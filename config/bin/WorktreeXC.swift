import Cocoa
import Foundation

struct Entry { let label: String; let path: String }

func enumerateCandidates() -> [Entry] {
    let home = NSHomeDirectory()
    let repo = "\(home)/Developer/notability"
    let nbgb = "\(home)/Developer/nb-gb/ios/Notability.xcodeproj"
    let fm = FileManager.default

    var entries: [Entry] = []
    if fm.fileExists(atPath: nbgb) {
        entries.append(Entry(label: "nb-gb", path: nbgb))
    }

    guard fm.fileExists(atPath: repo) else { return entries }

    let task = Process()
    task.executableURL = URL(fileURLWithPath: "/usr/bin/git")
    task.arguments = ["-C", repo, "worktree", "list", "--porcelain"]
    let out = Pipe()
    task.standardOutput = out
    task.standardError = Pipe()
    do { try task.run() } catch { return entries }
    task.waitUntilExit()

    let data = out.fileHandleForReading.readDataToEndOfFile()
    let output = String(data: data, encoding: .utf8) ?? ""
    let prefix = repo + "/"

    for line in output.split(separator: "\n", omittingEmptySubsequences: true) {
        guard line.hasPrefix("worktree ") else { continue }
        let wt = String(line.dropFirst("worktree ".count))
        let proj = "\(wt)/ios/Notability.xcodeproj"
        guard fm.fileExists(atPath: proj) else { continue }
        let label = wt.hasPrefix(prefix) ? String(wt.dropFirst(prefix.count)) : wt
        entries.append(Entry(label: label, path: proj))
    }
    return entries
}

let entries = enumerateCandidates()
guard !entries.isEmpty else {
    let notif = Process()
    notif.executableURL = URL(fileURLWithPath: "/usr/bin/osascript")
    notif.arguments = ["-e", "display notification \"No Notability.xcodeproj found\" with title \"Worktree XC\""]
    try? notif.run()
    exit(1)
}

final class KeyTableView: NSTableView {
    var onConfirm: (() -> Void)?
    var onCancel: (() -> Void)?

    override var acceptsFirstResponder: Bool { true }

    private func move(by delta: Int) {
        guard numberOfRows > 0 else { return }
        let current = selectedRow < 0 ? 0 : selectedRow
        let next = max(0, min(numberOfRows - 1, current + delta))
        selectRowIndexes(IndexSet(integer: next), byExtendingSelection: false)
        scrollRowToVisible(next)
    }

    override func keyDown(with event: NSEvent) {
        switch event.keyCode {
        case 36, 76: // Return, KeypadEnter
            onConfirm?()
        case 53: // Escape
            onCancel?()
        default:
            if let chars = event.charactersIgnoringModifiers {
                switch chars {
                case "j": move(by: 1); return
                case "k": move(by: -1); return
                default: break
                }
                if let digit = Int(chars), digit >= 1, digit <= numberOfRows {
                    let row = digit - 1
                    selectRowIndexes(IndexSet(integer: row), byExtendingSelection: false)
                    scrollRowToVisible(row)
                    return
                }
            }
            super.keyDown(with: event)
        }
    }
}

final class ListSource: NSObject, NSTableViewDataSource, NSTableViewDelegate {
    let entries: [Entry]
    init(_ entries: [Entry]) { self.entries = entries }
    func numberOfRows(in tableView: NSTableView) -> Int { entries.count }
    func tableView(_ tv: NSTableView, viewFor col: NSTableColumn?, row: Int) -> NSView? {
        let id = NSUserInterfaceItemIdentifier("cell")
        let cell = (tv.makeView(withIdentifier: id, owner: nil) as? NSTableCellView) ?? {
            let c = NSTableCellView()
            let tf = NSTextField(labelWithString: "")
            tf.translatesAutoresizingMaskIntoConstraints = false
            tf.lineBreakMode = .byTruncatingMiddle
            tf.font = NSFont.systemFont(ofSize: 13)
            c.addSubview(tf)
            c.textField = tf
            c.identifier = id
            NSLayoutConstraint.activate([
                tf.leadingAnchor.constraint(equalTo: c.leadingAnchor, constant: 8),
                tf.trailingAnchor.constraint(equalTo: c.trailingAnchor, constant: -8),
                tf.centerYAnchor.constraint(equalTo: c.centerYAnchor),
            ])
            return c
        }()
        let entry = entries[row]
        let prefix = row < 9 ? "\(row + 1)  " : "    "
        cell.textField?.stringValue = prefix + entry.label
        return cell
    }
}

let app = NSApplication.shared
app.setActivationPolicy(.regular)
app.activate(ignoringOtherApps: true)

let alert = NSAlert()
alert.messageText = "Worktree XC"
alert.informativeText = "Open Xcode in which worktree?"
alert.addButton(withTitle: "Open")
alert.addButton(withTitle: "Cancel")

let rowHeight: CGFloat = 22
let visibleRows = min(entries.count, 8)
let listHeight = CGFloat(visibleRows) * rowHeight + 2
let listWidth: CGFloat = 460

let table = KeyTableView()
table.headerView = nil
table.rowHeight = rowHeight
table.allowsMultipleSelection = false
table.allowsEmptySelection = false
table.intercellSpacing = NSSize(width: 0, height: 0)
table.style = .plain
table.usesAlternatingRowBackgroundColors = false
let col = NSTableColumn(identifier: NSUserInterfaceItemIdentifier("c"))
col.width = listWidth - 4
table.addTableColumn(col)

let source = ListSource(entries)
table.dataSource = source
table.delegate = source

let scroll = NSScrollView(frame: NSRect(x: 0, y: 0, width: listWidth, height: listHeight))
scroll.documentView = table
scroll.hasVerticalScroller = entries.count > visibleRows
scroll.borderType = .lineBorder
scroll.autohidesScrollers = true

alert.accessoryView = scroll

table.selectRowIndexes(IndexSet(integer: 0), byExtendingSelection: false)
table.onConfirm = { alert.buttons[0].performClick(nil) }
table.onCancel = { alert.buttons[1].performClick(nil) }

alert.window.initialFirstResponder = table
alert.window.level = .floating
DispatchQueue.main.async {
    alert.window.center()
    alert.window.makeFirstResponder(table)
}
app.activate(ignoringOtherApps: true)

let response = alert.runModal()
guard response == .alertFirstButtonReturn else { exit(0) }

let selectedRow = max(0, table.selectedRow)
let chosen = entries[selectedRow]
let openTask = Process()
openTask.executableURL = URL(fileURLWithPath: "/usr/bin/open")
openTask.arguments = [chosen.path]
try? openTask.run()
openTask.waitUntilExit()

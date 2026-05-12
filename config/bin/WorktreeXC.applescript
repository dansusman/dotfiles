on run
	-- Force frontmost via System Events. `tell me to activate` alone isn't enough
	-- on modern macOS for unsigned apps launched indirectly.
	tell me to activate
	try
		tell application "System Events"
			set frontmost of (first process whose name is "WorktreeXC") to true
		end tell
	end try

	set repoPath to (do shell script "echo $HOME/Developer/notability")
	set nbgbProj to (do shell script "echo $HOME/Developer/nb-gb/ios/Notability.xcodeproj")

	set rowsText to ""
	try
		set rowsText to do shell script "
set -e
REPO=" & quoted form of repoPath & "
NBGB=" & quoted form of nbgbProj & "
{
  if [ -e \"$NBGB\" ]; then
    printf 'nb-gb\\t%s\\n' \"$NBGB\"
  fi
  if [ -d \"$REPO\" ]; then
    /usr/bin/git -C \"$REPO\" worktree list --porcelain 2>/dev/null \\
      | awk '/^worktree /{print substr($0,10)}' \\
      | while IFS= read -r wt; do
          proj=\"$wt/ios/Notability.xcodeproj\"
          if [ -e \"$proj\" ]; then
            label=\"${wt#$REPO/}\"
            printf '%s\\t%s\\n' \"$label\" \"$proj\"
          fi
        done
  fi
}
"
	on error errMsg
		display dialog "Failed to enumerate worktrees: " & errMsg buttons {"OK"} default button 1
		return
	end try

	if rowsText is "" then
		display notification "No Notability.xcodeproj found" with title "Worktree XC"
		return
	end if

	set AppleScript's text item delimiters to (ASCII character 10)
	set rowLines to text items of rowsText
	set AppleScript's text item delimiters to ""

	set labels to {}
	set paths to {}
	repeat with ln in rowLines
		set s to ln as text
		if s is not "" then
			set AppleScript's text item delimiters to tab
			set parts to text items of s
			set AppleScript's text item delimiters to ""
			if (count of parts) is 2 then
				set end of labels to item 1 of parts
				set end of paths to item 2 of parts
			end if
		end if
	end repeat

	if (count of labels) is 0 then
		display notification "No Notability.xcodeproj found" with title "Worktree XC"
		return
	end if

	-- Re-assert frontmost right before showing the picker, in case shell delay let focus escape.
	try
		tell application "System Events"
			set frontmost of (first process whose name is "WorktreeXC") to true
		end tell
	end try
	set theChoice to choose from list labels with prompt "Open Xcode in which worktree?" default items {item 1 of labels} with title "Worktree XC"
	if theChoice is false then return

	set pickedLabel to item 1 of theChoice
	repeat with i from 1 to count of labels
		if item i of labels is pickedLabel then
			do shell script "/usr/bin/open " & quoted form of (item i of paths)
			return
		end if
	end repeat
end run

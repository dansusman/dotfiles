# Xcode settings

## Xcode setup
I haven't tested this yet, but it'd be cool to alias the dotfiles version of keybinds and theme and have Xcode load those settings instead of having
two copies, one backing up in this repo and one actually in use by Xcode. I don't want to break all my keybinds and have to manually set them back
up, so maybe when I'm actually setting up a new machine I can try doing it this way. And update this comment...

## `write.py` script

I've written a custom LLDB python script to copy breakpoints to the clipboard. Usage is as follows:

```
(lldb) command script import ~/.dotfiles/xcode/write.py
(lldb) write br list
```

## Xcode tips/binds

### Fast editing
- Add cursors for multi-cursor edits: `Ctrl+Shift+Click` or `Option+ArrowKey` (custom)
- Move selection up: `Ctrl+[` (custom)
- Move selection down: `Ctrl+]` (custom)
- Delete word backward: `Ctrl+W` (custom)
- Go Forward: `Ctrl+O` (custom)
- Go Back: `Ctrl+I` (custom)

### Compiler errors/warnings
- Cycle through errors: `Cmd+5` -> `Arrows` -> `Cmd+J` -> `Enter`
- Jump to next issue: `Ctrl+'`
- Jump to previous issue: `Ctrl+Shift+'`

### Git diff
- Jump to next change: `Ctrl+\` (custom)
- Jump to previous change: `Ctrl+Shift+\` (custom)
- Toggle code review mode: `Ctrl+Q` (custom)
- Side-by-side diff: `Ctrl+S` (custom)
- Inline diff: `Ctrl+Z` (custom)

### Misc
- Fold all code: `Cmd+Opt+Shift+LeftArrow`
- Unfold all code: `Cmd+Opt+Shift+RightArrow`
- Fold current block: `Cmd+Opt+LeftArrow`
- Unfold current block: `Cmd+Opt+RightArrow`
- Show documentation: `Cmd+Shift+0`
- Toggle debug area: `Cmd+Shift+Y`
- Find selected symbol in workspace: `Cmd+Ctrl+Shift+F`
- Jump to definition: `gr`
- Jump to references: `Ctrl+R` (custom)
- Next placeholder: `Ctrl+.` (custom)
- Previous placeholder: `Ctrl+,` (custom)
- Show Document items (marks and TODOs and such): `Ctrl+_` (custom)
- Clear all breakpoints: `Hyper+0` (custom)

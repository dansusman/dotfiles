---
name: whitespace-check
description: >
  Check file indentation (tabs vs spaces) before editing. Auto-triggers before any file edit
  to prevent "Bad control character in JSON" errors from the edit tool. Always use this skill
  when editing files — especially .svelte, .ts, .json, and other frontend files.
---

# Whitespace Check Before Editing

**ALWAYS** check a file's indentation style before using the `edit` tool.

## Why

The `edit` tool requires `oldText` to match the file exactly, byte-for-byte. If the file uses
tabs but you write spaces (or vice versa), the edit silently fails or causes JSON parse errors
("Bad control character in string literal").

## How

Before any edit, run:

```bash
sed -n '1p' <file> | xxd | head -1
```

Or check a few indented lines:

```bash
head -20 <file> | xxd | head -5
```

- `09` = tab character
- `20` = space character

## Rules

1. If the file uses **tabs** (`09`), use `sed -i ''` for replacements instead of the `edit` tool, since the edit tool's JSON transport chokes on literal tabs.
2. If the file uses **spaces** (`20`), the `edit` tool works fine.
3. When in doubt, use `sed` — it handles both.

## Quick Reference

| Byte | Char   | Safe for edit tool? |
|------|--------|---------------------|
| `09` | Tab    | **No** — use `sed`  |
| `20` | Space  | Yes                 |

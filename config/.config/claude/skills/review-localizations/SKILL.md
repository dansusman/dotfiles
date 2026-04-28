---
description: Review an app-db.txt localization update for missing format params, punctuation inconsistencies, and formatting issues. Assumes git diff is dirty with localization changes.
argument-hint: "[optional: path to app-db.txt, defaults to app-db.txt]"
---

# Review Localizations

Review localization changes in `$ARGUMENTS` (default: `app-db.txt`) for correctness.

## Steps

### 1. Capture the diff

```bash
git diff ${ARGUMENTS:-app-db.txt} > /tmp/loc_diff.txt
```

### 2. Run automated checks

Run this Python script to detect missing format params and punctuation mismatches:

```bash
python3 << 'PYEOF'
import re

with open('/tmp/loc_diff.txt', 'r') as f:
    lines = f.read().splitlines()

key = ""
en = ""
en_trail = ""
results = []

for line in lines:
    # Key lines are context lines: ' \t[keyname]'
    if re.match(r'^ \t\[[^\]]+\]$', line):
        key = line.strip()
        en = ""
        en_trail = ""
        continue

    # English value line (context or added)
    m = re.match(r'^[ +]\t\ten = (.+)$', line)
    if m:
        en = m.group(1)
        en_trail = en[-1] if en else ""
        continue

    # Added translation line: '+\t\tlang = value'
    m = re.match(r'^\+\t\t([a-z][a-zA-Z-]*) = (.+)$', line)
    if m and en:
        lang = m.group(1)
        val = m.group(2)
        val_trail = val[-1] if val else ""

        # Check missing format params
        for param in ['%1$@', '%2$@', '%3$@', '%d', '%i']:
            if param in en and param not in val:
                results.append(f"MISSING PARAM  [{key}] {lang}: missing {param}")

        # Check punctuation consistency vs English
        if en_trail == '.' and val_trail not in ('.', '\u3002'):
            results.append(f"MISSING PERIOD [{key}] {lang}: ends {repr(val_trail)}")
        if en_trail == '?' and val_trail not in ('?', '\uff1f'):
            results.append(f"MISSING QMARK  [{key}] {lang}: ends {repr(val_trail)}")
        if en_trail not in ('.', '?', '!', ':') and val_trail == '.':
            results.append(f"EXTRA PERIOD   [{key}] {lang}: (en ends {repr(en_trail)})")

for r in results:
    print(r)
print(f"\n{len(results)} issues found.")
PYEOF
```

### 3. Manual spot-checks

Beyond what the script catches, also check:

- **Missing spaces in translations**: scan for suspiciously joined words (common in ru, de)
- **Incorrect capitalization**: label/button strings should capitalize consistently across languages — check `fr` in particular, which sometimes lowercases where others capitalize
- **Wrong period character in Chinese**: should be `。` (U+3002), not `.` (U+002E). Verify with:
  ```bash
  grep "zh-Han" /tmp/loc_diff.txt | grep "^\+" | python3 -c "
  import sys
  for line in sys.stdin:
      line = line.rstrip()
      last = line[-1]
      if ord(last) in (ord('.'), ord('\u3002'), ord('\uff0e')):
          print(hex(ord(last)), repr(last), '|', line[-60:])
  "
  ```
  All Chinese endings should be `0x3002 '。'`, never `0x2e '.'`.

### 4. Interpreting results

- **Thai (th)** commonly omits Western punctuation (`.`, `?`) — this is often intentional due to Thai typography conventions. Flag it but note it may be acceptable.
- **EXTRA PERIOD on `comment`** lines — false positive from the script, ignore.
- **ko, pt, uk-UA** sometimes add trailing periods on bullet-point strings where English omits them — flag for review but may be locale-conventional.

### 5. Report findings

Group results by severity:
1. **Clear bugs**: missing params, missing spaces, wrong characters
2. **Punctuation mismatches**: extra/missing periods vs English
3. **Possibly intentional**: Thai punctuation omissions, locale-conventional periods

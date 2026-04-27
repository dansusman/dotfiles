---
name: pr-review-slideshow
description: Review a GitHub PR and produce an HTML slideshow of manual-verification callouts (no comments posted, no approve/reject). Use when the user says "review PR <num> and make a slideshow", "slideshow callouts for <num>", "generate review callouts for <num>", "look at <num> and give me callouts", or similar. Two-pass review: initial suggestions, then validate each by tracing code, then output the deck.
---

# PR Review Slideshow

Generate an HTML slideshow of review callouts for a Notability PR. **Never** post comments, approve, or reject — output is for the human reviewer to verify manually.

## Inputs

The user gives a PR number (e.g. `51840`). Assume the `Ginger-Labs/Notability` repo unless told otherwise.

## Workflow

### 1. Gather PR context

```bash
gh pr view <num> --json title,body,author,files,additions,deletions,baseRefName,headRefName,url
gh pr diff <num>
```

Read the description carefully — author often flags their own concerns and lists manual test steps. Capture both.

### 2. First pass — generate suggestions

Walk the diff and brainstorm callouts. For each, classify:

- ⚠️ **High priority** — possible correctness bug, contract violation, or silent regression.
- 🟡 **Tuning / consider** — magic numbers, missing config, perf concerns.
- ✅ **Like** — genuinely good changes worth acknowledging.
- 🧪 **Tests / QA** — missing coverage; manual test plan.
- 💅 **Nits** — style, naming, conventions (CLAUDE.md rules: no `lazy var`, no `+` for list concat, no pragma marks, deprecated APIs, etc.).

Cross-reference project conventions:
- `/Users/danielsusman/Developer/notability/review/CLAUDE.md` and platform sub-CLAUDE.mds (`ios/CLAUDE.md`, etc.)
- `docs/observability.md` for log keys / levels
- `docs/analytics.md` for Mixpanel events

### 3. Second pass — validate every suggestion by tracing the code

This is the most important step. For each callout from pass 1, **track it down in the actual codebase before keeping it**. Common things to verify:

- **Library/API contracts.** If a callout assumes "callback shape X" or "indexing convention Y", read the implementation. Use `grep -rn` to find the function definition. Trace through Objective-C / C++ / Swift bridges if needed (e.g. PDFTron lives in `ios/GLConversion/GLConversion/PDFTronWrapper.m`).
- **Threading.** Find the call site, walk up to the OperationQueue / DispatchQueue / actor that schedules it. Don't assume "synchronous = main thread."
- **Reusability concerns.** If you suggested "reuse existing X instead of allocating new Y", check whether X actually exposes the API Y needs (different wrappers around the same PDF can use CGPDFDocument vs PDFKit vs PDFTron — they're not interchangeable).
- **Magic numbers / thresholds.** Run the comparison against any sibling parser used elsewhere in the indexing/processing pipeline. A threshold check using parser A while the actual downstream work uses parser B is a real silent-regression risk.
- **Index conventions.** 0- vs 1-indexed bugs are easy to introduce. Trace from the value's origin (often a C/Obj-C library) to its consumer.

For each callout, the second pass produces one of three verdicts:

1. **Confirmed concern** — keep as a callout slide. Include the trace evidence (file:line) so the human can sanity-check fast.
2. **Confirmed non-issue** — drop from the active callouts, but **keep on the "non-issues" recap slide** with the one-line reason it's fine.
3. **Refined** — concern was real but different from the original framing. Rewrite the slide.

### 4. Build the HTML slideshow

Write to `/tmp/pr-<num>-callouts.html` and `open` it.

Required slides, in order:

1. **Title** — PR number, author, base/head, additions/deletions, files touched, one-line goal.
2. **What it does** — short summary in the reviewer's own words.
3. **Confirmed callouts** — one slide per kept concern. Each slide:
   - Pill (`warn` / `info` / `good` / depending on severity)
   - One-sentence claim
   - A `<pre>` with the relevant code or trace evidence (file:line)
   - 1–3 bullets of "**Verify:** …" actions for the human
4. **Manual QA checklist** — author's listed test steps + any extras you'd add (mixed-content cases, edge thresholds, cancellation).
5. **Style nits** (optional, only if any)
6. **Initial recommendations — confirmed non-issues** — *required slide*. List every callout that was dropped after the second pass, with the one-line reason ("PDFTron `GetIndex` is 1-indexed by spec, see `PDFTronWrapper.m:198`"). This shows the human what was already vetted so they don't waste time re-checking.
7. **Summary** — bullet list of recommendations with severity pills, plus a footer reminder: *"Do not post on the PR — manual verification only."*

### Slideshow format

- Write to `/tmp/pr-<num>-callouts.html` and `open` it. (`/tmp` is wiped on reboot — fine, these decks are disposable. If the user wants to keep one, they'll ask.)
- Self-contained HTML, no external assets.
- Styling is freeform — pick whatever fits the PR (dense technical PR → compact dark theme; user-facing PR → roomier with screenshots/diagrams if relevant). Don't force consistency across decks.
- Required interactions: keyboard nav (`←` / `→` / space) and a visible slide counter. Beyond that, do what makes sense.

## Hard rules

- **Do not** run `gh pr review`, `gh pr comment`, `gh pr close`, or any state-changing GitHub command.
- **Do not** push commits or branches.
- After the deck is written, just say it's ready and where it is. Summarize the most important 2–3 callouts in chat for quick triage.
- If the user later asks to dig into a specific callout further, do another targeted trace and report findings in chat. Only update the deck if they ask.

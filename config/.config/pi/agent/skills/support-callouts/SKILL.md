---
name: support-callouts
description: Generate a support-team callout list for a Notability release PR. Use when the user says "support callouts for 16.2", "support notes for PR 51586", "generate support callouts for <version>", "what should support know about this release", or similar. Produces a grouped, plain-language list of user-facing changes (with extra emphasis on Support Requested / Zendesk / user-reported items) plus a separate Tech Debt section for manual review.
---

# Support Callouts Generator

Produces a list of callouts for the Notability support team describing what's in a release, grouped by theme, in plain non-technical language focused on user impact. Highlights items tied to user reports (Zendesk, Support Requested label, beta feedback, linked issues from users).

## Input

User gives either:
- A version like `16.2` → find the `<version> Submission` PR in `Ginger-Labs/Notability`.
- A PR number like `51586` → use directly.

Find the submission PR:
```bash
gh pr list --repo Ginger-Labs/Notability --state all --search "<version> Submission in:title" --json number,title
```

## Step 1 — Gather raw data

1. Read the submission PR body:
   ```bash
   gh pr view <num> --repo Ginger-Labs/Notability --json body,title
   ```
   Parse out all linked PR numbers grouped by section (Cherry Picks, High, Medium, Low, Skip QA). Include **all** sections — support needs to know about Low Priority and Skip QA fixes too.

2. For each linked PR, pull title, body, labels, and linked issues:
   ```bash
   for pr in <list>; do
     echo "=== PR $pr ==="
     gh pr view $pr --repo Ginger-Labs/Notability \
       --json title,body,labels,closingIssuesReferences \
       --jq '{title, labels: [.labels[].name], body: (.body // "")[:2000], issues: [.closingIssuesReferences[]?.number]}'
   done
   ```
   Use `--jq` to keep output compact. Truncate body to ~2000 chars per PR — enough to see screenshots/videos/support mentions.

3. For any PR that references an issue (via `closingIssuesReferences` or `Fixes #NNNNN` / `Closes #NNNNN` / `#NNNNN:` in the title or body), pull the issue:
   ```bash
   gh issue view <issue_num> --repo Ginger-Labs/Notability \
     --json title,body,labels \
     --jq '{title, labels: [.labels[].name], body: (.body // "")[:1500]}'
   ```

4. While scanning each PR/issue, flag these signals and remember them per PR:
   - **Support Requested** — label on PR or issue, or phrase in body/title.
   - **Zendesk** — any mention or link (`zendesk.com`, `z.n`, ticket numbers).
   - **User reports / user feedback / reported by users / reddit / App Store review** — phrases in body.
   - **Beta feedback / TestFlight feedback** — phrases in body.
   - **Screenshots / images** — `![...](...)` or `user-images.githubusercontent.com` / `github.com/.../assets/` links.
   - **Demo videos** — `.mov`, `.mp4`, `.webm`, or `user-images`/`assets` video embeds, or words like "demo", "video", "recording".

## Step 2 — Classify each PR

Put each PR into exactly one of these buckets:

**A. User-facing** (default for anything with visible behavior change): new feature, bug fix, UI change, performance win users will feel, copy change, settings change, onboarding change, billing/subscription change.

**B. Tech debt / internal / fully gated**: refactors with no behavior change, renames, analytics-only, translations, backend/URL plumbing, debug menu, SDK bumps with no user effect, version bumps, CI, dependency updates, code behind a feature flag that is **off** in this release.
- If a feature flag is being flipped on (even partially / beta) in this release, it's **user-facing**, not tech debt.
- If unsure, default to user-facing — support would rather hear about it.

## Step 3 — Write the callouts

Output format:

```
Support Callouts — Notability <version>
Release PR: https://github.com/Ginger-Labs/Notability/pull/<num>

## 🚨 User-Reported / Support-Requested Fixes
(items flagged with Support Requested label, Zendesk mentions, user reports, or beta feedback — surface these first so support knows "yes, this is the one you've been hearing about")

- <Plain-language description of the change and who it affects>
  PR: https://github.com/Ginger-Labs/Notability/pull/XXXXX
  Signals: Support Requested label, Zendesk ticket mentioned
  📸 Screenshots in PR   🎥 Demo video in PR   (only if actually present)

## ✨ New Features

- Introducing <Feature> — <one sentence on what it does and how users access it>.
  PR: https://github.com/Ginger-Labs/Notability/pull/XXXXX
  🎥 Demo video in PR

## 🛠 Bug Fixes & Improvements
(grouped by theme where it makes sense — library, editor, subscriptions, iOS 26, migration, etc.)

### <Theme e.g. Library & Thumbnails>
- <Plain-language description>
  PR: https://github.com/Ginger-Labs/Notability/pull/XXXXX

### <Theme e.g. Subscriptions & Billing>
- ...

## ⚠️ Watch-outs (refactors shipping — expect possible regression reports)
(PRs that are risky refactors of user-facing areas — not tech debt exactly, but support should know what to blame if reports spike)

- <Area> was refactored this release. If you see an uptick in <specific user-visible symptom>, it may be related.
  PR: https://github.com/Ginger-Labs/Notability/pull/XXXXX

---

## 🧹 Tech Debt / Internal (human review)
Listed for human review — these look internal-only, but double-check before sending to support.

- PR #XXXXX — <title>
- PR #XXXXX — <title>
```

### Writing style rules

- **Plain language, user impact first.** Not: "Refactored NotesViewModel out of NotesView." Yes: "Library layout code was restructured — watch for reports of notes not selectable or long-press menu actions not working."
- **No internal jargon.** Translate:
  - `collab` → `Notability Cloud` (the new note engine) — **never** "shared notes" / "collaboration"
  - `legacy` → `classic Notability` (or just "the previous note engine")
  - `NBC` → `Notability Cloud`
  - `SK1/SK2`, `StoreKit`, `Redux` → describe the user effect instead
  - `B2B` → okay to keep, support knows it (business trial users)
- **Mention who's affected** when it's a subset: "Chinese users typing with IME…", "business trial users on the Billing tab…", "users on iOS 26…".
- **Mention where to find it** for new features ("available in the note options menu") and new surfaces ("beta only for now").
- **Call out screenshot/video availability** with 📸 / 🎥 and the PR link only when the PR body actually contains them — verify from the fetched body text.
- **Don't invent severity.** If a PR doesn't say Zendesk or Support Requested, don't claim it did.
- **Group related small fixes** under one theme bullet when they reinforce the same support narrative (e.g. three checklist fixes → one "Checklists toggle more reliably" callout listing all three PR links).

### Signal phrasing

When surfacing items in the "User-Reported / Support-Requested" section, note the *kind* of signal in a short `Signals:` line. Examples:
- `Signals: Support Requested label`
- `Signals: Zendesk ticket linked in PR`
- `Signals: Linked issue reports user saw <X>`
- `Signals: Beta feedback mentioned in PR body`
- `Signals: Reddit report mentioned in PR body`

## Step 4 — Offer follow-ups

After printing, offer to:
- Expand any bullet with more detail (e.g. exact reproduction steps from the linked issue).
- Re-cluster under different themes.
- Produce a shorter "top 5" version for a Slack post.

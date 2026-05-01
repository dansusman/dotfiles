---
name: generate-beta-test-details
description: Generate TestFlight beta tester "Test Details" notes for a Notability iOS release. Use when the user says "write beta test details for 16.2", "draft beta notes for PR 51586", "generate test details for <version>", or similar. Finds the release submission PR on GitHub, reads the linked PRs, filters for user-visible changes (especially .beta features wanting feedback), and outputs 3-4 main bullets plus an optional "For new canvas testers" section.
---

# Beta Test Details Generator

Writes the "Test Details" / "What to Test" notes shown to TestFlight beta testers for a Notability iOS release. Audience is real users on the beta — slightly more instructional and detailed than App Store "What's New" copy, but still in plain user-facing voice.

## Finding the submission PR

The user will give you either:
- A version like `16.2` → find the PR whose title is `16.2 Submission` (or closest match) in the `Ginger-Labs/Notability` repo.
- A PR number like `51586` → use it directly.
- Nothing → find the most recent `Submission` PR.

To find by version:
```bash
gh pr list --repo Ginger-Labs/Notability --state all --search "<version> Submission in:title" --json number,title
```
To find the most recent:
```bash
gh pr list --repo Ginger-Labs/Notability --search "Submission" --limit 3 --json number,title,author,createdAt
```
If multiple match, prefer state `open` and the exact title `<version> Submission`. Confirm with the user if ambiguous.

## Gathering context

1. `gh pr view <num> --json body,title` on the submission PR to get the list of linked PRs (grouped by Cherry Picks / High / Medium / Low / Skip QA).
2. **Do not filter by test-priority section.** Pull from Cherry Picks, High, Medium, and Low — user impact is what matters, and a Medium-priority PR may have higher user impact than a High-priority one. Skip the `Skip QA` section.
3. Batch-fetch PR titles and bodies in parallel groups of ~15:
   ```bash
   for pr in <list>; do
     echo "=== $pr ==="
     gh pr view $pr --json title,body --jq '.title + "\n" + (.body // "" | .[:400])' 2>/dev/null
   done
   ```
4. If a PR description is sparse or unclear, read the linked issue (`gh issue view <num> --repo Ginger-Labs/Notability`) to understand what the user actually sees.

## What to exclude

Always skip:
- Tech debt, refactors, internal plumbing, SDK/dependency upgrades with no user-visible behavior
- Unit test PRs and pure documentation PRs
- Analytics/tracking/logging-only changes
- Translation/localization-only changes
- Debug menu changes
- MyScript / handwriting recognition engine upgrades and language-pack updates (treat as tech debt)
- B2B / business-trial-only features

## Filter by feature flag status

For any PR that touches `Feature.swift`, you must determine the **post-change** status, not the prior status:

```bash
gh pr view <NUMBER> --json files | jq -r '.files[].path' | grep -i "feature"
gh pr diff <NUMBER> | grep -A2 -B2 "<FeatureCaseName>\|optIn\|beta\|everyone\|remoteConfig\|gingerLabs"
```

**Read the diff carefully.** A flag-promotion PR has a `-` line with the old status and a `+` line with the new status. The new status is what ships to users in this release. A common mistake is to grep, see `.optIn` once, and exclude the PR — when the PR is actually *promoting* the flag from `.optIn` to `.beta`, which is exactly the kind of change beta testers should know about.

**Promotions matter even when no other code changes.** A standalone PR whose only diff is `case .myFeature: return .optIn` → `case .myFeature: return .beta` (or `.beta` → `.everyone`, `.beta` → `.remoteConfig`) is a major callout — that's a feature *becoming visible* to this release's audience for the first time. Look up the feature's behavior (search for the case name in the codebase, or the original PR that introduced it) and write the bullet about the feature itself, not about the flag flip.

### When the feature is hard to describe

For a flag-promotion PR (or any included PR) where the title, description, diff, and linked issue don't make the user-facing behavior clear, briefly try to glean a product description from the repo before giving up:

1. Grep for the feature case name across the repo to find where it gates behavior — `grep -rn "Feature.<caseName>" Source/ ios/` (or the equivalent path). The call sites and surrounding UI strings often explain what the feature does.
2. Search for the original PR that introduced the case (`git log -S "<caseName>" -- '*Feature.swift'`) and read its description.
3. Look for related localization strings, view-controller names, or analytics event names tied to the feature.

If after that the behavior is still unclear, **do not invent a description**. Include the feature in the main or canvas-testers section as a placeholder bullet, with the linked PR, calling out that a human needs to fill it in. Example:

```
- ⚠️ <FeatureCaseName> is now visible to beta users in this release, but I couldn't generate a product description from the PR, diff, or surrounding code. Please write the details manually. ([flag promotion PR](https://github.com/Ginger-Labs/Notability/pull/51736))
```

This is better than silently dropping the callout (which is what caused the #51736 miss) and better than guessing wrong.

**Inclusion rules — based on the PR's resulting (post-change) flag value:**
- `.everyone` → include
- `.remoteConfig` → include
- `.beta` (including promotions *to* `.beta`) → **prioritize**. Beta-flagged features are exactly what we want testers to try and give feedback on. Call them out and, when reasonable, give a short instruction on how to find them.
- `.optIn` (and demotions to `.optIn`) → exclude
- `.gingerLabs` → exclude

If a PR demotes a flag (e.g. `.beta` → `.optIn` because something regressed), exclude it and consider noting it in **Considered but skipped** with the reason "feature pulled back to internal".

PRs that don't touch `Feature.swift` are judged by title/description for user visibility (bug fix, UX improvement, etc.).

## Notability vocabulary

Translate internal names to user-facing ones:
- `collab` → **Notability Cloud** (the new note engine). For canvas-specific work, **new canvas** is also OK in the canvas-testers section.
- `ASR` → **Transcription**
- Never use internal names: "legacy", "collab", "Redux", "SK1", "SK2", "CloudKit", "CloudKit daemon", "ENE", flag names, PR numbers, file names. If a change only makes sense by referencing legacy, it's probably internal — skip it.

"Collab" / "Notability Cloud" canvas changes are anything that affects the note editing surface itself: text boxes, PDFs, highlighter, eraser, pen, images, gestures, page navigator, hover, zoom view inside a note, image-to-ink, etc. These go in the **For new canvas testers** section, not the main list.

## Output format

Two sections:

**Main section** — 3-4 bullets covering general user-visible changes (library, settings, sync, non-canvas UI, performance, bug fixes). Lead with the most impactful or most-want-feedback item. Don't label this "fixes for everyone" or similar — the absence of the canvas-testers heading already implies that.

**For new canvas testers:** (optional, only include if there's relevant material) — 2-3 bullets about Notability Cloud canvas / note-editing changes.

Bullet style:
- Use `-` for the prefix throughout the output (consistent in main, canvas, and below-the-fold sections).
- **Be concise.** One short sentence per bullet. Cut qualifiers, mechanism details, and "why" explanations. The reader is a beta tester skimming a list, not reading copy.
  - Good: `- Link-shared notes can now be deleted from the recipient's library`
  - Too wordy: `- Link-shared notes can now be deleted from the recipient's library, autosync exports as .ntb instead of .pdf so notes round-trip back to Notability cleanly, …`
- **Don't try to surface every change.** Pick the 3-4 most important user-visible items. Cram-bullets that string together five unrelated fixes are a sign you should promote one and drop the rest into "Considered but skipped".
- For new features at `.beta`, a short hint on how to try it is OK (one extra clause, not a second sentence) since the goal is feedback.
- Plain user voice. Describe the outcome, not the implementation.
- Grouping small related polish into one themed bullet is fine ("Highlighter, textbox, and checklist improvements") — but only when the items actually share a theme.

## After printing

Output three sections, all using `-` bullets. Every PR/issue reference must be a **markdown link with the PR title as the link text** and the full GitHub URL as the target, e.g. `[Apple Pencil Pro haptics on iPad Pro](https://github.com/Ginger-Labs/Notability/pull/51205)`. Cmd+Click on the rendered link navigates in the terminal. Do not use bare `#51420` references or bare URLs without titles anywhere in the output.

1. **Sources by bullet** — bulleted list, one bullet per output bullet, listing the linked PRs that fed it.
   ```
   - Pencil Pro haptics: [Apple Pencil Pro haptics on iPad Pro](https://github.com/Ginger-Labs/Notability/pull/51205) (.beta)
   ```

2. **Considered but skipped** — bulleted list of user-visible PRs that didn't make the cut (small polish, edge-case fixes, borderline items). One bullet per PR with the title-linked PR plus a short reason. These are fair game to surface if the user asks.
   ```
   - [Adjust font preset sizes](https://github.com/Ginger-Labs/Notability/pull/51421) — minor polish
   - [Fix OAuth display name](https://github.com/Ginger-Labs/Notability/pull/51839) — narrow audience
   ```

3. **Tech debt / internal / debug** — separate bulleted list of PRs excluded for not being user-facing at all (refactors, debug menu, internal plumbing, .optIn / .gingerLabs, ASR/MyScript internals, etc.). Title-linked PR plus short reason each.
   ```
   - [Refactor handwriting pipeline](https://github.com/Ginger-Labs/Notability/pull/51381) — refactor
   - [Add debug toggle for X](https://github.com/Ginger-Labs/Notability/pull/51736) — .optIn flag
   ```

4. **User-reported / support-requested** — bulleted list of any *included* PRs (i.e. ones that ended up as a main or canvas-tester bullet) that originated from real user feedback, beta feedback, or a support request. The point of this section is to flag for the user "these specific bullets are responses to people who reported the issue — you may want to highlight them differently."

   How to determine if a PR qualifies:
   - Check PR labels: `gh pr view <NUMBER> --json labels --jq '.labels[].name'`. Labels like `support-requested`, `user-feedback`, `beta-feedback`, `zendesk`, `customer-reported` count.
   - Check linked issue(s): `gh pr view <NUMBER> --json closingIssuesReferences --jq '.closingIssuesReferences[].number'`, then `gh issue view <ISSUE> --json labels,body --repo Ginger-Labs/Notability`. Look at issue labels (same set) and skim the body for: Zendesk ticket links, Slack thread links to user-report channels, phrases like "user reports", "customer reported", "from a beta tester", "support team escalation".
   - PR description itself sometimes mentions "reported by …" or links a Slack/Zendesk thread.

   **Confidence:** include a short confidence note when the signal is ambiguous. For example, if the linked issue has Slack links but doesn't explicitly say "user report", note that. Format: `<status>` for clear cases, `<status> (<short caveat>)` for ambiguous ones.

   ```
   - [Allow deleting link-shared notes](https://github.com/Ginger-Labs/Notability/pull/51665): support requested
   - [Detect non-standard MP4 audio](https://github.com/Ginger-Labs/Notability/pull/51613): user feedback (multiple Slack links in linked issue, not 100% sure they're user reports)
   - [Fix iPhone Pro upsell button overlap](https://github.com/Ginger-Labs/Notability/pull/51420): beta feedback
   ```

   If no included PRs qualify, omit the section entirely rather than printing an empty one.

Then offer to promote anything from "Considered but skipped" into the main bullets, swap items between sections, or adjust tone.

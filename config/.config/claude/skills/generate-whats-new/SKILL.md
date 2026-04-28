---
name: generate-whats-new
description: Generate Apple App Store "What's New" release notes for a Notability iOS release. Use when the user says "write what's new for 16.2", "write what's new for PR 51586", "draft release notes for <version>", "generate whats new", or similar. Finds the release submission PR on GitHub, reads the linked PRs, filters by feature flag visibility, and outputs ~4 bullets in Notability's App Store voice.
---

# What's New Generator

Writes the "What's New in This Version" text shown on the App Store for a Notability iOS release.

## Finding the submission PR

The user will give you either:
- A version like `16.2` → find the PR whose title is `16.2 Submission` (or closest match) in the `Ginger-Labs/Notability` repo.
- A PR number like `51586` → use it directly.
- Nothing → find the most recent `Submission` PR authored by the current user.

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
2. Focus on **Cherry Picks**, **High Priority**, and **Medium Priority** sections. Skip `Skip QA` and usually skip Low Priority unless something there is clearly user-facing.
3. Batch-fetch PR titles and bodies in parallel groups of ~15:
   ```bash
   for pr in <list>; do
     echo "=== $pr ==="
     gh pr view $pr --json title,body --jq '.title + "\n" + (.body // "" | .[:300])' 2>/dev/null
   done
   ```
4. If a PR description is sparse or unclear, read the linked GitHub issue it fixes (`gh issue view <num> --repo Ginger-Labs/Notability`) to understand user impact.
5. Ignore internal work: refactors, tech debt, analytics/tracking, backend/URL plumbing, translations, debug menu, SDK migrations with no user-visible effect.
   - **MyScript / handwriting recognition engine upgrades and language-pack updates are tech debt**, not user-facing. Don't write bullets about them even though the PR can sound impactful.

## Filter by feature flag status

For any PR that looks like it introduces a new feature, check whether it touches `Feature.swift`:

```bash
gh pr view <NUMBER> --json files | jq -r '.files[].path' | grep -i "feature"
```

If it does touch `Feature.swift`, check the diff to see what status the new feature case is assigned:

```bash
gh pr diff <NUMBER> | grep -A30 "<FeatureCaseName>\|optIn\|beta\|everyone\|remoteConfig\|gingerLabs"
```

**Inclusion rules:**
- `.everyone` → include (visible to all users)
- `.remoteConfig` → include (server-controlled rollout to real users)
- `.beta` → include only if the PR description makes clear it's a significant user-facing change being broadly tested
- `.optIn` → exclude (debug/internal only, not visible to real users)
- `.gingerLabs` → exclude (Ginger Labs staff only)

If a PR does NOT touch `Feature.swift`, judge by the title/description whether it's user-visible (bug fix, UX improvement, etc.).

## Notability vocabulary (important)

- **"Collab" ≠ "shared notes".** Collab is the internal name for Notability's new note engine (the one that replaced Legacy). Its user-facing name is **Notability Cloud**. Fixes on the collab path affect all notes on the new engine, not just notes shared with other people. Translate `collab` → `Notability Cloud`. Never write `shared`, `shared notes`, or `collaboration` for collab-path work.
- **Distinguish "added to Notability Cloud" from "fixed".** PRs titled like "Port X to Collab" or "X UI Feedback for Collab" are usually **bringing a feature that already exists on Legacy over to the new Notability Cloud engine**. Frame as "Added X on Notability Cloud", not "Fixed X".
- **Avoid "canvas".** Users don't think of the note editor as a canvas. Prefer "note-taking", "writing", "notes", or name the specific tool (pen, highlighter, eraser, checklist).
- No internal jargon: no "Redux", "SK2", "legacy", "collab", PR numbers, etc.

## Writing the bullets

Output around **4 bullets**, each prefixed with `• ` (the U+2022 bullet, not `-` or `*`). 4 is a default, not a rule — a release with only 3 strong user-facing themes should ship 3 bullets rather than padding with weak material.

Voice and format rules:
- **New feature announcements** use the `Introducing <Feature>: <one-sentence benefit>.` pattern with a colon.
  - Example: `• Introducing Study Timer: Stay focused with set study sessions and built-in breaks.`
- **Improvements and bug fixes** are written as plain sentences without a colon, describing the outcome for the user. No trailing period is fine; match the examples below.
  - `• Optimized images on Notability Cloud to take up less storage space while keeping quality`
  - `• Improved Zoom View experience across all toolbar positions`
  - `• Better layout for Learn on smaller screens`
- Group related small fixes into a single themed bullet (e.g. combine checklist + highlighter + eraser polish into "Fixed…").
- Lead with the most exciting / most user-visible item. If there's a genuinely new feature in the release, make it bullet 1 with the `Introducing` pattern.
- Keep each bullet to one line, user-benefit focused.
- iOS version fixes → phrase as "Smoothed out iOS <N> rough edges, including …".
- Do not mention B2B/business trial features in consumer "What's New" copy.

## Output

After printing the bullets, list which PRs each bullet was sourced from (and a brief note on PRs excluded because of feature-flag status) so the user can verify. Then offer to tweak tone, swap bullets, or lean more feature-forward vs. fix-forward.

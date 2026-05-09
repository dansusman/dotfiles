---
description: Run the PR code review loop locally against the current branch — same review the GH action would run on push, but before opening the PR. Present feedback, get user sign-off, apply fixes as commits. Does NOT push or open a PR.
argument-hint: "[optional base branch, defaults to staging]"
---

# Finalize PR (local pre-PR review loop)

Mirrors what the `ci-review-pr` GitHub Action would do once the PR is open — but runs locally against the current branch so you can address feedback before pushing. **This skill does not push, open, or update a PR.**

## Steps

### 1. Detect GitButler vs plain git

GitButler stacks multiple branches into one workspace, so plain `git diff` against `staging` will mix changes from every applied branch. The skill must scope the review to the **single branch** the user is prepping for PR.

- Probe: run `but status --json`. If it succeeds, treat this as a GitButler repo.
- If GitButler:
  - Run `but branch list --json` to enumerate applied branches with their CLI IDs.
  - If exactly one branch is applied AND it has commits to review, use it (still confirm out loud: "Reviewing branch `<name>` (`<id>`) — proceed?").
  - **In any ambiguous case, ASK the user which branch to diff** — multiple applied branches (a stack), nested stacks, branch with no commits, etc. Show the list with IDs, names, and commit counts. Never guess.
  - Selected branch becomes `<branch-id>`. Skip git base-detection — `but` already knows the branch's parent in the stack.
- If plain git:
  - Default base: `staging`. Override with `$ARGUMENTS` if provided.
  - If the current branch was cut from a non-`staging` parent, detect via `git merge-base` and use that.
  - Refuse to run if the current branch IS the base (`staging`/`main`).

### 2. Sanity checks

- **GitButler**: run `but status` and check the selected branch has commits (look at the branch entry). If only uncommitted changes, ask whether to commit them to that branch first (via `but commit <branch>`) or abort. If the branch has zero commits and zero changes, abort.
- **Plain git**: run `git status`. If there are uncommitted changes, ask whether to commit them first or abort. Run `git log <base>..HEAD --oneline` to confirm there are commits to review. If empty, abort.

### 3. Gather context

Pull the diff scoped to the single target branch — never the whole stack or whole workspace.

- **GitButler**:
  - `but diff <branch-id>` — diff for that branch only (excludes other stacked branches above/below).
  - Derive the file list from that diff output.
  - For each modified file, still use `git log --oneline -10 -- <file>` for history context (git history is shared regardless of GitButler).
- **Plain git**:
  - `git diff <base>...HEAD` (three dots: changes on this branch only).
  - `git diff <base>...HEAD --name-only` for the file list.
  - `git log --oneline -10 -- <file>` per modified file for churn/contradiction context.

### 4. Run the code-reviewer agent

Spawn `subagent_type="code-reviewer"` with a prompt that contains:

- A `## Diff to Review` section with the full diff from step 3.
- A `## Git History Context` section if step 3 surfaced relevant recent fixes or high-churn files.
- An instruction to return findings as inline-style items: `<file>:<line> — <comment>`, plus an overall verdict (`ship it` / `minor tweaks` / `simplify first`).

Do NOT pass any prior review context — this is a fresh review of current state.

### 5. Present findings + proposed fixes as an HTML slideshow

Render the findings using the **`visual-explainer:generate-slides`** skill. One finding per slide. Each slide must include:

- **Severity badge**: Must fix (correctness/security/data-loss/SOC2/PII/broken invariants) · Should fix (engineering-values violations, missing tests in high-leverage areas) · Nit (style/naming/clarity).
- **Location**: `<file>:<line>`.
- **The finding** — what the reviewer said.
- **Proposed fix** — concrete before/after code snippet, or "no change recommended" with reasoning.

Add a title slide (PR summary: branch, base, file count, finding count by severity) and a final "Sign-off" slide listing every finding with its identifier so the user can refer to them by number.

After generating the deck, open it locally and tell the user the file path. Do NOT apply any changes yet.

If the verdict is `ship it` and there are no Must/Should items, skip the slideshow, report "Branch is review-clean" and stop.

### 6. User sign-off

Ask the user which proposals to apply. Accept any of:

- "all" / "apply all"
- A list of item numbers/identifiers
- "skip nits"
- "none" — stop without changes

For ambiguous or judgment-call items, ask before assuming.

### 7. Apply approved fixes

- Edit the relevant files to apply only the approved proposals.
- Commit them as one or more focused commits. Use conventional commit style per `~/bin/generate-commit`.
- **GitButler**: commit to the selected branch with `but commit <branch-id> --only -m "..."` (and `but stage` first if needed) so fixes do not leak into other stacked branches.
- **Plain git**: `git add <files>` then `git commit -m "..."`.
- **Do NOT add Claude as a co-author. Do NOT include a `Co-Authored-By: Claude` trailer.** Plain commit only.
- Do not amend existing commits — always create new commits.

### 8. Verification pass

Re-run the code-reviewer agent against the new branch-scoped diff (`but diff <branch-id>` for GitButler, `git diff <base>...HEAD` for plain git).

- **Clean** — report verdict and stop.
- **New issues** — surface them with proposed fixes via a fresh `visual-explainer:generate-slides` deck (same format as step 5), get sign-off, apply. Then stop. Do not loop a third time automatically — repeated passes thrash.

### 9. Final report

Output:

- The verdict (clean / outstanding items the user chose to skip).
- The commits added during this run (`git log <base>..HEAD --oneline`).

Do not prompt the user to push or open a PR — that is their next step on their own terms.

## Important

- This skill **never** pushes, opens a PR, edits PR labels, or touches GitHub.
- Never add Claude as a commit co-author.
- Do not amend existing commits — always create new commits for fixes.
- Do not run `git push --force` or `--force-with-lease` under any circumstance.
- Respect the project's engineering values, observability, and analytics rules from `CLAUDE.md` when evaluating findings.

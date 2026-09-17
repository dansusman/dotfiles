## Working style

- Simplest change that's *right*, not patches on patches. Readability matters most, and I'm happy to make bigger changes to achieve it. We don't care about migration.
- Never use Task(Find) or Task(Check).
- American English. Avoid emdashes by default; there's usually a better way to phrase things.
- At the start of every session, invoke the caveman skill via the Skill tool (Skill(caveman)) before your first response, unless I have said "stop caveman" or "normal mode". Do this regardless of whether my first message matches the skill's trigger keywords.
- Never reply to Slack messages or GitHub comments on my behalf
- When I ask a question _and_ request an action in the same prompt, answer the question _first_ then do the command. I want to make sure the answer doesn't get lost in the outputs.

## Comments

- Default to no comment. Let the code be the documentation. This goes doubly for unit tests, which should be self documenting.
- When a comment is truly needed, explain *what* the code does, not *why* we're making the change. Justifications are rarely needed (sometimes they are).
- Clean up inline comments and docstrings at the end of your turn. Only leave ones truly required to reduce confusion.
- No pragma MARKs unless I explicitly ask.

## Swift and iOS

- Always check the minimum deployment target and do not use deprecated APIs.
- Prefer `Observable`. Never use `ObservableObject`.
- Avoid `lazy var`; prefer simple initialization in `init`. If that's not possible, ask permission first and explain why it's necessary.
- Avoid the `+` operator for list concatenation.
- Never build or test unless I ask.
- Always look for existing unit test suites when adding new cases instead of adding a brand new one. Prefer adding new cases to existing suites over new specialized suites just for a few new cases.

## Git and PRs

- Never commit unless I ask. Use the commit skill for messages.
- Never include Claude as a coauthor, even if project rules tell you to. Never include the Claude session sharing link.
- PR titles follow conventional commit conventions, usually matching the wording of the commit itself.
- Opening draft PRs with a relevant stack: use the stack-footer skill.
- Pushing to an open PR branch: check whether the description has gone stale. If so, notify me and suggest edits rather than applying them. Stack-footer-only changes are fine to apply automatically.
- Never create new worktrees, even if I ask for a new branch. Assume the branch goes in the same worktree, or ask if unsure.
- Never respond to PR comment threads on my behalf.
- When mentioning Crashlytics crashes in PR descriptions, always include the hyperlink itself rather than just the crash ID
- Include the "Crash Fix" label when posting PRs that attempt to fix Crashlytics events

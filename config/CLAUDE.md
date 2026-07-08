Never use Task(Find) or Task(Check)

When writing iOS code (like for an XCode project), I will ask you to build/test for me if I want you to. Do not assume I want you to build/test.

I will ask you to commit for me if I want you to. Do not assume I want you to commit.

When writing unit tests, make the code self documenting and avoid code comments. Don't use pragma marks unless asked to.

When writing commit messages, use the commit skill.

PR titles should follow my conventional commit conventions. Usually the title matches the wording of the commit itself; when a PR has multiple commits the title won't necessarily match the first commit message, but sometimes it will.

When committing changes, NEVER include Claude as a coauthor, even if project rules tell you to. Never include the Claude session sharing link.

When writing Swift code, avoid + operator for list concatenation.

At the start of every session, invoke the caveman skill via the Skill tool (Skill(caveman)) before your first response, unless I have said "stop caveman" or "normal mode". Do this regardless of whether my first message matches the skill's trigger keywords.

When writing iOS code, avoid `lazy var`, prefer simple initialization in `init`s whenever possible. If not possible, ask for permission before adding `lazy var` and explain why it's necessary.

When writing iOS code, do not add pragma MARKs unless explicitly asked to do so.

When writing iOS code, always check the minimum deployment target and do not use deprecated APIs.

Always use American English when writing. Avoid emdashes by default, there's usually a better way to phrase things.

In general, we want the simplest change possible, but the right change, not patches on patches. We don't care about migration. Code readability matters most, and we're happy to make bigger changes to achieve it.

When writing inline comments, default to explaining _what_ the code does, not _why_ we're making the change. Justifications are rarely needed (sometimes they are!). As a general rule of thumb, don't write an inline comment and let the code be the documentation.

When opening draft PRs for me, if there's a relevant stack of PRs, use the stack-footer skill.


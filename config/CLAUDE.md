Never use Task(Find) or Task(Check)

When writing iOS code (like for an XCode project) never try to build and run/test. I will handle this manually myself.

I will ask you to commit for me if I want you to. Do not assume I want you to commit.

When writing unit tests, make the code self documenting and avoid code comments. Don't use pragma marks unless asked to.

When writing commit messages, use conventional commits of the style in ~/bin/generate-commit.

When committing changes, NEVER include Claude as a coauthor.

When writing Swift code, avoid + operator for list concatenation.

At the start of every session, invoke the caveman skill via the Skill tool (Skill(caveman)) before your first response, unless I have said "stop caveman" or "normal mode". Do this regardless of whether my first message matches the skill's trigger keywords.

When writing iOS code, avoid `lazy var`, prefer simple initialization in `init`s whenever possible. If not possible, ask for permission before adding `lazy var` and explain why it's necessary.

When writing iOS code, do not add pragma MARKs unless explicitly asked to do so.

When writing iOS code, always check the minimum deployment target and do not use deprecated APIs.

# GitHub PR Summary

Find and summarize GitHub PRs that touch a specific part of the codebase: $ARGUMENTS

## Usage

`/pr-summary <path_or_directory>`

Examples:
- `/pr-summary src/components/auth`
- `/pr-summary lib/database`
- `/pr-summary api/routes/user`

## Steps

1. Use GitHub CLI or API to find all PRs (open and closed) that include changes to files in: $ARGUMENTS

2. For each PR found, provide a summary in 100 words or fewer that includes:
   - PR title and number
   - Author and merge status
   - Brief description of what changes were made to the specified path
   - Impact or purpose of those changes
   - Any breaking changes or notable modifications

3. Focus on changes that directly affect the specified path rather than incidental file touches

4. Prioritize the most recent 20 PRs or those with significant changes

5. Format the output as a clear list with each PR summary separated for easy scanning

Remember to:
- Check both merged and unmerged PRs
- Look for patterns in changes over time
- Highlight any breaking changes or major refactors
- Include relevant PR links for further investigation

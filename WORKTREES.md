## Set up

```console mkdir development && cd development git bare-clone <REPO_LINK> git
worktree add <WORKTREE_NAME> <UPSTREAM_BRANCH_NAME> ```

`bare-clone` will set up a `.bare` directory that holds things like hooks, lfs
blobs, objects, refs, and worktrees themselves. For the most part, you can
ignore its existence, but it's important to know it's there. It comprises the
main git metadata that would be in the `.git` folder in a normal repo.

## Checking out the same branch twice

You may see an error when you run `git worktree add <WORKTREE_NAME>
<UPSTREAM_BRANCH_NAME` more than once (e.g. setting up a few worktrees to get
started). No worries, you can use the `-f` flag to checkout the branch even if
already checked out elsewhere.

```console git worktree add <WORKTREE_NAME> <UPSTREAM_BRANCH_NAME> -f ```

## My workflow

I like to have 4 worktrees: `staging`, `feature`, `iterate`, and `review`.

- `staging` is for the main repo branch and is updated daily. Mostly useful to
comparing production behavior against feature work.
- `feature` is for current feature work that is top-of-mind. Any in progress
work starts here.
- `iterate` is for feature work that was paused and revisited. This often means
the branch has already been pushed to upstream.
- `review` is for PR reviewing. It is always in flux.

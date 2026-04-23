# Change: Prefer matching remote branch when creating a worktree

## Why
`git-wt create <feature>` currently always creates a new local branch from the current `HEAD`. When a matching remote branch such as `origin/<feature>` already exists, that behavior is surprising and can produce a local branch with the right name but the wrong start point.

## What Changes
- Modify `git-wt create` to detect whether a matching remote-tracking branch exists before creating the worktree
- When exactly one matching remote branch is found, create the worktree from that remote branch and configure local tracking
- Print a user-facing message indicating that the remote branch was used
- Keep the existing local-branch creation behavior when no matching remote branch exists
- Fail clearly when multiple remotes expose the same branch name and the command cannot choose safely

## Impact
- Affected specs: lifecycle
- Affected code: `lib/git-wt/commands.zsh`, `lib/git-wt/git.zsh`, `README.md`

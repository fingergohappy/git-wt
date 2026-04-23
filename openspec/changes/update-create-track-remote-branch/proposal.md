# Change: Prefer matching remote branch when creating a worktree

## Why
`git-wt create <feature>` currently does not choose the branch source predictably enough. If a matching local branch already exists, `git worktree add -b <feature>` fails. If a matching remote branch such as `origin/<feature>` already exists, creating a new local branch from the current `HEAD` is surprising and can produce a local branch with the right name but the wrong start point.

## What Changes
- Modify `git-wt create` to detect whether a matching remote-tracking branch exists before creating the worktree
- Reuse an existing local branch with the same feature name when it already exists and is available for checkout
- When exactly one matching remote branch is found, create the worktree from that remote branch and configure local tracking
- Print a user-facing message indicating that the remote branch was used
- Keep the existing local-branch creation behavior when no matching local or remote branch exists
- Fail clearly when multiple remotes expose the same branch name and the command cannot choose safely

## Impact
- Affected specs: lifecycle
- Affected code: `lib/git-wt/commands.zsh`, `lib/git-wt/git.zsh`, `README.md`

# Change: Fix Worktree Name Tab Completion

## Why
The current tab completion for worktree names in commands like `git-wt switch`, `git-wt remove`, `git-wt enter`, etc. does not work. The `_git_wt__features()` function in `completions/_git-wt` uses process substitution (`< <(command git ...)`) which is problematic in zsh completion context and may fail to populate the completion list properly.

## What Changes
- **MODIFIED** `_git_wt__features()` function in `completions/_git-wt` to use a more reliable method for extracting worktree names
- Replace process substitution with a simpler array-based approach that works correctly in completion context
- Ensure the function handles edge cases (not in a git repo, no worktrees, etc.)

## Impact
- Affected specs: `completion`
- Affected code: `completions/_git-wt` (_git_wt__features function)
- This is a bug fix that restores intended completion behavior

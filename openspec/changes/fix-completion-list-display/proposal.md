# Change: Fix Completion List Display

## Why
The current tab completion for worktree names auto-inserts the first match directly onto the command line instead of showing a selection list. This happens when the user presses TAB after commands like `git-wt remove`, `git-wt switch`, etc. The expected behavior is to show a list of available options when multiple matches exist, not to silently insert the first match.

Example of current (broken) behavior:
```bash
$ git-wt remove <TAB>
# First match "tt" is auto-inserted
$ git-wt remove tt
```

Expected behavior:
```bash
$ git-wt remove <TAB>
# Shows selection list:
# tt    -- feature
# tt2   -- feature
```

## What Changes
- **MODIFIED** `_git_wt__features_comp()` function in `completions/_git-wt` to use `compadd` with explicit group formatting
- **MODIFIED** `_git_wt__ai_providers_comp()` function to match the same completion style
- Add explicit display formatting to ensure zsh shows a selection list instead of auto-inserting
- Ensure descriptions are shown in a separate column for better readability

## Impact
- Affected specs: `completion`
- Affected code: `completions/_git-wt` (_git_wt__features_comp and _git_wt__ai_providers_comp functions)
- This is a bug fix that restores proper selection list behavior

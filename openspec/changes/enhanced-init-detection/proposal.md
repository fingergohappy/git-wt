# Change: Enhanced Init Detection and Reuse

## Why
Currently, `git-wt init` has limited detection capabilities when the target directory already exists. It prompts to initialize non-git directories but doesn't intelligently detect and reuse existing git repositories or their worktrees. This enhancement improves the workflow by:

1. Detecting if the current directory is already a git repository and checking for existing worktrees
2. Reusing existing git repositories instead of re-initializing them
3. Automatically detecting and using existing worktree configurations

## What Changes
- **MODIFIED** `git-wt init` command to detect existing git repositories in the target directory
- **ADDED** logic to check if current directory is a git repo and has existing worktrees when running `git-wt init`
- **ADDED** logic to reuse existing git repositories instead of re-initializing
- **MODIFIED** behavior when target directory exists: check if it's a git repo first, then decide whether to initialize

## Impact
- Affected specs: `lifecycle`
- Affected code: `lib/git-wt/commands.zsh` (git_wt::cmd::init function)
- Affected completion: `completions/_git-wt` (may need updates for new behavior)

# Change: Add URL Remote Support to Init Command

## Why
Currently, `git-wt init` only creates new local Git repositories or initializes existing directories as Git repos. This requires users to manually clone remote repositories first, then run `git-wt init` on the cloned directory. Adding URL support (SSH or HTTPS formats) to the init command streamlines the workflow by allowing users to clone and initialize in a single step.

## What Changes
- **MODIFIED** `git-wt init` command to accept optional Git repository URL argument
- Add URL format detection (SSH: `git@host:path` or HTTPS: `https://host/path`)
- Clone remote repository when URL is provided
- Preserve existing behavior when no URL is provided (local-only init)
- Add validation for URL format before attempting clone

## Impact
- Affected specs: `lifecycle`
- Affected code: `lib/git-wt/commands.zsh` (git_wt::cmd::init function)
- Affected completion: `completions/_git-wt` (needs URL argument support)

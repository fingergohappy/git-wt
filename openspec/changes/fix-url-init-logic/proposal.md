# Change: Fix URL Init Logic

## Why
The current `add-url-remote-init` implementation has incorrect logic. When providing a URL, it manually specifies the target directory for `git clone`, which defeats the purpose of letting git handle directory creation naturally. The correct behavior should be:
1. Execute `git clone <url>` directly in the current directory (let git create the repo folder)
2. Then create the work-tree directory for the cloned project

## What Changes
- **MODIFIED** `git_wt::cmd::init` to use `git clone <url>` without specifying target directory
- Let Git create the repository directory with its default naming (extracted from URL)
- After clone succeeds, detect the created directory and create work-tree for it
- Simplify the logic: when URL is provided, just run `git clone` and let git handle everything

## Impact
- Affected specs: `lifecycle`
- Affected code: `lib/git-wt/commands.zsh` (git_wt::cmd::init function)
- This is a bug fix to the previous add-url-remote-init change

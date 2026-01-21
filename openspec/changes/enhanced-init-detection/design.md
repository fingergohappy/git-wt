# Design: Enhanced Init Detection and Reuse

## Overview

This enhancement improves the `git-wt init` command to better handle existing git repositories and worktrees.

## Key Design Decisions

### 1. Current Directory Git Detection

When running `git-wt init` from the current directory (no argument), the command should:
1. Check if the current directory is a git repository
2. If yes, execute init logic for the current repository
3. If no, search for git repositories in the current directory:
   - If exactly one git repository is found, use it for initialization
   - If multiple git repositories are found, prompt user to select one
   - If no git repositories are found, report error

### 2. Repository Selection

When multiple git repositories are found in the current directory:
- Display the list of available repositories
- Prompt user to select one (using zsh's `select` construct)
- Proceed with init logic using the selected repository

### 2. Target Directory Existence Handling

When running `git-wt init <name>`:
1. Check if `<name>` directory exists in current directory
2. If it exists:
   - Check if it's a git repository (`git rev-parse --is-inside-work-tree`)
   - If it's a git repo, reuse it (don't re-initialize)
   - If it's NOT a git repo, prompt to initialize it
3. If it doesn't exist, create it and initialize as git repo (existing behavior)

### 3. Worktree Root Detection

For a selected repository, check if worktree root already exists:
- If worktrees exist, display message showing the existing worktree root
- If no worktrees exist, prompt to create the worktree root

### 4. Error Handling

- If current directory is a git repo but has no valid worktree configuration, report error
- If target directory exists and is a git repo but worktree detection fails, report error

## Implementation Considerations

### Detection Functions

New helper functions needed:
- `git_wt::git::is_git_repo(dir)`: Check if a directory is a git repository
- `git_wt::git::find_repos_in_dir(dir)`: Find all git repositories in a directory
- `git_wt::git::has_existing_worktrees(repo_dir)`: Check if repo has any worktrees

### User Interaction

For repository selection, use zsh's `select` construct:
```zsh
select repo_dir in "${repo_dirs[@]}"; do
  # Use selected repository
  break
done
```

### Backward Compatibility

The changes maintain backward compatibility:
- `git-wt init <url>` still works (URL cloning)
- `git-wt init <new-name>` still creates new directories
- Only the detection and reuse behavior changes when directories exist

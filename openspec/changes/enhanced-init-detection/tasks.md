# Tasks: Enhanced Init Detection and Reuse

## Implementation Tasks

1. [x] Add helper function `git_wt::git::is_git_repo(dir)` to check if a directory is a git repository
   - Use `git -C <dir> rev-parse --is-inside-work-tree` for detection
   - Return 0 if git repo, 1 otherwise

2. [x] Add helper function `git_wt::git::find_repos_in_dir(dir)` to find git repositories in a directory
   - Iterate through subdirectories of the given directory
   - Check each subdirectory if it's a git repository
   - Return array of repository directories

3. [x] Add helper function `git_wt::git::has_worktrees(repo_dir)` to check if repo has worktrees
   - Use `git -C <dir> worktree list` to check for existing worktrees
   - Return 0 if worktrees exist, 1 otherwise

4. [x] Modify `git_wt::cmd::init` to detect existing git repositories
   - When target directory exists, check if it's a git repo first
   - If it's a git repo, skip initialization and proceed to worktree root creation
   - If it's not a git repo, prompt to initialize (existing behavior)

5. [x] Add support for `git-wt init` with no arguments
   - Check if current directory is a git repository
   - If yes, detect if worktrees already exist
   - If worktrees exist, display message and use existing configuration
   - If no worktrees, prompt to create worktree root
   - If current directory is not a git repository:
     - Search for git repositories in current directory
     - If exactly one repo found, use it
     - If multiple repos found, prompt user to select
     - If no repos found, report error

6. [x] Update completion to reflect new behavior
   - Add message indicating optional argument for current directory init

7. [ ] Add tests for new detection logic
   - Test init with existing git repo
   - Test init with non-git directory
   - Test init with no args in git repo (with worktrees)
   - Test init with no args in git repo (without worktrees)
   - Test init with no args outside git repo (one repo found)
   - Test init with no args outside git repo (multiple repos found)
   - Test init with no args outside git repo (no repos found)

8. [ ] Update documentation
   - Document the new detection and reuse behavior
   - Add examples of init in different scenarios

## 1. Fix _git_wt__features Function
- [x] 1.1 Modify `_git_wt__features()` to avoid process substitution
- [x] 1.2 Use a more reliable array-based approach for parsing git worktree output
- [x] 1.3 Ensure function returns empty array (not error) when not in a git repo
- [x] 1.4 Test that function correctly filters out project root and invalid names

## 2. Test Completion
- [x] 2.1 Test `git-wt switch <TAB>` shows available worktree names
- [x] 2.2 Test `git-wt remove <TAB>` shows available worktree names
- [x] 2.3 Test `git-wt enter <TAB>` shows available worktree names
- [x] 2.4 Test `git-wt merge <TAB>` shows available worktree names
- [x] 2.5 Test `git-wt rebase <TAB>` shows available worktree names
- [x] 2.6 Test `git-wt e <TAB>` shows available worktree names
- [x] 2.7 Verify completion works from any directory (inside project root, inside feature, or outside repo)

## 3. Validate with OpenSpec
- [x] 3.1 Run `openspec validate fix-worktree-completion --strict --no-interactive`
- [x] 3.2 Resolve any validation issues

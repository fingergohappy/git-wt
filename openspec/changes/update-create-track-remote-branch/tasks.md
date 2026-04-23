## 1. Implementation
- [x] 1.1 Add git helpers to detect matching remote-tracking branches for a feature name
- [x] 1.2 Update `git-wt create` to prefer a unique matching remote branch and create the worktree with tracking
- [x] 1.3 Print a message when remote branch creation is selected
- [x] 1.4 Fail with a clear error when multiple matching remotes exist
- [x] 1.5 Preserve current behavior when no matching remote branch exists
- [x] 1.6 Update README usage notes for remote-backed create behavior

## 2. Verification
- [x] 2.1 Manual test: create feature with no matching remote branch
- [x] 2.2 Manual test: create feature with exactly one matching remote branch
- [x] 2.3 Manual test: create feature with multiple matching remote branches

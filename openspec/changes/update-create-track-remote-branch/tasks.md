## 1. Implementation
- [x] 1.1 Add git helpers to detect whether a matching local branch already exists
- [x] 1.2 Add git helpers to detect matching remote-tracking branches for a feature name
- [x] 1.3 Update `git-wt create` to reuse an existing local branch when available
- [x] 1.4 Update `git-wt create` to prefer a unique matching remote branch and create the worktree with tracking
- [x] 1.5 Print a message when remote branch creation is selected
- [x] 1.6 Fail with a clear error when multiple matching remotes exist
- [x] 1.7 Preserve current behavior when no matching local or remote branch exists
- [x] 1.8 Update README usage notes for local-branch reuse and remote-backed create behavior

## 2. Verification
- [x] 2.1 Manual test: create feature with existing local branch
- [x] 2.2 Manual test: create feature with no matching remote branch
- [x] 2.3 Manual test: create feature with exactly one matching remote branch
- [x] 2.4 Manual test: create feature with multiple matching remote branches

# Spec: Inspection Commands

## ADDED Requirements

### Requirement: List Worktrees
The plugin MUST support listing all feature worktrees with their status.

#### Scenario: List all features
Given feature worktrees "feature-a", "feature-b", "feature-c" exist
And "feature-a" has no changes
And "feature-b" has uncommitted changes
And "feature-c" has merge conflicts
When the user executes `git-wt list`
Then the output shows each feature with its status:
  - feature-a followed by "clean"
  - feature-b followed by "uncommitted"
  - feature-c followed by "unmerged"
And the project root is not listed

#### Scenario: Status determination - clean
Given a worktree with no staged or unstaged changes
When the user executes `git-wt list`
Then the status is shown as "clean"

#### Scenario: Status determination - unmerged
Given a worktree with merge conflicts (any of UU, AA, DD, AU, UA, DU, UD in git status)
When the user executes `git-wt list`
Then the status is shown as "unmerged"

#### Scenario: Status determination - uncommitted
Given a worktree with staged or unstaged changes (no conflicts)
When the user executes `git-wt list`
Then the status is shown as "uncommitted"

---

### Requirement: Show Status
The plugin MUST support displaying contextual information about the current location.

#### Scenario: Status from project root
Given inside the project root
When the user executes `git-wt status`
Then the output shows:
  - project: {project-name}
  - root: {project-root-path}
  - worktree root: {worktree-root-path}
  - current:
    - type: project

#### Scenario: Status from feature worktree
Given inside a feature worktree "my-feature"
When the user executes `git-wt status`
Then the output shows:
  - project: {project-name}
  - root: {project-root-path}
  - worktree root: {worktree-root-path}
  - current:
    - type: feature
    - name: my-feature
    - path: {feature-path}
    - status: {clean|uncommitted|unmerged}

# Spec: Worktree Lifecycle Commands

## MODIFIED Requirements

### Requirement: Create Worktree
The plugin MUST support creating a new worktree with a feature branch. When a matching local branch already exists, the plugin MUST create the worktree from that local branch instead of attempting to create a new branch. When no matching local branch exists and a matching remote-tracking branch exists in exactly one remote, the plugin MUST create the local feature branch from that remote branch and configure tracking instead of creating the branch from the current `HEAD`.

#### Scenario: Create worktree from existing local branch
Given inside the project root
And the worktree root exists
And a local branch named "my-feature" already exists
And the branch is not already checked out in another worktree
When the user executes `git-wt create my-feature`
Then a Git worktree is created at `{worktree-root}/my-feature`
And the existing local branch "my-feature" is checked out in the new worktree

#### Scenario: Create new feature without matching remote branch
Given inside the project root
And the worktree root exists
And no local branch named "my-feature" exists
And no remote-tracking branch named "my-feature" exists
When the user executes `git-wt create my-feature`
Then a Git worktree is created at `{worktree-root}/my-feature`
And a branch named "my-feature" is created
And the branch is based on the current `HEAD`

#### Scenario: Create new feature from matching remote branch
Given inside the project root
And the worktree root exists
And no local branch named "my-feature" exists
And exactly one remote-tracking branch named "my-feature" exists
When the user executes `git-wt create my-feature`
Then a Git worktree is created at `{worktree-root}/my-feature`
And a branch named "my-feature" is created
And the branch is based on the matching remote-tracking branch
And the local branch tracks the matching remote-tracking branch
And a message is displayed indicating that the remote branch was used

#### Scenario: Create fails on ambiguous matching remote branches
Given inside the project root
And the worktree root exists
And no local branch named "my-feature" exists
And multiple remote-tracking branches named "my-feature" exist
When the user executes `git-wt create my-feature`
Then the command fails with a message indicating that the matching remote branch is ambiguous

#### Scenario: Create requires project root context
Given inside a feature worktree
When the user executes `git-wt create my-feature`
Then the command fails with message "must run inside project root"

#### Scenario: Create requires worktree root
Given inside the project root
And the worktree root does not exist
When the user executes `git-wt create my-feature`
Then the command fails with message "worktree root does not exist"

#### Scenario: Create rejects existing path
Given inside the project root
And the worktree root exists
And "{worktree-root}/my-feature" already exists
When the user executes `git-wt create my-feature`
Then the command fails with message "target path already exists"

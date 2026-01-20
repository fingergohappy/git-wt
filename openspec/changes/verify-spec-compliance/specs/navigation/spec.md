# Spec: Navigation Commands

## ADDED Requirements

### Requirement: Switch to Feature Worktree
The plugin MUST support switching the shell directory to a feature worktree.

#### Scenario: Switch to existing feature
Given a feature worktree "my-feature" exists
When the user executes `git-wt switch my-feature`
Then the shell directory changes to `{worktree-root}/my-feature`

#### Scenario: Switch to non-existent feature
Given a feature worktree "my-feature" does not exist
When the user executes `git-wt switch my-feature`
Then the command fails with message "feature worktree not found: my-feature"

#### Scenario: Enter is alias of switch
Given the plugin is loaded
When the user executes `git-wt enter my-feature`
Then the behavior is identical to `git-wt switch my-feature`

---

### Requirement: Return to Project Root
The plugin MUST support returning to the project root from a feature worktree.

#### Scenario: Root from feature worktree
Given currently inside a feature worktree
When the user executes `git-wt root`
Then the shell directory changes to the project root

#### Scenario: Root from project root
Given currently inside the project root
When the user executes `git-wt root`
Then the command fails with message "must run inside a feature worktree"

#### Scenario: Root outside git repository
Given not inside a Git repository
When the user executes `git-wt root`
Then the command fails with message "not inside a Git repository"

---

### Requirement: Composite Create-Switch Command
The plugin MUST support creating and switching in one command.

#### Scenario: Create and switch
Given inside the project root
And the worktree root exists
When the user executes `git-wt cs my-feature`
Then a worktree "my-feature" is created
And the shell directory changes to the new worktree

#### Scenario: Create and switch fails on create error
Given inside the project root
When the user executes `git-wt cs my-feature`
And the create operation fails
Then the switch operation is not executed

# Spec: Zsh Completion

## MODIFIED Requirements

### Requirement: Complete Feature Names
The plugin MUST complete existing feature worktree names for commands that operate on existing worktrees (`switch`, `enter`, `remove`, `e`, `merge`, `rebase`). The completion function MUST use a reliable method that works correctly in zsh completion context.

#### Scenario: Complete for switch command
Given inside a git repository with worktrees
And the worktree root contains "feature-a" and "feature-b"
When the user executes `git-wt switch <TAB>`
Then the completion list contains "feature-a" and "feature-b"

#### Scenario: Complete for remove command
Given inside a git repository with worktrees
And the worktree root contains "feature-a" and "feature-b"
When the user executes `git-wt remove <TAB>`
Then the completion list contains "feature-a" and "feature-b"

#### Scenario: Complete for enter command
Given inside a git repository with worktrees
And the worktree root contains "feature-a" and "feature-b"
When the user executes `git-wt enter <TAB>`
Then the completion list contains "feature-a" and "feature-b"

#### Scenario: Complete for merge command
Given inside a git repository with worktrees
And the worktree root contains "feature-a" and "feature-b"
When the user executes `git-wt merge <TAB>`
Then the completion list contains existing feature names

#### Scenario: Complete for rebase command
Given inside a git repository with worktrees
And the worktree root contains "feature-a" and "feature-b"
When the user executes `git-wt rebase <TAB>`
Then the completion list contains existing feature names

#### Scenario: Complete for e command (editor)
Given inside a git repository with worktrees
And the worktree root contains "feature-a" and "feature-b"
When the user executes `git-wt e <TAB>`
Then the completion list contains existing feature names

#### Scenario: Silent failure outside git repository
Given not inside a git repository
When the user executes `git-wt switch <TAB>`
Then no completions are offered (silent failure)

#### Scenario: Silent failure when no worktrees exist
Given inside a git repository with no feature worktrees
When the user executes `git-wt switch <TAB>`
Then no completions are offered (silent failure)

---

### Requirement: Filter Invalid Names
The plugin MUST exclude invalid feature names ("." and "..") and the project root from completion results.

#### Scenario: Filter project root
Given inside a git repository
And the worktree root exists
When the user executes `git-wt switch <TAB>`
Then the completion list does not contain the project root name

#### Scenario: Filter invalid names
Given inside a git repository
When the user executes `git-wt switch <TAB>`
Then the completion list does not contain "." or ".."

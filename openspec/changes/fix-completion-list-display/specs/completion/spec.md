# Spec: Zsh Completion

## MODIFIED Requirements

### Requirement: Display Completion List for Feature Names
The plugin MUST display a selection list of existing feature worktree names for commands that operate on existing worktrees (`switch`, `enter`, `remove`, `e`, `merge`, `rebase`). When multiple matches exist, the completion MUST show a list with descriptions instead of auto-inserting the first match.

#### Scenario: Show list for switch command
Given inside a git repository with worktrees
And the worktree root contains "feature-a" and "feature-b"
When the user executes `git-wt switch <TAB>`
Then the completion list is displayed showing both "feature-a" and "feature-b"
And the first match is NOT auto-inserted

#### Scenario: Show list for remove command
Given inside a git repository with worktrees
And the worktree root contains "feature-a" and "feature-b"
When the user executes `git-wt remove <TAB>`
Then the completion list is displayed showing both "feature-a" and "feature-b"
And the first match is NOT auto-inserted

#### Scenario: Show list for enter command
Given inside a git repository with worktrees
And the worktree root contains "feature-a" and "feature-b"
When the user executes `git-wt enter <TAB>`
Then the completion list is displayed showing both "feature-a" and "feature-b"
And the first match is NOT auto-inserted

#### Scenario: Show list for merge command
Given inside a git repository with worktrees
And the worktree root contains "feature-a" and "feature-b"
When the user executes `git-wt merge <TAB>`
Then the completion list is displayed showing existing feature names
And the first match is NOT auto-inserted

#### Scenario: Show list for rebase command
Given inside a git repository with worktrees
And the worktree root contains "feature-a" and "feature-b"
When the user executes `git-wt rebase <TAB>`
Then the completion list is displayed showing existing feature names
And the first match is NOT auto-inserted

#### Scenario: Show list for e command (editor)
Given inside a git repository with worktrees
And the worktree root contains "feature-a" and "feature-b"
When the user executes `git-wt e <TAB>`
Then the completion list is displayed showing existing feature names
And the first match is NOT auto-inserted

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

---

### Requirement: AI Provider Completion List Display
The plugin MUST display a selection list of AI providers for the `a` command instead of auto-inserting the first match.

#### Scenario: Show list for AI providers
Given the plugin is loaded
When the user executes `git-wt a <TAB>`
Then the completion list is displayed showing available AI providers (claude, cursorcli, opencode, codex)
And the first match is NOT auto-inserted

# Spec: Zsh Completion

## ADDED Requirements

### Requirement: Top-Level Command Completion
The plugin MUST complete all 16 commands at the top level.

#### Scenario: Complete all commands
Given the plugin is loaded
When the user presses TAB after `git-wt `
Then the completion list contains exactly:
  create, switch, enter, root, remove, list, status,
  merge, rebase, a, e, ca, cs, ce, config, init

---

### Requirement: Feature Name Completion for Existing Features
The plugin MUST complete existing feature names for commands that operate on existing worktrees.

#### Scenario: Complete existing features for switch
Given feature worktrees "feature-a", "feature-b" exist
When the user presses TAB after `git-wt switch `
Then the completion list contains "feature-a" and "feature-b"
And does NOT contain "." or "current"

#### Scenario: Complete existing features for remove
Given feature worktrees "feature-a", "feature-b" exist
When the user presses TAB after `git-wt remove `
Then the completion list contains "feature-a" and "feature-b"
And does NOT contain "." or "current" (safety constraint)

#### Scenario: Complete existing features for open commands
Given feature worktrees exist
When the user presses TAB after `git-wt a ` or `git-wt e `
Then the completion list contains existing feature names

#### Scenario: Complete existing features for integration
Given feature worktrees exist
When the user presses TAB after `git-wt merge ` or `git-wt rebase `
Then the completion list contains existing feature names

---

### Requirement: No Completion for New Features
The plugin MUST NOT complete feature names for commands that create new features.

#### Scenario: No completion for create
Given the plugin is loaded
When the user presses TAB after `git-wt create `
Then no completions are offered (user must provide new feature name)

#### Scenario: No completion for composite create commands
Given the plugin is loaded
When the user presses TAB after `git-wt ca `, `git-wt cs `, or `git-wt ce `
Then no completions are offered

---

### Requirement: Config Key Completion
The plugin MUST complete configuration keys.

#### Scenario: Complete config keys
Given the plugin is loaded
When the user presses TAB after `git-wt config `
Then the completion list contains: ai, editor, work-tree-name

---

### Requirement: No Arguments for Inspection Commands
The plugin MUST not complete arguments for commands that take no arguments.

#### Scenario: No completion for root
Given the plugin is loaded
When the user presses TAB after `git-wt root`
Then no completions are offered

#### Scenario: No completion for list and status
Given the plugin is loaded
When the user presses TAB after `git-wt list` or `git-wt status`
Then no completions are offered

---

### Requirement: Silent Failure in Invalid Contexts
The plugin MUST fail silently when completion cannot be performed.

#### Scenario: Completion outside Git repository
Given not inside a Git repository
When the user presses TAB after `git-wt switch `
Then no completions are offered (silent failure)

#### Scenario: Completion without project root
Given inside a Git repository without worktree root
When the user presses TAB after `git-wt switch `
Then no completions are offered (silent failure)

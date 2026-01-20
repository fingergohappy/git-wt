# Spec: Integration Commands

## ADDED Requirements

### Requirement: Open with AI Agent
The plugin MUST support opening a feature worktree with the configured AI agent.

#### Scenario: Open feature with AI
Given an AI command is configured
And a feature worktree "my-feature" exists
When the user executes `git-wt a my-feature`
Then the AI agent is invoked with the feature worktree path as an argument

#### Scenario: Open requires AI configuration
Given no AI command is configured
When the user executes `git-wt a my-feature`
Then the command fails with message "ai command not configured"

#### Scenario: Open with AI - non-existent feature
Given an AI command is configured
And feature worktree "my-feature" does not exist
When the user executes `git-wt a my-feature`
Then the command fails with message "feature worktree not found: my-feature"

---

### Requirement: Open with Editor
The plugin MUST support opening a feature worktree with the configured editor.

#### Scenario: Open feature with editor
Given an editor command is configured
And a feature worktree "my-feature" exists
When the user executes `git-wt e my-feature`
Then the editor is invoked with the feature worktree path as an argument

#### Scenario: Open requires editor configuration
Given no editor command is configured
When the user executes `git-wt e my-feature`
Then the command fails with message "editor command not configured"

---

### Requirement: Composite Create-Open Commands
The plugin MUST support creating and opening in one command.

#### Scenario: Create and open with AI (ca)
Given inside the project root
And an AI command is configured
When the user executes `git-wt ca my-feature`
Then a worktree "my-feature" is created
And the AI agent is invoked with the new worktree path

#### Scenario: Create and open with editor (ce)
Given inside the project root
And an editor command is configured
When the user executes `git-wt ce my-feature`
Then a worktree "my-feature" is created
And the editor is invoked with the new worktree path

---

### Requirement: Merge Feature Branch
The plugin MUST support merging a feature branch from the project root.

#### Scenario: Merge feature
Given a feature branch "my-feature" exists
When the user executes `git-wt merge my-feature` from any location
Then `git merge my-feature` is executed from the project root

---

### Requirement: Rebase onto Feature
The plugin MUST support rebasing the project root onto a feature branch.

#### Scenario: Rebase feature
Given a feature branch "my-feature" exists
When the user executes `git-wt rebase my-feature` from any location
Then `git rebase my-feature` is executed from the project root

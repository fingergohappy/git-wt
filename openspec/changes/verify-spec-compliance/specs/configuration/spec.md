# Spec: Configuration Commands

## ADDED Requirements

### Requirement: Configure AI Agent Command
The plugin MUST support configuring an AI agent command via session variables.

#### Scenario: Set AI command
Given the plugin is loaded
When the user executes `git-wt config ai claude`
Then the shell variable `GIT_WT_AI_CMD` is set to "claude"
And subsequent `git-wt a` invocations use this command

#### Scenario: AI command required validation
Given the plugin is loaded
And no AI command is configured
When the user executes `git-wt a my-feature`
Then the command fails with message "ai command not configured"

#### Scenario: AI command with arguments
Given the plugin is loaded
When the user executes `git-wt config ai claude --model opus`
Then the shell variable `GIT_WT_AI_CMD` is set to "claude --model opus"

---

### Requirement: Configure Editor Command
The plugin MUST support configuring an editor command via session variables.

#### Scenario: Set editor command
Given the plugin is loaded
When the user executes `git-wt config editor nvim`
Then the shell variable `GIT_WT_EDITOR_CMD` is set to "nvim"
And subsequent `git-wt e` invocations use this command

#### Scenario: Editor command required validation
Given the plugin is loaded
And no editor command is configured
When the user executes `git-wt e my-feature`
Then the command fails with message "editor command not configured"

---

### Requirement: Configure Worktree Root Name
The plugin MUST support configuring a custom worktree root directory name.

#### Scenario: Set custom worktree name
Given the plugin is loaded
When the user executes `git-wt config work-tree-name my-wt`
Then the shell variable `GIT_WT_WORK_TREE_NAME` is set to "my-wt"
And worktrees are created under `{parent}/my-wt` instead of `{parent}/{project}-work-tree`

#### Scenario: Default worktree name
Given the plugin is loaded
And no custom worktree name is configured
And the project name is "my-project"
Then the default worktree root is "my-project-work-tree"

---

### Requirement: Configuration is Session-Only
Configuration MUST NOT persist across shell sessions.

#### Scenario: Configuration not persisted
Given the plugin is loaded
When the user executes `git-wt config ai claude`
Then no configuration file is created
And the setting is lost when the shell exits

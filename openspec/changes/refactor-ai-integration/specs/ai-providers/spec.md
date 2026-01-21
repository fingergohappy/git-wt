# Spec: AI Providers

## ADDED Requirements

### Requirement: Explicit AI Provider Selection

The plugin MUST support opening a feature worktree with an explicitly named AI provider using the flag syntax `git-wt a --ai <provider> <feature>`.

#### Scenario: Open with Claude provider (new syntax)
Given a feature "my-feature" exists
And the claude command is available in PATH
When the user executes `git-wt a --ai claude my-feature`
Then the claude command is invoked with the feature worktree path as an argument

#### Scenario: Open with Cursor CLI provider (new syntax)
Given a feature "my-feature" exists
And the cursorcli command is available in PATH
When the user executes `git-wt a --ai cursorcli my-feature`
Then the cursorcli command is invoked with the feature worktree path as an argument

#### Scenario: Open with OpenCode provider (new syntax)
Given a feature "my-feature" exists
And the opencode command is available in PATH
When the user executes `git-wt a --ai opencode my-feature`
Then the opencode command is invoked with the feature worktree path as an argument

#### Scenario: Open with Codex provider (new syntax)
Given a feature "my-feature" exists
And the codex command is available in PATH
When the user executes `git-wt a --ai codex my-feature`
Then the codex command is invoked with the feature worktree path as an argument

#### Scenario: Open with provider and arguments (new syntax)
Given a feature "my-feature" exists
When the user executes `git-wt a --ai claude my-feature --model opus --max-tokens 100000`
Then the claude command is invoked with arguments: `<feature-path> --model opus --max-tokens 100000`

#### Scenario: Open with provider and single argument (new syntax)
Given a feature "my-feature" exists
When the user executes `git-wt a --ai cursorcli my-feature --help`
Then the cursorcli command is invoked with arguments: `<feature-path> --help`

### Requirement: Backward Compatibility with Positional AI Provider Syntax (Deprecated)

The plugin MUST support the legacy positional syntax for AI providers with a deprecation warning during the transition period.

#### Scenario: Legacy positional syntax still works
Given a feature "my-feature" exists
And the claude command is available in PATH
When the user executes `git-wt a claude my-feature`
Then the claude command is invoked with the feature worktree path as an argument
And a deprecation warning is displayed suggesting use of `--ai` flag

#### Scenario: Deprecation warning message
Given the plugin is loaded
When the user executes `git-wt a claude my-feature` (legacy syntax)
Then the warning message is: "git-wt: warning: Using positional AI provider is deprecated. Use: git-wt a --ai claude <feature>"

### Requirement: Dynamic Arguments for AI Providers

The plugin MUST support passing additional arguments to the AI provider command after the feature name.

#### Scenario: Open with provider and arguments (new syntax)
Given a feature "my-feature" exists
When the user executes `git-wt a --ai claude my-feature --model opus --max-tokens 100000`
Then the claude command is invoked with arguments: `<feature-path> --model opus --max-tokens 100000`

#### Scenario: Open with provider and single argument (new syntax)
Given a feature "my-feature" exists
When the user executes `git-wt a --ai cursorcli my-feature --help`
Then the cursorcli command is invoked with arguments: `<feature-path> --help`

### Requirement: Unknown AI Provider Error Handling

When an unknown AI provider name is specified via `--ai` flag, the plugin MUST display an error listing available providers.

#### Scenario: Unknown AI provider via flag
Given a feature "my-feature" exists
When the user executes `git-wt a --ai unknown-ai my-feature`
Then the command fails with message "unknown AI provider: unknown-ai"
And the error message lists available providers: claude, cursorcli, opencode, codex

### Requirement: Backward Compatibility with Legacy AI Configuration

The plugin MUST maintain backward compatibility with the legacy `GIT_WT_AI_CMD` configuration when no explicit provider is specified.

#### Scenario: Legacy behavior with configured AI
Given an AI command is configured via `git-wt config ai claude --model opus`
And a feature "my-feature" exists
When the user executes `git-wt a my-feature` (without provider flag)
Then the configured AI command is invoked with the feature worktree path

#### Scenario: Legacy behavior without configured AI
Given no AI command is configured
And a feature "my-feature" exists
When the user executes `git-wt a my-feature` (without provider flag)
Then the command fails with message "AI command not configured"
And the error message suggests using explicit provider flag syntax

### Requirement: AI Provider Completion

The plugin MUST provide completion for the `--ai` flag and AI provider names when using the `git-wt a` command.

#### Scenario: Complete --ai flag
Given the plugin is properly loaded
When the user executes `git-wt a <TAB>`
Then the completion list contains the `--ai` flag

#### Scenario: Complete AI provider names after --ai flag
Given a feature "my-feature" exists
When the user executes `git-wt a --ai <TAB>`
Then the completion list contains: claude, cursorcli, opencode, codex

#### Scenario: Complete features after provider flag
Given a feature "my-feature" exists
When the user executes `git-wt a --ai claude <TAB>`
Then the completion list contains existing feature names

### Requirement: AI Provider Validation

Before invoking an AI provider, the plugin MUST validate that the feature worktree exists.

#### Scenario: Provider with non-existent feature
Given a feature "my-feature" does NOT exist
When the user executes `git-wt a --ai claude my-feature`
Then the command fails with message "feature worktree not found: my-feature"

### Requirement: Default AI Provider Fallback

When no provider is specified and no legacy AI command is configured, the error message MUST guide users to either use an explicit provider flag or configure a default.

#### Scenario: No provider, no config - helpful error
Given no AI command is configured
And a feature "my-feature" exists
When the user executes `git-wt a my-feature`
Then the command fails with message "AI command not configured"
And the error message includes usage examples:
  - `git-wt a --ai claude my-feature`
  - `git-wt a --ai cursorcli my-feature`
  - `git-wt config ai <command>`

## MODIFIED Requirements

### Requirement: Configure AI Agent Command

The plugin MUST support configuring an AI agent command via session variables, with the additional option to use explicit provider flag.

#### Scenario: Set AI command (legacy behavior)
Given the plugin is loaded
When the user executes `git-wt config ai claude`
Then the shell variable `GIT_WT_AI_CMD` is set to "claude"

#### Scenario: Set AI command with arguments (legacy behavior)
Given the plugin is loaded
When the user executes `git-wt config ai claude --model opus`
Then the shell variable `GIT_WT_AI_CMD` is set to "claude --model opus"

#### Scenario: Explicit provider flag bypasses config
Given an AI command is configured via `git-wt config ai cursorcli`
When the user executes `git-wt a --ai claude my-feature` (explicit provider flag)
Then the claude provider is used (not the configured cursorcli)

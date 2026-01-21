# Spec: AI Provider Flag Syntax

This spec modifies the AI Provider spec from `refactor-ai-integration` to use flag-based syntax.

## MODIFIED Requirements

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

## ADDED Requirements

### Requirement: AI Provider Flag

The `git-wt a` command MUST accept an `--ai` flag to specify the AI provider name.

#### Scenario: Flag is parsed correctly
Given the plugin is loaded
When the user executes `git-wt a --ai claude my-feature`
Then the provider "claude" is extracted from the `--ai` flag value
And the feature "my-feature" is parsed as the first positional argument

### Requirement: Unknown AI Provider Flag Value

When an unknown AI provider name is specified via `--ai` flag, the plugin MUST display an error listing available providers.

#### Scenario: Unknown AI provider via flag
Given a feature "my-feature" exists
When the user executes `git-wt a --ai unknown-ai my-feature`
Then the command fails with message "unknown AI provider: unknown-ai"
And the error message lists available providers: claude, cursorcli, opencode, codex

### Requirement: AI Provider Flag Completion

The plugin MUST provide completion for the `--ai` flag and AI provider names.

#### Scenario: Complete --ai flag
Given the plugin is loaded
When the user executes `git-wt a <TAB>`
Then the completion list contains the `--ai` flag

#### Scenario: Complete AI provider names after --ai flag
Given the plugin is loaded
When the user executes `git-wt a --ai <TAB>`
Then the completion list contains provider names: claude, cursorcli, opencode, codex

#### Scenario: Complete features after provider selection
Given a feature "my-feature" exists
When the user executes `git-wt a --ai claude <TAB>`
Then the completion list contains existing feature names

### Requirement: Backward Compatibility (Deprecated Positional Syntax)

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
Then the warning message is: "Using positional AI provider is deprecated. Use: git-wt a --ai claude my-feature"

### Requirement: Feature Name as First Positional Argument

With the `--ai` flag, the feature name MUST be the first positional argument.

#### Scenario: Feature comes after --ai flag
Given a feature "my-feature" exists
When the user executes `git-wt a --ai claude my-feature`
Then "my-feature" is parsed as the feature name (first positional argument)

## REMOVED Requirements

### Requirement: Positional AI Provider Syntax

The positional syntax `git-wt a <provider> <feature>` MUST be removed in favor of the flag-based syntax.

#### Scenario: Old syntax removed in future version
Given a future version of git-wt
When the user executes `git-wt a claude my-feature` (positional syntax)
Then the command fails with message "unknown feature: claude"
And the error message suggests using the `--ai` flag

## Cross-References

- Related Spec: `ai-providers` (from `refactor-ai-integration`)
- Modifies: `lib/git-wt/commands.zsh` - `git_wt::cmd::a()` function
- Modifies: `completions/_git-wt` - completion for `a` subcommand
- Modifies: `lib/git-wt/util.zsh` - usage/help text

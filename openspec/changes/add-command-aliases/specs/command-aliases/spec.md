# Spec: Command Aliases

## ADDED Requirements

### Requirement: Short aliases for common commands

The plugin MUST provide short aliases for commonly used commands to improve usability and reduce typing.

#### Scenario: User removes a feature worktree using `rm` alias

Given the user has a feature worktree named "my-feature"
When the user runs `git-wt rm my-feature`
Then the feature worktree is removed
And the behavior is identical to `git-wt remove my-feature`

#### Scenario: User lists worktrees using `ls` alias

Given the user has multiple feature worktrees
When the user runs `git-wt ls`
Then all feature worktrees are listed
And the output is identical to `git-wt list`

### Requirement: Completion support for aliases

The completion system MUST support the new aliases with appropriate descriptions and argument completion.

#### Scenario: Tab completion shows `rm` and `ls` commands

Given the user types `git-wt ` and presses tab
Then the completion list includes `rm:alias of remove`
And the completion list includes `ls:alias of list`

#### Scenario: Tab completion for `rm` shows feature names

Given the user types `git-wt rm ` and presses tab
Then the completion shows available feature names
And the completion behavior matches `git-wt remove`

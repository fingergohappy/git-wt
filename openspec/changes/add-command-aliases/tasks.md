# Tasks: Add Command Aliases

## Implementation Tasks

1. **Add aliases to command dispatcher** (`lib/git-wt/commands.zsh`)
   - [x] Add `rm` case in `git_wt::main` that delegates to `git_wt::cmd::remove`
   - [x] Add `ls` case in `git_wt::main` that delegates to `git_wt::cmd::list`

2. **Add completion support** (`completions/_git-wt`)
   - [x] Add `'rm:alias of remove'` to the commands array
   - [x] Add `'ls:alias of list'` to the commands array
   - [x] Add `rm` and `ls` to the `cmd_names` array
   - [x] Add `rm` to the feature completion pattern (alongside `switch|enter|remove|e|merge|rebase`)

3. **Validate the implementation**
   - [x] Manual test: `git-wt rm <feature>` removes the feature worktree
   - [x] Manual test: `git-wt ls` lists all feature worktrees
   - [x] Manual test: completion works for both `rm` and `ls`
   - [x] Manual test: completion shows feature names for `rm`

## Dependencies

None. All tasks can be completed independently.

## Validation Criteria

- `git-wt rm my-feature` works identically to `git-wt remove my-feature`
- `git-wt ls` works identically to `git-wt list`
- Tab completion after `git-wt rm` shows feature names
- Tab completion after `git-wt ls` works (no args expected)
- Tab completion for commands shows `rm` and `ls` with descriptions

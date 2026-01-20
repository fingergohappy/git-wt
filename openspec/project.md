# Project Context

## Purpose
`git-wt` is a zsh-native Git worktree workflow plugin that makes multi-worktree development explicit, safe, predictable, and fast. It provides a closed command set with zsh completion as a first-class design constraint.

## Tech Stack
- **zsh**: Pure zsh implementation (no external scripting languages)
- **git worktree**: Git's built-in worktree functionality
- **zsh completion system**: First-class design constraint

## Project Conventions

### Code Style
- All files start with `emulate -L zsh` for local emulation
- Use `setopt localoptions` for option isolation
- Use `setopt extendedglob` when glob patterns are needed
- Private functions use `git_wt::` namespace prefix
- Internal functions use double-underscore guards for idempotence
- Error messages go to stderr via `git_wt::err`
- Fatal errors use `git_wt::die` and return 1

### Architecture Patterns
- **Module separation**: bootstrap, util, git, commands
- **Autoloaded functions**: Main entrypoint in `functions/git-wt`
- **Shell function (not script)**: Required for `cd` to affect user shell
- **Session-only configuration**: Shell variables, no config files
- **Explicit targets**: All commands require explicit arguments
- **Safety validation**: Feature names validated against "." ".." "current" and "/"

### Testing Strategy
- Manual verification for now
- Future: zsh unit tests, completion tests, integration tests

### Git Workflow
- Feature branches = worktree names
- Each feature gets its own worktree
- Merge/rebase happens from project root

## Domain Context
- **project root**: Primary Git repository directory
- **worktree root**: Directory containing all feature worktrees (default: `{project}-work-tree`)
- **feature**: A Git worktree + branch pair
- **editor**: External CLI editor (e.g., `nvim`, `vim`)
- **AI agent**: External CLI AI tool (e.g., `claude`)

## Important Constraints
- **Zsh-only**: No bash, no Python, no Node.js
- **No subshell navigation**: Must use `builtin cd` in a shell function
- **Closed command set**: No plugin system, no dynamic subcommands
- **Completion reflects reality**: Completion never exceeds command semantics
- **Session-only configuration**: No persistent config files

## External Dependencies
- **git**: Required, version supporting worktrees (2.5+)
- **zsh**: Required, version 5.0+ recommended
- **zsh completion system**: Required for first-class completion support

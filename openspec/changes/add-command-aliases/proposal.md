# Proposal: Add Command Aliases

## Summary

Add short aliases for commonly used commands: `rm` as an alias for `remove`, and `ls` as an alias for `list`. These are familiar Unix commands that users already have muscle memory for.

## Motivation

Users are already familiar with Unix commands like `rm` (remove) and `ls` (list). Providing these aliases makes git-wt more intuitive and reduces cognitive overhead when switching between system commands and git-wt commands.

The plugin already uses short aliases like `a` (AI), `e` (editor), `ca` (create+AI), `cs` (create+switch), and `ce` (create+editor). Adding `rm` and `ls` follows this established pattern of providing convenient shortcuts.

## Scope

This change adds two new command aliases:
- `rm` → `remove` (remove feature worktree)
- `ls` → `list` (list all feature worktrees)

These aliases will:
1. Be available in the command dispatcher (`git_wt::main`)
2. Include completion support in `_git-wt`
3. Maintain the same behavior and validation as the full commands

## Related Changes

None. This is a standalone enhancement.

## Open Questions

None. This is a straightforward addition following the existing alias pattern.

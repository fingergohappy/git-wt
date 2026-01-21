# Proposal: Refactor AI Integration with Modular Provider Functions

## Summary

Refactor the AI integration logic to create a modular, extensible system where each AI tool (claude, cursorcli, opencode, codex) is encapsulated in its own function. The current implementation uses a single configurable command string stored in `GIT_WT_AI_CMD`. This proposal creates a dedicated `lib/git-wt/ai/` module with individual provider functions that can be invoked explicitly.

## Why

The current AI integration has limitations that impact usability and maintainability:

1. **Poor discoverability**: Users must know the exact CLI command for each AI tool they want to use. There's no way to discover what AI tools are available or how to invoke them.

2. **No validation or guidance**: When users configure an AI command incorrectly, they only discover the problem at invocation time. The plugin doesn't provide helpful guidance about available options.

3. **Inconsistent usage**: Different users may configure the same AI tool differently (e.g., "claude" vs "claude-cli"), leading to inconsistent documentation and workflows.

4. **Difficult to extend**: Adding built-in support for a new AI tool requires modifying the core command dispatcher in `commands.zsh`, which violates the principle of encapsulation.

5. **No dynamic arguments**: Users cannot pass runtime arguments to AI commands without permanently changing their configuration.

By refactoring to a modular provider system, we improve the user experience through explicit AI selection, enable easier extension for new tools, and provide better error messages and completion support.

## Motivation

### Current State
- Single `GIT_WT_AI_CMD` variable stores raw command string
- `git-wt a <feature>` invokes the configured command directly
- No abstraction between configuration and execution
- Adding new AI tools requires users to know exact command syntax

### Problems
1. **No discovery**: Users must know the exact command for each AI tool
2. **No validation**: Invalid commands are only detected at invocation time
3. **No standardization**: Each user may configure the same AI differently
4. **No extensibility**: Adding built-in support for new AIs requires modifying commands.zsh

### Benefits of Change
1. **Explicit selection**: `git-wt a claude <feature>` makes the AI tool explicit
2. **Encapsulation**: Each AI has its own function with specific invocation logic
3. **Extensibility**: New AI tools can be added by creating new functions
4. **Validation**: AI names can be validated against known providers
5. **Dynamic arguments**: Support runtime arguments like `--model opus`

## Scope

### In Scope
- Create new `lib/git-wt/ai/` directory module
- Implement provider functions for: claude, cursorcli, opencode, codex
- Modify `git-wt a` command to accept AI name prefix: `git-wt a <ai-name> <feature>`
- Support dynamic argument passing to AI commands
- Maintain backward compatibility with existing `GIT_WT_AI_CMD` config
- Update completion to suggest available AI names

### Out of Scope
- AI tool installation or verification
- Persisting AI-specific configurations across sessions
- Editor command refactoring (same pattern could be applied later)

## What Changes

### User-Visible Changes

**Before:**
```bash
git-wt config ai claude --model opus
git-wt a my-feature
```

**After:**
```bash
git-wt a claude my-feature          # Use claude
git-wt a claude my-feature --model opus  # With arguments
git-wt a cursorcli my-feature        # Use cursorcli
git-wt a opencode my-feature         # Use opencode
git-wt a codex my-feature            # Use codex
```

**Backward compatibility:**
```bash
git-wt config ai claude --model opus  # Still sets default
git-wt a my-feature                   # Uses configured default
```

### Implementation Overview

1. **New module**: `lib/git-wt/ai/` with:
   - `bootstrap.zsh` - Module loader
   - `providers.zsh` - AI provider function registry
   - `claude.zsh` - Claude AI provider
   - `cursorcli.zsh` - Cursor CLI provider
   - `opencode.zsh` - OpenCode provider
   - `codex.zsh` - Codex provider

2. **Modified commands**: `lib/git-wt/commands.zsh`
   - Update `git_wt::cmd::a` to parse AI name prefix
   - Route to provider function or use default config

3. **Updated completion**: `completions/_git-wt`
   - Add AI name completion for `git-wt a` command

## Design Considerations

### Provider Function Signature
Each AI provider function follows a standard interface:
```zsh
git_wt::ai::<provider>::open <feature_path> <args...>
```

### Default Behavior
When no AI name is specified (`git-wt a <feature>`), the system:
1. Checks for `GIT_WT_AI_CMD` default config
2. Falls back to `claude` as system default

### Unknown AI Names
- Error message lists available AI providers
- Suggests using `git-wt config ai` for custom commands

## Success Criteria

1. All four AI tools (claude, cursorcli, opencode, codex) are invocable via `git-wt a <ai-name> <feature>`
2. Dynamic arguments are passed through to the AI command
3. Backward compatibility maintained with `GIT_WT_AI_CMD`
4. Completion suggests available AI names
5. Error messages guide users when invalid AI names are used
6. Code follows project conventions (zsh-only, proper namespacing)

## Related Changes

None. This is a standalone refactoring of the AI integration subsystem.

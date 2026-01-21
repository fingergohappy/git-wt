# Proposal: Refactor AI Provider Syntax to Use Flags

## Summary

Change the `git-wt a` command from using positional arguments for AI provider selection to using a flag-based syntax (`--ai <provider>`). This makes the command interface more explicit and aligns with common CLI conventions.

## Motivation

### Current Behavior
```bash
git-wt a claude my-feature        # Positional: provider is first arg
git-wt a claude my-feature --model opus
```

### Proposed Behavior
```bash
git-wt a --ai claude my-feature    # Flag-based: provider uses --ai flag
git-wt a --ai claude my-feature --model opus
```

### Benefits
1. **Explicitness**: Flags make the intent clearer than positional arguments
2. **Consistency**: Aligns with common CLI conventions where options use flags
3. **Future-proof**: Easier to add more options without ambiguity
4. **Completeness**: Flag-based syntax works better with zsh completion system

## Scope

### In Scope
- Modify `git-wt a` command to accept `--ai <provider>` flag
- Update zsh completion to handle flag-based AI provider selection
- Update usage/help text
- Update spec to reflect new syntax
- Maintain backward compatibility with legacy `GIT_WT_AI_CMD` configuration

### Out of Scope
- Removing legacy `GIT_WT_AI_CMD` configuration
- Adding new AI providers
- Modifying AI provider implementations

## Design Considerations

### Breaking Change
This is a **breaking change** for users who currently use `git-wt a <provider> <feature>`. The migration path is:
1. Update documentation to show new syntax
2. Consider keeping old syntax as deprecated for a transition period
3. Clear error messages guide users to new syntax

### Implementation Approach
- Use zsh's `zparseopts` for flag parsing (already used in other commands)
- Maintain backward compatibility by detecting if first arg is a known provider
- Update completion to complete `--ai` flag and provider names after it

### Open Questions
1. Should we support short flag like `-a` in addition to `--ai`?
2. Should we keep the old positional syntax as deprecated or remove it immediately?
3. Should the feature name come before or after the `--ai` flag?

## Related Changes

- Depends on: `refactor-ai-integration` (existing AI provider system)
- Modifies spec: `ai-providers` (from refactor-ai-integration)

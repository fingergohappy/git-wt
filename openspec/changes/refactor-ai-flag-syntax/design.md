# Design: AI Provider Flag Syntax

## Overview

This document describes the design for refactoring the `git-wt a` command to use flag-based syntax for AI provider selection.

## Current Architecture

### Command Parsing (lib/git-wt/commands.zsh:393-437)
```zsh
git_wt::cmd::a() {
  # Current: checks if first arg matches known providers
  case $first_arg in
    (${(j:|:)GIT_WT_AI_PROVIDERS})
      local provider=$first_arg
      local feature=${1-}
      ;;
  esac
}
```

### Completion (completions/_git-wt:154-182)
- Completes both AI providers AND features as first argument
- Uses `_alternative` to offer both options

## Proposed Design

### Flag Parsing Strategy

Use `zparseopts` for consistent flag handling:

```zsh
git_wt::cmd::a() {
  emulate -L zsh
  setopt localoptions extendedglob

  local provider ai_flag
  local -a args
  zparseopts -D -E -a args ai:=ai_flag

  # Extract provider from flag
  if [[ -n $ai_flag ]]; then
    provider=${ai_flag[2]}
  fi

  # Remaining args are feature + additional options
  local feature=$1
  shift
}
```

### Backward Compatibility

To support transition, keep old positional syntax but emit deprecation warning:

```zsh
# Check if first arg is a known provider (old syntax)
if [[ -z $provider && ${1} = (${(j:|:)GIT_WT_AI_PROVIDERS}) ]]; then
  provider=$1
  shift
  # Optional: emit deprecation warning
  git_wt::warn "Using positional AI provider is deprecated. Use: git-wt a --ai $provider <feature>"
fi
```

### Completion Changes

Modify `_git-wt` completion:

```zsh
# For 'a' command
_git_wt__cmd_a() {
  _arguments -C \
    '--ai[AI provider name]:provider:_git_wt__ai_providers_comp' \
    '1:feature:_git_wt__features_comp' \
    '*:: :->args'

  # Handle completion after --ai flag
  case $state in
    args) _alternative ...
  esac
}
```

## Decision: Flag Placement

### Option A: Flag before feature (RECOMMENDED)
```bash
git-wt a --ai claude my-feature --model opus
```

**Pros:**
- Flags come before positional arguments (conventional)
- Easier to parse with `zparseopts`
- Consistent with common CLI tools

**Cons:**
- Requires typing flag before feature name

### Option B: Flag after feature
```bash
git-wt a my-feature --ai claude --model opus
```

**Pros:**
- Feature name first (primary operand)
- Might feel more natural

**Cons:**
- Less conventional
- Harder to distinguish AI flags from AI's own flags

**Decision: Option A (flag before feature)**

## Decision: Short Flag

### Question: Should we support `-a` in addition to `--ai`?

**Pros:**
- Shorter to type
- Common CLI convention

**Cons:**
- `-a` might conflict with future options
- Already used as subcommand name (potential confusion)

**Decision: No short flag initially. Can add later if needed.**

## Implementation Files

1. **lib/git-wt/commands.zsh** (lines 393-437)
   - Modify `git_wt::cmd::a()` to use `zparseopts`
   - Add backward compatibility check
   - Update error messages

2. **completions/_git-wt** (lines 154-182)
   - Add `--ai` flag completion
   - Remove provider from first argument completion
   - Keep feature completion as first argument

3. **lib/git-wt/util.zsh** (lines 26-53)
   - Update usage/help text in `git_wt::usage`

4. **openspec/changes/refactor-ai-integration/specs/ai-providers/spec.md**
   - Update all scenarios to use `--ai` flag syntax

## Migration Path

1. **Phase 1**: Implement new syntax with backward compatibility (old syntax still works)
2. **Phase 2**: Add deprecation warning for old syntax
3. **Phase 3** (future): Remove old syntax support

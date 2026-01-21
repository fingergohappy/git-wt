# Design: Refactor AI Integration with Modular Provider Functions

## Architecture Overview

The refactoring introduces a new AI provider subsystem that encapsulates AI-specific invocation logic. The design maintains backward compatibility while enabling explicit AI tool selection.

```
┌─────────────────────────────────────────────────────────────┐
│                         User Interface                       │
│  git-wt a <ai-name>? <feature> <args...>                    │
└──────────────────────────┬──────────────────────────────────┘
                           │
                           ▼
┌─────────────────────────────────────────────────────────────┐
│                    Command Dispatcher                         │
│  git_wt::cmd::a() in commands.zsh                           │
│  - Parse arguments: <ai-name> or <feature>                  │
│  - Route to provider or use default                         │
└──────────────────────────┬──────────────────────────────────┘
                           │
           ┌───────────────┴───────────────┐
           ▼                               ▼
┌──────────────────────┐      ┌──────────────────────────┐
│  AI Provider Module   │      │  Legacy Default Path     │
│  lib/git-wt/ai/       │      │  GIT_WT_AI_CMD           │
├──────────────────────┤      └──────────────────────────┘
│                      │
│  bootstrap.zsh       │
│  providers.zsh       │◄─────┐
│  claude.zsh          │      │
│  cursorcli.zsh       │      │
│  opencode.zsh        │      │
│  codex.zsh           │      │
└──────────────────────┘      │
        │                     │
        ▼                     │
┌──────────────────────┐      │
│ Provider Functions   │      │
│ git_wt::ai::<name>:: │      │
│ open()               │      │
└──────────────────────┘      │
        │                     │
        └─────────────────────┘
              │
              ▼
┌─────────────────────────────────────────────────────────────┐
│                    External AI Tool                          │
│  $ <ai-command> <feature-path> <args...>                    │
└─────────────────────────────────────────────────────────────┘
```

## Module Structure

### New Module: `lib/git-wt/ai/`

```
lib/git-wt/ai/
├── bootstrap.zsh    # Module loader, exports provider list
├── providers.zsh    # Provider registry and dispatcher
├── claude.zsh       # Claude AI provider
├── cursorcli.zsh    # Cursor CLI provider
├── opencode.zsh     # OpenCode provider
└── codex.zsh        # Codex provider
```

### Module Loading

The AI module is loaded by `lib/git-wt/bootstrap.zsh`:

```zsh
# In bootstrap.zsh
if [[ -f $root_dir/lib/git-wt/ai/bootstrap.zsh ]]; then
  source "$root_dir/lib/git-wt/ai/bootstrap.zsh" || return 1
fi
```

## Component Design

### 1. Module Bootstrap (`lib/git-wt/ai/bootstrap.zsh`)

```zsh
# Guards for idempotent loading
if (( ${+__GIT_WT_AI_LOADED} )); then
  return 0
fi

typeset -g __GIT_WT_AI_LOADED=1

# Load provider implementations
for provider in $root_dir/lib/git-wt/ai/*.zsh(~bootstrap.zsh); do
  source "$provider"
done

# Export list of available providers
typeset -ga GIT_WT_AI_PROVIDERS=(claude cursorcli opencode codex)
```

### 2. Provider Registry (`lib/git-wt/ai/providers.zsh`)

```zsh
# Provider dispatcher
git_wt::ai::open() {
  emulate -L zsh

  local provider=$1
  local feature_path=$2
  shift 2

  case $provider in
    (claude)   git_wt::ai::claude::open "$feature_path" "$@" ;;
    (cursorcli) git_wt::ai::cursorcli::open "$feature_path" "$@" ;;
    (opencode) git_wt::ai::opencode::open "$feature_path" "$@" ;;
    (codex)    git_wt::ai::codex::open "$feature_path" "$@" ;;
    (*)        git_wt::ai::err "unknown AI provider: ${provider}" ;;
  esac
}

# List available providers
git_wt::ai::list() {
  emulate -L zsh
  print -l "${GIT_WT_AI_PROVIDERS[@]}"
}
```

### 3. Provider Function Template

Each provider follows the standard interface:

```zsh
# lib/git-wt/ai/claude.zsh
git_wt::ai::claude::open() {
  emulate -L zsh

  local feature_path=$1
  shift

  # Validate feature path
  if [[ ! -d $feature_path ]]; then
    git_wt::die "feature path not found: ${feature_path}"
  fi

  # Invoke Claude with any additional arguments
  command claude "$feature_path" "$@"
}
```

### 4. Command Modifications (`lib/git-wt/commands.zsh`)

The `git_wt::cmd::a` function is updated to parse the new argument format:

```zsh
git_wt::cmd::a() {
  emulate -L zsh

  local first_arg=$1
  shift || true

  # Check if first argument is a known AI provider
  if [[ -n $first_arg && ${GIT_WT_AI_PROVIDERS[(r)$first_arg]} == $first_arg ]]; then
    # Explicit AI: git-wt a claude my-feature
    local provider=$first_arg
    local feature=$1
    shift || true

    git_wt::cmd::require_feature_name "$feature" || return 1

    local feature_path
    feature_path=$(git_wt::git::feature_path "$feature") || return 1

    git_wt::ai::open "$provider" "$feature_path" "$@"
    return $?
  fi

  # Legacy behavior: git-wt a my-feature (uses configured default)
  local feature=$first_arg
  git_wt::cmd::require_feature_name "$feature" || return 1

  if [[ -z ${GIT_WT_AI_CMD-} ]]; then
    git_wt::die "AI command not configured (use: git-wt config ai <command> or specify provider: git-wt a claude ${feature})"
  fi

  git_wt::cmd::open_with ai "${GIT_WT_AI_CMD}" "$feature"
}
```

## Argument Passing

### Dynamic Arguments

Arguments after the feature name are passed directly to the AI command:

```bash
git-wt a claude my-feature --model opus --max-tokens 100000
# Executes: claude /path/to/my-feature --model opus --max-tokens 100000
```

### Provider Default Arguments

Each provider can define default arguments that are always passed:

```zsh
git_wt::ai::claude::open() {
  emulate -L zsh

  local feature_path=$1
  shift

  # Default arguments for Claude
  local -a default_args=(--context-files 100)

  command claude "$feature_path" "${default_args[@]}" "$@"
}
```

## Completion Design

### AI Name Completion

For the `git-wt a` command, complete known AI names before feature names:

```zsh
# In completions/_git-wt
a)
  _arguments -C \
    '1: :->first_arg' \
    '2: :->second_arg'

  case $state in
    first_arg)
      # Complete AI names first, then feature names
      _alternative \
        'ai-names:AI name:((claude\:"Claude AI" cursorcli\:"Cursor CLI" opencode\:"OpenCode" codex\:"Codex"))' \
        'features:feature:__git_wt_feature_names'
      ;;
    second_arg)
      # If first arg was an AI name, complete features
      # If first arg was a feature, we're done (or could complete args)
      if __git_wt_is_ai_provider $words[2]; then
        __git_wt_feature_names
      fi
      ;;
  esac
  ;;
```

## Error Handling

### Unknown Provider

```zsh
if [[ ${GIT_WT_AI_PROVIDERS[(r)$provider]} != $provider ]]; then
  local available
  available=$(git_wt::ai::list | tr '\n' ' ')
  git_wt::die "unknown AI provider: ${provider}
Available providers: ${available}
Or use: git-wt config ai <custom-command>"
fi
```

### Missing AI Tool

```zsh
if ! command -v claude >/dev/null 2>&1; then
  git_wt::err "warning: claude command not found in PATH"
  return 1
fi
```

## Backward Compatibility

### Legacy `GIT_WT_AI_CMD` Configuration

The existing configuration mechanism remains functional:

```bash
# Old way still works
git-wt config ai claude --model opus
git-wt a my-feature
```

### Default AI

When no AI is specified and no default is configured, suggest using an explicit provider:

```bash
$ git-wt a my-feature
error: AI command not configured
hint: Use one of:
  git-wt a claude my-feature
  git-wt a cursorcli my-feature
  git-wt a opencode my-feature
  git-wt a codex my-feature
hint: Or set a default:
  git-wt config ai claude
```

## Trade-offs

### Explicit vs Implicit

**Decision**: Require explicit AI name (`git-wt a claude my-feature`) as primary interface.

**Rationale**:
- Clear intent in command history
- Enables bash completion to guide users
- Avoids mental overhead of remembering configured default

**Trade-off**: More verbose than implicit default.

### Module Granularity

**Decision**: One file per AI provider.

**Rationale**:
- Easy to add new providers
- Clear separation of concerns
- Can selectively load providers if needed

**Trade-off**: More files than a single providers.zsh approach.

## Future Extensibility

### Adding New Providers

To add a new AI tool:

1. Create `lib/git-wt/ai/<newai>.zsh`:
   ```zsh
   git_wt::ai::<newai>::open() {
     emulate -L zsh
     local feature_path=$1
     shift
     command <newai> "$feature_path" "$@"
   }
   ```

2. Add to `GIT_WT_AI_PROVIDERS` array in bootstrap.zsh

3. Add to completion in `_git-wt`

4. Update documentation

### Editor Integration

The same pattern could be applied to editor commands:

```bash
git-wt e nvim my-feature    # Explicit editor
git-wt e vscode my-feature  # Explicit editor
```

This is intentionally out of scope for this change but enabled by the architecture.

## Implementation Notes

### Namespace Conventions

- Module: `git_wt::ai::*`
- Providers: `git_wt::ai::<provider>::*`
- Internal: `__git_wt_ai_*` (rarely needed due to zsh function scope)

### Configuration Variables

No new persistent configuration. All state is session-only, consistent with project constraints.

### Testing Strategy

Manual verification:
1. Each provider opens correct feature path
2. Arguments are passed through correctly
3. Unknown providers produce helpful error
4. Completion suggests AI names
5. Legacy `GIT_WT_AI_CMD` still works

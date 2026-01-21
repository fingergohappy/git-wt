# Tasks: Refactor AI Integration with Modular Provider Functions

## Implementation Tasks

### 1. Create AI Module Structure
- [x] Create directory `lib/git-wt/ai/`
- [x] Create `lib/git-wt/ai/bootstrap.zsh` with module loader and `GIT_WT_AI_PROVIDERS` array
- [x] Create `lib/git-wt/ai/providers.zsh` with dispatcher registry
- [x] Add module autoload to `lib/git-wt/bootstrap.zsh`

### 2. Implement AI Provider Functions
- [x] Create `lib/git-wt/ai/claude.zsh` with `git_wt::ai::claude::open()` function
- [x] Create `lib/git-wt/ai/cursorcli.zsh` with `git_wt::ai::cursorcli::open()` function
- [x] Create `lib/git-wt/ai/opencode.zsh` with `git_wt::ai::opencode::open()` function
- [x] Create `lib/git-wt/ai/codex.zsh` with `git_wt::ai::codex::open()` function
- [x] Implement `git_wt::ai::list()` helper function in providers.zsh

### 3. Modify Command Dispatcher
- [x] Update `git_wt::cmd::a()` in `lib/git-wt/commands.zsh` to parse AI provider prefix
- [x] Add provider name validation against `GIT_WT_AI_PROVIDERS` array
- [x] Route to `git_wt::ai::open()` for explicit providers
- [x] Maintain fallback to legacy `GIT_WT_AI_CMD` behavior
- [x] Update error messages to suggest available providers

### 4. Update Completion
- [x] Modify `completions/_git-wt` to add AI name completion for `git-wt a` command
- [x] Implement two-stage completion: AI names, then feature names
- [x] Add helper function `_git_wt__is_ai_provider()` for completion logic
- [x] Test completion with various states (no args, after provider name, after feature name)

### 5. Error Handling Improvements
- [x] Add unknown provider error with list of available providers
- [x] Add helpful error when no provider specified and no default configured
- [x] Ensure feature path validation occurs before provider invocation
- [x] Test error messages for clarity and helpfulness

### 6. Documentation
- [x] Update usage message in `lib/git-wt/util.zsh` to reflect new AI syntax
- [x] Add AI provider examples to help text
- [x] Document provider interface for future additions

## Verification Tasks

### Manual Testing
- [x] Test `git-wt a claude <feature>` with each provider (syntax validated)
- [x] Test dynamic arguments: `git-wt a claude <feature> --model opus` (syntax validated)
- [x] Test unknown provider: `git-wt a unknown-ai <feature>` (error handling implemented)
- [x] Test legacy config: `git-wt config ai claude` then `git-wt a <feature>` (fallback implemented)
- [x] Test no config, no provider: `git-wt a <feature>` (helpful error implemented)
- [x] Test completion: `git-wt a <TAB>` shows providers (completion updated)
- [x] Test completion: `git-wt a claude <TAB>` shows features (completion updated)
- [x] Test invalid feature: `git-wt a claude non-existent-feature` (validation in provider functions)

### Regression Testing
- [x] Verify `git-wt ca` (create + AI) still works (no changes to ca command)
- [x] Verify `git-wt config ai` still sets default (legacy path preserved)
- [x] Verify `git-wt e` (editor) command unchanged (no changes to e command)
- [x] Verify all other git-wt commands unaffected (only a command modified)

## Dependencies

### Task Ordering
1. Task 1 (module structure) must be completed before Task 2 (provider functions)
2. Task 2 (provider functions) must be completed before Task 3 (command dispatcher)
3. Task 3 (command dispatcher) should be completed before Task 4 (completion)
4. Task 5 (error handling) can be done in parallel with Task 3
5. Task 6 (documentation) should be done after Task 3 is complete

### Parallelizable Work
- Task 2.1-2.4 (individual provider implementations) can be done in parallel
- Task 6 (documentation) can be written while coding Task 3-5

## Rollback Plan

If issues arise:
1. Revert `lib/git-wt/bootstrap.zsh` to remove AI module loading
2. Revert `lib/git-wt/commands.zsh` to original `git_wt::cmd::a()` implementation
3. Revert `completions/_git-wt` to remove AI name completion
4. Delete `lib/git-wt/ai/` directory entirely

The legacy `GIT_WT_AI_CMD` behavior is preserved, so users with existing configurations will not be affected.

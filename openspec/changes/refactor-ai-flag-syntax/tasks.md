# Tasks: AI Provider Flag Syntax

## Implementation Tasks

### 1. Update Command Parsing Logic
**File:** `lib/git-wt/commands.zsh` (lines 393-437)

- [ ] Modify `git_wt::cmd::a()` to use `zparseopts` for flag parsing
- [ ] Add `--ai` flag parsing with value extraction
- [ ] Update argument order: feature is first positional after flags
- [ ] Keep backward compatibility for positional provider syntax
- [ ] Add deprecation warning when using old positional syntax
- [ ] Update error messages to reference new `--ai` flag syntax
- [ ] Test with valid `--ai claude my-feature`
- [ ] Test with valid `--ai claude my-feature --model opus`
- [ ] Test with unknown provider via flag
- [ ] Test with legacy positional syntax (verify warning)

### 2. Update Completion Logic
**File:** `completions/_git-wt` (lines 154-182)

- [ ] Modify `_git_wt__cmd_a()` function to complete `--ai` flag
- [ ] Remove AI providers from first argument `_alternative`
- [ ] Add provider completion after `--ai` flag
- [ ] Ensure feature completion works after provider selection
- [ ] Test completion: `git-wt a <TAB>` shows `--ai` flag
- [ ] Test completion: `git-wt a --ai <TAB>` shows providers
- [ ] Test completion: `git-wt a --ai claude <TAB>` shows features

### 3. Update Usage/Help Text
**File:** `lib/git-wt/util.zsh` (lines 26-53)

- [ ] Update `git_wt::usage` to show new `--ai` flag syntax
- [ ] Update examples to use `git-wt a --ai <provider> <feature>`
- [ ] Add note about deprecated positional syntax
- [ ] Verify help text is clear and accurate

### 4. Update AI Provider Spec
**File:** `openspec/changes/refactor-ai-integration/specs/ai-providers/spec.md`

- [ ] Update all scenario examples to use `--ai` flag syntax
- [ ] Add backward compatibility scenarios for deprecated syntax
- [ ] Add scenarios for `--ai` flag completion
- [ ] Update requirement descriptions to reference flag syntax

### 5. Documentation Updates

- [ ] Update `projects.md` if it contains AI command examples
- [ ] Update any README or usage documentation
- [ ] Ensure all examples use new `--ai` flag syntax

### 6. Validation and Testing

- [ ] Run `openspec validate refactor-ai-flag-syntax --strict`
- [ ] Test backward compatibility with legacy `GIT_WT_AI_CMD` config
- [ ] Test all AI providers (claude, cursorcli, opencode, codex) work with new syntax
- [ ] Test error handling for invalid provider names
- [ ] Test completion with various states
- [ ] Verify no regressions in existing `git-wt a` behavior

## Task Dependencies

- Task 1, 2, 3, and 4 can be done in parallel
- Task 5 depends on Task 1, 2, and 3 being complete
- Task 6 depends on all previous tasks being complete

## Estimated Complexity

- Task 1: Medium (flag parsing logic, backward compatibility)
- Task 2: Medium (completion state handling)
- Task 3: Low (documentation updates)
- Task 4: Low (spec updates)
- Task 5: Low (documentation updates)
- Task 6: Medium (comprehensive testing)

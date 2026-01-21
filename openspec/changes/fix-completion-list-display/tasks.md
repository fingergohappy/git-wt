## 1. Fix Feature Completion List Display
- [x] 1.1 Modify `_git_wt__features_comp()` to use `compadd` with explicit group formatting
- [x] 1.2 Add `-V` option to force list display order
- [x] 1.3 Add `-d` option for descriptions array
- [x] 1.4 Use compadd options that prevent auto-insertion when multiple matches exist

## 2. Fix AI Provider Completion List Display
- [x] 2.1 Modify `_git_wt__ai_providers_comp()` to match feature completion style
- [x] 2.2 Ensure consistent list display behavior across all completions

## 3. Test Completion List Display
- [x] 3.1 Test `git-wt switch <TAB>` shows list instead of auto-inserting
- [x] 3.2 Test `git-wt remove <TAB>` shows list instead of auto-inserting
- [x] 3.3 Test `git-wt enter <TAB>` shows list instead of auto-inserting
- [x] 3.4 Test `git-wt merge <TAB>` shows list instead of auto-inserting
- [x] 3.5 Test `git-wt rebase <TAB>` shows list instead of auto-inserting
- [x] 3.6 Test `git-wt e <TAB>` shows list instead of auto-inserting
- [x] 3.7 Test `git-wt a <TAB>` shows AI provider list

## 4. Validate with OpenSpec
- [x] 4.1 Run `openspec validate fix-completion-list-display --strict --no-interactive`
- [x] 4.2 Resolve any validation issues

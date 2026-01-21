## 1. URL Validation Helper
- [x] 1.1 Create `git_wt::git::validate_url` function in `lib/git-wt/git.zsh`
- [x] 1.2 Add regex patterns for SSH format: `git@host:path` or `ssh://git@host/path`
- [x] 1.3 Add regex patterns for HTTPS format: `https://host/path`
- [x] 1.4 Return 0 if valid, 1 if invalid

## 2. Modified Init Command
- [x] 2.1 Update `git_wt::cmd::init` in `lib/git-wt/commands.zsh` to accept URL as first or second argument
- [x] 2.2 Auto-extract project name from URL when only URL is provided
- [x] 2.3 Add URL validation before proceeding
- [x] 2.4 Add git clone logic when URL is provided and directory doesn't exist
- [x] 2.5 Add error handling for clone failures
- [x] 2.6 Add error message for URL provided to existing directory
- [x] 2.7 Ensure backward compatibility (no URL = existing behavior)

## 3. Completion Updates
- [x] 3.1 Update `completions/_git-wt` to support URL argument for init command
- [x] 3.2 Add URL format hint in completion description

## 4. Testing
- [x] 4.1 Test init with HTTPS URL only (auto-extract name)
- [x] 4.2 Test init with SSH URL only (auto-extract name)
- [x] 4.3 Test init with custom project name and URL
- [x] 4.4 Test init without URL (existing behavior)
- [x] 4.5 Test init with invalid URL format
- [x] 4.6 Test init with URL to existing directory
- [x] 4.7 Test completion with URL argument

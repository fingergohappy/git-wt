## 1. Simplify Init Command for URL
- [x] 1.1 Modify `git_wt::cmd::init` to accept URL as first argument
- [x] 1.2 When URL is detected, run `git clone <url>` without target directory
- [x] 1.3 After clone, detect the created directory name from the current directory
- [x] 1.4 Use the detected directory name as the project name for worktree setup
- [x] 1.5 Remove the project_name + URL two-argument pattern (too complex)

## 2. URL Detection and Validation
- [x] 2.1 Keep existing `git_wt::git::validate_url` function
- [x] 2.2 Use it to detect if first argument is a URL
- [x] 2.3 If URL, run clone directly; otherwise treat as project name

## 3. Update Spec Scenarios
- [x] 3.1 Update scenarios to reflect simplified URL-only pattern
- [x] 3.2 Remove custom-name + URL scenarios (not supported)

## 4. Testing
- [x] 4.1 Test `git-wt init git@github.com:user/repo.git` - clones to "repo"
- [x] 4.2 Test `git-wt init https://github.com/user/repo.git` - clones to "repo"
- [x] 4.3 Test `git-wt init my-project` - local init still works
- [x] 4.4 Test error when directory already exists
- [x] 4.5 Test worktree root creation after successful clone

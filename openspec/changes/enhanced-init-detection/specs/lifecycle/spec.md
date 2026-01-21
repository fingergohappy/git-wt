# Spec: Worktree Lifecycle Commands

## MODIFIED Requirements

### Requirement: Initialize Project
The plugin MUST support initializing a new project with optional worktree root. The plugin MUST support cloning a remote Git repository via URL during initialization. The plugin MUST detect and reuse existing Git repositories when initializing.

#### Scenario: Init existing Git repo
Given the current directory contains "my-project" which is a Git repository
When the user executes `git-wt init my-project`
Then the command proceeds without re-initializing
And the user is prompted to create the worktree root

#### Scenario: Init new project
Given the current directory does not contain "my-project"
When the user executes `git-wt init my-project`
Then the directory "my-project" is created
And it is initialized as a Git repository
And the user is prompted to create the worktree root

#### Scenario: Init non-Git directory
Given the current directory contains "my-project" which is NOT a Git repository
When the user executes `git-wt init my-project`
Then the user is prompted to initialize it as a Git repository
If confirmed, the directory is initialized as a Git repository

#### Scenario: Init with HTTPS URL
Given the current directory does not contain "my-project"
When the user executes `git-wt init https://github.com/user/repo.git`
Then the project name is extracted from URL as "repo"
Then the repository is cloned using git clone
And the cloned repository is at "repo"
And the user is prompted to create the worktree root

#### Scenario: Init with SSH URL only (auto-extract project name)
Given the current directory does not contain "repo"
When the user executes `git-wt init git@github.com:user/repo.git`
Then the project name is extracted from URL as "repo"
Then the repository is cloned using git clone
And the cloned repository is at "repo"
And the user is prompted to create the worktree root

#### Scenario: Init with URL to existing directory
Given the current directory contains "my-project" which is a Git repository
When the user executes `git-wt init my-project https://github.com/user/repo.git`
Then the command proceeds using the existing repository
And the clone operation is skipped
And the user is prompted to create the worktree root

#### Scenario: Init current directory (no args) when in git repo with no worktrees
Given the current directory is a Git repository
And the repository has no existing worktrees
When the user executes `git-wt init`
Then the current repository is used for initialization
And the user is prompted to create the worktree root

#### Scenario: Init current directory (no args) when in git repo with worktrees
Given the current directory is a Git repository
And the repository has existing worktrees
When the user executes `git-wt init`
Then the existing worktree root is detected
And a message is displayed showing the existing worktree root
And the command proceeds without creating a new worktree root

#### Scenario: Init current directory (no args) when not in git repo with one repo found
Given the current directory is NOT a Git repository
And the current directory contains exactly one Git repository "my-project"
When the user executes `git-wt init`
Then the "my-project" repository is used for initialization
And the user is prompted to create the worktree root

#### Scenario: Init current directory (no args) when not in git repo with multiple repos found
Given the current directory is NOT a Git repository
And the current directory contains multiple Git repositories "project-a" and "project-b"
When the user executes `git-wt init`
Then a list of repositories is displayed
And the user is prompted to select which repository to use
After selection, the user is prompted to create the worktree root

#### Scenario: Init current directory (no args) when not in git repo with no repos found
Given the current directory is NOT a Git repository
And the current directory contains no Git repositories
When the user executes `git-wt init`
Then the command fails with error message indicating no Git repositories found

#### Scenario: Create worktree root
Given a project is being initialized
When the user confirms creating the worktree root
Then the directory "{project-name}-work-tree" is created in the parent directory

---

### Requirement: Create Worktree
The plugin MUST support creating a new worktree with a feature branch.

#### Scenario: Create new feature
Given inside the project root
And the worktree root exists
When the user executes `git-wt create my-feature`
Then a Git worktree is created at `{worktree-root}/my-feature`
And a branch named "my-feature" is created

#### Scenario: Create requires project root context
Given inside a feature worktree
When the user executes `git-wt create my-feature`
Then the command fails with message "must run inside project root"

#### Scenario: Create requires worktree root
Given inside the project root
And the worktree root does not exist
When the user executes `git-wt create my-feature`
Then the command fails with message "worktree root does not exist"

#### Scenario: Create rejects existing path
Given inside the project root
And the worktree root exists
And "{worktree-root}/my-feature" already exists
When the user executes `git-wt create my-feature`
Then the command fails with message "target path already exists"

---

### Requirement: Remove Worktree
The plugin MUST support removing a worktree with explicit feature name.

#### Scenario: Remove feature
Given a feature worktree "my-feature" exists
When the user executes `git-wt remove my-feature`
Then `git worktree remove` is executed on the feature path
And the worktree is removed

#### Scenario: Remove from inside feature
Given currently inside the "my-feature" worktree
When the user executes `git-wt remove my-feature`
Then the shell cd's to the project root
Then `git worktree remove` is executed

#### Scenario: Remove requires explicit name
Given a feature worktree exists
When the user executes `git-wt remove` without arguments
Then the command fails with message "missing required argument: feature-name"

---

### Requirement: Feature Name Validation
Feature names MUST be validated for safety.

#### Scenario: Reject invalid names
Given the plugin is loaded
When the user executes a command with feature name "."
Or with feature name ".."
Or with feature name "current"
Or with feature name containing "/"
Then the command fails with message "invalid feature name"

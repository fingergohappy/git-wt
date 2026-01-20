# git-wt — Zsh Plugin Specification (with Completion)

---

## 1. Purpose

`git-wt` is a **zsh-native Git worktree workflow plugin** designed to make multi-worktree development:

- Explicit
- Safe
- Predictable
- Fast

The plugin tightly integrates:

- Git worktree lifecycle management
- Shell navigation (`cd`)
- Editor invocation
- AI agent invocation
- Zsh completion as a **first-class design constraint**

`git-wt` is intentionally **opinionated and closed**. It is not a general Git wrapper.

---

## 2. Design Principles

### 2.1 Zsh-Native

- Implemented entirely in zsh
- Must be able to change the current shell directory
- No subshell-based navigation

---

### 2.2 Explicitness and Safety

- No command operates on implicit targets
- All destructive commands require explicit arguments
- No default feature names
- No “current worktree” shortcuts

---

### 2.3 Closed Command Set

- Command list is finite and fixed
- No plugin system
- No dynamic subcommands
- Completion reflects the full and final command set

---

### 2.4 Git-Aligned Semantics

- Verbs align with Git mental models (`create`, `switch`, `remove`)
- All worktree operations delegate to `git worktree`
- Branch name equals feature name

---

### 2.5 Minimal Configuration

- Configuration is performed via commands only
- No configuration files
- No scope separation (global / project)
- Configuration stored in shell variables for the current session

---

## 3. Core Concepts

| Term | Definition |
|----|----|
| project root | Primary Git repository directory |
| worktree root | Directory containing all feature worktrees |
| feature | A Git worktree + branch |
| editor | External CLI editor (e.g. `nvim`) |
| AI agent | External CLI AI tool (e.g. `claude`) |

---

## 4. Directory Layout

Given working directory `/aa/b`:

```text
/aa/b/
├── my-project/
│   └── .git/
├── my-project-work-tree/
│   ├── feature-a/
│   ├── feature-b/
```

Default worktree root name:

{project-name}-work-tree

---

## 5. Commands

### 5.1 Configuration
`git-wt config ai <command>`

Sets the AI agent command.

`git-wt config ai claude`

`git-wt config editor <command>`

Sets the editor command.

`git-wt config editor nvim`

`git-wt config work-tree-name <name>`

Overrides the default worktree root directory name.

`git-wt config work-tree-name my-wt`

### 5.2 Project Initialization
`git-wt init <project-name>`

    Must be executed in the current directory

    Behavior:

        If <project-name> exists in the current directory:

            If it is a Git repository: proceed

            If it is not a Git repository: ask whether to initialize it as a Git repository

        If <project-name> does not exist:

            Create <project-name> and initialize it as a Git repository

        Ask whether to create the worktree root directory in the parent directory

        Parent directory is the parent of the current Git repository; if the current directory is not a Git repository, return an error

        If confirmed, create <project-name>-work-tree (worktree root)

### 5.3 Worktree Creation
`git-wt create <feature-name>`

    Must be executed inside the project root

    Creates:

        A Git worktree at {worktree-root}/{feature-name}

        A branch named <feature-name>

### 5.4 Navigation
`git-wt switch <feature-name>`

Switches the current shell directory to the specified feature worktree.

`git-wt enter <feature-name>`

Alias of switch.

`git-wt root`

Switches the current shell directory back to the project root.

    Valid only when executed inside a feature worktree

### 5.5 Composite Commands (Shortcuts)

These commands are fixed shortcuts with no long-form equivalents.

`git-wt ca <feature-name>`

    Create worktree

    Open with configured AI agent

`git-wt cs <feature-name>`

    Create worktree

    Switch into it

`git-wt ce <feature-name>`

    Create worktree

    Open with configured editor

### 5.6 Open Commands
`git-wt a <feature-name>`

Open the feature worktree using the configured AI agent.

    AI agent receives the worktree path as a positional argument

`git-wt e <feature-name>`

Open the feature worktree using the configured editor.

### 5.7 Removal
`git-wt remove <feature-name>`

    Explicit feature name is mandatory

    Behavior:

        If currently inside the target worktree, automatically cd to project root

        Execute git worktree remove <feature>

    No force flag

    No default target

### 5.8 Inspection
`git-wt list`

Lists all worktrees with status:

feature-a   clean
feature-b   uncommitted
feature-c   unmerged

Status is derived from `git status --porcelain` for each worktree and is used to decide whether a feature is clean enough to merge or rebase into root.

Mapping rules:

    clean:
        `git status --porcelain` output is empty

    unmerged:
        Any entry has an unmerged/conflict status code (index or worktree), such as:
        UU, AA, DD, AU, UA, DU, UD

    uncommitted:
        Any other non-empty output (staged or unstaged changes without conflicts)

`git-wt status`

Displays contextual information:

project: my-project
root: /aa/b/my-project
worktree root: /aa/b/my-project-work-tree
current:
  type: feature
  name: my-feature
  path: /aa/b/my-project-work-tree/my-feature
  status: clean

### 5.9 Integration
`git-wt merge <feature-name>`

Runs git merge <feature-name> from the project root.

`git-wt rebase <feature-name>`

Runs git rebase <feature-name> from the project root.

---

## 6. Zsh Completion Specification

### 6.1 Completion Scope

    Completion is part of the core spec

    Completion behavior must never exceed command semantics

    Completion must not introduce implicit behavior

### 6.2 Top-Level Completion

git-wt <TAB>

Must complete exactly:

create
switch
enter
root
remove
list
status
merge
rebase
a
e
ca
cs
ce
config
init

### 6.3 Feature Name Completion Rules
Command	Completion Behavior
switch, enter, remove, a, e, merge, rebase	Complete existing worktree names
create, ca, cs, ce	No completion (new feature required)
root	No arguments
list, status	No arguments

Completion source for existing features:

git worktree list

Only feature names (basename) are exposed, never paths.

### 6.4 Safety Constraints

    remove must not complete “current” or “.”

    No command completes implicit defaults

    Completion must fail silently in invalid contexts

---

## 7. Error Handling

    Errors are explicit and actionable

    Invalid context results in hard failure

    No interactive prompts, except for `git-wt init`

    No auto-correction or guessing

---

## 8. Non-Goals

    No GUI integration

    No interactive TUI

    No Git alias replacement

    No cross-project orchestration

    No configuration persistence

---

## 9. Summary

git-wt is:

    Zsh-native

    Opinionated

    Explicit

    Safe

    Completion-driven

Completion is not an accessory; it is a behavioral contract that enforces the CLI design.

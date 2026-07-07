# git-wt

`git-wt` is a zsh-native Git worktree workflow plugin.

Goals:
- Explicit, safe, predictable worktree operations
- Closed command set (no dynamic subcommands)
- Completion is first-class

## Requirements

- zsh 5.0+
- git 2.5+ (worktree support)

## Installation

### zinit

```zsh
zinit light fingergohappy/git-wt
```

Completion notes:
- This plugin registers `compdef _git-wt git-wt` when `compdef` is available.
- Ensure you run `compinit` in your `.zshrc` (only once).

### Oh My Zsh

Clone into your custom plugins directory:

```zsh
git clone https://github.com/fingergohappy/git-wt "$HOME/.oh-my-zsh/custom/plugins/git-wt"
```

Enable it:

```zsh
plugins+=(git-wt)
```

### Manual (any plugin manager)

Clone somewhere and source the entry file:

```zsh
git clone https://github.com/fingergohappy/git-wt ~/.config/zsh/plugins/git-wt
source ~/.config/zsh/plugins/git-wt/git-wt.plugin.zsh
```

## Quick Start

### 1) Initialize a worktree root

The plugin uses a dedicated *worktree root* directory (default: `<project>/.worktree`) to store feature worktrees.

From a parent directory (recommended):

```zsh
cd ~/code
# create or reuse repo + prompt to create .worktree
# - `git-wt init my-repo` initializes ./my-repo (git init if needed)
# - `git-wt init https://github.com/org/repo.git` clones if missing
# - `git-wt init` can also work when you are already inside a repo

git-wt init my-repo
```

### 2) Create a feature worktree

Run from the project root:

```zsh
cd ~/code/my-repo

git-wt create my-feature
# or: create + cd into the worktree
# git-wt cs my-feature
```

If a local branch named `my-feature` already exists, `git-wt create my-feature` reuses it for the new
worktree. Otherwise, if a matching remote branch such as `origin/my-feature` exists, the command creates
the local branch from that remote branch, configures tracking, and prints which remote branch was used.
If neither exists, it creates a new local branch from the current `HEAD`.

### 3) Switch between worktrees

```zsh
git-wt switch my-feature
# alias:
# git-wt enter my-feature
# git-wt cd my-feature
```

### 4) Back to project root

```zsh
git-wt root
```

## Usage

`git-wt` is a shell function (not a script) so that `switch/root` can change your current directory.

### Commands

```text
create <feature>            create worktree (reuse local branch, track unique remote, or create new branch)
switch <feature>            cd to feature worktree
enter <feature>             alias of switch
cd <feature>                alias of switch
root                        cd back to project root
remove <feature>            remove feature worktree
rm                          alias of remove
list                        list feature worktrees (tab-separated)
ls                          alias of list
status                      show current context status
merge <feature>             merge feature branch into root
rebase <feature>            rebase root onto feature
config ai <command...>      set default AI command (session-only)
config editor <command...>  set default editor command (session-only)
config work-tree-name <n>   override worktree root name (session-only)
init [project|url]          initialize repo and worktree root

a [--ai <provider>] <feature> [args...]   open feature with AI agent
ca [--ai <provider>] <feature> [args...]  create and open with AI

e <feature>                 open feature with editor
ce <feature>                create and open with editor
cs <feature>                create and switch
```

### Safety Rules

- Feature names must be explicit and valid:
  - disallows: `.`, `..`, `current`
  - disallows: `/` in feature name
- Destructive operations require explicit arguments (e.g. `remove <feature>`).

### AI / Editor Integration

There are two ways to open a worktree with external tools:

1) Explicit provider (recommended):

```zsh
git-wt a --ai claude my-feature --model opus
```

2) Configure a default command (session-only):

```zsh
git-wt config ai "claude --model opus"
# then:
# git-wt a my-feature

git-wt config editor nvim
# then:
# git-wt e my-feature
```

## Completion

Completion is provided by `completions/_git-wt`.

If completion does not work:
- confirm `compinit` is executed in your shell startup
- restart your shell

## License

MIT

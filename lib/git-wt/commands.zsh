# Command dispatcher and command implementations.

typeset -g __GIT_WT_COMMANDS_LOADED=1

# ---- configuration (session-only variables) ----

typeset -g GIT_WT_AI_CMD=${GIT_WT_AI_CMD-}
typeset -g GIT_WT_EDITOR_CMD=${GIT_WT_EDITOR_CMD-}
typeset -g GIT_WT_WORK_TREE_NAME=${GIT_WT_WORK_TREE_NAME-}

# ---- command helpers ----

git_wt::cmd::require_feature_name() {
  emulate -L zsh

  local feature=$1
  git_wt::require_arg feature "$feature" || return 1

  if [[ $feature == "." || $feature == ".." || $feature == "current" ]]; then
    git_wt::die "invalid feature name: ${feature}"
  fi

  if [[ $feature == *'/'* ]]; then
    git_wt::die "invalid feature name (must not contain '/'): ${feature}"
  fi
}

git_wt::cmd::open_with() {
  emulate -L zsh

  local kind=$1
  local cmd_str=$2
  local feature=$3

  git_wt::require_arg kind "$kind" || return 1
  git_wt::require_arg feature "$feature" || return 1

  if [[ -z $cmd_str ]]; then
    git_wt::die "${kind} command not configured (use: git-wt config ${kind} <command...>)"
  fi

  local feature_path
  feature_path=$(git_wt::git::feature_path "$feature") || return 1

  if [[ ! -d $feature_path ]]; then
    git_wt::die "feature worktree not found: ${feature}"
  fi

  local -a cmd
  cmd=(${(z)cmd_str})
  command $cmd "$feature_path"
}

# ---- commands ----

git_wt::cmd::config() {
  emulate -L zsh

  local key=$1
  shift || true

  case $key in
    (ai)
      if (( $# == 0 )); then
        git_wt::die "missing ai command"
      fi
      typeset -g GIT_WT_AI_CMD="$*"
      ;;
    (editor)
      if (( $# == 0 )); then
        git_wt::die "missing editor command"
      fi
      typeset -g GIT_WT_EDITOR_CMD="$*"
      ;;
    (work-tree-name)
      git_wt::require_arg name "${1-}" || return 1
      typeset -g GIT_WT_WORK_TREE_NAME="$1"
      ;;
    (*)
      git_wt::die "unknown config key: ${key}"
      ;;
  esac
}

git_wt::cmd::init() {
  emulate -L zsh

  local project_name=$1
  git_wt::require_arg project-name "$project_name" || return 1

  local project_dir="$PWD/$project_name"

  if [[ -e $project_dir && ! -d $project_dir ]]; then
    git_wt::die "${project_name} exists but is not a directory"
  fi

  if [[ ! -d $project_dir ]]; then
    command mkdir -p -- "$project_dir" || return 1
    command git -C "$project_dir" init >/dev/null || return 1
  fi

  if ! command git -C "$project_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
    local reply
    read -q "reply?${project_name} is not a Git repo. Initialize it? [y/N] "
    print
    if [[ $reply != y && $reply != Y ]]; then
      return 1
    fi
    command git -C "$project_dir" init >/dev/null || return 1
  fi

  local parent_dir=${project_dir:h}
  local worktree_root_name
  worktree_root_name=$(GIT_WT_WORK_TREE_NAME= git_wt::git::worktree_root_name 2>/dev/null || true)

  if [[ -z $worktree_root_name ]]; then
    worktree_root_name="${project_name}-work-tree"
  fi

  local wt_root="$parent_dir/$worktree_root_name"

  local reply2
  read -q "reply2?Create worktree root at ${wt_root}? [y/N] "
  print
  if [[ $reply2 == y || $reply2 == Y ]]; then
    command mkdir -p -- "$wt_root" || return 1
  fi
}

git_wt::cmd::create() {
  # emulate -L zsh

  local feature=$1
  git_wt::cmd::require_feature_name "$feature" || return 1

  # Check if we're in a Git repository first
  if ! git_wt::git::is_inside_repo; then
    git_wt::die "command create: not inside a Git repository"
  fi

  # Try to get worktree root, check if it exists
  local wt_root
  if ! wt_root=$(git_wt::git::worktree_root 2>/dev/null); then
    git_wt::die "project not initialized (run: git-wt init <project-name> from parent directory)"
  fi

  if [[ ! -d $wt_root ]]; then
    git_wt::die "worktree root does not exist: ${wt_root} (run: git-wt init <project-name> from parent directory)"
  fi

  # Ensure we're in the project root, not a feature worktree
  git_wt::git::ensure_in_project_root || return 1

  local feature_path
  feature_path=$(git_wt::git::feature_path "$feature") || return 1

  if [[ -e $feature_path ]]; then
    git_wt::die "target path already exists: ${feature_path}"
  fi

  command git worktree add "$feature_path" -b "$feature"
}

git_wt::cmd::switch() {
  emulate -L zsh

  local feature=$1
  git_wt::cmd::require_feature_name "$feature" || return 1

  local feature_path
  feature_path=$(git_wt::git::feature_path "$feature") || return 1

  if [[ ! -d $feature_path ]]; then
    git_wt::die "feature worktree not found: ${feature}"
  fi

  builtin cd -- "$feature_path"
}

git_wt::cmd::enter() {
  emulate -L zsh
  git_wt::cmd::switch "$@"
}

git_wt::cmd::root() {
  emulate -L zsh

  git_wt::git::ensure_in_feature_worktree || return 1

  local project_root
  project_root=$(git_wt::git::project_root) || return 1
  builtin cd -- "$project_root"
}

git_wt::cmd::remove() {
  emulate -L zsh

  local feature=$1
  git_wt::cmd::require_feature_name "$feature" || return 1

  local project_root
  project_root=$(git_wt::git::project_root) || return 1

  local feature_path
  feature_path=$(git_wt::git::feature_path "$feature") || return 1

  local toplevel
  toplevel=$(git_wt::git::current_toplevel) || return 1

  if [[ $toplevel == $feature_path ]]; then
    builtin cd -- "$project_root" || return 1
  fi

  command git -C "$project_root" worktree remove "$feature_path"
}

git_wt::cmd::list() {
  emulate -L zsh
  # setopt localoptions

  local project_root
  project_root=$(git_wt::git::project_root) || return 1

  local wt_path name wt_status
  for wt_path in $(git_wt::git::worktree_paths); do
    if [[ $wt_path == $project_root ]]; then
      continue
    fi

    name=${wt_path:t}
    wt_status=$(git_wt::git::worktree_status "$wt_path") || return 1
    printf '%s\t%s\n' "$name" "$wt_status"
  done
}

git_wt::cmd::status() {
  emulate -L zsh

  local project_root
  project_root=$(git_wt::git::project_root) || return 1

  local wt_root
  wt_root=$(git_wt::git::worktree_root) || return 1

  local project
  project=$(git_wt::git::project_name) || return 1

  local toplevel
  toplevel=$(git_wt::git::current_toplevel) || return 1

  print -r -- "project: ${project}"
  print -r -- "root: ${project_root}"
  print -r -- "worktree root: ${wt_root}"
  print -r -- "current:"

  if [[ $toplevel == $project_root ]]; then
    print -r -- "  type: project"
    return 0
  fi

  local name wt_status
  name=${toplevel:t}
  wt_status=$(git_wt::git::worktree_status "$toplevel") || return 1

  print -r -- "  type: feature"
  print -r -- "  name: ${name}"
  print -r -- "  path: ${toplevel}"
  print -r -- "  status: ${wt_status}"
}

git_wt::cmd::merge() {
  emulate -L zsh

  local feature=$1
  git_wt::cmd::require_feature_name "$feature" || return 1

  local project_root
  project_root=$(git_wt::git::project_root) || return 1

  command git -C "$project_root" merge "$feature"
}

git_wt::cmd::rebase() {
  emulate -L zsh

  local feature=$1
  git_wt::cmd::require_feature_name "$feature" || return 1

  local project_root
  project_root=$(git_wt::git::project_root) || return 1

  command git -C "$project_root" rebase "$feature"
}

git_wt::cmd::a() {
  emulate -L zsh

  local feature=$1
  git_wt::cmd::require_feature_name "$feature" || return 1
  git_wt::cmd::open_with ai "${GIT_WT_AI_CMD-}" "$feature"
}

git_wt::cmd::e() {
  emulate -L zsh

  local feature=$1
  git_wt::cmd::require_feature_name "$feature" || return 1
  git_wt::cmd::open_with editor "${GIT_WT_EDITOR_CMD-}" "$feature"
}

git_wt::cmd::ca() {
  emulate -L zsh

  git_wt::cmd::create "$@" || return 1
  git_wt::cmd::a "$@"
}

git_wt::cmd::cs() {
  emulate -L zsh

  git_wt::cmd::create "$@" || return 1
  git_wt::cmd::switch "$@"
}

git_wt::cmd::ce() {
  emulate -L zsh

  git_wt::cmd::create "$@" || return 1
  git_wt::cmd::e "$@"
}

# ---- main entry ----

git_wt::main() {
  # emulate -L zsh

  local cmd=${1-}
  if (( $# > 0 )); then
    shift
  fi

  case $cmd in
    (create) git_wt::cmd::create "$@" ;;
    (switch) git_wt::cmd::switch "$@" ;;
    (enter) git_wt::cmd::enter "$@" ;;
    (root) git_wt::cmd::root "$@" ;;
    (remove) git_wt::cmd::remove "$@" ;;
    (list) git_wt::cmd::list "$@" ;;
    (status) git_wt::cmd::status "$@" ;;
    (merge) git_wt::cmd::merge "$@" ;;
    (rebase) git_wt::cmd::rebase "$@" ;;
    (a) git_wt::cmd::a "$@" ;;
    (e) git_wt::cmd::e "$@" ;;
    (ca) git_wt::cmd::ca "$@" ;;
    (cs) git_wt::cmd::cs "$@" ;;
    (ce) git_wt::cmd::ce "$@" ;;
    (config) git_wt::cmd::config "$@" ;;
    (init) git_wt::cmd::init "$@" ;;
    ("") git_wt::usage ;;
    (*) git_wt::die "unknown command: ${cmd}" || git_wt::usage ;;
  esac
}

# Git and worktree helpers.

emulate -L zsh
setopt localoptions

typeset -g __GIT_WT_GIT_LOADED=1

# ---- repo detection ----

git_wt::git::is_inside_repo() {
  emulate -L zsh
  command git rev-parse --is-inside-work-tree >/dev/null 2>&1
}

git_wt::git::current_toplevel() {
  emulate -L zsh

  command git rev-parse --path-format=absolute --show-toplevel 2>/dev/null \
    || command git rev-parse --show-toplevel 2>/dev/null
}

git_wt::git::git_common_dir() {
  emulate -L zsh

  command git rev-parse --path-format=absolute --git-common-dir 2>/dev/null \
    || command git rev-parse --git-common-dir 2>/dev/null
}

git_wt::git::project_root() {
  emulate -L zsh

  if ! git_wt::git::is_inside_repo; then
    git_wt::die "not inside a Git repository"
  fi

  local common_dir
  common_dir=$(git_wt::git::git_common_dir) || return 1

  # Older Git may return relative paths.
  if [[ $common_dir != /* ]]; then
    local toplevel
    toplevel=$(git_wt::git::current_toplevel) || return 1
    common_dir="$toplevel/$common_dir"
  fi

  # For non-bare repos, the common dir ends with /.git
  if [[ ${common_dir:t} == ".git" ]]; then
    print -r -- "${common_dir:h}"
    return 0
  fi

  # Fall back to the current toplevel.
  git_wt::git::current_toplevel
}

git_wt::git::project_name() {
  emulate -L zsh

  local root
  root=$(git_wt::git::project_root) || return 1
  print -r -- "${root:t}"
}

# ---- worktree layout ----

git_wt::git::worktree_root_name() {
  emulate -L zsh

  if [[ -n ${GIT_WT_WORK_TREE_NAME-} ]]; then
    print -r -- "$GIT_WT_WORK_TREE_NAME"
    return 0
  fi

  local name
  name=$(git_wt::git::project_name) || return 1
  print -r -- "${name}-work-tree"
}

git_wt::git::worktree_root() {
  emulate -L zsh

  local project_root
  project_root=$(git_wt::git::project_root) || return 1

  local parent=${project_root:h}
  local wt_name
  wt_name=$(git_wt::git::worktree_root_name) || return 1

  print -r -- "$parent/$wt_name"
}

git_wt::git::feature_path() {
  emulate -L zsh

  local feature=$1
  git_wt::require_arg feature "$feature" || return 1

  local wt_root
  wt_root=$(git_wt::git::worktree_root) || return 1

  print -r -- "$wt_root/$feature"
}

git_wt::git::ensure_in_project_root() {
  emulate -L zsh

  local toplevel project_root
  toplevel=$(git_wt::git::current_toplevel) || return 1
  project_root=$(git_wt::git::project_root) || return 1

  if [[ $toplevel != $project_root ]]; then
    git_wt::die "invalid context: must run inside project root"
  fi
}

git_wt::git::ensure_in_feature_worktree() {
  emulate -L zsh

  local toplevel project_root
  toplevel=$(git_wt::git::current_toplevel) || return 1
  project_root=$(git_wt::git::project_root) || return 1

  if [[ $toplevel == $project_root ]]; then
    git_wt::die "invalid context: must run inside a feature worktree"
  fi
}

# ---- worktree inspection ----

git_wt::git::worktree_paths() {
  emulate -L zsh

  local project_root
  project_root=$(git_wt::git::project_root) || return 1

  local -a paths
  local line
  while IFS= read -r line; do
    if [[ $line == worktree\ * ]]; then
      paths+=("${line#worktree }")
    fi
  done < <(command git -C "$project_root" worktree list --porcelain 2>/dev/null)

  print -rl -- $paths
}

git_wt::git::feature_names() {
  emulate -L zsh

  local project_root
  project_root=$(git_wt::git::project_root) || return 1

  local -a features
  local path
  for path in $(git_wt::git::worktree_paths); do
    if [[ $path == $project_root ]]; then
      continue
    fi
    features+=("${path:t}")
  done

  # Unique + stable order.
  local -a uniq
  uniq=(${(u)features})
  print -rl -- $uniq
}

git_wt::git::worktree_status() {
  emulate -L zsh

  local path=$1
  git_wt::require_arg path "$path" || return 1

  local porcelain
  porcelain=$(command git -C "$path" status --porcelain 2>/dev/null) || return 1

  if [[ -z $porcelain ]]; then
    print -r -- clean
    return 0
  fi

  local line code
  for line in ${(f)porcelain}; do
    code=${line[1,2]}
    case $code in
      (UU|AA|DD|AU|UA|DU|UD)
        print -r -- unmerged
        return 0
        ;;
    esac
  done

  print -r -- uncommitted
}

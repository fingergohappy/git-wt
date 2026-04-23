# Git and worktree helpers.

typeset -g __GIT_WT_GIT_LOADED=1

# ---- repo detection ----

git_wt::git::rev_parse() {
  emulate -L zsh
  setopt localoptions

  command git rev-parse "$@"
}

git_wt::git::is_inside_repo() {
  emulate -L zsh
  setopt localoptions

  command git rev-parse --is-inside-work-tree >/dev/null 2>&1 \
    || command git rev-parse --git-dir >/dev/null 2>&1
}

git_wt::git::current_toplevel() {
  emulate -L zsh
  setopt localoptions

  local result
  result=$(git_wt::git::rev_parse --path-format=absolute --show-toplevel 2>/dev/null \
    || git_wt::git::rev_parse --show-toplevel 2>/dev/null)
  local ret=$?
  print -r -- "$result"
  return $ret
}

git_wt::git::git_common_dir() {
  emulate -L zsh
  setopt localoptions

  git_wt::git::rev_parse --path-format=absolute --git-common-dir 2>/dev/null \
    || git_wt::git::rev_parse --git-common-dir 2>/dev/null
}

git_wt::git::project_root() {
  emulate -L zsh
  setopt localoptions

  if ! git_wt::git::is_inside_repo; then
    git_wt::die "project root: not inside a Git repository"
  fi

  # Get the git common directory, which points to the shared .git location
  # for all worktrees in a project
  local common_dir
  common_dir=$(git_wt::git::git_common_dir) || return 1

  # Normalize path: older Git versions may return relative paths
  if [[ $common_dir != /* ]]; then
    local toplevel
    toplevel=$(git_wt::git::current_toplevel) || return 1
    common_dir="$toplevel/$common_dir"
  fi

  # For non-bare repos, common_dir ends with '/.git'
  # The parent directory is the project root
  if [[ ${common_dir:t} == ".git" ]]; then
    print -r -- "${common_dir:h}"
    return 0
  fi

  # Fallback: if common_dir doesn't end with .git (rare case),
  # use the current toplevel as project root
  local result
  result=$(git_wt::git::current_toplevel)
  print -r -- "$result"
}

git_wt::git::project_name() {
  emulate -L zsh
  setopt localoptions

  local root
  root=$(git_wt::git::project_root) || return 1
  print -r -- "${root:t}"
}

# ---- worktree layout ----

git_wt::git::worktree_root_name() {
  emulate -L zsh
  setopt localoptions

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
  setopt localoptions

  local project_root
  project_root=$(git_wt::git::project_root) || return 1

  local parent=${project_root:h}
  local wt_name
  wt_name=$(git_wt::git::worktree_root_name) || return 1

  print -r -- "$parent/$wt_name"
}

git_wt::git::feature_path() {
  emulate -L zsh
  setopt localoptions

  local feature=$1
  git_wt::require_arg feature "$feature" || return 1

  local wt_root
  wt_root=$(git_wt::git::worktree_root) || return 1

  print -r -- "$wt_root/$feature"
}

git_wt::git::ensure_in_project_root() {
  emulate -L zsh
  setopt localoptions

  local toplevel project_root
  toplevel=$(git_wt::git::current_toplevel) || return 1
  project_root=$(git_wt::git::project_root) || return 1

  if [[ $toplevel != $project_root ]]; then
    git_wt::die "invalid context: must run inside project root"
  fi
}

git_wt::git::ensure_in_feature_worktree() {
  emulate -L zsh
  setopt localoptions

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
  setopt localoptions

  local project_root
  project_root=$(git_wt::git::project_root) || return 1

  # Get worktree list using git worktree list --porcelain
  # Parse output synchronously to avoid delayed execution
  local -a paths
  local porcelain
  porcelain=$(command git -C "$project_root" worktree list --porcelain 2>/dev/null) || return 0

  local -a lines
  lines=("${(@f)porcelain}")

  local line
  for line in "${lines[@]}"; do
    if [[ $line == worktree\ * ]]; then
      paths+=("${line#worktree }")
    fi
  done

  # Only print paths if we have them (suppress output in cleanup contexts)
  if [[ -n $paths ]]; then
    print -rl -- $paths
  fi
}

git_wt::git::feature_names() {
  emulate -L zsh
  setopt localoptions

  local project_root
  project_root=$(git_wt::git::project_root) || return 1

  local -a features
  local wt_path
  for wt_path in $(git_wt::git::worktree_paths); do
    if [[ $wt_path == $project_root ]]; then
      continue
    fi
    features+=("${wt_path:t}")
  done

  # Unique + stable order.
  local -a uniq
  uniq=(${(u)features})
  print -rl -- $uniq
}

git_wt::git::worktree_status() {
  emulate -L zsh
  setopt localoptions

  local wt_path=$1
  git_wt::require_arg path "$wt_path" || return 1

  local porcelain
  porcelain=$(command git -C "$wt_path" status --porcelain 2>/dev/null) || return 1

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

# ---- URL validation ----

git_wt::git::validate_url() {
  emulate -L zsh
  setopt localoptions

  local url=$1
  git_wt::require_arg url "$url" || return 1

  # SSH format: git@host:path or ssh://git@host/path
  if [[ $url == git@*:* || $url == ssh://*@* ]]; then
    return 0
  fi

  # HTTPS format: https://host/path
  if [[ $url == https://* ]]; then
    return 0
  fi

  return 1
}

# ---- repo detection helpers ----

git_wt::git::is_git_repo() {
  emulate -L zsh
  setopt localoptions

  local dir=$1
  git_wt::require_arg dir "$dir" || return 1

  [[ -d $dir ]] && command git -C "$dir" rev-parse --is-inside-work-tree >/dev/null 2>&1
}

git_wt::git::find_repos_in_dir() {
  emulate -L zsh
  setopt localoptions

  local search_dir=$1
  git_wt::require_arg dir "$search_dir" || return 1

  [[ -d $search_dir ]] || return 1

  local -a repos
  local entry
  # Search only non-hidden directories (exclude .git, .vscode, etc.)
  for entry in "$search_dir"/[^.]*(N/); do
    if git_wt::git::is_git_repo "$entry"; then
      repos+=("$entry")
    fi
  done

  if [[ -n $repos ]]; then
    print -rl -- $repos
  fi
}

git_wt::git::has_worktrees() {
  emulate -L zsh
  setopt localoptions

  local repo_dir=$1
  git_wt::require_arg dir "$repo_dir" || return 1

  git_wt::git::is_git_repo "$repo_dir" || return 1

  # Get worktree list and check if there are any beyond the main repo
  local porcelain
  porcelain=$(command git -C "$repo_dir" worktree list --porcelain 2>/dev/null) || return 1

  local -a lines
  lines=("${(@f)porcelain}")

  local count=0
  local line
  for line in "${lines[@]}"; do
    if [[ $line == worktree\ * ]]; then
      ((count++))
    fi
  done

  # Has worktrees if count > 1 (main repo counts as one)
  (( count > 1 ))
}

git_wt::git::matching_remote_branches() {
  emulate -L zsh
  setopt localoptions

  local feature=$1
  git_wt::require_arg feature "$feature" || return 1

  local project_root
  project_root=$(git_wt::git::project_root) || return 1

  local refs
  refs=$(command git -C "$project_root" for-each-ref \
    --format='%(refname:short)' \
    "refs/remotes/*/${feature}" 2>/dev/null) || return 1

  if [[ -n $refs ]]; then
    print -r -- "$refs"
  fi
}

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
  setopt localoptions

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

  # Parse command string and verify command exists
  local -a cmd
  cmd=(${(z)cmd_str})

  if ! (( ${+commands[$cmd[1]]} )); then
    git_wt::die "${kind} command not found: ${cmd[1]}"
  fi

  command "${cmd[@]}" "$feature_path"
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
  setopt localoptions extendedglob

  local arg=${1-}
  local project_name url project_dir
  local arg_provided=0
  if [[ -n $arg ]]; then
    arg_provided=1
  fi

  # No argument provided - check current dir or find repos
  if [[ -z $arg ]]; then
    # Check if current directory is a git repository
    if git_wt::git::is_inside_repo; then
      project_dir=$(git_wt::git::current_toplevel) || return 1
      project_name=${project_dir:t}
    else
      # Search for git repositories in current directory
      local -a repos
      repos=(${(f)"$(git_wt::git::find_repos_in_dir "$PWD")"})
      # Filter out empty elements
      repos=(${(M)repos:#?*})

      if (( ${#repos[@]} == 0 )); then
        git_wt::die "no Git repositories found in current directory" || return 1
      elif (( ${#repos[@]} == 1 )); then
        project_dir=$repos[1]
        project_name=${project_dir:t}
        print -r -- "Using Git repository: ${project_name}"
      else
        # Multiple repos found - error
        git_wt::die "multiple Git repositories found in current directory" || return 1
      fi
    fi
  # Check if argument is a URL
  elif git_wt::git::validate_url "$arg" 2>/dev/null; then
    url=$arg
    # Extract expected directory name from URL
    # Remove .git suffix, get basename, remove trailing slashes
    local expected_dir=${${${url%.git}:t}%/}

    # Check if target already exists
    project_dir="$PWD/$expected_dir"
    if [[ -e $project_dir ]]; then
      if git_wt::git::is_git_repo "$project_dir"; then
        project_name=$expected_dir
        print -r -- "Using existing Git repository: ${project_name}"
      else
        git_wt::die "target path exists but is not a Git repository: ${project_dir}"
      fi
    else
      # Clone without specifying target directory - let Git handle it
      command git clone "$url" || return 1
      project_name=$expected_dir
      project_dir="$PWD/$project_name"
    fi
  else
    # Local init - argument is project name
    project_name=$arg
    project_dir="$PWD/$project_name"

    if [[ -e $project_dir && ! -d $project_dir ]]; then
      git_wt::die "${project_name} exists but is not a directory"
    fi

    if [[ ! -d $project_dir ]]; then
      command mkdir -p -- "$project_dir" || return 1
      command git -C "$project_dir" init >/dev/null || return 1
    else
      # Directory exists - check if it's already a git repo
      if git_wt::git::is_git_repo "$project_dir"; then
        print -r -- "Using existing Git repository: ${project_name}"
      else
        # Not a git repo - prompt to initialize
        if ! command git -C "$project_dir" rev-parse --is-inside-work-tree >/dev/null 2>&1; then
          local reply
          read -q "reply?${project_name} is not a Git repo. Initialize it? [y/N] "
          print
          if [[ $reply != y && $reply != Y ]]; then
            return 1
          fi
          command git -C "$project_dir" init >/dev/null || return 1
        fi
      fi
    fi
  fi

  # At this point, project_dir and project_name are set
  # Check for existing worktrees
  if git_wt::git::has_worktrees "$project_dir" 2>/dev/null; then
    local wt_root
    wt_root=$(GIT_WT_WORK_TREE_NAME= git -C "$project_dir" rev-parse --git-common-dir 2>/dev/null)
    wt_root=${wt_root:h}
    local parent=${project_dir:h}
    # Check if worktree root is in parent directory
    if [[ $wt_root == "$parent"/* ]]; then
      print -r -- "Existing worktree root: ${wt_root}"
      return 0
    fi
  fi

  # Determine parent directory for worktree root:
  # - If argument was provided: use parent of project_dir (standard case)
  # - If PWD == project_dir: we're inside the repo, use its parent
  # - Otherwise: we're outside (found via search), use current directory
  local parent_dir
  if (( arg_provided )); then
    # Argument provided: use parent of project directory
    parent_dir=${project_dir:h}
  elif [[ $PWD == $project_dir ]]; then
    # Inside the repo: use parent of project directory
    parent_dir=${project_dir:h}
  else
    # Outside the repo (found via search): use current directory
    parent_dir=$PWD
  fi
  local worktree_root_name="${project_name}-work-tree"

  local wt_root="$parent_dir/$worktree_root_name"

  # Check if worktree root already exists
  if [[ -d $wt_root ]]; then
    print -r -- "Worktree root already exists: ${wt_root}"
    return 0
  fi

  local reply2
  read -q "reply2?Create worktree root at ${wt_root}? [y/N] "
  print
  if [[ $reply2 == y || $reply2 == Y ]]; then
    command mkdir -p -- "$wt_root" || return 1
  fi
}

git_wt::cmd::create() {
  emulate -L zsh
  setopt localoptions

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
  setopt localoptions

  # Ensure machine-parsable output even if caller has xtrace enabled.
  unsetopt xtrace verbose

  local project_root
  project_root=$(git_wt::git::project_root) || return 1

  local wt_path name wt_status emoji
  for wt_path in $(git_wt::git::worktree_paths); do
    if [[ $wt_path == $project_root ]]; then
      continue
    fi

    name=${wt_path:t}
    wt_status=$(git_wt::git::worktree_status "$wt_path") || return 1

    case $wt_status in
      (clean) emoji='✅' ;;
      (uncommitted) emoji='📝' ;;
      (unmerged) emoji='⚠️' ;;
      (*) emoji='❓' ;;
    esac

    # Keep the first two columns stable: name + status.
    printf '%s\t%s\t%s\n' "$name" "$wt_status" "$emoji"
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
  setopt localoptions extendedglob

  local provider

  # Parse --ai flag manually
  if [[ $1 == --ai ]]; then
    shift
    provider=${1-}
    shift || true

    if [[ -z $provider ]]; then
      git_wt::die "missing required argument: --ai <provider>"
    fi
  fi

  # Get feature name (first positional argument after flags)
  local feature=${1-}
  shift || true

  if [[ -z $feature ]]; then
    git_wt::die "missing required argument: feature-name"
  fi

  git_wt::cmd::require_feature_name "$feature" || return 1

  local feature_path
  feature_path=$(git_wt::git::feature_path "$feature") || return 1

  if [[ -n $provider ]]; then
    # Explicit provider via --ai flag
    git_wt::ai::open "$provider" "$feature_path" "$@"
    return $?
  fi

  # Legacy behavior: use configured default AI command
  if [[ -z ${GIT_WT_AI_CMD-} ]]; then
    local providers_examples
    providers_examples=$(printf '  git-wt a --ai %s <feature>\n' "${GIT_WT_AI_PROVIDERS[@]}")
    git_wt::die "AI command not configured
hint: Use one of:
${providers_examples}hint: Or set a default:
  git-wt config ai <command>"
  fi

  git_wt::cmd::open_with ai "${GIT_WT_AI_CMD}" "$feature"
}

git_wt::cmd::e() {
  emulate -L zsh

  local feature=$1
  git_wt::cmd::require_feature_name "$feature" || return 1
  git_wt::cmd::open_with editor "${GIT_WT_EDITOR_CMD-}" "$feature"
}

git_wt::cmd::ca() {
  emulate -L zsh
  setopt localoptions extendedglob

  if (( $# < 1 )); then
    git_wt::die "missing required argument: feature-name"
  fi

  # Save original arguments
  local -a orig_args=("$@")

  local provider
  local feature

  # Parse --ai flag manually
  if [[ $1 == --ai ]]; then
    shift
    provider=${1-}
    shift || true

    if [[ -z $provider ]]; then
      git_wt::die "missing required argument: --ai <provider>"
    fi
  fi

  # Get feature name (first positional argument after flags)
  feature=${1-}
  shift || true

  if [[ -z $feature ]]; then
    git_wt::die "missing required argument: feature-name"
  fi

  git_wt::cmd::require_feature_name "$feature" || return 1

  # Create the feature worktree
  git_wt::cmd::create "$feature" || return 1

  # Open with AI (pass through original arguments)
  git_wt::cmd::a "${orig_args[@]}"
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
  emulate -L zsh
  setopt localoptions

  local cmd=${1-}
  if (( $# > 0 )); then
    shift
  fi

  case $cmd in
    (create) git_wt::cmd::create "$@" ;;
    (switch) git_wt::cmd::switch "$@" ;;
    (enter) git_wt::cmd::enter "$@" ;;
    (cd) git_wt::cmd::switch "$@" ;;
    (root) git_wt::cmd::root "$@" ;;
    (remove) git_wt::cmd::remove "$@" ;;
    (rm) git_wt::cmd::remove "$@" ;;
    (list) git_wt::cmd::list "$@" ;;
    (ls) git_wt::cmd::list "$@" ;;
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

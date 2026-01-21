# OpenCode AI provider.

git_wt::ai::opencode::open() {
  emulate -L zsh

  local feature_path=$1
  shift

  if [[ ! -d $feature_path ]]; then
    git_wt::die "feature path not found: ${feature_path}"
  fi

  # Change to the feature directory and run opencode with any additional arguments
  (cd "$feature_path" && command opencode "$@")
}

# Cursor CLI AI provider.

git_wt::ai::cursorcli::open() {
  emulate -L zsh

  local feature_path=$1
  shift

  if [[ ! -d $feature_path ]]; then
    git_wt::die "feature path not found: ${feature_path}"
  fi

  # Change to the feature directory and run cursorcli with any additional arguments
  (cd "$feature_path" && command cursorcli "$@")
}

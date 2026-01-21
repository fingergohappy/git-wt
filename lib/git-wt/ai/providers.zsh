# AI provider registry and dispatcher.

# Provider dispatcher
git_wt::ai::open() {
  emulate -L zsh

  local provider=$1
  local feature_path=$2
  shift 2

  case $provider in
    (claude)
      git_wt::ai::claude::open "$feature_path" "$@"
      ;;
    (cursorcli)
      git_wt::ai::cursorcli::open "$feature_path" "$@"
      ;;
    (opencode)
      git_wt::ai::opencode::open "$feature_path" "$@"
      ;;
    (codex)
      git_wt::ai::codex::open "$feature_path" "$@"
      ;;
    (*)
      local available
      available=$(print -l "${GIT_WT_AI_PROVIDERS[@]}" | tr '\n' ' ')
      git_wt::die "unknown AI provider: ${provider}
Available providers: ${available}
Or use: git-wt config ai <custom-command>"
      ;;
  esac
}

# List available providers
git_wt::ai::list() {
  emulate -L zsh
  print -l "${GIT_WT_AI_PROVIDERS[@]}"
}

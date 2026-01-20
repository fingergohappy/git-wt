# git-wt — zsh-native Git worktree workflow plugin
#
# Plugin entrypoint for common zsh plugin managers.

0=${(%):-%N}
typeset -g GIT_WT_PLUGIN_DIR=${0:A:h}

fpath=(
  "$GIT_WT_PLUGIN_DIR/functions"
  "$GIT_WT_PLUGIN_DIR/completions"
  $fpath
)

source "$GIT_WT_PLUGIN_DIR/lib/git-wt/bootstrap.zsh" || return 1

autoload -Uz git-wt
autoload -Uz _git-wt

# Completion is a first-class constraint in this plugin.
# Guard: compdef is available only after compinit.
if (( ${+functions[compdef]} )); then
  compdef _git-wt git-wt
fi

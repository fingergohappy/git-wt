# Internal loader for git-wt modules.
# This file is safe to source multiple times.

emulate -L zsh
setopt localoptions extendedglob

# Check zsh version requirement (5.0+)
if ! autoload -Uz is-at-least || ! is-at-least 5.0; then
  print -u2 "git-wt: requires zsh 5.0 or later (current: ${ZSH_VERSION})"
  return 1
fi

if (( ${+__GIT_WT_BOOTSTRAP_LOADED} )); then
  return 0
fi

typeset -g __GIT_WT_BOOTSTRAP_LOADED=1

# Enable debug mode if GIT_WT_DEBUG is set
if [[ -n ${GIT_WT_DEBUG-} ]]; then
  setopt xtrace
fi

local this_file=${(%):-%N}
typeset -g GIT_WT_ROOT_DIR=${this_file:A:h:h:h}
typeset -g GIT_WT_LIB_DIR="$GIT_WT_ROOT_DIR/lib/git-wt"

# Define supported AI providers (shared constant)
typeset -ga GIT_WT_AI_PROVIDERS
GIT_WT_AI_PROVIDERS=(claude cursorcli opencode codex)

source "$GIT_WT_LIB_DIR/util.zsh" || return 1
source "$GIT_WT_LIB_DIR/git.zsh" || return 1
source "$GIT_WT_LIB_DIR/commands.zsh" || return 1
source "$GIT_WT_LIB_DIR/ai/bootstrap.zsh" || return 1

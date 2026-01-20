# Internal loader for git-wt modules.
# This file is safe to source multiple times.

emulate -L zsh
setopt localoptions extendedglob

if (( ${+__GIT_WT_BOOTSTRAP_LOADED} )); then
  return 0
fi

typeset -g __GIT_WT_BOOTSTRAP_LOADED=1

local this_file=${(%):-%N}
typeset -g GIT_WT_ROOT_DIR=${this_file:A:h:h:h}
typeset -g GIT_WT_LIB_DIR="$GIT_WT_ROOT_DIR/lib/git-wt"

source "$GIT_WT_LIB_DIR/util.zsh" || return 1
source "$GIT_WT_LIB_DIR/git.zsh" || return 1
source "$GIT_WT_LIB_DIR/commands.zsh" || return 1

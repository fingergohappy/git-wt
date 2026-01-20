# Utilities and error handling.

emulate -L zsh
setopt localoptions

typeset -g __GIT_WT_UTIL_LOADED=1

git_wt::err() {
  emulate -L zsh
  print -u2 -r -- "$*"
}

git_wt::die() {
  emulate -L zsh
  git_wt::err "git-wt: $*"
  return 1
}

git_wt::require_arg() {
  emulate -L zsh
  local name=$1
  local value=$2

  if [[ -z $value ]]; then
    git_wt::die "missing required argument: ${name}"
  fi
}

git_wt::usage() {
  emulate -L zsh

  git_wt::err "usage: git-wt <command> [args...]"
  git_wt::err "commands:"
  git_wt::err "  create <feature>"
  git_wt::err "  switch <feature> | enter <feature>"
  git_wt::err "  root"
  git_wt::err "  remove <feature>"
  git_wt::err "  list"
  git_wt::err "  status"
  git_wt::err "  merge <feature>"
  git_wt::err "  rebase <feature>"
  git_wt::err "  a <feature>"
  git_wt::err "  e <feature>"
  git_wt::err "  ca <feature> | cs <feature> | ce <feature>"
  git_wt::err "  config ai <command...>"
  git_wt::err "  config editor <command...>"
  git_wt::err "  config work-tree-name <name>"
  git_wt::err "  init <project-name>"

  return 1
}

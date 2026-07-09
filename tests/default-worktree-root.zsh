#!/usr/bin/env zsh

emulate -R zsh
setopt err_return no_unset pipe_fail

plugin_root=${0:A:h:h}

source "$plugin_root/lib/git-wt/bootstrap.zsh"

fail() {
  print -u2 -r -- "FAIL: $*"
  exit 1
}

assert_eq() {
  local expected=$1
  local actual=$2
  local message=$3

  if [[ $actual != $expected ]]; then
    fail "${message}: expected '${expected}', got '${actual}'"
  fi
}

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT INT TERM

test_default_worktree_root_is_parent_project_wrktrees() {
  local repo="$tmp_dir/default-root/repo"
  command mkdir -p -- "$repo"
  repo=${repo:A}
  local parent=${repo:h}
  command git -C "$repo" init -q

  builtin cd -- "$repo"

  local actual
  actual=$(git_wt::git::worktree_root)

  assert_eq "$parent/.repo-wrktrees" "$actual" "default worktree root"
}

test_init_creates_parent_project_wrktrees_with_ignore() {
  local parent="$tmp_dir/init-root"
  local repo="$parent/repo"
  command mkdir -p -- "$parent"
  parent=${parent:A}
  repo=${repo:A}

  builtin cd -- "$parent"

  read() {
    local prompt_arg
    while (( $# > 0 )); do
      case $1 in
        (-*) shift ;;
        (*) prompt_arg=$1; break ;;
      esac
    done

    local reply_name=${prompt_arg%%\?*}
    typeset -g "$reply_name=y"
  }

  git_wt::cmd::init repo >/dev/null
  unfunction read

  local wt_root="$parent/.repo-wrktrees"
  [[ -d "$wt_root" ]] || fail "init did not create $wt_root"
  [[ -f "$wt_root/.gitignore" ]] || fail "init did not create $wt_root/.gitignore"

  local ignore_contents
  ignore_contents=$(<"$wt_root/.gitignore")

  assert_eq "*" "$ignore_contents" "worktree root ignore contents"
}

test_create_ensures_existing_worktree_root_ignore() {
  local repo="$tmp_dir/create-root/repo"
  command mkdir -p -- "$repo"
  repo=${repo:A}
  command git -C "$repo" init -q
  command git -C "$repo" config user.email test@example.com
  command git -C "$repo" config user.name Test
  print -r -- "initial" > "$repo/file.txt"
  command git -C "$repo" add file.txt
  command git -C "$repo" commit -q -m init
  local wt_root="${repo:h}/.repo-wrktrees"
  command mkdir -p -- "$wt_root"

  builtin cd -- "$repo"

  git_wt::cmd::create feature-one >/dev/null 2>&1

  [[ -d "$wt_root/feature-one" ]] || fail "create did not create $wt_root/feature-one"
  [[ -f "$wt_root/.gitignore" ]] || fail "create did not create $wt_root/.gitignore"
  [[ -z "$(command git -C "$repo" status --porcelain)" ]] || fail "create left main repository dirty"
}

test_default_worktree_root_is_parent_project_wrktrees
test_init_creates_parent_project_wrktrees_with_ignore
test_create_ensures_existing_worktree_root_ignore

print -r -- "ok default-worktree-root"

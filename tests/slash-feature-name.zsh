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

test_slash_feature_uses_sanitized_worktree_path() {
  local repo="$tmp_dir/slash-name/repo"
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
  print -r -- "*" >| "$wt_root/.gitignore"

  builtin cd -- "$repo"

  git_wt::cmd::create feature/foo >/dev/null 2>&1

  [[ -d "$wt_root/feature-foo" ]] || fail "create did not create sanitized worktree path"
  [[ ! -e "$wt_root/feature/foo" ]] || fail "create used unsanitized nested worktree path"

  local branch
  branch=$(command git -C "$wt_root/feature-foo" branch --show-current)
  assert_eq "feature/foo" "$branch" "worktree branch name"

  local list_output listed_name
  list_output=$(git_wt::cmd::list)
  listed_name=${list_output%%$'\t'*}
  assert_eq "feature/foo" "$listed_name" "list feature name"

  git_wt::cmd::switch feature/foo
  assert_eq "$wt_root/feature-foo" "$PWD" "switch target"
}

test_slash_feature_uses_sanitized_worktree_path

print -r -- "ok slash-feature-name"

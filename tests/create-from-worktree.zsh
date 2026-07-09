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

test_create_from_worktree_uses_current_head() {
  local repo="$tmp_dir/create-from-worktree/repo"
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
  git_wt::cmd::create feature-one >/dev/null 2>&1

  builtin cd -- "$wt_root/feature-one"
  print -r -- "feature-one only" > feature-one.txt
  command git add feature-one.txt
  command git commit -q -m "feature one"

  local feature_one_head
  feature_one_head=$(command git rev-parse HEAD)

  git_wt::cmd::create feature-two >/dev/null 2>&1 \
    || fail "create from feature worktree failed"

  [[ -d "$wt_root/feature-two" ]] || fail "create did not create sibling worktree"

  local branch
  branch=$(command git -C "$wt_root/feature-two" branch --show-current)
  assert_eq "feature-two" "$branch" "new worktree branch name"

  command git -C "$wt_root/feature-two" merge-base --is-ancestor "$feature_one_head" HEAD \
    || fail "feature-two did not start from current worktree HEAD"

  local inherited_contents
  inherited_contents=$(<"$wt_root/feature-two/feature-one.txt")
  assert_eq "feature-one only" "$inherited_contents" "inherited feature worktree file"
}

test_create_from_worktree_uses_current_head

print -r -- "ok create-from-worktree"

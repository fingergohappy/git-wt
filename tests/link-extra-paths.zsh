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

assert_symlink() {
  local link=$1
  local target=$2
  local message=$3

  [[ -L $link ]] || fail "${message}: not a symlink: ${link}"

  local actual
  actual=$(readlink -- "$link")
  assert_eq "${target:a}" "$actual" "$message"
}

tmp_dir=$(mktemp -d)
trap 'rm -rf "$tmp_dir"' EXIT INT TERM

setup_repo() {
  local repo=$1
  command mkdir -p -- "$repo"
  repo=${repo:A}
  command git -C "$repo" init -q
  command git -C "$repo" config user.email test@example.com
  command git -C "$repo" config user.name Test
  print -r -- "initial" > "$repo/file.txt"
  print -r -- ".env" > "$repo/.gitignore"
  print -r -- ".claude/" >> "$repo/.gitignore"
  print -r -- ".vscode/settings.json" >> "$repo/.gitignore"
  command git -C "$repo" add file.txt .gitignore
  command git -C "$repo" commit -q -m init

  local wt_root="${repo:h}/.${repo:t}-wrktrees"
  command mkdir -p -- "$wt_root"
  print -r -- "*" >| "$wt_root/.gitignore"

  print -r -- "$repo"
}

test_link_ignored_file_from_project_root() {
  local repo
  repo=$(setup_repo "$tmp_dir/link-file/repo")
  print -r -- "SECRET=1" > "$repo/.env"

  builtin cd -- "$repo"
  local GIT_WT_LINK=".env"

  git_wt::cmd::create feature-one >/dev/null 2>&1 \
    || fail "create with GIT_WT_LINK=.env failed"

  local dest="${repo:h}/.repo-wrktrees/feature-one/.env"
  assert_symlink "$dest" "$repo/.env" "ignored file symlink"
  assert_eq "SECRET=1" "$(<$dest)" "ignored file contents via symlink"
}

test_link_from_project_root_when_missing_in_current_worktree() {
  local repo
  repo=$(setup_repo "$tmp_dir/link-fallback/repo")
  print -r -- "SECRET=2" > "$repo/.env"

  builtin cd -- "$repo"
  git_wt::cmd::create feature-one >/dev/null 2>&1 \
    || fail "create feature-one failed"

  local feature_one="${repo:h}/.repo-wrktrees/feature-one"
  [[ ! -e $feature_one/.env ]] || fail "feature-one unexpectedly has .env"

  builtin cd -- "$feature_one"
  local GIT_WT_LINK=".env"
  git_wt::cmd::create feature-two >/dev/null 2>&1 \
    || fail "create feature-two from worktree failed"

  local dest="${repo:h}/.repo-wrktrees/feature-two/.env"
  assert_symlink "$dest" "$repo/.env" "fallback to project root when missing in current worktree"
}

test_link_directory() {
  local repo
  repo=$(setup_repo "$tmp_dir/link-dir/repo")
  command mkdir -p -- "$repo/.claude"
  print -r -- '{"model":"opus"}' > "$repo/.claude/settings.json"

  builtin cd -- "$repo"
  local GIT_WT_LINK=".claude"

  git_wt::cmd::create feature-one >/dev/null 2>&1 \
    || fail "create with GIT_WT_LINK=.claude failed"

  local dest="${repo:h}/.repo-wrktrees/feature-one/.claude"
  assert_symlink "$dest" "$repo/.claude" "ignored directory symlink"
  assert_eq '{"model":"opus"}' "$(<$dest/settings.json)" "directory contents via symlink"
}

test_link_nested_and_absolute_outside_paths() {
  local repo
  repo=$(setup_repo "$tmp_dir/link-nested/repo")
  command mkdir -p -- "$repo/.vscode"
  print -r -- '{"tabSize":2}' > "$repo/.vscode/settings.json"

  local outside="$tmp_dir/link-nested/shared.txt"
  print -r -- "shared" > "$outside"

  builtin cd -- "$repo"
  local GIT_WT_LINK=".vscode/settings.json,$outside"

  git_wt::cmd::create feature-one >/dev/null 2>&1 \
    || fail "create with nested and absolute GIT_WT_LINK failed"

  local wt="${repo:h}/.repo-wrktrees/feature-one"
  assert_symlink "$wt/.vscode/settings.json" "$repo/.vscode/settings.json" "nested ignored file symlink"
  assert_symlink "$wt/shared.txt" "$outside" "absolute path outside worktree"
}

test_skip_missing_and_do_not_overwrite() {
  local repo
  repo=$(setup_repo "$tmp_dir/link-skip/repo")

  builtin cd -- "$repo"
  local GIT_WT_LINK=".env,file.txt,does-not-exist"

  git_wt::cmd::create feature-one >/dev/null 2>&1 \
    || fail "create should skip missing link sources"

  local wt="${repo:h}/.repo-wrktrees/feature-one"
  [[ ! -e $wt/.env ]] || fail "missing .env should not be created"
  [[ ! -L $wt/file.txt ]] || fail "tracked file.txt should not be replaced with a symlink"
  [[ -f $wt/file.txt ]] || fail "tracked file.txt should remain a regular file"
}

test_link_glob_multiple_files() {
  local repo
  repo=$(setup_repo "$tmp_dir/link-glob-files/repo")
  print -r -- "SECRET=1" > "$repo/.env"
  print -r -- "SECRET=2" > "$repo/.env.local"

  builtin cd -- "$repo"
  local GIT_WT_LINK=".env*"

  git_wt::cmd::create feature-one >/dev/null 2>&1 \
    || fail "create with GIT_WT_LINK=.env* failed"

  local wt="${repo:h}/.repo-wrktrees/feature-one"
  assert_symlink "$wt/.env" "$repo/.env" "glob matched .env"
  assert_symlink "$wt/.env.local" "$repo/.env.local" "glob matched .env.local"
}

test_link_glob_nested_and_recursive() {
  local repo
  repo=$(setup_repo "$tmp_dir/link-glob-nested/repo")
  command mkdir -p -- "$repo/.vscode" "$repo/secrets/a"
  print -r -- '{"tabSize":2}' > "$repo/.vscode/settings.json"
  print -r -- '{"keys":[]}' > "$repo/.vscode/keybindings.json"
  print -r -- "hidden" > "$repo/secrets/a/.secret"
  print -r -- "secrets/" >> "$repo/.gitignore"

  builtin cd -- "$repo"
  local GIT_WT_LINK=".vscode/*,**/.secret"

  git_wt::cmd::create feature-one >/dev/null 2>&1 \
    || fail "create with nested and recursive GIT_WT_LINK globs failed"

  local wt="${repo:h}/.repo-wrktrees/feature-one"
  assert_symlink "$wt/.vscode/settings.json" "$repo/.vscode/settings.json" "nested glob settings.json"
  assert_symlink "$wt/.vscode/keybindings.json" "$repo/.vscode/keybindings.json" "nested glob keybindings.json"
  assert_symlink "$wt/secrets/a/.secret" "$repo/secrets/a/.secret" "recursive glob .secret"
}

test_link_glob_prefers_current_then_project_root() {
  local repo
  repo=$(setup_repo "$tmp_dir/link-glob-fallback/repo")
  print -r -- "ROOT=1" > "$repo/.env"
  print -r -- "ROOT_LOCAL=1" > "$repo/.env.local"

  builtin cd -- "$repo"
  git_wt::cmd::create feature-one >/dev/null 2>&1 \
    || fail "create feature-one failed"

  local feature_one="${repo:h}/.repo-wrktrees/feature-one"
  print -r -- "WT_LOCAL=1" > "$feature_one/.env.local"

  builtin cd -- "$feature_one"
  local GIT_WT_LINK=".env*"
  git_wt::cmd::create feature-two >/dev/null 2>&1 \
    || fail "create feature-two from worktree with glob failed"

  local wt="${repo:h}/.repo-wrktrees/feature-two"
  assert_symlink "$wt/.env" "$repo/.env" "glob fallback .env from project root"
  assert_symlink "$wt/.env.local" "$feature_one/.env.local" "glob prefers current worktree .env.local"
}

test_link_glob_absolute_and_unmatched() {
  local repo
  repo=$(setup_repo "$tmp_dir/link-glob-abs/repo")

  local outside_dir="$tmp_dir/link-glob-abs/shared"
  command mkdir -p -- "$outside_dir"
  print -r -- "a" > "$outside_dir/a.txt"
  print -r -- "b" > "$outside_dir/b.txt"
  print -r -- "nope" > "$outside_dir/c.md"

  builtin cd -- "$repo"
  local GIT_WT_LINK="$outside_dir/*.txt,no-such*"

  git_wt::cmd::create feature-one >/dev/null 2>&1 \
    || fail "create with absolute glob should skip unmatched patterns"

  local wt="${repo:h}/.repo-wrktrees/feature-one"
  assert_symlink "$wt/a.txt" "$outside_dir/a.txt" "absolute glob a.txt"
  assert_symlink "$wt/b.txt" "$outside_dir/b.txt" "absolute glob b.txt"
  [[ ! -e $wt/c.md ]] || fail "absolute glob should not match c.md"
  [[ ! -L $wt/file.txt ]] || fail "unmatched glob should not replace tracked file.txt"
}

test_link_ignored_file_from_project_root
test_link_from_project_root_when_missing_in_current_worktree
test_link_directory
test_link_nested_and_absolute_outside_paths
test_skip_missing_and_do_not_overwrite
test_link_glob_multiple_files
test_link_glob_nested_and_recursive
test_link_glob_prefers_current_then_project_root
test_link_glob_absolute_and_unmatched

print -r -- "ok link-extra-paths"

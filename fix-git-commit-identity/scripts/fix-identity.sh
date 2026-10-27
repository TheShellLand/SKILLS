#!/usr/bin/env bash
set -euo pipefail
fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }
usage() {
  printf '%s\n' 'Usage: bash fix-identity.sh [--commit REV] [--name NAME --email EMAIL] [--role author|committer|both] [--message-file FILE] [--apply]' 'Defaults to HEAD. Rebuilds descendants of the selected commit, preserving merge topology.' 'Without --apply, previews without writing objects or refs.'
}
name= email= role=both message= apply=false revision=HEAD
while [ "$#" -gt 0 ]; do
  case "$1" in
    --name|--email|--role|--message-file|--commit)
      [ "$#" -ge 2 ] || fail "Missing value for $1"
      case "$1" in
        --name) name=$2 ;; --email) email=$2 ;; --role) role=$2 ;; --message-file) message=$2 ;; --commit) revision=$2 ;;
      esac
      shift 2 ;;
    --apply) apply=true; shift ;;
    --help|-h) usage; exit 0 ;;
    *) fail "Unknown argument: $1" ;;
  esac
done
case "$role" in author|committer|both) ;; *) fail 'Role must be author, committer, or both' ;; esac
if [ -n "$name$email" ]; then
  [ -n "$name" ] && [ -n "$email" ] || fail 'Supply both --name and --email'
  case "$name$email" in *'<'*|*'>'*|*$'\n'*|*$'\r'*) fail 'Identity contains forbidden characters' ;; esac
else
  [ -n "$message" ] || fail 'Supply name/email or a replacement message file'
fi
[ -z "$message" ] || [ -s "$message" ] || fail 'Message file is missing or empty'
export GIT_NO_REPLACE_OBJECTS=1
branch=$(git symbolic-ref -q HEAD) || fail 'Detached HEAD is unsupported'
old=$(git rev-parse --verify HEAD)
target=$(git rev-parse --verify --end-of-options "$revision^{commit}") || fail 'Target must resolve to one commit'
git merge-base --is-ancestor "$target" "$old" || fail 'Target must be an ancestor of HEAD'
[ "$(git rev-parse --is-shallow-repository)" = false ] || fail 'Shallow history is unsupported'
[ -z "$(git status --porcelain --untracked-files=all)" ] || fail 'Index and worktree must be clean'
for state in rebase-merge rebase-apply MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD sequencer BISECT_LOG; do
  [ ! -e "$(git rev-parse --git-path "$state")" ] || fail "Operation in progress: $state"
done
# Only descendants of the target need rebuilding; side branches retain their original objects.
descendants=$(git rev-list --reverse --topo-order --ancestry-path "$target..$old")
commits="$target${descendants:+ $descendants}"
for commit in $commits; do
  headers=$(git cat-file commit "$commit" | sed '/^$/,$d')
  if printf '%s\n' "$headers" | LC_ALL=C grep -Ev '^(tree |parent |author |committer |$)' >/dev/null; then
    fail "Signed commits or extra headers are unsupported: $commit"
  fi
done
printf 'Target: %s\nBranch tip: %s\nRole: %s\n' "$target" "$old" "$role"
[ -z "$name" ] || printf 'Requested identity: %s <%s>\n' "$name" "$email"
printf 'Affected commits (target first):\n%s\n' "$commits"
[ -z "$message" ] || printf 'Replacement message: %s\n' "$message"
if ! "$apply"; then printf '%s\n' 'Preview only; add --apply to perform this correction.'; exit 0; fi
tmp=$(mktemp -d "${TMPDIR:-/tmp}/fix-identity.XXXXXXXX")
trap 'rm -rf "$tmp"' EXIT
: > "$tmp/map"
for commit in $commits; do
  an=$(git show -s --format=%an "$commit"); ae=$(git show -s --format=%ae "$commit")
  cn=$(git show -s --format=%cn "$commit"); ce=$(git show -s --format=%ce "$commit")
  ad=$(git show -s --date=raw --format=%ad "$commit")
  cd=$(git show -s --date=raw --format=%cd "$commit")
  if [ "$commit" = "$target" ] && [ -n "$name" ]; then
    case "$role" in author|both) an=$name; ae=$email ;; esac
    case "$role" in committer|both) cn=$name; ce=$email ;; esac
  fi
  git cat-file commit "$commit" | sed '1,/^$/d' > "$tmp/message"
  if [ "$commit" = "$target" ] && [ -n "$message" ]; then cp "$message" "$tmp/message"; fi
  tree=$(git show -s --format=%T "$commit")
  parents=$(git show -s --format=%P "$commit")
  args=("$tree")
  mapped_parents=()
  for parent in $parents; do
    mapped=$(awk -v id="$parent" '$1 == id { print $2 }' "$tmp/map")
    mapped=${mapped:-$parent}
    mapped_parents+=("$mapped")
    args+=(-p "$mapped")
  done
  new=$(GIT_AUTHOR_NAME="$an" GIT_AUTHOR_EMAIL="$ae" GIT_AUTHOR_DATE="$ad" GIT_COMMITTER_NAME="$cn" GIT_COMMITTER_EMAIL="$ce" GIT_COMMITTER_DATE="$cd" git -c commit.gpgSign=false commit-tree "${args[@]}" -F "$tmp/message")
  git cat-file commit "$new" | sed '1,/^$/d' > "$tmp/stored-message"
  cmp -s "$tmp/message" "$tmp/stored-message" || fail 'Message verification failed; branch unchanged'
  # Bash 3.2 with nounset needs a guarded expansion for an empty root-parent array.
  mapped_parent_text=${mapped_parents[*]-}
  expected=$(printf '%s\n' "$tree" "$mapped_parent_text" "$an" "$ae" "$cn" "$ce" "$ad" "$cd")
  actual=$(git show -s --date=raw --format='%T%n%P%n%an%n%ae%n%cn%n%ce%n%ad%n%cd' "$new")
  [ "$expected" = "$actual" ] || fail 'Metadata verification failed; branch unchanged'
  printf '%s %s\n' "$commit" "$new" >> "$tmp/map"
done
new=$(awk -v id="$old" '$1 == id { print $2 }' "$tmp/map")
[ -n "$new" ] || fail 'Missing rewritten branch tip; branch unchanged'
[ "$(git symbolic-ref -q HEAD)" = "$branch" ] || fail 'Branch changed concurrently'
[ -z "$(git status --porcelain --untracked-files=all)" ] || fail 'Worktree changed concurrently'
backup="refs/backups/fix-identity/$(date +%Y%m%dT%H%M%S)-$$"
git update-ref "$backup" "$old" ''
git update-ref -m 'fix commit identity' "$branch" "$new" "$old"
printf 'Old: %s\nNew: %s\nBackup: %s\n' "$old" "$new" "$backup"
printf 'Old-to-new commit IDs:\n'
cat "$tmp/map"

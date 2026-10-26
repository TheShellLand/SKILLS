#!/usr/bin/env bash
set -euo pipefail
fail() { printf 'Error: %s\n' "$*" >&2; exit 1; }
usage() {
  printf '%s\n' 'Usage: bash fix-identity.sh [--name NAME --email EMAIL] [--role author|committer|both] [--message-file FILE] [--apply]' 'Repairs HEAD only. Without --apply, previews without writing objects or refs.'
}
name= email= role=both message= apply=false
while [ "$#" -gt 0 ]; do
  case "$1" in
    --name|--email|--role|--message-file)
      [ "$#" -ge 2 ] || fail "Missing value for $1"
      case "$1" in
        --name) name=$2 ;; --email) email=$2 ;; --role) role=$2 ;; --message-file) message=$2 ;;
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
[ -z "$(git status --porcelain --untracked-files=all)" ] || fail 'Index and worktree must be clean'
for state in rebase-merge rebase-apply MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD sequencer BISECT_LOG; do
  [ ! -e "$(git rev-parse --git-path "$state")" ] || fail "Operation in progress: $state"
done
headers=$(git cat-file commit "$old" | sed '/^$/q')
if printf '%s\n' "$headers" | LC_ALL=C grep -Ev '^(tree |parent |author |committer |$)' >/dev/null; then
  fail 'Signed commits or extra headers are unsupported'
fi
an=$(git show -s --format=%an "$old"); ae=$(git show -s --format=%ae "$old")
cn=$(git show -s --format=%cn "$old"); ce=$(git show -s --format=%ce "$old")
ad=$(git show -s --date=raw --format=%ad "$old")
cd=$(git show -s --date=raw --format=%cd "$old")
if [ -n "$name" ]; then
  case "$role" in author|both) an=$name; ae=$email ;; esac
  case "$role" in committer|both) cn=$name; ce=$email ;; esac
fi
printf 'Commit: %s\nAuthor: %s <%s>\nCommitter: %s <%s>\n' "$old" "$an" "$ae" "$cn" "$ce"
[ -z "$message" ] || printf 'Replacement message: %s\n' "$message"
if ! "$apply"; then printf '%s\n' 'Preview only; add --apply to perform this correction.'; exit 0; fi
tmp=$(mktemp -d "${TMPDIR:-/tmp}/fix-identity.XXXXXXXX")
trap 'rm -rf "$tmp"' EXIT
git cat-file commit "$old" | sed '1,/^$/d' > "$tmp/message"
[ -z "$message" ] || cp "$message" "$tmp/message"
tree=$(git show -s --format=%T "$old")
parents=$(git show -s --format=%P "$old")
args=("$tree")
for parent in $parents; do args+=(-p "$parent"); done
new=$(GIT_AUTHOR_NAME="$an" GIT_AUTHOR_EMAIL="$ae" GIT_AUTHOR_DATE="$ad" GIT_COMMITTER_NAME="$cn" GIT_COMMITTER_EMAIL="$ce" GIT_COMMITTER_DATE="$cd" git -c commit.gpgSign=false commit-tree "${args[@]}" -F "$tmp/message")
git cat-file commit "$new" | sed '1,/^$/d' > "$tmp/stored-message"
cmp -s "$tmp/message" "$tmp/stored-message" || fail 'Message verification failed; branch unchanged'
expected=$(printf '%s\n' "$tree" "$parents" "$an" "$ae" "$cn" "$ce" "$ad" "$cd")
actual=$(git show -s --date=raw --format='%T%n%P%n%an%n%ae%n%cn%n%ce%n%ad%n%cd' "$new")
[ "$expected" = "$actual" ] || fail 'Metadata verification failed; branch unchanged'
[ "$(git symbolic-ref -q HEAD)" = "$branch" ] || fail 'Branch changed concurrently'
[ -z "$(git status --porcelain --untracked-files=all)" ] || fail 'Worktree changed concurrently'
backup="refs/backups/fix-identity/$(date +%Y%m%dT%H%M%S)-$$"
git update-ref "$backup" "$old" ''
git update-ref -m 'fix commit identity' "$branch" "$new" "$old"
printf 'Old: %s\nNew: %s\nBackup: %s\n' "$old" "$new" "$backup"

#!/usr/bin/env bash
set -euo pipefail
helper=$(cd "$(dirname "$0")" && pwd)/fix-identity.sh
tmp=$(mktemp -d "${TMPDIR:-/tmp}/test-identity.XXXXXXXX")
trap 'rm -rf "$tmp"' EXIT
git init -q "$tmp/repo"
cd "$tmp/repo"
git config user.name 'Old Name'
git config user.email old@example.com
git -c commit.gpgSign=false commit --allow-empty -qm 'Keep this message'
old=$(git rev-parse HEAD)
bash "$helper" --name 'New Name' --email new@example.com > "$tmp/preview"
[ "$(git rev-parse HEAD)" = "$old" ]
[ -z "$(git for-each-ref refs/backups/)" ]
bash "$helper" --name 'New Name' --email new@example.com --role author --apply
[ "$(git show -s --format='%an <%ae>' HEAD)" = 'New Name <new@example.com>' ]
[ "$(git show -s --format='%cn <%ce>' HEAD)" = 'Old Name <old@example.com>' ]
[ "$(git show -s --format=%T HEAD)" = "$(git show -s --format=%T "$old")" ]
[ "$(git show -s --format=%B HEAD)" = 'Keep this message' ]
printf '%s\n' 'Keep this message' '' 'Co-authored-by: New Name <new@example.com>' > "$tmp/message"
bash "$helper" --message-file "$tmp/message" --apply
git cat-file commit HEAD | sed '1,/^$/d' > "$tmp/actual"
cmp "$tmp/message" "$tmp/actual"
bash "$helper" --name 'Both Name' --email both@example.com --apply
[ "$(git show -s --format='%an %ae %cn %ce' HEAD)" = 'Both Name both@example.com Both Name both@example.com' ]
before=$(git rev-parse HEAD)
printf '%s\n' dirty > dirty
if bash "$helper" --name X --email x@example.com --apply > "$tmp/error" 2>&1; then exit 1; fi
[ "$(git rev-parse HEAD)" = "$before" ]
rm dirty
# Older root with two descendants: preserve each descendant's metadata, message, tree and dates.
root=$(git rev-parse HEAD)
printf '%s\n' first > content
git add content
git -c commit.gpgSign=false commit -qm 'First descendant'
printf '%s\n' second >> content
git add content
git -c commit.gpgSign=false commit -qm 'Second descendant'
tip=$(git rev-parse HEAD)
git show -s --date=raw --format='%T%n%an%n%ae%n%cn%n%ce%n%ad%n%cd%n%B' HEAD > "$tmp/tip-metadata"
git show -s --date=raw --format='%T%n%an%n%ae%n%cn%n%ce%n%ad%n%cd%n%B' HEAD~1 > "$tmp/middle-metadata"
bash "$helper" --commit "$root" --name 'Root Name' --email root@example.com --role committer > "$tmp/preview"
[ "$(git rev-parse HEAD)" = "$tip" ]
bash "$helper" --commit "$root" --name 'Root Name' --email root@example.com --role committer --apply > "$tmp/result"
[ "$(git show -s --format=%ce HEAD~2)" = root@example.com ]
[ "$(git show -s --format=%ae HEAD~2)" = both@example.com ]
[ "$(git rev-parse HEAD)" != "$tip" ]
git show -s --date=raw --format='%T%n%an%n%ae%n%cn%n%ce%n%ad%n%cd%n%B' HEAD > "$tmp/new-tip"
git show -s --date=raw --format='%T%n%an%n%ae%n%cn%n%ce%n%ad%n%cd%n%B' HEAD~1 > "$tmp/new-middle"
cmp "$tmp/tip-metadata" "$tmp/new-tip"
cmp "$tmp/middle-metadata" "$tmp/new-middle"
git for-each-ref --format='%(objectname)' refs/backups/ | grep -qx "$tip"
# Change a non-root commit with a descendant, replacing only its message.
bash "$helper" --commit HEAD~1 --message-file "$tmp/message" --apply > "$tmp/result"
git cat-file commit HEAD~1 | sed '1,/^$/d' > "$tmp/actual"
cmp "$tmp/message" "$tmp/actual"
git show -s --date=raw --format='%T%n%an%n%ae%n%cn%n%ce%n%ad%n%cd%n%B' HEAD > "$tmp/new-tip"
cmp "$tmp/tip-metadata" "$tmp/new-tip"
# Merge graph: rebuild only the target's side and merge, retaining the other parent's object.
base=$(git rev-parse HEAD)
git checkout -qb side
git -c commit.gpgSign=false commit --allow-empty -qm 'Side target'
side=$(git rev-parse HEAD)
git checkout -qb other "$base"
git -c commit.gpgSign=false commit --allow-empty -qm 'Other side'
other=$(git rev-parse HEAD)
git -c commit.gpgSign=false merge --no-ff -m 'Keep merge resolution' side > "$tmp/merge"
merge=$(git rev-parse HEAD)
bash "$helper" --commit "$side" --name 'Side Name' --email side@example.com --apply > "$tmp/result"
[ "$(git rev-parse HEAD^1)" = "$other" ]
[ "$(git show -s --format=%ae HEAD^2)" = side@example.com ]
[ "$(git rev-parse side)" = "$side" ]
[ "$(git show -s --format=%T HEAD)" = "$(git show -s --format=%T "$merge")" ]
[ "$(git show -s --format=%B HEAD)" = 'Keep merge resolution' ]
# A merge itself can be the selected target, with a descendant.
git -c commit.gpgSign=false commit --allow-empty -qm 'After merge'
bash "$helper" --commit HEAD^ --name 'Merge Name' --email merge@example.com --apply > "$tmp/result"
[ "$(git show -s --format=%ae HEAD^)" = merge@example.com ]
[ "$(git rev-parse HEAD^^1)" = "$other" ]
[ "$(git show -s --format=%B HEAD)" = 'After merge' ]
# A common ancestor rebuilds both sides of a merge without losing either parent.
tip_tree=$(git show -s --format=%T HEAD)
count=$(git rev-list --count HEAD)
bash "$helper" --commit "$base" --name 'Base Name' --email base@example.com --apply > "$tmp/result"
[ "$(git show -s --format=%ae HEAD^^1^)" = base@example.com ]
[ "$(git show -s --format=%ae HEAD^^2^)" = base@example.com ]
[ "$(git rev-parse HEAD^^1^)" = "$(git rev-parse HEAD^^2^)" ]
[ "$(git rev-list --count HEAD)" = "$count" ]
[ "$(git show -s --format=%T HEAD)" = "$tip_tree" ]
# Reject an unrelated target and signed/extra headers before moving the branch.
before=$(git rev-parse HEAD)
if bash "$helper" --commit "$tip" --name X --email x@example.com --apply > "$tmp/error" 2>&1; then exit 1; fi
[ "$(git rev-parse HEAD)" = "$before" ]
git cat-file commit HEAD > "$tmp/raw"
sed '/^committer /a\
encoding UTF-8
' "$tmp/raw" > "$tmp/extra"
extra=$(git hash-object -t commit -w "$tmp/extra")
git update-ref HEAD "$extra"
if bash "$helper" --commit HEAD^ --name X --email x@example.com --apply > "$tmp/error" 2>&1; then exit 1; fi
[ "$(git rev-parse HEAD)" = "$extra" ]
git update-ref HEAD "$before"
git checkout -q --detach
if bash "$helper" --name X --email x@example.com --apply > "$tmp/error" 2>&1; then exit 1; fi
printf '%s\n' 'PASS: HEAD, older root and non-root, descendants, merges, messages, backups, preview and rejection cases'

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
git checkout -q --detach
if bash "$helper" --name X --email x@example.com --apply > "$tmp/error" 2>&1; then exit 1; fi
printf '%s\n' 'PASS: preview, root/empty commit, author-only, both, exact message, dirty and detached rejection'

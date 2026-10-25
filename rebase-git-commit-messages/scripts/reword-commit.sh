#!/usr/bin/env bash
# Rewrite one commit in a linear range; run from the target repository.
set -euo pipefail
fail() { printf '%s\n' "$*" >&2; exit 1; }
[ "$#" -eq 2 ] || fail 'Usage: bash reword-commit.sh COMMIT MESSAGE_FILE'
git rev-parse --show-toplevel >/dev/null
[ -z "$(git status --porcelain)" ] || fail 'Worktree/index must be clean, including untracked files.'
for state in rebase-merge rebase-apply MERGE_HEAD CHERRY_PICK_HEAD REVERT_HEAD sequencer; do
    [ ! -e "$(git rev-parse --git-path "$state")" ] || fail "Existing operation: $state"
done
[ "$(git rev-parse --is-shallow-repository)" = false ] || fail 'Shallow repositories are not supported.'
git symbolic-ref -q HEAD >/dev/null || fail 'Check out the intended branch first.'
selected=$(git rev-parse --verify "$1^{commit}")
oldtip=$(git rev-parse HEAD)
git merge-base --is-ancestor "$selected" HEAD || fail 'Selected commit is not an ancestor of HEAD.'
[ -f "$2" ] || fail 'Message file does not exist.'
export REWORD_TMP
REWORD_TMP=$(mktemp -d "${TMPDIR:-/tmp}/reword-commit.XXXXXXXX")
# Keep files on failure for diagnosis; remove them only after verification.
printf 'Recovery files: %s\n' "$REWORD_TMP"
git stripspace < "$2" > "$REWORD_TMP/message"
[ -s "$REWORD_TMP/message" ] || fail 'Replacement message must not be empty.'
base=$(git rev-parse --verify "$selected^" 2>/dev/null || true)
if [ -n "$base" ]; then
    range="$base..$oldtip"
else
    range="$oldtip"
fi
[ -z "$(git rev-list --merges "$range")" ] || fail 'Merge history requires the merge workflow in SKILL.md.'
git rev-list --reverse "$range" > "$REWORD_TMP/old-ids"
backup="refs/backup/reword-$(basename "$REWORD_TMP")"
git update-ref "$backup" "$oldtip" ''
printf 'Backup: %s (%s)\n' "$backup" "$oldtip"
while IFS= read -r oid; do
    printf 'pick %s\n' "$oid"
    if [ "$oid" = "$selected" ]; then
        printf '%s\n' 'exec git commit --amend --only --allow-empty --cleanup=verbatim -F "$REWORD_TMP/message"'
    fi
done < "$REWORD_TMP/old-ids" > "$REWORD_TMP/todo"
cat > "$REWORD_TMP/editor" <<'EDITOR'
#!/bin/sh
set -eu
cp "$REWORD_TMP/todo" "$1"
EDITOR
export GIT_SEQUENCE_EDITOR='sh "$REWORD_TMP/editor"'
export GIT_EDITOR=true GIT_TERMINAL_PROMPT=0
if [ -n "$base" ]; then
    start=("$base")
else
    start=(--root)
fi
if ! git -c rebase.autoStash=false rebase -i --no-rebase-merges --keep-empty --empty=keep \
    --no-autosquash --no-update-refs "${start[@]}"; then
    if [ -d "$(git rev-parse --git-path rebase-merge)" ]; then
        git rebase --abort || fail "Abort failed. Backup: $backup; files: $REWORD_TMP"
    fi
    fail "Rebase failed; no success claimed. Backup: $backup; files: $REWORD_TMP"
fi
newtip=$(git rev-parse HEAD)
if [ -n "$base" ]; then
    git rev-list --reverse "$base..$newtip" > "$REWORD_TMP/new-ids"
else
    git rev-list --reverse "$newtip" > "$REWORD_TMP/new-ids"
fi
[ "$(wc -l < "$REWORD_TMP/old-ids")" -eq "$(wc -l < "$REWORD_TMP/new-ids")" ] || fail 'Verification failed: commit count.'
[ -z "$(git rev-list --merges "${base:+$base..}$newtip")" ] || fail 'Verification failed: topology.'
newselected=
while read -r old new; do
    for pair in "old:$old" "new:$new"; do
        side=${pair%%:*}
        oid=${pair#*:}
        git show -s --format='%T%n%an%n%ae%n%at%n%ai' "$oid" > "$REWORD_TMP/$side-metadata"
        # Extract the raw message, avoiding pretty-format's extra newline.
        git cat-file commit "$oid" | sed '1,/^$/d' > "$REWORD_TMP/$side-message"
    done
    cmp -s "$REWORD_TMP/old-metadata" "$REWORD_TMP/new-metadata" || fail "Verification failed: tree/author for $old"
    if [ "$old" = "$selected" ]; then
        cmp -s "$REWORD_TMP/message" "$REWORD_TMP/new-message" || fail 'Verification failed: replacement message.'
        newselected=$new
    else
        cmp -s "$REWORD_TMP/old-message" "$REWORD_TMP/new-message" || fail "Verification failed: unrelated message $old"
    fi
    printf '%s -> %s\n' "$old" "$new"
done < <(paste "$REWORD_TMP/old-ids" "$REWORD_TMP/new-ids")
[ -n "$newselected" ] || fail 'Verification failed: selected commit missing.'
[ "$(git rev-parse "$oldtip^{tree}")" = "$(git rev-parse 'HEAD^{tree}')" ] || fail 'Verification failed: tip tree.'
[ -z "$(git status --porcelain)" ] || fail 'Verification failed: worktree/index changed.'
printf 'Verified message-only rewrite: %s -> %s\nBackup retained: %s\n' "$selected" "$newselected" "$backup"
rm -rf "$REWORD_TMP"

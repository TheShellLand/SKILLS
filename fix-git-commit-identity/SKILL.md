---
name: fix-git-commit-identity
description: Fix a wrong username, name, email, author, or committer on a Git commit, including requests to fix the username and email in a commit message. Prefer this skill over rebase-git-commit-messages for identity corrections. The Bash helper repairs a selected commit and preserves its descendants, including merges.
---

# Fix Git Commit Identity

Use this skill when a user asks to fix a username, name, email, author, or committer on a commit.
Creating this skill does not authorize changing the current repository's history.

## Select this workflow for identity corrections

Select by the requested correction, even when the user calls author information a "commit message".
For a username, name, or email correction, use this skill first. Inspect the stored metadata and message to
determine which contains the wrong identity; do not assume the wording requires rewording or rebasing.

| Request | Workflow |
| --- | --- |
| "Fix the username and email in the commit message" | This skill; inspect metadata and message, then correct the affected identity fields. |
| "Change the last commit's author to Correct Name <correct@example.com>" | This skill with `--role author`. |
| "Fix the email in Co-authored-by" | This skill with `--message-file`, preserving unrelated message text. |
| "Rewrite the subject to explain the bug fix" | `rebase-git-commit-messages`; this is general message rewording. |

For an identity correction, run the bundled helper rather than generating a rebase or substituting
`reword-commit.sh`. Use `--commit` for an older target. A request to reword other message
content as well as fix identity requires both workflows within their supported scope.

## Identify the correction

Inspect `git status --short`, `git log -5 --format=fuller`, and `git config --show-origin --get-regexp '^user\.'`.
A Git commit has author and committer names/emails; a hosting-service username is not a separate Git field.
Changing `user.name` or `user.email` alone does not repair existing commits.

Use the requested values exactly. If they are missing, inspect repository-local configuration and the user's
instructions; ask when the intended identity remains unclear. Never infer an email from a hosting username.
Choose `author`, `committer`, or `both` from the request; if it just says to fix the commit identity, use `both`.
The helper defaults to `both` and targets `HEAD` unless `--commit REV` selects another commit. Resolve the
requested target and inspect it with `git show -s --format=fuller REV`. It must be reachable from the current
attached branch. Never substitute HEAD for an older target. One invocation corrects one selected commit;
for multiple requested corrections, resolve later targets using each invocation's old-to-new mapping.

Names/emails written in the message, such as `Co-authored-by` or `Signed-off-by`, are separate from metadata.
For a message correction, save the complete corrected message in a UTF-8 file outside the repository and pass
`--message-file`. Preserve all unrelated text and trailers. For general rewording, use
[rebase-git-commit-messages](../rebase-git-commit-messages/SKILL.md) instead.

## Run the helper

Read [fix-identity.sh](scripts/fix-identity.sh) for its supported options. Run from the target repository with Bash.
Illustrative metadata correction:

```sh
bash '/absolute/path/to/fix-git-commit-identity/scripts/fix-identity.sh' --name 'Correct Name' --email 'correct@example.com' --role both
```

To correct an older commit, add `--commit REV`, where `REV` is the requested hash or revision (for example
`HEAD~3`). Both root commits and merge commits are supported. Preview lists every affected commit.

The default is a read-only preview. For an authorized correction, run the same command with `--apply`.
Use `--role author` or `--role committer` to change only that identity. A message-only correction needs just
`--message-file '/absolute/path/to/message.txt'`; name and email must otherwise be supplied together.

The script creates replacement commit objects for the target and its descendants, verifies each, makes a backup
ref, and updates only the current branch using the original tip as a concurrency guard. It preserves every tree,
parent order and merge topology, dates, unselected identities, and message bytes unless a replacement message
is supplied for the target. Descendant metadata and messages remain unchanged; their parent IDs are remapped.
Side branches and tags stay at their existing commits. It does not stage files, change Git configuration, run commit
hooks, or push. Repositories requiring commit hooks must use their approved workflow instead. Signed commits,
extra commit headers in the affected history, shallow clones, dirty worktrees, detached HEAD, and operations
in progress are rejected. A failure before the final branch update leaves the branch unchanged.

Check remote-tracking refs containing the target before applying; explain when published history will change.
The target and its descendants receive new IDs when the correction changes the target.
Publishing is a separate action. On failure, inspect the error and current Git state before retrying; do not
reset or abort someone else's operation. The helper prints its backup ref and old/new IDs after success.

## Verify

Inspect `git show -s --format=fuller NEW_TARGET` using the printed mapping and `git status --short`.
Report the actual identity, old/new IDs for the target and affected descendants,
and backup ref. Existing signatures cannot survive an identity rewrite; this helper refuses signed inputs.
Never claim remote commits changed after a local-only repair.

Best: correct metadata with explicit values and verify the stored author and committer.
Avoid: changing global Git configuration or replacing every matching name across history.

---
name: fix-git-commit-identity
description: Correct the author or committer name and email on the latest Git commit, or identity text in its message, using a deterministic Bash helper.
---

# Fix Git Commit Identity

Use this skill when a user asks to fix a username, name, email, author, or committer on a commit.
Creating this skill does not authorize changing the current repository's history.

## Identify the correction

Inspect `git status --short`, `git log -5 --format=fuller`, and `git config --show-origin --get-regexp '^user\.'`.
A Git commit has author and committer names/emails; a hosting-service username is not a separate Git field.
Changing `user.name` or `user.email` alone does not repair existing commits.

Use the requested values exactly. If they are missing, inspect repository-local configuration and the user's
instructions; ask when the intended identity remains unclear. Never infer an email from a hosting username.
Choose `author`, `committer`, or `both` from the request; if it just says to fix the commit identity, use `both`.
The helper defaults to `both`. It handles only the latest commit on an attached branch. For older commits or
ranges, report this limit rather than silently changing HEAD or flattening history.

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

The default is a read-only preview. For an authorized correction, run the same command with `--apply`.
Use `--role author` or `--role committer` to change only that identity. A message-only correction needs just
`--message-file '/absolute/path/to/message.txt'`; name and email must otherwise be supplied together.

The script creates a replacement commit object, verifies it, makes a backup ref, and updates the branch using
the original tip as a concurrency guard. It preserves the tree, parents, dates, unselected identity, and message
bytes unless a replacement message is supplied. It does not stage files, change Git configuration, run commit
hooks, or push. Repositories requiring commit hooks must use their approved workflow instead. Signed commits,
extra commit headers, dirty worktrees, detached HEAD, and operations in progress are rejected.

Check remote-tracking refs containing HEAD before applying; explain when published history will change.
Publishing is a separate action. On failure, inspect the error and current Git state before retrying; do not
reset or abort someone else's operation. The helper prints its backup ref and old/new IDs after success.

## Verify

Inspect `git show -s --format=fuller HEAD` and `git status --short`. Report the actual identity, old/new IDs,
and backup ref. Existing signatures cannot survive an identity rewrite; this helper refuses signed inputs.
Never claim remote commits changed after a local-only repair.

Best: correct metadata with explicit values and verify the stored author and committer.
Avoid: changing global Git configuration or replacing every matching name across history.

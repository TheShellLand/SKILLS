---
name: rebase-git-commit-messages
description: Rewrite existing Git commit messages with a scripted, non-interactive rebase. Use for rewording one or more commits while preserving their changes and order.
---

# Rebase Git Commit Messages

Rewrite only the requested messages. Creating this skill or drafting replacement messages does not authorize rewriting
the current repository. When the user requests the rewrite, carry it through within that scope without repeatedly
asking for confirmation. Publishing rewritten history is a separate action.

## Systemic Integrity Over Heuristic Shortcuts

The prescribed workflow is part of correctness. Follow every applicable requirement in this skill and the referenced
commit-message skill; general Git habits are not grounds for skipping or replacing a required step. These requirements
encode this environment's terminal constraints, message conventions, preservation checks, and recovery safeguards.
A rewrite that produces the desired subject but bypasses those requirements is not a compliant completion.

Before changing history, identify the applicable workflow and its required preparation, execution, and verification
steps. Use the bundled helper for one selected commit in a linear range; use the scripted procedure below for multiple
selected commits or merges. Do not substitute an editor-driven `git rebase -i`, a standalone `git commit --amend`, or
reset-and-recommit because it is familiar, shorter, or commonly recommended. The scripted `git rebase -i` invocation
specified below remains required where applicable.

Execute the applicable steps without asking the user to reconfirm requirements already established here. If a required
step is unsupported, fails, or conflicts with a higher-priority instruction or an explicit user override, report the
specific constraint and follow the recovery guidance; do not silently invent an alternative or claim full compliance.
Before reporting completion, check tool evidence against every applicable requirement, including message format and
history preservation. Git success alone does not establish compliance.

Best: inspect the target commit, select the required message format, run the prescribed scripted workflow, and verify
the stored message and every affected commit. Avoid: defaulting to a familiar interactive reword procedure because
the skill's multi-step workflow seems unnecessarily complex.

## Execute the Requested Work

When asked to fix or reword a commit, use the available tools to inspect, rewrite, and verify it during this task.
A proposed message, a command block, or a statement such as "I am performing a rebase" does not complete the request.
Keep progress updates brief and continue to tool execution. If execution is unavailable or blocked, state the exact
limitation and distinguish any drafted message from an applied change. Never claim a rebase ran without tool evidence.

## Inspect and Prepare

- Read the target repository's instructions and [write-git-commit-messages](../write-git-commit-messages/SKILL.md).
  Complete that skill's repository-root comparison and format selection before drafting replacements. Rewriting an
  existing message uses the same convention as creating a commit; the old message is not evidence of the required
  format. In this skill-library repository, select Format A even if the existing subject uses Conventional Commits
  or the checkout has another name, such as `brain`. Do not fall back to Format B because Git accepted the old message.
  Inspect each selected commit's full message and diff, rather than the current working-tree diff, to draft its
  replacement.
  Ground the subject and body in `git show --format=fuller <commit>` and the actual patch. Preserve exact filenames,
  directory names, and commands: `/SKILLS` is a directory, not `/SKILLS.md`. Do not invent changes, motivations, or
  synchronization behavior from the old subject alone. Write the full message as commit text, without `Subject:` or
  `Body:` labels or literal `\n` separators.
  Preserve meaningful trailers and issue references unless the request changes them.
- Inspect status, the current branch, and the commit graph. Resolve requested commits to full object IDs and identify
  the oldest selected commit and the affected descendants through `HEAD`. Ask for a missing target or ambiguous range
  only when it cannot be inferred from the request.
- Require a clean index and working tree and no existing rebase, merge, or cherry-pick in progress. Do not automatically
  stash, discard changes, or abort somebody else's operation. Report the blocking state so it can be resolved.
- Record the original tip and create a uniquely named backup ref before rewriting. Save the affected commits' trees,
  parent relationships, author identities/dates, and full messages so verification can compare old and new history.
  Keep temporary files outside the working tree until verification succeeds or recovery finishes.
- Explain that selected commits and their descendants receive new IDs. Check whether remote-tracking refs contain the
  affected commits; mention shared-history implications when relevant. Do not infer permission to push from permission
  to rewrite locally. Rewriting also invalidates existing commit signatures; follow any repository signing requirements.

## Script the Rebase

For one selected commit in a linear range, use the bundled
[reword-commit.sh](scripts/reword-commit.sh) after completing the inspection above. Run from the target repository:

```sh
message_file=$(mktemp)
cat > "$message_file" <<'MESSAGE'
[component] Describe the inspected change

Explain what the actual commit changed and why.
MESSAGE
bash /absolute/path/to/rebase-git-commit-messages/scripts/reword-commit.sh COMMIT "$message_file"
```

Replace the example text, helper path, and `COMMIT` with inspected values, then execute the command through tools.
Always invoke this helper with `bash`, even if it is executable. Do not run `./scripts/reword-commit.sh` or a bare
helper path; direct execution may fail with a shebang interpreter permission error.
The helper creates a backup, supplies the rebase todo through `GIT_SEQUENCE_EDITOR`, and amends the selected commit
through an `exec` step. It verifies each replayed tree, author, and message and prints actual old-to-new IDs.
It supports root and empty commits; it rejects dirty worktrees, existing operations, detached HEAD, shallow clones,
and merge-containing ranges. It retains hooks and repository signing settings; inspect those first if they require
interaction. It aborts its own failed rebase and retains recovery files on failure. It never pushes.
Delete the input message file after success. For multiple selected commits or merges, use the procedure below.

Use Git's interactive-rebase machinery with a scripted sequence editor so no editor or terminal interaction is needed.
For a linear range, start immediately before the oldest selected commit; use `--root` if it is the root commit.
Do not use `HEAD~N` unless the selected range actually establishes that count.
For message-only changes, keep the existing base and operate on the inspected branch through its tip. Do not use
`--onto` to guess a range: it changes the replay destination. A positional commit ID as the rebase branch argument
can leave HEAD detached. Inspect the selected range before execution rather than assuming two supplied IDs mean
exactly two commits. Do not replace the scripted rebase with reset-and-recommit as an editor workaround.

1. Write each complete replacement message into its own UTF-8 file with real line breaks. Use a file-writing tool or
   quoted heredoc so message text, backticks, and dollar signs cannot become shell code.
2. Generate a todo containing every affected commit, oldest first, as `pick <full-original-id>`. Immediately after each
   selected commit, add an `exec` command that amends the current commit from its corresponding message file:

   ```text
   pick <full-original-id> Original subject
   exec git -c core.hooksPath=/dev/null commit --amend --only --allow-empty -F '/absolute/path/to/message.txt'
   ```

   The identifiers and path above are illustrative; substitute inspected IDs and shell-quoted absolute paths.
   `--only` keeps staged changes out of the amendment and `--allow-empty` preserves intentionally empty commits.
   Disable hooks only for these message amendments, where hooks could mutate staged content; if repository policy
   requires hooks, honor it and verify they do not change content. Do not change persistent Git configuration.
3. Create a POSIX shell sequence-editor script that copies the prepared todo to the filename Git passes as `$1`.
   Quote paths for both shell layers: Git invokes the editor command through a shell, and `exec` lines are shell
   commands.
   Never interpolate replacement message text into either script.
4. Run with command-scoped editor variables, using the actual prepared editor path:

   ```sh
   GIT_SEQUENCE_EDITOR="sh <shell-quoted-editor-path>" GIT_EDITOR=true git rebase -i --keep-empty --empty=keep --no-autosquash --no-update-refs <base>
   ```

   Replace `<base>` with the parent of the oldest selected commit or `--root`. `--no-update-refs` prevents configured
   automatic updates to other branches. Explicitly disable any configured automatic stashing for this operation.
   Check locally supported options before running; do not silently drop preservation options on older Git versions.

Do not use `reword` with `GIT_EDITOR=true`: it accepts the old message without providing a replacement. Do not use a
global editor setting or an unrestricted search-and-replace across history.
Scripted editors work without an interactive terminal; lack of terminal interaction is not a reason to abandon this
procedure or change the message format selected by the commit-message skill. `GIT_REBASE_EDITING` is not a standard
Git editor control; use the documented editor variables above.

### Merge History

Inspect the entire affected range for merges. A flat `pick` list drops merge topology, so never apply it to such a
range.
Use `--rebase-merges` with a scripted editor that preserves Git's generated `label`, `reset`, and `merge` commands.
Match selected ordinary commits by their original IDs and insert the amendment after their `pick`; for selected merge
commits, insert it after their `merge -C <original-id>` command. Keep `-C` to avoid opening a merge-message editor.
Validate all selected commits matched exactly once before allowing the rebase to begin. Merge recreation can change
resolutions; compare every recreated tree and parent relationship, and abort if message-only preservation fails.

## Handle Stops and Verify

If a command fails, inspect Git's state before retrying. Do not blindly repeat the rebase, skip commits, or resolve
content conflicts as part of a message-only request. Abort the rebase started by this workflow if preservation cannot
be guaranteed, and report the reason. If an amendment failed, do not assume `rebase --continue` reruns that command;
verify and perform the intended amendment before continuing with the same command-scoped editor environment.

Avoid: `git rebase -i <base> || git commit --amend`. A rebase can fail before replay begins or stop on a conflict;
an unconditional amendment can change the wrong commit. Run recovery separately after inspecting the error,
current HEAD, and operation state. Report completion only after verification succeeds.

After success, compare the original range with the rewritten range in order. Require the same commit count, trees,
author identities/dates, and topology (mapping old parent IDs to new IDs). Require exact replacement messages for
selected commits and unchanged messages for all others. Also require the same tip tree and a clean worktree.
Committer metadata and IDs normally change. A tip-only diff is insufficient: it can hide changed intermediate commits.

Read each selected commit's stored full message with `git show -s --format=%B <new-id>` and check its subject and
required body against the selected convention. The helper verifies that Git stored the supplied replacement; it
does not decide whether that replacement follows the repository's message rules. A successful Git command or clean
`git status` proves neither message compliance nor completion of a requested correction.

Best: for this library, verify `[skills] Clarify rebase instructions and safety checks`, a blank line, and an
explanatory body in the rewritten commit. Avoid: accepting `docs(skills): clarify rebase instructions and safety
checks` because the rebase succeeded and the worktree is clean.

If verification fails after completion, retain the backup ref and report the mismatch. Restore only the history this
workflow changed, after checking for intervening work; never blindly run `reset --hard`.

Report the old-to-new IDs and subjects for rewritten messages, verification results, and the backup ref for recovery.
Obtain the new IDs from Git after completion; never infer them. If no rewrite completed, explicitly say so instead of
presenting the proposed message as the result.
Remove temporary files after successful verification, but retain the backup ref. Do not push unless authorized; when
publishing is requested, inspect the remote tip and use an explicit expected-value `--force-with-lease` for the intended
branch rather than an unconditional force push.

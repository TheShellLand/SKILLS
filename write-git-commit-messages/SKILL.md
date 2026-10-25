---
name: write-git-commit-messages
description: Write descriptive Git commit messages from the diff when preparing or making commits. Follow repository-specific conventions.
---

# Write Git Commit Messages

Inspect `git status` and the relevant diff. Describe the actual changes and why they were made. Commit only authorized
changes and preserve unrelated work.

## Choose exactly one format

The target repository is the repository receiving the commit. Identify it before choosing a format:

1. Run `git rev-parse --show-toplevel` in the directory receiving the commit to get the target repository root.
2. Run `git -C <skill-directory> rev-parse --show-toplevel`, replacing `<skill-directory>` with the actual directory
   containing this `SKILL.md`, to get the skill-library repository root. Compare resolved absolute paths.
   **If the roots match, select Format A immediately.** This file supplies the explicit convention; `AGENTS.md`
   does not need to repeat it. Skip the remaining selection steps and write the message using Format A.
3. If the roots differ, read the target repository's applicable instructions and commit guidance before selecting
   a format. Do not infer a convention from the repository's name or working directory alone.

If either root cannot be determined, inspect the available repository metadata and instructions to resolve its
identity. A failed command is not evidence that the repositories differ.

Select the first matching rule below, then stop selecting:

1. **Target is this skill-library repository:** use Format A. This skill explicitly defines its commit convention;
   do not use the Conventional Commits fallback here.
2. **Target is another repository with an explicit commit convention:** follow that repository's convention.
3. **Target is another repository with no explicit commit convention:** use Format B.

Example: if the target root is `/root/brain` and the skill-library root is `/SKILLS`, they are different repositories.
Read `/root/brain`'s applicable instructions. Use its explicit convention if present; otherwise use Format B.
If both roots are `/root/brain`, use Format A even though the directory is named `brain`.

Best: committing in `/root/brain` with this skill at `/root/brain/write-git-commit-messages/SKILL.md` means Format A.
Use `[skills] Clarify commit format selection` followed by a blank line and an explanatory body.
Avoid: selecting Format B because `/root/brain/AGENTS.md` only links to this skill. The link does not cancel this
skill's explicit Format A convention for its own repository. Do not guess conventions from an organization name
or speculate about what people usually want.

## Format A: This skill-library repository

Use a bracketed component, a descriptive primary action, a blank line, and a body explaining what changed and why:

```text
[component] Descriptive primary action

Explain exactly what changed and why.
```

Best:

```text
[skills] Standardize skill folders and metadata

Move reusable workflows into named folders with SKILL.md entrypoints
and update the library index so agents can find the relevant guidance.
```

Avoid in this repository: `docs(skills): clarify installation`. It uses Format B instead of the required Format A.

## Format B: Fallback for another repository

Use Conventional Commits: `type(scope): summary`, with optional scope. Choose the type from `feat`, `fix`, `docs`,
`refactor`, `style`, `test`, or `chore`. Aim for a summary of 50 characters or fewer; this is a recommendation,
not a hard limit. Add a body explaining why and how the change affects the system, and a footer for issue references
or breaking changes when needed.

Best: `docs(skills): clarify installation`. Avoid: `fix: update docs` for documentation-only changes.

## Check before committing

Verify that the message uses the selected format and describes the inspected diff. A short summary alone does not
establish compliance: check the format and required body too.

Pass multiline messages with actual line breaks. Prefer a message file with `git commit -F`; avoid literal `\n`
separators.

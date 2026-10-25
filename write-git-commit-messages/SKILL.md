---
name: write-git-commit-messages
description: Write descriptive Git commit messages from the diff when preparing or making commits. Follow repository-specific conventions.
---

# Write Git Commit Messages

Inspect `git status` and the relevant diff. Describe the actual changes and why they were made. Commit only authorized
changes and preserve unrelated work.

## Choose exactly one format

Select the first matching rule below, then stop selecting. The target repository is the repository receiving the
commit, not necessarily the repository where this skill is stored.

1. **Target is this skill-library repository:** use Format A. This skill explicitly defines its commit convention;
   do not use the Conventional Commits fallback here.
2. **Target is another repository with an explicit commit convention:** follow that repository's convention.
3. **Target is another repository with no explicit commit convention:** use Format B.

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

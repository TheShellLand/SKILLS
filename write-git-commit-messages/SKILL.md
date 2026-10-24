---
name: write-git-commit-messages
description: Write descriptive Git commit messages from the diff when preparing or making commits. Follow repository-specific conventions.
---

# Write Git Commit Messages

Inspect `git status` and the relevant diff. Describe the actual changes and why they were made. Commit only authorized changes and preserve unrelated work.

Use the following format in this skill-library repository. When applying this skill in another repository, follow that repository's explicit commit convention first:

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

When no repository convention is specified, use Conventional Commits: `type(scope): summary`, with optional scope. Use `feat`, `fix`, `docs`, `refactor`, `style`, `test`, or `chore` as appropriate. Aim for a summary of 50 characters or fewer; add a body explaining why and how the change affects the system, and a footer for issue references or breaking changes when needed.

Best: `docs(skills): clarify installation`. Avoid: `fix: update docs` for documentation-only changes.

Pass multiline messages with actual line breaks. Prefer a message file with `git commit -F`; avoid literal `\n` separators.

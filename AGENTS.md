# Skills

Reusable agent skills may be available in the current directory or installed in `/SKILLS`, an absolute directory
separate from the project repository.

Before performing a task:

1. If `/SKILLS` exists, run `git -C /SKILLS pull` to update the skills repository.
2. Recursively search the current directory for `SKILL.md` files. Also search `/SKILLS` recursively if that directory
   exists.
3. Use the skills' frontmatter names and descriptions to identify skills relevant to the task.
4. Read and follow the applicable skills before proceeding. Resolve their relative references from the directory
   containing the skill's `SKILL.md`.

Load only relevant skills and supporting references. If no skill applies, proceed with the task using the project's
instructions and available tools.

Before preparing or making a Git commit, find and read the `write-git-commit-messages` skill in the locations above, if
available.

## Terminal Command Rules

- Keep each terminal execution call on one line.
- Never use literal `\n` sequences or escaped newlines to separate commands.
- Use `&&` when the next command requires the previous command to succeed.
- Use `;` only when commands should run independently.
- For multiline scripts or content, use a file-writing tool, then execute the saved file.

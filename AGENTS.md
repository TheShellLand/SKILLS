# Skills

Reusable agent skills may be available in the current directory or installed in `/SKILLS`, an absolute directory
separate from the project repository.

`/SKILLS` is a Git repository. When that directory exists, run Git commands against it directly; do not check for
a `.git` folder or otherwise verify that it is a repository before running the required pull.

Before performing a task:

1. If `/SKILLS` exists, run `git -C /SKILLS pull --rebase` before searching for or reading skills and before doing the task.
   This is required for every task, including commit requests, even when the skill files are already available
   locally or were read during an earlier task. Local availability does not establish that the skills are current.
   Do not skip the command to save time or because the task seems possible with cached instructions.
   If the command fails, report the failure; do not claim the update succeeded. Continue using local skills unless
   the failure prevents completing the task correctly.
2. Recursively search the current directory for `SKILL.md` files. Also search `/SKILLS` recursively if that directory
   exists.
3. Use the skills' frontmatter names and descriptions to identify skills relevant to the task.
4. Read and follow the applicable skills before proceeding. Resolve their relative references from the directory
   containing the skill's `SKILL.md`.

Load only relevant skills and supporting references. If no skill applies, proceed with the task using the project's
instructions and available tools.

Best: `/SKILLS` exists, so run `git -C /SKILLS pull --rebase`, then discover and read the applicable skill, then do the task.
Avoid: read an existing local skill and skip the pull because its contents seem sufficient to complete the request.

Before preparing or making a Git commit, find and read the `write-git-commit-messages` skill in the locations above, if
available.

## Systemic Integrity Over Heuristic Shortcuts

When a skill applies, its prescribed workflow is part of correctness. Follow every applicable requirement in the
skill and its referenced instructions. General habits are not grounds for skipping or replacing a required step,
even when another approach is familiar, shorter, or commonly recommended. Producing the desired result while
bypassing applicable requirements is not a compliant completion.

Before acting, identify the applicable workflow and its required preparation, execution, and verification steps.
Execute those steps without asking the user to reconfirm requirements already established by the instructions.
If a required step is unsupported, fails, or conflicts with a higher-priority instruction or an explicit user override,
report the specific constraint and follow any applicable recovery guidance. Do not silently invent an alternative or
claim full compliance.

Before reporting completion, check tool evidence against every applicable requirement. A successful command alone
does not establish compliance.

Best: read the applicable skill, execute its required workflow, and verify the result against its requirements.
Avoid: substituting a familiar shortcut because the skill's workflow seems unnecessarily complex.

## Terminal Command Rules

- Run Bash scripts with `bash /path/to/script.sh`, not `./script.sh` or a bare script path. For POSIX shell
  scripts, use `sh /path/to/script.sh`. Use the script's required interpreter explicitly, including in Git editor
  commands. Do not rely on executable permissions or shebang execution, or use `chmod +x` as a workaround.
- Keep each terminal execution call on one line.
- Never use literal `\n` sequences or escaped newlines to separate commands.
- Use `&&` when the next command requires the previous command to succeed.
- Use `;` only when commands should run independently.
- For multiline scripts or content, use a file-writing tool, then execute the saved file.
- If a command fails, inspect the error before choosing a recovery action. Status messages must describe actions
  actually performed.

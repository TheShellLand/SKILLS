# Skills

Reusable agent skills may be available in the current directory or installed in `/SKILLS`, an absolute directory
separate from the project repository.

`/SKILLS` is a Git repository. When that directory exists, run Git commands against it directly; do not check for
a `.git` folder or otherwise verify that it is a repository before running the required pull.

## Required workflow for every task

Perform this preparation once at the start of every task, including requests such as "commit changes" that follow
earlier edits. It is not required before every individual tool call. A direct task request does not waive these
requirements; an explicit user override or higher-priority instruction takes precedence.

1. Select `/SKILLS` if it exists; otherwise select `/tmp/SKILLS`. If the selected directory is missing, clone
   `https://github.com/TheShellLand/SKILLS.git` into it. Run `git -C <selected-directory> pull --rebase` before
   searching for or reading skills. Reuse existing directories without checking for a `.git` folder. Treat
   references to `/SKILLS` in shared instructions as references to the selected directory.
2. Read and follow the selected directory's `AGENTS.md`. Reading this project's `AGENTS.md` alone is insufficient.
3. Recursively discover `SKILL.md` files in both the current project and the selected shared directory. These are
   the two discovery locations, not both `/SKILLS` and `/tmp/SKILLS`.
4. Inspect skill names and descriptions to identify applicable skills. Read and follow each applicable `SKILL.md`
   and its required references before executing the task. Resolve relative references from the skill's directory.
   Discovery or naming a skill alone does not satisfy this requirement.
5. Execute the task using the applicable preparation, execution, and verification steps. If no skill applies,
   proceed using the project and shared instructions.
6. Before reporting completion, verify that actual tool calls and results support compliance. A plan, acknowledgment,
   or successful task command is not evidence that prerequisite steps were performed.

For commit tasks, find, read, and follow `write-git-commit-messages`, if available, before preparing or making the
commit. Do not jump directly from "commit changes" to `git add` and `git commit`.

If a required step fails or is unsupported, report the specific failure and follow the documented recovery rules
in the applicable skill. If cloning or updating fails, report the failure and continue with available local
skills unless it prevents correct completion. If the selected directory has no `AGENTS.md`, report that and
continue using project instructions and available tools. Do not silently skip steps or claim full compliance.
Do not ask the user to reconfirm requirements already established here.

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

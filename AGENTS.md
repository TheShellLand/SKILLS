# Skills

Reusable agent skills may be available in the current directory or installed in `/SKILLS`, an absolute directory
separate from the project repository.

`/SKILLS` is a Git repository. When that directory exists, run Git commands against it directly; do not check for
a `.git` folder or otherwise verify that it is a repository before running the required pull.

## Default workflow for direct action requests

For every direct action request (a verb followed by a task), follow the full pre-flight and execution workflow
defined in all applicable `AGENTS.md` files. Skip that workflow only when the user explicitly requests a bypass using
the word `bypass`.

## Preparation is an execution gate

At session initialization and at the start of each new task, the agent MUST complete the preparation gates below
before choosing an implementation approach or executing the requested task. Read the request first only as needed
to determine scope, applicable instructions, and any explicit override. Skill discovery and instruction review
MUST precede task execution, including tasks that appear routine or follow earlier work.

Task execution MUST NOT commence until tool results establish that every preparation gate has passed or that a
documented recovery rule permits continuation. Preparation commands and reads needed to satisfy these gates are
permitted. A plan, remembered instructions, or an acknowledgment MUST NOT substitute for observed results.

These gates operate within the instruction hierarchy. Higher-priority instructions and explicit user overrides
take precedence. A bypass applies only to the workflow the user explicitly exempts; it does not waive unrelated
requirements.

## Required workflow for every task

Perform this preparation once at the start of every task, including requests such as "commit changes" that follow
earlier edits. It is not required before every individual tool call. A direct task request does not waive these
requirements; an explicit user override or higher-priority instruction takes precedence.

1. **Verify the shared path.** Check whether `/SKILLS` exists using a tool. Select it if it exists; otherwise
   select `/tmp/SKILLS` and check whether that directory exists. If the selected directory is missing, clone
   `https://github.com/TheShellLand/SKILLS.git` into it. Run `git -C <selected-directory> pull --rebase` before
   searching for or reading skills. Reuse existing directories without checking for a `.git` folder. Treat
   references to `/SKILLS` in shared instructions as references to the selected directory.
2. **Load shared instructions.** Check for and read the selected directory's `AGENTS.md`, then follow its
   applicable instructions. Reading this project's `AGENTS.md` alone MUST NOT satisfy this gate.
3. **Discover both skill locations.** Recursively discover `SKILL.md` files in both the current project and the
   selected shared directory. These are the two discovery locations, not both `/SKILLS` and `/tmp/SKILLS`.
4. **Load applicable workflows.** Inspect skill names and descriptions to identify applicable skills. Read and
   follow each applicable `SKILL.md` and its required references before executing the task. Resolve relative
   references from the skill's directory.
   Discovery or naming a skill alone does not satisfy this requirement.
5. **Release the execution gate.** Confirm that steps 1–4 have tool evidence or an allowed recovery outcome before
   executing the task. Execute the task using the applicable preparation, execution, and verification steps.
   If no skill applies, proceed using the project and shared instructions.
6. **Verify before completion.** Before reporting completion, verify that actual tool calls and results support
   compliance. A plan, acknowledgment, or successful task command is not evidence that prerequisite steps were
   performed.

For commit tasks, find, read, and follow `write-git-commit-messages`, if available, before preparing or making the
commit. Do not jump directly from "commit changes" to `git add` and `git commit`.

If a required step fails or is unsupported, report the specific failure and follow the documented recovery rules
in the applicable skill. If cloning or updating fails, report the failure and continue with available local
skills unless it prevents correct completion. If the selected directory has no `AGENTS.md`, report that and
continue using project instructions and available tools. Do not silently skip steps or claim full compliance.
Do not ask the user to reconfirm requirements already established here.

## Failure states and recovery

The following are workflow violations and failures of project integrity:

- Executing the task before the preparation gates are satisfied or a documented recovery permits continuation.
- Skipping a required path check, shared-instruction read, skill discovery location, or applicable skill reference.
- Substituting a familiar procedure for a required workflow without an applicable override.
- Reporting compliance or completion without supporting tool evidence.

If a violation is detected, stop dependent task actions, report the specific missed requirement, and complete the
missing preparation where possible. Review work already performed against the newly loaded instructions and
correct any resulting defects before continuing. Do not describe later recovery as proof that the original
execution complied.

A failed prerequisite MUST block dependent actions unless the recovery rules above or the applicable skill
explicitly permit continuation. If no permitted recovery is available, report the blocker and the information or
capability needed to resolve it. Do not silently mark an unresolved gate as passed.

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

## Script Adherence Rule

When a project or shared directory provides specialized helper scripts (e.g., in /scripts/), prioritize executing these
tools exactly as documented. Do not attempt complex multi-step transformations or creative interpretations of git state
when a direct script helper is provided; use it directly as specified without deviation unless explicitly instructed
otherwise by the user post-discovery. Prioritize automated skill workflows over raw manual shell executions where
applicable to ensure consistency with target credentials and metadata requirements.

## File Editing Rules

When editing files, use actual line breaks for paragraphs and multiline content. Never insert literal `\n` or
`\r\n` characters as substitutes for real newlines.

Use a file-editing tool for multiline changes. After editing, inspect the diff and verify that formatting is
preserved.

If you find accidental literal newline escapes in prose, replace them with actual line breaks. Preserve
intentional escapes in code, JSON, regular expressions, and examples—do not perform a blind global replacement.

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

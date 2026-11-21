# Shared Agent Instructions

## Select the shared skills directory

At the start of every task, select one shared skills directory:

1. If `/SKILLS` exists, use `/SKILLS`.
2. Otherwise, use `/tmp/SKILLS`. If it does not exist, run:

   ```sh
   git clone https://github.com/TheShellLand/SKILLS.git /tmp/SKILLS
   ```

Both paths are absolute and separate from this project. In the steps below, `<skills-directory>` means the
selected path. Treat references to `/SKILLS` in shared instructions as references to that path, including update
and discovery steps.

## Recover an incomplete temporary checkout

After a restart, `/tmp/SKILLS` may contain leftover directories, including `.git`, with essential files missing.
An existing `.git` directory alone does not establish that the checkout is usable.

1. Recover `/tmp/SKILLS` if the root `AGENTS.md` is missing or if the pull fails and
   `git -C /tmp/SKILLS rev-parse --verify 'HEAD^{commit}'` also fails. If the checkout has both a valid
   HEAD commit and its root `AGENTS.md`, keep it and handle the pull failure using the section below.
2. Create a backup directory with `mktemp -d /tmp/SKILLS-recovery.XXXXXX`. Clone
   `https://github.com/TheShellLand/SKILLS.git` into a new `checkout` subdirectory there. Verify that
   the clone has a valid HEAD commit and a readable root `AGENTS.md` before moving either checkout.
3. Move the incomplete `/tmp/SKILLS` to `previous` inside the backup directory, then move the verified
   `checkout` into `/tmp/SKILLS`. If the second move fails, restore `previous` to `/tmp/SKILLS`.
   Keep the backup and report its location. Rerun the pull before continuing the workflow.

Apply this recovery only to `/tmp/SKILLS`. For failures with `/SKILLS`, follow the failure-handling section.

## Prepare and execute each task

Perform this workflow once per task, even if instructions or skills were read during an earlier task:

1. Run `git -C <skills-directory> pull --rebase` before searching for or reading skills. For
   `/tmp/SKILLS`, apply the recovery steps above when the checkout is incomplete.
2. Read and follow the selected directory's updated `AGENTS.md` in addition to this project's instructions.
3. Recursively discover `SKILL.md` files in both the current project and the selected shared directory.
4. Inspect skill names and descriptions, then read each applicable skill and its required references before
   executing the task. Resolve relative references from the skill's directory.
5. Execute the task using the applicable preparation, execution, and verification requirements. If no skill applies,
   follow the project and shared instructions.
6. Before reporting completion, verify that actual tool calls and results support compliance with those requirements.

## Handle preparation failures

If cloning, updating, or recovery fails, report the failure and continue with available local skills unless the failure
prevents
completing the task correctly. If the selected directory's `AGENTS.md` is missing, report that and continue using
this project's instructions and available tools. Do not silently skip required steps or claim full compliance when
a requirement could not be completed.

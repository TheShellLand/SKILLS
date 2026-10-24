---
name: maintain-skills
description: Create, update, rename, or reorganize reusable agent skills and maintain this repository's skill index and cross-references.
---

# Maintain Skills

Read the existing skill and its references before changing it. Use available skill-creation guidance when creating or substantially revising a skill.

## Structure and Discovery

Give each skill its own top-level folder with a short, descriptive, lowercase, hyphenated name. Prefer an action-oriented name that identifies the workflow.

Use `SKILL.md` as the entrypoint, with YAML frontmatter containing:

- `name`: matches the folder name, uses lowercase letters, digits, and hyphens, and stays under 64 characters.
- `description`: explains the capability and when to use it.

Put optional supported metadata under `metadata`. Add scripts, references, or assets only when they serve the workflow. Preserve existing helpers and references when moving folders.

## Instruction Placement

Keep repository-wide policies and skill-routing instructions in `AGENTS.md`. Keep `SKILLS.md` as a linked index rather than duplicating procedures there. Put reusable task instructions in the relevant skill.

When a recurring workflow is learned or improved, update the corresponding skill or create a focused skill if none fits. Include concrete Best and Avoid examples when they clarify a meaningful decision. Preserve user intent, real constraints, and existing authorization boundaries.

Best: update commit-message examples in `write-git-commit-messages/SKILL.md` and link to that skill from the index. Avoid: copying the same commit rules into `AGENTS.md`, the index, and several skills.

## Renames and Verification

When renaming a skill, update the folder, frontmatter name, heading, index entry, and references together. Search for the old name and inspect any remaining uses.

Validate YAML frontmatter, folder/name agreement, supported fields, and Markdown links. Run the available skill validator when applicable. Check the diff for unintended changes and whitespace errors. Verify executable helpers if their behavior changes.

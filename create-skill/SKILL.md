---
name: create-skill
description: Turn a recurring workflow, prompt, or set of instructions into a reusable agent skill with a named folder, SKILL.md metadata, and focused task guidance. Use for new skill creation; use maintain-skills for library maintenance and existing-skill organization.
---

# Create Skill

Create a reusable skill that helps an agent perform a specific task. Preserve the user's intended behavior, output
preferences, and constraints without expanding the task or granting permission for unrelated actions.

## Identify the Workflow

Read the supplied prompt, examples, or reference files. Identify the task, when the skill should apply, the inputs it
needs, and the expected result. Ask only for missing details that materially affect the workflow; otherwise proceed with
reasonable assumptions.

Check the destination's existing skills before creating a new one. If an existing skill already covers the request,
update it rather than creating overlapping guidance. Distinguish reusable instructions from sample inputs and past
outputs.

## Create the Entrypoint

Respect the requested destination. In this repository, create a top-level skill folder and
follow [maintain-skills](../maintain-skills/SKILL.md) for library conventions. Do not install or publish the skill
elsewhere unless requested.

Choose a short, descriptive, action-oriented name using lowercase letters, digits, and single hyphens. Keep it under 64
characters. Create `skill-name/SKILL.md` with a frontmatter name matching the folder:

```markdown
---
name: summarize-meeting-notes
description: Turn meeting notes into a concise summary with decisions, action items, and unresolved questions. Use when the user requests a meeting recap.
---

# Summarize Meeting Notes

Read the supplied notes and summarize the discussion, decisions, action items,
and unresolved questions. Preserve explicit owners and dates. Mark missing
owners or deadlines as unspecified rather than inventing them.
```

Write the description for discovery: state what the skill does and when it applies. Add a boundary only when it prevents
likely confusion with another skill. Keep normal automatic selection unless the user requests explicit-only invocation.

## Write Useful Instructions

Convert one-off prompt wording into direct instructions that work across repeated requests. Include the outcome,
necessary inputs, meaningful decisions, real constraints, and output format. Describe how to handle missing information
when it affects correctness.

Assume the agent already knows general reasoning and tool use. Include task-specific guidance that changes its
decisions. Avoid generic advice, repeated policies, invented tools, and arbitrary mandatory steps.

Use concrete examples where they resolve ambiguity. Label illustrative data clearly so it cannot be mistaken for user
data. Keep instructions flexible unless a fixed procedure is necessary for correctness.

Best: preserve a user's requirement for aligned progress bars and define how missing values are displayed. Avoid:
copying a sample report's numbers into the skill as default user values.

## Add Resources Only When Needed

Keep a simple skill self-contained. Add `scripts/` for reusable deterministic operations, `references/` for substantial
conditional guidance, and `assets/` for files used in generated output. Link supporting files from the entrypoint and
explain when they are needed.

Do not create empty directories, placeholder resources, or extra documentation without a concrete use. Add optional UI
metadata only when required by the target integration or requested by the user; consult that integration's supported
schema before writing it.

## Verify and Register

Check that YAML parses, required name and description fields are present, the folder and name match, metadata fields are
supported, and referenced files exist. Remove scaffold placeholders. Use the available skill validator when applicable;
structural validation alone does not verify behavior.

Review the instructions against a representative request and a relevant edge case, such as missing input or a request
outside the intended scope. Run added or changed scripts when needed to verify their behavior. Scale verification to the
workflow's complexity and risk.

In this repository, add an entry to `README.md` and update relevant routing links without duplicating the workflow.
Review the diff and whitespace checks, then report the created path, verification performed, and any remaining
limitations.

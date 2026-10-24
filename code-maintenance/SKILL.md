---
name: code-maintenance
description: Inspect, modify, refactor, or debug repository code while checking dependencies and verifying changes.
---

# Code Maintenance

This document defines a library of standardized skills, protocols, and best practices for various tasks performed by AI agents within this project. When a task falls into one or more of these categories, follow the specified "Best" patterns and avoid the listed pitfalls.

## Navigation & Contextual Awareness

### `Context Synthesis`
**Description:** Gathering sufficient context before starting any significant modification to understand dependencies and side effects.
- **Pattern (Best):**
    1. Read documentation/README files first.
    2. Map out relevant file paths using `rg --files`.
    3. Examine directory structure for naming conventions.
    4. Trace imports/dependencies in existing code.
- **Avoid:** Jumping directly into editing a file without understanding how it interacts with other modules.

---

## Development Lifecycle

### `Code Modification Management`
**Description:** Standardized approach for applying changes to the codebase.
- **Requirement:** Always use precise replacements via the provided tools. Ensure that every change is intentional and has been verified against the original source.
- **Pattern (Best):**
    1. For small changes, identify exact line blocks matchable by `edit`.
    2. If multiple locations are changed simultaneously, batch them into one tool call.
    3. Validate only after successful completion of an edit across all files involved.
- **Avoid:** Providing contextually ambiguous edits or using "guesswork" on file contents.

### `Bug Analysis & Debugging`
**Description:** Systematic approach to identifying and resolving issues in code.
- **SOP:**
    1. Reproduce the bug with a script if possible (`bash`).
    2. Inspect logs/error messages carefully.
    3. Isolate the failing module through binary search (commenting out components).
    4. Apply fix and verify via regression testing before claiming completion.

---

## Documentation & Reporting

For commits, follow [git-commit-messages](../git-commit-messages/SKILL.md).

For harness tasks, follow [task-lifecycle](../task-lifecycle/SKILL.md) when its tools are available.

---

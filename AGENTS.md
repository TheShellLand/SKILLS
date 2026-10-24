# AGENTS.md - AI Agents Capabilities & Skill Library

This document serves as the central repository for skills, protocols, and standard operating procedures (SOPs) that guide the behavior and execution of AI agents across all projects. 

Whenever a new project begins or a new task is identified, refer to this file to ensure consistent quality, standard formatting, and correct methodology.

---

## How to Use This File
When you encounter a recurring task (e.g., "Write a git commit message", "Generate documentation", "Refactor code"), check `AGENTS.md` or `SKILLS.md`. If a specific skill is defined in either file, follow the instructions exactly as documented.

---

## Skills Reference

Refer to `SKILLS.md` for the library of skills available for use.

---


## System Evolution
When a new skill is mastered or a better way of doing something is discovered:
1. Update the corresponding section in `AGENTS.md`.
2. Update the description to include specific examples of "Best" vs "Avoid" patterns.
3. Ensure any cross-references (e.g., between Git and Documentation logic) are 
---

## Development Environment
Source ~/venv/automonisaur/bin/activate before running Python code if it exists.

## Git Tasks when commiting changes

- When executing git commands via shell, ensure multi-line messages are passed with actual line breaks (e.g., using real  multiline string blocks) rather than literal "\\n" escapes which will be rendered literally in commit logs.

- create a descriptive git commit using git diff
- use this specific format for all commits:

[component] [Descriptive primary action/sentence]

[A detailed description or paragraph explaining exactly what was changed and why.]
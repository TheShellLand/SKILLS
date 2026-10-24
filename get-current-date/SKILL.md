---
name: get-current-date
description: Get the current calendar date using Python in system local time or UTC. Use when a task needs today's date from the runtime clock.
---

# Get Current Date

Run [scripts/get_current_date.py](scripts/get_current_date.py) with the configured Python interpreter. The helper uses only the Python standard library and prints a single ISO date, `YYYY-MM-DD`.

Resolve the script path relative to this skill's directory. Follow applicable project or IDE instructions for choosing the interpreter; no package installation is needed.

- With no arguments, use the system's local timezone.
- With `--utc`, return the current UTC date.

Use the requested timezone mode. Do not assume the host's local timezone matches the user's timezone. If a named timezone is required, obtain that timezone and use a timezone-aware Python calculation instead of presenting the local or UTC date as its equivalent.

Read the actual command output and confirm successful execution before answering. Do not substitute a date from an example, conversation metadata, or memory. Report execution failure instead of guessing.

Best: return the helper's date and identify UTC when UTC was requested. Avoid: assuming UTC and local time always have the same calendar date.

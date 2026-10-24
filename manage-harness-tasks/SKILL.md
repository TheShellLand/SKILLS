---
name: manage-harness-tasks
description: Manage backlog work in a harness that exposes TaskClaim, TaskHeartbeat, and TaskUpdate. Use only when those tools are available.
---

# Manage Harness Tasks

1. Select the next authorized backlog task.
2. Claim it with `TaskClaim`.
3. Perform the work and report progress with `TaskHeartbeat` as required by the harness.
4. Record the final state and discovered dependencies with `TaskUpdate`.
5. Reference the relevant project goal in task descriptions.

Use the tools' actual schemas. If these tools are unavailable, report the limitation rather than inventing calls.

Best: record dependencies and completion evidence. Avoid: marking unfinished work complete.

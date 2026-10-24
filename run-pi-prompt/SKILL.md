---
name: run-pi-prompt
description: Run one noninteractive prompt with the pi coding agent and return its output. Use when the user requests a single pi run.
metadata:
  version: '1.0.0'
  author: Eric
  tags: 'agent, pi'
---

# Run Pi Prompt

Execute the requested prompt in print mode:

```sh
pi -p 'PROMPT GOES HERE'
```

Replace the example with the actual task and quote it safely for the shell. Include relevant file paths and constraints. Keep requested changes within the user's authorized scope.

Inspect the output and exit status, then report the result or failure. Do not assume the output is a Docker container identifier.

Best: `pi -p 'Summarize AGENTS.md without changing files.'` for a summary request. Avoid: launching an interactive session for a single prompt.

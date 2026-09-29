---
name: pi-once
description: run a single prompt in pi agent, that exits after it is finished running
version: 1.0.0
author: Eric
tags: [agent, pi]
---

# run pi once

## Procedure
1. execute the shell:

```shell
pi -p "PROMPT GOES HERE"
```

2. you will receive a string which is hte docker container you just executed. 

## Examples
*User:* "Can you run pi agent once on the file AGENTS.md?"
*Action:* Invoke `pi-once` on `AGENTS.md`.


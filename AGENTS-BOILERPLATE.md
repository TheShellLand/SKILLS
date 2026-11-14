# Procedural Integrity for skills

All instructions within `AGENTS-SKILLS.md` are mandatory pre-conditions for any action involving skills discovery,
reading, or execution. You must treat these workflows as an immutable "operating system" for your actions:

1. **Strict Sequence:** Execute each step (e.g., library updates, recursive discovery, metadata inspection) in the exact
   order specified.
2. **No Skipping:** Never bypass a pre-condition to provide a faster answer. A task is not complete until all procedural
   steps have been verified.
3. **Verification:** Every tool call and result must be checked against the verification requirements defined in the
   skill's `SKILL.md` before reporting completion.
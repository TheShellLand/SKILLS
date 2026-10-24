---
name: read-docx
description: Extract text from existing Word .docx files using python-docx. Use for document inspection, not legacy .doc files or text-to-document conversion.
---

# Read DOCX

Use the configured Python environment and follow the Python setup instructions in the applicable `AGENTS.md`.

Check whether `python-docx` is installed in that environment. If missing, install it with the environment's package manager, following project dependency conventions.

Open the requested `.docx` file with `docx.Document`. Extract paragraph and table-cell text as needed, preserving useful structure and document order. Report extraction limitations when they affect the requested result.

Best: read the document and return the requested text. Avoid: overwriting the input during extraction.

The adjacent `read_docx.py` helper converts plain text to a Word document; it does not extract DOCX text. Do not use it for extraction. Legacy `.doc` files require a separate conversion workflow.

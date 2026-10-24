---
name: create-docx-from-text
description: Convert UTF-8 plain text into a Word .docx document using the bundled python-docx helpers. Use for text-to-document creation, not extracting existing DOCX files or converting legacy Word documents.
---

# Create DOCX from Text

Use the configured Python environment with `python-docx` installed, following the project's dependency conventions. Confirm the source is UTF-8 plain text and identify the intended output path.

## Bundled Helpers

- [scripts/convert_text_to_docx.py](scripts/convert_text_to_docx.py): the former root `read_docx.py` helper. Its effective `main` reads plain text and creates one Word paragraph per input line.
- [scripts/convert_text_to_docx_alternate.py](scripts/convert_text_to_docx_alternate.py): the former `read-docx/read_docx.py` helper, with similar conversion behavior and different filename handling.

These are preserved existing implementations, not DOCX readers. Prefer the first helper for ordinary conversion; use the alternate only when its filename behavior is specifically needed. Both accept one source-path argument and derive the destination instead of accepting an explicit output path.

Before execution, inspect the selected helper's destination logic. Supply a plain-text source with a distinct, nonexisting derived `.docx` destination. Do not pass `.doc` or `.docx` input: the helpers attempt to read it as text and may select the input itself as the destination. Never overwrite an existing input or output without authorization.

Run the selected helper with the configured Python executable, the resolved script path, and a safely quoted source path. Verify that the expected document was created and that its paragraph content matches the text. Errors may be printed without a nonzero exit status, so confirm the artifact rather than relying on exit status alone.

Best: convert `notes.txt` to a new `notes.docx` while retaining the original text. Avoid: passing an existing Word document to a helper that reads UTF-8 text.

For extracting existing Word documents, use [read-docx](../read-docx/SKILL.md).

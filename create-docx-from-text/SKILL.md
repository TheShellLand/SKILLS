---
name: create-docx-from-text
description: Convert supplied text or UTF-8 text files into a Microsoft Word .docx document. Use for text-to-Word creation, not extracting existing DOCX files or converting legacy Word documents.
---

# Create DOCX from Text

Create an actual `.docx` file, preserving the supplied wording and order unless the user requests editing. Renaming a text file to `.docx` does not create a Word document.

## Prepare the Text and Destination

Accept text supplied in the conversation or a local UTF-8 text file. If neither is available, ask for the source text. Save conversation text to a temporary UTF-8 `.txt` file using actual line breaks and a file-writing tool; do not interpolate it into a shell command.

Use the requested output name and directory. Otherwise, use the source filename with a `.docx` extension, or `document.docx` for conversation text, in the working directory. Choose a new filename if the destination already exists unless replacement is authorized.

Use the configured Python environment with `python-docx` installed, following the project's dependency conventions. Check the import before conversion; if unavailable, install it according to those conventions or report the dependency blocker.

## Preserve Content and Apply Formatting

For ordinary plain text, preserve each input line as a Word paragraph, including internal blank lines. The bundled helpers use `splitlines()`: a final line terminator does not create an extra paragraph. They do not interpret Markdown, create tables, or preserve exact page layout.

Keep Markdown markers literal unless the user requests Markdown interpretation. If headings, lists, tables, or other formatting are requested, create native Word elements with `python-docx` in a separate saved Python script; the bundled helpers only support plain paragraphs. Apply a supplied template or style requirements when requested. Do not invent a title or rewrite content merely to format it.

## Bundled Helpers

- [scripts/convert_text_to_docx.py](scripts/convert_text_to_docx.py): the former root `read_docx.py` helper. Its effective `main` reads plain text and creates one Word paragraph per input line.
- [scripts/convert_text_to_docx_alternate.py](scripts/convert_text_to_docx_alternate.py): the former `read-docx/read_docx.py` helper, with similar conversion behavior and different filename handling.

These are preserved existing implementations, not DOCX readers. Prefer the first helper for ordinary conversion; use the alternate only when its filename behavior is specifically needed. Both accept one source-path argument and derive the destination instead of accepting an explicit output path.

Before execution, inspect the selected helper's destination logic. Supply a plain-text source with a distinct, nonexisting derived `.docx` destination. Do not pass `.doc` or `.docx` input: the helpers attempt to read it as text and may select the input itself as the destination. Never overwrite an existing input or output without authorization.

Run the selected helper with the configured Python executable, the resolved script path, and a safely quoted source path. Verify that the expected document was created and that its paragraph content matches the text. Errors may be printed without a nonzero exit status, so confirm the artifact rather than relying on exit status alone.

For example, from this skill's directory, with `python3` representing the configured environment:

```bash
python3 scripts/convert_text_to_docx.py "/path/to/notes.txt"
```

When the requested destination differs from the helper's derived path, stage the text in a temporary directory with a safe `.txt` filename, convert there, then move the verified artifact to the chosen destination. Check the destination again before moving to avoid replacing another file.

## Verify and Deliver

Reopen the output with `docx.Document` to confirm it is a readable Word document. For plain conversion, compare its paragraph texts against the source's `splitlines()` result, including Unicode and blank paragraphs. For formatted output, check text in paragraphs and table cells and inspect the requested styles. If a renderer is available and layout matters, inspect the rendered pages; otherwise disclose that visual layout was not checked.

Return a clickable link to the resulting `.docx` file and briefly state any material conversion limitations. Do not report success when the artifact is missing or cannot be reopened.

Best: convert `notes.txt` to a new `notes.docx` while retaining the original text. Avoid: passing an existing Word document to a helper that reads UTF-8 text.

For extracting existing Word documents, use [read-docx](../read-docx/SKILL.md).

import sys
import os
from docx import Document

def main():
    if len(sys.argv) < 2:
        print("Usage: python read_docx.py <input_text_file>")
        return

    source_path = sys.argv[1]

    # Define how to name the output file (same base, .docx extension)
    base, ext = os.path.splitext(source_path)
    if not base or ext == ".docx": 
        target_doc = "output_" + os.path.basename(source_path[0:len(os.path.dirname(source_path)) if len(os.path.dirname(source_path))>1 else ""]) # simplified logic below in real file to ensure consistency

    # Actually, keep it robust for filenames with no paths etc
    target_doc = base + ".docx" if ext != '.docx' and not os.path.basename(base).endswith('.docx') else (source_path if ext == '.docx' else f"{base}.docx")
    # Simplified standard rewrite below to avoid over-complexity:

def main():
    if len(sys.argv) < 2:
        print("Usage: python read_docx.py <input_file>")
        return

    source = sys.argv[1]
    base, ext = os.path.splitext(source)
    target = base + ".docx" if ext != ".doc" and ext != ".docx" else source

    # Ensure output isn't just a period or empty name (if path was relative/raw)
    if not target[0].isalpha() and len(target)>1: 
        pass # ignore logic for now, use standard naming.

    try:
        with open(source, 'r', encoding='utf-8') as f:
            content = f.read()

        doc = Document()
        # Standard paragraph-per-line to preserve structure of text files 100% clearly.
        for line in content.splitlines():
            doc.add_paragraph(line)

        doc.save(target)
        print(f"Successfully created {target} from {source}")

    except Exception as e:
        print(f"Error: {e}")

if __name__ == "__main__":
    main()
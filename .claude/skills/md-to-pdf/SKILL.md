---
name: md-to-pdf
description: >
  Convert a Markdown file in this repo to a self-contained PDF with all local
  images embedded as base64. Use when the user asks to "export this md as a
  pdf", "generate a pdf from this doc", or similar.
version: 1.0.0
allowed-tools:
  - Read
  - Bash
---

# md-to-pdf

Converts a Markdown file to PDF using `.claude/skills/md-to-pdf/scripts/md_to_pdf.py`. That script:

1. Reads the target `.md` file.
2. Rewrites every local `![alt](relative/path.png)` image reference to an
   inline `data:` URI (base64), resolved relative to the markdown file's own
   directory — so the PDF has no external file dependencies.
3. Renders the markdown to HTML (via the `markdown` pip package, with
   `extra`, `sane_lists`, `tables`, `toc` extensions) inside a minimal styled
   HTML wrapper.
4. Prints that HTML to PDF using a headless Chromium browser (Edge or Chrome,
   auto-detected — override with the `MD_TO_PDF_BROWSER` env var if neither is
   at a default install path).

## How to run it

```
python .claude/skills/md-to-pdf/scripts/md_to_pdf.py <path/to/file.md> [-o <path/to/output.pdf>]
```

- If `-o` is omitted, the PDF is written next to the source file with the
  same basename (e.g. `docs/foo.md` -> `docs/foo.pdf`).
- Only images referenced via standard Markdown image syntax
  (`![alt](path)`) are embedded. Remote images (`http(s)://`) are left as
  external links, not embedded.

## When invoked

1. Identify the markdown file the user means (ask if ambiguous).
2. Run the command above via Bash from the repo root.
3. Confirm the output PDF path and file size to the user; do not attempt to
   preview the PDF's rendered pages (no `pdftoppm`/poppler is installed in
   this environment).
4. If the script errors with "No Chromium-based browser found", tell the
   user to set `MD_TO_PDF_BROWSER` to their browser's executable path, or
   install Edge/Chrome.
5. If the script errors with "Missing dependency: markdown", run
   `pip install markdown` first (confirm with the user before installing).

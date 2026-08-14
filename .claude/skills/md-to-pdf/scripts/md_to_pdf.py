#!/usr/bin/env python3
"""Convert a Markdown file to a self-contained PDF, with local images embedded.

Usage:
    python .claude/skills/md-to-pdf/scripts/md_to_pdf.py path/to/file.md [-o path/to/output.pdf]

Requires:
    - Python package `markdown` (pip install markdown)
    - A local Chromium-based browser (Edge or Chrome) for the HTML -> PDF step.
      Set MD_TO_PDF_BROWSER to an explicit executable path to override
      auto-detection.
"""
import argparse
import base64
import mimetypes
import os
import re
import shutil
import subprocess
import sys
import tempfile
from pathlib import Path

try:
    import markdown
except ImportError:
    sys.exit("Missing dependency: run `pip install markdown` and retry.")

CANDIDATE_BROWSERS = [
    r"C:\Program Files\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe",
    r"C:\Program Files\Google\Chrome\Application\chrome.exe",
    r"C:\Program Files (x86)\Google\Chrome\Application\chrome.exe",
]

IMG_RE = re.compile(r'!\[([^\]]*)\]\(([^)\s]+)(?:\s+"[^"]*")?\)')

CSS = """
body { font-family: -apple-system, Segoe UI, Arial, sans-serif; line-height: 1.5;
       color: #1a1a1a; max-width: 900px; margin: 2em auto; padding: 0 1em; }
h1, h2, h3 { color: #2a2a2a; }
img { max-width: 100%; display: block; margin: 1em 0; }
code { background: #f2f2f2; padding: 0.1em 0.3em; border-radius: 3px; }
pre code { display: block; padding: 0.8em; overflow-x: auto; }
blockquote { border-left: 4px solid #999; margin: 1em 0; padding: 0.2em 1em; background: #f7f7f7; }
hr { border: none; border-top: 1px solid #ccc; margin: 2em 0; }
table { border-collapse: collapse; }
td, th { border: 1px solid #ccc; padding: 0.4em 0.8em; }
@media print { body { margin: 0; max-width: none; } }
"""


def find_browser() -> str:
    override = os.environ.get("MD_TO_PDF_BROWSER")
    if override:
        return override
    for candidate in CANDIDATE_BROWSERS:
        if Path(candidate).is_file():
            return candidate
    for name in ("msedge", "chrome", "google-chrome", "chromium"):
        found = shutil.which(name)
        if found:
            return found
    sys.exit(
        "No Chromium-based browser found. Set MD_TO_PDF_BROWSER to an "
        "executable path (Edge or Chrome)."
    )


def embed_images(md_text: str, base_dir: Path) -> str:
    def replace(match: re.Match) -> str:
        alt, src = match.group(1), match.group(2)
        if src.startswith(("http://", "https://", "data:")):
            return match.group(0)
        img_path = (base_dir / src).resolve()
        if not img_path.is_file():
            print(f"warning: image not found, leaving as-is: {src}", file=sys.stderr)
            return match.group(0)
        mime = mimetypes.guess_type(str(img_path))[0] or "application/octet-stream"
        b64 = base64.b64encode(img_path.read_bytes()).decode("ascii")
        return f"![{alt}](data:{mime};base64,{b64})"

    return IMG_RE.sub(replace, md_text)


def render_html(md_path: Path) -> str:
    md_text = md_path.read_text(encoding="utf-8")
    md_text = embed_images(md_text, md_path.parent)
    body = markdown.markdown(
        md_text, extensions=["extra", "sane_lists", "tables", "toc"]
    )
    return f"""<!doctype html>
<html>
<head>
<meta charset="utf-8">
<title>{md_path.stem}</title>
<style>{CSS}</style>
</head>
<body>
{body}
</body>
</html>
"""


def html_to_pdf(html: str, pdf_path: Path, browser: str) -> None:
    with tempfile.NamedTemporaryFile(
        "w", suffix=".html", delete=False, encoding="utf-8"
    ) as f:
        f.write(html)
        html_path = Path(f.name)
    try:
        subprocess.run(
            [
                browser,
                "--headless",
                "--disable-gpu",
                "--no-pdf-header-footer",
                f"--print-to-pdf={pdf_path}",
                html_path.as_uri(),
            ],
            check=True,
            capture_output=True,
            text=True,
        )
    finally:
        html_path.unlink(missing_ok=True)


def main() -> None:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("markdown_file", type=Path)
    parser.add_argument("-o", "--output", type=Path, default=None)
    args = parser.parse_args()

    md_path = args.markdown_file.resolve()
    if not md_path.is_file():
        sys.exit(f"Not found: {md_path}")

    pdf_path = (args.output or md_path.with_suffix(".pdf")).resolve()
    browser = find_browser()

    html = render_html(md_path)
    html_to_pdf(html, pdf_path, browser)
    print(f"wrote {pdf_path}")


if __name__ == "__main__":
    main()

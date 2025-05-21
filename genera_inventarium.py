#!/usr/bin/env python3
import os
import datetime
from pathlib import Path
from urllib.parse import urljoin

SITE_URL = "https://abbatia.aquinas.lol"
DOCS_DIR = Path("docs")
SITEMAP_PATH = DOCS_DIR / "sitemap.xml"
ROBOTS_PATH = DOCS_DIR / "robots.txt"

def is_valid_page(path: Path) -> bool:
    if path.name.startswith("google") and path.suffix == ".html":
        return False
    if path.name.endswith("index.xml"):
        return False
    if path.name == "index.html" and path.parent == DOCS_DIR:
        return False
    return path.suffix == ".html"

def calculate_priority(path: Path) -> str:
    return "1.0" if path.name == "index.html" else "0.7"

def extract_date_from_filename(filename: str) -> str:
    try:
        date_part = filename[:10]
        datetime.datetime.strptime(date_part, "%Y-%m-%d")
        return date_part
    except Exception:
        return None

def build_url(path: Path) -> str:
    rel_path = path.relative_to(DOCS_DIR)
    if path.name == "index.html":
        return urljoin(SITE_URL + "/", str(rel_path.parent) + "/")
    else:
        return urljoin(SITE_URL + "/", str(rel_path))

def main():
    entries = []

    for root, dirs, files in os.walk(DOCS_DIR):
        for name in files:
            path = Path(root) / name
            if not is_valid_page(path):
                continue

            url = build_url(path)
            date = extract_date_from_filename(path.name)

            entry_lines = [f"  <url>",
                           f"    <loc>{url}</loc>"]
            if date:
                entry_lines.append(f"    <lastmod>{date}</lastmod>")
            if path.name == "index.html":
                entry_lines.append("    <changefreq>monthly</changefreq>")
            entry_lines.append("  </url>")
            entry = "\n".join(entry_lines)

            entries.append(entry)

    with open(SITEMAP_PATH, "w", encoding="utf-8") as f:
        f.write('<?xml version="1.0" encoding="UTF-8"?>\n')
        f.write('<urlset xmlns="http://www.sitemaps.org/schemas/sitemap/0.9">\n')
        f.write("  <url>\n")
        f.write(f"    <loc>{SITE_URL}/</loc>\n")
        f.write("    <changefreq>monthly</changefreq>\n")
        f.write("  </url>\n")
        for entry in entries:
            f.write(entry + "\n")
        f.write('</urlset>\n')

    with open(ROBOTS_PATH, "w", encoding="utf-8") as f:
        f.write("User-agent: *\n")
        f.write("Disallow:\n\n")
        f.write(f"Sitemap: {SITE_URL}/sitemap.xml\n")

if __name__ == "__main__":
    main()

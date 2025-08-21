#!/usr/bin/env python3
import os
import datetime
from pathlib import Path
from urllib.parse import urljoin

SITE_URL = "https://abbatia.aquinas.lol"
DOCS_DIR = Path("docs")
SITEMAP_PATH = DOCS_DIR / "sitemap.xml"
ROBOTS_PATH = DOCS_DIR / "robots.txt"
TABELLAE_DIR = Path("_tabellae")

def is_valid_page(path: Path) -> bool:
    if path.name.startswith("google") and path.suffix == ".html":
        return False
    if path.name.endswith("index.xml"):
        return False
    if path.name == "index.html" and path.parent == DOCS_DIR:
        return False
    return path.suffix == ".html"

def format_lastmod_utc(ts: float) -> str:
    """Return ISO 8601 timestamp with explicit +00:00 offset from a POSIX mtime."""
    return datetime.datetime.fromtimestamp(ts, datetime.timezone.utc).strftime('%Y-%m-%dT%H:%M:%S+00:00')

def build_url(path: Path) -> str:
    rel_path = path.relative_to(DOCS_DIR)
    if path.name == "index.html":
        return urljoin(SITE_URL + "/", str(rel_path.parent) + "/")
    else:
        return urljoin(SITE_URL + "/", str(rel_path))

def is_section_page(rel_path: Path) -> bool:
    return rel_path.name == "index.html"

def source_mtime_for_section(section: str) -> float:
    """Return mtime for a section by taking the newest immediate subdirectory in _tabellae/<section>.
    Fallback to the section dir mtime, then _tabellae mtime."""
    base = TABELLAE_DIR / section
    if not base.exists():
        return TABELLAE_DIR.stat().st_mtime
    newest = None
    try:
        for child in base.iterdir():
            if child.is_dir():
                mt = child.stat().st_mtime
                if newest is None or mt > newest:
                    newest = mt
        if newest is not None:
            return newest
        return base.stat().st_mtime
    except Exception:
        return base.stat().st_mtime

def source_mtime_for_html(rel_path: Path) -> float:
    """Return mtime of the markdown source corresponding to a docs HTML page.
    Special handling for paths like <section>/opera/<YYYY-...>.html → _tabellae/<section>/<YYYY>/<same>.md
    Fallbacks:
      - _tabellae/<section>/<basename>.md (direct)
      - _tabellae/<rel_path>.md (mirrored tree)
      - section dir mtime
    """
    # rel_path like refectorium/opera/2025-08-18-foo.html
    parts = list(rel_path.parts)
    if len(parts) >= 3 and parts[1] == 'opera':
        section = parts[0]
        filename = rel_path.name
        year = filename[:4] if filename[:4].isdigit() else None
        if year:
            candidate = TABELLAE_DIR / section / year / (filename[:-5] + '.md')
            if candidate.exists():
                return candidate.stat().st_mtime
        # fallback within section root
        fallback1 = TABELLAE_DIR / section / (filename[:-5] + '.md')
        if fallback1.exists():
            return fallback1.stat().st_mtime
    # generic mirror fallback
    generic = TABELLAE_DIR / rel_path.with_suffix('.md')
    if generic.exists():
        return generic.stat().st_mtime
    # last resort: section directory mtime
    section = parts[0] if parts else ''
    base = TABELLAE_DIR / section
    return (base.stat().st_mtime if base.exists() else TABELLAE_DIR.stat().st_mtime)

def main():
    entries = []

    # Walk the docs directory and build URL entries
    for root, dirs, files in os.walk(DOCS_DIR):
        for name in files:
            path = Path(root) / name
            if not is_valid_page(path):
                continue

            rel_path = path.relative_to(DOCS_DIR)
            url = build_url(path)
            if is_section_page(rel_path):
                section = rel_path.parent.name
                lm_ts = source_mtime_for_section(section)
            else:
                lm_ts = source_mtime_for_html(rel_path)
            lastmod = format_lastmod_utc(lm_ts)

            entry_lines = [
                "  <url>",
                f"    <loc>{url}</loc>",
                f"    <lastmod>{lastmod}</lastmod>",
                "  </url>",
            ]
            entries.append("\n".join(entry_lines))

    # Write sitemap with namespaces and UTC timestamps
    with open(SITEMAP_PATH, "w", encoding="utf-8") as f:
        f.write('<?xml version="1.0" encoding="UTF-8"?>\n')
        f.write('<urlset\n')
        f.write('  xmlns="http://www.sitemaps.org/schemas/sitemap/0.9"\n')
        f.write('  xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance"\n')
        f.write('  xsi:schemaLocation="http://www.sitemaps.org/schemas/sitemap/0.9 http://www.sitemaps.org/schemas/sitemap/0.9/sitemap.xsd">\n')

        # Root URL entry
        root_index = DOCS_DIR / 'index.html'
        if root_index.exists():
            root_lastmod = format_lastmod_utc(root_index.stat().st_mtime)
        else:
            root_lastmod = format_lastmod_utc(datetime.datetime.now(datetime.timezone.utc).timestamp())
        f.write("  <url>\n")
        f.write(f"    <loc>{SITE_URL}/</loc>\n")
        f.write(f"    <lastmod>{root_lastmod}</lastmod>\n")
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

"""Build a read-only copy of the Meridian Map editor around one graph version, for sharing as an artifact.

Usage (from the repo root):
  python -I tools/design/meridian_rework/editor/publish_view.py <out.html> [<version>]

<version> defaults to the most recently saved one. The page is the editor itself in read-only mode: pan, zoom, click a
node to read it, find, colour modes, checks and clusters; no saving and no editing tools. It embeds the version's data,
so it needs no server. The document wrapper tags are left out because the artifact host adds its own.
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, os.path.dirname(HERE))
import versions  # noqa: E402


def main():
    if len(sys.argv) < 2:
        raise SystemExit(__doc__)
    out = sys.argv[1]
    names = [v["name"] for v in versions.listing()]
    name = sys.argv[2] if len(sys.argv) > 2 else (names[0] if names else None)
    if name not in names:
        raise SystemExit(f"no version {name!r}; have: {', '.join(names)}")
    doc = versions.read(name)
    with open(os.path.join(HERE, "editor.html"), encoding="utf-8") as f:
        page = f.read()
    # the host wraps the page in its own document: drop ours
    for pat in (r"<!doctype html>\s*", r"<html[^>]*>\s*", r"</html>\s*", r"<head>\s*", r"</head>\s*", r"<body>\s*",
                r"</body>\s*", r'<meta charset="utf-8">\s*', r'<meta name="viewport"[^>]*>\s*'):
        page = re.sub(pat, "", page, flags=re.I)
    page = page.replace("<title>Meridian Map Editor</title>", "<title>Meridian Map Viewer</title>", 1)
    embed = json.dumps({"readonly": True, "version": name, "doc": doc}, ensure_ascii=False, separators=(",", ":"))
    marker = '<script id="embed" type="application/json">__EMBED__</script>'
    assert marker in page, "editor.html lost its embed slot"
    page = page.replace(marker, marker.replace("__EMBED__", embed.replace("</", "<\\/")), 1)
    with open(out, "w", encoding="utf-8") as f:
        f.write(page)
    print(f"{out}: {name}, {os.path.getsize(out) / 1e6:.1f} MB")


if __name__ == "__main__":
    main()

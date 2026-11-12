"""Inline a replays JSON (export_replay.py) and the icons it uses (assets/icons) into the replay viewer as one page.

Run: python -I tools/design/combat_sim/make_replay_page.py REPLAYS.json OUT.html
Icons: art_<id>.png for every art in the replays, ward_resist / ward_shield, buff_/debuff_<element>. A missing icon
falls back to the viewer's letter glyph and is listed here.
"""
import base64
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
ICONS = os.path.join(ROOT, "assets", "icons")
ELEMENTS = ["fire", "water", "wood", "metal", "earth", "ice", "thunder", "wind"]


def uri(path):
    return "data:image/png;base64," + base64.b64encode(open(path, "rb").read()).decode("ascii")


def main():
    if len(sys.argv) != 3:
        print(__doc__)
        return 2
    page = open(os.path.join(HERE, "replay_viewer.html"), encoding="utf-8").read()
    if "/*__DATA__*/" not in page or "/*__ICONS__*/" not in page:
        print("NO_SLOT\treplay_viewer.html lacks a /*__DATA__*/ or /*__ICONS__*/ slot")
        return 2
    raw = open(sys.argv[1], encoding="utf-8").read()
    replays = json.loads(raw)
    icons, missing = {}, []
    for r in replays:
        for side in ("A", "B"):
            for a in r[side]["arts"]:
                p = os.path.join(ICONS, "arts", "art_%s.png" % a["id"].replace("-", "_"))
                if os.path.exists(p):
                    icons["art:" + a["id"]] = uri(p)
                else:
                    missing.append(a["id"])
    for k, f in (("ward:resist", "wards/ward_resist.png"), ("ward:shield", "wards/ward_shield.png")):
        if os.path.exists(os.path.join(ICONS, f)):
            icons[k] = uri(os.path.join(ICONS, f))
    for kind in ("buff", "debuff"):
        for e in ELEMENTS:
            p = os.path.join(ICONS, "status", "%s_%s.png" % (kind, e))
            if os.path.exists(p):
                icons["%s:%s" % (kind, e)] = uri(p)
    page = page.replace("/*__DATA__*/", raw.replace("</", "<\\/")).replace("/*__ICONS__*/", json.dumps(icons))
    with open(sys.argv[2], "w", encoding="utf-8", newline="\n") as f:
        f.write(page)
    print("icons\t%d embedded; no icon for %d arts: %s" % (len(icons), len(set(missing)), ", ".join(sorted(set(missing)))[:300]))
    print("wrote %s (%d KB)" % (sys.argv[2], os.path.getsize(sys.argv[2]) // 1024))
    return 0


if __name__ == "__main__":
    sys.exit(main())

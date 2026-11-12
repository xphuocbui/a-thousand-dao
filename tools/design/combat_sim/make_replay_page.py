"""Inline a replays JSON (export_replay.py) and the icons it uses (assets/icons) into the replay viewer as one page.

Run: python -I tools/design/combat_sim/make_replay_page.py REPLAYS.json OUT.html
Icons (installed by tools/asset-pipeline/icons/review.py --apply): arts/art_<id>.png for every art in the replays,
techniques/tech_<id>.png, status/element_<el>.png (buff and debuff, halo drawn by the viewer), status/status_<id>.png,
status/counter_<id>.png, status/stance_<id>.png, and a ward picture for the resistance ward and the ward shields.
A missing icon falls back to the viewer's letter glyph or text chip and is listed here.
"""
import base64
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", ".."))
ICONS = os.path.join(ROOT, "assets", "icons")
ELEMENTS = ["fire", "water", "wood", "metal", "earth", "ice", "thunder", "wind"]
# Replays do not name a catalogue ward yet, so the two ward slots show one representative painting each (first found).
WARD_PICS = {"ward:resist": ["wards/ward_common_ward.png", "wards/ward_resist.png"],
             "ward:shield": ["wards/ward_golden_light_shield.png", "wards/ward_shield.png"]}


def uri(path):
    return "data:image/png;base64," + base64.b64encode(open(path, "rb").read()).decode("ascii")


def fname(i):
    return i.replace("-", "_")


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

    def put(key, rel):
        p = os.path.join(ICONS, rel)
        if os.path.exists(p):
            icons[key] = uri(p)
            return True
        missing.append(key)
        return False

    statuses, counters, stances = set(), set(), set()
    for r in replays:
        for side in ("A", "B"):
            for a in r[side]["arts"]:
                put("art:" + a["id"], "arts/art_%s.png" % fname(a["id"]))
            for t in r[side].get("techniques", []):
                put("tech:" + t["id"], "techniques/tech_%s.png" % fname(t["id"]))
        for sn in r.get("snaps", []):
            for side in ("A", "B"):
                x = sn.get(side) or {}
                statuses |= set(x.get("st", {}))
                counters |= set(x.get("ct", {}))
                if x.get("state"):
                    stances.add(x["state"])
    for s in sorted(statuses):
        put("status:" + s, "status/status_%s.png" % fname(s))
    for c in sorted(counters):
        put("counter:" + c, "status/counter_%s.png" % fname(c))
    for s in sorted(stances):
        put("stance:" + s, "status/stance_%s.png" % fname(s))
    for e in ELEMENTS:
        put("element:" + e, "status/element_%s.png" % e)
    for k, choices in WARD_PICS.items():
        for rel in choices:
            if os.path.exists(os.path.join(ICONS, rel)):
                icons[k] = uri(os.path.join(ICONS, rel))
                break
        else:
            missing.append(k)
    page = page.replace("/*__DATA__*/", raw.replace("</", "<\\/")).replace("/*__ICONS__*/", json.dumps(icons))
    with open(sys.argv[2], "w", encoding="utf-8", newline="\n") as f:
        f.write(page)
    miss = sorted(set(missing))
    print("icons\t%d embedded; %d missing: %s" % (len(icons), len(miss), ", ".join(miss)[:400]))
    print("wrote %s (%d KB)" % (sys.argv[2], os.path.getsize(sys.argv[2]) // 1024))
    return 0


if __name__ == "__main__":
    sys.exit(main())

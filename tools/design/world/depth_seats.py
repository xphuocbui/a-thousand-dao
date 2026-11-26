"""The final seat and leans of every sect, as a machine-readable table (production/plans/world-depth-implementation.md
Stage 1; World Generation Open Question 12, rule 16 and Formula F).

Reads each sect page (design/world/depth/sects/<key>.md): the "| Leans |" row of § 1 (the text after "→", or the
whole row when it says "unchanged") and the "**Decision (R4) ...**" paragraph of § 2 with its candidate table (the
row whose verdict is **seat**, else "move the seat ... (<place id>)", else "stay": the current seat). Writes
design/world/depth/seats.json:

    {"sects": [{"key", "seat_old", "seat", "moved", "leans", "no_lean", "fit", "notes"}]}

Formula F (the seat fit test, with innate variants removed: Wind) runs on the final seat and leans; depth_check.py
reads this file and reports a sect that fails. Observations, not verdicts: a page this tool cannot read is listed,
never guessed.

Run: python -I tools/design/world/depth_seats.py [--check]   (--check: compare with the file, write nothing)
Exit 0 always.
"""
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[3]
D = ROOT / "design" / "world" / "depth"
OUT = D / "seats.json"
NAME = {"Metal": "kim", "Wood": "moc", "Water": "thuy", "Fire": "hoa", "Earth": "tho", "Ice": "bang",
        "Thunder": "loi", "Wind": "phong", "Darkness": "am", "Light": "quang"}
BASE = {"kim", "moc", "thuy", "hoa", "tho"}   # place.qi.shares is keyed by these ids
INNATE = {"phong"}                   # World Generation rule 16: an innate variant is removed before the test
LEAN_FIRST, LEAN_OTHER, LEAN_VARIANT = 25.0, 15.0, 5.0


def leans_of(row):
    text = row.split("→", 1)[1] if "→" in row else row
    text = re.split(r"\(|\.\s|:", text.replace("*", ""), maxsplit=1)[0]
    if re.search(r"\bnone\b", text):
        return []
    return [NAME[w] for w in re.findall(r"\b(" + "|".join(NAME) + r")\b", text)]


def seat_of(page, current):
    m = re.search(r"\*\*Decision[^*]*\*\*", page, re.S)
    if not m:
        return None, "no Decision paragraph"
    decision = m.group(0).replace("\n", " ")
    section = page[m.start():]
    section = section[:re.search(r"\n## ", section).start()] if re.search(r"\n## ", section) else section
    for line in section.splitlines():
        cells = [c.strip() for c in line.strip().strip("|").split("|")]
        if len(cells) > 2 and re.search(r"\*\*seat\*\*", cells[-1]):
            ids = re.findall(r"\((?:place )?(\d+)\)", cells[0])
            if ids:
                return int(ids[0]), "the candidate row marked seat"
    # the place moved to: "... from the manor house (27) to Tiêu Âm Mạch (263)" names the old seat first
    mv = re.search(r"move the seat(?: record)?\b.*?\b(?:to|onto)\b[^()]*\((?:place )?(\d+)\)", decision)
    if mv:
        return int(mv.group(1)), "the Decision's move"
    if re.search(r"\bstay\b", decision):
        st = re.search(r"\bstay (?:at|on)[^(.]*?(?:\(|place )(\d+)", decision)
        if st and int(st.group(1)) != current:
            return None, "Decision stays at %s but the current seat is %s" % (st.group(1), current)
        return current, "the Decision stays"
    return None, "Decision names no seat: " + decision[:100]


def fit(place, leans):
    """World Generation Formula F on one place's qi."""
    q = place["qi"]
    sh, va = q["shares"], q.get("variants", {})
    order = sorted(sh, key=sh.get, reverse=True)
    ell = [lean for lean in leans if lean not in INNATE]
    notes, ok = [], True
    for i, lean in enumerate(ell):
        if lean in BASE:
            s = sh.get(lean, 0.0)
            good = s >= (LEAN_FIRST if i == 0 else LEAN_OTHER) or lean in order[:1 if i == 0 else 2]
            notes.append("%s %.0f%%%s" % (lean, s, "" if good else " FAILS"))
        else:
            s = float(va.get(lean, 0.0))
            good = s >= LEAN_VARIANT
            notes.append("%s %.0f%s" % (lean, s, "" if good else " FAILS"))
        ok = ok and good
    return ok, ", ".join(notes) if ell else ("no lean" if not leans else "innate lean only")


def build():
    w = json.loads((ROOT / "assets/data/world_continent.json").read_text(encoding="utf-8"))
    current = {s["key"]: s["seat"] for s in w["great_sects"] + w["minor_sects"]}
    places = {p["id"]: p for p in w["places"]}
    rows, unread = [], []
    for page_path in sorted((D / "sects").glob("*.md")):
        key = page_path.stem
        page = page_path.read_text(encoding="utf-8")
        lrow = re.search(r"^\| Leans \|(.*)$", page, re.M)
        seat, how = seat_of(page, current.get(key))
        if lrow is None or seat is None:
            unread.append({"key": key, "why": "no Leans row" if lrow is None else how})
            continue
        leans = leans_of(lrow.group(1))
        ok, note = fit(places[seat], leans) if seat in places else (False, "seat %s is not a place" % seat)
        rows.append({"key": key, "seat_old": current.get(key), "seat": seat, "moved": seat != current.get(key),
                     "leans": leans, "no_lean": not leans, "fit": ok, "notes": "%s; %s" % (how, note)})
    return {"_doc": "Generated by tools/design/world/depth_seats.py from the sect pages (§ 1 Leans, § 2 Decision). "
                    "The final seat and leans of every sect, and World Generation Formula F on them (Wind removed).",
            "sects": rows, "unread": unread}


def main():
    out = build()
    text = json.dumps(out, ensure_ascii=False, indent=1) + "\n"
    rows = out["sects"]
    print("sects read %d, unread %d, moved %d, no-lean %d, failing Formula F %d" % (
        len(rows), len(out["unread"]), sum(r["moved"] for r in rows), sum(r["no_lean"] for r in rows),
        sum(not r["fit"] for r in rows)))
    for r in rows:
        if not r["fit"]:
            print("  FAILS F: %s seat %s leans %s (%s)" % (r["key"], r["seat"], r["leans"], r["notes"]))
    for u in out["unread"]:
        print("  unread: %s (%s)" % (u["key"], u["why"]))
    if "--check" in sys.argv:
        same = OUT.exists() and OUT.read_text(encoding="utf-8") == text
        print("seats.json is %s" % ("current" if same else "stale or missing"))
    else:
        OUT.write_text(text, encoding="utf-8", newline="\n")
        print("wrote", OUT.relative_to(ROOT))
    return 0


if __name__ == "__main__":
    sys.exit(main())

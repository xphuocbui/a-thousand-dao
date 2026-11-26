"""The world-depth pass's new dated events as structured records (production/plans/world-depth-implementation.md
Stage 1; ADR-0009 decision 2; World Generation rule 5a).

Reads every event entry on the sect and group pages (design/world/depth/sects/*.md, people/*.md), written

    - **N-<owner>-<nn>** (<year or span>, `<kind>`[, hidden | tier: landmark|annal | kind: `<story kind>`]): "<text>"
    | N-<owner>-<nn> | <year> | <kind> | "<English text>" |          (the table form, people/clans.md)

and writes design/world/depth/events/<owner>.events.json:

    {"owner", "events": [{"id", "year", "span", "kind", "tier", "secret", "text_en", "text_vi",
                          "people", "sects", "place", "page"}]}

- tier by kind (rule 5a): the 13 landmark kinds go to the landmark chronicle, the `hidden` kind to neither tier
  (tier "hidden"), every other kind to the annals; a page's `tier:` override wins.
- secret: the page kind `secret` (annals, secret flag), the "hidden" mark after a kind, and the `hidden` kind.
- people, sects and place are matched by name in the text (people by their Hán-Việt name, sects by name, places by
  the continent's place names, longest name first). A match is a proposal for the translation pass to confirm.
- secret also when a timeline row naming the event says "(hidden)", or "(hidden" follows the quoted text.
- text_vi is "" until the translation pass writes it, with text_vi_of = the text_en it translated (--check reports a
  text_vi whose text_en has changed since). A later run keeps every hand-written text_vi, text_vi_of, people, sects
  and place (the page owns id, year, kind, tier, secret and text_en; the events file owns the rest).

Run:
  python -I tools/design/world/depth_events.py            write the files
  python -I tools/design/world/depth_events.py --check    compare, write nothing: missing entries, stale page
                                                          fields, empty text_vi, unknown keys and ids
  ... --check --owner=bang_tam,thien_xu                   the same, for those owners only (all lines printed)
Exit 0 always.
"""
import collections
import glob
import json
import pathlib
import re
import sys

ROOT = pathlib.Path(__file__).resolve().parents[3]
D = ROOT / "design" / "world" / "depth"
OUT = D / "events"
START_YEAR = 1200
LANDMARK = {"seat_moved", "array_laid", "sect_founded", "founding", "headship", "item_made", "item_taken", "item_lost",
            "item_found", "treasure", "technique_made", "seal_laid", "seal_renewed"}
HEAD = re.compile(r"^\s*[-*] \*\*(N-([a-z_]+)-\d+[a-z]?)\*\* \(([^)]*)\):\s*(.*)$")
ROW = re.compile(r'^\|\s*(N-[a-z_]+-\d+[a-z]?)\s*\|\s*([\d\s\-andto]+?)\s*\|\s*`?([a-z_]+)`?\s*\|\s*("[^"]*")[^|]*\|')
PAGE_FIELDS = ("year", "span", "kind", "story_kind", "tier", "secret", "text_en")


def load(p):
    return json.loads(pathlib.Path(p).read_text(encoding="utf-8"))


def names():
    """People, sect and place names to match in event text: [(name, kind, key)], longest first."""
    out = []
    for f in glob.glob(str(D / "sects" / "*.cast.json")) + glob.glob(str(D / "people" / "*.cast.json")):
        for p in load(f).get("people", []):
            if p.get("name_hv"):
                out.append((p["name_hv"], "people", p["key"]))
    hist = load(ROOT / "assets/data/world_history.json")
    for p in hist["people"]:
        out.append((p["name"], "people", p["key"]))
    w = load(ROOT / "assets/data/world_continent.json")
    for s in w["great_sects"] + w["minor_sects"]:
        out.append((s["name"], "sects", s["key"]))
    for p in w["places"]:
        if p.get("name") and p.get("kind") not in ("great_seat", "minor_seat"):
            out.append((p["name"], "place", p["id"]))
    seen, uniq = set(), []
    for n, k, v in sorted(out, key=lambda x: -len(x[0])):
        if (n, k) not in seen and len(n) > 3:
            seen.add((n, k))
            uniq.append((n, k, v))
    return uniq


def parse_pages():
    """Every event entry on the pages: {id: record}, and problems."""
    events, problems = {}, []
    pages = sorted(glob.glob(str(D / "sects" / "*.md")) + glob.glob(str(D / "people" / "*.md")))
    # a timeline row that marks its own event (hidden): "| 1175 | ... | **N-nam_pho-04** (hidden) |", or the page's
    # short form "**N-04**". Only the row's bold ids are its own; a plain id in the row is a cross-reference.
    hidden_ids = set()
    for page in pages:
        stem = pathlib.Path(page).stem.replace("-", "_")
        for line in pathlib.Path(page).read_text(encoding="utf-8").split("\n"):
            if line.lstrip().startswith("|") and "(hidden" in line:
                for bold in re.findall(r"\*\*([^*]+)\*\*", line):
                    hidden_ids |= set(re.findall(r"\bN-[a-z_]+-\d+[a-z]?\b", bold))
                    hidden_ids |= {"N-%s-%s" % (stem, n) for n in re.findall(r"\bN-(\d+[a-z]?)\b", bold)}
    for page in pages:
        lines = pathlib.Path(page).read_text(encoding="utf-8").split("\n")
        for i, line in enumerate(lines):
            m = HEAD.match(line)
            t = ROW.match(line)
            if t and not m:   # the table form: | N-clans-01 | 600 | marriage | "text" |
                m = HEAD.match('- **%s** (%s, `%s`): %s' % (t.group(1), t.group(2), t.group(3), t.group(4)))
            if not m:
                continue
            eid, owner, head, text = m.group(1), m.group(2), m.group(3), m.group(4)
            j = i
            while text.count('"') < 2 and j + 1 < len(lines):
                j += 1
                text += " " + lines[j].strip()
            q = re.match(r'^"(.*?)"', text)
            parts = [p.strip() for p in head.split(",")]
            years = [int(y) for y in re.findall(r"\d{1,4}", parts[0])]
            kind = parts[1].strip("`") if len(parts) > 1 else ""
            flags = [p.strip("`") for p in parts[2:]]
            if not years or not kind or not q:
                problems.append("%s (%s): the entry header or quoted text cannot be read" % (eid, page))
                continue
            override = next((f.split(":", 1)[1].strip() for f in flags if f.startswith("tier:")), None)
            # the `hidden` kind keeps the page's story kind as a fact: (1162, `hidden`, kind: `trade`)
            story_kind = next((f.split(":", 1)[1].strip().strip("`") for f in flags if f.startswith("kind:")), "")
            tier = override or ("hidden" if kind == "hidden" else ("landmark" if kind in LANDMARK else "annal"))
            after = text[q.end():].lstrip()
            marked = "hidden" in flags or after.startswith("(hidden") or eid in hidden_ids
            rec = {"id": eid, "year": years[0], "span": parts[0] if len(years) > 1 else "", "kind": kind,
                   "tier": tier, "secret": kind in ("secret", "hidden") or marked,
                   "story_kind": story_kind, "text_en": q.group(1).strip(), "page":str(pathlib.Path(page).relative_to(ROOT)).replace("\\", "/")}
            if eid in events:
                problems.append("%s: written twice (%s, %s)" % (eid, events[eid]["page"], rec["page"]))
                continue
            if not 0 <= rec["year"] <= START_YEAR:
                problems.append("%s: year %d is outside 0-%d" % (eid, rec["year"], START_YEAR))
            events[eid] = (owner, rec)
    return events, problems


def match(text, table):
    found = {"people": [], "sects": [], "place": []}
    rest = text
    for name, kind, key in table:
        if re.search(r"(?<!\w)" + re.escape(name) + r"(?!\w)", rest):
            if key not in found[kind]:
                found[kind].append(key)
            rest = re.sub(r"(?<!\w)" + re.escape(name) + r"(?!\w)", " ", rest)
    return found


def build():
    events, problems = parse_pages()
    table = names()
    old = {}
    for f in glob.glob(str(OUT / "*.events.json")):
        for e in load(f).get("events", []):
            old[e["id"]] = e
    by_owner = collections.defaultdict(list)
    for eid, (owner, rec) in sorted(events.items()):
        prev = old.get(eid)
        if prev is not None:
            kept = {k: prev[k] for k in ("text_vi", "text_vi_of", "people", "sects", "place") if k in prev}
        else:
            m = match(rec["text_en"], table)
            kept = {"text_vi": "", "people": m["people"], "sects": m["sects"],
                    "place": m["place"][0] if m["place"] else None}
        by_owner[owner].append(dict(rec, **kept))
    return by_owner, problems, old


def check(by_owner, problems, old):
    people = set()
    for f in glob.glob(str(D / "sects" / "*.cast.json")) + glob.glob(str(D / "people" / "*.cast.json")):
        people |= {p["key"] for p in load(f).get("people", [])}
    people |= {p["key"] for p in load(ROOT / "assets/data/world_history.json")["people"]}
    w = load(ROOT / "assets/data/world_continent.json")
    sects = {s["key"] for s in w["great_sects"] + w["minor_sects"]}
    places = {p["id"] for p in w["places"]}
    out = list(problems)
    for owner, evs in by_owner.items():
        for e in evs:
            prev = old.get(e["id"])
            if prev is None:
                out.append("%s: not in events/%s.events.json yet" % (e["id"], owner))
                continue
            for k in PAGE_FIELDS:
                if prev.get(k) != e[k]:
                    out.append("%s: %s on the page is %r, the events file has %r" % (e["id"], k, e[k], prev.get(k)))
            if not prev.get("text_vi"):
                out.append("%s: no text_vi" % e["id"])
            elif prev.get("text_vi_of") != e["text_en"]:
                # the translation pass writes text_vi_of = the text_en it translated, so a rewrite is caught
                out.append("%s: text_vi translates an older text_en (re-translate)" % e["id"])
            for k in prev.get("people", []):
                if k not in people:
                    out.append("%s: person %s does not exist" % (e["id"], k))
            for k in prev.get("sects", []):
                if k not in sects:
                    out.append("%s: sect %s does not exist" % (e["id"], k))
            if prev.get("place") is not None and prev["place"] not in places:
                out.append("%s: place %s does not exist" % (e["id"], prev["place"]))
    ids = {e["id"] for evs in by_owner.values() for e in evs}
    for eid in sorted(set(old) - ids):
        out.append("%s: in an events file but on no page" % eid)
    return out


def main():
    by_owner, problems, old = build()
    n = sum(len(v) for v in by_owner.values())
    tiers = collections.Counter(e["tier"] for v in by_owner.values() for e in v)
    print("events on the pages: %d in %d owners (%s); secret %d" % (
        n, len(by_owner), ", ".join("%s %d" % kv for kv in sorted(tiers.items())),
        sum(e["secret"] for v in by_owner.values() for e in v)))
    if "--check" in sys.argv:
        found = check(by_owner, problems, old)
        owners = next((a.split("=", 1)[1].split(",") for a in sys.argv if a.startswith("--owner=")), None)
        if owners:   # one batch's owners only (the translation pass): --owner=bang_tam,thien_xu
            found = [x for x in found if re.match(r"^N-(%s)-" % "|".join(map(re.escape, owners)), x)]
        print("observations: %d" % len(found))
        for x in found if owners else found[:60]:
            print("  " + x)
        return 0
    for p in problems:
        print("  " + p)
    OUT.mkdir(exist_ok=True)
    for owner, evs in sorted(by_owner.items()):
        (OUT / ("%s.events.json" % owner)).write_text(json.dumps(
            {"owner": owner, "_doc": "Generated by tools/design/world/depth_events.py from the pages; id, year, span, "
                                     "kind, tier, secret and text_en follow the page, the rest is kept as written here.",
             "events": evs}, ensure_ascii=False, indent=1) + "\n", encoding="utf-8", newline="\n")
    print("wrote %d files in %s" % (len(by_owner), OUT.relative_to(ROOT)))
    return 0


if __name__ == "__main__":
    sys.exit(main())

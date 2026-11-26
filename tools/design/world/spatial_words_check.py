"""List fight records that use the readings removed or postponed on 2026-11-26 (Combat rule 25 rewritten: no spatial
fight, one side against one side; design/world/depth/DECISIONS-2026-11-26.md).

Observations, never verdicts (.claude/docs/context-management.md): each line names a record, the field, the class and
the matched words. Whether a hit needs a rewrite is the rewrite pass's call.

Classes:
  removed    position words: range, knock-back/push/pull, rooted/pinned/planted, field Pieces (steles, banners), a
             place inside the fight (inside your mist, zone), spreads and nearby/nearest/another foe, behind/beside/steps
  postponed  several fighters: ally/allies, alone, every/all/each foe, foes, enemies
  rename     the kept rhythm readings under their old names: Still, stand still, stillness, Moving, the foe moves,
             footwork (now Composed, Pressing, the foe pressed)
  key        an engine key or tag of the old vocabulary inside a record (at_range, field_piece, foe_moved, still_time,
             displaced, the tags still/moving/footwork/piece/displace/rooted/pinned)

Scanned: rule-bearing fields only (rule, effect, concept, payload, reads, limits, closes, note, intent, targets_note,
build_use, strikes, desc, text, effects/tags/do records). Lore, names, appearances and stories are images and stay
(Combat rule 26). Every record name found in the scanned files is blanked out of the text first, so "Still Water",
"Rooted Form" or "Planted Banner" named inside a rule do not count.

Usage (repo root):
  python -I tools/design/world/spatial_words_check.py [--depth | --shipped] [--sect <key>] [--class <c>] [--json]
  python -I tools/design/world/spatial_words_check.py --self-test
"""
import glob
import json
import os
import re
import sys
from collections import Counter, defaultdict

ROOT = os.path.abspath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))

DEPTH = (["design/world/depth/sects/*.items.json", "design/world/depth/sects/*.techniques.json",
          "design/world/depth/sects/*.beasts.json", "design/world/depth/sects/*.cast.json",
          "design/world/depth/builds/authored/auth-*.json"])
SHIPPED = (["assets/data/combat_effects.json", "assets/data/combat_library.json", "assets/data/dao_do_map.json",
            "assets/data/items_cong_phap.json", "assets/data/items_named.json", "assets/data/items_artifacts.json",
            "assets/data/items_treasures.json", "assets/data/crafting_talismans.json",
            "assets/data/crafting_diagrams.json", "assets/data/creatures_linh_thu.json", "assets/data/traits.json"])

COMMENT_FIELDS = {"note", "intent", "targets_note", "build_use", "notes"}
RULE_FIELDS = {"rule", "effect", "concept", "payload", "reads", "limits", "closes", "note", "intent", "targets_note",
               "build_use", "strikes", "desc", "description", "text", "notes"}
NAME_FIELDS = {"name", "name_hv", "gloss", "new"}
SKIP_FIELDS = {"lore", "story", "appearance", "backstory", "wants", "secret", "_doc", "doc", "history"}

P = {
    "removed": [
        r"\bat (a )?range\b", r"\bfrom range\b", r"\bdistance\b", r"\bclose(s|d)? (in|the gap)\b", r"\bclose range\b",
        r"\barm'?s length\b", r"\bfrom afar\b", r"\bout of reach\b", r"\bin reach\b",
        r"\bdisplace", r"\bknock(s|ed|ing)? ((the|a|your) foe )?(back|aside|away|down)\b",
        r"\b(push|pull|throw|hurl|fling)(s|es|ed|ing)? (the|a|your) foe (back|away|aside|in|close)\b",
        r"\bpush(es|ed|ing)? (back|away|aside)\b",
        r"\bpull(s|ed|ing)? (in|close|closer|toward|towards)\b", r"\bdrag(s|ged|ging)?\b", r"\bhaul(s|ed|ing)?\b",
        r"\boff[- ]balance\b", r"\bsweeps? (the foe|aside|away)\b", r"\bplanted\b",
        r"\brooted\b", r"\broots? (the|a|your) foe\b", r"\brooting\b", r"\broots? (it|them)\b", r"\btakes? root\b", r"\bpinned\b", r"\bpins? (the|a) foe\b",
        r"\bhooked\b", r"\bcannot leave\b", r"\bbound in place\b",
        # a laid object written as a self-counter charge ("a Banner charge", "Stele charges") is the new form
        r"\bfield pieces?\b", r"\bsteles?\b(?!-? ?charges?)", r"\bbanners?\b(?!-? ?charges?)",
        r"\bflags?\b(?!-? ?charges?)", r"\blaid out\b",
        r"\b(inside|within|into|enters?|entering|leaves?|under) (your|the|its|their|this|an?) (field|mist|ring|array|"
        r"formation|cloud|rain|haze|glow|zone|circle|domain|fog|snow|storm|net|web)\b",
        r"\bin (your|the|its) (field|mist|ring|zone|circle|fog|haze|net|web)\b", r"\bzones?\b",
        r"\bfoes? (inside|within|in it|under it)\b",
        r"\bspread(s|ing)? to\b", r"\bnearby\b", r"\bnearest\b", r"\badjacent\b", r"\bneighbou?r(ing)? foe",
        r"\bjumps? to\b", r"\bchains? to\b", r"\bbounces?\b", r"\banother foe\b", r"\bnext foe\b(?! art)",
        r"\bbehind the foe\b", r"\bin front of\b",
        r"\bsteps? (back|aside|forward|in|toward|towards|away|out)\b", r"\bretreat", r"\bflank",
    ],
    # often figurative ("Wood behind it", "beside the furnace", "a slow pace"): listed, rarely a position rule
    "soft": [r"\bbehind (you|them|it|him|her)\b", r"\bbeside\b", r"\bpaces?\b", r"\bcloser\b"],
    "postponed": [
        r"\ball(y|ies)\b", r"\balone\b", r"\bevery foe\b(?! art)", r"\ball foes\b", r"\beach foe\b(?! art)",
        r"\bfoes\b", r"\benem(y|ies)\b(?=s)|\benemies\b", r"\bsurrounded\b", r"\boutnumbered\b", r"\bother foes?\b",
    ],
    "rename": [r"\bStill\b", r"\bstands? still\b", r"\bheld still\b", r"\bstillness\b", r"\bMoving\b",
               r"\bfoe mov(es|ed)\b", r"\bfootwork\b"],
}
CI = {"removed": re.I, "postponed": re.I, "rename": 0, "soft": re.I}
PAT = {c: [re.compile(x, CI[c]) for x in v] for c, v in P.items()}
# the old engine term "Piece" (a field Piece), capitalised; a lower-case "piece" is a build piece and stays
PAT["removed"].append(re.compile(r"\bPieces?\b"))
# "stand still" etc. are case-insensitive even inside the case-sensitive rename class
PAT["rename"] = [re.compile(x, 0 if x in (r"\bStill\b", r"\bMoving\b") else re.I) for x in P["rename"]]

OLD_KEYS = {"at_range", "field_piece", "field_pieces", "foe_moved", "still_time", "displaced", "allies", "alone"}
OLD_TAGS = {"still", "moving", "footwork", "piece", "displace", "rooted", "pinned"}


def short_name(v):
    v = re.sub(r"\s*\([^)]*\)", "", str(v)).strip()
    return v if len(v) >= 4 else None


def walk(x, path, rec, out, names):
    """Collect (record id, field path, text) for every rule-bearing string; gather names on the way."""
    if isinstance(x, dict):
        rid = x.get("id") or x.get("key") or rec
        for k, v in x.items():
            if k in NAME_FIELDS and isinstance(v, str):
                n = short_name(v)
                if n:
                    names.add(n)
            if k in SKIP_FIELDS or k in NAME_FIELDS:
                continue
            if k == "tags" and isinstance(v, list):
                for t in v:
                    if isinstance(t, str) and t in OLD_TAGS:
                        out.append((str(rid), path + "." + k, "key", t))
                continue
            walk(v, path + "." + k, str(rid), out, names)
    elif isinstance(x, list):
        for i, v in enumerate(x):
            walk(v, path, rec, out, names)
    elif isinstance(x, str):
        field = path.rsplit(".", 1)[-1]
        if field in RULE_FIELDS or path.endswith(".do") or ".do." in path or field in ("read", "on"):
            out.append((rec, path, "text", x))
        for k in OLD_KEYS:
            if field in ("read", "on", "reads") and re.search(r"\b%s\b" % k, x):
                out.append((rec, path, "key", k))


def scan_text(text, names):
    t = text
    for n in names:
        if n in t:
            t = t.replace(n, " ")
    hits = []
    for c, pats in PAT.items():
        for p in pats:
            for m in p.finditer(t):
                hits.append((c, m.group(0)))
    return hits


def scan(files):
    rows = []
    for f in files:
        try:
            d = json.load(open(os.path.join(ROOT, f), encoding="utf-8"))
        except (OSError, ValueError) as e:
            print("skip %s: %s" % (f, e), file=sys.stderr)
            continue
        out, names = [], set()
        walk(d, "", os.path.basename(f), out, names)
        names = sorted(names, key=len, reverse=True)
        for rec, path, kind, val in out:
            if kind == "key":
                rows.append({"file": f, "record": rec, "field": path, "class": "key", "words": [val], "text": ""})
                continue
            hits = scan_text(val, names)
            for c in ("removed", "postponed", "rename", "soft"):
                w = sorted({h[1] for h in hits if h[0] == c}, key=str.lower)
                if w:
                    rows.append({"file": f, "record": rec, "field": path, "class": c, "words": w, "text": val})
    return rows


def files_of(globs):
    out = []
    for g in globs:
        out += sorted(os.path.relpath(x, ROOT).replace("\\", "/") for x in glob.glob(os.path.join(ROOT, g)))
    return out


def self_test():
    names = ["Still Water", "Rooted Form", "Planted Banner"]
    must = {"removed": ["Knocks the foe back 0.3 s", "while you are at range", "the foe is Rooted", "lay a stele",
                        "foes inside your mist", "spreads to a nearby foe", "a step back", "Pinned 2 s"],
            "postponed": ["you and your allies heal", "while you fight alone", "every foe takes 3 stacks", "all foes"],
            "rename": ["While you are Still, your ward", "a foe who stands still", "while Moving"]}
    bad = 0
    for c, texts in must.items():
        for t in texts:
            if c not in {h[0] for h in scan_text(t, names)}:
                print("MISSED %s: %r" % (c, t))
                bad += 1
    for t in ["Still Water restores health", "In Rooted Form you heal", "Planted Banner adds damage",
              "a 2 s delay on every foe art", "it still stands", "the art moves your timer"]:
        hits = scan_text(t, names)
        if hits:
            print("FALSE HIT %r: %s" % (t, hits))
            bad += 1
    print("self-test: %s" % ("ok" if not bad else "%d failures" % bad))
    return 1 if bad else 0


def main(argv):
    if "--self-test" in argv:
        return self_test()
    globs = DEPTH + SHIPPED
    if "--depth" in argv:
        globs = DEPTH
    if "--shipped" in argv:
        globs = SHIPPED
    files = files_of(globs)
    if "--sect" in argv:
        sk = argv[argv.index("--sect") + 1]
        files = [f for f in files if os.path.basename(f).startswith(sk + ".") or f.startswith("assets/")]
    rows = scan(files)
    if "--class" in argv:
        c = argv[argv.index("--class") + 1]
        rows = [r for r in rows if r["class"] == c]
    if "--json" in argv:
        print(json.dumps(rows, ensure_ascii=False, indent=1))
        return 0
    for r in rows:
        print("%-9s %s :: %s :: %s :: %s" % (r["class"], r["file"], r["record"], r["field"].lstrip("."),
                                              ", ".join(r["words"])))
    by = defaultdict(set)
    for r in rows:
        by[r["class"]].add((r["file"], r["record"]))
    src = Counter("shipped" if r["file"].startswith("assets/") else "depth" for r in rows)
    recs = {(r["file"], r["record"]) for r in rows}
    rule = {(r["file"], r["record"]) for r in rows
            if r["class"] != "soft" and r["field"].rsplit(".", 1)[-1] not in COMMENT_FIELDS}
    print("\nrecords with a non-soft hit in a rule field (not commentary): %d" % len(rule))
    print("\nfiles %d; hit lines %d (%s); records with a hit %d; by class (records): %s" % (
        len(files), len(rows), ", ".join("%s %d" % kv for kv in sorted(src.items())), len(recs),
        ", ".join("%s %d" % (c, len(v)) for c, v in sorted(by.items()))))
    return 0


if __name__ == "__main__":
    sys.exit(main(sys.argv[1:]))

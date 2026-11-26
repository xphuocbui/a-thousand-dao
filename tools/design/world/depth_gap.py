"""The world-depth gap report (ADR-0009 decision 10; production/plans/world-depth-implementation.md Stage 1).
Observations, not verdicts: it lists what the world-depth content (design/world/depth/) names that the game does not
have yet, and the state each record is in. The plan is done when every open list is empty.

States, per record:
  rule text   only the depth proposal exists (a concept, a name, rule prose)
  catalogue   promoted into the design catalogue (design/techniques, design/arts, design/items) but not exported
  game        in the game's data file (items_cong_phap, combat_library, items_named, combat_effects, ...)
  runs        in the game and nothing in it is marked not run (Effects: no not_run / pending; lines: fight.py
              compiles them, or a GDScript reader is seen for an out-of-fight key)
Only "runs" is closed.

Ownership: a record belongs to the depth file that defines it (sects/<key>.* or people/<group>.*). A reference (a
build naming a technique, a named item, a tie) belongs to the person who makes it; a reference to a record another
owner defines is listed again as cross-owner, so one sect's zero can be read apart from the others.

Fight verdicts come from fight.py itself (passive_effect and apply_static, the same code the game data is compiled
by). A tag scope fight.py accepts is still open when no art in combat_library.json carries the tag. A key with no
fight stat (or an out-of-fight key) is "reader seen" when `total("<key>"` appears in src/**/*.gd, the StatSheet read;
a key read another way is not seen, so that list is a lead, not a verdict.

Run:
  python -I tools/design/world/depth_gap.py                     totals, all owners
  python -I tools/design/world/depth_gap.py --sect bang_tam     one owner (a sect key or a people/ group)
  python -I tools/design/world/depth_gap.py --list effects      print one section's open entries
  python -I tools/design/world/depth_gap.py --json out.json     write every section in full
Exit 0 always.
"""
import argparse
import collections
import glob
import io
import json
import pathlib
import re
import sys
import contextlib

ROOT = pathlib.Path(__file__).resolve().parents[3]
D = ROOT / "design" / "world" / "depth"
DATA = ROOT / "assets" / "data"
sys.path.insert(0, str(ROOT / "tools" / "design" / "combat_sim"))
with contextlib.redirect_stdout(io.StringIO()):
    import fight as F  # noqa: E402

STAND_IN = re.compile(r"^(hoang|huyen|dia|thien)_[a-z_]+$")
# a new dated event is N-<owner>-<nn> (schema.md); a run such as "N-bang_tam-01, -02" names -02 by its short form
EVENT_ID = re.compile(r"\bN-([a-z_]+)-(\d+[a-z]?)\b")
EVENT_RUN = re.compile(r"\bN-([a-z_]+)-\d+[a-z]?((?:\s*(?:,|and|to|-)\s*-?\d+[a-z]?\b)+)")
# Stage 1 tie mapping (game kinds from src/gameplay/relationships/ties.gd PINNED and SOFT; user rulings 2026-11-26):
# "lover" is a soft friend tie started at a high strength; a former master or disciple is a soft tie, friend by
# default, rival or enmity where the authored note says they parted badly (the pinned su_do is the current pair only,
# since the game holds one living master).
TIE_MAP = {
    "parent": "kin", "child": "kin", "sibling": "kin", "cousin": "kin", "grandparent": "kin", "grandchild": "kin",
    "aunt_uncle": "kin", "niece_nephew": "kin", "in_law": "kin", "ancestor": "kin", "descendant": "kin",
    "master": "su_do", "disciple": "su_do", "former_master": "friend", "former_disciple": "friend",
    "sworn_sibling": "ket_nghia", "dao_partner": "dao_lu", "spouse": "dao_lu",
    "friend": "friend", "lover": "friend", "rival": "rival", "enemy": "enmity",
    "feud": "feud", "debt": "debt", "creditor": "debt",
}
# pinned for caps (ties.gd is_pinned): the pinned kinds, a blood feud, a favour owed. Every authored person is
# notable in the game (Ties.notable: cast_key set), so the cap is cap_notable (16) for all of them.
PINNED = {"kin", "su_do", "ket_nghia", "dao_lu", "companion", "feud"}
TIE_CAP = 16


def load(p):
    with open(p, encoding="utf-8") as fh:
        return json.load(fh)


def owner_of(path):
    return pathlib.Path(path).name.split(".")[0]


def depth_files(kind):
    # "*.<kind>" also matches the wave files (<key>.2.cast.json ...), so one glob per folder
    return sorted(set(glob.glob(str(D / "sects" / ("*." + kind))) + glob.glob(str(D / "people" / ("*." + kind)))))


def plain(name):
    return re.sub(r"\s*\([^)]*\)\s*$", "", str(name)).strip()


class Game:
    """What the game and the design catalogues hold now."""

    def __init__(self):
        cp = load(DATA / "items_cong_phap.json")
        self.techs = {t["id"]: t for t in cp["templates"]}
        lib = load(DATA / "combat_library.json")
        self.lib_arts = set(lib["arts"])
        self.lib_items = set(lib["items"])
        self.lib_tags = {t for a in lib["arts"].values() for t in a.get("tags", [])}
        self.named_recs = {n["id"]: n for n in load(DATA / "items_named.json")["named"]}
        self.named = set(self.named_recs)
        self.effects = load(DATA / "combat_effects.json")["effects"]
        self.bases = {b["id"] for b in load(DATA / "items_artifacts.json")["bases"]}
        dmap = load(DATA / "dao_do_map.json")
        self.nodes = {int(n["id"]) for n in dmap["nodes"]}
        self.starts = set(dmap["starts"])
        hist = load(DATA / "world_history.json")
        self.beasts = {b["key"] for b in hist.get("beasts", [])}
        self.people = {p["key"] for p in hist["people"]}
        self.events = {e["id"]: bool(e.get("text_vi")) for e in hist["events"]}   # closes with its Vietnamese text
        sets_file = DATA / "items_sets.json"
        self.sets = {s["id"] for s in load(sets_file)["sets"]} if sets_file.exists() else set()
        self.cat_techs = {t["id"] for f in glob.glob(str(ROOT / "design/techniques/catalogue-*.json")) for t in load(f)}
        self.cat_items = {i["id"] for f in glob.glob(str(ROOT / "design/items/catalogue-*.json")) for i in load(f)}
        self.cat_arts = set()
        for pat in ("design/arts/family-*.json", "design/arts/part-*.json", "design/items/common-arts.json"):
            for f in glob.glob(str(ROOT / pat)):
                self.cat_arts |= {a["id"] for a in load(f)}
        self.cat_sets = set()
        for f in glob.glob(str(ROOT / "design/items/sets-*.json")):
            self.cat_sets |= {s["id"] for s in load(f)}
        # art records the wish pass already wrote in the art DSL (builds/authored/auth-tech.json), not yet promoted
        self.authored_arts = {e["record"]["id"] for e in load(D / "builds/authored/auth-tech.json")["entries"]
                              if isinstance(e.get("record"), dict) and e["record"].get("id")}
        self.gd_text = "\n".join(p.read_text(encoding="utf-8") for p in (ROOT / "src").rglob("*.gd"))

    def tech_state(self, tid):
        if tid in self.techs:
            return "game"
        return "catalogue" if tid in self.cat_techs else "rule text"

    def art_state(self, aid):
        if aid in self.lib_arts:
            return "runs"
        if aid in self.cat_arts:
            return "catalogue"
        return "engine form" if aid in self.authored_arts else "rule text"

    def item_state(self, iid):
        if iid in self.named and iid in self.lib_items:
            return "game"
        return "catalogue" if iid in self.cat_items else "rule text"

    def effect_state(self, name):
        e = self.effects.get(plain(name))
        if e is None:
            return "rule text", ""
        for flag in ("not_run", "pending"):
            if e.get(flag):
                return "game", "%s: %s" % (flag, str(e[flag])[:120])
        return "runs", ("approx: %s" % str(e["approx"])[:120]) if e.get("approx") else ""

    def line_verdict(self, line):
        """fight.py's verdict on one modifier line {key, value, scope}: (state, note)."""
        key = line.get("key")
        unmod = []
        if key in F.OUT_OF_FIGHT:
            seen = ('total("%s"' % key) in self.gd_text
            return ("runs" if seen else "game"), ("out of fight; stat sheet reader seen" if seen else
                                                  "out of fight; no stat sheet reader seen")
        if key in F.STATIC:
            F.apply_static({"realm": "luyen_khi"}, [dict(line, scope=list(line.get("scope", [])))], "line", unmod)
        elif key in F.PASSIVE_MOD:
            F.passive_effect({"id": "line"}, unmod, lines=[dict(line, scope=list(line.get("scope", [])))],
                             what="line", prefix="gap")
        else:
            seen = ('total("%s"' % key) in self.gd_text
            return ("runs" if seen else "rule text"), ("no fight stat; stat sheet reader seen" if seen else
                                                       "no fight stat and no stat sheet reader seen")
        if unmod:
            return "game", "; ".join(u.split(": ", 1)[-1] for u in unmod)
        # a tag scope fight.py accepts still matches nothing if no art in the library carries the tag
        dead = [t for t in line.get("scope", []) if t not in F.ELEMENT_EN and t not in F.DTYPE_TAG
                and t not in ("buff", "debuff") and t not in self.lib_tags]
        if dead:
            return "game", "scope tag %s: no art in combat_library.json carries it" % ", ".join(dead)
        return "runs", ""


class Report:
    def __init__(self, game, only=None):
        self.g = game
        self.only = only
        self.sec = collections.defaultdict(list)   # section -> [entry dict]
        self.totals = collections.Counter()

    def add(self, section, owner, state, **kw):
        if self.only and owner != self.only and kw.get("ref_owner") != self.only:
            return
        self.totals[(section, state)] += 1
        self.sec[section].append(dict(owner=owner, state=state, **kw))

    # -- records -----------------------------------------------------------------------------------------------------
    def techniques(self):
        self.tech_owner = {}
        self.lineages = {}
        for f in depth_files("techniques.json"):
            own = owner_of(f)
            d = load(f)
            self.lineages[own] = d.get("lineage") or {}
            for t in d.get("techniques", []):
                self.tech_owner[t["id"]] = own
                self.add("techniques", own, self.g.tech_state(t["id"]), id=t["id"], tier=t.get("tier"),
                         kind=t.get("tech_kind"))
                for a in t.get("arts", []):
                    if isinstance(a, dict):
                        aid = a.get("id") or ""
                        self.add("arts_new", own, self.g.art_state(aid) if aid else "rule text", id=aid,
                                 name=a.get("new", ""), technique=t["id"])
                    else:
                        self.add("arts_ref", own, self.g.art_state(a), id=a, technique=t["id"])
                # once promoted, the depth file keeps the id only (ADR-0009 decision 1): read the game's record
                src = self.g.techs.get(t["id"], t)
                for p in (src.get("passives") or []) + (src.get("bonuses") or []):
                    if isinstance(p, dict) and "key" in p:
                        st, note = self.g.line_verdict(p)
                        self.add("lines", own, st, key=p["key"], scope=p.get("scope", []), where=t["id"], note=note)
                for e in t.get("effects") or []:
                    nm = e.get("name") if isinstance(e, dict) else e
                    self.effect_row(own, nm, t["id"], isinstance(e, dict) and bool(e.get("new")))

    def effect_row(self, own, name, where, new):
        """One Effect named by a record. A name marked new that is already an Effect's key stays open as a clash
        (ADR-0009 decision 3: a new Effect never takes an existing key)."""
        nm = plain(name)
        self.effect_names[nm].add(where)
        st, note = self.g.effect_state(nm)
        if new and nm in self.g.effects:
            st, note = "clash", "marked new, but %s is an existing Effect (source %s)" % (
                nm, self.g.effects[nm].get("source", "items"))
        self.add("effects", own, st, name=nm, where=where, new=new, note=note)

    def items(self):
        self.item_owner = {}
        for f in depth_files("items.json"):
            own = owner_of(f)
            d = load(f)
            for i in d.get("items", []):
                self.item_owner[i["id"]] = own
                note = ""
                if not i.get("base"):
                    note = "no base"
                elif i["base"] not in self.g.bases:
                    note = "base %s unknown" % i["base"]
                self.add("items", own, self.g.item_state(i["id"]), id=i["id"], kind=i.get("kind"), note=note)
                for m in self.g.named_recs.get(i["id"], i).get("modifiers", []):
                    st, n = self.g.line_verdict(m)
                    self.add("lines", own, st, key=m["key"], scope=m.get("scope", []), where=i["id"], note=n)
                for e in i.get("effects", []):
                    if isinstance(e, dict):
                        self.effect_row(own, e.get("name", ""), i["id"], bool(e.get("new")))
                    else:
                        self.effect_row(own, e, i["id"], False)
                for a in i.get("arts", []) or []:
                    aid = a.get("id") if isinstance(a, dict) else a
                    self.add("arts_ref", own, self.g.art_state(aid), id=aid, item=i["id"])
            for s in d.get("sets", []):
                st = "game" if s["id"] in self.g.sets else ("catalogue" if s["id"] in self.g.cat_sets else "rule text")
                self.add("sets", own, st, id=s["id"], pieces=len(s.get("pieces", [])))
                for b in s.get("bonuses", []):
                    for m in b.get("modifiers") or []:
                        stl, n = self.g.line_verdict(m)
                        self.add("lines", own, stl, key=m["key"], scope=m.get("scope", []), where=s["id"], note=n)
                    if b.get("effect"):
                        self.effect_row(own, b["effect"].split(":")[0], s["id"], True)

    def authored(self):
        """The 94 authored wishes (builds/authored): their modifier lines get fight.py's verdict; their engine words
        are the new_vocab / engine_additions strings."""
        for f in sorted((D / "builds" / "authored").glob("auth-*.json")):
            d = load(f)
            for e in d.get("entries", []):
                r = e.get("record") or {}
                for m in r.get("modifiers", []) if isinstance(r, dict) else []:
                    st, n = self.g.line_verdict(m)
                    self.add("lines", "authored", st, key=m["key"], scope=m.get("scope", []), where=e.get("wish"), note=n)
                # an authored Effect already named by an item, set or technique is that record's row, not a second one
                if e.get("kind") == "effect" and isinstance(r, dict) and r.get("name")                         and plain(r["name"]) not in self.effect_names:
                    self.effect_row("authored", r["name"], e.get("wish"), True)
                words = list(e.get("new_vocab") or [])
                ea = r.get("engine_additions") if isinstance(r, dict) else None
                if isinstance(ea, list):
                    words += ea
                elif ea and not str(ea).lower().startswith("none"):
                    words.append(ea)
                for w in words:
                    self.add("engine_words", "authored", "rule text", word=str(w)[:200], where=e.get("wish"))
            for x in d.get("refused", []) + d.get("not_authored", []):
                self.add("wishes_open", "authored", "rule text", wish=x.get("wish") if isinstance(x, dict) else str(x),
                         file=f.name)

    def beasts(self):
        for f in depth_files("beasts.json"):
            own = owner_of(f)
            for b in load(f).get("beasts", []):
                self.add("beasts", own, "game" if b["key"] in self.g.beasts else "rule text", id=b["key"],
                         owner_id=b.get("owner_id"))

    # -- references ----------------------------------------------------------------------------------------------------
    def tech_ref(self, own, who, slot, tid, note=""):
        if not tid:
            return
        if STAND_IN.match(tid):
            self.add("stand_ins", own, "rule text", person=who, slot=slot, tech=tid, note=note[:160])
            return
        state = self.g.tech_state(tid)
        if tid not in self.tech_owner and tid not in self.g.techs and tid not in self.g.cat_techs:
            self.add("unknown_ids", own, "rule text", person=who, kind="technique", id=tid, slot=slot)
            return
        ro = self.tech_owner.get(tid, "game")
        if ro not in (own, "game"):
            self.add("cross_owner", own, state, person=who, kind="technique", id=tid, ref_owner=ro)

    def people(self):
        self.person_owner, ties = {}, {}
        for f in depth_files("cast.json"):
            own = owner_of(f)
            for p in load(f).get("people", []):
                self.person_owner[p["key"]] = own
                ties[p["key"]] = (own, p)
        for key, (own, p) in ties.items():
            if not p.get("alive"):
                continue
            b = p.get("build") or {}
            self.tech_ref(own, key, "main", (b.get("main") or {}).get("tech", ""), b.get("note", ""))
            for i, a in enumerate(b.get("aux") or []):
                self.tech_ref(own, key, "aux%d" % (i + 1), a.get("tech", ""), b.get("note", ""))
            for g in b.get("gear") or []:
                if "named" in g:
                    nid = g["named"]
                    if nid not in self.item_owner and nid not in self.g.named:
                        self.add("unknown_ids", own, "rule text", person=key, kind="named item", id=nid)
                    elif self.item_owner.get(nid, own) != own:
                        self.add("cross_owner", own, self.g.item_state(nid), person=key, kind="named item", id=nid,
                                 ref_owner=self.item_owner[nid])
                elif g.get("base") not in self.g.bases:
                    self.add("unknown_ids", own, "rule text", person=key, kind="base", id=g.get("base"))
            tr = b.get("tree") or {}
            if tr.get("start") and tr["start"] not in self.g.starts:
                self.add("unknown_ids", own, "rule text", person=key, kind="tree start", id=tr["start"])
            for n in tr.get("targets") or []:
                if int(n) not in self.g.nodes:
                    self.add("unknown_ids", own, "rule text", person=key, kind="tree node", id=n)
            # ties (Stage 1 mapping; caps: NPC Relationships rule 5, notable 16 / ordinary 6)
            partners = {}
            for t in p.get("ties") or []:
                k = TIE_MAP.get(t.get("kind"))
                if k is None:
                    self.add("ties_unmapped", own, "rule text", person=key, kind=t.get("kind"), to=t.get("to"))
                    continue
                if t.get("to") not in ties and t.get("to") not in self.g.people:
                    self.add("unknown_ids", own, "rule text", person=key, kind="tie target", id=t.get("to"))
                # the game keeps one record per pair; a pair is pinned if any of its ties is
                partners[t.get("to")] = partners.get(t.get("to"), False) or k in PINNED
            if len(partners) > TIE_CAP:
                pinned = sum(partners.values())
                self.add("ties_over_cap", own, "rule text", person=key, tier=p.get("tier"), partners=len(partners),
                         pinned=pinned, soft=len(partners) - pinned)
        for own, lin in self.lineages.items():
            fields = [("main", lin.get("main")), ("inner", lin.get("inner")), ("outer", lin.get("outer")),
                      ("body", lin.get("body"))] + [("secret", s.get("id")) for s in lin.get("secret") or []]
            for slot, tid in fields:
                if tid:
                    self.tech_ref(own, "lineage", slot, tid)
            for n in lin.get("tree_route") or []:
                if int(n) not in self.g.nodes:
                    self.add("unknown_ids", own, "rule text", person="lineage", kind="tree node", id=n)

    def events(self):
        """The new dated events (N-<owner>-<nn>) named anywhere in the depth content (review/ excluded), against the
        structured files design/world/depth/events/<owner>.events.json (Stage 1)."""
        structured = set()
        for f in glob.glob(str(D / "events" / "*.events.json")):
            structured |= {e["id"] for e in load(f).get("events", [])}
        seen = set()
        for f in sorted(D.rglob("*")):
            if f.is_dir() or "review" in f.parts or "events" in f.parts or f.suffix not in (".md", ".json"):
                continue
            text = f.read_text(encoding="utf-8")
            for m in EVENT_ID.finditer(text):
                seen.add((m.group(1), m.group(2)))
            for m in EVENT_RUN.finditer(text):
                for n in re.findall(r"(\d+[a-z]?)", m.group(2)):
                    seen.add((m.group(1), n.zfill(2) if n.isdigit() else n))
        for own, n in sorted(seen):
            eid = "N-%s-%s" % (own, n)
            state = ("runs" if self.g.events.get(eid) else "game") if eid in self.g.events else                 ("structured" if eid in structured else "rule text")
            self.add("events", own, state, id=eid)

    def run(self):
        self.effect_names = collections.defaultdict(set)
        self.techniques()
        self.items()
        self.authored()
        self.shared_effect_names = {n: sorted(v) for n, v in self.effect_names.items() if len(v) > 1}
        self.beasts()
        self.people()
        self.events()
        return self


SECTIONS = ["techniques", "arts_new", "arts_ref", "items", "sets", "effects", "lines", "beasts", "events",
            "stand_ins", "unknown_ids", "cross_owner", "ties_unmapped", "ties_over_cap", "engine_words", "wishes_open"]
# sections whose every entry is open (a reference to fix or a word to build), whatever its state
ALWAYS_OPEN = {"stand_ins", "unknown_ids", "ties_unmapped", "engine_words", "wishes_open"}


def is_open(section, e):
    if section in ALWAYS_OPEN:
        return True
    if section == "ties_over_cap":
        return True   # an observation: the authored overflow rule (NPC Relationships rule 5) decides each
    if section == "cross_owner":
        return e["state"] not in ("runs", "game")
    return e["state"] != "runs" and not (section in ("techniques", "items", "sets", "beasts", "events")
                                         and e["state"] == "game")


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--sect", help="one owner: a sect key or a people/ group name")
    ap.add_argument("--list", choices=SECTIONS, help="print one section's open entries")
    ap.add_argument("--json", help="write every section, in full, to this path")
    a = ap.parse_args()
    r = Report(Game(), a.sect).run()
    print("world-depth gap report%s (observations; open = not yet running in the game)" %
          (" for " + a.sect if a.sect else ""))
    print("%-14s %7s %7s  %s" % ("section", "total", "open", "by state"))
    for s in SECTIONS:
        es = r.sec.get(s, [])
        st = collections.Counter(e["state"] for e in es)
        print("%-14s %7d %7d  %s" % (s, len(es), sum(1 for e in es if is_open(s, e)),
                                     ", ".join("%s %d" % kv for kv in sorted(st.items()))))
    if not a.sect:
        print("Effect names on more than one record: %d (%s)" % (len(r.shared_effect_names), "; ".join(
            "%s x%d" % (n, len(v)) for n, v in sorted(r.shared_effect_names.items()))))
        rule_text = sum(1 for s in ("arts_new", "effects") for e in r.sec.get(s, []) if e["state"] == "rule text")
        print("records still rule text, whose engine words are unknown until written: %d" % rule_text)
    if a.list:
        for e in r.sec.get(a.list, []):
            if is_open(a.list, e):
                print(json.dumps(e, ensure_ascii=False))
    if a.json:
        out = {"sections": {s: r.sec.get(s, []) for s in SECTIONS},
               "shared_effect_names": r.shared_effect_names}
        pathlib.Path(a.json).write_text(json.dumps(out, ensure_ascii=False, indent=1) + "\n", encoding="utf-8")
        print("wrote", a.json)
    return 0


if __name__ == "__main__":
    sys.exit(main())

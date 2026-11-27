"""The world-depth reader of export_world.py (ADR-0009 decision 5; world-depth plan Stage 7, 2026-11-26).

For the sects named with `--sect` (or every sect and outside group with `--sect all`), it reads design/world/depth/:
- people from sects/<key>.cast.json and its wave files (<key>.<n>.cast.json). A depth record wins on every field it
  carries; an old cast record's other fields are kept; `changed` notes are dropped;
- builds from each person's `build`, `root`, `thien_phu` and `stage`, in the cast_builds shape;
- ties, mapped to the game's kinds by depth_gap.TIE_MAP, one record per pair, with the cap trimmed by strength
  (pinned ties kept);
- beasts from sects/<key>.beasts.json;
- events from events/<key>.events.json.

The export's own checks then run over the merged cast as before. Emits through the exporter's err and warn.
"""
import glob
import json
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import depth_gap  # noqa: E402  (TIE_MAP, PINNED, TIE_CAP: one mapping for the gap report and the export)

ROOT = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
D = os.path.join(ROOT, "design", "world", "depth")
WORLD_DATA_VERSION = 1   # ADR-0009 decision 9: raised only on a break an old save cannot hold

# authored start strength of a soft tie (Ties.write_soft delta; npc_relationships.json soft start is 25 / -10 / -50)
SOFT_START = {"friend": 40, "rival": 40, "enmity": 50}
LOVER_START = 70        # DECISIONS-2026-11-26: lover is a high-strength soft friend tie
FORMER_START = 30       # a former master or disciple: a soft tie
DEBT_START = 30
# a former pair that "parted badly" (DECISIONS-2026-11-26): the note decides rival or enmity
ENMITY_WORDS = ("hate", "betray", "killed", "murder", "cursed", "enemy", "vengeance", "revenge")
RIVAL_WORDS = ("parted badly", "quarrel", "broke with", "cast out", "expelled", "left him", "left her", "bitter",
               "grudge", "rival", "resent")
PERSON_KEEP = ("tier", "stage", "appearance", "wants", "secret", "birthplace", "beasts")


def load(path):
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


def owners(arg):
    """The owner keys a --sect argument names (comma list, or all)."""
    every = sorted({os.path.basename(p).split(".")[0]
                    for p in glob.glob(os.path.join(D, "sects", "*.cast.json")) + glob.glob(os.path.join(D, "people", "*.cast.json"))})
    if arg == "all":
        return every
    keys = [k.strip() for k in arg.split(",") if k.strip()]
    bad = [k for k in keys if k not in every]
    if bad:
        raise SystemExit("--sect: no depth cast for %s (known: %s)" % (", ".join(bad), ", ".join(every)))
    return keys


def owner_files(key, kind):
    out = []
    for folder in ("sects", "people"):
        out += glob.glob(os.path.join(D, folder, "%s.%s" % (key, kind)))
        out += glob.glob(os.path.join(D, folder, "%s.*.%s" % (key, kind)))
    return sorted(set(out))


def former_kind(note):
    n = (note or "").lower()
    if any(w in n for w in ENMITY_WORDS):
        return "enmity"
    if any(w in n for w in RIVAL_WORDS):
        return "rival"
    return "friend"


class Depth:
    """The depth content of the exported owners, merged into an Export (tools/design/world/export_world.py)."""

    def __init__(self, ex, keys):
        self.ex, self.keys = ex, keys
        self.people_src = []          # depth person records, in file order
        for k in keys:
            for f in owner_files(k, "cast.json"):
                self.people_src += load(f)["people"]
        self.place_ids = {p["id"] for p in ex.cont["places"]}
        self.former_log = []

    # -- people --------------------------------------------------------------------------------------------------
    def merge_people(self, people):
        """Merge the depth people into the exported list (in place); returns the keys merged."""
        by = {r["key"]: r for r in people}
        merged = []
        for p in self.people_src:
            rec = by.get(p["key"])
            if rec is None:
                rec = {"key": p["key"]}
                people.append(rec)
                by[p["key"]] = rec
            rec.update({"name": p["name_hv"], "name_han": p.get("name_han", ""), "gloss": p.get("gloss", ""),
                        "sex": p["sex"], "born": p["born"], "alive": bool(p["alive"]), "sect": p.get("sect") or "",
                        "rank": p.get("rank") or "", "role": p.get("role", "")})
            where = "depth person %s" % p["key"]
            if p["alive"]:
                rec["realm"] = p["realm"]
                for k in ("peak_realm", "died", "cause", "record"):
                    rec.pop(k, None)
                home = p.get("home")
                if home not in self.place_ids:
                    self.ex.err("%s: home %r is not a place id" % (where, home))
                rec["home"] = home
                tr = p.get("traits", {})
                rec["traits"] = {"personality": tr.get("personality", []), "calling": tr.get("calling", ""),
                                 "fate_given": tr.get("fate_given", []) or [], "gained": tr.get("gained", []) or []}
            else:
                rec["peak_realm"] = p.get("peak_realm") or p.get("realm")
                rec["died"] = p.get("died")
                rec["cause"] = p.get("cause", "")
                rec["record"] = True
                for k in ("realm", "home", "traits"):
                    rec.pop(k, None)
                sk = rec["sect"]
                if sk and sk not in self.ex.sect_keys and sk not in self.ex.fallen_keys:
                    # a sect gone before the game's history begins (Lãnh Hương Các, 724): the record keeps no sect key
                    self.ex.warn("%s: sect %s is not a game sect or fallen sect; the dead record keeps no sect key" % (where, sk))
                    rec["sect"] = ""
            for k in PERSON_KEEP:
                if p.get(k) not in (None, "", []):
                    rec[k] = p[k]
            if p.get("master"):
                rec["master"] = p["master"]
            else:
                rec.pop("master", None)
            merged.append(p["key"])
        return merged

    def check_masters(self, people_by):
        """A master the world does not hold (a sect not exported yet) is dropped with an observation."""
        for p in self.people_src:
            m = p.get("master")
            if m and m not in people_by:
                people_by[p["key"]].pop("master", None)
                self.ex.warn("depth person %s: master %s is not in the world yet (their sect is not exported)" % (p["key"], m))

    # -- builds --------------------------------------------------------------------------------------------------
    def builds(self):
        out = {}
        for p in self.people_src:
            if not p.get("alive") or not p.get("build"):
                continue
            b = p["build"]
            rec = {"root": p.get("root", {}), "archetype": b.get("archetype"), "stage": int(p.get("stage", 0)),
                   "main": b.get("main", {}), "aux": b.get("aux", []), "gear": b.get("gear", []),
                   "skills": b.get("skills", {})}
            if p.get("thien_phu"):
                rec["thien_phu"] = p["thien_phu"]
            tree = b.get("tree") or {}
            if tree.get("start") or tree.get("targets"):
                rec["tree"] = {k: tree[k] for k in ("start", "targets") if tree.get(k) not in (None, "", [])}
            if b.get("note"):
                rec["note"] = b["note"]
            out[p["key"]] = rec
        return out

    # -- ties ----------------------------------------------------------------------------------------------------
    def ties(self, people_by):
        """[{a, b, kind, s}] for the game's Ties writers (WorldBuilder._step_ties); master pairs travel as `master`."""
        pairs = {}
        skipped_missing = 0
        skipped_dead = 0
        for p in self.people_src:
            if not p.get("alive"):
                continue
            for t in p.get("ties", []):
                dk, to = t.get("kind"), t.get("to")
                k = depth_gap.TIE_MAP.get(dk)
                if k is None:
                    self.ex.err("depth person %s: tie kind %r has no game kind" % (p["key"], dk))
                    continue
                if k == "su_do":
                    continue   # the current pair is the person's `master` field (Ties.set_master)
                o = people_by.get(to)
                if o is None:
                    skipped_missing += 1
                    continue
                if not o.get("alive"):
                    skipped_dead += 1
                    continue
                s = 0
                if dk in ("former_master", "former_disciple"):
                    k = former_kind(t.get("note"))
                    s = FORMER_START
                    self.former_log.append("%s -> %s: %s" % (p["key"], to, k))
                elif dk == "lover":
                    s = LOVER_START
                elif k in SOFT_START:
                    s = SOFT_START[k]
                elif k == "debt":
                    s = DEBT_START
                a, b = (p["key"], to) if dk != "creditor" else (to, p["key"])   # debt: a owes b
                key = tuple(sorted((a, b)))
                rank = (2 if k in depth_gap.PINNED else 1 if k in ("feud", "debt") else 0, s)
                old = pairs.get(key)
                if old is None or rank > old[0]:
                    pairs[key] = (rank, {"a": a, "b": b, "kind": k, "s": s})
        out = [v[1] for v in pairs.values()]
        # the cap (16, every authored person is notable): pinned ties stay; soft-only ties (including debt) are kept by
        # strength up to soft_limit = max(soft_reserve.notable=4, cap_notable=16 - pinned_count) (ties.gd:107,167,222).
        su_do_pairs = set()
        for k, rec in people_by.items():
            if not rec.get("alive"):
                continue
            m = rec.get("master")
            if m and m != k and people_by.get(m, {}).get("alive"):
                su_do_pairs.add((min(k, m), max(k, m)))
        pinned_pairs = su_do_pairs | {tuple(sorted((t["a"], t["b"]))) for t in out if t["kind"] in depth_gap.PINNED}
        pinned_count = {}
        for a, b in pinned_pairs:
            pinned_count[a] = pinned_count.get(a, 0) + 1
            pinned_count[b] = pinned_count.get(b, 0) + 1
        while True:
            soft_people = sorted({x for t in out if tuple(sorted((t["a"], t["b"]))) not in pinned_pairs for x in (t["a"], t["b"])})
            trimmed_any = False
            for person in soft_people:
                soft_lim = max(4, depth_gap.TIE_CAP - pinned_count.get(person, 0))
                soft_only = [t for t in out if person in (t["a"], t["b"]) and tuple(sorted((t["a"], t["b"]))) not in pinned_pairs]
                over = len(soft_only) - soft_lim
                if over <= 0:
                    continue
                soft_only.sort(key=lambda t: (t["s"], t["a"], t["b"]))
                for t in soft_only[:over]:
                    out.remove(t)
                trimmed_any = True
                self.ex.warn("depth person %s: %d soft ties over soft_limit %d (pinned %d, cap %d); %d trimmed by strength"
                             % (person, over, soft_lim, pinned_count.get(person, 0), depth_gap.TIE_CAP, over))
            if not trimmed_any:
                break
        if skipped_missing:
            self.ex.warn("%d depth ties name someone not in the world yet (their sect is not exported)" % skipped_missing)
        if skipped_dead:
            self.ex.warn("%d depth ties name a dead person (ties live between living cultivators only)" % skipped_dead)
        out.sort(key=lambda t: (t["a"], t["b"]))
        return out

    # -- beasts --------------------------------------------------------------------------------------------------
    def beasts(self, people_by):
        out = []
        for k in self.keys:
            for f in owner_files(k, "beasts.json"):
                for b in load(f)["beasts"]:
                    if b.get("owner_id") not in people_by:
                        self.ex.err("beast %s: owner %s is not in the world" % (b["key"], b.get("owner_id")))
                        continue
                    if b.get("home") not in self.place_ids:
                        self.ex.err("beast %s: home %r is not a place id" % (b["key"], b.get("home")))
                    out.append({k2: v for k2, v in b.items() if k2 not in ("status", "authored")})
        return out

    # -- events --------------------------------------------------------------------------------------------------
    def events(self, people_by):
        out = []
        seen_paths = set()
        for k in self.keys:
            for cand in dict.fromkeys((k, k.replace("-", "_"))):
                p = os.path.join(D, "events", "%s.events.json" % cand)
                if not os.path.exists(p) or p in seen_paths:
                    continue
                seen_paths.add(p)
                for e in load(p)["events"]:
                    rec = {"id": e["id"], "tier": e.get("tier") or "annal", "year": int(e["year"]), "kind": e["kind"],
                           "people": [x for x in e.get("people", []) if x in people_by],
                           "sects": e.get("sects", []), "text_vi": e["text_vi"], "text_en": e.get("text_en", "")}
                    if e.get("place") is not None:
                        if e["place"] not in self.place_ids:
                            self.ex.err("event %s: place %r is not a place id" % (e["id"], e["place"]))
                        rec["place"] = e["place"]
                    if e.get("secret") or e.get("tier") == "hidden":
                        rec["secret"] = True
                    if e.get("story_kind"):
                        rec["story_kind"] = e["story_kind"]
                    missing = [x for x in e.get("people", []) if x not in people_by]
                    if missing:
                        self.ex.warn("event %s: %s not in the world yet; left out of its people" % (e["id"], ", ".join(missing)))
                    out.append(rec)
        return out


def version_files():
    """The depth files the data_version hash adds (ADR-0009 decision 9)."""
    return sorted(glob.glob(os.path.join(D, "**", "*.json"), recursive=True))

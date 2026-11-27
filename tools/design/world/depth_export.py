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
import re
import sys
import unicodedata

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import depth_gap  # noqa: E402  (TIE_MAP, PINNED, TIE_CAP: one mapping for the gap report and the export)

ROOT = os.path.normpath(os.path.join(HERE, "..", "..", ".."))
D = os.path.join(ROOT, "design", "world", "depth")
TRAITS_PATH = os.path.join(ROOT, "assets", "data", "traits.json")
WORLD_DATA_VERSION = 1   # ADR-0009 decision 9: raised only on a break an old save cannot hold

# NPC Traits rule 2a over-band trim constants (design/gdd/npc-traits.md:89-99, AC-NT-53)
TRAIT_BAND_MAX = {"A": 12, "B": 8, "C": 6}
TRIM_KIND_PRIORITY = {
    "gained": 0,
    "coping": 1,
    "lifestyle": 2,
    "fate_given": 3,
    "path": 4,
    "talent": 5,
    "health": 6,
}
TEXT_FIELDS = ("backstory", "role", "gloss", "wants", "secret", "appearance")

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
# Sects rule 20d (2026-11-25, R3 approved) & each no-lean sect page §6:
# 4 căn cốt (muc_van, trac_anh, tuan_tung, xuyen_lam), 2 thần hồn (thu_phan, van_hac), 1 ngộ tính (tam_kiem),
# 1 đạo tâm (van_khoi), 3 mapped tests (nhan_tran line -> dao_tam, vong_trieu oath -> dao_tam, chan_kim eye -> ngo_tinh);
# 5 also recruit by kin (chan_kim, nhan_tran, trac_anh, vong_trieu, xuyen_lam).
NO_LEAN_RECRUIT_BY = {
    "chan_kim":   {"talent": "ngo_tinh", "kin": True},
    "muc_van":    {"talent": "can_cot",  "kin": False},
    "nhan_tran":  {"talent": "dao_tam",  "kin": True},
    "tam_kiem":   {"talent": "ngo_tinh", "kin": False},
    "thu_phan":   {"talent": "than_hon", "kin": False},
    "trac_anh":   {"talent": "can_cot",  "kin": True},
    "tuan_tung":  {"talent": "can_cot",  "kin": False},
    "van_hac":    {"talent": "than_hon", "kin": False},
    "van_khoi":   {"talent": "dao_tam",  "kin": False},
    "vong_trieu": {"talent": "dao_tam",  "kin": True},
    "xuyen_lam":  {"talent": "can_cot",  "kin": True},
}
VALID_RECRUIT_TALENTS = {"can_cot", "than_hon", "ngo_tinh", "dao_tam"}


def sect_lineage_elements(key, fallback_leans):
    """Lineage element/variant ids from design/world/depth/sects/<key>.techniques.json (lineage.elements),
    falling back to the sect's leans when the file or field is absent."""
    path = os.path.join(D, "sects", "%s.techniques.json" % key)
    if os.path.exists(path):
        lin = load(path).get("lineage") or {}
        if "elements" in lin and lin["elements"] is not None:
            return list(lin["elements"])
    return list(fallback_leans)


def sect_recruit_by(key):
    """No-lean recruiting rule (Sects rule 20d) for the 11 no-lean sects, or None for lean sects."""
    rec = NO_LEAN_RECRUIT_BY.get(key)
    return dict(rec) if rec is not None else None


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


def _slug(name):
    n = unicodedata.normalize("NFKD", str(name).lower().replace("đ", "d")).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "_", n).strip("_")


def _total_traits(tr):
    return (
        len(tr.get("personality") or [])
        + (1 if tr.get("calling") else 0)
        + (1 if tr.get("upbringing") else 0)
        + len(tr.get("talent") or [])
        + len(tr.get("path") or [])
        + (1 if tr.get("lifestyle") else 0)
        + len(tr.get("health") or [])
        + (1 if tr.get("coping") else 0)
        + len(tr.get("fate_given") or [])
        + len(tr.get("gained") or [])
    )


class TraitIndex:
    """Indexed view of assets/data/traits.json for v1/v2 validation, retired-fate migration, and Rule 2a trim."""

    def __init__(self, data):
        self.data = data
        self.v1_by_name = {}
        self.v1_by_id = {}
        for k in ("personality", "callings", "fate", "gained"):
            self.v1_by_name[k] = {x["name"]: x for x in data.get(k, [])}
            self.v1_by_id[k] = {x["id"]: x for x in data.get(k, [])}
        self.v2_by_id = {}
        for k in ("upbringing", "talent", "path", "lifestyle", "health", "coping"):
            self.v2_by_id[k] = {x["id"]: x for x in data.get(k, [])}
        self.retired_fates = {k: {"id": str(v["id"]), "tier": int(v["tier"])} for k, v in data.get("retired_fates", {}).items()}
        self.opposed_of = {}
        for pair in data.get("opposed_v2", []):
            if len(pair) == 2:
                a, b = pair
                self.opposed_of.setdefault(a, set()).add(b)
                self.opposed_of.setdefault(b, set()).add(a)

    def resolve_v1(self, kind, raw):
        if raw in self.v1_by_name[kind]:
            return self.v1_by_name[kind][raw]
        s = _slug(raw)
        if s in self.v1_by_id[kind]:
            return self.v1_by_id[kind][s]
        return None

    def retired_replacement(self, raw):
        return self.retired_fates.get(_slug(raw))

    def search_terms(self, kind, val):
        """Candidate ids, English names, tier names, and Vietnamese names to look for in a person's text."""
        terms = []
        if kind in ("gained", "fate_given"):
            v1_kind = "gained" if kind == "gained" else "fate"
            rec = self.resolve_v1(v1_kind, val)
            if rec:
                terms.extend([rec["id"], rec["id"].replace("_", " "), rec["id"].replace("_", "-"),
                              rec["name"], rec.get("name_vi", "")])
            else:
                terms.append(str(val))
        elif kind == "talent":
            tid = val["id"]
            tier = int(val["tier"])
            rec = self.v2_by_id["talent"].get(tid)
            terms.extend([tid, tid.replace("_", " "), tid.replace("_", "-")])
            if rec:
                tn = rec.get("tier_names") or [s.strip() for s in rec.get("name", "").split("/")]
                tn_vi = rec.get("tier_names_vi") or [s.strip() for s in rec.get("name_vi", "").split("/")]
                if 1 <= tier <= len(tn):
                    terms.append(tn[tier - 1])
                if 1 <= tier <= len(tn_vi):
                    terms.append(tn_vi[tier - 1])
        else:
            rec = self.v2_by_id.get(kind, {}).get(val)
            terms.extend([str(val), str(val).replace("_", " "), str(val).replace("_", "-")])
            if rec:
                terms.extend([rec.get("name", ""), rec.get("name_vi", "")])
        return [t.strip().lower() for t in terms if t and t.strip()]


def load_trait_index():
    return TraitIndex(load(TRAITS_PATH))


def migrate_retired_fates(traits, tier, idx, where, warn_fn):
    """Migrate retired v1 fates in fate_given into talent tiers (Rule 2, AC-NT-49)."""
    fates = list(traits.get("fate_given") or [])
    talents = [dict(x) for x in (traits.get("talent") or [])]
    talent_cap = 3 if tier == "A" else 2
    kept_fates = []
    for fg in fates:
        rep = idx.retired_replacement(fg)
        if rep is None:
            kept_fates.append(fg)
            continue
        fam_id = rep["id"]
        rep_tier = rep["tier"]
        existing = next((t for t in talents if t["id"] == fam_id), None)
        if existing is not None:
            old_t = int(existing["tier"])
            existing["tier"] = max(old_t, rep_tier)
            warn_fn("%s: migrated retired fate %s -> %s tier %d (merged from tier %d)" % (where, fg, fam_id, existing["tier"], old_t))
        else:
            opps = idx.opposed_of.get(fam_id, set())
            dropped_opps = [t["id"] for t in talents if t["id"] in opps]
            if dropped_opps:
                talents = [t for t in talents if t["id"] not in opps]
                warn_fn("%s: retired fate %s -> %s tier %d dropped opposed talent(s) %s" % (where, fg, fam_id, rep_tier, ", ".join(dropped_opps)))
            talents.append({"id": fam_id, "tier": rep_tier})
            warn_fn("%s: migrated retired fate %s -> %s tier %d" % (where, fg, fam_id, rep_tier))
            while len(talents) > talent_cap:
                talents.sort(key=lambda t: (int(t["tier"]), t["id"]))
                dropped = talents.pop(0)
                warn_fn("%s: retired fate migration exceeded talent cap %d; dropped %s tier %d" % (where, talent_cap, dropped["id"], dropped["tier"]))
    traits["fate_given"] = kept_fates
    traits["talent"] = talents


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
        self.trim_log = []
        self.trait_idx = load_trait_index()

    def _normalize_traits(self, raw_tr, where):
        tr = raw_tr or {}
        raw_health = tr.get("health")
        if raw_health is None or raw_health == "":
            health = []
        elif isinstance(raw_health, str):
            health = [raw_health]
        elif isinstance(raw_health, list):
            health = [str(x) for x in raw_health if x]
        else:
            self.ex.err("%s: invalid health field %r" % (where, raw_health))
            health = []

        raw_coping = tr.get("coping")
        if raw_coping is None or raw_coping == "":
            coping = ""
        elif isinstance(raw_coping, str):
            coping = raw_coping
        elif isinstance(raw_coping, list):
            vals = [str(x) for x in raw_coping if x]
            if len(vals) > 1:
                self.ex.err("%s: %d coping traits (cap 1, NPC Traits rule 2a)" % (where, len(vals)))
            coping = vals[0] if vals else ""
        else:
            self.ex.err("%s: invalid coping field %r" % (where, raw_coping))
            coping = ""

        talents = []
        for x in (tr.get("talent") or []):
            if isinstance(x, dict) and "id" in x and "tier" in x:
                talents.append({"id": str(x["id"]), "tier": int(x["tier"])})
            else:
                self.ex.err("%s: malformed talent entry %r" % (where, x))

        return {
            "personality": [str(x) for x in (tr.get("personality") or []) if x],
            "calling": str(tr.get("calling") or ""),
            "fate_given": [str(x) for x in (tr.get("fate_given") or []) if x],
            "gained": [str(x) for x in (tr.get("gained") or []) if x],
            "upbringing": str(tr.get("upbringing") or ""),
            "talent": talents,
            "path": [str(x) for x in (tr.get("path") or []) if x],
            "lifestyle": str(tr.get("lifestyle") or ""),
            "health": health,
            "coping": coping,
        }

    def _validate_traits(self, tr, tier, where):
        """AC-NT-29: validate all v1/v2 trait ids/names, per-kind caps, and opposed pairs."""
        idx = self.trait_idx
        pers = tr["personality"]
        if len(pers) != 3:
            self.ex.err("%s: %d personality traits (need 3, AC-NT-29)" % (where, len(pers)))
        seen_sets = set()
        for nm in pers:
            rec = idx.resolve_v1("personality", nm)
            if rec is None:
                self.ex.err("%s: unknown personality trait %r (AC-NT-29)" % (where, nm))
            else:
                if rec["set"] in seen_sets:
                    self.ex.err("%s: opposed/duplicate personality set %d (%s, AC-NT-29)" % (where, rec["set"], pers))
                seen_sets.add(rec["set"])

        if not tr["calling"] or idx.resolve_v1("callings", tr["calling"]) is None:
            self.ex.err("%s: unknown or missing calling %r (AC-NT-29)" % (where, tr["calling"]))

        fates = tr["fate_given"]
        if len(fates) > 2:
            self.ex.err("%s: %d fate_given traits (cap 2, AC-NT-29)" % (where, len(fates)))
        seen_fate_pairs = set()
        held_v2_and_fate = set()
        for nm in fates:
            rec = idx.resolve_v1("fate", nm)
            if rec is None:
                self.ex.err("%s: unknown or retired fate_given %r (AC-NT-29)" % (where, nm))
            else:
                if rec["pair"] in seen_fate_pairs:
                    self.ex.err("%s: opposed/duplicate fate pair %s (%s, AC-NT-29)" % (where, rec["pair"], fates))
                seen_fate_pairs.add(rec["pair"])
                held_v2_and_fate.add(rec["id"])

        gained = tr["gained"]
        if len(gained) > 2:
            self.ex.err("%s: %d gained traits (cap 2, AC-NT-29)" % (where, len(gained)))
        if len(set(gained)) != len(gained):
            self.ex.err("%s: duplicate gained traits %s (AC-NT-29)" % (where, gained))
        for nm in gained:
            if idx.resolve_v1("gained", nm) is None:
                self.ex.err("%s: unknown gained trait %r (AC-NT-29)" % (where, nm))

        if not tr["upbringing"]:
            self.ex.err("%s: missing upbringing (need 1, AC-NT-29)" % where)
        elif tr["upbringing"] not in idx.v2_by_id["upbringing"]:
            self.ex.err("%s: unknown upbringing %r (AC-NT-29)" % (where, tr["upbringing"]))

        talent_cap = 3 if tier == "A" else 2
        if len(tr["talent"]) > talent_cap:
            self.ex.err("%s: %d talent traits (tier %s cap %d, AC-NT-29)" % (where, len(tr["talent"]), tier, talent_cap))
        seen_tal = set()
        for t in tr["talent"]:
            tid, tv = t["id"], t["tier"]
            if tid not in idx.v2_by_id["talent"] or tv not in (1, 2, 3):
                self.ex.err("%s: invalid talent %r (AC-NT-29)" % (where, t))
            elif tid in seen_tal:
                self.ex.err("%s: duplicate talent family %r (AC-NT-29)" % (where, tid))
            else:
                seen_tal.add(tid)
                held_v2_and_fate.add(tid)

        if len(tr["path"]) > 2:
            self.ex.err("%s: %d path traits (cap 2, AC-NT-29)" % (where, len(tr["path"])))
        if len(set(tr["path"])) != len(tr["path"]):
            self.ex.err("%s: duplicate path traits %s (AC-NT-29)" % (where, tr["path"]))
        for pid in tr["path"]:
            if pid not in idx.v2_by_id["path"]:
                self.ex.err("%s: unknown path trait %r (AC-NT-29)" % (where, pid))
            else:
                held_v2_and_fate.add(pid)

        if tr["lifestyle"] and tr["lifestyle"] not in idx.v2_by_id["lifestyle"]:
            self.ex.err("%s: unknown lifestyle trait %r (AC-NT-29)" % (where, tr["lifestyle"]))

        if len(tr["health"]) > 2:
            self.ex.err("%s: %d health traits (cap 2, AC-NT-29)" % (where, len(tr["health"])))
        if len(set(tr["health"])) != len(tr["health"]):
            self.ex.err("%s: duplicate health traits %s (AC-NT-29)" % (where, tr["health"]))
        for hid in tr["health"]:
            if hid not in idx.v2_by_id["health"]:
                self.ex.err("%s: unknown health trait %r (AC-NT-29)" % (where, hid))

        if tr["coping"] and tr["coping"] not in idx.v2_by_id["coping"]:
            self.ex.err("%s: unknown coping trait %r (AC-NT-29)" % (where, tr["coping"]))

        for pair in idx.data.get("opposed_v2", []):
            if len(pair) == 2 and pair[0] in held_v2_and_fate and pair[1] in held_v2_and_fate:
                self.ex.err("%s: holds opposed traits %s and %s (AC-NT-29)" % (where, pair[0], pair[1]))

    def _trim_over_band(self, p, tr, tier, where):
        """Rule 2a over-band trim (design/gdd/npc-traits.md:89-99, AC-NT-53)."""
        band_max = TRAIT_BAND_MAX.get(tier, 6)
        if _total_traits(tr) <= band_max:
            return
        text_blob = " ".join(str(p.get(k) or "") for k in TEXT_FIELDS).lower()

        def is_named(kind, val):
            for term in self.trait_idx.search_terms(kind, val):
                if re.search(r"(?<!\w)" + re.escape(term) + r"(?!\w)", text_blob):
                    return 1
            return 0

        while _total_traits(tr) > band_max:
            candidates = []
            # Excluded: personality, calling, upbringing, and tier A's last talent
            for i, nm in enumerate(tr["gained"]):
                cid = _slug(nm)
                candidates.append(((is_named("gained", nm), TRIM_KIND_PRIORITY["gained"], 0, cid), "gained", i, cid))
            if tr["coping"]:
                cid = tr["coping"]
                candidates.append(((is_named("coping", cid), TRIM_KIND_PRIORITY["coping"], 0, cid), "coping", None, cid))
            if tr["lifestyle"]:
                cid = tr["lifestyle"]
                candidates.append(((is_named("lifestyle", cid), TRIM_KIND_PRIORITY["lifestyle"], 0, cid), "lifestyle", None, cid))
            for i, nm in enumerate(tr["fate_given"]):
                cid = _slug(nm)
                candidates.append(((is_named("fate_given", nm), TRIM_KIND_PRIORITY["fate_given"], 0, cid), "fate_given", i, cid))
            for i, cid in enumerate(tr["path"]):
                candidates.append(((is_named("path", cid), TRIM_KIND_PRIORITY["path"], 0, cid), "path", i, cid))
            if tier != "A" or len(tr["talent"]) > 1:
                for i, t in enumerate(tr["talent"]):
                    cid = t["id"]
                    candidates.append(((is_named("talent", t), TRIM_KIND_PRIORITY["talent"], int(t["tier"]), cid), "talent", i, cid))
            for i, cid in enumerate(tr["health"]):
                candidates.append(((is_named("health", cid), TRIM_KIND_PRIORITY["health"], 0, cid), "health", i, cid))

            if not candidates:
                self.ex.warn("%s (tier %s): over band (%d > %d) with only protected traits; trim stopped"
                             % (where, tier, _total_traits(tr), band_max))
                break

            candidates.sort(key=lambda c: c[0])
            sort_key, kind, idx_pos, cid = candidates[0]
            before_n = _total_traits(tr)
            if kind in ("gained", "fate_given", "path", "talent", "health"):
                tr[kind].pop(idx_pos)
            else:
                tr[kind] = ""
            named_flag = sort_key[0]
            reason = "over tier %s band (%d > %d); %s; kind=%s" % (
                tier, before_n, band_max,
                "named in backstory" if named_flag else "not named in backstory",
                kind,
            )
            self.trim_log.append((p["key"], cid, kind, reason))
            self.ex.warn("%s (tier %s): trimmed %s '%s' (%s)" % (where, tier, kind, cid, reason))

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
                tier = p.get("tier") or "C"
                tr = self._normalize_traits(p.get("traits"), where)
                migrate_retired_fates(tr, tier, self.trait_idx, where, self.ex.warn)
                self._validate_traits(tr, tier, where)
                self._trim_over_band(p, tr, tier, where)
                rec["traits"] = tr
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

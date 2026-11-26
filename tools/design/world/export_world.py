"""The authored world's history as game data (design/gdd/world-generation.md, Core Rules 1-15; user decisions
2026-11-15 and 2026-11-20).

Reads the approved design files and writes one file the game reads, assets/data/world_history.json:
- design/world/: sect_start_proposal (alignment, levels, treasury, loyalty), cast_proposal (72 people, 10 master
  ties, 4 vanished sects), leader_traits_proposal (traits of the living cast), chronicle_proposal (200 landmark
  events), annals_proposal (316 annals), records_proposal (14 dead records), legendary_items_proposal (34 items),
  territory_history_proposal (eras, land changes, wars, fallen sects, vassal changes, grudges);
- design/map/continent-11/: history.json (the 28 hidden slots and their candidate tiles, the 80 tile secrets, the
  famous sites), sacred.json (named features that are not places), minor_sects.json (crafts);
- assets/data/world_continent.json (the exported continent: places, regions and sects by id; run
  tools/design/map/export_continent.py first).

Names become ids: a place name (or a promoted city's former name) becomes its place id, a region name its id, and
a named feature that is not a place (the wasteland, the barrow, the deep caves) stays a feature reference. Nothing
is rolled here: the per-game rolls (hidden spots, tile secrets, reserves) and the random cultivators are the
builder's (WorldBuilder, Core Rules 8-9).

--check runs World Generation's Checking list (Edge Cases) and exits 1 on any failure; observations (warnings) are
printed but do not fail. Runtime never reads design/.

Usage: python tools/design/world/export_world.py [--check]
"""
import argparse
import hashlib
import json
import os
import sys

sys.path.insert(0, os.path.dirname(os.path.abspath(__file__)))
import depth_export  # noqa: E402  (the world-depth reader, ADR-0009 decision 5)

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
WORLD = os.path.join(ROOT, "design", "world")
MAP = os.path.join(ROOT, "design", "map", "continent-11")
OUT = os.path.join(ROOT, "assets", "data", "world_history.json")
START_YEAR = 1200
REALMS = ["luyen_khi", "truc_co", "ket_dan", "nguyen_anh", "hoa_than"]
ALIGN = {"chính đạo": "chinh", "ma đạo": "ma", "trung lập": "trung", "chinh": "chinh", "ma": "ma", "trung": "trung"}
SETTLE = {1: 12, 2: 9, "minor": 4}            # Sects F1 settle levels by tier
LOYALTY_BREAK = 30
CAST_SIZE = (60, 100)
# kinds of event whose people may be dead or unborn at the event (a burial names the dead; a tale may be told of them)
AFTER_DEATH_KINDS = {"burial", "tale", "omen", "item_found", "item_passed", "realm_opened", "discovery"}
# The sect's specialty (World Generation's sect archetype, which NPC Builds reads for its members). Chosen by Claude
# from each sect's craft and leans, 2026-11-20; listed for the user's review (production/plans/continent-world.md).
SPECIALTY = {
    "thien_xu": "tran_su", "tung_dao": "phap_tu", "lac_ha": "phap_tu", "thinh_vu": "kiem_tu", "bang_tam": "kiem_tu",
    "thuy_vi": "dan_su", "phuong_minh": "phap_tu",
    "thoi_tinh": "kiem_tu", "phat_y": "kiem_tu", "cung_tinh": "tran_su", "cuu_cao": "phap_tu", "ham_nguyet": "phap_tu",
    "van_hac": "phap_tu", "thai_chi": "dan_su", "lang_dao": "phap_tu", "binh_thuy": "phap_tu", "muc_van": "the_tu",
    "thien_bao": "tran_su", "nam_pho": "tran_su", "xuyen_lam": "the_tu", "hong_dau": "dan_su", "le_hoa": "kiem_tu",
    "trac_anh": "the_tu", "da_quang": "kiem_tu", "hong_lo": "dan_su", "van_khoi": "phap_tu", "truc_thuc": "linh_thuc_su",
    "le_tuyen": "dan_su", "phan_vu": "the_tu", "thu_phan": "phap_tu",
}


def load(path):
    with open(path, encoding="utf-8") as fh:
        return json.load(fh)


class Export:
    def __init__(self, depth_keys=None):
        self.errors, self.warnings = [], []
        self.depth_keys = depth_keys or []
        self.cont = load(os.path.join(ROOT, "assets", "data", "world_continent.json"))
        self.wg = load(os.path.join(ROOT, "assets", "data", "world_generation.json"))
        self.realms_file = load(os.path.join(ROOT, "assets", "data", "cultivation_realms.json"))
        W = lambda f: load(os.path.join(WORLD, f + ".json"))
        self.sect_start, self.cast, self.traits = W("sect_start_proposal"), W("cast_proposal"), W("leader_traits_proposal")
        self.chron, self.annals, self.records = W("chronicle_proposal"), W("annals_proposal"), W("records_proposal")
        self.items, self.territory = W("legendary_items_proposal"), W("territory_history_proposal")
        # the provinces-v2 sects (user decision 4, 2026-11-24): their start rows, founding years and specialties
        v2_start = os.path.join(WORLD, "provinces-v2", "sect_start_v2.json")
        if os.path.exists(v2_start):
            for s in load(v2_start)["minor_sects"]:
                self.sect_start["minor_sects"].append({k: s[k] for k in ("key", "name_hv", "lord", "alignment", "levels",
                                                                         "treasury", "loyalty")})
                self.cast["minor_sect_founding_years"][s["key"]] = s["founded"]
                SPECIALTY.setdefault(s["key"], s["specialty"])
        # their heads (cast_v2.json) and the provinces-v2 annals (annals_v2.json; user decision 7)
        v2_cast = os.path.join(WORLD, "provinces-v2", "cast_v2.json")
        if os.path.exists(v2_cast):
            vc = load(v2_cast)
            self.cast["people"] += vc["people"]
            self.traits["others"].update(vc["traits"])
        v2_annals = os.path.join(WORLD, "provinces-v2", "annals_v2.json")
        if os.path.exists(v2_annals):
            self.annals["events"] += load(v2_annals)["events"]
        self.history = load(os.path.join(MAP, "history.json"))
        lq = load(os.path.join(MAP, "land_qi.json"))   # Travel & Map Formula C (tools/design/map/land_qi.py)
        self.qi = {str(q["id"]): q for q in lq["places"]}
        self.sacred = load(os.path.join(MAP, "sacred.json"))
        self.minor_design = {s["key"]: s for s in load(os.path.join(MAP, "minor_sects.json"))["minor_sects"]}
        self.place_by_name = {}
        for p in self.cont["places"]:
            self.place_by_name[p["name"]] = p
        for p in self.cont["places"]:
            if p.get("former_name"):
                self.place_by_name.setdefault(p["former_name"], p)
        # a moved seat (World Generation rule 16; seat_moves.json): its name means the old place, now a sect hall, in
        # an event dated before the move, and the new seat from the move on (so the chronicle keeps its places)
        by_id = {p["id"]: p for p in self.cont["places"]}
        self.moved_seat = {}
        for g in self.cont["great_sects"] + self.cont["minor_sects"]:
            mv = g.get("seat_moved")
            if mv:
                self.moved_seat[by_id[g["seat"]]["name"]] = (int(mv["from"]), int(mv["year"]), set(mv.get("events_at_old", [])))
        self.region_by_name = {r["name"]: r for r in self.cont["regions"]}
        self.features = self._features()
        self.famous = self._famous()

    def err(self, msg):
        self.errors.append(msg)

    def warn(self, msg):
        self.warnings.append(msg)

    # -- named things ------------------------------------------------------------------------------------------------
    def _features(self):
        """Named sacred features that are not places: {name: {kind, tile}}."""
        S, out = self.sacred, {}
        if S.get("miasma_wasteland"):
            w = S["miasma_wasteland"]
            out[w["name_hv"]] = {"kind": "miasma_wasteland", "tile": list(w["source"]) if isinstance(w["source"], list) else w["tile_list"][0]}
        if S.get("miasma_source"):
            out[S["miasma_source"]["name_hv"]] = {"kind": "miasma_source", "tile": S["miasma_source"]["tile"]}
        for c in S.get("deep_caves", []):
            if c.get("name_hv"):
                out[c["name_hv"]] = {"kind": "deep_cave", "tile": c["tile"]}
        for v in S.get("spirit_veins", []):
            if v.get("name_hv"):
                out.setdefault(v["name_hv"], {"kind": "spirit_vein", "tile": v["anchor"]})
        return out

    def _famous(self):
        out = {}
        for group, kind in (("secret_realms", "secret_realm"), ("ruins", "ruin"), ("blessed_large", "blessed_land"),
                            ("blessed_small", "blessed_land")):
            for s in self.history["famous"].get(group, []):
                rec = {"name": s["name_hv"], "name_han": s.get("name_han", ""), "gloss": s.get("gloss", ""), "kind": kind,
                       "tile": s.get("tile") or s.get("centre"), "region": self.region_id(s.get("region"), "famous site"),
                       "holder": self.sect_key(s.get("holder") or s.get("territory") or s.get("sect")),
                       "note": s.get("note", "")}
                for k in ("cycle", "size", "element", "dD3", "push", "tile_list"):
                    if k in s:
                        rec[k] = s[k]
                q = self.qi.get("famous:" + s["name_hv"])
                if q is not None:
                    rec["qi"] = {"part": q["part"], "part_biome": q["biome"], "shares": q["shares"], "variants": q["variants"],
                                 "land_density": q["land_density"], "land_danger": q["land_danger"]}
                    rec["density"], rec["danger"] = q["density"], q["danger"]
                out[s["name_hv"]] = rec
        return out

    def region_id(self, name, where):
        if name is None or name == "":
            return 0
        if isinstance(name, int):
            return name
        r = self.region_by_name.get(name)
        if r is None:
            self.err("%s: region '%s' does not exist" % (where, name))
            return 0
        return r["id"]

    def sect_key(self, name):
        if not name:
            return ""
        for g in self.cont["great_sects"] + self.cont["minor_sects"]:
            if g["name"] == name or g["key"] == name:
                return g["key"]
        return name

    def place_ref(self, name, where, year=None, event=None):
        """A place name -> {"place": id} | {"feature": name, "tile"} | {"famous": name}; {} for none. With [year], a
        moved seat's name before its move resolves to the old seat (now its sect hall)."""
        if not name:
            return {}
        if name in self.moved_seat and ((year is not None and year < self.moved_seat[name][1])
                                        or (event is not None and event in self.moved_seat[name][2])):
            return {"place": self.moved_seat[name][0]}   # before the move, or an event the page keeps at the old seat
        if name not in self.place_by_name and " (" in name:     # "Tùng Đào Cung (the retreat by its seat)": a note
            ref = self.place_ref(name.split(" (")[0], where, year, event)
            if ref:
                ref["note"] = name.split(" (", 1)[1].rstrip(")")
            return ref
        p = self.place_by_name.get(name)
        if p is not None:
            return {"place": p["id"]}
        if name in self.famous:
            return {"famous": name}
        if name in self.features:
            return {"feature": name, "tile": self.features[name]["tile"]}
        self.err("%s: place '%s' is not a place, famous site or named feature" % (where, name))
        return {}

    # -- sects -------------------------------------------------------------------------------------------------------
    def sects(self):
        start = {s["key"]: s for s in self.sect_start["great_sects"] + self.sect_start["minor_sects"]}
        founded = dict(self.cast["great_sect_founding_years"])
        founded.update(self.cast["minor_sect_founding_years"])
        out = []
        for kind, group in (("great", self.cont["great_sects"]), ("minor", self.cont["minor_sects"])):
            for g in group:
                key = g["key"]
                st = start.get(key)
                if st is None:
                    self.err("sect %s has no start-state row (sect_start_proposal.json)" % key)
                    continue
                rec = {"key": key, "name": g["name"], "name_han": g.get("name_han", ""), "gloss": g.get("gloss", ""),
                       "kind": kind, "alignment": ALIGN.get(st["alignment"], st["alignment"]), "leans": g.get("leans", []),
                       "seat": g["seat"], "levels": st["levels"], "treasury": st["treasury"],
                       "founded": founded.get(key), "specialty": SPECIALTY.get(key, "")}
                for k in ("seat_moved", "seat_array_density", "seat_array"):   # World Generation rules 16, 16a
                    if k in g:
                        rec[k] = g[k]
                if kind == "great":
                    rec["tier"] = g["tier"]
                    rec["regions"] = g.get("regions", [])
                else:
                    rec["lord"] = g.get("lord", "")
                    rec["loyalty"] = st.get("loyalty")
                    rec["craft"] = g.get("craft", self.minor_design.get(key, {}).get("craft", ""))
                    rec["region"] = g.get("region")
                if rec["founded"] is None:
                    self.err("sect %s has no founding year" % key)
                if rec["specialty"] == "":
                    self.err("sect %s has no specialty" % key)
                cap = SETTLE[g["tier"]] if kind == "great" else SETTLE["minor"]
                for track, lv in st["levels"].items():
                    if int(lv) > cap:
                        self.err("sect %s: %s level %d is above the F1 settle level %d" % (key, track, lv, cap))
                if kind == "minor" and (st.get("loyalty") is None or int(st["loyalty"]) <= LOYALTY_BREAK):
                    self.err("sect %s: start loyalty %s is at or below the break line %d" % (key, st.get("loyalty"), LOYALTY_BREAK))
                out.append(rec)
        self.sect_keys = {s["key"] for s in out}
        return out

    def fallen(self):
        out = []
        for f in self.territory["fallen_sects"]:
            out.append({"key": f["key"], "name": f["name_hv"], "name_han": f.get("name_han", ""), "gloss": f.get("gloss", ""),
                        "founded": f["founded"], "fell": f["fell"], "cause": f.get("cause", ""), "land": f.get("land", []),
                        "ruin": self._ruin_of(f["key"])})
        for v in self.cast["vanished_sects"]:
            out.append({"key": v["key"], "name": v["name_hv"], "name_han": v.get("name_han", ""), "gloss": v.get("gloss", ""),
                        "founded": v["founded"], "fell": v["fell"], "cause": v.get("cause", ""), "ruin_slot": v.get("ruin_slot", ""),
                        "last_head": v.get("last_head", "")})
        self.fallen_keys = {f["key"] for f in out}
        return out

    def _ruin_of(self, key):
        for p in self.cont["places"]:
            if p.get("kind") == "ruin" and p.get("history_key") == key:
                return p["id"]
        return None

    # -- people ------------------------------------------------------------------------------------------------------
    def people(self):
        tr = {}
        for key, t in list(self.traits["traits"].items()) + list(self.traits["others"].items()):
            tr[key] = t
        out = []
        for p in self.cast["people"] + [dict(r, alive=False, record=True) for r in self.records["records"]]:
            rec = {"key": p["key"], "name": p["name_hv"], "name_han": p.get("name_han", ""), "gloss": p.get("gloss", ""),
                   "sex": p["sex"], "born": p["born"], "alive": bool(p["alive"]), "sect": p.get("sect") or "",
                   "rank": p.get("rank") or "", "role": p.get("role", "")}
            if p["alive"]:
                rec["realm"] = p["realm"]
                rec["home"] = self.place_ref(p.get("home"), "person %s home" % p["key"]).get("place")
                if rec["home"] is None:
                    self.err("person %s: home '%s' is not a place" % (p["key"], p.get("home")))
                t = tr.get(p["key"])
                if t is None:
                    self.err("person %s is alive and has no authored traits" % p["key"])
                else:
                    rec["traits"] = {"personality": t.get("personality", []), "calling": t.get("calling", ""),
                                     "fate_given": t.get("fate_given", [])}
            else:
                rec["peak_realm"] = p.get("peak_realm")
                rec["died"] = p.get("died")
                rec["cause"] = p.get("cause", "")
                rec["record"] = True
            for k in ("vassal_of", "served_under", "abode_slot", "master"):
                if p.get(k):
                    rec[k] = p[k]
            out.append(rec)
        by = {r["key"]: r for r in out}
        for t in self.cast["ties"]:
            if t["disciple"] not in by or t["master"] not in by:
                self.err("master tie %s -> %s names a missing person" % (t["master"], t["disciple"]))
                continue
            by[t["disciple"]]["master"] = t["master"]
        self.people_by = by
        return out

    def check_people(self, sects):
        age_min = self.wg["people"]["age_min_by_realm"]
        for r in self.people_by.values():
            realm = r.get("realm") or r.get("peak_realm")
            if realm not in REALMS:
                self.err("person %s: realm '%s' is not a realm" % (r["key"], realm))
            if r["sect"] and r["sect"] not in self.sect_keys and r["sect"] not in self.fallen_keys:
                self.err("person %s: sect '%s' does not exist" % (r["key"], r["sect"]))
            if r.get("master") and r["master"] not in self.people_by:
                self.err("person %s: master '%s' does not exist" % (r["key"], r["master"]))
            if r.get("alive"):
                age = START_YEAR - int(r["born"])
                if realm in REALMS and age < age_min[REALMS.index(realm)]:
                    self.err("person %s is %d at the start, below the %s minimum age %d" % (r["key"], age, realm, age_min[REALMS.index(realm)]))
                life = self.realms_file["realms"][REALMS.index(realm)]["lifespan"] if realm in REALMS else 0
                if age >= life:
                    self.err("person %s is %d at the start, at or past the %s lifespan %d" % (r["key"], age, realm, life))
        for s in sects:
            heads = [r for r in self.people_by.values() if r.get("alive") and r["sect"] == s["key"] and r["rank"] == "tong_chu"]
            if len(heads) != 1:
                self.err("sect %s has %d living leaders in the cast" % (s["key"], len(heads)))
            else:
                s["leader"] = heads[0]["key"]
        living = [r for r in self.people_by.values() if r.get("alive")]
        n_core = len(self.cast["people"])
        if not CAST_SIZE[0] <= n_core <= CAST_SIZE[1]:
            self.warn("the cast has %d people (target %d-%d)" % (n_core, CAST_SIZE[0], CAST_SIZE[1]))
        # Formula B: K_r <= T_r(N_min)
        weights = self.wg["realm_distribution"]
        w = [float(x["weight"]) if isinstance(x, dict) else float(x) for x in (weights if isinstance(weights, list) else weights.values())]
        if any(x <= 0 for x in w):
            self.err("a realm weight is zero or negative")
        tmin = targets(int(self.wg["people"]["world_cultivators_min"]), w)
        for i, realm in enumerate(REALMS):
            k = sum(1 for r in living if r["realm"] == realm)
            if k > tmin[i]:
                self.err("realm %s: %d living cast members, above its target %d at the smallest world" % (realm, k, tmin[i]))
        self.living_by_realm = {realm: sum(1 for r in living if r["realm"] == realm) for realm in REALMS}

    # -- events ------------------------------------------------------------------------------------------------------
    def events(self):
        out = []
        slots = {s["slot"] for s in self.history["hidden"]}
        items = {i["key"] for i in self.items["items"]}
        wars = {w["key"] for w in self.territory["wars"]}
        for tier, evs in (("landmark", self.chron["events"]), ("annal", self.annals["events"])):
            for e in evs:
                where = "event %s" % e["id"]
                rec = {"id": e["id"], "tier": tier, "year": int(e["year"]), "kind": e["kind"], "people": e.get("people", []),
                       "sects": e.get("sects", []), "text_vi": e["text_vi"], "text_en": e.get("text", "")}
                rec.update(self.place_ref(e.get("place"), where, int(e["year"]), e["id"]))
                if e.get("famous_site"):
                    if e["famous_site"] not in self.famous:
                        self.err("%s: famous site '%s' does not exist" % (where, e["famous_site"]))
                    rec["famous"] = e["famous_site"]
                reg = e.get("region_id") or self.region_id(e.get("region"), where)
                if reg:
                    rec["region"] = reg
                for k in ("slot", "item", "war", "writ", "judgement"):
                    if e.get(k):
                        rec[k] = e[k]
                if e.get("secret"):
                    rec["secret"] = True
                if rec.get("slot") and rec["slot"] not in slots:
                    self.err("%s names slot %s, which is not in the slot list" % (where, rec["slot"]))
                if rec.get("item") and rec["item"] not in items:
                    self.err("%s names item %s, which does not exist" % (where, rec["item"]))
                if rec.get("war") and rec["war"] not in wars:
                    self.err("%s names war %s, which does not exist" % (where, rec["war"]))
                if not 0 <= rec["year"] <= START_YEAR:
                    self.err("%s: year %d is outside 0-%d" % (where, rec["year"], START_YEAR))
                for pk in rec["people"]:
                    p = self.people_by.get(pk)
                    if p is None:
                        self.err("%s names person %s, who does not exist" % (where, pk))
                        continue
                    if rec["year"] < int(p["born"]):
                        self.err("%s (year %d) names %s before their birth (%d)" % (where, rec["year"], pk, p["born"]))
                    if p.get("died") is not None and rec["year"] > int(p["died"]) and rec["kind"] not in AFTER_DEATH_KINDS:
                        self.err("%s (year %d, %s) names %s after their death (%d)" % (where, rec["year"], rec["kind"], pk, p["died"]))
                for sk in rec["sects"]:
                    if sk not in self.sect_keys and sk not in self.fallen_keys:
                        self.err("%s names sect %s, which does not exist" % (where, sk))
                out.append(rec)
        out.sort(key=lambda r: (r["year"], r["id"]))
        self.event_ids = {r["id"] for r in out}
        # every hidden slot has an origin event
        named = {r["slot"] for r in out if r.get("slot")}
        for s in sorted(slots - named):
            self.err("hidden slot %s has no origin event in the chronicle" % s)
        return out

    def check_wars(self, sects):
        founded = {s["key"]: s["founded"] for s in sects}
        founded.update({f["key"]: f["founded"] for f in self.fallen_list})
        fell = {f["key"]: f["fell"] for f in self.fallen_list}
        for w in self.territory["wars"]:
            for side in w["sides"]:
                for k in side:
                    if k not in founded:
                        self.err("war %s names sect %s, which does not exist" % (w["key"], k))
                    elif int(w["years"][0]) < int(founded[k]):
                        self.err("war %s (%d) begins before %s was founded (%d)" % (w["key"], w["years"][0], k, founded[k]))
        for f in self.fallen_list:
            if int(f["fell"]) < int(f["founded"]):
                self.err("fallen sect %s falls (%d) before its founding (%d)" % (f["key"], f["fell"], f["founded"]))
        del fell

    # -- items, territory, hidden -------------------------------------------------------------------------------------
    def legendary(self):
        out = []
        for i in self.items["items"]:
            rec = {k: i[k] for k in ("key", "kind", "role", "made_by", "made_year", "story", "status") if k in i}
            rec.update({"name": i["name_hv"], "name_han": i.get("name_han", ""), "gloss": i.get("gloss", ""),
                        "element": i.get("element_guess", "")})
            if i.get("holder"):
                if i["holder"] not in self.people_by:
                    self.err("item %s: holder %s does not exist" % (i["key"], i["holder"]))
                elif not self.people_by[i["holder"]].get("alive"):
                    self.err("item %s: holder %s is not alive at the start" % (i["key"], i["holder"]))
                rec["holder"] = i["holder"]
            if i.get("place"):
                rec.update(self.place_ref(i["place"], "item %s" % i["key"]))
            for k in ("slot", "pair", "famous_site", "secret", "sought_by"):
                if i.get(k):
                    rec[k] = i[k]
            if i["status"] == "held" and not i.get("holder"):
                self.err("item %s is held but names no holder" % i["key"])
            out.append(rec)
        return out

    def hidden(self):
        slots, secrets, seen = [], [], {}
        origin = {}
        for e in self.chron["events"]:
            if e.get("slot"):
                origin.setdefault(e["slot"], e["id"])
        owners = {}
        for p in self.cast["people"]:
            if p.get("abode_slot"):
                owners[p["abode_slot"]] = p["key"]
        for v in self.cast["vanished_sects"]:
            if v.get("ruin_slot"):
                owners[v["ruin_slot"]] = v["key"]
        for s in self.history["hidden"]:
            cands = [list(c.get("tile") or c.get("centre")) for c in s["candidates"]]
            rec = {"slot": s["slot"], "kind": s["kind"], "candidates": cands, "origin": origin.get(s["slot"], ""),
                   "hidden_h": s.get("hidden_H", 1000), "owner": owners.get(s["slot"], ""),
                   "regions": [self.region_id(c.get("region"), "slot %s" % s["slot"]) for c in s["candidates"]]}
            qis = []
            for i, c in enumerate(s["candidates"]):
                q = self.qi.get("slot:%s:%d" % (s["slot"], i))
                if q is None:
                    self.err("hidden slot %s candidate %d has no land qi (run tools/design/map/land_qi.py)" % (s["slot"], i))
                    qis.append({})
                    continue
                qis.append({"qi": {"part": q["part"], "part_biome": q["biome"], "shares": q["shares"], "variants": q["variants"],
                                   "land_density": q["land_density"], "land_danger": q["land_danger"]},
                            "density": q["density"], "danger": q["danger"]})
            rec["candidate_qi"] = qis
            if s["kind"].startswith("blessed"):
                rec["tile_lists"] = [c.get("tile_list", [c.get("tile") or c.get("centre")]) for c in s["candidates"]]
                rec["element"] = s.get("element", "")
                rec["dD3"] = s.get("dD3", 0.0)
                rec["push"] = s.get("push", 0)
            slots.append(rec)
        for s in self.history["tile_secrets"]:
            secrets.append({"slot": s["slot"], "kind": s["kind"], "region": self.region_id(s.get("region"), "tile secret %s" % s["slot"]),
                            "candidates": [list(c) for c in s["candidates"]], "hidden_h": s.get("hidden_H", 300),
                            "dD3": s.get("dD3", 0.0)})
        for rec in slots + secrets:
            if len(rec["candidates"]) < 2:
                self.err("hidden slot %s has %d candidate(s); 2 or more are needed" % (rec["slot"], len(rec["candidates"])))
            for t in rec["candidates"]:
                k = tuple(t)
                if k in seen and seen[k] != rec["slot"]:
                    self.err("hidden slots %s and %s share the candidate tile %s" % (seen[k], rec["slot"], list(k)))
                seen[k] = rec["slot"]
        return slots, secrets

    def build(self):
        sects = self.sects()
        self.fallen_list = self.fallen()
        people = self.people()
        depth = depth_export.Depth(self, self.depth_keys) if self.depth_keys else None
        if depth:   # the world-depth cast of the exported sects merges over the old one (ADR-0009 decision 5)
            depth.merge_people(people)
            self.people_by = {r["key"]: r for r in people}
            depth.check_masters(self.people_by)
        self.check_people(sects)
        events = self.events()
        if depth:
            events += depth.events(self.people_by)
            events.sort(key=lambda r: (r["year"], r["id"]))
            self.event_ids = {r["id"] for r in events}
        self.check_wars(sects)
        items = self.legendary()
        slots, secrets = self.hidden()
        builds = self.cast_builds(depth.builds() if depth else None)
        T = self.territory
        territory = {"eras": T["eras"], "land_changes": T["land_changes"], "wars": T["wars"],
                     "vassal_lord_changes": T["vassal_lord_changes"], "grudges": T["grudges"], "other_events": T["other_events"]}
        for lc in T["land_changes"]:
            if lc.get("chronicle_event") and lc["chronicle_event"] not in self.event_ids:
                self.err("land change of region %s in %s names event %s, which does not exist" % (lc["land"], lc["year"], lc["chronicle_event"]))
        for g in T["grudges"]:
            for k in g["pair"]:
                if k not in self.sect_keys:
                    self.err("grudge %s names sect %s, which does not exist" % (g["pair"], k))
        return {
            "schema_version": 1,
            "_doc": ("The authored world's history (design/gdd/world-generation.md), exported by tools/design/world/export_world.py "
                     "from design/world/*.json and design/map/continent-11; do not edit by hand. start_year: every game starts here "
                     "(Core Rule 11). sects: the 30 living sects with their authored start (alignment chinh | ma | trung, the four "
                     "development levels, treasury, a minor sect's lord and loyalty), seat (place id), founded year, specialty (the "
                     "sect archetype NPC Builds reads) and leader (a cast key). fallen_sects: sects that fell before the start. "
                     "people: the fixed cast (alive: realm, home place id, traits; dead: records with peak_realm, died, cause), with "
                     "master, vassal_of, served_under and abode_slot where authored. events: the landmark chronicle and the annals, "
                     "ordered by year then id; place is a place id, famous a famous site's name, feature a named feature with its tile; "
                     "secret events are hidden until discovered. legendary_items: the 34 unique items, held by a living cast member or "
                     "lost at a place or slot. territory: eras, land changes, wars, vassal changes, grudges. hidden_slots: the 28 hidden "
                     "places with their 2-3 candidate tiles and origin event; tile_secrets: the 80 with their candidates; famous_sites "
                     "and features: named sites and features. data_version: a hash of the inputs, recorded in each save (Core Rule 13)."),
            "data_version": self.version(),
            "start_year": START_YEAR,
            "sects": sects,
            "fallen_sects": self.fallen_list,
            "people": people,
            "events": events,
            "legendary_items": items,
            "territory": territory,
            "hidden_slots": slots,
            "tile_secrets": secrets,
            "famous_sites": list(self.famous.values()),
            "features": [dict(v, name=k) for k, v in self.features.items()],
            "living_cast_by_realm": self.living_by_realm,
            "cast_builds": builds,
            "world_data_version": depth_export.WORLD_DATA_VERSION,
            "depth_sects": self.depth_keys,
            "ties": depth.ties(self.people_by) if depth else [],
            "beasts": depth.beasts(self.people_by) if depth else [],
        }

    # -- the cast's hand-authored builds (Core Rule 6) -------------------------------------------------------------
    def cast_builds(self, extra=None):
        """design/world/cast_builds.json, checked id by id (World Generation's Checking: a build naming a technique,
        item or Đạo Đồ node that does not exist fails). A living person with no build is reported (an observation
        until all are written; the builder fills those from a keyed stream)."""
        path = os.path.join(WORLD, "cast_builds.json")
        if not os.path.exists(path):
            self.warn("no design/world/cast_builds.json yet: every living cast member's build is a keyed stand-in")
            return {}
        data = load(path)
        builds = dict(data.get("builds", {}))
        builds.update(extra or {})   # the exported sects' depth builds win (ADR-0009 decision 5)
        cp = load(os.path.join(ROOT, "assets", "data", "items_cong_phap.json"))
        temps = {t["id"]: t for t in cp["templates"]}
        tiers = {t["rank"]: t for t in cp["tiers"]}
        arts = load(os.path.join(ROOT, "assets", "data", "items_artifacts.json"))
        bases = {b["id"] for b in arts["bases"]}
        named = {n["id"] for n in load(os.path.join(ROOT, "assets", "data", "items_named.json"))["named"]}
        dmap = load(os.path.join(ROOT, "assets", "data", "dao_do_map.json"))
        nodes = {int(n["id"]): n for n in dmap["nodes"]}
        starts = set(dmap["starts"].keys())
        attrs = load(os.path.join(ROOT, "assets", "data", "character_attributes.json"))
        talents = {t["id"] for t in attrs["thien_phu"]}
        elems = load(os.path.join(ROOT, "assets", "data", "character_elements.json"))
        variants = {v["id"]: v for v in elems["variants"]}
        archetypes = {a["id"] for a in self.wg["archetypes"]}
        skills = set(self.wg["npc_builds"]["archetype_skills"].values()) | {"dan_dao"}
        for f in ("crafting_formations", "crafting_refining", "crafting_talismans"):
            sk = load(os.path.join(ROOT, "assets", "data", f + ".json")).get("skill")
            if sk:
                skills.add(sk)
        realm_rank = {r: i for i, r in enumerate(REALMS)}
        used_named = {}
        for key, b in builds.items():
            where = "build %s" % key
            person = self.people_by.get(key)
            if person is None or not person.get("alive"):
                self.err("%s: no living cast member %s" % (where, key))
                continue
            root = b.get("root", {})
            for e, v in root.get("elements", {}).items():
                if e not in ("kim", "moc", "thuy", "hoa", "tho"):
                    self.err("%s: '%s' is not a base element" % (where, e))
                if not 10 <= float(v) <= 100:
                    self.err("%s: %s purity %s is outside 10-100" % (where, e, v))
            for vid, v in root.get("variants", {}).items():
                d = variants.get(vid)
                if d is None:
                    self.err("%s: '%s' is not a variant" % (where, vid))
                    continue
                for req in d.get("requires", []):
                    if req not in root.get("elements", {}):
                        self.err("%s: variant %s needs %s in the root" % (where, vid, req))
            if not root.get("elements"):
                self.err("%s: the root names no element" % where)
            for t, v in b.get("thien_phu", {}).items():
                if t not in talents or not 1 <= int(v) <= 100:
                    self.err("%s: talent %s = %s" % (where, t, v))
            if b.get("archetype") not in archetypes:
                self.err("%s: archetype '%s' does not exist" % (where, b.get("archetype")))
            ri = realm_rank.get(person["realm"], 0)
            for slot, tech in [("main", b.get("main", {}))] + [("aux", a) for a in b.get("aux", [])]:
                t = temps.get(tech.get("tech"))
                if t is None:
                    self.err("%s: %s technique '%s' is not in the catalogue" % (where, slot, tech.get("tech")))
                    continue
                kind = t.get("tech_kind", "main")
                if slot == "main" and kind != "main":
                    self.err("%s: '%s' is a %s technique, not a main method" % (where, t["id"], kind))
                if slot == "aux" and kind == "main":
                    self.err("%s: '%s' is a main method, not an auxiliary one" % (where, t["id"]))
                top = tiers.get(int(t["tier"]), {}).get("max_realm")
                if top in realm_rank and ri > realm_rank[top] + 1:
                    self.warn("%s: '%s' (tier %s, for up to %s) is far below %s" % (where, t["id"], t["tier"], top, person["realm"]))
                if not 1 <= int(tech.get("layer", 1)) <= int(t.get("layers", 1)):
                    self.err("%s: layer %s of '%s' is outside 1-%s" % (where, tech.get("layer"), t["id"], t.get("layers")))
            if len(b.get("aux", [])) > 2:
                self.err("%s: at most 2 auxiliary techniques (AC-CP-42)" % where)
            for g in b.get("gear", []):
                if "named" in g:
                    if g["named"] not in named:
                        self.err("%s: named item '%s' does not exist" % (where, g["named"]))
                    elif g["named"] in used_named:
                        self.err("%s: named item '%s' is already %s's" % (where, g["named"], used_named[g["named"]]))
                    used_named[g["named"]] = key
                elif g.get("base") not in bases:
                    self.err("%s: artifact base '%s' does not exist" % (where, g.get("base")))
                elif not 0 <= int(g.get("grade", 1)) < len(arts["grades"]):
                    self.err("%s: artifact grade %s is outside 0-%d (%s)" % (where, g.get("grade"), len(arts["grades"]) - 1, ", ".join(x["id"] for x in arts["grades"])))
            tr = b.get("tree", {})
            if tr.get("start") and tr["start"] not in starts:
                self.err("%s: Đạo Đồ start '%s' does not exist" % (where, tr["start"]))
            for nid in tr.get("targets", []):
                if int(nid) not in nodes:
                    self.err("%s: Đạo Đồ node %s does not exist" % (where, nid))
            for sk in b.get("skills", {}):
                if sk not in skills:
                    self.err("%s: skill '%s' does not exist (known: %s)" % (where, sk, ", ".join(sorted(skills))))
        missing = [k for k, p in self.people_by.items() if p.get("alive") and k not in builds]
        if missing:
            self.warn("%d living cast member(s) have no authored build yet: %s" % (len(missing), ", ".join(missing)))
        return builds

    def version(self):
        h = hashlib.sha256()
        for d, names in ((WORLD, sorted(os.listdir(WORLD))), (MAP, ["history.json", "sacred.json", "minor_sects.json", "land_qi.json", "seat_moves.json"])):
            for n in names:
                if n.endswith(".json"):
                    with open(os.path.join(d, n), "rb") as fh:
                        h.update(n.encode() + fh.read())
        with open(os.path.join(ROOT, "assets", "data", "world_continent.json"), "rb") as fh:
            h.update(fh.read())
        if self.depth_keys:   # ADR-0009 decision 9: the hash also covers design/world/depth/
            h.update(",".join(self.depth_keys).encode())
            for f in depth_export.version_files():
                with open(f, "rb") as fh:
                    h.update(os.path.relpath(f, ROOT).replace(os.sep, "/").encode() + fh.read())
        return h.hexdigest()[:16]


def targets(n, weights):
    """World Generation Formula A: largest-remainder headcounts, ties to the lower realm."""
    total = sum(weights)
    raw = [n * w / total for w in weights]
    t = [int(r) for r in raw]
    order = sorted(range(len(raw)), key=lambda i: (-(raw[i] - t[i]), i))
    for i in order[: n - sum(t)]:
        t[i] += 1
    return t


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--check", action="store_true")
    ap.add_argument("--sect", default="", help="world-depth owners to export (comma list, or all); ADR-0009")
    a = ap.parse_args()
    ex = Export(depth_export.owners(a.sect) if a.sect else None)
    out = ex.build()
    for w in ex.warnings:
        print("observation:", w)
    if ex.errors:
        for e in ex.errors:
            print("FAILED:", e)
        print("%d failure(s); nothing written" % len(ex.errors))
        return 1
    if not a.check:
        with open(OUT, "w", encoding="utf-8") as fh:
            json.dump(out, fh, ensure_ascii=False, indent=1)
            fh.write("\n")
    print(json.dumps({"sects": len(out["sects"]), "fallen_sects": len(out["fallen_sects"]), "people": len(out["people"]),
                      "living": sum(1 for p in out["people"] if p["alive"]), "events": len(out["events"]),
                      "items": len(out["legendary_items"]), "hidden_slots": len(out["hidden_slots"]),
                      "tile_secrets": len(out["tile_secrets"]), "living_cast_by_realm": out["living_cast_by_realm"],
                      "data_version": out["data_version"], "depth_sects": out["depth_sects"], "ties": len(out["ties"]),
                      "beasts": len(out["beasts"]), "written": not a.check}, ensure_ascii=False))
    return 0


if __name__ == "__main__":
    sys.exit(main())

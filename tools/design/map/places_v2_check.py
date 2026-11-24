"""Checks the written province and place lore (design/world/provinces-v2/lore/region_<r>.json) against its brief
(briefs/region_<r>.json) and the world. Prints observations (errors and warnings), never a verdict.

Errors: a province or slot of the brief with no entry; a missing field; a name used twice (also against the 254
existing places and the other regions' files); name_han not one character per syllable of name; a ruin without former
and lived; a proposed minor sect without its sect block. Warnings: a name whose last syllable does not fit its kind (a
mine not ending in Khoáng, a peak not in Phong / Sơn / Đỉnh ...); lore shorter than LORE_MIN or longer than LORE_MAX
characters; a year after the start year (1200).

usage: python -I tools/design/map/places_v2_check.py [region ...]
"""
import glob
import json
import os
import re
import sys

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
BASE = os.path.join(ROOT, "design/world/provinces-v2")
LORE_MIN, LORE_MAX = 80, 900
START_YEAR = 1200
ENDINGS = {
    "mine": ["Khoáng", "Động", "Quật", "Diêu"],
    "peak": ["Phong", "Sơn", "Đỉnh", "Lĩnh", "Nhai", "Phụ"],
    "lake": ["Hồ", "Đàm", "Trạch", "Bạc"],
    "forest": ["Lâm", "Sâm", "Tùng", "Trúc"],
    "lightning_wood": ["Lâm", "Mộc", "Sâm", "Trúc"],
    "gorge": ["Hạp", "Cốc", "Giản", "Khê"],
    "hot_spring": ["Tuyền", "Thang", "Trì"],
    "spirit_vein": ["Mạch", "Tuyền", "Nhãn", "Huyệt"],
    "volcano": ["Sơn", "Phong", "Nhạc"],
    "lava_vent": ["Khẩu", "Huyệt", "Quật", "Trì"],
    "village": ["Thôn", "Trang", "Ấp", "Hương", "Bảo", "Lý"],
    "town": ["Trấn", "Thị", "Bảo", "Phố", "Tập"],
    "minor_seat": ["Môn", "Phái", "Các", "Cung", "Viện", "Đường", "Tông", "Trang", "Lâu", "Quán"],
}
NEEDS = ["name", "name_han", "gloss", "look", "lore"]


def syllables(name):
    return len([w for w in re.split(r"[\s\-]+", name.strip()) if w])


def han_len(han):
    return len([ch for ch in han if "㐀" <= ch <= "鿿" or "豈" <= ch <= "﫿"])


def main(regions):
    cont = json.load(open(os.path.join(ROOT, "assets/data/world_continent.json"), encoding="utf-8"))
    # the 254 authored places (the merged provinces-v2 ones, v2_slot, are this checker's own entries)
    used = {p["name"]: "existing place %d" % p["id"] for p in cont["places"] if not p.get("v2_slot")}
    for s in cont["great_sects"] + cont["minor_sects"]:
        if s["key"] not in {p.get("key") for p in cont["places"] if p.get("v2_slot")}:
            used.setdefault(s["name"], "sect " + s["key"])
    files = sorted(glob.glob(os.path.join(BASE, "lore", "region_*.json")))
    prov_used = {}   # province name -> its key: provinces must not repeat among themselves
    v2_keys = {p.get("key") for p in cont["places"] if p.get("v2_slot")}
    sect_keys = {s["key"] for s in cont["great_sects"] + cont["minor_sects"] if s["key"] not in v2_keys}
    holder = {r["id"]: r["holder"] for r in cont["regions"]}
    # every place name of every file first, so a province is checked against places in later files too
    for f in files:
        try:
            d0 = json.load(open(f, encoding="utf-8"))
        except Exception:
            continue
        for k0, e0 in d0.get("places", {}).items():
            if e0.get("name"):
                used.setdefault(str(e0["name"]), k0)
    errs = warns = 0
    out = []
    for f in files:
        r = int(re.search(r"region_(\d+)", f).group(1))
        brief = json.load(open(os.path.join(BASE, "briefs", "region_%d.json" % r), encoding="utf-8"))
        try:
            lore = json.load(open(f, encoding="utf-8"))
        except Exception as e:
            out.append("E region %d: not valid JSON: %s" % (r, e))
            errs += 1
            continue
        check = not regions or r in regions

        def err(msg):
            nonlocal errs
            if check:
                errs += 1
                out.append("E region %d: %s" % (r, msg))

        def warn(msg):
            nonlocal warns
            if check:
                warns += 1
                out.append("W region %d: %s" % (r, msg))

        provs = lore.get("provinces", {})
        places = lore.get("places", {})
        for p in brief["provinces"]:
            e = provs.get(p["key"])
            if not e:
                err("province %s has no entry" % p["key"])
                continue
            for k in ("name", "name_han", "gloss", "lore"):
                if not str(e.get(k, "")).strip():
                    err("province %s: no %s" % (p["key"], k))
            nm = str(e.get("name", ""))
            if nm and han_len(e.get("name_han", "")) != syllables(nm):
                err("province %s: name_han %r is not one character per syllable of %r" % (p["key"], e.get("name_han"), nm))
            if nm in prov_used:
                err("province name %r used twice (%s)" % (nm, prov_used[nm]))
            elif nm and nm in used and not used[nm].startswith("existing place") and not used[nm].startswith("sect "):
                err("province name %r is also a place's name (%s)" % (nm, used[nm]))
            prov_used.setdefault(nm, p["key"])
            ln = len(str(e.get("lore", "")))
            if ln and not (LORE_MIN <= ln <= LORE_MAX):
                warn("province %s: lore %d characters" % (p["key"], ln))
        for s in brief["slots"]:
            e = places.get(s["slot"])
            if not e:
                err("slot %s has no entry" % s["slot"])
                continue
            for k in NEEDS:
                if not str(e.get(k, "")).strip():
                    err("slot %s: no %s" % (s["slot"], k))
            nm = str(e.get("name", ""))
            if nm in used and used[nm] != s["slot"]:
                err("place name %r used twice (%s)" % (nm, used[nm]))
            used[nm] = s["slot"]
            if nm and han_len(e.get("name_han", "")) != syllables(nm):
                err("slot %s: name_han %r is not one character per syllable of %r" % (s["slot"], e.get("name_han"), nm))
            ends = ENDINGS.get(s["kind"])
            if ends and nm and nm.split()[-1] not in ends:
                warn("slot %s (%s): name %r ends unusually for its kind" % (s["slot"], s["kind"], nm))
            if s["kind"] == "ruin":
                lv = e.get("lived")
                if not e.get("former") or not lv:
                    err("slot %s: a ruin needs former and lived [from, to]" % s["slot"])
                elif e["former"] not in ("city", "town", "sect", "fort", "village"):
                    err("slot %s: former %r is not one of city, town, sect, fort, village" % (s["slot"], e["former"]))
                elif not (isinstance(lv, list) and len(lv) == 2 and int(lv[0]) < int(lv[1]) <= START_YEAR):
                    err("slot %s: lived %r must be [from, to] with from < to <= %d" % (s["slot"], lv, START_YEAR))
            if s["kind"] == "minor_seat":
                sb = e.get("sect")
                if not isinstance(sb, dict):
                    err("slot %s: a proposed minor sect needs its sect block" % s["slot"])
                else:
                    if sb.get("key") in sect_keys:
                        err("slot %s: sect key %r is already a sect's" % (s["slot"], sb.get("key")))
                    sect_keys.add(sb.get("key"))
                    if sb.get("alignment") not in ("chính đạo", "trung lập", "ma đạo"):
                        err("slot %s: alignment %r" % (s["slot"], sb.get("alignment")))
                    if not sb.get("leans") or any(x not in ("Metal", "Wood", "Water", "Fire", "Earth") for x in sb.get("leans", [])):
                        err("slot %s: leans %r" % (s["slot"], sb.get("leans")))
                    if sb.get("lord") != holder.get(r):
                        err("slot %s: lord %r is not the region's holder %r" % (s["slot"], sb.get("lord"), holder.get(r)))
                    if int(sb.get("founded", 9999)) > START_YEAR:
                        err("slot %s: founded %r after the start year" % (s["slot"], sb.get("founded")))
            for txt in (e.get("lore", ""), e.get("look", "")):
                for y in re.findall(r"\b(1[2-9]\d\d|[2-9]\d\d\d)\b", str(txt)):
                    if int(y) > START_YEAR:
                        warn("slot %s: year %s after the start year" % (s["slot"], y))
            ln = len(str(e.get("lore", "")))
            if ln and not (LORE_MIN <= ln <= LORE_MAX):
                warn("slot %s: lore %d characters" % (s["slot"], ln))
    print("\n".join(out[:300]))
    print("files %d; errors %d, warnings %d" % (len(files), errs, warns))


if __name__ == "__main__":
    main([int(a) for a in sys.argv[1:]])

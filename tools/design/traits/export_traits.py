"""Builds assets/data/traits.json from design/gdd/npc-traits-catalogue.md (NPC Traits #42, approved 2026-11-14): the
37 personality traits in their opposed sets, the 14 callings with the archetypes' calling weights, the 10 fate-given and
16 gained traits; each with its stat rows (key and value, from the catalogue's stat codes), choice-tag weights, regard,
roll weight and its Sects F15 pulls parsed into fields the engine reads (dial deltas, war and rebel odds, weariness,
invest share, treasury draw, loyalty, pact line, alignment factor, attitude speed and bias, bold, fickle, first track).
A pull the parser does not know is kept in the trait's "notes" (the engine ignores it).

Run:  python tools/design/traits/export_traits.py
"""

import json
import re
import unicodedata

SRC = "design/gdd/npc-traits-catalogue.md"
OUT = "assets/data/traits.json"
MINUS = "−"
# F4's fate-given odds and talent weights (npc-traits.md F4 Variables)
ROLL = {"_doc": "F4 (design/gdd/npc-traits.md F4): p_any, the chance of a fate-given trait, and p_second, of a second one given the first (0.90 / 0.09 / 0.01); g_f = clamp(talent / g_ref, g_lo, g_hi) for a gift, the inverse for a flaw, on the talent before trait rows.", "p_any": 0.1, "p_second": 0.1, "g_ref": 45.0, "g_lo": 0.25, "g_hi": 3.0}
# F5's constants (npc-traits.md F5 Variables)
INHERIT = {"_doc": "F5 (design/gdd/npc-traits.md F5): h, the chance per known parent to pass a personality trait (no kin are recorded yet); m_master, the roll's lean toward a master known at creation.", "h": 0.5, "m_master": 3.0}
# F2's clamp (npc-traits.md F2 Variables)
CHOICE = {"_doc": "F2 choice weight (design/gdd/npc-traits.md F2): the product of the person's trait-by-tag weights is clamped to [m_lo, m_hi]; a 0 weight in the catalogue is F2's never.", "m_lo": 0.1, "m_hi": 5.0}
# F3's constants (npc-traits.md F3 Variables), carried in the data file for the engine
OPINION = {"_doc": "F3 opinion and att0 (design/gdd/npc-traits.md F3). s, o: shared and opposed weights; tie: master or disciple, kin, Dao companion, own sect head; sect_same: same sect; sect_k: share of the sects' attitude between NPCs of different sects; k_st: weight of the player's standing; att0_max: ceiling at a first meeting (the floor is the hostile threshold + 1).", "s": 10, "o": 10, "tie": {"master": 30, "kin": 30, "companion": 50, "own_head": 15}, "sect_same": 10, "sect_k": 0.2, "k_st": 0.25, "att0_max": 30}


def slug(name):
    n = unicodedata.normalize("NFKD", name.lower().replace("đ", "d")).encode("ascii", "ignore").decode()
    return re.sub(r"[^a-z0-9]+", "_", n).strip("_")


def num(s):
    return float(s.replace(MINUS, "-").replace("+", ""))


def cells(line):
    return [c.strip() for c in line.strip().strip("|").split("|")]


def stat_codes(text):
    codes = {}
    for line in text.splitlines():
        m = re.match(r"\|\s*([A-Z][a-z]?)\s*\|\s*([^|]+)\|\s*`([a-z_]+)`\s*\|", line)
        if m:
            codes[m.group(1)] = m.group(3)
    return codes


def rows(text, codes):
    out = []
    for part in re.split(r"\s*·\s*", text.strip()):
        m = re.match(r"([A-Z][a-z]?)\s*([+" + MINUS + r"-][\d.]+)", part)
        if m and m.group(1) in codes:
            out.append({"stat": codes[m.group(1)], "value": num(m.group(2))})
    return out


def tags(text):
    out = {}
    for part in re.split(r"\s*·\s*", text.strip()):
        m = re.match(r"([a-z]+)\s+(\*\*never\*\*|never|[\d.]+)", part)
        if m:
            out[m.group(1)] = 0.0 if "never" in m.group(2) else float(m.group(2))
    return out


def regard(text):
    t = text.strip()
    m = re.match(r"bias_all\s*([+" + MINUS + r"-]\d+)", t)
    if m:
        return {"bias_all": num(m.group(1))}
    m = re.match(r"bias_dir\s*([+" + MINUS + r"-]\d+)\s*(.*)", t)
    if m:
        return {"bias_dir": num(m.group(1)), "toward": m.group(2).strip()}
    m = re.match(r"target\s*([+" + MINUS + r"-]\d+)", t)
    if m:
        return {"target": num(m.group(1))}
    return {}


DIALS = {"tax": "tax", "expansion": "expansion", "openness": "openness", "war readiness": "war_readiness", "recruitment": "recruitment"}


def pulls(text):
    p = {}
    notes = []
    for part in [x.strip() for x in text.split(";") if x.strip()]:
        lo = part.lower().replace(MINUS, "-")
        done = False
        for k, f in (("war odds", "war_odds"), ("rebel odds", "rebel_odds"), ("invest share", "invest_share")):
            m = re.match(k + r"\s+([\d.]+)", lo)
            if m:
                p[f] = float(m.group(1))
                done = True
        m = re.match(r"weariness\s+([+-]\d+)(.*)", lo)
        if m:
            p["weariness"] = float(m.group(1))
            if "truce" in m.group(2):
                p["weariness_for_truce"] = True
            done = True
        if lo.startswith("half weariness from losses"):
            p["half_loss_weariness"] = True
            done = True
        m = re.match(r"(tax|expansion|openness|war readiness|recruitment)\s+([+-]\d+)(.*)", lo)
        if m:
            d = DIALS[m.group(1)]
            if "while thriving" in m.group(3):
                p.setdefault("dial_when_thriving", {})[d] = float(m.group(2))
            else:
                p.setdefault("dials", {})[d] = float(p.get("dials", {}).get(d, 0.0)) + float(m.group(2))
            done = True
        m = re.match(r"treasury draw\s+(\d+)", lo)
        if m:
            p["draw_mult"] = float(m.group(1))
            done = True
        m = re.match(r"loyalty\s+([+-]\d+)", lo)
        if m:
            p["loyalty"] = float(m.group(1))
            done = True
        m = re.match(r"pact line\s+(\d+)(.*)", lo)
        if m:
            p["pact_line"] = float(m.group(1))
            if "defence" in m.group(2):
                p["pact_line_scope"] = "defence"
            done = True
        m = re.match(r"alignment factor\s+×([\d.]+)", lo)
        if m:
            p["alignment_factor"] = float(m.group(1))
            done = True
        m = re.match(r"attitude speed\s+×([\d.]+)\s*(.*)", lo)
        if m:
            p["attitude_speed"] = float(m.group(1))
            p["attitude_speed_when"] = "hostile" if "hostile" in m.group(2) else "friendly"
            done = True
        m = re.match(r"attitude bias\s+([+-]\d+)", lo)
        if m:
            p["attitude_bias_from_all"] = float(m.group(1))
            done = True
        if lo == "bold":
            p["bold"] = True
            done = True
        if lo.startswith("never bold"):
            p["never_bold"] = True
            p["needs_halved"] = "halved" in lo
            done = True
        if lo == "needs halved":
            p["needs_halved"] = True
            done = True
        if lo == "fickle":
            p["fickle"] = True
            done = True
        m = re.match(r"first track\s+(\w+)", lo)
        if m:
            p["first_track"] = m.group(1)
            done = True
        if not done:
            notes.append(part)
    if notes:
        p["notes"] = notes
    return p


def section(text, title):
    i = text.index(title)
    j = text.find("\n## ", i + 1)
    return text[i: j if j > 0 else len(text)]


def main():
    text = open(SRC, encoding="utf-8").read()
    codes = stat_codes(text)
    out = {"schema_version": 1, "_doc": "Built by tools/design/traits/export_traits.py from design/gdd/npc-traits-catalogue.md (NPC Traits #42); do not edit by hand. Stat values are in the stat's own units (percent, points or pp, as the key reads them). pulls: the Sects F15 pulls the engine reads; notes: pulls kept as text (event weights and such, read by later systems).",
           "personality": [], "callings": [], "calling_weights": {}, "fate": [], "gained": [], "fade_seasons": 40,
           "opinion": OPINION, "choice": CHOICE, "inherit": INHERIT, "roll": ROLL}
    # personality
    sec = section(text, "## Personality")
    set_no = 0
    for line in sec.splitlines():
        if not line.startswith("|") or "---" in line or "Trait" in line:
            continue
        c = cells(line)
        if len(c) < 8:
            continue
        if c[0].isdigit():
            set_no = int(c[0])
        m = re.match(r"(.+?)\s*\((.+)\)", c[1])
        if not m:
            continue
        out["personality"].append({"id": slug(m.group(1)), "name": m.group(1), "name_vi": m.group(2), "set": set_no,
                                   "boon": rows(c[2], codes), "cost": rows(c[3], codes), "tags": tags(c[4]),
                                   "regard": regard(c[5]), "weight": float(c[6]) if c[6] else 1.0, "pulls": pulls(c[7])})
    # callings
    sec = section(text, "## Callings")
    ccodes = dict(codes)
    ccodes.update(stat_codes(sec))
    for line in sec.splitlines():
        if not line.startswith("|") or "---" in line or "Calling" in line or "Archetype" in line:
            continue
        c = cells(line)
        if len(c) == 6 and c[0].isdigit():
            m = re.match(r"(.+?)\s*\((.+)\)", c[1])
            out["callings"].append({"id": slug(m.group(1)), "name": m.group(1), "name_vi": m.group(2),
                                    "boon": rows(c[2], ccodes), "cost": rows(c[3], ccodes), "tags": tags(c[4]), "pulls": pulls(c[5])})
        elif len(c) == 2 and "·" in c[1] or (len(c) == 2 and ":" in c[1]):
            arch = c[0]
            ws = {}
            if ":" in c[1]:
                names, w = c[1].split(":")
                for n in names.split(","):
                    ws[slug(n.strip())] = float(w.strip().split()[0])
            else:
                for part in re.split(r"\s*·\s*", c[1]):
                    m2 = re.match(r"(.+?)\s+([\d.]+)$", part.strip())
                    if m2:
                        ws[slug(m2.group(1))] = float(m2.group(2))
            m3 = re.match(r"(.+?)\s*\((.+)\)", arch)
            out["calling_weights"][slug(m3.group(1)) if m3 else ("sect_member" if "sect member" in arch.lower() else slug(arch))] = ws
    # fate-given
    sec = section(text, "## Fate-given")
    fcodes = dict(codes)
    fcodes.update(stat_codes(sec))
    pair = ""
    for line in sec.splitlines():
        if not line.startswith("|") or "---" in line or "Trait" in line or "Code" in line:
            continue
        c = cells(line)
        if len(c) < 7:
            continue
        if c[0]:
            pair = c[0]
        m = re.match(r"(.+?)\s*\((.+)\)", c[1])
        if not m:
            continue
        out["fate"].append({"id": slug(m.group(1)), "name": m.group(1), "name_vi": m.group(2), "pair": slug(pair),
                            "rows": rows(c[2], fcodes), "world_price": c[3], "tags": tags(c[4]), "regard": regard(c[5]),
                            "reads": c[6]})
    # gained
    sec = section(text, "## Gained")
    for line in sec.splitlines():
        if not line.startswith("|") or "---" in line or "Trait" in line:
            continue
        c = cells(line)
        if len(c) < 9 or not c[0].isdigit():
            continue
        m = re.match(r"(.+?)\s*\((.+)\)", c[1])
        out["gained"].append({"id": slug(m.group(1)), "name": m.group(1), "name_vi": m.group(2), "grade": c[2],
                              "rows": rows(c[3], fcodes), "tags": tags(c[4]), "regard": regard(c[5]), "opposed": slug(c[6]) if c[6] else "",
                              "trigger": c[7].strip("`"), "pulls": pulls(c[8])})
    json.dump(out, open(OUT, "w", encoding="utf-8"), ensure_ascii=False, indent=1)
    print(json.dumps({k: len(v) for k, v in out.items() if isinstance(v, (list, dict))}))
    unk = [(t["id"], t["pulls"].get("notes")) for t in out["personality"] + out["callings"] if t["pulls"].get("notes")]
    print("pull notes kept as text:", unk)


if __name__ == "__main__":
    main()

"""Build a modifier inventory from game data, the tree catalogue and the overnight summary.

Usage (from the repo root):
  python -I tools/design/modifier_inventory.py . <out_dir>
  python -I tools/design/modifier_inventory_md.py <out_dir> design/quick-specs/modifier-inventory.md
Writes inventory.csv and inventory.json to <out_dir> (keep it outside the repo, e.g. a temp folder).
Groups, forms, breadth, reads and tags are keyword guesses: rerun after a source changes, never hand-edit the output.
"""
import csv
import json
import os
import re
import sys
from collections import Counter, defaultdict

ROOT, OUT = sys.argv[1], sys.argv[2]
P = lambda *a: os.path.join(ROOT, *a)

entries = []


def add(**kw):
    kw.setdefault("layer", "")
    kw.setdefault("builds", "")
    kw.setdefault("notable", "")
    kw.setdefault("vi", "")
    kw.setdefault("key", "")
    kw.setdefault("used_by", "")
    entries.append(kw)


def clean(s):
    return re.sub(r"\s+", " ", s.replace("**", "")).strip()


def split_name(cell):
    m = re.match(r"\*\*(.+?)\*\*\s*(?:\((.+?)\))?", cell.strip())
    if m:
        return m.group(1).strip(), (m.group(2) or "").strip()
    m = re.match(r"(.+?)\s*\((.+?)\)\s*$", cell.strip())
    if m:
        return m.group(1).strip(), m.group(2).strip()
    return clean(cell), ""


def md_tables(path):
    """Yield (section_path, header, row_cells) for each markdown table row."""
    heads = {}
    header = None
    with open(path, encoding="utf-8") as f:
        for line in f:
            line = line.rstrip("\n")
            m = re.match(r"^(#{1,4}) (.+)", line)
            if m:
                lvl = len(m.group(1))
                heads = {k: v for k, v in heads.items() if k < lvl}
                heads[lvl] = m.group(2).strip()
                header = None
                continue
            if line.startswith("|"):
                cells = [c.strip() for c in line.strip().strip("|").split("|")]
                if all(re.fullmatch(r":?-{3,}:?", c) for c in cells):
                    continue
                if header is None:
                    header = cells
                    continue
                yield [heads[k] for k in sorted(heads)], header, cells
            else:
                if line.strip():
                    header = None


# ---------- A. live stat keys ----------
labels = json.load(open(P("assets/data/character_stat_labels.json"), encoding="utf-8"))["labels"]
usage = defaultdict(set)


def walk(o, fname):
    if isinstance(o, dict):
        for k, v in o.items():
            if k in labels:
                usage[k].add(fname)
            if k == "stat" and isinstance(v, str) and v in labels:
                usage[v].add(fname)
            walk(v, fname)
    elif isinstance(o, list):
        for v in o:
            walk(v, fname)


for fn in sorted(os.listdir(P("assets/data"))):
    if fn.endswith(".json") and fn != "character_stat_labels.json":
        walk(json.load(open(P("assets/data", fn), encoding="utf-8")), fn.replace(".json", ""))

for k, v in labels.items():
    add(src="live-key", status="Live", name=v["name"], key=k,
        text=f"{v['name']} ({v['unit']})", used_by=", ".join(sorted(usage[k])) or "(label only)")

# ---------- B. combat-designed keys ----------
for k, d in [("crit_chance_pct", "crit chance"), ("crit_damage_pct", "crit damage"), ("evade_pct", "evade"),
             ("accuracy_pct", "accuracy"), ("pierce_pct", "realm pierce"), ("art_cost_pct", "art cost"),
             ("linh_luc_regen_pct", "linh lực regeneration"), ("status_resist_pct", "status resistance"),
             ("ward_efficiency_pct", "ward efficiency"), ("body_guard_pct", "body guard"),
             ("soul_res_pct", "soul resistance"), ("art_speed_pct", "art speed")]:
    add(src="combat-key", status="Designed", name=d, key=k, text=f"{d} (pct), Combat Parameter keys",
        used_by="combat.md")

# ---------- C. meridian capabilities ----------
caps = json.load(open(P("assets/data/meridian_capabilities.json"), encoding="utf-8"))["capabilities"]
for c in caps:
    add(src="capability", status="Live", name=c["name_en"], vi=c["name"], text=c["desc"],
        kind="rule-bender", key=f"capability #{c['id']} ({c['tier']})", used_by="meridian_capabilities")

# ---------- D. tree catalogue ----------
for sec, hdr, cells in md_tables(P("design/quick-specs/tree-modifier-catalogue.md")):
    h = [x.lower() for x in hdr]
    name, vi = split_name(cells[0])
    top = sec[1] if len(sec) > 1 else ""
    sub = sec[2] if len(sec) > 2 else ""
    status = {"●": "Live", "◐": "Designed", "○": "Idea"}
    if h[:4] == ["modifier", "small", "notable", "status"]:
        keym = re.search(r"`([a-z_]+)`", cells[0])
        add(src="catalogue-node", status=status.get(cells[3][:1], "Idea"), name=clean(re.sub(r"\(`.*?`.*?\)", "", cells[0])),
            key=keym.group(1) if keym else "", text=f"small {clean(cells[1])}; notable {clean(cells[2])}",
            notable=clean(cells[2]), kind="node", hint=sub)
    elif h[:3] == ["modifier", "status", "effect"]:
        add(src="catalogue-oneoff", status=status.get(cells[1][:1], "Idea"), name=clean(re.sub(r"\(`.*?`\)", "", cells[0])),
            text=clean(cells[2]), kind="rare one-off", hint=sub)
    elif h[:3] == ["name", "effect", "build it makes"]:
        add(src="catalogue-keystone", status="Idea", name=name, vi=vi, text=f"{clean(cells[1])} (makes: {clean(cells[2])})",
            kind="keystone", hint=sub)
    elif h[:3] == ["name", "effect", "cost"]:
        add(src="catalogue-keystone", status="Idea", name=name, vi=vi, text=f"{clean(cells[1])} (cost: {clean(cells[2])})",
            kind="keystone", hint="Dark paths")
    elif h[:4] == ["modifier", "form", "effect", "layer"]:
        add(src="catalogue-forged", status="Idea", name=name, vi=vi, text=clean(cells[2]), layer=cells[3],
            kind="special", form_hint=cells[1], hint="forged")
    elif h[:2] == ["name", "kind"]:
        add(src="catalogue-enabler", status="Idea", name=name, vi=vi,
            text=f"Opens: {clean(cells[2])}. Closes: {clean(cells[3])}", kind="enabler", hint="enabler")

# ---------- E. overnight ----------
for sec, hdr, cells in md_tables(P("design/builds/overnight-2026-11-07/summary/1-modifiers.md")):
    h = [x.lower() for x in hdr]
    name, vi = split_name(cells[0])
    sub = re.sub(r"\s*\(\d+\)$", "", sec[-1])
    if h[0] == "modifier" and len(h) == 4:
        add(src="overnight-special", status="Proposal", name=name, vi=vi, text=clean(cells[1]),
            layer=cells[2], builds=clean(cells[3]), kind="special", hint=sub)
    elif h[0] == "keystone":
        add(src="overnight-keystone", status="Proposal", name=name, vi=vi, text=clean(cells[1]),
            builds=clean(cells[2]), kind="keystone", hint="keystone")
    elif h[0] == "row":
        small, notable = clean(cells[1]), clean(cells[2])
        add(src="overnight-plain", status="Proposal", name=name, vi=vi,
            text=("small " + small if small else "") + ("; notable " + notable if notable else ""),
            notable=notable, builds=clean(cells[3]), kind="node", hint="plain")

for sec, hdr, cells in md_tables(P("design/builds/overnight-2026-11-07/summary/2-techniques-and-effects.md")):
    if sec[-1].startswith("Enablers"):
        name, vi = split_name(cells[0])
        add(src="overnight-enabler", status="Proposal", name=name, vi=vi, text=clean(cells[1]),
            builds=clean(cells[3]), kind="enabler", fit=cells[2], hint="enabler")

for e in entries:
    e.setdefault("kind", "stat key" if e["src"] in ("live-key", "combat-key") else "node")
    e.setdefault("hint", "")

# ---------- merge duplicates (same normalized English name, or same stat key on node rows) ----------
def norm(s):
    s = s.lower()
    s = re.sub(r"[^a-z0-9 ]", " ", s)
    s = re.sub(r"\b(the|a|an|maximum|max)\b", " ", s)
    return re.sub(r"\s+", " ", s).strip()

ALIAS = {"defense": "ward strength", "khi huyet": "maximum health", "linh luc": "maximum linh luc",
         "than thuc": "than thuc", "phap bao power": "artifact power", "phap bao attack": "weapon attack",
         "phap bao defense": "armour defence", "tran phap strength": "formation power",
         "pill effect": "pill effect in fight", "element match bonus": "element affinity",
         "than thuc cost": "artifact than thuc cost", "attack": "damage", "realm pierce": "realm pierce",
         "linh luc regeneration": "linh luc regeneration"}

def mkey(e):
    n = norm(e["name"])
    n = re.sub(r"\b(in a fight)\b", "in fight", n)
    return ALIAS.get(n, n)

# key-based merge first: stat key entries absorb catalogue/plain rows naming the same key
by_key = {}
merged = []
for e in entries:
    e["sources"] = [e["src"]]
    e["status_all"] = [e["status"]]
for e in entries:
    kk = e["key"] if e["key"] and not e["key"].startswith("capability") else None
    if not kk:
        m = re.search(r"\b([a-z]+(?:_[a-z]+)+_pct)\b", e["text"])
        if e["kind"] == "node" and m and len(re.findall(r"_pct", e["text"])) <= 2 and not re.search(r"\b(on|with|against|while|per)\b", e["name"].lower()):
            kk = m.group(1)
    if kk and kk in by_key and e["kind"] in ("node", "stat key"):
        tgt = by_key[kk]
        tgt["sources"].append(e["src"]); tgt["status_all"].append(e["status"])
        if e["builds"]: tgt["builds"] = ", ".join(filter(None, [tgt["builds"], e["builds"]]))
        if e["kind"] == "node" and not tgt.get("node_text"): tgt["node_text"] = e["text"]
        if e["vi"] and not tgt["vi"]: tgt["vi"] = e["vi"]
        continue
    if kk and e["kind"] in ("node", "stat key"):
        by_key[kk] = e
        if not e["key"]: e["key"] = kk
    merged.append(e)

by_name = {}
final = []
for e in merged:
    k = (mkey(e), e["kind"] in ("node", "stat key"))
    if k in by_name:
        tgt = by_name[k]
        tgt["sources"] += e["sources"]; tgt["status_all"] += e["status_all"]
        if e["builds"]: tgt["builds"] = ", ".join(filter(None, [tgt["builds"], e["builds"]]))
        if not tgt.get("node_text") and e["kind"] == "node": tgt["node_text"] = e["text"]
        if e["vi"] and not tgt["vi"]: tgt["vi"] = e["vi"]
        if e["layer"] and not tgt["layer"]: tgt["layer"] = e["layer"]
        continue
    by_name[k] = e
    final.append(e)

RANK = {"Live": 0, "Designed": 1, "Idea": 2, "Proposal": 3}
for e in final:
    e["status"] = min(e["status_all"], key=lambda s: RANK[s])
    b = sorted(set(x.strip() for x in e["builds"].split(",") if x.strip()))
    e["builds"] = ", ".join(b)
    e["nbuilds"] = len(b)

# ---------- tags ----------
T = [
    ("fire", r"\bfire\b|lava|burn|hỏa|flame|heat"),
    ("water", r"\bwater\b|thủy|ice|cold"),
    ("wood", r"\bwood\b|mộc"),
    ("metal", r"\bmetal\b|kim\b|steel"),
    ("earth", r"\bearth\b|thổ|stone"),
    ("element", r"element|fire|water|wood|metal|earth|lava|thunder|generating|overcom|ngũ hành|five phases|ring step|purity|colour|phase"),
    ("thunder", r"thunder|lightning|lôi"),
    ("damage", r"damage|attack_pct|\bpoints to\b|\bpoints on\b|\bpoints per\b|hits harder|deal more|deals more|c_art|coefficient|\bhit damage|^attack$"),
    ("art", r"\barts?\b|technique|spell|cast|art_"),
    ("basic_attack", r"basic attack|basic"),
    ("weapon_form", r"sword|palm|seal|needle|rope|song|beast form|furnace form|form\b|fist"),
    ("crit", r"crit"),
    ("accuracy", r"accuracy|cannot be evaded"),
    ("speed", r"speed|cooldown|timer|sooner|first firing|faster|tempo|later"),
    ("linh_luc", r"linh l[ựu]c|qi\b|pool|regen|mana|spirit stone|surfeit"),
    ("cost", r"cost|price|pays?\b|paid|free|refund"),
    ("reservation", r"reserv"),
    ("ward", r"ward|block"),
    ("health", r"health|khí huyết|vitality|khi_huyet|heal|restore|life\b"),
    ("body", r"\bbody\b|thể tu|guard|armour|skin|marrow"),
    ("evade", r"evade|evasion|dodge"),
    ("soul", r"soul|thần thức|than_thuc|divine sense|thần hồn|x_soul"),
    ("status", r"status|tick|poison|burn|bleed|curse|toxic|rot|sickness|over-time|cleanse"),
    ("poison", r"poison|toxic|rot|đan độc|corpse"),
    ("curse", r"curse"),
    ("conversion", r"convert|becomes|turns?\b|carries? .* tag|count(s)? as"),
    ("trigger", r"\bwhen\b|\bafter\b|each time|on a crit|on hit|once (a|per) fight|fires again|echo|trigger|knockout|if you would"),
    ("conditional", r"\bwhile\b|\bbelow\b|\babove\b|\bunder\b|\bover\b|against an enemy|if every|if the|foreseen|blind"),
    ("scaling_per", r"\bper\b|for each|for every|\bto \+\d"),
    ("artifact", r"artifact|pháp bảo|treasure|weapon|armour|flying|banner|gear|slot.*treasure"),
    ("companion", r"companion|beast|puppet|linh thú|herd"),
    ("formation", r"formation|trận|ground|array|bund"),
    ("talisman", r"talisman|phù|paper"),
    ("pill", r"\bpill|đan\b|alchemy|brew|coating|wax"),
    ("preparation", r"prepar|coating|formation|talisman|pill|ground|foreseen|before the fight|laid"),
    ("escape", r"escape|flee|flight|hide|stealth"),
    ("fortune", r"fortune|khí vận|khi_van|luck|reroll|cơ duyên|co_duyen|heaven"),
    ("realm", r"realm|vượt cấp|pierce|suppress|stage"),
    ("slots", r"slot"),
    ("mass_battle", r"levy|army|war\b|mass|soldier|troop|formulas k|rating"),
    ("cultivation", r"cultivat|tu vi|breakthrough|bình cảnh|seclusion|deviation|tâm ma|heart demon|lifespan|\bage\b|years|thọ"),
    ("heart_demon", r"heart demon|tâm ma|tam_ma"),
    ("lifespan", r"lifespan|thọ|years of|\bage\b|age_mult"),
    ("crafting", r"herb|alchemy|refin|brew|recipe|field|plot|furnace|luyện"),
    ("economy", r"income|mission|market|stone|price|levy"),
    ("travel", r"travel|map\b|place"),
    ("attribute", r"ngo_tinh|can_cot|than_hon|khi_van|dao_tam|mi_luc|presence|ngộ|căn cốt|thiên phú"),
    ("combat", r"fight|hit|art|damage|ward|crit|attack|enemy|duel|combat|evade|guard|companion|status|tick"),
]
TAGRE = [(t, re.compile(p, re.I)) for t, p in T]

def tags_for(e):
    blob = " ".join([e["name"], e["key"], e["text"], e.get("hint", ""), e.get("node_text", "")])
    tags = [t for t, rx in TAGRE if rx.search(blob)]
    if e["key"] in ("ngo_tinh", "can_cot", "than_hon", "khi_van", "dao_tam", "mi_luc"):
        tags.append("attribute")
    return list(dict.fromkeys(tags))

# ---------- group by EFFECT (what it changes); conditions go to "reads" ----------
SPLIT = re.compile(r"\b(while|per|for each|for every|when|after|if|once|against|below|above|on a crit|on a |on ground|in a foreseen|with no|to an enemy|to a target|under \d|over the|at \d+ %|read at|with an authored|with a cooldown|with three|naming)\b", re.I)


def first_text(e):
    t = re.sub(r"^small\s*", "", e["text"])
    parts = t.split("; notable")
    t = parts[0] if parts[0].strip() else " ".join(parts[1:])
    return t.strip()


def effect_part(e):
    ft = re.sub(r"\((makes|cost): .*?\)$", "", first_text(e)).strip()
    m = SPLIT.search(ft)
    eff = ft[:m.start()] if m and m.start() > 3 else ft
    return (e["name"] + " " + eff).lower(), (ft[m.start():].lower() if m else "")


EFFECT = [
    ("cultivation", r"tu luyện|cultivat|closed-door|breakthrough|\bage at\b"),
    ("crafting", r"herbs? |travel|tame|feed cost|draw success"),
    ("conversion", r"becomes|convert|counts? as (every|fire|qi|drain|ward|health|linh)|carries (your|thunder|every)|turns? (to|into)|keeping its"),
    ("damage", r"\bpoints\b|damage|coefficient|c_art|hits harder|deals? (much )?more|more damage"),
    ("speed", r"speed|cooldown|timer|sooner|first firing|fire later|half its effective|tempo"),
    ("cost", r"\bcost|price|\bpays?\b|\bpaid in\b|refund|reserves?|reservation|no linh lực|costs no"),
    ("crit", r"crit"),
    ("accuracy", r"accuracy|cannot be evaded|pierce"),
    ("damage", r"damage|\bpoints?\b|coefficient|c_art|harder|\+\d+ (to|on) |\bl[1-5]\b|deal more|deals? (much )?more|surge of power|adds attack|\battack\b"),
    ("linh_luc", r"linh l[ựu]c|regenerat|per second|regained|\bpool\b|regen"),
    ("ward", r"\bward"),
    ("health", r"health|khí huyết|vitality|heal|restore|survive|killing blow|leaves you at 1|mask"),
    ("body_guard", r"body guard|guard\b|armour|skin|marrow"),
    ("evade", r"evade|the double|curtain"),
    ("soul", r"soul|thần thức|divine sense|x_soul"),
    ("status", r"status|tick|poison|burn|curse|toxic|stack|duration|cleanse|affliction|rupture|surfeit"),
    ("prep", r"talisman|formation|pill|potency|ground"),
    ("slots", r"slot"),
    ("escape", r"escape|flee|fled|stealth|hiding"),
    ("fortune", r"reroll|fortune|khí vận|cơ duyên|co_duyen|heaven"),
    ("realm", r"realm|stage|suppress"),
    ("cultivation", r"cultivat|tu vi|breakthrough|seclusion|deviation|tâm ma|heart demon|lifespan|\bage\b|years"),
    ("crafting", r"herb|alchemy|luyện|refin|brew|recipe|plot|field|tame|feed|draw success|stones"),
    ("economy", r"income|mission|market|travel"),
    ("attribute", r"ngo_tinh|can_cot|than_hon|khi_van|dao_tam|mi_luc|presence|comprehension"),
]
EFFRE = [(n, re.compile(p, re.I)) for n, p in EFFECT]

READS = [
    ("own linh lực", r"your linh l[ựu]c|linh lực stays|linh lực share|linh lực you hold|linh lực runs out|your pool|linh lực hits 0"),
    ("enemy linh lực", r"enemy('s)? (maximum )?linh l|target('s)? (maximum )?linh l|enemy has under|enemy with no linh"),
    ("own health", r"(your|you) .*health|health is|health falls|below \d+ % health|above \d+ % health|health missing"),
    ("enemy health", r"enemy('s)? health|target's maximum health"),
    ("fight time", r"per second of the fight|this fight|every \d+ s|for each second|lasts"),
    ("in-fight events", r"per hit|per firing|each time|per talisman fired|evaded this fight|landed|on a crit|knockout|kill"),
    ("owned stat (compile)", r"you own|read at compile|at compile"),
    ("heart demon / toxicity", r"heart demon|tâm ma|toxicity|đan độc"),
    ("attribute", r"presence|comprehension|fortune|purity"),
    ("element relation", r"overcom|generat|ward carries"),
    ("slots / loadout", r"slot|every slotted|equipped"),
    ("preparation / ground", r"foreseen|blind|ground|formation stands|prepared|before the fight"),
    ("realm gap", r"realm"),
    ("craft skill", r"alchemy level|skill level|talisman skill|you drew yourself|brewed"),
    ("life / years", r"years|lifespan|seasons|wick|\bage\b"),
    ("hit tags / kind", r"with the .* (tag|form)|of the body kind|qi hits|body hits|tag family"),
]
READRE = [(n, re.compile(p, re.I)) for n, p in READS]

KMAP = {"attack_pct": "damage", "defense_pct": "ward", "ward_efficiency_pct": "ward", "khi_huyet_pct": "health",
        "linh_luc_pct": "linh_luc", "linh_luc_regen_pct": "linh_luc", "art_cost_pct": "cost", "than_thuc_pct": "soul",
        "soul_res_pct": "soul", "than_thuc_cost_pct": "artifact", "artifact_power_pct": "artifact",
        "artifact_attack_pct": "artifact", "artifact_defense_pct": "artifact", "element_affinity_pct": "artifact",
        "crit_chance_pct": "crit", "crit_damage_pct": "crit", "accuracy_pct": "accuracy", "pierce_pct": "accuracy",
        "evade_pct": "evade", "body_guard_pct": "body_guard", "status_resist_pct": "status", "art_speed_pct": "speed",
        "formation_power_pct": "prep", "pill_effect_pct": "prep", "tam_ma_resist_pct": "cultivation",
        "dan_doc_resist_pct": "cultivation", "dan_doc_decay": "cultivation", "dan_doc_no_penalty": "cultivation",
        "stealth": "escape", "co_duyen_pct": "fortune", "single_artifact": "artifact", "khi_van": "attribute",
        "ngo_tinh": "attribute", "can_cot": "attribute", "than_hon": "attribute", "dao_tam": "attribute", "mi_luc": "attribute"}


def effect_of(e):
    eff, cond = effect_part(e)
    if e["key"] in KMAP:
        return KMAP[e["key"]], eff, cond
    for n, rx in EFFRE:
        if rx.search(eff):
            return n, eff, cond
    for n, rx in EFFRE:
        if rx.search(cond):
            return n, eff, cond
    return "rule", eff, cond


SCOPE_GROUP = [
    ("companion", r"companion|beast|puppet|herd|hound"),
    ("soul", r"soul|x_soul"),
    ("status", r"tick|poison|burn|bleed|curse|over-time|\brot\b|statuses"),
    ("prep", r"talisman|formation|pill|coating|ground|prepared|paper|furnace"),
    ("artifact", r"artifact|flying|phi_kiem|weapon|armour|treasure"),
    ("element", r"\b(fire|water|wood|metal|earth|lava|thunder|element)"),
    ("art", r"\barts?\b|basic attack|sword|palm|seal|needle|rope|song|fist|body hits|qi hits|body damage|qi damage|healing"),
]
SCOPERE = [(n, re.compile(p, re.I)) for n, p in SCOPE_GROUP]

GROUP_NAMES = {
    "dmg_general": "Damage: general", "dmg_element": "Damage: element", "dmg_art": "Damage: arts, basic attack, forms, kinds",
    "crit": "Crit, accuracy and pierce", "speed": "Speed and tempo", "cost": "Linh lực: cost, reservation, payment",
    "linh_luc": "Linh lực: pool and regeneration", "ward": "Ward", "health": "Health and healing",
    "body_guard": "Body guard", "evade": "Evade", "soul": "Soul and thần thức", "status": "Statuses, ticks and curses",
    "conversion": "Conversion", "companion": "Companions and beasts", "artifact": "Artifacts and gear",
    "prep": "Preparation: formations, talismans, pills, ground", "slots": "Slots and loadout",
    "escape": "Escape", "fortune": "Fortune", "realm": "Realm and suppression", "mass": "Mass battle",
    "cultivation": "Life and cultivation", "crafting": "Crafting and economy", "attribute": "Attributes (thiên phú)",
    "rule": "Other rules",
}
ORDER_KEYS = ["dmg_general", "dmg_element", "dmg_art", "crit", "speed", "cost", "linh_luc", "ward", "body_guard",
              "health", "evade", "soul", "status", "conversion", "companion", "artifact", "prep", "slots", "escape",
              "fortune", "realm", "mass", "cultivation", "crafting", "attribute", "rule"]


def group_of(e, cls, eff):
    full = (e["name"] + " " + e["text"]).lower()
    if re.search(r"levy|army|formulas k|mass battle|troop", full) or e.get("hint") == "Mass battles":
        return "mass"
    if cls == "damage":
        for n, rx in SCOPERE:
            if rx.search(eff):
                return {"element": "dmg_element", "art": "dmg_art"}.get(n, n)
        return "dmg_general"
    if cls == "accuracy":
        return "crit"
    if cls == "economy":
        return "crafting"
    if cls in ("speed", "cost") and re.search(r"companion|beast", eff):
        return "companion"
    if cls in ("speed", "cost") and re.search(r"talisman", eff):
        return "prep"
    return cls if cls in GROUP_NAMES else "rule"


def form_of(e):
    x = (e["name"] + " " + e["text"] + " " + e.get("form_hint", "")).lower()
    # scope by hit tag or kind is part of a plain modifier, not a condition
    x = re.sub(r"against (fire|water|wood|metal|earth|body hits|qi hits|any one element|body|qi)\b|with swords|on (body|fire|water|sword) hits|\(or any one (tag|element)\)", " ", x)
    if e["kind"] == "enabler": return "enabler"
    if e["kind"] in ("keystone", "rule-bender"): return "keystone / capability"
    if e["kind"] == "rare one-off": return "one-off"
    if re.search(r"becomes|convert|counts? as|carries", x): return "conversion"
    if re.search(r"clips|past the cap|past their maximum|overflow|clipped", x): return "overflow"
    if re.search(r"\bwhen\b|\bafter\b|each time|on a crit|once a fight|once per|fires again|if you would|at the defeat|knockout", x): return "trigger"
    if re.search(r"\bper\b|for each|for every", x): return "per"
    if re.search(r"\bwhile\b|\bbelow\b|\babove\b|under \d|against|foreseen|if every|with no|on ground|to an enemy|at load|\d+ or more\b", x): return "conditional"
    lay = e["layer"].strip().upper()
    if lay in ("L2", "L3", "L4", "L5"): return "more"
    if re.search(r"^[\s;a-z]*[+\-−]\d", x) or e["kind"] == "stat key": return "plain"
    return "rule"


def breadth_of(e, form, eff):
    if e["kind"] in ("enabler", "keystone", "rule-bender"): return "-"
    if form not in ("plain", "more"): return "narrow"
    if re.search(r"sword|palm|seal|needle|rope|song|beast|basic|poison|curse|talisman|formation|pill|companion|lava|thunder|healing|furnace|ink|copied", eff): return "narrow"
    if re.search(r"\b(fire|water|wood|metal|earth)\b|element|\barts?\b|body hits|qi hits|body damage|qi damage|statuses?|tick|soul|artifact|weapon|armour", eff): return "family"
    return "universal"


for e in final:
    e["tags"] = tags_for(e)
    cls, eff, cond = effect_of(e)
    g = group_of(e, cls, eff)
    e["effect"] = cls
    e["group"] = GROUP_NAMES[g]
    e["gkey"] = g
    e["form"] = form_of(e)
    e["breadth"] = breadth_of(e, e["form"], eff)
    e["reads"] = [n for n, rx in READRE if rx.search(cond)] if cond else []

ORDER = [GROUP_NAMES[k] for k in ORDER_KEYS]
final.sort(key=lambda e: (ORDER.index(e["group"]), RANK[e["status"]], e["kind"], e["name"].lower()))

os.makedirs(OUT, exist_ok=True)
cols = ["group", "name", "vi", "kind", "status", "sources", "key", "effect", "form", "layer", "breadth", "reads", "tags", "text", "builds", "used_by"]
with open(os.path.join(OUT, "inventory.csv"), "w", encoding="utf-8-sig", newline="") as f:
    w = csv.writer(f)
    w.writerow(cols)
    for e in final:
        w.writerow([", ".join(sorted(set(e[c]))) if c == "sources" else (" ".join(e[c]) if c in ("tags", "reads") else e.get(c, "")) for c in cols])

json.dump(final, open(os.path.join(OUT, "inventory.json"), "w", encoding="utf-8"), ensure_ascii=False, indent=1)

# stats
print("raw entries:", len(entries), "after merge:", len(final))
print(Counter(e["src"] for e in entries))
print(Counter(e["group"] for e in final).most_common())
print(Counter(e["kind"] for e in final))
print(Counter(e["form"] for e in final))
print(Counter(e["breadth"] for e in final))
print("merged with >1 source:", sum(1 for e in final if len(set(e["sources"])) > 1))

"""Render the inventory JSON as two lists: Modifiers (plain numbers) and Effects (rules).

Usage (from the repo root, after modifier_inventory.py):
  python -I tools/design/modifier_inventory_md.py <out_dir> design/quick-specs/modifier-inventory.md

A Modifier is a plain number on a stat: "+X to something" or "X % increased / more something", optionally
narrowed by tags. An Effect is anything with a rule in it: a condition, scaling, a trigger, a conversion,
an overflow, a rule change, a keystone or an enabler. An Effect usually grants Modifiers as its payload.
"""
import json
import re
import sys
from collections import Counter, defaultdict

OUT, MD = sys.argv[1], sys.argv[2]
d = json.load(open(f"{OUT}/inventory.json", encoding="utf-8"))

SRC_LABEL = {
    "live-key": "game data", "combat-key": "Combat GDD", "capability": "Meridian capability",
    "catalogue-node": "catalogue", "catalogue-oneoff": "catalogue", "catalogue-keystone": "catalogue",
    "catalogue-forged": "catalogue", "catalogue-enabler": "catalogue", "overnight-special": "overnight",
    "overnight-plain": "overnight", "overnight-keystone": "overnight", "overnight-enabler": "overnight",
}
TAGWORDS = (r"\b(fire|water|wood|metal|earth|lava|thunder|sword|palm|seal|needle|rope|song|poison|curse|soul|"
            r"healing|talisman|body|qi|beast|companion|basic attack|burn)\b")
EFFECT_TYPES = [
    ("conditional", "Conditional", "Grants its payload only while something holds (linh lực above 50 %, health below 30 %, a foreseen fight)."),
    ("per", "Scaling", "Grows with a count (per point of đan độc, per empty slot, per second of the fight), usually to a cap."),
    ("trigger", "Trigger", "When something happens, do something (on a crit, after a knockout, once a fight)."),
    ("conversion", "Conversion", "Changes a hit's tags or kind, or makes one quantity count as another."),
    ("overflow", "Overflow", "Uses what a cap clips."),
    ("rule", "Rule change", "Changes a rule outright, with no number to stack."),
    ("one-off", "Rule change", ""),
    ("keystone / capability", "Keystone", "A strong rule with a price. Meridian capabilities are here too."),
    ("enabler", "Enabler", "Opens a channel, a rule or a resource and closes something in exchange; the piece a build is built on."),
]
TYPE_OF = {k: v for k, v, _ in EFFECT_TYPES}
TYPE_DESC = {}
for k, v, desc in EFFECT_TYPES:
    if desc:
        TYPE_DESC[v] = desc
TYPE_ORDER = ["Conditional", "Scaling", "Trigger", "Conversion", "Overflow", "Rule change", "Keystone", "Enabler"]


def concept(e):
    if "(flag)" in e["text"]:
        return "Effect"
    if e["form"] in ("plain", "more"):
        return "Modifier"
    if e["form"] == "one-off" and re.match(r"^\s*[+\-−]", e["text"]):
        return "Modifier"
    return "Effect"


def etype(e):
    if "(flag)" in e["text"]:
        return "Rule change"
    return TYPE_OF.get(e["form"], "Rule change")


def short(t, n=150):
    t = re.sub(r"^small\s*", "", t).replace("; notable", " · notable").replace("|", "/").strip(" ;")
    t = re.sub(r"\s*\(makes: (.*?)\)$", r" → \1", t)
    return t if len(t) <= n else t[: n - 1].rstrip() + "…"


def template(name):
    n = re.sub(r"\(or any one (tag|element)\)", "", name.lower())
    n2 = re.sub(TAGWORDS, "<tag>", n)
    n2 = re.sub(r"\s+", " ", n2).strip()
    return n2 if n2 != n.strip() else None


def tagword(name):
    m = re.search(TAGWORDS, name.lower())
    return m.group(1) if m else ""


def size(e):
    t = e["text"]
    m = re.findall(r"[+\-−]\s?[\d.]+\s?(?:%|points?)?", t)
    if e["kind"] in ("stat key",):
        return ""
    return " / ".join(dict.fromkeys(x.replace(" ", "") for x in m[:2]))


def srcs(e):
    s = ", ".join(sorted(set(SRC_LABEL[x] for x in e["sources"])))
    if e["nbuilds"]:
        s += f" · {e['nbuilds']} build" + ("s" if e["nbuilds"] > 1 else "")
    return s


mods = [e for e in d if concept(e) == "Modifier"]
effs = [e for e in d if concept(e) == "Effect"]
order = []
for e in d:
    if e["group"] not in order:
        order.append(e["group"])

L = []
w = L.append
w("# Modifier and Effect Inventory")
w("")
w("> **Status**: Working list, 2026-11-07. Input for the Modifier System GDD (`design/gdd/modifiers.md`, not yet created).")
w("> **Nothing here is adopted.** Overnight entries are proposals to filter (systems-index build design order).")
w("> **Generated**: rerun `tools/design/modifier_inventory.py` (usage in its docstring), never hand-edit. Groups,")
w("> types, breadth and reads are keyword guesses; about one entry in ten may sit in a debatable place.")
w("")
w("## Two concepts")
w("")
w("- **Modifier**: a plain number on a stat, \"+X to something\" or \"X % increased / more something\". It may be")
w("  narrowed by tags (Fire, sword, arts, qi hits) but has no condition and no rule of its own. Modifiers are what")
w("  stacks: they add inside a layer and multiply across layers (Combat Formulas B).")
w("- **Effect**: anything with a rule in it. A condition, scaling, a trigger, a conversion, an overflow or a rule")
w("  change; the heavy kinds are keystones and enablers. An Effect usually grants Modifiers as its payload:")
w("  \"+12 % sword damage while linh lực is above 50 %\" is a Conditional Effect whose payload is the Modifier")
w("  \"+12 % sword damage\".")
w("- Statuses (burns, poisons, curses) keep their own name, so \"effect\" never means a status.")
w("")
w("| | Modifiers | Effects |")
w("|---|---|---|")
sm, se = Counter(e["status"] for e in mods), Counter(e["status"] for e in effs)
for s in ["Live", "Designed", "Idea", "Proposal"]:
    w(f"| {s} | {sm[s]} | {se[s]} |")
w(f"| **Total** | **{len(mods)}** | **{len(effs)}** |")
w("")
w("*Live* in game data · *Designed* in a GDD, not built · *Idea* in the Nov 6 tree catalogue · *Proposal* from the")
w("overnight run. Sources: `assets/data/character_stat_labels.json` and the files that use its keys, `combat.md`")
w("§ Parameter keys, `meridian_capabilities.json`, `design/quick-specs/tree-modifier-catalogue.md`, and the")
w("overnight `summary/1-modifiers.md` and `2-techniques-and-effects.md` § Enablers. 624 entries read, 556 after merging.")
w("")

# ---------------- Modifiers ----------------
w("## Part 1: Modifiers")
w("")
w("Grouped by the stat they change. Rows that are the same modifier on a different tag are folded into one")
w("**template** (`<tag> art cost`), with the tags seen so far. **Breadth** answers the Meridian Map question:")
w("*universal* helps every build, *family* a broad group (an element, arts, soul), *narrow* a few.")
w("")
mgroups = defaultdict(list)
for e in mods:
    mgroups[e["group"]].append(e)
w("| Group | Modifiers | Universal | Family | Narrow |")
w("|---|---|---|---|---|")
rows_by_group = {}
for g in order:
    es = mgroups.get(g)
    if not es:
        continue
    folded = {}
    rows = []
    for e in es:
        t = template(e["name"]) if e["kind"] != "stat key" else None
        if t:
            if t not in folded:
                folded[t] = {"name": t, "members": [], "status": [], "breadth": e["breadth"], "key": "",
                             "size": size(e), "sources": set(), "nb": 0}
                rows.append(folded[t])
            f = folded[t]
            f["members"].append(tagword(e["name"]) or e["name"])
            f["status"].append(e["status"])
            f["sources"].update(SRC_LABEL[x] for x in e["sources"])
            f["nb"] += e["nbuilds"]
            if e["breadth"] == "family" or f["breadth"] != "family":
                f["breadth"] = e["breadth"] if f["breadth"] == "narrow" else f["breadth"]
        else:
            rows.append(e)
    rows_by_group[g] = rows
    br = Counter((r["breadth"]) for r in rows)
    anchor = re.sub(r"[^a-z0-9 -]", "", g.lower()).replace(" ", "-")
    w(f"| [{g}](#{anchor}) | {len(rows)} | {br['universal']} | {br['family']} | {br['narrow']} |")
w("")
RANK = {"Live": 0, "Designed": 1, "Idea": 2, "Proposal": 3}
for g in order:
    rows = rows_by_group.get(g)
    if not rows:
        continue
    w(f"### {g}")
    w("")
    w("| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |")
    w("|---|---|---|---|---|---|")
    def rk(r):
        st = min(r["status"], key=lambda s: RANK[s]) if "members" in r else r["status"]
        return ({"universal": 0, "family": 1, "narrow": 2}.get(r["breadth"], 3), RANK[st])
    for r in sorted(rows, key=rk):
        if "members" in r:
            st = min(r["status"], key=lambda s: RANK[s])
            members = sorted(set(m for m in r["members"] if m))
            src = ", ".join(sorted(r["sources"])) + (f" · {r['nb']} build uses" if r["nb"] else "")
            w(f"| **{r['name']}** (template) | {', '.join(members)} | {r['size']} | {r['breadth']} | {st} | {src} |")
        else:
            nm = f"**{r['name']}**" + (f" ({r['vi']})" if r["vi"] else "")
            if r["key"] and not r["key"].startswith("capability"):
                nm += f" `{r['key']}`"
            SCOPE = ("fire", "water", "wood", "metal", "earth", "thunder", "element", "art", "basic_attack", "weapon_form",
                     "poison", "curse", "status", "soul", "body", "companion", "artifact", "talisman", "formation", "pill")
            scope = " ".join(t for t in r["tags"] if t in SCOPE)
            w(f"| {nm} | {scope} | {size(r) or short(r['text'], 60)} | {r['breadth']} | {r['status']} | {srcs(r)} |")
    w("")

# ---------------- Effects ----------------
w("## Part 2: Effects")
w("")
w("Grouped by type. **Changes** is what the payload acts on (the same groups as Part 1); **Reads** is what a")
w("condition or scaling looks at.")
w("")
egroups = defaultdict(list)
for e in effs:
    egroups[etype(e)].append(e)
w("| Type | Effects | Live | Idea | Proposal | What it is |")
w("|---|---|---|---|---|---|")
for t in TYPE_ORDER:
    es = egroups.get(t, [])
    st = Counter(e["status"] for e in es)
    anchor = t.lower().replace(" ", "-")
    w(f"| [{t}](#{anchor}) | {len(es)} | {st['Live']} | {st['Idea']} | {st['Proposal']} | {TYPE_DESC.get(t, '')} |")
w("")
rc = Counter(r for e in effs for r in e["reads"])
w("**What conditions read** (a fixed list of readable quantities is a candidate GDD rule): " +
  ", ".join(f"{k} {v}" for k, v in rc.most_common()) + ".")
w("")
for t in TYPE_ORDER:
    es = egroups.get(t, [])
    if not es:
        continue
    w(f"### {t}")
    w("")
    w("| Effect | Changes | Reads | What it does | Status | Source |")
    w("|---|---|---|---|---|---|")
    es.sort(key=lambda e: (order.index(e["group"]), RANK[e["status"]], e["name"].lower()))
    for e in es:
        nm = f"**{e['name']}**" + (f" ({e['vi']})" if e["vi"] else "")
        w(f"| {nm} | {e['group']} | {', '.join(e['reads'])} | {short(e['text'])} | {e['status']} | {srcs(e)} |")
    w("")

open(MD, "w", encoding="utf-8").write("\n".join(L) + "\n")
print("wrote", MD, len(L), "lines; modifiers", len(mods), "rows", sum(len(v) for v in rows_by_group.values()), "effects", len(effs))
print({t: len(egroups.get(t, [])) for t in TYPE_ORDER})

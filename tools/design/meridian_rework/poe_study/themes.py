"""What PoE's notable clusters contain, where each theme sits, and how clusters are shaped and chained.

Usage: python -I themes.py <poe1 data.json> <poe2 tree.json> <ours meridian.json> <ours meridian-map.html> <out_dir>
Writes <out_dir>/themes.json (per-cluster records for the viewer) and <out_dir>/theme-metrics.json, prints a summary.
"""
import collections
import importlib.util
import json
import math
import re
import sys

P1, P2, OJ, OH, OUT = sys.argv[1:6]

# reuse the loaders from analyse.py without running its main block
src = open(__file__.replace("themes.py", "analyse.py"), encoding="utf-8").read()
src = src.split("\nout = {}\n")[0]
sys.argv = ["x", P1, P2, OUT]
ns = {}
exec(compile(src, "analyse.py", "exec"), ns)
load, load_ours, bfs = ns["load"], ns["load_ours"], ns["bfs"]

THEMES = [  # (theme, regex) — first strong match wins per stat line; order puts specific before generic
    ("minion", r"\bminions?\b"), ("totem", r"\btotems?\b"), ("trap/mine", r"\btraps?\b|\bmines?\b"),
    ("curse", r"\bcurses?\b|\bhex\b|\bmarks?\b"), ("warcry", r"warcr(y|ies)"), ("aura/reservation", r"reservation|\bauras?\b|\bheralds?\b"),
    ("flask/charm", r"\bflasks?\b|\bcharms?\b|tincture"), ("crit", r"critical"), ("energy shield", r"energy shield"),
    ("block", r"\bblock\b"), ("armour", r"\barmour\b"), ("evasion", r"evasion|\bevade\b"),
    ("life", r"\blife\b"), ("mana", r"\bmana\b"), ("leech", r"\bleech"),
    ("fire", r"\bfire\b|ignite|\bburning\b"), ("cold", r"\bcold\b|freeze|chill"), ("lightning", r"lightning|shock"),
    ("chaos/poison", r"\bchaos\b|poison|wither"), ("elemental", r"elemental"),
    ("bleed/physical", r"bleed|physical|impale"), ("damage over time", r"damage over time"),
    ("weapon", r"\b(swords?|axes?|maces?|bows?|claws?|daggers?|staff|staves|wands?|quarterstaff|crossbows?|spears?|flails?|sceptres?|two hand|one hand|dual wield|shields?)\b"),
    ("projectile", r"projectile"), ("area", r"area of effect"), ("speed", r"attack speed|cast speed|skill speed|movement speed"),
    ("spell", r"\bspells?\b"), ("attack", r"\battacks?\b|\bmelee\b"), ("accuracy", r"accuracy"),
    ("stun/ailment", r"\bstun|\bailments?\b|\bdaze|\bslow"), ("resistance", r"resistance"), ("charges", r"charges?\b"),
    ("attributes", r"strength|dexterity|intelligence|attributes?"), ("duration/cooldown", r"duration|cooldown"),
]
RX = [(t, re.compile(r, re.I)) for t, r in THEMES]
MASTERY_MAP = {  # PoE 1 mastery names → the shared taxonomy
    "Critical": "crit", "Life": "life", "Mana": "mana", "Energy Shield": "energy shield", "Armour": "armour", "Evasion": "evasion",
    "Block": "block", "Fire": "fire", "Cold": "cold", "Lightning": "lightning", "Chaos": "chaos/poison", "Poison": "chaos/poison",
    "Elemental": "elemental", "Physical": "bleed/physical", "Bleeding": "bleed/physical", "Impale": "bleed/physical",
    "Minion Offence": "minion", "Minion Defence": "minion", "Totem": "totem", "Trap": "trap/mine", "Mine": "trap/mine",
    "Curse": "curse", "Mark": "curse", "Warcry": "warcry", "Reservation": "aura/reservation", "Flask": "flask/charm",
    "Tincture": "flask/charm", "Leech": "leech", "Attack": "attack", "Caster": "spell", "Accuracy": "accuracy",
    "Projectile": "projectile", "Damage Over Time": "damage over time", "Recovery": "life", "Protection": "resistance",
    "Stun": "stun/ailment", "Charge": "charges", "Attributes": "attributes", "Duration": "duration/cooldown",
    "Spell Suppression": "evasion", "Shield": "weapon", "Staff": "weapon", "Mace": "weapon", "Sword": "weapon", "Axe": "weapon",
    "Bow": "weapon", "Wand": "weapon", "Dagger": "weapon", "Claw": "weapon", "Two Hand": "weapon", "Dual Wielding": "weapon",
    "Retaliation": "attack", "Rage": "attack", "Banner": "aura/reservation", "Brand": "spell", "Link": "aura/reservation",
    "Fortify": "armour", "Blind": "evasion", "Armour and Energy Shield": "armour", "Armour and Evasion": "armour",
    "Evasion and Energy Shield": "evasion",
}


def themes_of(lines):
    c = collections.Counter()
    for s in lines:
        for t, rx in RX:
            if rx.search(s):
                c[t] += 1
                break
    return c


def poe_clusters(path, game):
    d, nodes, edges = load(path, game)
    raw = d["nodes"]
    adj = collections.defaultdict(set)
    for a, b in edges:
        adj[a].add(b); adj[b].add(a)
    groups = collections.defaultdict(list)
    for k, v in nodes.items():
        groups[v["g"]].append(k)
    mastery = {}
    for sid, n in raw.items():
        if isinstance(n, dict) and n.get("isMastery") and "group" in n:
            mastery[int(n["group"])] = (n["name"].replace(" Mastery", ""), len(n.get("masteryEffects", [])))
    stats = {int(n.get("skill", sid)): n.get("stats", []) for sid, n in raw.items() if isinstance(n, dict) and str(n.get("skill", sid)).isdigit()}
    clusters = []
    for g, ks in groups.items():
        ks = [k for k in ks if nodes[k]["t"] != "mastery"]
        nots = [k for k in ks if nodes[k]["t"] in ("notable", "keystone")]
        if not nots or any(nodes[k]["t"] == "start" for k in ks):
            continue
        c = collections.Counter()
        for k in nots:
            for t, v in themes_of(stats.get(k, [])).items():
                c[t] += 2 * v
        for k in ks:
            if nodes[k]["t"] in ("small", "attribute"):
                c.update(themes_of(stats.get(k, [])))
        label = None
        if g in mastery and mastery[g][0] in MASTERY_MAP:
            label = MASTERY_MAP[mastery[g][0]]
        theme = label or (c.most_common(1)[0][0] if c else "other")
        smalls = [k for k in ks if nodes[k]["t"] in ("small", "attribute")]
        match = sum(1 for k in smalls if theme in themes_of(stats.get(k, [])))
        clusters.append({"g": g, "nodes": ks, "notables": len([k for k in nots if nodes[k]["t"] == "notable"]),
                         "keystone": any(nodes[k]["t"] == "keystone" for k in ks), "theme": theme,
                         "theme_from": "mastery" if label else "stats", "mastery": mastery.get(g),
                         "smalls": len(smalls), "smalls_on_theme": match})
    return nodes, adj, clusters


def ours_clusters():
    dj = json.load(open(OJ, encoding="utf-8"))
    d, nodes, edges, curves = load_ours(OH)
    adj = collections.defaultdict(set)
    for a, b in edges:
        adj[a].add(b); adj[b].add(a)
    theme_of = {c["id"]: c["theme"] for c in dj["clusters"]}
    groups = collections.defaultdict(list)
    for k, v in nodes.items():
        if v["g"] != -1:
            groups[v["g"]].append(k)
    clusters = []
    for g, ks in groups.items():
        nots = [k for k in ks if nodes[k]["t"] in ("notable", "keystone")]
        if not nots:
            continue
        smalls = [k for k in ks if nodes[k]["t"] in ("small", "attribute")]
        clusters.append({"g": g, "nodes": ks, "notables": len(nots), "keystone": any(nodes[k]["t"] == "keystone" for k in ks),
                         "theme": theme_of.get(g, "other"), "theme_from": "record", "mastery": None,
                         "smalls": len(smalls), "smalls_on_theme": len(smalls)})
    return nodes, adj, clusters


def analyse(name, nodes, adj, clusters):
    alloc = {k for k, v in nodes.items() if v["t"] != "mastery"}
    starts = [k for k, v in nodes.items() if v["t"] == "start"]
    xs = [nodes[k]["x"] for k in alloc]; ys = [nodes[k]["y"] for k in alloc]
    cx, cy = sum(xs) / len(xs), sum(ys) / len(ys)
    rmax = max(math.hypot(x - cx, y - cy) for x, y in zip(xs, ys))
    member = {}
    for i, c in enumerate(clusters):
        for k in c["nodes"]:
            member[k] = i
        c["x"] = sum(nodes[k]["x"] for k in c["nodes"]) / len(c["nodes"])
        c["y"] = sum(nodes[k]["y"] for k in c["nodes"]) / len(c["nodes"])
        c["r"] = math.hypot(c["x"] - cx, c["y"] - cy) / rmax
        c["sector"] = int(((math.degrees(math.atan2(c["x"] - cx, -(c["y"] - cy))) + 360) % 360) // 30)
        ks = set(c["nodes"])
        c["exits"] = sum(1 for k in ks for m in adj[k] if m in alloc and m not in ks)
        intra = sum(1 for k in ks for m in adj[k] if m in ks) // 2
        cyc = intra - len(ks) + 1
        c["form"] = "wheel" if cyc >= 1 else ("star" if any(len([m for m in adj[k] if m in ks]) >= 3 for k in ks) else "line")
        nt = [k for k in ks if nodes[k]["t"] in ("notable", "keystone")]
        c["notable_tip"] = sum(1 for k in nt if len([m for m in adj[k] if m in alloc]) == 1)
        c["notable_count_all"] = len(nt)
    # distance from each start to every node
    sd = {s: bfs(adj, s, alloc) for s in starts}
    # cluster-to-cluster road distance: multi-source BFS from each cluster's nodes, stop at other clusters
    def nearest_clusters(i):
        c = clusters[i]
        dist = {k: 0 for k in c["nodes"]}
        q = collections.deque(c["nodes"])
        found = {}
        while q:
            u = q.popleft()
            for v in adj[u]:
                if v in dist or v not in alloc:
                    continue
                dist[v] = dist[u] + 1
                j = member.get(v)
                if j is not None and j != i:
                    if j not in found:
                        found[j] = dist[v]
                    continue  # do not walk through other clusters
                if dist[v] < 12:
                    q.append(v)
        return found
    near = [nearest_clusters(i) for i in range(len(clusters))]
    for i, c in enumerate(clusters):
        f = near[i]
        c["nn"] = min(f.values()) if f else None
        nbrs = [j for j, dd in f.items() if dd <= (c["nn"] or 0) + 1]
        c["nn_same_theme"] = any(clusters[j]["theme"] == c["theme"] for j in nbrs)
        c["neighbour_themes"] = sorted({clusters[j]["theme"] for j in nbrs})
    # per-theme scatter
    by = collections.defaultdict(list)
    for i, c in enumerate(clusters):
        by[c["theme"]].append(i)
    allpairs = [math.hypot(a["x"] - b["x"], a["y"] - b["y"]) for i, a in enumerate(clusters) for b in clusters[i + 1:]]
    mean_all = sum(allpairs) / len(allpairs)
    themes = {}
    for t, ids in sorted(by.items(), key=lambda kv: -len(kv[1])):
        if len(ids) < 3:
            continue
        pts = [clusters[i] for i in ids]
        pd = [math.hypot(a["x"] - b["x"], a["y"] - b["y"]) for k, a in enumerate(pts) for b in pts[k + 1:]]
        disp = (sum(pd) / len(pd)) / mean_all
        sectors = len({p["sector"] for p in pts})
        acc = []
        for s in starts:
            best = min((min((sd[s].get(k, 999) for k in clusters[i]["nodes"]), default=999) for i in ids), default=999)
            acc.append(best)
        owners = collections.Counter()
        for i in ids:
            k0 = clusters[i]["nodes"][0]
            if starts:
                owners[min(starts, key=lambda s: sd[s].get(k0, 999))] += 1
        same = sum(1 for i in ids if clusters[i]["nn_same_theme"]) / len(ids)
        themes[t] = {"clusters": len(ids), "dispersion": round(disp, 2), "sectors_of_12": sectors,
                     "radius_mean": round(sum(p["r"] for p in pts) / len(pts), 2),
                     "points_from_start_min_max": [min(acc), max(acc)] if acc else None,
                     "starts_owning": len(owners), "neighbour_same_theme_share": round(same, 2)}
    # theme neighbour pairs
    pairs = collections.Counter()
    for i, c in enumerate(clusters):
        for t2 in c["neighbour_themes"]:
            if t2 != c["theme"]:
                pairs[tuple(sorted((c["theme"], t2)))] += 1
    forms = collections.Counter(c["form"] for c in clusters)
    exits = collections.Counter(min(c["exits"], 4) for c in clusters)
    form_exits = collections.Counter((c["form"], min(c["exits"], 3)) for c in clusters)
    nn_hist = collections.Counter(min(c["nn"], 10) for c in clusters if c["nn"] is not None)
    nots = collections.Counter(min(c["notable_count_all"], 5) for c in clusters)
    tipshare = sum(c["notable_tip"] for c in clusters) / max(1, sum(c["notable_count_all"] for c in clusters))
    on_theme = sum(c["smalls_on_theme"] for c in clusters) / max(1, sum(c["smalls"] for c in clusters))
    from_mastery = sum(1 for c in clusters if c["theme_from"] == "mastery")
    m_opts = collections.Counter(c["mastery"][1] for c in clusters if c["mastery"])
    # theme by radius band
    band = lambda r: "inner" if r < 0.4 else ("middle" if r < 0.7 else "outer")
    theme_band = collections.defaultdict(collections.Counter)
    for c in clusters:
        theme_band[c["theme"]][band(c["r"])] += 1
    return {
        "clusters": len(clusters), "themes": themes,
        "theme_pairs_top": [[a, b, n] for (a, b), n in pairs.most_common(15)],
        "forms": dict(forms), "exits_hist": {str(k): v for k, v in sorted(exits.items())},
        "form_by_exits": {f"{f}/{e}": v for (f, e), v in sorted(form_exits.items())},
        "nearest_cluster_points_hist": {str(k): v for k, v in sorted(nn_hist.items())},
        "notables_per_cluster_hist": {str(k): v for k, v in sorted(nots.items())},
        "notables_at_tips_share": round(tipshare, 2), "smalls_on_theme_share": round(on_theme, 2),
        "themed_by_mastery": from_mastery, "mastery_options_hist": {str(k): v for k, v in sorted(m_opts.items())},
        "neighbour_same_theme_share_all": round(sum(1 for c in clusters if c["nn_same_theme"]) / len(clusters), 2),
        "theme_band": {t: dict(v) for t, v in theme_band.items() if sum(v.values()) >= 3},
    }, clusters


metrics, viewer = {}, {}
for key, loader in (("poe1", lambda: poe_clusters(P1, 1)), ("poe2", lambda: poe_clusters(P2, 2)), ("ours", ours_clusters)):
    nodes, adj, clusters = loader()
    m, cl = analyse(key, nodes, adj, clusters)
    metrics[key] = m
    ids = sorted(nodes)
    ix = {k: i for i, k in enumerate(ids)}
    viewer[key] = {"clusters": [[ix[k] for k in c["nodes"] if k in ix] for c in cl], "theme": [c["theme"] for c in cl],
                   "form": [c["form"] for c in cl], "exits": [c["exits"] for c in cl],
                   "mastery": [c["mastery"][0] if c["mastery"] else None for c in cl]}
json.dump(metrics, open(f"{OUT}/theme-metrics.json", "w", encoding="utf-8"), ensure_ascii=False, indent=1)
json.dump(viewer, open(f"{OUT}/themes.json", "w", encoding="utf-8"), ensure_ascii=False, separators=(",", ":"))
for k, m in metrics.items():
    print("=====", k, {x: m[x] for x in m if x not in ("themes", "theme_band")})
    print(" theme  clusters dispersion sectors radius access(min,max) starts sameNbr")
    for t, v in m["themes"].items():
        print(f"  {t:18s} {v['clusters']:3d}  {v['dispersion']:.2f}  {v['sectors_of_12']:2d}  {v['radius_mean']:.2f}  {v['points_from_start_min_max']}  {v['starts_owning']}  {v['neighbour_same_theme_share']}")
    print(" bands:", m["theme_band"])

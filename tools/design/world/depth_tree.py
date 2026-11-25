"""Đạo Đồ helper for the world-depth builds (design/world/depth/README.md). Observations only.

  index          write design/world/depth/_inputs/dao_do/<land>.md: every notable and keystone by land, with id, name,
                 lines, effect, capability, and its distance in points from the land's start
  route KEY...   for cast keys, print each person's points, the cost of their target route, what it reaches
  (import)       route_report(person) for depth_check.py

Rules mirrored from src/gameplay/dao_do/dao_do_tree.gd and src/gameplay/cultivation/ladder.gd: the tree opens the
start, then the shortest route from the open set to each target in order (1 point per node), skipping Chaos-gated
nodes unless the root passes the gate (Primordial Chaos, or all five elements above chaos_gate_purity) and capability
notables below cap_realm_min; points = Ladder.points_total(stage_first_level(realm, stage)).

Run: python -I tools/design/world/depth_tree.py index | route so_ngoc_ho tiet_han_mai
"""
import collections
import glob
import json
import pathlib
import sys

ROOT = pathlib.Path(__file__).resolve().parents[3]
REALMS = ["luyen_khi", "truc_co", "ket_dan", "nguyen_anh", "hoa_than"]
_cache = {}


def _load(p):
    return json.loads((ROOT / p).read_text(encoding="utf-8"))


def data():
    if not _cache:
        m = _load("assets/data/dao_do_map.json")
        nodes = {n["id"]: n for n in m["nodes"]}
        adj = collections.defaultdict(list)
        for a, b in m["edges"]:
            adj[a].append(b)
            adj[b].append(a)
        cfg = _load("assets/data/dao_do_tree.json")
        cr = _load("assets/data/cultivation_realms.json")
        _cache.update(nodes=nodes, adj=adj, starts=m["starts"], cfg=cfg, ladder=cr["ladder"],
                      bands=[r["levels"] for r in cr["realms"]])
    return _cache


def _stage_starts(bands, i):
    b0, b1 = bands[i]
    n = b1 - b0 + 1
    return [b0 + n // 3, b0 + (2 * n) // 3, b1]


def points_for(realm, stage):
    d = data()
    bands, lad = d["bands"], d["ladder"]
    ri = REALMS.index(realm)
    level = bands[ri][0] if stage <= 0 else _stage_starts(bands, ri)[min(stage, 3) - 1]
    total = int(lad["pts_birth"]) + level - 1
    for i in range(len(bands)):
        if i > 0 and level >= bands[i][0]:
            total += int(lad["great_breakthrough_bonus"][i - 1])
        for s, st in enumerate(_stage_starts(bands, i)):
            if level >= st:
                total += int(lad["small_breakthrough_bonus"][i][s])
    return total


def gate_open(root):
    el, va = root.get("elements", {}), root.get("variants", {})
    if "hon_don" in va:
        return True
    need = float(data()["cfg"].get("chaos_gate_purity", 30))
    return all(float(el.get(e, 0)) > need for e in ["moc", "hoa", "tho", "kim", "thuy"])


def _blocked(n, gate, realm_i):
    d = data()
    if n.get("gate") == "chaos" and not gate:
        return True
    if int(n.get("cap", 0) or 0) > 0 and realm_i < int(d["cfg"].get("cap_realm_min", 2)):
        return True
    return False


def _dist(open_set, gate, realm_i):
    d = data()
    dist = {a: 0 for a in open_set}
    prev = {}
    q = collections.deque(open_set)
    while q:
        cur = q.popleft()
        for nb in d["adj"][cur]:
            if nb in dist or _blocked(d["nodes"][nb], gate, realm_i):
                continue
            dist[nb] = dist[cur] + 1
            prev[nb] = cur
            q.append(nb)
    return dist, prev


def route_report(p):
    """{points, spent, reached [ids], unreached [ids], over (targets past the budget), bad [reasons]} or None."""
    d = data()
    b = p.get("build") or {}
    tree = b.get("tree") or {}
    targets = tree.get("targets") or []
    if not targets:
        return None
    root = p.get("root") or b.get("root") or {}
    realm = p.get("realm") or "luyen_khi"
    ri = REALMS.index(realm)
    pts = points_for(realm, int(p.get("stage", b.get("stage", 0)) or 0))
    gate = gate_open(root)
    bad = []
    st = tree.get("start", "")
    if st not in d["starts"]:
        bad.append("start %r is not a Đạo Đồ start" % st)
        return {"points": pts, "spent": 0, "reached": [], "unreached": targets, "over": [], "bad": bad}
    open_set = [d["starts"][st]]
    left = pts - 1
    reached, unreached, over = [], [], []
    for t in targets:
        if t not in d["nodes"]:
            bad.append("target %s is not a node" % t)
            continue
        if t in open_set:
            reached.append(t)
            continue
        if _blocked(d["nodes"][t], gate, ri):
            bad.append("target %s (%s) is gated or a capability notable below Kết Đan" % (t, d["nodes"][t].get("name", "")))
            unreached.append(t)
            continue
        dist, prev = _dist(open_set, gate, ri)
        if t not in dist:
            unreached.append(t)
            bad.append("target %s unreachable" % t)
            continue
        if dist[t] > left:
            over.append(t)
            continue
        path, cur = [], t
        while cur not in open_set:
            path.append(cur)
            cur = prev[cur]
        open_set += path
        left -= len(path)
        reached.append(t)
    return {"points": pts, "spent": pts - left, "reached": reached, "unreached": unreached, "over": over, "bad": bad}


def _line(n):
    mods = ", ".join("%s %s%s" % (m["stat"], ("%g" % m["value"]), ("[" + "/".join(m["scope"]) + "]") if m.get("scope") else "")
                     for m in n.get("mods", []))
    extra = []
    if n.get("effect"):
        extra.append("effect: " + n["effect"])
    if n.get("cap"):
        extra.append("capability %s (Kết Đan+)" % n["cap"])
    if n.get("closes"):
        extra.append("closes: " + n["closes"])
    return mods + ("; " + "; ".join(extra) if extra else "")


def _ideas():
    """node id -> idea name (design/dao-do/content/*.json) and idea name -> {lines, cap} (big-cluster-ideas-v5.md)."""
    import re
    by_node, info = {}, {}
    for f in glob.glob(str(ROOT / "design/dao-do/content/*.json")):
        for k, v in json.loads(pathlib.Path(f).read_text(encoding="utf-8"))["nodes"].items():
            if isinstance(v, dict) and v.get("idea"):
                by_node[int(k)] = v["idea"] if isinstance(v["idea"], str) else str(v["idea"])
    md = (ROOT / "design/dao-do/big-cluster-ideas-v5.md")
    if md.exists():
        for line in md.read_text(encoding="utf-8").splitlines():
            c = [x.strip() for x in line.split("|")]
            if len(c) > 6 and c[1].isdigit():
                name = re.sub(r"\*", "", c[4])
                info[name] = {"lines": c[5], "cap": re.sub(r"\*", "", c[6])}
    return by_node, info


def _effects():
    """effect name (English part) -> rule text (assets/data/combat_effects.json) and keystone id -> 'build it ends'."""
    import re
    rules = {k: v.get("rule", "") for k, v in _load("assets/data/combat_effects.json")["effects"].items()}
    ends = {}
    draft = ROOT / "design/dao-do/content/effects-draft.md"
    if draft.exists():
        for line in draft.read_text(encoding="utf-8").splitlines():
            m = re.match(r"\| c\d+ \S+ \S*\s*\((\d+)\) \|[^|]*\|[^|]*\|[^|]*\| ([^|]+) \|", line)
            if m:
                ends[int(m.group(1))] = m.group(2).strip()
    return rules, ends


def _eff_text(n, rules):
    e = n.get("effect")
    if not e:
        return ""
    return rules.get(e.split(" (")[0], "")


def index():
    d = data()
    out = ROOT / "design/world/depth/_inputs/dao_do"
    out.mkdir(parents=True, exist_ok=True)
    by_node, info = _ideas()
    rules, ends = _effects()
    dist_from = {el: _dist([sid], True, 4)[0] for el, sid in d["starts"].items()}

    start_land = {"kim": "el-kim", "moc": "el-moc", "thuy": "el-thuy", "hoa": "el-hoa", "tho": "el-tho",
                  "bang": "el-thuy", "loi": "var-loi", "am": "var-am", "quang": "var-quang", "phong": "var-phong",
                  "hon_don": "chaos"}

    def near(nid):
        return min(((dist_from[e].get(nid, 9999), e) for e in d["starts"]), default=(9999, "?"))

    def land_of(n):
        a = n.get("area", "exact")
        if n["kind"] == "keystone" and a == "exact":
            return start_land.get(near(n["id"])[1], "exact")   # a keystone sits in the land of its nearest start
        return "borders" if a.startswith("border") else a.replace(":", "-")

    lands = collections.defaultdict(lambda: collections.defaultdict(list))
    for n in d["nodes"].values():
        if n["kind"] not in ("notable", "keystone"):
            continue
        grp = by_node.get(n["id"]) or ("cluster %s" % n.get("cluster"))
        lands[land_of(n)][grp].append(n)
    for land, groups in sorted(lands.items()):
        own = land.split("-", 1)[1] if "-" in land else None
        def dist(nid):
            if own in d["starts"] and nid in dist_from[own]:
                return dist_from[own][nid], own
            return near(nid)
        rows = []
        for grp, ns in groups.items():
            ns.sort(key=lambda n: dist(n["id"])[0])
            rows.append((dist(ns[0]["id"])[0], grp, ns))
        rows.sort(key=lambda r: (not r[1].startswith(("cluster",)) is False, r[0]))
        ideas_rows = [r for r in rows if not r[1].startswith("cluster ")]
        small_rows = [r for r in rows if r[1].startswith("cluster ")]
        L = ["# Đạo Đồ build pieces: %s (generated by tools/design/world/depth_tree.py index)" % land, "",
             "Organised by **idea** (the tree's big clusters, `design/dao-do/big-cluster-ideas-v5.md`), nearest to the "
             "start first, then the small clusters. For each piece: its theme lines and capability, then every notable "
             "and keystone in it with its exact lines and, for an Effect, the rule. **Targets** = the ids of the "
             "notables / keystone you want from a piece, nearest first (the route opens the small nodes between). "
             "`d` = points from the start (%s). Check routes with `python -I tools/design/world/depth_tree.py route <key>`."
             % (own or "nearest start"), ""]
        keys = sorted((n for ns in groups.values() for n in ns if n["kind"] == "keystone"), key=lambda n: dist(n["id"])[0])
        if keys:
            L.append("## Keystones of this land (a build's capstone: big lines, one rule, and a closing cost)")
            for n in keys:
                eff, end = _eff_text(n, rules), ends.get(n["id"])
                L.append("- **%d** %s: %s%s%s (d %d)" % (n["id"], n.get("name", ""), _line(n),
                         ("; rule: " + eff) if eff else "", ("; ends: " + end) if end else "", dist(n["id"])[0]))
            L.append("")
        for dd, grp, ns in ideas_rows:
            inf = info.get(grp, {})
            L.append("## %s  (d %d, %d notables%s)" % (grp, dd, sum(1 for n in ns if n["kind"] == "notable"),
                                                      ", keystone" if any(n["kind"] == "keystone" for n in ns) else ""))
            if inf:
                L.append("Theme: %s. %s" % (inf.get("lines", ""), inf.get("cap", "")))
            for n in ns:
                dn, ds = dist(n["id"])
                kind = "KEYSTONE" if n["kind"] == "keystone" else "notable"
                eff = _eff_text(n, rules)
                end = ends.get(n["id"])
                L.append("- **%d** %s %s: %s%s%s (d %d)" % (n["id"], kind, n.get("name", ""), _line(n),
                         ("; rule: " + eff) if eff else "", ("; ends: " + end) if end else "", dn))
            L.append("")
        if small_rows:
            L.append("## Small clusters (no named idea), nearest first")
            for dd, grp, ns in small_rows:
                L.append("- %s (d %d): " % (grp, dd) + "; ".join("**%d** %s%s: %s%s" % (
                    n["id"], "KEYSTONE " if n["kind"] == "keystone" else "", n.get("name", ""), _line(n),
                    ("; rule: " + _eff_text(n, rules)) if _eff_text(n, rules) else "") for n in ns))
        (out / ("%s.md" % land)).write_text("\n".join(L) + "\n", encoding="utf-8")
    pts = {r: [points_for(r, s2) for s2 in range(3)] for r in REALMS}
    readme = out / "README.md"
    old = readme.read_text(encoding="utf-8") if readme.exists() else ""
    tail = old[old.index("Which file"):] if "Which file" in old else ""
    readme.write_text(
        "# Đạo Đồ inputs for build writers\n\nStarts (tree.start → node id): %s\n\nPoints by realm and stage 0/1/2: %s\n\n"
        "One file per land (`el-<element>.md`, `var-<variant>.md`, `chaos.md`, `exact.md` (keystones and the hub), "
        "`borders.md`), organised by idea (big cluster) with every notable's lines and every keystone's Effect rule.\n\n%s"
        % (json.dumps(d["starts"]), json.dumps(pts), tail), encoding="utf-8")
    print("wrote %d land files" % len(lands))


def main():
    if len(sys.argv) > 1 and sys.argv[1] == "index":
        index()
        return
    if len(sys.argv) > 2 and sys.argv[1] == "route":
        people = {}
        for f in glob.glob(str(ROOT / "design/world/depth/**/*.cast.json"), recursive=True):
            for p in json.loads(pathlib.Path(f).read_text(encoding="utf-8"))["people"]:
                people[p["key"]] = p
        for k in sys.argv[2:]:
            p = people.get(k)
            r = route_report(p) if p else None
            print(k, r if r else "(no targets)")
        return
    print(__doc__)


if __name__ == "__main__":
    main()

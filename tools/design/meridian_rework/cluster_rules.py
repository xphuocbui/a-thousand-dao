"""Check the cluster rules of design/research/meridian-land-authoring.md ("Cluster rules", user 2026-11-15) on a
Meridian Map graph: a version file from design/meridian-map/versions/, a build's tree.json, or one figure template.

Usage (from the repo root):
  python -I tools/design/meridian_rework/cluster_rules.py <graph.json> [--region earth] [--json out.json] [--list]
  python -I tools/design/meridian_rework/cluster_rules.py --templates

The rules, per visible cluster (hidden clusters are left out):
  R1 mirror   every node has a twin of the same class (minor / payoff) across the line from the node it is entered
              from through the cluster's centre, or sits on that line. Several outside links: any line through the
              centre that maps the nodes and the links onto themselves. Figures in ASYM_FORMS are exempt for now.
  R2 waste    no dead ends: every minor node lies on some route (no node twice) between two of the cluster's entries
              and payoffs. A longer route round a loop counts, as an alternative path (it should carry different
              modifiers from the short way). "detour" lists, for information, minor nodes on no SHORTEST route.
  R3 door     follow the stem in to where the figure opens; for figures at least 3 deep, the nearest payoff is 2+
              steps past that point, unless the opening node itself is the payoff hub (3+ links inside the cluster).
  R4 payoff   the cluster holds at least one notable or keystone.
  R6 pairs    road nodes with exactly one cluster on each side (within 25 degrees of opposite): the share whose two
              clusters are the same figure, mirrored across the road (target 5-10 %).

Like the other helpers it reports what it measures and never edits a graph.
"""
import collections
import json
import math
import sys

MINOR = ("small", "travel")
PAYOFF = ("notable", "keystone")
# lopsided on purpose; R1 skips them until the user decides (guide, Cluster rules 1)
ASYM_FORMS = {"bolt", "spiral", "wave", "antler", "L", "stairs", "zig", "koi", "shared zigzag", "pinwheel",
              "taiji", "whirl"}     # the last two turn about their centre instead of mirroring
TOL = 0.3


def _cls(kind):
    return "payoff" if kind in PAYOFF else ("start" if kind == "start" else "minor")


class Graph:
    def __init__(self, d):
        self.N = {n["id"]: n for n in d["nodes"]}
        self.CL = {c["id"]: c for c in d.get("clusters", [])}
        self.adj = collections.defaultdict(set)
        for e in d["edges"]:
            self.adj[e["a"]].add(e["b"]); self.adj[e["b"]].add(e["a"])
        self.mem = collections.defaultdict(list)
        for n in d["nodes"]:
            c = n.get("cluster")
            if c is not None and not (self.CL.get(c) or {}).get("hidden"):
                self.mem[c].append(n["id"])

    def xy(self, i):
        n = self.N[i]
        return n["x"], n["y"]

    def bfs(self, src, allowed):
        dist = {src: 0}; q = collections.deque([src])
        while q:
            u = q.popleft()
            for v in self.adj[u]:
                if v in allowed and v not in dist:
                    dist[v] = dist[u] + 1; q.append(v)
        return dist


def _mirror_ok(G, ids, extra, cx, cy, ux, uy):
    """Every node of ids (and every outside point in extra) has a same-class twin across the line (c, u)."""
    pts = [(G.xy(i), _cls(G.N[i]["kind"])) for i in ids] + [(p, "out") for p in extra]
    for (x, y), c in pts:
        px, py = x - cx, y - cy
        t = px * ux + py * uy
        mx, my = 2 * t * ux - px + cx, 2 * t * uy - py + cy
        if not any(c2 == c and math.dist((mx, my), q) < TOL for q, c2 in pts):
            return False
    return True


def _blocks(G, nodes):
    """Biconnected components of the subgraph on `nodes` (Tarjan), each as a set of nodes."""
    idx, low, st, out, c = {}, {}, [], [], [0]

    def dfs(u, p):
        idx[u] = low[u] = c[0]; c[0] += 1
        for v in G.adj[u]:
            if v not in nodes or v == p:
                continue
            if v not in idx:
                st.append((u, v)); dfs(v, u); low[u] = min(low[u], low[v])
                if low[v] >= idx[u]:
                    comp = set()
                    while True:
                        e = st.pop(); comp |= set(e)
                        if e == (u, v):
                            break
                    out.append(comp)
            elif idx[v] < idx[u]:
                st.append((u, v)); low[u] = min(low[u], idx[v])
    for s in nodes:
        if s not in idx:
            dfs(s, None)
    return out


def dead_ends(G, S, term):
    """Minor nodes of the cluster S on no simple route between two terminals (entries, payoffs): dead-end spurs and
    loops that hang off one point. A longer route round a loop is not a dead end; it is an alternative path, worth it
    when its modifiers differ from the short way's (user 2026-11-15)."""
    if len(term) < 2:
        return sorted(i for i in S if G.N[i]["kind"] in MINOR and i not in term)
    B = _blocks(G, S)
    alive = list(range(len(B)))
    changed = True
    while changed:
        changed = False
        cnt = collections.Counter(v for k in alive for v in B[k])
        for k in alive:
            cuts = [v for v in B[k] if cnt[v] > 1]
            if len(cuts) <= 1 and not ((B[k] - set(cuts)) & term):
                alive.remove(k); changed = True
                break
    keep = set().union(*[B[k] for k in alive]) if alive else set()
    return sorted(i for i in S if G.N[i]["kind"] in MINOR and i not in keep and i not in term)


def check_cluster(G, cid):
    ids = G.mem[cid]; S = set(ids)
    form = (G.CL.get(cid) or {}).get("form", "?")
    links = sorted({(i, j) for i in ids for j in G.adj[i] if j not in S})
    ports = sorted({i for i, _ in links})
    outside = sorted({j for _, j in links})
    pay = [i for i in ids if G.N[i]["kind"] in PAYOFF]
    r = {"id": cid, "form": form, "name": (G.CL.get(cid) or {}).get("name", ""), "n": len(ids), "payoffs": len(pay),
         "ports": len(ports), "region": G.N[ids[0]].get("region")}
    cx = sum(G.xy(i)[0] for i in ids) / len(ids); cy = sum(G.xy(i)[1] for i in ids) / len(ids)
    # R1
    if form in ASYM_FORMS or len(ids) < 3:
        r["R1"] = None
    elif len(outside) == 1:
        ox, oy = G.xy(outside[0]); L = math.hypot(cx - ox, cy - oy) or 1
        r["R1"] = _mirror_ok(G, ids, [], cx, cy, (cx - ox) / L, (cy - oy) / L)
    else:
        ext = [G.xy(j) for j in outside]
        r["R1"] = any(_mirror_ok(G, ids, ext, cx, cy, math.cos(math.radians(a)), math.sin(math.radians(a)))
                      for a in range(0, 180))
    # R2: dead ends (loose). "detour" (strict, information only): minor nodes on no shortest route
    D = {p: G.bfs(p, S) for p in ports}
    P = {g: G.bfs(g, S) for g in pay}
    detour = []
    for i in ids:
        if G.N[i]["kind"] not in MINOR or i in ports:
            continue
        ok = any(g in D[p] and i in D[p] and i in P[g] and D[p][i] + P[g][i] == D[p][g] for p in ports for g in pay) or \
            any(q in D[p] and i in D[p] and i in D[q] and D[p][i] + D[q][i] == D[p][q] for p in ports for q in ports if p < q) or \
            any(h in P[g] and i in P[g] and i in P[h] and P[g][i] + P[h][i] == P[g][h] for g in pay for h in pay if g < h)
        if not ok:
            detour.append(i)
    r["detour"] = detour
    # slack: how much longer than the shortest is the best route through each minor node (0 on a shortest route).
    # A ring's two halves have slack 0-2; a wing that loops five nodes out and back has much more.
    slack = 0
    for i in detour:
        best = min([D[p][i] + P[g][i] - D[p][g] for p in ports for g in pay if g in D[p] and i in D[p] and i in P[g]] +
                   [D[p][i] + D[q][i] - D[p][q] for p in ports for q in ports if p < q and q in D[p] and i in D[p] and i in D[q]] +
                   [P[g][i] + P[h][i] - P[g][h] for g in pay for h in pay if g < h and h in P[g] and i in P[g] and i in P[h]] or [99])
        slack = max(slack, best)
    r["max_slack"] = slack
    r["waste"] = dead_ends(G, S, set(ports) | set(pay))
    r["R2"] = not r["waste"]
    # R3: single-entry figures only (a pass-through has no single door)
    r["R3"] = None
    if len(ports) == 1 and pay:
        prev, cur, walked = None, ports[0], 0
        while G.N[cur]["kind"] not in PAYOFF:
            nxt = [v for v in G.adj[cur] if v in S and v != prev]
            if len(nxt) != 1:
                break
            prev, cur, walked = cur, nxt[0], walked + 1
        door = cur
        Dd = G.bfs(door, S - ({prev} if prev is not None else set()))
        if G.N[door]["kind"] in PAYOFF and len([v for v in G.adj[door] if v in S and v != prev]) <= 1:
            # a chain that never opens before its first payoff: at least two minor nodes lead up to it
            r["R3"] = walked >= 2
            r["door_steps"] = walked
        elif max(Dd.values()) >= 3:
            near = min(Dd.get(g, 99) for g in pay)
            hub = G.N[door]["kind"] in PAYOFF and len([v for v in G.adj[door] if v in S]) >= 3
            r["R3"] = near >= 2 or hub
            r["door_steps"] = near
    # R4
    r["R4"] = bool(pay)
    return r


def facing_pairs(G):
    """Road nodes with exactly one cluster on each side; (road node, cluster a, cluster b, mirrored?)."""
    out = []
    for n in G.N.values():
        if n["kind"] != "travel":
            continue
        cs = {}
        for j in G.adj[n["id"]]:
            c = G.N[j].get("cluster")
            if c is not None and c in G.mem:
                cs.setdefault(c, j)
        if len(cs) != 2:
            continue
        (c1, j1), (c2, j2) = cs.items()
        x, y = G.xy(n["id"])
        a1 = math.atan2(G.xy(j1)[1] - y, G.xy(j1)[0] - x); a2 = math.atan2(G.xy(j2)[1] - y, G.xy(j2)[0] - x)
        if abs(abs((a1 - a2 + math.pi) % (2 * math.pi) - math.pi) - math.pi) > math.radians(25):
            continue
        same = G.CL[c1].get("form") == G.CL[c2].get("form") and len(G.mem[c1]) == len(G.mem[c2])
        if same:   # mirrored across the line through the road node, perpendicular to the pair's axis
            ux, uy = -(math.sin(a1)), math.cos(a1)
            same = _mirror_ok(G, G.mem[c1] + G.mem[c2], [], x, y, ux, uy)
        out.append((n["id"], c1, c2, same))
    return out


def summary(d, region=None):
    G = Graph(d)
    rows = [check_cluster(G, c) for c in G.mem if region is None or G.N[G.mem[c][0]].get("region") == region]
    minors = sum(1 for r in rows for i in G.mem[r["id"]] if G.N[i]["kind"] in MINOR)
    pairs = [p for p in facing_pairs(G) if region is None or G.N[p[0]].get("region") == region]
    forms = collections.Counter(r["form"] for r in rows)

    def share(key):
        tested = [r for r in rows if r[key] is not None]
        return sum(not r[key] for r in tested), len(tested)
    s = {
        "clusters": len(rows),
        "R1_fail": share("R1"), "R2_fail": share("R2"), "R3_fail": share("R3"), "R4_fail": share("R4"),
        "wasted_minor": (sum(len(r["waste"]) for r in rows), minors),
        "detour_minor": (sum(len(r["detour"]) for r in rows), minors),
        "R6_mirrored_pairs": (sum(p[3] for p in pairs), len(pairs)),
        "payoffs": sum(r["payoffs"] for r in rows),
        "clusters_2plus_payoffs": sum(r["payoffs"] >= 2 for r in rows),
        "minor_per_cluster": round(minors / max(1, len(rows)), 2),
        "top_form_share": round(max(forms.values()) / max(1, len(rows)), 3) if forms else 0,
        "all_pass": sum(all(r[k] in (True, None) for k in ("R1", "R2", "R3", "R4")) for r in rows),
    }
    return s, rows


def fmt(s):
    f = lambda t: f"{t[0]} of {t[1]}"
    return (f"clusters {s['clusters']} (all rules pass: {s['all_pass']})\n"
            f"  R1 not mirrored        {f(s['R1_fail'])}\n"
            f"  R2 dead-end nodes      {f(s['R2_fail'])} clusters, {f(s['wasted_minor'])} minor nodes "
            f"(on no shortest route: {s['detour_minor'][0]})\n"
            f"  R3 notable at the door {f(s['R3_fail'])}\n"
            f"  R4 no notable          {f(s['R4_fail'])}\n"
            f"  R6 mirrored road pairs {f(s['R6_mirrored_pairs'])} (target 5-10 %)\n"
            f"  payoffs {s['payoffs']}, clusters with 2+ {s['clusters_2plus_payoffs']}, minor per cluster "
            f"{s['minor_per_cluster']}, commonest figure {s['top_form_share']:.1%}")


def template_graph(pts, roles, edges):
    """One figure template as a graph: entry node 0 joined to a road node one unit before it, on the -y side."""
    nodes = [{"id": 0, "kind": "travel", "x": 0.0, "y": -1.0, "cluster": None}]
    kinds = {"s": "small", "N": "notable", "K": "keystone"}
    for j, ((x, y), ro) in enumerate(zip(pts, roles)):
        nodes.append({"id": j + 1, "kind": kinds.get(ro, "small"), "x": x, "y": y, "cluster": 0})
    es = [{"a": 0, "b": 1}] + [{"a": e[0] + 1, "b": e[1] + 1} for e in edges]
    return {"nodes": nodes, "edges": es, "clusters": [{"id": 0, "form": "template"}]}


def templates():
    import importlib.util
    import os
    here = os.path.dirname(os.path.abspath(__file__))
    sp = importlib.util.spec_from_file_location("pens", os.path.join(here, "regions", "pens.py"))
    pens = importlib.util.module_from_spec(sp); sp.loader.exec_module(pens)
    out = []
    for kind, (pts, roles, edges) in sorted(pens.PICT.items()):
        G = Graph(template_graph(pts, roles, edges))
        r = check_cluster(G, 0)
        r["form"] = kind
        if kind in ASYM_FORMS or kind in pens.ASYM:
            r["R1"] = None
        out.append(r)
    return out


def main():
    a = sys.argv[1:]
    if "--templates" in a:
        rows = templates()
        bad = [r for r in rows if any(r[k] is False for k in ("R1", "R2", "R3", "R4"))]
        for r in rows:
            fl = [k for k in ("R1", "R2", "R3", "R4") if r[k] is False]
            print(f"{'FAIL' if fl else 'ok  '} {r['form']:<12} n={r['n']:<3} payoffs={r['payoffs']} "
                  f"{' '.join(fl)}{' waste=' + str(len(r['waste'])) if r['waste'] else ''}"
                  f"{' door=' + str(r.get('door_steps')) if r['R3'] is False else ''}")
        print(f"{len(bad)} of {len(rows)} templates fail")
        return
    d = json.load(open(a[0], encoding="utf-8"))
    region = a[a.index("--region") + 1] if "--region" in a else None
    s, rows = summary(d, region)
    print(fmt(s))
    if "--list" in a:
        for r in rows:
            fl = [k for k in ("R1", "R2", "R3", "R4") if r[k] is False]
            if fl:
                print(f"  {r['region']:<9} {r['form']:<14} {r['name'][:40]:<40} {' '.join(fl)}")
    if "--json" in a:
        json.dump({"summary": s, "clusters": rows}, open(a[a.index("--json") + 1], "w", encoding="utf-8"), ensure_ascii=False)


if __name__ == "__main__":
    main()

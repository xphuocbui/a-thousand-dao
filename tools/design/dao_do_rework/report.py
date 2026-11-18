"""Report-only checks for a compiled Đạo Đồ map (design/dao-do/rules-2026-11-18.md section 3.8).

usage: python -I tools/design/dao_do_rework/report.py <compiled map.json> [--region R] [--base]

Prints observations beside the PoE 2 reference values of the rules file (section 5). It never places, ranks or judges
anything: no pass or fail, the eye decides (rules 3.1 and 3.3).

Definitions, the same as the PoE 2 study (section 4):
- A cluster is a connected component of small and notable nodes once roads (travel), starts and keystones are removed,
  so figures joined together count as one ("merged").
- Same drawing = sorted node kinds + sorted pairwise distances rounded to a bucket, so any turn or mirror is the same
  drawing. Results are quoted as a range over the buckets 0.3, 0.5 and 0.8 units.
- Tiers: small 1-5 nodes, medium 6-8, big 9+.
- Form: chain (no loop, no node with 3+ links inside), branch (no loop, a fork), one loop, multi-loop.
- Base clusters (the skeleton's start motifs and emblems) are kept out of the counts; --base lists them.
"""
import collections
import json
import math
import sys

BUCKETS = (0.3, 0.5, 0.8)
RIM = 84.0


def load(path):
    M = json.load(open(path, encoding="utf-8"))
    nodes = {n["id"]: n for n in M["nodes"]}
    adj = collections.defaultdict(set)
    for e in M["edges"]:
        adj[e["a"]].add(e["b"])
        adj[e["b"]].add(e["a"])
    base = set()
    for g in M.get("groups", []):
        if str(g.get("shape", "")).startswith(("start:", "emblem")):
            base.update(g.get("nodes", []))
    return nodes, adj, base


def clusters_of(nodes, adj):
    inside = lambda i: nodes[i]["kind"] in ("small", "notable")
    seen, out = set(), []
    for i in nodes:
        if i in seen or not inside(i):
            continue
        st, c = [i], set()
        seen.add(i)
        while st:
            u = st.pop()
            c.add(u)
            for v in adj[u]:
                if v not in seen and inside(v):
                    seen.add(v)
                    st.append(v)
        out.append(c)
    return out


def form(c, adj):
    k = len(c)
    e_in = sum(1 for i in c for j in adj[i] if j in c) // 2
    cyc = e_in - k + 1
    maxdeg = max(sum(1 for j in adj[i] if j in c) for i in c)
    if cyc == 0:
        return "chain" if maxdeg <= 2 else "branch"
    return "one loop" if cyc == 1 else "multi-loop"


def drawing(c, nodes, bucket):
    pts = [(nodes[i]["x"], nodes[i]["y"]) for i in c]
    kinds = tuple(sorted(nodes[i]["kind"][0] for i in c))
    d = tuple(sorted(round(math.dist(pts[a], pts[b]) / bucket) for a in range(len(pts)) for b in range(a + 1, len(pts))))
    return kinds, d


def tier(k):
    return "small" if k <= 5 else "medium" if k <= 8 else "big"


def pct(x, t):
    return "%.0f%%" % (100.0 * x / t) if t else "-"


def q(vals, f):
    vals = sorted(vals)
    return vals[min(len(vals) - 1, int(f * len(vals)))] if vals else float("nan")


def rng(vals, fmt="%d"):
    lo, hi = min(vals), max(vals)
    return fmt % lo if lo == hi else (fmt + "-" + fmt) % (lo, hi)


def main():
    args = sys.argv[1:]
    region = args[args.index("--region") + 1] if "--region" in args else None
    show_base = "--base" in args
    nodes, adj, base = load(args[0])
    allc = clusters_of(nodes, adj)
    basec = [c for c in allc if c <= base]
    cs = [c for c in allc if not c <= base]
    mixed = sum(1 for c in cs if c & base)
    if region:
        cs = [c for c in cs if collections.Counter(nodes[i]["region"] for i in c).most_common(1)[0][0] == region]
    T = len(cs)
    print("Đạo Đồ report (observations only; PoE 2 values from rules-2026-11-18.md section 5)")
    print("map %s%s: %d nodes; %d clusters drawn (%d joined to a start motif or emblem), %d base clusters "
          "(start motifs, emblems on their own) left out" % (
              args[0], " region " + region if region else "", len(nodes), T, mixed, len(basec)))
    if show_base:
        for c in basec:
            print("  base cluster: %d nodes, region %s" % (len(c), nodes[next(iter(c))]["region"]))
    if not T:
        print("no drawn clusters yet")
        return

    cen = [(sum(nodes[i]["x"] for i in c) / len(c), sum(nodes[i]["y"] for i in c) / len(c)) for c in cs]
    reg = [collections.Counter(nodes[i]["region"] for i in c).most_common(1)[0][0] for c in cs]
    size = [len(c) for c in cs]
    doors = [frozenset(j for i in c for j in adj[i] if nodes[j]["kind"] in ("travel", "start")) for c in cs]

    # size mix and gradient
    print("\nSIZE MIX (targets, not quotas: about half 3-5, a third 6-8, a seventh 9+; PoE 2 1-2 2%, 3-5 50%, 6-8 34%, 9+ 14%)")
    bands = [("1-2", 1, 2), ("3-5", 3, 5), ("6-8", 6, 8), ("9+", 9, 10 ** 6)]
    print("  " + ", ".join("%s %s" % (n, pct(sum(lo <= s <= hi for s in size), T)) for n, lo, hi in bands)
          + "; median %d, p90 %d" % (q(size, 0.5), q(size, 0.9)))
    print("  by distance from the centre (PoE 2: small 66% -> 54% -> 44%, big 8% -> 12% -> 19%, inner half outward):")
    for name, lo, hi in (("r < 42", 0, 42), ("42-63", 42, 63), ("63-84", 63, RIM + 0.01), ("islands", RIM + 0.01, 1e9)):
        ix = [k for k in range(T) if lo <= math.hypot(*cen[k]) < hi]
        if ix:
            print("    %-8s %4d clusters: small %s, medium %s, big %s" % (
                name, len(ix), pct(sum(tier(size[k]) == "small" for k in ix), len(ix)),
                pct(sum(tier(size[k]) == "medium" for k in ix), len(ix)), pct(sum(tier(size[k]) == "big" for k in ix), len(ix))))

    # form mix
    fm = collections.Counter(form(c, adj) for c in cs)
    print("\nFORM MIX (reference: chains about 40%, one loop 35%, multi-loop at most 15%, branches 10%; PoE 2 38/37/14/9)")
    print("  " + ", ".join("%s %s" % (k, pct(fm[k], T)) for k in ("chain", "one loop", "multi-loop", "branch")))

    # largest merged
    big = sorted(size, reverse=True)[:5]
    print("\nLARGEST MERGED CLUSTERS (PoE 2's largest is 43): %s" % ", ".join(map(str, big)))

    # reuse, per bucket
    per = {b: [drawing(c, nodes, b) for c in cs] for b in BUCKETS}
    print("\nREUSE (ranges over buckets %s)" % ", ".join(map(str, BUCKETS)))
    distinct = [len(set(per[b])) for b in BUCKETS]
    once = [sum(1 for v in collections.Counter(per[b]).values() if v == 1) for b in BUCKETS]
    print("  different drawings %s of %d clusters; drawn only once %s of clusters (PoE 2 45-60%%)" % (
        rng(distinct), T, "-".join(sorted({pct(o, T) for o in once}))))
    for t in ("small", "medium", "big"):
        over, worst = [], []
        for b in BUCKETS:
            cnt = collections.Counter(per[b][k] for k in range(T) if tier(size[k]) == t)
            lim = {"small": 10 ** 6, "medium": 3, "big": 1}[t]
            over.append(sum(v for v in cnt.values() if v > lim))
            worst.append(max(cnt.values(), default=0))
        n_t = sum(tier(s) == t for s in size)
        rule = {"small": "families repeat freely", "medium": "a drawing at most 3 times",
                "big": "each drawn once"}[t]
        print("  %-6s %4d clusters (%s): most copies of one drawing %s%s" % (
            t, n_t, rule, rng(worst), "" if t == "small" else "; clusters past the rule %s" % rng(over)))
    regions = sorted(set(reg))
    print("  per region (bucket 0.5): clusters / different drawings / most copies of one")
    for r in regions:
        ix = [k for k in range(T) if reg[k] == r]
        cnt = collections.Counter(per[0.5][k] for k in ix)
        print("    %-9s %4d / %4d / %2d" % (r, len(ix), len(cnt), max(cnt.values())))

    # twins and neighbourhoods, bucket 0.5
    sig = per[0.5]
    by = collections.defaultdict(list)
    for k in range(T):
        by[sig[k]].append(k)
    twin = []
    close_shared = close = 0
    for k in range(T):
        mates = [j for j in by[sig[k]] if j != k]
        if not mates:
            continue
        j = min(mates, key=lambda j: math.dist(cen[k], cen[j]))
        d = math.dist(cen[k], cen[j])
        twin.append(d)
        if d < 6:
            close += 1
            close_shared += bool(doors[k] & doors[j])
    print("\nTWINS (bucket 0.5; rule: about 6+ apart unless a deliberate pair; PoE 2 p10 2.4, median 13.2, 26% closer than 6, two thirds of those on one road node)")
    if twin:
        print("  %d clusters have a copy; nearest copy p10 %.1f, median %.1f; closer than 6: %s, of those sharing a road node %s" % (
            len(twin), q(twin, 0.1), q(twin, 0.5), pct(close, len(twin)), pct(close_shared, close)))
    else:
        print("  no drawing appears twice")
    near_diff, same_nn = [], 0
    for k in range(T):
        around = [j for j in range(T) if j != k and math.dist(cen[k], cen[j]) < 6]
        near_diff.append(len({sig[j] for j in around} | {sig[k]}))
        if around:
            nn = min(around, key=lambda j: math.dist(cen[k], cen[j]))
            same_nn += sig[nn] == sig[k]
    print("NEIGHBOURHOODS (cluster centres): different drawings within 6 units, itself included, median %d (PoE 2 7, small clusters); nearest neighbour is the same drawing %s (PoE 2 11%%)" % (
        q(near_diff, 0.5), pct(same_nn, T)))
    hubs = collections.defaultdict(list)
    for k in range(T):
        for d in doors[k]:
            hubs[d].append(sig[k])
    multi = [v for v in hubs.values() if len(v) >= 2]
    rep = sum(1 for v in multi if len(set(v)) < len(v))
    print("HUBS: road nodes carrying 2+ clusters %d; carrying two copies of one drawing %s (PoE 2 11%%)" % (len(multi), pct(rep, len(multi))))


if __name__ == "__main__":
    main()

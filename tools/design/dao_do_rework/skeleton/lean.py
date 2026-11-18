"""Lean notables for the Đạo Đồ v2 (review 2026-11-17: the v1 tree inverted PoE's notable mix, 18 / 28 / 52 % of
clusters with 1 / 2 / 3+ notables against PoE 2's 60 / 24 / 13 %, 2,059 notables in all).

The lean library keeps every authored figure exactly as drawn (same nodes, same links) and only re-marks which nodes
are notables: as few as the cluster rules allow. Rule R2 (no dead-end minor node) means a leaf must stay a notable,
so a figure with two mirrored tips keeps two; a closed figure (ring, lens, diamond) keeps one, on its axis tip.

For each figure: try every possible keep set (one axis node, or one mirrored pair), mark only it, then promote
whatever R2 forces (dead-end leaves, then the farthest node of any loop that hangs off one point) until no minor node
is wasted. The result with the fewest notables wins; ties go to a set that was a notable in the original drawing,
then to the deepest (most steps from the entry), then to the highest.

Big figures (12+ nodes) keep at least two notables, so the outer band's set pieces still pay off more than a lens.

Also here: small figures (4-6 nodes, one notable) for fill, since PoE 2's median cluster is 5 nodes and v1's was 8.

A layout opts in with an entry {"library": "lean"} in any region (layout.py installs it before compiling); v1
layouts never name it and compile exactly as before.

Usage: python -I tools/design/dao_do_rework/skeleton/lean.py           (prints the before/after table)
"""
import collections
import math
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
sys.path.insert(0, os.path.dirname(HERE))
import authored as A  # noqa: E402

MIN_BIG = 12            # figures this size or larger keep at least two notables


def _adj(S):
    adj = collections.defaultdict(set)
    for a, b, _ in S.links:
        adj[a].add(b); adj[b].add(a)
    return adj


def _mirror(S):
    """index -> its mirror twin (itself on the axis)."""
    out = {}
    for i, (u, v, _) in enumerate(S.nodes):
        for j, (x, y, _) in enumerate(S.nodes):
            if abs(x + u) < 1e-3 and abs(y - v) < 1e-3:
                out[i] = j; break
        else:
            out[i] = i
    return out


def _blocks(adj, nodes):
    """Biconnected components (as node sets) of the graph on `nodes`."""
    idx, low, st, out, cnt = {}, {}, [], [], [0]

    def dfs(u, p):
        idx[u] = low[u] = cnt[0]; cnt[0] += 1
        for w in adj[u]:
            if w not in nodes or w == p:
                continue
            if w not in idx:
                st.append((u, w)); dfs(w, u)
                low[u] = min(low[u], low[w])
                if low[w] >= idx[u]:
                    comp = set()
                    while True:
                        e = st.pop(); comp |= set(e)
                        if e == (u, w):
                            break
                    out.append(comp)
            elif idx[w] < idx[u]:
                st.append((u, w)); low[u] = min(low[u], idx[w])
    for s in nodes:
        if s not in idx:
            dfs(s, None)
    return out


def dead(S, roles):
    """Minor nodes on no simple route between two terminals (the entry and the notables): cluster_rules.dead_ends."""
    adj = _adj(S)
    nodes = set(range(len(S.nodes)))
    term = {0} | {i for i, r in enumerate(roles) if r == "N"}
    if len(term) < 2:
        return sorted(nodes - term)
    B = _blocks(adj, nodes)
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
    return sorted(i for i in nodes if i not in keep and i not in term)


def _steps(S):
    adj = _adj(S)
    d = {0: 0}; q = [0]
    for u in q:
        for w in adj[u]:
            if w not in d:
                d[w] = d[u] + 1; q.append(w)
    return d


def _rules_fail(S, roles):
    """True when the marking breaks a cluster rule (R1-R4) as cluster_rules.py checks it."""
    import cluster_rules as cr
    P = [(u - S.nodes[0][0], v - S.nodes[0][1]) for u, v, _ in S.nodes]
    res = cr.check_cluster(cr.Graph(cr.template_graph(P, "".join(roles), [(a, b) for a, b, _ in S.links])), 0)
    return any(res[k] is False for k in ("R1", "R2", "R3", "R4"))


def lean_roles(S):
    """The leanest notable marking of S that keeps the cluster rules. Returns a list of roles ('s' / 'N')."""
    n = len(S.nodes)
    if n <= 1:
        return [r for _, _, r in S.nodes]
    mir = _mirror(S); st = _steps(S); adj = _adj(S)
    orig = [r for _, _, r in S.nodes]
    first = min(st[i] for i in range(n) if orig[i] == "N")      # how deep the original's nearest notable sat
    cands = sorted({tuple(sorted({i, mir[i]})) for i in range(1, n)})
    best = None
    for K in cands:
        roles = ["s"] * n
        for i in K:
            roles[i] = "N"
        for _ in range(n):
            dd = dead(S, roles)
            if not dd:
                break
            leaves = [i for i in dd if len(adj[i]) == 1]
            pick = leaves or [max(dd, key=lambda i: (st[i], S.nodes[i][1]))]
            for i in pick:
                roles[i] = "N"; roles[mir[i]] = "N"
        if dead(S, roles):
            continue
        if min(st[i] for i in range(n) if roles[i] == "N") < min(first, 2):
            continue            # rule R3: no payoff at the door
        if _rules_fail(S, roles):
            continue
        cnt = roles.count("N")
        if n >= MIN_BIG and cnt < 2:
            continue
        key = (cnt, -sum(orig[i] == "N" for i in K), -max(st[i] for i in K), -max(S.nodes[i][1] for i in K))
        if best is None or key < best[0]:
            best = (key, roles)
    return best[1] if best else orig


def leaned(S):
    """A copy of shape S with the lean notable marking."""
    T = A.Shape(S.name)
    T.nodes = [(u, v, r) for (u, v, _), r in zip(S.nodes, lean_roles(S))]
    T.links = list(S.links)
    return T


# --- small figures, one notable each (4-7 nodes) ---
def arc(S, i, j, s):
    """Link S's nodes i-j (right-hand twins; mirrored) as an arc bulging s to the right of i->j (s < 0: to the
    left). The centre is computed, so it is equidistant from both ends."""
    i0 = i[0] if isinstance(i, tuple) else i
    j0 = j[0] if isinstance(j, tuple) else j
    p, q = S.nodes[i0][:2], S.nodes[j0][:2]
    dx, dy = q[0] - p[0], q[1] - p[1]
    L = math.hypot(dx, dy); h = L / 2
    nr = (dy / L, -dx / L)
    r = (h * h + s * s) / (2 * abs(s))
    m = ((p[0] + q[0]) / 2, (p[1] + q[1]) / 2)
    k = s - math.copysign(r, s)
    S.l(i, j, (m[0] + nr[0] * k, m[1] + nr[1] * k))


def petal():
    S = A.Shape("Petal")          # a diamond drawn with arcs: a pointed leaf
    e = S.n(0, -1.2); sd = S.n(0.8, 0.0); t = S.n(0, 1.2, "N")
    arc(S, e, sd, 0.25); arc(S, sd, t, 0.25)
    return S


def bud():
    S = A.Shape("Bud")            # stem, two sepals closing on the tip
    e = S.n(0, -1.7); s = S.n(0, -0.6); sd = S.n(0.8, 0.3); t = S.n(0, 1.2, "N")
    S.l(e, s); S.l(s, sd); arc(S, sd, t, 0.2)
    return S


def gem():
    S = A.Shape("Gem")            # a cut stone: crown and pavilion
    e = S.n(0, -1.5); lo = S.n(0.75, -0.4); hi = S.n(0.75, 0.6); t = S.n(0, 1.3, "N")
    S.l(e, lo); S.l(lo, hi); S.l(hi, t)
    S.l(lo[0], lo[1], mirror=False)
    return S


def pod():
    S = A.Shape("Pod")            # a long lens with two nodes a side
    e = S.n(0, -1.8); a = S.n(0.6, -0.75); b = S.n(0.6, 0.75); t = S.n(0, 1.8, "N")
    arc(S, e, a, 0.15); arc(S, a, b, 0.2); arc(S, b, t, 0.15)
    return S


def drop():
    S = A.Shape("Drop")           # a teardrop: straight below, round above
    e = S.n(0, -1.3); sd = S.n(0.75, 0.2); t = S.n(0, 1.0, "N")
    S.l(e, sd); arc(S, sd, t, 0.3)
    return S


def shard():
    S = A.Shape("Shard")          # a split blade: a bar across under the point
    e = S.n(0, -1.6); s = S.n(0, -0.5); sd = S.n(0.7, 0.45); t = S.n(0, 1.5, "N")
    S.l(e, s); S.l(s, sd); S.l(sd, t)
    S.l(sd[0], sd[1], mirror=False)
    return S


def vase():
    S = A.Shape("Vase")           # rails drawn round
    e = S.n(0, -1.6); a = S.n(0.75, -0.5); b = S.n(0.6, 0.6); t = S.n(0, 1.4, "N")
    arc(S, e, a, 0.2); arc(S, a, b, 0.15); arc(S, b, t, 0.2)
    return S


def pendant():
    S = A.Shape("Pendant")        # a little ring hanging from a stem
    e = S.n(0, -1.9); s = S.n(0, -0.8); c = (0, 0.3)
    r = S.n(*A.pol(1.1, 120, c)); r2 = S.n(*A.pol(1.1, 50, c)); t = S.n(0, 1.4, "N")
    S.l(e, s); S.l(s, r, c); S.l(r, r2, c); S.l(r2, t, c)
    return S


SMALL_LEAN = [petal, bud, gem, pod, drop, shard, vase, pendant]


def library():
    """name -> Shape, the lean library: every authored figure leaned, plus the small one-notable figures."""
    out = {}
    for f in A.SHAPES:
        S = f()
        out[S.name] = leaned(S)
    for f in SMALL_LEAN:
        S = f()
        out[S.name] = S
    return out


def install(G):
    """Swap mapgen's AUTH (shared by layout.py, fill.py and place_compound) for the lean library, in place."""
    G.AUTH.update(library())
    G.LEAN = True


def main():
    rows = []
    for f in A.SHAPES + SMALL_LEAN:
        S = f()
        L = leaned(S) if f not in SMALL_LEAN else S
        before = sum(r == "N" for _, _, r in S.nodes); after = sum(r == "N" for _, _, r in L.nodes)
        probs = [p for p in A.check(L) if not p.startswith("notables")]
        rows.append((S.name, len(S.nodes), before, after, probs))
    for r in rows:
        print("%-24s %3d nodes  notables %d -> %d  %s" % (r[0], r[1], r[2], r[3], " ".join(r[4])))
    c = collections.Counter(min(r[3], 3) for r in rows)
    print("figures with 1 / 2 / 3+ notables after:", dict(sorted(c.items())))
    print("problems:", sum(bool(r[4]) for r in rows))


if __name__ == "__main__":
    main()

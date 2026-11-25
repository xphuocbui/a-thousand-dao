"""Measure Linh Căn rule 2 / Formulas A2 and D4 (roots follow the land) on the fixed world: province land qi,
element factors, world means, and a birth simulation (inclusion rates, mean purity, Ice rate). Observations only.
Run: python -I tools/design/map/land_birth_measure.py <repo root>   (2026-11-25, world-depth pass)"""
import struct, zlib, json, sys, collections
import numpy as np
ROOT = sys.argv[1]
def grid(path):
    b = open(path, 'rb').read(); w, h, n = struct.unpack('<HHH', b[8:14]); off = 14; L = {}
    for i in range(n):
        tag = b[off:off+4].decode(); nb, sg, rl, cl = struct.unpack('<BBII', b[off+4:off+14])
        raw = zlib.decompress(b[off+14:off+14+cl]); off += 14 + cl
        dt = {(1,0): np.uint8, (2,0): np.uint16, (2,1): np.int16}[(nb, sg)]
        L[tag] = np.frombuffer(raw, dtype=dt).reshape(h, w).astype(np.float64)
    return L, w, h
Q, w, h = grid(ROOT + '/assets/map/continent_11_qi.bin')
G, _, _ = grid(ROOT + '/assets/map/continent_11_grid.bin')
pid = np.frombuffer(open(ROOT + '/assets/map/continent_11_province_ids.bin', 'rb').read(), dtype=np.uint16)
pid = pid[-w*h:].reshape(h, w)
EL = ['MO', 'HO', 'TH', 'KI', 'TY']; ELN = ['moc', 'hoa', 'tho', 'kim', 'thuy']
VA = {'PH': 'phong', 'LO': 'loi', 'AM': 'am', 'QU': 'quang', 'BA': 'bang'}
wsum = G['SHR1'] + G['SHR2'] + G['SHR3']; wsum[wsum == 0] = 1
def tile(prefix):
    return sum(Q['S%d%s' % (k, prefix)] * G['SHR%d' % k] for k in (1, 2, 3)) / wsum
def tilev(prefix):
    return sum(Q['V%d%s' % (k, prefix)] * G['SHR%d' % k] for k in (1, 2, 3)) / wsum
S = np.stack([tile(e) for e in EL], -1)
tot = S.sum(-1, keepdims=True); tot[tot == 0] = 1; S = 100 * S / tot
V = {VA[k]: tilev(k) for k in VA}
print('raw scale check: S1MO max', Q['S1MO'].max(), 'V1BA max', Q['V1BA'].max())
prov = json.load(open(ROOT + '/assets/data/world_provinces.json', encoding='utf-8'))['provinces']
cont = json.load(open(ROOT + '/assets/data/world_continent.json', encoding='utf-8'))
P = {p['id']: p for p in cont['places']}
def factor(s, k=1.0): return np.clip(1 + k * (s - 20) / 20, 0.25, 3)
rows = []
for p in prov:
    if p['kind'] != 'settlement': continue
    m = pid == p['id']
    if not m.any(): continue
    ms = S[m].mean(0)
    mv = {v: V[v][m].mean() for v in V}
    mvmax = {v: V[v][m].max() for v in V}
    rows.append((p, ms, mv, mvmax))
fac = np.array([factor(r[1]) for r in rows])
print('settlement provinces', len(rows))
for i, e in enumerate(ELN):
    sh = np.array([r[1][i] for r in rows])
    print('%-5s province mean share: min %.0f p25 %.0f med %.0f p75 %.0f max %.0f | factor k=1: max %.2f, provinces with factor>=1.5: %d, >=2: %d' % (
        e, sh.min(), np.percentile(sh, 25), np.median(sh), np.percentile(sh, 75), sh.max(), fac[:, i].max(), (fac[:, i] >= 1.5).sum(), (fac[:, i] >= 2).sum()))
for v in V:
    mean = np.array([r[2][v] for r in rows]); mx = np.array([r[3][v] for r in rows])
    print('%-6s province mean variant qi: max %.1f, provinces >=5: %d, >=10: %d | province MAX tile: provinces >=10: %d >=20: %d' % (v, mean.max(), (mean >= 5).sum(), (mean >= 10).sum(), (mx >= 10).sum(), (mx >= 20).sum()))
# village-tile comparison: settled places
st = [p for p in cont['places'] if p['kind'] in ('city', 'town', 'village', 'market')]
vh = np.array([p['qi']['shares'].get('hoa', 0) for p in st])
print('villages/towns: Fire share max %.0f, >=30: %d of %d' % (vh.max(), (vh >= 30).sum(), len(st)))
ph = np.array([r[1][1] for r in rows])
print('provinces: Fire mean max %.0f, >=30: %d of %d' % (ph.max(), (ph >= 30).sum(), len(rows)))

# --- relative normalisation and a birth simulation ---
rng = np.random.default_rng(7)
cw = np.array([45, 32, 15, 6.5, 1.5]); cw = cw / cw.sum()
shares = np.array([r[1] for r in rows])                       # provinces x 5
pop = np.array([max(1, len([x for x in r[0]['places'] if x.get('kind') in ('city','town','village','market','great_seat','minor_seat')])) for r in rows], float)
wmean = (shares * pop[:, None]).sum(0) / pop.sum()
print('world (population-weighted) mean share by element:', dict(zip(ELN, np.round(wmean, 1))))
def sim(fac, n=200000):
    inc = np.zeros(5); idx = rng.choice(len(rows), size=n, p=pop / pop.sum())
    nb = rng.choice(5, size=n, p=cw) + 1
    for t in range(n):
        wts = fac[idx[t]].copy(); chosen = []
        for _ in range(nb[t]):
            p = wts / wts.sum(); j = rng.choice(5, p=p); chosen.append(j); wts[j] = 0
        inc[chosen] += 1
    return inc / n
base = sim(np.ones_like(shares), 40000)
absf = np.clip(1 + (shares - 20) / 20, 0.25, 3)
relf = np.clip(1 + (shares - wmean) / wmean, 0.25, 3)
print('inclusion rate (share of people holding the element), uniform:', dict(zip(ELN, np.round(base, 3))))
print('                                     absolute k=1 (vs 20 %):', dict(zip(ELN, np.round(sim(absf, 40000), 3))))
print('                                     relative k=1 (vs world mean):', dict(zip(ELN, np.round(sim(relf, 40000), 3))))
for i, e in enumerate(ELN):
    print('%-5s relative factor: provinces >=1.5: %d, >=2: %d, max %.2f' % (e, (relf[:, i] >= 1.5).sum(), (relf[:, i] >= 2).sum(), relf[:, i].max()))

# --- purity shift and Ice ---
def sim2(fac, vmax_ice, n=60000, p_land=6.0, k_var=1.0, v_hi=5.0, t_parts=0.5, tilt=True):
    idx = rng.choice(len(rows), size=n, p=pop / pop.sum()); nb = rng.choice(5, size=n, p=cw) + 1
    pur = []; ice = 0; ge85 = 0
    for t in range(n):
        f = fac[idx[t]].copy()
        q = vmax_ice[idx[t]] if tilt else 0.0
        if tilt and q > 0:            # variant land tilts its parts: Water share + t_parts * q, re-normalised factor
            s = shares[idx[t]].copy(); s[4] += t_parts * q
            f = np.clip(1 + (s - wmean) / wmean, 0.25, 3)
        wts = f.copy(); chosen = []
        for _ in range(nb[t]):
            j = rng.choice(5, p=wts / wts.sum()); chosen.append(j); wts[j] = 0
        prs = {}
        for j in chosen:
            p = np.clip(round(rng.normal(50, 20) + (p_land * (f[j] - 1) if tilt else 0)), 10, 100); prs[j] = p; pur.append(p); ge85 += p >= 85
        if 4 in prs:
            mult = np.clip(1 + k_var * q / 10, 1, v_hi) if tilt else 1
            if rng.random() < 0.12 * prs[4] / 100 * mult: ice += 1
    return np.mean(pur), ge85 / len(pur), ice / n
vice = np.array([r[3]['bang'] / 100 for r in rows])
print('uniform:   mean purity %.1f, share >=85 %.3f, Ice rate %.4f' % sim2(np.ones_like(shares), vice, tilt=False))
print('R1 (rel):  mean purity %.1f, share >=85 %.3f, Ice rate %.4f' % sim2(relf, vice))
ice_prov = [r for r in rows if r[3]['bang'] >= 1000]
print('Ice provinces (strongest tile >= 10):', [(r[0]['name'], round(r[3]['bang']/100)) for r in ice_prov])

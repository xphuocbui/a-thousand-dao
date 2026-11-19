"""Check and render step A (one idea per big picture) from design/dao-do/content/src/ideas.py.

Usage (repo root): python -I tools/design/dao_do_rework/content/ideas_report.py [--write]
Checks (observations only): every big picture has an idea; every idea's lines pass the method's §3 at the small
grade (its first two lines) and the notable grade (all lines); no two ideas share the same first-two-line pair;
each of the 25 capabilities is placed once; coverage per element land. --write renders
design/dao-do/big-cluster-ideas-v5.md from the data.
"""
import collections
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
sys.path.insert(0, HERE)
import content_lib as L   # noqa: E402
import pieces as P        # noqa: E402

ROOT = L.ROOT
MAP = os.path.join(ROOT, 'design', 'dao-do', 'cells', 'versions', 'v5-frozen-2026-11-19', 'dao-do-map.json')
SRC = os.path.join(ROOT, 'design', 'dao-do', 'content', 'src', 'ideas.py')
OUT = os.path.join(ROOT, 'design', 'dao-do', 'big-cluster-ideas-v5.md')
AREAS = ['fire', 'earth', 'metal', 'water', 'wood', 'light', 'thunder', 'darkness', 'hub',
         'chaos-fire', 'chaos-earth', 'chaos-metal', 'chaos-water', 'chaos-wood']
SIDES = {'fire': ('toward Earth', 'toward Wood'), 'earth': ('toward Metal', 'toward Fire'),
         'metal': ('toward Water', 'toward Earth'), 'water': ('toward Wood', 'toward Metal'),
         'wood': ('toward Fire', 'toward Water')}
TITLE = {'fire': 'Fire (Hỏa)', 'earth': 'Earth (Thổ)', 'metal': 'Metal (Kim)', 'water': 'Water (Thủy)',
         'wood': 'Wood (Mộc), with the Wind cells 43-44', 'light': 'Light island (Quang): the Sun',
         'thunder': 'Thunder island (Lôi)', 'darkness': 'Darkness island (Ám) and the Shadow Shrine',
         'hub': 'Hub: the Chaos swirl', 'chaos-fire': 'Start motif, Fire (cell 3)', 'chaos-earth': 'Start motif, Earth (cell 2)',
         'chaos-metal': 'Start motif, Metal (cell 4)', 'chaos-water': 'Start motif, Water (cell 5)',
         'chaos-wood': 'Start motif, Wood (cell 1)'}
COVER = {  # coverage families (method §4.1.5): which stat keys count
    'element damage': lambda k, s: k in ('attack_pct', 'crit_chance_pct', 'crit_damage_pct', 'resist_pen_pct', 'convert_pct', 'stack_effect_pct') and s,
    'defence': lambda k, s: k in ('resist_pct', 'block_rating', 'defense_pct', 'ward_efficiency_pct', 'body_shield_pct', 'evade_pct', 'khi_huyet_pct', 'soul_res_pct'),
    'sustain': lambda k, s: k in ('health_regen_pct', 'health_regen_inc_pct', 'linh_luc_regen_pct', 'linh_luc_regen_inc_pct', 'leech_linh_luc_pct', 'linh_luc_on_hit_pct', 'linh_luc_on_crit_pct', 'healing_pct', 'healing_taken_pct'),
    'own system': lambda k, s: k in ('alchemy_success', 'pill_effect_pct', 'refining_success', 'formation_power_pct', 'herb_growth_pct', 'companion_power_pct', 'companion_health_pct', 'companion_speed_pct', 'artifact_power_pct', 'artifact_attack_pct') or (k == 'attack_pct' and s in ('talisman', 'formation', 'companion')),
    'cultivation': lambda k, s: k in ('cultivation_speed_pct', 'ngo_tinh', 'density_bonus', 'than_thuc_pct'),
    'late life (rim)': lambda k, s: k in ('lifespan_pct', 'breakthrough_chance'),
}


def label(k, s):
    nm = {'attack_pct': 'damage', 'crit_chance_pct': 'crit chance', 'crit_damage_pct': 'crit damage',
          'resist_pen_pct': 'penetration', 'resist_pct': 'resistance', 'khi_huyet_pct': 'max health',
          'health_regen_pct': 'health regen', 'health_regen_inc_pct': 'health regen (incr.)',
          'linh_luc_pct': 'max linh lực', 'linh_luc_regen_pct': 'linh lực regen', 'linh_luc_regen_inc_pct': 'linh lực regen (incr.)',
          'linh_luc_on_hit_pct': 'linh lực on hit', 'linh_luc_on_crit_pct': 'linh lực on crit', 'linh_luc_on_kill_pct': 'linh lực on kill',
          'leech_linh_luc_pct': 'linh lực leech', 'defense_pct': 'ward strength', 'ward_efficiency_pct': 'ward efficiency',
          'block_rating': 'block', 'body_shield_pct': 'body shield', 'evade_pct': 'evade', 'art_speed_pct': 'art speed',
          'art_cost_pct': 'art cost', 'basic_speed_pct': 'basic attack speed', 'accuracy_pct': 'accuracy', 'pierce_pct': 'realm pierce',
          'x_soul': 'soul attack damage', 'soul_res_pct': 'soul resistance', 'status_resist_pct': 'status resistance',
          'status_duration_pct': 'status duration', 'curse_effect_pct': 'curse effect', 'timer_resist_pct': 'timer resistance',
          'stack_effect_pct': 'stack effect', 'stack_duration_pct': 'stack duration', 'convert_pct': 'conversion',
          'healing_pct': 'healing', 'healing_taken_pct': 'healing taken', 'tam_ma_resist_pct': 'heart-demon resistance',
          'qi_deviation_pct': 'qi deviation', 'dan_doc_resist_pct': 'pill-toxicity resistance', 'dan_doc_decay': 'pill-toxicity fading',
          'lifespan_pct': 'lifespan', 'breakthrough_chance': 'breakthrough chance', 'cultivation_speed_pct': 'cultivation speed',
          'density_bonus': 'spirit-qi density', 'alchemy_success': 'alchemy success', 'pill_effect_pct': 'pill effect',
          'refining_success': 'refining success', 'herb_growth_pct': 'herb growth', 'formation_power_pct': 'formation power',
          'artifact_power_pct': 'artifact power', 'artifact_attack_pct': 'artifact attack', 'artifact_defense_pct': 'artifact defence',
          'element_affinity_pct': 'element affinity', 'companion_power_pct': 'companion power share', 'companion_health_pct': 'companion health',
          'companion_speed_pct': 'companion speed', 'than_thuc_pct': 'thần thức', 'reserve_eff_pct': 'reservation efficiency',
          'ward_bill_pct': 'ward bill', 'co_duyen_pct': 'cơ duyên', 'stealth': 'stealth', 'escape_pct': 'escape chance',
          'travel_speed_pct': 'travel speed', 'mission_income_pct': 'mission income', 'ngo_tinh': 'ngộ tính', 'khi_van': 'khí vận',
          'can_cot': 'căn cốt', 'than_hon': 'thần hồn', 'dao_tam': 'đạo tâm', 'mi_luc': 'mị lực'}.get(k, k)
    return f"{nm} [{s}]" if s else nm


def main():
    rows = []
    g = {'I': lambda area, key, idea, lines, cap=None, effect=None, pending=(), note='':
         rows.append(dict(area=area, key=key, idea=idea, lines=lines, cap=cap, effect=effect, pending=list(pending), note=note))}
    exec(compile(open(SRC, encoding='utf-8').read(), SRC, 'exec'), g)
    m, nodes, adj = P.load(MAP)
    errs, warns = [], []
    by_area = collections.defaultdict(list)
    for r in rows:
        by_area[r['area']].append(r)
    pieces_by_area = {a: {p['key']: p for p in P.pieces(m, nodes, adj, a)} for a in AREAS}
    pairs = collections.defaultdict(list)
    caps = collections.Counter()
    md = []
    for a in AREAS:
        ps = pieces_by_area[a]
        big = []
        seen = set()
        for p in sorted(ps.values(), key=lambda p: (p['r'], p['key'])):
            if p['tier'] == 'B' and p['named'] and p['key'] not in seen:
                seen |= {p['key'], p.get('twin')}
                big.append(p)
        have = {}
        for r in by_area[a]:
            p = ps.get(r['key'])
            if not p:
                errs.append(f"{a}: {r['key']} is not a piece"); continue
            k = p['key'] if p['key'] in seen and not (p.get('twin') and p['twin'] in have) else p.get('twin') or p['key']
            have.setdefault(min(p['key'], p.get('twin') or p['key']), []).append(r)
            for j, (st, sc) in enumerate(r['lines']):
                if j < 2 and st != 'density_bonus':
                    L.check_mod(st, sc, L.SMALL, f"{a} {r['key']} line {j + 1}", 'small node', errs, warns)
                L.check_mod(st, sc, 4.0, f"{a} {r['key']} line {j + 1}", 'notable', errs, warns)
            pairs[frozenset(map(tuple, r['lines'][:2]))].append(f"{a}:{r['idea']}")
            if r['cap']:
                caps[r['cap'][0].split(' ')[0]] += 1
        missing = [p['key'] for p in big if min(p['key'], p.get('twin') or p['key']) not in have]
        for k in missing:
            errs.append(f"{a}: big picture {k} has no idea")
        # coverage (element lands)
        if a in SIDES:
            got = {fam for r in by_area[a] for st, sc in r['lines'] for fam, f in COVER.items() if f(st, sc)
                   and (fam != 'late life (rim)' or ps.get(r['key'], {}).get('r', 0) >= 69)}
            lack = [f for f in COVER if f not in got]
            if lack:
                warns.append(f"{a}: coverage lacks {', '.join(lack)}")
        # markdown
        md.append(f"\n## {TITLE[a]}: {len(big)} big pictures\n")
        if a in SIDES:
            md.append(f"Side: − = {SIDES[a][0]}, + = {SIDES[a][1]} (degrees off the land's axis).\n")
        md.append("| # | Where | Picture (nodes / notables) | Idea | Lines | Capability · Effect · pending |")
        md.append("|---|---|---|---|---|---|")
        for n, p in enumerate(big, 1):
            rs = have.get(min(p['key'], p.get('twin') or p['key']), [])
            pic = p['key'].split(' ', 1)[1] + (', pair' if p.get('twin') else '')
            where = f"{p['key'].split(' ')[0]}, r{p['r']:.0f}, {p['off']:+.0f}°"
            for r in rs or [None]:
                if r is None:
                    md.append(f"| {n} | {where} | {pic} ({p['n']} / {p['kinds'].count('n')}) | — | — | |"); continue
                extra = '; '.join(x for x in [r['cap'] and f"**{r['cap'][0]}** ({r['cap'][1]})", r['effect'] and f"Effect: {r['effect']}",
                                               r['pending'] and 'pending: ' + ', '.join(r['pending']), r['note']] if x)
                md.append(f"| {n} | {where} | {pic} ({p['n']} / {p['kinds'].count('n')}) | **{r['idea']}** | "
                          f"{'; '.join(label(s, c) for s, c in r['lines'])} | {extra} |")
    for k, v in pairs.items():
        if len(v) > 1:
            warns.append(f"same first two lines: {' / '.join(v)}")
    allc = {f'#{i}' for i in range(1, 26)}
    for c in sorted(allc - set(caps)):
        errs.append(f"capability {c} not placed")
    for c, n in caps.items():
        if n > 1:
            errs.append(f"capability {c} placed {n} times")
    print(f"ideas: {len(rows)}; new: {sum(r['idea'].startswith('★') for r in rows)}; capabilities placed: {len(caps)}/25")
    for e in errs:
        print('ERROR', e)
    for w in warns:
        print('warn ', w)
    if '--write' in sys.argv:
        head = open(os.path.join(HERE, 'ideas_header.md'), encoding='utf-8').read()
        open(OUT, 'w', encoding='utf-8', newline='\n').write(head + '\n'.join(md) + '\n')
        print('wrote', OUT)


if __name__ == '__main__':
    main()

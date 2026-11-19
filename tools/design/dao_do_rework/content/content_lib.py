"""Đạo Đồ content: authoring helpers, value formula and checks (design/dao-do/content-method.md).

Content source files (design/dao-do/content/src/<area>.py) are written by hand and call the helpers below:
    BIG(key, idea, a, b, nts, ...)   a big picture (9+ nodes): smalls alternate the idea's lines, notables by hand
    MED(key, a, nts, ...)            a medium cluster (6-8 nodes) or a start figure
    SM(key, a, nts)                  a small cluster (1-5 nodes): smalls carry line a, each notable a + its partner
    KEY(key, name, effect, mods)     a keystone
A line is (stat, scope) with scope a comma-separated tag string ('' = universal); a modifier is (stat, scope, W).
N(name, *mods, cap=None, effect=None, pending=()) is one notable. Notables are listed in walk order (pieces.py).

This module never chooses content: it expands the patterns the method fixes, prices by Modifier System Formulas C
and reports rule breaks (observations only).
"""
import math
import os
import re

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, '..', '..', '..', '..'))
SMALL, NOTABLE = 1.2, 8.0
F_TIER = {'T1': 0.5, 'T2': 0.25, 'T3': 0.0}

# ---- stat table: the Modifier System catalogue script (prices, grids, tiers), with the Stat List's newer keys ----
_src = open(os.path.join(ROOT, 'tools', 'design', 'modifier_catalogue.py'), encoding='utf-8').read()
_ns = {}
exec(compile(_src.split('\nout = []')[0], 'modifier_catalogue.py', 'exec'), _ns)
MULT, TIER, tier_of, value_of = _ns['MULT'], _ns['TIER'], _ns['tier'], _ns['value']

EXPAND = {'<type>': 'fire cold lightning light chaos', '<element>': 'kim moc thuy hoa tho',
          '<form>': 'sword palm seal beast formation', '<role>': 'weapon ward_gear body_gear utility',
          '<variant>': 'bang phong loi quang am', '<status>': 'burn bleed poison qi_disruption',
          'physical': 'physical force', 'artifact': 'artifact talisman formation companion', 'basic': 'basic quick slow',
          'curse': 'over_time curse', 'quick': 'quick slow', 'slow': 'slow costly', 'secluded': 'secluded travelling'}
STATS = {}   # key -> dict(price, u, d, implied, status, scopes:set of frozenset, pending_scopes:set)
for (g, name, price, u, unit, d, implied, status, scopes, note) in _ns['S']:
    m = re.search(r'`([a-z_]+)`', name)
    if not m:
        continue
    key = m.group(1) + ('#I' if ', I)' in name else '')
    rec = STATS.setdefault(key, dict(price=price, u=u, d=d, implied=implied, status=status, unit=unit,
                                     scopes=set(), pending=set()))
    for label, tags, members in scopes:
        combos = [[]] if not tags else None
        if tags and len(tags) == 1:
            combos = [[t] for t in EXPAND.get(tags[0], tags[0]).split()]
        elif tags:
            combos = []   # two-tag row: handled by TWO_TAG below
        for c in combos:
            (rec['pending'] if 'Pending' in label else rec['scopes']).add(frozenset(c))
# Stat List rows newer than the catalogue script (modifiers.md, 2026-11-11 suggestions and #44)
for key, price, u, d, status, implied in [
        ('companion_power_pct', 0.4, 0.1, 1, 'Designed', None), ('companion_speed_pct', 0.4, 0.1, 1, 'Designed', 'companion'),
        ('companion_health_pct', 0.4, 0.1, 1, 'Designed', 'companion'), ('basic_speed_pct', 0.4, 0.1, 1, 'Designed', 'basic'),
        ('status_duration_pct', 0.6, 0.1, 1, 'Designed', 'over_time'), ('curse_effect_pct', 0.6, 0.1, 1, 'Designed', 'curse'),
        ('ward_bill_pct', 0.5, 0.1, 1, 'Designed', None), ('timer_resist_pct', 0.5, 0.1, 1, 'Designed', None),
        ('status_duration_taken_pct', 0.3, 0.1, -1, 'Designed', None), ('lifespan_years', None, 0.1, 1, 'Live', None)]:
    STATS[key] = dict(price=price, u=u, d=d, implied=implied, status=status, unit='', scopes={frozenset()}, pending=set())
STATS['status_duration_pct']['scopes'] |= {frozenset(['curse'])}
STATS['status_duration_taken_pct']['scopes'] |= {frozenset(['over_time']), frozenset(['curse'])}
STATS['basic_speed_pct']['status'] = 'Designed'
for k in ('stack_effect_pct', 'stack_duration_pct'):
    STATS[k]['scopes'] = {frozenset([e, bd]) for e in EXPAND['<element>'].split() + EXPAND['<variant>'].split()
                          for bd in ('buff', 'debuff')}
TWO_TAG = {'attack_pct'}   # two-tag scopes allowed (modifiers.md rule 8, catalogue row "two tags")
VOCAB = set()
for v in EXPAND.values():
    VOCAB |= set(v.split())
VOCAB |= set(TIER) | {'buff', 'debuff', 'cultivator', 'creature'}
VOCAB = {t for t in VOCAB if not t.startswith('<')}
# never on small nodes or notables (method §3.2); rare counts may sit on keystones
NEVER_ON_NODES = {'damage_more', 'ward_more', 'body_more', 'leech_health_pct', 'bonus_ward_slots', 'art_coef_add',
                  'bonus_slots', 'free_slots', 'field_plots', 'alchemy_yield', 'stack_grant', 'beast_slots',
                  'talisman_stock', 'artifact_slots', 'status_stack_cap'}
RARE_PRICE = {'bonus_slots': 20, 'free_slots': 10, 'field_plots': 20, 'alchemy_yield': 20, 'stack_grant': 10,
              'bonus_ward_slots': 30, 'beast_slots': 15, 'talisman_stock': 10, 'artifact_slots': 25}
BREAKTHROUGH_OK = set()   # idea ids allowed to carry breakthrough_chance (filled by the area files' BREAKTHROUGH)
VARIANT_TIER = 'narrow'


def scope_tags(scope):
    return [t for t in scope.replace(' ', '').split(',') if t]


def tier_for(key, tags):
    rec = STATS[key]
    imp = rec['implied']
    if imp and imp not in TIER:
        imp = 'body_gear'   # placeholder implied tags count as family (catalogue script convention)
    tt = [t if t in TIER else ('<variant>' if t in EXPAND['<variant>'].split() else
                               '<status>' if t in EXPAND['<status>'].split() else t) for t in tags
          if t not in ('buff', 'debuff')]
    TIER.setdefault('<variant>', 'narrow')
    return tier_of(tt, imp)


def price(key, tags, budget):
    """Modifier System Formulas C. Returns (value, tier, loss share)."""
    rec = STATS[key]
    t = tier_for(key, tags)
    if rec['price'] is None:
        return None, t, 0.0
    v = value_of(budget, MULT[t], rec['price'], rec['u'], rec['d'])
    exact = budget * MULT[t] / rec['price']
    loss = 1 - abs(v) / exact if exact else 0.0
    return v, t, loss


def check_mod(key, scope, budget, where, kind, errs, warns, pending=False):
    tags = scope_tags(scope)
    if key in NEVER_ON_NODES and kind != 'keystone':
        errs.append(f'{where}: {key} is never allowed on a {kind} (method §3.2)'); return None
    if key in RARE_PRICE:
        return round(budget / RARE_PRICE[key], 3)
    if key == 'convert_pct':   # scope 'from>to': two damage types, never Soul, never to itself (Damage Types rule 6)
        a, _, b = scope.partition('>')
        types = {'physical', 'force', 'fire', 'cold', 'lightning', 'light', 'chaos'}
        if a not in types or b not in types or a == b:
            errs.append(f'{where}: conversion {scope} must be from>to between two non-Soul damage types'); return None
        return value_of(budget, MULT['family'], 0.8, 1, 1)
    if key not in STATS:
        if pending:
            return None
        errs.append(f'{where}: unknown stat {key}'); return None
    for t in tags:
        if t not in VOCAB:
            errs.append(f'{where}: unknown tag {t} on {key}')
    rec = STATS[key]
    fs = frozenset(tags)
    ok = fs in rec['scopes'] or (key in TWO_TAG and len(tags) == 2 and all(frozenset([t]) in rec['scopes'] for t in tags))
    if not ok and not pending:
        if fs in rec['pending']:
            errs.append(f'{where}: {key}[{scope}] is a Pending scope: put it in pending=() (method §3.4, choice 2a)')
        else:
            errs.append(f'{where}: scope [{scope}] is not a catalogue scope of {key}')
    if rec['status'] == 'Pending' and not pending:
        errs.append(f'{where}: {key} is Pending: put it in pending=() (choice 2a)')
    if key == 'breakthrough_chance' and kind != 'keystone':
        warns.append(f'{where}: breakthrough_chance (method §3.5)')
    v, t, loss = price(key, tags, budget)
    if v is not None and v == 0:
        errs.append(f'{where}: {key}[{scope}] floors to 0 at {budget} W (method §3.3)')
    elif loss > 0.15:
        warns.append(f'{where}: {key}[{scope}] loses {loss:.0%} to rounding at {budget} W')
    return round(v, 4) if v is not None else v


# ---- authoring records ----
class N:
    """One notable. cap=('#10', 'T1') or effect='Name' sit on one copy of a mirrored pair only (the copy with the
    negative axis offset); alt=(mods...) is what the other copy's notable carries instead (a full 8 W)."""
    def __init__(self, name, *mods, cap=None, effect=None, pending=(), alt=None, alt_name=None):
        self.name, self.mods, self.cap, self.effect, self.pending = name, list(mods), cap, effect, list(pending)
        self.alt, self.alt_name = (list(alt) if alt else None), alt_name


def n(name, x, y, wx=4, wy=4, **kw):
    """Short form of a two-modifier notable: n(name, line, line, W, W). A line is (stat, scope)."""
    return N(name, (x[0], x[1], wx), (y[0], y[1], wy), **kw)


AREA = []   # filled by the content source file


def BIG(key, nts, idea=None, a=None, b=None, c=None, pat='AAB', twin=True, smalls=None):
    """idea and lines a, b, c default to the piece's step-A idea in content/src/ideas.py (filled by build.py)."""
    AREA.append(dict(kind='B', key=key, idea=idea, a=a, b=b, c=c, nts=nts, pat=pat, twin=twin, smalls=smalls))


def MED(key, a, nts, b=None, pat='A', twin=True, theme=None, smalls=None):
    AREA.append(dict(kind='M', key=key, idea=theme, a=a, b=b, c=None, nts=nts, pat=pat, twin=twin, smalls=smalls))


def SM(key, a, nts, twin=True):
    """nts: list of (name, partner line) or N(...)."""
    out = []
    for x in nts:
        out.append(x if isinstance(x, N) else N(x[0], (a[0], a[1], 4.0), (x[1][0], x[1][1], 4.0)))
    AREA.append(dict(kind='S', key=key, idea=None, a=a, b=None, c=None, nts=out, pat='A', twin=twin, smalls=None))


def ONE(ids, a):
    """Loose small nodes with no cluster (the base map's proposal nodes): each carries line a at the small grade."""
    AREA.append(dict(kind='O', ids=list(ids), a=a))


def KEY(key, name, effect, mods, closes=''):
    AREA.append(dict(kind='K', key=key, name=name, effect=effect, mods=mods, closes=closes))

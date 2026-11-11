# The Nine-Gate Warden (Cửu Quan Thủ Hộ Giả): a Hóa Thần boss that shuts one door on you every 12 s, rebuilt from library arts and the Earth/Metal catalogue techniques.

Files: `builds/deity-warden.fight.json` (hoa_than), `builds/deity-warden.nguyen-anh.fight.json` (nguyen_anh, 6 slots).
Kept unchanged: realm, root (`purity` metal 80 / earth 70), layers, crit, ward, body, cleanse share. The old files had no keystones, curses, effects, counters or states.

## Old piece to library piece

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Gate Hammer (heavy Earth slam, 4 Earth debuff stacks) | `strata-hammer` (heavy Earth hammer on Strata); a common `gate-hammer` exists but is a generated-technique art, not carried | mountain-heart-canon (6) |
| Closing Palm (metal palm, 3 Metal debuff stacks) | none carried (`closing-palm` is common-only); nearest by role: `sinking-weight` (Earth seal, stacks) | mountain-heart-canon (2) |
| Lustral Bell (cleanse on a 10 s clock) | none; no library art cleanses on a clock | lost |
| Deaf Verdict (soul) | none carried (soul arts sit on hollow-bell-canon, a Water root) | lost |
| Open Hand Reckoning (no ward, doubled offence) | `bone-turning-palm` (heavy palm through the body) | mountain-bone-body-art (5) |
| Iron Gate (block / per-hit ward identity) | `iron-hide-stance`, `mountain-stance`, `bastion-reprisal`, `mountain-root-stance` | iron-hide-manual (3); mountain-heart-canon (1, 4); mountain-bone-body-art (2) |

## Techniques chosen and why

- **Main: `mountain-heart-canon`** (Profound, tho). A whole four-art suite of Earth stance, ward and shield-burst arts: the Warden is a wall whose body and ward layers (shield 0.3, block 40, layers on the caps) feed bastion-reprisal and strata-hammer. Earth is purity 70, usable.
- **Aux: `iron-hide-manual`** (kim secret): iron-hide-stance (+120 resistance, +35 block), the Iron Gate in one art.
- **Aux: `mountain-bone-body-art`** (body, always usable): a body-shield passive, mountain-root-stance and bone-turning-palm (the nearest to the Open Hand's heavy hit).
- Seven arts at hoa_than (no slot warning). At nguyen_anh fight.py reports 7 arts in 6 slots, so `mountain-root-stance` (the stance that makes arts 20 % slower) was dropped there; the other six are the same.
- Hunter's Reach and Nine-Temper (kim mains) were passed over: both are offence engines, the guide's concept is defence.

## Lost in the move

- Lustral Bell / Lustral Toll: no library art cleanses on a clock; the 10 s purge is gone (it was already only an approximation).
- Deaf Verdict (soul art): the catalogue has soul arts only on a Water root; the Warden has none.
- Closing Palm and Gate Hammer as named arts: they are common arts reachable only through a generated common technique, which would cost the main method; nearest suite pieces taken.
- The phase script, ward swap and Open Hand were never modelled and still are not.
- Five technique passives have no engine stat and did not run (below).

## Fights

Foes: typical and top_end Hóa Thần (`--matrix`); 20 fights each.

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical hoa_than | 1.9 | 20-0-0 | never | 1.9 | none |
| top_end hoa_than | 4.7 | 20-0-0 | never | 4.0 | L2 0.3, trig_budget 2.2 per fight |
| typical nguyen_anh (6 arts) | 1.9 | 20-0-0 | never | 1.0 | none |

## --without tests (hoa_than, typical; top_end shown too)

| Test | Typical before -> after | Top-end before -> after |
|---|---|---|
| `--without tech:mountain-heart-canon` | 1.9 s, 20-0 -> 1.9 s, 20-0 | 4.7 s, 20-0 -> 4.7 s, 20-0 (L2 clip gone) |
| `--without strata-hammer` (identity piece) | 1.9 s, 20-0 -> 1.9 s, 20-0 (NO_CHANGE) | 4.7 s, 20-0 -> 4.7 s, 20-0 (NO_CHANGE) |

(The main-technique test removes only its always-on passive effect; the arts stay loaded, so it also reads NO_CHANGE-like. The typical run was without the passives' effect firing at all because most passives have no engine stat.)

## UNMODELLED

- ward model change at each phase: the file holds one drain ward, the phase average; the engine models drain wards only.
- Phase script and 12 s clock: boss phases and telegraphs are not modelled by the engine.
- Soul ward and Deaf Verdict: soul ward payloads are not modelled and the build has no soul art.
- Per-hit ward payload of the Iron Gate: only drain is modelled.
- Purge bell as a timed full strip: no library art or engine action does a timed full strip.
- Open Hand phase (no ward, doubled offence): needs the phase script.
- mountain-heart-canon body_shield_pct +8, stack_effect_pct +10 [tho], stack_duration_pct +15 [tho]; iron-hide-manual stack_duration_pct +4 [kim]; mountain-bone-body-art body_shield_pct +4: no engine stat, not run.

## Observations

Against the 30-60 s band the fights are far short: 1.9 s against the typical foe and 4.7 s against a top-end foe at the same realm, with full health left and no dry on our side. The result comes from the layers on the caps and the basic attack; the library arts barely run. Against the typical foe all seven arts are NEVER_FIRED; against the top-end foe mountain-stance (1.0), bone-turning-palm (1.0), sinking-weight, iron-hide-stance and mountain-root-stance (0.3 each) fire, while bastion-reprisal and strata-hammer are NEVER_FIRED. Both `--without` tests are NO_CHANGE, so the engine of this build (Strata, shield-break bursts) does not engage in a fight this short, and the main-technique passives that do run are absent in the result. The guide's claims: "beats a typical Hóa Thần foe 20 of 20 in under 2 s" holds (1.9 s); "a top-end player wins 16 of 20 in about 22 s" does not (20 of 20 in 4.7 s), but that figure was the Warden defending, not this file's matchup, and the phase-based defence it rests on is unmodelled, so the "wall" claims are not assessed. No tuning was done.

# Giant Killer (Sơn Hạ Châm, The Needle Under the Mountain), engine v2 rebuild

A Metal–Earth Kết Đan that tempers Metal arts and sunders resistance to punch one realm up; ordinary against equals.

## Assumed numbers (no old fight file existed)

Taken from the guide and `giant-killer.sheet.md` (defining realm Core Formation, `ket_dan`). Also in `_comment` of the fight file.

- `layers` [200, 225, 250, 130, 100]: L1 +200 (knee), L2 +225 (the sheet's Huyền total), L3 250 (cap, the top-end anchor), L4 +130 (Nine Rods + Hand Bath, foreseen), L5 +100 (Against the Heavens). Applied at every gap, because the engine has no realm-gap readable. The gap-0 row therefore overstates.
- crit 0.5 chance, ×2.0; art speed +50; art cost −20 %; regen +6 pp; accuracy +10; purity metal 80, earth 80.
- Ward and body: the realm's typical Common Ward and body (the Golden Bell and Soul-Guarding Lamp are not drain wards). Keystones none, curses none. Only one fight file, as the old build had none.

## Pieces

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Threaded Needle (Metal debuffs) | flying-blade-retinue (blades lay Metal debuff stacks) | hundred-blades-canon (3) |
| Through the Mountain (heavy hit) | shatter-edge-cleave (heavy, 4× on 6 Metal debuffs) | nine-temper-scripture (6) |
| Pestle Grind | sheathed-edge (banked crit strikes) | nine-temper-scripture (4) |
| Last Stitch / the finisher | sundering-wedge (Sundered, resistance −150 a stack) | hundred-blades-canon (6) |
| Art speed / crit tempo | whetstone-pass (Temper → Metal crit) | nine-temper-scripture (1) |
| Bearing the Mountain, Earth stacks (defence) | iron-hide-manual passives (resist +100 [physical], block +9); its stance art is not slotted | iron-hide-manual (3, not slotted) |
| Sweeper's Exit | none (escape not modelled) | — |

Five arts in five slots (`ket_dan` 5, no bonus).

## Techniques chosen and why

- **Main: `nine-temper-scripture`** (kim). The Metal tempering suite: Temper rises with each Metal art and feeds crit, and its heavy cleave pays out on Metal debuff stacks, which is the old Threaded Needle → Through the Mountain loop.
- **Aux: `hundred-blades-canon`** (kim secret). Its blades lay the Metal debuff stacks the cleave breaks, and Sundered thins the foe's resistance, the nearest library answer to the pierce job.
- **Aux: `iron-hide-manual`** (kim secret). Only for its physical-resistance passive in place of Bearing the Mountain; no art from it is slotted.

## Lost in the move

- Half a Realm (the identity piece), Stiff Neck, Through the Ceiling, Mountain Notches, Needle's Eye, Realm-Piercing affix: no library equivalent, not in the game. The "half a realm gap" is not in the rebuild at all.
- Against the Heavens: kept only as a flat L5 +100, since there is no realm-gap readable.
- Realm pierce and Physical penetration: no engine field.
- Golden Bell, Soul-Guarding Lamp, Clear Heart Ward: modelled as the typical Common Ward.
- Sweeper's Exit and Beneath Notice (escape is not modelled), Ore Weight, Cold Iron Order, the Forty-Year Needle's bonuses, Earth buff stacks from Bearing the Mountain (nearest library art, packed-earth-stance, is a common art and needs a generated common technique).
- Technique passives with no engine stat: stack_duration_pct (3 techniques), status_duration_pct [curse]; art_speed [kim] applies to every art.

## Matchups (`--matrix`, 20 seeds)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical, same realm (ket_dan+0) | 1.0 | 20-0-0 | never | 1.0 | trig_budget 0.6 |
| typical, nguyen_anh+1 | 2.0 | 20-0-0 | never | 2.0 | trig_budget 0.5 |
| typical, hoa_than+2 | 3.9 | 0-12-8 | 2.8 | never | trig_budget 0.2 |
| top_end, ket_dan+0 | 1.6 | 0-20-0 | 1.6 | never | none |
| top_end, nguyen_anh+1 | 1.0 | 0-20-0 | 1.0 | never | none |
| top_end, hoa_than+2 | 1.0 | 0-20-0 | 1.0 | never | none |

## --without tests (typical, same realm, ket_dan+0)

| Removed | Before | After |
|---|---|---|
| `tech:nine-temper-scripture` | 1.0 s, 20-0-0 | 1.0 s, 20-0-0 |
| `whet-temper-edge` (Temper → crit, the identity effect) | 1.0 s, 20-0-0 | 1.0 s, 20-0-0 |

(One realm up, typical, both are 2.0 s, 20-0-0 as well. At hoa_than+2 typical, losses go 12 → 14 without the technique, 12 → 15 without whet-temper-edge. `--without whetstone-pass` is not an effect id and changed nothing.)

## UNMODELLED

- Half a Realm: no library art or technique does it and the engine has no fight-unit shift.
- Against the Heavens: L5 +100 only upward; no realm-gap readable, so L5 100 at every gap.
- Stiff Neck, Through the Ceiling, Mountain Notches, Needle's Eye, Realm-Piercing affix: not in the game, no library equivalent.
- Realm pierce and Physical penetration: no engine field.
- Golden Bell, Soul-Guarding Lamp, Clear Heart Ward: per-hit and soul wards run as the typical Common Ward.
- nine-temper-scripture art_speed [kim]: the engine reads art_speed without hit context, so it applies to every art; hundred-blades-canon art_speed [kim] likewise.
- stack_duration_pct (nine-temper, hundred-blades, iron-hide), status_duration_pct [curse] (hundred-blades): no engine stat.

## Observations

Same-realm fights last 1.0 s against a typical foe, 2.0 s one realm up and 3.9 s two up, against the 30–60 s band: far under it, and the top-end rows end in 1–1.6 s the other way (all losses). That follows from the assumed layers (the sheet's top-end-anchor M with L5 on at every gap) set against the engine's fitted typical foe; no number was tuned. The guide's claims do not hold in this run: the rebuilt stack has no Half a Realm, so no upward edge appears (a typical foe two realms up beats it 12-0 or draws, a top-end foe beats it at every gap, and the "weak against equals" cost is absent because L5 is always on). The identity tests show nothing at the typical same realm and one up, since fights end before the engine arts matter, and a small effect only at +2 (12 → 14 and 12 → 15 losses of 20). NEVER_FIRED: shatter-edge-cleave and flying-blade-retinue in every matchup; sundering-wedge except typical hoa_than+2 (0.4 per fight); sheathed-edge in about half the rows (0.0–1.4 per fight). The rebuilt suites are Metal engines, but the fights end before their stacks build.

LIB-DONE design/builds/engine-v2/giant-killer.md

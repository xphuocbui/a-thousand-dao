# The Armoury Mind (Tàng Binh Thức) on engine v2

Hang seven treasures on one mind: gear fills the layer, and the weapon count strikes, walls and counts. Defining realm: Nascent Soul (nguyen_anh).

**Read first:** the Glob for `armoury-mind*.fight.json` under `design/builds/overnight-2026-11-10/builds/` found NO old fight files, so there was no old file to copy layers, crit, ward, body or keystones from. They were derived from the guide's arithmetic (layers ×3.66/×3.65/×3.5/×2.3 → 266/265/250/130; L5 comes from the Effects; ward +83/+83; purity metal 95). Crit, body, keystones and curses are left at the engine defaults (the guide names none). Only one realm file was written, since no other realm had an old file.

## Old piece → library piece

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Rack-Wide Volley (the big blow) | `shatter-edge-cleave` (heavy Physical cleave, breaks Metal debuff stacks) | nine-temper-scripture (6) |
| Hook and Chain (lays Sundered) | `sundering-wedge` | hundred-blades-canon (6) |
| Called Blade (a striking blade) | `flying-blade-retinue` (blades that strike and lay Metal debuff stacks) | hundred-blades-canon (3) |
| Peg-Line Cut (Metal buffs on you) | `blood-quench-blade` (5 Metal buff stacks on you; pays health) | nine-temper-scripture (2) |
| (new: crit engine for the rack) | `whetstone-pass`, `sheathed-edge` | nine-temper-scripture (1), (4) |
| Re-Temper (heal) | none | lost |
| Shut the Armoury Door (soul cleanse) | none | lost |
| Pass-Garrison Armoury Scripture | `nine-temper-scripture` (main), `hundred-blades-canon`, `iron-hide-manual` (aux, passives only: Physical resist, block) | – |
| Garrison Mind, Full Rack, Humming Shields, Opened Seams, Steady Breath, Iron Skin Renewed | kept as Effects (not arts) | – |

## Techniques chosen and why

- **nine-temper-scripture** (main, Metal): the only Metal main with arts on both the Physical-blade side (cleave, sheathed edge) and a Metal-buff-on-you art. Its cleave breaks Metal debuff stacks, which is exactly what Garrison Mind lays.
- **hundred-blades-canon** (secret, Metal): blades and Sundered, the closest suite to "weapons you control strike and lay Metal stacks". Needle-rain was dropped; six slots hold six arts.
- **iron-hide-manual** (secret, Metal): taken for its passives only (+100 Physical resist, +9 block) as armour-and-walls flavour. Its art (iron-hide-stance) is not slotted. This is a thin choice and could be dropped.

## What was lost in the move

- Re-Temper (heal) and Shut the Armoury Door (soul-curse cleanse): no library equivalent in the Metal suites; no slot left either.
- Peg-Line Cut: a library common art exists but needs a generated common technique; I used `blood-quench-blade` (also pays health) instead.
- Edge Past the Rack (L3 surplus → penetration), the Thinned Mind close, and per-piece counts (written as fixed 4 weapons / +40 / 2 ward pieces): see UNMODELLED.
- Garrison Mind's strike size (0.1 per weapon) and Humming Shields (0.6 %/pulse) are my own values; the guide says only "a small free hit".

## Matchups (typical enemy and top-end, defining realm and one above)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical nguyen_anh+0 | 1.4 | 20-0-0 | never | 1.4 | trig_budget 4.0 |
| typical hoa_than+1 | 3.0 | 20-0-0 | never | 2.9 | trig_budget 11.8 |
| top_end nguyen_anh+0 | 1.5 | 0-20-0 | 1.5 | never | – |
| top_end hoa_than+1 | 1.0 | 0-20-0 | 1.0 | never | – |

## --without tests (typical, nguyen_anh+0)

- `--without tech:nine-temper-scripture` (passives only; its arts stay): before 1.4 s, 20-0, health left 99 % → after 1.4 s, 20-0, 99 %. No change.
- `--without garrison-mind` (the identity piece): before 1.4 s, 20-0, health 99 %, clipped trig_budget 4.0 → after 1.9 s, 20-0, health 98 %, clipped 0.1. About a third slower; the effect is real. At hoa_than+1 typical: 3.0 s → 3.5 s, health 84 % → 74 %.

## UNMODELLED

- Edge Past the Rack: needs a layer-total readable and a penetration mod key.
- Thinned Mind close: no engine action to thin soul defence.
- Steady Breath: scope is Metal arts in the guide, here it lifts L5 for every hit.
- Piece-count reads: Effects cannot read the pieces owned, so counts are fixed.
- Gear/ward/body numbers: derived from the guide, not an old fight file (none existed).
- technique passives with no engine stat or scope: nine-temper stack_duration +4 [kim], hundred-blades stack_duration +10 [kim] and status_duration +15 [curse], iron-hide-manual stack_duration +4 [kim] (not run); art_speed_pct [kim] on both techniques applies to every art (engine reads it without hit context).

## Observations

At the defining realm the typical fight lasts 1.4 s, far under the 30–60 s band (3.0 s one realm up); the top-end enemy kills the build in about 1.5 s, so the build neither survives nor lasts. The guide's claim that Garrison Mind matters holds in direction (a third slower without it), but the guide's claim of a sustained, wall-backed fight does not show: the foe dies before any wall matters. Four of six arts are NEVER_FIRED at typical nguyen_anh+0 (shatter-edge-cleave, sundering-wedge, flying-blade-retinue, sheathed-edge, blood-quench-blade: five in fact; only whetstone-pass fires, 0.8 per fight), and the same set is NEVER_FIRED against the top-end enemy. Removing the main technique's passives changes nothing, so the arts, not the passives, carry nothing here either; the result is driven by the layers and Garrison Mind alone. These layers come from guide arithmetic and may be too high versus the fitted enemy; I did not tune them.

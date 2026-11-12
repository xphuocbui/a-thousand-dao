# The Quiet Vine (Tĩnh Đằng Độc Kinh), geared

Lay poison in thorn batches, keep yourself topped up with Wood healing, and let the enemy lose the race you refuse to run. Realm: Foundation Establishment (Trúc Cơ, `truc_co`).

Fight file: `builds/starter-venom.fight.json`. It is the engine-v2 file plus seven items, the hatchet's art swapped in for `harvest-bloom`, and one written Effect (`eff:Sap Rises`). Nothing else is changed; no number is tuned.

## Loadout

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Heartwood Hatchet (Tâm Mộc Phủ) `wood-heartwood-hatchet` | 2 | Its art Fell the Rotting Tree counts as a Rotting Canopy Canon art, lays 2 Poison and cashes a Poison pile into a heavy Chaos-tinged hit. It takes the `harvest-bloom` slot. Its modifiers add Wood attack. |
| Armour | Ironbark Cuirass (Thiết Bì Giáp) `wood-ironbark-cuirass` | 2 | Health regeneration and healing taken for a build whose defence is its own healing. |
| Ring 1 | Ring of the Slow Garden (Hoãn Viên Giới) `wood-slow-garden-ring` | 3 | The poison ring: longer, stronger debuff stacks, Spillover. |
| Ring 2 | Sprout Ring (Mầm Nha Giới) `wood-sprout-ring` | 1 | Health regeneration and a stronger Wood buff. |
| Necklace | Sap-Heart Pendant (Dịch Tâm Bội) `wood-sap-heart-pendant` | 2 | Healing, Wood buff, regeneration and a reserve art (Verdant Aura). |
| Extra 1 | Verdant Cycle Seal (Thanh Hoàn Ấn) `wood-cycle-seal` | 3 | Wood attack and art speed; a fifth Verdant Cycle Scripture art that has no art slot to sit in. TT 30. |
| Extra 2 | Heartwood Bulwark (Tâm Mộc Thuẫn) `wood-heartwood-bulwark` | 3 | Carries the Effect Sap Rises (healing from Wood buff stacks), plus regeneration and a shield. TT 15. |
| Extra 3 | empty | | Nothing fitted under the limit. |

Thần thức: 30 + 15 = **45 against a limit of 45** (45 × divine_sense 1.0 × (1 + 0 % than_thuc)). The third extra stays empty. Grades are all at most 3.

## Before and after

Old file run on the current engine; the engine-v2 guide's 30.9 s was measured before the engine changed, so the old column is the fresh run, not that table. 20 fights each.

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical, truc_co (same realm) | 36.8 | 27.0 | 20-0-0 | 20-0-0 |
| typical, ket_dan (+1) | 8.5 | 8.7 | 0-20-0 | 0-20-0 |
| typical, nguyen_anh (+2) | 4.0 | 4.0 | 0-20-0 | 0-20-0 |
| top_end, truc_co | 1.6 | 1.6 | 0-20-0 | 0-20-0 |
| top_end, ket_dan | 1.0 | 1.0 | 0-20-0 | 0-20-0 |
| top_end, nguyen_anh | 1.0 | 1.0 | 0-20-0 | 0-20-0 |

Same-realm typical: foe dry 24.4 s old, 19.9 s geared; the build never ran dry in either; health left 100 % in both.

`--without` (typical, same realm):

| Removed | Mean s | W-L-other | Foe dry s |
|---|---|---|---|
| nothing (geared) | 27.0 | 20-0-0 | 19.9 |
| `item:wood-heartwood-hatchet` (modifiers only; its art stays in the slot) | 30.2 | 20-0-0 | 21.4 |
| `item:wood-cycle-seal` | 30.4 | 20-0-0 | 21.7 |
| `eff:Sap Rises` | 27.0 | 20-0-0 | 19.9 |

The most important item is the Heartwood Hatchet and the Verdant Cycle Seal about equally (about 3.2 s and 3.4 s each). Both do it through Wood attack and art speed, the only gear stats the engine runs.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | Fell the Rotting Tree (art) | a heavy poison-eating hit | `wood-heartwood-hatchet`, events, craft, NPC | in the catalogue (worn) | have |
| Ring | Spillover | foe linh lực drain on ticks (not run) | `wood-slow-garden-ring`, event, NPC | in the catalogue (worn) | have |
| Weapon (other) | Seal of the Turning Season (art) | a Wood seal that heals with 3 Seeds | `wood-cycle-seal` | in the catalogue (worn as an extra, art unslotted) | medium: needs an art slot |
| Armour | Grave-Silk Shroud, ward | a unique poison robe | `wood-grave-silk-robe`, grade 4 | in the catalogue; needs Kết Đan | high, later realm |
| Extra | Gripping Root | delays the foe's next art | `wood-thousand-roots-banner`, grade 4 | in the catalogue; needs Kết Đan | medium, later realm |
| Ring | Poison damage over time / stack count | see Missing pieces | | missing | high |

## Missing pieces

- A Wood or Chaos ring that adds Poison stacks laid per art, not duration only (Wood family).
- A necklace that turns Poison ticks into healing or linh lực for the wearer, the keystone leech the guide lists (Wood family).
- A light armour for the Wood poisoner with a cleanse-immunity window (Wood family; the guide's Moss-Ledger).
- A grade 3 Wood treasure of at most 15 thần thức, so that Cycle Seal and Bulwark are not forced to fill the limit (Wood family).

## UNMODELLED

- Spillover (Ring of the Slow Garden): the engine has no action I could confirm for draining the foe's linh lực on each tick; its rule text was not in the files read.
- Ironbark Shell (cuirass) and Heartwood Ward (bulwark): a cast Physical shell and a cast shield, not a drain ward that beats the build's Common Ward.
- Verdant Aura (Sap-Heart Pendant reserve art): 12 % reserve not deducted, grants not run.
- Verdant Cycle Seal's art: no art slot left; only its modifiers run.
- Item modifiers with no engine stat (stack effect and duration on Wood, health regeneration, healing taken, khí huyết, defence, linh lực): not run. Only the attack and art-speed lines reached the fight.
- Everything the old file already listed (Root Drinks the Rot, Patient Venom, Moss-Ledger, Sap Rises beyond the table, Spillover as an upgrade, wood purity).

## Observations

Gear shortened the same-realm typical fight from 36.8 s to 27.0 s, so the fight now sits just under the 30-60 s band; the build still wins 20 of 20 at full health, and nothing changed against stronger foes, which still win in under 9 s. Most of the gear gain comes from two items' Wood attack and art speed, because those are the only item stats the engine reads: the cuirass, both regeneration lines, the pendant, the bulwark's defence and the Wood stack lines did nothing in the fight. The written Effect Sap Rises fired nothing that shows, as healing cannot matter in a fight the build ends at 100 % health. All four arts fire, including the hatchet's art (6.5 per fight). Nothing became degenerate, but the build was never in danger, so the sustain gear has no test yet; it would need a harder foe, which only top-end or +1 realm gives, and those are not winnable by gear at this grade. The Spillover and ward claims remain untested.

GEAR-DONE starter-venom

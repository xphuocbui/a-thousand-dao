# The Hollow Thief (Hư Thủ Thâu Pháp), geared

Leave the foe's strength to your own echoes: a hollow tide of linh lực-burning palms, re-fired by echo arts on your own multiplier, now with a Hollow-Tide zither and two Echo treasures. Realm: Nguyên Anh (nguyen_anh).

Fight file: `builds/art-thief.fight.json`. A copy of the engine-v2 file with `"items"`, one art swapped (Twin Shadow Fist → Resonant Shockwave) and one engine Effect (`eff:Echo`). No number was tuned; the ward stays the build's own (payload 342.5 beats the robe's Hollow Veil at 264).

## Loadout

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Shock-Wave Zither (Chấn Ba Cầm) `force-chaos-shock-zither` | 1 | Its art Resonant Shockwave counts as a Hollow Tide Scripture art and feeds Drink; slotted in place of Twin Shadow Fist, which never fired |
| Armour | Hollow Robe (Không Y) `force-chaos-hollow-robe` | 2 | Force-family armour; +6 % thần thức widens the extra budget; its ward is weaker than the build's, so not used |
| Ring | Echoing Ring (Hồi Âm Giới) `soul-song-seal-echoing-ring` | 3 | Carries Echo, the free-hit Effect the echo engine wants |
| Ring | Hollow Ring (Không Giới) `force-chaos-hollow-ring` | 1 | Debuff stack strength and status duration for Qi Disruption (no engine stat reads either) |
| Necklace | Ledger-Murmur Pendant (Phế Thanh Bội) `force-chaos-ledger-murmur-pendant` | 2 | Debuff stacks, healing, linh lực regeneration; reserve art not run |
| Extra | Echo-Skin Drum (Hưởng Bì Cổ) `body-echo-skin-drum` | 3 | Physical art speed, crit and crit damage for the palms; its Echo is not stacked with the ring's. TT 20 |
| Extra | Twin-Edge Flying Sword (Song Nhận Phi Kiếm) `blade-twin-edge-sword` | 2 | Sword crit, speed and attack for the Afterimage Sword Canon's Phantom Sword. TT 20 |

Thần thức: 20 + 20 = **40** against a limit of 45 × 1.0 × (1 + 10 / 100) = 49.5 (the build's own divine_sense is absent; robe +6 % and ring +4 % than_thuc counted; 45 if neither counts, still above 40). Two extra slots left empty.

## Before and after

Twenty fights each, one `--matrix` run per file.

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical, nguyen_anh+0 | 3.0 | 6.0 | 20-0-0 | 20-0-0 |
| typical, hoa_than+1 | 3.7 | 20.2 | 20-0-0 | 20-0-0 |
| top_end, nguyen_anh+0 | 8.9 | 37.9 | 19-1-0 | 9-10-1 |
| top_end, hoa_than+1 | 4.7 | 5.9 | 0-20-0 | 0-20-0 |

("Old" is the earlier engine-v2 rerun; "geared" is this file with the budgeted `layers`, rerun 2026-11-13. Before the budget revision the geared file read 1.9 / 3.6 / 5.2 / 8.7 s on today's engine.)

`--without` tests (geared file, `--matrix`):

| Test | typical n+0 | typical h+1 | top_end n+0 | top_end h+1 |
|---|---|---|---|---|
| geared, full | 6.0 s, 20-0-0 | 20.2 s, 20-0-0 | 37.9 s, 9-10-1 | 5.9 s, 0-20-0 |
| `--without item:force-chaos-shock-zither` | 6.0 s, 20-0-0 | 20.2 s, 20-0-0 | 37.9 s, 9-10-1 | 5.9 s, 0-20-0 |
| `--without eff:Echo` | 6.2 s, 20-0-0 | 20.7 s, 20-0-0 | 34.4 s, 9-11-0 | 6.0 s, 0-20-0 |

The zither test removes only the item's modifiers (the swapped-in art stays); it changed nothing. Removing Echo changes the fights only slightly (it fires about 5 free hits a typical fight, 28 at top_end).

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | Art that copies the foe's last art | The build's identity: theft | Force-chaos family | Missing | High |
| Ring | Echo, second copy that stacks (or a stronger Echo) | More free hits per art | Item, event or craft | Catalogue has Echo on 5 items; stacking not defined | High |
| Necklace | Force `attack_pct` scoped to force | Scales the scripture's burn and palms | Force-chaos family | Missing (the pendant carries Chaos) | Medium |
| Armour | Ward above 342.5 payload with linh lực regeneration | Keeps the sustain while the echoes run | Force-chaos or body | Missing (the robe's ward is weaker) | Medium |
| Extra | Palm-scoped art speed or Drink | Fires Marrow-Siphon Palm and Hollowing Strike, which never fired in the typical fight | Body family | Missing | Medium |
| Any | Mod-engine stat for status_duration_pct and stack_effect_pct | Lets three owned pieces count | Engine | Not an item | Low |

## Missing pieces

- A foe-art-copying weapon or ring (steal and fire the foe's last art at 60 %): force-chaos.
- A Force-scoped necklace or ring with `attack_pct`, not only Chaos: force-chaos.
- A palm-scoped treasure that adds Drink or counts toward Answering Palm's third palm: body.
- A heavier armour whose ward beats a Common Ward at ws 62.5: force-chaos.

## UNMODELLED

- THEFT ITSELF (loan slots, `stolen` tag, copying the foe's arts, Pre-Read, Hollow Guard, Spent Hand): no library art or item copies a foe's art and the engine has no event for it.
- A bare-fist enemy gives nothing to copy: not run, since the matrix enemy always has arts.
- Echo (Echoing Ring, Echo-Skin Drum): written once as `eff:Echo`; the engine's free hit cannot carry the art's tags, and a second Echo from the other item is not stacked, since the rules do not say whether it would be.
- Opening Cut (Twin-Edge Flying Sword): not relied on, not written.
- Hollow Veil ward (Hollow Robe): weaker than the build's ward, so the old ward stays.
- Reserve art Murmuring Debts (Ledger-Murmur Pendant): the 10 % reserve is not deducted and the grants do not run.
- Item passives with no engine stat: `khi_huyet_pct`, `than_thuc_pct`, `defense_pct`, `status_resist_pct`, `status_duration_pct`, `stack_effect_pct` (debuff), `linh_luc_on_crit_pct`; the scoped `art_speed_pct` (force, soul, physical, sword) apply to every art, as the engine cannot scope them.
- Technique passives as in the engine-v2 guide (status_duration_pct, scoped cost and speed).

## Observations

With the budgeted layers the typical Nguyên Anh foe dies in 6.0 s (still faster than the 10-20 s budget target), the Hóa Thần +1 typical foe in 20.2 s, and the top-end Nguyên Anh foe is a coin flip (9-10-1, 37.9 s). Against the Hóa Thần top-end foe the build still loses every fight (5.9 s). Every art now fires in the typical Nguyên Anh fight (Marrow-Siphon Palm 1.9, Hollowing Strike 1.1 a fight). Echo is worth little by the `--without` test, and the zither's modifiers change nothing. The Echo-Skin Drum, Twin-Edge Sword, Hollow Ring and the pendant have mostly modifiers the engine cannot read. These are observations from one 20-fight matrix each, not a verdict.

## Budget revision (2026-11-13)

- **What changed:** `layers` went from `[400, 200, 240, 150, 0]` (84 % of the typical-to-top-end gap; the Nguyên Anh budget is 23 %) to `[370, 40, 40, 20, 0]` (22 %). L2-L4 now sit at the typical enemy's values; L1 was trimmed from 400 to 370; L5 was already 0. No technique, item or art was changed.
- **Why:** the techniques' passives and items' modifiers already run as Effects, so claiming L2-L4 as well double-counted them. The concept (echoing palms and sword on the build's own multiplier) lives in L1 and the Effects, so L1 stayed and the other layers were cut first.
- **How the fights moved** (mean time, wins; before -> after, same engine, today): typical nguyen_anh+0 1.9 s 20-0 -> 6.0 s 20-0; typical hoa_than+1 3.6 s 20-0 -> 20.2 s 20-0; top_end nguyen_anh+0 5.2 s 20-0 -> 37.9 s 9-10-1; top_end hoa_than+1 8.7 s 3-17 -> 5.9 s 0-20.

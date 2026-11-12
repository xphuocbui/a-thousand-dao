# The Brimming Tide (Mãn Triều), geared

A Water cultivator who keeps the linh lực pool full and is paid for it, now carrying named Water items. Realm: Foundation Establishment (Trúc Cơ, `truc_co`).

Fight file: `design/builds/engine-v3/builds/starter-tide.fight.json` (copy of the engine-v2 file plus `items`, one item art swapped in, two engine Effects, and the ward set to the armour's ward).

## Loadout

Grade cap at this realm is 3; every piece is grade 3 or lower. Divine sense is 1.0 (absent in the file).

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon (base) | Drowned Anchor (Trầm Hải Mao), `water-drowned-anchor` | 3 | Its art counts as a Still Moon Tide Scripture art and adds a Tide source; Water attack, art speed and stack effect modifiers. Its art takes the slot of Swelling Tide Palm. |
| Armour (base) | Hundred-Patch Armour (Bách Nạp Giáp), `general-hundred-patch-armour` | 3 | The only armour that fits an outlasting build (the water family has none): a Common Ward at 1.2 times, health regeneration, 3 % thần thức. Modelled as the drain ward. |
| Ring (base) | Ring of the Returning Tide (Hồi Triều Giới), `water-returning-tide-ring` | 3 | Healing and regeneration modifiers, and the Backflow Effect (healing refills the pool). |
| Ring (base) | Dewdrop Ring (Lộ Châu Giới), `water-dewdrop-ring` | 1 | A cheap pool and breathing ring; the other water ring is grade 3 and already worn. |
| Necklace (base) | Moon-Well Pendant (Tỉnh Nguyệt Bội), `water-moon-well-pendant` | 2 | Healing, regeneration, stack effect, +5 % thần thức (which raises the extra-slot limit); reserve art Still Surface. |
| Extra 1 | Brimming Shield (Mãn Thuẫn), `water-brimming-shield` | 3 | Steady Breath and a pool-and-regeneration modifier set; thần thức 15. |
| Extra 2 | Still-Pool Gourd (Tĩnh Trì Hồ Lô), `water-still-pool-gourd` | 2 | Steady Breath and regeneration; thần thức 25. |
| Extra 3 | empty | | Tide Bell (25) would bring the total to 65, over the limit. |

Thần thức: 15 + 25 = **40** against a limit of 45 × 1.0 × (1 + 8 / 100) = **48.6** (than_thuc_pct 5 from the pendant, 3 from the armour).

Gourd art `water-gourd-pours-the-pool` is not slotted: four art slots stay as before and the anchor art took the palm's slot, so the gourd is carried for its modifiers and Steady Breath only.

## Before and after

Matrix of 20 seeds per row, from `--matrix`. Rows labelled by the engine as truc_co+0, ket_dan+1 (one realm up) and nguyen_anh+2 (two realms up). The old file now reads 37.0 s at the same realm, not the 30.7 s in the engine-v2 guide (the engine has moved since).

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical, same realm | 37.0 | 29.4 | 20-0-0 | 20-0-0 |
| typical, +1 realm | 18.6 | 57.3 | 0-20-0 | 2-13-5 |
| typical, +2 realms | 4.2 | 4.7 | 0-20-0 | 0-20-0 |
| top_end, same realm | 2.0 | 2.0 | 0-20-0 | 0-20-0 |
| top_end, +1 | 1.0 | 1.0 | 0-20-0 | 0-20-0 |
| top_end, +2 | 1.0 | 1.0 | 0-20-0 | 0-20-0 |

Foe runs dry (typical, same realm): old 24.0 s, geared 19.7 s. The player never runs dry and keeps 100 % health in both.

### `--without` (typical, same realm, geared 29.4 s, 20 wins)

| Removed | Mean s | Wins | Foe dry |
|---|---|---|---|
| `item:water-drowned-anchor` (its modifiers; the art stays slotted) | 34.5 | 20 | 23.1 s |
| `eff:Steady Breath` | 32.5 | 20 | 20.8 s |
| `eff:Backflow` | 29.4 | 20 | 19.7 s |
| `item:water-returning-tide-ring` | 29.4 | 20 | 19.7 s |
| `item:water-dewdrop-ring` | 29.4 | 20 | 19.7 s |

The anchor is the piece that matters most (about 5 s); Steady Breath is worth about 3 s.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Armour | `stack_effect_pct` [thuy, buff] and a ward | Water stack strength on the body piece | Craft, event | Missing: no water armour (the water family has no giáp or đạo bào) | High |
| Weapon | Mao or Ấn art that spends Tide | A second Tide payoff | Quest, npc | In the catalogue: `water-nine-fathom-seal` (grade 4, Kết Đan and above) | Medium |
| Extra | Reserved Layered Cloud shield | Standing shield, not modelled | Craft, quest | In the catalogue: `water-brimming-shield` (worn; the engine cannot run it) | Low |
| Necklace | `stack_duration_pct` [thuy, buff] | Longer Water stacks (the pendant reserve art grants it; engine has no stat) | Event | In the catalogue: `water-moon-well-pendant` (worn, not run) | Medium |
| Ring | Backflow with an amount cap | Pool refill from healing | Craft | In the catalogue: `water-returning-tide-ring` (worn) | Low |
| Any | `healing_pct` and `health_regen_inc_pct` that the engine reads | Healing feeding Brimming Cup | Craft | In the catalogue; regeneration is not an engine stat | Medium |

## Missing pieces

- A Water armour (giáp or đạo bào) with a Water-stack or pool ward: owned by the water family.
- A Water extra slot piece that turns a full pool into a Cup refill (a Cup-feeding utility): owned by the water family.
- A Water necklace with a non-reserve Effect (the water necklaces are all reserve or plain): owned by the water family.

## UNMODELLED

- Full-Sea ward bonus (ward drain falls while the pool is above 80 %): not an engine Effect.
- Tide-Bound Vessel and Still Pool Array: not engine pieces, folded into layers and ward numbers.
- Hundred-Patch Armour Effect Final Clause: the fight never takes the build Down at the same realm, so it was not written.
- Backflow cap (at most 3 % of maximum linh lực a pulse): `limit` counts firings, not amounts; run uncapped.
- Brimming Shield ward Layered Cloud (reserved shield): not a drain ward; the Hundred-Patch Ward stands as the drain ward.
- Moon-Well Pendant reserve art Still Surface (reserves 10 % linh lực; grants stack duration and effect): not run or deducted.
- Item modifiers the engine has no stat for: `linh_luc_pct`, `stack_effect_pct`, `khi_huyet_pct`, `defense_pct`, `healing_taken_pct`, `health_regen_inc_pct`, `ward_efficiency_pct`, `than_thuc_pct` (the loader prints each).
- Water-scoped `art_speed_pct` on the anchor and gourd: the engine applies it to every art.
- Technique passives still-moon-tide-scripture `health_regen_inc_pct` and `stack_duration_pct`: no engine stat.
- Steady Breath is modelled once as L5 +12 on Water arts while linh lực is at 50 % or above, although two items carry it.

## Observations

Gear mattered. At the same realm the geared fight is 29.4 s against 37.0 s, a little under the 30-60 s band; the old file was inside it, so gear pushed the fight just below the band's floor, with the foe dry at 19.7 s instead of 24.0 s. The clearest change is one realm up: from a certain loss at 18.6 s to 2 wins, 13 losses and 5 draws at 57.3 s, so the build now survives a stronger foe for about a minute; two realms up and every top_end foe still end the fight in under 5 s, so the glass ceiling is unchanged. Nothing degenerated: the player keeps 100 % health at the same realm and it is the same outlast shape as before. The anchor is the largest piece (the fight lengthens by 5 s without its modifiers) and Steady Breath is worth about 3 s. Backflow and the returning-tide ring and the dewdrop ring changed no measured fight at the same realm, so their payoff is not shown; the matrix's top_end rows fired none of the four arts, as before, and the anchor art lost 4.0 Tide gains per fight to the pulse limit at the same realm (11.3 at +1 realm). The armour's ward numbers (payload 411, drain 0.394) were set in the file as the nearest drain ward; they were not tested separately from the other pieces.

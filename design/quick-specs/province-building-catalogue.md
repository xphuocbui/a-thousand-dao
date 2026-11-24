# Province building catalogue (quick spec, 2026-11-24)

**Status:** drafted by Claude under the user's delegation ("only stop for major decisions", 2026-11-24). Every number is
a *(guess)* for the balance pass (Provinces OQ 1). Reviewed once with the rest at the end. Becomes
`assets/data/province_buildings.json` in provinces-runtime Stage 2.

**Sources:** Provinces rules 7–10 and F3–F6 (`design/gdd/provinces.md`); Travel & Map Formula J (the old works' prices);
Sects F2 (`free_level`), F9 (war strength); ADR-0008. User decisions it rests on (2026-11-24): one catalogue; no highest
level; tracks price levels (×2 per level above `free_level = ⌈T/2⌉`); prebuilt density is land, not a building.

## Shared rules

- **Cost of level L:** `cost_lt · growth^(L−1) · 2^max(0, L − free_level[track])` linh thạch, plus
  `materials · L` units of rarity ≥ `rarity_min`; build seasons `seasons · L` for permanent kinds, 1 + ⌊L/3⌋ for upkept.
- **Upkeep:** `upkeep · L` a season (upkept kinds only); unpaid follows Provinces' Unpaid → Ruined states.
- **Staff:** upkept kinds need `staff_lvl` (1.0) population units per level (F4); permanent kinds need none.
- **No highest level.** Effects that are chances use a divide-the-miss form (`1 − (1 − p)/(1 + k·L)`) so they rise
  without limit and never pass 1; everything else is linear in L.
- **Who benefits:** a cultivation building helps members of the province holder's sect, at the seat for anything done
  there (crafting, breakthrough) and everywhere for what the sect teaches (formation power, techniques). The player
  counts as a member when in that sect.
- **Hook status:** **live** = the value exists in code today and the building only adds a term; **new hook** = a small
  new term in existing code (named below); **waits** = the system that would read it is not built.

## Production (priced by Holdings)

| Kind | Kind | Effect per level | cost_lt / growth | Upkeep | Hook |
|---|---|---|---|---|---|
| Mine works (khai khoáng) | upkept | +10 % production on the province's mines (G_f); site growth step per level above 1 | 1,000 / 2.0 | 3 % of the site's base value | live (Formula H `G_f`, `MapWorks.production_gain`); site growth Stage 3 |
| Hunting lodge (săn thú quán) | upkept | as mine works, on beast lairs | 1,000 / 2.0 | 3 % of site base value | live; Stage 3 |
| Spirit fields (linh điền) | upkept | as mine works, on spirit veins and hot springs; herbs `out[b]` 60 base value; population capacity +3 % (F3) | 1,200 / 2.0 | 3 % of site base value, 10 on a province without a site | live (G_f); `out[b]` Stage 1 F4; capacity Stage 5 |
| Vein dressing (tu mạch) | permanent | +3 % production on every site of the province | 2,000 / 2.0, materials 1, rarity 2, seasons 1 | — | live (G_f) |

The old **workshop** is replaced by the craft halls below (its craft capacity had no reader).

## Logistics (priced by Trade)

| Kind | Kind | Effect per level | cost_lt / growth | Upkeep | Hook |
|---|---|---|---|---|---|
| Road | upkept | infrastructure +200 (F6) | 600 / 2.0 | 4 | waits (access, Stage 6) |
| Caravan post | upkept | infrastructure +400 | 1,500 / 2.0 | 10 | waits (Stage 6) |
| Landing (river or coast only) | upkept | infrastructure +500 | 2,000 / 2.0 | 12 | waits (Stage 6) |
| Storehouse | upkept | the province's stock held +20 %; spoilage × 1/(1 + 0.15 L) | 1,000 / 2.0 | 6 | waits (Trade Goods stock and spoilage per province, Stage 6) |

## Society

| Kind | Track | Effect per level | cost_lt / growth | Upkeep | Hook |
|---|---|---|---|---|---|
| Market hall | Trade | the province's shop stock counts × (1 + 0.25 L) (`Market.ensure_stock` `stock_*`); margin later | 1,500 / 2.0 | 8 | new hook (`market.gd` stock counts by the shop's province); margin waits on Market #20 |
| Granary | Holdings | population capacity +5 % (F3); famine cover +0.1 | 1,000 / 2.0 | 5 | waits (Stage 5) |
| Warding wall | Military | `def` +0.05 in its region's battles when the region holds the holder's seat (Sects F9; was 1.2 flat); raid and beast-tide losses × 1/(1 + 0.2 L) | 2,000 / 2.0 | 10 | new hook (Sects F9 `def`); raids wait on Stage 7 |

## Cultivation (priced by Institutions; at the province's seat)

| Kind | Kind | Effect per level | cost_lt / growth | Upkeep | Hook |
|---|---|---|---|---|---|
| Gathering array (đại tụ linh trận) | upkept | density +0.10 at the seat | 3,000 / 2.5, materials 1, rarity 3 | 125 | live (Formula B; NPCs via Formula H) |
| Spirit grove (linh lâm) | permanent | density +0.02 | 2,000 / 2.0, materials 1, rarity 2, seasons 1 | — | live |
| Qi channel (dẫn linh cừ) | permanent | +2 share points to one chosen element (one channel per element) | 2,000 / 2.0, materials 1 of that element | — | live (Formula B match) |
| Alchemy hall (đan phòng) | upkept | members brewing at the seat: `alchemy_success` +5 (divides the failure chance); the region's market pill success `ps` → `1 − (1 − ps)/(1 + 0.1 L)` | 2,500 / 2.2, materials 1, rarity 2 | 40 | new hook (sheet source "facility" at the seat; `craft_economy` `ps` per market) |
| Artifact forge (luyện khí phòng) | upkept | members refining at the seat: `refining_success` +3; the region's artifact `ps` as above | 2,500 / 2.2 | 40 | new hook (same two) |
| Talisman hall (phù lục đường) | upkept | members drawing at the seat: success +3 (a new sheet stat `talisman_success`, added to Talismans' formula); the region's talisman `ps` as above | 2,000 / 2.2 | 30 | new hook (talismans.gd has no sheet term today) |
| Formation hall (trận pháp đường) | upkept | every member: `formation_power_pct` +3 (the sect teaches formations) | 2,500 / 2.2 | 40 | new hook (sheet source "sect" for members; formations and diagrams already read it) |
| Scripture pavilion (tàng kinh các) | permanent | members' technique tier roll +0.15 at generation and intake (`build_generator` tier); the sect store's manual tier later | 4,000 / 2.5, materials 2, rarity 3, seasons 2 | — | new hook (NPC tier roll); store waits on Sects F14 |
| Meditation chamber (tĩnh thất) | upkept | members at the bottleneck: breakthrough step +0.01 (`npc_step_chance`, inside the gate's own base–max band); the player's breakthrough at the seat the same | 3,000 / 2.5, materials 1, rarity 3 | 60 | new hook (`ProgressionEdges.npc_step_chance`, player check owed) |
| Recruitment hall (chiêu sinh điện) | upkept | the sect's intake weight × (1 + 0.1 L) (Sects F17 `rec_k`) | 1,500 / 2.0 | 15 | new hook (`SectEconomy.intake`) |

**Great projects** stay in `design/world/great_projects_proposal.md`: the famous, unique, staged versions (a named Tàng
Kinh Các, Đan Lô, Tĩnh Thất or grand array), one slot, each stage priced by Institutions, with effects beyond what the
ordinary hall's levels give. Ordinary halls are what any sect builds (decided 2026-11-24 under delegation).

## Starting buildings (rule 10) with these kinds

Unchanged from rule 10's table. Its "gathering array" entries start at level 1. No sect starts with a craft hall,
pavilion, chamber or recruitment hall: sects build them by expected return (Stage 4).

## Open

- The `ps` divide form and the member bonuses are guesses; the Stage 4 sim measures whether sects build halls at all
  (`SectWorks._value` needs a value for each new kind: members × bonus × a per-kind weight).
- The meditation chamber's step bonus sits inside the gate's base–max band (Realms' structure, not a building cap); if
  the user wants it uncapped too, the band is Realms' rule to change.
- Market hall margin and storehouse wait on Market #20 and Trade Goods stock per province.

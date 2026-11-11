# Staging: sect-ladder

## Modifiers

| ID | Name (Hán-Việt) | Stat and size | Form | Channel | Layer | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|---|---|---|
| deep-heat | Deep Heat (Nhiệt Thâm) | +0.4 % more Burn tick damage per Burn stack on the target, up to 20 stacks (+8 %) | Per | tick | L2 | Needs key (a Per stat on tick damage scoped burn, with a stack cap) | Công pháp bonus, cluster notable | sect-ladder | second home: any Burn build (Wildfire Wood-Fire). First guess; not run in the fight |

## Công pháp

| ID | Name (Hán-Việt) | Kind and tier | What it gives | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| red-hearth-canon | Red Hearth True Canon (Xích Lô Chân Kinh) | main, Huyền | linh_luc_regen_pct 0.6, damage_over_time_pct 8; abilities Kindle Palm (L1), Red Lotus Ring (L3), Cinder Lance (L7), Hearth Banner (L9) | Needs key (abilities empty today; DoT key is a catalogue row) | sect-ladder | bonus budget NOT ASSESSED (keys not in bonus_pool) |

## Arts

| ID | Name (Hán-Việt) | Source | Kind, tags | c_art / cost / cooldown | Rule | Fit | Used by |
|---|---|---|---|---|---|---|---|
| kindle-palm | Kindle Palm (Dẫn Hỏa Chưởng) | Primer / Canon L1 | qi, fire, palm, burn | 1.4 / 0.02 / 2 s | Fire hit, 2 Burn stacks for 8 s. Near-duplicate of staged spark-palm (starter-flame): merge if their numbers agree | Needs key (art record) | sect-ladder |
| red-lotus-ring | Red Lotus Ring (Xích Liên Ấn) | Canon L3 | qi, fire, seal, burn | 2.9 / 0.04 / 5 s | Fire hit, 3 Burn stacks 10 s, 2 Fire buff stacks 12 s on the caster | Needs key (art record) | sect-ladder |
| cinder-lance | Cinder Lance (Tẫn Hỏa Thương) | Canon L7 | qi, fire, burn | 3.4 / 0.05 / 7 s | Fire hit, 4 Burn stacks for 10 s. Near-duplicate of staged flame-lance (starter-flame): merge if numbers agree | Needs key (art record) | sect-ladder |
| hearth-banner | Hearth Banner (Lô Kỳ) | Canon L9 | buff, fire | 0 / 0.03 / 12 s | no damage, 3 Fire buff stacks for 20 s | Needs key (art record) | sect-ladder |

## Concepts and keys

| ID | Name | Kind | What it is | Fit | Used by |
|---|---|---|---|---|---|
| sect-curriculum | Sect curriculum (Môn Quy Giáo Trình) | Concept | a sect record listing, per realm, technique, arts, items, pill, array and Đạo nodes, plus a talent grade; the NPC generator builds members from it | Needs rule (NPC Builds #24, Sects & Missions #26; no GDD yet) | sect-ladder |
| hearth-keepers-line | Hearth Keeper's Line (Lô Thủ Mạch) | Cluster idea | open Fire-land cluster, 7 acupoints: 3 Fire damage / DoT, 2 Fire art cost, 1 regeneration, notable Deep Heat, keystone Embers Feed the Hearth at the far end | Needs key | sect-ladder |

## Reused

| ID | Found in |
|---|---|
| embers-feed-the-hearth | staging |
| kindling-breath-primer | staging |
| ember-rod | staging |
| hearth-warming-pill | staging |
| gathering-flame-array | staging |
| fire-damage-node | tree catalogue |
| fire-art-cost-node | tree catalogue |
| tag-art-speed-node | tree catalogue |
| damage-over-time-node | tree catalogue |
| first-firing-sooner-node | tree catalogue |

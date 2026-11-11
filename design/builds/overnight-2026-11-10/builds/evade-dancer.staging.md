# Staging: evade-dancer

## Modifiers

| ID | Name (Hán-Việt) | Stat and size | Form | Channel | Layer | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|---|---|---|
| surplus-breeze | Surplus Breeze (Dư Phong) | each evade point above `evade_cap`, after accuracy, gives +0.5 % art speed, up to +20 % | Overflow | art | none | Needs rule (combat.md Formulas I: report points clipped by `evade_cap`) | Phong Đạo Drift Facet notable | evade-dancer | second home: any evade or crit-over-cap build |
| wind-fed-edge | Wind-Fed Edge (Phong Dưỡng Nhận) | +2 % more Wind art damage per Wind stack on you, up to 10 stacks | Per | art | L2 | Needs key (a Wind-stack count readable by a modifier) | technique bonus | evade-dancer | second home: any Wind-stack build |
| rhythm-of-the-miss | Rhythm of the Miss (Hụt Tiết) | +25 % more hit damage for 2 s after an evade | Conditional | art | L5 | Needs rule (effects.md conditions: time since last evade) | Reed Drift cluster notable | evade-dancer | second home: any dodge or counter build |
| veiled-aim | Veiled Aim (Mạc Chuẩn) | foe accuracy −4 pp small, −10 pp from a formation | Flat base | all | none | Needs key (foe accuracy key) | formation, Đạo | evade-dancer | second home: any evade or ward build |

## Effects

| ID | Name (Hán-Việt) | Rule | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|
| evade-pays | Evade Pays (Tị Hồi) | on a hit evaded: restore 1 % of maximum linh lực and add 1 Wind buff stack for 8 s on you | Needs rule (the hit-evaded event) | enabler Unstruck Body | evade-dancer | identity piece; no second home yet |
| reply | Reply (Hồi Báo) | every 4th evaded hit fires a free riposte hit, trigger channel, within `trig_budget` | Needs rule (hit-evaded event, trigger channel) | enabler Unstruck Body | evade-dancer | trigger hits never crit and use no L5 |
| carried-off | Carried Off (Phong Tải) | an evaded hit removes one debuff stack batch of yours, at most once per pulse | Needs rule (hit-evaded event, effects.md cleanse) | enabler Unstruck Body | evade-dancer | the tick answer |

## Enablers

| ID | Name (Hán-Việt) | Kind | Lives on | Opens | Closes | Fit | Used by |
|---|---|---|---|---|---|---|---|
| unstruck-body | Unstruck Body (Bất Xúc Thân) | New channel (the evade roll) | divine ability at layer 6 of Reed-Shadow Scripture | the hit-evaded event and the three Effects | soul resistance 0 from every source, no soul ward | Needs rule | evade-dancer |

## Artifacts, talismans, pills, formations

| ID | Name (Hán-Việt) | Type | What it does | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| cicada-wing-sash | Cicada-Wing Sash (Thiền Dực Đới) | Artifact, utility | evade +10 pp, art speed, Gale affixes | Needs key (a light base) | evade-dancer | L3 |
| clear-breeze-pill | Clear-Breeze Pill (Thanh Phong Đan) | Pill | +6 pp evade for the fight | Needs key (a pill's fight payload) | evade-dancer | L4 |
| crosswind-array | Crosswind Array (Giao Phong Trận) | Formation | foe accuracy −10 pp, owner evade +8 pp | Needs key (foe accuracy) | evade-dancer | L4, ground tags |

## Công pháp

| ID | Name (Hán-Việt) | Kind and tier | What it gives | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| reed-shadow-scripture | Reed-Shadow Scripture (Lô Ảnh Kinh) | main, tier 3, Wind | evade +8, regen +6, art speed +8, Wind-Fed Edge, the enabler at layer 6 and the five arts | Needs key | evade-dancer | budget NOT ASSESSED |

## Arts

| ID | Name (Hán-Việt) | Source | Kind, tags | c_art / cost / cooldown | Rule | Fit | Used by |
|---|---|---|---|---|---|---|---|
| tuoc-phong-nhan | Reed-Cutting Breeze (Tước Phong Nhận) | Scripture layer 1 | elem, wind, cut | 1.9 / 0.03 / 2 s | Wind hit, +1 Wind stack for 8 s | Needs key | evade-dancer |
| hu-bo | Hollow Step (Hư Bộ) | Scripture layer 3 | elem, wind, step | 0.6 / 0.02 / 3 s | Wind hit, +2 Wind stacks, restores 2 % linh lực | Needs key | evade-dancer |
| dieu-lac | Falling Leaf (Điệp Lạc) | Scripture layer 5 | elem, wind, cut | 2.9 / 0.05 / 4 s | Wind hit, +1 Wind stack | Needs key | evade-dancer |
| tan-phong | Scatter Gale (Tán Phong) | Phong Đạo Drift Facet | elem, wind, cleanse | 0 / 0.03 / 6 s | cleanse 2 debuff stack batches from you | Needs key | evade-dancer |
| cuong-phong-quan | Gale Crown (Cuồng Phong Quán) | Scripture layer 9 | elem, wind, crown | 4.6 / 0.08 / 8 s | Wind hit, +3 Wind stacks for 10 s | Needs key | evade-dancer |

## Đạo pieces

| ID | Name (Hán-Việt) | Way and facet | Kind | What it does | Fit | Used by |
|---|---|---|---|---|---|---|
| phong-phieu-facet | Drift Facet lines (Phiêu) | Phong Đạo, Drift | stat lines, notable, art | evade and Wind-stack lines, notable Surplus Breeze, art Scatter Gale | Needs key | evade-dancer |

## Concepts and keys

| ID | Name | Kind | What it is | Fit | Used by |
|---|---|---|---|---|---|
| hit-evaded-event | Hit-evaded event | Concept | an evaded hit fires one event the Effects can read, bounded by `trig_budget` and `trigger_depth` | Needs rule (combat.md Formulas I, effects.md rule 9) | evade-dancer |
| reed-drift-cluster | Reed Drift (Lô Phiêu) | Cluster idea | sealed Wind cluster: evade, art speed, first firing, status duration; notables Rhythm of the Miss and Wind-Fed Edge | Needs key | evade-dancer |

## Reused

| ID | Found in |
|---|---|
| gale-affixes | staging |
| phong-cuong-phong-gale | staging |
| cleansed-stacks-event | staging |
| Element damage (Fire, Water, Wood, Metal or Earth damage), used for Wind | tree catalogue |
| Trigger limit (`trig_cap`) | tree catalogue |
| First firing comes sooner | tree catalogue |
| Status duration | tree catalogue |
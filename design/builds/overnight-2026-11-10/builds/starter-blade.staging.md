# starter-blade: staged pieces

## Modifiers

| ID | Name (Hán-Việt) | Stat and size | Form | Channel | Layer | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|---|---|---|
| drawn-steel | Drawn Steel (Xuất Thiết) | +12 pts more on arts with the sword form, rising with technique layers | More | art | L2 | Needs key (modifiers.md Stat List, a form-keyed damage_more) | Technique layer ability, Kiếm Đạo | starter-blade | Second home: any armoury or Kiếm Đạo build. First guess |
| edge-spills-over | Edge Spills Over (Phong Dật) | Crit chance past `crit_chance_cap` becomes crit damage at 1 pp of multiplier per 2 pp, bounded by `crit_mult_cap` | Overflow | art, basic | outside M | Needs rule (combat.md rule 8 crit caps) | Kiếm Ý keystone | starter-blade | Second home: any crit build. The top-end upgrade. First guess |
| hot-edge | Hot Edge (Nhiệt Phong) | +10 pts more hit damage while you crit within the last 3 s | Conditional | art, basic | L5 | Needs rule (an event "you crit within N s" readable as a condition) | Whetstone Row notable, Kiếm Đạo | starter-blade | Second home: any crit build. First guess |

## Effects

| ID | Name (Hán-Việt) | Rule | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|
| whetted-edge | Whetted Edge (Mài Phong) | Each crit you land adds one Whet stack on you (max 8). Each stack lasts 6 s on its own timer and adds 2 pp crit chance. Applies to art and basic hits. | Needs rule (effects.md: a self-stack status keyed to a crit event) | Plain Iron Sword Manual layer 4 ability | starter-blade | The identity piece. Signature. First guess |

## Enablers

| ID | Name (Hán-Việt) | Kind | Lives on | Opens | Closes | Fit | Used by |
|---|---|---|---|---|---|---|---|

(No enabler: the enabling Effect is `whetted-edge`, above.)

## Artifacts, talismans, pills, formations

| ID | Name (Hán-Việt) | Type | What it does | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| wren-feather-sword | Wren-Feather Flying Sword (Yến Vũ Phi Kiếm) | Named artifact, weapon, `phi_kiem` base | L3 gear; rolls flying sword attack and crit chance with swords | Fits today for the base; Needs key for the sword-scoped affixes | starter-blade | Starter weapon through Trúc Cơ |
| whetstone-oil | Whetstone Oil (Ma Du) | Coating, preparation | +15 to +20 pts prepared sword damage in L4 | Needs key (a coating's fight payload) | starter-blade | Reuses the preparation-fight-payload concept |
| clear-edge-pill | Clear-Edge Pill (Minh Phong Đan) | Pill, preparation | L4 points and a few points of crit chance for the fight | Needs key (a pill's fight payload) | starter-blade | |

## Công pháp

| ID | Name (Hán-Việt) | Kind and tier | What it gives | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| plain-iron-sword-manual | Plain Iron Sword Manual (Phác Thiết Kiếm Quyết) | main, tier 2, Metal | attack_pct 8, linh_luc_pct 6; abilities Whetted Edge (layer 4), Drawn Steel (layer 7); seals Whetstone Row | Needs key (abilities and combat passives) | starter-blade | Reaches Kết Đan |

## Arts

| ID | Name (Hán-Việt) | Source | Kind, tags | c_art / cost / cooldown | Rule | Fit | Used by |
|---|---|---|---|---|---|---|---|
| returning-sword-light | Returning Sword Light (Hồi Quang Kiếm) | technique layer 1 | qi, Metal, sword, flying | 2.0 / 0.04 / 3 s | A hit; the flying sword goes out and returns | Needs key (art record) | starter-blade |
| quick-draw-cut | Quick Draw Cut (Tật Xuất Kiếm Trảm) | technique layer 1 | qi, Metal, sword, quick | 1.0 / 0.02 / 1.5 s | A fast cheap hit; the main source of crit rolls | Needs key (art record) | starter-blade |
| notch-the-foe | Notch the Foe (Khắc Ngân) | technique layer 3 | qi, Metal, sword | 0.6 / 0.02 / 5 s | A hit plus 3 Metal debuff stacks for 8 s | Needs key (art record) | starter-blade |
| ten-thousand-returns | Ten Thousand Returns (Vạn Hồi Kiếm Vũ) | technique layer 10 | qi, Metal, sword, flying, slow | 4.2 / 0.08 / 8 s | A slow big hit | Needs key (art record) | starter-blade |
| sheathe-and-breathe | Sheathe and Breathe (Thu Kiếm Điều Tức) | technique layer 9 | qi, restore | 0.3 / 0.02 / 8 s | Restores 6 % of maximum linh lực | Needs key (art record) | starter-blade |

## Đạo pieces

| ID | Name (Hán-Việt) | Way and facet | Kind | What it does | Fit | Used by |
|---|---|---|---|---|---|---|
| kiem-y-edge-spills | Kiếm Ý facet holds Edge Spills Over and Hot Edge (Kiếm Ý: Phong Dật, Nhiệt Phong) | Kiếm Đạo, Kiếm Ý facet | Keystone and notable | The top-end crit pieces on the existing Sword Way | Needs rule (via `edge-spills-over` and `hot-edge`) | starter-blade |

## Concepts and keys

| ID | Name | Kind | What it is | Fit | Used by |
|---|---|---|---|---|---|
| whetstone-row-cluster | Whetstone Row (Ma Thạch Hàng) | Cluster idea | Armoury-craft cluster, Metal affinity, sealed by the Plain Iron Sword Manual; 7 acupoints (sword crit chance, basic attack damage, sword art speed) and Hot Edge as the notable | Needs key (sword-scoped crit key) | starter-blade |

## Reused

| ID | Found in |
|---|---|
| basic-coef-add-key | staging |
| basic-attack-speed | staging |
| preparation-fight-payload | staging |
| flowing-water | tree catalogue |
| elemental-fist | tree catalogue |
| crit-chance-with-swords | tree catalogue |
| flying-sword-attack | tree catalogue |
| sword-art-speed | tree catalogue |
| linh-luc-regained-on-a-crit | tree catalogue |
| sword-damage | tree catalogue |

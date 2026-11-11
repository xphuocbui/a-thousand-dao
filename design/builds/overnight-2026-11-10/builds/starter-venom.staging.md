## Modifiers

| ID | Name (Hán-Việt) | Stat and size | Form | Channel | Layer | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|---|---|---|
| patient-venom | Patient Venom (Nhẫn Độc) | +1 % more poison tick damage per 4 Poison stacks on the target, cap +25 | Per | tick | L2 | Needs rule (modifiers.md Per form reads a stack count at tick time) | Đạo Mộc Quiet Vine branch | starter-venom | First guess; its cap is folded into the fight file's L2 points |
| watched-rot | Watched Rot (Quan Hủ) | +0.3 pp linh lực regeneration while the target has 15+ Poison stacks | Conditional | any | none | Needs key (a stack-count condition on regeneration) | Đạo Mộc, Bitter Sap Row | starter-venom | The safety net that pays for itself only while the plan works |

## Effects

| ID | Name (Hán-Việt) | Rule | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|
| seeds-left-behind | Seeds Left Behind (Di Chủng) | When a cleanse removes Poison stacks you applied, 30 % of them regrow as a new 6 s batch, at most once per 4 s | Needs rule (effects.md rule 9a, on the staged `cleansed-stacks-event`) | Quiet Vine Sutra layer 12 | starter-venom | Answers the cleanser |

## Enablers

| ID | Name (Hán-Việt) | Kind | Lives on | Opens | Closes | Fit | Used by |
|---|---|---|---|---|---|---|---|

## Artifacts, talismans, pills, formations

| ID | Name (Hán-Việt) | Type | What it does | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| bitter-thorn-needle | Bitter-Thorn Needle (Khổ Thích Châm) | Artifact, weapon | A `cham` of thượng phẩm grade with a Liệt affix and a Wood element-affinity affix; L3 for the tick build | Fits today (named item on a generated base) | starter-venom | |
| mossback-vest | Mossback Vest (Đài Bối Giáp) | Artifact, body | A `giap` of trung phẩm with a Hộ Thân affix; costs 5 thần thức | Fits today | starter-venom | |
| bitterroot-pill | Bitterroot Pill (Khổ Căn Đan) | Pill | Prepared poison tick +9 in L4 for the fight | Needs key (a pill's fight payload) | starter-venom | |

## Công pháp

| ID | Name (Hán-Việt) | Kind and tier | What it gives | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| quiet-vine-sutra | Quiet Vine Sutra (Tĩnh Đằng Kinh) | Secret, tier 2, Wood | linh lực +6, health +6; Rot Deepens +20 L2 and Long Roots (batches last 20 % longer); abilities Thorn Seed 1, Weeping Sap 3, Rot Bloom 5, Venom Tithe 9, Seeds Left Behind 12 | Needs key | starter-venom | Pairs with the existing Thanh Mộc Địa Quyết |

## Arts

| ID | Name (Hán-Việt) | Source | Kind, tags | c_art / cost / cooldown | Rule | Fit | Used by |
|---|---|---|---|---|---|---|---|
| thorn-seed | Thorn Seed (Thích Chủng) | Quiet Vine Sutra, 1 | Qi hit, wood, poison, over_time | 0.5 / 0.03 / 3 s | Hit plus 10 Poison stacks, 14 s (12 at Kết Đan) | Needs key (art record) | starter-venom |
| weeping-sap | Weeping Sap (Khấp Dịch) | Quiet Vine Sutra, 3 | Heal, wood | heal 0.9 / 0.04 / 7 s | Heal plus 3 Wood buff stacks, 14 s (4 at Kết Đan) | Needs key (art record) | starter-venom |
| rot-bloom | Rot Bloom (Hủ Hoa) | Quiet Vine Sutra, 5 | Qi hit, wood, poison | 0.4 / 0.05 / 6 s | Hit plus 24 Poison stacks, 20 s (30 at Kết Đan) | Needs key (art record) | starter-venom |
| venom-tithe | Venom Tithe (Độc Thuế) | Quiet Vine Sutra, 9 | Qi hit, wood, poison | 0.3 / 0.04 / 8 s | Hit plus 16 Poison stacks, 24 s; restores 2 % of linh lực | Needs key (art record) | starter-venom |

## Đạo pieces

| ID | Name (Hán-Việt) | Way and facet | Kind | What it does | Fit | Used by |
|---|---|---|---|---|---|---|
| moc-tinh-dang-lines | Quiet Vine branch (Mộc: Tĩnh Đằng) | Wood (Mộc), Growth and Venom lines | Stat lines and two notables | Holds Patient Venom and Watched Rot; lines of Poison damage and regeneration | Needs key | starter-venom |

## Concepts and keys

| ID | Name | Kind | What it is | Fit | Used by |
|---|---|---|---|---|---|
| poison-stack-count-readable | Target's Poison stacks | Key | The number of the applier's Poison stacks on the target, readable by modifiers and conditions | Needs rule (modifiers.md, effects.md rule 9a) | starter-venom |
| bitter-sap-cluster | Bitter Sap Row (Khổ Dịch) | Cluster idea | Wood poison, sealed, 7 acupoints: Poison damage and Status duration smalls, Watched Rot notable | Needs key | starter-venom |
| cleanser-telegraph | Cleanser telegraph | Concept | A foreseen-fight line that says the enemy cleanses | Needs rule (combat.md rule 12, Guidance Layer) | starter-venom |

## Reused

| ID | Found in |
|---|---|
| root-drinks-the-rot | missing pieces |
| sap-rises | staging |
| hot-spring-array | staging |
| cleansed-stacks-event | staging |
| noc-spillover | staging |
| twenty-year-rot | missing pieces |
| thorns | missing pieces |
| spirit-tea | missing pieces |
| rot-deepens | tree catalogue |
| corpse-wax-coating | tree catalogue |
| spillover | tree catalogue |
| poison-damage | tree catalogue |
| damage-over-time | tree catalogue |
| status-duration | tree catalogue |
| linh-luc-regeneration | tree catalogue |

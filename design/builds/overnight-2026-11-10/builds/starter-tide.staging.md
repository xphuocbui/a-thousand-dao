# starter-tide staging

## Modifiers

| ID | Name (Hán-Việt) | Stat and size | Form | Channel | Layer | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|---|---|---|
| still-water | Still Water (Tĩnh Thủy) | +15 ward efficiency while linh lực is at or above 80 % of maximum | Conditional | ward | W5 | Needs rule (combat-defence.md Formulas A, ward drain reads the pool share) | Thủy Đạo Triều facet notable, Full Cistern cluster | starter-tide | Second home: any pool-fed ward build |
| depth-is-shield | Depth Is Shield (Uyên Thành Thuẫn) | 1 point ward strength per 5 % of max linh lực above the realm base, capped at +40 | Borrow | ward | W2 | Needs rule (combat-defence.md A0, borrow with a bound) | Thủy Đạo Uyên keystone | starter-tide | Top-end upgrade; closes: none, but the cap is the bound |

## Artifacts, talismans, pills, formations

| ID | Name (Hán-Việt) | Type | What it does | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| tide-bound-gourd | Tide-Bound Gourd (Hệ Triều Hồ Lô) | Artifact, utility, named | Carries Spill Shield | Needs key (new utility base or a named item with an authored effect) | starter-tide | History: a well-keeper's gourd never emptied in forty years |
| still-pool-array | Still Pool Array (Tĩnh Trì Trận) | Formation | Prepared: Water art damage (L4) and ward W4 of about 30 | Needs key (a combat formation payload) | starter-tide | |
| clear-spring-pill | Clear-Spring Pill (Thanh Tuyền Đan) | Pill | Prepared: max linh lực up for the fight | Needs key (a pill's fight payload) | starter-tide | |

## Công pháp

| ID | Name (Hán-Việt) | Kind and tier | What it gives | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| tide-reading-canon | Reading the Tide Canon (Độc Triều Kinh) | main, tier 2, Water | linh_luc_pct 16, regen 0.5, L2 Water arts +40 more, three arts and Brimming Cup as abilities | Needs key (abilities, combat passives) | starter-tide | Reaches Kết Đan |

## Arts

| ID | Name (Hán-Việt) | Source | Kind, tags | c_art / cost / cooldown | Rule | Fit | Used by |
|---|---|---|---|---|---|---|---|
| tide-pulse | Tide Pulse (Triều Xung) | Canon layer 1 | qi, Water, hit | 2.0 / 3 % / 3 s | Gives 1 Water buff stack for 12 s | Needs key (art record) | starter-tide |
| deep-well-seal | Deep Well Seal (Thâm Tỉnh Ấn) | Canon layer 3 | qi, Water, seal, hit | 3.1 / 4 % / 6 s | Plain hit, carries L2 | Needs key (art record) | starter-tide |
| drawing-breath | Drawing Breath (Hấp Triều) | Canon layer 5 | qi, Water, hit | 0.8 / 2 % / 8 s | Restores 7 % of pool, gives 2 Water stacks 15 s | Needs key (art record) | starter-tide |

## Đạo pieces

| ID | Name (Hán-Việt) | Way and facet | Kind | What it does | Fit | Used by |
|---|---|---|---|---|---|---|
| thuy-uyen-tide-lines | Depths and Tides lines (Uyên, Triều) | Thủy Đạo, Uyên and Triều facets | Stat lines, notable, keystone | Pool and regeneration lines; Still Water notable; Depth Is Shield keystone | Needs rule (via still-water and depth-is-shield) | starter-tide |

## Concepts and keys

| ID | Name | Kind | What it is | Fit | Used by |
|---|---|---|---|---|---|
| full-cistern-cluster | Full Cistern (Mãn Trì) | Cluster idea | Water, sealed by the Canon, 8 acupoints: max linh lực, regeneration, ward efficiency; notables Still Water and a +8 % pool | Needs key | starter-tide |
| pool-share-on-ward | Pool share read by a ward | Key and rule | The ward's drain reads current linh lực share as a condition | Needs rule (combat-defence.md Formulas A) | starter-tide |

## Reused

| ID | Found in |
|---|---|
| brimming-cup | missing pieces |
| spill-shield | missing pieces |
| gathering-tide | missing pieces |
| full-sea | tree catalogue |
| water-damage | tree catalogue |
| tag-art-cost | tree catalogue |
| hot-spring-array | staging |
| spring-never-fails | staging |
| well-drawing-gourd | staging |

# Staging: art-thief

## Modifiers

| ID | Name (Hán-Việt) | Stat and size | Form | Channel | Layer | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|---|---|---|
| faithful-copy | Faithful Copy (Chân Bản) | `copy_fidelity_pct`: base 70, +6 per notable, cap 100 | Flat base | art (copy) | none | Needs key | Hollow Hall cluster notables | art-thief | Second home: any clone or likeness build |
| warm-hand | Warm Hand (Nhiệt Thủ) | `copy_start_share`: a fresh copy starts at 25 % of its cooldown instead of 50 % | Timing | art (copy) | none | Needs key | Hollow Hall cluster, Thousand-Hands Gauntlet affix | art-thief | Second home: any opening-speed build |
| pilfered-craft | Pilfered Craft (Thâu Công) | +30 % more damage on `stolen` arts | More | art (copy) | L2 | Needs key (tag `stolen`) | Hư Thực Đạo, Ẩn Thực notable | art-thief | Second home: any mimic or companion-art build |
| borrowed-weight | Borrowed Weight (Mượn Trọng) | +12 % more for each distinct copy held, cap 4 (+48) | Per | art (copy) | L2 | Needs key | Hollow Hall Sutra layer bonus | art-thief | Signature: the engine of this build; naturally bounded by the loan slot count |
| full-hand | Full Hand (Mãn Thủ) | +60 % more hit damage while every loan slot holds a copy | Conditional | art (copy) | L5 | Needs key (condition readable at run time) | Hư Thực Đạo, Thực Kích notable | art-thief | Second home: any full-loadout build |
| hollow-guard | Hollow Guard (Hư Hộ) | +8 % more ward strength for each loan slot still empty | Conditional | ward | W2 | Needs rule (reads slot fill at run time) | Bare-Scroll Robe affix | art-thief | Second home: Clear Path or Quiet Channels builds with empty slots |
| own-medicine | Own Medicine (Dĩ Độc Công Độc) | `stolen_res_pen_pct` 50: the foe's resistance to a copy's tags counts at half | More | art (copy) | none | Needs key | Hollow Hall cluster notable | art-thief | Second home: any build that fights a resistant foe |
| wide-sleeve | Wide Sleeve (Khoan Tụ) | `loan_slots_bonus` +1; own arts cost +20 % linh lực | Cap shift and Trade | none | none | Needs key | Hollow Hall cluster, outer notable | art-thief | Second home: any slot bender |
| stolen-breath | Stolen Breath (Tá Tức) | A copy's hit restores 1.5 % of maximum linh lực | Trigger | art (copy) | none | Needs key | Hollow Hall cluster | art-thief | Second home: any leech build |

## Effects

| ID | Name (Hán-Việt) | Rule | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|
| spent-hand | Spent Hand (Tàn Thủ) | When a copy would be lost because the loan slots are full, it is released at once as a free hit at 50 % of its coefficient. Counts against the trigger budget | Needs rule (combat.md rule 9) | Hư Thực Đạo capstone | art-thief | Overflow form. Second home: any slot-limited build |
| pre-read | Pre-Read (Tiên Duyệt) | If the foe's art list is known before the fight, its most costly known art is copied into loan slot 1 at t = 0, starting at its half cooldown | Needs rule (Combat Open Question 4, rule 12) | Mirror-Study Array payload | art-thief | Works in a blind fight only with Standing Array. Second home: any scout build |

## Enablers

| ID | Name (Hán-Việt) | Kind | Lives on | Opens | Closes | Fit | Used by |
|---|---|---|---|---|---|---|---|
| borrowed-hand | Borrowed Hand (Tá Thủ) | Slot bender and Borrow | Hollow Hall Sutra, layer 4 ability | Loan slots: every empty art slot records the foe's casts as copies fired on your layers | The slots themselves, soul, ward and escape arts, and any foe with no art | Needs rule (combat.md rule 13) | art-thief |

## Artifacts, talismans, pills, formations

| ID | Name (Hán-Việt) | Type | What it does | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| thousand-hands-gauntlet | Thousand-Hands Gauntlet (Thiên Thủ Thủ Sáo) | Artifact, weapon | L3 weapon attack and the Warm Hand affix | Needs key | art-thief | A named piece with authored flavour |
| bare-scroll-robe | Bare-Scroll Robe (Bạch Quyển Y) | Artifact, armour (ward) | Ward strength and the Hollow Guard affix | Fits today (ward and a new affix) | art-thief | |
| mirror-study-array | Mirror-Study Array (Duyệt Kính Trận) | Formation | L4 prepared more and the Pre-Read payload | Needs rule (carries an Effect payload) | art-thief | |
| still-mind-pill | Still-Mind Pill (Tĩnh Tâm Đan) | Pill | Modest thần thức and pill effect for the fight | Fits today | art-thief | |

## Công pháp

| ID | Name (Hán-Việt) | Kind and tier | What it gives | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| hollow-hall-sutra | Hollow Hall Sutra (Hư Đường Kinh) | Main, Địa giai (tier 2), water | `linh_luc_pct` 12, `linh_luc_regen_pct` 0.4, Borrowed Weight at layer bonus, Borrowed Hand at layer 4 | Needs rule (the ability) | art-thief | Seals the Hollow Hall cluster |

## Arts

| ID | Name (Hán-Việt) | Source | Kind, tags | c_art / cost / cooldown | Rule | Fit | Used by |
|---|---|---|---|---|---|---|---|
| hollow-palm | Hollow Palm (Hư Chưởng) | Hollow Hall Sutra, layer 1 | qi, Water, Palm, strike | 2.6 / 0.04 / 4 s | A plain hit | Needs key | art-thief |
| still-pool-mending | Still Pool Mending (Tĩnh Trì Hồi Khí) | Hollow Hall Sutra, layer 2 | qi, Water, heal | heal 1.2 / 0.04 / 6 s | Heals | Fits today | art-thief |

## Đạo pieces

| ID | Name (Hán-Việt) | Way and facet | Kind | What it does | Fit | Used by |
|---|---|---|---|---|---|---|
| hidden-hand-notable | Hidden Hand (Ẩn Thủ) | Hư Thực Đạo, Ẩn Thực | Notable | Carries Pilfered Craft | Needs key | art-thief |
| true-hand-notable | True Hand (Thực Thủ) | Hư Thực Đạo, Thực Kích | Notable | Carries Full Hand and crit on stolen arts | Needs key | art-thief |
| empty-becomes-full | The Empty Becomes Full (Hư Thực Tương Sinh) | Hư Thực Đạo, capstone | Keystone | Carries Spent Hand | Needs rule | art-thief |

## Concepts and keys

| ID | Name | Kind | What it is | Fit | Used by |
|---|---|---|---|---|---|
| loan-slot | Loan slot (Tá Vị) | Concept (Combat rule 13) | An empty art slot at fight start that records one copy of a foe's art; one per art id; never a soul, ward or escape art; copies end with the fight | Needs rule | art-thief |
| stolen-tag | Stolen tag | Key (Combat rule 6, tags) | A tag every copy carries, so modifiers can scope to copies | Needs key | art-thief |
| enemy-art-cast-readable | Foe's art cast readable | Rule (Combat rule 10) | An Effect or the loan rule can read the id and record of an art the foe has just cast | Needs rule | art-thief |
| hollow-hall-cluster | Hollow Hall (Hư Đường) | Cluster idea | Water, sealed by the sutra; 8 acupoints, 2 notables and an outer notable; Faithful Copy, Warm Hand, Own Medicine, Stolen Breath, Wide Sleeve | Needs key | art-thief |

## Reused

| ID | Found in |
|---|---|
| empty-art-slot | staging |
| clear-path | staging |
| tag-art-speed (art speed with one tag) | tree catalogue |
| tag-crit-chance (crit chance with one tag) | tree catalogue |
| art-cost (`art_cost_pct`) | tree catalogue |
| standing-array (Thường Trận) | tree catalogue |
| home-ground (Địa Lợi) | tree catalogue |

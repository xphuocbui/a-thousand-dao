# Staging: status-collector

## Modifiers

| ID | Name (Hán-Việt) | Stat and size | Form | Channel | Layer | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|---|---|---|
| crowded-ledger | Crowded Ledger (Chúng Bệnh) | +3 % more art damage per distinct own status on the target, cap +36 | Per | art | L2 | Needs rule (combat.md Formulas B: live read in L2) | hidden cluster, far notable | status-collector | second home: Curse-engine |
| thrifty-brand | Thrifty Brand (Tiết Ấn) | −8 % art cost on arts that apply a status (tag `status_apply`), notable | Increased | art | none | Needs key (new tag `status_apply`) | tree | status-collector | second home: starter-venom, curse-engine |
| extra-curse-slot | Extra Curse Slot (Thêm Chú Vị) | +1 `curse_slots` | Cap shift | any | none | Needs key (a cap-shift key) | hidden cluster, last notable | status-collector | rare; second home: Curse-engine |

## Effects

| ID | Name (Hán-Việt) | Rule | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|
| tally-ten | Tally Ten (Thập Kết) | Marked Prey counts up to twelve kinds of your statuses: its cap becomes +48 instead of +16 | Needs rule (effects.md Marked Prey Limits) | Độc Đạo, Ôn Dịch capstone | status-collector | any Marked Prey build |
| rolling-refresh | Rolling Refresh (Lan Bệnh) | When you apply a status, one other of your statuses on the target is refreshed by 1 pulse; 2 per firing | Needs rule (effects.md Trigger; trigger budget) | Độc Đạo, Ôn Dịch middle node | status-collector | second home: starter-venom |

## Enablers

| ID | Name (Hán-Việt) | Kind | Lives on | Opens | Closes | Fit | Used by |
|---|---|---|---|---|---|---|---|
| tally-gourd | Tally Gourd (Kết Sổ Hồ Lô) | Loop opener | Named artifact, `ho_lo` base, cực | After an art of yours applies a status, a 1-stack, 3-pulse batch of the next of Qi Disruption, Bleed, Exposed the target lacks | −30 % direct damage on status-applying arts; one curse slot; 25 thần thức | Needs rule (effects.md Trigger record on an item) | status-collector |

## Artifacts, talismans, pills, formations

| ID | Name (Hán-Việt) | Type | What it does | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| registrars-needle | Registrar's Needle (Chủ Bộ Châm) | Artifact, weapon, `cham` | L3 attack with Liệt and element affixes | Fits today (generated item) | status-collector | named flavour only |
| hospice-ward-robe | Hospice Ward Robe (Dưỡng Đường Y) | Artifact, ward, `giap` | W3 gear for the drain ward | Fits today (generated item) | status-collector | named flavour only |
| hundred-herb-pill | Hundred-Herb Pill (Bách Thảo Đan) | Pill | Fight payload: +12 % status duration | Needs key (uses the reused `preparation-fight-payload`) | status-collector | L4 |

## Công pháp

| ID | Name (Hán-Việt) | Kind and tier | What it gives | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| hundred-ailment-canon | Hundred-Ailment Register Canon (Bách Bệnh Chân Kinh) | Main, tier 3 (Thiên) | five-element names, four Brand arts and Ledger Reckoning, seals the Many Hands cluster | Needs key (a five-element main; abilities) | status-collector | budget NOT ASSESSED |
| two-variants-pamphlet | Two Variants Pamphlet (Nhị Biến Tiểu Sách) | Secret, tier 2 | Thread-Lightning and Rime Brands | Needs key | status-collector | aux harmony NOT ASSESSED |

## Arts

| ID | Name (Hán-Việt) | Source | Kind, tags | c_art / cost / cooldown | Rule | Fit | Used by |
|---|---|---|---|---|---|---|---|
| ember-brand | Ember Brand (Hỏa Ấn) | Canon layer 2 | elem, fire, status | 0.7 / 0.02 / 3 s | hit plus a 5-stack, 10 s Burn batch | Needs key (art record) | status-collector |
| cracked-earth-brand | Cracked-Earth Brand (Thổ Ấn) | Canon layer 4 | elem, earth, status | 0.7 / 0.02 / 3 s | hit plus Earth debuff batch (accuracy down) | Needs key (art record) | status-collector |
| cold-iron-brand | Cold-Iron Brand (Kim Ấn) | Canon layer 6 | elem, metal, status | 0.7 / 0.02 / 3 s | hit plus Metal debuff batch (physical taken up) | Needs key (art record) | status-collector |
| bitter-sap-brand | Bitter-Sap Brand (Mộc Ấn) | Canon layer 8 | elem, wood, status | 0.7 / 0.02 / 3 s | hit plus Poison batch | Needs key (art record) | status-collector |
| thread-lightning-brand | Thread-Lightning Brand (Lôi Ấn) | Pamphlet layer 4 | elem, thunder, status | 0.7 / 0.02 / 3 s | hit plus Thunder debuff batch (crit taken up) | Needs key (art record) | status-collector |
| rime-brand | Rime Brand (Băng Ấn) | Pamphlet layer 8 | elem, ice, status | 0.7 / 0.02 / 3 s | hit plus Ice debuff batch (art cost up) | Needs key (art record) | status-collector |
| ledger-reckoning | Ledger Reckoning (Tính Sổ) | Canon layer 12 | phys, metal | 3.1 / 0.06 / 4 s | a physical hit; L2 and L5 read the count | Needs key (art record) | status-collector |

## Đạo pieces

| ID | Name (Hán-Việt) | Way and facet | Kind | What it does | Fit | Used by |
|---|---|---|---|---|---|---|
| on-dich-tally-ten | Plague Facet holds Tally Ten and Rolling Refresh (Ôn Dịch: Thập Kết, Lan Bệnh) | Độc Đạo, Ôn Dịch facet | Effect nodes | capstone and middle node | Needs rule (via `tally-ten`) | status-collector |

## Concepts and keys

| ID | Name | Kind | What it is | Fit | Used by |
|---|---|---|---|---|---|
| status-roster-twelve | Distinct-status roster (the twelve) | Rule table | what counts as one kind: six element debuff families, Bleed, Qi Disruption, Corpse Rot, up to three curses | Needs rule (effects.md Marked Prey "distinct statuses") | status-collector |
| status-apply-tag | `status_apply` tag | Key | tag on arts that apply a status, scope of Thrifty Brand and the Gourd | Needs key | status-collector |
| many-hands-cluster | Many Hands (Quần Thủ) | Cluster idea | sealed Wood cluster of 8 acupoints: status chance, duration, Thrifty Brand, art speed; far notables Crowded Ledger and Extra Curse Slot; sealed by the Canon | Needs key | status-collector |

## Reused

| ID | Found in |
|---|---|
| nine-rods-array | staging |
| deeper-nails | staging |
| cleanser-telegraph | staging |
| preparation-fight-payload | staging |

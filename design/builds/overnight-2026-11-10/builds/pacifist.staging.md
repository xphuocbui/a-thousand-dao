## Modifiers

| ID | Name (Hán-Việt) | Stat and size | Form | Channel | Layer | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|---|---|---|
| deeper-frost | Deeper Frost (Hàn Thâm) | +12 % ice stack `cost_up` per notable | Increased | stack | none | Needs key | Tree | pacifist | Second home: any ice or cost-denial build |
| long-frost | Long Frost (Hàn Kéo Dài) | +12 % ice stack duration | Increased | stack | none | Needs key | Tree | pacifist | Second home: any stack build. Overlaps catalogue "Status duration" |
| patient-ward | Patient Ward (Nhẫn Hộ) | +1 % ward strength per 10 s fought, cap +20 % | Per | ward | W2 | Needs key | Technique | pacifist | Second home: Late Bloom builds |

## Effects

| ID | Name (Hán-Việt) | Rule | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|
| debt-seal | Debt Seal (Trái Ấn) | Foe with Seals pays 5 % of each art's cost per Seal in health, cap 10 Seals and 50 % of a cost; not damage | Needs rule (effects.md Blood Casting; combat.md rule 11) | Way (Nhân Quả, Nợ) | pacifist | Identity piece. Signature |
| interest | Interest (Lợi Tức) | Regain 20 % of the linh lực the foe spends, up to 2 % of your maximum a pulse | Needs rule (effects.md) | Way (Nhân Quả, Nợ) | pacifist | Second home: any drain build |
| unspent-edge | Unspent Edge (Nhận Chưa Rút) | `attack_pct` counts 50 % as ward strength and body strength | Needs rule (combat-defence.md A0) | Named item | pacifist | Borrow form |
| backlash-count | Backlash Count (Phản Chấn) | Every 4th foe art under 3 or more Seals costs them 4 % of their health (pay, not damage) | Needs rule (effects.md) | Way (Nhân Quả, Báo Ứng) | pacifist | Signature |
| dread-of-the-ledger | Dread of the Ledger (Kinh Trướng) | At 8 or more Seals and half health the foe starts its escape channel; flight is a win for the Vow bearer | Needs rule (combat.md Escape) | Way keystone | pacifist | Second home: Soul Pressure builds |

## Enablers

| ID | Name (Hán-Việt) | Kind | Lives on | Opens | Closes | Fit | Used by |
|---|---|---|---|---|---|---|---|
| open-palm-vow | Open Palm Vow (Bất Tranh Thệ) | Free channel | Technique ability, layer 9 | The basic attack lays a Debt Seal per hit | All direct damage: basic coefficient 0, no art above `c_art` 0 | Needs rule (effects.md closing rule) | pacifist |

## Artifacts, talismans, pills, formations

| ID | Name (Hán-Việt) | Type | What it does | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| still-pond-array | Silent Pond Array (Tĩnh Trì Trận) | Formation | L4 ward more from preparation | Needs key | pacifist | |
| ledger-slip-talisman | Ledger Slip Talisman (Trướng Phù) | Talisman | Lays 5 Seals at t = 0; one use, takes an art slot | Needs key | pacifist | |

## Công pháp

| ID | Name (Hán-Việt) | Kind and tier | What it gives | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| tinh-tri-truong-kinh | Still Pond Ledger Sutra (Tĩnh Trì Trướng Kinh) | main, tier 3 | Regeneration, art cost, healing, ability Open Palm Vow at layer 9 | Needs key | pacifist | Budget NOT ASSESSED |

## Arts

| ID | Name (Hán-Việt) | Source | Kind, tags | c_art / cost / cooldown | Rule | Fit | Used by |
|---|---|---|---|---|---|---|---|
| cold-ledger | Cold Ledger (Hàn Trướng) | Sutra, layer 1 | qi, ice, stack | 0 / 0.04 / 4 s | 3 ice stacks for 12 s | Needs key | pacifist |
| silent-tally | Silent Tally (Mặc Kế) | Sutra, layer 4 | qi, curse | 0 / 0.04 / 6 s | Stagnation and Qi Disruption | Needs key | pacifist |
| still-tide | Still Tide (Tĩnh Triều) | Sutra, layer 2 | water, heal, buff | heal 0.5 / 0.04 / 5 s | heal and 2 water stacks | Needs key | pacifist |
| closing-the-book | Closing the Book (Khép Trướng) | Nợ node | curse | 0 / 0.08 / 12 s | guard: foe has 8 or more Seals; converts Seals to Dread | Needs rule | pacifist |

## Đạo pieces

| ID | Name (Hán-Việt) | Way and facet | Kind | What it does | Fit | Used by |
|---|---|---|---|---|---|---|
| no-ledger-facet | Debts facet notables (Nợ) | Nhân Quả Đạo, Nợ and Báo Ứng | Notables and keystone | Holds Debt Seal, Interest, Backlash Count, Closing the Book, Dread | Needs rule | pacifist |

## Concepts and keys

| ID | Name | Kind | What it is | Fit | Used by |
|---|---|---|---|---|---|
| foe-pays-cost | Foe pays its costs in health | Concept | Opposed cost payment (Debt Seal, Interest) | Needs rule | pacifist |
| flight-is-a-win | Flight is a win | Concept | A foe's flight counts as the Vow bearer's win | Needs rule | pacifist |

## Reused

| ID | Found in |
|---|---|
| deeper-nails | staging |
| extra-curse-slot | staging |
| basic-attack-speed | staging |
| late-bloom | tree catalogue |
| status-duration | tree catalogue |
| first-firing-sooner | tree catalogue |
| measured-breath | content ledger |

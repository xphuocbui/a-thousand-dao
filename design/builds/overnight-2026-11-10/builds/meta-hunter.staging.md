# Staging: meta-hunter

## Modifiers

| ID | Name (Hán-Việt) | Stat and size | Form | Channel | Layer | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|---|---|---|
| whetted-edge | Whetted Edge (Lợi Nhận) | +20 % more damage on arts with the Metal tag, per art | More | art | L2 | Needs key (modifiers.md Stat List: a tag-scoped `damage_more`) | Kim Đạo passive, technique | meta-hunter | Second home: any Metal build |
| spent-blood | Spent Blood (Huyết Phí) | +4 % more per 10 % of the foe's maximum health spent on art costs, cap +40 % | Per | art | L2 | Needs rule (a readable, see `health-paid-cost-readable`) | Hidden cluster Steady Hand | meta-hunter | Second home: any build that faces a health-payer; bounded by the cap |
| hounds-scent | Hounds on the Scent (Truy Tung) | +16 % more per distinct status you have on the foe, up to 5 statuses (+80 %) | Per | art | L5 | Needs rule (the distinct-status readable of `status-roster-twelve`) | Kim Đạo node | meta-hunter | Second home: any status-stacking build |
| spilled-ink | Spilled Ink (Dật Mặc) | Linh lực gained past a full pool becomes a ward shield at 50 % | Overflow | any | none | Needs rule (combat-defence.md shields) | Tree notable, Steady Hand | meta-hunter | Second home: any leech or on-hit build |

## Effects

| ID | Name (Hán-Việt) | Rule | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|
| dear-blood | Dear Blood (Huyết Quý) | Curse, 10 s, refresh: the foe's health-paid art costs are 1.5×. Needs the Ledger Seal | Needs rule (effects.md curse table; combat-defence.md E, cost payment) | Writ of Reckoning | meta-hunter | Cleanse tags: curse, cleanse; status resistance applies |
| called-debt | Called Debt (Đòi Nợ) | Each pulse, 15 % of the health the foe paid on costs in that pulse returns to them as a tick (Force) | Needs rule (effects.md tick; readable `health-paid-cost-readable`) | Ledger Seal | meta-hunter | Not damage that ends the fight alone: bounded by the foe's own spending |
| clean-ledger | Clean Ledger (Sạch Sổ) | Stagnation on the wearer is capped at 20 stacks; each stack past it adds +0.4 % more (L5), cap +40 % | Needs rule (effects.md rule 9, stacking) | Ledger Seal | meta-hunter | Second home: any cleanser or anti-curse build |

## Enablers

| ID | Name (Hán-Việt) | Kind | Lives on | Opens | Closes | Fit | Used by |
|---|---|---|---|---|---|---|---|
| ledger-seal | Ledger Seal (Bạ Ấn) | Rule swap and loop opener | Named artifact, base `an`, `thuong` | The entries rule: Dear Blood, Called Debt, Spent Blood and Clean Ledger go live | The wearer can never pay costs in health or apply Stagnation | Needs rule | meta-hunter |

## Artifacts, talismans, pills, formations

| ID | Name (Hán-Việt) | Type | What it does | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| clear-bile-pill | Clear-Bile Pill (Thanh Đởm Đan) | Pill | Prepared: +20 pp status resistance against curses for the fight; fills L4 with the array | Needs key (a pill's fight payload) | meta-hunter | Also useful for any anti-curse build |
| ledger-hall-array | Ledger-Hall Array (Bạ Đường Trận) | Formation | Prepared L4 for arts against a known quarry; blind fights lose it | Needs key (combat formation payload) | meta-hunter | Needs `quarry-knowledge` to be useful |

## Công pháp

| ID | Name (Hán-Việt) | Kind and tier | What it gives | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| open-ledger-sutra | Open Ledger Sutra (Khai Bạ Kinh) | Main, tier 3, Metal | `linh_luc_pct` 30, `status_resist_pct` 15, `leech_linh_luc_pct` 3, six abilities | Needs key (abilities are art records) | meta-hunter | Budget not checkable: two stats are outside `bonus_pool` |

## Arts

| ID | Name (Hán-Việt) | Source | Kind, tags | c_art / cost / cooldown | Rule | Fit | Used by |
|---|---|---|---|---|---|---|---|
| whetted-tally | Whetted Tally (Ma Nhận Kế) | Open Ledger Sutra, layer 1 | phys, Metal, hit | 2.6 / 0.05 / 3 s | Hit, 2 Metal debuff stacks for 8 s | Needs key | meta-hunter |
| closing-the-book | Closing the Book (Hợp Bạ Trảm) | Sutra, layer 1 | phys, Metal, hit | 3.1 / 0.04 / 6 s | Heavy hit; Spent Blood applies | Needs key | meta-hunter |
| writ-of-reckoning | Writ of Reckoning (Thúc Nợ Trạng) | Sutra, layer 3 | elem, Metal, curse | 1.2 / 0.03 / 5 s | 4 Metal debuff stacks for 10 s; Withering; with the Seal, Dear Blood | Needs rule | meta-hunter |
| clean-the-page | Clean the Page (Tẩy Trang) | Sutra, layer 6 | elem, Metal, cleanse | 0 / 0.03 / 6 s | Guard: you hold 1 or more Stagnation stacks; removes all of them | Needs key | meta-hunter |
| ink-line-breath | Ink-Line Breath (Mặc Tuyến Tức) | Sutra, layer 8 | elem, restore | 0 / 0.02 / 8 s | Restores 5 % of maximum linh lực | Needs key | meta-hunter |
| bloodhound-count | Bloodhound's Count (Truy Huyết Toán) | Sutra, layer 11 | phys, Metal, hit | 3.4 / 0.05 / 8 s | Heavy hit; Spent Blood applies | Needs key | meta-hunter |

## Đạo pieces

| ID | Name (Hán-Việt) | Way and facet | Kind | What it does | Fit | Used by |
|---|---|---|---|---|---|---|
| kim-dao-whetted-edge | Whetted Edge (Lợi Nhận) | Kim Đạo, Kim Phong | Passive | The Whetted Edge modifier | Needs key | meta-hunter |
| kim-dao-clean-hand | Clean Hand (Thanh Thủ) | Kim Đạo, Thối Thể | Notable | +20 pp status resistance against curses | Fits today | meta-hunter |

## Concepts and keys

| ID | Name | Kind | What it is | Fit | Used by |
|---|---|---|---|---|---|
| health-paid-cost-readable | Health paid on art costs | Readable | The health a side has paid on art costs this fight and in the last pulse (Effects rule 5) | Needs rule | meta-hunter |
| quarry-knowledge | Quarry knowledge | Concept | A sect's listed quarry makes the fight non-blind for L4 against that pattern (Combat rule 12) | Needs rule | meta-hunter |
| incoming-status-stack-cap | Incoming status stack cap | Concept | Caps a status's stacks on the wearer and turns the excess into a bonus (Effects rule 9) | Needs rule | meta-hunter |
| steady-hand-cluster | Steady Hand (Ổn Thủ) | Cluster idea | Heart State, Metal, sealed by the Ledger Seal; 8 acupoints: leech, curse resistance, art cost, notables Spilled Ink and Spent Blood | Needs key | meta-hunter |

## Reused

| ID | Found in |
|---|---|
| status-roster-twelve | staging |
| spirit-severing | tree catalogue |

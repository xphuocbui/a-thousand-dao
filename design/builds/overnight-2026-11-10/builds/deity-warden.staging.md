# deity-warden staging

## Modifiers

| ID | Name (Hán-Việt) | Stat and size | Form | Channel | Layer | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|---|---|---|
| fast-art-ward | Fast-Art Ward (Khoái Kích Hộ) | +40 % ward strength against arts under 2 s cooldown and basic attacks | More | art, basic | W2 | Needs key | công pháp, Turning Year cluster | deity-warden | any anti-evade-dancer or anti-flurry defender |
| lustral-share | Lustral Share (Tẩy Phần) | `cleanse_share` 0.25 to 0.5 | Increased | stacks | none | Needs key | công pháp, tree notable | deity-warden | any cleanser; bounded at 0.5 |
| ward-down-more | Bare Gate (Lộ Quan) | +40 % more damage while own ward is down | Conditional | art | L5 | Needs key | công pháp | deity-warden | any Empty Vessel or no-ward build |

## Effects

| ID | Name (Hán-Việt) | Rule | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|
| gate-turning | Gate Turning (Chuyển Quan) | every 12 s the holder's ward changes model, the old capacity is discarded and a 2 s Toll leaves no ward | Needs rule (combat-defence.md rule 1) | Nine-Gate Seal | deity-warden | signature; also Turning Key |
| lustral-toll | Lustral Toll (Tẩy Chung) | on a 10 s clock, 1.5 s after a telegraph, remove every stack and curse on the holder | Needs rule (effects.md rule 9a) | Lustral Bell art | deity-warden | any cleanser boss |

## Enablers

| ID | Name (Hán-Việt) | Kind | Lives on | Opens | Closes | Fit | Used by |
|---|---|---|---|---|---|---|---|
| nine-gate-seal | Nine-Gate Seal (Cửu Quan Ấn) | Rule swap | named artifact | the phase clock and the purge bell | the Toll gap; nothing carries across a swap | Needs rule | deity-warden |

## Artifacts, talismans, pills, formations

| ID | Name (Hán-Việt) | Type | What it does | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| turning-key | Turning Key (Chuyển Quan Thược) | artifact, utility | the holder swaps their ward model once per fight, with a 2 s ward gap | Needs rule | deity-warden | boss reward |
| toll-array | Toll Array (Đối Quan Trận) | formation | 25 % more damage for 4 s after an enemy ward swap (L4) | Needs key | deity-warden | player counter |

## Công pháp

| ID | Name (Hán-Việt) | Kind and tier | What it gives | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| cuu-quan-kinh | Nine Thresholds Scripture (Cửu Quan Kinh) | main, tier 5 | regen +7 %, art cost −30 %, health +20 %, abilities Gate Turning and Lustral Toll | Needs key | deity-warden | budget not assessed |

## Arts

| ID | Name (Hán-Việt) | Source | Kind, tags | c_art / cost / cooldown | Rule | Fit | Used by |
|---|---|---|---|---|---|---|---|
| gate-hammer | Gate Hammer (Quan Chùy) | scripture | body, Earth, slam | 3.4 / 0.05 / 6 s | plain hit | Needs key | deity-warden |
| closing-palm | Closing Palm (Hợp Chưởng) | scripture | qi, Metal, palm | 2.4 / 0.04 / 3 s | 3 Metal phys-taken stacks for 10 s | Needs key | deity-warden |
| lustral-bell | Lustral Bell (Tẩy Chung) | Lustral Toll | qi, Metal, bell | 1.0 / 0.03 / 10 s | 1.5 s telegraph, then strips stacks and curses | Needs rule | deity-warden |
| deaf-verdict | Deaf Verdict (Tuyệt Thính Phán) | scripture | soul | soul / 0.04 / 8 s | guard: Deaf Gate phase only | Needs rule | deity-warden |
| open-hand-reckoning | Open Hand Reckoning (Khai Chưởng Phán) | scripture | body, Earth | 3.0 / 0.05 / 5 s | guard: Open Hand phase only | Needs rule | deity-warden |

## Đạo pieces

| ID | Name (Hán-Việt) | Way and facet | Kind | What it does | Fit | Used by |
|---|---|---|---|---|---|---|
| luan-nien-gate | Turning Year cluster (Luân Niên) | Tứ Thời Đạo, Luân Niên | cluster idea | Fast-Art Ward, Lustral Share, ward-swap capability | Needs rule | deity-warden |

## Concepts and keys

| ID | Name | Kind | What it is | Fit | Used by |
|---|---|---|---|---|---|
| phase-script | Phase script (Luân Môn) | concept | an NPC carries up to four phases, each with a duration, a ward model and stat swaps | Needs rule (combat.md rule 10, combat-defence.md rule 1) | deity-warden |
| ward-swap-gap | Ward-swap gap (Toll) | concept | a swap discards old ward capacity and leaves a ward-less window | Needs rule (combat-defence.md rule 1) | deity-warden |

## Reused

| ID | Found in |
|---|---|
| boss-readable | staging |
| cleanser-telegraph | staging |
| cleansed-stacks-event | staging |
| rolling-refresh | staging |
| tally-ten | staging |
| quiet-mirror-talisman | staging |
| Unyielding Breath | tree catalogue |
| Heavy Hand | tree catalogue |
| Sheathed Blade | tree catalogue |
| Twin Wards | tree catalogue |
| Spirit Severing | tree catalogue |
| Seeing Eye | tree catalogue |
| Against the Heavens | tree catalogue |
| Bare Vessel | content ledger |
| Spillover | content ledger |

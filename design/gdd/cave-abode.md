# Cave Abode & Home Works (Động Phủ)

> **Status**: In Review (revised 2026-11-21 after design-review round 4)
> **Author**: user + Claude
> **Last Updated**: 2026-11-21
> **Last Verified**: 2026-11-21
> **Implements Pillar**: 3 (Power Is Built, Not Given), 4 (Every Season Counts), 2 (Every Number Is Bounded and Visible)
> **Creative Director Review (CD-GDD-ALIGN)**: REVISED 2026-11-21 — Pillar 1 concern (everyone building the same four works) answered by a catalogue diversity requirement in Open Questions 2 and 5

## Summary

The cave abode (động phủ) is a cultivator's own base and the home of layer 1 of the land: the personal works that raise the density and element match at their home for them alone. An abode has a grade from 1 to 5 that sets how many works it can hold, so choosing what to raise (a tended cave, a spring, a focus array, Formations' standing arrays, a field) is a build decision. It costs seasons and upkeep that scale with realm, which gives high-realm linh thạch a lasting, visible sink (Pillars 3, 4, 2). Travel & Map keeps the four-layer stack and its caps; this system supplies layer 1's contents.

> **Quick reference** — Layer: `Feature` (inferred; no systems index row yet) · Priority: `Alpha` (proposed) · Key deps: `Travel & Map, Formations, Regional Economy, Sects, Realms, Item Database, Character Stats`

## Overview

The cave abode (động phủ) is a cultivator's own base: a place they open on wild land or take over from a ruin, and the one home where their personal works stand. This GDD owns the abode and **layer 1 of the land**, the **home works**. These are the improvements that raise the density and element match at the owner's home for the owner alone: a tended cave, a private spring, a focus array, the standing arrays of Formations (Tụ Linh and the others) and private fields. Travel & Map keeps the four-layer stack and its caps (Formula B), the shared works of layer 2 and the production of places. This GDD supplies layer 1's contents to that stack.

A home is where a character cultivates, brews, grows herbs and keeps their arrays. The abode takes seasons and linh thạch to open and raise, costs upkeep to keep up, and fades if it is left. It is also the sink for linh thạch that high realms hold unspent.

**Player fantasy:** the hermit's home that grows with its owner. It begins as bare rock on a good tile and, season by season, becomes a place tuned to their root and their build: the right element pushed up, the density worth a Core Formation breakthrough, the arrays humming. Choosing what to raise first, and what to let go, is a build decision (Pillar 3); the time and stones it takes make it matter (Pillar 4); and every line of what it gives is on the stat block (Pillar 2).

## Detailed Design

### Core Rules

All fractions and counts are **guesses** for the balance harness.

1. **The abode is a record.** A character has one **home** at a time (Travel & Map rules 8, 32): a self-built cave abode, a rented or bought residence (rule 34), or a claimed abode (rule 11). The home record holds its **grade** (1–5), its **works** (each with a level) and the seasons its upkeep has been unpaid. Everything below happens at the home only.
2. **One ladder of grades.** A self-built abode starts at grade 1; a claimed one starts at F4's `grade_after` (rule 11). Either is raised one grade at a time. A settled residence's grade is the one it was rented or bought at (Travel & Map rule 34), capped by its place kind (village 2, town 3, market and city 4, sect seat 5). Grade 4 needs Core Formation and grade 5 Nascent Soul to hold (`grade_realm_min`, the same minimums as residences).
3. **Grade sets slots and the level ceiling.** The abode has `slots_by_grade[grade]` work slots (guess 2 / 3 / 4 / 5 / 6). A work's level cannot exceed `grade + 2` (Formulas F3), nor its own `max`; with grade + 2, level-5 works are reachable at grade 3, so today's early-game density is unchanged. The catalogue is larger than the slots, so which works to hold is the decision. A work takes `slots` slots (default 1; a big work may take 2), and holds them from the season its building starts.
4. **The home-work catalogue.** A home work is a record with `id`, `stat`, `kind` (permanent or upkept), `max`, per-level gain, cost, upkeep, `slots` and any condition. It is one of:
   - the **layer-1 works** of `map_works.json` (`tended_abode`, `private_spring`, `focus_array`, and later ones), whose records this GDD now owns;
   - the **standing arrays of Formations** (Tụ Linh, Thanh Mộc, Hộ Sơn): their records, build cost, upkeep and skill cap stay Formations' (Part II, F3), and each takes one slot here;
   - a **field** (rule 5).
5. **Fields take a slot.** A private field is a home work that holds one slot and has an upkeep. What it grows, how herbs age and Thanh Mộc's growth bonus stay with Spirit Herbs & Fields (#14). This GDD defines no herb output.
6. **Raising the grade** (self-built and claimed abodes; a rented or bought residence's grade is fixed by the residence, and getting a better one means renting a better one). A grade is raised at the home with seasons and linh thạch: `grade_cost = linh_thach_max[realm] × grade_cost_frac[grade]` (a realm-scaled share) and one season per grade. A raise to grade g also needs a realm that can hold g (rule 2), or it is refused and nothing is spent. **Timing:** the stones are paid when the raise starts; the new grade's slots, level ceiling and upkeep apply from the next season (the old grade holds in between). Opening an abode still costs Travel & Map's `abode_cost_frac`, paid at the start, and the abode is Open from that season. The **entry works keep their flat prices**; only the grade ladder and the abode's own upkeep (rule 8) scale with realm.
7. **Building and raising works** is as today: at the home only, spending seasons, linh thạch and materials (`MapWorks.build`), within the level ceiling (rule 3) and the free slots. Layer 1's contribution to Formula B is still capped there (`c1p`, `c1u`, share and match caps); this GDD never changes those caps.
8. **Abode upkeep** (self-built and claimed abodes; a residence pays rent under Travel & Map Formula M instead of the grade upkeep, and the upkeep and fade clocks of its upkept works still apply). Each season the home pays `grade_upkeep = linh_thach_max[realm] × upkeep_frac[grade]` (a realm-scaled share, cut by Thổ purity as upkept works are today) plus the upkeep of its upkept works, except Formations' standing arrays, whose upkeep stays on Formations' yearly tick (Formations rule 14). This is the perpetual sink. The fade clock counts **consecutive** unpaid seasons of the grade upkeep (Formulas F2). At `grade_fade_seasons` the grade drops by one and the clock resets to 0, so a further `grade_fade_seasons` unpaid seasons drop it again; any paid season resets the clock. **Grade 1 is a floor:** an unpaid grade-1 abode stays the owner's home (Neglected) and its grade never drops below 1; only its upkept works fade, on their own clocks. A home becomes Left only when the owner moves away (rule 10).
9. **Dormant works.** If the grade falls and the works exceed the slots, the owner chooses which works go **dormant** (default, and the choice for an owner who does not pick before the next season: the most recently built, whole works only; a 2-slot work counts by its slots). Dormancy is only ever forced by a lost slot, never chosen to dodge upkeep or fading. A dormant work keeps its level, counts for nothing and costs no upkeep, and is brought back when a slot is free, earliest built first **that fits** (a 2-slot work waiting for a second free slot does not block a 1-slot work behind it). A dormant work's own fade clock is frozen. **Level ceiling after a fall:** a work whose level exceeds the lower ceiling keeps its stored level but counts, and is upkept, at `min(level, ceiling)`; it counts fully again when the grade is raised.
10. **Leaving a home** is Travel & Map's rule 32: the works stop counting and upkept ones start fading; permanent works stay with the place. A self-built or claimed abode is then **left**, with its grade recorded and its grade fade clock set to 0. If its owner dies instead, its upkept works start fading the same way (death is treated like leaving) and the abode is a Ruin; fading stops only when it becomes a hidden place (frozen). A rented or bought residence is never Left or claimable: it goes back to its holder (Travel & Map rule 34).
11. **Claiming a left abode.** Anyone may claim a left or ruined abode they can reach for half the opening fee and one season. It keeps its permanent works, its faded upkept works are gone, Formations' standing arrays included (Formations rule 14) (an upkept work that had only partly faded keeps its reduced level), and it comes back at its **old grade minus one** (minimum 1), but never above the highest grade the claimant's realm can hold (`grade_realm_min`); works beyond the slots go dormant (rule 9). The fee is priced at the claimant's realm when paid. A Ruin may instead become a hidden place (Travel & Map rule 15), and a claim there follows the same terms. **Timing:** the fee is paid when the claim starts, the claimant's home is the claimed abode from that payment (the old home becomes Left that season), the grade fade clock is set to 0, and the abode is Claimed for that one season; its grade upkeep falls due from the next season.
12. **NPC abodes.** A hermit's or loose cultivator's home has a grade like any other. Each season an NPC with enough stones may raise it (a chance, as sects' works are), booked as one aggregate in Regional Economy Formula H and not simulated work by work. Each NPC pays its raise and its F2 grade upkeep from its own purse, and the aggregate is the sum of those payments; an NPC that cannot pay counts an unpaid season on its own fade clock (rule 8) and loses a grade by it, so the purse bound below never forgives an individual's upkeep; NPC abodes have no simulated works or dormancy. The top grade an NPC's realm allows is 3 below Core Formation, 4 at Core Formation and 5 from Nascent Soul (`grade_realm_min`). The aggregate is bounded by construction by the purses (each NPC pays at most what its own purse holds, so the sum never exceeds the NPC purse pool); the only reserve is the per-NPC raise gate `npc_reserve_mult` (F5), and upkeep may draw a purse down to 0. When a hermit dies their abode becomes a Ruin record (a claim target, rule 11).
13. **Visibility** (Pillar 2). The stat block lists the abode's grade, slots used out of available, each work with its level and gain, each dormant work, the grade upkeep and any layer-1 cap that clamps a gain (as Travel & Map's lines show clamps).
14. **Stones spent on the abode itself** (grade raises, grade upkeep and claims) are a sink booked in Regional Economy Formula H as `burn_abode`, which is exactly what Formula H defines it as. Formations' standing arrays and diagrams are `burn_formation` (their build, raise and upkeep stones; Formations rules 14, 17) and are never booked as `burn_abode`; the other layer-1 works, fields and the opening fee are paid by the player alone (rule 12 gives NPCs no works) as purchases inside `player_net`, with no Formula H burn line, so they add no `burn_abode` entry. A player's `burn_abode` spend is also a purchase inside `player_net`, so it cancels in `M'` and `M` (which excludes the player) is untouched; an NPC's spend is a true burn of `M`. Linh thạch stays money only: no stat is priced in stones.

### States and Transitions

**The abode (per home record)**

| State | Meaning | Becomes | When |
|---|---|---|---|
| Open | A home at grade g, upkeep paid. **Initial state:** a newly opened abode starts Open, and so does a claimed one after its claim season | Neglected; Left; Ruin | Grade upkeep unpaid this season; the owner moves; the owner dies |
| Neglected | Upkeep unpaid since the last paid season, the clock at 1 to `grade_fade_seasons − 1` (at grade 1, any number); works still count | Open; Fallen; Left; Ruin | Paid; the clock reaches `grade_fade_seasons` (grade 2+); the owner moves; the owner dies |
| Fallen | A one-season event, not a resting state: the grade is lowered by one and the clock resets to 0 | Neglected (still unpaid, the next unpaid season counts as 1) or Open (paid); Left; Ruin | The next season; the owner moves or dies in it |
| Left | The owner moved away (a self-built or claimed abode); grade clock 0 | Claimed; Ruin | Someone claims it; or its last owner dies (Ruin) |
| Ruin | The last owner is dead, nobody home (reached from Open, Neglected, Fallen, Claimed or Left on death) | Claimed; Hidden place | A claim; or it becomes a hidden place (Travel & Map rule 15) |
| Hidden place | A frozen Ruin: grade and works fixed at the last recorded state | Claimed | A finder claims it (rule 11) |
| Claimed | Taken over at old grade − 1; one season | Open; Left; Ruin | The claim season passes; the owner moves; the owner dies |

**A home work (per work)**

| State | Meaning | Becomes |
|---|---|---|
| Building | In its building season(s); holds its slots from the start | Active |
| Active | Counts, within the cap | Fading (upkept, unpaid, or the home was left or its owner died); Dormant (slot lost); Building (a level is being raised: it keeps counting at its old level meanwhile) |
| Fading | Upkept work, upkeep unpaid | Active (paid); level − 1 every `fade_seasons`; gone at 0; Dormant (slot lost, its fade clock frozen) |
| Dormant | Kept at its level, counts for nothing, no upkeep, fade clock frozen | Active (a slot is free; earliest built that fits) |

### Interactions with Other Systems

| System | Direction | What flows | Owner of the interface |
|---|---|---|---|
| Travel & Map #25 | out | `ΔD1p`, `ΔD1u`, layer-1 share and match from the active works, for Formula B; the home record | Travel & Map owns Formula B and every cap; this GDD owns layer 1's contents and the slot rules |
| Travel & Map #25 | in | Abode opening (rule 8, Formula M), home states (rule 32), residence grade and rent (rules 33–34), the layer-1 caps, `grade_realm_min` | Travel & Map |
| Formations #17 | in | The standing arrays' records, build cost, upkeep and skill cap; each takes one slot | Formations owns the arrays; this GDD owns the slot |
| Spirit Herbs & Fields #14 | in | What a field grows, herb ageing, Thanh Mộc's growth bonus | #14 (built, no GDD) |
| Item Database #13 | in | Materials for works (`rarity_min`) | Item Database |
| Character Stats #7 | in | Thổ purity (the upkeep cut), realm | Character Stats |
| Time & Turn #4 | in | The season, the upkeep tick, building seasons | Time & Turn |
| Regional Economy #43 | out | Every stone spent, booked as a sink in Formula H (NPC abodes as an aggregate) | Regional Economy owns the ledger |
| Sects #26 | in/out | Sect founding needs an abode at stacked density ≥ `seat_density` (rule 29); sects decide whether they object to, tax or evict an abode on their land | Sects |
| Realms #8 | in | The realm that scales the grade costs and gates grades 4 and 5 | Realms |
| World Database | out | Home records, grades, works, left and ruined abodes | World Database (storage) |
| Living World Tick #28 | in | The seasonal upkeep, NPC upgrade chances | Living World Tick |
| Game UI #37 | out | The abode stat block and the work and grade menus | This GDD owns the data; UI owns layout |

Sects' `seat_density` (≥ 1.5, rule 29) reads the abode's stacked density, so the layer-1 caps and the slot limit decide who can found a sect from an abode. It needs no change; it is recorded for the review.

## Formulas

Starting values are **guesses** for the balance harness to derive. The one measured number behind the sizing: Nascent Soul and Hóa Thần lives end with about 1–4 million linh thạch unspent (`production/plans/world-economy.md`, decision 7), against a `linh_thach_max` of 40,000 and 300,000.

### F1. Raising the grade (self-built or claimed abodes only)

The grade_cost formula is defined as:

`grade_cost(g) = round(linh_thach_max[realm] × grade_cost_frac[g])` linh thạch and one season, for g = 2…5. Grade 1 costs only the opening fee (Travel & Map Formula M).

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| g | int | 2–5 | home record | The grade being reached |
| grade_cost_frac[g] | float | 0.25 / 0.75 / 2.0 / 5.0 | data file *(guess)* | Share of the owner's realm budget |
| linh_thach_max[realm] | int | 80 / 600 / 5,000 / 40,000 / 300,000 | `events_budgets.json` | The owner's realm at the moment of paying |

**Output Range:** 20 stones (grade 2 at Qi Refining) to 1.5 million (grade 5 raised at Hóa Thần).
**Example:** Core Formation, grade 3: 5,000 × 0.75 = **3,750**. Nascent Soul, the whole ladder 2→5: 40,000 × 8.0 = **320,000**.

### F2. Abode upkeep per season (self-built or claimed abodes; a residence pays rent instead)

The grade_upkeep formula is defined as:

`grade_upkeep(g) = max(1, ceil(round(linh_thach_max[realm] × upkeep_frac[g] × (1 − tho_cut), 6)))` (rounded to 6 decimals before `ceil`, against float error), with `tho_cut = clamp(Thổ purity × 0.004, 0, 0.9)`; unpaid for `grade_fade_seasons` consecutive seasons, the grade drops by one and the clock resets (grade 1 never drops; rule 8)

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| upkeep_frac[g] | float | 0.0005 / 0.001 / 0.0025 / 0.005 / 0.01 | data file *(guess)* | Share of the realm budget per season, grades 1–5 |
| grade_fade_seasons | int | 4 | data file *(guess)* | Unpaid seasons before the grade drops one (a work keeps its own `fade_seasons`) |
| tho_cut | float | 0–0.4 in play (0.9 guard) | `map_works.json` (`tho_upkeep_cut_per_purity`) | The Earth discount works already use |

**Output Range:** 1 stone a season (grade 1, Qi Refining) to 3,000 (grade 5, Hóa Thần).
**Example:** Nascent Soul, grade 5: 40,000 × 0.01 = **400 a season**, about 1,600 a year, roughly **480,000 over three centuries**. This running cost absorbs surplus more than the one-off ladder does.

### F3. Slots and the level ceiling

The slot_limit formula is defined as:

`slots(g) = slots_by_grade[g]`; a work's level ≤ `min(work.max, g + level_margin)`; the works held take `Σ work.slots ≤ slots(g)`.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| slots_by_grade[g] | int | 2 / 3 / 4 / 5 / 6 | data file *(guess)* | Work slots at grade g |
| level_margin | int | 2 | data file *(guess)* | Level ceiling above the grade; 2 lets level-5 works stand at grade 3 |
| work.max, work.slots | int | 1–5 (7 for Tụ Linh under Capability #15); 1 (2 for a big work) | `map_works.json` | The work's own maximum level and slot cost |

**Output Range:** 2 to 6 slots; a level ceiling of 3 (grade 1) to 7 (grade 5), after each work's own `max`. **Example:** grade 3 has 4 slots; Tụ Linh Trận level 5 is allowed (3 + 2 = 5) and uses 1 of them.

### F4. Claiming a left abode

The claim_fee formula is defined as:

`claim_fee = round(linh_thach_max[claimant realm] × abode_cost_frac × claim_frac)`; `grade_after = min(max(1, grade_before − 1), top_grade[claimant realm])`, where `top_grade` is 3 below Core Formation, 4 at Core Formation and 5 from Nascent Soul

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| abode_cost_frac | float | 0.05 | Travel & Map Formula M (registered) | Opening cost share |
| claim_frac | float | 0.5 | data file *(guess)* | Share of the opening cost a claim pays |
| grade_before | int | 1–5 | home record | The recorded grade of the Left abode |

**Output Range:** 2 stones (Qi Refining) to 7,500 (Deity Transformation); the grade after is 1 to 4.
**Example:** Core Formation: 5,000 × 0.05 × 0.5 = **125**.

### F5. NPC raising their abode

The npc_raise rule is defined as: each season an NPC at grade g below the top grade its realm allows, whose purse at the start of the season, before that season's upkeep, ≥ `grade_cost(g+1) × npc_reserve_mult`, raises it when its seasonal roll `< npc_raise_p`. The cost is booked in Formula H as one aggregate.

**Variables:**
| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| npc_reserve_mult | float | 2 | data file *(guess)* | Purse needed, in multiples of the raise cost, so an NPC keeps a reserve |
| npc_raise_p | float | 0.05 | data file *(guess)* | Chance per season once affordable |

**Output Range:** an NPC reaches a grade about 20 seasons after it can afford it. **Example:** a Core Formation hermit with 8,000 at grade 2 (cost 3,750 × 2 = 7,500 needed) raises it with chance 0.05 that season.

### Boundary and loop checks

- **Grade 1:** grade 1 has no raise cost; upkeep is clamped to at least 1; slots never fall below 2.
- **Unaffordable upkeep:** a poor owner's abode falls one grade after each `grade_fade_seasons` consecutive unpaid seasons and stops at grade 1, which stays their home, so the sink cannot push anyone below grade 1, out of their home or into debt.
- **Thổ at 100 purity:** the cut is 100 × 0.004 = 0.4 at most (the 0.9 clamp is only a guard), so upkeep never falls below 60 % of the base and never reaches 0.
- **Positive loop:** richer → higher grade → more slots → more arrays and fields → richer. It is bounded: density and match are capped by Travel & Map Formula B (`c1p` 0.1 and `c1u` 0.75, about 0.85 density, plus 0.30 on `c1u` only where Capability #15 applies), so the late grades buy utility, not cultivation speed, and cannot break the Core Formation gate.
- **Dominant purchase:** none for density at the base caps, since grade 3's four slots already hold the works that fill them. Grades 4–5 add Hộ Sơn, Thanh Mộc and fields, and (with Capability #15's two extra Tụ Linh levels) the level ceiling `grade + 2` is what lets levels 6 and 7 stand at grades 4 and 5.
- **Early raises:** grades 2 and 3 cost little at a low realm, because the price follows the realm at the moment of paying. This is accepted: the upkeep still follows the current realm and grows with it.
- **Faucet:** none in this GDD. Field output belongs to Spirit Herbs & Fields (#14).

## Edge Cases

**Grade, slots and works**

- **If a work would exceed its level ceiling or no slot is free**: the build is refused with the reason (ceiling or slots) and nothing is spent.
- **If the grade falls below what the works need** (neglected upkeep, or a claim at grade − 1): the owner picks which works go dormant, defaulting to the most recently built (also the default for a headless run), before the next season starts. The dormant ones keep their levels and count for nothing.
- **If a dormant work's slot opens again**: it comes back at its kept level at once, and upkeep resumes the same season.
- **If layer 1 would pass a Formula B cap** (the density, share or match cap): the gain is clamped, and the stat block shows the clamp as a line. Slots and stones spent past the cap still count; nothing refunds them.
- **If two works push the same cap** (Tụ Linh and `tended_abode` both add density): each counts toward its own cap (upkept 0.75, permanent 0.1); nothing is shared across caps.
- **If a standing array's Trận Pháp skill cap is lower than the work's level ceiling**: the skill cap wins (Formations F3), and the lower level counts.

**Money and upkeep**

- **If the grade upkeep and the works' upkeep can't both be paid**: the abode's own grade upkeep is paid first, then the works' upkeep in the order they were built. An unpaid item starts its own fade clock; the others are unaffected.
- **If the owner's realm rises after a grade was raised**: nothing is re-priced. Upkeep follows the **current** realm's `linh_thach_max`, so it grows with the realm; a rich old hermit pays the most, intended.
- **If the owner is in a sect that pays or taxes the abode**: Sects decides (Travel & Map's edge case on abodes in a sect's territory). This GDD adds no second charge.

**Moving, leaving and claiming**

- **If the owner moves home**: a self-built or claimed abode becomes Left at its current grade (recorded), its upkept works start fading, and its permanent works stay. A rented or bought residence returns to its holder and is never Left. Slots at the new home start empty.
- **If a rented residence's grade is fixed and the owner wants more slots**: rent a higher-grade residence or open an abode. No raise is possible, and the menu says so.
- **If two characters claim the same left abode**: the first to pay wins; the second is refused. A **small blessed land** claim follows Travel & Map's one-holder rule.
- **If a claimed abode's old grade was 1**: it stays 1, and like any grade-1 abode it stays the owner's home when upkeep goes unpaid (rule 8).
- **If a claimant's realm is below the old grade's minimum**: the abode comes back at the highest grade the claimant's realm can hold (F4), and the works beyond its slots go dormant.
- **If the owner dies**: the abode becomes a Ruin directly (the last owner is dead). An heir does **not** inherit it; an heir may claim it under rule 11 like anyone else, at grade − 1 and half the fee.
- **If a work's level exceeds the ceiling after a grade fall**: it counts at the ceiling and keeps its stored level (rule 9).
- **If the ruin becomes a hidden place**: its works and grade freeze at the last recorded state and wait for a finder to claim it.

**NPCs**

- **If an NPC cannot afford `grade_cost × npc_reserve_mult`**: no raise is attempted that season and no raise cost is booked (its grade upkeep is still paid).
- **If an NPC's realm is too low for the next grade** (grade 4 needs Core Formation, grade 5 Nascent Soul): the raise is not attempted.
- **If a sect leader or member lives at the seat**: they are not an abode owner; the seat's residences follow Travel & Map's rules 33–34.

**Interactions**

- **If a sect's `seat_density` check (Sects rule 29) reads an abode with dormant works**: dormant works count for nothing, so density falls and the founder may fail the check until a slot opens.
- **If a field's herbs are in the ground when the field goes dormant**: they are handled by Spirit Herbs & Fields (#14), which owns herb ageing and harvest. This GDD only stops the field's per-season upkeep.

## Dependencies

| System | Type | Interface | State | Lists Cave Abode? |
|---|---|---|---|---|
| Travel & Map (#25) | Hard | Layer-1 contribution to Formula B; abode opening, home states, residence grades and rent, the layer-1 caps | GDD designed, revised 2026-11-13 | Yes (added 2026-11-21) |
| Formations (#17) | Hard | The standing arrays as home works, each taking a slot | GDD designed 2026-11-21 | Yes (added 2026-11-21) |
| Regional Economy (#43) | Hard (out) | Stones spent, booked in Formula H (grade raises, upkeep, claims, NPC aggregate) | GDD approved | Yes (added 2026-11-21, `burn_abode`) |
| Sects (#26) | Soft | Founding needs an abode at `seat_density` (rule 29); sects' say over abodes on their land | GDD approved | Yes (added 2026-11-21) |
| Realms & Bottlenecks (#8) | Soft | The owner's realm scales the costs and gates grades 4 and 5 | GDD in review | Yes (added 2026-11-21) |
| Item Database (#13) | Soft | Materials for works | GDD complete | n/a (reads only) |
| Character Stats (#7) | Soft | Thổ purity, realm | GDD in review | n/a (reads only) |
| Spirit Herbs & Fields (#14) | Soft | What a field grows; ageing; Thanh Mộc's bonus | Built, no GDD | n/a |
| Time & Turn (#4) | Soft | The season tick | Built, no GDD | n/a |
| Living World Tick (#28) | Soft | The seasonal upkeep and NPC raises | GDD designed 2026-11-15 | Needs a note when reviewed |
| World Database (#3) | Soft | Home records, grades, works | Built, no GDD | n/a |
| Game UI (#37) | Soft | The abode screen | Not started | Index |

**Circularity:** none added. This GDD reads Travel & Map's caps and Formations' records, and supplies layer-1 values to Formula B, which never writes back.

The five back-links (Travel & Map, Formations, Regional Economy with `burn_abode` in Formula H, Sects and Realms) were added on 2026-11-21.

## Visual/Audio Requirements

Art bible §1–4 are still placeholders; this section draws on §7 and the pillars.

- **Terminal today.** The abode prints as a header (grade, slots used out of available, upkeep per season) and a table of works: name, level, gain, state (active, fading, dormant). Clamp lines print under the stat block. No state depends on colour alone.
- **Game UI intent.** The abode is a small ink-wash grotto, one picture that gains detail by grade: bare rock at grade 1, a tended cave at 2–3, carved gates and arrays at 4–5. Works sit as round medallions in slots, using the Đạo Đồ node grammar (bronze ring frames, art bible §7.9, in-engine states only per §7.7). Dormant works are dimmed and keep their ring; fading works carry a shape mark, not only a colour.
- **Events that need a visual and a sound later:** opening an abode, raising a grade, a work finishing, a work fading, a work going dormant, claiming a ruin.

## Game Feel

The abode is the slow, quiet counterweight to fights: **the moment that matters is seeing your home grow after a long stretch of seasons.**

- **Before:** the grade and slot screen shows what the next grade buys and costs, so the player plans.
- **During:** nothing is real-time; building a work or a grade takes seasons, shown on the season summary.
- **After:** when upkeep goes unpaid the screen says which work is fading and in how many seasons, so a loss of grade is never a surprise (Pillar 2).

## UI Requirements

| Screen or element | Must show | Must allow |
|---|---|---|
| Abode screen | Grade, slots used out of available, each work with level, gain, state, upkeep, the clamp lines, the next grade's cost and upkeep | Build or raise a work; raise the grade; choose dormant works when a slot is lost (rule 9); leave the abode |
| Work picker | The catalogue: each work's gain, cost, upkeep, slots and the level ceiling at this grade | Choose a work and an element (for share works) |
| Claim screen | A found or known Left abode: its recorded grade, the grade it would come back at, works kept, fee | Claim it |
| Season summary | Upkeep paid, works fading, grade falls | Open the abode screen |

All of these work in the debug terminal first, with numbered menus.

> **📌 UX Flag — Cave Abode:** this system has UI requirements. In Pre-Production, run `/ux-design` for the abode screen and the work picker before writing epics. Stories that touch this UI should cite `design/ux/[screen].md`, not this GDD.

## Cross-References

| This GDD | References | What |
|---|---|---|
| Rules 1, 10, 11 | Travel & Map rules 8, 15, 32; Formula M | Opening, home states, hidden places, `abode_cost_frac` |
| Rules 2, 6; F1 | Travel & Map rules 33–34; Formula M | Residence grades, `grade_realm_min`, rent |
| Rule 7; F3 | Travel & Map Formula B | Layer-1 caps (`c1p`, `c1u`, share and match) |
| Rule 4 | Formations Part II, F3 | Standing arrays as home works; the skill cap |
| Rule 5 | Spirit Herbs & Fields (#14) | Field mechanics |
| Rules 6, 8, 14; F1, F2 | Regional Economy Formula H | The sink ledger |
| F1, F2, F4 | `events_budgets.json` (`linh_thach_max`) | The realm budget scaling |
| Rule 8; F2 | `map_works.json` (`tho_upkeep_cut_per_purity`) | The Earth discount |
| Rule 12; F5 | Living World Tick | The seasonal NPC step |
| Edge cases | Sects rule 29 | The sect-founding abode check |

## Acceptance Criteria

**Core rules**

- **AC-CA-01** [Logic] Rule 1. **GIVEN** a self-built home at grade 3, **WHEN** the owner opens or claims another, **THEN** the old one becomes Left at grade 3 and only the new one is the home. **GIVEN** a rented residence, **WHEN** the owner moves, **THEN** it returns to its holder and is not Left or claimable.
- **AC-CA-02** [Logic] Rule 2. **GIVEN** a Foundation Establishment character with a self-built grade-3 abode, **WHEN** raising to grade 4, **THEN** it is refused (needs Core Formation) and nothing is spent. **GIVEN** a village residence, **WHEN** a grade-3 rental is requested, **THEN** it is refused and a grade of at most 2 is offered.
- **AC-CA-03** [Logic] Rule 3, F3. **GIVEN** grade 3 (4 slots), **WHEN** a fifth one-slot work is built, **THEN** it is refused for slots and nothing is spent. **GIVEN** grade 1, **THEN** no work exceeds level 3 and grade 3 allows level 5 (`grade + 2`).
- **AC-CA-04** [Logic] Rule 4. **GIVEN** Tụ Linh Trận built as a home work, **THEN** it uses 1 slot, and a 2-slot work uses 2.
- **AC-CA-05** [Logic] Rule 5. **GIVEN** a field in a slot, **THEN** its upkeep bills each season, and **WHEN** it goes dormant **THEN** the upkeep stops.
- **AC-CA-06** [Logic] Rule 6, F1. **GIVEN** a Core Formation owner at grade 2, **WHEN** raising to grade 3, **THEN** 3,750 stones are paid and one season passes. **GIVEN** `tended_abode` level 1, **THEN** it costs 300 at any realm (entry works stay flat).
- **AC-CA-07** [Logic] Rule 6. **GIVEN** a rented grade-3 residence, **WHEN** the owner tries to raise it, **THEN** it is refused with the reason "the residence's grade is fixed" and nothing is spent.
- **AC-CA-08** [Integration] Rule 7, Travel & Map Formula B. **GIVEN** an upkept density work with a raw gain of 0.9 and a fixture permanent work with a raw gain of 0.2 (the catalogue's `tended_abode` tops out at 0.06), **THEN** layer 1's density is 0.75 + 0.1 = 0.85 (each cap separately) and the stat block shows two clamp lines. **GIVEN** Tụ Linh at level 5 (exactly 0.75), **THEN** no clamp line prints.
- **AC-CA-09** [Logic] Rule 8, F2. **GIVEN** Nascent Soul and grade 5, **THEN** upkeep is 400 a season; with Thổ purity 75, **THEN** 280 (cut 0.3). **GIVEN** Qi Refining grade 1, **THEN** 1 (the minimum).
- **AC-CA-10** [Logic] Rule 8, edge. **GIVEN** stones for only the grade upkeep, **THEN** the grade upkeep is paid first and the works' upkeep starts its fade clock. **GIVEN** `grade_fade_seasons` (4) consecutive unpaid seasons at grade 3, **THEN** the grade drops to 2 and the clock resets; 4 more unpaid seasons drop it to 1; one paid season resets the clock. **GIVEN** grade 1 and any number of unpaid seasons, **THEN** the abode stays the owner's home at grade 1, only its upkept works fade, and it is not Left.
- **AC-CA-11** [Logic] Rule 9. **GIVEN** grade 4 with five works and a fall to grade 3 (4 slots), **THEN** the owner picks one dormant (default the latest built); it counts for 0, costs no upkeep, and **WHEN** a slot opens **THEN** it returns at its kept level the same season.
- **AC-CA-12** [Logic] Rule 10. **GIVEN** a home with `tended_abode` and Tụ Linh Trận, **WHEN** the owner moves, **THEN** the old abode is Left at its grade, Tụ Linh Trận starts fading, `tended_abode` (level 3, a permanent work) stays on the old record and adds 0 to the owner's layer-1 density at the new home, and the new home has no works.
- **AC-CA-13** [Logic] Rule 11, F4. **GIVEN** a Core Formation claimant and a Left grade-3 abode, **THEN** the fee is 125, one season passes, and the grade is 2 with permanent works kept and faded upkept works gone. **GIVEN** an old grade of 1, **THEN** 1. **GIVEN** two claimants, **THEN** the first to pay wins and the second is refused. **GIVEN** a Qi Refining claimant and a Left grade-5 abode, **THEN** the grade after is 3 (the top grade below Core Formation) and works beyond its 4 slots go dormant. **GIVEN** a Ruin, **THEN** the same terms apply.
- **AC-CA-14** [Logic] Rule 12, F5. **GIVEN** an NPC with a purse of exactly 2 × `grade_cost(g+1)` and room under its realm's top grade, **WHEN** the injected roll is 0.049 (`< npc_raise_p` 0.05), **THEN** it raises and the cost is booked in the one aggregate; **WHEN** the roll is 0.050, **THEN** it does not. Fixture: a Core Formation hermit at grade 2 (`grade_cost(3)` = 3,750), purse 7,500 raises at roll 0.049 and not at 0.050; purse 7,499 never raises. **GIVEN** an NPC that cannot pay its grade upkeep, **THEN** only its own fade clock advances and the aggregate is the sum of what each NPC paid. **GIVEN** (Thổ purity 0) NPC A, Core Formation at grade 2, purse 7,500, roll 0.049, and NPC B, Core Formation at grade 2, purse 0, **THEN** A pays the 3,750 raise plus the grade-2 upkeep of 5 (the old grade holds, rule 6), B pays 0 and advances only its own fade clock, and the season's aggregate is 3,755, never more than the sum of the purses (7,500). **GIVEN** a purse below the gate, or a realm too low for the next grade, **THEN** no raise is attempted and no raise cost is booked; the grade upkeep is still paid.
- **AC-CA-15** [Logic] Rule 13. **GIVEN** a home, **THEN** the stat block shows the grade, slots used out of available, each work's level and gain, each dormant work, the grade upkeep and every clamp line.
- **AC-CA-16** [Integration] Rule 14. **GIVEN** a Core Formation player at purity 0 in season N who raises grade 2→3 (3,750) and pays the grade-2 upkeep that season (rule 6: the old grade holds, 5,000 × 0.001 = 5) and a standing array's upkeep, and in season N+1 pays grade-3 upkeep (5,000 × 0.0025 = 12.5, so 13), and in a separate later season claims an abode (125; the claimed abode owes no upkeep in its claim season, rule 11), **THEN** `burn_abode` receives the entries 3,750 and 5 (season N), 13 (season N+1) and 125 (claim season), the array's upkeep goes to `burn_formation` and never to `burn_abode`, the `burn_abode` amounts also appear in `player_net` as purchases, and Formula H's identity (`M' = M + F_mine − burn_works − burn_stone − burn_fees − burn_formation − burn_abode − burn_heirless − player_net`) leaves `M` unchanged for the player's share within 1e-6.

**Edge cases and cross-system**

- **AC-CA-17** [Logic] Edge (owner dies). **GIVEN** an owner's death, **THEN** the abode is a Ruin directly and an heir does not inherit it; the heir may claim it under rule 11 (AC-CA-13's terms).
- **AC-CA-18** [Integration] Sects rule 29. **GIVEN** a home at stacked density 1.52 with all works active, **WHEN** Tụ Linh at level 1 (0.15) goes dormant, **THEN** the density is 1.37 and the founder fails the `seat_density` 1.5 check until a slot opens.
- **AC-CA-19** [Integration] Formations F3. **GIVEN** a Tụ Linh work at level ceiling 5 and a Trận Pháp skill cap of 3, **THEN** the work counts at level 3.
- **AC-CA-20** [Logic] F1, F2 boundaries. **GIVEN** grade 1, **THEN** there is no raise cost and slots are at least 2. **GIVEN** Thổ purity 100 at Nascent Soul and grade 5, **THEN** the cut is 0.4 and upkeep is 240 (60 % of 400). **GIVEN** Qi Refining, grade 1 and Thổ purity 100, **THEN** upkeep is 1 (the floor). **GIVEN** a work above the ceiling after a grade fall, **THEN** it counts at the ceiling and keeps its stored level.

**Screens**

- **AC-CA-21** [UI] **GIVEN** the abode screen at grade 3 with a dormant work and a clamped cap, **THEN** a screenshot in `production/qa/evidence/` shows the grade, slots used, each work with its level and gain, the dormant one marked, the upkeep, and the clamp lines, without colour alone carrying any state.

**Gaps noted (not criteria):** the sink share (a late grade-5 abode absorbing about as much as the surplus the harness measures) is a harness check; the catalogue beyond the seven known works is unauthored; field output is Spirit Herbs & Fields' and has no criterion here.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | **Closed 2026-11-21:** back-links added in Travel & Map (rule 32 and Interactions), Formations (rule 14, Dependencies), Regional Economy (Formula H `burn_abode`), Sects (rule 29, Dependencies) and Realms (downstream row) | user | Done |
| 2 | The home-work catalogue beyond the seven known works: how many, which stats, which take 2 slots. **Diversity requirement (CD-GDD-ALIGN, Pillar 1):** the first authored catalogue must give at least two different best-in-slot sets per root element at grade 3, so that not every character builds the same four works | user (hand-authored) | Before implementation |
| 3 | Starting values (`slots_by_grade`, `grade_cost_frac`, `upkeep_frac`, `claim_frac`, `npc_raise_p`, `npc_reserve_mult`) and whether a grade-5 abode absorbs a meaningful share of the 1–4 million surplus | Balance Harness (#33) | Harness pass |
| 4 | Whether the grade ladder should be open-ended later, if grades 1–5 do not absorb enough | user | After the harness pass |
| 5 | Does the level ceiling `grade + 2` leave grades 4–5 with enough reason to exist for non-sink players? Check with the diversity requirement of question 2 (a harness count of how many characters hold each work set) | game-designer | With the first catalogue |
| 6 | Spirit Herbs & Fields (#14) has no GDD: the field's herb output, ageing and Thanh Mộc's bonus need one | user | When #14 is designed |
| 7 | Do heirs deserve a claim discount (a living heir of a dead owner), given NPC Relationships tracks heirs? | user | With NPC Relationships review |
| 8 | Sect-owned abodes and members' residences: who pays upkeep when a sect houses its members (Sects #26)? | Sects | With the Sects follow-up |
| 9 | **Back-links closed 2026-11-21:** Regional Economy AC-RE-07 now includes `burn_formation` and `burn_abode`; Living World Tick S6 names the abode upkeep and NPC raises. Game UI (#37) has no GDD yet, so the abode screen waits for it (UI Requirements). Harness watches: paying upkeep one season in four (3 unpaid + 1 paid never drops the grade; payment is automatic when the purse holds it), the claim fee ignoring the grade's stones, abandon-and-reclaim loops, the poverty spiral after a realm breakthrough | Regional Economy; Living World Tick; Balance Harness (#33) | With those reviews |

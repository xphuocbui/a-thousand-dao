# Đạo Ways: shared rule decisions

> The user's answers to `_shared-rules.md` R1–R22, taken one at a time on 2026-11-11. Each "yes" still has to be
> written into its owning GDD (section by section, user approves), and each Way that asked is then revised to point at
> it. Nothing here has been applied to a GDD yet.

| R | Decision | Details chosen | Owning GDD | Applied? |
|---|---|---|---|---|
| R1 Foe timers | **Yes, as proposed** | `delay_timer(target art, s)` + curse Slowed Time at **6 % per stack, cap 5 (30 %)**; falling return halves the **delay seconds** for repeats on one target within 3 s; defence key `timer_resist_pct` | Effects (actions, Status Catalogue), Character Stats (key) | No |
| R2 Ward-shield bypass | **Yes, as proposed** | part property `bypass_share`: skips ward shields only (still meets resistance, block, body shield); sources add, **cap 50 % per hit**. Đao's Sweep stays Đao's own Effect, not part of the rule | Combat Defence & Healing, Combat (part properties) | No |
| R3 Shield `stops`, pieces | **Yes, both parts** | every shield record gets a `stops` list (types, ticks, at a share) Effects can add to; optional `pieces` (one hit breaks at most one piece; pieces regrow). Answers to the counters capped at **50 % of Chaos, 30 % of Soul**, each source closes something real. **Ticks**: base shields never stop them; only an Effect adding ticks to `stops` can, at a share | Combat Defence & Healing, Effects | No |
| R4 Kind-locked slots | **Yes** | key `free_slots[kind]`, kinds talisman, artifact_active, escape, pill, feint; Combat rule 13's pool stays the rule. **No total cap** (user's choice; the proposed +3 was dropped), so each source's own cost is the limit | Combat (rule 13), Character Stats (key) | No |
| R5 Down refusals | **Yes, as proposed** | one Down refusal per fight from all sources; a "twice" capstone raises it to 2, never higher. **Last acts are not refusals and have no limit** | Combat (defeat check), Effects | No |
| R6 Avoid step | **Yes, as proposed** | an avoid step at the head of the defence path, before evade: decoys/images absorb whole hits, untargetable windows drop hits, a companion sink moves a share. Ticks never avoided; log names every avoid. **Bound: a per-pulse budget of avoided hits from all sources** (start at 2, a tuning knob) | Combat Defence & Healing (defence path), Effects | No |
| R7 Self-counters | **Yes, as proposed** | one generic self-counter record (id, adding event, cap, decay, readers), tag `growing` for counter-pieces to read. **No limit on how many run at once**; each counter's own cap and decay bound it | Effects | No |
| R8 Pre-fight choices | **Yes, as proposed** | a preparation-choice record (id, effects, allowed situations: foreseen, ambush, blind), gated by Combat rule 12's table; the Advisor can preset. **One pick per source, no total cap** | Combat (rule 12), Effects | No |
| R9 Carried ground | **Yes, as proposed** | a carried ground object brought into fights at **foreseen 100 %, ambush 70 %, blind 50 %**; the Domain is the one carried ground that unfolds mid-fight | Combat (rule 12, L4), Effects | No |
| R10 Least-resisted conversion | **Yes, capstones and majors only** | `convert_to: least_resisted`, decided when the hit lands; uses one of the 2 conversions | Combat (conversion), Effects (tiers) | No |
| R11 Added Soul part | **Yes, cap 30 %** | a non-soul art may carry an added Soul part ≤ 30 % of its damage; meets only soul defence, shares the soul lockout; converting to Soul stays forbidden | Combat (soul rules) | No |
| R12 Pools as weapons (part 1) | **Accepted:** Crossing the Line (Sinh Tử), heart demon as a pool (Ma), thần thức as a pool (Xạ). **Deferred:** thần thức theft (Phệ) | each is its own identity piece; heart demon pool needs R13's in-fight readable | Combat (pools), Effects, Character Stats | No |
| R12 Pools as weapons (part 2) | **Deferred both:** overdraw (Thủy), pool swap (Âm Dương) | the two pieces wait; Thủy and Âm Dương keep them labelled `Needs rule` | — | — |
| R13 Life readables | **Yes, all groups** | one Character Stats pass adding a "life readables" section (world time/season, kill count/win streak, World Database grudges/oaths/kindness/debts, merit/incense/renown, heart demon/pill toxicity, foe tags demonic/ghost/undead, Blood Purity, Dao Heart, Calamity Marks, Soul charges, Tipsiness) and one Combat pass exposing them to Effects | Character Stats, Combat (rule 2) | No |
| R14 Cap shifts | **Yes, as proposed** | at most one cap-shift capstone per Way, each with a closing cost the build feels. Pricing waits, like all Effect pricing (effects unpriced until the game is finished) | Dao (capstones), Effects | No |
| R15a Meta progression | **Small, only through these Ways** | nothing carries over by default; only Luân Hồi (Memory of Lives) and Sư (Pass the Lamp) pass on a small named inheritance | Dao, (future) life/legacy rules | No |
| R15b Fifth Đạo | **Yes, as Phân Thân's capstone only** | The Avatar Walks is the one exception to dao.md rule 9, at a real cost; no other source | Dao (rule 9 exception) | No |
| R15c Cull | **Yes, Sát only, capstone tier** | outright kill below 8 % health (tuning knob); one Way owns culling | Effects, Combat (defeat check) | No |
| R15d Layer writes | **Yes, capstones only, read-mostly** | Effects may read layer totals freely; writing (clip/raise) only at capstone tier, one per Way, logged (Thiên, Vô Cực) | Effects, Combat (layers) | No |
| R15e Dream window | **Later** | Mộng's snapshot-and-swap keeps `Needs rule` | — | — |
| R16 Strip foe buffs | **Yes, strip and steal** | `strip_buff(n, element = largest pile)`, oldest batch first, at most once per pulse per source; `steal` variant moves them to the owner; copying needs no new action | Effects (rule 6 actions) | No |
| R17 Fight-long debuffs | **Confirmed** | a fight-long foe stat loss must be a named curse with stacks, duration ≤ 5 pulses (already applied in batches 01–62) | Effects (Status Catalogue) | Yes (in the Ways) |
| R18 Triggers outside `trig_budget` | **All inside, except Hoa's capstone** | six move inside the budget; Hoa's capstone declares a petal channel and stays `Needs rule` | Effects (rule 7) | No |
| R19 Cash in | **Yes, as proposed** | `consume(element, side, n)`: removes up to n stacks of an element from a side, oldest batch first, reports the count to the same Effect's payload; one Breakdown line | Effects (rule 6 actions) | No |
| R20 New events | **Add "heal restored" and "hit fully stopped by wards"** | batch-expired and window-start are rewritten as pulse checks or time conditionals | Effects (rule 5 events) | No |
| R21 Direct foe stat changes | **Keep the rule** | foe changes only through statuses; drafts use owner modifiers or named statuses | Effects | Yes (in the Ways) |
| R22 Curse durations | **Yes, clamp 1–5** | apply every change, then clamp to 1–5 pulses (`curse_duration_max`); halves round down, never below 1 | Effects (Status Catalogue) | No |

## Other decisions (OVERNIGHT-2026-11-11 items 2, 3, 5 and combos red item 3)

| Question | Decision | Notes |
|---|---|---|
| Life-earned permanent bonuses (`_combos-and-risks.md` 1) | **No ceiling** | keep as drafted; earned power is the reward. Watch the macro difficulty targets |
| Floor on non-soul resistance (combos 2) | **No floor, keep the 2026-11-10 ruling** | negative resistance amplifies; shred stays uncapped |
| The cost lock (combos 3) | **Keep it; merge Băng's Absolute Zero and dry-well's Cold Toll into one piece** | no cap on Ice cost raise |
| Way outlines on the tree | **Own outline per Way** | each Way's ~150-node cluster graph gets its own shape (Meridian kit, no silhouettes); Hỏa's Sword-layout draft is a placeholder |

## Build-run system suggestions (`design/builds/overnight-2026-11-10/RUN-SUMMARY.md` § 2, top 9)

| # | Suggestion | Decision |
|---|---|---|
| 1 | Record fields: `fight_payload` on pills, coatings, combat talismans; combat formations as data; technique ability/passive/Effect lists | **Adopt, with the combat-passive budget** |
| 2 | New readables and events for Effects (tick prevented points, cleansed-stacks event, arts fired this instant, pool shortfall, soul-hit linh lực, overflow per pulse, pre-cap layer total, pieces you control, higher-realm knockouts, boss tag) | **Adopt as one rule-5 edit; every reader carries its own cap** |
| 3 | Reference thần thức and soul resistance by realm (typical 59.4 / 0; top-end 142 / 15; soul-resistant + Soul-Guarding Lamp) and Thinned Mind | **Fill the table now; adopt Thinned Mind** (k tuned after) |
| 4 | Art lint holes: (a) curse lint charge, (b) soul art pricing, (c) stack grant bound, (d) front-loaded batches | **Adopt (a), (b), (c); (d) as a 2-pulse minimum batch** |
| 5 | One-line clarifications (usable-maximum shares, empty slot, curse start, "a hit landed", conversion history, Measured Stroke 10 s, overflow read whole, formations on one ground) | **Adopt as written. Granted stacks: no status roll. Fire buff: a factor on all of a side's direct damage, outside M, companion hits count** (falling return only if the harness shows pure buffers above the anchor) |
| 6 | Timer stats: `opening_haste_pct`, `basic_speed_pct`, `companion_speed_pct` | **Adopt all three; opening haste never on tree smalls** (techniques, Way notables, named items, pills only); NPC generator gives top-end NPCs some |
| 7 | Plain keys: `curse_effect_pct`, `ward_bill_pct`, `companion_health_pct` + companion power share, `than_thuc_cost_pct` [weapon], `status_duration_taken_pct` + status duration [curse] | **Adopt all** (watch Sundered with `curse_effect_pct`; watch drain wards' share of NPC loadouts) |
| 8 | `basic_coef_add` and `art_coef_add` outside the art lint | **Adopt both; `art_coef_add` only from named, capped Effects** (Vow of the One Stroke, Thunderhead to start) |
| 9 | Held payload ("until your next X") as a fifth Effect timing | **Adopt** |

Suggestions 10–17 were not asked (outside the top 9).

## Summary

- **Accepted:** R1–R11, R12 (Crossing the Line, heart demon pool, thần thức pool), R13, R14, R15a–d, R16, R19, R20,
  R22. **Confirmed (already in the Ways):** R17, R21. **Deferred:** R12 thần thức theft, overdraw, pool swap; R15e Dream window.
- **Changed from the proposal:** R4 has no total cap; R15b allows Phân Thân's fifth Đạo.
- **Next:** write the accepted rules into their owning GDDs (section by section, user approves each), then revise
  each asking Way to point at the rule instead of its own `Needs rule`.

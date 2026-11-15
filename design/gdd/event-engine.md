# Event Engine

> **Status**: In Design
> **Author**: user + Claude
> **Last Updated**: 2026-11-15
> **Last Verified**: 2026-11-15
> **Implements Pillar**: Pillar 2, Every Number Is Bounded and Visible; Pillar 5, A World That Remembers

## Summary

The Event Engine makes a life's story moments: pop-up events in the manner of EU4 and Crusader Kings, with a text and
two to four choices, fired by the season pulse, by hooks on game moments and by follow-ups that earlier choices
scheduled. Flags, variables and stories chain events into arcs that remember what the player did. One shared budget per
chain or story keeps every reward inside the realm's bounds (Pillar 2). Important NPCs live through the same events off
screen, choosing by their traits. All content is authored Vietnamese data that needs no LLM.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `World Database, Character Stats, Item Database, NPC Builds, Combat, Time & Turn; soft: Travel & Map, Sects & Missions, NPC Traits, Regional Economy & Trade, Quests, LLM Game Master (parked)`

## Overview

The Event Engine makes the story moments of a life. They work like the pop-up events of grand-strategy games (EU4,
Crusader Kings): a title, a text and two to four choices. A choice may cost something up front, ask for a check (a
talent (thiên phú) roll or a real fight through Combat), and lead to a success or failure outcome. Events fire from
three places: the **season pulse** when the player spends time (cultivating, exploring, travelling), **hooks** on
moments the game already has (a breakthrough, arriving at a place, a travel stretch, joining a sect, the death of
someone the player knows), and **follow-ups** that earlier events scheduled. Events read and write **flags and
variables** on people, places and sects. A choice made now can therefore come back seasons or years later, and
events chain into longer stories: a robber you spared returns, an old cave abode (động phủ) is opened over three
visits, a debt falls due.

The engine is also the guard rail. Every number an event gives or takes passes the same validator and budget: a
per-realm ceiling scaled by fortune (khí vận), counted across a whole story and not per step. Authored content, and
later any other source, cannot hand out more than the realm allows (Pillar 2, Every Number Is Bounded and Visible).
Events are authored data with Vietnamese player text, and they stand alone without an LLM. The parked LLM Game
Master would be one more source going through the same validator. What an event changes is written to the World
Database, so later events, people and the chronicle remember it (Pillar 5, A World That Remembers). The same
machinery also lets important NPCs live through events off screen, choosing by their traits, and it is the one
door through which an event asks other systems for things: a fight request with its situation (Combat), a price
shock (Regional Economy & Trade), a trait gained or lost (NPC Traits), a change of standing with a sect (Sects &
Missions). Without it a season is only numbers; with it, the life has things that happened.

## Detailed Design

### Core Rules

Structure decisions (user, 2026-11-15): short chains are plain events joined by flags and follow-ups, and long arcs
are **stories**; events fire from the season pulse, hooks and follow-ups, with a pacing guard; only events marked
NPC-capable run for NPCs, and only for some people; a chain or story shares **one budget** across its steps.

**The event**

1. **An event is a data record.** It has an id, a title and a text (Vietnamese, with placeholders filled from its
   scopes, rule 22), its **scopes**, its **conditions**, a **weight**, and two to four **options**. Each option has:
   - a label and its **choice tags** (aggressive, merciful, greedy, deceitful, loyal, cautious, vengeful, devout,
     social…; the vocabulary is this system's, NPC Traits rule 8 reads it);
   - an optional **show condition** (the option exists only when it holds), which may require a trait: a trait adds
     an option that fits it, and never takes one away (NPC Traits rule 9);
   - **always** effects, paid on choosing (a cost in spirit stones (linh thạch), an item, a heart-demon (tâm ma) risk);
   - a **check**: none, a stat check (rule 16) or a fight (rule 17);
   - a **success** and a **failure** outcome, each a text, a list of effects (rule 13) and any follow-ups (rule 11).
2. **Scopes name who and where the event is about.** `root` is the person living it (the player, or an NPC under
   rule 19). An event may bind up to three more scopes: one other person (`other`: a new person, a sect-mate, a person
   the root knows, a person holding a named flag, a fixed-cast person by id, or a beast), the place (always the root's
   current place, or a named place for authored anchors), and a sect (the root's, the place's owner, or a named one).
   A scope that cannot be bound makes the event ineligible, and the pick moves on (rule 7).
3. **Four kinds, by how an event fires.** **Pulse** events can be drawn by the season pulse (rule 5). **Hook** events are
   listed under a hook (rule 6). **Follow-up only** events never fire on their own and are only scheduled by an
   outcome (the Paradox "triggered only"). **Story** events belong to a story (rule 12) and fire only from it. One
   record has exactly one kind.
4. **Conditions are a closed vocabulary, combined with all / any / not.** Each condition is a named test on a scope:
   realm and stage range, age, lifespan left, sect and rank, sect alignment, attitude to the player, trait held, flag
   set or not, variable compared to a number, item or item tag held, spirit stones held, place kind, biome, danger,
   owner, region, season of the year, year range, place known, an event kind logged for a scope within N seasons, a
   story's stage, a person alive, the edge (thiên mệnh) and fortunate-encounter (cơ duyên) allowance, a bottleneck (bình
   cảnh), heart demon above a level. Place kinds are the fixed world's (Travel & Map rule 6, World Generation &
   History): great and minor sect seat, city, market, town, village, mine, peak, volcano, lake, island, forest, gorge,
   spirit vein, secret realm, ruin and cave abode. The old generator's place types are retired. A data file that uses
   an unknown condition, place kind or effect is **rejected when the game data loads**, with the file and record
   named. It is never discovered in play.

**Firing**

5. **The season pulse.** When the player spends a season (cultivating, exploring, a crafting season and the other
   season-long actions of Time & Turn), the engine rolls the pulse chance (Formulas A). On a hit it picks one eligible
   pulse event (rule 7). Closed-door cultivation (bế quan) has no pulse, as built. Travel is different: Travel & Map
   Formula E decides whether a travel stretch draws an encounter, and this system only picks it, from the events
   listed under the `on_travel_stretch` hook, filtered by the stretch's biome and mode.
6. **Hooks fire on moments the game already has.** The hooks: `on_arrive` (at a place), `on_travel_stretch`,
   `on_discover` (a hidden place found), `on_breakthrough` (success and failure), `on_realm_enter`, `on_join_sect`,
   `on_leave_sect`, `on_rank_change`, `on_known_death` (someone the root knows, or holds a flag on, dies),
   `on_fight_end` (an event fight), `on_secret_realm` (announced, opened, closing), `on_tribulation_end`,
   `on_talk` (the player greets a person: NPC Interaction & Dialogue rule 18, added 2026-11-15),
   `on_season_start` and `on_year_start`. A hook lists its events and its own chance (1.0 for a scripted moment). A
   hook fires at most one event per occurrence. Another system that wants a new hook asks for it here.
7. **The pick.** Eligible events are those whose kind fits, whose conditions hold, whose scopes bind, and which are
   off cooldown (rule 9). One is drawn by its **effective weight**: its base weight times the product of its weight
   modifiers, each a condition with a factor (Formulas B). Fate-given traits, sect event weights (Sects knob "event
   weights") and the root's situation enter here, as modifiers, never as code.
8. **Player events draw from the session stream; NPC events from keyed streams.** A player event's pick, binding and
   check draw from the session stream (ADR-0002 decision 1). An NPC event draws from a keyed stream on (game seed,
   person, season, event id), so the order the tick visits people in changes nothing (ADR-0002 decision 4). A fight
   takes one seed under Combat and Power Rankings' own rules.

**Pacing and order**

9. **The pacing guard.** The player gets at most `player_events_per_season_max` events in one season, follow-ups
   included. An event has a cooldown in seasons after it fires for a root, and may be `once_per_life` (per root) or
   `once_per_world` (one root ever; used for authored events around the fixed cast and history's places). Only one
   event is pending at a time: while it waits, time-consuming actions are refused, as built.
10. **When several are due at once,** they queue: follow-ups due this season first (oldest scheduled first), then
    hook events, then the pulse. Ties break by event id. What does not fit under the cap this season waits for the
    next one (a follow-up) or is dropped (a hook or pulse event: the moment has passed).

**Memory: flags, variables, follow-ups and stories**

11. **Flags, variables and follow-ups.** An effect may set or clear a **flag** on a person, place, sect or the world,
    with an optional expiry in seasons, or add to an integer **variable** on one of them (clamped to its declared range).
    Names are namespaced by the event or story that owns them. Any condition may read any namespace. An outcome may
    **schedule** a follow-up: an event for a scope, either after a delay rolled in a range of seasons, or at the next
    occurrence of a named hook (for example, "the next time the root arrives at this place"). When it falls due, its
    conditions are checked: if they hold it fires, if not it waits up to its `wait_seasons` and is then dropped. A
    root dead before it falls due drops it.
12. **Stories are long arcs.** A story is a data record: a start (an event outcome, a hook or world generation for an
    authored fixed-world story), named stages, its own variables, an end condition (a stage reached, a timeout in
    seasons, a scope person dying, a failure flag) and a budget multiplier (rule 14). Each season an active story
    checks whether its next event is due (its `on_season_start` heartbeat). A root has at most `stories_active_max`
    active stories. A new start beyond that is refused, unless the new story is marked `priority`: then the root's
    oldest story that is not marked `priority` ends as timed out. A story ends with a World Database record (a
    chronicle-style line, rule 22). Stories anchor authored content to the fixed world: the hidden places history left
    (World Generation & History), the fixed cast, the sects' quarrels.
13. **The effect vocabulary.** Effects an outcome may carry: spirit stones (linh thạch), cultivation base (tu vi),
    vitality loss (khí huyết, as a percentage), heart demon (tâm ma), pill toxicity (đan độc), attitude of a person to
    the player, a herb, a material, an artifact, a technique (công pháp), a pill, a talisman, a treasure, a Kinh Mạch Đồ
    point, the Deity Transformation insight, unsealing a cluster, a breakthrough pill or missing herb for a protagonist
    (cơ duyên gifts, Progression Edges), grant or remove a gained trait (NPC Traits rules 11 and 13), raise a trait's
    trigger id (NPC Traits rule 12), a sect standing change, a sect loyalty or attitude change within Sects' own bounds,
    a market shock (Regional Economy & Trade rule 18), a clue or rumour (Travel & Map rule 16), reveal a place, a scar
    on the land (Travel & Map, its threshold), set or clear a flag, change a variable, schedule a follow-up, start or end
    a story, move a story's stage, and a fight request (rule 17). Each effect is applied by the system that owns the
    value; this system only validates and asks.

**Budgets and money**

14. **One budget per chain or story.** A **chain** is an event that did not come from a story, plus every follow-up it
    schedules, and theirs in turn. A chain or story has one budget per reward kind: its ceiling (the per-realm event
    budget scaled by fortune, Formulas C) times its multiplier (chain `chain_budget_mult`; story its own, at most
    `story_budget_mult_max`). Each grant spends from what is left, and a single event may still grant no more than one
    event's ceiling. A grant that asks for more is clamped to what is left, and the clamp is reported. Items keep
    their per-event grade, tier and rarity caps, and a chain or story may grant only a set number of items (Formulas
    C); pricing items into the same value budget waits for settled Item Database prices (Open Questions). Losses (vitality,
    heart demon, toxicity, spirit stones paid) are capped per event, as built, and do not spend the budget. When the root
    enters a new realm, the unspent share of each budget carries over at the new realm's ceiling.
15. **No event creates money.** A spirit stone grant names a source, the victim's purse, a sect treasury, the commons
    pool or the lost-stash pool, and pays `min(budget left, the source's balance)` (Regional Economy & Trade Formula K).
    The outcome text is told the amount actually paid. Item grants are generated by Item Database within its own rules,
    as built.

**Checks and fights**

16. **A stat check** compares a talent with a difficulty (Character Stats' check chance, owned there). Talismans for
    checks (Talismans), capability #19's reroll and stealth for evading work as built. The check's chance and its
    Breakdown are shown on the option before the player chooses.
17. **A fight is a request to Combat.** The option names the enemy (the `other` scope), the **situation**: foreseen,
    ambush or blind (Combat rule 12), the ground tags (`own_abode` among them), and optionally `no_heal`. A win takes the
    success outcome; a loss, a draw or a flight takes the failure outcome (Combat AC-CB-62). The option shows the fight
    engine's odds before the choice (as built). After a win over a cultivator, if the option allows, the player chooses
    **mercy**: kill (the foe dies, recorded) or spare (a flag on the foe, `spared_by`). After a win over a creature,
    taming is offered (Spirit Beasts). The consequences outside the fight are applied here, once (Combat rule 14). A
    source of a situation step (the build ledger's Alarm Array, Challenge Letter) may raise the root's side one step
    (blind → ambush → foreseen), never lower the other side's. When the root is an NPC, the fight is a rating roll
    (Power Rankings rule 12).
18. **Death.** When vitality reaches 0 after the effects, the root dies (Character Stats rule 9), unless a capability
    saves them (capability #5, as built). The death cause names the event.

**NPCs**

19. **Some events, some people.** An event marked `npc` may run for an NPC root. It must not carry player-only effects
    (cơ duyên gifts, Kinh Mạch Đồ points for the player, unsealing). Each season, after the Living World Tick's own steps,
    NPC events run for: every living fixed-cast person, every person the player knows (met, holds a flag on, or with an
    attitude other than 0), and a keyed sample of `npc_sample_per_season` other people. Each rolls the NPC pulse
    (Formulas A), capped at `npc_events_per_season_max` for the world.
20. **An NPC chooses by its traits.** Its option is drawn by NPC Traits F2 (base weight times trait weights), from
    the options whose show conditions hold. Its checks use the same stat formula; its fights are rating rolls. Effects
    apply under the same budgets. No text is shown. A resolved NPC event writes a World Database record, which reaches
    the player's news when the event is marked `newsworthy` or a scope is someone the player knows. An NPC event may
    schedule a follow-up whose root is the player, so a rival's revenge or a friend's request reaches them.

**Content, text and what the player sees**

21. **Sources.** Authored records are the main source. Quests (#31) builds its stage events from its own records and
    hands them in. The parked LLM Game Master (#29) would be one more source later. Every source goes through the same
    validator: it clamps numbers to the budget, drops unknown effects, registers any new person in the World Database
    before they appear, and adds a free exit when every option costs spirit stones (as built). It reports every change
    as a warning that the debug terminal shows.
22. **Text stands alone.** Every title, text, option label and outcome text is Vietnamese data, with placeholders for
    the scopes' names, realms, place, region, sect, the `other` person's latest history line and the variables. A text
    may carry two or three variants, drawn by a keyed draw. A resolved event's World Database record is a sentence
    built from the event's `log` line, so the news and the chronicle read without an LLM.
23. **What is shown (Pillar 2).** Before choosing, each option shows its always costs, its check with chance and
    Breakdown (or the fight odds), any trait that added it (NPC Traits rule 9), and a summary of each outcome: the
    reward and risk kinds with their ranges. An outcome may be marked `hidden` ("?"), but a hidden outcome that can kill
    shows that it can, and after resolution every roll and effect is shown in full (as built). An item may reveal
    hidden outcomes (the Star Chart idea, design/builds).

### States and Transitions

**An event instance**

| State | Becomes | When |
|---|---|---|
| Candidate | Bound | Picked by weight (rule 7) and its scopes bind (rule 2) |
| Candidate | (dropped) | A scope cannot bind; the pick moves on |
| Bound | Validated | The validator accepts it, after clamps (rule 21) |
| Bound | Rejected | Too few valid options, or no title or text; logged as a warning |
| Validated | Pending | The root is the player; time-consuming actions wait (rule 9) |
| Validated | Resolved | The root is an NPC: option drawn by traits (rule 20) |
| Pending | Resolved | The player chooses an option it can pay for |
| Resolved | Logged | Effects applied, follow-ups scheduled, the World Database record written |

A save keeps a pending event as it is (as built).

**A scheduled follow-up**

| State | Becomes | When |
|---|---|---|
| Scheduled | Due | Its delay ends, or its named hook occurs |
| Due | Fired | Conditions hold and it fits under the pacing cap |
| Due | Waiting | Conditions fail or the cap is full; rechecked each season |
| Waiting | Fired | Conditions hold within `wait_seasons` |
| Waiting / Scheduled | Dropped | `wait_seasons` runs out, or the root dies |

**A story**

| State | Becomes | When |
|---|---|---|
| Not started | Active (first stage) | Its start event, hook or world-generation start; under the root's story cap |
| Active (stage n) | Active (stage m) | An outcome moves its stage |
| Active | Ended: done | An end stage is reached |
| Active | Ended: failed | A failure flag is set, or a scope person it needs dies |
| Active | Ended: timed out | Its timeout passes, or a priority story displaces it (rule 12) |

Each ending writes one World Database record. A `once_per_world` story never starts again.

**A flag:** set → cleared (by an effect) or expired (its seasons pass). Variables have no states; they are clamped.

### Interactions with Other Systems

| System | Direction | What flows | Owner of the interface |
|---|---|---|---|
| World Database (#3) | in / out | In: people, places, sects, the event log for conditions. Out: flags, variables, pending event, follow-ups, stories, event records, new people | World DB (storage); this GDD (what is stored) |
| Time & Turn (#4) | in | Season-long actions that run the pulse; season and year starts | Time & Turn |
| Simulation Core (#2), ADR-0002 | in | The session stream for player events; keyed streams for NPC events | ADR-0002 |
| Character Stats (#7) | in / out | In: talents, fortune (the reward ceiling), heart demon, vitality, the check chance. Out: vitality loss, heart demon, toxicity, death | Character Stats (formulas); this GDD (when they apply) |
| Realms & Bottlenecks (#8), Progression Edges (#11) | in / out | In: realm, stage, bottleneck, edge and cơ duyên allowance. Out: cultivation base, insight, cơ duyên gifts, the `on_breakthrough` and `on_realm_enter` hooks | Realms; Progression Edges quick spec |
| Item Database (#13), Alchemy, Talismans, Spirit Beasts | out / in | Out: item grants within budget, taming after a creature fight. In: check talismans, items held for conditions | Each item system |
| Combat (#21) | out / in | Out: a fight request (enemy, situation, ground tags, `no_heal`). In: the result; this system applies death, mercy, taming | Combat (the result); this GDD (the request and consequences) |
| Power Rankings | out / in | NPC-rooted fights are rating rolls; rated player fights take keyed seeds (Power Rankings rule 13) | Power Rankings |
| Heavenly Tribulation (#22) | in | The result, as the `on_tribulation_end` hook and a news record | Thiên Kiếp |
| Travel & Map (#25) | in / out | In: travel stretches with biome and mode (Formula E), arrivals, discoveries, secret realm cycles. Out: clues and rumours, revealed places, scars | Travel & Map (chances and places); this GDD (the events) |
| Sects & Missions (#26) | in / out | In: event-weight knobs, sect membership and rank. Out: standing, loyalty and attitude changes within Sects' bounds; notable choices for the news | Sects |
| World Generation & History (#27) | in | Fixed cast, history's hidden places and chronicle as story anchors; authored stories started at world generation | World Generation & History |
| Living World Tick (#28) | in / out | The tick calls the NPC event step once a season (rule 19) | Living World Tick (order); this GDD (the step) |
| NPC Builds (#24) | out | New people an event creates (validator, rule 21) | NPC Builds |
| NPC Traits | in / out | In: trait weights (F2), fate-given modifiers, trait-gated options. Out: trait grants, removals, trigger ids | NPC Traits (weights); this GDD (choice tags) |
| Regional Economy & Trade | out | Market shocks; spirit stone grants drawn from holders (Formula K) | Regional Economy & Trade |
| Quests (#31) | in / out | In: stage events as a source. Out: the check result and Breakdown, the shared validator and budgets | Quests (plans); this GDD (events, budgets) |
| LLM Game Master (#29), parked | in | A future source through the validator; nothing depends on it | — |
| Debug Terminal, Game UI | out | The pending event, options with costs, chances and outcome summaries, warnings, the news | Game UI |

## Formulas

User decisions 2026-11-15: chain 1.5×, story up to 3×; an item count cap per chain or story now, item value later;
2 player events a season and an 8-season default cooldown. Every number marked *guess* waits for play.

### A. Pulse chance (rules 5, 19)

The pulse_chance formula is defined as:

`p_pulse = clamp(p_base + p_danger · d + b_explore + b_cd, 0, 1)` · `b_cd = b_cd0 · (1 + cd_pct / 100)` when the root
has the edge, is at a bottleneck and has cơ duyên allowance left this realm, else 0 ·
`p_npc = p_npc0` for an NPC root

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| p_base | float | 0.12 | data file (`events_templates.json` `random_event_chance.base`) | Chance with no danger |
| p_danger | float | 0.06 | data file (`random_event_chance.per_danger`) | Added per point of danger |
| d | int | 1–4 | Travel & Map (place or part danger) | Danger where the season is spent |
| b_explore | float | 0.55 when exploring, else 0 | data file (`random_event_chance.explore_bonus`) | Exploring looks for events |
| b_cd0 | float | 0.25 | data file (`character_edges.json` `co_duyen_bottleneck_event_bonus`) | Fortunate-encounter bonus (Progression Edges) |
| cd_pct | float | 0 and up (100 with the edge's own row) | calculated (stat sheet `co_duyen_pct`) | Raises the cơ duyên bonus |
| p_npc0 | float | 0.10 | data file *(guess)* | An NPC's pulse chance in a season |

**Output Range:** 0.18 (cultivating at danger 1) to 1. The clamp only bites when exploring at danger 4 with the cơ
duyên bonus (raw 0.91 + 0.50 = 1.41): the event is then certain, which fits a protagonist hunting for a chance at a
bottleneck. With no bonus the highest is 0.91.
**Example:** cultivating at a danger-2 forest: 0.12 + 0.12 = **24 %** a season. Exploring the same place: **79 %**.
Exploring a danger-1 village at a bottleneck with the edge (cd_pct 100): 0.12 + 0.06 + 0.55 + 0.5 = 1.23 → **100 %**.

### B. Effective weight (rule 7)

The event_weight formula is defined as:

`w = 0` if any applicable factor is 0, else `w = w_base · clamp(Π_i f_i, f_lo, f_hi)` over the weight modifiers whose
condition holds

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| w_base | float | > 0 | data file (the event record) | The event's base weight |
| f_i | float | 0–10 | data file (the event's modifiers; Sects "event weights" knob; NPC Traits fate-given rows) | One modifier's factor |
| f_lo, f_hi | float | 0.1, 10 | data file *(guess)* | Bounds on the product, so stacked modifiers cannot crowd out every other event |

**Output Range:** 0, or 0.1 · w_base to 10 · w_base. A factor of 0 is an exclusion and is never clamped up.
**Example:** a betrayal event (w_base 5) for a root in a sect at war (×2), whose sect leans to it (×1.5), against a
heaven-favoured player (envy ×1.5): 5 · 4.5 = **22.5**. With five ×2 modifiers the product 32 is clamped to 10: **50**.
An NPC's choice between options is NPC Traits F2, not this formula.

### C. Budgets (rules 14, 15)

The event_ceiling formula is defined as:

`B_ev[k] = cap_r[k] · c_kv` for spirit stones · `B_ev[tu_vi] = tvp_r · c_kv · stage_cost` ·
`c_kv = 0.75 + 0.005 · kv` (Character Stats, registered as `khi_van_reward_ceiling`)

The chain_budget formula is defined as:

`B_ch[k] = m · B_ev[k]` with `m = m_chain` for a chain or the story's own `m ≤ m_story_max` ·
`grant = min(request, B_left[k], B_ev[k], balance[source])` (the last term for spirit stones only, Regional Economy &
Trade Formula K) · `B_left[k]' = B_left[k] − grant` · items granted ≤ `n_items` for the chain or story

On entering a new realm: `B_left[k]' = (B_left[k] / B_ch[k]) · B_ch'[k]` at the new realm's ceiling.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| cap_r[k] | int | spirit stones 80 / 600 / 5,000 / 40,000 / 300,000 by realm | data file (`events_budgets.json` `per_realm.linh_thach_max`) | One event's grant cap before fortune |
| tvp_r | float | 0.5 / 0.4 / 0.3 / 0.25 / 0.2 | data file (`per_realm.tu_vi_pct_max`) | One event's cultivation base cap, as a share of a stage |
| stage_cost | float | > 0 | Realms & Bottlenecks | Cultivation base for the root's current stage |
| kv | float | 0–100 typical | calculated (effective fortune, Character Stats) | Fortune (khí vận) |
| c_kv | float | 0.75–1.25 typical | calculated | Reward ceiling |
| m_chain | float | 1.5 | data file *(guess)* | A chain's budget multiplier |
| m, m_story_max | float | 1–3 | data file (story record; cap *guess*) | A story's multiplier and its cap |
| n_items | int | chain 2; story its own, at most 4 | data file *(guess)* | Item grants allowed in one chain or story |
| balance[source] | int | ≥ 0 | Regional Economy & Trade | The holder a spirit stone grant draws on |

**Output Range:** a grant from 0 to one event's ceiling; a chain from 0 to 1.5 ceilings; a story from 0 to 3 ceilings.
At fortune 0 the ceiling is 0.75 of the cap; at 100 it is 1.25. Fortune above 100 keeps raising it by 0.005 a point
(no cap; scale without caps), and the per-event term still bounds a single grant. Losses do not spend the budget and
are capped per event (rule 14).
**Example:** a Foundation Establishment (Trúc Cơ) player with fortune 60: c_kv = 1.05, one event's spirit stone ceiling
= 630 and a chain's = 945. Step 1 grants 500 (left 445); step 2 asks for 600 and gets **445**. If step 2 draws on a
commons pool of 200, it gets **200** (Formula K). A story at m = 3 has 1,890 to spend, at most 630 in any one step.

### D. NPC event volume (rule 19)

The npc_event_volume formula is defined as:

`E[N] = min(N_max, p_npc0 · (n_cast + n_known + n_sample))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| n_cast | int | 51 living at the start, falling as they die | World Generation & History (fixed cast) | Fixed-cast people |
| n_known | int | 0–about 100 | calculated | People the player knows (rule 19), fixed cast not counted twice |
| n_sample | int | 200 | data file (`npc_sample_per_season`) *(guess)* | Keyed sample of other living people |
| N_max | int | 40 | data file (`npc_events_per_season_max`) *(guess)* | World cap a season |

**Output Range:** about 25 a season at the start (0.10 · 251), up to the cap of 40. Each fixed-cast person meets an
event about once every 10 seasons (2.5 years), so they change on screen without flooding the news. Cost: about 250
people × about 50 NPC-capable events ≈ 12,500 condition checks a season.
**Example:** a player who knows 30 people: 0.10 · (51 + 30 + 200) = **28** events a season.

### E. Pacing (rules 9, 10)

The pacing_cap formula is defined as:

`fires(e) = n_season < n_max ∧ (t_now − t_last[e, root]) ≥ cd(e) ∧ ¬(once_per_life(e) ∧ fired_before(e, root)) ∧
¬(once_per_world(e) ∧ fired_ever(e))`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| n_season | int | 0–n_max | calculated | Player events already this season, follow-ups included |
| n_max | int | 2 | data file (`player_events_per_season_max`) *(guess)* | Player events in one season |
| cd(e) | int | 8 by default; 0 and up per event | data file (`cooldown_seasons`) | Seasons before the same event can fire again for the same root |
| wait_seasons | int | 4 by default | data file *(guess)* | How long a due follow-up may wait (rule 11) |
| stories_max | int | player 3, NPC 1 | data file (`stories_active_max`) *(guess)* | Active stories per root |

**Output Range:** 0–2 player events a season. An 8-season cooldown lets one event recur at most once every 2 years of game
time for the same root (a life of S seasons: at most S / 8 times). Its conditions and its share of the 150–250
templates' weight make real repeats much rarer; how many seasons a life lasts is Time & Turn's.
**Example:** a follow-up and a hook event fall due in the same season, and the pulse also hits: the follow-up fires,
then the hook event; the pulse event is dropped (rule 10).

## Edge Cases

**Picking and binding**

- **If no event is eligible** at a pulse or hook hit: nothing happens; the debug terminal logs which pool was empty. The
  pulse is not re-rolled.
- **If Travel & Map's encounter roll hits but no `on_travel_stretch` event fits the biome and mode**: no encounter; the
  stretch continues and the gap is logged as a content warning.
- **If fewer than two options remain after show conditions**: the event is ineligible for this root, and the pick
  moves on (rule 7).
- **If the root can pay for no option**: cannot happen. The validator adds the free exit whenever every option costs
  spirit stones (rule 21).
- **If an `other` scope names a fixed-cast person who is dead**: the scope fails to bind and the event is ineligible.
- **If a `once_per_world` event is NPC-capable**: the first root, player or NPC, uses it up. An authored event meant
  for the player is not marked `npc`.
- **If capability #20 lets a hostile event pass the player by**: it is not logged, does not count toward the pacing
  cap, and takes no cooldown, as built.

**Timing**

- **If a hook is raised while an event is pending or resolving** (an `on_fight_end` from the event's own fight, or a
  death caused by its outcome): it is queued as due this season and fires after, under the pacing cap. Events never
  nest.
- **If the cap is full when a follow-up falls due**: it waits (rule 11), up to `wait_seasons`, then is dropped.
- **If the root dies with follow-ups scheduled and stories active**: the follow-ups are dropped, and each story ends as
  failed with its record. A follow-up whose root is someone else stays.
- **If a story's needed scope person dies**: the story ends as failed, unless its record lists that death as a stage
  (a revenge story continues with the killer).
- **If a story start is refused because the root's story cap is full**: the outcome's other effects still apply, the
  start is dropped, and the warning names the story.
- **If the player is inside a secret realm when it closes**: the realm's authored closing event fires for them
  (`on_secret_realm` closing). Every secret realm must have one; the data load rejects a realm without it. If its
  conditions fail, the player is put out at the gate and nothing else changes.
- **If a save is made with an event pending, follow-ups scheduled or stories active**: all of it is saved with the
  session stream, and a reload resumes with the same draws (ADR-0002).

**Budgets and numbers**

- **If a chain or story budget is spent**: further grants of that kind pay 0. The effect line is left out and the
  outcome shows its `empty_text` if it has one; the record still logs the clamp.
- **If the named source holds less than the grant** (Formula K): the source's balance is paid, and the text is told the
  amount actually paid. A source with 0 pays 0, as above.
- **If the root changes realm mid-chain or mid-story, up or down** (a breakthrough, or capability #5's stage loss): the
  unspent share carries to the new realm's ceiling (Formulas C). A step that already paid out is never taken back.
- **If fortune is above 100**: the ceiling keeps rising (scale without caps); a single grant is still capped by one
  event's ceiling and by the holder's balance.
- **If a variable change would leave its declared range**: it is clamped, and the clamp is reported.
- **If two events write the same world-scope flag**: the later write wins, and both writes are in the event log.
  Namespaced flags cannot collide.
- **If an outcome brings vitality to exactly 0**: the root dies (rule 18). A loss is never floored for events (registry
  note on the breakthrough vitality floor).

**Fights**

- **If the fight engine cannot compile a side or is switched off**: the check falls back to the built duel roll, and
  the check line says why (as built).
- **If a fight ends in a draw or a flight**: the failure outcome applies, and no mercy choice is offered.
- **If the player spares a foe that the event's story needs dead**: the story reads the `spared_by` flag; the authored
  story decides what follows. The engine never overrides the player's mercy choice.

**Degenerate play**

- **Hopping between two places to farm `on_arrive` events**: each hop costs travel time, each event has its cooldown per
  root, and the player gets at most 2 events a season. The most the hop loop can yield is the season cap, the same as
  exploring.
- **Killing people for their purse**: a grant draws on the victim's actual purse (Formula K), and the death is
  recorded, so sects and people who knew the victim can react through their own events.
- **Leaving a story unfinished to keep its budget for later**: an unspent budget is not stored value. It is only a
  ceiling, and timeouts end a stalled story.

## Dependencies

**Upstream (this system needs them)**

| System | Hard / Soft | Interface | Has GDD |
|---|---|---|---|
| World Database (#3) | Hard | People, places, sects, event log; storage for flags, variables, follow-ups, stories, the pending event | No (built) |
| Time & Turn (#4) | Hard | Season-long actions, season and year starts | No (built) |
| Simulation Core (#2), ADR-0002 | Hard | Session and keyed random streams | ADR-0002 |
| Character Stats (#7) | Hard | Talents, fortune ceiling, check chance, vitality, heart demon, toxicity, death | Yes |
| Realms & Bottlenecks (#8) | Hard | Realm, stage, stage cost, bottleneck, insight | Yes |
| Item Database (#13) | Hard | Item grants and their per-event caps | Yes |
| NPC Builds (#24) | Hard | New people created by events | No (built) |
| Combat (#21) | Hard | Fight requests and results (rule 17) | Yes |
| NPC Traits | Hard for NPC events, soft for the player | F2 choice weights, fate-given weight modifiers, trait-gated options, trait grants | Yes |
| Regional Economy & Trade | Hard for spirit stone grants | Formula K holders; market shocks | Yes |
| Progression Edges (#11) | Soft | Edge, cơ duyên allowance and gifts, `b_cd0` | Quick spec |
| Travel & Map (#25) | Soft | Travel stretches (Formula E), arrivals, discoveries, place kinds, biomes, secret realm cycles, clues, scars | Yes |
| Sects & Missions (#26) | Soft | Membership, rank, event-weight knobs; standing, loyalty and attitude changes | Yes |
| World Generation & History (#27) | Soft | Fixed cast, history's hidden places, chronicle as story anchors; stories started at world generation | Yes |
| Power Rankings | Soft | Rating rolls for NPC fights; keyed seeds for rated player fights | Yes |
| Alchemy, Talismans, Spirit Beasts | Soft | Pills, check talismans, taming | No (built) |

**Downstream (they need this system)**

| System | Hard / Soft | Interface |
|---|---|---|
| Heavenly Tribulation (#22) | Soft | `on_tribulation_end` and the news record |
| Quests (#31) | Hard | Stage events through the validator, budgets, check results |
| Living World Tick (#28) | Soft | Calls the NPC event step (rule 19) |
| NPC Interaction & Dialogue (#30) | Soft | Flags and the event log for what people remember (provisional; no GDD) |
| LLM Game Master (#29), parked | Soft | A future source through the validator |
| Debug Terminal, Game UI | Hard | The pending event, options, chances, outcome summaries, warnings, news |

**Bidirectional check.** Character Stats, Realms (canh-gioi), Combat, Công Pháp, Đạo, Effects, Item Database, Kinh
Mạch Đồ, Linh Căn, NPC Traits, Power Rankings, Quests, Regional Economy & Trade, Sects, Thiên Kiếp and Travel & Map
already list the Event Engine in their Dependencies. World Generation & History lists it too (row added 2026-11-15,
with this GDD). The systems index row 23 was updated with this
GDD's dependencies (2026-11-15).

**Revisions this GDD answers or asks for elsewhere:**
- Regional Economy & Trade Open Question 5 ("every spirit stone grant draws from a holder, and the budgets are
  restated"): answered by rule 15 and Formulas C.
- Character Stats Open Question 4 (event budgets for talent, heart demon and vitality effects): heart demon and
  vitality are capped per event as built (`tam_ma_max`, `khi_huyet_loss_pct_max`); **talent changes are not an event
  effect yet** (Open Questions).
- Travel & Map Open Question 5 (scar threshold and size): still open; the effect exists (rule 13) and its numbers wait
  (Open Questions).
- `events_templates.json` must be rekeyed to the fixed world's place kinds, and `mach_an_co_vat` (retired Mạch Ấn)
  removed or rewritten (rule 4).

## Visual/Audio Requirements

`art-director` not consulted (Lean mode; events are read as text, not watched). There is no art bible yet, and the map
style is still being chosen. Review before production.

- **The event card is the visual.** Title, text and options on an ink-wash card, matching the planned 2D UI (game
  concept, Visual Identity Anchor). An event may name an **illustration key** (a place kind, a creature kind, a
  fixed-cast portrait); a missing key falls back to the place kind's image. The illustrations are authored assets,
  listed later by `/asset-spec`.
- **Kinds read at a glance:** a story event shows its story's name and stage; a follow-up shows a small mark naming
  the earlier event; a fortunate encounter (cơ duyên) and a fixed-cast event have their own frame.
- **Audio:** one sting when an event interrupts time (distinct for danger, fortune and story), a soft page sound for a
  choice, and the fight's own audio for an event fight. Nothing loops on the card.
- The debug terminal shows the same information as text (as built).

## Game Feel

- **An event interrupts, then waits.** Time stops on the card, and nothing is chosen for the player or on a timer.
  Reading at the player's pace is part of the game.
- **Choices are weighed, not guessed.** Each option's cost, chance and outcome kinds are on the card before choosing
  (rule 23), so a bad result feels like a risk taken, not a trap.
- **Consequences come back.** A follow-up or story event names what it follows ("the bandit you spared…"), so the
  player feels remembered. This is the feel the chains exist for.
- **Rhythm:** at most two events a season (Formulas E). A danger-1 cultivating season fires about one time in five,
  and an exploring season most of the time, so calm and eventful stretches alternate.
- **Resolution is instant and itemised:** after the choice, the check line, then each effect line (as built), then the
  outcome text.

## UI Requirements

- **The event card:** title; story name and stage, or follow-up mark; text; illustration; 2–4 options. Each option
  shows its label, the trait that added it (if any), its always costs, its check (stat, difficulty, chance with a
  Breakdown on hover or tap) or fight odds with the situation (foreseen, ambush, blind), and the outcome summary
  (reward and risk kinds with ranges, or "?" for a hidden outcome; a deadly hidden outcome says it can kill). An
  option the player cannot pay for is shown but disabled, with the reason.
- **The result view:** check line, effect lines, outcome text, then the mercy choice after a won fight against a
  cultivator, or taming after one against a creature.
- **The stories panel:** each active story with its name, stage, the last event, and its budget left (Pillar 2).
- **The news:** NPC event records about people the player knows, and `newsworthy` ones (rule 20).
- **The debug terminal** additionally shows validator warnings, the eligible pool with weights, and scheduled follow-ups.

> **📌 UX Flag — Event Engine**: this system has UI requirements. In Pre-Production, run `/ux-design` for the event
> card, the result view and the stories panel before writing epics. Stories citing UI should cite
> `design/ux/[screen].md`.

## Cross-References

| This document references | Target GDD | Element | Nature |
|---|---|---|---|
| Rule 4, place kinds | travel-map.md | Rule 6, place kinds | Data dependency |
| Rule 4, fixed-world anchors; rule 12 | world-generation.md | Fixed cast, chronicle, hidden places | Data dependency |
| Rules 5 and 13, travel encounters, clues, scars | travel-map.md | Formula E, rules 13, 16, 17; Open Question 5 | Ownership handoff (Travel decides if, this system decides what) |
| Rules 7, 20, choice tags and weights | npc-traits.md | Rules 8, 9, 11–13; F2 | Rule dependency |
| Rule 7, event weights | sects.md | Knob "event weights" | Data dependency |
| Rules 13, 15, money and shocks | regional-economy-trade.md | Rule 18, Formula K, Open Question 5 | Rule dependency |
| Rules 16, 18, checks and death | character-stats.md | Check chance, reward ceiling, rule 9, Open Question 4 | Formula dependency |
| Rule 17, fights | combat.md | Rules 12, 14; AC-CB-62, AC-CB-63 | Ownership handoff (Combat the result, this system the consequences) |
| Rule 17, NPC fights; keyed seeds | power-rankings.md | Rules 12, 13 | Rule dependency |
| Rule 8, streams | docs/architecture/adr-0002-random-streams.md | Decisions 1, 3, 4 | Rule dependency |
| Formulas A, cơ duyên | design/quick-specs/progression-and-edges.md | `co_duyen_bottleneck_event_bonus`, `co_duyen_per_realm` | Data dependency |
| Formulas C, item caps | item-database.md | Item grants | Data dependency |
| Rule 21, quest stage events | quests.md | Rules 2, 5; stage kind `event` | Ownership handoff |
| `on_tribulation_end` | thien-kiep.md | The result as an event | State trigger |

## Acceptance Criteria

Test types: [Logic] automated unit test; [Integration] automated test across systems; [Config/Data] a data-load or
lint check; [UI] retained screenshot; [Playtest] a documented playtest question.

**The event and its data (rules 1–4)**

- **AC-EV-01** [Logic] Rule 1. **GIVEN** an event record with 2 options, each with label, tags, always effects, a
  check and both outcomes, **WHEN** it is loaded and validated, **THEN** the normalized event keeps every field, and an
  option missing a failure outcome uses its success outcome (as built).
- **AC-EV-02** [Logic] Rule 2. **GIVEN** an event whose `other` scope requires a sect-mate, **WHEN** the root has no
  sect, **THEN** the event is not eligible and the pick takes another.
- **AC-EV-03** [Logic] Rule 3. **GIVEN** a follow-up-only event with weight 100, **WHEN** 1,000 pulses run, **THEN** it
  never fires from the pulse.
- **AC-EV-04** [Config/Data] Rule 4. **GIVEN** a data file whose record uses condition `foo`, place kind `thanh` or
  effect `mach_an`, **WHEN** the game data loads, **THEN** loading fails with the file, the record id and the unknown
  name in the message.
- **AC-EV-05** [Logic] Rule 4. **GIVEN** conditions `all[realm ≥ truc_co, not flag X, any[place_kind = peak, place_kind
  = gorge]]`, **WHEN** tested for a Trúc Cơ root at a gorge without X, then with X, **THEN** true, then false.

**Firing and pacing (rules 5–10, Formulas A, B, E)**

- **AC-EV-06** [Logic] Formulas A. **GIVEN** danger 2, cultivating, no edge, **THEN** p = 0.24; exploring, p = 0.79;
  danger 1, exploring, at a bottleneck with the edge, allowance left and cd_pct 100, **THEN** p = 1.0 (raw 1.23).
- **AC-EV-07** [Logic] Rule 5. **GIVEN** a season of closed-door cultivation, **THEN** no pulse is rolled.
- **AC-EV-08** [Integration] Rule 5, Travel & Map. **GIVEN** a stretch whose encounter roll (Formula E) hits on desert
  ground, **WHEN** the pick runs, **THEN** only `on_travel_stretch` events allowing the desert biome and the mode are
  candidates, and no pulse roll is made for the stretch.
- **AC-EV-09** [Logic] Rule 6. **GIVEN** a hook with chance 1.0 listing two eligible events, **WHEN** it occurs, **THEN**
  exactly one event fires.
- **AC-EV-10** [Logic] Formulas B. **GIVEN** w_base 5 and active factors 2, 1.5, 1.5, **THEN** w = 22.5; with five
  factors of 2, **THEN** w = 50; with any factor 0, **THEN** w = 0.
- **AC-EV-11** [Logic] Rule 8. **GIVEN** the same seed and the same player actions twice, **THEN** the same events fire
  with the same rolls. **GIVEN** the NPC tick visits people in two different orders, **THEN** every NPC event and choice
  is the same.
- **AC-EV-12** [Logic] Formulas E. **GIVEN** a follow-up, a hook event and a pulse hit all due in one season, **THEN** the
  follow-up and the hook event fire, in that order, and the pulse event is dropped.
- **AC-EV-13** [Logic] Rule 9. **GIVEN** an event with cooldown 8 that fired in season t, **THEN** it is ineligible for the
  same root in seasons t+1 to t+7 and eligible at t+8. A `once_per_life` event never fires twice for one root; a
  `once_per_world` event never fires twice in one world.
- **AC-EV-14** [Logic] Rule 9. **GIVEN** a pending event, **WHEN** the player tries to cultivate, **THEN** it is refused
  with the event's title in the message.

**Memory (rules 11–12)**

- **AC-EV-15** [Logic] Rule 11. **GIVEN** a flag set with expiry 4 at season t, **THEN** it reads true at t+3 and false at
  t+4. A variable with range 0–10 at 9 plus 5 reads 10, and a warning names the clamp.
- **AC-EV-16** [Logic] Rule 11. **GIVEN** a follow-up scheduled with delay 2–4 seasons, **THEN** it falls due within that
  range; if its conditions fail when due, it waits and is dropped after `wait_seasons` (4).
- **AC-EV-17** [Logic] Rule 11. **GIVEN** a follow-up keyed to "next `on_arrive` at place P", **WHEN** the root arrives
  at another place, then at P, **THEN** it fires only at P.
- **AC-EV-18** [Logic] Rule 12. **GIVEN** a story moved to stage 3 by an outcome, **WHEN** stage 3's event conditions hold
  at the next season start, **THEN** that event fires; at the end stage the story ends as done and writes one World
  Database record.
- **AC-EV-19** [Logic] Rule 12. **GIVEN** a player with 3 active stories, **WHEN** a 4th non-priority story would start,
  **THEN** it is refused with a warning and the outcome's other effects apply; a priority story ends the oldest
  non-priority story as timed out instead.

**Effects, budgets, money (rules 13–15, Formulas C)**

- **AC-EV-20** [Logic] Rule 13. **GIVEN** each effect in the vocabulary, **WHEN** applied through the validator, **THEN**
  the owning system's value changes, and an effect not in the vocabulary is dropped with a warning.
- **AC-EV-21** [Logic] Formulas C. **GIVEN** a Trúc Cơ root with fortune 60, **THEN** one event's spirit stone ceiling is
  630 and a chain's is 945; step 1 grants 500; step 2 asking 600 gets 445; step 3 asking any amount gets 0, and the
  effect line is left out.
- **AC-EV-22** [Logic] Formulas C boundary. **GIVEN** fortune 0, **THEN** the ceiling multiplier is 0.75; fortune 100
  gives 1.25; fortune 140 gives 1.45.
- **AC-EV-23** [Logic] Formulas C. **GIVEN** a story with m = 3 and a step asking 2 event ceilings, **THEN** it gets 1
  ceiling. A story record with m = 4 is clamped to 3 at load with a warning.
- **AC-EV-24** [Logic] Formulas C. **GIVEN** a chain that has granted 2 items, **WHEN** a third item grant applies,
  **THEN** it is dropped with a warning.
- **AC-EV-25** [Logic] Formulas C. **GIVEN** a chain with 300 of 945 left at Trúc Cơ, **WHEN** the root breaks through to
  Kết Đan (ceiling 5,250 at fortune 60, chain 7,875), **THEN** 2,500 is left (300 / 945 × 7,875).
- **AC-EV-26** [Integration] Rule 15, Regional Economy & Trade. **GIVEN** a grant of 500 drawing on a commons pool of 200,
  **THEN** 200 is paid, the pool is 0, the outcome text shows 200, and the season's money total is unchanged (no
  money created).
- **AC-EV-27** [Logic] Rule 14. **GIVEN** a vitality loss of 60 % and a heart demon of +15 at Luyện Khí, **THEN** they
  apply and do not reduce the chain budget; a request for 80 % vitality loss is clamped to 60 %.

**Checks, fights, death (rules 16–18)**

- **AC-EV-28** [Logic] Rule 16. **GIVEN** stat 60 vs difficulty 50 and fortune 50, **THEN** the chance is 0.60 and the
  option shows it with its Breakdown before choosing.
- **AC-EV-29** [Integration] Rule 17, Combat. **GIVEN** a fight option with situation ambush and ground tag `own_abode`,
  **WHEN** resolved, **THEN** Combat receives both, a win takes success, and a loss, a draw or a flight takes failure.
- **AC-EV-30** [Integration] Rule 17. **GIVEN** a won fight against a cultivator with mercy allowed, **WHEN** the player
  spares, **THEN** the foe lives with flag `spared_by` = player; **WHEN** the player kills, **THEN** the foe is dead in
  the World Database with a record. A won creature fight offers taming; a draw offers neither.
- **AC-EV-31** [Logic] Rule 17. **GIVEN** an Alarm Array at the root's abode and a blind fight there, **THEN** the root's
  side fights as ambush and the other side stays blind.
- **AC-EV-32** [Logic] Rule 18. **GIVEN** vitality 0.3 and an outcome of −30 %, **THEN** the root dies with the event's
  title in the cause; with capability #5 unused, the root lives one stage lower (as built).

**NPC events (rules 19–20, Formulas D)**

- **AC-EV-33** [Logic] Rule 19. **GIVEN** an NPC-capable event carrying a cơ duyên gift, **WHEN** loaded, **THEN** it is
  rejected (player-only effect on an `npc` event).
- **AC-EV-34** [Logic] Formulas D. **GIVEN** 51 fixed-cast people, 30 known people and a sample of 200, **THEN** the
  expected NPC events are 28.1 a season, and over 400 seasons the mean is within ±5 % of it; with 600 eligible people
  the count never exceeds 40 in a season.
- **AC-EV-35** [Integration] Rule 20, NPC Traits F2. **GIVEN** a Wrathful, Vengeful NPC and options tagged aggressive /
  vengeful vs merciful, **WHEN** the NPC event runs 1,000 times with keyed seeds, **THEN** the aggressive option's share
  matches F2's weights within ±3 points.
- **AC-EV-36** [Logic] Rule 20. **GIVEN** an NPC event whose `other` is someone the player knows, **THEN** its record
  reaches the player's news; an unmarked event about strangers does not.
- **AC-EV-37** [Integration] Rule 20. **GIVEN** an NPC outcome scheduling a follow-up rooted on the player, **THEN** the
  player meets it when it falls due, under the player's pacing cap.

**Sources, text, display (rules 21–23)**

- **AC-EV-38** [Logic] Rule 21. **GIVEN** a raw event from any source with a spirit stone grant above the ceiling, an
  unknown effect and every option costing spirit stones, **THEN** the grant is clamped, the effect is dropped, a free
  exit is added, and each change is a warning.
- **AC-EV-39** [Logic] Rule 21. **GIVEN** a raw event that creates a new person, **THEN** the person exists in the World
  Database before the event is shown.
- **AC-EV-40** [Logic] Rule 22. **GIVEN** a template with `{npc}`, `{place}` and `{other_history}`, **THEN** the shown
  text has no unreplaced `{…}`; a resolved event's World Database record is its `log` line filled from data.
- **AC-EV-41** [Config/Data] Rule 22. **GIVEN** the shipped event data, **THEN** every title, text, label and outcome text
  is non-empty, and no record needs an LLM to produce player text.
- **AC-EV-42** [UI] Rule 23. **GIVEN** an event with a stat check, a fight option, a trait-added option, a hidden outcome
  and a deadly hidden outcome, **THEN** a retained screenshot shows each option's cost, chance or odds, the trait, "?"
  and the deadly warning.

**Edge cases**

- **AC-EV-43** [Logic] Edge Cases. **GIVEN** a hook raised while an event resolves, **THEN** it fires after the event,
  never nested.
- **AC-EV-44** [Logic] Edge Cases. **GIVEN** the root dies with 2 follow-ups and 1 story active, **THEN** both follow-ups
  are dropped and the story ends as failed with a record.
- **AC-EV-45** [Config/Data] Edge Cases. **GIVEN** a secret realm with no closing event, **WHEN** the data loads, **THEN**
  loading fails naming the realm.
- **AC-EV-46** [Logic] Edge Cases. **GIVEN** a save made with an event pending, 2 follow-ups and an active story, **WHEN**
  reloaded, **THEN** the next 20 session draws, the pending event, the schedule and the story stage all match.

**Feel**

- **AC-EV-47** [Playtest] Game Feel. Over a 60-minute life, do players name at least one follow-up or story event as
  "the game remembered what I did"? Does any player report events as too frequent at 2 a season?

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Price item grants into the same value budget as spirit stones (Formulas C), once Item Database prices are settled? | user + Item Database | After Item DB price pass |
| 2 | Talent (thiên phú) changes as an event effect: allowed, and with what per-event cap (Character Stats Open Question 4)? | user | Before content authoring |
| 3 | When the player loses an event fight, does the foe show mercy by its traits (spare, rob, kill), or does the authored failure outcome always decide? Capture (rule 17) is also undefined | user + Combat | Before content authoring |
| 4 | Scar threshold and size (Travel & Map Open Question 5): which events may scar the land, and by how much | user + Travel & Map | With the first scarring content |
| 5 | Content volume and order: the audit guesses 150–250 events. How many stories, how many per fixed-cast person, and which first (start origins, history's hidden places, sect quarrels)? | user | Before content authoring |
| 6 | All numbers marked *guess* (p_npc0, f_lo/f_hi, m_chain, m_story_max, n_items, n_max, cooldown, wait_seasons, stories_max, n_sample, N_max): measure in playtests and the Balance Harness | Balance Harness | First playable |
| 7 | Do quest stage events (Quests #31) spend the quest's own budget B or a chain budget? Proposed: the quest budget replaces the chain budget for its stages | user + Quests | Quests redesign |
| 8 | Is the hook list complete (rule 6)? Candidates not yet in: `on_craft_done`, `on_market_trade`, `on_teaching`, `on_birthday` | user | Before content authoring |

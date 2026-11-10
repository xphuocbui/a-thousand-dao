# Heavenly Tribulation (Thiên Kiếp)

> **Status**: Approved for rules (lean design re-review 2026-11-06); numbers provisional until the Balance Harness measures `p_t` (Open Question 2)
> **Author**: user + agents
> **Last Updated**: 2026-11-06; 2026-11-10 (#44 follow-up: regeneration, health ×4, time limit and fatigue)
> **Last Verified**: 2026-11-06
> **Build status**: On hold with the full fight (Combat). Until `tribulation_enabled` is true, no tribulation runs and Realms' fallback stands: the roll's success stands
> **Implements Pillar**: Power Is Built, Not Given (3); Every Number Is Bounded and Visible (2)

## Summary

Heavenly Tribulation is the last test before Deity Transformation: after a successful breakthrough roll the player
fights a run of three boss waves, drawn at random from a pool, with health carried between them and no changes to
the build. Clearing every wave crosses the realm with full vitality, a lasting buff and a chosen reward, and losing
any wave is death. It gives the ladder its final, build-testing climax and sets the survival chance Realms needs
for its last roll target.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Combat, Realms, Event Engine`

## Overview

Heavenly Tribulation is the last test of the last great breakthrough. When the player's pill roll for the
Deity Transformation step succeeds, the heavens answer: the character faces a short run of boss fights, each a
full Combat fight (Combat GDD) against a tribulation boss drawn at random from an authored pool. Health carries
from one wave to the next, nothing about the build can change between them, and a character that clears every
wave crosses into the new realm, comes out whole, and gains a lasting buff and a special reward. A character that loses any wave dies. The player's choices are all made before
the attempt, in the build and the preparation (formations, talismans, pills, ward, slot order, and the place the
attempt is made), and the pool is visible while the draw is not, so a build that answers only one kind of threat
is punished and a prepared, rounded build survives at the edge target (Pillar 3). Every wave explains itself through
Combat's Breakdown (Pillar 2).

This system owns the step table (which breakthroughs bring a tribulation), the boss pool and its draw, what
carries between waves, how a result becomes survival or death, and the survival chance `p_t` that Realms &
Bottlenecks needs to set the Deity Transformation roll target. It owns no fight rules: Combat resolves every wave.
Today the table holds one row, Nascent Soul to Deity Transformation. Lightning tribulations for other realms
are planned (user decision 2026-11-06) and are a new row plus new bosses, with no new rule. The boss content
itself comes later; the engine must run with any pool that passes lint. It applies to the player only: an NPC's
fate roll at the gate already contains the tribulation (Realms rule 12).

## Detailed Design

### Core Rules

Named values are defined in Formulas and live in `tribulation_rules.json` (rules) and `tribulation_bosses.json`
(the pool). Rules marked **(assumption)** are the author's reading and wait for confirmation (Open Questions).

1. **A tribulation answers a great breakthrough, and only the player's.** `tribulation_steps` is a data table of
   breakthrough steps. Today it holds one row: Nascent Soul to Deity Transformation. When the pill roll of a
   listed step succeeds (Realms rules 7 and 9), Realms hands off to this system in the same season. A step not
   in the table has no tribulation and its success stands. NPCs never run a tribulation: their fate roll at the
   gate is calibrated to include it (Realms rule 12 and Formulas C2).
2. **A tribulation is a run of waves.** It has `wave_count` waves (3, a guess), in order. Each wave is one Combat
   fight (Combat rule 1) between the player and one boss. The whole tribulation is atomic, like a fight: a pure
   function of its inputs (the compiled profile, the preparation, the place, the draw and the seed), saved at
   neither wave nor pulse, giving the same result and logs every time. The attempt, its pill and roll and the
   tribulation form one unit: nothing is saved between them.
3. **Bosses come from a pool.** Each record in `tribulation_bosses.json` is an enemy profile in Combat's sense
   (rule 18) plus the steps it serves, a draw `weight`, a `main_kind` (body, qi or soul: the kind with the largest
   share of its offence) and a `reward` (rule 9). It has no realm field: suppression always uses the step's destination realm (rule 6). A boss is not a
   cultivator and not a creature that can be tamed. The pool is content added later by data, with no new rule.
4. **The draw.** At the hand-off one seeded stream draws `wave_count` distinct bosses from the pool for that step,
   weighted, without replacement, and fixes the whole list. A boss is revealed when its wave begins. The stream's
   seed is the **tribulation id**: a hash of the world seed, character id, step, season and **setup hash**, a canonical
   hash of the compiled profile and the preparation. Any change to the setup changes the draw, so what a death
   revealed is useless after a reload (user decision 2026-11-06). The id is derived, so it needs no saving.
5. **Preparation comes before the attempt.** The situation is Foreseen (Combat rule 12): everything can be
   prepared, and the setup is fixed when the player confirms the attempt, which is the commitment. The compiled
   profile, ward, slot order and prepared items serve every wave, and nothing can be changed between waves. While
   preparing, the player sees the pool for the step: each boss's full profile, as Combat's preparation shows an
   enemy, and its draw `weight`, but not the draw (user decision 2026-11-06). The ground tags are those of the place of the attempt plus the tag `tribulation`, so a place
   with a vein or a laid formation counts.
6. **The player fights as the realm being left.** The profile compiles at the pre-breakthrough realm and stage.
   The boss's realm for the gap `g` is always the step's destination realm, so the player is
   one realm below and suppression applies, with pierce reducing it (Combat rule 20).
7. **What carries between waves.** Health carries exactly, with no floor and no healing. Linh lực carries and then
   recovers `rest_pulses` pulses of regeneration, up to its maximum (Formulas B). Talisman and consumable stock
   carries: what a wave used is gone. Everything else starts fresh in each wave: statuses, curses, art timers
   (every art on its full cooldown, Combat rule 10), triggers, wards and escape channels. Pill effects taken in
   preparation last through the whole tribulation (user decision 2026-11-06). Each later wave sends Combat its starting
   shares for health and linh lực (Combat rule 3).
8. **Only a knockout win clears a wave.** The player must win the wave's fight by knockout. Every other ending
   fails the tribulation: the player Down, a draw, or a flight (an escape art that
   succeeds also fails it, so a slotted escape art is a wasted slot, and preparation warns of it).
9. **Surviving.** When every wave is cleared, the character has survived. This system reports survival to Realms,
   which moves the character to the early stage of the next realm with vitality full and fires
   `breakthrough_succeeded` (Realms rule 9). No vitality loss applies: the breakthrough remakes the body. The
   character also gains (user decision 2026-11-06; the form below is an **assumption**):
   - **The tempered buff.** A lasting sheet line, `tribulation_tempered`, for the rest of the life. Its stat keys and
     amounts are data, held to a budget of `tempered_buff_w` W (Formulas E).
   - **A special reward.** The player chooses one reward from the `reward` entries of the bosses it beat, which are
     authored on the boss records with the pool. Rarity and value bounds come from the Item Database.

   This system decrements spent stock once, after the run, and the World DB records the event with the bosses
   faced and the waves cleared.
10. **Failing is death.** Losing a wave kills the character (user decision 2026-11-06, as the Realms state table
    already says). Spent stock is decremented as on survival. The death is recorded with the cause `tribulation`, the waves cleared and the boss that ended
    the run. There is no mercy, capture or taming. The knockout of a boss never counts for capability #9
    because a boss is not a cultivator.
11. **Randomness.** The draw is the only randomness this system adds. Each wave's fight seed derives from the
    tribulation id and the wave number, so the same save and setup always give the same draw and result, and a
    changed setup gives a new draw and new fights.
12. **The pool must cover the threats.** For each step, the data lint requires at least `wave_count` bosses, and at
    least one boss whose main threat kind is each of body, qi and soul, so a one-note build meets something it
    cannot answer in some draws. The authoring target is `pool_target` bosses per step (Formulas D).
13. **The result explains itself.** The result lists, per wave: the boss, how the fight ended, its time, the
    player's health and linh lực at the end, and the deciding layer. It also gives the waves cleared and the final
    ending. Each wave's full Combat log is kept (Pillar 2).

### States and Transitions

| State | Entered when | Leaves when |
|---|---|---|
| Handed off | Realms reports a successful roll on a step in the table | The draw is made |
| Drawn | The `wave_count` bosses are fixed | Wave 1 begins (same moment) |
| Wave k (Combat: Running) | The previous wave was cleared (or this is wave 1) | The fight ends |
| Survived | Wave `wave_count` is cleared | Realms reads the result |
| Failed | Any wave ends in anything but a player knockout win | Realms reads the result |

| Transition | Condition | Effect |
|---|---|---|
| Wave k to Wave k+1 | Player knockout win, k below `wave_count` | Carry-over of rule 7 |
| Wave k to Survived | Player knockout win, k equal to `wave_count` | Realms: next realm, `breakthrough_succeeded`; the buff and the reward choice |
| Wave k to Failed | Down, draw or flight | Realms: Dead, cause `tribulation` |

### Interactions with Other Systems

Event Engine, Alchemy, Talismans and Formations have no GDD yet. Rows marked **provisional** hold the contract this
GDD expects.

| System | Direction | What flows | Owner of the interface |
|---|---|---|---|
| Combat (#21) | out / in | Out: one fight request per wave (the compiled profile, the boss profile, situation Foreseen, the player as requesting side, ground tags, a fight id, starting health and linh lực shares). In: the result of the fight | Combat (fight engine and result); this GDD (waves, carry-over) |
| Realms & Bottlenecks (#8) | in / out | In: the hand-off after a successful roll on a listed step. Out: survival or death. The survival chance feeds the Deity Transformation roll target `0.20 ÷ max(p_t_ref, 0.20)` | Realms (steps, roll, level change); this GDD (`p_t`, outcome) |
| Character Stats (#7) | out | The `tribulation_tempered` sheet line after survival | Character Stats (keys); this GDD (the buff) |
| Item Database (#13), Talismans (#18), Alchemy (#15) | in / out | In: stock used in the waves; pill timed effects, which hold for every wave whatever duration Alchemy later defines (**provisional**). Out: the chosen reward item | the preparing system; Item Database (reward bounds) |
| Formations (#17), Travel & Map (#25) | in | The place's ground tags and any laid formation (**provisional**) | Formations; Travel & Map |
| Event Engine (#23) | out | The result as an event for the news and the death or survival record | Event Engine |
| World Database (#3) | out | The event record of the tribulation | World DB |
| LLM Game Master (#29) | out | The result, boss names and wave summaries for narration and the epitaph (numbers checked as elsewhere) | LLM Game Master |
| Balance Harness (#33) | out | A headless tribulation run and the `p_t` measurement | Balance Harness |
| Debug Terminal (#36), Game UI (#37) | out | The pool, the preparation data, the per-wave log | the presentation system |

## Formulas

All values are guesses until the Balance Harness runs real tribulations. Combat's own win rates are provisional
(Combat Open Questions 6 and 20), and the full fight is on hold, so nothing here has been simulated.

**Reference builds.** "Edge" means the Combat Formulas B top-end anchors and "baseline" means the typical anchors,
both at the end of Nascent Soul. Combat's anchor table gives ehp in fight units (94 typical and 315 top-end), and
`U_r` is 100 at Nascent Soul, so the figures below (9,400 and 31,500) are those units times 100. With the suppression of g = 1 and assumed attack rates, top-end has Off about
90,000 per second and ehp 31,500, and typical has Off about 1,500 and ehp 9,400. Fight power F = Off × ehp is
about 2.8e9 and 1.41e7, so the two differ by about 200×.

### A. Wave strength

The wave_pool formula is defined as:

`w_k = pool_ramp ^ (k − 1)` ; `m_eff = min(m_cap, boss_pool_mult · w_k)`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| k | int | 1 to `wave_count` | calculated | Wave number |
| wave_count | int | 1–5, default 3 (guess) | data file | Waves in a tribulation |
| pool_ramp | float | 1.0–2.0, default 1.5 (guess) | data file | Growth of a boss's pools per wave |
| w_k | float | ≥ 1 | calculated | Wave multiplier |
| boss_pool_mult | float | 1 to `bm_max` | data file (boss record) | The boss's authored multiplier |
| bm_max | float | 1.5 | data file | Keeps the ramp in charge: at or below `pool_ramp`, so a later wave is never weaker whatever the draw |
| m_cap | float | 10 | constant (Combat `boss_pool_mult` range) | Combat's ceiling |
| m_eff | float | 1–10 | calculated | The `boss_pool_mult` sent to Combat |

The ramp is on pools only. It needs no new Combat key, keeps the Breakdown readable and still raises lethality,
because a longer fight lets the boss deal more. A damage ramp would need a new key and would spike past what a
ward can absorb.

**Output Range:** 1 to 3.4 at the defaults. The lint keeps `bm_max · pool_ramp ^ (wave_count − 1) ≤ m_cap`, so the
cap is never reached in play, and `wave_count` 6 at the defaults fails it (11.4).

**Example:** `boss_pool_mult` 1.2 at waves 1, 2 and 3 gives **1.2, 1.8 and 2.7**.

### B. Carry-over

The carry_over formula is defined as:

`h_next = health_end / health_max` ; `q_next = min(qi_max, qi_end + rest_pulses · qi_max · (regen_base + regen_k · ln(1 + regen_bonus / regen_k))) / qi_max` (Combat Formulas E: a log curve, no cap)

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| health_end, qi_end | float | health above 0; linh lực ≥ 0 | calculated (Combat result) | The player's pools when the wave ended |
| health_max, qi_max | float | about 6,400 (×4 since #44) and 2,600 at typical Nascent Soul | calculated (Combat Formulas A) | Unchanged across waves |
| rest_pulses | int | 0–12, default 8 (guess) | data file | Pulses of linh lực regeneration between waves |
| regen_base, regen_bonus, regen_k | float | 0.035; ≥ 0; 0.08 | Combat Formulas E | Regeneration per pulse, with diminishing returns on the bonus (#44) |
| h_next, q_next | float | above 0 to 1; 0 to 1 | calculated | Starting shares sent to Combat for the next wave |

Wave 1 starts by Combat's ordinary rule, with its vitality floor. Later waves start from these shares exactly, with
no floor. Health gets nothing from the rest. `rest_pulses` stays at or below 12 because a full sustain build
refills in 13, and carried linh lực must still matter.

**Output Range:** h above 0 to 1. q at least `rest_pulses · regen_base`, up to 1.

**Example:** `qi_max` 2,600, `health_max` 1,600. A wave ends at 700 health and 300 linh lực. With no bonus the rest adds
8 × 52 = 416, so the next wave starts at **h 0.4375** and **q 0.275**. A full sustain build adds 1,664 and starts at
**q 0.755**.

### C. Survival chance

The survival_chance formula is defined as:

`p_t = Σ_D Pr(D) · Π_k P(win_k | state_k)`, measured as `p_t_hat = tribulations survived / N` ; `roll_target = 0.20 / max(p_t_ref, 0.20)`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| D, Pr(D) | set, float | 0–1 | calculated | A draw and its chance under rule 4 |
| P(win_k \| state_k) | float | 0–1 | measured | A knockout win of wave k from the carried state |
| N | int | ≥ 2,000, default 4,000 (guess) | harness setting | Tribulations run per build, each with a true draw and a fresh seed |
| p_t_edge, p_t_base | float | 0.90; 0.50 (user decision 2026-11-06) | data file (targets) | Mean over the harness's edge and baseline builds. Edge may be off by ±0.03 and baseline by ±0.05; each edge build stays at or above 0.80 (guesses) |
| p_t_ref | float | 0–1 | measured | The measured edge mean, which Realms uses |
| roll_target | float | 0.2–1 | calculated | The Deity Transformation roll target (Realms Formulas E) |

The harness runs whole tribulations with real Combat fights. It reports `p_t_hat`, its standard error, and the
failures split by ending, by wave and by boss kind. Fights are near-deterministic (Combat rule 15), so a build's
survival rests mostly on the draw: 0.50 means half of the draws, not a coin toss in each fight.

**Output Range:** `p_t` 0 to 1. `roll_target` 0.20 to 1.

**Example:** `p_t_ref` 0.90 gives a roll target of **0.222**; a measured 0.84 gives **0.238**.

The wave_loss pre-check is defined as:

`r_b = F_boss / F_player` ; `loss_k = r_b · w_k` ; `Σ loss_k` above 1 means the run fails

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| F_boss, F_player | float | > 0 | calculated (Combat Formulas K) | Fight power at wave 1 strength, F = Off × ehp |
| r_b | float | 0.10–0.35 against baseline (guess) | calculated | The power band of a boss |
| loss_k | float | ≥ 0 | calculated | Share of the player's ehp that wave k costs |

A wave lasts `ehp_boss · w_k / Off_player` and costs `Off_boss` per second of it, which divided by the player's ehp
gives `r_b · w_k`. This is an estimate for authors (the lint checks `r_b` alone), and it ignores the linh lực the rest returns.

**Output Range:** at the defaults Σ w_k is 4.75, so a run of equal bosses survives only below r_b 0.21.

**Example:** a boss with Off 400 and ehp 8,000 has F 3.2e6, so r_b is 0.227 against baseline: **22.7 %, 34.0 % and
51.1 %**, 108 % in all. An average draw just kills a baseline build and a below-average one lets it through, which
is the 0.50 target. Against edge the same boss has r_b about 0.001, so an edge build loses only to a boss it has no
answer for. **One knob cannot tune both targets:** pool and offence set baseline, and threat kinds set edge. If the
harness measures edge at 0.99, the fix is bosses that counter more builds, not more pool.

### D. Boss lint

The data lint checks every record in `tribulation_bosses.json`. Each of the values below is a data file key and a guess.

| Check | Rule |
|---|---|
| Multiplier | `1 ≤ boss_pool_mult ≤ bm_max`, and `bm_max ≤ pool_ramp` |
| Ramp | `pool_ramp ≥ 1`, and `bm_max · pool_ramp ^ (wave_count − 1) ≤ m_cap` |
| Power band | r_b against the baseline reference is within `band_min` 0.10 and `band_max` 0.35 |
| Kill time | The baseline reference kills the boss at the last wave's `m_eff` within `stall_time` (60 s, before Combat's fatigue starts; #44; was 0.5 · `time_limit`, retired 2026-11-10), by the Combat Formulas K estimate, so no boss forces the player into fatigue |
| Soul share | At most `soul_share_max` 0.5 of the boss's offence is soul |
| Arts | 2 to 5 arts, each passing Combat's art lint, and no escape art: a boss's flight would end a wave with no knockout |
| Realm | A boss record has no `equiv_realm` key (rule 6): a record that carries one is rejected |
| Weight | `weight` above 0 |
| Coverage | Rule 12; `main_kind` matches the boss's largest offence share; and once the pool reaches `pool_target` 6, no `main_kind` holds above `kind_share_max` 0.5 of a step's pool weight |
| Reward | Every boss has a `reward` that passes the Item Database's bounds |

### E. The tempered buff

The tempered_buff formula is defined as:

`Σ (amount_key · W_key) ≤ tempered_buff_w`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| amount_key | float | ≥ 0 | data file (`tribulation_steps` row) | Each stat key's amount in the buff |
| W_key | float | > 0 | data file (Character Stats `stat_power_weights`) | The W price of a point of that key |
| tempered_buff_w | float | 0–120, default 60 (guess) | data file | The buff's budget, about 5 % of the 1,172 W a full tree holds at Deity Transformation |

**Output Range:** 0 to `tempered_buff_w`. A row over budget fails the lint.

**Example:** +30 `attack_pct` at 1 W a point and +30 `defense_pct` at 1 W a point cost **60 W**, inside the budget.

## Edge Cases

`systems-designer` reviewed the formula boundaries. It was not consulted on this section as a whole (Lean mode).

**Endings**

- **If the player wins a double knockout on overkill (Combat rule 10):** it is a knockout win. The wave is cleared and the player carries 1 health.
- **If a wave ends in a draw:** the tribulation fails and the character dies. A draw's `wound: grave` never reaches a caller here.
- **If a wave runs past 60 s:** Combat's flat fatigue (Combat rule 10) grows as n² for both sides, and the boss's larger pool outlasts the player's, so the player falls and the character dies, even with most of its health left at 60 s. A build that cannot kill cannot cross (there is no time limit or stalemate since 2026-11-10).
- **If an escape art succeeds:** the flight fails the tribulation and the character dies. The exception is Combat's own rule: if the boss's health is 0 or below at that point, it is a knockout win and the wave is cleared.
- **If the last wave is won with 1 health:** the character survives and comes out at full vitality with the buff, like any survivor.

**Carry-over**

- **If the player starts a later wave with almost no health:** the share is used exactly, with no floor, and the next hit may end the run.
- **If linh lực ends a wave at 0:** the rest still returns `rest_pulses` of regeneration. At `rest_pulses` 0 the next wave starts with an empty pool, no ward and no arts but the basic attack.
- **If a regeneration curse was active when the wave ended:** curses do not carry, so the rest regenerates normally.
- **If vitality is below the Combat floor at the attempt:** wave 1 starts at the floor. The floor is not applied again in later waves.
- **If a talisman's stock ran out in an earlier wave:** it is skipped in later waves (Combat rule 13).
- **If a trigger has a once-per-fight limit:** it renews each wave, because each wave is a new fight. Combat has no revive effect, so this adds no second life.

**The draw and the pool**

- **If a step's pool has fewer than `wave_count` bosses, or none:** the data lint rejects it at load, so a listed step can never reach a tribulation with no bosses.
- **If a roll succeeds on a step not in `tribulation_steps`:** there is no tribulation and the success stands.
- **If a later attempt happens in a different season, or the setup changes in any way:** the draw differs, because both are in its seed.
- **If a reload changes nothing:** the same setup gives the same draw and the same result.
- **If the player beat bosses with the same `reward`:** the choice lists it once.
- **If `m_eff` would pass `m_cap`:** it stops at the cap and the log says so. The lint prevents this in authored data.

**Timing and saves**

- **If any successful roll hands off, including an extra roll from capability #23:** the tribulation runs the same way.
- **If the game closes during a tribulation:** nothing was saved, because it is atomic. A reload returns to before the attempt, and the same setup gives the same result.
- **If the character is near its lifespan cap:** the tribulation resolves inside the attempt's season, and age is then checked as Realms says.
- **If the character has already crossed the step:** it never faces it again. Stage losses do not cross a realm (Realms).
- **If `tribulation_enabled` is false (until the full fight is built):** no tribulation runs. Realms' fallback stands and the roll's success stands.

**Degenerate strategies watched for**

- **Stacking pure defence:** fatigue ends the wave with the player Down, which is death (rule 8).
- **Healing between waves:** health carries exactly and the rest touches only linh lực.
- **Reloading to learn the draw:** a changed setup draws again, so a death teaches nothing about the next try. The cost, accepted by the user (design review 2026-11-06), is that a small setup change re-rolls the draw for free after a reload. Reloading to before the attempt is allowed, as with any save: the death is final for an ironman save, and this system adds no lock of its own.
- **Maximum sustain:** bounded by regeneration's diminishing returns (`regen_k`) and the limit on `rest_pulses`.

## Dependencies

**Upstream (this system needs these).**

| System | Type | Interface | State |
|---|---|---|---|
| Combat (#21) | Hard | The fight engine, enemy profiles, starting shares, the result | Approved for rules; build on hold |
| Realms & Bottlenecks (#8) | Hard | Hand-off, level change, `breakthrough_succeeded`, Dead | GDD in review; lists this system |
| Character Stats (#7) | Hard | The `tribulation_tempered` modifier source (a sheet line, using existing stat keys); `stat_power_weights` | GDD in review; lists this system as a modifier source |
| Sim Core (#2), Config (#1) | Hard | Seeded stream, `tribulation_rules.json`, `tribulation_bosses.json` | Built, no GDD |
| Item Database (#13) | Soft | Consumable stock; reward bounds | GDD approved; lists this system as a downstream reader of its bounds |
| Talismans (#18), Alchemy (#15), Formations (#17) | Soft | Prepared items | Quick spec or no GDD; **provisional** |
| Travel & Map (#25) | Soft | The place's ground tags | Built, no GDD; **provisional** |
| Quests (#31) | Soft | None at runtime. The reward content pass waits on it (Open Question 9) | GDD in review |

**Downstream (these need this system).**

| System | Type | Interface | State |
|---|---|---|---|
| Realms & Bottlenecks (#8) | Hard | Survival or death; `p_t` for the roll target | Open Question 2 there waits on the measurement |
| Event Engine (#23) | Soft | The event for the news and records | Built, no GDD |
| The Way (#39) | Soft | Lôi, Kiếp and Nghịch Đạo facets act on the tribulation; breakthrough and heart-demon Effects carry bot fixtures | In review (`dao.md`) |
| World Database (#3) | Soft | The tribulation record | Built, no GDD |
| LLM Game Master (#29) | Soft | Result and summaries for narration and the epitaph | Built, no GDD |
| Balance Harness (#33) | Hard | Headless tribulation runs | Built, no GDD |
| Debug Terminal (#36), Game UI (#37) | Soft | Pool, preparation data, wave log | Terminal built, Game UI not started |

**Bidirectional check.** Realms and Combat already list this system. The systems index names the Event Engine as a
dependency: it is a soft, downstream one here, because Combat lets this system open fights directly.

**Combat sub-systems (back-references added by the Combat revision #43, 2026-11-08).** This system and the four
systems split out of Combat depend on each other as follows.

- **Combat Defence & Healing (#21a):** every wave sets `no_heal`; soul and status defence apply as in any fight.
- **Combat Damage Types (#21b):** tribulation lightning deals Lightning, so Lightning resistance is the answer.
- **Effects System (#41):** refusals and last acts run at Down as in any fight (the Down step).

## Tuning Knobs

All live in `tribulation_rules.json` unless stated, and are guesses until the Balance Harness runs (Open Question 2).

| Knob | Safe range | Default | Affects |
|---|---|---|---|
| `wave_count` | 1–5 (the ramp lint bounds it) | 3 | Run length and lethality; each wave multiplies the chance of a draw that beats the build |
| `pool_ramp` | 1.0–2.0 (not below `bm_max`) | 1.5 | How much harder later waves are; mostly sets the baseline survival chance |
| `bm_max` | 1.0–`pool_ramp` | 1.5 | How far one boss can stand apart from the ramp |
| `rest_pulses` | 0–12 | 8 | Linh lực recovered between waves; the reward for sustain builds |
| `band_min`, `band_max` | 0.05–0.50 (min below max) | 0.10, 0.35 | Boss power against a baseline build; sets the baseline target |
| `stall_time` | 50–60 s | 60 s (#44, before fatigue; was `stall_share` 0.5 of the retired `time_limit`) | How long a baseline build may take to kill a boss |
| `soul_share_max` | 0.2–0.7 | 0.5 | How much of a boss's offence may be soul, which most builds cannot ward |
| `kind_share_max`, `pool_target` | 0.34–0.7; 3–12 | 0.5; 6 | How varied a pool must be, so no build type dominates the draw |
| `tempered_buff_w` | 0–120 | 60 | Size of the survivor's lasting buff |
| `tribulation_enabled` | true or false | false until the full fight is built | Whether any tribulation runs |
| `p_t_edge`, `p_t_base` and tolerances | edge 0.8–0.95; baseline 0.3–0.7 | 0.90; 0.50 | The measurement targets, not a rule |

## Visual/Audio Requirements

`art-director` not consulted (Lean mode). Review manually before production. Today's surface is the Debug Terminal;
assets are deferred with the Game UI (#37).

- **Terminal.** A clear header per wave names the wave number and the boss. The tribulation's start and its end
  are marked in the log. Combat's colour and naming rules for damage lines apply.
- **Game UI intent.** The scroll darkens as clouds gather and each wave is a new sheet, with numbers kept in the print layer (art pillar "Numbers in print"). Bosses are shown as glyphs from their tags (art pillar "Glyphs, not paintings").
- **Events that need a visual and a sound later:** tribulation begins, wave begins, boss revealed, wave cleared, survival, death.

## Game Feel

The tribulation is read, not played, so feel means dread and release.

- **Before:** confirming the attempt should feel like a real commitment. The player knows the pool and the risk, and sees what the build has no answer for.
- **During:** a reveal between waves is the tension beat. Each wave shows the boss first, then the fight, and the health left is always in view, so a falling bar is the story.
- **After:** survival is the biggest moment of a life and earns its own screen, with the reward choice as its payoff. A death names the wave and the boss, and points at what the build lacked.

## UI Requirements

| Screen or element | Must show | Must allow |
|---|---|---|
| Attempt confirmation | The pill roll's chance, a tribulation warning, `wave_count`, the pool (each boss's full profile and draw weight), the player's setup, a warning for a slotted escape art | Prepare, confirm or back out |
| Wave header | Wave number, the revealed boss, starting health and linh lực | Continue |
| Fight log | As Combat's fight log | Open a hit's Breakdown |
| Result | Survived or died, each wave's boss, ending, time, health and linh lực left, deciding layer; on survival, the buff and the rewards on offer | Choose one reward; continue |

All of these work in the Debug Terminal first, with numbered menus as elsewhere.

> **📌 UX Flag — Heavenly Tribulation:** this system has UI requirements. In Pre-Production, run `/ux-design` for
> the attempt confirmation and the wave and result screens before writing epics. Stories that touch this UI should
> cite `design/ux/[screen].md`, not this GDD.

## Cross-References

| This GDD | Refers to | Mechanic or value | Note |
|---|---|---|---|
| Rules 1, 9, 10, Formulas C | canh-gioi.md rules 7, 9, 12, Formulas C2, E, Open Question 2 | Hand-off, success, Dead, NPC fate, `0.20 ÷ p_t` | Read only |
| Rules 2, 8, Formulas B | combat.md rules 1, 3, 10, 14, Formulas A, E | Atomic fight, starting shares, endings, regeneration | Starting shares added to Combat rule 3 on 2026-11-06 |
| Rule 3, Formulas A, D | combat.md rule 18, Formulas A, K, AC-CB-54 | Enemy profile, `boss_pool_mult`, art lint, F | The 4-second boss rule exempts tribulation bosses (user decision 2026-11-06) |
| Rule 6 | combat.md rule 20, Formulas H | Gap `g`, suppression, pierce | Read only |
| Rule 5 | combat.md rule 12 | Foreseen preparation | Read only |
| Rule 9 | canh-gioi.md rule 9 | Vitality full on success | Read only; a survivor takes no vitality loss |
| Rule 9, Formulas E | character-stats.md; registry `stat_power_weights` | The buff's sheet line and W prices | `tribulation_tempered` is a modifier source in Character Stats' Dependencies, not a new stat key |
| Rule 9 | item-database.md | Reward bounds | To be matched |

## Acceptance Criteria

Drafted by qa-lead, then updated by the main session for the rulings after its report (survivor's buff and reward, the setup hash, the lint fixes). Nothing has run. Sampling ACs use fixed seed lists, so they are deterministic. **OQ1** marks an AC that uses Combat's starting shares (Open Question 1, closed). A section tag applies unless an AC carries its own.

Evidence: `tests/unit/tribulation/`, `tests/integration/tribulation/`, `production/qa/evidence/balance/`, `production/qa/evidence/debug-terminal/`.

**Fixtures.** Used throughout unless stated; full precision, tolerance ±0.0001.

- **FX-R:** `wave_count` 3, `pool_ramp` 1.5, `bm_max` 1.5, `m_cap` 10, `rest_pulses` 8, `regen_base` 0.035, `regen_k` 0.08, band 0.10–0.35, `stall_time` 60, `soul_share_max` 0.5, `kind_share_max` 0.5, `pool_target` 6, `tempered_buff_w` 60, `tribulation_enabled` true.
- **FX-P:** Nascent Soul great perfection, `health_max` 1,600, `qi_max` 2,600, v 1.0, `regen_bonus` 0, Off 1,500, ehp 9,400 (also the lint baseline).
- **FX-B:** boss, Off 400, ehp 8,000, `boss_pool_mult` 1.0, 2 arts, soul share 0.25, a fixture `reward`.
- **FX-POOL:** six FX-B: B1, B2 (`main_kind` body), Q1, Q2 (qi), S1, S2 (soul), weights 2, 1, 2, 1, 2, 1, each with its own `reward` and its offence shares set to match.
- **FX-STUB:** injected fight function; records requests, returns scripted results (default: player knockout win).

**Hand-off** [Logic]. When the roll succeeds:

- **AC-TK-01** Rule 1. Given a listed step, then a tribulation starts in the same season.
- **AC-TK-02** Rule 1. Given an unlisted step, then no tribulation starts and the success stands.
- **AC-TK-03** Edge. Given a capability #23 extra roll, then one tribulation starts.
- **AC-TK-04** Edge. Given `tribulation_enabled` false, then no tribulation starts and the success stands.

**Run** [Logic]

- **AC-TK-05** [Integration] Rule 1. Given fated NPCs at the last gate, when 100 seasons tick, then the tribulation entry is never called.
- **AC-TK-06** Edge. Given a Deity Transformation character that lost stages, when seasons pass, then no tribulation starts.
- **AC-TK-07** Edge. Given one season of lifespan left, when the character survives, then the age check follows the result.
- **AC-TK-08** Rule 2. Given all wins, when a run ends, then 3 requests went out in order, one boss each.
- **AC-TK-09** Rules 2, 11. Given identical inputs, when run twice, then results and logs are byte-identical.
- **AC-TK-10** [Integration] Rule 2. Given a pre-attempt save, when a run aborts in wave 2 and reloads, then state equals that save.
- **AC-TK-11** [Integration] Edge, OQ1. Given that reload and setup, when re-attempted with real Combat, then draw and result match an uninterrupted run.
- **AC-TK-12** [Integration] Rule 3, OQ1. Given a boss added only as fixture JSON, when drawn, then real Combat fights complete with no code change.

**Draw and seeds** [Logic]. When the draw is made:

- **AC-TK-13** Rule 4. Given 1,000 seeds, then every list holds 3 distinct bosses.
- **AC-TK-14** Rule 4. Given 10,000 seeds, then wave 1 is a given weight-2 boss 0.2222 and weight-1 boss 0.1111 of the time (±0.02).
- **AC-TK-15** Rule 4. Given those seeds, then a weight-2 boss is in 0.6262 of lists, a weight-1 boss in 0.3738 (±0.02).
- **AC-TK-16** Edge. Given 20 consecutive seasons, other keys equal, then the lists include at least 5 distinct lists.
- **AC-TK-17** Rules 4, 11. Given the same setup twice, then the lists are identical. Given 20 setups that each differ by one slot, then at least 5 distinct lists appear.
- **AC-TK-18** Rule 4. Given a run, when wave 1 begins, then the log names no later boss.
- **AC-TK-19** Rule 11. Given one tribulation id, when waves 1–3 run, then the fight seeds differ.
- **AC-TK-20** Rule 11. Given an outer generator, when a run completes, then its state is unchanged.
- **AC-TK-21** Rule 4. Given a save, when it is reloaded with no setup change, then the tribulation id is the same.

**Setup** [Logic]. When waves are requested:

- **AC-TK-22** Rule 5. Given a confirmed attempt, then profile, ward, slot order and items match across requests.
- **AC-TK-23** Rule 5. Given a place tagged `vein`, then the situation is Foreseen, the player is the requesting side, and ground tags are exactly `vein`, `tribulation`.
- **AC-TK-24** Rule 6. Given FX-P and FX-B, then the profile is compiled at Nascent Soul great perfection with gap `g` 1.

**Carry-over** (all OQ1) [Logic]. Integration ACs here use real Combat. When the next wave is requested:

- **AC-TK-25** Rule 7. Given a wave ending at 2,800 health (health_max 6,400), then h is 0.4375.
- **AC-TK-26** Formulas B. Given 300 linh lực at wave end, then q is 0.39538 (8 pulses at 3.5 %).
- **AC-TK-27** Formulas B. Given 300 and `regen_bonus` 0.06, then q is 0.75354; given 0.10, q is 0.91438 (log curve, `regen_k` 0.08).
- **AC-TK-28** Formulas B. Given 2,400, then q is 1.0.
- **AC-TK-29** Edge. Given 0, then q is 0.16; at `rest_pulses` 0, q is 0.
- **AC-TK-30** Edge. Given 300 and a regeneration curse active at wave end, then q is 0.27538.
- **AC-TK-31** Rule 7. Given 3 talismans and wave 1 spending 2, then stock is 1.
- **AC-TK-32** Rule 7. Given a prepared pill, then all 3 requests carry its effect.
- **AC-TK-33** [Integration] Edge. Given v 0.3, then wave 1 starts at 640 health; wave 1 ending at 500, wave 2 starts at 500.
- **AC-TK-34** [Integration] Rule 7. Given a status and curse at wave end, then neither is present next wave.
- **AC-TK-35** [Integration] Rule 7. Given wave 2 at t = 0, then every art timer is at full cooldown.
- **AC-TK-36** [Integration] Edge. Given a once-per-fight trigger spent in wave 1, then it can fire in wave 2.
- **AC-TK-37** [Integration] Edge. Given a talisman exhausted in wave 1, then wave 2 skips it without error.

**Endings** [Logic]. When wave 2 returns the scripted result:

- **AC-TK-38** Rule 8. Given player Down, then the run is Failed and no wave 3 request is sent.
- **AC-TK-39** Edge. Given a draw at 1 health, `wound: grave`, then Failed.
- **AC-TK-40** Edge. Given a wave still running at 66 s with both sides falling to fatigue together (a draw), then Failed; given a boss pool larger than the player's at 60 s and no damage dealt after, then the player falls to fatigue first and the tribulation is Failed.
- **AC-TK-41** Edge. Given the player Fled with boss health above 0, then Failed.
- **AC-TK-42** Edge. Given the player Fled, boss health 0, Combat reporting a knockout win, then the wave clears.
- **AC-TK-43** Edge, OQ1. Given a double-knockout win at 1 health, then the wave clears and next h is 0.000625.

**Outcome** [Integration], real Realms on FX-STUB. When the run ends:

- **AC-TK-44** Rule 9. Given 3 clears, then Realms sets level 101, early Deity Transformation, bar 0.
- **AC-TK-45** Rule 9. Given 3 clears, then `breakthrough_succeeded` fires once, after wave 3, not at the roll.
- **AC-TK-46** Rule 10. Given a failure at any wave, then `breakthrough_succeeded` never fires.
- **AC-TK-47** Edge. Given wave 3 won at 1 health, then the character survives.
- **AC-TK-48** Rule 9. Given waves ending at 1,200, 800, 400, then vitality is full after the run and no vitality loss is applied.
- **AC-TK-49** Rule 9. Given survival, then the sheet holds `tribulation_tempered` with the step's keys, and it is still there after a save and reload.
- **AC-TK-50** Rule 10. Given a failure, then no buff and no reward are granted.
- **AC-TK-51** Rule 9. Given bosses B1, Q1 and S1 beaten, then the choice lists their 3 rewards and exactly the chosen one enters the inventory.
- **AC-TK-52** Edge. Given two beaten bosses with the same `reward`, then the choice lists it once.
- **AC-TK-53** Rules 9, 10. Given 2 talismans spent, on survival or on death, then stock falls by 2 once, after the run.
- **AC-TK-54** Rule 9. Given survival, then World DB holds one record with 3 bosses and 3 waves cleared.
- **AC-TK-55** Rule 10. Given wave 2 lost to Q1, then the character is Dead, cause `tribulation`, waves cleared 1, boss Q1.
- **AC-TK-56** Rule 10. Given capability #9 and 3 boss knockouts, then Realms receives no defeat.
- **AC-TK-57** Rule 10. Given a lost wave, then no mercy, capture or taming is offered.
- **AC-TK-58** [Logic] Rule 13. Given any run, then each wave lists boss, ending, time, health, linh lực and deciding layer, with waves cleared and final ending.
- **AC-TK-59** [Logic] Rule 13. Given 3 waves, then 3 full Combat logs are kept.

**Formulas** [Logic]. When computed:

- **AC-TK-60** A. Given `boss_pool_mult` 1.2, then `m_eff` is 1.2, 1.8, 2.7.
- **AC-TK-61** A, edge. Given mult 1.5, ramp 2, k 5, then `m_eff` is 10, not 24, and the log says so.
- **AC-TK-62** C. Given `p_t_ref` 0.90, 0.84, 0.10, 1.0, then `roll_target` is 0.22222, 0.23810, 1.0, 0.20.
- **AC-TK-63** C. Given FX-B against FX-P, then `r_b` is 0.22695 and `loss_k` 0.22695, 0.34043, 0.51064.
- **AC-TK-64** C. Given those, then the sum 1.07801 reads as failing; equal bosses at 0.21 sum 0.9975, not failing.
- **AC-TK-65** [Integration, Bot: Balance Harness] C. Given FX-STUB losing only to S1, N 4,000, then `p_t_hat` is 0.37381 (±0.005; the exact value is 1 − 0.62619 from the draw odds of AC-TK-15, so the tolerance is sampling noise on the fixed seed list only).
- **AC-TK-66** [Bot: Balance Harness] C. Given 3,600 of 4,000 survived, then `p_t_hat` is 0.90, standard error 0.00474, with failures split by ending, wave, boss kind.
- **AC-TK-67** [Integration, Bot: Balance Harness] **Provisional**, OQ1, Open Questions 2, 3. Given the real pool, then edge mean is 0.90 ±0.03, baseline 0.50 ±0.05, each edge build at least 0.80.

**Lint** [Config]. Given FX-POOL with the named change, when lint runs at load, then:

- **AC-TK-68** Multiplier. `boss_pool_mult` 1.0, 1.5 pass; 0.99, 1.51 or `bm_max` 1.6 are rejected.
- **AC-TK-69** Ramp. `wave_count` 5 passes (7.59375); 6 (11.390625) or `pool_ramp` 0.99 are rejected.
- **AC-TK-70** Power band. Off 400, ehp 3,525 or 12,337.5 passes; 3,500 (0.09929) or 12,500 (0.35461) are rejected.
- **AC-TK-71** Kill time. Off 200, ehp 20,000 passes (30.0 s); 20,100 is rejected (30.15 s).
- **AC-TK-72** Soul share. 0.50 passes; 0.51 is rejected.
- **AC-TK-73** Arts. 2, 5 pass; 1, 6, one art failing Combat's art lint, or an escape art are rejected.
- **AC-TK-74** Realm. A boss record carrying an `equiv_realm` key, with any value, is rejected; one without it passes.
- **AC-TK-75** Weight. 0 is rejected.
- **AC-TK-76** Rule 12. An empty pool, 3 bosses at `wave_count` 4, or removing S1 and S2 is rejected.
- **AC-TK-77** Coverage. B1 weight 5 (body 0.50) passes; weight 6 (0.538) is rejected; weight 6 with Q2 removed (five bosses, below `pool_target`) passes. A `main_kind` that is not the boss's largest offence share is rejected.
- **AC-TK-78** Reward. A boss with no `reward`, or one outside the Item Database's bounds, is rejected.
- **AC-TK-79** Formulas E. A buff of 60 W passes; 61 W is rejected.

**Terminal** [UI]. Screenshots retained in `production/qa/evidence/debug-terminal/`.

- **AC-TK-80** Rule 5. Given the confirmation screen, then it shows chance, warning, `wave_count`, each pool boss's full profile and draw weight, and setup, but no draw.
- **AC-TK-81** Rule 8. Given a slotted escape art, then the confirmation warns of it.
- **AC-TK-82** Given a run, then each header shows wave number, boss, starting health and linh lực.
- **AC-TK-83** Rule 9. Given survival, then the result screen shows the buff and the reward choice.

## Open Questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | **Closed 2026-11-06:** Combat rule 3 and Formulas A now accept starting shares for health and linh lực with no floor (AC-CB-78) | — | — |
| 2 | Measure `p_t` with real builds, then re-fit `wave_count`, `pool_ramp`, `rest_pulses` and the power band. Depends on Combat Open Questions 6 and 20. The rules can be approved first, as Combat's were, and this run then approves the numbers; AC-TK-67 stays provisional until it does (user decision 2026-11-06) | systems-designer, Balance Harness | Approval of the numbers; Realms Open Question 2 |
| 3 | Boss content: the pool, 6 or more bosses for the first step, each with a threat identity | game-designer | Content pass |
| 4 | **Closed 2026-11-06:** the player sees every pool boss's full profile and draw weight, but not the draw (rule 5). This follows Combat Open Question 4's working default | — | — |
| 5 | **Closed 2026-11-06:** pill effects taken in preparation last through all waves (rule 7). Alchemy must honour this when its GDD is written | — | — |
| 6 | The concept says Dao heart (đạo tâm) resists heart demons at tribulations. Should a boss be able to use the character's heart demon or Dao heart, such as a heart demon wave? Nothing here uses them yet | user | Content pass |
| 7 | Lightning tribulations for other realms (user, 2026-11-06): which steps, and how they change those gates' targets | user | `tribulation_steps` |
| 8 | Realms' NPC fate at the last gate (`base_g` 0.032, `max_g` 0.20) is calibrated to include the tribulation. Confirm it still matches once `p_t` is measured | systems-designer | Realms Formulas C2 |
| 9 | The form of the survivor's reward (rule 9, assumption): a lasting buff plus a choice of one boss reward. What are the buff's keys and the rewards themselves? This pass waits on more items, rewards for other systems, and Quests and Missions (user decision 2026-11-06) | user, game-designer | Content pass |

# Combat Model

How the fight actually rewards a build. The GDD says what the rules are; this file says what they
mean for someone designing modifiers. It holds rules and key names, not values, so it stays true when
numbers move. Read values from `design/gdd/combat.md` on each run, or let `scripts/fight_calc.py`
apply them. Rule and Formulas references are to that GDD.

## The shape of a fight

There is one target, no movement, no positioning and no player input. A build is finished before
the fight starts, then the engine runs it on a timeline of seconds (rule 10). So the things a
Path of Exile player would stack for screen coverage do not exist here, and everything a build wants
has to come from one of the axes below.

Fights are short. A typical mirror lasts a few seconds, and a top-end build can end an ordinary fight
in its first volley (rule 18). Anything that pays off late must also explain how the build lives
that long.

## Damage channels

A channel is a way damage reaches the enemy. **The channel is the most important choice in a build**,
because it decides which layers, caps and defences apply. A Death's-Oath-style enabler is usually a
new channel, or a channel that was not available without a slot or a cost.

| Channel | Scales with | Does not get | Meets | Limited by |
|---|---|---|---|---|
| **Art hit** | `c_art`, L1 to L5, crit, art speed | | evade, ward, body guard | linh lực, cooldown, slots, art lint |
| **Basic attack** | `basic_coef`, L1 to L5, crit | art speed, costs nothing | evade, ward, body guard | `basic_cooldown`, always runs |
| **Companion hit** | power share, M | crit | evade, ward, body guard | `c_comp_cap`, `basic_cooldown` |
| **Trigger free hit** | `c_trig`, L1 to L4 | L5, crit | evade, ward, body guard | `trig_budget`, `trig_cap`, `trigger_depth` |
| **Tick (over time)** | `c_tick`, stacks, L1 to L4 | L5, crit | body guard only, inside the ward | `dot_pool_cap`, `dot_pulse_cap`, duration |
| **Qi burn tick** | as a tick, on linh lực | L5, crit | nothing | its own share cap |
| **Soul art** | `x_soul`, thần thức ratio squared | layers, crit | skips ward, guard and evade | `soul_cap`, `soul_lockout`, `rho_min` |
| **Ward drain** | your hit size, the enemy's drain rate | | a side effect of any blocked hit | the enemy's ward model |

What follows from the table:

- **Ticks are a clock, not a damage race.** Past the caps, more damage does nothing, and the caps are
  shares of the target's maximum health. So at `dot_pulse_cap` a build kills anything in a fixed time,
  whatever its realm, with suppression only raising what it takes to reach the cap. A tick build's real
  stack is: reach the cap, then survive the clock. Modifiers that raise a cap, or spend the damage
  clipped by a cap, are worth far more than more damage.
- **Soul ignores the whole multiplier game.** Layers do nothing, so a soul build stacks thần thức and
  `x_soul` instead. Rate is bounded by the lockout.
- **Triggers can never be the main damage.** They are at most a set share of direct damage since the
  last pulse. They shine for applying statuses, refunds and curses, which the damage budget does not
  count.
- **L5 only touches hits.** A "while" modifier in L5 is worth nothing to a tick build. Give tick builds
  L1 to L4 modifiers, or a rule that lets L5 apply.
- **The basic attack is the only free, guaranteed channel.** Art speed never touches it. A build that
  wants to live on it needs modifiers aimed at it, since few exist.

## The multiplier

`M = L1 × L2 × L3 × L4 × L5` (Formulas B). Bonuses add inside a layer and multiply across layers.

| Layer | Fed by | Think of it as | Notes for modifiers |
|---|---|---|---|
| L1 Increased | `attack_pct`, tree and Way W, "increased" tags | The everyday stack | Soft cap, then a hard cap. W fills only this layer |
| L2 Art "more" | Tag-keyed modifiers on techniques, arts, Way art nodes | The build's identity | Authored in the 5 to 50 point band |
| L3 Gear | Artifact attack against the realm base | What you carry | Rises with `artifact_power_pct` and artifact count, limited by thần thức |
| L4 Preparation | Formations, talismans, pills, coatings, ground | What you did before | Mostly gone in a blind fight (rule 12), ground tags only |
| L5 Trigger and conversion | "While" and "after" effects | The condition you must hold | Only while active, and hits only |

- **Spreading wins.** Five modest layers beat one huge one, so a modifier in an empty layer is worth
  more than the same points in a full one. Always ask which layer the build is short in.
- **The top-end anchors sit exactly on the hard caps of L2 to L5.** Reaching top-end means filling every
  layer. A build that skips one, such as refusing preparation, gives up that whole factor. Say so in the
  price of the build. Changing a cap or adding a layer is a `Needs rule` proposal, flagged for the user.
- **Crit and suppression sit outside M.** Crit is capped in chance and in multiplier. Pierce only matters
  when fighting upward.

## Time

- **Nothing fires at t = 0.** Every art starts on its full effective cooldown, so a cooldown is also
  its first delay (rule 13). A long-cooldown art may never fire in a short fight.
- **Art speed divides, with falling returns,** and it also moves the first firing. It stops at
  `cooldown_min`.
- **Pulses are the beat.** Regeneration, ticks, durations and per-pulse limits all run on
  `pulse_interval`. Times are whole milliseconds and events tie only in the same millisecond, so an art
  cooldown that divides the pulse lands on the beat, and one that does not drifts off it.
- **Instants have an order** (rule 10): pulse, art costs, hits, escapes, then the defeat check. Guards
  are read after the pulse. All of an instant's damage lands before anyone is judged, so a dying side
  still acts in that instant. Follow-up instants let a waiting art fire at the same time.
- **Waiting is a state.** An art blocked by cost or guard stays ready and fires when it can.
- **The art lint trades three things:** coefficient, cost and cooldown. Short cooldowns give the most
  damage per second and burn linh lực fastest. Long cooldowns at a low cost give by far the most damage
  per linh lực, but arrive late. Run `fight_calc.py` rather than guessing where a build sits.

## Linh lực

- **It is mana and defence in one pool** (rule 11). Every art cast weakens the ward. Nothing reserves it.
- **Costs are shares of maximum,** so a bigger pool buys no extra casts. It does buy more ward, because
  a drain ward's capacity is `pool / drain`.
- **Regeneration is a small share per pulse.** Sustainable spending is about `regen` per second. Most
  builds overspend and live on their opening pool.
- **The first thing that goes wrong is usually the pool.** Several arts on similar cooldowns drain it
  in one or two volleys, and then the ward has nothing.
- **Starving an enemy is a real win condition.** With no linh lực a side has no ward and no arts, only
  the basic attack, and hits land nearly in full (rule 23). Qi hits burn more than body hits, body hits
  leak more.

## Defence

| Layer | Stops | Paid by | Fails to |
|---|---|---|---|
| Evade | Body and qi hits | Nothing | Ticks, soul |
| Ward | Body and qi hits, a share set by pass | Linh lực, by model: drain, per hit or per pulse | Ticks, soul, an empty pool |
| Body guard | Everything past the ward, including ticks; less against qi | Nothing | Soul |
| Health | The bar that ends the fight | | |
| `soul_res_pct`, thần thức | Soul arts | Nothing | Only the Way and rare items give it |
| `status_resist_pct`, cleanse | Status chances, curses | An art slot for a cleanse | |

Ward models matter for matchups. A drain ward is punished by big hits, a per-hit ward by many small
hits, and a per-pulse ward by a long fight. A new ward model is data plus a rule (rule 22).

## Fixed limits worth designing against

Each of these is a key in Combat. A modifier that moves one is a **cap shift**, among the strongest
things in the game, so make it small, single and costly.

`slots_by_realm` · `curse_slots` · `stack_cap` · `dot_pool_cap` · `dot_pulse_cap` · `trig_cap` ·
`trig_budget` · `trigger_depth` · conversions per hit (2) · `crit_chance_cap` · `crit_mult_cap` ·
`evade_cap` · `pierce_cap` · `soul_cap` · `soul_lockout` · `cooldown_min` · `regen_cap` · `ward_cap` ·
`guard_cap` · `equip.max_slots` · `aux_slots`

## The life around the fight

This is what the game has and Path of Exile does not. `compile(character, preparation)` reads the whole
character (rule 2), so a modifier can read anything on the sheet at compile time, cheaply and
deterministically. Stats that do nothing in a fight today are open ground:

- Heart demon (tâm ma), pill toxicity (đan độc), fortune (khí vận), vitality fraction
- Years of lifespan left, age, seasons in closed-door cultivation
- Purity of the root, element affinity, number of Daos held, nodes bought in a Dao
- Technique tier, layers, mastery, comprehension
- Thần thức left unused by artifacts, artifacts equipped, spirit stones carried
- Failed breakthroughs this life, realm stage, cultivators defeated

Read a real key before using one: `design/gdd/character-stats.md` Parameter keys and Stat sheet sections.

## From Path of Exile to this game

| In PoE | Here | Note |
|---|---|---|
| Aura | A permanent status with no slot | `Needs rule`: statuses have durations today |
| Mana reservation | Not in the game: rule 11 says nothing reserves linh lực | `Needs rule`, and a strong cost, because reserved linh lực is also ward |
| Area of effect | No equivalent in a duel | Replace with stacks, status count or duration. It matters only in the mass-battle rating |
| Movement speed | No equivalent | Replace with art speed, earlier first firing or escape |
| Minions | One companion (rule 19), or artifacts that act | A swarm is a `Needs rule` channel |
| Totems, traps, mines | Formations and talismans | Prepared before the fight, so they live in L4 |
| Curses | Curses (rule 8), `curse_slots` of them | They change rules, never pools |
| Flasks | Pills and talismans | Pills only in preparation |
| Life and energy shield | Health behind a linh lực ward | |
| Chaos Inoculation style keystones | Rule-benders in the catalogue, such as No Ward | |
| Conversion, gained as extra | Conversion (rule 6). A converted part keeps both tag families | At most 2 per hit |
| Support gems | Not in the game | A new concept: an auxiliary art that alters arts by tag |
| Cluster jewels | Sealed hidden clusters | Authored content a player can plan around |
| Ascendancy | A Đạo keystone | |
| Build-enabling unique | A named artifact, a technique, a keystone or a Đạo | See the forge |

## How builds usually fail

1. The opening spend empties linh lực and the ward falls before the arts finish the job.
2. All the arts are slow and the fight is over before they fire.
3. Modifiers target a layer the channel does not use, such as L5 on ticks.
4. Damage stacks past a cap with nothing to spend it on.
5. One layer is huge and another is empty.
6. Nothing answers one threat kind: no soul defence, no plan for a drainer, no cleanse.
7. The build needs a long fight and has no way to survive one.
8. The build depends on chance, which rule 15 wants to stay a flavour.

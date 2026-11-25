# Engine wishes: what the authored Effects need from the combat engine

Status: list for the combat port (user ruling 2026-11-25, group 8: keep the Effects, list the features). Nothing
here is in `design/gdd/combat.md` or `effects.md` yet. Sources: the authored records in `builds/authored/`
(`engine_additions`, `new_vocab`, the `.md` flags) and the duel readings. Ids are Effect, status or art record ids.

The duel readings themselves (Still, Moving, Displaced, Planted, Rooted and Pinned, At range, Broken, Wounded,
allies counted, Field and Piece) are specified with their hooks and knobs in `duel-readings.md` section 2. They are
not repeated here, except where an Effect needs more than that section gives.

## 1. Fight-state actions

| Feature | What it does | Needed by | Simplest hook |
|---|---|---|---|
| **Held damage** (delayed damage) | A share of a hit taken is held back and lands over the next N s; healing pays the held amount off first | `a-file-of-one` (Geese Stance, Geese Startled by the Cold) | A per-side `held_damage` pool. On `hit_taken`, move X % of the damage into it. Each pulse, pay `pool / remaining pulses` as damage that bypasses wards. A heal first reduces the pool, then health. |
| **Immunity to timer delays** | For a time, the foe's Move-a-timer actions do nothing to your arts | `the-ninth-verse` | A state flag `delay_immune`. Effects rule 6 ("Move a timer") skips a target that holds it. This is the same carve-out as R9 Planted, which refuses `displace` delays. |
| **Tick taken turned into healing** | A damage-over-time tick on you heals you for a share of it instead of hurting | `bitter-medicine` | An `on: tick_taken` event with a filter on the status tag (`poison`) and a guard on your own stack count. The action `convert_tick_to_heal {share}` is the mirror of Crossing the Line (R12). |
| **Stop a side's clock** | For N s one side's art timers, basic attack, companions and stack countdowns do not run, while the other side's do | `the-world-before`, `asleep` | A per-side `clock_scale` (default 1). The action `stop_clock {side, seconds}` sets it to 0. The timeline multiplies that side's timer, basic-attack and stack-duration advance by it. |
| **Status that holds its caster** | While the status runs on the foe, the caster's own damaging arts and basic attack are held; a direct hit of the caster that does land ends it | `charmed`, `asleep` (laid by `the-second-cup-charms` and `lullaby-of-the-karst`) | A status-row flag `holds_caster: true`. Applying the status starts an R29 held state on the caster that suppresses arts with a damage part and the basic attack, and ends with the status. A `hit_landed` by the caster's side (not a tick, not a companion for Charmed) removes the status. |
| **Diagram laid in an ambush or a blind fight** | The holder's combat diagram is laid even where Formations rule 9 forbids it, with its fuel paid | `a-formation-that-walks` | A holder flag `diagram_always`, read by Formations rule 9's laying check. |
| **Extended last act after Down** | After you go Down, your banked waves fire for 6 s, and if the foe goes Down in that window the fight is a draw | `pine-wave-fifteenth-layer` | A Down-step variant `last_act_window {seconds}`: you are untargetable and inactive, and only the listed free hits fire. A double knockout resolves as a draw. This is a rule change to Formulas C. |
| **Overflow-healing amount** | Reads how much of a heal was lost to full health | `the-empty-mountains-answer` | The heal event reports `overflow` beside `amount`, so a self-counter can add it. |
| **Upkeep per standing Piece** | Each Piece you keep up drains a little linh lực each second (the close the cap ruling added) | `laid-ward-on-the-next-stroke` | A cost-per-pulse field on R7 self-counters: `upkeep {pool: linh_luc, per_stack}`. |

## 2. New readables and events

| Feature | What it does | Needed by | Simplest hook |
|---|---|---|---|
| **Lost in the last N s** | Your health and linh lực lost in the last 3 s (and, for the art, the foe's buffs and wards gained in the last 6 s) | `the-sky-of-a-moment-ago` | A per-side ring buffer of per-pulse losses and gains, read as `own.lost_last.<pool>.<seconds>`. |
| **Pill burned in a fight** | An art spends a prepared pill from the pill slot; the pill's element and grade become payload; a pill can fail in a fight | `pill-smoke` | The action `burn_pill`, the event `pill_burned {element, grade, failed}`, and `stacks.el = pill`. |
| **Linh lực drained** | Points of linh lực moved from the foe to you are reported, so a counter can bank them | `landing-the-fish` (fed by Line Through the Ice and A Bite on the Line) | The event `qi_drained {amount}`, `counter.add_amount`, and `free_hit.amount` read from a counter. |
| **Healed and leech events** | Reacts to a heal received and to health leeched by your own hit | `water-wears-the-stone`, `drink-within-a-breath`, `move-the-sickness` | The event `healed {source}` and the payloads `heal.of = amount` and `gain_qi.of = heal_share`. |
| **Ice batch runs out** | Fires when one of your element batches on the foe expires | `black-under-white` / `black-thaw` (Black Ice Method) | The event `batch_expired {element, stacks}`. |
| **Ward absorbs a hit** | Fires for each hit your frost ward or a ward share absorbs or loses | `frost-answers-the-blow`, `true-gold-does-not-fear-the-furnace` | The event `ward_absorbed {amount}` beside the existing shield-breaks event. Confirm whether it exists. |
| **Fight hour of a Piece** | A Piece remembers the 5 s hour of the fight in which it was laid | `the-twelve-hours` | A `laid_at` pulse on each counter batch. Hour = floor(laid_at / 5 s). |
| **A failed escape** | Counts escape attempts that fail in this fight | `know-the-way-out` | The event `escape_failed`. The Effect raises the next escape chance; the `escape_bonus` clip has to allow it, so check that cap. |

## 3. Tags and statuses

| Feature | What it does | Needed by | Simplest hook |
|---|---|---|---|
| **Status rows Charmed, Drunk, Sleep** | Three new curses | `charmed`, `drunk`, `asleep` | Rows in the Effects Status Catalogue (rule 9). Drunk has no stack cap since the cap ruling; each stack runs its own 3 pulses. Charmed and Sleep use the caster hold above. |
| **`mist` tag** | Marks your mist Fields and states, so "a foe's Wind art lifts your mist" and "a foe art that misses in your mist" can find them | `the-wind-lifts-the-mist`, `lost-on-the-road` | The tag `mist` on Lock the Road, Haze on the Path and A Breath of Road Mist. The lift runs on the foe's `art_fired` event, before that art's hit. |
| **`song` and `bow` form tags** | Scopes for song and bow modifiers | the b2 and b10 lines (`[song]`, `[bow]` scopes) | A `modifiers.md` rule 9 vocabulary amendment. The tags are now on the depth arts and on the library bells. |
| **`fan` tag** | One plumage colour comes from a fan art | `five-marks-from-five-arts` | The tag `fan` on fan arts. No art carries it yet. |
| **`crane` and `bird` on companions** | Hits by a crane or bird companion are filtered | `a-crane-for-the-rider`, `birds-pay-court-to-the-phoenix`, `birds-bring-the-fire` | Companion records carry `tags`, and companion hit events carry the companion's tags. The crane king (`sects/cuu_cao.beasts.json`) carries `crane`, `bird`. |
| **Talisman source on stacks and marks** | Stacks and marks laid by a talisman art cannot be cleansed | `rainfast-ink`, `stars-on-the-foe` | Each batch or mark remembers its source art's tags. A cleanse skips batches whose source carries `talisman` while the holder has the Effect. |
| **Light element and Soul part** | A Light hit with an added 30 % Soul part, which counts as both song and soul | `dawn-call` | The element `light`, dtype `light`, and `soul_part` (Damage Types rule 1, the R11 exception). |

## 4. Art DSL words (from `auth-tech.json` `new_vocab`)

| Words | Needed by |
|---|---|
| `requires.root_lacks`, `requires.root_has` (root gates) | `bronze-answers` (no Thunder), `dawn-call` (Light) |
| `fire_art.filter.element` | `bronze-answers` |
| `stacks.kind = debuff` on side own (a Burn on yourself); event `tick_taken`; read `own.debuff.<el>` | `into-the-vent` |
| `movements` (per-firing sub-rules from a counter); event `in_turn`; a counter on side foe; `next_art_cost`; `filter.not_art_id` | `nine-shao-next-movement`, `remnant-next-movement` |
| A counted-chance meter kept between fights, with p reading khí vận (an exception to Formulas A) | `playing-past-the-break` |
| `move_own_debuffs`; read `own.tech_layer.<id>`; `free_hit.pass_shields` | `move-the-sickness` |
| A counted curse that takes no slot | `black-under-white` |
| Art ids for lineage arts that have none yet (`where-the-drop-falls`, `line-through-the-ice`, `a-bite-on-the-line`) | `bronze-answers`, `landing-the-fish` |

## 5. Engine checks (no new feature, only a confirmation)

- Does a Bleed tick match `attack_pct [bleed]` and `status_duration_pct [bleed]` through its status tags? (b11
  Opened Veins)
- Does a summon's fixed coefficient read `companion_power_pct`? (b13 Stone Wardens; that wire is not applied)
- The decays the cap ruling added (`the-empty-mountains-answer` −10 % a second, `banked-healing` −5 % a second) use the
  existing decaying self-counter (as furnace-heart's `heat`). Confirm that a counter can decay by a share, not only by
  a count.

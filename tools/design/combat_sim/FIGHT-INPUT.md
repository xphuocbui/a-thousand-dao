# Fight Input Format

> The build-file format `tools/design/combat_sim/fight.py` reads (moved from a retired skill's
> `references/content-formats.md`, 2026-11-11). Run `python tools/design/combat_sim/fight.py --numbers` for the anchors.


`design/builds/[slug].fight.json`, read by `scripts/fight.py`, which runs it on the combat simulator
(`tools/design/combat_sim/engine.py` since 2026-11-11; `sim.py` keeps the #44 tuning record). `realm`, `layers` and `arts` are required; every other field is
optional and defaults to the typical anchor. Write one file for the defining realm, and change `realm` and
the points for a second run. **A field the loader does not know stops the run** (`UNKNOWN_FIELD`), so a
result never silently ignores part of the build.

**`layers` holds only what applies to every channel:** `attack_pct` and untagged sources in L1, gear in L3,
and the untagged L2, L4 and L5 points. A tag-scoped modifier goes in the `x` of the art it touches, added on
top. Putting "Fire more" in `layers` also feeds it to the basic attack, and the result is wrong in a way that
looks like a strong build.

```json
{
  "name": "slug", "realm": "ket_dan",
  "layers": [120, 80, 40, 20, 0],
  "crit": {"chance": 0.1, "mult": 1.5},
  "n_body": 1.2, "n_qi": 1.1,
  "art_speed_pct": 30, "art_cost_pct": 10, "art_cost_health_pct": 0,
  "regen_bonus_pp": 2, "health_regen_pp": 0, "healing_pct": 0,
  "evade_pct": 0, "accuracy_pct": 0,
  "gain_on_hit_pct": 0, "leech_qi_pct": 0, "leech_health_pct": 0,
  "ward": {"model": "drain", "payload": 342.5, "drain_base": 0.328, "ws_base": 40, "we": 40,
           "layers": [40, 40, 20, 10], "block": 15},
  "body": {"block": 30, "resistance": 25, "shield": 0.3, "layers": [40, 47, 20, 0]},
  "cleanse": {"per_pulse": 0, "fee_share": 0, "share": 0.25},
  "keystones": {"k_burn": 0.5},
  "curses": ["withering"],
  "purity": {"fire": 80},
  "bonus_slots": 0,
  "arts": [{"id": "slug", "c_art": 2.9, "cost_share": 0.06, "cooldown": 3, "element": "fire", "kind": "elem",
            "buff": [1, 10], "debuff": [2, 6], "c_heal": 0, "qi_restore": 0, "cleanse": 0,
            "x": [0, 20, 0, 0, 0]}],
  "enemy": "typical",
  "enemy_overrides": {"ward": {"ws_base": 200}},
  "unmodelled": ["what this file cannot express, one line each"]
}
```

- **Numbers are GDD units.** `cost_share` is the #44 share (0.02–0.125); `drain_base` the #44 ward record
  (the Common Ward 0.328); `regen_bonus_pp` and `health_regen_pp` are percentage points a pulse; the `_pct`
  fields are percent. The loader converts them to the simulator's units.
- **Ward** (Combat Defence & Healing A0, A, C): `model` is `drain`, `default` (60 points, drain 0.40, no ws)
  or `off`. `payload` is the ward's resistance points at ws 0; `ws_base` the additive ward strength (gear
  included); `layers` the ward layers W2–W5 (W3 is gear: `100 · 0.47 · a_w`). With no `ward` the build has
  the realm's typical Common Ward. Per-hit, reserved and cast wards, shields and soul wards: model the
  nearest drain ward and list the real one in `unmodelled`.
- **Body** (A0, A, A2, B, E): base block rating, base body resistance in points and the body shield's
  share of health; `layers` are B2–B5 (B3 is body gear: `100 · 0.47 · a_b`). The layers scale block,
  resistance and health regeneration, never the shield. `ward.block` is the unscaled rest (flesh, ward gear).
- **Arts:** `kind` is `phys` or `elem`; `element` one of fire, water, earth, metal, wood, thunder, wind, ice;
  `buff` and `debuff` are `[stacks, seconds]` of that element's stacks (Effects System Formulas D). The
  loader prints `lint_over` for an art above the art lint (or a heal above the heal lint), and `range` for a
  cost or cooldown outside the GDD's range.
- **Keystones** are the simulator's `k_` fields (linh lực keystones from the builds-by-root catalogue);
  `curses` takes `withering` and `stagnation`.
- **Enemies:** `typical`, `top_end` (every offence and ward layer at cap) and `top_end_the_tu` (every body
  layer at cap, the default ward). They are exact at Qi Refining and fitted elsewhere. Use
  `enemy_overrides` (same fields as a build) to shape a matchup, such as a heavy ward or a cleanser.
- **Effects run in the fight** (engine 2026-11-11). Write the build's engine as `effects` records; put a piece in
  `unmodelled` only when the engine refuses it (it names the missing event, action or readable), so most builds can
  now be assessed. Still not modelled: conversion inside a hit, forms and stances, loadout swaps, ward
  payloads other than drain (model the nearest drain ward).

### Effects, counters and the new fields

```json
"counters": [{"id": "whet", "cap": 8, "each_for": 6}],
"effects": [
  {"id": "whetted-edge", "on": "crit", "do": [{"counter": {"id": "whet", "add": 1}}]},
  {"id": "whet-crit", "on": "always", "scale": {"read": "own.counter.whet"}, "do": [{"mod": {"crit": 2}}]},
  {"id": "flowing-water", "on": "crit", "limit": {"per_pulse": 3},
   "do": [{"timer": {"side": "own", "which": "others", "by": -0.5}}]},
  {"id": "hot-edge", "on": "crit", "do": [{"mod": {"L5": 10, "for": 3}}]},
  {"id": "mending-guard", "on": "always", "if": [{"read": "own.hp_share", "op": "<=", "value": 0.6}],
   "do": [{"mod": {"hregen": 0.5}}]}
]
```

- **An Effect** is `{id, on, filter?, if?, scale?, chance?, limit?, held?, do}`.
  - `on`: `always` (a static or conditional modifier, read live) or an event: `fight_start`, `art_fired`,
    `hit_landed` (any own hit not evaded), `crit`, `evaded` (you evaded), `was_hit`, `was_evaded`, `hit_stopped`
    (wards stopped it all), `pulse`, `tick_dealt`, `heal_restored`, `shield_broken`, `status_applied`,
    `overflow`, `cleansed`, `soul_hit`, `down` (with `refuse_down`).
  - `filter` narrows an event: `dtype`, `element`, `kind` (art, basic, companion, trigger), `tags`.
  - `if`: conditions, all must hold: `{"read", "op": "<=|>=|<|>|==", "value"}`. Readables: `own.` or `foe.` +
    `hp_share`, `hp_missing_share`, `qi_share`, `qi_missing_share`, `buff.<el>`, `debuff.<el>`, `status.<id>`,
    `counter.<id>`, `distinct_statuses`, `fired`, `body_shield_share`, `boss`, `tam_ma`; `time`; `event.amount`.
  - `scale`: `{"read", "per", "cap"}` multiplies every number in `do` by floor(read / per), capped if `cap` is set
    (leave `cap` out for limitless scaling).
  - `limit`: `per_pulse`, `per_fight`, `cooldown` (seconds). `chance` rolls the seeded stream.
  - `held`: `{"until": "art_fired" | "hit_landed", "cap"}` banks the payload on the event and spends it on the next.
- **Actions** (one verb each): `mod` (a stat for `for` seconds on an event, refreshed by a new firing unless
  `"stack": true`; live on `always`), `gain_qi` / `heal` (`share` of the max, or `"of": "amount"` of the event),
  `free_hit` (`c`, `dtype`; trigger budget and cap apply), `stacks` (`el`, `n`, `for`, `side`), `status` (`id`,
  `stacks`, `dur`, `side`, `chance`; ids from the Status Catalogue), `cleanse`, `timer` (`side` own or foe, `which`
  all, others, longest or next, `by` seconds, positive delays a foe; foe delays fall off), `refund`, `counter`, `strip` (`n`, `el`, `steal`),
  `consume` (`el`, `side`, `n`, `then`, `per`), `refuse_down`, `last_act` (`c`), `cull` (a health share),
  `shield` (`body` share), `self_hit`, `store_damage` (Internal Injury).
- **Mod keys:** `L1`–`L5` (layer points), `crit`, `crit_mult`, `evade`, `acc` (pp), `art_speed`,
  `basic_speed`, `opening_haste`, `cost_red`, `regen`, `hregen`, `healing`, `leech_hp`, `leech_qi`,
  `gain_on_hit`, `resist`, `block`, `dampen_taken`, `timer_resist`, `bypass`, `ward_bill`, `basic_coef`,
  `soul_res`, `x_soul`, `dmg_more`, `companion_speed`, `tick_block`.
- **Counters:** `{id, cap?, each_for?, decay_per_pulse?}`; tag them `growing` in the guide (R7).
- **New build fields:** `companions` (`[{"c", "dtype", "cd"}]`), `shields` (ward shields:
  `[{"size": share of qi_max, "stops": {dtype: share}, "pieces", "standing", "floor"}]`), `basic_speed_pct`,
  `opening_haste_pct`, `basic_coef_add`, `timer_resist_pct`, `ward_bill_pct`, `refusals`, `divine_sense`,
  `soul_res_pct`, `x_soul`, `tam_ma`, `resist` (typed points), `boss`.
- **More art fields** (2026-11-11): `convert` (`{"to": dtype, "share"}`: that share meets the other type's
  defence), `hp_cost` (share of health paid on firing), `charges` (stored firings; a spent one refires after
  `cooldown_min`, all return after the cooldown). **Build field** `states`: forms and stances
  `[{"id", "mods", "suppress": [art ids], "start"}]`, switched by the `state` action, read as `own.state.<id>`.
  **More actions:** `cleanse` with `status` or `curses: n`; `state` (`set`, `toggle`); `summon` (`c`, `dtype`, `cd`,
  `for`); `fire_art` (`which`: last or an art id, `share`): an echo. Guards and `if` take `{"any": [conditions]}`.
  Events carry `art_id` (filter on it), and `heal_restored` carries the healing art's id, tags and cost.
- **Engine-building arts** (2026-11-11): `group` (the technique carrying it), `steps` (a multi-step art:
  `[{"unlock": conditions, "pay": actions, "c_mult" or "c_art", overrides}]`; each firing tries the next step, fires it
  if its unlock holds (paying `pay`, e.g. a `consume`), else falls back to step 1; the last step resets the chain),
  `empower` (`[{"if": conditions, "pay": actions, "c_mult", "add_statuses", overrides}]` applied at firing). New events
  `step_unlocked`, `empowered`. New readables: `own.fired_within.<s>.<all|tag|group|art>.<value>` (distinct arts fired
  within s seconds; "this pulse" is 1), `own.since.<art id>` (seconds since it last fired), `own.step.<art id>`.
  A step or empower above the art lint must be gated; the lint reports its multiple as `engine_payoff`.
- **New art fields:** `tags`, `guards` (conditions, all must hold), `statuses` (`[{"id", "stacks"}]` on hit),
  `split` (sub-hit shares), `soul_pct` (a soul art), `soul_part` (≤ 0.30), `bypass`, `pool` (`qi`, `tam_ma`,
  `than_thuc`).
- **`--without <effect id>`** removes one Effect: the identity test for an engine piece.
- **Library pieces** (2026-11-11): an art may be `{"lib": "<art id>"}`, which loads the record from
  `design/arts/family-*.json` or `part-*.json` (every authored art since 2026-11-14) with its effects, counters and states; other keys
  on the entry override its fields. `"techniques": ["<technique id>"]` loads each technique's passives from
  `design/techniques/catalogue-*.json` as one always-on Effect `tech:<id>` (`--without tech:<id>` tests it). Passives
  with no engine stat, and scopes on stats the engine reads without hit context, print as UNMODELLED.
  `design/arts/INDEX.md` lists every technique and art on one line.
- **Items** (2026-11-12): `"items": ["<item id>"]` loads named items from `design/items/catalogue-*.json`: their plain
  modifiers as one always-on Effect `item:<id>` (`--without item:<id>` removes them; the item's art stays slotted),
  their arts as library arts (slot one with `{"lib": "<art id>"}`), and the weapon bases' common arts from
  `design/items/common-arts.json`. Item wards run as extra wards (below); item Effects run from the Effects library
  (below), or from the build's own `"eff:<English name>"` records. `design/items/INDEX.md` lists every item on one line.
- **Build stats from techniques and items** (2026-11-13). These lines change the build itself, so they are folded in
  at load instead of running as live modifiers: `khi_huyet_pct` and `linh_luc_pct` (summed, then the file's `n_body` /
  `n_qi` × (1 + sum / 100)), `body_shield_pct` (`body.shield` + pp / 100), `defense_pct` and `ward_efficiency_pct`
  (added to the drain ward's `ws_base` and `we`), `than_thuc_pct` (`divine_sense` × (1 + pct / 100)),
  `stack_effect_pct` and `stack_duration_pct` (by element and buff/debuff scope).
- **New build fields** (2026-11-13): `reserved` (share of maximum linh lực held by reservations, capped at 0.9: the
  fight starts at and refills to `qi_max · (1 − reserved)` while art costs read the full `qi_max`; an item's reserve
  arts add their share and run their `grants`), `stack_eff` and `stack_dur` (percent, keyed `"<element>|<buff|debuff>"`
  with `*` for any: `{"fire|debuff": 20, "*|*": 10}`).

- **Extra wards** (2026-11-13): `"wards": [{"name", "payload", "payment", "activation"}]` in the GDD's words, as the
  starter ward table and item wards write them: payload `"Fire 240 points"`, `"all 100 points"`, `"shield σ 0.135"`,
  `"block 60"`; payment `"drain 0.176"`, `"per hit 0.035"`, `"reserved 0.49"`, `"cast 0.036"`; activation `"standing"` or
  `"cast, cooldown 4 s, up 3 s"`. Item wards are added the same way. They are scaled by the build's ward strength and
  efficiency and take the free ward slots (`ward_slots_by_realm` 1 / 1 / 2 / 3 / 4 plus up to 2 from thần thức, less one
  for the main ward), then the free art slots; a ward with no slot is listed as UNMODELLED. A worn armour's ward
  (an item whose base is body_gear) takes its armour's own slot (Combat Defence & Healing rule 5, 2026-11-13); a
  ward record of your own takes it with `"own_slot": true`. A per-hit ward pays one fee per hit (all its parts) and
  one per tick, which it then meets; a reserved ward holds its share through `reserved`; a cast ward fires on its cooldown and is up for its window.
  Evade payloads (`"evade +14.4 pp"`) run while the ward is up (2026-11-13); status, soul and cleanse payloads are not
  run (listed).

- **Layer budget** (user decision 2026-11-13): a build file's `layers` may claim at most a share of the gap between the
  typical and the top-end enemy's layers, summed over L1–L5: 10 / 10 / 17 / 23 / 30 % from Qi Refining to Deity
  Transformation. A build at its budget beats a typical same-realm enemy in about 10–20 s. `fight.py` prints the claimed
  share on every run and `OVER_BUDGET` above it. This is a flag, not a refusal; a guide that claims more says which
  pieces put it there.
  The same budget applies to each hand-set field, against its own typical-to-top-end gap (`FIELD_OVER`):

  | Field | Typical | Top-end |
  |---|---|---|
  | crit chance and damage | 0.15 / 1.7 | 0.5 / 3.0 (GDD caps) |
  | `art_cost_pct` | 0 | 50 (the cap) |
  | `evade_pct` | 0 | 40 (`evade_cap`) |
  | `accuracy_pct` | 0 | 40 (a guess) |
  | `art_speed_pct` | 0 | 100 (a guess) |

  Sustain fields (regeneration, healing, leech) are not budgeted, nor are the pools (`n_body`, `n_qi`), which also
  hold the item and technique pool modifiers the loader folds in. Once the Đạo Đồ is back, build files derive
  these from their pieces instead (user decision 2026-11-13).
- **Named Effects from the library** (2026-11-13): `assets/data/combat_effects.json` (moved from `tools/design/combat_sim/effects_library.json` on 2026-11-14, ADR-0001) holds an engine form
  of every Effect the item catalogue names (its rule text beside it). A worn item's Effect is added from it unless the
  build file writes its own `"eff:<English name>"` records, which win. An entry may also fold lines into the build
  (`static`), reserve linh lực (`reserve`), define counters, or multiply by a count of worn items (`count`: by first
  role, or by an art tag). Approximations and Effects the sim cannot run (escape, carried spirit stones) print as
  UNMODELLED with the reason.
- **Scoped reads** (2026-11-13): art speed, cost reduction and the soul multiplier read each art's own context
  (`dtype`, `element`, `tags`), so a scoped `art_speed_pct`, `art_cost_pct` or `x_soul` speeds only the arts it names,
  and the opening cooldown honours art speed too. An `elem` art meets a type filter as its element's usual type
  (Combat Damage Types rule 3): Fire → fire, Ice and Water → cold, Thunder → lightning, Wind → force, Wood → chaos.
- **Checked at load** (2026-11-13): a filter or mod with a `dtype` or `element` the engine never produces, a readable
  naming an unknown element pile or status (`buff.moc`, `status.burn`), and a `cost_red` outside −1..1 (it is a share:
  0.1 = 10 %) stop the run instead of silently doing nothing.
- **More catalogue keys run** (2026-11-13): `status_duration_pct` (outgoing; scope `curse` allowed; curses still clamp),
  `status_resist_pct` (Combat F: p = clamp(chance × (1 − resist), 5 %, 95 %), against guaranteed statuses too),
  `healing_taken_pct` (floored at −50 %), `linh_luc_on_crit_pct`, `art_cost_health_pct` (linh lực pays cost ÷
  (1 + X/100), health the rest point for point; as a build field too), `resist_pen_pct` (points off the part's
  resistance, its type scope matching the final type), `pierce_pct` (Formulas H, capped at `pierce_cap` 0.75; as a
  build field too), `stack_grant`. Out-of-fight keys (`khi_van`, `cultivation_speed_pct`, `artifact_slots` and others)
  are skipped without a note.
- **More vocabulary** (2026-11-13). Mod keys `status_dur`, `status_resist`, `heal_taken`, `qi_on_crit`, `art_cost_hp`,
  `pen`, `pierce`, `stack_grant`, `blood_cast`, `shield_pays`, `hp_cost_red`, `heal_cap`, `unmoved`, `no_regen`,
  `foe_soul_res`. Actions `burn_qi` (`of`, `share`: the foe loses linh lực), `emit` (`event`: raise another event, e.g.
  a basic hit counting as an evade), `protect` (`el`, `for_first`, `swap_buff`: a cleanse skips your debuff batches),
  `refresh` (`el`, `side`, `kind`, `hold`). `timer` takes `which: "next"` (least time left, the earlier slot on a tie:
  the GDD's "next ready art"); `free_hit` takes `dtype: "same"`; `fire_art` takes `which: "longest"`. Events
  `foe_ward_paid` (`amount`), `foe_cost_extra` (the cost a foe paid because of your Ice). Readables `curses`,
  `ward_paid`, `buff_elements`, `state.any`; events now carry `share` on `heal_restored` and `overflow`,
  `hp_paid_share` on `art_fired`, and the art's tags on `soul_hit`.

### Built in world-depth Stage 5 (2026-11-26; both engines, parity fixtures t10, t11)

- **Slice 1:** the event `ward_absorbed` (`event.amount`, `event.dtype`); the action `stop_clock` (`side`,
  `seconds`; an art already ready waits too); `event.overflow` on `heal_restored`; a counter's `decay_share`; the
  event words `batch_expired` and `healed` (EVENT_ALIAS).
- **Slice 2a statuses** (art `statuses` or the `status` action; read as `status.<id>`): `off_guard` (evade 0, no
  draw), `bound` (escape fails; escape is not modelled yet, so it is a readable only), `charmed` (the target's arts
  wait; its caster is held; the caster's own trigger or free hit ends it), `drunk` (each landing its own time, no
  cap; per stack 8 % slower timers and 10 points of aim; at 3+ stacks Water parts deal 10 % more), `sleep` (the
  clock stops; its caster is held; any direct hit wakes it for 20 % less). A held caster's arts with a damage part
  and its basic attack do not fire. A chance-free fixture may lay Drunk only on a side with `acc` 1 or more.
- **Slice 2b:** the mod `tick_to_heal` (percent; filters `element`, `status`, `dtype`): a tick its holder takes
  deals nothing and heals that share of it as healing (Bitter Medicine; the Effects GDD's `convert_tick_to_heal`).
  A counter's `upkeep` (`{"pool": "qi" or "hp", "per_stack": share of the pool's maximum}`): paid each pulse per
  stack; stacks the pool cannot pay end, the charges nearest their end first; health keeps `pay_keep_health`.
  Fixture t12.
- **Slice 2c:** the action `last_act_window` (`seconds`, `every` (default 1), `spend` (a counter, one per round;
  empty ends it), `hits` (`[{"c", "dtype"}]`)) on a `down` Effect: when no refusal holds the side up, it stays in
  the fight for the window, untargetable, unhealable and out of its pulse, and each round fires its hits as free
  hits; it goes Down on time or when the bank is empty, and the foe going Down within it is a draw. Once a fight; it
  replaces the side's other last acts and its `down` event. Fixtures t13 (draw), t14 (ends on time).
- **Slice E, escape** (Combat rule 10, Formulas I): an art's `escape` (its e_art, 0.40-0.70 in content) makes it
  an escape art. Firing it opens a 1 s channel (one per side; a ready escape art waits). When the channel ends, after
  both sides' hits, A first, a side above 0 health rolls `clamp(e_art + 0.10 x realm gap - 0.15 x lock + escape/100,
  0.05, 0.95)`: `lock` is the foe's mod flag, `escape` the side's mod. Bound fails it with no draw. A success ends
  the fight (`flight`; the fled side wins if the foe is already at 0); a failure raises `escape_failed`. Fortune is
  not modelled in any roll yet. Fixtures t15 (chancy), t16 (Bound, exact).
- **Slice 3:** `burn_qi` takes `to_self` (a drain: that share of the linh lực burned moves to you, and the event
  `qi_drained` reports `event.amount`); a leech heal's `source` is `leech` (filter `source`); readables
  `own.lost_last.<hp|qi>.<seconds>` (net losses per pulse in the window, plus since the last pulse) and
  `own.counter_hours.<id>` / `own.counter_this_hour.<id>` (a charge counter's distinct 5 s fight hours, and the
  charges laid in the current hour; laid = end − `each_for`). Fixture t17.
- **Slice 3b, pill smoke** (user: smoke only for now): a build's `pill` (`{"element", "grade", "fail"}`); the
  action `burn_pill` (`stacks_per_grade` 4, `for` 6 s) spends it once a fight: that many debuff stacks per grade of
  its element on the foe (Water as Ice, none as Wood), a fail roll, and the event `pill_burned` (`element`, `grade`,
  `failed`). The pill's own effect is not modelled yet. Fixture t18.
- **Slice 4:** the element and damage type `light` (Hán-Việt scope `quang`); a companion's `tags` ride on its hits
  (filter `tags`: `crane`, `bird`); a debuff batch laid by an art tagged `talisman` is held fast through every
  cleanse while its caster holds the mod flag `talisman_fast` (Rainfast Ink). Fixture t19. Not built: an added Soul
  part meeting `[soul]`-scoped modifiers (Damage Types rule 1, 2026-11-26); today it takes the art's own scope only.
- **Slice 5, the duel readings** (Combat rule 25, Formulas L): readables `own|foe.composed` (a stance tagged
  `composed`, or 2 s since its last damaging or movement art or evade), `composed_time`, `pressing` (not Composed;
  a stance tagged `pressing`, or within 1 s of a movement art, tag `movement`, or an evade), `foe_pressed` (the
  reader's foe acted within 1 s), `since_act`, `field_up` (the stance is tagged `field`), `broken` (the reader's foe
  has fallen to 25 % this fight), `wounded` (the reader has). Events `wounded` and `broken`, once a fight, right after
  the hit, tick or pulse that crossed. A state may carry `tags`. Fixture t20.

### World-depth vocabulary (2026-11-26; to build in world-depth Stage 5)

Proposed words from the authored records (`design/world/depth/builds/authored/auth-tech.json` `new_vocab`, listed in
`builds/engine-wishes.md` §4; approved for the plan by the user 2026-11-26). Until Stage 5 builds them the loader
does not know them, so a build file that uses one stops with `UNKNOWN_FIELD`.

- **Root gates** on an art: `requires.root_lacks` and `requires.root_has` (an element or variant id): the art may
  be slotted only if the owner's root lacks or has it (`bronze-answers`: no Thunder; `dawn-call`: Light).
- **Event filters:** `fire_art.filter.element`; `filter.not_art_id`.
- **Self-debuffs:** `stacks` with `kind: debuff` on `side: own` (a Burn on yourself), the event `tick_taken`, read
  as `own.debuff.<el>` (`into-the-vent`).
- **Movements:** `movements`, per-firing sub-rules taken in turn from a counter; the event `in_turn`; a counter on
  `side: foe`; `next_art_cost` (`nine-shao-next-movement`, `remnant-next-movement`).
- **A counted-chance meter kept between fights**, whose p reads khí vận (`playing-past-the-break`; an exception to
  Effects Formulas A, noted in Effects rule 12).
- **Moving and reading:** `move_own_debuffs`; read `own.tech_layer.<id>`; `free_hit.pass_shields`
  (`move-the-sickness`).
- **A counted curse that takes no curse slot** (`black-under-white`; an exception noted in the Effects Status
  Catalogue).
- **Lineage art ids** still to assign (Stage 6): `where-the-drop-falls`, `line-through-the-ice`, `a-bite-on-the-line`.

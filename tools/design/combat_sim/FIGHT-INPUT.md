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
  now be assessed. Still not modelled: escape, conversion inside a hit, forms and stances, loadout swaps, ward
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
  `stacks`, `dur`, `side`; ids from the Status Catalogue), `cleanse`, `timer` (`side` own or foe, `which` all,
  others or longest, `by` seconds; foe delays fall off), `refund`, `counter`, `strip` (`n`, `el`, `steal`),
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
  `design/arts/family-*.json` (or a `common` art of `part-*.json`) with its effects, counters and states; other keys
  on the entry override its fields. `"techniques": ["<technique id>"]` loads each technique's passives from
  `design/techniques/catalogue-*.json` as one always-on Effect `tech:<id>` (`--without tech:<id>` tests it). Passives
  with no engine stat, and scopes on stats the engine reads without hit context, print as UNMODELLED.
  `design/arts/INDEX.md` lists every technique and art on one line.


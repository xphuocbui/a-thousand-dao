# Stage 6 Record Pass — `thinh_vu` (Thính Vũ Lâu)

Progress log for `thinh_vu` following `_brief-record.md` (`OWNER = thinh_vu`).

## Checklist

- [x] **Step 1 — Mechanic table**
- [x] **Step 2 — Techniques & arts** (`design/stage6-staging/thinh_vu/techniques/catalogue-sect-thinh_vu.json`, `arts/part-sect-thinh_vu.json`, `pending.json`, and `foreign/xuyen_lam/...` for `calm-wind-staff-canon`; do NOT duplicate `phuong_minh`'s `foreign/market-folk/`)
- [x] **Step 3 — Effects** (`design/stage6-staging/thinh_vu/effects/thinh_vu.effects.json`)
- [x] **Step 4 — Items & sets** (`design/stage6-staging/thinh_vu/items/catalogue-sect-thinh_vu.json`, `items/sets-thinh_vu.json`)
- [x] **Step 5 — Depth edits** (`design/world/depth/sects/thinh_vu.techniques.json`)
- [x] **Step 6 — Stand-ins & beasts** (`thinh_vu.cast.json`, `thinh_vu.2.cast.json`, `thinh_vu.4.cast.json`; 0 beasts)
- [x] **Step 7 — Holder check & verification** (`lint_techniques.py`, `lint_arts.py`, `lint_items.py`, `depth_check.py`, `sect_fight.py thinh_vu`, `sect_fight.py thinh_vu --gap 1`, standalone Effect/art probes)
- [x] **Step 7b — Băng Tâm pilot lessons verification**:
  - [x] No spatial condition / fight positioning assumptions in any Effect or Art
  - [x] No `"free_hit"` expecting crit (`sword-raised-to-the-cloud` uses direct art hit with `charges: 2` + `steps` so it crits for `tvl-gold-sand-pair`)
  - [x] `self.mod(att, "acc")` passes no `ctx` (any `acc` mod omits `tags`); `art_fired` runs before `hit_landed` (uses `held: {"until": "hit_landed"}` where needed); single `s.state` slot guarded with `own.state.any == 0`
  - [x] Every Effect checked against real holders + standalone probe where `sect_fight.py` skips `technique.effects`, `MAX_ARTS = 6` cutoff, or specific set combos
  - [x] Early-promoted `foreign/xuyen_lam/` matches `xuyen_lam`'s lineage; `market-folk` (`censer-smoke-manual`, `pill-smoke`) uses `phuong_minh`'s early-promotion without duplication
- [x] **Step 8 — Write review** (`production/plans/stage6/thinh_vu-review.md`)
- [x] **Step 9 — Finish** (append `RECORD PASS DONE`, write `production/plans/stage6/thinh_vu.done`, verify no stray files)

---

## Step 1 — Mechanic Table

### Techniques (6 depth + 3 new stand-ins + 1 early-promoted `xuyen_lam`)

| Id | Tier | Kind | Elements | Layers | Passives / Bonuses | Arts / Passive Effects | Notes |
| --- | --- | --- | --- | --- | --- | --- | --- |
| `rain-on-bronze-primer` | 0 | `main` | `kim`, `hoa` | 6 | `attack_pct` 4 `["kim"]`, `attack_pct` 4 `["hoa"]`, `crit_chance_pct` 4 `["kim"]`, `resist_pct` 50 `["lightning"]` | `whetstone-pass` (1), `bell-struck-palm` (2) | Depth proposal; Metal + Fire convergence primer |
| `rain-chain-sword-scripture` | 1 | `main` | `kim`, `loi` | 9 | `attack_pct` 5 `["kim"]`, `attack_pct` 5 `["sword"]`, `crit_chance_pct` 4 `["sword"]`, `resist_pct` 75 `["lightning"]` | `sheathed-edge` (1), `blood-quench-blade` (2), `where-the-drop-falls` (3); `effects`: `Not a Drop Spilled` (4), `Return to the Scabbard` (6) | Passive arts staged as `technique-effects` (`pending.json`: `build`) |
| `thunder-in-the-rain-canon` | 2 | `main` | `kim`, `loi` | 12 | `attack_pct` 6 `["kim"]`, `attack_pct` 6 `["loi"]`, `resist_pct` 150 `["lightning"]`, `can_cot` 1.33 `[]` | `answering-peal` (1), `chain-arc` (2), `sundering-wedge` (3), `bronze-answers` (4), `the-chain-carries-it-down` (5), `rain-before-the-peal` (6) | `can_cot` noted `NOT_PRICED` (out-of-fight) |
| `lightning-rod-sword` | 1 | `secret` | `loi` | 9 | `attack_pct` 6 `["loi"]`, `art_speed_pct` 5 `["loi"]`, `crit_chance_pct` 5 `["loi"]`, `resist_pct` 75 `["lightning"]` | `overload-form` (1), `capacitor-palm` (2), `sword-raised-to-the-cloud` (3) | Inner Thunder hall method |
| `listening-rain-sutra` | 3 | `secret` | `thuy`, `kim` | 15 | `evade_pct` 6 `[]`, `linh_luc_regen_inc_pct` 15 `[]`, `attack_pct` 8 `["kim"]`, `art_speed_pct` 6 `["kim"]`, `than_thuc_pct` 5 `[]` | `deep-lake-stance` (1), `echo-of-the-dodge` (2), `rain-on-the-withered-lotus` (4), `the-night-is-long` (6) | Head-only sutra (`manh_da_vu`, 12) |
| `opening-thunder-canon` | 2 | `main` | `loi` | 12 | `attack_pct` 10 `["loi"]`, `art_speed_pct` 8 `["loi"]`, `crit_damage_pct` 20 `["loi"]`, `defense_pct` -8 `[]` | `stormcloud-familiar` (1), `storm-bank` (2), `open-the-sky` (4) | Forbidden Khải Lôi method |
| `black-toad-venom-manual` | 1 | `main` | `moc`, `thuy` | 9 | bonus: `linh_luc_pct` 10; passives: `attack_pct` 5 `["moc"]`, `stack_effect_pct` 12 `["moc","debuff"]`, `stack_duration_pct` 10 `["debuff"]`, `healing_pct` 6 `[]` | `toad-venom-mist` (1), `bitter-tasting-draught` (3) | **Stand-in** replacing `huyen_moc` on `o_thiem_tu` (8), `mai_doc_ca` (5) |
| `rain-cistern-breath` | 0 | `main` | `thuy`, `moc` | 6 | `khi_huyet_pct` 5 `[]`, `health_regen_inc_pct` 6 `[]`, `resist_pct` 30 `["cold"]` | `cistern-draw` (1) | **Stand-in** replacing `hoang_thuy` on `dau_tam_thuy` (6) |
| `stone-stove-breath` | 0 | `main` | `moc`, `kim` | 6 | `khi_huyet_pct` 5 `[]`, `defense_pct` 4 `[]`, `health_regen_inc_pct` 4 `[]` | `stoke-the-embers` (1) | **Stand-in** replacing `hoang_moc` on `sa_bat_ngu` (6) |
| `calm-wind-staff-canon` (`foreign/xuyen_lam`) | 1 | `main` | `kim`, `moc`, `tho` (lint proxy for `[]`) | 9 | bonus: `khi_huyet_pct` 10; passives: `attack_pct` 5 `["physical"]`, `defense_pct` 5 `[]`, `status_resist_pct` 12 `[]`, `linh_luc_regen_inc_pct` 6 `[]` | `walk-slowly` (1), `who-is-afraid` (2), `one-straw-cape` (4); `effects`: `The Long Road` (5) | **Early promotion** from `xuyen_lam.techniques.json` for `uc_da_diep` (6); `names` lint proxy logged |

### Arts (11 depth + 4 stand-in + 3 `foreign/xuyen_lam`)

| Id | Technique | Role / El / Kind | Engine Form Summary |
| --- | --- | --- | --- |
| `bell-struck-palm` | `rain-on-bronze-primer` | `damage` / `metal` / `phys` | `c_art: 1.0, cost_share: 0.03, cooldown: 2.5, debuff: ["fire", 1, 6.0]`; `hit_landed` sets `bell_struck=1` (8 s); next `metal` art with `foe.debuff.fire >= 1` (`art_fired` + `held: until hit_landed`) gets `dmg_more: 15` and clears `bell_struck`. |
| `where-the-drop-falls` | `rain-chain-sword-scripture` | `damage` / `metal` / `phys` | `c_art: 1.5, cost_share: 0.04, cooldown: 4.0`; `guards: [own.counter.foe_struck >= 1]`. `hit_taken` sets `foe_struck=1`; art fires once as a fast Metal sword counter-cut (`art_id: "where-the-drop-falls"`, feeds `bronze-answers`) and clears `foe_struck`. |
| `Not a Drop Spilled` (passive art) | `rain-chain-sword-scripture` | passive Effect | Tracked in `thinh_vu.effects.json` (`technique-effects` pending word). Counts `not_a_drop_cups` (+1 per pulse without damaging art, reset cleanly on damaging art `art_fired`); each Cup gives `linh_luc_regen_inc_pct +5`; next damaging art banks `dmg_more: 3 * cups` (up to engine layer cap 100) via `held: {until: "hit_landed", read: "own.counter.not_a_drop_cups"}` and clears Cups. |
| `Return to the Scabbard` (passive art) | `rain-chain-sword-scripture` | passive Effect | Tracked in `thinh_vu.effects.json` (`technique-effects` pending word). Counts `scabbard_idle` pulses without damaging art (`reset` on damaging `art_fired`); at `>= 3` sets `scabbard_armed = 1` + grants `temp_mod` `no_evade` (`target_no_evade` -> wait: `ignore_evade` via `steps`/`ignore_evade`? Let's use `engine.py` `no_evade` on foe / `bypass_evade` — check `engine.py` exact key!) and clears `no_second_penalty` / re-arms first-hit latches (`no_second_done`, `first_sword_done`). |
| `bronze-answers` | `thunder-in-the-rain-canon` | `damage` / `metal` / `phys` | Authored (`e1`). `c_art: 0.9, cost_share: 0.03, cooldown: 3.0`, shares `peal` counter (`each_for: 8`). Crit / `where-the-drop-falls` hit adds `peal`; at `peal >= 3`, Metal crit `fire_art` last Metal at `0.6` and resets `peal`. `empower` `c_mult: 3` at `peal >= 3` and (`foe.debuff.metal >= 4` or `own.fired_within.1.group.thunder-in-the-rain-canon >= 2`). `requires` omitted for `lint_arts.py` and logged. |
| `the-chain-carries-it-down` | `thunder-in-the-rain-canon` | `damage` / `thunder` / `elem` | `c_art: 1.4, cost_share: 0.06, cooldown: 5.0`. Thunder hit + chains extra bolt (`free_hit c: 0.45 elem`) scaled by Metal/Thunder stacks when foe holds `thunder >= 1`; `effects`: on `hit_landed`, if `foe.debuff.metal >= 2`, converts up to 2 Metal stacks -> 2 Thunder stacks (`consume metal n=2 -> stacks thunder`). `requires` omitted for `lint_arts.py` and logged. |
| `rain-before-the-peal` | `thunder-in-the-rain-canon` | `stacks` / `metal` / `elem` | `c_art: 0.9, cost_share: 0.05, cooldown: 6.0, debuff: ["metal", 3, 8.0]`. Plants `rain_peal_timer = 3` (decays 1/pulse); when it reaches 1 -> fires delayed bolt (`free_hit c: 1.1 elem` + `stacks thunder 2 for 8`), amplified (`c: 2.2`, `stacks thunder 3`) if `foe.debuff.thunder >= 3` or `own.tech.lightning-rod-sword >= 1` or `own.tech.heavenly-tribulation-scripture >= 1`. |
| `sword-raised-to-the-cloud` | `lightning-rod-sword` | `damage` / `thunder` / `elem` | `c_art: 0.0, cost_share: 0.06, cooldown: 6.0, charges: 2`. Cast sets `sword_raised = 3` (`each_for: 3`) — **no `state` used** so `overload-form` is never overwritten. After 1 s (`sword_raised` tick at 2), if foe didn't act (`own.foe_pressed == 0`), fires bolt via `steps` (`c_art: 1.9, elem`) + `stacks thunder 2 for 8` so it **can crit** for `tvl-gold-sand-pair`! If `own.foe_pressed >= 1`, misses and adds `+2.0 s` `timer` delay to itself. |
| `rain-on-the-withered-lotus` | `listening-rain-sutra` | `utility` / `water` / `elem` | `c_art: 0.0, cost_share: 0.05, cooldown: 7.0`. Grants `lotus_listen = 6`, `decoy {n: 1}`. On `decoy_struck` while `lotus_listen >= 1`, raises `emit {"event": "evaded"}`. Any `evaded` adds `+1 heard` (`each_for: 12`). Next `metal` art banks `dmg_more: 12 * heard` (via `held: {until: "hit_landed"}`) and clears `heard`. |
| `the-night-is-long` | `listening-rain-sutra` | `utility` / `water` / `elem` | `c_art: 0.0, cost_share: 0.06, cooldown: 9.0, guards: [own.counter.night_rain <= 1]`. Sets `night_rain = 10` (`decay_per_pulse: 1`); enters `state: "night-rain-field"` (tags `["field"]`) only if `own.state.any == 0`. Each pulse while `night_rain >= 1`: applies `temp_mod speed -12, regen_inc -20` to foe and restores `gain_qi share: 0.025` to own. |
| `open-the-sky` | `opening-thunder-canon` | `damage` / `thunder` / `elem` | `c_art: 1.5, hp_cost: 0.2, cost_share: 0.05, cooldown: 10.0`. Sets `open_sky = 8` (`decay_per_pulse: 1`). While `open_sky >= 1`, each `thunder` `art_fired` (not trigger/re-fire, gated with `limit: {per_pulse: 1}` + `own.counter.sky_echo == 0`) triggers `fire_art {"which": "last", "share": 1.0}` with `sky_echo` pulse guard so every Thunder art casts twice without infinite recursion. |
| `toad-venom-mist` | `black-toad-venom-manual` | `stacks` / `wood` / `elem` | `c_art: 0.9, cost_share: 0.04, cooldown: 4.0, debuff: ["wood", 3, 8.0], tags: ["wood", "over_time", "poison"]`. Stand-in art. |
| `bitter-tasting-draught` | `black-toad-venom-manual` | `heal` / `water` / `elem` | `c_art: 0.0, c_heal: 1.2, cost_share: 0.05, cooldown: 6.0, cleanse: 1, buff: ["wood", 2, 6.0]`. Stand-in art. |
| `cistern-draw` | `rain-cistern-breath` | `heal` / `water` / `elem` | `c_art: 0.0, c_heal: 1.0, qi_restore: 0.06, cost_share: 0.03, cooldown: 5.0`. Stand-in art. |
| `stoke-the-embers` | `stone-stove-breath` | `ward` / `wood` / `elem` | `c_art: 0.0, cost_share: 0.04, cooldown: 5.0, buff: ["wood", 2, 6.0]`, grants `ward_grow {share: 0.08, of: "hp"}` + `regen_inc +10` for 4 s. Stand-in art. |
| `walk-slowly` (`foreign/xuyen_lam`) | `calm-wind-staff-canon` | `utility` / `""` / `phys` | Sets `walk_slowly_on = 1` + gains 1 `walk_slowly` stack (`each_for: 15`) per pulse while `own.pressing >= 1`, cleared if `!own.pressing` or `escape` fired. Next `phys` art banks `dmg_more: 6` per stack via `held: {until: "hit_landed"}` and clears `walk_slowly`. |
| `who-is-afraid` (`foreign/xuyen_lam`) | `calm-wind-staff-canon` | `damage` / `""` / `phys` | `c_art: 1.6, cost_share: 0.04, cooldown: 4.5, tags: ["physical", "staff"]`; if `own.counter.walk_slowly >= 5` on hit, cleanses 1 negative status (`cleanse: {status: "fear"}` / `cleanse: 1`). |
| `one-straw-cape` (`foreign/xuyen_lam`) | `calm-wind-staff-canon` | `ward` / `""` / `phys` | `c_art: 0.0, cost_share: 0.05, cooldown: 8.0`; for 4 s (`cape = 4`), grants `status_resist +50` (`slowed` / curse mitigation), `ward_grow 0.10`, and reduces incoming trigger/field damage (`dmg_taken_mult -0.25` via `temp_mod`). |

### Effects (20 total in `thinh_vu.effects.json`: 7 item + 11 set + 2 passive-art technique Effects)

| Name | Owner / Source | Engine Mechanic |
| --- | --- | --- |
| `Under the Umbrella` | `tvl-tuong-phi-tan` | `cooldown_ms: 10000` (10 s counter `umbrella_cd`); on `incoming` / `hit_taken` (`filter: {"element": "lightning"}`, `umbrella_cd == 0`), mitigates (`reduce_pct` / `ward_grow` or `heal` + `gain_qi {share: 0.1, of: "amount"}`) — wait: verify exact `incoming` / damage prevention verb in `engine.py` before writing Step 3! |
| `Nine Cups` | `tvl-founders-rain-chain` | Counter `nine_cups` (+1 on `hit_taken`); at `>= 9`: resets `nine_cups` and sets `timer: {which: "next", by: -99}` + `temp_mod {next_art_cost: -1.0}` (`cast at once, no linh lực`). |
| `Every Lamp Has a Name` | `tvl-soul-vault-lamp` | While foe has a curse (`foe.curse.any >= 1`), grants `ignore_evade` / `acc +100` (or `temp_mod no_evade` on foe) and on `curse_tick` (`tick` / `pulse`), drains foe `qi` (`burn_qi {of: "max", share: 0.015, to_self: 1.0}`). |
| `No Second Cut` | `tvl-night-far-gone` | Tracks `no_second_done`; first `sword` hit (`no_second_done == 0`) crits (`crit +100`) and gains `pierce +50`, then sets `no_second_done = 1` on `hit_landed`. Subsequent hits while `no_second_done == 1` get `dmg_more: -12`. |
| `Glass Rings` | `tvl-glass-flying-sword` | When `sword-raised-to-the-cloud` fires a bolt (`hit_landed` `art_id: "sword-raised-to-the-cloud"`), `fire_art {"which": "sword-raised-to-the-cloud", "share": 1.0}` (limit `per_cast: 1`) and self-damage `0.05 * hp_max` (`self_dmg` / `hp_cost`). |
| `The Bell Hears First` | `tvl-eaves-listening-bell` | At start / first foe act (`fight_start` / first `foe.art_fired`), reveals foe & sets `timer: {which: "next", by: -99}` once per fight (`bell_hears_done`). |
| `It Hums` | `tvl-gate-drumstick` | On `status_applied` / `stack_applied` (`filter: {"element": "thunder", "side": "foe"}`), adds `hum_charges` (`each_for: 4.0`). At `>= 4`, next `thunder` art (`hit_landed`) consumes `hum_charges` and applies `stun` (`dur = 0.5 + 0.1 * (charges - 4)`). |
| `The Rain Answers` | `tvl-night-rain-regalia` (3 pc) | While `own.counter.night_rain >= 1` or holder wears `tvl-tuong-phi-tan`, on `evaded`, adds `rain_rings`; at 3 rings resets `rain_rings` and fires Lightning bolt (`free_hit` or scaled `c` from Metal attack). |
| `The Wick Is Cut` | `tvl-soul-vault-pair` (2 pc) | Once per fight (`wick_cut_done == 0`), when `foe.hp_pct <= 0.25` and `foe.curse.any >= 1`, converts curse into `seal` (`status: {"id": "seal", "dur": 2.0}`, or removes arts / applies `seal`). |
| `Words Before Blades` | `tvl-old-tower-pair` (2 pc) | First 5 s (`fight_start` -> `words_guard = 5`) while no damaging art fired: `dmg_taken -25` (`temp_mod`); on `evaded` adds `water` buff stack + `words_evades`. First `sword` `art_fired` spends `words_evades` for `dmg_more: 8` each (`held: {until: "hit_landed"}`). |
| `Branded to the Vein` | `tvl-vein-keeper` (2 pc) | When `foe.curse.count >= 2`, each `lightning` `hit_landed` extends active curses on foe (`extend_status` / `refresh` / `+1 s`). |
| `One Cut Drawn Out` | `tvl-dalan-suite` (2 pc) | Each pulse without attacking adds `drawn_out` (`crit_dmg +12` per stack spent on next `sword` hit); first `sword` art cannot be evaded; links `Return to the Scabbard` after 3 s idle to reset `no_second_done` and first-art clause. |
| `Thin as Glass` | `tvl-glass-storm` (3 pc) | Always: `healing_inc_pct -20`. Above 50% HP (`own.hp_pct > 0.5`), Lightning `crit` triggers bonus bolt (`free_hit c: 0.45 elem`). On `hit_taken` (`ev.amount > 0.10 * hp_max`), `timer: {which: "next", filter: {"element": "lightning"}, by: -99}`. |
| `Heard Before It Falls` | `tvl-hall-of-echoes` (3 pc) | At `fight_start`, grants `decoy {n: 1}` (first foe art) + `ward_grow {share: 0.08, of: "hp"}` + marks foe `heard_marked = 1` on evade; `seal` / `status_duration` on marked foe `+2 s`. |
| `The Gate Drums` | `tvl-gate-drum` (3 pc) | Every 4 Thunder/storm stacks applied (`drum_storms`), beats drum (`drum_beats += 1`): fires bolt (`free_hit c: 0.7 elem`) and applies `slowed_time` (`2 + (drum_beats - 1)` stacks). |
| `The Struck Shed` | `tvl-gold-sand-pair` (2 pc) | On `crit` (`filter: {"art_id": "sword-raised-to-the-cloud"}` while `own.counter.sword_raised >= 1`), adds 1 `thunder` debuff stack on foe. |
| `After the First Blow` | `tvl-spring-rain-pair` (2 pc) | Tracks first foe attack (`first_blow_seen`); if `evaded` before hit taken, sets `after_blow_crit = 1`; next `sword` art gains `+100` `crit` (`held: {until: "hit_landed"}`) and clears. |
| `Formed in a Storm` | `tvl-cone-thunder` (2 pc) | Tracks `fire_storm_halves` (+1 per `fire` `hit_landed`); every 2 hits (+1 storm count) fires `free_hit c: 0.4 elem` + `stacks thunder 1` to feed Thunder chains/stacks. |
| `Not a Drop Spilled` | `rain-chain-sword-scripture` (L4 passive) | See technique table (`technique-effects` pending word). |
| `Return to the Scabbard` | `rain-chain-sword-scripture` (L6 passive) | See technique table (`technique-effects` pending word). |

RECORD PASS DONE

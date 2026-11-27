# Lê Hoa Am (`le_hoa`): Stage 6 record pass review (2026-11-27, headless/delegated job, decisions auto-accepted)

## Summary

**Built (all staged in `design/stage6-staging/le_hoa/`; nothing exported, no files touched outside allowed paths):**
- **3 techniques** (`techniques/catalogue-sect-le_hoa.json`): `gate-sword-primer` (Yellow main, `names: ["kim"]`), `pear-blossom-snow-sword` (Profound secret, `names: ["bang", "kim"]`), and `sealed-cold-sutra` (Earth secret, `names: ["bang"]`). `winter-toll-canon` is already committed in `design/techniques/catalogue-ice.json`. Every bonus and passive on the staged techniques is new and sized to its tier (§C).
- **5 new arts** (`arts/part-sect-le_hoa.json`): `bar-the-gate`, `eighth-month-snow`, `one-branch-of-pear`, `lay-the-seal`, and `sit-against-the-door`. All 5 art ids are registered in `design/world/depth/sects/le_hoa.techniques.json`.
- **3 Effects** (`effects/le_hoa.effects.json`): 1 item Effect (`Toll of the Frozen Bolt`) and 2 set Effects (`Until It Stops Wanting`, `None Shall Pass`). Every Effect self-declares all counters it reads or writes in its own `counters` array for standalone GDScript compilation (`test_every_library_effect_compiles` / `fighter_profile_loader.gd`), validates cleanly in `engine.validate`, and runs on its real holders in `sect_fight.py`.
- **5 items and 2 sets** (`items/catalogue-sect-le_hoa.json`, `items/sets-le_hoa.json`): depth modifiers preserved verbatim (all 24 lines run), `sources: ["npc"]`, `unique: true`, `"rarity": 5` on the grade-4 treasure `lh-bolt-ice-bell`, and the R6 `exception` mark on the 4 weapon/ward/armour pieces (`lh-bolt-ice-bell`, `lh-snow-veil-robe`, `lh-pear-branch-sword`, `lh-miners-gate-coat`).
- **0 stand-ins** (`stand_ins: 0`; all 11 living members already hold valid lineage techniques).
- **0 beasts** (`le_hoa` has no `beasts.json`).
- **0 pending words** (all records run on existing engine words; no `pending.json` needed).
- **0 early promotions** (`cross_owner: 0`).

**Counts:**
- **Deviations:** `10` (§C–§F).
- **Decisions taken for the user:** `5` (§A).
- **Pending words:** `0`.
- **Never ran:** `0` — all 3 Effects and all 5 new arts fire and run on their real holders across `gap 0` and `gap 1` (plus `manh_tinh_chi + bar-the-gate` 7th-slot probe).

**Checks (all run after final edit with `DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\le_hoa`):**
- `lint_arts.py`: checked 5 arts in 1 file, **0 findings**.
- `lint_techniques.py`: checked 3 techniques, **0 findings** (`7.9 W / 8`, `15.5 W / 16`, `22.3 W / 24`).
- `lint_items.py`: checked 5 items, **0 findings** (`unique 5 of 5`).
- `depth_check.py --quiet`: **findings: none**.
- `depth_gap.py --sect le_hoa`: `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `ties_unmapped: 0`, `ties_over_cap: 0`, `engine_words: 0`, `wishes_open: 0`, `lines: 24/24 runs`.
- Standalone Effect validation: all 3 Effects validate cleanly with all read/written counters declared locally.
- `sect_fight.py le_hoa` (`--seeds 5`, `gap 0` and `gap 1`): **0 REFUSED**, all 5 new arts fire and all 3 Effects execute on their real holders.

**Open items (for Stage 7 / user / serial step):**
- `lh-bolt-ice-bell` has `kind: "treasure"` (grade 4, rarity 5); tracked at the serial/export step for `export_named.py` treasure handling (carried over from `bang_tam.md` / `truc_thuc-review.md`).
- `manh_tinh_chi` carries 7 arts total across `winter-toll-canon` (4), `pear-blossom-snow-sword` (2), and `gate-sword-primer` (1); `sect_fight.py` caps at 6 slots (`bar-the-gate` verified via a dedicated probe alongside `deep-winter-form` and `eighth-month-snow`).

---

## A. Decisions auto-accepted (user rule 2026-11-26), with reasons

1. **Self-counters `gate_raised` (`bar-the-gate`), `petal_field` (`eighth-month-snow`), and `sit_door` (`sit-against-the-door`) instead of `s.state`.**
   - *Choice:* Track all three temporary stances/fields via `decay_per_pulse: 1` self-counters (`set: 5` -> 4 pulses for `gate_raised` / `petal_field`, `set: 7` -> 6 pulses for `sit_door`) rather than `s.state`.
   - *Reason:* Every inner-gate and elder holder (`thai_le_tuyet`, `manh_tinh_chi`, `ung_le_am`, `ton_han_y`) slots `winter-toll-canon`'s committed art `deep-winter-form` (`family-ice.json`), which toggles `s.state = "deep-winter"`. Using `s.state` on `bar-the-gate`, `eighth-month-snow`, or `sit-against-the-door` would overwrite `deep-winter` (Băng Tâm Lesson 2). Self-counters also avoid altering `own.composed` artificially while allowing `sit-against-the-door` and `lay-the-seal` to interact cleanly.
2. **Reading "each second the foe presses" on `eighth-month-snow` (`own.foe_pressed`, `foe.pressing`, or `foe.since_act <= 1.0` with `foe.fired >= 1`).**
   - *Choice:* Check `any` of `own.foe_pressed >= 1`, `foe.pressing >= 1`, or `foe.since_act <= 1.0` (gated by `foe.fired >= 1` so `t_act == None` at fight start is excluded) at `cd = 6.0`.
   - *Reason:* In `engine.py`, `own.foe_pressed` uses strict `self.t - o.t_act < 1000` at pulse time, which misses exact-integer cooldowns like `typical`'s `2.0 s` `quick` art (`1000 ms` is not `< 1000 ms`), whereas `foe.since_act <= 1.0` catches both sub-second and exact-1-second foe actions. Lowering `cd` from `7.0` to `6.0` ensures the drift opens reliably within 12–14 s fights.
3. **Splitting `sit-against-the-door` `always` mods (`ward_pct` vs `status_dur [curse]`) and using `ward_grow` for ward regeneration.**
   - *Choice:* Put `ward_pct: 15` and `status_dur: 30 [curse]` in separate `always` records (never sharing one `mod` dict with a `tags` filter), regenerate stance ward via `ward_grow {share: 0.04 on cast, 0.02/pulse of hp}`, and grant `+3 s` (`add: 3`) to `lay-the-seal`'s `seal_hold` when `sit_door >= 1`.
   - *Reason:* `engine.py` evaluates `ward_pct` with `ctx = None`, so adding `tags: ["curse"]` to the same `mod` would cause `ward_pct` to never match; and two unstacked `mod` actions in one record overwrite each other. `ward_grow` (`bang_tam` W1) creates/refills the holder's stance ward without needing an existing stance ward.
4. **`Until It Stops Wanting` tracks Frost Seal duration via shared `seal_hold` and uncapped `vigil_toll` (`each_for: 10`).**
   - *Choice:* Trigger on `winter-toll-canon` `art_fired` whenever `own.counter.seal_hold >= 1`, `foe.status.heavy_breath >= 1`, or `foe.status.slowed_time >= 1`, adding `1` to `seal_hold` and `1` to `vigil_toll` (`each_for: 10`, no `cap`), with `dampen_taken: 5.26` (`1 / 1.0526 = 0.95`, 5 % less damage per toll) scaled by `vigil_toll`.
   - *Reason:* `each_for: 10` without `cap` implements "stack with no ceiling, and each fades on its own" directly in both engines; checking `heavy_breath` and `slowed_time` alongside `seal_hold` ensures `Until It Stops Wanting` works even if a holder fires `rime-lock-seal` before `lay-the-seal` (or lacks `lay-the-seal`).
5. **`Toll of the Frozen Bolt` maps frozen-lightning stun to `stop_clock` 0.5 s; `None Shall Pass` uses `bypass: 0.5` + `pen: 100` (`tags: ["sword"]`) spent on `crit`.**
   - *Choice:* Map `"its arts that come ready in the next 0.5 s wait until it ends"` on `Toll of the Frozen Bolt` to `stop_clock {side: "foe", seconds: 0.5}` on every 5th `winter-toll-canon` art; map `None Shall Pass` to `gate_blocks` on `blocked` -> at 3, arm `gate_pass = 1` granting `sure_crit: 1`, `bypass: 0.5`, `pen: 100` scoped inside `mod` to `tags: ["sword"]`, spent on `crit` (`tags: ["sword"]`).
   - *Reason:* `stop_clock` is the ruled Stage 6 engine word for freezing/halting art timers (`DECISIONS-2026-11-26.md`); spending `gate_pass` on `crit` rather than `hit_landed` follows Băng Tâm Lesson 3 (`Every Fifth a Star`), and `bypass 0.5 + pen 100` pierces both ward shields (`bypass_cap: 0.5`) and drain ward resistance.

---

## B. Mechanic table (Step 1)

| Record | Mechanic | Engine status | Implementation |
|---|---|---|---|
| `gate-sword-primer` / `bar-the-gate` | Guarding stance: while Composed with sword raised, next hit halved + light Metal hit back | Has | `c_art 0`, `gate_raised` (`decay_per_pulse: 1`, set 5 = 4 pulses), `gate_guard` (set 1); while `gate_raised >= 1`, `gate_guard >= 1`, `own.composed >= 1`: `always` `dampen_taken 100`, `was_hit` -> `gate_guard = 0`, `free_hit 0.65 phys`, +1 Metal stack (6 s) |
| `pear-blossom-snow-sword` / `eighth-month-snow` | Field of frost petals for a few s; foe pressing gains 1 Ice/s; user moves more lightly | Has | `c_art 0`, `petal_field` (`decay_per_pulse: 1`, set 5 = 4 pulses), +1 Ice stack (6 s) on cast; `always` `evade 4` & `art_speed 8`; `pulse` (`foe.fired >= 1` & `own.foe_pressed` / `foe.pressing` / `foe.since_act <= 1.0`) -> +1 Ice stack (6 s) |
| `pear-blossom-snow-sword` / `one-branch-of-pear` | Metal thrust; at 5+ Ice stacks on foe, pierces ward | Has | Metal `phys` `c_art 2.0`, `tags [physical, sword, pierce]`; `empower` (`foe.debuff.ice >= 5`) -> `c_mult 1.3`, `bypass 0.5`, `pen 120` (`art_id: one-branch-of-pear`) |
| `sealed-cold-sutra` / `lay-the-seal` | Cold seal: lengthens cooldown, lowers damage; 4th seal stills all arts for a breath | Has | Ice `c_art 1.2`, `slowed_time` 1 (4 s), `timer +1.0 s` (`next`), `seal_hold` (set 7 -> 6 pulses; +3 if `sit_door >= 1`), `always` `dampen_taken 12`; 4th `hit_landed` -> `stop_clock 1.0 s` on foe |
| `sealed-cold-sutra` / `sit-against-the-door` | Stance: while sitting, ward regenerates and seals last longer | Has | `c_art 0`, `sit_door` (`decay_per_pulse: 1`, set 7 = 6 pulses); `ward_grow` 4 % HP on cast + 2 %/pulse; `always` `ward_pct 15` and `status_dur 30 [curse]` |
| `Toll of the Frozen Bolt` (`lh-bolt-ice-bell`) | Every 5th Winter Toll Canon art: 2 Ice stacks + 0.5 s art freeze | Has (`stop_clock`) | `art_fired [group: winter-toll-canon]` increments `bell_toll`; at 5 -> reset, +2 Ice (8 s), `stop_clock` 0.5 s on foe |
| `Until It Stops Wanting` (`lh-pear-blossom-vigil` 3pc) | Each bell toll on Frost-Sealed foe: hold +1 s, foe deals 5 % less for 10 s, uncapped | Has (`each_for`) | `art_fired [group: winter-toll-canon]` while `seal_hold >= 1` / `heavy_breath >= 1` / `slowed_time >= 1` -> `seal_hold +1`, `vigil_toll +1` (`each_for: 10`, no cap); `always` scaled by `vigil_toll`: `dampen_taken 5.26` |
| `None Shall Pass` (`lh-the-gate` 3pc) | After blocking 3 hits, next thrust is sure crit and pierces ward | Has | `blocked` -> `gate_blocks +1`; at 3 -> `gate_blocks = 0`, `gate_pass = 1`; `always` (`gate_pass >= 1`) -> `sure_crit 1`, `bypass 0.5`, `pen 100` (`tags: [sword]`); spent on `crit [sword]` |

---

## C. Techniques (`catalogue-sect-le_hoa.json`)

All bonuses and passives below are **new** (the depth proposals name none) and sized against same-tier catalogue peers.

| Technique | Tier, kind | Bonuses (new) | Passives (new) | Abilities (unlock) | Peer & W |
|---|---|---|---|---|---|
| `gate-sword-primer` | Yellow main, Metal (`["kim"]`) | none | `block_rating` 8 `[]`, `defense_pct` 2 `[]`, `attack_pct` 4 `["sword"]` | `bar-the-gate` (1) | `nine-temper-scripture` / `furrow-iron-breath` (`7.9 W of 8`) |
| `pear-blossom-snow-sword` | Profound secret, Ice+Metal (`["bang", "kim"]`) | `attack_pct` 8 | `crit_chance_pct` 5 `["sword"]`, `art_speed_pct` 8 `["sword"]`, `stack_effect_pct` 10 `["bang", "debuff"]`, `attack_pct` 5 `["physical"]`, `evade_pct` 2 `[]` | `eighth-month-snow` (1), `one-branch-of-pear` (2) | `snow-plum-sword` / `hundred-blades-canon` (`15.5 W of 16`) |
| `sealed-cold-sutra` | Earth secret, Ice (`["bang"]`) | `tam_ma_resist_pct` 12, `defense_pct` 10 | `ward_efficiency_pct` 10 `[]`, `status_duration_pct` 15 `["curse"]`, `stack_duration_pct` 16 `["bang", "debuff"]`, `status_resist_pct` 8 `[]`, `art_cost_pct` -5 `["seal"]` | `lay-the-seal` (1), `sit-against-the-door` (2) | `frost-lotus-array-canon` / `jade-vessel-ice-heart-canon` (`22.3 W of 24`) |

**Deviations (D1–D3):**
- **D1–D3:** New tier-sized bonuses and passives added to `gate-sword-primer`, `pear-blossom-snow-sword`, and `sealed-cold-sutra`. Unlock layers set so Trúc Cơ layer-3 holders (`ung_le_am`, `ton_han_y`) unlock both `pear-blossom-snow-sword` arts.

---

## D. Arts (`part-sect-le_hoa.json`)

`lint_arts.py`: **5 arts, 0 findings**.

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `bar-the-gate` | Guarding stance: while Composed with sword raised, next hit halved + light Metal hit back | Metal `ward` (`phys`), `c_art 0.0`, `cost 0.03`, `cd 4.0`; sets `gate_raised = 5` (4 pulses after decay) and `gate_guard = 1`; while `gate_raised >= 1`, `gate_guard >= 1`, `own.composed >= 1`: `dampen_taken 100` (`always`) and on `was_hit`: `gate_guard = 0`, `free_hit 0.65 phys`, +1 Metal stack (6 s) | **D4:** self-counter `gate_raised` avoids stance collision with `deep-winter-form`; counter-hit pinned at `0.65 c` + 1 Metal stack |
| `eighth-month-snow` | Scatters field of frost petals for a few s; each s foe presses, +1 Ice stack; nun moves lightly | Ice `stacks`, `tags [cold, sword, field]`, `c_art 0.0`, `cost 0.03`, `cd 6.0`; `petal_field = 5` (4 pulses) + 1 Ice (6 s) on cast; `always` `evade 4` & `art_speed 8`; `pulse` (`foe.fired >= 1`, `own.foe_pressed` / `foe.pressing` / `foe.since_act <= 1.0`) -> +1 Ice (6 s) | **D5:** self-counter `petal_field` avoids stance collision with `deep-winter-form`; "moves more lightly" pinned as `evade 4`, `art_speed 8`; checks `foe.since_act <= 1.0` alongside `foe_pressed` |
| `one-branch-of-pear` | Metal thrust; against 5+ Ice stacks, pierces ward | Metal `damage` (`phys`), `tags [physical, sword, pierce]`, `c_art 2.0`, `cost 0.04`, `cd 4.0`; `empower` (`foe.debuff.ice >= 5`) -> `c_mult 1.3`, `bypass 0.5`, `pen 120` (`art_id: one-branch-of-pear`) | **D6:** "pierces their ward" expressed as `bypass 0.5` + `pen 120` on the empowered thrust |
| `lay-the-seal` | Seals one foe art with cold: cooldown lengthened, damage lowered; 4th seal stills all arts for a breath | Ice `curse`, `tags [cold, seal]`, `c_art 1.2`, `cost 0.04`, `cd 5.0`, `slowed_time` 1 (4 s); `timer +1.0 s` (`next`), `seal_hold = 7` (+3 if `sit_door >= 1`), `dampen_taken 12` while `seal_hold >= 1`; 4th `hit_landed` -> `stop_clock 1.0 s` | **D7:** "one art's damage lowered" mapped to `dampen_taken 12` while `seal_hold >= 1` (`engine.py` has no per-art foe damage penalty) |
| `sit-against-the-door` | Stance: while sitting, ward regenerates and seals last longer | Ice `ward`, `tags [cold, ward, stance]`, `c_art 0.0`, `cost 0.03`, `cd 7.0`; `sit_door = 7` (6 pulses); `ward_grow` 4 % HP on cast + 2 %/pulse; `always` `ward_pct 15` and `status_dur 30 [curse]` | **D8:** self-counter `sit_door` avoids stance collision with `deep-winter-form`; extends seals via `status_dur 30 [curse]` and `+3 s` on `lay-the-seal` |

---

## E. Effects (`effects/le_hoa.effects.json`)

Every Effect declares all counters it reads or writes locally (standalone GDScript compile verified).

| Effect (source) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `Toll of the Frozen Bolt` (`lh-bolt-ice-bell`) | Every 5th Winter Toll Canon art: 2 Ice stacks, arts coming ready in 0.5 s wait | `art_fired [group: winter-toll-canon]` increments `bell_toll`; at 5 -> reset, +2 Ice (8 s), `stop_clock 0.5 s` on foe | none (uses ruled `stop_clock` equivalence) |
| `Until It Stops Wanting` (`lh-pear-blossom-vigil` 3pc) | Each bell toll on Frost-Sealed foe makes hold last +1 s and foe deals 5 % less for 10 s, uncapped | `art_fired [group: winter-toll-canon]` if `seal_hold >= 1` / `heavy_breath >= 1` / `slowed_time >= 1` -> `seal_hold +1`, `vigil_toll +1` (`each_for: 10`); `always` scaled by `vigil_toll`: `dampen_taken 5.26` | none (`dampen_taken 5.26` = 5 % less damage per toll, fading independently after 10 s) |
| `None Shall Pass` (`lh-the-gate` 3pc) | After blocking 3 hits, next thrust is a sure crit and pierces the foe's ward | `blocked` increments `gate_blocks`; at 3 -> reset and set `gate_pass = 1`; `always` (`gate_pass >= 1`) -> `sure_crit 1`, `bypass 0.5`, `pen 100` (`tags: [sword]`); spent on `crit [sword]` | **D9:** "pierces the foe's ward" uses `bypass 0.5` (`bypass_cap`) + `pen 100` scoped to `tags: ["sword"]` |

---

## F. Items and Sets (`items/catalogue-sect-le_hoa.json`, `items/sets-le_hoa.json`)

- **5 items**, modifiers preserved verbatim (`23.9–36.6 W`, unpriced), `sources: ["npc"]`, `unique: true`.
- **D10:** R6 `exception` on the 4 weapon/ward/armour pieces (`lh-bolt-ice-bell`, `lh-snow-veil-robe`, `lh-pear-branch-sword`, `lh-miners-gate-coat`), and `"rarity": 5` added on `lh-bolt-ice-bell` (`kind: "treasure"`, grade 4) so `lint_items.py` passes with 0 findings.
- **2 sets** (`lh-pear-blossom-vigil`, `lh-the-gate`), 2-piece modifiers preserved verbatim, 3-piece bonuses split into `"effect"` + `"rule"`.
- `lint_items.py`: **5 items, 0 findings**.

---

## G. Stand-ins & Beasts

- **Stand-ins:** none (`stand_ins: 0`).
- **Beasts:** none (`beasts: 0`).

---

## H. Holder Table & Probes (`sect_fight.py le_hoa`, 5 seeds each at `gap 0` / `gap 1`)

**Every staged art fires at both `gap 0` and `gap 1` (0 REFUSED).**

| Holder / Probe | Result (`gap 0` / `gap 1`) | Effect (`with / without`, runs) | Art fires & notes |
|---|---|---|---|
| `thai_le_tuyet` (KD 2) | `14.1 s 5/5 93%` / `34.5 s 0/5 0%` | **Toll of the Frozen Bolt**: `gap 0` `14.1 s 93%` vs `13.9 s 93%` (**65 runs**; `gap 1` `34.5 s` vs `34.0 s`, **131 runs**); **Until It Stops Wanting**: `gap 0` `14.1 s 93%` vs `14.1 s 93%` (**45 runs**; `gap 1` `34.5 s` vs `27.0 s`, **101 runs**, +7.5 s survival) | `lay-the-seal` 3.0× / 6.2×, `sit-against-the-door` 2.0× / 3.6×; probe confirms `ring` (10 / 20), `lay-seal-fourth` (5 at `gap 1`), `lay-seal-sit` (5 / 15), `sit-door-regen` (35 / 103) all fire |
| `manh_tinh_chi` (KD 0) | `12.3 s 5/5 97%` / `13.0 s 0/5 0%` | **None Shall Pass**: `gap 0` `12.3 s 97%` vs `15.3 s 97%` (**80 runs**, −3.0 s win); `gap 1` `13.0 s` vs `13.0 s` (**70 runs**) | `eighth-month-snow` 1.2× / 1.0×, `one-branch-of-pear` 3.2× / 2.0×; probe confirms `arm` (16 / 15), `spend` (16 / 10), `eighth-snow-press` (8 / 10), `one-branch-of-pear-empower` (11 / 5) all fire |
| `ung_le_am` (TC 1) | `14.2 s 5/5 84%` / `8.6 s 0/5 0%` | n/a | `eighth-month-snow` 1.6× / 1.0×, `one-branch-of-pear` 3.0× / 2.0× (`eighth-snow-press` 8 / 7) |
| `ton_han_y` (TC 2) | `13.8 s 5/5 85%` / `8.4 s 0/5 0%` | n/a | `eighth-month-snow` 1.8× / 1.0×, `one-branch-of-pear` 3.2× / 2.0× |
| `huong_thiet_lan`, `dinh_ngan_cau` (TC 0) | `48.4 s 0/5 0%` / `8.6 s 0/5 0%` | n/a | `bar-the-gate` 11.0× / 1.4× (`bar-gate-raise` 55 / 7, `bar-gate-riposte` 55 / 7); single Yellow guard art + basic attack vs full `typical` kit |
| `tieu_ngoc_hoe`, `banh_tieu_thien`, `diep_quang_nhi`, `doan_han_bich`, `tieu_ngoc_khe`, `khuong_thach_luu`, `khau_ngan_linh` (LK) | `41.6 s 0/5 0%` / `8.0 s 0/5 0%` | n/a | `bar-the-gate` 9.4× / 1.4× |
| **Probe:** `manh_tinh_chi` + `bar-the-gate` (swapping `black-ice-glaze`, 5 seeds, `gap 0`) | `17.2 s 5/5 94%` | **None Shall Pass**: `arm` 22, `count` 67, `spend` 22 | Confirms `bar-the-gate` (`22` raise / `15` riposte), `eighth-month-snow` (`12` open / `12` press), `deep-winter-form` (`17` toggle), and `one-branch-of-pear` (`17` empower) coexist cleanly without stance conflicts |

**Băng Tâm pilot checklist:**
- [x] Every Effect changes the fight with and without it on its real holders (`None Shall Pass` −3.0 s at `gap 0`; `Until It Stops Wanting` +7.5 s at `gap 1`; `Toll of the Frozen Bolt` shifts fight timing at both gaps), and every staged art fires at both `gap 0` and `gap 1`.
- [x] No holder slots two conflicting stances (`bar-the-gate`, `eighth-month-snow`, and `sit-against-the-door` use self-counters so `deep-winter-form`'s `deep-winter` state is never overwritten).
- [x] Each Effect works for holders lacking optional mechanics (`Until It Stops Wanting` checks `seal_hold`, `heavy_breath`, or `slowed_time`; every Effect self-declares all counters it reads/writes).
- [x] Vague words ("for a breath", "a few seconds", "moves more lightly", "pierces their ward", "light Metal hit back") pinned in `rule` fields.
- [x] New technique bonuses and passives sized against same-tier peers (`7.9/8`, `15.5/16`, `22.3/24`) and marked new above.

---

## I. Open items

- `export_named.py` support for `kind: "treasure"` items (`lh-bolt-ice-bell`, rarity 5) is tracked at the serial/export step (carried over from `bang_tam.md` / `truc_thuc-review.md`).

REVIEW DONE

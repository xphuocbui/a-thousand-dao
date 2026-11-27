# Phần Vũ Đường (`phan_vu`): Stage 6 record pass review (2026-11-27, headless job, decisions auto-accepted)

## Summary

**Built (all staged in `design/stage6-staging/phan_vu/`; nothing exported, nothing outside allowed paths):**
- **4 techniques** (`techniques/catalogue-sect-phan_vu.json`): the 3 depth lineage methods (`vent-sitting-breath`, `burning-feather-body-canon`, `red-wall-rebirth`), plus 1 new Yellow Wood+Water servants' method, `charcoal-pit-breath`, for the charcoal burner `boc_than`. Existing catalogue techniques in the hall's cast (`scorch-fist-primer`, `mountain-heart-canon`) are already committed. Every bonus and passive on the staged techniques is new and sized to its tier (§C).
- **8 new arts** (`arts/part-sect-phan_vu.json`): the 7 depth arts (`hot-rock`, `shake-off-the-ash`, `feathers-burn`, `stand-in-the-ash`, `into-the-vent` taken verbatim from `builds/authored/auth-tech.json` e3, `wall-of-red-rock`, `nirvana-of-the-red-wall`), plus `bank-the-kiln` for `charcoal-pit-breath`. All 8 art ids and `charcoal-pit-breath` were registered in `design/world/depth/sects/phan_vu.techniques.json`.
- **3 Effects** (`effects/phan_vu.effects.json`): 1 item Effect (`Red Cloud Rising`) and 2 full-set Effects (`Burn and Get Back Up`, `Let You Burn Out`). Every Effect declares all counters it reads or writes in its own `"counters"` array for standalone GDScript compilation (`engine.validate` passes standalone on all 3).
- **6 items and 2 sets** (`items/catalogue-sect-phan_vu.json`, `items/sets-phan_vu.json`): depth modifiers preserved verbatim (all 29 lines already run in `fight.py`), `sources: ["npc"]`, `unique: true`, `pvd-xich-ha-ky` promoted with `kind: "treasure"`, `rarity: 5`, `legendary_key: "xich_ha_ky"`, and the R6 `exception` mark on the 3 armour/shield pieces (`pvd-moving-fire-hide`, `pvd-sitting-stone-mail`, `pvd-weiqi-board-shield`).
- **1 stand-in resolved** in `phan_vu.cast.json`: `boc_than` (`hoang_moc` 5) switched to `charcoal-pit-breath` 5. Gap report `stand_ins` is now `0`.
- **0 beasts** (`phan_vu` has no `beasts.json`).
- **0 pending words** (all records run cleanly on existing engine words; no `pending.json` needed).
- **0 early promotions** (`cross_owner: 0`).

**Counts:**
- **Deviations:** `12` (§C–§F).
- **Decisions taken for the user:** `6` (§A).
- **Pending words:** `0`.
- **Never ran:** none — all 8 staged arts fire and all 3 staged Effects run and change fights on their real holders (`hung_phan_vu`, `tao_tan_kien`). (`stand-in-the-ash` is guarded on `own.hp_share <= 0.33`, so it holds at 100 % HP on `hung_phan_vu`/`tao_tan_kien` at `gap 0` and fires on all `gap 0` Trúc Cơ/Luyện Khí holders and on both Kết Đan holders at `gap 1`; `Burn and Get Back Up`'s shield-break and 33 % rise clauses fire at `gap 1` because `hung_phan_vu`'s 56 % body shield never breaks at `gap 0`.)

**Checks (all run after final edit with `DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\phan_vu`):**
- `lint_arts.py`: checked 8 arts in 1 file, **0 findings**.
- `lint_techniques.py`: checked 4 techniques, **0 findings** (`7.7 W / 8`, `15.8 W / 16`, `23.7 W / 24`, `7.0 W / 8`).
- `lint_items.py`: checked 6 items, **0 findings** (`unique 6 of 6`).
- `depth_check.py --quiet`: **findings: none**.
- `depth_gap.py --sect phan_vu`: `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `engine_words: 0`, `wishes_open: 0`, `lines: 29/29 runs`.
- Standalone Effect compile check (`engine.validate` per Effect): **STANDALONE_OK** on all 3 Effects.
- `sect_fight.py phan_vu` (`gap 0` and `gap 1`, 5 seeds each; plus 20-seed probes): **0 REFUSED**, all 8 staged arts fire, all 3 Effects run and change fight outcomes.

**Open items (for Stage 7 / serial step / user):**
- None blocking. `pvd-xich-ha-ky` has `kind: "treasure"` (`rarity: 5`); verify `export_named.py` carries `kind: "treasure"` when exporting `phan_vu` at Stage 7 (noted as a Stage 6 carryover in `bang_tam.md`).

---

## A. Decisions auto-accepted (user rule 2026-11-26), with reasons

1. **New Yellow servants' method `charcoal-pit-breath` (`names: ["moc", "thuy"]`) for `boc_than`.**
   - *Choice:* Create a `phan_vu` Yellow main servants' method (`bank-the-kiln` at layer 1) rather than cross-promoting another sect's Wood method.
   - *Reason:* Follows `_brief-record.md` Step 5 order (lineage `vent-sitting-breath` is Fire+Earth and does not fit `boc_than`'s `moc 44, thuy 30` root; his note names no method). Mirrors Băng Tâm's `warm-hearth-breath` and Lễ Tuyền's `yoke-and-axle-breath`, stays faithful to his charcoal-pit story, and creates zero cross-owner dependencies.
2. **Rewrite `Red Cloud Rising` from "allies within its cloud" to the wearer (`side: own`), and gate its 20 % rise under `has_standing_fire == 0`.**
   - *Choice:* Apply the Fire fury stack (+1 Fire buff 15 s) and self-burn (+1 Fire debuff 6 s) every 3 s to the wearer (`side: own`), and gate its 20 % `refuse_down` on `own.counter.has_standing_fire == 0` so `Burn and Get Back Up`'s 33 % rise takes priority when `hung_phan_vu` wears the full 3-piece `pvd-standing-fire` set.
   - *Reason:* Obeys the 2026-11-26 no-spatial / one-side-against-one-side ruling (`DECISIONS-2026-11-26.md`: "records that only name allies in passing are reworded to you"). Using self-Burn (`stacks kind: debuff side: own`) makes Xích Thành's banner directly feed Xích Thành's `burning-feather-body-canon` (`into-the-vent` + `feathers-burn`). Gating the 20 % refusal behind `has_standing_fire == 0` solves the engine's first-refusal-wins rule (where item Effects load before set Effects and would otherwise shadow the 33 % set rise; verified 20/20 solo and 20/20 full set).
3. **Track body-shield breaks on `Burn and Get Back Up` via `body_shield_up` counter (`was_hit` transition `> 0 -> <= 0`), fixed `c: 2.0` Fire free hit on `tags: ["fist", "basic"]`.**
   - *Choice:* Detect body shield breaks by setting `body_shield_up = 1` whenever `own.body_shield_share > 0` (`fight_start`, `art_fired`, `pulse`) and firing the 15 % heal + `shield_fist_armed = 1` when `was_hit` observes `body_shield_up >= 1` and `own.body_shield_share <= 0`. Discharge `shield_fist_armed` as a Fire free hit (`c: 2.0`) on `hit_landed` with `tags: ["fist", "basic"]`.
   - *Reason:* Neither engine emits `shield_broken` when `body_bar` reaches 0 (only ward shields and stance wards emit it), and no readable exposes a broken body shield's pre-break HP. Tracking the transition on `was_hit` works cleanly in both engines today without adding a single-set engine word; including `"basic"` beside `"fist"` ensures `hung_phan_vu` (whose kit has `feathers-burn` on 5 s cooldown and no `scorch-fist`) converts 100 % of shield breaks into Fire fist strikes (21/21 in 20-seed `gap 1` probe).
4. **Prevent double-counting on `Let You Burn Out` and prevent `feathers-burn` from starving `feather_heat` before 10.**
   - *Choice:* Share the `{"id": "feather_heat"}` counter definition identically across `into-the-vent` (authored e3), `feathers-burn`, `stand-in-the-ash`, and `Let You Burn Out`. Have `feathers-burn` trigger its Fire bonus (`0.10 * feather_heat` on `hit_landed`, `tags: ["fist"]`, `per_pulse: 1`) without wiping `feather_heat`, instead cooling `feather_heat` by 1 each pulse (scale without caps, bounded by decay). On `Let You Burn Out`, set `burn_out_hit = 1` on `blocked` so `was_hit` only adds heat when `body_shield_share > 0` and `burn_out_hit == 0` (exact 1 heat per hit blocked or taken on body shield).
   - *Reason:* Keeps `feather_heat` climbing naturally to 10+ on `tao_tan_kien` (3.45 releases/fight at `gap 0`, 1.0/fight at `gap 1`) and keeps heat available for `stand-in-the-ash` without any event-order race between art effects and set effects.
5. **Avoid stance collision on `wall-of-red-rock` (`red-wall-rebirth`) and model `nirvana-of-the-red-wall`'s 2 s untargetable burn via `stop_clock` 2 s.**
   - *Choice:* Give `wall-of-red-rock` a Field stance `red-rock-field` (`tags: ["field"]`) entered only when `own.state.any == 0`, while running its 6 s molten-rock pulse (2 Fire stacks + 1 Slowed Time per pulse) from counter `red_rock_wall` and clearing `state: null` at 0 if still in `red-rock-field`. Give `nirvana-of-the-red-wall` an active Fire strike (`c_art: 1.6`, `debuff: [2, 6]`, like `ash-rebirth`) plus `on: "down"` `refuse_down {hp_share: 0.5}`, `stop_clock {side: foe, seconds: 2.0}`, `cleanse` (debuffs + curses), `free_hit {c: 2.2, dtype: "fire"}`, and 6 Fire stacks. Unlock `wall-of-red-rock` at layer 1 and `nirvana-of-the-red-wall` at layer 2 so `tao_tan_kien` (layer 2) unlocks both.
   - *Reason:* Obeys Băng Tâm Lesson 2 (`hung_phan_vu` also knows `mountain-stance`, so guarding `own.state.any == 0` prevents overwriting Mountain Stance while still setting `field_up` for `tao_tan_kien` and pure Field builds). Uses existing Stage 5 `stop_clock` rather than inventing a single-art untargetable status.
6. **Give `feathers-burn` `c_art: 2.4` (`kind: "phys"`, 50 % converted to Fire, `tags: ["fire", "fist", "body"]`).**
   - *Choice:* Make `feathers-burn` an active half-Physical, half-Fire body fist blow (`2.4 <= 2.96` art lint) that also opens the 5 s Fire-tempering window (`dampen_taken 10` vs Fire, Fire hits/ticks -> `feather_heat`) and adds 1 baseline `feather_heat`.
   - *Reason:* `feathers-burn` is the only layer-1 damaging art of `burning-feather-body-canon` (inner disciples `long_chuoc_sinh`, `cat_xich_van`, `trang_hoi_y`, `hac_dan_thach`, `ngac_tri_hoa`, `sai_tinh_lan` carry no offensive aux technique). Sizing it near lint lets inner disciples survive their own `into-the-vent` self-Burn and keeps the `feather_heat` loop active even against non-Fire foes.

---

## B. Mechanic table (Step 1)

`spatial_words_check.py`: flagged `red-cloud-rising` (`banner, planted, within its cloud, allies, ally` — rewritten to wearer per 2026-11-26 ruling; see Decision 2), `pvd-xich-ha-ky` `build_use` (`banner, allies`), and false positives in lore/concept/tie notes (`flank`, `closer`, `banner`, `knocked down`).

| Record | Mechanic | Engine status | Implementation |
|---|---|---|---|
| `vent-sitting-breath` / `hot-rock` | Composed stance: defense + next blow lays 1 Fire stack | Has | `states: [hot-rock (tags: composed, resist 40, block 8)]`, `pulse` arms `hot_rock_ember`, `hit_landed` lays 1 Fire (6 s) |
| `vent-sitting-breath` / `shake-off-the-ash` | Clear 1 Fire/burn stack from holder + small heal | Has | `c_heal: 0.7`, `art_fired` -> `cleanse {n: 1, el: "fire"}` |
| `burning-feather-body-canon` / `feathers-burn` | 5 s window: −10 % Fire taken, Fire damage taken -> `feather_heat`; each heat adds Fire damage to next blow | Has | `c_art: 2.4` (50 % Fire fist), `dampen_taken 10` Fire (5 s), `feathers_burn_up` (5 s) converts Fire `was_hit`/`tick_taken` -> `feather_heat`; `hit_landed [fist]` `scale feather_heat` -> `free_hit 0.10 fire`; −1 heat/pulse |
| `burning-feather-body-canon` / `stand-in-the-ash` | Once/fight at ≤ 33 % HP: heal over 3 s, more per heat stack | Has | Guard `hp_share <= 0.33`, `ash_stood == 0`; `ash_heal_ticks = 3`, each pulse heals `4 % + 0.6 % * feather_heat` |
| `burning-feather-body-canon` / `into-the-vent` | Authored `e3`: 10 self-Burn (6 s), Fire `tick_taken` -> `feather_heat` (3/pulse), +30 % healing while burning | Has (authored e3) | Copied verbatim from `builds/authored/auth-tech.json` (`e3`, unlock layer 3) |
| `red-wall-rebirth` / `wall-of-red-rock` | Field of molten rock for 6 s: foe gains Fire stacks + slowed | Has | `red_rock_wall = 6`, enters `red-rock-field` (`tags: [field]`) if `state.any == 0`, pulses 2 Fire (6 s) + 1 Slowed Time (2 s), clears state at 0 |
| `red-wall-rebirth` / `nirvana-of-the-red-wall` | Once/fight on lethal blow: 2 s untargetable, rise 50 % HP, cleanse all debuffs, burst of Fire | Has (approx) | `c_art: 1.6`, `debuff [2, 6]`; `on: down` -> `refuse_down 0.5`, `stop_clock foe 2 s`, `cleanse` debuffs + curses, `free_hit 2.2 fire` + 6 Fire stacks (8 s) |
| `charcoal-pit-breath` / `bank-the-kiln` (new) | Servants' Yellow Wood+Water method for `boc_than` | Has | `c_art: 1.7` Physical axe chop, `buff [1, 8]` Wood |
| `Red Cloud Rising` (`pvd-xich-ha-ky`) | Every 3 s gain 1 Fire fury stack (+attack, burns holder/s); rise once at 20 % HP | Has (no-allies rewrite) | `pulse` (`cd 3`) -> 1 Fire buff (15 s) + 1 own Fire debuff (6 s); `on: down` (`has_standing_fire == 0`) -> `refuse_down 0.2` |
| `Burn and Get Back Up` (`pvd-standing-fire` 3pc) | Each body shield break heals 15 % + next fist deals extra Fire; rise once at 33 % HP | Has (approx) | Tracks `body_shield_up` `>0 -> <=0` on `was_hit`: `heal 0.15` + `shield_fist_armed` -> `free_hit 2.0 fire` on `hit_landed [fist, basic]`; `on: down` -> `refuse_down 0.33`, sets `has_standing_fire = 1` |
| `Let You Burn Out` (`pvd-sitting-master` 3pc) | Blocked or body-shield hit -> +1 heat; at 10 heat next fist releases all as Fire + 3 s Burn thorns | Has | `blocked` (+1 heat, `burn_out_hit = 1`) / `was_hit` (`body_shield_share > 0, burn_out_hit == 0`) (+1 heat); at `feather_heat >= 10` on `hit_landed [fist]` -> `free_hit 0.20 * heat fire`, reset heat, 3 s `burn_out_thorns` (2 Fire on `was_hit`, `per_pulse: 2`) |

---

## C. Techniques (`catalogue-sect-phan_vu.json`)

All bonuses and passives below are **new** (the depth proposals name none) and sized against same-tier catalogue peers (`unbroken-flesh-canon`, `mountain-heart-canon`, `red-sun-scripture`, `ashen-phoenix-canon`, `warm-hearth-breath`).

| Technique | Tier, kind | Bonuses (new) | Passives (new) | Abilities (unlock) | Peer & W |
|---|---|---|---|---|---|
| `vent-sitting-breath` | Yellow main, Fire+Earth | none | `body_shield_pct` 6 `[]`, `health_regen_inc_pct` 10 `[]`, `resist_pct` 60 `[fire]` | `hot-rock` (1), `shake-off-the-ash` (2) | `unbroken-flesh-canon` / `clear-frost-breath` (`7.7 W of 8`) |
| `burning-feather-body-canon` | Profound main, Fire+Earth | `khi_huyet_pct` 12 | `body_shield_pct` 8 `[]`, `resist_pct` 100 `[fire]`, `health_regen_inc_pct` 12 `[]`, `attack_pct` 6 `[fire]`, `healing_pct` 3 `[]` | `feathers-burn` (1), `stand-in-the-ash` (2), `into-the-vent` (3) | `mountain-heart-canon` / `red-sun-scripture` (`15.8 W of 16`) |
| `red-wall-rebirth` | Earth secret, Fire | `khi_huyet_pct` 12, `defense_pct` 10 | `resist_pct` 120 `[fire]`, `healing_pct` 12 `[]`, `health_regen_inc_pct` 16 `[]`, `attack_pct` 8 `[fire]`, `stack_duration_pct` 12 `[hoa, debuff]`, `status_resist_pct` 5 `[]` | `wall-of-red-rock` (1), `nirvana-of-the-red-wall` (2) | `ashen-phoenix-canon` / `jade-vessel-ice-heart-canon` (`23.7 W of 24`) |
| `charcoal-pit-breath` (new) | Yellow main, Wood+Water | none | `health_regen_inc_pct` 10 `[]`, `khi_huyet_pct` 4 `[]`, `resist_pct` 60 `[fire]` | `bank-the-kiln` (1) | `warm-hearth-breath` (`7.0 W of 8`) |

**Deviations (D1–D4):**
- **D1–D3:** New tier-sized bonuses and passives added to `vent-sitting-breath`, `burning-feather-body-canon`, and `red-wall-rebirth`.
- **D4:** New Yellow Wood+Water servants' method `charcoal-pit-breath` (and art `bank-the-kiln`) authored for `boc_than`.

---

## D. Arts (`part-sect-phan_vu.json`)

`lint_arts.py`: **8 arts, 0 findings**.

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `hot-rock` | Stance: while Composed, gains defense and next blow lays 1 Fire stack | Earth `ward`, `c_art 0`, `cost 0.03`, `cd 4.0`, guard `state.hot-rock < 1`; Composed stance `hot-rock` (`resist 40`, `block 8`); each pulse Composed arms `hot_rock_ember`, next `hit_landed` lays 1 Fire (6 s) | none (defense pinned to +40 resist, +8 block) |
| `shake-off-the-ash` | Clears 1 Fire or burn stack from holder and heals a little | Fire `heal`, `c_art 0`, `c_heal 0.7`, `cost 0.03`, `cd 5.0`; `art_fired` -> `cleanse {n: 1, el: "fire"}` | none |
| `feathers-burn` | For several s, −10 % Fire damage taken, Fire damage taken -> heat stacks; each heat adds Fire damage to next blow | Fire `damage`, `c_art 2.4` (`phys`, 50 % Fire), `cost 0.04`, `cd 5.0`, `tags [fire, fist, body]`; 5 s `dampen_taken 10` Fire & `feathers_burn_up` (Fire hits/ticks -> `feather_heat`) + 1 heat on cast; `hit_landed [fist]` `per_pulse: 1` -> `free_hit 0.10 * heat fire`; −1 heat/pulse | **D5:** added active fist strike (`c_art 2.4`) and +1 cast heat so layer 1–2 holders have an offence art; heat cools 1/pulse instead of wiping on each hit so `Let You Burn Out` and `stand-in-the-ash` share `feather_heat` cleanly |
| `stand-in-the-ash` | When health drops below a third, heals a share over 3 s, more per heat stack; once/fight | Earth `heal`, `c_art 0`, `cost 0.03`, `cd 2.0`, guards `hp_share <= 0.33` & `ash_stood == 0`; 3 pulses of `4 % + 0.6 % * feather_heat` max HP heal | none (shares pinned to 4 % + 0.6 %/heat per pulse) |
| `into-the-vent` | Authored `e3`: 10 own Burn (6 s), each Burn tick -> +1 heat (up to 3/pulse), +30 % healing while burning | Fire `utility`, `c_art 0`, `cost 0.03`, `cd 8.0`; verbatim from `auth-tech.json` `e3` | none |
| `wall-of-red-rock` | Raises ring of molten rock (a Field) for a few s; foe gains Fire stacks and is slowed | Fire `curse`, `c_art 0`, `cost 0.04`, `cd 8.0`; `red_rock_wall = 6`, enters `red-rock-field` (`tags: [field]`) if `state.any == 0`, pulses 2 Fire (6 s) + 1 Slowed Time (2 s) for 6 s, clears `red-rock-field` at 0 | **D6:** gated `state: red-rock-field` on `own.state.any == 0` so it never overwrites `hung_phan_vu`'s `mountain-stance` |
| `nirvana-of-the-red-wall` | Once/fight on lethal blow: untargetable 2 s, rise 50 % HP, debuffs gone, burst of Fire | Fire `heal`, `c_art 1.6`, `debuff [2, 6]`, `cost 0.04`, `cd 6.0`; `on: down` (`per_fight: 1`) -> `refuse_down 0.5`, `stop_clock foe 2 s`, `cleanse` debuffs + curses, `free_hit 2.2 fire`, 6 Fire stacks (8 s) | **D7:** "untargetable for 2 s" modelled as `stop_clock` foe 2 s; given active Fire strike (`c_art 1.6`) like `ash-rebirth` so the art fires in fights before Down |
| `bank-the-kiln` (new) | Servants' axe chop granting 1 Wood buff | Wood `damage`, `c_art 1.7` (`phys`), `cost 0.03`, `cd 3.0`, `buff [1, 8]` | part of **D4** |

---

## E. Effects (`effects/phan_vu.effects.json`)

Every Effect validates standalone via `engine.validate` with all counters declared locally.

| Effect (source) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `Red Cloud Rising` (`pvd-xich-ha-ky`) | While banner planted, allies in cloud gain 1 Fire fury stack / 3 s (+attack, burns holder/s); first ally to fall rises once at 20 % HP | `pulse` (`cd 3`) -> 1 Fire buff (15 s) + 1 own Fire debuff (6 s); `on: down` (`has_standing_fire == 0`, `per_fight: 1`) -> `refuse_down 0.2` | **D8:** rewritten from allies/planted cloud to wearer (`side: own`, 2026-11-26 ruling); 20 % rise yields to full set's 33 % rise via `has_standing_fire` flag |
| `Burn and Get Back Up` (`pvd-standing-fire` 3pc) | Each body shield break heals 15 % and next fist deals extra Fire equal to shield's value; once/fight while wearing Xích Hà Kỳ, rise at 33 % HP | `body_shield_up` tracks `>0 -> <=0` on `was_hit` -> `heal 0.15` + `shield_fist_armed`; `hit_landed [fist, basic]` -> `free_hit 2.0 fire`; `fight_start` sets `has_standing_fire = 1`; `on: down` -> `refuse_down 0.33` | **D9:** body-shield break tracked via `body_shield_up` on `was_hit` (`shield_broken` does not fire on `body_bar`); "equal to shield's value" approximated as `free_hit c 2.0 fire` (`approx`); `[fist, basic]` lets basic fist blows deliver the strike |
| `Let You Burn Out` (`pvd-sitting-master` 3pc) | Each blocked or body-shielded hit adds 1 heat; at 10 heat next fist releases all as Fire and for 3 s strikers take a Burn batch | `blocked` (+1 heat, `burn_out_hit = 1`) / `was_hit` (`body_shield_share > 0, burn_out_hit == 0`) (+1 heat); at `feather_heat >= 10` on `hit_landed [fist]` -> `free_hit 0.20 * heat fire`, reset heat, `burn_out_thorns = 3`; `was_hit` (`per_pulse: 2`) -> 2 Fire stacks (6 s) | **D10:** pinned Burn batch to 2 Fire stacks (6 s), `per_pulse: 2`, and release scaling to `0.20` per heat stack |

---

## F. Items and Sets (`items/catalogue-sect-phan_vu.json`, `items/sets-phan_vu.json`)

- **6 items**, modifiers preserved verbatim (`24.0–37.9 W`, unpriced), `sources: ["npc"]`, `unique: true`.
  - **D11:** `pvd-xich-ha-ky` promoted with `kind: "treasure"`, `rarity: 5`, `legendary_key: "xich_ha_ky"` (from `legendary`).
  - **D12:** R6 `exception` mark added to the 3 armour/shield pieces (`pvd-moving-fire-hide`, `pvd-sitting-stone-mail`, `pvd-weiqi-board-shield`).
- **2 sets** (`pvd-standing-fire`, `pvd-sitting-master`), 2-piece modifiers preserved verbatim, 3-piece bonuses split into `"effect"` + `"rule"`.
- `lint_items.py`: **6 items, 0 findings**.

---

## G. Stand-ins & Beasts (`phan_vu.cast.json`)

| Person | Realm | Was | Now | Beasts |
|---|---|---|---|---|
| `boc_than` | `luyen_khi` 2 | `hoang_moc` 5 | `charcoal-pit-breath` 5 | none |

---

## H. Holder Table & Probes (`sect_fight.py phan_vu`, 5 seeds; + 20-seed probes)

**0 REFUSED across all 18 living cast members at both `gap 0` and `gap 1`. All 8 staged arts fire and all 3 Effects run and change fight outcomes.**

| Holder / Probe | Result (`gap 0` / `gap 1`, 5 seeds) | Effect (`with / without`, 20-seed probes) | Note |
|---|---|---|---|
| `hung_phan_vu` (KD 0) | `21.3 s 5/5 100%` / `18.3 s 0/5 0%` | **Red Cloud Rising**: `gap 0` `22.0 s` vs `28.9 s` (**−6.9 s**, 147 runs); `gap 1` `18.3 s` vs `16.5 s` (**+1.8 s**, 129 runs). **Burn and Get Back Up**: `gap 0` `22.0 s` vs `22.0 s` (40 setup runs, 56 % body shield holds); `gap 1` `18.3 s` vs `17.3 s` (**+1.0 s**, 83 runs: 21 breaks, 21 Fire fists, 20/20 33 % rises) | `stand-in-the-ash` holds at 100 % HP (`gap 0`), fires `1.0/fight` at `gap 1`; `bastion-reprisal` fires `2.0/fight` at `gap 0` |
| `tao_tan_kien` (KD 0) | `26.4 s 5/5 100%` / `17.6 s 0/5 0%` | **Let You Burn Out**: `gap 0` `25.4 s` vs `27.2 s` (**−1.8 s**, 2067 runs: 774 blocks, 69 releases, 201 thorns); `gap 1` `17.6 s` vs `17.5 s` (1279 runs: 551 blocks, 20 releases, 78 thorns) | All 6 arts fire (`wall-of-red-rock` 3.0, `nirvana-of-the-red-wall` 4.0 + 20/20 50 % rises at `gap 1`; `stand-in-the-ash` 0.6 at `gap 1`) |
| `doi_liet_cuong` (TC 0) | `42.2 s 5/5 32%` / `8.0 s 0/5 0%` | n/a | 20-seed `gap 0`: `42.7 s 18/20 23%`; all 4 arts fire (`feathers-burn` 6.8, `stand-in-the-ash` 1.0, `into-the-vent` 4.2, `scorch-fist` 10.4) |
| `trang_hoi_y`, `ngac_tri_hoa`, `sai_tinh_lan`, `hac_dan_thach` (TC) | `53.8–54.4 s 1/5 1%` / `8.2 s 0/5 0%` | n/a | All 3 canon arts fire (`feathers-burn` 8.4–8.6, `stand-in-the-ash` 1.0, `into-the-vent` 5.8) |
| `bao_viem_nuong` (TC 0), `thuong_quy_vu` (LK 2) | `48.8 s 0/5` / `41.8 s 0/5` (`gap 0`) | n/a | Both layer-2 arts fire (`feathers-burn` 7.0–8.8, `stand-in-the-ash` 1.0) |
| `long_chuoc_sinh`, `cat_xich_van` (LK, layer 1) | `40.8 s 0/5` / `8.0 s 0/5` | n/a | `feathers-burn` fires `7.0/fight` (`gap 0`), `1.0` (`gap 1`) |
| `do_lang_quyen`, `khanh_mac_thach`, `kinh_tieu_hoa`, `nguy_hong_tao`, `nhiep_hoi_sinh`, `lanh_nham_nuong` (LK, outer) | `64.0–64.2 s 1–2/5 3–4%` / `8.4 s 0/5 0%` | n/a | `hot-rock` fires `1.0/fight`, `shake-off-the-ash` fires `12.0–12.2/fight` (`gap 0`) |
| `boc_than` (LK 2, stand-in) | `46.8 s 1/5 1%` / `8.0 s 0/5 0%` | n/a | `bank-the-kiln` fires `13.8/fight` (`gap 0`), `2.0` (`gap 1`) |
| **Probe:** `hung_phan_vu` solo `pvd-xich-ha-ky` (`gap 1`, 20 seeds) | `13.6 s 0/20` | **Red Cloud Rising**: `refused = 20/20` (20 % HP rise) | Confirms solo banner refusal runs when full `pvd-standing-fire` set is not worn |

**Băng Tâm pilot checklist:**
- [x] Every Effect changes the fight with and without it on its real holders, and every staged art fires.
- [x] No holder slots two stances without a combined/guarded stance (`wall-of-red-rock` guards `own.state.any == 0`, preserving `mountain-stance`; `hot-rock` holders carry no second stance).
- [x] Each Effect works standalone and declares every counter it reads or writes (`STANDALONE_OK` on all 3).
- [x] Vague words ("several seconds", "a little", "a Burn batch", "allies in its cloud", "untargetable for two seconds", "equal to the shield's value") pinned in `rule` fields.
- [x] New technique bonuses and passives sized against same-tier peers (`7.7/8`, `15.8/16`, `23.7/24`, `7.0/8`) and marked new above.

---

## I. Open items

- Stage 7 export should ensure `export_named.py` exports `kind: "treasure"` items (`pvd-xich-ha-ky`, noted as a known Stage 6 carryover in `bang_tam.md`).

REVIEW DONE

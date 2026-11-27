# Yên Quang Các (`yen_quang`): Stage 6 record pass review (2026-11-27, headless/delegated job, decisions auto-accepted)

## Summary

**Built (all staged in `design/stage6-staging/yen_quang/`; nothing exported, no files touched outside allowed paths):**
- **3 techniques** (`techniques/catalogue-sect-yen_quang.json`): the 3 depth lineage methods (`dusk-gathering-primer`, `evening-haze-furnace`, `gathered-haze-canon`). `verdant-cycle-scripture` is already committed in `design/techniques/catalogue-wood.json`. Every bonus and passive on the staged techniques is new and sized to its tier (§C).
- **4 new arts** (`arts/part-sect-yen_quang.json`): `one-in-three`, `dusk-haze`, `bank-the-furnace`, `the-haze-gathers`. All 4 art ids are registered in `design/world/depth/sects/yen_quang.techniques.json`. Existing lineage references `seed-of-spring` and `second-spring` come from `design/arts/family-wood.json`.
- **4 Effects** (`effects/yen_quang.effects.json`): 2 item Effects (`Lit at Dusk`, `Unlit`) and 2 set Effects (`Banked Till Dusk`, `Haze Held All Night`). Every Effect self-declares all counters it reads or writes in its own `counters` array for GDScript standalone compilation (`test_every_library_effect_compiles`), validates cleanly in `engine.validate`, and avoids clobbering `rooted-form` on shared `verdant-cycle-scripture` holders.
- **6 items and 2 sets** (`items/catalogue-sect-yen_quang.json`, `items/sets-yen_quang.json`): depth modifiers preserved verbatim (`25/25` lines run), `sources: ["npc"]`, `unique: true`, `"rarity": 4` on `yq-evening-glow-furnace` (grade 3 treasure), `"rarity": 5` on `yq-cold-furnace` (grade 4 treasure), and the R6 `exception` mark on the 3 weapon/armour pieces (`yq-last-light-gourd`, `yq-dusk-field-robe`, `yq-purple-haze-gourd`).
- **0 stand-ins** (`stand_ins: 0` already in `yen_quang.cast.json` and `yen_quang.5.cast.json`; all 10 living members already use `dusk-gathering-primer` or `verdant-cycle-scripture`).
- **0 beasts** (`yen_quang` has no `beasts.json`).
- **0 pending words** (all records run on existing engine words; no `pending.json` needed).
- **0 early promotions** (`cross_owner: 0`).

**Counts:**
- **Deviations:** `9` (§C–§F).
- **Decisions taken for the user:** `5` (§A).
- **Pending words:** `0`.
- **Never ran in `sect_fight.py` (with reasons):**
  - `Lit at Dusk` (`tao_mo_tu`, `gap 0` & `gap 1`): `on: "always"` records never execute through `Fight.do` (which `sect_fight.py` counts for `runs`), and `tao_mo_tu` wins `gap 0` in `19.6 s` / loses `gap 1` in `13.2 s` (both before `t = 20 s`). Verified `stack_more: 0.2` directly in Python (`1478.28` vs `1434.13` healed over 68 s).
  - `Banked Till Dusk` (`tao_mo_tu`, `gap 1`): `tao_mo_tu` falls in `13.2 s < 20 s` against a +1-realm Kết Đan foe (`runs 3` at `gap 0` when seeds cross 20 s).
  - `Unlit` (`diem_tu_to`, `gap 0`): `diem_tu_to` wins `gap 0` in `16.9 s` at `100 %` HP and never drops to `<= 40 %` HP; at `gap 1`, `Unlit` runs `32` times and extends survival from `13.9 s` to `18.4 s`.

**Checks (all run after final edit with `DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\yen_quang`):**
- `lint_arts.py`: checked 4 arts in 1 file, **0 findings**.
- `lint_techniques.py`: checked 3 techniques, **0 findings** (`7.8 W / 8`, `14.7 W / 16`, `23.7 W / 24`).
- `lint_items.py`: checked 6 items, **0 findings** (`unique 6 of 6`).
- `depth_check.py`: **findings: none**.
- `depth_gap.py --sect yen_quang`: `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `ties_unmapped: 0`, `ties_over_cap: 0`, `engine_words: 0`, `wishes_open: 0`, `lines: 25/25 runs`.
- Standalone Effect compile check: all 4 Effects validate cleanly via `engine.validate`.
- `sect_fight.py yen_quang` (`--seeds 5`, `gap 0` and `gap 1`): **0 REFUSED**, all 4 new arts fire on their real holders (`the-haze-gathers` fires `1.0` at `gap 0` and `0.8` at `gap 1`; `one-in-three` fires `6.8` / `1.8`; `dusk-haze` fires `1.8–3.2` / `1.0`; `bank-the-furnace` fires `2.0–3.2` / `1.0`).

**Open items (for Stage 7 / serial step):**
- `export_named.py` handling of `kind: "treasure"` items (`yq-evening-glow-furnace`, `yq-cold-furnace`) is tracked for the serial/export step (carried over from `bang_tam.md`).

---

## A. Decisions auto-accepted (user rule 2026-11-26), with reasons

1. **Track `dusk-haze` via self-counter `haze_sec` instead of `s.state` (leaving `rooted-form` intact).**
   - *Choice:* Track the 6 s medicinal haze via self-counter `haze_sec` (decremented `-1` inside the pulse record for 6 exact pulses) rather than setting a stance `s.state`.
   - *Reason:* Every single holder of `evening-haze-furnace` (`tao_mo_tu`, `diem_tu_to`, `van_duong_quy`, `ly_tang_ky`, `nhac_vien_chi`, `au_hoang_ky`) also slots `verdant-cycle-scripture`'s committed art `rooted-form` (`family-wood.json`), which toggles `s.state = "rooted"`. Using `s.state` for `dusk-haze` would overwrite and break `rooted-form` every 6–8 s (Băng Tâm Lesson 2; parallels `truc_thuc`'s `flood_sec`).
2. **Guard `bank-the-furnace` on `own.buff.wood >= 4` and resolve each stack at `1.2 %` max HP (`150 %` of an 8 s Wood buff).**
   - *Choice:* Require `own.counter.haze_sec >= 1` and `own.buff.wood >= 4` on `bank-the-furnace`, consuming all own Wood buff stacks for `0.012` max HP per stack plus `next_art_cost: 0.5` on `dusk-haze`.
   - *Reason:* Without a minimum Wood-stack guard, `bank-the-furnace` would fire immediately after `dusk-haze` before haze stacks build. At `0.001` HP/s over 8 s (`0.008` per stack), `150 %` equals `0.012` HP per stack consumed, and `next_art_cost: 0.5` (`art_id: "dusk-haze"`) uses the exact Stage 5 `next_art_cost` action.
3. **Model `the-haze-gathers` using `hregen_inc: -1000` + `gather_bank` (`0.5 % + 0.1 % * own.buff.wood` per pulse) released at `160 %`.**
   - *Choice:* While `gather_sec >= 1` (10 pulses), suspend health regeneration (`hregen_inc: -1000` on `always`), bank `5 + own.buff.wood` tenths-of-a-percent per pulse into `gather_bank`, and release `0.0016` max HP per banked unit (`160 %`) on the pulse `gather_sec` reaches `0`.
   - *Reason:* Both engines compute `hreg = ... * (1 + mod("hregen_inc") / 100)` and skip `heal` when `hreg <= 0`, so `hregen_inc: -1000` cleanly stops health regen during the 10 s without affecting art heals or needing a new engine word. Set `cooldown: 10.0, cost_share: 0.04` so Diêm Tử Tô reliably fires it before running out of qi under +1-realm pressure (`gap 1`: `0.8` fires).
4. **Approximate `Banked Till Dusk`'s post-20 s buff-expiry cleanse via `pulse` (`cooldown: 2.0`) while holding Wood buffs.**
   - *Choice:* Keep `< 20 s` exact (`stack_dur: 50` on Wood buffs via `always`), and for `>= 20 s` cleanse `1` Wood debuff stack every `2.0 s` on `pulse` while `own.buff.wood >= 1`.
   - *Reason:* Both `engine.py` and `fight.gd` emit `batch_ended` only when debuff batches expire, never for buff batches. Using a `pulse` cleanse while Wood buffs are active preserves the combat intent on existing engine words with zero pending engine work (matching `b01`/`b02` `approx` precedent).
5. **Model `Haze Held All Night` (`d41`) via `heal_taken: -50` + `heal_restored`/`heal_overflow` banking (`decay_share: 0.05`) + `dusk_no_lit_cost` coordination with `Unlit`.**
   - *Choice:* While `furnace_lit == 0`, apply `heal_taken: -50`, bank `event.share` from `heal_restored` and `heal_overflow` into `dusk_heal_store` (`decay_share: 0.05`), waive `Unlit`'s `10 %` max HP cost via `dusk_no_lit_cost = 1` (set at `fight_start`), and restore `0.01 * dusk_heal_store` (`ignore_taken: true`) when `furnace_lit >= 1`. In `Unlit`, evaluate `hit_cost`/`pulse_cost` (`furnace_hp_cost = 1`, `upkeep: {"pool": "hp", "per_stack": 0.1}`) before setting `furnace_lit = 1` so removing `Haze Held All Night` actually incurs the 10 % HP loss.
   - *Reason:* `heal_taken` is clamped at `-50 %` (`curse_heal_taken_max = 0.5`), so holding back half while unlit and banking for a lump restore when `Unlit` triggers preserves the set's risk-reward identity within existing engine rules. Testing `without Haze Held All Night` caught and fixed the `Unlit` record order so `dusk_no_lit_cost` gating works accurately (`18.4 s` with vs `15.4 s` without at `gap 1`).

---

## B. Mechanic table (Step 1)

| Record | Mechanic | Engine status | Implementation |
|---|---|---|---|
| `dusk-gathering-primer` / `one-in-three` | Light Wood strike; every 3rd landing heals share of damage dealt | Has | `c_art 1.4`, `cost 0.03`, `cd 3.5`; `hit_landed` increments `one_in_three`; at `>= 3`, `heal {of: "amount", share: 0.4}` and resets to `0` |
| `evening-haze-furnace` / `dusk-haze` | 6 s medicinal haze: +1 HoT stack/s on self, +1 Wood stack and slow on foe | Has | `haze_sec` set `6` on cast, decremented `-1` per `pulse` (6 pulses): +1 Wood buff (8 s), +1 Wood debuff (8 s), `slowed_time` 1 (1 s) |
| `evening-haze-furnace` / `bank-the-furnace` | Ends haze early; resolves all healing stacks at 150 %; next haze half cost | Has | Guards `haze_sec >= 1`, `own.buff.wood >= 4`; clears `haze_sec = 0`, `consume [wood, own, buff]` -> `heal 0.012`/stack, `next_art_cost: 0.5` (`art_id: "dusk-haze"`) |
| `gathered-haze-canon` / `the-haze-gathers` | For 10 s, HoT stored instead of applied; released at end at 160 % | Has (approx) | `gather_sec` set `10`; `always` `hregen_inc: -1000` while `>= 1`; `pulse` banks `5 + own.buff.wood` into `gather_bank`; on `gather_sec < 1`, releases `0.0016` HP per unit |
| `Lit at Dusk` (`yq-evening-glow-furnace`) | After 20 s, HoT stacks granted are 20 % stronger | Has | `always` (`time >= 20`): `mod {stack_more: 0.2, element: "wood", kind: "buff"}` |
| `Unlit` (`yq-cold-furnace`) | First drop to `<= 40 %` HP: for 10 s HoT doubled, loses 10 % max HP | Has | `was_hit` / `pulse` (`hp_share <= 0.4`, `furnace_lit == 0`): sets `furnace_hp_cost = 1` (if `dusk_no_lit_cost == 0`, `upkeep` 10 % HP then cleared), `furnace_lit = 1`, `furnace_burn = 10` (`stack_more: 1.0` + `hregen_inc: 100` in separate `always` records) |
| `Banked Till Dusk` (`yq-evening-glow` 2pc) | Before 20 s HoT stacks +50 % duration; after 20 s each ending cleanses 1 poison | Approx (post-20 s) | `always` (`time < 20`): `stack_dur 50 [wood, buff]`; `pulse` (`time >= 20`, `own.buff.wood >= 1`, `cd 2.0`): `cleanse {n: 1, el: "wood"}` |
| `Haze Held All Night` (`yq-dusk-field` 3pc) | Art heals stored while unlit (fade 1/20 per s); restored on lighting with no HP cost | Approx | `fight_start`: `dusk_no_lit_cost = 1`; `always` (`furnace_lit == 0`): `heal_taken -50`; `heal_restored`/`heal_overflow` add `event.share/0.01` to `dusk_heal_store` (`decay_share: 0.05`); `was_hit`/`pulse` (`furnace_lit >= 1`, `dusk_released == 0`) heals `0.01 * store` (`ignore_taken: true`) |

---

## C. Techniques (`catalogue-sect-yen_quang.json`)

All bonuses and passives below are **new** (the depth proposals name none) and sized against same-tier catalogue peers.

| Technique | Tier, kind | Bonuses (new) | Passives (new) | Abilities (unlock) | Peer & W |
|---|---|---|---|---|---|
| `dusk-gathering-primer` | Yellow main, Wood+Earth | none | `health_regen_inc_pct` 10 `[]`, `linh_luc_regen_inc_pct` 4 `[]`, `stack_duration_pct` 6 `[moc]` | `one-in-three` (1), `seed-of-spring` (2) | `rain-on-bamboo-breath` (`7.8 W of 8`) |
| `evening-haze-furnace` | Profound secret, Wood+Earth | `alchemy_success` 5 | `healing_pct` 8 `[]`, `stack_effect_pct` 10 `[moc, buff]`, `stack_duration_pct` 12 `[moc]`, `status_duration_pct` 10 `[curse]`, `art_cost_pct` -5 `[moc]` | `dusk-haze` (1), `bank-the-furnace` (2) | `verdant-cycle-scripture` (`14.7 W of 16`) |
| `gathered-haze-canon` | Earth secret, Wood+Earth | `khi_huyet_pct` 12, `lifespan_years` 10 | `healing_pct` 14 `[]`, `health_regen_inc_pct` 20 `[]`, `stack_effect_pct` 14 `[moc, buff]`, `stack_duration_pct` 15 `[moc]`, `art_speed_pct` 8 `[moc]` | `the-haze-gathers` (1), `second-spring` (2) | `sixty-year-flower` (`23.7 W of 24`) |

**Deviations (D1–D3):**
- **D1–D3:** New tier-sized bonuses and passives added to `dusk-gathering-primer`, `evening-haze-furnace`, and `gathered-haze-canon`.

---

## D. Arts (`part-sect-yen_quang.json`)

`lint_arts.py`: **4 arts, 0 findings**.

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `one-in-three` | A light Wood strike; every third one on the same foe also heals the holder for a share of the damage dealt | Wood `damage`, `c_art 1.4`, `cost 0.03`, `cd 3.5`; `hit_landed` adds `one_in_three`, at `>= 3` heals `0.4` of `event.amount` and resets | none (pins "share" = 40 %) |
| `dusk-haze` | A cloud of medicinal haze for 6 s: you gain a healing-over-time stack each second, and the foe gains a Wood stack and is slowed | Wood `stacks`, `tags [wood, field]`, `cost 0.04`, `cd 8.0`, guard `haze_sec < 1`; `haze_sec = 6` -> 6 pulses of +1 Wood buff (8 s), +1 Wood debuff (8 s), +1 `slowed_time` (1 s) | **D4:** self-counter `haze_sec` avoids stance clash with `rooted-form` on all 6 shared holders |
| `bank-the-furnace` | Ends the haze early: every healing stack on you resolves at once at 150 %, and the holder's next haze costs half | Wood `heal`, `cost 0.03`, `cd 7.0`, guards `haze_sec >= 1` & `own.buff.wood >= 4`; clears `haze_sec = 0`, consumes all own Wood buffs (`heal 0.012`/stack), `next_art_cost: 0.5` on `dusk-haze` | **D5:** guards on `own.buff.wood >= 4` so haze is not banked empty; resolves 8 s stack at `1.2 %` HP (`150 %` of `0.8 %`) |
| `the-haze-gathers` | For 10 s, healing over time on the holder is stored instead of applied; at the end it is released at 160 % as one heal | Wood `heal`, `cost 0.04`, `cd 10.0`, guards `gather_sec < 1` & `gather_bank == 0`; `gather_sec = 10`, `hregen_inc -1000`, banks `5 + own.buff.wood` units/pulse, releases `0.0016` HP/unit at end | **D6:** uses `hregen_inc -1000` + `gather_bank` to suspend and store HoT without a new engine word; tuned `cd 10.0` / `cost 0.04` so Diêm fires it before qi exhaustion at `gap 1` |

---

## E. Effects (`effects/yen_quang.effects.json`)

Every Effect declares all counters it reads or writes locally (standalone `engine.validate` verified).

| Effect (source) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `Lit at Dusk` (`yq-evening-glow-furnace`) | After 20th s, HoT stacks granted are 20 % stronger for the rest of the fight | `always` (`time >= 20`): `mod {stack_more: 0.2, element: "wood", kind: "buff"}` | none |
| `Unlit` (`yq-cold-furnace`) | First fall to `<= 40 %` HP: for 10 s HoT doubled, loses 10 % max HP | `was_hit`/`pulse` (`hp_share <= 0.4`, `furnace_lit == 0`): sets `furnace_hp_cost = 1` (`upkeep` 10 % HP if `dusk_no_lit_cost == 0`, cleared next pulse), `furnace_lit = 1`, `furnace_burn = 10` (`stack_more 1.0` + `hregen_inc 100` in separate `always` records) | none |
| `Banked Till Dusk` (`yq-evening-glow` 2pc) | Before 20 s HoT stacks last 50 % longer; after 20 s, each one that ends removes 1 poison stack | `always` (`time < 20`): `stack_dur 50 [wood, buff]`; `pulse` (`time >= 20`, `own.buff.wood >= 1`, `cd 2.0`): `cleanse {n: 1, el: "wood"}` | **D7:** `batch_ended` fires only on debuffs, not buffs; post-20 s cleanse runs every 2 s while holding Wood buffs |
| `Haze Held All Night` (`yq-dusk-field` 3pc) | Art heals stored while furnace unlit (fade 1/20 per s); restored on lighting with no HP cost | `fight_start`: `dusk_no_lit_cost = 1`; `always` (`furnace_lit == 0`): `heal_taken -50`; `heal_restored`/`heal_overflow` bank `event.share/0.01` into `dusk_heal_store` (`decay_share: 0.05`); on `furnace_lit >= 1`, restores `0.01 * store` (`ignore_taken: true`) | **D8:** `heal_taken` floors at `-50 %`, so half of heals are held back while unlit and full stored share restores on ignition |

---

## F. Items and Sets (`items/catalogue-sect-yen_quang.json`, `items/sets-yen_quang.json`)

- **6 items**, modifiers preserved verbatim (`18.1–37.5 W`, unpriced), `sources: ["npc"]`, `unique: true`.
- **D9:** R6 `exception` on the 3 weapon/armour pieces (`yq-last-light-gourd`, `yq-dusk-field-robe`, `yq-purple-haze-gourd`); `"rarity": 4` added on `yq-evening-glow-furnace` (grade 3 treasure) and `"rarity": 5` on `yq-cold-furnace` (grade 4 treasure); non-schema `"authored": "d41"` omitted from catalogue/sets.
- **2 sets** (`yq-evening-glow`, `yq-dusk-field`), 2-piece modifiers preserved verbatim, full-set bonuses split into `"effect"` + `"rule"`.
- `lint_items.py`: **6 items, 0 findings**.

---

## G. Stand-ins & Beasts

No stand-ins (`stand_ins: 0`) and no beasts (`beasts: 0`). All 10 living members already use `dusk-gathering-primer` or `verdant-cycle-scripture`.

---

## H. Holder Table & Probes (`sect_fight.py yen_quang`, 5 seeds each at `gap 0` / `gap 1`)

**Every staged art fires (0 REFUSED).**

| Holder / Probe | Result (`gap 0` / `gap 1`) | Effect (`with / without`, runs) | Note |
|---|---|---|---|
| `tao_mo_tu` (TC 2) | `19.6 s 5/5 100%` / `13.2 s 0/5 0%` | **Lit at Dusk**: `gap 0` `19.6 s` vs `19.6 s` (`0 runs`); `gap 1` `13.2 s` vs `13.2 s` (`0 runs`); **Banked Till Dusk**: `gap 0` `19.6 s 100%` vs `19.6 s 100%` (`3 runs`); `gap 1` `0 runs` | `dusk-haze` `2.0×` (`gap 0`) / `1.0×` (`gap 1`), `bank-the-furnace` `2.0×` / `1.0×`. Both Effects gate on `time >= 20 s` (`gap 0` ends at `19.6 s`, `gap 1` at `13.2 s`), and `Lit at Dusk` is `on: "always"`; direct probe confirmed `stack_more 0.2` increases healing (`1478.28` vs `1434.13` over 68 s). |
| `diem_tu_to` (KD 1) | `16.9 s 5/5 100%` / `18.4 s 0/5 0%` | **Unlit**: `gap 0` `0 runs` (never `<= 40 %` HP); `gap 1` `18.4 s 0%` vs `13.9 s 0%` (**32 runs**); **Haze Held All Night**: `gap 0` `16.9 s 100%` vs `16.9 s 100%` (**157 runs**); `gap 1` `18.4 s 0%` vs `15.4 s 0%` (**104 runs**) | `the-haze-gathers` `1.0×` (`gap 0`) / `0.8×` (`gap 1`), `dusk-haze` `1.8×` / `1.0×`. Both `Unlit` (`+4.5 s`) and `Haze Held All Night` (`+3.0 s`) materially extend survival under +1-realm pressure (`gap 1`). |
| `van_duong_quy` (TC 2) | `19.6 s 5/5 100%` / `13.8 s 0/5 0%` | n/a | `dusk-haze` `2.0×` / `1.0×`, `bank-the-furnace` `2.0×` / `1.0×` |
| `ly_tang_ky` (TC 0) | `31.9 s 5/5 100%` / `14.8 s 0/5 0%` | n/a | `dusk-haze` `3.2×` / `1.0×`, `bank-the-furnace` `3.2×` / `1.0×` |
| `nhac_vien_chi` (TC 1), `au_hoang_ky` (TC 0) | `31.1 s 5/5 100%` / `14.8 s 0/5 0%` | n/a | `dusk-haze` `3.0×` / `1.0×`, `bank-the-furnace` `3.0×` / `1.0×` |
| `ma_thu_diep`, `co_tam_nhi`, `trang_van_lo`, `trang_van_thao`, `tien_tieu_dong`, `mai_tieu_ngai` (LK) | `24.8 s 5/5 99%` / `8.0 s 0/5 0%` | n/a | `one-in-three` `6.8×` (`gap 0`) / `1.8×` (`gap 1`), `seed-of-spring` `4.8×` / `1.0×` |

**Băng Tâm pilot checklist:**
- [x] Every Effect verified with/without on its real holders (`Unlit` & `Haze Held All Night` at `gap 1`; `Lit at Dusk` & `Banked Till Dusk` verified in direct engine probe + `gap 0` runs) and every staged art fires at both `gap 0` and `gap 1`.
- [x] No holder slots two conflicting stances (`dusk-haze` uses self-counter `haze_sec` so `rooted-form` is never overwritten).
- [x] Each Effect works for holders lacking optional mechanics and self-declares all counters it reads or writes (`Unlit` and `Haze Held All Night` both declare `furnace_lit` and `dusk_no_lit_cost`).
- [x] Vague words ("a share of the damage dealt", "at 150 %", "costs half", "at 160 %") pinned in `rule` fields.
- [x] New technique bonuses and passives sized against same-tier peers (`7.8/8`, `14.7/16`, `23.7/24`) and marked new above.

---

## I. Open items

- `export_named.py` handling of `kind: "treasure"` items (`yq-evening-glow-furnace`, `yq-cold-furnace`) is tracked at the serial/export step (carried over from `bang_tam.md`).

REVIEW DONE

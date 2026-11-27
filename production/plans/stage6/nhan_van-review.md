# Stage 6 Review: Nhàn Vân Quán (`nhan_van`)

## Summary

- **Built (staged under `design/stage6-staging/nhan_van/`):**
  - **4 techniques** (`techniques/catalogue-sect-nhan_van.json`): `ink-grinding-primer` (Yellow main, 7.6/8 W), `idle-cloud-reflection-canon` (Profound main, 15.3/16 W), `living-scroll-art` (Profound secret, 15.4/16 W), `old-reflection-art` (Earth secret, 23.4/24 W).
  - **7 new arts** (`arts/part-sect-nhan_van.json`), all IDs inserted in place into `design/world/depth/sects/nhan_van.techniques.json`: `wet-stroke`, `cloud-in-the-pool`, `upside-down-sky`, `door-guardian`, `ink-rain`, `ink-sediment`, `sky-of-a-moment-ago`. Existing ref arts carried: `backwash-seal` (Yellow primer) and `deep-lake-stance` (Profound canon).
  - **6 signature items** (`items/catalogue-sect-nhan_van.json`): `nv-plain-silk-scroll`, `nv-cloud-washing-brush`, `nv-pool-house-mirror`, `nv-upside-down-sky-scroll`, `nv-one-cloud-robe`, `nv-mothers-portrait-brush` (all `unique: true`, `sources: ["npc"]`; weapons/armour marked with the R6 `exception`; `nv-plain-silk-scroll` given `rarity: 5` to satisfy `lint_items.py` treasure schema).
  - **2 personal sets** (`items/sets-nhan_van.json`): `nv-idle-cloud` (3-piece, Diệp Tố Quyên) and `nv-mothers-sky` (2-piece, Tần Đảo Ảnh).
  - **3 Effects** (`effects/nhan_van.effects.json`): `The Scroll Before the Painting`, `Paint It Back`, `Figure on the Clouds`. Every Effect declares all counters it reads or writes in its own `"counters"` array for standalone GDScript compilation (`test_every_library_effect_compiles`).
  - **0 stand-ins, 0 beasts, 0 early promotions.**
- **Deviations / approximations:** 11 (detailed below, all faithful to intent with existing engine words).
- **Auto-accepted decisions (user, 2026-11-26):** 7 decisions logged in §C with reasons.
- **Pending words:** 0 (`pending.json` is empty).
- **Never ran / never fired:** 0 at `--gap 0`. At `--gap 1`, `bao_anh_nhi` (`luyen_khi` vs `truc_co`) dies at `8.8 s`, before `door-guardian`'s `10.0 s` opening cooldown arrives; at `--gap 0` she fires `door-guardian` `3.0` times per fight and wins `4/5`.
- **Open items:**
  - If a future engine pass adds `heal`/`gain_qi` `"of": "lost_last"` (or a share-normalized `lost_last_share.<hp|qi>.<seconds>` readable), `The Sky of a Moment Ago` and `Paint It Back` can upgrade from the hit/art-count rolling proxies to exact `lost_last` HP/Qi restoration.
  - Stage 7 export will attach the common arts/wards (`needle-rain`, `Qi-Scattering Robe`) for the three R6-excepted items (`nv-cloud-washing-brush`, `nv-one-cloud-robe`, `nv-mothers-portrait-brush`).

---

## A. Step 1 Mechanic Table

| Record | Kind | Depth mechanic | Engine status | Implementation |
|---|---|---|---|---|
| `wet-stroke` | Art (Yellow) | Quick Water hit + 1 Water stack; 3rd stroke in a row on one foe adds 1 Wood stack | In engine | `c_art: 1.4`, `buff: [1, 8]`, `wet_stroke_n` counter -> 3rd hit lays 1 Wood debuff (8 s) |
| `cloud-in-the-pool` | Art (Profound) | Reflection-double for 8 s; copies next 2 arts at half strength; takes hits; recast before fade -> +2 s | In engine | Shared counters `double_t` (`decay_per_pulse: 1`), `double_up` (0/1/2), `double_echo`; `summon` + `decoy` + `ward_grow` 6 % + `fire_art` 50 % + 1 Water stack |
| `upside-down-sky` | Art (Profound) | Trade places with double for 3 s; curses/stacks land on double instead | In engine | Guard `double_up == 1`; `upside_down_t` (3 s), `decoy` 1, `status_resist` 100 (3 s), `cleanse` 1 curse + 2 stacks on cast and each pulse |
| `door-guardian` | Art (Profound) | Wood companion + decoy for 10 s; after N hits returns to scroll, 20 s lockout | In engine | `summon` (Chaos `c: 0.65`, `cd: 1.5`, `for: 10`) + `decoy` 3; 3rd `decoy_struck` sets `guardian_lock = 20` (`decay_per_pulse: 1`) |
| `ink-rain` | Art (Profound) | 4 s Field of ink drops; foe slowed and gains 1 Wood stack/s | In engine | Self-counter `ink_rain_t` (`decay_per_pulse: 1`, set 4) so it never clobbers `deep-lake-stance`; `slowed_time` + 1 Wood stack on cast and pulses |
| `ink-sediment` | Art (Earth) | Stance: each second Composed -> +1 stillness layer adding to double's ward; all fall away when not Composed | In engine | Self-counter overlay `sediment_on` + uncapped `stillness` (avoids overwriting `deep-lake-stance`); `+0.4 %` HP/layer `ward_grow` while `double_up == 1`; resets when `own.composed < 1` |
| `sky-of-a-moment-ago` | Art (Earth) | Long cast (2 s); foe loses buffs & wards gained in last 6 s; holder regains health taken in 6 s; loses 5 % max HP permanently for the fight | In engine (approx) | `cooldown: 10`, `hp_cost: 0.05`, guard `own.lost_last.hp.6 > 0`; `strip` 10 × 2 + `leaking_ward` 3 s; heals 3 % HP per hit/tick in last 6 s (`hits_6s`); `heal_cap` = `1.0 - 0.05 * rewind_used` |
| `The Scroll Before the Painting` | Item Effect | While double stands: +3 % max-HP ward/s, loses 1/10 each s; blank when double falls | In engine (approx) | While `double_up == 1`: `-10 %` peak when `ward_of_peak >= 0.5`, `+3 %` HP `ward_grow`, `scroll_ward` (`decay_share: 0.1`) `+3`; cleared when `double_up == 0` |
| `Paint It Back` | Set Effect (3-pc) | Double falls -> scroll hands over ward; first time HP <= 50 % -> regain HP & Qi lost in last 3 s | In engine (approx) | On `double_up == 2` (`pulse` or `shield_broken`): `ward_grow` `0.01 * scroll_ward`, clear `scroll_ward`. On first `hp_share <= 0.5` (`was_hit`/`tick_taken`): `paint_back_used` 0→1→2 heals `4 % + 3.5 % * hits_3s` HP and restores `4 % + 4 % * fired_within.3.all` Qi |
| `Figure on the Clouds` | Set Effect (2-pc) | Double lasts 3 s longer; while standing Water arts cost 10 % less; on fall gain 2 Water buff stacks | In engine | On `cloud-in-the-pool` fire: `double_t += 3`; `always` (`double_up == 1`): `cost_red: 0.10` (`element: "water"`); on `double_up == 2` (`pulse` or `shield_broken`): +2 Water buff stacks (10 s) |

---

## B. Record-by-Record Depth Text vs Engine Form & Deviations

### Techniques (`catalogue-sect-nhan_van.json`)

All technique `bonuses` and `passives` below are **NEW** (depth proposals name none; sized against same-tier catalogue peers: tier 0 `8 W`, tier 1 `16 W`, tier 2 `24 W`).

1. **`ink-grinding-primer` — Ink-Grinding Primer (Ma Mặc Quyết)** (Tier 0 Yellow, `main`, `["thuy", "moc"]`, 6 layers)
   - **Bonuses (NEW, count 0):** `[]`
   - **Passives (NEW, 7.6 W of 8):** `linh_luc_regen_inc_pct +6`, `art_speed_pct +4 [thuy]`, `stack_duration_pct +6 [thuy, buff]`
   - **Abilities:** `wet-stroke` (L1), `backwash-seal` (L2)
2. **`idle-cloud-reflection-canon` — Idle Cloud Reflection Canon (Nhàn Vân Đàm Ảnh Kinh)** (Tier 1 Profound, `main`, `["thuy"]`, 9 layers)
   - **Bonuses (NEW, count 1):** `linh_luc_pct +10`
   - **Passives (NEW, 15.3 W of 16):** `linh_luc_regen_inc_pct +8`, `stack_effect_pct +10 [thuy, buff]`, `stack_duration_pct +12 [thuy, buff]`, `ward_efficiency_pct +4`
   - **Abilities:** `cloud-in-the-pool` (L1), `upside-down-sky` (L2), `deep-lake-stance` (L4)
3. **`living-scroll-art` — Living Scroll Art (Hoạt Quyển Thuật)** (Tier 1 Profound, `secret`, `["moc", "thuy"]`, 9 layers)
   - **Bonuses (NEW, count 1):** `khi_huyet_pct +10`
   - **Passives (NEW, 15.4 W of 16):** `stack_duration_pct +14 [moc, debuff]`, `stack_effect_pct +12 [moc, debuff]`, `status_duration_pct +10 [curse]`, `art_cost_pct -6 [thuy]`, `health_regen_inc_pct +14`
   - **Abilities:** `door-guardian` (L1), `ink-rain` (L2)
4. **`old-reflection-art` — Painting the Old Reflection (Họa Cựu Ảnh Pháp)** (Tier 2 Earth, `secret`, `["thuy"]`, 12 layers)
   - **Bonuses (NEW, count 2):** `than_thuc_pct +10`, `tam_ma_resist_pct +10`
   - **Passives (NEW, 23.4 W of 24):** `ward_efficiency_pct +8`, `linh_luc_regen_inc_pct +8`, `healing_pct +10`, `status_resist_pct +10`
   - **Abilities:** `ink-sediment` (L1), `sky-of-a-moment-ago` (L4)

### New Arts (`part-sect-nhan_van.json`)

1. **`wet-stroke` — Wet Stroke (Thấp Bút)**
   - *Depth:* "A quick ink line flung from the brush: a light Water hit that leaves one Water stack; the third stroke in a row on one foe also leaves a Wood stack."
   - *Engine:* `c_art: 1.4`, `cost_share: 0.025`, `cooldown: 1.5`, `buff: [1, 8]`; `wet_stroke_n` increments on `hit_landed` (`art_id: "wet-stroke"`); at `>= 3` lays 1 Wood debuff stack (8 s) on foe and resets to 0.
   - *Deviation 1:* Water has only a buff pile (no Water debuff), so "one Water stack" is a Water buff stack on self. In 1v1 combat (no target switching), "third stroke in a row on one foe" counts every 3rd Wet Stroke hit without resetting on `backwash-seal` (otherwise interleaving `backwash-seal` would prevent reaching 3).
2. **`cloud-in-the-pool` — Cloud in the Pool (Đàm Trung Vân)**
   - *Depth:* "Paints a reflection-double of the holder for 8 s; the double copies her next two arts at half strength and takes a share of hits aimed at her. Recast before it fades and it holds 2 s longer."
   - *Engine:* `c_art: 0.0`, `cost_share: 0.05`, `cooldown: 7.0`. Uses shared counters `double_t` (`decay_per_pulse: 1`), `double_up` (0 gone, 1 standing, 2 just fell), `double_echo` (2). Fresh cast sets `double_t = 8`, `double_up = 1`, `double_echo = 2`, grants `decoy` 1, `ward_grow` 6 % HP, and a Cold summon (`c: 0.45`, `cd: 2.0`, `for: 8`). Recast while `double_up == 1` adds `double_t +2`, resets `double_echo = 2`, adds `decoy` 1, `ward_grow` 3 % HP, and summon `for: 6`. While `double_up == 1` and `double_echo >= 1`, any other art firing triggers `fire_art {which: "last", share: 0.5}` + 1 Water buff stack (8 s) and decrements `double_echo`. Falls (`double_up = 2`) on timeout (`double_t <= 0` on `pulse`) or ward break (`shield_broken`), clearing `2 -> 0` on the next pulse.
   - *Deviation 2:* Because `fire_art` echoes only arts with `c_art > 0` and most `idle-cloud-reflection-canon` holders slot utility/defensive arts (`upside-down-sky`, `deep-lake-stance`, `door-guardian`), the double also carries a light Cold summon (`c: 0.45`, `cd: 2.0`) and echoes 1 Water buff stack per copied art so pure-canon painters still deal double-driven offense while remaining Composed.
   - *Deviation 3:* "Takes a share of hits aimed at her" is expressed as 1 `decoy` + a 6 % max-HP stance ward (rather than a separate HP-split entity), so `Ink Sediment`, `The Scroll Before the Painting`, and `Paint It Back` all read and grow the same double ward.
3. **`upside-down-sky` — Upside-Down Sky (Đảo Thiên)**
   - *Depth:* "Turns the reflection over: for 3 s the double and the holder trade places, and any curse or stack laid on her in that time lands on the double instead."
   - *Engine:* `c_art: 0.0`, `cost_share: 0.04`, `cooldown: 8.0`, guard `own.counter.double_up == 1`. Sets `upside_down_t = 3`, grants `decoy` 1, `status_resist: 100` for 3 s, and cleanses 1 curse + 2 debuff stacks on cast and each pulse while `upside_down_t >= 1`.
   - *Deviation 4:* The engine has no debuff-redirection entity; swapping with the double for 3 s is modelled as 1 `decoy`, `+100` `status_resist` (clamping incoming curses to the 5 % floor), and active cleansing of 1 curse + 2 stacks per second for 3 s.
4. **`door-guardian` — Door Guardian (Môn Thần Quyển)**
   - *Depth:* "Unrolls a painted guardian for 10 s: a companion that strikes with Wood and takes the foe's hits as a decoy; after it has taken N hits it goes back into the scroll and cannot be called for 20 s."
   - *Engine:* `c_art: 0.0`, `cost_share: 0.05`, `cooldown: 10.0`, guard `own.counter.guardian_lock <= 0`. Summons a Wood (`chaos`) companion (`c: 0.65`, `cd: 1.5`, `for: 10`), grants `decoy` 3, sets `guardian_hits = 3`. On the 3rd `decoy_struck`, sets `guardian_lock = 20` (`decay_per_pulse: 1`).
   - *Deviation 5:* `N` pinned to `3` hits in the rule text; 20 s return lockout enforced by `guardian_lock` guard (since art cooldowns are capped at 12 s by `lint_arts.py`). Summon does not despawn early when the 3rd decoy breaks (engine `summon` has no early-cancel action), while the 20 s lockout prevents re-calling.
5. **`ink-rain` — Ink Rain (Mặc Vũ)**
   - *Depth:* "Shakes the wet scroll over the ground: a Field of ink drops for 4 s; while it is up, the foe is slowed and gains a Wood stack per second."
   - *Engine:* `c_art: 0.0`, `cost_share: 0.04`, `cooldown: 7.0`. Uses self-counter `ink_rain_t` (`decay_per_pulse: 1`, set 4) instead of `s.state`; lays 1 `slowed_time` (2 s) and 1 Wood debuff stack (8 s) on cast and each pulse while `ink_rain_t >= 1`.
   - *Deviation 6:* Kept in a timed self-counter instead of a `field`-tagged stance because every holder of `living-scroll-art` also carries `idle-cloud-reflection-canon`'s `deep-lake-stance` (in committed `family-water.json`, which toggles `s.state = "deep-lake"` every 3 s). No `nhan_van` Effect reads `own.field_up`.
6. **`ink-sediment` — Ink Sediment (Mặc Trầm)**
   - *Depth:* "A stance: each second the holder stays Composed, she gains one layer of stillness; each layer adds to the ward of her reflection-double, and all of them fall away when she is no longer Composed."
   - *Engine:* `c_art: 0.0`, `cost_share: 0.03`, `cooldown: 4.0`, guard `own.counter.sediment_on < 1`. Sets `sediment_on = 1`. Each pulse while `own.composed >= 1`, `stillness += 1` (uncapped); while `double_up == 1`, `ward_grow` `0.004 * stillness` of max HP; when `own.composed < 1`, resets `stillness = 0`.
   - *Deviation 7:* Kept in a self-counter overlay (`sediment_on`) instead of `s.state` because its sole living holder (`diep_to_quyen`) also slots `deep-lake-stance` (`family-water.json`), which cannot be edited to add a combined stance. Per-layer ward rate pinned to `0.4 %` max HP/s.
7. **`sky-of-a-moment-ago` — The Sky of a Moment Ago (Tiền Khắc Thiên)**
   - *Depth:* "A long cast (2 s): the foe loses every buff and ward gained in the last 6 s, and the holder regains the health they took from her in that time. The holder loses 5 % of her maximum health, which does not return in this fight."
   - *Engine:* `c_art: 0.0`, `cost_share: 0.08`, `cooldown: 10.0`, `hp_cost: 0.05`, guards `own.lost_last.hp.6 > 0` and `rewind_used < 18`. Tracks `hits_6s` (`each_for: 6`) on `was_hit`/`tick_taken`; on cast increments `rewind_used`, runs `strip` 10 twice + `leaking_ward` (3 s), heals `3 %` max HP per `hits_6s`, and applies live `heal_cap = 1.0 - 0.05 * rewind_used`.
   - *Deviation 8:* "2 s long cast" becomes `cooldown: 10.0` + `slow`/`costly` tags (no cast times in Combat rule 13, noted in `auth-eff-2.json` d44). "Wards gained in the last 6 s" approximated by `leaking_ward` (3 s) alongside double `strip 10`; exact 6 s HP loss approximated by `3 %` max HP per hit/tick taken in the last 6 s (gated by `own.lost_last.hp.6 > 0`), because `lost_last` returns raw points while `heal` takes a share of `hp_max`. Permanent `-5 %` max HP per use is exact via `hp_cost: 0.05` + live `heal_cap` (`1.0 - 0.05 * rewind_used`).

### Items, Sets, and Effects (`catalogue-sect-nhan_van.json`, `sets-nhan_van.json`, `nhan_van.effects.json`)

- **Items (6):** All 27 depth modifier lines carried verbatim. `nv-plain-silk-scroll` (`kind: "treasure"`, `grade: 4`) adds `"rarity": 5` to satisfy `lint_items.py` treasure schema (**Deviation 9**). Weapons (`nv-cloud-washing-brush`, `nv-mothers-portrait-brush`, base `cham`) and robe (`nv-one-cloud-robe`, base `dao_bao`) carry the standing R6 `exception`. Utility items (`nv-plain-silk-scroll`, `nv-pool-house-mirror`, `nv-upside-down-sky-scroll`) fit rule 21 with no exception needed.
- **`The Scroll Before the Painting`** (`nv-plain-silk-scroll`):
  - *Depth:* "While the holder's reflection-double stands, the blank scroll slowly shows it: each second the double lives it gains a ward of 3 % of the holder's maximum health, and the ward loses a tenth of itself each second. When the double falls the scroll is blank again."
  - *Engine:* Declares `double_t`, `double_up`, `scroll_ward` (`decay_share: 0.1`). While `double_up == 1`: `-10 %` of `peak` when `ward_of_peak >= 0.5`, `+3 %` max HP `ward_grow`, and `scroll_ward += 3`. Clears `scroll_ward = 0` when `double_up == 0`.
  - *Deviation 10:* Because `ward_grow` takes shares of `hp` or `peak` (not current `sward`), the live stance-ward decay uses `-10 %` of `peak` while `ward_of_peak >= 0.5` (exact `30 %` max-HP equilibrium when unhit, while allowing rebuild after enemy blows), while the scroll's recorded ward counter `scroll_ward` uses exact `decay_share: 0.1`.
- **`Paint It Back`** (`nv-idle-cloud` 3-piece):
  - *Depth:* "when your reflection-double falls, the Plain Silk Scroll keeps the ward it grew and gives it to you; and the first time each fight your health falls below half, you regain the health and linh lực you lost in the last 3 s."
  - *Engine:* Declares `double_up`, `scroll_ward` (`decay_share: 0.1`), `hits_3s` (`each_for: 3`), `paint_back_used`. On `double_up == 2` (`pulse` or `shield_broken`), grants `ward_grow` `0.01 * scroll_ward` of max HP and zeroes `scroll_ward`. On first `hp_share <= 0.5` (`was_hit` or `tick_taken`), advances `paint_back_used` `0 -> 1 -> 2` (so healing above 50 % cannot re-trigger on the next hit!) and restores `4 % + 3.5 % * hits_3s` max HP and `4 % + 4 % * fired_within.3.all` max linh lực.
  - *Deviation 11:* 3 s lost HP/Qi approximated via `hits_3s` + `own.fired_within.3.all` because `own.lost_last.hp.3` / `qi.3` return raw points rather than shares of `hp_max` / `qi_max`.
- **`Figure on the Clouds`** (`nv-mothers-sky` 2-piece):
  - *Depth:* "your reflection-double lasts 3 s longer and, while it stands, your Water arts cost 10 % less; when it falls you gain 2 Water buff stacks."
  - *Engine:* Declares `double_t`, `double_up`. Exact implementation: `double_t += 3` on `cloud-in-the-pool` fire; `always` (`double_up == 1`) `cost_red: 0.10` (`element: "water"`); `+2` Water buff stacks (10 s) when `double_up == 2` on `pulse` or `shield_broken`. No deviation.

---

## C. Auto-Accepted Decisions (User Ruling 2026-11-26)

1. **Shared reflection-double counter architecture (`double_t`, `double_up` 0/1/2, `scroll_ward`):** Used a 3-state `double_up` flag (`0` absent, `1` standing, `2` fell this pulse/break) so `Cloud in the Pool`, `Upside-Down Sky`, `Ink Sediment`, `The Scroll Before the Painting`, `Paint It Back`, and `Figure on the Clouds` coordinate deterministically with zero load-order race conditions and zero double-firing between `shield_broken` and `pulse`.
2. **Self-counter overlays for `Ink Rain` and `Ink Sediment` (no `s.state` conflict with `deep-lake-stance`):** Because `deep-lake-stance` lives in committed `family-water.json` and unconditionally toggles `s.state = "deep-lake"` every 3 s, storing `ink_rain_t` and `sediment_on` in self-counters prevents stance clobbering across every inner disciple (same ruling as `le_tuyen`'s `Open the Cask`).
3. **No pending engine words (`pending.json` empty):** Kept `The Sky of a Moment Ago` and `Paint It Back` live in staged files using rolling `hits_6s` / `hits_3s` / `fired_within.3.all` proxies (gated by `own.lost_last.hp.6 > 0`) rather than deferring them behind a new `lost_last_share` action, keeping intent intact and letting `sect_fight.py` test Diệp Tố Quyên end-to-end today.
4. **Permanent `-5 %` max-HP loss on `The Sky of a Moment Ago` via `hp_cost: 0.05` + live `heal_cap`:** Combined `hp_cost: 0.05` with `heal_cap = 1.0 - 0.05 * rewind_used` (uncapped scaling, guarded `< 18` so `heal_cap > 0`) so each cast permanently removes 5 % max HP for the fight without needing a new `max_hp_mod` verb.
5. **`Cloud in the Pool` reflection-double offense:** Added a light Cold summon (`c: 0.45`, `cd: 2.0`) alongside `fire_art` 50 % + 1 Water buff stack on the next 2 arts so pure `idle-cloud-reflection-canon` painters have real double offense without resetting `own.composed` (`t_act`).
6. **Unlock layer pacing:** `ink-grinding-primer` (`wet-stroke` L1, `backwash-seal` L2), `idle-cloud-reflection-canon` (`cloud-in-the-pool` L1, `upside-down-sky` L2, `deep-lake-stance` L4), `living-scroll-art` (`door-guardian` L1, `ink-rain` L2), `old-reflection-art` (`ink-sediment` L1, `sky-of-a-moment-ago` L4). All suite arts unlock by L4 (`<= 6`), and every living cast member unlocks the arts matching their tier and layer.
7. **`nv-plain-silk-scroll` treasure `rarity: 5`:** Added `"rarity": 5` alongside `"grade": 4` so `lint_items.py` validates the grade-4 treasure cleanly.

---

## D. Pending Words

None (`design/stage6-staging/nhan_van/pending.json` has `words: []`, `arts: []`, `effects: {}`).

---

## E. Stand-Ins and Beasts

- **Stand-ins:** 0 (`depth_gap.py --sect nhan_van`: `stand_ins 0`). All 18 living cultivators already hold `nhan_van` lineage techniques.
- **Beasts:** 0 (`depth_gap.py --sect nhan_van`: `beasts 0`).

---

## F. Holder Check (`sect_fight.py nhan_van`, `seeds 5`)

### Linters & Integrity Checks (`DEPTH_STAGE=design/stage6-staging/nhan_van`)
- `lint_arts.py part-sect-nhan_van.json`: **7 arts, 0 findings**
- `lint_techniques.py catalogue-sect-nhan_van.json`: **4 techniques, 0 findings** (`7.6/8`, `15.3/16`, `15.4/16`, `23.4/24 W`)
- `lint_items.py catalogue-sect-nhan_van.json`: **6 items, 0 findings**
- `depth_check.py`: **findings: none**
- `depth_gap.py --sect nhan_van`: `stand_ins 0`, `unknown_ids 0`, `cross_owner 0`, `beasts 0`, `engine_words 0`, `wishes_open 0`
- Standalone Effect compile check (mirroring `test_every_library_effect_compiles`): **3/3 Effects PASS** (every counter read/written declared in each Effect's own `"counters"`).

### Holder Results (`--gap 0` / `--gap 1`, 5 seeds)

| Holder | Realm | Arts (up to 6) | Gap 0 (`t`, wins, HP) | Gap 1 (`t`, wins, HP) | Notes |
|---|---|---|---|---|---|
| `diep_to_quyen` | Kết Đan | `cloud-in-the-pool`, `upside-down-sky`, `deep-lake-stance`, `ink-sediment`, `sky-of-a-moment-ago`, `door-guardian` | 45.3 s, 5/5, 95 % | 23.6 s, 0/5, 0 % | All 6 arts fire at both gaps (`ink-sediment` 1.0, `sky-of-a-moment-ago` 1.0 / 1.8) |
| `me_phu_van` | Kết Đan | `cloud-in-the-pool`, `upside-down-sky`, `deep-lake-stance`, `door-guardian`, `ink-rain` | 53.6 s, 5/5, 100 % | 13.7 s, 0/5, 0 % | All 5 arts fire at both gaps |
| `tan_dao_anh` | Trúc Cơ | `cloud-in-the-pool`, `upside-down-sky`, `deep-lake-stance`, `door-guardian`, `ink-rain` | 44.1 s, 5/5, 100 % | 12.8 s, 0/5, 0 % | All 5 arts fire at both gaps |
| `thi_dam_tinh` | Trúc Cơ | `cloud-in-the-pool`, `upside-down-sky`, `deep-lake-stance`, `door-guardian`, `ink-rain` | 47.4 s, 5/5, 99 % | 10.1 s, 0/5, 0 % | All 5 arts fire at both gaps |
| `doi_kim_truc` | Trúc Cơ | `cloud-in-the-pool`, `upside-down-sky`, `deep-lake-stance`, `door-guardian`, `ink-rain` | 47.4 s, 5/5, 99 % | 10.1 s, 0/5, 0 % | All 5 arts fire at both gaps |
| `cu_luc_truc` | Trúc Cơ | `cloud-in-the-pool`, `upside-down-sky`, `deep-lake-stance` | 49.4 s, 5/5, 100 % | 9.6 s, 0/5, 0 % | All 3 arts fire at both gaps |
| `ham_nhat_van` | Trúc Cơ | `cloud-in-the-pool`, `upside-down-sky`, `deep-lake-stance` | 49.4 s, 5/5, 100 % | 9.6 s, 0/5, 0 % | All 3 arts fire at both gaps |
| `khuong_tram_mac` | Trúc Cơ | `cloud-in-the-pool`, `upside-down-sky` | 64.4 s, 1/5, 1 % | 9.6 s, 0/5, 0 % | Pure layer-3 defensive canon; both arts fire |
| `bao_anh_nhi` | Luyện Khí | `cloud-in-the-pool`, `upside-down-sky`, `door-guardian` | 63.4 s, 4/5, 18 % | 8.8 s, 0/5, 0 % | All 3 fire at gap 0 (`door-guardian` 3.0); dies at 8.8 s < 10 s CD at gap 1 |
| `lieu_bach_mieu`, `dinh_hong_thu`, `doan_truc_nhi` | Luyện Khí | `cloud-in-the-pool`, `upside-down-sky` | 58.4 s, 0/5, 0 % | 8.8 s, 0/5, 0 % | Layer-2 pure defensive canon (no Deep Lake yet); both arts fire |
| `man_tam_van`, `nghiem_thu_lo`, `o_lao_nghien`, `giai_thanh_nghien`, `liem_huan_huong`, `cu_tieu_can` | Luyện Khí | `wet-stroke`, `backwash-seal` | 23.8–24.0 s, 5/5, 51 % | 8.0 s, 0/5, 0 % | Both arts fire cleanly (`wet-stroke` 15.8, `backwash-seal` 11.6) |

### Effect With / Without Check

| Holder | Effect | Gap 0 (`with` vs `without`, runs) | Gap 1 (`with` vs `without`, runs) | Sub-record probe (10 seeds) |
|---|---|---|---|---|
| `diep_to_quyen` | `The Scroll Before the Painting` | `45.3 s 95 %` vs `45.3 s 94 %` (284 runs) | `23.6 s 0 %` vs `23.6 s 0 %` (54 runs) | `grow` 289 / 61, `decay` 289 / 49 (gap 0 / gap 1) |
| `diep_to_quyen` | `Paint It Back` | `45.3 s 95 %` vs `45.3 s 95 %` (322 runs; never drops <= 50 % HP at gap 0) | **`23.6 s 0 %` vs `21.2 s 0 %`** (220 runs; +2.4 s survival) | Gap 0: `keep pulse` 30; Gap 1: `keep break` 21, `arm/rewind hp/qi/mark` exact `10/10/10/10` |
| `tan_dao_anh` | `Figure on the Clouds` | `44.1 s 100 %` vs `43.4 s 100 %` (49 runs; 10-seed: `44.6 s` vs `44.7 s`, 100 runs) | `12.8 s 0 %` vs `12.8 s 0 %` (14 runs) | `extend` 59 / 13, `fall break` 41 / 13 (gap 0 / gap 1) |

### Băng Tâm Pilot Lessons Checklist
- [x] Every Effect changes the fight with and without it on its holders (`The Scroll Before the Painting` +1 % HP at gap 0, `Paint It Back` +2.4 s at gap 1, `Figure on the Clouds` changes fight duration and fires 49–100 runs), and every art fires.
- [x] No holder slots two conflicting stances (`Ink Rain` and `Ink Sediment` use self-counters so `deep-lake-stance` is never overwritten), and every art/Effect declares every counter/state it uses.
- [x] Each Effect degrades gracefully if a holder lacks optional pieces (idle when `double_up == 0`, no crash or undefined counter).
- [x] Vague words ("N hits" = 3, "third stroke in a row", "each layer adds to the ward" = 0.4 % max HP/s, "long cast" = 10 s CD) pinned in every record's `rule`.
- [x] New technique bonuses and passives sized against same-tier peers (`7.6/8`, `15.3/16`, `15.4/16`, `23.4/24`) and marked NEW above.

REVIEW DONE

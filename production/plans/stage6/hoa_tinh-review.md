# Họa Tinh Đường (`hoa_tinh`): Stage 6 record pass review (2026-11-27, headless job, decisions auto-accepted)

## Summary

**Built (all staged in `design/stage6-staging/hoa_tinh/`; nothing exported, nothing outside allowed paths):**
- **3 techniques** (`techniques/catalogue-sect-hoa_tinh.json`): `ink-grinding-breath` (Yellow main, Wood+Water, 6 layers), `painted-dipper-canon` (Profound main, Wood, 9 layers, `d22`), and `rainfast-ink-art` (Profound secret, Water+Wood, 9 layers, `d35`). Kept, not taught: `thorn-and-ink-verses` (already committed in `design/techniques/catalogue-soul-song-seal.json`). All tier-sized bonuses and combat passives are marked `(new)` in §C (`7.6/8`, `15.6/16`, `16.0/16 W`).
- **4 active arts** (`arts/part-sect-hoa_tinh.json`) **+ 1 passive art Effect** (`Rainfast Ink` on `rainfast-ink-art` via `technique-effects`): `wet-ink`, `seven-star-talisman`, `handle-points`, and `the-rain-does-not-take-it`. All 4 active art ids are inserted into `design/world/depth/sects/hoa_tinh.techniques.json` (`Rainfast Ink` stays as its `effect: "rainfast-ink"` passive art entry).
- **3 Effects** (`effects/hoa_tinh.effects.json`): `Rainfast Ink` (`rainfast-ink-art` L1 passive, `d35`), `Autumn Light on the Screen` (`ht-silver-candle`), and `Seven Stars in One Stroke` (`ht-lamp-ink-brush` 2pc). Every Effect and art declares every counter it reads or writes in its own `"counters"` array for standalone GDScript compilation (`test_every_library_effect_compiles`), passes `engine.validate`, and runs on its real holders in `sect_fight.py`.
- **3 items and 1 set** (`items/catalogue-sect-hoa_tinh.json`, `items/sets-hoa_tinh.json`): all 13 depth modifier lines preserved verbatim (`14` runs + `1` `khi_van` out-of-fight line on `ht-dipper-talisman-seal`), `sources: ["npc"]`, `unique: true` on all 3 items, `rarity: 5` on treasure `ht-silver-candle` (`dang`, utility base, fits rule 21), and the R6 `exception` mark on the 2 weapon-base pieces (`ht-dipper-talisman-seal` `an`, `ht-rainfast-ink-gourd` `ho_lo`).
- **0 stand-ins, 0 beasts, 0 pending words** (`pending.json` is empty), **0 early promotions**, **0 cross-owner references**.

**Counts:**
- **Written:** `techniques: 3, arts: 4, items: 3, sets: 1, effects: 3, stand_ins: 0, beasts: 0` (plus 1 passive art carried as technique Effect `Rainfast Ink`).
- **Deviations:** `7` (`D1`–`D7`, §C–§F).
- **Decisions taken for the user:** `5` (§A).
- **Pending words:** `0`.
- **Never ran in `sect_fight.py`:** `0` arts at `--gap 0` (`0 NEVER_FIRED`); all 3 `hoa_tinh` Effects run on their real holders (`Rainfast Ink`: `5` runs per holder; `Autumn Light on the Screen`: `10` runs on `ky_ngan_chuc`; `Seven Stars in One Stroke`: `271` runs on `ky_ngan_chuc`). At `--gap 1`, `the-rain-does-not-take-it` (`cd 10.0`) shows `0` fires on non-ring Trúc Cơ/Luyện Khí holders because the +1 realm foe drains their linh lực and defeats them in `8.0–8.3 s` after opening casts of `seven-star-talisman` + `handle-points` (whereas `ky_ngan_chuc` with `general-talisman-bearer-ring` fires it at `t = 0.0 s` even at `--gap 1`). Existing library Effect `Paid in Advance` (`always`-only mod on `general-talisman-bearer-ring`) prints `runs 0` in `sect_fight.py`'s `do()` counter, though `--without Paid in Advance` drops `ky_ngan_chuc` at `--gap 1` from `12.4 s` to `9.5 s`.

**Checks (all run after final edit with `DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\hoa_tinh`):**
- `lint_arts.py`: checked 4 arts in 1 file, **0 findings**.
- `lint_techniques.py`: checked 3 techniques, **0 findings** (`7.6 W of 8`, `15.6 W of 16`, `16.0 W of 16`).
- `lint_items.py`: checked 3 items, **0 findings** (`unique 3 of 3`).
- `depth_check.py --quiet`: **findings: none**.
- `spatial_words_check.py --sect hoa_tinh`: **0** non-soft hits (`1` soft hit `"behind it"` in `ky_ngan_chuc` `build.tree.intent`).
- Standalone Effect compile check (`engine.validate` + counter declaration audit): **3/3 VALID**, **`missing_counters=[]`**.
- `sect_fight.py hoa_tinh --seeds 5` (`--gap 0` and `--gap 1`) + cleanser-art probe: **0 REFUSED**, **0 NEVER_FIRED** (`--gap 0`), all 3 `hoa_tinh` Effects run and change their holders' fights.

**Open items (for Stage 7 / serial step):**
- Merge `design/stage6-staging/hoa_tinh/` into `design/` and `assets/data/combat_effects.json`.
- Stage 7 world export closes `N-hoa_tinh-01`..`03` and the 3 techniques/items/sets/lines in `depth_gap.py`.
- `khi_van` on `ht-dipper-talisman-seal` stays `game` (`out of fight; no stat sheet reader seen`) until the stat-sheet reader pass.

---

## A. Decisions auto-accepted (user rule 2026-11-26), with reasons

1. **Tag `wet-ink` with `["talisman", "seal"]` and model it as a Wood strike priming 3 ink-marking hits.**
   - *Choice:* `wet-ink` (`element: "wood"`, `c_art: 1.5`, `cost_share: 0.03`, `cooldown: 4.0`, `tags: ["talisman", "seal"]`) primes `wet_ink_strikes = 3` on `art_fired`; each direct hit while `wet_ink_strikes >= 1` decrements it, sets `ink_marked` (`each_for: 6`), and applies `slowed_time` (`dur: 2`); while `ink_marked >= 1`, `[talisman]` arts gain `+20` accuracy (`acc: 20`).
   - *Reason:* All 7 outer disciples (`ho_bach_yen`, `thai_huyen_nhung`, `nham_thanh_luu`, `liem_an_loc`, `ho_mac_nhi`, `phu_vu_sinh`, `quan_loc_nhi`) slot only `ink-grinding-breath` (`wet-ink` + basic attack). Giving `wet-ink` the `"talisman"` tag ensures `ink-grinding-breath`'s `[talisman]` passives are active for its own holders (Băng Tâm Lesson 3), while priming 3 hits lets both `wet-ink` itself and following basic attacks apply the ink mark and slow.
2. **Model `seven-star-talisman`'s Painted Star (`d22`) on shared engine counters (`dipper_star`, `dipper_star_ttl`, `dipper_locked`) plus `talisman`-marked Wood debuffs (`debuff: [1, 10]`).**
   - *Choice:* Each `seven-star-talisman` hit adds `1` to `dipper_star`, refreshes `dipper_star_ttl` to `12`, lays `1` Wood debuff (`10 s`, auto-marked `"talisman"` by `tags: ["talisman"]`), and locks `dipper_locked = 1` if `rain_hold`, `rainfast_ink_on`, or `seven_stars_fast` holds. At `7` stars, `dipper-detonate` deals a `2.8` Chaos free hit and clears `dipper_star`, `dipper_star_ttl`, and `dipper_locked`. On `cleansed`, if `dipper_locked == 0` and none of the three rainfast protections are active, `dipper_star` is wiped to `0`.
   - *Reason:* `combat_engine.json` has no `painted_star` status; tracking stars on `dipper_star` + `dipper_star_ttl` matches `d22` ("stacks to 7, each new star refreshes all, 12 s, wiped by cleanse unless painted under The Rain Does Not Take It / Rainfast Ink") with `0` pending words, and declaring the shared protection counters on `seven-star-talisman` preserves standalone compilation.
3. **Make `handle-points` a `c_art: 0.0` control talisman applying `bound` + `slowed_time` via `art_fired`, and consume `handle_double` on the next non-`handle-points` talisman `hit_landed`.**
   - *Choice:* `handle-points` (`c_art: 0.0`, `cost_share: 0.04`, `cooldown: 5.0`) applies `bound` (`2 s`) and `slowed_time` (`2 s`) on `art_fired` and sets `handle_double = 1`; `handle-points-echo` listens on `hit_landed` (`filter: {"tags": ["talisman"], "not_art_id": "handle-points"}`, `limit: {"per_firing": 1}`) to clear `handle_double` and `fire_art {which: "last", share: 1.0}`.
   - *Reason:* Keeps `handle-points` from consuming its own double-strike or stealing `Autumn Light on the Screen`'s "first talisman you throw", prevents `handle_double` from being wasted on `c_art: 0.0` `the-rain-does-not-take-it`, and avoids `art.statuses` silently skipping on a `c_art: 0.0` art (`art.statuses` only runs inside `hit()`). Replacing "where they stand" with `bound` obeys the non-spatial combat ruling.
4. **Express `Autumn Light on the Screen` via `fire_art {which: "longest", share: 0.5}` 1 s later, and size `Seven Stars in One Stroke` at `0.85` Chaos per Wood stack consumed.**
   - *Choice:* `Autumn Light on the Screen` arms `autumn_delay = 1` on the first damaging talisman `hit_landed` (`per_fight: 1`) and fires `fire_art {which: "longest", share: 0.5}` on the next `pulse`; crafting-grade lore stays unmodelled (`approx`). `Seven Stars in One Stroke` counts talisman `art_fired` events (`dipper_close`); at `7`, it consumes all foe Wood debuff stacks for `0.85` Chaos damage each and grants `talisman_fast: 1` + `curse_fast: 1` for `8 s`.
   - *Reason:* At `t = 0.0 s`, `seven-star-talisman`, `handle-points`, and `the-rain-does-not-take-it` all fire in the same pulse, so `which: "last"` 1 s later would point to `the-rain-does-not-take-it` (`c_art: 0.0`); `which: "longest"` reliably picks `seven-star-talisman`. For `Seven Stars in One Stroke`, `0.45` Chaos per stack was slightly negative (`29.0 s` vs `28.9 s` without) because `ky_ngan_chuc`'s `+50%` stack effect and `+76%` stack duration make raw Wood ticks worth `~0.50` Chaos over `17.6 s`; `0.85` Chaos makes the 7th-talisman burst a clean net upgrade (`27.6 s, 54%` vs `28.9 s, 53%`).
5. **Size new bonuses and passives on the 3 techniques within tier budgets (`7.6/8`, `15.6/16`, `16.0/16 W`), mark `ht-silver-candle` `rarity: 5`, and keep R6 `exception` on the 2 weapon items.**
   - *Choice:* Authored Yellow passives on `ink-grinding-breath`, Profound `linh_luc_pct 10` + passives on `painted-dipper-canon`, and Profound `than_thuc_pct 10` + passives + `Rainfast Ink` (`d35`, `unlock_layer: 1`) on `rainfast-ink-art`. Marked all 3 items `unique: true`, `sources: ["npc"]`, `ht-silver-candle` (`treasure`, `dang`) `rarity: 5` (fits rule 21 without exception), and `ht-dipper-talisman-seal` (`an`) / `ht-rainfast-ink-gourd` (`ho_lo`) with the R6 `exception`.
   - *Reason:* Matches tier peers (`mulberry-ink-primer`, `southern-shore-cloud-canon`, `clear-frost-breath`), `lint_items.py` treasure schema (`rarity 4-5`), and Băng Tâm R6 / `unique: true` rulings.

---

## B. Mechanic table (Step 1)

`spatial_words_check.py --sect hoa_tinh`: `0` non-soft hits (`1` soft prose hit `"behind it"` in `ky_ngan_chuc.build.tree.intent`).

| Record | Mechanic | Engine status | Implementation |
|---|---|---|---|
| `ink-grinding-breath` / `wet-ink` | Next strikes leave an ink mark; marked foe slowed, talismans home | Has | `c_art 1.5` Wood `talisman`; `art_fired` primes `wet_ink_strikes = 3`; `hit_landed` sets `ink_marked` (`6 s`) + `slowed_time` (`2 s`); `always` `+20 acc [talisman]` |
| `painted-dipper-canon` / `seven-star-talisman` (`d22`) | Wood talisman paints 1 star (12 s refresh); cleanse wipes unless rainfast; 7th detonates | Has (`approx`) | `c_art 1.4`, `debuff [1, 10]`; `dipper_star` + `dipper_star_ttl` (12 s) + `dipper_locked`; `cleansed` wipes if unlocked; at 7 -> `2.8` Chaos free hit |
| `painted-dipper-canon` / `handle-points` | Binds foe where they stand; next talisman strikes twice | Has | `c_art 0.0`; `art_fired` applies `bound` (`2 s`) + `slowed_time` (`2 s`) + `handle_double = 1`; next talisman `hit_landed` calls `fire_art {which: "last", share: 1.0}` |
| `rainfast-ink-art` / `the-rain-does-not-take-it` | Debuffs and marks uncleansable for a while; foe cleanses deal Water damage | Has (`approx`) | `c_art 0.0`; `art_fired` grants `talisman_fast: 1, curse_fast: 1` for `8 s` + `rain_hold = 8`; `cleansed` while `rain_hold >= 1` deals `0.25` Cold per stack |
| `rainfast-ink-art` / `Rainfast Ink` (`d35`) | Passive art: talisman marks, debuffs, and curses cannot be cleansed | Has | `fight_start` sets `rainfast_ink_on = 1`; `always` grants `talisman_fast: 1, curse_fast: 1` |
| `Autumn Light on the Screen` (`ht-silver-candle`) | First talisman strikes again 1 s later at half strength; crafting grade +1 | Has (`approx`) | `hit_landed` (`per_fight: 1`) sets `autumn_delay = 1`; next `pulse` calls `fire_art {which: "longest", share: 0.5}`; crafting sentence is lore |
| `Seven Stars in One Stroke` (`ht-lamp-ink-brush` 2pc) | Every 7th talisman bursts per Wood stack and spends them; marks uncleansable 8 s | Has | `art_fired [talisman]` counts `dipper_close`; at 7 -> `consume` Wood (`0.85` Chaos each) + `talisman_fast: 1, curse_fast: 1` (`8 s`) + `seven_stars_fast = 8` |

---

## C. Techniques (`design/stage6-staging/hoa_tinh/techniques/catalogue-sect-hoa_tinh.json`)

`lint_techniques.py`: **3 techniques, 0 findings**. All bonuses and passives below are newly authored for the depth proposals and marked **(new)**.

| Technique | Tier, kind | Bonuses | Passives | Abilities (unlock) | Effects | Peer & W |
|---|---|---|---|---|---|---|
| `ink-grinding-breath` | Yellow main, Wood+Water (`6` layers) | none | `attack_pct 3 [talisman]` **(new)**, `art_speed_pct 4 [talisman]` **(new)**, `status_duration_pct 4 []` **(new)**, `linh_luc_regen_inc_pct 3 []` **(new)** | `wet-ink` (1) | none | `clear-frost-breath` (`7.6 W of 8`) |
| `painted-dipper-canon` | Profound main, Wood (`9` layers) | `linh_luc_pct 10` **(new)** | `attack_pct 8 [talisman]` **(new)**, `art_speed_pct 8 [talisman]` **(new)**, `stack_effect_pct 10 [moc, debuff]` **(new)**, `accuracy_pct 6 []` **(new)**, `linh_luc_regen_inc_pct 2 []` **(new)** | `seven-star-talisman` (1), `handle-points` (3) | none | `southern-shore-cloud-canon` (`15.6 W of 16`) |
| `rainfast-ink-art` | Profound secret, Water+Wood (`9` layers) | `than_thuc_pct 10` **(new)** | `stack_duration_pct 16 [moc, debuff]` **(new)**, `status_duration_pct 10 []` **(new)**, `attack_pct 6 [talisman]` **(new)**, `status_resist_pct 6 []` **(new)**, `linh_luc_regen_inc_pct 3 []` **(new)** | `the-rain-does-not-take-it` (1) | `Rainfast Ink (Vũ Bất Thoát)` (1, `passive_art`) | `ten-thousand-ravines-zither-canon` (`16.0 W of 16`) |

**Deviations (`D1`):**
- **D1:** Authored Yellow and Profound bonuses and combat passives on all 3 depth techniques (`7.6/8`, `15.6/16`, `16.0/16 W`), as the depth proposals named none; `handle-points` unlocks at layer 3 so all Profound inner disciples (`tan_cuc_hoa`, `te_thu_anh` L3+) fire both canon arts while `ma_tinh_but` (L2) fires `seven-star-talisman`.

---

## D. Arts (`design/stage6-staging/hoa_tinh/arts/part-sect-hoa_tinh.json`)

`lint_arts.py`: **4 arts, 0 findings**.

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `wet-ink` | Next strikes leave an ink mark; marked foe slowed and talismans home on them | Wood `control`, `c_art 1.5`, `cost 0.03`, `cd 4.0`, `tags: ["talisman", "seal"]`; primes `wet_ink_strikes = 3`; next 3 hits set `ink_marked` (`6 s`) + `slowed_time` (`2 s`); `ink_marked` grants `+20 acc [talisman]` | **D2:** Tagged `"talisman"` and given `c_art 1.5` so `ink-grinding-breath`'s `[talisman]` passives apply to its own holders (Decision A1) |
| `seven-star-talisman` | Throws Wood talisman painting 1 star; cleanse wipes unless painted under The Rain Does Not Take It; 7th detonates | Wood `damage`, `c_art 1.4`, `cost 0.03`, `cd 2.5`, `debuff [1, 10]`, `tags: ["talisman"]`; tracks `dipper_star` + `dipper_star_ttl` (`12 s`) + `dipper_locked`; `cleansed` wipes if unlocked; at 7 -> `2.8 Chaos` free hit | **D3:** Uses shared engine counters (`dipper_star`, `dipper_locked`) instead of a new `painted_star` status (`approx`, Decision A2) |
| `handle-points` | Binds foe where they stand for a moment and makes next talisman strike twice | Wood `control`, `c_art 0.0`, `cost 0.04`, `cd 5.0`, `tags: ["talisman"]`; `art_fired` applies `bound` (`2 s`) + `slowed_time` (`2 s`) + `handle_double = 1`; next non-`handle-points` talisman `hit_landed` calls `fire_art {which: "last", share: 1.0}` | **D4:** Non-spatial `bound` + `slowed_time` replace "where they stand" (Decision A3) |
| `the-rain-does-not-take-it` | For a while debuffs and marks cannot be cleansed; each one foe tries to remove deals Water damage | Water `utility`, `c_art 0.0`, `cost 0.03`, `cd 10.0`, `tags: ["talisman", "cold"]`; `art_fired` grants `talisman_fast: 1, curse_fast: 1` (`8 s`) + `rain_hold = 8`; `cleansed` while `rain_hold >= 1` deals `0.25 Cold` per `event.amount` | **D5:** `cleansed` triggers only on non-fast batches actually removed, since `talisman_fast`/`curse_fast` silently skip cleanses (`approx`) |

---

## E. Effects (`design/stage6-staging/hoa_tinh/effects/hoa_tinh.effects.json`)

All 3 Effects declare every counter they read or write on themselves (`missing_counters=[]`) and pass `engine.validate`.

| Effect (source) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `Rainfast Ink` (`rainfast-ink-art` L1 passive, `d35`) | Talisman marks and talisman-laid debuffs/curses cannot be cleansed | `fight_start` sets `rainfast_ink_on = 1`; `always` grants `talisman_fast: 1, curse_fast: 1` | none |
| `Autumn Light on the Screen` (`ht-silver-candle`) | First talisman thrown strikes again 1 s later at half strength; painted talismans keep a grade higher | `hit_landed` (`per_fight: 1`, `tags: ["talisman"]`) sets `autumn_delay = 1`; next `pulse` clears it and calls `fire_art {which: "longest", share: 0.5}` | **D6:** Uses `which: "longest"` so simultaneous `t = 0.0 s` setup arts do not hijack `last_art`; crafting grade bonus is unmodelled lore (Decision A4) |
| `Seven Stars in One Stroke` (`ht-lamp-ink-brush` 2pc) | Every 7th talisman closes the Dipper: strikes once more per Wood stack and spends them; marks uncleansable 8 s | Counts talisman `art_fired` (`dipper_close`); at `7` consumes all foe Wood debuffs (`0.85 Chaos` each) + sets `talisman_fast: 1, curse_fast: 1` (`8 s`) + `seven_stars_fast = 8` | none (sized at `0.85` Chaos per stack, Decision A4) |

---

## F. Items and Sets (`design/stage6-staging/hoa_tinh/items/`)

- **3 items** (`catalogue-sect-hoa_tinh.json`): all 13 depth modifier lines preserved verbatim (`27.0–42.3 W`, unpriced), `sources: ["npc"]`, `unique: true` on all 3. `ht-silver-candle` (`kind: "treasure"`, `base: "dang"`, `utility`) carries `rarity: 5` (fits rule 21 with no exception needed). `ht-dipper-talisman-seal` (`an`) and `ht-rainfast-ink-gourd` (`ho_lo`) carry the R6 `exception` (**D7**).
- **1 set** (`sets-hoa_tinh.json`): `ht-lamp-ink-brush` (2pc), modifiers preserved verbatim, full-set bonus carries `"effect"` and `"rule"`.
- `lint_items.py`: **3 items, 0 findings**.

---

## G. Stand-ins & Beasts

- **Stand-ins:** `0` (all 17 living members in `hoa_tinh.cast.json` and `hoa_tinh.5.cast.json` already hold `ink-grinding-breath` or `painted-dipper-canon`).
- **Beasts:** `0` (`hoa_tinh` has no `hoa_tinh.beasts.json`).

---

## H. Holder Table & Probes (`sect_fight.py hoa_tinh --seeds 5`, `--gap 0` and `--gap 1`)

**Every art fires at `--gap 0` (`0 REFUSED`, `0 NEVER_FIRED`), and all 3 `hoa_tinh` Effects run on their real holders.**

| Holder (realm) | `--gap 0` result | `--gap 1` result | Arts fired (`--gap 0` / `--gap 1`) | Effects (`with / without`, runs) |
|---|---|---|---|---|
| `ky_ngan_chuc` (KĐ 1) | `27.6 s, 5/5, 54%` | `12.4 s, 0/5, 0%` | `seven-star-talisman` 15.8/6.6, `handle-points` 7.2/3.0, `the-rain-does-not-take-it` 3.4/1.0 | **Rainfast Ink**: `27.6/27.6 s` (`5` runs; vs cleanser-art probe `25.6 s 58%` vs `28.3 s 52%`, `0` vs `10` star wipes). **Autumn Light on the Screen**: `27.6/29.0 s` (`10` runs). **Seven Stars in One Stroke**: `27.6/28.9 s` (`271` runs). **Paid in Advance**: `gap 1` `12.4/9.5 s` (`0` `do()` runs; `always`-only library Effect) |
| `lac_to_binh` (TC 1) | `31.9 s, 5/5, 33%` | `8.3 s, 0/5, 0%` | `seven-star-talisman` 14.6/3.2, `handle-points` 6.8/1.0, `the-rain-does-not-take-it` 3.2/0.0 | **Rainfast Ink**: `31.9/31.9 s` (`5` runs; `gap 1` `8.3/8.3 s`, `5` runs) |
| `diep_tung_yen` (TC 1), `nhiep_to_han` (TC 0), `han_thuy_mac` (TC 0) | `35.8 s, 0/5, 0%` | `8.0 s, 0/5, 0%` | `seven-star-talisman` 13.8/3.0, `handle-points` 5.6/1.0, `the-rain-does-not-take-it` 3.2/0.0 | **Rainfast Ink**: `35.8/35.8 s` (`5` runs) |
| `lang_mac_khanh` (TC 2), `luc_thanh_chi` (TC 2) | `38.5 s, 2/5, 4%` | `8.0 s, 0/5, 0%` | `seven-star-talisman` 15.2/3.0, `handle-points` 6.2/1.0 | n/a (vs cleanser-art probe: `dipper-wiped 47`, `0` detonations) |
| `te_thu_anh` (LK 2) | `33.6 s, 1/5, 3%` | `8.0 s, 0/5, 0%` | `seven-star-talisman` 13.4/3.0, `handle-points` 5.2/1.0, `the-rain-does-not-take-it` 3.2/0.0 | **Rainfast Ink**: `33.6/33.6 s` (`5` runs) |
| `tan_cuc_hoa` (LK 2) | `36.3 s, 1/5, 2%` | `8.0 s, 0/5, 0%` | `seven-star-talisman` 14.4/3.0, `handle-points` 5.2/1.0 | n/a |
| `ma_tinh_but` (LK 2) | `35.2 s, 0/5, 0%` | `8.0 s, 0/5, 0%` | `seven-star-talisman` 12.6/3.0 | n/a |
| `ho_bach_yen` (LK 1), `thai_huyen_nhung` (LK 0), `nham_thanh_luu` (LK 1), `liem_an_loc` (LK 1), `ho_mac_nhi` (LK 1), `phu_vu_sinh` (LK 1), `quan_loc_nhi` (LK 0) | `56.6 s, 0/5, 0%` | `8.4 s, 0/5, 0%` | `wet-ink` 14.0/2.0 | n/a (probe on `ho_mac_nhi`: `wet-ink-prime 70`, `wet-ink-mark 210`) |

**Targeted cleanser-art probe (`enemy` slotting a `cleanse: 3`, `cd 3.0` Water art, 5 seeds):**
- `lang_mac_khanh` (no `Rainfast Ink`): `36.8 s, 2/5, 3%`, `dipper-wiped 47`, `dipper-detonate 0`.
- `ky_ngan_chuc` (with `Rainfast Ink`): `25.6 s, 5/5, 58%`, `dipper-wiped 0`, `dipper-detonate 15`.
- `ky_ngan_chuc` (without `Rainfast Ink`, only `The Rain Does Not Take It`): `28.3 s, 5/5, 52%`, `dipper-wiped 10`, `dipper-detonate 12`.

**Băng Tâm pilot checklist:**
- [x] Every Effect changes the fight on its real holders (`Autumn Light` and `Seven Stars in One Stroke` in `--gap 0`; `Rainfast Ink` in the cleanser-art probe), and every art fires (`0 NEVER_FIRED`, `0 REFUSED`).
- [x] No holder slots colliding stances (none of `hoa_tinh`'s arts use stances; `0` stance collisions).
- [x] Every "your X" Effect works for holders lacking optional pieces (`Rainfast Ink` and `Autumn Light` work without `Seven Stars in One Stroke`; `ink-grinding-breath` holders benefit from their `[talisman]` passives on `wet-ink`).
- [x] Vague words ("for a while", "light Water damage", "half strength", "once more for each of your Wood stacks", "binds where they stand") pinned explicitly in each `rule`.
- [x] Technique bonuses and passives sized cleanly within tier budgets (`7.6/8`, `15.6/16`, `16.0/16 W`) and marked `(new)` in §C.

---

## I. Open items

- Stage 7 merge & export closes `hoa_tinh`'s gap report (`techniques`, `arts_new`, `items`, `sets`, `effects`, `N-hoa_tinh-01..03`).
- `khi_van 1` on `ht-dipper-talisman-seal` stays `game` (`out of fight; no stat sheet reader seen`) until the stat-sheet reader pass.

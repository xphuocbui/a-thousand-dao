# Sương Tùng Các (`suong_tung`): Stage 6 record pass review (2026-11-27, headless job, decisions auto-accepted)

## Summary

**Built (all staged in [design/stage6-staging/suong_tung/](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/suong_tung/); nothing exported, nothing written outside allowed paths):**
- **3 techniques** ([catalogue-sect-suong_tung.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/suong_tung/techniques/catalogue-sect-suong_tung.json)): `pine-paper-talisman-primer` (Tier 0 main, Wood+Water, 6 layers), `frost-pine-ward-canon` (Tier 1 main, Wood+Water, 9 layers, `d15, a1`), and `lantern-ward-art` (Tier 1 secret, Wood+Water, 9 layers). Existing secret method `thorn-and-ink-verses` is already committed in [catalogue-soul-song-seal.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/techniques/catalogue-soul-song-seal.json). All tier-sized bonuses and combat passives are marked **(new)** in §C (`7.2/8`, `15.8/16`, `15.4/16 W`).
- **4 new active arts** ([part-sect-suong_tung.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/suong_tung/arts/part-sect-suong_tung.json)): `frost-sheet`, `laid-ward` (`d15, a1`), `frost-on-the-pine`, and `cold-night-lamp`. All 4 art IDs were inserted into [suong_tung.techniques.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/suong_tung.techniques.json). Existing library arts `ambush-talisman` and `lamp-oil-lance` are referenced unchanged.
- **3 Effects** ([suong_tung.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/suong_tung/effects/suong_tung.effects.json)): `The Light That Stays` (`st-cold-night-lantern`), `Sheets in the Wind` (`st-hundred-wards-flag`), and `Ward Written Inside` (`st-lamp-and-brush` 2pc). Every Effect and art declares every counter it reads or writes in its own `"counters"` array (`missing_counters=[]`), passes `engine.validate`, and runs on its real holders in `sect_fight.py`.
- **3 signature items and 1 set** ([items/catalogue-sect-suong_tung.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/suong_tung/items/catalogue-sect-suong_tung.json), [sets-suong_tung.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/suong_tung/items/sets-suong_tung.json)): `st-cold-night-lantern` (`dang` 3), `st-hundred-wards-flag` (`ky` 3), `st-lantern-maker-brush` (`cham` 2, R6 `exception`), and set `st-lamp-and-brush` (2pc). All 3 items carry `sources: ["npc"]` and `unique: true`, with all 13 depth modifier lines preserved verbatim.
- **0 stand-ins, 0 beasts, 0 pending words** ([pending.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/suong_tung/pending.json) empty), **0 early promotions**, **0 cross-owner references**.

**Counts:**
- **Written:** `techniques: 3, arts: 4, items: 3, sets: 1, effects: 3, stand_ins: 0, beasts: 0`.
- **Deviations:** `5` (`D1`–`D5`, §C–§F).
- **Decisions taken for the user:** `5` (§A).
- **Pending words:** `0`.
- **Never ran in `sect_fight.py`:** `0` (`0 REFUSED`, `0 NEVER_FIRED`, `0 NEVER_RAN` across all 16 living members at both `--gap 0` and `--gap 1`). Sub-note: `laid-ward-foreseen` (`tag.foreseen >= 1`) awaits `"foreseen"` in `REQUEST_TAGS` (shared open item with `minh_loan`), and `laid-ward-spend` is bypassed on `van_han_dang` because `The Light That Stays` (`laid-ward-save-first`) + `Ward Written Inside` (`laid-ward-spend-twice`) protect every crossing on his seeds (while `laid-ward-spend` runs `54–64` times on holders without the Lamp/Brush pair).

**Checks (all run after final edit with `DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\suong_tung`):**
- `lint_arts.py`: checked 4 arts in 1 file, **0 findings** (`engine_payoff frost-sheet empower 1: x1.04 of the lint, gated`).
- `lint_techniques.py`: checked 3 techniques, **0 findings** (`7.2 W of 8`, `15.8 W of 16`, `15.4 W of 16`).
- `lint_items.py`: checked 3 items, **0 findings** (`unique 3 of 3`).
- `depth_check.py --quiet`: **findings: none**.
- `spatial_words_check.py --sect suong_tung`: **0** real spatial hits (`3` false-positive `"flag"` hits in `suong_tung.items.json`/`cast.json` from the item name "Flag of a Hundred Wards", and `2` matching `"Flag"`/`"flag"` hits in staged `suong_tung.effects.json`/`catalogue-sect-suong_tung.json`).
- Standalone `engine.validate` + counter declaration audit: **3/3 VALID**, **`missing_counters=[]`**.
- `sect_fight.py suong_tung --seeds 5` (`--gap 0` and `--gap 1`): **0 REFUSED**, **0 NEVER_FIRED**, **0 NEVER_RAN** across all `16/16` living members.

**Open items (for serial step / Stage 7):**
- Merge `design/stage6-staging/suong_tung/` into `design/` and `assets/data/combat_effects.json`, and run the exporters (`export_techniques.py`, `export_named.py`, `export_combat_library.py`, `export_world.py --sect suong_tung` to close `N-suong_tung-01..03`).
- Add `"foreseen"` to `assets/data/combat_engine.json` `REQUEST_TAGS` (shared with `minh_loan`) when foreseen fights are wired so `laid-ward-foreseen` activates automatically.

---

## A. Auto-accepted decisions (user rule 2026-11-26), with reasons

1. **Use counters rather than stances on `laid-ward`, `frost-on-the-pine`, and `cold-night-lamp` to avoid colliding with `thorn-and-ink-verses` (`marching-dirge`).**
   - *Choice:* Implement `laid-ward` (`ward`, `upkeep: 0.002` qi/pulse), `frost-on-the-pine` (`pine_frost_ward`, `each_for: 8`), and `cold-night-lamp` (`lantern`, `decay_per_pulse: 1`) strictly on self-counters instead of `states`.
   - *Reason:* Five Trúc Cơ members (`van_han_dang`, `nhac_hoa_bi`, `quan_suong_thu`, `thieu_hoa_tam`, `duong_mac_chieu`) slot `thorn-and-ink-verses` as `aux`, whose layer-1 `marching-dirge` toggles the `march` stance. Giving `frost-on-the-pine` or `cold-night-lamp` a `state` would overwrite `march` (Băng Tâm Lesson 2). Counters preserve `march` intact while expressing every ward and lantern duration cleanly.
2. **Read `laid-ward` crossings via `on: "pulse"` (`time > 1`, `any: [own.foe_pressed >= 1, foe.since_act <= 1]`), with `outside_budget: true` Chaos `free_hit` (`0.5`, or `0.7` when `lantern >= 1`) and sequential `ward_spared` gating.**
   - *Choice:* Trigger `laid-ward` once per pulse when the foe acted (`own.foe_pressed >= 1` or `foe.since_act <= 1` with `time > 1`), applying `off_guard` (`1 s`) and `free_hit {c: 0.5/0.7, dtype: "chaos", outside_budget: true}`, and route ward consumption through mutually exclusive `ward_spared` flags (`laid-ward-save-first` -> `laid-ward-spend-twice` -> `laid-ward-spend` -> `laid-ward-clear-spared`). Wire foreseen start on `fight_start` (`tag.foreseen >= 1`).
   - *Reason:* Neither engine has a `foe_art_fired` event (`minh_loan` Decision A3/A6 precedent); `since_act <= 1` captures exact-integer enemy cooldowns; `outside_budget: true` prevents `pulse` `direct_dmg == 0` trigger-budget clipping; and `ward_spared` eliminates same-event set/add listener races between `The Light That Stays`, `Ward Written Inside`, and normal ward burn-out. Using `0.7` Chaos while `lantern >= 1` ensures `cold-night-lamp`'s "takes more damage from wards" boosts `laid-ward`'s `free_hit` triggers (which lack `art` tags) alongside `+25 % dmg_more` on `[ward]` arts.
3. **Implement `cold-night-lamp` (`cd: 5.0`) on a `decay_per_pulse: 1` `lantern` counter (`9` pulses, doubled to `17` by `The Light That Stays`) so it fires before `laid-ward` (`cd: 7.0`).**
   - *Choice:* Set `cold-night-lamp` cooldown to `5.0 s` (`laid-ward` `7.0 s`) and use `lantern` with `decay_per_pulse: 1` (`set: 9` normally -> 8 active pulses, `set: 17` with `lantern_double >= 1` -> 16 active pulses).
   - *Reason:* `each_for` in `counter_def` is static and cannot be doubled by an item Effect (`The Light That Stays`). Using `decay_per_pulse: 1` lets `The Light That Stays` double the lantern's duration cleanly (`9` vs `17` accounts for `pulse()` decrementing before `fire_event("pulse")`), and `cd: 5.0` ensures `van_han_dang` lights `cold-night-lamp` before casting `laid-ward` (`Ward Written Inside` ran `17` times over 5 seeds).
4. **Implement `frost-sheet` as a Water `c_art: 1.4` `[talisman, seal]` control art that sticks `frost_sheet` (`each_for: 10`), delays the foe's next art `0.5 s`, and empowers to `1.75x` (`2.45`) on a stuck sheet; place `frost-sheet` at `unlock_layer: 2` on `pine-paper-talisman-primer`.**
   - *Choice:* `frost-sheet` unlocks at layer 2 (all 4 outer disciples are L2–L4), delays `which: "next"` by `0.5 s`, arms `frost_sheet` (`each_for: 10`), and empowers `c_mult: 1.75` when `own.counter.frost_sheet >= 1`.
   - *Reason:* Gives every outer-gate disciple both `ambush-talisman` and `frost-sheet` (`4/5` wins at Luyện Khí `--gap 0`, `31.8 s`, `29%` HP left) while staying cleanly gated (`x1.04` lint payoff).
5. **Size Tier 0/1 bonuses and combat passives within budget (`7.2/8`, `15.8/16`, `15.4/16 W`), preserve item modifiers verbatim with `unique: true`, and mark `st-lantern-maker-brush` (`cham`) with the R6 `exception`.**
   - *Choice:* Author Yellow passives on `pine-paper-talisman-primer`, `linh_luc_pct 10` + passives on `frost-pine-ward-canon`, and `khi_huyet_pct 10` + passives on `lantern-ward-art`. Mark all 3 signature items `unique: true`, `sources: ["npc"]`, with the R6 `exception` on `st-lantern-maker-brush` (`cham`, weapon role), and `outside_budget: true` on `Sheets in the Wind` (`c: 0.35` Physical on `[ward]` `art_fired`).
   - *Reason:* Matches Tier 0/1 peer budgets, Băng Tâm R6/unique rulings, and avoids `art_fired` `direct_dmg == 0` budget clipping on `nhac_hoa_bi`'s `c_art: 0.0` ward arts.

---

## B. Mechanic table (Step 1)

`spatial_words_check.py --sect suong_tung`: only 3 false-positive `"flag"` hits in prose/comments from the item name "Flag of a Hundred Wards".

| Record | Mechanic | Engine status | Staged implementation |
|---|---|---|---|
| `pine-paper-talisman-primer` / `frost-sheet` | Blank sheet sticks & slows next art; written sheet deals more | Has (`timer` next, counter, `empower`) | `c_art 1.4` Water `[talisman, seal]`; `hit_landed` delays `next` `0.5 s` & sets `frost_sheet` (`10 s`); `empower c_mult 1.75` while `frost_sheet >= 1` |
| `frost-pine-ward-canon` / `laid-ward` (`d15, a1`) | 3 Ward charges, uncapped, qi upkeep; foe art spends 1 -> no evade 1 s + Wood dmg; foreseen 3 free | Has (`upkeep`, `off_guard`, `free_hit`, `tag.foreseen`) | `ward` (`upkeep 0.002` qi); `fight_start` (`tag.foreseen`) +3; `pulse` (`foe_pressed` / `since_act <= 1`) -> `off_guard 1 s` + `0.5` (`0.7` lit) Chaos `free_hit` + `ward_spared` spend |
| `frost-pine-ward-canon` / `frost-on-the-pine` | Next hit on you reduced and attacker slowed | Has (`dampen_taken`, `was_hit`, `slowed_time`) | `pine_frost_ward` (`cap 1, each_for 8`); `always` `+60 dampen_taken`; `was_hit` clears ward & lays `slowed_time 1 (2 s)` |
| `lantern-ward-art` / `cold-night-lamp` | Lantern charge: regen, cold resist, foe slowed, more ward dmg | Has (`decay_per_pulse`, `heal`, `resist`, `dmg_more`) | `lantern` (`decay_per_pulse 1`, set `9` or `17`); `pulse` `2.5%` HP heal & `slowed_time` (cd 3); `always` `+100 cold` resist & `+0.25 dmg_more [ward]` |
| `The Light That Stays` (`st-cold-night-lantern`) | Lantern lasts 2x; while held, first crossed ward does not burn out | Has (`fight_start`, `art_fired`, shared counters) | `lantern_double = 1` on `fight_start`; `ward_save = 1` on `cold-night-lamp` `art_fired` |
| `Sheets in the Wind` (`st-hundred-wards-flag`) | Laying a ward throws a slowing sheet | Has (`art_fired` `[ward]`, `free_hit`, `slowed_time`) | `art_fired [ward]` -> `0.35` Phys `free_hit` (`outside_budget: true`) + `slowed_time 1 (2 s)` |
| `Ward Written Inside` (`st-lamp-and-brush` 2pc) | Wards laid inside Cold Night Lamp's light burn out only on 2nd crossing | Has (`art_fired`, shared counters) | `art_fired` (`laid-ward`, `lantern >= 1`) -> `ward_twice += 3` |

---

## C. Techniques (`design/stage6-staging/suong_tung/techniques/catalogue-sect-suong_tung.json`)

`lint_techniques.py`: **3 techniques, 0 findings**. All bonuses and passives below are newly authored for the depth proposals and marked **(new)**.

| Technique | Tier, kind | Bonuses | Passives | Abilities (unlock) | W used / budget |
|---|---|---|---|---|---|
| `pine-paper-talisman-primer` | Tier 0 main, `moc` + `thuy` (`6` layers) | none (`bonus_count 0`) | `attack_pct 3 [talisman]` **(new)**, `art_speed_pct 4 [talisman]` **(new)**, `status_duration_pct 4 [curse]` **(new)**, `linh_luc_regen_inc_pct 3 []` **(new)** | `ambush-talisman` (1), `frost-sheet` (2) | `7.2 W of 8` |
| `frost-pine-ward-canon` | Tier 1 main, `moc` + `thuy` (`9` layers) | `linh_luc_pct 10` **(new)** | `attack_pct 6 [talisman]` **(new)**, `art_speed_pct 8 [talisman]` **(new)**, `linh_luc_regen_inc_pct 4 []` **(new)**, `ward_efficiency_pct 3 []` **(new)**, `status_resist_pct 6 []` **(new)** | `lamp-oil-lance` (1), `laid-ward` (2), `frost-on-the-pine` (3) | `15.8 W of 16` |
| `lantern-ward-art` | Tier 1 secret, `moc` + `thuy` (`9` layers) | `khi_huyet_pct 10` **(new)** | `health_regen_inc_pct 12 []` **(new)**, `healing_pct 8 []` **(new)**, `resist_pct 100 [cold]` **(new)**, `status_duration_pct 6 [curse]` **(new)**, `attack_pct 5 [ward]` **(new)** | `cold-night-lamp` (1) | `15.4 W of 16` |

**Deviation (`D1`):**
- **D1:** Authored Yellow and Profound bonuses and combat passives on all 3 depth techniques (`7.2/8`, `15.8/16`, `15.4/16 W`), as the depth proposals named none; `laid-ward` and `frost-on-the-pine` unlock at layers 2 and 3 so L2 inner disciples (`nghe_tung_yen`, `o_tieu_mac`, `tat_hanh_chi`) run `lamp-oil-lance` + `laid-ward`, and L3+ holders run all 3 canon arts.

---

## D. Arts (`design/stage6-staging/suong_tung/arts/part-sect-suong_tung.json`)

`lint_arts.py`: **4 arts, 0 findings**.

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `frost-sheet` | Throws a blank sheet that sticks to a foe and slows its next art; a written sheet on the same foe deals more damage. | Water `control`, `c_art 1.4`, `cost 0.03`, `cd 3.5`, `tags: [cold, talisman, seal]`; `hit_landed` (`per_pulse: 1`) delays `next` `0.5 s` and sets `frost_sheet` (`each_for: 10`); `empower c_mult 1.75` (`2.45`) when `frost_sheet >= 1`. | **D2:** Pinned "written sheet on the same foe" as re-casting `frost-sheet` while `frost_sheet` (`10 s`) holds (`x1.04` gated payoff). |
| `laid-ward` (`d15, a1`) | Gains 3 Ward charges, uncapped, qi upkeep; each time the foe fires an art, one is spent: foe cannot evade 1 s and takes Wood damage. Foreseen: 3 gained at start, no cost. | Wood `ward`, `c_art 0.0`, `cost 0.04`, `cd 7.0`, `tags: [wood, talisman, ward, seal]`; `ward` (`upkeep 0.002` qi); `fight_start` (`tag.foreseen`) +3; `art_fired` +3; `pulse` (`foe_pressed` / `since_act <= 1`, `time > 1`) -> `off_guard 1 s` + `0.5` (`0.7` if `lantern >= 1`) Chaos `free_hit` (`outside_budget: true`) + `ward_spared` spend. | **D3:** "Each time the foe fires an art" read once per pulse via `foe_pressed` / `since_act <= 1` (`minh_loan` precedent); `free_hit` Chaos `0.5` (`0.7` lit) uses `outside_budget: true`. |
| `frost-on-the-pine` | Writes a ward on you: the next hit on you is reduced and the attacker is slowed. | Water `ward`, `c_art 0.0`, `cost 0.03`, `cd 5.0`, `tags: [cold, talisman, ward, seal]`; sets `pine_frost_ward` (`cap 1, each_for 8`); `always` `+60 dampen_taken`; `was_hit` clears ward & applies `slowed_time 1 (2 s)`. | **D4:** Uses counter `pine_frost_ward` instead of a stance so `marching-dirge` (`march` stance) is never overwritten (Decision A1); reduction pinned at `+60` dampen (~`37.5 %`). |
| `cold-night-lamp` | Gains a Lantern charge for several seconds: while you hold it, you regenerate health and resist cold; the foe is slowed and takes more damage from wards. | Water `ward`, `c_art 0.0`, `cost 0.04`, `cd 5.0`, `tags: [cold, talisman, ward]`; sets `lantern` (`decay_per_pulse 1`, `9` or `17` if `lantern_double >= 1`); `pulse` `2.5 %` HP heal + `slowed_time` (cd 3); `always` `+100 cold` resist & `+0.25 dmg_more [ward]`. | none (`9`/`17` pulses gives full `8`/`16` active pulses around `decay_per_pulse: 1`). |

---

## E. Effects (`design/stage6-staging/suong_tung/effects/suong_tung.effects.json`)

All 3 Effects declare every counter they read or write (`missing_counters=[]`) and pass `engine.validate`.

| Effect (source) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `The Light That Stays` (`st-cold-night-lantern`) | Your Cold Night Lamp lantern charge lasts twice as long, and while you hold it, the first ward the foe crosses does not burn out. | `fight_start`: `lantern_double = 1` (doubles `cold-night-lamp` `lantern` to `17`); `art_fired` (`cold-night-lamp`): `ward_save = 1` (read by `laid-ward-save-first` while `lantern >= 1`). | none |
| `Sheets in the Wind` (`st-hundred-wards-flag`) | Each time you lay a ward, one blank sheet from the flag flies to the foe and slows it briefly. | `art_fired` (`tags: ["ward"]`): `free_hit {c: 0.35, dtype: "phys", outside_budget: true}` + `slowed_time 1 (2 s)`. | **D5:** Pinned "lay a ward" as firing any `[ward]` art (`laid-ward`, `frost-on-the-pine`, `cold-night-lamp`) and used `outside_budget: true` to avoid `direct_dmg == 0` trigger-budget clipping on `art_fired`. |
| `Ward Written Inside` (`st-lamp-and-brush`, 2pc) | Wards you lay inside your Cold Night Lamp's light are written twice: each burns out only after a second foe crosses it. | `art_fired` (`laid-ward`, `if: own.counter.lantern >= 1`): `ward_twice += 3` (spent 1-for-1 by `laid-ward-spend-twice` before `ward`). | none |

---

## F. Items and sets (`design/stage6-staging/suong_tung/items/`)

- **3 items** (`catalogue-sect-suong_tung.json`): all 13 depth modifier lines preserved verbatim, `sources: ["npc"]`, `unique: true` on all 3. `st-cold-night-lantern` (`dang`, utility) and `st-hundred-wards-flag` (`ky`, utility) fit rule 21 directly; `st-lantern-maker-brush` (`cham`, weapon) carries the R6 `exception`.
- **1 set** (`sets-suong_tung.json`): `st-lamp-and-brush` (2pc), modifiers preserved verbatim, full-set bonus carries `"effect"` and `"rule"`.
- `lint_items.py`: **3 items, 0 findings**.

---

## G. Stand-ins & Beasts

- **Stand-ins:** `0` (`suong_tung` has no stand-in techniques in either cast file).
- **Beasts:** `0` (`suong_tung` has no `suong_tung.beasts.json`).

---

## H. Holder Table (`sect_fight.py suong_tung --seeds 5`, `--gap 0` & `--gap 1`)

**Every art fires (`0 REFUSED`, `0 NEVER_FIRED`), and all 3 `suong_tung` Effects run and affect their real holders.**

| Holder(s) | Realm | Arts | `--gap 0` (`mean_s`, `wins/5`, `hp_left`) | `--gap 1` (`mean_s`, `wins/5`, `hp_left`) | Effects (`with / without`, runs) |
|---|---|---|---|---|---|
| `van_han_dang` | `truc_co` | `lamp-oil-lance`, `laid-ward`, `frost-on-the-pine`, `cold-night-lamp`, `marching-dirge`, `thorn-lullaby` | `30.8 s, 5/5, 97 %` (`3.4–11.4` fires) | `10.2 s, 0/5, 0 %` (`1.0–3.2` fires) | **The Light That Stays**: `30.8 s 97 %` vs `30.8 s 92 %` (`29` runs G0, `15` G1). **Ward Written Inside**: `30.8 s 97 %` vs `30.5 s 95 %` (`17` runs G0, `5` G1). |
| `nhac_hoa_bi` | `truc_co` | `lamp-oil-lance`, `laid-ward`, `frost-on-the-pine`, `marching-dirge`, `thorn-lullaby` | `30.3 s, 5/5, 92 %` (`4.0–10.8` fires) | `8.7 s, 0/5, 0 %` (`1.0–3.0` fires) | **Sheets in the Wind**: `30.3 s 92 %` vs `28.3 s 88 %` (`59` runs G0, `15` G1). |
| `thieu_hoa_tam`, `quan_suong_thu` | `truc_co` | `lamp-oil-lance`, `laid-ward`, `frost-on-the-pine`, `marching-dirge`, `thorn-lullaby` | `27.1 s, 5/5, 97 %` (`4.0–9.8` fires) | `8.3 s, 0/5, 0 %` (`1.0–2.2` fires) | n/a |
| `duong_mac_chieu` | `truc_co` | `lamp-oil-lance`, `laid-ward`, `frost-on-the-pine`, `marching-dirge` | `37.9 s, 5/5, 24 %` (`5.0–14.0` fires) | `8.1 s, 0/5, 0 %` (`1.0–2.0` fires) | n/a |
| `khong_da_hanh` | `truc_co` | `lamp-oil-lance`, `laid-ward`, `frost-on-the-pine`, `cold-night-lamp` | `61.9 s, 4/5, 14 %` (`7.8–16.0` fires) | `8.5 s, 0/5, 0 %` (`1.0–2.2` fires) | n/a |
| `chu_anh_tuyet`, `hang_bang_tuong`, `lien_bich_phu` | `luyen_khi` | `lamp-oil-lance`, `laid-ward`, `frost-on-the-pine` | `34.6 s, 0/5, 0 %` (`4.6–11.4` fires) | `8.0 s, 0/5, 0 %` (`1.0–2.0` fires) | n/a |
| `o_tieu_mac`, `tat_hanh_chi`, `nghe_tung_yen` | `luyen_khi` | `lamp-oil-lance`, `laid-ward` | `41.8 s, 0/5, 0 %` (`5.4–13.6` fires) | `8.0 s, 0/5, 0 %` (`1.0–2.0` fires) | n/a |
| `cau_ap_suong`, `banh_tieu_dang`, `bui_to_chi`, `cao_han_chuc` | `luyen_khi` | `ambush-talisman`, `frost-sheet` | `31.8 s, 4/5, 29 %` (`8.0–9.8` fires) | `9.0 s, 0/5, 0 %` (`2.0` fires) | n/a (`frost-sheet` empowers `5` times on seed 1) |

**Băng Tâm pilot checklist:**
- [x] Every Effect changes the fight on its real holders (`The Light That Stays`: `97%` vs `92%`; `Ward Written Inside`: `97%` vs `95%`; `Sheets in the Wind`: `92%` vs `88%`), and every art fires (`0 NEVER_FIRED`, `0 REFUSED`).
- [x] No holder slots colliding stances (`marching-dirge` keeps `march` stance undisturbed; `laid-ward`, `frost-on-the-pine`, and `cold-night-lamp` use counters).
- [x] Every "your X" Effect works for holders lacking optional pieces (`laid-ward` runs without `cold-night-lamp` or `st-cold-night-lantern`; `frost-sheet` runs standalone on outer disciples).
- [x] Vague words ("briefly", "a little", "reduced", "more damage", "written sheet") pinned explicitly in each `rule`.
- [x] Technique bonuses and passives sized cleanly within tier budgets (`7.2/8`, `15.8/16`, `15.4/16 W`) and marked **(new)** in §C.

---

## I. Open items

- Stage 7 merge & export closes `suong_tung`'s `depth_gap.py` rows (`techniques`, `arts_new`, `items`, `sets`, `effects`, `N-suong_tung-01..03`).
- Adding `"foreseen"` to `assets/data/combat_engine.json` `REQUEST_TAGS` activates `laid-ward-foreseen` (`tag.foreseen >= 1`) automatically.

REVIEW DONE

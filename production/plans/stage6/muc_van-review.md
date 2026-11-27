# Mục Vân Trang (`muc_van`): Stage 6 record pass review (2026-11-27, headless job, decisions auto-accepted)

## Summary

**Built (all staged in `design/stage6-staging/muc_van/`; nothing exported, nothing outside allowed paths):**
- **3 techniques** (`techniques/catalogue-sect-muc_van.json`): the 2 depth lineage methods (`cloud-herd-body-canon`, `herd-call`) plus 1 new Yellow Water+Wood servants' method (`river-ice-groom-breath`) for the hired groom stand-in `hua_tich_cau`. `mountain-bone-body-art` and `gale-courier-scripture` are already committed in `design/techniques/catalogue-body.json` and `catalogue-wind.json`. Every bonus and passive on the staged techniques is new and sized cleanly inside its tier budget (§C).
- **6 new arts** (`arts/part-sect-muc_van.json`): the 5 depth arts (`the-long-ride`, `run-with-the-herd`, `bridle-hand`, `whistle-home`, `the-herd-turns`) plus `two-bucket-haul` for `river-ice-groom-breath`. All 6 art ids and `river-ice-groom-breath` are registered in `design/world/depth/sects/muc_van.techniques.json`.
- **4 Effects** (`effects/muc_van.effects.json`): 2 item Effects (`Turn the Herd`, `Horse and Rider Bear It Together`) and 2 full-set Effects (`One Thread of Wind`, `Ninety Thousand Li`). Every Effect declares all counters it reads or writes in its own `"counters"` array for standalone GDScript compilation (`test_every_library_effect_compiles` / `fighter_profile_loader.gd`), validates cleanly in `engine.validate`, and runs on its real holder in `sect_fight.py`.
- **6 items and 2 sets** (`items/catalogue-sect-muc_van.json`, `items/sets-muc_van.json`): all 25 depth modifier lines preserved verbatim (all 25 already run in `fight.py`), `sources: ["npc"]`, `unique: true` on all 6 items, and the R6 `exception` mark on the 3 weapon/armour/robe pieces (`mv-cloud-herding-lance`, `mv-herder-felt-armour`, `mv-whirlwind-abbey-habit`).
- **1 stand-in resolved** in `design/world/depth/sects/muc_van.cast.json`: `hua_tich_cau` (`hoang_thuy` layer 3 -> `river-ice-groom-breath` layer 3). `stand_ins` gap = `0`.
- **2 beasts verified** (`muc_van.beasts.json` & `muc_van.cast.json`): `khau_muc_van` already lists `beasts: ["dap_van"]` and `tan_thien_ly` already lists `beasts: ["hong_tong"]` (exported in Stage 7).
- **0 pending words** (`pending.json` is empty: every record runs on existing engine words).
- **0 early promotions** (`cross_owner: 0`).

**Counts:**
- **Deviations:** `13` (`D1`–`D13`, §C–§F).
- **Decisions taken for the user:** `6` (§A).
- **Pending words:** `0`.
- **Never ran in `sect_fight.py`:** `0` (all 6 arts fire and all 4 Effects run at both `gap 0` and `gap 1`).

**Checks (all run after final edit with `DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\muc_van`):**
- `lint_arts.py`: checked 6 arts in 1 file, **0 findings**.
- `lint_techniques.py`: checked 3 techniques, **0 findings** (`16.0 W of 16`, `15.8 W of 16`, `8.0 W of 8`; 0 `OVER_BUDGET` notes).
- `lint_items.py`: checked 6 items, **0 findings** (`unique 6 of 6`).
- `depth_check.py --quiet`: **findings: none**.
- `depth_gap.py --sect muc_van`: `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `ties_unmapped: 0`, `ties_over_cap: 0`, `engine_words: 0`, `wishes_open: 0`, `lines: 25/25 runs`.
- Standalone Effect compile check (`engine.validate` + counter declaration audit): **4/4 OK**, **0 undeclared counters**.
- `sect_fight.py muc_van --seeds 10` (`gap 0` and `gap 1`): **0 REFUSED**, **0 NEVER_FIRED**, **0 NEVER_RAN**.

**Open items (for Stage 7 / serial step / user):**
- Stage 7 world export will wire `dap_van` (`khau_muc_van`) and `hong_tong` (`tan_thien_ly`) into `world_history.json` beasts and permanent fight companions (`sect_fight.py` does not yet attach permanent beasts, so `khau_muc_van` was also verified in a 20-seed probe with `dap_van` attached: all 3 companion Effects show massive impact).
- `thoi_duong_giac` inherits two pre-existing committed stances (`swallow-stance` from `gale-courier-scripture` and `mountain-root-stance` from `mountain-bone-body-art`, both outside `muc_van`'s write scope); she still wins 10/10 at `gap 0` (11.8 s, 99% HP) and 5/20 at `gap 1` (40.4 s) with `Ninety Thousand Li`.

---

## A. Decisions auto-accepted (user rule 2026-11-26), with reasons

1. **Promote `herd-call` as `tech_kind: "body"` (`names: []`, `family: "body"`) instead of `tech_kind: "secret", names: []`.**
   - *Choice:* Set `"tech_kind": "body"` on `herd-call` in `catalogue-sect-muc_van.json` while keeping `"names": []`.
   - *Reason:* `cong-phap.md` Rule 2 and `lint_techniques.py` require `secret` techniques to name 1–3 elements and restrict `names: []` to `body` techniques. Mục Vân is a no-lean body sect (`elements: []`) recruiting by bone (`can_cot`); forcing elements onto `herd-call` would contradict the manor's no-lean doctrine and exclude non-matching inner riders, whereas `tech_kind: "body"` preserves `names: []`, keeps both arts element-less, and scales with `can_cot`.
2. **New Yellow Water+Wood servants' method `river-ice-groom-breath` (`two-bucket-haul`) for stand-in `hua_tich_cau`.**
   - *Choice:* Create a `muc_van` Yellow `main` method (`names: ["thuy", "moc"]`) rather than cross-promoting another sect's Water method or giving him `mountain-bone-body-art`.
   - *Reason:* Follows `_brief-record.md` Step 5. His `exception` explicitly forbids teaching him the manor's lineage (`"not taught the lineage"`), his note names no outside method, and his root (`thuy 36, moc 28`) and backstory (hauling two buckets of river ice for the white bear for thirty summers) fit a humble Yellow `tap_dich` method with zero cross-owner dependencies.
3. **Track `the-long-ride` stance via self-counter `long_ride_on` (not `s.state`), with `shield {body: 0.005}` per Momentum gained and penetrating foe art hits as the heavy-blow halving trigger.**
   - *Choice:* Use counter `long_ride_on` (`cap: 1`), `shield {body: 0.005}` on each pulse Momentum grows, `L5 +2` (`dtype: "phys"`) scaled per Momentum, and `was_hit` (`kind: "art"`, `event.amount > 0`, `per_pulse: 1`) with `scale {read: "own.counter.momentum", per: 2}` -> `add: -1` to halve Momentum cleanly.
   - *Reason:* `khau_muc_van` slots both `the-long-ride` and committed library art `swallow-stance` (`s.state = "swallow"`). Using `s.state` on `the-long-ride` would collide with `swallow-stance` (Băng Tâm Lesson 2), and rewriting `swallow` into a combined state would break `swallow-glide`, `hundred-feather-flurry`, and `held-breath` which read `own.state.swallow`. `body_shield_pct` is a static key (no live mod exists), and `was_hit`'s `event.amount` is raw HP (not a share of `hp_max`), so an unblocked foe art hit reaching health cleanly approximates a 5%+ heavy blow while rewarding body-shield upkeep.
4. **Add a 5 s spirit-horse `summon` (`c: 0.45`, `cd: 1.5 s`, `dtype: "phys"`) to `the-herd-turns` and use `dmg_more` (`kind: "companion"`) across all companion damage Effects.**
   - *Choice:* `the-herd-turns` calls a temporary herd mount alongside its 5 s companion buff and Slowed Time on companion hits; every companion damage modifier in `muc_van` uses `dmg_more` (`kind: "companion"`), not `L1`/`L5`.
   - *Reason:* `herd-call`'s own concept is calling horses from the herd (`"calls one beast, then three"`). Summoning a herd horse makes `herd-call` immediately playable for inner riders without a permanent beast (`du_bon_van`, `lu_truy_phong`) and lets all companion Effects run in `sect_fight.py` even before permanent beasts load. Using `dmg_more` is required because `engine.py:1326` bypasses `layers_M` (`L1`–`L5`) for `kind == "companion"`.
5. **Run `Horse and Rider Bear It Together` and `One Thread of Wind` on existing engine words (`dampen_taken 17.65`, `companion_present`, `each_for: 1.0` joint-strike windows, Physical art hit for lance knock-down).**
   - *Choice:* Track companion presence for 6 s after each companion hit (`companion_present`), run the 15 % direct-hit damage share as `dampen_taken 17.65` (`1 / 1.1765 = 0.85`), detect 1 s joint strikes with paired `each_for: 1.0` charge counters, heal the rider 2 % HP on joint strikes (companions have no health bar, Combat rule 19), and trigger `One Thread of Wind`'s knock-down (`stop_clock 1.0` + `off_guard 1 s`, spending 5 Wind stacks) on Physical art hits (`dtype: "phys", kind: "art"`).
   - *Reason:* Avoids adding single-item pending words (`own.companions`, `avoid_share`) while faithfully preserving every build interaction (tiring on hits taken, full rest on joint strikes, healing + Wind + knock-down loop, companion bonus vs statused foe). Pinning "lance hit" to Physical art hits ensures `khau_muc_van`'s `run-with-the-herd`, `bridle-hand`, and `anchor-drop` all trigger it (none carry a `"lance"` tag).
6. **Trigger `Ninety Thousand Li`'s gust on `element: "wind", tags: ["escape", "step"]` (with `dampen_taken: 25` for exact 20 % reduction).**
   - *Choice:* Accept both `escape` and `step` tags on Wind arts when spending 8+ Wind buff stacks.
   - *Reason:* No Wind `escape` art exists in `design/arts/` yet, and `thoi_duong_giac`'s `gale-courier-scripture` kit uses `step`-tagged Wind footwork (`three-step-chase`, `swallow-stance`). Matching `["escape", "step"]` keeps future Wind escape arts supported while making `Ninety Thousand Li` actively run and deliver `+10.2 s` survival (`5/20` vs `2/20` wins at `gap 1`) on its real holder today.

---

## B. Mechanic table (Step 1)

`spatial_words_check.py` returned 3 lines on `muc_van` (`foe within` in `horse-and-rider-bear-it-together` = time window "within 1 s"; `beside` in `horse-and-rider-bear-it-together` and `cloud-herd-body-canon` = lore for companion present): 0 real spatial rules.

| Record | Mechanic | Engine status | Implementation |
|---|---|---|---|
| `cloud-herd-body-canon` / `the-long-ride` (`d20`) | Stance: +1 Momentum per pulse you/horse hit; +Phys dmg & body shield per stack; heavy blow (5%+) halves | Has (`approx` on 5%+ & shield) | `long_ride_on` counter; `hit_landed` once/pulse -> `momentum +1` + `shield 0.005`; `always` `scale` -> `L5 +2 [phys]`; `was_hit [art]` `event.amount > 0` -> halve via `scale per 2, add -1` |
| `cloud-herd-body-canon` / `run-with-the-herd` | Spend Momentum: rider + horse hit together, foe soonest art waits 0.5 s, Phys dmg scaled by stacks | Has | `c_art 1.6`, `companion_speed +100` (1 s), `scale momentum` -> `free_hit 0.20 phys` + `momentum = 0`; `hit_landed` -> `timer foe next +0.5 s` |
| `cloud-herd-body-canon` / `bridle-hand` | Seize & hold foe 1 s; companion deals extra damage while held | Has | `c_art 1.4`, `statuses [bound 2s]`; `hit_landed` -> `stop_clock foe 1.0 s` + `dmg_more 0.35 [companion]` (2 s) |
| `herd-call` / `whistle-home` | Call companion, small heal, clear fear/slow | Has (rider target, Combat R19) | `c_heal 0.8`, `cleanse {curses: 1}`, `companion_speed +15` (3 s), `status_resist +15` (3 s) |
| `herd-call` / `the-herd-turns` | Companions gain attack & speed for a few s; foe struck is slowed | Has | `summon` herd horse (`c 0.45, cd 1.5, for 5 s`), `dmg_more 0.25 [companion]` + `companion_speed 25` (5 s), `herd_turns` counter -> companion `hit_landed` lays `slowed_time` (2 s) |
| `river-ice-groom-breath` / `two-bucket-haul` | New Yellow Water+Wood servants' method for `hua_tich_cau` | Has | Water `c_art 1.5`, `cost 0.03`, `cd 4.0`, `art_fired` -> `shield {body: 0.04}` |
| `Turn the Herd` (`mv-cloud-herding-lance`) | Companion hit within 1 s of own art hit -> foe next art waits 0.3 s & companion's next hit +30 % | Has | `rider_art_window` (`each_for: 1.0`), `herd_turn_next` (`spend` before `proc` so same hit never self-spends), `timer foe next +0.3 s`, `dmg_more 0.30 [companion]` |
| `Horse and Rider Bear It Together` (`mv-dap-van-bridle-ring`, `d42`) | Companion active -> 15 % direct hits taken by horse; each hit -2 % comp dmg for 5 s; joint strike within 1 s clears all | Has (`approx`) | `companion_present` (`each_for: 6.0`), `dampen_taken 17.65`, `horse_tired` (`each_for: 5.0`) -> `dmg_more -0.02 [companion]` per stack; joint strike (`hr_own_hit`/`hr_comp_hit`, `each_for: 1.0`) sets `horse_tired = 0` |
| `One Thread of Wind` (`mv-horse-lord` 3pc) | Joint strike within 1 s -> heal 2 % & +1 Wind stack; at 5 stacks next lance hit knocks down 1 s; companion +15 % vs statused foe | Has | `otw_own_hit`/`otw_comp_hit` (`each_for: 1.0`) -> `heal 0.02` + 1 Wind (10 s); `hit_landed [phys, art]` at 5+ Wind -> `consume 5 Wind`, `stop_clock 1.0`, `off_guard 1 s`; `always` `foe.distinct_statuses >= 1` -> `dmg_more 0.15 [companion]` |
| `Ninety Thousand Li` (`mv-phu-dao-last` 3pc) | Evade -> +1 Wind; Wind escape/step art at 8+ Wind spends all -> 2 s -20 % dmg taken & +2.5 % evade/stack for 4 s | Has (`approx` `step` tag) | `evaded` -> 1 Wind (8 s); `art_fired [wind, tags: escape|step]` at `own.buff.wind >= 8` -> `dampen_taken 25` (2 s) + `consume` all Wind -> `evade +2.5` / stack (4 s) |

---

## C. Techniques (`design/stage6-staging/muc_van/techniques/catalogue-sect-muc_van.json`)

All bonuses and passives below are **new** (the depth proposals name none) and sized cleanly inside their tier budgets (`lint_techniques.py`: **3 techniques, 0 findings**, 0 `OVER_BUDGET` notes).

| Technique | Tier, kind | Bonuses (new) | Passives (new) | Abilities (unlock) | Peer & W |
|---|---|---|---|---|---|
| `cloud-herd-body-canon` | Profound body, none | `khi_huyet_pct` 12 | `body_shield_pct` 6 `[]`, `attack_pct` 5 `[physical]`, `health_regen_inc_pct` 10 `[]`, `attack_pct` 6 `[companion]`, `art_speed_pct` 4 `[physical]` | `the-long-ride` (1), `run-with-the-herd` (2), `bridle-hand` (4) | `hundred-echo-palm-scripture` (`16.0 W of 16`) |
| `herd-call` | Profound body, none | `than_thuc_pct` 10 | `attack_pct` 8 `[companion]`, `art_speed_pct` 8 `[companion]`, `status_resist_pct` 8 `[]`, `healing_pct` 5 `[]`, `linh_luc_regen_inc_pct` 2 `[]` | `whistle-home` (1), `the-herd-turns` (2) | `hundred-echo-palm-scripture` (`15.8 W of 16`) |
| `river-ice-groom-breath` (new) | Yellow main, Water+Wood | none | `khi_huyet_pct` 4 `[]`, `health_regen_inc_pct` 8 `[]`, `linh_luc_regen_inc_pct` 4 `[]` | `two-bucket-haul` (1) | `warm-hearth-breath` (`8.0 W of 8`) |

**Deviations (`D1`–`D4`):**
- **D1–D2:** New tier-sized bonuses and passives added to `cloud-herd-body-canon` (`16.0/16 W`) and `herd-call` (`15.8/16 W`).
- **D3:** `herd-call` promoted with `tech_kind: "body"` (`names: []`) instead of `tech_kind: "secret", names: []` per Cong Phap rule 2 and `lint_techniques.py` (Decision A1).
- **D4:** New Yellow Water+Wood servants' method `river-ice-groom-breath` (`8.0/8 W`) and art `two-bucket-haul` authored for stand-in `hua_tich_cau` (Decision A2).

---

## D. Arts (`design/stage6-staging/muc_van/arts/part-sect-muc_van.json`)

`lint_arts.py`: **6 arts, 0 findings**.

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `the-long-ride` (`d20`) | Stance: each s you/horse hit adds Momentum (+Phys dmg & body shield); 5%+ blow loses half | Element-less `ward` stance (`long_ride_on` counter), `cost 0.03`, `cd 6.0`; `hit_landed` once/pulse -> `momentum +1` + `shield 0.005`; `L5 +2 [phys]` per Momentum; `was_hit [art]` (`amount > 0`) halves Momentum | **D5:** Self-counter avoids stance clash with `swallow-stance`; body shield via `shield 0.005`; 5%+ heavy blow approximated by penetrating foe art hit |
| `run-with-the-herd` | Charge spending Momentum: rider & companion hit together, foe soonest art waits 0.5 s, Phys dmg scaled by stacks | Element-less `damage`, `c_art 1.6`, `cost 0.04`, `cd 5.0`, `phys`; `companion_speed +100` (1 s); spends all Momentum for `0.20` Phys free hit/stack; `hit_landed` -> `timer foe next +0.5 s` | **D6:** Companion alignment expressed as `+100%` companion speed for 1 s; `0.20` Phys free-hit scale per stack |
| `bridle-hand` | Seizes & holds foe 1 s; companion deals extra damage while held | Element-less `control`, `c_art 1.4`, `cost 0.04`, `cd 7.0`, `statuses [bound 2s]`; `hit_landed` -> `stop_clock foe 1.0 s` + `dmg_more 0.35 [companion]` (2 s) | **D7:** "holds 1 s" expressed as `stop_clock 1.0 s` + `bound 2 s`; companion bonus `+35%` for 2 s |
| `whistle-home` | Calls companion to side, heals it a little, clears 1 fear/slow | Element-less `heal`, `c_heal 0.8`, `cost 0.03`, `cd 5.0`; `cleanse {curses: 1}`, `companion_speed +15` (3 s), `status_resist +15` (3 s) | **D8:** Heal & curse cleanse target the rider (companions have no HP/status bar, Combat R19), paired with companion speed rally |
| `the-herd-turns` | Companions gain attack & speed for a few s; foe struck by them is slowed | Element-less `summon`, `cost 0.04`, `cd 8.0`; calls spirit horse (`c 0.45`, `cd 1.5`, `for 5 s`), `dmg_more 0.25 [companion]` + `companion_speed 25` (5 s), companion `hit_landed` lays `slowed_time` (2 s) | **D9:** Also summons a 5 s herd horse matching `herd-call` lore so non-beast inner riders & `sect_fight.py` get active companion procs |
| `two-bucket-haul` (new) | n/a (new servants' art) | Water `damage`, `c_art 1.5`, `cost 0.03`, `cd 4.0`, `art_fired` -> `shield {body: 0.04}` | part of **D4** |

---

## E. Effects (`design/stage6-staging/muc_van/effects/muc_van.effects.json`)

All 4 Effects declare every counter they read/write on themselves and pass standalone `engine.validate`.

| Effect (source) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `Turn the Herd` (`mv-cloud-herding-lance`) | Companion hit within 1 s of own art hit -> foe soonest art waits 0.3 s & companion's next hit +30 % | `rider_art_window` (`each_for: 1.0`), `herd_turn_next` (`spend` ordered before `proc`), `timer foe next +0.3 s`, `dmg_more 0.30 [companion]` | none (exact) |
| `Horse and Rider Bear It Together` (`mv-dap-van-bridle-ring`, `d42`) | Companion active -> 15 % direct hit taken by horse; each share -2 % comp dmg for 5 s; joint strike within 1 s rests it fully | `companion_present` (`each_for: 6.0`), `dampen_taken 17.65`, `horse_tired` (`each_for: 5.0`) -> `dmg_more -0.02 [companion]` per stack; joint strike (`each_for: 1.0`) resets `horse_tired = 0` | **D10:** `companion_present` 6 s proxy & `dampen_taken 17.65` (`approx`) |
| `One Thread of Wind` (`mv-horse-lord` 3pc) | Joint strike within 1 s -> both heal 2 % & +1 Wind; at 5 stacks next lance hit knocks down 1 s; companion +15 % vs statused foe | Joint strike (`each_for: 1.0`, once/pulse) -> `heal 0.02` + 1 Wind (10 s); `hit_landed [phys, art]` at 5+ Wind -> consumes 5 Wind, `stop_clock 1.0`, `off_guard 1 s`; `dmg_more 0.15 [companion]` vs statused foe | **D11:** Heals rider (Combat R19); "lance hit" = Physical art hit; consumes 5 Wind on knock-down |
| `Ninety Thousand Li` (`mv-phu-dao-last` 3pc) | Evade -> +1 Wind; Wind escape art at 8+ stacks spends all -> 2 s -20 % dmg taken & +2.5 % evade/stack for 4 s | `evaded` -> 1 Wind (8 s); `art_fired [wind, tags: escape|step]` at 8+ Wind -> `dampen_taken 25` (2 s) + `consume` all Wind -> `evade +2.5` / stack (4 s) | **D12:** Matches `step` alongside `escape` (`approx`, Decision A6) |

---

## F. Items and Sets (`design/stage6-staging/muc_van/items/`)

- **6 items** (`catalogue-sect-muc_van.json`): all 25 depth modifier lines preserved verbatim (`16.0–38.7 W`, unpriced), `sources: ["npc"]`, `unique: true` on all 6. Weapon (`mv-cloud-herding-lance`, base `mao`) and armour/robe (`mv-herder-felt-armour` `giap`, `mv-whirlwind-abbey-habit` `dao_bao`) carry the R6 `exception` mark (**D13**). Utility (`ky`), ring (`nhan`), and necklace (`ngoc_boi`) pieces fit rule 21 with no exception needed.
- **2 sets** (`sets-muc_van.json`): `mv-horse-lord` and `mv-phu-dao-last`, 2-piece modifiers preserved verbatim, 3-piece bonuses structured as `"effect"` + `"rule"`.
- `lint_items.py`: **6 items, 0 findings**.

---

## G. Stand-ins & Beasts (`muc_van.cast.json`, `muc_van.beasts.json`)

| Person | Realm | Stand-in change | Beasts (already wired in `muc_van.cast.json`) |
|---|---|---|---|
| `hua_tich_cau` | `luyen_khi` 2 | `hoang_thuy` 3 -> `river-ice-groom-breath` 3 | none |
| `khau_muc_van` | `ket_dan` 1 | none (already `cloud-herd-body-canon` 8) | `dap_van` (spirit horse, Kết Đan) |
| `tan_thien_ly` | `truc_co` 2 | none (already `cloud-herd-body-canon` 6) | `hong_tong` (spirit mare, Trúc Cơ) |

---

## H. Holder Table & Probes (`sect_fight.py muc_van --seeds 10`; + 20-seed probes)

**Every technique art fires and every Effect runs at both `gap 0` and `gap 1` (0 REFUSED, 0 NEVER_FIRED, 0 NEVER_RAN).**

| Holder / Probe | Result (`gap 0` / `gap 1`) | Effects (`with / without`, runs) | Note |
|---|---|---|---|
| `khau_muc_van` (KD 1, `sect_fight`, 10 seeds) | `41.0 s 10/10 100%` / `17.3 s 0/10 0%` | **Horse & Rider**: `41.0 s` vs `42.5 s` (`1192` runs `gap 0`); `17.3 s` vs `14.9 s` (`388` runs `gap 1`). **Turn the Herd**: `41.0 s` vs `42.8 s` (`262` runs `gap 0`); `17.3 s` vs `17.8 s` (`47` runs `gap 1`). **One Thread of Wind**: `41.0 s` vs `39.3 s` (`1058` runs `gap 0`); `17.3 s` vs `16.0 s` (`311` runs `gap 1`) | All 6 arts fire (`the-long-ride` 1.0, `run-with-the-herd` 10.3, `bridle-hand` 6.9, `whistle-home` 9.5, `the-herd-turns` 5.1, `swallow-stance` 10.0) |
| **Probe:** `khau_muc_van` + `dap_van` (20 seeds) | `31.9 s 20/20 100%` / `33.7 s 0/20 0%` | **Horse & Rider**: `gap 1` **`33.7 s` vs `28.2 s`** (`+5.5 s`, `2818` runs). **Turn the Herd**: `gap 0` **`31.9 s` vs `33.4 s`** (`-1.5 s` faster kill, `885` runs). **One Thread of Wind**: `gap 1` **`33.7 s` vs `17.5 s`** (`+16.2 s`, `3550` runs) | Shows full horse-lord synergy with permanent spirit horse `dap_van` |
| `thoi_duong_giac` (KD 0, `sect_fight`, 10 seeds) | `11.8 s 10/10 99%` / `38.8 s 3/10 9%` | **Ninety Thousand Li**: `gap 0` `11.8 s` vs `11.9 s` (`56` runs); `gap 1` **`38.8 s 3/10 9%` vs `29.4 s 0/10 0%`** (`+9.4 s`, `206` runs) | 20-seed `gap 1` probe confirms: **`40.4 s 5/20 7%` vs `30.2 s 2/20 2%`** (`448` runs) |
| `tan_thien_ly`, `du_bon_van`, `lu_truy_phong` (TC) | `52.8 s 10/10 57%` / `9.4 s 0/10 0%` | n/a | All 5 lineage arts fire (`1.0 / 10.4 / 6.6 / 10.2 / 5.5` per fight at `gap 0`) |
| `khau_thanh_thao` (TC 1) | `57.7 s 9/10 22%` / `9.3 s 0/10 0%` | n/a | All 3 canon arts fire (`1.0 / 10.7 / 6.9`) |
| `trinh_luc_phan` (TC 0) | `55.0 s 4/10 4%` / `8.3 s 0/10 0%` | n/a | Both unlocked arts fire (`1.0 / 9.9`) |
| `khau_tieu_cau`, `thong_truy_dien`, `tan_muc_so` (LK) | `49.8 s 1/10 1%` / `8.1 s 0/10 0%` | n/a | Both unlocked arts fire (`1.0 / 8.6`) |
| `hua_tich_cau` (LK 2, stand-in) | `53.7 s 1/10 1%` / `8.0 s 0/10 0%` | n/a | `two-bucket-haul` fires `12.0x` at `gap 0`, `1.3x` at `gap 1` |

*(Note: `mac_khien_phong`, `kim_dac_loc`, `tiet_bo_van`, `me_dich_am`, `ngai_dap_sa`, `ngao_tuyet_nhi`, and `nghieu_thu_nhan` use the already-committed `mountain-bone-body-art` with no `muc_van`-owned techniques or named items, so `sect_fight.py` skips them by design.)*

**Băng Tâm pilot checklist:**
- [x] Every Effect changes the fight with and without it on its real holders, and every art fires (`0 NEVER_FIRED`, `0 NEVER_RAN`).
- [x] No authored art introduces a stance collision (`the-long-ride` uses `long_ride_on` counter so it never overwrites `swallow-stance` on `khau_muc_van`; no art sets an undefined stance).
- [x] Each "your companion" / "your X" Effect works cleanly even for holders who lack a permanent companion (`the-herd-turns` calls a herd horse, `bridle-hand` and `whistle-home` still apply full control/heal/cleanse/resist).
- [x] Vague words ("heavy blow", "holds them", "fear or slow", "lance hit", "Wind escape art") pinned explicitly in each `rule` field.
- [x] New technique bonuses and passives sized cleanly inside same-tier budgets (`16.0/16`, `15.8/16`, `8.0/8`) and marked new in §C.

---

## I. Open items

- Stage 7 world export will attach `dap_van` (`khau_muc_van`) and `hong_tong` (`tan_thien_ly`) from `muc_van.beasts.json` into game data.
- `thoi_duong_giac`'s pre-existing `swallow-stance` + `mountain-root-stance` pairing (both committed library arts outside `muc_van`) could optionally get a future combined-stance or aux check in Stage 11 balance, though she already performs strongly (`10/10` at `gap 0`, `5/20` at `gap 1`).

REVIEW DONE

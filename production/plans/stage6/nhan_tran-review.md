# Nhạn Trận Môn (`nhan_tran`): Stage 6 record pass review (2026-11-27, headless job, decisions auto-accepted)

## Summary

**Built (all staged in `design/stage6-staging/nhan_tran/`; nothing exported, nothing outside allowed paths):**
- **3 techniques** (`techniques/catalogue-sect-nhan_tran.json`): `wild-geese-formation-canon` (Profound main, `names: []`), `spring-levy-drum` (Profound secret, `names: []`), `walking-out-of-the-grey` (Earth secret, `names: []`). Existing body/outer method `mountain-bone-body-art` is already in `design/techniques/catalogue-body.json`. All new bonuses and passives are sized to tier (§C) while preserving `wild-geese-formation-canon`'s `b1` passives verbatim.
- **5 new arts** (`arts/part-sect-nhan_tran.json`): `geese-stance`, `trading-the-point`, `close-the-file`, `one-breath-down-the-file`, `the-rear-guard-faces-back` (all element-free, `element: ""`). All 5 `"id"` fields were inserted in `design/world/depth/sects/nhan_tran.techniques.json`. Existing library arts `mountain-root-stance` and `marching-dirge` are referenced unchanged.
- **4 Effects** (`effects/nhan_tran.effects.json`): `One Goose`, `Geese Line`, `Last Man in the File`, `Take the Wind`. Every Effect declares all counters it reads or writes in its own `"counters"` array (`STANDALONE_OK 4`).
- **6 items and 2 sets** (`items/catalogue-sect-nhan_tran.json`, `items/sets-nhan_tran.json`): depth modifiers preserved verbatim (`29/29` lines run), `sources: ["npc"]`, `unique: true`, `rarity: 5` on grade-4 treasure `nt-first-file-banner`, and R6 `exception` on the 4 weapon/body_gear/ward_gear pieces (`nt-breath-cloth`, `nt-point-sword`, `nt-rear-guard-shield`, `nt-point-felt-coat`).
- **0 stand-ins, 0 beasts, 0 early promotions, 0 pending words** (`pending.json` not needed).

**Checks (run after final edit with `DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\nhan_tran`):**
- `lint_arts.py design/stage6-staging/nhan_tran/arts/part-sect-nhan_tran.json`: **5 arts, 0 findings**.
- `lint_techniques.py design/stage6-staging/nhan_tran/techniques/catalogue-sect-nhan_tran.json`: **3 techniques (`16.0 W / 16`, `15.6 W / 16`, `22.5 W / 24`), 0 findings**.
- `lint_items.py design/stage6-staging/nhan_tran/items/catalogue-sect-nhan_tran.json`: **6 items (`unique 6 of 6`), 0 findings**.
- `depth_check.py --quiet`: **findings: none**.
- `depth_gap.py --sect nhan_tran`: `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `ties_unmapped: 0`, `ties_over_cap: 0`, `engine_words: 0`, `wishes_open: 0`, `lines: 29/29 runs`.
- Standalone Effect compile check (`engine.validate`): **STANDALONE_OK 4**.
- `sect_fight.py nhan_tran --seeds 5` (`--gap 0` and `--gap 1`): **0 REFUSED**, all 5 staged arts fire on real holders.

**Counts:**
- **Deviations:** `10` (§C–§F).
- **Decisions taken for the user:** `8` (§A).
- **Pending words:** `0`.
- **Early promotions:** `0`.
- **Never ran in `sect_fight.py`:** `Geese Line` reports `runs 0 NEVER_RAN` only because both of its records are `on: "always"` (read live in `Fight.mod`, not counted by `Fight.do()`); its `with` vs `without` delta on `muc_han_nhan` at `--gap 1` proves it actively extends survival (`44.2 s` vs `40.8 s`, `+3.4 s`).

**Open items (for Stage 7 / serial step / user):**
- `nt-first-file-banner` has `kind: "treasure"` (`rarity: 5`); verify `export_named.py` handles `kind: "treasure"` at Stage 7 (carried over from `bang_tam.md`).
- Outer disciples (`lieu_kien_thach`, `luong_bo_khuyet`, `sach_bat_ngon`, `ton_lac_ho`, `hang_co_nhan`) use `mountain-bone-body-art` only (`sect_fight.py` runs the 13 living holders of authored `nhan_tran` methods/items).

---

## §A Auto-Accepted Decisions (user rule 2026-11-26), with reasons

1. **Adapt `nhan_tran`'s `postponed-2026-11-26.json` records into 1v1 equivalents rather than parking the sect's main lineage.**
   - *Choice:* Promote `wild-geese-formation-canon`, `geese-stance`, `one-breath-down-the-file`, `One Goose`, `Geese Line`, and `Last Man in the File` with faithful 1v1 engine rewrites (matching the `b02` precedent of `phan_vu` `Red Cloud Rising` and `truc_thuc` `Warm the Grove`), instead of parking them.
   - *Reason:* Unlike `lac_ha`'s optional `long-sky-one-colour` aux canon, `wild-geese-formation-canon` is Nhạn Trận Môn's sole `main` technique (13 of 18 living disciples, and the only technique for 4 Luyện Khí inner disciples), and `One Goose` / `Geese Line` / `Last Man in the File` are the sect head's core signature items/set. Rewriting multi-fighter ally-counting and parked `held_damage` into 1v1 formation/banner/sustain rules keeps the entire sect playable and lets every art and Effect run cleanly without inventing engine words.
2. **Use self-counter `geese_stance` (and tags `["formation", "ward"]`) instead of `s.state` or `"stance"` tag on `geese-stance`.**
   - *Choice:* Model `Geese Stance` with a self-counter `geese_stance` (`0`/`1`) and omit `"stance"` from `tags`.
   - *Reason:* Six living `nhan_tran` fighters (including `muc_han_nhan`, `dong_kien_luy`, `muc_tan_vu`) slot `mountain-bone-body-art`'s `mountain-root-stance` (`family-body.json`), whose `root-toggle` triggers on `filter: {"tags": ["stance"]}`, and `dong_kien_luy` / `cat_tri_co` also slot `spring-levy-drum`'s `marching-dirge` (`state: "march"`). Using `geese_stance` preserves `mountain-root` and `march` intact without clobbering or unintended toggling (Băng Tâm Lesson 2), and lets `trading-the-point` cleanly end `geese_stance` without dropping `mountain-root`.
3. **Model `Geese Stance`'s 1v1 file protection as `dampen_taken: 18`, 15 % hit-recovery heal (`was_hit`), and +3 % HP `ward_grow` every 3 s.**
   - *Choice:* Replace `0.9^(allies-1)` and parked `held_damage` (`40 %` held, paid off by healing) with steady `dampen_taken: 18` (`~1 - 0.9^2`), a 15 % `heal {of: "amount"}` on `was_hit` (`per_pulse: 1`), and +3 % HP `ward_grow` every 3 s (`limit: {cooldown: 3}`). Removed `Displaced` break condition (Displace removed in 2026-11-26 no-spatial ruling).
   - *Reason:* Preserves the "very hard to break, sustains through strain, grows a small ward every 3 s" identity on existing Stage 5/6 actions (`dampen_taken`, `heal of: amount`, `ward_grow`).
4. **Loop `trading-the-point` -> `geese-stance` rotation via explicit pulse counter `point_hold` (`4 -> 0`).**
   - *Choice:* On cast, `trading-the-point` sets `point_hold = 4` and `dampen_taken: 30` for 4 s; on the 4th pulse (`point_hold == 1` before `add: -1`), resets `geese_stance = 0` and calls `cleanse {curses: 1}` so `geese-stance` opens its guard (`geese_stance < 1`) and re-forms the line.
   - *Reason:* Faithful to "For 4 s you take 30 % less damage; then the stance ends and clears one curse from you", avoids `decay_per_pulse` firing before `pulse`, and creates an active file-rotation cadence across the fight.
5. **Give `close-the-file` an active drum brace (`c_art: 1.6`, 3 s `+10 %` speed / `5 %` dampen) alongside its once-per-fight `wounded` rally (`5 s` `+25 %` art/basic speed, `+12 %` companion speed, `10 %` dampen).**
   - *Choice:* Combine an active `c_art: 1.6` Physical drum strike + 3 s line-tightening mod with the `on: "wounded"` (`per_fight: 1`) rally (`art_speed 25, basic_speed 25, companion_speed 12, dampen_taken 10` in one merged `mod` dict). Dropped `each time you are Displaced` (`duel-readings.md` §3a) per 2026-11-26 no-spatial ruling.
   - *Reason:* Keeps `close-the-file` useful when slotted at `gap 0` (where holders stay above 25 % HP) while firing its full Wounded rally at `gap 1` / low HP (`PROBE_DONG_WOUNDED`: `close_beat=3, close_wounded=1`). Merging all 4 stats into one `mod` avoids `temp_mods` overwriting by `e["id"]`.
6. **Rewrite `one-breath-down-the-file` as 8 s shared-breath cleansing (`+30 %` `status_resist`, immediate `2` debuffs + `1` curse cleansed, and `1` debuff cleansed per pulse for 8 pulses).**
   - *Choice:* Omit the punitive "Alone: curses last twice as long" fallback (which was an artifact of `div / 1` in multi-fighter math and would punish `muc_han_nhan` in every 1v1 duel) and express "halved poison and shortened curses" through `status_resist: 30` + immediate cleanse + 8 pulses of `cleanse {n: 1}`.
   - *Reason:* Aligns with `walking-out-of-the-grey`'s core concept ("a shared poison is a halved poison") and ensures the sect head's Earth secret art helps rather than harms him in 1v1 fights.
7. **Set `wild-geese-formation-canon` `mountain-root-stance` unlock at layer 4, `spring-levy-drum` unlocks `[1, 2]`, and `walking-out-of-the-grey` unlocks `[1, 2]`.**
   - *Choice:* `geese-stance` (1), `trading-the-point` (2), `mountain-root-stance` (4); `close-the-file` (1), `marching-dirge` (2); `one-breath-down-the-file` (1), `the-rear-guard-faces-back` (2).
   - *Reason:* Respects `unlock_layer <= 6` (`cong-phap` rule), keeps `bo_thanh_lang` (`spring-levy-drum` L1) firing `close-the-file`, and gives `luong_thu_hang` (who has no `mountain-bone-body-art` aux) `mountain-root-stance` at L5.
8. **Use `"names": []` directly on all 3 element-free techniques (`lint-element-free-techniques`) and `rarity: 5` on treasure `nt-first-file-banner`.**
   - *Choice:* No fake element proxy needed (supported by `b02` `lint_techniques.py` update); all 5 carried arts and `mountain-root-stance` / `marching-dirge` have `element: ""`. Set `rarity: 5` (dropping `grade: 4`) on `nt-first-file-banner` and added R6 `exception` on the 4 armour/shield/weapon pieces (`nt-breath-cloth`, `nt-point-sword`, `nt-rear-guard-shield`, `nt-point-felt-coat`).
   - *Reason:* Cleanly passes `lint_techniques.py` (`0 findings`) and `lint_items.py` (`0 findings`) while matching `nhan_tran` R3 no-lean canon.

---

## §B Mechanic Table (Step 1)

`spatial_words_check.py --sect nhan_tran`: flagged `one-goose`, `geese-line`, `nt-first-file-banner`, `nt-out-of-the-grey`, `wild-geese-formation-canon`, `Geese Stance`, `One Breath Down the File` (`allies`, `ally`, `Alone`, `banner`, `Piece`, `planted`, `Displace`), plus soft notes (`behind her`, `Pace`). All non-soft issues resolved in staged records (§A 1–6).

| Record | Mechanic | Engine Status | Staged Implementation |
|---|---|---|---|
| `wild-geese-formation-canon` / `geese-stance` | File stance: damage reduction, strain heal, +3 % HP ward/3 s | Rewritten 1v1 (no allies / `held_damage` / `Displace`) | Self-counter `geese_stance`: `always` `dampen_taken: 18`, `was_hit` (`per_pulse: 1`) `heal {of: amount, share: 0.15}`, `pulse` (`cd: 3`) `ward_grow 0.03` |
| `wild-geese-formation-canon` / `trading-the-point` | 4 s −30 % dmg taken, then end stance & clear 1 curse | Has | `point_hold = 4`, `mod {dampen_taken: 30, for: 4}`; at `point_hold == 1`, `geese_stance = 0` + `cleanse {curses: 1}` |
| `spring-levy-drum` / `close-the-file` | Active brace + Wounded 5 s speed (companions half) & −10 % dmg | Has | `c_art: 1.6` + 3 s brace (`+10 %` speed, `5 %` dampen); `on: wounded` (`per_fight: 1`) -> `art_speed 25, basic_speed 25, companion_speed 12, dampen_taken 10` (5 s) |
| `walking-out-of-the-grey` / `one-breath-down-the-file` | 8 s shared breath halving debuffs & mitigating curses | Rewritten 1v1 (no ally division / Alone penalty) | `one_breath = 8`, `status_resist 30` (8 s), `cleanse {n: 2}` + `cleanse {curses: 1}`, `pulse` -> `cleanse {n: 1}` |
| `walking-out-of-the-grey` / `the-rear-guard-faces-back` | 3 s evade + ward + 1 free hit | Has | `mod {evade: 20, for: 3}`, `ward_grow 0.08 hp`, `free_hit {c: 1.8, dtype: phys}` |
| `One Goose` (`nt-first-file-banner`) | Planted banner reduces dmg taken & takes first share | Rewritten 1v1 (no ally count) | `banner_planted = 1` at `fight_start`, `always` `dampen_taken: 15`, every 6 s `was_hit` heals `30 %` of damage taken |
| `Geese Line` (`nt-first-file-banner`, `d17`) | +8 block per file anchor beyond self | Rewritten 1v1 (`banner_planted` + `geese_stance`) | `always`: `+8 block` when `banner_planted >= 1`, `+8 block` when `geese_stance >= 1` |
| `Last Man in the File` (`nt-out-of-the-grey` 3pc) | While Banner stands: shield block + shed poison/miasma on block (3 s cd) | Has | `always` (`banner_planted >= 1`) `block: 20`; `on: blocked` (`cd: 3`) -> `cleanse {n: 1, el: "wood"}` + `cleanse {status: "corpse_rot"}` |
| `Take the Wind` (`nt-point-of-file` 2pc) | −10 % dmg taken; each block gives small ward | Has (`duel-readings` §3a) | `always` `dampen_taken: 10`; `on: blocked` (`per_pulse: 2`) -> `ward_grow 0.015 hp` |

---

## §C Techniques (`catalogue-sect-nhan_tran.json`)

All `bonuses` and NEW `passives` are sized against same-tier catalogue peers; `b1` passives on `wild-geese-formation-canon` are kept verbatim.

| Technique | Tier, Kind | Bonuses (NEW) | Passives | Arts (Unlock) | W Used / Budget |
|---|---|---|---|---|---|
| `wild-geese-formation-canon` | 1 / `main` | `khi_huyet_pct 10` | `attack_pct 6 [tho]` (`b1`), `block_rating 10 []` (`b1`), `khi_huyet_pct 6.6 []` (`b1`), **NEW**: `defense_pct 2 []`, `status_resist_pct 5 []` | `geese-stance` (1), `trading-the-point` (2), `mountain-root-stance` (4) | `16.0 W of 16` |
| `spring-levy-drum` | 1 / `secret` | `defense_pct 10` | **NEW**: `attack_pct 6 [physical]`, `art_speed_pct 5 []`, `block_rating 8 []`, `khi_huyet_pct 5 []`, `status_resist_pct 4 []` | `close-the-file` (1), `marching-dirge` (2) | `15.6 W of 16` |
| `walking-out-of-the-grey` | 2 / `secret` | `khi_huyet_pct 12`, `defense_pct 10` | **NEW**: `status_resist_pct 15 []`, `evade_pct 4 []`, `block_rating 15 []`, `health_regen_inc_pct 15 []` | `one-breath-down-the-file` (1), `the-rear-guard-faces-back` (2) | `22.5 W of 24` |

**Deviations (D1–D2):**
- **D1:** Added tier-matched NEW `bonuses` (`khi_huyet_pct`, `defense_pct`) and NEW combat `passives` to all 3 techniques (keeping `b1` lines verbatim on `wild-geese-formation-canon`).
- **D2:** Set unlock layers to `[1, 2, 4]`, `[1, 2]`, `[1, 2]` (§A 7).

---

## §D Arts (`part-sect-nhan_tran.json`)

`lint_arts.py`: **5 arts, 0 findings**.

| Art | Depth Text | Engine Form | Deviation |
|---|---|---|---|
| `geese-stance` | Stance: 3+ allies dmg ×0.9^(n-1); Alone 40 % held 4 s, heal pays first; small ward / 3 s; Displaced breaks | `c_art: 0`, `cost: 0.03`, `cd: 5.0`, guard `geese_stance < 1`, tags `[formation, ward]`; sets `geese_stance = 1`; `dampen_taken: 18`, `was_hit` (`per_pulse: 1`) `heal {of: amount, share: 0.15}`, `pulse` (`cd: 3`) `ward_grow 0.03 hp` | **D3:** Uses self-counter `geese_stance` instead of `s.state`/`stance` tag (§A 2); 1v1 adaptation replaces ally multiplier / `held_damage` / `Displaced` (§A 3) |
| `trading-the-point` | 4 s 30 % less dmg; then stance ends & clears 1 curse | `c_art: 0`, `cost: 0.03`, `cd: 8.0`, tags `[formation, ward]`; `point_hold = 4`, `mod {dampen_taken: 30, for: 4}`; on 4th pulse (`point_hold == 1`) sets `geese_stance = 0` + `cleanse {curses: 1}` | **D4:** Ends `geese_stance` counter rather than `s.state` (§A 4) |
| `close-the-file` | When first Wounded: 5 s attack speed (companions half) & 10 % less dmg | `c_art: 1.6` (`phys`, `cost: 0.03`, `cd: 5.0`, tags `[formation, quick]`), 3 s brace (`+10 %` speed, `5 %` dampen); `on: wounded` (`per_fight: 1`) -> `art_speed 25, basic_speed 25, companion_speed 12, dampen_taken 10` (5 s) | **D5:** Added active `c_art: 1.6` brace for non-Wounded fights; dropped `Displaced` clause (§A 5) |
| `one-breath-down-the-file` | 8 s: curses/debuffs divided by allies & −25 % dur (Alone: halved & 2× dur) | `c_art: 0`, `cost: 0.03`, `cd: 10.0`, tags `[formation, cleanse]`; `one_breath = 8`, `status_resist 30` (8 s), `cleanse {n: 2}`, `cleanse {curses: 1}`, + `cleanse {n: 1}` per pulse for 8 pulses | **D6:** 1v1 cleanse/resist rewrite drops ally-count division and Alone penalty (§A 6) |
| `the-rear-guard-faces-back` | 3 s evade & ward, strike once (free hit) | `c_art: 0`, `cost: 0.04`, `cd: 7.0`, tags `[formation, ward]`; `evade 20` (3 s), `ward_grow 0.08 hp`, `free_hit 1.8 phys` | none (pins evade +20 pp, ward 8 % HP, free hit c 1.8) |

---

## §E Effects (`effects/nhan_tran.effects.json`)

All 4 Effects declare every read/written counter locally (`STANDALONE_OK 4`).

| Effect (Source) | Depth Rule | Engine Form | Deviation |
|---|---|---|---|
| `One Goose` (`nt-first-file-banner`) | Banner planted (Piece) & 3+ allies: dmg ×(1−X)^(n−1), banner's first share yours | `fight_start`: `banner_planted = 1, banner_first = 1`; `always`: `dampen_taken: 15`; `was_hit` (`banner_first >= 1`): `heal {of: amount, share: 0.30}`, `banner_first_cd = 6` | **D7:** 1v1 adaptation maps planted banner to `banner_planted = 1`, `dampen_taken: 15`, and 6 s first-share hit absorption (§A 1) |
| `Geese Line` (`nt-first-file-banner`) | 2+ allies (you, companions, Pieces): +8 block per ally beyond self | `always`: `+8 block` (`banner_planted >= 1`) + `+8 block` (`geese_stance >= 1`) | **D8:** 1v1 anchors (`banner_planted` and `geese_stance`) replace multi-fighter ally count |
| `Last Man in the File` (`nt-out-of-the-grey` 3pc) | While Banner spread holds: shield block + blocked hit sheds 1 poison/miasma (3 s cd) | `always` (`banner_planted >= 1`): `block: 20`; `on: blocked` (`cd: 3`): `cleanse {n: 1, el: "wood"}` + `cleanse {status: "corpse_rot"}` | **D9:** "blocked as though raised the shield" pinned as `+20` block rating while `banner_planted >= 1` |
| `Take the Wind` (`nt-point-of-file` 2pc) | −10 % dmg taken; each block gives small ward | `always`: `dampen_taken: 10`; `on: blocked` (`per_pulse: 2`): `ward_grow 0.015 hp` | none (pins small ward = 1.5 % HP, max 2/pulse) |

---

## §F Items and Sets (`items/catalogue-sect-nhan_tran.json`, `items/sets-nhan_tran.json`)

- **6 items**, modifiers preserved verbatim (`29/29` lines run, `16.8–40.0 W`), `sources: ["npc"]`, `unique: true`.
  - **D10:** `nt-first-file-banner` uses `"rarity": 5` (`kind: "treasure"`, grade 4); R6 `exception` added on the 4 armour/shield/weapon pieces (`nt-breath-cloth`, `nt-point-sword`, `nt-rear-guard-shield`, `nt-point-felt-coat`); proposal fields `status` and `authored` dropped.
- **2 sets** (`nt-out-of-the-grey`, `nt-point-of-file`), 2-piece modifiers preserved verbatim, full-set bonuses split into `"effect"` + `"rule"`.
- `lint_items.py`: **6 items, 0 findings**.

---

## §G Stand-ins & Beasts

- **Stand-ins:** `0` (`depth_gap.py`: `stand_ins 0`).
- **Beasts:** `0`.
- **Events:** `4` structured (`N-nhan_tran-01..04`).

---

## §H Holder Table & Probes (`sect_fight.py nhan_tran --seeds 5`, `--gap 0` and `--gap 1`; probes)

**0 REFUSED across all 13 living authored-method/item holders. All 5 staged arts fire on real holders at both `gap 0` and `gap 1`.**

| Holder / Probe | Realm | Arts Slotted | Gap 0 (`mean_s`, `wins/5`, `hp%`) | Gap 1 (`mean_s`, `wins/5`, `hp%`) | Effects Observed (`with` vs `without`, runs) / Note |
|---|---|---|---|---|---|
| `muc_han_nhan` | `ket_dan` | `geese-stance`, `trading-the-point`, `mountain-root-stance`, `one-breath-down-the-file`, `the-rear-guard-faces-back`, `bone-turning-palm` | `32.0 s`, `5/5`, `100%` | `44.2 s`, `0/5`, `0%` | **One Goose**: `gap 0` `32.0s 100%` (`runs 205`), `gap 1` `44.2s` vs `23.4s` (`runs 290`, `+20.8s`). **Geese Line**: `gap 1` `44.2s` vs `40.8s` (`+3.4s`, `always` `runs 0`). **Last Man in the File**: `gap 0` `runs 51`, `gap 1` `44.2s` vs `40.4s` (`runs 74`, `+3.8s`) |
| `dong_kien_luy` | `ket_dan` | `geese-stance`, `trading-the-point`, `mountain-root-stance`, `close-the-file`, `marching-dirge`, `bone-turning-palm` | `17.2 s`, `5/5`, `100%` | `18.0 s`, `0/5`, `0%` | All 6 arts fire (`3.0, 2.6, 4.0, 4.0, 7.0, 5.6` at gap 0; `2.4, 2.4, 2.4, 2.4, 3.2, 2.0` at gap 1) |
| `muc_tan_vu` | `truc_co` | `geese-stance`, `trading-the-point`, `mountain-root-stance`, `bone-turning-palm` | `26.0 s`, `5/5`, `100%` | `20.8 s`, `0/5`, `0%` | **Take the Wind**: `gap 0` `26.0s 100%` (`runs 183`), `gap 1` `20.8s` vs `18.2s` (`runs 156`, `+2.6s`) |
| `co_thiet_liet`, `ngo_bat_tan` | `truc_co` | `geese-stance`, `trading-the-point`, `mountain-root-stance`, `bone-turning-palm` | `29.9 s`, `5/5`, `100%` | `16.4 s`, `0/5`, `0%` | All 4 arts fire cleanly |
| `duong_thu_tuyen`, `luong_thu_hang` | `truc_co` | `geese-stance`, `trading-the-point`, `mountain-root-stance` | `60.8 s`, `5/5`, `96%` | `16.0–16.4 s`, `0/5`, `0%` | All 3 arts fire cleanly (`7.4, 6.8, 9.2` at gap 0) |
| `cat_tri_co` | `truc_co` | `geese-stance`, `trading-the-point`, `mountain-root-stance`, `close-the-file`, `marching-dirge` | `38.6 s`, `5/5`, `94%` | `13.2 s`, `0/5`, `0%` | All 5 arts fire cleanly (`5.6, 5.0, 7.4, 7.6, 10.2` at gap 0) |
| `bo_thanh_lang` | `luyen_khi` | `geese-stance`, `trading-the-point`, `close-the-file` | `51.7 s`, `5/5`, `93%` | `12.0 s`, `0/5`, `0%` | All 3 arts fire (`7.0, 6.8, 10.4` at gap 0) |
| `thieu_vu_hang`, `la_nhat_hang`, `lam_te_vu`, `ninh_bac_hang` | `luyen_khi` | `geese-stance`, `trading-the-point` | `64.8 s`, `3/5`, `5%` | `10.8 s`, `0/5`, `0%` | Both arts fire (`8.0, 7.2` at gap 0) |
| **Probe `PROBE_POISON_CURSE`** (`muc_han_nhan` vs Wood/Corpse Rot/Slowed Time foe, seed 1) | `ket_dan` | full kit | `31.0 s`, win `A` | — | `last_man_shed=9`, `point_rotate=3`, `one_breath_open=2`, `one_breath_pulse=16` |
| **Probe `PROBE_DONG_WOUNDED`** (`dong_kien_luy` vs `nguyen_anh` typical, seed 1) | `ket_dan` | full kit | — | `24.0 s`, `0/1` | `close_beat=3`, `close_wounded=1` (`on: wounded` rally verified) |

**Băng Tâm pilot checklist:**
- [x] Every Effect changes the fight with and without it on its real holders (`One Goose`, `Geese Line`, `Last Man in the File`, `Take the Wind`), and all 5 staged arts fire on real holders.
- [x] No holder overwrites or toggles another stance (`geese-stance` uses self-counter `geese_stance` and omits `"stance"` tag, preserving `mountain-root-stance` and `marching-dirge`).
- [x] Every Effect declares all read/written counters locally (`STANDALONE_OK 4`).
- [x] Vague words ("small ward", "first share", "blocked as though raised the shield", "half speed") pinned in `rule` fields.
- [x] New technique bonuses and passives sized against same-tier peers (`16.0/16`, `15.6/16`, `22.5/24`) and marked NEW above.

REVIEW DONE

# Stage 6 Record Review — `lang_dao` (Lãng Đào Môn)

## Summary
Staged all `lang_dao` Stage 6 content into [design/stage6-staging/lang_dao/](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/lang_dao) — **3 techniques** (`ferry-pole-primer`, `washing-waves-canon`, `nine-bends-art`), **3 new arts** (`pole-vault`, `a-thousand-washings`, `ninth-bend`), **4 items** (`ld-nine-bend-toll-seal` as `kind: "treasure"`, `rarity: 5`; `ld-last-white-sail`, `ld-first-fleet-anchor`, `ld-ferry-master-oilskin`), **1 set** (`ld-nine-landings`), **3 Effects** (`Pay the Toll`, `The Boat That Did Not Burn`, `Round the Bend, Then the Anchor`), and empty `pending.json` (0 new engine words needed) — and wrote the new art IDs back into [lang_dao.techniques.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/lang_dao.techniques.json).

All linters pass with **0 findings** (`lint_arts.py`, `lint_techniques.py`, `lint_items.py`), `depth_check.py --sect lang_dao` passes with **0 findings**, `spatial_words_check.py` reports **0** hits on all staged files, `engine.validate()` passes standalone for all 3 Effects, and `sect_fight.py lang_dao --seeds 5` runs cleanly at both `gap 0` and `gap 1` across all 18 living cast members (**0 REFUSED**, every art fires). Targeted probes verified `The Boat That Did Not Burn` against a Fire-Burn foe (`22.0 s` with `refused` leaving `1` HP vs `13.4 s` without), `Ninth Bend` + `Anchor` drop vs a 40% evade foe, `Pole Vault` banking, and standalone `Pay the Toll` reaching its 5-toll Pass.

---

## §A Auto-Accepted Decisions (with design rationale)

1. **`nine-bends-art` omits `swallow-stance` from staged `abilities`**: [swallow-stance](file:///C:/Users/xphuo/IdeaProjects/my-game/design/arts/family-wind.json) has `element: "wind"`, which fails `lint_techniques.py` `ELEMENT` unless `"phong"` is added to `names`; adding `"phong"` would break `CongPhap.usable()` ([cong_phap.gd](file:///C:/Users/xphuo/IdeaProjects/my-game/src/gameplay/cultivation/cong_phap.gd)) for all three living `nine-bends-art` holders (`giang_cuu_khuc`, `thuong_bach_pham`, `lai_bat_khuc`), who all have Water+Wood roots without Wind. Following `tung_dao`'s `startled-goose-step` precedent, `swallow-stance` stays in `lang_dao.techniques.json` as depth background, staged `abilities` carries `ninth-bend` at `unlock_layer: 1`, `nine-bends-art` carries `evade_pct 8`, and `ninth-bend` grants `+12 evade` for `3.5 s` on cast so the curve-slipping fantasy works in Water.
2. **Non-spatial rewrite of `ninth-bend`**: Depth prose says *"deals heavy damage from behind and cannot be evaded"*. Dropped *"from behind"* per the 2026-11-26 no-spatial-fight ruling; expressed *"heavy damage and cannot be evaded"* as `dmg_more: 1.0` (`×2.0` damage) + `acc: 500` on the next damaging Water art (`own.since_act <= 0`).
3. **Unlock layers and passive/bonus sizing**: Sized `ferry-pole-primer` (`7.9 / 8.0 W`: `evade_pct 3`, `khi_huyet_pct 3`, `linh_luc_regen_inc_pct 2`; `pole-vault` L1, `rooted-form` L2), `washing-waves-canon` (`bonuses`: `linh_luc_pct 12`, `attack_pct 10`; `passives` `23.3 / 24.0 W`: `art_speed_pct 10 [thuy]`, `attack_pct 8 [thuy]`, `resist_pen_pct 30 [cold]`, `pierce_pct 8`, `linh_luc_regen_inc_pct 5`; `gathering-wave` L1, `a-thousand-washings` L2, `drag-of-the-deep` L4), and `nine-bends-art` (`bonuses`: `attack_pct 8`; `passives` `16.0 / 16.0 W`: `evade_pct 8`, `attack_pct 6 [thuy]`; `ninth-bend` L1) so every living holder in `lang_dao` (and `loose-south`'s `trinh_tieu_do`, `yen_hoi_do`) unlocks their arts and passes `CongPhap.usable()`.
4. **`a-thousand-washings` ward-stripping & full pierce approximation**: Modelled *"each hit strips a small part of the foe's ward"* as `+15 pen [water]` per `washings` stack (1..9), and *"at the tenth hit the next art pierces fully"* as `bypass: 0.5` (`bypass_cap`) + `pierce: 75` (`pierce_cap`) + `pen: 300` on the next damaging art (`own.since_act <= 0`), since `pass_shields` only exists on `free_hit`.
5. **Independent `anchor_bend` counter on `Round the Bend, Then the Anchor`**: `Round the Bend, Then the Anchor` tracks its own `anchor_bend` counter on `evaded` rather than sharing `nine_bend` with `ninth-bend`, avoiding double-incrementing on `giang_cuu_khuc` while keeping both records standalone-compilable. Also shares `tolled` / `toll_paid` / `toll_pass` declarations in its own `counters` so `Pay the Toll` + `Round the Bend` compose seamlessly and compile standalone.
6. **`Pay the Toll` trigger & `The Boat That Did Not Burn` tick approximation**: Because the engine emits no foe-side `art_fired` event, `Pay the Toll` triggers on `was_hit` and `evaded` (`kind: "art"`, `per_pulse: 1` so multi-hit splits pay once per cast) and transfers `0.02` of foe `qi_max` (`burn_qi of: "max", to_self: 1.0`) up to 5 tolls (`0.10` total), then grants `dampen_taken: 11.11` (`-10 %` damage taken). `The Boat That Did Not Burn` treats the Sail/Flag charge as standing while worn (base `ky` has no Flag art), halves Fire hits via `dampen_taken: 100 [dtype: fire]`, reduces Burn ticks via `resist: 200 [dtype: fire]` (since `defend()` does not apply `dampen_taken` to ticks), and uses `on: "down"` `refuse_down` (1 HP) when `own.counter.sail_burn_tick >= 1` or `own.debuff.fire >= 1`.
7. **Item schema (`unique: true`, R6 `exception`, `kind: "treasure"`, `rarity: 5`)**: Marked all 4 items `sources: ["npc"]`, `unique: true`; set `kind: "treasure", rarity: 5` (dropping `grade`) on `ld-nine-bend-toll-seal`; added the R6 `exception` on the 3 `weapon`/`body_gear` items (`ld-nine-bend-toll-seal`, `ld-first-fleet-anchor`, `ld-ferry-master-oilskin`).

---

## §B Techniques (`techniques/catalogue-sect-lang_dao.json`)

| ID | Tier | Kind | Names | Layers | Passive W | Bonuses & Abilities |
|---|---|---|---|---|---|---|
| `ferry-pole-primer` | 0 | `main` | `thuy`, `moc` | 6 | 7.9 / 8 | Bonuses: none; `pole-vault` (L1), `rooted-form` (L2) |
| `washing-waves-canon` | 2 | `main` | `thuy`, `moc` | 12 | 23.3 / 24 | Bonuses: `linh_luc_pct 12`, `attack_pct 10`; `gathering-wave` (L1), `a-thousand-washings` (L2), `drag-of-the-deep` (L4) |
| `nine-bends-art` | 1 | `secret` | `thuy` | 9 | 16.0 / 16 | Bonuses: `attack_pct 8`; `ninth-bend` (L1) *(depth `swallow-stance` omitted; see §A #1)* |

*(All `bonuses` and `passives` above are new against the depth file, which named none.)*

---

## §C Arts (`arts/part-sect-lang_dao.json`)

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `pole-vault` | *"The holder vaults and the next blow she lands makes the foe's soonest art wait 0.3 s."* | `water`, `elem`, `role: "control"`, `tags: ["cold", "movement"]`, `c_art: 1.45`, `cost_share: 0.03`, `cd: 3.5`; `on: "art_fired"` `held: {"until": "hit_landed", "cap": 1}` -> `timer foe next +0.3 s`. | Added light `c_art: 1.45` strike so outer holders (`ferry-pole-primer`) have an active attack art alongside `rooted-form`; if it lands it triggers immediately, if evaded it waits for the next hit landed. |
| `a-thousand-washings` | *"Each hit of the holder's Water arts strips a small part of the foe's ward; at the thousandth part (in practice, the tenth hit) the next art pierces fully."* | `water`, `elem`, `role: "damage"`, `tags: ["cold", "wave"]`, `c_art: 1.8`, `split: [0.25]*4`, `cost_share: 0.05`, `cd: 5.0`; Water art `hit_landed` adds `washings` (`+15 pen [water]` each on `always`); at 10 clears & arms `washings_pierce` for next damaging art (`bypass: 0.5, pierce: 75, pen: 300`). | *"pierces fully"* uses `bypass 0.5` (`bypass_cap`), `pierce 75` (`pierce_cap`), and `+300 pen`, since `pass_shields` is `free_hit`-only. |
| `ninth-bend` | *"After nine slipped blows, the holder's next Water art deals heavy damage from behind and cannot be evaded."* | `water`, `elem`, `role: "damage"`, `tags: ["cold", "step"]`, `c_art: 1.5`, `cost_share: 0.04`, `cd: 4.0`; `art_fired` grants `+12 evade` `3.5 s`; `evaded` builds `nine_bend` -> at 9 clears & arms `ninth_bend_ready` for next damaging Water art (`dmg_more: 1.0, acc: 500`). | Dropped *"from behind"* (no spatial fight); added `+12 evade` `3.5 s` on cast to supply the evade loop after omitting `swallow-stance` (§A #1). |

---

## §D Effects (`effects/lang_dao.effects.json`)

| Name | Source Item / Set | Depth text vs Engine form | Deviation |
|---|---|---|---|
| `Pay the Toll` | `ld-nine-bend-toll-seal` | First Water `art_fired` (`per_fight: 1`) sets `tolled = 1`. `was_hit` & `evaded` (`kind: "art"`, `per_pulse: 1`) drain `0.02` foe `qi_max` (`burn_qi of: "max", to_self: 1.0`) up to 5 tolls (`0.10`); at 5 flips `tolled = 0, toll_pass = 1` (`always` `dampen_taken: 11.11` = `-10 %` damage taken). | Uses `was_hit` + `evaded` (`kind: "art"`, `per_pulse: 1`) because no foe `art_fired` event exists. |
| `The Boat That Did Not Burn` | `ld-last-white-sail` | Standing Sail/Flag charge: `always` `dampen_taken: 100, resist: 200 [dtype: fire]`; `tick_taken` (`element: "fire"`) marks `sail_burn_tick` (`each_for: 2, cap: 1`); `on: "down"` (`per_fight: 1`) when `sail_burn_tick >= 1` or `own.debuff.fire >= 1` runs `refuse_down` (leaves `1` HP). | Sail charge standing while worn (base `ky` has no Flag art); `resist 200` approximates burn-tick halving since `defend()` does not apply `dampen_taken` to ticks. |
| `Round the Bend, Then the Anchor` | `ld-nine-landings` (3-pc) | On `evaded`: if `tolled >= 1`, drains `0.02` foe `qi_max` + adds `toll_paid` (flips `toll_pass` at 5); increments `anchor_bend` -> at 9 clears, sets `mod {bypass: 0.5, pen: 150}` and fires `free_hit {c: 1.8, dtype: "cold"}`. | Independent `anchor_bend` counter avoids double-counting with `ninth-bend`; *"ignores half the foe's ward"* uses `bypass 0.5` + `pen 150`. |

---

## §E Items and Sets (`items/catalogue-sect-lang_dao.json`, `items/sets-lang_dao.json`)

- **4 items** (`ld-nine-bend-toll-seal` treasure `rarity: 5` + R6 exception; `ld-last-white-sail` artifact grade 3 `ky`; `ld-first-fleet-anchor` artifact grade 3 `mao` + R6 exception; `ld-ferry-master-oilskin` artifact grade 3 `giap` + R6 exception). All `sources: ["npc"]`, `unique: true`, modifiers matching `lang_dao.items.json` verbatim.
- **1 set** (`ld-nine-landings`: 2-pc `attack_pct 8 [thuy]`, `evade_pct 3`; 3-pc `Round the Bend, Then the Anchor`).

---

## §F Holder Table (`sect_fight.py lang_dao --seeds 5`, post-edit)

All 18 living cast members ran with **0 REFUSED** and every slotted art fired:

| Holder | Realm | Arts | Gap 0 (`mean_s, wins/5, hp_left`) | Gap 1 (`mean_s, wins/5, hp_left`) | Effects (`with / without`, `runs` gap 0 / gap 1) |
|---|---|---|---|---|---|
| `giang_cuu_khuc` | `ket_dan` | `gathering-wave`, `a-thousand-washings`, `drag-of-the-deep`, `ninth-bend`, `backwash-seal` | `11.4 s, 5/5, 100%` | `24.8 s, 0/5, 0%` | `Pay the Toll`: `11.4 vs 13.1 s` (`runs 26`) / `24.8 vs 15.6 s` (`runs 26`); `Round the Bend`: `11.4 vs 11.7 s` (`runs 27`) / `24.8 vs 25.0 s` (`runs 69`) |
| `thuong_bach_pham` | `ket_dan` | `gathering-wave`, `a-thousand-washings`, `drag-of-the-deep`, `ninth-bend` | `22.5 s, 5/5, 100%` | `12.9 s, 0/5, 0%` | `The Boat That Did Not Burn`: `runs 0` vs `typical` (no Fire/Burn; `always` counts 0). Fire-Burn probe: `22.0 s` (`burn_mark 67`, `refused` at `1` HP) vs `13.4 s` without |
| `giang_hoi_lan` | `truc_co` | `gathering-wave`, `a-thousand-washings`, `drag-of-the-deep`, `backwash-seal` | `16.8 s, 5/5, 100%` | `8.6 s, 0/5, 0%` | — |
| `tiet_an_thuy` | `truc_co` | `gathering-wave`, `a-thousand-washings`, `drag-of-the-deep`, `backwash-seal` | `16.8 s, 5/5, 100%` | `8.6 s, 0/5, 0%` | — |
| `lai_bat_khuc` | `truc_co` | `gathering-wave`, `a-thousand-washings`, `drag-of-the-deep`, `ninth-bend` | `20.5 s, 5/5, 99%` | `10.5 s, 0/5, 0%` | — |
| `sai_ket_lam`, `thuong_thien_dao`, `uc_lang_hoa` | `truc_co` | `gathering-wave`, `a-thousand-washings`, `drag-of-the-deep` | `34.2 s, 4/5, 60%` | `8.7 s, 0/5, 0%` | — |
| `le_tieu_pham`, `ma_truong_cao`, `dong_cuu_mon`, `to_lenh_chu`, `ngo_da_do` | `luyen_khi` | `gathering-wave`, `a-thousand-washings` | `30.8 s, 0/5, 0%` | `8.0 s, 0/5, 0%` | Earth main at L2-3 vs `typical` Luyện Khí |
| `thach_thap_dinh`, `bo_tay_sa`, `uc_tieu_bong` | `luyen_khi` | `pole-vault`, `rooted-form` | `60.4 s, 5/5, 90%` | `13.1 s, 0/5, 0%` | `pole-vault` `13.6` fires (`24` banks in seed 1) |
| `giang_tieu_loan`, `ky_chu_nhi` | `luyen_khi` | `pole-vault`, `rooted-form` | `60.8 s, 5/5, 87%` | `13.1 s, 0/5, 0%` | `pole-vault` `13.8` fires |

**Targeted Probes (post-edit):**
- `The Boat That Did Not Burn` (`thuong_bach_pham` vs Fire-Burn foe): `22.0 s` (`burn_mark: 67`, `down` `refused` at `21.72 s` leaving `1` HP) vs `13.4 s` without.
- `Ninth Bend` + `Round the Bend` (`giang_cuu_khuc` vs 40% evade foe): `ninth-bend-count: 13`, `ninth-bend-arm: 1`, `ninth-bend-unleash: 1`, `Anchor:count: 13`, `Anchor:drop: 1`.
- `Pay the Toll` standalone (`ld-nine-bend-toll-seal` without set vs fast-cast foe): `stamp: 1`, `hit: 5`, `hit_pass: 1`.

---

## §G Open Items (for serial step / Stage 7)
1. Serial merge of `design/stage6-staging/lang_dao/` into `design/` and `assets/data/combat_effects.json`, which also closes `loose-south`'s 2 cross-owner references (`trinh_tieu_do`, `yen_hoi_do` on `ferry-pole-primer`).
2. Stage 7 `export_named.py` `kind: "treasure"` support for `ld-nine-bend-toll-seal` and world export for `N-lang_dao-01`..`04`.

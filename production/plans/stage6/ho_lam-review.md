# Hộ Lâm Đường (`ho_lam`): Stage 6 review (2026-11-27)

## Summary

- **Built (staged under [design/stage6-staging/ho_lam/](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/ho_lam)):**
  - **Techniques (3):** `raft-and-root-primer` (Tier 0 main, Wood/Water), `night-beside-the-tree` (Tier 1 secret, Wood), `spring-flood-raft-art` (Tier 1 secret, Water) in [catalogue-sect-ho_lam.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/ho_lam/techniques/catalogue-sect-ho_lam.json).
  - **Arts (4 new):** `log-on-the-current`, `the-forest-listens`, `bark-closes`, `the-flood-takes-it` in [part-sect-ho_lam.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/ho_lam/arts/part-sect-ho_lam.json), with `"id"` fields inserted into [ho_lam.techniques.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/ho_lam.techniques.json).
  - **Effects (3):** `One Stroke`, `The Tree Did Not Answer`, `The Forest Closes` in [ho_lam.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/ho_lam/effects/ho_lam.effects.json).
  - **Items & Sets (4 items, 1 set):** `hlm-asking-axe`, `hlm-first-light-heart`, `hlm-lead-raft-banner`, `hlm-white-wax-robe` in [catalogue-sect-ho_lam.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/ho_lam/items/catalogue-sect-ho_lam.json) and `hlm-first-light` in [sets-ho_lam.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/ho_lam/items/sets-ho_lam.json).
  - **Stand-ins & Beasts:** `0` stand-ins (all 18 living members already use real techniques), `0` beasts.
- **Deviations (8):** logged in §§D–F below (all auto-accepted against Combat/Effects/Item DB rules).
- **Auto-accepted decisions:** stance coexistence on `bark-closes`, `foe_pressed` event-driven trigger on `the-forest-listens`, 3-Water-in-a-row streak counting & cooldown tuning on `the-flood-takes-it`, Composed reading on `One Stroke`, pendant-only heal cancellation on `The Tree Did Not Answer`, `mountain-cleave` trigger on `The Forest Closes`, R6 `exception` & `unique: true`, and `water` -> `thuy` scope fix on `hlm-lead-raft-banner`.
- **Pending words:** none (all records run with existing engine vocabulary).
- **Never ran in `sect_fight.py` (with reasons):**
  - `The Forest Closes` (`runs 0` in `sect_fight.py` at `--gap 0` and `--gap 1`): `sect_fight.py` fills all 6 of `luc_thanh_sam`'s art slots from his two techniques (`verdant-cycle-scripture` 4 + `night-beside-the-tree` 2 = 6), so `hlm-asking-axe`'s base common art `mountain-cleave` is not slotted in the generated build. Verified by targeted probe (`luc_axe_gap0`: `brace: 10`, `regen: 50`, `thorns: 75`).
  - `The Tree Did Not Answer` (`runs 0` at `--gap 0` only): `luc_thanh_sam` wins `--gap 0` at `100 %` HP without reaching Down. Verified at `--gap 1` (`runs 5`, extending fight from `16.0 s` to `18.0 s`).
- **Early promotions:** none (`phu_hau_tho`'s `seed-and-soil-primer` is already committed under `thuy_vi` in [catalogue-sect-thuy_vi.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/techniques/catalogue-sect-thuy_vi.json)).
- **Open items (for serial step / Stage 7+):**
  - Serial step: merge [ho_lam.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/ho_lam/effects/ho_lam.effects.json) via `put_effects.py` into `assets/data/combat_effects.json` and promote the staged technique, art, item, and set files into `design/`.
  - Stage 7/8: structured events `N-ho_lam-01..04`, and `world_continent.json` re-lean `["Wood", "Water"]` (`N-ho_lam-04` / R4).

## A. Auto-accepted decisions (with reasons)

1. **Non-masking stance guard on `bark-closes` (`night-beside-the-tree`):** Every holder of `night-beside-the-tree` (`luc_thanh_sam`, `mi_tuc_thu`, `lai_hoanh_chi`, `thieu_tung_lam`) also carries `rooted-form` (`rooted`). Setting a separate stance unconditionally would overwrite `rooted` and mask `rooted-creep`/`rooted-sap`. Guarding `"state": {"set": "bark-closes"}` on `own.state.any == 0` while running the 4 s `dampen_taken: 25`, `no_evade: 1`, and `heal {share: 0.02}` via `bark_sec` leaves `rooted` intact for dual-technique holders while still giving standalone holders the `composed` `bark-closes` stance.
2. **Event-driven "pressed" check on `the-forest-listens`:** `own.foe_pressed` on `pulse` checks `self.t - o.t_act < 1000 ms`, which evaluates to `0` against any foe whose arts land on integer seconds (including `typical`). Triggering on `was_hit` (`kind: art`), `evaded` (`kind: art`), and `was_evaded` (`limit: {per_pulse: 1}`) catches every enemy art and evade reliably during the 6 s window.
3. **Water streak counting & cooldown on `the-flood-takes-it`:** Basic attacks (`element: ""`) fire every `1.0 s`, so "struck with Water three times in a row" must count art hits (`kind: art, element: water`, `per_firing: 1`) and reset on non-Water art hits (`kind: art, not_tags: ["water"]`). Setting `cooldown: 2.5, c_art: 1.5` (from `4.0` s) lets `dang_bich_luu` and `do_xuan_trieu` land 3 Water arts in a row before `seed-of-spring` (`5.0 s`) resets the streak, while staying under the art lint (`1.63`). "Breaks the foe's guard" maps to `exposed` (`-100` all resistances for `3 s`), matching `thien_xu`'s `the-seventh-star-falls`.
4. **`One Stroke` ("have not moved for 2 s") read as Composed:** At `t = 0`, `own.composed` is `0` until `2 s` pass without acting (`composed_after = 2.0`), while arts and basics hit before `t = 2.0`. Reading `One Stroke` as "first Composed hit each fight" preserves the `2 s` stillness requirement and fires cleanly at `t = 2.0 s` (`5` runs on `luc_thanh_sam`).
5. **`The Tree Did Not Answer` ("the pendant gives no healing"):** Cancels the pendant's own `+12 % healing` and `+36 % health_regen_inc` (`mod {healing: -12, hregen_inc: -36}` while `heartwood_spent >= 1`), matching the studio pattern in `Grown, Not Made` rather than blocking all external healing.
6. **`The Forest Closes` ("after each axe stroke"):** Triggers on `art_fired` for `mountain-cleave` (`phu` base common art). `heal {share: 0.02}` on `pulse` delivers the `2 %` HP/s regeneration cleanly.
7. **R6 `exception`, `unique: true`, `rarity: 5`, and `thuy` scope:** Auto-accepted per standing rulings R6 and rule 20f (`hlm-asking-axe` and `hlm-white-wax-robe` carry `exception`, all 4 items carry `sources: ["npc"]` and `unique: true`, treasure `hlm-first-light-heart` carries `rarity: 5`, and `hlm-lead-raft-banner` uses `"thuy"` instead of `"water"` in its modifier scope).

## B. Pending words

None.

## C. Techniques (`catalogue-sect-ho_lam.json`)

Depth proposals list no bonuses or passives; all bonuses and passives below are **new**, sized against the same-tier catalogue techniques (`seed-and-soil-primer`, `clear-frost-breath`, `haze-walk`, `returning-wake-verse`).

| Technique | Tier, kind | Bonuses *(new)* | Passives *(new)* | Arts (unlock layer) |
|---|---|---|---|---|
| `raft-and-root-primer` | Tier 0 main, `["moc", "thuy"]` | none (`bonus_count 0`) | `khi_huyet_pct` 4, `health_regen_inc_pct` 6, `linh_luc_regen_inc_pct` 3, `stack_duration_pct` 4 `["moc"]` (`7.7 W` of `8`) | `rooted-form` (1), `log-on-the-current` (2) |
| `night-beside-the-tree` | Tier 1 secret, `["moc"]` | `khi_huyet_pct` 10 (`bonus_count 1`) | `accuracy_pct` 6, `health_regen_inc_pct` 8, `healing_pct` 6, `stack_effect_pct` 8 `["moc", "debuff"]` (`10.4 W` of `16`) | `second-spring` (1), `the-forest-listens` (2), `bark-closes` (3) |
| `spring-flood-raft-art` | Tier 1 secret, `["thuy"]` | `linh_luc_pct` 12 (`bonus_count 1`) | `art_speed_pct` 7 `["thuy"]`, `attack_pct` 5 `["thuy"]`, `linh_luc_regen_inc_pct` 3 (`8.5 W` of `16`) | `swelling-tide-palm` (1), `the-flood-takes-it` (2) |

## D. Arts (`part-sect-ho_lam.json`)

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `log-on-the-current` | A heavy Wood hit: the foe's soonest art waits 0.5 s; if a Water stack is on you, the hit carries on and strikes the foe again at half. | Wood elem, `c_art: 3.0`, `cost_share: 0.05`, `cd: 5.0`, `tags: ["wood", "heavy"]`; `hit_landed` (`per_pulse: 1`): `timer {side: foe, which: next, by: 0.5}`; `empower` on `own.buff.water >= 1`: `split: [1.0, 0.5]`. | None. |
| `the-forest-listens` | For 6 s your next art against the foe cannot miss, and a foe who pressed while it lasts takes a Wood stack. | Wood elem, `c_art: 0.0`, `cost_share: 0.03`, `cd: 8.0`, `tags: ["wood", "seal"]`; `art_fired` sets `forest_listens_sec = 6, forest_listens_sure = 1`; next damaging art (`not_art_id`, `own.since_act <= 0`) grants `mod {acc: 500}` and clears `sure`; while `sec >= 1`, `was_hit`/`evaded` (`kind: art`) and `was_evaded` (`per_pulse: 1`) lay 1 Wood debuff (`8 s`). | **Deviation 1:** uses `was_hit`/`evaded`/`was_evaded` instead of `pulse` `own.foe_pressed` so integer-second foe arts trigger reliably. |
| `bark-closes` | Wraps you in bark for 4 s: you take 25 % less damage, heal a little each second; your evade is 0 and you cannot be Pressing. | Wood elem, `c_art: 0.0`, `cost_share: 0.04`, `cd: 8.0`, `tags: ["wood", "stance", "ward"]`; `art_fired` sets `bark_sec = 4` (and enters `composed` stance `bark-closes` if `own.state.any == 0`); `always` while `bark_sec >= 1`: `dampen_taken: 25, no_evade: 1`; `pulse`: `heal {share: 0.02}` and `add: -1`; exits `bark-closes` when `bark_sec == 0`. | **Deviation 2:** stance entry guarded on `own.state.any == 0` so `rooted-form` is never overwritten/masked. |
| `the-flood-takes-it` | A Water hit: the foe's soonest art waits 0.3 s and it lays 2 Slowed Time; if you have struck with Water three times in a row, it also breaks the foe's guard. | Water elem, `c_art: 1.5`, `cost_share: 0.04`, `cd: 2.5`, `tags: ["water", "cold"]`, `statuses: [{id: slowed_time, stacks: 2, dur: 3}]`; `hit_landed`: `timer {side: foe, which: next, by: 0.3}`; `water_streak` +1 on Water `art` hit (`per_firing: 1`), reset on `not_tags: ["water"]` `art` hit, at `>= 3` lays `exposed` (`3 s`) and resets. | **Deviation 3:** basic attacks ignored by streak; guard break = `exposed` (`3 s`); `cd 2.5` (`c_art 1.5`) so 3-in-a-row lands between Wood arts. |

## E. Effects (`ho_lam.effects.json`)

| Effect (source) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `One Stroke` (`hlm-asking-axe`) | Your first hit on a foe each fight deals 30 % more damage if you have not moved for the 2 s before it. | `always` while `one_stroke_done == 0` and `own.composed >= 1`: `mod {dmg_more: 0.3}`; `hit_landed` under same conditions sets `one_stroke_done = 1`. | **Deviation 4:** reads as first Composed hit (`own.composed >= 1`), since `t = 0` starts with `composed == 0`. |
| `The Tree Did Not Answer` (`hlm-first-light-heart`) | Once a fight, when you would take a killing blow, the heartwood takes it instead and you are left at a tenth of your health. After that the pendant gives no healing for the rest of the fight. | `down` (`per_fight: 1`): `refuse_down {hp_share: 0.1}`, `heartwood_spent = 1`; `always` while `heartwood_spent >= 1`: `mod {healing: -12, hregen_inc: -36}`. | **Deviation 5:** removes the pendant's own healing modifiers (`healing -12`, `hregen_inc -36`) rather than zeroing all character healing. |
| `The Forest Closes` (`hlm-first-light` 3-pc) | after each axe stroke you brace: your evade is 0 for 6 s, you regenerate 2 % of your health each second, and the foe that hits you gains a Wood stack. | `art_fired` (`art_id: "mountain-cleave"`): `forest_closes_sec = 6`; `always` (`sec >= 1`): `mod {no_evade: 1}`; `pulse` (`sec >= 1`): `heal {share: 0.02}`, `add: -1`; `was_hit` (`sec >= 1`, `per_pulse: 2`): 1 Wood debuff (`8 s`). | **Deviation 6:** "axe stroke" triggers on `phu` common art `mountain-cleave`. |

## F. Items & Sets (`catalogue-sect-ho_lam.json`, `sets-ho_lam.json`)

- **4 items, 1 set (`hlm-first-light`):**
  - `hlm-asking-axe` (`phu`, grade 3, `sources: ["npc"]`, `unique: true`, R6 `exception`, `30.0 W of 38.4`, Effect `One Stroke`)
  - `hlm-first-light-heart` (`ngoc_boi`, `treasure`, grade 4 / **`rarity: 5`**, `sources: ["npc"]`, `unique: true`, `30.8 W of 51.2`, Effect `The Tree Did Not Answer`) — **Deviation 8** (`rarity: 5`, `unique: true`, R6 `exception` on axe & robe).
  - `hlm-lead-raft-banner` (`ky`, grade 3, `sources: ["npc"]`, `unique: true`, `27.1 W of 38.4`, modifiers `attack_pct 14 [thuy]`, `art_speed_pct 8 [thuy]`, `linh_luc_regen_inc_pct 12`, `stack_grant 1 [thuy, buff]`) — **Deviation 7** (`"water"` -> `"thuy"` scope to match `lint_techniques.py` / `lint_items.py` Modifier tag vocabulary).
  - `hlm-white-wax-robe` (`dao_bao`, grade 3, `sources: ["npc"]`, `unique: true`, R6 `exception`, `27.7 W of 38.4`)
  - `hlm-first-light` (3-piece set): 2-pc `health_regen_inc_pct 15`, `khi_huyet_pct 6`; 3-pc Effect `The Forest Closes`.

## G. Stand-ins & Beasts

- **0 stand-ins:** All 18 living members in [ho_lam.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/ho_lam.cast.json) and [ho_lam.5.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/ho_lam.5.cast.json) already hold real techniques (`verdant-cycle-scripture`, `raft-and-root-primer`, `seed-and-soil-primer`).
- **`phu_hau_tho` (`seed-and-soil-primer`):** Already committed under `thuy_vi` ([catalogue-sect-thuy_vi.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/techniques/catalogue-sect-thuy_vi.json)); no duplicate or edit to `thuy_vi` files.
- **0 beasts.**

## H. Holder check (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\ho_lam`)

### Linters
- `python -I tools/design/arts/lint_arts.py design/stage6-staging/ho_lam/arts/part-sect-ho_lam.json`: `checked 4 arts in 1 files, 0 findings` (`log-on-the-current empower 1: x1.41 of the lint, gated`).
- `python -I tools/design/arts/lint_techniques.py design/stage6-staging/ho_lam/techniques/catalogue-sect-ho_lam.json`: `checked 3 techniques, 0 findings`.
- `python -I tools/design/items/lint_items.py design/stage6-staging/ho_lam/items/catalogue-sect-ho_lam.json`: `checked 4 items, 22 bases, 9 common arts, 0 findings`.

### `sect_fight.py ho_lam --seeds 5` (`--gap 0` and `--gap 1`)

| Holder | Realm | Arts (fires/fight @ gap 0) | Gap 0 (`mean_s`, `win`, `hp`) | Gap 1 (`mean_s`, `win`, `hp`) | Effects (`with` vs `without`, `runs`) |
|---|---|---|---|---|---|
| `luc_thanh_sam` | `ket_dan` | `seed-of-spring` (3.0), `rooted-form` (2.0), `second-spring` (0.0), `harvest-bloom` (2.0), `the-forest-listens` (1.0), `bark-closes` (1.0) | `15.7 s`, `5/5`, `100 %` | `18.0 s`, `0/5`, `0 %` | `One Stroke`: `15.7 s` vs `15.7 s` (`runs 5` @ gap 0, `5` @ gap 1); `The Tree Did Not Answer`: `runs 0` @ gap 0 (100% HP), `18.0 s` vs `16.0 s` (`runs 5` @ gap 1); `The Forest Closes`: `runs 0` (see probe) |
| `dang_bich_luu` | `ket_dan` | `seed-of-spring` (2.0), `rooted-form` (1.6), `second-spring` (0.2), `harvest-bloom` (1.2), `swelling-tide-palm` (2.6), `the-flood-takes-it` (4.6) | `11.6 s`, `5/5`, `100 %` | `14.4 s`, `0/5`, `0 %` | — |
| `do_xuan_trieu` | `truc_co` | `seed-of-spring` (2.2), `rooted-form` (2.0), `second-spring` (0.2), `swelling-tide-palm` (3.0), `the-flood-takes-it` (6.0) | `15.2 s`, `5/5`, `100 %` | `8.7 s`, `0/5`, `0 %` | — |
| `lai_hoanh_chi` | `truc_co` | `seed-of-spring` (3.0), `rooted-form` (2.0), `second-spring` (0.2), `harvest-bloom` (2.0), `the-forest-listens` (1.0), `bark-closes` (1.0) | `15.6 s`, `5/5`, `100 %` | `14.4 s`, `0/5`, `0 %` | — |
| `mi_tuc_thu` | `truc_co` | `seed-of-spring` (3.0), `rooted-form` (2.0), `second-spring` (0.2), `harvest-bloom` (2.0), `the-forest-listens` (1.0), `bark-closes` (1.0) | `15.6 s`, `5/5`, `100 %` | `14.4 s`, `0/5`, `0 %` | — |
| `thieu_tung_lam` | `truc_co` | `seed-of-spring` (4.0), `rooted-form` (3.4), `second-spring` (0.2), `the-forest-listens` (2.4), `bark-closes` (2.4) | `23.9 s`, `5/5`, `99 %` | `14.0 s`, `0/5`, `0 %` | — |
| `sam_lang_nhi` | `luyen_khi` | `rooted-form` (7.2), `log-on-the-current` (7.8) | `55.0 s`, `5/5`, `90 %` | `15.0 s`, `0/5`, `0 %` | — |
| `tac_ha_thang` | `luyen_khi` | `rooted-form` (7.2), `log-on-the-current` (7.8) | `55.0 s`, `5/5`, `90 %` | `15.0 s`, `0/5`, `0 %` | — |
| `truc_linh_lo` | `luyen_khi` | `rooted-form` (7.2), `log-on-the-current` (7.8) | `55.0 s`, `5/5`, `90 %` | `15.0 s`, `0/5`, `0 %` | — |
| `binh_thiet_phu` | `luyen_khi` | `rooted-form` (8.8) | `65.0 s`, `5/5`, `57 %` | `15.2 s`, `0/5`, `0 %` | — |
| `to_mieu_nhi` | `luyen_khi` | `rooted-form` (8.8) | `64.8 s`, `5/5`, `59 %` | `15.2 s`, `0/5`, `0 %` | — |
| `phan_tieu_ho` | `luyen_khi` | `rooted-form` (8.8) | `65.0 s`, `5/5`, `57 %` | `15.2 s`, `0/5`, `0 %` | — |
| `phu_hau_tho` | `luyen_khi` | `seed-of-spring` (5.0), `furrow-palm` (6.2) | `25.8 s`, `5/5`, `100 %` | `8.1 s`, `0/5`, `0 %` | — |

### Targeted probes (`--seeds 5`)
- `luc_axe_gap0` (`luc_thanh_sam` with `mountain-cleave` slotted): `15.2 s`, `5/5` wins, `100 %` HP; `The Forest Closes brace: 10`, `regen: 50`, `thorns: 75`, `One Stroke spend: 5`, `forest-listens-sure: 5`, `forest-listens-press-hit: 15`, `bark-closes-pulse: 20`, `rooted-creep: 30` (Rooted Form unmasked).
- `luc_axe_gap1`: `17.6 s`, `0/5` wins; `The Tree Did Not Answer: 5`, `The Forest Closes brace: 5`.
- `sam_water_buff` (`sam_lang_nhi` + `deep-lake-stance`): `37.4 s`, `5/5` wins, `77 %` HP; `('empowered', 'log-on-the-current'): 2` on seed 1.
- `dang_bich_luu_gap0` & `do_xuan_trieu_gap0`: `flood-streak-break: 9` (`11.6 s`, `5/5` wins) and `flood-streak-break: 10` (`15.2 s`, `5/5` wins).
- `nbt_standalone` (no `rooted-form`, foe `evade_pct: 30`): `47.6 s`, `5/5` wins, `87 %` HP; `bark-closes-enter: 18`, `bark-closes-exit: 17`, `bark-closes-pulse: 71`, `forest-listens-press-hit: 62`, `forest-listens-press-foe-evade: 35`, `forest-listens-sure: 22`.

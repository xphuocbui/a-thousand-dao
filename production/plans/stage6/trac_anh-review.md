# Stage 6 Record Pass Review — `trac_anh` (Trạc Anh Đài)

## Summary

- **What was built (staged under [design/stage6-staging/trac_anh/](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/trac_anh)):**
  - **Techniques (2):** staged in [catalogue-sect-trac_anh.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/trac_anh/techniques/catalogue-sect-trac_anh.json) — `canglang-body-canon` (Profound `body`, `names: []`) and `whale-line-harpoon` (Profound `secret`, `names: []`).
  - **Arts (5 new):** staged in [part-sect-trac_anh.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/trac_anh/arts/part-sect-trac_anh.json) — `wash-the-hat-strings`, `wash-the-feet`, `ninth-fathom` (`canglang-body-canon`), and `throw-the-iron`, `haul-in` (`whale-line-harpoon`). Art IDs inserted in place in [trac_anh.techniques.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/trac_anh.techniques.json).
  - **Effects (2):** staged in [trac_anh.effects.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/trac_anh/effects/trac_anh.effects.json) — `The Line Holds` (`ta-canglang-harpoon`) and `Drag It to the Ice` (`ta-old-ivory-hunt` 3-piece set). Both declare every counter they read/write and pass standalone `engine.validate()`.
  - **Items (4) & Sets (1):** staged in [catalogue-sect-trac_anh.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/trac_anh/items/catalogue-sect-trac_anh.json) and [sets-trac_anh.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/stage6-staging/trac_anh/items/sets-trac_anh.json) (`sources: ["npc"]`, `unique: true`, R6 `exception` on `ta-canglang-harpoon` and `ta-white-whale-coat`, `rarity: 4` on treasure `ta-goose-bone-beads`).
- **Stand-ins:** `0` (all 18 living cast members already carry real techniques).
- **Beasts:** `2` (`lang_nhi`, `tiem_nhi`), already wired on owner `doan_to_ba` (`"beasts": ["lang_nhi", "tiem_nhi"]` in [trac_anh.cast.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/trac_anh.cast.json), matching `than_hon: 54` capacity 2; beast records in [trac_anh.beasts.json](file:///C:/Users/xphuo/IdeaProjects/my-game/design/world/depth/sects/trac_anh.beasts.json) close at Stage 7 export).
- **Deviations:** `4` logged across records (details in §D–§E).
- **Auto-accepted decisions:** `6` (logged in §A with reasons).
- **Pending words:** `0` (all mechanics run on existing Stage 5 + Stage 6 engine words).
- **Never ran in `sect_fight.py`:** `0` — all 5 arts fired (`>= 1.0` fires/fight) in both `--gap 0` and `--gap 1`, and both Effects ran on `doan_thanh_lang` (`The Line Holds`: `182` runs at gap 0 / `25` at gap 1; `Drag It to the Ice`: `137` runs at gap 0 / `27` at gap 1).
- **Early promotions:** `0`.
- **Open items (for serial / Stage 7):**
  - Serial merge & export (`stage6_merge.py`, `export_techniques.py`, `export_named.py`, `export_combat_library.py`, `compile_parity_export.py`, `export_world.py --sect trac_anh`) to close `techniques` (2), `arts_new` (5), `items` (4), `sets` (1), `effects` (2), `beasts` (2), and `events` (2 structured).

---

## A. Auto-Accepted Decisions (with Reasons)

1. **Keep `names: []` on element-free `secret` method `whale-line-harpoon` (matching `canglang-body-canon`):**
   - *Reason:* Batch `b02` (`lint-element-free-techniques`) updated `lint_techniques.py` so authored `main`/`secret` methods whose carried abilities all have `element == ""` may use `"names": []` cleanly with `0` findings. Both `canglang-body-canon` (`body`) and `whale-line-harpoon` (`secret`) carry element-free `phys` arts only.
2. **Size `canglang-body-canon` and `whale-line-harpoon` bonuses and passives to Profound (tier 1) budget (`<= 16.0 W`, unpriced):**
   - *Reason:* Depth text gives no bonuses or passives. `canglang-body-canon` takes `khi_huyet_pct 12` (`bonus_count: 1`) and passives `health_regen_inc_pct 12`, `resist_pct 75 [cold]`, `body_shield_pct 8`, `status_resist_pct 8`, `defense_pct 3` (`15.9 W` of `16.0 W`). `whale-line-harpoon` takes `attack_pct 8` (`bonus_count: 1`) and passives `attack_pct 6 [physical]`, `pierce_pct 4`, `status_duration_pct 12 [curse]`, `art_speed_pct 5 [physical]` (`14.8 W` of `16.0 W`).
3. **Set `ninth-fathom` `unlock_layer: 6` (with `1, 2, 6` on `canglang-body-canon`) and `cooldown: 6.0`:**
   - *Reason:* `lint_techniques.py` rejects any suite art with `unlock_layer > 6` (`UNLOCK`, so a Trúc Cơ cultivator can access the whole suite), and `trac_anh`'s highest holder (`doan_thanh_lang`) is at layer 7. Setting `unlock_layer: 6` keeps the suite lint-clean and unlocks `ninth-fathom` for L6+ holders (`doan_thanh_lang`, `phi_nhan_tam`, `doan_to_ba`, `ngac_hai_tieu`). Guarded once-per-fight (`ninth_fathom_used == 0`), `cooldown: 6.0` ensures it fires once in both `--gap 0` and `--gap 1` fights (`1.0` fires/fight).
4. **Non-spatial rewrite of `throw-the-iron` (`Bound` 3 s + `Slowed Time` 2 s) and `haul-in` (avoiding `"haul"`/`"pins"`/`"ranged"`/`"movement"`):**
   - *Reason:* Under the 2026-11-26 no-spatial-fight ruling, `"pins"` / `"cannot flee"` maps to the `bound` curse (`3 s`, `Slowed Time` `2 s`, total `lint_arts` charge `0.50` allowing `c_art 1.35` on `4.0 s` cooldown so Bound holds steadily). `haul-in` (`c_art 2.2`, `cooldown 5.0`) uses `empower` on `foe.status.bound >= 1` (`timer {side: "foe", which: "next", by: 0.3}`, `c_mult 1.6`) plus a `line_held` pulse counter scaling `dmg_more 0.15` via `tags: ["haul_in"]` (never filtering `temp_mods` by `art_id`), and rewords `"hauls"` in `rule` to `"tightens the harpoon line"` so `spatial_words_check.py` passes cleanly.
5. **Split `wash-the-hat-strings` into two `art_fired` records and implement `wash-the-feet` / `ninth-fathom` with `was_hit` refunds:**
   - *Reason:* Emitting two `mod` actions (`hregen 0.025` and `dampen_taken 100 [dtype: cold]`) in separate records avoids the multi-`mod` clobber bug. On `wash-the-feet`, ordering `convert` before `arm` on `was_hit` (`event.amount > 0`) turns the second damaging hit into `body_bar` (`heal {of: "amount", share: 1.0, ignore_taken: true}` + `body_shield: true`) and exits the stance (`state {set: null}`). On `ninth-fathom`, an exact-millisecond `each_for: 1.0` counter (`ninth_fathom_sec`) paired with `dampen_taken 10000` and `was_hit`/`tick_taken`/`soul_taken` refunds gives true 1 s zero-net-damage invulnerability across pulse boundaries.
6. **Add `"rarity": 4` on treasure `ta-goose-bone-beads`, `"unique": true` / `sources: ["npc"]` on all 4 items, R6 `exception` on `ta-canglang-harpoon` (`mao`) and `ta-white-whale-coat` (`giap`), and split `"Drag It to the Ice"` rule out of the set's `effect` name:**
   - *Reason:* `lint_items.py` requires `rarity` 4–5 on `treasure` records (`grade: 3` -> `rarity: 4`); `mao` (`weapon`) and `giap` (`body_gear`) require R6 `exception` notes; splitting `effect` and `rule` in `sets-trac_anh.json` matches `sets-bang_tam.json` and keeps `Drag It to the Ice`'s `rule` text free of spatial verbs.

---

## B. Pending Words

None (`0` pending words; no `pending.json`).

---

## C. Techniques (`design/stage6-staging/trac_anh/techniques/catalogue-sect-trac_anh.json`)

| Technique | Tier, kind | Bonuses (new) | Passives (new, sized to tier, unpriced) | Arts (unlock layer) |
|---|---|---|---|---|
| `canglang-body-canon` | Profound (1), `body`, `names: []` | `khi_huyet_pct` 12 | `health_regen_inc_pct` 12, `resist_pct` 75 `[cold]`, `body_shield_pct` 8, `status_resist_pct` 8, `defense_pct` 3 (`15.9 W` of `16`) | `wash-the-hat-strings` (1), `wash-the-feet` (2), `ninth-fathom` (6) |
| `whale-line-harpoon` | Profound (1), `secret`, `names: []` | `attack_pct` 8 | `attack_pct` 6 `[physical]`, `pierce_pct` 4, `status_duration_pct` 12 `[curse]`, `art_speed_pct` 5 `[physical]` (`14.8 W` of `16`) | `throw-the-iron` (1), `haul-in` (4) |

---

## D. Arts (`design/stage6-staging/trac_anh/arts/part-sect-trac_anh.json`)

| Art | Depth concept | Engine form | Deviation |
|---|---|---|---|
| `wash-the-hat-strings` | A breath held under pressure: for a few seconds the holder's health regenerates and cold damage taken is halved. | `role: heal`, `cost_share: 0.03`, `cd: 6.0`; two `art_fired` records grant `hregen: 0.025` (2.5 % HP/s) and `dampen_taken: 100 [dtype: cold]` for 4 s. | None. |
| `wash-the-feet` | A low, rooted stance after being hit: the next hit taken is turned into body shield. | `role: ward`, `cost_share: 0.04`, `cd: 6.0`; enters Composed stance `wash-the-feet` (`+10 block`); first damaging `was_hit` arms `wash_feet_armed = 1`, next damaging `was_hit` refunds `event.amount` (`ignore_taken: true`), adds `event.amount` to `body_bar` (`body_shield: true`), and exits the stance. | **Deviation 1:** removed spatial word `"rooted"`, and ends the stance after one hit conversion so the 6 s cooldown bounds it instead of converting every second hit indefinitely. |
| `ninth-fathom` | At the ninth layer, once a fight: the holder sinks into the stillness of deep water, takes no damage for 1 s and clears every slowing effect. | `role: ward`, `cost_share: 0.05`, `cd: 6.0`, `unlock_layer: 6`, guarded `ninth_fathom_used == 0`; clears `slowed_time` + `drunk`, grants `dampen_taken: 10000` for 1 s and arms `ninth_fathom_sec` (`each_for: 1.0`) to refund any remaining `was_hit`/`tick_taken`/`soul_taken` damage for 1 s. | **Deviation 2:** unlocks at layer 6 (not 9) to satisfy `lint_techniques` (`unlock_layer <= 6`) and reach L6–L7 holders; uses `"deep-water calm"` instead of `"stillness"`. |
| `throw-the-iron` | A ranged throw that pins the target: their movement and art speed fall while the line holds. | `role: curse`, `c_art: 1.35`, `cost_share: 0.04`, `cd: 4.0`; applies `bound` (3 s) and `slowed_time` (2 s) on hit. | **Deviation 3:** non-spatial rewrite (`"pins"` / `"movement"` -> `bound` + `slowed_time`). |
| `haul-in` | Makes the soonest art of a Bound foe wait 0.3 s and deals Physical damage scaled by how long the line held. | `role: damage`, `c_art: 2.2`, `cost_share: 0.05`, `cd: 5.0`, `tags: [physical, harpoon, haul_in]`; `empower` when `foe.status.bound >= 1` delays foe's next art `0.3 s` and sets `c_mult: 1.6`; `line_held` counts seconds Bound on `pulse` and scales `+15 % dmg_more` per second on `tags: ["haul_in"]`. | None (reworded `"haul"` in `rule` to `"tightens the harpoon line"` for `spatial_words_check`). |

---

## E. Effects (`design/stage6-staging/trac_anh/effects/trac_anh.effects.json`)

| Effect (source) | Depth rule | Engine form | Deviation |
|---|---|---|---|
| `The Line Holds` (`ta-canglang-harpoon`) | While a target is Bound by your Whale-Line Harpoon, your hits on it heal you for 3 % of the damage dealt. | `hit_landed` (`foe.status.bound >= 1`, `event.amount > 0`): `heal {of: "amount", share: 0.03}`. | None (`foe.status.bound` in 1v1 is the harpoon's Bind). |
| `Drag It to the Ice` (`ta-old-ivory-hunt` 3pc) | A foe Bound by your harpoon (it cannot flee); each second it stays Bound you heal 1 % of your health and it takes 4 % more Physical damage from you; the bonus lasts while the Bind holds and is lost when it ends. | `pulse` (`foe.status.bound == 0`): resets `ivory_bind = 0`; `pulse` (`foe.status.bound >= 1`): `heal {share: 0.01}` + `ivory_bind +1`; `always` (`foe.status.bound >= 1`, `ivory_bind >= 1`): scaled `dmg_more: 0.04 [dtype: phys]` per `ivory_bind`. | **Deviation 4:** `rule` reworded without `"drag"` (only the Effect's proper name `"Drag It to the Ice"` retains `"Drag"`). |

---

## F. Items, Sets, Stand-Ins & Beasts

- **Items (4, `catalogue-sect-trac_anh.json`):** `ta-canglang-harpoon` (`mao`, grade 3, `The Line Holds`, R6 `exception`), `ta-white-whale-coat` (`giap`, grade 3, R6 `exception`), `ta-goose-bone-beads` (`ngoc_boi`, treasure grade 3 / `rarity: 4`), `ta-sworn-ice-ring` (`nhan`, grade 3). All 4 carry `sources: ["npc"]`, `unique: true`, `arts: []`, and unchanged modifiers.
- **Sets (1, `sets-trac_anh.json`):** `ta-old-ivory-hunt` (`ta-canglang-harpoon`, `ta-white-whale-coat`, `ta-sworn-ice-ring`), 2pc `khi_huyet_pct 6` + `attack_pct 6 [physical]`, 3pc Effect `Drag It to the Ice (Duệ Thượng Băng)`.
- **Stand-ins:** `0` (`18/18` living cast members already carry real techniques).
- **Beasts:** `doan_to_ba` already carries `"beasts": ["lang_nhi", "tiem_nhi"]` (`than_hon: 54`, capacity 2); `trac_anh.beasts.json` closes when `export_world.py --sect trac_anh` runs in Stage 7.

---

## G. Holder & Probe Verification Table

### Linters & Checkers (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\trac_anh`)
- `lint_arts.py`: `checked 5 arts in 1 files, 0 findings` (`haul-in empower 1: x1.10 of the lint, gated`)
- `lint_techniques.py`: `checked 2 techniques, 0 findings` (`canglang-body-canon 15.9 W of 16`, `whale-line-harpoon 14.8 W of 16`)
- `lint_items.py`: `checked 4 items, 22 bases, 9 common arts, 0 findings` (`unique 4 of 4`)
- `depth_check.py --quiet`: `findings: none`
- Standalone `engine.validate()`: `The Line Holds` OK, `Drag It to the Ice` OK
- `spatial_words_check.py` on staged files: `0` non-soft hits in `techniques`, `arts`, `items`, `effects`; `1` false-positive on `sets-trac_anh.json` `.bonuses.effect` matching the proper Effect name `"Drag It to the Ice (Duệ Thượng Băng)"`.

### `sect_fight.py trac_anh --seeds 5` (`--gap 0` & `--gap 1` — 13/13 Authored-Kit Holders, 0 `REFUSED`)

| Holder | Realm | Slotted arts (Gap 0 fires/fight) | Gap 0 (`mean_s`, wins, HP) | Gap 1 (`mean_s`, wins, HP) | Effect runs (`with` vs `without`) |
|---|---|---|---|---|---|
| `doan_thanh_lang` | `ket_dan` | `wash-the-hat-strings` (8.8), `wash-the-feet` (5.8), `ninth-fathom` (1.0), `throw-the-iron` (7.6), `haul-in` (4.0), `seep-through-palm` (7.0) | `54.6 s`, `5/5`, `96 %` | `11.5 s`, `0/5`, `0 %` (all 6 arts fired `>= 1.0`) | `The Line Holds`: `182` runs (`54.6 s 96 %` vs `54.6 s 96 %`; `25` at gap 1); `Drag It to the Ice`: `137` runs (`54.6 s 96 %` vs `58.6 s 92 %`; `27` at gap 1) |
| `phi_nhan_tam` | `ket_dan` | `answering-palm` (7.8), `twin-shadow-fist` (2.8), `rolling-barrage-fist` (9.4), `wash-the-hat-strings` (3.4), `wash-the-feet` (3.0), `ninth-fathom` (1.0) | `23.7 s`, `5/5`, `93 %` | `9.2 s`, `0/5`, `0 %` (all 6 arts fired `>= 1.0`) | n/a |
| `doan_to_ba` | `truc_co` | `wash-the-hat-strings` (7.2), `wash-the-feet` (5.4), `ninth-fathom` (1.0), `throw-the-iron` (6.2), `haul-in` (4.0) | `44.3 s`, `0/5`, `0 %` | `10.7 s`, `0/5`, `0 %` (all 5 arts fired `>= 1.0`) | n/a (beasts `lang_nhi`, `tiem_nhi` not added by `sect_fight.py`) |
| `ngac_hai_tieu` | `truc_co` | `wash-the-hat-strings` (7.2), `wash-the-feet` (5.4), `ninth-fathom` (1.0), `throw-the-iron` (6.2), `haul-in` (4.0) | `44.3 s`, `0/5`, `0 %` | `10.7 s`, `0/5`, `0 %` (all 5 arts fired `>= 1.0`) | n/a |
| `dau_thuy_lang` | `truc_co` | `wash-the-hat-strings` (4.2), `wash-the-feet` (4.0), `answering-palm` (8.8), `twin-shadow-fist` (3.0) | `26.5 s`, `5/5`, `93 %` | `8.0 s`, `0/5`, `0 %` (all 4 arts fired `>= 1.0`) | n/a |
| `boc_kinh_thang` | `truc_co` | `wash-the-hat-strings` (6.8), `wash-the-feet` (5.2), `throw-the-iron` (6.2), `haul-in` (4.0) | `43.5 s`, `0/5`, `0 %` | `8.3 s`, `0/5`, `0 %` (all 4 arts fired `>= 1.0`) | n/a |
| `lo_chau_nuong`, `bao_thiet_thu` (2) | `truc_co` | `wash-the-hat-strings` (6.8), `wash-the-feet` (6.0) | `45.4 s`, `0/5`, `0 %` | `8.4 s`, `0/5`, `0 %` (both fired `1.0`) | n/a |
| `co_lang_hoa` | `luyen_khi` | `wash-the-hat-strings` (6.4), `wash-the-feet` (5.6), `throw-the-iron` (6.8) | `40.4 s`, `0/5`, `0 %` | `8.2 s`, `0/5`, `0 %` (all 3 fired `>= 1.0`) | n/a |
| `lam_nhan_thanh`, `nghe_tieu_lang`, `vu_bich_trieu` (3) | `luyen_khi` | `wash-the-hat-strings` (5.6), `wash-the-feet` (5.4) | `40.0 s`, `0/5`, `0 %` | `8.2 s`, `0/5`, `0 %` (both fired `1.0`) | n/a |

*(The remaining 5 outer disciples `tan_bach_au`, `dong_vong`, `quan_tieu_kinh`, `boc_hai_dong`, `kim_hai_yen`, `dong_thoa` — 6 Luyện Khí cultivators — carry committed `unbroken-flesh-canon`.)*

### Targeted Probes (10 seeds each)
- **`DOAN_GAP0_COUNTS` (`doan_thanh_lang` vs typical `ket_dan`):** `eff:The Line Holds` **329**, `eff:Drag It to the Ice:tick` **201**, `:clear` **42**, `haul-in-hold` **201**, `haul-in-clear` **42**, `haul-in-empower` **21**, `ninth-fathom-cast` **10**, `wash-the-feet-enter` **49**, `-arm` **49**, `-convert` **48**, `wash-the-hat-strings-regen` **82**, `-cold` **82**.
- **`PROBE_LINE_TOUGH` (`doan_thanh_lang` vs 2.5× HP Cold enemy):** full **6/10 wins, 14.5 % HP** vs without `The Line Holds` **6/10 wins, 14.4 % HP** vs without `Drag It to the Ice` **2/10 wins, 4.9 % HP**.
- **`PROBE_COLD_AND_FEET` (`bao_thiet_thu` vs Cold `truc_co` enemy):** full **10/10, 33.5 % HP** vs without `wash-the-hat-strings-cold` **10/10, 31.1 % HP** vs without `wash-the-feet` **10/10, 32.2 % HP** (`100` enter / `100` arm / `100` convert).
- **`PROBE_NINTH` (`doan_to_ba` vs `slowed_time` `truc_co` enemy):** with `ninth-fathom` **10/10 wins, 58.9 s, 57.7 % HP** vs without `ninth-fathom` **6/10 wins, 61.6 s, 20.0 % HP** (`10` casts).

REVIEW DONE

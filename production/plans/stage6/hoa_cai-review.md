# Stage 6 review: Hoa Cái Đường (`hoa_cai`)

All staged files live under `design/stage6-staging/hoa_cai/` and art `"id"` entries were inserted into `design/world/depth/sects/hoa_cai.techniques.json`. Decisions are auto-accepted under the 2026-11-26 rule and logged below.

## Summary

- **Built:**
  - `techniques/catalogue-sect-hoa_cai.json`: 4 techniques (`cinnabar-washing-primer`, `canopy-furnace-canon`, `nine-cycle-mercury-art`, `sulphur-lung-breath`).
  - `arts/part-sect-hoa_cai.json`: 5 new active arts (`pan-the-grains`, `spread-the-canopy`, `lift-the-lid`, `quicksilver`, `hold-the-fume`); `canopy-furnace-canon` also carries `pill-smoke` at layer 4, which already exists in `design/arts/part-sect-market-folk.json` (`element: ""`).
  - `items/catalogue-sect-hoa_cai.json`: 5 signature items (`hc-nine-cycle-gourd`, `hc-canopy-furnace`, `hc-sulphur-fan`, `hc-fume-censer`, `hc-cinnabar-robe`), modifiers verbatim from `hoa_cai.items.json`, all with `sources: ["npc"]` and `unique: true`.
  - `items/sets-hoa_cai.json`: 2 sets (`hc-canopy-and-lid`, `hc-blind-founder`).
  - `effects/hoa_cai.effects.json`: 4 Effects (`The Unfinished Pill`, `Nine Stars over the Fire`, `Under the Lid`, `A Room Full of Fume`), each declaring every counter it reads or writes (`gourd_drunk`, `sealed_room_set`) for standalone GDScript compilation.
  - `design/world/depth/sects/hoa_cai.techniques.json`: `"id"` added before `"new"` on the 5 new arts (`pill-smoke` already carried `"id": "pill-smoke"`).
- **Deviations:** 7 engine-form clarifications/approximations (D1–D7, detailed in §§D–E).
- **Auto-accepted decisions:** 7 (logged in §A with reasons).
- **Pending words:** none (`0`; no `pending.json` needed).
- **Never ran / conditional:** `eff:The Unfinished Pill self poison` did not run on `uy_dan_duong` because he wears all 3 pieces of `The Sealed Room` (`A Room Full of Fume`), which routes the lingering poison to the foe via `eff:The Unfinished Pill shared poison` (5/5 runs); `eff:Under the Lid fan tag` and `eff:Under the Lid fan gust` did not run inside `sect_fight.py` because `sect_fight.py` slots only the 5 technique arts on `la_tu_vi`, omitting her item's common art `fan-gust` (verified separately in `fight.py` with `fan-gust` slotted: `30` runs over 5 seeds, dropping fight time from `17.2 s` to `16.0 s`); `Nine Stars over the Fire`'s out-of-fight pill batch-preservation awaits crafting Effect hooks; `hold-the-fume`'s `hold-fume-immune-*` and `hold-fume-poison-heal` only trigger against Burn/Poison foes (verified firing on `uy_dan_duong` once `shared poison` laid `wood` debuffs on the foe). Every art fired on every real holder (`0 REFUSED`, `0 NEVER_FIRED`, `0 NEVER_RAN` at both `--gap 0` and `--gap 1`).
- **Early promotions:** none (`0` stand-ins; `0` cross-owner references; `pill-smoke` was already promoted in `design/arts/part-sect-market-folk.json`).
- **Open items:** serial step merge/export; `export_named.py` support for `kind == "treasure"` (`hc-nine-cycle-gourd`); out-of-fight failed-pill batch recovery hook (`Nine Stars over the Fire`) and full self pill-effect combat support (`pill-smoke`).

---

## A. Auto-accepted decisions (with reasons)

1. **`pill-smoke` is referenced from `design/arts/part-sect-market-folk.json` rather than duplicated in `part-sect-hoa_cai.json`:**
   - *Reason:* `pill-smoke` was already promoted by `market-folk` (`group: "censer-smoke-manual"`, `element: ""`). Duplicating its record in `part-sect-hoa_cai.json` would cause a `DUPLICATE` error in `lint_arts.py`, whereas keeping it in `canopy-furnace-canon.abilities` (`unlock_layer: 4`) passes `lint_techniques.py` cleanly (`element == ""` is accepted by `tho`-named techniques, and `SUITE_SPLIT` only checks arts whose `group == "canopy-furnace-canon"`).
2. **`spread-the-canopy` uses `ward_grow` (`15 % HP`) + `refresh {side: "foe", kind: "debuff"}` on `pulse` without occupying the stance slot, and lays `2` Earth debuffs (`8 s`) on cast:**
   - *Reason:* Keeps the stance slot clear and avoids locking `spread-the-canopy` behind a state toggle. Refreshing all own debuff batches on `pulse` while `own.ward_share > 0` implements "while it holds, debuffs the holder has laid on the foe do not fade" in exact Python/GDScript parity. Laying `2` Earth debuffs on cast ensures L2–L3 `canopy-furnace-canon` holders (`du_hoang_nhi`, `chau_di_an`, `van_thuy_dan`) have debuffs to seal and feed `lift-the-lid`.
3. **Cooldown staggering (`spread-the-canopy` `5.0 s`, `lift-the-lid` `7.0 s`) and unguarded `lift-the-lid`:**
   - *Reason:* Staggering cooldowns guarantees `spread-the-canopy` opens and holds the ward for at least 2 full pulses before `lift-the-lid` breaks it outward (`release_ward`), so `canopy-seal-debuffs`, `Nine Stars over the Fire sustain`, and `Under the Lid ward` all run reliably. Leaving `lift-the-lid` unguarded ensures it still fires (`0 NEVER_FIRED`) when an enemy breaks the ward early in `--gap 1` fights.
4. **Mercury stacks are Metal debuffs (`el: "metal"`), and `quicksilver`'s 9-stack threshold applies `withering` (`-50 %` healing taken) + `0.06 c` Physical damage per Metal stack each second (`outside_budget: true`):**
   - *Reason:* `hoa_cai.items.json` and `auth-mod.json` already define Mercury stacks as `["kim", "debuff"]` (`el: "metal"`). `withering` (`heal_taken: -0.5`) already exists in `STATUS`, and `outside_budget: true` on the `pulse` `free_hit` avoids `s.direct_dmg == 0` pulse budget clipping (same pattern as `minh_loan`).
5. **`hold-the-fume` implements poison/burn immunity via `tick_to_heal: 1` (`wood` and `fire`) + `status_immune: 1` (`corpse_rot`) for `4 s` without cleansing `wood`:**
   - *Reason:* `tick_to_heal` at `1 %` zeroes out all Burn and Poison tick damage in both engines (`engine.py:1528`, `fight.gd:1360`) with negligible heal noise (`1 %` of tick), while `status_immune` blocks `corpse_rot`. Crucially, avoiding a blanket `wood` cleanse ensures `hold-the-fume` never strips `The Unfinished Pill`'s uncleansable lingering poison (`protect {el: "wood"}`) when `uy_dan_duong` wears the Gourd solo.
6. **`The Unfinished Pill` triggers once per fight on `own.hp_share <= 0.75` or `time >= 8` (`gourd_drunk` state machine) and checks `sealed_room_set`:**
   - *Reason:* Adding `time >= 8` guarantees `uy_dan_duong` drinks even in `--gap 0` fights where his 3-piece kit keeps him above 75 % HP. Routing through `gourd_drunk` prevents record 1's `33.3 %` heal from invalidating `hp_share <= 0.75` before records 2/3 run on the same pulse. Both `The Unfinished Pill` and `A Room Full of Fume` declare `sealed_room_set` in their own `"counters"` arrays for standalone GDScript compilation.
7. **`hc-nine-cycle-gourd` (`kind: "treasure"`, `grade: 4`) carries `"rarity": 5` and R6 `exception`:**
   - *Reason:* `lint_items.py` requires `rarity` in `{4, 5}` for `treasure`, and `ho_lo` (`weapon`, `utility`) expects a weapon common art (`gourd-spout`) under rule 21, so R6 `exception` applies alongside `hc-sulphur-fan` (`phien`) and `hc-cinnabar-robe` (`dao_bao`). `hc-canopy-furnace` and `hc-fume-censer` (`huong_lo`, `utility`) satisfy rule 21 directly.

---

## B. Pending words

None (`0` pending words; all 4 techniques, 5 new arts, 5 items, 2 sets, and 4 Effects run on existing engine words with Python/GDScript parity).

---

## C. Techniques (`design/stage6-staging/hoa_cai/techniques/catalogue-sect-hoa_cai.json`)

Only `nine-cycle-mercury-art` carries depth passives (`b3`: `stack_effect_pct 12 [kim, debuff]`, `stack_duration_pct 16 [kim, debuff]`). **All bonuses and all other passives below are new**, sized against the tier's combat passive budget (`8 / 16 W`) and unpriced (`catalogue-sect-*`).

| Technique | Tier, kind, elements | Bonuses (all new) | Passives (new unless marked depth) | Arts (unlock layer) |
|---|---|---|---|---|
| `cinnabar-washing-primer` | Tier 0 main, Earth + Metal (`6` layers) | none (`bonus_count 0`) | `attack_pct` 4 `[tho]`, `stack_duration_pct` 8 `[tho, debuff]`, `stack_effect_pct` 6 `[kim, debuff]`, `khi_huyet_pct` 3 (`7.6 / 8 W`) | `pan-the-grains` (1) |
| `canopy-furnace-canon` | Tier 1 main, Earth (`9` layers) | `defense_pct` 8 | `ward_efficiency_pct` 6, `stack_duration_pct` 14 `[tho, debuff]`, `stack_duration_pct` 10 `[debuff]`, `attack_pct` 4 `[tho]`, `khi_huyet_pct` 3 (`15.9 / 16 W`) | `spread-the-canopy` (1), `lift-the-lid` (2), `pill-smoke` (4, existing) |
| `nine-cycle-mercury-art` | Tier 1 secret, Metal (`9` layers) | `linh_luc_pct` 12 | **depth (`b3`):** `stack_effect_pct` 12 `[kim, debuff]`, `stack_duration_pct` 16 `[kim, debuff]`; **new:** `attack_pct` 6 `[kim]`, `attack_pct` 4 `[over_time]`, `art_speed_pct` 5 `[kim]`, `status_duration_pct` 3 `[curse]` (`15.8 / 16 W`) | `quicksilver` (1) |
| `sulphur-lung-breath` | Tier 0 body, element-free (`6` layers) | none (`bonus_count 0`) | `status_resist_pct` 8, `resist_pct` 30 `[chaos]`, `resist_pct` 30 `[fire]`, `health_regen_inc_pct` 10 (`7.8 / 8 W`) | `hold-the-fume` (1) |

---

## D. Arts (`design/stage6-staging/hoa_cai/arts/part-sect-hoa_cai.json`)

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `pan-the-grains` (`cinnabar-washing-primer`, L1) | A sweeping strike that throws heavy grit: deals Earth damage and lowers the foe's speed for a few seconds; repeated hits deepen the slow. | Earth control (`c 1.2`, cost 0.04, cd 3.0, `debuff [1, 6]`, `statuses [slowed_time x1, 4 s]`): tracks `pan_rhythm` (`each_for 8`); on `hit_landed` when `pan_rhythm >= 1`, adds 1 extra `slowed_time` (`4 s`) before incrementing `pan_rhythm`. | none ("lowers speed" pinned as `slowed_time`, deepening on repeats within 8 s). |
| `spread-the-canopy` (`canopy-furnace-canon`, L1) | Raises an Earth ward over the holder; while it holds, debuffs the holder has laid on the foe do not fade. | Earth ward (`c 0`, cost 0.04, cd 5.0): `ward_grow` `15 %` HP + `2` Earth debuffs (`8 s`); on `pulse` while `own.ward_share > 0`, runs `refresh {side: "foe", kind: "debuff"}`. | **D1:** raises `sward` via `ward_grow` without taking the stance slot, and adds `2` Earth debuffs so L2–L3 holders have debuffs to maintain. |
| `lift-the-lid` (`canopy-furnace-canon`, L2) | Breaks the ward outward: the foe takes Earth damage that grows with the debuffs on it. | Earth damage (`c 2.0`, cost 0.05, cd 7.0, `debuff [2, 6]`): `empower c_mult 1.6` if `ward_share > 0` or `foe.debuff.earth >= 3` or `foe.debuff.metal >= 3`; on `hit_landed`: `release_ward {dtype: "phys"}` if `ward_share > 0`, plus `0.06 c` `free_hit` per stack of `earth`, `metal` (`phys`), and `wood` (`chaos`). | **D2:** scales per-element (`earth`, `metal`, `wood`) at `0.06 c` per stack + `1.6x` empower because no single readable sums all debuff elements on the foe. |
| `pill-smoke` (`canopy-furnace-canon`, L4) | *(Already promoted in `design/arts/part-sect-market-folk.json`)* | Element-free Chaos puff (`c 0.6`, cost 0.04, cd 6.0, `convert chaos 1.0`): `burn_pill {stacks_per_grade: 4, for: 6.0}`. | **D3:** existing `part-sect-market-folk.json` record reused (`self_share` half-strength pill effect awaits full pill combat support). |
| `quicksilver` (`nine-cycle-mercury-art`, L1) | For a few seconds the holder's hits apply a Mercury stack; at nine stacks the foe's healing is cut sharply and they take Metal damage over time. | Metal stacks (`c 1.4`, cost 0.04, cd 6.0, `debuff [2, 8]`): arms `quicksilver_coat` (`cap 1, each_for 5`); while active, `hit_landed` (`kind: "art"` / `"basic"`) lays `1` Metal debuff (`8 s`); on `pulse` while `foe.debuff.metal >= 9`, applies `withering` (`2 s`, `-50 %` healing taken) and deals `0.06 c` Physical (`outside_budget: true`) per Metal stack. | **D4:** pins "cut sharply" to `withering` (`-50 %` healing taken) and Metal DoT to `0.06 c` Physical per Metal stack on `pulse` (`outside_budget: true`). |
| `hold-the-fume` (`sulphur-lung-breath`, L1) | For a few seconds the holder is immune to poison and burning and regains health for every poison stack on the foe. | Element-free body heal (`c 0`, cost 0.04, cd 6.0, `c_heal 0.5`): arms `fume_hold` (`cap 1, each_for 4`); on `art_fired`, heals `+1 %` HP per `foe.debuff.wood`; while `fume_hold >= 1`, sets `tick_to_heal: 1` (`wood`, `fire`) and `status_immune: 1` (`corpse_rot`). | **D5:** uses `tick_to_heal: 1` (zeroes Poison/Burn tick damage without stripping `The Unfinished Pill`'s uncleansable `wood` poison) + `0.5 c_heal` baseline so it acts in non-Poison matchups. |

---

## E. Effects (`design/stage6-staging/hoa_cai/effects/hoa_cai.effects.json`)

Every Effect declares all counters it reads or writes (`gourd_drunk`, `sealed_room_set`) in its own `"counters"` array for GDScript standalone compilation.

| Effect (source) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `The Unfinished Pill` (`hc-nine-cycle-gourd`) | Once a fight, drink from the gourd: heal a third of your health and gain a large share of attack for ten seconds, then take a lingering mercury poison you cannot cleanse until the fight ends. | Declares `gourd_drunk`, `sealed_room_set`. On `pulse` (`hp_share <= 0.75` or `time >= 8`, `per_fight: 1`): heals `33.3 %` HP, grants `L1 +30` (`for 10 s`), sets `gourd_drunk = 1`; then applies `protect {el: "wood"}` + `4` permanent (`for: null`) `wood` debuffs to `own` (if `sealed_room_set == 0`) or `foe` (if `sealed_room_set >= 1`). | **D6:** triggers at `hp_share <= 0.75` or `time >= 8` so full-set holders still drink in `--gap 0`; "large share of attack" pinned as `L1 +30`; "lingering mercury poison" pinned as `protect` + `4` permanent `wood` debuffs. |
| `Nine Stars over the Fire` (`hc-canopy-furnace`) | Pills you refine while carrying the furnace come out one grade steadier: a failed batch is kept as a lower grade instead of lost. In a fight, your wards last longer while a foe carries your debuffs. | On `always` while foe has Earth/Metal/Wood/Fire debuffs: `ward_pct +20`. On `pulse` while `own.ward_share > 0` and foe has any of those debuffs: `ward_grow {share: 0.02, of: "peak"}`. | **D7:** out-of-fight failed-batch recovery has no crafting Effect consumer in `src/` yet (logged in `approx` and §I); fight half strengthens main ward (`+20 %`) and refills stance ward (`+2 %` peak/s). |
| `Under the Lid` (`hc-canopy-and-lid`, 2pc) | while a foe carries both your Earth and your Mercury stacks, your ward regains 3 % each second, and each fan art adds one more Mercury stack to it. | On `pulse` (`own.ward_share > 0`, `foe.debuff.earth >= 1`, `foe.debuff.metal >= 1`): `ward_grow {share: 0.03, of: "peak"}`. On `art_fired` (`tags: ["fan"]` or `art_id: "fan-gust"`): `1` Metal debuff (`8 s`). | none (`fan-gust` matched explicitly alongside `tags: ["fan"]` because `common-arts.json` tags `fan-gust` as `["artifact"]`). |
| `A Room Full of Fume` (`hc-blind-founder`, 3pc) | each second, the foe gains one Mercury stack; the Gourd's lingering poison no longer stays on you but goes to the foe when you drink. | Declares `sealed_room_set`. On `fight_start`: `sealed_room_set = 1`. On `pulse`: `1` Metal debuff (`8 s`) on the foe. | none. |

---

## F. Items and sets (`design/stage6-staging/hoa_cai/items/catalogue-sect-hoa_cai.json`, `sets-hoa_cai.json`)

- **5 signature items**, modifiers copied verbatim from `design/world/depth/sects/hoa_cai.items.json`, all with `sources: ["npc"]`, `unique: true`, and `arts: []`.
- R6 `exception` set on `hc-nine-cycle-gourd` (`ho_lo`), `hc-sulphur-fan` (`phien`), and `hc-cinnabar-robe` (`dao_bao`); `hc-canopy-furnace` and `hc-fume-censer` (`huong_lo`, `utility`) satisfy rule 21 directly.
- `hc-nine-cycle-gourd` (`kind: "treasure"`, `grade: 4`) carries `"rarity": 5` and `"effects": ["The Unfinished Pill"]`; `hc-canopy-furnace` carries `"effects": ["Nine Stars over the Fire"]`.
- **2 sets:** `hc-canopy-and-lid` (2pc, `Under the Lid`) and `hc-blind-founder` (2pc modifiers, 3pc `A Room Full of Fume`), matching the depth modifiers and rules.

---

## G. Stand-ins and beasts

- **Stand-ins:** `0` (`hoa_cai` has 0 stand-in techniques across all 17 living members in `hoa_cai.cast.json` and `hoa_cai.5.cast.json`).
- **Beasts:** `0`.
- **Depth art ids:** inserted `"id"` before `"new"` on the 5 new arts in `design/world/depth/sects/hoa_cai.techniques.json`; `depth_check.py --sect hoa_cai` reported `findings: none` and `depth_gap.py --sect hoa_cai` reported `unknown_ids: 0`, `engine_words: 0`, `cross_owner: 0`, `stand_ins: 0`, `lines: 26/26 runs`.

---

## H. Holder check (`$env:DEPTH_STAGE = "C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\hoa_cai"`)

**Linters & standalone Effect validation:**
- `lint_arts.py design/stage6-staging/hoa_cai/arts/part-sect-hoa_cai.json`: `5 arts in 1 files, 0 findings` (`lift-the-lid empower 1: x1.05 of the lint, gated`).
- `lint_techniques.py design/stage6-staging/hoa_cai/techniques/catalogue-sect-hoa_cai.json`: `4 techniques, 0 findings` (`7.6 / 8 W`, `15.9 / 16 W`, `15.8 / 16 W`, `7.8 / 8 W`).
- `lint_items.py design/stage6-staging/hoa_cai/items/catalogue-sect-hoa_cai.json`: `5 items, 22 bases, 9 common arts, 0 findings`.
- `engine.validate` standalone check: `4/4` Effects valid (`0` errors).
- `depth_check.py --sect hoa_cai`: `findings: none`.
- `spatial_words_check.py`: `0` hits for `hoa_cai`.

**`sect_fight.py hoa_cai` (`--seeds 20` at `--gap 0`; `--seeds 5` at `--gap 1`; `0 REFUSED`, `0 NEVER_FIRED`, `0 NEVER_RAN`):**

| Holder(s) | Realm | Active arts | Same realm (`mean_s`, `wins/20`, `hp_left`) | `--gap 1` (`mean_s`, `wins/5`, `hp_left`) | Art fires (mean, gap 0) | Effect ablations & notes |
|---|---|---|---|---|---|---|
| `uy_dan_duong` | `ket_dan` | `spread-the-canopy, lift-the-lid, pill-smoke, quicksilver, hold-the-fume` | `16.8 s`, `20/20`, `98%` | `11.6 s`, `0/5`, `0%` | `2.0–3.0` | `The Unfinished Pill`: with `16.8 s 98%` vs without `17.7 s 90%` (`runs 40`). `A Room Full of Fume`: with `16.8 s 98%` vs without `20.8 s 95%` (`runs 355`). |
| `la_tu_vi` | `truc_co` | `spread-the-canopy, lift-the-lid, pill-smoke, quicksilver, hold-the-fume` | `20.9 s`, `20/20`, `91%` | `9.4 s`, `0/5`, `0%` | `3.0–4.0` | `Nine Stars over the Fire`: with `20.9 s 91%` vs without `21.0 s 90%` (`runs 239`). `Under the Lid`: `runs 239` (in `sect_fight.py`, `fan-gust` is not slotted; with `fan-gust` added in `fight.py` over 5 seeds: `16.0 s 91%` vs without `17.2 s 90%`, `fan-gust` record `30` runs). |
| `thieu_ngan_hong` | `truc_co` | `spread-the-canopy, lift-the-lid, pill-smoke, quicksilver` | `21.1 s`, `20/20`, `81%` | `8.0 s`, `0/5`, `0%` | `3.0–4.0` | Full Canopy + Mercury core wins cleanly inside 21 s. |
| `bien_lam_chau` | `luyen_khi` | `spread-the-canopy, lift-the-lid, hold-the-fume, quicksilver` | `21.1 s`, `20/20`, `89%` | `8.0 s`, `0/5`, `0%` | `3.0–4.0` | Inner-gate Canopy + Quicksilver + Breath wins cleanly in 21 s. |
| `trac_dao_sa`, `ky_chu_sa`, `muc_hong_sa` | `truc_co` | `spread-the-canopy, lift-the-lid, pill-smoke, hold-the-fume` | `40.1 s`, `20/20`, `75%` | `8.8 s`, `0/5`, `0%` | `5.0–7.5` | Mid-sect ward + debuff sustain kit wins cleanly in the 30–60 s band. |
| `van_thuy_dan` | `truc_co` | `spread-the-canopy, lift-the-lid` | `39.5 s`, `20/20`, `68%` | `8.4 s`, `0/5`, `0%` | `5.5–7.6` | 2-art Canopy core wins cleanly in 39.5 s. |
| `du_hoang_nhi`, `chau_di_an` | `luyen_khi` | `spread-the-canopy, lift-the-lid` | `37.0 s`, `20/20`, `69%` | `8.0 s`, `0/5`, `0%` | `5.1–7.2` | 2-art Luyện Khí inner-gate kit wins cleanly in 37 s. |
| `ngai_hoang_thach`, `me_hoa_thu`, `chung_minh_hien`, `co_tich_dang` | `luyen_khi` | `pan-the-grains, hold-the-fume` | `48.1–48.6 s`, `1/20`, `1%` | `8.9 s`, `0/5`, `0%` | `6.2–14.7` | Outer-gate Yellow kit + body heal survives ~48 s vs 3-art `typical` enemy. |
| `me_thanh_mach`, `phi_tieu_lam`, `la_khoi_minh` | `luyen_khi` | `pan-the-grains` | `43.4–43.5 s`, `0/20`, `0%` | `8.9 s`, `0/5`, `0%` | `13.3` | Single-art outer-gate primer (`pan-count-rhythm` 68, `pan-deepen-slow` 63 over 5 seeds). |

---

## I. Open items (for the serial step / user)

1. **`export_named.py` `kind == "treasure"`:** `hc-nine-cycle-gourd` has `kind: "treasure"`, `grade: 4`, `rarity: 5`; ensure `export_named.py` exports `treasure` records at Stage 7/serial export (same open item as `ml-luan-bell` and `ct-star-lake-mirror`).
2. **`Nine Stars over the Fire` crafting half:** out-of-fight failed-batch recovery ("a failed batch is kept as a lower grade instead of lost") awaits the Alchemy crafting Effect consumer in `src/`.
3. **Serial step:** merge `design/stage6-staging/hoa_cai/` into `design/`, merge `effects/hoa_cai.effects.json` via `put_effects.py`, and run `export_combat_library.py` / `compile_parity_export.py`.

REVIEW DONE

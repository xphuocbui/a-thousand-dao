# Cửu Cao Phái (`cuu_cao`): Stage 6 record pass review (2026-11-27, headless job, decisions auto-accepted)

## Summary

**Built (all staged in `design/stage6-staging/cuu_cao/`; nothing exported, nothing written outside allowed paths):**
- **2 techniques** (`techniques/catalogue-sect-cuu_cao.json`): `marsh-reed-breath` (Yellow main, Wood, outer) and `crane-bond-rite` (Profound secret, Wind + Wood, inner). New bonuses and passives are sized within each tier's W budget (`7.7 W of 8`, `14.7 W of 16`, §C).
- **3 active arts** (`arts/part-sect-cuu_cao.json`): `reed-bed`, `crane-descends`, and `cry-in-the-nine-marshes`. The 4th depth art (`A Crane for the Rider`, `d32`) is a passive art staged as a layer-2 technique Effect on `crane-bond-rite` (`technique-effects` b01).
- **3 Effects** (`effects/cuu_cao.effects.json`): `A Crane for the Rider` (`crane-bond-rite` L2 passive), `The King Answers` (`cc-green-field-bell`), and `Rider and King` (`cc-green-field-riders` full set). All 3 pass standalone `engine.validate` with local counter declarations and zero `always`/multi-`mod` traps.
- **3 items and 1 set** (`items/catalogue-sect-cuu_cao.json`, `items/sets-cuu_cao.json`): `cc-green-field-bell` (`chuong` 4, `kind: "treasure"`, `rarity: 5`), `cc-winter-terrace-cloak` (`dao_bao` 3), `cc-crane-down-robe` (`dao_bao` 3), and set `cc-green-field-riders` (2 pieces). All 3 carry `sources: ["npc"]`, `unique: true`, and the R6 `exception` mark (`ward_gear`/`body_gear` bases).
- **0 stand-ins:** all 17 living members (`cuu_cao.cast.json` + `cuu_cao.5.cast.json`) already reference `gale-courier-scripture`, `slow-hour-scripture`, `crane-bond-rite`, or `marsh-reed-breath`.
- **3 beasts wired:** added `"beasts": ["han_vu"]` on `cu_van_ly` and `"beasts": ["bat_phi"]` on `mai_lo_tuyet` in `design/world/depth/sects/cuu_cao.cast.json` (`ung_hac_minh` already listed `"beasts": ["thanh_dien"]`).
- **Deviations:** 5 documented below (§A, §D, §E).
- **Pending words:** none (`[]`).
- **Early promotions:** none (`[]`).
- **Never ran in default `sect_fight.py`:**
  - `Rider and King` (`cc-green-field-riders`): requires a `crane`-tagged companion from `cuu_cao.beasts.json` (`thanh_dien`), which `sect_fight.py` does not load before Stage 7 export. Verified active and impactful in 20-seed `ung_hac_minh + thanh_dien` probes (`gap=0`: 274 runs, `7.3 s` vs `7.6 s` without; `gap=1`: 394 runs, `10.5 s` vs `11.2 s` without).
- **Checks (after final edit):** `lint_arts` **0 findings** (3 arts), `lint_techniques` **0 findings** (2 techniques), `lint_items` **0 findings** (3 items), `depth_check.py` `findings: none`, `spatial_words_check.py --sect cuu_cao` **0 removed/postponed**, standalone `engine.validate` **3/3 VALID**, `sect_fight.py cuu_cao --seeds 5` at `--gap 0` & `--gap 1` (+ `--people` for the remaining 4 members) **0 REFUSED** across all 17/17 living members with every slotted art firing.
- **Open items (for serial step / Stage 7):** merge `design/stage6-staging/cuu_cao/` into `design/` and `assets/data/combat_effects.json`; run exporters (`export_techniques.py`, `export_named.py` — noting `cc-green-field-bell` is `kind: "treasure"`, `export_combat_library.py`, `export_world.py --sect cuu_cao` to close `beasts` [3] and `events` [3] in `depth_gap.py`).

## A. Decisions auto-accepted (user rule 2026-11-26), with reasons

1. **Size `marsh-reed-breath` (T0) and `crane-bond-rite` (T1) bonuses/passives from concept and unlock `cry-in-the-nine-marshes` at layer 4.**
   - What: gave `marsh-reed-breath` 4 Wood/sustain/curse passives (`7.7 W of 8`), and `crane-bond-rite` `khi_huyet_pct 10` bonus + 4 Wind/companion/evade passives (`14.7 W of 16`), with `cry-in-the-nine-marshes` at `unlock_layer: 4` (and `A Crane for the Rider` at `unlock_layer: 2`).
   - Why: depth files omit bonuses/passives; sizing within tier budgets (`cong-phap.md` rule 1) rewards both grooms' binding/healing play and riders' Wind/companion kit. Layer 4 unlock lets `tong_phi_thu` (L4) and `banh_da_hang` (L4), as well as `cu_van_ly` (L6) and `ung_hac_minh` (L9), cast the full suite (`cong-phap` rule 17 requires `<= 6`).

2. **Timed 8 s `reed-bed` Field state on `marsh-reed-breath`.**
   - What: `reed-bed` enters `state: "reed-bed"` (`tags: ["field"]`) for 8 pulses (`reed_bed` cap 8, decremented on `pulse` before the `<= 0` exit check) with guard `own.field_up < 1`; each pulse applies 1 `slowed_time` (2 s), 1 Wood debuff stack (6 s), and 1.5 % max HP heal.
   - Why: a timed 8 s Field refreshes naturally on cooldown (`8.0 s`) without permanent lock-in, uses zero new engine words, and has no stance contention (grooms hold no other stance art).

3. **Non-spatial reading of `crane-descends` and `cry-in-the-nine-marshes` with `"crane"` tag (no `"song"` tag).**
   - What: mapped `crane-descends` knockback/open to `timer {side: foe, which: next, by: 0.3}` + `off_guard` (1 s) + `mod {evade: 8, art_speed: 10, for: 4}`; mapped `cry-in-the-nine-marshes` concentration break + buff lengthening to `timer {side: foe, which: next, by: 0.8}` + `refresh {side: own, kind: buff}` + `buff [1, 6]`. Both carry `"crane"`; `cry-in-the-nine-marshes` omits `"song"`.
   - Why: per 2026-11-26 combat redesign (`DECISIONS-2026-11-26.md`), Displaced is removed and knockback/interrupt map to `timer` delays; `cuu_cao.md` §4 explicitly forbids counting the crane's cry as music; tagging both arts `"crane"` lets `The King Answers` repeat them cleanly.

4. **`A Crane for the Rider` (`crane-bond-rite` L2 passive) and `Rider and King` (`cc-green-field-riders`) handle companion presence via `crane_bonded` / `king_beside` + `crane_spirit` (`each_for: 8`).**
   - What: `crane_bonded` and `king_beside` latch on the first `hit_landed` or `was_evaded` by a `kind: "companion", tags: ["crane"]` companion (`thanh_dien` / `han_vu` once exported). When `crane_bonded == 0` (`tong_phi_thu`, `banh_da_hang`, or pre-export `sect_fight.py`), `crane-descends` (20 s cooldown) summons a crane spirit (`c: 0.5, dtype: "force", cd: 1.0, for: 8`) and sets `crane_spirit` (`each_for: 8`) so its hits grant Wind buff stacks (max 2/pulse).
   - Why: engine `summon` actions do not carry `tags` and there is no live `own.companions` readable (`engine.py`). Latching on the first `crane` companion strike/evade (at `t = 1.0 s`, well before `crane-descends`'s `5.0 s` cooldown) separates real beast owners from unbonded riders cleanly without inventing new engine words (`_brief-record.md`: prefer existing words when they keep the intent).

5. **`The King Answers` triggers on the first `crane`-tagged art fired and repeats `crane` arts for 8 s; all 3 signature items carry `unique: true`, R6 `exception`, and `rarity: 5` on `cc-green-field-bell`.**
   - What: `The King Answers` fires `free_hit {c: 1.2, dtype: "force"}` and arms `king_answers` (`each_for: 8`) on the first `crane` art fired, then repeats `fire_art {which: "last", share: 1.0}` for every `crane` art fired while `king_answers >= 1`. `cc-green-field-bell` (`chuong`, `kind: "treasure"`) carries `rarity: 5` (required by `lint_items.py`) plus the R6 `exception` alongside `cc-winter-terrace-cloak` and `cc-crane-down-robe` (`dao_bao`).
   - Why: triggering on the first `crane` art ensures the 8 s double-cast window is never wasted before crane arts come off cooldown; R6 `exception` is required for `ward_gear`/`body_gear` bases without authored item wards.

## B. Mechanic table

Recorded in `production/plans/stage6/cuu_cao.md` (Step 1). `spatial_words_check.py --sect cuu_cao` reports 0 `removed` or `postponed` hits in `cuu_cao`.

## C. Techniques (`design/stage6-staging/cuu_cao/techniques/catalogue-sect-cuu_cao.json`)

| Technique | Tier, kind | Bonuses (new) | Passives (new) | Abilities / Effects | W budget |
|---|---|---|---|---|---|
| `marsh-reed-breath` | T0 Yellow main, `moc` | none | `health_regen_inc_pct` 8 `[]`, `stack_duration_pct` 8 `[moc, debuff]`, `status_duration_pct` 8 `[curse]`, `attack_pct` 2 `[moc]` | `reed-bed` (1) | **7.7 W of 8** |
| `crane-bond-rite` | T1 Profound secret, `phong+moc` | `khi_huyet_pct` 10 | `attack_pct` 8 `[companion]`, `evade_pct` 4 `[]`, `art_speed_pct` 6 `[phong]`, `stack_effect_pct` 8 `[phong, buff]` | `crane-descends` (1), `cry-in-the-nine-marshes` (4); passive `A Crane for the Rider` (2) | **14.7 W of 16** |

## D. Arts (`design/stage6-staging/cuu_cao/arts/part-sect-cuu_cao.json`)

All 3 active arts pass `lint_arts.py` with **0 findings**.

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `reed-bed` | Raises a bed of reeds (a Field) around the holder: while it is up, the foe is slowed and takes light Wood damage over time, and the holder regains health | Wood `c_art 0.0`, `cost 0.04`, `cd 8.0`; `state "reed-bed"` (`tags: ["field"]`) for 8 pulses (`reed_bed`); per pulse `slowed_time` (1, 2 s), `wood` stack (1, 6 s), `heal 0.015` | Timed 8 s Field via `reed_bed` pulse counter |
| `crane-descends` | Calls the bonded crane down on a foe: a Wind strike that knocks them back and leaves them open; while the crane circles, the holder gains evade and speed | Wind `c_art 1.5`, `cost 0.04`, `cd 5.0`, `tags: ["wind", "crane", "quick"]`, `statuses: [off_guard 1 s]`; on `art_fired`: `timer` foe next `+0.3 s`, `mod {evade: 8, art_speed: 10, for: 4}` | Non-spatial knockback mapped to `0.3 s` `timer` delay + `off_guard` 1 s |
| `cry-in-the-nine-marshes` | The crane's cry: a brief Wind burst around the holder that breaks the foe's concentration and lengthens the holder's buffs (not music) | Wind `c_art 1.2`, `cost 0.04`, `cd 6.0`, `tags: ["wind", "crane"]` (no `song`), `buff [1, 6]`; on `art_fired`: `timer` foe next `+0.8 s`, `refresh {side: own, kind: buff}` | Interrupt mapped to `0.8 s` `timer` delay |

## E. Effects (`design/stage6-staging/cuu_cao/effects/cuu_cao.effects.json`)

All 3 pass standalone `engine.validate`.

| Effect (source) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `A Crane for the Rider` (`crane-bond-rite` L2) | Each hit your crane companion lands gives 1 Wind buff (4 s, max 2/pulse). Firing Crane Descends with no companion calls a crane spirit for 8 s (`c 0.5`, Wind, `crane`), once every 20 s | `crane_bonded` latches on `crane` companion `hit_landed`/`was_evaded`; `crane` companion hits grant 1 Wind buff (4 s, `per_pulse: 2`); if `crane_bonded == 0`, `crane-descends` (cd 20 s) summons `c 0.5 force cd 1.0 for 8` + `crane_spirit` (`each_for: 8`) so companion hits grant 1 Wind buff | `approx`: `summon` lacks tags and there is no `own.companions` readable, so `crane_bonded` + `crane_spirit` split real-beast vs spirit-summon tracking |
| `The King Answers` (`cc-green-field-bell`) | Once a fight, ringing the bell calls the crane king Thanh Điền: it strikes the foe with Wind and, for a few seconds, any crane art you use is cast twice | On first `crane` `art_fired` (`per_fight: 1`): `free_hit {c: 1.2, dtype: "force"}` + `king_answers` (`each_for: 8`); while `king_answers >= 1`, `crane` `art_fired` runs `fire_art {which: "last", share: 1.0}` | Rings on first `crane` art fired so the 8 s double-cast window always covers crane arts; `fire_art` repeats the art's damage hit |
| `Rider and King` (`cc-green-field-riders` 2-pc) | Each attack you evade, the crane king answers with one Wind strike at the attacker (at most once a second). While the king fights beside you, you regain 1 % of your health each second | `king_beside` latches on `crane` companion `hit_landed`/`was_evaded`; `evaded` (`per_pulse: 1`) fires `free_hit {c: 0.6, dtype: "force"}`; `pulse` heals `0.01` | `approx`: no `own.companions` readable, so `king_beside` latches on first `crane` companion strike/evade (at `t = 1.0 s`) |

## F. Items & Sets (`design/stage6-staging/cuu_cao/items/catalogue-sect-cuu_cao.json`, `sets-cuu_cao.json`)

- **3 unique NPC items** (`sources: ["npc"]`, `unique: true`, R6 `exception` on all 3): `cc-green-field-bell` (`chuong` 4, `kind: "treasure"`, `rarity: 5`, 32.3 W of 51.2), `cc-winter-terrace-cloak` (`dao_bao` 3, 25.1 W of 38.4), `cc-crane-down-robe` (`dao_bao` 3, 24.9 W of 38.4).
- **1 set** (`cc-green-field-riders`): 2-piece modifiers (`evade_pct 4`, `attack_pct 8 [companion]`) + full-set Effect `Rider and King (Kỵ Vương Đồng Phong)`.

## G. Stand-ins & Beasts (`design/world/depth/sects/cuu_cao.cast.json`)

- **Stand-ins:** 0.
- **Beasts:** `ung_hac_minh` -> `["thanh_dien"]` (pre-existing), `cu_van_ly` -> `["han_vu"]` (added), `mai_lo_tuyet` -> `["bat_phi"]` (added).

## H. Pending words

None (`[]`).

## I. Holder table (`sect_fight.py cuu_cao --seeds 5`, `--gap 0` & `--gap 1`, plus 20-seed probes)

**0 REFUSED across all 17/17 living members; every slotted art fires.**

| Holder / Probe | Realm | Arts | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effects / Art fires |
|---|---|---|---|---|---|
| `ung_hac_minh` | `ket_dan` | `swallow-stance`, `hundred-feather-flurry`, `three-step-chase`, `held-breath`, `crane-descends`, `cry-in-the-nine-marshes` | 8.6 s, 5/5, 100 % | 10.6 s, 0/5, 0 % | All 6 arts fire (3.8/3.2 crane G0; 3.0/2.8 G1). `A Crane for the Rider`: 29 runs G0 (8.6 s vs 8.8 s), 34 runs G1 (10.6 s vs 10.8 s). `The King Answers`: 40 runs G0 (8.6 s vs 9.0 s), 34 runs G1 (10.6 s vs 9.2 s). `Rider and King`: 0 runs (no `beasts` in `sect_fight`). |
| `ung_hac_minh` (probe + `thanh_dien`, 20 seeds) | `ket_dan` | same + `crane` companion (`c 0.5 force cd 1.0`) | **7.3 s, 20/20, 100 %** | **10.5 s, 0/20, 0 %** | `A Crane for the Rider`: **161 runs G0** (`7.3 s` vs `7.8 s`), **221 runs G1** (`10.5 s` vs `10.9 s`). `The King Answers`: **134 runs G0** (`7.3 s` vs `8.4 s`), **141 runs G1**. `Rider and King`: **274 runs G0** (`7.3 s` vs `7.6 s`), **394 runs G1** (`10.5 s` vs `11.2 s`). |
| `cu_van_ly` | `truc_co` | same 6 rider arts | 13.1 s, 5/5, 85 % | 9.5 s, 0/5, 0 % | All 6 arts fire (3.4/2.6 crane G0; 1.0/1.0 G1). `A Crane for the Rider`: 40 runs G0 (`13.1 s 85 %` vs `14.2 s 84 %`), 28 runs G1 (`9.5 s` vs `10.5 s`). |
| `cu_van_ly` (probe + `han_vu`, 20 seeds) | `truc_co` | same + `crane` companion (`c 0.5 force cd 1.0`) | **11.9 s, 20/20, 88 %** | **10.9 s, 0/20, 0 %** | `A Crane for the Rider`: **247 runs G0** (`11.9 s 88 %` vs `13.6 s 85 %`), **233 runs G1** (`10.9 s` vs `11.1 s`). |
| `tong_phi_thu` | `truc_co` | same 6 rider arts | 13.2 s, 5/5, 82 % | 10.1 s, 0/5, 0 % | All 6 arts fire (3.0/2.2 crane G0; 1.0/1.0 G1). `A Crane for the Rider`: 40 runs G0 (`13.2 s 82 %` vs `14.7 s 80 %`), 31 runs G1. |
| `banh_da_hang` | `truc_co` | `swallow-stance`, `hundred-feather-flurry`, `three-step-chase`, `crane-descends`, `cry-in-the-nine-marshes` | 14.6 s, 5/5, 77 % | 10.1 s, 0/5, 0 % | All 5 arts fire (3.0/2.0 crane G0; 1.0/1.0 G1). `A Crane for the Rider`: 40 runs G0 (`14.6 s 77 %` vs `16.3 s 74 %`), 31 runs G1 (`10.1 s` vs `9.4 s`). |
| `mai_lo_tuyet`, `ha_vi_lang` | `truc_co` | `reed-bed` | 64.7 s, 3/5, 2 % | 8.4 s, 0/5, 0 % | `reed-bed` fires (7.8 G0; 0.4 G1). |
| `dong_duoc_huong` | `luyen_khi` | `reed-bed` | 63.5 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | `reed-bed` fires (7.4 G0; 0.4 G1). |
| `lu_thuy_dien` | `luyen_khi` | `reed-bed` | 61.6 s, 1/5, 1 % | 8.0 s, 0/5, 0 % | `reed-bed` fires (7.2 G0; 0.4 G1). |
| `nguy_ha_lo`, `dau_quang_lang`, `su_man_thanh`, `pham_thanh_lo` | `luyen_khi` | `reed-bed` | 61.8–62.0 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | `reed-bed` fires (7.2 G0; 0.4 G1). |
| `ha_tri_han` | `luyen_khi` | `reed-bed` | 61.8 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | `reed-bed` fires (7.0 G0; 0.4 G1). |
| `khong_tuong_vu` (`--people`) | `truc_co` | `swallow-stance`, `hundred-feather-flurry`, `three-step-chase` | 18.4 s, 5/5, 66 % | — | All 3 arts fire (4.0/2.6/5.6). |
| `mo_cao_yen`, `lo_phi_suong`, `ninh_van_tuoc` (`--people`) | `luyen_khi` | `swallow-stance`, `hundred-feather-flurry` | 43.6 s, 0/5, 0 % | — | Both arts fire (9.4/5.8). |

REVIEW DONE

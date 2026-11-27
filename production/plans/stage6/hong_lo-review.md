# Stage 6 Record Pass Review — Hồng Lô Cốc (`hong_lo`)

**Date:** 2026-11-27
**Owner:** `hong_lo`
**Status:** Staged cleanly under `design/stage6-staging/hong_lo/`; `lint_techniques.py`, `lint_arts.py`, and `lint_items.py` all report `0` findings (`DEPTH_STAGE=design/stage6-staging/hong_lo`), `depth_check.py` reports `findings: none`, `depth_gap.py --sect hong_lo` reports `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `engine_words: 0`, `wishes_open: 0`, and `sect_fight.py hong_lo --seeds 20` + `--gap 1` + synthetic probes confirm every art fires and every Effect runs.

---

## Summary

- **Built (staged in `design/stage6-staging/hong_lo/`):**
  - `5` techniques in `techniques/catalogue-sect-hong_lo.json` (`3` lineage proposals: `snow-hearth-primer`, `water-over-fire-canon`, `whale-road-harpoon`; `2` new stand-in methods: `broth-kettle-breath` for `tap_dich` cooks, `satchel-hall-healing-canon` for Satchel Hall healers).
  - `5` new arts in `arts/part-sect-hong_lo.json` (`bank-the-coal`, `steam-from-the-jacket`, `the-pot-is-finished`, `line-on-the-whale`, `skimming-the-broth`), plus `5` existing library arts referenced (`brazier-form`, `furnace-heart`, `drag-of-the-deep`, `seed-of-spring`, `second-spring`).
  - `4` Effects in `effects/hong_lo.effects.json` (`It Does Not Cool`, `Quench the Jacket`, `Ký Tế`, `A Second Early`).
  - `6` unique items in `items/catalogue-sect-hong_lo.json` and `2` sets in `items/sets-hong_lo.json`.
  - `4` stand-ins cleared in `hong_lo.cast.json` and `hong_lo.5.cast.json`; `4` art IDs and `2` stand-in techniques registered in `hong_lo.techniques.json`. `0` beasts.
- **Deviations:** `6` logged across records (see §C–§E: `the-pot-is-finished` counter posture & initial buff stacks + pill timing deferred, `It Does Not Cool` cleanse/evade mapping, `Quench the Jacket` periodic cleanse for 2x Burn expiry, `Ký Tế` `0.06 c` Fire burst, `A Second Early` pill timing deferred & steam Burn read, item scope tag fixes `water` -> `cold`/`thuy` + treasure `rarity: 5`).
- **Auto-accepted decisions:** `7` decisions taken against the design rules and logged in §A.
- **Pending words:** `0` (`pending.json` omitted; all records run on the existing Stage 5/6 engine vocabulary).
- **Never ran in default `sect_fight.py` (and why):** `It Does Not Cool` (default typical foe has `0` evade and `0` cleanse; verified `109` hold + `8` keep runs vs evading/cleansing foe), `Ký Tế` (`hlo-ky-te` 3-piece set is split 2/1 between `dong_hong_lo` and `tan_tuyet_than`; verified `80` hold + `20` burst runs in 3-piece probe), `Kindled Wound` (external `catalogue-fire.json` `always` Effect on `fire-furnace-mouth-gourd`: changes `dong_hong_lo` fight `14.9 s / 75%` -> `14.7 s / 76%` with `0` `E.Fight.do` triggers).
- **Early promotions:** `0` (no foreign owner files touched).
- **Open items:** None blocking the serial merge; pill-timing halves of `the-pot-is-finished` and `A Second Early` await the future Alchemy combat-pills pass (`DECISIONS-2026-11-26.md`).

---

## A. Auto-Accepted Decisions (with Reasons)

1. **`broth-kettle-breath` (`tap_dich`) and `satchel-hall-healing-canon` (`chap_su`) for the 4 stand-ins:**
   - `duong_bat_oan` and `duong_thang_nhi` (`hoang_hoa`) carry `tap_dich` exceptions ("kitchen servant; not taught the lineage"). Rather than putting them into `snow-hearth-primer`, staged a dedicated Yellow kitchen method `broth-kettle-breath` with `skimming-the-broth` (matching Băng Tâm's `warm-hearth-breath` and Thúy Vi's `cliff-hearth-breath`).
   - `giai_bach_bo` and `cuc_xa_tien` (`huyen_moc`) keep Thanh Nang Đường's healing method under R2/R5 exception. Because Thúy Vi staged `thanh-nang-balm-canon` in `design/stage6-staging/thuy_vi/` (not yet merged) and `stage6_merge.py` enforces globally unique technique IDs, Hồng Lô stages its own `satchel-hall-healing-canon` (`moc`/`thuy`, Profound, `seed-of-spring` + `second-spring`) so both passes merge cleanly without cross-owner edits or ID collisions.
2. **`bank-the-coal` as a Fire art (`element: "fire"`) unlocking at layer 2 of `snow-hearth-primer`:**
   - Outer boat disciples (`nghieu_lang_hoa`, `nhan_doi_nhi`, `te_luc_tien`, `cao_hai_mac`, `nghieu_vong_kinh`) carry `snow-hearth-primer` (`brazier-form` at L1 has `c_art: 0.0`). Making `bank-the-coal` a Fire damaging palm at L2 gives every L2+ outer disciple a Fire hit to bank coals (`each_for: 6`) and lets `nghieu_vong_kinh` / `cao_hai_mac` spend those coals whenever they fire their Water arts (`drag-of-the-deep`, `line-on-the-whale`).
3. **`the-pot-is-finished` uses counter `ky_te` (`8` s, no `"stance"` tag) and kindles 1 Fire + 1 Water buff (`6` s) on cast:**
   - `brazier-form` (`family-fire.json`) defines `brazier-toggle` filtering on `{"tags": ["stance"]}`, and both `dong_hong_lo` and `tan_tuyet_than` slot `brazier-form`. Omitting `"stance"` from `the-pot-is-finished`'s `tags` and tracking its `8` s posture via counter `ky_te` preserves `brazier` without overwriting the single `s.state` slot (Lesson 2 / Trap 4).
   - Neither `dong_hong_lo` nor `tan_tuyet_than` has another art granting own Fire/Water buff stacks. Granting `1` Fire + `1` Water buff (`6` s) on entry ensures the posture runs its bonuses for `6` s and breaks with the `0.6 c` Fire `self_hit` at `6` s unless refreshed—which also lets `tan_tuyet_than`'s `Quench the Jacket` fire against non-Fire foes. Cooldown set to `8.0` s so it fires even in short `--gap 1` fights (`9.2 s`).
4. **Pill timing ("pills act a second sooner") in `the-pot-is-finished` and `A Second Early`:**
   - Per `DECISIONS-2026-11-26.md` ("Pills in a fight: smoke only for now"), pills have no fight-effect cooldown or timer until the Alchemy pass. Added no speculative pending word; `the-pot-is-finished` speeds `heal`-tagged arts (`art_speed: 25, tags: ["heal"]`, reducing a `5 s` heal by `1.0 s`) and `steam-from-the-jacket` carries `"heal"` so both holders benefit, while pill timing is logged in `approx`.
5. **`A Second Early` reads Burn stacks spent by `steam-from-the-jacket` (`steam_spent` counter):**
   - `tan_tuyet_than`'s Đạo Đồ targets (`2457` Fire Poison, `2417` Clinging Embers: `stack_effect_pct ["hoa", "debuff"]`) and `hlo-steam-censer` (`stack_effect_pct ["hoa", "debuff"]`) buff her Burn on the foe, and `water-over-fire-canon` has no self-Burn applicator. Following Băng Tâm's "your Ice stacks" convention, `A Second Early` heals `2 %` max HP per Burn stack `steam-from-the-jacket` consumes (via shared counter `steam_spent`).
6. **`line-on-the-whale` uses `silence` (`tag: "movement"`, clamped to `5` s curse max):**
   - Both engines (`engine.py:1062,1683` and `fight.gd:960-963`) already support `silence` scoped to a single tag (`"tag": "movement"`). Using `silence {tag: "movement", dur: 5}` with counter `whale_line` (`6` s for the Slowed Time on Water hits) fulfills "the foe's movement arts fail" with zero engine changes.
7. **Item scope fixes (`water` -> `cold` / `thuy`) and treasure `rarity: 5`:**
   - `hong_lo.items.json` wrote `"scope": ["water"]` on `hlo-nine-year-ember` (`resist_pct 100`) and `hlo-whale-road-spear` (`attack_pct 16`), which `lint_items.py` rejects (`water` is not in the Modifier tag vocabulary). Mapped `resist_pct` to `["cold"]` (matching `combat_engine.json` `scope_dtype`) and `attack_pct` to `["thuy"]` (matching `catalogue-water.json`). Added `"rarity": 5` to `hlo-nine-year-ember` (`kind: "treasure"`, `grade: 4`) and R6 `exception` to `hlo-snow-melt-gourd`, `hlo-whale-road-spear`, and `hlo-first-snow-jacket`; all `6` items carry `sources: ["npc"]` and `unique: true`.

---

## B. Mechanic Table & Techniques (`catalogue-sect-hong_lo.json`)

The depth records name no bonuses or passives; all bonuses and passives below are new and sized against their tier's catalogue budget (unpriced in `catalogue-sect-hong_lo.json`).

| Technique | Tier, kind | Bonuses (new) | Passives (new) | Arts (unlock layer) |
|---|---|---|---|---|
| `snow-hearth-primer` | Yellow main, `hoa` + `thuy` | none (`0`) | linh lực regen `+4 %`, attack `3 % [fire]`, Burn duration `6 % [hoa, debuff]`, khí huyết `2 %` (`7.6 / 8 W`) | `brazier-form` (1), `bank-the-coal` (2) |
| `water-over-fire-canon` | Earth secret, `hoa` + `thuy` | alchemy success `+6`, linh lực `15 %` | attack `8 % [fire]`, attack `6 % [cold]`, healing `10 %`, Burn effect `12 % [hoa, debuff]`, Burn duration `12 % [hoa, debuff]`, status resist `8 %` (`22.9 / 24 W`) | `furnace-heart` (1), `steam-from-the-jacket` (2), `the-pot-is-finished` (4) |
| `whale-road-harpoon` | Profound secret, `thuy` | khí huyết `10 %` | attack `8 % [cold]`, accuracy `8 %`, status duration `12 % [curse]`, Water debuff duration `12 % [thuy, debuff]` (`15.3 / 16 W`) | `drag-of-the-deep` (1), `line-on-the-whale` (3) |
| `broth-kettle-breath` *(new stand-in)* | Yellow main (`tap_dich`), `hoa` + `thuy` | none (`0`) | health regen `+8 %`, khí huyết `4 %`, linh lực regen `+3 %` (`7.2 / 8 W`) | `skimming-the-broth` (1) |
| `satchel-hall-healing-canon` *(new stand-in)* | Profound main (`chap_su`), `moc` + `thuy` | herb growth `15 %` | healing `8 %`, health regen `+10 %`, linh lực regen `+8 %`, status resist `5 %` (`15.4 / 16 W`) | `seed-of-spring` (1), `second-spring` (4) |

---

## C. Arts (`part-sect-hong_lo.json`)

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `bank-the-coal` | Each Fire hit you land banks its heat as a coal (`6` s); a Water art fired while holding a coal spends it to lay `2` Burn stacks and regain linh lực | Fire palm `c 1.6`, `cost 0.03`, `cd 3.0`, `debuff [1, 6]`; counter `coal` (`each_for: 6`); `hit_landed [fire]` adds 1 coal; `art_fired [water]` spends 1 coal -> `2` Burn (`6` s) + `3 %` qi | Added `1` Burn (`6` s) on its own hit so the palm participates in the Fire stack engine |
| `steam-from-the-jacket` | Water hit turning every `3` Burn stacks on the foe into a Fire-and-Water burst of steam that heals for `1/3` of its damage; Burn stacks spent | Water `c 1.6`, `cost 0.04`, `cd 5.0`, tags `[cold, water, seal, steam, heal]`; `hit_landed` at `>= 3` foe Burn sets `leech_hp: 33.3` (`1` ms), consumes foe Burn (`per: 3`), records `steam_spent`, fires `0.45 Fire + 0.45 Cold` `free_hit`s per `3` stacks | None (`leech_hp` heals 1/3 of burst; `consume` spends all Burn stacks proportionally by `got / 3`) |
| `the-pot-is-finished` | Stance for `8` s: while holding Fire + Water stacks, pills & heals act `1` s sooner and Fire arts cost `20 %` less; breaks with a small Fire hit if either runs out | `c 0.0`, `cost 0.04`, `cd 8.0`; counter `ky_te` (`8` s, no `"stance"` tag); entry lays `1` Fire + `1` Water buff (`6` s); `always` `cost_red 0.2 [fire]` + `art_speed 25 [heal]`; `pulse` breaks with `0.6 c` Fire `self_hit` when either buff `< 1` | Tracked via `ky_te` counter to preserve `brazier`; grants `1+1` starter buffs (`6` s) so holders run it; pill timing awaits Alchemy pass |
| `line-on-the-whale` | Spear hit tying a Water line for `6` s: foe's movement arts fail and each Water hit adds Slowed Time | Water `c 1.8`, `cost 0.04`, `cd 7.0`; `hit_landed` sets `whale_line` (`6` s) + `silence` (`tag: "movement"`, `dur: 5`); `hit_landed [water]` while `whale_line >= 1` lays `1` Slowed Time (`3` s) | `silence` clamps to `5` s (`curse_duration_max`) while `whale_line` runs full `6` s |
| `skimming-the-broth` *(new)* | Kitchen servants' stand-in heal | Elementless `c_heal 0.55`, `cost 0.03`, `cd 5.0`, tag `[heal]` | New stand-in art |

---

## D. Effects (`design/stage6-staging/hong_lo/effects/hong_lo.effects.json`)

| Effect (source) | Depth rule | Engine form | Deviation |
|---|---|---|---|
| `It Does Not Cool` (`hlo-nine-year-ember`) | Burn does not fall off when fight pauses or foe hides; once a fight, keeps `> 5` Burn stacks put out by a Water hit | `was_evaded [fire]` refreshes foe Burn (`at_least: 6`); `cleansed` (`amount > 5`, `per_fight: 1`) restores `event.amount` Burn stacks (`8` s) | Fight pauses already freeze debuff timers via `stop_clock`; hiding read as `was_evaded`, Water-extinguish read as `cleansed` |
| `Quench the Jacket` (`hlo-snow-melt-gourd`) | On taking Fire damage (`cd 2` s), gain `1` Water stack; at `3+` Water stacks, own Burn ends twice as fast | `was_hit` & `tick_taken [fire]` (shared `quench_cd` `2` s) grant `1` Water buff (`10` s); `pulse` (`buff.water >= 3`, `debuff.fire >= 1`, `cd 2` s) cleanses `1` own Burn | Incoming debuff duration halving is not a live mod key; modelled via `2` s Fire cleanse (`approx`, matching `The Robe Is Never Dry`) |
| `Ký Tế` (`hlo-ky-te` 3pc) | Burn on foe does not fall off while healing; each heal cast turns `1` Burn into a `3` s Burn Fire burst | `heal_restored` refreshes foe Burn (`at_least: 4`); `art_fired [tags: heal]` (`foe.debuff.fire >= 1`) consumes `1` Burn for `0.06 c` Fire `free_hit` | `3` s of `1` Burn (`0.019 c/s`) written as `0.06 c` Fire `free_hit` |
| `A Second Early` (`hlo-snow-hearth` 2pc) | Pills act `1` s sooner; each time a steam art spends your own Burn stacks, heal `2 %` HP per stack spent | `hit_landed [tags: steam]` (`steam_spent > 0`) heals `2 %` max HP per stack in `steam_spent`, then resets `steam_spent` to `0` | Pill timing deferred to Alchemy pass; reads `steam-from-the-jacket`'s consumed Burn (`steam_spent`) |

---

## E. Items & Sets (`catalogue-sect-hong_lo.json`, `sets-hong_lo.json`)

- **6 items** (`hlo-nine-year-ember` treasure `rarity: 5`; 5 artifacts `grade: 3`), all `sources: ["npc"]`, `unique: true`.
- R6 `exception` carried on the 3 `weapon` / `body_gear` items (`hlo-snow-melt-gourd`, `hlo-whale-road-spear`, `hlo-first-snow-jacket`).
- Modifier scope fixes applied: `hlo-nine-year-ember` `resist_pct` `["water"]` -> `["cold"]`; `hlo-whale-road-spear` `attack_pct` `["water"]` -> `["thuy"]`.
- **2 sets** (`hlo-ky-te` 3pc, `hlo-snow-hearth` 2pc); `lint_items.py` reports `checked 6 items, 22 bases, 9 common arts, 0 findings`.

---

## F. Stand-ins (`hong_lo.cast.json`, `hong_lo.5.cast.json`)

| Person | Cast file | Realm | Old -> New |
|---|---|---|---|
| `giai_bach_bo` | `hong_lo.cast.json` | `truc_co` | `huyen_moc` (L8) -> `satchel-hall-healing-canon` (L8) |
| `cuc_xa_tien` | `hong_lo.cast.json` | `luyen_khi` | `huyen_moc` (L3) -> `satchel-hall-healing-canon` (L3) |
| `duong_bat_oan` | `hong_lo.cast.json` | `luyen_khi` | `hoang_hoa` (L4) -> `broth-kettle-breath` (L4) |
| `duong_thang_nhi` | `hong_lo.5.cast.json` | `luyen_khi` | `hoang_hoa` (L2) -> `broth-kettle-breath` (L2) |

---

## G. Holder Table (`sect_fight.py hong_lo --seeds 20` & `--gap 1`)

| Holder | Realm | Default (20 seeds) | `--gap 1` (20 seeds) | Arts & Effects |
|---|---|---|---|---|
| `dong_hong_lo` | `ket_dan` | `14.7 s, 20 wins, 76%` | `8.6 s, 0 wins, 0%` | All 6 arts fire (`1.9–5.9`/fight; `1.0–3.0` at `--gap 1`). `It Does Not Cool`: `0` runs vs typical foe (`109` hold + `8` keep vs evade/cleanse foe). `Kindled Wound`: `always` (`14.7 s / 76%` vs `14.9 s / 75%` without). |
| `tan_tuyet_than` | `ket_dan` | `18.4 s, 20 wins, 90%` | `9.2 s, 0 wins, 0%` | All 6 arts fire (`2.0–6.0`/fight; `0.6–2.0` at `--gap 1`). `Quench the Jacket`: **`60` runs** (`self_hit` at `ky_te` break; `142` runs vs Fire foe). `A Second Early`: **`20` runs** (`90%` hp vs `79%` without). |
| `nghieu_vong_kinh` | `truc_co` | `30.4 s, 20 wins, 58%` | `9.0 s, 0 wins, 0%` | All 4 arts fire (`3.8–9.3`/fight; `1.0–2.0` at `--gap 1`); `bank-the-coal` + `line-on-the-whale` verified (`93` coal banks, `79` spends, `37` lines, `79` slows in 10 seeds). |
| `cao_hai_mac` | `truc_co` | `31.3 s, 20 wins, 53%` | `8.9 s, 0 wins, 0%` | All 4 arts fire (`3.9–9.8`/fight; `1.0–2.0` at `--gap 1`). |
| `giai_bach_bo` | `truc_co` | `37.1 s, 20 wins, 100%` | `8.6 s, 0 wins, 0%` | `seed-of-spring` (`7.4`), `second-spring` (`1.6`). |
| `nghieu_lang_hoa` | `luyen_khi` | `44.6 s, 11 wins, 8%` | `8.0 s, 0 wins, 0%` | `brazier-form` (`6.1`), `bank-the-coal` (`12.2`). |
| `nhan_doi_nhi`, `te_luc_tien` | `luyen_khi` | `44.6 s, 11 wins, 8%` | `8.0 s, 0 wins, 0%` | `brazier-form` (`6.1`), `bank-the-coal` (`12.2`). |
| `lai_tieu_than` | `luyen_khi` | `46.4 s, 0 wins, 0%` | `8.0 s, 0 wins, 0%` | `brazier-form` (`6.6` default, `1.0` `--gap 1`; L1 outer disciple). |
| `cuc_xa_tien` | `luyen_khi` | `33.0 s, 20 wins, 99%` | `8.0 s, 0 wins, 0%` | `seed-of-spring` (`6.5` default, `1.0` `--gap 1`). |
| `duong_bat_oan`, `duong_thang_nhi` | `luyen_khi` | `44.5 s, 0 wins, 0%` | `8.0 s, 0 wins, 0%` | `skimming-the-broth` (`8.0` default, `1.0` `--gap 1`; `tap_dich` cooks). |

- **Synthetic 3-piece `hlo-ky-te` probe** (`dong_hong_lo` with `hlo-nine-year-ember`, `hlo-coal-carrier-ring`, `hlo-snow-melt-gourd` vs `2x` HP typical Kết Đan foe, 10 seeds): `Ký Tế:hold` ran `80` times and `Ký Tế:burst` ran `20` times (`10/10` wins, `19.6 s`).

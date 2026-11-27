# Vạn Hác Viện (`van_hac`): Stage 6 review (2026-11-27)

## Summary

- **Built (staged under `design/stage6-staging/van_hac/`):** 3 techniques (`pine-wind-fingering`, `ten-thousand-ravines-zither-canon`, `the-monks-rest`), 5 new active arts (`plucked-pitch`, `echo-wall`, `ten-thousand-ravines`, `the-held-rest`, `empty-ravine`), 4 signature items (`vh-tung-phong-cam`, `vh-stringless-zither`, `vh-held-rest-beads`, `vh-ravine-wind-robe`), 1 set (`vh-monks-things`), and 4 Effects (`The Earned Rest` from `d28`, `Pines in Ten Thousand Ravines`, `The Unplayed Note`, `Silence After the Twelfth`).
- **Deviations (4 logged):** (1) Resonance stored as a `foe`-side counter (`foe.counter.resonance`) rather than timed debuff batches; (2) `Empty Ravine` strips up to 3 stacks of the foe's largest buff pile + applies `silence` (`tag: "song"`, 3 s) + deals Force damage (`c_art 1.4`) because `target.buffs` does not track source tags (`song`/`drum`/`bell`); (3) `Pines in Ten Thousand Ravines` fires echoes on the next `pulse` (`free_hit` 0.8 Force + 1 Resonance per queued song art) rather than spawning a delayed copy at a spatial point; (4) `Silence After the Twelfth` uses `stop_clock` 1.0 s + `slowed_time` 3 stacks for 3 s rather than single-tag `silence` so all foe arts stall and slow.
- **Auto-accepted decisions (6 logged in §B):** element-free technique passives/bonuses sized to tier (`names: []`); `plucked-pitch` cooldown 1.5 s so `thorn-lullaby` lands within 1 s; `Echo Wall` as a 4 s timed charge counter to avoid clobbering `march` stance; Resonance as `foe.counter.resonance` with `res_keep` halving; `Empty Ravine` `strip` + `silence` (`tag: "song"`); signature item `rarity: 5` on `vh-tung-phong-cam`, `unique: true` and R6 `exception` marks on weapon/robe bases.
- **Pending words:** none (`pending.json` not needed; every record compiles and runs on existing engine words).
- **Never ran:** none — all 5 new arts and 2 referenced arts (`marching-dirge`, `thorn-lullaby`) fired on their holders, and all 4 Effects ran in `sect_fight.py` (`--gap 0` and `--gap 1`).
- **Early promotions:** none (`cross_owner: 0`, `stand_ins: 0`, `beasts: 0`).
- **Open items for the serial step / Stage 7:** promote staged files from `design/stage6-staging/van_hac/` into `design/` and merge `effects/van_hac.effects.json` into `assets/data/combat_effects.json`; note `export_named.py` skips `kind: "treasure"` (`vh-tung-phong-cam`) until treasure export is added; export the 3 structured events (`N-van_hac-01`..`03`) at Stage 7.

## A. Verification & Linter Results

With `DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\van_hac`:
- `spatial_words_check.py --sect van_hac`: 0 hits for `van_hac` (`van_hac.items.json` phrase `"from a random point near the foe"` was removed from the engine `rule` of `Pines in Ten Thousand Ravines`).
- `lint_arts.py design/stage6-staging/van_hac/arts/part-sect-van_hac.json`: checked 5 arts, **0 findings**.
- `lint_techniques.py design/stage6-staging/van_hac/techniques/catalogue-sect-van_hac.json`: checked 3 techniques, **0 findings** (`pine-wind-fingering` 7.2 W of 8, `ten-thousand-ravines-zither-canon` 22.4 W of 24, `the-monks-rest` 13.9 W of 16).
- `lint_items.py design/stage6-staging/van_hac/items/catalogue-sect-van_hac.json`: checked 4 items, **0 findings** (4 of 4 unique; R6 exceptions on `vh-tung-phong-cam`, `vh-stringless-zither`, `vh-ravine-wind-robe`).
- `depth_check.py`: **0 findings**.

## B. Auto-Accepted Design Decisions

1. **Element-free technique bonuses and passives (new, sized to tier):** `van_hac.techniques.json` gave no bonuses/passives for `pine-wind-fingering` (tier 0) or `the-monks-rest` (tier 1), and 2 authored passives (`soul_res_pct 8.3`, `status_resist_pct 7.5`) for `ten-thousand-ravines-zither-canon` (tier 2) with no bonuses. Sized to tier budgets (`names: []` per b02 `lint-element-free-techniques`), using unscoped/valid scope tags (`[]`, `["soul"]`, `["curse"]`) so every passive runs in `fight.py` and `depth_gap.py` without `SCOPE` or dead-tag notes.
2. **Resonance representation (`foe.counter.resonance`):** `Ten Thousand Ravines`, `Echo Wall`, `Pines in Ten Thousand Ravines`, and `Silence After the Twelfth` share a `foe`-side counter `resonance` (like Phượng Minh's `shao`) instead of adding a new timed stack pile to both engines. `Ten Thousand Ravines` computes `floor(R / 2)` via `res_keep` (`scale per: 2`) and re-adds it after clearing `resonance`, giving limitless scaling without caps.
3. **`Echo Wall` as a timed charge counter (`each_for: 4.0`, `cap: 1`):** avoids occupying the fighter's single stance slot, which `marching-dirge` uses for `"march"`. `echo-wall-heal` guards on `event.amount > 0` so blocked hits do not heal.
4. **`Plucked Pitch` cadence (`cooldown: 1.5`, `c_art: 1.4`):** at `cooldown: 2.0`, `thorn-lullaby` (`6.0 s`) fired 1 ms before `plucked-pitch`, so the 1 s `plucked_echo` window expired before the next note. At `cooldown: 1.5 s` (`1456 ms` at +3 % speed), `plucked-pitch` fires right before `thorn-lullaby` (`5824 ms` vs `5825 ms`), landing the +25 % echo reliably.
5. **`Empty Ravine` uses existing `strip` + `silence` (`tag: "song"`):** `target.buffs` does not track source art tags (`song`/`drum`/`bell`). Rather than adding buff-source metadata to both engines for one counter-art, `Empty Ravine` strips up to 3 stacks of the foe's largest buff pile, silences `song` arts for 3 s, and deals Force damage (`c_art 1.4`) so it still acts against non-song foes.
6. **Treasure rarity & R6 signature item defaults:** `vh-tung-phong-cam` (`kind: "treasure"`, `grade: 4`) gets `"rarity": 5` for `lint_items.py`, and all 4 items carry `"unique": true` and `sources: ["npc"]`, with R6 `exception` on `cam` and `dao_bao` bases.

## C. Techniques (`catalogue-sect-van_hac.json`)

All bonuses and passives below are new except the two `b1` passives on `ten-thousand-ravines-zither-canon` (`soul_res_pct 8.3`, `status_resist_pct 7.5`) and `The Earned Rest` (`d28`).

| Technique | Tier, kind, names | Bonuses | Passives | Arts / Effects (unlock layer) |
|---|---|---|---|---|
| `pine-wind-fingering` | Yellow (0) main, `names: []` | none | **new:** `attack_pct 3`, `art_speed_pct 3`, `linh_luc_regen_inc_pct 3` (7.2 W of 8) | `plucked-pitch` (1), `thorn-lullaby` (2) |
| `ten-thousand-ravines-zither-canon` | Earth (2) main, `names: []` | **new:** `than_thuc_pct 10`, `linh_luc_pct 12` | `soul_res_pct 8.3`, `status_resist_pct 7.5`; **new:** `attack_pct 6`, `art_speed_pct 6`, `linh_luc_regen_inc_pct 6` (22.4 W of 24) | `marching-dirge` (1), `echo-wall` (2), `ten-thousand-ravines` (4) |
| `the-monks-rest` | Profound (1) secret, `names: []` | **new:** `than_thuc_pct 8` | **new:** `status_duration_pct 10 [curse]`, `art_speed_pct 6 [soul]`, `x_soul 4`, `linh_luc_regen_inc_pct 6` (13.9 W of 16) | `the-held-rest` (1), `empty-ravine` (2); **effect:** `The Earned Rest` (`passive_art: true`, 4) |

## D. Arts (`part-sect-van_hac.json`)

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| `plucked-pitch` | A single note thrown at a foe as Force damage; the next note within a second strikes harder. | `element: ""`, `kind: "elem"`, `convert: {to: "force", share: 1.0}`, `c_art 1.4`, `cost_share 0.03`, `cd 1.5`; `hit_landed` arms `plucked_echo` (`each_for: 1.0, cap: 1`); `always` grants `dmg_more 0.25` to `tags: ["song", "music"]`, spent on next song/music hit or evade | Cooldown set to 1.5 s so `thorn-lullaby` lands within 1 s |
| `echo-wall` | For a few seconds each art cast at the holder returns a soft echo that heals her for a part of its damage. (Canon: notes stack Resonance.) | `c_art 0.0`, `cost_share 0.04`, `cd 6.0`; 4 s charge counter `echo_wall`; `was_hit` (`kind: "art"`, `event.amount > 0`) heals 25 % of `event.amount` (max 3/pulse); every `song` `art_fired` adds 1 `resonance` on foe | Timed counter instead of stance; Resonance added as `foe.counter.resonance` |
| `ten-thousand-ravines` | The foe takes Force damage for each Resonance stack it carries; then half its stacks (rounded down) are laid on it again as a new batch. | `c_art 1.5`, `cost_share 0.06`, `cd 6.0`, `convert: {to: "force", share: 1.0}`; `art_fired` deals `free_hit` `0.25 c` Force per `foe.counter.resonance`, then halves `foe.counter.resonance` via `res_keep` (`per: 2`) | Uses `foe.counter.resonance` rather than a timed debuff batch |
| `the-held-rest` | For two seconds after your song ends, the foe casts more slowly; after a Marching Dirge finale the rest lasts 0.5 s per Measure spent (each later one half as long), and the foe's arts cost more while it holds (The Earned Rest). | `c_art 0.0`, `cost_share 0.03`, `cd 5.0`; `art_fired` sets `held_rest = 2` (decremented on `pulse`) and lays `slowed_time` (`stacks: 1, dur: 2, cap: 1`) | None (Earned Rest extends `held_rest` + adds `heavy_breath`) |
| `empty-ravine` | Removes all buffs on one foe that were given by a song, drum or bell. | `c_art 1.4`, `cost_share 0.03`, `cd 5.0`, `convert: {to: "force", share: 1.0}`; `hit_landed` strips up to 3 stacks of the foe's largest buff pile and lays `silence` (`tag: "song"`, `dur: 3`) | `strip` does not filter by `song`/`drum`/`bell` source tags; paired with `silence [song]` and Force hit |

## E. Effects (`effects/van_hac.effects.json`)

| Effect (source) | Depth text | Engine form | Deviation |
|---|---|---|---|
| `The Earned Rest` (`the-monks-rest`, layer 4, `d28`) | When your Marching Dirge finale ends a march, The Held Rest starts at once and lasts 0.5 s for each Measure the finale spent instead of 2 s, and each later finale's rest this fight is half as long as the one before; while it holds, the foe carries one Heavy Breath stack (its arts cost 25 % more). | Tracks `earned_measures` on `pulse` while `own.state.march >= 1` (because `march-reset` clears `measure` before `tech_effects` run); on `marching-dirge` finale sets `held_rest = max(1, floor(M / 2^(halvings+1)))`, increments `earned_halvings`, resets `earned_measures`, and keeps 1 `slowed_time` + 1 `heavy_breath` (`cap: 1`) while `held_rest >= 1` | Minimum 1 pulse rest for any finale with >= 1 Measure |
| `Pines in Ten Thousand Ravines` (`vh-tung-phong-cam`) | Each note of a song art played on this zither also sounds once more a second later from a random point near the foe, as an echo with half the effect. Echoes add Resonance but cannot themselves echo. | Queues 1 in `cam_echo` per `song` `art_fired`; on `pulse`, fires `free_hit` `0.8 c` Force + 1 `resonance` on foe per queued note and clears `cam_echo` (`free_hit` does not emit `art_fired`, so echoes never re-echo) | Spatial phrase `"from a random point near the foe"` dropped per No Spatial Fight rule; uses 0.8 Force `free_hit` on `pulse` |
| `The Unplayed Note` (`vh-stringless-zither`) | While you hold the Monk's Rest silence, this zither plays the note you did not: the next song art you cast after the silence costs no linh lực. | Arms `unplayed_armed` whenever `held_rest >= 1`; on `pulse` when `unplayed_armed == 1` and `held_rest == 0`, grants `next_art_cost: 0` for `tags: ["song"]` and clears `unplayed_armed` | None |
| `Silence After the Twelfth` (`vh-monks-things` 3-pc) | each echo the Zither sounds adds one Resonance to its foe; when you stop playing (The Held Rest), a foe with 6 or more Resonance falls into the silence: its next art fails and its casting is 30 % slower for 3 s. | On `the-held-rest` or `marching-dirge` finale (`own.state.march == 0 && own.counter.held_rest >= 1`) with `foe.counter.resonance >= 6` (`cooldown: 5`), calls `stop_clock` 1.0 s on foe and lays `slowed_time` 3 stacks for 3 s | Uses `stop_clock` 1.0 s + `slowed_time` x3 (`approx`) instead of single-tag `silence` |

## F. Items & Sets (`catalogue-sect-van_hac.json`, `sets-van_hac.json`)

- **4 items, 1 set (`vh-monks-things`):** modifiers match `van_hac.items.json` verbatim. All 4 pieces carry `sources: ["npc"]` and `unique: true`; `vh-tung-phong-cam` carries `rarity: 5`; weapon (`cam`) and robe (`dao_bao`) pieces carry the R6 `exception` mark.
- **Stand-ins / Beasts:** 0 stand-ins, 0 beasts.

## G. Holder Check (`sect_fight.py van_hac --seeds 5`)

| Holder | Realm | Arts | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effects (`runs` at gap 0; `with` vs `without`) |
|---|---|---|---|---|---|
| `ha_thinh_tung` | `ket_dan` | `marching-dirge`, `echo-wall`, `ten-thousand-ravines`, `the-held-rest`, `empty-ravine`, `thorn-lullaby` | 26.9 s, 5/5, 100 % | 11.0 s, 0/5, 0 % | `The Earned Rest`: 230 runs (26.9 s 100 % vs 28.5 s 100 %); `Pines in Ten Thousand Ravines`: 328 runs (26.9 s 100 % vs 32.4 s 99 %); `Silence After the Twelfth`: 30 runs (26.9 s 100 % vs 26.9 s 100 %; at gap 1: 11 runs, 11.0 s vs 9.7 s) |
| `cu_dong_moc` | `ket_dan` | `marching-dirge`, `echo-wall`, `ten-thousand-ravines`, `the-held-rest`, `empty-ravine` | 35.4 s, 5/5, 48 % | 8.1 s, 0/5, 0 % | `The Earned Rest`: 290 runs (35.4 s 48 % vs 36.2 s 10 %); `The Unplayed Note`: 237 runs (35.4 s 48 % vs 38.2 s 0 %) |
| `quan_tich_am` | `truc_co` | `marching-dirge`, `echo-wall`, `ten-thousand-ravines`, `the-held-rest`, `empty-ravine` | 33.6 s, 2/5, 3 % | 8.0 s, 0/5, 0 % | `The Earned Rest`: 262 runs (33.6 s 3 % vs 32.2 s 0 %) |
| `khuong_lac_huyen`, `man_ti_truc`, `han_thanh_huong`, `phuong_tung_ban` | `truc_co` | `marching-dirge`, `echo-wall`, `ten-thousand-ravines` | 39.8 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | — (no authored items/Earned Rest) |
| `tham_du_van` | `truc_co` | `marching-dirge`, `echo-wall`, `ten-thousand-ravines`, `the-held-rest`, `empty-ravine` | 32.2 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | — (`the-monks-rest` L2 < L4) |
| `ton_thinh_ha`, `cat_minh_huyen`, `yen_to_huyen`, `te_tieu_van` | `luyen_khi` | `marching-dirge`, `echo-wall` | 41.4 s, 0/5, 0 % | 8.0 s, 0/5, 0 % | — |
| `au_tieu_mien`, `thoi_luc_linh`, `manh_tieu_ca`, `co_minh_thach`, `bang_thach_khanh`, `khuc_hanh_ca` | `luyen_khi` | `plucked-pitch`, `thorn-lullaby` | 35.2 s, 5/5, 59 % | 8.0 s, 0/5, 0 % | — (trace confirmed `plucked-spend`: 4 on `au_tieu_mien`) |

Every art fired on every holder, and every Effect ran on its holders. `Silence After the Twelfth` had identical win/time at `--gap 0` (seed 1–5 already 26.9 s 100 % due to `ha_thinh_tung`'s full set), and extended survival at `--gap 1` (11.0 s vs 9.7 s, 11 runs).

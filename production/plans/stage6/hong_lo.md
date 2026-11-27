# Stage 6: Hồng Lô Cốc (`hong_lo`, progress file)

Method: `production/plans/world-depth-implementation.md` Stage 6 and `production/plans/stage6/_brief-record.md` (decisions auto-accepted per user 2026-11-26).
Resume here: read this file, then do the first unchecked step.

## Scope (`python -I tools/design/world/depth_gap.py --sect hong_lo`)
- 3 proposal techniques: `snow-hearth-primer` (Yellow main, `hoa`/`thuy`), `water-over-fire-canon` (Earth secret, `hoa`/`thuy`), `whale-road-harpoon` (Profound secret, `thuy`). Existing lineage: `red-sun-scripture`.
- 4 new arts: `bank-the-coal`, `steam-from-the-jacket`, `the-pot-is-finished`, `line-on-the-whale`. (3 referenced arts `brazier-form`, `furnace-heart`, `drag-of-the-deep` already run.)
- 6 items (`hlo-nine-year-ember`, `hlo-snow-melt-gourd`, `hlo-whale-road-spear`, `hlo-coal-carrier-ring`, `hlo-first-snow-jacket`, `hlo-steam-censer`), 2 sets (`hlo-ky-te`, `hlo-snow-hearth`), 4 Effects (`It Does Not Cool`, `Quench the Jacket`, `Ký Tế`, `A Second Early`).
- 4 stand-ins: `duong_bat_oan`, `duong_thang_nhi` (`hoang_hoa`), `giai_bach_bo`, `cuc_xa_tien` (`huyen_moc`).
- 0 beasts; 6 structured events; 0 tie overflow, 0 cross-owner refs, 0 engine words, 0 open wishes.

## Step 1 result: Mechanic table
`spatial_words_check.py`: only 1 `soft` hit in `items.build_use` (`beside`) and 1 `postponed` hit in `ties.note` (`ally`). No rule text hits.

| Kind | Name / ID | State | Implementation / Decision |
|---|---|---|---|
| Tech | `snow-hearth-primer` | has | Tier 0 main, `hoa`/`thuy`, 6 layers, 0 bonuses, passives sized to 7.6 W / 8 W (`linh_luc_regen_inc_pct` 4, `attack_pct` 3 `[fire]`, `stack_duration_pct` 6 `[hoa, debuff]`, `khi_huyet_pct` 2). Arts: `brazier-form` (L1), `bank-the-coal` (L2). |
| Tech | `water-over-fire-canon` | has | Tier 2 secret, `hoa`/`thuy`, 12 layers, 2 bonuses (`alchemy_success` 6, `linh_luc_pct` 15), passives 22.9 W / 24 W. Arts: `furnace-heart` (L1), `steam-from-the-jacket` (L2), `the-pot-is-finished` (L4). |
| Tech | `whale-road-harpoon` | has | Tier 1 secret, `thuy`, 9 layers, 1 bonus (`khi_huyet_pct` 10), passives 15.3 W / 16 W. Arts: `drag-of-the-deep` (L1), `line-on-the-whale` (L3). |
| Tech (stand-in) | `broth-kettle-breath` (new) | has | Tier 0 `tap_dich` kitchen method (`hoa`/`thuy`, 6 layers, 7.2 W / 8 W, art `skimming-the-broth` L1) for `duong_bat_oan` and `duong_thang_nhi`. |
| Tech (stand-in) | `satchel-hall-healing-canon` (new) | has | Tier 1 `chap_su` Thanh Nang healing method (`moc`/`thuy`, 9 layers, 15.4 W / 16 W, `seed-of-spring` L1 + `second-spring` L4) for `giai_bach_bo` and `cuc_xa_tien`. Separate ID from `thuy_vi`'s `thanh-nang-balm-canon` to avoid staged ID clash. |
| Art | `bank-the-coal` | has | `element: "fire"`, `debuff: [1, 6]`, counter `coal` (`each_for: 6`); `hit_landed` (`fire`) adds 1 coal; `art_fired` (`water`) with `coal >= 1` spends 1 coal, lays 2 Burn (6 s), restores 3% qi. |
| Art | `steam-from-the-jacket` | has | `element: "water"`, `tags: ["cold", "water", "seal", "steam", "heal"]`, `hit_landed` with `foe.debuff.fire >= 3`: sets `leech_hp: 33.3` (1 ms), consumes Burn (`per: 3`), records `steam_spent`, fires `0.45 Fire + 0.45 Cold` `free_hit`s per 3 stacks. |
| Art | `the-pot-is-finished` | decision | Counter `ky_te` (8 s, `cd 8.0`) so `brazier` stance is not overwritten (omit `"stance"` tag so `brazier-toggle` does not fire); grants 1 Fire + 1 Water buff (6 s) on cast so holders without external buff arts run it; `art_speed 25 [heal]` + `cost_red 0.2 [fire]` while both hold; breaks with `0.6 c` Fire `self_hit` when either runs out. Pill speed noted as awaiting Alchemy pass. |
| Art | `line-on-the-whale` | has | Counter `whale_line` (6 s) + `silence` (`tag: "movement"`, clamped to 5 s curse max); while `whale_line >= 1`, `hit_landed` (`water`) adds 1 `slowed_time` (3 s). |
| Art (stand-in) | `skimming-the-broth` (new) | has | Elementless heal (`c_heal: 0.55`, `cost_share: 0.03`, `cd: 5.0`) for `broth-kettle-breath`. |
| Effect | `It Does Not Cool` | has | `was_evaded` refreshes foe Burn batches (`at_least: 6`); `cleansed` (`amount > 5`, `per_fight: 1`) restores that many Burn stacks (8 s). |
| Effect | `Quench the Jacket` | has | `was_hit` / `tick_taken` (`dtype: "fire"`, `quench_cd` 2 s) grants 1 Water buff (10 s); `pulse` (`own.buff.water >= 3`, `cd: 2`) cleanses 1 own Burn stack (`approx` for 2x Burn expiry). |
| Effect | `Ký Tế` | has | `heal_restored` refreshes foe Burn (`at_least: 4`); `art_fired` (`tags: ["heal"]`, `foe.debuff.fire >= 1`) consumes 1 Burn for `0.06 c` Fire `free_hit` (3 s of 1 Burn). |
| Effect | `A Second Early` | decision | Pill speed noted as awaiting Alchemy pass; `hit_landed` (`tags: ["steam"]`, `steam_spent > 0`) heals `2%` max HP per Burn stack spent (`steam_spent` reset to 0). |
| Items & sets | 6 items, 2 sets | has | `hlo-nine-year-ember` treasure given `rarity: 5` (`resist_pct` scope `["cold"]`); `hlo-whale-road-spear` `attack_pct` scope `["thuy"]`; R6 `exception` on `hlo-snow-melt-gourd`, `hlo-whale-road-spear`, `hlo-first-snow-jacket`; all 6 `sources: ["npc"]`, `unique: true`. |

## Steps
- [x] 1. Verify first: mechanic table written above, `spatial_words_check.py` checked.
- [x] 2. Techniques and arts (staged in `design/stage6-staging/hong_lo/techniques/catalogue-sect-hong_lo.json` and `arts/part-sect-hong_lo.json`; `hong_lo.techniques.json` updated).
- [x] 3. Effects (staged in `design/stage6-staging/hong_lo/effects/hong_lo.effects.json`).
- [x] 4. Items and sets (staged in `design/stage6-staging/hong_lo/items/catalogue-sect-hong_lo.json` and `sets-hong_lo.json`).
- [x] 5. Stand-ins cleared (`giai_bach_bo`, `cuc_xa_tien`, `duong_bat_oan` in `hong_lo.cast.json`; `duong_thang_nhi` in `hong_lo.5.cast.json`).
- [x] 6. Beasts: none (`beasts: 0`).
- [x] 7. Holder check (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\hong_lo`):
      - `lint_techniques.py`: 5 techniques, 0 findings.
      - `lint_arts.py`: 5 arts, 0 findings.
      - `lint_items.py`: 6 items, 0 findings.
      - `depth_check.py`: findings: none; `depth_gap.py --sect hong_lo`: stand_ins 0, unknown_ids 0, engine_words 0, wishes_open 0.
      - `sect_fight.py hong_lo --seeds 20` & `--gap 1`: all arts fire, no REFUSED holder, synthetic probes verify `It Does Not Cool`, `Ký Tế`, `Quench the Jacket`, and `A Second Early`.
- [x] 8. Review file (`production/plans/stage6/hong_lo-review.md`).
- [x] 9. Finish (`RECORD PASS DONE` below and `production/plans/stage6/hong_lo.done`).

RECORD PASS DONE

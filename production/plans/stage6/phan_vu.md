# Stage 6: Phần Vũ Đường (`phan_vu`) — progress file

Method: `production/plans/stage6/_brief-record.md` (headless record pass, decisions auto-accepted).
Staging folder: `design/stage6-staging/phan_vu/`.

## Scope (initial `depth_gap.py --sect phan_vu`, 2026-11-27)
- 3 depth techniques: `vent-sitting-breath` (Yellow main, Fire+Earth), `burning-feather-body-canon` (Profound main, Fire+Earth), `red-wall-rebirth` (Earth secret, Fire). Existing in cast: `scorch-fist-primer`, `mountain-heart-canon`.
- 7 depth arts (1 already engine-form `into-the-vent` e3 in `auth-tech.json`, 6 rule text).
- 6 items (`pvd-xich-ha-ky` treasure + 5 artifacts), 2 sets (`pvd-standing-fire`, `pvd-sitting-master`), 3 Effects (`Red Cloud Rising`, `Burn and Get Back Up`, `Let You Burn Out`).
- 29 modifier lines (all 29 already run).
- 0 beasts, 6 structured events, 1 stand-in (`boc_than`: `hoang_moc` 5), 0 cross-owner refs, 0 tie issues.

## Stand-ins (resolved)
| Person | Root | Was | Now |
|---|---|---|---|
| `boc_than` | Wood 44, Water 30 | `hoang_moc` 5 | `charcoal-pit-breath` 5 (new `phan_vu` Yellow Wood+Water servants' method, art `bank-the-kiln`) |

## Steps
- [x] 1. Verify first: ran `depth_gap.py --sect phan_vu` (with `--list` for all open sections) and `spatial_words_check.py`. Built the mechanic table; zero new engine words needed (all 8 arts and 3 Effects run on existing engine words; `Red Cloud Rising` rewritten from allies/cloud to wearer per 2026-11-26 ruling; `Burn and Get Back Up` body-shield break tracked on `was_hit` via `body_shield_up`).
- [x] 2. Techniques and arts (staged):
      - `design/stage6-staging/phan_vu/techniques/catalogue-sect-phan_vu.json`: 4 techniques (`vent-sitting-breath` 7.7 W/8, `burning-feather-body-canon` 15.8 W/16, `red-wall-rebirth` 23.7 W/24, `charcoal-pit-breath` 7.0 W/8).
      - `design/stage6-staging/phan_vu/arts/part-sect-phan_vu.json`: 8 arts (`hot-rock`, `shake-off-the-ash`, `feathers-burn`, `stand-in-the-ash`, `into-the-vent`, `wall-of-red-rock`, `nirvana-of-the-red-wall`, `bank-the-kiln`).
      - Registered art ids and `charcoal-pit-breath` in `design/world/depth/sects/phan_vu.techniques.json`.
- [x] 3. Effects (staged):
      - `design/stage6-staging/phan_vu/effects/phan_vu.effects.json`: `Red Cloud Rising`, `Burn and Get Back Up`, `Let You Burn Out`, each declaring every counter it reads or writes in its own `"counters"` array for standalone GDScript compilation.
- [x] 4. Items and sets (staged):
      - `design/stage6-staging/phan_vu/items/catalogue-sect-phan_vu.json`: 6 items (`sources: ["npc"]`, `unique: true`, `pvd-xich-ha-ky` `rarity: 5` + `legendary_key: "xich_ha_ky"`, R6 `exception` on the 3 armour/shield pieces).
      - `design/stage6-staging/phan_vu/items/sets-phan_vu.json`: 2 sets (`pvd-standing-fire`, `pvd-sitting-master`).
- [x] 5. Stand-ins: updated `boc_than` in `design/world/depth/sects/phan_vu.cast.json` from `hoang_moc` to `charcoal-pit-breath` (layer 5).
- [x] 6. Beasts: none (`phan_vu` has 0 beasts).
- [x] 7. Holder check (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\phan_vu`):
      - `lint_arts.py`: 8 arts, **0 findings**.
      - `lint_techniques.py`: 4 techniques, **0 findings**.
      - `lint_items.py`: 6 items, **0 findings** (`unique 6 of 6`).
      - `depth_check.py --quiet`: **findings: none**.
      - `depth_gap.py --sect phan_vu`: `stand_ins: 0`, `unknown_ids: 0`, `cross_owner: 0`, `engine_words: 0`, `wishes_open: 0`, `lines: 29/29 runs`.
      - Standalone `engine.validate` per Effect: **STANDALONE_OK** on all 3 Effects.
      - `sect_fight.py phan_vu --seeds 5` (`gap 0` and `gap 1`) + 20-seed probes: **0 REFUSED**, all 8 staged arts fire, all 3 Effects run and change fight outcomes (`Red Cloud Rising` −6.9 s at `gap 0` / +1.8 s at `gap 1`, solo 20 % rise 20/20; `Burn and Get Back Up` +1.0 s, 21/21 breaks->Fire fists, 20/20 33 % rises at `gap 1`; `Let You Burn Out` −1.8 s at `gap 0`, 69 releases + 201 thorns; `nirvana-of-the-red-wall` 20/20 50 % rises at `gap 1`).
- [x] 8. Review file: written to `production/plans/stage6/phan_vu-review.md` (ending with `REVIEW DONE`).
- [x] 9. Finish: wrote `production/plans/stage6/phan_vu.done` and closed this progress file.

RECORD PASS DONE

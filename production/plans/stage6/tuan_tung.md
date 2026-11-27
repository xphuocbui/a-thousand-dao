# Stage 6: Tuần Tùng Đường (`tuan_tung`) — progress file

Method: `production/plans/world-depth-implementation.md` Stage 6 and `production/plans/stage6/_brief-record.md` (headless job, decisions auto-accepted).

## Scope (`python -I tools/design/world/depth_gap.py --sect tuan_tung`)
- **3 techniques** (all Tier 1 Profound, `names: []`): `pine-warden-staff-and-bow-canon` (main), `three-nights-on-the-road` (secret), `wolf-winter-arrow` (secret). Outer gate `unbroken-flesh-canon` is already in `design/techniques/catalogue-body.json`.
- **4 new arts** (`wolf-ring`, `second-night`, `the-leader-first`, plus passive art `Warden Geese Line` for `Geese Line (Nhạn Hàng)` `d17`) and **2 existing library arts** (`pinning-arrow`, `nocked-arrow` in `design/arts/family-blade.json`).
- **3 signature items** (`ttg-wolf-winter-bow`, `ttg-caravan-bell`, `ttg-three-nights-coat`), **1 set** (`ttg-three-nights`), **4 Effects** (`Warden Geese Line`, `The Pack Turns`, `Ring for the Wardens`, `Dawn Shot`).
- **1 beast** (`thuong_muc`, already wired on `diem_lac_nhan.beasts`), **2 events** (`N-tuan_tung-01`, `N-tuan_tung-02`, structured).
- **0 stand-ins**, **0 cross-owner references**, **0 tie issues**.

## Steps
- [x] 1. Verify first: mechanic table & `spatial_words_check.py --sect tuan_tung`.
- [x] 2. Techniques and arts (staged in `design/stage6-staging/tuan_tung/techniques/catalogue-sect-tuan_tung.json` and `arts/part-sect-tuan_tung.json`; art IDs inserted in `design/world/depth/sects/tuan_tung.techniques.json`).
- [x] 3. Effects (staged 4 Effects in `design/stage6-staging/tuan_tung/effects/tuan_tung.effects.json`; `STANDALONE_OK 4`).
- [x] 4. Items and sets (staged 3 items in `items/catalogue-sect-tuan_tung.json` and 1 set in `items/sets-tuan_tung.json`).
- [x] 5. Stand-ins (none needed: 0 across all 16 living members).
- [x] 6. Beasts (`thuong_muc` verified already wired on `diem_lac_nhan.beasts` in `tuan_tung.cast.json` and valid in `tuan_tung.beasts.json`).
- [x] 7. Holder check (`lint_arts.py`: 0 findings; `lint_techniques.py`: 0 findings; `lint_items.py`: 0 findings; `depth_check.py --quiet`: findings none; `spatial_words_check.py`: 0 hits in staged files; `sect_fight.py tuan_tung --seeds 5` at `--gap 0` & `--gap 1` + outer `--people` + `PROBE_GLOW_30`, `PROBE_DIEM_EAGLE`, `PROBE_TRANG_COMPANION`, `PROBE_DAWN`: 0 REFUSED across all 16/16 living members, all slotted arts fire, all Effects verified).
- [x] 8. Review file (`production/plans/stage6/tuan_tung-review.md`).
- [x] 9. Finish (`production/plans/stage6/tuan_tung.done` written and validated).

RECORD PASS DONE

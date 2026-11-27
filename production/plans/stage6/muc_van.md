# Stage 6: Mục Vân Trang (`muc_van`) — progress file

Method: `production/plans/stage6/_brief-record.md` (decisions auto-accepted, user rule 2026-11-26; staged in `design/stage6-staging/muc_van/`).

## Scope (initial gap report `depth_gap.py --sect muc_van`)
- 2 depth techniques (`cloud-herd-body-canon`, `herd-call`) + 1 new Yellow servants' method (`river-ice-groom-breath`) for stand-in `hua_tich_cau`. Existing in lineage: `mountain-bone-body-art`, `gale-courier-scripture`.
- 5 depth new arts (`the-long-ride`, `run-with-the-herd`, `bridle-hand`, `whistle-home`, `the-herd-turns`) + 1 new art (`two-bucket-haul`).
- 6 items, 2 sets, 4 Effects (2 item: `Turn the Herd`, `Horse and Rider Bear It Together`; 2 set: `One Thread of Wind`, `Ninety Thousand Li`).
- 2 beasts (`dap_van` on `khau_muc_van`, `hong_tong` on `tan_thien_ly`), 4 structured events (`N-muc_van-01`..`04`).
- 1 stand-in (`hua_tich_cau`: `hoang_thuy` layer 3 -> `river-ice-groom-breath` layer 3).
- 0 cross-owner refs, 0 unknown ids, 0 over-cap ties, 0 unmapped ties, 0 pending engine words.
- Authored wish records incorporated: `d20` (`the-long-ride-timeline`, `auth-eff-1.json`), `d42` (`horse-and-rider-bear-it-together`, `auth-eff-2.json`), plus non-spatial `a1` rewordings.

## Steps
- [x] 1. Verify first: ran `depth_gap.py --sect muc_van` (+ `--list` on all open sections) and `spatial_words_check.py` (3 hits on `muc_van`, all false positives / soft: time window "within 1 s" and lore "beside"). Built the full mechanic table (`muc_van-review.md` §B).
- [x] 2. Techniques and arts (staged): wrote `design/stage6-staging/muc_van/techniques/catalogue-sect-muc_van.json` (3 techniques, passives sized to tier budgets: `16.0/16`, `15.8/16`, `8.0/8`) and `design/stage6-staging/muc_van/arts/part-sect-muc_van.json` (6 arts). Registered all 6 art ids and `river-ice-groom-breath` in `design/world/depth/sects/muc_van.techniques.json`.
- [x] 3. Effects (staged): wrote `design/stage6-staging/muc_van/effects/muc_van.effects.json` (4 Effects, every counter explicitly declared on its own Effect for standalone GDScript compilation; `pending.json` empty).
- [x] 4. Items and sets (staged): wrote `design/stage6-staging/muc_van/items/catalogue-sect-muc_van.json` (6 items, `sources: ["npc"]`, `unique: true`, R6 `exception` on weapon/armour/robe) and `design/stage6-staging/muc_van/items/sets-muc_van.json` (2 sets).
- [x] 5. Stand-ins: resolved `hua_tich_cau` (`hoang_thuy` 3 -> `river-ice-groom-breath` 3) in `design/world/depth/sects/muc_van.cast.json`. `stand_ins` gap = 0.
- [x] 6. Beasts: verified `khau_muc_van` carries `beasts: ["dap_van"]` and `tan_thien_ly` carries `beasts: ["hong_tong"]` in `muc_van.cast.json`, matching `muc_van.beasts.json`.
- [x] 7. Holder check (with `DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\muc_van`):
  - `lint_arts.py`: 6 arts, **0 findings**.
  - `lint_techniques.py`: 3 techniques, **0 findings** (`16.0/16`, `15.8/16`, `8.0/8`, 0 `OVER_BUDGET`).
  - `lint_items.py`: 6 items, **0 findings** (`unique 6 of 6`).
  - `depth_check.py --quiet`: **findings: none**.
  - `depth_gap.py --sect muc_van`: `stand_ins 0`, `unknown_ids 0`, `cross_owner 0`, `lines 25/25 runs`.
  - Standalone Effect validation (`engine.validate` + counter declaration scan): all 4 Effects pass with 0 undeclared counters.
  - `sect_fight.py muc_van --seeds 10` (`gap 0` and `gap 1`): **0 REFUSED**, **0 NEVER_FIRED**, **0 NEVER_RAN**; all 4 Effects run and alter fights, confirmed further in 20-seed probes including `khau_muc_van` with `dap_van` as permanent companion.
- [x] 8. Review file: wrote `production/plans/stage6/muc_van-review.md` (ending with `REVIEW DONE`).
- [x] 9. Finish: wrote `production/plans/stage6/muc_van.done`.

RECORD PASS DONE

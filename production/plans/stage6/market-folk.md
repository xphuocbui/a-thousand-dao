# Stage 6 Record Pass — `market-folk` (Batch `b06`)

Scope: `design/world/depth/people/market-folk.*` -> `design/stage6-staging/market-folk/` (staged artefacts only; committed `design/` and `assets/` untouched until `--merge`).

## Checklist

- [x] **Step 1 — Inventory (`depth_gap.py --sect market-folk`)**:
  - 4 techniques (`censer-smoke-manual` already in committed `design/techniques/`, 3 proposals open)
  - 7 `arts_new` (`pill-smoke` already in `design/arts/part-sect-market-folk.json`, 6 open)
  - 1 `arts_ref` (`runs`)
  - 25 items, 8 sets
  - 18 Effects (`Know the Way Out` clashes with `world-depth:thien_xu`; 17 `market-folk`-owned Effects; duplicate `"Second Spring"` item vs set resolved by renaming the set bonus to `"Apricot Clinic's Spring (Hạnh Quán Hồi Xuân)"`)
  - 20 stand-ins across `market-folk.cast.json` and `market-folk.2.cast.json`
  - 11 cross-owner lines (all `catalogue` and already committed in `design/techniques/`)
- [x] **Step 2 — Decisions**: Auto-accepted for headless Stage 6 batch (`b06`); recorded with reasons in `production/plans/stage6/market-folk-review.md`.
- [x] **Step 3 — Technique & Art Records**: Preserved committed `censer-smoke-manual` & `pill-smoke`, authored the 3 proposed techniques + 6 proposed arts, plus 4 new stand-in techniques & 5 stand-in arts; linked IDs in `market-folk.techniques.json`.
- [x] **Step 4 — Effect, Item & Set Records**: Staged `effects/market-folk.effects.json` (17 Effects, standalone-complete `counters`/`states`), `items/catalogue-sect-market-folk.json` (25 items), `items/sets-market-folk.json` (8 sets); resolved `Know the Way Out` (`"new": false`) and `"Apricot Clinic's Spring"` in `market-folk.items.json`.
- [x] **Step 5 — Stand-Ins Resolved**: Replaced all 20 stand-ins in `market-folk.cast.json` and `market-folk.2.cast.json`, and equipped signature techniques on `lac_dan_thanh` (`censer-smoke-manual`), `gia_hoi_xuan` (`second-spring-needle-art`), and `ve_van_co` (`loom-of-letters-array`).
- [x] **Step 6 — Verification Suite (`DEPTH_STAGE`)**: Ran `lint_arts.py` (0), `lint_techniques.py` (0), `lint_items.py` (0), standalone `engine.validate` (17/17 OK), spatial scan (0 hits), `depth_check.py --quiet` (0 `market-folk` findings), `depth_gap.py --sect market-folk` (0 stand-ins, 0 unknown IDs, 0 open wishes), `stage6_merge.py market-folk --check` (0 failures), `sect_fight.py market-folk --seeds 5` (`--gap 0` & `--gap 1`, 0 `REFUSED`), plus targeted Effect probes (`pill OK/FAIL`, `Apricot Clinic's Spring`, `Second Spring`, `The Books Balance`, `Call the Debt`, `Paid in Full`, `Heavy Keel`).
- [x] **Step 7 — Close Out**: Wrote `market-folk-review.md`, `market-folk.done`, and finalized plan.

RECORD PASS DONE

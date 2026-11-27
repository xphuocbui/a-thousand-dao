# Stage 6 Record Pass — `vong_trieu` (Vọng Triều Đường)

Owner: `vong_trieu`
Brief: `production/plans/stage6/_brief-record.md`
Plan ref: `production/plans/world-depth-implementation.md`
Staging dir: `design/stage6-staging/vong_trieu/`

## Checklist
- [x] Step 1 — Verify source files, gap audit, and mechanic table
- [x] Step 2 — Stage active arts (`design/stage6-staging/vong_trieu/arts/part-sect-vong_trieu.json`) and wire `"id"` / `"unlock_layer"` into `design/world/depth/sects/vong_trieu.techniques.json`
- [x] Step 3 — Stage techniques (`design/stage6-staging/vong_trieu/techniques/catalogue-sect-vong_trieu.json`) with tier-1 caps, `names` lint proxy, and `effects` passive arts
- [x] Step 4 — Stage effects (`design/stage6-staging/vong_trieu/effects/vong_trieu.effects.json`) with standalone GDScript counter/state declarations
- [x] Step 5 — Stage items (`design/stage6-staging/vong_trieu/items/catalogue-sect-vong_trieu.json`) and sets (`design/stage6-staging/vong_trieu/items/sets-vong_trieu.json`)
- [x] Step 6 — Run linters (`0 findings`), `depth_check.py`, `depth_gap.py --sect vong_trieu`, standalone GDScript counter check, `sect_fight.py` (`--gap 0` / `--gap 1`), and targeted probes
- [x] Step 7 — Write `production/plans/stage6/vong_trieu-review.md`, finalize this plan, and write `production/plans/stage6/vong_trieu.done`

## Scope Summary
- **Techniques (3 staged):** `lamp-ward-seal-canon` (main, tier 1, `14.4 W of 16`), `tide-reading-gaze` (secret, tier 1, `12.7 W of 16`), `last-lamp-vigil` (secret, tier 1, `15.6 W of 16`).
- **Arts (6 active staged):** `set-the-lamp`, `line-of-lamps`, `read-the-swell`, `far-watch`, `bind-the-flame`, `the-lamp-stays-lit`.
- **Effects (5 staged):** `Lamp-Ward` (tech passive L3), `The Lamp Flares` (tech passive L4), `The Lamp That Is Not Out` (`vtd-unsleeping-lamp`), `Not One Lamp Out` (`vtd-lamp-chain` 3pc), `Layered Against the Tide` (`vtd-breakwater` 3pc).
- **Items & Sets (6 items, 2 sets staged):** `vtd-unsleeping-lamp`, `vtd-breakwater-seal`, `vtd-kim-sa-seal`, `vtd-pearl-diver-robe`, `vtd-sea-wall-shield`, `vtd-jetty-stone`; `vtd-lamp-chain`, `vtd-breakwater`.
- **Stand-ins / Beasts / Pending words:** `0` stand-ins, `0` beasts, `0` cross-owner refs, `0` pending engine words.

RECORD PASS DONE

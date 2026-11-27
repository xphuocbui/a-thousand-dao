# Stage 6: Minh Loan Các (progress file)

Method: `production/plans/world-depth-implementation.md` Stage 6, "the per-sect method" and `production/plans/stage6/_brief-record.md`.
Owner: `minh_loan`. Decisions are auto-accepted (user 2026-11-26) and logged in `production/plans/stage6/minh_loan-review.md`.

## Scope (gap report `python -I tools/design/world/depth_gap.py --sect minh_loan`)
- **4 techniques:** `clay-mould-primer` (Yellow main), `singing-luan-bell-canon` (Profound main), `hanging-bells-array` (Profound secret), `unstruck-bell-canon` (Earth secret).
- **7 new arts + 1 existing ref:** `fired-mould`, `carriage-bell`, `ward-peal`, `hang-the-bells`, `alarm-line`, `struck-it-answers`, `the-bell-that-rings-itself`, plus existing `mountain-stance` (`family-earth.json`).
- **6 items, 2 sets, 3 Effects** (`Rings as It Moves`, `Struck, She Rings`, `Forty Answer`).
- **0 stand-ins, 0 beasts, 3 structured events, 0 cross-owner references.**

## Steps
- [x] 1. Verify first: mechanic table below, `spatial_words_check.py` (`0` non-soft hits, `5` soft `"beside"` hits in `build_use` / `ties.note`).
- [x] 2. Techniques and arts (staged in `design/stage6-staging/minh_loan/`).
- [x] 3. Effects (staged in `design/stage6-staging/minh_loan/effects/minh_loan.effects.json`; `0` pending words).
- [x] 4. Items and sets (staged in `design/stage6-staging/minh_loan/items/`).
- [x] 5. Stand-ins (`0`, none needed) and depth art `"id"` entries in `design/world/depth/sects/minh_loan.techniques.json`.
- [x] 6. Beasts (`0`, none).
- [x] 7. Holder check (`$env:DEPTH_STAGE = "C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\minh_loan"`):
      - `lint_arts.py`: `7 arts in 1 files, 0 findings`.
      - `lint_techniques.py`: `4 techniques, 0 findings` (`7.8/8`, `15.1/16`, `15.4/16`, `24.0/24`).
      - `lint_items.py`: `6 items, 22 bases, 9 common arts, 0 findings` (R6 exceptions on 3 `chuong` + 1 `dao_bao`; `rarity: 5` on treasure `ml-luan-bell`).
      - Standalone Effect validation (`engine.validate` + self-declared counters/states): `0` errors on all 3 Effects.
      - `depth_check.py --sect minh_loan`: `findings: none`; `depth_gap.py --sect minh_loan`: `unknown_ids: 0`, `engine_words: 0`.
      - `sect_fight.py minh_loan --seeds 20` and `--gap 1 --seeds 5`: `0 REFUSED`, `0 NEVER_FIRED`, `0 NEVER_RAN`, `clipped: {}` across all 18 living cast members; all 3 Effects measurably change fights on their holders (`Rings as It Moves` 19.5 s vs 20.5 s, `Struck, She Rings` 19.5 s 100% vs 22.7 s 95%, `Forty Answer` 33.0 s vs 38.8 s); all `--gap 1` fights lose `0/5`.
- [x] 8. Review file (`production/plans/stage6/minh_loan-review.md`, ending with `REVIEW DONE`).
- [x] 9. Finish (`RECORD PASS DONE`, `production/plans/stage6/minh_loan.done`).

## Step 1: Mechanic table

| Record | Mechanic | Group / Resolution |
|---|---|---|
| `clay-mould-primer` | Tier 0 main (`tho`, `kim`, 6 layers); no bonuses/passives in depth | Engine has it (new passives sized to `7.8/8 W`) |
| `fired-mould` | Baked clay skin for 3 s, blocks next hit, rings for 1 Earth stack on break | Engine has it (`ward_grow 0.08`, `block +20 for 3`, `shield_broken` `stance_ward` -> Earth debuff; avoids stance conflict with `mountain-stance`) |
| `singing-luan-bell-canon` | Tier 1 main (`kim`, 9 layers); depth `b3` Metal debuff passives + new lines | Engine has it (sized to `15.1/16 W`, bonus `defense_pct 8`) |
| `carriage-bell` | 6 s ringing: foe presses or dodges -> light Metal hit + 1 Metal stack | Engine has it (`each_for 6` counter, `pulse` `foe_pressed`/`pressing`/`since_act <= 1` + `was_evaded` -> one-shot `summon` `0.45 phys` + Metal debuff) |
| `ward-peal` | Creature foe's soonest art waits 2 s; ward scales with Metal stacks on foe | Engine has it (`timer next +2.0`, `ward_grow 0.06 + 0.015 * foe.debuff.metal`; delay applies to any foe in duels) |
| `hanging-bells-array` | Tier 1 secret (`kim`, `tho`, 9 layers); no bonuses/passives in depth | Engine has it (sized to `15.4/16 W`, bonus `than_thuc_pct 8`) |
| `hang-the-bells` (`d15`) | 4 Bell charges (10 s); while 2+, foe art -> Slowed Time + escalating Metal stacks; foreseen start free | Engine has it (`each_for 10` uncapped `bell`, plain `bell_escalate`, `pulse` `foe_pressed`/`since_act <= 1`, `fight_start` `tag.foreseen`) |
| `alarm-line` | Rings all Bell charges: 2 Earth stacks + 0.5 s clock stop | Engine has it (`stacks earth 2`, `stop_clock 0.5`, scaled `free_hit` `0.25 phys` per `bell` charge `outside_budget: true`) |
| `unstruck-bell-canon` | Tier 2 secret (`kim`, 12 layers); no bonuses/passives in depth | Engine has it (sized to `24.0/24 W`, 2 bonuses) |
| `struck-it-answers` | 8 s: each hit taken returns damage as Metal + 1 Metal stack | Engine has it (`each_for 8`, `was_hit` `return_damage 0.35 phys` + Metal debuff, `ward_absorbed` `return_damage 0.35 phys`) |
| `the-bell-that-rings-itself` | At 8+ Metal stacks, bell rings once/s until stacks gone | Engine has it (`self_ring` latch at `foe.debuff.metal >= 8`, one-shot `summon 0.45 phys` each `pulse` until `0`, plus `c 1.2` + `2` Metal active toll) |
| `Rings as It Moves` | Foe presses or dodges -> light Metal hit + 1 Metal stack, <=1/s | Engine has it (`luan_bell_cd` `each_for 1`, `pulse` + `was_evaded`, `free_hit 0.4 phys outside_budget`, Metal debuff) |
| `Struck, She Rings` | Hit taken -> light Metal hit + 1 Metal stack + 1% HP heal, <=1/s | Engine has it (`was_hit`, `cooldown 1`, `free_hit 0.4 phys outside_budget`, Metal debuff, `heal 0.01`) |
| `Forty Answer` | Foe acts -> every held Bell charge rings for light Metal hit, <=1/s | Engine has it (declares `bell` counter; `pulse` `foe_pressed`/`since_act <= 1`, scaled one-shot `summon 0.25 phys`) |
| 6 signature items + 2 sets | `sources: ["npc"]`, `unique: true`, R6 `exception` on `chuong`/`dao_bao`, `rarity: 5` on treasure `ml-luan-bell` | Engine & linters have it |

RECORD PASS DONE

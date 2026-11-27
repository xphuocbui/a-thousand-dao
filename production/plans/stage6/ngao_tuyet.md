# Stage 6: Ngạo Tuyết Phái (`ngao_tuyet`) — progress file

Method: `production/plans/stage6/_brief-record.md` (headless record pass, decisions auto-accepted).
Staging folder: `design/stage6-staging/ngao_tuyet/`.

## Scope (initial `depth_gap.py --sect ngao_tuyet`, 2026-11-27)
- 3 depth techniques: `cold-plum-sword-primer` (Yellow main, Metal+Wood), `plum-through-snow-sword-canon` (Profound main, Metal+Wood), `lone-branch-sword` (Profound secret, Metal). Existing in cast: `iron-hide-manual` (`catalogue-metal.json`).
- 5 new depth arts (`First Petal`, `Five Petals`, `Bloom in the Snow`, `Bare Winter`, `Last Blossom`), 1 existing art ref (`flying-sword` in `family-blade.json`).
- 3 signature items (`ngt-plum-in-snow-sword`, `ngt-thach-khau-tiger-hide`, `ngt-han-mai-snow-cloak`), 1 set (`ngt-plum-and-snow`), 3 Effects (`One Flower on Iron`, `The Tiger's Weight`, `Bare Branch Blooms`).
- 14 modifier lines (all 14 already run).
- 0 beasts, 3 structured events, 0 stand-ins, 0 cross-owner refs, 0 tie issues, 0 engine words, 0 open wishes.

## Step 1: Mechanic table & spatial check
`spatial_words_check.py --sect ngao_tuyet`: 1 soft hit only (`beside` in `pho_ngao_suong` tie note); **0 `removed` or `postponed` hits** across all techniques, arts, items, and sets.

| Record | Mechanic | Engine status | Implementation |
|---|---|---|---|
| `cold-plum-sword-primer` / `first-petal` | Fast Metal thrust; +1 Petal; 5 Petals -> next thrust crits | Has | `c_art: 1.3` Metal `phys` (`tags: [metal, sword, quick]`), `plum_petal` (`each_for: 12`), `sure_crit: 1` at `>= 5` armed by `first_petal_ready` on `art_fired` so hit #5's natural crit never steals hit #6's charge |
| `plum-through-snow-sword-canon` / `five-petals` | 5 quick Metal thrusts, each leaves Wood bleed (debuff) stack | Has | `c_art: 1.8` Metal `phys` (`split: [0.2]*5`), each `hit_landed` lays 1 Wood debuff (`for: 8`) and adds 1 `plum_petal` (`each_for: 12`) so canon holders also feed Petals |
| `plum-through-snow-sword-canon` / `bloom-in-the-snow` | Below 50 % HP: sword arts crit more & crits heal a little | Has | `c_art: 1.5` Metal `phys` (`tags: [metal, sword]`) + `always` `crit +15 [sword]` & `crit` `heal 0.025` (`per_pulse: 2`) while `own.hp_share < 0.5` |
| `lone-branch-sword` / `bare-winter` | With no companion: sword arts cost less & deal more | Has (approx) | `c_art: 1.6` Metal `phys` (`tags: [metal, sword]`) + `has_companion` latch on `kind: companion` (`since.flying-sword >= 12`), `always` `cost_red: 0.15` & `dmg_more: 0.15` `[sword]` while `has_companion == 0` |
| `lone-branch-sword` / `last-blossom` | Once/fight killing blow leaves 1 HP for 1 s; next sword art 2x dmg | Has | `c_art: 1.8` Metal `phys` (`tags: [metal, sword, heavy]`) + `on: down` (`per_fight: 1`): `refuse_down {}` (1 HP), `stop_clock foe 1 s`, `mod {dmg_more: 1.0, tags: [sword], for: 1.0}`, `last_blossom_saved = 1` |
| `ngt-plum-in-snow-sword` / `One Flower on Iron` | Next sword crit leaves 1 Wood debuff per Petal; doubled at 5 Petals | Has | On `crit [sword]`, mutually exclusive `< 5` (`1 * plum_petal`) and `>= 5` (`2 * plum_petal`) Wood debuffs (`for: 8`) + reset `plum_petal` to 0 |
| `ngt-thach-khau-tiger-hide` / `The Tiger's Weight` | Luyện Khí / Trúc Cơ beasts hesitate: 1st attack delayed 1 s | Has (approx) | Neither engine exposes `foe.creature` or `foe.realm`; on `fight_start` if `foe.boss == 0`: `stop_clock {side: foe, seconds: 1.0}` |
| `ngt-plum-and-snow` / `Bare Branch Blooms` | No companion & < 50 % HP: +6 % sword crit dmg per Petal; Last Blossom save -> +5 Petals | Has (approx) | `has_companion` latch (`since.flying-sword >= 12`); `always` `< 0.5 HP` & `has_companion == 0`: `crit_mult: 6 [sword]` scaled by `plum_petal`; `on: refused` (`last_blossom_saved >= 1`): `plum_petal +5` |

## Steps
- [x] 1. Verify first: ran `depth_gap.py --sect ngao_tuyet` (with `--list` for all open sections) and `spatial_words_check.py --sect ngao_tuyet`; built mechanic table above.
- [x] 2. Techniques and arts (staged) + depth art ids in `design/world/depth/sects/ngao_tuyet.techniques.json`:
      - `design/stage6-staging/ngao_tuyet/techniques/catalogue-sect-ngao_tuyet.json`: 3 techniques (`cold-plum-sword-primer` `7.9 W/8`, `plum-through-snow-sword-canon` `15.3 W/16`, `lone-branch-sword` `15.7 W/16`).
      - `design/stage6-staging/ngao_tuyet/arts/part-sect-ngao_tuyet.json`: 5 arts (`first-petal`, `five-petals`, `bloom-in-the-snow`, `bare-winter`, `last-blossom`).
- [x] 3. Effects (staged):
      - `design/stage6-staging/ngao_tuyet/effects/ngao_tuyet.effects.json`: `One Flower on Iron`, `The Tiger's Weight`, `Bare Branch Blooms` (every counter declared locally).
- [x] 4. Items and sets (staged):
      - `design/stage6-staging/ngao_tuyet/items/catalogue-sect-ngao_tuyet.json`: 3 items (`sources: ["npc"]`, `unique: true`, R6 `exception`).
      - `design/stage6-staging/ngao_tuyet/items/sets-ngao_tuyet.json`: 1 set (`ngt-plum-and-snow`).
- [x] 5. Stand-ins: `0` (all 16 living members already reference `cold-plum-sword-primer` or `plum-through-snow-sword-canon`).
- [x] 6. Beasts: `0` (`ngao_tuyet` has no `beasts.json`).
- [x] 7. Holder check (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\ngao_tuyet`):
      - `lint_arts.py`: 5 arts, **0 findings**.
      - `lint_techniques.py`: 3 techniques, **0 findings**.
      - `lint_items.py`: 3 items, **0 findings** (`unique 3 of 3`).
      - Standalone `engine.validate`: **STANDALONE_OK 3**.
      - `depth_check.py --quiet`: **findings: none**.
      - `sect_fight.py ngao_tuyet --seeds 5` (`--gap 0` and `--gap 1`) + 20-seed probes: **0 REFUSED** across 16/16 living members, `0 NEVER_FIRED`, all 3 Effects run and change fight outcomes.
- [x] 8. Review file: written to `production/plans/stage6/ngao_tuyet-review.md` (ending with `REVIEW DONE`).
- [x] 9. Finish: wrote `production/plans/stage6/ngao_tuyet.done` and closed this progress file.

RECORD PASS DONE

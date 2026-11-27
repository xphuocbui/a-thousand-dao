# Stage 6: Bình Thủy Môn (progress file)

Method: `production/plans/world-depth-implementation.md` Stage 6, "the per-sect method", and `production/plans/stage6/_brief-record.md` (headless job, decisions auto-accepted).

## Scope (`python -I tools/design/world/depth_gap.py --sect binh_thuy`)
- **1 technique:** `duckweed-drift-primer` (Yellow main, `thuy`/`moc`, outer gate, 6 layers).
- **2 new arts:** `close-over-the-stone` ("Close Over the Stone (Bình Hợp)"), `chance-meeting` ("Chance Meeting (Tương Phùng)").
- **7 items:** `bth-following-wind-fan`, `bth-claw-king-shell`, `bth-crossing-lamp`, `bth-ferry-token-ring`, `bth-strait-crossing-coat`, `bth-phieu-bong-tide-mirror`, `bth-shell-gatherer-robe`.
- **2 sets:** `bth-the-crossing` (3pc, `bui_phieu_binh`), `bth-slack-water` (3pc, `luong_bach_tan`).
- **4 Effects:** `Every Day of the Year` (`bth-following-wind-fan`), `Slack Water` (`bth-claw-king-shell`), `Somewhere Else by Morning` (`bth-the-crossing`), `The Tenth Layer` (`bth-slack-water`).
- **0 stand-ins, 0 beasts, 0 cross-owner refs, 7 structured events** (closed at Stage 7/8 export).

## Step 1: Mechanic table & spatial check
`spatial_words_check.py --sect binh_thuy`: 2 hits in `binh_thuy`:
- `binh_thuy.items.json :: slack-water :: items.effects.rule :: Still` (false positive: technique name "Still Moon Tide").
- `binh_thuy.cast.json :: luong_bach_tan :: people.build.tree.intent :: behind it` (build intent prose, not a fight rule).
- Plus `Somewhere Else by Morning` in `binh_thuy.items.json` has `"carries you behind the attacker"` (spatial image; rewritten non-spatially in the Effect `rule` and engine record).

| Record | Kind | Depth rule / concept | Engine mapping | Status / Ruling |
|---|---|---|---|---|
| `duckweed-drift-primer` | technique | Yellow main, Water/Wood, drifts & heals when struck | `tier: 0`, `names: ["thuy", "moc"]`, new passives sized <= 8 W (`healing_pct 5`, `evade_pct 2`, `linh_luc_regen_inc_pct 3` = 7.9 W), `abilities`: `close-over-the-stone` (L1), `chance-meeting` (L2) | Existing words; auto-accepted passives & unlock layers |
| `close-over-the-stone` | art | After holder is hit, light heal over 3 s; once per few seconds | Wood `heal` art (`c_heal: 0.4`, `buff: [1, 8.0]`) + `was_hit` (`event.amount > 0`, `cooldown: 6`, `duckweed_mend == 0`) -> 3 pulses of `heal {share: 0.015}` | Existing words |
| `chance-meeting` | art | Quick strike dealing Water or Wood (stronger element) + 1 buff stack | Engine lacks `own.purity` comparison; Water `elem` quick strike (`c_art: 1.5`, `cooldown: 2.0`, `cost_share: 0.025`, `buff: [1, 8.0]`) paired with Wood `close-over-the-stone` | Existing words (auto-accepted deviation logged) |
| `Every Day of the Year` | item Effect | With Water buff stack, Wind/Water art slows don't slow you; 1st evade gives 2 Water buffs | `always` (`own.buff.water >= 1`) -> `status_immune {status: "slowed_time"}` + `delay_immune: 1` (engine doesn't expose caster element on slow/delay); `evaded` (`per_fight: 1`) -> 2 Water buffs (8 s) | Existing words (`approx` logged) |
| `Slack Water` | item Effect | On block: +1 Water buff; at 5 stacks, next Still Moon Tide art heals 4 % HP | `blocked` (`event.amount > 0`) -> +1 Water buff; `buff_gained` (`element: "water"`, `own.buff.water >= 5` or `>= 4` when `slack_water_threshold >= 1`) arms `slack_armed = 1`; `art_fired` (`group: "still-moon-tide-scripture"`, `slack_armed >= 1`) -> `heal {share: 0.04}` + `slack_just_healed` pulse handshake | Existing words (armed on `buff_gained` so empowered `swelling-tide-palm` consumption doesn't eat threshold) |
| `Somewhere Else by Morning` | set Effect | Evade -> +1 Water buff; at 5 stacks next evade spends 5 for 1 %/stack/s heal over 5 s | Non-spatial: `evaded` checks `own.buff.water >= 5` BEFORE `+1` grant -> `consume` 5 Water buffs + `crossing_tide = 5` -> 5 pulses of `heal {share: 0.05}` | Existing words (non-spatial rewrite logged) |
| `The Tenth Layer` | set Effect | Shell heals at 4 Water buffs instead of 5; each Shell heal grants +1 Water buff; blocking stops Water buffs fading | `fight_start` sets `slack_water_threshold = 1`; `heal_restored`/`heal_overflow` when `slack_just_healed >= 1` grants +1 Water buff and clears flag; `blocked` (`event.amount > 0`) calls `refresh {el: "water", side: "own", kind: "buff"}` | Existing words |
| 7 items, 2 sets | items/sets | `bth-following-wind-fan`, `bth-claw-king-shell`, `bth-crossing-lamp`, `bth-ferry-token-ring`, `bth-strait-crossing-coat`, `bth-phieu-bong-tide-mirror`, `bth-shell-gatherer-robe`; `bth-the-crossing`, `bth-slack-water` | `sources: ["npc"]`, `unique: true`, R6 `exception` on the 4 weapons/armour/shield (`phien`, `thuan`, `dao_bao` x2) | Existing fields |

## Steps
- [x] 1. Verify first: mechanic table, `spatial_words_check.py`, `depth_gap.py`.
- [x] 2. Techniques and arts (staged under `design/stage6-staging/binh_thuy/`): `duckweed-drift-primer` (`7.9 W of 8`), `close-over-the-stone`, `chance-meeting`; IDs added to `design/world/depth/sects/binh_thuy.techniques.json`.
- [x] 3. Effects (staged under `design/stage6-staging/binh_thuy/effects/binh_thuy.effects.json`): 4 Effects (`Every Day of the Year`, `Slack Water`, `Somewhere Else by Morning`, `The Tenth Layer`), standalone `engine.validate()` passed for all 4.
- [x] 4. Items and sets (staged under `design/stage6-staging/binh_thuy/items/`): 7 unique NPC items (4 with R6 `exception`), 2 sets.
- [x] 5. Stand-ins: verified 0 in `binh_thuy`.
- [x] 6. Beasts: verified 0 in `binh_thuy`.
- [x] 7. Holder check: `lint_arts` (0 findings), `lint_techniques` (0 findings), `lint_items` (0 findings), `sect_fight.py binh_thuy` (`--gap 0` and `--gap 1`: every art fires, every Effect runs on real holders), plus slow/delay probe and standalone `Slack Water` probe.
- [x] 8. Review file: `production/plans/stage6/binh_thuy-review.md` written.
- [x] 9. Finish: `RECORD PASS DONE` and `production/plans/stage6/binh_thuy.done`.

RECORD PASS DONE

# Stage 6: Phượng Minh Cung (record pass, progress file)

Brief: `production/plans/stage6/_brief-record.md` (OWNER = phuong_minh). Headless job, decisions auto-accepted (user, 2026-11-26) and logged in `production/plans/stage6/phuong_minh-review.md`. Resume here: do the first unchecked step.
Staging folder: `design/stage6-staging/phuong_minh/` (mirrors `design/`). Never run git.

## Scope (gap report 2026-11-27, `python -I tools/design/world/depth_gap.py --sect phuong_minh`)
- **5 depth techniques** (+ 1 new servants' method + 1 early foreign promotion):
  - `wutong-dawn-breath` (Yellow main, Wood + Fire, 6 layers)
  - `five-virtue-phoenix-canon` (Heaven main, Fire + Wood, 12 layers; tier 2 in depth proposal, keeping depth's `tier: 2, layers: 12` Earth/Địa or Heaven? Depth says `tier: 2, layers: 12`)
  - `morning-sun-feather-fan` (Profound/tier 1 secret, Fire, 9 layers)
  - `shao-remnant-score` (Profound/tier 1 secret, Wood, 9 layers)
  - `nine-shao-advent` (Heaven/tier 3 secret, Fire, 15 layers)
  - **New servants' method:** `hearth-ash-breath` (Yellow/tier 0 main, Earth, 6 layers) for 4 `tap_dich` Earth servants (`bao_lac_hai`, `bi_thuan`, `nguu_dai_huu`, `luu_tu_nuong`)
  - **Early foreign promotion (`foreign/market-folk/`):** `censer-smoke-manual` + `pill-smoke` (`e2`) for `ke_chu_sa`
- **14 new depth arts** (13 staged as active arts + 1 passive art Effect `Birds Pay Court to the Phoenix`) + `dawn-call` (`e10`, referenced by `pm-dawn-call-pipe`) + `ash-sweep-palm` (new servants' art) + `pill-smoke` (`e2`, in `foreign/market-folk/`).
- **28 items, 10 sets, 17 staged Effects** (2 technique Effects including 1 passive art `Birds Pay Court to the Phoenix` + `Playing Past the Break`; 5 item Effects; 10 set Effects).
- **5 stand-ins** (`bao_lac_hai`, `bi_thuan`, `nguu_dai_huu`, `luu_tu_nuong` on `hoang_tho` -> `hearth-ash-breath`; `chu_tri_am` on `dia_kim` -> existing committed `hundred-blades-canon`).
- **3 beasts** (`xich_quan`, `tieu_vi` on `vu_ngo_dong`; `ngu_cau` on `an_thuy_vu`) — already listed on cast `beasts` fields; beast records close at Stage 7 export.

## Mechanic Table (verified before staging)

| Record | Mechanics | Engine words | Status |
|---|---|---|---|
| `wutong-dawn-breath` | Seed of Spring + Dawn Call Palm | standard passives; `scale` Fire buff | exists |
| `dawn-call-palm` | Light Fire strike, +1 Wood buff on self; stronger with Fire buffs | `buff`, `always` `scale` `dmg_more` | exists |
| `five-virtue-phoenix-canon` | Furnace Heart + Five-Colour Plumage + Phoenix Sings + Perch + passive art Birds Pay Court | standard bonuses/passives; passive art Effect uses `technique-effects` | `technique-effects` (pending) |
| `five-colour-plumage` | 5 distinct colour counters (`fire`, `fan`, `song`, `wood/heal`, `ward`) + repeat Fire counter -> at 5 spend for next art `L5 +20` & 30% heal (half if repeat) | `counters`, `not_tags`, `scale`, `heal`, `L5` | exists |
| `phoenix-sings-high-ridge` | Fire hit scaling with foe missing HP; consumes plumage stacks if held for Burn + qi | `scale` `foe.hp_missing_share`, `gain_qi`, `stacks` | exists |
| `perch-on-the-wutong` | Still Wood stance (`field` tag); while Composed grows bark ward; first Fire art consumes ward for Fire damage | `state` (`field`), `composed`, `ward_grow`, `release_ward` | exists |
| `birds-pay-court-to-the-phoenix` | Passive art (layer 5): bird companion hit adds next lacking plumage colour (1/pulse); on full spend, heal 3% + companions +30% next hit | `technique-effects`, `kind: companion, tags: [bird]`, `heal`, `dmg_more` | `technique-effects` (pending) |
| `morning-sun-feather-fan` | Flint Volley + Hundred Plumes + Wing Screen | standard tier 1 bonuses/passives | exists |
| `hundred-plumes` | Split 4 Fire feathers laying 1 Burn each; at 5+ foe Burn splits 6 feathers | `split`, `hit_landed`, `empower` `split` | exists |
| `wing-screen` | Feather screen reducing next hit taken and laying 1 Burn on attacker (uses counter, not stance slot) | `counter`, `ward_grow`, `dampen_taken`, `was_hit` | exists |
| `shao-remnant-score` | Thorn Lullaby + Dawn Clouds + Remnant Next Movement + Effect `Playing Past the Break` | `x_soul` scoped `soul`; `art_speed_pct` unscoped (6% vs 8% `song`, since `song` is not in `TIER`); Effect needs `technique-effects` + `meters` | `song` scope gap; `technique-effects` (pending) |
| `dawn-clouds-take-the-colour` | Sustained song (counter flag, not stance slot): +1% qi/s + Slowed Time/s; ends on health hit (`amount > 0`) | `counter`, `pulse`, `gain_qi`, `status`, `was_hit` `event.amount` | exists |
| `remnant-next-movement` | Movements 1..7 on `remnant_movement`; non-score `song` resets to 0 | `effects` descending order on `remnant_movement` (avoids missing `movements` field in `lint_arts.py`) | adapted to pass `lint_arts` |
| `Playing Past the Break` | Past 7th movement once a fight: `meter` trial -> 5 Slowed Time + 10% qi OR 10% hp/qi backlash + restart | `meter`, `status`, `gain_qi`, `self_hit`; attaching needs `technique-effects` + `meters` compiler | `technique-effects` (pending) |
| `nine-shao-advent` | 1st, 5th, 8th, Next Movement (1..8 suite <= layer 6) + standalone story 9th (layer 15, `group: ""`) | tier 3 bonuses/passives, `status_duration_pct` `[curse]` | exists |
| `nine-shao-first-movement`, `fifth`, `eighth`, `next-movement` | Ordered Shao movements 1..8 laying `shao` stacks on foe; summon beasts on 5th; 2s `stop_clock` on 8th (at 8 Shao or in turn); out-of-turn resets | `effects` + `counter side foe` + `summon` + `stop_clock` (avoids `movements` in `lint_arts.py`) | adapted to pass `lint_arts` |
| `nine-shao-ninth-movement` | Story-weapon heavy Fire+Soul + 3s `stop_clock`; `notes` documents lower-realm forbid | `stop_clock`, `soul_part` | story gate noted |
| `hearth-ash-breath` + `ash-sweep-palm` | New Earth servants' Yellow method (7.8 W) + simple Earth art | standard static/passive + `debuff` | new |
| `censer-smoke-manual` + `pill-smoke` | Early promotion for `ke_chu_sa` into `foreign/market-folk/`; `names: ["hoa"]` for `lint_techniques`; `burn_pill` directly | `burn_pill` (`stacks_per_grade`, `for`); `pill_effect_pct` unpriced note on `catalogue-sect-*` | early promotion |
| `dawn-call` (`e10`) | Light+Soul note on pipe; 3rd cast lays Exposed (`root_has: [quang]` in `notes` until `lint_arts` accepts `requires`) | `light`, `soul_part`, `status exposed` | `requires` omitted for lint |
| `Eight of Nine` (`pm-tieu-thieu-quan`) | Fight start +1 `shao` on foe; at 8+ `shao` on foe stops foe clock 2 s; 9th lore non-art | `fight_start`, `counter side foe`, `stop_clock` | partial (`9th` story only) |
| `The Five Marks Shine` (`pm-five-colour-robe`) | Full plumage spend -> ward 6% max HP | `ward_grow` via `pl_spent_flag` | exists |
| `Sit Beside` (`pm-ash-seat-censer`) | Out-of-fight breakthrough aid | `not_run` | out of fight |
| `Thread of the Nest` (`pm-nest-thread-banner`) | While `field_up >= 1`: `-10%` Fire dmg taken & `+10%` ward strength (`approx` for +1s ward dur) | `always`, `own.field_up`, `dampen_taken`, `ward_pct` | exists (`approx`) |
| `The Birds Bring the Fire` (`pm-wutong-twig-ring`) | Bird companion hit -> 1 Fire buff (4s), cap 2/pulse | `hit_landed` `kind: companion, tags: [bird]` | exists |
| `The Phoenix Comes with Stately Grace` (`pm-five-virtue`) | Full spend -> heal 5% + next plumage starts at 2 (`pl_c1`, `pl_c2`, `plumage 2`) | `heal`, `counter` | exists |
| `Two Wings Beat` (`pm-twin-wings`) | Every 3rd fan art echoes (`fire_art which: last`) | `art_fired` + `fire_art` | exists |
| `The Censer Remembers` (`pm-ash-seat`) | +0.5% hp bank/s while foe burns (`-2%/s` otherwise); on `refused`, ward; else at `wounded` once, heal | `pulse`, `refused`, `wounded`, `ward_grow`, `heal` | exists |
| `Burning Feathers` (`pm-hall-stands`) | Fan crit -> +1 Burn; at 10+ Burn on foe -> +10% Fire crit | `crit`, `stacks`, `always` `mod crit` | exists |
| `The Birds Fight First` (`pm-wutong-court`) | Bird hit -> 1 Wood buff; fan art spends all -> +6% dmg each | `hit_landed`, `art_fired`, `consume`, `dmg_more` | exists |
| `Fire Down the Thread` (`pm-nest-array`) | While `field_up >= 1`: `buff_gained` (fire) -> `ward_grow` 2% hp (`approx` no 1% self-qi cost); `shield_broken` (`stance_ward`) -> Fire hit back | `buff_gained`, `ward_grow`, `shield_broken`, `free_hit` | exists (`approx`) |
| `Never the Eighth` (`pm-seven-movements`) | Each Remnant movement -> 1 Slowed Time; at 7th -> 5 Slowed Time + restart to 0 + soul art speed +20% 8s | `art_fired`, `status`, `counter set 0`, `mod art_speed` | exists |
| `A Copy in Small` (`pm-small-morning`) | Full plumage spend -> ward 4% hp; while ward holds -> plumage builds 25% faster (extra +1 every 4th colour step) | `ward_grow`, `own.ward_share`, `counter` | exists |
| `Light on the Pipe` (`pm-dawn-call`) | Every 5th `pipe` soul art -> `exposed` 3 s | `art_fired` `tags: [pipe]`, `status exposed` | exists |
| `Petal Feint` (`pm-yellow-chrysanthemum`) | After `evaded`: next fan art +30% speed, Fire Burn duration +33% for 3 s (~+2 s on 6 s Burns) | `evaded`, `mod art_speed`, `mod stack_dur` | exists (`approx`) |

## Decisions so far (auto-accepted)
- Implement `remnant-next-movement` & `nine-shao-next-movement` via pure `effects` + descending counters rather than `"movements"`, and omit `"requires"` from `dawn-call` (`notes` documents `root_has: ["quang"]`), so all arts pass `lint_arts.py` cleanly without modifying `tools/`.
- Replace unrecognised `"song"` scope on `shao-remnant-score` (`x_soul` -> `["soul"]`, `art_speed_pct` -> `6 []`) and on 3 items (`pm-remnant-score-zither`, `pm-dawn-call-pipe`, `pm-rites-drum` -> `scope: ["artifact"]` or unscoped) to clear `lint_techniques` / `lint_items` `SCOPE` findings, matching `thien_xu` D39.
- Early-promote `censer-smoke-manual` + `pill-smoke` (`e2`) into `foreign/market-folk/` with `names: ["hoa"]` (so `lint_techniques` accepts it cleanly) and `burn_pill {stacks_per_grade: 4, for: 6.0}`.
- Keep `nine-shao-ninth-movement` at `unlock_layer: 15` with `group: ""` (standalone story art) so it passes `lint_techniques` suite rule (`unlock_layer <= 6` for `group` arts).
- Put `dawn-clouds-take-the-colour` and `wing-screen` on self-counters instead of `states` so only `perch-on-the-wutong` (`tags: ["field"]`) and `brazier-form` use the stance slot — zero stance collisions across any holder.
- Stand-ins: new `hearth-ash-breath` + `ash-sweep-palm` for the 4 Earth servants; `hundred-blades-canon` (Thính Vũ's existing committed Metal method in `catalogue-metal.json`) for guest elder `chu_tri_am`, leaving `thinh_vu` untouched.

## Steps
- [x] 1. Verify first: mechanic table built above; DEPTH_STAGE env convention verified.
- [x] 2. Techniques and arts (staged + `phuong_minh.techniques.json` art ids + `foreign/market-folk/`).
- [x] 3. Effects (`effects/phuong_minh.effects.json` + `pending.json`).
- [x] 4. Items and sets (`items/catalogue-sect-phuong_minh.json`, `items/sets-phuong_minh.json`).
- [x] 5. Stand-ins (`phuong_minh.cast.json`, `.3.cast.json`, `.4.cast.json`).
- [x] 6. Beasts (`vu_ngo_dong`, `an_thuy_vu` verified against `phuong_minh.beasts.json`).
- [x] 7. Lint and holder check (`lint_arts`, `lint_techniques`, `lint_items`, `depth_gap`, `sect_fight`, real-kit probes).
- [x] 8. Review file (`production/plans/stage6/phuong_minh-review.md`).
- [x] 9. Finish (`RECORD PASS DONE` + `production/plans/stage6/phuong_minh.done`).

## Exact commands (`$env:DEPTH_STAGE = "C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\phuong_minh"`)
- `python -I tools/design/arts/lint_arts.py design/stage6-staging/phuong_minh/arts/part-sect-phuong_minh.json`
- `python -I tools/design/arts/lint_techniques.py design/stage6-staging/phuong_minh/techniques/catalogue-sect-phuong_minh.json`
- `python -I tools/design/items/lint_items.py design/stage6-staging/phuong_minh/items/catalogue-sect-phuong_minh.json`
- `python -I tools/design/arts/lint_arts.py design/stage6-staging/phuong_minh/foreign/market-folk/arts/part-sect-market-folk.json`
- `python -I tools/design/arts/lint_techniques.py design/stage6-staging/phuong_minh/foreign/market-folk/techniques/catalogue-sect-market-folk.json`
- `python -I tools/design/combat_sim/sect_fight.py phuong_minh [--gap 1] --seeds 10`

RECORD PASS DONE

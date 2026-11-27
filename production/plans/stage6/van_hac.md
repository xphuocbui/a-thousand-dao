# Stage 6: Vạn Hác Viện (`van_hac`, progress file)

Method: `production/plans/world-depth-implementation.md` Stage 6 and `production/plans/stage6/_brief-record.md` (headless job, Batch b04; decisions auto-accepted).
Resume here: read this file, then do the first unchecked step.

## Scope (`python -I tools/design/world/depth_gap.py --sect van_hac`)
- 3 techniques: `pine-wind-fingering` (Yellow main, `names: []`), `ten-thousand-ravines-zither-canon` (Earth main, `names: []`), `the-monks-rest` (Profound secret, `names: []`). Existing referenced: `thorn-and-ink-verses` (Wood secret, `catalogue-soul-song-seal.json`).
- 6 new art entries in `van_hac.techniques.json`: 5 active arts (`plucked-pitch`, `ten-thousand-ravines`, `echo-wall`, `the-held-rest`, `empty-ravine`) + 1 passive art (`The Earned Rest`, `effect: "earned-rest"`, `unlock_layer: 4`, `d28` from `auth-eff-2.json`).
- 2 existing library arts referenced: `thorn-lullaby`, `marching-dirge` (`family-soul-song-seal.json`).
- 4 items (`vh-tung-phong-cam` treasure, `vh-stringless-zither`, `vh-held-rest-beads`, `vh-ravine-wind-robe`), 1 set (`vh-monks-things`, 3 pieces), 3 Effects (`Pines in Ten Thousand Ravines`, `The Unplayed Note`, `Silence After the Twelfth`) + 1 technique passive Effect (`The Earned Rest`).
- 0 stand-ins, 0 beasts, 0 cross-owner refs, 0 unmapped/over-cap ties, 3 structured events (`N-van_hac-01`..`03`).

## Steps
- [x] 1. Verify first: mechanic table below; `spatial_words_check.py --sect van_hac` (0 hits for `van_hac`).
- [x] 2. Techniques and arts (staged): `design/stage6-staging/van_hac/techniques/catalogue-sect-van_hac.json` (3 techniques), `design/stage6-staging/van_hac/arts/part-sect-van_hac.json` (5 active arts), `design/world/depth/sects/van_hac.techniques.json` updated with active art ids.
- [x] 3. Effects (staged): `design/stage6-staging/van_hac/effects/van_hac.effects.json` (4 Effects: `The Earned Rest`, `Pines in Ten Thousand Ravines`, `The Unplayed Note`, `Silence After the Twelfth`).
- [x] 4. Items and sets (staged): `design/stage6-staging/van_hac/items/catalogue-sect-van_hac.json` (4 items), `design/stage6-staging/van_hac/items/sets-van_hac.json` (1 set).
- [x] 5. Stand-ins (none needed — 0 stand-ins).
- [x] 6. Beasts (none — 0 beasts).
- [x] 7. Holder check (`DEPTH_STAGE=C:\Users\xphuo\IdeaProjects\my-game\design\stage6-staging\van_hac`): `lint_arts.py` 0 findings, `lint_techniques.py` 0 findings, `lint_items.py` 0 findings, `depth_check.py` 0 findings; `sect_fight.py van_hac --seeds 5 --gap 0` and `--gap 1` all arts fired, all Effects ran; trace probe verified `plucked-spend`, `ravines-reapply`, `The Unplayed Note grant`, `The Earned Rest`, and `Silence After the Twelfth`.
- [x] 8. Review file (`production/plans/stage6/van_hac-review.md`).
- [x] 9. Finish (`RECORD PASS DONE` here + `production/plans/stage6/van_hac.done`).

## Step 1: Mechanic table
| Record | Kind | Depth mechanic | Engine status | Plan |
|---|---|---|---|---|
| `pine-wind-fingering` | tech | Element-free (`names: []`) Yellow main; passives unauthored | Engine has (`lint-element-free-techniques`, b02) | Size passives <= 8 W (`attack_pct`, `art_speed_pct`, `linh_luc_regen_inc_pct`); carry `plucked-pitch` (L1), `thorn-lullaby` (L2) |
| `plucked-pitch` | art | Force hit; next note within 1 s strikes harder | Engine has (`convert` to `force`, `each_for: 1.0` counter `plucked_echo`, `dmg_more`) | Arm `plucked_echo` on `hit_landed`; `always` gives +25 % `dmg_more` to `tags: ["song", "music"]`; spend on next song/music hit/evade |
| `ten-thousand-ravines-zither-canon` | tech | Element-free (`names: []`) Earth main; 2 authored passives (`soul_res_pct 8.3`, `status_resist_pct 7.5`), rest unauthored | Engine has (`lint-element-free-techniques`, b02) | Add 2 tier-2 bonuses (`than_thuc_pct 10`, `linh_luc_pct 12`) + Force/regen passives <= 24 W; carry `marching-dirge` (L1), `echo-wall` (L2), `ten-thousand-ravines` (L4) |
| `echo-wall` | art | 4 s wall: each art hit damaging you heals part of its damage; song arts stack Resonance | Engine has (`each_for: 4.0` counter `echo_wall`, `was_hit` with `event.amount > 0`, `counter {side: foe}`) | Timed counter `echo_wall` (avoids clobbering `march` stance); heals 25 % of `event.amount` (max 3/pulse); every `song` art adds 1 `resonance` on foe |
| `ten-thousand-ravines` | art | Force damage per Resonance stack on foe; half stacks (rounded down) remain | Engine has (`scale`, `free_hit`, `counter {side: foe}`) | Force `c_art` + `free_hit` 0.25 c per `foe.counter.resonance`; compute `floor(R/2)` via `res_keep` (`per: 2`), reset `resonance` to 0, re-add `res_keep` |
| `the-monks-rest` | tech | Element-free (`names: []`) Profound secret; bonuses/passives unauthored | Engine has (`lint-element-free-techniques`, `technique-effects`) | Add 1 tier-1 bonus (`than_thuc_pct 8`) + curse/soul/regen passives <= 16 W; carry `the-held-rest` (L1), `empty-ravine` (L2), effect `The Earned Rest` (L4, `passive_art: true`) |
| `the-held-rest` | art | 2 s rest slowing foe casting | Engine has (`counter` `held_rest`, `status` `slowed_time`) | Set `held_rest = 2` (ticked on `pulse`), apply `slowed_time` 1 stack for 2 s |
| `empty-ravine` | art | Removes buffs on foe given by song, drum or bell | Approx with existing (`strip` + `silence`) | `target.buffs` does not track source art tags (`song`/`drum`/`bell`); strip up to 3 stacks of foe's largest buff pile, apply `silence` (`tag: "song"`, 3 s), and deal light Force damage so it stays active in non-song matchups |
| `The Earned Rest` (`d28`) | passive art / Effect | After Marching Dirge finale, Held Rest lasts `0.5 * Measures` (halved each later finale) + Heavy Breath x1 while held | Engine has (`own.state.march`, `scale`, `status` `heavy_breath`) | Mirror `measure` via `earned_measures` on `pulse` (since `march-reset` zeroes `measure` before `tech_effects` run); compute `0.5 * M / 2^halvings` (min 1 pulse); maintain 1 `heavy_breath` + `slowed_time` (`cap: 1`) while `held_rest >= 1` |
| `Pines in Ten Thousand Ravines` | item Effect (`vh-tung-phong-cam`) | Song art echoes 1 s later at half strength (spatial phrase dropped); echoes add Resonance, cannot echo | Engine has (`counter` `cam_echo`, `pulse`, `free_hit`) | Queue 1 per `song` `art_fired`; on next `pulse` deal `free_hit` 0.8 Force + 1 `resonance` per queued note (`free_hit` cannot trigger `art_fired`) |
| `The Unplayed Note` | item Effect (`vh-stringless-zither`) | While holding Monk's Rest silence, next song art after silence ends costs 0 | Engine has (`next_art_cost: 0`) | Arm `unplayed_armed` whenever `held_rest >= 1`; on `pulse` when `unplayed_armed == 1` and `held_rest == 0`, grant `next_art_cost: 0` for `tags: ["song"]` |
| `Silence After the Twelfth` | set Effect (`vh-monks-things`) | Echoes add Resonance; on The Held Rest with 6+ Resonance, foe's next art fails and casting 30 % slower 3 s | Engine has (`stop_clock`, `slowed_time`) | On `the-held-rest` or `marching-dirge` finale (`march == 0 && held_rest >= 1`) with `foe.counter.resonance >= 6`, `stop_clock` 1 s + `slowed_time` 3 stacks for 3 s |

RECORD PASS DONE

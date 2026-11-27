# Stage 6 Record Pass — `tung_dao` (Tùng Đào Cung)

Owner: `tung_dao`
Stage dir: `design/stage6-staging/tung_dao/`
Scope (from `depth_gap.py --sect tung_dao`):
- Techniques: 4 (`listening-pine-primer`, `pine-wave-true-canon`, `pine-rain-canon`, `startled-goose-step`) + 2 new Yellow stand-ins (`hearth-simmer-breath`, `bark-and-timber-breath`)
- Arts (new): 7 active depth arts + 2 stand-in arts (9 total in `part-sect-tung_dao.json`) + 1 passive art Effect (`Answering Wave`)
- Arts (ref): 6 (`seed-of-spring`, `second-spring`, `rooted-form`, `gathering-wave`, `brimming-cup`, `swallow-stance` — `swallow-stance` omitted from `startled-goose-step` staged `abilities`, see Decisions)
- Items: 27 (`td-wandering-dragon-sash` as `kind: "treasure"`, `rarity: 5`)
- Sets: 9
- Effects: 23 (2 technique + 11 item + 10 set bonuses; `technique-effects` pending word reused with decision `"build"`; `Still Water` -> `Abbey's Still Water` to avoid Đạo Đồ clash; 2 out-of-combat items recorded with `"not_run"`)
- Beasts: 0
- Stand-ins: 4 (`banh_tao_nhi`, `phung_que_chi`, `sam_chuc_nuong`, `mac_don_moc`)
- Cross-owner: `market-folk`'s `khau_phuc_linh` (`listening-pine-primer` layer 5 — holds Wood & Water)

## Progress
- [x] Step 1 — Audit gap, cross-check rules & engine, and finish mechanic designs
- [x] Step 2 — Stage techniques, arts, and `pending.json`
- [x] Step 3 — Stage items, sets, and Effects
- [x] Step 4 — Write IDs & stand-ins back to `design/world/depth/sects/tung_dao.*.json`
- [x] Step 5 — Run linters, `engine.validate`, `depth_check.py`, `sect_fight.py`, and targeted probes
- [x] Step 6 — Fix all findings and verify every new art/Effect runs & alters fights
- [x] Step 7 — Write `tung_dao-review.md`, append `RECORD PASS DONE`, write `tung_dao.done`

## Auto-Accepted Decisions (summary — full reasons in `tung_dao-review.md`)
1. `pine-needle-rain` ID instead of `needle-rain` (collides with Metal common/family art).
2. `listening-pine-primer` `names: ["moc"]` (matches both Wood arts; fixes `CongPhap.usable` on 9 outer disciples lacking Water).
3. `pine-wave-true-canon` keeps `names: ["moc", "thuy"]` (`tan_mac_bach` logged as pre-existing root/method mismatch).
4. `startled-goose-step` omits `swallow-stance` from staged `abilities` (Wind element fails `lint_techniques` & `CongPhap.usable` on `thoi_khinh_hong`).
5. Two new Yellow stand-in techniques (`hearth-simmer-breath`, `bark-and-timber-breath`) for the 4 kitchen/weaver/carter servants.
6. `td-still-water-lamp` Effect named `"Abbey's Still Water"` (avoids `combat_effects.json` Đạo Đồ `"Still Water"` clash; depth item rename logged as Open Item).
7. Non-conflicting Field states on `Rain Through the Needles` (`pine-rain`) and `Light on the Quay` (`quay-light`) using counters so `rooted-form` is never overwritten.
8. Non-spatial `Moon on Open Water` (`own.composed >= 1` boosts Water art damage & speed).
9. Shared pending word `technique-effects` reused (`decision: "build"`) for `Answering Wave` and `The Fifteenth Layer`.

## Step 1 — Mechanic Table

### Techniques
| ID | Name | Tier | Kind | Elements | Layers | Arts / Effects |
|---|---|---|---|---|---|---|
| `listening-pine-primer` | Listening Pine Primer (Thính Tùng Quyết) | 0 | `main` | `moc` | 6 | `seed-of-spring` (L1), `pine-needle-rain` (L2) |
| `pine-wave-true-canon` | Pine Wave True Canon (Tùng Đào Chân Kinh) | 3 | `main` | `moc`, `thuy` | 15 | `second-spring` (L1), `rooted-form` (L2), `gathering-wave` (L3), `ten-thousand-pines-answer` (L5), `the-wave-comes-back` (L8); passive Effects: `Answering Wave` (L4), `The Fifteenth Layer` (L15) |
| `pine-rain-canon` | Rain on the Pine Sea Canon (Tùng Hải Vũ Kinh) | 2 | `secret` | `thuy`, `moc` | 12 | `brimming-cup` (L1), `rain-through-the-needles` (L3), `the-road-in-a-dream` (L6) |
| `startled-goose-step` | Startled Goose Step (Kinh Hồng Bộ) | 2 | `secret` | `moc` | 12 | `the-goose-rises-from-the-reeds` (L1), `the-white-wolf-falls` (L4) (`swallow-stance` omitted — see Decisions) |
| `hearth-simmer-breath` | Hearth-Simmer Breath (Táo Hạ Văn Hỏa Quyết) | 0 | `main` | `hoa` | 6 | `simmered-broth` (L1) (stand-in for `banh_tao_nhi`, `phung_que_chi`) |
| `bark-and-timber-breath` | Bark-and-Timber Breath (Mộc Thạch Phụ Trọng Công) | 0 | `main` | `tho` | 6 | `steady-shoulder` (L1) (stand-in for `sam_chuc_nuong`, `mac_don_moc`) |

### New Arts (9 active + 1 passive Effect)
| ID | Name | Element | Group | Core Mechanic |
|---|---|---|---|---|
| `pine-needle-rain` | Needle Rain (Châm Vũ) | `wood` | `listening-pine-primer` | `c_art: 1.5`, 3 s cd, `cost: 0.03`, Wood debuff `4` for `5 s`; if foe already has Water buff/debuff, inflicts `slowed_time` `1` for `2 s`. |
| `ten-thousand-pines-answer` | Ten Thousand Pines Answer (Vạn Tùng Ứng) | `wood` | `pine-wave-true-canon` | `c_art: 0.0`, 10 s cd, `cost: 0.045`; opens 8 s `pines_answering` window (self Wood heal ticks + wave counter): each `heal_restored` lays Wood debuff +1 stack & restores `1.5 %` max linh lực, scaling +10 % per wave (`c_mult`-like free follow-up wave `c: 0.65` scaled by wave). |
| `the-wave-comes-back` | The Wave Comes Back (Đào Hồi) | `water` | `pine-wave-true-canon` | `c_art: 0.0`, 12 s cd, `cost: 0.05`, `c_heal: 0.8`; marks current damage baseline for 10 s (`wave_mark`), tracks damage taken (`on: "was_hit"`), snaps back on expiry or `< 50 %` HP to restore tracked damage (capped cleanly per budget). |
| `answering-wave` *(passive Effect)* | Answering Wave (Ứng Đào) | `tech` | `pine-wave-true-canon` | Layer 4 passive Effect: on `heal_restored`, scales per `1 %` HP restored (`share`) -> 1 Wood debuff stack on foe + 1 Water buff stack on self. |
| `rain-through-the-needles` | Rain Through the Needles (Vũ Xuyên Châm) | `water` | `pine-rain-canon` | `c_art: 0.0`, 12 s cd, `cost: 0.05`; 10 s Field (`pine_rain` counter, sets `pine-rain` state only if no stance active): each pulse `heal 1 %` + `gain_qi 1 %`, every 2 pulses foe takes 1 Water debuff, Wood stacks laid while active get `stack_dur: 2.0`. |
| `the-road-in-a-dream` | The Road in a Dream (Mộng Lộ) | `water` | `pine-rain-canon` | `c_art: 0.0`, 10 s cd, `cost: 0.035`; on cast gives 1 Water buff, `ward_grow` 6 %, 2 s `delay_immune`; once/fight on pulse if `sleep`/`charmed`/`silence`/`sealed_meridian` cleanses 1 curse & grows ward 12 % (out-of-combat seclusion cultivation `not_run` note). |
| `the-goose-rises-from-the-reeds` | The Goose Rises from the Reeds (Hồng Khởi Lô Trung) | `wood` | `startled-goose-step` | `c_art: 0.0`, 8 s cd, `cost: 0.04`; grants 2 s `goose_evade` (`evade +100` spent on `evaded`) and `next_art_more: 0.30` (`goose_poise` cleared on `hit_landed`/`was_evaded` kind `art`). |
| `the-white-wolf-falls` | The White Wolf Falls (Bạch Lang Lạc) | `wood` | `startled-goose-step` | `c_art: 3.1`, 9 s cd, `cost: 0.06`, `debuff: [3, 8]`, `status: [off_guard, 1, 2]`; if `own.hot_active >= 1` or `own.buff.wood >= 4` gains `+0.35` hit empowerment. |
| `simmered-broth` | Simmered Broth (Văn Hỏa Dưỡng Canh) | `fire` | `hearth-simmer-breath` | `c_art: 0.0`, `c_heal: 0.5`, 5 s cd, `cost: 0.03`; gentle Fire kitchen mend + 1 Fire buff. |
| `steady-shoulder` | Steady Shoulder (Kiên Phụ Trọng) | `earth` | `bark-and-timber-breath` | `c_art: 1.6`, 4 s cd, `cost: 0.03`, `buff: [1, 8]`; plain Earth strike + 1 Earth buff. |

### Effects (23 total: 2 Technique + 11 Item + 10 Set)
| Name | Source | Engine Hook |
|---|---|---|
| `Answering Wave` | `pine-wave-true-canon` L4 *(pending: technique-effects)* | `on: "heal_restored"`, scales per `0.01` `event.share` (cap 10), lays Wood debuff & self Water buff. |
| `The Fifteenth Layer` | `pine-wave-true-canon` L15 *(pending: technique-effects)* | `on: "down"` `limit: {per_fight: 1}` -> `refuse_down` + 6 s `last_act_window` + fires up to 6 `free_hit` (`c: 0.8`, half `phys`/`elem`) per held/built wave. |
| `Supple as a Swimming Dragon` | `td-wandering-dragon-sash` | `on: "was_hit"` (`limit: {cooldown: 15}`) if `event.amount >= X` -> `heal` 50 % of `event.amount` + increments `dragon_slipped`. |
| `The Pack Remembers` | `td-white-wolf-fang` | `on: "always"` if `foe.status.off_guard >= 1` -> `mod: {pen: 150, element: "wood"}`. |
| `Hear It Coming` | `td-listening-robe` | Opening 15 s ward (`status_immune` for `sleep`, `charmed`, `bound`, `off_guard` + `delay_immune`), first triggered art attempt breaks the ward. |
| `One Stick of Listening` | `td-pine-heart-censer` | `not_run` (out-of-combat seasonal cultivation). |
| `Abbey's Still Water` | `td-still-water-lamp` | `on: "pulse"` (`cooldown: 10`) -> sets `next_art_cost: 0` (`element: "water"`, held until Water `art_fired`). |
| `The Ninth Bend` | `td-nine-bend-ring` | Counts Water `art_fired` (`bend_count`; +1 extra if `event.cost == 0` when set active); on 9th -> `free_hit c: 1.1 dtype: "elem"` + sets `ninth_bent`. |
| `Roots Under the Field` | `td-coiled-root-banner` | Tracks `foe.composed` on `pulse`; at 2 -> `off_guard` 1 s (`cooldown: 10`). |
| `Cool the Burn` | `td-pine-rain-fan` | `on: "heal_restored"` (`cooldown: 1`) -> `cleanse` 1 Fire debuff stack. |
| `Heard Once` | `td-clear-sound-zither` | `not_run` (out-of-combat voice art learning speed). |
| `Crack the Ice` | `td-broken-ice-flags` | Opening Field / Flag charges: tracks `foe.composed` to 3 -> `off_guard` 2 s + 1 Water debuff (`cooldown: 6`). |
| `Moon on Open Water` | `td-moon-lake-mirror` | Non-spatial: `on: "always"` if `own.composed >= 1` -> `mod: {dmg_more: 0.12, element: "water"}` & `art_speed: 15` (`water`). |
| `The Sea Answers` | `td-pine-regalia` (3p) | `on: "pulse"` every 3 s while `own.composed >= 1` -> escalating Wood debuff & 2 % heal; wave 6+ costs `2 %` max linh lực; resets on move. |
| `Hold the Quay` | `td-cold-ford-charge` (2p) | `on: "always"` if `own.composed >= 1` -> `dmg_taken: -0.12`, `status_dur: 1.0` (`off_guard`). |
| `Light on the Quay` | `td-cold-ford-charge` (3p) | While `own.composed >= 1`: `quay_lit` Field, +1 % heal/s, Slows foe (`slowed_time`), at `foe.status.off_guard >= 2` counters with `free_hit c: 1.0`. |
| `Ferry Across` | `td-ferryman-remedy` (2p) | `on: "heal_restored"` (`cooldown: 6`) if `own.hp_share < 0.5` -> `cleanse` 1 Wood debuff + 1 Wood buff. |
| `The Last Bridge` | `td-cut-bridges` (2p) | `on: "hit_landed"` once/fight when `foe.hp_share < 0.5` -> `next_sword_crit` (`sword` tag: `crit: 100`) + `off_guard` 1 s on foe. |
| `Light as a Startled Goose` | `td-goose-and-dragon` (3p) | On `dragon_slipped` (or `evaded` from Sash) -> 4 s regrowth ticks (`1 %`/pulse = 4 % total) + `off_guard` 1 s on attacker. |
| `The River Keeps Its Bed` | `td-still-water-relics` (3p) | Water `art_fired` with `event.cost == 0` adds +1 extra `bend_count`; when `ninth_bent` triggers, `gain_qi: 0.03`. |
| `Voice in the Rain` | `td-rain-over-long-lake` (3p) | While `pine_rain >= 1` or `field_up >= 1`: `on: "heal_restored"` -> +1 Water buff + `gain_qi: 0.01`; `on: "always"` if `own.hp_share < 0.34` -> `healing: 25`. |
| `Keep Singing` | `td-unwritten-score` (3p) | Wood `art_fired` within gap -> `song` counter (`each_for: 8`); +2 % Wood `art_speed` & +3 % `soul_res` per `song`; at `song >= 4`: `status_immune: "silence"` + `on: "soul_taken"` spends 4 `song` to heal `event.amount`. |
| `Ground Set Before` | `td-ice-breaker-array` (3p) | First 5 s (`fight.time <= 5`): `+50 %` curse duration; while Field up & foe cursed 3 pulses -> `off_guard` 1.5 s + 1 Water debuff (`cooldown: 10`). |

RECORD PASS DONE

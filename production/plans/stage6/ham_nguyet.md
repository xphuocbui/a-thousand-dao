# Stage 6: Hàm Nguyệt Trang (`ham_nguyet`) (progress file)

Method: `production/plans/world-depth-implementation.md` Stage 6, "the per-sect method", and `production/plans/stage6/_brief-record.md` (headless job, decisions auto-accepted).

## Scope (`python -I tools/design/world/depth_gap.py --sect ham_nguyet`)
- **3 techniques:** `pearl-diver-breath` (Yellow main, Water), `moon-holding-scripture` (Earth main, Water), `nacre-over-grit-canon` (Profound secret, Water). Existing in lineage: `undertow-litany`.
- **5 new arts:** `empty-lungs`, `the-moon-in-the-water`, `full-pool`, `wrap-the-grain`, `cast-the-pearl`. (2 existing art refs: `gathering-wave`, `deep-lake-stance`.)
- **4 items, 1 set, 3 Effects:** `hn-tuyet-loc-fist-pearl` (`The Pearl Remembers`), `hn-moon-fish-lantern` (`False Moon`), `hn-nacre-robe`, `hn-frost-lotus-pin`, set `hn-moon-over-pearl` (`What Hurts You, Wrap`).
- **0 stand-ins, 0 beasts, 0 cross-owner refs.** (4 structured events close at Stage 7.)

## Step 1: Mechanic Table
`spatial_words_check.py --sect ham_nguyet`: 3 commentary/lore hits in `ham_nguyet.cast.json` (`alone` in tie note, `beside` in tree intent, `Still` in tree targets_note); 0 hits in techniques, arts, items, or sets.

| Record | Core Mechanic | Engine Support | Resolution |
|---|---|---|---|
| `pearl-diver-breath` | Outer Water main, long even linh lực | Existing (`bonuses`, `passives`) | Size `linh_luc_regen_inc_pct 7`, `status_resist_pct 5` (7.6 W of 8); `gathering-wave` (1), `empty-lungs` (2). |
| `empty-lungs` | Cannot be choked, air-poisoned, or broken out of a channel; faster linh lực regen | Existing (`mod`: `regen`, `delay_immune`, `status_resist`, `status_immune` w/ `tags`) | 5 s window: `+0.03` regen, `delay_immune 1`, `status_resist 50`; separate record `status_immune 1` on `tags: ["heavy_breath", "silence", "sealed_meridian"]`. |
| `moon-holding-scripture` | Inner Water main, heals/wards/wears down | Existing (`bonuses`, `passives`) | Size `linh_luc_pct 12`, `defense_pct 10` bonuses; 23.0 W of 24 passives; `deep-lake-stance` (1), `full-pool` (2), `the-moon-in-the-water` (4). |
| `the-moon-in-the-water` | 4 s Reflection decoy; struck restores part of blow as linh lực | Existing (`decoy`, `decoy_struck`, `gain_qi`, counters) | `decoy {n: 1}`, `refl_up = 1`, `refl_t = 4` (guarded `refl_up < 1`); `decoy_struck` restores `0.08` `qi_max` (proxy, as `decoy_struck` has no `amount`); pulse expiry decrements `decoy -1` if unstruck after 4 s. |
| `full-pool` | Slow HoT growing per second unmoved | Existing (`c_heal`, `heal`, `own.since_act`) | `c_heal 0.5` + 4 s pulse HoT: `1.5 %` max HP + `0.5 %` per second of `own.since_act` (uncapped). |
| `nacre-over-grit-canon` | Elders' Water secret: wrap hits into ward/Pearls, cast back | Existing (`bonuses`, `passives`) | Size `defense_pct 8` bonus; 15.7 W of 16 passives; `wrap-the-grain` (1), `cast-the-pearl` (3). |
| `wrap-the-grain` | Stance: foe arts grant Nacre + ward; 5 Nacre -> 1 Pearl | Existing (`was_hit`, `ward_grow`, counters) | Self-counter stance `wrap_stance` (coexists beside `deep-lake-stance` without overwriting it); `ward_grow 0.04` on cast, `+1 nacre` and `ward_grow 0.025` per foe art hit, `5 nacre -> 1 pearl` + `pearl_just_made`. |
| `cast-the-pearl` | Spend 1 Pearl to return last striking art at half damage as Water | Partial (no foe-art `c_art` memory) | Guarded `own.counter.pearl >= 1`, spends 1 Pearl, deals `c_art 2.0` Water hit (fixed half-heavy-art proxy). |
| `The Pearl Remembers` | Pearl made stores 30 s Nacre on Fist Pearl; < 1/3 HP spends all for 4 % ward/stack | Existing (`each_for: 30`, `hp_share <= 0.3334`, `ward_grow`) | `fist_nacre` (`each_for: 30`) fed by `pearl_just_made`; crossing `<= 0.3334` HP (hit or pulse) grows stance ward `0.04 * hp_max` per stack (matching `The Door Stays Shut`) and arms `fist_spent`. |
| `False Moon` | Reflection lasts 2x as long; while up, cultivate-rate linh lực regen | Existing (`art_fired`, `always`, `mod.regen`) | Adds `+4` to `refl_t` on `the-moon-in-the-water`; `+0.035` `regen` bonus while `refl_up >= 1`. |
| `What Hurts You, Wrap` | Absorbed foe arts lay Fist Nacre; Fist spend freezes ward 2 s (`ward_fixed`) & next Pearl lays 2 Ice | Existing (`ward_absorbed`, `ward_fixed`, `stacks`) | `ward_absorbed` (`kind: art`, `cooldown: 0.1`) -> `+1 fist_nacre`; on `fist_spent >= 1` (hit or pulse) -> `ward_fixed 1` for 2 s + `next_pearl_ice = 2`; `cast-the-pearl` consumes `next_pearl_ice` for 2 Ice stacks (8 s). |

## Steps
- [x] 1. Verify first: mechanic table & `spatial_words_check.py --sect ham_nguyet`.
- [x] 2. Techniques and arts (staged under `design/stage6-staging/ham_nguyet/` + 5 art ids inserted in `design/world/depth/sects/ham_nguyet.techniques.json`).
- [x] 3. Effects (`design/stage6-staging/ham_nguyet/effects/ham_nguyet.effects.json`): all 3 Effects compile and run standalone (`engine.validate` + 1-seed fight).
- [x] 4. Items and sets (`catalogue-sect-ham_nguyet.json`, `sets-ham_nguyet.json`): 4 items (all `unique: true`, `sources: ["npc"]`; `hn-tuyet-loc-fist-pearl` has `rarity: 5` + `grade: 4`; R6 `exception` on `hn-tuyet-loc-fist-pearl`, `hn-nacre-robe`, `hn-frost-lotus-pin`), 1 set (`hn-moon-over-pearl`).
- [x] 5. Stand-ins: 0 open in `ham_nguyet`.
- [x] 6. Beasts: 0 on `ham_nguyet`.
- [x] 7. Holder check (`DEPTH_STAGE=design/stage6-staging/ham_nguyet`):
      - `lint_arts.py`: 5 arts, **0 findings**.
      - `lint_techniques.py`: 3 techniques, **0 findings**.
      - `lint_items.py`: 4 items, **0 findings**.
      - `sect_fight.py ham_nguyet --seeds 5` (`--gap 0` and `--gap 1`) + targeted `mid_hard` probe on `kieu_nguyet_chau`: 0 `REFUSED`, every art fires, and all 3 Effects run (`The Pearl Remembers` 15 runs at gap 0 / 19 at gap 1; `What Hurts You, Wrap` 70 at gap 0 / 48 at gap 1 + `pearl` ice probe 4 runs; `False Moon` 31 runs at gap 0 / 4 at gap 1).
- [x] 8. Review file (`production/plans/stage6/ham_nguyet-review.md`): rule texts beside engine forms, 5 deviations, 5 auto-accepted decisions, 0 pending words, holder table.
- [x] 9. Finish: `RECORD PASS DONE` below and `production/plans/stage6/ham_nguyet.done` written.

RECORD PASS DONE

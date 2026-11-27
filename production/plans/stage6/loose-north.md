# Stage 6: `loose-north` (Batch `b06`, progress file)

Owner type: outside people group (`design/world/depth/people/loose-north.*`).
Scope (`depth_gap.py --sect loose-north`): `0` techniques, `0` new arts, `10` items, `4` sets, `7` Effects (`3` item + `4` set), `1` beast (`tiem_anh` on `quan_tuyet_tung`), `0` events, `20` stand-ins (`5` in `loose-north.cast.json`, `15` in `loose-north.2.cast.json`).

## Steps
- [x] 1. Verify first: `depth_gap.py --sect loose-north`, `spatial_words_check.py --sect loose-north` (0 hits), and mechanic table below.
- [x] 2. Techniques and arts: none (`0` new techniques, `0` new arts; `sand-wall-primer` from `tran_sa` already merged in `design/techniques/catalogue-sect-tran_sa.json`).
- [x] 3. Effects (`design/stage6-staging/loose-north/effects/loose-north.effects.json`).
- [x] 4. Items and sets (`design/stage6-staging/loose-north/items/catalogue-sect-loose-north.json`, `sets-loose-north.json`).
- [x] 5. Stand-ins (`loose-north.cast.json`, `loose-north.2.cast.json`).
- [x] 6. Beasts (`beasts: ["tiem_anh"]` on `quan_tuyet_tung` in `loose-north.cast.json`).
- [x] 7. Holder check (`lint_items.py`, `depth_check.py`, `stage6_merge.py loose-north --check`, `sect_fight.py loose-north --seeds 5 --gap 0` & `--gap 1`, plus targeted probes).
- [x] 8. Review file (`production/plans/stage6/loose-north-review.md`).
- [x] 9. Finish (`RECORD PASS DONE` + `production/plans/stage6/loose-north.done`).

## Step 1: Mechanic table
| Record | Kind | Depth rule | Classification | Engine plan |
|---|---|---|---|---|
| Flame Leans (`ln-old-bronze-lamp`) | Item Effect | Flame leans toward hidden doors and gutters before a live ward or trap array | Out-of-fight (`not_run`) | Wrap prose in `loose-north.items.json`; `not_run` entry in `loose-north.effects.json` |
| Thaw the Ice (`ln-thawing-brazier`) | Item Effect | Thaws old ice an hour and keeps frozen hall air breathable | Out-of-fight (`not_run`) | Wrap prose in `loose-north.items.json`; `not_run` entry in `loose-north.effects.json` |
| Thaw (`ln-thawing-brazier`, `d48`) | Item Effect | Fire hit removes 1 own Ice stack (max 2/pulse); each heals 0.5 % max HP and grants 1 Fire buff (5 s) | Existing words | `hit_landed` (`element: "fire"`, `own.debuff.ice >= 1`, `per_pulse: 2`) -> `cleanse {el: "ice", n: 1}`, `heal {share: 0.005}`, `stacks {el: "fire", n: 1, for: 5, side: "own", kind: "buff"}` |
| Will Not Fall (`ln-woodcutter-pair` 2pc) | Set Effect | Once/fight, fatal hit leaves 1 HP + full body shield; next axe hit in 3 s heals 50 % of damage | Existing words (`approx` on axe tag) | `down` (`per_fight: 1`) -> `refuse_down {}`, `shield {refill: 1.0}`, `will_not_fall_heal` (`each_for: 3, cap: 1`); `hit_landed` (`dtype: "phys"`) -> `heal {of: "amount", share: 0.5}` |
| The Way Out (`ln-digger-kit` 3pc) | Set Effect | Once/fight below 1/3 HP leave at once; inside foe's array, seal hits break nodes | Existing words (`approx`) | `was_hit`/`pulse` (`hp_share <= 0.333`, `per_fight` via `way_out_used`) -> `mod {escape: 100, for: 10}`; `hit_landed` (`tags: ["seal"]`, `foe.field_up >= 1`) -> `status {sundered, 1, 6s}` + `timer {foe, next, 0.4}` |
| Never Had a Healer (`ln-bobtail-gear` 3pc) | Set Effect | Wasted leech becomes body shield decaying 10 %/s; while active, axe crits deal +25 % damage | Existing words (`approx` on axe tag) | `heal_overflow` (`source: "leech"`) -> `heal {of: "amount", share: 1.0, body_shield: true}` + `leech_shield_up`; `pulse` -> `-0.1` body shield scaled by `own.body_shield_share`; `always` -> `mod {crit_mult: 25, dtype: "phys"}` |
| Hot Hands (`ln-thaw-girl-fire` 2pc) | Set Effect | Fist hits lay 1 Fire stack, or 2 if foe carries Ice stacks or is slowed | Existing words | `hit_landed` (`tags: ["fist"]`) -> `stacks {el: "fire", n: 2 or 1, for: 6, side: "foe"}` |

RECORD PASS DONE

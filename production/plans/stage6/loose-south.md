# Stage 6: `loose-south` (Batch `b06`, progress file)

Owner type: outside people group (`design/world/depth/people/loose-south.*`).
Scope (`depth_gap.py --sect loose-south`): `0` techniques, `0` new arts, `13` items (`ls-white-wind-hook` also held by `thien_xu`'s `do_vo_cuu`), `5` sets, `10` Effects (`2` clashes on `Know the Way Out` owned by `world-depth:thien_xu`, `8` new: `4` item + `4` set), `1` beast (`bat_phe` on `an_thu_son`), `0` events, `16` stand-ins (`3` in `loose-south.cast.json`, `13` in `loose-south.2.cast.json`).

Cross-owner note: `do_liet_co` holds `black-wind-blood-sabre` (`aux2`), owned and staged by `demonic` (`design/stage6-staging/demonic/`). Do NOT duplicate or early-promote it; both land together in `b06` serial.

## Steps
- [x] 1. Verify first: `depth_gap.py --sect loose-south`, `spatial_words_check.py --sect loose-south` (0 hits; manual scan caught `"from range"` on `ls-unlit-sail` / `ls-stockade-pair` and `"Still"` on `ls-free-crossing` in `people/loose-south.items.json`), and mechanic table below.
- [x] 2. Techniques and arts: none (`0` new techniques, `0` new arts).
- [x] 3. Effects (`design/stage6-staging/loose-south/effects/loose-south.effects.json`).
- [x] 4. Items and sets (`design/stage6-staging/loose-south/items/catalogue-sect-loose-south.json`, `sets-loose-south.json`).
- [x] 5. Stand-ins (`loose-south.cast.json`, `loose-south.2.cast.json`).
- [x] 6. Beasts (`beasts: ["bat_phe"]` on `an_thu_son` in `loose-south.cast.json`).
- [x] 7. Holder check (`lint_items.py`, `depth_check.py`, `stage6_merge.py loose-south --check`, `sect_fight.py loose-south --seeds 5 --gap 0` & `--gap 1`, plus targeted probes).
- [x] 8. Review file (`production/plans/stage6/loose-south-review.md`).
- [x] 9. Finish (`RECORD PASS DONE` + `production/plans/stage6/loose-south.done`).

## Step 1: Mechanic table
| Record | Kind | Depth rule | Classification | Engine plan |
|---|---|---|---|---|
| `Know the Way Out` (`ls-thu-am-goat-bell`, `ls-unlit-sail`) | Item Effect | Each escape you fail this fight makes your next escape 10 % likelier; a success clears it (`d2`) | Clash -> existing (`world-depth:thien_xu`) | Set `"new": false` in `loose-south.items.json`; reference `"Know the Way Out"` on both items in `catalogue-sect-loose-south.json`; do not redefine in `loose-south.effects.json` |
| `The Goat Knows` (`ls-thu-am-goat-bell`) | Item Effect | Bell rings before poison ground; in a fight, first poison or curse stack applied each fight is refused | Existing words (`approx`) | `goat_refused` (cap 1): on `was_hit` or `pulse` when `own.debuff.wood >= 1` or `own.curses >= 1`, sets `goat_refused = 1` and cleanses 1 Wood stack or 1 curse |
| `No Fare` (`ls-thuy-khau-stern-lamp`) | Item Effect | While you have a companion, you regain 1 % of your health each second | Existing words (`approx` latch) | Latch `has_companion` (cap 1) on `hit_landed` / `was_evaded` (`kind: "companion"`); on `pulse` if `has_companion >= 1`, `heal {share: 0.01}` |
| `Stamp of Trust` (`ls-false-cloud-seal`) | Item Effect | Forged seal passes for Nam Phố's work except to true seal holder | Out-of-fight (`not_run`) | `not_run` entry in `loose-south.effects.json`, `records: []` |
| `Dark on Dark Water` (`ls-unlit-sail`) | Item Effect | Out of combat unseen on water; in a fight, first art aimed at her from range misses | Existing words (non-spatial `approx`) | On `fight_start`, `decoy {n: 1}` (avoids first incoming direct hit) |
| `Walked Out of Chiết Kích` (`ls-miasma-walker` 3pc) | Set Effect | Each poison/curse stack thickens ward by 2 % HP instead of harm; ward loses 1/20 per s; while it holds, escape channel 1/3 shorter | Existing words (`approx` on escape channel) | On `was_hit`/`pulse` scaled by `own.debuff.wood` / `own.curses`: `ward_grow {share: 0.02, of: "hp"}` + `cleanse`; on `pulse` scaled by `own.ward_share` (`floor: false`): `ward_grow {share: -0.05, of: "hp"}`; `always` while `own.ward_share > 0`: `mod {escape: 15}` |
| `Tempered by Arrows` (`ls-stockade-pair` 2pc) | Set Effect | Each hit taken from range gives 1 Thunder buff stack, falling 1 per 2 s; next hook strike spends them, striking once more with Thunder for each | Existing words (non-spatial `approx`) | On `was_hit` (`event.amount > 0`): `stacks {el: "thunder", n: 1, for: 8, side: "own", kind: "buff"}` + `arrow_thunder +1`; `pulse` (`cooldown: 2`): `arrow_thunder -1` + `consume {el: "thunder", n: 1}`; `hit_landed` (`tags: ["sword", "saber"]`): scaled `free_hit {c: 0.4, dtype: "lightning"}` + clear |
| `No One Drowns` (`ls-free-crossing` 2pc) | Set Effect | While you have a companion or are Still, ward regains 2 %/s; first time below 1/4 HP, heals 15 % | Existing words (Still -> Composed) | On `pulse` if `has_companion >= 1` or `own.composed >= 1`: `ward_grow {share: 0.02, of: "hp"}`; on `wounded` (`per_fight: 1`): `heal {share: 0.15}` |
| `Leave While It Burns` (`ls-night-rain-stall` 2pc) | Set Effect | When a curse you laid is cleansed or a talisman burns out, untargetable for 1 s (once per 6 s) | Existing words (`approx`) | Shared `burn_vanish_cd` (`each_for: 6, cap: 1`): on `cleansed` or `batch_ended` when `burn_vanish_cd == 0`, `decoy {n: 1}`, `mod {evade: 40, for: 1.0}`, `burn_vanish_cd +1` |

RECORD PASS DONE

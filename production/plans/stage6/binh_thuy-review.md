# Bình Thủy Môn: Stage 6 review (2026-11-27, headless auto-accepted)

## Summary

- **Built (staged under `design/stage6-staging/binh_thuy/`):**
  - **1 technique:** `duckweed-drift-primer` (`techniques/catalogue-sect-binh_thuy.json`), Yellow main, `thuy`/`moc`, 6 layers, passives sized at 7.9 W of 8.0 W.
  - **2 new arts:** `close-over-the-stone` (Wood heal + reactive 3 s HoT on `was_hit`) and `chance-meeting` (Water quick strike + Water buff) in `arts/part-sect-binh_thuy.json`; art IDs written into `design/world/depth/sects/binh_thuy.techniques.json`.
  - **7 signature items and 2 sets:** all 7 items in `items/catalogue-sect-binh_thuy.json` (`sources: ["npc"]`, `unique: true`, R6 `exception` on the 4 weapons/armour/shield) and both 3-piece sets in `items/sets-binh_thuy.json`.
  - **4 Effects:** `Every Day of the Year`, `Slack Water`, `Somewhere Else by Morning`, and `The Tenth Layer` in `effects/binh_thuy.effects.json`.
- **Stand-ins & beasts:** `0` stand-ins, `0` beasts, `0` cross-owner references.
- **Deviations:** `4` logged across records (details in §C–§E).
- **Decisions taken (auto-accepted):** `6` (listed in §A with reasons).
- **Pending words:** `0` (all mechanics expressed cleanly with existing engine words).
- **Never ran:** `0` — all 2 new arts and all 4 Effects ran on their real holders in `sect_fight.py` (`--gap 0` and `--gap 1`), and every sub-record ran in per-record / probe checks.
- **Early promotions:** `0`.
- **Open items:**
  - Serial merge & export (`stage6_merge.py`, `export_techniques.py`, `export_named.py`, `export_combat_library.py`, `compile_parity_export.py`, `export_world.py`) to close `techniques`, `arts_new`, `items`, `sets`, `effects`, and the 7 structured `events`.

---

## A. Auto-accepted decisions (with reasons)

1. **`duckweed-drift-primer` passives and unlock layers:** Set passives to `healing_pct 5`, `evade_pct 2`, and `linh_luc_regen_inc_pct 3` (all untagged, `7.9 W` of `8.0 W` Yellow main budget) with `close-over-the-stone` at layer `1` and `chance-meeting` at layer `2`.
   - *Reason:* Depth text specifies no bonuses/passives. Untagged healing, evade, and qi regen match "drifts, and heals a little each time it is struck" equally for both Water-primary and Wood-primary outer disciples, and unlocking both arts by layer 2 ensures every outer holder (layers 2–4) accesses both arts.
2. **`close-over-the-stone` dual active + reactive form:** Authored as a Wood `heal` art (`c_heal 0.4`, `cost_share 0.025`, `cooldown 5.0`, `buff [1, 8.0]`) carrying reactive `was_hit` (`event.amount > 0`, `cooldown 6.0`, `duckweed_mend == 0`) -> 3 pulses of `heal {share: 0.015}`.
   - *Reason:* Keeps the art useful and firing in `sect_fight.py` while faithfully implementing the post-hit 3 s HoT without clobbering active ticks or triggering on 0-damage hits.
3. **`chance-meeting` authored as Water without a new `own.purity` comparison word:** Authored as `element: "water"`, `c_art 1.5`, `cost_share 0.025`, `cooldown 2.0`, `buff [1, 8.0]` rather than adding a pending `own.purity.<el>` comparison readable.
   - *Reason:* `engine.holds()` compares a single readable to a constant, and `Art.element`/`dtype` are static; adding a one-off element-comparison mechanism for a Yellow outer-gate primer is not worth a new engine word (`_brief-record.md`: "Prefer an existing word whenever it keeps the intent... A new word must be worth it for builds"). Pairing Water `chance-meeting` with Wood `close-over-the-stone` keeps both sect elements represented across the primer's two arts.
4. **`Every Day of the Year` slow/delay immunity scope:** Uses `status_immune {status: "slowed_time"}` and `delay_immune: 1` whenever `own.buff.water >= 1`, without filtering by the foe art's element (`wind`/`water`).
   - *Reason:* The engine's `status_immune` and `delay_immune` checks do not pass the caster art's `element` in `ctx`. Marked `approx` in `binh_thuy.effects.json`.
5. **`Somewhere Else by Morning` non-spatial rewrite & record order:** Removed `"carries you behind the attacker"` (no spatial fight rule 2026-11-26) and ordered `evaded` `consume 5` (`own.buff.water >= 5`) *before* `evaded` `+1 Water buff`.
   - *Reason:* Non-spatial combat has no positioning; ordering `consume` before the `+1` grant guarantees reaching 5 stacks waits for the *next* evade to trigger the 5 s healing tide (`5 %` HP/s via manual pulse decrement rather than `decay_per_pulse`).
6. **`Slack Water` + `The Tenth Layer` coordination with standalone parity:** `Slack Water` arms `slack_armed = 1` on `buff_gained` (`element: "water"`, `own.buff.water >= 5` or `>= 4` when `slack_water_threshold >= 1`) and heals `4 %` on `art_fired` (`group: "still-moon-tide-scripture"`), wrapping the `heal` call with `slack_just_healed = 1 -> 0` so `The Tenth Layer` listens on `heal_restored`/`heal_overflow` (`slack_just_healed >= 1`) to grant +1 Water buff stack. `The Tenth Layer` also refreshes own Water buff batches on `blocked` (`event.amount > 0`).
   - *Reason:* Arming on `buff_gained` ensures empowered `swelling-tide-palm` (which consumes Water buffs in `shape()` before `art_fired`) still receives the Shell's 4 % heal; `slack_just_healed` makes the two Effects order-independent and standalone-compilable (`test_every_library_effect_compiles`); `refresh` on `blocked` restarts Water buff timers only while blocking. Signature items marked `unique: true` (`sources: ["npc"]`) and R6 `exception` added to the 4 weapons/armour/shield (`bth-following-wind-fan`, `bth-claw-king-shell`, `bth-strait-crossing-coat`, `bth-shell-gatherer-robe`).

---

## B. Pending words

None (`0` pending words; no `pending.json`).

---

## C. Techniques (`design/stage6-staging/binh_thuy/techniques/catalogue-sect-binh_thuy.json`)

| Technique | Tier, kind | Bonuses | Passives (new, unpriced) | Arts (unlock layer) |
|---|---|---|---|---|
| `duckweed-drift-primer` | Yellow (0) main, `thuy` + `moc` | none | `healing_pct` 5, `evade_pct` 2, `linh_luc_regen_inc_pct` 3 (`7.9 W` of `8.0`) | `close-over-the-stone` (1), `chance-meeting` (2) |

---

## D. Arts (`design/stage6-staging/binh_thuy/arts/part-sect-binh_thuy.json`)

| Art | Depth concept | Engine form | Deviation |
|---|---|---|---|
| `close-over-the-stone` | After the holder is hit, a light heal over 3 s; once per few seconds | Wood `heal` (`c_heal 0.4`, `cost_share 0.025`, `cooldown 5.0`, `buff [1, 8.0]`); on `was_hit` (`event.amount > 0`, `cooldown 6.0`, `duckweed_mend == 0`) -> 3 pulses of `heal {share: 0.015}` | Added light active cast heal + 1 Wood buff so casting the art itself has an effect on cast |
| `chance-meeting` | Quick strike dealing Water or Wood damage (stronger element) and granting 1 buff stack | Water `elem` (`c_art 1.5`, `cost_share 0.025`, `cooldown 2.0`, `buff [1, 8.0]`) | Fixed as Water instead of dynamically comparing Water vs Wood purity (no `own.purity` comparison in engine) |

---

## E. Effects (`design/stage6-staging/binh_thuy/effects/binh_thuy.effects.json`)

| Effect (source) | Depth rule | Engine form | Deviation |
|---|---|---|---|
| `Every Day of the Year` (`bth-following-wind-fan`) | While you carry a Water buff stack, slows from the foe's Wind and Water arts do not slow you, and your first evade each fight grants 2 Water buff stacks | `always` (`own.buff.water >= 1`): `status_immune {status: "slowed_time"}` + `delay_immune: 1`; `evaded` (`per_fight: 1`): +2 Water buff stacks (8 s) | Slow/delay immunity applies to all foe slows/delays (engine checks lack foe art element; marked `approx`) |
| `Slack Water` (`bth-claw-king-shell`) | When you block, gain 1 Water buff stack; at 5 stacks your next Still Moon Tide art heals you for 4 % of your health | `blocked` (`event.amount > 0`): +1 Water buff (8 s); `buff_gained` (`water`) at >= 5 (or >= 4 with `slack_water_threshold >= 1`) arms `slack_armed = 1`; `art_fired` (`group: "still-moon-tide-scripture"`, `slack_armed >= 1`) heals 4 % HP | None (armed via `buff_gained` so empowered `swelling-tide-palm` buff consumption does not skip the heal) |
| `Somewhere Else by Morning` (`bth-the-crossing`) | Evade -> +1 Water buff; at 5 stacks next evade carries you behind the attacker and turns all 5 into a tide healing 1 %/stack/s for 5 s | `evaded` (`own.buff.water >= 5`): `consume` 5 Water buffs + `crossing_tide = 5`; `evaded`: +1 Water buff (8 s); `pulse` (`crossing_tide >= 1`): `heal {share: 0.05}`, `crossing_tide - 1` | Non-spatial rewrite: dropped `"carries you behind the attacker"` (no positions in combat) |
| `The Tenth Layer` (`bth-slack-water`) | Shell's heal comes at 4 Water buff stacks instead of 5; each heal it makes grants +1 Water buff; while you block, Water buff stacks do not fade | `fight_start`: `slack_water_threshold = 1`; `heal_restored`/`heal_overflow` (`slack_just_healed >= 1`): +1 Water buff (8 s); `blocked` (`event.amount > 0`): `refresh {el: "water", side: "own", kind: "buff"}` | None |

---

## F. Items & sets (`design/stage6-staging/binh_thuy/items/`)

- **7 items** (`catalogue-sect-binh_thuy.json`), modifiers unchanged, `sources: ["npc"]`, `unique: true`, `arts: []`, Effects named in plain English:
  - R6 `exception` on `bth-following-wind-fan` (`phien`), `bth-claw-king-shell` (`thuan`), `bth-strait-crossing-coat` (`dao_bao`), `bth-shell-gatherer-robe` (`dao_bao`).
  - No `exception` needed on `bth-crossing-lamp` (`dang`), `bth-ferry-token-ring` (`nhan`), `bth-phieu-bong-tide-mirror` (`kinh`).
- **2 sets** (`sets-binh_thuy.json`): `bth-the-crossing` (3pc, `bui_phieu_binh`), `bth-slack-water` (3pc, `luong_bach_tan`).

---

## G. Holder check (`sect_fight.py binh_thuy`, 5 seeds)

### Linters (`DEPTH_STAGE=design/stage6-staging/binh_thuy`)
- `lint_arts.py`: `2` arts, `0` findings.
- `lint_techniques.py`: `1` technique (`duckweed-drift-primer`, `7.9 W of 8`), `0` findings.
- `lint_items.py`: `7` items (`7 of 7` unique), `0` findings.
- Standalone `engine.validate()` + dummy fight on all 4 Effects: `4/4` passed.

### `sect_fight.py binh_thuy --seeds 5 --gap 0` and `--gap 1`

| Holder | Realm | Arts | Gap 0 (`mean_s`, `wins`, `hp_left`) | Gap 1 (`mean_s`, `wins`, `hp_left`) | Effect runs (gap 0 / gap 1) |
|---|---|---|---|---|---|
| `ba_lang_nhi` | `luyen_khi` | `close-over-the-stone`, `chance-meeting` | `51.6 s`, `5/5`, `78%` | `8.0 s`, `0/5`, `0%` | n/a (`close-over-hit` 45, `close-over-pulse` 131 at gap 0) |
| `nhu_thanh_can` | `luyen_khi` | `close-over-the-stone`, `chance-meeting` | `51.6 s`, `5/5`, `78%` | `8.0 s`, `0/5`, `0%` | n/a |
| `hoan_khach_nhi` | `luyen_khi` | `close-over-the-stone`, `chance-meeting` | `51.6 s`, `5/5`, `78%` | `8.0 s`, `0/5`, `0%` | n/a |
| `ngo_ba_can` | `luyen_khi` | `close-over-the-stone`, `chance-meeting` | `51.6 s`, `5/5`, `78%` | `8.0 s`, `0/5`, `0%` | n/a |
| `ong_tieu_pham` | `luyen_khi` | `close-over-the-stone`, `chance-meeting` | `51.6 s`, `5/5`, `78%` | `8.0 s`, `0/5`, `0%` | n/a |
| `ton_niem_trieu` | `luyen_khi` | `close-over-the-stone`, `chance-meeting` | `51.6 s`, `5/5`, `78%` | `8.0 s`, `0/5`, `0%` | n/a |
| `dam_thuy_sinh` | `luyen_khi` | `close-over-the-stone`, `chance-meeting` | `51.6 s`, `5/5`, `78%` | `8.0 s`, `0/5`, `0%` | n/a |
| `ngo_tan_tan` | `luyen_khi` | `close-over-the-stone`, `chance-meeting` | `51.6 s`, `5/5`, `78%` | `8.0 s`, `0/5`, `0%` | n/a |
| `ong_te_do` | `truc_co` | `deep-lake-stance`, `gathering-wave`, `brimming-cup`, `swelling-tide-palm`, `backwash-seal` | `13.6 s`, `5/5`, `100%` | `9.0 s`, `0/5`, `0%` | n/a |
| `bui_phieu_binh` | `ket_dan` | `deep-lake-stance`, `gathering-wave`, `brimming-cup`, `swelling-tide-palm`, `swallow-stance`, `hundred-feather-flurry` | `19.2 s`, `5/5`, `100%` | `14.8 s`, `0/5`, `0%` | `Every Day of the Year`: `5 / 5`; `Somewhere Else by Morning`: `61 / 54` |
| `luong_bach_tan` | `ket_dan` | `deep-lake-stance`, `gathering-wave`, `brimming-cup`, `swelling-tide-palm`, `backwash-seal`, `seep-through-palm` | `10.6 s`, `5/5`, `100%` | `22.0 s`, `0/5`, `0%` | `Slack Water`: `199 / 485`; `The Tenth Layer`: `122 / 275` |

### Targeted probes
- **`bui_phieu_binh` vs slow/delay foe (`drag-of-the-deep` + `frost-breath-palm`, 5 seeds):** `22.7 s` (`100%`) with `Every Day of the Year` vs `25.2 s` (`100%`) without (`status_immune` + `delay_immune` prevent foe slow/delay).
- **`luong_bach_tan` with `bth-claw-king-shell` alone (`Slack Water` without `The Tenth Layer`, 5 seeds):** `5/5` wins, `10.5 s`, `eff:Slack Water arm: 40`, `eff:Slack Water block: 87`, `eff:Slack Water heal: 13`.
- **Per-record counts (gap 0, 5 seeds):**
  - `bui_phieu_binh`: `Every Day of the Year evade: 5`, `Somewhere Else by Morning tide: 5`, `stack: 35`, `heal: 21`.
  - `luong_bach_tan`: `Slack Water block: 83`, `arm: 82`, `heal: 34`, `The Tenth Layer threshold: 5`, `heal: 5`, `heal_overflow: 29`, `refresh: 83`.
  - `ba_lang_nhi`: `close-over-hit: 45`, `close-over-pulse: 131`.

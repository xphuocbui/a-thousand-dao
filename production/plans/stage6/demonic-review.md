# Stage 6 Review — `demonic` (`design/world/depth/people/demonic.*`)

## Summary
- **Owner**: `demonic` (Ma đạo circle outside the sects; Batch `b06`)
- **Staged files** (`design/stage6-staging/demonic/`):
  - `techniques/catalogue-sect-demonic.json`: 9 techniques (7 existing methods from `demonic.techniques.json` + 2 new stand-in carrier canons: `copper-mountain-bell-canon`, `night-moth-karst-canon`)
  - `arts/part-sect-demonic.json`: 6 authored arts (`borrowed-sleep`, `drink-within-a-breath`, `move-the-sickness`, `black-frost-seal`, `soul-ledger-chime`, `night-moth-ink`)
  - `items/catalogue-sect-demonic.json`: 12 unique NPC items (`dm-blood-red-robe`, `dm-ink-needle`, `dm-blood-seal`, `dm-cracked-bell`, `dm-borrowed-wick-lamp`, `dm-cave-orchid-pendant`, `dm-black-wind-sabre`, `dm-bitter-well-gourd`, `dm-sons-lamp`, `dm-pedlar-robe`, `dm-karst-lamp`, `dm-ink-grinder-robe`)
  - `items/sets-demonic.json`: 3 sets (`dm-set-blood-ink-study`, `dm-soul-pedlar`, `dm-u-lan-keeper`)
  - `effects/demonic.effects.json`: 15 Effects (`source: "world-depth:demonic"` — 2 technique passives, 10 item Effects, 3 set 3-piece Effects; 0 pending words)
- **World-depth in-place updates** (`design/world/depth/people/demonic.*`):
  - `demonic.techniques.json`: added `"id": "borrowed-sleep"` on `shade-orchid-breath` and added `copper-mountain-bell-canon` & `night-moth-karst-canon`
  - `demonic.items.json`: normalized `dm-set-blood-ink-study` 3pc `effect` prefix to `Writ in Their Blood (Huyết Thư): ...`
  - `demonic.cast.json` & `demonic.2.cast.json`: replaced all 16 stand-in `build.main` entries (`stand_ins: 0`)
- **Gate verification** (with `DEPTH_STAGE=design/stage6-staging/demonic`):
  - `lint_arts.py`: `checked 6 arts in 1 files, 0 findings`
  - `lint_techniques.py`: `checked 9 techniques, 0 findings` (`black-ice-method` `curse_effect_pct` emitted `NOT_PRICED` note only)
  - `lint_items.py`: `checked 12 items, 22 bases, 9 common arts, 0 findings`
  - `spatial_words_check.py --sect demonic`: 0 demonic findings (`67` records with non-soft hits all shipped)
  - `depth_check.py --quiet`: `findings: none` (`1891` people, `266` techniques)
  - `depth_gap.py --sect demonic`: `stand_ins: 0`, `unknown_ids: 0`, `ties_unmapped: 0`, `engine_words: 0`, `wishes_open: 0`
  - `stage6_merge.py demonic --check`: `0 failure(s)`
  - Standalone `engine.validate()`: `Validated 15 effects standalone, failures=0`
  - `sect_fight.py demonic --seeds 5 --gap 0` and `--gap 1`: exit `0`, NO `REFUSED`; all 6 arts and 10/14 combat Effects fire on holders (plus 4 unslotted/conditional Effects verified via 5 targeted probes; `Fed in Blood` marked `not_run`).

---

## §A — Auto-Accepted Decisions & Deviations
1. **`drink-within-a-breath` (`e7` fix)**: `auth-tech.json` used `state.for: 1` (not parsed by `engine.py`/`effect_runner.gd`) and `gain_qi {of: "heal_share", share: 1.0}` (would restore 100% max linh lực). Replaced `state` with self-counter `within_a_breath` (`cap: 1`, `each_for: 1`, refreshed via `add: 1`); fixed `breath-drinks` to `scale {read: "event.share", per: 0.01, floor: false}` + `gain_qi {share: 0.01}`, and added `breath-cut-qi` on `hit_landed` (`gain_qi {of: "amount", share: 0.06}`) because `heal {of: "amount"}` does not tag `source: "leech"`.
2. **`move-the-sickness` (`e8` fix)**: `auth-tech.json` passed a dict to `pay_per_stack` (engine expects plain float) and `{amount: ...}` to `free_hit` (engine requires `c`). Converted to `"pay_per_stack": 0.005` and `"free_hit": {"c": 0.7, "dtype": "chaos", "pass_shields": true}`.
3. **`black-frost-seal` (`e9` fix)**: `debuff: [5, 6]` + `statuses: [{withering}]` summed to `0.85` charge (`> 0.60` `CHARGE_FAIL` in `lint_arts.py`). Moved `Withering` (`stacks: 1, dur: 4`) into `effects` (`on: "hit_landed"`, `per_firing: 1`), preserving exact art gameplay and empowerment.
4. **Element `""` on Darkness arts & `"soul"` scope on items**: Engine `ELEMENTS` has no `"darkness"` key yet, so `borrowed-sleep` and `night-moth-ink` use `"element": ""` (matching `blood-ink-writ` and `thorn-lullaby`) with `"darkness"` in `tags`. Changed `art_speed_pct` scope `"song"` to `"soul"` on `dm-cracked-bell`, `borrowed-wick-sutra`, and `copper-mountain-bell-canon` to match Modifier vocabulary (`lint_items.py` `SCOPE` check).
5. **Counter consumption via `counter set: 0` (not `consume`)**: `engine.py`'s `consume` verb targets element `debuffs`/`buffs` (requiring `el`), not counters. Replaced counter consumption in `Draw the Ink`, `The Held Voice`, `Nine Wicks`, and `Writ in Their Blood` with `counter {id: ..., set: 0}`.
6. **Treasure rarity floor & R6 exceptions**: Upgraded `dm-borrowed-wick-lamp` and `dm-sons-lamp` (`kind: "treasure"`) from `grade: 3`/`2` to `rarity: 4`, and `dm-blood-seal` (`grade: 4`) to `rarity: 5` (matching treasure schema). Added R6 `exception` to the 8 items whose base carries a `common_art` or `common_ward` (`dao_bao`, `cham`, `an`, `chuong`, `phi_kiem`, `ho_lo`).
7. **Stand-in carrier canon assignment**: Added `copper-mountain-bell-canon` (`ham_tan_chung` `dia_kim`) and `night-moth-karst-canon` (`sao_an_lan` `huyen_am`), promoted `khoai_thiet_ung`'s `main` to `black-wind-blood-sabre` L9 (removing the duplicate entry in `aux`), and mapped the 13 `demonic.2.cast.json` stand-ins cleanly.
8. **`Fed in Blood`**: Seasonal out-of-fight upkeep hook with `not_run` and `records: []` (matching `Chars in a Season`).

---

## §B — Mechanic Classification Table (Summary)
- **Techniques (`9`)**: `blood-ink-canon` (T2 main), `shade-orchid-breath` (T0 main), `red-debt-rite` (T1 secret), `borrowed-wick-sutra` (T1 secret), `black-wind-blood-sabre` (T1 main), `withered-branch-method` (T1 secret), `black-ice-method` (T2 secret, authored), `copper-mountain-bell-canon` (T2 main, carrier), `night-moth-karst-canon` (T1 main, carrier).
- **Arts (`6`)**: `borrowed-sleep`, `drink-within-a-breath`, `move-the-sickness`, `black-frost-seal`, `soul-ledger-chime`, `night-moth-ink`.
- **Items (`12`)** & **Sets (`3`)**: all 12 `dm-*` unique NPC pieces + `dm-set-blood-ink-study`, `dm-soul-pedlar`, `dm-u-lan-keeper`.
- **Effects (`15`)**: `The Black Under the White`, `Black Thaw`, `The Robe Drinks First`, `Draw the Ink`, `Sealed in His Name`, `The Held Voice`, `Nine Wicks`, `Drink from the Dark`, `Within a Breath`, `His Sister's Water`, `Fed in Blood` (`not_run`), `Lullaby of the Karst`, `Writ in Their Blood`, `A Breath Bought`, `A Breath That Costs No One`.

---

## §C — Techniques (`techniques/catalogue-sect-demonic.json`)
- All 9 techniques carry `"owner": "demonic"`, `"origin": "authored"`, tier-matched `bonuses` (0 / 1 / 2), valid passive scopes, and W totals under budget (`8 / 16 / 24 W`):
  - `shade-orchid-breath`: `6.0 W / 8`
  - `red-debt-rite`: `10.4 W / 16`
  - `borrowed-wick-sutra`: `13.8 W / 16`
  - `black-wind-blood-sabre`: `11.9 W / 16`
  - `withered-branch-method`: `8.5 W / 16`
  - `night-moth-karst-canon`: `10.6 W / 16`
  - `blood-ink-canon`: `14.3 W / 24` (`abilities` unlock at L1 / L4 / L6)
  - `copper-mountain-bell-canon`: `18.8 W / 24`
  - `black-ice-method`: `NOT ASSESSED W of 24` (`curse_effect_pct` note only, `0` findings)

---

## §D — Arts (`arts/part-sect-demonic.json`)
- `borrowed-sleep`: elem, `c_art 1.2`, `cost_share 0.03`, `cd 5` — lays 10 `stagnation` (4 s) + `+0.015` `regen` (4 s) on hit.
- `drink-within-a-breath`: phys, `c_art 1.3`, `cost_share 0.03`, `cd 3` — 15% damage heal + leech-to-linh-lực during 1 s post-crit window (`within_a_breath`).
- `move-the-sickness`: elem/wood, `c_art 0.8`, `cost_share 0.04`, `cd 5` — `move_own_debuffs` (`pay_per_stack: 0.005`) + at layer >= 9, `4%` heal & Chaos `free_hit` (`c: 0.7`, `pass_shields: true`).
- `black-frost-seal`: elem/ice, `c_art 1.0`, `cost_share 0.04`, `cd 5`, `debuff [5, 6]`, 30% Chaos convert + `Withering` (1 stack, 4 s) on hit; x2.5 & 100% Chaos at `foe.debuff.ice >= 10` & `withering >= 1`.
- `soul-ledger-chime`: elem/metal, `soul_pct 0.036`, `cost_share 0.05`, `cd 4` — soul damage + `slackened_soul` (4 s).
- `night-moth-ink`: elem, `c_art 1.2`, `cost_share 0.04`, `cd 4` — lays `withering` (4 s).

---

## §E — Effects (`effects/demonic.effects.json`) & Holder Verification
| Effect | Holder / Probe | Gap 0 runs (mean_s / HP%) | Gap 1 runs / Probe | Status |
|---|---|---|---|---|
| `The Robe Drinks First` | `trieu_huyet_y` | `0` (wins 100%, never `<50%` HP) | `5` (10.6s vs 10.0s) | Verified |
| `Draw the Ink` | `trieu_huyet_y` / Probe P1 | `5` (gap 0) | P1: `arm 25`, `spend 20` | Verified |
| `The Held Voice` | `ham_tan_chung` | `10` (10.6s vs 14.4s) | `10` (10.2s vs 10.2s) | Verified |
| `Nine Wicks` | `ham_tan_chung` / NW Probe | `5` (`fight_start`) | NW Probe: `save 5`, `refusals 5/5` | Verified |
| `A Breath Bought` | `ham_tan_chung` | `20` (10.6s vs 10.6s, 81% vs 84%) | `7` (10.2s vs 9.0s) | Verified |
| `Drink from the Dark` | `sao_an_lan` | `runs 291` (at gap 1; via `pulse` 1.1 s `regen` mod) | `291` (61.5s) | Verified |
| `Lullaby of the Karst` | `sao_an_lan` | `61` (57.8s vs 31.7s) | `63` (61.5s vs 33.2s) | Verified |
| `A Breath That Costs No One` | `sao_an_lan` | `625` (57.8s 96% vs 57.7s 5% HP!) | `663` (61.5s vs 25.7s) | Verified |
| `Within a Breath` | `khoai_thiet_ung` | `68` (21.6s, 84%) | `22` (8.0s) | Verified |
| `His Sister's Water` | `tra_ham_tuyen` / Probe P5 | `1` | `5` (11.9s vs 9.3s); P5 drink `3` | Verified |
| `Writ in Their Blood` | Probe P1 (3pc Study) | — | P1: `free 20`, `empower 15` | Verified (probe) |
| `Sealed in His Name` | Probe P1 (`dm-blood-seal`) | — | P1 (`always` `art_id` `status_dur 100`) | Verified (probe) |
| `The Black Under the White` | Probe P4 (`black-ice-method`) | — | P4 (`always` `counted_curse_per 5`) | Verified (probe) |
| `Black Thaw` | Probe P4 (`black-ice-method`) | — | P4: `54` triggers | Verified (probe) |
| `Fed in Blood` | `mat_thu_ninh` | `0` (`not_run`) | `0` (`not_run`) | Deferred (out-of-fight) |

- Additional art probes:
  - `move-the-sickness` (`duong_kho_chi` overflowed `MAX_ARTS = 6` in cast): Probe P2 fired `35` times (`sickness-moved: 35`, `wound-moved: 35`).
  - `Nine Wicks` non-soul vs soul isolation: required `event.amount > 0` AND `own.hp_share > 0` on `eff:Nine Wicks clear mark` so 0-damage and corpse-tap basic hits occurring later in the lethal soul tick do not clear `last_hit_soul` before `down` runs (`5/5` lethal soul saves confirmed).

---

## §F — Items (`items/catalogue-sect-demonic.json`) & Sets (`items/sets-demonic.json`)
- All 12 items pass `lint_items.py` (`0 findings`, unique, `npc` source, within grade W limits: `10.6–35.3 W`).
- All 3 sets preserve exact names, Hán-Việt tags, 2-piece modifiers, and 3-piece rules.

---

## §G — Stand-in Replacements (`16 -> 0`)
- `demonic.cast.json` (`3`):
  - `ham_tan_chung`: `dia_kim` L9 -> `copper-mountain-bell-canon` L9
  - `sao_an_lan`: `huyen_am` L9 -> `night-moth-karst-canon` L9
  - `khoai_thiet_ung`: `dia_kim` L9 -> `black-wind-blood-sabre` L9 (deduped from `aux`, keeping `debt-ledger-blade` L6)
- `demonic.2.cast.json` (`13`):
  - `ngu_mong_te` (`hoang_am` L6) -> `shade-orchid-breath` L6
  - `sung_ngoc_khe` (`hoang_am` L6) -> `shade-orchid-breath` L3
  - `khoai_hong_ngac` (`huyen_kim` L7) -> `black-wind-blood-sabre` L7
  - `biet_tri_phan` (`huyen_thuy` L8) -> `still-moon-tide-scripture` L8
  - `duong_kho_chi` (`huyen_moc` L9) -> `verdant-cycle-scripture` L9
  - `mat_thu_ninh` (`huyen_thuy` L5) -> `still-moon-tide-scripture` L5
  - `ngao_tam_phu` (`huyen_thuy` L4) -> `still-moon-tide-scripture` L4
  - `chi_da_hanh` (`hoang_am` L3) -> `shade-orchid-breath` L3
  - `an_tieu_mac` (`hoang_am` L4) -> `shade-orchid-breath` L4
  - `tien_hoi_nhi` (`hoang_moc` L4) -> `verdant-cycle-scripture` L4
  - `cu_tieu_lang` (`hoang_thuy` L3) -> `still-moon-tide-scripture` L3
  - `viet_da_nhi` (`hoang_hoa` L3) -> `red-sun-scripture` L3
  - `xa_tieu_sa` (`hoang_thuy` L2) -> `still-moon-tide-scripture` L2

---

## §H — Open Items
1. **Engine Darkness element & curse-immunity**: `borrowed-sleep` and `night-moth-ink` use `"element": ""` until a Darkness element stack effect is ruled; `Sealed in His Name` models lower-realm unbreakability as `+100%` duration until cleanse immunity by realm exists; `His Sister's Water` uses a `qi_drained` immediate counter-restore proxy until `drain_immune` exists; `Nine Wicks` uses static `reserve: 0.09` + engine 1-per-fight `refuse_down`.
2. **`Fed in Blood`**: Seasonal out-of-fight upkeep on `dm-sons-lamp` (`not_run`).
3. **Art slot overflows in `demonic.2.cast.json`**: `duong_kho_chi` carries `6+` arts across 3 techniques (`move-the-sickness` overflows slot 6, verified in Probe P2); `cao_sa_lang`'s `pay-in-blood` has a high activation threshold at `--gap 1` (`fires 3.0` at `--gap 0`).

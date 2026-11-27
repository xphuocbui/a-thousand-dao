# Stage 6: Chức Hà Các (`chuc_ha`, progress file)

Method: `production/plans/world-depth-implementation.md` Stage 6 and `production/plans/stage6/_brief-record.md`.
**Decisions are auto-accepted** (user rule 2026-11-26) and logged with reasons in `production/plans/stage6/chuc_ha-review.md`.

## Scope (`python -I tools/design/world/depth_gap.py --sect chuc_ha`)
- **3 proposal techniques**: `mulberry-leaf-breath` (Yellow main, `moc` + `hoa`), `unbroken-thread-canon` (Profound main, `moc`), `fire-in-the-thread` (Profound secret, `hoa`).
- **7 new arts**: `spin-a-strand`, `warm-shed`, `reel-in`, `warp-and-weft`, passive art `When the Thread Breaks` (`d37`, layer 3 `technique-effects`), `burning-thread`, `fire-silk-weave`.
- **3 items, 1 set, 4 Effects**:
  - `chc-red-cloud-shuttle` (`The Thread Catches`)
  - `chc-first-weave-robe` (`Chars in a Season` — out-of-fight seasonal craft/decay rule)
  - `chc-season-woven-robe`
  - Set `chc-unbroken-thread` (`Fire Runs the Thread`)
  - Plus technique passive art `When the Thread Breaks` (`d37`)
- **3 stand-ins**: `nhiem_thanh_lam` (`huyen_thuy` 8), `mac_lam_y` (`hoang_thuy` 4), `nguu_thai_diep` (`hoang_tho` 4).
- **0 beasts**, **3 structured events** (`N-chuc_ha-01`..`-03`).
- `spatial_words_check.py`: 4 hits in `chuc_ha` (`banner` in `ties.note` and `build.note`), 0 hits in rule fields.

## Mechanic table (Step 1)
| Record | Mechanic | Engine Status | Notes |
|---|---|---|---|
| `spin-a-strand` | Light Wood hit + brief slow | Covered (`c_art`, `debuff`, `slowed_time`) | Tagged `["wood", "thread", "quick"]` |
| `warm-shed` | Small heal over time on holder | Covered (`pulse` + `heal`, `buff`) | 4 pulses HoT |
| `reel-in` | Thread bind (`thread_t1`/`t2`), `slowed_time`, next art +0.3 s; 2nd bind -> `off_guard` 1 s | Covered (`timer`, `status`, counters) | Explicit pulse counters avoid `decay_per_pulse` trap |
| `warp-and-weft` | Field stance (`field_up`), blows lose force (`dampen_taken`), Wood stacks per pulse | Covered (`states`, `tags: ["field"]`, `pulse`) | 4 pulses duration, 7 s cd |
| `When the Thread Breaks` (`d37`) | Foe `heavy`/`slow` art snaps thread -> -4% max linh lực; unbroken end ties `thread_knot` (+1 Wood on `thread` arts, +2 Burn on `burning-thread`) | Covered (`technique-effects`, `was_hit`/`evaded` `tags`, `gain_qi`, `art_fired`) | Typical enemy lacks `heavy`/`slow` tags -> verified in targeted probe |
| `burning-thread` | Fire damage + stacks, stronger while foe is bound by a thread | Covered (`empower` on `thread_t1`/`t2`) | Fires standalone and stronger with `reel-in` |
| `fire-silk-weave` | Out-of-combat fire-silk ward craft | Covered as combat Fire ward (`resist` + `ward_grow`) | Keeps seasonal craft lore in `rule` |
| `The Thread Catches` | 2 threads bound at once -> 2 Fire stacks + short burn | Covered (`art_fired` on `thread_t1 >= 1` & `thread_t2 >= 1`) | Declares `thread_t1`, `thread_t2` |
| `Chars in a Season` | Seasonal robe reweaving & modifier decay | Out of fight (`not_run`) | Logged in review & `.done` |
| `Fire Runs the Thread` | While bound, Wood stacks burn as Fire; on bind end, +1 Fire batch per 3 Wood stacks | Covered (`pulse` `free_hit`, `thread_ended`/`thread_snapped` `stacks`) | Declares `thread_t1`, `thread_t2`, `thread_ended`, `thread_snapped` |

## Stand-ins (Step 5)
| Person | Root | Was | Now |
|---|---|---|---|
| `nhiem_thanh_lam` | Water 62, Wood 40 | `huyen_thuy` 8 | `indigo-vat-canon` 8 (`chuc_ha` guest method) |
| `mac_lam_y` | Water 42, Wood 26 | `hoang_thuy` 4 | `vat-stirring-breath` 4 (`chuc_ha` vat-stirrer method) |
| `nguu_thai_diep` | Earth 46, Water 30 | `hoang_tho` 4 | `mulberry-row-breath` 4 (`chuc_ha` servant method) |

## Steps
- [x] 1. Verify first (mechanic table, `spatial_words_check`).
- [x] 2. Techniques and arts (staged: 6 techniques, 10 arts).
- [x] 3. Effects (staged: 4 Effects in `chuc_ha.effects.json`, standalone counter/state check ok).
- [x] 4. Items and sets (staged: 3 items, 1 set).
- [x] 5. Stand-ins (`chuc_ha.cast.json`, `chuc_ha.5.cast.json`, `chuc_ha.techniques.json`).
- [x] 6. Beasts (0 in `chuc_ha`).
- [x] 7. Holder check (`lint_*` 0 findings, `depth_check` findings: none, `depth_gap` `stand_ins 0` / `lines 12/12 runs`, `sect_fight` 0 `REFUSED` & 0 `NEVER_FIRED` at `--gap 0` and `--gap 1`, `suite_check` 12 runs ok, `heavy_foe` probe ok).
- [x] 8. Review file (`production/plans/stage6/chuc_ha-review.md`, `REVIEW DONE`).
- [x] 9. Finish (`RECORD PASS DONE`, `production/plans/stage6/chuc_ha.done`).

RECORD PASS DONE

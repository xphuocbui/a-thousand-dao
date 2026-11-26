# Stage 6: Băng Tâm Các (progress file)

Method: `production/plans/world-depth-implementation.md` Stage 6, "the per-sect method" (user-approved 2026-11-26).
Resume here: read this file, then do the first unchecked step.

## User rulings for this sect (2026-11-26)
- Commit after every unit, own paths only.
- Stand-ins as proposed (table below). hang_minh_sa's method (Dạ Quang's `red-sand-sabre-primer`) is promoted early
  with this sect, per the method's step 4, so Băng Tâm's gap reaches zero.
- Review format: `production/plans/stage6/bang_tam-review.md`, each rule beside its engine form.

## Scope (gap report 2026-11-26, `python -I tools/design/world/depth_gap.py --sect bang_tam`)
- 4 techniques: clear-frost-breath (Yellow main, outer), jade-vessel-ice-heart-canon (Earth main),
  snow-plum-sword (Profound secret), frost-lotus-array-canon (Earth secret). Existing in the lineage: winter-toll-canon,
  stilled-hour-sutra.
- 9 new arts (no ids yet).
- 23 items, 9 sets, 11 Effects (2 item, 9 set).
- 2 beasts (ngoc_dieu, han_tich; owner lam_tuyet_dieu), 5 events (structured).
- 1 person over the tie cap: on_sa_ngoc (export trims, Stage 7).
- 5 cross-owner references to clear-frost-breath (hermits-sages, loose-north, tam_kiem): these close when it is
  promoted.
- Authored wish records to take as written: d18 `frost-answers-the-blow` (auth-eff-1.json, Heart in the Jade Vessel);
  the a1 rewordings (Ice in the Vessel, The Peak Does Not Move, Sitting on the Ice). e9 `black-ice-method` (for
  cung_mac_suong) is held until her story turns (WIRED.md); it is not in this pass.

## Stand-ins (ruled)
| Person | Root | Pick |
|---|---|---|
| trac_on_tuyen | Water, Wood | clear-frost-breath, layer 1 (lineage) |
| giai_tieu_hoa | Fire, Earth | red-sun-scripture (Dương Lô's method, the note) |
| dao_han_mac | Earth, Fire | new Băng Tâm Yellow servants' method (Earth, Wood, Fire) |
| ma_thao_nhi | Earth, Wood | the same new method |
| quy_to_nga | Wood, Water | the same new method ("a Wood breath of her own in the washing steam") |
| hang_minh_sa | Fire, Metal | red-sand-sabre-primer (Dạ Quang outer method, promoted early) |

## Steps
- [ ] 1. Verify first: the mechanic table (exists / needs a word / needs a ruling), spatial_words_check.
- [ ] 2. Checkers up front: lint_techniques, lint_arts, suite_check, lint_items (known broken), exporters' --check,
      sets export in export_named.py.
- [ ] 3a. Techniques and arts (+ the servants' method, red-sand-sabre-primer).
- [ ] 3b. Effects (11) into combat_effects.json.
- [ ] 3c. Items (23) and sets (9).
- [ ] 4. Stand-ins and beasts (owner's `beasts` field).
- [ ] 5. Engine words, both engines, parity.
- [ ] 6. Review file, then STOP for the user.
- [ ] 7. Stage 7 (after approval).

## Notes from the first read (2026-11-26)
Mechanics that look like they need an engine word or a ruling (to confirm in step 1):
- a frost ward that grows each second, and its peak (Heart in the Jade Vessel, Ice in the Vessel, The Peak Does Not
  Move);
- reflecting a soul or heart-demon art as Cold damage (Clear-Heart Mirror art, Clear-Heart Reflection); the mod key
  `reflect_first` exists, so check it;
- a freeze status ("freezes them for a breath": Rime Lotus, Plum Falls on Snow); no `freeze` in STATUS;
- formation strength regained, "cannot be broken", and "while your diagram is laid" (Walk the Nodes, The Peak Does Not
  Move); `diagram_always` is not built;
- "your curses count as Ice debuffs for your stack effect" (Hidden Half), the reverse of `counted_curse_per`;
- heart-demon odds at a breakthrough (Ice in the Vessel), outside the fight;
- possibly spatial: "walks into them", "stands inside the seal", "a Field", "afterimage".
Existing words that cover parts: `stop_clock`, `wounded`/`broken` events, `composed`/`composed_time`, `ward_absorbed`,
`shield_broken`, `off_guard`, `sure_crit`, `bypass`, `states` with `suppress` and `tags`.

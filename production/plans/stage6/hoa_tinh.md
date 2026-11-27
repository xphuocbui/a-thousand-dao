# Họa Tinh Đường (`hoa_tinh`): Stage 6 progress file

Method: `production/plans/world-depth-implementation.md` Stage 6, "the per-sect method" + `production/plans/stage6/_brief-record.md` (headless job, decisions auto-accepted).

## Scope (`python -I tools/design/world/depth_gap.py --sect hoa_tinh`)
- **3 proposal techniques:** `ink-grinding-breath` (Yellow main, Wood/Water, 6 layers), `painted-dipper-canon` (Profound main, Wood, 9 layers, `d22`), `rainfast-ink-art` (Profound secret, Water/Wood, 9 layers, `d35`). Kept, not taught: `thorn-and-ink-verses` (already committed in `design/techniques/catalogue-soul-song-seal.json`).
- **5 new arts** (4 active arts in `arts/part-sect-hoa_tinh.json` + 1 passive art `Rainfast Ink` as technique Effect on `rainfast-ink-art`): `wet-ink`, `seven-star-talisman`, `handle-points`, `the-rain-does-not-take-it`, plus passive `Rainfast Ink`.
- **3 items, 1 set:** `ht-silver-candle` (`treasure`, `dang`, grade 4 / rarity 5), `ht-dipper-talisman-seal` (`artifact`, `an`, grade 3), `ht-rainfast-ink-gourd` (`artifact`, `ho_lo`, grade 3); set `ht-lamp-ink-brush` (2 pieces).
- **3 Effects:** `Rainfast Ink` (`rainfast-ink-art` L1 passive, `d35`), `Autumn Light on the Screen` (`ht-silver-candle`), `Seven Stars in One Stroke` (`ht-lamp-ink-brush` 2pc).
- **0 stand-ins, 0 beasts, 0 cross-owner references, 3 events** (`N-hoa_tinh-01..03`, Stage 7).

## Steps
- [x] 1. Verify first: mechanic table & `spatial_words_check.py --sect hoa_tinh` (0 non-soft hits; 1 soft hit `"behind it"` in `ky_ngan_chuc` tree intent).
- [x] 2. Techniques and arts (staged in `design/stage6-staging/hoa_tinh/`; art ids inserted into `design/world/depth/sects/hoa_tinh.techniques.json`).
- [x] 3. Effects (staged in `design/stage6-staging/hoa_tinh/effects/hoa_tinh.effects.json`; all shared counters declared on every Effect and art).
- [x] 4. Items and sets (staged in `design/stage6-staging/hoa_tinh/items/`).
- [x] 5. Stand-ins: none (`0`).
- [x] 6. Beasts: none (`0`).
- [x] 7. Holder check: lints (`0` findings across `lint_arts`, `lint_techniques`, `lint_items`), `depth_check.py --quiet` (`findings: none`), `spatial_words_check.py --sect hoa_tinh` (`0` non-soft hits), standalone Effect `engine.validate` (`3/3 VALID`, `missing_counters=[]`), and `sect_fight.py hoa_tinh` (`--gap 0`, `--gap 1`, + cleanser-art probe).
- [x] 8. Review file (`production/plans/stage6/hoa_tinh-review.md`).
- [x] 9. Finish (`RECORD PASS DONE` + `production/plans/stage6/hoa_tinh.done`).

RECORD PASS DONE

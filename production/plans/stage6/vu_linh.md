# Stage 6: Vũ Linh Đường (`vu_linh`) progress

Method: `production/plans/stage6/_brief-record.md` (auto-accepted decisions, `OWNER = vu_linh`).

## Scope (`depth_gap.py --sect vu_linh`, baseline)
- 4 techniques: `charcoal-burners-primer` (Yellow main), `canopy-bell-canon` (Profound main), `molten-bronze-litany` (Profound secret), `listening-bell-seal` (Earth secret).
- 8 new arts in depth: 6 active (`bank-the-kiln-stance`, `hang-a-bell`, `the-line-rings`, `pour-molten-bronze`, `hard-as-a-bell`, `it-rings-for-you`) + 2 passive (`Heard Through the Roots`, `Tuned Bronze`, promoted as `technique-effects`).
- 4 items (`vl-clear-bell`, `vl-root-line-banner`, `vl-last-blue-lamp`, `vl-casters-apron`), 1 set (`vl-bell-lines`).
- 3 item/set Effects (`Clear Note`, `The Forest Hears`, `The Line Is Tuned`) + 2 passive-art technique Effects (`Heard Through the Roots`, `Tuned Bronze`).
- 0 stand-ins, 0 beasts, 0 cross-owner refs, 3 structured events.

## Steps
- [x] 1. Verify first: mechanic table complete (`bank-the-kiln` renamed `bank-the-kiln-stance` to avoid `phan_vu` collision; `canopy_bell` counter avoids `minh_loan` `bell` collision; `cast_ward_duration_pct` noted as unconsumed in `CHARACTER_MODS`).
- [x] 2. Techniques and arts (staged in `design/stage6-staging/vu_linh/techniques/` and `arts/`, ids added in `design/world/depth/sects/vu_linh.techniques.json`).
- [x] 3. Effects (5 staged in `design/stage6-staging/vu_linh/effects/vu_linh.effects.json`).
- [x] 4. Items and sets (4 items and 1 set staged in `design/stage6-staging/vu_linh/items/`).
- [x] 5. Stand-ins (`0` needed; verified `stand_ins: 0`).
- [x] 6. Beasts (`0` needed; verified `beasts: 0`).
- [x] 7. Holder check (`lint_arts`, `lint_techniques`, `lint_items` all 0 findings; `depth_check.py --quiet` `findings: none`; `depth_gap.py --sect vu_linh` clean; `sect_fight.py vu_linh --seeds 5 --gap 0` & `--gap 1` + 20-seed `an_thanh_linh` + soul+charm & kiln probes all 0 `REFUSED`).
- [x] 8. Review file (`production/plans/stage6/vu_linh-review.md` written, ending with `REVIEW DONE`).
- [x] 9. Finish (`vu_linh.done` written).

RECORD PASS DONE

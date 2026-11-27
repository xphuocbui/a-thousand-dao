# Stage 6 Record Pass — `vu_an` (Vụ Ẩn Môn)

Owner: `vu_an` (Batch `b04`)
Staged path: `design/stage6-staging/vu_an/`

## Progress
- [x] 1. Verify first (`depth_gap.py`, `spatial_words_check.py`, `combat_effects.json`, `deep-lake-stance` & escape/field precedents)
- [x] 2. Stage techniques and arts + insert `"id"` on 4 new active arts in `vu_an.techniques.json`
- [x] 3. Stage items and sets
- [x] 4. Stage Effects (`vu_an.effects.json`)
- [x] 5. Stand-ins & cross-owner check (0 stand-ins; `haze-walk` committed under `thuy_vi`)
- [x] 6. Beasts check (0 beasts)
- [x] 7. Run linters, standalone compile check, `depth_check.py`, `depth_gap.py`, and `sect_fight.py` (with targeted conditional Effect probes)
- [x] 8. Auto-accept design decisions against rules and update notes
- [x] 9. Write `vu_an-review.md` and `vu_an.done`

## Mechanic Inventory
| Kind | ID / Name | Role / Tier | Source | Target |
|---|---|---|---|---|
| Technique | `road-mist-primer` | Tier 0 `main` (`moc, thuy`) | `vu_an.techniques.json` | `techniques/catalogue-sect-vu_an.json` |
| Technique | `mist-lock-array-canon` | Tier 1 `main` (`moc, thuy`) | `vu_an.techniques.json` | `techniques/catalogue-sect-vu_an.json` |
| Technique | `hidden-gate-array` | Tier 1 `secret` (`moc`) | `vu_an.techniques.json` | `techniques/catalogue-sect-vu_an.json` |
| Technique (ref) | `haze-walk` | Tier 1 `secret` (`moc`) | committed `thuy_vi` | reused by id, not duplicated |
| Active Art | `a-breath-of-road-mist` | `utility` (`wood`, `mist`) | `road-mist-primer` L1 | `arts/part-sect-vu_an.json` |
| Active Art | `lock-the-road` | `utility` (`wood`, `mist`, `field`) | `mist-lock-array-canon` L1 | `arts/part-sect-vu_an.json` |
| Active Art | `lantern-stone` | `utility` (`wood`, `lantern`, `mist`) | `mist-lock-array-canon` L2 | `arts/part-sect-vu_an.json` |
| Active Art (ref) | `deep-lake-stance` | `utility` (`water`, `stance`, `form`) | `family-water.json` | `mist-lock-array-canon` L4 (already runs) |
| Active Art | `the-gate-is-not-there` | `utility` (`wood`, `mist`, `movement`) | `hidden-gate-array` L1 | `arts/part-sect-vu_an.json` |
| Passive Art Effect | `The Wind Lifts the Mist` (`d49`) | `passive_art` (L1) | `road-mist-primer` & `mist-lock-array-canon` | `effects/vu_an.effects.json` |
| Passive Art Effect | `Lost on the Road` (`d2`) | `passive_art` (L5) | `mist-lock-array-canon` | `effects/vu_an.effects.json` |
| Item | `va-mist-lock-lantern` | `treasure` (`dang`, grade 3 / rarity 4) | `vu_an.items.json` (`bang_yen_toa`) | `items/catalogue-sect-vu_an.json` |
| Item | `va-bobtail-axe` | `artifact` (`phu`, grade 3, R6 exception) | `vu_an.items.json` (`trieu_ngu_lang`) | `items/catalogue-sect-vu_an.json` |
| Item | `va-milestone-flag` | `artifact` (`ky`, grade 2) | `vu_an.items.json` (`bang_yen_toa`) | `items/catalogue-sect-vu_an.json` |
| Set | `va-road-mist` | 2-piece set | `vu_an.items.json` (`bang_yen_toa`) | `items/sets-vu_an.json` |
| Item Effect | `The Mist Does Not Ask` | item effect | `va-mist-lock-lantern` | `effects/vu_an.effects.json` |
| Item Effect | `Out of the Mist` | item effect | `va-bobtail-axe` | `effects/vu_an.effects.json` |
| Set Effect | `Nobody Looked` | 2pc set effect | `va-road-mist` | `effects/vu_an.effects.json` |

## Validation Snapshot
- `lint_techniques.py`: `checked 3 techniques, 0 findings` (`7.9 W / 8`, `13.0 W / 16`, `14.6 W / 16`).
- `lint_arts.py`: `checked 4 arts in 1 files, 0 findings`.
- `lint_items.py`: `checked 3 items, 22 bases, 9 common arts, 0 findings`.
- `depth_check.py --sect vu_an`: `findings: none`.
- `spatial_words_check.py --sect vu_an`: `0` hits in rule fields (`2` non-rule hits in `ties.note`).
- Standalone `engine.validate`: all `5` Effects in `vu_an.effects.json` compiled cleanly with explicit counter declarations, no multi-`mod` clobber, and no named `states`.
- `sect_fight.py vu_an --seeds 5` (`--gap 0` and `--gap 1`): all `17` living holders ran (`0 REFUSED`), every active art fired across both `--gap 0` and `--gap 1`. Targeted probes verified `The Wind Lifts the Mist` vs Wind arts, `Lost on the Road` evade/decoy/escape triggers, `Out of the Mist` post-mist empowerment, and `The Mist Does Not Ask` / `Nobody Looked` coexistence with `deep-lake-stance`.

RECORD PASS DONE

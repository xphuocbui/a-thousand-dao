# Power Rankings: measurements (2026-11-14)

Observations behind the Power Rankings revision of 2026-11-14 (`design/gdd/power-rankings.md` Formulas, Open
Questions 1, 2, 3, 5). The user's decisions from these numbers are in the GDD; this note only records what was measured.

## 1. How sharp fights are (`fight.py`, reference fighters, 400 fights a row)

The realm's typical fighter with health (`n_body`) × f against the unscaled typical fighter:

| Health × | Realm 0 share | Realm 2 share | Elo gap (realm 0 / 2) |
|---|---|---|---|
| 1.02 | 0.521 | 0.550 | +15 / +35 |
| 1.05 | 0.568 | 0.596 | +47 / +67 |
| 1.10 | 0.637 | 0.695 | +98 / +142 |
| 1.20 | 0.779 | 0.839 | +217 / +284 |
| 1.50 | 0.969 | 0.976 | +584 / +629 |
| 2.00 | 1.000 | 1.000 | saturated |

About 3,000 Elo per tenfold of health (`health_elo`). Every pairing of reference fighters across or within a realm
(typical r+1 against typical r, top-end r against typical r and against typical r+1) was 20 of 20 for the stronger.

## 2. Realm step and top-end on the same ruler (`fight.py`, bisection, 40 fights a probe)

| Fighter | Equals typical of the realm below × health |
|---|---|
| Typical Trúc Cơ, Kết Đan, Nguyên Anh | ×28.7, ×28.8, ×29.0 |
| Typical Hóa Thần | ×24.3 |
| Top-end, every realm | beyond ×256 of its own realm's typical (off the ruler) |

So a realm is about ×29 in typical-health terms, about 4,400 Elo; the old fixed panel's realm-beside members and
top-end member could only ever give 1-0 results.

## 3. Generated NPCs on the ruler (Godot probe, seed 101, 5,000-NPC world at year 0, 40 NPCs a realm, 12 fights a probe)

The health factor f at which the realm's typical fighter breaks even with the NPC:

| Realm | n | Share vs typical p10 / p50 / p90 | f p10 / p25 / p50 / p75 / p90 | min / max |
|---|---|---|---|---|
| Luyện Khí | 40 | 0.00 / 0.00 / 0.63 | 0.11 / 0.17 / 0.26 / 0.41 / 1.04 | 0.06 / 1.3 |
| Trúc Cơ | 40 | 0.00 / 0.54 / 1.00 | 0.21 / 0.33 / 0.99 / 3.30 / 4.87 | 0.11 / 11.2 |
| Kết Đan | 40 | 0.54 / 1.00 / 1.00 | 1.11 / 3.35 / 8.47 / 12.1 / 17.3 | 0.17 / 63.5 (probe cap 64) |
| Nguyên Anh | 30 | 1.00 / 1.00 / 1.00 | 3.14 / 4.35 / 7.94 / 13.4 / 28.2 | 0.11 / 63.5 (probe cap 64) |
| Hóa Thần | 2 | 1.00 | 14.5 / 26.8 | |

Within a realm, p10 to p90 spans ×10 to ×23 (about 3,000 Elo). Realms overlap only at the tails (Kết Đan p90 ×17 is
below Nguyên Anh typical, ×29). Input for the NPC substance and difficulty-target work: "typical" sits at about the
Luyện Khí p90 and below the Kết Đan p10.

## 4. Build changes a season (Godot probe, same world, 10 years, every living NPC's compiled build file hashed)

| Year | % of NPCs changed a season | Breakthroughs | Stage changes | Other |
|---|---|---|---|---|
| 1 | 6.4 | 12 | 309 | 0 |
| 5 | 3.8 | 8 | 183 | 0 |
| 10 | 2.3 | 12 | 101 | 0 |
| Mean | 3.85 (about 190) | 10.5 | 182.2 | 0 |

The world tick gives NPCs no new techniques or items yet ("other" is 0); re-measure when it does. The population
stayed at 5,000 with no new ids in the 10 years.

## 5. Cost

Godot: 13.7 ms a fight over the 18,240 probe fights (inflated by fights against heavily scaled fighters); the world
tick itself was about 4.2 s a season including the build hashing. `fight.py`: 0.3 ms a reference fight.

Scripts (scratch, not kept): a `fight.py` slope and realm-gap bisection, and a Godot `SceneTree` probe using
`FighterCompiler.compile`, `FighterCompiler.from_data` and `CombatService.resolve`.

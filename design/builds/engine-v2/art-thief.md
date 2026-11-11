# The Hollow Thief (Hư Thủ Thâu Pháp), rebuilt from the library

Leave the foe's strength to your own echoes: a hollow tide of linh lực-burning palms, re-fired by echo arts on your own multiplier (the foe-art theft itself has no library piece).

Fight files: `builds/art-thief.fight.json` (Nguyên Anh, defining realm), `builds/art-thief.ket-dan.fight.json` (Kết Đan). Kept unchanged from the old files: layers, crit, ward, body, root (`purity` water 60, metal 50), art speed and cost, regeneration, leech. The old build had no effects, counters, states or keystones, so none were removed.

## Pieces

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Hollow Hall Sutra (main technique) | Hollow Tide Scripture | `hollow-tide-scripture` (main, thuy) |
| Hollow Palm (2.6 hit) | Marrow-Siphon Palm | hollow-tide-scripture (1) |
| Hollow Palm, heavy follow-up | Hollowing Strike | hollow-tide-scripture (4) |
| Borrowed Hand: a copy fires back on your multiplier | Answering Palm (every third palm re-fires your last art at 60 %) | hundred-echo-palm-scripture (1), body |
| Loan-slot copies 2 and 3 | Twin Shadow Fist (a shadow double) | hundred-echo-palm-scripture (2) |
| Spent Hand / copies fired again | Phantom Sword (re-fires the last art on a crit with 3 Afterimages) | afterimage-sword-canon (2), kim secret |
| Still Pool Mending (heal) | none carried; Hollow Husk Stance fills the sixth slot | hollow-tide-scripture (2) |

Nguyên Anh runs all six arts. Kết Đan runs five (drops Hollow Husk Stance, the sixth slot).

## Techniques chosen and why

- **Hollow Tide Scripture** (Earth main, thuy): the nearest thing to the Hollow Hall Sutra. Its Qi Disruption steals the foe's linh lực and returns half of it, the closest library gesture to taking from the foe. Water purity 60 covers it.
- **Hundred Echo Palm Scripture** (Profound body, always usable): the echo engine. Marrow-Siphon Palm and Hollowing Strike are palms, so they feed Answering Palm's third-palm echo, which is the nearest to "your last art fires again".
- **Afterimage Sword Canon** (Earth secret, kim): metal purity 50 usable; Phantom Sword is a second last-art re-fire, on crits.

## Lost in the move

- Borrowed Hand, the loan slots, the `stolen` tag, Borrowed Weight, Pilfered Craft, Full Hand, Faithful Copy, Warm Hand, Own Medicine, Stolen Breath, Spent Hand, Pre-Read, Hollow Guard, Wide Sleeve: the identity (copying the foe's arts) has no library art or suite. It is now only approximated by own-art echoes; the build no longer scales with how many arts the foe throws.
- Still Pool Mending: no heal sits in the chosen suites, and a common heal could not be added without dropping a catalogue technique.
- The old stolen-tag `x` points (+100 L2, +60 L5 on copies) are gone; no overrides allowed.

## Matchups (Nguyên Anh file, `--matrix`)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical, nguyen_anh+0 | 2.6 | 20-0-0 | never | 2.0 | none |
| typical, hoa_than+1 | 3.0 | 20-0-0 | never | 3.0 | L1 1.0 |
| top_end, nguyen_anh+0 | 5.0 | 12-8-0 | never | 3.0 | L1 2.1, shadow-quicken 0.1 |
| top_end, hoa_than+1 | 4.5 | 0-20-0 | 4.1 | 4.0 | L1 0.1 |

Kết Đan file, typical, one run without --matrix: 2.9 s, 20 wins, you dry never, foe dry 2.5.

## Without tests (same-realm typical, nguyen_anh+0)

| Test | Mean s | W-L-other | You dry | Foe dry |
|---|---|---|---|---|
| before (full build) | 2.6 | 20-0-0 | never | 2.0 |
| `--without tech:hollow-tide-scripture` | 2.6 | 20-0-0 | never | 2.0 |
| `--without answering-palm` (identity piece) | 2.6 | 20-0-0 | never | 2.0 |

No change at the same-realm typical foe: the fight ends before any of the arts fire. The tests move only in other rows: top_end nguyen_anh+0 without the main technique 4.8 s and 11-9 (was 5.0 s, 12-8); typical hoa_than+1 without answering-palm 3.1 s (was 3.0 s). (A third run, `--without tech:hundred-echo-palm-scripture`, was also made: typical nguyen_anh+0 unchanged, top_end nguyen_anh+0 5.0 s and 9-11.)

## UNMODELLED

- THEFT ITSELF (loan slots, the `stolen` tag, copying the foe's arts, half-cost half-cooldown copies, Pre-Read, Hollow Guard, Spent Hand): no library art copies a foe's art and the engine has no event for it.
- A bare-fist enemy gives nothing to copy: not run, since the matrix enemy always has arts.
- technique hollow-tide-scripture passive status_duration_pct +12: no engine stat.
- technique hollow-tide-scripture passive art_cost_pct (scope force): the engine reads cost_red without hit context, so it applies to every art.
- technique hundred-echo-palm-scripture passives art_speed_pct and art_cost_pct (scope physical): same, applied to every art.
- technique afterimage-sword-canon passive status_duration_pct +15: no engine stat.

## Observations

At the same realm (Nguyên Anh, typical foe) the fight lasts 2.6 s, far under the 30-60 s band; the top_end foe takes 5.0 s, also well under. The old guide said about 3 s, and that still holds, but for a different reason: the build wins before its echoes can start. At the typical Nguyên Anh foe the only art that fires is Hollow Husk Stance (1.0 a fight); Marrow-Siphon Palm, Hollowing Strike, Answering Palm, Twin Shadow Fist and Phantom Sword are all NEVER_FIRED there. Twin Shadow Fist is NEVER_FIRED in every row; the stance fires in every row, so its 35 % extra linh lực cost is paid with nothing gained. Against top_end Nguyên Anh the build wins 12-8 and fires the echo arts once each. The guide's claims about copying the foe's arts, Borrowed Weight and Full Hand cannot be tested at all here, and the claim that it beats a top-end foe in 9 s did not hold (5.0 s, a coin flip, and a loss at hoa_than+1). Because the same-realm typical fight ends before the engine starts, both --without tests show nothing there, so they say nothing about whether the echo engine or the main technique earn their slots. These are observations from one 20-fight matrix each, not a verdict.

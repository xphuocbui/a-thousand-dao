# Mirror Hide (Kính Bì), engine v2 rebuild

A Thổ-Kim (Earth-Metal) block tank that stands behind stacked body layers and lets every blow come back at the enemy as a reprisal.

## Old pieces to library pieces

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Packed Earth Stance / Packed Earth Hide (stance that takes the blow) | `mountain-stance` | mountain-heart-canon (1) |
| Needle Mark (Metal debuff stacks) | `sinking-weight` (Earth stacks on the foe, slow) | mountain-heart-canon (2) |
| Return channel, burst on a stopped blow (Open the Mirror / Thorn Chorus) | `bastion-reprisal` (body shield breaks into a free Physical hit) | mountain-heart-canon (4) |
| Open the Mirror (the big answer) | `strata-hammer` | mountain-heart-canon (6) |
| Mirror-Skin hardening (Hide Hardens, resist) | `iron-hide-stance` | iron-hide-manual (3) |
| Mending Breath / Offering Cut / `mirror-return` approximation | none | none |

The Nguyên Anh file carries the same five arts. Thorn Chorus (the old sixth art) has no counterpart, and the sixth slot stays empty.

## Techniques chosen and why

- **Mountain Heart Canon (Sơn Tâm Kinh), main, tho.** It is the whole defence-into-offence suite. Mountain Stance answers each hit you take, Sinking Weight lays Earth stacks and slows the foe, Bastion Reprisal turns a broken body shield into a free Physical hit, and Strata Hammer spends the Strata that hits taken lay on you. This is the closest library engine to "the more you stop, the more you return". The Earth purity of 70 makes it usable.
- **Iron Hide Manual (Thiết Bì Quyết), secret, kim.** The Metal purity of 70 makes it usable. It adds Iron Hide stance (+120 resistance, +35 block; the index line is cut off after "each hit you take" and I did not read the rest), and its passives add block rating and Physical resistance, which the old guide's body layers already wanted.
- I left out Mountain Bone Body Art (Sơn Cốt Thể Thuật, body). Its arts would make seven against five slots at Kết Đan (Core Formation). I did not try it for passives alone, and I did not test whether a technique with no slotted art still applies its passives.

## Lost in the move

- The Return channel (Phản) at 30 % of every incoming hit, with the 2.0 U per-hit cap, has no library equivalent. Mountain Stance and Bastion Reprisal are the nearest answers, and they fire on events rather than on the size of each hit.
- Needle Mark's Metal debuff (1.8 % more Physical taken per stack) became Sinking Weight's Earth stacks and slow.
- Mending Breath (a heal on a timer) and Offering Cut (self-hit) have no stand-in.
- Held Reflection, Self-Wound Counts, Boil Returned and Bait stay as the guide's Effects, but none is run (see UNMODELLED).
- Thorn Chorus, the sixth art of the Nguyên Anh guide, is gone.

## Results (Kết Đan file, `--matrix`, 20 fights per row)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical ket_dan+0 | 3.0 | 20-0-0 | never | 3.0 | none |
| typical nguyen_anh+1 | 5.3 | 20-0-0 | never | 5.0 | mountain-take 1.0, trig_budget 1.0 |
| typical hoa_than+2 | 10.7 | 20-0-0 | never | 8.2 | mountain-take 3.0, trig_budget 1.4 |
| top_end ket_dan+0 | 46.0 | 20-0-0 | never | 43.5 | iron-hide-temper 3.8, mountain-take 6.8 |
| top_end nguyen_anh+1 | 14.1 | 0-20-0 | never | never | iron-hide-temper 0.8, mountain-take 2.5 |
| top_end hoa_than+2 | 2.1 | 0-20-0 | never | never | mountain-take 0.1 |

Nguyên Anh file, no matrix: typical nguyen_anh+0 took 4.0 s, 20-0-0, you dry never, foe dry 3.0, trig_budget clipped 1.0 per fight.

## `--without` tests (typical, same realm, Kết Đan)

| Test | Before | After |
|---|---|---|
| `--without tech:mountain-heart-canon` | 3.0 s, 20-0 | 3.0 s, 20-0 (NO_CHANGE) |
| `--without mountain-stance` (identity piece) | 3.0 s, 20-0 | 3.0 s, 20-0 (NO_CHANGE) |

At the top-end Kết Đan row the technique test went from 46.0 s to 46.2 s, and the art test from 46.0 s to 46.7 s, both still 20-0. At nguyen_anh+1 against top_end the art test went from 14.1 s to 10.2 s, and at hoa_than+2 against typical from 10.7 s to 11.7 s.

## UNMODELLED

- Return channel (Phản): a free Physical hit per incoming hit at 30 % with a 2.0 U cap. The engine has no event that scales a free hit by the size of the hit taken or by what was stopped, so the old `mirror-return` approximation is gone and the library answers stand in.
- Mirror-Scale Hide enabler, Held Reflection bank, Self-Wound Counts, Boil Returned, Bait curse: none can be written as Effects on the current events (no bank of clipped return, no health-paid-as-hit-taken, no curse on enemy basic cooldown).
- Technique passive `body_shield_pct +8` of mountain-heart-canon: no engine stat.
- Technique passives `stack_effect_pct +10 [tho]` and `stack_duration_pct +15 [tho]` of mountain-heart-canon: no engine stat.
- Technique passive `stack_duration_pct +4 [kim]` of iron-hide-manual: no engine stat.

## Observations

A typical same-realm fight at Kết Đan lasted 3.0 s and the foe ran dry in all 20, well under the 30-60 s band. The old guide's 1.7 s figure held in spirit: the build still ends a typical fight in seconds. Against top_end at the same realm it lasted 46.0 s, inside the band and a win in all 20, which matches the guide's 41 s. The guide's claim that the build is a defence-tank that wins by outlasting holds against the same-realm top end, but at one realm up (nguyen_anh+1) it lost 0-20 in 14.1 s, so "stay at your realm" holds and the unlisted case, a higher realm, is much worse than the guide says. Neither `--without` test moved the typical same-realm fight at all, because all five arts fired 0.0 times per fight in it: the fight ends in 3 s before any art is ready, so the matchup tells us nothing about the technique. The technique and the art only show at longer fights. NEVER_FIRED: all five arts at typical ket_dan+0; bastion-reprisal and strata-hammer at typical nguyen_anh+1; sinking-weight, bastion-reprisal, strata-hammer and iron-hide-stance at top_end hoa_than+2; and in the Nguyên Anh file at typical nguyen_anh+0, everything except mountain-stance (sinking-weight, bastion-reprisal, strata-hammer, iron-hide-stance). Many passives could not be modelled, so the numbers understate the technique.

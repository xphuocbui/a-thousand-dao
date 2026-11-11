# The Brimming Tide (Mãn Triều), rebuilt on the library

A Water cultivator who keeps the linh lực pool full and is paid for it, now carried by the whole Still Moon Tide suite.

## Pieces

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Reading the Tide Canon (Độc Triều Kinh), tier 2 | Still Moon Tide Scripture (Tĩnh Nguyệt Triều Kinh), main | itself (passives) |
| Brimming Cup (Mãn Bôi Quyết), Effect, L5 | `brimming-cup` (art) | still-moon-tide-scripture (4) |
| Gathering Tide (Gathering Tide, Water stacks) | `gathering-wave` | still-moon-tide-scripture (2) |
| Drawing Breath (Hấp Triều), refill and Water stacks | `deep-lake-stance` (closest: the pool and regeneration engine; the old art was a plain common art with no signature) | still-moon-tide-scripture (1) |
| Tide Pulse (Triều Xung), workhorse | `swelling-tide-palm` (closest Water damage art of the suite) | still-moon-tide-scripture (6) |
| Deep Well Seal (Thâm Tỉnh Ấn), heavy hit | none; the palm takes the heavy-hit job | none |
| Kết Đan only: nothing | `backwash-seal` (a returning-wake-verse art, fifth slot) | returning-wake-verse (1) |

Kept as they were: realm, `purity` water 60, L1 and gear/formation layers (L1 60 / 105, L3 20, L4 20), crit, `n_body`, `n_qi`, art speed 5 %, art cost 12 %, regeneration bonus, the drain ward (ws 40, we 55, layers 50/40/30/20). Zeroed because they only stood in for the old Canon and Cup: L2 40 (Canon passive) and L5 16 (the flat Brimming Cup proxy).

## Techniques chosen and why

- **Still Moon Tide Scripture (main, Earth tier, thuy, 12 layers).** A whole suite: its four arts (layers 1, 2, 4, 6) all fit the four Foundation slots, it is Water, and its engine (Tide counter, healing and Water stacks, linh lực spill, body shield) is exactly what the build already feeds: regeneration, healing and a full pool. It contains Brimming Cup under the same name, the build's identity piece.
- **Returning Wake Verse (secret, thuy), Kết Đan only.** Foundation has four slots, so the suite fills them and no auxiliary art fits; Kết Đan has five, and `backwash-seal` (every third Water art repeats at half power and returns 2 % linh lực) fits a pool build. Undertow Litany was the alternative but its arts (layers 1, 3, 5) cost health or are curse-flavoured.
- No generated common technique: the suite already carries Drawing Breath's job.

## Lost in the move

- Deep Well Seal (the 6 s heavy hit): no library Water seal; the suite's palm replaces it.
- Tide Pulse and Drawing Breath as plain arts: the common arts exist (`tide-pulse`, `drawing-breath`) but need a generated common technique and a slot; the main suite was preferred.
- The Reading the Tide Canon passive, about +40 L2 on Water arts: the library technique has no damage-more passive; its passives are art speed, healing, health regeneration, stack duration, linh lực regeneration.
- The old flat Brimming Cup (+16 L5) is now the real art, which restores 10 % linh lực and a shield and spills overflow as a hit, not a pool-reading damage bonus. The "+2 % more per 10 % pool" reading is lost.
- Spill Shield, Still Water, Depth Is Shield, Full Sea: staged Effects not in the old fight file, still not in this one.
- At Foundation the auxiliary slot is empty; at Kết Đan Gathering Tide's old role is carried by `gathering-wave`.

## Fight results (20 seeds each, same realm = typical truc_co+0)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical, same realm (truc_co+0) | 30.7 | 20-0-0 | never | 18.1 | tide-from-healing 1.1, trig_budget 19.9 per fight |
| typical, +1 realm | 13.9 | 0-20-0 | 10.4 | never | tide-from-healing 12.6 |
| typical, +2 realms | 4.0 | 0-20-0 | 4.0 | never | tide-from-healing 3.0 |
| top_end, same realm | 2.0 | 0-20-0 | 2.0 | never | none |
| top_end, +1 | 1.0 | 0-20-0 | 1.0 | never | none |
| top_end, +2 | 1.0 | 0-20-0 | 1.0 | never | none |
| Kết Đan file, typical same realm (ket_dan+0, five arts) | 19.1 | 20-0-0 | never | 13.3 | tide-from-healing 2.0, trig_budget 10.8 |

### `--without` tests (typical, same realm, before -> after)

- `--without tech:still-moon-tide-scripture` (the main technique's passives): 30.7 s -> 33.6 s, wins 20 -> 20, foe dry 18.1 -> 19.8 s. Changed. One step up the realm ladder: 13.9 -> 13.2 s, no wins either way.
- `--without brimming-cup` (the identity art): 30.7 s -> 39.1 s, wins 20 -> 20, foe dry 18.1 -> 23.7 s, health left 100 % both. Changed. Against +1 realm 13.9 -> 11.9 s.

## UNMODELLED

- Full-Sea ward bonus (ward drain falls while the pool is above 80 %): not an engine Effect; the ward uses fixed ws_base and we.
- The Tide-Bound Vessel and the Still Pool Array: not pieces in the engine, folded into layers and ward numbers.
- Technique still-moon-tide-scripture passive art_speed_pct scoped to thuy: the engine reads art speed without hit context, so it applies to every art.
- Technique still-moon-tide-scripture health_regen_inc_pct +18 and stack_duration_pct +10: the engine has no such stat, so they do not run.
- (Kết Đan file) returning-wake-verse art_speed_pct scoped to thuy: same reason as above.

## Observations

At the same realm the Foundation fight lasts 30.7 s, at the bottom of the 30-60 s band, and the Kết Đan fight (five arts) lasts 19.1 s, below it. In both the player never runs dry and keeps 100 % health, while the foe runs dry at 18.1 s and 13.3 s. This matches the guide's "win by outlasting, never dry" claim and its roughly 31 s Foundation figure. The guide's Kết Đan figure of about 26 s no longer holds (19.1 s). Brimming Cup as a real art lengthens the fight when removed (39.1 s without it), so it is worth about 8 s at Foundation, and the main technique's passives are worth about 3 s. The guide's claim that a foe one realm up beats it still holds: the foe won all 20 fights at +1 realm (13.9 s here against the guide's 11.5 s at Foundation) and at +2, and every top_end foe wins within 1-2 s, as the guide says for a top-end burst opener. The 19.9 trig_budget clips per fight at Foundation say the suite's free hits (spill, waves) hit the trigger budget; some of the suite's payoff is thrown away. NEVER_FIRED arts: `gathering-wave` and `brimming-cup` against a typical +2-realm foe, and all four arts against every top_end foe (the fight ends before the first cooldown).

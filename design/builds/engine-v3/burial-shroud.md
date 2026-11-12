# The Burial Shroud (Liệm Y Đạo), geared: a ket_dan ward-stripper that burns the foe's linh lực with Qi Disruption and stacks curses on the dying

Realm: Core Formation (ket_dan). Input: `design/builds/engine-v3/builds/burial-shroud.fight.json` (old: `design/builds/engine-v2/builds/burial-shroud.fight.json`).

## Loadout

Limit for the extra slots: 45 × divine_sense 1.0 × (1 + 10 / 100) = 49.5 thần thức (than_thuc_pct 10 comes from the Hollow Robe +6 and the Branding Iron +4; even without it the 45 holds).

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Balance-Sheet Seal (Kết Toán Ấn, `force-chaos-ledger-seal`) | 3 | Its art Settle the Account counts as a Ruin Ledger Scripture art and cashes the Fray the build stacks; replaces Gathered Ruin Verdict in the art slots. Chaos attack and curse speed modifiers. |
| Armour | Hollow Robe (Không Y, `force-chaos-hollow-robe`) | 2 | Light Force-cover robe with Chaos resistance. Its ward (Force 264, drain 0.317) does not beat the build's Common Ward at ws 150 (payload 342.5 base), so no ward was swapped. |
| Ring | Hollow Ring (Không Giới, `force-chaos-hollow-ring`) | 1 | Debuff stack strength, Chaos attack, status duration (curse build). |
| Ring | Wayfarer's Ring (Hành Lữ Giới, `general-wayfarer-ring`) | 1 | Filler: a little health and fortune; the catalogue has no better free ring for this build (Hollow Ring family has one ring at grade 1 and Open-Vein Ring wants a bloodletting build). |
| Necklace | Ledger-Murmur Pendant (Phế Thanh Bội, `force-chaos-ledger-murmur-pendant`) | 2 | Debuff stack strength, Chaos attack, regen; its reserve art lengthens statuses (reserve not run). |
| Extra 1 | Ledger Branding Iron (Phế Trướng Lạc Thiết, `force-chaos-ledger-branding-iron`) | 2 | Carries the Effect Marked Prey (L5 +4 per distinct status on the foe), the one item Effect the build runs. TT 15. |
| Extra 2 | Shock-Wave Zither (Chấn Ba Cầm, `force-chaos-shock-zither`) | 1 | Force attack and speed modifiers. Its art Resonant Shockwave (a fourth Hollow Tide art) was **not** slotted: all five art slots are full. TT 25. |
| Total extras | 15 + 25 = **40** thần thức | | against a limit of 49.5 |

## Before and after

Old = the engine-v2 file run today; geared = the engine-v3 file. Wins-losses-other, 20 fights each.

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical ket_dan+0 | 9.3 | 8.5 | 20-0-0 | 20-0-0 |
| typical nguyen_anh+1 | 20.8 | 16.3 | 20-0-0 | 20-0-0 |
| typical hoa_than+2 | 15.8 | 14.8 | 0-20-0 | 0-20-0 |
| top_end ket_dan+0 | 4.0 | 4.0 | 0-20-0 | 0-20-0 |
| top_end nguyen_anh+1 | 2.0 | 2.0 | 0-20-0 | 0-20-0 |
| top_end hoa_than+2 | 1.6 | 1.6 | 0-20-0 | 0-20-0 |

Health left on wins: 97 % → 97 % (same realm), 66 % → 72 % (one realm up). (The old file's numbers differ from the engine-v2 guide, 7.6 s and 14.1 s, because the engine and library changed since that guide was written.)

`--without` (typical, same realm; the other matchups were not shown by these runs):

| Test | Mean s | Wins | Foe dry |
|---|---|---|---|
| geared (reference) | 8.5 | 20 | 7.1 s |
| `--without item:force-chaos-ledger-seal` (its modifiers only; its art stays slotted) | 8.7 | 20 | 7.3 s |
| `--without eff:Marked Prey` | 8.7 | 20 | 7.8 s |

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | Chaos attack %, curse art speed % | Harder Settle the Account and faster curses | event, craft, quest, npc | In the catalogue (grade 3 Seal; no grade 4 Ruin Ledger weapon) | Medium |
| Extra | Primordial Mirror (`force-chaos-primordial-mirror`, unique, TT 18, Unmaking Glass) | Unknown for this build, not read; unique piece of the Chaos family | holder at world start | In the catalogue | Low |
| Extra | Marked Prey on a second item | The cap is +16 L5; one source already reaches it at 4 statuses | — | In the catalogue | Low |
| Ring | Open-Vein Ring (Blood Drinker) | A health-sustain Effect, not tested here | event, craft | In the catalogue | Low |
| Necklace or ring | Linh lực burn / reserve-free sustain | Own linh lực never runs dry in these fights, so low | — | Missing | Low |
| Any | Tick-scoped layers (Grave Rot, Rot Deepens) | The build's lost identity | — | Missing (no permanent no-duration tick Effect) | High |

## Missing pieces

- A permanent no-duration tick source (Grave Rot's role) and the Spillover clip-to-burn rule: the Chaos family (Hollow/Ruin Ledger items) should own them.
- A ring or necklace that raises Qi Disruption strength or the foe's linh lực drain: the Force-chaos family.
- A grade 4 Ruin Ledger weapon (the Seal is grade 3): Force-chaos family.
- A body-guard or pierce modifier piece (the old build's body guard 40 and pierce 30): Body family.

## UNMODELLED

- Grave Rot permanent tick: no field for a no-duration status.
- Reservation of 25 % of linh lực: no reservation field; also the Murmuring Debts reserve (10 %), not deducted and its grants not run.
- `pierce_pct` 30: no field.
- Body guard 40: the typical body is used.
- Spillover: no clip-to-burn rule; Qi Disruption stands in.
- Bare Vessel: no conditional layer on a foe's linh lực pool.
- Rot Deepens and Corpse-Wax Coating: tick-scoped layers with no tick to scope to.
- Cleansing and the post-fight vitality cost: caller rules.
- Ward shape: Common Ward at ws 150, we 150; the Hollow Veil does not beat it so was not swapped.
- Technique passives with no engine stat or scope (status_duration_pct, hollow-tide and ruin-ledger cost and speed scopes) as in the old guide.
- Item modifiers with no engine stat (not run): `stack_effect_pct` (Seal, Hollow Ring, Pendant), `status_duration_pct` (Seal, Hollow Ring, Iron), `khi_huyet_pct` (Seal, Robe, Wayfarer, Zither), `than_thuc_pct`, `defense_pct`, `status_resist_pct`, `khi_van`, `cultivation_speed_pct`.
- Item art-speed scopes (Seal, Iron, Zither) apply to every art because the engine reads speed without hit context.
- Item Effect Marked Prey: modelled as "eff:Marked Prey", reading `foe.distinct_statuses` (the catalogue reads the statuses of yours on the target; the engine's readable is the closest).

## Observations

Gear mattered a little: the same-realm fight went from 9.3 s to 8.5 s and the one-realm-up win from 20.8 s to 16.3 s (health left 66 % to 72 %), but no matchup changed outcome: it still wins at ket_dan and nguyen_anh+1 and loses at hoa_than+2 and against every top-end foe, which end in 1.6–4.0 s. Fights are still well under the 30-60 s band (8.5 s and 16.3 s); only the two-realms-up loss lasts near 15 s. Nothing made the build degenerate. Removing the Seal's modifiers or Marked Prey costs only 0.2 s (Marked Prey does move foe-dry from 7.1 to 7.8 s). The `--without item:` test only removes an item's modifiers, so the Seal's real contribution (the art Settle the Account, fired 1.8 times a fight at same realm) is not isolated; in exchange Gathered Ruin Verdict is no longer in the build. Fired nothing: Hollowing Strike and Settle the Account against top_end ket_dan+0, and all five arts against top_end nguyen_anh+1 and hoa_than+2 (the fight ends before they come ready). Most item modifiers (stack strength, status duration, health) hit engine stats that do not exist, so the geared numbers understate the items.

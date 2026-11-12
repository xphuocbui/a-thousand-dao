# The Hollow Thief (Hư Thủ Thâu Pháp), geared

Leave the foe's strength to your own echoes: a hollow tide of linh lực-burning palms, re-fired by echo arts on your own multiplier, now with a Hollow-Tide zither and two Echo treasures. Realm: Nguyên Anh (nguyen_anh).

Fight file: `builds/art-thief.fight.json`. A copy of the engine-v2 file with `"items"`, one art swapped (Twin Shadow Fist → Resonant Shockwave) and one engine Effect (`eff:Echo`). No number was tuned; the ward stays the build's own (payload 342.5 beats the robe's Hollow Veil at 264).

## Loadout

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Shock-Wave Zither (Chấn Ba Cầm) `force-chaos-shock-zither` | 1 | Its art Resonant Shockwave counts as a Hollow Tide Scripture art and feeds Drink; slotted in place of Twin Shadow Fist, which never fired |
| Armour | Hollow Robe (Không Y) `force-chaos-hollow-robe` | 2 | Force-family armour; +6 % thần thức widens the extra budget; its ward is weaker than the build's, so not used |
| Ring | Echoing Ring (Hồi Âm Giới) `soul-song-seal-echoing-ring` | 3 | Carries Echo, the free-hit Effect the echo engine wants |
| Ring | Hollow Ring (Không Giới) `force-chaos-hollow-ring` | 1 | Debuff stack strength and status duration for Qi Disruption (no engine stat reads either) |
| Necklace | Ledger-Murmur Pendant (Phế Thanh Bội) `force-chaos-ledger-murmur-pendant` | 2 | Debuff stacks, healing, linh lực regeneration; reserve art not run |
| Extra | Echo-Skin Drum (Hưởng Bì Cổ) `body-echo-skin-drum` | 3 | Physical art speed, crit and crit damage for the palms; its Echo is not stacked with the ring's. TT 20 |
| Extra | Twin-Edge Flying Sword (Song Nhận Phi Kiếm) `blade-twin-edge-sword` | 2 | Sword crit, speed and attack for the Afterimage Sword Canon's Phantom Sword. TT 20 |

Thần thức: 20 + 20 = **40** against a limit of 45 × 1.0 × (1 + 10 / 100) = 49.5 (the build's own divine_sense is absent; robe +6 % and ring +4 % than_thuc counted; 45 if neither counts, still above 40). Two extra slots left empty.

## Before and after

Twenty fights each, one `--matrix` run per file.

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| typical, nguyen_anh+0 | 3.0 | 2.8 | 20-0-0 | 20-0-0 |
| typical, hoa_than+1 | 3.7 | 4.8 | 20-0-0 | 20-0-0 |
| top_end, nguyen_anh+0 | 8.9 | 11.2 | 19-1-0 | 20-0-0 |
| top_end, hoa_than+1 | 4.7 | 4.5 | 0-20-0 | 0-20-0 |

(The engine-v2 guide recorded 2.6 / 3.0 / 5.0 / 4.5 s; the engine reruns today read as shown above, and the old column uses today's rerun.)

`--without` tests (geared file, `--matrix`):

| Test | typical n+0 | typical h+1 | top_end n+0 | top_end h+1 |
|---|---|---|---|---|
| geared, full | 2.8 s, 20-0-0 | 4.8 s, 20-0-0 | 11.2 s, 20-0-0 | 4.5 s, 0-20-0 |
| `--without item:force-chaos-shock-zither` (the weapon, the item that matters most by its art) | 2.8 s, 20-0-0 | 4.8 s, 20-0-0 | 11.2 s, 20-0-0 | 4.5 s, 0-20-0 |
| `--without eff:Echo` | 2.8 s, 20-0-0 | 4.8 s, 20-0-0 | 10.0 s, 19-1-0 | 4.5 s, 0-20-0 |

The zither test removes only the item's modifiers (a small Force attack, art speed and health), because the swapped-in art stays; it changed nothing. The Echo test is the one that moved: top_end Nguyên Anh +0 went from 11.2 s and 20-0 to 10.0 s and 19-1.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | Art that copies the foe's last art | The build's identity: theft | Force-chaos family | Missing | High |
| Ring | Echo, second copy that stacks (or a stronger Echo) | More free hits per art | Item, event or craft | Catalogue has Echo on 5 items; stacking not defined | High |
| Necklace | Force `attack_pct` scoped to force | Scales the scripture's burn and palms | Force-chaos family | Missing (the pendant carries Chaos) | Medium |
| Armour | Ward above 342.5 payload with linh lực regeneration | Keeps the sustain while the echoes run | Force-chaos or body | Missing (the robe's ward is weaker) | Medium |
| Extra | Palm-scoped art speed or Drink | Fires Marrow-Siphon Palm and Hollowing Strike, which never fired in the typical fight | Body family | Missing | Medium |
| Any | Mod-engine stat for status_duration_pct and stack_effect_pct | Lets three owned pieces count | Engine | Not an item | Low |

## Missing pieces

- A foe-art-copying weapon or ring (steal and fire the foe's last art at 60 %): force-chaos.
- A Force-scoped necklace or ring with `attack_pct`, not only Chaos: force-chaos.
- A palm-scoped treasure that adds Drink or counts toward Answering Palm's third palm: body.
- A heavier armour whose ward beats a Common Ward at ws 62.5: force-chaos.

## UNMODELLED

- THEFT ITSELF (loan slots, `stolen` tag, copying the foe's arts, Pre-Read, Hollow Guard, Spent Hand): no library art or item copies a foe's art and the engine has no event for it.
- A bare-fist enemy gives nothing to copy: not run, since the matrix enemy always has arts.
- Echo (Echoing Ring, Echo-Skin Drum): written once as `eff:Echo`; the engine's free hit cannot carry the art's tags, and a second Echo from the other item is not stacked, since the rules do not say whether it would be.
- Opening Cut (Twin-Edge Flying Sword): not relied on, not written.
- Hollow Veil ward (Hollow Robe): weaker than the build's ward, so the old ward stays.
- Reserve art Murmuring Debts (Ledger-Murmur Pendant): the 10 % reserve is not deducted and the grants do not run.
- Item passives with no engine stat: `khi_huyet_pct`, `than_thuc_pct`, `defense_pct`, `status_resist_pct`, `status_duration_pct`, `stack_effect_pct` (debuff), `linh_luc_on_crit_pct`; the scoped `art_speed_pct` (force, soul, physical, sword) apply to every art, as the engine cannot scope them.
- Technique passives as in the engine-v2 guide (status_duration_pct, scoped cost and speed).

## Observations

Gear changed the result only a little. The typical Nguyên Anh foe still dies in 2.8 s, about as fast as before and far below the 30-60 s band; the top-end foe takes 11.2 s and was won 20-0 against 19-1 before; against the Hóa Thần top-end foe the build still loses every fight (4.5 s). The fights stay well under 30 s, so the band is not reached by this gear. No item made the build degenerate: the clearest effect was the Echo Effect: with it the top_end fight runs 1.2 s longer (11.2 s against 10.0 s) and one more fight is won (20-0 against 19-1), so it reads as survival, not speed. The geared build is also slower than the old one at typical hoa_than+1 (4.8 s against 3.7 s) with the same wins; the cause was not isolated. The zither's art fires every row where the fight lasts (1.0 a fight at typical, 1.9 at top_end), but removing the zither's modifiers changed nothing, and its Drink count did not show up in any result. Fired nothing: Marrow-Siphon Palm and Hollowing Strike are NEVER_FIRED in the typical Nguyên Anh fight (the fight ends first; in the old file Marrow-Siphon Palm fired 0.0–1.4 a fight depending on the row), and Twin Shadow Fist is gone. The Echo-Skin Drum, Twin-Edge Sword, Hollow Ring and the pendant have only modifiers the engine mostly cannot read, so their effect here is close to nothing; the sword's art and Opening Cut were not slotted. These are observations from one 20-fight matrix each, not a verdict.

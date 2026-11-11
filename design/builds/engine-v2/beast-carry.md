# beast-carry — Raising the Tiger (Dưỡng Hổ): a linh thú (spirit beast) does all the killing while you feed, heal and ward it.

**Read this first.** There were no old `beast-carry*.fight.json` files (the Glob found none anywhere under design/builds; the guide says no simulator was used). So I could not copy the old layers, crit, ward or body. I wrote `layers` from the guide's multipliers (L1 x3.66 -> 332 raw points, L2 300, L3 250, L4 110, L5 89), crit 0, art speed +100 and no `ward`/`body` (the realm default). Only one file exists, for nguyen_anh; there was no other realm file to rebuild. The numbers below describe this reconstruction, not the old build.

## Piece map

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Feed the Fire (Fire buff stacks) | `warm-the-hearth` (closest Fire buff-stack art) | generated common art, not in `techniques` |
| Old-Tree Sap (heal) | `second-spring` | verdant-cycle-scripture (4) |
| Hearth Song, Whistle In, Bark Mantle, Rouse, Moss Fang Bite, Fang and Claw (technique passive) | none | lost |
| Scripture passives (health/linh lực/damage, healing) | passives only | verdant-cycle-scripture, ashen-phoenix-canon |

## Techniques chosen and why

- Main `verdant-cycle-scripture` (Wood, usable: wood purity 60). A heal engine suite (Spring counts heals), the closest to a "heal and keep the beast up" method. Its other arts hit the enemy (seed-of-spring, harvest-bloom) or slow arts 20 % (rooted-form), so I took only `second-spring` (layer 4).
- Auxiliary `ashen-phoenix-canon` (Fire secret, usable: fire purity 80), taken for passives only: healing +10 %, stack_effect +10 %, leech. Its arts all hit, so none are slotted.
- No body technique: every body art in the catalogue hits.
- Fire buff stacks: `warm-the-hearth` as a one-art generated common technique.

## What was lost

- Straining Leash (the identity, L5 from share above cap), Shared-Heart Contract (beast with its own health bar, Down, Rouse), Bonded Spirit feeding the beast's timers, Sure Bite, Roused, Pack Hunt, Marked Prey, Rain on Both: no library art, and the engine has no companion share, companion health or companion hit filter. I modelled only the beast as a companion hitting c 1.0 every 0.5 s.
- Fire stacks at scale: Feed the Fire (12 stacks for 2 %) became one 3-stack art that also hits, which breaks the Contract's "no art that hits" rule (not enforced by the engine).
- Bark Mantle, Rouse, Hearth Song, Whistle In: no equivalent (Water/Ice/Earth wards are outside the root).

## Matchups (nguyen_anh file, `--matrix`)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical nguyen_anh+0 | 1.0 | 20-0-0 | never | 1.0 | not reported |
| typical hoa_than+1 | 2.0 | 20-0-0 | never | 2.0 | not reported |
| top_end nguyen_anh+0 | 1.4 | 0-20-0 | 1.0 | never | not reported |
| top_end hoa_than+1 | 1.0 | 0-20-0 | 1.0 | never | not reported |

## --without tests (typical, same realm)

- `--without tech:verdant-cycle-scripture`: 1.0 s -> 1.0 s, 20 wins -> 20 wins (no change in any matchup; its engine stat passives printed UNMODELLED).
- `--without warm-the-hearth` (the identity art; Straining Leash itself is not modelled): NO_CHANGE, 1.0 s -> 1.0 s, 20 -> 20 wins.

## UNMODELLED

- Shared-Heart Contract: beast in the open (health bar, 30 % redirect, Down, Rouse) is not an engine concept.
- Straining Leash: needs a companion share readable the engine lacks.
- Bonded Spirit / Lent Hand: only the 0.5 s companion timer is written, art speed does not feed it.
- Sure Bite, Roused, Pack Hunt, Marked Prey, Rain on Both: no companion hit filter.
- verdant-cycle-scripture passives stack_effect +8, stack_duration +10, health_regen +8: no engine stat. Its art_speed +4 [moc] applies to every art (no hit context).
- ashen-phoenix-canon passives stack_effect +10 and status_duration +10 [curse]: no engine stat.

## Observations

Fights are 1.0 s (typical) and 2.0 s (hoa_than+1), far under the 30-60 s band, and the top_end foe wins in 1.0-1.4 s: nothing in these runs is a fight, because the companion alone one-shots a typical foe at my reconstructed layers while the default body and ward do not hold a top-end foe. Both arts are NEVER_FIRED in every matchup (the fight ends before their first timer), which is also why both `--without` tests are NO_CHANGE. The guide's claims (four bites a second, Fire stacks holding, the tiger kept standing by heals, a 30-60 s fight) cannot be confirmed or refuted here; the engine ran only the companion, with no Contract, Leash or beast health. These results are not usable for balance, and they depend on layers I inferred from the guide, since the old file was missing.

LIB-DONE design/builds/engine-v2/beast-carry.md

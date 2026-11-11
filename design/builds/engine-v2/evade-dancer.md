# Drifting Wind Dancer (Phiêu Phong Vũ Giả), library rebuild

A Wind cultivator at the evade cap whose dodged hits feed two Wind techniques that count, hold and replay them.

Defining realm Nguyên Anh (nguyen_anh), root `purity` wind 80, layers, crit, ward, body and evade 40 kept from the old file. Files: `builds/evade-dancer.fight.json` (nguyen_anh), `builds/evade-dancer.ket-dan.fight.json` (ket_dan).

## Pieces

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Reed-Cutting Breeze (Tước Phong Nhận) | Hundred-Feather Flurry (closest: many light hits fed by basics and evades) | gale-courier-scripture (2) |
| Hollow Step (Hư Bộ) | Three-Step Chase (named replacement in the library) | gale-courier-scripture (4) |
| Falling Leaf (Diệu Lạc) | Held Breath (each evade banks a Breath, spent by the next art) | gale-courier-scripture (6) |
| Scatter Gale (Tán Phong) | Trailing Gale (Slowed Time, evades delay the foe; closest, not the evade-cleanse) | slow-hour-scripture (1) |
| Gale Crown (Cuồng Phong Quán) | Echo of the Dodge (evade and crit counts replay the last art); Reckless Gale, the listed replacement, was not slotted | slow-hour-scripture (4) |
| (none, a sixth slot at Nguyên Anh) | Gale Sprite | slow-hour-scripture (2) |
| Evade Pays, Reply, Carried Off, Surplus Breeze (Effects, Đạo) | kept as they were: not modelled, listed in `unmodelled` as before | none |

Kết Đan file: the same without Three-Step Chase (5 slots at ket_dan; six arts would give `slots_over`). All layers used are at most 6, inside the layer-9 limit.

## Techniques chosen and why

- **Gale Courier Scripture (Phong Sứ Kinh), main, phong.** Its arts read evade (Feathers and Breath fill from evades) and its gates take "3 courier arts in one pulse", which Three-Step Chase's charges give. It also carries evade +5 and basic speed +10.
- **Slow Hour Scripture (Trì Thời Kinh), secret, phong.** Trailing Gale lays the Slowed Time that the Flurry step 3, the Held Breath empower and the Echo empower all take as a gate, and Echo counts evades, so the dancer's evade is the fuel for both suites. It also carries evade +4.
- Not slotted: Swallow Stance (arts 25 % slower, against the build's art-speed layers; it is a gate key for the same arts, so this is a choice that could be revisited) and Reckless Gale (pays health; the build's ward and body layers are built to keep health high).
- No body technique: evade is the defence and the old build had none.

## Lost in the move

- **Scatter Gale's evade-cleanse of own stacks** (Scattering Breeze, 2 batches per 6 s): no library equivalent; Trailing Gale is control, not cleanse. Carried Off (Effect) is still unmodelled, so the build has no modelled answer to ticks.
- **Hollow Step's `qi_restore`**: gone with the invented art; the linh lực pay from evades is only the +2 pp regen already in the file.
- **Wind stack from each art** (old buff stacks on every art): the library arts bring few Wind stacks, so the "ten Wind stacks, arts pinned at 0.5 s" signature moment and Wind-Fed Edge's stacks are weaker or absent.
- **Gale Crown's big payload** (4.6 coefficient, 3 stacks): replaced by Echo's replay at 25 % per Echo.
- Hollow Step ↔ Three-Step Chase and Gale Crown ↔ Reckless Gale are listed by the library as replacements; here Gale Crown became Echo of the Dodge instead (recorded).

## Fights (nguyen_anh file, 20 runs each, `--matrix`)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical, same realm | 1.7 | 20-0-0 | never | 0.9 | none |
| typical, one realm higher | 2.1 | 20-0-0 | never | 2.0 | sprite-dance 0.1, trig_budget 0.2 |
| top end, same realm | 9.2 | 20-0-0 | never | 8.5 | echo-crit 0.3, feather-evade 0.1, gale-drag 0.1, sprite-dance 0.8, trig_budget 0.8 |
| top end, one realm higher | 5.1 | 0-20-0 | 4.9 | never | echo-crit 0.2, feather-evade 0.1, gale-drag 0.1, sprite-dance 0.5 |
| ket_dan file, typical, same realm | 4.9 | 20-0-0 | never | 4.5 | echo-crit 0.1, feather-evade 0.2, gale-drag 0.2, sprite-dance 0.8, trig_budget 0.1 |

(The matrix labels the higher realm hoa_than+1.)

## `--without` tests (nguyen_anh, typical same realm unless noted)

| Test | Before | After |
|---|---|---|
| `--without tech:gale-courier-scripture` (main technique) | 1.7 s, 20-0 | 1.8 s, 20-0 (identity: changed) |
| same, top end same realm | 9.2 s, 20-0 | 9.0 s, 18-2 |
| `--without echo-of-the-dodge` (identity piece) | 1.7 s, 20-0 | 1.7 s, 20-0 (identity: NO_CHANGE) |
| same, typical one realm higher | 2.1 s | 2.6 s, 20-0 |
| same, top end same realm | 9.2 s, 20-0 | 10.1 s, 13-7 |

I also ran `--without tech:slow-hour-scripture`: typical same realm no change (1.7 s), top end same realm 9.2 s 20-0 to 9.2 s 19-1.

## UNMODELLED

- evaded hit pays linh lực (modelled as +2 pp regen at Nguyên Anh, +3 at Kết Đan): the engine has no way here to attach it to the unbuilt Evade Pays Effect; the old file already carried it this way.
- evaded hit adds Wind stack (Evade Pays): not modelled; library arts bring their own stacks.
- evaded hit fires riposte (Reply): trigger, not modelled, as in the old file.
- evade_cap shift keystone: no engine stat for it.
- technique gale-courier-scripture passive stack_effect_pct +8 [phong]: no engine stat (not run).
- technique gale-courier-scripture passive art_speed_pct scope [quick]: the engine reads art_speed without hit context, so it applies to every art.
- technique slow-hour-scripture passive status_duration_pct +10 [curse]: no engine stat (not run).

## Observations

At Nguyên Anh the typical same-realm fight lasts 1.7 s and the typical foe one realm higher 2.1 s, far under the 30-60 s band; the top-end same-realm foe takes 9.2 s, also under it. At Kết Đan a typical foe takes 4.9 s, which matches the guide's "5 s". In the Nguyên Anh typical fights every art shows NEVER_FIRED (the foe dies before the first art is ready), so the library arts do nothing there and the `--without` tests change nothing but noise; the top-end fights are where the arts fire (held-breath and echo 4.9, trailing-gale 3.5, three-step-chase 3.0, flurry 1.9, sprite 1.1 per fight). NEVER_FIRED arts: all six against the typical same-realm foe; against the typical foe one realm higher hundred-feather-flurry, three-step-chase, trailing-gale and gale-sprite (held-breath and echo-of-the-dodge fire once each); in the Kết Đan file none, though gale-sprite fires only 0.1 per fight. The guide's claims hold in part: a top-end same-realm foe is no longer an even fight (20-0, where the guide gave 13-6-1) and one realm higher the build still loses (0-20), matching "you lose"; the guide's "volley or two" for typical foes holds. Echo of the Dodge is the identity piece that matters: removing it moves the top-end same-realm result from 20-0 to 13-7, while removing the main technique costs 2 wins. Trigger-budget and sprite-dance clipping appear in the top-end fights (trig_budget 0.8, sprite-dance 0.8 per fight). The fight lengths are far under the band as measured; I did not tune anything.

# The Hearth Keeper (Thủ Lô Hỏa Giả) — engine v2 rebuild

A Fire caster that burns the enemy with a tempo suite of Fire arts and lets the Burn refill its linh lực (Embers Feed the Hearth, kept as the old approximation).

Fight file: `design/builds/engine-v2/builds/starter-flame.fight.json` (Kết Đan, the build's only old fight file, so no other realm file). Root, layers, crit, ward, body, purity (fire 70) and the Embers/Kindled Wound/First Move approximations are unchanged from the old file.

## Pieces

| Old piece | Library piece | Technique (layer) |
|---|---|---|
| Spark Palm (Hỏa Tinh Chưởng), 1 Burn, cd 2 | `flint-volley` (3 charges, 2 Burn each) | red-sun-scripture (2) |
| Kindling Seal (Dẫn Hỏa Ấn), 2 Burn | `heat-haze` (3 Burn + Slowed Time) | ashen-phoenix-canon (3) |
| Flame Lance (Liệt Diễm Thương), 3 Burn, heavy | `furnace-heart` (Heat counter, vent cashes Burn) | red-sun-scripture (4) |
| Warm the Hearth (Noãn Lô Quyết), Fire buff stacks | `brazier-form` (Fire stance, Burn ticks mend you) | red-sun-scripture (1) |
| (none; filler for the free slot) | `twin-flame-echo` (echo of the last art) | red-sun-scripture (6) |

Techniques: `red-sun-scripture` (main, Profound, hoa), `ashen-phoenix-canon` (secret, hoa), `scorch-fist-primer` (secret, hoa; its one art `scorch-fist` is not slotted, so only its passives count). 4 + 1 arts = the 5 Kết Đan slots.

## Why these techniques

- Red Sun Scripture is a whole suite whose engine the build already feeds: Burn on the foe is one of the unlock routes of Furnace Heart, Flint Volley and Twin Flame Echo (15, 15 and 30 Burn), and the old build puts Burn on the target from its first art. Its passives (Fire art speed, Fire damage more, cheaper Fire arts) also match the fuel plan.
- Ashen Phoenix Canon names Burn directly: `damage_more +4` and `attack_pct +8` scoped to over-time Fire, and Heat Haze carries Burn plus Slowed Time. Only Heat Haze is slotted (a second art would exceed 5 slots); its other arts were left out for lack of slots.
- Scorch Fist Primer: no slot for Scorch Fist, taken for its passives (resist pen Fire +24, stack effect +8), all within the root. Of these only the resist pen is a real stat and the engine reports it as not run; the choice is therefore close to free and untested.

## Lost in the move

- Warm the Hearth is a common art with no catalogue technique carrying it; its only piece in the new build is the Fire stance in Brazier Form, which is not the same effect (no Fire buff stacks for damage).
- Spark Palm, Kindling Seal and Flame Lance were plain cheap Burn arts (1/2/3 stacks, cooldowns 2/4/6 s). The library has no plain one in a hoa technique: `kindle-palm`, `ember-rain`, `flame-lance` exist only as common arts of a generated common technique (one each). The old art "rhythm" of cheap Burn is gone.
- The old guide's art order (Warm the Hearth first, then 2/4/6 s cycle) no longer holds; Brazier Form is a stance that slows arts 15 % and suppresses Ember Rain.
- Several technique passives print as UNMODELLED (stack effect, stack duration, curse status duration, resist pen), so part of the suites' value is not in the numbers.

## Results (`--matrix`, 20 fights each)

| Matchup | Mean s | W-L-other | You dry | Foe dry | Clipped |
|---|---|---|---|---|---|
| typical, Kết Đan (same realm) | 17.9 | 20-0-0 | never | 13.9 | brazier-warm 14.2, heat-build 2.0, brazier-thorns 1.0, trig_budget 0.5 |
| typical, Nguyên Anh (+1) | 7.7 | 0-20-0 | 5.9 | never | brazier-warm 2.5, brazier-thorns 0.1 |
| typical, Hóa Thần (+2) | 3.4 | 0-20-0 | 2.7 | never | none |
| top_end, Kết Đan | 1.6 | 0-20-0 | 1.0 | never | none |
| top_end, Nguyên Anh | 1.0 | 0-20-0 | 1.0 | never | none |
| top_end, Hóa Thần | 1.0 | 0-20-0 | 1.0 | never | none |

Health left at the same-realm typical fight: 95 %.

## --without tests (typical, Kết Đan)

| Test | Before | After |
|---|---|---|
| `--without tech:red-sun-scripture` (main technique passives) | 17.9 s, 20-0, foe dry 13.9, 95 % health | 18.8 s, 20-0, foe dry 14.2, 94 % health |
| `--without flint-volley` (identity piece: the Burn batch art) | 17.9 s, 20-0, foe dry 13.9, 95 % health | 18.8 s, 20-0, foe dry 16.2, 94 % health |

Every other matchup: no change in either test (the identity line prints NO_CHANGE).

## UNMODELLED

- Embers Feed the Hearth (25 % of each Burn tick as linh lực): approximated by `gain_on_hit_pct 0.6` and `regen_bonus_pp 3`; the real trigger is not modelled (kept from the old file).
- Embers' cost (direct Fire hits 15 % less): not applied, direct damage is overstated by up to 15 %.
- First Move and Fire art cost nodes: folded into `art_cost_pct 15`.
- Kindled Wound (L5 +15 vs Burn target): a guard the simulator cannot model, always-on L5 15, a slight overstatement.
- Xích Diễm Địa Quyết bonuses (linh lực +12 %, heart-demon resist) and the root purity are not checked beyond `purity.fire`; its L2 share is folded into layers.
- Burn ticks come from the simulator's fire debuff stacks; their linh lực return is the Embers approximation.
- red-sun-scripture: `art_speed_pct` and `art_cost_pct` scoped to Fire apply to every art (the engine reads them without hit context); `stack_effect_pct +8` and `stack_duration_pct +4` have no engine stat (not run).
- ashen-phoenix-canon: `stack_effect_pct +10` has no engine stat; `status_duration_pct +10 [curse]` is not run.
- scorch-fist-primer: `stack_effect_pct +8` has no engine stat; `resist_pen_pct +24 [fire]` is not run.

## Observations

At the same realm (typical, Kết Đan) the fight lasts 17.9 s, below the 30-60 s band (the old build was about 22 s), with 20 wins, the linh lực bar never dry and 95 % health left (old: 55 %). One realm up it loses in 7.7 s (old about 7 s); a top-end cultivator ends it in 1.6 s (old under 2 s), so the guide's claims about the lost matchups hold and the "never dry" claim holds. The guide's "a little strong, a little short" is a little stronger and shorter here, and "Embers feeds the hearth" is still only the old approximation, not tested on the new arts. The two --without tests moved the same-realm fight by only about 0.9 s each and not at all elsewhere, so neither the technique's passives nor Flint Volley shows up as the build's identity in these numbers; the fight is decided by the shared base (layers, ward, Embers approximation). Brazier Form's warm effect is clipped 14.2 times per fight at Kết Đan, and Heat Build 2.0 and the trigger budget 0.5. NEVER_FIRED: at Nguyên Anh+1 `flint-volley`; at Hóa Thần+2 `brazier-form`, `flint-volley`, `heat-haze`; at top_end all five arts at every realm (the fight ends before the first cooldown). Not run: other realm files, the old build had only a Kết Đan file.

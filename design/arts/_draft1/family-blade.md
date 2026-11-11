# Family: Blade (element-less weapon forms: sword, saber, spear, bow)

7 authored arts, `family-blade.json`, lint 0 findings (2026-11-11). Numbers are first guesses inside the art lint.

| Art | Mechanic shape | Hooks | One-line rule |
|---|---|---|---|
| Debt Blade (Huyết Trái Kiếm) | Paying with health; low-health payoff | low health, health regeneration, leech health, healing, crit | Costs 5 % health; strikes again per 10 % health missing. |
| Flurry Stance (Loạn Đao Thế) | Stance (state) with suppression | basic speed, basic coefficient, gain on hit, crit | Toggle: faster, harder basic attack that returns linh lực, but plain sword and broad saber arts are suppressed. |
| Coiling Thrust (Triền Thương Đột) | Build-up then cash-in (counter, spend) | art speed, counter gain, extra hits | Each firing adds a Coil (no cap); at 4+ it unleashes 3 extra thrusts per 4 Coils and spends them. |
| Pinning Arrow (Đinh Tiễn) | Delay and Slowed Time curse | crit, slowed time stacks, curse duration, timer delay | Lays Slowed Time, delays the foe's longest timer 1 s; a crit lays 2 more stacks. |
| Phantom Sword (Huyễn Ảnh Kiếm) | Echo and repeat (`fire_art`) | crit, crit multiplier, last art damage, echo repeats | Hits and crits leave Afterimages; at 3 a crit refires your last art at 60 %. |
| Flying Sword (Phi Kiếm) | Summon, stacking | companion speed and damage, summon count, cooldown recovery | Strikes, then a sword hits every 1.5 s for 12 s; each firing adds another. |
| Triple Draw (Tam Bạt Đao) | Charges and burst with a decaying counter (`each_for`) | charges, art speed, cooldown recovery, counter duration | 3 charges; each draw in the last 4 s adds an extra cut to the next hit. |

## Library arts replaced

All seven are new (`sources: (gap)`). They replace no library art: Plain Sword Cut, Broad Saber Sweep, Spear Thrust and Bleeding Slash (common) are kept. The authored Sundering Cut, Binding Thrust, Iron Nail and Reaping Saber in `part-a.json` are not touched (curse and cull shapes; Reaping Saber's cull stays the saber's finisher).
Flurry Stance names two commons in its `suppress` list (`plain-sword-cut`, `broad-saber-sweep`), so it trades them for basic-attack tempo.

## What the engine could not express

- **Held payload** ("your next art"): `held` exists on Effects, but a saber riposte banked from `was_evaded` and spent on the next art needs a damage payload; `held` banks mods only, so I left it out.
- **Conversion** (e.g. half the hit to Force): the art `convert` field exists but I used no art for it, so this shape stays open for another family.
- **Conditional split**: `split` is a fixed art field, so Coiling Thrust's "becomes N thrusts" is modelled as extra `free_hit`s, which use the trigger budget and cap (they cannot exceed it).
- **Free hits from arts use the trigger budget** (`trig_budget`, `trig_cap`): Debt Blade's interest and Triple Draw's snowball are clipped at high scaling. A "limitless" signature would need an `outside_budget` flag per art; the engine has one inside `free_hit` (`outside_budget`) that I did not use, pending a decision on whether signatures may bypass it.
- **Bow-specific**: no range, volley or projectile-count readable; Pinning Arrow is a curse/delay art with a bow tag only.
- **Flurry Stance suppress list** names art ids, so it only suppresses those two commons, not "all arts with a tag"; a tag-based suppress would be better.
- Unit values for state mods (`basic_speed 50`, `basic_coef 0.5`, `gain_on_hit 2`) were guessed from the mod-key list, not checked against a tuned build.

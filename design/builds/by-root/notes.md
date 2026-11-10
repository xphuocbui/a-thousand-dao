# Notes from writing the builds

What came up while writing the builds in this folder (overnight 2026-11-09/10). These are observations for the
user, not decisions.

## 1. The linh lực keystones carry almost every build

After the Combat economy revision (#44), a side whose pool runs dry loses, so nearly every build names a linh lực
engine. Most of them are the New per-element keystones (the user's decision of 2026-11-09 put them in each
element's tree). Counted across the files: The Spring Never Fails (Water) appears 27 times, Edge Returns the Breath
(Metal) and Root Drinks the Rot (Wood) 19 each, Embers Feed the Hearth (Fire) 18, The Stone Remembers (Earth) 16,
Storm Battery (Thunder) 13.

- **Priority:** these 11 keystones (`missing-pieces.md` § Linh lực keystones) are the most-needed new content.
  Without them, builds without Water have only the plain sustain modifiers and Blood Casting.
- **Water looked like the default second element** while writing; the simulator says otherwise (below). Its buff is the only stack that raises the pool, and The
  Spring Never Fails removes diminishing returns from it. Many builds "add a Water art for stacks". If that is too
  strong, give Water's keystone a heavier closing cost, or let the other keystones match its value.
- **Starting numbers from the simulator** (`tools/design/combat_sim/keystonefit.py`, 2026-11-10). Each keystone build
  uses its element's kit, pays for its stacks through the art lint (Effects Formulas D) and takes the closing cost
  named in `missing-pieces.md`. The number below is where the build wins about 15 points above an even mirror
  (24 seeds, so ±30 %):

  | Keystone | Starting number | Closing cost used | Note |
  |---|---|---|---|
  | Storm Battery (Thunder) | **1.9 %** of maximum linh lực per crit | non-crit hits −10 % | The Thunder kit with the closing cost and no keystone wins only 4 % |
  | Embers Feed the Hearth (Fire) | **15 %** of each Burn tick's damage returned as linh lực | direct Fire hits −15 % | |
  | Root Drinks the Rot (Wood) | **1.8 %** of damage to a poisoned foe returned as linh lực | none against an unpoisoned foe | Written as a flat leech, not "doubled" |
  | The Stone Remembers (Earth) | **1.1 %** of damage stopped (resistance and block) returned | evade 0 | Against Physical attackers; less against others |
  | Breath Between Blows (Wind) | **0.8 %** of maximum linh lực per art fired | no art over 6 s | |
  | Frost Tithe (Ice) | about **100 %** of the extra cost your Ice stacks add | none | Ice stacks are weak alone, so the tithe must return the whole extra |
  | Edge Returns the Breath (Metal) | barely needed | — | The Metal kit already beats the target **without** the keystone (60 %): Metal's stack weights (1.0 % / 0.8 % per stack-second) look too low together |
  | The Spring Never Fails (Water) | — | — | See below: Water kits are over-charged, and removing diminishing returns adds little (4 % → 8 %) |

- **Water's price is wrong in the other direction.** Its weight (2.2 % per stack-second, measured on 10 s batches)
  over-charges long batches, because regeneration has diminishing returns: a 15 s Water kit pays a 0.33 charge and
  wins 4 %. Charge Water's buff on a falling scale (or cap the charge for Water), and give The Spring Never Fails a
  stronger effect, such as "+0.1 pp linh lực regeneration per Water stack, not subject to diminishing returns".
- **Simulator check:** a kit that grants Water buff stacks lasting the whole fight wins 42 % against the typical
  build when it pays for them (it gives up its damage budget), and 100 % when the stacks are free. The art lint's
  stack charge (Effects Formulas D) is what keeps Water fair; an Effect or item that grants Water stacks for free
  (Effects are unpriced) would be the danger.

## 2. Paying in health is the strongest general pattern

Health is cheap after #44 (about 0.21 W per % of maximum health, modifiers.md Open Question 9), and linh lực is
life. So paying art costs in health (Blood Casting, 14 uses; `art_cost_health_pct`, 10 uses) and regenerating health
(Wood) turns a cheap pool into the precious one. Several builds (Blood on the Whetstone, the Charcoal Kiln, the
Ancient Banyan, the Iron Tree, the Ironwood Golem) are this pattern in different clothes.

- **Risk:** if every strong build pays in health, health-paid costs are underpriced. `art_cost_health_pct` is priced
  at 0.5 W per % as a guess; the simulator should price it.
- **Simulator check (2026-11-10, `tools/design/combat_sim/sim.py`):** a typical build that pays **half** its art
  costs in health (the same share of health as of linh lực) beats the typical build in **24 of 24** seeds, and
  ends the fight in 23 s instead of 36 s. Paying **all** of its costs in health loses every seed: health runs out at
  about 19 s. So the pattern is very strong in the middle and limits itself at the extreme. Blood Casting and
  `art_cost_health_pct` needed a real price: now 0.35 W per point, dampen-shaped, no cap (ruled 2026-11-10).
- **Counters, checked in the simulator:** Withering does **not** counter health-paid costs, because paying in health
  is not healing; it only hurts the builds that also regenerate or heal. Stagnation (no regeneration) beats them, but
  Stagnation beats everything (§ 7). So a build that pays half its costs in health has almost no counter today:
  **ruled 2026-11-10: no cap; the stat is now dampen-shaped ("art costs X % shifted to health": linh lực pays cost ÷ (1 + X/100)), priced 0.35 W per point.** Several builds below list Withering as their
  weakness; for the pure health-payers that is wrong.

## 3. Rules and readables the builds keep asking for

Several New pieces need the same small rule extensions. Adding these few would unlock many builds:

| Extension | Where | Builds that need it |
|---|---|---|
| A guard "target holds at least N of your debuff stacks" | Combat rule 13 (guards) | Hammer and Anvil, the Avalanche, every "cash-in" build |
| An action "consume your debuff stacks for an effect" | Effects rule 6 (actions) | the Quenched Blade, Quench |
| An action "convert your own stacks of one element to another" | Effects rule 6 | the Smelter |
| Readable: damage prevented by your block and resistance (event) | Effects rule 5 | The Stone Remembers |
| Readable: the foe's resistance by type, the foe's main element | Effects rule 5 | Cracking Root, Overcoming Answer |
| Readable: arts fired this instant | Effects rule 5 | Eruption |
| Element-tagged companions (a companion's hits carry its element and grant its stacks) | creature records | the Salamander Keeper, the Living Sword, the Bonfire Forge Army, the Artisan General |
| Formations that grant stacks each pulse | formation records | the Living Landscape, the Stone Forest Maze |
| Universal (unscoped) stack effect and stack duration modifiers | Modifier System catalogue | every multi-element build |

## 4. Multi-element technique and items are missing

Every công pháp today names one element (Canh Kim, Thanh Mộc, Huyền Thủy, Xích Diễm, Hậu Thổ) or one variant. Dual,
triple and wider roots have no technique that names their elements, so their builds borrow a single-element one.
The New Green Flame Scripture, Molten Core Canon, Boiling Sea Canon, Three Seasons Canon, Four Seasons Canon and Five
Phases Canon fill that gap. With công pháp trees planned for a separate tab (`design/research/side-trees-thoughts.md`),
these multi-element techniques are a natural place for the cycle Effects (Generating Cycle, Overcoming Answer).

Artifact kinds are also thin for some themes: an Axe, a Lantern, a Mirror, a Lightning Rod and a Five-Phase Flag
were each wanted by more than one build.

## 5. Darkness, Light and Chaos have no stacks, so they lean on their parents

By the user's rule these three have no element stacks. Their builds work through statuses (Exposed, Corpse Rot),
Chaos damage, the Down step and their parents' stacks. Each got a New linh lực keystone that reads something other
than stacks (Night Tithe, Dawn Tithe, Primordial Breath). If the user wants them to feel as full as the other
elements, a status-based engine per variant (Exposed for Light, a Chaos rot for Darkness) is the closest substitute.

## 6. Element weakness stays out of damage

Overcoming Answer (five elements) reads the foe's element. The user ruled out an element cycle in damage (Combat
Damage Types rule 2), so the build is written as an Effect, never a resistance rule. Keep it that way.

## 7. Stagnation is too strong after #44

Simulator (2026-11-10): a typical build whose hits apply Stagnation (linh lực and health regeneration stop for 3
pulses, refreshed on each hit) beats the typical build in **24 of 24** seeds, and still does at **half** its
damage. With wards paid in linh lực, regeneration is what keeps a side alive after its pool first runs low; a
curse that keeps it at 0 decides the fight. Before #44 this mattered little (8 s fights).

- **Proposals:** Stagnation halves regeneration instead of stopping it; or it gets the 2-pulse reapply lockout
  Sealed Meridian and Silence have; or only rare sources may apply it on hit. The Effects System's curse table owns
  it (Status Catalogue).
- Builds that rely on Stagnation (the Executioner, `triple-metal-water-fire.md`) are written as counters; they would
  be the strongest builds in the catalogue until this is fixed.

## 8. What was not done

- No single build was priced or simulated. Only the patterns above were: health-paid costs, Water stacks, the
  keystone numbers, Withering and Stagnation (`tools/design/combat_sim/`: `sim.py` now has keystone and curse
  hooks, `keystonefit.py` fits the keystones). The simulator has no companions, soul arts, formations, talismans or
  Effects beyond those, so most builds cannot be run yet.
- Names of the New pieces are proposals; Hán-Việt was checked by eye only.
- Đạo requirements for the Đạo named here are not in data yet (`dao.json` does not exist); the builds use each Đạo's
  natural parents from Spiritual Roots rule 16.

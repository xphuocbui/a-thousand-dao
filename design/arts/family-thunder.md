# Thunder (Lôi) signature arts

8 authored arts in `family-thunder.json`: 5 engine, 3 standalone, in two suites. `python -I tools/design/arts/lint_arts.py design/arts/family-thunder.json` prints 0 findings. Fully fed payoffs (lint `engine_payoff`): Capacitor Palm x3.75, Chain Arc x4.39, Answering Peal x3.24, Tribulation Seal x5.03, Thunderclap Bind x3.47. Not simulated; numbers are first guesses.

| Art | Mechanic shape | Hooks | Engine (how to feed it) | One-line rule |
|---|---|---|---|---|
| Capacitor Palm (Tụ Lôi Chưởng) [engine] | Build-up, cash-in (counter, no cap) | charges, Lightning art count, crit, Thunder stacks, free hits | Charges from any landed Lightning art or crit; step 1: 3 Charges or Overload; step 2: 6 Charges AND (6 foe Thunder stacks OR 3 scripture arts in a pulse), burns 3 own Thunder stacks | Lightning arts store Charges; the Palm releases one 0.15 strike each, then hits 1.6x, then 4x when fed. |
| Chain Arc (Liên Hoàn Lôi) [engine] | Split hits, crit snowball | crit chance, per-hit effects, quick arts, Thunder stacks | Step 1: 4 Thunder stacks (own or foe) or Overload (1.6x); step 2: (2 own or 4 foe stacks) AND (3 Peals, 4 Charges or 3 scripture arts in a pulse), burns 2 own stacks for 8 hits at 2.5x | Five hits that each crit-roll and ramp crit chance; fed, it becomes eight stronger hits. |
| Answering Peal (Hồi Lôi) [engine] | Echo and repeat | crit, last art, trigger damage, Slowed Time | Peals from crits or new Slowed Time; empower (3x) on (3 Peals or 3 scripture arts in a pulse) AND (3 foe or 2 own Thunder stacks) | 3 Peals: next crit refires your last art at 60 %. |
| Overload Form (Quá Tải Thể) [standalone] | Stance with backlash | crit, art speed, Thunder buff stacks, evade, low linh lực | It is the feeder: unlocks Palm and Chain Arc steps | +25 % art speed, +15 crit, -25 evade; crits give Thunder stacks and sting you. |
| Tribulation Seal (Kiếp Lôi Ấn) [engine] | Stacks above N, uncapped heaven-strike, verdict | Thunder stacks, stack duration, pulse count, low-health foe | Step 1: 4 foe stacks, 4 Charges or a Slowed foe (2x); step 2: 6 foe stacks AND (Slowed x2, foe at 50 % health or 3 scripture arts); consumes 6 foe stacks for 5x | At 8+ stacks heaven strikes every pulse; the verdict consumes stacks for a huge hit. |
| Thunderclap Bind (Lôi Phược) [engine] | Delay and Slowed Time | crit, Slowed Time, timer delay, foe cooldown | Step 1: Slowed foe, 4 foe stacks or foe at 60 % linh lực (delays 1 s, 2x); step 2: 4 foe stacks AND (Slowed x2, 3 Peals or 3 scripture arts) (all timers +1 s, 4x) | Slowed Time x2; crits delay the foe's longest timer. |
| Stormcloud Familiar (Lôi Vân Linh) [standalone] | Summon | companion speed, companion damage, crit, Thunder stacks | Its crits lay foe Thunder stacks: feeds the Seal | A cloud strikes for 0.08 every 2 s for 9 s; its crits lay Thunder stacks. |
| Storm Bank (Tích Lôi Ngân) [standalone] | Charges, paid in health | charges, health cost, damage more, low health, healing | Below half health each bolt lays 2 foe Thunder stacks: feeds the Seal | 3 bolts at 3 % health each; each gives +2 % damage stacking. |

## Suite: Thousand-Bolt Scripture (`thousand-bolt-scripture`)
Capacitor Palm, Chain Arc, Answering Peal, Overload Form. A crit build: Overload gives speed and crit and Thunder stacks, Chain Arc crits feed Peals and Charges, the Palm cashes Charges in, and Peal echoes the heaviest art. Firing three of the four in one pulse opens the top step of the Palm, Chain Arc and the Peal at once.

## Suite: Heavenly Tribulation Scripture (`heavenly-tribulation-scripture`)
Tribulation Seal, Thunderclap Bind, Stormcloud Familiar, Storm Bank. A stack-and-delay build: the Familiar's crits and low-health Storm Bank bolts pile Thunder stacks on the foe, Bind slows and dries it, and the Seal's verdict cashes everything in. Slowed foe or Peals (cross-suite) are alternative keys.

## Library arts replaced
| Library art | Fate |
|---|---|
| forking-verdict, forked-light | Replaced by Chain Arc (forked-light stays as a common). |
| rolling-thunder | Replaced by Answering Peal (the 50 % health guard is gone). |
| cloud-splitting-bolt, far-flash | Merged into Tribulation Seal. |
| thunder-needle | Replaced by Thunderclap Bind and Stormcloud Familiar; Leaking Ward on hit is no longer carried. |
| ice-breaking-peal | Role covered by Storm Bank; its dry-foe 30 % bonus is not kept. |
| thread-lightning-brand, rolling-peal, static-charge | Commons, kept as they are. |
| iron-spark, lightning-step, winnings, static-veil | Untouched (conversion, utility, ward). |

## Engine gaps
- `fire_art` with `which: last` repeats any last art, not the last Thunder art: it needs an element or tag filter.
- Stances cannot suppress arts by tag, only by id, and have no per-second upkeep, so Overload Form's trade-off is stat-only.
- `free_hit` is bound by the trigger budget and cap, so "limitless" Charge and stack scaling is clipped there (needs a decision).
- Counter `pay` (spend a counter inside a step) is not used: the Palm spends Charges through its own discharge effect, and steps pay with Thunder stacks only.
- Chain Arc's sub-hits are assumed to fire `crit` events in sequence; no real chaining to extra targets (one foe only).
- Cross-suite readables (`own.counter.peal`, `own.counter.charge`) read 0 when the other art is not equipped; intended, but untested.
- Tribulation (Thiên Kiếp) boss fights wait on built content.

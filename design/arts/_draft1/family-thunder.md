# Thunder (Lôi) signature arts

8 authored arts in `family-thunder.json`, linted at 0 findings (`python -I tools/design/arts/lint_arts.py design/arts/family-thunder.json`). Each has one mechanic of its own. Numbers are first guesses inside the art lint. The lint checks the schema; it does not run a fight, so none of these has been simulated yet.

| Art | Mechanic shape | Hooks | One-line rule |
|---|---|---|---|
| Capacitor Palm (Tụ Lôi Chưởng) | Build-up, then cash-in (counter, no cap) | charges, Lightning art count, art speed, free hits, crit | Each landed Lightning art stores 1 Charge; the Palm releases all as 0.22-coefficient strikes and empties the store. |
| Stormcloud Familiar (Lôi Vân Linh) | Summon | companion speed, companion damage, crit, Thunder stacks, summon count | A cloud strikes for 0.55 every 2 s for 9 s; its crits lay Thunder debuff stacks. |
| Overload Form (Quá Tải Thể) | Stance (state) with a backlash | crit, art speed, Thunder buff stacks, evade, low linh lực | Toggle: +35 % art speed and +20 crit, -25 evade, crits feed you Thunder stacks and sting you; ends at 15 % linh lực. |
| Chain Arc (Liên Hoàn Lôi) | Split hits, crit snowball | crit chance, per-hit effects, quick arts, on-hit stacks | Five 0.5 sub-hits that each roll a crit; each crit adds +6 crit chance for 3 s, stacking. |
| Answering Peal (Hồi Lôi) | Echo and repeat (counter on crit) | crit, last art, art coefficient, trigger damage | At 3 Peals the next crit fires your last art again at 60 % and clears them. |
| Thunderclap Bind (Lôi Phược) | Delay and Slowed Time (curse pattern) | crit, Slowed Time, curse duration, timer delay, foe cooldown | Applies Slowed Time x2; while slowed, each crit pushes the foe's longest cooldown back 0.6 s. |
| Tribulation Seal (Kiếp Lôi Ấn) | Conditional payoff on stacks above N, uncapped | Thunder stacks, stack duration, pulse count, other stack sources | At 8+ Thunder stacks on the foe, every pulse heaven strikes for 0.18 per 4 stacks. |
| Storm Bank (Tích Lôi Ngân) | Charges and bursts, paid partly in health | charges, health cost, art speed, damage more, low health | Three back-to-back bolts at 3 % health each; every bolt gives +25 % damage for 3 s, stacking. |

## Library arts replaced

This family rebuilds the authored Thunder arts of `part-b.json` and `part-c.json`. The `part-*.json` files are untouched, so the originals still exist until triage merges this file.

| Library art | Fate |
|---|---|
| thunder-needle (Leaking Ward on hit) | Not rebuilt. Its ids are listed in the `sources` of Stormcloud Familiar and Thunderclap Bind. |
| cloud-splitting-bolt, far-flash | Merged into Tribulation Seal (a stack-driven payoff). |
| rolling-thunder (guard: foe at 50 % health) | Replaced by Answering Peal. |
| forking-verdict | Replaced by Chain Arc (every hit forks, not 2 a pulse). |
| ice-breaking-peal, `rolling-peal` common | Their cooldown role is covered by Storm Bank. `rolling-peal` stays as a common. |
| iron-spark | Not replaced: Physical conversion (see gaps). |
| lightning-step, winnings | Untouched. |
| forked-light, thread-lightning-brand, static-charge, rolling-peal | Commons, kept as they are. |

## Engine gaps

- **Fire-art filter:** `fire_art` with `which: last` repeats whatever fired last, not the last Thunder art. Answering Peal can echo a non-Thunder art. It needs an element or tag filter on `fire_art`.
- **Overload Form:** the state has no way to suppress arts by tag, only by id. A real stance trade-off such as "your heavy arts are suppressed" cannot be written. It also has no cost per second; the only upkeep is the lightning backlash and the linh lực threshold.
- **Capacitor Palm and Tribulation Seal:** `free_hit` is bound by the trigger budget and cap. Very large Charge or stack counts will be clipped, so limitless scaling is really limited by the trigger budget. Whether that is intended needs a decision.
- **Chain Arc:** `split` sub-hits are assumed to roll crit and fire `crit` events one after another so the ramp builds within one firing. The lint does not prove this; it needs a run in the engine. There is no real chaining to extra targets (one foe only).
- **Storm Bank:** `charges` with `hp_cost` is written as the engine documents it. How a refired charge behaves under `cooldown_min` is untested here.
- **Not written for lack of an engine piece:** a Physical conversion of a Lightning art (`convert` exists, but nothing makes the art keep the Lightning tag while hitting Physical defence in the lint), and a Thunder shield or heal as a weapon. There is no readable for "crits this pulse", so "crit streak" payoffs use counters.
- **Tribulation (boss fight):** the Thiên Kiếp fight itself waits on built content; these arts are only the player-side hooks.

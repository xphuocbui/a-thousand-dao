# Ice (Băng) signature arts

8 authored arts (5 engine, 3 standalone), two suites. Lint: `python -I tools/design/arts/lint_arts.py design/arts/family-ice.json` → 0 findings; 9 gated payoff lines at x3.0-x5.5 of the lint. Built on `_draft1/family-ice`: kept its seal, palm, form, glaze, delay, mantle and volley ideas, and gave the engine arts steps and empowers.

| Art | Mechanic shape | Hooks | One-line rule | Engine (how to feed it) |
|---|---|---|---|---|
| Rime-Lock Seal (Sương Tỏa Ấn) | Cost lock, multi-step curse pattern | ice stacks, foe art costs, timer delay, canon arts fired | Each 10 Ice stacks add Heavy Breath; later steps lock harder and delay arts | Step 1: foe Ice ≥ 10, foe already cursed or 2 canon arts this pulse. Step 2 (eats 10): foe Ice ≥ 15 AND (2 Heavy Breath or Shatter Palm fired ≤ 3 s ago) |
| Shatter Palm (Toái Băng Chưởng) | Build-up then cash-in (consume) | ice stacks, free hits, crit, slowed time, low-health foe | Shatters the foe's Ice stacks for a huge hit plus a cold hit per stack | Foe Ice ≥ 10 AND Frost ≥ 2 (eats all, a free hit per stack); OR Slowed Time ≥ 2, foe ≤ 30 % health, or Deep Winter (eats 5) |
| Deep Winter Form (Thâm Đông Thế) | Stance with a thaw-break exit | basic speed, ice stacks, frost, resistance, low health | Slow, tough stance that lays Ice on every hit; leaving it fed is a thaw break | Frost ≥ 5 (built by the stance and by Seal and Palm); OR foe Ice ≥ 15; OR own health ≤ 50 % |
| Black Ice Glaze (Huyền Băng Ấn) | Held payload ("your next art") | next art, art speed, heavy arts, exposed, free hits | The next art (cap 2 glazes) lands Exposed, 8 Ice stacks and a cold hit | Standalone: scales with art speed and how heavy the next art is |
| Stilled Instant (Đình Thời Ấn) | Delays and Slowed Time, multi-step | ice stacks, timer delay, slowed time stacks, sutra arts fired | Lays Slowed Time and freezes art timers per 10 Ice stacks; later steps stop time harder | Step 1: Slowed Time ≥ 2, foe Ice ≥ 10 or 2 sutra arts this pulse. Step 2 (eats 10): foe Ice ≥ 15 AND (Slowed Time ≥ 3 or 2 sutra arts this pulse) |
| Shattering Mantle (Toái Băng Giáp) | Shield as a weapon, multi-step | body shield size, shield breaks, free hits, ice stacks | A body shield that bursts into cold hit and Ice stacks; re-fired it slams | Shield standing, health ≤ 50 % or foe Ice ≥ 6 (step 1); foe Ice ≥ 12 (eats 12) AND (shield standing or 2 sutra arts this pulse) (step 2) |
| Sleet Volley (Tuyết Vũ Tiễn) | Charges and split hits | charges, art speed, split hits, crit | 3 charges, 5 icicles each, each lays an Ice stack (2 more on crit) | Standalone: feeds every Ice consumer |
| Frozen Marrow Pact (Cốt Băng Khế) | Paid with health; conditional payoff per Ice stacks | ice stacks, health cost reduction, healing, free hits | Costs 6 % health; per 5 Ice stacks adds a cold hit and a 1 % heal | Standalone: pairs with Ice stackers and health regeneration |

## Suites

**Winter Toll Canon (Đông Toán Kinh)** (`winter-toll-canon`): Rime-Lock Seal, Shatter Palm, Deep Winter Form, Black Ice Glaze. Loop: the form and the Sleet-style stackers pile Ice; Seal locks the foe's costs and eats stacks to delay; Palm cashes what is left. Seal, Palm and Form all build the shared **Frost** counter, which pays the form's thaw break. Palm and Seal read each other (`own.since.shatter-palm`, group arts fired this pulse); Glaze primes the next art of the chain.

**Stilled Hour Sutra (Đình Thời Kinh)** (`stilled-hour-sutra`): Stilled Instant, Shattering Mantle, Sleet Volley, Frozen Marrow Pact. Loop: Volley's icicles raise Ice fast; Instant freezes timers and Mantle turns a taken hit into a burst, both stepping up when two sutra arts fire in one pulse; Pact turns the stacks into healing. Suite members also use the Ice consumers of the first suite.

## Library arts replaced

- `frostbound-toll`, `leaking-seal` → Rime-Lock Seal (the existing common `leaking-seal` stays as is).
- `rime-needle` (staged) → Sleet Volley; the common `rime-needle` is untouched.
- `undertow` (authored) → Stilled Instant in the timer role; the library `undertow` (dry-linh-lực guard) stays as a different art.
- `rime-mantle` → Shattering Mantle.
- New: Shatter Palm, Deep Winter Form, Black Ice Glaze, Frozen Marrow Pact. Commons (`frost-seal`, `rime-brand`, `cold-ledger`) are kept and not repeated.

## What the engine could not express

- **Per-stack scaling inside a held payload**: Black Ice Glaze cannot make its blessed art's bonus grow with the Ice stacks (a `scale` would multiply the Exposed stack count too). Needs `scale` per action, not per Effect.
- **Frozen/Brittle as a state of the foe**: no "foe is frozen" status; the cost lock is Heavy Breath plus stack-scaled cost, and delays are timer moves. A freeze status that makes the next hit crit or bypass would let "brittle payoffs" be named directly.
- **Consume `then` per stack with a `c` read from the stack count** is approximated by `per: 1` free hits.
- **Shield-breaking on purpose** (spending your own shield as a payment) is approximated by a `shield` pay that re-raises it; there is no "break own shield now" action.
- **Order of toggle and empower** on the stance (empower reads the state before the toggle) follows the Water family's convention and is untested here.

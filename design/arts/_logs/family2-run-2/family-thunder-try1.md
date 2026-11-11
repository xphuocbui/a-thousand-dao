# Job transcript: family-thunder (try 1)

I wrote the Thunder family: 8 arts in `design/arts/family-thunder.json` and the table in `design/arts/family-thunder.md`. The lint prints `checked 8 arts in 1 files, 0 findings`. Nothing has been run in a fight, so the numbers are first guesses.

There are 3 standalone and 5 engine arts. Fully fed, the engine arts hit between x3.24 and x5.03 of the lint; no payoff is ungated.

- **Standalone:**
  - Overload Form is a stance.
  - Stormcloud Familiar is a summon.
  - Storm Bank holds charges and pays in health.
- **Engine, with the full-power payoff:**
  - Capacitor Palm stores Charges and cashes them in, up to x3.75.
  - Chain Arc is a crit-snowball split hit that becomes 8 hits, x4.39.
  - Answering Peal echoes your last art, x3.24.
  - Tribulation Seal has a verdict that consumes the foe's Thunder stacks, x5.03.
  - Thunderclap Bind delays the foe's timers, x3.47.

Every engine art has at least two ways to feed it. The routes are Charges, own or foe Thunder stacks, Overload Form, Peals, a Slowed or dry foe, a foe at 40 % health, and three arts of the same scripture fired in one pulse.

The two suites:
- **Thousand-Bolt Scripture:** Capacitor Palm, Chain Arc, Answering Peal, Overload Form.
- **Heavenly Tribulation Scripture:** Tribulation Seal, Thunderclap Bind, Stormcloud Familiar, Storm Bank.

The .md lists which library arts these replace and these engine gaps:
- `fire_art` cannot filter to Thunder arts.
- Stances cannot suppress arts by tag.
- `free_hit` is clipped by the trigger budget.
- A step cannot pay with a counter, so the Palm spends Charges through its own discharge effect.
- Cross-suite counters read 0 when the other art is not equipped.

FAMILY-DONE design/arts/family-thunder.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-thunder.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-thunder.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/family-thunder.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-thunder.md) instead (Edit rules cover all file-editing tools).
```

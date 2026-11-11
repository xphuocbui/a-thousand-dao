# Job transcript: family-metal (try 1)

I wrote the Metal family: 8 arts in `design/arts/family-metal.json` (5 engine, 3 standalone). `python -I tools/design/arts/lint_arts.py design/arts/family-metal.json` prints 0 findings. I did not run any of the arts through the combat engine, only the lint.

- **Engine arts:** Whetstone Pass, Shatter-Edge Cleave, Sheathed Edge, Flying Blade Retinue and Sundering Wedge. Each has two or more ways to feed it. Fully fed, they hit 3.3–5.9 times a plain art of equal cost.
- **Standalone arts:** Blood-Quench Blade, Needle Rain and Iron Hide Stance.
- **Suites:** Nine-Temper Scripture (Whetstone, Cleave, Sheathed Edge, Blood-Quench) shares a Temper counter. Hundred-Blades Canon (Needle Rain, Retinue, Wedge) shares the foe's Metal stacks and Sundered.
- **Shapes:** No two arts share a mechanic shape.
- **Replaces:** Iron Hide Stance replaces Thorn Chorus, and Sundering Wedge replaces Writ of Reckoning.

Several mechanics are assumptions the lint cannot check:
- **Held strikes ignore tag filters:** Sheathed Edge banks a strike on any crit, not only Metal ones.
- **Spending Temper:** I used a negative counter add, assuming it floors at 0.
- **Consume as a payment:** I assumed it does nothing when the foe has no stacks.
- **"Fired this pulse" count:** I assumed it includes the art being fired.
- **Needle Rain:** I assumed each sub-hit rolls its own crit and status.
- **Shared counter:** the Temper counter is declared in each art that uses it, so a build combining them must dedupe.

The `.md` also names the stance-by-tag gap, with the table, suite sections and replaced arts.

FAMILY-DONE design/arts/family-metal.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-metal.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-metal.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/family-metal.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-metal.md) instead (Edit rules cover all file-editing tools).
```

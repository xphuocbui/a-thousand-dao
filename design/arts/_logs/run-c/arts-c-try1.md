# Job transcript: arts-c (try 1)

Part C is written: 49 arts (16 common, 33 authored), a few more than the target of about 40. `python -I tools/design/arts/lint_arts.py design/arts/part-c.json` prints 0 findings. The coverage counts are thunder 13, wind 11 and 25 element-less, which includes control and utility.

Each element has at least 3 common arts. Authored arts cover damage, stacks or curse, and identity (thunder crits, wind speed). Element-less arts have the Force, Chaos and soul damage arts, the curse and control seals, cleanse, escape, heal and one summon.

What I could not express in the schema (details are in `design/arts/part-c.md`):
- **Conversion inside a hit** (Iron Spark's 60 % Physical): there is no art field for it. Iron Spark is a `phys` art with the Thunder element, which approximates it.
- **Cleanse by tag:** the engine only cleanses a number of batches, so the cleanse arts use a count and a guard.
- **Escape** is not modelled by the engine, so the two escape arts carry the guard only.
- **Companion rules:** Whistle In uses a `companion_speed` mod as a stand-in, and Bark Mantle, Old-Tree Sap and Rouse are left out. House Takes All's Cash Out and Lustral Bell's telegraph were also left out or approximated, and Deaf Verdict uses `foe.boss` for its phase guard.
- **Cloud-Splitting Bolt's slot-order rule** ("largest hit of the volley") is only a `breaker` tag.
- **Staged rows with no part-C home:** open-hand-reckoning, gate-hammer, closing-palm, cold-ledger and still-tide. They need other parts or a rule.

Curse arts sit lower in `c_art` than the staged guesses, since the lint charges curse duration.

I wrote a throwaway generator script in `design/arts/` to compute the `c_art` values and deleted it afterwards. Only `part-c.json` and `part-c.md` remain.

ARTS-DONE design/arts/part-c.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/part-c.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/part-c.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/part-c.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/part-c.md) instead (Edit rules cover all file-editing tools).
```

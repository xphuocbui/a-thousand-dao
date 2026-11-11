# Job transcript: family-fire (try 1)

I wrote the Fire family: 8 authored arts in `design/arts/family-fire.json` and `design/arts/family-fire.md`. The lint reports 0 findings. None of the arts has been run in a fight; the new step, empower and consume-`then` fields are only linted.

**What's in it**
- **Standalone (3):** Scorch Fist, Blood-Fed Pyre and Brazier Form. Scorch Fist is the conversion art: a half-converted Physical fist that becomes fully Fire against a foe with 20+ Burn.
- **Engine arts (5):** Furnace Heart, Flint Volley, Twin Flame Echo, Ash Rebirth and Heat Haze. Each has a gated step and 3-4 feed routes joined by OR-guards. The lint reports `engine_payoff` of x3.04 to x3.60 for them.
- **Suites:** `red-sun-scripture` (Furnace Heart, Flint Volley, Twin Flame Echo, Brazier Form) and `ashen-phoenix-canon` (Ash Rebirth, Heat Haze, Blood-Fed Pyre). Members feed each other's steps through `own.fired_within.3.group.<id>`.
- **Shapes:** the eight arts use eight different mechanic shapes, with no repeats.

**Library arts replaced:** Burning Reply and Cinder Cloak (by Brazier Form) and Flare Up (by Furnace Heart's vent step). They should be removed from `part-a`/`part-b` when the family is merged.

**What the engine could not express**
- **Missing summon:** the family has no summon art.
- **Counter scale and reset:** Ash Rebirth's rise-from-Down needs a per-action scale, so its heal and reset sit in two Effects that rely on Effect order.
- **Compound step conditions:** step unlocks can only OR conditions together, so an "A and B" unlock cannot be written.
- **Missing readables and options:** there is no way to suppress arts by tag (Brazier Form suppresses Ember Rain by id), no "except this art" option for echoes, no readable for charge count, and the lint has no charge-aware budget for Flint Volley.
- **Flat Heat spend:** a vent that spends all Heat and scales with it would need a pay that reads a counter. Furnace Heart spends a flat 10.

`.md` has the full table, both suite sections and the complete engine-gap list.

FAMILY-DONE design/arts/family-fire.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-fire.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-fire.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/family-fire.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-fire.md) instead (Edit rules cover all file-editing tools).
```

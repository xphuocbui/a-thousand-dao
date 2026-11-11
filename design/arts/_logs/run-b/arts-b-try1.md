# Job transcript: arts-b (try 1)

I wrote `design/arts/part-b.json` (45 arts, 16 common and 29 authored) and `design/arts/part-b.md`. The lint prints `checked 45 arts in 1 files, 0 findings`. I did not run any art in the fight simulator, so how they play is untested.

- **Water (11):** sustain, plus the soul arts staged under Water.
- **Ice (8):** costs lock.
- **Wood (13):** heals and poisons.
- **Other elements (13):** heal and ward arts for Earth, Metal, Fire, Thunder, Wind and element-less, mostly cleanse arts.
- **Common arts:** each of Water, Ice and Wood has at least 3 (a plain damage art, a stack builder and one more).
- **Gaps filled:**
  - Water: sustain identity (Ebb and Flow), ward.
  - Ice: plain damage, cost-lock identity (Frostbound Toll), ward.
  - Wood: plain damage, curse, identity (Venom-Drinking Root), signature damage (Heartwood Spear), ward.
  - Other elements: Fire, Thunder, Wind and Earth ward arts, and a Fire heal.

**Not verified:**
- **Refund:** refund-on-heal is written as a `refund` action on `heal_restored`. I did not check that the engine passes the art's cost into that event, so it may do nothing.
- **Tag filters:** every shield, refund and bonus Effect filters on a tag unique to its art. I did not check that the engine honours `filter.tags` on `art_fired` and `heal_restored`.

**Changed from the staged rows:**
- Poison batches (10 for 14 s, 24 for 20 s, 16 for 24 s) and Earth 8 for 16 s exceeded the 0.6 stack charge, so I cut them (for example Rot Seed is 4 for 10 s).
- Leaking Seal's c_art is 1.08, down from the staged 1.9, because Leaking Ward charges 0.15 a pulse.
- Ninth-Weight Lance is 0.0643 instead of 0.0644 to stay under the soul lint.

**Not expressible, so left out or approximated:**
- Companion and summon arts, and escape arts.
- Conversions inside a hit.
- The `curse`, `soul` and `seal` cleanse tags.
- Lustral Bell's telegraph.

`part-b.md` has the merged staged ids and the full list.

ARTS-DONE design/arts/part-b.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/part-b.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/part-b.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/part-b.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/part-b.md) instead (Edit rules cover all file-editing tools).
```

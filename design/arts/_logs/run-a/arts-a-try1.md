# Job transcript: arts-a (try 1)

I wrote 42 arts to `design/arts/part-a.json` (19 `common`, 23 `authored`), and the lint prints `checked 42 arts in 1 files, 0 findings`. The lint only checks names, ranges and charges, so I haven't run any of the new Effects in a fight.

By group:
- **Fire:** 10 arts.
- **Earth:** 10 arts.
- **Metal:** 10 arts.
- **Element-less Physical:** 12 arts across sword, saber, fist and spear.

Each element has at least 3 `common` arts, including a plain damage art and a stack builder. Authored arts cover damage, stacks or curse, and each element's identity: Burn payoffs, Earth endurance, Metal pierce and reckoning, and Physical curses and control. Where staged arts overlapped I merged them and listed their ids in `sources`.

Things to know:
- I couldn't run my own scripts here, so I computed every `c_art` by hand from the lint formula.
- Several mechanics aren't expressible in the schema, so I left them out or approximated them. The main ones are own conversion (Physical to Fire), a per-art `damage_more` on L2, health-paid costs, the Held Reflection bank, boss-phase guards and OR-guards. All are listed in `part-a.md`.
- The Iron Mountain Shield size (8% of health) is a guess. The `dmg_more` units (percent assumed) and the tag scoping on `mod` in Thorn Chorus and Ledger Reckoning are untested in a fight run.
- Packed Earth Stance is set to 5 stacks for 12 s, because both staged variants broke the 0.6 stack-second charge.

`part-a.md` has the per-element tables, merged ids, gaps filled and the unexpressible list.

ARTS-DONE design/arts/part-a.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/part-a.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/part-a.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/part-a.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/part-a.md) instead (Edit rules cover all file-editing tools).
```

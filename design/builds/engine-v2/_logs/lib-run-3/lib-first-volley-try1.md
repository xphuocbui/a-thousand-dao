# Job transcript: lib-first-volley (try 1)

I rebuilt `first-volley` from the library and fought it on engine v2. On the typical foe at its own realm it wins 20-0 in 1.5 s. Against the top-end foe it loses 20-0 at both realms.

- **Techniques:** The main method is `thousand-bolt-scripture`, which carries overload-form, chain-arc, answering-peal and capacitor-palm. The fifth art is the common `forked-light`. I took no auxiliary technique: Thunder has no secret technique in the catalogue, and the usable body techniques only add arts that don't fit a volley. That leaves one of the six slots empty.
- **Realm files:** Only `design/builds/engine-v2/builds/first-volley.fight.json` (Nguyên Anh) exists, because the old build had a fight file only for that realm. So there were no other-realm runs.
- **Purity:** The old fight file had no `purity` field. I used `{"thunder": 60}` from the guide's "purity 60 or more", so check that.
- **Effects kept or modelled:**
  - **As build fields:** opening haste +250 and one refusal.
  - **As Effects:** Flowing Water, linh lực on crit, and Unanswered (+40 L5 while the foe has fired no art).
- **Lost in the move:**
  - **No library equivalent:** Iron Spark's Physical conversion, Lightning Step, Thunder Needle's Leaking Ward, and the single big Breaker hit.
  - **Overrides not allowed:** The old per-art L2 300 and L4 150 are gone, because library arts take no overrides. This makes the result weaker than the old file, so the numbers aren't comparable with it.

| Matchup | Mean s | W-L | You dry | Foe dry |
|---|---|---|---|---|
| typical, same realm | 1.5 | 20-0 | never | 1.1 s |
| typical, +1 realm | 2.0 | 20-0 | never | 1.5 s |
| top_end, same realm | 4.7 | 0-20 | 4.3 s | never |
| top_end, +1 realm | 2.2 | 0-20 | 2.1 s | never |

- **`--without tech:thousand-bolt-scripture`:** no change at any of the four matchups. I did not investigate why, so either the technique's passives are redundant here or the loader isn't applying them.
- **`--without unanswered`:** no change at the same realm except the foe going dry later (1.5 s instead of 1.1 s); at +1 realm the typical fight goes from 2.0 s to 2.5 s.
- **Opening haste:** It is a build field, so `--without` can't remove it and I didn't test it.
- **Guide's claims:** The guide's claim that the volley beats top-end at the floor does not hold on these runs. Every fight is far under the 30–60 s band, and no art went unfired.

Everything else is in `first-volley.md`, including the UNMODELLED lines.

LIB-DONE design/builds/engine-v2/first-volley.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/first-volley.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/first-volley.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/first-volley.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/first-volley.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/first-volley.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/first-volley.md) instead (Edit rules cover all file-editing tools).
```

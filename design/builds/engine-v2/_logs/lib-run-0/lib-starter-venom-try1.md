# Job transcript: lib-starter-venom (try 1)

I rebuilt `starter-venom` from the library and wrote the two fight files and the results file. The Foundation (Trúc Cơ) same-realm fight lasts 30.9 s, inside the 30-60 s band at its low edge.

**Build.** The main method is `verdant-cycle-scripture` and the one auxiliary technique is `rotting-canopy-canon`. Arts at Foundation, all `{"lib": id}` with no overrides:
- `thorn-rain` and `blight-canker` from the poison suite.
- `second-spring` and `harvest-bloom` from the main suite.

The Core Formation (Kết Đan) file adds `thornling-grove`. Layers, speed, cost, regeneration and healing fields are the old values.

**Purity.** The old fight file had no purity field, so I wrote wood 50 from the guide's "middling purity". Without a wood entry the Wood techniques would not be usable. This is my reading of the guide, not a copied number, and it is recorded in the file and the guide.

**Cleanser file.** I did not write a v2 file for `starter-venom.cleanser.fight.json`. It was an enemy variant at the same realm, not another realm. The guide's cleanser claim is therefore not re-tested.

**Results (20 fights each).**

| Matchup | Mean | Result |
|---|---|---|
| Same realm, Foundation, typical | 30.9 s | 20-0, never dry, about 99 % health left |
| Same realm, Core Formation, typical | 19.6 s | 20-0 |
| A realm or two above, or top-end | 1-8 s | 0-20 |

**`--without` tests (typical, same realm).**
- **Main technique** (`tech:verdant-cycle-scripture`): 30.9 s to 31.1 s. The engine reads almost none of its passives, so its value here is the arts it carries, which stay in the file.
- **Identity piece** (`thorn-rain`, the old Thorn Seed's replacement): 30.9 s to 62.4 s. The build goes dry on linh lực but still wins.

**Observations.**
- The Foundation fight is about 7 s shorter than the guide's 38 s.
- The Core Formation fight is below the 30-60 s band.
- Health left is 99 %, against the guide's 76 %.
- The only NEVER_FIRED arts are in the +2 and top-end fights, where the fight ends before any art fires.

**What was lost.** No library art lays Rot Bloom's 24-stack, 20 s batch, so the build now stacks many short batches. The old L2 points on the poison arts, Weeping Sap's Wood regeneration stacks and Venom Tithe's linh lực refund are gone. The results file lists the UNMODELLED lines.

LIB-DONE design/builds/engine-v2/starter-venom.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/starter-venom.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/starter-venom.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/starter-venom.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/starter-venom.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/starter-venom.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/starter-venom.md) instead (Edit rules cover all file-editing tools).
```

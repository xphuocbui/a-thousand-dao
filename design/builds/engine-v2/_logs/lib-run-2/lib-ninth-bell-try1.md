# Job transcript: lib-ninth-bell (try 1)

I rebuilt `ninth-bell` from library arts and fought it on engine v2. The same-realm typical fight lasts 6.2 s against the 30-60 s band. The build wins it 20-0 and finishes on 71 % health.

- **Techniques:** `nine-temper-scripture` is the main method (Metal, `whetstone-pass` 1, `blood-quench-blade` 2, `sheathed-edge` 4, `shatter-edge-cleave` 6). `nine-seal-ledger` is the one auxiliary, and only `frozen-hour-seal` (layer 3) fits the five slots at Core Formation.
- **One realm file:** the old build had only the Core Formation fight file, so there is no second realm file.
- **Purity is my assumption:** the old file had no `purity`, so I set `{"metal": 80}`. The guide only says Metal.
- **Lost:**
  - The three bell arts and their 2/4/6 s cooldowns are gone, so the exact art-speed beat no longer exists.
  - On the Beat is still unmodelled, so the guide's exact-beat claims can't be checked.
  - The Great Toll's half-the-damage stroke has no library equivalent.
- **Other matchups:** one realm up it loses 0-20 at 11.5 s, and two realms up it loses 0-20 at 5.9 s. Top-end foes kill it in 1-2 s.
- **`--without` tests (typical, same realm):**

  | Test | Mean s | Health left |
  |---|---|---|
  | Baseline | 6.2 | 71 % |
  | `--without tech:nine-temper-scripture` | 6.7 | 70 % |
  | `--without whetstone-pass` | 7.5 | 64 % |

  Both tests still win 20-0. I used `whetstone-pass` as the identity piece because On the Beat isn't modelled.
- **NEVER_FIRED:** `shatter-edge-cleave` and `frozen-hour-seal` never fire against top-end foes, because those fights end within 2 s. No art is NEVER_FIRED in the typical fights.

The UNMODELLED lines and the old-to-library table are in the results file.

LIB-DONE design/builds/engine-v2/ninth-bell.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/ninth-bell.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/ninth-bell.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/ninth-bell.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/ninth-bell.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/ninth-bell.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/ninth-bell.md) instead (Edit rules cover all file-editing tools).
```

# Job transcript: lib-triple-convert (try 2)

I built `triple-convert` from the library and ran it, but its defining double conversion (Physical to Fire to Chaos) is not tested. The engine has no conversion inside a hit, and no library art converts twice.

- **No old fight files.** The Glob for `triple-convert*.fight.json` found nothing, and the build has no files for other realms. I built only the Nguyên Anh file from the guide, so layers, crit, ward and cost reduction are my guesses from the guide's caps, not carried-over values.
- **Build.**
  - **Techniques:** main `nine-temper-scripture`, aux `rotting-canopy-canon` and `scorch-fist-primer`.
  - **Arts:** six, filling the six slots at Nguyên Anh: `shatter-edge-cleave`, `scorch-fist`, `whetstone-pass`, `sheathed-edge`, `blight-canker`, `thornling-grove`.
  - **Effects:** Former Shapes, Kindled Wound and Marked Prey stay as flat Effects.
- **Matrix, typical at the same realm:**
  - **Fight length:** 8.2 s, well under the 30-60 s band. All 20 fights were won with 82 % health left.
  - **Stronger foes:** it lost all 20 fights against hoa_than+1 and against top_end. Most arts never fired there (NEVER_FIRED).
- **`--without` (typical, same realm).** The two tests moved the result little:

| Test | Before | After |
|---|---|---|
| `--without tech:nine-temper-scripture` | 8.2 s | 8.5 s |
| `--without former-shapes` | 8.2 s | 9.0 s |

- **Guide claims.** The ×255 figure and the Chaos-resistance break can't be tested here. The same-realm result is probably inflated by the flat Former Shapes and the guessed layers.

Files are in `design/builds/engine-v2/`:
- `builds/triple-convert.fight.json`
- `triple-convert.md`

LIB-DONE design/builds/engine-v2/triple-convert.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/triple-convert.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/triple-convert.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/triple-convert.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/triple-convert.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/triple-convert.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/triple-convert.md) instead (Edit rules cover all file-editing tools).
```

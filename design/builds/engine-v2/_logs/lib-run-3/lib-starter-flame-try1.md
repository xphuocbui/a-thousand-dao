# Job transcript: lib-starter-flame (try 1)

I rebuilt `starter-flame` from the library and fought it on engine v2. At the same realm it wins 20 of 20 in 17.9 s, which is below the 30-60 s band. I ran the matrix and both `--without` tests. There was no second realm file to write, because the old build only had a Kết Đan file.

**The build:** techniques `red-sun-scripture` (main), `ashen-phoenix-canon` and `scorch-fist-primer`. They carry five arts in the five Kết Đan slots: `brazier-form`, `flint-volley`, `furnace-heart`, `twin-flame-echo` and `heat-haze`. Scorch Fist's own art is not slotted, so only its passives count, and the engine marks its resist pen as not run. Everything that is not an art or technique is unchanged from the old file, including the Embers Feed the Hearth approximation.

**Results (typical, Kết Đan):**
- **Fight:** 17.9 s, the linh lực bar never ran dry, and 95 % health was left. The old build took about 22 s with 55 % health left.
- **Other matchups:** it loses by Nguyên Anh+1 (7.7 s), as the guide says. Against top-end it lasts 1.6 s.
- **`--without tech:red-sun-scripture`:** 18.8 s, still 20-0, with no change in any other matchup.
- **`--without flint-volley`:** 18.8 s, still 20-0, with no change in any other matchup. I used it as the identity piece because it replaces the old Burn batch arts.
- **NEVER_FIRED:** `flint-volley` at Nguyên Anh+1; `brazier-form`, `flint-volley` and `heat-haze` at Hóa Thần+2; every art against top-end.

Neither `--without` test moved the result much, so the numbers do not show either piece as the build's identity.

**Losses:**
- Warm the Hearth has no library equivalent, and Brazier Form is only a loose stand-in.
- The old cheap Burn rhythm (Spark Palm, Kindling Seal, Flame Lance) is gone, because the library only has those as common arts.
- Several technique passives are not run by the engine, so part of their value is not in the numbers.

All of this is in `design/builds/engine-v2/starter-flame.md`.

LIB-DONE design/builds/engine-v2/starter-flame.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/starter-flame.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/starter-flame.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/starter-flame.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/starter-flame.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/starter-flame.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/starter-flame.md) instead (Edit rules cover all file-editing tools).
```

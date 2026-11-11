# Job transcript: lib-burial-shroud (try 1)

I rebuilt `burial-shroud` from the library and fought it on engine v2. The write-up is done.

**What I did:**
- **Techniques:** Hollow Tide Scripture (main, thuy) and Ruin Ledger Scripture (secret, tho). Five library arts fill the five ket_dan slots.
- **Kept:** the realm, layers, ward, body numbers and every non-art piece. The Shroud, Spillover and reservation pieces stay as UNMODELLED lines.
- **One file only:** the old build had a single fight file, so there are no other-realm files.

**Results at ket_dan:**
- **Typical, same realm:** a 7.6 s win with 96 % health left.
- **Typical, one realm up:** a 14.1 s win with 61 % health left.
- **Two realms up and every top-end enemy:** all losses, in 1–8.5 s.
- **Fight length:** all of these are well under the 30–60 s band.
- **Never fired:** Hollowing Strike and Gathered Ruin Verdict against top_end at the same realm. All five arts against top_end one and two realms up.

**The `--without` tests (typical, same realm):**
- **`tech:hollow-tide-scripture`:** no change, 7.6 s to 7.6 s. Its passives are small and the arts it carries stay in the build.
- **`marrow-siphon-palm`** (the identity piece, standing in for Spillover): 7.6 s to 9.1 s, still a win. The old guide's "a win becomes a loss" does not repeat.

**Two flags you should check:**
- **Purity split:** the old file had no purity field, so I wrote water 50 and earth 50 from "Earth and Water". The 50/50 is my reading.
- **Clipped column:** the engine's output has nothing for it, so the table says n/a.

I did not run Bash commands that chain several operations, because those need approval here. I ran each command separately.

LIB-DONE design/builds/engine-v2/burial-shroud.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/burial-shroud.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/burial-shroud.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/burial-shroud.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/burial-shroud.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/burial-shroud.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/burial-shroud.md) instead (Edit rules cover all file-editing tools).
```

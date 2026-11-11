# Job transcript: lib-starter-blade (try 1)

I rebuilt `starter-blade` from the library and fought it on engine v2. At the same realm it wins 20 of 20 against a typical foe, in 15.0 s at Trúc Cơ and 12.1 s at Kết Đan. That is well under the 30–60 s band. I did not re-read the output files after writing them.

**The build**
- **Techniques:** Nine-Temper Scripture (main), Afterimage Sword Canon and Hundred-Blades Canon (both auxiliary). All three name only Metal, and I gave the root a Metal purity of 65.
- **Trúc Cơ arts:** `whetstone-pass`, `needle-rain`, `sheathed-edge` and `flying-sword`.
- **Kết Đan arts:** the same four plus `phantom-sword`.
- **Purity:** the old file had no purity field, so 65 is my pick from the guide's "60 to 70".

**Fights**
- **`--matrix`:** it printed six rows (three realms by typical and top_end). `top_end_the_tu` was not in its output. Against typical at Trúc Cơ the build wins 20-0, and I lose every fight against an enemy a realm up or at top end (8.0 s at Kết Đan+1, 1.0–3.5 s at Nguyên Anh+2 and top_end).
- **`--without tech:nine-temper-scripture`:** same realm, 15.0 s becomes 16.5 s, still 20-0. Removing the main technique's passives costs little.
- **`--without whetstone-pass`:** the fight goes from 15.0 s to 19.5 s, still 20-0. This is the build's identity piece.
- **Kết Đan file:** typical at the same realm, 12.1 s, 20-0, I run dry at 11.2 s.

**Guide claims**
- **Win rate:** the guide's 16 of 20 at Trúc Cơ and 14 of 20 at Kết Đan do not hold. Both are now 20-0 and much shorter.
- **Pool:** "dry at about 15 s" does not hold at Trúc Cơ. I never run dry there, but I do at Kết Đan.
- **Realm up:** losing to a cultivator a realm above still holds.

**NEVER_FIRED**
- **Arts:** `needle-rain` and `flying-sword` never fire against the realm-up and top_end foes. At top_end Kết Đan and Nguyên Anh+2 all four never fire, because the fights end in about 1 s.
- **Same realm:** every art fires in the same-realm fights.

**What was lost**
- **Arts:** Notch the Foe's debuff, Sheathe and Breathe and Ten Thousand Returns have no equivalent in the chosen suites. Quick Draw Cut became `needle-rain`, a six-needle volley rather than a cheap fast cut.
- **Overrides and manual:** the per-art L2 overrides and the manual's layer-4 enabler are gone.
- **Possible double count:** the old crit chance (0.15 / 0.18) already included the averaged Whet stacks, so it may double count with Temper. I kept it as the rules say.

The UNMODELLED lines are in `starter-blade.md`.

Files are in `design/builds/engine-v2/`:
- `builds/starter-blade.fight.json`
- `builds/starter-blade.ket-dan.fight.json`
- `starter-blade.md`

LIB-DONE design/builds/engine-v2/starter-blade.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/starter-blade.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/starter-blade.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/starter-blade.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/starter-blade.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/starter-blade.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/starter-blade.md) instead (Edit rules cover all file-editing tools).
```

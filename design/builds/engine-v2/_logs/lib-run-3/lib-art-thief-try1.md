# Job transcript: lib-art-thief (try 1)

I rebuilt `art-thief` from the library and fought it on engine v2. The fights end in 2.6 s at the same realm (Nguyên Anh, typical foe), well under the 30-60 s band. The foe-art theft itself has no library piece, so the build is a stand-in: it keeps the Hollow Hall sutra feel and re-fires your own arts instead of the foe's.

- **Techniques:** Hollow Tide Scripture as main, plus Hundred Echo Palm Scripture (body) and Afterimage Sword Canon (kim) as auxiliaries. The root is water 60 and metal 50, so all three are usable.
- **Arts:** Nguyên Anh carries six arts and Kết Đan five. Hollow Husk Stance is the sixth and is dropped at Kết Đan.
- **Lost:** Borrowed Hand, the loan slots and every modifier built on stolen copies are gone, and so is Still Pool Mending.
- **Slots:** fight.py raised no slot error for either file.

| Matchup (Nguyên Anh file) | Mean s | W-L |
|---|---|---|
| typical, nguyen_anh+0 | 2.6 | 20-0 |
| typical, hoa_than+1 | 3.0 | 20-0 |
| top_end, nguyen_anh+0 | 5.0 | 12-8 |
| top_end, hoa_than+1 | 4.5 | 0-20 |

- **Kết Đan file:** typical foe, 2.9 s, 20-0.
- **Without tests:** I used `answering-palm` as the identity piece. At the same-realm typical foe, both tests show no change from the full build (2.6 s, 20-0), because the foe dies before the echo arts fire.
- **NEVER_FIRED:** at that matchup only Hollow Husk Stance fires; the other five arts never fire. Twin Shadow Fist never fires in any matchup.
- **Extra run:** I also ran `--without tech:hundred-echo-palm-scripture`, which you didn't ask for, by mistake. It is noted in the file and changes nothing at the typical foe.

LIB-DONE design/builds/engine-v2/art-thief.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/art-thief.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/art-thief.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/art-thief.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/art-thief.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/art-thief.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/art-thief.md) instead (Edit rules cover all file-editing tools).
```

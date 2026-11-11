# Job transcript: tune-soul-song-seal (try 1)

The Soul, Song, Seal family is only partly tuned: Nine Seal Ledger and the engine checks are met, but Hollow Bell Canon and Thorn Lullaby are still too slow. Lint is at 0 findings, and no `NEVER_ENGAGED` line remains.

**Met**
- **Nine Seal Ledger:** x0.73 at Trúc Cơ and x0.81 at Kết Đan, up from x0.35 and x0.44 (FAST).
- **Engagement:** Frozen Hour and Branding now fire at both realms. Ambush and Frozen Hour reach a top step or empower about 1.2 to 2.1 times a fight.
- **Standalones:** Marching Dirge (x0.82 and x0.87) and Blood-Ink Writ (x0.73 and x0.82) are in range or close. Blood-Ink at Trúc Cơ sits just under the 0.8 floor.
- **Earned top gates:** the Death Knell, Death Trap, Hour Stopped and Sunk to the Soul steps now each need an easy route AND a real requirement.

**Not met**
- **Hollow Bell Canon:** x1.31 at Trúc Cơ and x1.17 at Kết Đan, against a target of x0.6 to x1.0. The lint's soul-damage limit on the Bell and Lance (`SOUL_OVER`) blocks the obvious fix. A test run with the limit exceeded reached x0.82 and x1.01. Raising `free_hit` values in `pay` and in the echo barely moved the fight, so I suspect the trigger budget clips them. The Bell's Death Knell (top step) never fired in a typical build.
- **Thorn Lullaby:** x1.38 and x1.23, against a target of x0.8 to x1.2. Changing the heal, adding a base strike and raising the thorn damage only moved it slightly.

I judged the three Seal-art gates and the Lullaby base strike (new `c_art` 1.8) by suite_check alone. The write-up in `tune-soul-song-seal.md` lists every change, the before and after suite_check rows, and these open items.

I also updated the gate text in `design/arts/family-soul-song-seal.md` and in the rule strings of `design/arts/family-soul-song-seal.json`.

Files are in `design/arts`:
- `family-soul-song-seal.json`
- `family-soul-song-seal.md`
- `tune-soul-song-seal.md`
- `_logs/soul-song-seal-orig.json` (backup of the original)
- `_logs/tune-soul-song-seal-apply.py` (patch script I wrote but couldn't run, so I applied the edits by hand; it can be deleted)

TUNE-DONE design/arts/tune-soul-song-seal.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-soul-song-seal.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-soul-song-seal.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/tune-soul-song-seal.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/tune-soul-song-seal.md) instead (Edit rules cover all file-editing tools).
```

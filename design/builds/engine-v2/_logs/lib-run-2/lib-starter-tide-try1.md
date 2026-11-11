# Job transcript: lib-starter-tide (try 1)

I rebuilt the Tide on the Still Moon Tide Scripture suite (Tĩnh Nguyệt Triều Kinh) and fought it. At Foundation (Trúc Cơ) against a typical same-realm foe it won 20-0 in 30.7 s, with the player never dry.

- **Build:** the whole four-art suite (`deep-lake-stance`, `gathering-wave`, `brimming-cup`, `swelling-tide-palm`) fills the four Foundation slots. At Kết Đan the second technique, Returning Wake Verse (`returning-wake-verse`), adds `backwash-seal` as a fifth art.
- **Kết Đan same-realm fight:** 19.1 s, a 20-0 win, so below the 30-60 s band. I ran that file once without `--matrix`.
- **`--without` same-realm tests:**
  - Without the main technique's passives: 30.7 s to 33.6 s.
  - Without `brimming-cup`: 30.7 s to 39.1 s.
- **Higher foes:** the build lost all 20 fights against a foe one or two realms up, and against every top-end foe within 1-2 s. The guide already says this.
- **Never fired:** `gathering-wave` and `brimming-cup` against the typical foe two realms up, and all four arts against every top-end foe.

I set L2 (40) and L5 (16) to 0 because they only stood in for the old Canon passive and the flat Brimming Cup proxy. The library technique has no damage-more passive, so the Canon's +40 is lost, as is the guide's "+2 % per 10 % pool" reading of the Cup. I mapped Tide Pulse to `swelling-tide-palm` and Drawing Breath to `deep-lake-stance` as the closest suite arts. Deep Well Seal has no library equivalent, so its heavy-hit role goes to the palm. Details and the UNMODELLED lines are in the md.

Files are in `design/builds/engine-v2/`:
- `builds/starter-tide.fight.json`
- `builds/starter-tide.ket-dan.fight.json`
- `starter-tide.md`

LIB-DONE design/builds/engine-v2/starter-tide.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/starter-tide.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/starter-tide.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/starter-tide.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/starter-tide.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/starter-tide.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/starter-tide.md) instead (Edit rules cover all file-editing tools).
```

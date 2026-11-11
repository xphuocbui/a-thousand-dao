# Job transcript: lib-mirror-hide (try 1)

I rebuilt `mirror-hide` from the library and fought it on engine v2. The same-realm typical fight (Kết Đan) ends in 3.0 s with 20 wins, but the `--without` tests changed nothing there. All five arts fired 0.0 times in that fight, so it says nothing about the technique.

**Choices**
- **Techniques:** Mountain Heart Canon (main, Earth) and Iron Hide Manual (secret, Metal).
- **Arts:** `mountain-stance`, `sinking-weight`, `bastion-reprisal`, `strata-hammer` and `iron-hide-stance`. These are all `{"lib": ...}` with no overrides. They fit the 5 slots at Kết Đan and the 6 at Nguyên Anh. The Nguyên Anh file carries the same five arts.
- **Left out:** I skipped Mountain Bone Body Art because its arts would have made seven. I did not test whether a technique with no slotted art still applies its passives.

**Loss:** The Return channel (Phản) has no library equivalent. The old `mirror-return` approximation is gone. Mountain Stance and Bastion Reprisal stand in, but they fire on events, not on the size of each hit. Mending Breath, Offering Cut, Needle Mark's Metal debuff and Thorn Chorus have no counterpart either. Needle Mark became Sinking Weight's Earth stacks and slow.

**Results**
- **Fight length against the 30–60 s band:**
  - A typical same-realm fight takes 3.0 s, far below the band.
  - A top-end same-realm fight takes 46.0 s with 20 wins, which is inside the band.
  - One realm up against top-end, it lost 0 of 20 in 14.1 s.
- **`--without` tests, Kết Đan typical:** removing `tech:mountain-heart-canon` or `mountain-stance` left it at 3.0 s, 20-0. At the top-end Kết Đan row the times moved only to 46.2 s and 46.7 s.
- **NEVER_FIRED:** all five arts in the same-realm typical fight. The other rows are in the results file.

**Process:** I wrote a small helper script to generate the fight files, but running it was blocked. I wrote both JSON files directly and deleted the helper afterwards.

**Index gap:** The index line for `iron-hide-stance` is truncated, and the `family-*.md` files named in the brief do not exist (the data is in the `.json` files). So I did not read that art's full rule, and the results file says so.

Files are in `design/builds/engine-v2/`:
- `builds/mirror-hide.fight.json`
- `builds/mirror-hide.nguyen-anh.fight.json`
- `mirror-hide.md`

LIB-DONE design/builds/engine-v2/mirror-hide.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/mirror-hide.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/mirror-hide.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/mirror-hide.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/mirror-hide.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/mirror-hide.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/mirror-hide.md) instead (Edit rules cover all file-editing tools).
```

# Job transcript: lib-dry-well (try 1)

I rebuilt Dry Well on the library as Winter Toll Canon (main) plus Stilled Hour Sutra, and the build now loses the top-end fight every time (0–20). The old guide claimed a 2.0 s win with 81 % health against the same foe type, so that claim no longer holds.

**Technique choice.** Winter Toll Canon is main and Stilled Hour Sutra is auxiliary. Both name Ice, and the build has Water 90 and Ice 72. I left the second auxiliary slot empty. I took the Water and Ice figures from the guide, because the old files carried no `purity`. The loader wants `water` and `ice` as the keys, not `thuy` and `bang`.

**Arts.** Nguyên Anh has six: rime-lock-seal, sleet-volley, deep-winter-form, black-ice-glaze, stilled-instant and shatter-palm. Trúc Cơ has four: rime-lock-seal, sleet-volley, deep-winter-form and shatter-palm.

**Matrix results (Nguyên Anh):**

| Matchup | Mean s | W-L |
|---|---|---|
| typical | 4.0 | 20–0 |
| typical, one realm up (hoa_than+1) | 7.2 | 20–0 |
| top_end | 13.7 | 0–20 |
| top_end, one realm up (hoa_than+1) | 7.4 | 0–20 |

- **`--without` tests (typical, same realm):** removing `tech:winter-toll-canon` or `rime-lock-seal` leaves both at 4.0 s and 20 wins. On the top-end foe, removing the Seal slows the fight from 13.7 to 16.0 s, still a loss.
- **Trúc Cơ (typical, one run):** 15.0 s, 20–0.
- **Fight length:** every fight is well under the 30–60 s band.
- **NEVER_FIRED:** none; all six arts fire in every row.
- **Losses in the move:** the Ward-bill curse (Leaking Seal's +50 %), the Qi Disruption burn, the two guarded blades and the heal have no library equivalent. They are recorded in the .md.
- **Unmodelled:** the keystone and item pieces stay in `unmodelled`, one line each with its reason. Those lines include Absolute Zero (the identity keystone), Weighted Bucket and Water Table.

Files are in `design/builds/engine-v2/`:
- `dry-well.md`
- `builds/dry-well.fight.json`
- `builds/dry-well.truc-co.fight.json`

LIB-DONE design/builds/engine-v2/dry-well.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/dry-well.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/dry-well.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/dry-well.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/dry-well.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/dry-well.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/dry-well.md) instead (Edit rules cover all file-editing tools).
```

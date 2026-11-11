# Job transcript: lib-starter-wall (try 1)

I rebuilt `starter-wall` from the library and fought it on engine v2. The two fight files and the write-up are written. One thing to know first: with `mountain-stance` removed the fight gets longer, not shorter.

**Build.** The main technique is `mountain-heart-canon`. Its four arts (`mountain-stance`, `sinking-weight`, `bastion-reprisal`, `strata-hammer`) fill the four Foundation slots. The two auxiliary body techniques, `unbroken-flesh-canon` and `mountain-bone-body-art`, bring only passives at Foundation. At Core Formation (Kết Đan) a fifth slot takes `bulwark-knuckle`, carried by `unbroken-flesh-canon`. Everything else in the old file is unchanged.

**Lost.** Mending Breath's guarded heal has no Earth library equivalent, so the build now has no heal art. I did not swap the main technique for a common one just to get `second-wind`.

**Same-realm results (typical foe, 20 fights):**

| Realm | Mean s | Result | You dry | Foe dry |
|---|---|---|---|---|
| Foundation (Trúc Cơ) | 31.7 | 20-0 | never | 22.1 |
| Core Formation (Kết Đan) | 19.5 | 20-0 | never | 15.2 |

- **Health:** you finish at 100 % in both, against about 70 % and 54 % in the guide.
- **Length:** Foundation sits at the lower edge of the 30-60 s band, and Core Formation is under it.
- **Higher realms:** one realm up the build loses 20-0, and every top-end fight ends in 1-2 s.
- **`--without tech:mountain-heart-canon`:** no change (31.8 s, 20-0), because none of its passives has an engine stat and none ran.
- **`--without mountain-stance`:** 43.1 s, 20-0.
- **NEVER_FIRED:** `sinking-weight`, `bastion-reprisal` and `strata-hammer` at Nguyên Anh +2, and all four arts in every top-end row. No art is NEVER_FIRED at the same realm.

The guide's old figures of about 65 s, about 70 % health left and linh lực running dry around 28 s no longer hold.

**Housekeeping.** I created a throwaway helper script in `design/builds/engine-v2/_logs/` and deleted it again; nothing else outside the named files was written.

Files are in `design/builds/engine-v2/`:
- `builds/starter-wall.fight.json`
- `builds/starter-wall.ket-dan.fight.json`
- `starter-wall.md`

LIB-DONE design/builds/engine-v2/starter-wall.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/starter-wall.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/starter-wall.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/starter-wall.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/starter-wall.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/starter-wall.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/starter-wall.md) instead (Edit rules cover all file-editing tools).
```

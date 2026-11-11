# Job transcript: lib-bare-fist (try 1)

I rebuilt `bare-fist` on the library and fought it on engine v2. It wins every typical-foe fight (20-0) in 9 to 18 s and loses every top-end fight (0-20). Typical fights fall well short of the 30-60 s band.

**Build:**
- **Root:** Earth, purity 80. Layers, crit, ward, evade and regen are carried over unchanged. The old files had no `purity` field, so I added `{"earth": 80}`.
- **Techniques:** `mountain-heart-canon` as the main method and `unbroken-flesh-canon` (body) as the auxiliary.
- **Arts:** `sinking-weight`, `bastion-reprisal`, `strata-hammer`, `bulwark-knuckle` and `last-breath-fist`, five in total.
- **Left out:** `mountain-stance` slows the basic attack by 40 percent and the engine would toggle it on cooldown, so I skipped it. `marrow-tithe-strike` is a health-paying art that doesn't fit the concept.
- **Realm file:** `bare-fist.ket-dan.fight.json` carries the same choices; all five arts unlock at layer 6 or below.

**Matchups** (`--matrix`, same-realm and one realm up):

| Matchup | Mean s | W-L |
|---|---|---|
| typical, Nguyên Anh | 9.0 | 20-0 |
| typical, Hóa Thần | 18.0 | 20-0 |
| top-end, Nguyên Anh | 6.4 | 0-20 |
| top-end, Hóa Thần | 2.8 | 0-20 |
| typical, Kết Đan file | 10.4 | 20-0 |

**Loss.** The old guide's claim of a Nguyên Anh race win against the top-end caster does not hold, and neither does its two-punch kill. The old file never carried Stored Breath, the basic-attack speed or the flat coefficient, so this isn't a clean library-versus-invented comparison.

**Identity tests** (typical foe, Nguyên Anh):
- **Removing `tech:mountain-heart-canon`:** 9.0 s before and after. Its passives have no engine stat, so they didn't run.
- **Removing `bastion-reprisal`:** 9.0 s becomes 10.7 s, so it carries real damage. At Hóa Thần the same removal takes 18.0 s to 26.7 s.

**NEVER_FIRED:** `bastion-reprisal` never fires against the top-end foe at Nguyên Anh. Against the top-end foe at Hóa Thần all five arts never fire, because the fight ends in 2.8 s.

**Losses from the move:**
- **Stored Breath:** it had no library equivalent.
- **Closed Hand Vow:** it is void now that damaging arts are slotted.
- **Other old Effects:** they were never fight-file fields, so they stay unmodelled.

The write-up is in `design/builds/engine-v2/bare-fist.md`. It has the piece table, technique reasoning, matchup table, the two `--without` tests and the unmodelled lines.

LIB-DONE design/builds/engine-v2/bare-fist.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/bare-fist.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/bare-fist.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/bare-fist.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/bare-fist.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/bare-fist.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/bare-fist.md) instead (Edit rules cover all file-editing tools).
```

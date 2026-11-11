# Job transcript: lib-soul-lance (try 1)

I rebuilt `soul-lance` from the library and fought it on engine v2. The old build had only a Nguyên Anh fight file, so there is no other-realm file.

- **Build:** main technique `hollow-bell-canon` (Water, tolling-bell-requiem and lamp-oil-lance) and auxiliary `undertow-litany` (seep-through-palm, marrow-to-dew, drag-of-the-deep). `mountain-splitting-thought` comes in as the common art of a generated common technique. That fills the six slots at Nguyên Anh.
- **Root:** the old file had no `purity`, so I set `{"water": 70}` from the guide's "single Water, purity 70+".
- **Lost:** Heart-Lamp Lance, Lamp-Threading Needle, Lamp-Light, Lantern Out, Bell of Waking and Ninth-Weight Lance have no library equivalent, nor do Lamp-Threading Scripture's divine sense and Still Flame passive.
- **Soul inputs:** the old file kept its soul numbers (`x_soul` 157, `divine_sense` 7800) only as UNMODELLED lines, so the engine runs on its defaults for them. That is the main reason the fights are slower than the guide's 4 s.

Fight results, Nguyên Anh file:

| Matchup | Mean s | W-L |
|---|---|---|
| typical, same realm | 21.7 | 20-0 |
| typical, one realm up | 30.7 | 20-0 |
| top_end, same realm | 15.9 | 0-20 |
| top_end, one realm up | 6.9 | 0-20 |

- **Fight length:** the same-realm fight is below the 30-60 s band, and the guide's 4 s kill does not reproduce.
- **Without `tech:hollow-bell-canon`:** 21.0 s at the same realm, 44.1 s one realm up.
- **Without tolling-bell-requiem** (I used it as the identity piece because the guide's real one, Thousand-Weight Thought, is not in the library): 56.5 s with 14 wins and 6 losses at the same realm.
- **NEVER_FIRED:** lamp-oil-lance and mountain-splitting-thought never fire in the full build. I did not find the cause. The file sets no `divine_sense`, and lamp-oil-lance is paid in divine sense, but that is unconfirmed.

I tuned no numbers and touched no other files.

LIB-DONE design/builds/engine-v2/soul-lance.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/soul-lance.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/soul-lance.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/soul-lance.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/soul-lance.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/soul-lance.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/soul-lance.md) instead (Edit rules cover all file-editing tools).
```

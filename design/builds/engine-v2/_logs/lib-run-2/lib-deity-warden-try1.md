# Job transcript: lib-deity-warden (try 1)

The rebuild is written and fought, but the build ends every fight almost immediately and its library arts barely fire.

**Build.** It keeps the old realm, purity (metal 80 / earth 70), layers, ward and body. The main method is `mountain-heart-canon`, with `iron-hide-manual` and `mountain-bone-body-art` as auxiliaries. That gives seven library arts at hoa_than.

**Slots.** The nguyen-anh file reported 7 arts in 6 slots. I dropped `mountain-root-stance` there, so that file differs from the hoa_than one by that art. I added the file's name myself: `deity-warden.nguyen-anh.fight.json`, after the old file, though the brief said `.<realm>.`

**Results (20 fights each).**

| Matchup | Mean s | W-L |
|---|---|---|
| hoa_than typical | 1.9 | 20-0 |
| hoa_than top_end | 4.7 | 20-0 |
| nguyen_anh typical | 1.9 | 20-0 |

All three are far below the 30-60 s band. Against the typical foe every art is NEVER_FIRED. Against the top-end foe `bastion-reprisal` and `strata-hammer` are NEVER_FIRED.

**`--without` tests.** Both gave no change, at typical and at top_end. I used `strata-hammer` as the identity piece, since the old identity pieces had no library equivalent. The `--without tech:mountain-heart-canon` run removes only that technique's passive; its arts stay loaded, so it was not a clean test of the whole technique.

**Lost.** The Lustral Bell and the Deaf Verdict have no usable library equivalent, and the phase script, ward swap and Open Hand are still unmodelled. The common arts Gate Hammer and Closing Palm were not carried. Five technique passives have no engine stat and did not run.

I could not delete a leftover helper script, `design/builds/engine-v2/_logs/mk_deity_warden.py`, because running or removing it needed an approval that was unavailable. It is unused, since I wrote the JSON files directly. Please delete it.

LIB-DONE design/builds/engine-v2/deity-warden.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/deity-warden.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/deity-warden.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/deity-warden.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/deity-warden.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/deity-warden.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/deity-warden.md) instead (Edit rules cover all file-editing tools).
```

# Job transcript: lib-home-fortress (try 1)

I stopped before building anything, because the old fight files for `home-fortress` don't exist. I didn't write `home-fortress.fight.json`, any realm file or `design/builds/engine-v2/home-fortress.md`, and I ran no fights.

Glob for `design/builds/overnight-2026-11-10/builds/home-fortress*.fight.json` returned nothing. A repo-wide `**/home-fortress*` Glob found only these four files:
- `design/builds/overnight-2026-11-10/builds/home-fortress.md`
- `design/builds/overnight-2026-11-10/builds/home-fortress.sheet.md`
- `design/builds/overnight-2026-11-10/_driver/home-fortress-try1.md`
- `design/builds/overnight-2026-11-10/_driver/home-fortress-try2.md`

Rule 1 says to keep the old build's layers, crit, ward, body, keystones, curses and non-art effects. The guide gives only rough figures: about ×235 damage at home, 407 ward strength, and L4 at about 310 points against a 150 cap. It doesn't give the numbers a fight file needs, such as the ward `payload` and layers, body layers, crit, `n_body`/`n_qi` or the effect records. Making those up would be tuning numbers (rule 5), and any matrix I ran on them would look like a result without being one.

The `.sheet.md` or the `_driver` try files might hold those numbers, but you told me to read nothing else, so I haven't opened them.

Two other points:
- **Realms:** the guide says Nascent Soul (`nguyen_anh`) is the defining realm. Which other realms had old fight files can't be recovered.
- **Library fit:** the INDEX has Earth techniques with an engine for this concept (`mountain-heart-canon`, main; `deep-vein-scripture`, secret; `mountain-bone-body-art`, body). I haven't verified the build's `purity` against them.

To unblock, any one of these is enough:
- Point me to the missing fight files (they may have been deleted or live under another name).
- Allow me to read `home-fortress.sheet.md` as the source of the layers, ward, body and crit.
- Tell me to build from the guide alone, with my own assumed numbers recorded as `unmodelled`.

Nothing was written, so the `LIB-DONE` line is deliberately absent.

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/home-fortress.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/home-fortress.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/home-fortress.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/home-fortress.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/home-fortress.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/home-fortress.md) instead (Edit rules cover all file-editing tools).
```

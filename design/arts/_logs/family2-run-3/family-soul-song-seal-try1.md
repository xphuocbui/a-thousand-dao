# Job transcript: family-soul-song-seal (try 1)

I wrote 8 authored arts in `design/arts/family-soul-song-seal.json` and the table in `design/arts/family-soul-song-seal.md`. The lint prints 0 findings (`checked 8 arts`), but I have not run any of them in a fight.

- **Standalone (3):** Marching Dirge (stance with a finale), Thorn Lullaby (healing as a weapon), and Blood-Ink Writ (health cost plus curses; new, no library source).
- **Engine (5):** Tolling Bell Requiem (Toll counter and echoes), Lamp-Oil Lance (paid in divine sense), Ambush Talisman (held payload), Frozen Hour Seal (Slowed Time) and Branding Seal (conversion).
- **Suites:** the Bell and Lance share `hollow-bell-canon`. Ambush, Frozen Hour and Branding share `nine-seal-ledger` and a Seal counter. The two suites cross, since Branding wants the Slackened Soul the Lance lays.
- **Feeding routes:** every engine art has at least 3 routes, joined by OR-guards. The `.md` lists them per art.
- **Payoff:** Frozen Hour, Branding and Ambush's second step reach about 3.4–3.6x the lint. Ambush's first step is only 1.5x on its coefficient, plus three more free hits from its banked talismans.
- **Soul arts:** the Bell and Lance have a coefficient of 0, so the lint cannot measure them. Their payoff comes from heavy `free_hit` strikes in `pay` (3.0, 7.0 and 3.5 Soul coefficient), which I estimate at 3–6x a plain soul art, not measured.

Things the engine could not express, all named in the `.md`:
- **Soul override:** a step or empower cannot override `soul_pct`, so the soul arts cannot use `c_mult`.
- **Trigger budget:** `pay` free hits share the trigger budget, so a big Peal may be clipped.
- **Health cost:** `hp_cost` is charged on top of the linh lực cost; a form that replaces part of that cost is missing.
- **Passed lint, not run:** Blood-Ink's per-status `dmg_more` bonus, `foe.qi_share` as the foe-dry readable, and the Dirge toggle ordering.

FAMILY-DONE design/arts/family-soul-song-seal.json

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/arts/family-soul-song-seal.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-soul-song-seal.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/arts/family-soul-song-seal.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/arts/family-soul-song-seal.md) instead (Edit rules cover all file-editing tools).
```

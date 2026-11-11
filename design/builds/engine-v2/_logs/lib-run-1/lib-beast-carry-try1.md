# Job transcript: lib-beast-carry (try 1)

I rebuilt `beast-carry` as a nguyên anh file, but the fights are degenerate (1–2 s) and tell us nothing about balance.

**No old fight files.** `beast-carry*.fight.json` doesn't exist anywhere under `design/builds`, and the guide says no simulator was used. I took the layers from the guide's multipliers (332, 300, 250, 110, 89), set crit to 0 and art speed to +100, and left `ward` and `body` at the realm default. That is a reconstruction. Only one file exists, since there was no other realm file to rebuild.

**What I chose:**
- **Main technique:** `verdant-cycle-scripture`, carrying `second-spring` at layer 4.
- **Auxiliary technique:** `ashen-phoenix-canon`, taken for its passives only, because all its arts hit the enemy.
- **Common art:** `warm-the-hearth` stands in for Feed the Fire. It hits, which the Contract's "no art that hits" rule forbids; the engine doesn't enforce that.
- **Lost:**
  - Straining Leash, the identity piece.
  - The Shared-Heart Contract's beast health bar.
  - Bonded Spirit feeding the beast's timers.
  - Sure Bite, Roused, Pack Hunt, Marked Prey and Rain on Both.
  - Hearth Song, Whistle In, Bark Mantle and Rouse.

**Results:**

| Matchup | Mean s | W-L |
|---|---|---|
| typical nguyên anh | 1.0 | 20-0 |
| typical hóa thần+1 | 2.0 | 20-0 |
| top_end nguyên anh | 1.4 | 0-20 |
| top_end hóa thần+1 | 1.0 | 0-20 |

- **Fight length:** typical fights are 1–2 s against the 30–60 s band, and the top_end foe wins in 1–1.4 s.
- **`--without` tests:** `tech:verdant-cycle-scripture` and `warm-the-hearth` both changed nothing. Straining Leash isn't modelled, so I used the art id as the identity test.
- **NEVER_FIRED:** both arts, in every matchup, because the fight ends before their first timer.
- **Guide claims:** none can be confirmed or refuted from these runs.

The matchup table in `beast-carry.md` has no real Clipped values, because fight.py didn't print a Clipped figure.

Files are in `design/builds/engine-v2/`:
- `builds/beast-carry.fight.json`
- `beast-carry.md`

LIB-DONE design/builds/engine-v2/beast-carry.md

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/beast-carry.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/beast-carry.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/builds/beast-carry.*.fight.json) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/builds/beast-carry.*.fight.json) instead (Edit rules cover all file-editing tools).
Permission allow rule (--allowed-tools): Write(design/builds/engine-v2/beast-carry.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v2/beast-carry.md) instead (Edit rules cover all file-editing tools).
```

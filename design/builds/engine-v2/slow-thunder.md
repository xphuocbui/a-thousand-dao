# The Slow Thunder (Trì Lôi) — engine v2 rebuild: NOT RUN

**Status: blocked, nothing was rebuilt and no fight was run.**

## Why

The brief says to keep the build's realm, root (`purity`), layers, crit, ward, body, keystones and curses from its old
fight files, which it names as `design/builds/overnight-2026-11-10/builds/slow-thunder*.fight.json`.

- Globbing that pattern returned nothing.
- A wider glob (`design/builds/**/slow-thunder*`) found only `slow-thunder.md`, `slow-thunder.sheet.md` and
  `_driver/slow-thunder-try1.md`.
- A glob for `**/slow-thunder*.json` found nothing.
- The other 38 builds in that folder have `.fight.json` files; slow-thunder has none.

So the numbers rule 1 says to keep were never written down as a fight input.

The guide gives targets (regen about +5 points, slow-art cost -40 %, Long Fuse and Heavy Sky filling L2 to 300,
crit cap 50 % and x3.0, art speed +80), but not the layer totals, ward record, body, keystones or `purity` values
a fight file needs. Guessing them would be tuning, which rule 5 forbids, and would make every result below a
statement about my numbers, not about the build. The brief also limits me to four named files, so I did not read
`slow-thunder.sheet.md`, which may hold the numbers.

Nothing else was written. No `.fight.json` exists in `design/builds/engine-v2/builds/` for this build, and no
`--matrix` or `--without` run was made. Every table the brief asks for (old piece to library piece, matchups,
`--without` tests, UNMODELLED lines, observations) is therefore **not assessed**.

## Observation from the guide and the index (not a build)

- The build's identity piece, Thunderhead (`thunderhead`), is a staged Effect, not a library art. Its four arts
  (Far Flash, Thaw Rumble, Rolling Peal, Ice-Breaking Peal) are staged too. Only `rolling-peal` exists in the
  library, as a common thunder art, and no library art or technique matches Thunderhead.
- The nearest catalogue main technique for a thunder root is `thousand-bolt-scripture` (Yellow main, `loi`).
  `heavenly-tribulation-scripture` (Heaven main, `loi`) is the other. Neither carries slow, cheap arts or an
  overflow-read engine. The loss would be the guide's whole premise: 2 % cost, 12 s arts that catch a full
  pool's regeneration.
- This is a guess from the index only, and nothing was run to check it.

## To unblock

Either point me at the old fight input (for example `slow-thunder.sheet.md`, or the numbers inside
`_driver/slow-thunder-try1.md`), or say that I may take the typical-anchor defaults and the guide's targets as the
layers, ward, body and `purity`. I will then do the rebuild and the runs.

LIB-BLOCKED design/builds/engine-v2/slow-thunder.md

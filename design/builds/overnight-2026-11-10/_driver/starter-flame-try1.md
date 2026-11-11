# Session transcript: starter-flame-try1

> Final message of one headless `claude -p` session.

The Hearth Keeper (Thủ Lô Hỏa Giả) is designed and all six files are written. It is a Fire caster that burns the enemy and refills its own linh lực from the Burn ticks. 7 checks pass, none fail, and 2 are NOT ASSESSED (below).

I chose this direction myself. The other directions (a big-hit Bonfire, an alchemy-heavy Furnace Master, a one-big-hit Last Blaze) are recorded in the sheet. In short, the first runs dry, the second needs alchemy a new player does not have, and the third punishes mistakes.

**Build:**
- **Root and technique:** Fire root at about 70 purity, with Xích Diễm Địa Quyết as the main công pháp (in the game today).
- **Arts:** four cheap Fire arts (Spark Palm, Kindling Seal, Flame Lance, Warm the Hearth). The fifth slot at Kết Đan is left free for the player's own fix.
- **Enabler:** Embers Feed the Hearth returns 25 % of each Burn tick as linh lực. It costs 15 % of your direct Fire hits.
- **Layers:** the existing Kindled Wound Effect fills L5, and the sheet covers L1 to L5 by Kết Đan.
- **Sacrifice:** crit and pierce, both ones a first build doesn't need.

**Fight results** (simulator, 20 seeds):
- **Same-realm typical fight:** 20 wins, 0 losses, about 22 s, never dry, 55 % health left. That is a little short of the 30–60 s band, which I accepted for a starter.
- **Against stronger foes:** it loses to a foe one realm up (about 7 s) and to a top-end foe (1.6 s), as any ordinary build does.
- **Identity test:** the simulator can't remove Embers directly, so I removed its approximation (`regen_bonus_pp`). Typical wins dropped from 20 to 4.

**NOT ASSESSED checks:**
- **Budgets:** the arts are inside the lint, but I did not compute the technique's budget.
- **The fight:** Embers is the engine and is unmodelled. I ran it as an approximation (`regen_bonus_pp` and `gain_on_hit_pct`). The sheet lists everything the simulator could not model.

**Staged and suggested:**
- **Staged new:** 9 pieces (the Fire primer, four arts, Ember Rod, pill, formation and a cluster idea).
- **Reused:** 6 pieces.
- **Suggestion:** one, adding an Effects action "restore linh lực" on a Burn tick, which Embers needs.
- **Not touched:** no shared files were edited, and I ran no git commands and no Python other than `fight.py`.

Files are in `design/builds/overnight-2026-11-10/builds/`:
- `starter-flame.md`
- `starter-flame.sheet.md`
- `starter-flame.fight.json`
- `starter-flame.staging.md`
- `starter-flame.suggestions.md`
- `starter-flame.ledger.md`

BUILD-RESULT: slug=starter-flame status=DONE staged_new=9 staged_reused=6 suggestions=1 checks_fail=0 checks_na=2

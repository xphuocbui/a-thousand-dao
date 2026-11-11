# Session transcript: one-art-try1

> Final message of one headless `claude -p` session.

I designed the build **The Empty Hall (Không Đường)**. It carries one art, the largest the rules allow, and leaves every other art slot empty on purpose. The sheet and the player guide are written, and the shared files are updated. As instructed, there was no simulator, so the fight check and the identity test are NOT ASSESSED; every other check passes when read against the rules.

**What the one art has to be.** The rules size an art by its cost and its written cooldown. Art speed then shortens the cooldown but doesn't shrink the art. So the one art is the largest legal art: the Grindstone Stroke (Ma Thạch Trảm), costing 12.5 % of linh lực, with a 12 s cooldown and a coefficient of 6.75 (a typical art is about 1.6). Every empty slot then pays for it:
- **Speed (Clear Path):** +40 % art speed per empty slot. At Deity Transformation (Hóa Thần) the 12 s art fires every 2.5 s, and the first one at 1.56 s.
- **Size (Vow of the One Stroke, the enabler):** +0.4 coefficient per empty slot, past the normal limit, so 6.75 becomes 9.55. In exchange you can never slot a second art, a talisman, an escape art, or a ward in an art slot.
- **Damage (Undivided):** +10 points per empty slot in the Effects layer, up to +70.
- **Fuel (Quiet Channels, reused):** extra linh lực regeneration per empty slot. The art spends about half of regeneration in every realm, so the pool stays high and the free ward slots (up to six) hold all fight.
- **Identity (Empty Hall):** when the art lands, each empty slot rings once with a free echo that lays a Metal debuff stack. That is about +31 % Physical damage taken at Hóa Thần. The seventh ring is dropped by the game's trigger cap (6 per second), which is the signature moment.

**Shape.** Single Metal (Kim) root at purity 90+. The Way is the catalogue's Đại Đạo, "The Great Way Is Simple": its capstone gives one more art slot, which this build leaves empty. The technique is the Whetstone Scripture (Ma Thạch Kinh), which teaches exactly one art; I wrote a Địa giai copy and a Thiên giai copy for Hóa Thần. The build is beaten by:
- **Silencers:** a curse that blocks the sword tag stops the only art, and the Vow forbids the cleanse art that would fix it.
- **Evaders:** one dodged stroke wastes a whole 2.5 s cycle.

**Things I found while checking:**
- **Measured Stroke can never apply.** It needs a written cooldown of 20 s or more, but cooldowns have been capped at 12 s since the economy revision (#44). I proposed lowering the threshold to 10 s.
- **"Empty art slot" means two things.** Bare Rack and the Quiet Channels row (staged by bare-fist) count it differently; I proposed one meaning.
- **Sealed clusters no longer exist.** They were retired on 2026-11-10 (cong-phap.md rule 15). I first used them, then rewrote my cluster as a region idea for the tree rework.
- **A near-twin piece already exists.** Empty Hall closely mirrors Garrison Mind, staged by another session's armoury-mind build. Both share the same trigger cap, which I noted on its row.

**Shared files.**
- **Staging catalogue:** 12 new rows, and "one-art" added to the Used by cell of 6 existing rows.
- **Run ledger:** rows for the build, its pieces and its concepts.
- **Suggestions:** 3 entries (the art-size limit change, the Measured Stroke threshold, and the empty-slot meaning).

Files are in `design/builds/overnight-2026-11-10/builds/`:
- `one-art.sheet.md`
- `one-art.md`

BUILD-RESULT: slug=one-art status=DONE staged_new=12 staged_reused=6 suggestions=3 checks_fail=0 checks_na=2

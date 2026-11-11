# Fix: overlaps (five user decisions, 2026-11-11)

All numbers are first guesses.

## 63-ky.md
- Build direction 2 (Talisman Brush): now talisman crafting; fight use of talismans goes to Trận (decision 2).
- Facet 2 Họa Phù: small lines, stat notables and minors changed from talisman power to crafting success, ink, crafting speed.
- Facet 2 major Talisman Sleeve removed (moved to Trận); replaced by Master Inkmaker (quality step, failed draw returns half ink; crafting only).
- Minor Quick Release removed (a combat piece; also the review's no-op); replaced by Quick Brush (drawing 20 % faster).
- Facet 4 major Folding Array: now "formations laid in half the time" (never under 1 s); no ground in unprepared fights (decision 1).
- Facet 5 major Stones as Fuel: rate set (stones per 1 % max linh lực: Luyện Khí 1, Trúc Cơ 3, Kim Đan 10, Nguyên Anh 30, Hóa Thần 100); close: artifact actives paid in stones fire 25 % slower (decision 5).
- Capstone Hundred Talismans replaced by Hands Stained with Ink (+2 copies per draw, certain quality chance; closes: double ink per draw).
- New pieces: dropped the `free_slots[talisman]` line. Kept apart from: Trận now owns talisman builds and carried ground.

## 65-tran-dao.md
- Facet 3 major Talisman Barrage: now also carries the Talisman Sleeve (two slotted talismans take no art slot), moved from Kỹ; one major per facet kept.
- Capstone A Formation within the Body: stated as the Dao's carried-ground source (R9 shares; away from home one formation counts, the stronger) (decision 1).
- Capstone Ten Thousand Talismans: also widens the Sleeve to 4 talismans (replaces Kỹ's Hundred Talismans).
- Kept apart from: Kỹ crafts only, Họa adds tags only, Trận owns carried formations and talisman builds.

## 66-hoa-painting.md
- Facet 2 major Unroll the Landscape: ground tags only, no formation strength in unprepared fights; removed the painted-formations clause (decision 1).
- Kept apart from: Kỹ's Họa Phù is crafting; Trận owns the carried formation.

## 86-thien.md
- Facet 4 major Rewrite a Law replaced by Black-Letter Law (own curses on the foe cannot be cleansed for 2 pulses and ignore 25 pp of its status resist; `Needs rule`, cleanse lock).
- New capstone Rewrite a Law (keystone): one constant shifted 10 % in your favour, Thiên's one cap shift (R14); close: your hits deal 15 % less (L2 −15) (decision 3).
- Heaven Has No Favourites (layer write, R15d) unchanged.
- New pieces: updated the R14 note.

## 85-nghich.md
- Against the Current: text states it reads the gap to the foe now, not damage taken (decision 4). Numbers unchanged.

## 91-han.md
- Vengeance: counts only the grudge target's own hits (no companion, ticks, reflected or ally damage); no net-of-healing; cap +25 kept (decision 4).

## 87-kiep.md
- Calamity Qi: stacks now come from events survived (tribulation wave or bolt, near-death below 25 %, Down refusal), not health lost; cap 9 kept.
- Capstone Calamity Incarnate: "2 stacks per event (cap 18)" in place of "per 5 % lost".
- Build direction 4 and Kept apart from updated to match.

## Open
- Kiếp's near-death and event counts are not tuned. Black-Letter Law needs a cleanse-lock rule. Rewrite a Law's list of constants is unchanged from the old major.
- `compile_index.py` was not rerun.

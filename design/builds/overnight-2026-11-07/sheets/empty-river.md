# The Empty River (Không Giang Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "A hermit of a single place (seed 72): ground bound, strong only at home, and the home is something strange, not a mountain cave. What does the world do about someone who cannot leave?"
> **Direction**: The home is a painting, so it can be bought. The world's answer is that it sells them, and every owner stamps a seal on their sky. Inside, each brushstroke pushes the visitor one step further down the picture, and they get smaller: hits, health and pool together. The forced push cut a kit of varied landscape strokes, which the Blank could not pay for, and made the paper itself the budget.
> **Realm span**: Nascent Soul – Deity Transformation tested, defined at Deity Transformation · **Power level**: strong at home, nothing elsewhere · **Use**: player build, or a treasure a sect owns
> **Fit**: 5 Fits today · 7 Needs key · 4 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: the Way of Space tree is not linted)

## The Spine

- **The channel:** big ink strokes and a signature, on a target who shrinks.
- **The enabler:** the scroll Empty River (Không Giang Đồ). It opens the Blank (Lưu Bạch), paper that pays for strokes in place of linh lực. It closes the door: you live in it, so no road, no market, no sect and no fight you did not get.
- **The keystone:** Far Distance (Viễn Cảnh), Way of Space. Each point of ink makes the target 1.2 % smaller.
- **The loop:** three Splashed Inks in three seconds, a dry line with what is left, then sign.
- **The engine:** size scales their hits, their health and their pool together. Their bars keep their shares, but your hits are measured against a smaller body, and their ward's drain is a fixed size against a smaller sea. A Wall on a 200 ward has no pool left by 6 s.
- **The sacrifice:** everything outside the frame. The Blank is one budget for the fight, and every seal comes out of it.
- **The arc:** at Nascent Soul two seals. By Deity, the world keeps offering a third, and it is a trap.

## The Legend

Hermit Tịch lives in a thatched hut at the lower left of a hanging scroll called Empty River, and has done since a painter put them there to give the mountains scale. Tịch holds that the painting is the world, that our world is a stain on the back of it, and that visitors are poorly drawn. Eleven owners have stamped it. Tịch's almanac records each seal as a new red sun, notes the inconvenience, and predicts no more. A monastery once hung the scroll face to the wall for sixty years. Tịch has written this up as the Long Night, and blames the visitors.

What does the world do about someone who cannot leave? It buys them. Sects pay a province for the scroll, hang it in the treasury and unroll it for thieves. Whoever walks in meets a cheerful old figure with a wet brush and a lecture on perspective, and by the third stroke is a dot on a far path. They come out a hand high, and it takes a season to grow back. Forgers sell copies in every market. Each new owner wants their own seal on it, and each seal is one more sun over the only river Tịch has to paint on. Tịch is the one person in the world who does not know they are for sale.

## How It Fights

Splashed Ink lands at 1 s and the visitor is 70 % of themselves, 49 % at 2 s, 34 % at 3 s. A Dry Brush spends the last of the paper and the Signature starts, stronger for every point painted. An ordinary visitor is gone at 3 s. A Wall loses its pool by 6 s and is finished at 12 s.

**The signature moment:** a Wall with `ws` 200 and twice the pool, at 32 % of its size, signed for (`variants/empty-river-wall.fight.json`).

## Enabler

**Empty River (Không Giang Đồ).** A named artifact, and not one you equip: it takes no slot and no thần thức, because it is the ground. Paper 100. Ink fades by 5 Blank a season, so a full fight costs four years. **A character can only reach it by being painted in,** a rare event, and it closes every system that needs you to go somewhere.

## The Stack

Sizes are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Identity | **Far Distance (Viễn Cảnh)** | An art with the ink tag makes the target smaller by 1 % per point of ink, to 20 %, times your thần thức over theirs at most 1. Size scales fight unit, health and linh lực | Rule swap | art | none | ○ | Way keystone | The Brush Fee, The Spring Hand: any ink art |
| Fuel | **The Blank (Lưu Bạch)** | Ink arts are paid in paper at 100 points per share of cost, never in linh lực. It does not return in a fight | Rule swap | art | none | ○ | Artifact | any finite prepared resource |
| Multiplier | **Collector's Seal (Tàng Ấn)** | Each seal takes Blank and adds points to one layer for every hit inside. Elder: 8 Blank, L4 30. Minister: 12 Blank, L2 40 | Trade | any | L2, L4 | ○ | Artifact | any owned ground |
| Rate | **Deep Perspective (Thâm Viễn)** | +0.1 % smaller per point of ink, taken twice | Increased | art | none | ○ | Way passive | any ink art |
| Past the cap | **Signed and Dated (Lạc Khoản Niên)** | +1 L2 on the Signature per point of Blank painted | Per | art | L2 | ○ | Way passive | any finishing art that reads a spent pool |
| Multiplier | Damage (`attack_pct`) | L1 200, the soft cap | Increased | any | L1 | ● | Tree | every build |
| Survival | Maximum health, Maximum linh lực, Ward strength, Ward efficiency | 348, 150, 180 and 180 W | Increased | any | none | ● | Tree | every build |

**Identity piece:** Far Distance and the Blank, a pair, so `--without far_distance` removes both. Mixed then wins at 5 s, on 75 %, and the Wall at 12 s, on 94 %. That file is also the honest picture of this hermit outside the frame: it loses all of them.
**Empty rungs:** crit past the base, L3 and L5. L3 is the point: gear is for people who go places.

**W:** 1,058 of Deity's 1,172 in the file, with 114 unspent. A hermit has no travel, trade or farming to buy, so the half a typical life spends outside fights comes here. That is the build's quiet power, and it is why a forgery still wins.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Water, purity 40 or more | Way of Space needs it |
| Main method | One Ladle Rule, reused | Water, and nothing else matters |
| Ward | Common ward, `ws` 180, `we` 180 | The pool pays for nothing else, so it is all ward |

## Arts

| Art | Source | Kind, tags | c_art | Blank or cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Splashed Ink (Bát Mặc) | Scroll | qi, ink | 4.0 | 25 Blank | 1 s | | Needs key |
| Dry Brush (Can Bút) | Scroll | body, ink | 2.35 | 5 Blank | 4 s | | Needs key |
| Signature (Lạc Khoản) | Scroll | qi | 2.1 | 0.05 linh lực | 3 s | 9 Blank or fewer | Needs key |

Three of 7 slots: the Blank cannot pay for more. Costs are authored as shares so the lint reads them.

## Đạo

**Way of Space (Không Gian Đạo).** A seed in Dao rule 2 with no tree yet. **Requirement:** Water at purity 40. **`theme_stats`:** `travel_speed_pct`, `than_thuc_pct`, `evade_pct`, `linh_luc_regen_pct`. **Branches:** The Near Bank (Cận Ngạn), the road you can walk. The Middle Reach (Trung Lưu), what lies between you and a thing. The Far Bank (Viễn Ngạn), holding Deep Perspective twice and Signed and Dated. **Keystone:** Far Distance. No art nodes, under rule 3. The rest of the tree is not written out, and it is not linted.

## Matchups

Files are `variants/empty-river-[name].fight.json`.

| Enemy | Result | File |
|---|---|---|
| **Panel: 5 of 5** | Mixed and Evader 3 s on 90 %, Fast 3 s on 78 %, Pulse 4 s on 88 %, Wall 12 s on 88 % | `mixed`, `evader`, `fast`, `pulse`, `wall` |
| One cheap art | 3 s on 91 % | `cheap` |
| Top-end | Loses at 1 s, enemy on 98 % | `top-end` |
| Nascent Soul version | Mixed 3 s on 87 %, Wall 12 s on 82 % | `nascent`, `nascent-wall` |
| **A forgery: no seals, half the shrink** | Mixed 4 s on 82 %, Pulse 10 s on 63 %, Wall 37 s on 39 % | `forgery-mixed`, `-pulse`, `-wall` |
| A Wall that sees twice as far | 21 s on 60 % | `sight2-wall` |
| **A Wall that sees four times as far** | **Loses at 32 s, enemy on 42 %** | `sight4-wall` |
| Every enemy art burns 20 Blank | 3 s on 88 % | `fire` |

**What the seals do.** This is the choice the world hands the hermit.

| Seals | Blank | Pulse | Wall | Files |
|---|---|---|---|---|
| None | 100 | 7 s on 83 % | 15 s on 87 % | `no-seals-` |
| **Elder, Minister** | **80** | **4 s on 88 %** | **12 s on 88 %** | `pulse`, `wall` |
| + Abbot's poem, 6 Blank, L5 15 | 74 | 8 s on 73 % | 18 s on 74 % | `three-seals-` |
| + the Great Seal, 30 Blank, L2 100 | 44 | 7 s on 67 % | 14 s on 72 % | `four-seals-` |

**The surprise is a cliff.** Splashed Ink costs 25. At 80 Blank you get three and a Dry Brush. A pretty six-point poem takes you to 74, you get two, and everything doubles. So the hermit's whole life comes down to one sum: 25 Blank of seals is free and 26 is a catastrophe. An emperor's gift can be a siege.

**Fire was the counter I expected, and it is not.** The paper is spent by 3 s, so burning it costs the fight nothing (`fire`). The real counter is sight.

**The other two rows.** Deep Perspective is the Wall at 12 s against 14 s (`no-perspective-wall`), Signed and Dated 12 s against 14 s (`no-signed-wall`). Modest, as rows should be.

**The fine line loses.** The slow strokes I wanted, a peak, a river, a pine, are worse everywhere: Mixed 4 s on 78 %, Pulse 6 s on 70 %, Wall 15 s on 77 %, Fast 4 s on 50 % (`fine-line-`). Size is bought per point of ink, so the biggest stroke first is simply correct. This is the campaign's kit question at the other end of the cost line, and the theme lost.

**Home.** A forgery wins all three runs, slower. That is the 1,058 W doing it, not the copy. A true fight outside the frame is the `--without` run above. Whether a forger's half-shrink is too kind is a question for the user.

**Counter:** a top-end, which ends it at 1 s, and anyone with four times the sight and a good ward. Outside the fight: the owner, who can roll you up.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Arts inside the lint, 3 of 7 slots, 1,058 W. Way of Space is a sketch of one branch and a keystone, not linted |
| Validity | PASS | Ward inside caps. `blank_cost` reads authored shares |
| Stack | PASS | Four forms: Rule swap, Trade, Increased, Per. `--without` changes every fight |
| Scaling | PASS | `m_static` 3.00 before seals, against 8.96 |
| The fight | PASS | Runs on `rules/far_distance.py`. The Blank is paid in slot order, so a stroke cannot overdraw it |
| Reuse | PASS | One Ladle Rule. Far Distance has two named second homes |
| NPC use | PASS | Rare by design: an NPC can be painted in too, and a sect can own one |
| Counterplay | PASS | `sight4-wall`, `top-end` |
| Originality | PASS | A hermit in a painting is a common image. Names checked |

## Fight Results

Input: `sheets/empty-river.fight.json`, through `_tools/fight_x.py`, `--matrix`. A paper model. Deity has no realm above it, so the gap rows repeat.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0, 1, 2 | Win on 90 % | 3 s | never | |
| top_end | 0, 1, 2 | Loss, enemy 98 % | 1 s | 1 s | |

**Unmodelled:** Blank fading, owners and figures on the road are outside the fight. The owner's seals are chosen in the file, though in the world they are not the hermit's choice.

## New Concepts

**Size (Tỉ Lệ).** A fight value on a side that scales its fight unit and both pools. A new rule beside Combat rule 3, bounded at 20 %. Breakdown line: "Far Distance: this target is at 49 % of its size." It serves The Brush Fee and The Spring Hand, whose arts are ink. **Question for the user:** is it too strong a rule to leave on a keystone, and should a target recover it after the fight? The sheet says a season.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Far Distance, Size | Needs rule | Above |
| The Blank, Collector's Seal | Needs rule | A paper resource and seals that spend it. Combat rule 11 |
| Empty River | Needs rule | A home that is an artifact, and a rare event that paints you in |
| Deep Perspective, Signed and Dated, three arts, Way of Space, One Ladle Rule | Needs key | `ink` tag, `blank`, a shrink key, one tree |

## Also Considered

- **Low Tide:** a hermit on a sandbar that exists for 40 s a day. A fine clock, but it is The Fortieth Breath with salt.
- **The Gourd:** a hermit in a gourd on someone else's belt, so the home goes to the fight. The scroll does the same job, and keeps the seals.

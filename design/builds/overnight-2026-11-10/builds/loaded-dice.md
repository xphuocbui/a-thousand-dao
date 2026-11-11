# The Loaded Dice (Quán Cốt)

A gambler's build where every chance is a visible meter, and your luck (khí vận) is loaded into the meters before the fight starts.

## Why it works

Normally a crit is a die roll. Here the roll is replaced by a meter (the Called Blow Effect): each hit adds your crit chance to it, and at 1.0 the hit crits. With a 0.30 chance you crit on exactly every third to fourth hit, and it never varies. The fight is swingy, because the crits come in a rhythm and the big ones land together, but nothing is random, so you can plan it.

Your luck is what loads the dice. The Loaded Table adds 0.002 to every meter per point of khí vận, up to +0.15, so 75 khí vận fills the meter 15 points faster. You raise khí vận at home: the Ledger-Bone Dice (+15), the Nine-Star Array (+20 in the fight), a Sparrow-Luck Pill (+15), on top of a base of about 25. Every third crit is a Jackpot (+1.0 crit multiplier, so a 2.0 crit becomes a 3.0, the cap). Payouts also pay back linh lực (Winnings) and build damage (Stacked Meter, +2 % per payout, up to +20 %).

Key numbers (first guesses): crit chance 0.30 at Kết Đan, 0.40 at Nguyên Anh; crit multiplier 2.0 to 2.2, cap 3.0; Called Blow cap 0.35 before fortune; the global crit cap is 0.5.

## What to look for

| Piece | Where | Status |
|---|---|---|
| Spiritual root (linh căn) | Thunder (Lôi), convergence of Fire and Metal, purity 80 or more | in the game |
| Talents | High khí vận (fortune), Comprehension | in the game |
| Đạo | Mệnh Đạo: Called Blow, Open Book, Tally Keeper, House Edge, Spilled Luck, Jackpot, The Loaded Table | Mệnh Đạo is in the game; Called Blow is designed in the Effects GDD; the other nodes are not in the game yet (staged: open-book, tally-keeper, house-edge, spilled-luck-node, jackpot-capstone-notable, loaded-table-capstone) |
| Công pháp | Nine-Bone Ledger Sutra (Cửu Cốt Toán Kinh), Địa giai | not in the game yet (staged: nine-bone-ledger-sutra) |
| Arts | Cast the Bones, Counting Blade, Thunder Debt, Winnings, Raise the Stakes, House Takes All | not in the game yet (staged: the six art ids) |
| Items | Ledger-Bone Dice, Nine-Star Array, Borrowed Luck Talisman, Sparrow-Luck Pill | not in the game yet (staged: ledger-bone-dice, nine-star-array, borrowed-luck-talisman, sparrow-pill) |
| Enabler | The Loaded Table (Quán Bàn) | not in the game yet (staged: loaded-table) |

## The enabling Effects

- **Called Blow (Báo Chiêu):** your crit is counted on a meter, not rolled. The build needs it because every other piece reads the meter. It costs you: the crit chance cap falls from 0.50 to 0.35 (before fortune).
- **The Loaded Table (Quán Bàn):** your evade is counted too, and khí vận adds up to +0.15 to every meter. Needed because it turns the stat nobody uses in a fight into the engine. It costs you: no escape art, ever, and fortune no longer helps any rolled chance.
- **Jackpot (Đại Phát):** every third crit payout adds 1.0 to that hit's crit multiplier. This is the screenshot moment.
- **Cash Out (Thu Bàn):** House Takes All spends the crit meter if it reads 0.6 or more, so you choose when the payout lands.
- **Flowing Water (Lưu Thủy):** a crit shortens your other arts' timers by 0.5 s, so payouts speed up the next payout.

## Modifiers to stack

1. **Crit chance** (tree, Sutra +6 %): the sum the meter counts. Layer: crit. Stop at 0.35 before fortune; above that Spilled Luck turns it into crit multiplier.
2. **Khí vận** (talent, dice, array, pill): the fill. Stop at 75 points; the feed is capped at +0.15.
3. **Crit damage:** payout size. Stop when a normal crit sits near 2.0 so Jackpot has room to the 3.0 cap.
4. **Attack (L1):** the everyday layer; returns fall past +200.
5. **Art damage and Stacked Meter (L2):** Stacked Meter caps at +20 %.
6. **Linh lực regained on a crit, regeneration, cost reduction:** fuel; keep the pool from ever running dry.
7. **Dice and array (L3, L4):** your gear and preparation layers.
8. **Spilled Luck:** only once the crit sum passes 0.35.
9. **Thunder debuff stacks (Thunder Debt):** raise crit damage taken; more stacks help until the stack cap.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Called Blow | Effect | Makes the crit a counted meter | Mệnh Đạo, Định Mệnh branch | Designed in Effects GDD | core |
| The Loaded Table | Effect (enabler) | Fortune fills the meters, counted evade | Mệnh Đạo capstone | staged: loaded-table | core |
| Khí vận | Modifier | Meter fill | Talent, tree small nodes, kỳ ngộ events | in the game (stat) | core |
| Crit chance | Modifier | The meter's raw rate | Tree notables, Sutra | in the game | core |
| Crit damage | Modifier | Payout size | Tree notables, Ledger-Bone Dice | in the game | core |
| Ledger-Bone Dice | Item (affix: khí vận, Loaded Start) | +15 khí vận, meters start half full | Named artifact, a bookkeeper's grave | staged: ledger-bone-dice | core |
| Jackpot | Effect | Big spike every ninth hit | Mệnh Đạo notable | staged: jackpot | strong |
| Linh lực regained on a crit | Modifier | Sustain through payouts | Sutra, tree notable | tree catalogue (new key) | strong |
| Flowing Water | Effect | Payouts shorten timers | Mệnh Đạo notable | tree catalogue | strong |
| Stacked Meter | Modifier | Up to +20 % art damage | Tally Keeper node, Gambler's Row cluster | staged: stacked-meter | strong |
| Nine-Star Array | Formation | +20 khí vận | Formation master | staged: nine-star-array | strong |
| Sparrow-Luck Pill | Pill | +15 khí vận for a fight | Alchemy | staged: sparrow-pill | strong |
| Loaded Start | Modifier | First payout comes early | House Edge node, dice | staged: loaded-start | nice |
| Spilled Luck | Modifier (Overflow) | Crit chance past the cap becomes crit multiplier | Khí Vận branch | staged: spilled-luck | strong |
| Cash Out (House Takes All) | Effect, art | Timing the payout | Sutra layer 12 | staged: cash-out, house-takes-all | strong |
| Borrowed Luck Talisman | Talisman | +12 khí vận for 30 s | Talisman maker | staged: borrowed-luck-talisman | nice |
| Art damage | Modifier | L2 more | Tree | tree catalogue | nice |
| Soul resistance, status resistance | Modifier | Covers the soul and curse gaps | Tree, ward gear | in the game | strong (top-end) |
| Realm pierce, accuracy | Modifier | Reach upward at Nguyên Anh | Tree | in the game | nice |
| Counted evade | Effect | Dodges every Nth hit with no roll | The Loaded Table | staged: loaded-table | core |

## Realm by realm

- **Trúc Cơ (4 slots):** Called Blow and Cast the Bones. A crit every third hit. No evade meter yet. Ordinary power.
- **Kết Đan (5 slots):** The Loaded Table opens, you add the dice and the array, Jackpot arrives. Roughly 17 s to beat a typical same-realm foe in the simulator.
- **Nguyên Anh (6 slots):** Spilled Luck and House Takes All. You pick when the meter pays. Beats a typical same-realm foe in about 12 s, but your linh lực runs dry near 9 s in the test, so sustain gear matters here.

## How it plays

Slot order: Cast the Bones first (fast, fills the meters), Counting Blade, Thunder Debt (applies the crit-taken stacks), Winnings (refund), Raise the Stakes (the slow big hit), and at Nguyên Anh House Takes All last. Load at home: wear the dice, light the array, take the pill, so the meters start half full. The signature moment: the crit meter reads 0.9, the Jackpot counter reads 2 of 3, and House Takes All cashes both in one hit.

## What beats it

- **An Ill Star curser (Mệnh Đạo):** cuts your khí vận, so the feed falls. Cleanse the curse, carry spare fortune (talisman), or raise base crit.
- **A soul striker:** evade and crit do nothing against soul. Stack soul resistance.
- **A tick or poison specialist:** ticks skip evade and crit. Bring a cleanse.
- **A top-end enemy:** the fight ends in about a second, before the meters pay. Do not fight upward without the Loaded Start pieces.
- **A block-heavy body cultivator (thể tu):** flat block eats the small hits. Lean on Raise the Stakes and House Takes All.

## Not in the game yet

Called Blow (designed only), The Loaded Table, Jackpot, Cash Out, Spilled Luck, Stacked Meter, Loaded Start, the Nine-Bone Ledger Sutra and its six arts, Ledger-Bone Dice, Nine-Star Array, Borrowed Luck Talisman, Sparrow-Luck Pill, the Mệnh Đạo nodes listed above, and the Gambler's Row cluster. All staged in `loaded-dice.staging.md`.

## Changes the game would need

- **Fortune may feed a counted chance** (Effects System rule 12: "Fortune does not shift counted chance"). One named keystone, The Loaded Table, adds 0.002 per khí vận (at most +0.15) to every counted chance and counts evade. Trade-off: a soft stat feeds power; it is bounded, and an Ill Star curse counters it.
- **Counted payouts as a readable event** (Effects System rule 12 and Combat rule 9). A meter reaching 1 emits an event that Per modifiers, Effects and art guards can read and spend. Trade-off: payouts become a trigger source, so `trig_budget` applies.

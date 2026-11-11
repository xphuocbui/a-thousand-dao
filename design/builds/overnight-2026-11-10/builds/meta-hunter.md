# The Open Ledger (Khai Bạ)

A Metal cultivator who swears never to pay in blood and never to stall a foe, and so can punish both.

## Why it works

Two patterns are very strong right now. One pays art costs in health, which a normal heal-block does not touch. The other puts Stagnation on every hit, which slows both kinds of regeneration. The Open Ledger answers each with a rule, not a bigger number, and stays an ordinary strong Metal fighter against everything else.

- **Against health-payers.** The Writ of Reckoning lays Dear Blood: the foe's health-paid costs are 1.5×, and 15 % of the health they paid comes back as damage. Your hits also grow by 4 % for every 10 % of maximum health they have spent (cap +40 %). Withering stops their healing.
- **Against Stagnation.** Stagnation on you stops at 20 stacks (at 1 % dampening per stack, that is nothing). Each stack past 20 is entered in the ledger and adds 0.4 % more damage, up to +40 %. Your sustain comes from leech, gain on hit and Ink-Line Breath, never from regeneration, so the curse had little to take.
- **Against everyone else.** A top-end ward (layers 300/250/150/100), a damage multiplier of about 180 at Nguyên Anh (the top-end anchor is 256, a typical build 7.4), and 6 of 20 wins against an equal top-end generalist. It is good, not unbeatable.
- **What it costs.** You can never pay in health, the best general sustain, and you can never lay Stagnation. Two of six slots do nothing against an ordinary foe.

Numbers on new pieces are first guesses. The simulator could not test the three Effects that make it a counter, so the guide says where it is only designed.

## What to look for

In the order you find them. "Not in the game yet" pieces are staged in this build's staging file.

1. **Spiritual root (linh căn):** Kim (Metal), purity 80 or more, a single root. In the game.
2. **Talents:** Thần thức (it pays for the Seal and reads your quarry), Comprehension (a tier 3 technique). In the game.
3. **Đạo:** Kim Đạo · *Bách Luyện*, Kim Phong and Thối Thể facets. In the roster as a Way, its graph is not yet drawn. Proposed passives Whetted Edge and Clean Hand: not in the game yet (staged: `kim-dao-whetted-edge`, `kim-dao-clean-hand`).
4. **Công pháp:** Open Ledger Sutra (Khai Bạ Kinh), main, tier 3, `names: kim`. Not in the game yet (staged: `open-ledger-sutra`).
5. **Arts:** Whetted Tally, Closing the Book, Writ of Reckoning, Clean the Page, Ink-Line Breath, Bloodhound's Count. Not in the game yet (staged: `whetted-tally`, `closing-the-book`, `writ-of-reckoning`, `clean-the-page`, `ink-line-breath`, `bloodhound-count`).
6. **Items:** Brush-Blade (flying sword) and Tallyman's Coat (armour) can roll from existing bases (`phi_kiem`, `giap`), in the game. The Clear-Bile Pill and Ledger-Hall Array: not in the game yet (staged: `clear-bile-pill`, `ledger-hall-array`).
7. **Enabler:** the Ledger Seal (Bạ Ấn). Not in the game yet (staged: `ledger-seal`).

## The enabling Effects

- **Dear Blood (Huyết Quý), a curse.** The foe's health-paid art costs are 1.5×, and 15 % of the health they paid returns to them as a tick (Called Debt). *Why:* health-paid costs are the pattern's strength, and Withering never touched them. Not in the game yet (staged: `dear-blood`, `called-debt`).
- **Clean Ledger (Sạch Sổ).** Stagnation on you is capped at 20 stacks; each stack past it is entered for +0.4 % more damage, up to +40 %. *Why:* it removes the curse as a threat and turns a loss into a gain. Not in the game yet (staged: `clean-ledger`).
- **The Ledger Seal's oath.** You may never pay costs in health and never apply Stagnation. *Why:* it is the price of the enabler. Without the Seal the Writ still lays Withering and Metal stacks, nothing more. Not in the game yet (staged: `ledger-seal`).

## Modifiers to stack

Most important first.

1. **Ward layers W2–W5** (technique, gear, preparation, Effects). Fill all four; the simulator showed this is where the top-end fight is won. Stop at the caps 300/250/150/100.
2. **Linh lực leech and linh lực on hit.** Stagnation does not touch them. Returns fall past about 6 %; add on-hit before more leech.
3. **Whetted Edge (L2, Metal).** +20 % more per art. L2 caps at 300 points; you stop near 280, leaving room for Spent Blood.
4. **Spent Blood (L2, Per).** Only against health-payers. Cap +40 %.
5. **Gear (L3).** Seal, Brush-Blade, Coat; thần thức limits how many you carry.
6. **Quarry Notes (L4).** Pill and array, only against a known quarry. In a blind fight this layer is gone.
7. **Hounds on the Scent (L5).** +16 % more per distinct status you have on the foe, up to five. Falling return: the fifth status is the hardest.
8. **Status resistance against curses.** Up to about +30 pp; after that, cleansing is cheaper.
9. **Art cost.** −30 % is enough; the build's arts are cheap already.
10. **Metal damage (L1).** Past +200 points, L1 counts half; stop there.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Ledger Seal | Entries rule | Switches on Dear Blood, Called Debt, Clean Ledger | Named artifact, taken at the Hall's oath | Staged (`ledger-seal`) | core |
| Writ of Reckoning | Dear Blood curse | Doubles the cost of a health-payer's style | Sutra layer 3 | Staged (`dear-blood`) | core |
| Open Ledger Sutra | Tier 3 main technique | The six arts, leech, status resistance | Hall library | Staged (`open-ledger-sutra`) | core |
| Linh lực leech | `leech_linh_luc_pct` | Regeneration-free sustain | Tree acupoints and notables, weapon affix | In the game (key) | core |
| Ward gear | Ward strength layers W3 | Top-end defence | Tallyman's Coat, named or rolled | In the game | core |
| Clean Ledger | Overflow on Stagnation | Immunity to the stall, then a bonus | Seal keystone | Staged (`clean-ledger`) | core |
| Whetted Edge | +20 % more, Metal tag, L2 | The build's L2 | Kim Đạo passive, technique | Staged (`whetted-edge`) | strong |
| Spent Blood | Per, L2 | Punishes spenders; cap +40 % | Steady Hand cluster | Staged (`spent-blood`) | strong |
| Linh lực on hit | `linh_luc_on_hit_pct` | Fuel under any curse | Tree, gloves affix | In the game | strong |
| Status resistance, curses | `status_resist_pct` +30 pp | Writ lands, Stagnation applied less | Tree, Clear-Bile Pill, Coat | In the game (key), pill staged (`clear-bile-pill`) | strong |
| Hounds on the Scent | Per, L5 | Reaches the top-end L5 | Kim Đạo node | Staged (`hounds-scent`) | strong |
| Ledger-Hall Array | Prepared L4 against a known quarry | Fills L4 where a sect knows its prey | Formation, Hall | Staged (`ledger-hall-array`) | strong |
| Spilled Ink | Overflow to ward shield | Turns spare linh lực into a shield | Tree notable, Steady Hand | Staged (`spilled-ink`) | nice |
| Spirit Severing | Hits burn the foe's linh lực | Answers a ward-heavy quarry | Existing keystone idea (catalogue) | Catalogued, not built | nice |
| Brush-Blade with leech | Weapon affix | L3 plus sustain | Weapon drop | In the game | nice |
| Quarry knowledge | Fight is not blind for L4 | Lifts the Hunter to top-end | Sect rule, world | Staged (`quarry-knowledge`) | core, for top-end |
| Bloodhound's Count | Heavy hit, Spent Blood | The sixth-slot closer | Sutra layer 11 | Staged (`bloodhound-count`) | nice |

## Realm by realm

- **Kết Đan (Core Formation):** five slots. Whetted Tally, Closing the Book, the Writ, Clean the Page, Ink-Line Breath. The Seal is borrowed. At a typical foe you win in about 2 s with the basic attack; the tools matter at top-end fight lengths.
- **Nguyên Anh (Nascent Soul):** a sixth slot (Bloodhound's Count), your own Seal, full ward layers, L4 against a known quarry. This is where it plays as intended.
- **Beyond (Hóa Thần):** the Hall's next question is which pattern to hunt; not designed.

## How it plays

Art order: Whetted Tally first (every 3 s), Closing the Book, the Writ, Clean the Page, Ink-Line Breath, Bloodhound's Count. Nothing fires at t = 0; the first Writ lands at about 5 s. Loadout: the sixth slot is Bloodhound's Count; swap Clean the Page for a second Whetted-type art if your quarry does not stall.

**Signature moment:** a blood-caster is at 60 % health after three hungry casts, and the Breakdown reads "Dear Blood: cost 1.5×". Your Closing the Book lands for a third more, and the ledger shows how much they owe.

## What beats it

- **A top-end generalist of the same realm** (a ward-heavy top-end build): 6 wins to 13 losses in the simulator. Adapt: bring Spirit Severing, play the long game with leech.
- **A burst build that ends the fight in two volleys:** the Writ fires at about 5 s and never lands. Adapt: a higher ward layer, a different slot 1.
- **A soul build:** soul hits pass layers and pay no cost, so no collection. Adapt: soul resistance.
- **A thể tu with no art costs:** nothing to collect. Adapt: play as a plain Metal fighter and lean on L1 to L3.
- **A curse-immune quarry:** the Writ misses. Adapt: raise status resistance and use Bloodhound's Count.
- **Observation:** the simulator showed a 0-of-20 floor against a top-end Stagnation applier, and the build's added cleanse changed nothing. Whether that is the build or the simulator's Stagnation is an open question.

## Not in the game yet

Ledger Seal; Open Ledger Sutra; the six arts (Whetted Tally, Closing the Book, Writ of Reckoning, Clean the Page, Ink-Line Breath, Bloodhound's Count); the Effects Dear Blood, Called Debt and Clean Ledger; the modifiers Whetted Edge, Spent Blood, Hounds on the Scent, Spilled Ink; the Clear-Bile Pill and Ledger-Hall Array; the Kim Đạo passives; the Steady Hand cluster; Quarry knowledge.

## Changes the game would need

- **Curse on cost payment (Combat Defence & Healing E; Effects System curse table).** A curse that changes how a foe's costs are paid, with a readable for the health they have paid. Suggestion filed.
- **Incoming stack cap with overflow (Effects System rule 9).** Cap a status's stacks on the wearer and turn the excess into a bonus. Suggestion filed.
- **Quarry knowledge (Combat rule 12).** A sect's named quarry makes the fight non-blind for L4. Suggestion filed.

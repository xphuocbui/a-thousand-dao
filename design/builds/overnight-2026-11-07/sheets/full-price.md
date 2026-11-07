# The Full Price (Túc Giá Đạo)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "Spirit stones carried are power, and arts can be paid in money: the merchant immortal."
> **Direction**: Art costs have no ceiling once money pays them. The art lint already sells any coefficient, so a merchant buys arts no pool could ever afford. Followed the numbers past the seed: spent stones are the power, and carried stones turn out to be a discount.
> **Realm span**: Foundation Establishment – Deity Transformation · **Power level**: legend while an 80,000-stone purse lasts, below ordinary once it is gone, and nothing yet shows that purse can be reached · **Use**: player build, or a rich NPC worth hunting
> **Fit**: 5 Fits today · 10 Needs key · 7 Needs rule
> **Checks**: 6 PASS · 0 FAIL · 3 NOT ASSESSED (Budgets: stones are not in the lint and thần thức is not totalled; Scaling: the stone rate and the 80,000-stone purse have no economy to size against; NPC use: no spec for what NPCs carry)

## The Spine

- **The channel:** art hits on all five layers, with no crit. One enormous hit, before anyone else can act.
- **The enabler:** Seal of Full Payment. Opens paying art costs in spirit stones. Closes linh lực as a way to pay: no stones, no arts.
- **The loop:** make money for years, carry it, and spend it in half a second.
- **The engine:** the art lint prices coefficient by cost, and only the size of a pool ever stopped anyone buying more. Stones remove that limit, and Rush Order delivers the hit before t = 1, when nobody else in the game has acted.
- **The sacrifice:** it does not fight, it pays. Two contracts empty a good purse, and a merchant with no stones loses to an ordinary cultivator of their own realm.
- **The arc:** a trader learns that everything has a price. Late in life they find that they are the most expensive thing they own.

## The Legend

The Weights and Measures Sutra was never a manual. It was the accounts of a sect that billed its disciples for training, entering every art's linh lực cost as a figure in stones. One clerk noticed that no rule stopped the column going past the size of the sea. The sect dissolved in debt, and the clerk left with the ledger and the seal.

Those who take up that seal learn the price of everything, and find it hard to stop. Every purse they carry can be read by anyone who looks. They do not have friends so much as accounts. Everyone with a knife and a reason to need money wants them dead, and the seal goes to whoever manages it.

## How It Fights

Half a second into the fight, before the first pulse and before any art in the game has fired, a stamp comes down on the enemy. On an ordinary road they use a cheap offer and let the ward take the rest. If the enemy can actually hurt them, Buyout fires in the same instant.

**The signature moment:** a top-end cultivator of the same realm dies at t = 0.5 with every art still on its timer, for a bill of 45,075 stones, half of it refunded. The merchant checks the sum.

## Enabler

**Seal of Full Payment (Túc Phó Ấn)**, named artifact, `an` base. Resource swap.

- **Opens:** every art may be paid in spirit stones instead of linh lực, and the ward below pays likewise.
- **Closes:** while it is equipped, linh lực pays for nothing. Carried stones appear on your profile, where any NPC can read them. A winner who takes you takes the seal.
- **Found:** a dead treasurer's effects, or a robbery. It is one item, and rare; the stack is not.

Price of an art: `stones = k · R · s² · fee · (1 − art_cost)`, where `s` is the art's share of maximum linh lực, `R` is the realm's `linh_thach_max`, and `k` is `stone_rate`, 2. Squared, because a market thins out as you buy it.

## The Stack

Sizes on new modifiers are first guesses. A forced push replaced the plain rungs: the first draft had a flat stones-to-damage Per, and Rush Order, Exact Change and the guarded Buyout came from that push.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | **Priced Above the Sea (Giá Siêu Hải)** | A stone-paid art may have `cost_share` above 1, and the art lint applies unchanged | Rule swap | art | none | ○ | Đạo keystone | any resource-swap build, such as blood-paid arts |
| Rate | Rush Order (Cản Đơn) | +50 % price: the art's first firing comes at half its effective cooldown | Timing | art | none | ○ | Đạo | any alpha strike, First Move builds |
| Multiplier | Damage (`attack_pct`) | +160 | Increased | any | L1 | ● | Tree | every build |
| Multiplier | Metal damage | +20 to Metal arts | Increased | art | L1 | ○ | Tree | **Catalogue row** |
| Multiplier | Tolled Seal (Chung Ấn) | +30 points to arts with the seal form | More | art | L2 | ○ | Technique | **Reused from the Ninth Bell** |
| Multiplier | Bulk Order (Phê Lượng) | +25 points to an art per full share of its cost | Per | art | L2 | ○ | Đạo | any costly art, Heavy Hand builds |
| Multiplier | Artifact attack | +40 from gear | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Purse Weight (Trọng Nang) | +30 points per doubling of carried stones above `R`, read at the start of a fight, within the L3 cap | Borrow | any | L3 | ○ | Đạo | any build with idle wealth |
| Multiplier | Ringing Ground (Hưởng Địa) | +20 points to arts, from a formation | More | art | L4 | ○ | Formation | **Reused from the Ninth Bell** |
| Multiplier | Full Sea (Mãn Hải) | +60 points while linh lực stays above 80 % | Conditional | art, basic | L5 | ○ | Sealed cluster | **Catalogue keystone** |
| Reach | Realm pierce (`pierce_pct`) | +15 | Flat | any | none | ● | Tree | any realm-crosser |
| Past the cap | Exact Change (Trảo Tiền) | Overkill on a winning hit refunds that share of its price, up to half | Overflow | art | none | ○ | Đạo | any priced art, refunding blood or stock |
| Fuel | Art cost (`art_cost_pct`) | −25 %, also on stones | Flat | art | none | ● | Tree, Đạo | sustain builds |
| Fuel | Collected Debt (Thu Trái) | On a knockout, take 10 % of the loser's carried stones | Trigger | any | none | ○ | Đạo | any bandit or hunter NPC |
| Survival | Indemnity Ward (Bồi Thường Hộ) | A per-pulse ward whose premium is paid in stones | Rule swap | any | none | ○ | Ward | any Seal user |

**Identity piece:** Priced Above the Sea. Without it (`--without priced_above_sea`) a 2-share art cannot be bought, and a same-realm top-end flips from a win at t = 0.5 to a loss at t = 1 with the enemy on 82 %.

**The surprise: carried stones are not the power, they are a discount.** The seed said stones carried are power. Removing Purse Weight (`--without purse_weight`) wins all the same fights at the same realm. What it changes is the bill: a top-end of the same realm costs 9,940 stones with a full purse and 29,890 without. A ×1.86 multiplier cuts the bill by ×3, because the price squares. So to this build, every multiplier in the game is a discount. The rich pay less for the same death.

**Second surprise: the cheapest move is to shoot first.** Without Rush Order, the same top-end needs a 3.5-share shot to win a double knockout on overkill (`variants/full-price-no-rush.fight.json`), at 91,875 stones, more than the purse. At t = 0.5 it needs 0.94, because it never gets to answer.

**Empty rungs:** Crit is a sacrifice. A merchant does not gamble, so evade is the honest counter: a 40 % evader wastes the contract 4 times in 10, and the money stays spent. Reach needs nothing past pierce, because one huge hit overwhelms a drain ward's pool.

| Layer | Points at Core Formation (Ruinous Offer) | Multiplier | Sources |
|---|---|---|---|
| L1 | 180 | ×2.80 | `attack_pct`, Metal damage |
| L2 | 80 | ×1.80 | Tolled Seal, Bulk Order |
| L3 | 160 | ×2.60 | Gear, Purse Weight at 80,000 stones |
| L4 | 20 | ×1.20 | Ringing Ground; a blind fight loses it |
| L5 | 60 | ×1.60 | Full Sea, held by paying everything in stones |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Metal, high purity | Metal's role is already `mission_income`. The Way requires it |
| Key talents | Charm (mị lực), Fortune (khí vận) | Prices and reward ceilings |
| The Way (Đạo) | Way of Trade | Holds the keystone and the money pieces |

## Công Pháp

### Weights and Measures Sutra (Cân Lượng Kinh) — main, Thiên giai

An account book, kept by someone who stopped being able to see anything else.

```json
{"id": "can_luong_kinh", "name": "Cân Lượng Kinh", "tier": 3, "tech_kind": "main",
 "names": ["kim"], "layers": 15,
 "bonuses": [{"stat": "attack_pct", "value": 15}, {"stat": "khi_huyet_pct", "value": 12},
             {"stat": "lifespan_years", "value": 12}],
 "abilities": [{"ability_id": "earnest_money", "unlock_layer": 3},
               {"ability_id": "buyout", "unlock_layer": 7},
               {"ability_id": "ruinous_offer", "unlock_layer": 11}],
 "seal_clusters": ["counting_beads"], "origin": "authored"}
```

**Fit:** Needs key (abilities; `seal_clusters` is unread today) · **Budget:** 15/15 + 12/15 + 12/15 = 2.6 of 4, each under the 1.5 single cap

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Earnest Money (Định Kim) | Sutra, 3 | qi, seal, Metal | 4.0 | share 0.25: 469 stones at Core | 1 s | none | Needs key |
| Buyout (Mãi Đoạn) | Sutra, 7 | body, seal, Metal | 13 | share 1: 7,500 | 1 s | own health below 75 % | Needs rule |
| Ruinous Offer (Khuynh Gia Giá) | Sutra, 11 | body, seal, Metal | 25 | share 2, rushed: 45,000; later firings 30,000 | 1 s, first at 0.5 s | none | Needs rule |

Prices include the −25 % art cost. **Effect:** each is a hit. **Buyout's guard is the build's spending policy.** It reads after the first hit lands, so the art fires in a follow-up instant at the same t (rule 10), and the merchant only pays if the enemy could actually hurt them. **Description:** the deposit, the purchase, and the price of the whole house.

The coefficients of 13 and 25 pass the art lint and exceed Formulas C's stated range of 1.2 to 12.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation Establishment | 4 | Earnest, Buyout | Indemnity | Ruinous Offer unlocks late; a contract is 5,400 stones |
| Core Formation, road | 5 | Earnest, Buyout | Indemnity | About 450 to 4,400 stones a fight |
| Core Formation, contract | 5 | Earnest, Buyout, Ruinous | Indemnity | Slotted only for a fight worth paying for |
| Nascent Soul | 6 | As above | Indemnity | A contract is 360,000 stones |
| Deity Transformation | 7 | As above | Indemnity | A contract is 2,700,000 stones, by the formula |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Seal of Full Payment | Artifact, weapon | `an`, `thuong`, realm tier | The enabler. The treasurer who cut it was killed with it | Needs rule |
| Indemnity Ward | Ward | New `cost_model`, pass 0.4 body, 0.3 qi | Premium 2 % of `R` per pulse, in stones: 75 at Core after art cost. Linh lực is never touched, so Full Sea holds, and the fight becomes a meter | Needs rule |
| Ringing Ground | Formation | Reused | L4 | Needs key |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Counting Beads | Sealed cluster | Full Sea, art cost | Needs key |
| 2 | `art_cost_pct` | To −25 % | Directly cuts every bill | Fits today |
| 3 | `attack_pct`, `khi_huyet_pct` | Notables | No W goes to linh lực at all: `n_qi` 1.0, a merchant's sea is a puddle | Fits today |

### Hidden cluster idea: Counting Beads (Toán Châu)

Theme: the Market economy, wider than one build. Metal affinity, outer, sealed. Seal condition: a technique that lists it. Size 7. Small acupoints give art cost and Metal damage. The notable is Full Sea, the payoff farthest from the entry.

## Đạo

**Way of Trade (Thương Đạo), proposal.** Requirement: Metal at purity 40 or more. `theme_stats`: `art_cost_pct`, `mission_income_pct`, `travel_speed_pct`, `co_duyen_pct`, `mi_luc`, `khi_van`. 20 nodes, on the mix of dao.md Formulas D1's worked example, so 236 W, 11.8 W a node. With the name hidden, every node is about buying, moving goods or owing.

| Branch | Nodes, in order | Signature nodes |
|---|---|---|
| **The Scale (Hành)**, 6 | art cost, Exact Change, art cost, Bulk Order, charm, Rush Order | **Exact Change** (T2), **Bulk Order** (T1), **Rush Order** (T1) |
| **The Road (Lộ)**, 6 | income, Collected Debt, travel, Purse Weight, encounters, Bank Draft | **Purse Weight** (T2). **Collected Debt** (T1). **Bank Draft (Ngân Phiếu)** (T2): stones lodged at a counting house count at half for Purse Weight and cannot be taken |
| **The Ledger (Trướng)**, 7 | fortune, Ransom Clause, income, On Credit, charm, Fair Dealing, fortune | **Ransom Clause (Thục Mệnh)** (T2): a mortal wound is spared if you can pay `4R`. **On Credit (Xa Trướng)** (T1): opens Debt, below. **Fair Dealing (Công Bình)** (T1): an NPC who took your stones in a deal will not rob you for a year |
| **Keystone** | Priced Above the Sea | T3 and a 4 W `art_cost_pct` line |

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | A poor trader with a very good seal | Earnest Money | Paying 469 stones for a blow, and feeling it for a year |
| Core Formation | One contract buys any peer | Ruinous Offer | The first time a stranger reads your purse and smiles |
| Nascent Soul | The same, at eight times the price | Bank Draft | Deciding how much of yourself to keep in a vault |
| Deity Transformation | A fortune per fight | On Credit | Owing more than a sect is worth, and nobody left to collect it |

## Matchups

Core Formation, contract loadout, 80,000-stone purse unless stated. Each row is read from the file named, in `variants/` unless it says `main`, which is `sheets/full-price.fight.json`. A `duel` file runs with no `--matrix`.

| Enemy | Result | Why | File |
|---|---|---|---|
| Typical, same realm or one up | Wins at 0.5 s, untouched | Net 22,575 stones. Far too expensive: use the road loadout | main |
| Top-end, same realm | Wins at 0.5 s, untouched | Net 22,575 stones | main |
| The Ninth Bell, the Burial Shroud (duels) | Wins at 0.5 s | Neither has acted yet | `full-price-duel-ninth-bell.fight.json`, `full-price-duel-burial-shroud.fight.json` |
| Top-end, one realm up | Loses at 1 s, enemy on 59 % | A 2-share offer is not enough; the price list says 3 shares | main |
| Typical, two realms up | Loses at 1 s, enemy on 48 % | As above | main |
| ×4 boss, top-end | Loses at 1 s, enemy on 52 % | The pool outlasts the offer | `full-price-boss-x4.fight.json` |
| 0.5 s striker, top-end | Double knockout at 0.5 s, won on overkill | The merchant wins by having overpaid | `full-price-striker.fight.json` |
| **The Receiving Hand (duel)** | **Loses at 1 s, enemy on 95 %** | Ruinous Offer is caught whole and returned in the next punch. 45,619 stones, no refund | `full-price-duel-receiving-hand.fight.json` |
| Any enemy, with no stones left | Loses to a typical of the same realm at 3 s, enemy on 83 % | Default ward, no arts, nothing | `full-price-no-stones.fight.json` |

**Counter:** a catcher, an evader, or time. The worst enemy is the fourth fight of the week.

## The Price List

Cheapest rushed single shot at Core Formation, at 0.01-share steps. Gross stones, before Exact Change. Each cell is a saved file: `variants/full-price-price-[enemy]-g[gap].fight.json`, and `-no-purse` for the last column, run with `--enemy` and `--gap`. 0.01 of a share less does not kill at 0.5 s. The two dearest purse cells cost more than 80,000, so those files carry 150,000, which is the same +120.

| Enemy | Share | With an 80,000 purse | With no Purse Weight |
|---|---|---|---|
| Typical, same realm | 0.27 / 0.54 | 820 | 3,280 |
| Top-end, same realm | 0.94 / 1.63 | 9,940 | 29,890 |
| Typical, one up | 1.07 / 1.83 | 12,880 | 37,675 |
| Top-end, one up | 2.99 / 4.66 | 100,576 | 244,300 |
| Typical, two up | 3.29 / 5.09 | 121,771 | 291,466 |

**What a purse buys.** From 80,000 stones at Core: contract one, then 57,425 left and Purse Weight +90 (`variants/full-price-contract-two.fight.json`); contract two, then 34,850 left and +60; a third cannot be paid, and Ruinous Offer does not fire (`variants/full-price-contract-three.fight.json`). Two contracts, and the merchant is back on the road.

**Whether the purse exists.** Every contract figure here assumes 80,000 stones at Core Formation, which is 16 × `R`, and `R` (`linh_thach_max`, 5,000 at Core in `assets/data/events_budgets.json`) is the ceiling on one event reward. Nothing in this sheet shows that purse can be reached. The bills are real, because a plug-in prints them, but "legend" is the power of that purse and not a proven one. The cheapest same-realm top-end shot with no Purse Weight is still 29,890 stones, about six such rewards.

**Economy note.** Every contract burns stones. `systems-index.md` lists "add sinks when later realms are designed" as an open risk, and this is one.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique 2.6 of 4; slots 3 of 5; art lint within for all three, printed by the tool now that `cost_share` holds the real share. Thần thức not totalled |
| Validity | PASS | Metal, `thien`, `an` real; `mission_income_pct`, `art_cost_pct`, `co_duyen_pct`, `travel_speed_pct` are real keys |
| Stack | PASS | Nine forms, identity piece, every rung filled or named. `--without priced_above_sea` changes the top-end fight from a win to a loss |
| Scaling | NOT ASSESSED | INFO: art M about 25, between the anchors at 5.48 and 210, and the shot kills a top-end. Whether that is priced right depends on `k` and on whether an 80,000-stone purse can exist, and there is no Market GDD to size either against |
| The fight | PASS | Constants 60 of 60, selftest clean; every hit is simulated. `rules/stone_payment.py` prints the bill, and `rush_order`, `purse_weight` and `exact_change` run their rules. Ruinous Offer fires at t = 0.5 |
| Reuse | PASS | Tolled Seal and Ringing Ground reused from the Ninth Bell, Full Sea from the catalogue. Bare Vessel, lesser grade (+30), tested and cut: it changed nothing (`variants/full-price-bare-vessel.fight.json`) |
| NPC use | NOT ASSESSED | NPCs have a wealth effect in Quests, but no spec for carried stones. Spending policy is only guards, which the generator can set |
| Counterplay | PASS | Catchers, evaders, ×4 bosses, attrition |
| Originality | PASS | Original structure and names |

## Fight Results

Input: `design/builds/overnight-2026-11-07/sheets/full-price.fight.json`, the contract loadout, rules `stone_payment`, `priced_above_sea`, `rush_order`, `purse_weight` and `exact_change`. Observations from `_tools/fight_x.py`, a paper model with expected values for chance, not the game.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Win, 100 % health left | 0.5 s | never | none |
| typical | 1 | Win, 100 % health left | 0.5 s | never | none |
| typical | 2 | Loss, enemy on 48 % | 1 s | never | none |
| top_end | 0 | Win, 100 % health left | 0.5 s | never | none |
| top_end | 1 | Loss, enemy on 59 % | 1 s | never | none |
| top_end | 2 | Loss, enemy on 92 % | 1 s | never | none |

**The road loadout** (`variants/full-price-road.fight.json`): typical same realm, a win at 1 s on 85 %, net 448 stones, Buyout never fires. One realm up, a win at 1 s on 48 %, net 4,369, Buyout fires in the follow-up. Top-end same realm, a loss at 1 s.

**What the repair changed.** The bill now comes from a plug-in, not from sums by hand. The road's net is higher than first written: a fight to t = 1 pays two premiums, and Exact Change refunds the overkill share, which is under half on a cheap hit. Ruinous Offer no longer has a stock of 1, so it can fire again at 30,000 if the purse holds. Two cells of the price list moved one step. No result changed.

**Second realm.** Nascent Soul (`variants/full-price-nascent.fight.json`) and Foundation Establishment (`variants/full-price-foundation.fight.json`) match Core: both win through same-realm top-end at 0.5 s and lose to top-end one up (enemy on 72 % and 47 %). Their stats are a first guess.

**Removing Full Sea** (`--without "Full Sea"`) leaves top-end one up on 74 %, against 59 %. **Removing Purse Weight** (`--without purse_weight`) leaves it on 78 %, and raises every price as listed.

**Unmodelled:** evade as a true miss; Collected Debt; the purse between fights, which is the three contract files above. All are listed in the fight file.

## New Concepts

**Debt (Nợ).** Spirit stones may fall below 0 through On Credit, down to `4R`. Rule: Character Stats rule 6, which holds stones at 0 or more, plus Market. Interest accrues per season, and unpaid debt adds to heart demon (tâm ma) and sends a collector through Quests. Breakdown line: "paid on credit, 12,000 owed." It would also serve a creditor build and a build that borrows from its own future. NPCs can carry debt as a fact in the World Database. **Question for the user:** is debt a system you want?

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Seal of Full Payment | Needs rule | Combat rule 11 and 13: a second payer for arts; a fight budget of stones |
| Priced Above the Sea | Needs rule | Formulas C: `cost_share` above 1 and `c_art` above 12 for stone-paid arts; a `stone_rate` key |
| Rush Order | Needs rule | Combat rule 13: an art's first firing can come early |
| Exact Change | Needs rule | Combat rule 14: overkill reported to the caller for a refund |
| Indemnity Ward | Needs rule | Combat rule 22: a cost model paid outside linh lực |
| Collected Debt | Needs rule | Rule 14's caller: stones change hands on a knockout |
| Debt | Needs rule | Character Stats rule 6 and a Market rule |
| Metal damage, Tolled Seal, Ringing Ground, Bulk Order, Purse Weight, Full Sea | Needs key | Tagged, per-share and per-doubling keys; compile reads carried stones |
| Three arts, Weights and Measures Sutra, Counting Beads, Way of Trade | Needs key | Art records, `seal_clusters`, a cluster idea and a Đạo as data |

## Questions for the User

1. A Core cultivator kills a same-realm top-end for about 10,000 to 45,000 stones. Is `stone_rate` 2 the right order of magnitude?
2. Should a build be able to act before t = 1 at all? Rush Order is the sharpest rule-bend here.
3. Rule 18 wants a top-end build to need 4 s against an ordinary boss. This shot ends a ×4 typical boss at 0.5 s (`variants/full-price-boss-x4.fight.json`). Acceptable at this price?
4. Can a Core cultivator ever hold 80,000 stones, 16 times the ceiling on one event reward? If not, what purse is real, and does "legend" survive it?

## Also Considered

- **The Insured:** ordinary arts, all money into the Indemnity Ward, a cultivator who cannot be worn down. Sound, but only a defence.
- **The Debtor:** a build living entirely on credit. Stronger as its own concept once Debt is decided.

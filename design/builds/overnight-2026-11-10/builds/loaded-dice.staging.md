# Staging: loaded-dice

First-guess numbers throughout. Nothing here is in game data.

## Reused

| ID | Found in |
|---|---|
| flowing-water | tree catalogue |
| linh-luc-regained-on-a-crit | tree catalogue |
| art-damage | tree catalogue |
| crit-damage | tree catalogue |
| called-blow | tree catalogue (Effects System Starter Effects names it; the catalogue's "Fortune" keystone row Heaven's Favour is the nearest) |

## Modifiers

| ID | Name (Hán-Việt) | Stat and size | Form | Channel | Layer | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|---|---|---|
| stacked-meter | Stacked Meter (Tích Tiết) | +2 % more art damage per counted payout in the last 8 s, up to 10 payouts (+20 %) | Per | art | L2 | Needs key (a payout count readable at compile of the Breakdown) | Mệnh Đạo, Định Mệnh branch; tree cluster | loaded-dice | Bounded by the count cap. Second home: any Called Blow or counted-chance build |
| spilled-luck | Spilled Luck (Dật Phúc) | Counted crit chance above the Called Blow cap (0.35) adds 2 points of crit multiplier per 0.01 over, inside `crit_mult_cap` 3.0 | Overflow | art, basic | none | Needs rule (Effects System rule 12: what a counted cap clips) | Mệnh Đạo notable | loaded-dice | Second home: any crit build with a chance cap |
| loaded-start | Loaded Start (Quán Khởi) | Each counted meter you own starts the fight at 0.5 instead of 0 | Timing | any | none | Needs rule (Effects System rule 12: meter start value) | Pill, formation, tree notable | loaded-dice | Second home: any counted-chance build that wants a fast first payout |

## Effects

| ID | Name (Hán-Việt) | Rule | Fit | Suggested home | Used by | Notes |
|---|---|---|---|---|---|---|
| jackpot | Jackpot (Đại Phát) | Every third counted crit payout adds 1.0 to that hit's crit multiplier, inside `crit_mult_cap` 3.0. The meter shows "3 of 3" | Needs rule (Effects System rule 12: a payout counter) | Mệnh Đạo capstone | loaded-dice | Deterministic: no draw |
| cash-out | Cash Out (Thu Bàn) | An art with this guard may spend the crit meter: if it reads 0.6 or more, the art's hit is a crit and 1 comes off the meter (a reading below 0.6 spends nothing and the art waits) | Needs rule (Effects System rule 12: an art reads and spends a meter) | art on House Takes All | loaded-dice | Lets the player time the payout |

## Enablers

| ID | Name (Hán-Việt) | Kind | Lives on | Opens | Closes | Fit | Used by |
|---|---|---|---|---|---|---|---|
| loaded-table | The Loaded Table (Quán Bàn) | Scaling bridge + Rule removal | Mệnh Đạo capstone keystone (Định Mệnh branch) | Your evade is counted (one chance, rule 12); your khí vận adds 0.002 per point (at most +0.15) to every counted chance you own, after its cap, inside the global caps; counted meters read on the HUD | You can never use an escape art; Called Blow's 0.35 cap stays; fortune no longer shifts any rolled chance of yours | Needs rule (Effects System rule 12: "Fortune does not shift counted chance") | loaded-dice |

## Artifacts, talismans, pills, formations

| ID | Name (Hán-Việt) | Type | What it does | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| ledger-bone-dice | Ledger-Bone Dice (Toán Cốt Tử) | Artifact, utility, named | +15 khí vận; +6 % crit damage; an affix line "counted meters start at 0.5" (Loaded Start) | Fits today (khí vận affix; the third line is Needs rule) | loaded-dice | Carved from a bookkeeper's own knucklebones |
| nine-star-array | Nine-Star Array (Cửu Tinh Trận) | Formation | In a prepared fight: +20 khí vận for the fight; L4 formation power scales it | Needs key (a fight-long khí vận bonus from preparation) | loaded-dice | Blind fights lose it (rule 12) |
| borrowed-luck-talisman | Borrowed Luck Talisman (Tá Vận Phù) | Talisman | Used up: +12 khí vận for 30 s | Needs key | loaded-dice | Takes an art slot |
| sparrow-pill | Sparrow-Luck Pill (Tước Vận Đan) | Pill | +15 khí vận for the next fight; toxicity small | Needs key | loaded-dice | Preparation only |

## Công pháp

| ID | Name (Hán-Việt) | Kind and tier | What it gives | Fit | Used by | Notes |
|---|---|---|---|---|---|---|
| nine-bone-ledger-sutra | Nine-Bone Ledger Sutra (Cửu Cốt Toán Kinh) | main, Địa giai (tier 2), reaches Nguyên Anh | `linh_luc_regen_pct` 10, `crit_chance_pct` 6; divine abilities: Winnings (layer 4), Raise the Stakes (layer 8), House Takes All (layer 12) | Fits today (bonuses); abilities are new art records | loaded-dice | Budget NOT ASSESSED: bonus_pool keys not checked |

## Arts

| ID | Name (Hán-Việt) | Source | Kind, tags | c_art / cost / cooldown | Rule | Fit | Used by |
|---|---|---|---|---|---|---|---|
| cast-the-bones | Cast the Bones (Phóng Cốt) | Sutra, layer 1 | qi, thunder, strike | 2.0 / 0.04 / 2 s | Hit; +1 thunder buff stack on you for 10 s | Fits today | loaded-dice |
| counting-blade | Counting Blade (Toán Đao) | Sutra, layer 2 | qi, metal, strike | 3.1 / 0.06 / 4 s | Hit | Fits today | loaded-dice |
| thunder-debt | Thunder Debt (Lôi Trái) | Sutra, layer 3 | qi, thunder, status | 1.4 / 0.03 / 3 s | Hit; 3 thunder debuff stacks on the target (crit_taken, critdmg_taken) for 10 s | Fits today | loaded-dice |
| winnings | Winnings (Thắng Lợi) | Sutra, layer 4 | qi, thunder, restore | 0.8 / 0.05 / 6 s | Hit; regain 3 % of maximum linh lực | Fits today | loaded-dice |
| raise-the-stakes | Raise the Stakes (Đại Chú) | Sutra, layer 8 | qi, metal, strike | 4.6 / 0.08 / 8 s | Hit | Fits today | loaded-dice |
| house-takes-all | House Takes All (Nhà Cái Thắng) | Sutra, layer 12 | qi, thunder, strike | 3.4 / 0.05 / 6 s | Hit with the Cash Out guard | Needs rule | loaded-dice |

## Đạo pieces

| ID | Name (Hán-Việt) | Way and facet | Kind | What it does | Fit | Used by |
|---|---|---|---|---|---|---|
| open-book | Open Book (Mở Sổ) | Mệnh Đạo, Định Mệnh | notable | Counted meters are shown to the enemy-side Breakdown too; +4 % crit damage | Fits today (stat) | loaded-dice |
| tally-keeper | Tally Keeper (Giữ Sổ) | Mệnh Đạo, Định Mệnh | notable | Stacked Meter | Needs key | loaded-dice |
| spilled-luck-node | Spilled Luck node | Mệnh Đạo, Khí Vận | notable | Spilled Luck | Needs rule | loaded-dice |
| house-edge | House Edge (Địa Lợi Cục) | Mệnh Đạo, Khí Vận | notable | +10 khí vận; Loaded Start | Needs rule | loaded-dice |
| loaded-table-capstone | The Loaded Table | Mệnh Đạo capstone | keystone | the enabler | Needs rule | loaded-dice |
| jackpot-capstone-notable | Jackpot node | Mệnh Đạo, Định Mệnh | notable | Jackpot | Needs rule | loaded-dice |

## Concepts and keys

| ID | Name | Kind | What it is | Fit | Used by |
|---|---|---|---|---|---|
| counted-payout-event | Counted payout (Chi Trả) | New event | A counted meter reaching 1 emits an event Effects and Per modifiers can read (Stacked Meter, Jackpot, Winnings) | Needs rule | loaded-dice |
| fight-fortune | Fortune in the fight (Khí Vận Chiến) | New key | An in-fight khí vận value that preparation (formation, pill, talisman, artifact) can raise, read by Combat Formulas I and the Loaded Table | Needs key | loaded-dice |
| gamblers-row | Gambler's Row (Phố Cược) | Cluster idea | Sealed cluster, Thunder/Metal, 9 acupoints: small khí vận, crit chance, crit damage; notable Stacked Meter; seal: win three fights against a higher realm | Needs key | loaded-dice |

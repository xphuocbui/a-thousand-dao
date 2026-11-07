# The Best Plan (Thượng Sách)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "Never wins and never dies: flight as a way of life." "Twenty talismans: a gambler's sleeve." Critic order 2: the Coward, defined at Qi Refining, no kill condition, leaves with the goods, fear and pettiness, funny.
> **Direction**: The seed's sleeve is kept and given a stranger engine: Slow Wound, written for a saint who stands 40 seconds, is put on paper for someone who stands 2.5. The killing blow goes on a bill, and you leave before it falls due.
> **Realm span**: Qi Refining – Nascent Soul, defined at Qi Refining · **Power level**: ordinary · **Use**: player build, a whole life; also the NPC everyone swears they killed
> **Fit**: 2 Fits today · 8 Needs key · 9 Needs rule
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (Budgets: no talisman or escape budget exists. Scaling: a build with no damage has no anchor to meet)

## The Spine

- **The channel:** none. It wins by a Fled result (Combat rule 10), with a damage multiplier of 1.00. Its "damage" is what it carries out of the room.
- **The enabler:** Promissory Paper, a talisman that puts Slow Wound on you for one fight. Each sheet is a rare, used-up purchase, so every fight has a price before it starts.
- **The loop:** paper at 0.5 s, first exit at 0.5 s, first roll at 1.5 s, pick a pocket every half second until a roll lands.
- **The engine:** a blow on the ledger pays 5 % of health a second, however big it is, and a Fled result ends the fight with the rest unpaid. So the size of the blow stops mattering, and the only question left is how long you stay.
- **The sacrifice:** you never win a fight. No knockout, no capability #9, no duel, no Heavenly Tribulation, since a flight fails it (Tribulation rule 8). Nascent Soul is the end of this road.
- **The arc:** every person who nearly killed you goes in a book. You cannot meet them again until they die, so a life becomes the job of outliving a list.

## The Legend

The Thirty-Six Exits was written by a conscript who served in fourteen armies for an average of nine days each. It is a field manual. Chapter one is doors. Chapter nine is why the second-best horse is the one to steal. Chapter thirty-six reads, in full, "If you have reached this chapter, the other thirty-five have failed. Put the book down." Every general in the eastern marches has burned a copy and owns a copy.

The author has been officially dead nine times. A small wreath, the cheapest the shop sells, has arrived at the funeral of every commander they ever deserted, in some cases centuries apart, always with a card that says "Paid in full." Nobody hunts them. Nobody can agree they are worth it, which they regard as the finest thing ever said about them.

## How It Fights

A Foundation elder in a bad mood steps into the alley. You fire a sheet of paper before they finish their sentence. They hit you with something that would kill a horse, and you feel almost nothing, because that blow has been received and will be processed. You slap them in the face, take their purse, fail a roll, take their pills, make the second roll and go. You are at 95 % health and you owe 285 % of your health to a stranger.

**The signature moment:** two realms below a top-end elder, at 2.5 s, you leave on 95 % health with their purse, having taken 63,144 % of your maximum health in blows that have not arrived yet (`sheets/best-plan.fight.json --enemy top_end --gap 2`). Paid in years, that is 757.7 years. You have 80.

## The Stack

Sizes on new modifiers are first guesses. `[C]` was taken on the stack: a plain pile of escape chance became Skipped Bill and the Creditors' Book.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Escape chance | +7 % from one notable and one small | Increased | escape | none | ○ | Hidden cluster | **Catalogue row** |
| Rate | Cold Feet (Hàn Túc) | Escape arts first fire at `cooldown_min` | Timing | escape | none | ○ | Technique | any trapper's getaway, any NPC guard who sounds an alarm |
| Multiplier | Full Sleeve (Mãn Tụ) | +0.02 escape bonus per doubling of talismans carried above 4, read at the start of a fight, slots or bag | Per | escape | none | ○ | Technique | any talisman crafter |
| Reach | Beneath Notice (Bất Túc Đạo) | Against a pursuer above you, the realm term is +0.05 a realm, not −0.10. Nobody important chases a flea | Rule swap | escape | none | ○ | Hidden cluster | any low-presence rogue |
| Reach | Terror (Kinh Hồn) | +0.15 escape bonus while the ledger exceeds your health. You are technically dead, and running like it | Conditional | escape | none | ○ | Hidden cluster | any Slow Wound user |
| Fuel | Folded Corner (Chiết Giác) | The first failed roll of a fight puts its talisman back in stock, one corner folded | Trigger | escape | none | ○ | Technique | any sleeve of single-use paper |
| Survival | **Slow Wound (Hoãn Thương)** | Hit damage past ward and guard enters a ledger that pays at most `dot_pool_cap` of health a pulse. Carried here by paper, for one fight | Rule swap | incoming | none | ○ | Talisman | **Reused from The Incense Vigil**, where it is a technique for standing still |
| Survival | Years Owed (Thọ Trái) | The ledger left at the fight's end costs lifespan: 1 % of the realm's base per 100 % of health | Overflow | any | none | ○ | Rule of Slow Wound | **Reused from The Incense Vigil** |
| Identity | **Skipped Bill (Đào Trái)** | On a Fled result the ledger is not paid in years. It is written in the Creditors' Book against the one who dealt it | Overflow | incoming | none | ○ | Technique | any debtor, any NPC who owes the player |
| Identity | Dies Later (Hậu Tử) | When a creditor dies by any hand but yours, the entry is void, heart demon falls by 3, and you learn where they kept their things, with a claim on 1 % of carried stones per 100 % owed, to 25 % | Per | none | none | ○ | Technique | any long-lived grudge |

**Identity piece:** Skipped Bill. `--without skipped_bill`, one realm below a top-end you still leave at 2.5 s, and then die on the road of 211.6 years owed, with 80 left (`sheets/best-plan.fight.json --enemy top_end --gap 1`). One level with a top-end you live, 58.1 years poorer.

**The borrowed piece:** Slow Wound was built to stand 40 seconds and win a stalemate. Here it is used for 2.5 seconds, by someone running. `--without promissory_paper`, a top-end at your own realm kills you at 1 s (same file, `--gap 0`).

**Pieces that share a job:** Terror and Beneath Notice both raise the roll. Remove both against a locking top-end two realms up (`variants/best-plan-lock.fight.json --enemy top_end --gap 2`): p falls from 0.73 to 0.28, the exit moves from 2.5 s to 4.5 s, and the bill doubles to 126,363 %.

**Empty rungs:** crit, L1 to L5 and past-the-cap are sacrifices. Chance stays chance, and the sleeve answers it with quantity.

| Layer | Points at Qi Refining | Multiplier | Sources |
|---|---|---|---|
| L1 to L5 | 0 | ×1.00 | Nothing. Every point spent here is a sheet of paper not bought |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Any. Water is traditional, for no reason the author would give | The build reads no element |
| Key talents | Fortune, then Comprehension for the craft | Fortune shifts every roll by 0.001 a point (Formulas I) |
| The Way (Đạo) | None | A Way is a reason to stay somewhere |

## Công Pháp

### Thirty-Six Exits (Tam Thập Lục Lộ Quyết) — secret, Huyền giai

A deserter's field manual, in the margins of someone else's.

```json
{"id": "tam_thap_luc_lo", "name": "Tam Thập Lục Lộ Quyết", "tier": 1, "tech_kind": "secret",
 "names": ["thuy"], "layers": 9,
 "bonuses": [{"stat": "stealth", "value": 10}, {"stat": "travel_speed_pct", "value": 15}],
 "abilities": [{"ability_id": "goat_in_passing", "unlock_layer": 3}],
 "seal_clusters": ["am_mon"], "origin": "authored"}
```

Layer 2 gives Cold Feet, layer 4 Full Sleeve, layer 6 Folded Corner, layer 9 Skipped Bill and Dies Later. **Fit:** Needs key · **Budget:** 10/10 + 15/15 = 2.0 of 2.0. `huyen` reaches Core Formation; past that it runs at `beyond_realm_mult`, and the owner does not care.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Promissory Paper (Khế Trái Phù) | Talisman, stock 1 | talisman | 0 | 0 | 0.5 s | time above 0 | Needs rule |
| Thần Hành Phù | Talisman, stock 6, e_art 0.50 | talisman, escape | 0 | 0 | 1 s | time above 0 | Needs key |
| Goat in Passing (Thuận Thủ) | Thirty-Six Exits, layer 3 | body, theft | 0 | 0.02 | 0.5 s | none | Needs rule |
| Not-Yet-Used Sheet (Vị Dụng Phù) | Talisman, stock 1, e_art 0.70 | talisman, escape | 0 | 0 | 1 s | own health below 30 % | Needs key |

**Promissory Paper. Effect:** Slow Wound at share 1.0 for this fight, from the instant it fires. **Description:** a contract with your own future, witnessed by no one.

**Goat in Passing. Effect:** each firing lifts one carried thing from the enemy: a stack of talismans, a pill, or 1 % of carried stones, cheapest first. Kept only on a Fled result, dropped otherwise. **Description:** the name is an old saying, and the goat was never the point.

**Not-Yet-Used Sheet. Description:** carried for ninety years through eleven near-deaths, each of which was judged not quite bad enough.

**What the numbers changed:** an exit priced in linh lực dies with the ward, since at 5 % a sheet one top-end blow empties the pool and the next exit never fires (`variants/best-plan-priced-exit.fight.json --enemy top_end --gap 0`: one roll, Down at 21 s), so every exit in the sleeve is paper paid for in stock.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Qi Refining | 3 | Promissory Paper, Thần Hành Phù, Goat | Default | Greed or a better exit: the third slot is the whole decision |
| Foundation | 4 | Add Not-Yet-Used Sheet | Default | Greed and fear, at last |
| Core Formation | 5 | Add a second Promissory Paper, guarded on stock | Default | A rematch needs one for the old bill |
| Nascent Soul | 6 | Add a second exit tier | Default | Very tired |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Promissory Paper | Talisman | Difficulty 70, level 4, ink 150, yield 1, like Phá Cảnh Phù | One bad day each. Your stock of these is the number of times you may be unlucky | Needs rule |
| Thần Hành Phù | Talisman | Exists: `than_hanh`, `use: evade` | The cheap legs. Gains an escape art record | Needs key |
| Not-Yet-Used Sheet | Talisman | Difficulty 85, level 6 | Never fired. Counts for Full Sleeve all the same | Needs key |

Slotted talismans count in a blind fight (Combat rule 12), which is why the sleeve is always packed.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Hidden Doors cluster | Below | The whole tree plan | Needs key |
| 2 | Escape chance | +1 % small, +6 % notable | Toward the 0.3 limit | Needs key |

### Hidden cluster idea: Hidden Doors (Ám Môn)

Theme: escape, which is wider than this build. Water affinity. Sealed, seal condition: Thirty-Six Exits lists it in `seal_clusters`. Size 6: four small Escape chance acupoints, notables Terror and Beneath Notice at the far end. No capability.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Qi Refining | A pickpocket with a contract in their sleeve. Every fight costs about a year of savings | Promissory Paper | The first name goes in the book, and you stop sleeping in the same bed twice |
| Foundation | You pick fights with the rich and old on purpose: an elder with five years left is the best investment in the world | Not-Yet-Used Sheet | First funeral. You weep, convincingly, and go to look at the estate |
| Core Formation | A slum landlord of dead people's caves | Second paper | Each entry costs +1 heart demon and each funeral removes 3, so the gate to Nascent Soul (heart demon 20) opens only when enough of your enemies have died of old age |
| Nascent Soul | You outlived everyone who remembers why you ran | None | The Tribulation invites you. You read the invitation carefully and move house |

Realm lifespans of 120, 200, 500 and 1,000 years are why you climb at all: a creditor a realm up outlives you, and the only way to attend their funeral is to break through.

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Any fixture, three realms of it | Leaves at 2.5 s on 95 % | The size of the blow is not your problem today |
| Mixed, same realm and one up | Leaves at 2.5 s on 95 %, with 5 and 4 lifts | `variants/best-plan-mixed.fight.json` |
| A locking pursuer, same realm, every roll failing | Seven rolls at 0.63, then Down at 21 s. 99.9 % chance of having left | `variants/best-plan-lock-unlucky.fight.json --enemy top_end` |
| A soul striker one realm up | Leaves on 5 % | `variants/best-plan-soul.fight.json --gap 1`. Ledger skips soul. If the second roll fails, Down at 3 s (`variants/best-plan-soul-unlucky.fight.json --gap 1`), with 97.1 % to have left first. Both sides read the fixture's thần thức of 1.0, and `realm_sense` applies the realm's M_ts of 3 |
| An old creditor, with paper | Leaves at 2.5 s, bill doubled | `variants/best-plan-rematch.fight.json --enemy top_end` |
| An old creditor, out of paper | Down at 1 s, as the whole bill lands | `variants/best-plan-rematch-broke.fight.json --enemy top_end`. This is what you are afraid of |
| The Not-Yet-Full | Never leaves. Down at 20 s | `variants/best-plan-vs-not-yet-full.fight.json --gap 2`. Every blow breaks the channel. Take away Held at Table and you leave at 2.5 s, purse in hand (`variants/best-plan-vs-not-yet-full-no-hold.fight.json --gap 2`) |

**Counter:** a hunter whose blows break an escape channel (Held at Table), since a bill does not stop a hit from landing. Then a soul striker, and anyone patient enough to wait until your paper runs out. An ambusher who opens the fight with a 0.5 s art hits before the paper resolves (unmodelled).

## The Nerve Table

Staying longer is the only decision the fight offers, set by the exit's time guard. Mixed enemy, same realm. Files: `variants/best-plan-mixed.fight.json`, then `-nerve-3`, `-nerve-6`, `-nerve-10`, all `--gap 0`.

| Exit guard | Leaves at | Lifts | Health at the door | Bill |
|---|---|---|---|---|
| At once | 2.5 s | 5 | 95 % | 59 % |
| 3 s | 5 s | 10 | 80 % | 178 % |
| 6 s | 8 s | 13 | 65 % | 413 % |
| 10 s | 12 s | 17 | 45 % | 619 % |

The bill is also the share of their estate you can claim, so greed pays twice and fear pays once. Everyone sets this number lower than they should and regrets it for a century.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Technique 2.0 of 2.0. Slots 3 of 3. Talismans and escape arts have no lint: the art lint reads c_art only |
| Validity | PASS | `than_hanh`, `huyen`, `stealth`, `travel_speed_pct` are real ids. `e_art` inside 0.40 to 0.70. Bonus 0.28 at most, inside the 0.3 limit |
| Stack | PASS | Seven forms, identity tested, layers stated as empty on purpose. Overflow is the identity piece, so the critic's closure allows it |
| Scaling | NOT ASSESSED | `m_static` 1.00 against typical 3.27 and top-end 103. No anchor exists for a build with no damage |
| The fight | PASS | Ends in flight in all six matrix fights, with the escape rule run, not assumed. No `cap_hit` lines |
| Reuse | PASS | Slow Wound, Years Owed, Thần Hành Phù, Escape chance reused. Each new piece has a second home |
| NPC use | PASS | All are guards and stock. An NPC with a book is a person hiding from the player, waiting for them to die |
| Counterplay | PASS | Held at Table, soul strikers, lock with patience |
| Originality | PASS | "Best plan" and "goat in passing" are common proverbs from an old list of stratagems, used as idioms. No novel or game names |

## Fight Results

Input: `sheets/best-plan.fight.json`, with `rules/escape.py`, `rules/slow_wound.py` and `rules/best_plan.py`. Observations from `fight_x.py`, a paper model. Rolls are expected values: a roll succeeds when the running total of p reaches 1.

| Enemy | Gap | Result | Time | p | Chance of having left by then | Bill | Years if unskipped |
|---|---|---|---|---|---|---|---|
| typical | 0 | flight | 2.5 s | 0.63 | 86.3 % | 75 % | 0.9 |
| typical | 1 | flight | 2.5 s | 0.83 | 97.1 % | 285 % | 3.4 |
| typical | 2 | flight | 2.5 s | 0.88 | 98.6 % | 1,127 % | 13.5 |
| top_end | 0 | flight | 2.5 s | 0.78 | 95.2 % | 4,838 % | 58.1 |
| top_end | 1 | flight | 2.5 s | 0.83 | 97.1 % | 17,635 % | 211.6 |
| top_end | 2 | flight | 2.5 s | 0.88 | 98.6 % | 63,144 % | 757.7 |

**Bracket:** `variants/best-plan-unlucky.fight.json`, every roll failing, runs out of paper after seven rolls and is Down at 21 s against a top-end two up. **Second realm:** `variants/best-plan-foundation.fight.json --matrix`, all six fights end in flight at 2.5 s on 95 %. **Last resort:** `variants/best-plan-last-sheet.fight.json --enemy top_end`, every roll failing, fires the Not-Yet-Used Sheet at 16 s at p 0.95.

The index's W and L columns have no flight, so `merge.py` will show this build as losses. It lost nothing.

**Unmodelled:** what a lift takes, the Creditors' Book after the fight, Dies Later, heart demon, and which side opens the fight.

## New Concepts

**The Creditors' Book (Trái Chủ Bộ).** A per-life list of `{creditor, share}`, written on a Fled result under Skipped Bill.

- **Rule:** Combat rule 14 adds the ledger left to the result. World Database holds the list. In a later fight against a creditor, their share stands in the ledger at t = 0, and if no Slow Wound is running at the first pulse, all of it lands at once. A new entry adds +1 heart demon.
- **Bounds:** an entry ends with the creditor's life. It can only be paid down at 5 % of health a second, in person.
- **Breakdown line:** "Owed to Elder of the Ninth Peak: 4,838 % of maximum health."
- **Other builds:** The Incense Vigil's Years Owed, The Already-Waited's Owed Wait, any sect blacklist.
- **NPCs:** they keep books too, so somewhere a person the player once struck is reading the obituaries with hope.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Promissory Paper | Needs rule | A talisman may grant a rule-swap for one fight. Slow Wound itself is a Needs rule from The Incense Vigil |
| Skipped Bill, Creditors' Book | Needs rule | Combat rule 14, World Database |
| Dies Later | Needs rule | Living World Tick reports a creditor's death; Event Engine offers the estate |
| Beneath Notice | Needs rule | Formulas I: a modifier may replace `escape_realm_step` |
| Cold Feet | Needs rule | Rule 13: an art tag may start below its full cooldown |
| Goat in Passing | Needs rule | Rule 14 carries lifted goods, moved by the caller on a Fled result |
| Terror, Full Sleeve, Folded Corner | Needs key | Escape-tag keys and a read of carried stock |
| Thần Hành Phù, Not-Yet-Used Sheet, Escape chance | Needs key | An art record with `e_art`; the catalogue row |

## Also Considered

- The Gambler's Sleeve (Đổ Tụ Đạo): twenty random talismans fired blind, fortune as the stat, but the luck was doing the design.
- The Last Man Out (Hậu Thoái): a sworn retreat that wins by holding the door for one's own side, which needs the mass-battle rating more than a duel.

# The Brush Fee (Nhuận Bút)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "Copies the enemy's art."
> **Direction**: A copyist whose copies are billed to the author. The copy is the delivery; the invoice is the weapon.
> **Realm span**: Foundation Establishment – Deity Transformation · **Power level**: strong · **Use**: player build to aim for, or a hated sect of forgers
> **Fit**: 3 Fits today · 10 Needs key · 5 Needs rule
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: a copied art has no lint of its own, and thần thức is not totalled)

## The Spine

- **The channel:** art hits on copied records, through all five layers, in the instant the enemy fires. The ward they would have met has just been billed away.
- **The enabler:** the Stele-Rubbing Scripture. Art slots hold Rubbings, which are blank until an enemy art fires. It closes having anything of your own to do.
- **The loop:** the enemy fires one art. Every Rubbing copies it, and each copy charges its cost to the enemy's pool in the same cost step. They are empty before the first hit lands.
- **The engine:** a top-end cultivator's toughness is mostly linh lực. The fee removes it, and an ordinary volley then reaches a body that was never built to be hit.
- **The sacrifice:** no first move, no art of your own, and nothing at all against an enemy who fires none.
- **The arc:** first a thief of small arts. Later a creditor who wants their enemy solvent, because a bankrupt author writes nothing worth copying. Patronage is meant to do that, and as written it cannot yet: see What the repair changed.

## The Legend

Sects once hired copyists to reproduce their manuals, and to keep the contents safe they hired people who were forbidden to learn. A copyist traced strokes for forty years without being taught a word of what they meant. They were paid by the page. One scripture hall stopped paying. The next time its elder fired an art in public, a copyist in the crowd took a rubbing of it in the air, and the invoice went to the elder's own meridians.

They are not liked. Each carries a ledger, and most can no longer write their own name in their own hand. Sects whose arts have been rubbed offer bounties, and the copyists have noticed the bounties are always worded by someone who has never paid for anything.

## How It Fights

Nothing happens until the enemy acts. Then their first art goes off, and five copies of it go off with it, all paid from their pool. **The signature moment:** a Core Formation copyist with an ordinary multiplier, about 19 against a top-end 210, meets a top-end build. Both fall at t = 1. The top-end build wins the double knockout on overkill, and walks out of the instant on 1 health, in front of everyone.

## Enabler

**Stele-Rubbing Scripture (Thác Bi Kinh)**, a secret art copied from nobody knows where. **Opens:** Rubbings, arts with no content of their own. **Closes:** those slots hold nothing of yours, a fight against someone who fires no art is a fight with your basic attack alone, and your element modifiers do not reach a copy unless the copied art carries the tag. So the stack keys on a new source tag, `copied`.

A Rubbing fires in the instant an enemy art fires, once per its own timer. It takes that art's `c_art`, kind and tags, and uses your layers. It cannot read a caster whose thần thức puts your ratio below `rho_min` 0.25. One realm up the ratio is about 0.33, and two up about 0.1, so two realms up the build needs about 2.5 times the thần thức of its peers just to read. The reference enemies have equal sense, so `sheets/brush-fee.fight.json` leaves the gate open and `variants/brush-fee-unread.fight.json` closes it at ratio 0.1.

## The Stack

Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Rubbings | `c_art` is the original's | Rule swap | art | none | ○ | Secret art | any mimic, Blank Slip users |
| Rate | The enemy's firing | Your rate is theirs; art speed only matters against arts under 1 s | Timing | art | none | ● | none | a real sacrifice |
| Multiplier | Copied Art Damage | +20 to arts with the `copied` tag | Increased | art | L1 | ○ | Way of Ink stat line | any talisman thief |
| Multiplier | Practised Stroke (Thuần Bút) | +8 per firing of the original this fight, to +64 | Per | art | L2 | ○ | Way of Ink | any repeating art, Late Bloom builds |
| Multiplier | Dark Ink (Nùng Mặc) | +50 from Way of Ink art nodes on `copied` | More | art | L2 | ○ | Way of Ink | any talisman thief |
| Multiplier | Artifact attack | +110 from gear | Gear | any | L3 | ● | Artifacts | every build |
| Multiplier | Sized Paper (Phàn Chỉ) | +30 to `copied` and talisman hits, from treated paper prepared before the fight | More | art | L4 | ○ | Preparation | any talisman build |
| Multiplier | Bare Vessel (Lộ Đỉnh) | +30 while the enemy is under 5 % linh lực. **Reused from the Burial Shroud**. Lesser grade, +30. The same modifier has a greater grade, +80, in Great Tonic, Remnant Host, Struck Name and Taster's Fever; one size would change fights | Conditional | art, basic | L5 | ○ | Sealed cluster | any ward-breaker |
| Multiplier | Full Sea (Mãn Hải) | +30 while your linh lực is above 80 %. **Catalogue keystone** | Conditional | art | L5 | ○ | Tree | any build that does not spend |
| Reach | Deep Reading (Tế Độc) | `rho_min` is 0.15 for your Rubbings | Cap shift | art | none | ○ | Way of Ink | any soul build, as a read on soul arts |
| Reach | Usurious Ink (Cao Lợi Mặc) | When a fee is charged at double, curse: +50 % art cost, 2 pulses | Trigger | art | none | ○ | Bleeding Ink | any starving build |
| Past the cap | **Patronage (Bảo Trợ)** | When the enemy cannot afford a ready art, you pay its cost, while your pool is above that cost | Trade | art | none | ○ | Way of Ink | any build that forces the enemy to act |
| Fuel | **Brush Fee (Nhuận Bút)** | The cost of a `copied` art is charged to the original's caster. They pay what they have | Rule swap | art | none | ○ | Way of Ink keystone | any mimic |
| Survival | Common ward at a full pool | You spend nothing, so the ward has all of it | none | any | none | ● | Ward | any efficient build |
| Answer | Kept Rubbing (Tàng Bản) | A Rubbing keeps its last copy between fights. It fires on a 3 s timer at your own cost until it copies something new | Borrow | art | none | ○ | Way of Ink | any loadout that reads the last fight |

**Identity piece:** Brush Fee. With the fee off and the copies still free (`--without brush_fee`), a win at 1 s one realm up becomes a double knockout lost at 2 s, and a top-end enemy keeps 60 % instead of 0 %. With the copies paid from your own pool, as any art would be (`variants/brush-fee-self-paid.fight.json`), one realm up leaves the enemy on 64 % and you dead.
**Empty rungs:** Rate is a sacrifice, the point of the build. Crit is left at the tree's level because copies need no help at an equal realm, and it is a gap one realm up, not a choice.

| Layer | Points at Core Formation (a copy at t = 1) | Multiplier | Sources |
|---|---|---|---|
| L1 | 176 | ×2.76 | `attack_pct` 156, Copied Art Damage 20 |
| L2 | 58 | ×1.58 | Way of Ink 50, Practised Stroke 8, rising per firing |
| L3 | 110 | ×2.10 | Gear |
| L4 | 30 | ×1.30 | Sized Paper; a blind fight loses it and still wins one realm up (`variants/brush-fee-blind.fight.json`) |
| L5 | 60 | ×1.60 | Bare Vessel, Full Sea |

M for a copy is about 19.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Metal and Water, a generating pair | Metal main feeds a Water secret art, so harmony pays `main_generates` 1.15 |
| Key talents | Soul strength, then comprehension | Thần thức decides who can be read |
| Main technique | `thien_kim`, as shipped | Reused data. The build needs nothing from its main but the generating pair |
| The Way (Đạo) | Way of Ink (below) | Holds the keystone |

## Công Pháp

### Stele-Rubbing Scripture (Thác Bi Kinh) — secret, Thiên giai

No two copies of it agree, and all of them work.

```json
{"id": "thac_bi_kinh", "name": "Thác Bi Kinh", "tier": 3, "tech_kind": "secret",
 "names": ["thuy"], "layers": 15,
 "bonuses": [{"stat": "than_thuc_pct", "value": 20}, {"stat": "linh_luc_pct", "value": 15},
             {"stat": "tam_ma_resist_pct", "value": 10}],
 "abilities": [{"ability_id": "first_impression", "unlock_layer": 3},
               {"ability_id": "reversed_proof", "unlock_layer": 7},
               {"ability_id": "bleeding_ink", "unlock_layer": 11}],
 "seal_clusters": [], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 20/15 + 15/20 + 10/15 = 2.75 of 4.0, the largest 1.33 under the 1.5 single cap

## Arts

All are Rubbings: `cost_share` 0 of yours, 1 s timer, no guard, tags `copied` plus the original's.

| Art | Source, layer | Kind | c_art | Fee | Fit |
|---|---|---|---|---|---|
| First Impression (Sơ Thác) | Scripture, 3 | as copied | ×1 | ×1 | Needs rule |
| Reversed Proof (Phản Ấn) | Scripture, 7 | swapped, body and qi | ×1 | ×1 | Needs rule |
| Bleeding Ink (Thẩm Mặc) | Scripture, 11 | as copied | ×0.5 | ×2, with Usurious Ink | Needs rule |
| Fair Copy (Thiện Bản) | Way of Ink, art node | as copied | ×1 | ×1 | Needs rule |
| Blank Slip (Bạch Thiếp) | Talisman, stock 2 | as copied | ×1 | ×1 | Needs key |

**Effects.** First Impression is the hit alone. Reversed Proof meets the other side of the ward, since qi drains harder and body leaks more. Bleeding Ink is the invoice. Fair Copy also carries the original's status and curse. Blank Slip needs no technique, so anyone can carry one Rubbing, which is the build's way into the wider game. **Description:** an ink rubbing, a mirror print, a wet page, a clean page, and a slip of paper you hope is empty.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Foundation Establishment | 4 | First, Reversed, Bleeding, Fair | Common | Fee total 0.90 with the original |
| Core Formation | 5 | First, Reversed, Bleeding, Fair, Blank Slip | Common | Fee total 1.05: one firing of a 0.15 art empties them |
| Nascent Soul | 6 | As above, plus a Kept Rubbing | Common | A planned art from your last fight |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Bone brush | Artifact, weapon | `cham`, generated | Cheap on thần thức, which matters here | Fits today |
| Blank Slip | Talisman | new | The fifth Rubbing | Needs key |
| Sized Paper | Preparation | new | Fills L4 | Needs key |

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Thần thức (`than_thuc_pct`) | Notables | The reading gate | Fits today |
| 2 | `attack_pct` | 35 % of W | Copies use your layers | Fits today |
| 3 | Full Sea | Keystone | You do not spend | Needs key |

## Đạo

**Way of Ink (Mặc Đạo), proposal.** The way of copying, invoices and archives. No existing Đạo reads as this.

- **Requirement:** a technique of kind `secret` (rule 5).
- **`theme_stats`:** `than_thuc_pct`, `ngo_tinh`, `tam_ma_resist_pct`.
- **Size:** 20 nodes, 60 points. Three branches and a keystone.

| Branch | Nodes | Signature nodes |
|---|---|---|
| **Rubbing (Thác)**, the hand | 7: 3 stat lines, 2 T1, 2 T2 | Copied Art Damage (T1), Dark Ink (T1), Practised Stroke (T2), **Fair Copy** (art, T2) |
| **Ledger (Trướng)**, the debt | 6: 2 stat lines, 2 T1, 2 T2 | Itemised Bill (T1: the Breakdown names each fee), Late Payment (T1: a fee unpaid in full lengthens a curse by 1 pulse), Deep Reading (T2), **Patronage** (T2) |
| **Archive (Tàng)**, the shelf | 6: 3 stat lines, 1 T1, 2 T2 | Marginalia (T1: reveals more of an enemy's profile in preparation), **Kept Rubbing** (T2), Forged Manual (T2: once a realm, write a Hoàng giai copy of a technique you fought, for sale or use) |
| **Keystone** | 1: T3 and a 4 W line | **Brush Fee** |

**Node lint, Formulas D1, first guess.** Each branch opens with an 8 W stat line. Branches 80, 72 and 70 W, means 11.4, 12.0 and 11.7, inside 9.9–14.9. Keystone 34 W. Total 256 W over 20, mean 12.8, inside 11.2–13.7. Routes: 130 W over 10 (13.0), 122 W over 9 (13.6), 120 W over 9 (13.3), all at least 11.2. No ceiling is raised and no root factor touched (rule 4). Deep Reading is a bounded cap shift on one constant, for one art family. Art nodes wait for the fight to be built, as with every Đạo.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | Blank Slip and a basic attack | First Impression, the Way's glimpse | Tracing an art you were never taught, and it works |
| Core Formation | One firing, one volley, one empty enemy | Brush Fee | The first invoice |
| Nascent Soul | The same volley, and a boss that outlasts it is still a loss | Kept Rubbing | Lending linh lực to someone who is trying to kill you, if the rule ever allows it |
| Deity Transformation | Reads anything it can reach | Deep Reading | No longer sure which hand is their own |

## Matchups

Core Formation. Each row is read from `--matrix` on the file named, in `variants/` unless it says `main`, which is `sheets/brush-fee.fight.json`.

| Enemy | Result | Why | File |
|---|---|---|---|
| Typical, same realm | Wins at 1 s, 80 % health | The fee strips the ward before the volley | main |
| Typical, one realm up | Wins at 1 s, 32 % health | The build's defining fight | main |
| Typical, two realms up | Loses at 1 s, enemy on 54 % | With the gate open. Closed, nothing is copied and the enemy stays on 100 % | main; `brush-fee-unread.fight.json` |
| **Top-end, same realm** | **Double knockout, lost on overkill** | The enemy is left on 1 health | main |
| Top-end, one realm up | Loses at 1 s, enemy on 15 % | The pool goes to 0, so the ward is gone and Bare Vessel is on | main |
| Thể tu with arts, same realm | Wins at 1 s, 80 % health | `n_body` 2.5, `a_b` 5, `t_b` 3. Its guard absorbs more, but the volley is still free | `brush-fee-thick-body.fight.json` |
| Heavy art, 10 s, `c_art` 6.25 | Double knockout, won at 10 s | The heaviest art makes the heaviest copies | `brush-fee-heavy-art.fight.json` |
| Cheap arts, cost 0.04, same realm | Wins at 1 s, 83 % health | Copies alone are enough | `brush-fee-cheap-art.fight.json` |
| **Cheap arts, one realm up** | **Double knockout, lost at 2 s** | Fee of only 0.24 a volley. Usurious Ink does not flip this | `brush-fee-cheap-art.fight.json`, `brush-fee-cheap-art-no-usury.fight.json` |
| **No arts, one realm up** | **Loses at 5 s, enemy on 91 %** | Nothing to copy. Kept Rubbing gets it to 72 %, and still loses at 3 s | `brush-fee-no-art.fight.json`, `brush-fee-kept-rubbing.fight.json` |
| Boss ×4, same realm | Wins at 1 s, 80 % health | One volley still finishes it | `brush-fee-boss-x4.fight.json` |
| Boss ×8, plain | Loses at 13 s, enemy on 7 % | One volley short. See below | `brush-fee-boss-x8.fight.json` |
| Boss ×8, Patronage | **The same loss: 13 s, enemy on 7 %** | Patronage never pays. See below | `brush-fee-boss-x8-patronage.fight.json` |

**Counter:** a body cultivator or a fist saint who fires nothing, or any strong enemy on cheap arts. Soul is the third: a caster too far above you cannot be read.

## Checks

Each result is PASS, FAIL or NOT ASSESSED, with the reason.

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Scripture 2.75 of 4.0, slots 5 of 5. A Rubbing has no `c_art` in the file, so the lint prints nothing for it. That is a real hole, listed under New Content Needed: a copy has no lint of its own. Thần thức not totalled |
| Validity | PASS | `thuy`, `thien`, `thien_kim`, `cham`, `secret` are real; Thiên giai reaches Deity Transformation; Metal generates Water |
| Stack | PASS | Ten forms. Rate named as a sacrifice. Identity test: see above; `--without brush_fee` changes results at every gap and against both enemies but the same-realm typical win |
| Scaling | PASS | Copy M about 19, above typical 5.48, below top-end 210. `m_static` 5.38 is channel-wide only |
| The fight | PASS | Constants 60 of 60, selftest clean. `rules/rubbing.py` and `rules/brush_fee.py` run the engine, so nothing stands in for it. No cap hit. Patronage ran and paid nothing, which is a finding about the rule, not about the engine |
| Reuse | PASS | Bare Vessel, Full Sea and the shipped `thien_kim`. No signature modifiers |
| NPC use | PASS | Slots and arts only. Breakdown line: "Copied from [name]; 0.15 charged to [name]" |
| Counterplay | PASS | No-art fighters, cheap arts, a soul out of reach |
| Originality | PASS | Rubbing, invoice and royalty images; nothing from existing works |

## Fight Results

Input: `sheets/brush-fee.fight.json`, rules `rubbing` and `brush_fee`. Observations from `_tools/fight_x.py`, a paper model with expected values for chance, not the game.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Win, 80 % health | 1 s | never | none |
| typical | 1 | Win, 32 % health | 1 s | never | none |
| typical | 2 | Loss, enemy on 54 % | 1 s | 1 s | none |
| top_end | 0 | Double knockout, lost on overkill | 1 s | 1 s | none |
| top_end | 1 | Loss, enemy on 15 % | 1 s | 1 s | none |
| top_end | 2 | Loss, enemy on 82 % | 1 s | 1 s | none |

The calculator prints the enemy on 0 % at gap 0, and rule 10 leaves the winner of a double knockout at 1 health.

**What the repair changed.** The first pass stood the fee in as zero-damage shadow arts on the enemy, each skipped when the enemy could not afford it, so an enemy kept a little pool and a little ward. The rule says they pay what they have. With a real plug-in the pool reaches 0 before the first hit, Bare Vessel turns on, and every lost fight in this table is closer than first written. The result of each fight is unchanged. The claim about Patronage did not survive, below.

**The surprises.**

1. **The build was meant to be a mirror, and it is a tax.** Spreading the Rubbings over 2, 3 and 4 s timers loses one realm up at 2 s with the enemy on 82 % (`variants/brush-fee-spread-timers.fight.json`). Concentrating them on one 1 s timer wins at 1 s. The fee only matters if it lands before the volley, all at once.
2. **Top-end defence is mostly linh lực.** The same volley, paid for by yourself, leaves a top-end enemy on 69 % (`variants/brush-fee-self-paid.fight.json`). Billed to them, it takes them to 0. Foundation Establishment and Nascent Soul reach the same double knockout.
3. **The fee kills its own engine, and Patronage does not save it.** An empty enemy fires nothing, so nothing is copied. Against a ×8 boss the first volley cannot finish it, and the build dies at 13 s with the boss on 7 %. The sheet used to say that Patronage ends that fight at 2 s. Run as the rule is written, it never pays: `patronage_paid` is 0 in all six fights of `variants/brush-fee-boss-x8-patronage.fight.json`, because the cost is a share of the boss's ×8 pool, which is more than your whole pool, and the result is the plain loss. At ×4 the cost is within reach, but the same-realm fight is over at 1 s and the others end before you have the pool (`variants/brush-fee-boss-x4-patronage.fight.json`). Nothing here shows that paying your enemy works.

**Other realms:** Foundation Establishment with four Rubbings wins at 79 % and, one up, 31 % (`variants/brush-fee-foundation.fight.json`). Nascent Soul with five wins at 82 % and, one up, 44 % (`variants/brush-fee-nascent.fight.json`). Both take a top-end enemy to a double knockout lost on overkill. Their gear is a first guess.

**Unmodelled:** Fair Copy's carried statuses, since no reference enemy's art carries one. Kept Rubbing is three plain 3 s arts at your own cost, which is what it is while the enemy fires nothing.

## New Concepts

**Mimic art.** An art record with no content, which takes `c_art`, kind and tags from the enemy art fired in that instant, plus a new `source` tag, `copied`. **Rule:** Combat rule 6 (tag), rule 10 (a Rubbing joins the instant after both sides' costs are paid), rule 13 (the record). **Bounds:** one firing per own timer, slots, the enemy's own firing rate, `rho_min`. The fee is bounded by the enemy's pool, so one volley empties a pool at a 0.15 art. **Breakdown:** "Copied from [name]." **Other builds served:** a talisman thief on Blank Slips, and a boss that copies the player's art. **NPCs:** yes, by slotting one.

**Questions for the user.** Should a copy be able to exceed what the copier could learn, given that a copy has no lint of its own? Is it acceptable that a top-end build's toughness can be billed away? The bound is that cheap arts dodge it, and that it still loses the double knockout. Patronage as written never pays, because a boss's cost is measured in the boss's pool: should it be measured in yours, or be cut?

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Rubbings (four arts) | Needs rule | The mimic record above |
| A copy's art lint | Needs rule | Deliberately over the lint. A Rubbing costs its owner nothing, so at `art_lint_max(0, 1)` = 1.00 a copied `c_art` 2.0 is over. The reason is the design: a copy's budget is the original's, paid by the original's caster. Formulas C needs to say so |
| Brush Fee | Needs rule | Formulas E: a cost charged to another side, and what "pay what they have" does |
| Patronage | Needs rule | Formulas E: the other way round, your pool paying their cost. Decide first whose pool sizes the cost: as written it never pays a boss |
| Kept Rubbing | Needs rule | Combat rule 1: a stored art record entering `compile` from the last fight |
| Deep Reading | Needs rule | A `rho_min` override for one art family |
| Way of Ink | Needs key | A `dao.json` entry; its art node waits on the fight |
| Practised Stroke, Copied Art Damage, Dark Ink, Sized Paper, Usurious Ink, Bare Vessel, Full Sea | Needs key | Tag and per-firing keys |
| Stele-Rubbing Scripture, Blank Slip | Needs key | Ability catalogue, a talisman entry |

## Also Considered

- **Perfect Forgery:** a copy reads the enemy's multiplier instead of yours, useless against the weak and lethal to the strong; it leaves nothing to stack and overlaps seed 57.
- **Library of the Dead:** keep the art of each person you beat and fight from a shelf; a pure collection game with no fight of its own, and its best idea survives as Kept Rubbing.

# The Transplant (Di Căn Lộ)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: "The Transplant: a root cut from a corpse, which the body rejects on a clock, so purity falls each decade unless you feed it donors of the same element. You end up hunting for parts. Sincere dread rather than a smug chronicle."
> **Direction**: The root is the engine, and it spends itself. It pays for your arts out of its own purity, so every hard fight takes years off it, and the only thing that puts years back is another person's root. Rejection grows with each donor, so the hunger compounds.
> **Realm span**: Foundation Establishment – Nascent Soul, defined at Nascent Soul · **Power level**: strong at its own realm while purity holds, helpless once it does not · **Use**: player build, or the thing a sect's infirmary is afraid of
> **Fit**: 6 Fits today · 9 Needs key · 3 Needs rule
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (Budgets: thần thức not totalled, and L2 has no W price; NPC use: rule 15 gives NPCs no root changes yet)

## The Spine

- **The channel:** art hits, Wood-tagged. Three arts at the top of the lint, cost 0.25, on a 1 s cooldown. L1, L2 and L3 filled. L4 empty in a blind fight, L5 empty.
- **The enabler:** the Grafted Root. It opens a second payer: the root pays its purity share of each Wood art's cost, so a spend that should empty the sea in one volley leaves the ward standing. It closes purity's one promise, that it never falls.
- **The loop:** fight to take a donor, spend purity to win, feed the root, wait for the next decade to take it back.
- **The engine:** purity is at once the build's damage, its fuel and its clock. A fight lowers it, a donor raises it, and each donor makes the next decade worse.
- **The sacrifice:** peace. There is no end state in which the root stops needing someone.
- **The arc:** a mercy at Foundation Establishment. A habit by Core Formation. By the fourth century of Nascent Soul, a census.

## The Legend

The bonesetter at the quarry town lost their root in a kiln collapse at forty, and their apprentice died of fever the same winter with a Wood root that a sect would have paid for. The books say a root dies with its owner. The bonesetter had the body for one more night and nobody left to ask. It took. For ten years they were grateful and went to the grave every spring, and they healed more people than they ever had with their own.

Then the left hand began to go cold at night, a little further up each year. They found they could tell, without trying, the Wood in anyone who came close: in a patient, in a neighbour, in the child who carried water to the gate, who was fifteen and purer than anyone they had ever met. They stood at the gate a long time. That night they packed the knife and walked until they could no longer feel the child, and they have not stopped walking, and they know exactly how far it is back.

## How It Fights

Three heavy Wood arts every second, far past what any sea could pay. The ward stays up because the root pays first. Against an equal it is over in two or three volleys. The fights it wants are the ones where the other person runs, because a corpse three days old is a donor and an empty road is not.

**The signature moment:** the same character, the same enemy, the only change the root's purity. Purity 75 wins at 2 s on 79 %. Purity 30 dies at 5 s with the enemy on 16 %. Nothing else happened. Seventy-five years passed with no donor (`variants/the-transplant-mixed.fight.json`, `variants/the-transplant-p30-mixed.fight.json`).

## The Root

**Grafted Root (Di Thực Căn).** The first version let the root pay everything, and purity did not matter, so the root now pays only its purity share.

| Field | Value |
|---|---|
| **Origin** | A fourth origin, Grafted (Di Thực), beside innate, convergence and transmutation |
| **Requirement** | An element the root does not own. A donor holding that element at purity 30 or more, dead no more than 3 days, or alive. Foundation Establishment or above. The Root-Cutter's Knife |
| **Acquisition** | Never rolled at birth. One operation, chance 0.4 + donor purity ÷ 200. On success the element is owned at round(0.9 × donor purity). On failure nothing is gained, and the penalties of a failed breakthrough apply: +15 heart demon, vitality −40 % |
| **Per purity point** | The root pays 1 % of the cost of arts naming its element, out of purity, at 2 purity per full share of cost. +0.5 L2 points on those arts. Purity also scales the element as usual |
| **Below purity 40** | Cold Graft: each such art also costs 0.1 % of maximum health per point under 40 |
| **Below purity 10** | The root is dead. The element is lost and its arts cannot fire. Another graft may be cut in |
| **Rejection** | Each decade purity falls by 6 + donors fed so far |
| **Feeding** | A donor of the same element, by the same rules: +round(0.25 × donor purity), up to 100, +3 heart demon. No operation roll. A flight leaves nothing to feed on |

```json
{"id": "di_thuc", "name": "Di Thực", "name_en": "Graft", "origin": "grafted", "requires": [],
 "desc": "A dead root in a living body. It pays for what it can, and it does not stay."}
"di_thuc": [{"stat": "graft_cost_share_pct", "per_purity": 1.00}, {"stat": "graft_art_more", "per_purity": 0.50}]
```

**Meridian Map.** A graft has no sector of its own. It is a base element with a flag, so its element sector reads `0.5 + purity / 100` exactly as rule 8 says: 1.25 at purity 75, 0.75 at 25. The scale moves as purity falls, so bought acupoints lose value decade by decade. If the root dies the sector reads the absent 0.25, and nothing is refunded. Bridges average as usual. The player watches one arm of the wheel go dim. Roads stay exact.

**Existing variants.** The graft breaks rule 11 in one place only: it counts as a base element while it lives, so it changes `n_base`, the tier, the pairs and the curve row, and a Fire root given a Metal graft makes Thunder eligible (rule 13's roll). Variants are never lost, so a Thunder formed that way stays when the graft dies, its purity recomputed to the clamp of 1 and its sector at 0.51. Tẩy Tủy Đan works on a graft, when it is the weakest owned element, and does not touch the clock. Linh Căn Quả cannot add an element a graft holds. Mutation Awakening rolls as normal.

**The cost.** Rule 14 is gone for this element. Heart demon rises 3 per donor against a decay of 10 a decade. Every sect treats a root-cutter as it treats a plague carrier, and a holder can feel the same element in anyone nearby, which they cannot turn off.

## The Stack

Sizes on new modifiers are first guesses. Nearly everything here is an ordinary catalogue row: the root is the strange piece.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| Base | Arts at cost 0.25 | c_art 4.00, the lint's maximum at 1 s | none | art | none | ○ | Technique | any burst build |
| Multiplier | Damage (`attack_pct`) | +110 | Increased | any | L1 | ● | Tree | everyone |
| Multiplier | Wood damage | +60 unscaled, in the Wood sector, so +75 at purity 75 | Increased | art | L1 | ○ catalogue | Tree | any Wood build |
| Multiplier | Foreign Edge (Dị Phong) | +0.5 L2 points per purity point on arts naming the graft | Per | art | L2 | ○ | Root | any root with a named element |
| Multiplier | Root-Cutter's Knife | +30 | Increased | any | L3 | ○ | Artifact | any weapon |
| Reach | Held at Table (Lưu Khách) | **Reused from The Not-Yet-Full.** A hit of 20 % of the target's maximum health or more breaks an open escape channel | Trigger | any | none | ○ | Technique | **Reused** |
| Fuel | **The Root Pays (Căn Phó)** | The root pays its purity share of an art's cost, out of purity | Trade | art | none | ○ | Root | any build wanting a second payer for one element |
| Fuel | Cold Graft (Hàn Tiếp) | Below purity 40, those arts cost health | Trade | art | none | ○ | Root | any decaying enabler |
| Survival | Ward strength, ward efficiency | `ws` 173, `we` 99, gear included | Increased | any | none | ● | Tree, gear | everyone |
| Survival | Maximum health, maximum linh lực | `n_body` 1.92, `n_qi` 2.48 | Increased | any | none | ● | Tree | everyone |
| Survival | Body guard | +37 | Increased | any | none | ● | Tree | everyone |

**Identity piece:** The Root Pays. See the swap test.

**The standing rule, used unplanned.** Held at Table was written so a glutton's meal could not leave. Here it is what makes a hunt a hunt. In the main fight the donor runs at the first wound. With it: knockout at 3 s, donor taken, net +11.62 purity. `--without held_at_table`: the donor flees at 2 s on 6 %, nothing is fed, and the fight cost 2.25 purity for nothing.

**Empty rungs:** Rate and crit are sacrifices, and the arts are already at 1 s. Past the cap is empty, since nothing here reaches one. L5 is a gap.

| Layer | Points at Nascent Soul, purity 75 | Multiplier | Sources |
|---|---|---|---|
| L1 | 185 on Wood arts | ×2.85 | Damage 110, Wood 75 |
| L2 | 37.5 on Wood arts | ×1.38 | Foreign Edge |
| L3 | 30 | ×1.30 | Knife |
| L4 | 0 | ×1.00 | Blind. +40 in `variants/the-transplant-foreseen.fight.json` |
| L5 | 0 | ×1.00 | Gap |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Any root without Wood, plus the graft | The graft needs an element you do not own |
| Key talents | None | Purity comes from someone else |
| The Way (Đạo) | None. Sense and fortune stay at their defaults (1.0 and 50) in every file | The build is finished without one |

## Công Pháp

### Scion Method (Tiếp Mộc Quyết) — main, Địa giai

A gardener's manual for keeping a cut branch alive on a stranger's trunk, with the word branch crossed out.

```json
{"id": "tiep_moc_quyet", "name": "Tiếp Mộc Quyết", "tier": 2, "tech_kind": "main",
 "names": ["moc"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 12}, {"stat": "khi_huyet_pct", "value": 8}],
 "abilities": [{"ability_id": "tiep_chi", "unlock_layer": 2}, {"ability_id": "xuyen_tam", "unlock_layer": 4}, {"ability_id": "bac_bi", "unlock_layer": 7}],
 "seal_clusters": [], "origin": "authored"}
```

**Fit:** Needs key · **Budget:** 12/20 + 8/15 = 1.13 of 3.0.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Grafted Branch (Tiếp Chi) | Method, 2 | body, Wood | 4.00 | 0.25 | 1 s | none | Needs key |
| Through the Heartwood (Xuyên Tâm) | Method, 4 | qi, Wood | 4.00 | 0.25 | 1 s | none | Needs key |
| Stripped Bark (Bác Bì) | Method, 7 | body, Wood | 4.00 | 0.25 | 1 s | none | Needs key |

**Effect:** a hit each. **Description:** what a surgeon's hands learn to do when they stop being careful.

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Root-Cutter's Knife (Cát Căn Đao) | Artifact, weapon | Any blade, named | L3 +30. Required for the operation | Needs key |
| Suppressing Pill (Ức Dị Đan) | Pill | New | For one decade, rejection is 2 lower and `body_guard_pct` 15 lower, with toxicity at Tẩy Tủy Đan's level. Medicine that lowers the body's guard so it stops fighting the root | Needs key |

The pill does what such medicine does: it buys time from the body by weakening the body. In the main fight the 15 points of guard change nothing (`variants/the-transplant-clock-pill.fight.json`: 3 s on 74 %), so its real price is toxicity. It delays the end by 70 years.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Foundation Establishment | A healer who hits too hard | The graft, one donor | Purity 75 wins at 2 s on 70 % (`variants/the-transplant-foundation.fight.json`) |
| Core Formation | Careful, one donor in three decades | Stripped Bark | The hand goes cold |
| Nascent Soul | A hunter | The clock turns | Three donors a decade by the third century |

## The Clock

Arithmetic on the rule, printed by `variants/the-transplant-clock.fight.json`: start at purity 75, hold purity at 45, donors of purity 50 giving +12, rejection 6 + donors fed. The world target is 5,000 cultivators, and the birth weights put Wood in 37.5 % of them, so 1,875 holders.

| Decade | Rejection | Donors this decade | Donors in all |
|---|---|---|---|
| 10 | 9 | 1 | 4 |
| 20 | 20 | 1 | 15 |
| 30 | 44 | 3 | 41 |
| 40 | 97 | 8 | 99 |
| 50 | 216 | 18 | 228 |
| 60 | 481 | 40 | 515 |
| 70 | 1,071 | 90 | 1,155 |
| 77 | | | 1,875: the world is out of Wood |

**A Nascent Soul lives 1,000 years. The graft eats every Wood root in the world by year 770.** The need doubles about every 85 years. With the Suppressing Pill all the way, it is decade 84 (`variants/the-transplant-clock-pill.fight.json`). This table is kind: it ignores the purity each hunt costs. Nobody reaches the end of it, and the player will see that long before they get there, which is the dread. Each donor is +3 heart demon against a decay of 10 a decade, so from about the third century heart demon only rises.

Purity is rolled at birth and has nothing to do with realm. The best donor in any sect is usually not an elder.

## Swap Test

Same character, the root swapped for a natural Wood root at purity 75 with the same sector scale. Save files named.

| Fight | Grafted | Plain, same arts | Plain, arts rebuilt for one sea |
|---|---|---|---|
| Mixed enemy | Win, 2 s on 79 % (`-mixed`) | **Dead at 3 s, enemy on 57 %** (`-plain-mixed`) | **Dead at 3 s, enemy on 30 %** (`-plain-best-mixed`) |
| Main fight, the running donor | Win, 3 s on 74 %, donor taken | Donor flees at 2 s on 81 %, nothing fed (`-plain`) | Donor flees at 2 s on 77 % (`-plain-best`) |

`--without grafted_root` on the main file: the donor flees at 2 s on 86 %.

## Matchups

Main fight: `sheets/the-transplant.fight.json`, a Nascent Soul with the mixed arts, `n_body` 4, an escape art and every roll a success. The rest are saved beside it.

| Purity | Main fight | Mixed enemy |
|---|---|---|
| 90 | Win, 2 s on 79 % (`-p90`) | Win, 2 s on 79 %, pool 63 % (`-p90-mixed`) |
| 75 | Win, 3 s on 74 % | Win, 2 s on 79 %, pool 40 % (`-mixed`) |
| 60 | Win, 3 s on 74 % (`-p60`) | Win, 2 s on 79 %, pool 18 % (`-p60-mixed`) |
| 45 | **Dead at 6 s, enemy on 25 %** (`-p45`) | Win, 2 s on 61 %, pool 0 (`-p45-mixed`) |
| 30 | Donor flees at 2 s on 61 % (`-p30`) | **Dead at 5 s, enemy on 16 %** (`-p30-mixed`) |
| 15 | Donor flees at 2 s on 77 % (`-p15`) | **Dead at 3 s, enemy on 47 %** (`-p15-mixed`) |

| Enemy | Result | File |
|---|---|---|
| One jab and nothing else | Win, 2 s on 79 % | `-one-jab` |
| Foreseen, away from any ground, L4 +40 | Win, 2 s on 85 %, donor held | `-foreseen` |
| Typical, one realm up, same donor shape | Dead at 2 s, enemy on 85 % | main file, `--gap 1` |
| Top-end | Dead at 1 s, enemy on 91 % | main file, `--enemy top_end` |

**Counter:** time, which needs no enemy at all: no donor means no gain, and every decade of hiding is a decade of rejection. A patient sect need only keep its Wood roots behind a wall. In a fight, a body-crusher (Combat rule 18) one realm up kills it at 2 s, and a top-end at 1 s.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Arts within the lint, 3 of 6 slots, technique 1.13 of 3.0. Thần thức not totalled. L2 has no W price, so the root's band cannot be checked against Formulas E |
| Validity | PASS | `moc`, tier 2 reaches Nascent Soul, ward and art fields real |
| Stack | PASS | Forms: Increased, Per, Trigger, Trade. L4 and L5 empty and named |
| Scaling | PASS | `m_static` 2.73 before tag points, about 5.1 on Wood arts at purity 75, against typical 7.37. It wins on spend, not on M |
| The fight | PASS | The loop fires, no cap hit, 60 of 60 constants |
| Reuse | PASS | Held at Table proved in the main fight. Second homes named |
| NPC use | NOT ASSESSED | Rule 15: root changes are not reachable for NPCs. A world-generated NPC could start with a graft and a purity, but nothing yet ages it |
| Counterplay | PASS | A body-crusher one realm up, a top-end, and time |
| Originality | PASS | Names checked against the ledger. Medical grafting is a real practice, not a source work |

## Fight Results

Input: `sheets/the-transplant.fight.json`. Rules `escape`, `not_yet_full`, `grafted_root`. Observations from `_tools/fight_x.py`, a paper model.

| Enemy | Gap | Result | Time | Own dry at | Cap hits |
|---|---|---|---|---|---|
| typical | 0 | Win, 74 %, pool 18 % | 3 s | never | none |
| typical | 1 | Dead, enemy on 85 % | 2 s | never | none |
| top_end | 0 | Dead, enemy on 91 % | 1 s | 1 s | none |

The enemy realm stops at Deity Transformation, so the gap 2 rows add only suppression.

**Unmodelled:** rejection, feeding and heart demon between fights (the clock variant prints the arithmetic). Purity spent in a fight is read by the next fight, because compile runs once. The operation's roll.

## New Concepts

**Rejection (Bài Dị).** Rule: Spiritual Roots, a new rule beside 13 and 14. Bounds: purity floor 10, at which the root dies. Breakdown line: "Di Thực: Wood 75, −6 next decade, 0 donors." Other builds: any graft of any element, and a cursed artifact or borrowed body with the same clock. NPCs: not until rule 15 opens root changes.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Grafted Root | Needs rule | Spiritual Roots rules 9, 11 and 14: a fourth origin, an exception to "a variant is not a base element", and an element that can be lost |
| The Root Pays | Needs rule | Combat Formulas E: part of a cost paid from purity |
| Rejection | Needs rule | Spiritual Roots: the clock and feeding |
| Foreign Edge, Cold Graft | Needs key | `graft_art_more`, the graft's body cost |
| Arts, technique, knife, pill | Needs key | Records as above |

## Also Considered

- **The Patchwork:** many grafts of one element stacked on one channel, each on its own clock. Stranger, and far more to read per fight.
- **The Willing Donor:** a devoted disciple feeds you a little of their own purity each decade, and you watch them fade. Lovely, and it wants a whole companion system first.

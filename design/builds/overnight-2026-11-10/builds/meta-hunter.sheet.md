# The Open Ledger (Khai Bạ)

> **Status**: Design sheet, 2026-11-11. Not in game data. Numbers on new content are first guesses.
> **Seed**: A counter-build to the strongest known patterns: health-paid art costs and Stagnation-on-hit (see design/builds/by-root/notes.md). The sect that exists to hunt those builds. Make it strong against them and honest against everything else, so the game has a real answer in its world.
> **Direction**: The Open Ledger (a debt-collector sect; see Directions considered)
> **Realm span**: Kết Đan (Core Formation) to Nguyên Anh (Nascent Soul) · **Power level**: top-end · **Use**: NPC or sect archetype (a player can walk it)
> **Fit**: 8 Fits today · 12 Needs key · 7 Needs rule
> **Checks**: 6 PASS · 0 FAIL · 3 NOT ASSESSED (Budgets: technique budget and thần thức not checkable; Stack: identity test, the identity Effect is unmodelled; The fight: the engine pieces are unmodelled)

## Directions considered

Chosen: **The Open Ledger (Khai Bạ)**, a sect that records what a cultivator borrows against their own body and calls the debt due. It fills the gap the notes name: health-paid costs have no counter (Withering does not touch them), and Stagnation beats everything. A counter-build only works if it answers a *pattern* with rules, not with a bigger number, so this one gets three answers in rules and a normal, honest body around them.

Not chosen:

- **The Quiet Bailiff (Tĩnh Pháp Lại).** A pure immunity wall: status resistance, cleanses, body regeneration. It never loses to Stagnation, but it has no way to win and the fight ends on fatigue, which the game treats as a failure. Rejected: no win condition.
- **The Drained Cup (Cạn Chén).** A starver: Spirit Severing plus linh lực leech, so hunters win by emptying the pool. It is strong against ward builds, but a health-payer's pool is health, so the burn does nothing to it. Rejected: it hunts a different quarry.

## The Spine

- **The channel:** Art hit, Metal (phys and elem), with Metal debuff stacks on the foe. All five layers are used: L1 200, L2 280, L3 250, L4 150, L5 80 points (M about 180 at Nguyên Anh; the top-end anchor is 256, the typical 7.37). Defence is top-end: ward layers W2–W5 at their caps (300/250/150/100) and the body layers part-filled.
- **The enabler:** Ledger Seal (Bạ Ấn), a named seal artifact. It opens the ledger: the foe's health-paid costs and the Stagnation stacks put on the wearer become *entries* that three Effects can read. It closes two doors: the wearer can never pay an art cost in health and never applies Stagnation (the Clean Hand Oath).
- **The loop:** Metal arts keep stacks and Withering on the foe; the Writ of Reckoning lays Dear Blood; the foe's own spending of health becomes damage and a damage bonus; the wearer's sustain comes from leech, gain on hit and one restoring art, never from regeneration.
- **The engine:** The quarry's strength is the hunter's fuel. Every point of health a foe pays on a cost is multiplied (Dear Blood), returned as a tick (Called Debt) and counted as a bonus (Spent Blood). Every Stagnation stack past a cap of 20 is not applied but entered, and adds to L5 (Clean Ledger). The stronger the pattern, the harder the hunter hits.
- **The sacrifice:** It cannot pay in health, the strongest general pattern. It cannot lay Stagnation. It leaves regeneration low, so a long fight against a plain build is just a fight. Two of six slots (Writ, Clean the Page) do nothing against a generalist. It loses to an equal-realm top-end generalist (6 wins, 13 losses, 1 draw).
- **The arc:** Kết Đan: five slots, the Writ and the cleanse arrive, the Seal is borrowed from the Hall. Nguyên Anh: sixth slot (Bloodhound's Count), L4 preparation against a known quarry, full ward layers. Beyond the span (Hóa Thần): the Hall's keystone would bind a whole pattern, which is a later question.

## The Legend

The Salt-Ledger Hall (Diêm Bạ Đường) kept the account books of a dozen sects, and so it was the first to read the pattern. Disciples of a rival school burned their own blood to cast through a long siege, and the Hall's bookkeepers wrote down every drop; a second school stalled the hearts of its enemies with a curse until a fight became a vigil. The bookkeepers' conclusion was an audit: nothing is free, someone always pays, and the one who pays in blood is borrowing at a rate that must be collected.

The founder, the Reckoner (Quán Thư), swore the Clean Hand Oath: the Hall's hunters would never pay a cost in blood and never lay the stalling curse, so that no one could say they won by the same sin. The Seal is the oath made object, and the sect has kept it since. Disciples are recruited from the burned-out: the brothers and daughters of blood-casters.

Hunters are feared as bailiffs. Blood-casters call the Hall a plague; Stagnation sects call it a cold wall. Neither can say it cheats, since the Hall pays in coin they refuse.

## How It Fights

The Hunter opens like any Metal cultivator, with a ward at top-end layers and a Whetted Tally every 3 s that stacks Metal on the foe. At about 5 s the Writ of Reckoning lands: Withering and Dear Blood. If the foe pays in health, every cast now costs them half again as much, a share of what they paid is returned as a tick, and the hunter's Closing the Book and Bloodhound's Count hit harder per tenth of health spent. If the foe lays Stagnation, the stacks stop at 20 and the rest become the hunter's bonus. Leech and Ink-Line Breath keep the pool full without a pulse of regeneration.

**The signature moment:** a blood-caster in full burn, at 60 % health, casts a hungry art and the Breakdown shows "Dear Blood: cost 1.5×" while the Ledger reads "entered: 14 %" and the hunter's Closing the Book lands for a third more.

## Enabler

**Ledger Seal (Bạ Ấn)**, named artifact, base `an` (seal), thần thức cost as a utility piece. Found by taking the Clean Hand Oath at the Hall (the event) or from a dead hunter. Opens: the entries rule, which makes Dear Blood, Called Debt, Spent Blood and Clean Ledger readable and live. Closes: no health-paid art costs, no Stagnation applied by the wearer, and the Seal's rule ends if either is broken. Without the Seal, Writ of Reckoning still lays Withering and Metal stacks, and nothing else.

## The Stack

Sizes on new modifiers are first guesses. Existing keys are named as they appear in `modifiers.md`.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Metal arts coefficient | c_art 2.6–3.4 inside the art lint | Flat base | art | none | ● | Techniques, arts | any Metal build |
| 2 Rate | Art speed (`art_speed_pct`) | +25 % | Increased | art | none | ◐ | Tree | any art build |
| 3 L1 | Metal damage | +12 % per notable, a few notables | Increased | art | L1 | ○ | Tree | any Metal build |
| 3 L2 | Whetted Edge (Lợi Nhận) | +20 % more on arts with the Metal tag, per art | More | art | L2 | ○ | Technique, Đạo | any Metal build |
| 3 L2 | Spent Blood (Huyết Phí) | +4 % more per 10 % of max health the foe has paid on art costs, cap +40 % | Per | art | L2 | ○ | Cluster | any build facing a health-payer |
| 3 L3 | Gear | Ledger Seal, Brush-Blade, Tallyman's Coat | Flat | art | L3 | ○ | Items | n/a |
| 3 L4 | Quarry Notes | prepared L4 from the Clear-Bile Pill and Ledger-Hall Array, only when the quarry is known | More | art | L4 | ○ | Pills, formations | any prepared build |
| 3 L5 | Hounds on the Scent (Truy Tung) | +16 % more per distinct status you have on the foe, up to 5 (+80 %) | Per | art | L5 | ○ | Đạo | any status-stacking build |
| 4 Crit | Crit chance and damage | chance 0.2, multiplier 1.8 | Increased | art | none | ● | Tree | any |
| 5 Reach | Seam in the Armour | Metal debuff stacks: the foe takes more physical damage per stack | Status | art | none | ● | Arts | any Metal build |
| 6 Past the cap | Clean Ledger (Sạch Sổ) | Stagnation on you is capped at 20 stacks; each stack past it is entered: +0.4 % more (L5), cap +40 %. L5 total stays under 100 | Overflow | art | L5 | ○ | Seal, keystone | any curse-resistant build |
| 6 Past the cap | Spilled Ink (Dật Mặc) | Linh lực gained past a full pool becomes a ward shield at 50 % | Overflow | any | none | ○ | Tree notable | any leech build |
| 7 Fuel | Linh lực leech, on hit, art cost | `leech_linh_luc_pct` 6 %, `linh_luc_on_hit_pct` 0.5 pp, `art_cost_pct` −30 % | Increased | art | none | ● | Tree, items | any |
| 8 Survival | Clear-Bile (Thanh Đởm) | `status_resist_pct` +20 pp against curses | Increased | any | none | ● | Tree, pill | any curse-facing build |
| 8 Survival | Ward layers | W2–W5 300/250/150/100, `ws_base` 110, `we` 140 | More | ward | W2–W5 | ◐ | Technique, gear | any ward build |
| 9 Identity | Dear Blood (Huyết Quý) | The foe's health-paid art costs are 1.5×, and 15 % of the health they paid returns as a tick (Called Debt) | Rule swap (curse) | tick | none | ○ | The Writ, the Seal | any anti-health-payer build |

**Identity piece:** Dear Blood. Delete it and the build plays like a Metal ward build with good leech: its whole claim against health-payers disappears.
**Empty rungs:** none empty. Rung 4 (certainty) is a plain crit, a deliberate modest choice. L5 stops at 80 of 100 and L2 at 280 of 300: that is the room for the quarry-only bonuses, not a gap.

| Layer | Points at Nguyên Anh | Multiplier | Sources |
|---|---|---|---|
| L1 | 200 | ×3.0 | Metal damage notables, attack_pct, Kim Đạo Kim Phong |
| L2 | 280 | ×3.8 | Whetted Edge, Spent Blood (cap +40), technique |
| L3 | 250 | ×3.5 | Seal, Brush-Blade, Tallyman's Coat |
| L4 | 150 | ×2.5 | Clear-Bile Pill, Ledger-Hall Array, only against a known quarry |
| L5 | 80 | ×1.8 | Hounds on the Scent (up to 80), Clean Ledger (up to 40), together under the 100 cap |

M = 3.0 × 3.8 × 3.5 × 2.5 × 1.8 ≈ 180, against the top-end anchor 256 (about 70 %) and the typical 7.37.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Kim (Metal), purity 80 or more, a single root | Metal's stacks (the foe takes more physical damage) and the Kim Đạo; the build's sustain is not elemental, so no second root is needed |
| Key talents | Thần thức (reads the quarry), Comprehension | Thần thức for the Seal's cost and for L4 knowledge; Comprehension for a tier 3 technique |
| The Way (Đạo) | Kim Đạo · *Bách Luyện*, the Kim Phong and Thối Thể facets | Kim Phong holds Metal stacks; Thối Thể holds block and body shield. Two proposed passives: Whetted Edge, Clean Hand (Clear-Bile as a notable) |

## Công Pháp

### Open Ledger Sutra (Khai Bạ Kinh) — main, tier 3

The Reckoner's account of a debt: every power is borrowed, and a ledger keeps it honest.

```json
{"id": "khai_ba_kinh", "name": "Khai Bạ Kinh", "tier": 3, "tech_kind": "main",
 "names": ["kim"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_pct", "value": 30}, {"stat": "status_resist_pct", "value": 15},
             {"stat": "leech_linh_luc_pct", "value": 3}],
 "abilities": [{"ability_id": "writ-of-reckoning", "unlock_layer": 3},
               {"ability_id": "clean-the-page", "unlock_layer": 6},
               {"ability_id": "ink-line-breath", "unlock_layer": 8},
               {"ability_id": "bloodhound-count", "unlock_layer": 11}],
 "seal_clusters": ["steady-hand"], "origin": "authored"}
```

**Fit:** Needs key (the abilities are new art records) · **Budget:** NOT ASSESSED: `Σ value / pool_max` needs each stat's `bonus_pool`, and `status_resist_pct` and the leech key are not in it. Tier 3's `max_realm` is Nguyên Anh, which reaches the span.

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Whetted Tally (Ma Nhận Kế) | Sutra, layer 1 | phys, Metal, hit | 2.6 | 0.05 | 3 s | none | Needs key |
| Closing the Book (Hợp Bạ Trảm) | Sutra, layer 1 | phys, Metal, hit | 3.1 | 0.04 | 6 s | none | Needs key |
| Writ of Reckoning (Thúc Nợ Trạng) | Sutra, layer 3 | elem, Metal, curse | 1.2 | 0.03 | 5 s | none | Needs rule |
| Clean the Page (Tẩy Trang) | Sutra, layer 6 | elem, Metal, cleanse | 0 | 0.03 | 6 s | you hold at least 1 Stagnation stack | Needs key |
| Ink-Line Breath (Mặc Tuyến Tức) | Sutra, layer 8 | elem, restore | 0 | 0.02 | 8 s | none | Needs key |
| Bloodhound's Count (Truy Huyết Toán) | Sutra, layer 11 | phys, Metal, hit | 3.4 | 0.05 | 8 s | none | Needs key |

Lint check at c_art ≤ 1 × (1 + 24 × cost) + 0.25 × (cooldown − 1): Whetted Tally 2.7, Closing the Book 3.21, Writ 2.72, Bloodhound's Count 3.95; all inside. The simulator printed no `lint_over`.

- **Whetted Tally.** *Effect:* a Metal hit, 2 stacks of the Metal debuff for 8 s. *Description:* a tally mark scratched on the foe's guard.
- **Closing the Book.** *Effect:* a heavy Metal hit; Spent Blood applies. *Description:* the ledger is shut, and the account with it.
- **Writ of Reckoning.** *Effect:* 4 Metal debuff stacks for 10 s; lays Withering (● exists) and, with the Seal, Dear Blood (○). *Description:* the demand, written and served.
- **Clean the Page.** *Effect:* removes all Stagnation stacks from you (a cleanse, Effects rule 9a). *Description:* the stall is wiped as an error in the books.
- **Ink-Line Breath.** *Effect:* restores 5 % of maximum linh lực at a cost of 2 %. *Description:* the brush is wetted again.
- **Bloodhound's Count.** *Effect:* a heavy Metal hit; the foe's health-paid cost this fight increases its damage (Spent Blood). *Description:* the hounds are sent to collect.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Kết Đan | 5 | Whetted Tally, Closing the Book, Writ of Reckoning, Clean the Page, Ink-Line Breath | Common Ward with W layers 250/200/120/60 | Seal is on loan from the Hall |
| Nguyên Anh | 6 | the same, with Bloodhound's Count last | Drain ward at top-end layers | L4 filled against a known quarry |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Ledger Seal (Bạ Ấn) | artifact, utility, named | `an`, `thuong`, tier for Nguyên Anh | The enabler: opens entries, closes health-pay and Stagnation | Needs rule |
| Brush-Blade (Bút Kiếm) | artifact, weapon | `phi_kiem`, `thuong`, Nguyên Anh | L3 weapon attack; wanted affixes: Metal damage, linh lực leech | Fits today |
| Tallyman's Coat (Bạ Y) | artifact, ward | `giap`, `thuong`, Nguyên Anh | Ward gear, `ws_base` and status resistance; carries the ward layers | Fits today |
| Clear-Bile Pill (Thanh Đởm Đan) | pill | Alchemy | Prepared: +status resistance against curses for the fight; fills L4 with the array | Needs key |
| Ledger-Hall Array (Bạ Đường Trận) | formation | Formations | Prepared L4 for arts against a known quarry; blind fights lose it | Needs key |

The Seal's history: it was a counting-board lid, burned black at one corner where the founder pressed it to a blood-casting disciple's wrist.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Linh lực leech (small, then notable) | +0.8 % to 5.5 % | The sustain that Stagnation cannot dampen | Fits today |
| 2 | Status resistance against curses | +4.5 pp / +30 pp | Clear-Bile | Fits today |
| 3 | Metal damage notables | +12 % each | L1 | Needs key |
| 4 | Linh lực on hit | +0.19 pp | Fuel | Fits today |
| 5 | Art cost | −3 % each | Fuel | Fits today |
| 6 | Spilled Ink notable | overflow to ward shield | Past the cap | Needs rule |
| 7 | Spirit Severing (existing keystone, optional) | hits burn linh lực | Lets the hunter answer a pure-ward quarry | Needs rule |

### Hidden cluster idea: Steady Hand (Ổn Thủ)

Theme: Heart State (the Hall teaches a stilled hand). Element affinity: Metal. Kind: sealed. Seal condition: an item, the Ledger Seal, or the technique listing it in `seal_clusters`. Size: 8 acupoints: small acupoints of leech, status resistance against curses and art cost; a notable "Spilled Ink" (Overflow); a notable "Spent Blood" (Per, cap +40); no capability. An idea for the tree rework, not data.

## Đạo

Kim Đạo · *Bách Luyện* (existing in the provisional catalogue, graph not yet drawn). Nodes that matter: Kim Phong (Metal Edge: Metal stacks) holds the proposed passive Whetted Edge; Thối Thể (Tempered Body) holds the proposed Clean Hand notable (Clear-Bile as a passive); the keystone is the Seal's rule, which is an item, not a Way. The Way supplies stat lines from its `theme_stats` and no cap raise.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Kết Đan | A careful Metal fighter; the tools arrive at about 5 s | Writ, Clean the Page, Ink-Line Breath, borrowed Seal | Takes the Clean Hand Oath and gives up health-pay for good |
| Nguyên Anh | A bailiff: the quarry's strength is the fuel | Sixth slot, Bloodhound's Count, L4 against a known quarry, own Seal | First quarry hunted down; the Hall names them |
| Hóa Thần (beyond the span) | Would bind a whole pattern | A Hall keystone, not designed | The Hall is asked who the next quarry should be |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Typical build, same realm | wins, a first volley | Top-end layers; its tools never fire |
| Blood-caster paying half its costs in health | favoured (not simulated) | Dear Blood and Called Debt double the cost of their style |
| Blood-caster that also regenerates (Wood) | strongly favoured (not simulated) | Withering and Dear Blood together |
| Stagnation applier | favoured (not simulated); the simulator shows a floor of 0 wins | Stacks cap at 20; the rest feed L5 |
| Top-end generalist, same realm | loses (6 wins, 13 losses, 1 draw) | Honest: no quarry, no bonus |
| Burst build that ends in two volleys | loses | The Writ fires at 5 s, too late |
| Soul build | even or loses | Soul passes layers and cost payment; Dear Blood does nothing |
| Thể tu with no art costs | loses or even | No health-paid costs to collect |

**Counter:** a top-end generalist at the same realm, a build that is dead before the first cooldown, a soul build, and a quarry that is immune to curses (status resistance makes the Writ miss).

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Arts: all six inside the art lint, no `lint_over` printed; slots 5 at Kết Đan and 6 at Nguyên Anh, inside 5 and 6 of `slots_by_realm`. Technique budget and thần thức of three artifacts: not checkable (stats outside `bonus_pool`) |
| Validity | PASS | Metal, `kim`; tier 3 reaches Nguyên Anh; bases `phi_kiem`, `an`, `giap` and grade `thuong` exist; no auxiliary technique |
| Stack | NOT ASSESSED | Ladder filled, 7 forms (Increased, More, Flat base, Per, Overflow, Rule swap, Status), identity piece named, all five layers used. Identity test: `--without writ-of-reckoning` changed the top-end result (6 wins to 0) but removes only the Metal stacks; Dear Blood itself is unmodelled |
| Scaling | PASS | M ≈ 180 against the top-end anchor 256 (INFO: about 70 %, L5 and L2 held below the caps) |
| The fight | NOT ASSESSED | The engine (Dear Blood, Called Debt, Clean Ledger) is unmodelled; see Fight Results |
| Reuse | PASS | Reuses the status-roster readable, Spirit Severing, the leech and status keys, Withering; one signature piece (Ledger Seal) |
| NPC use | PASS | The generator can roll a hunter from the Seal's two closing rules; each modifier reads in a Breakdown line |
| Counterplay | PASS | Top-end generalist, burst builds, soul builds, curse-immune quarry |
| Originality | PASS | No names from novels or games; a bookkeeping sect is a structure, not a name |

## Fight Results

Input: `design/builds/overnight-2026-11-10/builds/meta-hunter.fight.json` (Nguyên Anh), `.ket-dan.fight.json`, `.vs-health.fight.json`, `.vs-stagnation.fight.json`. Observations from `fight.py` on the combat simulator (`tools/design/combat_sim/sim.py`, 20 fixed seeds), not the game.

| Enemy | Gap | Wins / losses / draws | Mean time | Own dry at | Never fired | Cap hits |
|---|---|---|---|---|---|---|
| typical, Nguyên Anh | 0 | 20 / 0 / 0 | 1.8 s | never | all six (the foe is dead first) | none |
| typical | +1 | 20 / 0 / 0 | 2.8 s | never | five of six | none |
| top_end | 0 | 6 / 13 / 1 | 18.3 s | 16.7 s | none | none |
| top_end | +1 | 0 / 20 / 0 | 5.7 s | 5.3 s | none | none |
| top_end paying half its costs in health (no Dear Blood) | 0 | 0 / 20 / 0 | 18.6 s | 17.5 s | none | none |
| top_end applying Stagnation | 0 | 0 / 20 / 0 | 11.3 s | 10.7 s | none | none |
| typical, Kết Đan | 0 | 20 / 0 / 0 | 2.4 s | never | four of five | none |
| top_end, Kết Đan | 0 | 0 / 20 / 0 | 8.7 s | 8.3 s | none | none |

**Identity test** (`--without writ-of-reckoning`): `identity top_end+0 changed` (wins 6 to 0, 18.3 s to 18.1 s), `top_end+1 changed` (0 to 0, 5.7 s to 6.0 s), `typical NO_CHANGE` in both. The art does something in the claimed top-end fight, but only through its Metal stacks.

**Findings.** (1) Against the Stagnation applier the build loses all 20 seeds, and raising the build's cleanse to a 0.8 share, 2 per pulse changed nothing. The cleanse does not move the simulator's result, so this run shows the sustain, not the design's cap-at-20. Whether the simulator's Stagnation matches the GDD's dampening (1 % per stack, never a stop, Effects Status Catalogue) is for the user to check. (2) Against the health-payer the simulator has no Dear Blood, so 0 wins is a floor. (3) Ward strength is the knob: `ws_base` 100 and `we` 120 lost 0 of 20, 110 and 140 gave 6, and 120 and 160 gave 17, a sharp slope; the build is at the honest end.

**Unmodelled:** Dear Blood (a curse changing cost payment), Called Debt (a health-paid tick), Spent Blood and Hounds on the Scent (Per conditions), Clean Ledger (the stack cap and its overflow), the Seal's entries and closing rule, Spilled Ink, L4 only against a known quarry (run at 150 points, as if not blind), and L5 run as a static 80 points, which overstates the opening seconds. Simulator `model_note`: not modelled are soul attacks, companions, triggers, conversion, curses other than Withering and Stagnation, guards and conditions, shields beyond the body shield, escape; enemies are exact at Qi Refining and fitted at Nguyên Anh.

## New Concepts

- **Quarry knowledge.** A sect's known quarry makes the fight non-blind for L4 (Combat rule 12), so a hunter's prepared layer works against the pattern it hunts. Serves any sect archetype with a named enemy and any build with a prepared layer. Bound: only against a pattern the sect lists; Breakdown line: "Quarry: Blood-casting — preparation counts". Question for the user: is a sect's quarry a world-generation tag?
- **Incoming status stack cap.** A rule that caps a status's stacks on the wearer and turns the excess into a bonus (Effects System rule 9, stacking). Serves any anti-curse build and any thể tu. Bound: one status per keystone, 20 stacks, bonus cap +40 %.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Dear Blood, Called Debt | Needs rule | Effects curse table: cost payment changed; a readable of health the foe has paid on costs (Effects rule 5) |
| Clean Ledger | Needs rule | Effects rule 9: a cap on incoming stacks with overflow into L5 |
| Hounds on the Scent | Needs rule | Readable: distinct statuses on the foe (Effects rule 5); one L5 source |
| Quarry knowledge | Needs rule | Combat rule 12, blind-fight preparation |
| Spilled Ink | Needs rule | Combat Defence & Healing: a ward shield from overflow linh lực |
| Ledger Seal | Needs rule | The entries rule and the Clean Hand Oath as an item rule |
| Whetted Edge, Spent Blood, Metal damage | Needs key | Tag-scoped More and Per keys in modifiers.md |
| Six arts, the Sutra, Clear-Bile Pill, Ledger-Hall Array | Needs key | Art records, a technique record, a pill payload, a formation payload |

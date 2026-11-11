# The Unquarrelling Ledger (Bất Tranh Trướng)

> **Status**: Design sheet, 2026-11-11. Not in game data. Numbers on new content are first guesses.
> **Seed**: Never deals direct damage. Wins by making the enemy hurt itself: reflected costs, backlash, heart demon, collapse of their own linh lực, or by outlasting until they flee. A strange build that should still be viable.
> **Direction**: A, The Ledger (chosen by the build driver; see Directions considered).
> **Realm span**: Trúc Cơ – Nguyên Anh · **Power level**: ordinary · **Use**: player · **Spiritual root**: Thủy with the Băng (Ice) variant
> **Fit**: 4 Fits today · 9 Needs key · 10 Needs rule
> **Checks**: 7 PASS · 0 FAIL · 2 NOT ASSESSED (Budgets: combat modifiers on a technique cannot be priced; The fight: the engine pieces Debt Seal, Interest, Backlash and Dread are not in the simulator)

## Directions considered

Chosen: **A. The Ledger (Trướng)**. The enemy's every spend is written against them: ice stacks make their arts cost more, Debt Seals make part of each cost come out of their health, Stagnation and Qi Disruption starve their pool, and a tall Water ward and body outlast them. Chosen because it is the only reading that uses rules the game already has (ice cost stacks, Stagnation, Qi Disruption, the "pay in health" rule of Blood Casting) and still has a loop a player can watch.

- **B. The Heart-Demon Whisperer (Tâm Ma Dẫn).** Soul-side: plant tâm ma in the foe and let it eat their arts. Not picked: soul builds are unmodelled by the simulator, and Soul hits are direct damage by another name.
- **C. The Patient Ghost (Nhẫn Quỷ).** Pure evasion and a long game until the enemy flees. Not picked: it has no loop to play and needs the enemy-flight rule to work at all. Its ending survives as the Nguyên Anh capstone (Dread of the Ledger).

## The Spine

- **The channel:** none of the damage channels. Ticks and hits stay at zero. The win arrives as the enemy's own cost: element-stack cost increase (Effects System Formulas D, ice `cost_up` 0.039 a stack), Debt Seal (part of each of their art costs paid in health), regeneration dampening (Stagnation) and Qi Disruption. Offence layers L1–L5 are all empty on purpose; the defence layers W2–W5 and B2–B5 carry the build.
- **The enabler:** Open Palm Vow (Bất Tranh Thệ). Opens: the basic attack, the only free and guaranteed channel, applies one Debt Seal per hit instead of damage. Closes: every direct hit. Basic coefficient is 0 and no slotted art may carry `c_art` above 0.
- **The loop:** mark them (Palm and Cold Ledger), make them spend (their arts cost more and bite them), refill yourself from what they spend (Interest), mend while the ledger grows.
- **The engine:** Debt Seal plus Interest. The faster the enemy casts, the faster they wound themselves and the faster you refill. A foe who stops casting is worth nothing and also does nothing, so the fight ends by fatigue in your favour because you stand taller.
- **The sacrifice:** it cannot kill a foe that will not cast, it cannot end a fight early, and it does nothing against a top-end enemy whose first volley finishes the fight in 2 s.
- **The arc:** Trúc Cơ, a mender with a slow ledger; Kết Đan, Seals reach their cap and the foe's pool collapses; Nguyên Anh, the closing of the book: a foe with a full ledger and half health tries to run, and running is a win for you.

## The Legend

At the border of a drought-hit district the Quiet Pond hermitage kept a mendicant register: monks took in wounded men from both sides and wrote down what each had cost the pond. When raiders came, the abbess answered each cut with a bill. Raiders who struck at her paid every spent breath of their own back until they limped out. The register became a method: the Unquarrelling Ledger.

Its walkers are mostly healers and field-surgeons who could not stomach the sect war. It does something to them: they stop wanting to win and begin wanting to be right. Their tâm ma is a tally that never closes.

Blood-casters and burst sects hate it for the same reason: a ledger-keeper makes their strength a debt.

## How It Fights

You never strike. The Open Palm lays a Seal on the foe with every basic attack, Cold Ledger puts ice stacks on them so their arts cost more linh lực, Silent Tally stagnates their regeneration, and Still Tide mends you. Each art the foe casts is now dearer and also bites a slice of their own health. Their ward falls as their pool drains, and you regain a share of what they spend.

**Signature moment:** at 40 s the foe's pool is empty, their ward is gone, they fire a last art anyway and it costs them a tenth of their health, and the Interest of that cast refills your ward. At Nguyên Anh, Closing the Book makes them turn and run, and the result screen says you won.

## Enabler

**Open Palm Vow (Bất Tranh Thệ)**, a divine ability of the main technique (layer 9), or a vow made at a temple altar. Opens a free channel: the basic attack applies a Debt Seal per hit (no coefficient). Closes: direct damage. Basic `basic_coef` is 0 and arts with `c_art` above 0 cannot be slotted (the same closing rule as Paid in Advance, Effects System). **Needs rule:** Effects System, a "forbid a slot kind" rule plus a zeroed basic.

## The Stack

Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | Cold Stacks | Ice debuff 3 stacks for 12 s, `cost_up` 0.039 a stack | Per (stack) | stack | none | ● | Art | any ice or cost-denial build |
| 1 Base | Debt Seal (Trái Ấn) | Each stack: the foe pays 5 % of each art's cost share as health (cap 10 stacks) | Trade (on foe) | foe cost | none | ○ | Effect | Blood-cost foes' hunters |
| 2 Rate | Basic attack speed (reuse `basic-attack-speed`) | Palm lands faster | Redirect | basic | none | ○ | Tree | starter-blade |
| 2 Rate | First firing comes sooner (catalogue) | −12 % first firing | Timing | art | none | ○ | Tree | any opener |
| 3 Multiplier | Patient Ward (Nhẫn Hộ) | +1 % ward strength per 10 s fought, cap +20 % | Per | ward | W2 | ○ | Technique | Late Bloom builds |
| 3 Multiplier | Unspent Edge (Nhận Chưa Rút) | `attack_pct` counts 50 % as ward strength and body strength | Borrow | defence | W/B | ○ | Armour | any ward build with spare attack |
| 4 Certainty | Silent Tally (Stagnation, Qi Disruption) | Existing curses, no roll | Conditional | curse | none | ● | Art | curse-engine |
| 5 Reach | Deeper Nails (reuse) | +% curse effect: Stagnation and Seals stronger | Increased | curse | none | ○ | Tree | curse-engine |
| 5 Reach | Deeper Frost (Hàn Thâm) | +% to ice stack `cost_up` | Increased | stack | none | ○ | Tree | ice builds |
| 6 Past the cap | Extra Curse Slot (reuse) / Seal cap shift | Debt Seal cap 10 to 15 | Cap shift | foe cost | none | ○ | Cluster | status-collector |
| 7 Fuel | Interest (Lợi Tức) | Regain 20 % of the linh lực the foe spends, up to 2 % of your maximum a pulse | Trigger | fuel | none | ○ | Effect | any drain build |
| 7 Fuel | Linh lực regeneration, art cost, healing (catalogue) | Tree bulk | Increased | fuel | none | ● | Tree | everyone |
| 8 Survival | Long Frost (Hàn Kéo Dài) | +12 % ice stack duration | Increased | stack | none | ○ | Tree | ice builds |
| 9 Identity | Backlash Count (Phản Chấn) | Every 4th foe art under 3 or more Seals costs them 4 % of their health | Per | foe cost | none | ○ | Effect | any anti-caster build |

Forms used: Per, Trade, Redirect, Timing, Borrow, Conditional, Increased, Cap shift, Trigger (nine).

**Identity piece:** Debt Seal. Delete it and the foe's casts cost only linh lực, which Interest, Stagnation and Cold Stacks cannot turn into health loss; the build has nothing that wounds. In the fight test the real piece cannot be removed because the simulator has no field for it, so `--without cold-ledger` stands in (the ice stack half of the same ledger).
**Empty rungs:** L1–L5 offence, crit, pierce (all a sacrifice: never deals direct damage). Soul answer is a gap (Tĩnh Tâm affix only).

| Layer | Points at Kết Đan | Multiplier | Sources |
|---|---|---|---|
| L1–L5 offence | 0, 0, 0, 0, 0 | ×1 | Empty by the Vow. Nothing to multiply |
| W2–W5 ward | 40, 40, 20, 10 | typical 1.4 / 1.4 / 1.2 / 1.1 | Technique, Patched Robe (ward gear), Silent Pond Array, Still Tide pill/buff |
| B2–B5 body | 40, 40, 20, 10 | typical | Technique body line, robe, formation |

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Thủy at 80 % purity, Băng variant (`requires: thuy`) | Ice is the only element whose stack is a cost increase; Water's stack gives regeneration and linh lực maximum |
| Key talents | Thần thức (soul and unused artifact capacity), Comprehension (the Way) | Tĩnh Tâm resistance guards the build's one hole, heart demon |
| The Way (Đạo) | Nhân Quả Đạo, facet Nợ (Debts) for Seal and Interest; Thủy Đạo Uyên for linh lực; Bồ Đề Nghiệp Thuẫn for wards | Existing Ways with matching facets (dao.md Catalogue rows 29, 17, 42) |

## Công Pháp

### Still Pond Ledger Sutra (Tĩnh Trì Trướng Kinh) — main, tier 3

The abbess's register, copied into a sutra with the accounts left blank.

```json
{"id": "tinh-tri-truong-kinh", "name": "Tĩnh Trì Trướng Kinh", "tier": 3, "tech_kind": "main",
 "names": ["thuy"], "layers": 12,
 "bonuses": [{"stat": "linh_luc_regen_pct", "value": 0.8}, {"stat": "art_cost_pct", "value": -3},
             {"stat": "healing_pct", "value": 6}],
 "abilities": [{"ability_id": "bat-tranh-the", "unlock_layer": 9}],
 "seal_clusters": ["do-hoi-tho"], "origin": "authored"}
```

**Fit:** Needs key (ability record) · **Budget:** NOT ASSESSED: `bonus_pool` is not checked for combat keys. Tier 3 reaches Nguyên Anh (`max_realm` nguyen_anh, `bonus_budget` 3).

## Arts

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Cold Ledger (Hàn Trướng) | Technique, layer 1 | qi, ice, stack | 0 (sim 0.02) | 0.04 | 4 s | none | Needs key |
| Silent Tally (Mặc Kế) | Technique, layer 4 | qi, curse | 0 | 0.04 | 6 s | none | Needs key |
| Still Tide (Tĩnh Triều) | Technique, layer 2 | water, heal, buff | heal 0.5 | 0.04 | 5 s | none | Needs key |
| Closing the Book (Khép Trướng) | Đạo node (Nợ), Nguyên Anh | curse | 0 | 0.08 | 12 s | foe has 8 or more Seals | Needs rule |

- **Cold Ledger. Effect:** 3 ice stacks for 12 s on the foe (`cost_up`). **Description:** a line of frost on the account.
- **Silent Tally. Effect:** applies Stagnation and Qi Disruption (existing curses). **Description:** the book is closed on the foe's breath.
- **Still Tide. Effect:** heal 0.5 and 2 water stacks for 12 s (regeneration). **Description:** the pond refills.
- **Closing the Book. Effect:** converts all Seals into Dread (below). **Description:** the sum is read aloud.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Trúc Cơ | 4 | Cold Ledger, Still Tide, Silent Tally, (Open Palm basic) | Common Ward | Seals grow slowly. Survives by mending |
| Kết Đan | 5 | Cold Ledger, Silent Tally, Still Tide, ward art, spare | Drain ward, ws 45 | Seals reach 10. The foe dries at about 21 s in the simulator |
| Nguyên Anh | 6 | as above, plus Closing the Book | Drain ward, Patient Ward | Seal cap 15 with the cluster. Foe may flee |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Patched Robe of the Quiet Pond (Bố Y Tĩnh Trì) | Armour, body | `giap`, thuong, tier Kết Đan, affixes `ho_than`, `tinh_tam` | Health and heart-demon resistance; carries Unspent Edge as a named effect | Fits today (base and affixes), effect Needs rule |
| Silent Pond Array (Tĩnh Trì Trận) | Formation, L4 | new | Ward more from preparation | Needs key |
| Ledger Slip Talisman (Trướng Phù) | Talisman | new | Opening: lays 5 Seals at once. One use, takes an art slot | Needs key |

The robe was sewn from a dead monk's habit; each patch is a cut the wearer once answered with a bill.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | Linh lực regeneration | +1 % notable | Fuel | Fits today |
| 2 | Ward efficiency | +8 % notable | Survival | Fits today |
| 3 | Deeper Nails (curse effect) | staged | Reach | Needs key |
| 4 | Late Bloom (Hậu Phát) | catalogue | Art speed over a long fight | Needs rule |
| 5 | Status duration | +12 % notable | Ice stacks last | Needs key |
| 6 | Status chance | +6 % | None needed, Seals are certain | skipped |

### Hidden cluster idea: Dried Pond Ledger (Đồ Hội Thổ)

Theme: Way of Debts (Nhân Quả) with Water affinity. Sealed; seal condition: held the technique at layer 6. Seven acupoints: small points of regeneration, ward efficiency and curse effect; a notable of Patient Ward, and at the far end a notable that adds +5 Seal cap (Extra Curse Slot style). Reuse of Measured Breath (Điều Tức) for art speed and regeneration. An idea for the tree rework.

## Đạo

No new Đạo. Nhân Quả Đạo facet Nợ holds: Debt Seal as a notable, Interest as a notable, Closing the Book as an art node, and Dread of the Ledger as the facet keystone. Thủy Đạo Uyên holds the linh lực lines. Node values are not set; they follow dao.md Formulas D1.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Trúc Cơ | A mender with a slow tally; wins by outlasting small casters | Open Palm, Cold Ledger | Gave up the blade for the register |
| Kết Đan | Seals at cap; casters collapse | Debt Seal cap, Interest, Patient Ward | Ledgers bring sect enemies |
| Nguyên Anh | Foes run | Closing the Book, Dread | The tally never closes; heart demon grows |

## Matchups

| Enemy | Result | Why |
|---|---|---|
| Caster with big arts (typical) | wins | Casts hurt them, ward falls |
| Basic-attack thể tu | loses slowly | Never casts, so no debts. Plain fatigue decides |
| Burst, top-end foe | loses | One volley in 2 s |
| Cleanser | even | Cleansing strips Seals; Debt Seals are not cleanse-immune |
| Foe a realm above | loses | Simulator: dead in 9 s |

**Counter:** a thể tu (body cultivator) who rarely casts and hits hard on basic attacks, or a cleanser/purifier that removes Seals each pulse. Answer: keep Silent Tally up (Stagnation turns their regeneration against them) and add Patient Ward.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Combat modifiers are not in `bonus_pool`, so `Σ value / pool_max` cannot be computed. Art lint passes (c_art 0 or 0.02; costs 0.04 are within 0.02–0.125; cooldowns 4–12 s are within range) |
| Validity | PASS | `bang` requires `thuy`; `giap`, `ho_than`, `tinh_tam` exist in items_artifacts.json; technique tier 3 `max_realm` is nguyen_anh; slots 4 / 5 / 6 fit |
| Stack | PASS | Nine forms; every rung filled or named a sacrifice. Identity: `--without cold-ledger` (the ice half of the ledger) read `changed`; the real identity piece (Debt Seal) is unmodelled |
| Scaling | PASS | Offence M is 1 by design. Defence layers sit at the typical anchors (W and B 40/40/20/10), which fits an ordinary build. INFO: it does not reach the offence anchors, and does not claim to |
| The fight | NOT ASSESSED | See Fight Results. The simulator ran the modelled half (cost stacks, Stagnation, sustain). The engine pieces are unmodelled |
| Reuse | PASS | Reuses `deeper-nails`, `extra-curse-slot`, `basic-attack-speed`, Late Bloom, Measured Breath, Status duration, First firing sooner. Signature pieces: Debt Seal, Backlash Count (two). Each has a second home |
| NPC use | PASS | Debt Seal and Backlash read one Breakdown line each ("Foe pays 5 % of each art's cost per Seal in health"); no player input needed |
| Counterplay | PASS | Non-casting thể tu and cleansers; top-end burst |
| Originality | PASS | No names or techniques lifted. Structure borrows "damage reflection" tropes only |

## Fight Results

Input: `design/builds/overnight-2026-11-10/builds/pacifist.fight.json` (Kết Đan) and `pacifist.nguyen-anh.fight.json`. Observations from `fight.py` on the combat simulator, 20 fixed seeds, not the game.

| Enemy | Gap | Wins / losses / draws | Mean time | Own dry at | Never fired | Cap hits |
|---|---|---|---|---|---|---|
| typical, Kết Đan | 0 | 20 / 0 / 0 | 65.2 s | never | none | none |
| typical, Kết Đan | +1 | 0 / 20 / 0 | 9.7 s | 7.8 s | none | none |
| typical, Kết Đan | +2 | 0 / 20 / 0 | 4.0 s | 3.2 s | still-tide | none |
| top_end, Kết Đan | 0 | 0 / 20 / 0 | 1.6 s | 1.6 s | both arts | none |
| typical, Nguyên Anh | 0 | 20 / 0 / 0 | 65.5 s | never | none | none |
| typical, Nguyên Anh | +1 | 0 / 20 / 0 | 8.4 s | 6.5 s | none | none |
| top_end, Nguyên Anh | 0 | 0 / 20 / 0 | 1.6 s | 1.0 s | both arts | none |

The foe's linh lực is dry at 21 s, with the player never dry and 66 % health left (Kết Đan). The mean 65 s is above the 30–60 s band because the fight ends in fatigue (from 60 s); the build is slow by design, and the wall build before it was also over.

**Caveat:** the simulator's basic attack still runs at base with the Vow modelled as zero layers, and the foe's death in the simulator may owe something to it and to fatigue, so the simulator does not prove the pacifist can win with no direct damage. The Debt Seal, which wounds the foe, is not in the simulator at all.

**Identity test** (`--without cold-ledger`): changed at Kết Đan (foe dry 21 s with it, 26 s without; health left 66 % against 53 %; time 65.2 s against 66.0 s) and at Nguyên Anh (foe dry 21.1 s against 24 s; 61 % against 53 %). Wins stay 20 of 20 both ways, so the ice stacks are a help, not the cause.

**Unmodelled:** Debt Seal (foe pays costs in health); Backlash Count; Interest; Open Palm Vow's zeroed basic attack; Dread and enemy flight; Unspent Edge; Patient Ward; Silent Tally's Qi Disruption (the sim has Stagnation only); `model_note`: soul attacks, companions, triggers, conversion, curses other than Withering and Stagnation, guards and conditions, shields beyond the body shield, escape.

## New Concepts

- **Foe pays its costs in health (Debt Seal).** Rule needed: Effects System, "pay a cost in health" (the Blood Casting rule) applied to the other side's arts; Combat rule 11 for the linh lực side. Bounded: 10 stacks, 50 % of a cost at most. Breakdown line: "Foe pays 5 % of each art's cost per Seal in health." Serves: any anti-caster build, a Blood Casting hunter. Question for the user: should it be allowed against NPCs and creatures alike.
- **Flight is a win.** Rule needed: Combat rule on Escape, line "a fight ends in flight with no winner". Proposal: if the fleeing side is the opponent of a side with the Vow, the Vow side wins. Serves: any intimidation build (Soul Pressure), the Patient Ghost direction. Question for the user.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Debt Seal, Interest, Backlash Count, Dread of the Ledger | Needs rule | Effects System: foe-side cost payment; Combat rule 11 |
| Open Palm Vow | Needs rule | Effects System: forbid a slot kind plus zeroed basic |
| Unspent Edge | Needs rule | Combat Defence & Healing A0: Borrow of `attack_pct` |
| Closing the Book, Dread | Needs rule | Combat Escape rule: foe forced to escape; flight is a win |
| Cold Ledger, Silent Tally, Still Tide, technique, array, talisman, Long Frost, Deeper Frost, Patient Ward | Needs key | art records, stat keys |

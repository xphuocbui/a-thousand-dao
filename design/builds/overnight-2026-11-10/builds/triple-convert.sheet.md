# The Three Smeltings (Tam Luyện)

> **Status**: Design sheet, 2026-11-11 (overnight run 2026-11-10). Not in game data. Numbers on new content are first guesses.
> **Seed**: "Conversion keeps both tag families and a hit allows two conversions. Physical to Fire to Chaos (or similar) so one hit is scaled by three tag families' modifiers at once. Find the strongest legal conversion chain and what it costs."
> **Direction**: The Three Smeltings: every art is struck as Physical, turned to Fire by the art itself, then turned to Chaos by a plain conversion modifier, so each hit carries all three damage-type tags and lands as Chaos.
> **Realm span**: Qi Refining – Nascent Soul (Nguyên Anh), defined at Nascent Soul · **Power level**: top-end · **Use**: player
> **Fit**: 8 Fits today · 17 Needs key · 2 Needs rule (two-type scopes with the history read; The Fourth Smelting)
> **Checks**: 8 PASS · 0 FAIL · 2 NOT ASSESSED (The fight and the identity test: no simulator this run, user decision 2026-11-11). Budgets is PASS for arts, slots and plain technique bonuses; the technique's combat lines (`damage_more`, `convert_pct`) have no `bonus_pool` row and are NOT ASSESSED inside that check.

## Directions considered

Chosen: **The Three Smeltings (Tam Luyện)**, the full Physical → Fire → Chaos chain on every art hit. It answers the seed
directly, uses only legal conversions, and lands on the damage type that body shields cannot stop and resistance
reaches last.

Not chosen:

- **The Smith's Hammer (Thiết Chùy Quyền):** the same chain on the basic attack, opened by a conditional conversion Effect.
  Not picked: the basic attack's coefficient 1.0 and fixed 1 s timer give the chain's big multiplier a tiny base, and
  the build would need a new enabler only to reach what art hits get from their own records.
- **The Rust Bloom (Thiết Hoa):** the chain reversed, Chaos → Fire → Physical, ending Physical under uncapped Metal debuff
  stacks (+1.8 % Physical damage taken each). Not picked: a Physical finish meets block, body shields and the most
  common resistance, so the price falls on almost every matchup.

## The strongest legal chain, and what it costs

The seed's question, answered from Combat Damage Types rule 6 and Formulas A.

**What the rules allow.**
- A hit takes at most **2 conversions**, in three steps: the art's own, then Effects, then `convert_pct` modifiers.
- Each conversion reads its source type's share **at the start of its step**. A chain inside one step moves nothing
  (AC-DT-28): Physical → Fire and Fire → Chaos on the same art record leaves 0.6 Physical and 0.4 Fire, and so do two
  `convert_pct` keys. **The two links must sit in two different steps.**
- A converted part keeps its earlier types as tags for offence modifiers (L1, L2, L4, L5 scopes, crit scopes), and
  resistance, block, shields and penetration read only its final type.
- So one part can carry **at most three damage types**: its authored type and two conversions. Element tags (Kim, Hỏa,
  Mộc) are the art's and apply on top, whatever the part's type.

**The candidate chains.**

| Chain | Steps used | Final type meets | Verdict |
|---|---|---|---|
| **Physical → Fire → Chaos** | art (P → F 100 %), modifier (F → Chaos 100 pp) | Chaos: type resistance is rare by its row (Modifier System rule 13); passes body shields (Combat Damage Types rule 7) | **Chosen.** Physical has the widest supply (weapons, swords, Metal); Fire has Kindled Wound and Burn; Chaos is the best finish |
| Physical → Lightning → Chaos | art, modifier | the same finish | Even on paper. The middle needs the Thunder variant (Fire + Metal convergence, 0.6–60 % chance) to be cheap, and Lightning has no Kindled Wound. A Wood–Fire–Metal root that converges Thunder can take it later |
| Force → Fire → Chaos | art, modifier | the same finish | Weaker supply: Force is broad like Physical but has no weapon or sword family behind it |
| Physical → Chaos → Fire (or any finish but Chaos) | art, modifier | Fire meets body shields and ordinary Fire resistance | Worse finish |
| Fork: Physical → Fire and Physical → Chaos | one step, two keys | two parts, each with two types | Fewer tags per part. Its use is splitting resistance types against a Chaos-warded foe (see Matchups) |
| Same-step chain (both on the art, or two `convert_pct` keys) | one step | nothing moves past the first link | Not a chain (AC-DT-28) |

**What it costs.**

| Price | Size | Why |
|---|---|---|
| Link 1, Physical → Fire 100 % | Free on the art record | The art lint (Combat Formulas C) reads coefficient, cost and cooldown, not conversion |
| Link 2, Fire → Chaos 100 pp of `convert_pct` | Green-Smoke Rot Sutra +50 pp (an auxiliary slot), Kiln-Hook Sword +30 pp, one tree notable ~20 pp. From the tree alone: about 4–5 in-tree notables (8 W × 1.5 ÷ 0.8 = 15 pp at the reference grade; 18–26 pp at in-tree 10–14 W), about 50–60 W, 7–8 % of Nascent Soul's 739 W | Modifier System Formulas C, `convert_pct` 0.8 W per pp, implied family |
| The breakpoint | Above 50 pp | Sundered lands on the **largest part's** final type (Status Catalogue). Below 51 pp of Fire → Chaos the Fire part is larger and your Sundered lands on Fire |
| Both conversion slots | No third conversion | Nothing else may convert your hits: no answer-conversion against a Chaos-warded foe without giving up a link |
| One final type | Every hit is Chaos | Rule 18's Chaos-resistant enemy (at least 150 points against the Chaos group) meets the whole build with one number |
| Penetration on earlier types | Physical and Fire penetration do nothing | Penetration reads the final type only (Combat Defence & Healing rule 4, AC-CD-13) |
| Metal debuff | Wasted | "+1.8 % Physical damage taken" is defence-side and reads the final type. The Metal art lays Sundered instead |
| Three tags to silence | Silence [physical] stops every art (all are authored Physical) | Silence blocks arts with the named tag and every modifier needing it (Status Catalogue) |

## The Spine

- **The channel:** art hits. Every layer L1 to L5 applies, crit applies, the hit meets evade, resistance, block and
  shields. Caps: L1 400 (knee 200), L2 300, L3 250, L4 150, L5 100; crit 0.5 and ×3; conversion 2 per hit, a key's sum
  clipped at 100 pp.
- **The enabler:** none. The seed is an unusual stack of existing rules: the art's own conversion, a `convert_pct` row
  and history tags.
- **The loop:** the Metal art lays Sundered, the Fire art lays Burn, the Wood art lays Poison and Wood buff stacks; every
  hit lands as Chaos with Physical and Fire in its history; Sundered follows the Chaos; the slow Third Smelting lands
  on a target bearing Burn, Poison and three Sundered stacks.
- **The engine:** a part with two earlier types is matched by **three families of every layer at once**. Three
  techniques' L2 lines that would each serve one damage type all serve every hit, so L2 reaches its cap of 300 from
  ordinary pieces; two-type scopes ([fire, chaos], [physical, chaos]) only a converted part can match, priced at the
  narrow tier; and Former Shapes pays L5 for the history itself.
- **The sacrifice:** one finish. No resistance split, no answer-conversion, dead Physical and Fire penetration. It
  refuses to fix this: against Chaos-warded foes it forks or loses.
- **The arc:** a Qi Refining smelter whose blows are hot iron (Physical → Fire), who learns at Core Formation to let
  the charcoal smoke follow the flame, and at Nascent Soul pours all three into one blow.

## The Legend

In the black valleys where charcoal burners and iron smelters lived side by side, the work killed men three ways at
once: the hammer that slipped, the pour that splashed, and the smoke that settled in the lungs over thirty years. A
smelter who had buried his father and two brothers wrote down what he had watched them die of, and found that it was
one death in three stages. The Three Smeltings Canon (Tam Luyện Chân Kinh) is that confession turned into a method: the
blow, the heat that follows it, and the fume that follows the heat.

He died of the third stage, coughing soot, at an age a cultivator should have laughed at. His canon passed to the
valley's guild and from there to anyone who could pay. Body cultivators of the river sects hate its students: their
iron skin stops the blow and the heat, and the smoke walks through it. Poison masters of the southern marshes, who
cultivate in fumes from birth, are the ones it cannot touch.

## How It Fights

Six art slots at Nascent Soul. Four arts deal damage, and each strikes as Physical, turns wholly to Fire by its own
record, then wholly to Chaos through the build's Fire → Chaos conversion. The quick Ore-Splitting Cut lays Sundered,
Bellows Flame lays Burn, Charcoal Smoke lays Poison and gives Wood buff stacks for health regeneration. The slow
Third Smelting carries the build's own L2 and its first firing comes 6 s into the fight (4 s at +50 % art speed). A heal and a
seal-cleanse fill the last two slots. Every hit's Breakdown shows "Chaos ← Fire ← Physical".

**Signature moment:** the first Third Smelting, 4 s in. One purple number on a body cultivator whose iron skin has
eaten every Fire and Physical hit of the opening, with three Sundered stacks under it and Former Shapes, Kindled Wound,
Festering Wound and Marked Prey all lit in the Breakdown.

## The Stack

The build's modifiers, in order up the ladder. Sizes on new modifiers are first guesses.

| Rung | Modifier | Effect | Form | Channel | Layer | Status | Home | Second home |
|---|---|---|---|---|---|---|---|---|
| 1 Base | The art's own conversion | Each art record: authored 100 % Physical, Physical → Fire 100 % in the art step | Conversion | art | none | ◐ (rule designed; art records Needs key) | Three Smeltings Canon arts | first-volley's Iron Spark (60 % Lightning → Physical) |
| 1 Base | Smoke from the Flame (Hỏa Sinh Yên) | `convert_pct` Fire → Chaos, scope [art]: technique +50 pp, weapon +30 pp, notable +15 pp | Conversion | art | none | ◐ (key designed) | Green-Smoke Rot Sutra, Kiln-Hook Sword, Slag Heap cluster, Kim Đạo Lò Rèn | any Fire build that wants a Chaos finish (by-root dual-wood-fire) |
| 2 Rate | Art speed | `art_speed_pct` +50 (tree and technique) | Increased | art | none | ◐ | Tree | everyone |
| 3 L1 | Damage by type | `attack_pct` [physical], [fire], [chaos] (small +1.5/+1.8/+1.8 %, notable +10/+12/+12 %) | Increased | art | L1 | ○ rows, ● key | Tree, Slag Heap cluster | every Physical, Fire and Chaos build |
| 3 L1 | Slag and Soot, L1 (Xỉ Yên) | `attack_pct` [fire, chaos] narrow: small +2.4 %, notable +16 % | Increased | art (converted parts only) | L1 | ○ | Slag Heap cluster | any Fire → Chaos converter; dual-wood-fire Wildfire |
| 3 L2 | Kiln Heat (Diêu Nhiệt) | `damage_more` +50 [fire] | More | art | L2 | ○ | Three Smeltings Canon passive | every Fire art build (starter-flame, triple-wood-fire-metal Axeman) |
| 3 L2 | Ore Weight (Khoáng Trọng) | `damage_more` +45 [physical] (technique), +25 (Way node) | More | art | L2 | ○ | Ore-Vein Scripture; Kim Đạo Lò Rèn | sword and Metal builds; curse-engine's Iron Nail |
| 3 L2 | Lingering Fume (Tàn Yên) | `damage_more` +45 [chaos] | More | art | L2 | ○ | Green-Smoke Rot Sutra | every Chaos art build (variant-darkness, Độc Đạo arts) |
| 3 L2 | Slag and Soot, L2 (Xỉ Yên) | `damage_more` +40 [physical, chaos] (canon), +40 [fire, chaos] (Way art node) | More | art (converted parts only) | L2 | ○ | Three Smeltings Canon passive; Kim Đạo Lò Rèn | any two-link converter |
| 3 L3 | Gear | Two Cực phẩm weapons and ward gear at the top-end anchor | Flat base (gear) | art | L3 | ● | Items | everyone |
| 3 L4 | Ringing Ground via Nine Rods Array | L4 +80 on art hits from a formation (foreseen only) | More | art | L4 | ○ (staged, reused) | Formation | first-volley, dry-well, bare-fist, curse-engine |
| 3 L4 | Soot Coating (Yên Mặc Đồ) | L4 `damage_more` +50 [chaos], one fight, adds pill toxicity | More | art | L4 | ○ | Coating (preparation) | any Chaos or poison hit build |
| 3 L5 | Kindled Wound (Trì Nhiệt) | L5 +15 on parts with [fire] (type or history) against a target bearing your Burn | Conditional | art | L5 | ● (Effects Starter) | Tech, Way, Item | Fire arts |
| 3 L5 | Festering Wound (Hủ Thương) | L5 +15 on parts with [chaos] against a target bearing your Poison | Conditional | art | L5 | ○ | Green-Smoke Rot Sutra | every Poison build with hits (two-clocks' Rot Seed, starter-venom) |
| 3 L5 | Marked Prey (Tiêu Ký) | L5 +4 per distinct status of yours on the target, cap +16 (Burn, Poison, Sundered: +12) | Per | art | L5 | ● | Tech, Way, Item | curse and status builds |
| 4 Crit | Crit by type | `crit_chance_pct` scoped [physical], [fire], [chaos]: all count, because the hit's largest part carries all three (Modifier System rule 8, whole hit) | Increased | art | none | ◐ | Tree, affixes | crit builds of each type |
| 5 Reach | Sundered (Phá Giáp) | −150 Chaos resistance per stack, 3 stacks; follows the largest part's final type | Conditional (curse) | art | none | ● | Ore-Splitting Cut, Third Smelting | curse-engine |
| 5 Reach | Chaos penetration | `resist_pen_pct` [chaos] +80 (weapon), +40–80 (affix) | Flat (points) | art | none | ◐ | Kiln-Hook Sword, smelting affix | Độc Đạo Nọc lines |
| 6 Past the cap | When to stop | L2 at 300 on the Third Smelting: stop adding L2 and put the rest into L4 and L5. `convert_pct` past 100 pp clips | — | — | — | — | — | — |
| 7 Fuel | Cost and sustain | `art_cost_pct` −25, `linh_luc_on_hit_pct`, Blood Drinker (6 % of dealt as health), Wood buff health regeneration | Increased, Trigger | any | none | ● / ◐ | Tree, Kiln-Hook Sword, Charcoal Smoke | sustain builds |
| 8 Survival | A drain ward in ward slots; Charcoal Poultice; Quench (seal cleanse) | — | — | — | — | ○ arts | Ward slots; auxiliary techniques | — |
| 9 Identity | **Former Shapes (Tiền Hình)** | Your hit parts deal L5 +20 for each earlier damage type in their history (+40 for a twice-converted part, bounded by the 2 conversions) | Per | art | L5 | ○ | Kim Đạo, Lò Rèn facet (`major`) | first-volley's Iron Spark (+20 on 60 % of the hit), by-root Molten Core Canon, any conversion build |
| 10 Optional | The Fourth Smelting (Đệ Tứ Luyện) | Keystone cap shift: your hits may take 3 conversions; closes: −1 art slot | Cap shift | art | none | ○ Needs rule | Kim Đạo Lò Rèn keystone (Deity Transformation) | any converter with a fourth family to reach (Thunder roots: Physical → Fire → Lightning → Chaos) |

**Identity piece:** Former Shapes. It pays for the history itself, so it is worth nothing to an unconverted build, +20 to
a one-link build and +40 to this one. Remove the second link and it halves; remove both and it is zero.
**Empty rungs:** none. Rung 6 is a stop rule, not a gap: L2 reaches its cap on the slow art and stops.
**Forms used:** Conversion, Increased, More, Per, Conditional, Flat (gear and points), Trigger (Blood Drinker): seven.

| Layer | Points at Nascent Soul (Third Smelting, foreseen, all conditions met) | Multiplier | Sources |
|---|---|---|---|
| L1 | raw ≈ 470, effective 200 + 0.5 × 270 = 335 | ×4.35 | ≈ 290 W of tree in type-scoped and two-type rows (breadth 1.25–2.0) plus the canon's `attack_pct`. The top-end reference reaches ×3.66 from 333 W of `attack_pct` (Combat Formulas B) |
| L2 | 300 (cap) | ×4.00 | Kiln Heat 50 [fire] + Slag and Soot 40 [physical, chaos] (canon) + Lingering Fume 45 [chaos] + Ore Weight 45 [physical] (auxiliaries) + Way art nodes 90 (Slag and Soot 40 [fire, chaos], Ore Weight 25 × 2) + the art's own 30. The quick arts reach 270 (×3.7) |
| L3 | 250 (cap) | ×3.50 | Top-end gear anchor |
| L4 | 130 foreseen; 0 blind | ×2.30; ×1.00 | Nine Rods Array 80 + Soot Coating 50 |
| L5 | 82 | ×1.82 | Former Shapes 40 + Kindled Wound 15 + Festering Wound 15 + Marked Prey 12 |
| **M** | | **≈ 255 foreseen, ≈ 111 blind** | Top-end anchor at Nascent Soul: 256 |

**The same character with the second link removed** (Fire → Chaos taken away; the hit ends Fire with Physical history):
L1 loses the [chaos] and [fire, chaos] rows (≈ ×3.5), L2 loses 125 points (175, ×2.75), L4 loses the coating (×1.8),
L5 loses Festering Wound and half of Former Shapes (47, ×1.47): **M ≈ 89**, about a third. This is arithmetic on the
layer formula, not a fight result.

## Foundation

| Piece | Choice | Why |
|---|---|---|
| Spiritual root (linh căn) | Triple: Metal, Fire, Wood (Kim, Hỏa, Mộc), each 70+; Fire and Wood highest | The three elements are the three stages and three element-stack jobs: Metal (the cut, Sundered), Fire (Burn, Kindled Wound), Wood (Poison, Wood buff, Festering Wound). Wood → Fire is a generating pair (+3 % cultivation speed). Fire + Metal may converge Thunder later (`attack_pct` role, and a Lightning middle) |
| Key talents | Comprehension (ngộ tính); root bone (căn cốt) | Comprehension: three techniques to raise to great completion. Root bone: health while the opening stacks go on |
| The Way (Đạo) | Kim Đạo · Bách Luyện (Hundred Temperings), Lò Rèn facet (the Forge) | Metal's Way, met by the root. Proposed nodes: Former Shapes (`major`), Slag and Soot [fire, chaos] L2 art node, Ore Weight [physical] L2 ×2, `convert_pct` F → Chaos and `attack_pct` [physical] stat lines (staged: `lo-ren-former-shapes`; this session did not read design/dao-ways, so the facet's real contents are unchecked) |

## Công Pháp

### Three Smeltings Canon (Tam Luyện Chân Kinh) — main, Earth grade (Địa giai, tier 2, to Nascent Soul, 12 layers)

The smelter's confession: the blow, the heat, the smoke.

```json
{"id": "tam_luyen_chan_kinh", "name": "Tam Luyện Chân Kinh", "tier": 2, "tech_kind": "main",
 "names": ["kim", "hoa", "moc"], "layers": 12,
 "bonuses": [{"stat": "attack_pct", "value": 15}, {"stat": "linh_luc_pct", "value": 20},
             {"stat": "khi_huyet_pct", "value": 15}],
 "abilities": [{"ability_id": "ore_splitting_cut", "unlock_layer": 1},
               {"ability_id": "bellows_flame", "unlock_layer": 4},
               {"ability_id": "charcoal_smoke", "unlock_layer": 7},
               {"ability_id": "third_smelting", "unlock_layer": 10}],
 "passives_proposed": [{"layer": 4, "stat": "damage_more", "layer_tag": "L2", "scope": ["fire"], "value": 50},
                       {"layer": 9, "stat": "damage_more", "layer_tag": "L2", "scope": ["physical", "chaos"], "value": 40}],
 "seal_clusters": ["slag_heap"], "origin": "authored"}
```

**Fit:** Needs key (abilities, combat passives and art records have no field in `items_cong_phap.json` yet). **Budget:**
plain bonuses 1.0 + 1.0 + 1.0 = 3.0 of 3.0 at pool maxima, each ≤ 1.5 (the same lines as the staged Straw-Man Litany
Scripture). The two `damage_more` passives have no `bonus_pool` row: NOT ASSESSED for budget. They scale with B(k) only
(Cultivation Techniques rule 1). A Heaven-grade (Thiên giai) copy for Deity Transformation does not exist.

### Green-Smoke Rot Sutra (Thanh Yên Hủ Kinh) — secret art, Earth grade, names Wood

The charcoal burners' breathing method, which taught them to live in the smoke longer than their neighbours.

```json
{"id": "thanh_yen_hu_kinh", "name": "Thanh Yên Hủ Kinh", "tier": 2, "tech_kind": "secret",
 "names": ["moc"], "layers": 12,
 "bonuses": [{"stat": "khi_huyet_pct", "value": 15}, {"stat": "linh_luc_regen_pct", "value": 0.3}],
 "passives_proposed": [{"stat": "convert_pct", "from": "fire", "to": "chaos", "scope": ["art"], "value": 50},
                       {"stat": "damage_more", "layer_tag": "L2", "scope": ["chaos"], "value": 45}],
 "effects": ["festering_wound"],
 "abilities": [{"ability_id": "charcoal_poultice", "unlock_layer": 6}], "origin": "authored"}
```

**Fit:** Needs key. **Budget:** plain bonuses within 3.0 by analogy (two lines, each at or under a pool maximum);
`linh_luc_regen_pct` pool not checked: NOT ASSESSED. Harmony under the main: pairs (Wood, Metal) 0.60, (Wood, Fire) 1.00,
(Wood, Wood) 1.00, average **0.87**. It cuts the plain bonuses only; `convert_pct` and `damage_more` scale with B(k).

### Ore-Vein Scripture (Khoáng Mạch Kinh) — secret art, Earth grade, names Metal

A miner's method for feeling the grain of rock before the pick falls.

```json
{"id": "khoang_mach_kinh", "name": "Khoáng Mạch Kinh", "tier": 2, "tech_kind": "secret",
 "names": ["kim"], "layers": 12,
 "bonuses": [{"stat": "defense_pct", "value": 15}, {"stat": "linh_luc_pct", "value": 20}],
 "passives_proposed": [{"stat": "damage_more", "layer_tag": "L2", "scope": ["physical"], "value": 45}],
 "abilities": [{"ability_id": "quench", "unlock_layer": 6}], "origin": "authored"}
```

**Fit:** Needs key. **Budget:** plain bonuses 2.0 of 3.0 by analogy. Harmony: (Metal, Metal) 1.00, (Metal, Fire) 0.60,
(Metal, Wood) 0.60, average **0.73**: the price of a Metal auxiliary under a three-element main, paid only on its plain bonuses.

## Arts

Art lint: `c_art ≤ 1 + 24 · cost_share + 0.25 · (cooldown − 1)`, times `(1 − charge)` for element stacks (Effects
Formulas D). Curses carry no charge today.

| Art | Source, layer | Kind, tags | c_art | Cost | Cooldown | Guard | Fit |
|---|---|---|---|---|---|---|---|
| Ore-Splitting Cut (Khai Khoáng Trảm) | Canon, L1 | Hit, authored Physical, P → F 100 % in the art step; kim, physical, sword, curse, art, cheap | 1.97 (lint 1.97) | 0.03 | 2 s | — | Needs key |
| Bellows Flame (Cổ Bễ Hỏa) | Canon, L4 | Hit, authored Physical, P → F 100 %; hoa, physical, art | 1.89 (lint 2.70 × 0.70) | 0.05 | 3 s | — | Needs key |
| Charcoal Smoke (Thán Yên) | Canon, L7 | Hit, authored Physical, P → F 100 %; moc, physical, poison, art | 1.35 (lint 2.70 × 0.50) | 0.05 | 3 s | — | Needs key |
| Third Smelting (Đệ Tam Luyện) | Canon, L10 | Hit, authored Physical, P → F 100 %; hoa, physical, sword, curse, art, costly, slow; own L2 +30 | 4.65 (lint 4.65) | 0.10 | 6 s | — | Needs key |
| Charcoal Poultice (Thán Cao) | Green-Smoke Rot Sutra, L6 | Heal; moc, art | c_heal 4.13 (heal lint 1.4 × 2.95) | 0.05 | 4 s | own health ≤ 70 % | Needs key |
| Quench (Tôi Thiết) | Ore-Vein Scripture, L6 | Cleanse; kim, cleanse, art | — | 0.03 | 3 s | own status Sealed Meridian or Silence | Needs key |

- **Ore-Splitting Cut. Effect:** hit; applies Sundered (1 stack) on the largest part's final type: Chaos once Fire →
  Chaos passes 50 pp. **Description:** the first stroke into the ore, to find where it breaks.
- **Bellows Flame. Effect:** hit; applies 4 Burn for 5 s (20 stack-seconds, charge 0.30). **Description:** the bellows
  breathe once and the iron is white.
- **Charcoal Smoke. Effect:** hit; applies 4 Poison for 5 s (charge 0.30) and grants its owner 2 Wood buff stacks for
  10 s (charge 0.20). **Description:** the smoke the burners learned to breathe, and the enemy did not.
- **Third Smelting. Effect:** hit; applies Sundered (1 stack); carries `damage_more` +30 L2 for itself. Slot 1.
  **Description:** the blow, the pour and the fume in one motion.
- **Charcoal Poultice. Effect:** heals U × 4.13 × 4 (1,652 at Nascent Soul), refunding its cost when it heals
  (Combat Defence & Healing rule 16). **Description:** wet ash bound on a burn, the oldest medicine of the valley.
- **Quench. Effect:** cleanses curses with the `seal` cleanse tag (Sealed Meridian, Silence) from its owner.
  **Description:** hot iron into cold water, and the brittleness leaves it.

## Loadout by Realm

| Realm | Slots | Slot order | Ward | Note |
|---|---|---|---|---|
| Qi Refining | 3 | Ore-Splitting Cut, a found art, a talisman | default and a Common Ward | One link only: Physical → Fire. Physical and Fire modifiers both apply already |
| Foundation Establishment | 4 | Bellows Flame, Ore-Splitting Cut, two others | a drain ward | Green-Smoke Rot Sutra learned: about 15–25 pp Fire → Chaos (B(k) 0.3–0.5). The second link starts as a small Chaos part |
| Core Formation | 5 | Charcoal Smoke, Bellows Flame, Ore-Splitting Cut, Charcoal Poultice, Quench | two wards | Fire → Chaos passes 50 pp (canon layers 7–9 plus a tree notable): Sundered now follows the Chaos part. Former Shapes on the Way |
| **Nascent Soul** | 6 | Third Smelting, Charcoal Smoke, Bellows Flame, Ore-Splitting Cut, Charcoal Poultice, Quench | drain ward in a ward slot | 100 pp: the whole hit is Chaos. L2 300 on the slow art. Defining realm |
| Deity Transformation | 7 | as above + an escape | as above | Needs a Heaven-grade copy of the canon (not designed). Optional: The Fourth Smelting (Needs rule) |

## Items

| Item | Type, role | Base, grade, tier | What it does for the build | Fit |
|---|---|---|---|---|
| Kiln-Hook Sword (Diêu Câu Kiếm) | Named artifact, weapon | `phi_kiem`, Cực phẩm, Nascent Soul tier | `convert_pct` Fire → Chaos +30 [art]; `resist_pen_pct` [chaos] +80; `artifact_attack_pct` +30; carries Blood Drinker (existing Effect: restore 6 % of what your hits deal). Engine (link 2), reach, sustain | Fits today (named item on designed keys; Blood Drinker lists Item) |
| Smelting affixes | Affix rows for generated artifacts | any weapon base | "Hóa Yên" `convert_pct` Fire → Chaos +10–25 pp; "Thực" `resist_pen_pct` [chaos] +40–80. The player's route to 100 pp without the named sword | Fits today (rows on designed keys) |
| Second weapon | Artifact, weapon | `an` or `phi_kiem`, Cực phẩm | L3, and crit by type | Fits today |
| Ward gear | Artifact, ward role | `chuong` or `thuan` | Ward defence | Fits today |
| Nine Rods Array (Cửu Can Trận) | Formation (foreseen) | staged by first-volley | Ringing Ground L4 +80 on art hits | Needs key (reused) |
| Soot Coating (Yên Mặc Đồ) | Coating, preparation (foreseen and ambush) | — | L4 +50 [chaos]; adds pill toxicity (đan độc) as its recipe sets | Needs key (a coating's fight payload) |

The Kiln-Hook Sword: a flying sword forged with a hook at the tip, used in the valley to drag the slag skin off a pour.
The guild gave it to whoever finished the canon; most who earned it had already started to cough.

## Tree and Clusters

| Priority | Node, cluster or keystone | Value | Why | Fit |
|---|---|---|---|---|
| 1 | `convert_pct` Fire → Chaos [art] notables | +15 pp at reference (18–26 in-tree) | Close the gap to 100 pp; past 50 pp Sundered follows | ◐ key, ○ rows |
| 2 | `attack_pct` [fire, chaos] (Slag Heap) | +2.4 % small, +16 % notable | The best L1 per W the build can match | ○ |
| 3 | `attack_pct` [fire], [chaos], [physical] | +1.8/+1.8/+1.5 % small | Every one of them matches every hit | ○ rows |
| 4 | `crit_chance_pct` scoped by type | +1.2/+8 pp (universal sizes) or more scoped | To the 0.5 cap | ● / ○ |
| 5 | `art_cost_pct`, `linh_luc_regen_pct` | −3 % / +1 pp notable | Fuel | ● |
| 6 | `resist_pen_pct` [chaos] | +18/+120 pts | The counter's answer | ◐ |
| Stop | L1 past raw 600 (effective 400) | — | Hard cap | — |

### Hidden cluster idea: Slag Heap (Xỉ Đôi)

Theme: what fire leaves behind: slag, soot, smoke (wider than this build: any Fire build with a Chaos or Physical
side reads it). Element affinity Fire. Kind: sealed; seal condition: the Three Smeltings Canon lists it in
`seal_clusters`. Size 9 acupoints, one notable per `huyet_per_notable`, the payoff farthest. Smalls: `attack_pct`
[fire, chaos] +2.4 % (×2), `attack_pct` [physical] +1.5 %, `convert_pct` Fire → Chaos +2 pp (×2), `resist_pen_pct` [chaos] +18;
notables `convert_pct` Fire → Chaos +15 pp and, farthest, `attack_pct` [fire, chaos] +16 %. No capability.

## Đạo

No new Way. The build asks Kim Đạo (Bách Luyện, Hundred Temperings) for its Lò Rèn facet (the Forge) to hold
Former Shapes as its `major` Effect, Slag and Soot [fire, chaos] as an L2 art node, Ore Weight [physical] ×2, and
stat lines `convert_pct` Fire → Chaos and `attack_pct` [physical]. The facet is about what fire does to metal, which is
the build. Staged as `lo-ren-former-shapes`; the Way's real graph (design/dao-ways) was not read this session.

## Progression

| Realm | Plays like | New piece | Story beat |
|---|---|---|---|
| Qi Refining | A Physical sword cultivator whose cuts arrive hot | Ore-Splitting Cut, its own Physical → Fire | Apprenticed to the guild; learns the first smelting |
| Foundation Establishment | Burn builder; a sliver of Chaos on every hit | Bellows Flame; Green-Smoke Rot Sutra | Breathes the smoke on purpose for the first time |
| Core Formation | Sundered starts landing on Chaos; body cultivators stop being a wall | Charcoal Smoke, Former Shapes, Fire → Chaos past 50 pp | The first cough; the first river-sect duel won through iron skin |
| Nascent Soul | Every hit is Chaos with two earlier shapes; L2 at its cap | Third Smelting, Kiln-Hook Sword | Takes the sword; buries a brother of the guild who did not |
| Deity Transformation | Unchanged unless a fourth link is legal | The Fourth Smelting (Needs rule), a Heaven-grade canon | Looks for the fourth stage the founder never wrote |

## Matchups

| Enemy (Combat rule 18 types) | Result | Why |
|---|---|---|
| Body cultivator (thể tu), heavy block and body shields | wins | Chaos passes body shields; block still takes its flat share |
| Typical warded caster (R 557 at Nascent Soul) | wins | After Sundered ×3 and 160 penetration, Chaos R ≈ −53: hits are amplified ×1.53 |
| Top-end warded caster (R ≈ 1,500) | wins on paper | Chaos R ≈ 890 after Sundered and penetration: 10.1 % through instead of 6.25 % |
| Chaos-resistant enemy (≥ 150 points against Chaos, rule 18) | even to loses | The one number the build cannot route round. Answer: more Chaos penetration, or a fork loadout (drop the Fire → Chaos sources so hits end Fire) |
| Curser with Sealed Meridian (L2) | loses the exchange it lands in | L2 ×4.0 → ×1.0 for 2 pulses: three quarters of the damage gone. Quench cleanses it |
| Silencer naming [physical] | loses until cleansed | Every art is authored Physical, so none fires. Quench answers |
| Cleanser (cleansing ward) | even | Burn and Poison thin, so Kindled Wound, Festering Wound and Marked Prey flicker; Former Shapes and the layers stay |
| Drainer (Qi Disruption, soul arts) | even | Six arts on a 0.03–0.10 budget; the pool empties first. Leech and the heal carry it |

**Counter:** the Chaos-resistant poison master. Their Chaos resistance meets every hit with one number, and their own
Poison passes your body shields as yours passes theirs.

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | PASS | Arts within the lint (1.97, 1.89, 1.35, 4.65; heal 4.13); 6 slots of 6 at Nascent Soul; 4 artifacts of `equip.max_slots` 6; canon's plain bonuses 3.0 of 3.0. **NOT ASSESSED inside it:** the techniques' `damage_more` and `convert_pct` lines (no `bonus_pool` row) and thần thức for the artifact set (not summed) |
| Validity | PASS | Elements kim, hoa, moc; damage types physical, fire, chaos; base `phi_kiem`; Earth grade reaches Nascent Soul (12 layers); every conversion is in a separate step, never to or from Soul, never back; harmony 0.87 and 0.73 computed |
| Stack | PASS | Nine rungs filled (rung 6 a stop rule); seven forms; no L5 on ticks; layer totals stated; identity piece named |
| Identity test | NOT ASSESSED | No simulator this run (user decision 2026-11-11). Layer arithmetic only: without the second link M falls from ≈ 255 to ≈ 89 |
| Scaling | PASS | M ≈ 255 foreseen against the top-end anchor 256 at Nascent Soul (INFO: L1 above the anchor, L4 and L5 below it). Blind ≈ 111 |
| The fight | NOT ASSESSED | No simulator this run (user decision 2026-11-11). Not hand-simulated |
| Reuse | PASS | Reuses Kindled Wound, Marked Prey, Blood Drinker, Sundered (game); Nine Rods Array, Deeper Nails (staging); `convert_pct` (Modifier System). One signature piece (Kiln-Hook Sword); every new modifier names a second home |
| NPC use | PASS | Every new modifier is a plain catalogue row; Former Shapes and Festering Wound read a hit's tags and statuses on the target, both readable; all `npc: true` |
| Counterplay | PASS | Chaos-resistant enemy (rule 18 group resistance), Sealed Meridian on L2, Silence [physical] |
| Originality | PASS | Names built from the valley's trade (smelting, charcoal, slag); no novel or game names |

## Fight Results

Not run. No combat simulator this run (user decision 2026-11-11); no fight input was written and nothing was simulated
by hand. The numbers above are single-formula arithmetic from Combat Formulas B and C and Combat Defence & Healing
rule 3.

**Unmodelled:** everything that happens over time: linh lực spend against regeneration and ward bills, stack build-up
of Burn, Poison and Sundered, the first-firing delays, crit variance, the heal and the cleanse.

## New Content Needed

| Item | Type | What is needed |
|---|---|---|
| Two-type scopes (Slag and Soot) and Former Shapes' read | Needs rule (clarification) | Modifier System rule 8: say that a scope of two damage types is valid and matches only through history; Effects rule 5: name "a part's earlier types" as readable (suggestion 1) |
| Art records with their own conversion | Needs key | Art record fields for conversions (Combat rule 13; Combat Damage Types rule 6 step 1) |
| Technique combat passives (`damage_more`, `convert_pct`) | Needs key | A field in `items_cong_phap.json` and `bonus_pool` rows |
| Kiln Heat, Ore Weight, Lingering Fume, Slag and Soot | Needs key | Content rows on designed keys |
| Smoke from the Flame | Needs key | `convert_pct` Fire → Chaos rows (designed key) |
| Festering Wound | Needs key | Effect record (mirror of Kindled Wound) |
| Former Shapes | Needs key | Effect record; the history read (above) |
| Soot Coating | Needs key | A coating's fight payload |
| Smelting affixes | Fits today | Two rows in `items_artifacts.json` affixes |
| Kiln-Hook Sword | Fits today | Named item |
| The Fourth Smelting | Needs rule | Combat Damage Types rule 6 (2 per hit; Tuning Knobs safe range 1–3), as a keystone cap shift (suggestion 2) |

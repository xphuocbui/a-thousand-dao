# The Three Smeltings (Tam Luyện)

Strike as iron, burn as fire, kill as smoke: every blow carries three kinds of damage bonus at once and lands as the
one kind that iron skin cannot stop.

## Why it works

Four rules of the game make this build.

1. **A hit can change its damage type twice.** A hit's damage can be *converted*: some or all of it changes type, say
   from Physical to Fire. Each hit takes at most two conversions, and they happen in steps: first the art's own
   conversion, then conditional Effects, then plain conversion bonuses (`convert_pct`).
2. **A converted hit remembers what it was.** Damage that went Physical → Fire → Chaos still counts as Physical and as
   Fire for *your* bonuses. "+12 % Physical damage", "+12 % Fire damage" and "+12 % Chaos damage" all apply to it.
   The enemy's defence only sees the last type: Chaos.
3. **Chaos is the hardest type to defend.** Chaos damage passes body shields (the iron skin of body cultivators, thể tu),
   and Chaos resistance comes only from rare sources.
4. **Your bonuses come in layers that multiply.** Bonuses of the same layer add together; the five layers multiply
   (L1 "increased", L2 "more" from techniques and arts, L3 gear, L4 preparation, L5 conditions). Each layer has a cap.

**The catch, and the trick.** The two conversions must sit in **different steps**. If one art tries to turn Physical
into Fire *and* Fire into Chaos, the second does nothing, because it looks for Fire at the start of the step and
finds none. So this build puts the first link on the art itself (every art of its technique is struck as Physical
and turns itself 100 % to Fire) and the second link on plain Fire → Chaos bonuses (100 points in total).

**What that buys.** Normally a technique that gives "more Fire damage" is useless to your Physical arts. Here every
technique, Way node, coating and condition aimed at *any* of the three types feeds *every* hit. Your L2 layer (the
technique bonuses, capped at 300 points) fills from three families at once:

| L2 source | Points | Applies because the hit is… |
|---|---|---|
| Three Smeltings Canon, Kiln Heat | +50 | Fire (in its history) |
| Three Smeltings Canon, Slag and Soot | +40 | Physical *and* Chaos (only a converted hit has both) |
| Green-Smoke Rot Sutra, Lingering Fume | +45 | Chaos |
| Ore-Vein Scripture, Ore Weight | +45 | Physical (in its history) |
| The Way: Slag and Soot +40, Ore Weight +25 × 2 | +90 | Fire and Chaos; Physical |
| Third Smelting's own bonus | +30 | itself |
| **Total** | **300, the cap: ×4.0** | |

**The key numbers** (from the game's damage formulas at Nascent Soul (Nguyên Anh); arithmetic, not a fight test):

- All five layers on your big art, the Third Smelting, with a formation and coating prepared: **×4.35 × 4.0 × 3.5 ×
  2.3 × 1.82 ≈ ×255**. The game's "top-end" reference at Nascent Soul is ×256. You reach it from ordinary pieces.
- The same character with the second link taken away (hits end as Fire): about **×89**, a third.
- One Third Smelting before defence: 100 (Nascent Soul's fight unit) × 4.65 (the art's coefficient) × 255 ≈ **118,600**.
- Against a top-end warded enemy (about 1,500 resistance points), three Sundered stacks (−450 Chaos resistance) and
  160 Chaos penetration leave 890 points, so about **12,000** gets through. With the hit ending Fire instead, about
  3,600 does.
- Against a typical Nascent Soul enemy (557 points), the same curses push Chaos resistance below zero (−53), and
  negative resistance *amplifies*: ×1.53.

**What it costs:** the first link is free (an art's own conversion is not priced by the art's power limit). The
second needs 100 points of Fire → Chaos: +50 from an auxiliary technique, +30 from a weapon, and a tree notable or
two, or about 50–60 W (7–8 % of your tree at Nascent Soul) if it all comes from the tree. You give up any other
conversion, any damage-type spread, and all Physical and Fire penetration.

## What to look for

In the order a player usually finds them.

1. **Spiritual root (linh căn): Triple, Metal, Fire and Wood (Kim, Hỏa, Mộc), each 70 or more.** Each element has a
   job: Metal cuts (Sundered), Fire burns (Burn), Wood smokes (Poison, and Wood buff stacks that heal you). Wood feeds
   Fire, a generating pair (+3 % cultivation speed). *In the game.*
2. **Talents: comprehension (ngộ tính) and root bone (căn cốt).** Comprehension for three techniques to great
   completion; root bone for health while your stacks go on. *In the game.*
3. **The Way (Đạo): Kim Đạo · Bách Luyện (Hundred Temperings), the Lò Rèn facet (the Forge).** Wanted nodes: Former
   Shapes (the identity piece), Slag and Soot (+40 L2, Fire and Chaos), Ore Weight (+25 L2 Physical, twice), Fire →
   Chaos conversion lines. *The Way is in the catalogue; these nodes are not in the game yet (staged:
   `lo-ren-former-shapes`, `former-shapes`, `history-scopes`, `ore-weight`, `smoke-from-flame`).*
4. **Main technique (công pháp): Three Smeltings Canon (Tam Luyện Chân Kinh).** Earth grade (Địa giai), names Metal,
   Fire and Wood, to Nascent Soul. Holds all four damage arts and two L2 passives. *Not in the game yet (staged:
   `three-smeltings-canon`).*
5. **Auxiliary techniques:**
   - Green-Smoke Rot Sutra (Thanh Yên Hủ Kinh), Wood: +50 points Fire → Chaos, +45 L2 Chaos, Festering Wound, a heal.
     *Not in the game yet (staged: `green-smoke-sutra`).*
   - Ore-Vein Scripture (Khoáng Mạch Kinh), Metal: +45 L2 Physical, the Quench cleanse. *Not in the game yet (staged:
     `ore-vein-scripture`).*
6. **Arts (thần thông):**
   - Ore-Splitting Cut (Khai Khoáng Trảm): quick, cheap, lays Sundered. *Not in the game yet (staged: `ore-splitting-cut`).*
   - Bellows Flame (Cổ Bễ Hỏa): lays 4 Burn. *Not in the game yet (staged: `bellows-flame`).*
   - Charcoal Smoke (Thán Yên): lays 4 Poison, gives you 2 Wood buff stacks. *Not in the game yet (staged: `charcoal-smoke`).*
   - Third Smelting (Đệ Tam Luyện): the slow, heavy blow; lays Sundered. *Not in the game yet (staged: `third-smelting`).*
   - Charcoal Poultice (Thán Cao): a heal. *Not in the game yet (staged: `charcoal-poultice`).*
   - Quench (Tôi Thiết): cleanses Sealed Meridian and Silence from you. *Not in the game yet (staged: `quench`).*
7. **Items:**
   - Kiln-Hook Sword (Diêu Câu Kiếm), a named flying sword: +30 Fire → Chaos, +80 Chaos penetration, Blood Drinker.
     *Not in the game yet (staged: `kiln-hook-sword`).*
   - Smelting affixes on any generated weapon: "Hóa Yên" (Fire → Chaos +10–25) and "Thực" (Chaos penetration +40–80).
     *Not in the game yet (staged: `smelting-affixes`).*
   - Nine Rods Array (Cửu Can Trận), a formation: +80 L4 on art hits in foreseen fights. *Not in the game yet (staged:
     `nine-rods-array`, from another build).*
   - Soot Coating (Yên Mặc Đồ): +50 L4 on Chaos hits for one fight. *Not in the game yet (staged: `soot-coating`).*
8. **Enabler:** none. This build is an unusual stack of rules that already exist.

## The enabling Effects

No enabler; these Effects carry the build.

- **Former Shapes (Tiền Hình)**, the identity piece. *Your hit parts deal +20 more (L5) for each earlier damage type
  in their history.* A twice-converted hit gets +40, a once-converted hit +20, an unconverted hit nothing. It is the
  reason to finish the chain rather than stop at one link. *Not in the game yet (staged: `former-shapes`).*
- **Kindled Wound (Trì Nhiệt).** *Your Fire parts deal +15 more (L5) to a target bearing your Burn.* Your hits end as
  Chaos, but they still count as Fire, so it applies. *In the game.*
- **Festering Wound (Hủ Thương).** *Your Chaos parts deal +15 more (L5) to a target bearing your Poison.* The Chaos
  twin of Kindled Wound. *Not in the game yet (staged: `festering-wound`).*
- **Marked Prey (Tiêu Ký).** *+4 more (L5) for each different status of yours on the target, up to +16.* Burn,
  Poison and Sundered make +12. *In the game.*
- **Sundered (Phá Giáp)**, a curse. *−150 resistance per stack (3 stacks) to the damage type of the hit's largest part.*
  Once your hits are more than half Chaos, Sundered strips Chaos resistance, and your Poison ticks profit too. *In
  the game.*
- **Blood Drinker (Ẩm Huyết).** *Restore 6 % of what your hits deal as health.* Your sustain, on the Kiln-Hook Sword.
  *In the game.*

## Modifiers to stack

Most important first.

1. **Fire → Chaos conversion (`convert_pct`, Fire → Chaos), to 100.** *The engine.* The first breakpoint is **51**:
   above it, Sundered follows the Chaos part. Stop at **100**; anything past it is wasted (a key's sum clips at 100).
2. **L2 "more" from all three families: [fire], [physical], [chaos], and the two-type [physical, chaos] and
   [fire, chaos].** *Layer L2.* Stop at **300** on the Third Smelting (the cap). The quick arts sit near 270.
3. **L5 conditions: Former Shapes, Kindled Wound, Festering Wound, Marked Prey.** *Layer L5.* They reach 82 of the
   100 cap; Weight of Names or Steady Breath can fill the rest.
4. **Damage "increased" scoped by type or by two types.** *Layer L1.* Two-type nodes like [fire, chaos] give twice an
   unscoped node's value per point of tree budget (a third more than a one-type node), and only converted hits can use them. Falling returns past 200 points (each
   point counts half), hard stop at 400 effective (600 raw).
5. **Crit chance, any of the three types.** *Outside the layers.* All three count, because your hit's one part carries all
   three. Stop at 50 % (the cap); then crit damage, to ×3.
6. **Chaos penetration.** *Reach.* Only Chaos penetration works; Physical and Fire penetration do nothing. No cap; it is
   your answer to Chaos-resistant enemies.
7. **L4 preparation: a combat formation and a Chaos coating.** *Layer L4.* Cap 150; only counts in foreseen fights.
8. **Art cost reduction and linh lực per hit.** *Fuel.* Six arts drain the pool; art cost stops at −50 %.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Smoke from the Flame | `convert_pct` Fire → Chaos, scope [art] | The second link; past 50 Sundered follows the Chaos | Green-Smoke Rot Sutra (+50), tree notables (+15), Kim Đạo Lò Rèn lines | Staged: `smoke-from-flame` | core |
| Three Smeltings Canon arts | Art's own Physical → Fire 100 % | The first link, free, on every damage art | Main technique | Staged: `three-smeltings-canon` and its arts | core |
| Former Shapes | Effect: L5 +20 per earlier type | +40 L5 on every hit; the reason to finish the chain | Kim Đạo, Lò Rèn facet (`major`) | Staged: `former-shapes` | core |
| Slag and Soot | `damage_more` L2 [physical, chaos] / [fire, chaos], `attack_pct` [fire, chaos] | L2 and L1 only a converted hit can use, at the narrow price | Canon passive, Way art node, Slag Heap cluster | Staged: `history-scopes` | core |
| Kiln Heat | `damage_more` +50 L2 [fire] | 50 of the 300 L2 | Canon passive (layer 4) | Staged: `kiln-heat` | core |
| Lingering Fume | `damage_more` +45 L2 [chaos] | 45 L2 | Green-Smoke Rot Sutra | Staged: `lingering-fume` | core |
| Ore Weight | `damage_more` +45 / +25 L2 [physical] | 95 L2 across technique and Way | Ore-Vein Scripture; Kim Đạo Lò Rèn | Staged: `ore-weight` | core |
| Kiln-Hook Sword | `convert_pct` +30, Chaos penetration +80, Blood Drinker | 30 of the 100 points of conversion, reach and sustain in one slot | Named item (guild reward) | Staged: `kiln-hook-sword` | strong |
| Smelting affixes | `convert_pct` Fire → Chaos +10–25; `resist_pen_pct` [chaos] +40–80 | The route to 100 without the named sword | Generated weapons | Staged: `smelting-affixes` | strong |
| Festering Wound | Effect: L5 +15 on Chaos vs your Poison | 15 L5 | Green-Smoke Rot Sutra | Staged: `festering-wound` | strong |
| Kindled Wound | Effect: L5 +15 on Fire vs your Burn | 15 L5, through history | Techniques, Way, items | In the game | strong |
| Marked Prey | Effect: L5 +4 per status | 12 L5 from Burn, Poison, Sundered | Techniques, Way, items | In the game | strong |
| Nine Rods Array | Ringing Ground L4 +80 | Most of L4 in foreseen fights | Formation | Staged: `nine-rods-array` | strong |
| Soot Coating | `damage_more` L4 +50 [chaos] | The rest of L4 | Coating (alchemy) | Staged: `soot-coating` | strong |
| Deeper Nails | `curse_effect_pct` | Bigger Sundered: −187.5 a stack at +25 % | Nine Knots cluster; Sinh Tử Đạo lines | Staged: `deeper-nails` (another build) | nice |
| Slag Heap cluster | `attack_pct` [fire, chaos], `convert_pct`, Chaos penetration | A planned tree path for L1 and the last conversion points | Hidden cluster (sealed by the canon) | Staged: `slag-heap-cluster` | nice |
| Crit by type | `crit_chance_pct` [physical], [fire] or [chaos] | To the 50 % cap from three pools | Tree, affixes | Stat in the game; scoped rows staged with the tree rework | nice |
| The Fourth Smelting | Keystone: 3 conversions per hit, −1 art slot | A fourth family (Lightning, with a Thunder root) | Kim Đạo Lò Rèn keystone, Deity Transformation | Staged: `fourth-smelting` (needs a rule change) | nice |

## Realm by realm

- **Qi Refining (Luyện Khí).** Ore-Splitting Cut strikes Physical and turns itself to Fire. One link only, but Physical
  and Fire bonuses both already apply. Fill the other slots with what you find.
- **Foundation Establishment (Trúc Cơ).** Bellows Flame and Burn. Learn the Green-Smoke Rot Sutra: at its early layers it
  gives 15–25 points of Fire → Chaos, a thin Chaos slice on every hit.
- **Core Formation (Kết Đan).** Charcoal Smoke, Poison and Wood buff healing. Push Fire → Chaos **past 50**: Sundered
  now strips Chaos resistance, and body cultivators stop being a wall. Take Former Shapes on the Way.
- **Nascent Soul (Nguyên Anh), the build's peak.** Third Smelting; Fire → Chaos at 100, so every hit is Chaos with two
  earlier shapes; L2 at its 300 cap; the Kiln-Hook Sword.
- **Deity Transformation (Hóa Thần).** The canon stops at Nascent Soul; a Heaven-grade (Thiên giai) copy does not exist
  yet. If the Fourth Smelting is ever made legal, a Thunder root can add Lightning as a fourth shape.

## How it plays

**Loadout at Nascent Soul (six art slots, in order):** Third Smelting, Charcoal Smoke, Bellows Flame, Ore-Splitting
Cut, Charcoal Poultice (heals at 70 % health), Quench (fires only when you are Sealed or Silenced). A drain ward in a
free ward slot.

**Order of play:** the fight runs itself on cooldowns. Ore-Splitting Cut (every 2 s) keeps Sundered on; Bellows Flame
and Charcoal Smoke (every 3 s) keep Burn, Poison and your Wood buff up; the Third Smelting comes 6 s in (4 s with +50 %
art speed) and every 6 s after. Put it in slot 1 so it pays first when linh lực runs short.

**The signature moment:** the first Third Smelting against a body cultivator. Every Fire and Physical blow of the
opening has vanished into their iron skin; this one is a single purple Chaos number, its Breakdown reading
"Chaos ← Fire ← Physical", with Former Shapes, Kindled Wound, Festering Wound and Marked Prey all lit.

## What beats it

- **A Chaos-resistant enemy** (every realm has one: at least 150 resistance points against Chaos). Your whole build
  meets one number. Adapt: stack Chaos penetration, or before a foreseen fight take off the Fire → Chaos pieces so
  your hits end as Fire.
- **Sealed Meridian on your L2.** Your ×4.0 becomes ×1.0 for two seconds. Quench cleanses it; keep it slotted.
- **Silence naming Physical.** All your arts are struck as Physical, so none fires. Quench again.
- **Cleansers.** A cleansing ward thins your Burn and Poison, and Kindled Wound, Festering Wound and Marked Prey
  flicker. The layers and Former Shapes stay. Accept it.
- **Drainers.** Six arts drain your pool; against Qi Disruption or soul arts you run dry first. Art cost reduction,
  linh lực per hit and Blood Drinker carry you.
- **Poison masters**: Chaos-resistant, and their Poison passes your body shields as yours passes theirs. Your worst
  matchup.

## Not in the game yet

Every staged piece this build needs (all in the staging catalogue):

- Technique and arts: `three-smeltings-canon`, `green-smoke-sutra`, `ore-vein-scripture`, `ore-splitting-cut`,
  `bellows-flame`, `charcoal-smoke`, `third-smelting`, `charcoal-poultice`, `quench`.
- Modifiers: `smoke-from-flame`, `history-scopes`, `kiln-heat`, `lingering-fume`, `ore-weight`.
- Effects: `former-shapes`, `festering-wound`, `fourth-smelting` (optional).
- Items: `kiln-hook-sword`, `smelting-affixes`, `soot-coating`, `nine-rods-array` (from another build).
- Way and tree: `lo-ren-former-shapes`, `slag-heap-cluster`, `deeper-nails` (from another build, optional).
- Concept: `history-read` (a hit's earlier types as something scopes and Effects may read).

## Changes the game would need

1. **Say that a part's earlier damage types are a scope and a readable.** Modifier System
   (`design/gdd/modifiers.md`) rule 8: state that a scope of two damage types ([fire, chaos]) is valid and matches only
   a converted part through its history, priced at the narrow tier (Formulas B). Effects System
   (`design/gdd/effects.md`) rule 5: name "a hit part's earlier types (its history)" on the readable list, so Former
   Shapes can count them. Today both are implied by Combat Damage Types rule 6 but not written, and validation might
   reject a two-type scope as one that can never match.
2. **Optional: a keystone that allows a third conversion.** Combat Damage Types (`design/gdd/combat-damage-types.md`)
   rule 6 and Tuning Knobs ("conversions per hit", 2, safe range 1–3): let one keystone, The Fourth Smelting, raise its
   holder's limit to 3, closing one art slot. The build does not need it; it is the legend version.

# Cultivation Techniques (Công Pháp)

> **Status**: In Review (design-review 2026-11-10: NEEDS REVISION, 2 blocking; answers and fixes applied the same day, see `reviews/cong-phap-review-2026-11-10.md`; confirming re-review 2026-11-10 answered and fixed the same day, see `reviews/cong-phap-rereview-2026-11-10.md`).
> **Creative Director Review (CD-GDD-ALIGN)**: skipped (Lean mode)
> **Author**: user + Claude
> **Last Updated**: 2026-11-10
> **Last Verified**: 2026-11-10
> **Implements Pillar**: Pillar 3 (Power Is Built, Not Given); touches Pillar 1 (Your Dao, Your Name) and Pillar 4 (Every Season Counts)

## Summary

A cultivation technique (công pháp) is the method a cultivator cultivates with. It is
found, bought or inherited as a manual and mastered technique layer by technique
layer (tầng công pháp) over
seasons.
- **The main method** sets cultivation speed. Speed comes from how well the
  technique's elements fit the spiritual root, its tier and its mastered layers.
- **Two auxiliary arts** add bonuses and divine abilities (thần thông), weighed by
  their element harmony with the main method.

Choosing which technique to commit seasons to, and when to switch at a tier
ceiling, is a core build decision of Pillar 3.

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `Spiritual Roots, Realms & Bottlenecks, Character Stats, Item DB; soft: Time & Turn, Meridian Map`

## Overview

A cultivation technique (công pháp) is the method a cultivator uses to draw spiritual qi
(linh khí) through their spiritual root (linh căn).

**What a technique has.** Each technique is an item with:
- a tier (Yellow, Profound, Earth or Heaven; Hoàng, Huyền, Địa, Thiên);
- the elements or variant roots (biến dị) it names;
- a ladder of technique layers (tầng công pháp), mastered one by one over seasons. In
  this GDD "layer" always means a technique layer, never a Qi Refining layer, which is
  one level of that realm (glossary).

**What it does.** The technique's speed factor feeds the Realms cultivation rate. The
factor depends on how well the cultivator's root matches the named elements and how
many layers they have mastered. A technique also adds stat bonuses through the
Character Stats provider interface. At set layers it unlocks divine abilities (thần
thông); this GDD owns when they unlock, and Combat owns what they do.

**The slots.**
- One main method (chủ tu) sets cultivation speed and technique power.
- Up to two auxiliary arts (phụ tu), such as secret arts and body techniques, add
  bonuses and abilities but no speed. They are weaker when their elements clash with
  the root or the main method.

**Where techniques come from.** Players find them in the world, buy them, earn them
from sects or inherit them from the world's history. Each technique remembers the
layers mastered in it, so switching costs only the seasons needed to climb a new
ladder.

**Why it matters.** Without this system, cultivation speed would be fixed by the root
alone, and Pillar 3 (Power Is Built, Not Given) would lose its main build decision:
which technique you commit your seasons to. The decision has two sides:
- a high-tier technique in elements you are weak in;
- a humbler one that fits your root.

## Detailed Design

### Core Rules

**The technique record**

1. **What a technique is.** A technique is a template in `items_cong_phap.json`. Each
   copy found in the world is an Item DB manual (bí tịch) that points at the template.
   A template has:
   - `id`, `name`, `tier` (0–3) and `tech_kind` (rule 2: `main`, `secret` or `body`);
   - `names`: the elements or variant roots it draws on (1–3 ids; none for a body
     technique);
   - `layers`: the layer count, set by the tier (rule 5);
   - `bonuses`: stat modifiers, each with a value at full mastery (Formulas D);
   - `abilities`: divine abilities (thần thông), each `{ability_id, unlock_layer}`; `ability_id` points at a Combat art
     record (Combat rule 13: id, tags, typed damage parts, linh lực cost, cooldown, effect), which Combat owns;
   - `effects`: Effect ids the technique hosts (Effects System rule 13; a technique may be an enabler), and `tags`
     (the union of its modifiers' tags, Modifier System rule 9). `bonuses` stay priced by `bonus_pool` and
     `bonus_budget` for now; they move to the Modifier System's W budgets when the catalogue is authored (user
     decision 2026-11-10, review D4). A `damage_more` or conversion modifier (Modifier System rule 12, L2) scales with
     B(k) only, not with F, H or `comp_strength`. `effects` do not use `bonus_pool` or the budget, and an enabler's
     `closes` is checked at load (Effects System rule 13);
   - `body_defence`: not a field; a body technique's Combat Iron Body tier is derived from its tier and mastered
     layer (rule 2), so nothing can disagree with it;
   - `origin`: `authored` or `generated` (rule 17).
2. **Kinds.**
   - **Main method** (tâm pháp): the only kind that sets cultivation speed and
     technique power. It goes in the main slot.
   - **Secret art** (bí thuật): an auxiliary art that names elements. It adds
     bonuses and abilities, never speed.
   - **Body technique** (luyện thể): an auxiliary art that names no element. It
     scales with Physique (căn cốt) instead of purity (Formulas D). This is the
     route for a cultivator whose root fits no art they have found. In a fight it gives the body's defence (block,
     body shield and Physical resistance; Combat rule 23, Combat Defence & Healing rule 12) at **fixed sizes per
     tier** (user decision 2026-11-10, review D2): a body technique of tier t (0–3) at mastered layer k reaches Combat's Iron
     Body tier `iron_tier(k) = 1 + floor((k − 1) × (T − 1) ÷ (layers − 1))`, with T = t + 2 (2 / 3 / 4 / 5 for Yellow,
     Profound, Earth, Heaven; re-review D-2): tier 1 at its first layer, T at great completion.
     Each Combat tier adds block +10, body shield σ_b +0.10 and Physical resistance +8.3 points (Combat Defence &
     Healing Formulas H), so a Profound body technique at great completion gives 30 / 0.30 / 25 points. These lines are
     outside `F`, `B(k)` and `comp_strength`, and outside `bonus_pool` and the budget.
3. **Tiers.** Yellow, Profound, Earth and Heaven (Hoàng, Huyền, Địa, Thiên), ranks
   0–3. The tier sets:
   - the speed and power scale;
   - the layer count and the maximum realm (rule 5);
   - the bonus budget (Formulas D);
   - the price band (Market).

   A higher tier is never a strict upgrade: it may name elements you are weak in.

**Learning and slots**

4. **Learning.** Reading a manual teaches its technique. The technique joins the
   character's known list with layer 1 mastered; it takes no season and costs no
   resource.
   - The manual stays an item: it can be kept, sold or given away. Sects may forbid
     selling their manuals (Sects & Missions).
   - A character may learn a technique whose named ids their root lacks. They cannot
     slot it until the root has every named id (rule 8).
   - Learning the same technique twice does nothing.
5. **Layers and realms.** Every tier has 3 layers per realm up to its maximum realm:

   | Tier | Max realm | Layers |
   |---|---|---|
   | Yellow (Hoàng) | Foundation Establishment | 6 |
   | Profound (Huyền) | Core Formation | 9 |
   | Earth (Địa) | Nascent Soul | 12 |
   | Heaven (Thiên) | Deity Transformation | 15 |

   - Layer *k* needs the cultivator to be in realm ⌈*k* ÷ 3⌉ or higher: layers 1–3
     need QR, 4–6 FE, 7–9 CF, 10–12 NS and 13–15 DT.
   - So a Heaven technique found in Qi Refining stops at layer 3 until Foundation
     Establishment, like any other technique. Its tier still gives a higher speed
     scale.
   - The last layer is **great completion** (đại thành) of that technique.
6. **Slots.** A character has one main slot and `aux_slots` auxiliary slots (2).
   - The main slot takes a main method; auxiliary slots take secret arts or body
     techniques.
   - Capability #6 Twin Technique Cultivation (Meridian Map) adds a second main
     slot. Its method cultivates at 50 % speed with its full bonuses (Formulas A).
   - Slots can be changed at the start of any season, at no cost, except that a change
     which would end the life needs the confirmation of Realms rule 14 (rule 12). The technique
     you take out keeps its layers and its stored mastery (rule 7). A season's
     mastery and rate use the slots as set at its start.
   - The same technique cannot fill two slots.

**Mastery**

7. **Mastery per season.** Each slotted technique below great completion gains
   mastery each season (Formulas B).
   - The gain scales with effective Comprehension (ngộ tính). Comprehension also multiplies what a technique
     gives (rules 11 and 12).
   - The full rate applies in seasons spent cultivating (Time & Turn), and
     `mastery_idle_frac` of it (0.5) in other seasons.
   - When stored mastery reaches the next layer's cost, the layer is mastered, and
     the leftover carries over.
   - If the next layer needs a higher realm (rule 5), mastery stops accumulating at
     that cost. The layer is mastered at the start of the first season in the
     required realm.
   - Mastery is never lost: not by unslotting, by a failed breakthrough or by any
     other cost.
8. **A named id the root lacks.**
   - A technique is **usable** only if every element and variant it names is owned by the root, or has been raised
     by rare sources (Spiritual Roots rule 8a: Meridian roads, a Linh Căn Quả) to at least `tech_foreign_purity_min`
     (10, the birth minimum; user decision 2026-11-10, re-review D-1). Body techniques are always usable. Purity
     never falls, so a technique usable this way stays usable.
   - An unusable technique cannot be slotted.
   - If a root change makes a slotted technique unusable, it is unslotted at the
     start of the next season. No current root change removes an element or a
     variant (Spiritual Roots), so this is a guard only.
   - With no usable main method in the main slot, the cultivator cultivates crudely:
     the speed factor is `no_cong_phap_mult` (0.3) × the strongest base purity ÷ 100
     (Formulas A, as built). There is no technique power, and the main slot gains no
     mastery (auxiliary arts still do).

**What a technique gives**

9. **Speed.** Only the main method (and the #6 second main) gives speed. Its factor
   comes from:
   - the tier scale;
   - the average purity of the named ids (the Spiritual Roots contract, rule 8 there), read in full, past 100 too
     (user decision 2026-11-10, Spiritual Roots review D6). Purity a road granted in an element the root does not own
     counts here too once the technique is usable through it (rule 8; Spiritual Roots rule 8a, review D2). The ranges in Formulas A and D widen with it, and Realms re-checks its years table (its Open Question 23);
   - the mastered layer (Formulas A).

   This factor is the `tech` term of the Realms cultivation rate.
10. **The tier cap.** In a realm above the tier's maximum realm, the main method's
    speed factor is multiplied by `beyond_realm_mult` (0.25; Realms rule 13). Power,
    bonuses and abilities are unaffected. In practice this forces a change of main
    method at each tier's ceiling.
11. **Technique power.** The main method gives `tech_power` (Formulas C), which
    Character Stats multiplies into spiritual power (linh lực). Effective Comprehension
    multiplies it (Formulas F), but a main method never gives less than `no_tech_power`.
    With no main method, `tech_power` is `no_tech_power` (0.5) whatever the Comprehension.
    The #6 second main gives no technique power.
12. **Bonuses.** Every slotted, usable technique adds its bonuses through the
    Character Stats provider interface, with one source line per technique.
    - A bonus scales with the mastered layer (Formulas D).
    - Effective Comprehension multiplies every bonus. Body techniques take half the
      effect, in both directions (Formulas F).
    - `herb_growth_pct`, `alchemy_success` and `lifespan_years` count toward Character
      Stats' character-wide bonus curves and the alchemy dampen (its rule 14 and Formulas I, 2026-11-10), shared with
      the tree, items and pills, with diminishing returns instead of a stop.
    - Because bonuses count only while slotted, a slot or main-method change that would
      lower the lifespan cap to the character's age or below needs the player's
      confirmation, and a confirmed change kills (Realms rule 14; user decision
      2026-11-04, cross-GDD review NG4).
    - An auxiliary art's bonuses are also scaled by its harmony with the main
      method (Formulas D). Harmony is directional:
      - **the main method generates the art** (tương sinh, main → art): ×1.15;
      - **the art generates the main method** (art → main), or **the same
        element**: ×1.00 (neutral);
      - **either overcomes the other** (tương khắc): ×0.60.
    - Harmony is checked between each base element the art names and each element
      the main method names (a derived variant counts as its required elements; an innate
      variant and Primordial Chaos are neutral). With one or two (art element, main element) pairs the worst relation
      applies; with three or more pairs H is the **average** of their factors (user decision 2026-11-10, review D3), so
      wide arts and convergence mains are not always 0.60. Archived Blood and Void cannot be named by new templates.
    - Body techniques, and any art while the main slot is empty, are always
      neutral.
13. **Divine abilities.** An ability is **unlocked** while its technique is slotted
    and its `unlock_layer` is mastered. Unlocking makes its Combat art eligible for the loadout's art slots (one pool
    of `slot_count`, Combat rule 13); it is usable only once slotted.
    - Unslotting hides the ability; slotting the technique again restores it.
    - This GDD owns which abilities a technique carries and when they unlock.
      Combat owns what each ability does (design/gdd/combat.md).
14. **Combat.** Combat reads the unlocked abilities. `tech_power` reaches it only through
    spiritual power, which sizes the qi pool (Combat Formulas A), so there is no separate
    technique line. With no usable main method no ability is listed, and `no_tech_power`
    applies to spiritual power only.

**Hooks for other systems**

15. **Meridian seals: retired** (2026-11-10). The Meridian Map's sealed and hidden clusters were scrapped (user
    decision 2026-11-09) and its rule 7 retired with them, so techniques open nothing on the map and count no seasons
    for it. `seal_clusters`, `seal_seasons` (the Meridian Map's `cong_phap_seasons`) and the main-slot season counts
    are retired; old saves drop the counts on load. Công pháp and items may get their own side trees later
    (`design/research/side-trees-thoughts.md`); that is new design, not this rule.
16. **The starting technique.** Each life starts knowing one generated Yellow main
    method that names the strongest base element, at layer 1, in the main slot (as
    built; Concept onboarding).

**Content**

17. **Authored and generated.**
    - **Authored** templates are hand-written catalogue entries. All Earth and
      Heaven techniques are authored, as are all techniques naming a variant, all
      body techniques and every technique a world's history or a sect hands down.
      The target is about 40 (Concept); the MVP has a handful per kind.
    - **Generated commons** are Yellow and Profound main methods and secret arts,
      rolled from tier templates (Formulas E). They name 1 element, or 2 with chance
      `multi_element_chance`. Each draws its bonuses from `bonus_pool`. It has no
      abilities.
    - A common offered to the player (market stock, an event reward) draws each
      element from the player's root with chance `root_bias` (0.6). Without the
      bias a random 1-element technique fits a 1-element root only 1 time in 5.
    - An LLM-invented event can grant only a catalogue technique or a generated
      common within its event budget (Event Engine). It may give a generated common a
      flavour name, and nothing else.
18. **A next-tier source is always reachable.** Beyond its ceiling a main method runs
    at ×0.25 (rule 10), so a life without a next-tier technique stalls. Each world
    guarantees, for every realm from Core Formation up and for each of the five base
    elements, at least one reachable par-tier main method (Formulas A) that names
    only that element. Any root therefore has a next step.
    - "Reachable" means a sect library, a market stock or a quest reward in the
      starting province.
    - **The guaranteed copy is reserved.** NPCs never buy, take or learn from it, and
      no market restock removes it.
    - **If its source is lost** (the sect is destroyed or closed to the player, or the
      quest fails or expires), the same technique appears in a market stock in the
      starting province at the next season start, at its normal price (Formulas E),
      and stays there until bought. The World Database records the new location.
      (User decision 2026-11-04, cross-GDD review T2.)
    - World Generation, Sects & Missions and Market own where each one appears. This
      GDD owns the guarantee and the fallback.
19. **NPCs.** NPCs follow the same rules: same slots, layers and mastery. NPC Build
    Generation picks their techniques and sets their layers to fit their realm and
    age.

### States and Transitions

The state of one technique for one character:

| State | Meaning | Enters from | Leaves to |
|---|---|---|---|
| Unknown | Not learned | — | Known (read a manual, rule 4) |
| Known · unusable | Learned; a named id is neither owned nor at purity ≥ 10 | Unknown; any Slotted sub-state (root change, guard only) | Known · usable (the root gains the id, or its purity reaches 10) |
| Known · usable | Learned, can be slotted, not in a slot | Unknown; Known · unusable; Slotted (unslotted) | Slotted (at a season start) |
| Slotted | In the main, second-main or an auxiliary slot; gains mastery, gives its effects | Known · usable | Known · usable (unslotted); Known · unusable (root change); Gated; Great completion |
| Gated | Slotted, but the next layer needs a higher realm; mastery holds at that layer's cost | Slotted | Slotted (the realm is reached); Known · usable (unslotted); Known · unusable (root change) |
| Great completion | Slotted at the last layer; gains no more mastery | Slotted | Known · usable (unslotted; it stays at great completion); Known · unusable (root change) |

Layers and stored mastery belong to the character and the technique, and survive
every transition. Losing the manual item never unlearns a technique.

### Interactions with Other Systems

| System | Direction | Data | Owner |
|---|---|---|---|
| Spiritual Roots | in | the purity of each named element and variant; root changes that make a technique usable | Spiritual Roots |
| Realms & Bottlenecks | in / out | in: the current realm, for layer gates and the tier cap. Out: `tech`, the speed factor in the cultivation rate (Realms Formulas I); slot changes that Realms rule 14's lifespan confirmation covers | this GDD (the factor); Realms (the rate) |
| Character Stats | in / out | in: effective Comprehension (mastery, technique strength) and Physique (body techniques). Out: technique bonuses through the provider interface, and `tech_power` for spiritual power | this GDD (values); Character Stats (the interface) |
| Meridian Map | in / out | in: capability #6 (second main slot). Out: nothing since the seals were retired (rule 15) | Meridian Map |
| Time & Turn | in | whether the season was spent cultivating (full or idle mastery rate) | Time & Turn |
| Item DB | in / out | manuals as items pointing at templates; generated commons stored as records | Item DB (storage); this GDD (the record schema) |
| Combat | out | the unlocked divine abilities (Combat art records); `tech_power` through spiritual power | this GDD (which and when); Combat (effects) |
| Combat Defence & Healing | out | body techniques' block, body shield and Physical resistance at fixed tier sizes (rule 2) | Combat Defence (sizes); this GDD (tiers) |
| Combat Damage Types | out | each ability's art declares typed damage parts | Combat Damage Types |
| Modifier System | in | keys, tags, `more` on L2; the W budgets bonuses move to | Modifier System |
| Effects System | in | the Effects a technique hosts; enablers | Effects System |
| Market | out | manuals for sale, priced by tier (`value`) | Market |
| Event Engine / LLM GM | out | catalogue ids and generated commons that events may grant, within budget | Event Engine (budgets); this GDD (what may be granted) |
| NPC Build Generation | out | the same templates, slots and layer rules for NPCs | NPC Build Generation |
| World Generation & History / Sects | out | authored techniques placed in histories, ruins and sect libraries | those systems |

## Formulas

`systems-designer` proposed these formulas (lean mode, Section D). All the
arithmetic is by hand, rechecked by `qa-lead`; no bot run has confirmed it yet (AC-CP-46 to AC-CP-48). "Guess" values
are tuning starting points; "derived" values follow from a stated target.

Realm index *r*: QR = 1, FE = 2, CF = 3, NS = 4, DT = 5. Layer *k*: 1 to the tier's
`layers` (6 / 9 / 12 / 15).

### A. Speed factor

The tech_speed formula is defined as:

`tech_one = (κ ÷ g) · edge · match · L · beyond`
`tech = max(tech_one(main), crude) + f2 · tech_one(second)` (the second term only with capability #6)
`tech = crude = no_cong_phap_mult · strongest_purity / 100` (no usable main method; rule 8)

The **crude floor**: a slotted main method never gives less than crude cultivation
would. Slotting a method is therefore never worse than leaving the slot empty; when
the floor applies, the breakdown line says so ("crude floor").

with
- `cap(r) = min(3r, layers)`: the highest layer the realm allows;
- `d = max(0, cap(r) − k)`: layers the realm allows but not yet mastered;
- `L = max(L_floor, 1 − δ · d)`;
- `edge = S[tier] / S[par(r)]` if r ≤ the tier's max realm, else 1;
- `beyond = beyond_realm_mult` (0.25) if r > the tier's max realm, else 1;
- `match = avg_purity(names) / 100` (Spiritual Roots rule 8);
- `g = count_gain[n_base]`, the **element-count gain**: 1.00 / 1.22 / 1.33 / 1.41 /
  1.46 for 1–5 base elements, and 1.27 for five elements in QR.

The **par tier** `par(r)` is the lowest tier whose max realm is at or above *r*:
Yellow for QR and FE, Profound for CF, Earth for NS and Heaven for DT. For a single
root, a par-tier technique with match 0.5 and every allowed layer mastered gives
exactly 1.0 in every realm, which is the value the Realms years table assumes.

**The element-count gain** (user decision 2026-11-04, cross-GDD review N6). A player
picks a technique naming the root's strongest element, and the strongest of *n*
elements has a higher purity than a single root's one element: 61.2 / 66.8 / 70.4 /
73.1 against 50.1 for 2–5 elements, exact over the Spiritual Roots purity roll. `g`
is that ratio, so a par-tier technique naming the strongest element gives 1.0 on
average for every element count, and the Realms years table holds for all tiers. It
is applied per element count, not through κ or Realms `climb_total`, because either
of those would also slow single roots, which already sit near their Nascent Soul and
Deity Transformation ceilings. Five elements in QR use 1.27 instead of 1.46, so that
at most about 6 % of five-element lives spend more than half of QR's lifespan there
(AC-CP-47); the full 1.46 would put about 19 % there. A technique naming a weaker
element, or several elements, still gives less, as before.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| r | int | 1–5 | calculated | Current realm index |
| k | int | 1–15 | calculated | Highest mastered layer of this technique |
| layers | int | 6 / 9 / 12 / 15 | data file | Ladder length by tier (rule 5) |
| d | int | 0–14 | calculated | Allowed but unmastered layers |
| δ (`layer_speed_penalty`) | float | 0.06 (guess; safe 0.04–0.10) | data file | Speed lost per unmastered allowed layer |
| L_floor (`layer_speed_floor`) | float | 0.70 (guess; safe 0.5–0.8) | data file | Lower bound of L; reached at d = 5 with the defaults |
| S[tier] (`speed_mult`) | float | 1.00 / 1.15 / 1.30 / 1.45 (guess; edge per tier 1.10–1.25) | data file | Tier speed scale (**changed** from 1.0 / 1.3 / 1.7 / 2.2; power is now separate, Formulas C) |
| κ (`tech_norm`) | float | 2.0 (derived: 1 ÷ typical match 0.5; safe 1.8–2.2) | data file | Normaliser |
| g (`count_gain`) | float | 1.00 / 1.22 / 1.33 / 1.41 / 1.46 by base element count; 1.27 for five elements in QR (derived; see above) | data file | Element-count gain divided out of κ |
| match | float | 0.08 and up (0.08: a derived variant at its purity floor of 8; above 1.0 past purity 100) | calculated (Spiritual Roots) | Average purity of the named ids ÷ 100, uncapped |
| beyond_realm_mult | float | 0.25 | data file (value from Realms rule 13) | Tier cap |
| f2 (`second_main_mult`) | float | 0.5 | data file (value from Meridian Map #6) | Second main method's speed share |
| no_cong_phap_mult | float | 0.3 (as built) | data file | Crude cultivation multiplier |
| strongest_purity | int | 10 and up | calculated (Spiritual Roots) | Highest base-element purity (uncapped) |
| tech | float | 0.03 and up: 2.9 for the main slot at purity 100, 4.35 with #6; higher past purity 100 | calculated | The `tech` term of Realms Formulas I |

**Output Range:**
- The main slot runs from 0.03 (crude at strongest purity 10, or the crude floor) to
  2.9 (a Heaven technique in QR or FE at match 1.0, which is vanishingly rare). Before
  the floor, one technique can be as low as 0.028 (beyond its realm at match 0.08 and
  L 0.70).
- Under normal play a technique gives 0.8–1.4.
- κ is not applied to the crude branch: crude is 0.03–0.30. A beyond-realm main
  method at match 0.5 gives about 0.25, which the crude floor lifts for any root whose
  strongest purity is above 83. So past a tier ceiling, the main method's speed is
  close to nothing, and the push to switch is real.
- The #6 second term has no floor.
- tech is never negative.

**Example:** a Profound technique naming Wood 40 and Fire 86 has match 0.63. The
root {Wood 40, Fire 86} has two base elements, so g = 1.22.
- **CF, layer 8:** cap = 9, d = 1, L = 0.94 and edge = 1, so tech = 2 ÷ 1.22 × 1 ×
  0.63 × 0.94 = **0.97**.
- **Same technique at NS:** it is beyond its realm, so 2 ÷ 1.22 × 0.63 × 0.94 × 0.25
  = 0.243, below crude (0.3 × 0.86 = 0.258), so the crude floor gives **0.258**.
- **With #6:** a Yellow Wood technique at FE (match 0.40, layer 6) in the second slot
  adds 0.5 × 2 ÷ 1.22 × 0.40 = 0.33.
- With `g` pinned to 1.0, as in the default test fixture, the same three give 1.18,
  0.30 and 0.40 (AC-CP-14, AC-CP-17).

**Check: the technique a typical life holds gives about 1.0.** This assumes a
3-element root, Comprehension 45, and a forced switch to the next par tier at each
tier ceiling, with mastery costs from Formulas B.

| Realm | Technique | Share of the realm spent ramping | Mean L over the realm | tech at match 0.5 |
|---|---|---|---|---|
| QR | Yellow starter | 20 % | 0.98 | 0.98 |
| FE | the same Yellow | 22 % | 0.98 | 0.98 |
| CF | a fresh Profound | 52 % | 0.92 | 0.92 |
| NS | a fresh Earth | 54 % | 0.91 | 0.91 |
| DT | a fresh Heaven | 55 % | 0.91 | 0.91 |

- The result is 0.91–0.98 at match 0.5, within 10 % of the Realms assumption.
- **Multi-element roots** (`qa-lead`): the starter names the strongest element, which
  averages purity 67 for a 3-element root. Without `g`, raw tech would be about 1.31
  in QR and FE and 1.22–1.24 later, and such lives would clear realms about 24 %
  faster than the Realms years table. `g` (1.33 for three elements) divides that
  out, so raw tech is about 0.98 in QR and FE and 0.92 later. κ stays 2.0.
- Across all roots the starter's mean match is 0.58 (derived, weighted by the count
  weights), +16 % on raw match; `g` divides that out too.
- **The QR half-lifespan ceiling:**
  - **Five-element roots.** The starter match is about 0.73, so with `g` 1.27 tech ≈
    2.0 ÷ 1.27 × 0.73 × 0.98 ≈ 1.13. A five-element root always holds all five
    generating pairs (+15 %), so QR takes about 50 ÷ 1.13 ≈ 44 years against the
    60-year ceiling (the Spiritual Roots table's 50 years assumes tech 1.0). A
    five-element life breaches the ceiling if its strongest purity is 53 or less,
    which happens about 6 % of the time.
  - **One-element roots.** The QR figure is 25 years at tech 1.0. The ceiling
    breaks below tech 0.42 (purity 21 or less), about 8 % of one-element lives.
  - The Realms check is on the median, which holds. A match floor would close the
    tail but would change the Spiritual Roots contract, so it is not proposed.

### B. Mastery

The mastery formula is defined as:

`gain = g0 · (1 + comp / D_m) · act · slot_frac`
`cost(k) = C[⌈k/3⌉] · w[j] · T[tier] · (catchup if ⌈k/3⌉ < r, else 1)`, with `j = ((k − 1) mod 3) + 1`

Each season, every slotted technique below great completion adds `gain` to its
stored mastery.
- **Next layer not gated:** while stored ≥ cost(k + 1), the layer is mastered and the
  cost is subtracted. Several layers can be mastered in one season.
- **Next layer gated** (it needs a higher realm, rule 5): stored = min(stored + gain,
  cost(k + 1)). Any excess is lost.
- **Layer 1** is mastered on learning (rule 4), so its cost is never paid.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| g0 (`mastery_base`) | float | 1.0 (guess; safe 0.7–1.5) | data file | Points per season |
| comp | float | 1–150 | calculated (Character Stats) | Effective Comprehension |
| D_m (`mastery_comp_divisor`) | float | 100 (guess; safe 60–200) | data file | ×1.45 at Comprehension 45, ×2.5 at 150 |
| act | float | 1.0 or `mastery_idle_frac` 0.5 | data file | 1.0 in a season spent cultivating (Time & Turn) |
| slot_frac (`second_main_mastery`) | float | 1.0 (guess; safe 0.5–1.0) | data file | Mastery rate in the #6 slot; every other slot is 1.0 |
| C[realm] (`trio_cost`) | float | 60 / 84 / 118 / 165 / 231 (guess; ±30 %) | data file | Cost of one realm's three layers, ×1.4 per realm |
| w[j] (`layer_weights`) | float | 0.25 / 0.33 / 0.42 (guess; must sum to 1) | data file | Share of the trio paid by the realm's 1st, 2nd and 3rd layer |
| T[tier] (`layer_cost_mult`) | float | 1.0 / 1.2 / 1.4 / 1.6 (guess; safe 1.0–2.0) | data file | Tier cost multiplier |
| catchup (`catchup_mult`) | float | 0.25 (guess; safe 0.1–0.5) | data file | Discount on layers belonging to realms below the current one |
| gain | float | 0.5–2.5 per season | calculated | Mastery added |
| cost(k) | float | 4.95–155 (paid layers) | calculated | Points to master layer k |

**Output Range:**
- Gain is 0.5 to 2.5 per season: Comprehension 1 idle gives 0.5, Comprehension 150
  cultivating gives 2.5.
- A paid layer costs from 4.95 (Yellow layer 2 at the catch-up price; layer 1's cost
  is never paid) to about 155 (Heaven layer 15).

**Pacing** (3-element root, Comprehension 45 so gain 1.45, all seasons
cultivating). Realm lengths are the Realms years table, 38 / 50 / 60 / 101 / 168
years, at 4 seasons per year (152 / 200 / 240 / 404 / 672 seasons).

| Realm | Yellow trio | Share of the realm | Par-tier trio | Share of the realm |
|---|---|---|---|---|
| QR (layers 2–3 only) | 31 seasons | 20 % | — | — |
| FE | 43 (layers 5–6; layer 4 is pre-paid during the QR gate hold) | 22 % | — | — |
| CF | — | — | 98 (Profound) | 41 % |
| NS | — | — | 159 (Earth) | 39 % |
| DT | — | — | 255 (Heaven) | 38 % |

- A fresh technique also has to clear its lower-realm layers at the catch-up price:
  27 seasons for Profound at CF, 60 for Earth at NS and 114 for Heaven at DT. Those
  are included in the Formulas A check.
- If only 75 % of seasons are spent cultivating, elapsed time is about 1.14 times
  longer (guess).
- Five-element roots spend about 72 % of NS and 89 % of DT ramping once the catch-up
  layers are counted, because those realms are short for them. Their mean L is about
  0.89 and 0.85, which their higher match offsets; the loss is bounded by the L floor.

**Example:** an Earth technique at NS, layer 11 (k = 11, so ⌈11/3⌉ = 4 and j = 2):
cost = 165 × 0.33 × 1.4 = **76.2** points, which is about 52.6 seasons at gain 1.45.
Bought after the cultivator reaches DT, the same layer costs 76.23 × 0.25 = **19.06**.

### C. Technique power

The tech_power formula is defined as:

`tech_power = max(no_tech_power, power_mult[tier] · (p_floor + (1 − p_floor) · (k − 1) / (layers − 1)) · comp_strength)` (a main method in the main slot)
`tech_power = no_tech_power` (no usable main method)

Power measures how far into its own ladder the technique is; speed (Formulas A)
measures depth relative to the realm.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| power_mult | float | 1.0 / 1.3 / 1.7 / 2.2 (as built) | data file | Tier power scale |
| p_floor (`power_layer_floor`) | float | 0.6 (guess; safe 0.4–0.8) | data file | Share of the power at layer 1 |
| k, layers | int | as in A | calculated, data file | Mastered layer; ladder length |
| no_tech_power | float | 0.5 (guess) | data file | Spiritual power factor with no main method (as built it was 1.0); also the floor under a main method |
| comp_strength | float | 0.78–1.525 | calculated (Formulas F) | Effective Comprehension's multiplier |
| tech_power | float | 0.5–3.355 | calculated | Read by Character Stats (spiritual power), which sizes Combat's qi pool (rule 14) |

**Output Range:** 0.5 (no main method) to 3.355 (a Heaven technique at great
completion, Comprehension 150). At Comprehension 45 a Heaven technique tops out at 2.2
and a Yellow technique at layer 1 gives 0.6. The floor binds a Yellow layer 1 below
Comprehension 12, where the product would be under 0.5, so learning a method never
lowers spiritual power. Character Stats' range is 0.5–3.355 (cross-GDD edit, user decision).

**Example** (Comprehension 45, so `comp_strength` is 1): an Earth technique at layer 9 of 12
gives 0.6 + 0.4 × 8/11 = 0.8909, so tech_power = 1.7 × 0.8909 = **1.51**. A Heaven technique found in QR, at layer 3,
gives 2.2 × (0.6 + 0.4 × 2/14) = **1.45**, against 0.76 for a Yellow technique at
layer 3.

### D. Bonuses

The technique_bonus formula is defined as:

`v = v_full · B(k) · F · H · comp_strength`, where `B(k) = b_floor + (1 − b_floor) · (k − 1) / (layers − 1)` and:
- `F = 0.5 + avg_purity(names) / 100` for a main method or a secret art;
- `F = min(F_cap, 0.5 + physique / 100)` for a body technique;
- `H` = the harmony factor (rule 12) for an auxiliary art; 1.0 for the main method.

H is the worst relation over the pairs (art element, main element) when there are one or two pairs, and their
average when there are three or more (review D3), with a derived variant counted as its required elements and an
innate variant or Primordial Chaos neutral. The generating cycle is Wood → Fire → Earth
→ Metal → Water → Wood (`character_elements.json` `cycle`). The overcoming relation
is Wood–Earth, Earth–Water, Water–Fire, Fire–Metal and Metal–Wood.

| Relation of art element *a* to main element *m* | H |
|---|---|
| *m* generates *a* | 1.15 |
| *a* generates *m*, or *a* = *m* | 1.00 |
| *a* overcomes *m*, or *m* overcomes *a* | 0.60 |
| body technique, or an empty main slot | 1.00 |

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| v_full | float | per bonus (`bonus_pool` min–max, or authored) | data file | Value at great completion, before F and H |
| b_floor (`bonus_layer_floor`) | float | 0.3 (guess; safe 0.2–0.5) | data file | Share of the bonus at layer 1 |
| avg_purity | float | 8 and up (uncapped) | calculated (Spiritual Roots) | As in A, but in the Meridian Map's 0.5 + purity ÷ 100 form |
| physique | float | 1–150 | calculated (Character Stats) | Effective Physique (căn cốt) |
| F_cap (`body_factor_cap`) | float | 1.5 (guess; safe 1.2–1.5) | data file | Cap on the body-technique factor |
| H (`harmony`) | float | 0.60–1.15 (one of 0.60 / 1.00 / 1.15, or an average of them) | data file | Harmony multiplier |
| comp_strength | float | 0.78–1.525 (body techniques 0.89–1.2625) | calculated (Formulas F) | Effective Comprehension's multiplier; a body technique uses `body_comp_strength` |
| v | float | 0 to about 2.63 × v_full at purity 100; more past it | calculated | Bonus delivered; one provider line per technique |

**Output Range:**
- F is 0.58 and up in the purity form (1.5 at purity 100, 2.0 at 150; uncapped) and 0.51–1.5 in the Physique form;
  H is 0.60–1.15.
- So v runs from 0.3 × 0.58 × 0.6 × 0.78 ≈ 0.08 × v_full (layer 1, low purity, overcoming,
  Comprehension 1) up to 1.5 × 1.15 × 1.525 ≈ 2.63 × v_full (great completion, purity 100,
  generated by the main method, Comprehension 150).
- The bonus budget reads `v_full`, so it is unchanged; past purity 100 `v` keeps rising, and for herb growth,
  alchemy and lifespan Character Stats' curves give diminishing returns on what `v` delivers.

**Example** (Comprehension 45, so `comp_strength` is 1):
- **A Profound secret art** with attack_pct 12, at layer 6 of 9, average purity 70.
  The main method is Water, and the art is Wood (Water generates Wood):
  - B = 0.3 + 0.7 × 5/8 = 0.7375, F = 1.2 and H = 1.15;
  - v = 12 × 0.7375 × 1.2 × 1.15 = **12.2 %**.
  - Under a Metal main method (Metal overcomes Wood), H = 0.60 and v = 6.37 %, stored
    as **6.3 %** (floored to the 0.1 grid; the first case stores 12.2).
- **A body technique** with Physique 60 has F = 1.1.

**Bonus budget.** A template's bonuses must fit its tier:

`Σ v_full / pool_max(stat) ≤ bonus_budget[tier]`, and each `v_full ≤ bonus_single_cap · pool_max(stat)`

| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| pool_max(stat) | float | per stat | data file (`bonus_pool` max) | Reference size of one bonus; every stat a template uses needs a `bonus_pool` row (`authored_only: true` keeps it out of commons) |
| bonus_budget | float | 1.0 / 2.0 / 3.0 / 4.0 (guess; safe ±25 %) | data file (per tier) | Total bonus size a tier may carry |
| bonus_single_cap | float | 1.5 (guess; safe 1.2–2.0) | data file | Largest single bonus, in pool maxima |

- Generated commons always fit: a Profound secret art has at most 2 bonuses at pool
  maximum, 2.0 against a budget of 2.0.
- Divine abilities do not count against the budget; Combat owns their weight (Open
  Question 3).
- The data validator rejects a template over budget (Edge Cases).

**Example:** an Earth secret art with attack_pct 20 (pool max 15, so 1.33) and
linh_luc_pct 20 (pool max 20, so 1.0) uses 2.33 of its 3.0 budget, so it is valid.
attack_pct 25 would be 1.67, above the 1.5 single cap, so it is rejected.

### E. Generated commons

The common_roll formula is defined as:

`tier ~ weights[Yellow, Profound]` when the source does not fix the tier;
`n_elements = 2 with chance multi_element_chance, else 1`;
`each element ~ the root's not-yet-drawn base elements (uniform among them) with chance root_bias (player offers only), else uniform over the not-yet-drawn elements`; if the root has none left, the draw is uniform;
`n_bonuses = bonus_count[tier] + (secret_art_bonus_extra if a secret art)`;
`price = value[tier] · (price_base + price_spread · q̄)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| weights | int | 50 / 30 (as built; renormalised to 62.5 % / 37.5 %) | data file | Tier weights; the Earth and Heaven weights (15 / 5) apply to authored loot only |
| multi_element_chance | float | 0.2 (as built; safe 0.1–0.3) | data file | Chance of a 2-element common |
| multi_element_count | int | [2, 2] (**changed** from [2, 3]) | data file | Commons name at most 2 elements (rule 17) |
| root_bias | float | 0.6 (guess; safe 0.4–0.8) | data file | Chance each element of a player offer comes from the player's root |
| bonus_count | int | 0 / 1 (Yellow / Profound, as built) | data file | Bonuses on a main method |
| secret_art_bonus_extra | int | 1 (guess) | data file | Extra bonuses on a secret art, which has no speed |
| bonus value | float | `bonus_pool` [min, max], uniform, rounded to 0.1 | data file | v_full of each bonus; stats drawn without replacement |
| value | int | 30 / 200 / 1,500 / 12,000 (as built) | data file | Tier price base |
| q̄ | float | 0–1 (0.5 with no bonuses) | calculated | Mean of clamp((v_full − min) ÷ (max − min), 0, 1) over the bonuses |
| price_base, price_spread | float | 0.85, 0.30 (guess; band ±10–25 %) | data file | Price band |
| price | int | 0.85–1.15 × value, rounded to the nearest integer (half away from zero) | calculated | Item value of a generated common; Market applies its own buy and sell rounding |

**Output Range:** Yellow commons cost 26–35 and Profound commons 170–230. The price
formula applies to generated commons only. An authored manual sits at its tier's data
`value` (as built): 200 Profound, 1,500 Earth and 12,000 Heaven. Market owns the final
bands.

**Example:**
- **Price.** A Profound main method with linh_luc_pct 15 (pool 5–20) has q̄ = 0.667,
  so price = 200 × (0.85 + 0.30 × 0.667) = **210**.
- **Root bias.** For a Fire-only root, a 1-element player offer is Fire with chance
  0.6 + 0.4 × 1/5 = **0.68**, instead of 0.20 unbiased.

### F. Comprehension strength

The comp_strength formula is defined as:

`comp_strength = 1 + (ngo_tinh_eff − strength_comp_mean) ÷ strength_comp_divisor`
`body_comp_strength = 1 + (comp_strength − 1) · strength_comp_body_share`

Effective Comprehension (ngộ tính) multiplies `tech_power` (Formulas C) and every bonus (Formulas D): how well the
cultivator understands a technique decides how much of it they can use. At the average roll a technique gives what it
says; below that it gives less. A body technique rests on the body more than on understanding, so its bonuses use
`body_comp_strength`, the same effect at a share. User decisions 2026-11-06. This is not Character Stats' `comp`, which is never below 1.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| ngo_tinh_eff | float | 1–150 | calculated (Character Stats Formulas B) | Effective Comprehension |
| strength_comp_mean | float | 45 | data file | The Comprehension where a technique gives its written value; the talent roll's mean |
| strength_comp_divisor | float | 200 (guess; safe 100–400) | data file | Points of Comprehension per +1.0 |
| strength_comp_body_share | float | 0.5 (guess; safe 0–1) | data file | The share of the effect a body technique takes |
| comp_strength | float | 0.78–1.525 | calculated | The multiplier for main methods and secret arts |
| body_comp_strength | float | 0.89–1.2625 | calculated | The multiplier for body techniques |

**Output Range:** `comp_strength` is 0.78 at Comprehension 1, 1.00 at 45, 1.275 at 100 and 1.525 at the clamp of 150.
`body_comp_strength` is 0.89, 1.00, 1.1375 and 1.2625 at the same points.

**Example:** an Earth technique at layer 9 of 12 has 1.5145 before this factor. At Comprehension 100,
`tech_power` = 1.5145 × 1.275 = **1.93**; at 20 it is 1.5145 × 0.875 = **1.33**.

### Parameter keys

**`items_cong_phap.json`, per tier:**
- `rank`;
- `speed_mult` 1.00 / 1.15 / 1.30 / 1.45 (**changed**);
- `power_mult` 1.0 / 1.3 / 1.7 / 2.2;
- `max_realm` and `layers` 6 / 9 / 12 / 15 (new);
- `layer_cost_mult` 1.0 / 1.2 / 1.4 / 1.6 (new);
- `bonus_count`, `value` and `weight`;
- `bonus_budget` 1.0 / 2.0 / 3.0 / 4.0 (new);
- `seal_seasons`: retired 2026-11-10 (rule 15).

**`items_cong_phap.json`, global:**
- slots and speed: `aux_slots` 2, `second_main_capability` 6, `tech_norm` 2.0, `count_gain` [1.00, 1.22, 1.33,
  1.41, 1.46] by base element count with `count_gain_qr_5` 1.27 (new),
  `layer_speed_penalty` 0.06,
  `layer_speed_floor` 0.70, `beyond_realm_mult` 0.25, `second_main_mult` 0.5;
- mastery: `mastery_base` 1.0, `mastery_comp_divisor` 100, `mastery_idle_frac` 0.5,
  `second_main_mastery` 1.0, `trio_cost` [60, 84, 118, 165, 231], `layer_weights`
  [0.25, 0.33, 0.42], `catchup_mult` 0.25;
- power and bonuses: `power_layer_floor` 0.6, `no_tech_power` 0.5,
  `strength_comp_mean` 45, `strength_comp_divisor` 200, `strength_comp_body_share` 0.5 (new),
  `bonus_layer_floor` 0.3, `body_factor_cap` 1.5, `bonus_single_cap` 1.5 (new),
  `harmony` {`main_generates` 1.15,
  `neutral` 1.00, `overcoming` 0.60};
- commons: `commons_tiers` [0, 1], `multi_element_chance` 0.2,
  `multi_element_count` [2, 2], `root_bias` 0.6, `secret_art_bonus_extra` 1,
  `price_base` 0.85, `price_spread` 0.30, and `element_prefixes`, `suffixes` and
  `bonus_pool` (as built; rows may carry `authored_only: true`);
- the authored catalogue: `templates` [ … ] (rule 1).

**Other files:**
- `cultivation_realms.json`: `no_cong_phap_mult` 0.3 stays there (as built).
- `character_elements.json`: `cycle` (read only).

## Edge Cases

This section was drafted without `systems-designer` (lean mode). Several design and cross-GDD reviews have checked it, but no specialist pass has.

**Comprehension**
- **If Comprehension is so low that a method's power falls under `no_tech_power`:** the power is
  `no_tech_power`, so a method is never worse than none.
- **If effective Comprehension changes (a perk, a tree node, an event):** power and bonuses follow at the next
  sheet build. Layers and mastery do not change.
- **If a technique or artifact ever gives Comprehension:** no pool row or affix does today. Bonuses read Comprehension
  before technique and artifact bonuses are added, so a technique cannot multiply itself; `tech_power` reads the
  finished total. Decide this before authoring one.

**Slots and usability**
- **If the main slot is empty but auxiliary arts are slotted:** cultivation is crude
  (rule 8) and `tech_power` is `no_tech_power`. The arts still give their bonuses and
  gain mastery, with harmony 1.00.
- **If the #6 second slot holds a method while the main slot is empty or unusable:**
  the second slot is inert. It gives no speed, bonuses or mastery until the main
  slot holds a usable method. Moving the method into the main slot is the intended
  play, and the move empties the #6 slot (rule 6). While the main slot holds a usable
  method, a method in the #6 slot cannot also go there.
- **If capability #6 is lost:** the second slot is emptied at the next season start.
  The method keeps its layers and stored mastery.
- **If the player tries to slot the same technique twice, or a main method in an
  auxiliary slot:** the action is refused with a reason line (rules 2 and 6).
- **If a root gains an element or a variant** (a Linh Căn Quả, a Mutation
  Awakening): every known technique that becomes usable moves to Known · usable at
  the next season start. Nothing is auto-slotted.
- **If a derived variant's purity changes because a required element changed** (Spiritual
  Roots rule 10): match and F for techniques naming it update at the next season start.
- **If the strongest base elements tie when the starting technique is chosen:** the
  first of the tied elements in `cycle` order is used.

**Layers and mastery**
- **If one season's gain is enough for several layers:** every affordable ungated
  layer is mastered in that season, in order.
- **If the next layer is gated:** stored mastery stops at that layer's cost. The
  surplus is lost, and the layer is mastered at the start of the first season in
  the required realm.
- **If a technique is at great completion:** it gains no mastery and stores none.
- **If the realm were ever lowered:** no current rule lowers a realm (Realms stage
  loss stays inside the realm). If one ever did, mastered layers would be kept,
  with d = max(0, cap(r) − k) = 0. The layers still count for power and bonuses.
- **If Comprehension changes during a season:** the season's gain uses its value at
  the season start.
- **If stored mastery equals a cost to within 1e-6:** the layer is mastered. Stored
  mastery is a float compared with the Character Stats tolerance rule (Formulas I
  there).

**Speed, power and bonuses**
- **If the main method is beyond its realm:** speed is ×0.25. Power, bonuses
  and abilities are unaffected. All its layers are allowed (cap(r) =
  layers), though not necessarily mastered.
- **If an auxiliary art is beyond its tier's max realm:** nothing changes. The tier
  cap applies to main-method speed only.
- **If an art names two elements, one harmonious and one overcoming against the main
  method:** the worst relation applies (two pairs), so H = 0.60.
- **If an art and its main make three or more pairs** (a two-element art under a Thunder or Darkness main): H is
  the average of the pairs' factors; [Wood, Water] under a Thunder main is (1.00 + 0.60 + 0.60 + 1.15) ÷ 4 = 0.84.
- **If adding an element raises H:** under a Thunder main a [Wood] art gives 0.60 (two pairs, the worst) but a
  [Wood, Water] art 0.84 (four pairs, averaged). This is intended (user decision 2026-11-10, re-review D-4): wide
  arts are allowed to harmonise better.
- **If the main method or an art is Primordial Chaos:** it is neutral (H 1.00), like an innate variant.
- **If purity passes 100:** speed and bonuses read it in full (rule 9); `tech_power` does not read purity.
- **If a 1-element root receives a 2-element player offer:** both draws are biased
  towards root elements not yet drawn. If the first lands on the root's element, the
  second is uniform over the other four, because none is left to bias towards. If
  the first misses, the second is biased towards the root's element.
- **If a technique in the #6 slot is beyond its own realm:** its speed term carries
  its own ×0.25, independently of the main method.
- **If a bonus would land between precision steps:** it is floored to the Character
  Stats precision grid, with the 1e-6 tolerance.

**Items and economy**
- **If a learned manual is sold:** the seller keeps the technique. The buyer can
  learn it. Buying and reselling cannot profit, because Market buy prices round up
  and sell prices round down (Character Stats Formulas H). Market must keep a
  manual's sell price below its buy price.
- **If the same technique is learned again from a second manual:** nothing happens.
  The second manual is still an item that can be sold.
- **If a character dies** (player or NPC): their known list, layers and stored
  mastery end with the life; carry-over is the Codex's (Open Question 7). Manuals
  they held are ordinary items and follow the Item DB and World Database rules for a
  dead character's belongings: looted, inherited by their sect, or left where they
  died. A technique they knew without holding its manual leaves no manual. World
  Generation may record it as a lost technique, a Discovery hook (Concept).
- **If a manual is lost, stolen or destroyed:** the technique stays known (States
  table).
- **If no par-tier technique for the root's elements has been found when a tier
  ceiling is reached:** this cannot happen under rule 18 for a base element, because
  the guaranteed copy is reserved and, if its source is lost, reappears in a market
  stock the next season. The player may still not have bought it yet; the
  breakthrough preview then warns (UI Requirements). It can happen for an authored
  variant technique. The life then switches to a base-element
  par method and pays the ramp.

**Content validation (load-time errors)**
- **If a template's `unlock_layer` is above its `layers`, its `layers` does not match
  its tier, it names more than 3 ids, a `names` id is not a base element or catalogue
  variant, a body technique names any id, a main method or secret art names none,
  a generated common is above Profound, a bonus stat has no `bonus_pool` row, or the
  bonuses exceed the tier's bonus budget or the single-bonus cap (Formulas D):** the
  data validator rejects the file at load. The game
  does not start on a bad catalogue.
- **If an LLM-invented event names a technique id that is not in the catalogue, or
  asks for a generated common above its event budget:** the Event Engine validator
  rejects that effect. The rest of the event still resolves.
- **If an LLM-invented technique effect supplies fields other than a flavour name**
  (tier, names, bonuses): those fields are stripped and logged, and the effect
  applies with the catalogue or rolled values.

## Dependencies

**Upstream:**

| # | System | What Cultivation Techniques needs from it |
|---|---|---|
| 1 | Data-Driven Config | `items_cong_phap.json` (tiers, templates, globals), `cultivation_realms.json` (`no_cong_phap_mult`), `character_elements.json` (`cycle`) |
| 2 | Deterministic Simulation Core | The seeded RNG for generated commons |
| 6 | Spiritual Roots | Purity of each named element and variant; the base elements (usability, starting technique, root bias); derived variants' required elements (harmony) |
| 8 | Realms & Bottlenecks | The current realm, for layer gates, the par tier and the tier cap |
| 7 | Character Stats | Effective Comprehension (mastery) and Physique (body techniques); the precision grid and tolerance rule |
| 13 | Item DB | Manuals as items that point at templates; storage for generated commons |

**Upstream, soft (needed for a part of the system):**

| # | System | What it supplies | Without it |
|---|---|---|---|
| 4 | Time & Turn | Whether a season was spent cultivating | Every season counts at the full rate |
| 10 | Meridian Map | Capability #6 (second main slot) | No second slot |

**Downstream:**

| # | System | What it takes |
|---|---|---|
| 8 | Realms & Bottlenecks | `tech`, the speed factor in the cultivation rate (Formulas A) |
| 7 | Character Stats | Technique bonuses through the provider interface; `tech_power` for spiritual power |
| 10 | Meridian Map | Capability #6 (second main slot); the seals are retired (rule 15) |
| 21 | Combat | The unlocked divine abilities; `tech_power` through spiritual power |
| 21a | Combat Defence & Healing | Body techniques' block, body shield and resistance (rule 2) |
| 21b | Combat Damage Types | Typed damage parts on each ability's art |
| 20 | Market | Manuals for sale; commons with root bias; prices from Formulas E; the rule 18 reserved copy and its fallback stock |
| 23, 29 | Event Engine, LLM GM | The catalogue and the commons an event may grant; validation of technique effects |
| 24 | NPC Build Generation | Templates, slots and layer rules for NPCs |
| 39 | The Way (Đạo) | Daos that may name a technique kind and tier as a requirement (`dao.md` rule 5); an open question on relocated mutation ids is closed (OQ 11) |
| 26, 27 | Sects & Missions, World Generation & History | Authored techniques to place; the next-tier guarantee (rule 18) |
| 3 | World Database | Known techniques, layers and stored mastery per character |
| 12 | Codex & Karmic Carryover | Techniques discovered across lives (if that system chooses to keep them) |
| 33 | Balance Simulation Harness | The factor and mastery rules, for AC-CP-46 to AC-CP-48 |
| 35–37 | Guidance Layer, Debug Terminal, Game UI | The technique display and slot actions |
| 5 | Save/Load | The known list, layers, stored mastery and slots |

**Cycles and how they are broken:**
- **Cultivation Techniques ↔ Realms.** This one is already in the systems index.
  Realms owns the realm ladder as data, and this system reads it. Realms reads
  `tech` through the rate formula and never calls this system's rules.
- **Cultivation Techniques ↔ Character Stats.** This system reads effective
  Comprehension and Physique, and supplies bonuses through the provider interface.
  The cycle is broken in time: mastery and the body-technique factor read the
  values at the season start, and bonuses apply to the sheet built for that
  season. A technique bonus that raised Comprehension would therefore affect
  mastery from the following season.
- **Cultivation Techniques ↔ Meridian Map.** The Meridian Map supplies #6 through the capability set in
  Character Stats (the capability-host rule); since the seals were retired (rule 15) nothing flows back.

**Bidirectionality.** The related GDDs list this system: Spiritual Roots, Character Stats, Realms, the Meridian Map,
Combat, Combat Defence & Healing, Combat Damage Types, the Modifier and Effects Systems, the Way and Item DB.

**Combat sub-systems (back-references added by the Combat revision #43, 2026-11-08).** This system and the four
systems split out of Combat depend on each other as follows.

- **Combat Defence & Healing (#21a):** body techniques (luyện thể) grant block, body shield and resistance (its rule 12, Formulas H: Iron Body Art tiers); ward spells and heal arts are technique content.
- **Combat Damage Types (#21b):** every art a technique unlocks declares its damage parts and types.
- **Modifier System (#40):** technique modifiers come from its catalogue, including `more` on L2.
- **Effects System (#41):** technique and art Effects are its records.

## Tuning Knobs

All keys are in `items_cong_phap.json` unless noted.

| Knob | Value | Safe range | What it moves |
|---|---|---|---|
| `tech_norm` (κ) | 2.0 | 1.8–2.2; *derived* as 1 ÷ the typical match 0.5 | Every technique's speed. It is tied to Spiritual Roots' `purity_mean` 50: if that moves, κ must follow, or the Realms years table drifts |
| `count_gain`, `count_gain_qr_5` | 1.00 / 1.22 / 1.33 / 1.41 / 1.46; 1.27 | *derived* each as the expected strongest purity of an n-element root ÷ 50 (±0.05 for bot tuning, AC-CP-48); `count_gain[1]` must stay 1.0; `count_gain_qr_5` 1.20–1.30, *derived*: above 1.30 more than about 9.5 % of five-element lives spend over half of QR's lifespan there (AC-CP-47) | Whether every element count meets the Realms years table. Must be recomputed if Spiritual Roots' `purity_mean` or `purity_sd` moves |
| `speed_mult` | 1.00 / 1.15 / 1.30 / 1.45 | edge per tier 1.10–1.25 | How much a tier above par is worth against a better root fit. At 1.25 per tier, tier dominates match more often |
| `layer_speed_penalty` (δ) | 0.06 | 0.04–0.10 | The cost of switching. At 0.10, staying with a technique matters more |
| `layer_speed_floor` | 0.70 | 0.5–0.8 | The worst ramp. **Coupled with δ:** the floor binds only from (1 − floor) ÷ δ unmastered layers (5 at the defaults), so change the two together |
| `beyond_realm_mult` | 0.25 | value from Realms rule 13 | The tier ceiling. At 0.25 a beyond-realm method at match 0.5 gives about 0.25, close to crude, so the crude floor often binds past a ceiling |
| `mastery_base` | 1.0 | 0.7–1.5 | Layer pace for everyone |
| `mastery_comp_divisor` | 100 | 60–200 | How much Comprehension speeds mastery: ×1.45 at 45, ×2.5 at 150 (100); ×1.75 at 45 (60) |
| `mastery_idle_frac` | 0.5 | 0.25–1.0 | The pace in seasons spent travelling or crafting. Inert for a life that always cultivates |
| `trio_cost` | 60 / 84 / 118 / 165 / 231 | ±30 %; keeps a realm's trio at 20–55 % of a 3-element root's realm time (*derived*, Formulas B) | Layer pace per realm |
| `layer_weights` | 0.25 / 0.33 / 0.42 | must sum to 1 | Whether a realm's last layer is the slow one |
| `layer_cost_mult` | 1.0 / 1.2 / 1.4 / 1.6 | 1.0–2.0 | The ramp cost of a higher tier |
| `catchup_mult` | 0.25 | 0.1–0.5 | The cost of a fresh technique's lower-realm layers, and so the switch cost at each tier ceiling (27 / 60 / 114 seasons at the defaults) |
| `second_main_mult` | 0.5 | value from Meridian Map #6 | #6's speed; additive, up to +50 % (Open Question 2) |
| `second_main_mastery` | 1.0 | 0.5–1.0 | Whether the #6 slot doubles as a mastery route for the next method |
| `power_mult` | 1.0 / 1.3 / 1.7 / 2.2 | Heaven ≤ 2.2 before `comp_strength` (the Character Stats range is 2.2 × 1.525) | Spiritual power and combat by tier |
| `power_layer_floor` | 0.6 | 0.4–0.8 | How much a found high-tier technique is worth before it is mastered |
| `no_tech_power` | 0.5 | 0.4–0.8 | Spiritual power with no main method |
| `strength_comp_mean` | 45 | *derived*: the talent roll's mean | The Comprehension that gives a technique's written value. Moves with the talent roll, or the average character gains or loses strength |
| `strength_comp_divisor` | 200 | 100–400 (guess) | How much Comprehension strengthens techniques: ×1.275 at 100 (200); ×1.55 at 100 (100) |
| `strength_comp_body_share` | 0.5 | 0–1 (guess) | How much Comprehension matters to body techniques: 0 leaves them to Physique alone, 1 treats them like any technique |
| `bonus_layer_floor` | 0.3 | 0.2–0.5 | Bonus value at layer 1 |
| `bonus_budget` | 1.0 / 2.0 / 3.0 / 4.0 | ±25 % (guess); generated commons must stay inside it (a Profound secret art at pool maxima uses 2.0) | The total bonus a tier of technique may carry; the validator rejects a template over it |
| `bonus_single_cap` | 1.5 | 1.2–2.0 (guess) | The largest single bonus, in pool maxima |
| `body_factor_cap` | 1.5 | 1.2–1.5 | How far Physique can push a body technique |
| `harmony` | 1.15 / 1.00 / 0.60 | generating 1.05–1.25; overcoming 0.4–0.8 | Whether auxiliary arts must be chosen around the main method |
| `aux_slots` | 2 | 1–3 | Build width |
| `multi_element_chance` | 0.2 | 0.1–0.3 | The share of 2-element commons |
| `root_bias` | 0.6 | 0.4–0.8 | How often a player offer fits the root. At 1.0 the market is a vending machine; at 0 a 1-element root rarely sees a fit |
| `secret_art_bonus_extra` | 1 | 0–2 | Whether a Yellow secret art is worth a slot (at 0 it does nothing) |
| `price_base`, `price_spread` | 0.85, 0.30 | band ±10–25 % | Price spread of commons |
| `no_cong_phap_mult` | 0.3 | 0.2–0.4; in `cultivation_realms.json` | Crude cultivation, and the crude floor under every slotted main method (Formulas A). Raising it makes the tier ceiling softer |

## Visual/Audio Requirements

Deferred to the Game UI GDD (system 37). Intent:
- each technique shows its tier colour and the colours of its named elements;
- mastering a layer is a small moment, and great completion (đại thành) a big one;
- unlocking a divine ability is a celebrated moment.

## Game Feel

Not specified at this tier. Intent:
- finding a manual is a decision, not a pickup: "does it fit my root, and is it
  worth the ramp?";
- staying with a technique should feel like depth paying off;
- reaching a tier ceiling should feel like a push to go out and find the next one,
  not a wall.

## UI Requirements

These apply to the Debug Terminal now and to the Game UI later.
- **The technique panel.** It shows:
  - the main slot, the auxiliary slots and the #6 slot when held;
  - per technique: tier, kind, named ids with the root's purity for each, layer
    *k* of *layers*, and stored mastery against the next cost;
  - the gate: "layer 7 needs Core Formation".
- **Speed.** The rate breakdown has one technique line. Its tooltip, or `explain`,
  splits it into κ, g, edge, match, L and beyond, for example "Profound Wood–Fire,
  layer 8: 2.0 ÷ 1.22 (2 elements) × 1.00 × 0.63 × 0.94 = 0.97".
  - A beyond-realm method is flagged in the line: "[beyond its realm]", as built. The
    ×0.25 itself is not shown yet (Open Question 8).
- **Harmony.** Each auxiliary art shows its relation to the main method (generated
  by it / neutral / overcoming) and the resulting ×1.15 / ×1.00 / ×0.60.
- **Known list.** It lists known techniques, marks the unusable ones with the
  missing id ("needs Water"), and shows each one's kept layers.
- **Before learning or slotting.** The screen previews the speed and bonus change,
  and the seasons to reach the speed of the current method. This makes the ramp
  trade-off (Formulas A) visible. It also shows the new lifespan cap, and the death
  confirmation of Realms rule 14 when the change would end the life.
- **Manual items.** Market and inventory show tier, kind, named ids, whether the
  manual fits the root, and whether it is already learned.
- **Before a great breakthrough.** If the main method's max realm is below the next
  realm, the breakthrough preview warns before the attempt, for example "At Nascent
  Soul your Profound Fire method runs at ×0.25. Next-tier Fire method: <source>". The
  source is the rule 18 guaranteed copy's current location.

## Cross-References

| Document | Relationship |
|---|---|
| `design/gdd/game-concept.md` | Cultivation techniques (core mechanic 4), the ~40 content target, onboarding (one technique at start) |
| `design/gdd/linh-can.md` | Rule 8 (the purity scale of named ids, a locked contract); the fallback that rule leaves to this GDD is rule 8 here |
| `design/gdd/canh-gioi.md` | Formulas I (the `tech` term), rule 13 (the ×0.25 tier cap), rule 14 (the lifespan confirmation for slot changes), the years-per-realm table that Formulas A calibrates against |
| `design/gdd/character-stats.md` | The provider interface, the bonus curves (rule 14, Formulas I), spiritual power (`tech_power`, range 0.5–3.355), effective Comprehension and Physique, the precision and tolerance rules, Market rounding |
| `design/gdd/kinh-mach-do.md` | Capability #6 (the second main slot); rule 7's technique seals are retired |
| `design/gdd/combat.md`, `combat-defence.md`, `combat-damage-types.md` | Art records (rule 13), body defence (rule 2, Iron Body tiers), typed damage parts |
| `design/gdd/modifiers.md`, `effects.md` | Modifier keys, tags and `more` on L2; the Effects techniques host |
| `design/gdd/dao.md`, `item-database.md` | Way requirements on technique kinds; manuals as items |
| `design/glossary.md` | Tier, kind and element names |
| `assets/data/items_cong_phap.json`, `cultivation_realms.json`, `character_elements.json` | The data this GDD's keys change or read |
| `src/gameplay/cultivation/cultivation_rules.gd`, `src/gameplay/items/item_factory.gd`, `src/gameplay/character/stat_sheet.gd`, `src/gameplay/character/character_rules.gd` | Code the changes touch |

## Acceptance Criteria

Drafted with `qa-lead`, which recomputed every number in Formulas (its corrections are
applied above).

- **Gate levels.** Logic, Integration and UI are BLOCKING; Config/Data is ADVISORY.
  Balance criteria are bot-harness runs that gate sign-off of the guessed values in
  Formulas A–C, not an implementation story.
- **Suites.**
  - Logic: `tests/unit/cultivation/`, next to `cultivation_rules_test.gd`.
  - Integration: `tests/integration/cultivation/`.
  - UI evidence: a debug-terminal transcript in `production/qa/evidence/debug-terminal/`.
- **Determinism and isolation.**
  - Every random test uses a fixed seed, with tolerances of about four standard
    errors.
  - Fixtures come from factory functions (root, template, character), not inline
    records.
  - Floats are compared with `assert_near` at 1e-6 unless stated.
  - The only file I/O is loading `assets/data/`; the validator tests pass in-memory
    dictionaries.
  - No test writes to `user://`. Terminal runs pass `--no-llm --achievements-file ""`,
    and LLM effects come from a stub, never the user's LLM config.
- **Default fixture** unless stated:
  - root R = {Wood (Mộc) 40, Fire (Hỏa) 86};
  - Comprehension (ngộ tính) 45, Physique (căn cốt) 60;
  - every season spent cultivating, stage multiplier 1.00, no speed bonuses;
  - `count_gain` pinned to 1.0 for every element count, so the `tech` values below
    test the other terms; AC-CP-18a tests `g` itself.
- *k* is the highest mastered technique layer (tầng công pháp).

**Rules**

- **AC-CP-01** [Logic] Rules 1, 2 and 9, the record and its kinds.
  - A manual (bí tịch) item resolves to its template, which has every rule 1 field.
  - With R at QR, a Yellow (Hoàng) [Fire] main method (tâm pháp) at k 3 gives `tech`
    1.72 and `tech_power` 0.76.
  - Adding a [Wood] secret art (bí thuật) and a body technique (luyện thể) in the two
    auxiliary slots leaves both values unchanged.
- **AC-CP-02** [Logic] Rule 3, a higher tier is not a strict upgrade. At QR, k 3,
  root R:
  - a Heaven (Thiên) [Wood] main method gives `tech` 1.16, against 1.72 for a Yellow
    [Fire] one;
  - its `tech_power` is still higher, at 1.4457 against 0.76.
- **AC-CP-03** [Logic] Rule 4, learning.
  - Reading a manual adds the technique at k 1 with stored mastery 0.
  - No season passes, and no resource changes.
  - The manual stays in the inventory.
  - A second manual of the same template changes nothing: the known list, k and
    stored mastery are as before, and the second manual stays an item.
  - With R, a [Water] technique can be learned (Known · unusable) but not slotted
    (AC-CP-07).
- **AC-CP-04** [Logic] Rule 5, layers and realm gates.
  - Layer counts are 6 / 9 / 12 / 15 by tier.
  - Layers 3 / 4 / 6 / 7 / 9 / 10 / 12 / 13 need realm QR / FE / FE / CF / CF / NS /
    NS / DT.
  - A Heaven technique held in QR cannot pass k 3.
  - A Yellow technique at DT has cap 6.
  - k = `layers` reports great completion (đại thành).
- **AC-CP-05** [Logic] Rule 6, slots. Each of these is refused with a reason line, and
  the state is unchanged:
  - a third auxiliary slot;
  - the same technique in two slots;
  - a main method in an auxiliary slot, or an auxiliary art in the main slot.

  At a season start a swap costs no season and no resource (a swap that would put the lifespan cap at or below the age first needs Realms rule 14's confirmation: AC-CG-62). The technique taken out
  keeps its k and stored mastery exactly. A season's mastery and rate use the slots
  as they were at its start.
- **AC-CP-06** [Logic] Rule 7, mastery. A Yellow [Fire] main method from k 1 at QR,
  gaining 1.45 a season:
  - end of season 13: k 1, stored 18.85;
  - end of season 14: k 2, stored 0.50;
  - end of season 31: k 2, stored 25.15;
  - end of season 32: k 3, stored 1.40.

  Mastery is never lost: k and stored mastery are unchanged after unslotting and
  reslotting, and after a forced failed breakthrough.
- **AC-CP-07** [Logic] Rule 8, usability. With R:
  - [Wood, Fire] is usable;
  - [Wood, Water] is not;
  - [Light (Quang)] is usable only if Light is owned or its purity is at least 10;
  - with Water raised to 12 by Water-land roads (not owned), [Wood, Water] is usable and its speed reads Water 12;
    at Water 9 it is not (`tech_foreign_purity_min` 10);
  - a body technique is always usable.

  Guard case: a test-only fixture removes Fire from the root. The slotted [Fire] main
  method is unslotted at the next season start, not at once.
- **AC-CP-08** [Logic] Rule 8, crude cultivation, with R and an empty main slot:
  - `tech` = 0.3 × 86 ÷ 100 = 0.258, with the label "No main method (crude)", as
    built;
  - `tech_power` = 0.5;
  - the main slot gains no mastery;
  - a slotted auxiliary art still gains 1.45 a season, and its bonus uses harmony
    1.00.
- **AC-CP-09** [Logic] Rule 13, divine abilities (thần thông). The fixture main method
  carries ability `a1` at `unlock_layer` 4, and an auxiliary art carries `a2` at 1. At
  FE:
  - at k 3 the unlocked list is [a2];
  - once layer 4 is mastered it is [a1, a2];
  - after the main method is unslotted, `a1` is gone;
  - when it is reslotted, `a1` returns with no new mastery.

  Known but unslotted techniques never add abilities. An unlocked ability is only eligible for the loadout's art
  slots; it is usable in a fight once slotted (Combat rule 13).
- **AC-CP-10** Retired 2026-11-10 with rule 15 (seal counting). An old save with seal counts loads and drops them.
- **AC-CP-11** [Logic] Rule 16, the starting technique. A new life starts with a
  generated Yellow main method naming the strongest base element: k 1, stored
  mastery 0, in the main slot, `origin` `generated`.
  - {Wood 40, Fire 86, Water 10} → Fire.
  - {Wood 60, Water 60} → Wood (the first tied element in `cycle` order).
  - {Fire 50, Metal 50, Earth 30} → Fire.
  - {Earth 70, Metal 70, Water 70} → Earth.
  - {Wood 40, Fire 86} plus Wind 90 → Fire, because variants are ignored.
- **AC-CP-12** [Config/Data] Rule 17, the shipped catalogue.
  - Every Earth and Heaven template, every template naming a variant (biến dị) and
    every body technique has `origin` `authored`.
  - There is at least one main method, one secret art and one body technique.

**Data and formulas**

- **AC-CP-13** [Config/Data] Parameter keys in `items_cong_phap.json`. Per tier:
  - `speed_mult` 1.00 / 1.15 / 1.30 / 1.45 (the old 1.0 / 1.3 / 1.7 / 2.2 survive only
    in `power_mult`);
  - `power_mult` 1.0 / 1.3 / 1.7 / 2.2;
  - `layers` 6 / 9 / 12 / 15, and `max_realm` FE / CF / NS / DT;
  - `layer_cost_mult` 1.0 / 1.2 / 1.4 / 1.6;
  - `value` 30 / 200, `bonus_count` 0 / 1, `weight` 50 / 30 / 15 / 5.

  Globals:
  - `multi_element_count` [2, 2];
  - `trio_cost` [60, 84, 118, 165, 231];
  - `layer_weights` [0.25, 0.33, 0.42], summing to 1 within 1e-9;
  - every other global at its Parameter keys value.

  `no_cong_phap_mult` 0.3 is in `cultivation_realms.json` only.
- **AC-CP-14** [Logic] Formulas A example, rules 9 and 10. Root R, a Profound (Huyền)
  [Wood, Fire] main method, match 0.63:
  - at CF, k 8: `tech` = **1.1844**, shown 1.18;
  - at NS, k 8 (d is still 1): **0.2961**, shown 0.30, with "[beyond its realm]" in
    the breakdown line.
- **AC-CP-15** [Logic] Parity. Root {Water 50} and a [Water] method at every allowed
  layer:
  - Yellow at QR k 3 and at FE k 6;
  - Profound at CF k 9;
  - Earth (Địa) at NS k 12;
  - Heaven at DT k 15.

  Each gives `tech` 1.0.
- **AC-CP-16** [Logic] Edge and layer factor, root {Water 50}.
  - At QR k 3: Profound 1.15, Earth 1.30, Heaven 1.45.
  - Earth at CF k 9: 1.130435.
  - Heaven at CF k 9: 1.260870.
  - Heaven at NS k 12: 1.115385.
  - Profound at CF with k 9 / 8 / 7 / 6 / 5 / 4 / 1: 1.00 / 0.94 / 0.88 / 0.82 / 0.76 /
    0.70 / 0.70.
- **AC-CP-17** [Logic] Capability #6 Twin Technique Cultivation (Song Tu Công Pháp),
  root R.
  - At FE: a Yellow [Fire] main at k 6 (1.72) plus a Yellow [Wood] second at k 6
    (+0.40) gives **2.12**.
  - At CF: a Profound [Fire] main at k 9 (1.72) plus the same Yellow [Wood] second,
    now beyond its realm (+0.5 × 2 × 0.40 × 0.25 = 0.10), gives 1.82.
  - The second slot gains 1.45 a season.
  - Without #6 the second slot does not exist.
- **AC-CP-18** [Logic] Crude branch and range.
  - Crude cultivation gives 0.03 at strongest purity 10 and 0.30 at 100. κ is not
    applied.
  - With root {Water 10}, a Yellow [Water] method at CF, k 1, gives 0.035 (crude
    would be 0.03).
  - Crude floor: with root R, a Yellow [Wood] method at CF, k 6 (beyond its realm),
    computes 0.20 but gives **0.258**, labelled "crude floor". It still gives its
    `tech_power` and bonuses.
  - A Heaven method at purity 100 at QR, k 3, gives 2.9. Adding a second Heaven
    method in the #6 slot gives 4.35.
  - Over every tier × realm × k × purity in {10, 50, 100, 150}, `tech` ≥ 0; at purity 150 a Heaven method at QR, k 3,
    gives more than 2.9 (no cap).
- **AC-CP-18a** [Logic] The element-count gain `g`, with live `count_gain`.
  - A Yellow [Water] method at QR, k 3, on roots whose strongest element is Water 50
    and that hold 1 / 2 / 3 / 4 / 5 base elements gives `tech` 1.0 / 0.8197 / 0.7519
    / 0.7092 / 0.7874 (five elements use 1.27 in QR).
  - The same at FE, k 6, on the five-element root gives 0.6849 (1.46).
  - Root R at CF with a Profound [Wood, Fire] main at k 8 gives **0.9708**, shown
    0.97. At NS the same method computes 0.2427 and gives the crude floor **0.258**.
  - Variants do not change `g`: a 2-element root holding Thunder (Lôi) or Wind (Phong) uses 1.22.
  - `explain` shows `g` inside the technique line, as "÷ 1.22 (2 elements)".
- **AC-CP-19** [Logic] Formulas B, gain.
  - Comprehension 45: 1.45 cultivating, 0.725 idle.
  - Comprehension 1, idle: 0.505.
  - Comprehension 150, cultivating: 2.5.
  - Three cultivating seasons and one idle season at Comprehension 45 add 5.075.
- **AC-CP-20** [Logic] Formulas B, cost.
  - An Earth method at NS, layer 11: **76.23**, shown 76.2. From stored 0 at gain
    1.45 it is mastered in season 53.
  - The same layer at DT: **19.0575**.
  - Yellow layer 2 at QR: 19.8. At FE or above: 4.95, the smallest cost ever paid.
  - Heaven layer 15: 155.232.
  - Catch-up totals at gain 1.45:
    - Profound at CF, layers 2–6: 38.7 points, done in season 27;
    - Earth at NS, layers 2–9: 86.45, season 60;
    - Heaven at DT, layers 2–12: 164.8, season 114.
  - Full-price trios: Yellow FE 84, Profound CF 141.6, Earth NS 231, Heaven DT 369.6.
- **AC-CP-21** [Logic] Formulas C and rule 11, `tech_power`.
  - Yellow: 0.6 at k 1, 0.76 at k 3.
  - Earth at k 9 of 12: **1.514545**.
  - Heaven: **1.445714** at k 3, 2.2 at k 15.
  - A Profound method at k 8, at NS (beyond its realm): 1.235, the same as at CF.
  - No main method: 0.5.
  - A Yellow k 1 main plus a Heaven #6 second: 0.6.
  - Auxiliary arts add nothing.
- **AC-CP-22** [Logic] Formulas D and rule 12, harmony.
  - All 25 ordered (main, art) element pairs match the table: 5 where the main
    generates the art (tương sinh) at 1.15; 10 at 1.00 (the art generates the main, or
    the same element); 10 overcoming pairs (tương khắc) at 0.60.
  - An art naming [Wood, Fire] under a Water main: 0.60 (two pairs, the worst relation).
  - An art naming [Wood, Water] under a Thunder main: 0.84 (four pairs, averaged).
  - Any art under a Primordial Chaos main, or a Chaos art under any main: 1.00 (neutral).
  - An art naming Light under a Water main: 0.60 (a derived variant counts as its required elements).
  - An art naming Wind under a Water main: no harmony penalty (an innate variant is neutral).
  - A Light main against an Earth art: 1.15 (Light counts as Fire, and Fire generates Earth).
  - A Light main against a Metal art: 0.60 (Fire overcomes Metal).
  - Body techniques, and any art while the main slot is empty: 1.00.
  - Example: root {Wood 70, Water 50, Metal 50}, a Profound [Wood] secret art with
    `attack_pct` 12 at k 6 of 9:
    - under a [Water] main: exact 12.2130, stored **12.2**;
    - under a [Metal] main: exact 6.372, stored **6.3**.
- **AC-CP-23** [Logic] Formulas D, B and F.
  - B is 0.3 at k 1 and 1.0 at k = `layers`, for every tier.
  - A body technique with `v_full` 10 at great completion gives 11.0 at Physique 60,
    15.0 at Physique 150 (the cap) and 5.1 at Physique 1.
  - A Yellow [Fire] main with `v_full` 10 at k 6 of 6, root R: 13.6.
  - Body defence (rule 2): a Profound body technique at great completion gives block 30, σ_b 0.30 and Physical
    resistance 25 points at any Physique and Comprehension (Combat tier 3, as Combat AC-CB-60 expects); at its first
    layer, Combat tier 1 (10 / 0.10 / 8.3); at k 5 of 9, tier 2 (20 / 0.20 / 16.6); a Heaven one at great
    completion, tier 5 (50 / 0.50 / 41.5). A Yellow one reaches tier 1 at k 3 and tier 2 at k 6.
- **AC-CP-24** [Logic] Formulas E, price.
  - A Profound main method with `linh_luc_pct` 15 (pool 5–20): q̄ 0.6667, price
    **210** (integer).
  - A Yellow main method with no bonuses: 30.
  - A Profound bonus at the pool minimum: 170; at the maximum: 230.
  - A Yellow secret art with its bonus at the minimum: 26; at the maximum: 35.
  - An authored manual sits at its tier's `value`, whatever its bonuses: 200, 1,500 or
    12,000.
- **AC-CP-25** [Logic] Formulas E, rolls. Over 100,000 seeded commons:
  - unfixed tier: Yellow 62.5 % ± 0.6 pp, Profound 37.5 % ± 0.6 pp;
  - 2-element commons 20.0 % ± 0.5 pp;
  - never 3 elements, never above Profound, never a variant, never a body
    technique;
  - `abilities` always empty, `origin` `generated`;
  - bonus count 0 / 1 / 1 / 2 for a Yellow main / Profound main / Yellow art /
    Profound art;
  - bonus values inside the pool range, on the 0.1 grid, with distinct stats.
- **AC-CP-26** [Logic] Formulas E, root bias. Over 100,000 seeded 1-element player
  offers:
  - Fire-only root: Fire **68.0 %** ± 0.6 pp, each other element 8.0 % ± 0.4 pp;
  - {Wood, Fire, Water}: each root element 28.0 % ± 0.6 pp, Earth and Metal 8.0 % ±
    0.4 pp;
  - non-player rolls (NPC and world loot): each element 20.0 % ± 0.5 pp.

  Fire-only root, 2-element offers, over 50,000 draws:
  - with the first draw stubbed to land on Fire, the second is uniform over the
    other four, 25.0 % ± 0.8 pp each;
  - with the first draw stubbed to miss Fire, the second is Fire 70.0 % ± 0.8 pp;
  - unstubbed, an offer contains Fire 90.4 % ± 0.5 pp of the time.
- **AC-CP-27** [Logic] Gate hold. A Yellow [Fire] method at QR, k 3, stored 20.5,
  gaining 1.45:
  - after one season, stored is 21.0 (cost(4)) and the state is Gated; the 0.95
    surplus is lost;
  - a second QR season leaves 21.0 and k 3;
  - after the breakthrough to FE, the first FE season starts with k 4 and stored 0,
    and ends with stored 1.45.
- **AC-CP-28** [Logic] Several layers in one season. A Yellow method at CF, k 1, stored
  14.0, at Comprehension 150 (gain 2.5):
  - one season masters layers 2, 3 and 4 in order (4.95, 6.3, 5.25);
  - it ends at k 4 with stored 0.0, within 1e-6.

  Tolerance: stored = cost − 5e-7 masters the layer; cost − 2e-6 does not.

**Edge cases**

- **AC-CP-29** [Logic] Great completion. A Yellow method at FE, k 6, slotted for 10
  seasons:
  - stored stays 0 and the state is Great completion;
  - after unslotting it is Known · usable at k 6.
- **AC-CP-30** [Logic] The #6 slot when the main slot is empty, root R. A Yellow
  [Wood] method at k 2 sits in the #6 slot:
  - `tech` is crude, 0.258, and `tech_power` is 0.5;
  - the #6 method adds no bonus line, and its stored mastery is unchanged after a
    season;
  - moved to the main slot at the next season start, it sets `tech`, the #6 slot is
    empty, and it gives one speed term, one bonus line and one season's mastery.

  With a usable main method in the main slot, moving the #6 method there is refused
  with a reason line, and the state is unchanged.

  When #6 is lost, the second slot is emptied at the next season start, and the
  method keeps its k and stored mastery.
- **AC-CP-31** [Logic] Values are read at the season start.
  - Comprehension raised from 45 to 100 mid-season: that season gains 1.45, the next
    2.0.
  - A technique bonus to Comprehension affects mastery from the following season.
  - A Spiritual Root Fruit (Linh Căn Quả) that adds Water mid-season makes a known
    [Water] technique Known · usable at the next season start, not before, and it is
    not auto-slotted.
  - A derived variant's purity change updates match and F at the next season start.
- **AC-CP-32** [Logic] The tier cap covers main-method speed only. A Profound [Fire]
  main at k 9, root R, at NS:
  - `tech` is 0.43;
  - `tech_power`, bonuses and abilities are the same as at CF.

  A Profound secret art at NS gives the same bonus as at CF.
- **AC-CP-33** [Logic] Manuals.
  - After selling a learned manual, the seller still knows the technique.
  - The buyer learns it at k 1.
  - After a manual is lost, stolen or destroyed, the known list, k and stored mastery
    are unchanged.
- **AC-CP-34** [Logic] The load-time validator. Each of these is rejected, with an
  error naming the template id and the field:
  - `unlock_layer` above `layers`;
  - `layers` not matching the tier;
  - more than 3 `names`;
  - a `names` id that is neither a base element nor a catalogue variant;
  - a body technique naming any id;
  - a main method or secret art naming none;
  - a generated common above Profound;
  - a bonus stat with no `bonus_pool` row;
  - an `effects` id with no Effects System record, or an `ability_id` with no Combat art record;
  - a `tags` list that is not the union of its modifiers' tags;
  - an Earth template whose bonuses sum to 3.01 pool maxima, or any bonus above 1.5
    pool maxima. The AC example (attack_pct 20 + linh_luc_pct 20, 2.33) loads.

  The game does not start. A valid fixture catalogue loads.

**Integration**

- **AC-CP-35** [Integration] Realms & Bottlenecks (Formulas I).
  - The rate breakdown has exactly one technique line, and the #6 term is inside it.
  - With the AC-CP-14 fixture, the rate equals the rate with `tech` forced to 1.0,
    times 1.1844 at CF and times 0.2961 at NS. The ×0.25 is applied once, not twice
    (which would give 0.0740).
  - Crude cultivation shows as that same line at 0.258.
- **AC-CP-36** [Integration] Character Stats provider. Root R, with three slotted
  techniques:
  - a Yellow [Fire] main with 1 bonus;
  - a [Wood] secret art with 2 bonuses;
  - a body technique with 1 bonus.

  The sheet has exactly three technique source lines, each naming its technique,
  carrying 1, 2 and 1 modifiers (the body technique's block, body shield and resistance lines are its Combat profile,
  not sheet modifiers, so they do not count here). Unslotting the art at a season start removes its
  line. Known-but-unslotted techniques and an inert #6 method add no line. Values
  are floored to the grid (12.213 → 12.2).
- **AC-CP-37** [Integration] Character Stats, spiritual power (linh lực). At CF, stage
  multiplier 1.00, `linh_luc_pct` 0, without #4:
  - an Earth main method at k 9 gives **9,087.27** (6,000 × 1.514545);
  - an empty main slot gives 3,000.00;
  - a Heaven method in the #6 slot changes neither.
- **AC-CP-38** [Integration] Meridian Map (Kinh Mạch Đồ). (The seal cases are retired with rule 15.)
  - Without capability #6, slotting a second main method is refused.
- **AC-CP-39** [Integration] Combat.
  - The compiled combat profile has no technique line, and `tech_power` reaches it only
    through spiritual power. With no main method at Qi Refining the qi pool is 82.02
    (rule 14; Combat AC-CB-60).
  - The ability list Combat reads equals AC-CP-09's unlocked list at each step.
  - A slotted Profound body technique at great completion gives Combat's profile block 30, σ_b 0.30 and Physical
    resistance 25 points, unscaled by Physique, Comprehension or ws (rule 2; Combat AC-CB-60).
- **AC-CP-40** [Integration] Market.
  - For every presence value 1–150 and every price in 26–35 and 170–230, plus 1,500
    and 12,000, a manual's sell price is at least 1 below its buy price. A buy-and-resell loop never makes a
    profit.
  - Player-offer stock follows AC-CP-26's rates.
- **AC-CP-41** [Integration] Event Engine with a stub LLM.
  - An authored event grants a catalogue manual.
  - A generated common within budget is granted.
  - An LLM effect naming an id outside the catalogue is rejected, and so is a common
    above the event budget. The event's other effects still apply.
  - A flavour name is applied. Other LLM-supplied fields (tier, names, bonuses) are
    stripped, one log line names them, and the effect applies with the catalogue or
    rolled values.
  - Nothing reads or writes `user://`.
- **AC-CP-42** [Integration] NPC builds. Over 200 seeded NPCs from QR to DT:
  - every slotted technique is usable;
  - k ≤ min(3r, `layers`);
  - at most 1 main method (2 with #6) and 2 auxiliary arts, with no duplicates.

  An NPC and a player with the same root, technique, k, realm and Comprehension get
  the same `tech`, `tech_power` and per-season gain.
- **AC-CP-43** [Integration] Rule 18 (provisional: World Generation, Sects & Missions
  and Market have no GDDs). In 20 seeded worlds, for CF, NS and DT and each of the five
  base elements, at least one par-tier main method naming only that element sits in a
  sect library, a market stock or a quest reward in the starting province.
- **AC-CP-44** [Integration] Save/Load. A round trip keeps:
  - the known list, k and stored mastery (exactly);
  - every slot, including #6;
  - generated common records.

  A save taken while a technique is held at a gate reloads with stored = cost.
- **AC-CP-49** [Integration] Rule 18, reservation and fallback. In a seeded world with
  a guaranteed Profound [Earth] method:
  - over 100 seasons of NPC market purchases, no NPC buys, takes or learns from the
    reserved copy;
  - if the sect holding it is destroyed at season N, the same technique is in a
    starting-province market stock at season N + 1, at its Formulas E price, and the
    World Database records the move;
  - the same holds when the quest offering it fails, and when the sect closes to the
    player;
  - a restock never removes the fallback copy before it is bought.

**UI**

- **AC-CP-45** [UI] The debug-terminal transcript shows:
  - each known technique with its tier, kind, "k / layers" and Gated or Great
    completion state, with unusable ones marked by the missing id;
  - the rate breakdown's one technique line at 1.18 for the AC-CP-14 fixture, and its
    `explain` split into κ, g, edge, match, L and beyond;
  - each auxiliary art's harmony relation and multiplier;
  - a refused slot action for a [Water] technique on root R, naming Water.

  The `explain` split, harmony display and missing-id text are unbuilt (Open Question 8).
- **AC-CP-50** [UI] The breakthrough preview of an FE-peak character with a Yellow
  [Fire] main method warns "×0.25" for Core Formation and names the location of the
  rule 18 guaranteed Profound [Fire] method. A character whose main method reaches
  the next realm sees no warning. Unbuilt (Open Question 8).

**Balance** (`tools/balance/autoplay.gd`)

The harness needs four things first: per-season logging of `tech` and match, a
policy that switches technique at each tier ceiling, an option to pin Comprehension,
and a mode that rolls purities at a fixed element count. `--elements N` as built fixes
every purity at 60 and every talent at 50, so it has no purity spread for AC-CP-47's
tail shares and cannot show the strongest-purity gain that `g` divides out. The
`--elements` runs below mean that rolled mode.

- **AC-CP-46** [Balance] **Formulas A calibration, the main bot check.** Run
  `--elements 3` on a fixed seed list, ≥ 100 lives, with Comprehension pinned at 45
  and every season cultivating. The policy keeps the starter through FE, then at
  each ceiling switches to the par-tier method naming the strongest element.
  - Measure per realm the season-weighted mean of tech₀.₅ = `tech` × g × 0.5 ÷ match.
  - Targets, each ±0.04: QR 0.98, FE 0.98, CF 0.92, NS 0.91, DT 0.91.
  - Every realm must lie in 0.87–1.02.
  - The raw mean `tech` must lie in 0.80–1.20 in every realm (expected about 0.98 in
    QR and FE, and 0.92 later).
- **AC-CP-47** [Balance] The QR half-lifespan ceiling under Formulas A. Run
  `--elements 1` and `--elements 5`, ≥ 400 lives each.
  - Median QR years ≤ 60 for both (expected about 25 and about 44).
  - Share of lives over 60 years: ≤ 13.5 % for 1-element (hand 7.7 %) and ≤ 9.5 % for
    5-element (hand about 6 % with `g` 1.27 in QR; limit raised from 6.5 % with the
    `g` decision, keeping the hand-plus-about-3.5-points margin).
- **AC-CP-48** [Balance] Re-check of the Realms years table.
  - AC-CG-33 and AC-CG-33a re-run with Formulas A–C active, and both pass. Expected
    1-element NS median about 465 at Comprehension 50 (about 474 at 45) against the 500
    ceiling.
  - Run `--elements 2`, `3` and `4` with AC-CP-46's policy, ≥ 100 lives each, with the
    generating-pair bonus on. The median years per realm are within ±10 % of the
    Spiritual Roots years table (its Formulas B), the one reference: it includes each
    tier's expected pair bonus, so 3 elements is 36 / 48 / 58 / 97 / 161.
  - By hand this policy runs over that band at NS and DT: about +11 % for 3 elements and
    +12–15 % for 4, from the ramp and Comprehension 45 against the table's 1.25 factor
    (density 1). An overrun of that size is not by itself a `count_gain` error (Open
    Question 1).
  - If a count is off by more, retune that count's `count_gain`, not κ or Realms
    `climb_total` (user decision 2026-11-04, cross-GDD review N6). The Realms
    baseline breakthrough targets (AC-CG-30/31) are then re-run.

**Comprehension strength** (`cong_phap_test.gd`)

- **AC-CP-51** [Logic] Formulas F. `comp_strength` is 0.78 / 1.00 / 1.275 / 1.525 at Comprehension 1 / 45 / 100 / 150.
- **AC-CP-52** [Logic] Formulas C. An Earth method at layer 9 of 12 gives its AC-CP-21 power × 1.275 at Comprehension 100 and × 0.78 at 1.
- **AC-CP-53** [Logic] Rule 11. With no main method `tech_power` is 0.5 at Comprehension 150. A Yellow layer 1 at Comprehension 1 is 0.5, not 0.468.
- **AC-CP-54** [Logic] Rule 12. Against their Comprehension 45 values, a main method and a secret art give × 1.275 at Comprehension 100 and × 0.78 at 1; a body technique gives × 1.1375 and × 0.89.
- **AC-CP-55** [Integration] Raising effective Comprehension from 45 to 100 raises the sheet's bonus and duel offense, and spiritual power carries the full 1.275 (after any `linh_luc_pct` change).

**Not testable here, by design:**
- Lowering a realm: no rule does it.
- The 75 %-cultivating ×1.14 guess: bot only, once Time & Turn exists.
- What a divine ability does: Combat.
- Sects forbidding the sale of their manuals: Sects & Missions.
- Codex carryover: not designed.

## Open Questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | Confirm the hand-computed Formulas A check (mean tech₀.₅ 0.91–0.98 per realm) and the Formulas B pacing with a bot run, and re-run Realms AC-CG-33 and AC-CG-33a with the new factor. User decisions 2026-11-04: keep κ 2.0; the strongest-element starter's speed-up for multi-element roots is divided out per element count by `count_gain` (cross-GDD review N6, replacing the earlier `climb_total` plan, which could not fit its safe range); five elements in QR use 1.27, not 1.46, to keep the QR tail at about 6 %. The bot confirms `count_gain` (AC-CP-48); pill supply stays the breakthrough lever. The hand model puts NS and DT over AC-CP-48's ±10 % band for 3 and 4 elements, so that run must decide whether the band or the expectation moves | Realms & Bottlenecks calibration (bot) | Formulas A and B sign-off |
| 2 | #6 Twin Technique Cultivation is additive, up to +50 % speed, which can shorten realm years by about a third. Check it against its Meridian Map price; the alternative `max(main, 0.5 × second)` would make it nearly worthless | Meridian Map, systems-designer | Capability pricing |
| 3 | What each divine ability does: owned by Combat (its art records, Combat Open Question 13) | Combat GDD | Rule 13 effects |
| 4 | Author the catalogue: about 40 templates, with an MVP handful per kind (main method, secret art, body technique), including variant techniques, heirlooms and the rule 18 par methods for each element. Also give every template a source: `kim_cang_the`, `long_tuong_cong`, `phong_hanh_quyet` and `am_anh_bi_thuat` cannot be obtained in play, because Profound rolls are always generated and callers ask only for main methods and secret arts, so rule 2's body-technique route does not exist yet | content (writer, systems-designer) | Rule 17, rule 18 |
| 5 | About 8 % of one-element lives (purity 21 or less) and about 6 % of five-element lives (purity 53 or less) breach the 60-year QR ceiling. The median holds. A match floor would close the tail, but it would change the Spiritual Roots rule 8 contract | game-designer, Spiritual Roots | Pillar 4 tail |
| 6 | Rule 18 guarantees base-element par methods only. Should a variant root also get a guaranteed variant technique path, or is a switch back to a base element its intended cost? | game-designer | Rule 18 |
| 7 | Whether known techniques carry over between lives | Codex & Karmic Carryover | — |
| 8 | Built: the speed factor, layers and mastery, slots, the speed and power split, bonuses and harmony, commons, seal counting (retired by rule 15; to remove from the code) and the crude floor. Display still unbuilt: <ul><li>the `explain` split of the technique line, and the ×0.25 in it;</li><li>each art's harmony relation and multiplier;</li><li>the missing id on unusable techniques and in the refusal;</li><li>the preview before learning or slotting (speed, bonus, seasons to catch up);</li><li>the breakthrough-preview warning with the source location (AC-CP-50).</li></ul> | implementation story | UI Requirements, AC-CP-45, AC-CP-50 |
| 9 | Rule 18 needs at least 10 authored single-element par methods (5 Earth, 5 Heaven; the Profound ones can be commons) out of about 40. Those 10 now exist in the data, and the build stocks all 15 as reserved market copies. Placing one per element per realm through sects and quests in every world would still strain the 15 / 5 Earth and Heaven rarity weights. Options: allow generated Earth and Heaven methods for guarantee placements only; guarantee only the elements present in the starting province; or grow the catalogue | game-designer, content | Rules 17 and 18 |
| 10 | There is no Player Fantasy section (advisory at the standard tier) | game-designer | — |
| 11 | Techniques naming a relocated mutation (Spiritual Roots rule 16) are re-pointed when the Way (Đạo) is designed. Until then such a template would fail the `names` validation; no shipped template names one | game-designer, the Way | Rule 17 catalogue |
| 12 | ~~Rule 15's interim sector rule~~ **Closed 2026-11-10:** the seals are retired with the Meridian Map's sealed clusters | — | — |
| 13 | Rules with no built path yet: <ul><li>the load-time validator (Edge Cases, AC-CP-34): nothing in `src/` reads `bonus_budget` or `bonus_single_cap`;</li><li>emptying the #6 slot when capability #6 is lost, and rule 8's guard for the #6 slot;</li><li>the unfixed tier roll (Formulas E, AC-CP-25): every caller fixes the tier, the market uses the realm index as the tier, and the tier `weight` values are unread.</li></ul> | implementation story | Edge Cases, AC-CP-25, AC-CP-34 |
| 14 | Comprehension strength (Formulas F) lifts `tech_power` up to 3.355; Combat's qi pool (Combat Formulas A) is sized from spiritual power, so re-check its anchors when the fight is built (the old ward fit is retired) | systems-designer, user | Formulas F, Combat Formulas A |

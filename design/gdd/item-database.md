# Item Database & Generation

> **Status**: In Design
> **Author**: user + agents
> **Last Updated**: 2026-11-06
> **Last Verified**: 2026-11-06
> **Implements Pillar**: Power Is Built, Not Given (3); Every Number Is Bounded and Visible (2); Every Season Counts (4)

## Summary

The Item Database is the one record of everything a cultivator can hold: what each item is, how it is generated within
engine budgets, what it is worth and what happens when it is used, equipped or traded. Items fall into four
categories (consumable, equippable, crafting, other), an item may have several, and the action taken decides what it
does. It documents the built item system, adds one shared rarity ladder and equippable roles, and is the foundation
Combat's full fight is waiting on.

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `Config, Sim Core, World DB`

## Overview

The Item Database is the one record of everything a cultivator can hold, find, trade, craft, wear or use
up: herbs (linh thảo), pills (đan dược), artifacts (pháp khí, pháp bảo), technique manuals (công pháp),
materials, talismans (phù lục), treasures, and later key items such as the Meridian Seal (Mạch Ấn). It
decides what an item *is* (its record and its categories), how new items are *made* (generated within
budgets the engine sets), how an item is *valued*, and what happens when it is *used, equipped, consumed or
traded*. Every other economy system, the crafts, the Market, events and the Way read items through it and
add none of their own rules to a record.

Items are split into four categories: **consumables** (used up when their effect fires), **equippable**
(worn or carried and kept, limited by divine sense [thần thức]), **crafting** (ingredients and materials
that become something else) and **other** (manuals, keys, clues and whatever fits none of these). An item
may carry **several categories**, so a herb can be crafting and also edible; the rules say which
behaviour wins when they conflict (user decision 2026-11-06). Tags, as in Combat, carry what the
categories do not: element, grade, whether an item is poisonous, a ward, body gear or a key.

For the player, items are where a build becomes physical (Pillar 3): a found manual, an aged herb, a
refined artifact. Time is stored in them (Pillar 4), because herbs gain potency with age and pills
carry a quality. Numbers on items are bounded and visible (Pillar 2): even an item an LLM event invents
gets its value and stats from engine budgets, and is a record in the World Database before the player
sees it. The Item Database must stay deterministic from the seed and cheap enough to hold the world's
history, since a living world of 5,000 cultivators owns a lot of items. Combat's full fight waits on this
system and on techniques, abilities and passives (the Combat GDD's build hold).

## Detailed Design

### Core Rules

Numbers are not set here; named values such as `rarity_max` are defined in Formulas and live in the
`items_*.json` files. Rules marked **(assumption)** are the author's reading and wait for confirmation
(Open Questions).

1. **An item is a record in the World Database `items` table.** Every record has an `id`, a `kind`, a
   `name`, an `owner_id` and the fields its kind adds (herb: `age`, `plot`; pill: `quality`; artifact: `base`,
   `grade`, `tier`, `affixes`; and so on). Its categories, tags and rarity are read from its kind and
   template, not stored on it. The record is canonical: whatever it says is the item. Nothing outside
   the table holds item state.
2. **Templates are data; records are instances.** Authored content (herbs, recipes, treasures, the
   technique catalogue, talismans) lives in `items_*.json` and the crafting files, and a record points to
   its template by `template`. **Generated** items (artifacts and common manuals) roll their numbers
   from budgets and store them whole on the record, so a later data change never rewrites an item
   that already exists. A value read through a template follows data changes; a rolled value does not.
   **Change:** materials, treasures and talismans copy `value` onto the record today, and will read it from
   the template instead.
3. **Four categories, and an item may have several** (user decision 2026-11-06).
   - **Consumable:** used up when its effect fires.
   - **Equippable:** worn or carried and kept, limited by divine sense (thần thức).
   - **Crafting:** an ingredient or material that becomes something else.
   - **Other:** manuals, keys, clues and whatever fits none of these.

   | Kind | Categories |
   |---|---|
   | Herb, material | Crafting |
   | Pill, talisman, treasure | Consumable |
   | Artifact | Equippable |
   | Technique manual | Other |
   | Mạch Ấn seal | Consumable and other |

   An item's categories come from its kind and template, and a template may add one. A new category is an
   engine change; a new item or tag is data.
4. **The action decides what an item does.** Each category grants actions: a consumable can be *used*,
   an equippable *equipped* and *unequipped*, a crafting item *put in* a craft, and an item of the other
   category *studied* (a manual) or *turned in* (a key). Every item can also be *held*, *sold* and
   *given*, unless it is bound (rule 13). The player picks the action, so a herb that is crafting and also
   edible (none is yet) is never ambiguous. An **automatic caller** (the Advisor, a bot, an NPC, an auto-use talisman)
   must name the action it wants, and **an item with more than one category is never used up
   automatically** unless the caller named the consumable action for that very item.
5. **Tags carry what categories do not.** A tag is a data string with no behaviour of its own: element,
   role (rule 6), effect (poison, cleanse, ward, key), source. Systems read tags; the Item Database only
   stores them and checks them at load, rejecting any tag that is not defined in data. A tag never
   changes what an item is, only what reads it.
6. **Equippable items declare a role by tags** (user decision 2026-11-06): **weapon**, **ward**,
   **body** and **utility**, and a base may carry several. Weapon, ward and utility default from a base's attack
   and defence (Formulas E); **body** is always authored, because numbers cannot tell a shield from
   armour. Combat reads the roles: ward items feed the ward, body items feed body
   guard, weapons feed offence (Combat Formulas B and D). The Item Database adds no slots by role.
7. **Rarity is one shared ladder; each kind keeps its own detail** (user decision 2026-11-06). Every item
   has a rarity rank from 1 to `rarity_max`. Event budgets are keyed by one rarity cap per realm (Formulas F). Value caps
   (`pill_price_max`, `herb_age_max`, `linh_thach_max`) and the treasure whitelist stay as they are. A kind's own state stays on the kind: herb age, pill quality,
   artifact grade and affixes, technique tier. Each kind maps its own grade or tier onto the rarity
   ladder in data.
8. **Generation: the engine owns every number.** A caller chooses the kind, a rarity or grade inside the
   current budget, an element and an optional flavour name (at most 40 characters). The engine rolls
   everything else, clamps it to the budget, and adds the record to the database before anyone sees it.
   Generation is a pure function of the seeded random stream it is given, the budgets and the data, so
   the same inputs always give the same item.
9. **Value.** Every item has a value in spirit stones (linh thạch) per unit, at least 1, computed by its
   kind: a herb from its base value and potency, a pill from its recipe price and quality, an artifact
   from its base, grade and tier, the rest from data. Value is the price input: the Market adds its own
   margin and computes no price from other fields, though it reads rarity, template and flags to choose
   stock.
10. **Stacks and instances.** An item with state that differs per unit (a herb's age, an artifact's
    affixes, a manual's progress) is an **instance**: one record per item. An item whose units are
    identical (the same pill recipe and quality, the same material, the same talisman) is a **stack**:
    one record with a `qty`. Two stacks merge when their keys match (Formulas G), and a stack with `qty` 0 is
    removed.
11. **Equipping.** Equipping is a flexible set limited by thần thức (user decision 2026-11-06). A character
    may equip up to `equip.max_slots` pieces (more with Meridian Map capability #2). Each piece costs
    thần thức to control, and a piece the character cannot control adds nothing but stays equipped.
    Equipping needs an owned equippable item. Combat and Character Stats decide what a piece adds; the
    Item Database decides whether it is held, worn and counted.
12. **Using a consumable.** The system that owns an item's effect applies it (pills through Alchemy and
    Character Stats, talismans through Combat, treasures through their effect, a seal through the Meridian
    Map), then the Item Database reduces the stack by 1. A use that is refused leaves the item untouched,
    as a Linh Căn Quả refused at full purity is kept. An effect that has a choice or a risk shows its
    preview first. **A removal that would end a life needs a preview** (Realms rule 14): before an
    equipped item is unequipped, given or sold, the Item Database asks Character Stats for the resulting
    lifespan cap and shows it, and the player confirms.
13. **Protected items (assumption).** An item may carry the flag **bound** (it cannot be sold or given:
    a Meridian Seal is bound to its cluster) or **reserved** (NPCs never buy, take or learn from it and
    no Market restock removes it: Cultivation Techniques rule 18, the guaranteed next-tier manual). `bound` is authored on the template and
    `reserved` is set by the system that creates the record, as it is today. Neither stops a player
    using the item.
14. **Ownership.** An item has exactly one owner at any time: a person, a place (a lost item waiting to
    be found) or no one. Transfers (buying, selling, giving, looting, finding, theft) change the single
    `owner_id` and are logged as events. An item whose owner no longer exists is a data error, caught
    when the world is saved.
15. **Time moves state only through its owning system.** The Item Database never changes a record on its
    own. A herb's age is advanced on the season tick by the Spirit Herb system and a nurtured treasure's
    years by Character Stats; the Item Database holds the field and keeps it valid.
16. **Items an LLM event invents are bounded.** An event may ask for an item of a kind, a rarity and an
    element. The engine picks the numbers inside the budget in `events_budgets.json` (a treasure must also be on the
    realm's whitelist), creates and registers the record, and only then lets the narration name it. The narration never changes a record
    afterwards (Pillar 2).
17. **Items explain themselves.** Every derived number on an item (a herb's potency, a pill's value, an
    artifact's attack) can be shown as a Breakdown, and `describe` gives a one-line summary of any item
    that names its categories, rarity and value.
18. **Items enter and leave by named routes.** Items enter by generation (events, Market stock, crafts,
    loot, world history, the starting kit) and leave by use, sale, destruction or loss. Frequencies belong
    to those systems; the Item Database exposes counts by kind, category and rarity so the Balance
    Harness can watch inflation.
19. **Data is linted at load.** A template without a category, a tag not defined in data, a rarity outside
    1 to `rarity_max` and an equippable base with no role are all rejected, so none reaches a record. Defined
    tags live in a new `items_tags.json`, which also holds the existing recipe `effect.tag` strings.

### States and Transitions

An item record has these states. A stack with `qty` 0 never exists; it is removed.

| State | Entered when | Leaves when |
|---|---|---|
| Created | Generated or authored, and added to the table | It gets an owner |
| Held | An owner holds it | It is equipped, used, transferred or lost |
| Equipped | An equippable item is in the owner's equipped list | It is unequipped, transferred or the owner dies |
| Planted | A herb is put in a field plot | It is harvested or dies |
| Lost | Its owner is a place (dropped, abandoned, an owner died) | A character finds it |
| Consumed | A consumable is used up, or a craft takes an ingredient | The record is removed |

Held, Equipped and Lost items are all transferable unless bound. A bound item can still be used, but
not sold or given.

### Interactions with Other Systems

Alchemy, Artifact Refining, Formations, Talismans, Spirit Beasts, Market, Events, NPC Builds and the Living
World have no GDD yet (quick specs at most). Rows marked **provisional** hold the contract this GDD expects.

| System | Direction | What flows | Owner of the interface |
|---|---|---|---|
| World Database (#3) | in / out | The `items` table and its records, the owner index, event logging for transfers | World DB (storage); this GDD (what an item record is) |
| Config (#1), Sim Core (#2) | in | Data files, the seeded random stream, Breakdown | Config, Sim Core |
| Character Stats (#7) | out / in | Out: equipped affixes, timed pill effects and lifespan pill years. In: the lifespan cap preview for rule 12 | Character Stats (keys, caps); this GDD (the records) |
| Realms & Bottlenecks (#8) | out | Breakthrough pills (tag and quality) and talismans, consumed on use; the unequip preview | Realms (what a gate needs); this GDD (the items and the preview) |
| Cultivation Techniques (#9) | out / in | Manuals as items pointing at templates; generated commons stored whole; the reserved flag | Techniques (record schema, rule 18); this GDD (storage, flags) |
| Meridian Map (#10) | out | The Mạch Ấn seal key item and its bound flag, consumed on use | Meridian Map (what a seal does); this GDD (the item) |
| Combat (#21) | out | Equipped pieces with role tags, attack, defence and affixes; consumable arts (talismans) | Combat (what a piece adds, on hold); this GDD (roles) |
| Alchemy (#15), Spirit Herbs (#14) | in / out | Herbs and pills created and consumed; herb age advanced on the tick (**provisional**) | Alchemy, Spirit Herbs |
| Artifact Refining (#16), Formations (#17), Talismans (#18), Spirit Beasts (#19) | in / out | Crafted items created and ingredients consumed (**provisional**) | each crafting system |
| Market (#20) | out | Value, the reserved and bound flags (**provisional**) | Market (price and stock); this GDD (value) |
| Event Engine (#23) | in / out | Item requests within a budget; rewards created through generation (**provisional**) | Event Engine (the request); this GDD (the record) |
| NPC Builds (#24), Living World (#28) | in | Items generated for NPCs and moved by the world (**provisional**) | NPC Builds, Living World |
| Save/Load (#5) | out | The records, whole | Save/Load |
| Debug Terminal (#36), Game UI (#37) | out | `describe`, category and tag data, previews | the presentation system |
| Balance Harness (#33) | out | Counts by kind, category and rarity | Balance Harness |

## Formulas

Everything below documents the built game unless marked **change**. The built numbers were calibrated by bot
runs and stay as they are; `per_doubling`, `max_potency`, `element_chance`, the grade weights, `value_mult`,
`buy_markup` and `sell_ratio` have no recorded rationale beyond that. Manual price and tier belong to Cultivation
Techniques Formulas E and are not redefined here.

### A. Rarity ladder

The rarity formula is defined as:

`rarity = kind_rank + kind_offset[kind]`, with `1 ≤ rarity ≤ rarity_max`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| rarity_max | int | 6 | data file (**change**: new `items_rarity.json`) | Top of the ladder; herbs already reach 6 |
| kind_rank | int | herb rarity 1–6, material rarity 1–4, artifact grade 0–4, technique tier 0–3, pill band 1–5, talisman `material_rarity` 1–3, treasure rarity 4–5 | data file | The kind's own rank, unchanged |
| kind_offset | int | herb 0, material 1, artifact 1, technique 2, pill 1, talisman 1, treasure 0 | data file (**change**) | Aligns each kind onto the ladder |
| pill band | int | 1–5 | calculated | 1 + the number of `pill_band_edges` [20, 150, 1,500, 8,000, 60,000] strictly below the recipe's price |

**Output Range:** an integer from 1 to 6. No built number changes. Pill quality is state, not rarity.

| Rank | Herb | Material | Artifact grade | Manual tier | Pill | Talisman | Treasure |
|---|---|---|---|---|---|---|---|
| 1 | Ngưng Khí Thảo, Thanh Tâm Liên | — | Phàm (0) | — | — | — | — |
| 2 | Hỏa Linh Chi, Hoàng Tinh Sâm | rarity 1 | Hạ (1) | Hoàng (0) | Tụ Khí, Thanh Độc, Hồi Xuân | Hỏa Cầu, Kim Cương | — |
| 3 | Xích Huyết Đằng, Băng Tâm Thảo | rarity 2 | Trung (2) | Huyền (1) | Hoàng Long, Tĩnh Tâm, Huyết Khí | Thần Hành | — |
| 4 | Kim Tủy Quả | rarity 3 | Thượng (3) | Địa (2) | Trúc Cơ | Phá Cảnh | Mạch Ấn |
| 5 | Vạn Niên Mộc Linh, Anh Tâm Liên | rarity 4 | Cực (4) | Thiên (3) | Ngưng Nguyên, Tẩy Tủy, Diên Thọ | — | Linh Căn Quả |
| 6 | Hóa Thần Quả | — | — | — | Hóa Anh, Hóa Thần | — | — |

**Example:** Trúc Cơ Đan's price of 400 sits above two edges, so its band is 3 and its rarity is 3 + 1 = **4**.

### B. Herb potency and value

The herb_potency formula is defined as:

`herb_potency = clamp(1 + per_doubling · log2(max(age, 0.01) / mature_years), 0.1, max_potency)`

The herb_value formula is defined as:

`herb_value = max(1, round(base_value · herb_potency))`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| age | float | ≥ 0 | record | Years grown |
| mature_years | float | 1–100 | data file (`items_herbs.json`) | Age of full value |
| per_doubling | float | 0.5 | data file | Potency per doubling of age |
| max_potency | float | 5 | data file | Reached at 256 × `mature_years` |
| base_value | int | 2–3,000 | data file | Value at maturity |

**Output Range:** potency 0.1–5, at 1.0 at maturity, 1.5 at twice that age and 2.0 at four times. Value is at least 1.

**Example:** Hoàng Tinh Sâm (mature 10, base 20): age 5 gives potency 0.5, value **10**; age 40 gives 2.0, value **40**.
Kim Tủy Quả (mature 50, base 150) at age 42 gives 0.874, value **131**.

### C. Pill value and margin

The pill_value formula is defined as:

`pill_value = int(price · (1 + 0.5 · quality))`

The pill_margin lint is defined as (**change**: new, warning only):

`pill_margin = price · yield · sell_ratio / (Σ herb_value(min_age) · qty · buy_markup)`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| price | int | 12–40,000 | data file (`items_recipes.json`) | Recipe base price |
| quality | int | 0–3 | record | Pill quality rank |
| yield | int | 1–2 | data file | Pills per brew |
| buy_markup, sell_ratio | float | 1.5, 0.6 | data file (`session_actions.json`) | The Market's margin, shown here only for the lint |

**Output Range:** `pill_value` runs from 12 to 100,000 and truncates. A margin below 1 means a pill loses money when
its herbs are bought at the Market, even at 100 % brew success.

**Today's margins (user decision 2026-11-06: no change).** Every recipe costs less than it sells for at herb value.
Only Tĩnh Tâm Đan fails the lint, at 0.85; Huyết Khí Đan is thin at 1.07. Both are pills to use, not to trade. The lint
warns on any new recipe below 1.

**Example:** Hồi Xuân Đan, price 18, quality 1: int(18 × 1.5) = **27**. Tĩnh Tâm Đan: 150 × 1 × 0.6 = 90 against 71 × 1.5 = 106.5, so **0.85**.

### D. Artifacts

The artifact formulas are defined as:

`scale = grade.power_mult · tier.power_scale` ; `attack = base.attack · scale` ; `defense = base.defense · scale` ; `value = int(base.base_value · grade.value_mult · tier.value_scale)` ; `than_thuc_cost = base.than_thuc_cost · realm(tier).than_thuc_mult`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| grade | int | 0–4 | data file or caller | Phàm to Cực phẩm; rolled by weights 40 / 30 / 18 / 9 / 3, clamped to the cap |
| power_mult, value_mult | float | 1 / 1.3 / 1.7 / 2.2 / 3; 1 / 2 / 4 / 9 / 20 | data file | Per grade |
| affix count | int | 0 / 1 / 2 / 3 / 4 | data file | Per grade |
| tier | int | 0–4 | caller | The realm the item is made for |
| power_scale, value_scale | float | 1 / 10 / 100 / 1,000 / 10,000; 1 / 8 / 60 / 400 / 3,000 | data file | Per tier |
| than_thuc_mult | float | 1 / 3 / 10 / 30 / 100 | data file (`cultivation_realms.json`) | Per realm |
| element_chance | float | 0.6 | data file | Chance an artifact has an element |

**Affix roll.** For each affix slot, one affix is picked by weight from the 9 in the pool without replacement. An
element-bound affix on an item with no element skips that slot, so the item has one affix fewer. Each value is
`snapped(uniform(min, max), 0.1)`. Affixes change neither attack, defense nor value; they apply through Character Stats
and Combat.

**Output Range:** Phi Kiếm's attack runs 30 to 900,000 and its value 20 to 1,200,000 across grades and tiers.

**Example:** Phi Kiếm at tier 1, grade 2: scale 17, attack **510**, value 20 × 4 × 8 = **640**, thần thức cost **60**, two affixes.

### E. Role tags

The default_role formula is defined as:

`a = attack / (attack + defense)` ; role = **weapon** if `a ≥ weapon_min`, **ward** if `a ≤ ward_max`, otherwise **utility**. An authored `roles` list on the base replaces this. **Body** is only ever authored.

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| attack, defense | float | ≥ 0 | data file | The base's values, before grade and tier |
| weapon_min, ward_max | float | 0.70, 0.30 | data file (**change**) | Thresholds; guesses |
| roles | list | weapon, ward, body, utility | data file (**change**) | Authored override |

**Output Range:** one or more roles. A base with no attack and no defence is utility.

| Base | Attack / defence | a | Role |
|---|---|---|---|
| Phi Kiếm | 30 / 0 | 1.00 | weapon |
| Ấn | 40 / 5 | 0.89 | weapon |
| Phiến | 32 / 5 | 0.86 | weapon |
| Châm | 22 / 0 | 1.00 | weapon |
| Hồ Lô | 25 / 10 | 0.71 | weapon, utility (authored) |
| Kỳ | 15 / 15 | 0.50 | utility |
| Chuông | 10 / 25 | 0.29 | ward |
| Thuẫn | 0 / 35 | 0.00 | ward |
| Giáp | 0 / 30 | 0.00 | body (authored) |

**Example:** Chuông: 10 / 35 = 0.29, at or under 0.30, so **ward**.

### F. Budgets

The realm_rarity_cap formula is defined as (**change**: replaces four per-realm keys, with the same results):

`cap[kind] = realm_rarity_cap[realm] − kind_offset[kind]`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| realm_rarity_cap | int | 3 / 4 / 5 / 5 / 5 | data file (`events_budgets.json`) | One cap per realm on the ladder |
| default_rarity_offset | int | −1 | data file | Replaces `default_artifact_grade_offset` and `default_cong_phap_tier_offset`, both −1 |

| Realm | Ladder cap | Herb | Material | Artifact grade | Technique tier |
|---|---|---|---|---|---|
| Qi Refining | 3 | 3 | 2 | 2 | 1 |
| Foundation Establishment | 4 | 4 | 3 | 3 | 2 |
| Core Formation | 5 | 5 | 4 | 4 | 3 |
| Nascent Soul | 5 | 5 | 4 | 4 | 3 |
| Deity Transformation | 5 | 5 | 4 | 4 | 3 |

**Output Range:** every derived cap equals today's value. These stay as they are: `pill_price_max` (a price cap, because the
ladder is too coarse above Core Formation), `herb_age_max`, `linh_thach_max`, the `treasures` whitelist (it overrides the
rarity cap: Linh Căn Quả is rank 5 and allowed from Foundation Establishment) and the Market's stock keys.

**Known gap (user decision 2026-11-06: leave and measure).** The rarity cap bounds an artifact's power, not its value. At
the cap, one artifact is worth 1.25× to 6× the realm's `linh_thach_max`, and selling returns 60 % of that, so artifacts
are the real wealth tap. Formulas H watches it.

**Example:** at Foundation Establishment, an artifact's grade cap is 4 − 1 = **3**, and the default grade is 3 − 1 = **2**.

### G. Stacks

The stack_key formula is defined as:

`stack_key = (kind, template, quality, owner_id, bound, reserved)` ; two stacks merge when their keys are equal ; `qty = qty_a + qty_b`

The stack_value formula is defined as:

`stack_value = value_of(unit) · qty`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| kind | string | pill, material, talisman, treasure | record | Kinds that stack |
| quality | int | 0–3 | record | Pills only |
| bound, reserved | bool | — | record | **Change:** part of the key, so a bound seal never merges with a free one |
| qty | int | ≥ 1 | record | Units |

**Output Range:** herbs, artifacts and manuals are instances and never merge. A pill's unit value truncates before it is multiplied.

**Example:** three Hồi Xuân Đan at quality 1: 3 × 27 = **81**.

### H. Harness measures

All thresholds are proposals with no source; set them after the first run.

| Measure | Alarm |
|---|---|
| Records per cultivator, and the world total at 5,000 cultivators | World above about 200,000, or one cultivator above 200 |
| Item wealth against spirit stones, per realm: `Σ value_of · qty / Σ linh thạch` | Drift above 2× over 100 years |
| Value created against removed, per kind and year | Above 1.5 over 50 years |
| Share of records at rank 5–6 | Above 5 % |
| Breakthrough main herbs in random Market stock | Any (a hard invariant) |
| Lowest pill margin among unrestricted recipes | Below 1 for a new recipe |
| Equipped artifacts their owner cannot control | Above 25 % |

## Edge Cases

**Records and data**

- **If a template fails the load lint:** the game does not start in development, and the failing template is named.
- **If a saved record points at a template that no longer exists:** the record is kept, shows its stored name with value 1, and can only be held or sold. The loader logs it.
- **If a template's numbers change in data:** template-read values follow on the next load, and rolled values on existing records stay as they are (rule 2).
- **If an item's owner no longer exists at save time:** it is a data error, logged and reported; the item moves to no owner rather than vanishing.

**Generation**

- **If a request is above its budget:** it is clamped to the cap and the clamp is logged. It is never refused, so an event always gets an item.
- **If no template fits a rarity and element:** the element filter is dropped first (as built), then the lowest rarity is used.
- **If a flavour name is over 40 characters:** it is cut to 40.
- **If an element-bound affix is rolled on an item with no element:** that slot is skipped, and the item has one affix fewer (as built).
- **If a treasure is above the rarity cap but in the realm's whitelist:** the whitelist wins.

**Stacks and values**

- **If part of a stack is sold, given or used:** the stack splits; the moved units keep every field and merge at their destination if a key matches.
- **If two stacks have different owners or flags:** they never merge.
- **If a herb's age is 0:** its potency is 0.1 and its value at least 1.
- **If an affix value is negative:** it stands, as with the Linh affix's −10 to −30 thần thức cost.

**Using and equipping**

- **If a use is refused:** the item stays, and nothing is consumed.
- **If an effect fails after it started:** the item is consumed only after the effect reports success, so a failed effect leaves the item.
- **If an automatic caller gives no action:** the call is refused and logged. The item is not used.
- **If an item has several categories and a craft takes it:** the crafting action consumes it, and no consumable effect fires.
- **If equipping would pass `equip.max_slots`:** it is refused.
- **If a piece costs more thần thức than the wearer has left:** it stays equipped, adds nothing and warns.
- **If thần thức falls, or a Meridian slot capability is lost:** pieces stay equipped in order. Pieces past the cap add nothing until the owner unequips.
- **If an equipped item is sold, given or stolen:** it is unequipped first, with the rule 12 preview for a player action. A theft has no preview.

**Ownership**

- **If a character dies holding items:** the caller moves them; the Item Database only requires a valid new owner.
- **If a bound item's owner dies:** it becomes Lost at that place and stays bound.
- **If a reserved item's source is lost:** Cultivation Techniques rule 18 reissues it through the Market.
- **If a herb is planted:** it stays owned by the planter, and its plot is on the record.

## Dependencies

**Upstream (the Item Database needs these).**

| System | Type | Interface | State |
|---|---|---|---|
| World Database (#3) | Hard | The `items` table, owner index, event log | Built, no GDD |
| Config (#1), Sim Core (#2) | Hard | Data files, seeded streams, Breakdown | Built, no GDD |
| Character Stats (#7) | Soft | The lifespan cap for the rule 12 preview | GDD in review |

**Downstream (these need the Item Database).**

| System | Type | Interface | State |
|---|---|---|---|
| Character Stats (#7) | Hard | Equipped affixes, timed pill effects, lifespan pill years | GDD in review; lists Item DB |
| Realms (#8) | Hard | Breakthrough pills and talismans, the removal preview | GDD in review; lists Item DB |
| Cultivation Techniques (#9) | Hard | Manuals, generated commons, the reserved flag | GDD in review; lists Item DB |
| Meridian Map (#10) | Hard | The Mạch Ấn key and its bound flag | GDD in review; lists Item DB |
| Spirit Herbs (#14), Alchemy (#15) | Hard | Herbs, pills, potency | Built, no GDD |
| Artifact Refining (#16), Formations (#17), Talismans (#18), Spirit Beasts (#19) | Hard | Crafted items, ingredients, roles | Quick specs only |
| Market (#20) | Hard | Value, flags, stock generation | Built, no GDD |
| Combat (#21) | Hard for the full fight | Role tags, attack, defence, consumable arts | GDD designed, build on hold; today's duel reads artifacts directly |
| Event Engine (#23), LLM GM (#29) | Hard | Budgeted item requests | Built, no GDD |
| NPC Builds (#24), World Generation (#27), Living World (#28) | Hard | Items for NPCs and history | Built, no GDD |
| Save/Load (#5) | Hard | Whole records; a `schema_version` bump for the new fields | Built, no GDD |
| Guidance (#35), Debug Terminal (#36), Game UI (#37), Balance Harness (#33) | Soft | `describe`, previews, counts | Terminal and Guidance built |

**Bidirectional check.** Character Stats, Realms, Cultivation Techniques, the Meridian Map and Combat list this system. No
circular dependency is added: crafts and effects act through their own systems, and this system never calls them back
except for the rule 12 preview, which is a read.

## Tuning Knobs

These values must live in data and never in code. Defaults are in Formulas. Safe ranges are left out on purpose, as in
Combat (user decision 2026-11-06), until real content and bot runs exist. Keys owned elsewhere, such as manual prices and
the Market's margin, stay with their owners.

| Knobs | What they affect |
|---|---|
| `rarity_max`, `kind_offset`, `pill_band_edges` | The shared ladder |
| `per_doubling`, `max_potency`, each herb's `mature_years` and `base_value` | Herb value over time |
| Each recipe's `price`, `yield` and quality step | Pill value |
| Grade `power_mult`, `value_mult`, `weight`, affix count; tier `power_scale`, `value_scale` | Artifact power and price |
| `element_chance`, the affix pool and its weights | What generated artifacts look like |
| `equip.max_slots` | How many pieces a build wears |
| `weapon_min`, `ward_max`, each base's `roles` | Equippable roles |
| `realm_rarity_cap`, `default_rarity_offset` | Event reward strength |

**Knobs that move together.** `kind_offset` and `realm_rarity_cap` together set every kind's cap, so a change to one must be
checked against the built caps (AC-ID-07). Breakthrough recipe herbs and `min_age` are owned by Realms and are calibrated:
never change a herb's `mature_years` or `base_value` without re-running Realms' pill supply.

## Visual/Audio Requirements

Art and audio are deferred with the Game UI (#37). The one binding need is the concept's art pillar "Glyphs, not paintings":
a new item needs no hand-painted asset, so a record's kind, element, rarity and role must be enough to compose its icon.
The terminal shows rarity through a colour and always through a word as well, so nothing depends on colour alone.

## Game Feel

- **Finding something:** a rare item is announced with its rarity and what it could do for this build, so the moment reads as
  luck the player can use.
- **Nothing is mysterious:** every item's value and derived numbers are one step away (rule 17).
- **Time is visible:** a herb shows its age and what its next doubling is worth, so waiting feels like saving.

## UI Requirements

| Screen or element | Must show | Must allow |
|---|---|---|
| Inventory | Items grouped by category, an item appearing under each of its categories, with rarity and value | Filter by category, tag and rarity; pick an action |
| Item detail | `describe` line, categories, tags, rarity, value and any Breakdown (rule 17) | Each action its categories grant, with bound items showing that they cannot be traded |
| Equip panel | Equipped pieces, slots used and the cap, thần thức used and available, roles | Equip and unequip, with the rule 12 preview on a removal that would end a life |
| Use preview | The effect, its risk or choice | Confirm or back out |

All of these work in the Debug Terminal first, with numbered menus as elsewhere.

> **📌 UX Flag — Item Database:** this system has UI requirements. In Pre-Production, run `/ux-design` for the inventory and
> equip screens before writing epics. Stories that touch this UI should cite `design/ux/[screen].md`, not this GDD.

## Cross-References

| This GDD | Refers to | Mechanic or value | Note |
|---|---|---|---|
| Rules 11, 12 | canh-gioi.md rule 14 | A removal that would end a life needs confirmation | This GDD owns the preview |
| Rule 12 | character-stats.md rules on pills, Formulas I | Lifespan pill years, timed effects, the cap | Read only |
| Rule 13, Edge Cases | cong-phap.md rule 18 | The reserved manual and its fallback | This GDD owns the flag |
| Rule 2, Formulas A | cong-phap.md rules 2, 17, Formulas E | Manuals, tiers, price | Not redefined here |
| Rules 3, 13 | kinh-mach-do.md rule 7, Open Question 13 | The Mạch Ấn key | This GDD owns the item; sources stay open |
| Formulas C, F | canh-gioi.md Formulas D, E | Breakthrough recipes, herb `min_age` | Calibrated; never changed here |
| Rule 6, Formulas E | combat.md Formulas D, Open Question 10 | Body-tagged defence feeds body guard, the rest the ward | Answers Combat Open Question 10 for the built bases |
| Rule 11 | kinh-mach-do.md capability #2 | Extra equip slots | Read only |
| Formulas D | character-stats.md | Affix stat keys | Read only |

## Acceptance Criteria

[To be designed]

## Open Questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | Confirm the bound and reserved flags (rule 13) and the rule 12 removal preview, both added from other GDDs' needs | user | Rules 12, 13 |
| 2 | Artifact value runs 1.25× to 6× the realm's stone cap. Left as built (user decision 2026-11-06); revisit after the first wealth measure | economy-designer, Balance Harness | Formulas F, H |
| 3 | Where do Mạch Ấn keys come from, and how many does a life find (Meridian Map Open Question 13)? | user | Rule 13 |
| 4 | Should any herb have an edible effect? Rule 4 allows it, and no herb has one in data yet | user | Content pass |
| 5 | Item records at world scale: should ordinary items of dead NPCs be removed, and when? The measure in Formulas H has no data behind it yet | world-builder, Living World | Rule 18 |
| 6 | Herb rarity means scarcity and artifact grade means power, yet they share one ladder. The ladder fits today only because the caps align; a retune of one kind may need an exception | economy-designer | Formulas A, F |
| 7 | Which pill effects are timed (Character Stats rule 12 lists them), and where is the timer held? | systems-designer | Rule 12 |
| 8 | Ward, body and utility roles beyond the 9 built bases, and new equippables Combat needs | game-designer | Content pass, Combat |
| 9 | All Formulas H thresholds, `weapon_min` and `ward_max` are guesses | economy-designer | Formulas E, H |
| 10 | **To do (user 2026-11-06):** add more items to the game, authored by hand rather than generated. Today there are 10 herbs, 12 recipes, 8 materials, 9 artifact bases, 4 talismans and 2 treasures | user, game-designer | Content pass, Combat |

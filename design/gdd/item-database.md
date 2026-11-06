# Item Database & Generation

> **Status**: Designed (pending review)
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
materials, talismans (phù lục), treasures, and key items such as the Meridian Seal (Mạch Ấn). It
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
   template, not stored on it. The record is canonical: whatever it says is the item. Two facts about
   an item sit on the character instead: the equipped list and nurtured years.
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
   an equippable *equipped* and *unequipped*, a crafting item *put in* a craft, and a manual *studied*. Every item can also be *held*, *sold* and
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
   armour. Combat reads them: a body piece's defence feeds body guard, and every other
   piece's defence feeds the ward, whatever its role (Combat Formulas D). Attack feeds offence on any piece.
   The Item Database adds no slots by role.
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
    thần thức to control, and a piece the character cannot control adds nothing but stays equipped. Pieces are
    counted in equip order, and a piece that does not fit is skipped, so a cheaper later piece still counts.
    Equipping needs an owned equippable item. Combat and Character Stats decide what a piece adds; the
    Item Database decides whether it is held, worn and counted.
12. **Using a consumable.** The system that owns an item's effect applies it (pills through Alchemy and
    Character Stats, talismans through Combat, treasures through their effect, a seal through the Meridian
    Map), then the Item Database reduces the stack by 1. A Meridian capability may
    keep a talisman. Some consumables are spent by their system rather than by hand: a talisman at the
    moment it fires, a breakthrough pill at an attempt. A use that is refused leaves the item untouched,
    as a Linh Căn Quả refused at full purity is kept. An effect that has a choice or a risk shows its
    preview first. **A removal that would end a life needs a preview** (Realms rule 14): before the player
    unequips, gives or sells an equipped item, the Item Database asks Character Stats for the resulting
    lifespan cap. If that would end the life it shows the cap and the player confirms; otherwise no
    preview appears.
13. **Protected items (assumption).** An item may carry the flag **bound** (it cannot be sold or given:
    a Meridian Seal is bound to its cluster) or **reserved** (NPCs never buy, take or learn from it and
    no Market restock removes it: Cultivation Techniques rule 18, the guaranteed next-tier manual). `bound` is authored on the template and copied
    to the record, and `reserved` is set by the system that creates the record, as it is today. A bound
    item can still be found, looted or stolen; only selling and giving are refused. Neither stops a player
    using the item.
14. **Ownership.** An item has exactly one owner at any time: a person, a place (a lost item waiting to
    be found), a Market (stock) or no one. Transfers (buying, selling, giving, looting, finding, theft) change the single
    `owner_id` and are logged as events. An item whose owner no longer exists is a data error, caught
    when the world is saved.
15. **Time moves state only through its owning system.** The Item Database never changes a record on its
    own. A herb's age is advanced on the season tick by the Spirit Herb system, and a nurtured treasure's
    years are held and advanced on the character.
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
19. **Data is linted at load.** An unknown kind, a tag not defined in data, a rarity outside
    1 to `rarity_max` and an empty `roles` list are all rejected, so none reaches a record. Defined
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

Bound items can be used, found, looted and stolen, but not sold or given. An item in Market stock is Held by the
Market. Consumed also covers sale to no one, destruction and a dead herb: the record is removed.

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

### Build Gaps

This GDD states the target. These rules read as design but are not in the code yet, beyond what Formulas marks **change**. The
acceptance criteria that fail today are listed so the build scope is visible.

| Rule | What the code does today | Criteria |
|---|---|---|
| 1 | Herb records store `rarity`; artifacts, pills, manuals and talismans have none | 01 |
| 2 | Authored manuals copy `value`, `bonuses` and `layers` onto the record | 25 |
| 3, 4, 5 | No categories, actions or tags exist; `use_item` takes no action, and bots call it bare | 02, 03, 04, 37, 38, 39, 40 |
| 8, 16 | Herb and material clamps are silent, and budgets live only in the event validator, so direct factory callers bypass them | 16 |
| 10 | `EventResolver` never merges, so event materials and talismans make new records; **buying the last talisman does not merge** (`market.gd`, likely bug) | 31, 32 |
| 11 | **A piece the wearer cannot control still applies its affixes** (`stat_sheet.gd`, likely bug). Combat power never checks the slot cap | 42, 43 |
| 12 | `unequip` has no confirm step; `Market.sell` refuses an equipped item instead of unequipping | 44, 45, 46, 47 |
| 14 | Market trades and `give_item` log no event; no owner check runs at save; nothing moves a dead owner's items | 50, 51, 52 |
| 15 | Nothing changes here; listed because the nurture years and equipped list sit on the character | — |
| 17 | `describe` shows no category, rarity or value, and items have no Breakdown | 56, 57 |
| 18 | No counts or item measures exist in `tools/balance/` | 58, 71 to 74, 76, 77 |
| Tuning | The quality step 0.5, the name limit 40, the potency floor 0.1 and the age floor 0.01 are hardcoded | — |
| UI | No inventory, detail or equip screens match this GDD | 78 to 83 |

Migration: removing stored `value` and herb `rarity` and adding `bound` needs a save `version` bump (today 3) and a migration of
version 3 records (`bound` set from the template, `value` dropped). Combat's AC-ID-70 is on hold with the full fight.

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
| pill band | int | 1–5 | calculated | 1 + the number of `pill_band_edges` [20, 150, 1,500, 8,000, 60,000] strictly below the recipe's price. A recipe above the top edge would be rank 7, and the load lint rejects it until the ladder grows |

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
| grade | int | 0–4 | data file or caller | Phàm to Cực phẩm; rolled by weights 40 / 30 / 18 / 9 / 3 among the grades at or under the cap, so a cap renormalises the odds |
| power_mult, value_mult | float | 1 / 1.3 / 1.7 / 2.2 / 3; 1 / 2 / 4 / 9 / 20 | data file | Per grade |
| affix count | int | 0 / 1 / 2 / 3 / 4 | data file | Per grade |
| tier | int | 0–4 | caller | The realm the item is made for |
| power_scale, value_scale | float | 1 / 10 / 100 / 1,000 / 10,000; 1 / 8 / 60 / 400 / 3,000 | data file | Per tier |
| than_thuc_mult | float | 1 / 3 / 10 / 30 / 100 | data file (`cultivation_realms.json`) | Per realm. An affix's cost change is clamped to ×0.1–2.0 when worn, as built |
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
rarity cap: Linh Căn Quả is rank 5 and allowed from Foundation Establishment) and the Market's stock keys. Where the
Market reads `material_rarity_max` today, it reads the derived material cap. Pills, talismans and treasures have no rarity cap.

**Known gap (user decision 2026-11-06: leave and measure).** The rarity cap bounds an artifact's power, not its value. At
the cap, one artifact is worth 0.75× to 6× the realm's `linh_thach_max`, depending on its base, and selling returns 60 % of that, so artifacts
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
| kind | string | pill, material, talisman | record | Kinds that stack; treasures stay instances, as built, because their effects remove the whole record |
| quality | int | 0–3 | record | Pills only |
| bound, reserved | bool | — | record | **Change:** part of the key, so a bound stack never merges with a free one |
| qty | int | ≥ 1 | record | Units |

**Output Range:** herbs, artifacts, manuals and treasures are instances and never merge. A pill's unit value truncates before it is multiplied.

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

- **If an artifact's base is removed from data:** it is treated as a missing template, keeping its rolled numbers.
- **If a template fails the load lint:** the game does not start in development, and the failing template is named.
- **If a saved record points at a template that no longer exists:** the record is kept, shows its stored name with value 1, and can only be held or sold. The loader logs it.
- **If a template's numbers change in data:** template-read values follow on the next load, and rolled values on existing records stay as they are (rule 2).
- **If an item's owner no longer exists at save time:** it is a data error, logged and reported; the item moves to no owner rather than vanishing.

**Generation**

- **If a request is above its budget:** a rarity, grade, tier or age is clamped to the cap and the clamp is logged, so the event still gets an item. A treasure off the whitelist, an over-budget pill or an unknown template is dropped with a warning.
- **If no template fits a rarity and element:** the element filter is dropped first (as built), then the lowest rarity is used. A manual tier with no template falls to the top common tier.
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
| Save/Load (#5) | Hard | Whole records; a save `version` bump and migration for the new fields | Built, no GDD |
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

Drafted by qa-lead, then updated by the main session for the rulings applied after its report. Formulas H thresholds are
unmeasured proposals. Build Gaps (below Detailed Design) says which criteria describe work not built yet.

Evidence: Logic tests under `tests/unit/items/`, Integration tests under `tests/integration/items/`, Balance Harness output
under `production/qa/evidence/balance/`, terminal evidence under `production/qa/evidence/debug-terminal/`.

**Fixtures.** Tolerance is ±0.01 unless stated. Rolled samples use a fixed list of seeds.

- **FX-D:** shipped `assets/data`, unmodified.
- **FX-O:** an overlay copy of the data with the named values changed, loaded through `GameData`.
- **FX-M:** test-only template `fx_edible_herb`, a herb with categories crafting and consumable and a heal effect.
- **FX-N:** a character with Mị lực 50, so buying is exactly ×1.5 and selling exactly ×0.6.
- **FX-E:** thần thức capacity 100, no capabilities, equipped in order A (cost 60), B (cost 60, one `khi_van` +5 affix), C (cost 20), each with attack 10.
- **FX-L:** a test-only artifact with a `lifespan_years` +5 affix, equipped by a character whose age is the cap without it + 1, with no other lifespan bonus.

**Records, categories and tags**

- **AC-ID-01** [Logic] Rule 1. Given one record of each kind in a fresh World Database, then each has `id`, `kind`, `name` and `owner_id` plus its kind's fields, and none stores `categories`, `tags` or `rarity`.
- **AC-ID-02** [Logic] Rule 3. Given FX-D, then herb and material are [crafting]; pill, talisman and Linh Căn Quả are [consumable]; artifact is [equippable]; manual is [other]; Mạch Ấn is [consumable, other]. Given FX-M, `fx_edible_herb` is [crafting, consumable].
- **AC-ID-03** [Logic] Rule 4. Given each category, then consumable gives use; equippable gives equip and unequip; crafting gives put in; other gives study on a manual. Every unbound item also lists hold, sell and give.
- **AC-ID-04** [Logic] Rule 5. Given two FX-O templates identical except for an extra defined tag, then value, categories and actions are equal.

**Ladder and budgets**

- **AC-ID-05** [Logic] Formulas A. Given FX-D, then every rarity is an integer from 1 to 6 and matches the Formulas A table for herbs, materials, artifact grades, manual tiers, pills, talismans (2 Hỏa Cầu, Kim Cương; 3 Thần Hành; 4 Phá Cảnh) and treasures (4 Mạch Ấn; 5 Linh Căn Quả).
- **AC-ID-06** [Logic] Formulas A. Price 20 gives band 1; 21 gives 2; 150 gives 2; 151 gives 3; 400 gives 3 (rarity 4); 40,000 gives 5 (rarity 6). Given price 60,001 in FX-O, rarity would be 7 and the load lint rejects the recipe.
- **AC-ID-07** [Logic] Formulas F; cited by Tuning Knobs. Given `realm_rarity_cap` 3 / 4 / 5 / 5 / 5 and offsets herb 0, material 1, artifact 1, technique 2, then all 20 caps equal today's `events_budgets.json`: `herb_rarity_max` 3 / 4 / 5 / 5 / 5, `material_rarity_max` 2 / 3 / 4 / 4 / 4, `artifact_grade_max` 2 / 3 / 4 / 4 / 4, `cong_phap_tier_max` 1 / 2 / 3 / 3 / 3. The test holds these as a golden table, and until the change lands also asserts the table equals the file.
- **AC-ID-08** [Logic] Formulas F. Given `default_rarity_offset` −1, the default artifact grade is 1 / 2 / 3 / 3 / 3 and the default technique tier 0 / 1 / 2 / 2 / 2.
- **AC-ID-09** [Config] Rule 7, Formulas F. Given FX-D, these are unchanged: `pill_price_max` 150 / 1,500 / 8,000 / 60,000 / 400,000; `herb_age_max` 40 / 120 / 400 / 1,000 / 3,000; `linh_thach_max` 80 / 600 / 5,000 / 40,000 / 300,000; `treasures` empty at Qi Refining and [linh_can_qua] at the other four realms.

**Generation**

- **AC-ID-10** [Logic] Rule 8. Given a fresh generator with seed S and the same inputs, when an artifact, a common manual, a random herb and a random material are each generated twice, then the records are deep-equal before `db.add`, and the generator's state afterward is equal. Over 20 seeds, at least two artifacts differ.
- **AC-ID-11** [Integration] Rule 8. Given an event asking for an artifact with `attack` 99,999 and `value` 99,999, then the record's attack and value are the Formulas D results.
- **AC-ID-12** [Logic] Formulas D. Given a fixed base and element `kim`: Phi Kiếm tier 1 grade 2 is attack 510, value 640, thần thức 60, 2 affixes; Phi Kiếm tier 0 grade 0 is 30, 20, 20, 0 affixes; Phi Kiếm tier 4 grade 4 is 900,000, 1,200,000, 2,000, 4 affixes; Ấn tier 0 grade 1 is attack 52, defense 6.5, value 50, thần thức 30, 1 affix; Giáp tier 2 grade 3 is defense 6,600, value 9,720, thần thức 50, 3 affixes.
- **AC-ID-13** [Logic] Formulas D, affixes. Given 1,000 seeds at grade 4 with element `kim`, each artifact has 4 affixes with distinct ids, each value in range and a multiple of 0.1. Given element `none`, `nguyen_to` never appears and the count is 3 exactly when it was the rolled slot. Attack, defense and value equal the no-affix result.
- **AC-ID-14** [Logic] Formulas D, rolls. Over 100,000 seeds, `roll_grade` with cap 4 gives 40 / 30 / 18 / 9 / 3 % (±1 point). With cap 2, shares are 45.5 / 34.1 / 20.5 % (±1 point). An artifact rolling its own element has one 60 % of the time (±1 point).
- **AC-ID-15** [Logic] Rule 8. A flavour name of 41 characters is cut to 40. A name of 40 is unchanged. Each composed Vietnamese character counts as 1.
- **AC-ID-16** [Integration] Edge Cases. Given a herb request at rarity 9 at Qi Refining, the herb's rarity is at most 3 and one clamp line is logged; the same for material rarity, artifact grade and manual tier. Given an element with no template at the rarity, the element filter is dropped and an item is returned. Given rarity 0, a rank-1 template is returned.
- **AC-ID-17** [Integration] Rule 16, Edge Cases. Given a Linh Căn Quả request at Foundation Establishment (rank 5, cap 4), it is granted. Given the same at Qi Refining, or a Mạch Ấn at any realm, no treasure is created and a warning is logged.
- **AC-ID-18** [Integration] Rule 16. Given a resolving event with an item reward, when the narration is built, the record is already in the `items` table, and after narration it is deep-equal to its state before.

**Values**

- **AC-ID-19** [Logic] Formulas B. Hoàng Tinh Sâm at age 5 is 0.5, value 10; age 10 is 1.0, 20; age 20 is 1.5, 30; age 40 is 2.0, 40. Age 2,560 and age 100,000 are 5.0, value 100. Kim Tủy Quả at age 42 is 0.8742, value 131. At age 0, Ngưng Khí Thảo is 0.1, value 1, and Hóa Thần Quả is 0.1, value 300.
- **AC-ID-20** [Logic] Formulas C. Hồi Xuân Đan at quality 0 is 18, at 1 is 27, at 3 is 45. Hóa Thần Đan at 3 is 100,000. An FX-O recipe at price 15, quality 1, is 22.
- **AC-ID-21** [Logic] Formulas C, lint. Given FX-D, margins (±0.01) are Tụ Khí 2.40, Thanh Độc 2.67, Hồi Xuân 1.80, Hoàng Long 2.06, Tĩnh Tâm 0.85, Trúc Cơ 1.68, Huyết Khí 1.07, Ngưng Nguyên 3.95, Tẩy Tủy 7.14, Diên Thọ 3.64, Hóa Anh 1.33, Hóa Thần 1.30. Exactly one warning names `tinh_tam_dan`, and the game still loads. The lint tests the unrounded margin: an FX-O recipe at 0.99 warns and loads, and at exactly 1.00 it does not warn.
- **AC-ID-22** [Logic] Rule 9. Every item in FX-D has a value of at least 1. Tinh Thiết is 15, Linh Căn Quả 4,000, Mạch Ấn 800, Hỏa Cầu Phù 12, Phá Cảnh Phù 300. Given FX-N, a quality-1 Hồi Xuân Đan (27) buys at 41 and sells at 16, and a 640 artifact buys at 960 and sells at 384.
- **AC-ID-23** [Logic] Rule 2, Edge Cases. Given a saved Phi Kiếm (attack 510, value 640) and a generated manual, when reloaded under FX-O with base attack, multipliers, scales and manual pricing changed, both records and their `value_of` are unchanged.
- **AC-ID-24** [Logic] Rule 2. Given FX-O with Hoàng Tinh Sâm `base_value` 30, an age-40 herb is worth 60. With `mature_years` 20 as well, potency 1.5 and value 45. With Hồi Xuân Đan `price` 20, quality 1 is worth 30.
- **AC-ID-25** [Logic] Rule 2 change. Given FX-O with Tinh Thiết 20, Linh Căn Quả 5,000 and Hỏa Cầu Phù 14, existing records are worth those values and none stores a `value` key.

**Roles**

- **AC-ID-26** [Logic] Formulas E. Given FX-D, Phi Kiếm, Ấn, Phiến and Châm are weapon; Kỳ is utility; Chuông and Thuẫn are ward. Boundary fixtures: 70/30 is weapon, 30/70 is ward, 69/31 and 31/69 are utility. A base of 0/0 is utility with no division error.
- **AC-ID-27** [Logic] Rule 6. Given FX-D, Hồ Lô is [weapon, utility] and Giáp is [body], although Thuẫn and Giáp both have `a` 0.00. No role is ever computed as body. Given six weapon-role artifacts, all six equip.

**Stacks**

- **AC-ID-28** [Logic] Formulas G. Given two stacks of qty 2 and 3 with equal keys, one record remains with qty 5, for pill, material and talisman. Given a difference in any one key field, two records remain.
- **AC-ID-29** [Logic] Formulas G. Given two herbs of equal template and age, two identical artifacts, two identical manuals or two Mạch Ấn with one owner, they stay separate records.
- **AC-ID-30** [Logic] Rule 10, Formulas G. Given a stack of qty 1, when used or sold, the record is gone. No record with qty 0 or below exists after any step. Three quality-1 Hồi Xuân Đan have stack value 81. Three FX-O pills at price 15, quality 1, have stack value 66.
- **AC-ID-31** [Logic] Edge Cases. Given FX-N and a stack of 3 in stock, when one is bought, stock is 2 and the buyer has 1 with every field kept, merged into a matching stack if one exists. Buying the last unit also merges, for pill, material and talisman alike. Selling 1 of 3 leaves 2.
- **AC-ID-32** [Integration] Rule 10. Given a character holding a stack, when the same key arrives by event reward, craft, explore or purchase, its qty rises and no second record appears.

**Using**

- **AC-ID-33** [Logic] Rule 12. Given FX-N with vitality 0.20, no toxicity and 3 quality-0 Hồi Xuân Đan, when one is used, vitality is 0.70, qty is 2 and toxicity rose.
- **AC-ID-34** [Logic] Rule 12. Each of these returns `ok` false with the record, character and generator unchanged: a 4th Huyết Khí Đan, a 3rd Diên Thọ Đan, Tẩy Tủy Đan with every root at full purity, Linh Căn Quả with all five elements at 100, Trúc Cơ Đan by `use`, and Mạch Ấn with no cluster to open.
- **AC-ID-35** [Logic] Edge Cases. Given a stub effect that starts and then reports failure, qty is unchanged.
- **AC-ID-36** [Logic] Rule 12. Given Linh Căn Quả and a missing element, when used with no element, the result has `needs_element`, the options and preview lines, and the fruit is kept. With a valid element, the fruit is consumed.
- **AC-ID-37** [Logic] Rule 4, Edge Cases. Given an automatic caller naming no action, the call is refused, one log line names the caller and item, and nothing changes.
- **AC-ID-38** [Logic] Rule 4. Given FX-M and Mạch Ấn: an automatic caller naming no action, or another action, consumes nothing; naming use for a different record of the same template consumes nothing on this record; naming use for this exact record reduces it by 1; a player picking use reduces it by 1.
- **AC-ID-39** [Logic] Edge Cases. Given `fx_edible_herb` taken by a craft, it is consumed and the character's vitality, toxicity and pill-use count are unchanged.
- **AC-ID-40** [Integration] Rule 4. Given a 100-year autoplay run, every automatic use names its action, no refusal is logged, and no multi-category item is consumed unnamed.

**Equipping**

- **AC-ID-41** [Logic] Rule 11. With no capability, 6 artifacts equip and the 7th is refused. With capability #2, 7 equip and the 8th is refused. An unowned item, a non-artifact and an already equipped item are refused.
- **AC-ID-42** [Logic] Rule 11. Given FX-E, A, B and C stay equipped, B is reported as overflow with a warning, and thần thức spent is 80 of 100. B adds no attack, defense or `khi_van`. When A is unequipped, B adds its attack and +5 `khi_van`.
- **AC-ID-43** [Logic] Edge Cases. Given FX-E at capacity 200, when capacity drops to 100, no piece is unequipped and AC-ID-42 holds. Given 7 pieces with capability #2 removed by fixture, all 7 stay equipped, the 7th adds nothing, and it adds again once a piece is unequipped.
- **AC-ID-44** [Logic] Edge Cases. Given an equipped item sold or given by the player, it leaves the equipped list before the transfer. Given a theft, the same with no preview.

**Removal preview**

- **AC-ID-45** [Logic] Rule 12. Given FX-L, when the piece is unequipped unconfirmed, the result has `needs_confirm`, a line naming the new cap and the age, and nothing changes. When confirmed, the piece is unequipped and the character dies at once.
- **AC-ID-46** [Logic] Rule 12. Given FX-L, selling or giving the piece behaves as AC-ID-45. A theft ends the life with no preview. A removal that leaves the cap above the age shows no preview.
- **AC-ID-47** [Logic] Rule 12. Given FX-L, when the preview runs, the character, world database and generator state are unchanged.

**Flags**

- **AC-ID-48** [Logic] Rule 13. Given a bound Mạch Ấn, sell and give are refused and spirit stones and the record are unchanged. Use still consumes it. Every record of a template with `bound` is bound, and the flag survives save and load.
- **AC-ID-49** [Integration] Rule 13. Given a reserved manual in Market stock, after 5 yearly restocks it is still there. The player can buy it and learn from it. An NPC buy, take or learn attempt is refused.

**Ownership, time and states**

- **AC-ID-50** [Logic] Rule 14. Given a buy, sale, gift, loot, find and theft, each record has exactly one `owner_id` after it, and each logs one event naming the item and both sides.
- **AC-ID-51** [Logic] Rule 14, Edge Cases. Given items owned by a person, a place, a Market and no one, none is flagged at save. Given an owner id that exists nowhere, the save reports it and the item stays with no owner.
- **AC-ID-52** [Integration] Edge Cases. Given a character who dies holding items, the caller moves them to a valid owner, and an invalid owner is rejected. Given a bound item, its owner becomes the place of death and it stays bound, and a character can find it there.
- **AC-ID-53** [Logic] Edge Cases. Given a planted herb, `owner_id` is the planter, `plot` is 0 or above, and selling it is refused until harvest.
- **AC-ID-54** [Logic] Rule 15. Given one record of each kind and the Spirit Herb tick stubbed out, after 40 seasons all records are deep-equal. With the tick on, only herb `age` changes.
- **AC-ID-55** [Logic] States. Created goes to Held on gaining an owner; Held goes to Equipped, Planted, Lost and Consumed; Equipped goes to Held on unequip; Lost goes to Held on being found; a Consumed record is gone. Illegal moves are refused.

**Explaining and counting**

- **AC-ID-56** [Logic] Rule 17. Given one item of each kind, `describe` returns one line naming its categories, rarity and value.
- **AC-ID-57** [Logic] Rule 17. Given Kim Tủy Quả at age 42, a quality-1 Hồi Xuân Đan and the AC-ID-12 Phi Kiếm, a Breakdown exists for potency (0.874), value (27) and attack (510), and its lines match the shown total.
- **AC-ID-58** [Logic] Rule 18. Given 3 herbs, 2 artifacts and 1 Mạch Ấn, counts by kind sum to 6 records, and Mạch Ấn is counted under both consumable and other.

**Load lint**

- **AC-ID-59** [Logic] Rule 19, Edge Cases. Given an FX-O template with each fault in turn (unknown kind, undefined tag, rarity 0, rarity 7, empty `roles`), when the game loads in development, it does not start and the error names the template and the fault.
- **AC-ID-60** [Config] Rule 19. Given FX-D, the lint gives 0 errors and the one AC-ID-21 warning. `items_tags.json` holds `truc_co_dan`, `ngung_nguyen_dan`, `hoa_anh_dan` and `hoa_than_dan`.
- **AC-ID-61** [Logic] Edge Cases. Given a saved record whose template or base is gone, it is kept, shows its stored name, has value 1, offers only hold and sell, and one log line names it.

**Cross-system**

- **AC-ID-62** [Integration] Character Stats. Given a Hộ Thân +10 affix, when equipped `khi_huyet_pct` rises by 10, and when unequipped it returns. Given a quality-0 Diên Thọ Đan at no toxicity, the lifespan bonus rises by 15.0.
- **AC-ID-63** [Integration] Realms. Each breakthrough pill's `effect.tag` equals the `entry_requirement.item_tag` of the realm it enters. Given a pill attempt with a held pill and Phá Cảnh Phù, one of each is consumed whether it passes or fails. A refused attempt consumes neither.
- **AC-ID-64** [Integration] Techniques. Given an owned manual, when learned, the record stays. Given a new world, the rule 18 reserved copies exist. Given the source lost at season N, the same technique is in a starting-province Market at season N + 1 at its normal price, and the World Database records the move.
- **AC-ID-65** [Integration] Meridian Map. Given a Mạch Ấn and an available item-sealed cluster, when used, the cluster opens and the seal is consumed.
- **AC-ID-66** [Integration] Market. Given FX-O with `value_of` stubbed to 100 and FX-N, the buy price is 150 and the sell price 60. A bound item is refused at sale.
- **AC-ID-67** [Integration] Event Engine. Given the keys replaced by `realm_rarity_cap`, the event validator, Market stock and explore loot use the AC-ID-07 caps for each realm. A seeded 100-year run gives identical item records before and after the change.
- **AC-ID-68** [Integration] Save/Load. Given a save with every kind, `bound`, `reserved`, `qty`, affixes, `plot` and `lost`, a round trip is deep-equal and the save `version` is above 3. A version 3 save loads with records migrated.
- **AC-ID-69** [Integration] Combat, today's duel. Given one seeded build, chiến lực and duel results are identical before and after role tags land.
- **AC-ID-70** [Integration] Combat, on hold. Given grade-0, tier-0 Thuẫn and Giáp at B_p 100, stage 1.00, `a_w` is 0.35, `a_b` is 0.30 and the gear adds 10.5 to `ws` and `we`. Adding Kỳ makes `a_w` 0.50. A piece tagged ward and body feeds `a_b` only.

**Balance Harness (bot measures, on a 5,000-cultivator world over a fixed seed set)**

- **AC-ID-71** [Integration] Records. The world total is at most 200,000 and no cultivator holds more than 200 records.
- **AC-ID-72** [Integration] Wealth. Per realm, `Σ value_of · qty / Σ linh thạch` drifts by no more than 2× over 100 years.
- **AC-ID-73** [Integration] Flow. Value created against removed, per kind, stays at or below 1.5 over 50 years.
- **AC-ID-74** [Integration] Rarity. At most 5 % of records are rank 5 or 6.
- **AC-ID-75** [Integration] Market herbs. Random stock never holds Hoàng Tinh Sâm, Kim Tủy Quả, Anh Tâm Liên or Hóa Thần Quả.
- **AC-ID-76** [Integration] Margin. No recipe outside the shipped list is below 1. Tĩnh Tâm Đan at 0.85 is the accepted baseline.
- **AC-ID-77** [Integration] Control. At most 25 % of equipped artifacts are ones their owner cannot control.

**UI (Debug Terminal first; transcript or screenshot in `production/qa/evidence/debug-terminal/`)**

- **AC-ID-78** [UI] Inventory. Given a character holding every kind, a retained transcript shows items grouped by category, with Mạch Ấn under both of its categories, each with rarity and value. Filtering by category, tag and rarity each narrows the list.
- **AC-ID-79** [UI] Item detail. A retained transcript shows the `describe` line, categories, tags, rarity, value and any Breakdown, with a numbered action for each granted action. A bound item shows that it cannot be traded.
- **AC-ID-80** [UI] Equip panel. Given FX-E, a retained screenshot shows the pieces, slots used and cap, thần thức 80 of 100 and each role. FX-L's unequip shows the preview.
- **AC-ID-81** [UI] Use preview. Given Linh Căn Quả, the transcript shows the effect and choice. Backing out leaves every record unchanged.
- **AC-ID-82** [UI] Visual requirements. With colour switched off, every rarity still reads as a word (Open Question 13).
- **AC-ID-83** [UI] Game Feel. Given Hoàng Tinh Sâm at age 40, the transcript shows age 40, value 40, and at the next doubling age 80, potency 2.5, value 50.

## Open Questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | Confirm the bound and reserved flags (rule 13) and the rule 12 removal preview, both added from other GDDs' needs | user | Rules 12, 13 |
| 2 | Artifact value runs 0.75× to 6× the realm's stone cap. Left as built (user decision 2026-11-06); revisit after the first wealth measure | economy-designer, Balance Harness | Formulas F, H |
| 3 | Where do Mạch Ấn keys come from, and how many does a life find (Meridian Map Open Question 13)? | user | Rule 13 |
| 4 | Should any herb have an edible effect? Rule 4 allows it, and no herb has one in data yet | user | Content pass |
| 5 | Item records at world scale: should ordinary items of dead NPCs be removed, and when? The measure in Formulas H has no data behind it yet | world-builder, Living World | Rule 18 |
| 6 | Herb rarity means scarcity and artifact grade means power, yet they share one ladder. The ladder fits today only because the caps align; a retune of one kind may need an exception | economy-designer | Formulas A, F |
| 7 | Which pill effects are timed (Character Stats rule 12 lists them), and where is the timer held? | systems-designer | Rule 12 |
| 11 | The action interface: its signature, how a call is known to be automatic, and which log a refusal goes to. It may need an ADR | gameplay-programmer | Rule 4, AC-ID-37, 38, 40 |
| 12 | What counts as a "risk" that needs a use preview (rule 12), since every pill adds toxicity | game-designer | Rule 12 |
| 13 | The six rarity rank names, and which rank is announced on finding an item | writer, game-designer | AC-ID-82, Game Feel |
| 14 | What Formulas H means by drift and unrestricted recipes, whether windows roll, and whether NPCs count | economy-designer | AC-ID-71 to 77 |
| 15 | A reserved manual keeps its flag after purchase; if the player sells it, nothing reissues it. Should it? | systems-designer | Cultivation Techniques rule 18 |
| 16 | Mạch Ấn opens the nearest sealed cluster in code, while rule 13 calls it bound to its cluster (Meridian Map Open Question 19) | systems-designer | Rule 13 |
| 8 | Ward, body and utility roles beyond the 9 built bases, and new equippables Combat needs | game-designer | Content pass, Combat |
| 9 | All Formulas H thresholds, `weapon_min` and `ward_max` are guesses | economy-designer | Formulas E, H |
| 10 | **To do (user 2026-11-06):** add more items to the game, authored by hand rather than generated. Today there are 10 herbs, 12 recipes, 8 materials, 9 artifact bases, 4 talismans and 2 treasures | user, game-designer | Content pass, Combat |

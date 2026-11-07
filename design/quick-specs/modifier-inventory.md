# Modifier and Effect Inventory

> **Status**: Working list, 2026-11-07. Input for the Modifier System GDD (`design/gdd/modifiers.md`, not yet created).
> **Nothing here is adopted.** Overnight entries are proposals to filter (systems-index build design order).
> **Generated**: rerun `tools/design/modifier_inventory.py` (usage in its docstring), never hand-edit. Groups,
> types, breadth and reads are keyword guesses; about one entry in ten may sit in a debatable place.

## Two concepts

- **Modifier**: a plain number on a stat, "+X to something" or "X % increased / more something". It may be
  narrowed by tags (Fire, sword, arts, qi hits) but has no condition and no rule of its own. Modifiers are what
  stacks: they add inside a layer and multiply across layers (Combat Formulas B).
- **Effect**: anything with a rule in it. A condition, scaling, a trigger, a conversion, an overflow or a rule
  change; the heavy kinds are keystones and enablers. An Effect usually grants Modifiers as its payload:
  "+12 % sword damage while linh lực is above 50 %" is a Conditional Effect whose payload is the Modifier
  "+12 % sword damage".
- Statuses (burns, poisons, curses) keep their own name, so "effect" never means a status.

| | Modifiers | Effects |
|---|---|---|
| Live | 43 | 34 |
| Designed | 2 | 0 |
| Idea | 29 | 53 |
| Proposal | 121 | 274 |
| **Total** | **195** | **361** |

*Live* in game data · *Designed* in a GDD, not built · *Idea* in the Nov 6 tree catalogue · *Proposal* from the
overnight run. Sources: `assets/data/character_stat_labels.json` and the files that use its keys, `combat.md`
§ Parameter keys, `meridian_capabilities.json`, `design/quick-specs/tree-modifier-catalogue.md`, and the
overnight `summary/1-modifiers.md` and `2-techniques-and-effects.md` § Enablers. 624 entries read, 556 after merging.

## Part 1: Modifiers

Grouped by the stat they change. Rows that are the same modifier on a different tag are folded into one
**template** (`<tag> art cost`), with the tags seen so far. **Breadth** answers the Meridian Map question:
*universal* helps every build, *family* a broad group (an element, arts, soul), *narrow* a few.

| Group | Modifiers | Universal | Family | Narrow |
|---|---|---|---|---|
| [Damage: general](#damage-general) | 6 | 6 | 0 | 0 |
| [Damage: element](#damage-element) | 13 | 0 | 13 | 0 |
| [Damage: arts, basic attack, forms, kinds](#damage-arts-basic-attack-forms-kinds) | 15 | 0 | 7 | 8 |
| [Crit, accuracy and pierce](#crit-accuracy-and-pierce) | 10 | 5 | 0 | 5 |
| [Speed and tempo](#speed-and-tempo) | 10 | 1 | 5 | 4 |
| [Linh lực: cost, reservation, payment](#linh-lc-cost-reservation-payment) | 6 | 0 | 4 | 2 |
| [Linh lực: pool and regeneration](#linh-lc-pool-and-regeneration) | 3 | 3 | 0 | 0 |
| [Ward](#ward) | 9 | 7 | 2 | 0 |
| [Body guard](#body-guard) | 2 | 1 | 1 | 0 |
| [Health and healing](#health-and-healing) | 4 | 3 | 0 | 1 |
| [Evade](#evade) | 1 | 1 | 0 | 0 |
| [Soul and thần thức](#soul-and-thn-thc) | 5 | 1 | 3 | 1 |
| [Statuses, ticks and curses](#statuses-ticks-and-curses) | 22 | 7 | 6 | 9 |
| [Companions and beasts](#companions-and-beasts) | 4 | 0 | 0 | 4 |
| [Artifacts and gear](#artifacts-and-gear) | 8 | 4 | 3 | 1 |
| [Preparation: formations, talismans, pills, ground](#preparation-formations-talismans-pills-ground) | 15 | 2 | 2 | 11 |
| [Slots and loadout](#slots-and-loadout) | 1 | 0 | 0 | 1 |
| [Escape](#escape) | 1 | 1 | 0 | 0 |
| [Fortune](#fortune) | 1 | 1 | 0 | 0 |
| [Mass battle](#mass-battle) | 3 | 2 | 0 | 1 |
| [Life and cultivation](#life-and-cultivation) | 6 | 6 | 0 | 0 |
| [Crafting and economy](#crafting-and-economy) | 10 | 9 | 0 | 1 |
| [Attributes (thiên phú)](#attributes-thin-ph) | 6 | 6 | 0 | 0 |
| [Other rules](#other-rules) | 4 | 2 | 0 | 2 |

### Damage: general

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **attack** (Công Lực) `attack_pct` |  | attack (pct) | universal | Live | catalogue, game data, overnight · 1 build |
| **Damage over time** (Trì Thương) | status | +2% / +12% | universal | Idea | catalogue, overnight · 2 builds |
| **Deep Bite** (Thâm Thực) |  | +10% | universal | Proposal | overnight · 1 build |
| **Good Fit** (Vừa Người) |  | +10% | universal | Proposal | overnight · 1 build |
| **Power share** (Phân Lực) | soul companion | +0.5points / +3points | universal | Proposal | overnight · 1 build |
| **Split Hit Damage** (Phân Kích Thương) |  | +2 / +12 | universal | Proposal | overnight · 1 build |

### Damage: element

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **On the Beat** (Hợp Tiết) | element art | More damage on an art that fires in the same millisecond as… | family | Idea | catalogue |
| **Bright Steel** (Minh Cương) | metal element | +12% | family | Proposal | overnight · 1 build |
| **Cold Edge** (Hàn Phong) | water element art body | +2points / +12points | family | Proposal | overnight · 1 build |
| **<tag> damage** (template) | earth, fire, lava, metal, water, wood | +2% / +12% | family | Proposal | overnight · 6 build uses |
| **Full Bellows** (Mãn Bễ) | fire element art | +12points | family | Proposal | overnight · 1 build |
| **Green Heart** (Thanh Tâm) | wood element | +12% | family | Proposal | overnight · 1 build |
| **Honed Edge** (Ma Lợi) | metal element art | +2points | family | Proposal | overnight · 1 build |
| **living <tag>** (template) | wood | +2points | family | Proposal | overnight · 1 build uses |
| **Red Heart** (Xích Tâm) | fire element | +12% | family | Proposal | overnight · 1 build |
| **Settled Weight** (Trầm Trọng) | earth element art | +2points / +12points | family | Proposal | overnight · 1 build |
| **Thin Stream** (Tế Lưu) | water element art | +2points / +12points | family | Proposal | overnight · 1 build |
| **Banked Heat** (Uẩn Nhiệt) | fire element art | +30points | family | Proposal | overnight · 1 build |
| **Overcoming Stroke** (Khắc Kích) | element art | +60points | family | Proposal | overnight · 1 build |

### Damage: arts, basic attack, forms, kinds

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **Art damage** (Pháp Thương) | art | +1.5% / +10% | family | Idea | catalogue, overnight · 2 builds |
| **<tag> damage** (template) | basic attack, body, sword | +2% / +12% | family | Idea | catalogue, overnight · 7 build uses |
| **Blood Stroke** (Huyết Kích) | art | +2points / +12points | family | Proposal | overnight · 1 build |
| **Heavy Note** (Trọng Âm) | art | +20 | family | Proposal | overnight · 1 build |
| **Many Streams** (Đa Lưu) | art | +20 | family | Proposal | overnight · 1 build |
| **Patient Art** (Nại Pháp) | art | +1.5points / +10points | family | Proposal | overnight · 1 build |
| **Slow Art Damage** (Hoãn Pháp Thương) | art | +3 / +15 | family | Proposal | overnight · 1 build |
| **tolled <tag>** (template) | seal |  | narrow | Idea | catalogue |
| **Long Flight** (Trường Phi) | art weapon_form | +2points / +12points | narrow | Proposal | overnight · 1 build |
| **Copied Art Damage** (Sao Pháp Thương) | art | +20 | narrow | Proposal | overnight · 1 build |
| **Dark Ink** (Nùng Mặc) | art | +50points | narrow | Proposal | overnight · 1 build |
| **Fine Needling** (Tinh Châm) | art weapon_form | +20points | narrow | Proposal | overnight · 1 build |
| **Full Title** (Toàn Hiệu) | art weapon_form | +40points | narrow | Proposal | overnight · 1 build |
| **long <tag>** (template) | rope | +40points | narrow | Proposal | overnight · 1 build uses |
| **reed <tag>** (template) | song | +60points | narrow | Proposal | overnight · 1 build uses |

### Crit, accuracy and pierce

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **accuracy** `accuracy_pct` |  | accuracy (pct), Combat Parameter keys | universal | Live | Combat GDD, catalogue, overnight · 2 builds |
| **crit chance** (Bạo Suất) `crit_chance_pct` |  | crit chance (pct), Combat Parameter keys | universal | Live | Combat GDD, catalogue, overnight · 1 build |
| **crit damage** `crit_damage_pct` |  | crit damage (pct), Combat Parameter keys | universal | Live | Combat GDD, catalogue, overnight · 3 builds |
| **realm pierce** `pierce_pct` |  | realm pierce (pct), Combat Parameter keys | universal | Live | Combat GDD, catalogue, overnight · 3 builds |
| **True Line** (Chân Tuyến) |  | +3% | universal | Proposal | overnight · 1 build |
| **Crit chance with swords** | weapon_form | +0.8% / +5% | narrow | Idea | catalogue, overnight · 1 build |
| **crit chance on <tag> hits** (template) | body | +0.8% / +5% | narrow | Proposal | overnight · 1 build uses |
| **crit chance with <tag>** (template) | fire, water | +0.8% | narrow | Proposal | overnight · 2 build uses |
| **long <tag>** (template) | needle | +3% | narrow | Proposal | overnight · 1 build uses |
| **White Point** (Bạch Điểm) | fire element weapon_form | +5% | narrow | Proposal | overnight · 1 build |

### Speed and tempo

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **First firing comes sooner** |  | −2% / −12% | universal | Idea | catalogue, overnight · 2 builds |
| **art speed** (Tấn Pháp) `art_speed_pct` | art | art speed (pct), Combat Parameter keys | family | Designed | Combat GDD, catalogue, overnight · 1 build |
| **<tag> art speed** (template) | fire, healing, poison, sword, water, wood | +1% / +6% | family | Idea | catalogue, overnight · 6 build uses |
| **Quick Draught** (Cấp Phong) | fire element art | +6% | family | Proposal | overnight · 1 build |
| **Quick Shoot** (Tấn Manh) | wood element art | +6% | family | Proposal | overnight · 1 build |
| **Rush Order** (Cản Đơn) | water art | +50% | family | Proposal | overnight · 1 build |
| **<tag> speed** (template) | basic attack | +1% / +6% | narrow | Idea | catalogue, overnight · 1 build uses |
| **Between Breaths** (Tức Gian) | art status curse | +6% | narrow | Proposal | overnight · 1 build |
| **Hurrying Word** (Cấp Ngôn) | art status curse | +6% | narrow | Proposal | overnight · 1 build |
| **Quick Tongue** (Tấn Thiệt) | art status curse | +1% | narrow | Proposal | overnight · 1 build |

### Linh lực: cost, reservation, payment

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **art cost** (Tiết Khí) `art_cost_pct` | art | art cost (pct), Combat Parameter keys | family | Live | Combat GDD, catalogue, overnight · 1 build |
| **<tag> art cost** (template) | earth, fire, healing, poison, soul, sword, water, wood | −1% / −6% | family | Idea | catalogue, overnight · 8 build uses |
| **dry <tag>** (template) | wood | -6% | family | Proposal | overnight · 1 build uses |
| **Thin Leaf** (Bạc Diệp) | wood element art | -6% | family | Proposal | overnight · 1 build |
| **Small Word** (Tiểu Ngôn) | art status curse | +2.5% | narrow | Proposal | overnight · 1 build |
| **Thrifty Word** (Tiết Ngôn) | art status curse | -1% | narrow | Proposal | overnight · 1 build |

### Linh lực: pool and regeneration

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **linh lực** (Linh Hải) `linh_luc_pct` |  | linh lực (pct) | universal | Live | catalogue, game data, overnight · 3 builds |
| **linh lực regeneration** (Hồi Khí) `linh_luc_regen_pct` |  | linh lực regeneration (pct), Combat Parameter keys | universal | Live | Combat GDD, catalogue, overnight · 6 builds |
| **Full Trunk** (Mãn Thân) |  | +8% | universal | Proposal | overnight · 1 build |

### Ward

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **defense** `defense_pct` |  | defense (pct) | universal | Live | catalogue, game data, overnight · 6 builds |
| **ward efficiency** (Hộ Hiệu) `ward_efficiency_pct` |  | ward efficiency (pct), Combat Parameter keys | universal | Live | Combat GDD, catalogue, overnight · 6 builds |
| **Burnt Hands** (Thục Thủ) | fire element status | +12% | universal | Proposal | overnight · 1 build |
| **Green Wall** (Thanh Bích) | wood metal element | +12% | universal | Proposal | overnight · 1 build |
| **Slow Sap** (Hoãn Dịch) |  | +8% | universal | Proposal | overnight · 1 build |
| **Tempered** (Tôi Hỏa) | fire metal element | +12% | universal | Proposal | overnight · 1 build |
| **Strong Decoction** (Nùng Thang) |  | +0.3 | universal | Proposal | overnight · 1 build |
| **ward strength against <tag>** (template) | earth, fire, water, wood | +2% / +12% | family | Idea | catalogue, overnight · 5 build uses |
| **ward strength against <tag> hits** (template) | body, qi | +1.5% / +10% | family | Proposal | overnight · 2 build uses |

### Body guard

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **body guard** (Hộ Thể) `body_guard_pct` | body | body guard (pct), Combat Parameter keys | universal | Live | Combat GDD, catalogue, overnight · 4 builds |
| **<tag> guard against <tag> hits** (template) | body | +2% / +12% | family | Idea | catalogue, overnight · 2 build uses |

### Health and healing

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **khí huyết** (Trọng Thể) `khi_huyet_pct` |  | khí huyết (pct) | universal | Live | catalogue, game data, overnight · 6 builds |
| **Old Bark** (Lão Bì) |  | +6.5% | universal | Proposal | overnight · 1 build |
| **Tough Grain** (Kiên Văn) |  | +6.5% | universal | Proposal | overnight · 1 build |
| **<tag>** (template) | healing | +2% / +12% | narrow | Proposal | overnight · 1 build uses |

### Evade

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **evade** (Thiểm Tị) `evade_pct` |  | evade (pct), Combat Parameter keys | universal | Live | Combat GDD, catalogue, overnight · 1 build |

### Soul and thần thức

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **thần thức** (Thần Thức) `than_thuc_pct` | soul | thần thức (pct) | universal | Live | catalogue, game data, overnight · 1 build |
| **soul resistance** (Kháng Hồn) `soul_res_pct` | soul | soul resistance (pct), Combat Parameter keys | family | Live | Combat GDD, catalogue, overnight · 1 build |
| **<tag> attack damage** (template) | soul | +1.5% / +10% | family | Idea | catalogue, overnight · 1 build uses |
| **Fine Point** (Tiêm Điểm) | art soul | +2% / +12% | family | Proposal | overnight · 1 build |
| **Shorter `soul_lockout`, `escape_channel`** | soul | −0.1 | narrow | Idea | catalogue |

### Statuses, ticks and curses

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **status resistance** (Kháng Độc) `status_resist_pct` | status | status resistance (pct), Combat Parameter keys | universal | Live | Combat GDD, catalogue, overnight · 4 builds |
| **Status chance** (Nhiễm Suất) | status | +1% / +6% | universal | Idea | catalogue, overnight · 2 builds |
| **Status duration** (Trì Cửu) | status | +2% / +12% | universal | Idea | catalogue, overnight · 2 builds |
| **Catching Flame** (Dẫn Hỏa) | fire status | +6% | universal | Proposal | overnight · 1 build |
| **Catching Thorn** (Câu Thích) | status | +6% | universal | Proposal | overnight · 1 build |
| **Complication** (Biến Chứng) | status | +12points | universal | Proposal | overnight · 1 build |
| **long <tag>** (template) | burn | +12% | universal | Proposal | overnight · 1 build uses |
| **<tag> damage** (template) | burn, poison | +2.5% / +15% | family | Idea | catalogue, overnight · 2 build uses |
| **Corpse-Wax Coating** (Thi Lạp) | status poison pill | Prepared tick damage | family | Idea | catalogue |
| **Deep Coals** (Thâm Than) | fire element status | +12points | family | Proposal | overnight · 1 build |
| **Deep Thorn** (Thâm Thích) | wood element status | +12points | family | Proposal | overnight · 1 build |
| **Spread** (Thấm) | status | +1% | family | Proposal | overnight · 1 build |
| **Steeped** (Tẩm Lâu) | status | +6% | family | Proposal | overnight · 1 build |
| **<tag> duration on you** (template) | curse | −2% / −12% | narrow | Idea | catalogue, overnight · 1 build uses |
| **Status stack cap** | status | +1 | narrow | Idea | catalogue |
| **Rot Deepens** (Thi Độc Thâm) | status poison | More tick damage with the poison tag | narrow | Idea | catalogue |
| **Full Weight** (Toàn Trọng) | status curse | +12% | narrow | Proposal | overnight · 1 build |
| **Lingering Word** (Dư Ngôn) | status curse | +2.5% | narrow | Proposal | overnight · 1 build |
| **Long Memory** (Trường Ký) | status curse | +15% | narrow | Proposal | overnight · 1 build |
| **One Thought** (Nhất Niệm) | art status curse | +2.5% | narrow | Proposal | overnight · 1 build |
| **Sharpened Word** (Lợi Ngôn) | status curse | +2% | narrow | Proposal | overnight · 1 build |
| **Slow to Lift** (Nan Giải) | status curse | +15% | narrow | Proposal | overnight · 1 build |

### Companions and beasts

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **<tag> attack speed** (template) | companion | +1.5% / +10% | narrow | Idea | catalogue, overnight · 1 build uses |
| **<tag> damage** (template) | beast, companion, qi | +2% / +12% | narrow | Idea | catalogue, overnight · 4 build uses |
| **Grown Together** (Đồng Trưởng) | companion | +1.5points / +10points | narrow | Proposal | overnight · 1 build |
| **Vow Renewed** (Trùng Thệ) | body companion | +4points / +25points | narrow | Proposal | overnight · 1 build |

### Artifacts and gear

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **pháp bảo attack** (Binh Lực) `artifact_attack_pct` | artifact | pháp bảo attack (pct) | universal | Live | catalogue, game data, overnight · 2 builds |
| **pháp bảo defense** (Giáp Hậu) `artifact_defense_pct` | artifact | pháp bảo defense (pct) | universal | Live | catalogue, game data, overnight · 3 builds |
| **pháp bảo power** (Khí Uy) `artifact_power_pct` | artifact | pháp bảo power (pct) | universal | Live | catalogue, game data, overnight · 1 build |
| **thần thức cost** (Khinh Khí) `than_thuc_cost_pct` | soul | thần thức cost (pct) | universal | Live | catalogue, game data, overnight · 2 builds |
| **element match bonus** `element_affinity_pct` | element | element match bonus (pct) | family | Live | catalogue, game data |
| **Good Steel** (Hảo Cương) | metal artifact | +10% | family | Proposal | overnight · 1 build |
| **Drilled Ranks** (Thao Binh) | artifact | +50 | family | Proposal | overnight · 1 build |
| **flying <tag> attack** (template) | sword | +2% / +12% | narrow | Idea | catalogue, overnight · 1 build uses |

### Preparation: formations, talismans, pills, ground

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **trận pháp strength** `formation_power_pct` | formation | trận pháp strength (pct) | universal | Live | catalogue, game data |
| **Landing Ground** (Độ Khẩu Địa) | formation | +40points | universal | Proposal | overnight · 1 build |
| **Iron-Sand Hand Bath** (Thiết Sa Dục Thủ) | art basic_attack body | +25points | family | Proposal | overnight · 1 build |
| **Whetstone Ash** (Ma Thạch Hôi) | earth artifact | +60 | family | Proposal | overnight · 1 build |
| **pill effect** `pill_effect_pct` | pill | pill effect (pct) | narrow | Live | catalogue, game data |
| **<tag> power** (template) | talisman | +2% / +12% | narrow | Idea | catalogue |
| **<tag> stock** (template) | talisman | +1 | narrow | Idea | catalogue |
| **Ringing Ground** (Hưởng Địa) | art formation | Prepared art damage from a formation | narrow | Idea | catalogue |
| **Empty Stomach** (Không Phúc) | pill | +20% | narrow | Proposal | overnight · 1 build |
| **Good Paper** (Thượng Chỉ) | talisman | +1% / +6% | narrow | Proposal | overnight · 1 build |
| **<tag> art speed** (template) | talisman | +1% / +6% | narrow | Proposal | overnight · 1 build uses |
| **<tag> damage** (template) | talisman | +2 / +12. | narrow | Proposal | overnight · 1 build uses |
| **Sized Paper** (Phàn Chỉ) | art talisman | +30points | narrow | Proposal | overnight · 1 build |
| **Taken Ground** (Chiếm Địa) | formation | A ground holds one formation: the other side's L4 counts at… | narrow | Proposal | overnight · 1 build |
| **whetstone <tag>** (template) | water | +40points | narrow | Proposal | overnight · 1 build uses |

### Slots and loadout

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **Art slot** | art | +1 | narrow | Designed | catalogue |

### Escape

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **Escape chance** | companion | +1% / +6% | universal | Idea | catalogue |

### Fortune

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **cơ duyên frequency** `co_duyen_pct` |  | cơ duyên frequency (pct) | universal | Live | game data |

### Mass battle

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **Rotating Ranks** (Luân Xạ) | status poison | +0.10 | universal | Proposal | overnight · 1 build |
| **Stamped Iron** (Ấn Thiết) | soul | +40 | universal | Proposal | overnight · 1 build |
| **Field Array** (Dã Trận) | formation | The leader's formation adds its L4 to every member of the f… | narrow | Proposal | overnight · 1 build |

### Life and cultivation

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **breakthrough chance** `breakthrough_chance` |  | breakthrough chance (pct) | universal | Live | game data |
| **qi deviation chance** `qi_deviation_pct` |  | qi deviation chance (pct) | universal | Live | game data |
| **thọ nguyên** `lifespan_years` |  | thọ nguyên (years) | universal | Live | game data |
| **tu luyện speed** `cultivation_speed_pct` |  | tu luyện speed (pct) | universal | Live | game data |
| **tâm ma resistance** `tam_ma_resist_pct` |  | tâm ma resistance (pct) | universal | Live | game data |
| **đan độc resistance** (Nại Độc) `dan_doc_resist_pct` | poison pill | đan độc resistance (pct) | universal | Live | game data, overnight · 1 build |

### Crafting and economy

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **herb growth** `herb_growth_pct` |  | herb growth (pct) | universal | Live | game data |
| **linh điền plots** `field_plots` |  | linh điền plots (flat) | universal | Live | game data |
| **luyện khí success** `refining_success` |  | luyện khí success (pct) | universal | Live | game data |
| **luyện đan success** `alchemy_success` | pill | luyện đan success (pct) | universal | Live | game data |
| **mission income** `mission_income_pct` |  | mission income (pct) | universal | Live | game data |
| **travel speed** `travel_speed_pct` |  | travel speed (pct) | universal | Live | game data |
| **Feed cost** (Tiết Liệu) | earth | -2% / -12% | universal | Proposal | overnight · 1 build |
| **Field plots** (Điền Số) |  | +1 | universal | Proposal | overnight · 1 build |
| **Taming chance** (Thuần Thú) |  | +1% / +6% | universal | Proposal | overnight · 1 build |
| **Steady Brush** (Ổn Bút) | talisman | +1% / +6% | narrow | Proposal | overnight · 1 build |

### Attributes (thiên phú)

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **can_cot** `can_cot` |  | can_cot (flat) | universal | Live | game data |
| **dao_tam** `dao_tam` |  | dao_tam (flat) | universal | Live | game data |
| **khi_van** `khi_van` |  | khi_van (flat) | universal | Live | game data |
| **mi_luc** `mi_luc` |  | mi_luc (flat) | universal | Live | game data |
| **ngo_tinh** `ngo_tinh` |  | ngo_tinh (flat) | universal | Live | game data |
| **than_hon** `than_hon` |  | than_hon (flat) | universal | Live | game data |

### Other rules

| Modifier | Scope / tags | Size (small / notable) | Breadth | Status | Source |
|---|---|---|---|---|---|
| **linh khí density** `density_bonus` |  | linh khí density (flat) | universal | Live | game data |
| **Five Courses** (Ngũ Vị Tịch) | art pill | Each firing serves the next loaded course, which keeps ever… | universal | Proposal | overnight · 1 build |
| **Trigger limit** |  | +1 | narrow | Idea | catalogue |
| **Carried Note** (Đới Âm) | element art companion | Tag modifiers on an art you fired this instant also apply t… | narrow | Proposal | overnight · 1 build |

## Part 2: Effects

Grouped by type. **Changes** is what the payload acts on (the same groups as Part 1); **Reads** is what a
condition or scaling looks at.

| Type | Effects | Live | Idea | Proposal | What it is |
|---|---|---|---|---|---|
| [Conditional](#conditional) | 49 | 0 | 4 | 45 | Grants its payload only while something holds (linh lực above 50 %, health below 30 %, a foreseen fight). |
| [Scaling](#scaling) | 95 | 3 | 1 | 91 | Grows with a count (per point of đan độc, per empty slot, per second of the fight), usually to a cap. |
| [Trigger](#trigger) | 31 | 1 | 1 | 29 | When something happens, do something (on a crit, after a knockout, once a fight). |
| [Conversion](#conversion) | 15 | 0 | 0 | 15 | Changes a hit's tags or kind, or makes one quantity count as another. |
| [Overflow](#overflow) | 9 | 0 | 1 | 8 | Uses what a cap clips. |
| [Rule change](#rule-change) | 63 | 5 | 8 | 50 | Changes a rule outright, with no number to stack. |
| [Keystone](#keystone) | 72 | 25 | 37 | 10 | A strong rule with a price. Meridian capabilities are here too. |
| [Enabler](#enabler) | 27 | 0 | 1 | 26 | Opens a channel, a rule or a resource and closes something in exchange; the piece a build is built on. |

**What conditions read** (a fixed list of readable quantities is a candidate GDD rule): own health 14, in-fight events 14, life / years 14, own linh lực 13, slots / loadout 12, element relation 11, attribute 10, heart demon / toxicity 10, owned stat (compile) 10, realm gap 9, enemy linh lực 9, fight time 8, preparation / ground 8, hit tags / kind 3, craft skill 2, enemy health 1.

### Conditional

| Effect | Changes | Reads | What it does | Status | Source |
|---|---|---|---|---|---|
| **Bare Vessel** (Lộ Đỉnh) | Damage: general | enemy linh lực | More hit damage while the enemy has under 5 % linh lực | Idea | catalogue |
| **Damage to an enemy with no linh lực** | Damage: general |  | +2.5 % · notable +15 % | Idea | catalogue, overnight · 5 builds |
| **Damage while above 50 % health** (Toàn Thân) | Damage: general |  | +2 % · notable +12 % | Idea | catalogue, overnight · 2 builds |
| **Damage while below 50 % health** (Sạt Lở) | Damage: general |  | +2 % · notable +12 % | Idea | catalogue, overnight · 2 builds |
| **Bright Blood** (Xích Huyết) | Damage: general |  | +2 points to hits while over the line. · notable +12 points to hits while over the line. | Proposal | overnight · 1 build |
| **Cornered** (Khốn Đấu) | Damage: general | own health | +50 points while your health share is below the enemy's. | Proposal | overnight · 1 build |
| **Longer Breath** (Trường Tức) | Damage: general | own linh lực | +50 points to hits while your linh lực share is more than 10 points above the enemy's. Two grades: a lead of 10 here, a lead of 0 in The Deepest Well… | Proposal | overnight · 1 build |
| **Open Door** (Khai Môn) | Damage: general |  | · notable +15 % damage to an enemy under 5 % linh lực. Catalogue row, read at 5 %. | Proposal | overnight · 1 build |
| **Over the Line** (Quá Tuyến) | Damage: general |  | At load 30 or more, +28 points on hits, and 4 % of maximum health lost at each pulse past ward and guard. | Proposal | overnight · 1 build |
| **Turned Blade** (Đảo Phong) | Damage: general |  | With no hit to deal, half your L1 and L3 points add to body_guard_pct. | Proposal | overnight · 1 build |
| **Bored Shaft** (Toản Tỉnh) | Damage: element |  | Foreseen fights: +25 points to all hits and +0.10 to Water Table, from a shaft sunk at the place of the fight. | Proposal | overnight · 1 build |
| **Heat Held** (Dư Nhiệt) | Damage: element |  | +2.5 points to Fire arts while the enemy is Burning. | Proposal | overnight · 1 build |
| **Keeping Heat** (Trì Nhiệt) | Damage: element |  | · notable +15 points to Fire arts while the enemy is Burning. | Proposal | overnight · 1 build |
| **Set Table** (Thiết Tịch) | Damage: element |  | Foreseen fights: you read the enemy's element at t = 0, and +30 points to arts. | Proposal | overnight · 1 build |
| **Unbroken Glaze** (Toàn Dứu) | Damage: element | own health | +2 points to Earth arts while your health is at 25 % or above. · notable +12 points to Earth arts while your health is at 25 % or above. | Proposal | overnight · 1 build |
| **Unbroken Surface** (Toàn Diện) | Damage: element | own linh lực | +2 points to Water arts while your linh lực is above 5 %. · notable +12 points to Water arts while your linh lực is above 5 %. | Proposal | overnight · 1 build |
| **Borrowed Name** (Mạo Danh) | Damage: arts, basic attack, forms, kinds |  | While the enemy is Unnamed, your art hits gain 75 % of the L2 it lost. | Proposal | overnight · 1 build |
| **First Taste** (Sơ Vị) | Damage: arts, basic attack, forms, kinds | enemy linh lực | +50 points to art hits while the target's linh lực is above 60 %. | Proposal | overnight · 1 build |
| **Running Low** (Cạn Khí) | Damage: arts, basic attack, forms, kinds | own linh lực | +1.5 points to arts while your linh lực is at 50 % or below. The any-art grade of Spent Breath. · notable +10 points to arts while your linh lực is a… | Proposal | overnight · 1 build |
| **Set Jaw** (Giảo Nha) | Damage: arts, basic attack, forms, kinds |  | +2 art damage while the target bears exactly one curse. | Proposal | overnight · 1 build |
| **Short Art** (Đoản Pháp) | Damage: arts, basic attack, forms, kinds |  | +1.5 points to arts with an authored cooldown under 2 s. The rival of Patient Art. · notable +10 points to arts with an authored cooldown under 2 s.… | Proposal | overnight · 1 build |
| **Short Edge** (Đoản Phong) | Damage: arts, basic attack, forms, kinds |  | +2 points to sword arts with an authored cooldown under 2 s. · notable +12 points to sword arts with an authored cooldown under 2 s. | Proposal | overnight · 1 build |
| **Single Grudge** (Độc Oán) | Damage: arts, basic attack, forms, kinds |  | · notable +12 art damage while the target bears exactly one curse. | Proposal | overnight · 1 build |
| **Spent Breath** (Khí Tận) | Damage: arts, basic attack, forms, kinds | own linh lực | +2 points to sword arts while your linh lực is at 50 % or below. · notable +12 points to sword arts while your linh lực is at 50 % or below. | Proposal | overnight · 1 build |
| **Steady Breath** (Bình Tức) | Damage: arts, basic attack, forms, kinds | own linh lực | +1.5 points to arts while your linh lực is at 50 % or above. The any-art grade of Steady Thread. · notable +10 points to arts while your linh lực is… | Proposal | overnight · 1 build |
| **Steady Thread** (Ổn Tuyến) | Damage: arts, basic attack, forms, kinds | own linh lực | +2 points to sword arts while your linh lực is at 50 % or above. · notable +12 points to sword arts while your linh lực is at 50 % or above. | Proposal | overnight · 1 build |
| **Thinning Ward** (Bạc Hộ) | Damage: arts, basic attack, forms, kinds | enemy linh lực | +2 art damage while the enemy has under 50 % linh lực. · notable +12 % art damage while the enemy has under 50 % linh lực. | Proposal | overnight · 2 builds |
| **Unbroken Sentence** (Bất Đoạn) | Damage: arts, basic attack, forms, kinds | enemy linh lực | · notable +10 art damage while the enemy has under 50 % linh lực. | Proposal | overnight · 1 build |
| **Unmoved** (Bất Động) | Damage: arts, basic attack, forms, kinds | own health | +2 points to body hits while your health is at 50 % or above. Unbroken Glaze's key on a wider tag. · notable +12 points to body hits while your healt… | Proposal | overnight · 1 build |
| **Paid in the Ground** (Địa Thường) | Speed and tempo |  | One art's timer runs while you are buried, never below cooldown_min, and the seconds paid are reported. | Proposal | overnight · 1 build |
| **Both Hands** (Song Thủ) | Linh lực: cost, reservation, payment | heart demon / toxicity | While heart demon stands above 50 as a pulse begins, the pool pays two arts that pulse. | Proposal | overnight · 2 builds |
| **Head of Water** (Thủy Đầu) | Linh lực: cost, reservation, payment |  | An art may pay everything above a keep line it names; its coefficient is the art lint's value for what it paid. | Proposal | overnight · 1 build |
| **Plain Blow** (Phàm Kích) | Linh lực: cost, reservation, payment |  | A single hit on a side with no linh lực at all removes at most 8 health before body guard. Ticks and soul are not limited. | Proposal | overnight · 1 build |
| **Priced Above the Sea** (Giá Siêu Hải) | Linh lực: cost, reservation, payment |  | A stone-paid art may have cost_share above 1, and the art lint applies unchanged. | Proposal | overnight · 1 build |
| **Skipped Bill** (Đào Trái) | Linh lực: cost, reservation, payment | life / years | On a Fled result the ledger is not paid in years. It is written in the Creditors' Book against the one who dealt it. | Proposal | overnight · 1 build |
| **Nothing Leaves** (Bất Xuất) | Linh lực: pool and regeneration | element relation | While the ward stands, your statuses on the enemy lose no duration and the enemy does not regenerate. If it cannot be paid it falls for the fight and… | Proposal | overnight · 1 build |
| **Down to the Skin** (Thoát Y) | Ward |  | With no layer left, a wash takes 40 ward strength and efficiency, and you keep your share. | Proposal | overnight · 1 build |
| **Dress Rehearsal** (Diễn Tập) | Evade | preparation / ground | In a foreseen fight the Curtain starts at 2. | Proposal | overnight · 1 build |
| **Clear Head** (Thanh Tỉnh) | Soul and thần thức | own linh lực | +2.5 x_soul while your linh lực is at 30 % or above. · notable +15 x_soul while your linh lực is at 30 % or above. | Proposal | overnight · 1 build |
| **Slackened Soul** (Tùng Hồn) | Soul and thần thức |  | A curse: the defender's thần thức reads 25 % lower against your soul arts for 2 pulses, stacking to 50 %. | Proposal | overnight · 1 build |
| **Unseen Hand** (Ám Thủ) | Soul and thần thức |  | +60 x_soul while at full health. | Proposal | overnight · 1 build |
| **Long Simmer** (Cửu Tiên) | Statuses, ticks and curses |  | · notable +10 points on over-time statuses with an authored duration of 4 or more. | Proposal | overnight · 1 build |
| **Rich Soil** (Phì Thổ) | Statuses, ticks and curses | enemy linh lực | +2 points to both tick caps while the target's linh lực is 50 % or more. | Proposal | overnight · 1 build |
| **Short Stick** (Đoản Hương) | Statuses, ticks and curses |  | Foreseen fights only: time_limit falls by half. | Proposal | overnight · 1 build |
| **Behind the Ward** (Hộ Hậu) | Companions and beasts | own linh lực | +2 points to companion hits while your linh lực is above 25 %. · notable +12 points to companion hits while your linh lực is above 25 %. | Proposal | overnight · 1 build |
| **Full House** (Mãn Tọa) | Preparation: formations, talismans, pills, ground | preparation / ground, hit tags / kind | On ground with the stage tag: +30 points, and the Curtain holds 4. | Proposal | overnight · 1 build |
| **Beneath Notice** (Bất Túc Đạo) | Escape | realm gap | Against a pursuer above you, the escape realm term is +0.05 a realm, not -0.10. | Proposal | overnight · 1 build |
| **Terror** (Kinh Hồn) | Escape | own health | +0.15 escape bonus while the ledger exceeds your health. | Proposal | overnight · 1 build |
| **Rehearsal** (Diễn Tập) | Other rules |  | Foreseen fights only, a prepared item: you choose where both counts of Called Blow start. | Proposal | overnight · 1 build |

### Scaling

| Effect | Changes | Reads | What it does | Status | Source |
|---|---|---|---|---|---|
| **All Eyes** (Chúng Mục) | Damage: general | attribute | Per point of presence above 45: +0.4 crit_chance_pct, +1 crit_damage_pct, +0.5 evade_pct, inside Combat's caps. | Proposal | overnight · 1 build |
| **Bare Rack** (Không Giá) | Damage: general | slots / loadout | +15 points per empty art slot, on arts. | Proposal | overnight · 1 build |
| **Bitter Measure** (Khổ Lượng) | Damage: general | heart demon / toxicity | +1.5 points per đan độc on the poison tag. | Proposal | overnight · 1 build |
| **Carried Tags** (Kiêm Tính) | Damage: general |  | +15 points to a hit per element tag on it. | Proposal | overnight · 1 build |
| **Cook's Hand** (Trù Thủ) | Damage: general | craft skill, hit tags / kind | +4 points per alchemy level on hits with the furnace form. | Proposal | overnight · 1 build |
| **Cracked Perfection** (Liệt Viên Mãn) | Damage: general |  | +0.05 to stage_mult on damage per Gate Scar, past great perfection. | Proposal | overnight · 1 build |
| **Deep Perspective** (Thâm Viễn) | Damage: general |  | · notable +0.1 % smaller per point of ink. | Proposal | overnight · 1 build |
| **Dull Hand** (Độn Thủ) | Damage: general | attribute | attack_pct -0.5 per purity point of the root. | Proposal | overnight · 1 build |
| **Encore** (Tái Diễn) | Damage: general | fight time, in-fight events | +10 points per hit evaded this fight, to +100. | Proposal | overnight · 1 build |
| **Follow Through** (Thuận Thế) | Damage: general | own health, enemy health | +0.02 points per 1 % of the enemy's health missing, to sword arts, so +2 at most. · notable +0.12 points per 1 % of the enemy's health missing, to sw… | Proposal | overnight · 1 build |
| **Foreign Edge** (Dị Phong) | Damage: general | attribute | +0.5 L2 points per purity point on arts naming the graft. | Proposal | overnight · 1 build |
| **Forgotten Face** (Vô Diện) | Damage: general | attribute | +2 per point of presence under 45, up to +60. | Proposal | overnight · 1 build |
| **Given Years** (Tặng Niên) | Damage: general | realm gap, life / years | +2 points per 1 % of your realm's lifespan given away, while the person named lives, in any fight. Two grades: this one on art and basic; The Herd-Ch… | Proposal | overnight · 1 build |
| **Grateful Patients** (Cảm Ân) | Damage: general |  | · notable +1 point per 5 living people you have fought and left alive, to +20. | Proposal | overnight · 1 build |
| **Light Hand** (Khinh Thủ) | Damage: general | heart demon / toxicity | +2 than_thuc_pct per point of heart demon under 30. | Proposal | overnight · 1 build |
| **Long Way Round** (Viễn Lộ) | Damage: general |  | +0.2 to a part's coefficient per conversion it went through. | Proposal | overnight · 1 build |
| **Nothing to Lose** (Vô Sở Thất) | Damage: general | life / years | +10 points for each doubling of the enemy's years left over your own, to +100. | Proposal | overnight · 1 build |
| **Practised Stroke** (Thuần Bút) | Damage: general | fight time, in-fight events | +8 points per firing of the original this fight, to +64. | Proposal | overnight · 1 build |
| **Purse Weight** (Trọng Nang) | Damage: general | realm gap | +30 points per doubling of carried stones above the realm's linh_thach_max, read at the start of a fight, within the L3 cap. | Proposal | overnight · 1 build |
| **Refused Force** (Cự Lực) | Damage: general | fight time | +15 points to hits per health floor held this fight. | Proposal | overnight · 1 build |
| **Reopened** (Tái Liệt) | Damage: general | own health | +0.1 points to hits per 1 % of health missing. · notable +0.6 points to hits per 1 % of health missing. Turned Away's size. | Proposal | overnight · 1 build |
| **Reopened** (Tái Liệt) | Damage: general | own health | +0.6 points to hits per 1 % of health missing. | Proposal | overnight · 1 build |
| **Short Wick** (Đoản Đăng) | Damage: general | life / years | +5 points for each season of lifespan under 40. | Proposal | overnight · 1 build |
| **Shown Face** (Lộ Diện) | Damage: general | attribute | +2 per point of presence above 45, up to +60. | Proposal | overnight · 1 build |
| **Sick Body** (Bệnh Thể) | Damage: general |  | · notable +2 points to hits per status stack on the enemy. | Proposal | overnight · 1 build |
| **Signed and Dated** (Lạc Khoản Niên) | Damage: general |  | +1 L2 on the Signature per point of Blank painted. | Proposal | overnight · 1 build |
| **Unwritten Margin** (Bạch Biên) | Damage: general | hit tags / kind | +12 for each tag family a hit lacks; +72 on a bare hit. | Proposal | overnight · 1 build |
| **Varied Diet** (Tạp Thực) | Damage: general |  | +3 points to hits per different main technique eaten, to +60. | Proposal | overnight · 1 build |
| **Wasting** (Hao Tổn) | Damage: general | enemy linh lực | +0.03 points to hits per 1 % of the enemy's linh lực missing. · notable +0.2 points to hits per 1 % of the enemy linh lực missing. | Proposal | overnight · 2 builds |
| **Fired Clay** (Đào Thể) | Damage: element | owned stat (compile) | +0.1 points to Earth arts per 1 % of body guard you own. Read at compile. · notable +0.6 points to Earth arts per 1 % of body guard you own. Read at… | Proposal | overnight · 1 build |
| **Held Water** (Tàng Thủy) | Damage: element | own linh lực | +0.02 points to Water arts per 1 % of linh lực you hold. · notable +0.12 points to Water arts per 1 % of linh lực you hold, so +12 at full. | Proposal | overnight · 1 build |
| **Load-Bearing** (Phụ Trọng) | Damage: element |  | +1 point to Earth arts per artifact you carry, at most 6. · notable +5 points to Earth arts per artifact you carry, at most 6. | Proposal | overnight · 1 build |
| **Ore Vein** (Khoáng Mạch) | Damage: element | element relation, slots / loadout | +1 point to Metal arts per artifact equipped, 6 at most. Earth generates Metal. | Proposal | overnight · 1 build |
| **Sap Rise** (Dịch Thăng) | Damage: element | owned stat (compile), element relation | · notable +4 points to Wood arts per 1 % of linh lực regeneration bonus, read at compile, 24 at most by regen_cap. | Proposal | overnight · 1 build |
| **Spring Head** (Tuyền Đầu) | Damage: element | owned stat (compile), element relation | +0.5 points to Water arts per 1 % of regeneration you own. Read at compile. · notable +3 points to Water arts per 1 % of regeneration you own. Read a… | Proposal | overnight · 1 build |
| **Stoked** (Thiêm Sài) | Damage: element |  | · notable +3 points to Fire arts per status stack on the enemy, bounded by the stack cap. | Proposal | overnight · 1 build |
| **Thin Ward** (Bạc Hộ) | Damage: element | enemy linh lực | +0.05 points to Fire arts per 1 % of the enemy's linh lực missing. | Proposal | overnight · 1 build |
| **Worn Slope** (Hao Pha) | Damage: element | own health | +0.02 points to Earth arts per 1 % of your health missing. · notable +0.12 points to Earth arts per 1 % of your health missing. | Proposal | overnight · 1 build |
| **Sustained Note** (Dư Âm) | Damage: arts, basic attack, forms, kinds | fight time | More art damage per second of the fight, up to a cap | Idea | catalogue |
| **Bulk Order** (Phê Lượng) | Damage: arts, basic attack, forms, kinds |  | +25 points to an art per full share of its cost. | Proposal | overnight · 1 build |
| **Collector's Seal** (Tàng Ấn) | Damage: arts, basic attack, forms, kinds |  | Each seal takes Blank and adds points to one layer for every hit inside. | Proposal | overnight · 1 build |
| **Crowded Sky** (Mãn Thiên) | Damage: arts, basic attack, forms, kinds |  | · notable +3 art damage per curse on the target. | Proposal | overnight · 1 build |
| **Deep Breath** (Thâm Tức) | Damage: arts, basic attack, forms, kinds | owned stat (compile), element relation | +0.3 points to arts per 1 % regeneration you own. Read at compile. The any-art grade of Spring Head and Sap Rise, at a smaller size because it is wid… | Proposal | overnight · 1 build |
| **Even Streams** (Phân Lưu) | Damage: arts, basic attack, forms, kinds |  | An art hit or basic attack splits into one equal part per base element held, each with that tag. | Proposal | overnight · 1 build |
| **Gorged** (Bão Lôi) | Damage: arts, basic attack, forms, kinds | fight time | +1 point to arts and basic attacks per 1 % of maximum health restored this fight, to +100. | Proposal | overnight · 1 build |
| **Many Forms** (Đa Thức) | Damage: arts, basic attack, forms, kinds | slots / loadout | +1 point to sword arts per sword art slotted. | Proposal | overnight · 1 build |
| **Many Small Ills** (Bách Tiểu Tật) | Damage: arts, basic attack, forms, kinds |  | · notable +5 art damage per curse on the target. | Proposal | overnight · 1 build |
| **Many Threads** (Đa Tuyến) | Damage: arts, basic attack, forms, kinds | owned stat (compile), slots / loadout | +1 point to sword arts per phi_kiem equipped, read at compile. | Proposal | overnight · 1 build |
| **Marked Target** (Tiêu Ký) | Damage: arts, basic attack, forms, kinds |  | +1 art damage per curse on the target. | Proposal | overnight · 1 build |
| **Nibbling Word** (Thực Ngôn) | Damage: arts, basic attack, forms, kinds |  | +1 art damage per curse on the target. | Proposal | overnight · 1 build |
| **Quickened** (Tấn Thế) | Damage: arts, basic attack, forms, kinds | owned stat (compile) | +0.1 points to arts per 1 % art speed you own. Read at compile. · notable +0.6 points to arts per 1 % art speed you own. Read at compile. | Proposal | overnight · 1 build |
| **Rich Seam** (Phú Mạch) | Damage: arts, basic attack, forms, kinds | enemy linh lực | +0.5 points to arts per 1 % the target's maximum linh lực exceeds yours, up to +60. | Proposal | overnight · 1 build |
| **Ring's Weakest** (Hoàn Nhược) | Damage: arts, basic attack, forms, kinds | attribute | +1.5 points to arts per point of your lowest owned element's purity. | Proposal | overnight · 1 build |
| **Ten Thousand Strikes** (Vạn Kích) | Damage: arts, basic attack, forms, kinds | in-fight events | +0.1 to the basic attack's coefficient per power of ten of basic attacks landed this life, up to +0.7. | Proposal | overnight · 1 build |
| **Virulence** (Bệnh Thế) | Damage: arts, basic attack, forms, kinds |  | +40 points to arts per curse on you, or per curse an art held as it fired. | Proposal | overnight · 1 build |
| **Known Gate** (Thức Quan) | Crit, accuracy and pierce |  | +5 pierce per Gate Scar. | Proposal | overnight · 1 build |
| **The Answer** (Hoàn Chiêu) | Crit, accuracy and pierce |  | +0.5 to the crit count for each hit slipped. | Proposal | overnight · 1 build |
| **Fever** (Độc Nhiệt) | Speed and tempo | owned stat (compile), heart demon / toxicity | +1.5 art_speed_pct per point of đan độc at compile. | Proposal | overnight · 1 build |
| **Spare Mind** (Dư Thần) | Speed and tempo |  | +3 % flight speed per 1 % of thần thức left free. | Proposal | overnight · 1 build |
| **Cold Graft** (Hàn Tiếp) | Linh lực: cost, reservation, payment | attribute | Below purity 40, each art naming the graft costs 0.1 % of maximum health per point under 40. | Proposal | overnight · 1 build |
| **The Owed Wait** (Trái Đãi) | Linh lực: cost, reservation, payment | heart demon / toxicity | One season at the landing owed per heart demon spent. Each season paid returns 1 heart demon with decay off; each left unpaid costs 1 Dao heart. | Proposal | overnight · 1 build |
| **The Root Pays** (Căn Phó) | Linh lực: cost, reservation, payment |  | The root pays its purity share of an art's cost, out of purity, at 2 purity per full share of cost. | Proposal | overnight · 1 build |
| **Deep Drink** (Thâm Ẩm) | Linh lực: pool and regeneration |  | · notable +1 % of maximum per second. | Proposal | overnight · 1 build |
| **Spared Breath** (Dư Tức) | Linh lực: pool and regeneration | owned stat (compile) | +0.02 % regeneration per 10 ward efficiency you own. Read at compile, inside regen_cap. · notable +0.12 % regeneration per 10 ward efficiency you own… | Proposal | overnight · 1 build |
| **Spring Vein** (Tuyền Mạch) | Linh lực: pool and regeneration | element relation | · notable +1 % of maximum per second. Water generates Wood. | Proposal | overnight · 1 build |
| **Ancestor's Face** (Tổ Diện) | Health and healing | own health | One mask per dead head. Each fight, each stops one hit sized 8 % of your health or more, whole, with nothing drained. | Proposal | overnight · 1 build |
| **Empty Room** (Không Thất) | Soul and thần thức | slots / loadout | +0.5 x_soul per empty art slot. · notable +3 x_soul per empty art slot. | Proposal | overnight · 1 build |
| **Failing Lamp** (Tàn Đăng) | Soul and thần thức | enemy linh lực | +0.02 x_soul per 1 % of the enemy's linh lực missing. · notable +0.12 x_soul per 1 % of the enemy's linh lực missing. | Proposal | overnight · 1 build |
| **Numb Soul** (Ma Hồn) | Soul and thần thức |  | +8 soul_res_pct per Gate Scar. | Proposal | overnight · 1 build |
| **Held Acres** (Tích Điền) | Statuses, ticks and curses |  | +7 points on over-time statuses per spirit field plot you work (n_plots, 1 to 12). | Proposal | overnight · 1 build |
| **Inured Flesh** (Quán Độc) | Statuses, ticks and curses | heart demon / toxicity | +0.3 status_resist_pct per đan độc. | Proposal | overnight · 1 build |
| **Kept Grudge** (Tàng Hận) | Statuses, ticks and curses | heart demon / toxicity | +1 point on over-time tags per point of heart demon. | Proposal | overnight · 1 build |
| **Full Trough** (Mãn Tào) | Companions and beasts | preparation / ground | +20 points to companion hits per doubling of the year's feed above what is due, to +40. A blind fight keeps it. | Proposal | overnight · 1 build |
| **Long Loyalty** (Trường Trung) | Companions and beasts | owned stat (compile) | +0.4 points to companion hits per 10 loyalty above 50. Read at compile. Loyalty is what feed buys. · notable +2.5 points to companion hits per 10 loy… | Proposal | overnight · 1 build |
| **Opened Guard** (Khai Hộ) | Companions and beasts |  | +1 point to companion hits per curse on the enemy. · notable +5 points to companion hits per curse on the enemy. | Proposal | overnight · 1 build |
| **Still Hand** (Tĩnh Thủ) | Companions and beasts | owned stat (compile), slots / loadout | +0.3 points to companion hits per empty art slot. Read at compile. · notable +2 points to companion hits per empty art slot. Read at compile. | Proposal | overnight · 1 build |
| **Urging Word** (Thôi Ngôn) | Companions and beasts |  | +1 point to companion hits per curse on the enemy. · notable +5 points to companion hits per curse on the enemy. | Proposal | overnight · 1 build |
| **Idle Hands** (Nhàn Thủ) | Artifacts and gear | slots / loadout | +10 to hits with the artifact source tag per empty art slot. | Proposal | overnight · 1 build |
| **pills per luyện đan** | Preparation: formations, talismans, pills, ground |  | pills per luyện đan (flat) | Live | game data |
| **Known Ground** (Thục Địa) | Preparation: formations, talismans, pills, ground | preparation / ground, life / years | +25 points per ground tag at a place where you have lived a full cycle of seasons. | Proposal | overnight · 1 build |
| **Old Bund** (Cựu Đê) | Preparation: formations, talismans, pills, ground | life / years | +0.05 to the coefficient of arts with the formation source tag per 10 years the formation has stood, to +1.0. | Proposal | overnight · 1 build |
| **Past Papers** (Cựu Đề) | Preparation: formations, talismans, pills, ground | attribute, preparation / ground | · notable In a foreseen fight, +1 point per 2 points of comprehension lead, to +30. | Proposal | overnight · 1 build |
| **Pill-Fed** (Đan Dưỡng) | Preparation: formations, talismans, pills, ground | heart demon / toxicity | +1 % return per point of the attacker's pill toxicity, up to +30 %. | Proposal | overnight · 1 build |
| **Signed Paper** (Lạc Khoản) | Preparation: formations, talismans, pills, ground | in-fight events, craft skill | · notable +3 to talismans you drew yourself per talisman skill level. | Proposal | overnight · 1 build |
| **The Blank** (Lưu Bạch) | Preparation: formations, talismans, pills, ground |  | Ink arts are paid in paper at 100 points per share of cost, never in linh lực, and it does not return in a fight. | Proposal | overnight · 1 build |
| **The Clear Line** (Thanh Tuyến) | Preparation: formations, talismans, pills, ground |  | Clean purity is purity -4 per stain: each artifact, pill in effect, art naming another element, or second Way. | Proposal | overnight · 1 build |
| **Warm Hand** (Thủ Nhiệt) | Preparation: formations, talismans, pills, ground | fight time, in-fight events | +0.25 per talisman fired this fight, to +40 with the notable's +1. | Proposal | overnight · 1 build |
| **Catching Hand** (Tiếp Thủ) | Slots and loadout |  | Each empty art slot catches one enemy art hit per fight: the art fires and pays, and its hit deals nothing and drains nothing. | Proposal | overnight · 1 build |
| **Clean Hands** (Tịnh Thủ) | Slots and loadout | slots / loadout | +0.5 % starting colour per empty art slot. | Proposal | overnight · 1 build |
| **Full Sleeve** (Mãn Tụ) | Escape |  | +0.02 escape bonus per doubling of talismans carried above 4, read at the start of a fight. | Proposal | overnight · 1 build |
| **Dull Fortune** (Ngu Phúc) | Fortune | attribute | +1 khi_van per point of comprehension under 50, to +40. | Proposal | overnight · 1 build |
| **tu luyện speed per linh căn element** | Life and cultivation |  | tu luyện speed per linh căn element (pct) | Live | game data |
| **đan độc fading per season** | Life and cultivation |  | đan độc fading per season (flat) | Live | game data |
| **Fine Work** (Tinh Công) | Crafting and economy |  | Coatings you brewed gain 20 % per point of quality, 0 to 3. | Proposal | overnight · 1 build |
| **Losing Face** (Thất Diện) | Attributes (thiên phú) | own health | Presence reads 1.5 lower per 1 % of maximum health missing, for the fight. | Proposal | overnight · 1 build |

### Trigger

| Effect | Changes | Reads | What it does | Status | Source |
|---|---|---|---|---|---|
| **In Step** (Đồng Bộ) | Damage: general |  | +50 points to a hit landing after one of your arts in the same instant. | Proposal | overnight · 1 build |
| **Raw Scar** (Tân Ngân) | Damage: general | preparation / ground | +30 points to hits for 4 seasons after a failed great breakthrough, in any situation, even a blind fight. | Proposal | overnight · 1 build |
| **Slow Wound** (Hoãn Thương) | Damage: general |  | Hit damage past ward and guard enters a ledger. The ledger pays at most dot_pool_cap of maximum health a pulse, after ticks, on its own cap. | Proposal | overnight · 1 build |
| **Still Warm** (Dư Ôn) | Damage: general | in-fight events | For 4 seasons after a knockout, you hold the victim's largest tag-keyed L2 modifier. | Proposal | overnight · 1 build |
| **Late Leaf** (Vãn Diệp) | Damage: element |  | · notable +12 points to Wood arts after the fourth second. | Proposal | overnight · 1 build |
| **Late Hour** (Vãn Thời) | Damage: arts, basic attack, forms, kinds |  | +2 points to arts after the tenth second. The any-art grade of Late Leaf, later and on the same size. · notable +12 points to arts after the tenth se… | Proposal | overnight · 1 build |
| **Linh lực regained on a crit, as a share of maximum** | Crit, accuracy and pierce |  | +0.1 % · notable +0.6 % | Idea | catalogue |
| **Linh lực regained on a crit** | Crit, accuracy and pierce | in-fight events | +0.1 % of maximum on a crit. · notable +0.6 % of maximum on a crit. | Proposal | overnight · 3 builds |
| **Final Clause** (Mạt Khoản) | Speed and tempo |  | Once a fight, if you would go Down, your longest-cooldown art fires in that instant with what it holds. | Proposal | overnight · 1 build |
| **Paid in Seasons** (Quý Thường) | Linh lực: cost, reservation, payment | life / years | Health you lose is restored at the defeat check and burns 1 season per 20 % of maximum health. At 0 seasons you are Down, having acted in that instan… | Proposal | overnight · 1 build |
| **Patronage** (Bảo Trợ) | Linh lực: cost, reservation, payment | own linh lực | When the enemy cannot afford a ready art, you pay its cost, while your pool is above that cost. | Proposal | overnight · 1 build |
| **Scraping the Well** (Quát Tỉnh) | Linh lực: cost, reservation, payment |  | When a drain ward's pool cannot pay what a hit asks, the unpaid linh lực lands on health, past body guard. | Proposal | overnight · 1 build |
| **Someone Else's Problem** (Giá Họa) | Linh lực: cost, reservation, payment | in-fight events, life / years | On a knockout win, the loser pays your Years Owed. | Proposal | overnight · 1 build |
| **Turned Away** (Bế Môn) | Linh lực: cost, reservation, payment |  | At the defeat check, a side at 0 health with an unopened Gate Scar and 15 % of maximum linh lực pays it, opens one scar and stands at 5 % health. One… | Proposal | overnight · 1 build |
| **Usurious Ink** (Cao Lợi Mặc) | Linh lực: cost, reservation, payment |  | When a fee is charged at double, curse: +50 % art cost for 2 pulses. | Proposal | overnight · 1 build |
| **Cold Dew** (Hàn Lộ) | Linh lực: pool and regeneration | in-fight events, element relation | · notable +0.6 % of maximum linh lực regained on a crit. Metal generates Water. | Proposal | overnight · 1 build |
| **Stands Over You** (Hộ Chủ) | Ward | own health | When you go Down, your companion stays on its own health and guard with no ward, and the fight goes on until it falls. Needs loyalty 60 or more. | Proposal | overnight · 1 build |
| **Callus Returns** (Kiển Hoàn) | Body guard | life / years | After 80 seasons have gone from a wick, +1 body guard base for the fight. | Proposal | overnight · 1 build |
| **Cue** (Nhập Tràng) | Body guard | in-fight events | A guard: true in an instant when a hit landed on the double. The art fires in the follow-up instant. | Proposal | overnight · 1 build |
| **Self-Cure** (Tự Y) | Health and healing |  | When a target ruptures, regain 10 % of maximum health. | Proposal | overnight · 1 build |
| **Parting Cut** (Biệt Đao) | Statuses, ticks and curses |  | When you go Down, your statuses run out before the result is final; you do nothing and the winner may cleanse. | Proposal | overnight · 1 build |
| **When the Worst Has Passed** (Bĩ Cực) | Conversion |  | Each roll against you that fails adds its chance to a visible count. At 1.0 the next one lands and the count returns to 0. | Proposal | overnight · 1 build |
| **stealth (when fleeing or hiding)** | Escape |  | stealth (when fleeing or hiding) (flat) | Live | game data |
| **Years at Table** (Thọ Yến) | Realm and suppression |  | A knockout adds 5 % of the victim's years left to your lifespan, up to 3 x the realm's. | Proposal | overnight · 1 build |
| **Between Courses** (Gián Thiện) | Life and cultivation | in-fight events | After a knockout of a cultivator, restore 25 % of missing health and 50 % of missing linh lực. | Proposal | overnight · 1 build |
| **Clean Kill** (Nhất Khẩu) | Life and cultivation |  | A knockout of a cultivator adds 0.10 x their realm's power base x (0.25 + 0.75 x the health share they had when the last instant began). | Proposal | overnight · 1 build |
| **Cut Short** (Đoản Án) | Life and cultivation |  | +1 heart demon after the fight per whole second art speed removed from the art's reading. | Proposal | overnight · 1 build |
| **Dies Later** (Hậu Tử) | Life and cultivation | heart demon / toxicity | When a creditor dies by any hand but yours, the entry is void, heart demon falls by 3, and you claim 1 % of their carried stones per 100 % owed, to 2… | Proposal | overnight · 1 build |
| **Every Blow** (Mỗi Kích) | Life and cultivation |  | +0.3 heart demon per 1 % of maximum health lost to a hit, kept after the fight. | Proposal | overnight · 1 build |
| **The Credit** (Đầu Bài) | Life and cultivation |  | A knockout won with the Curtain up is credited to the role: it feeds no tally of cultivators defeated, and the world records the double. | Proposal | overnight · 1 build |
| **Collected Debt** (Thu Trái) | Crafting and economy | in-fight events | On a knockout, take 10 % of the loser's carried stones. | Proposal | overnight · 1 build |

### Conversion

| Effect | Changes | Reads | What it does | Status | Source |
|---|---|---|---|---|---|
| **Cracked Stone** (Liệt Thạch) | Damage: element | element relation | · notable +12 % Wood damage against an enemy whose ward carries Earth. Wood overcomes Earth. | Proposal | overnight · 1 build |
| **Felling Stroke** (Phạt Mộc) | Damage: element | element relation | · notable +12 % Metal damage against an enemy whose ward carries Wood. Metal overcomes Wood. | Proposal | overnight · 1 build |
| **Kindling** (Dẫn Nhiên) | Damage: element | element relation | · notable +12 % Fire damage while the enemy carries a Wood status. Wood generates Fire. | Proposal | overnight · 1 build |
| **Title Deed** (Địa Khế) | Speed and tempo |  | While a formation you hold title to stands, your arts with an authored cooldown of 6 s or more count as carrying the formation source tag. Sold with… | Proposal | overnight · 1 build |
| **Thrift** (Tiết Dụng) | Ward |  | A quarter of your ward efficiency also counts as art_cost_pct, inside its 50 % limit. | Proposal | overnight · 1 build |
| **Bitter Pearl** (Khổ Châu) | Statuses, ticks and curses |  | Each 10 toxicity the clamp at 100 clips adds a grain for life, to 20. A grain counts as 1 đan độc for Per modifiers. | Proposal | overnight · 1 build |
| **Thin Bleed** (Tế Huyết) | Statuses, ticks and curses |  | On hit, apply a wound named for the piece that carries it: c_tick 0.2, 4 pulses, stacks to 5. Wounds from different pieces are different statuses. He… | Proposal | overnight · 1 build |
| **Unnamed** (Vô Danh Ấn) | Statuses, ticks and curses |  | A curse: the enemy's hits count as having no element or form tags, so their L2 stops for 2 pulses. It carries no tag, so no cleanse matches it. | Proposal | overnight · 1 build |
| **Field Walls** (Điền Thành) | Conversion | preparation / ground | While your formation stands, formation_power_pct also counts as ward strength and efficiency. | Proposal | overnight · 1 build |
| **Hollow Palm** (Không Chưởng) | Conversion |  | 50 % of a basic attack becomes qi, keeping its body tags. | Proposal | overnight · 1 build |
| **Overheat** (Quá Nhiệt) | Conversion |  | Art speed that cooldown_min clips becomes L5 points, 1 for 1, up to +30. | Proposal | overnight · 1 build |
| **Requisition** (Trưng Thu) | Conversion |  | Linh lực burn counts as drain a ward asked for: whatever reads drain also reads your burn. | Proposal | overnight · 1 build |
| **Ring Step** (Hoàn Bộ) | Conversion |  | Up to 100 % of an art hit converts to the next element on the generating cycle, twice. Each part keeps every earlier tag. | Proposal | overnight · 1 build |
| **Given to the Ranks** (Phó Liệt) | Mass battle |  | Half your L1 leaves you and counts as L4 for every member of your force. | Proposal | overnight · 1 build |
| **The Name Arrives First** (Danh Tiên Chí) | Crafting and economy |  | An enemy your tally frightens (5, 20, 50, 200, 1,000 for Qi Refining to Deity) carries an exit that stays shut until a blow of theirs falls on a mask… | Proposal | overnight · 1 build |

### Overflow

| Effect | Changes | Reads | What it does | Status | Source |
|---|---|---|---|---|---|
| **Boiled Over** (Phí Dật) | Damage: general |  | Each L4 point the cap clips on a course adds 0.01 c_tick to a body tick, Scald, for 3 pulses. | Proposal | overnight · 1 build |
| **Still Water** (Tĩnh Thủy) | Linh lực: pool and regeneration |  | Regeneration clipped by a full pool restores health, at half its amount. | Proposal | overnight · 1 build |
| **Broad Back** (Khoan Bối) | Health and healing | in-fight events | Each 1.0 of c_comp the cap clips moves 10 % of each hit on your health to the beast, to 40 %, against its guard. Overkill is not moved. If its wounds… | Proposal | overnight · 1 build |
| **Deep Abscess** (Thâm Ung) | Health and healing |  | Surfeit the cap clips adds to the next Lancing, up to +15 % of health. | Proposal | overnight · 1 build |
| **Running Line** (Phóng Tuyến) | Soul and thần thức |  | The share soul_cap clips shortens the lockout to soul_lockout x soul_cap / raw share, at least 0.1 s. | Proposal | overnight · 1 build |
| **Spillover** (Dật Độc) | Statuses, ticks and curses |  | Tick damage a cap clips burns the target's linh lực, within the qi burn cap | Idea | catalogue |
| **Widening Wound** (Khoát Thương) | Statuses, ticks and curses |  | Half of what dot_pulse_cap clips at a pulse adds to that cap on this target for the rest of the fight, never past distinct statuses x dot_pool_cap. | Proposal | overnight · 1 build |
| **Deep Bund** (Thâm Đê) | Preparation: formations, talismans, pills, ground |  | L4 points past the cap add +0.01 each to formation arts' coefficient. | Proposal | overnight · 1 build |
| **Unspent Rage** (Dư Nộ) | Life and cultivation | heart demon / toxicity | After a fight in which dot_pulse_cap clipped, +1 heart demon. | Proposal | overnight · 1 build |

### Rule change

| Effect | Changes | Reads | What it does | Status | Source |
|---|---|---|---|---|---|
| **Towel Only** (Đơn Cân) | Damage: general |  | Your own L2 to L5 count for nothing. | Proposal | overnight · 1 build |
| **Fire, Water, Wood, Metal or Earth damage** | Damage: element |  | +2 % · notable +12 % | Idea | catalogue |
| **Variant element damage (such as Lava)** | Damage: element |  | +2.5 % · notable +15 % | Idea | catalogue |
| **Living Wood (notable)** (Hoạt Mộc) | Damage: element |  | · notable +12 points to Wood arts. | Proposal | overnight · 1 build |
| **One Ring** (Nhất Hoàn) | Damage: element |  | A bonus to any one element's damage also applies to the other four. | Proposal | overnight · 1 build |
| **Body damage, Qi damage** | Damage: arts, basic attack, forms, kinds |  | +1.5 % · notable +10 % | Idea | catalogue |
| **Returned Force** (Hoàn Lực) | Damage: arts, basic attack, forms, kinds |  | A caught art adds half its c_art to your next basic attack's coefficient. | Proposal | overnight · 1 build |
| **Washing** (Tẩy) | Damage: arts, basic attack, forms, kinds |  | An art with the wash tag zeroes the target's largest of L2 to L5 for the fight, and you add 50 % of it to the same layer. L1 never washes. | Proposal | overnight · 1 build |
| **Called Blow** (Báo Chiêu) | Crit, accuracy and pierce |  | Your crit and evade take no draw: chance adds to a count on each hit, and the hit that fills it to 1 crits or is slipped, and the count falls by 1. | Proposal | overnight · 1 build |
| **Hair's Breadth** (Phân Hào) | Crit, accuracy and pierce |  | · notable +5 % crit chance with Metal. The Sword row with its tag swapped. | Proposal | overnight · 1 build |
| **Cold Feet** (Hàn Túc) | Speed and tempo |  | Escape arts first fire at cooldown_min. | Proposal | overnight · 1 build |
| **Deep Mud** (Thâm Nê) | Speed and tempo |  | A Ground Law: cooldown_min is 3 s on this ground, for both sides. | Proposal | overnight · 1 build |
| **Held at Table** (Lưu Khách) | Speed and tempo |  | A single hit of yours for 20 % of the target's maximum health or more breaks an open escape channel. Cost, cooldown and stock stay spent. | Proposal | overnight · 1 build |
| **Kept Rubbing** (Tàng Bản) | Speed and tempo |  | A Rubbing keeps its last copy between fights and fires it on a 3 s timer at your own cost until it copies something new. | Proposal | overnight · 1 build |
| **Measured Stroke** (Định Trảm) | Speed and tempo |  | Arts with an authored cooldown of 20 s or more cannot be evaded and cannot crit. | Proposal | overnight · 1 build |
| **Standing Water** (Tích Thủy) | Speed and tempo |  | A formation's timer runs from the day it was laid: its arts first fire at the first pulse. | Proposal | overnight · 1 build |
| **Child Steals the Mother** (Tử Đạo Mẫu Khí) | Linh lực: cost, reservation, payment |  | A hit whose element generates your ward's phase is Fed: pass_tag -0.25, the ward pays nothing, and you gain half of what it blocked. | Proposal | overnight · 1 build |
| **Exact Change** (Trảo Tiền) | Linh lực: cost, reservation, payment |  | Overkill on a winning hit refunds that share of its price, up to half. | Proposal | overnight · 1 build |
| **Lien** (Thế Chấp) | Linh lực: cost, reservation, payment |  | Each living entry in your Book reserves 5 % of maximum linh lực, to 30 %. | Proposal | overnight · 1 build |
| **Relapse** (Tái Phát) | Linh lực: cost, reservation, payment |  | Each affliction that comes home refunds 2 % of maximum linh lực. | Proposal | overnight · 1 build |
| **Seen Through** (Thức Phá) | Linh lực: cost, reservation, payment |  | An attacker whose accuracy reaches your evade sees through the double: the Curtain neither fills nor pays for them. | Proposal | overnight · 1 build |
| **Sweet Ward** (Cam Hộ) | Linh lực: cost, reservation, payment |  | A curse may strengthen a ward: pass_raise -0.4, so it blocks more and pays for it. | Proposal | overnight · 1 build |
| **Turned Hand** (Phản Thủ) | Linh lực: cost, reservation, payment |  | A curse: a bearer's hit art still pays and lands on its owner at half strength, through their own ward, at most 25 % of their maximum health. The bas… | Proposal | overnight · 1 build |
| **Years Owed** (Thọ Trái) | Linh lực: cost, reservation, payment |  | At the fight's end each 100 % of maximum health left in the ledger costs 1 % of the realm's base lifespan. | Proposal | overnight · 1 build |
| **Dry Season** (Hạn Quý) | Linh lực: pool and regeneration |  | A Ground Law: regen_base is 0 on this ground, for both sides. | Proposal | overnight · 1 build |
| **Still Sea** (Tĩnh Hải) | Linh lực: pool and regeneration |  | The Slow Wound cap falls by 0.55 x your linh lực share. | Proposal | overnight · 1 build |
| **Ward strength against body hits, or qi hits** | Ward |  | +1.5 % · notable +10 % | Idea | catalogue |
| **Open Sky** (Không Thiên) | Ward |  | Each 1 % of thần thức left free adds 0.6 ward strength. | Proposal | overnight · 1 build |
| **Standard Planted** (Thụ Kỳ) | Ward |  | A ky strike applies a curse: ward pass +30 % for 3 pulses. | Proposal | overnight · 1 build |
| **Unfelt** (Bất Giác) | Ward |  | A part under the line, before the ward, skips the ward. At or over it, the ward works as usual. | Proposal | overnight · 1 build |
| **Talisman not consumed** | Health and healing |  | A used talisman may survive | Live | catalogue |
| **Joy of the Work** (Lạc Nghiệp) | Health and healing |  | Health you restore to the other side counts 3 times as health you restored, for anything that reads it. | Proposal | overnight · 1 build |
| **Weapon efficiency: weapons occupy less thần thức** | Soul and thần thức |  | −1 % · notable −6 % | Idea | catalogue |
| **Shorter soul_lockout** (Tiếp Niệm) | Soul and thần thức |  | · notable -0.1 s soul_lockout. Catalogue one-off, a single notable. Not run. | Proposal | overnight · 1 build |
| **Weapon efficiency** | Soul and thần thức |  | Weapons occupy 1 % less thần thức. · notable Weapons occupy 6 % less thần thức. | Proposal | overnight · 1 build |
| **Lit Wick** (Tàn Đăng) | Statuses, ticks and curses |  | Each pulse of a fight burns a season, whether or not you are struck. | Proposal | overnight · 1 build |
| **Mordant** (Môi Nhiễm) | Statuses, ticks and curses |  | A cleanse leaves half of the colour. | Proposal | overnight · 1 build |
| **Surplus** (Dư Thu) | Statuses, ticks and curses |  | Tick damage the caps clip comes home as linh lực at half its amount, at most 5 % of maximum a pulse. | Proposal | overnight · 1 build |
| **Conversion share** | Conversion |  | Converts more of a hit to another tag | Idea | catalogue |
| **Bluer Than the Plant** (Thanh Ư Lam) | Conversion |  | At 100 % colour their basic attack turns too. | Proposal | overnight · 1 build |
| **Sword, Palm, Seal or Beast damage** | Companions and beasts |  | +2 % · notable +12 % | Idea | catalogue |
| **only one pháp bảo, much stronger** | Artifacts and gear |  | only one pháp bảo, much stronger (flag) | Live | game data |
| **Flown artifact damage** | Artifacts and gear |  | Increased damage on hits with the artifact source tag. | Proposal | overnight · 1 build |
| **Talisman sleeve** | Preparation: formations, talismans, pills, ground |  | One talisman takes no art slot | Idea | catalogue |
| **Folded Corner** (Chiết Giác) | Preparation: formations, talismans, pills, ground |  | The first failed roll of a fight puts its talisman back in stock. | Proposal | overnight · 1 build |
| **Grave Goods** (Tùy Táng) | Preparation: formations, talismans, pills, ground |  | At a handover, half of Eaten Power goes into the ground with the head. With a life eating E, handover power closes on E. | Proposal | overnight · 1 build |
| **Let It Ride** (Thừa Hứng) | Preparation: formations, talismans, pills, ground |  | · notable A talisman that was not consumed fires once more in the same instant. That firing cannot come back. | Proposal | overnight · 1 build |
| **Level Ground** (Bình Địa) | Preparation: formations, talismans, pills, ground |  | A Ground Law: on this ground L2, L3 and L5 count at most 40, 40 and 10, for both sides. | Proposal | overnight · 1 build |
| **Untended Field** (Hoang Điền) | Preparation: formations, talismans, pills, ground |  | Leave the ground for 5 years, or miss upkeep, and Old Bund resets to 0. | Proposal | overnight · 1 build |
| **Magic treasure slot** | Slots and loadout |  | One more artifact equipped | Live | catalogue |
| **Eaten Power** (Thực Lực) | Slots and loadout |  | In a fight, your power term is your realm's power base plus what you have eaten. Realm, suppression and slots do not change. | Proposal | overnight · 1 build |
| **Fights as Itself** (Tự Chiến) | Realm and suppression |  | A companion hits with its own realm's fight unit, stage and suppression gap, not its owner's. c_comp_cap and the owner's M stay. | Proposal | overnight · 1 build |
| **Census** (Hộ Bạ) | Mass battle |  | Mortals may be counted in a force as levy rows. | Proposal | overnight · 1 build |
| **Spear Drill** (Thao Thương) | Mass battle |  | A levy's basic coefficient is 1.3. | Proposal | overnight · 1 build |
| **failed breakthroughs cost no tu vi, half the tâm ma** | Life and cultivation |  | failed breakthroughs cost no tu vi, half the tâm ma (flag) | Live | game data |
| **đan độc no longer weakens pills** | Life and cultivation |  | đan độc no longer weakens pills (flag) | Live | game data |
| **Fair Measure** (Công Lượng) | Life and cultivation |  | 25 % fewer years owed. | Proposal | overnight · 1 build |
| **Spoiled Palate** (Yếm Thực) | Life and cultivation |  | Pills do nothing for you and seclusion adds no cultivation base. Only defeats fill the bar. | Proposal | overnight · 1 build |
| **What They Had Left** (Dư Niên) | Life and cultivation |  | A cultivator you kill and plough in adds the years they had left to one plot. | Proposal | overnight · 1 build |
| **Already Read** (Dĩ Duyệt) | Attributes (thiên phú) |  | A hit from an art that has fired before this fight is cut by half your comprehension lead, as a percentage, to 30 %. | Proposal | overnight · 1 build |
| **Deep Reading** (Tế Độc) | Other rules |  | rho_min is 0.15 for your Rubbings. | Proposal | overnight · 1 build |
| **Measure Taken** (Lượng Thủ) | Other rules |  | An art that has turned never turns twice in that fight. Its owner has corrected their aim. | Proposal | overnight · 1 build |
| **Slag** (Xỉ Hỏa) | Other rules |  | · notable 40 % of Fire hits become Lava and keep their Fire tags. The catalogue's Conversion share one-off. | Proposal | overnight · 1 build |

### Keystone

| Effect | Changes | Reads | What it does | Status | Source |
|---|---|---|---|---|---|
| **Against the Heavens** (Nghịch Thiên) | Damage: general | realm gap | More damage for each realm your enemy is above you → The vượt cấp specialist | Idea | catalogue |
| **Empty Vessel** (Không Khí) | Damage: general |  | The less linh lực you have, the harder you hit → Deliberately burns out | Idea | catalogue |
| **Full Sea** (Mãn Hải) | Damage: general | own linh lực | Bonus damage while linh lực stays above 80 % → Rewards efficient, cheap arts | Idea | catalogue |
| **Head of the Line** (Tiên Phong) | Damage: general |  | Your first slot deals much more, your last slot less → Slot order matters more | Idea | catalogue |
| **Heart Demon's Blade** (Tâm Ma Nhập Đao) | Damage: general |  | Damage rises with your heart demon (tâm ma) (cost: Raises the qi deviation chance) | Idea | catalogue |
| **Mirror Ward** (Kính Hộ) | Damage: general |  | A share of blocked damage is stored and released with your next hit → Defence that attacks | Idea | catalogue |
| **Thorned Skin** (Kinh Bì) | Damage: general |  | Part of the damage body guard stops is returned to the attacker → Punishes fast hitters | Idea | catalogue |
| **Withheld Hand** (Thu Thủ) | Damage: element |  | Your basic attack does not fire. Each time it would, +1.0 c_art to your longest-cooldown art until that art fires. | Proposal | overnight · 1 build |
| **Empty Hand** (Không Thủ) | Damage: arts, basic attack, forms, kinds |  | Every empty art slot strengthens the basic attack → Martial, zero-art build | Idea | catalogue |
| **Focused Mind** (Nhất Tâm) | Damage: arts, basic attack, forms, kinds |  | One fewer art slot, but more damage on the rest → Specialist | Idea | catalogue |
| **Heavy Hand** (Trọng Thủ) | Damage: arts, basic attack, forms, kinds |  | Arts with a cooldown of 5 s or more deal more; arts under 2 s deal less → Few big hits | Idea | catalogue |
| **Sheathed Blade** (Ẩn Phong) | Damage: arts, basic attack, forms, kinds | fight time | An art that waited ready hits harder for each second it waited → Guarded, patient arts | Idea | catalogue |
| **Thousand Cuts** (Thiên Đao) | Damage: arts, basic attack, forms, kinds |  | The reverse: fast arts deal more, slow arts deal less → Many small hits, on-hit effects | Idea | catalogue |
| **Far Distance** (Viễn Cảnh) | Damage: arts, basic attack, forms, kinds |  | An art with the ink tag makes the target smaller by 1 % per point of ink, to 20 %. Size scales fight unit, health and linh lực. Way of Space. | Proposal | overnight · 1 build |
| **Struck Name** (Tước Danh) | Crit, accuracy and pierce | attribute | Capability on a sealed cluster. Art records may carry no tags: a bare hit meets any ward on default pass and drain. Closes crit, all tag-keyed modifi… | Proposal | overnight · 1 build |
| **Flowing Water** (Lưu Thủy) | Speed and tempo |  | A crit shortens your other arts' timers by 0.5 s → Crit chains | Idea | catalogue |
| **Glass Meridians** (Lưu Ly Kinh Mạch) | Speed and tempo |  | Large art speed bonus (cost: Less health and body guard) | Idea | catalogue |
| **Last Stand** (Bối Thủy) | Speed and tempo | own health | Big art speed bonus below 30 % health → Comeback build | Idea | catalogue |
| **Late Bloom** (Hậu Phát) | Speed and tempo | fight time | Art speed rises for every 5 s the fight lasts → Sustain build that outlasts bursts | Idea | catalogue |
| **Soul Pressure** (Thần Uy) | Speed and tempo |  | With a soul twice the enemy's, its first arts fire later → Intimidation | Idea | catalogue |
| **Soul Wound** (Thương Hồn) | Speed and tempo |  | Soul hits briefly lower the enemy's art speed → Soul as control, not damage | Idea | catalogue |
| **Treasure Nurtured Within** (Dưỡng Bảo Nội Thể) | Linh lực: cost, reservation, payment |  | The first equipped treasure costs no divine sense and grows +1% per year, up to +50%. | Live | Meridian capability |
| **Blood Casting** (Huyết Tế) | Linh lực: cost, reservation, payment | own linh lực | Arts cost health when linh lực runs out → Never stops casting, kills itself if careless | Idea | catalogue |
| **First Move** (Tiên Thủ) | Linh lực: cost, reservation, payment |  | Your first art of the fight costs no linh lực → Alpha strike | Idea | catalogue |
| **Along the Thread** (Duyên Tuyến) | Linh lực: cost, reservation, payment |  | On your soul arts, thần thức the defender has bound to artifacts counts at half. You may equip nothing that costs thần thức. Each kill by a soul art… | Proposal | overnight · 1 build |
| **Brush Fee** (Nhuận Bút) | Linh lực: cost, reservation, payment |  | The cost of a copied art is charged to the original's caster, who pays what they have. | Proposal | overnight · 1 build |
| **Shattering Ward** (Toái Hộ) | Linh lực: pool and regeneration | own linh lực | When your linh lực hits 0, the ward bursts for a free hit → Turns a loss of guard into a payoff | Idea | catalogue |
| **Spirit Severing** (Đoạn Linh) | Linh lực: pool and regeneration |  | Your hits also burn the enemy's linh lực → Beats ward builds by starving them | Idea | catalogue |
| **No Ward** (Vô Hộ) | Ward |  | You can never use a ward, but gain a large body guard → Pure thể tu | Idea | catalogue |
| **Twin Wards** (Song Hộ) | Ward |  | A second ward stays up at half strength; breaks "one ward at a time" → Layered resistance | Idea | catalogue |
| **One Drop** (Nhất Tích) | Ward |  | Your first hit leaves 1 % colour. Each pulse colour x (1 + (clean purity - their highest purity) / 50 x spread). That share of their art hits resolve… | Proposal | overnight · 1 build |
| **Slip of the Hand** (Thất Thủ) | Ward |  | Every art that would hit, on either side, first rolls 0.05 + (other's fortune - caster's fortune) x 0.001. A slip resolves on its caster, through the… | Proposal | overnight · 1 build |
| **Blood Commands Spirit** (Huyết Ngự Linh) | Health and healing |  | 20% of vitality counts as spiritual power; below 30% vitality, -20% attack. | Live | Meridian capability |
| **Soul Leaves the Body** (Linh Hồn Xuất Khiếu) | Health and healing | realm gap | Once per realm, survive a death in an event at 5% vitality, losing one stage. | Live | Meridian capability |
| **Iron Marrow** (Thiết Tủy) | Health and healing |  | Body guard rises as health falls → Gets harder to finish | Idea | catalogue |
| **Unyielding Breath** (Bất Khuất) | Health and healing | own health, in-fight events | Once per fight, a killing blow leaves you at 1 health → Reliable escape window | Idea | catalogue |
| **Beast Soul Union** (Thú Hồn Hợp Thể) | Soul and thần thức |  | The strongest spirit beast adds its full combat power instead of half. | Live | Meridian capability |
| **Divided Divine Sense** (Thần Thức Phân Hóa) | Soul and thần thức |  | +1 magic treasure slot and +20% divine sense. | Live | Meridian capability |
| **Burning Life to Break Through** (Thiêu Thọ Phá Cảnh) | Statuses, ticks and curses | realm gap, life / years | After a failed pill attempt, burn 10 years (5% of the realm's lifespan if more) to retry at once. | Live | Meridian capability |
| **Burning Lifespan** (Nhiên Thọ) | Statuses, ticks and curses | own health | Once per fight, a large surge of power when health is low (cost: Years of lifespan) | Idea | catalogue |
| **Five Phases Cycle** (Ngũ Hành Tương Sinh) | Statuses, ticks and curses |  | Arts firing in generating order (Wood, Fire, Earth, Metal, Water) each gain a stacking bonus; breaking the order resets it → Slot order and cooldowns… | Idea | catalogue |
| **Elemental Fist** (Ngũ Hành Quyền) | Conversion |  | The basic attack carries your main element's tags → Basic attack benefits from element bonuses | Idea | catalogue |
| **Turning Phase** (Chuyển Hành) | Conversion | element relation | When an art carrying an element reaches you, your ward's phase becomes what it generates, from your next hit on, and your Ring Steps start there, so… | Proposal | overnight · 1 build |
| **Bonded Spirit** (Linh Khế) | Companions and beasts |  | The companion's hits carry your art speed and your statuses → Beast master | Idea | catalogue |
| **Wounded Beast** (Thương Thú) | Companions and beasts |  | Low vitality before the fight raises damage instead of only hurting you → Fights on while injured | Idea | catalogue |
| **Twin Arms in Harmony** (Song Khí Hợp Bích) | Artifacts and gear |  | Two magic treasures of the same kind work as a pair: +15% attack for the pair. | Live | Meridian capability |
| **Endless Talismans** (Phù Lục Bất Tận) | Preparation: formations, talismans, pills, ground |  | 30% chance a used talisman is not consumed. | Live | Meridian capability |
| **Formation Within a Formation** (Trận Trung Trận) | Preparation: formations, talismans, pills, ground |  | Formations may exceed their maximum by 2 levels; upkeep for those levels x2. | Live | Meridian capability |
| **Last Radiance** (Hồi Quang Phản Chiếu) | Preparation: formations, talismans, pills, ground | realm gap, life / years | With under 5 years of lifespan left, one pill attempt per realm is up to x2, capped. | Live | Meridian capability |
| **Portable Cave Abode** (Động Phủ Tùy Thân) | Preparation: formations, talismans, pills, ground |  | Formations and spirit fields work wherever you are; the field can be tended anywhere. | Live | Meridian capability |
| **Strange Pill Reborn** (Dị Đan Hóa Sinh) | Preparation: formations, talismans, pills, ground |  | A failed brew has a 30% chance of a random lesser pill instead of ash. | Live | Meridian capability |
| **Home Ground** (Địa Lợi) | Preparation: formations, talismans, pills, ground |  | Ground tags always count in your favour → Chooses where to fight | Idea | catalogue |
| **Standing Array** (Thường Trận) | Preparation: formations, talismans, pills, ground |  | Your formation also counts in blind fights → Always-prepared formation master | Idea | catalogue |
| **One Root** (Đồng Căn) | Slots and loadout | slots / loadout | A bonus if every slotted art shares one element → Pure element | Idea | catalogue |
| **Heaven's Favour** (Thiên Quyến) | Escape |  | Once per fight, reroll a failed escape → Fortune build | Idea | catalogue |
| **Child of Fortune** (Khí Vận Chi Tử) | Fortune | realm gap | Once per realm, reroll a failed event check. | Live | Meridian capability |
| **Reading Heaven's Secrets** (Thiên Cơ Diễn Toán) | Fortune |  | See every choice's success and failure outcomes before choosing. | Live | Meridian capability |
| **Concealed Breath** (Liễm Tức Ẩn Thân) | Realm and suppression |  | Others see you two stages lower; hostile events -30% frequency. | Live | Meridian capability |
| **Dao in Dreams** (Mộng Trung Ngộ Đạo) | Life and cultivation |  | Seasons spent travelling also cultivate, at 50% rate. | Live | Meridian capability |
| **Embryonic Breath** (Thai Tức Quy Nguyên) | Life and cultivation |  | Age at three-quarters speed during closed-door cultivation. | Live | Meridian capability |
| **Great Essence-Draining Art** (Hấp Tinh Đại Pháp) | Life and cultivation |  | Defeating a cultivator gives cultivation base worth 5% of the current stage; heart demon +2. | Live | Meridian capability |
| **Heart Demon Turned to Strength** (Tâm Ma Hóa Lực) | Life and cultivation |  | Heart demon above 50 adds attack; qi deviation chance x2. | Live | Meridian capability |
| **Mutation Awakening** (Biến Dị Khai Mở) | Life and cultivation |  | Each completed realm breakthrough gives one more roll to every unowned, non-declined derived variant whose requirement is met. | Live | Meridian capability |
| **Twin Technique Cultivation** (Song Tu Công Pháp) | Life and cultivation |  | A second main method at 50% speed with its full bonuses. | Live | Meridian capability |
| **The Set Day** (Định Nhật) | Life and cultivation | life / years | Once a life, name a kin and a day at most ten years off. Your age jumps to that distance from your cap, theirs falls by half the years given, never b… | Proposal | overnight · 1 build |
| **Blink Mark** (Thuấn Di Ấn) | Crafting and economy |  | Once a year, travel instantly to any visited place. | Live | Meridian capability |
| **Divided Furnace Flame** (Đan Hỏa Phân Lô) | Crafting and economy |  | Brew two recipes in one season. | Live | Meridian capability |
| **Hundred Herbs Kept Alive** (Bách Thảo Tàng Linh) | Crafting and economy |  | Harvested herbs keep aging in the bag at half speed. | Live | Meridian capability |
| **Ten Thousand Beasts, One Heart** (Vạn Thú Đồng Tâm) | Other rules |  | +2 spirit beasts kept; loyalty never drops below 30. | Live | Meridian capability |
| **Echo** (Hồi Âm) | Other rules |  | An art has a chance to fire again at half power. Counts as a trigger, so the trigger budget applies → Combo | Idea | catalogue |
| **Seeing Eye** (Động Sát) | Other rules |  | Reveals more of the enemy's profile while preparing (Combat Open Question 4) → Information as power | Idea | catalogue |
| **Ten Thousand Names** (Vạn Danh) | Other rules |  | Đạo keystone. A bare hit counts as carrying every tag for your own modifiers and none for the enemy's. | Proposal | overnight · 1 build |

### Enabler

| Effect | Changes | Reads | What it does | Status | Source |
|---|---|---|---|---|---|
| **Wash the Dust** (Tẩy Trần) | Damage: general |  | A cleanse aimed at the target. Closes your own L2 to L5. | Proposal | overnight · 1 build |
| **Stele-Rubbing Scripture** (Thác Bi Kinh) | Damage: element |  | Secret art, Thiên giai, Water. Grants Rubbings, arts that take c_art, kind and tags from the enemy art fired that instant. Those slots hold nothing o… | Proposal | overnight · 1 build |
| **Already Waited** (Dĩ Đãi) | Speed and tempo | life / years | At each pulse heart demon pays one art's timer, the next in slot order, at 1 per second left; it fires this instant at its normal linh lực cost. Clos… | Proposal | overnight · 1 build |
| **Recall Banner** (Thu Binh Kỳ) | Speed and tempo |  | Named artifact, ky base. Lifts equip.max_slots; each piece flies on its own timer for no slot and no linh lực. Closes all artifact defence, removes t… | Proposal | overnight · 1 build |
| **Bitter Tithe** (Khổ Thuế) | Linh lực: cost, reservation, payment |  | Poison-tag arts cost đan độc, not linh lực, and what is spent stays gone. Closes: cleansing pills no longer work on you. | Proposal | overnight · 1 build |
| **Seal of Full Payment** (Túc Phó Ấn) | Linh lực: cost, reservation, payment |  | Named artifact, an base. Arts and the ward may be paid in spirit stones; linh lực pays for nothing; carried stones show on your profile; a winner who… | Proposal | overnight · 1 build |
| **The Understudy** (Thế Thân) | Linh lực: cost, reservation, payment |  | Evade is never rolled. Each body or qi hit fills the Curtain by p_evade times min(1, your thần thức / theirs); at 1 or more it pays 1 and the hit lan… | Proposal | overnight · 1 build |
| **Water Table** (Thủy Mạch) | Linh lực: cost, reservation, payment |  | Of the linh lực a target's ward pays for your hit, you gain 0.36, up to your maximum. Closes: your linh lực does not regenerate in a fight. | Proposal | overnight · 1 build |
| **Borne Body** (Tá Thể) | Health and healing | slots / loadout | The side's health, n_body and guard are the first puppet's in slot order, its blow is the companion channel, and when it falls the next walks on at f… | Proposal | overnight · 1 build |
| **Both Sides** (Song Phương Thệ) | Health and healing |  | Arts may restore a share of maximum health. Closes: the same share goes to the other side, and a heal cannot be aimed. | Proposal | overnight · 1 build |
| **The Named Heir** (Lập Tự) | Health and healing | realm gap | A rider on The Set Day: name a disciple, and at death continue as them in the same world, with the Book, the tally and one mask per dead head. Closes… | Proposal | overnight · 1 build |
| **The Tasting Book** (Phẩm Thực Lục) | Soul and thần thức |  | A soul-bound register. Opens Eaten Power and Clean Kill. Closes pills and seclusion for life, through Spoiled Palate. | Proposal | overnight · 1 build |
| **Grave-Silk Shroud** (Liệm Thi Y) | Statuses, ticks and curses | slots / loadout | Opens: A permanent tick from t = 0 with no slot. Closes: 25 % of maximum linh lực reserved | Idea | catalogue |
| **Cut Fuse** (Tiệt Dẫn) | Statuses, ticks and curses |  | A pill rolled in wax acts in a window of the fight, with an onset and length in whole pulses, for +2 toxicity. Closes: doses cannot change, and a bli… | Proposal | overnight · 1 build |
| **Moved Sickness** (Di Bệnh) | Statuses, ticks and curses |  | Curses from your own life have no duration on you. An art with the cleanse tag sends them to the target; when one ends, is cleansed or is pushed out… | Proposal | overnight · 1 build |
| **Sown Field** (Hoạt Lũng) | Statuses, ticks and curses |  | At t = 0 each plot you sow is a permanent tick on the enemy, c_tick 0.04 x the herb's potency. Closes: your basic attack, 1 % of linh lực per plot fo… | Proposal | overnight · 1 build |
| **Feeding-Back Ward** (Phản Bộ Hộ) | Conversion |  | A per-hit ward that also returns blocked damage to the attacker's linh lực, 1.0 per point; past their maximum it becomes Surfeit. | Proposal | overnight · 1 build |
| **Ground Law** (Địa Luật) | Preparation: formations, talismans, pills, ground |  | A laid formation carries one law moving listed Combat keys for one fight, for both sides. Closes: nothing in a blind fight, and the years reset if yo… | Proposal | overnight · 1 build |
| **Lightning Rod** (Thu Lôi) | Preparation: formations, talismans, pills, ground | preparation / ground | A Ground Law: on ground tagged tribulation, every art hit by the other side carries Thunder and no other element, counted as Fire for the cycle. Clos… | Proposal | overnight · 1 build |
| **Open-Door Furnace** (Khai Môn Lô) | Preparation: formations, talismans, pills, ground |  | New artifact base dan_lo, attack 46, defence 20, thần thức 30. Opens Five Courses. Closes: a loaded coating serves nothing else, blind nothing can be… | Proposal | overnight · 1 build |
| **Paid in Advance** (Tiên Phó) | Preparation: formations, talismans, pills, ground |  | A talisman keeps its authored cost for the art lint and pays no linh lực when fired. Closes every art but talismans. | Proposal | overnight · 1 build |
| **Promissory Paper** (Khế Trái Phù) | Preparation: formations, talismans, pills, ground |  | A talisman, stock used up: Slow Wound at share 1.0 for this fight, from the instant it fires. Closes: every fight costs a rare sheet, and with none l… | Proposal | overnight · 1 build |
| **Vow of the Open Hand** (Khai Thủ Thệ) | Slots and loadout | slots / loadout | Catching Hand holds one catch per empty slot and Empty Hand counts every empty slot; any slot that holds an art after the Vow is stained for life and… | Proposal | overnight · 1 build |
| **Census Seal** (Hộ Bạ Ấn) | Mass battle |  | Named an artifact from a mortal throne. Opens levy rows in Formulas K. Closes: no sect will hold you, and each 1,000 levy lost adds +1 heart demon, w… | Proposal | overnight · 1 build |
| **The Copyist's Error** (Sao Ngộ) | Life and cultivation |  | While the Spent Kiln Sutra is main, every great breakthrough attempt fails with no roll, needs no pill and ignores bare_attempt_cap; each failure lea… | Proposal | overnight · 1 build |
| **The Received Years** (Thụ Niên) | Life and cultivation | life / years | The person named on a Set Day, while the giver lives: the years received become a wick that blows and terror burn, and an art's first firing at them… | Proposal | overnight · 1 build |
| **Incense Vow** (Hương Thệ) | Other rules |  | A stalemate is a win when the other side opened the fight. Closes: your hits deal nothing, and you cannot start a fight. | Proposal | overnight · 1 build |


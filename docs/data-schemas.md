# Game data files

Every gameplay number lives here, not in code (coding standard: data-driven values).
Files follow `[system]_[name].json`, keys are `snake_case`, and each file carries
`schema_version`. Godot parses every JSON number as a float; code converts with
`int()` where an integer is meant. Loaded by `src/gameplay/game_data.gd` (`GameData`).

Design source: the GDDs in `design/gdd/` own the values of the files they name
(Spiritual Roots, Character Stats, Realms & Bottlenecks, Cultivation Techniques, Đạo Đồ). Systems with no GDD yet keep first-pass drafts from `design/gdd/game-concept.md`.

| File | What it defines | Read by |
|---|---|---|
| `cultivation_realms.json` | Realm ladder and breakthrough rules | `CultivationRules`, `CombatPower`, `BuildGenerator` |
| `character_attributes.json` | Thiên phú, roll distribution, grade bands, linh căn rolls, element-count curve, derived constants, start values, origins | `CharacterFactory`, `LinhCan`, `CultivationRules`, `CharacterRules` |
| `dao_do_capabilities.json` | The 25 capabilities: tier, parameters, NPC effect | `GameData`, every host system |
| `character_elements.json` | Five elements, their economy roles, the 8 variant roots and their role lines | `LinhCan`, `DaoDoTree`, `StatSheet`, `CharacterRules` |
| `items_herbs.json` | Linh thảo templates and potency curve | `ItemFactory`, `HerbField`, `Alchemy` |
| `items_recipes.json` | Alchemy rules and đan phương | `Alchemy`, `PillEffects`, `Market` |
| `items_artifacts.json` | Pháp bảo grades, tiers, bases, affixes, equip slots, named-item rules | `ItemFactory`, `CombatPower`, `EquipSlots` |
| `items_named.json` | Named artifacts (generated from `design/items/catalogue-*.json` by `tools/design/items/export_named.py`; never hand-edited) | `ItemFactory`, `WorldGenerator` |
| `items_rarity.json` | The shared rarity ladder (kind offsets, pill price bands, `rarity_max`) and Lost-item decay (`lost_decay_years` 30, `lost_decay_rarity_max` 4) | `ItemRarity`, `WorldTicker` |
| `items_cong_phap.json` | Công pháp tiers, name parts, bonus pool | `ItemFactory` |
| `items_materials.json` | Materials (trade goods, future crafting) | `ItemFactory` |
| `dao_do_tree.json` | Đạo Đồ generator: rings, pools, notables, keystones | `DaoDoTree` |
| `world_map.json` | Travel & Map land qi (Formula C inputs, built offline by `tools/design/map/land_qi.py`) and the element-match keys (Formulas A-B) | `LandQi`, `land_qi.py` |
| `world_continent.json` | The authored continent 11 (exported by `tools/design/map/export_continent.py`; never hand-edited): regions, sects, places with their density, danger and qi, routes, arrays, origins, the grid and qi files, `mu` | `ContinentData`, `ContinentGrid`, `LandQi` |
| `map_resources.json` | Travel & Map resource sites, production (Formula H), reserves (Formula I) and the start-reserve choices | `MapProduction`, `WorldBuilder` |
| `economy.json` | Regional Economy & Trade: the money holders' starting values (Formula H: reserves by realm, starting purses, commons pools) | `MoneyLedger`, `WorldBuilder` |
| `world_history.json` | The authored world's history (exported by `tools/design/world/export_world.py`; never hand-edited): sects' start, cast, chronicle and annals, legendary items, territory, hidden slots, tile secrets, famous sites | `WorldBuilder` |
| `map_works.json` | Travel & Map works on the land (Formula J), Formula B's layer caps, the developed ground of settlements and seats, residences and cave-abode costs (Formula M) | `MapWorks`, `LandQi`, `WorldBuilder`, `GameSession` |
| `world_generation.json` | Regions, places, sects, people, NPC builds, history, ticks, texts | `WorldGenerator`, `WorldTicker`, `BuildGenerator`, `GameSession` |
| `world_names.json` | Hán-Việt name parts and personality traits | `BuildGenerator`, `WorldGenerator`, `EventContext` |
| `combat_rules.json` | Chiến lực shares, duel curve, demon beasts | `CombatPower`, `BuildGenerator` |
| `session_actions.json` | Field, missions, market, talk, pills, sects, exploring | `GameSession`, `HerbField`, `Market`, `PillEffects` |
| `events_templates.json` | Random-event chance and offline event templates | `EventTemplateSource`, `GameSession` |
| `events_budgets.json` | The LLM/event budget: every clamp the engine applies | `EventValidator`, `EventContext`, `EventResolver` |
| `events_prompts.json` | LLM system prompts (`{language}` placeholder) | `LlmService`, `Narrator` |
| `services_llm.json` | LLM endpoint defaults (no key; keys come from env or user://) | `LlmService` |
| `session_advisor.json` | Advisor thresholds and menu sizes | `Advisor` |
| `character_stat_labels.json` | Readable names and units of modifier stat keys | `GameData.format_mod` |
| `crafting_refining.json` | Luyện khí: tiers, fuel, success, grades | `Refinery` |
| `crafting_formations.json` | Trận pháp: formations, costs, upkeep | `Formations` |
| `crafting_talismans.json` | Phù lục: talismans, ink, success | `Talismans` |
| `creatures_linh_thu.json` | Linh thú: taming, feeding, loyalty, power share | `BeastKeeper` |
| `items_treasures.json` | Rare treasures (Linh Căn Quả) | `TreasureEffects`, `ItemFactory` |
| `meta_achievements.json` | Thành tựu conditions | `Achievements` |

## Schemas and units

### cultivation_realms.json

Schema 2 (design/gdd/canh-gioi.md Parameter keys). Per realm: `levels` [lo, hi], `climb_total`
(sum of the realm's level costs), `climb_growth` (last cost / first cost), `bottleneck_bar`
(the bar at the realm's last level; null with no next realm), `stage_names` and `stage_curve_groups` (4 entries), `lifespan`, `base_rate`,
`power_base`, `than_thuc_mult`, `khi_huyet_mult`, `linh_luc_base`, `entry_requirement`
({item_tag, base_chance, pill_chance, gate_factor, condition}; condition is null, density_min, tam_ma_max or
insight).
`ladder`: level_cap, stage_power_step, bare_attempt_cap, great_breakthrough_bonus,
small_breakthrough_bonus (per realm, three each), pts_birth, and legacy_tu_vi_required (read only to migrate old saves).
`breakthrough`: pill and talent terms, q_extras_ceiling_pp, failure_insight_pp and _cap,
chance_min/max, failure penalties, vitality_floor. `guard.s_max` feeds Đạo Đồ Formulas E2.

### character_attributes.json
- `thien_phu[]`: `{id, name, desc}` — the six innate stats besides linh căn.
- `roll`: normal distribution `mean`, `sd`, clamped to `min..max`.
- `grade_bands[]`: `{name, max}` — Hạ ≤30, Trung ≤60, Thượng ≤85, Cực phẩm ≤99, Thiên 100.
- `linh_can`: `count_weights` (element count → weight), `purity_mean/sd/min/max`,
  `bien_di_chance_factor` (first-order chance = pa×pb/10000 × factor),
  `bien_di_higher_order_factor` (divided by order−1 for higher orders),
  `bien_di_purity_factor` (purity = geometric mean of parents × factor),
  `bien_di_counts_as_element` (open design question; currently true),
  `max_counted_elements`.
- `element_count_curve`: element count (`"1"`..`"5"`, 5 = 5+) → stage group →
  cultivation speed relative to Đơn linh căn (design: slower early, parity at
  TC trung kỳ for 2–3, TC hậu kỳ for 4, KĐ sơ kỳ for 5+, steep after).
- `derived`: `khi_huyet_per_can_cot`, `than_thuc_per_than_hon`, `dan_doc_max`,
  `tam_ma_max`, `dan_doc_natural_decay` and `tam_ma_natural_decay` (points per season),
  `injury_recovery_pct_per_season` (vitality fraction per season).
- `start`: `age`, `linh_thach`, `tree_points`.
- `origins[]`: `id`, `name`, `desc`, `linh_thach`, `starting_herbs[{herb, age, qty}]`,
  `cong_phap_tier`, `sect` (joins a generated sect), optional `khi_van_bonus`, `stipend_per_year`.

### character_elements.json

`cycle` (generating order), `elements` (name, name_en, role), `tiers` (root names by n_base),
`element_effects` (per-purity roles), `variants` (8, in roll order: id, name, name_en, origin,
requires, desc) and `variant_effects` (per variant: {stat, per_purity}).

### items_herbs.json
- `potency`: `per_doubling` (potency = 1 + k·log2(age/mature)), `max_potency`.
- `herbs[]`: `id`, `name`, `element`, `mature_years`, `base_value` (linh thạch at
  potency 1), `seed_price`, `rarity` 1–5, `desc`.

### items_recipes.json
- `alchemy`: `skill_success_per_level` (% per Đan Đạo level), `ngo_tinh_success_per_point`,
  `min_success`/`max_success` (%), `khi_van_crit_per_point` (crit % per point),
  `crit_extra_yield`, `xp_per_level` (× next level), `max_level`, `fail_xp_fraction`,
  `quality_grade_thresholds` (average ingredient potency for quality rank 0..3).
- `recipes[]`: `id`, `name`, `ingredients[{herb, min_age, qty}]`, `difficulty`
  (success % = 100 − difficulty + bonuses), `min_level` (level 0 may attempt level-1),
  `yield`, `xp`, `toxicity` (đan độc per pill), `price`, `effect`
  (`tu_vi {value, realm_scale}`, `dan_doc`, `tam_ma`, `heal_pct`, `stat {stat, value, max_uses}`,
  `lifespan {value, max_uses}`, `breakthrough {tag}`), `desc`.

### items_artifacts.json
- `grades[]`: `rank` 0–4, `affixes` count, `power_mult`, `value_mult`, `weight`.
- `tiers[]`: per realm — `name`, `power_scale` (attack/defense ×), `value_scale`.
Schema 3 (2026-11-13; item-database.md rules 6, 11, 20, Formulas D). Bases are copied from `design/items/bases.json`,
less its retired `than_thuc_cost`: no piece costs thần thức (rule 11, user decision 2026-11-13).
- `bases[]`: `roles` (weapon, ward_gear, body_gear, utility, ring, necklace), `damage_type`, `attack`, `defense`,
  `base_value`, `weight`.
- `affixes[]`: `word`, `stat`, `min`/`max`, `weight`, optional `element_bound`, optional `exclude_roles` (Liệt and
  Kiên skip rings and necklaces). Linh gives `than_thuc_pct` 7–18 (it lowered a cost before schema 3).
- `element_chance`, `element_match_bonus_pct` (+% power when the item's element is in your root).
- `equip.base_slots` (slot -> count), `equip.slot_roles` (slot -> roles it takes), `equip.extra_slots_by_realm`
  (per realm; any piece), `equip.artifact_slot_sense_step` (1.75: one more extra slot per 1.75 × the realm's reference
  thần thức, no cap) and `equip.sense_ref_talent` (45: the reference is 45 × thần thức per point × the realm's
  `than_thuc_mult`, the `ds_ref` of Combat Defence & Healing), `equip.single_artifact_keystone_mult`. Every slot is free.
  Replaces schema 1's `equip.max_slots`.
- `named.unique_rarity_min` (5), `named.rarity_offset` (artifact rarity = grade + 1), `named.unique_return_years`
  (50), `named.holder_realm_min` (2, Kết Đan: the lowest realm World Generation gives a unique named item to).

### items_named.json

Generated; schema 1. `named[]`: `id`, `name`, `base`, `grade` 1–4, `element` (Ngũ Hành families only), `family`,
`modifiers[]` {`key`, `value`, `scope`}, `effects[]` (Effect names), `arts[]`/`wards[]`/`reserve_arts[]` {`id`, `name`,
`rule`} (stored; the game has no art combat yet), `sources[]`, optional `holder`, `exception`. Only unscoped modifiers
whose key is in `character_stat_labels.json` reach the stat sheet (`ItemStats`).

### items_cong_phap.json

Schema 2 (design/gdd/cong-phap.md Parameter keys). `tiers`: rank, speed_mult, power_mult,
max_realm, layers, layer_cost_mult, bonus_count, value, weight, bonus_budget, seal_seasons.
Global: slots and speed (aux_slots, tech_norm, count_gain, layer_speed_penalty and floor,
beyond_realm_mult, second_main_mult), mastery (mastery_base, trio_cost, layer_weights,
catchup_mult), power and bonuses, harmony, commons (commons_tiers, root_bias, price_base,
price_spread, bonus_pool). `templates`: the authored catalogue (id, name, tier, tech_kind main,
secret or body, names, layers, bonuses, abilities, seal_clusters, origin).

### items_materials.json
- `materials[]`: `id`, `name`, `element`, `base_value`, `rarity`, `desc`.

### dao_do_tree.json

Schema 2 (design/gdd/dao-do.md Parameter keys). Topology (radials_per_sector,
ring_anchor_depths, ring_interior, base_cluster_slots, entry_count_weights, shapes), values
(mark_value_*, stat_weights in W per displayed unit), hidden clusters (cluster_count, size
keys, inner_share, sealed_share, size_realm_gates, cap_min_n, premium), themes and
element_themes, keystones and center_keystone, the variant sector keys, tree_breakthrough_cap,
npc_unseal_share and open_unseals_per_realm. Sealed cluster content is theme-pool filler until
the authored pass (the GDD's Open Question 6).

### world_map.json — land qi and the element match (design/gdd/travel-map.md Formulas A-C)

- `land`: Formula C's inputs, read only by `tools/design/map/land_qi.py`. `cell_km` (6.175, the fine cell),
  `depth_full_km` 555, `blend_radius_km` 222, `density_min`/`density_max` 0.3/2.4. `biomes.<name>`: `id` (the fine
  biome image's value), `profile` (P_b over moc/hoa/tho/kim/thuy, sums to 100), `sig` (signature element or null),
  `sigma` (signature push at full depth, points), `b` (base density), `g_d` (density added at full depth), `x` (base
  danger), `g_x` (danger added at full depth). `features.<name>`: `push` (points per element at the feature's own
  cells; variants sit outside the 100), `reach_km` (R_f), `density` (a_f) or `density_by_grade` (spirit veins),
  `danger` (x_f). `kinds`: place kind -> Formula C's row; `rows.<row>`: `band` and `share_1_4` (the row's targets),
  `o_kind` (density offset, fitted by `land_qi.py --fit`), `danger_cut` (how much a settlement lowers danger, never
  below 1), `fit` false for a row outside the table (blessed lands). `targets`: Formula C's map targets, reported by
  the tool as observations. All numbers are first guesses unless the GDD states them.
- `match`: `match_gain` k 1.0, `match_land_min` 0.8 (floor; no ceiling), `match_unowned_rate` 0.5 (purity only
  from rare sources), and Formula B's stack keys (`match_stack_min`, `match_cap_l3/l2/l1`, `density_cap`,
  `density_cap_l3`, `share_cap_l3/l2/l1`) for the layers still to come.

### world_generation.json
- `regions`, `places_per_region` (`min`/`max`), `place_types[]` (`suffix`, `weight`,
  `density` range = linh khí multiplier, `danger` 1–4, `market`, `bounties`).
- `travel`: seasons per road (`same_region_seasons`, `cross_region_seasons`), `extra_links_per_region`.
- `sects`: count, `alignments[]`, `members_min/max`, `member_archetype_share`.
- `people`: `world_cultivators`, `world_cultivators_min`, `townsfolk_per_town`, `townsfolk_realm_max`,
  `age_min_by_realm[]`, `age_max_lifespan_frac`, `traits_per_person`, `female_chance`,
  `loose_tan_tu_share`.
- `npc_builds`: artifact counts, `cong_phap_tier_per_realm`, skill levels, `archetype_skills`,
  Đạo Đồ greedy scoring (`tree_focus_weight`, `tree_kind_scores`),
  `artifact_root_element_chance`, `archetype_keep_chance`, `leader_realm_min`, `elder_realm_min`.
- `realm_distribution[]`, `archetypes[]` (`elements`, `tree_focus`, `artifact_bases`, `weight`).
- `history`: `years` simulated, `events_per_year`, `event_weights[]`, `legendary_artifacts`,
  `fallen_sects`, `duel_kill_chance`, `founder_realm_range`, `legend_held_chance`,
  `betrayal_rogue_chance`, `texts{type: template}` (Vietnamese; `{a}`, `{b}`, `{s1}`, `{s2}`,
  `{place}`, `{item}`, `{realm}`, `{cause}` placeholders).
- `tick`: `event_chance_per_season` (world duel), `npc_cultivation_seasons_per_stage`,
  `npc_breakthrough_pill_chance_factor`.
- `season_names[]`, `calendar_name`.

### world_names.json
`surnames`, `given_male`, `given_female`, `sect_first`, `sect_suffix`, `regions`,
`place_words`, `traits[{id, name}]`. All original names (no novel IP).

### combat_rules.json
- `power`: `base_offense_share`, `base_defense_share` (of realm base), `cong_phap_share`,
  `khi_huyet_weight`, `linh_luc_weight` (points of chiến lực per point).
- `duel`: `ratio_exponent` k (win = A^k/(A^k+B^k)), `min/max_win_chance`,
  `khi_van_per_point`, `injured_power_floor`.
- `beast`: name parts, `power_mult`.

### session_actions.json
`field` (plots, `seed_rarity_max`, `must_be_home`), `mission` (incomes, realm scale,
injury), `market` (markups, Mị lực price factor, stock sizes and caps), `talk`
(relationship range, `attitude_change_max`, thresholds), `closed_door.max_years`,
`pill` (đan độc divisor, `realm_scale_penalty`, `quality_effect_step`), `explore`
(`loot_linh_thach_frac`, `lost_item_check`), `death`, `sect` (stipends, join rank),
`cultivate.max_seasons_per_command`, `home_place_types`.

### events_templates.json
- `random_event_chance`: `base` + `per_danger` × place danger (+ `explore_bonus`) per season.
- `templates[]`: `id`, `weight`, `place_types[]` (or `any`), optional `requires_sect`,
  `requires_tam_ma`; `npc` (`mode`: none/new/beast/existing_sect/existing_any, `archetype`,
  `realm_offset`); `title`, `text` (placeholders `{npc}` `{npc_realm}` `{npc_history}`
  `{place}` `{sect}` `{region}` `{player}`); `choices[]` with `label`, `check`
  (`none` / `stat {stat, difficulty}` / `combat {enemy: event_npc}`), `always[]`,
  `success{text, effects[]}`, `failure{...}`. Effects use `budget_frac [lo, hi]` for
  linh thạch and tu vi (fraction of the realm budget), `grade_offset` / `tier_offset` for items.

### events_budgets.json — the engine's limits on every event (templates and LLM)
`khi_van_ceiling` (reward ceiling × (base + Khí vận × per_point)), `difficulty` range,
choice/effect counts, text lengths, `allowed_check_stats`, `allowed_effect_types`,
`per_realm{}` maxima (linh thạch gain/loss, tu vi as a fraction of the stage requirement,
artifact grade, herb rarity/age, material rarity, công pháp tier, pill price, khí huyết
loss %, tâm ma, đan độc, relationship, Đạo Đồ points), `check` (stat check chance =
base + (stat − difficulty) × per_point + (Khí vận − neutral) × kv_per_point, clamped),
default item offsets, `npc_realm_offset`, `context` sizes, `free_exit_choice` (label/text of the
free choice the validator adds when every choice of an event costs linh thạch, so a broke
player can never be softlocked).

### events_prompts.json
System prompts for `event_system`, `narrate_system`, `talk_system`, `epitaph_system`;
`{language}` is replaced from `language_names`.

### services_llm.json
`provider`, `base_url`, `path`, `model`, `timeout_sec`, `temperature`, `max_tokens`,
`language`, `key_env_vars[]`, `user_config_path`, `use_for{events, narration, talk, epitaph}`.
**No API key ever goes in this file.**

### session_advisor.json — thresholds for the Advisor (goals and menu)
`lifespan_warning_years`, `lifespan_urgent_years`, `khi_huyet_warning_pct`,
`dan_doc_warning`, `tam_ma_warning`, `low_linh_thach`, `beast_loyalty_warning`,
`invest_affordability_mult` (suggest a formation or refine only with this many times its
cost in hand); `menu`: `cultivate_seasons`, `closed_door_years`, `max_goal_entries`,
`label_max_chars`. Read by `Advisor`.

### character_stat_labels.json — readable names for modifier stat keys
`labels{stat: {name, unit}}`; unit `pct` (+n%), `flat`, `years`, `flag` (name only).
Thiên phú ids use their names from character_attributes.json. Read by
`GameData.format_mod` (đạo văn, biến dị, affixes, công pháp bonuses).

### crafting_refining.json — luyện khí (spec: design/quick-specs/luyen-khi-and-tran-phap.md)
`skill`; per artifact tier arrays `difficulty`, `min_level`, `materials`, `min_rarity`,
`xp`; `fuel_mult` (fuel = base value × tier value_scale × fuel_mult), `success_per_level`,
`kim_success_per_purity`, `ngo_tinh_per_point`, `min/max_success`, `levels_per_grade`
(grade cap = level / levels_per_grade + avg material rarity − 1), `fail_xp_fraction`,
`xp_per_level`, `max_level`. Read by `Refinery`.

### crafting_formations.json — trận pháp
`skill`, `xp_per_level_built`, `xp_per_level`, `max_skill_level`,
`tho_upkeep_cut_per_purity`; `formations[]`: `id`, `name`, `stat`, `per_level`, `applies`
(`home` only while at home / `always`), `max_level`, `cost_lt`, `cost_growth`
(cost = cost_lt × growth^(level−1)), `materials_per_level`, `material_rarity`,
`upkeep_lt_per_level`, `desc`. Read by `Formations`.

### crafting_talismans.json — phù lục (spec: design/quick-specs/phu-luc-linh-thu-thanh-tuu.md)
`skill`, `success_per_level`, `than_hon_per_point`, `than_hon_neutral`, `min/max_success`,
`xp_per_level`, `max_level`, `fail_xp_fraction`; `talismans[]`: `id`, `name`, `use`
(`combat` | `evade`), `stat`, `value` (added for one check), `difficulty`, `min_level`,
`ink_lt`, `materials`, `material_rarity`, `yield`, `xp`, `base_value`, `desc`.
Read by `Talismans`.

### creatures_linh_thu.json — linh thú
`skill`; `tame{base, than_hon_neutral, than_hon_per_point, per_skill_level, min, max}`;
`max_beasts_base`, `than_hon_per_extra_beast`, `power_share` (of the beast's chiến lực
added to the owner), `feed_lt_by_realm[]`, `loyalty{start, max, unfed_loss, fed_gain}`,
`growth_per_skill_level`, `xp_per_tame`, `xp_per_year_fed`, `xp_per_level`, `max_level`.
Read by `BeastKeeper`.

### items_treasures.json — rare treasures used with `use`
`treasures[]`: `id`, `name`, `base_value`, `rarity`, `effect` (`add_element`: `purity`
[min, max] for a new root, `raise` for an owned one), `desc`. Which events may grant one
is `events_budgets.json` per_realm `treasures`. Read by `TreasureEffects`, `ItemFactory`.

### meta_achievements.json — thành tựu
`achievements[]`: `id`, `name`, `desc`, `condition` (`realm` {realm, max_age?, origin?,
min_elements?}, `skill` {skill, level}, `formation` {level}, `beasts` {count},
`bien_di` {count}, `age` {age}, `event` {event type}). Read by `Achievements`.

# Game data files

Every gameplay number lives here, not in code (coding standard: data-driven values).
Files follow `[system]_[name].json`, keys are `snake_case`, and each file carries
`schema_version`. Godot parses every JSON number as a float; code converts with
`int()` where an integer is meant. Loaded by `src/gameplay/game_data.gd` (`GameData`).

Design source for all of this: `design/gdd/game-concept.md` (§ Linh Căn, § Cảnh Giới,
§ Character Stats). Values are first-pass drafts for the debug terminal; the GDDs
written after `/map-systems` own their final tuning.

| File | What it defines | Read by |
|---|---|---|
| `cultivation_realms.json` | Realm ladder and breakthrough rules | `CultivationRules`, `CombatPower`, `BuildGenerator` |
| `character_attributes.json` | Thiên phú, roll distribution, grade bands, linh căn rolls, element-count curve, derived constants, start values, origins | `CharacterFactory`, `LinhCan`, `CultivationRules`, `CharacterRules` |
| `character_elements.json` | Five elements, their economy roles, biến dị definitions | `LinhCan`, `MeridianTree`, `StatSheet`, `CharacterRules` |
| `items_herbs.json` | Linh thảo templates and potency curve | `ItemFactory`, `HerbField`, `Alchemy` |
| `items_recipes.json` | Alchemy rules and đan phương | `Alchemy`, `PillEffects`, `Market` |
| `items_artifacts.json` | Pháp bảo grades, tiers, bases, affixes, equip rules | `ItemFactory`, `CombatPower` |
| `items_cong_phap.json` | Công pháp tiers, name parts, bonus pool | `ItemFactory` |
| `items_materials.json` | Materials (trade goods, future crafting) | `ItemFactory` |
| `meridian_tree.json` | Kinh Mạch Đồ generator: rings, pools, notables, keystones | `MeridianTree` |
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
- `realms[]`: `id`, `name`, `stage_names[]`, `stage_curve_groups[]` (keys into
  `element_count_curve`), `tu_vi_required[]` (tu vi to finish each stage),
  `lifespan` (years of thọ nguyên), `base_rate` (tu vi per season before multipliers),
  `power_base` (chiến lực base at stage 0), `stage_power_step` (+fraction per stage),
  `than_thuc_mult` / `khi_huyet_mult` (realm multipliers), `linh_luc_base`,
  `tree_points_per_stage` (Kinh Mạch points per stage-up and on entry),
  `entry_requirement` (`null`, or `{item_tag, base_chance, pill_chance}` — chances 0..1).
- `breakthrough`: `pill_quality_bonus_per_grade` (+chance per pill quality rank),
  `ngo_tinh_bonus_per_point`, `dao_tam_bonus_per_point` (+chance per point),
  `failure_tu_vi_loss_pct` (fraction lost), `failure_tam_ma_gain` (points),
  `failure_khi_huyet_loss_pct` (fraction of vitality), `backlash_death_tam_ma_threshold`,
  `tam_ma_backlash_divisor` (backlash % = Tâm ma − Đạo tâm / divisor).
- `cultivation`: `no_cong_phap_mult`, `ngo_tinh_divisor` (×(1+Ngộ/divisor)),
  `dan_doc_divisor` (×(1−Đan độc/divisor)), `closed_door_efficiency`, `seasons_per_year`.

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
- `cycle`: tương sinh order (Mộc→Hỏa→Thổ→Kim→Thủy); also the Kinh Mạch sector order.
- `elements{}`: `name`, `ansi` (terminal colour), `word` (name part), `role`, `role_desc`.
- `element_effects`: per purity point — `herb_growth_pct_per_purity` (Mộc),
  `alchemy_success_per_purity` (Hỏa, success % points), `dan_doc_decay_per_purity` (Thủy),
  `field_plots_per_purity` (Thổ), `mission_income_pct_per_purity` (Kim);
  `tree_scale_base` and `absent_element_tree_scale` (Kinh Mạch node scale = base + purity/100,
  or the absent value).
- `bien_di[]`: `id`, `name`, `parents[]` (element or biến dị ids), `order`, `kind`,
  `desc`, `effects[{stat, value, kind}]` (flat stat modifiers).

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
  Thần thức cost scales with the realm's `than_thuc_mult` instead (see `ItemFactory.artifact`).
- `bases[]`: `attack`, `defense`, `than_thuc_cost`, `base_value`, `weight`.
- `affixes[]`: `word`, `stat`, `min`/`max`, `weight`, optional `element_bound`.
- `element_chance`, `element_match_bonus_pct` (+% power when the item's element is in your root),
  `equip.max_slots`, `equip.single_artifact_keystone_mult`.

### items_cong_phap.json
- `tiers[]`: `rank` 0–3 (Hoàng/Huyền/Địa/Thiên), `speed_mult`, `power_mult`,
  `max_realm` (beyond it cultivation ×0.25), `bonus_count`, `value`, `weight`.
- `element_prefixes{}`, `suffixes[]`: name parts; `multi_element_chance`, `multi_element_count`;
  `bonus_pool[{stat, min, max}]`.

### items_materials.json
- `materials[]`: `id`, `name`, `element`, `base_value`, `rarity`, `desc`.

### meridian_tree.json
- `seed` (fixed: the tree is the same every life), `rings`, `nodes_base` + `nodes_growth`
  (nodes per sector ring = base + floor(ring × growth)), `same_ring_link_chance`,
  `notable_rings[]`, `notables_per_ring`, `keystone_ring`, `bridge_rings[]`.
- `root`, `gate_mods`, `small_pools{element|bridge: [{stat, value}]}`,
  `notables{element: [{name, mods}], bridge: [{pair, name, mods}]}`,
  `keystones{element|center: {name, mods, desc, requires_elements?}}`.

### world_generation.json
- `regions`, `places_per_region` (`min`/`max`), `place_types[]` (`suffix`, `weight`,
  `density` range = linh khí multiplier, `danger` 1–4, `market`, `bounties`).
- `travel`: seasons per road (`same_region_seasons`, `cross_region_seasons`), `extra_links_per_region`.
- `sects`: count, `alignments[]`, `members_min/max`, `member_archetype_share`.
- `people`: `loose_cultivators`, `townsfolk_per_town`, `townsfolk_realm_max`,
  `age_min_by_realm[]`, `age_max_lifespan_frac`, `traits_per_person`, `female_chance`,
  `loose_tan_tu_share`.
- `npc_builds`: artifact counts, `cong_phap_tier_per_realm`, skill levels, `archetype_skills`,
  Kinh Mạch greedy scoring (`tree_focus_weight`, `tree_kind_scores`),
  `archetype_element_purity`, `artifact_root_element_chance`, `leader_realm_min`, `elder_realm_min`.
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
loss %, tâm ma, đan độc, relationship, Kinh Mạch points), `check` (stat check chance =
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
`dan_doc_warning`, `tam_ma_warning`, `low_linh_thach`; `menu`: `cultivate_seasons`,
`closed_door_years`, `max_goal_entries`. Read by `Advisor`.

### character_stat_labels.json — readable names for modifier stat keys
`labels{stat: {name, unit}}`; unit `pct` (+n%), `flat`, `years`, `flag` (name only).
Thiên phú ids use their names from character_attributes.json. Read by
`GameData.format_mod` (Kinh Mạch huyệt, biến dị, affixes, công pháp bonuses).

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

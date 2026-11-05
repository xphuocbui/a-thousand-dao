# Character Stats

> **Status**: In Review (2026-11-05: independent review findings applied; cross-GDD review CONCERNS, no blockers). See `reviews/character-stats-review-log.md`.
> **Creative Director Review (CD-GDD-ALIGN)**: skipped (Lean mode)
> **Author**: user + Claude
> **Last Updated**: 2026-11-05
> **Last Verified**: 2026-11-05
> **Implements Pillar**: Pillar 2 (Every Number Is Bounded and Visible), Pillar 3 (Power Is Built, Not Given); touches Pillar 1 (Your Dao, Your Name)

## Summary

Character Stats is the numeric identity of every cultivator. It covers:
- **Innate talents:** six, rolled at birth on 1–100, graded Lower to Heavenly, and
  changed only by capped pills and events.
- **State:** toxicity, heart demon and vitality, which rise and fall each season.
- **Derived values:** divine sense, vitality, spiritual power and the combat power realm
  term, each scaled by realm and stage.

Every bonus from every system lands on one stat sheet with its source, so any number can
be explained. This GDD owns the stat keys, their units and precision, and each
character's capability set.

> **Quick reference** — Layer: `Core` · Priority: `MVP` · Key deps: `Spiritual Roots (Linh Căn), Sim Core, Config`

## Overview

Character Stats is the numeric identity of every cultivator, the player and every NPC
alike. It has three layers.

- **Innate talent (thiên phú).** Six talents rolled at birth on 1–100: comprehension (ngộ
  tính), physique (căn cốt), soul strength (thần hồn), fortune (khí vận), Dao heart (đạo
  tâm) and presence (mị lực). Each is graded from Lower (Hạ) to Heavenly (Thiên). The
  spiritual root (linh căn) sits beside them, but Spiritual Roots owns its rules. Talents
  change only through rare, capped effects: a talent pill limited to a few uses per life,
  or an event.
- **State.** What changes every season: cultivation base (tu vi), age against lifespan
  (thọ nguyên), vitality (khí huyết), pill toxicity (đan độc), heart demon (tâm ma) and
  spirit stones (linh thạch).
- **Derived values.** What the first two produce: divine sense (thần thức), maximum
  vitality, spiritual power (linh lực) and the realm term of combat power (chiến lực). Each
  is a realm base × the stage multiplier × talent and modifiers.

Every modifier from anywhere (root variants and generating pairs, the Meridian Map and
its capabilities, the cultivation technique, magic treasures, consumables and tools,
destiny perks, formations, craft mastery) lands on one stat sheet with its source, so any
total can be explained. Craft mastery (đạo nghệ) levels sit alongside, rise only by
practice, and may add modifiers on their own craft keys (rule 12).

The system exists because every other system speaks through it. It owns the stat keys,
their units and meaning, and the character's capability set. It never decides when stats
rise (Realms & Bottlenecks does) or what a node gives (the Meridian Map does). It carries
two pillars:
- **Pillar 3:** talent is the hand you are dealt, and power is what you build with it.
- **Pillar 2:** every number on the sheet has a visible breakdown.

## Detailed Design

This section documents the system as built in the debug terminal, plus the contracts
Realms & Bottlenecks and the Meridian Map rely on. Open Question 6 lists what is specified
here but not built yet.

### Core Rules

**Innate talent (thiên phú)**

1. **The six talents.** Values are integers.

   | Talent | Key | Drives |
   |---|---|---|
   | Comprehension (ngộ tính) | `ngo_tinh` | Cultivation speed, learning techniques, enlightenment (đốn ngộ), recipes, pill-attempt breakthrough chance |
   | Physique (căn cốt) | `can_cot` | Maximum vitality, body cultivation |
   | Soul strength (thần hồn) | `than_hon` | Divine sense: magic treasure control, detection, formation complexity |
   | Fortune (khí vận) | `khi_van` | Lucky encounters (kỳ ngộ), rare finds, crafting crits, the ceiling of LLM-invented rewards |
   | Dao heart (đạo tâm) | `dao_tam` | Resisting qi deviation; pill-attempt breakthrough chance |
   | Presence (mị lực) | `mi_luc` | NPC attitude, prices, what people share |

2. **Birth.**
   - **Fated birth (Thiên Định):** each talent is rolled from N(`roll.mean`, `roll.sd`),
     rounded and clamped to 1–100.
   - **Self-made birth (Tự Định):** the player sets each talent freely in 1–100 (values
     outside are rejected at input), and achievements are off.
   - An origin may adjust one talent at birth (for example a wandering cultivator gets
     +5 fortune), clamped to 1–100.
3. **Grades.** A talent's base value falls in a grade band: Lower (Hạ) 1–30, Middle
   (Trung) 31–60, Upper (Thượng) 61–85, Supreme (Cực phẩm) 86–99, Heavenly (Thiên) 100.
4. **Permanent change.** The base value changes only through:
   - a talent pill: an effect of type `stat`, limited per life by the recipe's
     `max_uses`; its gain is Formulas D's `talent_gain`;
   - an event effect inside the Event Engine's budget.

   The base value stays clamped to 1–100. Climbing realms never changes it. Root
   variants give modifiers, not base changes.
5. **Effective talent.** Effective value = base + the stat sheet's flat modifiers on that
   talent's key, clamped to 1–150. Every rule that reads a talent reads the effective
   value. The grade shown is the base value's grade.

**State**

6. **State values.** Each is a number held on the character:

   | Value | Range | Owner of its rules |
   |---|---|---|
   | Cultivation base (tu vi) | ≥ 0 | Realms & Bottlenecks |
   | Age | years, +0.25 per season, and #23's burn (Realms rule 18) | Time & Turn |
   | Vitality (khí huyết, current) | a fraction of maximum, above 0 and up to 1.0 while alive (rule 9) | this GDD |
   | Pill toxicity (đan độc) | 0–100, decimal | this GDD |
   | Heart demon (tâm ma) | 0–100, decimal | this GDD |
   | Spirit stones (linh thạch) | integer ≥ 0 | Market |
| Craft mastery (đạo nghệ) | per craft, `skills[id]` = {level, xp}: level an integer from 0 (untrained) to the craft's `max_level` (Alchemy 9), xp ≥ 0. Level n + 1 costs `xp_per_level` × (n + 1) | this GDD stores it; each craft sets its `max_level`, xp and what a level does |

7. **Pill toxicity.**
   - **Gain:** each pill adds its toxicity × (1 − `dan_doc_resist_pct` ÷ 100), with the factor clamped to 0.1–2.0, so negative resistance (a penalty)
     raises the gain.
   - **Effects:** it slows cultivation and weakens pills, unless `dan_doc_no_penalty` is
     held (Formulas).
   - **Decay** each season: the natural rate + Water (Thủy) purity × k + `dan_doc_decay`.
8. **Heart demon.**
   - **Gains:**
     - each failed breakthrough (+15, Realms & Bottlenecks);
     - events;
     - capability #9's +2 per defeat.

     Every gain is reduced by `tam_ma_resist_pct`, with the factor clamped to 0.1–2.0, so negative resistance (a penalty)
     raises the gain.
   - **Kills add none** (user decision, 2026-11-04). The only defeat-based gain is
     capability #9's +2, and only while #9 is held.
   - **Decay:** `tam_ma_natural_decay` per season (0.25, set by Realms & Bottlenecks).
     Calming pills and events can lower it further.
   - **Effects:** see the thresholds table under States and Transitions.
9. **Vitality.**
   - **Losses:** failed breakthroughs (40 % of maximum), mission wounds and event effects.
   - **The floor:** a failed breakthrough or a mission wound stops at 5 %
     (`vitality_floor`). A vitality-loss event effect has no floor.
   - **Fatal event:** a vitality-loss event effect that brings vitality to 0 or below is a
     fatal event, and the character dies. Capability #5 can survive it (the Meridian Map's
     catalogue).
   - **Recovery:** `injury_recovery_frac_per_season` of maximum each season.
   - A great breakthrough refills it.
   - A qi deviation sets it to the 5 % floor (Realms & Bottlenecks rule 10).

**Derived values**

10. **The four realm-scaled values.** Each takes the realm's multiplier and the stage
    multiplier from Realms & Bottlenecks, ×1.00 to ×1.45:
    - **Divine sense** (thần thức) = effective soul strength × per point × realm
      multiplier × stage multiplier × (1 + `than_thuc_pct`).
    - **Maximum vitality** = effective physique × per point × realm multiplier × stage
      multiplier × (1 + `khi_huyet_pct`).
    - **Spiritual power** (linh lực) = realm base × stage multiplier × technique power ×
      (1 + `linh_luc_pct`).
    - **The realm term of combat power** = the realm's power base × stage multiplier.
      Combat owns everything else in combat power.
11. **Element-driven multipliers**, as built: herb growth (Wood [Mộc] purity), field
    plots (Earth [Thổ]), pill-toxicity decay (Water [Thủy]) and mission income (Metal
    [Kim]). Herb growth and mission income multiply the purity term by the stat term;
    field plots and toxicity decay add them (Formulas G). Spiritual Roots owns the
    purities.

**The stat sheet**

12. **Modifiers.** Every bonus or penalty is a modifier {source, stat, value}. There are
    nine source kinds:
    - root variants (biến dị linh căn: purity-scaled role lines, Formulas G);
    - Spiritual Roots generating pairs (`cultivation_speed_pct` +3 each, Formulas I);
    - Meridian Map acupoints and capabilities;
    - the active cultivation technique;
    - equipped magic treasures (artifact-local keys excluded: Combat applies them);
    - Item DB consumables and tools (fertilisers, timed pill effects), while they act;
    - destiny perks;
    - formations;
    - craft mastery (đạo nghệ): a craft's mastery level may add sheet modifiers on its
      own craft keys. Spirit Fields mastery adds `herb_growth_pct` (cross-GDD review 04f,
      C2); the curve belongs to the craft's system (Spirit Herbs & Spirit Fields, system
      14, for this one), and the mastery level itself stays in this GDD.

    The sheet keeps every modifier with its source, so `explain` can show any total.
13. **Stacking.**
    - Values of the same key **add**.
    - A `_pct` key then applies once, as × (1 + total ÷ 100).
    - A flag key (`unit: flag`) is on when its total is above 0.
    - Talent keys add flat to the effective talent (rule 5).
    - `cultivation_speed_per_element_pct` is multiplied by the root's base element count and
      added to the `cultivation_speed_pct` total before the single multiplier, as built.
    - `lifespan_years` and `lifespan_pct` stack by these rules; Realms & Bottlenecks owns
      the lifespan formula (its rule 14): (realm lifespan + the lifespan bonus, ceilinged
      by rule 14 below and Formulas I) × (1 + `lifespan_pct` ÷ 100).
14. **Caps.** The first is per source: the Meridian Map's acupoints may contribute at
    most `tree_breakthrough_cap` (8 pp) to `breakthrough_chance`. It is applied to the
    tree's modifiers only, and the sheet shows the clamp as a line. Other sources of the
    same key are not capped by it. The summed per-attempt extras that `breakthrough_chance`
    joins (pill quality, comprehension, Dao heart, the tree's share, the Chaos variant's line, event bonuses; destiny
    perks excluded) also meet Realms & Bottlenecks' q-extras ceiling in its Formulas C,
    which Realms owns and sets; this GDD does not define its value.
    - **Character-wide bonus ceilings** (user decision 2026-11-04, cross-GDD review G1).
      Three totals are capped across every rule 12 source, because they feed
      breakthrough odds through pill supply (Realms Formulas D): `herb_growth_pct` at 10,
      `alchemy_success` at 3 (cross-GDD review 04f; were 40 and 8) and the lifespan bonus at 15 % of the realm's base lifespan (Formulas I). The
      lifespan bonus is lifespan pill years plus every `lifespan_years` modifier. An
      equipped treasure's lifespan is its `lifespan_years` modifier and is counted once,
      inside that sum; there is no separate treasure term.
    - **Penalties apply after the cap** (user decision 2026-11-04, fourth-pass review).
      The ceiling clamps only the sum of the positive modifiers; the negative ones are
      added afterwards: total = min(Σ positive, ceiling) + Σ negative. Each modifier is
      sorted by its own sign, so a source with a bonus and a penalty on the same key
      feeds both sums. Bonus above the ceiling therefore never absorbs a penalty: a +60 source with a
      −20 penalty gives 10 − 20 = −10, not min(40, 10) = 10.
    - **A negative lifespan bonus is allowed** (no earlier rule bounded it). It lowers the
      cap below the realm's base lifespan. A change the player makes that would put the
      cap at or below the character's age needs Realms rule 14's confirmation; a loss
      without a player choice follows Realms' Edge Case for it.
    - **What is capped.** A root term is a purity factor inside a formula, and
      it never enters the sheet; every sheet modifier on a ceiling key is capped,
      whatever its source. So the root terms (Wood's herb growth and
      Earth's plots, Formulas G; Fire's brew success, +0.25 pp per purity point, in
      Realms Formulas D and owned by Alchemy) are not capped. Nor are `field_plots`
      (bounded by `max_plots`; a deliberate build lever: extra plots can beat the
      breakthrough odds, and Realms' targets assume none (user decision 2026-11-04)) or
      `lifespan_pct` (bounded below). Alchemy's own brew-success terms are not sheet
      modifiers, so they are not capped either: Đan Đạo level (+6 pp per level, up to 54 pp
      at level 9) and comprehension (+0.1 pp per point) sit in Alchemy's base brew success,
      which Realms' p_brew0 carries. The sheet shows each clamp as a line. A variant's role lines are sheet modifiers, not root terms;
      none of the eight sits on a ceiling key. Any source of `lifespan_years` or
      `herb_growth_pct` counts under its ceiling (user decisions 2026-11-04, cross-GDD
      reviews W10 and 04f, B1).
    - **`lifespan_pct` sources and bound** (user decision 2026-11-05). Two sources grant it:
      the destiny perk Thọ Nguyên Dư Dả (`tho_nguyen`, +20) and the Wood keystone Vạn Cổ
      Trường Thanh (+25). Each is held at most once, so the total is at most **+45**. This
      is a bound on the data, not a runtime clamp: a new source must fit inside +45 or
      reopen this decision (Open Question 7).
15. **Stat keys.** This GDD owns every key, its unit and its meaning. Units:
    - `pct`: percentage points, so 1 = +1 %;
    - `flat`: a plain number;
    - `years`;
    - `flag`: on/off.

    Precision follows the Meridian Map's Formulas F: 0.1 for `pct` keys, `stealth` and
    `lifespan_years`; 0.01 for the six talent keys (`ngo_tinh`, `can_cot`,
    `than_hon`, `khi_van`, `dao_tam`, `mi_luc`), `dan_doc_decay` and `density_bonus`; 1 for `field_plots`, `alchemy_yield` and flags. **`field_plots` is
    an integer.**

    | Group | Keys (unit) |
    |---|---|
    | Cultivation | `cultivation_speed_pct`, `cultivation_speed_per_element_pct` (pct, × the root's base element count), `density_bonus` (flat qi density), `breakthrough_chance` (pct, pill attempts only) |
    | Combat | `attack_pct`, `defense_pct`, `khi_huyet_pct`, `linh_luc_pct`, `than_thuc_pct`, `artifact_power_pct` (pct); artifact-local: `artifact_attack_pct`, `artifact_defense_pct`, `element_affinity_pct`, `than_thuc_cost_pct` (pct, applied by Combat only); `single_artifact` (flag) |
    | Toxicity and heart demon | `tam_ma_resist_pct`, `dan_doc_resist_pct`, `pill_effect_pct` (pct); `dan_doc_decay` (flat per season); `dan_doc_no_penalty`, `safe_failure` (flag); `qi_deviation_pct` (pct: the qi deviation chance is × (1 + total ÷ 100); +100 doubles it) |
    | Lifespan | `lifespan_years` (years), `lifespan_pct` (pct) |
    | Crafts and economy | `alchemy_success`, `refining_success`, `formation_power_pct`, `herb_growth_pct`, `mission_income_pct` (pct); `alchemy_yield` (flat pills); `field_plots` (flat, integer) |
    | World | `travel_speed_pct`, `co_duyen_pct` (pct); `stealth` (flat) |
    | Talents | `ngo_tinh`, `can_cot`, `than_hon`, `khi_van`, `dao_tam`, `mi_luc` (flat, onto the effective talent) |

    A key not in this table is rejected by data validation, and an LLM-written fill is
    repaired (the Meridian Map's validator). The six talent keys display by their
    `character_attributes.json` names; `character_stat_labels.json` gives their unit.

**Capabilities**

16. **The capability set.** Each character, player or NPC, holds a set of capability ids
    (`capabilities`).
    - Only the Meridian Map adds to it, when a capability notable is opened. The add
      function is reachable only from the Meridian Map's grant, enforced by the API
      shape and code review.
    - Host systems read it.
    - It is saved with the character.
    - An NPC's simplified `npc_effect` is applied by its host, as the Meridian Map
      specifies.
17. **#4 Blood Commands Spirit (Huyết Ngự Linh), hosted here:**
    - spiritual power gains 20 % of maximum vitality, as a sheet line;
    - while current vitality is below 30 %, an `attack_pct` −20 modifier is on the sheet.
18. **#25 Heart Demon Turned to Strength (Tâm Ma Hóa Lực), hosted here:**
    - while heart demon is above 50, the sheet adds `attack_pct` = heart demon ÷ 2;
    - it always adds `qi_deviation_pct` +100, which doubles the qi deviation chance.
19. **#2 Divided Divine Sense (Thần Thức Phân Hóa), sheet line hosted here:** it adds
    `than_thuc_pct` +20 (`params.than_thuc_pct`) as a sheet line. Its extra magic treasure
    slot belongs to the treasure host.

**What the player cannot do:**
- raise a talent's base value above 100 or permanently by more than the pills' use
  limits;
- raise talents by climbing;
- edit the capability set directly;
- carry modifiers from a magic treasure that isn't equipped.

### States and Transitions

The character is Alive or Dead. Death comes from old age, a fatal qi deviation or a fatal
event (rule 9). Realms & Bottlenecks and Time & Turn own the first two triggers.

Heart demon has thresholds rather than states:

| Heart demon | What it means |
|---|---|
| below 20 | Calm |
| 20 and above | Heart demon intrusion events become eligible (`requires_tam_ma` 20, as built) |
| above 20 | The Nascent Soul condition fails (it holds at ≤ 20) |
| above 50 | Capability #25 adds attack |
| 90 and above | A qi deviation after a failed breakthrough kills |

Vitality bands, for display and the Advisor:
- full: 100 %;
- injured: below 50 %;
- critical: below 30 %, where capability #4 adds its −20 % attack;
- floor: 5 %, after a failed breakthrough or a mission wound (rule 9).

### Interactions with Other Systems

Time & Turn, Combat, Event Engine and the crafts have no GDD yet; their interfaces are
provisional. Spiritual Roots and Realms & Bottlenecks have GDDs at Needs Revision;
Cultivation Techniques and the Meridian Map have GDDs In Review (systems index,
2026-11-05).

| System | Direction | Data | Interface owner |
|---|---|---|---|
| Spiritual Roots (Linh Căn) | in | per-element purity, root variants with their purities (their role lines, Formulas G), `n_base`, `n_eff`, and one `cultivation_speed_pct` +3 modifier per generating pair owned (source "Tương sinh: <from> → <to>") | Spiritual Roots |
| Realms & Bottlenecks | in / out | in: realm, level, stage multiplier, heart demon +15 per failure, vitality −40 %; out: effective comprehension and Dao heart, the comprehension factor `comp` (Formulas J), `breakthrough_chance` (tree share capped), the bonus ceilings on herb growth, alchemy success and lifespan (rule 14), `qi_deviation_pct`, `safe_failure`, heart demon | Realms (the ladder); this GDD (the stats) |
| Meridian Map (Kinh Mạch Đồ) | in | acupoint modifiers {source, stat, value}; capability ids into the set | Meridian Map (what nodes give); this GDD (keys, units, the set) |
| Cultivation Techniques | in | technique bonuses (modifiers) and technique power for spiritual power | Cultivation Techniques |
| Item DB (magic treasures, pills) | in | equipped treasure affixes; pill effects (toxicity, talent pills, heart demon pills) | Item DB |
| Progression Edges | in | destiny perk modifiers and flags | Progression Edges |
| Formations | in | formation modifiers (`density_bonus` and others) | Formations |
| Combat | out / in | out: attack, defense, the four derived values, artifact-local keys; in: vitality loss | Combat |
| Event Engine | in / out | in: heart demon, talent and vitality effects inside budget; out: fortune (reward ceiling), heart demon thresholds (event eligibility) | Event Engine |
| Market, NPC Interaction | out | presence (prices, attitude) | Market, NPC Interaction |
| Crafts (Alchemy, Artifact Refining, Talismans, Spirit Fields, Beast Taming) | out / in | out: craft mastery levels, element multipliers, craft stat keys; in: modifiers a craft grants from its mastery level (Spirit Fields: `herb_growth_pct`, under the rule 14 ceiling) | each craft |
| Guidance Layer, Debug Terminal, Game UI | out | the sheet, `explain` breakdowns, grades, thresholds | Guidance Layer |
| Save/Load | out | talents, state values, craft mastery, the capability set, the lifespan bonus from pills (`pill_years`), per-life use counts of every pill with `max_uses` | Save/Load |

## Formulas

Proposed with `systems-designer` (2026-11-04). Values marked *guess* need a bot run.
Realm abbreviations: QR, FE, CF, NS, DT (`design/glossary.md`).

### A. Talent roll and grade

The talent_roll formula is defined as:

`talent = clamp(round(N(mean, sd)), 1, 100)` ; `grade = the first band with talent ≤ band.max`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| mean, sd | float | 45, 16 | data file (`roll.mean`, `roll.sd`) | Distribution of a Fated birth roll (kept, user decision 2026-11-04) |
| talent | int | 1–100 | calculated | A talent's base value, rolled once at birth |
| band.max | int | 30 / 60 / 85 / 99 / 100 | data file (`grade_bands`) | Lower / Middle / Upper / Supreme / Heavenly |

**Output Range:** 1–100. Because of rounding, the band edges sit at raw values 30.5, 60.5,
85.5 and 99.5.

| Grade | Share per talent | Reading |
|---|---|---|
| Lower 1–30 | 18.2 % (0.27 % of rolls clamp to 1) | about 1 in 5 |
| Middle 31–60 | 65.1 % | the norm |
| Upper 61–85 | 16.1 % | about 1 in 6 |
| Supreme 86–99 | 0.54 % | about 1 in 190 |
| Heavenly 100 | 0.033 % | about 1 in 3,000 |

Across six talents, 3.4 % of characters have at least one Supreme-or-better talent and
0.2 % have a Heavenly one. A Heavenly talent nearly always comes from a talent pill, an
event or a Self-made birth.

**Example:** a raw roll of 72.4 → 72, Upper. A raw 103 → 100, Heavenly. A raw −3 → 1,
Lower.

### B. Effective talent

The effective_talent formula is defined as:

`eff(t) = clamp(base(t) + Σ flat(t), 1, 150)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| base(t) | int | 1–100 | calculated (A, talent pills, events) | Innate value; any origin bonus is already applied, clamped to 100 |
| Σ flat(t) | float | about −20 to +40 | calculated (stat sheet) | All modifiers on that talent key |
| eff(t) | float | 1–150 | calculated | What every rule reads; the grade comes from base(t) |

**Output Range:** 1–150.

**Example:** comprehension base 45 plus a perk's +10 = **55**.
Presence base 5 with a −10 penalty → clamped to **1**.

### C. Realm-scaled derived values

The derived_values formulas are defined as:

`divine_sense = eff(than_hon) · k_ts · M_ts[realm] · stage_mult · max(0, 1 + than_thuc_pct/100)`

`vitality_max = max(1, eff(can_cot) · k_kh · M_kh[realm] · stage_mult · max(0, 1 + khi_huyet_pct/100))`

`spiritual_power = B_ll[realm] · stage_mult · tech_power · max(0, 1 + linh_luc_pct/100) + [#4] · c4 · vitality_max`

`combat_realm_term = B_p[realm] · stage_mult`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| k_ts, k_kh | float | 1.0, 10 | data file (`than_thuc_per_than_hon`, `khi_huyet_per_can_cot`) | Per-point factors |
| M_ts | float | 1 / 3 / 10 / 30 / 100 | data file (`than_thuc_mult`) | Divine sense realm multiplier, QR to DT |
| M_kh | float | 1 / 4 / 15 / 50 / 150 | data file (`khi_huyet_mult`) | Vitality realm multiplier |
| B_ll | float | 100 / 800 / 6,000 / 50,000 / 400,000 | data file (`linh_luc_base`) | Spiritual power base |
| B_p | float | 100 / 1,000 / 10,000 / 100,000 / 1,000,000 | data file (`power_base`) | Combat power base |
| stage_mult | float | 1.00–1.45 | calculated (Realms & Bottlenecks, Formulas B) | Small-breakthrough multiplier |
| tech_power | float | 0.5–2.2 | calculated (Cultivation Techniques, Formulas C: tier `power_mult` × layer depth; 0.5 with no main method) | Cultivation technique power |
| [#4], c4 | bool, float | 0/1, 0.20 | calculated, data file (`linh_luc_conversion`) | Capability #4; added after the pct step, so `linh_luc_pct` does not multiply it |

**Output Range:** all ≥ 0; maximum vitality ≥ 1. Displayed values round half away from
zero (65.25 → 65, 652.5 → 653). **The realm bases stay as built**
(answering Realms & Bottlenecks' Open Question 7). The smallest great-breakthrough jump
is next base ÷ (base × 1.45) = 3.0 ÷ 1.45 = ×2.07, for divine sense and vitality. That is
still above the in-realm ladder's ×1.45. Spiritual power jumps at least ×5.17 and combat
power ×6.9. The step limit is (1 + 3s)² < 3, so s < 0.244.

At talent 45, with technique power 1.0 and no bonuses (stage ×1.00 / ×1.45):

| Realm | Divine sense | Max vitality | Spiritual power | Combat realm term |
|---|---|---|---|---|
| QR | 45 / 65 | 450 / 653 | 100 / 145 | 100 / 145 |
| FE | 135 / 196 | 1,800 / 2,610 | 800 / 1,160 | 1,000 / 1,450 |
| CF | 450 / 653 | 6,750 / 9,788 | 6,000 / 8,700 | 10,000 / 14,500 |
| NS | 1,350 / 1,958 | 22,500 / 32,625 | 50,000 / 72,500 | 100,000 / 145,000 |
| DT | 4,500 / 6,525 | 67,500 / 97,875 | 400,000 / 580,000 | 1,000,000 / 1,450,000 |

Capability #4 can only be opened from Core Formation on (Meridian Map: capability
clusters are gated at Core Formation or later). At physique 45 and stage ×1.00 it adds
about +22 % spiritual power at CF, +9 % at NS and +3 % at DT, so 20 % stays. The share
scales with physique: at physique 100 it is about +50 % at CF, and at 150 about +75 %.

**Example:** CF late stage (×1.30) with soul strength 60: divine sense = 60 × 1.0 × 10 ×
1.30 = **780**.

### D. Pill toxicity (đan độc)

The toxicity formulas are defined as:

`gain = tox_pill · clamp(1 − R_d/100, f_min, f_max)` ; `dd' = clamp(dd + gain, 0, 100)`

`cultivation_mult = 1 if dan_doc_no_penalty, else max(0, 1 − dd/D_c)`

`pill_potency = (1 + q_step · quality) · P_dd · max(0, 1 + pill_effect_pct/100) · [s_r if made for a lower realm]`, with `P_dd = 1 if dan_doc_no_penalty, else max(floor_c, 1 − dd/D_p)`

`talent_gain = max(1, round(value · pill_potency))` ; `base' = clamp(base + talent_gain, 1, 100)`

`decay = max(0, d_nat + k_w · purity_water + dan_doc_decay)` ; `dd' = max(0, dd − decay)` each season

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| tox_pill | float | 0–about 20 | data file (recipe `toxicity`) | The pill's toxicity |
| R_d | float | −100 to 90 | calculated (`dan_doc_resist_pct`) | Toxicity resistance; negative from penalties |
| f_min, f_max | float | 0.1, 2.0 | data file | Resist factor clamp |
| dd | float | 0–100 | calculated | Current toxicity |
| D_c | float | 200 | data file (`dan_doc_divisor`) | Cultivation divisor: at most −50 % (kept on purpose) |
| D_p | float | 100 | data file (`toxicity_effect_divisor`) | Pill divisor: potency can fall to 0 (kept on purpose) |
| floor_c | float | 0.25 for cleansing pills, 0 otherwise | data file (`cleanse_potency_floor`) | Cleansing pills (toxicity and heart demon types) keep at least 25 % strength, which removes the soft lock at toxicity 100 |
| q_step | float | 0.25 | data file (`quality_effect_step`) | Potency per quality grade |
| quality | int | 0 upward | Item DB | The pill's quality grade |
| s_r | float | 0.1 | data file (`realm_scale_penalty`) | Potency factor of a pill made for a lower realm |
| value | float | per recipe | data file (recipe `effect.value`) | A talent pill's listed gain |
| d_nat, k_w | float | 1.0, 0.05 | data file (`dan_doc_natural_decay`, `dan_doc_decay_per_purity`) | Natural decay and Water purity factor |

**Output Range:**
- gain: 0.1 to 2.0 × the pill's toxicity;
- cultivation multiplier: 0.5–1.0;
- potency: 0 upward;
- talent gain: 1 upward, an integer, rounded half away from zero; the base stays at most
  100;
- decay: 0 upward.

Potency is computed before the pill's own toxicity is added. `dan_doc_no_penalty` protects
pill potency as well as cultivation, as rule 7 states. Talent gain follows the purity
pills' rule (Spiritual Roots), so a talent pill always gives at least +1, even at potency
0, and it spends one use.

**Example:** a pill worth 100 cultivation base, quality 2, toxicity 8, taken at toxicity
40 with 20 % resistance:
- potency = 1.5 × 0.6 = 0.9, so it gives **+90** cultivation base;
- toxicity rises by 8 × 0.8 = 6.4, to **46.4**;
- cultivation then runs at × 0.768;
- with Water purity 60 and `dan_doc_decay` +0.5, decay is 1 + 3 + 0.5 = 4.5 a season,
  so toxicity is **41.9** the next season.

### E. Heart demon (tâm ma) and qi deviation

The heart_demon formulas are defined as:

`gain = amount · clamp(1 − R_t/100, f_min, f_max) · (0.5 if safe_failure and the source is a failed breakthrough)` ; `hd' = clamp(hd + gain, 0, 100)`

`hd' = max(0, hd − d_t)` each season

`P_dev = clamp(max(0, hd − eff(dao_tam)/k_b) · max(0, 1 + qi_deviation_pct/100), 0, 100)` %

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| amount | float | 15 per failed breakthrough; events; +2 per defeat (#9) | data file (`failure_tam_ma_gain` 15) | Kills add none (user decision) |
| R_t | float | −100 to 90 | calculated (`tam_ma_resist_pct`) | Heart demon resistance; negative from penalties (e.g. Destruction −10 → gains ×1.10) |
| d_t | float | 0.25 per season | data file (`tam_ma_natural_decay`) | Natural decay |
| k_b | float | 2 | data file (`tam_ma_backlash_divisor`) | Dao heart divisor |
| qi_deviation_pct | float | 0–100 | calculated (stat sheet) | Capability #25 adds +100, doubling the chance |

**Output Range:** heart demon 0–100; P_dev 0–100 %. The order matches Realms &
Bottlenecks rule 10: gain first, then the deviation roll with the new value. Death needs a
deviation **and** heart demon ≥ 90.

**Example:** Dao heart 30 (threshold 15), no resistance, 8 seasons between failures:

| | Without #25 | With #25 |
|---|---|---|
| Failure 1: heart demon 15 | 0 % | 0 % |
| Failure 2: 13 + 15 = 28 | 13 % | 26 % |
| Failure 3: 26 + 15 = 41 | 26 % | 52 % |
| Failure 4: 39 + 15 = 54 | 39 % | 78 %, and attack +27 |

### F. Vitality (khí huyết)

The vitality formulas are defined as:

`v' = max(v_floor, v − loss)` for a failed breakthrough or a mission wound ; `v' = v − loss`, fatal at `v' ≤ 0`, for an event effect ; `v' = min(1, v + r_v)` each season ; `attack_pct −20 while v < 0.30` (capability #4)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| v | float | above 0, up to 1.0 | calculated | Current vitality as a fraction of maximum |
| v_floor | float | 0.05 | data file (`breakthrough.vitality_floor`) | Floor of a failed breakthrough or a mission wound |
| loss | float | 0.4 per failed breakthrough; 0.2 per mission wound; event effects 0.15–0.60 | data file (`failure_khi_huyet_loss_frac`, `injury_khi_huyet_loss_pct`, the event's `khi_huyet_loss_pct`) | |
| r_v | float | 0.25 | data file (`injury_recovery_frac_per_season`) | Recovery per season |
| v_c | float | 0.4 | data file (`duel.injured_power_floor`) | Combat's floor on the vitality factor |

**Output Range:** above 0, up to 1.0 while alive; 0 or below is a fatal event. A great
breakthrough sets v = 1. Combat reads vitality as × max(v, v_c). Vitality is compared in integer tenths of a percent, round(v × 1000) half away from
zero, so 0.05 + 0.25 lands exactly on 300.

**Example:** a failure takes vitality from 1.0 to 0.6, then 0.85, then 1.0. A qi
deviation sets 0.05, then 0.30, 0.55, 0.80 and 1.0. An event effect of 15 % at 0.05 is
fatal; a failed breakthrough at 0.05 leaves 0.05.

### G. Element-driven multipliers

The element_multipliers formulas are defined as:

`herb_growth = (1 + k_h · purity_wood) · max(0, 1 + herb_growth_pct / 100)`

`mission_income = (1 + k_m · purity_metal) · max(0, 1 + mission_income_pct/100)`

`plots = clamp(base_plots + ⌊k_f · purity_earth⌋ + total(field_plots), 1, max_plots)`

Toxicity decay is in D. `total(field_plots)` is the stat sheet's `field_plots` total.
Herb growth and mission income multiply; field plots and toxicity decay add (rule 11).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| purity_* | float | 0 (absent), 10–100 | calculated (Spiritual Roots) | Element purity |
| k_h, k_m | float | 0.008, 0.008 | data file (`herb_growth_pct_per_purity`, `mission_income_pct_per_purity`, stored as 0.8 %) | Per purity point |
| k_f | float | 0.04 | data file (`field_plots_per_purity`) | Plots per Earth purity point |
| base_plots, max_plots | int | 3, 12 | data file | |
| herb_growth_pct | float | at most the ceiling, 10 (rule 14); negative allowed | calculated (stat sheet total after Formulas I) | Herb growth bonus, ceilinged with penalties added after the cap (rule 14); the factor `max(0, 1 + herb_growth_pct/100)` floors at 0 |
| mission_income_pct | float | no ceiling (not a rule 14 key), negative allowed | calculated (stat sheet total after Formulas I) | Mission income bonus; the factor floors at 0 |
| total(field_plots) | int | any; the result is clamped | calculated (stat sheet) | Extra plots |

**Output Range:** the purity term is 1.0–1.8. Herb growth is 0 up to 1.8 × (1 + ceiling/100) = 1.98
(Wood 100 at the ceiling of 10); it reaches 0 when `herb_growth_pct` is −100 or below. Mission
income is ≥ 0, with no upper bound set here because `mission_income_pct` has no ceiling.
Field plots 1–12.

**Variant roles.** Each owned variant adds its `variant_effects` lines to the sheet, with the
source "Biến dị: <data name>":

`value(v, k) = floor(per_purity(v, k) · purity_v / 0.1) · 0.1`

The floor is taken in integer arithmetic on hundredths, and the value follows the variant's
current purity. Spiritual Roots Formulas E owns the coefficients and prices. None of the
eight variants' keys is under a rule 14 ceiling. For example, Thunder at purity 47 gives
`attack_pct` +14.1.

**Example:** Wood 60 with `herb_growth_pct` +10 (the ceiling) → 1.48 × 1.1 = **1.628**.
Earth 60 with
`field_plots` +3 → 3 + 2 + 3 = **8** plots.

### H. Fortune and presence factors

These formulas use fortune and presence as the code does today; this GDD owns them, and
the listed systems consume them.

| Formula | Consumer |
|---|---|
| Reward ceiling = `0.75 + 0.005 · eff(khi_van)` (× the event budget's spirit stone and cultivation base caps) | Event Engine |
| Check chance = `clamp(0.5 + (stat − difficulty) · 0.01 + (eff(khi_van) − 50) · 0.002 [+ stealth · 0.01 when evading], 0.05, 0.95)`. The fortune term is omitted when the checked stat is fortune | Event Engine |
| Duel win chance gains `(fortune_A − fortune_B) · 0.001`, clamped 0.02–0.98 | Combat |
| Alchemy crit chance = `eff(khi_van) · 0.0015` | Alchemy |
| `charm = (eff(mi_luc) − 50) · 0.004`; buy = ⌈value × 1.5 × (1 − charm)⌉; sell = max(1, ⌊value × 0.6 × (1 + charm)⌋). Buy rounds up and sell rounds down, so rounding never favours the player in a loop | Market |
| NPC attitude: this GDD publishes `eff(mi_luc) − 50`; the scale belongs to NPC Interaction (not built) | NPC Interaction |

**Output Range:** reward ceiling 0.755–1.5 (1.0 at fortune 50); charm −0.196 to +0.40.
**Derived limit:** a buy-and-sell loop profits when charm > 0.9 ÷ 2.1 = 0.4286. At
presence 150 the price factor must stay below 0.00429 per point; 0.004 is just under it.
The limit holds only while the effective talent clamp stays at or below 157 (0.004 × 107 =
0.428); raise the clamp and the price factor must fall with it (Tuning Knobs).

**Rounding:** buy and sell are computed from the exact products with the Formula I
tolerance: buy = ⌈x − 1e-6⌉, sell = ⌊x + 1e-6⌋, so a product that is an integer in
exact arithmetic is not pushed to the next integer by floating-point error.

**Example:** fortune 55 → reward ceiling 1.025, alchemy crit 8.25 %. Presence 70 →
charm 0.08, so buying costs ×1.38 and selling pays ×0.648.

### I. Stat sheet stacking and precision

The stacking formulas are defined as:

`total(k) = Σ v_i` ; for `breakthrough_chance`: `total = min(Σ_tree v_i, cap_tree) + Σ_other v_i`

for `herb_growth_pct` and `alchemy_success`: `total = min(Σ⁺ v_i, ceiling(k)) + Σ⁻ v_i`

lifespan bonus: `B_life = min(pill_years + Σ⁺ lifespan_years, f_life · L_realm) + Σ⁻ lifespan_years`

`Σ⁺` sums the modifiers with v_i > 0 and `Σ⁻` those with v_i < 0, so penalties apply
after the cap (rule 14, user decision 2026-11-04). An equipped treasure's lifespan is its
`lifespan_years` modifier, counted once inside `Σ⁺ lifespan_years`; there is no separate
treasure term.

`mult(k) = max(0, 1 + total(k)/100)` for `_pct` keys ; `flag(k) = total(k) > 0`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| v_i | int (precision units) | per key | calculated | One modifier, quantized once when it enters the sheet |
| cap_tree | float | 8 pp | data file (`tree_breakthrough_cap`, owned by the Meridian Map) | Cap on the tree's share |
| ceiling(k) | float | `herb_growth_pct` 10, `alchemy_success` 3 pp (04f; were 40 and 8) | data file (`bonus_ceilings`) | Character-wide ceiling on the positive modifiers of every source, craft mastery's sheet modifiers included (rule 12; Alchemy's level term is not one, rule 14); penalties are added after it (rule 14) |
| f_life | float | 0.15 (guess) | data file (`bonus_ceilings.lifespan_frac`) | Lifespan bonus ceiling as a share of the realm's base lifespan |
| L_realm | int | 120 / 200 / 500 / 1,000 / 2,000 | data file (Realms & Bottlenecks) | The realm's base lifespan |
| pill_years | float | ≥ 0 | stored on the character (Item DB lifespan pills) | Lifespan years from pills taken; the raw sum is kept (Edge Cases) |
| Σ⁺, Σ⁻ | float | Σ⁺ ≥ 0, Σ⁻ ≤ 0 | calculated | Sums of a key's positive and negative modifiers, each modifier sorted by its own sign |
| B_life | float | at most f_life · L_realm; negative allowed | calculated | The lifespan bonus Realms rule 14 adds to the base lifespan |

The ceiling values are calibrated by Realms & Bottlenecks. The derived limit is Realms'
`bonus_ceiling_target`: with `gate_factor` set to 1, each gate's birth-mix mean S at all
ceilings, best plot play and one talisman ≤ 0.45, measured ≤ 0.48 (Realms AC-CG-60), which
owns the computed figures.
The target covers lives without extra plots: those are builds outside the target, per
Realms AC-CG-60 (user decision 2026-11-04). The tree's `breakthrough_chance` share (cap_tree) is also
inside Realms Formulas C's q-extras ceiling, which Realms owns.

**Output Range:** multipliers ≥ 0; flags 0/1. A ceilinged total is at most its ceiling
and has no lower bound but the sum of its penalties; its `_pct` multiplier floors at 0.
`B_life` can be negative, which puts the lifespan cap below the realm's base (rule 14).
Spiritual Roots' generating-pair modifiers (`cultivation_speed_pct` +3 each, 0–15 in all)
are ordinary entries in the sum.

**Rounding rule:** quantize at storage, by flooring, once.
- Modifiers are stored as integer units of their key's precision (0.1, 0.01 or 1), so sums
  are exact and tests are reproducible.
- Authored values (data, the tree, sealed clusters) must already sit on their key's grid.
  An off-grid authored value fails data validation. A valid one is stored as
  round(x × units), which survives floating-point error: 0.29 × 100 = 28.999… is stored
  as 29.
- Computed modifiers (#25's heart demon ÷ 2, NPC simplifications) are floored when they
  enter, with a tolerance: floor(x × units + 1e-6).
- Flooring, as the Meridian Map's Formulas F does, can never overstate a bonus.
- Derived values (C) stay floats and are rounded only on display.

**Example:** heart demon 54.25 → #25 adds 27.125 → stored **27.1**. Tree modifiers of
5.0 and 4.5 pp on `breakthrough_chance` → min(9.5, 8) = 8, plus a +12 perk (not capped) =
**20**. Two secret arts with `herb_growth_pct` 25 each plus a tree +6 → min(56, 10) =
**10**. A +60 with a −20 penalty → min(60, 10) − 20 = **−10**, so herb growth takes × 0.9;
a +5 with the −20 → 5 − 20 = **−15**. `alchemy_success` +2, +2 and +3 → min(7, 3) = **3**.
In QR (base lifespan 120), two arts with `lifespan_years` 15 →
min(30, 18) = **18** years; add a `lifespan_years` −5 penalty → 18 − 5 = **13**.

### J. Comprehension factor

The comprehension_factor formula is defined as:

`comp = 1 + ngo_tinh_eff ÷ ngo_tinh_divisor`

Realms & Bottlenecks multiplies `comp` into the cultivation rate (its Formulas I).
Cultivation Techniques' mastery reads effective comprehension directly, not `comp`.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| ngo_tinh_eff | float | 1–150 | calculated (Formulas B) | Effective comprehension (ngộ tính) |
| ngo_tinh_divisor | float | 200 (as built) | data file (`cultivation_realms.json`) | How much comprehension speeds cultivation |
| comp | float | 1.005–1.75 | calculated | The comprehension factor |

**Output Range:** 1.005 at comprehension 1, 1.5 at 100, 1.75 at the clamp of 150. Never
below 1, so comprehension only ever speeds cultivation.

**Example:** comprehension 45 (the roll mean) gives 1 + 45 ÷ 200 = **1.225**; 50 gives
**1.25**, the value the Realms and Spiritual Roots examples use. (Added 2026-11-04,
cross-GDD review N5: the factor was built but had no formula in any GDD.)

### Parameter keys

**`character_attributes.json`:**
- `roll` {mean 45, sd 16, min 1, max 100}; `grade_bands`.
- `derived`:
  - `than_thuc_per_than_hon` 1.0, `khi_huyet_per_can_cot` 10;
  - `dan_doc_natural_decay` 1.0;
  - `tam_ma_natural_decay` 0.25, read-only here: Realms & Bottlenecks owns the value;
  - `injury_recovery_frac_per_season` 0.25;
  - `resist_factor_min` 0.1, `resist_factor_max` 2.0;
  - `cleanse_potency_floor` 0.25;
  - `linh_luc_conversion` 0.20 (#4);
  - `effective_talent_min` 1, `effective_talent_max` 150;
  - `heart_demon_strength` {threshold 50, divisor 2, deviation_pct 100} for #25.
- `bonus_ceilings` {`herb_growth_pct` 10, `alchemy_success` 3, `lifespan_frac` 0.15}. Each
  ceiling clamps the positive modifiers only; penalties are added after it (rule 14).

**`character_elements.json`** (owned by Spiritual Roots): `variants` and `variant_effects` (per
variant a list of {`stat`, `per_purity`}), read by Formulas G's variant role lines. The
effect kinds "root" and "ceiling_raise" were removed with the relocated mutations.

**The fortune, presence and pill factors (Formulas D, F and H):**
- `events_budgets.json`: `khi_van_ceiling.base` 0.75, `khi_van_ceiling.per_point` 0.005;
  `check.base` 0.5, `check.per_point` 0.01, `check.khi_van_per_point` 0.002,
  `check.khi_van_neutral` 50, `check.stealth_per_point` 0.01, `check.min` 0.05,
  `check.max` 0.95.
- `combat_rules.json`: `duel.khi_van_per_point` 0.001, `duel.min_win_chance` 0.02,
  `duel.max_win_chance` 0.98, `duel.injured_power_floor` 0.4.
- `items_recipes.json`: `alchemy.khi_van_crit_per_point` 0.15 (%).
- `session_actions.json`: `market.mi_luc_price_per_point` 0.004, `market.buy_markup` 1.5,
  `market.sell_ratio` 0.6; `pill.toxicity_effect_divisor` 100, `pill.quality_effect_step`
  0.25, `pill.realm_scale_penalty` 0.1.

**`cultivation_realms.json`:**
- per realm: `than_thuc_mult`, `khi_huyet_mult`, `linh_luc_base`, `power_base`;
- `ladder.stage_power_step` 0.15, one global key;
- `breakthrough.failure_khi_huyet_loss_frac` 0.4;
- `breakthrough.vitality_floor` 0.05, read-only here: Realms & Bottlenecks owns it, and
  this is its only copy;
- `cultivation.dan_doc_divisor` 200;
- `cultivation.ngo_tinh_divisor` 200 (owned here, Formulas J).

**`character_stat_labels.json`:** every rule 15 key has an entry with its unit. Talent
display names come from `character_attributes.json` (rule 15).

## Edge Cases

**Talents**

- **If a talent pill would raise a base already at 100, or the pill's per-life uses are
  spent:** it cannot be taken and is not consumed. The item explains why.
- **If a talent pill would overshoot 100** (for example +5 at 97): it is taken, consumed
  and clamped at 100. Its preview shows the real gain (+3) first.
- **If potency would round a talent pill's gain to 0:** it gives +1 and spends one use
  (Formulas D).
- **If an origin bonus would push a talent above 100:** it is clamped to 100.
- **If an event or pill would lower a talent's base below 1:** it is clamped to 1. The
  grade is Lower, and the base never reads 0 or negative.
- **If modifiers push an effective talent below 1 or above 150:** it is clamped. The
  breakdown shows the clamp line.
- **If a Self-made birth sets every talent to 100:** that is allowed. Achievements are
  off for that life.

**State**

- **If a pill is taken at toxicity 100:** the gain is clamped at 100. A normal pill's
  potency is 0; a cleansing pill keeps 25 %; a talent pill still gives its minimum +1.
  Before the player takes it, the Advisor warns
  what the pill will actually do.
- **If heart demon or toxicity would go below 0 or above 100:** it is clamped.
- **If resistance goes below −100:** the factor stops at ×2.0. Above 90 % it stops at
  ×0.1, so a gain never disappears entirely.
- **If vitality is at 5 % and a failed breakthrough or a mission wound hits:** it stays
  at 5 %, and the character lives.
- **If a vitality-loss event effect brings vitality to 0 or below:** that is a fatal event
  (rule 9), and the character dies, whatever vitality was before. With capability #5
  unused this realm, the character survives at 5 % and loses one stage.
- **If recovery lands vitality exactly on 30 %:** capability #4's −20 % attack is off,
  because it applies strictly below 30 %. The comparison uses integer tenths of a
  percent.

**Derived values**

- **If the realm or stage changes:** all four derived values are recomputed at once.
  After a stage loss they fall with the stage multiplier.
- **If a `_pct` total is below −100:** its multiplier is floored at 0, never negative.
- **If capability #4 is held:** its 20 % of maximum vitality is added after the
  spiritual power percentage, so `linh_luc_pct` does not multiply it. `khi_huyet_pct`
  does, through maximum vitality.
- **If the character is an NPC:** the same formulas apply. Only the source of the
  modifiers differs.

**Stat sheet**

- **If data names an unknown stat key:** loading fails with a data validation error. An
  unknown key in an LLM-written fill is repaired by the Meridian Map's validator.
- **If a magic treasure is unequipped:** its modifiers leave the sheet immediately, unless
  the change would put the lifespan cap at or below the character's age. Then Realms
  rule 14's confirmation comes first, and declining leaves the treasure equipped.
- **If the lifespan bonus sits above the ceiling:** the raw sum is kept and the ceiling is
  applied when the bonus is read, so held-back years count again when a great
  breakthrough raises the ceiling (Realms rule 14).
- **If a ceiling key holds bonus above its ceiling and a penalty:** the penalty applies
  after the cap, so the bonus above the ceiling does not absorb it (rule 14). A +60 `herb_growth_pct` with a −20 penalty gives 10 − 20 = −10, and herb growth
  takes × 0.9. The sheet shows the clamp line (60 → 10) and then the penalty line. At −100
  or below the herb growth factor floors at 0 (`max(0, …)`, Formulas G), never negative.
- **If lifespan penalties push the lifespan bonus below 0:** that is allowed, and the
  cap falls below the realm's base lifespan. A player change that would put the cap at
  or below the age needs Realms rule 14's confirmation first.
- **If a capability is granted twice:** the set ignores the duplicate.
- **If the tree's `breakthrough_chance` modifiers exceed 8 pp:** only the tree's share is
  clamped, and other sources add on top.
- **If a flag key's sources sum to 0 or less** (a penalty cancelling a grant): the flag
  is off.
- **If a computed modifier is not on the precision grid:** it is floored when it enters
  the sheet (Formulas I).

**Capabilities**

- **If heart demon is exactly 50 with #25:** there is no attack bonus; it applies only
  above 50. The jump from +0 to +25 just above 50 is intended.
- **If the character holds both #4 and #25:** both sheet lines apply independently.

**Economy**

- **If presence is extreme:** charm stays in −0.196 to +0.40. A sale always pays at least
  1 spirit stone.

**Saves**

- **If a save has no capability set:** it loads as an empty set.
- **If a save stores heart demon or toxicity outside 0–100:** the values are clamped on
  load and the clamp is logged.

## Dependencies

Spiritual Roots, Realms & Bottlenecks, Cultivation Techniques, the Meridian Map and the Way
(Đạo) have GDDs among the systems below; every other interface is provisional. When each GDD is written, it must list Character Stats in
its own Dependencies section.

**Upstream (hard):**

| # | System | What Character Stats needs from it |
|---|---|---|
| 1 | Data-Driven Config | `character_attributes.json`, `character_stat_labels.json`, `character_elements.json`, the realm multipliers in `cultivation_realms.json` |
| 2 | Deterministic Simulation Core | The seeded RNG for talent rolls; Breakdown for every derived value |
| 6 | Spiritual Roots (Linh Căn) | Element purities, root variants with their purities and role lines, `n_base`, `n_eff`, generating-pair `cultivation_speed_pct` modifiers (up to +15 in all; they stack additively under Formulas I) |

**Modifier and value sources (soft).** Each pushes values into the sheet through one
provider interface. Character Stats never calls them, which breaks the cycles described
below.

| # | System | What it provides | Without it |
|---|---|---|---|
| 8 | Realms & Bottlenecks | Realm, level and stage multiplier, held on the character | Every realm-scaled value stays at QR early |
| 10 | Meridian Map | Acupoint modifiers and capability ids | No tree bonuses |
| 39 | The Way (Đạo) | Dao stat-line modifiers with the Dao and node as their source, and passive ability ids in the capability-style record (`design/gdd/dao.md` rules 3 and 4; no ceiling raises and no root factors) | No Dao bonuses |
| 9 | Cultivation Techniques | Technique bonuses and technique power | Spiritual power at `no_tech_power` 0.5 (Cultivation Techniques rule 11) |
| 13 | Item DB | Equipped treasure affixes, consumables and tools (fertilisers, timed pill effects), lifespan pill years | No item bonuses |
| 11 | Progression Edges | Destiny perk modifiers and flags | No player edge |
| 17 | Formations | Formation modifiers | No formation bonuses |
| 14 | Spirit Herbs & Spirit Fields | Spirit Fields mastery `herb_growth_pct` (curve owned there) | No mastery growth bonus |

**Downstream:**
- **Every system that reads a stat:** Realms & Bottlenecks, Combat, Event Engine, Market,
  NPC Interaction, every craft, Travel & Map, NPC Builds, the Living World Tick, Guidance
  and the UI, Save/Load and the Balance Harness.
- **Capability #4 and #25 behaviour, and #2's sheet line,** are hosted here.

**Cycles and how they are broken.** Realms ↔ Character Stats, and every modifier source ↔
Character Stats:
- Sources depend on the provider interface and the stat keys this GDD owns.
- Character Stats depends on neither the sources nor Realms. It reads the realm and stage
  values held on the character.
- The built `StatSheet.build` calls `ProgressionEdges` and `Formations` directly. Moving
  those calls behind the provider interface is an implementation change (becomes an
  ADR).

## Tuning Knobs

Ranges marked *derived* follow from another constraint in this GDD or an approved one.

| Knob | Value | Safe range | What it moves |
|---|---|---|---|
| `roll.mean` / `roll.sd` | 45 / 16 | 40–50 / 12–20 | Talent rarity: Supreme 0.54 %, Heavenly 0.033 % |
| `grade_bands` | 30 / 60 / 85 / 99 / 100 | keep in order | How talents are labelled |
| Effective talent clamp | 1–150 | upper 120–157; *derived*: presence above 157 with `mi_luc_price_per_point` 0.004 lets buy-sell loops profit (charm 0.4286 at 157). Raising the clamp past 157 needs the price knob lowered to ≤ 0.4286 ÷ (clamp − 50) | How far modifiers can push a talent |
| `stage_power_step` (Realms & Bottlenecks) | 0.15 | 0.10–0.20; *derived* hard limit < 0.244 | The in-realm ladder against the great-breakthrough jump |
| Realm multipliers and bases | as Formulas C | each realm ratio ≥ (1 + 3 × step)² (*derived*) | Realm jumps |
| `than_thuc_per_than_hon`, `khi_huyet_per_can_cot` | 1.0, 10 | ±50 % | How much soul strength and physique matter |
| `linh_luc_conversion` (#4) | 0.20 | 0.05–0.25 | #4's spiritual power: about +22 % at CF at physique 45, about +50 % at physique 100 |
| `dan_doc_divisor` (cultivation) | 200 | 200–400; *derived*: below 200 the slowdown would exceed the −50 % that Formula D's 0.5–1.0 output range promises | The cultivation slowdown at full toxicity (−50 % at 200) |
| `toxicity_effect_divisor` (pills) | 100 | 100–200 | Pill potency at high toxicity |
| `quality_effect_step` | 0.25 | 0.15–0.35 (*guess*) | How much a pill's quality raises its effect |
| `realm_scale_penalty` | 0.1 | 0.05–0.25 (*guess*) | How little a pill made for a lower realm still does |
| `cleanse_potency_floor` | 0.25 | 0.1–0.5 | How well cleansing works at toxicity 100 |
| `dan_doc_natural_decay`, `dan_doc_decay_per_purity` | 1.0, 0.05 | 0.5–2.0, 0.02–0.08 | Toxicity recovery; Water's value |
| `resist_factor_min` / `resist_factor_max` | 0.1 / 2.0 | 0.05–0.25 / 1.5–2.0 | Resistance floor and how much penalties bite |
| `failure_tam_ma_gain` (Realms & Bottlenecks) | 15 | 10–20 and at most `nascent_tam_ma_max`, as in Realms & Bottlenecks | Retry cost |
| `tam_ma_natural_decay` | 0.25 | 0.15–0.25; *derived*: Realms' n_90 (⌈90 ÷ (15 − decay × T_r)⌉) must stay at 7–10, which holds up to about 0.256 (at 0.5 it is 8 / 11 / 12 / 28) | Heart demon recovery |
| #25 threshold, divisor, deviation bonus | 50, 2, +100 | 40–60, 2–4, 50–100 | #25's reward and risk |
| `tam_ma_backlash_divisor` | 2 | 2–4 | How much Dao heart protects |
| `backlash_death_tam_ma_threshold` | 90 | 80–95 | When a deviation kills |
| `injury_recovery_frac_per_season` | 0.25 | 0.15–0.4 | How long injuries last |
| `failure_khi_huyet_loss_frac` | 0.4 | 0.2–0.5 | Injury from a failed breakthrough |
| `herb_growth_pct_per_purity`, `mission_income_pct_per_purity` | 0.8 % | 0.4–1.0 % | Wood's and Metal's value |
| `field_plots_per_purity`, `max_plots` | 0.04, 12 | *derived*: `max_plots` ≥ 3 + 4 + the tree's plots | Land |
| Fortune reward ceiling | 0.75 + 0.005 × fortune | base 0.6–0.9 | LLM reward size |
| Fortune in checks, duels | 0.002, 0.001 per point | 0–0.004, 0–0.002 | Luck against skill |
| `mi_luc_price_per_point` | 0.004 | 0.002–0.004; *derived*: ≤ 0.4286 ÷ (effective talent clamp − 50), which is 0.00429 at clamp 150, or buy-sell loops profit | Prices |
| Precision grid | 0.1 / 0.01 / 1 | fixed (Meridian Map, Formulas F) | Stacking |
| `ngo_tinh_divisor` | 200 | 150–300 | How much comprehension speeds cultivation: ×1.225 at 45 (200), ×1.30 at 45 (150). Moving it moves every realm's years (Realms years table) |
| `bonus_ceilings` | `herb_growth_pct` 10, `alchemy_success` 3, `lifespan_frac` 0.15 (04f; were 40 and 8) | 5–10, 2–3, 0.10–0.15: at most the current values until the bot run (AC-CG-60) confirms headroom; *derived*: the derived limit is Realms' `bonus_ceiling_target`: with `gate_factor` set to 1, each gate's birth-mix mean S at all ceilings, best plot play and one talisman ≤ 0.45, measured ≤ 0.48 (Realms AC-CG-60), which owns the computed figures. The target covers lives without extra plots; those are builds outside the target, per Realms AC-CG-60. Penalties apply after the cap (rule 14) | How far a dedicated alchemy build can push breakthrough odds and lifespan |

## Visual/Audio Requirements

Deferred to the Game UI GDD (system 37). Intent: grades get distinct colours, from Lower
to Heavenly; heart demon at 20 and above, and again at 90 and above, reads as danger.

## Game Feel

Not specified at this tier. Intent: the sheet should read like a cultivator's self-
knowledge. A roll of a Supreme talent should feel like news, and a modifier's source
should always be one `explain` away.

## UI Requirements

These apply to the Debug Terminal now and to the Game UI later.
- **The sheet.** It shows the six talents with base value, effective value and grade; the
  state values with their ranges; the four derived values; and the craft mastery levels.
- **`explain <stat>`.** It prints every source of any stat or derived value, every clamp
  line and the tree's capped share.
- **Thresholds.** Heart demon shows its bands (20, 50, 90) and the current qi deviation
  chance. Toxicity shows its cultivation and pill penalties. Vitality shows its band.
- **Warnings** (Advisor):
  - a pill whose potency will be cut by toxicity;
  - a talent pill that cannot be taken;
  - before a Nascent Soul attempt, heart demon high enough that one more failed
    breakthrough (its gain after resistance) would push it above 20.

## Cross-References

| Document | Relationship |
|---|---|
| `design/gdd/game-concept.md` | Character Stats (three layers, draft formulas), birth modes, Pillars 2 and 3 |
| `design/gdd/canh-gioi.md` | Stage multiplier (Formulas B), heart demon gain and decay, the Nascent Soul condition, qi deviation (rule 10, which must read `qi_deviation_pct`); Realms Formulas D (pill supply reads `herb_growth_pct`, `alchemy_success` and h); `bonus_ceiling_target` (AC-CG-60); this GDD answers its Open Questions 6 and 7 |
| `design/gdd/kinh-mach-do.md` | Acupoint modifiers, stat weights and precision (Formulas F), capabilities #4 and #25, the tree cap |
| `design/gdd/linh-can.md` | Element purities, base element count, root variant role lines and the generating-pair `cultivation_speed_pct` modifiers that enter the sheet |
| `design/gdd/cong-phap.md` | Technique bonuses through the provider interface, `tech_power` (Formulas C), and the slot-dependent lifespan years that Realms rule 14's confirmation covers |
| `design/glossary.md` | Terms |
| `assets/data/character_attributes.json`, `character_stat_labels.json`, `character_elements.json` | The data this GDD's keys change |
| `src/gameplay/character/stat_sheet.gd`, `character_rules.gd`, `src/gameplay/items/pill_effects.gd` | The code that builds this GDD |

## Acceptance Criteria

Drafted with `qa-lead`, which recomputed every GDD number in double precision.

- **Gate levels.** Logic, Integration and UI are BLOCKING; Config/Data is ADVISORY.
- **Logic suites** live in `tests/unit/character/` and **integration suites** in
  `tests/integration/character/`. Both extend `DaoTestSuite`, use an injected seeded RNG
  or stub, and compare floats with `assert_near` at 1e-6 unless stated.
- **UI evidence** is a debug-terminal transcript in
  `production/qa/evidence/debug-terminal/`.

**Talents**

- **AC-CS-01** [Logic] Formula A, statistical test. 200,000 Fated rolls from a fixed
  seed:
  - every value is an integer in 1–100;
  - grade shares are Lower 18.2 % ±0.5, Middle 65.1 % ±0.5, Upper 16.1 % ±0.5, Supreme
    0.54 % ±0.15 and Heavenly 0.033 % ±0.020 (percentage points);
  - raw values below 0.5 are 0.27 % ±0.06;
  - the same seed repeats the same sequence.
- **AC-CS-02** [Logic] Formula A. Stub raw values 72.4 / 103 / −3 / 30.49 / 30.5 give 72
  Upper / 100 Heavenly / 1 Lower / 30 Lower / 31 Middle.
- **AC-CS-03** [Logic] Rule 3. Bases 1, 30 → Lower; 31, 60 → Middle; 61, 85 → Upper;
  86, 99 → Supreme; 100 → Heavenly.
- **AC-CS-04** [Logic] Rule 2, Self-made birth.
  - All talents at 100 is accepted, and achievements are off: a stub achievement store
    receives no writes.
  - A value of 0 or 101 is rejected at input.
  - A Fated birth keeps achievements on.
- **AC-CS-05** [Logic] Rule 2. An origin's +5 fortune turns 98 into 100 (clamped) and 40
  into 45; the other talents are unchanged.
- **AC-CS-06** [Logic] Rule 4, Formulas D and edge cases. A fixture talent pill gives
  comprehension +5, with 2 uses, quality 0 and recipe toxicity 0, taken at toxicity 0.
  - From base 45: the pills give 50, then 55. The third is refused, is not consumed, and
    carries its own reason.
  - At base 100 it is refused and not consumed.
  - At base 97 it is consumed, gives 100, and its preview shows +3.
  - `talent_gain`: value 5 at potency 1.5 gives 8; value 2 at potency 0.75 gives 2; value 2
    at potency 0.48 and at potency 0 each give 1.
- **AC-CS-07a** [Logic] Rule 4 and edge cases. An event effect of −10 on base 5 gives 1,
  Lower, with the effective value still 1 or more.
- **AC-CS-07** [Logic] Rule 4.
  - Climbing QR → FE → CF never changes comprehension base 45.
  - A perk's +10 shows as a sheet modifier with the perk as its source, for an
    effective 55.
  - An event's +3 on base 99 gives 100.
- **AC-CS-08** [Logic] Formula B, for each of the six talent keys:
  - 45 + 10 = 55;
  - 5 − 10 → 1, with a clamp line;
  - 100 + 60 → 150, with a clamp line;
  - base 58 + 10 = 68, with the grade shown as Middle, from the base.

**State**

- **AC-CS-09** [Logic] Formula D, a toxicity-10 pill.
  - Resistance 20 / 95 / −100 / −150 gives a gain of 8.0 / 1.0 / 20.0 / 20.0.
  - A toxicity-10 pill with resistance 0 taken at toxicity 95 gives 100, not 105.
- **AC-CS-10** [Logic] Formula D example.
  - Potency is taken before the toxicity is added: +90.0 cultivation base (80.4 would
    fail).
  - Toxicity goes to 46.4, the cultivation multiplier is 0.768, and the next season's
    toxicity is 41.9.
- **AC-CS-11** [Logic] Rule 7.
  - At toxicity 100 without the flag: cultivation ×0.5 and a normal quality-2 pill's
    potency is 0.
  - With `dan_doc_no_penalty`: cultivation ×1.0 and the pill's potency is 1.5.
  - `pill_effect_pct` −150 gives potency 0.
  - A quality-0 lower-realm pill at toxicity 0 has potency 0.1.
- **AC-CS-12** [Logic] The cleansing floor, quality 0.
  - At toxicity 100: a toxicity cleanser and a heart demon calmer each have potency 0.25;
    a normal pill has 0.
  - At toxicity 80 a cleanser has 0.25; at 50 it has 0.5.
- **AC-CS-13** [Logic] Formula D decay.
  - Water 0 and no bonus decay 1.0 a season.
  - Toxicity 0.6 decays to 0.
  - `dan_doc_decay` −2 gives a decay of 0.
- **AC-CS-14** [Logic] Rule 8, Formula E. From a failed breakthrough's +15:
  - resistance 0 / 20 / −10 / 95 / −150 gives 15 / 12 / 16.5 / 1.5 / 30;
  - `safe_failure` at −10 gives 8.25, but an event's 15 is not halved;
  - #9's +2 at resistance 50 gives 1.0;
  - heart demon 95 + 15 gives 100.
- **AC-CS-15** [Logic] Formula E decay. 15 falls to 13.0 after 8 seasons; 0.1 falls to 0.
- **AC-CS-16** [Logic] Formula E example (Dao heart 30, 8 seasons apart):
  - heart demon after failures 1–4 is 15 / 28 / 41 / 54;
  - the qi deviation chance is 0 / 13 / 26 / 39 %, or 0 / 26 / 52 / 78 % with #25;
  - #25's attack line (+27.0) appears only after failure 4.
- **AC-CS-17** [Logic] Formula E clamps.
  - Heart demon 100 with Dao heart 1 and #25 gives 100 %.
  - 10 / 30 gives 0 %.
  - `qi_deviation_pct` −150 gives 0 %; +50 at 54 / 30 gives 58.5 %.
  - Dao heart 30 + 10 makes heart demon 54 give 34 %, proving the effective value is
    used.
- **AC-CS-18** [Integration] Gain before roll (Realms rule 10). Dao heart 30, stub draw
  0.70:
  - heart demon 80, then a failure → 95, chance 80 %, deviation, death. Rolling first
    would give 65 % and no deviation, so that fails the test;
  - heart demon 70, draw 0.69 → 85, a deviation that isn't fatal, vitality 0.05;
  - a forced deviation from 75 reaches exactly 90 and is fatal; from 74.9 it reaches 89.9
    and is not.
- **AC-CS-19** [Integration] The Realms failure contract. A failed FE→CF pill attempt
  with resistance 20:
  - heart demon +12.0, vitality 1.0 → 0.6;
  - with `safe_failure`, heart demon +6.0;
  - a combat kill without #9 leaves heart demon unchanged, and with #9 adds +2.0 before
    resistance (provisional until Combat exists; not blocking).
- **AC-CS-20** [Logic] Formula F, in tenths of a percent:
  - a failure: 1000 → 600 → 850 → 1000;
  - a deviation: 50 → 300 → 550 → 800 → 1000;
  - a failure at 300 → 50;
  - a failure at 50 → 50, still alive;
  - an event effect of 50 % at 1000 → 500, still alive;
  - an event effect of 15 % at 50 is fatal: the character is dead;
  - the same event with capability #5 unused: alive at 50, one stage lower;
  - a great breakthrough at 550 → 1000.
- **AC-CS-21** [Logic] Rule 17, #4's boundary.
  - Holding #4 at vitality 0.299, the −20 attack line is present.
  - At 0.05 plus one recovery (exactly 300) and at 0.30 set directly, it is absent.
  - Without #4 there is no line at 0.05.

**Derived values**

- **AC-CS-22** [Logic] Formula C table at talent 45. All 40 cells match the exact floats
  within 1e-6 (for example 65.25, 9,787.5, 580,000). The display rounds half away from
  zero, giving 65, 196, 653, 1,958 and 9,788.
- **AC-CS-23** [Logic] Formula C example. Divine sense 780.0; with `than_thuc_pct` +50,
  1,170.0.
- **AC-CS-24** [Logic] Floors.
  - `khi_huyet_pct` −150 → maximum vitality 1.
  - `linh_luc_pct` −200 → spiritual power 0.
  - `than_thuc_pct` −100 → divine sense 0.
- **AC-CS-25** [Logic] Rule 17, #4. CF ×1.00, physique 45:
  - spiritual power 6,000 without it, 7,350 with it;
  - with `linh_luc_pct` +50 it is 10,350, not 11,025;
  - adding `khi_huyet_pct` +20 gives 10,620.
- **AC-CS-26** [Integration] Realms' stage multiplier.
  - Stage 0 → 3 raises all four derived values ×1.45 (within 1e-9).
  - A stage loss from 2 to 1 moves all four from ×1.30 to ×1.15 together.
  - CF → NS takes divine sense from 652.5 to 1,350.
- **AC-CS-27** [Logic] An NPC and the player with identical inputs get identical derived
  values and qi deviation chance.
- **AC-CS-28** [Logic] Formula G.
  - Wood 60 with `herb_growth_pct` +10 → 1.48 × 1.1 = 1.628; Metal 50 → 1.4.
  - Wood 60 with `herb_growth_pct` sources summing to +40 → total 10, with a clamp line
    (40 → 10) → 1.628.
  - Earth 60 with +3 → 8 plots.
  - Earth 100 with +7 → 12 (clamped); Earth 0 with −5 → 1.
  - `herb_growth_pct` −150 → 0.
  - Plots are an integer.

**Stat sheet**

- **AC-CS-29** [Logic] Rule 13.
  - `attack_pct` +10 and +15 give multiplier 1.25, not 1.265.
  - −150 gives 0.
  - A flag at +1 is on; at +1 −1 or −1 it is off.
- **AC-CS-30** [Logic] Rule 12.
  - *(Provisional until Spirit Fields mastery and timed consumables have a built path,
    Open Question 6.)* Nine modifiers, one from each of rule 12's nine source kinds, keep
    their {source, stat, value} and sum to the total.
  - Unequipping a treasure removes its modifiers in the same call.
  - Artifact-local keys appear in no sheet total.
- **AC-CS-31** [Logic] Rule 14.
  - Tree 5.0 + 4.5 plus a perk's 12 → 20.0, with a clamp line from 9.5 to 8.0.
  - Tree 3.0 + 4.0 plus the perk → 19.0, with no clamp.
  - The perk alone → 12.0.
- **AC-CS-32** [Integration] Pill attempts use effective talents and the capped tree
  share, at FE→CF rank 0 with no talisman, tree 9.5 pp and a perk's 12 pp:
  - Realms receives q_tree 0.08 and q_bonus 0.12;
  - effective comprehension 20 (base 10 + 10) and Dao heart 20: the extras are 0.095, under
    the ceiling, and q = 0.26 (the base talents would give 0.255);
  - clamp case: comprehension 55 and Dao heart 40 effective: the extras are 0.1175, clamped
    to 0.10, and q = 0.265 (Realms AC-CG-25).
- **AC-CS-33** [Logic] Formula I, computed values.
  - #25 at heart demon 54.25 is stored as 271 units, at 50.1 as 250.
  - A computed 3.456 is stored as 345.
  - Ten +0.1 modifiers sum to exactly 10 units.
- **AC-CS-34** [Logic] Formula I, authored values.
  - `khi_van` 0.29 / 0.57 / 1.13 is stored as 29 / 57 / 113 units. A naive
    `floor(x * 100)` gives 28 / 56 / 112, so run it first and watch it fail.
  - An off-grid authored value (`field_plots` 2.5) fails validation.
- **AC-CS-35** [Logic] Rule 15.
  - A fixture with the key `atack_pct` fails validation, naming the key and its source.
  - Every rule 15 key passes.
  - [Integration] The same key in an LLM fill is repaired by the Meridian Map's validator
    and never reaches the sheet.
- **AC-CS-36** [Config/Data] Parameter keys.
  - Every listed `derived` value is present.
  - `stage_power_step` is one global 0.15.
  - The renamed `…_frac` keys are present and the old `…_pct` names are gone.
  - `vitality_floor` exists only as `breakthrough.vitality_floor`.
  - Every rule 15 key has a label entry with its unit, and the six talents show their
    `character_attributes.json` names.

**Capabilities**

- **AC-CS-37** [Integration] Rule 16. Opening notable #4 adds id 4; granting it again
  keeps the set at size 1; the sheet shows #4's lines.
- **AC-CS-38** [Integration] Rule 12. An acupoint giving comprehension +1.5 lands with
  source exactly `Kinh Mạch: <name> #<id>`, and effective comprehension rises by 1.5.
- **AC-CS-39** [Logic] Rule 18, #25.
  - The attack line is absent at heart demon 50.0, +25.0 at 50.1, and +27.1 at 54.25.
  - At 30 there is no attack line but `qi_deviation_pct` +100.
  - Without #25 there is neither line.
- **AC-CS-40** [Integration] Realms reads `qi_deviation_pct`. Heart demon 54, Dao heart
  30, draw 0.70: with #25 the roll uses 78 % and deviates; without it, 39 % and no
  deviation.
- **AC-CS-41** [Logic] #4 and #25 together, at heart demon 60 and vitality 0.2: attack
  lines −20 and +30, multiplier 1.10.

**Economy factors**

- **AC-CS-42** [Logic] Formula H, fortune.
  - Fortune 55 → reward ceiling 1.025, alchemy crit 0.0825.
  - Fortune 50 → 1.0; 1 → 0.755; 150 → 1.5.
  - Base 50 + 5 gives 1.025 (the effective value).
- **AC-CS-43** [Logic] Formula H, checks.
  - Stat 60, difficulty 50, fortune 70 → 0.64; when evading with stealth 10 → 0.74.
  - A fortune check omits the fortune term: fortune 70, difficulty 50 → 0.70, not 0.74.
  - The chance clamps to 0.95 and 0.05.
  - Duel fortune 80 against 30 → +0.05, kept within 0.02–0.98.
- **AC-CS-44** [Logic] Formula H, presence, on value 1,000.
  - Presence 70 → buy 1,380, sell 648.
  - Presence 150 → buy 900, sell 840; no loop profit.
  - Presence 1 → value 1 sells for 1.
  - Value 100 at charm 0.08 → buy ⌈138⌉ = 138, sell ⌊64.8⌋ = 64.
  - The attitude term published is presence − 50.
  - A product that is exactly an integer in exact arithmetic is not pushed up or down by
    floating-point error (the 1e-6 tolerance): value 1,000 at presence 150 buys for exactly
    900, not 901.
  - At every effective presence from 1 to 157 and values 1–10,000, the buy price is never
    below the sell price.

**Persistence**

- **AC-CS-45** [Logic] An in-memory round trip keeps every value equal: talent bases,
  state values, craft mastery, the capability set {4, 25}, the lifespan bonus from pills
  and pill use counts. The derived values match after load.
- **AC-CS-46** [Logic] Load hardening.
  - A save with no capabilities loads an empty set.
  - Heart demon 120 → 100, and toxicity −5 → 0.
  - Each clamp logs exactly one warning.

**UI (debug terminal transcripts)**

- **AC-CS-47** [UI] The sheet shows:
  - talents as base / effective and grade, e.g. "45 / 55 Middle";
  - presence by its label;
  - state values with their ranges, the four derived values and craft mastery.
- **AC-CS-48** [UI] `explain`.
  - `explain breakthrough_chance` shows two Meridian Map lines, the 9.5 → 8 clamp, the
    perk +12 and a total of 20.
  - `explain mi_luc` at 5 − 10 shows the clamp to 1.
- **AC-CS-49** [UI] Thresholds.
  - Heart demon 54 shows the 20 / 50 / 90 bands and 39 % (78 % with #25).
  - Toxicity 46.4 shows cultivation ×0.768 and potency ×0.536.
  - Vitality 0.25 shows "critical".
- **AC-CS-50** [UI] Advisor warnings:
  - a pill whose potency will be cut;
  - a talent pill refused at 100 and one with its uses spent, each with its own reason;
  - heart demon one failure away from 20 before a Nascent Soul attempt: with resistance
    20 (a failure adds 12), heart demon 9 warns (9 + 12 = 21) and 8 does not (8 + 12 = 20,
    which is not above 20).

- **AC-CS-51** [Logic] Rule 15, per-element stacking. With 3 base elements,
  `cultivation_speed_per_element_pct` +2 adds 6 to the cultivation speed percentage. With
  `cultivation_speed_pct` +10 as well, the rate multiplier is 1.16.
- **AC-CS-52** [Logic] Lifespan stacking. A realm lifespan of 200, a pill bonus of 10,
  `lifespan_years` +5 and `lifespan_pct` +10 give a cap of (200 + 10 + 5) × 1.10 = 236.5.
  With `lifespan_years` +30 instead, the bonus is min(40, 30) = 30 and the cap is
  (200 + 30) × 1.10 = 253, with a clamp line (Realms rule 14).
- **AC-CS-53** [Logic] Formulas J. Effective comprehension 1 / 45 / 50 / 100 / 150
  gives `comp` 1.005 / 1.225 / 1.25 / 1.5 / 1.75 with `ngo_tinh_divisor` 200, and the
  rate breakdown's comprehension line shows that value. A +10 comprehension modifier
  at base 45 gives 1.275.
- **AC-CS-54** [Logic] Rule 14, bonus ceilings.
  - Two technique `herb_growth_pct` 25 lines plus a tree +6 give a total of 10, with
    a clamp line; Wood purity 50 still multiplies herb growth by 1.4 on top.
  - Penalties after the cap: a +60 source with a −20 penalty gives 10 − 20 = −10, with a
    clamp line (60 → 10) and a separate penalty line; a +5 with a −20 gives
    −15, with no clamp line; +8 and +6 give 10, with a clamp line (14 → 10).
  - *(Provisional until system 14 defines the mastery curve.)* A Spirit Fields mastery
    `herb_growth_pct` +6 with a technique +8 gives 10, with a clamp line (14 → 10); the
    breakdown names the +6's source as the Spirit Fields craft.
  - `alchemy_success` 2 + 2 gives 3.
  - `alchemy_success` +2, +2 and +3 gives 3, with a clamp line (7 → 3).
  - At QR (base lifespan 120), a lifespan pill of 10 plus two `lifespan_years` 15
    lines give a lifespan bonus of 18, with a clamp line. At FE (200), a pill of 10
    plus one `lifespan_years` 15 line gives 25, under the ceiling of 30, with no
    clamp line.
  - `field_plots` and `lifespan_pct` are not clamped by these ceilings.
  - A stored lifespan bonus of 40 counts 18 in QR, 30 in FE and 40 in CF, with the raw
    sum unchanged. Every `lifespan_years` modifier is part of the sum and is clamped with
    the rest.
  - At QR, a pill of 10 plus two `lifespan_years` 15 lines and a `lifespan_years` −5
    line give 18 − 5 = 13. A −30 line alone gives −30, and the cap is 90, below the
    base of 120.
  - An equipped treasure with `lifespan_years` +10 adds 10 once, not twice.
- **AC-CS-55** [Logic] Rule 19, #2. Holding #2 adds a `than_thuc_pct` +20 line, and divine
  sense at CF ×1.00 with soul strength 45 goes from 450 to 540. Without #2 there is no
  line.
- **AC-CS-56** [Config/Data] Rule 14, `lifespan_pct`. Across the destiny perks and the tree
  keystones, the only `lifespan_pct` sources are `tho_nguyen` (+20) and the Wood keystone
  Vạn Cổ Trường Thanh (+25), summing to at most +45. With both at QR with a lifespan bonus
  of 18, the cap is 138 × 1.45 = 200.1.
- **AC-CS-57** [Integration] Heart demon thresholds. A template with `requires_tam_ma` 20
  is not eligible at 19.9 and is eligible at 20.0; the Nascent Soul condition holds at 20.0
  and fails at 20.1.

**Not testable here, by design:**
- That only the Meridian Map adds capabilities: a code-review and API-shape item.
- Event effects "inside the budget": blocked by Open Question 4.
- Combat-owned pieces beyond the fortune delta, and NPC `npc_effect` values (Meridian Map
  GDD).
- The talents' unbuilt roles, the attitude scale and Visual/Audio: Open Questions 2–5.

## Open Questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | ~~Spiritual Roots' purity rules and each root mutation's modifiers~~ **Answered 2026-11-04 by the Spiritual Roots GDD:** the purity rules and variant roles are in `linh-can.md` (redesigned 2026-11-04); the values here follow it | — | — |
| 2 | What attack and defense mean in combat, and how combat uses vitality (× max(v, 0.4) as built) | Combat GDD | The Combat keys in rule 15 |
| 3 | The NPC attitude scale that presence feeds | NPC Interaction GDD | Formulas H |
| 4 | Event Engine budgets for talent, heart demon and vitality effects | Event Engine GDD | Rule 4 (event talent changes) |
| 5 | The talents' unbuilt roles: soul strength's formation complexity and detection | the respective systems | Rule 1 |
| 6 | Specified here, not built yet: the provider interface for modifier sources; a talent pill's gain preview (AC-CS-06); the Advisor's per-pill warnings and the Nascent Soul heart demon warning (AC-CS-50; only the general toxicity and heart demon warnings exist); the vitality band names and heart demon bands on the sheet (AC-CS-49); load-time rejection of unknown stat keys and off-grid authored values (AC-CS-34, AC-CS-35); capability #9's +2 heart demon; Spirit Fields mastery's `herb_growth_pct` and timed consumables as sheet sources (AC-CS-30); automated tests for most ACs (`tests/unit/character/` covers few, and none carry AC ids) | implementation story | Building this GDD |
| 7 | ~~`lifespan_pct` is outside the lifespan ceiling; who may grant it?~~ **Answered 2026-11-05 (user decision):** the perk `tho_nguyen` (+20) and the Wood keystone (+25) are accepted, bound +45 in total (rule 14). Still open: any other source (a Way, a treasure) needs a price and must fit the bound, since it multiplies the whole cap and feeds pill supply through the growing years W; and no bot run has measured these two against the gate targets (AC-CG-60 does not include them) | user, Realms & Bottlenecks | Any new `lifespan_pct` source |

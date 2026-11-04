# Character Stats

> **Status**: Approved (2026-11-04, second lean /design-review; its 7 recommended items applied the same day). See `reviews/character-stats-review-log.md`.
> **Creative Director Review (CD-GDD-ALIGN)**: skipped (Lean mode)
> **Author**: user + Claude
> **Last Updated**: 2026-11-04
> **Last Verified**: 2026-11-04
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
  an event, a root mutation (biến dị).
- **State.** What changes every season: cultivation base (tu vi), age against lifespan
  (thọ nguyên), vitality (khí huyết), pill toxicity (đan độc), heart demon (tâm ma) and
  spirit stones (linh thạch).
- **Derived values.** What the first two produce: divine sense (thần thức), maximum
  vitality, spiritual power (linh lực) and the realm term of combat power (chiến lực). Each
  is a realm base × the stage multiplier × talent and modifiers.

Every modifier from anywhere (root mutations, the Meridian Map, the cultivation technique,
magic treasures, destiny perks, formations, capabilities) lands on one stat sheet with its
source, so any total can be explained. Craft mastery (đạo nghệ) skills sit alongside and
rise only by practice.

The system exists because every other system speaks through it. It owns the stat keys,
their units and meaning, and the character's capability set. It never decides when stats
rise (Realms & Bottlenecks does) or what a node gives (the Meridian Map does). It carries
two pillars:
- **Pillar 3:** talent is the hand you are dealt, and power is what you build with it.
- **Pillar 2:** every number on the sheet has a visible breakdown.

## Detailed Design

This section documents the system as built, plus the contracts the approved Realms &
Bottlenecks and Meridian Map GDDs rely on. Changes from the built game are marked
**(change)**.

### Core Rules

**Innate talent (thiên phú)**

1. **The six talents.** Values are integers.

   | Talent | Key | Drives |
   |---|---|---|
   | Comprehension (ngộ tính) | `ngo_tinh` | Cultivation speed, learning techniques, enlightenment (đốn ngộ), recipes, pill-attempt breakthrough chance |
   | Physique (căn cốt) | `can_cot` | Maximum vitality, pill-toxicity resistance, body cultivation |
   | Soul strength (thần hồn) | `than_hon` | Divine sense: magic treasure control, detection, formation complexity |
   | Fortune (khí vận) | `khi_van` | Lucky encounters (kỳ ngộ), rare finds, crafting crits, the ceiling of LLM-invented rewards |
   | Dao heart (đạo tâm) | `dao_tam` | Resisting heart demon and qi deviation; pill-attempt breakthrough chance |
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
     `max_uses`;
   - an event effect inside the Event Engine's budget.

   The base value stays clamped to 1–100. Climbing realms never changes it. Root
   mutations give modifiers, not base changes.
5. **Effective talent.** Effective value = base + the stat sheet's flat modifiers on that
   talent's key, clamped to 1–150. Every rule that reads a talent reads the effective
   value. The grade shown is the base value's grade.

**State**

6. **State values.** Each is a number held on the character:

   | Value | Range | Owner of its rules |
   |---|---|---|
   | Cultivation base (tu vi) | ≥ 0 | Realms & Bottlenecks |
   | Age | years, +0.25 per season | Time & Turn |
   | Vitality (khí huyết, current) | a fraction of maximum, 0.05–1.0 while alive | this GDD |
   | Pill toxicity (đan độc) | 0–100, decimal | this GDD |
   | Heart demon (tâm ma) | 0–100, decimal | this GDD |
   | Spirit stones (linh thạch) | integer ≥ 0 | Market |

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
   - **Decay:** `tam_ma_natural_decay` per season (**change**: 0.5 → 0.25, set by Realms &
     Bottlenecks). Calming pills and events can lower it further.
   - **Effects:** see the thresholds table under States and Transitions.
9. **Vitality.**
   - **Losses:** failed breakthroughs (40 % of maximum), fights and events. It never
     falls below 5 % while alive.
   - **Recovery:** `injury_recovery_frac_per_season` of maximum each season.
   - A great breakthrough refills it.
   - A qi deviation sets it to the 5 % floor (Realms & Bottlenecks rule 10).

**Derived values**

10. **The four realm-scaled values.** Each takes the realm's multiplier and the stage
    multiplier from Realms & Bottlenecks, ×1.00 to ×1.45 (**change**: today only combat
    power uses the stage multiplier):
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

12. **Modifiers.** Every bonus is a modifier {source, stat, value}. Sources:
    - root mutations;
    - Meridian Map acupoints and capabilities;
    - the active cultivation technique;
    - equipped magic treasures (artifact-local keys excluded: Combat applies them);
    - destiny perks;
    - formations.

    The sheet keeps every modifier with its source, so `explain` can show any total.
13. **Stacking.**
    - Values of the same key **add**.
    - A `_pct` key then applies once, as × (1 + total ÷ 100).
    - A flag key (`unit: flag`) is on when its total is above 0.
    - Talent keys add flat to the effective talent (rule 5).
    - `cultivation_speed_per_element_pct` is multiplied by the root's base element count and
      added to the `cultivation_speed_pct` total before the single multiplier, as built.
    - `lifespan_years` and `lifespan_pct` stack by these rules; Cultivation owns the
      lifespan formula (realm lifespan + `lifespan_years`, then × (1 + `lifespan_pct` ÷ 100)).
14. **Per-source caps.** Only one exists: the Meridian Map's acupoints may contribute at
    most `tree_breakthrough_cap` (8 pp) to `breakthrough_chance`. It is applied to the
    tree's modifiers only, and the sheet shows the clamp as a line. Other sources of the
    same key are not capped by it.
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
    | Toxicity and heart demon | `tam_ma_resist_pct`, `dan_doc_resist_pct`, `pill_effect_pct` (pct); `dan_doc_decay` (flat per season); `dan_doc_no_penalty`, `safe_failure` (flag); **(new)** `qi_deviation_pct` (pct: the qi deviation chance is × (1 + total ÷ 100); +100 doubles it) |
    | Lifespan | `lifespan_years` (years), `lifespan_pct` (pct) |
    | Crafts and economy | `alchemy_success`, `refining_success`, `formation_power_pct`, `herb_growth_pct`, `mission_income_pct` (pct); `alchemy_yield` (flat pills); `field_plots` (flat, integer) |
    | World | `travel_speed_pct`, `co_duyen_pct` (pct); `stealth` (flat) |
    | Talents | `ngo_tinh`, `can_cot`, `than_hon`, `khi_van`, `dao_tam`, `mi_luc` (flat, onto the effective talent) |

    A key not in this table is rejected by data validation, and an LLM-written fill is
    repaired (the Meridian Map's validator). `mi_luc` needs a display label
    (**change**: it is missing from `character_stat_labels.json`).

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

**What the player cannot do:**
- raise a talent's base value above 100 or permanently by more than the pills' use
  limits;
- raise talents by climbing;
- edit the capability set directly;
- carry modifiers from a magic treasure that isn't equipped.

### States and Transitions

The character is Alive or Dead. Death comes from old age, a fatal qi deviation or a fatal
event; Realms & Bottlenecks and Time & Turn own those triggers.

Heart demon has thresholds rather than states:

| Heart demon | What it means |
|---|---|
| 0–20 | Calm. The Nascent Soul breakthrough condition holds (≤ 20) |
| above 20 | Heart demon intrusion events become eligible (`requires_tam_ma` 20, as built); the Nascent Soul condition fails |
| above 50 | Capability #25 adds attack |
| 90 and above | A qi deviation after a failed breakthrough kills |

Vitality bands, for display and the Advisor:
- full: 100 %;
- injured: below 50 %;
- critical: below 30 %, where capability #4 adds its −20 % attack;
- floor: 5 %.

### Interactions with Other Systems

Spiritual Roots, Time & Turn, Combat, Event Engine and the crafts have no GDD yet; their
interfaces are provisional.

| System | Direction | Data | Interface owner |
|---|---|---|---|
| Spiritual Roots (Linh Căn) | in | per-element purity, root mutations (their modifiers), base element count, and one `cultivation_speed_pct` +3 modifier per generating pair owned (source "Tương sinh: <from> → <to>") | Spiritual Roots |
| Realms & Bottlenecks | in / out | in: realm, level, stage multiplier, heart demon +15 per failure, vitality −40 %; out: effective comprehension and Dao heart, `breakthrough_chance` (tree share capped), `qi_deviation_pct`, `safe_failure`, heart demon | Realms (the ladder); this GDD (the stats) |
| Meridian Map (Kinh Mạch Đồ) | in | acupoint modifiers {source, stat, value}; capability ids into the set | Meridian Map (what nodes give); this GDD (keys, units, the set) |
| Cultivation Techniques | in | technique bonuses (modifiers) and technique power for spiritual power | Cultivation Techniques |
| Item DB (magic treasures, pills) | in | equipped treasure affixes; pill effects (toxicity, talent pills, heart demon pills) | Item DB |
| Progression Edges | in | destiny perk modifiers and flags | Progression Edges |
| Formations | in | formation modifiers (`density_bonus` and others) | Formations |
| Combat | out / in | out: attack, defense, the four derived values, artifact-local keys; in: vitality loss | Combat |
| Event Engine | in / out | in: heart demon, talent and vitality effects inside budget; out: fortune (reward ceiling), heart demon thresholds (event eligibility) | Event Engine |
| Market, NPC Interaction | out | presence (prices, attitude) | Market, NPC Interaction |
| Crafts (Alchemy, Artifact Refining, Talismans, Spirit Fields, Beast Taming) | out | craft mastery levels, element multipliers, craft stat keys | each craft |
| Guidance Layer, Debug Terminal, Game UI | out | the sheet, `explain` breakdowns, grades, thresholds | Guidance Layer |
| Save/Load | out | talents, state values, craft mastery, the capability set, talent-pill use counts | Save/Load |

## Formulas

Proposed with `systems-designer` (2026-11-04). Values marked *guess* need a bot run;
**(change)** marks a difference from the code or data as built. Realm abbreviations: QR,
FE, CF, NS, DT (`design/glossary.md`).

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

**Example:** comprehension base 45 plus a Stars (Tinh Thần) mutation's +10 = **55**.
Presence base 5 with a Death (Tử) mutation's −10 → clamped to **1**.

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

`pill_potency = (1 + q_step · quality) · P_dd · max(0, 1 + pill_effect_pct/100) · [0.1 if made for a lower realm]`, with `P_dd = 1 if dan_doc_no_penalty, else max(floor_c, 1 − dd/D_p)`

`decay = max(0, d_nat + k_w · purity_water + dan_doc_decay)` ; `dd' = max(0, dd − decay)` each season

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| tox_pill | float | 0–about 20 | data file (recipe `toxicity`) | The pill's toxicity |
| R_d | float | −100 to 90 | calculated (`dan_doc_resist_pct`) | Toxicity resistance; negative from penalties |
| f_min, f_max | float | 0.1, 2.0 | data file | Resist factor clamp. **(change)** f_max was 1.0, which ignored penalties |
| dd | float | 0–100 | calculated | Current toxicity |
| D_c | float | 200 | data file (`dan_doc_divisor`) | Cultivation divisor: at most −50 % (kept on purpose) |
| D_p | float | 100 | data file (`toxicity_effect_divisor`) | Pill divisor: potency can fall to 0 (kept on purpose) |
| floor_c | float | 0.25 for cleansing pills, 0 otherwise | data file (`cleanse_potency_floor`) | **(change)** Cleansing pills (toxicity and heart demon types) keep at least 25 % strength, which removes the soft lock at toxicity 100 |
| q_step | float | 0.25 | data file (`quality_effect_step`) | Potency per quality grade |
| d_nat, k_w | float | 1.0, 0.05 | data file (`dan_doc_natural_decay`, `dan_doc_decay_per_purity`) | Natural decay and Water purity factor |

**Output Range:**
- gain: 0.1 to 2.0 × the pill's toxicity;
- cultivation multiplier: 0.5–1.0;
- potency: 0 upward;
- decay: 0 upward.

Potency is computed before the pill's own toxicity is added. **(change)**
`dan_doc_no_penalty` protects pill potency as well as cultivation, as rule 7 states.

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
| d_t | float | 0.25 per season | data file (`tam_ma_natural_decay`) | **(change)** was 0.5 |
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

`v' = max(v_floor, v − loss)` ; `v' = min(1, v + r_v)` each season ; `attack_pct −20 while v < 0.30` (capability #4)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| v | float | 0.05–1.0 | calculated | Current vitality as a fraction of maximum |
| v_floor | float | 0.05 | data file | Floor while alive |
| loss | float | 0.4 per failed breakthrough; fights and events vary | data file (`failure_khi_huyet_loss_frac`, **(change)** renamed from `…_pct`: it holds a fraction) | |
| r_v | float | 0.25 | data file (`injury_recovery_frac_per_season`, **(change)** renamed) | Recovery per season |

**Output Range:** 0.05–1.0. A great breakthrough sets v = 1. Combat reads vitality as
× max(v, 0.4). Vitality is compared in integer tenths of a percent, round(v × 1000) half away from
zero, so 0.05 + 0.25 lands exactly on 300.

**Example:** a failure takes vitality from 1.0 to 0.6, then 0.85, then 1.0. A qi
deviation sets 0.05, then 0.30, 0.55, 0.80 and 1.0.

### G. Element-driven multipliers

The element_multipliers formulas are defined as:

`herb_growth = (1 + k_h · purity_wood) · max(0, 1 + herb_growth_pct/100)`

`mission_income = (1 + k_m · purity_metal) · max(0, 1 + mission_income_pct/100)`

`plots = clamp(base_plots + ⌊k_f · purity_earth⌋ + total(field_plots), 1, max_plots)`

Toxicity decay is in D. `total(field_plots)` is the stat sheet's `field_plots` total.
**(change)** Rule 11 is corrected to match: herb growth and mission income multiply; field
plots and toxicity decay add.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| purity_* | float | 0 (absent), 10–100 | calculated (Spiritual Roots) | Element purity |
| k_h, k_m | float | 0.008, 0.008 | data file (`herb_growth_pct_per_purity`, `mission_income_pct_per_purity`, stored as 0.8 %) | Per purity point |
| k_f | float | 0.04 | data file (`field_plots_per_purity`) | Plots per Earth purity point |
| base_plots, max_plots | int | 3, 12 | data file | |

**Output Range:** herb growth and mission income ≥ 1.0 before the stat (at most 1.8 from
purity); field plots 1–12.

**Example:** Wood 60 with `herb_growth_pct` +40 → 1.48 × 1.4 = **2.07**. Earth 60 with
`field_plots` +3 → 3 + 2 + 3 = **8** plots.

### H. Fortune and presence factors

These formulas use fortune and presence as the code does today; this GDD owns them, and
the listed systems consume them.

| Formula | Consumer |
|---|---|
| Reward ceiling = `0.75 + 0.005 · eff(khi_van)` (× the event budget's spirit stone and cultivation base caps) | Event Engine |
| Check chance = `clamp(0.5 + (stat − difficulty) · 0.01 + (eff(khi_van) − 50) · 0.002 [+ stealth · 0.01 when evading], 0.05, 0.95)` | Event Engine |
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

`mult(k) = max(0, 1 + total(k)/100)` for `_pct` keys ; `flag(k) = total(k) > 0`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| v_i | int (precision units) | per key | calculated | One modifier, quantized once when it enters the sheet |
| cap_tree | float | 8 pp | data file (`tree_breakthrough_cap`, owned by the Meridian Map) | Cap on the tree's share |

**Output Range:** multipliers ≥ 0; flags 0/1. Spiritual Roots' generating-pair modifiers
(`cultivation_speed_pct` +3 each, 0–15 in all) are ordinary entries in the sum.

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
**20**.

### Parameter keys

**`character_attributes.json`:**
- `roll` {mean 45, sd 16, min 1, max 100}; `grade_bands`.
- `derived`:
  - `than_thuc_per_than_hon` 1.0, `khi_huyet_per_can_cot` 10;
  - `dan_doc_natural_decay` 1.0;
  - `tam_ma_natural_decay` 0.25 **(change)**;
  - `injury_recovery_frac_per_season` 0.25 **(rename)**;
  - `vitality_floor` 0.05;
  - `resist_factor_min` 0.1, `resist_factor_max` 2.0 **(new)**;
  - `cleanse_potency_floor` 0.25 **(new)**;
  - `linh_luc_conversion` 0.20 (#4) **(new)**;
  - `effective_talent_min` 1, `effective_talent_max` 150 **(new: hard-coded in
    `stat_sheet.gd` today)**;
  - `heart_demon_strength` {threshold 50, divisor 2, deviation_pct 100} for #25 **(new)**.

**`events_budgets.json`, `combat_rules.json`, `items_recipes.json`, `session_actions.json`**
(the fortune and presence factors, Formulas H; each key moves to data if it is
hard-coded):
- `khi_van_reward_base` 0.75, `khi_van_reward_per_point` 0.005;
- `khi_van_check_per_point` 0.002, `khi_van_duel_per_point` 0.001,
  `khi_van_crit_per_point` 0.15 (%);
- `mi_luc_price_per_point` 0.004.

**`cultivation_realms.json`:**
- per realm: `than_thuc_mult`, `khi_huyet_mult`, `linh_luc_base`, `power_base` (unchanged);
- `stage_power_step` 0.15, one global key **(change)**: it is per realm today, at 0.08
  for QR and 0.3 for the rest;
- `breakthrough.failure_khi_huyet_loss_frac` 0.4 **(rename)**.

**`character_stat_labels.json`:**
- add `qi_deviation_pct` and `mi_luc` **(new)**;
- give the six talent keys labels.

## Edge Cases

**Talents**

- **If a talent pill would raise a base already at 100, or the pill's per-life uses are
  spent:** it cannot be taken and is not consumed. The item explains why.
- **If a talent pill would overshoot 100** (for example +5 at 97): it is taken, consumed
  and clamped at 100. Its preview shows the real gain (+3) first.
- **If an origin bonus would push a talent above 100:** it is clamped to 100.
- **If an event or pill would lower a talent's base below 1:** it is clamped to 1. The
  grade is Lower, and the base never reads 0 or negative.
- **If modifiers push an effective talent below 1 or above 150:** it is clamped. The
  breakdown shows the clamp line.
- **If a Self-made birth sets every talent to 100:** that is allowed. Achievements are
  off for that life.

**State**

- **If a pill is taken at toxicity 100:** the gain is clamped at 100. A normal pill's
  potency is 0; a cleansing pill keeps 25 %. Before the player takes it, the Advisor warns
  what the pill will actually do.
- **If heart demon or toxicity would go below 0 or above 100:** it is clamped.
- **If resistance goes below −100:** the factor stops at ×2.0. Above 90 % it stops at
  ×0.1, so a gain never disappears entirely.
- **If vitality is at the 5 % floor and takes more damage:** it stays at 5 %. Only an
  explicit cause (old age, a fatal qi deviation, a fatal event) kills.
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
- **If a magic treasure is unequipped:** its modifiers leave the sheet immediately.
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

Only Realms & Bottlenecks and the Meridian Map have GDDs among the systems below; every
other interface is provisional. When each GDD is written, it must list Character Stats in
its own Dependencies section.

**Upstream (hard):**

| # | System | What Character Stats needs from it |
|---|---|---|
| 1 | Data-Driven Config | `character_attributes.json`, `character_stat_labels.json`, `character_elements.json`, the realm multipliers in `cultivation_realms.json` |
| 2 | Deterministic Simulation Core | The seeded RNG for talent rolls; Breakdown for every derived value |
| 6 | Spiritual Roots (Linh Căn) | Element purities, root mutations and their modifiers, base element count, generating-pair `cultivation_speed_pct` modifiers (up to +15 in all; they stack additively under Formulas I) |

**Modifier and value sources (soft).** Each pushes values into the sheet through one
provider interface. Character Stats never calls them, which breaks the cycles described
below.

| # | System | What it provides | Without it |
|---|---|---|---|
| 8 | Realms & Bottlenecks | Realm, level and stage multiplier, held on the character | Every realm-scaled value stays at QR early |
| 10 | Meridian Map | Acupoint modifiers and capability ids | No tree bonuses |
| 9 | Cultivation Techniques | Technique bonuses and technique power | Spiritual power at power 1.0 |
| 13 | Item DB | Equipped treasure affixes and pill effects | No item bonuses |
| 11 | Progression Edges | Destiny perk modifiers and flags | No player edge |
| 17 | Formations | Formation modifiers | No formation bonuses |

**Downstream:**
- **Every system that reads a stat:** Realms & Bottlenecks, Combat, Event Engine, Market,
  NPC Interaction, every craft, Travel & Map, NPC Builds, the Living World Tick, Guidance
  and the UI, Save/Load and the Balance Harness.
- **Capability #4 and #25 behaviour** is hosted here.

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
| `cleanse_potency_floor` | 0.25 | 0.1–0.5 | How well cleansing works at toxicity 100 |
| `dan_doc_natural_decay`, `dan_doc_decay_per_purity` | 1.0, 0.05 | 0.5–2.0, 0.02–0.08 | Toxicity recovery; Water's value |
| `resist_factor_min` / `resist_factor_max` | 0.1 / 2.0 | 0.05–0.25 / 1.5–2.0 | Resistance floor and how much penalties bite |
| `failure_tam_ma_gain` (Realms & Bottlenecks) | 15 | *derived*: above 10 and below the Nascent Soul limit of 20 | Retry cost |
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

## Visual/Audio Requirements

Deferred to the Game UI GDD (system 37). Intent: grades get distinct colours, from Lower
to Heavenly; heart demon above 20, and again above 90, reads as danger.

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
| `design/gdd/canh-gioi.md` | Stage multiplier (Formulas B), heart demon gain and decay, the Nascent Soul condition, qi deviation (rule 10, which must read `qi_deviation_pct`); this GDD answers its Open Questions 6 and 7 |
| `design/gdd/kinh-mach-do.md` | Acupoint modifiers, stat weights and precision (Formulas F), capabilities #4 and #25, the tree cap |
| `design/glossary.md` | Terms |
| `assets/data/character_attributes.json`, `character_stat_labels.json`, `character_elements.json` | The data this GDD's keys change |
| `src/gameplay/character/stat_sheet.gd`, `character_rules.gd`, `src/gameplay/items/pill_effects.gd` | Code the (change) items touch |

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
- **AC-CS-06** [Logic] Rule 4 and edge cases. A fixture talent pill gives comprehension
  +5, with 2 uses.
  - From base 45: the pills give 50, then 55. The third is refused, is not consumed, and
    carries its own reason.
  - At base 100 it is refused and not consumed.
  - At base 97 it is consumed, gives 100, and its preview shows +3.
- **AC-CS-07a** [Logic] Rule 4 and edge cases. An event effect of −10 on base 5 gives 1,
  Lower, with the effective value still 1 or more.
- **AC-CS-07** [Logic] Rule 4.
  - Climbing QR → FE → CF never changes comprehension base 45.
  - A Stars mutation shows as a +10 sheet modifier with the mutation as its source, for an
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
  - a 0.5 loss at 50 → 50, still alive;
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
  - Wood 60 with +40 → 2.072; Metal 50 → 1.4.
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
  - Six modifiers from six source kinds keep their {source, stat, value} and sum to the
    total.
  - Unequipping a treasure removes its modifiers in the same call.
  - Artifact-local keys appear in no sheet total.
- **AC-CS-31** [Logic] Rule 14.
  - Tree 5.0 + 4.5 plus a perk's 12 → 20.0, with a clamp line from 9.5 to 8.0.
  - Tree 3.0 + 4.0 plus the perk → 19.0, with no clamp.
  - The perk alone → 12.0.
- **AC-CS-32** [Integration] Pill attempts use effective talents and the capped tree
  share. Comprehension 55 effective, Dao heart 40 effective, with the AC-CS-31 modifiers,
  at FE→CF rank 0 with no talisman:
  - Realms receives q_tree 0.08 and q_bonus 0.12;
  - q = 0.3975 (base talents would give 0.39).
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
  - Every rule 15 key has a label, including `mi_luc`, `qi_deviation_pct` and the six
    talents.

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
  state values, craft mastery, the capability set {4, 25} and talent-pill use counts. The
  derived values match after load.
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

**Not testable here, by design:**
- That only the Meridian Map adds capabilities: a code-review and API-shape item.
- Event effects "inside the budget": blocked by Open Question 4.
- Combat-owned pieces beyond the fortune delta, and NPC `npc_effect` values (Meridian Map
  GDD).
- The talents' unbuilt roles, the attitude scale and Visual/Audio: Open Questions 2–5.

## Open Questions

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | Spiritual Roots' purity rules and each root mutation's modifiers (provisional here) | Spiritual Roots GDD | Rules 11 and 12, Formulas G |
| 2 | What attack and defense mean in combat, and how combat uses vitality (× max(v, 0.4) as built) | Combat GDD | The Combat keys in rule 15 |
| 3 | The NPC attitude scale that presence feeds | NPC Interaction GDD | Formulas H |
| 4 | Event Engine budgets for talent, heart demon and vitality effects | Event Engine GDD | Rule 4 (event talent changes) |
| 5 | The talents' unbuilt roles: physique's body cultivation; soul strength's formation complexity and detection | the respective systems | Rule 1 |
| 6 | Implementation changes: the resist clamp to 2.0; `dan_doc_no_penalty` also covering pills; the cleansing floor; two key renames; `stage_power_step` as one global key; derived values taking the stage multiplier; the new `qi_deviation_pct` key, which Realms & Bottlenecks rule 10 must read; the `mi_luc` and talent labels; the provider interface for modifier sources | implementation story | Building this GDD |

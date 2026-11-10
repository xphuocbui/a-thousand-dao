# Combat economy revision (#44): decision list

Drafted 2026-11-09 from combat.md Open Question 26, `design/research/sustain-audit-2026-11-08.md` (its six problems
and the element stacks section) and the user's direction of 2026-11-08 and 2026-11-09. No GDD has been changed for
#44 yet. Each item gives the problem, the options and my recommendation; the user decides. Answer in batches (A to E),
the way #43 ran.

**The user's direction, fixed:**
- Sustain is king. Linh lực regeneration, gain, cost reduction, paying with health and health regeneration have many
  sources. All-in burst builds stay possible but rare.
- Same-realm fights last 30–60 s; art cooldowns 0.5–12 s; short fights only across a realm gap.
- Fatigue damage may end stalls. Longer fights and stronger wards are fine.
- Mana-based công pháp must work: damage scaling on remaining linh lực, overflow linh lực into a shield or damage.
- Element stacks join the fight (sustain audit § Element stacks): a buff and a debuff per element, no cap, cleansing
  as the answer.

**Why the fight is short today.** A typical Qi Refining mirror lasts about 8 s. Art costs are 4–25 % of the pool
(`cost_share`) and the base regeneration is 2 % a second (`regen_cap` 8 %), so the pool runs dry at 3–6 s. Health is
16 fight units against offence of about 36 a second. Three more timers are set for 8 s: healing decays to 10 % by
15 s, upkeep wards grow 15 % a pulse, and the ward price check (`T_ref`) assumes an 8 s fight.

## Summary table

| ID | Batch | Question | Recommendation |
|---|---|---|---|
| A1 | Time | Target fight length | **Decided as recommended (2026-11-09):** Typical same-realm mirror 45 s (band 30–60 s); time limit 120 s |
| A2 | Time | Cooldown range | **Decided as recommended (2026-11-09):** 0.5–12 s (from 0.5–30 s) |
| A3 | Time | Fatigue | **Decided as recommended (2026-11-09):** From 60 s, unblockable damage rising each second |
| A4 | Time | How fights get longer | **Decided as recommended (2026-11-09):** Raise health and wards ×~4; keep damage numbers |
| A5 | Time | The price check's reference fight | **Decided as recommended (2026-11-09):** `T_ref` 8 s → 45 s |
| B1 | Linh lực | How fast an unbuilt pool runs dry | **Decided as recommended (2026-11-09):** Unbuilt dry at 15–20 s; a sustain build never dry |
| B2 | Linh lực | The regeneration cap | **Decided as recommended (2026-11-09):** Replace the hard cap with diminishing returns |
| B3 | Linh lực | Gain on hit, crit, kill and leech | **Decided as recommended (2026-11-09):** Allow as plain modifiers (a narrow exception, like conversion) |
| B4 | Linh lực | Paying with health as a stat | **Decided as recommended (2026-11-09):** Yes, a plain modifier |
| B5 | Linh lực | Increased regeneration (%) beside flat | **Decided as recommended (2026-11-09):** Yes |
| B6 | Linh lực | Burst builds rare | **Decided as recommended (2026-11-09):** By content and cost, no special rule |
| B7 | Linh lực | Mana-based công pháp hooks | **Decided as recommended (2026-11-09):** Two readable quantities: remaining share and overflow |
| C1 | Health | Healing decay | **Decided (user, 2026-11-09): removed.** Healing keeps full strength all fight |
| C2 | Health | Upkeep wards | **Decided (user, 2026-11-09): removed.** Wards pay by reserve, per hit, drain or cast |
| C3 | Health | Heal and tick caps per pulse | **Decided (user, 2026-11-09): both removed.** No cap on healing, no cap on ticks |
| D1 | Stacks | Existing statuses | **Decided as recommended (2026-11-09):** Burn → Fire, Poison → Wood; Frostbite and Shock retire |
| D2 | Stacks | Numbers per stack | **Decided as recommended (2026-11-09):** The 1 % family below, to tune with the harness |
| D3 | Stacks | Stacks against existing caps | **Decided as recommended (2026-11-09):** Global caps hold; curse caps don't apply to stacks |
| D4 | Stacks | Stack timers | **Decided as recommended (2026-11-09):** Each grant is a batch with its own timer |
| D5 | Stacks | Cleansing | **Decided as recommended (2026-11-09):** A cleanse removes a number of stacks, oldest first |
| D6 | Stacks | Which element a stack belongs to | **Decided as recommended (2026-11-09):** The art's element tag, not its damage type |
| D7 | Stacks | Pricing and modifiers | **Decided as recommended (2026-11-09):** Granting stacks is an Effect; stack strength and duration are modifiers |
| D8 | Stacks | Enemies, beasts, tribulations | **Decided as recommended (2026-11-09):** Same rules, same schema |
| E1 | Work | How numbers are set | **Decided as recommended (2026-11-09):** A small fight simulator first, then the GDD edits |
| E2 | Work | Order of the GDD edits | **Decided as recommended (2026-11-09):** Combat, Defence, Effects, Modifiers, Character Stats |
| E3 | Work | Catalogue variety | **Decided as recommended (2026-11-09):** Scoped rows for maximum linh lực, regeneration and health regeneration |

---

## A. Time

### A1. Target fight length — **decided as recommended** (user, 2026-11-09)
Today about 8 s; the direction says 30–60 s; `time_limit` is 40 s.
- **Options:** (a) aim at 30 s; (b) aim at 45 s; (c) aim at 60 s.
- **Recommendation: (b), 45 s for the typical mirror, band 30–60 s**, with `time_limit` raised to 120 s so fatigue
  (A3), not the clock, ends most stalls. A realm gap of one keeps fights under 10 s.

### A2. Cooldown range — **decided as recommended** (user, 2026-11-09)
The direction says 0.5–12 s (today 0.5–30 s). In a 45 s fight a 12 s art fires 3–4 times; a 30 s one once.
- **Recommendation: 0.5–12 s**, existing arts above 12 s re-authored when the content is written. `cooldown_min`
  stays 0.5 s.

### A3. Fatigue — **decided as recommended** (user, 2026-11-09)
Nothing ends a stall but the time limit (a draw).
- **Options:** (a) fatigue damage: from `fatigue_start`, both sides lose a rising share of maximum health a pulse,
  passing wards, shields and resistance; (b) fatigue on regeneration only (both pools regenerate less); (c) both.
- **Recommendation: (a), from 60 s, 1 % of maximum health a pulse, +1 % each further pulse.** A side still standing at
  about 75 s is in real danger; sustain still wins the 30–60 s band. It is not healing, not a status, and cannot be
  cleansed.

### A4. How fights get longer — **decided as recommended** (user, 2026-11-09)
Fights are damage against effective health; lengthening them ×5 needs one side of that to move.
- **Options:** (a) cut damage (every `c_art` ÷ 5); (b) raise health and ward strength (`health_units`, ward payloads);
  (c) a mix.
- **Recommendation: (b), about ×4 effective health, then the harness tunes.** Damage numbers stay readable and the
  existing art lint stays valid; wards matter more, which the user accepts. The rest of the length comes from
  pools no longer running dry (B1).

### A5. The price check's reference fight — **decided as recommended** (user, 2026-11-09)
The ward price check (`T_ref` 8 s) prices upkeep, drain and cast wards for an 8 s fight.
- **Recommendation: `T_ref` 45 s**, matching A1. Every ward's price is re-checked with the harness (E1).

## B. Linh lực

### B1. How fast an unbuilt pool runs dry — **decided as recommended** (user, 2026-11-09)
Today 3–6 s.
- **Options:** (a) cut art costs (`cost_share` 0.04–0.25 → 0.02–0.10); (b) raise base regeneration (2 % → 4–5 %);
  (c) both.
- **Recommendation: (c), with a target, not a number:** an unbuilt build runs dry at **15–20 s** and then lives on
  regeneration, firing about half as often; a sustain-built one **never runs dry** in a 45 s fight. That gap is what
  makes sustain the king stat.

### B2. The regeneration cap — **decided as recommended** (user, 2026-11-09)
`regen_cap` 8 % stops all bonuses at +6 pp, about six notables, and the uncapped Water buff would hit it at once.
- **Options:** (a) raise the cap (to 15–20 %); (b) replace it with diminishing returns:
  `regen_bonus_eff = bonus / (1 + bonus / k)`; (c) no cap.
- **Recommendation: (b).** Every source keeps adding something, Water stacks never hit a wall, and nothing runs away.
  `k` is tuned so +6 pp of bonus gives about +4.5 pp.

### B3. Gain on hit, crit and kill, and leech — **decided as recommended** (user, 2026-11-09)
Today these are Effects only, because "on hit" is a rule (sustain audit problem 5). PoE treats them as plain
modifiers, and they are the cheapest, most common sustain in PoE.
- **Options:** (a) keep them Effects; (b) a narrow exception, like conversion: "+X linh lực gained on hit / on crit /
  on kill" and "X % of damage leeched as linh lực or health" become plain priced modifiers.
- **Recommendation: (b).** "Sustain has many sources" needs cheap common rows. The exception names its keys, so the
  rule stays clear for everything else.

### B4. Paying with health as a stat — **decided as recommended** (user, 2026-11-09)
Today only an art-record field and the Blood Casting enabler.
- **Recommendation: a plain modifier**, "X % of art costs paid with health instead", priced, with the existing rule that
  it cannot take health below 1.

### B5. Increased regeneration — **decided as recommended** (user, 2026-11-09)
Today only flat pp of the pool.
- **Recommendation: add "% increased linh lực regeneration" and "% increased health regeneration"** beside the flat
  rows, so builds can scale what they have.

### B6. Burst builds rare — **decided as recommended** (user, 2026-11-09)
- **Recommendation: no rule.** Rarity comes from content (few high-cost burst arts and burst Effects) and from the
  economy itself: when sustain is cheap and long fights are the norm, spending everything at once only pays against a
  weaker foe.

### B7. Mana-based công pháp hooks — **decided as recommended** (user, 2026-11-09)
The Effects System can already read own linh lực and the regeneration clip (Still Water).
- **Recommendation: name two readable quantities** for Effects: the remaining share of linh lực, and **overflow**
  (regeneration and gain lost at a full pool, per pulse). "Damage per 10 % linh lực remaining" and "overflow becomes a
  shield" are then plain Effects.

## C. Health

### C1. Healing decay — **decided: removed** (user, 2026-11-09)
Healing, including regeneration, fell to 10 % by 15 s (Combat Defence & Healing rule 18, `heal_decay_end`,
`heal_decay_floor`). **Removed:** healing keeps full strength for the whole fight. What still stops a healer from
stalling: the heal cap per pulse (C3), the Withering curse (healing taken −50 %), and fatigue (A3), which healing
cannot outpace once it grows.

### C2. Upkeep wards — **decided: removed** (user, 2026-11-09)
Upkeep was one of the five ward payment models: a fee every pulse, growing 15 % a pulse (rule 8, `upkeep_growth`).
**Removed:** wards pay by **reserve**, **per hit**, **drain** or **cast**. Wards authored with upkeep move to one of
those four when the content is written; the price check (Formulas F) loses its upkeep term.
- **Kept (user, 2026-11-09):** standing statuses (Corpse Rot) still cost their caster a flat fee every pulse
  (Effects Formulas B). It doesn't grow, and it is what lets a status run with no duration.

### C3. Heal and tick caps — **decided: both removed** (user, 2026-11-09)
Healing was capped at `heal_pulse_cap` 4 % of maximum health between two pulses (Combat Defence & Healing rule 17),
and ticks at `dot_pool_cap` 5 % per tick and `dot_pulse_cap` 8 % per pulse (Combat Formulas F). **All three are
removed:** tick builds and healing builds scale without a ceiling.
- **What bounds them now:** resistance by damage type (ticks meet it), the Withering curse (healing taken −50 %),
  cleansing (element stacks and statuses), and fatigue (A3), which grows every second from 60 s.
- **Follows from it (D3):** Fire and Wood debuff stacks are now fully unbounded; only resistance and cleansing
  answer them.
- **Also removed (user, 2026-11-09):** the qi burn cap (`qi_burn_cap`, 5 % of maximum linh lực per pulse, for Qi
  Disruption and other ticks on linh lực).
- **The simulator must check** that an uncapped healer against fatigue still ends inside the 120 s time limit.

## D. Element stacks

### D1. Existing statuses — **decided as recommended** (user, 2026-11-09)
Burn (Fire), Poison (Chaos), Frostbite (Cold) and Shock (Lightning) overlap the new debuffs.
- **Recommendation:** Burn becomes Fire's debuff and Poison becomes Wood's (keeping the Chaos damage type, so it
  still passes shields). Frostbite and Shock retire; Ice's debuff is the art-cost rise and Thunder's the crit
  exposure. Effects that read "three Frostbite stacks" are rewritten to read stacks.

### D2. Numbers per stack — **decided as recommended** (user, 2026-11-09)
User-set: Fire +1 % damage, Ice +1 % art cost. Proposed for the rest, the "1 % family", all tuned by the harness:

| Element | Buff per stack | Debuff per stack |
|---|---|---|
| Fire | +1 % damage | Burn: 0.03 `c_tick` per stack, the applier's damage |
| Water | +1 % maximum linh lực, +0.05 pp linh lực regeneration | — |
| Earth | +1 % Physical resistance | −1 pp accuracy |
| Metal | +1 % Physical damage | +1 % Physical damage taken |
| Wood | +0.05 pp health regeneration | Poison: 0.03 `c_tick` per stack |
| Ice | — | +1 % art cost |
| Thunder | +1 pp accuracy, +0.5 pp crit chance | +0.5 pp crit chance and +2 % crit damage taken |
| Wind | +1 % art speed | −1 pp evade |

### D3. Stacks against existing caps — **decided as recommended** (user, 2026-11-09)
No cap on stacks (user), but several global caps already bound what stacks do: one pulse's ticks ≤ 8 % of maximum
health, crit chance ≤ 100 %, resistance's maximum, `cost_red` −50 %, and the curse caps (Heavy Breath's +50 % cost
rise).
- **Recommendation:** global caps hold (crit chance, resistance maximum, evade cap; the tick caps are removed by C3). **Curse caps don't apply
  to stacks:** Ice stacks add to art cost with no ceiling, and the counter is cleansing, as decided.

### D4. Stack timers — **decided as recommended** (user, 2026-11-09)
The source sets how many stacks and how long (user). The record still needs a shape.
- **Options:** (a) every stack its own timer; (b) a new grant refreshes all; (c) each grant is a batch with its own
  timer.
- **Recommendation: (c).** Sources stay independent (a 3-stack art and a 1-stack Effect each keep their own clock),
  and the count is easy to show: "Fire 14 (6 ending in 2 s)". A source can say "lasts the fight".

### D5. Cleansing — **decided as recommended** (user, 2026-11-09)
- **Options:** (a) a cleanse removes all debuff stacks; (b) a number of stacks, oldest first; (c) all stacks of one
  element.
- **Recommendation: (b), with (c) as a stronger form.** A cleansing ward removes N stacks a pulse or per payment; an
  Effect removes N at once; rare ones remove an element entirely. Uncapped stacks then meet a counter that also
  scales.

### D6. Which element a stack belongs to — **decided as recommended** (user, 2026-11-09)
- **Recommendation: the source's element tag** (Kim, Mộc, Thủy, Hỏa, Thổ, Băng, Lôi, Phong), not the damage type.
  Metal and Earth both deal Physical damage, and conversion should not change which stacks an art builds.

### D7. Pricing and modifiers — **decided as recommended** (user, 2026-11-09)
- **Recommendation:** granting stacks ("this art gives 2 Fire stacks for 6 s") is an Effect or an art-record field;
  plain modifiers are "+X % Fire stack effect", "+X % stack duration" and "+1 stack per grant" (scoped by element).
  The Modifier System prices them.

### D8. Enemies, beasts and tribulations — **decided as recommended** (user, 2026-11-09)
- **Recommendation: same rules and schema**, so a Fire beast builds Fire stacks and a tribulation can cleanse or pile
  them. Tribulations may name "no cleanse" in their own rules.

## E. Work

### E1. How numbers are set — **decided as recommended** (user, 2026-11-09)
Every recommendation above has a number that only a fight run can check.
- **Recommendation:** first build a small fight simulator in `tools/` (two typical builds at each realm: unbuilt,
  sustain, burst), run A–D against it, and only then write numbers into the GDDs. The current numbers came from an 8 s
  one-pool simulation that predates the timeline (combat.md Formulas note).

### E2. Order of the GDD edits — **decided as recommended** (user, 2026-11-09)
- **Recommendation:** Combat (Formulas A, A2, E, F, K, time keys, fatigue rule), Combat Defence & Healing (Formulas C,
  E, F, healing decay), Effects (status catalogue, element stacks, cleanse), Modifiers (new keys and rows, the B3
  exception), Character Stats (keys, consistency C14). One part at a time, each approved; then a fresh design review
  per GDD.

### E3. Catalogue variety — **decided as recommended** (user, 2026-11-09)
Maximum linh lực, linh lực regeneration and health regeneration have one universal row each (audit problem 3).
- **Recommendation:** add scoped and conditional rows (by element, by art form, while channelling, at low linh lực)
  when the Modifiers part is edited.

---

## E1 results: first simulator run (2026-11-09)

Simulator: `tools/design/combat_sim/sim.py` (scenario table), `sweep.py` (knob sweep), `fair.py` (what a build is
worth in art damage). Qi Refining, one drain-paid ward (the Common Ward) plus block, greedy art use, 20 seeds per
row. With today's numbers it reproduces today's game: a typical mirror of 6.0 s with linh lực dry at 4.4 s
(combat.md's FX-T mirror is 6.000 s).

**Numbers that meet the A and B targets:**

| Knob | Today | Proposed | Decision it serves |
|---|---|---|---|
| Health (`health_units` multiplier) | ×1 | **×8** (A4 said ×4; see below) | A1, A4 |
| Art costs (`cost_share`, every art) | ×1 | **×0.5** | B1 |
| Base linh lực regeneration (`regen_base`) | 2 % | **2.5 %** a second | B1 |
| Ward drain bill per prevented point | ×1 | **×0.2** (the price check at `T_ref` 45 s, A5) | A5, B1 |
| Regeneration bonus | hard cap 8 % | diminishing returns, k 0.08 | B2 |

**Results at those numbers:**

| Fight | Mean length | Result | Linh lực dry at |
|---|---|---|---|
| Typical mirror | 49.7 s | even (6 / 12 / 2 draws over 20) | 16.4 s (target 15–20 s) |
| Sustain vs typical, equal budget | 45.2 s | sustain 19 of 20 | sustain 23.1 s, typical 19.8 s |
| Burst vs typical | 39.8 s | burst 0 of 20 | burst 11.5 s |
| Healer mirror (stall check) | 64.0 s | ends by fatigue, never at the 120 s limit | 16 s |
| Healer vs typical | 29.0 s | healer 0 of 20 | — |
| Fire stacks vs typical | 36.1 s | Fire 19 of 20 | — |
| Fire stacks vs a cleansing ward (2 stacks a second) | 36.3 s | Fire 20 of 20 | — |
| Water/Wood vs typical | 40.4 s | Water/Wood 20 of 20 | — |
| Ice lock vs typical | 48.8 s | about even | — |
| Typical vs one realm up | 11.7 s | the higher realm 20 of 20 | — |

**What it shows:**
1. **×4 health is not enough.** A typical build with its ward up all fight deals about 20 damage a second; ×4 health
   gives about 22 s. **×8 gives 45–50 s.** A4 needs the user's re-decision.
2. **Sustain is underpriced for long fights.** At today's prices (regeneration 8 W per pp, cost reduction 1.2 W per
   %) a sustain build with the same budget wins 19 of 20, worth about 20 % of art damage (`fair.py`: it breaks even
   at ×0.81). That is "sustain is king", but too much at equal price: the Modifiers part re-prices regeneration and
   cost reduction against the 45 s fight (sustain audit problem 1).
3. **Element stacks need a price.** At one buff stack per firing (10 s) and two debuff stacks per hit (6 s), a Fire
   kit is worth about 25 % of its arts' damage (breaks even at ×0.75), Water/Wood the same, Ice about 4 %. So the
   art lint must charge for stacks (D7): roughly −25 % damage coefficient for a kit that builds stacks at that rate.
4. **A cleansing ward of 2 stacks a second does not answer a Fire kit** (which applies 6–8 a second). Cleansing
   needs to scale with what it faces: a number per hit taken, or a share of stacks.
5. **Healers lose** without the heal cap and decay: a heal art at the heal lint (0.3 of the damage lint) trades badly
   in a 45 s fight. The heal lint ratio needs a re-check.
6. **Burst is rare by itself:** it runs dry at 11.5 s and loses every fight. B6 holds with no rule.
7. **A realm gap still decides fast:** 11.7 s one realm up, against 45–50 s at the same realm.

**Limits:** Qi Refining only; one ward type; arts fire whenever ready; no soul arts, triggers or conversions; the
sample builds are hand-made. Real builds from the build generator should replace them before final numbers.

## A4 revised and the second run (2026-11-09)

**User decision:** health stays **×4**, with **much stronger wards** instead of ×8 health. "This makes mana more
important": a ward is paid in linh lực, so when the pool runs dry, damage taken jumps about ×10. The user also asked
that **other elements have ways to generate linh lực**, not only Water (item F1 below).

**Numbers that meet the targets with ×4 health:**

| Knob | Today | Proposed |
|---|---|---|
| Health | ×1 | **×4** |
| Ward resistance payloads (ward strength) | ×1 | **×1.4**: the typical Common Ward goes from 0.654 to 0.90 all resistance |
| Resistance cap (`resist_cap`) | 0.75 | **0.90** (today's `resist_cap_max`, so that ceiling must rise too, or top-end builds have no room) |
| Art costs | ×1 | **×0.5** |
| Base linh lực regeneration | 2 % | **3.5 %** a second |
| Ward drain bill per prevented point | ×1 | **×0.2** |

| Fight | Mean length | Result | Linh lực dry at |
|---|---|---|---|
| Typical mirror | 41.9 s | even (8 / 11 / 1) | 15.7 s |
| Sustain vs typical, equal budget | 42.5 s | sustain 18 of 20 (worth about 17 % of art damage) | 18.3 s |
| Burst vs typical | 32.8 s | burst 0 of 20 | 9.5 s |
| Healer mirror | 65.5 s | ends by fatigue | 15.4 s |
| Healer vs typical | 22.7 s | healer 0 of 20 | — |
| Fire stacks vs typical | 27.3 s | Fire 20 of 20 (worth about 28 % of art damage) | — |
| Water/Wood vs typical | 29.0 s | 20 of 20 (about 23 %) | — |
| Ice lock vs typical | 41.1 s | 14 of 20 (about 7 %) | — |
| Typical vs one realm up | 8.8 s | the higher realm 20 of 20 | — |

The findings of the first run stand: sustain and stacks need prices, cleansing must scale, and the heal lint needs a
re-check. New: the resistance ceiling (`resist_cap_max` 0.90) must rise if 0.90 becomes the typical ward.

## F1. Linh lực for every element — **decided** (user, 2026-11-09)

**Every elemental build has a way to generate linh lực, but not through the element stacks.** The buffs stay as
decided (only Water's touches linh lực). The mana engines come as **keystones in each element's tree** (the Meridian
Map's element lands, and công pháp trees where they fit). The per-element flavour table proposed here was **not
adopted**; the keystones are written in the tree content pass, after the modifier library (the map is a placeholder,
user 2026-11-09).

## F2. The resistance ceiling — **decided** (user, 2026-11-09)

`resist_cap_max` rises from 0.90 to **0.95**, so top-end builds keep room above the typical ward's 0.90.

## Part 2 decisions (user, 2026-11-09: "all as recommended")

- **P2-1 Ward strength ×1.25** on resistance payloads, not ×1.4: the typical Common Ward is 0.8175 at Qi Refining and
  reaches the 0.90 cap at Core Formation, so ward strength keeps mattering early; running dry means about ×5.5 damage.
  Simulator: typical mirror about 36 s.
- **P2-2 Healing:** heal arts scale with `health_units` (×4) and refund their own linh lực cost; `heal_lint_ratio`
  0.3 → 1.4. Simulator: a healer wins about 38 % against a typical build with the same budget; a healer mirror ends by
  fatigue at about 70 s. Health regeneration's cap (`hregen_cap`) is removed, as "no cap on healing".
- **P2-3** Surging Tide becomes per hit (0.027); Thousand-Layer Cloud becomes reserved (0.20).
- **P2-4** Numbers recomputed by script: drain ×0.2 (ε_0 3.05), `T_ref` 45 s, the ward catalogue, typical ehp 1,376.2,
  the FX-T mirror 34 s and FX-U 68 s (worked by hand), Formulas K's T0 55.8 s.
- **New open questions:** shield wards pass the new price check with wide margins (held at old payments, CD Open
  Question 18); reserved resistance auras got dearer (Still Lake 0.71 of the pool, CD Open Question 19).

## Part 3 decisions (user, 2026-11-09: "P3 as recommended", draft approved)

- **P3-1 Cleansing:** cleansing wards remove a share of every debuff batch each pulse (`cleanse_share` 0.25,
  range 0.25–0.5); cleanse arts and Effects remove N stacks oldest first; rare ones clear an element. Simulator: against
  a priced Fire kit, a cleanser's loss rate falls as the share rises (Fire wins 53 % at 0.25, 35 % at 0.5).
- **P3-2 Pricing:** the art lint charges `w × stack-seconds` per firing, with per-element weights fitted by
  `tools/design/combat_sim/stackfit.py` (Fire 1.0 / 2.0 % per stack-second, Water 2.2 % buff, Ice 0.6 % debuff,
  and so on), × 0.75 for an art granting both sides, capped at 0.6.
- Rime Lock now reads 10 Ice stacks; Spillover burns linh lực equal to 25 % of each tick (both Claude's picks, approved).

## Parts 4 and 5 (applied overnight 2026-11-09, **without draft approval: Claude's choices, provisional**)

The user asked to "finish what we're doing" before going to sleep, so parts 4 and 5 were applied with Claude's
recommendations. Each is marked provisional in its GDD header; review and change any of them.

**Part 4, modifiers.md:**
- **The sustain exception (B3)** written into rule 1: `linh_luc_on_hit_pct`, `linh_luc_on_crit_pct`,
  `linh_luc_on_kill_pct`, `leech_linh_luc_pct`, `leech_health_pct` are plain modifiers.
- **New stats:** those five, `art_cost_health_pct` (B4), `linh_luc_regen_inc_pct` and `health_regen_inc_pct` (B5),
  and the element stack modifiers `stack_effect_pct`, `stack_duration_pct`, `stack_grant` (D7).
- **Re-priced from the simulator** (`tools/design/combat_sim/pricefit.py`, 10 W of damage traded for the stat,
  24 seeds, so ±30 %): linh lực regeneration 8 → **22.8** W/pp; art cost 1.2 → **0.6** W/% (costs were halved);
  health regeneration 3.0 → **9.9** W/pp (no cap); linh lực on hit 42 W/pp; linh lực leech 1.44 W/%; health
  leech 0.21 W/%. Guesses (G): on crit 6.3, on kill 0.5, cost paid with health 0.5, increased health regen 0.3,
  stack effect 0.5, stack duration 0.4, +1 stack per grant 8.
- **Derived tag thresholds** halved with art costs: `cheap` ≤ 2.5 %, `costly` ≥ 10 %.
- **General Catalogue regenerated:** 266 → 342 modifiers (`tools/design/modifier_catalogue.py`; matches the GDD).
- **Finding left for the user (modifiers.md Open Question 9):** maximum health is now worth about **0.21 W per %**
  in fights, against its 1.2 price (`pricefit2.py`); maximum linh lực stays near 1.0 and all resistance near 1.25.
  Health has become the cheap pool. Re-pricing `khi_huyet_pct` touches Character Stats, Realms and the Meridian
  Map, so it was not changed. Thể tu and health builds need a look.

**Part 5, character-stats.md:** the Combat row of the key table now lists every key Combat's Parameter keys name
(closes consistency C14) and the #44 keys, with their precision.

**Registry** (`design/registry/entities.yaml`, validates clean): `time_limit` 120, `health_units` 64,
`resist_cap` 0.90, `resist_cap_max` 0.95; deprecated `dot_pulse_cap`, `dot_pool_cap`, `regen_cap`,
`heal_pulse_cap`, `heal_decay_end`, `heal_decay_floor`, `upkeep_growth`; added `fatigue_start`, `fatigue_step`,
`regen_k`.

**Follow-ups not done:**
- `thien-kiep.md` still uses `regen_cap` in its rest formula (Formulas B) and a boss kill inside 0.75 × `time_limit`
  (now 90 s); both need a pass.
- The registry formula expressions for Formulas A, C, E and the price check still show pre-#44 text.
- Code: nothing is built for #44 (the full fight is on hold).
- A fresh `/design-review` of combat.md, combat-defence.md, effects.md and modifiers.md.

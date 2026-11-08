# Re-review 2026-11-08c — Combat Defence & Healing (#21a)

Target: `design/gdd/combat-defence.md` as of commit b5ca784 (the second re-review's answers applied).
Method: `/design-review`, lean mode, workflow `standard`, run unattended. No specialist agents. The report could not be saved to disk (write denied), so the parent session saves it.
Read: the whole GDD by section; the latest review-log entry (2026-11-08b); `rereview-2026-11-08b/combat-defence.md`; `rereview-2026-11-08-decisions.md` (passes 1–3); combat.md Formulas D and line 126 (cooldowns); combat-damage-types.md rule 4 and AC-DT-30; effects.md Qi Disruption, No Ward, Down step and AC-EF-26; the registry entries for `soul_shield`, `soul_shield_share_max`, `dot_pool_cap`, `default_resist`, `ward_gear_scale`, `ward_cap`, `ward_floor`, `defence_block`, `defence_shield`, `ward_payment`, `ward_price_check`, `defence_ehp`, `regen_cap`.

**Autonomous-path decisions** (taken in place of the skill's prompts):
- Settled answers (the 23 first-round answers, and 2026-11-08b CD-04 "keep and document") were not reopened.
- Systems-index update, review-log append and "revise now": not taken. This run writes only this report.
- Next step: apply the SAFE fixes below, then re-run `/design-review design/gdd/combat-defence.md`.

## Verdict: NEEDS REVISION (minor)

The second re-review's 16 fixes are all in, and they are correct. Both old blockers are closed. Formulas A0 now counts `a_w` in full for ws and we, and caps it only for gear block. The cast cost uses `floor(T_ref / cooldown)`, and the payloads use `T_up`. The ward catalogue recomputes: every ratio and limit matches. The new ACs (AC-CD-60, 61, 62, 66, 67, 69) recompute. No blocking problem is left, and nothing needs a user decision.

Three recommended fixes remain. First, "each pays the same share" for drain wards is ambiguous, and `bill = min(pool, ...)` can overspend the pool when two wards are short. Second and third, AC-DT-30 and AC-EF-26 in other GDDs expect a Qi Disruption tick to be cut by Force resistance alone, but the default ward now also applies, so their numbers are wrong. Five small nits follow.

Completeness: 6/6 required sections at `standard`. Player Fantasy is absent (advisory at `standard`; Game Feel covers it). All dependency GDDs exist. Scope signal: L.

Counts: 0 blocking, 3 recommended, 5 nit. 8 SAFE, 0 DECISION.

## Findings

### CD-01 — RECOMMENDED — SAFE — Drain split is "the same share", but the formula bills each ward alone

**Location:** Detailed Design › Core Rules, rule 8, second bullet (lines 171–175); Formulas › C, formula text (line 556); AC-CD-22, third sentence (line 1051).

**Problem.** Rule 8 says: "If the pool cannot cover the total, each pays the same share of what is there". AC-CD-22 says "each pays the same share of the pool". Both can be read as an equal amount each. The formula `bill = min(pool, rate_w · prevented_w)` is per ward, so it can bill the pool twice.

Working: two drain wards, bills 20 and 10, pool 15.
- Formula as written: min(15, 20) = 15 and min(15, 10) = 10. Total 25, but the pool holds 15.
- Intended (same fraction of each bill): 15 / (20 + 10) = 0.5. Bills 10 and 5. Total 15.
- Equal amounts (7.5 each) would be a third reading, and it fits neither the formula nor AC-CD-22's "same share of the total prevented damage leaks".

**Fix.**
- Formulas C: replace `bill = min(pool, rate_w · prevented_w)` with `pay_frac = min(1, pool / Σ_w rate_w · prevented_w)` over the wards billed together in that step; `bill_w = pay_frac · rate_w · prevented_w`. The unpaid fraction `(1 − pay_frac)` of each resistance payload's `prevented_w` rejoins the part before block.
- Rule 8: replace "each pays the same share of what is there" with "each pays the same fraction of its own bill (`pay_frac`, Formulas C)".
- AC-CD-22: replace "each pays the same share of the pool" with "each pays the same fraction of its bill (pool 15, bills 20 and 10: 10 and 5)".

### DT-01 — RECOMMENDED — SAFE — A Qi Disruption tick is also cut by all resistance, and the default ward is Up

**Location:** combat-damage-types.md rule 4, tick-on-linh-lực row (line 113), and AC-DT-30 (line 381). That file is not edited here; this is a proposal for its owner.

**Problem.** This GDD's rule 1 (line 69) sends the tick through "resistance (all + Force, rule 3)". Damage Types says only "Force resistance". AC-DT-30 expects: "Force resistance 0.20, a full ward shield and a full body shield, THEN the tick is reduced by 0.20".

Under rule 11 as now worded, a shield the part passes does not count as Up for it. A tick on linh lực passes every shield. So the full ward shield does not keep the default ward down, and the default ward adds all resistance 0.30.

Working: tick of 10, Force resistance 0.20, default ward on.
- AC-DT-30 expects r = 0.20, so 8.0 lands.
- Rules here give r = 0.30 + 0.20 = 0.50, so 5.0 lands.

This assumes the fixture's ward carries only a shield payload and the 0.20 comes from elsewhere. The AC does not say.

**Fix.**
- Rule 4's row: change "Force resistance" to "all + Force resistance (Combat Defence rule 3)".
- AC-DT-30: add "and `no_default_ward`" to the fixture. Then 0.20 and 8.0 hold, and the AC stays about shields. The alternative is to state 0.50 and 5.0 with the default ward on.

### EF-01 — RECOMMENDED — SAFE — AC-EF-26 has the same default-ward gap

**Location:** effects.md AC-EF-26 (line 696) and the Qi Disruption row (line 281). That file is not edited here.

**Problem.** "GIVEN Force resistance 0.20 and full ward and body shields, THEN each tick is cut by 0.20". The cause and working are the same as DT-01: with the default ward Up, the cut is 0.50.

**Fix.**
- AC-EF-26: add "and `no_default_ward`" to the fixture, or state the cut as 0.50.
- Qi Disruption row: change "Force resistance" to "all + Force resistance".
- Spillover's burn is unaffected: it takes no second resistance step (AC-EF-48).

### CD-02 — NIT — SAFE — Rule 1's new table row is not indented, so the table breaks

**Location:** Core Rules, rule 1, path table, line 69.

**Problem.** The row reads "| Tick on linh lực (Qi Disruption) | resistance (all + Force, rule 3) → ..." and starts at column 0. The other rows start with three spaces because the table sits inside list item 1. A column-0 row ends the list item, so the table renders split. The Soul and Curse rows below it fall outside the table.

**Fix.** Indent line 69 by three spaces, like lines 66–68 and 70–71.

### CD-03 — NIT — SAFE — The header does not record the 2026-11-08b round

**Location:** Header, lines 3 and 5.

**Problem.** Status ends with "revised the same day with the user's answers to all 23 items". Last Updated says "re-review answers applied; see `reviews/rereview-2026-11-08-decisions.md`". Neither names the second re-review (2026-11-08b), its 16 findings or CD-04, which commit b5ca784 applied.

**Fix.**
- Status: append "; second re-review 2026-11-08b: Needs Revision, all 16 findings applied (A0 gear terms, cast-ward T_up, drain billed in two steps, qi-tick path, AC-CD-66 to 69; CD-04 kept as a known weakness)".
- Last Updated: "2026-11-08 (second re-review applied, `reviews/rereview-2026-11-08b/combat-defence.md`)".

### CD-04 — NIT — SAFE — AC-CD-68 names no fixture or order, and Edge Cases does not point to the known weakness

**Location:** AC-CD-68 (line 1122); Edge Cases › Shields, "If a tick arrives" (lines 843–845).

**Problem.** AC-CD-68 reads "a Qi Disruption tick of 10 against the default ward only" and names no side. The tick cap is 5 % of `qi_max` a pulse (effects.md rule 6). On FX-T that is 0.05 × 172.74 = 8.64, below the raw 10. The AC passes only because the cap acts after resistance (AC-DT-30) and 7.0 < 8.64. Nothing says that. Nothing says whether the 6.0 bill is taken before the 7.0 lands, which changes the log when the pool is short. The Edge Cases line does not mention the weakness.

Working (matches the decision): 10 × (1 − 0.30) = 7.0 lands; prevented 3.0; bill 2.0 × 3.0 = 6.0; total 13.0.

**Fix.**
- AC-CD-68: start "**GIVEN** FX-T at full linh lực (the 5 % cap is 8.64, so it does not bind: 7.0 < 8.64) and a Qi Disruption tick of 10 against the default ward only ...".
- Formulas C, after the known-weakness clause: "the bill is taken first, then the tick lands on what is left".
- Edge Cases: append to the tick-on-linh-lực sentence "A drain-paid ward bills it like any part (Formulas C, known weakness)."

### CD-05 — NIT — SAFE — The price check's firing count has no stated convention

**Location:** Formulas › F, `V_w` and `C_w` rows (lines 671–672).

**Problem.** `floor(T_ref / cooldown)` is right only if the first firing is at t = cooldown. Combat says arts start on cooldown, "so nothing fires at t = 0" (combat.md line 126), and Waiting (rule 7) means the same. This GDD never says so. The shield term "per firing" never names its count. A reader may count firings at t = 0, 4, 8 for Golden Light.

Working (re-checked):
- Golden Light, cooldown 4: firings at 4 and 8, so 2 = floor(8/4).
- Black Tortoise, cooldown 5: one firing at 5, so 1 = floor(8/5).
- The catalogue ratios 0.750 and 0.930 follow.

**Fix.** Add to the `V_w` row: "A cast ward's first firing is at t = cooldown (combat.md line 126), so firings in `T_ref` number `floor(T_ref / cooldown)`. A cast shield's V is that count times its per-firing value. A firing exactly at `T_ref` counts in both V and C."

### CD-06 — NIT — SAFE — The registry's `ward_payment` and `ward_price_check` lag the GDD

**Location:** design/registry/entities.yaml, `ward_payment` (lines 1076–1077) and `ward_price_check` (lines 1130–1131).

**Problem.** `ward_payment`'s expression says "block points taken for block". The GDD now splits those by each source's share of `B_hit`, bills in two steps, and bills a linh lực tick. `ward_price_check` has no `T_up` and no cast-cost count. Neither entry names the 2026-11-08b changes.

**Fix.**
- `ward_payment` expression: replace "block points taken for block" with "block points the hit lost times this ward's share of B_hit; resistance bills settle before block, block bills after; a tick on linh lực bills like any part".
- `ward_price_check` expression: append "; cast wards: resistance, block and evade use T_up = floor(T_ref / cooldown) × duration, and C = κQ · floor(T_ref / cooldown)".
- Set `revised: 2026-11-08` on both.

## Answers checked and found correctly applied

- **2026-11-08b CD-01:** the ws and we formulas (line 381) carry `a_w` uncapped. The `a_w` row (line 389) says the cap is on gear block only. A2's `b_gear` and the registry's `defence_block` use `min(a_w, 1)`. Combat D (line 530) matches. For top-end ward gear, a_w = 5 gives ws and we +150, not +30.
- **CD-02:** `T_up` is in the `V_w` row, `C_w` uses `floor(T_ref / cooldown)`, and AC-CD-69 is added.
- **CD-03:** the qi-tick row exists (line 69; see CD-02 above) and so does the Edge Cases line (line 844).
- **CD-04 (decision: keep):** documented in Formulas C and AC-CD-68.
- **CD-05 to CD-16:** all in place. These are the two-step drain rule, the "other sources keep their shares" sentence, AC-CD-60 (4.83), AC-CD-61, AC-CD-66, AC-CD-67, the Combat #43 list, the `we` source, the Waiting and Expired names, AC-CD-65's fixture, rule 9's soul-shield line, AC-CD-59's slow kit, and rule 11's "applies to the part" clause.
- The 23 first-round answers are still in place: soul shield, A0, drain billing, Waiting, no-ward flags, default ward, b = 0, Down refusal, live changes, knobs, cross-references and registry edits.

## Arithmetic checked this pass

All of these hold.
- **Catalogue ratios** (V / C, then limit = ε_0 · β · α = 0.61 · β · α):
  - Common Ward: 1 / 1.64 = 0.610; limit 0.610.
  - Fire-Shunning Veil: 1 / 1.10 = 0.909; limit 0.61 × 1.5 = 0.915.
  - Qi-Scattering Robe: 1 / 1.32 = 0.758; limit 0.61 × 1.25 = 0.763.
  - Flame-Quelling Aura: V = 0.27 × 36.5 × 8 = 78.84; C = 0.35 × 172.74 × 1.5 = 90.69; 0.869.
  - Still Lake Aura: C = 0.50 × 172.74 × 1.5 = 129.56; 78.84 / 129.56 = 0.609.
  - Golden Bell: V = 0.40 × 36.5 × 8 = 116.8; C = 8 × 0.14 × 172.74 = 193.47; 0.604.
  - Surging Tide: V = 87.6; C = 16.79 × 0.045 × 172.74 = 130.5; 0.671 against limit 0.61 × 1.15 = 0.702.
  - Mountain Screen: V = 0.27 × 172.74 = 46.64; C = 0.30 × 172.74 × 1.5 = 77.73; 0.600.
  - Thousand-Layer Cloud: V = 34.55; C = 0.018 × 16.79 × 172.74 = 52.2; 0.662.
  - Golden Light Shield: V = 2 × min(15.55, 109.5) = 31.09; C = 0.12 × 172.74 × 2 = 41.46; 0.750 against limit 0.763.
  - Black Tortoise Shell: V = 0.33 × 36.5 × 2 = 24.09; C = 0.15 × 172.74 × 1 = 25.91; 0.930 against limit 0.953.
  - Iron Shirt: block 60 × 0.0631 = 3.79, so 3.79 × 8 = 30.3; evade 0.12 × 36.5 × 8 = 35.0; C = 0.42 × 172.74 × 1.5 = 108.8; 65.3 / 108.8 = 0.600.
- **Block:** FX-T 15.0 × 0.0631 = 0.946. Thể tu 88.3 × 0.0631 = 5.57. AC-CD-60: 5 × 8 / 8.278 = 4.83. AC-CD-61: other sources 2.0, ward 3.0, half paid 1.5, 3.5 lost, 1.5 moves on.
- **Shields:** Mountain Screen 0.27 × 172.74 × 1.308 = 61.0. Thousand-Layer Cloud 0.20 × 172.74 × 1.308 = 45.19. Ws 400: 0.27 × 172.74 × 5 = 233.2. Recharge 0.25 × 61.0 × 1.308 = 19.9 per second. Thể tu body shield 0.90 × 121.15 = 109.0.
- **Payments:** Golden Bell fee 0.14 × 172.74 / 1.308 = 18.49. Surging Tide 7.77 at t 0 and 7.77 × 1.15^6 = 17.98 at 6 s. Still Lake reserved 0.50 / 1.154 = 0.4333, so usable linh lực 97.9.
- **Healing:** d(10) = 1 − 0.9 × 10 / 15 = 0.40. Cap 0.04 × 109.87 = 4.39 (stated 4.4).
- **New ACs:** AC-CD-62 (5 and 1 soaked, 5 and 5 lost) and AC-CD-66 (0.654 − 0.10 = 0.554) hold. The qi cap on FX-T is 0.05 × 172.74 = 8.64.
- **Not recomputed** (need harness or realm data): the thể tu ehp table, the fast and slow kit table, the stall timings (known, Open Question 17), AC-CD-46's other-realm mirrors, "446 against top-end hits", the 25–36 s upkeep timings, and the other realms' typical-block shares.
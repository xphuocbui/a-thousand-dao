# Review pass 1 (2026-11-08c) — Combat Defence & Healing (#21a)

Target: `design/gdd/combat-defence.md`, working tree after the round-3 fixes (uncommitted).
Method: `/design-review`, lean mode, workflow `standard`, unattended. No specialist agents.
Read: the whole GDD by range; the 2026-11-08b and 2026-11-08c reports for this GDD; the review log; registry entries owned by this GDD.
Settled decisions were not reopened (23 first-round answers, 2026-11-08b CD-04, round 3 DT-01, DT-04, EF-05 option A).

## Verdict: APPROVED

Counts: 0 blocking, 0 recommended, 4 nits. 4 SAFE (all applied), 0 DECISION.

Completeness: 6/6 sections required at `standard` (Overview, Detailed Design, Formulas, Edge Cases, Dependencies, Acceptance Criteria). Player Fantasy is absent. It is advisory at `standard`, and Game Feel covers it. Tuning Knobs is present.
Dependency graph: all dependency GDDs exist.
Registry values: every constant owned by this GDD (`resist_cap` 0.75, `resist_cap_max` 0.9, `resist_floor` −0.5, `ward_gear_scale` 0.3, `ward_cap` 400, `ward_floor` −90, `soul_shield_share_max` 0.75, the `ward_price_check` expression, the `defence_*` entries) matches the text. No conflict.
Scope signal: L (producer should verify before sprint planning).

All round-3 Defence fixes are in place and correct: `pay_frac` in rule 8, Formulas C and AC-CD-22; the indented qi-tick row; AC-CD-68's fixture; the cast firing convention in the `V_w` row; rule 9's qi-tick line. None of round 3's user decisions (DT-01 host order, DT-04 per-part scaling, EF-05 Chaos stacking) touches this GDD.

## Arithmetic recomputed this pass (all hold)

- Ward catalogue ratios, `V`, `C` and limits for all 13 priced wards. Upkeep sum 16.79 is 9 fees, t = 0 to 8 (n = 0 to 8).
- Resistance: Fire example (1.157 capped to 0.75, a = 10.3; pen 0.10 gives 18.4; after block 9.4 and 17.5); r −0.5 gives 61.95; realm anchor r values.
- Block: all five realm rows (typical, top-end, thể tu, thể tu + Iron Shirt); the fast and slow kit table; AC-CD-53 split (7.27 / 0.73 / 25.0); AC-CD-60 (4.83); AC-CD-61 (3.0, 1.5, 3.5, 1.5).
- Shields: 61.0, 45.2, 233.2, recharge 19.9 per second, AC-CD-29 (5.95); body σ_b thresholds 1.17 and 0.84.
- Payments: 0.4333 reserved, 97.9 usable, 0.0833 with res_eff capped at 50; upkeep 7.77 and 17.98; fee 18.49; cast cost 20.73; drain bill 25.9; default ward bill 24.8; AC-CD-68's 13.0.
- Healing: lint 3.3, c_heal 0.99, raw 6.25, cap 4.39, d(10) = 0.40, 2.5; AC-CD-36 (1.39).
- ehp example: 297.8; λ_all 0.3201; x 275.55.
- Ward slots (AC-CD-14) including 6 at Deity Transformation with one bonus.
- Stall check: a continuous model gives about 37.4 s against the stated 37.6 s. This is already Open Question 17.
- Not recomputed (need the harness or realm data): the thể tu ehp table, the typical block shares by realm, stall and upkeep timings, AC-CD-46's other-realm mirrors.

## Findings

### CD-01 — NIT — SAFE — The header does not record round 3
**Location:** Header, Status and Last Updated (lines 3 and 5).
**Problem:** Both stop at the second re-review (2026-11-08b). Round 3's fixes are in the body, so the header is stale.
**Fix:** Append the 2026-11-08c round and this pass to Status. Point Last Updated at this report. **Applied.**

### CD-02 — NIT — SAFE — `pay_frac` divides by 0 when no drain ward bills anything
**Location:** Formulas › C, drain formula (line 556).
**Problem:** `pay_frac = min(1, pool / Σ rate_w · prevented_w)`. When the sum is 0 (a drain ward with no positive resistance, R_pos 0, or a part the ward does not touch), the quotient is undefined. AC-CD-60 only covers the bill, not `pay_frac`.
**Fix:** State "`pay_frac` = 1 when that sum is 0, so nothing divides by 0". **Applied.**

### CD-03 — NIT — SAFE — AC-CD-04's "resistance 0" tick is not 0 with the default ward on
**Location:** AC-CD-04, second sentence (line 1024).
**Problem:** "A tick of 10 with status resistance 0.9, resistance 0 and no shields, THEN 10 reaches health." Every side has the default ward (all 0.30) unless flagged or at 0 linh lực, so the tick would deal 7.0. This is the same class of gap as round 3's DT-01 and EF-01.
**Fix:** Add "(the side is flagged `no_default_ward`, since the default ward would add 0.30)". The intent is unchanged. **Applied.**

### CD-04 — NIT — SAFE — AC-CD-43's `regen_cap` is easy to confuse with `hregen_cap`
**Location:** AC-CD-43 (line 1087).
**Problem:** This GDD also has `hregen_cap` (health regeneration, 0.02). `regen_cap` 0.08 is Combat's linh lực regeneration cap (registry, combat.md). The AC does not say which.
**Fix:** Write "linh lực regeneration at Combat's `regen_cap` 0.08 (not `hregen_cap`, which is health regeneration)". **Applied.**

## SAFE fixes applied (all in `design/gdd/combat-defence.md`)

1. CD-01: header Status and Last Updated.
2. CD-02: `pay_frac` = 1 when the sum is 0 (Formulas C).
3. CD-03: AC-CD-04 fixture names `no_default_ward`.
4. CD-04: AC-CD-43 names which regeneration cap it means.

No other file was edited except the review log (one appended entry). `systems-index.md` was not touched.

## DECISIONs

None.

## Still open (already tracked, not new)

Open Questions 2, 3, 4, 7 to 9, 11 to 17: Combat revision #43, harness checks, soul defence table, Item DB mapping. None blocks this GDD.

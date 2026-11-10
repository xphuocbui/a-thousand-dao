# Re-review 2026-11-10 triage (after #44 and the 2026-11-10 rulings)

Four headless Sonnet reviews (read-only), reports beside this file: `combat.md`, `combat-defence.md`, `effects.md`,
`modifiers.md`. All four: **NEEDS REVISION**, no design rethink. About $2 in total.

## Decisions for the user (Claude's recommendation in bold)

| # | Question | Recommendation |
|---|---|---|
| Q1 | Resistance keeps its cap (0.90, raisable to 0.95) while the rest of the game drops caps. At Core Formation one ward already reaches it, so ward strength stops mattering | **Make resistance dampen-shaped too:** damage ÷ (1 + R/100), no cap; re-fit the Common Ward so a typical ward still stops about 82 % at Qi Refining. Or keep the cap as a named exception |
| Q2 | Where element stacks that change damage taken sit in the defence path (Earth's dampen, Metal's +Physical taken) | **On the hit before resistance**, as the simulator does |
| Q3 | Water's +% maximum linh lực during a fight: reservations and ward shields were fixed at the start | **The pool's maximum changes live; reservations and shield sizes stay as compiled** |
| Q4 | Heal arts refund their cost: the nominal cost or what was paid, and also at full health? | **Refund what was actually paid in linh lực, only when the heal restores health** (no free cost at full health) |
| Q5 | Who owns the cleansing ward (`cleanse_share`)? | **Combat Defence & Healing:** a new "cleanse" ward payload (removes a share of each debuff batch each pulse); Clear Heart Ward updated (Poison is now Wood's stacks) |
| Q6 | Stack charge for a batch "for the fight" has no length | **Charge it as 60 s** (the fatigue start) |
| Q7 | `stack_grant` is rare but priced 8 W, below the rare range (10–30 W) | **10 W** |
| Q8 | Body gear prices after health's re-price (body shield 0.51): Iron Body ≈ 15.8 W a tier (was 20.7), Black Iron Armour ≈ 35 W (was 65), breaking the parity AC-CD-57 wants with ward gear | **Re-price them down and drop the parity**, or raise body gear's shield share to restore it |

## Mechanical fixes (no decision needed; follow approved rulings)

- **combat.md:** typical ehp 297.8 → 1,376.2 (Formulas A, Formulas B's 47.2 U → about 218 U); Formulas F Poison example and
  `c_tick` range re-based on the 0.019 stack values; Game Feel "6–8 s" → 30–60 s; header dates; Parameter keys list the
  #44 stat keys; `upkeep_share` text; a short "element stacks in the fight" pointer to Effects rule 9a.
- **combat-defence.md:** rule 11's default ward (0.375 / 0.40); healing-decay ACs (AC-CD-33, 37) and Game Feel;
  the 90 % cap edge case → 95 %; pre-#44 fixtures (Common Ward 0.625 / 0.328, Golden Bell 0.035, default ward, AC-CD-06
  body shield 131.8, Still Lake 0.71); fatigue added to the defence path (rule 1 table); leech in healing sources;
  Formulas I health regeneration 9.9; `T_ref · φQ`; header.
- **effects.md:** stale tick-cap text (rule 7, Corpse Rot row, Cross-References, AC-EF-25); AC-EF-16 uses retired Shock;
  state the 0.05-stack removal threshold and the lint rounding (round down to 0.01); rule 9's status bounds exempt
  Burn and Poison; Formulas B example uses Corpse Rot's 0.02; Spiritual Roots in Dependencies; header.
- **modifiers.md:** add `D` (dampened) to the Stat List legend and the two regeneration rows; state how dampened composes
  (`(base + Σflat)(1 + Σinc) ÷ (1 + ΣD)`, and after the regeneration curve); scope targets for pool, hit-event and stack
  stats (rule 8) and `buff` / `debuff` tags; stack rows into the catalogue; stale caps in rule 7 and Edge Cases; Rare
  table "to 95 %"; Formulas A body shield 0.51; Formulas C and E examples; rule 9's frostbite and shock tags; AC-MD-07,
  08, 17, 21; new ACs for dampened, shifted costs and the new keys; header.
- **Registry:** `dot_pool_cap` referenced_by; register the element-stack numbers; formula text for Formulas A, C, E.

## User answers (2026-11-10)

**All eight as recommended.** Apply Q1–Q8 with the mechanical fixes.

## Progress (2026-11-10)

- **Done (commit 49c60ac):** effects.md items and Q5 (owner noted), Q6, Q7; modifiers.md legend, `D` op, compose rule,
  scope targets, `stack_grant` 10 W, "to 95 %", catalogue regenerated.
- **Remaining:**
  - **Q1 (largest):** resistance becomes dampen-shaped, `damage ÷ (1 + R/100)` with R in points, no cap. A typical ward must
    still stop about 82 % at Qi Refining (R ≈ 455 points), so every resistance number changes: Combat Defence & Healing rule
    3, Formulas A (anchors, example, cap and ceiling keys retired), the ward catalogue and price check, Formulas G (ehp),
    penetration (points off R), curses that shred resistance (Sundered, Exposed: now dampen-shaped too), Earth's dampen
    stack (adds to R?), the Modifier System's `resist_pct` / `resist_cap_pct` rows and prices, `combat.md` examples, the
    simulator, and the registry. Do it as its own pass with the simulator to keep the typical mirror near 36–45 s.
  - **combat-defence.md:** Q2 (stack damage-taken effects apply before resistance), Q3 (Water's live maximum; reservations
    and shields stay as compiled), Q4 (heal refund = linh lực actually paid, only when health is restored), Q5 (the
    cleanse ward payload, Clear Heart Ward), Q8 (body pieces re-priced down: Iron Body ≈ 15.8 W a tier, Black Iron
    Armour ≈ 35 W, AC-CD-57 parity dropped), and its mechanical list.
  - **combat.md** and **modifiers.md** mechanical lists (stale examples and ACs), and the **registry**.

# Cross-GDD Review Report (third pass)

Date: 2026-11-04 (third review today; re-run after fix commit b895c8b; supersedes `gdd-cross-review-2026-11-04b.md` for current status)
GDDs Reviewed: 5 of 5 present (`linh-can.md`, `character-stats.md`, `canh-gioi.md`, `cong-phap.md`, `kinh-mach-do.md`)
Not read: none wholly. Partial-section gaps are listed under Coverage.
Focus: full (consistency + design theory + scenarios)
Systems Covered: Spiritual Roots (#6), Character Stats (#7), Realms & Bottlenecks (#8), Cultivation Techniques (#9), Meridian Map (#10)
Pillars: `game-concept.md` (5 pillars, 6 anti-pillars); `game-pillars.md` does not exist.
Entity registry: present (1,123 lines), used as the ownership baseline (Phase 2B).

**Method disclosure.** The five GDDs total about 438 KB, which is too large to paste into agent prompts. The agents got section line ranges and read by section, as in the two prior reviews; this deviates from the skill's contract. Three parallel `game-designer` agents ran instead of two:
- 2A: verification of the blocker fixes and the status of the older warnings;
- 2B: the AC cross-check and ownership sweep the prior review could not assess;
- 3+4: design holism and scenarios.

All three hit their turn limit, were resumed once, and wrote their files. The main session checked every Blocking claim against the GDD text:
- B1 and NG4 are confirmed.
- NG1 is reworded (see its entry).
- 2B's R1 is merged into G5, because 3+4's single-root ramp estimate is the more careful one.
- The main session also closed four of 2A's not-assessed items: C3, N7, N12 and N14.

---

## Status of the prior review's blockers

| ID | Status | Evidence |
|---|---|---|
| N5 `comp` undefined | FIXED | CS Formulas J (576–597); canh-gioi 613, AC-CG-07; registry `ngo_tinh_divisor`; one owner (CS 631) |
| N6 `climb_total` lever cannot fit | FIXED | `count_gain` in cong-phap Formulas A (309–328), AC-CP-18a, 46–48, OQ1; canh-gioi 312–317. Stale text left behind: W1, W3, I2, I3 |
| G1 technique bonuses feed odds | FIXED in principle | CS rule 14 ceilings (178–186), Formulas I (538); canh-gioi 441–456, AC-CG-60; KMD 849–853. Residuals: B1, NG4, W4–W6, NG5–NG7 |
| T2 rule 18 persistence | FIXED (core) | cong-phap 229–244, edge case 705–711, UI 859–862, AC-CP-49/50. Residuals: W7, P3 |

## Status of the prior review's warnings and info

| ID | Status | Evidence |
|---|---|---|
| C2 stale "no GDD yet" | OPEN | CS 259, 710 "Only Realms & Bottlenecks and the Meridian Map have GDDs"; canh-gioi 790–793 omits Cultivation Techniques |
| C3 missing Cross-References rows | PARTIAL | cong-phap 866–875 complete. No `cong-phap.md` row in canh-gioi 918–931, CS 810–820, linh-can 681–693; KMD 1596–1608 lists none of the four sibling GDDs; CS has no linh-can row |
| C4 CS absorbing linh-can | OPEN | CS OQ1 (1102) |
| C6 / C7 / C8 (= N4) | OPEN / PARTIAL / PARTIAL | CS 608 `vitality_floor` vs canh-gioi 646, and placed in two data files (2B); CS 606 `tam_ma_natural_decay` untagged; canh-gioi 865 "align at its next pass" |
| N1 rule 13 crude floor | OPEN | canh-gioi 178–179 |
| N2 / N13 the soft 9 ↔ 10 cycle | OPEN | KMD 1516 "No new cycle" vs cong-phap 776–779; index row 9 (64) omits Config and Sim Core |
| N3 `speed_pct` range | OPEN | canh-gioi 614 "0–about 40"; real total above +80 for five elements |
| N7 CS spiritual-power fixture | OPEN | AC-CS-25 (946–949) 6,000 / 7,350 assumes technique power 1.0; CS 354 gives 0.5 with no main method |
| N8 KMD stat-weight owner | NOT ASSESSED | — |
| N9 untagged Realms keys in CS | OPEN | CS 628 `stage_power_step`, 630 `failure_khi_huyet_loss_frac`; 2B adds `tam_ma_backlash_divisor` and `backlash_death_tam_ma_threshold` |
| N10 registry crude floor | FIXED | registry 396 |
| N11 `second_main_mult` source | OPEN | registry `source: kinh-mach-do.md`; the key is only in cong-phap 344, 612, 805 |
| N12 CS Downstream | FIXED | CS Dependencies lists #6 (hard) and #9 (soft) |
| N14 CS "power 1.0" | OPEN | CS 730 "Spiritual power at power 1.0" vs CS 354 "0.5 with no main method" (now an internal contradiction in CS) |
| N15 canh-gioi omits cong-phap | OPEN | canh-gioi 790–793, 918–931 |
| N16 five-element QR years | PARTIAL | AC-CP-47 "about 44" vs AC-CG-33a (1111) "about 50" (W1) |
| N17, N18 | OPEN (Info) | linh-can 145; KMD 1784, 399, 1462 "active seasons" |
| N19 index out of date | OPEN | index 5 "Last Updated 2026-11-03"; 28 "there are no GDDs"; 300–301 tracker |
| G2 single root has no technique choice | OPEN | NG1 extends it to multi-element roots in absolute terms |
| G3 higher tier is a strict upgrade | OPEN | cong-phap 93 vs `speed_mult` (339) |
| G4 "more elements is faster" | FIXED | `count_gain` cancels it on average |
| G5 single roots breach NS/DT | OPEN, slightly worse | see G5 below |
| G6 #6 underpriced | OPEN | cong-phap OQ2; KMD not re-read |
| G7 free learning and switching | OPEN | cong-phap 97–99, 125. Now also a death trap (NG4) |
| G8 | FIXED | with N6 |
| G9 W feedback | PARTIAL | lifespan channel bounded; the speed → W channel is not |
| G10 / D11 attention budget | OPEN | no owner |
| G11, G12 | OPEN (Info) | unchanged |
| T6 ~30× stack | MOSTLY FIXED | about 16× a bare single root; about 10.2× a single root with the same kit, against the designed ×10.35. The rest is #6 (G6) and N3 |
| D4, D8, D12, D13 | OPEN | linh-can OQ10, OQ9; KMD 836; CS, canh-gioi and cong-phap have no Player Fantasy section |
| D7 `lifespan_pct` | PARTIAL | now the only uncapped lifespan channel (W4) |
| D10 Pillar 4 fades late | PARTIAL | the +24 % is gone; a 3-element life still spends only 10 % of NS lifespan there |

---

## Consistency Issues

### Blocking

🔴 **B1. The lifespan cap rule omits the new lifespan ceiling, and that rule decides death by old age.**
- canh-gioi rule 14 (182–184): "The cap is the realm's lifespan plus pill and treasure bonuses plus lifespan_years, times (1 + lifespan_pct), as built. At age ≥ cap the character dies of old age."
- CS rule 13 (172–173) hands this formula to Realms ("Cultivation owns the lifespan formula (realm lifespan + `lifespan_years`, then × (1 + `lifespan_pct` ÷ 100))"), also without the clamp.
- CS Formulas I (538) now defines the bonus term as `min(pill_years + treasure_years + Σ lifespan_years, f_life · L_realm)`.
- AC-CS-52 (1075–1076) uses unclamped sums. It still passes, because 15 is under FE's 30, but it no longer tests the composed formula.
- Why it blocks: Realms owns and computes this cap itself (unlike N1, where Realms only reads `tech`). An implementation that follows the owner's rule gives a different death age from CS.
- Fix: rule 14 reads "realm lifespan + the Character Stats lifespan bonus (Formulas I, ceilinged), times (1 + lifespan_pct)". CS 172–173 and AC-CS-52 state the composed formula with one clamped case.

### Warnings

⚠️ **W1. The canh-gioi `climb_total` rationale and AC-CG-33a are stale after `count_gain`.**
- canh-gioi 856: "a five-element root already uses 84 % of the half-lifespan ceiling in QR".
- AC-CG-33a (1109–1112): "about 50".
- cong-phap 394–397 and AC-CP-47 now give about 44 years (73 %).
- Options: re-derive the QR range; keep +19 % as a margin and fix the text; or mark it pending the AC-CP-48 run.

⚠️ **W2 (= NG2, P1). A root change moves `g`, and no GDD defines it.**
- `g` is keyed on the current `n_base` (cong-phap 309). The edge case at 649–651 covers usability only.
- A Linh Căn Quả adds an element at purity 20–35 (linh-can 480, 494), which almost never becomes the strongest. The main method therefore slows with its purity unchanged:
  - 1→2 elements: −18 %;
  - 2→3: −8 %;
  - 3→4: −6 %;
  - 4→5: +11 % in QR, then −13 % at the FE step.
- The fruit's NS payoff falls from ×3.5 to about ×2.87 (linh-can OQ9 is out of date). `count_gain` is derived from the birth distribution, which an added element does not follow.
- linh-can says a root change applies "at once"; the rate is computed at season start (P1).
- Options:
  - (a) key `g` on the birth element count;
  - (b) key it on the current count, state that in the edge case, and show it in the Linh Căn Quả preview;
  - (c) key `g` on the named element's purity rank;
  - (d) accept it as the fruit's trade-off and update OQ9.

⚠️ **W3. cong-phap has stale figures.**
- 391–392 still says "+16 % in QR and FE".
- OQ5 (1338) says 3 %; Formulas A and AC-CP-47 say 6 %.
- AC-CP-45 (1282) leaves `g` out of the `explain` split.

⚠️ **W4. Do root mutations' lifespan years count toward the ceiling? The GDDs disagree.**
- CS rule 14 (179–180) exempts "the root's own terms". CS Formulas I (538) sums every `lifespan_years`, mutations included.
- linh-can Formulas E (460–463) prices Time at +200 years. Under the ceiling it delivers at most 18 / 30 / 75 / 150 / 300 by realm, so its W is wrong either way.
- `lifespan_pct` is the only uncapped channel (D7).
- Options: (a) mutations are capped and repriced; (b) exempt them, and say so in rule 14; (c) move mutation lifespan to `lifespan_pct` with its own ceiling.

⚠️ **W5 (= NG5). What happens to clamped lifespan is not stated.**
- CS 538's `min` over the stored sum implies the excess is kept and comes back at the next realm. No rule, Edge Case or AC says so.
- No warning tells the player that a lifespan pill used at the ceiling does nothing now.
- Options: state "kept, re-evaluated each season" plus an AC (QR 30 → 18, then 30 at FE); or "lost"; add an Advisor warning either way.

⚠️ **W6. The calibration order is undefined.**
- canh-gioi 443–445: two mastered Profound arts reach 0.49 at CF→NS, inside the ceilings.
- AC-CG-60 says "lower the `bonus_ceilings`, not Y", but neither AC says AC-CG-60 runs after AC-CG-30 raises Y.
- Fix: state the run order (AC-CG-30, then AC-CG-60).

⚠️ **W7. The rule 18 duties sit on systems with no GDD and are missing from cong-phap's own Interactions table.**
- Market (#20), Sects (#26), World Gen (#27) and World DB (#3) carry them.
- cong-phap Interactions 276 and 279 omit the reserved copy and the fallback that Downstream 756 and 759 list. Downstream 760 omits "records the new location".
- Fix: update the rows, and add a pending-obligation note to the index rows for #20, #26, #27 and #3.

⚠️ **W8. linh-can AC-LC-23 (805) and AC-LC-38 (890) say a technique "runs at" 0.435 and 0.63.**
- Those numbers are `match`. The same Wood/Fire technique at CF layer 8 runs at 0.97 (`g` 1.22). A test written from the AC text fails.
- Fix: say "match", or assert speed with tier, realm, layer and `g` stated.

⚠️ **W9. Ownership and registry gaps (2B).**
- KMD `q_max` (untagged) duplicates canh-gioi `chance_max` and `guard.s_max` (all 0.95); none is registered.
- `tree_breakthrough_cap` is used by three GDDs and has no registry entry.
- KMD says Realms owns `pts_birth`; canh-gioi does not list it.
- `beyond_realm_mult` is registered to cong-phap, which tags the value as coming from canh-gioi rule 13.
- The backlash keys' registry entries omit CS from `referenced_by`.
- `second_main_mult` is still missing from KMD's tables (N11).

### Info
- **I1.** canh-gioi 297 and linh-can 333 say "other rate factors 1.25 *guess*". `comp` at the roll mean is 1.225 (feeds G5).
- **I2.** linh-can 344–347 commentary predates Formulas A (technique 0.5, "84 %"). Its dominance figures (384–387) are roughly restored by `g`. Add a pointer.
- **I3.** AC-CP-48 names "the Spiritual Roots years table" but quotes canh-gioi's no-pair figures (38 / 50 / 60 / 101 / 168). linh-can's 3-element row with pairs is 36 / 48 / 58 / 97 / 161.
- **I4.** canh-gioi Formulas D `p_brew` (410) has no `alchemy_success` term, though 442–443 says it raises λ through `p_brew`.
- **I5.** One authored art can carry `alchemy_success` of about 20.8 (8 × 1.5 × 1.73), 2.6 × the whole ceiling, at full budget price (NG6).
- **I6.** CS rule 14 heading "Per-source caps. Only one exists" now sits above a second kind of cap.
- **I7.** KMD OQ14 is stale (lifespan now capped). AC-KMD-24 "high-tier" is undefined. AC-KMD-66 repeats a sentence. linh-can prices presence at 2 W per point, but KMD's weight table has no presence entry.

---

## Game Design Issues

### Blocking

🔴 **NG4. A free slot change can kill.**
- A technique's `lifespan_years` counts only while it is slotted (cong-phap 174: "Every slotted, usable technique adds its bonuses"). Slots change "at no cost" each season start (125). The cap kills at "age ≥ cap" (canh-gioi 183–184).
- Three ways the cap falls:
  - unslotting an art;
  - a main-method switch that drops an art's harmony from 1.15 to 0.60 (cong-phap 182–185) and so scales its bonus down;
  - losing #6 (cong-phap 643).
- Unequipping a treasure with lifespan does the same (rule 14 "treasure bonuses").
- Example: QR, age 130, an art giving +15 sets the cap at 135. Swap it out at a season start and the cap is 120, so the character dies from a menu action.
- No Edge Case, Advisor warning or AC covers it, and no rule says whether death resolves before or after the change.
- This predates the fix commit; the review surfaced it while checking G1.
- Options:
  - (a) refuse a slot or equipment change that would put the cap at or below age, with a message;
  - (b) allow it with a confirm warning that names the death;
  - (c) count lifespan bonuses at their highest value this realm (a ratchet), so removal never lowers the cap;
  - (d) make technique and treasure lifespan permanent when gained, like pills.
- Same fix site as B1 (canh-gioi rule 14, plus an Edge Case and an AC in canh-gioi or cong-phap).

### Warnings

⚠️ **G5 (carried, slightly worse; includes 2B's R1). The median single root sits at about 95 % of the NS and DT half-lifespan ceilings, and about 45–47 % of single roots breach.**
- linh-can 338: NS 456 and DT 925 at "other factors 1.25". With `comp` 1.225 at the roll mean, that is 465 and 944 at tech 1.0.
- With a single root's technique ramp (mean L ≈ 0.98, estimated): NS ≈ 474 (95 %) and DT ≈ 968 (97 %).
- Breach below purity 47.4 at NS (≈ 45 %) and 48.4 at DT (≈ 47 %); it was 41 / 43 %.
- 2B's cruder estimate (tech 0.91 throughout) puts the median itself over the ceiling (≈ 513 / 1,042). Either way, the "1.25" assumption is the hinge, and no GDD says what it contains.
- AC-CP-48 tests only the median, and cong-phap OQ5 tracks only QR.
- P5: alchemy becomes near-mandatory for single roots late, against linh-can's "a single root is a sprinter" (59).
- Options:
  - accept it as the single root's identity (linh-can OQ10);
  - a single-root speed identity (relax "`count_gain[1]` must stay 1.0");
  - a match floor (changes linh-can rule 7);
  - extend AC-CP-47's tail test to NS and DT, and restate "1.25" as the itemised product.

⚠️ **NG1 (reworded by the main session). Only the strongest-element choice now meets the years table.**
- `g` divides every technique on the root (cong-phap 309), so the relative ranking between technique choices is unchanged.
- What changed is the anchor. Before, a 3-element root's middle element gave parity (1.00); now it gives about 0.75, and the weakest about 0.50 (was 0.66). A 2-element technique on a 2-element root gives 0.82.
- Against the half-lifespan ceilings, any choice other than the strongest element now costs years the table does not budget. Meanwhile the harmony upside is at most +15 % on auxiliary bonuses (H 1.15).
- Together with G2, no root size has a real main-method choice. This touches Pillar 1 and the "fixed classes" anti-pillar.
- cong-phap 327–328 "still gives less, as before" understates it.
- Options:
  - (a) apply `g` only when the technique names the strongest element;
  - (b) reward multi-element techniques (a bonus per extra named id);
  - (c) let harmony touch speed slightly;
  - (d) accept it, and state that the main method follows the strongest element.

⚠️ **NG7 (= G1 residual). The ceiling target is ambiguous per life.**
- At the ceilings, the birth-mix mean is about 0.46–0.47. That is plausible, but at the edge of AC-CG-60's 0.48 limit.
- Per root it runs from 0.41 (single) to 0.66–0.67 (five-element alchemy build), close to the 0.70 edge target. The edge would then stop being distinct for rare roots.
- The GDDs say "a life", but AC-CG-60 measures the birth-mix mean.
- `field_plots` is outside the ceilings: +1 plot is λ × 1.33.
- A life that skips every bonus lands at 0.27–0.29, inside the ±0.05 band. Decide whether "3 in 10" means a bare life or a typical one.
- Options: per-tier ceiling targets; count `field_plots` in the budget; state which life "3 in 10" describes.

⚠️ **NG6. Bonuses clamped to dead weight are still priced at full value** in Meridian Map fills (KMD 852–853 accepts this) and in manual prices and budgets (cong-phap Formulas D/E do not mention it). The player cannot see that a line is dead before buying. Options: price at the delivered value; show "over ceiling" on the manual and in the fill preview.

⚠️ **P3 residuals of T2.** "Reachable" ignores price (Earth 1,275–1,725, Heaven 10,200–13,800; no income guarantee) and travel. Also undefined:
- what "closed to the player" means;
- whether "the starting province" is per world or per life (cong-phap OQ7);
- what happens if the starting province becomes unreachable.

Options: a price ceiling or a quest alternative; define "closed"; pin the guarantee per life; nearest-market fallback.

⚠️ **Carried open:** G2, G3, G6, G7 (now with NG4's death trap), G9 (speed channel), G10/D11 attention budget (about 6 active systems, no owner).

### Pillar and fantasy summary (3f, 3g)
- **Pillar 1:** holds for multi-element roots only with the strongest-element main (NG1, G2).
- **Pillar 2:** much improved; G1's side channel is now bounded and visible. NG6's clamped lines are the remaining visibility gap.
- **Pillar 3:** undercut by G3.
- **Pillar 4:** undercut by G7 and G9.
- **Pillar 5:** supported (rule 18 moves are recorded).
- **Anti-pillars:** "fixed classes" is touched by NG1 and G2; "stat-block card picking" by G3.
- **Fantasy conflicts:**
  - linh-can "single root is a sprinter" vs G5 and P5;
  - cong-phap "commit your seasons" vs G7.

---

## Cross-System Scenario Issues

Scenarios walked: 5
1. P1 A Linh Căn Quả adds an element mid-realm while a main method is slotted
2. P2 A great breakthrough with the three bonuses at their ceilings and the lifespan bonus clamped; the realm step raises the ceiling
3. P3 The T2 fallback end to end for a player who has left the starting province
4. P4 A five-element life's full speed stack at DT
5. P5 A single root at NS/DT with breakthrough timing

### Blockers
🔴 **P2 — Character Stats, Realms, Cultivation Techniques, Alchemy.** After the step, the player swaps techniques for the new realm. If a swapped-out art carried `lifespan_years` and the character's age is inside that margin, they die (NG4). The risk is highest late in a realm near the cap, which is exactly when #22 and #23 players live. Resolved with NG4.

### Warnings
- ⚠️ **P1 (Spiritual Roots → CS → Cultivation Techniques → Realms).** `g` change undefined; "at once" vs the season-start rate (W2).
- ⚠️ **P2 (CS, Realms).** Clamped lifespan resurfaces at the step with no message (W5). W is longer from the lifespan bonus, which means more pills and higher S (G9, now bounded).
- ⚠️ **P3.** No undefined stall, but poverty and distance can still stall a life (see P3 residuals).
- ⚠️ **P5.** Single root late-realm squeeze (G5).

### Info
- ℹ️ **P4.** The five-element DT stack is about 16.4× a bare single root (9 × 1.20 × 1.52), or about 20.5× with N3's real +90 %. Against a single root with the same kit it is about 10.2×, matching the designed ×10.35. `g` resolved T6's excess; the rest is G6 and N3.

---

## GDDs Flagged for Revision

| GDD | Reason | Type | Priority |
|-----|--------|------|----------|
| canh-gioi.md | B1 rule 14 lifespan formula; NG4 death on slot change (Edge Case + AC); W1, W6, I1, I4; carried C2, C3, N1, N3, N15 | Consistency + Design | Blocking |
| cong-phap.md | NG4 slot-change guard (shared fix site); W2 `g` on root change; W3; W7 Interactions rows; NG1; NG6; P3; carried G2, G3, G7 | Design + Consistency | Blocking (shared NG4) |
| character-stats.md | B1 (rule 13 and AC-CS-52 composed formula); W4 mutations vs ceiling; I6; carried C2–C4, C6, C7, N7, N9, N14 | Consistency | Blocking (shared B1) |
| linh-can.md | W2 Linh Căn Quả payoff and OQ9; W4 mutation lifespan pricing; W8 AC-LC-23/38; G5 years and the "1.25" hinge; I1, I2 | Consistency + Design | Warning |
| kinh-mach-do.md | W9 `q_max`, `pts_birth`, `second_main_mult`; I7; carried C3, N2, N8, N18, G6 | Consistency | Warning |
| systems-index.md (not a GDD) | N13, N19; W7 pending obligations on #3, #20, #26, #27 | Consistency | Warning |

---

## Verdict: FAIL

Two blocking issues, both in the lifespan cap rule (canh-gioi rule 14) and neither a redesign:
- **B1** is one sentence: rule 14 must use the ceilinged bonus from CS Formulas I. CS rule 13 and AC-CS-52 follow.
- **NG4** needs a rule for what happens when a free slot or equipment change would drop the cap to or below age, plus an Edge Case and an AC.

All four blockers from the prior review (N5, N6, G1, T2) are fixed.

### Required actions before re-running
1. **B1.** Rewrite canh-gioi rule 14 to read the Character Stats lifespan bonus (Formulas I, ceilinged). Restate CS 172–173 to match. Make AC-CS-52 (or a new AC) cover one clamped case.
2. **NG4.** Choose the guard (refuse, confirm-warn, ratchet, or make technique and treasure lifespan permanent). Write it as a rule in canh-gioi 14 or cong-phap rule 12/9, add an Edge Case, and add an AC: age 130 at QR, an art giving +15, unslot it, and assert the chosen outcome.
3. Recommended in the same pass, because they touch the same text: W4 (mutation lifespan and the ceiling) and W5 (is clamped excess kept?).

### Coverage
- **Phase 2A read:**
  - the fix commit's sections in all five GDDs;
  - CS Formulas I and J, Param keys, Tuning Knobs, AC-CS-52–54, Dependencies;
  - canh-gioi rules 13–14, Formulas D and I, Param keys, Tuning Knobs, Cross-References, AC-CG-07/30/33a/60;
  - cong-phap Formulas A, rules 12 and 18, Edge Cases, Interactions, Downstream, AC-CP-18a/45–50, OQ;
  - linh-can Formulas B, E and F;
  - registry 376–413 and 1040–1095.
- **Phase 2B read:**
  - KMD ACs 1609–2127 and linh-can ACs 694–936 against the other four GDDs;
  - every Tuning Knobs and Param keys section;
  - the registry.
- **Phase 3+4 read:**
  - the prior review; cong-phap 63–420 and 494–600;
  - canh-gioi 61–213 and 404–540;
  - CS rule 14 and Formulas I and J;
  - linh-can Player Fantasy, Formulas B–F and OQ;
  - `items_cong_phap.json` bonus pool.
- **Main session read:** the cross-references of linh-can, CS and KMD; CS Dependencies; CS 354, 364 and 937–949; canh-gioi 176–192 and 295–317.
- **NOT ASSESSED:**
  - N8 (KMD vs CS stat weights);
  - G6 and the KMD #6 section (not re-read; status assumed unchanged since no fix touched it);
  - whether KMD capability #24 is Mutation Awakening;
  - the CS and canh-gioi ACs in full against the other GDDs (2f; KMD and linh-can were covered this time);
  - the Linh Căn Quả preview text;
  - the KMD base-notable values for `herb_growth_pct` and `lifespan_years`.
- **Partial:** G5, NG7 and P4 use normal approximations and guessed W, and none was simulated. 3b has no Time & Turn spec to check against. Edge Cases sections are out of scope by design.

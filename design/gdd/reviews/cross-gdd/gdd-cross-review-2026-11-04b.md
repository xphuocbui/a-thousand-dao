# Cross-GDD Review Report (second pass)

Date: 2026-11-04 (second review today; supersedes the morning report for current status)
GDDs Reviewed: 5 of 5 present (`linh-can.md`, `character-stats.md`, `canh-gioi.md`, `cong-phap.md`, `kinh-mach-do.md`)
Not read: none wholly. Partial-section gaps are listed under Coverage.
Focus: full (consistency + design theory + scenarios)
Systems Covered: Spiritual Roots (#6), Character Stats (#7), Realms & Bottlenecks (#8), Cultivation Techniques (#9), Meridian Map (#10)
Pillars: `game-concept.md` (5 pillars, 6 anti-pillars); `game-pillars.md` does not exist.
Prior report: `gdd-cross-review-2026-11-04.md` (4 GDDs, before `cong-phap.md`), verdict FAIL. Status of its findings is below.
Entity registry: present (1,074 lines). Used as the Phase 2 baseline; swept for every `cong-phap.md` key and the C6/C7/C14 keys only.

**Method disclosure.** Phase 2 and Phases 3/4 ran as two parallel `game-designer` subagents. The five GDDs total about 424 KB. That is too large to paste, so the agents got section line ranges and read by section, as in the prior review. This deviates from the skill's contract. Both agents hit their turn limit and were resumed: Phase 2 twice, Phase 3/4 once. The main session checked every Blocking finding against the GDD text. It downgraded one (N1, now a Warning) and confirmed the rest.

---

## Status of the prior review's findings

| ID | Status | Evidence |
|---|---|---|
| C1 Awakening trigger | FIXED | canh-gioi 801; linh-can 185, 253: Spiritual Roots subscribes to `breakthrough_succeeded` |
| C2 stale "no GDD yet" | OPEN | CS 250, 664; KMD 1436; canh-gioi 235, 769 (omits Cultivation Techniques) |
| C3 missing Cross-References rows | OPEN | CS 762–772 (no linh-can, cong-phap); KMD 1590–1602 (none of the four); canh-gioi 896–909 (no cong-phap); linh-can 681–693 (no cong-phap) |
| C4 CS not absorbing linh-can | OPEN | CS OQ1 (1041) still open; CS 321–322 Stars +10 / Death −10; AC-CS-07 (814) |
| C5 `stage_power_step` | FIXED (both say global); still listed in both Parameter keys (N9) |
| C6 `vitality_floor` twice | OPEN | canh-gioi 625 vs CS 565; canh-gioi OQ11 asks CS to drop its copy |
| C7 `tam_ma_natural_decay` twice | PARTIAL | canh-gioi 643 owns it; CS 563, 723 still list it untagged |
| C8 `failure_tam_ma_gain` range | PARTIAL | canh-gioi 843 inclusive + `nascent_tam_ma_max`; CS 722 still exclusive |
| C9 rate formula | FIXED | canh-gioi Formulas I (579–599), multiplicative |
| C10 `climb_total` vs 5-element QR | FIXED, but the derivation is now out of date (N6) |
| C11 keystone W / mutation total | PARTIAL | `keystone_min_power` 50 W registered; aggregate cap still linh-can OQ8 |
| C12 stat-weight owner | PARTIAL | KMD 1447 vs KMD 802/812 vs CS 768 (N8) |
| C13 base element count | FIXED | canh-gioi 781; linh-can 199–200; CS 170 |
| C14 deprecated registry key | FIXED | entities.yaml 702–712 |
| D1 λ ignores root | FIXED | canh-gioi 408–414, 461–475. Recurs through techniques (G1) |
| D2 five-element keystone at season 1 | PARTIAL | KMD 523–527 accepts the tension; linh-can OQ11 open; the five-element technique starter (tech ≈ 1.43, cong-phap 365) widens it |
| D3 dominance check | FIXED by user decision | linh-can 388–391 "Rare roots are meant to win". The "about 1 %" figure (386) is now out of date (G4) |
| D4 single root weakest | OPEN, deepened | linh-can OQ10; G2, G5 |
| D5 Awakening twice | FIXED (text) | linh-can 432–434; pricing still OQ5 |
| D6 Self-made convergence | FIXED by user decision | linh-can 547–550 |
| D7 `lifespan_pct` unpriced | OPEN | linh-can 465; KMD 815–825, 851 |
| D8 Linh Căn Quả uncapped | PARTIAL | linh-can OQ9: no per-life counter |
| D9 Tẩy Tủy Đan wasted use | NOT VERIFIED (probably open) |
| D10 Pillar 4 fades late | OPEN, worsened | multi-element lives climb about 24 % faster (cong-phap 357–361) |
| D11 attention budget owner | OPEN (G10) |
| D12 tree speed cap | PARTIAL | per-cluster cap 4 only (KMD 836) |
| D13 Player Fantasy sections | OPEN (advisory) | CS, canh-gioi, cong-phap have none (cong-phap OQ10) |
| D14 minutes per life | NOT VERIFIED (Time & Turn has no GDD) |
| S1 Awakening order | PARTIAL | trigger and DT timing fixed (canh-gioi 138–142); RNG-stream position undefined |
| S2 Linh Căn Quả preview | PARTIAL | preview shows speed only (linh-can 561–564) |
| S4 failed NS extra roll | NOT VERIFIED | same-season roll confirmed (canh-gioi 199, 228); no cumulative-risk preview found |
| S5 multi-level season | FIXED | canh-gioi 81–85 |
| S6 Self-made | FIXED by user decision |

---

## Consistency Issues

### Blocking

🔴 **N5. No GDD defines the comprehension factor `comp` in the cultivation rate.**
- canh-gioi 593 (Formulas I) sources `comp` to Character Stats.
- Character Stats Formulas A–I (275–523) has no comprehension→rate formula. CS 256 outputs only "effective comprehension"; CS 69 says comprehension affects "Cultivation speed".
- canh-gioi 297 and 965 use "comprehension factor 1.25" as a guess. As built it is `1 + ngo_tinh ÷ ngo_tinh_divisor` (`cultivation_rules.gd` 35; `cultivation_realms.json` `ngo_tinh_divisor` 200), so 1.225 at 45, not 1.25. No GDD or registry entry names `ngo_tinh_divisor`.
- Why it blocks: Cultivation Techniques normalises `tech` to 1.0 "which is the value the Realms years table assumes" (cong-phap 302–303). That holds only if every other factor in the rate is defined.
- Options: (a) Character Stats adds a `comp` formula and owns `ngo_tinh_divisor`; (b) canh-gioi Formulas I defines `comp` and lists the key. Either way, register it and restate 1.25 as 1.225 or retune the divisor.

🔴 **N6. AC-CP-48's prescribed remedy cannot meet its own target inside canh-gioi's `climb_total` safe range.**
- cong-phap AC-CP-48 (1248–1252): 3-element QR/FE expected about −24 % against the years table. "If any realm is more than 20 % under the table, the fix is a Realms `climb_total` raise within its safe range, not a κ change (user decision 2026-11-04)".
- canh-gioi 835: `climb_total` safe range QR −30 % to **+19 %**, FE and CF ±30 %, NS and DT −30 % to **+8 %**. Undoing −24 % needs about **+32 %** (1 ÷ 0.76).
- The +19 % QR ceiling was derived from a five-element QR of about 50 years at tech ≈ 1.0 (AC-CG-33a 1087). cong-phap 365–367 puts it at about 41 years (tech ≈ 1.43). The range rests on a `tech` value Cultivation Techniques has replaced.
- `climb_total` is not per root. Raising it also slows single roots, which already sit near the NS ceiling (AC-CP-48 expects 465 against 500; G5).
- Options (user decision, since the lever was a user decision): (a) re-derive canh-gioi's safe ranges with Formulas A active; (b) a per-element-count lever (the curve, or κ, which the user ruled out); (c) accept that 3+-element lives are about 20–24 % faster and restate the years table.

### Warnings

⚠️ **N1. canh-gioi rule 13 states the ×0.25 tier cap without cong-phap's crude floor.** canh-gioi 177–179 vs cong-phap 285–290 (`max(tech_one(main), crude)`). The registry note (1012) repeats canh-gioi's wording. *Downgraded from Blocking by the main session:* canh-gioi Formulas I takes `tech` from Cultivation Techniques, so the drift is in rule text, not in a rule Realms computes. Fix: rule 13 points to cong-phap Formulas A as the owner of `tech`.

⚠️ **N2. KMD says Cultivation Techniques does not depend on it; cong-phap says it does.** KMD 1510–1511 "No new cycle: ... Cultivation Techniques ... don't depend on the Meridian Map" vs cong-phap 710 (soft upstream: #6) and 740–743 (cycle and how it is broken). Fix: name the cycle in KMD.

⚠️ **N3. canh-gioi Formulas I `speed_pct` "0–about 40" is too low.** canh-gioi 594. Sources: pairs up to +15; tree `cultivation_speed_pct` capped per cluster only (KMD 836); center keystone +8 per element (+40 at five); mutations (Thái Cực +40, Hỗn Độn +25); destiny perk +10. A five-element life passes +80. The years table assumes 0 (canh-gioi 304–310). Options: widen the range and say what the table assumes; add a tree-wide or total cap; hand it to the bot run.

⚠️ **N4 (= C6–C8).** `vitality_floor`, `tam_ma_natural_decay`, `failure_tam_ma_gain` still duplicated on the CS side. AC-CS-36 and AC-CG-58 (1222) test the same key in two different files.

⚠️ **N7. CS spiritual-power ACs assume technique power 1.0 with no fixture.** CS 355, AC-CS-22 (889), AC-CS-25 (898–899: 6,000 / 7,350) vs cong-phap AC-CP-37 (1164–1165: empty slot gives 3,000 because `no_tech_power` 0.5). A default character fails AC-CS-25. Fix: pin `tech_power` 1.0 in the CS fixture, or restate at 0.5.

⚠️ **N8 (= C12). Stat-weight ownership contradicts itself inside KMD.** KMD 1447 vs 802/812.

⚠️ **N9. Realms-owned keys also listed in CS Parameter keys / Tuning Knobs without an owner tag.** `stage_power_step` (CS 583), `failure_khi_huyet_loss_frac` (CS 585), `tam_ma_backlash_divisor`, `backlash_death_tam_ma_threshold` (CS 725–728). The registry (712–753) sources all to canh-gioi.

⚠️ **N10. Registry `technique_speed_factor` omits the crude floor.** entities.yaml 393 vs cong-phap 285.

⚠️ **N11. `second_main_mult` registry source is the Meridian Map; only cong-phap holds the key.** entities.yaml 1038–1040 vs cong-phap 578, 768; KMD has no such key (only prose at 324).

⚠️ **N12. CS Downstream omits Cultivation Techniques and Spiritual Roots.** cong-phap 702 and linh-can 611 list CS as upstream; CS 690–692 does not list them back.

⚠️ **N13. systems-index row 9 omits Config and Sim Core**, and rows 9 and 10 together show a soft 9 ↔ 10 cycle that KMD 1510 denies.

⚠️ **N15. canh-gioi does not record cong-phap as a written GDD.** canh-gioi 769–772 and the Cultivation Techniques row at 246 are still "provisional"; no `cong-phap.md` Cross-References row though 312–315 cite it.

⚠️ **N19. systems-index is out of date** (main session). Header "Last Updated 2026-11-03"; Overview "there are no GDDs yet"; Progress Tracker "Design docs reviewed 4", "Design docs approved 4 (6, 7, 8, 10)" while row 9 is Approved.

### Info
- **N14.** CS 684 "spiritual power at power 1.0" without Cultivation Techniques vs cong-phap 172 `no_tech_power` 0.5.
- **N16.** Five-element QR years: AC-CG-33a (1087) "about 50" vs AC-CP-47 (1242) "35–41". Both pass at ≤ 60; update with N6.
- **N17.** linh-can 145, 581 "cannot be used at its speed" vs cong-phap 147 "cannot be slotted".
- **N18.** AC-KMD-24 (1778) "active seasons" vs "cultivating seasons in the main slot" everywhere else. Values agree.

---

## Game Design Issues

### Blocking

🔴 **G1. Technique bonuses feed breakthrough odds and lifespan through stats no calibration counts (D1 again).**
- `items_cong_phap.json` 20–30 `bonus_pool` holds `herb_growth_pct` 10–25, `alchemy_success` 3–8 and `lifespan_years` 5–15. Generated commons draw from it (cong-phap 217–218). Every slotted technique adds its bonuses (cong-phap 174–175), up to 1.73 × base (497–499).
- canh-gioi 413–414 calibrates the root multiplier and the 0.30 / 0.70 targets "for a life with no `field_plots`, `herb_growth_pct` or other alchemy bonus". KMD caps only the tree's own breakthrough share (845–847).
- Arithmetic (purity 50): QR→FE with two Yellow arts at `herb_growth_pct` 25, layer 3 of 6 → λ × 1.29, S ≈ **0.37** vs 0.30. CF→NS with two Profound arts at great completion (`herb_growth_pct` 25, `alchemy_success` 8) → λ × 1.875, S ≈ **0.49** vs 0.30 (assumes `alchemy_success` adds points to brew success; Alchemy has no GDD). Two `lifespan_years` 15 add +30 years (+25 % of the QR cap), which also raises W and so λ.
- Options: (a) mark these rows `authored_only` and cap them; (b) add a technique term to canh-gioi Formulas D and recalibrate with the bot's loadout; (c) a character-wide ceiling like `tree_breakthrough_cap`; (d) price the bonus budget in W against the tree and mutation bands.

### Warnings

⚠️ **G2. A single root (45 % of lives) has no real technique choice.** A technique needs every id it names (cong-phap 145–147); single roots have no mutations, so match = purity and harmony is always 1.00, never 1.15 (179–186). The trade-off the Overview promises (57–59) does not exist for them. Touches the "stat-block card picking" anti-pillar and D4's soft class lock. Options: a depth bonus for one element; a "pure path" harmony bonus; single-root-only authored techniques; heterodox arts at a cost; or accept it as the single root's identity (linh-can OQ10).

⚠️ **G3. A higher tier is a strict upgrade for the same named elements; rule 3 (93) says it is not.** QR: a fresh Profound (L 0.88) gives 1.15 × 0.88 = 1.012, above a fully mastered Yellow (1.0); a fresh Heaven gives 1.276. Power 2.2 vs 1.0, bonus budget 4.0 vs 1.0, and a Heaven found in QR never needs replacing. The cost is only ×1.6 layer cost, price and rarity. Undercuts Pillar 3 (found, not built). Options: higher tiers demand something (match/purity minimum, Comprehension gate, heart demon or toxicity per layer); a niche for lower tiers; cap the speed edge below the intended realm; or rewrite rule 3.

⚠️ **G4. Matching the strongest element is a hidden "more elements is faster" channel.** Speed uses average purity of named elements (cong-phap 298); rule 18 guarantees single-element methods. Expected strongest purity for 1–5 elements is 50 / 61 / 67 / 71 / 73, so technique speed 1.00 / 1.22 / 1.34 / 1.42 / 1.46 on top of the curve and pairs. linh-can's dominance figures (384–387) and years table no longer hold. Options: state as intended and update linh-can; normalise match per root; reward multi-element techniques.

⚠️ **G5. About 40 % of single roots breach the NS and DT half-lifespan ceiling.** Single-root tech ≈ 2 × purity ÷ 100; NS breaches below purity 45.6 (≈ 41 %), DT below 46.3 (≈ 43 %). AC-CP-48 tests the median (465 vs 500), so it passes while the tail fails; AC-CP-47 tests QR only; linh-can OQ5 tracks only the 8 % QR tail. Options: a match floor (changes linh-can rule 7); κ or speed edge by element count; a single-root speed identity; extend OQ5 and AC-CP-47 to NS and DT.

⚠️ **G6. Capability #6 (Twin Technique) is classed T2 but is worth about 8–11 notables.** +50 % speed ≈ 110 W vs a notable's 10–14 W (KMD 677, 822); KMD's own rule (689–690) makes it T3. It also adds a fourth bonus line (G1). Options: T3; `max(main, f2 × second)` (cong-phap OQ2); f2 ≈ 0.25.

⚠️ **G7. Learning and switching techniques cost no time or resource (Pillar 4 test).** Learning is free (97–99); slots change free each season start (125–126); mastery is never lost (142). Swapping auxiliary arts every season becomes a chore and undercuts "commit your seasons". Options: learning takes a season; main-method switch costs a season or risk; auxiliary lock for N seasons; or accept the ramp as the cost.

⚠️ **G8 (= N6, design side).** OQ1's fix (raise `climb_total`) cannot undo a ×1.24 speed-up at NS/DT (cap +8 %), and raising it also slows single roots that already breach (G5).

⚠️ **G9. Positive feedback: faster climb → more bottleneck years W → more pills → higher odds.** W is "growing years left in the realm" (canh-gioi 426). Techniques, #6 and `lifespan_years` all raise it. Bounded by lifespan, but it compounds the "more elements" channels and is absent from canh-gioi's S-by-count table. Options: bot logs W per root; define W as a fixed share of realm lifespan.

⚠️ **G10 (= D11). About 6 active systems in a typical season, 7 at a bottleneck:** season activity, Meridian Map points, fields and alchemy, technique slots, heart demon and toxicity, events and market, plus breakthrough prep. Above 4; no owner. Options: Time & Turn season digest; auto-slot rules; Guidance prompts.

### Info
- **G11.** Technique mastery feeds the main loop rather than competing (healthy). Comprehension now counts four times (rate, mastery, pill-attempt chance, and through mastery L), so it is a candidate dominant stat; its Meridian Map weight (5 W) predates the mastery use. `catchup_mult` 0.25 is a good catch-up.
- **G12.** A learned manual keeps its full sale value (cong-phap 658–661), so learn-then-sell is always right. Option: consume on learning, or sell at a "copied" value.

### Pillar and fantasy summary (3f, 3g)
- Pillar 1 holds for multi-element roots, not single roots (G2). Pillar 2: G1 is an uncapped side channel. Pillar 3: undercut by G3. Pillar 4: undercut by G7 and G9 (tier caps and layer gates support it). Pillar 5: supported (lost techniques are recorded).
- Anti-pillars: "stat-block card picking" touched by G2 and G3; "fixed classes" strongest for single roots.
- Fantasy conflicts: linh-can "single root is a sprinter" vs G5; "five-element is fragile in QR" vs D2 plus the 1.43 starter; cong-phap "commit your seasons" vs G7.

---

## Cross-System Scenario Issues

Scenarios walked: 6
1. T1 Switching the main method mid-realm
2. T2 Great breakthrough with the main method at its tier cap
3. T3 Several levels while a technique layer completes
4. T4 Five-element root choosing arts with partial harmony
5. T5 Dying or losing a manual
6. T6 Every speed source stacked

### Blockers

🔴 **T2. Great breakthrough with the main method at its tier cap — Cultivation Techniques, Realms, World Gen, Sects, Market.** At the step into NS the method drops to ×0.25 (1.18 → 0.30). Rule 18 (cong-phap 226–234) guarantees one reachable par-tier method per realm and element in the starting province, but does not say whether the guarantee survives the copy being bought by an NPC, the quest failing, or the sect being destroyed or refusing entry. A stalled single root at purity 60 runs at 0.30, so NS takes 456 ÷ 0.30 ≈ 1,520 years against a 1,000 cap. Undefined behaviour. Options: re-place the guarantee when consumed; guarantee a copy the player can always reach; Market fallback from NS on. Also preview the ×0.25 drop before the attempt.

### Warnings
- ⚠️ **T1 (Cultivation Techniques, Realms).** Switching keeps layers, mastery and seal counts (no double-dip). Undefined: whether a gated layer mastered at the start of a new realm counts before or after the season-start rate (cong-phap 139–141 vs canh-gioi 81). G7 swap chore applies.
- ⚠️ **T4 (Cultivation Techniques, Meridian Map #6, Spiritual Roots).** With #6 there are two main methods; harmony is defined against "the main method" (cong-phap 176–185, 470). Which one sets it, and what H the second main's own bonuses take, is undefined. Options: main slot only; the worse of the two; treat the second main as an art.
- ⚠️ **T6 (Spiritual Roots, Cultivation Techniques, Meridian Map, Realms).** Five-element root at DT: 9 × 1.46 × 1.5 × 1.52 ≈ **30×** a single root at tech 1.0. linh-can's ×10.35 / ×12.6 understates this by about 2.4×. No cap on the product. Options: total speed cap; #6 as `max`; accept and document.

### Info
- ℹ️ **T3.** Both systems read season-start state, so no race. Excess mastery on a gated layer is lost with no warning; the bar has an Advisor warning (canh-gioi 669).
- ℹ️ **T5.** Losing a manual never unlearns; lost techniques are recorded. Cross-life carry-over is undecided (cong-phap OQ7). If techniques carry over, G3 becomes a cross-life stat race, which the user's direction rules out.

---

## GDDs Flagged for Revision

| GDD | Reason | Type | Priority |
|-----|--------|------|----------|
| cong-phap.md | G1 bonus pool feeds breakthrough odds; N6 AC-CP-48 lever cannot fit; T2 rule 18 persistence; G2–G7, T1, T4 | Design + Consistency | Blocking |
| canh-gioi.md | N5 `comp` undefined (or CS); N6 `climb_total` ranges out of date; G1 λ calibration excludes technique bonuses; N1, N3, N15, C6–C8 | Consistency + Design | Blocking |
| character-stats.md | N5 `comp` (if CS takes it); C2–C4, C6–C8, N7, N9, N12, N14 | Consistency | Blocking (shared N5) |
| linh-can.md | G4/G5/T6 make its dominance figures, years and speed multiples out of date; D4 deepened; C3, N17 | Design + Consistency | Warning |
| kinh-mach-do.md | C2, C3, N8 (weights), N2, N11, G6 (#6 tier) | Consistency + Design | Warning |
| systems-index.md (not a GDD) | N13 row 9; N19 out-of-date header, overview, tracker | Consistency | Warning |

---

## Verdict: FAIL

Four blocking issues: N5, N6, G1, T2. None needs a redesign.
- N5 is a missing formula whose as-built version exists.
- N6 is a lever choice the user already owns.
- G1 is the same calibration gap as D1, through a new channel.
- T2 is one missing sentence in rule 18.

### Required actions before re-running
1. **N5.** Define `comp` in Character Stats or in canh-gioi Formulas I, register `ngo_tinh_divisor`, and correct the 1.25 examples (or retune to match).
2. **N6.** Choose the lever for the 3+-element speed-up: re-derive `climb_total` safe ranges with Formulas A active, a per-element-count lever, or accept and restate the years table. Then update AC-CP-48, canh-gioi 835 and AC-CG-33a.
3. **G1.** Bound technique `herb_growth_pct`, `alchemy_success` and `lifespan_years`, or include them in canh-gioi Formulas D's calibration. Update canh-gioi 413–414 and AC-CG-30/31.
4. **T2.** State in cong-phap rule 18 what happens when the guaranteed source is consumed or lost, and add an Edge Case and an AC.

### Coverage
- **Phase 2 read:**
  - cong-phap Formulas A–E, Detailed Design 140–270, Dependencies through UI 692–835, ACs 1146–1261;
  - canh-gioi Detailed Design, Formulas A–C and H–I, Parameter keys, Dependencies, Tuning Knobs, Cross-References, OQ;
  - CS 150–269, Formulas H–I and Parameter keys, Dependencies, Tuning Knobs, Cross-References, AC 888–903, OQ;
  - linh-can 136–262, Formulas G and Parameter keys, Dependencies, Tuning Knobs, Cross-References, OQ;
  - KMD rule 7, Formulas F, Dependencies, Tuning Knobs, Cross-References, AC-KMD-21–25;
  - systems-index rows 6–10; registry 376–413, 700–764, 985–1049.
- **Phase 3/4 read:**
  - the prior review; cong-phap 1–698 and 1228–1276; canh-gioi 61–210 and 267–601;
  - linh-can 56–165, 270–437, 540–610 and 937–952; KMD 515–534, 662–761 and 780–854;
  - the `items_cong_phap.json` bonus pool. CS by grep only.
- **NOT ASSESSED:**
  - 2f against the rest of the KMD ACs (1603–2121 apart from 21–25) and the linh-can ACs. Reason: turn budget.
  - 2d registry sweep for duplicates among the four older GDDs beyond the keys named. Reason: turn budget.
- **Partial:**
  - 2b state transitions for death, lifespan and toxicity: checked only where cong-phap touches them.
  - 3b has no Time & Turn spec to check against.
  - G5 uses a normal approximation.
  - G9 is directional, because W is a guess.
  - G1 assumes `alchemy_success` adds points to brew success.
  - D9, D14 and S4 were not verified.
  - Edge Cases sections: out of scope by design (skill Phase 1c).

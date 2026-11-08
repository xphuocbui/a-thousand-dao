# Re-review 2026-11-08b — Combat Defence & Healing (#21a)

Target: `design/gdd/combat-defence.md` (as of commit 9400de1, the user's answers to re-review items 1–23).
Method: `/design-review`, lean mode, workflow `standard`, run unattended. No specialist agents (lean).
Read: the whole GDD by section; `rereview-2026-11-08-decisions.md` (passes 1–3); the latest entries of
`combat-defence-review-log.md`; the diff of 9400de1 for this GDD; combat.md Formulas D, E, E2 and rule 24;
combat-damage-types.md rules 1, 4, 5, 7; effects.md rules 5, 8, 11 and No Ward; the registry entries
`defence_ehp`, `down_step`, `soul_shield`, `soul_shield_share_max`, `dot_pool_cap`, `default_resist`,
`ward_gear_scale`, `ward_cap`, `ward_floor` and the block entry.

**Autonomous-path decisions** (logged in place of the skill's prompts):
- Freshness check: the GDD and registry are CHANGED since pass 3, so a full review ran.
- Systems-index update, review-log append, "revise now": not taken. This run may write only this file.
- Next step: apply the SAFE fixes, answer CD-04, then re-run `/design-review design/gdd/combat-defence.md`.

## Verdict: NEEDS REVISION

The user's 23 answers are almost all applied correctly and consistently. The soul shield (share and bar),
the Waiting state, the no-ward flags, the default-ward fix, b = 0 in ehp, the Down refusal, the live-change
rule, the new knobs, the cross-references and the three registry edits all match the decisions. The new ACs
(AC-CD-61 to 65) recompute correctly. Two blockers remain, and both are slips in how answers were applied,
not new design. First, Formulas A0 says it moved Combat Formulas D "unchanged", but it adds `min(a_w, 1)` to
ward strength (ws) and ward efficiency (we). That silently cuts top-end ward gear's bonus from +150 to +30.
Second, the CD 19 fix redefines `T` for cast wards as up time, but the cast cost `C_w` still uses
`floor(T / cooldown)`. Read literally, both catalogue cast wards then fail AC-CD-41. One new design gap also
appears: a drain-paid ward makes a linh lực tick (Qi Disruption) worse than no ward. The rest are wording,
AC and cross-reference fixes.

Completeness: 6/6 required sections at `standard` (Overview, Detailed Rules, Formulas, Edge Cases,
Dependencies, Acceptance Criteria). Player Fantasy is absent: advisory at `standard`; Game Feel covers it.
Dependency GDDs all exist (combat, character-stats, modifiers, combat-damage-types, effects, thien-kiep,
cong-phap, dao, item-database). Rough scope signal: L.

Counts: 2 blocking, 7 recommended, 7 nit. 15 SAFE, 1 DECISION.

## Findings

### CD-01 — BLOCKING — SAFE — A0 adds a cap to ward strength that Combat D never had

**Location:** Formulas › A0. Ward strength, ward efficiency and artifact defence, line 377 (formula) and
line 385 (`a_w` row). Also line 374–375 ("The values are unchanged").

**Problem.** The answer to CD 2 was to *move* Combat Formulas D's terms here. A0 says "The values are
unchanged", but its formula reads
"`ws = clamp(defense_pct + Σ ward_strength + 100 · ward_gear_scale · min(a_w, 1), ...)`" and the same
`min(a_w, 1)` for `we`. Combat Formulas D (combat.md line 530) has `100 · ward_gear_scale · a_w`, with no
cap. The only cap the user chose (2026-11-07, and Open Question 13) is on **gear block**: "the block from
ward gear capped at a = 1". The `a_w` row now says it "Counts up to 1 for ws, we and gear block", which
extends that block cap to ws and we.

Working: top-end ward gear is 5 × B_p (combat.md line 475; this GDD's Formulas B `a_b` row), so a_w = 5.
- Combat D: 100 × 0.30 × 5 = **+150** ws and +150 we.
- A0 as written: 100 × 0.30 × min(5, 1) = **+30**.

The typical anchor (a_w 0.85, +25.5) is unaffected, which is why no example caught it.

**Fix.** Line 377, replace both gear terms:
`ws = clamp(defense_pct + Σ ward_strength + 100 · ward_gear_scale · a_w, ward_floor, ward_cap)` ;
`we = clamp(ward_efficiency_pct + 100 · ward_gear_scale · a_w, 0, ward_cap)`
Line 385, `a_w` description, replace with:
"**All non-body artifact defence** (re-review CD 10; the role-tag rename is draft D2). Counts in full for ws
and we; counts up to 1 for gear block only (Formulas A2, Open Question 13)."
(If the user *does* want ws and we capped at a_w 1, that is a new decision with its own top-end re-derivation;
it should not ride in under "values unchanged".)

### CD-02 — BLOCKING — SAFE — The cast cost still uses `T`, which now means up time

**Location:** Formulas › F. Ward price check, Variables table: `V_w` row (line 666) and `C_w` row (line 667).

**Problem.** The CD 19 answer redefines `T` inside the `V_w` row: "**T** is `T_ref` for a standing ward and
the ward's up time inside `T_ref` for a cast ward, floor(T_ref / cooldown) × duration". The next row still
says "**Cast:** κQ · floor(T / cooldown)". Read literally, the cast cost now counts firings inside the up
time, not inside T_ref.

Working (Q = qi_max 172.74, I 36.5, T_ref 8 s):
- Black Tortoise Shell (cooldown 5 s, up 2 s): T = floor(8/5) × 2 = 2 s. C = 0.15 × 172.74 × floor(2/5) =
  0.15 × 172.74 × 0 = **0**. The ratio V / C is undefined, so the ward cannot pass.
- Golden Light Shield (cooldown 4 s, up 3 s): T = floor(8/4) × 3 = 6 s. C = 0.12 × 172.74 × floor(6/4) =
  20.73. V = 2 firings × min(0.09 × 172.74, 36.5 × 3) = 2 × 15.55 = 31.09. Ratio 31.09 / 20.73 = **1.50**,
  far over its 0.763 limit.
- Intended (firings inside T_ref): Black Tortoise C = 25.91, V = 0.33 × 36.5 × 2 = 24.09, ratio **0.930**;
  limit 0.61 × 1.25 × 1.25 = 0.953. Golden Light C = 41.46, ratio **0.750**; limit 0.61 × 1.0 × 1.25 = 0.763.
  Both match the catalogue.

So AC-CD-41 fails as written, for both cast wards.

**Fix.** Give the up time its own name. In the `V_w` row replace the T sentence with:
"**T** is `T_ref` for a standing ward. For a cast ward, resistance, block and evade use its up time inside
`T_ref`, `T_up = floor(T_ref / cooldown) × duration` (re-review CD 19; Black Tortoise Shell: 0.33 × 36.5 × 2 s
= 24.1, ratio 0.930)."
and write `r · I · T_up`, `min(B_w, I) · T_up`, `e · I · T_up` for cast wards where the row gives the
payload formulas. In the `C_w` row replace "**Cast:** κQ · floor(T / cooldown)" with
"**Cast:** κQ · floor(T_ref / cooldown)".

### CD-03 — RECOMMENDED — SAFE — Rule 1's path table has no row for a tick on linh lực

**Location:** Detailed Design › Core Rules, rule 1, path table (lines 65–70).

**Problem.** Combat Damage Types rule 4 (user decision 2026-11-08, re-review DT 3) added "A tick on linh lực
(Qi Disruption) | Force resistance → linh lực, passing every shield ... Never evade, never block". This
GDD owns the defence path, but its table only has "Over-time tick | resistance → the shields that do not let
it pass → health".

**Fix.** Add a row after "Over-time tick":
"| Tick on linh lực (Qi Disruption) | resistance (all + Force, rule 3) → linh lực, passing every shield. Never
evade, never block (Combat Damage Types rule 4) |"
Also add a matching line to Edge Cases › Shields after "If a tick arrives": "A tick on linh lực passes every
shield and comes off linh lực after resistance." (If Damage Types means Force resistance *without* all
resistance, its rule 4 should say so; rule 3 here sums both.)

### CD-04 — RECOMMENDED — DECISION — A drain ward makes a linh lực tick hurt more

**Location:** rule 8 (Drain row, line 166) and Formulas › C (line 552); rule 11 (default ward, line 229).

**Problem.** Drain bills linh lực for each point of damage it prevents. On a tick that already drains linh
lực, that bill can exceed what it saves. The default ward is the worst case, and every side with linh lực has
it.

Working: a Qi Disruption tick of 10 against the default ward only (all r 0.30, drain 2.0):
- lands 10 × 0.70 = 7.0 on linh lực; prevented 3.0; bill 2.0 × 3.0 = 6.0.
- total linh lực lost: 7.0 + 6.0 = **13.0**, against 10.0 with no ward. Resistance makes it 30 % worse.
- With the Common Ward at typical (rate 1.64 / 1.308² = 0.959, r 0.654): lands 3.46, bill 0.959 × 6.54 =
  6.27, total 9.73. A saving of only 2.7 %.

The same kind of trap ("strength can lose a fight") is what the drain rewrite was meant to remove.
Per-hit wards have a milder version: Golden Bell's fee of 18.49 per tick exceeds any one Qi Disruption tick
(capped at 5 % of `qi_max`, 8.6 at typical).

**Options.**
- **A (recommended).** Drain bills nothing for damage prevented on a linh lực tick; resistance still applies.
  Add to Formulas C: "a tick on linh lực bills no drain (its prevented damage is linh lực already)". Per-hit
  fees stay as they are, since straining under many small hits is the per-hit model's stated weakness.
- **B.** Drain bills on linh lực ticks, but each bill is capped at the points it prevents
  (`bill = min(pool, rate_w · prevented_w, prevented_w)`), so a ward never makes the tick worse.
- **C.** Keep the current rule, and document it as a known weakness of drain against Qi Disruption builds.

Whichever is chosen, add an AC with the 10-point tick above.

### CD-05 — RECOMMENDED — SAFE — Drain must bill in two steps, but rule 8 says one shared split

**Location:** rule 8, second bullet (lines 170–172); Formulas › C (line 552).

**Problem.** The CD 3 answer says a short pool's unpaid resistance share "is added back to `a_j` before
block", and drain-paid block is billed on "the block points the hit actually lost". So resistance bills
must be settled before block is taken, and block bills after. Rule 8 still says "**Several drain wards** bill
in proportion to the damage each prevents. If the pool cannot cover the total, each pays the same share",
which reads as one split across all drain wards, block payloads included. That is circular: the block a hit
loses depends on the resistance leak, which depends on the pool share, which would depend on the block bill.

**Fix.** Replace rule 8's second bullet with:
"- **Drain bills in two steps per hit part.** First, every drain-paid resistance payload (the default ward
included) is billed together. If the pool cannot cover the total, each pays the same share, and the unpaid
share of their prevented damage rejoins the part before block. Then block is taken, and every drain-paid
block payload is billed together from what is left, by the same rule (Formulas C)."
Add to Formulas C after the `bill` term: "resistance bills are settled before block; block bills after."

### CD-06 — RECOMMENDED — SAFE — Whether other block makes up a drain block's unpaid share

**Location:** Formulas › C (line 552) and Output Range (lines 575–576); AC-CD-61 (line 1109).

**Problem.** "a drain-paid block's unpaid share is simply not taken" does not say whether the other block
sources (flesh, gear, other wards) then take more. Their own share was computed from `B_hit`, so the literal
reading is that they do not. The doc should say so, because an implementer may "refill" from spare flesh block.

**Fix.** Append to the Output Range: "The other sources keep their own shares; they do not cover the unpaid
part, which moves on to shields." Add to AC-CD-61: "**GIVEN** the same hit and a pool that pays only half of
the ward's 3.0 bill, **THEN** the ward takes 1.5, flesh and gear take 2.0, the hit loses 3.5 points of block,
and 1.5 more moves on to shields."
Working: other sources' share = 5 × 4 / 10 = 2.0; ward 5 × 6 / 10 = 3.0, half paid = 1.5; 2.0 + 1.5 = 3.5;
5 − 3.5 = 1.5.

### CD-07 — RECOMMENDED — SAFE — AC-CD-60's block case no longer matches the new `blk_w`

**Location:** Acceptance Criteria, AC-CD-60 (line 1108).

**Problem.** "**GIVEN** a drain-paid block payload of 8 points on a hit whose parts total 5, **THEN** it bills
`rate_w` × 5." Under the CD 3 formula `blk_w = min(B_hit, Σ a_j) · B_w / B_hit`, the ward gets all 5 only
if it is the hit's only block. That never happens: flesh block is `flesh_block · n_body` with n_body ≥ 0.25,
so B_hit always has a flesh term. On FX-U (flesh 0.278 points): B_hit = 8.278, and
blk_w = 5 × 8 / 8.278 = **4.83**, not 5.

**Fix.** Replace the clause with: "**GIVEN** a drain-paid block payload of 8 points on FX-U (flesh 0.278, so
`B_hit` 8.278) and a hit whose parts total 5, **THEN** it bills `rate_w` × 4.83."

### CD-08 — RECOMMENDED — SAFE — AC-CD-49 contradicts the live-change answer, and CD 20 has no AC

**Location:** AC-CD-49 (line 1090); Edge Cases › Compile (lines 863–866).

**Problem.** The CD 20 answer says "Ward slots and every **base** defence sum are compiled once ... Curses and
Effects apply live on top". AC-CD-49 still says "**THEN** ward slots and the defence sums are unchanged",
which a curse mid-fight would break. Nothing tests the live part.

**Fix.** AC-CD-49: change "the defence sums" to "the base defence sums". Add:
"- **AC-CD-66** [Logic] Edge Cases, Compile (re-review CD 20). **GIVEN** FX-T with the Common Ward and a
curse that lowers all resistance by 0.10, applied at 3 s, **THEN** a part resolved before 3 s uses r 0.654, a
part resolved in a later instant uses r 0.554, and ward slots are unchanged."
Working: 0.654 − 0.10 = 0.554.

### CD-09 — RECOMMENDED — SAFE — The Combat change list misses the soul-ward lines

**Location:** Open Questions row 2 (line 1124); Dependencies, Combat row (line 872).

**Problem.** Soul wards and soul shields now act on soul hits (rule 14, Formulas B). Combat rule 24 says a
soul attack "ignores wards and body guard", and Combat Formulas E2 says "Wards, body guard, evade and crit do
not apply". Neither is on the #43 list. The Dependencies row also omits the A0 stub, which OQ 2 already names.

**Fix.** OQ 2: after "Formulas K's `t_w` and `t_h`," insert "rule 24's and Formulas E2's 'ignores wards'
(soul wards and soul shields now apply, this GDD's rule 14)". Dependencies › Combat row, "Lists this
system?": replace "and all of Formulas D," with "and all of Formulas D (leaving a stub that cites Formulas
A0), updates rule 24 and E2 for soul wards,".

### CD-10 — NIT — SAFE — `we` still names only the Modifier System as its source

**Location:** Formulas › C, Variables table, `we` row (line 559).

**Problem.** "we | float | 0–400 | Modifier System (`ward_efficiency_pct`)". After CD 2, `we` is computed in
A0 and includes the gear term. Formulas A's `ws` row was updated to "Formulas A0"; this one was not.

**Fix.** Source cell: "Formulas A0 (`ward_efficiency_pct` plus the gear term)".

### CD-11 — NIT — SAFE — Two places still call a cast ward between firings "down"

**Location:** Formulas › F, `α_m` row (line 671); UI Requirements, Ward row (line 921).

**Problem.** CD 22's answer: "Waiting" before the first firing, "Expired" between firings. The `α_m` row says
"cast is down until its first firing and between firings". The UI's ward row lists "up, down, broken,
expired, off" and has no Waiting.

**Fix.** `α_m` row: "Upkeep can fail and grows; a cast ward is Waiting until its first firing and Expired
between firings". UI: "showing state (waiting, up, down, broken, expired, off)".

### CD-12 — NIT — SAFE — AC-CD-65's fixture can still have the default ward up

**Location:** AC-CD-65 (line 1113).

**Problem.** "a side whose only wards are reserved (b = 0)". Under rule 11 as now worded (CD 8), a reserved
ward that does not apply to a part (Flame-Quelling Aura's Fire resistance on a Physical part, or Clear Heart
Ward) leaves the default ward Up for that part. The default ward is drain-paid, so b > 0 and the AC's premise
fails.

**Fix.** "**GIVEN** a side whose only ward is Still Lake Aura (reserved, all resistance, so the default ward is
never Up and b = 0), **THEN** ehp is P / λ_all and nothing divides by 0."

### CD-13 — NIT — SAFE — The CD 6 shield states have no AC

**Location:** rule 9 (lines 191–192); Acceptance Criteria › Shields.

**Problem.** "A standing shield starts full at t = 0. While its ward is Down (unpaid), the shield keeps its
value, does not soak and does not recharge." No AC tests it.

**Fix.** Add:
"- **AC-CD-67** [Logic] Rule 9 (re-review CD 6). **GIVEN** Thousand-Layer Cloud on FX-T, **THEN** its shield
is 45.2 at t 0. **GIVEN** its upkeep fails while the shield holds 20, **THEN** while it is Down the shield
soaks nothing and is still 20 five seconds later."
Working: 0.20 × 172.74 × 1.308 = 45.19.

### CD-14 — NIT — SAFE — The soul shield's pass list is not where the other defaults are

**Location:** rule 9, third bullet (lines 187–189); Formulas › B, soul shield note (line 538).
Cross-document: combat-damage-types.md rule 7.

**Problem.** Formulas B says "A soul shield is a ward shield passed by everything except Soul hits". Rule 9
says "Ward shields are passed by Soul and by ticks by default", and Damage Types rule 7 lists only ward and
body shield defaults. A reader of rule 9 alone would think a soul shield is passed by Soul.

**Fix.** Rule 9, after "...and a poison slips past it.": add "Soul shields are the reverse: passed by
everything except Soul (Formulas B)." Note for the Damage Types owner: add the same line to its rule 7
defaults (that file is not edited here).

### CD-15 — NIT — SAFE — AC-CD-59's slow hitter is not a defined fixture

**Location:** AC-CD-59 (line 1107).

**Problem.** "a slow-hitter variant whose hits come more than 2 s apart" names no hit size or kit, so two
testers could build different attackers. Formulas A2 already defines a slow kit.

**Fix.** Replace with "**AND** a slow-hitter variant: FX-T with only Formulas A2's slow art (c 3.3, 3 s
cooldown, D 68.1 at Qi Refining, scaled per realm) and no basic attack".

### CD-16 — NIT — SAFE — "Applies to the part" needs one clause for broken and passed shields

**Location:** rule 11 (lines 225–228).

**Problem.** Rule 11 says a ward "whose only payload is a broken shield counts as Up", and then that a ward
with no resistance, block or shield payload "that applies to the part" does not. It does not say whether a
broken shield "applies", or whether a shield the part passes (a tick against a ward shield) does. The CD 8
answer ("for that part") implies: a shield applies to a part it is not passed by, full or broken.

**Fix.** Replace "A ward with no resistance, block or shield payload that applies to the part" with "A ward
with no payload that applies to the part (resistance on all or on the part's final type; block, for hits
only; or a shield the part does not pass, full or broken)".

## Answers checked and found correctly applied

CD 1 (soul shield: share capped at 0.75, ws scales the bar; AC-CD-62 recomputes: 5 + 1 soaked, 5 and 5 lost),
CD 2 (apart from CD-01), CD 3 (formula and AC-CD-61: 5 × 6 / 10 = 3.0; gaps in CD-05 to CD-07), CD 4,
CD 5, CD 6, CD 7, CD 8, CD 9, CD 10, CD 11, CD 12 (OQ 15), CD 13 (registry `defence_ehp`, `default_resist`,
`dot_pool_cap`), CD 14 (all seven knobs plus `soul_shield_share_max`), CD 15, CD 16, CD 17 (OQ 17), CD 18
(OQ 16), CD 19 (apart from CD-02), CD 20 (apart from CD-08), CD 21 (rule 19, Edge Cases, AC-CD-64; registry
`down_step` now cited), CD 22 (apart from CD-11), CD 23 (the `[fire, over_time]` row is gone).

Spot-recomputed this pass and correct: A0 anchor (100 × 0.30 × 0.85 = 25.5; 30.8 − 25.5 = 5.3), Formulas C
example (27.0 × 0.959 = 25.9), Formulas D (45 × 1.45 × 1.25 = 81.6; 60 × 1.45 × 1.82 = 158.3), AC-CD-06,
-19, -20, -28, -30, -32, -36, Soul-Guarding Lamp's bar (0.10 × 172.74 = 17.3). Not recomputed (needs harness
data): AC-CD-46's other-realm mirrors, "446 against top-end hits", AC-CD-59's outcome.

<!-- PROTOTYPE - NOT FOR PRODUCTION -->
<!-- Question: Does drafting/fusing fragments into a chain engine make players rework builds, and can a local LLM narrate it within engine budgets? -->
<!-- Date: 2026-11-02 -->

# Concept Prototype Report: Dao Engine

> **Date**: 2026-11-02
> **Prototype Path**: Engine (Godot 4.7.1, GDScript)
> **Concept File**: design/gdd/game-concept.md

---

## Hypothesis

**A (primary):** If the player drafts fragments and fuses them into a chain engine with a live
preview, they deliberately rework their build to push the result higher — evidenced by 3+
deliberate rework actions in a 10-minute session, asking for another run, and optimized builds
clearly beating naive ones.

**B (layered):** A local LLM narrates a resolved clash and invents one in-budget event fast and
cleanly enough to carry the game — evidenced by < ~5 s per call and >= 9/10 valid events.

---

## Riskiest Assumption Tested

That tag-based fragment triggers produce chains that are legible *and* surprising. It did not hold:
the chain was legible but there was no underlying system to be surprised by.

---

## Approach

A separate Godot project: 12 fragments (6 hard-coded behaviours: strike, amp, echo, grow, synergy,
combo), draft 1-of-3 with best-placement preview, fuse/move/discard, three stage fights as a
stat-check damage race against enemy HP, a clash log, templated narration, and an LLM harness
(OpenAI-compatible HTTP, strict/lenient JSON validation, per-stage budget clamping, check for
invented numbers in narration, x10 benchmark).

**Path chosen:** Engine
**Reason for path:** the chain payoff was framed as a feel question, and the Godot build also
exercised the real local-LLM integration path.

**Shortcuts taken (intentional):**
- UI built in code from plain controls; no art, audio, menus or saves
- Hard-coded fragment data and enemy HP (calibrated by a headless sim)
- No local model installed; LLM plumbing verified against a deliberately misbehaving mock only

---

## Result

- **Headless verification passed:** scripted playthrough (draft, fight, stage progression,
  fuse/move/discard, new run) with no script errors; two screenshots of the draft and clash screens.
- **Balance sim, before any human play:** v1 builds barely differed (reordering worth ~1.1x; a
  deliberate drafter beat a naive one by 1.53x). Two tuning passes reached 2.0x — still not a
  "detonation".
- **Playtest (the user, internal):** rejected on first contact. Quote: *"this does not encapsulate
  the spirit of the game at all, the spirit of the game is you suppose to have a system, then
  build stuff with that system, it doesn't even have a decent system."*
- **LLM harness (mock only):** HTTP, strict vs lenient JSON, rejection of broken JSON, clamping of
  out-of-budget rewards, flagging of an invented narration number, and an unreachable endpoint
  all behaved as designed. Real model speed and quality: **not measured** (no model installed).

---

## Metrics

| Metric | Value |
|--------|-------|
| Path used | Engine |
| Iterations to playable | 1 build (verified headless before handing over); 3 balance-tuning iterations |
| Prototype duration | ~half a day of build and verification |
| Playtesters | 1 internal (the developer) / 0 external |
| Feel assessment | "Doesn't have a decent system": fragments read as stat blocks; the only decision is picking bigger numbers |
| Hypothesis verdict | A: REFUTED (the framing, not just the tuning). B: NOT ASSESSED (plumbing only, no real model) |

---

## Recommendation: PIVOT

The prototype answered the wrong question well. It showed that a chain of stat-block fragments
racing an HP number is not this game, whatever its numbers: the developer wants a ruleset of
primitives with properties and interactions that the player understands and builds inside, with
power emerging from what they build. The concept's other commitments — one cultivator's life, a
bounded LLM that never owns the numbers, inspectable math — were not contradicted.

CD-PLAYTEST skipped — Lean mode.

---

## If Pivoting

**Pivot direction:** replace the fragment damage race with a cultivation system in the style of
*Phàm Nhân Tu Tiên* (systems and genre conventions only; original world, names and items):
linh căn, cảnh giới with power levels and bình cảnh, linh thảo + luyện đan, luyện chế pháp bảo,
linh thú / linh trùng, phù lục, trận pháp. "Compose your Dao" folds in as công pháp you find and
combine. Linh căn redesigned: **more elements is better**, with a large biến dị linh căn system.
Details in `PIVOT-NOTE.md`.

**What to keep:** one cultivator per life; the bounded-LLM architecture (engine owns numbers,
budgets, clamping, templated fallback, number-faithfulness check); inspectable numbers; the Godot
+ HTTP plumbing.

**Next step:** rework `design/gdd/game-concept.md` around the system, then `/prototype` the revised
hypothesis.

---

## Lessons Learned

- **What assumptions were broken by actually building this?** That "compose your Dao" could be
  expressed as a list of effect cards. Without primitives and rules underneath, there is nothing
  to theory-craft — only numbers to compare.
- **What surprised us that didn't show up in the brainstorm?** The developer's anchor is a specific
  systemic tradition (Phàm Nhân Tu Tiên's cultivation economy), which the brainstorm never
  surfaced; the Balatro/Slay the Spire references pulled the prototype toward card-like stat blocks.
- **What would we test differently next time?** Ask what *system* the player builds inside before
  choosing what to prototype, and test whether the rules are legible and exploitable (a Paper or
  spreadsheet sim is enough) before testing feel.

---

> *Prototype code location: `prototypes/dao-engine-concept/`*
> *This code is throwaway. Never refactor into production.*

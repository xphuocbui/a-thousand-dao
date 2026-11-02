<!-- PROTOTYPE - NOT FOR PRODUCTION -->
<!-- Question: Does drafting/fusing fragments into a chain engine make players rework builds, and can a local LLM narrate it within engine budgets? -->
<!-- Date: 2026-11-02 -->

# Dao Engine Prototype

**Status:** concluded — **PIVOT** (2026-11-02). See `REPORT.md` and `PIVOT-NOTE.md`. Hypothesis B
(real local model) was never run; the LLM plumbing in `llm.gd` is the part worth re-testing.

Concept prototype for `design/gdd/game-concept.md` (Ten Thousand Daos). Throwaway code:
never import it from `src/`, and rewrite from scratch if the concept proceeds.

## Hypotheses

**A (primary, no LLM).** If the player drafts fragments and fuses them into a chain engine with a
live preview, they deliberately rework their build to push the result higher.
*Signal:* 3+ deliberate rework picks (move / fuse / discard, counted in the title bar) in a
10-minute session, the tester asks for another run, and optimized builds clearly beat naive ones.

**B (layered on top).** A local model can narrate a resolved clash and invent one in-budget event
fast and cleanly enough to carry the game.
*Signal:* average call under ~5 s and at least 9 of 10 events valid (the **Benchmark x10** button).

**Riskiest assumption:** tag-based fragment triggers give chains that are legible *and* surprising.

## How to run

Godot 4.7.1 (see `project.yaml` for the path on this machine). From this folder:

```
"C:/Godot/Godot_v4.7.1-stable_win64.exe" --path . --windowed --resolution 1280x720
```

Or open this folder in the Godot editor and press F5.

- Draft 3 fragments (the button shows the best slot for each and the chain total it would give),
  then **FIGHT!**. Three stages; the last is the tribulation. Select two slots (ctrl/shift-click)
  and **Fuse**, or **Move**/**Discard**. Six slots maximum, so fusing becomes necessary.
- Every action is logged to `user://session.log` (Godot user data folder).
- `-- --autoplay` after the Godot args drafts blindly and fights once (used for screenshots).

### LLM half (hypothesis B)

1. Run any OpenAI-compatible local server (Ollama default `http://localhost:11434/v1/chat/completions`,
   LM Studio `http://localhost:1234/v1/chat/completions`) and pull a small model.
2. Set the URL and model in the two boxes at the bottom right.
3. **Narrate (LLM)** after a fight: checks the narration for numbers the engine did not produce.
   **Invent event (LLM)**: JSON event, reward clamped to a per-stage budget. **Benchmark x10**: pass/fail
   against the hypothesis-B signals.
4. With no server, everything else still works (templated narration is the fallback).

No local model was installed when this was built. `mock-llm.js` (`node mock-llm.js`) is a mock
endpoint that misbehaves on purpose (fenced JSON, broken JSON, out-of-budget values, invented
numbers); it tests the plumbing and the validation only, **not** model quality or speed.

## Files

| File | Purpose |
|---|---|
| `core.gd` | Fragments, chain simulation, fusion, enemies (pure logic) |
| `main.gd` / `main.tscn` | Single-screen UI built in code, telemetry |
| `llm.gd` | HTTP client, JSON validation, budget clamping, narration number check |
| `sim.gd` | Headless balance sim: `godot --headless --path . -s sim.gd` |
| `smoke.gd` | Scripted playthrough of the scene (headless) |
| `llm_test.gd` | Headless check of `llm.gd` against an endpoint |
| `core_v1.gd.txt`, `core_v2.gd.txt` | Earlier tuning iterations, kept for the record |
| `shots/` | Screenshots of the draft and clash screens |

## Findings so far (pre-playtest, from the balance sim)

- v1 (amp boosts only the next slot): reordering a build was worth only ~1.1-1.15x; a deliberate
  drafter beat a naive one by 1.53x. Builds barely differed.
- v2 (amp boosts all later slots): ordering gain ~1.2x, drafter advantage still ~1.5x.
- v3 (stronger amps, steeper growth, bigger synergy/combo payoffs): ordering gain ~1.33x, drafter
  advantage **2.0x** (best optimized build ~6.6x the worst naive one). Better, still short of a
  "detonation". Whether it is enough is a human-playtest question.
- Slots fill by stage 2, so fusion/discard becomes forced in stage 3.
- Harness plumbing verified against the mock: strict vs lenient JSON counted separately, bad JSON
  rejected, out-of-budget values clamped, invented narration numbers flagged, unreachable endpoint
  handled without a crash.

Playtest results and the PROCEED/PIVOT/KILL verdict are recorded in the prototype report.

# ADR-0007: The Frontend's Own Block in Save Files

## Status
Accepted (the user's decision 2026-11-24: outliner pins "Save them").

## Date
2026-11-24

## Last Verified
2026-11-24 (Godot 4.7.1; `tests/unit/ui/ui_outliner_test.gd`)

## Decision Makers
The user ("Save them", 2026-11-24, when asked whether outliner pins should survive a reload), with the assistant
drafting.

## Summary
A save file is `GameSession.to_dict()` written by the map screen. The frontend's own bookkeeping (today only the
outliner's pinned people) goes beside it as one top-level key, `"frontend"`, which the map screen writes after the save
job returns and reads back after a load. `GameSession` never reads or writes it, and the save version does not change.

## Engine Compatibility

| Field | Value |
|-------|-------|
| **Engine** | Godot 4.7 (installed 4.7.1) |
| **Domain** | Persistence (save files), UI |
| **Layer** | Presentation |
| **Knowledge Risk** | LOW: plain `Dictionary` and `JSON` through the existing `SaveStore`; no post-cutoff API |
| **Post-Cutoff APIs Used** | None |

## ADR Dependencies

| Field | Value |
|-------|-------|
| **Depends On** | ADR-0006 (GameSession facade and frontend rule): the frontend may not add state to `GameSession`, so its bookkeeping stays in the frontend |
| **Enables** | Any later frontend-only state worth keeping with a save (window history, map camera), as more keys in the same block |

## Context
The outliner (design/ux/outliner.md) pins up to 12 people. The pins lived only in `user://outliner_pins.cfg`, keyed by
world seed and player id, so they did not travel with a save: loading an older save showed the pins as they were last
set, not as they were saved, and a copied save file had none. Pins are not game state (no rule reads them), so putting
them into `GameSession` would add a member, an Action and a job round trip for a convenience, against ADR-0006's aim of a
narrow facade.

## Decision
- **Write.** `_on_save_done` (the main thread, after the `to_dict` job) adds `out["frontend"] = OutlinerPins.to_save(world
  key)`, i.e. `{"outliner_pins": [ids, oldest first]}`, before `SaveStore.write`.
- **Read.** `_load_game` (the load job) passes `d.frontend` through untouched; `_on_load_done` calls
  `OutlinerPins.from_save(world key, block)`, which replaces that world's pins (capped at `outliner_pins_max`, repeats
  dropped).
- **Older saves.** A save without the block (before 2026-11-24) leaves the pins as they are in the ConfigFile.
- **During play** the ConfigFile stays the live store, so pins still survive a crash between saves.
- `GameSession.load_dict` ignores unknown keys, so the block needs no save-version bump; a future frontend key is added to
  the same block, never at the top level.

## Alternatives Considered
1. **A `GameSession` member and an Action `set_pins`.** Rejected: pin toggles would become jobs and the facade would carry
   state no rule reads (ADR-0006).
2. **A separate file per save (`<slot>.ui.json`).** Rejected: two files per save can drift apart or be copied singly.
3. **Keep the ConfigFile only.** Rejected by the user ("Save them").

## Consequences
- Positive: pins load with the save they were made in; no change to the session, its tests or the save version.
- Negative: the map screen now touches the save dictionary on both sides; a second frontend (the debug terminal) writes
  saves without the block, which loads as "no pins saved".

## Validation Criteria
`tests/unit/ui/ui_outliner_test.gd` `test_a_save_carries_the_pins_and_a_load_restores_them_adr_0007`: the block's JSON
round trip, restore-as-saved, an older save leaving the pins, the cap and repeats.

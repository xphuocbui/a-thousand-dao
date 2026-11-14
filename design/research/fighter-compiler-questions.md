# Fighter compiler: what a Character needs before it can fight (2026-11-14)

ADR-0001 step 3 turns a Character into a `FighterProfile`. The engine is finished and matches the sim; this note
lists what the *game data* lacked for the Character path, and the decisions that were yours. Written overnight;
**decided 2026-11-14** (see Decisions) and built the same day.

## Decisions (user, 2026-11-14)
1. **Arts and wards:** export all 223 authored arts and the parsed ward records. Done: `assets/data/combat_library.json`
   (282 arts with the common and item arts, 171 items, 38 of 40 wards run) from
   `tools/design/combat_sim/export_combat_library.py`; fight.py's library now resolves the authored part arts too.
2. **Layers and pools:** typical for the realm until the Meridian Map returns. Done: `FighterCompiler.compile()`.
3. **Modifier table:** in `combat_engine.json` `CHARACTER_MODS`, read by fight.py and the compiler. Done.
4. (ADR-0002 accepted with a project-owned hash; not a compiler question.)

The build-file step (`BuildFileCompiler`, a port of fight.py's `expand_library()` and `to_build()`) matches fight.py
on 58 cases holding every named item and every art (`tests/parity/compile_parity_test.gd`,
`compile_parity_export.py`). Choices the compile makes that are not settled design, all in `FighterCompiler`'s doc:
a Character with no arts of its own fights with the typical kit; a Character's sheet lines run as one always-on
Effect; ordinary pieces' affixes (scoped ones too) join the sheet lines.

## Done tonight (no design needed)
- **Data-built enemies.** `FighterCompiler.from_data(kind, realm, gd)` loads the sim's reference fighters (typical,
  top_end, top_end_the_tu, realms 0-4) from `assets/data/combat_reference_fighters.json`, which
  `tools/design/combat_sim/export_reference_fighters.py` writes from fight.py's own definitions (`--check` reports
  drift). A data-built typical mirror fights row for row like its parity fixture.
- **Constants through Config.** `CombatConstants.from_game_data(gd)`.
- **The request and service.** `FightRequest` and `CombatService.resolve()` with starting shares (Combat rule 3);
  `no_heal` and ground tags are refused by name until both engines run them.

## What the Character path needs

| # | Piece | In game data today | What fight.py does (the balance-tested path) | Decision needed |
|---|---|---|---|---|
| 1 | **Arts** | None for techniques; named items list art ids only (`items_named.json` "arts"); the 223 authored arts live in `design/arts/` | Converts a design art: `c_art` -> c, `cost_share / cost_scale` -> cost, `cooldown` -> cd, `kind` -> dtype; the art's own Effects and counters join the fighter | Export authored arts to `assets/data/combat_arts.json` (an exporter like the reference fighters, one source)? All 223, or only arts placed on techniques and items? |
| 2 | **Wards** | Named items' wards have an id, a name and an empty "rule"; no payload or payment | `parse_ward()` reads the GDD wording (payload, payment, activation) from the design catalogue, then scales by ward strength and efficiency | Export the parsed ward records with the item catalogue? |
| 3 | **Damage layers and pools** | The stat sheet has no layer points; build files hand-set `layers`, `n_body`, `n_qi`, ward strength | Hand-set fields, budgeted per realm (`layer_budget`, `field_budget`) | Until the Meridian Map returns (it is parked; memory "build stats from pieces"), start every Character at its realm's **typical** layers and pools and add item and technique modifiers? (Recommended: it keeps every fight inside the tuned envelope.) |
| 4 | **Modifiers** | The stat sheet sums item, technique, edge and root modifiers by key | `PASSIVE_MOD` maps 33 keys to engine mods (`crit_chance_pct` -> crit, `resist_pct` -> resist, `art_cost_pct` -> cost_red x -0.01, ...); `OUT_OF_FIGHT` skips 12; `STATIC` folds 8 into build fields (`apply_static`) | Move `PASSIVE_MOD`, `OUT_OF_FIGHT` and `STATIC` into `combat_engine.json` so the compiler and fight.py read one copy? |
| 5 | **Effects** | Named items list Effect names; the library is in `assets/data/combat_effects.json` | `add_library_effect()` resolves by name, counting worn pieces for "count" Effects | None beyond porting: the library is already shared |
| 6 | **Slots** | Item slots (rule 11) exist; art slots by realm are in fight.py's constants | `slots_by_realm` + `bonus_slots`; extra wards fill ward slots, then art slots | Port as specified |
| 7 | **Situation and preparation** | Talismans, pills, formations exist as items | fight.py does not model preparation per situation | Design work (Combat rule 12): what each situation compiles |

## Recommended order
1. Answers to 1, 2, 3 and 4 above.
2. Exporters for arts and wards (data, no rules).
3. `FighterCompiler.compile()` for the player: realm, typical layers (3), modifiers (4), arts (1), wards (2), library
   Effects (5), slots (6); a report of everything it could not compile, like fight.py's "unmodelled" lines.
4. ADR-0001 step 4: `CombatService` behind a flag in the Event Engine's combat check (ADR-0002 first).

## Findings from the port that touch content
- **Fixed 2026-11-14:** `metal-earthbind-drop` laid stacks of element `tho` (Hán-Việt for Earth) where the engine
  wants `earth`; the sim ran it silently. Now `earth`, and the sim's validate() refuses a non-engine stacks element.
- **Arts that read counters nothing builds** (heat, peal, charge, feather, echo, toll, coil, strata): steps and
  empowers waiting on an engine another piece builds. Both engines read an undefined counter as 0; the Godot loader
  now reports it as a warning rather than refusing the fighter.
- **A step field nobody runs:** `reckless-gale`'s second step sets `hp_cost` (0.12), which the sim's `override()`
  ignores; the Godot loader refuses it by name, so a Character with that art does not compile (listed as a known
  refusal in the compile parity test). Either add `hp_cost` to the override table (both engines) or move it off the
  step.
- **Final Clause** listens for `down`, which neither engine raises; it never fires.
- **`strip` without an element** picks the largest buff pile and breaks ties in Python set order (unstable between
  runs). Give tied piles a rule (oldest first?) in both engines.
- **Sealed Meridian recast:** the GDD says a recast while it runs does nothing; both engines refresh its duration.

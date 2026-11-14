# Fighter compiler: what a Character needs before it can fight (2026-11-14)

ADR-0001 step 3 turns a Character into a `FighterProfile`. The engine is finished and matches the sim; this note
lists what the *game data* still lacks for the Character path, and the decisions that are yours. Written overnight,
so nothing here is decided.

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
- **A step field nobody runs:** one authored step sets `hp_cost`, which the sim's `override()` ignores; the Godot
  loader refuses it by name. Either add `hp_cost` to the override table (both engines) or move it off the step.
- **Final Clause** listens for `down`, which neither engine raises; it never fires.
- **`strip` without an element** picks the largest buff pile and breaks ties in Python set order (unstable between
  runs). Give tied piles a rule (oldest first?) in both engines.
- **Sealed Meridian recast:** the GDD says a recast while it runs does nothing; both engines refresh its duration.

# Brief: fix pass A, mechanical (world-depth review fixes)

The content review found mechanical errors (`design/world/depth/review/RANKED.md` group A; full detail with suggested
fixes in the `read-*.md` files). You fix them in your batch's files. Do not rewrite stories: that is a later pass (B).

## Read
- `review/RANKED.md` (group A).
- Every `read-*.md` finding that names a file in your batch (grep the reviews for your sect and group keys).
- `DECISIONS-2026-11-25.md` (rulings) and `schema.md`.

## Fix, in your batch's files
1. **Caps in pieces.** "up to", "at most", "no more than", "capped", "max" in item, set, technique and art rules.
   Remove the cap and let the piece scale. Where it would run away, add a closing cost or a decay (Effects rule 19). A
   real threshold ("below 25 % health") is a condition, not a cap: keep it.
2. **Timeline slips.** Check birth years against the events the person takes part in (they must be alive and old
   enough). Founders who die of "old age" must die at their realm's lifespan or of another cause (Nguyên Anh lifespan
   1,000, Kết Đan 500). Fix the dead/alive notes in ties, and the date clashes the reviews name.
3. **Distances.** A tile is 25 km. Turn "a walk" or "every morning" into a real travel time, or move the place nearer
   (use place ids from `_inputs/`).
4. **Weapons.**
   - A sword cultivator (or a sword school's member) wears a sword: a named one, or a `phi_kiem` base.
   - A bow or staff school has its weapon. Use the nearest base and note the missing base; bow, staff and sabre bases
     are an Item DB open question.
   - If a "sword" label is wrong for the build (a ward build), fix the archetype instead.
5. **Leftover routes.** Tier A routes with a placeholder note, made before the lineages: redo them from the sect's
   `lineage.tree_route` and the person's build (`_brief-build-targets.md` method). Check each with
   `python -I tools/design/world/depth_tree.py route <key>`.
6. **Doubled ties.** The same pair and kind twice: merge them. Remove leaked secrets, where a junior "knows" what only
   the secret's holder knows.
7. **R2 roots.** Core ranks below the admission bar (for example Cửu Cao's riders with Wind 26-40 against 45): raise
   the root, or make them outer disciples with an `exception`.

Edit with careful substring replacement (the JSON files are hand-formatted); validate that each file parses. Run
`python -I tools/design/world/depth_check.py` until it is clean. Touch only your batch's files. Do not commit. Prefix
scratchpad files with your batch name. Report briefly (under 150 words): counts fixed per kind, and anything left.

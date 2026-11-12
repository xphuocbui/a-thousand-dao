# Fixed World: Decisions (2026-11-12)

Status: decided by the user 2026-11-12. The GDD rewrites below are not yet done.

## Decision

Every playthrough uses the same continent: same tiles, same map, same sects, same starting
political influence, and some of the same special characters.

Why: a beautiful map matters a lot. A fixed world allows a hand-finished, painted continent,
learnable geography and authored lore. Replay variety comes from people, secrets and play,
not from coastlines.

## Follow-up answers

| Question | Decision |
|---|---|
| Ordinary cultivators (all but the fixed special characters) | Random each game, from the seed |
| Secrets, hidden places, secret-realm spots, resource reserves | Rolled per game from a few hand-picked candidate spots each |
| History before the game starts | Fully authored, the same every game |
| Player start | Set by the chosen origin; each origin has a few home regions |

## Map art direction (follows from the decision)

- One painted continent (AI-assisted, hand-finished) with no cities, roads, labels or borders baked in.
- Grid data (120 × 80) is derived from painted index images (biome, elevation, moisture), not noise.
- Dynamic things are sprites and overlays: sites, cities, territory, qi mist, the knowledge mask, scars.
- No permanent visible grid; show the tile under the cursor, routes and search areas when needed.
- Art style still to be picked from `prototypes/map-style-demos`.

## What this changes (to do, section by section with the user)

- Travel & Map: rule 1 ("one generated world") and Formulas C (land generation).
- World Generation & History (#27): keeps random NPCs and their generated backgrounds, which fit
  inside the authored history; sects, territories, special characters and past events become
  authored data.
- Game concept and systems index: the world description and #27's role.
- Other GDDs that mention world creation in passing: a wording check.
- New authoring work: continent layout, secret candidate spots, an origins list with home regions.

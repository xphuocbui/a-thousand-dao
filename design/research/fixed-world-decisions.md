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

## Map art direction (decided 2026-11-13)

Two map views, each made the way it suits best:

- **Overview (zoomed out): an AI-generated painting** of the whole continent, about 3–4k px. It shows the
  large geography (mountain ranges, jungles, coasts, rivers), the famous places, cities and sects, and the
  political map.
- **Zoomed-in view: rendered.** A ground shader draws the land from the index images, and stamps (mountains,
  forests, towns) are placed by rules, then hand-fixed in an editor. This view shows the detailed geography
  and the tiles, which carry the map elements and their info.

Rules that keep the two views consistent:

- Grid data (120 × 80) comes from authored index images (biome, elevation, moisture), not noise. Both
  views are built from them.
- The painting follows the layout: the index images (or a rough render of them) are the guide image for
  the AI, so the coasts, ranges and rivers line up with the tiles. It is generated late, once the geography
  settles; until then a plain render of the overview stands in.
- Only permanent landmarks are painted in. Political borders, cities, sects and markers are overlays on the
  painting, so territory changes and discoveries show.
- At the zoom threshold the two views crossfade. They share a palette (biome colours sampled from the
  painting feed the ground shader) and one paper texture.
- In the zoomed-in view, dynamic things are sprites and overlays: sites, cities, territory, qi mist, the
  knowledge mask and scars. There is no permanent visible grid; the tile under the cursor, routes and search
  areas show when needed.
- Art style still to be picked from `prototypes/map-style-demos`.

**What a character sees (decided 2026-11-13):**

- **The overview is common knowledge.** Every character sees the whole painting, the famous places, the
  great cities and the sects from the start. The knowledge mask (blank paper until known) applies only in
  the zoomed-in view, where the tiles, sites and secrets are.
- **Political map:** borders of the major sects and kingdoms update live for everyone; small holdings and
  minor seats show as the character last heard them.

Both change Travel & Map rule 14 (a character starts knowing only their birth region and the main roads);
the rewrite is in the list below.

## What this changes (to do, section by section with the user)

- Travel & Map: rule 1 ("one generated world"), Formulas C (land generation), rule 14 (what a character
  knows: the overview is common knowledge, politics live for big powers), and Visual/Audio Requirements
  (the two-view map).
- World Generation & History (#27): keeps random NPCs and their generated backgrounds, which fit
  inside the authored history; sects, territories, special characters and past events become
  authored data.
- Game concept and systems index: the world description and #27's role.
- Other GDDs that mention world creation in passing: a wording check.
- New authoring work: continent layout, secret candidate spots, an origins list with home regions.

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

- Grid data comes from authored index images, not noise: since 2026-11-13 a fine map of about 6 km cells (biome,
  elevation, water) under 540 × 360 tiles of about 25 km (temperature, rainfall, features). Both views are built
  from them.
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

## Terrain-driven qi (decided 2026-11-13)

- A tile's element shares follow the terrain: its biome's profile, its **depth** inside the biome (the heart is purer
  than the edge; depth is measured to the nearest tile whose biome has a different signature, or none), a **blend**
  with its neighbours, and **features** (lava flows, ice fields, rivers, veins and the rest) pushing their element
  outward with a falloff.
- Base shares are scaled back to 100 at the land level; variant qi comes only from features, outside the 100.
- Depth also raises density and danger in biomes with a signature: the deep wild is richer and deadlier.
- Special biomes are mild at their base (volcano Fire 45, Earth 40, Metal 15) and take their peaks from features.
- The twelve features in Travel & Map rule 4 are kept.
- The land match has no ceiling (the ×1.3 is gone); its 0.8 floor stays. The ×1.6 stack cap is removed too, and so is
  the settled match cap for city and sect-ground homes (×1.3); only the per-layer limits and the settled density cap
  (1.8) stay.

## Map scale and mixed tiles (decided 2026-11-13)

- Same world size (about 13,300 × 8,900 km, 76°N to 4°S) on a finer grid: 540 × 360 tiles of about 25 km.
- A tile holds a natural mix of up to three biomes, each at least 10 %, read from a fine map 4 times finer (16 cells a
  tile). The main biome names the tile; a tile is sea when sea covers half of it or more.
- Coast and Lake-and-river-valley are no longer biomes; Lake is (19 biomes). Rivers are lines through tiles.
- Every system reads the mix by share: qi per part, travel cost and hazard share-weighted, encounter biome rolled by
  share. A player who knows a tile's mix may keep to one part. A place, abode or field sits in one part.
- From afar a known tile shows its main biome; crossing or standing on it shows the full mix.
- Rules and generator: `design/research/map-making-rules.md` sections J–L, `tools/design/map/continent_gen.py`.

## What this changes

- **Done 2026-11-13:** Travel & Map rewritten for all of the above (rules 1–5, 14, 15, 26–28, 33; Formulas A, B, C,
  M; Interactions, Dependencies, Edge Cases, Visual/Audio, Game Feel, UI, Acceptance Criteria, Open Questions), plus
  the entity registry and the systems index rows #25, #27 and #37.
- World Generation & History (#27): keeps random NPCs and their generated backgrounds, which fit
  inside the authored history; sects, territories, special characters and past events become
  authored data.
- **Done 2026-11-13:** the game concept's world-generation lines (pitch, feature 6, the session loop, the anti-pillar,
  inspiration, technical challenges, procedural systems, risks, MVP and Alpha scope).
- Other GDDs that mention world creation in passing: a wording check.
- New authoring work: continent layout, secret candidate spots, an origins list with home regions.
- **Done 2026-11-13:** Travel & Map revised for mixed tiles and rescaled to 25 km tiles (rules 1–4, 6–8, 10, 13, 14,
  18, 20, 28; Formulas A, C, D, E, F, K; Edge Cases, Visual, UI, Dependencies; ACs, with new AC-TM-146–150), plus the
  registry's trip_time and teleport_fee and the systems index row #25.

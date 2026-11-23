<!-- PROTOTYPE - NOT FOR PRODUCTION -->
# Province economy prototype

**Hypothesis.** Making the 273 provinces the economy's units (user, 2026-11-23: "simulate the economy a bit better and
more naturally"; "let province be an economic unit") gives prices that follow the land: gradients from producers to
buyers, local shortages that spread and heal, visible trade corridors, while still leaving the player a price gap worth
travelling for (`regional-economy-trade.md` rule 16).

**How to run.**
1. `godot --headless --path . -s res://prototypes/province-economy/dump_places.gd` writes `places_seed7.json`: the real
   world's per-place production by good class (MapProduction's own per-place parts), people by realm, region and market.
2. `python -I prototypes/province-economy/sim.py` re-sums them into provinces (`design/map/continent-11/provinces/`)
   and runs the GDD's formulas B-F and L1 with `assets/data/economy.json`'s parameters, two ways, 24 seasons, a herb
   blight (supply × 0.3) in region 14 in seasons 12-15. Maps and `observations.txt` land in `out/`.
   `ROUNDS` and `CAP` (environment) set variant B's flow reach.

**Variants.**
- **A:** provinces replace regions only. One market price per great sect; each province's local price comes from its own
  balance and access (L1, within ±`loc_band` of the market price). No goods move inside a market (rule 16 as built).
- **B:** every settlement province keeps its own stock and price; goods flow between neighbouring provinces each season
  (F's rule: cheaper to dearer, transport cost by distance, half the gap closed per round, up to 5 links a season, the
  importer's tariff 0.08 where two sects meet).
- Both: wilderness provinces' output goes to the neighbouring settlement provinces by border length (user choice);
  demand per province from its people's baskets and settlement weight (Formula C), calibrated so the world is at rest.

**Status:** concluded for this question (2026-11-23); the design goes into the GDD revision.

## Findings (observations, seed 7)

| | A: market + local price | B: neighbour flow |
|---|---|---|
| Price map | blocks by sect market; sharp jumps at market borders | gradients that follow the land; cheap producer zones, dear isolated valleys |
| Herb price spread, season 11 | 0.40-2.38 | 0.50-2.00 |
| Blight region, herb price | 0.67 → 1.01 → 0.72 | 0.86 → 1.22 → 0.86 |
| Neighbouring regions during the blight | +0.08 | +0.04, a visible halo in the adjacent provinces |
| Price vs distance from the hub (correlation) | -0.14 | -0.52 |
| Gap left between linked provinces (herb1), by travel time | 0.15 (< 1 season), 0.32 (1-2), 0.52 (> 2) | 0.09-0.13 (< 1 season), 0.21 (1-2), 0.24 (> 2) |
| Goods conserved | yes (one pool per market) | yes: flows net to 0 every season |
| Overflow (goods rotting at the source) | n/a | about 25 % of production; drops only slowly with more reach (74k → 55k from 3 to 8 hops): structural surplus far from buyers |

- **B reads as a real economy:** prices change with distance, a blight is a local event with a halo, and the busiest
  links form corridors (see `out/B_s11.png`).
- **Trading still pays in B, differently:** short hops leave little (about 0.1), long hauls, sect borders and shocks
  leave more (0.2-0.3+), so the player's profit comes from distance, danger and timing rather than any neighbour.
- **Structural surplus:** some provinces make far more than their reachable buyers can take. In the design this is a
  lever (storage works, merchants, roads), not a bug.
- **Not measured here:** engine speed for 141 provinces × 8+ classes × several flow rounds a season (to measure in the
  engine).

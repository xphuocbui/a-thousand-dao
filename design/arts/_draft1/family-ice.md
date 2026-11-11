# Ice (Băng) signature arts

Seven authored arts, `design/arts/family-ice.json`, lint: `checked 7 arts, 0 findings`. Ice's identity: it lays stacks
(which raise the foe's art costs, Effects rule 9a), and these arts cash those stacks in as locks, delays, shatters and
brittleness. Every art reads or lays Ice stacks, so any stack source (commons Rime Needle, Rime Brand, Cold Ledger) feeds them.
Behaviour was checked by the lint's engine schema validation only; no fight was run.

| Art | Mechanic shape | Hooks | One-line rule |
|---|---|---|---|
| Cold Toll Seal (Hàn Toán Ấn) | Conditional payoff: stacks above N (cost lock) | ice stacks, foe art costs, art speed, curse duration | Each full 10 Ice stacks on the foe adds a Heavy Breath curse on hit. |
| Shatter Palm (Toái Băng Chưởng) | Build-up then cash-in (consume) | ice stacks, stack duration, crit, free hits | Strikes, then consumes every Ice stack on the foe for a 0.15 cold hit each. |
| Stilled Instant (Đình Thời Ấn) | Delays and Slowed Time | ice stacks, timer delay, slowed time, art cooldown | Lays Slowed Time; each full 10 Ice stacks add 0.5 s to every foe art timer. |
| Shattering Mantle (Toái Băng Giáp) | Shield as a weapon | shield size, shield recovery, free hits, ice stacks | Body shield of 20 %; when broken it bursts for a 2.5 cold hit and 12 Ice stacks. |
| Deep Winter Form (Thâm Đông Thế) | Stance (state) | basic speed, basic attack, ice stacks, resistance | Toggle: 25 % slower, +20 resist, every hit lays 2 Ice stacks. |
| Sleet Volley (Tuyết Vũ Tiễn) | Charges and split hits | charges, art speed, split hits, ice stacks | 3 charges; each firing throws 4 icicles, each landing lays 1 Ice stack. |
| Black Ice Glaze (Huyền Băng Ấn) | Held payload ("your next art") | next art, art speed, heavy arts, exposed duration | Your next art also lays Exposed and 8 Ice stacks (brittle payoff). |

The pairs work against each other on purpose: Shatter Palm spends the stacks Cold Toll Seal needs, and Deep Winter Form
feeds both.

## Library arts replaced

- `frostbound-toll` → Cold Toll Seal (fixed threshold of 20 became scaling per 10, no ceiling in the read).
- `leaking-seal` (drain wards bill more, needs foe water) → folded into the Toll and Glaze ideas; its Leaking Ward curse
  stays available as a Status Catalogue entry for another family.
- `undertow` (waits for a dry foe) → Stilled Instant's timer idea; the dry-foe guard is not carried over.
- `rime-mantle` → Shattering Mantle (thorn stacks dropped for the burst).
- Kept as they are, not repeated: `rime-needle`, `frost-seal`, `rime-brand`, `cold-ledger` (commons).

## Engine gaps met

- **Held payload cannot skip its own firing.** `held` with `until: art_fired` banks on the glaze's firing and spends at the
  end of the same firing (`spend_banked` runs after the art's hits). Black Ice Glaze therefore uses a one-slot counter,
  spent by an Effect listed before the one that sets it. Missing piece: a `held` option `skip_current` (or `until: next_art`).
- **Heavy Breath cap is 2 (status cap)**, so Cold Toll Seal's scaling past 20 Ice stacks has no further effect; the
  limitless part is Ice stacks' own cost rise. A status stack-cap override on an Effect would let a build push it.
- **Stance cannot suppress by tag**: `suppress` lists art ids, so Deep Winter Form cannot say "your non-Ice arts are
  suppressed"; the stance trades speed for resistance instead.
- **Not run in a fight**: `own.state.<id>` as a readable, `consume ... then` with `free_hit`, and `shield_broken` for the
  body shield were taken from the schema text; confirm with a fight before relying on the numbers (c values are first guesses).

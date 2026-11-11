# Blade family: element-less weapon forms (sword, saber, spear, bow)

8 authored arts, 3 standalone and 5 engine, in two suites. Lint: 0 findings; engine payoff of the fully fed step 3.2-4.5x
the lint (Coiling Thrust 4.5, Phantom Sword 4.0, Nocked Arrow 3.7, Triple Draw 3.2, Flying Sword 3.2).
Built on `design/arts/_draft1/family-blade.json` (all 7 draft arts kept in spirit, Nocked Arrow added, engines added).

| Art | Mechanic shape | Power | Hooks | Engine (how to feed it) | One-line rule |
|---|---|---|---|---|---|
| Debt Blade (Huyết Trái Kiếm) | pay with health, conditional payoff (low health) | standalone | low health, health regen, leech, health cost reduction, art speed, crit | none: complete alone | Costs 5 % health; strikes again 0.4 for every 15 % of health missing, no cap. |
| Flurry Stance (Loạn Đao Thế) | stance / form | standalone | basic speed, basic coefficient, gain on hit, crit, evade | feeds Phantom Sword (own.state.flurry) | Toggle: 25 % faster, 10 % harder, linh-lực-returning basic attacks; plain sword and broad saber suppressed. |
| Pinning Arrow (Đinh Tiễn) | delays and Slowed Time | standalone | crit, Slowed Time stacks, curse duration, timer delay, art speed | feeds Coiling Thrust and Nocked Arrow with Slowed Time | Lays Slowed Time, delays the foe's longest timer 0.35 s per stack on the foe. |
| Coiling Thrust (Triền Thương Đột) | build-up then cash-in (counter, consume) | engine | coil count, art speed, extra hits, crit, Slowed Time | 2-step chain. Step 2 (1.6x): 4 Coils OR 3 Slowed Time OR 2 canon arts in one pulse. Step 3 (3.5x, five thrusts, Exposed): 6 Coils AND (4 Slowed Time OR Nocked Arrow within 3 s) | Each canon spear/bow art adds a Coil; spends them for 2.2x then five thrusts of 5.5x. |
| Nocked Arrow (Nhập Huyền Tiễn) | held payloads ("your next art") | engine | crit, banked cap, trigger damage, Slowed Time, coil count | Step 2 (1.8x): 2 Slowed Time OR 3 Coils OR 2 canon arts per pulse. Step 3 Volley (4 arrows, 3x): 4 Coils AND (7 s since last firing OR foe at 35 % health OR 4 Slowed Time) | Hits and crits bank arrows (cap 4) that fly as free hits with your next art. |
| Phantom Sword (Huyễn Ảnh Kiếm) | echoes and repeats | engine | crit, crit multiplier, last art damage, afterimage count, low health | Step 2 (1.3x): 4 Afterimages OR Flurry on OR 3 Bleed on foe. Step 3 (3 cuts, 2.8x, pays 6): 7 Afterimages AND (3 canon arts in one pulse OR you at 40 % health OR Flurry on) | Hits and crits leave Afterimages; at 3 a crit re-fires your last art at 60 %. |
| Flying Sword (Phi Kiếm) | summons (unbounded swords) | engine | companion speed/damage, summon count, duration, afterimage count | Empower (2.8x, +2 swords): 3 Afterimages AND (3 canon arts in one pulse OR 4 Bleed on foe OR 10 s since last firing) | Each firing adds a sword that hits every 1.5 s for 12 s; sword hits leave Afterimages. |
| Triple Draw (Tam Bạt Đao) | charges and bursts | engine | charges, cooldown recovery, art speed, bleed, crit, low health | Empower (1.9x): 2 draws in 4 s AND (2 Bleed on foe OR 3 canon arts in one pulse OR you at 40 % health) | 3 charges; each draw in the last 4 s adds a cut (0.15 coefficient); a fed draw hits 1.9x. |

## Suite 1: Hunter's Reach Canon (`hunters-reach-canon`; Pinning Arrow, Nocked Arrow, Coiling Thrust)
A bow-and-spear scripture of patience. Pinning Arrow stacks Slowed Time (and delays the foe's attacks); Nocked Arrow
banks free hits into the next art and lays more Slowed Time; every canon art adds a Coil, which Coiling Thrust and
Nocked Arrow spend or read. Cross-feeds: Slowed Time and Coils feed both engines; Nocked Arrow loosed within 3 s opens
Coiling Thrust's five-thrust step; two canon arts in one pulse opens the first step of both. Hooks: Slowed Time
stacks, crit, art speed, coil count.

## Suite 2: Afterimage Sword Canon (`afterimage-sword-canon`; Flurry Stance, Phantom Sword, Flying Sword, Triple Draw)
A fast-hands scripture. Flurry Stance makes the basic attack a crit engine (more hits, more crits, more Afterimages);
Phantom Sword and Flying Sword (sword hits) both build Afterimages, which Phantom Sword spends and Flying Sword reads;
Triple Draw lays Bleed that two engines read as an alternate key. Cross-feeds: Afterimages, Bleed, Flurry on, and three
canon arts in one pulse feed three engines; low health is a fifth route for Phantom Sword and Triple Draw.

## Library arts replaced
Draft/library `(gap)` arts only, nothing in part-a to replace: the common arts (Plain Sword Cut, Broad Saber Sweep,
Spear Thrust, Bleeding Slash) are untouched, and Flurry Stance suppresses the first two. The part-a authored Sundering
Cut, Binding Thrust, Iron Nail, Haft Sweep, Chain Sword and Reaping Saber are left as they are (none overlaps these
shapes). Pinning Arrow (draft) was reworked from a flat delay into delay-per-stack; Triple Draw's bleed key and Phantom
Sword's decaying counter are new; Nocked Arrow is new.

## Engine could not express
- **Counter `each_for` with a negative `add` does nothing** (engine.py counter verb only appends timestamps), so a
  pay on a timed counter spends nothing. Coil and Afterimage use `decay_per_pulse` counters instead. The same issue
  affects Whetstone Pass and Shatter-Edge Cleave in family-metal (they pay `add: -3/-5` on the timed `temper`).
- **Reading remaining charges of an art** (`own.charges.<art id>`): Triple Draw would like "all 3 charges in hand" as
  a feed; it uses a 4 s draw counter instead.
- **Held payload `mod`**: a banked `mod` (e.g. +40 % damage on the next art) is excluded when spent, so Nocked Arrow
  banks free hits rather than a damage multiplier.
- **Tag filter on `art_fired`** is assumed to match any tag of the fired art (used for `reach`).
- **Step-conditional echo**: a step cannot add an effect (Phantom Sword's step 3 cannot fire the last art again);
  it is three cuts instead.
- **Stance suppress by tag**: `suppress` lists art ids, so Flurry Stance names the two common arts it suppresses.

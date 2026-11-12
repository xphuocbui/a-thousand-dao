# Build round engine-v3: items as tests

> 2026-11-12. 38 headless Sonnet sessions (`_logs/`), jobs from `make_gear_jobs.py` and `make_unique_jobs.py`.
> Observations, not verdicts. The engine is `tools/design/combat_sim/fight.py`, which reads `"items"` since this round.

## What was run

- **Gearing (29 builds).** Every engine-v2 build with a fight file got a full loadout from the named-item catalogue
  (`design/items/`): the five base slots, extras by realm within thần thức (45 × divine sense), the grade cap of its
  realm. Each was fought before and after (`--matrix`), and without its key item. Guides: `<build>.md`.
- **Unique builds (9).** One new build around each unique item no geared build picked up. Guides: `unique-*.md`.

Every guide has a loadout, before/after or fight tables, `--without` tests, an **Upgrades to look for** table and its
**Missing pieces**.

## Results

**Gear is a modest boost, and nothing broke.** At its own realm, every geared build still wins 20-0 against the typical
enemy. The middle build's fight got about 15 % shorter. The biggest gains were Starter Blade (17.3 to 7.7 s), Ninth
Bell (8.7 to 4.5 s) and Loaded Dice (16.1 to 10.8 s); Pacifist and several Nascent Soul builds did not move. No guide
called an item degenerate.

| Build | Realm | Same realm, before | After |
|---|---|---|---|
| starter-blade | Trúc Cơ | 17.3 s | 7.7 s |
| ninth-bell | Kết Đan | 8.7 s | 4.5 s |
| loaded-dice | Kết Đan | 16.1 s | 10.8 s |
| starter-venom | Trúc Cơ | 36.8 s | 27.0 s |
| starter-tide | Trúc Cơ | 37.0 s | 29.4 s |
| starter-wall | Trúc Cơ | 37.1 s | 30.8 s |
| two-clocks | Nguyên Anh | 34.6 s | 29.8 s |
| soul-lance | Nguyên Anh | 26.7 s | 22.0 s |
| sect-ladder | Trúc Cơ | 24.1 s | 20.4 s |
| bare-fist, triple-convert, one-art, dry-well, burial-shroud | various | 7.5–15.3 s | 6.8–13.5 s |
| armoury-mind, art-thief, beast-carry, cooldown-floor, curse-engine, deity-warden, evade-dancer, first-volley, giant-killer, mirror-hide | Kết Đan and up | 1.2–5.0 s | 1.0–5.0 s |
| pacifist | Kết Đan | 64.0 s | 66.0 s |

**The unique items' Effects mostly measure small or zero in the sim.** Removing a unique's Effect changed the
same-realm fight by 0–3 s. The reasons are in the guides: some fire rarely (Bought Fate, once a fight); some matter only
in harder fights (Water Table moved the one-realm-up fight of The Moon in the Well); some run on stats the engine does not
model (Unmaking Glass has no foe buffs to strip, Verdict Stands needs a "never expires" action).

**Usage.** 88 of the 130 items were picked by at least one build; 17 of the 26 uniques by geared builds and the other 9
by their own builds. The metal family was picked most (the Whetstone Jade Pendant by 7 builds).

## Read these numbers with care

1. **The typical enemy above Qi Refining is too weak.** Before any gear, most Kết Đan and Nascent Soul builds already
   killed the typical same-realm enemy in 1–9 s, far under the 30–60 s band. This is the known fitting problem of the
   enemies above Qi Refining (Combat Formulas B), not an item problem, and it hides how much gear matters.
2. **The engine does not run many item stats**: maximum health and linh lực (`khi_huyet_pct`, `linh_luc_pct`), stack
   strength and duration (`stack_effect_pct`, `stack_duration_pct`), body shield share, ward strength, item wards other
   than drain wards, reserve arts (neither the reservation nor the grants), escape. Many builds said "gear did not matter
   in this engine"; that understates items.
3. **Item modifiers stack on layers that already assume typical gear.** The engine-v2 builds were tuned with a typical
   gear layer (L3) and a typical increased-damage total in L1; adding named items on top double-counts part of it, which
   overstates items. Points 2 and 3 pull in opposite directions.

## Missing pieces (147 lines, grouped)

The full list is in each guide's **Missing pieces** section. The themes, most asked first:

| Theme | Asked by | Owner |
|---|---|---|
| **Engine stats and actions**: `stack_effect_pct`, `stack_duration_pct`, `body_shield_pct`, `khi_huyet_pct`, `linh_luc_pct`, non-drain wards (cast, per hit, shield), "never expires", escape, a report of step unlocks | about 15 builds | combat engine (`engine.py`, `fight.py`) |
| **Armour with a standing drain ward** (most item wards are cast or per-hit wards, which the engine cannot run, and some families have no body armour, such as water) | metal, fire, water, thunder, wood, body, earth builds | each element family |
| **Rings above grade 1** in thunder, wind and fire (non-health) | first-volley, loaded-dice, cooldown-floor, sect-ladder, ninth-tribulation | thunder, wind, fire |
| **Cheap extras and thần thức**: utility pieces under about 10 TT, and items with `than_thuc_pct` so more extras fit | bare-fist, cooldown-floor, dry-well, evade-dancer, deity-warden, two-clocks, starter-venom | general, each family |
| **Lost identity pieces** of the old builds as items: Embers Feed the Hearth (fire, 2 builds), a crit meter (Loaded Table), Return from block, a realm-gap ring, a cleanse on a clock, a companion collar | many | the families named in each guide |
| **New bases**: a bow or spear | meta-hunter | bases |
| **A Darkness (Ám) family or tag** for the locket's `[am]` scope | unique-chaos-last-bargain-locket | arts and techniques |
| **A Chaos main method** (the Chaos techniques are all secrets) | unique-chaos-last-bargain-locket, unique-chaos-primordial-mirror | technique catalogue |
| **Enemies that self-buff**, so Unmaking Glass has a target | unique-chaos-primordial-mirror | enemy design |

## Suggested next steps

1. **Engine stats for items**: give the engine the stats above that most item lines use (stack effect and duration,
   maximum health and linh lực, body shield), reservation, and one more ward model (cast). Then rerun this round.
2. **Refit the typical enemy above Qi Refining** (Combat Formulas B), so fights land in 30–60 s and gear differences show.
3. **A gear baseline**: define the typical gear's share of L1 and L3, so named items replace it in a build instead of
   adding on top.
4. **A catalogue patch** from the themes: drain-ward armour per family, rings above grade 1 for thunder, wind and fire,
   cheap extras and thần thức pieces, and the lost identity pieces.

## Addendum 2026-11-13: the engine runs item stats

`engine.py` and `fight.py` now run the stats most item lines use: maximum health and linh lực, body shield, ward strength
and efficiency, thần thức, stack effect and duration (by element and buff or debuff), and reservation (reserve arts hold
their share of linh lực and run their grants). Tests: `test_engine.py` (5 new, 0 failed); regression and self-test
unchanged. Cast and other non-drain wards are still not run.

Refought on the new engine, each build without gear (engine-v2) against with gear (engine-v3), at its own realm:

| Build | Typical: no gear → gear | Top-end: no gear → gear |
|---|---|---|
| starter-blade | 17.1 s, 71 % health → 7.2 s, 96 % | loses → loses |
| soul-lance | 26.7 s, 40 % → 12.0 s, 75 % | **loses → wins 20-0** (49 % health) |
| ninth-bell | 8.7 s, 59 % → 4.3 s, 90 % | loses → loses |
| loaded-dice | 16.1 s, 74 % → 10.8 s, 87 % | loses → loses |
| sect-ladder | 23.8 s, 56 % → 20.4 s, 76 % | loses → loses |
| starter-venom, starter-flame, starter-tide, two-clocks, starter-wall | 35.7–27.6 s → 30.6–20.6 s | loses → loses |
| evade-dancer | 2.0 s → 1.8 s | wins 15.6 s → wins 9.9 s |
| curse-engine | 2.5 s → 2.5 s | **wins 20-0 → 12-8** |
| pacifist | 64.0 s, 84 % → 66.0 s, 61 % | loses → loses |
| the other 16 | 0–3.3 s faster (unkillable 18.9 → 15.6 s, bare-fist 12.0 → 9.6 s, triple-convert 15.3 → 13.1 s) | same results |

- **Gear now helps every build with room to improve** against the typical enemy; against the top-end enemy (every
  layer at cap) almost every build still dies in about 2 s with or without gear.
- **Soul Lance gains the most**: its thần thức and pool items now count, and it beats the top-end enemy.
- **Reservation has a real cost.** Curse Engine's 10 % reserve pendant (Ledger Murmur) costs it 8 of 20 top-end fights:
  without that one item it wins 20-0 again. Pacifist also lost health. A build that runs close to dry should not wear a
  reserve art; the guides' loadouts were chosen before reservation was run.

## Correction 2026-11-13: the typical enemy is not too weak

"Read these numbers with care" points 1 and 3 were wrong. Measured on the current engine, the **typical mirror** (typical
against typical) lasts 35.4 / 38.0 / 44.5 / 53.2 / 61.4 s from Qi Refining to Deity Transformation: inside the 30–60 s band,
Deity Transformation a second over. The note that the fitted enemies run short (25.6 s at Trúc Cơ, 20.0 s at Kết Đan)
came from `design/arts/README.md` and predates later engine changes. So the 1–9 s same-realm fights mean these builds
are far stronger than a typical cultivator, close to the top-end enemy (which beats typical in 2 s by design, a
regression anchor). No refit of Combat Formulas B is proposed.

The double counting of point 3 is small: rolled gear gives no increased damage, so named items' damage lines do not
overlap the builds' layers; only the gear layer L3 is shared, and both use it the same way. See GEAR-BASELINE.md.

## Addendum 2026-11-13: wards

The sim now runs extra wards beside the main drain ward: drain, per-hit, reserved and cast wards, shield and block
payloads, in the free ward slots (1 / 1 / 2 / 3 / 4 by realm, plus up to 2 from thần thức) and then the free art slots.
Item wards load automatically. Across the 38 builds, 42 item wards found a slot and 21 did not, most at Trúc Cơ and Kết
Đan, where the main ward takes the only slot. Results moved a little both ways: Dry Well survives the top-end enemy twice
as long (18.8 to 39.2 s); Evade Dancer's cast wards cost linh lực it needed, and it drops from 20 to 12 top-end wins.

**Armour brings its own ward slot** (user decision 2026-11-13, Combat Defence & Healing rule 5, AC-CD-14b): each worn armour
adds a ward slot that holds only its own ward. With it, 58 item wards find a slot across the 38 builds (42 before) and
only 5 do not, all ward gear (bells, shields) competing for the realm's ordinary slots.

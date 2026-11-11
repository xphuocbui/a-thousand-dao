# Wood (Mộc) signature arts

8 authored arts: 3 standalone, 5 engine, in two suites. `python -I tools/design/arts/lint_arts.py design/arts/family-wood.json`: 0 findings;
engine_payoff of the fully fed forms is x3.0-x3.5 of the lint (second-spring step 2 and thornling-grove step 2 x3.0; step 1 of each x1.3-1.5).
Commons (rot-seed, slow-rot, vine-lash, spring-sap, weeping-sap, venom-tithe) are unchanged and not repeated. Built on `_draft1`: kept Thorn Rain,
Bloodroot Pact, Rooted Form as standalones, turned the other five into engines.

| Art | Power | Mechanic shape | Hooks | Engine (how to feed it) | One-line rule |
|---|---|---|---|---|---|
| Seed of Spring (Xuân Chủng) | engine | Held payload ("your next art") | wood buff stacks, art speed, wood arts fired, healing, banked-seed cap | 4 Seeds (every Wood art you land plants one) AND 8 own Wood stacks (3.5x), OR eat 8 Poison on the foe (2.5x, a Chaos hit per 4 eaten) | Each landing banks a Seed; your next art of any kind sprouts them all; fully fed it hits 3.5x. |
| Harvest Bloom (Thu Hoạch Khai Hoa) | engine | Build-up then cash-in (consume) | poison stacks, wood buff stacks, seeds, free hits, chaos damage, crit | 12 foe Poison (eaten), OR 4 Seeds, OR 10 own Wood stacks (eaten) | Heavy hit; harvests Poison or Seeds or your own stacks into Chaos blooms and heals, 4x. |
| Second Spring (Tái Xuân) | engine | Echo / repeat; healing as a weapon | healing, heal arts, echo, last art damage, low health | Step 1: 6 Wood stacks OR 2 Seeds OR Rooted Form. Step 2: 3 Springs OR 40 % health | Every 3rd heal re-fires your last art; stepped up it strikes and re-fires it in full. |
| Rooted Form (Cắm Rễ Thế) | standalone | Stance / form | health regeneration, healing, wood buff stacks, damage taken, seeds | (feeds Seed, Harvest and Second Spring) | Sturdier and healing more but 20 % slower; poisons the foe and plants a Seed each pulse. |
| Thornling Grove (Thích Linh Lâm) | engine | Summon (stepped) | summons, companion speed, poison stacks, cooldown cut | Step 1: 10 foe Poison OR 2 canopy arts in a pulse OR 14 s since last grove. Step 2: 15 foe Poison AND (3 Stagnation OR 3 canopy arts) | Raises a Chaos Thornling; stepped it raises up to several more and hits 6x. |
| Blight Canker (Hủ Căn) | engine | Curse pattern | poison ticks, stagnation, curse duration, tick damage | 6 Stagnation AND 6 Poison on the foe, OR eat 15 Poison, OR 3 canopy arts in a pulse | Chaos ticks on a stagnated foe spread Stagnation, then Withering; fed it hits 4x and deepens the curse. |
| Thorn Rain (Thích Vũ) | standalone | Split hits | crit, split hits, poison stacks, accuracy, art speed | (feeds Thornling and Canker as a canopy art) | 6 thorns, each lays 1 Poison and a crit thorn lays another. |
| Bloodroot Pact (Huyết Căn Khế) | standalone | Paying with health | health cost, poison stacks, healing, leech, low health | (feeds Thornling and Canker as a canopy art) | Costs 6 % health; Chaos ticks heal in proportion to foe Poison; at 15 Poison the pact repays the blood. |

## Suite: Verdant Cycle Scripture (`verdant-cycle-scripture`)
Seed of Spring, Harvest Bloom, Second Spring, Rooted Form. The shared currency is the **Seed** counter: every Wood art you land plants one
(Seed of Spring's own effect), Rooted Form plants one a pulse. Seeds are spent by Seed of Spring, Harvest Bloom (4 each) and unlock Second Spring's
step 1 (2 Seeds). Wood buff stacks and Rooted Form are the second currency every engine reads. A build runs Rooted Form for Seeds and sustain, Seed
of Spring to bank stacks, Harvest Bloom to cash them in, Second Spring to turn the heals into echoes.

## Suite: Rotting Canopy Canon (`rotting-canopy-canon`)
Thornling Grove, Blight Canker, Thorn Rain, Bloodroot Pact. Pressure on the foe's Poison pile and Stagnation. Thorn Rain and Bloodroot Pact lay the Poison;
Thornling Grove and Blight Canker eat it or the curse for their full forms; any three of the four fired in one pulse unlock both engines' alternative route.
Thorn Rain is suppressed by Rooted Form, so the two suites are a choice, or a stance-swap build.

## Library arts replaced
- `venom-drinking-root` -> Bloodroot Pact. `withering-touch` -> Blight Canker. `banyan-shade` -> Second Spring. `heartwood-spear` -> Harvest Bloom.
- Kept as they are (not touched): `shedding-bark`, `bark-mantle`, `green-poultice`.

## What the engine could not express
- **A true "next art" hold.** Seed of Spring uses `held` with `until: art_fired`; whether the banking art's own firing spends it is unverified. Missing: a "not this art" filter on `held`.
- **Exclusive empower routes.** Every empower whose `if` holds applies, so alternative routes are made exclusive by hand (negated earlier conditions). A `first_match` flag would be cleaner.
- **Poison granted by Effects, summons and free hits are not charged by the lint** (only `buff`/`debuff` fields are), so Thornling Grove, Thorn Rain and Rooted Form are priced by hand.
- **Summon cap and scaling.** `summon` takes a fixed `c`; more Thornlings accumulate with no cap and cannot be made stronger by a readable.
- **Mods tagged `poison`.** No way to say "Poison ticks deal more" as a mod on tick damage; a `dmg_more` scoped to a status tick is missing. Bloodroot Pact's "hungrier at low health" was dropped for this reason.
- **Cleanse-resistance on Stagnation** (rule 16, R27) is not wired; a foe cleanse removes Blight Canker's pattern.
- **Heal-art damage.** A heal art with `c_art` 0 in steps shows engine_payoff only on its damage override; its `c_heal` jump (2.5 -> 9) is not measured by the lint.

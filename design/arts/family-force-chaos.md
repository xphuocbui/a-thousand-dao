# Family: element-less Force (Chấn) and Chaos (Hỗn Độn)

8 signature arts in `family-force-chaos.json`: 3 standalone, 5 engine, two suites. Lint: 0 findings (13 gated
`engine_payoff` lines, full payoffs 3.3-4.7 times the lint). Numbers tuned twice with suite_check (see `tune-force-chaos.md`, `tune2-force-chaos.md`); suites now x0.61-0.71, Bloodletting Rite x0.79-0.92, Shearing Palm about even. Table numbers below are from the first draft: Bloodletting now 1 % more per 10 % missing and 2 % leech; Shearing's crit tear is 1.8 chaos; payoffs in the Ruin Ledger and Hollow Tide arts were cut roughly 20-30 %.

| Art | Mechanic shape | Hooks | One-line rule | Engine (how to feed it) |
|---|---|---|---|---|
| Marrow-Siphon Palm (Tủy Hấp Chưởng) *(engine, hollow-tide)* | Second pool + multi-step | qi burn, Force damage, tick damage, Qi Disruption stacks, drink count | 2 Disruption; half of what your burn removes returns to you; steps to a Gulping Palm (2x) then a Draining Gulp (5x, +8 % linh lực) | Step 2: another scripture art this pulse, OR foe at 3 Disruption, OR Husk stance. Step 3: spend 8 Drink (built by any burn tick), OR foe below 35 % linh lực |
| Hollowing Strike (Khoét Rỗng Kích) *(engine, hollow-tide)* | Conditional payoff: foe dry | foe dry linh lực, drink count, Disruption stacks, stance | Heavy fist; 5x and +10 % linh lực back on a foe below 25 % linh lực | Top (3.5x, +10 % linh lực): foe below 40 % linh lực AND spend 3 Drink. Lower (2.2x, free): foe wearing any Disruption |
| Hollow Husk Stance (Không Xác Thế) *(standalone, hollow-tide)* | Stance (state) | basic attack, basic speed, Disruption stacks, art cost | Toggle: basic +0.8 coefficient, 30 % faster, lays 1 Disruption per hit; arts cost 35 % more | Complete alone; feeds Siphon and Hollowing as a condition |
| Fraying Thread (Tơ Rã) *(engine, ruin-ledger)* | Build-up then cash-in (counter, no cap) | status application, stacks, Fray count, distinct statuses | Sundered + every status you land adds a Fray; 4x tear at 6 Fray | 6 Fray (spent, 3x), OR foe wearing 3 different statuses (1.8x), OR 3 Fray spent + another scripture art this pulse (3.5x) |
| Gathered Ruin Verdict (Tụ Phế Phán) *(engine, ruin-ledger)* | Held payload ("your next art") | status application, held damage more, Fray, distinct statuses | Each status you land banks 12 % more (5 max) for your next art; Exposed | 4 Fray spent (4x), OR 4 different statuses on foe (3.5x), OR Ripening Curse fired within 4 s (3.5x) |
| Ripening Curse (Thục Chú) *(engine, ruin-ledger)* | Curse pattern + multi-step | distinct statuses, Stagnation stacks, curse slots, damage more | Stagnation; 6 % more per distinct status; ripens to Budding (1.8x) then Blooming (4x) | Step 2: 2 Stagnation OR Fraying Thread within 4 s. Step 3: 5 Stagnation, OR 4 different statuses, OR 5 Fray |
| Bloodletting Rite (Phóng Huyết Nghi) *(standalone)* | Paying with health | low health, leech health, healing, health cost | Pays 4 % health; 6 % more per 10 % missing health; 6 s of 20 % leech | Complete alone |
| Shearing Palm (Cắt Xé Chưởng) *(standalone)* | Conversion | Force and Chaos damage, shield bypass, crit | Half becomes Chaos (passes shields); a crit tears again for 0.4 chaos | Complete alone |

## Suite: Hollow Tide Scripture (hollow-tide-scripture, Không Triều Kinh)

Drain suite. Burn ticks of Qi Disruption build **Drink** (counter, 10 s each), returned linh lực funds the casting.
Siphon Palm lays the burn and chains to its Draining Gulp; Hollowing Strike finishes a dry foe; the Husk stance makes
every basic hit a Disruption source and counts as a feed for both (but taxes art cost 35 %, a real tradeoff). Any two
arts of the scripture in one pulse unlock Siphon's step 2; Drink is shared, so the two arts compete for it.

## Suite: Ruin Ledger Scripture (ruin-ledger-scripture, Phế Trướng Kinh)

Curse suite. **Fray** (counter, 12 s each) rises with every status or stack batch you land, from any art or element.
Fraying Thread and the Verdict spend it; Ripening Curse reads it and Stagnation; the Verdict reads Ripening's timer
(`own.since`); Ripening reads Thread's. Foe distinct statuses (4) is a no-payment route for all three, so stack-heavy
elemental builds can run the suite with no Fray at all.

## Library arts it replaces or builds on

- Replaces as signatures: Shearing Palm and Hollowing Strike over `force-wave`, Marrow-Siphon Palm over
  `qi-shaking-palm`, Ripening Curse over `unravelling-seal`/`exposing-thread`, Fraying Thread over `exposing-thread`,
  the Verdict over `unravelling-seal`. The commons stay as they are.
- Not repeated: the single-status applicators (Stagnation, Heavy Breath, Silence, Sealed Meridian, Slowed Time), soul
  arts, escape, cleanse, healing arts.

## What the engine could not express

- **Held payload next-only.** `held` banked by `status_applied` during this art's own hit is spent by that same firing
  (`spend_banked` runs after the hit). Missing: a `held` option `next_only` (skip the firing in progress).
- **Partial spends of Drink and Fray** use `counter add -N`. If the counter holds fewer, the engine clamps; the art
  tests `>=` first, but a chained step whose unlock reads another route (qi_share) pays 8 Drink it may not have.
  Missing: a `pay` that is conditional per route inside one step (steps have one `pay`).
- **Alternative routes in a step** share the single `pay`; Siphon step 3 therefore takes Drink even when the foe-dry
  route unlocked it. Hollowing and Fraying avoid this with exclusive `empower` entries.
- **`status_applied` carries no tags**, so Fray and the Verdict also count element stack batches (intended for the
  cross-element role, but curse-only variants cannot be written).
- **Stance cost raise** relies on negative `cost_red`; not run to confirm the sign.
- **`hp_cost` is unpriced** by the lint (Bloodletting Rite c_art was cut 2.7 -> 2.5 to leave room).
- **Dry foe** is read as `foe.qi_share`; whether burn ticks that overdraw clamp at 0 needs a regress run.
- No sim run was made, only the schema lint.

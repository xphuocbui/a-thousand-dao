# The Long Drought (Trường Hạn)

> **Status**: Overnight concept, 2026-11-07. Not in game data. Direction chosen by an agent, not the user. Numbers on new content are first guesses.
> **Seed**: Critic order 2: Curse crossed with Poison's Breath, to break a per-pulse ward by starving what pays it.
> **Direction**: Into the Breath's burn empties the pool. Standing Word shuts the income. Neither alone can drain a ward whose regeneration beats its upkeep.
> **Realm span**: Foundation Establishment – Core Formation, defined at Foundation · **Power level**: ordinary · **Use**: player path, or a sect's ward-breaker
> **Fit**: 3 Fits today · 15 Needs key · 0 Needs rule · 0 new pieces
> **Checks**: 8 PASS · 0 FAIL · 1 NOT ASSESSED (Budgets: nothing prices a curse)

## The Spine

- **The channel:** a qi burn on the enemy's pool, a poison tick, and then hits and the fist on a body with no ward.
- **The enabler:** none. Four existing arts in four slots.
- **The loop:** one word every 3.8 s keeps their regeneration shut. Two thin doses a cycle take the pool. Whatever pays their ward runs out, and it does not come back.
- **The engine:** Wasting. Every point the burn takes is +0.2 on every hit that follows, and the fist is the biggest single channel in this build.
- **The sacrifice:** the Wall, and any fight one realm up. There is no crit, and the pool is spent on the plan.
- **The arc:** at Foundation it wins by a hand. At Core the same four arts win the same fights with far more health left.

## The Legend

Elder Cát Hạn believes they cause the weather. Every dry year in the province for sixty years, they have taken the credit, cheerfully and in writing, and they send the prefect a bill. No one has ever shown that Cát Hạn has moved a single cloud. No one has managed to tell them, either.

What they do have is one sentence and a two-column herbal, and a delighted way of saying the sentence. Warded masters who pay their wards from a deep spring have come to explain the difference between a duel and a drought. Cát Hạn wins, thanks them, and adds the fight to the bill.

## How It Fights

Nothing happens for a second. Then doses, and at t = 3.8 the word. From there the enemy's numbers only fall. Against a ward that pays 4.7 % a pulse from 8 % income, a ward no ordinary drain can touch, the pool goes 73 % at t = 4, 21 % at t = 8, 4 % at t = 10 (`variants/long-drought-spring.fight.json --timeline`).

**The signature moment:** at t = 10 the ward cannot pay. Their strength rating has not changed, and it no longer matters. They fall a second later with 14 % of your health still standing.

## The Stack

30 nodes on The Second Sickness's base character. Every row is reused. Bare Vessel is left out, and nothing here misses it.

| # | Row | Take | Total | Form | Layer | Status | From |
|---|---|---|---|---|---|---|---|
| 1 | Burn damage (Thiêu Khí) | 3 + 1 | +22.5 | Increased | L1 | ○ reused | Breath |
| 2 | Poison damage (Độc Thương) | 3 + 1 | +22.5 | Increased | L1 | ○ reused | Common road |
| 3 | Damage over time (Trì Thương) | 2 + 1 | +16 | Increased | L1 | ○ reused | Common road |
| 4 | Status chance (Trúng Suất) | 3 + 1 | +9 | Increased | none | ○ reused | Common road |
| 5 | Long Simmer (Cửu Tiên) | notable | +10 | More | L2 | ○ reused | Common road |
| 6 | Basic attack damage (Bình Kích) | 2 + 1 | +16 | Increased | L1 | ○ reused | Breath |
| 7 | **Wasting (Hao Tổn)** | notable | up to +20 | Per | L2 | ○ reused | Breath |
| 8 | Damage to an enemy with no linh lực (Khô Hải) | 1 + 1 | +17.5 | Conditional | L1 | ○ reused | Breath |
| 9 | Unbroken Sentence (Bất Đoạn) | notable | +10 | Conditional | L5 | ○ reused | Curse |
| 10 | Slow to Lift (Nan Giải) | notable | +15 % curse duration | Increased | none | ○ reused | Curse |
| 11 | Lingering Word (Dư Ngôn) | 1 + 0 | +2.5 % | Increased | none | ○ reused | Curse |
| 12 | Health, Regeneration, Ward strength | 2, 2, 1 | | Increased | none | ● | Breath's survival nodes |

**Two nodes do the most.** Rows 10 and 11 make +17.5 %, and 3.525 pulses rounds to 4. With 3 pulses Standing Word's curse lapses before its next cast, and the build loses the Evader and the spring (`curse-3-evader`, `curse-3-spring`). This is the rounding ruling the critic asked for, and here it decides a fight.

**Dropped because adding them moves nothing:** Thinning Ward and Full Weight (`with-thinning-evader`, `with-strength-evader`: the same 12 s on 15 %). Curse strength does not matter here: the block on regeneration does.

**Identity piece:** Standing Word. `--without standing_word` on `long-drought-spring` loses at 12 s, enemy on 9 %, pool 48 %. On the Evader, it loses at 14 s, enemy on 22 %.
**Empty rungs:** crit and L4, sacrifices.

| Layer | Points | Multiplier | Sources |
|---|---|---|---|
| L1 | Thirst and Poison 38.5, hits 10 to 27.5 | ×1.39, ×1.10 to ×1.28 | General 10, rows 1 to 3, row 8 |
| L2 | Statuses 31, hits up to 20 | ×1.31, up to ×1.20 | Row 5, Held Acres 21, row 7 |
| L3 | 20 | ×1.20 | A cheap weapon. The money is in the ward |
| L5 | up to 10 | ×1.10 | Row 9, on arts |

## Foundation and Arts

Wood and Earth, any purity, as The Second Sickness: its pools, its ward (pass 0.42 and 0.28, `ws` 126.2, `we` 150), its garden. Plain Speech Method as main, Two-Column Materia as the secret technique. Four of 4 slots, so nothing can be added.

| Art | Source | Kind | c_art | Cost | Cooldown | Does |
|---|---|---|---|---|---|---|
| Thin Dose (Bạc Tễ) | Materia | qi | 0.8 | 0.04 | 1.9 s | Poison, 59 % a stack |
| Wasting Thirst (Tiêu Khát) | Materia | qi | 0.8 | 0.04 | 1.9 s | Thirst: qi burn, 59 % a stack |
| Standing Word (Trụ Ngôn) | Plain Speech | qi | 2.0 | 0.08 | 3.8 s | Curse, 4 pulses: cost +34 %, drain +34 %, regeneration blocked |
| Level Gaze (Bình Thị) | Plain Speech | qi | 1.9 | 0.04 | 3 s | A hit |

## Matchups

The standard panel plus **Spring**: a same-realm enemy with one cheap art, a Stone Ward at 0.10, `we` 112.1 and regeneration at the 8 % cap, so income beats upkeep. Each cell: result, time, own health. Files are `variants/long-drought-[name].fight.json`.

| | Mixed | Pulse | Wall | Evader | Fast | Spring |
|---|---|---|---|---|---|---|
| **The Long Drought** (`mixed` … `spring`) | W 7.6 s, 48 % | W 8 s, 45 % | L 81 % | W 12 s, 15 % | W 8 s, 23 % | **W 11 s, 14 %** |
| Into the Breath (`breath-*`) | W 11.4 s, 22 % | W 10 s, 34 % | L 73 % | L 29 % | W 9 s, 7 % | L 9 %, pool 42 % |
| The One Long Word, its own ward (`word-*`) | W 7 s, 10 % | L 32 % | L 89 % | L 53 % | L 83 % | L 35 %, pool 28 % |
| The One Long Word on Breath's ward (`word-kit-*`) | W 7 s, 53 % | W 8 s, 42 % | L 85 % | **W 9 s, 26 %** | **W 6 s, 32 %** | L, both down at 12 s, pool 3 % |
| **At Core** (`core-*`, `core-spring`) | W 8 s, 61 % | W 9.5 s, 59 % | L 82 % | W 13 s, 42 % | W 7 s, 33 % | W 11 s, 38 % |
| Into the Blood at Core (`core-blood-*`) | W 13 s, 29 % | W 11 s, 42 % | L 52 % | L 18 % | W 12 s, 21 % | |

**It loses to the Wall, by a long way, at both realms.** A doubled pool at ward 200 outlasts the burn.

**What the parents cannot do.** At the end of their spring fights the enemy still holds 42 % (Breath) and 28 % (the Word). Together, 0 to 1 %. Spring is the only fight that needs both halves, and the only win neither parent has.

**Do not overread the Evader.** It beats both published parents, but the fourth line is plain: The One Long Word on the same ward wins the Evader and Fast faster than this build does. Those wins came from the ward kit, not the crossing. Spring is also narrow: the Word on Breath's ward goes down in the same instant as the enemy.

**Which half did it?**

| Removed | Evader | Spring |
|---|---|---|
| Nothing | W 12 s, 15 % | W 11 s, 14 % |
| Block on regeneration (`no-block-*`) | L 11 % | L 21 %, pool 49 % |
| Curse at 3 pulses (`curse-3-*`) | L 12 % | L 17 % |
| Wasting (`no-wasting-*`) | L 13 % | W 12 s, 9 %. Also L 7 % on Fast (`no-wasting-fast`) |
| Wasting Thirst (`no-thirst-*`) | W 12 s, 12 % | L, both down at 12 s |
| Thin Dose (`no-dose-*`) | L 6 % | W 12 s, 25 %. Spring alone is better without it, and the Evader is lost |

**Counter:** the Wall (81 %), or any pool that outlasts the plan: a pool of `n_qi` 3.0 loses at 10 s, enemy on 25 % (`deep`). Cleansing does not help them: a cleanser who clears statuses and curses every 4 s spends its own pool and dies at 8 s (`cleanser`), which surprised me. One realm up is a loss at t = 4 (`sheets/long-drought.fight.json --matrix`).

## Checks

| Check | Result | Detail |
|---|---|---|
| Budgets | NOT ASSESSED | Nothing prices a curse. Arts inside the lint, 4 of 4 slots |
| Validity | PASS | Plain Speech reaches Core (`max_realm` `ket_dan`). Curse duration 4 is under `curse_duration_max` 5 |
| Stack | PASS | Increased, More, Conditional, Per. L4 empty and said so |
| Scaling | PASS | An ordinary build by design |
| The fight | PASS | 4 of 5 on the panel at both realms. The Wall is a stated loss |
| Reuse | PASS | 0 new pieces |
| NPC use | PASS | Every row is already in the ledger as a plain row |
| Counterplay | PASS | Wall, deep pool |
| Originality | PASS | No borrowed names |

**Unmodelled:** Plain Speech's +10 L2, +20 % pool and +15 % health are left out, because the pools are The Second Sickness's. If anything the fight is understated. Curses land at 100 %.

## New Content Needed

Nothing new. Every art and row is in the ledger already.

## Questions

1. A curse is either standing or not, and rounding decides which. Should +17.5 % really buy a whole pulse?
2. Rule 7 says statuses have a stacking rule. Should a curse recast refresh or stack? Here the curse lapses for 0.6 s between casts, and regeneration stays blocked only because no pulse falls in that gap.

## Also Considered

- **Closed Gate for Standing Word:** cheaper and longer, but it has no hit. Mixed slows to 9 s on 29 %, and the Evader and Spring are lost (`alt-gate-*`: L 16 %, L 22 %).
- **Stone Ward on this build:** it keeps Spring (11 s on 7 %) and speeds the Evader (9.5 s on 19 %), and loses health everywhere else (`alt-stone-*`). A hunter wearing what it hunts is a nice joke, not a better build.

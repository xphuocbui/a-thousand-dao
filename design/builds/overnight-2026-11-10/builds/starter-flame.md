# The Hearth Keeper (Thủ Lô Hỏa Giả)

A Fire caster that sets the enemy burning with cheap arts, and lets the Burn pay your linh lực back. A first build: one idea, forgiving, strong enough by Kết Đan (Core Formation).

## Why it works

- **Burn does the work.** Your arts put Burn stacks on the enemy. Each stack burns every second (0.019 of a hit per stack per pulse), has no cap, ignores evade and block, and never needs a crit. Spark Palm adds 1 stack, Kindling Seal 2, Flame Lance 3.
- **The fire feeds you.** The keystone Embers Feed the Hearth (Tàn Hỏa Dưỡng Lô) returns 25 % of every Burn tick as linh lực. Linh lực is both your mana and your ward, so running dry is the first way a caster loses; this build mostly cannot. In the simulator, without this sustain the same build wins 4 fights of 20 instead of 20.
- **Cheap arts.** Costs are 2 %, 4 % and 6 % of your maximum linh lực. Regeneration is 3.5 % of the pool each second, plus your bonuses.
- **All five damage layers are used.** L1 50, L2 40, L3 30, L4 20 and L5 15 points by Kết Đan. Spreading wins: five modest layers beat one big one.
- **What you give up:** crit (Burn never crits), pierce, and your direct Fire hits deal 15 % less. A first build should have few decisions; these are the ones you do not need yet.

In the combat simulator (not the game), at Kết Đan against a typical same-realm cultivator it won 20 of 20 in about 22 seconds with the linh lực bar never running dry and 55 % of health left. That is a little strong and a little short for a typical fight (30 to 60 s). It is a starter, so that is intended. One realm above, it loses (about 7 s); a top-end cultivator ends it in under 2 s.

## What to look for

In the order you find them.

1. **Spiritual root (linh căn): Fire, middling purity (about 70).** In the game. Fire tags are cheap for you and the Fire manuals name your element. A purer root is better but not required.
2. **Talents.** Comprehension (faster manual layers) and Willpower (against heart demon from Fire manuals). In the game.
3. **Đạo and nodes: Hỏa Đạo (Phần Thiên), branch Chân Hỏa (True Flame, Burn).** Way in the design catalogue; its nodes are not in the game data yet (staged: Hỏa Đạo nodes need the Way data).
4. **Công pháp.** Early: Khơi Hỏa Sơ Quyết (Kindling Breath Primer), not in the game yet (staged: kindling-breath-primer). From Trúc Cơ: Xích Diễm Địa Quyết, in the game (+12 % linh lực, heart-demon resistance, reaches Nguyên Anh).
5. **Arts.** Spark Palm (Hỏa Tinh Chưởng), Kindling Seal (Dẫn Hỏa Ấn), Flame Lance (Liệt Diễm Thương), Warm the Hearth (Noãn Lô Quyết). All not in the game yet (staged: spark-palm, kindling-seal, flame-lance, warm-the-hearth).
6. **Items.** Xích Lô Trượng (Ember Rod, Fire weapon), Noãn Lô Đan (Hearth-Warming Pill), Tụ Hỏa Trận (Gathering Flame Array). Not in the game yet (staged: ember-rod, hearth-warming-pill, gathering-flame-array).
7. **Enabler: Embers Feed the Hearth.** A keystone in the Fire land of the tree. Not in the game yet (staged: embers-feed-the-hearth).

## The enabling Effects

- **Embers Feed the Hearth (Tàn Hỏa Dưỡng Lô).** Each Burn tick you deal restores linh lực equal to 25 % of its damage. Why you need it: it makes your own damage your fuel, so you can keep casting and keep the ward up. Its price: your direct Fire hits deal 15 % less, which is why you are a Burn build and not a big-hit build. Not in the game yet.
- **Kindled Wound (Trì Nhiệt).** Your Fire hits deal 15 % more (layer L5) to a target bearing your Burn. Why you need it: it fills the fifth layer for free, since your arts put Burn on the target at once. In the game (effects.md Starter Effects).

## Modifiers to stack

Most important first.

1. **Linh lực regeneration** (small +0.15 %, notable +1 % of the maximum per second). Fills the fuel layer. Stop when the bar stays near full through a fight; past that it is wasted.
2. **Fire art cost** (−1 % small, −6 % notable). Fuel. Cheap arts are why the pool holds. Stop at about −15 %.
3. **Fire damage** (+2 % small, +12 % notable), layer L1. Soft cap at +200 points, after which it counts half; hard cap 400. The easiest thing to stack.
4. **Status duration** (+2 %, +12 %). Burn lasts longer, so batches overlap. Falling returns once Burn lasts as long as the fight.
5. **Art speed** (+0.5 %, +3 %). More casts and more stacks. Falling returns; it stops at a 0.5 s cooldown.
6. **Ward strength** (+1.2 %, +8 %). Survival. The enemy's hits drain your pool through the ward.
7. **Layer fillers (L3, L4, L5).** An Ember Rod (L3), a pill and an array (L4), Kindled Wound (L5). Each layer is capped (L3 250, L4 150, L5 100 points); an empty layer costs you its whole factor.
8. **Status stack cap (+1 stack)** — a rare one-off node for the top end.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Embers Feed the Hearth | Effect: restore linh lực on a tick | the engine: the Burn refills you | Fire-land keystone, tree | staged | core |
| Kindled Wound | Effect: L5 +15 on Fire parts vs your Burn | fills layer L5 | Way, công pháp or item (effects.md) | in the game | core |
| Xích Diễm Địa Quyết | Công pháp: linh lực +12 % | pool and L2 growth | công pháp, found or bought | in the game | core |
| Linh lực regeneration | +1 % notable | forgiveness | tree notable | in the game | core |
| Fire damage | +12 % notable | L1 growth | tree notable | staged (key) | core |
| Fire art cost | −6 % notable | cheaper casts | tree notable | staged (key) | core |
| Status duration | +12 % notable | longer Burn | tree notable (Kindled Meridians) | staged | strong |
| Xích Lô Trượng (Ember Rod) | Weapon with Fire damage and art cost affixes | L3, a layer you cannot otherwise fill | artifact affix, named item | staged | strong |
| Noãn Lô Đan | Pill: regeneration for the fight | L4 and fuel | pill, from Alchemy | staged | strong |
| Tụ Hỏa Trận | Formation: Fire ground, L4 | L4 | formation | staged | strong |
| Ward strength | +8 % notable | survival | tree notable | in the game | strong |
| First Move (Tiên Thủ) | Keystone: first art costs nothing | smoother opening | tree keystone | staged | nice |
| Hỏa Đạo, Chân Hỏa branch | Way nodes: Burn bonuses | a Burn-scoped L2 | Đạo node | not in game data yet | strong |
| Status stack cap | +1 Burn stack cap | more batches | rare tree one-off | staged | nice |
| Spirit Severing (Đoạn Linh) | Keystone: your hits burn enemy linh lực | beats wards and healers | tree keystone | staged | nice |
| Cleanse, a Water art or a Sword art | Free-slot answer | handles Fire-resistant enemies | any art | in the design | strong |

What turns a working build into a top-end one: fill every layer to its cap (L2 to L5), Embers plus Kindled Wound, a legend-grade weapon, Hỏa Đạo's Burn nodes and the stack cap. A top-end build wins by being the one that never runs dry.

## Realm by realm

- **Luyện Khí (Qi Refining), 3 slots.** Spark Palm, Kindling Seal and Warm the Hearth. Slow but safe: costs are small. No Embers yet.
- **Trúc Cơ (Foundation), 4 slots.** Embers Feed the Hearth arrives. Add Flame Lance. The pool stops being a worry.
- **Kết Đan (Core Formation), 5 slots.** Ember Rod, pill, array and Kindled Wound fill L3, L4 and L5. One slot is free for your own answer to what you meet.

## How it plays

- **Art order:** Warm the Hearth first (it fires once), then Spark Palm every 2 s, Kindling Seal every 4 s, Flame Lance every 6 s. Nothing fires at the start: each art waits one cooldown.
- **Loadout:** Common Ward for the whole climb; it costs nothing to learn. The free fifth slot holds a non-Fire art or a cleanse.
- **Signature moment:** the enemy's ward goes down while your linh lực bar stays near full for a 20-second fight.

## What beats it

- **Fire-resistant enemy** (150 or more points against Fire): every tick is cut and so is your refill. Use the free slot for a non-Fire art or a Sword hit.
- **Cleanser:** wipes Burn stacks. Recast Spark Palm quickly and keep Status duration high.
- **Healer:** heals undo ticks. Bring a Flame Lance rhythm and a pill for more damage, and a Spirit Severing-style piece later.
- **Anyone a realm above:** you lose in seconds, as every ordinary build does.
- **Drainer (Qi Disruption):** the refill covers it, until the ward falls.

## Not in the game yet

- Embers Feed the Hearth (an Effect action; needs a rule in effects.md rule 6).
- Fire damage, Fire art cost, Status duration, Status stack cap, First Move (tagged keys).
- Khơi Hỏa Sơ Quyết, Spark Palm, Kindling Seal, Flame Lance, Warm the Hearth.
- Xích Lô Trượng, Noãn Lô Đan, Tụ Hỏa Trận.
- Kindled Meridians (cluster idea for the tree rework).
- Hỏa Đạo's Chân Hỏa nodes (the Way is in the design catalogue only).

## Changes the game would need

- **Effects System, rule 6 (action list) and the tick-dealt event:** allow "restore linh lực" on a Burn tick, with a bound at the pool maximum. Embers Feed the Hearth needs it; it is also written to `starter-flame.suggestions.md`.

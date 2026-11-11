# The Brimming Tide (Mãn Triều)

A Water cultivator who keeps the linh lực pool nearly full, and is paid for it twice: arts hit harder and the ward costs less.

## Why it works

In this game linh lực is mana and defence in one pool. Every art you cast weakens the ward, and when the pool runs dry the ward falls and hits land nearly whole. Most new players lose that way. The Tide turns the lesson into a build.

- **Cheap arts.** Costs are a share of your maximum pool: 2 to 4 % an art. Your three arts cost about 2 % of the pool a second between them.
- **Fast refill.** You regain 3.5 % of the pool every pulse (1 s), plus about 1.5 points from the build. Spending 2 % a second and regaining 5 % means the pool stays up.
- **Paid for being full.** The key piece, Brimming Cup (Mãn Bôi Quyết), gives your arts +2 % more damage for every 10 % of pool left, up to +20 %. Still Water (Tĩnh Thủy) makes the ward cheaper to run while the pool is at 80 % or more.
- **A real number.** At Foundation (Trúc Cơ) against a typical same-realm foe, the simulator showed 20 wins in 20 fights, about 31 s each, the foe dry at about 22 s and the player never dry, with a third of health left. That run counted the Cup as a flat +16 %, not the real pool-reading version.

The offence is a little below typical (about 3.7x against 4.2x at Foundation). The ward is above typical. The build wins by outlasting.

## What to look for

In the order you find them. All figures are first guesses.

1. **Spiritual root (linh căn): Water (Thủy), purity about 60.** In the game. Water stacks add pool and regeneration, so the root is the economy.
2. **Talents:** Deep Spirit (a bigger pool) and Calm Breath (regeneration). In the game as stat talents; Comprehension helps the Canon. In the game.
3. **Đạo and nodes: Thủy Đạo (Nhược Thủy), Uyên (Depths) and Triều (Tides) facets.** The Way is in the game (catalogued). Take the Uyên lines for pool and regeneration. Still Water and Depth Is Shield are not in the game yet (staged: still-water, depth-is-shield).
4. **Công pháp: Reading the Tide Canon (Độc Triều Kinh), tier 2.** Not in the game yet (staged: tide-reading-canon). Reaches Kết Đan (Core Formation).
5. **Arts:**
   - Tide Pulse (Triều Xung): the 3 s workhorse. Not in the game yet (staged: tide-pulse).
   - Deep Well Seal (Thâm Tỉnh Ấn): the 6 s heavy hit. Not in the game yet (staged: deep-well-seal).
   - Drawing Breath (Hấp Triều): refills 7 % of the pool every 8 s and gives two Water stacks. Not in the game yet (staged: drawing-breath).
6. **Items:**
   - Deep Cistern Robe (Thâm Trì Bào): any ward armour with ward strength and max linh lực affixes. In the game.
   - A weapon with a Water affix. In the game.
   - Tide-Bound Gourd (Hệ Triều Hồ Lô). Not in the game yet (staged: tide-bound-gourd).
   - Still Pool Array (Tĩnh Trì Trận), a formation; Clear-Spring Pill (Thanh Tuyền Đan). Not in the game yet (staged: still-pool-array, clear-spring-pill).
7. **Enabler:** none. Brimming Cup is the engine, not an enabler. Not in the game yet (it is a reused staged piece from the missing-pieces file).

## The enabling Effects

- **Brimming Cup (Mãn Bôi Quyết).** Your arts deal +2 % more for every 10 % of linh lực you still have, up to +20 %. This is the build: it pays you for the habit of not overspending.
- **Still Water (Tĩnh Thủy).** While your pool is at 80 % or more, your ward is cheaper to run (about +15 ward efficiency). The build needs it so the ward and the arts do not compete when you are at your fullest.
- **Spill Shield (Dật Thuẫn).** Regeneration that would go past a full pool becomes a ward shield, up to 20 % of your maximum. The build needs it because otherwise surplus regeneration is thrown away when you are full.

## Modifiers to stack

Most important first. The layer is the multiplier it fills (Combat B).

1. **Maximum linh lực and regeneration (no layer).** Everything else reads the pool. Stop when regeneration returns fall: it runs on a log curve with no cap, so each extra point helps less.
2. **Ward strength and ward efficiency (ward layers).** Fill all four ward layers: technique and arts, robe, formation, Effects. Caps are 300 / 250 / 150 / 100 points; a starter sits at 50 / 40 / 30 / 20.
3. **Water damage (L1).** The everyday layer. Past +200 points it counts half, so stop there.
4. **Technique passive, Water arts more (L2).** About +40; the cap is 300, you will not reach it as a starter.
5. **Weapon affix (L3), formation and pill (L4).** About +20 each. They are cheap, and they are layers other builds neglect.
6. **Brimming Cup (L5).** +20 at a full pool. L5 caps at 100.
7. **Water art cost (no layer).** A few percent. Stop at about -20 % total: below that the pool is full anyway.
8. **Art speed.** Last, and small. It shortens cooldowns and spends the pool faster, which works against the build.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Brimming Cup | Effect, L5 per pool share | Up to +20 % more damage at full pool | Canon layer 7 ability | Staged (brimming-cup) | core |
| Maximum linh lực nodes | `linh_luc_pct` | The deep pool | Tree notables, Uyên facet | In the game | core |
| Regeneration nodes | `linh_luc_regen_pct` | Keeps the pool full | Tree notables, Uyên facet | In the game | core |
| Ward strength and efficiency nodes | `defense_pct`, `ward_efficiency_pct` | The strong ward | Tree notables | In the game | core |
| Deep Cistern Robe | Ward gear affixes (W3) | +40 ward points | Armour with ward and pool affixes | In the game | core |
| Reading the Tide Canon | Technique passive, L2 | +40 points more on Water arts | The technique | Staged (tide-reading-canon) | core |
| Water damage nodes | L1 increased | +60 L1 points | Tree rows | Staged (tree catalogue row) | strong |
| Still Water | Effect, ward efficiency while pool at or above 80 % | A cheaper ward at full | Thủy Đạo Triều facet notable | Staged (still-water) | strong |
| Spill Shield on the Tide-Bound Gourd | Overflow Effect | Surplus regeneration becomes a ward shield | Named artifact | Staged (spill-shield, tide-bound-gourd) | strong |
| Water art cost nodes | Art cost -6 % notable | More casts per pool | Tree rows | Staged (tree catalogue row) | strong |
| Hot Spring Array | Formation, regen and health regen on its ground | A pool that refills faster at home | Formation recipe | Staged (hot-spring-array, another build) | strong |
| Still Pool Array | Formation, L4 and ward W4 | +20 L4 and +30 W4 | Formation recipe | Staged (still-pool-array) | strong |
| Clear-Spring Pill | Pill, raises pool for the fight | A bigger pool at the start | Alchemy | Staged (clear-spring-pill) | nice |
| Gathering Tide | Art: 2 Water stacks for the fight | Pool and regeneration from stacks | Water art | Staged (gathering-tide) | nice |
| Full Sea | Keystone: more damage above 80 % pool | A second payoff for a full pool | Tree keystone | Staged (full-sea) | nice |
| Depth Is Shield | Borrow: pool counts as ward strength | Turns a deep pool into the top-end ward | Thủy Đạo Uyên keystone | Staged (depth-is-shield) | top-end |
| The Spring Never Fails | Water stacks add regeneration outside returns | Top-end regeneration; its closing cost halves pool from other sources, so it fights the deep pool | Water-land keystone | Staged (spring-never-fails) | top-end, optional |

What turns a working Tide into a top-end one: fill all five offence layers and all four ward layers (the top-end anchors sit on the caps), add Depth Is Shield so the pool is also the ward, and pair Brimming Cup with Full Sea. Be careful with The Spring Never Fails: it halves other pool sources, the exact thing this build stacks.

## Realm by realm

- **Luyện Khí (Qi Refining):** two arts, three slots, the Common Ward. Your lesson is to read the bar: cast Tide Pulse, refill with Drawing Breath.
- **Trúc Cơ (Foundation):** four slots, Deep Well Seal, Brimming Cup, a real ward. The full loop. A typical same-realm foe dies at about 31 s.
- **Kết Đan (Core Formation):** five slots, Gathering Tide, the Gourd, Depth Is Shield. The pool is deep enough that the ward is a wall. In the simulator a typical same-realm foe dies at about 26 s.

## How it plays

- **Art order:** Tide Pulse (3 s), Deep Well Seal (6 s), Drawing Breath (8 s). Nothing fires at t = 0; each art waits one cooldown.
- **Loadout:** the three arts, a ward robe, a Water weapon, the array and the pill before the fight. At Trúc Cơ the fourth slot takes Gathering Tide.
- **Signature moment:** around 22 s the foe's pool hits zero and it is down to a basic attack, while your bar has stayed above 80 % all fight. You are still at +19 % more damage with the ward cheap.

## What beats it

- **A top-end burst opener.** It ends the fight in 1 to 2 s. Counter: none for a starter; avoid the fight, or carry a talisman escape.
- **A linh lực drainer (a Chìm, Drowning-facet, Vụ Đạo cultivator).** Burns the pool you rely on. Counter: carry a cleanse and prefer Gathering Tide over Deep Well Seal.
- **A foe one realm up.** In the simulator it won all 20 fights (11.5 s at Trúc Cơ, 8.0 s at Kết Đan). Counter: pills and the array, or wait a realm.
- **A body cultivator (thể tu).** Block and body resistance ignore the ward, and the fight drags into fatigue (from 60 s). Counter: raise Water damage and the Cup, and rely on health.

## Not in the game yet

Staged pieces this build needs: tide-reading-canon, tide-pulse, deep-well-seal, drawing-breath, brimming-cup, spill-shield, still-water, depth-is-shield, tide-bound-gourd, still-pool-array, clear-spring-pill, gathering-tide, full-sea, hot-spring-array, spring-never-fails, the Water damage and Water art cost tree rows, the Full Cistern (Mãn Trì) cluster, and a thủy-uyên node set in Thủy Đạo.

## Changes the game would need

- **Pool-share condition on the ward (Combat Defence & Healing, Formulas A):** Still Water makes ward efficiency depend on the current pool share. See `starter-tide.suggestions.md`.
- **Borrow: max linh lực counts toward ward strength (Combat Defence & Healing, A0):** Depth Is Shield. Needs a bound.
- **Spill Shield (Effects System, readable events):** an overflow event on regeneration; already assumed by the staged Effect, still needs the rule.

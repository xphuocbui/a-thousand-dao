# The Whetted Edge (Mài Phong Kiếm)

A Metal sword build for a new player: a flying sword, a basic attack that hurts, and a blade that gets sharper every time it crits.

## Why it works

The fight rewards crits more than most things a new player can reach, because crit sits outside the five damage layers. Crit chance starts at 0 and is capped at 0.5; crit damage starts at ×1.5 and is capped at ×3.0. The Whetted Edge climbs that ladder.

- **The loop.** The basic attack and a quick, cheap art (Quick Draw Cut, 1.5 s) swing constantly, so you roll crits often. Every crit puts a "Whet" stack on you: +2 points of crit chance per stack, up to 8 stacks (+16), each lasting 6 s. A crit makes the next crit more likely.
- **The extra.** Flowing Water makes every crit trim 0.5 s off your other arts' timers. Linh lực gained on a crit pays for the fast arts.
- **Key numbers (Trúc Cơ, Foundation).** About 15 % crit chance and ×1.7 crit damage on average once Whet is counted. Layers: L1 58, L2 40 (+10 on sword arts), L3 40, L4 20, L5 10, close to the typical Trúc Cơ build, with crit on top.
- **In the simulator** it wins about 16 of 20 against a same-realm typical cultivator at Trúc Cơ (27 s) and 14 of 20 at Kết Đan (20 s). It loses to anyone a realm higher. The simulator does not model Whet itself; it uses the average, so a real fight swings more.

The price is defence. The build wears the ordinary Common Ward and has no body bonus, and it lives on chance.

## What to look for

In the order a player finds them.

1. **Spiritual root (linh căn): Metal (Kim), middling purity, about 60 to 70.** Metal is the sword's element; Notch the Foe's stacks are Metal. In the game.
2. **Talents:** divine sense (thần thức) first, because the flying sword costs it (Phi Kiếm costs 20); Fortune second, for luck. In the game.
3. **The Way (Đạo): Kiếm Đạo (Sword).** Its Kiếm Ý facet (crit, pierce) and Phi Kiếm facet are the build's home. The existing Way is in the game; the three notables this build wants (Flowing Water, Edge Spills Over, Hot Edge) are not in the game yet (staged: kiem-y-edge-spills).
4. **Công pháp: Plain Iron Sword Manual (Phác Thiết Kiếm Quyết).** Main, tier 2, Metal. Reaches Kết Đan. Not in the game yet (staged: plain-iron-sword-manual).
5. **Arts:** Quick Draw Cut, Returning Sword Light, Notch the Foe (Trúc Cơ), Sheathe and Breathe and Ten Thousand Returns (Kết Đan). Not in the game yet (staged: quick-draw-cut, returning-sword-light, notch-the-foe, sheathe-and-breathe, ten-thousand-returns).
6. **Items:** the flying sword (Phi Kiếm base is in the game); the named Wren-Feather Flying Sword (not in the game yet, staged: wren-feather-sword); Whetstone Oil coating (not in the game yet, staged: whetstone-oil); Clear-Edge Pill (not in the game yet, staged: clear-edge-pill).
7. **The enabler:** none as an item. The enabling Effect is Whetted Edge, unlocked at layer 4 of the manual. Not in the game yet (staged: whetted-edge).

## The enabling Effects

- **Whetted Edge (Mài Phong).** Each crit adds a Whet stack (max 8, 6 s each); each stack adds 2 points of crit chance. This is the engine: without it you are a sword with a modest crit chance. With it, crits come in streaks. It needs a new rule in the Effects system (a crit event).
- **Flowing Water (Lưu Thủy).** Each crit shortens your other arts' timers by 0.5 s. This turns crit streaks into art streaks: the flying sword is ready again sooner. It is a keystone in the tree catalogue, not in the game yet.
- **Hot Edge (Nhiệt Phong).** +10 points of "more" damage while you have crit in the last 3 s. This is the L5 payoff of the streak. Not in the game yet.
- **Elemental Fist (Ngũ Hành Quyền).** The basic attack carries your Metal tags, so every Metal and sword modifier you stack also helps the basic attack. This is what makes the basic attack "strong". Catalogue keystone, not in the game yet.
- **Edge Spills Over (Phong Dật).** The late-game Effect: crit chance above the cap of 0.5 becomes crit damage. It gives a crit build a reason to keep stacking at the top.

## Modifiers to stack

Most important first. The layer each fills is in brackets.

1. **Crit chance with swords** (crit, outside the layers). Biggest early win. Stop at about 0.5 total (the cap); past that only Edge Spills Over helps.
2. **Crit damage** (crit). Base is ×1.5. Each +10 pp is an increase of about 6 to 7 % on a crit. Stop near ×3.0 (the cap).
3. **Basic attack coefficient add** (base). A flat add to the basic attack's size. It never stops mattering, because the basic attack is the only free channel.
4. **Basic attack damage** (L1) and **Sword damage** (L1). L1 past +200 counts half, so stop near +200.
5. **Drawn Steel** (L2). Strongest single layer bonus for sword arts; the L2 cap is 300.
6. **Flying sword attack** (L3). Your weapon's multiplier; limited by thần thức.
7. **Whetstone Oil and Clear-Edge Pill** (L4). The preparation layer, usually empty in a blind fight. Do it before a challenge.
8. **Hot Edge** (L5). Only counts while a crit is recent. Stop at its cap; a streak is needed.
9. **Sword art speed.** Falling returns, and it stops at the 0.5 s floor on cooldown.
10. **Linh lực regained on a crit**, **art cost** reductions (fuel). Stop when the pool no longer runs dry before the fight ends.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Whetted Edge | Effect | The loop: crit gives crit | Plain Iron Sword Manual, layer 4 (công pháp) | staged: whetted-edge | core |
| Crit chance with swords | Modifier | Raises the chance that feeds the loop | Tree nodes, Kiếm Ý facet | staged (tree catalogue row) | core |
| Crit damage | Modifier | Makes each crit bigger | Tree nodes, gear affix | in the game (crit_damage_pct) | core |
| Basic attack coefficient add | Modifier | A bigger always-on hit | Technique, tree notable | staged: basic-coef-add-key | core |
| Elemental Fist | Effect | The basic attack gets Metal and sword bonuses | Kiếm Đạo keystone | staged (catalogue keystone) | core |
| Wren-Feather Flying Sword | Modifier (L3 gear) | Weapon multiplier with crit affixes | Named item | staged: wren-feather-sword | core |
| Flowing Water | Effect | Crits shorten art timers | Kiếm Ý facet keystone | staged (catalogue keystone) | strong |
| Drawn Steel | Modifier (L2) | More damage on sword arts | Technique layer 7 | staged: drawn-steel | strong |
| Whetstone Oil | Modifier (L4) | The preparation layer | Coating, crafted | staged: whetstone-oil | strong |
| Clear-Edge Pill | Modifier (L4) | A few points of crit chance for the fight | Pill, alchemy | staged: clear-edge-pill | strong |
| Linh lực regained on a crit | Modifier | Pays for the fast arts | Tree notable | staged (tree catalogue row) | strong |
| Sword art speed | Modifier | Faster Quick Draw, more crit rolls | Tree nodes | staged (tree catalogue row) | nice |
| Hot Edge | Effect or modifier (L5) | More damage in a streak | Whetstone Row notable (cluster) | staged: hot-edge | nice |
| Flying sword attack | Modifier (L3) | Raises the weapon layer | Tree nodes, gear | staged (tree catalogue row) | nice |
| Edge Spills Over | Effect (overflow) | Top-end: crit chance past the cap becomes crit damage | Kiếm Ý facet keystone | staged: edge-spills-over | core for top-end |
| Better flying sword base | Modifier (L3) | A weapon that outlasts `phi_kiem` at Kết Đan | A higher-grade base or named item | not in the game yet (no staged name) | strong |

The pieces that turn a working build into a top-end one are Edge Spills Over, a full L3 and L4 (a better sword and prepared coatings), and a full Whet stack held through the whole fight.

## Realm by realm

- **Luyện Khí (Qi Refining).** Three slots: Returning Sword Light, Quick Draw Cut, Notch the Foe. The basic attack does the work. Crit is a rare ring.
- **Trúc Cơ (Foundation).** Four slots; Whetted Edge unlocks, and the streaks start. Add Whetstone Oil before fights and the Wren-Feather sword. Keep the fourth slot for a defensive talisman.
- **Kết Đan (Core Formation).** Five slots: add Ten Thousand Returns and Sheathe and Breathe. Flowing Water chains your arts, the crit cap comes into sight, and Hot Edge pays off the streaks. Past Kết Đan the build needs Edge Spills Over to keep growing.

## How it plays

- **Art order:** Quick Draw Cut, Returning Sword Light, Notch the Foe, then (Kết Đan) Ten Thousand Returns and Sheathe and Breathe. Quick Draw fires first since a 1.5 s cooldown gives the most crit rolls.
- **Loadout:** the free slot at Trúc Cơ goes to a defensive talisman, because the build has no other defence.
- **The signature moment:** a chain where crit follows crit, the Whet stacks climb to 6 or 7, and the flying sword's cooldown drops each time, ending the fight in half the usual time.

## What beats it

- **A thể tu with high block (a stone-wall body build).** Block takes a flat amount from every hit, and Quick Draw's small hits give it nothing back. Adapt: lean on Ten Thousand Returns and Notch, and add body damage.
- **An evasive wind duelist.** Hits that miss give no crit, so Whet lapses. Adapt: accuracy, and keep Quick Draw firing.
- **A cultivator a realm above.** No pierce; you lose fast (about 8 s at Trúc Cơ). Do not fight upward.
- **A ward-heavy caster who outlasts you.** The pool is your next limit (dry at about 15 s in the simulator): keep Sheathe and Breathe and linh lực on crit.

## Not in the game yet

Every staged piece this build needs:

- Effects: Whetted Edge, Flowing Water, Hot Edge, Elemental Fist, Edge Spills Over.
- Modifiers: Drawn Steel, basic attack coefficient add (`basic_coef_add`), crit chance with swords, Sword damage, flying sword attack, sword art speed, linh lực regained on a crit.
- Công pháp: Plain Iron Sword Manual.
- Arts: Returning Sword Light, Quick Draw Cut, Notch the Foe, Ten Thousand Returns, Sheathe and Breathe.
- Items: Wren-Feather Flying Sword, Whetstone Oil, Clear-Edge Pill.
- Cluster: Whetstone Row. Đạo notables: the Kiếm Ý facet's Edge Spills Over and Hot Edge.

In the game today: the Metal root, the Phi Kiếm base, Kiếm Đạo's facets as drawn, and crit damage.

## Changes the game would need

- **Crit as an event and a self-stack source.** Touches `design/gdd/effects.md` (events and status families) and `design/gdd/combat.md` rule 8. Needed by Whetted Edge, Hot Edge and Flowing Water.
- **Overflow on the crit-chance cap.** Touches `design/gdd/combat.md` rule 8 and Formulas C (`crit_chance_cap`, `crit_mult_cap`): chance above 0.5 turns into crit damage at 1 pp of multiplier per 2 pp, bounded by the 3.0 cap. Needed by Edge Spills Over.

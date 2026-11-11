# The Hollow Thief (Hư Thủ Thâu Pháp)

Leave your art slots empty, let the foe's arts fill them, and fire them back at the foe on your own multiplier.

## Why it works

You carry only two arts of your own. Every other art slot is a loan slot (tá vị). Each time the foe casts an art, the oldest empty loan slot records a copy of it. The copy keeps the foe's element and tags, costs you half the linh lực, starts at half its cooldown and fires on your cooldown timer with all five layers of **your** multiplier, not the foe's.

The key numbers (all first guesses):

- A copy starts at **70 %** of the foe's coefficient and can reach 100 % with Faithful Copy.
- **Borrowed Weight:** +12 % more damage on every copy for each different copy you hold, up to four (+48 %).
- **Full Hand:** +60 % more (layer L5) while every loan slot holds a copy.
- Copies sit at about ×218 total multiplier at Nguyên Anh, against ×256 for a full top-end build. Your own two arts sit at about ×102.
- On the simulator, a typical same-realm foe falls in about 3 s at Kết Đan and at Nguyên Anh. A full-cap top-end foe beats you in about 9 s. The theft itself is not modelled by the simulator, so treat these as approximate.

The foe's arts are your fuel: the more arts it throws, the more you throw back.

## What to look for

In the order you find them:

1. **Spiritual root (linh căn):** Water and Metal, Water at 60 purity or more. Water for regeneration, Metal for crit on blade copies. Any Hư Thực Đạo build can use another root. *In the game.*
2. **Talents:** Comprehension (ngộ tính) for sutra layers and thần thức for the gear and for soul defence. *In the game.*
3. **Đạo and nodes:** Hư Thực Đạo (Empty and Full), facets Ẩn Thực and Thực Kích, and the capstone Hư Thực Tương Sinh. The Way exists in the catalogue. *Way in the game (provisional catalogue); the nodes Hidden Hand, True Hand and the capstone: not in the game yet (staged: hidden-hand-notable, true-hand-notable, empty-becomes-full).*
4. **Công pháp:** the Hollow Hall Sutra (Hư Đường Kinh), a Địa giai (tier 2) main technique. At layer 4 it unlocks Borrowed Hand. *Not in the game yet (staged: hollow-hall-sutra, borrowed-hand).*
5. **Arts:** Hollow Palm (Hư Chưởng, a 2.6 hit) and Still Pool Mending (Tĩnh Trì Hồi Khí, a heal). *Not in the game yet (staged: hollow-palm, still-pool-mending).*
6. **Items:** Thousand-Hands Gauntlet, Bare-Scroll Robe, Mirror-Study Array, Still-Mind Pill. *Not in the game yet (staged for each).*
7. **The enabler:** Borrowed Hand (Tá Thủ). *Not in the game yet (staged: borrowed-hand).*

## The enabling Effects

- **Borrowed Hand (Tá Thủ):** at the start of a fight, every empty art slot is a loan slot; a foe's art cast is recorded as a copy. The build does not exist without it. It costs you the opening volley and any copy of a soul, ward or escape art.
- **Spent Hand (Tàn Thủ):** when your loan slots are full and the foe casts a new art, the oldest copy is released at once as a free hit at half its coefficient, instead of vanishing. This turns a full hand from a waste into a weapon. It counts against the trigger budget.
- **Pre-Read (Tiên Duyệt):** if you know the foe before the fight, its most costly known art is already in loan slot 1 at t = 0. It removes the slow start, and it is why a prepared hollow hand beats a surprised one.
- **Hollow Guard (Hư Hộ):** while a loan slot stays empty it gives you ward strength, so the wait for the foe's first art is not defenceless.

## Modifiers to stack

Most important first.

1. **Borrowed Weight** (L2, Per). Always. It is the engine. Stop at four copies; it is capped.
2. **Pilfered Craft** (L2, More, stolen tag). Layer L2 for copies sits at its cap of 300 with the sutra, Hư Thực notables and Borrowed Weight, so stop when L2 on copies reaches about 300.
3. **Full Hand** (L5, Conditional). The layer otherwise empty. Worth most, since L5 on own arts is zero.
4. **Attack percentage** (L1). Past +200 raw it counts at half, so stop around +400.
5. **Gear** (L3). The Gauntlet and robe, up to about +240 (cap 250).
6. **Prepared** (L4). Array, pill, Home Ground, up to about +150 (cap 150 for a top-end build).
7. **Faithful Copy** (base). Takes copies from 70 % to 100 %. After 100 % it adds nothing.
8. **Stolen art speed** and **Warm Hand**. Faster, earlier. Falling returns: art speed divides cooldowns down to 0.5 s.
9. **Art cost, regeneration, Stolen Breath.** Half-price copies still drain a pool. Regeneration has no cap but falling returns.
10. **Own Medicine.** A foe's resistance to its own art counts at half. A priority when the foe is a heavy resister.
11. **Crit chance on stolen arts.** The crit cap is 50 %; this build sits near +20 %.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Borrowed Hand | Effect (enabler) | The loan slots, and the build | Hollow Hall Sutra, layer 4 | Staged (borrowed-hand) | Core |
| Borrowed Weight | Modifier, Per | +12 % more per distinct copy, to +48 % | Sutra layer bonus | Staged (borrowed-weight) | Core |
| Pilfered Craft | Modifier, More | +30 % more on copies | Hư Thực Đạo, Ẩn Thực notable | Staged (pilfered-craft) | Core |
| Full Hand | Modifier, L5 | +60 % more while all loans are full | Hư Thực Đạo, Thực Kích notable | Staged (full-hand) | Core |
| Faithful Copy | Modifier, base | 70 % to 100 % of the foe's coefficient | Hollow Hall cluster notables | Staged (faithful-copy) | Core |
| Thousand-Hands Gauntlet | Item, L3 | Weapon attack and Warm Hand | Named artifact from a fallen scribe sect | Staged (thousand-hands-gauntlet) | Core |
| Attack percentage | Modifier, L1 | The everyday layer | Tree nodes and Way W | In the game | Core |
| Art cost and regeneration | Modifier | The pool for half-price copies | Tree, Water root | In the game | Core |
| Spent Hand | Effect | A full hand returns its overflow as free hits | Hư Thực Đạo keystone | Staged (spent-hand) | Strong |
| Pre-Read | Effect | An opening copy at t = 0 | Mirror-Study Array | Staged (pre-read) | Strong |
| Mirror-Study Array | Formation, L4 | Prepared more and Pre-Read | Formation crafting | Staged (mirror-study-array) | Strong |
| Warm Hand | Modifier, timing | A copy fires after 25 % of its cooldown | Hollow Hall cluster | Staged (warm-hand) | Strong |
| Own Medicine | Modifier | Cuts a resistant foe's resistance to its own art | Hollow Hall cluster | Staged (own-medicine) | Strong |
| Art speed on one tag | Modifier | Faster copies | Tree notable, tag `stolen` | Row in the catalogue; tag not in the game yet | Strong |
| Stolen Breath | Modifier | Linh lực back on a copy's hit | Hollow Hall cluster | Staged (stolen-breath) | Strong |
| Bare-Scroll Robe, Hollow Guard | Item, ward | Ward strength while slots wait | Armour affix | Staged (bare-scroll-robe, hollow-guard) | Nice |
| Clear Path | Effect, art speed | +40 art speed per empty slot, up to +280, and loan slots count as empty | Đại Đạo, Giản facet | Staged by another build (clear-path) | Nice |
| Wide Sleeve | Modifier, cap shift | One more loan slot; own arts cost 20 % more | Hollow Hall keystone | Staged (wide-sleeve) | Nice. What turns a good build into a top-end one when the foe has five arts |
| Still-Mind Pill | Pill | Thần thức for the gear | Alchemy | Staged (still-mind-pill) | Nice |
| Home Ground | Keystone, L4 | Ground tags always count | Tree rework keystone | Catalogue idea, not in the game | Nice |
| Crit chance on one tag | Modifier | More crit on copies | Tree notable | Catalogue idea | Nice |

## Realm by realm

- **Kết Đan (Core Formation):** five slots, two own arts, three loans. Read what the foe brings. Against a typical caster the fight ends in about 3 s in the simulator.
- **Nguyên Anh (Nascent Soul):** six slots, four loans (five with Wide Sleeve). Pre-Read arms you at t = 0, and Spent Hand cashes the overflow.

Past Nguyên Anh the build is not designed; more slots and more loans would need a rebalance.

## How it plays

- **Art order:** Hollow Palm first (it is the only own damage), then Still Pool Mending. The loan slots follow in order of the foe's casts.
- **Loadout:** two arts and nothing else. No talismans (each takes a slot, which is a loan slot). A Drain ward with the Bare-Scroll Robe.
- **Signature moment:** a sword-sect elder throws his big art, and four seconds later it comes back on him faster than he cast it. Four copies of his arts in hand, a fifth cast, and the oldest comes out as a free hit.

## What beats it

- **A bare-fist body cultivator (thể tu):** basic attacks only, nothing to copy. Bring more own arts and give up loans, or avoid the fight.
- **A soul-art cultivator:** soul arts cannot be copied and skip the ward. Take thần thức, soul resistance and a soul ward.
- **A top-end alpha striker:** kills in a volley or two, before the copies ramp. Pre-Read and a stronger ward are your answer, and some fights you lose.
- **A one-art hermit:** gives one copy and no Borrowed Weight. It is an even fight, not a win.

## Not in the game yet

Everything unique to this build is staged: Borrowed Hand, loan slots, the `stolen` tag, the enemy-art-cast reading, Borrowed Weight, Pilfered Craft, Full Hand, Faithful Copy, Warm Hand, Own Medicine, Stolen Breath, Hollow Guard, Wide Sleeve, Spent Hand, Pre-Read, the Hollow Hall Sutra, Hollow Palm, Still Pool Mending, Hidden Hand, True Hand, the capstone, the Gauntlet, the robe, the array, the pill and the Hollow Hall cluster. Only attack percentage, art cost, regeneration, maximum linh lực and Hư Thực Đạo's catalogue entry are in the game or its catalogue.

## Changes the game would need

- **Loan slots and copying a foe's art.** Combat rule 13 (arts, cooldown timers and slot order) and rule 10 (instant order: the foe's cast is an event the other side can read). A copy is a generated art record in an empty slot, bounded at one per art id, never a soul, ward or escape art.
- **Enemy art list readable before the fight.** Combat Open Question 4 (what a character can read about the foe while preparing) for Pre-Read.

# The Wheel: Every Plain Stack on One Meridian Map (Kinh Mạch Đồ)

> **Status**: A proposal for the tree rework, written overnight on 2026-11-07. **No tree data was touched:** `assets/data/meridian_tree.json`, the GDDs, the registry and the catalogue are as they were. Nothing here is implemented, and the placements and folded sizes below are an agent's reading, not the user's decision. Folded sizes have not been run unless a file is named.

**The one idea.** Each element's two rival lines lean toward its two sector borders. So every border is met from both sides, and each border has one natural theme. Seven form paths (Sword, Poison, Curse, Body, Soul, Companion, Sustain) have no element, so they run across the wheel and borrow a border at each fork.

```
                              WOOD (Mộc)
              Crown  /                        \  Bramble
                    /    INCOME      STACKS    \
          Soaking  /                  AND TICKS \  Slow Fire
                  /                              \
          WATER (Thủy)     K1 K2 K3 rings     FIRE (Hỏa)
                  \        cross every           /
             Cold  \       sector: the form     /  Fierce Fire
                    \      paths run here      /
                     \  CRIT            HEAVY /
              Edge    \                 ARTS /   Kiln
                  METAL (Kim) ---GEAR--- EARTH (Thổ)
                 Grindstone's trunk      Ore
```

Clockwise from the top, as Map rule 1 lays the gates. Fire makes Earth, Earth makes Metal, and so on round.

## What the Map already gives a border

- **Every border:** 2 bridge clusters of 5 and 3 gap clusters of 3, 5 and 6, so 24 cluster acupoints and 5 crossings (rules 1, 21).
- **Scaling (rule 4):** a sector acupoint pays 0.5 + purity / 100, or 0.25 if you lack the element. A bridge pays the average of its two sectors. A gap cluster pays as sector s of the border between s and s + 1.
- **So borders are not symmetric, and the rework must decide this.** On a one-element root at purity 50, a bridge pays ×0.625. A gap cluster pays ×1.00 to the line leaning clockwise (Bramble, Fierce, Ore, Edge, Soaking) and **×0.25** to the line leaning the other way (Slow Fire, Kiln, Point, Cold, Crown). Every element has one line of each kind, or else the rule rewards two-element roots, which may be what you want.
- **A shape to borrow (rule 20):** a variant sector is 30 acupoints: a road chain, two clusters and an apex. That is the Plain Stack's shape: a trunk, two lines and a payoff. Four paths are already 30 nodes. Hidden clusters (rule 6) hold 3 to 12 acupoints, with notables farthest from the entry.

## The five borders

| Border | Theme | Lines that meet here | Shared rows at this border (folded below) |
|---|---|---|---|
| **Wood and Fire** | Stacks and ticks | Bramble, Slow Fire; Poison's Blood | Kindling, Stoked, Status chance, Status duration, Damage over time, Tag over-time row, Heat Held and Keeping Heat |
| **Fire and Earth** | Heavy arts | Fierce Fire, Kiln; Curse's Long, Body's Pestle | The heavy line, Unbroken Glaze, Above and below half health, Worn Slope, Fired Clay |
| **Earth and Metal** | Gear | Ore, Grindstone's trunk; Sword's Flown, Body's Mortar | Weapon attack, Artifact power, Armour defence, Per artifact row, Many Threads |
| **Metal and Water** | Crit | Edge, Cold; Sword's Held, Sustain's Quick | Crit chance with a tag (Hair's Breadth, Hàn Mang, White Point), Crit damage, Cold Dew (Hồi Bạo), the quick line, Cold Edge |
| **Water and Wood** | Income | Soaking, Crown; Curse's Light, Poison's Breath, Sustain's Slow, Companion's Held | Regeneration, Per regeneration row, Maximum linh lực, Ward efficiency, Held Water, Thin Stream and Small Word |

## The element paths

Every element trunk has the same catalogue skeleton, which is right: **[Element] damage +2 / +12, [Element] art cost −1 / −6, [Element] art speed +1 / +6.** The table lists what each adds.

| Path, sheet, walk | Trunk rows | Line one and its border | Line two and its border | How real is the fork |
|---|---|---|---|---|
| **Fire**, Fierce Fire, 30 nodes, Nascent Soul | Fire damage, Red Heart, Fire art cost, Dry Wood, Fire art speed | **Fierce Fire → Earth:** speed, Fire crit, Full Bellows, Thin Ward, Open Door | **Slow Fire → Wood:** status chance, duration, Heat Held, Keeping Heat, Stoked | Real |
| **Earth**, Long Firing, 55, Core | Earth damage, Body damage, Settled Weight, Maximum health, Body guard | **Kiln → Fire:** Unbroken Glaze, Above half, Fired Clay, Thinning Ward, ward rows | **Ore → Metal:** Weapon attack, Armour defence, Load-Bearing, Worn Slope, Below half | **Now thin.** At the legal 0.10 Kiln wins every saved fight and Ore has only speed |
| **Metal**, Grindstone, 34, Qi Refining | Metal damage, Bright Steel, Crit chance, Crit damage, Weapon attack, Good Steel, Artifact power, Maximum linh lực, Maximum health, Tough Grain, Ore Vein | **Edge → Water:** Deep Bite, Hair's Breadth, Steady Thread, Honed Edge, Thinning Ward | **Point → Earth, in name only:** Accuracy, True Line, then four Curse rows | Weak. Point is rented from Curse, and the Edge's crit rows move nothing |
| **Water**, One Ladle, 110, Deity | Water damage, Maximum linh lực, Ward strength, Ward efficiency, Regeneration, Water art cost, Unbroken Surface | **Soaking → Wood:** Qi damage, Thin Stream, Held Water, Spring Head, Wasting | **Cold → Metal:** Body damage, Cold Edge, Hàn Mang, Crit damage, Hồi Bạo | Half. Cold's only job is the fast killer |
| **Wood**, Evergreen, 75, Deity | Wood damage, Green Heart, Regeneration, Deep Drink, Wood art cost, Thin Leaf, Maximum health, Old Bark, Maximum linh lực, Full Trunk, Ward efficiency, Slow Sap | **Crown → Water:** Spring Vein, Sap Rise, Living Wood, Sustained Note, Steady Thread, Late Leaf | **Bramble → Fire:** Wood art speed, Quick Shoot, Status chance, Damage over time, Deep Thorn, Stoked | Weak. Bramble wins only the Mountain, an enemy with no arts |

## The form paths: where each could sit

| Path, sheet, walk | Where it could sit | Trunk rows | Line one and its border | Line two and its border |
|---|---|---|---|---|
| **Sword**, Daily Lesson, 30, Foundation | Sword Intent clusters, a spur off Metal's outer ring | Sword damage, Crit chance with swords | **Flown → Earth and Metal:** Flying sword attack, Long Flight, Steady Thread, Many Threads | **Held → Metal and Water:** Sword art speed, Short Edge, Spent Breath, Many Forms |
| **Poison**, Second Sickness, 30, Foundation | The Wood side of K2, with Sick Meridians as its sealed home | Poison damage, Damage over time, Status chance, Poison art cost, Long Simmer | **Blood → Wood and Fire:** Status duration, Complication, Sick Body, survival rows | **Breath → Water and Wood:** Burn damage, Basic attack, Khô Hải, Bare Vessel, Wasting |
| **Curse**, One Long Word, 30, Foundation | The K1 ring, since it needs no root and every root should reach it | Lingering Word, Slow to Lift, Sharpened Word, Full Weight, Quick Tongue, Between Breaths, Thrifty Word, Marked Target, Bare Vessel, Thinning Ward | **Long → Fire and Earth:** Single Grudge, Set Jaw, One Thought, Long Memory, Unbroken Sentence | **Light → Water and Wood:** Many Small Ills, Nibbling Word, Crowded Sky, Small Word, Hurrying Word |
| **Body**, Rice Pestle, 131, Deity | Body Guarding and Vitality clusters in the Earth sector. Health needs little walking, as one road node in two carries it | Body damage, Art damage, Basic attack, Crit on body hits, Crit damage, Body guard, Blood Stroke, Thinning Ward | **Pestle → Fire and Earth:** Maximum health, Mass Behind the Blow, Reopened | **Mortar → Earth and Metal:** Body guard, Armour defence, Hard Knuckle, Unmoved |
| **Soul**, Third Look, 70, Nascent Soul | Divine Sense clusters in the inner band beside K1, because roads already carry thần thức | Thần thức, Soul attack damage, Soul art cost, Regeneration, Maximum health, Ward efficiency | **Tower → no border:** Fine Point, Empty Room, Clear Head, Failing Lamp | **Walk-Down → any border:** Damage, Basic attack, Khô Hải, Wasting |
| **Companion**, Guide Hound, 99, Nascent Soul | Beast Taming clusters on K2. Capability #17 sits at the end of the trunk | Companion damage, Beast damage, Qi damage, Companion speed, Beast Soul Union, Full Trough, Long Loyalty, Wasting, ward and pool rows | **Held Leash → Water and Wood:** Still Hand, Behind the Ward, Above half | **Slipped Leash → K1, the Curse ring:** Urging Word, Opened Guard, Thrifty Word |
| **Sustain**, Seven Lamps, 198, Deity | Spiritual Power clusters across the Water and Wood border. The sheet asks to be dipped into, not walked whole | Regeneration, Art cost, Ward efficiency, Ward strength, Against body hits, Health, Body guard, Art damage, Tận Khí, Wasting | **Slow Breath → Water and Wood:** Spared Breath, Deep Breath, Patient Art, Late Hour, Steady Breath | **Quick Breath → Metal and Water:** Art speed, Short Art, Quickened, Running Low |

## One row, not several

The critic's Section 2 duplicates, folded. The first eight are the same effect under two names, so nothing changes but the name.

| One shared row | Size | Replaces | Used by |
|---|---|---|---|
| Regeneration (Hồi Khí), notable | +1 % | Deep Drink, Spring Vein | Wood; catalogue row also on Water, Earth, Poison, Soul, Sustain |
| Maximum linh lực (Linh Hải), notable | +8 % | Full Trunk, taken twice | Wood; catalogue row on most paths |
| Ward efficiency (Hộ Hiệu), notable | +8 % | Slow Sap, taken twice | Wood; catalogue row on most paths |
| Maximum health (Khí Huyết), notable | +6.5 % | Old Bark, Tough Grain | Wood, Metal; catalogue row on most paths |
| Status chance (Trúng Suất), notable | +6 % | Catching Flame, Catching Thorn | Fire, Wood, Poison |
| Ward strength against [element], notable | +12 % | Burnt Hands, Tempered, Green Wall, Khắc Hỏa, Hộ Đê, Khắc Thủy, Hộ Căn | Fire, Metal, Wood, Water, Earth. Not run: no element on a hit |
| Curse duration, notable | +15 % | Slow to Lift, Long Memory | Curse |
| Curse art speed, notable | +6 % | Between Breaths, Hurrying Word | Curse |
| Per curse on the target, acupoint | +1 | Marked Target (L1), Nibbling Word (L2). **Pick a layer:** they differ | Curse |
| Per 1 % regeneration, notable | +3, reading one base | Spring Head (+3, regeneration owned), Sap Rise (+4, bonus only), Deep Breath (+2) | Water, Wood, Sustain |
| Per artifact, at most 6 | +1 / +5 | Ore Vein, Load-Bearing | Metal, Earth. Many Threads is its sword cousin |
| [Element] over-time status, notable | +12 | Deep Coals, Deep Thorn | Fire, Wood |
| **The heavy line**: authored cooldown 3 s or more | +2 / +12 | Long Flight, Full Bellows, Settled Weight, One Thought, Patient Art | Sword, Fire, Earth, Curse, Sustain |
| **The quick line**: authored cooldown under 2 s | +2 / +12 | Short Edge, Short Art | Sword, Sustain |

The heavy line at 3 s would switch off Long Flight, because the Flown swords fire every 2 s. Not run, so check that first.

## The one "their pool is low" family

Six rows pay for the same moment, in 6 of the 8 first sheets. Proposal: three rungs, one layer each, every tree row at the Conditional and Per sizes the other roads use.

| Rung | Reads | Layer | Proposed size | Rows it folds | Used by today, at today's size |
|---|---|---|---|---|---|
| **Thinning** | Enemy under 50 % linh lực | L1 | +2 / +12 | Thinning Ward (Bạc Hộ), Unbroken Sentence (L5, +10) | Curse, Metal, Earth, Body |
| **Wasting** | Per 1 % of enemy linh lực missing | L2 | +0.02 / +0.12 | Wasting (Hao Tổn, +0.2), Thin Ward (also written Bạc Hộ, +0.05) | Poison, Water, Soul, Companion, Sustain; Fire. Failing Lamp is its soul twin, on `x_soul` |
| **Bare** | Enemy under 5 % linh lực | L5 | +2.5 / +15 | Bare Vessel on a node, Open Door and the catalogue's no linh lực row (Khô Hải, Tận Khí) | Curse +2.5, Poison +25; Fire, Poison, Soul, Sustain +15 at L1 |

**Bare Vessel's grades, stated plainly.** Acupoint +2.5, notable +25, lesser grade +30, greater grade +80. The last two sit on techniques and sealed clusters and stay outside this table. Two sheets now say so. Numbers were not changed, because a change alters fights:

- **Second Sickness at +15:** every Breath result holds, except that one lost fight ends with the enemy on 39 %, not 35 % (`second-sickness-breath-*-bv15`). So Bare Vessel is **not** why Breath beats Blood, whatever the critic suspected.
- **Fierce Fire at +15:** the main fight holds (`fierce-fire-mixed-bv15`), but the split and the cost pair turn from wins into losses (`fierce-fire-split-mixed-bv15`, `fierce-fire-mixed-pair-cost-bv15`).

**Two rulings wanted.** Is the catalogue's "no linh lực" Bare Vessel's 5 %? And does the Bare rung sit on L5, or on the catalogue's L1?

## Rows to re-think

Noted, not rewritten.

| Row | The problem | What to think about |
|---|---|---|
| Long Flight 2 s, Full Bellows 2.5 s, Settled Weight and One Thought 3 s, Thin Stream 5 % | Thresholds read off the sheet's own arts, so the condition is a disguised "this kit" | One heavy line, one quick line, one cheap line, set by the art lint and not by a sheet |
| Unbroken Surface (above 5 % linh lực) | **Never false in its home fight.** Ladle's pool ends on 28 %, so it is a free +36 L5 dressed as a Conditional | Raise the bar, or price it as a More row |
| Behind the Ward (above 25 %) | The same trap, found while folding: Guide Hound's pool stops at 36 % at home | As above |
| Long Firing's "no enabler" | `common-ward` loses at 6 s, so the Stone Ward is the enabler | Call it one |
| Daily Lesson's swords, Grindstone's needles | The kit carries L3 117 and 114, more than the road | Say so, or price gear against the road |
| The Ore Line | Fixing Stone Ward's illegal 0.125 removed its wins | Give it something Kiln cannot do |
| The Point, the Bramble | Weak forks: Metal's Earth side is really the gear trunk | Metal's second line could be Blade and Mail, the sheet's open question |

## What the rework inherits

- **Lengths do not compare.** Walks are 30, 34, 55, 70, 75, 99, 110, 131 and 198 nodes across five realms. Pick one length per realm first.
- **No path pays road tax.** 430 of 772 visible acupoints are generic road, which leaves about 68 cluster acupoints a sector. A real 30-node walk holds 10 or more nodes of nothing, and the 110-node Water walk does not fit in one sector at all.
- **One enemy still sorts the paths.** In the critic's probe, a mixed enemy on a per-pulse ward at 0.125 beat 7 of the 14 lines that had won. Test any new shape on `panel.md`, not on the mixed enemy alone.
- **Not yet fixed, outside this pass.** The Seven Lamps still runs Stone Ward at the illegal 0.125 and calls 0.15 safe. Daily Lesson, Guide Hound and Seven Lamps still say "any purity" on sector ground. Long Firing's row in `panel.md` and the ledger's Stone Ward line wait for the next merge and panel run.

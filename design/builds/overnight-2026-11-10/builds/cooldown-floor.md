# The Winnowing Gale (Dương Khang Phong)

Six cheap Wind arts strike every half second, thirteen blows a second, and each stroke costs less than the last.

## Why it works

Four rules of the fight make this build.

1. **No art can fire faster than every 0.5 s (`cooldown_min`), and art speed only divides a cooldown down to that floor.**
   An art's cooldown is `max(0.5 s, cooldown ÷ (1 + art speed))`. A 1.9 s art needs +280 % art speed to reach the floor.
   Every art in this build is authored at 1.9 s or less (so it counts as `quick`) and at a cost of 2.5 % of maximum linh
   lực or less (so it counts as `cheap`). Once they all sit at the floor, six arts fire twice a second and the basic attack
   once: **13 hits a second** at Nguyên Anh (Nascent Soul). A typical cultivator lands about 2.
2. **Art damage is paid for in cost and cooldown.** The art limit is `coefficient ≤ 1 + 24 × cost + 0.25 × (cooldown − 1)`.
   A cheap 1.9 s art gets 1.825; art speed takes the 1.9 s back. So you author every art at the long edge of "quick" and
   buy the art speed.
3. **The linh lực bill.** Costs are a share of your maximum. Twelve firings a second at 2.5 % each, halved to 1.25 % by the
   −50 % cost cap, is **15 % of your pool a second**. Base regeneration is 3.5 % a second. Every build that tries this runs dry.
   This one pays in three ways:
   - **Linh lực on hit** is a plain number, paid for every hit that lands, with no cap on how often. At +0.5 % of
     maximum per hit and 13 hits a second, that is **6.5 % a second**. A three-art caster gets the same node paid 2 or 3 times.
   - **Wind buff stacks** come from the arts themselves: +7.5 % art speed each (more with high Wind purity), and about
     24 of them stand at once. They push art speed far past the floor, to about +500 %.
   - **Slipstream (Thuận Phong)**, the build's own piece, spends that surplus. Art speed the floor throws away makes that
     art cheaper: 1 point of "dampened" cost for every 2 % clipped, so +220 % clipped divides a 1.9 s art's cost by 2.1,
     and the 1.0 s art's by 3 (its cap). The steady bill falls from about 15 % a second to **about 6.6 %**, under your
     income of about 12 %.
4. **A per-hit ward charges a fee for every hit it meets.** Golden Bell (Kim Chung Tráo) charges 3.5 % of its owner's
   maximum linh lực a hit. Against 13 hits a second that is **45 % of their pool a second**. They are dry by about the
   second pulse, and with no linh lực they have no ward at all.

The fight gets cheaper the longer it runs, because the Wind stacks keep rising. Sustain is king in this game, and this
build is a damage build that is also a sustain build.

## What to look for

In the order you meet them.

1. **Spiritual root (linh căn): Wind (Phong)**, purity 70 or more, on any base root. Wind is innate: it is rolled at birth
   (2.5 % of lives). Purity multiplies every Wind stack (`× (1 + 0.002 × purity)`). A Metal or Earth base root suits the
   Physical arts. *In the game.*
2. **Talents:** Comprehension (ngộ tính) to reach layer 12 of the scripture; some Root bone (căn cốt) to offset Glass
   Meridians' lost health. *In the game.*
3. **Đạo:** **Phong Đạo · Thanh Phong** (Clear Breeze: Wind). *In the game's Way catalogue; its graph is not drawn yet.*
   - Facet **Cuồng Phong (Gale: art speed)**: art speed and art cost lines, linh lực on hit, two Light Chaff (Khinh
     Khang) notables, Overheat, Eruption, and its big Effect, Slipstream. *Not in the game yet (staged: phong-cuong-phong-gale).*
   - Facet **Phiêu (Drift: Wind stacks)**: stack effect and stack duration for Wind. *Not in the game yet (staged: phong-cuong-phong-gale).*
   - The Way's capstone line: Trigger limit +1. *Not in the game yet (staged: trigger-limit).*
4. **Công pháp: Winnowing Wind Scripture (Dương Khang Phong Quyết)**, main, Địa giai, 12 layers. Bonuses: damage +15 %,
   linh lực +20 %, ward strength +15 %. Passives: Light Chaff +60 (layer 3), art speed +40 % [Wind] (5), linh lực on hit
   +0.10 % [Wind] (7), Slipstream (9), art cost −20 % [Wind] (11). *Not in the game yet (staged: winnowing-wind-scripture).*
   The only Wind technique in the game today, Phong Hành Quyết, is a travel method that stops at Kết Đan.
5. **Arts (from the scripture).** *Not in the game yet (staged: chaff-needle, husk-splitting-cut, winnowing-toss,
   sieve-palm, threshing-rain, empty-husk-gust, sweeping-the-floor).*
   - Chaff Needle (Khang Châm), 1.0 s: grants you a Wind stack.
   - Husk-Splitting Cut (Phá Xác Trảm), 1.9 s: lays a Wind debuff (−evade) on the foe.
   - Winnowing Toss (Dương Phong Thức), 1.9 s: grants you a Wind stack.
   - Sieve Palm (Sàng Chưởng), 1.9 s: lays a Wind debuff.
   - Threshing Rain (Đả Cốc Vũ), 1.9 s: both.
   - Empty-Husk Gust (Không Xác Phong), 1.9 s: plain damage.
   - Sweeping the Floor (Tảo Trường): clears your curses when you are Silenced or under Heavy Breath. It has no Wind tag
     on purpose, so a Silence on Wind arts cannot stop it.
6. **Items.**
   - **Granary-Mother's Fan (Thương Mẫu Phiến)**: +1 art slot, +30 % art speed, +0.15 % linh lực on hit, +6 % health
     leech, and Steady Breath on Wind arts. *Not in the game yet (staged: winnowing-fan).*
   - A Cực phẩm needle (Châm) with the Liệt affix: cheap in thần thức. *In the game.*
   - Rolled pieces with the Tật (art speed), Hồi Khí (linh lực on hit) or Hấp Huyết (health leech) affixes. *Not in the
     game yet (staged: gale-affixes).*
   - For foreseen fights: Nine Rods Array (Cửu Can Trận) and Iron-Sand Hand Bath (Thiết Sa Dục Thủ). *Not in the game
     yet (staged: nine-rods-array, iron-sand-hand-bath).*
7. **Enabler:** none. The build is a stack of pieces the game already designs, plus one new Effect (Slipstream) and one
   named fan.

## The enabling Effects

- **Slipstream (Thuận Phong).** Art speed that the 0.5 s floor clips on an art, read when it fires, dampens that art's
  cost: +1 per 2 % clipped, up to +200 (cost ÷ 3). This is the build. Without it, art speed past the floor is wasted and
  the bill is 15 % a second; with it, the bill is 6.6 %. *Not in the game yet (staged: slipstream).*
- **Overheat (Quá Nhiệt).** Art speed the floor clips becomes extra damage for that art, point for point, up to +30 (layer
  L5). It reads your art speed before the fight, so it wants +310 % from gear, tree, Way and technique, without counting
  Wind stacks. *In the game (designed in the Effects GDD; not built yet).*
- **Steady Breath (Bình Tức).** While your linh lực is at 50 % or more, your Wind arts deal +12 (L5). This build keeps
  its pool high, so it is lit all fight. *In the game (designed; not built yet).* Carried by the fan.
- **Eruption (Phún Trào).** +5 (L5) for each other art fired in the same instant, up to +25. With +310 % compile art
  speed, all six arts fire their first stroke at 0.500 s and stay on one timer. *Not in the game yet (staged: eruption).*
- **Glass Meridians (Lưu Ly Kinh Mạch).** +40 % art speed for −25 % health and half body shields. *In the game
  (designed; not built yet).*
- **Breath Between Blows (Gian Tức).** Each art you fire restores 1.2 % of maximum linh lực. It is a trigger, so it fires
  at most 6 times a second (the trigger cap), which is 7.2 % a second. It pays the Kết Đan bill before Slipstream exists.
  It forbids arts over 6 s, which this build never slots. *Not in the game yet (staged: breath-between-blows, first
  listed in the by-root Wind builds).*
- **Echo (Hồi Âm).** A landed art hit has a 25 % chance to strike again for free. With 12 art hits a second, about 3
  extra hits a second, inside the same 6-a-second trigger cap. *In the game (designed; not built yet).*
- **Still Water (Tĩnh Thủy).** Linh lực lost to a full pool heals you for half. Your surplus becomes health. *In the game
  (designed; not built yet).*

**The trigger cap is a budget.** Breath Between Blows and Echo are both triggers and share 6 firings a second (7 with
Trigger limit). Plain modifiers such as linh lực on hit and health leech are not triggers and have no such cap. That is
why this build buys sustain as plain numbers and spends its trigger budget on one Effect at a time.

## Modifiers to stack

Most important first. The layer each fills is in brackets.

1. **Art speed** (none: timing). +310 % before the fight: every art fires its first stroke together at 0.500 s and
   Overheat is full on all of them. Past that, Wind stacks add the rest in the fight; their surplus feeds Slipstream until
   it caps at +400 % clipped. Stop buying art speed on gear at +310 %.
2. **Linh lực on hit** (none: sustain). Aim for +0.5 % of maximum a hit (6.5 % a second). Up to +0.8 % is still worth it
   at Kết Đan or against Ice foes. Past the point where your pool sits full, the extra only feeds Still Water.
3. **Art cost** (none). To −50 %, the hard cap; stop there.
4. **Wind stack effect and duration** (none). Each +10 % stack effect is about +20 % art speed and −3 pp more enemy evade.
   No cap; stop when Slipstream is capped and the foe's evade is at 0.
5. **L2 "more" for quick, cheap arts** (L2, cap 300). Light Chaff from the scripture (+60) and the Way (+40 each). Your
   thinnest layer: every point here is worth more than anywhere else.
6. **Damage increased** (L1). Up to +200 at full value; past that each point counts half. Stop near +200 to +300.
7. **Crit chance and crit damage** (outside the layers). Chance to 50 % (cap), damage to ×3.0 (cap). With 13 rolls a
   second, the average holds.
8. **Health leech** (none: sustain). +6 % to +10 %: a share of a very high damage rate. More is overkill unless the foe
   hits hard.
9. **Accuracy and resistance penetration** (none: reach). Accuracy until evade minus accuracy is near 0 (Wind debuffs do
   most of it); penetration against Physical or Force walls.
10. **Gear attack** (L3, cap 250). The fan and needle reach about 170; do not trade art speed or on-hit lines for more.

## Upgrades to look for

Your shopping list, core first. "Core" makes the gale work; "strong" makes it top-end; "nice" smooths the edges.

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Winnowing Wind Scripture and its six hit arts | Effect (art kit) | Six cheap, quick arts that grant and lay Wind stacks: the whole channel | Công pháp, layers 1–10 | Not in the game yet (staged: winnowing-wind-scripture, chaff-needle, husk-splitting-cut, winnowing-toss, sieve-palm, threshing-rain, empty-husk-gust) | Core |
| Art speed [Wind] and universal | Modifier | +310 % before the fight: all arts at the 0.5 s floor from the first stroke | Tree notables (+20 [Wind], +13.3), scripture layer 5 (+40), Phong Đạo Cuồng Phong lines, fan (+30), Tật affix | Tree and key in the game (designed); Way, scripture, fan, affix staged | Core |
| Linh lực on hit | Modifier | +0.5 % of maximum per hit, paid 13 times a second: half your income | Tree family notable (+0.29), fan (+0.15), scripture layer 7 (+0.10), Hồi Khí affix | Key in the game (designed); fan, scripture, affix staged | Core |
| Art cost −50 % | Modifier | Halves every stroke; the cap | Tree notables (−20 [Wind], −13.3), scripture layer 11 (−20) | Key in the game (designed); scripture staged | Core |
| Slipstream (Thuận Phong) | Effect | Surplus art speed divides each art's cost by up to 3: the bill falls from 15 % to about 6.6 % a second | Phong Đạo Cuồng Phong major; scripture layer 9 | Not in the game yet (staged: slipstream) | Core |
| Breath Between Blows (Gian Tức) | Effect (keystone) | +7.2 % of maximum linh lực a second (6 firings a pulse): the Kết Đan bill | Meridian Map keystone, Wind land | Not in the game yet (staged: breath-between-blows) | Core at Kết Đan |
| Granary-Mother's Fan (Thương Mẫu Phiến) | Modifiers and an Effect | +1 art slot (+2 hits a second), +30 % art speed, +0.15 % linh lực on hit, +6 % leech, Steady Breath | Named artifact | Not in the game yet (staged: winnowing-fan) | Strong |
| Wind stack effect and duration | Modifier | More art speed per stack (Slipstream) and more evade shred | Phong Đạo Phiêu lines | Key in the game (designed); Way staged | Strong |
| Light Chaff (Khinh Khang) | Modifier (L2 more, [quick, cheap]) | +60 and +40 ×2 to your thinnest layer | Scripture layer 3; Phong Đạo notables | Not in the game yet (staged: light-chaff) | Strong |
| Overheat (Quá Nhiệt) | Effect | +30 L5 on every art once compile art speed passes +310 % | Phong Đạo minor, Meridian Map | In the game (designed; not built) | Strong |
| Glass Meridians (Lưu Ly Kinh Mạch) | Effect (trade) | +40 % art speed for −25 % health | Meridian Map keystone | In the game (designed; not built) | Strong |
| Eruption (Phún Trào) | Effect | +25 L5 when six arts share one timer | Phong Đạo notable | Not in the game yet (staged: eruption, arts-fired-this-instant) | Strong |
| Steady Breath (Bình Tức) | Effect | +12 L5 while your pool is half full or more: all fight | The fan | In the game (designed); fan staged | Strong |
| Health leech | Modifier | Heals a share of a very high damage rate; your main health sustain | Fan (+6), Hấp Huyết affix | Key in the game (designed); fan and affix staged | Strong |
| Echo (Hồi Âm) and Trigger limit (Dư Hưởng) | Effect and rare cap shift | About 3 more hits a second; a 7th trigger firing a pulse | Echo: Way, technique or item host; Trigger limit: Phong Đạo capstone | Echo in the game (designed); Trigger limit staged | Nice |
| Still Water (Tĩnh Thủy) | Effect | Surplus linh lực heals at half | Meridian Map keystone | In the game (designed; not built) | Nice |
| Threshing Floor (Cốc Trường) region | Modifiers | Art speed, art cost, linh lực on hit +0.19, art speed [quick] +20 | Tree region in the Wind land (an idea for the tree rework) | Not in the game yet (staged: threshing-floor-cluster) | Nice |
| Nine Rods Array and Iron-Sand Hand Bath | Modifier (L4) | +80 and +50 (Physical arts) in foreseen fights | Formation; coating | Not in the game yet (staged: nine-rods-array, iron-sand-hand-bath) | Nice |
| Basic attack speed | Modifier | Basic attack every 0.5 s: +1 hit a second | Tree or technique lines | Not in the game yet (staged: basic-attack-speed) | Nice |
| Resistance penetration [physical], [force] | Modifier | Through a Physical or Force resistance wall | Tree notables, affixes | In the game (designed) | Nice |

## Realm by realm

- **Trúc Cơ (Foundation Establishment):** learn the scripture's first arts. Chaff Needle and Husk-Splitting Cut on a plain
  Wind caster. You are not yet at the floor and should not try: the bill is not solved.
- **Kết Đan (Core Formation):** five slots plus the fan's. About +150 % art speed before the fight puts only Chaff Needle
  on the floor at once; the rest reach 0.5 s in about 3 seconds as Wind stacks rise. Breath Between Blows pays the bill
  (7.2 % a second) while Slipstream is still out of reach. Take Glass Meridians here.
- **Nguyên Anh (Nascent Soul):** six slots plus the fan's. With +310 % before the fight, all six arts fire together at
  0.500 s and every half second after. Slipstream (scripture layer 9 or the Way) now carries the bill, so the trigger
  budget can go to Echo. Sweeping the Floor joins at layer 12.
- **Past Nguyên Anh:** the scripture is Địa giai and stops at Nguyên Anh. Hóa Thần needs a Thiên giai copy, which does not
  exist yet.

## How it plays

**Art order (slot order matters only for who pays first in a short pool, and for the hit order):**

1. Chaff Needle
2. Winnowing Toss
3. Threshing Rain
4. Husk-Splitting Cut
5. Sieve Palm
6. Empty-Husk Gust
7. Sweeping the Floor (guard: you are Silenced or under Heavy Breath)

The stack-granting arts go first, so in a lean moment the arts that keep the gale fast are paid before the ones that only
deal damage.

**Loadout:** a Common Ward in your ward slots (your pool stays high, so the drain ward always has linh lực). Against an
Ice foe, add Clear Heart Ward (Thanh Tâm Chú). Artifacts: the fan, a needle, and ward gear. Before a foreseen fight: the
Nine Rods Array and the Iron-Sand Hand Bath.

**The signature moment.** A bell-ward abbot opens his log: at 0.500 s, six Golden Bell fees in one line; at 1.000 s,
seven; by 2.0 s his linh lực bar is empty, Golden Bell reads "Down (unpaid)", and every hit after that has no ward line
at all. Your own bar has not moved.

## What beats it

- **The frost: an Ice-stack applier, worse with Heavy Breath (Trọng Tức).** Every Ice stack on you adds 3.9 % to every art
  cost, with no cap. At 40 stacks your costs are ×2.56 and the bill passes your income. Sweeping the Floor clears Heavy
  Breath but not Ice stacks: that is how the scripture's founder died. Adapt: Clear Heart Ward (it removes a quarter of
  every debuff batch on you each pulse), more linh lực on hit, and drop to four or five arts so the bill shrinks.
- **A Physical or Force resistance wall** (150 points or more against the group). Every art you have is Physical or Force.
  Adapt: resistance penetration [physical] and [force]; it is cheap.
- **A Silence naming Wind arts.** All six hit arts go quiet for 3 pulses. Sweeping the Floor has no Wind tag and clears it.
- **A heavy hitter that ends the fight before the gale rises.** Glass Meridians leaves you with three quarters of your
  health. Against a top-end alpha strike, carry Unyielding Breath (Bất Khuất) or a shield ward.
- **Soul attacks.** They skip every ward and take a share of your linh lực and health. Small between equal souls; a
  Soul-Guarding Lamp answers a soul specialist.
- **Not a counter: block.** Flat block takes a fixed amount from every hit, after resistance, which hurts many small hits
  at low power. At Nguyên Anh a hit of yours is about 15,000; a ward that stops about 80 % leaves about 3,000, and a thể
  tu's block (237, or 372 with Iron Shirt) takes 8 to 12 % of that. It slows you; it does not stop you.
- **Not a counter: evasion.** Your Wind debuffs take a 40 % evade cap to near 0 within two or three seconds.

## Not in the game yet

Every staged piece this build needs, by its ID in the staging catalogue:

- `slipstream`: Slipstream (Thuận Phong), the identity Effect.
- `art-cost-dampened`: art cost accepting the "dampened" op, which Slipstream needs.
- `light-chaff`: Light Chaff (Khinh Khang), L2 "more" for quick, cheap arts.
- `winnowing-wind-scripture`: the Winnowing Wind Scripture (Dương Khang Phong Quyết).
- `chaff-needle`, `husk-splitting-cut`, `winnowing-toss`, `sieve-palm`, `threshing-rain`, `empty-husk-gust`,
  `sweeping-the-floor`: its seven arts.
- `winnowing-fan`: Granary-Mother's Fan (Thương Mẫu Phiến).
- `gale-affixes`: the Tật, Hồi Khí and Hấp Huyết affix rows.
- `breath-between-blows`: Breath Between Blows (Gian Tức), first listed in the by-root Wind builds.
- `trigger-limit`: Trigger limit (Dư Hưởng), from the tree modifier catalogue's rare one-offs.
- `phong-cuong-phong-gale`: the Phong Đạo Cuồng Phong and Phiêu pieces.
- `threshing-floor-cluster`: the Threshing Floor (Cốc Trường) tree region idea.
- `hit-landed-definition`: what counts as "a hit landed" for on-hit sustain.
- Reused from other builds: `eruption`, `arts-fired-this-instant`, `nine-rods-array`, `iron-sand-hand-bath`,
  `basic-attack-speed`, `preparation-fight-payload`.

## Changes the game would need

- **Art cost accepts the "dampened" op.** `design/gdd/combat.md` Formulas E (the art cost formula gains `÷ (1 + D / 100)`)
  and `design/gdd/modifiers.md` Stat List row "Art cost" (ops I → I, D). Rule 6a already names dampened as the shape for
  anything that must never reach 0; art cost reduction today stops at a hard 0.5. Slipstream needs it.
- **Trigger limit as a rare cap shift.** `design/gdd/combat.md` Formulas G (`trig_cap` 6 per side) and the Modifier
  System's rare table (`design/gdd/modifiers.md`): +1 firing between pulses, from keystones, named items and Way capstones
  only. The tree catalogue lists the idea; no rule allows it today.
- **What "a hit landed" means for on-hit sustain.** `design/gdd/modifiers.md` rule 1 (the sustain exception) and AC-MD-33:
  say whether `linh_luc_on_hit_pct` and leech count trigger free hits and hits that block reduced to 0. This build's
  income depends on the answer.
- Reused, already proposed by other builds: "arts you fired this instant" in `design/gdd/effects.md` rule 5 (Eruption).

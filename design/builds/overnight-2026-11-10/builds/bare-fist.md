# The Brimming Hand (Mãn Tức Quyền)

You never cast a single art: your whole linh lực pool is ward, your art slots hold more wards, and every breath your full pool cannot hold goes into your next punch.

## Why it works

Four rules of the fight make this build possible.

1. **The basic attack is free and always runs.** Every cultivator has a basic attack (a Physical hit on its own 1-second timer) that costs nothing and fires whatever else happens. Art speed never touches it, and almost nothing in the game scales it. This build scales nothing else: a flat bonus to its coefficient (**Heavy Knuckle, Trọng Quyền**), a faster timer (**basic attack speed, Khoái Quyền**), and every damage layer scoped to it.
2. **Linh lực is mana and ward in one pool.** Every art a caster fires is linh lực its ward no longer has. You fire none, so your ward pays only for what it stops. Your **enabler, the Closed Hand Vow (Bế Thủ Thệ)**, makes that a promise: with no damaging art slotted, your ward efficiency is +100, so the ward costs a third less to run.
3. **Art slots can hold wards, and every slotted ward is up at once.** You put shields and auras where your arts would be, layered on top of the wards in your free ward slots.
4. **Regeneration a full pool cannot hold is "overflow", and an Effect can read it.** Casters are never full, so for them it is nothing. You are full almost all the time. **Stored Breath (Tàng Tức)** banks that overflow and adds it to your next punch: +0.10 coefficient for every 1 % of your maximum linh lực that overflowed (up to +1.2). Every point your ward does *not* spend becomes fist. That is the engine: ward strength and ward efficiency (which make the ward cheaper) and regeneration are also your damage.

**The numbers.** All are first guesses, worked by hand from the current Combat and Defence rules at Nguyên Anh (Nascent Soul) in a prepared fight.

- Your punch: coefficient 2.2, every 0.667 s (basic attack speed +50 %), at **M 188.6** with a full pool (L1 ×3.50, L2 ×3.80, L3 ×3.50, L4 ×2.50, L5 ×1.62), crit 45 % at ×2.1. Stored Breath adds about **+0.95** to one punch each second. Your damage per second is about **0.72 of the top-end reference caster's**, at zero cost, behind 4,766 points of ward shields. At Hóa Thần it is **0.96**.
- **Against a typical cultivator** of your realm: the first punch (0.667 s) deals about 6,900 through their ward and breaks it. One punch.
- **Against the top-end reference caster:** your shields soak their first two hits, your second punch carries the banked breath, and you win at **1.33 s** in about half the rolls and at **2.0 s** in nearly all the rest, with about a third of your health left.
- **The identity test:** without Stored Breath the same race always ends at 2.0 s, and the fist does 22 % less damage per second whenever the pool is full.
- Caveat: the skill's fight script (`fight_calc.py`) still runs on rules from before the #44 economy revision (31 of its 60 constants are out of date), so its results (it calls both races at 1.0 s) are only observations. A current-rules script, `bare-fist.sim.py`, sits next to this guide but has not been run yet.

## What to look for

In the order you will meet them.

1. **Spiritual root (linh căn): Earth (Thổ)**, single element, purity 80 or more. Your punch carries the Earth tag (through Elemental Fist, below), so Earth damage lines count for it; Earth buff stacks make you take less Physical damage, more so at high purity. Earth-Metal also works (Metal stacks add Physical damage). *In the game.*
2. **Talents:** Physique (căn cốt) high, for health, block and your body technique. Comprehension (ngộ tính) good, because your best passives sit deep in the technique. Enough divine sense (thần thức) to reach 1.75 × your realm's reference: that opens one more free ward slot. *In the game.*
3. **Đạo:**
   - **Thể Đạo** · *Bất Diệt Thể* (the Undying Body), facet **Không Thủ** (Bare Hands). *In the game's Way catalogue; its graph is not drawn yet.* Nodes to buy: Heavy Knuckle notables (+0.5 coefficient) and basic attack speed notables (+15 %), Worn Knuckles (+40 "more" to the basic attack), Quiet Channels, and Stored Breath as the facet's big Effect. *Not in the game yet (staged: the-khong-thu-fist).*
   - Second Way: **Thổ Đạo** · *Bất Động Sơn* (Unmoving Mountain), facets **Trần Bích** (Dust Wall) for Settled Dust and **Sơn Thể** (Mountain Body) for block. *Not in the game yet (staged: tho-tran-bich-dust).*
4. **Công pháp:**
   - Main: a generated Earth method at first, then **Hậu Thổ Địa Quyết**, then **Hậu Thổ Thiên Kinh**. They add linh lực and ward strength, which is all you need from a main method. Their missing arts cost you nothing. *In the game.*
   - Auxiliary: **Uncarved Stone Fist (Phác Thạch Quyền)**, a body technique, Huyền giai to Kết Đan, and its Thiên giai copy **Phác Thạch Quyền Kinh** to Hóa Thần. It teaches no art. It holds Heavy Knuckle, Worn Knuckles, basic attack speed, Stored Breath and the Closed Hand Vow. *Not in the game yet (staged: uncarved-stone-fist).*
   - Second auxiliary: **Kim Cang Thể**, then **Long Tượng Công** (health, ward strength, damage). *In the game.*
5. **Arts:** none. You carry wards instead (below). The wards themselves are *in the game (designed in the Defence GDD's ward catalogue; not built yet)*: Common Ward, Qi-Scattering Robe, Fire-Shunning Veil, Mountain Screen, Thousand-Layer Cloud, Iron Shirt, Clear Heart Ward, Soul-Guarding Lamp.
6. **Items.**
   - **Quarry-Master's Knuckle Rings (Thạch Tượng Quyền Hoàn)**: your weapon. Heavy Knuckle +0.3, basic attack speed +15 %, artifact attack +30 %, and it carries Steady Breath and Settled Dust. Light on divine sense, so the rest can go to ward gear. *Not in the game yet (staged: quarry-knuckle-rings).*
   - A second weapon (a generated seal, `an`), two ward-gear pieces (a shield and a bell) and body armour (`giap`). Ward gear raises ward strength and efficiency, which here is also damage. *In the game.*
   - For prepared fights: **Iron-Sand Hand Bath (Thiết Sa Dục Thủ)** coating, **Stone-Marrow Pill (Thạch Tủy Đan)**, **Nine Rods Array (Cửu Can Trận)** formation. *Not in the game yet (staged: iron-sand-hand-bath, stone-marrow-pill, nine-rods-array).*
7. **Enabler: the Closed Hand Vow (Bế Thủ Thệ)**, on the Uncarved Stone Fist (Huyền layer 9, Thiên layer 12). *Not in the game yet (staged: closed-hand-vow).*

## The enabling Effects

- **Closed Hand Vow (Bế Thủ Thệ)**, the enabler. While no damaging art is slotted, ward efficiency +100. In exchange you may never slot a damaging art, a damaging talisman or a cast ward. *Why:* it turns "I cast nothing" into a cheaper ward: smaller drain bills, smaller reservations, and so more overflow for Stored Breath.
- **Stored Breath (Tàng Tức)**, the identity. Overflow (regeneration lost to a full pool) is banked; your next basic attack that lands adds +0.10 coefficient per 1 % of maximum linh lực banked, up to +1.2, then the bank empties. *Why:* it is the build. It makes regeneration, ward strength and ward efficiency into punch weight, and it is why a full pool matters.
- **Quiet Channels (Tĩnh Mạch).** +0.5 percentage points of linh lực regeneration for each art slot holding no art (empty or a ward), up to +3. *Why:* it ties the slots to the engine: more quiet slots, more breath, heavier punches.
- **Settled Dust (Lắng Trần).** When your punch lands, you gain one Earth buff stack for 4 s (Physical damage taken 1.1 % lower per stack). *Why:* an Earth root normally needs arts to make stacks; this gives you about six from punching alone.
- **Steady Breath (Bình Tức)**, scoped to the basic attack: +12 L5 while your linh lực is at 50 % or more. *In the game (designed in the Effects GDD; not built yet).* *Why:* a pool you never spend is nearly always above half.
- **Full Sea (Mãn Hải)**, a tree keystone idea: +30 L5 while your linh lực is at 80 % or more. *Not in the game yet (an idea in the tree catalogue; size is this build's guess).* *Why:* your second L5 source, and the reason not to let the ward bill too much.
- **Bare Rack (Không Giá).** +5 L5 to the basic attack per empty art slot, up to +20. *In the game (designed in the Effects GDD; not built yet).* *Why:* once your ward is strong enough (Nguyên Anh duels, Hóa Thần), empty slots pay.
- **Elemental Fist (Ngũ Hành Quyền).** Your basic attack carries your root's element tag (Earth). *In the game (designed in the Effects GDD; not built yet).* *Why:* Earth damage lines from Thổ Đạo then count for the punch.
- **Still Water (Tĩnh Thủy).** Overflow also heals at half its amount. *In the game (designed in the Effects GDD; not built yet).* *Why:* it reads the same overflow as Stored Breath, so a full pool both punches and heals.
- **Unyielding Breath (Bất Khuất).** Once a fight, a blow that would put you Down leaves you at 1 health; your maximum health is 15 % lower. *In the game (designed in the Effects GDD; not built yet).* *Why:* in a race against a top-end caster, it is one more punch.

## Modifiers to stack

Most important first.

1. **Linh lực regeneration** (`linh_luc_regen_pct`; flow). Every point of regeneration that overflows is up to +0.1 coefficient a second. It runs on a falling curve (each point is worth a little less), so stop pushing it once regeneration is about 9–10 % of your maximum per pulse (around +9 pp of bonus).
2. **Ward efficiency and ward strength** (`ward_efficiency_pct`, `defense_pct`, ward gear; defence and flow). They cut what the ward pays per hit, which is overflow you keep. No cap. Stop when your drain bill per enemy hit is well under one pulse of regeneration.
3. **Heavy Knuckle** (`basic_coef_add`; base, before any layer). The biggest lever, because it is outside the layers. No cap; the sources are few.
4. **Worn Knuckles and other "more" for the basic attack** (L2). Stop at L2's cap of +300.
5. **Weapons** (L3). Stop at +250.
6. **Preparation**: Hand Bath, Stone-Marrow Pill, Nine Rods Array (L4). Stop at +150; two of the three get you there.
7. **Basic attack speed** (timing). More punches, but each one meets the enemy's flat block, and Stored Breath still feeds one punch a second. Stop at +100 % (0.5 s, the floor).
8. **Crit chance and crit damage.** Stop at 50 % and ×3.0.
9. **Basic attack damage, Earth damage, plain damage** (L1). Past +200 each point counts half; past +400 nothing.
10. **Physical penetration and accuracy** (reach). Enough to answer a Physical-warded foe or an evader you expect.

L5 is your thin layer: Steady Breath, Full Sea and Bare Rack give at most +62 of its 100. Accept it.

## Upgrades to look for

Your shopping list, core first. "Core" pieces make the build work at all; "strong" pieces turn a working build into a top-end one (the Nguyên Anh race win, then Hóa Thần parity); "nice" pieces patch gaps or add margin. Sizes are first guesses.

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Stored Breath (Tàng Tức) | Effect | The identity: banked overflow becomes up to +1.2 punch coefficient (about +0.95 at Nguyên Anh) | Uncarved Stone Fist (Huyền layer 5, Thiên layer 8); Thể Đạo Không Thủ major node | not in the game yet (staged: stored-breath) | core |
| Closed Hand Vow (Bế Thủ Thệ) | Effect (enabler) | Ward efficiency +100 while no damaging art is slotted: cheaper ward, more overflow | Uncarved Stone Fist (Huyền layer 9, Thiên layer 12) | not in the game yet (staged: closed-hand-vow) | core |
| Heavy Knuckle (Trọng Quyền) | Modifier | Flat coefficient for the punch, outside every layer: the biggest single lever (+0.3 / +0.6 technique, +0.5 Đạo notable) | Uncarved Stone Fist; Thể Đạo Không Thủ notables; knuckle rings; Porter's Shoulder | not in the game yet (staged: heavy-knuckle, basic-coef-add-key) | core |
| Linh lực regeneration | Modifier | More overflow each pulse, so heavier punches; stop near +9 pp | Tree nodes (small +0.15 %, notable +1 %); Porter's Shoulder | in the game (`linh_luc_regen_pct`) | core |
| Ward efficiency and ward strength | Modifier | Cheaper bills and a stronger ward: every point unspent is punch | Tree nodes; ward gear (shield, bell); Hậu Thổ methods | in the game (`ward_efficiency_pct`, `defense_pct`) | core |
| Worn Knuckles (Chai Quyền) | Modifier ("more", L2) | +40 / +80 "more" damage on the punch; the largest layer you can reach | Uncarved Stone Fist (Huyền layer 7, Thiên layer 4); Thể Đạo Không Thủ notables | not in the game yet (staged: worn-knuckles) | core |
| Basic attack speed (Khoái Quyền) | Modifier | Faster punch timer (0.667 s at +50 %); you strike first at Nguyên Anh | Uncarved Stone Fist (+20); Thể Đạo notables (+15); knuckle rings (+15) | not in the game yet (staged: basic-attack-speed) | core |
| Quiet Channels (Tĩnh Mạch) | Effect | +0.5 pp regeneration per art slot holding no art, up to +3 | Thể Đạo Không Thủ minor node; Porter's Shoulder (farthest notable) | not in the game yet (staged: quiet-channels) | strong |
| Quarry-Master's Knuckle Rings (Thạch Tượng Quyền Hoàn) | Named item | Heavy Knuckle +0.3, speed +15 %, weapon attack +30 %; carries Steady Breath and Settled Dust; cheap in divine sense (thần thức) | Named item, new base `quyen_hoan` | not in the game yet (staged: quarry-knuckle-rings) | strong |
| Steady Breath (Bình Tức) | Effect (L5) | +12 L5 on the punch while linh lực is at 50 % or more | Knuckle rings | in the game (Effects GDD; not built yet) | strong |
| Full Sea (Mãn Hải) | Effect (tree keystone) | +30 L5 while linh lực is at 80 % or more; your second L5 source | Tree keystone | not in the game yet (an idea in the tree catalogue, not staged) | strong |
| Bare Rack (Không Giá) | Effect | +5 L5 per empty art slot, up to +20; pays in the duel loadout and at Hóa Thần | Tree or Đạo | in the game (Effects GDD; not built yet) | strong |
| Elemental Fist (Ngũ Hành Quyền) | Effect (keystone) | The punch carries the Earth tag, so Earth damage lines and Thổ Đạo notables count | Tree keystone | in the game (Effects GDD; not built yet) | strong |
| Settled Dust (Lắng Trần) | Effect | One Earth buff stack per landed punch (4 s, about six at once): less Physical damage taken | Thổ Đạo Trần Bích; knuckle rings | not in the game yet (staged: settled-dust, tho-tran-bich-dust) | strong |
| Weapon artifacts (L3) | Modifier | Artifact attack up to the +250 cap: the knuckle rings plus a generated seal (`an`) | Item affixes and bases | in the game (`artifact_attack_pct`) | strong |
| Stone-Marrow Pill (Thạch Tủy Đan) | Modifier (L4, prepared) | +60 "more" on the punch for one prepared fight | Pill, prepared fights only | not in the game yet (staged: stone-marrow-pill) | strong |
| Nine Rods Array (Cửu Can Trận) | Modifier (L4, prepared) | Ringing Ground +80 on hits that carry `art`, which the punch does | Formation, prepared fights only | not in the game yet (staged: nine-rods-array) | strong |
| Iron-Sand Hand Bath (Thiết Sa Dục Thủ) | Modifier (L4, prepared) | +25 to +50 on body hits; two of the three preparations reach the +150 cap | Coating, prepared fights only | not in the game yet (staged: iron-sand-hand-bath) | strong |
| Crit chance and crit damage | Modifier | Up to 45–50 % and ×2.1–3.0 on every punch | Tree nodes (chance +0.4 % / +2.5 %, damage +1.5 % / +10 %); gear | in the game (`crit_chance_pct`, `crit_damage_pct`) | strong |
| Still Water (Tĩnh Thủy) | Effect | The same overflow also heals at half: a full pool punches and heals | Tree or Đạo | in the game (Effects GDD; not built yet) | strong |
| Unyielding Breath (Bất Khuất) | Effect (keystone) | Once a fight, a killing blow leaves you at 1 health: one more punch in a race (−15 % health) | Tree keystone | in the game (Effects GDD; not built yet) | strong |
| Mirror Ward (Kính Hộ) | Effect (keystone) | A share of blocked damage is stored and released with your next hit; defence that punches | Tree keystone | in the game (a rule-bender idea in the tree catalogue; not built yet) | nice |
| Basic attack damage (Bình Kích), Earth damage, plain damage | Modifier (L1) | +2 % / +12 % lines on the punch; past +200 each point counts half | Tree nodes; Thổ Đạo | in the tree catalogue as designed rows (Basic attack damage and Earth damage, not built yet); plain damage in the game | nice |
| Physical penetration and accuracy | Modifier (reach) | Answers Physical-warded foes and evaders | Tree nodes; Thổ Đạo | in the game (`accuracy_pct`; Physical penetration is partly designed) | nice |
| Porter's Shoulder (Phu Kiên) cluster | Cluster | Eight acupoints of Heavy Knuckle, regeneration, speed and Quiet Channels, sealed by the technique | Hidden tree cluster, opened by the Uncarved Stone Fist | not in the game yet (staged: porters-shoulder-cluster) | nice |
| Twin Wards (Song Hộ) | Effect (keystone) | A second ward at half strength, breaking "one ward at a time"; more layers to soak a top-end volley | Tree keystone | in the game (a rule-bender idea in the tree catalogue; not built yet) | nice |

**What turns a working build into a top-end one:** Stored Breath with Closed Hand Vow is the working build. The top-end jump is the knuckle rings, Full Sea, Bare Rack and the three preparations, because they take your punch from about a quarter of a top-end caster's damage (Kết Đan) to a race you win (Nguyên Anh). Add Unyielding Breath and Still Water for the margin.

## Realm by realm

- **Luyện Khí (Qi Refining).** A slow, safe brawler. One ward slot (Common Ward), two shields in the art slots, the Huyền Uncarved Stone Fist. Your ward pays for most of what your pool regenerates, so Stored Breath adds little yet. You beat a typical cultivator in about 30 s with half your health left.
- **Trúc Cơ (Foundation Establishment).** The Closed Hand Vow arrives (Huyền layer 9) and the ward gets cheap enough to overflow. Add Clear Heart Ward against poison and curses. Get the knuckle rings.
- **Kết Đan (Core Formation).** Every art slot holds a ward (two shields, Iron Shirt, Clear Heart Ward, Soul-Guarding Lamp) and a second free ward slot takes Qi-Scattering Robe. You end ordinary fights in two punches (about 1.5 s). A top-end caster still outraces you here: your damage is about a quarter of theirs. You are a late bloomer.
- **Nguyên Anh (Nascent Soul).** The Thiên giai copy, Full Sea, basic attack speed +50 %. You strike first (0.667 s) and win the race against the top-end reference. This is the build's defining realm.
- **Hóa Thần (Deity Transformation).** Five ward slots (Clear Heart Ward moves into one), four empty art slots for Bare Rack's cap, speed +70 %. Your damage per second matches a top-end caster's, and you pay nothing for it.

## How it plays

- **Loadout, the "road" set (for blind and unknown fights):** free ward slots Common Ward, Qi-Scattering Robe, Fire-Shunning Veil, Soul-Guarding Lamp; art slots Mountain Screen, Thousand-Layer Cloud, Iron Shirt, Clear Heart Ward, two empty. You block about 461 points per hit and dodge about 31 % of hits.
- **Loadout, the "duel" set (a known top-end foe, prepared):** drop Iron Shirt and Clear Heart Ward. Together they hold back about a fifth of your pool (0.29 reserved against 0.085), and against huge hits you want the whole pool as ward. Four empty slots fill Bare Rack.
- **Slot order:** shields first (they soak in slot order), then the rest.
- **There is no art order.** The fight runs itself: wards up at t = 0, a punch every 0.667 s, a heavier punch right after each pulse.
- **The signature moment:** a top-end caster's first art lands on a wall of shields, and a breath later a single bare punch, heavier for everything you did not spend, ends the fight. The fight log reads "Stored Breath +0.95 → basic coefficient 3.15".

## What beats it

- **A drainer with staying power** (Qi Disruption, a boss or a big pool). It burns your linh lực faster than you breathe: no overflow, no Stored Breath, and soon no ward. This is how the technique's founder died. *Adapt:* keep Qi-Scattering Robe in a ward slot (its Force resistance cuts the burn), keep Clear Heart Ward (it cleanses a quarter of every debuff batch each pulse), and kill it before its second batch lands. Against an ordinary drainer you usually do.
- **An evader at the cap (40 %).** Two punches in five miss; the bank waits for the next punch that lands. *Adapt:* accuracy.
- **A soul attacker.** Soul hits skip every ward you carry. *Adapt:* Soul-Guarding Lamp, and enough health.
- **A Physical-warded foe** (at least 150 extra points against Physical). About 15 % less damage at the top end. *Adapt:* Physical penetration, or plain conversion lines that move part of the punch to another damage type.
- **A top-end caster before Nguyên Anh.** Its first volley outraces you at Kết Đan. *Adapt:* avoid prepared duels with top-end casters until Nguyên Anh, or fight them where your shields have time to matter.

## Not in the game yet

- Stored Breath (staged: stored-breath)
- Closed Hand Vow (staged: closed-hand-vow)
- Quiet Channels (staged: quiet-channels)
- Settled Dust (staged: settled-dust)
- Heavy Knuckle and the `basic_coef_add` stat (staged: heavy-knuckle, basic-coef-add-key)
- Basic attack speed, `basic_speed_pct` (staged: basic-attack-speed)
- Worn Knuckles (staged: worn-knuckles)
- Uncarved Stone Fist, Huyền and Thiên giai (staged: uncarved-stone-fist)
- Quarry-Master's Knuckle Rings and the `quyen_hoan` base (staged: quarry-knuckle-rings)
- Stone-Marrow Pill (staged: stone-marrow-pill)
- Iron-Sand Hand Bath (staged: iron-sand-hand-bath)
- Nine Rods Array (staged: nine-rods-array)
- Thể Đạo Không Thủ nodes (staged: the-khong-thu-fist)
- Thổ Đạo Trần Bích nodes (staged: tho-tran-bich-dust)
- Porter's Shoulder hidden cluster (staged: porters-shoulder-cluster)
- A payload that waits for your next punch (staged: held-payload)
- Full Sea (an idea in `design/quick-specs/tree-modifier-catalogue.md`, not staged)

## Changes the game would need

1. **A basic attack speed stat.** `design/gdd/combat.md` rule 13 says art speed applies to arts only and the basic attack runs on `basic_cooldown`; Formulas A2 fixes `basic_cooldown` at 1 s. Add `basic_speed_pct`: the basic attack's timer is `basic_cooldown ÷ (1 + basic_speed_pct / 100)`, never below `cooldown_min`; the companion keeps its timer. The Modifier System's "Basic attack speed" row (`design/gdd/modifiers.md`, Stat List, today Pending) gets the key.
2. **A flat basic-coefficient stat.** `design/gdd/combat.md` Formulas C reads `basic_coef` (1.0) as data. Add `basic_coef_add` to the Stat List in `design/gdd/modifiers.md`; the basic attack's coefficient becomes `basic_coef + Σ basic_coef_add`. The art lint keeps reading the data value, so arts do not grow with it.
3. **Effects whose payload waits for your next action.** `design/gdd/effects.md` rule 8 lets an Effect apply while a condition holds or on an event, but not "until your next basic attack". Add a held payload: banked by its trigger, spent by the owner's next named event, capped by the Effect.
4. **Read linh lực shares against the usable maximum.** `design/gdd/effects.md` rule 5 and the guards of `design/gdd/combat.md` rule 13 read linh lực "as a share" without saying of what. With more than 20 % of the pool reserved, a share of the full maximum can never reach 80 %, which would quietly switch off Full Sea and Steady Breath. Say it is the usable maximum, as start shares already are (`design/gdd/combat.md` rule 3, `design/gdd/combat-defence.md` rule 10).

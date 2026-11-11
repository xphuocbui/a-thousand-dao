# Raising the Tiger (Dưỡng Hổ)

Your tiger does all the killing; you never lift a hand, you only feed it fire, bind its wounds and stand behind it, and if it falls you are harmless until it rises.

## Why it works

Five rules of the fight make this build possible. The numbers come straight from the Combat GDDs; numbers on new pieces are first guesses.

1. **A companion (linh thú) hits for free.** A spirit beast attached to you strikes once every second (`basic_cooldown`), costs no linh lực, and uses every one of your damage layers (L1 to L5) on its own tags. Its coefficient is your beast's power share over your realm's power base, capped at **1.0**, the size of a basic attack (`c_comp_cap`, Combat Formulas J). It cannot crit. That cap is easy to reach: a beast of your own realm already gives about 0.5, so the game is not "a bigger beast", it is **more bites, more layers, and a use for the power past the cap**.
2. **Your enabler gives the beast your hand.** The **Shared-Heart Contract (Đồng Tâm Khế)** turns your own basic attack into a second strike by the tiger (**Lent Hand**). Two timers. Then **Bonded Spirit (Linh Khế)** lets your art speed shorten both timers, down to the game's floor of 0.5 s (`cooldown_min`). At +100 % art speed the tiger bites **four times a second**, still for free.
3. **Your whole economy becomes the tiger's damage.** You may slot no art that hits, ticks or curses the enemy, so your linh lực goes into wards and into buffs. Fire buff stacks give **+1.2 % damage dealt each** (× 1 + 0.002 × your Fire purity, so ×1.16 at purity 80). **Feed the Fire (Đầu Hỏa)** buys 12 stacks for 5 s for 2 % of your pool, so **every 1 % of your maximum linh lực per second you pour into it holds about 30 Fire stacks (+36 %)**. Spare regeneration is damage.
4. **The power you cannot use becomes damage.** **Straining Leash (Căng Xích)**, the build's identity: for every 0.1 of your beast's share above the 1.0 cap, its hits deal +5 more (layer L5), up to +50, half of L5's cap. Tame a tiger stronger than you, or double a weaker one with Beast Soul Union, and nothing is wasted.
5. **The beast fights in the open.** Under the Contract your tiger has a health bar of **half your maximum health**, and **30 % of the damage that reaches your health from hits lands on it instead**. Your heals and shields can reach it. That is what "protect the beast" means here: if it goes Down, your side deals no damage at all until it rises (by itself after 8 s, or at once with **Rouse**).

**The numbers at Nguyên Anh (Nascent Soul), top-end, prepared fight.** Your fight unit there is U = 100. The tiger's layers come to about **M 203** (L1 ×3.66, L2 ×4.00, L3 ×3.50, L4 ×2.10, L5 ×1.89), against the top-end reference's 256. One bite: 100 × 1.0 × 203 ≈ **20,300** before the enemy's defence; with 100 Fire stacks it is about **48,700**, four times a second. Your heal, Old-Tree Sap, restores 100 × 3.78 × 4 = **1,512** and gives back its linh lực when it heals. In a blind fight (no pill) M drops to about 136.

*No combat simulator was used for this build (user decision 2026-11-11): these are the formulas read by hand, not a fight result.*

## What to look for

In the order you will meet them.

1. **Spiritual root (linh căn): Wood and Fire (Mộc, Hỏa)**, Fire purity 80 or more, Wood 60 or more. Fire purity powers every Fire buff stack you hold; Wood is your tiger's element and your main technique's. Wood generates Fire, so the technique runs in harmony. *In the game.*
2. **Talents:** **Soul strength (thần hồn)** high: it raises your chance to tame a beast and how many you can keep, and the chase of this build is taming a beast stronger than you. **Physique (căn cốt)** good: your tiger's health bar is half of yours. Comprehension fair, for the technique's deep layers. **Craft: Beast Taming (Ngự thú)**, +5 % tame chance a level. *In the game.*
3. **Your beast: a Moss-Striped Tiger (Đài Văn Hổ)**, a Wood spirit beast whose stripes are living moss. Its bite carries the Wood tag and lays a Poison stack. Tame a cub at Trúc Cơ, or a grown one a realm above you later. Feed it every year. *Not in the game yet (staged: moss-striped-tiger, element-tagged-companions).* Any beast works; this one is what the build is drawn around.
4. **Đạo:**
   - **Thú Đạo** · *Bách Thú* (a Hundred Beasts), facets **Linh Khế** (Spirit Bond), **Bầy** (the Pack) and **Thú Thể** (Beast Body). Nodes to buy: Straining Leash (the facet's big Effect), Bonded Spirit, Fang and Claw notables (+40 more to companion hits), companion power share lines, companion attack speed lines, Pack Hunt and Marked Prey, Thick Hide lines. Capstone: the Shared-Heart Contract. *The Way is in the game's catalogue; its graph is not drawn yet (staged: thu-linh-khe-bond, thu-bay-pack, thu-the-hide).*
   - Second Way: **Mộc Đạo** · *Khô Vinh* (Wither and Bloom), facet **Rừng** (the Forest): a quarter of each Wood-tagged bite turned to Chaos (passes body shields), and two more Fang and Claw notables. *Not in the game yet (staged: moc-rung-forest).*
5. **Công pháp: Shared-Heart Tiger-Rearing Scripture (Đồng Tâm Dưỡng Hổ Kinh)**, a main technique naming Wood and Fire. Địa giai to Nguyên Anh (12 layers: health +15 %, linh lực +20 %, damage +15 %), and its Thiên giai copy to Hóa Thần. It teaches every art you use, Fang and Claw (+60 more to companion hits), Rain on Both, Straining Leash and, at layer 9, the Contract. *Not in the game yet (staged: shared-heart-tiger-scripture).* A body technique (luyện thể) for health is the natural auxiliary. *In the game.*
6. **Arts**, all from the Scripture. None of them touches the enemy. *Not in the game yet (staged: whistle-in, feed-the-fire, bark-mantle, old-tree-sap, rouse, hearth-song, moss-fang-bite).*
   - **Feed the Fire (Đầu Hỏa):** 12 Fire buff stacks for 5 s; cost 2 %, every 1 s; only while your linh lực is at 40 % or more.
   - **Hearth Song (Lô Ca):** 6 Fire buff stacks for 10 s; cost 3 %, every 2 s; the same guard. Longer stacks that survive a Silence.
   - **Whistle In (Hô Hổ):** the tiger's next bites come 0.5 s sooner, and it is Roused (+20 more on its hits for 3 s); cost 2 %, every 2 s.
   - **Bark Mantle (Bì Giáp):** a bark shield on the tiger worth 19 % of your maximum linh lực, whenever its shield is gone; cost 5 %, every 4 s.
   - **Old-Tree Sap (Lão Mộc Dịch):** heals whichever of you two is lower (both, with Rain on Both); refunds its cost when it heals; cost 5 %, every 3 s.
   - **Rouse (Hoán Tỉnh):** stands a Down tiger up at once at 40 %; cost 6 %, every 6 s.
7. **Items.**
   - **Tiger-Tally Seal (Hổ Phù Ấn):** your weapon, a bronze seal (`an`) in two halves, one at your belt and one at the tiger's throat. Companion power share +15, companion attack speed +20 %, companion damage +20 %, and Sure Bite (the tiger's bites cannot be evaded). Its attack feeds the gear layer for every bite. *Not in the game yet (staged: tiger-tally-seal).*
   - Two more weapon seals (`an`) or fans (`phien`), Cực phẩm: you never swing them, but their attack is the tiger's gear layer. Ward gear (bells `chuong`, shields `thuan`) for your own defence. *In the game.*
   - A **Beast-Bond (Thú Khế)** affix on any generated piece: companion power share +5 to +15. *Not in the game yet (staged: beast-bond-affix).*
   - For prepared fights: **Blood-Meal Pill (Huyết Thực Đan)**, fed to the tiger, +70 more on its hits for one fight. *Not in the game yet (staged: blood-meal-pill).*
   - All year: feed the tiger twice what it needs for **Full Trough (Mãn Tào)**, +20 to +40 more on its hits even in blind fights. *Not in the game yet (staged: full-trough).*
8. **Enabler: the Shared-Heart Contract (Đồng Tâm Khế)**, the Scripture's layer 9 (Thiên copy: layer 12), or Thú Đạo's capstone. *Not in the game yet (staged: shared-heart-contract, beast-in-the-open).*

## The enabling Effects

- **Shared-Heart Contract (Đồng Tâm Khế), enabler.** Your basic attack becomes a second strike by your companion (Lent Hand), and your companion fights in the open: a health bar of half your health, taking 30 % of the damage that reaches you from hits, reachable by your heals and shields, Down at 0. In exchange you may slot no art or talisman that hits, ticks or curses the enemy. *Why the build needs it:* without it the tiger is one bite a second beside your own basic attack, about half your damage, and "heal or protect the beast" means nothing because the beast cannot be hurt.
- **Bonded Spirit (Linh Khế), keystone.** Your companion's timers carry your art speed, stopping at 0.5 s. *Why:* it is the only way to more than two bites a second; it turns a stat buff arts barely want into the build's rate.
- **Straining Leash (Căng Xích), major.** Your companion's hits deal +5 more (L5) for every 0.1 of its share above the cap, up to +50. *Why:* it is the identity. Every keeper hits the cap; this keeper turns the surplus into half of L5.
- **Beast Soul Union (Thú Hồn Hợp Thể), keystone.** Your strongest companion's share counts double; costs one art slot and only one companion may fight. *Why:* it fills the cap and Straining Leash when your tiger is no stronger than you. Drop it once the tiger's own share is 2.0 or more.
- **Rain on Both (Vũ Lưỡng).** Your heal arts also heal your companion. *Why:* one heal keeps both bars up, and every heal refunds its cost.
- **Pack Hunt (Quần Liệp).** Your companion's hits deal +15 more while the target bears any of your statuses. *Why:* the tiger's own Poison bite switches it on from the first bite.
- **Marked Prey (Tiêu Ký).** +4 more per distinct status of yours on the target. *Why:* a small piece of L5; the Poison counts.
- **Sure Bite (Ngoạm Chắc).** Your companion's hits cannot be evaded. *Why:* a companion cannot crit, so certainty is its rung 4; against evaders it is the whole matchup.
- **Roused (Hưng Phấn), from Whistle In.** +20 more on companion hits for 3 s. *Why:* the last piece of L5 once art speed has floored the timers.

## Modifiers to stack

In priority order. Each says which layer it fills and when to stop.

1. **Art speed (`art_speed_pct`), to +100 %.** With Bonded Spirit it halves both tiger timers (1 s → 0.5 s). **Stop at +100 %**: the floor is 0.5 s, and past it only your buff arts speed up (which costs linh lực faster).
2. **Companion power share, up to the cap.** +1 point = +0.01 coefficient. **Stop when the tiger's coefficient reaches 1.0**; past it, only Straining Leash reads it, and it stops at a share of 2.0 (+50).
3. **More on companion hits, L2 (Fang and Claw).** Technique +60, Thú Đạo +40 ×3, Mộc Đạo +40 ×2. **Stop at 300 points** (L2's cap).
4. **Increased damage, L1 (`attack_pct`, companion damage).** Falling returns past 200 points (each point counts half), hard stop at 400.
5. **Fire stack strength (`stack_effect_pct` on Fire buff, `stack_grant`).** Multiplies every Fire stack. No cap; returns stay linear, limited by your linh lực.
6. **Linh lực regeneration and art cost.** Every 1 % of pool a second you free holds about 30 more Fire stacks. Regeneration has falling returns (a log curve: +30 points of bonus count as +12.5).
7. **Gear attack, L3.** Weapons you never swing; aim for about 250 points (×3.5), as any top-end build.
8. **Prepared more, L4 (Blood-Meal Pill, Full Trough).** Up to 110 of L4's 150; nothing else fills it for a companion.
9. **L5 sources (Straining Leash, Roused, Pack Hunt, Marked Prey).** They sum to 89; **stop at 100** (L5's cap).
10. **Your own defence and the tiger's bar:** health (the tiger's bar is half of yours), Thick Hide, ward strength. No caps; take them once the damage list above is filled.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Shared-Heart Contract | Effect (enabler) | Lent Hand (a second tiger timer) and the beast in the open | Scripture layer 9; Thú Đạo capstone | Staged: shared-heart-contract | core |
| Bonded Spirit | Effect (keystone) | Art speed shortens both tiger timers, to 4 bites a second | Thú Đạo Linh Khế notable; tree keystone | Staged: bonded-spirit | core |
| Straining Leash | Effect (major) | The share past the cap becomes up to +50 L5 | Scripture layer 11; Thú Đạo Linh Khế major | Staged: straining-leash | core |
| Moss-Striped Tiger | Companion | Wood-tagged bites that lay Poison (wakes Pack Hunt) | Taming (Spirit Beasts), Beast Taming craft | Staged: moss-striped-tiger | core |
| Art speed | Modifier (`art_speed_pct`) | +100 % floors the tiger at 0.5 s | Tree notables, Đạo lines | In the game (designed) | core |
| Fang and Claw | Modifier (L2 more, [companion]) | Up to the L2 cap of 300 | Scripture layer 2 passive; Thú Đạo and Mộc Đạo notables | Staged: fang-and-claw | core |
| Feed the Fire, Hearth Song | Arts (Fire buff stacks) | 30 stacks (+36 %) per 1 % of pool a second | Scripture layers 3 and 12 | Staged: feed-the-fire, hearth-song | core |
| Companion power share | Modifier | +0.01 coefficient per point, to the cap | Tree, Thú Đạo lines, Beast-Bond affix | Staged: beast-bond-affix (key Pending in the Modifier System) | strong |
| Beast Soul Union | Effect (keystone) | Doubles a weaker tiger's share | Meridian Map keystone (capability #17) | In the game (Effects GDD) | strong |
| Tiger-Tally Seal | Named artifact | Share +15, companion speed +20 %, companion damage +20 %, Sure Bite, L3 | A warden's grave, a Cedar-Ridge reward | Staged: tiger-tally-seal | strong |
| Rain on Both | Effect | Heals reach both bars | Scripture layer 7 | Staged: rain-on-both | strong |
| Old-Tree Sap, Bark Mantle, Rouse | Arts | Keep the tiger standing | Scripture layers 5, 7, 10 | Staged: old-tree-sap, bark-mantle, rouse | strong |
| Pack Hunt | Effect (L5 +15) | Always on once the bite has poisoned | Thú Đạo Bầy minor | In the game (Effects GDD) | strong |
| Companion attack speed | Modifier (`companion_speed_pct`) | Reaches the timer floor with less art speed | Tree, Shepherd's Path cluster, Tiger-Tally Seal | Staged: companion-attack-speed | strong |
| Fire stack strength | Modifier (`stack_effect_pct` [hoa, buff], `stack_grant`) | Every Fire stack stronger | Tree, Hỏa lines | In the game (designed) | strong |
| Rot Seeps In | Modifier (25 % Physical → Chaos, [moc]) | A quarter of each bite passes body shields | Mộc Đạo Rừng notable | In the game (designed as a conversion row) | strong |
| Blood-Meal Pill | Modifier (L4 +70, [companion]) | Prepared fights only | Alchemy | Staged: blood-meal-pill | nice |
| Full Trough | Modifier (L4 +20 to +40) | L4 in blind fights too | Feeding twice the due; Thú Đạo line | Staged: full-trough | nice |
| Sure Bite | Effect | No evaded bites | Shepherd's Path far notable; Tiger-Tally Seal | Staged: sure-bite | nice (core against evaders) |
| Thick Hide | Modifier (`companion_health_pct`) | A bigger tiger bar | Thú Đạo Thú Thể lines; cluster | Staged: thick-hide | nice |
| Marked Prey | Effect (L5 +4 per status) | +4 from the Poison | Thú Đạo Bầy minor | In the game (Effects GDD) | nice |
| Shepherd's Path cluster | Cluster (sealed) | Share, companion speed, companion damage, tiger health, Sure Bite | Sealed by the Scripture | Staged: shepherds-path-cluster | nice |

## Realm by realm

- **Trúc Cơ (Foundation).** Tame a cub. You still strike with your own basic attack and the cub bites beside you at about half a basic attack. Scripture layers 1–7: Feed the Fire, Whistle In, Old-Tree Sap. You play a healer with a pet.
- **Kết Đan (Core Formation).** Layer 9: the **Contract**. Your hands stop; the tiger now bites on two timers and takes 30 % of what reaches you. Pick up Rouse and Bark Mantle, start Thú Đạo, and begin feeding the tiger double for Full Trough. This is where the build turns on.
- **Nguyên Anh (Nascent Soul), the build's realm.** Bonded Spirit and +100 % art speed: four bites a second. Straining Leash and the Tiger-Tally Seal; Beast Soul Union only if your tiger is not yet stronger than you. Six slots: Feed the Fire, Hearth Song, Whistle In, Bark Mantle, Old-Tree Sap, Rouse. The best upgrade of the whole life is here: trade up to a tiger a realm above you.
- **Hóa Thần (Deity Transformation).** The Thiên giai copy (Fang and Claw +80; Old Cedar Song: Roused also gives +15 % companion speed). A seventh slot for a cleanse against curse builds; four ward slots. Your tiger outranks most sect elders.

## How it plays

**Art order (slot order):** Feed the Fire, Hearth Song, Whistle In, Bark Mantle, Old-Tree Sap, Rouse. Feed the Fire first so it wins any tie for linh lực; Rouse last because it waits for its guard anyway.

**Loadout:** one main technique (the Scripture), a body technique for health, the Tiger-Tally Seal and two weapon seals for the gear layer, two pieces of ward gear, a drain ward and a shield ward in your ward slots.

**The loop:** nothing fires at t = 0. At 0.5 s the tiger bites and Feed the Fire lights; from then on it bites every 0.5 s. Feed the Fire fires whenever your pool is at 40 % or more, so your pool sits near 40 % and every point of regeneration above it is fire in the tiger's stripes. Heals and bark go wherever they are needed.

**The signature moment:** the enemy's big art crashes into your ward, 30 % of what gets through tears into the tiger instead, the bark splits and the tiger drops to a sliver, and you, who have not raised a hand all fight, sing it whole again while it keeps biting four times a second.

## What beats it

- **A Physical-resistant healer** (every realm has one, Combat rule 18: 150+ points against Physical, plus a heal). Three-quarters of each bite is Physical. Adapt: stack Rot Seeps In and Chaos lines, keep Pack Hunt up, and lean on Fire stacks rather than L2.
- **A slow, heavy hitter** (a beast-breaker). One huge hit puts 30 % of a big number into the tiger's half-size bar; two inside Rouse's 6 s cooldown and your side deals nothing for up to 8 s. Adapt: Thick Hide and health, keep Bark Mantle up, and prepare a shield ward so less gets through to share.
- **Curse kits with Silence or Sealed Meridian.** A Silence on your buff arts stops the Fire stacks. Adapt: Hearth Song's 10 s stacks hold through one Silence; take a cleanse at Hóa Thần.
- **Tick and soul builds** are even: ticks and soul hits never land on the tiger, so your own bar takes them all. Adapt: a soul ward in a ward slot, and heals.
- **What it beats:** drainers (your damage costs no linh lực at all), alpha strikers (they run dry against a full ward and two health bars), and evaders (Sure Bite).

## Not in the game yet

Every staged piece this build needs, by name in `design/builds/overnight-2026-11-10/staging-catalogue.md`:

- Enabler: **shared-heart-contract** (Shared-Heart Contract)
- Effects: **straining-leash**, **sure-bite**, **bonded-spirit**, **rain-on-both**
- Modifiers: **fang-and-claw**, **thick-hide**, **beast-bond-affix**
- Items: **tiger-tally-seal**, **blood-meal-pill**, **full-trough**
- Công pháp: **shared-heart-tiger-scripture**
- Arts: **whistle-in**, **feed-the-fire**, **hearth-song**, **bark-mantle**, **old-tree-sap**, **rouse**, **moss-fang-bite**
- Đạo pieces: **thu-linh-khe-bond**, **thu-bay-pack**, **thu-the-hide**, **moc-rung-forest**
- Modifiers with new keys: **companion-attack-speed**
- Concepts and keys: **beast-in-the-open**, **companion-timer**, **companion-attack-speed**, **element-tagged-companions**, **moss-striped-tiger**, **shepherds-path-cluster**

## Changes the game would need

1. **A companion that can be hurt, healed and shielded (beast in the open).** Combat GDD (`design/gdd/combat.md`) rule 19 says a companion "cannot be targeted … and cannot be removed from the fight except by its owner's defeat"; Formulas J has no companion health. Proposal: an opt-in state, opened only by an Effect (the Contract), giving the companion a bar of 0.5 × its owner's health that takes 30 % of the damage reaching the owner's health from hits, a Down state with a rise after 8 s at 25 %, and heal and shield targets in Combat Defence & Healing (`design/gdd/combat-defence.md`) rule 16.
2. **Redirect the basic attack to the companion.** Effects GDD (`design/gdd/effects.md`) rule 6's closed action list: a new action "your basic attack becomes a companion strike". Combat rule 13 and Formulas A2 keep the timer at `basic_cooldown`.
3. **The companion's timer obeys speed and timer actions.** Combat Formulas A2 fixes `basic_cooldown` for the companion and says art speed touches arts only. Proposal: `companion_speed_pct` (the tree catalogue's "Companion attack speed") and Bonded Spirit's "art speed also applies" both divide the companion's timer, floored at `cooldown_min`; Effects rule 6 "move a timer" may name the companion's timer.
4. **Say where Fire buff's "damage dealt" goes.** Effects rule 9a gives Fire's buff as "+1.2 % damage dealt" without naming its layer or whether a companion's hits count. This build assumes it multiplies all the side's direct damage, companion included, outside M. If it is ruled into L1 instead, this build's Fire stacks shrink to about ×1.1 and it relies on its layers and rate.
5. **Element-tagged companions** (from the by-root missing pieces): a creature record field so a beast's hits carry its element tag and grant its element's stacks (Effects rule 9a; `assets/data/creatures_linh_thu.json` has no species records yet).

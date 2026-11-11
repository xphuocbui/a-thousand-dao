# The Slow Thunder (Trì Lôi)

Spend almost nothing, keep your ward full, and let the linh lực you never used come down as one enormous stroke of thunder that a drain ward cannot pay for.

## Why it works

**The art rule pays slow, cheap arts the most per linh lực.** Every art's coefficient (its base size before multipliers) is limited by the art lint (Combat Formulas C): 1 × (1 + 24 × cost) + 0.25 × (cooldown − 1). Per 1 % of your linh lực spent, that gives:

| Art | Coefficient | Cost | Coefficient per 1 % of linh lực |
|---|---|---|---|
| 1 s cooldown, typical cost 7.5 % | 2.80 | 7.5 % | 0.37 |
| 12 s cooldown, top cost 12.5 % | 6.75 | 12.5 % | 0.54 |
| **12 s cooldown, bottom cost 2 %** | **4.23** | **2 %** | **2.12** |

That is about six times the damage per linh lực of a spam art. The price is time: nothing fires at the start of a fight, and a 12 s art first fires one full cooldown in (Combat rule 13).

**Linh lực you do not spend is your ward.** Linh lực is mana and defence in one pool (Combat rule 11): every art you cast weakens your ward. This build's three big arts cost 2 % each (1.2 % after cost reduction), so its pool and its ward stay full the whole fight. Spam builds usually run dry around 16 s and fight on with no ward.

**A full pool throws regeneration away, and this build catches it.** Regeneration is 3.5 % of maximum linh lực per second, plus your bonus on a falling curve (Formulas E). With about +5 points of bonus that is **7.38 % a second**. The build spends about 1.5 % a second, so close to **6 % a second** is lost to a full pool. Two Effects read that loss:

- **Thunderhead (Tích Lôi Vân)** gathers it. Your longest art (the 12 s Ice-Breaking Peal) adds **+0.1 coefficient for every 1 % gathered, up to +3.0**. With nobody pressing you it fills in about 5 s, so the peal goes from 4.23 to **7.23**, 71 % bigger. The lint buys 0.24 coefficient per 1 % you spend; the thunderhead gives 0.10 per 1 % you did not.
- **Still Water (Tĩnh Thủy)** heals you for half of the same loss. That is about 3 % of your linh lực a second, roughly **1.2 % of your health a second**, because your health pool is about two and a half times your linh lực pool (Formulas A: 64 against 26 fight units).

**Why drain wards hate it.** A drain ward pays linh lực for the damage it stops. The typical Common Ward bills about **0.19 linh lực for each point it stops**, and it stops about 82 % of a hit, so it bills about **16 % of the hit** (Combat Defence & Healing Formulas C). A typical pool is about 26 fight units of linh lực, so any hit above about **170 fight units** costs more than the whole pool. Past that point the ward pays what it can, and **the unpaid share of what it would have stopped goes straight through**. Ten small hits of the same total are paid one at a time, and the enemy regenerates between them. One huge hit has to be paid all at once. Leaking Ward (+50 % to the bill) and Weighted Bucket (+15 %) bring the break point down to about 100 fight units. At top-end multipliers the Ice-Breaking Peal is many times past it, so the enemy's pool is emptied by the hit that was supposed to be stopped.

## What to look for

In the order a player finds them.

1. **Spiritual root (linh căn):** Fire and Metal, Fire high (80+) and Metal 50 or more, so the **Thunder (Lôi)** variant converges. Thunder purity strengthens your herald's Thunder stacks. *In the game.*
2. **Talents:** Comprehension (ngộ tính) to climb the scripture's layers, and soul strength (thần hồn) for thần thức: it guards against soul attacks that drain your linh lực, and at 1.75 × the reference it gives a fourth ward slot. *In the game.*
3. **Đạo and nodes:**
   - Động Tĩnh Đạo (Motion and Stillness): in the Tĩnh facet take Still Water, Steady Breath and the regeneration and ward-efficiency lines; in Tĩnh Cực Sinh Động take **Thunderhead** and two Long Fuse notables. *The Way is in the game; Thunderhead and Long Fuse are not in the game yet (staged: thunderhead, long-fuse).*
   - Lôi Đạo (Thunder), Thiên Lôi facet: three Heavy Sky notables and Thunder Breaks the Dam. *Not in the game yet (staged: heavy-sky, thunder-breaks-the-dam).*
4. **Công pháp:** the **Long Winter Thunder Scripture (Trường Đông Lôi Kinh)**, a Địa giai main technique for Thunder roots, good to Nguyên Anh. It teaches all four arts and carries Long Fuse, Heavy Sky, slow-art speed and cost, a second copy of Thunderhead, and Final Clause. *Not in the game yet (staged: long-winter-thunder-scripture).*
5. **Arts:** Far Flash, Thaw Rumble, Rolling Peal and Ice-Breaking Peal. *Not in the game yet (staged: far-flash, thaw-rumble, rolling-peal, ice-breaking-peal).*
6. **Items:**
   - The **Ice-Jam Seal (Phá Lăng Ấn)**, a named seal weapon. *Not in the game yet (staged: ice-jam-seal).*
   - A second weapon with an artifact-attack affix, a shield (`thuan`) with a defence affix, and light armour. *In the game.*
   - Nine Rods Array and the Thunder-Gall Pill for fights you see coming. *Not in the game yet (staged: nine-rods-array, thunder-gall-pill).*
7. **Enabler:** none. The build is a stack of pieces with one identity Effect, Thunderhead.

## The enabling Effects

- **Thunderhead (Tích Lôi Vân).** *Rule:* the linh lực your pool loses to fullness gathers; when your art with the longest cooldown next lands a hit, that hit adds +0.1 coefficient per 1 % of maximum linh lực gathered, up to +3.0, and the gathering clears. A miss keeps the charge. *Why the build needs it:* without it, unspent linh lực is only defence. With it, regeneration, cost reduction and ward efficiency become damage, and every point an enemy forces you to spend comes off your biggest hit. *Not in the game yet (staged: thunderhead).*
- **Still Water (Tĩnh Thủy).** *Rule:* linh lực lost to a full pool heals you for half. *Why:* sustain is what wins 30–60 s fights, and this build makes more overflow than anyone. It keeps paying once the thunderhead is full. *In the game (Effects GDD).*
- **Steady Breath (Bình Tức), slow arts.** *Rule:* while your linh lực is at 50 % or above, your slow arts deal more (L5 +12). *Why:* it is always on for this build. *In the game (Effects GDD).*
- **Bare Vessel (Lộ Đỉnh).** *Rule:* your hits deal more (L5 +80) while the enemy has under 5 % linh lực. *Why:* after the great peal overdraws their ward, the next peals land on an empty vessel. *Not in the game yet (staged: Bare Vessel, content ledger).*
- **Thunder Breaks the Dam (Lôi Phá Đê).** *Rule:* when the enemy's wards pay against your slow art's hit and that payment leaves them at 0 linh lực, their art with the least time left is delayed 1 s. *Why:* it keeps the enemy quiet in the seconds before your next peal. *Not in the game yet (staged: thunder-breaks-the-dam).*
- **Final Clause (Mạt Khoản).** *Rule:* once a fight, as you go Down, your longest-cooldown art fires free. *Why:* if a burst build catches you before your first great peal, the peal still falls, with the full thunderhead. *In the game (Effects GDD).*

## Modifiers to stack

Most important first.

1. **Linh lực regeneration** (`linh_luc_regen_pct`). *Fuel, no layer.* Every point is more thunderhead and more healing. Falling returns: +5 points of bonus count as +3.88, and +30 would count as only +12.5. Stop at about +5 to +6; past that, take cost reduction instead.
2. **Art cost on slow arts** (`art_cost_pct` [slow]). *Fuel.* −20 % from the scripture and −20 % from a tree notable takes each peal to 1.2 %. Stop at −40 %: the remaining spend is mostly the herald.
3. **Long Fuse** (+40 to +50 [slow, cheap]). *L2.* The build's own "more" layer. Stop with Heavy Sky at L2's cap of 300.
4. **Heavy Sky** (+40 [lightning]). *L2.* Fill to 300 with Long Fuse: 50 + 40 + 40 + 40 + 120 = 290.
5. **Crit chance on slow arts, crit damage on Thunder arts.** *Crit.* The cap is 50 % chance and ×3.0 damage. The herald's Thunder stacks add about 9 points of chance and 38 % crit damage on their own, so stop the crit-damage nodes at about +80.
6. **Damage with Lightning and with slow arts** (`attack_pct`). *L1.* The everyday stack. Past +200 each point counts half.
7. **Artifact attack.** *L3,* through the Ice-Jam Seal and one more weapon. Stop at L3's cap of 250.
8. **Ward efficiency and ward strength.** *Fuel under pressure.* Your own drain bills shrink, so more of each pulse overflows when you are being hit. No cap; take them after the layers are full.
9. **Art speed on slow arts.** *Rate.* +80 in total puts the peals at 4.4, 5.6 and 6.7 s. Do not push the Ice-Breaking Peal much below 5 s: the thunderhead needs about 5 s to fill.
10. **Opening Haste.** *Timing* (staged). +30 from the Thunder-Gall Pill brings the first great peal to about 5.1 s with the thunderhead still full. Stop at +30: more lands the first peal before the thunderhead is ready.
11. **Weighted Bucket** (`ward_bill_pct`). *Reach.* +15 makes the overdraw happen sooner. One notable is enough; the Leaking Ward from Far Flash does the rest.
12. **Lightning penetration** (`resist_pen_pct` [lightning]). *Reach.* Take it if per-hit wards or Lightning-resistant foes are common where you fight.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Thunderhead | Effect (overflow, held) | Up to +3.0 coefficient on the Ice-Breaking Peal (4.23 → 7.23) | Động Tĩnh Đạo, Tĩnh Cực Sinh Động major; scripture layer 9 | Staged: thunderhead | core |
| Long Winter Thunder Scripture | Công pháp | All four arts, Long Fuse +50, slow art speed +30, slow art cost −20, Heavy Sky +40, Final Clause | Main technique, Địa giai | Staged: long-winter-thunder-scripture | core |
| Still Water | Effect (overflow) | About 1.2 % of health a second while the pool overflows | Động Tĩnh Đạo Tĩnh minor; Meridian Map | In the game (Effects GDD) | core |
| Linh lực regeneration | Modifier `linh_luc_regen_pct` | Every point is more thunderhead and more healing | Tree notables (+1), Ice-Jam Seal (+1.0), Tĩnh lines | In the game | core |
| Art cost, slow arts | Modifier `art_cost_pct` [slow] | Peals at 1.2 % instead of 2 %, so more overflow | Scripture layer 8; tree notable; Winter Breath region | In the game (key); region staged: winter-breath-region | core |
| Long Fuse | Modifier, L2 [slow, cheap] | +40 to +50 more on every peal | Scripture layer 2; Tĩnh Cực Sinh Động notables ×2; Winter Breath far notable | Staged: long-fuse | core |
| Heavy Sky | Modifier, L2 [lightning] | +40 more per source; fills L2 with Long Fuse | Lôi Đạo Thiên Lôi notables ×3; scripture layer 6 | Staged: heavy-sky | strong |
| Ice-Jam Seal | Named artifact (weapon) | L3, slow art speed +30, regeneration +1.0, Steady Breath | Named item (the Seven Floes ferry) | Staged: ice-jam-seal | strong |
| Bare Vessel | Effect (conditional), L5 +80 | Fills L5 once the great peal empties the enemy | Way or tree | Staged (content ledger: Bare Vessel) | strong |
| Crit chance [slow], crit damage [loi] | Modifiers | Crits on few, huge hits; the cap is ×3.0 | Tree notables | In the game | strong |
| Nine Rods Array | Formation, L4 +80 | Half of L4 in fights you see coming | Formation (foreseen) | Staged: nine-rods-array | strong |
| Thunder-Gall Pill | Pill, L4 +70 [lightning], opening haste +30 | The other half of L4, and a first peal at 5.1 s | Alchemy (foreseen and ambush) | Staged: thunder-gall-pill | strong |
| Weighted Bucket | Modifier `ward_bill_pct` +15 | The enemy's drain ward breaks on a smaller hit | Winter Breath side notable; Vụ Đạo lines | Staged: weighted-bucket | strong |
| Ward efficiency | Modifier `ward_efficiency_pct` | Smaller own bills when you are hit, so the thunderhead still fills | Tree notables, Tĩnh lines, ward gear | In the game | strong |
| Lightning penetration | Modifier `resist_pen_pct` [lightning] +120 | The answer to per-hit wards and Lightning resisters | Tree notable; Thiên Lôi lines | In the game | strong |
| Thunder Breaks the Dam | Effect (trigger) | Enemy's next art delayed 1 s after a peal empties them | Lôi Đạo Thiên Lôi minor | Staged: thunder-breaks-the-dam | nice |
| Undivided | Effect (per), L5 +10 per empty slot | +20 L5 with two empty slots | Swept Floor region far notable; Đại Đạo Giản | Staged: undivided | nice |
| Opening Haste | Modifier `opening_haste_pct` | First great peal at 5.1 s (+30) | Thunder-Gall Pill; Herald's Banner (+40, too much alone) | Staged: opening-haste, herald-banner | nice |
| Final Clause | Effect (trigger) | The great peal falls even if you go Down first | Scripture layer 12 | In the game (Effects GDD) | nice |
| Clear Heart Ward | Ward (reserved 0.25) | Cleanses Silence and Leaking Ward put on you | A fourth ward slot from thần thức | In the game | nice |
| Measured Stroke | Effect (rule change) | Your 10 s and 12 s peals cannot be evaded (and cannot crit) | Way, technique | In the game, but its 20 s threshold is out of reach (staged suggestion: 10 s) | nice |

## Realm by realm

- **Kết Đan (the run-up).** Learn the scripture and take it to layer 5: Far Flash, Thaw Rumble and Rolling Peal. Five art slots, two of them empty; Common Ward and Soul-Guarding Lamp in two ward slots. No thunderhead yet. You are a patient caster who never runs dry and outlasts spam builds.
- **Nguyên Anh, early.** Layer 7 gives the Ice-Breaking Peal, and layer 9 (or the Động Tĩnh Đạo major) gives Thunderhead. The third ward slot takes Mountain Screen, a shield that covers the first seconds. Put the great peal in slot 1. This is where the build becomes itself: the 12 s peal lands with the thunderhead and empties drain wards.
- **Nguyên Anh, peak.** Layer 12 adds Final Clause. The Ice-Jam Seal at Cực phẩm, both L2 Ways and the Winter Breath region fill the layers. With high thần thức a fourth ward slot takes Clear Heart Ward against silencers. Past Nguyên Anh the scripture stops (no Thiên giai copy yet), so the build ends here.

## How it plays

- **Loadout (6 art slots):** slot 1 Ice-Breaking Peal (12 s), slot 2 Rolling Peal (10 s), slot 3 Thaw Rumble (8 s), slot 4 Far Flash (3 s), slots 5 and 6 empty (for Undivided). Ward slots: Common Ward, Soul-Guarding Lamp, Mountain Screen. No guards on any art.
- **Art order in a fight** (art speed +80 on the peals, +20 on the herald):
  - 0–2.5 s: nothing fires but the basic attack. The ward is full, Mountain Screen absorbs, and the thunderhead gathers.
  - 2.5 s: Far Flash marks the enemy with Thunder stacks and Leaking Ward, again every 2.5 s.
  - 4.4 s: Thaw Rumble lands.
  - 5.6 s: Rolling Peal lands.
  - 6.7 s: the Ice-Breaking Peal falls with a full thunderhead.
  - After that the peals keep cycling, the thunderhead refills between great peals, and Still Water heals all the while.
- **Signature moment:** the great peal hits a drain-ward caster and the Breakdown reads "Thunderhead +3.00: Ice-Breaking Peal 4.23 → 7.23; Common Ward paid 12 % of its bill". The enemy's linh lực bar is empty from one blow, and the next peal lands with Bare Vessel lit.

## What beats it

- **Linh lực drainers** (Qi Disruption, soul arts that take linh lực). They keep your pool below full, so nothing overflows: no thunderhead and no Still Water. *Adapt:* Soul-Guarding Lamp and thần thức against soul drain; ward efficiency and ward strength; a cleanse for Qi Disruption (Clear Heart Ward).
- **Per-hit wards** (Golden Bell, Surging Tide). They pay one flat fee per hit, so your huge hit never overdraws them. *Adapt:* Lightning penetration (+120 points per notable) and crit. This is your weakest ward matchup.
- **Fast bursters.** They strike before your first peal at 4.4 s. *Adapt:* Mountain Screen, the full Common Ward, health; Final Clause makes them pay if they kill you.
- **Evaders.** One evade costs a whole 5–7 s cycle (the thunderhead keeps its charge until a hit lands). *Adapt:* accuracy (Thunder buff stacks, accuracy nodes); Measured Stroke once its threshold is fixed.
- **Silencers.** Silence naming slow arts or Lightning stops all three peals. *Adapt:* Clear Heart Ward in a fourth ward slot.
- **Bosses with big pools.** Their drain ward holds more, so one peal does not empty it. Damage per linh lực still wins the long fight, which a boss always is.

## Not in the game yet

Every staged piece this build needs:

- **thunderhead:** Thunderhead (Tích Lôi Vân), the identity Effect.
- **thunder-breaks-the-dam:** Thunder Breaks the Dam (Lôi Phá Đê).
- **long-fuse:** Long Fuse (Trường Dẫn), L2 [slow, cheap].
- **heavy-sky:** Heavy Sky (Thiên Trầm), L2 [lightning].
- **long-winter-thunder-scripture:** Long Winter Thunder Scripture (Trường Đông Lôi Kinh).
- **far-flash, thaw-rumble, rolling-peal, ice-breaking-peal:** the four arts.
- **ice-jam-seal:** Ice-Jam Seal (Phá Lăng Ấn).
- **dong-tinh-stillness-burst, thien-loi-heavy-sky:** the Way nodes.
- **winter-breath-region:** Winter Breath (Đông Tức), a tree region idea.
- **overflow-read-whole:** the overflow-read clarification.
- Reused from earlier builds: **opening-haste**, **weighted-bucket**, **undivided**, **swept-floor-cluster**, **nine-rods-array**, **thunder-gall-pill**, **herald-banner**, **art-coef-add-key**, **held-payload**, **empty-art-slot**; and **Bare Vessel** (content ledger).

## Changes the game would need

1. **Overflow is read whole** (Effects System, `design/gdd/effects.md` rule 5). Every Effect that reads the overflow event reads the whole amount; overflow is never split between Effects. Still Water and Thunderhead both read it. *New suggestion.*
2. **A second source for `art_coef_add`, as a capped held payload** (Combat, `design/gdd/combat.md` Formulas C; Modifier System Stat List; Effects rule 8). Thunderhead adds coefficient after the lint, held until the longest art's next landed hit, capped at +3.0 per landing. This builds on one-art's `art_coef_add` and bare-fist's held payload. *New suggestion.*
3. **An opening timer stat** (`opening_haste_pct`, combat.md rule 13 and Formulas A2). Already suggested by first-volley.
4. **A stat for the bill your hits raise** (`ward_bill_pct`, combat-defence.md Formulas C). Already suggested by dry-well.
5. **Measured Stroke's threshold, 20 s → 10 s** (effects.md Starter Effects). Already suggested by one-art.
6. **Ability, passive and art-record fields on techniques** (`items_cong_phap.json`, cong-phap.md), and a fight payload for pills and formations. Already noted by every build of this run.

# The Thousand-Year Banyan (Thiên Niên Dung Thụ)

A tank that cannot be worn down: the healing it does not need turns into poison on the enemy, and when the 60 s
fatigue arrives, it is the last one standing.

## Why it works

Three rules of the fight make this build.

**1. Healing has no cap.** Health regeneration, heal arts and leech have no limit per pulse and never fade over a
fight (combat-defence.md rule 16, user decision #44). The only limit is your health bar: healing past full is lost.

**2. Fatigue is flat.** From 60 s, every pulse takes the same amount from both sides, `0.5 × U × n²`, where U is your
realm's fight unit and n counts the pulses since 60 s (combat.md rule 10). It ignores wards, shields and resistance,
and nothing changes it. It does not depend on your health. So the side with the bigger bar, refilling faster, is
always the last to fall.

**3. Poison is certain.** Poison is Wood's debuff: Chaos damage every pulse, 0.019 per stack. It never misses, never
crits, skips block and passes body shields.

The build joins them with one piece, **Surplus Life (Dư Sinh)**. Each pulse, every 1 % of your maximum health that
your healing could not fit in your bar lays 1 Poison stack (10 s) on the enemy, up to 30 a pulse.

- **If the enemy cannot hurt you,** your whole regeneration becomes Poison, and the Poison kills them.
- **If the enemy can hurt you,** your healing goes into your bar instead. You stop attacking and simply outlast them
  to fatigue.

Key numbers at Deity Transformation (Hóa Thần), from the GDD formulas. The fight unit U is 251.19, and your gear and
Way choices are first guesses:

- **Your bar:** health = 64 × U × n_body. A typical side (n 1.09) has about 17,500. This build aims for n about 3:
  **48,200**.
- **Your regeneration:** about 6 pp of bonus (technique, mantle, affix, about 30 Wood buff stacks at purity 80, Growth
  Rings), × 1.4 for regeneration increased, × 1.3 for healing ≈ **10.9 % of your health a pulse**, about 5,250.
- **Your Poison:** one stack ticks 251.19 × 0.019 = 4.77 before layers. With your layers (×6.8) and Wood purity 80
  (×1.16), that is about **37.6 a stack a pulse**. Unpressed, you lay about 11 stacks a pulse. With batches lengthened
  to 15 s, about 160 stacks sit on the enemy, about 6,000 a pulse before resistance. A typical ward stops 81.75 %
  of Chaos, so about 1,100 reaches the enemy's 17,500: **dead in about 25 s**, counting the ramp.
- **Fatigue:** it takes 126, 502, 1,130, 2,010 … a pulse. A typical side at full health falls at **66 s**. This build,
  at full health at 60 s and regenerating 5,250 a pulse, falls at about **72 s**. That is six pulses later, whatever
  the enemy does.

## What to look for

In the order a player finds them.

1. **Spiritual root (linh căn): Water and Wood**, with Wood purity high (80+). Wood purity powers both your Wood buff
   (regeneration) and the Poison you lay (each stack × (1 + 0.002 × purity)). Water feeds Wood, and your linh lực.
   *In the game.*
2. **Talents:** Căn cốt (Physique) first: +2.22 % health a point, so a bigger bar and a longer fatigue margin. Then Ngộ
   tính (Comprehension), to reach the technique's late layers. *In the game.*
3. **Đạo and nodes:** Mộc Đạo (Khô Vinh, Wither and Bloom), whose capstone idea is "the forest outlives everything".
   Take the Sinh Trưởng (Growth) facet and its keystone, Surplus Life, plus Still Water on the way through Rễ (Roots).
   If you can hold a second Way, Sinh Tử Đạo's Trường Sinh (Longevity) facet carries Growth Rings. *The Ways are in
   the game design; these nodes are not in the game yet (staged: `moc-sinh-truong-surplus`, `sinh-tu-truong-sinh-rings`).*
4. **Technique (công pháp): Thousand-Root Spring Scripture (Thiên Căn Tuyền Kinh).** A main method naming Wood and
   Water. The Địa giai copy reaches Nascent Soul (Nguyên Anh) and the Thiên giai copy reaches Deity Transformation. It
   teaches every art below, Spillover, Rot Deepens, and Surplus Life at Địa layer 11 or Thiên layer 12. *Not in the
   game yet (staged: `thousand-root-spring-scripture`).* Before you find it, Thanh Mộc Địa Quyết or Huyền Thủy Địa
   Quyết carry the stats. *In the game.*
5. **Arts (thần thông):**
   - Spring Sap (Xuân Dịch): 6 Wood stacks for 10 s, every 2 s. *Not in the game yet (staged: `spring-sap`).*
   - Underground Spring (Ám Tuyền): 6 Water stacks for 10 s, every 2 s. *Not in the game yet (staged:
     `underground-spring`).*
   - Banyan Shade (Dung Âm): a heal that refunds its cost. *Not in the game yet (staged: `banyan-shade`).*
   - Shedding Bark (Thoát Bì): cleanses your curses. *Not in the game yet (staged: `shedding-bark`).*
6. **Items:**
   - Banyan-Bark Mantle (Dung Bì Bào): body armour with health, regeneration, a body shield and Growth Rings. *Not in
     the game yet (staged: `banyan-bark-mantle`).*
   - A generated weapon rolling the Thực (Chaos penetration) and Hồi Xuân (regeneration) affixes. *Not in the game yet
     (staged: `smelting-affixes`, `hoi-xuan-affix`).*
   - Thousand-Year Sap Pill. *Not in the game yet (staged: `thousand-year-sap-pill`).*
   - Corpse-Wax Coating. *Not in the game yet (content ledger proposal).*
   - Hot Spring Array. *Not in the game yet (staged: `hot-spring-array`).*
   - Wards: Common Ward, Still Lake Aura, Clear Heart Ward, Mountain Screen, Thousand-Layer Cloud, Soul-Guarding Lamp,
     Golden Bell. *In the game design (combat-defence.md Formulas H).*
7. **Enabler: Surplus Life (Dư Sinh).** *Not in the game yet (staged: `surplus-life`).*

## The enabling Effects

- **Surplus Life (Dư Sinh), the enabler.** Healing lost to your full bar becomes Poison on the enemy: 1 stack (10 s)
  per 1 % of maximum health, up to 30 a pulse. Its price is **Rooted (Bám Rễ)**: your evade is fixed at 0, and you
  can never slot an escape art.
  *Why the build needs it:* without it, every point of regeneration past full is wasted, and the build can only win
  through fatigue.
- **Still Water (Tĩnh Thủy).** Linh lực lost to a full pool restores health, at half the amount.
  *Why:* your two buff arts cost 0.02 every 2 s against about 8 % regeneration a pulse, so your pool is nearly always
  full. Still Water turns that spare linh lực into health, and Surplus Life turns that health into Poison.
- **Spillover (Dật Độc).** Your ticks also burn 25 % of what they deal from the enemy's linh lực.
  *Why:* the Poison slowly starves the enemy's ward and arts, so the longer the fight runs, the less it can hurt you.
- **Growth Rings (Niên Luân).** +0.1 pp health regeneration for every 100 years of your age, up to +1.5 pp.
  *Why:* the build's arc. An old banyan heals faster than a young one, and an elder of 1,200 years carries +1.2 pp
  for free.
- **Sap Rises (Nhựa Thăng).** +1 % healing for each Wood buff stack you hold.
  *Why:* your 30 Wood stacks already raise regeneration. This makes them raise every heal as well, by +30 %.
- **The Spring Never Fails (Tuyền Bất Kiệt).** Each Water stack adds +0.025 pp linh lực regeneration outside the
  falling-returns curve.
  *Why:* it keeps the pool full past the point where plain regeneration stops paying.
- **Quiet Channels (Tĩnh Mạch).** +0.5 pp linh lực regeneration for each art slot that holds a ward or nothing, up to
  +3.
  *Why:* the build fills spare art slots with wards anyway, so the slots also pay for the pool.

## Modifiers to stack

In priority order:

1. **Health regeneration (`health_regen_pct`)** fills the engine itself. Stop when your overheal, unpressed, nears 30 %
   a pulse: that is Surplus Life's cap of 30 stacks. In practice you will not reach it. Each pp costs about 9.9 W, so
   weigh it against the next lines.
2. **Wood stack duration (`stack_duration_pct` [moc])** fills Rate. Longer Wood buff batches hold more regeneration,
   and longer Poison batches hold a bigger pile. It has no cap; +50 % is a good target.
3. **Healing (`healing_pct`) and regeneration increased (`health_regen_inc_pct`)** are multipliers. They multiply each
   other and the flat regeneration, so keep the three roughly even rather than piling one. Neither has a cap.
4. **Maximum health (`khi_huyet_pct`)** sets your fatigue margin. It does not change the Poison (Surplus Life counts
   percent), but it decides who falls last. It has no cap; `n_body` stops at 8.
5. **Reservation efficiency (`reserve_eff_pct`)** to 50, its cap. Without it your reserved wards pass `reserve_cap`
   0.9.
6. **Healing taken (`healing_taken_pct`)** is the answer to Withering, which takes healing taken down to a floor of
   −50 %. Stop at about +50: past it, you are only buying back what one curse took.
7. **Linh lực regeneration (`linh_luc_regen_pct`)** fuels the pool. Stop at about +6 pp of bonus: the log curve
   counts +6 as +4.48, and +30 only as +12.47.
8. **Poison layers:** `attack_pct` [poison] (L1), Rot Deepens (L2), weapon attack (L3), Corpse-Wax Coating (L4), and
   `stack_effect_pct` [moc, debuff]. Spread them across layers; there is no L5 for ticks.
9. **Chaos penetration (`resist_pen_pct` [chaos])** is worth most against warded foes. It has no cap.
10. **Status resistance (`status_resist_pct`)** fewer curses stick. The apply chance never falls below 5 %.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Surplus Life (Dư Sinh) | Effect (enabler) | Overheal becomes Poison: the whole damage channel | Mộc Đạo Sinh Trưởng keystone; Thousand-Root Spring Scripture (Địa L11, Thiên L12) | Staged (`surplus-life`) | core |
| Thousand-Root Spring Scripture | Technique | Arts, Spillover, Rot Deepens, regeneration passives, Surplus Life | Sect library or a rare find; Thiên copy for Deity Transformation | Staged | core |
| Spring Sap / Underground Spring | Arts (Wood and Water buffs) | About 30 Wood stacks (regeneration) and 30 Water stacks (pool) | The Scripture, layers 1 and 3 | Staged (`spring-sap`, `underground-spring`) | core |
| Health regeneration nodes | `health_regen_pct` +0.12 a small | The base of the engine | Tree; Heartwood cluster | In the game design (Designed key) | core |
| Banyan Shade | Heal art, refunds its cost | A large heal on every scratch, and its excess feeds Surplus Life | The Scripture, layer 5 | Staged (`banyan-shade`) | core |
| Banyan-Bark Mantle | `khi_huyet_pct` +20, `health_regen_pct` +1.0, `body_shield_pct` +10, Growth Rings | Bar, regeneration and the age bonus in one slot | Named armour (`giap`) | Staged (`banyan-bark-mantle`) | core |
| Still Water | Effect | Spare linh lực becomes health, and so Poison | Mộc Đạo Rễ or Thủy Đạo (Way host); tree | In the game design (effects.md) | strong |
| Reservation efficiency | `reserve_eff_pct` to 50 | Fits Still Lake Aura with Clear Heart Ward and the shields | Tree | In the game design (Designed key) | strong |
| Healing / regeneration increased | `healing_pct`, `health_regen_inc_pct` | Multiplies all your healing | Scripture Thiên L11 and L14; Heartwood notable; Sap Rises | Designed keys; Sap Rises staged (`sap-rises`) | strong |
| Hồi Xuân affix | `health_regen_pct` +0.2–0.6 | Regeneration a generated piece can roll | Generated artifacts | Staged (`hoi-xuan-affix`) | strong |
| Stack duration [moc] | `stack_duration_pct` | More Wood stacks held, and a bigger Poison pile | Mộc Đạo Sinh Trưởng; Heartwood smalls | Designed key; nodes staged | strong |
| Shedding Bark | Cleanse art | Removes Withering and Stagnation, the Salt-Sower's tools | The Scripture, layer 8 | Staged (`shedding-bark`) | strong |
| Rot Deepens | `damage_more` +40/+60 [poison] L2 | The Poison's identity layer | Scripture layer 9; Mộc Đạo notable | Content ledger proposal | strong |
| Thực affix | `resist_pen_pct` [chaos] +40–80 | The Poison reaches through Chaos wards | Generated weapon | Staged (`smelting-affixes`) | strong |
| Growth Rings | Effect (Per, age) | Up to +1.5 pp regeneration as you age | Banyan-Bark Mantle; Sinh Tử Đạo Trường Sinh | Staged (`growth-rings`) | nice |
| Thousand-Year Sap Pill | `health_regen_pct` +1.5, `healing_pct` +20 for one fight | A prepared fight (a boss, a tribulation) | Alchemy | Staged | nice |
| Corpse-Wax Coating | L4 `damage_more` on ticks | Fills L4 for the Poison in foreseen fights | Coating | Content ledger proposal | nice |
| Hot Spring Array | +regeneration on its ground | Both pools, in a prepared fight | Formation | Staged (`hot-spring-array`) | nice |
| The Spring Never Fails | Effect | Linh lực regeneration past the curve | Water land keystone | Staged (`spring-never-fails`) | nice |
| Quiet Channels | Effect (Per) | +0.5 pp linh lực regeneration per ward-holding slot | Porter's Shoulder cluster; Thể Đạo minor | Staged (`quiet-channels`) | nice |
| Heartwood (Tâm Mộc) cluster | Regeneration, healing, Sap Rises | A themed stretch of the tree to plan a life around | Sealed cluster, opened by the Scripture | Staged (`heartwood-cluster`) | nice |

## Realm by realm

- **Core Formation (Kết Đan): the sapling.** Địa Scripture up to layer 9: the two buff arts, Banyan Shade, Spillover and
  Rot Deepens. Surplus Life is not open yet, so the build wins by outlasting.
  - Fatigue at this realm takes 19.9 × n² a pulse.
  - A typical side's bar (about 2,780) falls at 66 s. This build aims for twice that (n_body 2, about 5,100), plus
    regeneration.
  - Wards: Common Ward and Still Lake Aura in the 2 free ward slots; Clear Heart Ward and Mountain Screen in art slots.
- **Nascent Soul (Nguyên Anh): the vow.** Surplus Life opens (Scripture Địa layer 11, or the Mộc Đạo keystone), and
  you take Rooted. Ordinary fights now end in 25–40 s on the Poison. Shedding Bark joins the loadout, and
  Soul-Guarding Lamp takes the third ward slot. The Banyan-Bark Mantle is the big upgrade.
- **Deity Transformation (Hóa Thần): the old tree.**
  - The Thiên Scripture adds healing +30 and regeneration increased +40.
  - 7 art slots and 4 ward slots. Quiet Channels counts three ward-holding art slots (+1.5 pp).
  - Growth Rings nears +1.2–1.5 pp.
  - About 10 % of your bar a pulse, and about 6 pulses of fatigue margin over a typical side.

## How it plays

**Loadout at Deity Transformation:**

- **Art slots, in order:**
  1. Banyan Shade
  2. Spring Sap
  3. Underground Spring
  4. Shedding Bark
  5. Clear Heart Ward
  6. Mountain Screen
  7. Thousand-Layer Cloud
- **Ward slots:** Common Ward, Still Lake Aura, Soul-Guarding Lamp, Golden Bell.

**Art order.**

- Banyan Shade goes first, because it must fire the instant the bar dips. Its guard is "own health at or below 95 %",
  so it fires on any scratch and always refunds its cost.
- The two buff arts run every 2 s from t = 2 and keep about 30 stacks of each element.
- Shedding Bark waits until you carry Withering or Stagnation.
- Nothing fires at t = 0 (every art starts on its cooldown). You start at full health, so overheal begins at the first
  pulse.

**The signature moment.** The enemy's big volley drops you to 70 %, and the Poison counter on the enemy stops cold.
Banyan Shade and two pulses of regeneration refill the bar, and the counter starts climbing again. Their damage paid
for nothing, and their pile of Poison is still ticking.

## What beats it

- **The Salt-Sower (Tát Diêm Giả):** an enemy built to break this build, from existing pieces only.
  - Its tools:
    - Withering: healing taken −50 %, which halves both your regeneration and your overheal.
    - Stagnation stacks: your regeneration is divided by (1 + stacks/100).
    - Clear Heart Ward on itself: it cleanses 25 % of every Poison batch each pulse, so your pile holds about a
      quarter of its size.
    - High Chaos resistance.
    - A steady mid-sized hitter that keeps your bar just under full, so overheal is 0.
  - **Adapt:** Shedding Bark early in the slot order, `healing_taken_pct` toward +50, and `status_resist_pct`. Bring
    the Thousand-Year Sap Pill if you know it is coming. It is still a fatigue fight, so a bigger bar wins it.
- **The alpha strike** (top-end burst, such as a synchronised first volley): it can kill before regeneration matters.
  - **Adapt:** raise maximum health and body shield (Mountain Screen, Thousand-Layer Cloud and the Mantle stand from
    t = 0). If you survive the volley, the burst build has nothing left.
- **High Chaos resistance** (Combat rule 18 requires one per realm tier): the Poison is cut hard.
  - **Adapt:** Chaos penetration (the Thực affix). Otherwise accept a fatigue win at about 66–72 s.
- **A bigger healer:** two sustain sides go to fatigue, and the bigger bar wins.
  - **Adapt:** maximum health and Căn cốt.
- **A soul build:** soul hits skip wards and shields and take a share of health and linh lực.
  - **Adapt:** Soul-Guarding Lamp. Regeneration refills the health part anyway.

## Not in the game yet

| Piece | Staged as | What it is |
|---|---|---|
| Surplus Life (Dư Sinh) | `surplus-life` | The enabler: overheal becomes Poison; closes Rooted |
| Health overflow | `health-overflow` | The readable Surplus Life needs (the healing lost to a full bar) |
| Thousand-Root Spring Scripture | `thousand-root-spring-scripture` | The main technique, Địa and Thiên copies |
| Underground Spring, Banyan Shade, Shedding Bark | `underground-spring`, `banyan-shade`, `shedding-bark` | Arts |
| Spring Sap | `spring-sap` | Art (staged by two-clocks, reused) |
| Growth Rings (Niên Luân) | `growth-rings` | Effect: regeneration by age |
| Sap Rises, The Spring Never Fails, Hot Spring Array | `sap-rises`, `spring-never-fails`, `hot-spring-array` | Pieces from the by-root catalogue |
| Quiet Channels | `quiet-channels` | Effect (staged by bare-fist, reused) |
| Banyan-Bark Mantle | `banyan-bark-mantle` | Named armour |
| Hồi Xuân and Thực affixes | `hoi-xuan-affix`, `smelting-affixes` | Artifact affix rows |
| Thousand-Year Sap Pill | `thousand-year-sap-pill` | Pill |
| Heartwood (Tâm Mộc) | `heartwood-cluster` | Sealed cluster idea |
| Mộc Đạo Sinh Trưởng pieces; Sinh Tử Đạo Trường Sinh pieces | `moc-sinh-truong-surplus`, `sinh-tu-truong-sinh-rings` | Đạo nodes |
| The Salt-Sower | `salt-sower-profile` | The counter enemy profile |
| Rot Deepens, Corpse-Wax Coating | content ledger proposals | Poison L2 and L4 |

## Changes the game would need

1. **Health overflow as a readable** (design/gdd/effects.md rule 5). An event each pulse window carrying the healing
   lost to a full health bar, from any source, as linh lực overflow already is (#44). Surplus Life reads it. No other
   rule changes.
2. **Say whether "grant element stacks" rolls a status chance** (design/gdd/effects.md rule 6; combat.md Formulas F).
   Today Formulas F says status resistance counts against every status, and rule 6 lists "grant element stacks" as an
   action without saying. This build assumes stacks granted by an Effect are not rolled. If they are rolled, a high
   status resistance becomes a second counter. That is acceptable, but it should be written down.

# Two Clocks (Song Thời)

Never strike: bury the enemy in embers until their linh lực runs dry, then let the rot finish them before they can cast again.

## Why it works

You run two damage-over-time families at once, and you give them different jobs.

- **Burn (Thiêu Đốt), the fast clock.** Fire damage, laid in big short bursts: 20 stacks that last 2 seconds,
  every second. Most enemies resist Fire well, so most of your Burn is stopped by their ward. That is the
  point. A ward that stops damage pays for it out of its owner's linh lực (spiritual power), and your
  **Ash Ledger (Tro Trướng)** burns another fifth of everything stopped. The harder they resist, the faster they run dry.
- **Poison (Trúng Độc), the slow clock.** Chaos damage, laid in thin long layers: 4 stacks that last 16 seconds,
  piling up. Poison slips past every shield, and almost nobody resists Chaos. It is the clock that kills.

When the first clock rings (the enemy's linh lực hits 0), three things happen in the same second:

1. they cannot cast arts any more, so they can barely hurt you;
2. a drain-paid ward goes out, so their resistance drops;
3. **Bare Vessel (Lộ Đỉnh)** switches on: +80 % more damage to every tick, thanks to your enabler.

The numbers, worked by hand on today's rules at Nascent Soul (Nguyên Anh), in a prepared fight:

- each stack ticks for about 1.6 fight units a second before resistance;
- against an ordinary cultivator the first bell rings at about **3 s** and they are dead at about **4 s**;
- against a strong, well-warded cultivator (1,650 resistance points) the first bell rings at about **3 s**, they stop
  casting, and they die at about **8 s**, with you on about 58 % health;
- take Ash Ledger away and the first bell slips to about 6 s. You still win at about 9 s, but on about a quarter of
  your health;
- take the enabler away and the kill slips to about 11 s.

The skill's fight calculator could not test this. Its constants are out of date (31 of 60 have drifted) and it still
models the tick caps the game removed, so these numbers come from a hand-worked model of the current formulas. A
simulator script sits next to this guide (`two-clocks.sim.py`) for anyone who wants to run it.

## What to look for

In the order you will find them.

1. **Spiritual root (linh căn): Wood and Fire, purity 70 or more.** *In the game.* Each element's purity
   strengthens its own stacks (about +16 % at purity 80), and Wood feeding Fire helps the main technique.
2. **Talents:** Comprehension first (technique layers, Đạo glimpses), Căn cốt (bone, health) second. *In the game.*
3. **Đạo (the Way) and nodes.**
   - **Hỏa Đạo** (Burning Heaven), facet **Tro Tàn** (Ash). It holds **Ash Ledger** and **Cinder Debt**, plus Fire
     penetration and Burn stack strength. *Not in the game yet (staged: tro-tan-ledger, ash-ledger, cinder-debt).*
   - **Hỏa Đạo**, facet **Chân Hỏa** (True Flame): **Banked Coals**. *Not in the game yet (staged: banked-coals).*
   - **Độc Đạo** (Ten Thousand Poisons), facet **Nọc** (Venom). It holds **Spillover (Dật Độc)**, Poison stack
     duration, Chaos penetration and Rot Deepens. Spillover is *in the game* (designed); the placement is *not in the
     game yet (staged: noc-spillover)*. Rot Deepens is *not in the game yet (staged: content ledger, Rot Deepens)*.
   - **Meridian Map keystone Embers Feed the Hearth (Tàn Hỏa Dưỡng Lô)** in the Fire land. *Not in the game yet
     (staged: embers-feed-the-hearth).*
   - **Sealed cluster Sick Meridians (Bệnh Mạch)**, ending in **Bare Vessel**. *Not in the game yet (staged: content
     ledger, Bare Vessel; Sick Meridians).*
   - Everyday tree nodes: damage over time, Poison damage, Fire damage, stack effect and stack duration by element,
     Fire and Chaos penetration, linh lực regeneration. *In the game* (designed in the Modifier System).
4. **Công pháp (technique): Green Flame Scripture (Thanh Diễm Quyết)**, a main technique naming Wood and Fire. Take
   the Địa giai copy at Core Formation, and the Thiên giai copy (Thanh Diễm Thiên Kinh) before Deity Transformation.
   *Not in the game yet (staged: green-flame-scripture).*
5. **Arts (thần thông)**, all from the scripture: **Ember Rain**, **Rot Seed**, **Spring Sap**, **Red Censer**,
   **Green Censer**. *Not in the game yet (staged: ember-rain, rot-seed, spring-sap, red-censer, green-censer).*
6. **Items.**
   - An **Ember Fan** (fan, Phiến) and a **Spore Gourd** (gourd, Hồ Lô) for gear damage. *In the game* (bases exist).
   - A ward robe (armour, Giáp). *In the game.*
   - **Corpse-Wax Coating (Thi Lạp)** and a Kindling pill for prepared fights. *Not in the game yet (staged:
     content ledger, Corpse-Wax Coating; Kindling pill).*
   - Wards: Common Ward, Mountain Screen, Golden Light Shield, then Clear Heart Ward and Thousand-Layer Cloud. *In the
     game* (designed).
7. **Enabler: the Twin-Wick Incense Clock (Song Tâm Hương Chung)**, a bell-based artifact from a burned mountain
   temple, found around Nascent Soul. *Not in the game yet (staged: incense-clock).*

## The enabling Effects

- **Twin-Wick Incense Clock (the enabler).** Your "while" and "after" damage bonuses (layer L5) also apply to your
  damage over time. Normally they only touch direct hits. **The price:** your hits deal no damage at all, arts and
  basic attack alike; they only lay stacks. The build needs it because without it, Bare Vessel and the other L5 pieces
  do nothing for ticks, and the second clock never speeds up.
- **Ash Ledger (the identity piece).** 20 % of the tick damage the enemy's resistance stops burns their linh lực. The
  build needs it because otherwise a heavily warded enemy keeps casting for twice as long, and that is how you die.
- **Spillover.** 25 % of the tick damage that lands also burns their linh lực. It is the other half of Ash Ledger:
  whether their resistance is high or low, the first clock runs.
- **Embers Feed the Hearth.** Each Burn tick gives you back a quarter of its damage as linh lực. Your arts cost
  0.07 of your pool a second against 0.044 of regeneration; this pays the difference. Its usual price ("your Fire hits
  deal 15 % less") costs you nothing, because your hits deal nothing anyway.
- **Bare Vessel.** +80 % more damage while the enemy has under 5 % linh lực: the second clock's payoff.
- **Fuel for the Fire.** Burn deals +3 % more for every 5 Poison stacks on the target, so the slow clock feeds the
  fast one.
- **Kindled Wound** and **Marked Prey.** Small extras on the same layer: +15 % to Burn against a burning target, and +8 %
  for carrying two different statuses.
- **Cinder Debt.** If the enemy cleanses your stacks, each stack removed burns 0.5 % of their maximum linh lực. It
  does not save your stacks; it makes cleansing cost them.

## Modifiers to stack

Most important first. "Layer" is where the bonus multiplies (L1 increased, L2 art "more", L3 gear, L4 preparation, L5
conditional).

1. **Stacks per batch and their strength:** stack effect for Fire debuffs and Wood debuffs (about +36 % each). It
   multiplies the stacks themselves, outside the layers. Stop when the other items below are cheaper per point.
2. **Penetration, Fire and Chaos (+120 points each).** Not a layer. Penetration past an enemy's resistance makes it
   negative, and negative resistance amplifies. This is why the typical foe dies one pulse after the first bell. Stop
   around +120 to +200: past the enemy's kept resistance it only matters after the bell.
3. **Linh lực regeneration (+1 pp)** until your arts never wait. Watch the "own dry" line; with Embers you rarely
   need more than one notable.
4. **L2 "more": Green Flame's +40, Rot Deepens +40 (Poison), Banked Coals +40 (Burn), a Đạo notable.** Aim for about
   +150 per family. The hard cap is +300.
5. **L1 increased: damage over time, Poison, Fire.** Past +200 each point counts half (soft cap), and +400 is the
   hard cap. About +300 is the sensible stop.
6. **Stack duration for Wood debuffs (+60 %).** Only Poison wants it: Burn's batches are meant to be short. Stop when
   a batch outlasts the fight (16 s is plenty).
7. **L3 gear (+200).** Fan and gourd attack. The cap is +250.
8. **L4 preparation: Corpse-Wax Coating +60, Kindling pill +40.** Cap +150. Prepared fights only.
9. **L5 (with the clock): Bare Vessel 80, Fuel for the Fire, Kindled Wound 15, Marked Prey 8.** The cap is +100, and
   Burn reaches it after the first bell. Do not chase more L5.
10. **Root purity.** Each 10 points of purity is +2 % per stack. Nice, not urgent.

## Upgrades to look for

Your shopping list, core first. The last rows are what turn a working build into a top-end one. "Staged" pieces
exist only on paper so far; the ID is from the staging catalogue unless noted.

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Twin-Wick Incense Clock (Song Tâm Hương Chung) | Effect (enabler) | Opens your "while" and "after" bonuses (layer L5) to your ticks; without it Bare Vessel does nothing for them. Kill on a strong foe falls from about 11 s to about 8 s | Named item, bell (Chuông), burned mountain temple ruins or a Nguyên Anh cultivator of this path | not in the game yet (staged: incense-clock) | core |
| Ash Ledger (Tro Trướng) | Effect | 20 % of the tick damage resistance stops burns their linh lực; makes the first clock blind to resistance | Hỏa Đạo (Burning Heaven), facet Tro Tàn (Ash), notable | not in the game yet (staged: ash-ledger, tro-tan-ledger) | core |
| Green Flame Scripture (Thanh Diễm Quyết) and its five arts (Ember Rain, Rot Seed, Spring Sap, Red Censer, Green Censer) | Effect (arts) plus +40 more damage over time | The two clocks themselves, plus a sustain buff; the passive is your L2 "more" | Công pháp (technique), Địa giai then Thiên giai copy | not in the game yet (staged: green-flame-scripture, ember-rain, rot-seed, spring-sap, red-censer, green-censer) | core |
| Embers Feed the Hearth (Tàn Hỏa Dưỡng Lô) | Effect (keystone) | Burn ticks refill a quarter of their damage as your linh lực; pays the arts' bill. Its close costs you nothing | Meridian Map, Fire land | not in the game yet (staged: embers-feed-the-hearth) | core |
| Spillover (Dật Độc) | Effect | 25 % of landed tick damage burns their linh lực; the first clock runs whatever their resistance | Độc Đạo (Ten Thousand Poisons), facet Nọc (Venom), notable | in the game (designed); placement not in the game yet (staged: noc-spillover) | core |
| Stack effect for Fire debuffs and Wood debuffs | Modifier | About +36 % on every stack, outside the layers | Tree notables and smalls, Hỏa Đạo, Độc Đạo | in the game (designed) | core |
| Fire and Chaos penetration | Modifier | +120 points each; pushes resistance negative so it amplifies | Tree, Hỏa Đạo Tro Tàn, Độc Đạo Nọc | in the game (designed) | core |
| Banked Coals (Than Ủ) | Modifier ("more", +40 Burn) | A fresh L2 multiplier on the fast clock | Hỏa Đạo, facet Chân Hỏa (True Flame), notable | not in the game yet (staged: banked-coals) | strong |
| Rot Deepens (Thi Độc Thâm) | Modifier ("more", +40 Poison) | The same for the slow clock | Độc Đạo notable | not in the game yet (staged: content ledger, Rot Deepens) | strong |
| Bare Vessel (Lộ Đỉnh) | Effect | +80 % more damage to ticks while the enemy has under 5 % linh lực: the second bell | Sealed cluster Sick Meridians (Bệnh Mạch) | not in the game yet (staged: content ledger, Bare Vessel; Sick Meridians) | strong |
| Corpse-Wax Coating (Thi Lạp) and a Kindling pill | Modifier (layer L4, +60 and +40) | Roughly doubles every tick in a prepared fight | Preparation (coating); Alchemy (pill) | not in the game yet (staged: content ledger, Corpse-Wax Coating; Kindling pill) | strong |
| Damage over time, Poison damage, Fire damage | Modifier (L1 increased) | Up to about +300 in total; past +200 each point counts half | Tree nodes, Đạo | in the game (designed) | strong |
| Ember Fan (Phiến) and Spore Gourd (Hồ Lô) with weapon attack, plus a Fire-penetration affix on the fan and a Wood stack-duration affix on the gourd | Modifier (L3 gear) | About +200 gear attack; the affixes feed your reach and Poison length | Item affixes, high-grade bases | in the game | strong |
| Stack duration for Wood debuffs | Modifier | +60 %: Poison batches last 16 s instead of 10 s | Độc Đạo Nọc, tree | in the game (designed) | strong |
| Fuel for the Fire (Tân Hỏa) | Effect | Burn +3 % more per 5 Poison stacks; the slow clock feeds the fast one | Mộc Đạo (Wood) notable | not in the game yet (staged: fuel-for-the-fire) | nice |
| Cinder Debt (Tẫn Trái) | Effect | Each stack a cleanse removes burns 0.5 % of their maximum linh lực; makes cleansers pay | Hỏa Đạo, Tro Tàn, minor | not in the game yet (staged: cinder-debt) | nice |
| Linh lực regeneration | Modifier | +1 pp until your arts never wait | Tree notable | in the game | nice |
| Kindled Wound and Marked Prey | Effect (small L5 bonuses) | +15 % Burn on a burning target; +8 % for two statuses | Hỏa Đạo; item | in the game (designed); Kindled Wound, Marked Prey are in the design GDDs | nice |
| Damage to an enemy with no linh lực | Modifier | +15 % on a notable; lands in the same window as Bare Vessel | Tree notable | in the game (designed, catalogue) | nice |
| Status chance and status duration | Modifier | Lifts your stacks off the 5 % floor against status-resisting foes; your worst matchup | Tree nodes | in the game (designed, catalogue) | nice |
| Ward set: Clear Heart Ward, Thousand-Layer Cloud, Golden Light Shield | Effect (wards) | Lets you stand still until the first bell; Clear Heart Ward against poisoners and cursers | Ward slots at Nguyên Anh and Hóa Thần | in the game (designed) | nice |
| Spiritual root (linh căn) purity | Modifier | Each 10 points of purity is +2 % per stack | Wood and Fire purity 70 or more | in the game | nice |

**What makes it top-end:** the Incense Clock, Ash Ledger and Bare Vessel together. Add the coating and pill for
prepared fights, and Fire and Chaos penetration past the enemy's kept resistance. A build with the stack but
without the Clock still wins, just about three seconds slower.

## Realm by realm

- **Core Formation (Kết Đan).** You have the scripture, Ember Rain and Rot Seed, the two Censers, Spring Sap,
  Ash Ledger and Embers, but no enabler. You drown wards: the first bell rings at 3–4 s, and the ticks then land against
  a ward that has gone out. Your hits still deal a little. You beat ordinary cultivators in about 4 s and strong ones
  in about 14 s.
- **Nascent Soul (Nguyên Anh).** You find the Incense Clock. Your hands go quiet and the smoke gets teeth: Bare
  Vessel now reaches your ticks, and strong foes fall in about 8 s. A third ward slot takes Clear Heart Ward against
  poisoners and cursers; a sixth art slot takes Golden Light Shield for the first seconds.
- **Deity Transformation (Hóa Thần).** The Thiên giai scripture, a seventh slot (a third Poison source or an escape
  talisman), a fourth ward slot (Thousand-Layer Cloud), and +1 Poison per batch. The shape stays the same; every
  number grows.

## How it plays

**Art order (slot order matters: the earlier slot pays first when linh lực is short):**

1. Ember Rain: 20 Burn for 2 s, every second. The fast clock; it must never wait.
2. Rot Seed: 4 Poison for 16 s, every second. The slow clock.
3. Spring Sap: 6 Wood buff stacks for 10 s, every 2 s. About 30 stacks, regrowing 3.5 % of your health a second.
4. Red Censer: a second Burn source, every 2 s.
5. Green Censer: a second Poison source, every 2 s.
6. Golden Light Shield (Nascent Soul): a shield on a 4 s cooldown for the seconds before the first bell.

**Wards:** Common Ward and Mountain Screen at Core Formation; add Clear Heart Ward at Nascent Soul and Thousand-Layer
Cloud at Deity Transformation.

**The signature moment:** about three seconds in, the enemy's Breakdown shows linh lực 0. Their arts stop, and on the
very next pulse your ticks jump from about 40 to about 260 raw per family. The first bell, then the second.

## What beats it

- **A cultivator who resists statuses, not damage.** Clear Heart Ward (+37.5 pp), plus status resistance against
  damage over time (+30 pp) and against poison (+40 pp), pushes your stacks to the 5 % floor. You have no hits, so you
  lose. *Adapt:* in a foreseen fight against a known resister, leave the Incense Clock at home so your arts' hits
  deal damage again. You will be weak, but not helpless.
- **Burst builds that end it before the third second** (top-end "first volley" cultivators). *Adapt:* take more
  ward and Golden Light Shield, and put Ember Rain first so the first bell comes as early as it can. Even so, this is
  a bad matchup.
- **Cleansers** (Clear Heart Ward's 25 % per pulse). Your Poison stalls at about 15 stacks, while Burn's short
  batches mostly tick before the cleanse. *Adapt:* lean on Burn and Cinder Debt; expect a 13 s fight rather than an
  8 s one.
- **Reserved-ward foes** (Still Lake Aura). Their resistance never falls, but the first bell still silences their
  arts, so you win more slowly.
- **Blind fights.** You lose your coating and pill (layer L4, ×2.0 → ×1.0), so every clock runs about half as fast.
  Carry the build into fights you choose.

## Not in the game yet

Every staged piece this build needs (IDs from the staging catalogue unless named otherwise):

- **Enabler:** incense-clock (Twin-Wick Incense Clock).
- **Effects:** ash-ledger (Ash Ledger), cinder-debt (Cinder Debt), embers-feed-the-hearth (Embers Feed the Hearth),
  fuel-for-the-fire (Fuel for the Fire).
- **Modifier:** banked-coals (Banked Coals).
- **Technique:** green-flame-scripture (Green Flame Scripture, Địa and Thiên giai).
- **Arts:** ember-rain, rot-seed, spring-sap, red-censer, green-censer.
- **Đạo placements:** tro-tan-ledger (Hỏa Đạo, Tro Tàn), noc-spillover (Độc Đạo, Nọc).
- **Readables:** tick-prevented-points, cleansed-stacks-event.
- **From the content ledger:** Bare Vessel (Lộ Đỉnh), Rot Deepens (Thi Độc Thâm), Corpse-Wax Coating (Thi Lạp), and
  the Sick Meridians (Bệnh Mạch) cluster idea.
- **Unnamed:** a Kindling pill (an L4 tick pill; any Alchemy L4 pill does the job).

## Changes the game would need

1. **Let an Effect extend L5 to damage over time.** Combat (`design/gdd/combat.md`) Formulas F says ticks use layers L1
   to L4. Add: "an Effect may state that its owner's L5 payloads also apply to that owner's ticks; the L5 cap is
   unchanged". Only the Incense Clock does this, and it costs every hit. This also fixes the staged Fuel for the Fire,
   which does nothing under today's rule.
2. **Two new readables for Effects.** Effects System (`design/gdd/effects.md`) rule 5, and Combat rule 9's event list:
   (a) a tick's prevented points (for Ash Ledger), and (b) "your stacks were removed by a cleanse" (for Cinder Debt).
3. **Bound an art's stack grant at the charge cap.** Effects System Formulas D and AC-EF-69 let an art whose charge would
   pass 0.6 simply pay 0.6, so its stack grant has no ceiling. Make such an art fail the lint: one firing grants at
   most 40 debuff (or 60 buff) stack-seconds. Without this, "the fastest legal kill clock" has no answer.
4. **Price or floor front-loaded batches.** Effects System rule 9a and Formulas D charge 40 stacks for 1 s the same as
   4 stacks for 10 s. The short batch skips the ramp and ticks before a cleansing ward (`design/gdd/combat-defence.md`
   rule 6) can thin it. Pick one: a minimum batch of 2 pulses, a higher weight for short batches, or a cleanse that
   also thins a batch on the pulse it lands. This build already uses 2 s Burn batches, the shortest a floor would keep.

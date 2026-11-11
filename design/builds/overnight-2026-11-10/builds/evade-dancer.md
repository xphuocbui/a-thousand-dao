# Drifting Wind Dancer (Phiêu Phong Vũ Giả)

A Wind cultivator who treats every dodged blow as income: each miss pays linh lực, stacks speed and counts toward a free counter-cut.

## Why it works

Evade has a hard ceiling: `evade_cap` is 0.40, so at best 4 hits in 10 never land. Most builds stack evade as a quiet defence stat and stop. The dancer turns each evaded hit into three payments (the enabler, Unstruck Body, makes an evaded hit an event the build can listen to):

- **Linh lực:** 1 % of maximum linh lực per evaded hit (first guess). Linh lực is mana and ward in one pool, so every miss refills the thing that keeps you alive.
- **Speed:** 1 Wind stack for 8 s per evaded hit. A Wind stack is +7.5 % art speed, and speed stops at `cooldown_min` (0.5 s), so after a few seconds the arts run at the floor.
- **A counter:** every fourth evaded hit fires a free riposte, the Reply (a trigger hit, small, never the main damage).

Two more rules close the loop. **Carried Off** removes one debuff stack batch from you for each evaded hit (once per pulse): this is the answer to ticks. **Surplus Breeze** turns evade points above the cap into art speed, so stacking evade past 40 % is never wasted.

The price is the soul: while Unstruck Body is on, soul resistance is 0 and no soul ward can be carried.

Key numbers (all first guesses): evade at the cap 0.40; realm step +0.02 per realm above the foe; Evade Pays +1 % linh lực; Wind stack +7.5 % art speed for 8 s; Reply every 4 evades; Surplus Breeze +0.5 % art speed per point over the cap, up to +20 %. Evade is not enough alone: you still need ward and body layers, because 60 % of hits still land.

## What to look for

In the order a player finds them.

1. **Spiritual root (linh căn): Wind (phong), purity 80 or higher.** In the game.
2. **Talents: Agility and Comprehension.** Agility feeds evade; Comprehension speeds the scripture's layers. In the game (existing stat keys).
3. **Đạo: Phong Đạo (Thanh Phong), Drift (Phiêu) and Gale (Cuồng Phong) branches.** The Way is in the game; the Surplus Breeze notable and the Scatter Gale art on the Drift Facet are not in the game yet (staged: surplus-breeze, tan-phong).
4. **Công pháp: Reed-Shadow Scripture (Lô Ảnh Kinh), main, tier 3.** Not in the game yet (staged: reed-shadow-scripture). Its layer-6 ability is the enabler, Unstruck Body (Bất Xúc Thân).
5. **Arts:** Reed-Cutting Breeze, Hollow Step, Falling Leaf, Scatter Gale, Gale Crown. Not in the game yet (staged: the five art records).
6. **Items:** Cicada-Wing Sash (Thiền Dực Đới), Clear-Breeze Pill (Thanh Phong Đan), Crosswind Array (Giao Phong Trận). Not in the game yet (staged under those names). A weapon rolling the Gale affixes (Tật, Hồi Khí, Hấp Huyết) is the reused part (staged by another build).
7. **Enabler: Unstruck Body.** Not in the game yet (staged: unstruck-body). Found by finishing the Scripture's layer 6, whose seal condition is surviving a fight with no hit landed.

## The enabling Effects

| Effect | What it does | Why the build needs it |
|---|---|---|
| Evade Pays (Tị Hồi) | An evaded hit restores 1 % of maximum linh lực, adds 1 Wind stack for 8 s, and moves the Reply counter | Without it evade is only a defence stat. This is the build |
| Reply (Hồi Báo) | Every 4th evaded hit fires a free riposte (trigger channel, `c_trig`, within `trig_budget`) | Turns misses into damage and into statuses |
| Carried Off (Phong Tải) | An evaded hit removes one batch of a debuff stack from you, at most once per pulse | The build's answer to ticks, since ticks are never evaded |

## Modifiers to stack

Priority list, most important first.

1. **Evade (`evade_pct`)**, layer: defence. Reach 55–65 pp so the cap still holds against the foe's accuracy. Stop once you are at the cap against your usual foes; surplus becomes speed through Surplus Breeze, up to +20 % art speed.
2. **Wind damage (increased)**, L1. Falling returns past +200 (the soft knee counts half), so stop there and fill other layers.
3. **Wind-Fed Edge (more per Wind stack)**, L2. Up to 10 stacks, +20 %; stop at 10.
4. **Art speed**, rate. Stops at `cooldown_min`; Wind stacks and Surplus Breeze both feed it, so stop buying it once arts sit at 0.5 s.
5. **Linh lực regeneration and art cost**, fuel. No cap on regeneration, falling returns on its log curve.
6. **Gear L3, Crosswind Array and pill L4, Rhythm of the Miss L5.** Each layer has its own cap (250 / 150 / 100); a layer you skip gives up its whole factor.
7. **Crit chance and crit damage.** Crit caps at 0.5 and 3.0; the dancer reaches about 0.2 and 2.0.
8. **Veiled Aim (foe accuracy down).** Lets less evade reach the cap.
9. **Ward and body layers.** Fill them: 60 % of hits still land.
10. **Trigger limit +1.** Raises the Reply's rate; stop after one.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Unstruck Body | Effect (enabler) | makes evaded hits pay | Reed-Shadow Scripture layer 6 | staged: unstruck-body | core |
| Evade Pays | Effect | linh lực and Wind stacks per evade | enabler | staged: evade-pays | core |
| Carried Off | Effect | removes your debuff stacks, the answer to ticks | enabler | staged: carried-off | core |
| Evade | Increased | the cap of 40 % | tree acupoints, Drift Facet, sash, pill | in the game | core |
| Surplus Breeze | Overflow | evade above the cap becomes art speed | Phong Đạo Drift Facet notable | staged: surplus-breeze | core |
| Wind-Fed Edge | Per (L2) | up to +20 % more Wind damage | Reed-Shadow Scripture bonus | staged: wind-fed-edge | strong |
| Reply | Effect | free counter per 4 evades | enabler | staged: reply | strong |
| Rhythm of the Miss | Conditional (L5) | +25 % more damage for 2 s after an evade | Reed Drift cluster notable | staged: rhythm-of-the-miss | strong |
| Cicada-Wing Sash | Artifact (L3) | +10 pp evade, art speed, Gale affixes | named artifact | staged: cicada-wing-sash | strong |
| Crosswind Array | Formation (L4) | foe accuracy −10 pp, evade +8 pp | formation (trận pháp) | staged: crosswind-array | strong |
| Veiled Aim | Flat base | foe accuracy down | formation, Đạo | staged: veiled-aim | strong |
| Gale affixes (Tật, Hồi Khí, Hấp Huyết) | Increased | art speed, regen, leech on a weapon | item affixes | staged by another build | strong |
| Clear-Breeze Pill | Pill (L4) | +6 pp evade for one fight | alchemy | staged: clear-breeze-pill | nice |
| Trigger limit +1 | Cap shift | Reply fires more often | Reed Drift cluster | catalogue idea, not in the game | nice |
| First firing comes sooner | Timing | arts start earlier | Reed Drift cluster | catalogue idea, not in the game | nice |
| Status duration | Increased | Wind stacks last longer | Reed Drift cluster | catalogue idea, not in the game | nice |
| Top-end ward and body layers | More | what turns a working dodger into a top-end one | technique, gear, formation | in the game (layers W2–W5, B2–B5) | core |

## Realm by realm

- **Trúc Cơ (Foundation):** evade about 15 pp, a short Wind stack from the first two arts. Evade Pays is not unlocked.
- **Kết Đan (Core Formation):** Unstruck Body unlocks at layer 6. Wind stacks make you fast and linh lực comes back. Typical same-realm foes fall in 5 s in the simulation.
- **Nguyên Anh (Nascent Soul):** evade at the cap, Gale Crown and Surplus Breeze. Typical foes fall in a volley or two; a top-end same-realm foe is an even fight (13 wins, 6 losses, 1 draw), and one realm higher you lose.

## How it plays

**Art order:** Reed-Cutting Breeze (2 s), Hollow Step (3 s), Falling Leaf (4 s), Scatter Gale (6 s), Gale Crown (8 s). Open with the cheap ones to start the Wind stack; Gale Crown arrives after the first volley.

**Loadout:** five arts and a free sixth slot at Nguyên Anh for a talisman. Drain ward with its layers near caps, body layers filled. Put the Sash, a weapon with the Gale affixes and the Crosswind Array into the prepared layers.

**Signature moment:** Gale Crown fires with ten Wind stacks, every other art is pinned at 0.5 s, and the foe's last Burn stack drops off the same breath.

## What beats it

- **Thần thức cultivator with a soul art.** Soul ignores layers and evade, and your soul resistance is 0. Adapt: win before they cast, or give up the enabler and wear soul gear.
- **Fast stackers (poison, burn).** Carried Off clears 1 batch per pulse and Scatter Gale 2 per 6 s; a stacker that lays more than that wins. Adapt: kill faster or pack a cleanse talisman.
- **Measured Stroke users.** Arts with a cooldown of 20 s or more cannot be evaded. You survive one hit by layers, then they run dry.
- **Earth and Thunder accuracy stacks.** Their accuracy stacks eat into your evade; bring Veiled Aim.
- **Qi burners (Qi Disruption).** The build runs on a pool. Keep Evade Pays flowing and burn them first.

## Not in the game yet

Staged: Unstruck Body, Evade Pays, Reply, Carried Off, Surplus Breeze, Wind-Fed Edge, Rhythm of the Miss, Veiled Aim, Reed-Shadow Scripture, the five arts (Reed-Cutting Breeze, Hollow Step, Falling Leaf, Scatter Gale, Gale Crown), Cicada-Wing Sash, Clear-Breeze Pill, Crosswind Array, the Drift Facet lines and notable, the Reed Drift cluster, and the hit-evaded event.

## Changes the game would need

1. **Hit-evaded event.** Touches Combat Formulas I and Effects rule 9. Today an evaded hit fires no triggers; it needs one event the Effects can read.
2. **Evade overflow readable.** Touches Combat Formulas I: report the points `evade_cap` clipped, for Surplus Breeze.

Both are written in `evade-dancer.suggestions.md`.

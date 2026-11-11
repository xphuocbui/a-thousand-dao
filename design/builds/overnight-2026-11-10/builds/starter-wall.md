# The Patient Wall (Nại Bích)

A safe first build: an Earth-root cultivator who is very hard to kill, wins slowly, and learns what a ward, a guard and regeneration do.

## Why it works

Three things defend you at once, and each is paid for differently:

- **The ward** is built from your linh lực. It stops a share of every hit, and it drains as it stops them. When your linh lực is empty, the ward is gone.
- **The body** (block, body resistance and the body shield) costs no linh lực. It keeps working when the ward falls.
- **Regeneration** puts linh lực back every pulse (a second), and a heal art puts health back.

A foe has to get through the ward, then the body, then the health bar, and you keep refilling all three. In the simulator, at Foundation (Trúc Cơ) against a typical cultivator of the same realm, the wall won 20 fights out of 20. They lasted about 65 s, and you finished with about 70 % health.

The numbers that matter: ward layers of about 50 / 47 / 20 and body layers of about 50 / 47 / 20, linh lực regeneration of about +2.5 points a pulse, health regeneration of about +1.5 points a pulse. Your damage is deliberately low: about +90 % in the everyday layer and almost nothing else.

A **guard** is a condition printed on an art: it fires only when the condition is true. Your heal has one: it fires only when your health is at or below 60 %. That is the whole idea of a guard. It waits, and it does not waste linh lực while you are healthy.

## What to look for

In the order you find them.

| Piece | What it is | Status |
|---|---|---|
| Spiritual root (linh căn) | Earth (Thổ), single root, purity about 50 is enough | in the game |
| Talents | Physique first, Comprehension second | in the game |
| Đạo | Thổ Đạo (Unmoving Mountain): the Sơn Thể (block) facet first, then Trần Bích (Earth stacks) | in the game (the Way is designed; its nodes are not all built) |
| Main công pháp | Hậu Thổ Địa Quyết (tier 2): +12 % linh lực, +8 % heart-demon resistance; reaches Core Formation (Kết Đan) | in the game; its three arts are not in the game yet (staged: packed-earth-stance, tremor-palm, mending-breath) |
| Body công pháp | Long Tượng Công (tier 2): +15 % health, +10 % damage | in the game |
| Arts | Packed Earth Stance (Hậu Thổ Trụ Thế), Tremor Palm (Chấn Thổ Chưởng), Mending Breath (Hồi Khí Tức) | not in the game yet (staged) |
| Items | Plain Shield (Thuẫn) for the ward, Hard-Worn Plate (Giáp) for the body | in the game |
| Formation, talisman | Hộ Sơn Trận (at home), Kim Cương Phù (for a fight you did not prepare) | in the game |
| Enabler | None. This build needs no special item | n/a |

## The enabling Effects

The build needs no enabler. It uses one Effect that already exists:

- **Iron Skin Renewed (Thiết Bì Phục).** Each time you fire an art that has a Physical part, your body shield regains 2 % of maximum health, once a pulse at most. It rewards firing the palm and the stance. In the game (Effects System, Starter Effects).

## Modifiers to stack

Most important first. Stop each one when the note says.

1. **Maximum health.** Fills the bar that ends the fight. Take it first, no limit worth reaching.
2. **Linh lực regeneration.** Fuels the ward and the heal. Take until your own linh lực is not dry before the foe's is. Past that, falling returns (a log curve).
3. **Ward strength and ward efficiency.** Strengthens the ward layers. Stop when the ward holds a full fight without your linh lực going dry.
4. **Body guard and body layers.** Block and body resistance. This is the layer that works with no linh lực.
5. **Health regeneration and healing.** Makes Mending Breath stronger. Stop when the heal fires less than once every few seconds.
6. **Art cost reduction.** Cheaper arts leave more for the ward.
7. **Damage (everyday nodes).** Last, because the build wins by outlasting, and a small number is enough. Past +200 % in the everyday layer, points count half.
8. **Stone Does Not Hurry (Thạch Bất Cấp).** +1 % more basic attack damage for each 5 s of the fight, up to +12 %. Not in the game yet. It rewards the long fight you are already having.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Health nodes | Maximum health (`khi_huyet_pct`) | A bigger bar for the whole climb | Tree, small and notable nodes | in the game | core |
| Regeneration nodes | Linh lực regeneration | Ward and heal never run dry | Tree acupoints | in the game | core |
| Ward nodes | Ward strength and efficiency | Stronger, cheaper ward | Tree acupoints | in the game | core |
| Plain Shield (Thuẫn) | Artifact defence, affix Kiên | Feeds the ward layer W3 | Artifact, base `thuan` | in the game | core |
| Hard-Worn Plate (Giáp) | Artifact defence, affix Hộ Thân | Feeds the body layer B3 and adds health | Artifact, base `giap` | in the game | core |
| Mending Breath | Heal art with a guard | Health back when it matters | Hậu Thổ Địa Quyết, layer 6 | staged (mending-breath) | core |
| Long Tượng Công | Body technique | +15 % health, +10 % damage | Công pháp, body kind | in the game | core |
| Spring Returns (Hồi Xuân) | Artifact affix, health regeneration | Heals you a little every pulse | Artifact affix (staged by an earlier build) | staged (hoi-xuan-affix) | strong |
| Hộ Sơn Trận | Formation, defence at home | +10 % defence per level in your own cave | Formation, `ho_son` | in the game | strong |
| Kim Cương Phù | Talisman, +40 % defence once | Safety in an unprepared fight | Talisman | in the game | strong |
| Sơn Thể facet | Block nodes | More flat reduction per hit | Thổ Đạo, Sơn Thể | in the game (nodes not all built) | strong |
| Trần Bích facet | Earth stack duration and count | The stance lasts longer | Thổ Đạo, Trần Bích | in the game (nodes not all built) | strong |
| Iron Skin Renewed | Effect, body shield refill | Refills the body shield as you attack | Effects System | in the game | strong |
| Stone Does Not Hurry | Per modifier on the basic attack | The slow win gets faster | Hidden cluster Settled Earth (Định Thổ) or a technique | staged (stone-does-not-hurry) | nice |
| Iron Marrow (Thiết Tủy) | Keystone: body guard rises as health falls | Harder to finish | Tree keystone idea (Tree Modifier Catalogue) | staged (catalogue) | nice |
| Hot Spring Array (Ôn Tuyền Trận) | Formation, regeneration on its ground | More linh lực and health regeneration at home | Formation (staged by earlier builds) | staged (hot-spring-array) | nice |
| Stone-Marrow Pill (Thạch Tủy Đan) | Pill for the body | A stronger body layer, prepared | Pill (staged by an earlier build) | staged (stone-marrow-pill) | nice |
| Tĩnh Tâm armour affix | Heart-demon resistance, plus a soul-resistance node | The first answer to soul attackers | Artifact affix; tree soul resistance | in the game | strong |

Pieces that turn a working build into a top-end one: the ward and body layers at their caps, which needs the third layer (gear, W3 and B3), the fourth (preparation: formation, talisman, pill) and the fifth (Effects). This build fills layers 2 and 3. The layers it leaves empty are where it can grow.

## Realm by realm

- **Qi Refining (Luyện Khí).** Three slots. The palm and the stance. The Common Ward does the work. You win by outlasting.
- **Foundation (Trúc Cơ).** The guarded heal arrives (layer 6 of the technique), and a Plain Shield. Fights end about 65 s with about 70 % health left.
- **Core Formation (Kết Đan).** Five slots. A talisman and a home formation. Against a typical cultivator at the same realm: 20 wins in 20, about 66 s, about 54 % health left. Your own linh lực runs dry around 28 s, so regeneration matters most here.

## How it plays

- **Art order:** Packed Earth Stance, Tremor Palm, Mending Breath (a fourth slot is free at Foundation).
- **Loadout:** Common Ward with a Plain Shield; Hard-Worn Plate; Hộ Sơn Trận at home; Kim Cương Phù from Core Formation.
- **Signature moment:** the foe's ward breaks around 48 s, and you are still at about 70 % health.

## What beats it

| Enemy | What happens | How to adapt |
|---|---|---|
| Cultivator one realm above | Loses (13.7 s at Foundation) | Fight at home; avoid; or break through first |
| Soul attacker | Soul skips ward and body | Soul resistance node, Tĩnh Tâm armour |
| Curse caster (Withering, Stagnation) | Curses cut your regeneration | A cleanse, a status-resistance node |
| Top-end builds | Over in 2 s | Not a fight to take |
| Burst sword cultivator | Dangerous only if one hit is huge | More health and the heal; the wall otherwise shrugs it |

## Not in the game yet

- Packed Earth Stance, Tremor Palm and Mending Breath (art records; `abilities` lists are empty today).
- Stone Does Not Hurry (a stat key).
- Spring Returns, Hot Spring Array, Stone-Marrow Pill, Iron Marrow (staged by earlier builds or the catalogue).
- Sustained Note (Dư Âm), reused from an earlier build, for the palm.
- Basic attack damage nodes (catalogue rows marked new).

## Changes the game would need

None.

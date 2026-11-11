# The Mirror Hide (Kính Bì)

You do not dodge and you do not ward. You stand behind a hide of stacked block and body layers, let the enemy hit you, and every blow comes back to them, bigger.

## Why it works

Every hit that reaches you, and the part of it your block and shields stop, comes back as a Physical hit on the attacker. The armour sets the share at 30 %. Your damage layers (L1 to L4) then multiply it, and a cap of 2.0 fight units per hit keeps one blow from being everything. The more you stop, the more you return: defence is your offence.

The key numbers:

- **Return:** 30 % of the incoming damage, blocked part included, as a free Physical hit (cap 2.0 U per hit, ticks count 25 %).
- **Layers at Kết Đan (Core Formation):** L1 400 (counts as 250), L2 250, L3 200, L4 120, L5 empty, so M is about 81. Body layers sit at their caps, 300 / 250 / 150 / 100.
- **Earth-Metal stacks:** each Earth stack cuts Physical taken by 1.1 %; each Metal stack on the enemy raises Physical taken by 1.8 %.
- **Price:** no ward, no evade.

On the combat simulator the Return was only approximated (one Physical hit a second), and the build ended a typical same-realm fight in about 1.7 s and lasted about 41 s against a top-end build. Treat those as the target, not a finished result.

## What to look for

In the order you find them.

1. **Spiritual root (linh căn): Earth-Metal (Thổ-Kim)**, purity 70 or more in each. In the game (the roots exist); the stack effects are in the Effects System.
2. **Talents:** Physique first (body layers and block), Comprehension second (the scripture's layers). In the game.
3. **Đạo (the Way):** Nhân Quả Đạo, branch Báo Ứng (Retribution). The Way is listed; its nodes for this build (Every Blow Comes Home, Debt Paid in Kind, Cutting Karma) are not in the game yet (staged: `nhan-qua-bao-ung-return`).
4. **Công pháp: Mirror-Skin Hundred Tempering Scripture (Kính Bì Bách Luyện Kinh).** Not in the game yet (staged: `mirror-skin-scripture`).
5. **Arts:** Packed Earth Stance, Needle Mark, Mending Breath, Open the Mirror, Offering Cut, Thorn Chorus. Packed Earth Stance and Mending Breath are staged by an earlier build (not in the game yet, staged: `packed-earth-stance`, `mending-breath`); the rest are not in the game yet (staged: `needle-mark`, `open-the-mirror`, `offering-cut`, `thorn-chorus`).
6. **Items:** Mirror-Scale Hide armour, Echo-Wall Array, Iron-Sand Hand Bath, Stone-Marrow Pill, Bruise-Blossom Pill, Quiet Mirror Talisman. All not in the game yet (staged: `mirror-scale-hide`, `echo-wall-array`, `iron-sand-hand-bath`, `stone-marrow-pill`, `bruise-blossom-pill`, `quiet-mirror-talisman`).
7. **Enabler:** Mirror-Scale Hide (Kính Lân Giáp), found on a dead garrison quartermaster or in a sealed garrison tomb. Not in the game yet (staged: `mirror-scale-hide`).

## The enabling Effects

- **The Return channel (Phản):** every hit or tick that reaches your defence path comes back as a free Physical hit. Why: it is the whole build. Not in the game yet (staged: `return-channel`).
- **Mirror-Scale Hide:** turns the channel on at 30 % and takes away wards and evade. Why: without it the build is a block tank with a basic attack.
- **Held Reflection (Tồn Ảnh):** what the per-hit cap clips is banked, up to 3 fight units, and Open the Mirror spends it. Why: it lets you bank a top-end hit and answer it later.
- **Self-Wound Counts (Tự Thương Cũng Trả):** health your own arts cost counts as a hit taken. Why: it makes the build work against enemies that will not hit you.
- **Boil Returned (Phản Độc):** when a tick stack on you ends or is cleansed, part of its total returns as a hit. Why: it turns poison and burns into damage.
- **Bait (Mồi Nhử):** a curse that shortens the enemy's basic attack cooldown by 20 %. Why: more hits means more returns.

## Modifiers to stack

Most important first.

1. **Return Share** (flat, the base). The armour gives 30; each notable adds 12 points. Fills the channel's base. Stop around 80 points: the cap clips the rest.
2. **Block and body layers** (B2 to B5). Fills defence and, through the channel, offence. Stop at the layer caps (300 / 250 / 150 / 100).
3. **Return Damage** (increased, L1). Cheap and wide. L1 past +200 counts half, so stop near +300.
4. **Hide Hardens** (per 5 block rating, L2, up to +60). Fills L2 without a slot. Stop at the cap of the Per.
5. **Mirror-Scale plate and a second body piece** (L3). Gear layer. Falling returns after about 200 points.
6. **Echo-Wall Array and the coating** (L4, prepared). Stop at about 120 to 150, the layer cap.
7. **Tick Return Weight** and **Boil Returned**. Make ticks feed the channel. Stop once ticks are half as good as hits.
8. **Return Cap Shift** (+0.25). The only way past the per-hit cap. Rare, take one.
9. **Health regeneration and healing.** Keeps you alive between returns. No cap, falling returns on the log curve.
10. **L5.** Empty on purpose. Nothing here fills it yet; see the table.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Mirror-Scale Hide | Enabler: Return channel | Opens the whole build | Named armour, sealed garrison tomb | staged: `mirror-scale-hide` | core |
| Return Share | Modifier (flat base) | Raises the share past 30 % | Tree notables, the Scripture, the Bruise-Blossom Pill | staged: `return-share` | core |
| Block rating | Modifier | Block layer and Hide Hardens input | Tree, Scripture, armour affix | in the game (designed) | core |
| Body layers B2 to B5 | Modifier | The defence that lets the build stand | Scripture, armour, formation, Effects (B5) | in the game (designed) | core |
| Return Damage | Modifier (increased, L1) | Everyday offence for the channel | Tree nodes | staged: `return-damage` | core |
| Hide Hardens | Modifier (per, L2) | Turns block into return damage | Scripture layer 3 | staged: `weight-of-the-hide` | core |
| Held Reflection | Effect (overflow bank) | Lets you bank big hits for Open the Mirror | Nhân Quả Đạo node, Scarred Hide cluster | staged: `held-reflection` | strong |
| Open the Mirror | Art | Spends the bank in one hit | Scripture layer 8 | staged: `open-the-mirror` | strong |
| Needle Mark | Art (Metal debuff stacks) | Enemy takes 1.8 % more Physical a stack | Scripture layer 2 | staged: `needle-mark` | strong |
| Self-Wound Counts | Effect | Works against enemies that wait | Nhân Quả Đạo, Offering Cut | staged: `self-wound-counts` | strong |
| Boil Returned | Effect | Poison and burn feed the channel | Nhân Quả Đạo, Cutting Karma node | staged: `boil-returned` | strong |
| Quiet Mirror Talisman | Talisman | The soul answer | Sect shop, a talisman recipe | staged: `quiet-mirror-talisman` | strong |
| Echo-Wall Array | Modifier (more, L4) | Fills the prepared layer | Formation recipe | staged: `echo-wall-array` | strong |
| Return Cap Shift | Modifier (cap shift) | +0.25 on the per-hit cap, the step from a working build to a top-end one | Scarred Hide capability | staged: `return-cap-shift` | strong |
| Tick Return Weight | Modifier | Ticks count more | Tree notable | staged: `tick-return-weight` | nice |
| Spring Returns | Affix (health regeneration) | Sustain between returns | Armour or ring affix | staged: `hoi-xuan-affix` | nice |
| Bait | Effect (curse) | More enemy hits a second | Nhân Quả Đạo or an art | staged: `bait` | nice |
| Thorned Skin | Keystone | A weaker return for a player without the armour | Tree keystone | staged (catalogue idea) | nice |
| Iron Marrow | Keystone | Block rises as health falls | Tree keystone | staged (catalogue idea) | nice |
| An L5 source | Modifier (conditional) | Fills the empty layer; what turns a working build into a top-end one | Needs a readable incoming hit | staged: `incoming-hit-readable` | nice |

## Realm by realm

- **Foundation (Trúc Cơ).** A block tank with a 10 % return from the Scripture. You win by outlasting. Four arts: Packed Earth Stance, Needle Mark, Mending Breath, Offering Cut.
- **Core Formation (Kết Đan).** You find the armour. The channel runs at 30 %, wards close, and fights with a typical foe end in a couple of seconds.
- **Nascent Soul (Nguyên Anh).** Held Reflection and Open the Mirror add a burst without leaving your defence. A sixth art, Thorn Chorus, comes in.

## How it plays

Art order: Packed Earth Stance, then Needle Mark, then Mending Breath on its timer, Open the Mirror when the bank is full, Offering Cut when you need a hit from yourself. The Return takes no slot. Loadout: one body armour, a second body piece with Spring Returns, Echo-Wall Array and a coating prepared before the fight. The signature moment: a top-end opponent throws its best strike, your health barely moves, and the same strike lands back on them from the armour.

## What beats it

- **Wind and Ice builds** that evade or wait. Evaded hits return nothing. Answer: Bait to shorten their cooldown, Offering Cut to hit yourself, and fatigue ends the fight at 60 s.
- **Poisoners and burners.** Ticks count at 25 %. Answer: cleanse with Boil Returned, and put Tick Return Weight on the tree.
- **Soul cultivators.** Soul ignores layers. Answer: soul resistance and the Quiet Mirror Talisman.
- **Higher realms.** Suppression and no ward. Answer: stay at your realm or find the Mirror Ward.

## Not in the game yet

Every piece on this guide is staged except the roots, talents, block and body layers: the Return channel, Mirror-Scale Hide, Held Reflection, Self-Wound Counts, Bait, Boil Returned, the Scripture, the arts (Needle Mark, Open the Mirror, Offering Cut, Thorn Chorus), the formation and pills, the talisman, the Đạo nodes, the cluster, and the keys `return_share_pct` and the `return` tag.

## Changes the game would need

1. **A Return channel** (Combat, Formulas G2): a free-hit channel outside the trigger budget, capped per hit. See the suggestion "mirror-hide: Return channel".
2. **Bait curse** (Combat rule 8): a curse that changes the enemy's basic attack cooldown, which today's curses do not do.
3. **Health paid counts as a hit taken** (Combat Defence & Healing rule 1): so a build can feed its own channel.

# The Straw Effigy (Thảo Nhân Chú)

Every small blow writes another curse on your enemy; when the last name goes on, the nail comes down.

## Why it works

Three rules of the game make this build.

1. **Curses change rules, and triggers can lay them for free.** A target holds up to three curses. The triggers in
   this game (things that happen "when your hit lands") can never be your main damage, because their damage is capped
   at half of your real hits. But a curse is not damage, so nothing caps how often a trigger lays one.
2. **Resistance has no floor.** Your enemy's ward stops damage with resistance points. Sundered takes 150 points
   off one damage type for each of its three stacks, and Exposed takes 100 off every type. Push resistance below 0
   and the enemy takes *more* than full damage.
3. **Two curses protect you.** Sealed Meridian makes one of the enemy's damage layers count for nothing for two
   seconds; on a strong enemy's art bonus (their L2, often ×4) that cuts their hits to a quarter. Heavy Breath makes
   their arts cost half again as much.

So the build hits often and cheaply, and every hit lays the next curse in a fixed order (your **litany**). Each curse
laid moves your big art, the **Iron Nail**, half a second closer. When the board is full, the Nail fires, reads how
many curse stacks are on the target, and lands on a ward that has lost 650 points of resistance.

**The numbers** (paper model at Nascent Soul (Nguyên Anh), against the game's "top-end" reference opponent, who fires
a big opener every half second):

| | Result |
|---|---|
| Full build | Win at 1.5 s with about 70 % health left |
| Without Driven Nail (the piece that brings the Nail early) | Win at 2.0 s with about 3 % health: a coin flip on their crits |
| Without Weight of Names (the Nail reading the curses) | Win at 2.0 s with about 43 % health |
| Without the Effigy (no litany) | Loss at 1.0 s |
| An ordinary (typical) cultivator | Dead in 0.5–1.0 s: two blows push their resistance below 0 |

The Nail's first hit at 1.0 s lands about 6,600 damage and makes the enemy's ward pay about 1,900 linh lực for what it
stopped. That is nearly all they have left, and with Heavy Breath on them their next opener costs more than they own.
These numbers come from hand arithmetic on the current rules; the game's fight calculator is out of date with those
rules, so treat them as a careful estimate, not a measurement.

## What to look for

In the order a player usually finds them.

1. **Spiritual root (linh căn): Metal–Wood (Kim–Mộc), Metal higher.** Metal overcomes Wood: the nail through the
   straw. *In the game.*
2. **Talents: root bone (căn cốt) and comprehension (ngộ tính).** Root bone for health, because you must stand two
   enemy openers while your curses go on. Comprehension to reach the technique's middle layers fast. *In the game.*
3. **The technique (công pháp): Straw-Man Litany Scripture (Thảo Nhân Chú Kinh).** A main method, Earth grade (Địa
   giai), Metal and Wood. It holds every art the build uses and its three passives. *Not in the game yet (staged:
   `straw-man-litany-scripture`).*
4. **The arts (thần thông), from the Scripture:**
   - Slipper Blow (Đả Hài Chưởng): a cheap, fast palm that lays Sundered. *Not in the game yet (staged: `slipper-blow`).*
   - Straw Binding (Thảo Phược): a cheap, fast blow that lays Exposed. *Not in the game yet (staged: `straw-binding`).*
   - Iron Nail (Thiết Đinh): the main art, a heavy seal. *Not in the game yet (staged: `iron-nail`).*
   - Ash of the Effigy (Hình Nhân Tro): cleanses curses off yourself. *Not in the game yet (staged: `ash-of-the-effigy`).*
   - Paper Boat Crossing (Chỉ Thuyền Độ): escape. *Not in the game yet (staged: `paper-boat-crossing`).*
   - Paper Money Burning (Phần Chỉ Tiền): a heal, at Nascent Soul. *Not in the game yet (staged: `paper-money-burning`).*
5. **The Way (Đạo): Sinh Tử Đạo, the Diệt facet (Death: curses, withering).** It holds Driven Nail, Marked Prey and,
   at its far end, the Fourth Nail. *The Way is in the catalogue; these nodes are not in the game yet (staged:
   `diet-facet-nails`, `driven-nail`, `fourth-nail`).*
6. **Items:**
   - The enabler, the **Petty-Man Effigy (Tiểu Nhân Hình Nhân)**: see below. *Not in the game yet (staged:
     `petty-man-effigy`).*
   - Coffin-Nail Needles (Quan Đinh Châm): any top-grade needle weapon (`cham`) with an attack affix. *In the game*
     (as a generated weapon).
   - A bell (`chuong`) for ward strength and armour (`giap`) for health. *In the game.*
   - Insect-Waking Incense (Kinh Trập Hương), a pill-incense taken before a planned fight. *Not in the game yet
     (staged: `insect-waking-incense`).*
   - Nine Rods Array (Cửu Can Trận), a formation laid before a planned fight. *Not in the game yet (staged:
     `nine-rods-array`, shared with other builds).*
7. **The tree:** art speed, Physical damage, Physical penetration, accuracy, and the hidden cluster **Nine Knots
   (Cửu Kết)**, which the Scripture unseals. *The plain nodes are designed; the cluster is not in the game yet
   (staged: `nine-knots-cluster`).*

## The enabling Effects

- **The Litany (on the Petty-Man Effigy).** When one of your hits lands, it lays the first curse in the Effigy's list
  that the target does not have yet (or has fewer stacks of than the most). If everything is on, it refreshes the curse
  with the least time left. It skips a curse that cannot be placed again yet. *Why the build needs it:* without it your
  arts lay two curses at most, and none of them is Sealed Meridian, the one that keeps you alive in the first second.
- **Backlash (the Effigy's price).** When your enemy cleanses one of your curses, it lands on you with the time it had
  left. *Why it matters:* this is the build's real weakness, and why it carries Ash of the Effigy.
- **Driven Nail (Đóng Đinh), the identity piece.** Each time you lay a curse (new, a stack or a refresh), your art with
  the longest cooldown comes 0.5 s sooner, up to 3 times a second. *Why the build needs it:* the blows that fill the
  board also bring the Nail, so it fires at 1.0 s instead of 3.0 s, and then about every 1.2 s.
- **Weight of Names (Danh Trọng).** Your hits deal more for every curse stack on the target: +10 % "more" (layer 5) a
  stack, up to +80. *Why:* this is "the main damage reads how cursed the target is". Seven stacks at Nascent Soul give
  +70.
- **Paid in Nails (Đinh Trả).** When the Nail lands on a target bearing every curse of your litany, you get its cost
  back. *Why:* the Nail costs a tenth of your linh lực, and your linh lực is also your ward.
- **The Fourth Nail (Đệ Tứ Đinh), at Nascent Soul.** Your curses can fill a fourth slot. Its price: curses on you last
  twice as long, which makes Backlash worse. *Why:* a fourth name (Heavy Breath) starves the enemy's arts.
- **Marked Prey (Tiêu Ký)** and **Blood Drinker (Ẩm Huyết)**, both already designed: +4 % more per different curse on
  the target, and 6 % of your hit damage back as health.

## Modifiers to stack

In priority order.

1. **Art speed to +100 %** (no layer: speed). It puts Slipper Blow and Straw Binding at the 0.5 s floor, so you hit
   three to five times a second. *Stop at +100 %:* past it the quick arts gain nothing, and the Nail does not need it
   because Driven Nail moves it.
2. **Accuracy** (no layer). An evaded hit lays no curse and moves no nail. *Stop* when the enemies you fight have no
   evade left against you.
3. **Physical penetration** (in the defence path, not a layer). Once your curses push resistance below 0, every point
   is +1 % damage taken. *No cap and no falling returns:* keep taking it after everything else.
4. **Physical damage and tree damage** (L1, "increased"). *Falling returns past +200* (each point counts half); stop
   around 330.
5. **"More" on Metal and seal arts** (L2): Nail Into Straw (the Scripture), the Diệt notables, Tolled Seal (the Nine
   Knots cluster). *Cap 300;* the build reaches about 220.
6. **Gear attack** (L3): a top-grade needle weapon. *Cap 250;* about 150 is the target.
7. **Preparation** (L4): Nine Rods Array (+80) and Insect-Waking Incense (+70) in planned fights. *Cap 150: exactly
   reached.* Nothing in a sudden (blind) fight.
8. **Layer 5 is full**: Weight of Names (+80 at most) and Marked Prey (+16) make 96 of the cap of 100. Take nothing
   else for layer 5.
9. **Curse effect (`curse_effect_pct`), Deeper Nails** (no layer). Makes Sundered and Exposed bigger. *Stop* thinking
   of it for Heavy Breath, Leaking Ward and Withering: those have their own maximum.
10. **Fuel**: linh lực on hit, art cost for curse arts. *Stop* when the quick arts never wait for linh lực.
11. **Health and root bone**. You must survive two enemy openers.

## Upgrades to look for

Your shopping list, core first. "Staged" means the piece is designed but not in the game data yet. The last rows are
the ones that turn a working build into a top-end one.

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Petty-Man Effigy (Tiểu Nhân Hình Nhân) | Effect (the enabler: Litany and Backlash) | Every hit that lands lays the next missing curse in your litany, including Sealed Meridian, which keeps you alive in the first second | Named item (utility artifact, new base `hinh_nhan`): a bridge-shrine event reward, or a weaker copy from a curse-seller | Not in the game yet (staged: `petty-man-effigy`) | core |
| Driven Nail (Đóng Đinh) | Effect (timing) | Each curse laid pulls your Iron Nail 0.5 s closer, so it fires at 1.0 s instead of 3.0 s. Without it you win at 2.0 s with about 3 % health | Sinh Tử Đạo, Diệt facet (`major` node) | Not in the game yet (staged: `driven-nail`, `diet-facet-nails`) | core |
| Weight of Names (Danh Trọng) | Effect (per curse stack) | Your hits deal +10 % "more" (layer 5) per curse stack, up to +80: the Nail reads how cursed the target is | Straw-Man Litany Scripture, layer 7; also a Diệt notable | Not in the game yet (staged: `weight-of-names`) | core |
| Straw-Man Litany Scripture (Thảo Nhân Chú Kinh) | Technique (công pháp) holding Nail Into Straw (+60 "more" on Metal, layer 2) and its passives | Holds every art and passive the build uses; unseals the Nine Knots cluster | Công pháp, Earth grade (Địa giai), Metal and Wood | Not in the game yet (staged: `straw-man-litany-scripture`) | core |
| Iron Nail (Thiết Đinh) | Art (thần thông) | The main damage: a heavy seal that waits for a full board, then lands on a ward stripped of 650 points | Scripture, layer 5 | Not in the game yet (staged: `iron-nail`) | core |
| Slipper Blow and Straw Binding (Đả Hài Chưởng, Thảo Phược) | Arts | Cheap, fast blows that lay Sundered and Exposed and fuel the Effigy: 3 to 5 curses a second | Scripture, layers 1 and 3 | Not in the game yet (staged: `slipper-blow`, `straw-binding`) | core |
| Art speed on curse arts (`art_speed_pct`, curse) | Modifier | Puts the two quick arts at the 0.5 s floor. Stop at +100 % | Tree nodes; Diệt facet stat lines | In the game (designed, partly built) | core |
| Physical penetration (`resist_pen_pct`) | Modifier | Below 0 resistance every point is +1 % damage taken, with no cap and no falling returns | Tree nodes (+100 on a notable) | In the game (designed) | core |
| Spiritual root Metal–Wood (Kim–Mộc) and root bone (căn cốt) | Foundation | Metal arts scope for Nail Into Straw; root bone gives the health to stand two enemy openers | Birth and talents | In the game | core |
| The Fourth Nail (Đệ Tứ Đinh) | Effect (keystone, cap shift) | Opens a fourth curse slot for Heavy Breath: their arts cost half again, so a top-end foe cannot afford its second opener. Price: curses on you last twice as long | Sinh Tử Đạo, Diệt facet far end (Nguyên Anh) | Not in the game yet (staged: `fourth-nail`, `diet-facet-nails`) | strong |
| Paid in Nails (Đinh Trả) | Effect (refund) | The Nail's cost comes back when it lands on a full board, and your linh lực is also your ward | Scripture, layer 10 | Not in the game yet (staged: `paid-in-nails`) | strong |
| Ash of the Effigy (Hình Nhân Tro) | Art (cleanse) | Answers Backlash when a purifier sends your curses home | Scripture, layer 9 | Not in the game yet (staged: `ash-of-the-effigy`) | strong |
| Deeper Nails (Đinh Sâu, `curse_effect_pct`) | Modifier | Makes Sundered and Exposed bigger (Sundered −150 → −187.5 at +25 %) | Nine Knots cluster; Diệt facet lines | Not in the game yet (staged: `deeper-nails`) | strong |
| Accuracy (`accuracy_pct`) | Modifier | An evaded hit lays no curse and moves no nail. Stop when foes have no evade left against you | Tree nodes (+16 on a notable) | In the game (designed) | strong |
| Coffin-Nail Needles (Quan Đinh Châm) | Item (top-grade `cham` needle, attack affix) | Layer 3 gear attack, about 150 | Generated weapon | In the game | strong |
| Nine Rods Array (Cửu Can Trận) | Formation (Ringing Ground, +80 "more" layer 4) | Half of layer 4 in planned fights; nothing in sudden fights | Formation laid before a planned fight | Not in the game yet (staged: `nine-rods-array`) | strong |
| Insect-Waking Incense (Kinh Trập Hương) | Pill-incense (+70 "more" on seal arts, layer 4) | The other half of layer 4; with the Array it fills the cap of 150 | Taken before a planned fight | Not in the game yet (staged: `insect-waking-incense`) | strong |
| Marked Prey (Tiêu Ký) | Effect (+4 % more per different curse, cap +16) | Fills layer 5 to 96 of 100 with Weight of Names | Diệt facet `minor` | In the game (designed Effect; its Diệt placement is staged: `diet-facet-nails`) | nice |
| Blood Drinker (Ẩm Huyết) | Effect (6 % of hit damage back as health) | Survival while the curses go on | The Effigy's second line | In the game (designed Effect) | nice |
| Nine Knots cluster (Cửu Kết) incl. Tolled Seal (Chung Ấn, +40 "more" on seal arts) | Cluster: modifiers (curse effect, art speed, status duration on curses) | Layer 2 "more" plus longer curses that outlast refreshes | Hidden tree cluster unsealed by the Scripture | Not in the game yet (staged: `nine-knots-cluster`) | nice |
| Art cost (curse) and linh lực on hit | Modifiers | Fuel: the quick arts never wait for linh lực | Tree nodes, Diệt lines | In the game (designed) | nice |
| Paper Money Burning and Paper Boat Crossing (Phần Chỉ Tiền, Chỉ Thuyền Độ) | Arts (heal, escape) | A heal at Nascent Soul and an exit against burst builds | Scripture, layers 12 and 11 | Not in the game yet (staged: `paper-money-burning`, `paper-boat-crossing`) | nice |
| Ward bell (`chuong`) and armour (`giap`) | Items | Ward strength and health for the first two openers | Generated artifacts | In the game | nice |

**What turns a working build into a top-end one:** Driven Nail (1.5 s win at 70 % health instead of 2.0 s at 3 %), the
Fourth Nail with Heavy Breath, Weight of Names, and a full layer 4 from the Array and the Incense.

## Realm by realm

- **Core Formation (Kết Đan), early.** The Effigy with three names (Sealed Meridian, Sundered, Exposed), the Scripture
  to layer 5. The Nail comes at 3 s. Against ordinary foes it does not matter: two blows push their resistance below 0.
- **Core Formation, late.** You reach the Diệt facet: Driven Nail brings the Nail to 1.0 s. Weight of Names (layer 7)
  and Ash of the Effigy (layer 9) arrive. You now beat the top-end reference opponent at about 1.5 s with 59 % health.
- **Nascent Soul (Nguyên Anh).** The Fourth Nail opens a fourth name: Heavy Breath. Their arts cost half again as much,
  and with the Nail's bill on their ward, a top-end opponent cannot afford its second opener. Paid in Nails and the
  heal (Paper Money Burning) arrive. Even a boss runs dry, because art costs are a share of its huge pool.

## How it plays

**Loadout at Nascent Soul, in slot order:** Iron Nail, Slipper Blow, Straw Binding, Ash of the Effigy, Paper Money
Burning, Paper Boat Crossing. Wards: a Common Ward and a Mountain Screen in your ward slots.

- **The Nail goes in slot 1**, so it pays first when several arts fire at once.
- **Set the Nail's guard to the last name of your litany** (Exposed at Core Formation, Heavy Breath at Nascent Soul).
  It then waits for a full board and fires the instant the last name goes on.
- **Set the litany for the fight.** Default: Sealed Meridian on their layer 2, Sundered, Exposed, Heavy Breath.
  Against a healer, Withering instead of Heavy Breath. Against a deep-pool ward tank, Leaking Ward.
- **Ash of the Effigy's guard** is "you have Sealed Meridian": the curse Backlash hurts most.

**The signature moment:** at exactly 1.000 s the fourth name goes on, and in the same millisecond the Iron Nail
fires. The enemy's linh lực bar drops from half to nothing on one hit, and their next opener never comes.

## What beats it

- **The alpha striker who starts the fight.** When two arts fire in the same instant, the side that opened the fight
  hits first. A burst build that ambushes you lands its 0.5 s volley before your first curse. *Adapt:* be the one who
  starts fights; carry Paper Boat Crossing; against known burst builds, put more into health.
- **The purifier.** A Light-Way cultivator (Quang Đạo, the Purity facet) who cleanses curses sends them back to you
  through Backlash: your own Sealed Meridian locks your Nail's bonus. *Adapt:* keep Ash of the Effigy slotted; put
  Sealed Meridian last in the litany so the curse they cleanse first is a lesser one.
- **High status resistance.** Curses can fail to land against it. *Adapt:* more hits (art speed, accuracy) beat
  resistance by volume; a 50 % resistant foe still takes a full board, just half a second later.
- **Evasion.** An evaded hit lays nothing. *Adapt:* accuracy.
- **The body cultivator (thể tu) with no ward.** Nothing to starve, and body shields soak Physical hits. *Adapt:*
  Sundered still cuts their Physical resistance; the fight is even, not lost.

## Not in the game yet

Every staged piece this build needs (IDs in the staging catalogue):

- `petty-man-effigy`: the enabler (the Litany and Backlash), on a new artifact base, `hinh_nhan`.
- `driven-nail`: the identity Effect.
- `weight-of-names`: the Per Effect that reads curse stacks.
- `paid-in-nails`: the Nail's refund.
- `fourth-nail`: the keystone that opens a fourth curse slot.
- `deeper-nails`: the `curse_effect_pct` modifier.
- `straw-man-litany-scripture`: the technique.
- `slipper-blow`, `straw-binding`, `iron-nail`, `ash-of-the-effigy`, `paper-boat-crossing`, `paper-money-burning`: the arts.
- `insect-waking-incense`: the preparation incense.
- `diet-facet-nails`: the Way nodes (Sinh Tử Đạo, Diệt facet).
- `nine-knots-cluster`: the hidden tree cluster.
- Shared with other builds: `nine-rods-array` (formation), `cleansed-stacks-event` (the event Backlash reads).

## Changes the game would need

1. **An event "your curse was cleansed from the target"** (Effects GDD, `design/gdd/effects.md` rule 5). Backlash
   reads it. It extends the event two-clocks already asked for (stacks removed by a cleanse) to curses.
2. **A cap shift on curse slots for one keystone** (Combat GDD, `design/gdd/combat.md` Formulas F, `curse_slots`): an
   Effect may let its owner's curses fill one more slot on a target, never more than one. The Fourth Nail needs it.
3. **A new stat, curse effect (`curse_effect_pct`)** (Modifier System, `design/gdd/modifiers.md` Stat List): +X % to the
   numbers your curses change, still clipped by each curse's own maximum.
4. **A clarification of when a curse starts working** (Combat GDD, `design/gdd/combat.md` rule 10, "a status or curse
   applied between pulses first counts at the next one"): the build reads it as "its rule applies at once, its
   duration first falls at the next pulse". If curses instead wait for the next pulse, Sealed Meridian no longer
   protects against the 0.5 s opener and the build loses its top-end matchup.

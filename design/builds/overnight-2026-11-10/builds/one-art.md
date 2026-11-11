# The Empty Hall (Không Đường)

Carry one art, the biggest one the rules allow, and leave every other slot empty: each empty slot makes that one
art faster, heavier and cheaper to keep up, and when it lands the empty hall rings.

## Why it works

**The rules price an art by its cost and its written cooldown, then let art speed take the cooldown away.** The
largest art the art lint (Combat Formulas C) allows costs 12.5 % of your linh lực and has a 12 s cooldown, with a
coefficient of 1.0 × (1 + 24 × 0.125) + 0.25 × 11 = **6.75**. A typical art hits at about 1.6. Nobody slots a
12 s art, because it fires once every 12 s and the first time at 12 s. This build makes it fire every 2.5 s.

**Every empty art slot pays for that.** Art slots grow from 4 at Foundation Establishment (Trúc Cơ) to 7 at Deity
Transformation (Hóa Thần), plus one from the Way's capstone. You fill one. Each of the others gives:

- +40 % art speed (Clear Path): at Hóa Thần, +280 % from seven empty slots, +380 % with the rest, so 12 s ÷ 4.8 = **2.5 s**;
- +0.4 to the art's coefficient, past the lint (the Vow): 6.75 + 2.8 = **9.55** at Hóa Thần;
- +10 points of "more" damage in the Effects layer (Undivided): +70 at Hóa Thần;
- +0.5 points of linh lực regeneration (Quiet Channels), up to +3;
- one ring when the art lands (Empty Hall): a free echo that lays a Metal debuff stack (+1.8 % Physical damage
  taken, ×1.2 at Metal purity 100).

**It never runs dry, so its wards never fall.** Linh lực is both mana and the ward's fuel. At Hóa Thần the art costs
0.106 of your pool every 2.5 s, about 4.3 % a second, and you regenerate 3.5 % + 0.08 × ln(1 + 0.04 / 0.08) ≈ 6.7 % a
second (Combat Formulas E). Half your regeneration feeds the stroke; the other half pays for up to six wards.

## What to look for

In the order you meet them:

1. **Spiritual root (linh căn):** a single Metal (Kim) root, purity 90 or higher. Purity powers the Metal stacks
   your rings lay and the Metal land of the tree. *In the game.*
2. **Talents:** high soul (thần hồn) for thần thức. Thần thức at 1.75 and 3.5 times your realm's reference gives one
   and two extra ward slots. Comprehension helps you learn the technique. *In the game.*
3. **Đạo and nodes:** the Great Way Is Simple (Đại Đạo, Đại Đạo Chí Giản), no requirement. The Way is in the
   catalogue *(in the game as a catalogue entry; its graph is not drawn)*; the nodes you want are *not in the game
   yet*: Clear Path and Quiet Channels in Giản (staged: clear-path, quiet-channels), Empty Hall in Nhất (staged:
   empty-hall), Whole Weight nodes in Bỏ (staged: whole-weight), and the capstone's extra art slot (staged:
   dai-dao-gian-nhat).
4. **Công pháp (technique):** the Whetstone Scripture (Ma Thạch Kinh), Địa giai to Nguyên Anh, then the Whetstone
   True Scripture (Ma Thạch Chân Kinh), Thiên giai to Hóa Thần. It teaches one art and nothing else. *Not in the
   game yet (staged: whetstone-scripture).* Take the Ore-Vein Scripture as a secret art for its Physical damage
   passive. *Not in the game yet (staged: ore-vein-scripture).*
5. **Arts:** the Grindstone Stroke (Ma Thạch Trảm), the only one. *Not in the game yet (staged: grindstone-stroke).*
6. **Items:** the Single-Notch Sword (Nhất Khuyết Kiếm), a flying sword with art speed, Physical penetration and
   Blood Drinker. *Not in the game yet (staged: single-notch-sword).* Any plain armour (giáp). *In the game.* For
   foreseen fights, the Nine Rods Array and an Iron-Sand Hand Bath. *Not in the game yet (staged: nine-rods-array,
   iron-sand-hand-bath).*
7. **Enabler:** the Vow of the One Stroke (Nhất Chiêu Thệ), on the Whetstone Scripture at layer 1. *Not in the game
   yet (staged: vow-of-one-stroke).*

## The enabling Effects

- **Vow of the One Stroke (Nhất Chiêu Thệ), enabler.** Your one art gets +0.4 coefficient for each empty art
  slot, past the normal limit, up to +2.8. In exchange you may never slot a second art, a talisman, an escape art
  or a ward in an art slot. *Why the build needs it:* it is the only way an art grows bigger than the rules allow,
  and it makes the empty slots a promise rather than a mistake. It also means you can never flee.
- **Empty Hall (Không Đường), major.** When your art lands, it rings once in each empty art slot: a small free echo
  with the art's tags that lays one debuff stack of the art's element for 6 s. At most once a second. *Why:* it
  turns the slot count into the target's weakness. Six rings a stroke hold about 14 Metal stacks on the target at
  Hóa Thần, about +31 % Physical damage taken.
- **Clear Path (Thông Lộ), major.** +40 % art speed for each empty art slot, up to +280 %. *Why:* without it the
  12 s art arrives too late to matter.
- **Undivided (Chuyên Nhất), minor.** Your arts deal more for each empty art slot: +10 points in the Effects layer
  each, up to +70. *Why:* the Effects layer (L5) is the one layer a minimalist fills by doing nothing.
- **Quiet Channels (Tĩnh Mạch), minor.** +0.5 points of linh lực regeneration per art slot with no art, up to +3.
  *Why:* fuel for the 12.5 % stroke.
- **Called Blow (Báo Chiêu), keystone.** Your crit chance fills a visible meter instead of being rolled; the crit cap
  falls to 35 %. *Why:* with one art, a run of bad luck is a lost fight. On the meter, about every third stroke crits.
- **Blood Drinker (Ẩm Huyết), major, on the sword.** You restore 6 % of what your hits deal as health. *Why:* the
  stroke is huge, so the heal is too. This is the build's health sustain.

## Modifiers to stack

1. **Art speed** (`art_speed_pct`, rate). Most important: it is what makes a 12 s art usable. Each point is worth less
   than the last (it divides). Stop when the stroke's cost per second reaches your regeneration minus what your
   wards need: about +380 % at Hóa Thần (2.5 s).
2. **Physical, Metal and art damage, "more"** (L2). The stroke's own +30, Whetted Edge +60, Ore Weight +45, Whole Weight
   +40 each. Stop at 300 (L2's cap).
3. **Increased damage** (`attack_pct`, Physical and Metal damage; L1). The everyday stack. Past +200, each point counts
   half.
4. **Crit damage** (`crit_damage_pct`). Under Called Blow your chance stops at 35 %, so the multiplier is where crit
   grows. Stop at ×3.0.
5. **Art cost** (`art_cost_pct`) and **linh lực regeneration**. Only as much as keeps your pool above half.
6. **Thần thức** (`than_thuc_pct`). Up to 3.5 times your realm's reference, for two extra ward slots. Past that it only
   feeds Open Sky (ward strength, up to +30).
7. **Physical penetration** (`resist_pen_pct` [physical]). Against Physical-resistant foes only.
8. **Preparation** (L4): Nine Rods Array and Iron-Sand Hand Bath give 130 of 150. Nothing in a blind fight.
9. **Status resistance**. Your only defence against a Silence on your art.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Vow of the One Stroke | Effect (enabler) | +0.4 coefficient per empty slot, past the lint; no second art, talisman or escape | Whetstone Scripture layer 1; Đại Đạo capstone | staged: vow-of-one-stroke | core |
| Grindstone Stroke | Art | The 6.75 art the whole build feeds | Whetstone Scripture layer 1 | staged: grindstone-stroke | core |
| Clear Path | Effect | +40 % art speed per empty slot | Đại Đạo, Giản facet | staged: clear-path | core |
| Empty Hall | Effect (identity) | One ring per empty slot, each a Metal debuff stack | Đại Đạo, Nhất facet; Whetstone True Scripture layer 15 | staged: empty-hall | core |
| Art speed (`art_speed_pct`) | Modifier | Rate: the 12 s art at 2.5 s | Tree notables, Single-Notch Sword (+30), technique (+40) | in the game (designed key) | core |
| Extra art slot (`bonus_slots`) | Modifier | One more empty slot: +40 % speed, +0.4 coefficient, +10 L5 | Đại Đạo capstone, Less Is Everything | in the game (designed key); capstone staged: dai-dao-gian-nhat | core |
| Quiet Channels | Effect | +0.5 pp regeneration per empty slot, to +3 | Đại Đạo, Giản facet; Porter's Shoulder cluster | staged: quiet-channels | core |
| Undivided | Effect | L5 +10 per empty slot, to +70 | Swept Floor cluster (far notable); Đại Đạo, Giản | staged: undivided | core |
| Opening Haste | Modifier | First stroke at 1.56 s instead of 2.5 s | Whetstone Scripture layer 3 | staged: opening-haste | strong |
| Whetted Edge | Modifier (L2, [kim]) | +60 more damage | Whetstone True Scripture layer 5 | staged: whetstone-scripture | strong |
| Whole Weight | Modifier (L2, [costly, slow]) | +40 more damage each | Đại Đạo, Bỏ facet (×2); Swept Floor notable | staged: whole-weight | strong |
| Ore Weight | Modifier (L2, [physical]) | +45 more damage | Ore-Vein Scripture (secret art) | staged: ore-weight | strong |
| Called Blow | Effect (keystone) | Crits every third stroke, no bad luck | Tree keystone | in the game (Effects GDD; not built yet) | strong |
| Single-Notch Sword | Named item | Art speed +30, Physical pen +60, Blood Drinker, Steady Breath | Named artifact (flying sword) | staged: single-notch-sword | strong |
| Treasure Nurtured Within | Effect (capability #3) | The sword binds no thần thức and grows +1 % a year to +50 % | Tree capability | in the game | strong |
| Crit damage (`crit_damage_pct`) | Modifier | Bigger crits under the meter, to ×3.0 | Tree, Đại Đạo Nhất stat line | in the game (designed key) | strong |
| Nine Rods Array; Iron-Sand Hand Bath | Modifier (L4) | +80 and +50 in foreseen fights | Formation; coating | staged: nine-rods-array, iron-sand-hand-bath | strong |
| Thần thức (`than_thuc_pct`) | Modifier | Two extra ward slots | Technique (+15), tree, Đại Đạo Bỏ | in the game | strong |
| Open Sky | Effect | Wards +0.5 per 1 % free thần thức, to +30 | Đại Đạo, Bỏ facet; tree | in the game (Effects GDD; not built yet) | nice |
| Measured Stroke | Effect | Against evaders: the stroke cannot be evaded (and cannot crit) | Đại Đạo, Nhất facet | in the game (Effects GDD), but its 20 s threshold is out of reach; see the last section | nice |
| Status resistance (`status_resist_pct`) | Modifier | Fewer Silences on your art | Tree, ward payloads | in the game (designed key) | nice |
| Steady Breath | Effect | L5 +12 while linh lực is at 50 % or more (nearly always) | Single-Notch Sword | in the game (Effects GDD; not built yet) | nice |

## Realm by realm

- **Foundation Establishment (Trúc Cơ):** 4 slots, 3 empty. The stroke at 4.8 s (first at 3.7 s), coefficient 7.95,
  three rings. One or two wards. It feels like an executioner: slow and final. Your pool barely moves.
- **Core Formation (Kết Đan):** 5 slots, 4 empty. 4.0 s. Add the Single-Notch Sword and a Clear Heart Ward.
- **Nascent Soul (Nguyên Anh):** 6 slots, 5 empty. 3.2 s, first at 2.0 s. Take Called Blow: every third stroke crits.
  Five wards with a strong thần thức.
- **Deity Transformation (Hóa Thần):** the Thiên giai copy and the Way's capstone. 8 slots, 7 empty. 2.5 s, first at
  1.56 s, coefficient 9.55, six rings (the seventh is lost to the trigger cap), six wards, a pool that never falls
  below half.

## How it plays

- **Art order:** there is one: the Grindstone Stroke in slot 1, everything else empty. No guard on it: it fires as
  soon as it is ready.
- **Loadout:** your free ward slots carry everything else. At Hóa Thần: Common Ward, Mountain Screen, Thousand-Layer
  Cloud, Golden Bell, Clear Heart Ward and Soul-Guarding Lamp. Prepare the Nine Rods Array and the Hand Bath when you
  can see a fight coming.
- **The signature moment:** at 1.6 s the stroke falls; the Breakdown logs six rings and a seventh dropped with the note
  "trigger cap". About every third stroke, the meter fills and it crits.

## What beats it

- **The Silencer.** A curse that blocks the `sword` or `physical` tag stops your only art for up to 5 seconds, and the
  Vow forbids the cleanse art that would fix it. *Adapt:* stack status resistance and wards with status payloads;
  carry the Clear Heart Ward. Against a known silencer, the build is honestly weak.
- **The evader.** One dodged stroke wastes 2.5 s and lays no rings. *Adapt:* accuracy, and Measured Stroke once its
  threshold is fixed.
- **The Physical-resistant foe** (150+ points against Physical). *Adapt:* the stroke's own Sundered (−150), the
  sword's +60 penetration and the Metal stacks bring it back near zero. You have no second damage type.
- **The drainer** (Qi Disruption, soul arts). A 12.5 % stroke is dear when your pool is burned. *Adapt:* the
  Soul-Guarding Lamp and Clear Heart Ward.
- **Anything you must run from.** You have no escape art, ever. Pick your fights.

## Not in the game yet

- Vow of the One Stroke (staged: vow-of-one-stroke)
- Empty Hall (staged: empty-hall)
- Clear Path (staged: clear-path)
- Undivided (staged: undivided)
- Whole Weight (staged: whole-weight)
- Quiet Channels (staged: quiet-channels)
- Opening Haste (staged: opening-haste)
- Ore Weight and the Ore-Vein Scripture (staged: ore-weight, ore-vein-scripture)
- Whetstone Scripture and Whetstone True Scripture (staged: whetstone-scripture)
- Grindstone Stroke (staged: grindstone-stroke)
- Single-Notch Sword (staged: single-notch-sword)
- Nine Rods Array, Iron-Sand Hand Bath (staged: nine-rods-array, iron-sand-hand-bath)
- Đại Đạo's Giản, Nhất and Bỏ nodes and its capstone (staged: dai-dao-gian-nhat)
- Swept Floor cluster (staged: swept-floor-cluster)
- The `art_coef_add` key (staged: art-coef-add-key)

## Changes the game would need

1. **A coefficient past the art lint, from one enabler.** design/gdd/combat.md Formulas C: the lint bounds `c_art` by
   cost and cooldown. Add: "an enabler may add `art_coef_add` after the lint", with a new key `art_coef_add` (flat,
   target art) in design/gdd/modifiers.md's Stat List, rare, Effect payload only.
2. **Measured Stroke's threshold.** design/gdd/effects.md Starter Effects (Rule change): Measured Stroke applies to
   arts with an authored cooldown of 20 s or more, but Combat Formulas A2 caps authored cooldowns at 12 s since #44,
   so it can never apply. Lower it to 10 s.
3. **One meaning of "empty art slot".** design/gdd/effects.md rule 5 (readables, "slots and loadout"): say that an
   empty art slot holds no art, talisman, escape art or ward. Today Bare Rack says "empty" and the staged Quiet
   Channels counts a ward as empty; the per-slot Effects need one count.

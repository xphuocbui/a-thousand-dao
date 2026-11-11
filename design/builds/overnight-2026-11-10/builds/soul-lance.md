# Soul Lance (Hồn Thương)

Never draw a weapon: carry six heavy treasures you never swing, and push a needle of thought through the enemy's soul once a second until the fourth one kills.

## Why it works

A soul attack (thần thức attack) plays by its own rules. It cannot be dodged, it cannot crit, and it ignores the enemy's
wards (hộ thể), resistance, block and body shields. It takes the **same share of the enemy's maximum health and maximum
spiritual power (linh lực) at once**, and that share grows with the **square** of how much stronger your divine sense
(thần thức) is than theirs. Twice their divine sense means four times the share.

Two limits keep it fair: one soul hit can take at most **30 %** (the soul cap), and a cultivator can fire **one soul art a
second** (the soul lockout). So the best any soul build can do is 30 % a second: four hits from full health. This build is
made to reach that ceiling against as many enemies as possible, and to stay alive while it does.

The trick is what it does with its treasures (pháp bảo). Your weapons' attack does nothing for a soul hit, and a soul
cultivator has two or three times the divine sense its treasures need. So instead of weapons it carries **weight**:
bells, a seal, a banner, a shield, all heavy. A new Effect, **Thousand-Weight Thought**, turns the divine sense those
treasures hold into soul damage, and the treasures themselves are your armour. The same divine sense also gives you two
extra free ward slots. One stat feeds the lance, the walls, the treasure count and the treasures' weight.

The numbers (closed-form soul shares, with the timing confirmed by the fight calculator `fight_calc.py`):

- Against an ordinary cultivator of your realm: dead at **4.0 s** (4.5 s at Core Formation). Every hit is at the cap.
- Against a strong cultivator with good soul defence, at Nascent Soul: dead at **4.000 s** (fight calculator). Without
  Thousand-Weight Thought: 5.000 s. Worked by hand, Soul Wound and Splinters of Thought push the enemy's first two arts
  back a full second each, so it fires at most one (the calculator does not model those two Effects).
- At Core Formation, against the same strong foe in the fight calculator: **a win at 11 s; without Thousand-Weight
  Thought, a loss at 12 s** with the enemy at 24 % health. That one Effect is the difference.
- Against a strong foe carrying a Soul-Guarding Lamp (Hộ Hồn Đăng): 6.0 s at Nascent Soul, 5.0 s at Deity Transformation.
- Against an ordinary cultivator **one realm above you**: 6.0 s at Nascent Soul.

## What to look for

In the order a player meets them.

1. **Spiritual root (linh căn): single Water (Thủy)**, purity 70 or more. *In the game.* Soul arts have no element, so the
   root only names the arts' tag; Water gives fast cultivation, the Water main techniques and Water-scoped soul damage nodes.
2. **Talents (thiên phú): soul strength (thần hồn) 85 or more**, then comprehension (ngộ tính). *In the game.* Divine sense
   is soul strength × realm × stage × (1 + bonuses), and it is squared in every lance. If a Fated life rolls soul strength
   70+, this is your build. Spend talent pills on soul strength.
3. **The Way (Đạo): Hồn Đạo · Nguyên Thần (the Soul).** *The Way is in the catalogue; its graph is not drawn yet.* Nodes to
   take: divine sense (`than_thuc_pct`) and soul strength lines in the **Thần Thức** facet, ending at Thousand-Weight
   Thought (*not in the game yet, staged: hon-than-thuc-weight*); soul damage (`x_soul`) and pierce lines in the **Hồn
   Kích** facet, with Soul Wound and Splinters of Thought (*not in the game yet, staged: hon-kich-splinters*); soul
   resistance lines in **Hồn Hộ** (*staged: hon-ho-lines*).
4. **Cultivation techniques (công pháp):**
   - Main method **Huyền Thủy Địa Quyết**, then **Huyền Thủy Thiên Kinh** for Deity Transformation. *In the game.*
   - Secret art **Lamp-Threading Scripture (Xuyên Đăng Bí Điển)**, Heaven tier (Thiên giai). *Not in the game yet (staged:
     lamp-threading-scripture).* It holds every soul art, +22.5 % divine sense, and the passive Still Flame (+30 soul damage).
5. **Arts (thần thông)**, all from the Lamp-Threading Scripture, *not in the game yet*:
   Lamp-Threading Needle (staged: lamp-threading-needle), Mountain-Splitting Thought (mountain-splitting-thought),
   Heart-Lamp Lance (heart-lamp-lance), Ninth-Weight Lance (ninth-weight-lance), Lamp-Light (lamp-light),
   Lantern Out (lantern-out), Bell of Waking (bell-of-waking).
6. **Items:**
   - **Bronze Shrine Bell (Đồng Từ Chung)**, a named bell twice as heavy as any other. *Not in the game yet (staged:
     bronze-shrine-bell).*
   - Generated treasures: a seal (Ấn), a bell (Chuông), a banner (Kỳ), a shield (Thuẫn), armour (Giáp), and at Nascent
     Soul a gourd (Hồ Lô). *In the game.* Look for the **Soul-Piercing (Thấu Hồn)** affix, `x_soul` +5 to +15 (*not in
     the game yet, staged: soul-piercing-affix*). **Never take the Linh affix** (it makes a treasure lighter).
   - **Lamp-Clear Pill (Minh Đăng Đan)**, +25 soul damage for one prepared fight. *Not in the game yet (staged:
     lamp-clear-pill).*
   - Wards (all *in the game*): Common Ward, Golden Bell, Mountain Screen, Thousand-Layer Cloud, Soul-Guarding Lamp; later
     Clear Heart Ward or Surging Tide, and Golden Light Shield in an art slot.
7. **Enabler:** none. The soul channel is already in the rules; the build needed content, not a new rule. Its identity piece
   is the Effect Thousand-Weight Thought (*not in the game yet, staged: thousand-weight-thought*).
8. **On the skill tree (kinh mạch đồ):** capability #2 Divided Divine Sense (Thần Thức Phân Hóa): +20 % divine sense and a
   seventh treasure slot. *In the game.* Open Sky (*designed*). The **Lamp Wick (Đăng Tâm)** sealed cluster, opened by the
   Lamp-Threading Scripture (*not in the game yet, staged: lamp-wick-cluster*).

## The enabling Effects

- **Thousand-Weight Thought (Thiên Quân Niệm)**, *new*. Your soul damage is +1 for every 1 % of your divine sense bound to
  treasures, up to +60. *Why the build needs it:* it is the answer to "what do I wear?". Without it a soul build would wear
  light armour and nothing else; with it every heavy bell is part of the lance. At Core Formation it is 60 of your 85 soul
  damage.
- **Splinters of Thought (Niệm Tiết)**, *new*. When the 30 % cap cuts a soul hit short, what was cut delays the enemy's
  next art by 0.5 s per 10 % cut, up to 1.5 s. *Why:* against weaker enemies your surplus becomes control, so they fire
  almost nothing before the fourth lance lands.
- **Lamp-Oil Siphon (Hấp Đăng Du)**, *new*. When your soul hit takes the enemy's spiritual power, you get back a quarter
  of what it took. *Why:* the arts cost 5–10 % of your pool each and fire every second; this is the fuel.
- **Slackened Soul (Tùng Hồn)**, *in the game* (a curse). The Needle puts two stacks on the enemy: −30 points of soul
  resistance for 2 pulses, with no floor. On an enemy with no soul resistance it goes to −30, which makes your next hit
  about 70 % bigger. *Why:* the Needle fires just before the Lance, so the Lance always lands on a loosened soul.
- **Soul Wound (Thương Hồn)**, *in the game* (designed). Each soul hit delays the enemy's next art by 0.5 s.
- **Open Sky (Không Thiên)**, *in the game* (designed). The other end of the dial: ward strength for divine sense left
  free. You will have 27–35 % free, so it gives +13 to +18 ward strength.
- **First Move (Tiên Thủ)**, *in the game* (designed). Your first soul art is free.

## Modifiers to stack

Most important first. Soul hits ignore all five damage layers, so **take no damage, crit or attack nodes at all**.

1. **Divine sense (`than_thuc_pct`)** and **soul strength (`than_hon`)**. Fills: the base, squared. When to stop: never
   before Deity Transformation; every +10 % divine sense is about +21 % soul share. It also gives the extra ward slots
   (you need 3.5 × your realm's reference, which you pass easily) and treasure room.
2. **Soul damage (`x_soul`)**: tree nodes (+10, or +12 scoped to Water), the Still Flame passive, Soul-Piercing affixes.
   Fills: the soul's own multiplier (not a damage layer). When to stop: when your lances reach the cap against the enemies
   you meet. Around +150 at Nascent Soul does it against strong foes.
3. **Weight on your treasures** (feeds Thousand-Weight Thought). Fills: soul damage, through the Effect. When to stop: at
   60 % of your divine sense bound, where the Effect caps at +60. Keep checking as your divine sense grows: at Core
   Formation six treasures are enough, at Nascent Soul you need the seventh, at Deity Transformation heavier refining.
4. **Art speed (`art_speed_pct`)**: to +100, then **stop**. At +100 the Needle comes round every 1.000 s, which is the
   lockout. More art speed only makes the bigger arts come round more often, about +14 % per extra +100.
5. **Pierce (`pierce_pct`)**: a little, only for fights one realm up.
6. **Spiritual power regeneration (`linh_luc_regen_pct`)**: until the Siphon carries you. Core Formation is short of fuel.

## Upgrades to look for

Your shopping list, core pieces first. The last rows are what turns a build that works into a top-end one: reaching the
30 % cap against strong foes, and surviving the fights that last longer than four seconds. Sizes on staged pieces are
first guesses.

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Divine sense (thần thức) notables, `than_thuc_pct` (+6 each) | Modifier | The base of every lance, squared: +10 % is about +21 % soul share. Also ward slots and treasure room | Tree nodes (kinh mạch đồ); Hồn Đạo Thần Thức facet; capability #2 (+20 %) | In the game | Core |
| Soul strength (thần hồn), `than_hon` | Modifier | Feeds divine sense at its root: every point is squared | Talent pills; tree nodes; Hồn Đạo Thần Thức facet | In the game | Core |
| Thousand-Weight Thought (Thiên Quân Niệm) | Effect | The identity piece: +1 soul damage per 1 % of divine sense bound to treasures, up to +60. At Core Formation it is 60 of your 85 | Hồn Đạo (Nguyên Thần), Thần Thức facet, major node | Not in the game yet (staged: thousand-weight-thought; Đạo node staged: hon-than-thuc-weight) | Core |
| Soul attack damage (`x_soul`), Water-scoped notables (+12) | Modifier | The build's only multiplier; about +150 at Nascent Soul reaches the cap on strong foes | Tree nodes; Hồn Kích facet lines | In the game (designed key) | Core |
| Lamp-Threading Scripture (Xuyên Đăng Bí Điển) with Still Flame | Modifier (technique bonus and +30 soul damage passive) | Holds all seven soul arts, +22.5 % divine sense, +30 soul damage | Secret art (công pháp), Heaven tier | Not in the game yet (staged: lamp-threading-scripture) | Core |
| Lamp-Threading Needle (Xuyên Đăng Châm) | Effect (soul hit that applies Slackened Soul) | Loosens the enemy's soul so the next lance lands about 70 % bigger | Art from the Scripture | Not in the game yet (staged: lamp-threading-needle) | Core |
| Bronze Shrine Bell (Đồng Từ Chung) | Modifier lines on a named item (heavy weight, +15 soul damage, defence) | A third of the weight Thousand-Weight Thought needs, plus a wall | Named item, inherited at Core Formation | Not in the game yet (staged: bronze-shrine-bell) | Core |
| Art speed (`art_speed_pct`), to +100 | Modifier | Brings the Needle to a 1.000 s cycle, the lockout. Stop there | Tree nodes; Hồn Kích facet | In the game (designed key) | Strong |
| Soul-Piercing affix (Thấu Hồn), `x_soul` +5 to +15 | Modifier | Lets every generated treasure add soul damage on top of its weight. Never take the Linh affix | Item affix on seals, bells, banners, shields | Not in the game yet (staged: soul-piercing-affix) | Strong |
| Splinters of Thought (Niệm Tiết) | Effect | What the 30 % cap cuts off delays the enemy's next art, so weaker foes fire almost nothing | Hồn Đạo, Hồn Kích facet, major node | Not in the game yet (staged: splinters-of-thought; Đạo node staged: hon-kich-splinters) | Strong |
| Ninth-Weight Lance (Cửu Quân Thương) | Effect (largest soul hit) | Replaces the Heart-Lamp Lance at Deity Transformation: the biggest share, ending most fights in 4–5 s | Art from the Scripture, layer 15 | Not in the game yet (staged: ninth-weight-lance) | Strong |
| Slackened Soul (Tùng Hồn) and Soul Wound (Thương Hồn) | Effects | Loosened soul resistance and enemy arts pushed back 0.5 s a hit; carry you past soul-resistant and burst foes | Needle (Slackened Soul); Hồn Đạo or technique (Soul Wound) | In the game | Strong |
| Lamp-Oil Siphon (Hấp Đăng Du) | Effect | Returns a quarter of the spiritual power (linh lực) a soul hit takes: the fuel that Core Formation lacks | Hồn Đạo shared minor node | Not in the game yet (staged: lamp-oil-siphon) | Strong |
| Divided Divine Sense (Thần Thức Phân Hóa), capability #2 | Modifier (+20 % divine sense, a seventh treasure slot) | The seventh weight at Nascent Soul, keeping Thousand-Weight Thought at its cap | Tree capability | In the game | Strong |
| Lamp-Clear Pill (Minh Đăng Đan) | Modifier (+25 soul damage for one fight) | Extra push against bosses and soul-warded foes | Pill (đan dược) | Not in the game yet (staged: lamp-clear-pill) | Nice |
| Bell of Waking (Tỉnh Hồn Chung) | Effect (cleanse) | Washes off Slackened Soul or a Silence naming the soul tag: the answer to a rival lance keeper | Art from the Scripture, layer 12 | Not in the game yet (staged: bell-of-waking) | Nice |
| Soul-Guarding Lamp (Hộ Hồn Đăng) and Hồn Hộ soul resistance | Effect (ward) and modifier (`soul_res_pct`) | Survives long fights against soul cultivators; holds back 20 % of your spiritual power | Ward slot; Hồn Đạo Hồn Hộ facet | Lamp in the game; Hồn Hộ lines not in the game yet (staged: hon-ho-lines) | Nice |
| Open Sky (Không Thiên) | Effect | Ward strength for divine sense left free (+13 to +18); the other end of the dial from Thousand-Weight Thought | Skill tree (Meridian Map) or Way | In the game (designed) | Nice |
| Lamp Wick (Đăng Tâm) sealed cluster | Modifiers (divine sense, soul strength, soul damage) | A dense cluster of exactly the three stats the build wants | Tree cluster, opened by the Scripture | Not in the game yet (staged: lamp-wick-cluster) | Nice |
| Mother Lode (Mẫu Khoáng) | Effect | Heavier refining at Deity Transformation: weight stays bound as divine sense grows | Tree (Meridian Map) content | Not in the game yet (staged: mother-lode) | Nice |
| Realm pierce (`pierce_pct`) and regeneration (`linh_luc_regen_pct`) | Modifiers (+3 and +1 notables) | A little for fights one realm up; fuel until the Siphon carries you | Tree nodes | In the game | Nice |
| Unyielding Breath (Bất Khuất) | Effect (keystone) | Once per fight a killing blow leaves you at 1 health, against burst builds that kill before the fourth lance | Tree keystone | In the game (designed) | Nice |


- **Core Formation (Kết Đan).** You get the Heart-Lamp Lance and the Bronze Shrine Bell. Six treasures, four free ward
  slots, five art slots. Ordinary foes die at 4.5 s; strong ones at about 9 s, and you run short of spiritual power around
  9 s, so the heal art and the Siphon matter. A strong foe with a Soul-Guarding Lamp is an even fight (about 15 s).
- **Nascent Soul (Nguyên Anh).** Capability #2 adds a seventh treasure and more divine sense; the Still Flame passive and
  Bell of Waking arrive. Your lance now caps strong foes: 4.0 s. An ordinary cultivator one realm up dies at 6.0 s.
- **Deity Transformation (Hóa Thần).** The Ninth-Weight Lance replaces the Heart-Lamp Lance. Six free ward slots, seven
  arts. Almost every fight in your realm ends in 4–5 s. Bosses take about 14 s.

## How it plays

**Art order (slot order matters):** Heart-Lamp Lance, Mountain-Splitting Thought, Lamp-Threading Needle, Lamp-Light (heal,
fires at 85 % health or below), Lantern Out (escape, at 30 % or below), then Bell of Waking (Nascent Soul) and Golden Light
Shield (Deity Transformation). When two soul arts are ready in the same instant the earlier slot fires, so this order
makes the cycle Lance, Thought, Needle, and the Needle's curse always covers the Lance.

**Wards:** Common Ward, Golden Bell, Mountain Screen, Thousand-Layer Cloud; add the Soul-Guarding Lamp when you know you
face a soul cultivator (it holds back 20 % of your spiritual power, so leave it off otherwise).

**No preparation needed.** Formations and preparation feed a damage layer the soul hit never reads, so a sudden ambush
costs you nothing. Take the Lamp-Clear Pill only against bosses and soul-warded foes.

**The signature moment:** a strong Nascent Soul cultivator with a full ward and every defence it bought stands there while
four threads of thought go through it, one a second, and falls at exactly 4.000 s with its spiritual power empty, its
own arts pushed back by each hit until it has fired at most one.

## What beats it

- **The soul-resistant enemy** (every realm has one): a Soul-Guarding Lamp, soul resistance from its Way and high divine
  sense of its own. Four lances become fifteen at Core Formation. *Adapt:* the Needle's Slackened Soul, the Lamp-Clear
  Pill, and grow into Nascent Soul, where it falls at 6 s.
- **Bosses.** Every soul share is divided by the boss's pool multiplier: a ×4 boss loses at most 7.5 % a hit. *Adapt:*
  your walls and heal must hold 14 s; slot all wards and take the pill.
- **Another soul cultivator.** Its divine sense is the bottom of your fraction and yours is the bottom of its. A mirror is
  even and slow (about 26 s). *Adapt:* the Soul-Guarding Lamp, Hồn Hộ soul resistance, and Bell of Waking to wash off its
  Slackened Soul.
- **A curse that silences soul arts** (Silence naming the soul tag) stops every soul art for 3 pulses. *Adapt:* Bell of
  Waking from Nascent Soul.
- **A realm gap.** Divine sense triples per realm. One realm up you still win against ordinary foes; against a strong one
  you lose, and two realms up you do nothing.
- **A burst build that kills before the fourth lance.** *Adapt:* Soul Wound pushes its first art back; Golden Light Shield
  and the Unyielding Breath keystone at Deity Transformation.

## Not in the game yet

Every staged piece this build needs (`design/builds/overnight-2026-11-10/staging-catalogue.md`):

- Effects: `thousand-weight-thought`, `splinters-of-thought`, `lamp-oil-siphon`; `mother-lode` (copied from the by-root
  missing pieces, used here as a gain).
- Modifier: `soul-piercing-affix`.
- Items: `bronze-shrine-bell`, `lamp-clear-pill`.
- Technique: `lamp-threading-scripture` (with the Still Flame passive).
- Arts: `lamp-threading-needle`, `mountain-splitting-thought`, `heart-lamp-lance`, `ninth-weight-lance`, `lamp-light`,
  `lantern-out`, `bell-of-waking`.
- Đạo pieces: `hon-than-thuc-weight`, `hon-kich-splinters`, `hon-ho-lines`.
- Concepts: `soul-art-lint`, `soul-reference-table`, `lamp-wick-cluster`.

## Changes the game would need

- **A lint for soul arts** (Combat GDD, `design/gdd/combat.md` Formulas C or E2, rule 24). Today a soul art's share is a
  free number between 0.03 and 0.08, unrelated to its cost or cooldown. The build's arts are sized to a proposed lint
  (share ≤ 0.0125 × the ordinary art lint).
- **A reference table of divine sense and soul resistance by realm** (Combat Defence & Healing GDD,
  `design/gdd/combat-defence.md` rule 14, Open Question 12). Every soul result depends on it; this guide's enemy numbers are
  guesses until it exists.
- **A readable for the spiritual power a soul hit takes** (Effects System GDD, `design/gdd/effects.md` rule 5), so
  Lamp-Oil Siphon can be written.

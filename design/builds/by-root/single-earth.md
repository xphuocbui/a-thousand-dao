# Single root: Earth (Thổ)

**What Earth brings.** Physical damage. Buff: Physical damage taken dampened per stack. Debuff: −1 pp accuracy on the
foe, so the foe misses more against anyone with evade. Craft role: spirit field plots; formation upkeep is lower.
Công pháp: Deep Earth Earth Scripture (Hậu Thổ Địa Quyết), Deep Earth Heaven Canon (Hậu Thổ Thiên Kinh), and the
body art Dragon-Elephant (Long Tượng Công). Formation: Mountain Guard Array (Hộ Sơn Trận).

**Earth's linh lực keystone (New, every Earth build):** **The Stone Remembers (Thạch Ký)**: 0.9 % of the damage
your block and resistance prevent returns as linh lực (starting number, `notes.md` § 9). How to create: Meridian Map keystone in the Earth land; an
Effect on the "damage prevented" read (new readable: prevented points per hit), action "restore linh lực";
closing cost "your evade is 0".

---

## 1. The Mountain That Pays (Sơn Trái)

**Concept.** The more they hit the mountain, the more the mountain has to spend. A fortress whose ward is fed by
the blows it stops.

**How it fights.** Earth buff stacks dampen Physical damage taken; the keystone turns prevented damage into linh lực,
so the ward pays itself against Physical attackers. It wins by attrition at 40–55 s.

**Stacks.**
- **Linh căn:** single Earth.
- **Công pháp:** Deep Earth Heaven Canon.
- **Đạo:** Gravity (Trọng Lực Đạo), the immovable branch.
- **Keystone:** The Stone Remembers (New).
- **Effects:** Field Walls (exists: formation power counts as ward strength); Shattering Ward (exists: a broken
  shield bursts on the foe).
- **Modifiers:** resistance [physical]; block; ward strength; `stack_effect_pct` [tho, buff].
- **Items:** Mountain Guard Array (prepared); Shield (Thuẫn); Mountain Screen.
- **Element stacks:** Earth buff.

**Weakness.** Fire, Cold and Chaos foes: Earth's buff guards only Physical, and the keystone feeds only on what is
prevented.

**New pieces.**
- **Prevented damage (readable)**: the points a hit lost to resistance and block, as an event. How to create: add
  to the Effects System's readable list (rule 5).

## 2. The Dust Veil (Trần Mạc)

**Concept.** Earth as blindness: debuff stacks cut the foe's accuracy while this cultivator takes evade, so hits
simply stop landing.

**How it fights.** Sand arts apply Earth debuff (−accuracy); with 25 % evade and 20 stacks on the foe, the foe
misses almost half its hits. Missed hits drain nothing, so the ward lasts.

**Stacks.**
- **Linh căn:** single Earth.
- **Công pháp:** Deep Earth Earth Scripture.
- **Đạo:** Illusion (Huyễn Đạo) for evade, or a New Dust Đạo.
- **Keystone:** The Stone Remembers is wrong here (it closes evade); take Iron Shirt's evade and Beneath Notice
  instead.
- **Effects:** Beneath Notice (exists); Iron Shirt ward (exists: block + evade).
- **Modifiers:** evade; `stack_duration_pct` [tho, debuff]; art speed.
- **Items:** Iron Shirt (reserved ward with evade); Fan to raise dust.
- **Element stacks:** Earth debuff.

**Weakness.** Soul attacks and ticks never meet evade; Thunder buff stacks (+accuracy) undo the debuff.

**New pieces.**
- **Dust Đạo (Trần Đạo)**: theme stats evade, accuracy-down duration; keystone "missed hits against you grant a
  Earth debuff stack". How to create: a new `dao.json` entry, requirement Earth purity 40.

## 3. The Field Lord (Điền Chủ)

**Concept.** A farmer-cultivator whose spirit fields pay for everything: herbs and stones off the land, a formation
on home ground, and one patient fight a year.

**How it fights.** On prepared ground the Mountain Guard Array stands; the fight is a slow grind behind a
reserved aura, with Earth buff stacks rising.

**Stacks.**
- **Linh căn:** single Earth (field plots role).
- **Công pháp:** Deep Earth Earth Scripture.
- **Đạo:** Spirit Farming (Linh Điền Đạo).
- **Keystone:** Portable Cave Abode (capability, exists: formations work anywhere) to take the home ground along.
- **Effects:** Field Walls (exists).
- **Modifiers:** formation power; `formation_upkeep_pct`; field plots.
- **Items:** Mountain Guard Array; Still Lake Aura.
- **Element stacks:** Earth buff.

**Weakness.** Blind fights away from home; Silence on the formation tag.

**New pieces.** None beyond the keystone.

## 4. The Mountain Seal (Sơn Ấn)

**Concept.** A seal as heavy as a mountain, pressed on the foe's meridians. Control by curses: Silence on the foe's
element, Sealed Meridian on its strongest layer, and an Earth body to wait out the answer.

**How it fights.** A seal art lays Silence (the foe's main element tag) and Sealed Meridian in turn; Earth buff
stacks keep it standing; the foe fights with half its kit.

**Stacks.**
- **Linh căn:** single Earth.
- **Công pháp:** Deep Earth Heaven Canon.
- **Đạo:** Gravity, the sealing branch (New nodes: curse duration).
- **Keystone:** The Stone Remembers (New).
- **Effects:** Silence and Sealed Meridian (exist, curses).
- **Modifiers:** status chance; art cost [curse]; curse duration.
- **Items:** Seal (Ấn).
- **Element stacks:** Earth buff.

**Weakness.** Cleansing; builds with many element tags (Silence blocks one).

**New pieces.** None.

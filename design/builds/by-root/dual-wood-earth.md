# Dual root: Wood and Earth (Mộc, Thổ)

**What the pair brings.** An overcoming pair (Wood breaks Earth): no speed bonus, but a strong story of roots
cracking stone. Wood's health regeneration and Poison; Earth's Physical resistance and accuracy debuff. Crafts: the
farmer's root, herbs and fields together. Linh lực keystones: Root Drinks the Rot (Wood, New), The Stone Remembers
(Earth, New).

---

## 1. Root Through Rock (Căn Xuyên Thạch)

**Concept.** Roots find the cracks. Poison passes shields, and this build adds a Wood effect that turns the foe's
own Physical resistance against it.

**How it fights.** Poison piles up; a New Effect makes Poison deal more against targets with high resistance (the
roots grow into the stone). Against thể tu and warded walls, this is the answer.

**Stacks.**
- **Linh căn:** Wood and Earth.
- **Công pháp:** Green Wood Heaven Canon.
- **Đạo:** Poison, the creeping branch.
- **Keystone:** Root Drinks the Rot (New).
- **Effects:** Spillover (exists).
- **Modifiers:** damage [poison]; `stack_duration_pct` [moc, debuff]; `resist_pen_pct` [chaos].
- **Items:** Needle (Châm) of thorn; Clear Heart Ward.
- **Element stacks:** Wood debuff.

**Weakness.** Ordinary against unarmoured foes; cleansing.

**New pieces.**
- **Cracking Root (Liệt Căn)**, an Effect: "your Poison deals +1 % more for every 2 pp of the target's Physical
  resistance". How to create: Effect reading the target's resistance (add "enemy resistance by type" to the
  readable list), payload L5 more scoped [poison].

## 2. The Hundred Herbs Estate (Bách Thảo Trang)

**Concept.** The richest farm in the province: herbs (Wood) on spirit fields (Earth), and a cultivator who fights
rarely and always prepared.

**How it fights.** On home ground behind the Green Wood Array, with herb pills inside; a slow grind with regeneration
and resistance.

**Stacks.**
- **Linh căn:** Wood and Earth.
- **Công pháp:** Green Wood Earth Scripture.
- **Đạo:** Spirit Farming (Linh Điền Đạo).
- **Keystone:** Hundred Herbs Kept Alive (capability, exists); Portable Cave Abode (capability, exists).
- **Effects:** Field Walls (exists).
- **Modifiers:** herb growth; field plots; formation power.
- **Items:** Green Wood Array; Mountain Guard Array.
- **Element stacks:** Wood buff, Earth buff.

**Weakness.** Ambushes away from home.

**New pieces.** None.

## 3. The Ancient Banyan (Cổ Dung)

**Concept.** A tree that has stood a thousand years: health regeneration (Wood) and resistance (Earth) together,
paying arts in health and never letting its ward fall.

**How it fights.** Blood Casting arts, Wood buff stacks to regrow, Earth buff stacks to resist. A wall that hits
back slowly and outlasts most foes into fatigue.

**Stacks.**
- **Linh căn:** Wood and Earth.
- **Công pháp:** Dragon-Elephant (Long Tượng Công).
- **Đạo:** Life (Sinh Đạo).
- **Keystone:** Blood Casting (exists); The Stone Remembers (New).
- **Effects:** Iron Skin Renewed (exists).
- **Modifiers:** health regeneration; resistance [physical]; `art_cost_health_pct`.
- **Items:** Armour body gear; Mountain Screen.
- **Element stacks:** Wood buff, Earth buff.

**Weakness.** Stagnation and Withering; Fire (burns the body shield).

**New pieces.** None.

## 4. The Stone Forest Maze (Thạch Lâm Mê Trận)

**Concept.** A formation of standing stones and twisted trees. Inside it the foe wanders: its hits miss, its arts
come late, and the maze's owner walks the only straight path.

**How it fights.** Prepared ground. The maze formation grants the owner evade and lays Earth debuff (−accuracy) on
the foe each pulse; Wood roots delay the foe's arts (Gripping Root).

**Stacks.**
- **Linh căn:** Wood and Earth.
- **Công pháp:** Deep Earth Earth Scripture.
- **Đạo:** Array (Trận Đạo), then Illusion (Huyễn Đạo).
- **Keystone:** Formation Within a Formation (capability, exists).
- **Effects:** Field Walls (exists), Gripping Root (New, `single-wood.md`).
- **Modifiers:** formation power; evade; `stack_duration_pct` [tho, debuff].
- **Items:** Stone Forest Array (New).
- **Element stacks:** Earth debuff (from the formation).

**Weakness.** Blind fights; a foe with high accuracy or soul attacks.

**New pieces.**
- **Stone Forest Array (Thạch Lâm Trận)**, a formation: "the owner gains evade; each pulse every foe on the ground
  gains 1 Earth debuff stack for 5 s". How to create: `crafting_formations.json` entry with a stack-grant field
  (see "Element arrays granting stacks").

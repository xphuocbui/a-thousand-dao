# Variant combinations

Wind is innate, so it can sit on any root. Some roots can also hold two derived variants at once: Fire, Earth and
Water can hold Light (from Fire) and Darkness (from Earth and Water); Water, Fire and Metal can hold Ice (from
Water) and Thunder (from Fire and Metal). These builds use those pairings.

---

## 1. The Wildfire Gale (Phong Hỏa Liệu Nguyên): Wind with Fire

**Concept.** Wind spreads fire. Wind buff stacks speed every Fire art, so Burn batches stack faster than any
cleanse can thin them.

**How it fights.** Quick Fire arts; each firing adds Wind buff (+1 % art speed) and lays Burn. At 20 s the arts fire
at the floor and Overheat turns the rest into damage.

**Stacks.**
- **Linh căn:** Fire with Wind.
- **Công pháp:** Crimson Flame Heaven Canon; Wind Walk Art.
- **Đạo:** Pill Fire, or Space for speed.
- **Keystone:** Breath Between Blows (Wind, New) and Embers Feed the Hearth (Fire, New).
- **Effects:** Overheat (exists), Kindled Wound (exists).
- **Modifiers:** art speed; damage [fire]; `stack_duration_pct` [hoa, debuff].
- **Items:** Fan (Phiến), the natural Wind-and-Fire artifact.
- **Element stacks:** Wind buff, Fire buff and debuff.

**Weakness.** Fire resistance; Ice stacks (many arts, each dearer).

**New pieces.** None beyond the keystones.

## 2. The Pollen Storm (Hoa Phấn Bão): Wind with Wood

**Concept.** Wind carries spores. Poison laid by many quick hits, spread so fast that a cleansing ward cannot keep
up.

**How it fights.** Wind debuff (−evade) so every spore lands; Wood Poison from quick arts; Wind buff speeds them.

**Stacks.**
- **Linh căn:** Wood with Wind.
- **Công pháp:** Green Wood Heaven Canon; Wind Walk Art.
- **Đạo:** Poison.
- **Keystone:** Root Drinks the Rot (Wood, New).
- **Effects:** Spillover (exists), Marked Prey (exists).
- **Modifiers:** art speed; damage [poison].
- **Items:** Fan; Gourd.
- **Element stacks:** Wind buff and debuff, Wood debuff.

**Weakness.** Chaos resistance; block (many small hits).

**New pieces.** None.

## 3. The Typhoon (Đài Phong): Wind with Water

**Concept.** A storm at sea: Water's bottomless pool lets Wind's frenzy run all fight.

**How it fights.** Water stacks deepen the pool while Wind stacks speed the arts; the faster it casts the deeper the
pool must be, and Water keeps pace.

**Stacks.**
- **Linh căn:** Water with Wind.
- **Công pháp:** Dark Water Heaven Canon.
- **Đạo:** Mist.
- **Keystone:** The Spring Never Fails (Water, New); Breath Between Blows (Wind, New).
- **Effects:** Steady Breath (exists), Flowing Water (exists).
- **Modifiers:** art speed; linh lực regeneration.
- **Items:** Bell; Gourd.
- **Element stacks:** Water buff, Wind buff.

**Weakness.** Burst before the storm builds.

**New pieces.** None.

## 4. The Sandstorm (Sa Bạo): Wind with Earth

**Concept.** Wind lifts sand: Earth debuff (−accuracy) and Wind debuff (−evade on the foe) together, so the foe
cannot hit and cannot dodge.

**How it fights.** Sand arts lay both debuffs; the cultivator takes evade; hits land and the foe's miss.

**Stacks.**
- **Linh căn:** Earth with Wind.
- **Công pháp:** Deep Earth Earth Scripture; Wind Walk Art.
- **Đạo:** Dust (New, `single-earth.md`).
- **Keystone:** Breath Between Blows (Wind, New).
- **Effects:** Beneath Notice (exists).
- **Modifiers:** evade; `stack_duration_pct` [tho, debuff] and [phong, debuff].
- **Items:** Iron Shirt; Fan.
- **Element stacks:** Earth debuff, Wind debuff.

**Weakness.** Soul attacks; ticks.

**New pieces.** None beyond those named.

## 5. The Thousand Blades Whirlwind (Thiên Nhận Toàn Phong): Wind with Metal

**Concept.** A tornado of flying swords: Wind speeds the swords, Metal debuff sharpens every cut.

**How it fights.** The Thousand Cuts (`single-metal.md`) at Wind's speed; Overheat past the floor.

**Stacks.**
- **Linh căn:** Metal with Wind.
- **Công pháp:** Canh Kim Heaven Canon.
- **Đạo:** Sword.
- **Keystone:** Breath Between Blows (Wind, New); Edge Returns the Breath (Metal, New).
- **Effects:** Overheat (exists), Opening Cut (exists).
- **Modifiers:** art speed [sword]; damage [sword].
- **Items:** Flying Swords.
- **Element stacks:** Wind buff, Metal debuff.

**Weakness.** Block.

**New pieces.** None.

## 6. The Eclipse (Nhật Thực): Light with Darkness

**Concept.** Sun and shadow in one root (Fire, Earth and Water with both variants). Light lays the foe bare
(Exposed), Darkness strikes the bared body with Chaos that passes its shields.

**How it fights.** A Light art keeps Exposed up (all resistance −0.10); Chaos arts hit through the opened ward and
past body shields. Against a thể tu or a warded wall it is the sharpest answer in the game.

**Stacks.**
- **Linh căn:** Fire, Earth, Water with Light and Darkness.
- **Công pháp:** Radiant Canon (New) and Shadow Secret Art.
- **Đạo:** Taiji (Thái Cực), the eclipse branch; Yin and Yang.
- **Keystone:** Dawn Tithe (Light, New).
- **Effects:** Marked Prey (exists).
- **Modifiers:** damage [chaos], [light]; status chance.
- **Items:** Mirror (New kind); Needle.
- **Element stacks:** none (both variants have none); Fire debuff if it burns.

**Weakness.** Cleansing Exposed; the rarity of the root.

**New pieces.**
- **Mirror (Kính)**, an artifact kind: utility, raises status chance for Light statuses. How to create: add a kind
  to `items_artifacts.json`.

## 7. The Frozen Lightning (Băng Lôi): Ice with Thunder

**Concept.** Water, Fire and Metal holding Ice and Thunder: Ice stacks drain the foe's pool, Thunder crits
recharge your own. Each crit takes from them and gives to you.

**How it fights.** Cold hits lay Ice debuff (+art cost on the foe); Lightning crits lay crit exposure and restore
linh lực (Storm Battery); Frost Tithe takes a share of what the foe overpays.

**Stacks.**
- **Linh căn:** Water, Fire, Metal with Ice and Thunder.
- **Công pháp:** Thunder Emperor True Canon; Dark Water Heaven Canon.
- **Đạo:** Heavenly Thunder, then Mist.
- **Keystone:** Storm Battery (Thunder, New), Frost Tithe (Ice, New).
- **Effects:** Rime Lock (exists), Called Blow (exists).
- **Modifiers:** crit chance; `stack_duration_pct` [bang, debuff].
- **Items:** Needle; Bell.
- **Element stacks:** Ice debuff, Thunder buff and debuff.

**Weakness.** Cleansing; the crit cap.

**New pieces.** None beyond the keystones.

## 8. The Storm Sage (Phong Lôi Thánh): Wind, Thunder and Chaos

**Concept.** The rarest root a life can carry: five elements, Chaos, Thunder and Wind. Every element stack, every
keystone, every Đạo glimpse. A legend, not a plan.

**How it fights.** The Hundred Arts Sage (`variant-chaos.md`) with Wind's speed and Thunder's crits on top.

**Stacks.**
- **Linh căn:** five elements, Chaos, Thunder, Wind.
- **Công pháp:** Five Phases Canon (New).
- **Đạo:** four glimpses: Taiji, Heavenly Thunder, Space, Time.
- **Keystone:** Primordial Breath, Storm Battery, Breath Between Blows (all New).
- **Effects:** Generating Cycle (New).
- **Modifiers:** universal stack effect and duration (New).
- **Items:** Five-Phase Flag (New).
- **Element stacks:** all.

**Weakness.** A root this rare comes perhaps once in a world's history; its early life is the slowest.

**New pieces.** None beyond those named.

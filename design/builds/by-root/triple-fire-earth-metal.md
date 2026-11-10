# Triple root: Fire, Earth and Metal (Hỏa, Thổ, Kim)

**What the root brings.** Two generating pairs (Fire → Earth → Metal, +6 %), and Fire with Metal can converge into
Thunder. Burn, Physical resistance, Physical damage and Physical-taken. The smelter's root: ore from the earth,
melted by fire, into metal. Đạo parents: Lava, Refined Metal.

---

## 1. The Smelter (Dã Luyện)

**Concept.** Ore goes in, steel comes out. Earth arts pile Earth buff (the ore), Fire arts melt it into Metal buff
(the steel), and the finished blade strikes with everything.

**How it fights.** A New Effect converts own buff stacks: every 4 s, 5 Earth buff stacks become 5 Metal buff stacks
if a Fire art fired. The build ends a fight with a heavy Metal-buffed sword art.

**Stacks.**
- **Linh căn:** Fire, Earth, Metal.
- **Công pháp:** Canh Kim Heaven Canon.
- **Đạo:** Refined Metal, the smelting branch.
- **Keystone:** Mother Lode (map placeholder) for the forge theme.
- **Effects:** Smelt (New, below).
- **Modifiers:** damage [physical]; `stack_grant` [tho, buff]; `stack_effect_pct` [kim, buff].
- **Items:** self-forged Flying Sword; Armour.
- **Element stacks:** Earth buff → Metal buff, Fire buff.

**Weakness.** The conversion takes time; early pressure.

**New pieces.**
- **Smelt (Luyện)**, an Effect: "when you fire a Fire art, up to 5 of your Earth buff stacks become Metal buff
  stacks, keeping their timers". How to create: a new action "convert own stacks" in the Effects action list.

## 2. The Iron Volcano (Thiết Hỏa Sơn)

**Concept.** Molten iron: Lava seals that land Physical and Fire together, Metal debuff for the steel, Burn for the
heat, Earth buff to stand the recoil.

**How it fights.** Like the Volcano (`dual-fire-earth.md`) with a Metal debuff layer that raises the Physical part.

**Stacks.**
- **Linh căn:** Fire, Earth, Metal.
- **Công pháp:** Molten Core Canon (New, `dual-fire-earth.md`).
- **Đạo:** Lava.
- **Keystone:** Edge Returns the Breath (Metal, New).
- **Effects:** Measured Stroke (exists).
- **Modifiers:** `convert_pct` Physical → Fire; damage [slow].
- **Items:** Seal.
- **Element stacks:** Metal debuff, Fire debuff, Earth buff.

**Weakness.** Fast kits.

**New pieces.** None beyond those named.

## 3. The Artisan General (Tượng Tướng)

**Concept.** A commander who equips an army: mission income (Metal), fields (Earth), alchemy (Fire). Fights at the
head of a beast or companion with the best gear in the region.

**How it fights.** A companion build: Beast Soul Union and a strong companion share, with ordinary arts.

**Stacks.**
- **Linh căn:** Fire, Earth, Metal.
- **Công pháp:** Canh Kim Earth Scripture.
- **Đạo:** Array.
- **Keystone:** Ten Thousand Beasts, One Heart (capability, exists).
- **Effects:** Beast Soul Union (exists), Pack Hunt (exists).
- **Modifiers:** companion power share; artifact power.
- **Items:** a beast; Flag.
- **Element stacks:** Metal debuff (from companion hits if a beast carries an element tag, New rule).

**Weakness.** Kill the companion first.

**New pieces.**
- **Element-tagged companions**: a companion's hits carry its own element tag and grant that element's stacks. How
  to create: a field on creature records (`creatures_linh_thu.json`), read by Effects rule 9a.

## 4. The Siege Engineer (Công Thành Sư)

**Concept.** A counter-build for walls. Auras, reserved wards and prepared formations are its prey: Metal pierces
resistance, Fire burns shields, and a breaching art shuts a ward down for a few seconds.

**How it fights.** Resistance penetration on every hit; a Breach art drops the foe's strongest ward for 3 s (a
curse); Burn wears body shields.

**Stacks.**
- **Linh căn:** Fire, Earth, Metal.
- **Công pháp:** Canh Kim Earth Scripture.
- **Đạo:** Destruction (Hủy Diệt).
- **Keystone:** Edge Returns the Breath (Metal, New).
- **Effects:** Breach (New).
- **Modifiers:** `resist_pen_pct`; damage [physical], [fire].
- **Items:** Seal; Needle.
- **Element stacks:** Metal debuff, Fire debuff.

**Weakness.** Ordinary against unwarded foes; body cultivators with block.

**New pieces.**
- **Breach (Phá Trận)**, a curse: "the target's strongest standing ward is Down for 3 pulses". How to create: a curse
  row in the Effects status catalogue (a ward lock, like Sealed Meridian's layer lock), with a reapply lockout.

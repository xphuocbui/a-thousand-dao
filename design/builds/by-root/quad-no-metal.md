# Quad root without Metal: Wood, Fire, Earth, Water (Mộc, Hỏa, Thổ, Thủy)

**What the root brings.** Three generating pairs (Water → Wood → Fire → Earth, +9 %); a slow start and a very fast
late game. Every debuff but Metal's (Poison, Burn, accuracy) and the mana, regeneration, damage and resistance
buffs. Earth with Water can converge into Darkness. A wide root: its strength is having many tools, not one sharp
one.

---

## 1. The Four Seasons Wheel (Tứ Quý Luân)

**Concept.** Spring (Wood), summer (Fire), late summer (Earth), winter (Water): four arts on one wheel, each season's
stacks strengthening the next through the Generating Cycle.

**How it fights.** Four arts on 8 s cooldowns offset by 2 s. Generating Cycle (New) rewards every turn. By the
third turn every art carries +20–30 %.

**Stacks.**
- **Linh căn:** Wood, Fire, Earth, Water.
- **Công pháp:** a four-element technique (New, the Four Seasons Canon).
- **Đạo:** Reincarnation (Luân Hồi), or Time (Thời Gian) for the seasons theme.
- **Keystone:** The Spring Never Fails (Water, New).
- **Effects:** Generating Cycle (New, `triple-wood-fire-earth.md`).
- **Modifiers:** damage scoped by each element; `stack_duration_pct` across elements (a universal stack duration
  modifier would help: New).
- **Items:** Flag of the four seasons.
- **Element stacks:** Water buff, Wood buff and debuff, Fire buff and debuff, Earth buff.

**Weakness.** Silence on any one element breaks the wheel; early burst.

**New pieces.**
- **Four Seasons Canon (Tứ Quý Kinh)**, a công pháp naming four elements, with one art per element. How to create:
  `items_cong_phap.json`; its speed averages four purities, so it is slow for a weak element.
- **Universal stack duration**: `stack_duration_pct` without an element scope (broad). How to create: a scope row
  in the General Catalogue (price × 1.25 breadth).

## 2. The Living Landscape (Sơn Thủy Họa)

**Concept.** A painter-cultivator who paints mountains, rivers, trees and suns, and each painted thing fights. A
formation build on prepared ground with four element formations at once.

**How it fights.** Prepared ground; the formations grant stacks of their element to their owner each pulse.

**Stacks.**
- **Linh căn:** Wood, Fire, Earth, Water.
- **Công pháp:** Deep Earth Earth Scripture.
- **Đạo:** Array, then Illusion.
- **Keystone:** Formation Within a Formation (capability, exists).
- **Effects:** Field Walls (exists).
- **Modifiers:** formation power; `formation_upkeep_pct`.
- **Items:** four element arrays (New: Fire and Water arrays).
- **Element stacks:** all four buffs, from the formations.

**Weakness.** Blind fights.

**New pieces.**
- **Element arrays granting stacks**: a formation field "grants 1 buff stack of its element to its owner each
  pulse". How to create: `crafting_formations.json` field; Effects rule 9a source kind "formation".

## 3. The Patient Sage (Nhẫn Hiền)

**Concept.** The late bloomer. A four-element root is slow until Nascent Soul; this build is a sustain shell that
survives the early realms, then turns into the Four Seasons Wheel.

**How it fights.** Early: heal arts and Water stacks, a reserved aura. Late: the wheel.

**Stacks.**
- **Linh căn:** Wood, Fire, Earth, Water.
- **Công pháp:** Green Wood Earth Scripture early.
- **Đạo:** Life first, Reincarnation later (four Đạo glimpses in a life).
- **Keystone:** The Spring Never Fails (New).
- **Effects:** Still Water (exists).
- **Modifiers:** healing; maximum linh lực.
- **Items:** Still Lake Aura.
- **Element stacks:** Water and Wood buffs.

**Weakness.** Low damage early.

**New pieces.** None.

## 4. The Sect Guardian (Hộ Tông)

**Concept.** The protector of a sect's mountain gate: four elemental arrays on home ground, and a cultivator who has
fought every invader there for a century.

**How it fights.** Mass battle and home defence: the Mountain Guard Array and three more element arrays raise ward
strength (Field Walls) for the guardian and its disciples. In a duel away from home it is ordinary.

**Stacks.**
- **Linh căn:** Wood, Fire, Earth, Water.
- **Công pháp:** Deep Earth Earth Scripture.
- **Đạo:** Array.
- **Keystone:** Formation Within a Formation (capability, exists).
- **Effects:** Field Walls (exists).
- **Modifiers:** formation power; `formation_upkeep_pct`.
- **Items:** four arrays (Element arrays granting stacks, New).
- **Element stacks:** all four buffs from the arrays.

**Weakness.** Any fight away from the gate.

**New pieces.**
- **Disciple aura**: an array that shares its owner's ward strength with allies in a mass battle. How to create: a
  formation field read by Combat Formulas K's force rating (mass battle).

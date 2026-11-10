# Five-element root (Ngũ Hành)

**What the root brings.** All five generating pairs (+15 %), the slowest start and the fastest end; Primordial
Chaos (Hỗn Độn) can converge from it. Every buff and every debuff but Ice's. The map's centre keystone, the **Five
Elements Cycle (Ngũ Hành Luân Chuyển)**, needs this root (Meridian Map, intended). The fantasy is mastery of the
cycle itself: generating and overcoming.

---

## 1. The Wheel of Generation (Sinh Luân)

**Concept.** Wood feeds Fire feeds Earth feeds Metal feeds Water feeds Wood. Five arts, each strengthened by the
stacks the one before it left, around and around; by the third lap nothing in the realm hits harder.

**How it fights.** Five arts on 10 s cooldowns, 2 s apart. Generating Cycle (New) and the Five Elements Cycle
keystone. The first 15 s are weak; from 30 s every art carries all the stacks behind it.

**Stacks.**
- **Linh căn:** all five, purities close together.
- **Công pháp:** a five-element technique (New: Five Phases Canon).
- **Đạo:** Taiji (Thái Cực), then Reincarnation.
- **Keystone:** Five Elements Cycle (map centre; content New: "your arts gain +2 % for each element whose buff
  stacks you hold").
- **Effects:** Generating Cycle (New).
- **Modifiers:** universal stack duration (New); damage scoped by element.
- **Items:** a Five-Phase Flag (New artifact, one slot per element).
- **Element stacks:** all five buffs, four debuffs.

**Weakness.** Early burst; Silence on any one element; a share cleanse.

**New pieces.**
- **Five Phases Canon (Ngũ Hành Kinh)**, a công pháp with one art per element.
- **Five Elements Cycle content**: "your arts gain +2 % for each element whose buff stacks you hold". How to create:
  Meridian Map content pass for the centre keystone.
- **Five-Phase Flag (Ngũ Hành Kỳ)**, an artifact kind: a flag with five element slots; each filled slot adds +5 %
  damage to arts of that element. How to create: add a kind to `items_artifacts.json` (utility role); refined
  with one material of each element.

## 2. The Overcomer (Khắc Chế Giả)

**Concept.** Read the foe's element, answer with the one that overcomes it: Water against Fire, Fire against Metal,
Metal against Wood, Wood against Earth, Earth against Water. A counter-build that adapts each fight.

**How it fights.** At compile, a New Effect reads the foe's main element and grants +20 % damage to arts of the
overcoming element; the build slots arts of all five and fires the right one most.

**Stacks.**
- **Linh căn:** all five.
- **Công pháp:** Five Phases Canon (New).
- **Đạo:** Taiji, the overcoming branch.
- **Keystone:** Five Elements Cycle.
- **Effects:** Overcoming Answer (New).
- **Modifiers:** damage scoped by element.
- **Items:** Five-Phase Flag (New).
- **Element stacks:** whichever overcoming element it uses.

**Weakness.** Variant-root foes (Thunder, Darkness, Light) have no overcoming element.

**New pieces.**
- **Overcoming Answer (Khắc Ứng)**, an Effect: "your arts of the element that overcomes the foe's main element deal
  +20 %". How to create: Effect reading the enemy's main root element (add to the readable list) and the fixed
  overcoming table.
- **Element weakness (optional rule)**: the user ruled no element cycle in damage (Combat Damage Types rule 2), so
  this lives only in Effects, never in resistance.

## 3. The Primordial Sage (Hỗn Nguyên Thánh), toward Chaos

**Concept.** A five-element root that has become Primordial Chaos: cultivation speed and breakthrough chance, and a
fight build that draws on every element's stack at once.

**How it fights.** See `variant-chaos.md`.

**Stacks.**
- **Linh căn:** all five plus Chaos.
- **Công pháp:** Five Phases Canon (New).
- **Đạo:** Taiji.
- **Keystone:** Five Elements Cycle.
- **Effects:** Generating Cycle (New).
- **Modifiers:** universal stack effect (New).
- **Items:** Five-Phase Flag.
- **Element stacks:** all.

**Weakness.** The slowest early life in the game.

**New pieces.**
- **Universal stack effect**: `stack_effect_pct` without an element scope (broad).

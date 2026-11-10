# Triple root: Metal, Water and Fire (Kim, Thủy, Hỏa)

**What the root brings.** One generating pair (Metal → Water, +3 %); Fire with Metal can converge into Thunder;
Water quenches Fire. Physical damage and debuff, the mana buff, Burn and damage. The smith's quench: steel, water,
fire.

---

## 1. The Tempered Steel (Tôi Cương)

**Concept.** Heat, quench, heat, quench: each cycle makes the blade harder. The build alternates Fire and Water
arts, and every full cycle adds a permanent Metal buff stack.

**How it fights.** A New Effect: "a Water art fired within 2 s after a Fire art grants 2 Metal buff stacks for the
fight". By 40 s the blade carries +20 % Physical.

**Stacks.**
- **Linh căn:** Metal, Water, Fire.
- **Công pháp:** Canh Kim Heaven Canon.
- **Đạo:** Refined Metal, the tempering branch.
- **Keystone:** Edge Returns the Breath (Metal, New).
- **Effects:** Tempering (New); Quench (New, `dual-water-fire.md`).
- **Modifiers:** damage [sword]; `stack_duration_pct` [kim, buff].
- **Items:** Flying Sword; Gourd.
- **Element stacks:** Metal buff, Water buff, Fire buff.

**Weakness.** Silence on one tag breaks the cycle.

**New pieces.**
- **Tempering (Tôi Luyện)**, an Effect: "a Water art fired within 2 s of your Fire art grants 2 Metal buff stacks for
  the fight". How to create: trigger on art fired, reading the last art's element and time.

## 2. The Steam Hammer (Chưng Chùy)

**Concept.** Water's deep pool powers one huge forge hammer every 12 s, its head red-hot.

**How it fights.** The Crushing Tide (`single-water.md`) with a Physical-to-Fire hammer and Metal debuff.

**Stacks.**
- **Linh căn:** Metal, Water, Fire.
- **Công pháp:** Dark Water Heaven Canon.
- **Đạo:** Lava's cousin; Refined Metal.
- **Keystone:** The Spring Never Fails (Water, New).
- **Effects:** Measured Stroke (exists).
- **Modifiers:** damage [costly], `convert_pct` Physical → Fire.
- **Items:** Seal; Bell.
- **Element stacks:** Water buff, Metal debuff, Fire debuff.

**Weakness.** Evasion (take Measured Stroke); Ice stacks.

**New pieces.** None.

## 3. The Storm Kettle (Lôi Ấm), toward Thunder

**Concept.** A root with all of Thunder's parents and a deep pool: crit swords now, lightning later.

**How it fights.** Called Blow crits; Water stacks for the pool. After Thunder: `variant-thunder.md`.

**Stacks.**
- **Linh căn:** Metal, Water, Fire.
- **Công pháp:** Canh Kim Heaven Canon.
- **Đạo:** Heavenly Thunder when glimpsed.
- **Keystone:** Edge Returns the Breath (New).
- **Effects:** Called Blow (exists).
- **Modifiers:** crit chance; maximum linh lực.
- **Items:** Flying Swords.
- **Element stacks:** Metal debuff, Water buff.

**Weakness.** Block.

**New pieces.** None.

## 4. The Executioner (Hành Hình Quan)

**Concept.** The answer to healers and regenerators. A cold blade (Metal and Water) and a branding iron (Fire): every
wound it gives stops healing.

**How it fights.** Withering (healing taken −50 %) and Stagnation (no regeneration) kept up by curse arts; Burn and
Metal debuff for the damage. Health-paid builds and healers collapse.

**Stacks.**
- **Linh căn:** Metal, Water, Fire.
- **Công pháp:** Canh Kim Heaven Canon.
- **Đạo:** Death (Tử Đạo).
- **Keystone:** Edge Returns the Breath (Metal, New).
- **Effects:** Marked Prey (exists).
- **Modifiers:** status chance; art cost [curse].
- **Items:** Branding Iron (New kind) or a Seal.
- **Element stacks:** Metal debuff, Fire debuff.

**Weakness.** Plain damage builds that never heal; cleansing.

**New pieces.**
- **Branding Iron (Lạc Thiết)**, an artifact kind: curse focus, raises curse duration. How to create: add a kind to
  `items_artifacts.json` (utility, curse role).

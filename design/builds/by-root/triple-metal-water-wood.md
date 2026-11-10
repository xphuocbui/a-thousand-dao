# Triple root: Metal, Water and Wood (Kim, Thủy, Mộc)

**What the root brings.** Two generating pairs (Metal → Water → Wood, +6 %). Physical damage and debuff, the mana
buff, Poison and health regeneration. A sustain root with a blade.

---

## 1. The Bamboo Sword (Trúc Kiếm)

**Concept.** A sword school in a bamboo grove: thin, flexible blades that never tire. Water keeps the pool, Wood
keeps the body, Metal keeps the edge.

**How it fights.** Quick sword arts with Metal debuff; a Wood art every 4 s keeps Wood buff stacks up; Water stacks
deepen the pool. It wins the long fight.

**Stacks.**
- **Linh căn:** Metal, Water, Wood.
- **Công pháp:** Canh Kim Heaven Canon.
- **Đạo:** Sword.
- **Keystone:** The Spring Never Fails (Water, New).
- **Effects:** Flowing Water (exists).
- **Modifiers:** damage [sword]; health regeneration; linh lực regeneration.
- **Items:** Flying Swords; Green Wood Array.
- **Element stacks:** Metal debuff, Water buff, Wood buff.

**Weakness.** Burst.

**New pieces.** None.

## 2. The Poisoned Needle Doctor (Độc Châm Y)

**Concept.** A physician who heals allies and poisons enemies with the same needles. Needles (Metal) carry Poison
(Wood); Water keeps the hand steady.

**How it fights.** Needle arts apply Poison and Metal debuff; a heal art refunds its cost.

**Stacks.**
- **Linh căn:** Metal, Water, Wood.
- **Công pháp:** Green Wood Heaven Canon.
- **Đạo:** Life, or Poison.
- **Keystone:** Root Drinks the Rot (Wood, New).
- **Effects:** Marked Prey (exists).
- **Modifiers:** damage [poison]; healing.
- **Items:** Needle (Châm).
- **Element stacks:** Wood debuff, Metal debuff.

**Weakness.** Cleansing.

**New pieces.** None.

## 3. The Waterwheel Mill (Thủy Xa)

**Concept.** A mill that turns forever: Water drives the wheel, the wheel turns the blades. Each art fired makes the
next cheaper, and Water stacks make every turn last.

**How it fights.** A New Effect: each art fired reduces the next art's cost by 2 %, stacking until an art of another
element fires.

**Stacks.**
- **Linh căn:** Metal, Water, Wood.
- **Công pháp:** Dark Water Heaven Canon.
- **Đạo:** Mist.
- **Keystone:** The Spring Never Fails (New).
- **Effects:** Turning Wheel (New).
- **Modifiers:** art cost; art speed.
- **Items:** Bell.
- **Element stacks:** Water buff.

**Weakness.** Silence on its element tag breaks the chain.

**New pieces.**
- **Turning Wheel (Xa Luân)**, an Effect: "each art of one element you fire lowers the next art of that element's
  cost by 2 %, stacking, reset when another element's art fires". How to create: Effect with a per-count read
  (firings this fight, a readable).

## 4. The Zither Player (Cầm Sư)

**Concept.** Metal strings on a wooden body, played beside water. Music that wounds the soul: every note is a soul
art, and the melody heals the player between strikes.

**How it fights.** A soul art each second (the lockout), each delaying the foe's next art; a heal art refunds its
cost; Water stacks keep the pool calm.

**Stacks.**
- **Linh căn:** Metal, Water, Wood.
- **Công pháp:** Green Wood Earth Scripture with soul arts (New).
- **Đạo:** Soul (Hồn Đạo).
- **Keystone:** Divided Divine Sense (capability, exists).
- **Effects:** Soul Wound (exists).
- **Modifiers:** `x_soul`; thần thức; healing.
- **Items:** Zither (New kind); Soul-Guarding Lamp.
- **Element stacks:** Water buff, Wood buff.

**Weakness.** Soul resistance; deafness (a New curse that blocks the [music] tag would be its counter).

**New pieces.**
- **Zither (Cầm)**, an artifact kind for music soul arts. How to create: add a kind to `items_artifacts.json` with a
  [music] form tag (a new form tag in the Modifier System's vocabulary).

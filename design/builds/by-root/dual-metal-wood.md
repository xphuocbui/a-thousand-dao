# Dual root: Metal and Wood (Kim, Mộc)

**What the pair brings.** An overcoming pair (Metal cuts Wood): the axe and the tree. Metal's Physical damage and
Physical-taken debuff; Wood's Poison and health regeneration. Bleed (Physical) and Poison (Chaos) are both ticks
that pass different defences. Linh lực keystones: Edge Returns the Breath (Metal, New), Root Drinks the Rot (Wood,
New).

---

## 1. The Woodcutter (Tiều Phu)

**Concept.** Bleed and rot: an axe opens the wound, sap poisons it. Two statuses for Marked Prey, two tick types
that need two different answers.

**How it fights.** Physical crits apply Bleed (Opening Cut); Wood arts apply Poison. Marked Prey counts both, and
Metal debuff raises the Physical part.

**Stacks.**
- **Linh căn:** Metal and Wood.
- **Công pháp:** Canh Kim Earth Scripture.
- **Đạo:** Destruction (Hủy Diệt) or Poison.
- **Keystone:** Edge Returns the Breath (New).
- **Effects:** Opening Cut (exists), Marked Prey (exists).
- **Modifiers:** crit chance; damage [over_time]; `stack_duration_pct` [moc, debuff].
- **Items:** an Axe-like Flying Sword (artifact kind exists as Phi Kiếm; an Axe kind is New).
- **Element stacks:** Metal debuff, Wood debuff.

**Weakness.** Cleansing; body shields soak Bleed (but not Poison).

**New pieces.**
- **Axe (Phủ)**, an artifact kind: slow, heavy, Physical, a Bleed affix. How to create: add a kind to
  `items_artifacts.json` (weapon role).

## 2. The Thorn Armour (Kinh Giáp)

**Concept.** A body covered in iron thorns: every hit that lands on it returns a Poisoned thorn.

**How it fights.** Wood buff regenerates; a thorn Effect returns damage and Poison to attackers. A slow, cruel tank.

**Stacks.**
- **Linh căn:** Metal and Wood.
- **Công pháp:** Diamond Body (Kim Cang Thể).
- **Đạo:** Life.
- **Keystone:** Root Drinks the Rot (New).
- **Effects:** Thorns (New).
- **Modifiers:** block; health regeneration; `stack_effect_pct` [moc, debuff].
- **Items:** Armour body gear; Iron Shirt.
- **Element stacks:** Wood buff, Wood debuff.

**Weakness.** Ranged soul attacks; foes with few big hits trigger few thorns.

**New pieces.**
- **Thorns (Kinh Thứ)**, an Effect: "when a hit reaches your health, the attacker takes 10 % of it back as Physical
  and gains 1 Poison stack". How to create: trigger on being hit, action "free hit" (Combat Formulas G) plus a
  debuff grant.

## 3. The Iron Tree (Thiết Thụ)

**Concept.** A tree that grew around a sword: Metal arts paid in health, Wood regeneration paying the health back.
The linh lực pool is only for the ward.

**How it fights.** Like Blood on the Whetstone (single Metal), with Wood buff stacks for regeneration instead of
leech.

**Stacks.**
- **Linh căn:** Metal and Wood.
- **Công pháp:** Canh Kim Heaven Canon.
- **Đạo:** Sword.
- **Keystone:** Blood Casting (exists).
- **Effects:** Iron Skin Renewed (exists).
- **Modifiers:** `art_cost_health_pct`; health regeneration; damage [sword].
- **Items:** Flying Sword; Common Ward.
- **Element stacks:** Wood buff, Metal debuff.

**Weakness.** Withering, Stagnation.

**New pieces.** Whetstone Vow (see `single-metal.md`).

## 4. The Last One Standing (Hậu Tồn Giả)

**Concept.** A build made for fatigue. After 60 s, both sides lose a growing share of health each second; this
cultivator arrives at 60 s with more health share left and one refusal held, so it stands one pulse longer.

**How it fights.** Defensive until 60 s: Wood regeneration, Metal block, a reserved aura, few arts. From 60 s, the
foe's share falls as fast as its own, but it started lower; Unyielding Breath buys the last pulse.

**Stacks.**
- **Linh căn:** Metal and Wood.
- **Công pháp:** Diamond Body (Kim Cang Thể).
- **Đạo:** Life.
- **Keystone:** Unyielding Breath (exists, Effect keystone).
- **Effects:** Unyielding Breath (exists), Still Water (exists).
- **Modifiers:** health regeneration; block; reservation efficiency.
- **Items:** Still Lake Aura; Armour.
- **Element stacks:** Wood buff, Metal buff.

**Weakness.** A foe who kills before 60 s; Withering and Stagnation.

**New pieces.**
- **Endurance (Nhẫn Nại)**, an Effect: "fatigue takes 20 % less from you". How to create: rule change on Combat's
  fatigue (rule 10); fatigue is meant to be unchangeable, so this needs the user's ruling first (rare, keystone
  tier).

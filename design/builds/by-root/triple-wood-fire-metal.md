# Triple root: Wood, Fire and Metal (Mộc, Hỏa, Kim)

**What the root brings.** One generating pair (Wood → Fire, +3 %); Fire with Metal can converge into Thunder; Metal
cuts Wood. Poison, Burn, Metal debuff: three debuffs and three tick-or-amp layers. An aggressive root.

---

## 1. The Three Wounds (Tam Thương)

**Concept.** Cut, burn, rot. Three statuses on the foe at all times; Marked Prey grows with each distinct one.

**How it fights.** A sword art (Bleed through Opening Cut), a Fire art (Burn), a Wood art (Poison). With Bleed, Burn
and Poison on the foe, Marked Prey is at full strength; Metal debuff amplifies the Physical part.

**Stacks.**
- **Linh căn:** Wood, Fire, Metal.
- **Công pháp:** Canh Kim Earth Scripture.
- **Đạo:** Destruction (Hủy Diệt).
- **Keystone:** Embers Feed the Hearth (Fire, New).
- **Effects:** Marked Prey (exists), Opening Cut (exists), Spillover (exists).
- **Modifiers:** damage [over_time]; crit chance; `stack_duration_pct` on each debuff.
- **Items:** Flying Sword, Fan, Gourd.
- **Element stacks:** Metal, Fire and Wood debuffs.

**Weakness.** An element-wide cleanse removes one; a share cleanse thins all three.

**New pieces.** None.

## 2. The Burning Forest Axeman (Phần Lâm Phủ)

**Concept.** Fell the tree, burn the stump. Physical axe blows build Metal debuff; Fire arts deal more per Metal
debuff stack (the iron conducts the heat).

**How it fights.** A New Effect lets Fire hits deal +1 % per Metal debuff stack on the target.

**Stacks.**
- **Linh căn:** Wood, Fire, Metal.
- **Công pháp:** Crimson Flame Heaven Canon.
- **Đạo:** Lava if Earth joins; else Destruction.
- **Keystone:** Edge Returns the Breath (Metal, New).
- **Effects:** Heat Through Iron (New).
- **Modifiers:** damage [fire]; damage [physical].
- **Items:** Axe (New kind, `dual-metal-wood.md`).
- **Element stacks:** Metal debuff, Fire buff.

**Weakness.** Fire resistance.

**New pieces.**
- **Heat Through Iron (Nhiệt Xuyên Thiết)**, an Effect: "your Fire hits deal +1 % more per Metal debuff stack on
  the target". How to create: Effect reading stack counts, payload L5 scoped [fire].

## 3. The Lightning Rod Grove (Lôi Trúc Lâm), toward Thunder

**Concept.** A grove of iron trees that calls the storm: a Fire–Metal root reaching for Thunder, with Wood to heal
between strikes.

**How it fights.** Crit-heavy Metal arts, Wood regeneration; after Thunder forms, see `variant-thunder.md`.

**Stacks.**
- **Linh căn:** Wood, Fire, Metal (Fire and Metal high).
- **Công pháp:** Canh Kim Heaven Canon → Thunder Emperor Canon.
- **Đạo:** Heavenly Thunder when glimpsed.
- **Keystone:** Edge Returns the Breath (New).
- **Effects:** Called Blow (exists).
- **Modifiers:** crit chance; health regeneration.
- **Items:** Flying Swords.
- **Element stacks:** Metal debuff, Wood buff.

**Weakness.** Block.

**New pieces.** None.

## 4. The Firework Maker (Pháo Hoa Sư)

**Concept.** Paper (Wood), powder (Fire), iron shot (Metal). A talisman maker whose fireworks burst into Burn and
shrapnel Bleed, all paid in advance.

**How it fights.** Talismans in art slots cost no linh lực (Paid in Advance); each burst lays Burn and, on a crit,
Bleed. Marked Prey counts both.

**Stacks.**
- **Linh căn:** Wood, Fire, Metal.
- **Công pháp:** Crimson Flame Earth Scripture.
- **Đạo:** Talisman Đạo (New, `dual-wood-fire.md`).
- **Keystone:** Endless Talismans (capability, exists).
- **Effects:** Paid in Advance (exists), Talisman Sleeve (exists), Opening Cut (exists), Marked Prey (exists).
- **Modifiers:** talisman power (Pending key); crit chance.
- **Items:** Shrapnel Talisman (New).
- **Element stacks:** Fire debuff, Metal debuff.

**Weakness.** The talisman stock.

**New pieces.**
- **Shrapnel Talisman (Toái Thiết Phù)**, a talisman: a Fire-and-Physical burst that lays Burn and Metal debuff. How
  to create: `crafting_talismans.json` entry, drawn with Fire ink on iron-dust paper.

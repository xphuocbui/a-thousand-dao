# Single root: Water (Thủy)

**What Water brings.** Physical (a crushing wave) or Cold (freezing mist). Water has a buff and no debuff: each
stack adds +1 % maximum linh lực and +0.05 pp linh lực regeneration. After #44 that makes Water **the mana
element**. Craft role: pill toxicity fades faster. Công pháp: Dark Water Earth Scripture (Huyền Thủy Địa Quyết),
Dark Water Heaven Canon (Huyền Thủy Thiên Kinh). A pure Water root can transmute into Ice (variant).

**Water's linh lực keystone (New, every Water build):** **The Spring Never Fails (Tuyền Bất Kiệt)**: each Water
stack you hold adds +0.025 pp linh lực regeneration, outside diminishing returns (fitted 2026-11-10, `notes.md` § 9).
How to create: Meridian Map keystone in the Water land; an Effect reading your Water stack count, payload a flat
regeneration share that Combat Formulas E adds after the diminishing-returns step; closing cost "your maximum linh
lực from other sources is halved".

---

## 1. The Deep Sea (Thâm Hải)

**Concept.** The pool that never runs dry. Every art adds Water stacks for the fight, so the longer it fights,
the deeper the sea; at 50 s it has twice the pool of the start.

**How it fights.** Cheap Water arts grant 1 buff stack each "for the fight". At 40 firings the pool is +40 % and
regeneration +2 pp. Its ward never drops; the foe's does around 30 s, and then the fight ends.

**Stacks.**
- **Linh căn:** single Water, high purity.
- **Công pháp:** Dark Water Heaven Canon.
- **Đạo:** Mist (Vụ Đạo), the endless-tide branch (stack duration, regeneration).
- **Keystone:** The Spring Never Fails (New).
- **Effects:** Steady Breath (exists: more damage while linh lực ≥ 50 %, which this build holds all fight), Still
  Water (exists: overflow heals).
- **Modifiers:** `linh_luc_regen_pct`, `linh_luc_regen_inc_pct`, maximum linh lực, `stack_effect_pct` [thuy, buff].
- **Items:** Gourd (Hồ Lô) as a water vessel; Still Lake Aura (reserved all resistance), affordable because the
  pool is deep.
- **Element stacks:** Water buff.

**Weakness.** It deals ordinary damage; a burst build that wins before 20 s, before the sea is deep. Ice stacks
(art cost) slow it.

**New pieces.**
- **Gathering Tide (Tụ Triều)**, an art that grants 2 Water buff stacks "for the fight". How to create: art in Dark
  Water Heaven Canon; pays the stack charge (Water's buff weight is the highest, 2.2 % per stack-second, so its
  damage is small).

## 2. The Overflowing Cup (Mãn Bôi)

**Concept.** A mana-based công pháp: damage scales with how full the pool is, and what spills over a full pool
becomes a shield.

**How it fights.** Stays near full linh lực all fight (big regeneration, cheap arts). Arts deal more for each
10 % of linh lực remaining. Overflow turns into a ward shield.

**Stacks.**
- **Linh căn:** single Water.
- **Công pháp:** Dark Water Earth Scripture.
- **Đạo:** Mist, the still-pool branch.
- **Keystone:** The Spring Never Fails (New).
- **Effects:** Steady Breath (exists); Still Water (exists, health version).
- **Modifiers:** linh lực regeneration; art cost reduction; ward strength.
- **Items:** Shield (Thuẫn) artifact; Mountain Screen.
- **Element stacks:** Water buff.

**Weakness.** Anything that drains its pool (Qi Disruption, Spillover, Leaking Ward) knocks it out of its best
state.

**New pieces.**
- **Brimming Cup (Mãn Bôi Quyết)**, an Effect: "your arts deal +2 % more for every 10 % of linh lực remaining".
  How to create: Effect reading own linh lực share (readable), payload L5 `damage_more`.
- **Spill Shield (Dật Thuẫn)**, an Effect: "overflow becomes a ward shield, up to 20 % of maximum linh lực". How to
  create: Effect on the overflow event (#44 readable), action "raise a ward shield".

## 3. The Crushing Tide (Hải Áp)

**Concept.** Water as weight: a Physical wave build that saves for one great tide every 12 s, paying for it from
a pool no one else can match.

**How it fights.** Small arts keep Water stacks up; every 12 s a costly wave art (cost 10–12.5 %) crashes. Water
stacks make the cost bearable.

**Stacks.**
- **Linh căn:** single Water.
- **Công pháp:** Dark Water Heaven Canon.
- **Đạo:** Mist, the tide branch.
- **Keystone:** The Spring Never Fails (New).
- **Effects:** Measured Stroke (exists) for an unmissable wave.
- **Modifiers:** damage [costly], [slow]; art cost [costly].
- **Items:** Bell (Chuông) to ring the tide; Golden Bell (per-hit ward) since it fights slow heavy hitters.
- **Element stacks:** Water buff.

**Weakness.** Evasive foes; Ice stacks (art cost) hit costly arts hardest.

**New pieces.** None needed beyond the keystone.

## 4. The Moon in the Well (Tỉnh Nguyệt)

**Concept.** The moon is in the well and not in the well. An illusionist of still water: the foe strikes a
reflection, and soul arts ripple into its mind.

**How it fights.** A reflection ward gives evade; soul arts delay the foe's arts (Soul Wound); Water stacks keep the
pool deep for both.

**Stacks.**
- **Linh căn:** single Water.
- **Công pháp:** Dark Water Earth Scripture.
- **Đạo:** Illusion (Huyễn Đạo).
- **Keystone:** The Spring Never Fails (New).
- **Effects:** Soul Wound (exists), Beneath Notice (exists).
- **Modifiers:** evade; `x_soul`; thần thức.
- **Items:** Mirror (New kind, `variant-combos.md`); Steam Veil (New ward, `dual-water-fire.md`).
- **Element stacks:** Water buff.

**Weakness.** Ticks and soul resistance.

**New pieces.** None beyond those named.

# Triple root: Fire, Earth and Water (Hỏa, Thổ, Thủy)

**What the root brings.** One generating pair (Fire → Earth, +3 %); Earth with Water can converge into Darkness;
Water quenches Fire. Burn and damage, Physical resistance and accuracy debuff, the mana buff. Steam, mud and stone.

---

## 1. The Hot Spring (Ôn Tuyền)

**Concept.** Water heated by fire under stone: a healing spring. A sustain build that stays in its spring
(prepared ground) and outlasts.

**How it fights.** Prepared ground (a Hot Spring formation, New) heals and refills linh lực each pulse; cheap Fire
arts burn the foe.

**Stacks.**
- **Linh căn:** Fire, Earth, Water.
- **Công pháp:** Deep Earth Earth Scripture.
- **Đạo:** Array.
- **Keystone:** The Spring Never Fails (Water, New).
- **Effects:** Field Walls (exists).
- **Modifiers:** formation power; linh lực regeneration; health regeneration.
- **Items:** Hot Spring Array (New).
- **Element stacks:** Water buff, Fire debuff.

**Weakness.** Away from home.

**New pieces.**
- **Hot Spring Array (Ôn Tuyền Trận)**, a formation: "+X pp linh lực and health regeneration for its owner on its
  ground". How to create: `crafting_formations.json` entry; laid with Earth, Fire and Water materials.

## 2. The Mud Golem (Nê Nhân)

**Concept.** A thể tu of baked mud: Earth resistance, Water to soften blows, Fire to harden the shell when hit.

**How it fights.** Each Fire art fired restores body shield; Earth buff stacks dampen Physical damage; Water stacks keep
the pool for the ward.

**Stacks.**
- **Linh căn:** Fire, Earth, Water.
- **Công pháp:** Dragon-Elephant.
- **Đạo:** Gravity.
- **Keystone:** The Stone Remembers (Earth, New).
- **Effects:** Iron Skin Renewed's Fire twin (New).
- **Modifiers:** body shield; resistance [physical].
- **Items:** Armour body gear.
- **Element stacks:** Earth buff, Water buff.

**Weakness.** Chaos.

**New pieces.**
- **Baked Shell (Nung Xác)**, an Effect: "when you fire a Fire art, your body shield regains 2 % of maximum
  health". How to create: copy Iron Skin Renewed with a [fire] scope.

## 3. The Geyser (Mạch Phun)

**Concept.** Pressure builds under stone until it erupts: a build that holds its arts until the pool is full, then
fires everything in one instant.

**How it fights.** Guards hold all arts until linh lực ≥ 90 %; then all fire together, with a New Effect that adds
damage per art fired in the same instant.

**Stacks.**
- **Linh căn:** Fire, Earth, Water.
- **Công pháp:** Dark Water Heaven Canon.
- **Đạo:** Lava.
- **Keystone:** The Spring Never Fails (New).
- **Effects:** Eruption (New); Steady Breath (exists).
- **Modifiers:** damage [fire]; maximum linh lực.
- **Items:** Gourd.
- **Element stacks:** Water buff, Fire debuff.

**Weakness.** Burst during the wait; drain.

**New pieces.**
- **Eruption (Phún Trào)**, an Effect: "your hits deal +5 % more for each other art you fired in the same instant".
  How to create: Effect reading firings this instant (add to the readable list).

## 4. The Potter's Golems (Đào Ngẫu Sư)

**Concept.** Clay (Earth) shaped with water (Water) and fired in a kiln (Fire): a potter who makes clay soldiers and
sends them in.

**How it fights.** Two golem companions (Earth-tagged) lay Earth debuff and soak hits; the potter keeps its pool for
the ward and fires a Fire art now and then.

**Stacks.**
- **Linh căn:** Fire, Earth, Water.
- **Công pháp:** Deep Earth Earth Scripture.
- **Đạo:** Array, the puppet branch (New nodes).
- **Keystone:** Ten Thousand Beasts, One Heart (capability, exists) for two golems.
- **Effects:** Pack Hunt (exists), Bare Rack (exists).
- **Modifiers:** companion power share.
- **Items:** Clay Golem (New companion item).
- **Element stacks:** Earth debuff (from the golems).

**Weakness.** Area damage; a foe who ignores the golems and strikes the potter.

**New pieces.**
- **Clay Golem (Đào Ngẫu)**, a companion made, not tamed: an item that becomes a creature record when fired in a
  kiln. How to create: Artifact Refining recipe producing a creature (see Awakened Artifact, `dual-fire-metal.md`).

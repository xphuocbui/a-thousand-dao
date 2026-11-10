# Triple root: Wood, Fire and Earth (Mộc, Hỏa, Thổ)

**What the root brings.** Two generating pairs (Wood → Fire → Earth, +6 %). A slow start and a strong late game.
Poison, Burn and the accuracy debuff; health regeneration, damage and Physical resistance buffs. The chain of
growth, burning and ash: a natural cycle build. Đạo parents: Lava (Fire, Earth), Life (Wood).

---

## 1. The Turning Season (Tứ Thời Luân)

**Concept.** Grow, burn, settle. The build rotates through three phases on a 12 s wheel, and each phase feeds the
next: Wood arts heal and poison, Fire arts burn what grew, Earth arts harden in the ash.

**How it fights.** Three arts on 12 s cooldowns offset by 4 s. A New Effect makes each element's art stronger for
every stack the previous phase left (Fire deals more per Poison stack on the foe; Earth grants more resistance per
Burn stack on the foe).

**Stacks.**
- **Linh căn:** Wood, Fire, Earth, balanced purities.
- **Công pháp:** a three-element technique (New); until then Green Wood Earth Scripture.
- **Đạo:** Reincarnation (Luân Hồi), the cycle branch.
- **Keystone:** Embers Feed the Hearth (Fire, New).
- **Effects:** Fuel for the Fire (New, `dual-wood-fire.md`); Generating Cycle (New, below).
- **Modifiers:** damage [moc], [hoa], [tho]; `stack_duration_pct` on all three.
- **Items:** Flag (Kỳ) of the seasons; Mountain Screen.
- **Element stacks:** Wood debuff, Fire debuff, Earth buff.

**Weakness.** A build that wins in the first 12 s, before one turn completes.

**New pieces.**
- **Generating Cycle (Tương Sinh Luân)**, an Effect: "your art of an element deals +2 % more for each stack of the
  element that generates it on the target or on you". How to create: Effect reading element stack counts, with a
  fixed generating table (Wood → Fire → Earth → Metal → Water → Wood).
- **Three Seasons Canon (Tam Thời Kinh)**, a công pháp naming three elements.

## 2. The Burnt Field (Phần Điền)

**Concept.** Slash-and-burn farming as a fight: burn the field, the ash feeds the next crop. Poison and Burn on the
foe; the cultivator's own fields and herbs make it rich.

**How it fights.** A tick build with both streams and an Earth body; slow to start, strong at 40 s.

**Stacks.**
- **Linh căn:** Wood, Fire, Earth (herbs, alchemy, fields: every craft but refining).
- **Công pháp:** Crimson Flame Earth Scripture.
- **Đạo:** Lava, or Spirit Farming for the economy.
- **Keystone:** Root Drinks the Rot (Wood, New).
- **Effects:** Marked Prey (exists), Spillover (exists).
- **Modifiers:** damage [over_time]; herb growth; alchemy success.
- **Items:** self-brewed pills; Gourd.
- **Element stacks:** Wood debuff, Fire debuff.

**Weakness.** Cleansing.

**New pieces.** None beyond those above.

## 3. The Incense Burner (Hương Lô Sư)

**Concept.** Resin from the tree (Wood), fire in the censer (Fire), ash in a bronze bowl of earth (Earth). The smoke
enters the foe's mind: soul arts carried on incense, and ash that blinds.

**How it fights.** Soul arts every second (the soul lockout); each soul hit delays the foe's next art (Soul Wound).
Ash arts lay Earth debuff (−accuracy). The foe acts late and misses.

**Stacks.**
- **Linh căn:** Wood, Fire, Earth.
- **Công pháp:** Crimson Flame Earth Scripture, with an incense soul art (New).
- **Đạo:** Soul (Hồn Đạo), or Illusion.
- **Keystone:** Divided Divine Sense (capability, exists).
- **Effects:** Soul Wound (exists), Open Sky (exists).
- **Modifiers:** `x_soul`; thần thức; `stack_duration_pct` [tho, debuff].
- **Items:** Censer (New kind); Soul-Guarding Lamp.
- **Element stacks:** Earth debuff.

**Weakness.** High soul resistance; a foe with a soul shield.

**New pieces.**
- **Censer (Hương Lô)**, an artifact kind: holds an incense soul art; its thần thức cost is low. How to create: add
  a kind to `items_artifacts.json` (utility, soul role).
- **Incense Smoke (Hương Yên)**, a soul art that also lays 1 Earth debuff stack. How to create: soul art record with a
  debuff grant (Combat E2 plus Effects rule 9a).

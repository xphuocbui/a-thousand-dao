# Dual root: Water and Wood (Thủy, Mộc)

**What the pair brings.** A generating pair (Water feeds Wood, +3 %). Water's mana buff, Wood's health
regeneration buff and Poison debuff. The calm, sustaining root: the longest-lived pools and bodies. Crafts: herbs and
pill toxicity fading. Linh lực keystones: The Spring Never Fails (Water, New), Root Drinks the Rot (Wood, New).

---

## 1. The Marsh (Đầm Lầy)

**Concept.** A swamp that never dries. Poison seeps through every shield while the cultivator's own pool and body
refill faster than anything can drain them.

**How it fights.** Wood Poison arts with long batches; Water stacks deepen the pool; Root Drinks the Rot leeches
linh lực from the poisoned foe. A 60 s fight is its home.

**Stacks.**
- **Linh căn:** Water and Wood.
- **Công pháp:** Green Wood Heaven Canon.
- **Đạo:** Poison, or Mist for the deep pool.
- **Keystone:** Root Drinks the Rot (New).
- **Effects:** Spillover (exists), Still Water (exists).
- **Modifiers:** `leech_linh_luc_pct`; `stack_duration_pct` [moc, debuff]; linh lực regeneration.
- **Items:** Gourd; Clear Heart Ward.
- **Element stacks:** Wood debuff, Water buff, Wood buff.

**Weakness.** Burst before 20 s; cleansing.

**New pieces.** None beyond the keystones.

## 2. Spring Rain (Xuân Vũ)

**Concept.** The healer. Heal arts refund their cost, Water stacks feed the pool, Wood stacks feed the body; a
spring rain that keeps falling.

**How it fights.** A heal art every 3 s and two damage arts. It stays topped up in both pools and wins by fatigue
or by the foe's pool running dry.

**Stacks.**
- **Linh căn:** Water and Wood.
- **Công pháp:** Green Wood Earth Scripture.
- **Đạo:** Life (Sinh Đạo).
- **Keystone:** The Spring Never Fails (New).
- **Effects:** Gorged (exists), Still Water (exists).
- **Modifiers:** healing; health regeneration; `linh_luc_regen_inc_pct`.
- **Items:** Green Wood Array; Mountain Screen.
- **Element stacks:** Water buff, Wood buff.

**Weakness.** Withering; a foe who brings Ice stacks (heal arts cost more).

**New pieces.**
- **Rain on Both (Vũ Lưỡng)**, an Effect for support play: "your heal arts also heal an ally companion". How to
  create: action "restore health" with a companion target; needs Combat's companion rules.

## 3. The Lotus on Still Water (Tĩnh Thủy Liên)

**Concept.** A calm meditator: never casts more than it regenerates, stays at full pool, and lets the overflow
become shields and healing.

**How it fights.** Two cheap arts only; the pool is always full, so overflow (#44 readable) turns into a ward
shield and into health through Still Water.

**Stacks.**
- **Linh căn:** Water and Wood.
- **Công pháp:** Dark Water Earth Scripture.
- **Đạo:** Taiji (Thái Cực) or Mist.
- **Keystone:** The Spring Never Fails (New).
- **Effects:** Still Water (exists), Spill Shield (New, see `single-water.md`), Steady Breath (exists).
- **Modifiers:** linh lực regeneration; ward strength.
- **Items:** Shield artifact.
- **Element stacks:** Water buff.

**Weakness.** Low damage: a tanky foe with its own sustain draws it into fatigue.

**New pieces.** Spill Shield (see `single-water.md`).

## 4. The Turtle and the Snake (Quy Xà)

**Concept.** The Black Tortoise of the north is a turtle bound with a snake. This cultivator keeps both: a turtle
companion that wards and a snake companion that poisons.

**How it fights.** Two companions (Ten Thousand Beasts allows more): the turtle carries a shield Effect for its
keeper, the snake's bites lay Poison. The keeper heals both.

**Stacks.**
- **Linh căn:** Water and Wood.
- **Công pháp:** Green Wood Earth Scripture.
- **Đạo:** Life.
- **Keystone:** Ten Thousand Beasts, One Heart (capability, exists).
- **Effects:** Pack Hunt (exists), Rain on Both (New, this file).
- **Modifiers:** companion power share; healing.
- **Items:** two beasts; Black Tortoise Shell ward.
- **Element stacks:** Wood debuff (snake), Water buff (keeper).

**Weakness.** Area damage; kill the snake first.

**New pieces.**
- **Guardian companion**: a companion whose Effect raises a shield on its keeper instead of attacking. How to
  create: a creature record field "guardian" plus an Effect "raise a ward shield on your keeper each N s".

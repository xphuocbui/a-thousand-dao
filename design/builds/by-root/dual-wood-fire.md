# Dual root: Wood and Fire (Mộc, Hỏa)

**What the pair brings.** A generating pair (Wood feeds Fire, +3 % cultivation speed). Two tick debuffs that never
merge: **Poison** (Chaos, passes shields) and **Burn** (Fire, wears body shields). Wood's buff is health
regeneration, Fire's is +1 % damage. Crafts: herbs and alchemy, the full pill chain from field to furnace.
Linh lực keystones available: Root Drinks the Rot (Wood, New) and Embers Feed the Hearth (Fire, New).

---

## 1. Wildfire (Dã Hỏa)

**Concept.** Wood is fuel. Every Poison stack the foe carries makes your Burn hit harder, so the forest burns
twice: rot, then flame.

**How it fights.** Wood arts lay Poison; Fire arts lay Burn. Marked Prey counts two distinct statuses. A new Effect
lets Burn deal more for every 5 Poison stacks on the target. Two tick streams pass two different defences: Poison
slips past shields, Burn grinds them.

**Stacks.**
- **Linh căn:** Wood and Fire, both at 50+ purity.
- **Công pháp:** Green Wood Heaven Canon for the poison arts; a Fire art from Crimson Flame on a second slot (a
  technique naming both elements would be better: New).
- **Đạo:** Poison (Độc Đạo) for duration, or Lava if Earth joins later.
- **Keystone:** Embers Feed the Hearth (New) for linh lực from Burn ticks.
- **Effects:** Marked Prey (exists), Kindled Wound (exists), Spillover (exists).
- **Modifiers:** damage [over_time]; `stack_duration_pct` [moc, debuff] and [hoa, debuff]; damage [fire].
- **Items:** Fan (Phiến) to drive the fire; Gourd of venom.
- **Element stacks:** Wood debuff, Fire debuff, Fire buff.

**Weakness.** One cleansing ward clears both streams; a Chaos-and-Fire resistant foe (rare).

**New pieces.**
- **Fuel for the Fire (Tân Hỏa)**, an Effect: "your Burn deals +3 % more for every 5 of your Poison stacks on the
  target". How to create: Effect reading element stack counts, payload L5 `damage_more` scoped [burn].
- **Green Flame Scripture (Thanh Diễm Quyết)**, a công pháp naming Wood and Fire. How to create: an
  `items_cong_phap.json` entry with both elements, speed scaled by the average purity.

## 2. The Charcoal Kiln (Thán Lô)

**Concept.** Burn the body to fuel the fire. Wood buff stacks regrow health fast; Blood Casting spends that health
on Fire arts. Linh lực stays untouched for the ward.

**How it fights.** Fire arts paid in health; Wood buff stacks (from a cheap Wood art every 2 s) regenerate it. The
foe faces a full ward and a fire that never runs out of fuel.

**Stacks.**
- **Linh căn:** Wood and Fire.
- **Công pháp:** Crimson Flame Earth Scripture.
- **Đạo:** Life (Sinh Đạo), the regrowth branch.
- **Keystone:** Blood Casting (exists).
- **Effects:** Gorged (exists: more damage per health restored).
- **Modifiers:** `art_cost_health_pct`; health regeneration; `stack_effect_pct` [moc, buff]; damage [fire].
- **Items:** Green Wood Array (prepared); Common Ward.
- **Element stacks:** Wood buff, Fire buff.

**Weakness.** Withering and Stagnation (regeneration blocked) collapse it; fatigue after 60 s.

**New pieces.** None.

## 3. The Herb-and-Furnace Sect Elder (Dược Lô Trưởng Lão)

**Concept.** A crafter who barely fights: grows herbs (Wood), brews them (Fire), and arrives at every fight with
the right pill already in the blood.

**How it fights.** Foreseen fights only: three self-brewed pills (L4 more, a resistance pill, a regeneration pill)
make an ordinary kit dangerous. Blind fights are its weakness.

**Stacks.**
- **Linh căn:** Wood and Fire (herb growth, alchemy).
- **Công pháp:** Green Wood Earth Scripture.
- **Đạo:** Pill Fire (Đan Hỏa), with Spirit Farming as a second Đạo later.
- **Keystone:** Hundred Herbs Kept Alive (capability, exists: harvested herbs age in the bag); Divided Furnace Flame
  (capability, exists).
- **Effects:** Strange Pill Reborn (exists).
- **Modifiers:** alchemy success, herb growth, pill effect.
- **Items:** its own pills; Gourd.
- **Element stacks:** whatever its arts grant; not the point.

**Weakness.** Blind fights and ambushes.

**New pieces.** Mid-Fight Pill (see `single-fire.md`).

## 4. The Paper Arsonist (Chỉ Hỏa Khách)

**Concept.** Wood makes the paper, Fire writes on it. A talisman cultivator whose fire is all prepaid: talismans
cost no linh lực when they fire, so the whole pool stays for the ward while burning paper does the fighting.

**How it fights.** Fireball talismans (Hỏa Cầu Phù) in art slots, paid in advance; one talisman with a guard rides
for free in the sleeve. Each talisman hit lays Burn. Linh lực only pays the ward, so the ward never falls.

**Stacks.**
- **Linh căn:** Wood and Fire (Wood for talisman paper grown from its own herbs, Fire for the ink's power).
- **Công pháp:** Crimson Flame Earth Scripture.
- **Đạo:** Pill Fire (heat), or a Talisman Đạo (New).
- **Keystone:** Endless Talismans (capability, exists: 30 % chance a talisman is not consumed).
- **Effects:** Paid in Advance (exists), Talisman Sleeve (exists), Kindled Wound (exists).
- **Modifiers:** talisman power (Pending key); damage [talisman], [fire].
- **Items:** a stock of Fireball talismans, self-drawn; Common Ward.
- **Element stacks:** Fire debuff.

**Weakness.** The talisman stock: a long fight or a run of fights empties the sleeve; a foe with Fire resistance.

**New pieces.**
- **Talisman Đạo (Phù Đạo)**: theme stats talisman power, keep chance, drawing speed; keystone "talismans you drew
  yourself carry your element stacks". How to create: a `dao.json` entry requiring Wood or Fire at 40.

# Triple root: Water, Wood and Fire (Thủy, Mộc, Hỏa)

**What the root brings.** Two generating pairs (Water → Wood → Fire, +6 %). The mana buff, Poison and regeneration,
Burn and damage. A root that grows its fuel and then burns it.

---

## 1. The Rainforest Fire (Vũ Lâm Hỏa)

**Concept.** A forest so wet it should not burn, burning anyway. Water deepens the pool, Wood grows the fuel
(Poison), Fire sets it alight. Three phases, one long fight.

**How it fights.** Early: Water stacks. Middle: Poison piles. Late: Fire arts with Fuel for the Fire (Burn deals more
per Poison stack).

**Stacks.**
- **Linh căn:** Water, Wood, Fire.
- **Công pháp:** Green Flame Scripture (New, `dual-wood-fire.md`).
- **Đạo:** Life, the fuel branch.
- **Keystone:** Embers Feed the Hearth (Fire, New).
- **Effects:** Fuel for the Fire (New), Kindled Wound (exists).
- **Modifiers:** damage [over_time]; maximum linh lực.
- **Items:** Gourd, Fan.
- **Element stacks:** Water buff, Wood debuff, Fire debuff.

**Weakness.** Cleansing late in the fight wipes the fuel.

**New pieces.** None beyond those named.

## 2. The Tea Master (Trà Sư)

**Concept.** Water, leaves and fire make tea. A calm cultivator whose pre-fight tea ceremony (a prepared buff) gives
the whole fight its rhythm.

**How it fights.** Foreseen fights: a prepared "tea" grants buff stacks of all three elements for the fight at
t = 0. Ordinary arts after that.

**Stacks.**
- **Linh căn:** Water, Wood, Fire.
- **Công pháp:** Green Wood Earth Scripture.
- **Đạo:** Pill Fire.
- **Keystone:** Divided Furnace Flame (capability, exists).
- **Effects:** Tea Ceremony (New).
- **Modifiers:** pill effect; `stack_duration_pct`.
- **Items:** Spirit Tea (New consumable).
- **Element stacks:** Water, Wood, Fire buffs from the start.

**Weakness.** Blind fights.

**New pieces.**
- **Spirit Tea (Linh Trà)**, a consumable: "at t = 0, grant N buff stacks of each element it was brewed with, for the
  fight". How to create: an Item DB pill-like consumable with a stack-grant payload; brewed by Alchemy from herbs.

## 3. The Lantern Healer (Đăng Y)

**Concept.** A healer with a lantern: Water and Wood heal, the Fire lantern burns those who strike the healer.

**How it fights.** Heal arts refund their cost; a Fire reflect (New) burns attackers.

**Stacks.**
- **Linh căn:** Water, Wood, Fire.
- **Công pháp:** Green Wood Earth Scripture.
- **Đạo:** Yang.
- **Keystone:** The Spring Never Fails (Water, New).
- **Effects:** Gorged (exists); Lantern Burn (New).
- **Modifiers:** healing; health regeneration.
- **Items:** a Lantern artifact (New kind).
- **Element stacks:** Wood buff, Fire debuff.

**Weakness.** Withering.

**New pieces.**
- **Lantern (Đăng)**, an artifact kind: utility, holds a reactive Effect. How to create: add a kind to
  `items_artifacts.json` (utility role).
- **Lantern Burn (Đăng Thiêu)**, an Effect: "when you are hit, the attacker gains 1 Burn stack for 6 s, at most once
  a second".

## 4. The Crane Rider (Hạc Kỵ)

**Concept.** A cultivator who rides a red-crowned crane over lakes and forests. The crane (Water and Wood) heals and
carries; its red crown burns.

**How it fights.** The crane is a companion whose hits lay Burn and whose presence adds Wood buff stacks to its rider;
the rider heals both and fires few arts.

**Stacks.**
- **Linh căn:** Water, Wood, Fire.
- **Công pháp:** Green Wood Earth Scripture.
- **Đạo:** Life.
- **Keystone:** Ten Thousand Beasts, One Heart (capability, exists).
- **Effects:** Pack Hunt (exists), Rain on Both (New, `dual-water-wood.md`).
- **Modifiers:** companion power share; healing; travel speed.
- **Items:** the crane; Swift Walk talisman.
- **Element stacks:** Fire debuff (crane), Wood buff (rider).

**Weakness.** Kill the crane.

**New pieces.** Element-tagged companions (see `triple-fire-earth-metal.md`).

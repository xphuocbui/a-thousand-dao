# Dual root: Water and Fire (Thủy, Hỏa)

**What the pair brings.** An overcoming pair (Water quenches Fire): the yin–yang pair. Water's mana buff and Fire's
damage buff and Burn. Water feeds a deep pool, Fire spends it. Natural Đạo: Yin, Yang, Taiji. Linh lực keystones: The
Spring Never Fails (Water, New), Embers Feed the Hearth (Fire, New).

---

## 1. The Steam Engine (Chưng Khí Cơ)

**Concept.** Water is the boiler, Fire the piston. Water stacks build the pool, Fire spends it on Burn and burst.
The engine gets faster the longer it runs.

**How it fights.** A cheap Water art every 2 s grants Water stacks for the fight; Fire arts spend freely. At 30 s
the pool is deep enough for two Fire arts at once.

**Stacks.**
- **Linh căn:** Water and Fire, both 50+.
- **Công pháp:** Crimson Flame Heaven Canon plus a Water slot (a joint technique is New).
- **Đạo:** Taiji (Thái Cực), the balance branch.
- **Keystone:** Embers Feed the Hearth (New).
- **Effects:** Steady Breath (exists), Kindled Wound (exists).
- **Modifiers:** damage [fire]; maximum linh lực; `stack_effect_pct` [thuy, buff].
- **Items:** Gourd (water) and Fan (fire).
- **Element stacks:** Water buff, Fire buff, Fire debuff.

**Weakness.** Early burst before the boiler is hot.

**New pieces.**
- **Boiling Sea Canon (Phí Hải Kinh)**, a công pháp naming Water and Fire. How to create: `items_cong_phap.json`.

## 2. Yin and Yang Turning (Âm Dương Chuyển)

**Concept.** The balance build: when your pool is high you burn, when it is low you rest and refill. Two halves of
one cycle.

**How it fights.** Arts carry guards: Fire arts fire only above 60 % linh lực, Water arts only below 40 %. Steady
Breath and Spent Breath reward both halves.

**Stacks.**
- **Linh căn:** Water and Fire, purities close together.
- **Công pháp:** any; the guards do the work.
- **Đạo:** Taiji, keystone the turning wheel.
- **Keystone:** The Spring Never Fails (New).
- **Effects:** Steady Breath (exists) on Fire arts, Spent Breath (exists) on Water arts.
- **Modifiers:** damage [fire]; linh lực regeneration.
- **Items:** Bell.
- **Element stacks:** Water buff, Fire buff.

**Weakness.** Drain (Spillover, Qi Disruption) breaks the rhythm.

**New pieces.** None; the guards exist (Combat rule 13).

## 3. The Quenched Blade (Thối Hỏa Nhận)

**Concept.** Heat a blade, plunge it in water: Fire arts set up, a Water strike cashes in. Each Burn stack on the
foe is extinguished by the strike for bonus damage.

**How it fights.** Burn piles up; a Water art consumes all Burn stacks on the target for a burst.

**Stacks.**
- **Linh căn:** Water and Fire.
- **Công pháp:** Dark Water Heaven Canon.
- **Đạo:** Yin (Âm Đạo).
- **Keystone:** Embers Feed the Hearth (New).
- **Effects:** Kindled Wound (exists).
- **Modifiers:** damage [fire]; damage [thuy].
- **Items:** Flying Sword; Fan.
- **Element stacks:** Fire debuff (spent), Water buff.

**Weakness.** A cleanse before the quench.

**New pieces.**
- **Quench (Thối)**, an Effect/action "consume your debuff stacks of one element on the target for a hit of X per
  stack". How to create: a new action "consume stacks" in the Effects System's action list (rule 6), priced by the
  stacks it removes.

## 4. The Steam Mirage (Chưng Ảo)

**Concept.** Heat over water makes mirages. An illusionist whose steam hides the true body: soul arts that wound
the mind, and evade that comes from a world that shimmers.

**How it fights.** Soul arts (Soul Wound delays the foe's next art) and evade from a steam ward; the foe's arts
land late and miss.

**Stacks.**
- **Linh căn:** Water and Fire.
- **Công pháp:** Dark Water Heaven Canon.
- **Đạo:** Illusion (Huyễn Đạo).
- **Keystone:** Concealed Breath (capability, exists).
- **Effects:** Soul Wound (exists), Beneath Notice (exists).
- **Modifiers:** `x_soul`; evade; thần thức.
- **Items:** Steam Veil (New ward).
- **Element stacks:** Water buff.

**Weakness.** High soul resistance; ticks (they never meet evade).

**New pieces.**
- **Steam Veil (Chưng Mạc)**, a ward: evade +15 pp, cast, cooldown 6 s, up 4 s. How to create: a ward record with
  an evade payload (Combat Defence & Healing rule 6), price-checked as a cast ward.

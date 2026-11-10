# Single root: Metal (Kim)

**What Metal brings.** Physical damage (Kim arts are Physical). Its buff stacks add +1 % Physical damage; its debuff
stacks make the foe take +1 % Physical damage. Craft role: refining success and mission income. A single root
cultivates fast early and slowly late, and it has the highest purity a life can roll, so a pure Metal root is the
sharpest Metal there is. Công pháp: Canh Kim Earth Scripture (Canh Kim Địa Quyết), Canh Kim Heaven Canon (Canh Kim
Thiên Kinh), and the body art Diamond Body (Kim Cang Thể).

**Metal's linh lực keystone (New, every Metal build):** **Edge Returns the Breath (Phong Hồi Khí)**: each crit
with a Physical hit restores about 0.5 % of maximum linh lực (the simulator says the Metal kit barely needs it;
`notes.md`). How to create: a keystone in the Metal land of the
Meridian Map; an Effect (trigger on crit) whose payload is `linh_luc_on_crit_pct`, closing cost "your
non-Physical hits cannot crit".

---

## 1. The Thousand Cuts (Thiên Trảm Kiếm)

**Concept.** A sword cultivator with three flying swords and no single big blow. Every small cut piles Metal
debuff on the foe, so the hundredth cut lands far harder than the first.

**How it fights.** Three quick sword arts (0.5–2 s cooldowns) fire all fight. Each hit adds Metal debuff stacks
for 6 s. By 15 s the foe takes +30–40 % Physical damage; crits refill linh lực through the keystone, so the
swords never stop.

**Stacks.**
- **Linh căn:** single Metal, high purity.
- **Công pháp:** Canh Kim Heaven Canon (sword arts; its tree, when side trees exist, should hold a "more swords
  in flight" node).
- **Đạo:** Sword (Kiếm Đạo), the flying-sword branch; keystone the Sword Đạo's signature.
- **Keystone:** Edge Returns the Breath (New). Called Blow (exists) makes crits reliable.
- **Effects:** Opening Cut (exists: Physical crits apply Bleed), Flowing Water (exists: crits shorten other
  timers), Echo (exists: a hit may strike again).
- **Modifiers:** damage scoped [sword]; crit chance; art speed [sword]; `linh_luc_on_crit_pct`;
  `stack_duration_pct` [kim, debuff].
- **Items:** three Flying Swords (Phi Kiếm); Golden Bell (per-hit ward) is wrong here, take the Common Ward.
- **Element stacks:** Metal debuff (main), Metal buff (minor).

**Weakness.** Flat block: many small hits each lose the block amount. A thể tu with Iron Shirt shrugs off the
swarm. Cleansing wards strip the debuff pile.

**New pieces.**
- **Sword Rain (Kiếm Vũ)**, an art (cooldown 0.5 s, cheap) that grants 1 Metal debuff stack per hit. How to create:
  an art record in Canh Kim Heaven Canon; it pays the stack charge in the art lint (Effects Formulas D).

## 2. Blood on the Whetstone (Huyết Ma Thạch)

**Concept.** Health is cheap and linh lực is life, so this cultivator pays for every art in blood and keeps the
whole pool for the ward. The ward never drops; the body slowly bleeds; the body heals itself on every Physical
blow.

**How it fights.** Arts cost health (Blood Casting plus `art_cost_health_pct`), so linh lực only pays the Common
Ward's drain. Iron Skin Renewed restores body shield on each Physical art. The fight is decided around 40–55 s,
when the foe's pool runs dry and this one's never did.

**Stacks.**
- **Linh căn:** single Metal (any purity; the build cares about the pool, not damage).
- **Công pháp:** Diamond Body (Kim Cang Thể) for health and block.
- **Đạo:** Refined Metal (Luyện Kim), the tempering branch (body shield, block).
- **Keystone:** Blood Casting (exists, as an enabler); Edge Returns the Breath (New) as backup income.
- **Effects:** Iron Skin Renewed (exists), Blood Drinker (exists: restore health from hits).
- **Modifiers:** `art_cost_health_pct` (new key, #44), `leech_health_pct` (new key, #44), maximum health, block,
  ward efficiency.
- **Items:** Armour (Giáp) of the body_gear kind; Common Ward; a health pill stack before the fight.
- **Element stacks:** Metal buff.

**Weakness.** Withering (healing taken −50 %) and Poison (passes the body shield) bleed it out before 60 s;
fatigue at 60 s punishes a long, low-health fight.

**New pieces.**
- **Whetstone Vow (Ma Thạch Thệ)**, keystone: "art costs paid in health are halved; you can never heal above 80 %
  health". How to create: Meridian Map keystone with a closing cost, payload `art_cost_health_pct`.

## 3. Hammer and Anvil (Chùy Châm)

**Concept.** A refiner who fights the way they forge: tap, tap, tap with cheap needles, then one great seal
falls on the softened metal.

**How it fights.** Two needle arts (0.5 s) apply Metal debuff stacks; one Seal (Ấn) art with a 12 s cooldown
waits until the foe holds 20+ Metal debuff stacks (a guard), then lands for its whole coefficient at +20 %
Physical taken and more.

**Stacks.**
- **Linh căn:** single Metal; the refining role lets this cultivator forge its own Needle and Seal at a higher
  grade.
- **Công pháp:** Canh Kim Earth Scripture.
- **Đạo:** Refined Metal (Luyện Kim), the forge branch.
- **Keystone:** Edge Returns the Breath (New).
- **Effects:** Measured Stroke (exists: long-cooldown arts cannot be evaded or crit; trade the crit for certainty).
- **Modifiers:** damage scoped [seal] and [slow]; `stack_effect_pct` [kim, debuff]; artifact power.
- **Items:** Needle (Châm) and Seal (Ấn) artifacts, both self-forged; Black Tortoise Shell (cast Physical ward).
- **Element stacks:** Metal debuff.

**Weakness.** A cleanse right before the seal falls wastes 12 s. Evasive foes dodge the seal (Measured Stroke
removes evade, so take it).

**New pieces.**
- **Anvil Guard (Châm Thủ)**, an art guard "fire when the target holds at least N of your debuff stacks". How
  to create: add `target stacks ≥ N` to Combat's fixed guard vocabulary (Combat rule 13).

## 4. Gold Rain (Kim Vũ)

**Concept.** Metal's craft role is mission income. This cultivator is rich, and pays for its arts in spirit stones
instead of linh lực, so its whole pool guards it while a rain of thrown coins does the fighting.

**How it fights.** Seal of Full Payment (exists: arts and wards paid in carried stones) for the coin arts; linh lực
stays full for the ward. A fight costs money, not breath.

**Stacks.**
- **Linh căn:** single Metal (mission income).
- **Công pháp:** Canh Kim Earth Scripture.
- **Đạo:** Refined Metal, the coin branch (New nodes: stone cost down).
- **Keystone:** Seal of Full Payment (exists; `npc: false`, so player only).
- **Effects:** Seal of Full Payment (exists).
- **Modifiers:** mission income; damage [physical].
- **Items:** a heavy purse of spirit stones; Coin (New artifact kind, thrown).
- **Element stacks:** Metal debuff.

**Weakness.** A poor season; a foe who drags the fight out until the purse is empty.

**New pieces.**
- **Coin (Tiền Tiêu)**, an artifact kind: thrown Physical, cheap, Metal-tagged. How to create: add a kind to
  `items_artifacts.json` (weapon role).

# Triple root: Earth, Metal and Water (Thổ, Kim, Thủy)

**What the root brings.** Two generating pairs (Earth → Metal → Water, +6 %); Earth with Water can converge into
Darkness. Physical resistance, Physical damage and debuff, and the mana buff. A defensive Physical root with a
deep pool.

---

## 1. The Bottomless Bell (Vô Để Chung)

**Concept.** A bell that rings for every blow it stops: Golden Bell (per hit) on a pool that Water keeps full and
Earth keeps safe, with Metal's ring answering each strike.

**How it fights.** Golden Bell's per-hit fee is cheap against slow heavy hitters; Water stacks pay the fees. A
New Effect: each per-hit fee paid rings back a small Physical hit.

**Stacks.**
- **Linh căn:** Earth, Metal, Water.
- **Công pháp:** Deep Earth Heaven Canon.
- **Đạo:** Refined Metal.
- **Keystone:** The Stone Remembers (Earth, New).
- **Effects:** Answering Bell (New).
- **Modifiers:** ward efficiency; maximum linh lực; block.
- **Items:** Golden Bell (ward); Bell (Chuông) artifact.
- **Element stacks:** Water buff, Earth buff.

**Weakness.** Many small hits (per-hit fees mount up); Chaos.

**New pieces.**
- **Answering Bell (Hồi Chung)**, an Effect: "when your per-hit ward pays a fee, the attacker takes a free Physical
  hit of c 0.3". How to create: trigger on the ward payment event (readable), action "free hit".

## 2. The Quicksilver Pool (Thủy Ngân Trì)

**Concept.** Liquid metal: arts that are cheap because the pool is deep, sword arts reshaped mid-fight between
quick and heavy forms.

**How it fights.** Two flying-sword arts share one artifact; a New Effect swaps a quick art for its heavy form when
linh lực is above 70 %.

**Stacks.**
- **Linh căn:** Earth, Metal, Water.
- **Công pháp:** Canh Kim Heaven Canon.
- **Đạo:** Sword.
- **Keystone:** The Spring Never Fails (Water, New).
- **Effects:** Steady Breath (exists).
- **Modifiers:** damage [sword]; maximum linh lực.
- **Items:** Flying Sword.
- **Element stacks:** Water buff, Metal debuff.

**Weakness.** Drain builds that keep it below 70 %.

**New pieces.**
- **Two Forms (Lưỡng Hình)**, an art-record field: an art with a second form used while a guard holds. How to
  create: Combat art record extension (two coefficient/cost/cooldown sets, one guard).

## 3. The Iron Reservoir (Thiết Hồ)

**Concept.** An aura cultivator: two reserved resistance auras, affordable on a deep Water pool, under a Metal
blade.

**How it fights.** Still Lake and Flame-Quelling Aura reserved; Water stacks refill the usable part; cheap sword
arts.

**Stacks.**
- **Linh căn:** Earth, Metal, Water.
- **Công pháp:** Dark Water Earth Scripture.
- **Đạo:** Mist.
- **Keystone:** The Spring Never Fails (New).
- **Effects:** Field Walls (exists).
- **Modifiers:** reservation efficiency; maximum linh lực.
- **Items:** Still Lake Aura, Flame-Quelling Aura.
- **Element stacks:** Water buff.

**Weakness.** Little left for arts; low damage.

**New pieces.** Reservoir (see `dual-earth-water.md`).

## 4. The Anchor (Thiết Mao)

**Concept.** The answer to cultivators who run. An iron anchor (Metal) sunk in the seabed (Earth, Water): once it
bites, no escape art succeeds.

**How it fights.** An anchor art locks pursuit (escape chance down), and Earth debuff blinds; a Water pool keeps the
lock up for the whole fight.

**Stacks.**
- **Linh căn:** Earth, Metal, Water.
- **Công pháp:** Canh Kim Earth Scripture.
- **Đạo:** Gravity (Trọng Lực Đạo).
- **Keystone:** The Spring Never Fails (Water, New).
- **Effects:** Anchor Chain (New).
- **Modifiers:** pursuit lock (escape lock penalty); damage [physical].
- **Items:** Anchor (New kind).
- **Element stacks:** Water buff, Earth debuff.

**Weakness.** A foe who never tries to run gains nothing from the lock.

**New pieces.**
- **Anchor Chain (Mao Liên)**, an Effect: "while your anchor art's lock holds, the target's escape chance is halved".
  How to create: Effect on Combat Formulas I's `escape_lock_penalty`.
- **Anchor (Mao)**, an artifact kind: a heavy lock tool. How to create: add a kind to `items_artifacts.json`.

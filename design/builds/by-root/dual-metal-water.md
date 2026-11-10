# Dual root: Metal and Water (Kim, Thủy)

**What the pair brings.** A generating pair (Metal bears Water, +3 %). Metal's Physical damage and debuff, Water's
mana buff. Water can transmute into Ice (Cold, the art-cost debuff). The drawn map's Metal–Water keystone is
"Frost on the Blade" (placeholder). Linh lực keystones: Edge Returns the Breath (Metal, New), The Spring Never
Fails (Water, New).

---

## 1. Dew on the Blade (Lộ Nhận)

**Concept.** A swordsman with a bottomless well. Water stacks deepen the pool every second, so three flying swords
fly all fight while the foe's ward starves.

**How it fights.** Sword arts fire as fast as their cooldowns allow; a cheap Water art every 2 s adds Water buff
stacks for the fight. By 30 s the pool is +30 % and regenerating fast; Metal debuff on the foe does the rest.

**Stacks.**
- **Linh căn:** Metal and Water.
- **Công pháp:** Canh Kim Heaven Canon.
- **Đạo:** Sword (Kiếm Đạo).
- **Keystone:** The Spring Never Fails (New).
- **Effects:** Steady Breath (exists), Flowing Water (exists).
- **Modifiers:** damage [sword]; `linh_luc_regen_pct`; `stack_effect_pct` [thuy, buff].
- **Items:** three Flying Swords; Common Ward.
- **Element stacks:** Water buff, Metal debuff.

**Weakness.** Block (many small hits); early burst before the pool is deep.

**New pieces.** None beyond the keystone.

## 2. Frost on the Blade (Sương Nhận)

**Concept.** Cold steel. Sword hits that carry frost raise the foe's art costs (Ice debuff, if the Water has turned
to Ice), so the enemy's pool drains while this one's fills.

**How it fights.** With an Ice variant: each sword hit adds an Ice debuff stack (+1 % art cost). By 30 s the foe's
arts cost +40 %; its pool runs dry first. Without Ice, use Rime Lock's cousin on Water hits.

**Stacks.**
- **Linh căn:** Metal and Water, ideally with Ice transmuted.
- **Công pháp:** Canh Kim Heaven Canon; an Ice sword art (New).
- **Đạo:** Sword, the cold-edge branch (New nodes).
- **Keystone:** Frost on the Blade (Sương Nhận, map placeholder): content New; Frost Tithe (Ice, New).
- **Effects:** Rime Lock (exists: 10 Ice stacks delay the foe's art).
- **Modifiers:** `convert_pct` Physical → Cold; damage [sword]; `stack_duration_pct` [bang, debuff].
- **Items:** Flying Sword of Cold affinity; Needle.
- **Element stacks:** Ice debuff, Metal debuff.

**Weakness.** Cleansing; a foe whose costs are already low (cheap kit) cares less.

**New pieces.**
- **Frost on the Blade content**: "your sword hits that deal Cold also grant 1 Ice debuff stack for 8 s". How to
  create: Meridian Map content pass on the drawn placeholder keystone.

## 3. The Tide Mercenary (Triều Dung Binh)

**Concept.** A hired blade paid in spirit stones (Metal's mission income), who keeps the pool deep and takes long
contracts.

**How it fights.** A balanced kit; the build's edge is economy: more missions, better gear, more pills. In fights
it is a typical swordsman with Water's endurance.

**Stacks.**
- **Linh căn:** Metal and Water.
- **Công pháp:** Canh Kim Earth Scripture.
- **Đạo:** Sword.
- **Keystone:** Edge Returns the Breath (New).
- **Effects:** First Move (exists: first art free).
- **Modifiers:** mission income; maximum linh lực; damage [sword].
- **Items:** a bought Thượng phẩm Flying Sword; Golden Bell.
- **Element stacks:** Water buff, Metal buff.

**Weakness.** Nothing special in a fight; it wins by being richer.

**New pieces.** None.

## 4. The Mind Blade (Tâm Kiếm)

**Concept.** A sword moved by thought alone. Thần thức drives the flying sword, so its soul arts strike the foe's
soul directly, and Water's calm keeps the mind clear.

**How it fights.** Soul arts (they meet only soul resistance and soul wards) with a sword theme; Soul Wound delays
the foe's next art on each soul hit. Water stacks keep the pool for the ward against ordinary blows.

**Stacks.**
- **Linh căn:** Metal and Water.
- **Công pháp:** Canh Kim Heaven Canon, with a soul sword art (New).
- **Đạo:** Soul (Hồn Đạo) with Sword.
- **Keystone:** Divided Divine Sense (capability, exists).
- **Effects:** Soul Wound (exists), Open Sky (exists).
- **Modifiers:** `x_soul`; thần thức; soul resistance.
- **Items:** Flying Sword; Soul-Guarding Lamp (ward).
- **Element stacks:** Water buff.

**Weakness.** A foe with high soul resistance or a soul shield; the soul lockout (one soul art a second).

**New pieces.**
- **Thought Sword (Ý Kiếm)**, a soul art with the sword form tag, so sword modifiers that allow it scale it. How
  to create: a soul art record in Canh Kim Heaven Canon (Combat E2) carrying [sword].

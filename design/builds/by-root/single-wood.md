# Single root: Wood (Mộc)

**What Wood brings.** Physical (thorns, roots) or Chaos (rot, poison) damage. Its buff stacks add health
regeneration; its debuff is **Poison**, Chaos ticks that pass every shield. Craft role: herb growth. Công pháp:
Green Wood Earth Scripture (Thanh Mộc Địa Quyết), Green Wood Heaven Canon (Thanh Mộc Thiên Kinh). Formation: Green
Wood Array (Thanh Mộc Trận).

**Wood's linh lực keystone (New, every Wood build):** **Root Drinks the Rot (Căn Ẩm Hủ)**: 1.8 % of the damage
you deal to a target bearing your Poison returns as linh lực (starting number, `notes.md`). How to create: Meridian Map keystone in the Wood land; an Effect
(reads the target's Wood debuff count) whose payload is `leech_linh_luc_pct` scoped to poisoned targets; closing cost "your leech is 0
against an unpoisoned target".

---

## 1. The Slow Garden (Hoãn Viên)

**Concept.** A herbalist who never hurries. Poison stacks in batches that last the whole fight; every second the
garden grows.

**How it fights.** Three cheap Wood arts each add 2 Poison stacks for 20 s. By 30 s the foe carries 30+ stacks,
ticking through every shield. Linh lực comes from leech on poisoned targets. The foe either cleanses or dies by
50 s.

**Stacks.**
- **Linh căn:** single Wood; high purity raises the Poison art's speed through the technique.
- **Công pháp:** Green Wood Heaven Canon (its arts are cheap Chaos poisons).
- **Đạo:** Poison (Độc Đạo), the slow-venom branch (stack duration).
- **Keystone:** Root Drinks the Rot (New).
- **Effects:** Spillover (exists: your ticks also burn linh lực, 25 % of their damage), Marked Prey (exists: more
  damage per distinct status; add Bleed from a needle for a second status).
- **Modifiers:** `stack_duration_pct` [moc, debuff]; damage scoped [over_time] and [poison]; art cost [poison];
  `leech_linh_luc_pct`.
- **Items:** Gourd (Hồ Lô) of venom; Clear Heart Ward (status resistance, so the foe's own poisons fail on you).
- **Element stacks:** Wood debuff (main), Wood buff (minor health regen).

**Weakness.** A cleansing ward at 0.5 a second halves the pile every pulse. Chaos resistance (rare) blunts it.

**New pieces.**
- **Twenty-Year Rot (Nhị Thập Niên Hủ)**, an art granting Poison batches "for the fight". How to create: an art in
  Green Wood Heaven Canon whose stack duration is "fight"; the lint charges it as 60 stack-seconds per stack.

## 2. The Evergreen Wall (Trường Thanh Bích)

**Concept.** Health is cheap, so Wood makes a lot of it. A healer-tank whose Wood buff stacks let health
regeneration outpace the foe, while Blood Casting turns that health into arts.

**How it fights.** A heal art (refunding its cost, #44) and Wood buff stacks keep health high; Blood Casting pays
for arts in health. Linh lực stays full for the ward. Wins by 60 s or by fatigue, since its regeneration keeps it
above the foe as fatigue grows.

**Stacks.**
- **Linh căn:** single Wood.
- **Công pháp:** Green Wood Earth Scripture.
- **Đạo:** Life (Sinh Đạo), the evergreen branch.
- **Keystone:** Blood Casting (exists); Root Drinks the Rot (New) if it adds a poison art.
- **Effects:** Gorged (exists: more damage per 1 % health restored this fight), Still Water (exists: overflow
  linh lực heals).
- **Modifiers:** `health_regen_pct`, `health_regen_inc_pct` (new key, #44), healing, `art_cost_health_pct`.
- **Items:** Green Wood Array (formation, prepared); Mountain Screen (reserved shield ward).
- **Element stacks:** Wood buff (main).

**Weakness.** Withering halves healing taken; a burst foe that kills before the regeneration matters.

**New pieces.**
- **Sap Rises (Nhựa Thăng)**, an Effect: "each Wood buff stack also adds +1 % healing". How to create: Effect with
  a per-count read, payload `healing_pct`.

## 3. The Strangler Fig (Giảo Dung)

**Concept.** Roots grip the foe: Physical thorn arts that root (delay) the enemy's arts while Poison works.

**How it fights.** A thorn art (Physical) with a delay payload pushes the foe's next art back 0.5 s on each hit;
the foe's rotation falls apart, so it spends less linh lực and deals less, while Poison ticks.

**Stacks.**
- **Linh căn:** single Wood.
- **Công pháp:** Green Wood Heaven Canon.
- **Đạo:** Life, the roots branch.
- **Keystone:** Root Drinks the Rot (New).
- **Effects:** Soul Wound's delay shape (exists, on soul hits); a Wood version is New.
- **Modifiers:** art speed [moc]; damage [physical]; `stack_effect_pct` [moc, debuff].
- **Items:** Flag (Kỳ) artifact as the root-binding focus.
- **Element stacks:** Wood debuff.

**Weakness.** Fast foes with many arts barely notice a 0.5 s delay; cleanse.

**New pieces.**
- **Gripping Root (Triền Căn)**, an Effect: "when your Physical Wood hit lands, the target's art with the least
  time left is delayed by 0.5 s, once per 2 s". How to create: copy Soul Wound's action (move the enemy's timer)
  onto a hit event scoped [moc, physical].

## 4. The Vine Garden (Đằng Viên)

**Concept.** A gardener whose plants fight for it: thorn vines and a man-eating flower, grown from seeds and set out
before the fight.

**How it fights.** Two plant companions (Wood-tagged) lay Poison and root the foe; the gardener heals them and keeps
its pool for the ward.

**Stacks.**
- **Linh căn:** single Wood (herb growth grows the plants).
- **Công pháp:** Green Wood Earth Scripture.
- **Đạo:** Life, the garden branch (New nodes: plant companions).
- **Keystone:** Ten Thousand Beasts, One Heart (capability, exists), read as "plants" too.
- **Effects:** Pack Hunt (exists), Bare Rack (exists).
- **Modifiers:** companion power share; herb growth.
- **Items:** Spirit Seed (New), planted before a foreseen fight.
- **Element stacks:** Wood debuff (from the plants).

**Weakness.** Blind fights (no time to plant); Fire.

**New pieces.**
- **Spirit Seed (Linh Chủng)**, an item: planted before a foreseen fight, it becomes a plant companion for that fight
  only. How to create: Item DB herb kind with a "companion for one fight" use; Herbs system grows it.

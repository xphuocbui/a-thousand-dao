# Dual root: Fire and Earth (Hỏa, Thổ)

**What the pair brings.** A generating pair (Fire makes Earth, +3 %). Fire damage and Burn; Earth's Physical
resistance buff and accuracy debuff. The natural parents of the **Lava Đạo (Dung Nham)**. Crafts: alchemy and
fields. Linh lực keystones: Embers Feed the Hearth (Fire, New), The Stone Remembers (Earth, New).

---

## 1. The Volcano (Hỏa Sơn)

**Concept.** A slow mountain that erupts. Heavy Earth-and-Fire seals every 8–12 s, each one leaving a Burn pool;
between eruptions the mountain just stands.

**How it fights.** Two slow Lava arts (Physical with part converted to Fire) each land a big hit and a long Burn
batch. Earth buff stacks keep it standing between eruptions.

**Stacks.**
- **Linh căn:** Fire and Earth.
- **Công pháp:** Deep Earth Heaven Canon with a Fire conversion; better, a Lava technique (New).
- **Đạo:** Lava (Dung Nham), the eruption branch.
- **Keystone:** Embers Feed the Hearth (New).
- **Effects:** Measured Stroke (exists); Kindled Wound (exists).
- **Modifiers:** `convert_pct` Physical → Fire; damage [slow]; `stack_duration_pct` [hoa, debuff].
- **Items:** Seal (Ấn) artifact; Mountain Screen.
- **Element stacks:** Fire debuff, Earth buff.

**Weakness.** Fast many-art builds that kill between eruptions; Fire resistance.

**New pieces.**
- **Molten Core Canon (Dung Tâm Kinh)**, a công pháp naming Fire and Earth whose arts convert 40 % Physical to Fire.
  How to create: `items_cong_phap.json` entry; the conversion is the art's own (first conversion step).

## 2. The Smoke Screen (Yên Mạc)

**Concept.** Ash in the air: Earth debuff blinds the foe while Burn chips away, and the cultivator stays hard to
hit.

**How it fights.** Ash arts apply both Earth debuff (−accuracy) and Burn. With evade 20 % and 20 Earth stacks on the
foe, a third of its hits miss.

**Stacks.**
- **Linh căn:** Fire and Earth.
- **Công pháp:** Crimson Flame Earth Scripture.
- **Đạo:** Lava, the ash branch (New nodes).
- **Keystone:** Beneath Notice (exists) and Iron Shirt's evade.
- **Effects:** Marked Prey (exists).
- **Modifiers:** evade; `stack_duration_pct` [tho, debuff]; damage [over_time].
- **Items:** Fan; Iron Shirt ward.
- **Element stacks:** Earth debuff, Fire debuff.

**Weakness.** Thunder foes (accuracy buff); soul attackers.

**New pieces.**
- **Ash Cloud (Hôi Vân)**, an art that grants both an Earth debuff and a Burn stack per hit. How to create: art
  record with two debuff grants; the lint charges both weights × 0.75.

## 3. The Kiln Fortress (Diêu Thành)

**Concept.** A formation master who fires clay: Earth formations made stronger by heat, and a body that grows
harder the hotter the fight.

**How it fights.** Mountain Guard Array prepared; Field Walls turns formation power into ward strength. Each Fire
art fired adds an Earth buff stack ("clay hardens in the kiln").

**Stacks.**
- **Linh căn:** Fire and Earth.
- **Công pháp:** Deep Earth Earth Scripture.
- **Đạo:** Array (Trận Đạo).
- **Keystone:** Earthen Kiln (Thổ Diêu), the Fire–Earth keystone drawn on the map (placeholder): use it for "Fire
  arts grant Earth buff stacks".
- **Effects:** Field Walls (exists).
- **Modifiers:** formation power; ward strength; `stack_grant` [tho, buff].
- **Items:** Mountain Guard Array; Flag (Kỳ).
- **Element stacks:** Earth buff.

**Weakness.** Blind fights; Silence on [formation].

**New pieces.**
- **Clay in the Kiln (Nê Nhập Diêu)**, keystone content for Earthen Kiln: "each Fire art you fire grants 1 Earth
  buff stack for 15 s; your Earth arts cost 25 % more". How to create: Meridian Map content pass.

## 4. The Salamander Keeper (Hỏa Tích Chủ)

**Concept.** A cultivator who raised a lava salamander from an egg. The beast fights; the keeper wards it, feeds it
Fire stacks, and keeps its own pool for the ward.

**How it fights.** Two cheap support arts and the basic attack; the salamander's hits (Fire, element-tagged) lay
Burn. Bare Rack makes the companion hit harder for every empty art slot, so the keeper slots little.

**Stacks.**
- **Linh căn:** Fire and Earth (the salamander needs both to hatch: an Earth nest, a Fire egg).
- **Công pháp:** Deep Earth Earth Scripture.
- **Đạo:** Lava, the beast branch (New nodes: companion share).
- **Keystone:** Beast Soul Union (exists, Effect keystone); Ten Thousand Beasts, One Heart (capability, exists).
- **Effects:** Pack Hunt (exists), Bare Rack (exists).
- **Modifiers:** companion power share; damage [companion].
- **Items:** a beast egg (New item kind); Mountain Screen.
- **Element stacks:** Fire debuff from the salamander (element-tagged companions, New).

**Weakness.** Kill the salamander and the keeper is half a cultivator.

**New pieces.**
- **Beast Egg (Thú Noãn)**, an item: hatches a companion of its element after N seasons of care at a matching root.
  How to create: Item DB treasure kind; Spirit Beasts system (creature records) for the hatchling.

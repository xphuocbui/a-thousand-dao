# Missing pieces

Every piece the builds in this folder use that does not exist yet, with how to create it. Compiled from the
**New pieces** sections and the linh lực keystone notes of each file (overnight 2026-11-09/10) by
`tools/design/build_catalogue/compile_missing.py` (rerun after editing a build). Nothing here is designed into a GDD; each is a proposal
for the library: modifiers, Effects, items, công pháp, Đạo, keystones.

Where a piece names a system rule, that system's owner would have to accept it. Effects are unpriced (Effects
rule 4); arts and items pass their own lints; keystones belong to the Meridian Map content pass, which waits on
the modifier library (user, 2026-11-09).

## Linh lực keystones, one per element or variant (user decision 2026-11-09)

| Piece | What it does and how to create it | Used by |
|---|---|---|
| **Breath Between Blows (Gian Tức)** | each art you fire restores 1.2 % of maximum linh lực (starting number, `notes.md` § 9). How to create: Meridian Map keystone in the Wind land; an Effect on the art-fired event, action "restore linh lực"; closing cost "your arts with an authored cooldown above 6 s cannot be slotted". | `variant-wind.md` |
| **Dawn Tithe (Bình Minh Thuế)** | "while the foe is Exposed, your hits restore linh lực". How to create: Meridian Map keystone on the Light island; reads statuses on the target. | `variant-light.md` |
| **Edge Returns the Breath (Phong Hồi Khí)** | each crit with a Physical hit restores 0.8 % of maximum linh lực (starting number, `notes.md` § 9). How to create: a keystone in the Metal land of the Meridian Map; an Effect (trigger on crit) whose payload is `linh_luc_on_crit_pct`, closing cost "your non-Physical hits cannot crit". | `single-metal.md` |
| **Embers Feed the Hearth (Tàn Hỏa Dưỡng Lô)** | each Burn tick you deal restores linh lực equal to 25 % of its damage (starting number, `notes.md` § 9). How to create: Meridian Map keystone in the Fire land; an Effect on the tick event, action "restore linh lực"; closing cost "your direct Fire hits deal 15 % less". | `single-fire.md` |
| **Frost Tithe (Sương Thuế)** | you gain 9 % of the extra cost your Ice stacks make the foe pay as linh lực (starting number, `notes.md` § 9). How to create: Meridian Map keystone in the Water land's Ice reach; an Effect on the foe's art-cost event (readable: the extra cost from your stacks), action "restore linh lực". | `variant-ice.md` |
| **Night Tithe (Dạ Thuế)** | "when you hit a foe that has not yet hit you, restore linh lực". How to create: Meridian Map keystone on the Darkness island; reads "hits taken this fight". | `variant-darkness.md` |
| **Primordial Breath (Hỗn Nguyên Khí)** | "you regenerate linh lực +0.1 pp for each element whose buff stacks you hold". How to create: Meridian Map keystone at the Chaos start; reads element stack counts. | `variant-chaos.md` |
| **Root Drinks the Rot (Căn Ẩm Hủ)** | 3.7 % of the damage you deal to a target bearing your Poison returns as linh lực (starting number, `notes.md` § 9). How to create: Meridian Map keystone in the Wood land; an Effect (reads the target's Wood debuff count) whose payload is `leech_linh_luc_pct` scoped to poisoned targets; closing cost "your leech is 0 against an unpoisoned target". | `single-wood.md` |
| **Storm Battery (Lôi Trì)** | every crit restores 1.9 % of maximum linh lực (starting number, `notes.md` § 9). How to create: Meridian Map keystone on the Thunder island; an Effect on the crit event (any type), payload `linh_luc_on_crit_pct`; closing cost "your non-crit hits deal 10 % less". | `variant-thunder.md` |
| **The Spring Never Fails (Tuyền Bất Kiệt)** | each Water stack you hold adds +0.025 pp linh lực regeneration, outside diminishing returns (fitted 2026-11-10, `notes.md` § 9). How to create: Meridian Map keystone in the Water land; an Effect reading your Water stack count, payload a flat regeneration share that Combat Formulas E adds after the diminishing-returns step; closing cost "your maximum linh lực from other sources is halved". | `single-water.md` |
| **The Stone Remembers (Thạch Ký)** | 0.9 % of the damage your block and resistance prevent returns as linh lực (starting number, `notes.md` § 9). How to create: Meridian Map keystone in the Earth land; an Effect on the "damage prevented" read (new readable: prevented points per hit), action "restore linh lực"; closing cost "your evade is 0". | `single-earth.md` |

## Keystone content for the Meridian Map

| Piece | What it does and how to create it | Used by |
|---|---|---|
| **Clay in the Kiln (Nê Nhập Diêu)** | keystone content for Earthen Kiln: "each Fire art you fire grants 1 Earth buff stack for 15 s; your Earth arts cost 25 % more". How to create: Meridian Map content pass. | `dual-fire-earth.md` (3. The Kiln Fortress) |
| **Five Elements Cycle content** | "your arts gain +2 % for each element whose buff stacks you hold". How to create: Meridian Map content pass for the centre keystone. | `five-elements.md` (1. The Wheel of Generation) |
| **Frost on the Blade content** | "your sword hits that deal Cold also grant 1 Ice debuff stack for 8 s". How to create: Meridian Map content pass on the drawn placeholder keystone. | `dual-metal-water.md` (2. Frost on the Blade) |
| **Mother Lode content (Mẫu Khoáng)** | "artifacts you refine roll one extra affix; your thần thức cost per artifact is +20 %". How to create: Meridian Map content pass, a passive on Artifact Refining. | `dual-earth-metal.md` (2. The Ore Vein) |
| **Whetstone Vow (Ma Thạch Thệ)** | keystone: "art costs paid in health are halved; you can never heal above 80 % health". How to create: Meridian Map keystone with a closing cost, payload `art_cost_health_pct`. | `single-metal.md` (2. Blood on the Whetstone) |

## Effects

| Piece | What it does and how to create it | Used by |
|---|---|---|
| **Ambush (Phục Kích)** | an Effect: "in a fight you opened by stealth, your arts start ready at t = 0". How to create: reads the fight situation (Event Engine's ambush tag); changes the start rule (Combat rule 10). | `variant-darkness.md` (1. The First Strike) |
| **Anchor Chain (Mao Liên)** | an Effect: "while your anchor art's lock holds, the target's escape chance is halved". How to create: Effect on Combat Formulas I's `escape_lock_penalty`. | `triple-earth-metal-water.md` (4. The Anchor) |
| **Answering Bell (Hồi Chung)** | an Effect: "when your per-hit ward pays a fee, the attacker takes a free Physical hit of c 0.3". How to create: trigger on the ward payment event (readable), action "free hit". | `triple-earth-metal-water.md` (1. The Bottomless Bell) |
| **Baked Shell (Nung Xác)** | an Effect: "when you fire a Fire art, your body shield regains 2 % of maximum health". How to create: copy Iron Skin Renewed with a [fire] scope. | `triple-fire-earth-water.md` (2. The Mud Golem) |
| **Brimming Cup (Mãn Bôi Quyết)** | an Effect: "your arts deal +2 % more for every 10 % of linh lực remaining". How to create: Effect reading own linh lực share (readable), payload L5 `damage_more`. | `single-water.md` (2. The Overflowing Cup) |
| **Cracking Root (Liệt Căn)** | an Effect: "your Poison deals +1 % more for every 2 pp of the target's Physical resistance". How to create: Effect reading the target's resistance (add "enemy resistance by type" to the readable list), payload L5 more scoped [poison]. | `dual-wood-earth.md` (1. Root Through Rock) |
| **Endurance (Nhẫn Nại)** | an Effect: "fatigue takes 20 % less from you". How to create: rule change on Combat's fatigue (rule 10); fatigue is meant to be unchangeable, so this needs the user's ruling first (rare, keystone tier). | `dual-metal-wood.md` (4. The Last One Standing) |
| **Eruption (Phún Trào)** | an Effect: "your hits deal +5 % more for each other art you fired in the same instant". How to create: Effect reading firings this instant (add to the readable list). | `triple-fire-earth-water.md` (3. The Geyser) |
| **Fuel for the Fire (Tân Hỏa)** | an Effect: "your Burn deals +3 % more for every 5 of your Poison stacks on the target". How to create: Effect reading element stack counts, payload L5 `damage_more` scoped [burn]. | `dual-wood-fire.md` (1. Wildfire) |
| **Generating Cycle (Tương Sinh Luân)** | an Effect: "your art of an element deals +2 % more for each stack of the element that generates it on the target or on you". How to create: Effect reading element stack counts, with a fixed generating table (Wood → Fire → Earth → Metal → Water → Wood). | `triple-wood-fire-earth.md` (1. The Turning Season) |
| **Gripping Root (Triền Căn)** | an Effect: "when your Physical Wood hit lands, the target's art with the least time left is delayed by 0.5 s, once per 2 s". How to create: copy Soul Wound's action (move the enemy's timer) onto a hit event scoped [moc, physical]. | `single-wood.md` (3. The Strangler Fig) |
| **Heat Through Iron (Nhiệt Xuyên Thiết)** | an Effect: "your Fire hits deal +1 % more per Metal debuff stack on the target". How to create: Effect reading stack counts, payload L5 scoped [fire]. | `triple-wood-fire-metal.md` (2. The Burning Forest Axeman) |
| **Lantern Burn (Đăng Thiêu)** | an Effect: "when you are hit, the attacker gains 1 Burn stack for 6 s, at most once a second". | `triple-water-wood-fire.md` (3. The Lantern Healer) |
| **Lightning Drinker (Ẩm Lôi)** | an Effect: "20 % of Lightning damage you take returns as linh lực". How to create: trigger on being hit by a Lightning part, action "restore linh lực". | `variant-thunder.md` (2. The Tribulation Rider) |
| **Overcoming Answer (Khắc Ứng)** | an Effect: "your arts of the element that overcomes the foe's main element deal +20 %". How to create: Effect reading the enemy's main root element (add to the readable list) and the fixed overcoming table. | `five-elements.md` (2. The Overcomer) |
| **Pruning Cut (Tiễn Chi)** | an Effect: "when your sword hit lands, remove 1 debuff stack from yourself, oldest first". How to create: trigger on hit, action "cleanse element stacks" (new action, #44). | `triple-earth-metal-wood.md` (2. The Bonsai Blade) |
| **Quench (Thối)** | an Effect/action "consume your debuff stacks of one element on the target for a hit of X per stack". How to create: a new action "consume stacks" in the Effects System's action list (rule 6), priced by the stacks it removes. | `dual-water-fire.md` (3. The Quenched Blade) |
| **Rain on Both (Vũ Lưỡng)** | an Effect for support play: "your heal arts also heal an ally companion". How to create: action "restore health" with a companion target; needs Combat's companion rules. | `dual-water-wood.md` (2. Spring Rain) |
| **Reservoir (Hồ Chứa)** | an Effect: "reservations are taken from your maximum before Water stacks, so Water stacks add only usable linh lực". How to create: a rule change on Combat Defence & Healing rule 10's order. | `dual-earth-water.md` (1. The Levee) |
| **Sap Rises (Nhựa Thăng)** | an Effect: "each Wood buff stack also adds +1 % healing". How to create: Effect with a per-count read, payload `healing_pct`. | `single-wood.md` (2. The Evergreen Wall) |
| **Smelt (Luyện)** | an Effect: "when you fire a Fire art, up to 5 of your Earth buff stacks become Metal buff stacks, keeping their timers". How to create: a new action "convert own stacks" in the Effects action list. | `triple-fire-earth-metal.md` (1. The Smelter) |
| **Spill Shield (Dật Thuẫn)** | an Effect: "overflow becomes a ward shield, up to 20 % of maximum linh lực". How to create: Effect on the overflow event (#44 readable), action "raise a ward shield". | `single-water.md` (2. The Overflowing Cup) |
| **Tempering (Tôi Luyện)** | an Effect: "a Water art fired within 2 s of your Fire art grants 2 Metal buff stacks for the fight". How to create: trigger on art fired, reading the last art's element and time. | `triple-metal-water-fire.md` (1. The Tempered Steel) |
| **Thorns (Kinh Thứ)** | an Effect: "when a hit reaches your health, the attacker takes 10 % of it back as Physical and gains 1 Poison stack". How to create: trigger on being hit, action "free hit" (Combat Formulas G) plus a debuff grant. | `dual-metal-wood.md` (2. The Thorn Armour) |
| **Turning Wheel (Xa Luân)** | an Effect: "each art of one element you fire lowers the next art of that element's cost by 2 %, stacking, reset when another element's art fires". How to create: Effect with a per-count read (firings this fight, a readable). | `triple-metal-water-wood.md` (3. The Waterwheel Mill) |
| **Unmake (Hủy Nguyên)** | an Effect action: "remove a share of the target's buff stacks". How to create: the cleanse action (#44) extended to buff stacks on a foe; rare, on Chaos only. | `variant-chaos.md` (3. The Unmaker) |

## Công pháp

| Piece | What it does and how to create it | Used by |
|---|---|---|
| **Boiling Sea Canon (Phí Hải Kinh)** | a công pháp naming Water and Fire. How to create: `items_cong_phap.json`. | `dual-water-fire.md` (1. The Steam Engine) |
| **Five Phases Canon (Ngũ Hành Kinh)** | a công pháp with one art per element. | `five-elements.md` (1. The Wheel of Generation) |
| **Four Seasons Canon (Tứ Quý Kinh)** | a công pháp naming four elements, with one art per element. How to create: `items_cong_phap.json`; its speed averages four purities, so it is slow for a weak element. | `quad-no-metal.md` (1. The Four Seasons Wheel) |
| **Green Flame Scripture (Thanh Diễm Quyết)** | a công pháp naming Wood and Fire. How to create: an `items_cong_phap.json` entry with both elements, speed scaled by the average purity. | `dual-wood-fire.md` (1. Wildfire) |
| **Molten Core Canon (Dung Tâm Kinh)** | a công pháp naming Fire and Earth whose arts convert 40 % Physical to Fire. How to create: `items_cong_phap.json` entry; the conversion is the art's own (first conversion step). | `dual-fire-earth.md` (1. The Volcano) |
| **Radiant Canon (Quang Minh Kinh)** | a Light công pháp. How to create: `items_cong_phap.json` naming the Light variant. | `variant-light.md` (1. The Sun Priest) |
| **Three Seasons Canon (Tam Thời Kinh)** | a công pháp naming three elements. | `triple-wood-fire-earth.md` (1. The Turning Season) |

## Arts

| Piece | What it does and how to create it | Used by |
|---|---|---|
| **Ash Cloud (Hôi Vân)** | an art that grants both an Earth debuff and a Burn stack per hit. How to create: art record with two debuff grants; the lint charges both weights × 0.75. | `dual-fire-earth.md` (2. The Smoke Screen) |
| **Earth Escape (Thổ Độn)** | an escape art that also leaves a Mire on the pursuer. How to create: escape art record (Combat Formulas I) with the Mire curse (New, this file) as a payload. | `dual-earth-water.md` (4. The Quicksand Runner) |
| **Gathering Tide (Tụ Triều)** | an art that grants 2 Water buff stacks "for the fight". How to create: art in Dark Water Heaven Canon; pays the stack charge (Water's buff weight is the highest, 2.2 % per stack-second, so its damage is small). | `single-water.md` (1. The Deep Sea) |
| **Incense Smoke (Hương Yên)** | a soul art that also lays 1 Earth debuff stack. How to create: soul art record with a debuff grant (Combat E2 plus Effects rule 9a). | `triple-wood-fire-earth.md` (3. The Incense Burner) |
| **Phoenix Mend (Phượng Dũ)** | a heal art that applies Burn on cast. How to create: art record with a heal payload and a debuff grant; the lint charges the stacks and the heal separately. | `single-fire.md` (3. The Phoenix Feather) |
| **Stagnant Water (Tử Thủy)** | an art: Water-tagged, Chaos damage, a small tick. How to create: art record in Dark Water Earth Scripture with a Chaos part (Combat Damage Types allows any type on an art). | `dual-earth-water.md` (3. The Hidden Spring) |
| **Sword Rain (Kiếm Vũ)** | an art (cooldown 0.5 s, cheap) that grants 1 Metal debuff stack per hit. How to create: an art record in Canh Kim Heaven Canon; it pays the stack charge in the art lint (Effects Formulas D). | `single-metal.md` (1. The Thousand Cuts) |
| **Thought Sword (Ý Kiếm)** | a soul art with the sword form tag, so sword modifiers that allow it scale it. How to create: a soul art record in Canh Kim Heaven Canon (Combat E2) carrying [sword]. | `dual-metal-water.md` (4. The Mind Blade) |
| **Thunderclap (Lôi Minh)** | an art with an action "delay every enemy art by 1 s". How to create: art record with the Effects action "move the enemy's timer" applied to all its arts; a strong control, so a long cooldown (12 s). | `variant-thunder.md` (3. The Thunderclap) |
| **Twenty-Year Rot (Nhị Thập Niên Hủ)** | an art granting Poison batches "for the fight". How to create: an art in Green Wood Heaven Canon whose stack duration is "fight"; the lint charges it as 60 stack-seconds per stack. | `single-wood.md` (1. The Slow Garden) |

## Items, wards and formations

| Piece | What it does and how to create it | Used by |
|---|---|---|
| **Anchor (Mao)** | an artifact kind: a heavy lock tool. How to create: add a kind to `items_artifacts.json`. | `triple-earth-metal-water.md` (4. The Anchor) |
| **Awakened Artifact (Linh Khí Thức Tỉnh)** | an artifact refined past Cực phẩm becomes a companion with its element tag. How to create: Artifact Refining rule plus a creature record generated from the artifact. | `dual-fire-metal.md` (4. The Living Sword) |
| **Axe (Phủ)** | an artifact kind: slow, heavy, Physical, a Bleed affix. How to create: add a kind to `items_artifacts.json` (weapon role). | `dual-metal-wood.md` (1. The Woodcutter) |
| **Beast Egg (Thú Noãn)** | an item: hatches a companion of its element after N seasons of care at a matching root. How to create: Item DB treasure kind; Spirit Beasts system (creature records) for the hatchling. | `dual-fire-earth.md` (4. The Salamander Keeper) |
| **Branding Iron (Lạc Thiết)** | an artifact kind: curse focus, raises curse duration. How to create: add a kind to `items_artifacts.json` (utility, curse role). | `triple-metal-water-fire.md` (4. The Executioner) |
| **Censer (Hương Lô)** | an artifact kind: holds an incense soul art; its thần thức cost is low. How to create: add a kind to `items_artifacts.json` (utility, soul role). | `triple-wood-fire-earth.md` (3. The Incense Burner) |
| **Clay Golem (Đào Ngẫu)** | a companion made, not tamed: an item that becomes a creature record when fired in a kiln. How to create: Artifact Refining recipe producing a creature (see Awakened Artifact, `dual-fire-metal.md`). | `triple-fire-earth-water.md` (4. The Potter's Golems) |
| **Coin (Tiền Tiêu)** | an artifact kind: thrown Physical, cheap, Metal-tagged. How to create: add a kind to `items_artifacts.json` (weapon role). | `single-metal.md` (4. Gold Rain) |
| **Disciple aura** | an array that shares its owner's ward strength with allies in a mass battle. How to create: a formation field read by Combat Formulas K's force rating (mass battle). | `quad-no-metal.md` (4. The Sect Guardian) |
| **Drum (Cổ)** | an artifact kind: rhythm focus, +crit chance for arts fired on a steady interval. How to create: add a kind to `items_artifacts.json` (utility role). | `variant-thunder.md` (4. The Thunder Drum) |
| **Element arrays granting stacks** | a formation field "grants 1 buff stack of its element to its owner each pulse". How to create: `crafting_formations.json` field; Effects rule 9a source kind "formation". | `quad-no-metal.md` (2. The Living Landscape) |
| **Five-Phase Flag (Ngũ Hành Kỳ)** | an artifact kind: a flag with five element slots; each filled slot adds +5 % damage to arts of that element. How to create: add a kind to `items_artifacts.json` (utility role); refined with one material of each element. | `five-elements.md` (1. The Wheel of Generation) |
| **Hot Spring Array (Ôn Tuyền Trận)** | a formation: "+X pp linh lực and health regeneration for its owner on its ground". How to create: `crafting_formations.json` entry; laid with Earth, Fire and Water materials. | `triple-fire-earth-water.md` (1. The Hot Spring) |
| **Lantern (Đăng)** | an artifact kind: utility, holds a reactive Effect. How to create: add a kind to `items_artifacts.json` (utility role). | `triple-water-wood-fire.md` (3. The Lantern Healer) |
| **Lightning Rod (Lôi Trượng)** | an artifact kind (utility, holds the Effect). Note: an overnight build sheet (`overnight-2026-11-07/sheets/drink-the-lightning.md`) explored a similar idea. | `variant-thunder.md` (2. The Tribulation Rider) |
| **Mid-Fight Pill (Lâm Trận Đan)** | a pill kind usable once in a fight, as a guarded art slot. How to create: an Item DB pill category that occupies an art slot with a guard (Combat rule 13). | `single-fire.md` (2. The Furnace Master) |
| **Mirror (Kính)** | an artifact kind: utility, raises status chance for Light statuses. How to create: add a kind to `items_artifacts.json`. | `variant-combos.md` (6. The Eclipse) |
| **Mirror Ward (Kính Quang Hộ)** | a ward: "all resistance 0.40; 20 % of damage it prevents strikes back as Light". How to create: a ward record with a new "reflect" payload; price-checked with the reflect counted as value. | `variant-light.md` (2. The Mirror Ward) |
| **Soul Jade (Hồn Ngọc)** | an item that holds the legacy. How to create: Item DB treasure, never tradable. | `variant-chaos.md` (4. The Reincarnator) |
| **Spirit Seed (Linh Chủng)** | an item: planted before a foreseen fight, it becomes a plant companion for that fight only. How to create: Item DB herb kind with a "companion for one fight" use; Herbs system grows it. | `single-wood.md` (4. The Vine Garden) |
| **Spirit Tea (Linh Trà)** | a consumable: "at t = 0, grant N buff stacks of each element it was brewed with, for the fight". How to create: an Item DB pill-like consumable with a stack-grant payload; brewed by Alchemy from herbs. | `triple-water-wood-fire.md` (2. The Tea Master) |
| **Star Chart (Tinh Đồ)** | an item: once a year, shows the next event's hidden branches. How to create: an Item DB treasure with an Event Engine read, a weaker relative of Reading Heaven's Secrets. | `variant-light.md` (4. The Star Reader) |
| **Steam Veil (Chưng Mạc)** | a ward: evade +15 pp, cast, cooldown 6 s, up 4 s. How to create: a ward record with an evade payload (Combat Defence & Healing rule 6), price-checked as a cast ward. | `dual-water-fire.md` (4. The Steam Mirage) |
| **Stone Forest Array (Thạch Lâm Trận)** | a formation: "the owner gains evade; each pulse every foe on the ground gains 1 Earth debuff stack for 5 s". How to create: `crafting_formations.json` entry with a stack-grant field (see "Element arrays granting stacks"). | `dual-wood-earth.md` (4. The Stone Forest Maze) |
| **Zither (Cầm)** | an artifact kind for music soul arts. How to create: add a kind to `items_artifacts.json` with a [music] form tag (a new form tag in the Modifier System's vocabulary). | `triple-metal-water-wood.md` (4. The Zither Player) |

## Đạo

| Piece | What it does and how to create it | Used by |
|---|---|---|
| **Cold Pill Đạo (Hàn Đan Đạo)** | Ice-and-Water alchemy (preserving pills, toxicity). How to create: a `dao.json` entry requiring Ice. | `variant-ice.md` (3. The Ice Physician) |
| **Dust Đạo (Trần Đạo)** | theme stats evade, accuracy-down duration; keystone "missed hits against you grant a Earth debuff stack". How to create: a new `dao.json` entry, requirement Earth purity 40. | `single-earth.md` (2. The Dust Veil) |
| **Talisman Đạo (Phù Đạo)** | theme stats talisman power, keep chance, drawing speed; keystone "talismans you drew yourself carry your element stacks". How to create: a `dao.json` entry requiring Wood or Fire at 40. | `dual-wood-fire.md` (4. The Paper Arsonist) |

## Modifiers

| Piece | What it does and how to create it | Used by |
|---|---|---|
| **Universal stack duration** | `stack_duration_pct` without an element scope (broad). How to create: a scope row in the General Catalogue (price × 1.25 breadth). | `quad-no-metal.md` (1. The Four Seasons Wheel) |
| **Universal stack effect** | `stack_effect_pct` without an element scope (broad). | `five-elements.md` (3. The Primordial Sage) |

## Rules, readables and record fields

| Piece | What it does and how to create it | Used by |
|---|---|---|
| **Anvil Guard (Châm Thủ)** | an art guard "fire when the target holds at least N of your debuff stacks". How to create: add `target stacks ≥ N` to Combat's fixed guard vocabulary (Combat rule 13). | `single-metal.md` (3. Hammer and Anvil) |
| **Breach (Phá Trận)** | a curse: "the target's strongest standing ward is Down for 3 pulses". How to create: a curse row in the Effects status catalogue (a ward lock, like Sealed Meridian's layer lock), with a reapply lockout. | `triple-fire-earth-metal.md` (4. The Siege Engineer) |
| **Deep Freeze (Thâm Đống)** | Rime Lock at every 10 stacks, not only the first. How to create: change Rime Lock's limit from "once per 4 pulses" to "each 10 stacks, once per 4 pulses". | `variant-ice.md` (2. The Frost Lock) |
| **Element weakness (optional rule)** | the user ruled no element cycle in damage (Combat Damage Types rule 2), so this lives only in Effects, never in resistance. | `five-elements.md` (2. The Overcomer) |
| **Element-tagged companions** | a companion's hits carry its own element tag and grant that element's stacks. How to create: a field on creature records (`creatures_linh_thu.json`), read by Effects rule 9a. | `triple-fire-earth-metal.md` (3. The Artisan General) |
| **Guardian companion** | a companion whose Effect raises a shield on its keeper instead of attacking. How to create: a creature record field "guardian" plus an Effect "raise a ward shield on your keeper each N s". | `dual-water-wood.md` (4. The Turtle and the Snake) |
| **Legacy (Di Sản)** | a Reincarnation Đạo keystone: "when this life ends, the next life you play starts with one Đạo glimpse already open". How to create: a meta rule across lives (Meta Achievements system), owned by the user's game-concept decisions; it touches Pillar 4's one-life weight, so it needs a ruling. | `variant-chaos.md` (4. The Reincarnator) |
| **Mire (Lầy)** | a curse: "the target's art speed −20 % for 3 pulses". How to create: a curse row in the Effects status catalogue (rule changed: art speed), with a curse cap like Heavy Breath's. | `dual-earth-water.md` (2. The Mudslide) |
| **Prevented damage (readable)** | the points a hit lost to resistance and block, as an event. How to create: add to the Effects System's readable list (rule 5). | `single-earth.md` (1. The Mountain That Pays) |
| **Rain (Vũ)** | a ground tag and Effect: "under rain, Water and Wood stack batches last 50 % longer, and each pulse every non-Water foe gains 1 Earth debuff stack". How to create: a ground tag in Combat rule 12's preparation list, read by an Effect. | `triple-water-wood-earth.md` (4. The Rain Caller) |
| **Scouting report** | before a foreseen fight, the foe's main element and ward kinds are shown. How to create: an Event Engine field on a foreseen combat request, shown by the Guidance Layer. | `quad-no-wood.md` (4. The Treasure Pavilion) |
| **Seclusion scope [secluded]** | already exists as a tag family in the Modifier System; a "cultivation speed while secluded" row should be authored with it. | `variant-ice.md` (4. The Winter Sleep) |
| **Shadow Self (Ảnh Thân)** | a companion summoned by reserving linh lực: its power share scales with the reserved share. How to create: a reserved-ward-like record that creates a companion (Combat Defence & Healing rule 10 plus creature records). | `variant-darkness.md` (4. The Shadow Puppeteer) |
| **Shrapnel Talisman (Toái Thiết Phù)** | a talisman: a Fire-and-Physical burst that lays Burn and Metal debuff. How to create: `crafting_talismans.json` entry, drawn with Fire ink on iron-dust paper. | `triple-wood-fire-metal.md` (4. The Firework Maker) |
| **Two Forms (Lưỡng Hình)** | an art-record field: an art with a second form used while a guard holds. How to create: Combat art record extension (two coefficient/cost/cooldown sets, one guard). | `triple-earth-metal-water.md` (2. The Quicksilver Pool) |

Total: 104 pieces.

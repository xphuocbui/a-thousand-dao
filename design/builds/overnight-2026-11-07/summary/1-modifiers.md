# 1. New Modifiers

Everything the overnight builds add that stacks: special modifiers, keystones, and the plain tree rows. Proposals only, not in game data. Sizes are first guesses. Generated from `pieces/` by a script.

## Words used below

- **Points (+12 points):** added to one of the five damage layers L1 to L5, which multiply together. L1 is ordinary increased damage; L2 to L5 are rarer and stronger.
- **c_art:** an art's damage multiplier. **cost:** its linh lực price, as a share of your maximum pool. **s:** its cooldown in seconds.
- **Pulse:** the once-a-second beat of a fight, when ticks and wards are paid.
- **Ward:** the linh lực shield. A **drain** ward pays per damage blocked, a **per-hit** ward a fixed fee per hit, a **per-pulse** ward a fixed fee per second.
- **Tick:** damage over time: burns, poisons, bleeds.
- **Art lint:** the rule that caps an art's damage for its cost and cooldown.
- **Foreseen fight:** one you prepare for, as opposed to a blind ambush.
- **Fit:** Fits today = works with the game as it is. Needs key = needs a new data field. Needs rule = needs a new combat or system rule.

## Special modifiers (192)

The signature pieces. Grouped by what they make stronger.

### Arts (your skills) (57)

| Modifier | What it does | Layer | Build |
|---|---|---|---|
| **Banked Heat** (Uẩn Nhiệt) | +30 points to hits carrying two or more element tags. | L2 | Kept Hearth |
| **Bare Rack** (Không Giá) | +15 points per empty art slot, on arts. | L2 | Fortieth Breath |
| **Borrowed Name** (Mạo Danh) | While the enemy is Unnamed, your art hits gain 75 % of the L2 it lost. | L2 | Struck Name |
| **Both Hands** (Song Thủ) | While heart demon stands above 50 as a pulse begins, the pool pays two arts that pulse. | none | Already-Waited, Welcome Bath |
| **Bulk Order** (Phê Lượng) | +25 points to an art per full share of its cost. | L2 | Full Price |
| **Carried Tags** (Kiêm Tính) | +15 points to a hit per element tag on it. | L2 | Kept Hearth |
| **Cold Graft** (Hàn Tiếp) | Below purity 40, each art naming the graft costs 0.1 % of maximum health per point under 40. | none | Transplant |
| **Cook's Hand** (Trù Thủ) | +4 points per alchemy level on hits with the furnace form. | L2 | Wedding Furnace |
| **Copied Art Damage** (Sao Pháp Thương) | +20 to arts with the copied tag. | L1 | Brush Fee |
| **Cue** (Nhập Tràng) | A guard: true in an instant when a hit landed on the double. The art fires in the follow-up instant. | none | Understudy |
| **Cut Short** (Đoản Án) | +1 heart demon after the fight per whole second art speed removed from the art's reading. | none | Fortieth Breath |
| **Dark Ink** (Nùng Mặc) | +50 points from Way of Ink art nodes on copied arts. | L2 | Brush Fee |
| **Deep Bund** (Thâm Đê) | L4 points past the cap add +0.01 each to formation arts' coefficient. | none | Level Ground |
| **Deep Reading** (Tế Độc) | rho_min is 0.15 for your Rubbings. | none | Brush Fee |
| **Down to the Skin** (Thoát Y) | With no layer left, a wash takes 40 ward strength and efficiency, and you keep your share. | none | Welcome Bath |
| **Exact Change** (Trảo Tiền) | Overkill on a winning hit refunds that share of its price, up to half. | none | Full Price |
| **Fever** (Độc Nhiệt) | +1.5 art_speed_pct per point of đan độc at compile. | none | Taster's Fever |
| **Final Clause** (Mạt Khoản) | Once a fight, if you would go Down, your longest-cooldown art fires in that instant with what it holds. | none | Fortieth Breath |
| **Fine Needling** (Tinh Châm) | +20 points to arts with the needle form. | L2 | Great Tonic |
| **Fine Work** (Tinh Công) | Coatings you brewed gain 20 % per point of quality, 0 to 3. | L4 | Wedding Furnace |
| **First Taste** (Sơ Vị) | +50 points to art hits while the target's linh lực is above 60 %. | L5 | Not-Yet-Full |
| **Five Courses** (Ngũ Vị Tịch) | Each firing serves the next loaded course, which keeps every earlier coating; a course the last did not generate resets the total to 0. | L4 | Wedding Furnace |
| **Foreign Edge** (Dị Phong) | +0.5 L2 points per purity point on arts naming the graft. | L2 | Transplant |
| **Forgotten Face** (Vô Diện) | +2 per point of presence under 45, up to +60. | L2 | Struck Name |
| **Full Title** (Toàn Hiệu) | +40 points to arts with the sword form. | L2 | Loud Sword |
| **Head of Water** (Thủy Đầu) | An art may pay everything above a keep line it names; its coefficient is the art lint's value for what it paid. | none | Deepest Well |
| **Kept Rubbing** (Tàng Bản) | A Rubbing keeps its last copy between fights and fires it on a 3 s timer at your own cost until it copies something new. | none | Brush Fee |
| **Long Rope** (Trường Sách) | +40 points to arts with the rope form. | L2 | Deepest Well |
| **Long Way Round** (Viễn Lộ) | +0.2 to a part's coefficient per conversion it went through. | none | Kept Hearth |
| **Measured Stroke** (Định Trảm) | Arts with an authored cooldown of 20 s or more cannot be evaded and cannot crit. | none | Fortieth Breath |
| **Old Bund** (Cựu Đê) | +0.05 to the coefficient of arts with the formation source tag per 10 years the formation has stood, to +1.0. | none | Level Ground |
| **One Ring** (Nhất Hoàn) | A bonus to any one element's damage also applies to the other four. | L1 | Kept Hearth |
| **Overcoming Stroke** (Khắc Kích) | +60 points to a hit carrying the element that overcomes the target's. | L5 | Kept Hearth |
| **Paid in the Ground** (Địa Thường) | One art's timer runs while you are buried, never below cooldown_min, and the seconds paid are reported. | none | Thirteenth Summer |
| **Patronage** (Bảo Trợ) | When the enemy cannot afford a ready art, you pay its cost, while your pool is above that cost. | none | Brush Fee |
| **Practised Stroke** (Thuần Bút) | +8 points per firing of the original this fight, to +64. | L2 | Brush Fee |
| **Priced Above the Sea** (Giá Siêu Hải) | A stone-paid art may have cost_share above 1, and the art lint applies unchanged. | none | Full Price |
| **Reed Song** (Lô Ca) | +60 points to arts with the song form. | L2 | Herd-Child |
| **Rich Seam** (Phú Mạch) | +0.5 points to arts per 1 % the target's maximum linh lực exceeds yours, up to +60. | L2 | Deepest Well |
| **Ring Step** (Hoàn Bộ) | Up to 100 % of an art hit converts to the next element on the generating cycle, twice. Each part keeps every earlier tag. | none | Kept Hearth |
| **Ring's Weakest** (Hoàn Nhược) | +1.5 points to arts per point of your lowest owned element's purity. | L2 | Kept Hearth |
| **Rush Order** (Cản Đơn) | +50 % price: the art's first firing comes at half its effective cooldown. | none | Full Price |
| **Set Table** (Thiết Tịch) | Foreseen fights: you read the enemy's element at t = 0, and +30 points to arts. | L4 | Kept Hearth |
| **Shown Face** (Lộ Diện) | +2 per point of presence above 45, up to +60. | L2 | Loud Sword |
| **Signed and Dated** (Lạc Khoản Niên) | +1 L2 on the Signature per point of Blank painted. | L2 | Empty River |
| **Sized Paper** (Phàn Chỉ) | +30 points to copied and talisman hits, from treated paper prepared before the fight. | L4 | Brush Fee |
| **Standing Water** (Tích Thủy) | A formation's timer runs from the day it was laid: its arts first fire at the first pulse. | none | Level Ground |
| **The Blank** (Lưu Bạch) | Ink arts are paid in paper at 100 points per share of cost, never in linh lực, and it does not return in a fight. | none | Empty River |
| **The Root Pays** (Căn Phó) | The root pays its purity share of an art's cost, out of purity, at 2 purity per full share of cost. | none | Transplant |
| **Thrift** (Tiết Dụng) | A quarter of your ward efficiency also counts as art_cost_pct, inside its 50 % limit. | none | Long Carry |
| **Title Deed** (Địa Khế) | While a formation you hold title to stands, your arts with an authored cooldown of 6 s or more count as carrying the formation source tag. Sold with the formation. | none | Forum Build |
| **Turned Hand** (Phản Thủ) | A curse: a bearer's hit art still pays and lands on its owner at half strength, through their own ward, at most 25 % of their maximum health. The basic attack is not touched. | none | Stand-In |
| **Unwritten Margin** (Bạch Biên) | +12 for each tag family a hit lacks; +72 on a bare hit. | L2 | Struck Name |
| **Usurious Ink** (Cao Lợi Mặc) | When a fee is charged at double, curse: +50 % art cost for 2 pulses. | none | Brush Fee |
| **Virulence** (Bệnh Thế) | +40 points to arts per curse on you, or per curse an art held as it fired. | L2 | Stand-In |
| **Washing** (Tẩy) | An art with the wash tag zeroes the target's largest of L2 to L5 for the fight, and you add 50 % of it to the same layer. L1 never washes. | L2-L5 | Welcome Bath |
| **Whetstone Water** (Ma Thạch Thủy) | +40 points to Sword arts, a coating applied in preparation. | L4 | Fortieth Breath |

### Arts and basic attacks (16)

| Modifier | What it does | Layer | Build |
|---|---|---|---|
| **Bluer Than the Plant** (Thanh Ư Lam) | At 100 % colour their basic attack turns too. | none | Indigo Drop |
| **Encore** (Tái Diễn) | +10 points per hit evaded this fight, to +100. | L2 | Understudy |
| **Given Years** (Tặng Niên) | +2 points per 1 % of your realm's lifespan given away, while the person named lives, in any fight. Two grades: this one on art and basic; The Herd-Child holds a companion grade, +1.5 per 1 % on L2, to +45. One size would change fights. | L4 | Given Years |
| **Gorged** (Bão Lôi) | +1 point to arts and basic attacks per 1 % of maximum health restored this fight, to +100. | L2 | Drink the Lightning |
| **Hollow Palm** (Không Chưởng) | 50 % of a basic attack becomes qi, keeping its body tags. | none | Receiving Hand |
| **Iron-Sand Hand Bath** (Thiết Sa Dục Thủ) | +25 points to body hits, prepared before the fight. | L4 | Receiving Hand |
| **Longer Breath** (Trường Tức) | +50 points to hits while your linh lực share is more than 10 points above the enemy's. Two grades: a lead of 10 here, a lead of 0 in The Deepest Well; one lead would change fights. | L5 | Long Carry |
| **Nothing to Lose** (Vô Sở Thất) | +10 points for each doubling of the enemy's years left over your own, to +100. | L5 | Given Years |
| **Over the Line** (Quá Tuyến) | At load 30 or more, +28 points on hits, and 4 % of maximum health lost at each pulse past ward and guard. | L5 | Pill Glutton |
| **Refused Force** (Cự Lực) | +15 points to hits per health floor held this fight. | L2 | Turned-Away |
| **Reopened** (Tái Liệt) | +0.6 points to hits per 1 % of health missing. | L5 | Turned-Away |
| **Returned Force** (Hoàn Lực) | A caught art adds half its c_art to your next basic attack's coefficient. | none | Receiving Hand |
| **Short Wick** (Đoản Đăng) | +5 points for each season of lifespan under 40. | L2 | Given Years |
| **Still Warm** (Dư Ôn) | For 4 seasons after a knockout, you hold the victim's largest tag-keyed L2 modifier. | L2 | Not-Yet-Full |
| **Ten Thousand Strikes** (Vạn Kích) | +0.1 to the basic attack's coefficient per power of ten of basic attacks landed this life, up to +0.7. | none | Receiving Hand |
| **Varied Diet** (Tạp Thực) | +3 points to hits per different main technique eaten, to +60. | L2 | Not-Yet-Full |

### Ticks: burns, poisons, bleeds (11)

| Modifier | What it does | Layer | Build |
|---|---|---|---|
| **Bitter Measure** (Khổ Lượng) | +1.5 points per đan độc on the poison tag. | L2 | Taster's Fever |
| **Boiled Over** (Phí Dật) | Each L4 point the cap clips on a course adds 0.01 c_tick to a body tick, Scald, for 3 pulses. | none | Wedding Furnace |
| **Held Acres** (Tích Điền) | +7 points on over-time statuses per spirit field plot you work (n_plots, 1 to 12). | L2 | Corner |
| **Kept Grudge** (Tàng Hận) | +1 point on over-time tags per point of heart demon. | L2 | Thousand Scales |
| **Nothing Leaves** (Bất Xuất) | While the ward stands, your statuses on the enemy lose no duration and the enemy does not regenerate. If it cannot be paid it falls for the fight and those statuses end. | none | Held Door |
| **Parting Cut** (Biệt Đao) | When you go Down, your statuses run out before the result is final; you do nothing and the winner may cleanse. | none | Thousand Scales |
| **Rich Soil** (Phì Thổ) | +2 points to both tick caps while the target's linh lực is 50 % or more. | none | Good Year |
| **Surplus** (Dư Thu) | Tick damage the caps clip comes home as linh lực at half its amount, at most 5 % of maximum a pulse. | none | Good Year |
| **Thin Bleed** (Tế Huyết) | On hit, apply a wound named for the piece that carries it: c_tick 0.2, 4 pulses, stacks to 5. Wounds from different pieces are different statuses. Held four times here: Bleed, Brine, Gall and Sinew. | none | Thousand Scales |
| **Unspent Rage** (Dư Nộ) | After a fight in which dot_pulse_cap clipped, +1 heart demon. | none | Thousand Scales |
| **Widening Wound** (Khoát Thương) | Half of what dot_pulse_cap clips at a pulse adds to that cap on this target for the rest of the fight, never past distinct statuses x dot_pool_cap. | none | Thousand Scales |

### Companions (6)

| Modifier | What it does | Layer | Build |
|---|---|---|---|
| **Carried Note** (Đới Âm) | Tag modifiers on an art you fired this instant also apply to your companion's hit in that instant. | L2 | Herd-Child |
| **Cornered** (Khốn Đấu) | +50 points while your health share is below the enemy's. | L5 | Already-Waited |
| **Fights as Itself** (Tự Chiến) | A companion hits with its own realm's fight unit, stage and suppression gap, not its owner's. c_comp_cap and the owner's M stay. | none | Herd-Child |
| **Full Trough** (Mãn Tào) | +20 points to companion hits per doubling of the year's feed above what is due, to +40. A blind fight keeps it. | L4 | Herd-Child |
| **In Step** (Đồng Bộ) | +50 points to a hit landing after one of your arts in the same instant. | L5 | Herd-Child |
| **Stands Over You** (Hộ Chủ) | When you go Down, your companion stays on its own health and guard with no ward, and the fight goes on until it falls. Needs loyalty 60 or more. | none | Herd-Child |

### Soul attacks (5)

| Modifier | What it does | Layer | Build |
|---|---|---|---|
| **Light Hand** (Khinh Thủ) | +2 than_thuc_pct per point of heart demon under 30. | none | Cut Line |
| **Numb Soul** (Ma Hồn) | +8 soul_res_pct per Gate Scar. | none | Turned-Away |
| **Running Line** (Phóng Tuyến) | The share soul_cap clips shortens the lockout to soul_lockout x soul_cap / raw share, at least 0.1 s. | none | Cut Line |
| **Slackened Soul** (Tùng Hồn) | A curse: the defender's thần thức reads 25 % lower against your soul arts for 2 pulses, stacking to 50 %. | none | Cut Line |
| **Unseen Hand** (Ám Thủ) | +60 x_soul while at full health. | none | Cut Line |

### Flying artifacts (7)

| Modifier | What it does | Layer | Build |
|---|---|---|---|
| **Drilled Ranks** (Thao Binh) | +50 to hits with the artifact source tag. | L2 | Remnant Host |
| **Flown artifact damage** | Increased damage on hits with the artifact source tag. | L1 | Remnant Host |
| **Idle Hands** (Nhàn Thủ) | +10 to hits with the artifact source tag per empty art slot. | L2 | Remnant Host |
| **Overheat** (Quá Nhiệt) | Art speed that cooldown_min clips becomes L5 points, 1 for 1, up to +30. | L5 | Taster's Fever |
| **Spare Mind** (Dư Thần) | +3 % flight speed per 1 % of thần thức left free. | none | Remnant Host |
| **Standard Planted** (Thụ Kỳ) | A ky strike applies a curse: ward pass +30 % for 3 pulses. | none | Remnant Host |
| **Whetstone Ash** (Ma Thạch Hôi) | +60 to hits with the artifact source tag, prepared before the fight. | L4 | Remnant Host |

### Draining linh lực (3)

| Modifier | What it does | Layer | Build |
|---|---|---|---|
| **Requisition** (Trưng Thu) | Linh lực burn counts as drain a ward asked for: whatever reads drain also reads your burn. | none | Corner |
| **Scraping the Well** (Quát Tỉnh) | When a drain ward's pool cannot pay what a hit asks, the unpaid linh lực lands on health, past body guard. | none | Deepest Well |
| **Sweet Ward** (Cam Hộ) | A curse may strengthen a ward: pass_raise -0.4, so it blocks more and pays for it. | none | Deepest Well |

### Rupture: overfilling the enemy (4)

| Modifier | What it does | Layer | Build |
|---|---|---|---|
| **Deep Abscess** (Thâm Ung) | Surfeit the cap clips adds to the next Lancing, up to +15 % of health. | none | Great Tonic |
| **Pill-Fed** (Đan Dưỡng) | +1 % return per point of the attacker's pill toxicity, up to +30 %. | none | Great Tonic |
| **Self-Cure** (Tự Y) | When a target ruptures, regain 10 % of maximum health. | none | Great Tonic |
| **Strong Decoction** (Nùng Thang) | +0.3 to the share a ward returns. | none | Great Tonic |

### Turning the enemy's arts on them (2)

| Modifier | What it does | Layer | Build |
|---|---|---|---|
| **Measure Taken** (Lượng Thủ) | An art that has turned never turns twice in that fight. Its owner has corrected their aim. | none | Mortal |
| **The Name Arrives First** (Danh Tiên Chí) | An enemy your tally frightens (5, 20, 50, 200, 1,000 for Qi Refining to Deity) carries an exit that stays shut until a blow of theirs falls on a mask, then opens at once. | none | Heir |

### Defence, healing and taking hits (14)

| Modifier | What it does | Layer | Build |
|---|---|---|---|
| **Already Read** (Dĩ Duyệt) | A hit from an art that has fired before this fight is cut by half your comprehension lead, as a percentage, to 30 %. | none | Clever Harm |
| **Ancestor's Face** (Tổ Diện) | One mask per dead head. Each fight, each stops one hit sized 8 % of your health or more, whole, with nothing drained. | none | Heir |
| **Broad Back** (Khoan Bối) | Each 1.0 of c_comp the cap clips moves 10 % of each hit on your health to the beast, to 40 %, against its guard. Overkill is not moved. If its wounds reach its health it dies. | none | Herd-Child |
| **Callus Returns** (Kiển Hoàn) | After 80 seasons have gone from a wick, +1 body guard base for the fight. | none | Mortal |
| **Dress Rehearsal** (Diễn Tập) | In a foreseen fight the Curtain starts at 2. | none | Understudy |
| **Every Blow** (Mỗi Kích) | +0.3 heart demon per 1 % of maximum health lost to a hit, kept after the fight. | none | Already-Waited |
| **Joy of the Work** (Lạc Nghiệp) | Health you restore to the other side counts 3 times as health you restored, for anything that reads it. | none | House Call |
| **Mordant** (Môi Nhiễm) | A cleanse leaves half of the colour. | none | Indigo Drop |
| **Paid in Seasons** (Quý Thường) | Health you lose is restored at the defeat check and burns 1 season per 20 % of maximum health. At 0 seasons you are Down, having acted in that instant. | none | Given Years |
| **Plain Blow** (Phàm Kích) | A single hit on a side with no linh lực at all removes at most 8 health before body guard. Ticks and soul are not limited. | none | Mortal |
| **Seen Through** (Thức Phá) | An attacker whose accuracy reaches your evade sees through the double: the Curtain neither fills nor pays for them. | none | Understudy |
| **Skipped Bill** (Đào Trái) | On a Fled result the ledger is not paid in years. It is written in the Creditors' Book against the one who dealt it. | none | Best Plan |
| **Slow Wound** (Hoãn Thương) | Hit damage past ward and guard enters a ledger. The ledger pays at most dot_pool_cap of maximum health a pulse, after ticks, on its own cap. | none | Incense Vigil |
| **Still Sea** (Tĩnh Hải) | The Slow Wound cap falls by 0.55 x your linh lực share. | none | Incense Vigil |

### Escape (5)

| Modifier | What it does | Layer | Build |
|---|---|---|---|
| **Beneath Notice** (Bất Túc Đạo) | Against a pursuer above you, the escape realm term is +0.05 a realm, not -0.10. | none | Best Plan |
| **Cold Feet** (Hàn Túc) | Escape arts first fire at cooldown_min. | none | Best Plan |
| **Folded Corner** (Chiết Giác) | The first failed roll of a fight puts its talisman back in stock. | none | Best Plan |
| **Full Sleeve** (Mãn Tụ) | +0.02 escape bonus per doubling of talismans carried above 4, read at the start of a fight. | none | Best Plan |
| **Terror** (Kinh Hồn) | +0.15 escape bonus while the ledger exceeds your health. | none | Best Plan |

### Mass battles (6)

| Modifier | What it does | Layer | Build |
|---|---|---|---|
| **Census** (Hộ Bạ) | Mortals may be counted in a force as levy rows. | none | Ant General |
| **Field Array** (Dã Trận) | The leader's formation adds its L4 to every member of the force. | L4 | Ant General |
| **Given to the Ranks** (Phó Liệt) | Half your L1 leaves you and counts as L4 for every member of your force. | L4 | Ant General |
| **Rotating Ranks** (Luân Xạ) | +0.10 to mass_reserve_weight for your force. | none | Ant General |
| **Spear Drill** (Thao Thương) | A levy's basic coefficient is 1.3. | none | Ant General |
| **Stamped Iron** (Ấn Thiết) | +40 for mass-made arms that cost no thần thức and a mortal can use. | L3 | Ant General |

### Any damage, or a general rule (56)

| Modifier | What it does | Layer | Build |
|---|---|---|---|
| **All Eyes** (Chúng Mục) | Per point of presence above 45: +0.4 crit_chance_pct, +1 crit_damage_pct, +0.5 evade_pct, inside Combat's caps. | none | Loud Sword |
| **Between Courses** (Gián Thiện) | After a knockout of a cultivator, restore 25 % of missing health and 50 % of missing linh lực. | none | Not-Yet-Full |
| **Bitter Pearl** (Khổ Châu) | Each 10 toxicity the clamp at 100 clips adds a grain for life, to 20. A grain counts as 1 đan độc for Per modifiers. | none | Taster's Fever |
| **Bored Shaft** (Toản Tỉnh) | Foreseen fights: +25 points to all hits and +0.10 to Water Table, from a shaft sunk at the place of the fight. | L4 | Deepest Well |
| **Called Blow** (Báo Chiêu) | Your crit and evade take no draw: chance adds to a count on each hit, and the hit that fills it to 1 crits or is slipped, and the count falls by 1. | none | Loud Sword |
| **Catching Hand** (Tiếp Thủ) | Each empty art slot catches one enemy art hit per fight: the art fires and pays, and its hit deals nothing and drains nothing. | none | Receiving Hand |
| **Child Steals the Mother** (Tử Đạo Mẫu Khí) | A hit whose element generates your ward's phase is Fed: pass_tag -0.25, the ward pays nothing, and you gain half of what it blocked. | none | Kept Hearth |
| **Clean Hands** (Tịnh Thủ) | +0.5 % starting colour per empty art slot. | none | Indigo Drop |
| **Clean Kill** (Nhất Khẩu) | A knockout of a cultivator adds 0.10 x their realm's power base x (0.25 + 0.75 x the health share they had when the last instant began). | none | Not-Yet-Full |
| **Collected Debt** (Thu Trái) | On a knockout, take 10 % of the loser's carried stones. | none | Full Price |
| **Collector's Seal** (Tàng Ấn) | Each seal takes Blank and adds points to one layer for every hit inside. | L2, L4 | Empty River |
| **Cracked Perfection** (Liệt Viên Mãn) | +0.05 to stage_mult on damage per Gate Scar, past great perfection. | none | Turned-Away |
| **Deep Mud** (Thâm Nê) | A Ground Law: cooldown_min is 3 s on this ground, for both sides. | none | Level Ground |
| **Dies Later** (Hậu Tử) | When a creditor dies by any hand but yours, the entry is void, heart demon falls by 3, and you claim 1 % of their carried stones per 100 % owed, to 25 %. | none | Best Plan |
| **Dry Season** (Hạn Quý) | A Ground Law: regen_base is 0 on this ground, for both sides. | none | Level Ground |
| **Dull Fortune** (Ngu Phúc) | +1 khi_van per point of comprehension under 50, to +40. | none | Lucky Fool |
| **Dull Hand** (Độn Thủ) | attack_pct -0.5 per purity point of the root. | L1 | Worst Root |
| **Eaten Power** (Thực Lực) | In a fight, your power term is your realm's power base plus what you have eaten. Realm, suppression and slots do not change. | none | Not-Yet-Full |
| **Even Streams** (Phân Lưu) | An art hit or basic attack splits into one equal part per base element held, each with that tag. | none | Worst Root |
| **Fair Measure** (Công Lượng) | 25 % fewer years owed. | none | Incense Vigil |
| **Field Walls** (Điền Thành) | While your formation stands, formation_power_pct also counts as ward strength and efficiency. | none | Level Ground |
| **Full House** (Mãn Tọa) | On ground with the stage tag: +30 points, and the Curtain holds 4. | L4 | Understudy |
| **Grave Goods** (Tùy Táng) | At a handover, half of Eaten Power goes into the ground with the head. With a life eating E, handover power closes on E. | none | Heir |
| **Held at Table** (Lưu Khách) | A single hit of yours for 20 % of the target's maximum health or more breaks an open escape channel. Cost, cooldown and stock stay spent. | none | Not-Yet-Full |
| **Inured Flesh** (Quán Độc) | +0.3 status_resist_pct per đan độc. | none | Taster's Fever |
| **Known Gate** (Thức Quan) | +5 pierce per Gate Scar. | none | Turned-Away |
| **Known Ground** (Thục Địa) | +25 points per ground tag at a place where you have lived a full cycle of seasons. | L4 | Level Ground |
| **Landing Ground** (Độ Khẩu Địa) | +40 points on a place where you owe seasons. A ground tag, so a blind fight keeps it. | L4 | Already-Waited |
| **Level Ground** (Bình Địa) | A Ground Law: on this ground L2, L3 and L5 count at most 40, 40 and 10, for both sides. | none | Level Ground |
| **Lien** (Thế Chấp) | Each living entry in your Book reserves 5 % of maximum linh lực, to 30 %. | none | Heir |
| **Lit Wick** (Tàn Đăng) | Each pulse of a fight burns a season, whether or not you are struck. | none | Given Years |
| **Losing Face** (Thất Diện) | Presence reads 1.5 lower per 1 % of maximum health missing, for the fight. | none | Loud Sword |
| **Open Sky** (Không Thiên) | Each 1 % of thần thức left free adds 0.6 ward strength. | none | Cut Line |
| **Purse Weight** (Trọng Nang) | +30 points per doubling of carried stones above the realm's linh_thach_max, read at the start of a fight, within the L3 cap. | L3 | Full Price |
| **Raw Scar** (Tân Ngân) | +30 points to hits for 4 seasons after a failed great breakthrough, in any situation, even a blind fight. | L4 | Turned-Away |
| **Rehearsal** (Diễn Tập) | Foreseen fights only, a prepared item: you choose where both counts of Called Blow start. | none | Loud Sword |
| **Relapse** (Tái Phát) | Each affliction that comes home refunds 2 % of maximum linh lực. | none | Stand-In |
| **Short Stick** (Đoản Hương) | Foreseen fights only: time_limit falls by half. | none | Incense Vigil |
| **Someone Else's Problem** (Giá Họa) | On a knockout win, the loser pays your Years Owed. | none | Lucky Fool |
| **Spoiled Palate** (Yếm Thực) | Pills do nothing for you and seclusion adds no cultivation base. Only defeats fill the bar. | none | Not-Yet-Full |
| **Still Water** (Tĩnh Thủy) | Regeneration clipped by a full pool restores health, at half its amount. | none | Fortieth Breath |
| **Taken Ground** (Chiếm Địa) | A ground holds one formation: the other side's L4 counts at most 20. | L4 | Level Ground |
| **The Answer** (Hoàn Chiêu) | +0.5 to the crit count for each hit slipped. | none | Loud Sword |
| **The Clear Line** (Thanh Tuyến) | Clean purity is purity -4 per stain: each artifact, pill in effect, art naming another element, or second Way. | none | Indigo Drop |
| **The Credit** (Đầu Bài) | A knockout won with the Curtain up is credited to the role: it feeds no tally of cultivators defeated, and the world records the double. | none | Understudy |
| **The Owed Wait** (Trái Đãi) | One season at the landing owed per heart demon spent. Each season paid returns 1 heart demon with decay off; each left unpaid costs 1 Dao heart. | none | Already-Waited |
| **Towel Only** (Đơn Cân) | Your own L2 to L5 count for nothing. | L2-L5 | Welcome Bath |
| **Turned Away** (Bế Môn) | At the defeat check, a side at 0 health with an unopened Gate Scar and 15 % of maximum linh lực pays it, opens one scar and stands at 5 % health. One per instant. | none | Turned-Away |
| **Turned Blade** (Đảo Phong) | With no hit to deal, half your L1 and L3 points add to body_guard_pct. | none | Incense Vigil |
| **Unfelt** (Bất Giác) | A part under the line, before the ward, skips the ward. At or over it, the ward works as usual. | none | Worst Root |
| **Unnamed** (Vô Danh Ấn) | A curse: the enemy's hits count as having no element or form tags, so their L2 stops for 2 pulses. It carries no tag, so no cleanse matches it. | none | Struck Name |
| **Untended Field** (Hoang Điền) | Leave the ground for 5 years, or miss upkeep, and Old Bund resets to 0. | none | Level Ground |
| **What They Had Left** (Dư Niên) | A cultivator you kill and plough in adds the years they had left to one plot. | none | Good Year |
| **When the Worst Has Passed** (Bĩ Cực) | Each roll against you that fails adds its chance to a visible count. At 1.0 the next one lands and the count returns to 0. | none | Lucky Fool |
| **Years Owed** (Thọ Trái) | At the fight's end each 100 % of maximum health left in the ledger costs 1 % of the realm's base lifespan. | none | Incense Vigil |
| **Years at Table** (Thọ Yến) | A knockout adds 5 % of the victim's years left to your lifespan, up to 3 x the realm's. | none | Not-Yet-Full |

## Keystones (10)

Big trade-offs: a strong rule with a real cost.

| Keystone | What it does | Build |
|---|---|---|
| **Along the Thread** (Duyên Tuyến) | On your soul arts, thần thức the defender has bound to artifacts counts at half. You may equip nothing that costs thần thức. Each kill by a soul art adds +3 heart demon. | Cut Line |
| **Brush Fee** (Nhuận Bút) | The cost of a copied art is charged to the original's caster, who pays what they have. | Brush Fee |
| **Far Distance** (Viễn Cảnh) | An art with the ink tag makes the target smaller by 1 % per point of ink, to 20 %. Size scales fight unit, health and linh lực. Way of Space. | Empty River |
| **One Drop** (Nhất Tích) | Your first hit leaves 1 % colour. Each pulse colour x (1 + (clean purity - their highest purity) / 50 x spread). That share of their art hits resolves on them, and that share of their ward stops neither you nor them. | Indigo Drop |
| **Slip of the Hand** (Thất Thủ) | Every art that would hit, on either side, first rolls 0.05 + (other's fortune - caster's fortune) x 0.001. A slip resolves on its caster, through their own ward, at most 30 % of their maximum health. Closes your own hitting arts. | Lucky Fool |
| **Struck Name** (Tước Danh) | Capability on a sealed cluster. Art records may carry no tags: a bare hit meets any ward on default pass and drain. Closes crit, all tag-keyed modifiers, talismans and escape. Presence −20 for life. | Struck Name |
| **Ten Thousand Names** (Vạn Danh) | Đạo keystone. A bare hit counts as carrying every tag for your own modifiers and none for the enemy's. | Struck Name |
| **The Set Day** (Định Nhật) | Once a life, name a kin and a day at most ten years off. Your age jumps to that distance from your cap, theirs falls by half the years given, never below 16. Your cap can never rise again. | Given Years |
| **Turning Phase** (Chuyển Hành) | When an art carrying an element reaches you, your ward's phase becomes what it generates, from your next hit on, and your Ring Steps start there, so they end at its overcomer. | Kept Hearth |
| **Withheld Hand** (Thu Thủ) | Your basic attack does not fire. Each time it would, +1.0 c_art to your longest-cooldown art until that art fires. | Fortieth Breath |

## Plain tree rows (210)

The ordinary acupoints and notables that stack on the Meridian Map. A row used by several builds appears once. Small = acupoint, Notable = the bigger version.

| Row | Small | Notable | Builds |
|---|---|---|---|
| **Accuracy** | +0.5 % accuracy_pct. | +3 % accuracy_pct. | Daily Lesson, Grindstone Road |
| **Armour defence** (Giáp Hậu) | +1.5 % defence on armour. | +10 % artifact_defense_pct. | Grindstone Road, Long Firing, Rice Pestle |
| **Art cost** (Tiết Khí) | -0.5 % art cost. Catalogue row, art_cost_pct. | -3 % art cost. Catalogue row, art_cost_pct. | Seven Lamps |
| **Art damage** (Pháp Thương) | +1.5 % to art hits. | +10 % to art hits. | Rice Pestle, Seven Lamps |
| **Art speed** (Tấn Pháp) | +0.5 % art_speed_pct. | +3 % art_speed_pct. | Seven Lamps |
| **Artifact power** (Khí Uy) | +0.9 % artifact power. Catalogue row, artifact_power_pct. |  | Grindstone Road |
| **Artifact thần thức cost** (Khinh Khí) | -0.8 % thần thức cost of artifacts. | -5 % than_thuc_cost_pct. Not run. | Grindstone Road, Third Look |
| **Basic attack damage** (Bình Kích) | +2 % to the basic attack. | +12 % to the basic attack. | Rice Pestle, Second Sickness, Third Look |
| **Basic attack speed** (Tốc Kích) | +1 % basic attack speed. Not run: basic_cooldown is one constant in the calculator. | +6 % basic attack speed. Not run. | Rice Pestle |
| **Beast damage** (Thú Hình) | +2 % to hits with the beast form. | +12 % to hits with the beast form. | Guide Hound |
| **Behind the Ward** (Hộ Hậu) | +2 points to companion hits while your linh lực is above 25 %. | +12 points to companion hits while your linh lực is above 25 %. | Guide Hound |
| **Between Breaths** (Tức Gian) |  | +6 % curse art speed. | One Long Word |
| **Blood Stroke** (Huyết Kích) | +2 points to arts paid in health. | +12 points to arts paid in health. | Rice Pestle |
| **Body damage** (Thể Thương) | +1.5 % to body hits. | +10 % to body hits. | Long Firing, One Ladle, Rice Pestle |
| **Body guard** (Hộ Thể) | +1.2 % body_guard_pct. | +8 % body_guard_pct. | Long Firing, Rice Pestle, Second Sickness, Seven Lamps |
| **Body guard against qi hits** (Nội Giáp) | +2 % body guard against qi hits. | +12 % body guard against qi hits. | Long Firing, Rice Pestle |
| **Bright Blood** (Xích Huyết) | +2 points to hits while over the line. | +12 points to hits while over the line. | Pill Glutton |
| **Bright Steel** (Minh Cương) |  | +12 % Metal damage. | Grindstone Road |
| **Burn damage** (Thiêu Khí) | +2.5 small, +15 notable, on qi burn statuses. |  | Second Sickness |
| **Burnt Hands** (Thục Thủ) |  | +12 % ward strength against Fire. | Fierce Fire Road |
| **Catching Flame** (Dẫn Hỏa) |  | +6 % status chance. | Fierce Fire Road |
| **Catching Thorn** (Câu Thích) |  | +6 % status chance. | Evergreen Road |
| **Clear Head** (Thanh Tỉnh) | +2.5 x_soul while your linh lực is at 30 % or above. | +15 x_soul while your linh lực is at 30 % or above. | Third Look |
| **Cold Dew** (Hàn Lộ) |  | +0.6 % of maximum linh lực regained on a crit. Metal generates Water. | Grindstone Road |
| **Cold Edge** (Hàn Phong) | +2 points to Water arts of the body kind. | +12 points to Water arts of the body kind. | One Ladle |
| **Companion attack speed** (Thú Tốc) | +1.5 % companion speed. Catalogue row, stops at cooldown_min. | +10 % companion speed. Catalogue row, stops at cooldown_min. | Guide Hound |
| **Companion damage** (Thú Thương) | +2 % companion damage. | +12 % companion damage. | Guide Hound |
| **Complication** (Biến Chứng) |  | +12 points on an over-time status applied to a target already carrying another. Read at application, so slot order matters. | Second Sickness |
| **Cracked Stone** (Liệt Thạch) |  | +12 % Wood damage against an enemy whose ward carries Earth. Wood overcomes Earth. | Evergreen Road |
| **Crit chance** (Bạo Suất) | +0.4 % crit chance. Catalogue row, crit_chance_pct. |  | Grindstone Road |
| **Crit chance on body hits** (Thể Bạo Suất) | +0.8 % crit chance on body hits. The Sword row with its tag swapped. | +5 % crit chance on body hits. The Sword row with its tag swapped. | Rice Pestle |
| **Crit chance with Fire** (Hỏa Bạo Suất) | +0.8 % crit chance on Fire hits. The Sword row with its tag swapped. |  | Fierce Fire Road |
| **Crit chance with swords** | +0.8 % crit chance on sword hits. | +5 % crit chance on sword hits. | Daily Lesson |
| **Crit chance with Water** (Hàn Mang) | +0.8 % crit chance on Water hits. The catalogue sword row on another tag. | +5 % crit chance on Water hits. The catalogue sword row on another tag. | One Ladle |
| **Crit damage** | +1.5 % crit_damage_pct. | +10 % crit_damage_pct. | Daily Lesson, One Ladle, Rice Pestle |
| **Crowded Sky** (Mãn Thiên) |  | +3 art damage per curse on the target. | One Long Word |
| **Curse duration on you** (Đoản Chú) | -2 % curse duration on you. Not run. | -12 % curse duration on you. Not run. | Rice Pestle |
| **Damage** (Công Lực) | +1.2 % attack_pct. | +8 % attack_pct. | Third Look |
| **Damage over time** (Trì Thương) | +2 % tick damage. |  | Fierce Fire Road, Second Sickness |
| **Damage to an enemy with no linh lực** | +2.5 % while the enemy has no linh lực. | +15 % while the enemy has no linh lực. | Daily Lesson, Guide Hound, Second Sickness, Seven Lamps, Third Look |
| **Damage while above 50 % health** (Toàn Thân) | +2 % while your health is above 50 %. | +12 % while your health is above 50 %. | Guide Hound, Long Firing |
| **Damage while below 50 % health** (Sạt Lở) | +2 % while your health is below 50 %. | +12 % while your health is below 50 %. | Long Firing, Rice Pestle |
| **Deep Bite** (Thâm Thực) |  | +10 % crit damage. | Grindstone Road |
| **Deep Breath** (Thâm Tức) | +0.3 points to arts per 1 % regeneration you own. Read at compile. The any-art grade of Spring Head and Sap Rise, at a smaller size because it is wider. | +2 points to arts per 1 % regeneration you own. Read at compile. The any-art grade of Spring Head and Sap Rise, at a smaller size because it is wider. | Seven Lamps |
| **Deep Coals** (Thâm Than) |  | +12 points to Fire over-time statuses. | Fierce Fire Road |
| **Deep Drink** (Thâm Ẩm) |  | +1 % of maximum per second. | Evergreen Road |
| **Deep Perspective** (Thâm Viễn) |  | +0.1 % smaller per point of ink. | Empty River |
| **Deep Thorn** (Thâm Thích) |  | +12 points to Wood over-time statuses. | Evergreen Road |
| **Dry Wood** (Can Sài) |  | -6 % cost of Fire arts. | Fierce Fire Road |
| **Earth art cost** (Tiết Thổ) | -1 % cost on arts with the Earth tag. Catalogue row, any one tag. | -6 % cost on arts with the Earth tag. Catalogue row, any one tag. | Long Firing |
| **Earth damage** (Thổ Thương) | +2 % to hits with the Earth tag. | +12 % to hits with the Earth tag. | Long Firing |
| **Empty Room** (Không Thất) | +0.5 x_soul per empty art slot. | +3 x_soul per empty art slot. | Third Look |
| **Empty Stomach** (Không Phúc) |  | +20 % potency on the first pill of a preparation. | Pill Glutton |
| **Evade** (Thiểm Tị) | +0.4 % evade_pct. Not run. | +2.5 % evade_pct. Not run. | Rice Pestle |
| **Failing Lamp** (Tàn Đăng) | +0.02 x_soul per 1 % of the enemy's linh lực missing. | +0.12 x_soul per 1 % of the enemy's linh lực missing. | Third Look |
| **Feed cost** (Tiết Liệu) | -2 % stones on the year's feed. Outside the fight. It makes Full Trough cheaper. | -12 % stones on the year's feed. Outside the fight. It makes Full Trough cheaper. | Guide Hound |
| **Felling Stroke** (Phạt Mộc) |  | +12 % Metal damage against an enemy whose ward carries Wood. Metal overcomes Wood. | Grindstone Road |
| **Field plots** (Điền Số) | +1 field_plots. The key exists, and the tree gives none today. |  | Good Year |
| **Fine Point** (Tiêm Điểm) | +2 % soul_pct on soul arts. A multiplier of its own, outside x_soul. | +12 % soul_pct on soul arts. | Third Look |
| **Fire art cost** (Hỏa Pháp Phí) | -1 % cost of Fire arts. |  | Fierce Fire Road |
| **Fire art speed** (Hỏa Pháp Tốc) | +1 % speed on Fire arts. Catalogue row, any one tag. |  | Fierce Fire Road |
| **Fire damage** (Hỏa Thương) | +2 % Fire damage. |  | Fierce Fire Road |
| **Fired Clay** (Đào Thể) | +0.1 points to Earth arts per 1 % of body guard you own. Read at compile. | +0.6 points to Earth arts per 1 % of body guard you own. Read at compile. | Long Firing |
| **First firing comes sooner** | First firing 2 % sooner. Not in any fight file. | First firing 12 % sooner. Not in any fight file. | Daily Lesson, Seven Lamps |
| **Flying sword attack** | +2 % to the attack of each equipped phi_kiem, so it grows with the swords carried. | +12 % to the attack of each equipped phi_kiem. | Daily Lesson |
| **Follow Through** (Thuận Thế) | +0.02 points per 1 % of the enemy's health missing, to sword arts, so +2 at most. | +0.12 points per 1 % of the enemy's health missing, to sword arts, so +12 at most. | Daily Lesson |
| **Full Bellows** (Mãn Bễ) |  | +12 points to Fire arts with a cooldown of 2.5 s or more. | Fierce Fire Road |
| **Full Trunk** (Mãn Thân) |  | +8 % maximum linh lực. | Evergreen Road |
| **Full Weight** (Toàn Trọng) |  | +12 % curse strength, inside Combat's curse bounds. | One Long Word |
| **Good Fit** (Vừa Người) |  | +10 % of washed points kept. | Welcome Bath |
| **Good Paper** (Thượng Chỉ) | +1 % to the chance a used talisman is not consumed, to 60 % at most. Notable +6 %. |  | Spring Hand |
| **Good Steel** (Hảo Cương) |  | +10 % attack on weapon-role artifacts. | Grindstone Road |
| **Grateful Patients** (Cảm Ân) |  | +1 point per 5 living people you have fought and left alive, to +20. | House Call |
| **Green Heart** (Thanh Tâm) |  | +12 % Wood damage. | Evergreen Road |
| **Green Wall** (Thanh Bích) |  | +12 % ward strength against Metal. Metal overcomes Wood. | Evergreen Road |
| **Grown Together** (Đồng Trưởng) | +1.5 points to hits from a beast of your own realm or higher. | +10 points to hits from a beast of your own realm or higher. | Guide Hound |
| **Hair's Breadth** (Phân Hào) |  | +5 % crit chance with Metal. The Sword row with its tag swapped. | Grindstone Road |
| **Hard Knuckle** (Ngạnh Quyền) | +0.05 points to body hits per 1 % of body_guard_pct you own. Fired Clay's key on a wider tag, so half its size. | +0.3 points to body hits per 1 % of body_guard_pct you own. | Rice Pestle |
| **Healing** (Trị Liệu) | +2 % to heal shares. Catalogue's any-tag row. | +12 % to heal shares. Catalogue's any-tag row. | House Call |
| **Healing art cost** (Trị Liệu Phí) | -1 % cost on healing arts. Notable -6 %. |  | House Call |
| **Healing art speed** (Trị Liệu Tốc) | +1 % speed on healing arts. Notable +6 %. |  | House Call |
| **Heat Held** (Dư Nhiệt) | +2.5 points to Fire arts while the enemy is Burning. |  | Fierce Fire Road |
| **Heavy Note** (Trọng Âm) |  | +20 to arts with an authored cooldown of 20 s or more. | Thirteenth Summer |
| **Held Water** (Tàng Thủy) | +0.02 points to Water arts per 1 % of linh lực you hold. | +0.12 points to Water arts per 1 % of linh lực you hold, so +12 at full. | One Ladle |
| **Honed Edge** (Ma Lợi) | +2 points to Metal arts. |  | Grindstone Road |
| **Hurrying Word** (Cấp Ngôn) |  | +6 % curse art speed. | One Long Word |
| **Keeping Heat** (Trì Nhiệt) |  | +15 points to Fire arts while the enemy is Burning. | Fierce Fire Road |
| **Kindling** (Dẫn Nhiên) |  | +12 % Fire damage while the enemy carries a Wood status. Wood generates Fire. | Evergreen Road |
| **Late Hour** (Vãn Thời) | +2 points to arts after the tenth second. The any-art grade of Late Leaf, later and on the same size. | +12 points to arts after the tenth second. The any-art grade of Late Leaf, later and on the same size. | Seven Lamps |
| **Late Leaf** (Vãn Diệp) |  | +12 points to Wood arts after the fourth second. | Evergreen Road |
| **Lava damage** (Nham Thương) | +2.5 % Lava damage. Catalogue variant row. |  | Fierce Fire Road |
| **Let It Ride** (Thừa Hứng) |  | A talisman that was not consumed fires once more in the same instant. That firing cannot come back. | Spring Hand |
| **Lingering Word** (Dư Ngôn) | +2.5 % curse duration, rounded to the nearest pulse, inside curse_duration_max. |  | One Long Word |
| **Linh lực regained on a crit** | +0.1 % of maximum on a crit. | +0.6 % of maximum on a crit. | Daily Lesson, One Ladle, Seven Lamps |
| **Linh lực regeneration** (Hồi Khí) | +0.15 % of maximum per second. | +1 % of maximum a pulse. | Evergreen Road, Long Firing, One Ladle, Seven Lamps |
| **Living Wood** (Hoạt Mộc) | +2 points to Wood arts. |  | Evergreen Road |
| **Living Wood (notable)** (Hoạt Mộc) |  | +12 points to Wood arts. | Evergreen Road |
| **Load-Bearing** (Phụ Trọng) | +1 point to Earth arts per artifact you carry, at most 6. | +5 points to Earth arts per artifact you carry, at most 6. | Long Firing |
| **Long Burn** (Trường Nhiên) |  | +12 % status duration. | Fierce Fire Road |
| **Long Flight** (Trường Phi) | +2 points to sword arts with an authored cooldown of 2 s or more. | +12 points to sword arts with an authored cooldown of 2 s or more. | Daily Lesson |
| **Long Loyalty** (Trường Trung) | +0.4 points to companion hits per 10 loyalty above 50. Read at compile. Loyalty is what feed buys. | +2.5 points to companion hits per 10 loyalty above 50. Read at compile. Loyalty is what feed buys. | Guide Hound |
| **Long Memory** (Trường Ký) |  | +15 % curse duration. | One Long Word |
| **Long Needle** (Trường Châm) |  | +3 % pierce. | Grindstone Road |
| **Long Simmer** (Cửu Tiên) |  | +10 points on over-time statuses with an authored duration of 4 or more. | Second Sickness |
| **Many Forms** (Đa Thức) | +1 point to sword arts per sword art slotted. |  | Daily Lesson |
| **Many Small Ills** (Bách Tiểu Tật) |  | +5 art damage per curse on the target. | One Long Word |
| **Many Streams** (Đa Lưu) |  | +20 to arts that split. | Worst Root |
| **Many Threads** (Đa Tuyến) | +1 point to sword arts per phi_kiem equipped, read at compile. |  | Daily Lesson |
| **Marked Target** (Tiêu Ký) | +1 art damage per curse on the target. |  | One Long Word |
| **Mass Behind the Blow** (Trọng Thể) | +0.02 points to body hits per 1 % of khi_huyet_pct you own. Read at compile. | +0.12 points to body hits per 1 % of khi_huyet_pct you own. Read at compile. | Rice Pestle |
| **Maximum health** (Khí Huyết) | +1 % khi_huyet_pct. | +6.5 % khi_huyet_pct. | Guide Hound, Long Firing, Rice Pestle, Second Sickness, Seven Lamps, Third Look |
| **Maximum linh lực** (Linh Hải) | +1.2 % linh_luc_pct. | +8 % linh_luc_pct. | Guide Hound, One Ladle, Second Sickness |
| **Metal damage** (Kim Thương) | +2 % Metal damage. |  | Grindstone Road |
| **Nibbling Word** (Thực Ngôn) | +1 art damage per curse on the target. |  | One Long Word |
| **Old Bark** (Lão Bì) |  | +6.5 % maximum health. | Evergreen Road |
| **One Thought** (Nhất Niệm) | +2.5 % strength of a curse on an art with a cooldown of 3 s or more. |  | One Long Word |
| **Open Door** (Khai Môn) |  | +15 % damage to an enemy under 5 % linh lực. Catalogue row, read at 5 %. | Fierce Fire Road |
| **Opened Guard** (Khai Hộ) | +1 point to companion hits per curse on the enemy. | +5 points to companion hits per curse on the enemy. | Guide Hound |
| **Ore Vein** (Khoáng Mạch) | +1 point to Metal arts per artifact equipped, 6 at most. Earth generates Metal. |  | Grindstone Road |
| **Past Papers** (Cựu Đề) |  | In a foreseen fight, +1 point per 2 points of comprehension lead, to +30. | Clever Harm |
| **Patient Art** (Nại Pháp) | +1.5 points to arts with an authored cooldown of 3 s or more. Wider than Settled Weight, so smaller. | +10 points to arts with an authored cooldown of 3 s or more. Wider than Settled Weight, so smaller. | Seven Lamps |
| **Poison art cost** (Tiết Dược) | -1 % small, -6 % notable, on poison-tag arts. Catalogue tag row. |  | Second Sickness |
| **Poison art speed** (Tốc Dược) | +1 % small, +6 % notable, on poison-tag arts. Catalogue tag row. |  | Second Sickness |
| **Poison damage** (Độc Thương) | +2.5 small, +15 notable, on the poison tag. |  | Second Sickness |
| **Power share** (Phân Lực) | +0.5 points of power_share. Inside c_comp_cap. Dead once Beast Soul Union is held. Not run. | +3 points of power_share. Inside c_comp_cap. Dead once Beast Soul Union is held. Not run. | Guide Hound |
| **Qi damage** (Khí Thương) | +1.5 % to qi hits. Reaches a companion whose fixed art is a qi hit. | +10 % to qi hits. Reaches a companion whose fixed art is a qi hit. | Guide Hound, One Ladle |
| **Quick Draught** (Cấp Phong) |  | +6 % speed on Fire arts. Catalogue row, any one tag. | Fierce Fire Road |
| **Quick Shoot** (Tấn Manh) |  | +6 % speed on Wood arts. | Evergreen Road |
| **Quick Tongue** (Tấn Thiệt) | +1 % curse art speed. |  | One Long Word |
| **Quickened** (Tấn Thế) | +0.1 points to arts per 1 % art speed you own. Read at compile. | +0.6 points to arts per 1 % art speed you own. Read at compile. | Seven Lamps |
| **Realm pierce** | +0.5 % pierce_pct. | +3 % pierce_pct. | Daily Lesson, Grindstone Road, Third Look |
| **Red Heart** (Xích Tâm) |  | +12 % Fire damage. | Fierce Fire Road |
| **Regeneration** (Hồi Khí) | +0.15 small, +1 notable. Catalogue row, linh_luc_regen_pct. | +1 % of maximum a pulse. | Second Sickness, Third Look |
| **Reopened** (Tái Liệt) | +0.1 points to hits per 1 % of health missing. | +0.6 points to hits per 1 % of health missing. Turned Away's size. | Rice Pestle |
| **Running Low** (Cạn Khí) | +1.5 points to arts while your linh lực is at 50 % or below. The any-art grade of Spent Breath. | +10 points to arts while your linh lực is at 50 % or below. The any-art grade of Spent Breath. | Seven Lamps |
| **Sap Rise** (Dịch Thăng) |  | +4 points to Wood arts per 1 % of linh lực regeneration bonus, read at compile, 24 at most by regen_cap. | Evergreen Road |
| **Set Jaw** (Giảo Nha) | +2 art damage while the target bears exactly one curse. |  | One Long Word |
| **Settled Weight** (Trầm Trọng) | +2 points to Earth arts with an authored cooldown of 3 s or more. Long Flight's key on another tag. | +12 points to Earth arts with an authored cooldown of 3 s or more. | Long Firing |
| **Sharpened Word** (Lợi Ngôn) | +2 % curse strength, inside Combat's curse bounds. |  | One Long Word |
| **Short Art** (Đoản Pháp) | +1.5 points to arts with an authored cooldown under 2 s. The rival of Patient Art. | +10 points to arts with an authored cooldown under 2 s. The rival of Patient Art. | Seven Lamps |
| **Short Edge** (Đoản Phong) | +2 points to sword arts with an authored cooldown under 2 s. | +12 points to sword arts with an authored cooldown under 2 s. | Daily Lesson |
| **Shorter soul_lockout** (Tiếp Niệm) |  | -0.1 s soul_lockout. Catalogue one-off, a single notable. Not run. | Third Look |
| **Sick Body** (Bệnh Thể) |  | +2 points to hits per status stack on the enemy. | Second Sickness |
| **Signed Paper** (Lạc Khoản) |  | +3 to talismans you drew yourself per talisman skill level. | Spring Hand |
| **Single Grudge** (Độc Oán) |  | +12 art damage while the target bears exactly one curse. | One Long Word |
| **Slag** (Xỉ Hỏa) |  | 40 % of Fire hits become Lava and keep their Fire tags. The catalogue's Conversion share one-off. | Fierce Fire Road |
| **Slow Art Damage** (Hoãn Pháp Thương) | Small +3, notable +15, on arts with an authored cooldown of 10 s or more. |  | Thirteenth Summer |
| **Slow Sap** (Hoãn Dịch) |  | +8 % ward efficiency. | Evergreen Road |
| **Slow to Lift** (Nan Giải) |  | +15 % curse duration. | One Long Word |
| **Small Word** (Tiểu Ngôn) | +2.5 % strength of a curse on an art costing 5 % or less. |  | One Long Word |
| **Soul art cost** (Tiết Thần) | -1 % cost on soul arts. The Fire art cost row on another tag. | -6 % cost on soul arts. | Third Look |
| **Soul attack damage** (Hồn Thương) | +1.5 x_soul. | +10 x_soul. | Third Look |
| **Soul resistance** (Kháng Hồn) | +1 % soul_res_pct. Not run. | +6 % soul_res_pct. Not run. | Third Look |
| **Spared Breath** (Dư Tức) | +0.02 % regeneration per 10 ward efficiency you own. Read at compile, inside regen_cap. | +0.12 % regeneration per 10 ward efficiency you own. Read at compile, inside regen_cap. | Seven Lamps |
| **Spent Breath** (Khí Tận) | +2 points to sword arts while your linh lực is at 50 % or below. | +12 points to sword arts while your linh lực is at 50 % or below. | Daily Lesson |
| **Split Hit Damage** (Phân Kích Thương) | Small +2, notable +12, on hits with three or more parts. |  | Worst Root |
| **Spread** (Thấm) | +1 % spread on spreading statuses. |  | Indigo Drop |
| **Spring Head** (Tuyền Đầu) | +0.5 points to Water arts per 1 % of regeneration you own. Read at compile. | +3 points to Water arts per 1 % of regeneration you own. Read at compile, and bounded by the 8 % regeneration cap. | One Ladle |
| **Spring Vein** (Tuyền Mạch) |  | +1 % of maximum per second. Water generates Wood. | Evergreen Road |
| **Status chance** (Nhiễm Suất) | +1 % status chance. |  | Fierce Fire Road, Second Sickness |
| **Status duration** (Trì Cửu) | +2 % status duration. |  | Fierce Fire Road, Second Sickness |
| **Status resistance** (Kháng Độc) | +1 % status_resist_pct. | +6 % status_resist_pct. | Long Firing, Rice Pestle, Seven Lamps, Third Look |
| **Steady Breath** (Bình Tức) | +1.5 points to arts while your linh lực is at 50 % or above. The any-art grade of Steady Thread. | +10 points to arts while your linh lực is at 50 % or above. The any-art grade of Steady Thread. | Seven Lamps |
| **Steady Brush** (Ổn Bút) | +1 % talisman draw success. Notable +6 %. Outside the fight. |  | Spring Hand |
| **Steady Thread** (Ổn Tuyến) | +2 points to sword arts while your linh lực is at 50 % or above. | +12 points to sword arts while your linh lực is at 50 % or above. | Daily Lesson |
| **Steeped** (Tẩm Lâu) |  | +6 % spread on spreading statuses. | Indigo Drop |
| **Still Hand** (Tĩnh Thủ) | +0.3 points to companion hits per empty art slot. Read at compile. | +2 points to companion hits per empty art slot. Read at compile. | Guide Hound |
| **Stoked** (Thiêm Sài) |  | +3 points to Fire arts per status stack on the enemy, bounded by the stack cap. | Fierce Fire Road |
| **Sword art cost** | -1 % cost on sword arts. Catalogue row, any one tag. | -6 % cost on sword arts. Catalogue row, any one tag. | Daily Lesson |
| **Sword art speed** | +1 % speed on sword arts. | +6 % speed on sword arts. | Daily Lesson |
| **Sword damage** | +2 % to hits with the sword tag. | +12 % to hits with the sword tag. | Daily Lesson |
| **Talisman art speed** (Phù Tốc) | +1 % talisman art speed. Notable +6 %. The catalogue's one-tag row. |  | Spring Hand |
| **Talisman damage** (Phù Thương) | +2 to hits with the talisman tag. Notable +12. The catalogue's one-tag row. |  | Spring Hand |
| **Taming chance** (Thuần Thú) | +1 % tame chance. Outside the fight. | +6 % tame chance. Outside the fight. | Guide Hound |
| **Tempered** (Tôi Hỏa) |  | +12 % ward strength against Fire. Fire overcomes Metal. | Grindstone Road |
| **Thin Leaf** (Bạc Diệp) |  | -6 % cost of Wood arts. | Evergreen Road |
| **Thin Stream** (Tế Lưu) | +2 points to Water arts with an authored cost of 5 % or less. | +12 points to Water arts with an authored cost of 5 % or less. | One Ladle |
| **Thin Ward** (Bạc Hộ) | +0.05 points to Fire arts per 1 % of the enemy's linh lực missing. |  | Fierce Fire Road |
| **Thinning Ward** (Bạc Hộ) | +2 art damage while the enemy has under 50 % linh lực. | +12 % art damage while the enemy has under 50 % linh lực. | One Long Word, Rice Pestle |
| **Thrifty Word** (Tiết Ngôn) | -1 % curse art cost. |  | One Long Word |
| **Thần thức** (Thần Thức) | +0.9 % than_thuc_pct. One road node in four already carries it. | +6 % than_thuc_pct. | Third Look |
| **Tough Grain** (Kiên Văn) |  | +6.5 % maximum health. | Grindstone Road |
| **Toxicity Tolerance** (Nại Độc) | +2 dan_doc_resist_pct. | +12 dan_doc_resist_pct. | Pill Glutton |
| **True Line** (Chân Tuyến) |  | +3 % accuracy. | Grindstone Road |
| **Unbroken Glaze** (Toàn Dứu) | +2 points to Earth arts while your health is at 25 % or above. | +12 points to Earth arts while your health is at 25 % or above. | Long Firing |
| **Unbroken Sentence** (Bất Đoạn) |  | +10 art damage while the enemy has under 50 % linh lực. | One Long Word |
| **Unbroken Surface** (Toàn Diện) | +2 points to Water arts while your linh lực is above 5 %. | +12 points to Water arts while your linh lực is above 5 %. | One Ladle |
| **Unmoved** (Bất Động) | +2 points to body hits while your health is at 50 % or above. Unbroken Glaze's key on a wider tag. | +12 points to body hits while your health is at 50 % or above. | Rice Pestle |
| **Urging Word** (Thôi Ngôn) | +1 point to companion hits per curse on the enemy. | +5 points to companion hits per curse on the enemy. | Guide Hound |
| **Vow Renewed** (Trùng Thệ) | +4 points to companion hits once a body has fallen. | +25 points to companion hits once a body has fallen. | Puppeteer |
| **Ward efficiency** (Hộ Hiệu) | +1.2 % ward_efficiency_pct. | +8 % ward_efficiency_pct. | Guide Hound, Long Firing, One Ladle, Second Sickness, Seven Lamps, Third Look |
| **Ward strength** | +1.2 % defense_pct. | +8 % defense_pct. | Daily Lesson, Guide Hound, Long Firing, One Ladle, Second Sickness, Seven Lamps |
| **Ward strength against body hits** (Hộ Thể) | +1.5 % ward strength against body hits. | +10 % ward strength against body hits. | Seven Lamps |
| **Ward strength against Earth** (Hộ Đê) | +2 % ward strength against Earth hits. Earth overcomes Water. | +12 % ward strength against Earth hits. | One Ladle |
| **Ward strength against Fire** (Kháng Hỏa) | +2 % ward strength against Fire. | +12 % ward strength against Fire hits. | Fierce Fire Road, One Ladle |
| **Ward strength against qi hits** (Hộ Khí) | +1.5 % ward strength against qi hits. Not run. | +10 % ward strength against qi hits. Not run. | Seven Lamps |
| **Ward strength against Water** (Khắc Thủy) | +2 % ward strength against Water hits. Earth overcomes Water. | +12 % ward strength against Water hits. | Long Firing |
| **Ward strength against Wood** (Hộ Căn) | +2 % ward strength against Wood hits. Wood overcomes Earth. | +12 % ward strength against Wood hits. | Long Firing |
| **Warm Hand** (Thủ Nhiệt) | +0.25 per talisman fired this fight, to +40 with the notable's +1. |  | Spring Hand |
| **Wasting** (Hao Tổn) | +0.03 points to hits per 1 % of the enemy's linh lực missing. | +0.2 points to hits per 1 % of the enemy linh lực missing. | Third Look, Second Sickness |
| **Water art cost** (Tiết Thủy) | -1 % cost on arts with the Water tag. Catalogue row, any one tag. | -6 % cost on arts with the Water tag. Catalogue row, any one tag. | One Ladle |
| **Water art speed** (Tấn Thủy) | +1 % speed on Water arts. Catalogue row, any one tag. | +6 % speed on Water arts. Catalogue row, any one tag. | One Ladle |
| **Water damage** (Thủy Thương) | +2 % to hits with the Water tag. | +12 % to hits with the Water tag. | One Ladle |
| **Weapon attack** (Binh Lực) | +1.5 % attack on weapon-role artifacts. Catalogue row, artifact_attack_pct. | +10 % artifact_attack_pct, weapon role. | Grindstone Road, Long Firing |
| **Weapon efficiency** | Weapons occupy 1 % less thần thức. | Weapons occupy 6 % less thần thức. | Daily Lesson |
| **White Point** (Bạch Điểm) |  | +5 % crit chance on Fire hits. The Sword row with its tag swapped. | Fierce Fire Road |
| **Wood art cost** (Mộc Pháp Phí) | -1 % cost of Wood arts. Catalogue row, any one tag. |  | Evergreen Road |
| **Wood art speed** (Mộc Pháp Tốc) | +1 % speed on Wood arts. Catalogue row, any one tag. |  | Evergreen Road |
| **Wood damage** (Mộc Thương) | +2 % Wood damage. |  | Evergreen Road |
| **Worn Slope** (Hao Pha) | +0.02 points to Earth arts per 1 % of your health missing. | +0.12 points to Earth arts per 1 % of your health missing. | Long Firing |

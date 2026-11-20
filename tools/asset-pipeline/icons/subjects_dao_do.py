"""Hand-written subjects for the Đạo Đồ node icons (art bible §7.9). Each entry: id -> (hue key, subject).

Hue keys are gen_ai.HUE keys. Stat icons use the neutral "stat" bronze so one icon reads in every land (the land's colour
is the frame's enamel line, in-engine). Ideas, capabilities, Effect notables, keystones and starts use their land's hue.

Which node shows which icon (art bible §7.9): node_<id> -> idea_<idea> -> stat_<main stat>. A plain notable shows its
main stat's icon in the notable frame (user, 2026-11-20). Roads show the colour-mapped qi pearl (frames_painted).
Every subject is kept with its full prompt and the nodes it serves in ai/openai/dao_do_catalogue.json
(catalogue_dao_do.py), so a set can be regenerated or reused. Written by hand (memory: hand-author, no scripts);
catalogue_dao_do.py only checks coverage against the tree data.
"""

LAND_HUE = {"el:hoa": "fire", "el:tho": "earth", "el:kim": "metal", "el:thuy": "water", "el:moc": "wood",
            "var:loi": "thunder", "var:am": "dark", "var:quang": "light", "var:phong": "wind", "chaos": "chaos"}

# Stats sharing one icon (PoE-style: related stats, one picture).
STAT_ALIAS = {"health_regen_inc_pct": "health_regen_pct", "linh_luc_regen_inc_pct": "linh_luc_regen_pct"}

# ---------------------------------------------------------------- stat icons (small nodes and plain notables)
STAT = {
    # offence
    "attack_pct": ("stat", "a single straight cultivator's sword thrust forward, a thin bright line of qi along its edge"),
    "crit_chance_pct": ("stat", "a narrowed eye of qi behind a single gleaming needle point, a tiny star flashing at its tip"),
    "crit_damage_pct": ("stat", "a sword point piercing a cracked jade plate, the crack bursting with white light"),
    "art_speed_pct": ("stat", "a hand forming a cultivation seal, ghosted copies of the fingers trailing in fast motion arcs"),
    "art_cost_pct": ("stat", "a cupped palm holding a small flame of qi, only a thin thread of energy flowing out of it"),
    "basic_speed_pct": ("stat", "a clenched fist striking forward, three after-images of it fanning behind in quick succession"),
    "accuracy_pct": ("stat", "a drawn arrow aimed through the centre of three concentric rings of light"),
    "pierce_pct": ("stat", "a slender spear point punching clean through a thick bronze plate, the hole glowing"),
    "resist_pen_pct": ("stat", "a blade of qi slicing through a translucent shimmering barrier, the barrier splitting apart"),
    "stack_effect_pct": ("stat", "three glowing tokens of qi stacked one on another, the top one blazing brighter than the rest"),
    "stack_duration_pct": ("stat", "three stacked glowing tokens of qi wrapped by a long slow ribbon of light that circles them"),
    "status_duration_pct": ("stat", "a lingering wisp of qi clinging to a silhouette, trailing slowly like smoke that will not fade"),
    "curse_effect_pct": ("stat", "a hooked talisman seal of dark qi, thorny tendrils spreading out from it"),
    "x_soul": ("stat", "a pale ghostly flame shaped like a spear, striking at a faint soul silhouette"),
    "element_affinity_pct": ("stat", "five small orbs of light in a ring, one in the middle drawn closer and glowing brightest"),
    "convert_pct": ("stat", "a single stream of qi flowing through a ring and coming out the other side as a different, brighter stream"),
    # defence
    "khi_huyet_pct": ("stat", "a human heart of swirling blood-qi, wrapped in a slow spiral of glowing breath"),
    "health_regen_pct": ("stat", "a cupped pair of hands with a slow upward stream of warm motes of life rising from them"),
    "healing_pct": ("stat", "an open palm with a soft lotus of light blooming above it, petals unfolding"),
    "healing_taken_pct": ("stat", "a seated figure's chest receiving a stream of warm light that sinks into it"),
    "defense_pct": ("stat", "a heavy round bronze shield seen straight on, its rim catching a hard highlight"),
    "block_rating": ("stat", "a raised forearm guard catching a falling blade, sparks bursting at the point of contact"),
    "evade_pct": ("stat", "a blurred silhouette leaning aside as a blade passes through the after-image where it stood"),
    "resist_pct": ("stat", "a calm figure inside a bright protective halo, a wave of energy breaking around it"),
    "body_shield_pct": ("stat", "a cultivator's body outlined by a hard glowing second skin of qi, like armour made of light"),
    "ward_efficiency_pct": ("stat", "a round protective seal of light, its inscribed rings tight and perfectly aligned, brighter at the centre"),
    "ward_bill_pct": ("stat", "a protective seal of light drawing only a thin trickle of qi from an open palm below it"),
    "soul_res_pct": ("stat", "a faint soul silhouette inside a glowing bell-shaped dome of light"),
    "tam_ma_resist_pct": ("stat", "a serene meditating figure while a shadowy demon face dissolves into smoke behind it"),
    "status_resist_pct": ("stat", "a palm raised flat, tendrils of corruption burning away before they touch it"),
    "timer_resist_pct": ("stat", "an hourglass whose falling sand is held still in mid-air by a ring of light"),
    "dan_doc_resist_pct": ("stat", "a pill with a dark toxic mist around it, the mist held back by a clean ring of light"),
    "dan_doc_decay": ("stat", "a dark toxic mist rising from a pill and fading away into clean light as it rises"),
    "qi_deviation_pct": ("stat", "a tangled knot of meridian lines being smoothed out into one calm flowing line"),
    "escape_pct": ("stat", "a cultivator's silhouette dissolving into a streak of light that shoots away out of the frame"),
    "stealth": ("stat", "a hooded figure half-vanished into darkness, only the edge of the hood catching a faint light"),
    # linh lực
    "linh_luc_pct": ("stat", "a round glowing pool of spiritual energy held in a dantian, brimming to its edge"),
    "linh_luc_regen_pct": ("stat", "a spiral of spiritual energy flowing steadily inward into a glowing dantian"),
    "linh_luc_on_hit_pct": ("stat", "a striking fist with a burst of qi on impact, motes of energy flying back toward the striker"),
    "linh_luc_on_crit_pct": ("stat", "a needle-point strike flashing like a star, a stream of qi rebounding from the flash"),
    "leech_linh_luc_pct": ("stat", "thin glowing threads drawing qi out of a struck silhouette into an open hand"),
    "reserve_eff_pct": ("stat", "a small sealed jade vessel holding a bright core of qi, a glowing seal on its lid"),
    # cultivation and the person
    "cultivation_speed_pct": ("stat", "a cultivator seated cross-legged in meditation, qi streaming into the crown of the head in a fast bright spiral"),
    "breakthrough_chance": ("stat", "a cultivator's silhouette bursting upward through a cracking ceiling of light"),
    "lifespan_pct": ("stat", "an ancient pine branch with a slow-burning incense stick beside it, its smoke rising in a long unbroken line"),
    "ngo_tinh": ("stat", "a single drop of light falling onto still water, perfect rings spreading from the point of insight"),
    "than_hon": ("stat", "a luminous soul flame floating above a cultivator's head, steady and bright"),
    "than_thuc_pct": ("stat", "an open third eye on a forehead, a wide sweeping fan of perception spreading from it"),
    "can_cot": ("stat", "a glowing spine and rib cage like carved jade, bones shining with inner strength"),
    "dao_tam": ("stat", "a heart of clear crystal with a single steady flame burning inside it"),
    "khi_van": ("stat", "a swirling auspicious cloud with a bright ribbon of fortune curling through it"),
    "co_duyen_pct": ("stat", "a winding mountain path with a single glowing treasure light shining from a hidden cave"),
    "mi_luc": ("stat", "a graceful folding fan half open, a soft gleam and drifting petals around it"),
    "mission_income_pct": ("stat", "a sect mission token of carved jade hanging from a cord, glowing with an earned light"),
    "travel_speed_pct": ("stat", "a flying sword carrying a cultivator's silhouette fast across a sea of clouds, long speed streaks"),
    # crafts and companions
    "alchemy_success": ("stat", "a three-legged pill cauldron with a single perfect round pill rising from its smoke"),
    "pill_effect_pct": ("stat", "a single glowing pill between two fingers, radiating rings of potency"),
    "refining_success": ("stat", "a hammer striking a glowing blade on an anvil, a bright burst of sparks"),
    "herb_growth_pct": ("stat", "a spirit herb sprouting fast from the soil, its leaves unfurling with light"),
    "formation_power_pct": ("stat", "a ring of formation flags planted around a glowing circle of runes on the ground"),
    "artifact_power_pct": ("stat", "a floating magic treasure, a small bronze bell, humming with rings of power"),
    "artifact_defense_pct": ("stat", "a small floating bronze mirror deflecting a beam of energy"),
    "artifact_attack_pct": ("stat", "a flying dagger treasure streaking forward with a trail of light"),
    "companion_power_pct": ("stat", "a spirit beast's head, a fierce wolf of light, eyes blazing"),
    "companion_health_pct": ("stat", "a spirit beast curled up inside a warm glowing aura"),
    "companion_speed_pct": ("stat", "a spirit beast mid-leap, long motion streaks behind it"),
}

# ---------------------------------------------------------------- big-picture ideas (one per idea; key = idea_slug())
IDEA = {
    # Fire
    "f1": ("fire", "Nine-Turn Furnace (Cửu Chuyển Lô): a bronze alchemy furnace with fire spiralling around it nine times, a pill of light rising from the top"),
    "f2": ("fire", "Strange Pill Gourd (Dị Đan Hồ Lô): a gourd tipped over, one strange glowing pill rolling out with a curl of smoke"),
    "f3": ("fire", "Phoenix (Phượng Hoàng): a phoenix head and neck in profile, its crest feathers of living flame"),
    "f4": ("fire", "Last Flare (Hồi Quang): a nearly spent candle whose flame suddenly flares tall and blinding"),
    "f5": ("fire", "Prairie Fire (Liệu Nguyên Hỏa): one spark landing in dry grass and a wall of flame racing out from it"),
    "f6": ("fire", "Sun Disc (Thái Dương Luân): a blazing wheel-shaped sun disc with sharp rays"),
    "f7": ("fire", "Ash Lotus (Hôi Liên): a lotus made of grey ash with embers still glowing in its petals"),
    "f8": ("fire", "Volcano (Hỏa Sơn): a volcano cone erupting a column of fire and lava bombs"),
    "f9": ("fire", "Ember Heart (Ẩn Hỏa Tâm): a heart of dark stone with a hidden ember glowing through its cracks"),
    "f10": ("fire", "Three-Legged Crow (Kim Ô): a black three-legged crow with wings spread, cut against a blazing sun disc"),
    "b11": ("fire", "Campfire (Lửa Trại): a small campfire of crossed logs, its flames rising warm and steady"),
    "b2": ("fire", "Molten Core (Dung Hạch): a sphere of molten rock with a white-hot core showing through a cracked crust"),
    "burning_blade": ("fire", "Burning Blade (Hỏa Nhận): a plain steel blade catching fire along its edge as it swings"),
    "pill_pouch": ("fire", "Pill Pouch (Đan Nang): a small tied cloth pouch with glowing pills spilling from its mouth"),
    "rise_from_ash": ("fire", "Rise From Ash (Dục Hỏa): a single flaming feather rising out of a heap of ash"),
    "searing_will": ("fire", "Searing Will (Chước Ý): a clenched fist wreathed in fierce white-hot flame"),
    "smouldering_qi": ("fire", "Smouldering Qi (Âm Hỏa): dark smouldering coals breathing slow embers, a faint thread of qi rising"),
    "soul_burning_lamp": ("fire", "Soul-Burning Lamp (Phần Hồn Đăng): a bronze oil lamp whose flame is shaped like a pale wailing soul"),
    "toxin_burning_fire": ("fire", "Toxin-Burning Fire (Luyện Độc Hỏa): a dark poisonous mist being burned away by a clean flame rising through it"),
    # Earth
    "b1": ("earth", "Kiln Hill (Diêu Sơn): a hillside kiln with fire glowing through its arched mouth, smoke rising"),
    "b3": ("earth", "Mother Lode (Mẫu Khoáng): a cave wall with a thick glowing vein of ore running through rock"),
    "e1": ("earth", "Nine Palaces (Cửu Cung Đồ): a square grid of nine glowing palaces of runes laid on the ground"),
    "e2": ("earth", "Black Tortoise (Huyền Quy): an ancient tortoise with a mountain-like shell, a serpent coiled around it"),
    "e3": ("earth", "Five Peaks (Ngũ Nhạc): five sacred mountain peaks rising from clouds, the middle one tallest"),
    "e4": ("earth", "Yellow Springs (Hoàng Tuyền): a dim underground river flowing through a dark cavern, a faint glow on the water"),
    "e5": ("earth", "Millstone (Thạch Ma): a heavy round millstone turning, grinding stone into dust"),
    "e6": ("earth", "Rampart (Thành Tường): a thick stone city wall with a gate tower, seen straight on"),
    "e7": ("earth", "Terraced Fields (Thê Điền): terraced rice fields stepping down a hillside, water glinting on each step"),
    "e8": ("earth", "Array Eye (Trận Nhãn): a glowing eye-shaped core at the centre of a formation of runes, lines converging on it"),
    "e9": ("earth", "Landslide (Sơn Băng): a mountainside breaking away, boulders tumbling down in a rush of dust"),
    "e10": ("earth", "Bedrock Root (Bàn Thạch Căn): a tree root gripping a massive boulder, both unmovable"),
    "h2": ("earth", "Cave Gate (Động Môn): the round stone gate of a cave abode in a cliff, soft light behind it"),
    "array_keeper": ("earth", "Array Keeper (Thủ Trận): a formation flag planted firmly in rock, its banner glowing with runes"),
    "bulwark": ("earth", "Bulwark (Kiên Lũy): a stout stone bastion tower standing against a storm of streaks"),
    "deep_soil": ("earth", "Deep Soil (Thâm Thổ): a cross-section of dark rich earth with a glowing seed of qi deep inside"),
    "earth_veins": ("earth", "Earth Veins (Địa Mạch): glowing lines of qi running like veins through cracked earth toward one point"),
    "five_grains": ("earth", "Five Grains (Ngũ Cốc): five full ears of grain bound together, heavy and ripe"),
    "heavy_star": ("earth", "Heavy Star (Trọng Tinh): a heavy iron meteor falling straight down, the ground cracking beneath it"),
    "ruyi": ("earth", "Ruyi (Như Ý): a carved ruyi sceptre with a cloud-shaped head, glowing softly"),
    "stone_skin": ("earth", "Stone Skin (Thạch Phu): a forearm whose skin has turned to cracked grey stone, a blade breaking on it"),
    "temple_bell": ("earth", "Temple Bell (Tự Chung): a great bronze temple bell hanging in a wooden frame, rings of sound spreading"),
    "thick_earth": ("earth", "Thick Earth (Hậu Thổ): a fist striking down into the ground, thick layers of earth heaving up around it"),
    # Metal
    "b4": ("metal", "Buried Vault (Kim Tàng Khố): an ancient treasure chest half-buried in earth, light leaking from its seam"),
    "b6": ("metal", "Autumn Dew (Thu Lộ): a single cold dew drop on the tip of a sword-shaped leaf"),
    "m1": ("metal", "Hundred-Sword Rack (Bách Kiếm Giá): a wooden rack holding a fan of many upright swords"),
    "m2": ("metal", "Spirit Furnace (Linh Lô): a refining furnace with a glowing treasure floating in its mouth"),
    "m3": ("metal", "Divided Mirror (Phân Thần Kính): a round bronze mirror split into several reflecting faces, each showing an eye"),
    "m4": ("metal", "Vajra Body (Kim Cương Thân): a muscular torso shining like polished metal, blades glancing off it"),
    "m5": ("metal", "Autumn Scythe (Thu Sát Liêm): a curved scythe sweeping through falling autumn leaves"),
    "m6": ("metal", "Ten Thousand Edges (Vạn Nhận): a storm of countless small flying blades circling in a vortex"),
    "m7": ("metal", "Golden Bell (Kim Chung Tráo): a translucent bell-shaped shield of light over a meditating figure"),
    "m8": ("metal", "Ore Vein (Khoáng Mạch): raw metal ore crystals jutting from rock, bright facets catching light"),
    "m9": ("metal", "Piercing Arrowhead (Xuyên Kim Tiễn): a heavy metal arrowhead punching through a metal plate"),
    "m10": ("metal", "Whetstone Wheel (Ma Thạch Luân): a spinning whetstone wheel throwing a fan of sparks off a blade"),
    "bronze_shield": ("metal", "Bronze Shield (Đồng Thuẫn): an ornate round shield with a beast-face boss at its centre"),
    "clear_gong": ("metal", "Clear Gong (Thanh La): a flat round gong struck once, clean rings of sound spreading outward"),
    "drawn_bow": ("metal", "Drawn Bow (Mãn Cung): a bow drawn to full moon, the arrow tip gleaming"),
    "five_metals": ("metal", "Five Metals (Ngũ Kim): five ingots of different metals stacked, each a different sheen"),
    "iron_discipline": ("metal", "Iron Discipline (Thiết Luật): an iron rule rod laid across a closed book of precepts"),
    "rotten_axe_handle": ("metal", "Rotten Axe Handle (Lạn Kha): an old axe whose wooden handle has crumbled to dust beside a go board"),
    "sword_intent": ("metal", "Sword Intent (Kiếm Ý): a sword silhouette made purely of sharp radiating light, no physical blade"),
    # Water
    "b5": ("water", "Mirror Lake (Kính Hồ): a perfectly still lake mirroring the moon, a single ripple at its centre"),
    "b7": ("water", "Rain on Bamboo (Vũ Trúc): rain falling on bamboo leaves, drops gathering on the leaf tips"),
    "b9": ("water", "Compass Rose (La Bàn): a geomancer's round compass with a glowing needle"),
    "w1": ("water", "Brush and Inkstone (Bút Nghiên): a calligraphy brush resting on an inkstone, a talisman of light forming from its tip"),
    "w2": ("water", "Dreaming River (Mộng Hà): a winding river flowing through a starry night sky like a dream"),
    "w3": ("water", "Moon over the Tide (Nguyệt Triều): a full moon pulling a rising wave of the sea toward it"),
    "w4": ("water", "Snow Lotus (Tuyết Liên): a white snow lotus with frost crystals on its petals"),
    "w5": ("water", "Icicle Crown (Băng Quan): a crown of sharp icicles, cold mist pouring off it"),
    "w6": ("water", "Whirlpool (Tuyền Qua): a deep whirlpool spiralling down into darkness"),
    "w7": ("water", "Black Abyss (Huyền Uyên): a bottomless dark abyss of water, a single pearl of light glowing far below"),
    "w8": ("water", "Paper Army (Chỉ Binh Trận): a row of cut-paper soldiers rising up and coming alive with light"),
    "w9": ("water", "Rain Curtain (Vũ Liêm): a dense curtain of falling rain with a figure's silhouette behind it"),
    "w10": ("water", "Carp at the Dragon Gate (Lý Ngư Khiêu Long Môn): a carp leaping up a waterfall toward a glowing gate, its tail turning into a dragon's"),
    "endless_knot": ("water", "Endless Knot (Vô Tận Kết): an endless knot of glowing cord looping into itself"),
    "frost_plate": ("water", "Frost Plate (Sương Giáp): a breastplate of thick frosted ice, cold vapour around it"),
    "frost_star": ("water", "Frost Star (Sương Tinh): a six-pointed star of ice crystal blazing with cold light"),
    "mill_race": ("water", "Mill Race (Thủy Xa): a wooden waterwheel turned by a rushing stream"),
    "rolling_waves": ("water", "Rolling Waves (Liên Ba): wave after wave rolling forward in a powerful line, crests curling"),
    "star_chart": ("water", "Star Chart (Tinh Đồ): an unrolled star map with constellations linked by glowing lines"),
    "still_lake_lotus": ("water", "Still Lake Lotus (Tĩnh Liên): a single lotus resting on a perfectly calm lake at night"),
    "water_trigram": ("water", "Water Trigram (Khảm Quái): the Kan trigram of three bars, the middle one whole, glowing in flowing water"),
    # Wood
    "b8": ("wood", "Wind Fan (Phong Phiến): a palm-leaf fan swinging, a gust of wind curling from it"),
    "b10": ("wood", "Wutong Perch (Ngô Đồng Thê): a wutong tree branch with a single flame-coloured feather resting on it"),
    "d1": ("wood", "Hundred-Herb Garden (Bách Thảo Viên): a walled garden bed crowded with many different glowing spirit herbs"),
    "d2": ("wood", "Wolf Pack (Lang Quần): three wolves of light running together as one pack"),
    "d3": ("wood", "Beast-Soul Totem (Thú Hồn Đồ Đằng): a carved wooden totem pole with a beast spirit rising from its top"),
    "d4": ("wood", "Green Dragon (Thanh Long): an azure-green eastern dragon coiling, scales like leaves"),
    "d5": ("wood", "World Tree (Kiến Mộc): a vast tree whose crown reaches into the clouds and roots into the earth"),
    "d6": ("wood", "Thorn Hedge (Kinh Cức): a dense hedge of long sharp thorns, one thorn glinting"),
    "d7": ("wood", "Bamboo Grove (Trúc Lâm): tall bamboo stalks in mist, a shadowy figure slipping between them"),
    "d8": ("wood", "Lingzhi Ring (Linh Chi Hoàn): a ring of lingzhi mushrooms growing in a circle, glowing softly"),
    "d9": ("wood", "Spring Sprout (Xuân Nha): a tender green sprout pushing up through melting snow"),
    "d10": ("wood", "Binding Vine (Đằng La): thick vines wrapping and binding a struggling silhouette"),
    "autumn_maple": ("wood", "Autumn Maple (Đan Diệp): red maple leaves falling, each edged like a blade"),
    "bamboo_joints": ("wood", "Bamboo Joints (Trúc Tiết): three green bamboo stalks, one split cleanly by a fast diagonal strike, the joints glowing"),
    "evergreen": ("wood", "Evergreen (Thường Thanh): a green pine standing untouched in a snowstorm"),
    "gourd_of_ten_thousand_years": ("wood", "Gourd of Ten Thousand Years (Vạn Niên Hồ Lô): an ancient gnarled gourd vine with one old gourd hanging, moss on it"),
    "hollow_bamboo": ("wood", "Hollow Bamboo (Không Trúc): a cut bamboo tube seen end-on, hollow and empty, a breath of qi passing through it"),
    "laurel_wreath": ("wood", "Laurel Wreath (Nguyệt Quế): a wreath of laurel leaves with a soft glow, ribbons tied at its base"),
    "morning_glory": ("wood", "Morning Glory (Khiên Ngưu): a twisting morning glory vine with trumpet flowers dripping venom"),
    "pine_strength": ("wood", "Pine Strength (Tùng Lực): a gnarled pine trunk gripping a cliff, bark like armour"),
    "raging_gale": ("wood", "Raging Gale (Cuồng Phong): a howling gale tearing leaves from branches in long streaks"),
    "riding_the_wind": ("wood", "Riding the Wind (Ngự Phong): a cultivator's silhouette standing on a gust of wind, robes billowing"),
    "tender_shoots": ("wood", "Tender Shoots (Nộn Chi): several tender green shoots curling upward, dew on their tips"),
    # Thunder
    "t1": ("thunder", "Tribulation Cloud (Kiếp Vân): a vast dark storm cloud swirling into a vortex, lightning gathering in its eye"),
    "t2": ("thunder", "Five Drums (Ngũ Lôi Cổ): five thunder drums in a ring, lightning leaping between them"),
    "t3": ("thunder", "Thunder Step (Lôi Bộ): a foot stepping down in a flash, lightning cracking out from the footprint"),
    "t4": ("thunder", "Heaven's Hammer (Thiên Phạt Chùy): a great hammer of lightning crashing down from the sky"),
    "arc_cloud": ("thunder", "Arc Cloud (Hồ Vân): a long arching cloud with a thin thread of lightning running along its curve"),
    "branching_bolt": ("thunder", "Branching Bolt (Chi Lôi): a single lightning bolt forking into many branches"),
    "clear_sky": ("thunder", "Clear Sky (Tình Không): storm clouds parting to reveal a clear bright sky, the last spark fading"),
    "cloud_sea": ("thunder", "Cloud Sea (Vân Hải): a rolling sea of clouds with distant lightning flickering beneath its surface"),
    "coursing_thunder": ("thunder", "Coursing Thunder (Lôi Mạch): lightning coursing along the meridian lines of a body"),
    "gathering_clouds": ("thunder", "Gathering Clouds (Tụ Vân): clouds swirling together into a dense ball, charged with sparks"),
    "grounding_rod": ("thunder", "Grounding Rod (Tiếp Địa): a metal rod planted in the earth, a lightning strike running down it into the ground"),
    "heavens_rumble": ("thunder", "Heaven's Rumble (Thiên Lôi Minh): deep rolling rings of sound shaking out from a dark thundercloud"),
    "purple_storm": ("thunder", "Purple Storm (Tử Lôi Bạo): a violent storm of lightning lashing in every direction"),
    "storm_rain": ("thunder", "Storm Rain (Bạo Vũ): heavy slanting storm rain lit by a flash of lightning"),
    "tempered_by_lightning": ("thunder", "Tempered by Lightning (Lôi Luyện): a cultivator standing firm as lightning strikes, the body glowing tempered"),
    "three_tribulations": ("thunder", "Three Tribulations (Tam Kiếp): three great lightning bolts striking down one after another"),
    "thunder_fan": ("thunder", "Thunder Fan (Lôi Phiến): a folding fan swept open, each rib crackling with lightning"),
    "thunder_gods_gaze": ("thunder", "Thunder God's Gaze (Lôi Thần Mục): a pair of eyes blazing with lightning in a storm cloud"),
    "twin_thunder": ("thunder", "Twin Thunder (Song Lôi): two lightning bolts striking side by side, crossing at one point"),
    # Light
    "l1": ("light", "Armillary Sphere (Hồn Thiên Nghi): a bronze armillary sphere of interlocking rings, a small sun at its centre"),
    "l2": ("light", "Fortune Coin (Khí Vận Tiền): an old round coin with a square hole spinning in a beam of light"),
    "l3": ("light", "Buddha's Halo (Phật Quang): a radiant halo of light behind a serene silhouette's head"),
    "l4": ("light", "Dawn (Bình Minh): the first sliver of sun breaking over a mountain ridge, rays fanning out"),
    "corona": ("light", "Corona (Nhật Miện): an eclipsed sun with a blazing corona flaring around the black disc"),
    "long_day": ("light", "Long Day (Trường Nhật): a sun hanging motionless above the horizon, shadows long and still"),
    "noon_glare": ("light", "Noon Glare (Chính Ngọ): a blinding sun straight overhead, a hard white glare"),
    "rising_sun": ("light", "Rising Sun (Húc Nhật): a large sun rising from a sea of clouds"),
    "solar_wind": ("light", "Solar Wind (Nhật Phong): streams of light blowing outward from the sun like wind"),
    "sun_shield": ("light", "Sun Shield (Nhật Thuẫn): a round shield shaped like a sun disc, rays forming its rim"),
    "sunfire": ("light", "Sunfire (Nhật Hỏa): a flame of pure sunlight burning in an open palm"),
    # Darkness
    "k1_k2": ("dark", "Devouring Maw and Veiled Cowl (Hấp Tinh Khẩu, Liễm Tức Sa): a hooded veiled figure whose open hand draws streams of essence into a dark swirling maw"),
    "k3": ("dark", "New Moon (Sóc Nguyệt): a thin new moon crescent with a dagger silhouette hidden in its curve"),
    "k4": ("dark", "Shadow Steps (Ảnh Bộ): footprints of shadow trailing across the ground, the walker already gone"),
    "k5": ("dark", "Night Moth (Dạ Nga): a dark moth with eye-patterned wings, dust of curses drifting from them"),
    "s1_s2": ("dark", "Heart Demon Altar and Incense Smoke (Tâm Ma Đài, Hương Yên): a dark altar with incense smoke curling up into a demon's face"),
    # Chaos and the hub
    "h1": ("chaos", "Twin Rings (Song Hoàn): two interlocking rings of light turning in opposite directions"),
    "h3": ("chaos", "Sixth Point (Biến Dị Chi Môn): a five-pointed star of elements with a strange sixth point growing from it"),
    "h4": ("chaos", "Before Heaven (Tiên Thiên Bát Quái): the Before-Heaven bagua of eight trigrams around a taiji, glowing"),
    "blade_breath": ("chaos", "Blade Breath (Kiếm Khí): a crescent of sharp sword energy flying through the air"),
    "chaos_blade": ("chaos", "Chaos Blade (Hỗn Kim): a sword whose blade is fractured and swirling with chaotic energy"),
    "chaos_edge": ("chaos", "Chaos Edge (Hỗn Độn Phong): a jagged edge of fractured reality, shards breaking off it"),
    "chaos_flame": ("chaos", "Chaos Flame (Hỗn Độn Hỏa): a flame that twists into fractured, shifting shapes"),
    "chaos_ground": ("chaos", "Chaos Ground (Hỗn Thổ): broken floating fragments of ground swirling in a void"),
    "chaos_root": ("chaos", "Chaos Root (Hỗn Mộc): twisting roots tangled into a chaotic knot with shards of light"),
    "chaos_tide": ("chaos", "Chaos Tide (Hỗn Triều): a wave that breaks into shards and swirls instead of falling"),
    "clear_spring": ("chaos", "Clear Spring (Thanh Tuyền): a clear spring bubbling up from a cleft in rock"),
    "cliff_hold": ("chaos", "Cliff Hold (Thủ Nhai): a hand gripping the edge of a sheer cliff, holding firm"),
    "edge_revealed": ("chaos", "Edge Revealed (Phong Mang Sơ Lộ): a sword drawn halfway from its scabbard, the blade's edge flashing"),
    "first_foothold": ("chaos", "First Foothold (Lập Túc): a single footprint pressed firmly into rock"),
    "first_leaf": ("chaos", "First Leaf (Sơ Diệp): the first leaf unfurling on a bare twig"),
    "five_phases_cycle": ("chaos", "Five Phases Cycle (Ngũ Hành Luân Chuyển): five orbs of fire, earth, metal, water and wood circling in a generating cycle"),
    "hearth": ("chaos", "Hearth (Táo Hỏa): a simple clay stove with a warm fire glowing inside"),
    "hill_spring": ("chaos", "Hill Spring (Sơn Tuyền): a small spring trickling out of a mossy hillside"),
    "primordial_breath": ("chaos", "Primordial Breath (Nguyên Khí): a single breath of primordial qi swirling out of darkness"),
    "return_to_origin": ("chaos", "Return to Origin (Quy Nguyên): streams of light flowing back into one bright point"),
    "ridge_line": ("chaos", "Ridge Line (Sơn Tích): a long mountain ridge line seen from below, firm against the sky"),
    "ripples": ("chaos", "Ripples (Liên Y): ripples spreading on dark water around a figure's reflection"),
    "spark_of_origin": ("chaos", "Spark of Origin (Nguyên Hỏa Tinh): a single primal spark igniting in an empty void"),
    "steady_ground": ("chaos", "Steady Ground (Ổn Địa): a flat stone platform holding firm as the ground shakes around it"),
    "undivided_mind": ("chaos", "Undivided Mind (Hỗn Nguyên Tâm): a sphere of swirling chaos with a perfectly calm centre"),
    "void_step": ("chaos", "Void Step (Hư Bộ): a foot stepping onto nothing, a ripple of void spreading beneath it"),
    "whetted": ("chaos", "Whetted (Đã Mài): a blade being drawn across a whetstone, a thin bright edge forming"),
    "yin_and_yang": ("chaos", "Yin and Yang (Âm Dương): a taiji symbol made of swirling light and shadow"),
}

# ---------------------------------------------------------------- capability notables (key = cap_<capability id>)
CAP = {
    "cap_1": ("metal", "Twin Arms in Harmony (Song Khí Hợp Bích): two magic treasures, a sword and a bell, orbiting each other in harmony"),
    "cap_2": ("metal", "Divided Divine Sense (Thần Thức Phân Hóa): a glowing third eye splitting its gaze into several beams"),
    "cap_3": ("metal", "Treasure Nurtured Within (Dưỡng Bảo Nội Thể): a small treasure glowing inside a translucent body's dantian"),
    "cap_4": ("metal", "Blood Commands Spirit (Huyết Ngự Linh): a drop of blood flying from a fingertip to bind a hovering treasure"),
    "cap_5": ("fire", "Soul Leaves the Body (Linh Hồn Xuất Khiếu): a glowing soul rising out of a seated meditating body"),
    "cap_6": ("chaos", "Twin Technique Cultivation (Song Tu Công Pháp): two closed cultivation scriptures side by side, their light braiding together"),
    "cap_7": ("earth", "Embryonic Breath (Thai Tức Quy Nguyên): a curled figure like an embryo breathing inside a glowing egg of qi"),
    "cap_8": ("water", "Dao in Dreams (Mộng Trung Ngộ Đạo): a sleeping cultivator beneath a dream of swirling stars"),
    "cap_9": ("dark", "Great Essence-Draining Art (Hấp Tinh Đại Pháp): a dark palm drawing glowing essence out of several silhouettes"),
    "cap_10": ("fire", "Divided Furnace Flame (Đan Hỏa Phân Lô): one fire splitting into two streams feeding two small furnaces"),
    "cap_11": ("fire", "Strange Pill Reborn (Dị Đan Hóa Sinh): a cracked pill with a new strange glow hatching from within"),
    "cap_12": ("wood", "Hundred Herbs Kept Alive (Bách Thảo Tàng Linh): a jade box opened to show fresh living herbs inside"),
    "cap_13": ("water", "Endless Talismans (Phù Lục Bất Tận): an endless stream of talismans flowing out of an open sleeve"),
    "cap_14": ("earth", "Portable Cave Abode (Động Phủ Tùy Thân): a whole tiny cave abode with a garden inside a gourd held in a palm"),
    "cap_15": ("earth", "Formation Within a Formation (Trận Trung Trận): a circle of runes with a smaller formation nested inside it"),
    "cap_16": ("wood", "Ten Thousand Beasts, One Heart (Vạn Thú Đồng Tâm): many beast silhouettes joined around a single glowing heart"),
    "cap_17": ("wood", "Beast Soul Union (Thú Hồn Hợp Thể): a cultivator's silhouette merging with a tiger spirit"),
    "cap_18": ("light", "Reading Heaven's Secrets (Thiên Cơ Diễn Toán): fingers counting over a glowing star diagram"),
    "cap_19": ("light", "Child of Fortune (Khí Vận Chi Tử): a child's silhouette standing in a pillar of auspicious light"),
    "cap_20": ("dark", "Concealed Breath (Liễm Tức Ẩn Thân): a figure whose aura shrinks to nothing, fading into the dark"),
    "cap_21": ("water", "Blink Mark (Thuấn Di Ấn): a glowing seal mark on the ground with a figure appearing on it in a flash"),
    "cap_22": ("fire", "Last Radiance (Hồi Quang Phản Chiếu): an old cultivator blazing with a final brilliant radiance"),
    "cap_23": ("thunder", "Burning Life to Break Through (Thiêu Thọ Phá Cảnh): a figure burning like a torch as lightning breaks the sky open above"),
    "cap_24": ("chaos", "Mutation Awakening (Biến Dị Khai Mở): a spiritual root crystal cracking open to reveal a strange new glow"),
    "cap_25": ("dark", "Heart Demon Turned to Strength (Tâm Ma Hóa Lực): a demon shadow being drawn into a cultivator's fist as power"),
}

# ---------------------------------------------------------------- notables with an Effect (key = name_slug(effect))
EFFECT = {
    "wildfire": ("fire", "Wildfire (Dã Hỏa): fire leaping from one burning silhouette to the next in a chain"),
    "eruption": ("fire", "Eruption (Bộc Phát): the ground bursting open under a foe, a column of lava shooting up"),
    "grinding_weight": ("earth", "Grinding Weight (Trọng Ma): two millstones closing on a struggling silhouette"),
    "burning_ground": ("earth", "Burning Ground (Địa Hỏa): cracked ground glowing with fire seeping up through it"),
    "reflection": ("water", "Reflection (Phản Chiếu): a strike hitting a mirror of water and bouncing back at its sender"),
    "tide": ("water", "Tide (Thủy Triều): a great wave rising and falling under a moon in a repeating cycle"),
    "thorns": ("wood", "Thorns (Đảo Thích): a striking fist pierced by thorns that grow out of the target"),
    "daybreak": ("light", "Daybreak (Phá Hiểu): a burst of dawn light shattering the darkness in a sharp line"),
    "dark_of_the_moon": ("dark", "Dark of the Moon (Sóc Ám): a moon swallowed by darkness, a single blade glinting in the black"),
    "first_thunder": ("thunder", "First Thunder (Tiên Lôi): the first bolt of a storm striking before anything else moves"),
    "heavens_verdict": ("thunder", "Heaven's Verdict (Thiên Phán): a pillar of judgement lightning striking down on a kneeling silhouette"),
    "before_heaven": ("chaos", "Before Heaven (Tiên Thiên): the primordial taiji forming out of formless chaos"),
}

# ---------------------------------------------------------------- keystones (key = name_slug(name))
KEYSTONE = {
    "ever_burning_furnace": ("fire", "Ever-Burning Furnace (Vĩnh Nhiên Lô): a furnace burning fiercely with no fuel, its draft sealed shut"),
    "burning_lifespan": ("fire", "Burning Lifespan (Nhiên Thọ): an incense stick of a lifetime burning down fast, each puff of smoke a burst of power"),
    "alchemists_heart": ("fire", "Alchemist's Heart (Đan Tâm): a heart-shaped pill cauldron glowing with steady inner fire"),
    "overheat": ("fire", "Overheat (Quá Nhiệt): a glowing red-hot sword blade warping from its own heat"),
    "open_sky": ("earth", "Open Sky (Không Thiên): a figure standing alone on a bare plateau under a vast open sky, no treasures"),
    "no_ward": ("earth", "No Ward (Vô Hộ): a shattered protective seal falling away from a bare-chested fighter standing firm"),
    "immovable_mountain": ("earth", "Immovable Mountain (Bất Động Sơn): a lone stone mountain standing still while a storm of streaks breaks around it, the mountain untouched"),
    "earth_vein_tap": ("earth", "Earth Vein Tap (Địa Mạch Dẫn): a formation spike driven into the ground, drawing a glowing vein of qi up from the earth"),
    "ten_thousand_swords_return": ("metal", "Ten Thousand Swords Return (Vạn Kiếm Quy Tông): countless swords flying in from every direction to one point"),
    "called_blow": ("metal", "Called Blow (Báo Chiêu): a sword pointed at a single marked spot on a target, the strike announced"),
    "autumn_harvest": ("metal", "Autumn Harvest (Thu Hoạch): a scythe sweeping through ripe stalks, each cut flashing"),
    "unyielding_breath": ("metal", "Unyielding Breath (Bất Khuất): a wounded fighter still standing, breath steaming, refusing to fall"),
    "flowing_water": ("water", "Flowing Water (Lưu Thủy): a swift stream rushing around stones without pause"),
    "still_water": ("water", "Still Water (Tĩnh Thủy): a perfectly still pool with a deep glowing centre, nothing disturbing it"),
    "boundless_sea": ("water", "Boundless Sea (Vô Biên Hải): an endless dark sea stretching to the horizon under a pale moon"),
    "thousand_talismans": ("water", "Thousand Talismans (Thiên Phù): a whirlwind of a thousand talismans swirling around a figure"),
    "spirit_garden": ("wood", "Spirit Garden (Linh Viên): a lush terraced spirit garden with a single beast resting at its gate"),
    "bare_rack": ("wood", "Bare Rack (Không Giá): an empty weapon rack, a fighter's bare fists raised before it"),
    "ten_thousand_poisons": ("wood", "Ten Thousand Poisons (Vạn Độc): a swarm of venomous creatures and poison flowers in a cauldron"),
    "sun_and_rain": ("wood", "Sun and Rain (Nhật Vũ): sunlight and rain falling together on a young tree"),
    "heavens_eye": ("light", "Heaven's Eye (Thiên Nhãn): a vast eye of light opening in the sky"),
    "sun_that_never_sets": ("light", "Sun That Never Sets (Bất Lạc Nhật): a sun fixed in the sky, no shadow anywhere beneath it"),
    "glass_meridians": ("thunder", "Glass Meridians (Lưu Ly Kinh Mạch): a translucent glass human torso, its meridian lines filled with crackling lightning, hairline cracks in the glass"),
    "hidden_moon": ("dark", "Hidden Moon (Ẩn Nguyệt): a moon hidden behind dark cloud, a figure slipping through its shadow"),
    "fire_feeds_fire": ("fire", "Fire Feeds Fire (Dĩ Hỏa Dưỡng Hỏa): one flame feeding into another, growing larger, a drop of water evaporating beside it"),
    "layered_earth": ("earth", "Layered Earth (Hậu Thổ Tích): thick stacked layers of rock strata, a strike stopped dead against them"),
    "keen_edge": ("metal", "Keen Edge (Lợi Phong): a razor edge seen along its length, splitting a hair in the air"),
    "frost_seal": ("water", "Frost Seal (Băng Phong): a seal of ice locking around a struggling flame"),
    "ageless_pine": ("wood", "Ageless Pine (Vạn Niên Tùng): an ancient pine thousands of years old, its bark scorched on one side"),
    "rising_tide": ("water", "Rising Tide (Triều Dâng): the sea swelling higher and higher against a cliff"),
    "ebb_tide": ("water", "Ebb Tide (Triều Rút): the sea drawing far back, gathering itself into one great wave"),
    "utmost_yang": ("chaos", "Utmost Yang (Dương Cực): a blazing white half of a taiji swallowing the dark half"),
    "utmost_yin": ("chaos", "Utmost Yin (Âm Cực): a deep dark half of a taiji swallowing the light half"),
    "nirvana": ("fire", "Nirvana (Niết Bàn): a phoenix rising whole out of its own ashes, wings of flame unfolding, embers falling away below"),
    "fire_lotus": ("fire", "Fire Lotus (Hỏa Liên): a lotus of flame blooming, each petal a tongue of fire"),
    "mountains_weight": ("earth", "Mountain's Weight (Sơn Nhạc Trọng): a mountain pressing down on an outstretched palm"),
    "earthen_armour": ("earth", "Earthen Armour (Thổ Giáp): a suit of armour made of packed earth and stone plates"),
    "metal_begets_water": ("metal", "Metal Begets Water (Kim Sinh Thủy): cold metal beading with water droplets that flow off it"),
    "hundred_refinements": ("metal", "Hundred Refinements (Bách Luyện): a blade folded over and over, its many layers visible like waves"),
    "water_begets_wood": ("water", "Water Begets Wood (Thủy Sinh Mộc): water pouring onto a sapling that grows up from it"),
    "returning_wave": ("water", "Returning Wave (Hồi Lãng): a wave crashing into a rock and curling back on itself"),
    "strangling_vines": ("wood", "Strangling Vines (Đằng Triền): vines tightening around a tree trunk, squeezing it"),
    "wood_begets_fire": ("wood", "Wood Begets Fire (Mộc Sinh Hỏa): a log catching fire, flames rising from the wood"),
}

# ---------------------------------------------------------------- starts (key = root key in dao_do_map.json "starts")
START = {
    "hon_don": ("chaos", "Chaos start (Hỗn Độn): a swirling primordial chaos with a single point of light at its heart"),
    "hoa": ("fire", "Fire root: a seed of flame glowing in a cupped pair of hands"),
    "tho": ("earth", "Earth root: a seed of stone with a glowing crack, held in a cupped pair of hands"),
    "kim": ("metal", "Metal root: a small bright ingot of metal resting in a cupped pair of hands"),
    "thuy": ("water", "Water root: a single drop of water glowing in a cupped pair of hands"),
    "bang": ("ice", "Ice root: a six-pointed ice crystal glowing in a cupped pair of hands"),
    "moc": ("wood", "Wood root: a green seedling sprouting from a cupped pair of hands"),
    "phong": ("wind", "Wind root: a small whirl of wind spinning above a cupped pair of hands"),
    "quang": ("light", "Light root: a small sun of light glowing in a cupped pair of hands"),
    "loi": ("thunder", "Thunder root: a small ball of lightning crackling in a cupped pair of hands"),
    "am": ("dark", "Darkness root: a small orb of darkness with a glowing rim held in a cupped pair of hands"),
}

# ---------------------------------------------------------------- road motif (painted greyscale; frames_painted.colourize)
# User 2026-11-20: qi pearl picked, candidates 1 and 2 mixed per node (frames_painted.road_candidate).
ROAD_MOTIF = {
    "qi_pearl": ("stat", "a single round spirit pearl of condensed qi, a soft swirl of energy turning inside it, a faint halo around it"),
    "acupoint": ("stat", "a single bright meridian acupoint, a small blazing star of qi with four short rays and a soft round glow"),
    "qi_swirl": ("stat", "a single small rising swirl of qi, a spiral flame of energy curling upward from one point"),
}

# ---------------------------------------------------------------- painted frames (option B; B1 = <kind>_dd0 picked)
FRAME = {
    "road": ("stat", "a slim plain ring of aged hammered bronze with a rounded rolled edge"),
    "small": ("stat", "a plain ring of aged hammered bronze with a rounded outer bead and a thin inner lip"),
    "notable": ("stat", "a sturdy ring of aged bronze with two raised beaded rims and four small round studs at the diagonals"),
    "capability": ("wood", "a ring of aged bronze ringed by eight carved green jade lotus petals pointing outward"),
    "keystone": ("stat", "a broad ornate ring of aged bronze with a twisted rope moulding, twelve round bosses and engraved cloud scrolls"),
    "start": ("stat", "a broad ring of aged bronze engraved with the eight trigrams of the bagua, raised bars evenly spaced around it"),
}

TABLE = {"dd_stat": STAT, "dd_idea": IDEA, "dd_cap": CAP, "dd_effect": EFFECT, "dd_keystone": KEYSTONE,
         "dd_start": START, "dd_roadmotif": ROAD_MOTIF, "dd_frame": FRAME}
# The full node-icon run (everything a node shows); roads and frames were picked in the look test (2026-11-20).
FULL = ["dd_statc", "dd_idea", "dd_cap", "dd_effect", "dd_keystone", "dd_start"]
# The look test's icons under their final kinds and ids (their images were moved there 2026-11-20).
TEST = [("dd_stat", "attack_pct"), ("dd_stat", "khi_huyet_pct"), ("dd_stat", "crit_damage_pct"),
        ("dd_stat", "cultivation_speed_pct"), ("dd_idea", "f10"), ("dd_idea", "w10"), ("dd_idea", "bamboo_joints"),
        ("dd_keystone", "nirvana"), ("dd_keystone", "glass_meridians"), ("dd_keystone", "immovable_mountain")]


def idea_slug(idea):
    """The icon id of a content idea string: 'F10 Three-Legged Crow (Kim Ô)' -> 'f10',
    '★ Arc Cloud (Hồ Vân)' -> 'arc_cloud', 'K1 ... + K2 ...' -> 'k1_k2'."""
    import re
    codes = re.findall(r"(?:^|\+ )([A-Z]\d+) ", idea)
    if codes:
        return "_".join(c.lower() for c in codes)
    return name_slug(idea.replace("★", ""))


def name_slug(name):
    """'Heaven's Verdict (Thiên Phán)' -> 'heavens_verdict'."""
    import re
    return re.sub(r"[^a-z0-9]+", "_", name.split("(")[0].strip().lower().replace("'", "")).strip("_")

# ---------------------------------------------------------------- stat icons v2: by stat AND scope, colour = family
# (user 2026-11-20 after the bronze set: "do what PoE does, the art + colour tell you what the node is"; research in
# design/research/poe-node-icons.md, palette §4 approved for the test). Key: "<stat>" or "<stat>__<scope>_<scope>".
# Hue keys: element keys of gen_ai.HUE for element scopes; family keys (body, linh, mind, offence, defence, fortune,
# craft, poison, sword) for the rest. A full colour field fills the circle (STAT_STYLE), as PoE's icons do.
STATC = {
    "attack_pct__moc": ("wood", "a strike of Wood qi: a whip of thorned vine lashing forward, torn leaves scattering from it"),
    "attack_pct__hoa": ("fire", "a palm thrusting forward and releasing a fire art, a spiral of flame bursting from it"),
    "attack_pct__fire": ("fire", "a raw tongue of searing flame licking upward, heat shimmer and sparks"),
    "crit_chance_pct__cold": ("ice", "a single needle of ice, a sharp star of frost flashing at its tip"),
    "attack_pct__loi": ("thunder", "a fist wreathed in lightning striking forward, bolts forking out from the knuckles"),
    "attack_pct__kim": ("metal", "a sweep of Metal qi: a gleaming crescent arc of a blade slicing through the air"),
    "attack_pct__tho": ("earth", "a stone fist smashing down, rock shards and dust bursting from the impact"),
    "attack_pct__sword": ("sword", "a straight jian sword thrust forward, its edge gleaming along its length"),
    "attack_pct__chaos": ("chaos", "a strike of chaotic energy, fractured shards of void breaking off it"),
    "khi_huyet_pct": ("body", "a human heart of swirling blood-qi, wrapped in a slow spiral of glowing breath"),
    "linh_luc_pct": ("linh", "a round glowing pool of spiritual energy held in a dantian, brimming to its edge"),
    "ngo_tinh": ("mind", "a single drop of light falling onto still water, perfect rings spreading from the point of insight"),
    "crit_chance_pct": ("offence", "a narrowed eye of qi behind a single gleaming needle point, a tiny star flashing at its tip"),
    "evade_pct": ("defence", "a blurred silhouette leaning aside as a blade passes through the after-image where it stood"),
    "khi_van": ("fortune", "a swirling auspicious cloud with a bright ribbon of fortune curling through it"),
    "alchemy_success": ("craft", "a three-legged pill cauldron with a single perfect round pill rising from its smoke"),
}
TABLE["dd_statc"] = STATC
TEST_C = [("dd_statc", k) for k in STATC]

# The three test icons that drifted from their subject (a figure instead of the thing): rewritten, regenerated.
STATC["attack_pct__fire"] = ("fire", "raw searing flames with no person or object, a tall tongue of fire curling upward, heat shimmer and sparks")
STATC["attack_pct__kim"] = ("metal", "no person: a single gleaming crescent arc of blade energy slicing across the circle, a hard metallic glint at its edge")
STATC["attack_pct__chaos"] = ("chaos", "no person: a fractured orb of chaotic energy splitting into jagged shards of void that fly outward")

# Unscoped stats: their picture is the STAT subject above, their colour the family (poe-node-icons.md section 4).
FAMILY = {
    "body": ["khi_huyet_pct", "health_regen_pct", "healing_pct", "healing_taken_pct", "can_cot", "body_shield_pct", "block_rating"],
    "linh": ["linh_luc_pct", "linh_luc_regen_pct", "linh_luc_on_hit_pct", "linh_luc_on_crit_pct", "leech_linh_luc_pct", "reserve_eff_pct", "art_cost_pct"],
    "mind": ["than_hon", "than_thuc_pct", "soul_res_pct", "x_soul", "tam_ma_resist_pct", "dao_tam", "ngo_tinh", "qi_deviation_pct"],
    "offence": ["attack_pct", "crit_chance_pct", "crit_damage_pct", "accuracy_pct", "pierce_pct", "resist_pen_pct", "art_speed_pct",
                "basic_speed_pct", "stack_effect_pct", "stack_duration_pct", "status_duration_pct", "curse_effect_pct",
                "element_affinity_pct", "convert_pct"],
    "defence": ["defense_pct", "evade_pct", "resist_pct", "ward_efficiency_pct", "ward_bill_pct", "status_resist_pct",
                "timer_resist_pct", "escape_pct", "stealth"],
    "fortune": ["khi_van", "co_duyen_pct", "mi_luc", "mission_income_pct", "travel_speed_pct", "cultivation_speed_pct",
                "breakthrough_chance", "lifespan_pct"],
    "craft": ["alchemy_success", "pill_effect_pct", "dan_doc_resist_pct", "dan_doc_decay", "refining_success", "herb_growth_pct",
              "formation_power_pct", "artifact_power_pct", "artifact_defense_pct", "artifact_attack_pct", "companion_power_pct",
              "companion_health_pct", "companion_speed_pct"],
}
for _fam, _stats in FAMILY.items():
    for _s in _stats:
        STATC.setdefault(_s, (_fam, STAT[_s][1]))

# Scoped stats: the scope shapes the picture and sets the colour. Key = statc_key(stat, scope).
STATC.update({
    # Ice (bang) and cold damage
    "attack_pct__bang": ("ice", "an Ice art: a palm pushing out a spear of jagged ice crystals, frost mist trailing"),
    "stack_duration_pct__bang_debuff": ("ice", "a frozen silhouette locked in a thick shell of ice that slowly creeps further over it"),
    "stack_effect_pct__bang_debuff": ("ice", "three layers of frost crystals stacked over a struggling silhouette, the top layer blazing cold"),
    "attack_pct__cold": ("ice", "no person: a blast of freezing wind full of ice shards bursting outward"),
    "resist_pct__cold": ("ice", "a calm figure inside a halo of light while a blizzard of ice breaks around it"),
    "resist_pen_pct__cold": ("ice", "an icicle spear punching through a shimmering barrier, the barrier shattering like frost"),
    # Chaos
    "resist_pen_pct__chaos": ("chaos", "a shard of chaotic void piercing a translucent barrier, the barrier dissolving into fragments"),
    # Companions, formations, talismans (crafts)
    "attack_pct__companion": ("craft", "a spirit beast, a wolf of light, lunging with bared fangs"),
    "art_speed_pct__formation": ("craft", "formation flags whirling fast around a circle of runes, motion streaks"),
    "attack_pct__formation": ("craft", "a formation circle of runes on the ground firing a beam of light upward"),
    "art_speed_pct__talisman": ("craft", "a fan of paper talismans flung fast from two fingers, motion streaks behind them"),
    "attack_pct__talisman": ("craft", "a single paper talisman bursting into a blast of energy as it strikes"),
    # Curses (Darkness purple)
    "art_cost_pct__curse": ("dark", "a hooked curse seal drawn with only a thin thread of qi from a fingertip"),
    "art_speed_pct__curse": ("dark", "a hand flicking a curse seal forward, ghosted copies trailing in fast arcs"),
    "status_duration_pct__curse": ("dark", "a curse seal clinging to a silhouette, its dark tendrils wrapping tighter and lingering"),
    "status_resist_pct__curse": ("dark", "a raised palm burning a dark curse seal to ash before it lands"),
    # Fire damage type
    "crit_chance_pct__fire": ("fire", "a needle point of white-hot flame, a star flash of fire at its tip"),
    "resist_pct__fire": ("fire", "a calm figure inside a halo of light while a wall of flame breaks around it"),
    "resist_pen_pct__fire": ("fire", "a lance of fire punching through a shimmering barrier, the barrier melting apart"),
    # Force
    "resist_pct__force": ("force", "a calm figure inside a halo of light while a concentric shockwave breaks around it"),
    # Fire arts (hoa)
    "art_cost_pct__hoa": ("fire", "a cupped palm holding a small steady flame, only a thin thread of qi feeding it"),
    "art_speed_pct__hoa": ("fire", "a hand forming a fire seal, ghosted copies of the fingers trailing flame in fast arcs"),
    "crit_chance_pct__hoa": ("fire", "a narrowed eye reflected in a flame, a star flash of fire at the flame's tip"),
    "crit_damage_pct__hoa": ("fire", "a burning sword point piercing a cracked plate, the crack bursting with fire"),
    "leech_linh_luc_pct__hoa": ("fire", "thin threads of flame drawing qi out of a burning silhouette into an open hand"),
    "linh_luc_on_hit_pct__hoa": ("fire", "a burning fist striking, motes of qi flying back from the burst of fire"),
    "stack_duration_pct__hoa_debuff": ("fire", "embers clinging to a silhouette, smouldering on and on without going out"),
    "stack_effect_pct__hoa_debuff": ("fire", "three burning brands stacked over a silhouette, the top one blazing brightest"),
    "attack_pct__hoa_slow": ("fire", "a huge slow fist of fire crashing down, a heavy shockwave of flame"),
    # Metal arts (kim)
    "art_speed_pct__kim": ("metal", "a hand forming a Metal seal, ghosted copies of the fingers trailing silver glints"),
    "crit_chance_pct__kim": ("metal", "a needle point of polished metal, a sharp star of light flashing at its tip"),
    "crit_damage_pct__kim": ("metal", "a metal blade point piercing a cracked jade plate, the crack bursting with white light"),
    # Light
    "attack_pct__light": ("light", "no person: a beam of pure sunlight striking down, rays bursting where it lands"),
    "crit_chance_pct__light": ("light", "a needle of sunlight, a blinding star flash at its tip"),
    "resist_pct__light": ("light", "a calm figure shielded from a glare of searing light by a darker halo"),
    "resist_pen_pct__light": ("light", "a ray of light piercing a shimmering barrier, the barrier burning away"),
    # Lightning damage type
    "attack_pct__lightning": ("thunder", "no person: a single jagged lightning bolt striking down, branching at the bottom"),
    "crit_chance_pct__lightning": ("thunder", "a needle point crackling with lightning, a star flash at its tip"),
    "resist_pct__lightning": ("thunder", "a calm figure inside a halo of light while lightning strikes all around it"),
    "resist_pen_pct__lightning": ("thunder", "a lightning bolt punching through a shimmering barrier, the barrier cracking apart"),
    "attack_pct__lightning_quick": ("thunder", "three quick lightning strikes in a row, flashing one after another"),
    # Thunder arts (loi)
    "stack_duration_pct__loi_debuff": ("thunder", "crackling static clinging to a silhouette, sparks running over it again and again"),
    "stack_effect_pct__loi_debuff": ("thunder", "three charges of lightning stacked over a silhouette, the top one blazing brightest"),
    "attack_pct__loi_slow": ("thunder", "a great slow hammer of thunder crashing down, a heavy shockwave of lightning"),
    # Wood arts (moc)
    "art_cost_pct__moc": ("wood", "a cupped palm with a small green sprout of qi growing from it, fed by a thin thread"),
    "art_speed_pct__moc": ("wood", "a hand forming a Wood seal, ghosted copies of the fingers trailing leaves in fast arcs"),
    "crit_chance_pct__moc": ("wood", "a sharp thorn point with a star flash of green light at its tip"),
    "crit_damage_pct__moc": ("wood", "a thorned vine spear piercing a cracked plate, the crack bursting with green light"),
    "stack_effect_pct__moc_debuff": ("wood", "three tightening coils of thorned vine stacked over a silhouette, the top one glowing brightest"),
    "attack_pct__moc_over_time": ("wood", "rot spreading slowly over a fallen log, green spores rising from it"),
    # Damage over time, quick and slow strikes (offence)
    "attack_pct__over_time": ("offence", "a lingering wound of glowing qi, slowly burning on a silhouette long after the strike"),
    "attack_pct__quick": ("offence", "a flurry of quick strikes, many after-images of a fist in a fan"),
    "attack_pct__slow": ("offence", "a single slow heavy blow, a massive fist crashing down with a heavy shockwave"),
    # Wind
    "attack_pct__phong": ("wind", "a Wind art: a crescent blade of wind slicing through the air, leaves caught in its wake"),
    "attack_pct__phong_quick": ("wind", "several quick crescent blades of wind slicing in a rapid flurry"),
    # Physical
    "attack_pct__physical": ("phys", "a bare fist striking hard, a burst of force and dust at the impact"),
    "crit_chance_pct__physical": ("phys", "a needle point of hardened bone-white steel, a star flash at its tip"),
    "resist_pct__physical": ("phys", "a calm figure inside a halo of light while blades and rocks break against it"),
    "resist_pen_pct__physical": ("phys", "a heavy spear point punching through a thick shield, the shield splitting"),
    "convert_pct__physical_to_fire": ("fire", "a plain steel blade turning into fire along its length, its tip already burning"),
    # Poison
    "attack_pct__poison": ("poison", "a dagger dripping venom, toxic mist curling from the drops"),
    "status_resist_pct__poison": ("poison", "a raised palm burning away a cloud of toxic venom before it touches"),
    # Sword
    "art_speed_pct__sword": ("sword", "a hand forming a sword seal, a flying sword darting fast with motion streaks"),
    "crit_chance_pct__sword": ("sword", "the tip of a jian sword with a sharp star of light flashing at its point"),
    "crit_damage_pct__sword": ("sword", "a jian sword point piercing a cracked jade plate, the crack bursting with light"),
    "attack_pct__sword_kim": ("metal", "a jian sword of shining Metal qi slicing, its edge leaving a silver arc"),
    # Earth arts (tho)
    "crit_damage_pct__tho": ("earth", "a stone spike piercing a cracked plate, the crack bursting with ochre light"),
    # Water arts (thuy)
    "art_cost_pct__thuy": ("water", "a cupped palm holding a small swirl of water, only a thin thread of qi feeding it"),
    "art_speed_pct__thuy": ("water", "a hand forming a Water seal, ghosted copies of the fingers trailing water in fast arcs"),
    "attack_pct__thuy": ("water", "a Water art: a palm releasing a crashing wave that bursts forward"),
    "crit_chance_pct__thuy": ("water", "a needle of pressurised water, a star flash of spray at its tip"),
    "linh_luc_on_hit_pct__thuy": ("water", "a water-wreathed fist striking, motes of qi flowing back in a ripple"),
    "stack_effect_pct__thuy_buff": ("water", "three swirling rings of water stacked around a figure, the top one glowing brightest"),
})
TEST_C = [("dd_statc", k) for k in STATC]
REDO_C = ["attack_pct__fire", "attack_pct__kim", "attack_pct__chaos"]


# ---------------------------------------------------------------- notable icons, one per distinct name (user 2026-11-20:
# "one per name, ideas first"). Key = name_slug(name); colour = the family of the notable's main line (STATC hues).
NOTE = {
    "noon_heat": ("fire", "Noon Heat (Ngọ Nhiệt): the sun at its highest point blazing down on cracked scorched ground, a heat haze rising"),
    "bleak_autumn": ("metal", "Bleak Autumn (Túc Sát): a bare tree in a cold wind, its last leaves cut away by thin silver blade-glints"),
    "frost_bloom": ("ice", "Frost Bloom (Sương Hoa): a flower made entirely of frost crystals opening on a frozen branch"),
    "dragon_coil": ("wood", "Dragon Coil (Long Bàn): the body of a green wood dragon coiled tight around a tree trunk, scales like bark and leaves"),
    "war_drum": ("thunder", "War Drum (Chiến Cổ): a great war drum struck hard, rings of lightning bursting from its skin"),
}
TABLE["dd_note"] = NOTE


def statc_key(stat, scope):
    """The v2 stat icon id: 'attack_pct' or 'attack_pct__hoa_debuff'; '>' in a conversion scope becomes '_to_'."""
    stat = STAT_ALIAS.get(stat, stat)
    return stat if not scope else stat + "__" + "_".join(scope).replace(">", "_to_")

# Stat icons v2 replace the bronze dd_stat set in the node lookup (2026-11-20); dd_stat stays as the record of the first set.
STATC_UNUSED = ["stack_effect_pct", "stack_duration_pct", "convert_pct"]
for _k in STATC_UNUSED:
    STATC.pop(_k, None)

# Palette v2 (2026-11-20): Sword joins Metal (one group fewer; design/research/poe-node-icons.md 4b).
for _k, (_h, _s) in list(STATC.items()):
    if _h == "sword":
        STATC[_k] = ("metal", _s)

# Notable subjects drafted per land (notes/<land>.json, reviewed before painting) with each notable's colour group from
# its main line (notes/HUES.json, computed). The five test notables above keep their own entries.
def _load_notes():
    import glob as _g
    import json as _j
    import os as _o
    here = _o.path.dirname(_o.path.abspath(__file__))
    hp = _o.path.join(here, "notes", "HUES.json")
    if not _o.path.exists(hp):
        return
    hues = _j.load(open(hp, encoding="utf-8"))
    for f in sorted(_g.glob(_o.path.join(here, "notes", "*.json"))):
        if f.endswith("HUES.json"):
            continue
        for slug, subj in _j.load(open(f, encoding="utf-8")).items():
            if slug in hues and slug not in NOTE:
                NOTE[slug] = (hues[slug], subj)


_load_notes()

# Frames v2 (user 2026-11-20: "the notable and keys should be more distinctive"; PoE study: notable = a spiky gold
# outline, keystone = a heavy engraved disc with a star window). Our own motifs, not PoE's shapes.
FRAME["notable2"] = ("fortune", "a bright gilded gold ring whose outer edge rises into eight evenly spaced ruyi cloud-scroll points, "
                     "like a sunburst of curling cloud heads, the inner opening a clean circle")
FRAME["keystone2"] = ("fortune", "a heavy wide disc of engraved gold with deep relief of coiling dragons and clouds, the central "
                      "opening a regular octagon with a raised bevelled lip, the outer rim thick and solid")

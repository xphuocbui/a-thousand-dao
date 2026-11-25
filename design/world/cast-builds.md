# Cast builds: review sheet

> **Status:** DRAFT 2026-11-20, hand-authored by Claude for the user's one review.
> **Data:** `design/world/cast_builds.json` (54 builds, the living fixed cast; World Generation & History, Core Rule 6).
> **Checked:** `python tools/design/world/export_world.py --check` passes with no failures and no observations.

One row per person, grouped by sect. The targets column shows up to four of the person's Đạo Đồ targets:
keystones (K) and capability notables (cap) first, then notables. The route to each target opens in order,
and the points left over go to the start's land. "Why it fits" is the build's one-line concept.

## Points for review

1. **Shared manuals.** There are 26 main methods for 54 people, so many manuals are shared; the full list is in
   *Shared techniques* below. Most shares follow a master-disciple or lord-vassal line. Two are deliberate story
   links:
   - The two duelists who fought to a draw on Cùng Mục Phong both hold Tàn Ảnh Kiếm Kinh.
   - Triệu Huyết Y holds Không Triều Kinh, the Night Rain head's manual, bought at the Night Rain Market.

   The others are cross-sect for lack of choice. Thanh Hoàn Kinh, the only Huyền Wood main, is held by six Kết
   Đan growers and healers. Each generic Địa manual is held by 3-4 people.
2. **No main method for Ice, Darkness, Blood or Light.** The only Ice main is Đông Toán Kinh (Huyền), so the Băng
   Tâm head uses Huyền Thủy Thiên Kinh plus Đình Thời Kinh. Darkness people take a Metal or Water main, and Poison
   (Hồng Đậu) is Wood with poison-scoped nodes and Hủ Quan Điển.
3. **Harmony left at 0.6 on purpose, twice.**
   - Lệ Tiêu Hồn: Cửu Ấn Lục (Metal) under a Thunder main. With his Metal purity it still beats a neutral Earth
     art he has no root for.
   - Mạc Quy Khư: Đình Thời Kinh under the Chaos main Bách Pháp Hiền Kinh. Under the harmony rule (worst pair), a
     Hỗn Độn main clashes with every element-named secret art; only innate variants or body arts escape it.
   Both are worth a rule look.
4. **Artifact grade scale.** The brief said grade 1-5, but `ItemFactory.artifact` reads 0..4 (Phàm..Cực phẩm) and
   `cast_builds.gd` passes the number through. Every grade here is 1-4, valid under both readings. Under the 0..4
   reading, 4 is Cực phẩm, which only the Nguyên Anh and Hóa Thần carry.
5. **Legendary items.** Sixteen people hold a legendary item that is not in `items_named` and takes no gear slot.
   Their gear avoids a named piece of the same kind; Tư Không Hạc Niên still carries a base flying sword beside
   Cô Hạc. Still open: should a legendary take one of the three slots?
6. **Named items.** 33 of 54 people carry one named item each, following the items' `holder` hints where one
   exists.
7. **Starts with no focus land.**
   - Mạc Quy Khư starts on the Chaos start. The leftover allocator matches no node to `hon_don`, so about 450 of
     his 530 points spread without a focus.
   - The Ice people start on `thuy` instead of `bang`, because no node is in a `bang` area.
   - Ung Hạc Minh starts on Wood, since Wind's land has only 19 nodes.
8. **Smaller doubts.**
   - Mạnh Dạ Vũ holds the Thunder drum (Thiên Tâm Lôi Cổ, "kept in a rain-calling hall"), but his root has no
     Thunder.
   - Mạc Quy Khư takes Song Tu Công Pháp, but the format has no second main method to use it.
   - Two Kết Đan crafters are at skill 9: Đồng Hồng Lô (alchemy) and Ninh Trúc Thực (spirit farming).
   - Thẩm Bắc Thần is given a small Fire root and a Light variant so his star divination can take Thiên Cơ Diễn
     Toán.
   - Ngu Lam Sơn has no secret art (a peaceable steward).
   - The formation skill is `tran_phap` (the `crafting_formations` id). `world_generation.json`
     `archetype_skills` still says `tran_dao`.

## Shared techniques

| Technique | Kind | Held by |
|---|---|---|
| Verdant Cycle Scripture (Thanh Hoàn Kinh) | main | Đàm Thanh Giang, Quyền Thanh Lam, Hà Thính Tùng, Nghiêm Linh Chi, Ninh Trúc Thực, Giả Hồi Xuân |
| Canh Kim Địa Quyết | main | Quan Vũ Thanh, Cố Dạ Lan, Thang Vô Tạ, Lý Hận Bích |
| Huyền Thủy Địa Quyết | main | Hồ Tùng Nguyệt, Kiều Nguyệt Châu, Giang Cửu Khúc, Châu Phi Vân |
| Canh Kim Thiên Kinh | main | Doãn Ngọc Hành, Đỗ Tinh Hà, Doãn Hi Hòa, Tư Không Hạc Niên |
| Thanh Mộc Địa Quyết | main | Ngu Lam Sơn, Tống Tọa Vân, Nghê Hồng Đậu |
| Hậu Thổ Địa Quyết | main | Thẩm Bắc Thần, Kim Vạn Lý, Vệ Văn Cơ |
| Mountain Heart Canon (Sơn Tâm Kinh) | main | Tô Mộ Vân, Khấu Mục Vân, Hùng Phần Vũ |
| Nine-Temper Scripture (Cửu Luyện Kinh) | main | Cát Lưu Quang, Hạng Dạ Bôi, Lâm Dã Hạc |
| Hậu Thổ Thiên Kinh | main | Tô Vãn Chiếu, Trầm Tịch Dương, Phan Vật Hoa |
| Winter Toll Canon (Đông Toán Kinh) | main | Tiết Hàn Mai, Sở Hàn Y, Thái Lê Tuyết |
| Hollow Tide Scripture (Không Triều Kinh) | main | Mạnh Dạ Vũ, Triệu Huyết Y |
| Lôi Đế Chân Kinh | main | Mạnh Lưu Ly, Úc Diệp Thanh |
| Red Sun Scripture (Xích Nhật Kinh) | main | Đồng Hồng Lô, Lạc Đan Thanh |
| Still Moon Tide Scripture (Tĩnh Nguyệt Triều Kinh) | main | Mai Lễ Tuyền, Đoạn Thương Hải |
| Xích Diễm Thiên Kinh | main | Hoa Triêu Dương, Vu Ngô Đồng |
| Thanh Mộc Thiên Kinh | main | Thôi Khinh Hồng, Đàm Tùng Lại |
| Hundred Echo Palm Scripture (Bách Hưởng Chưởng Kinh) | body | Đàm Tùng Lại, Mạnh Lưu Ly, Tống Tọa Vân, Úc Diệp Thanh, Đoạn Thương Hải |
| Long Tượng Công | body | Đỗ Tinh Hà, Thôi Khinh Hồng, Hùng Phần Vũ, Mạc Quy Khư |
| Undertow Litany (Hạ Lưu Kệ) | secret | Kiều Nguyệt Châu, Bùi Phiêu Bình, Đoàn Thanh Lãng, Triệu Huyết Y |
| Kim Cang Thể | body | Cố Dạ Lan, Phan Vật Hoa, Đoàn Thanh Lãng |
| Mountain Bone Body Art (Sơn Cốt Thể Thuật) | body | Quyền Thanh Lam, Khấu Mục Vân, Vệ Văn Cơ |
| Returning Wake Verse (Hồi Lưu Thi) | secret | Hồ Tùng Nguyệt, Quan Vũ Thanh, Giang Cửu Khúc |
| Stilled Hour Sutra (Đình Thời Kinh) | secret | Sở Ngọc Hồ, Thái Lê Tuyết, Mạc Quy Khư |
| Afterimage Sword Canon (Tàn Ảnh Kiếm Kinh) | secret | Thang Vô Tạ, Tư Không Hạc Niên |
| Debt Ledger Blade (Huyết Trái Đao Lục) | secret | Hạng Dạ Bôi, Triệu Huyết Y |
| Deep Vein Scripture (Thâm Mạch Kinh) | secret | Doãn Ngọc Hành, Thẩm Bắc Thần |
| Drawn-Out Edge Canon (Trì Nhận Kinh) | secret | Đỗ Tinh Hà, Cố Dạ Lan |
| Hundred-Blades Canon (Bách Nhận Kinh) | secret | Doãn Hi Hòa, Tô Vãn Chiếu |
| Iron Hide Manual (Thiết Bì Quyết) | secret | Cát Lưu Quang, Kim Vạn Lý |
| Thorn and Ink Verses (Cức Mặc Thi) | secret | Hà Thính Tùng, Châu Phi Vân |

## Thiên Xu Tông

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| doan_ngoc_hanh | Doãn Ngọc Hành | Nguyên Anh early | kim 80, tho 78 | Canh Kim Thiên Kinh (10) | Layered Earth (K); Formation Within a Formation (cap); Earth Vein Tap (K); Array Flag | The Pivot's cautious keeper of the Compact: fights from inside his own arrays behind stone wardens, and never steps out of them |
| do_tinh_ha | Đỗ Tinh Hà | Nguyên Anh late | kim 90, tho 62 | Canh Kim Thiên Kinh (14) | Keen Edge (K); Called Blow (K); Serpent Spear; Plum Blossom Spear | Four centuries of the Pivot's wars: a spearman of the Phá Quân spear who patiently waits for one called, killing blow |
| doan_hi_hoa | Doãn Hi Hòa | Trúc Cơ middle | kim 74, tho 60 | Canh Kim Thiên Kinh (3) | Keen Edge (K); Metal Root; Sword Rainbow; Autumn Water Sword | The presumed heir: her master's canon at its first layers and an ambitious edge she has not yet learned to sheathe |

## Tùng Đào Cung

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| thoi_khinh_hong | Thôi Khinh Hồng | Hóa Thần middle | moc 92, thuy 74 | Thanh Mộc Thiên Kinh (14) | Ageless Pine (K); Sun and Rain (K); Pine Bark; Pine Strength | The pine that outlived its founder: a Hóa Thần who slew the white wolf king, all endurance and slow, unkillable regrowth |
| dam_tung_lai | Đàm Tùng Lại | Nguyên Anh late | moc 85, thuy 72 | Thanh Mộc Thiên Kinh (13) | Sun and Rain (K); Water Begets Wood (K); Dao in Dreams (cap); Spring Shoots | A calm teacher who answers force with patience: sun-and-rain sustain, his master's canon, a palm that only answers |
| ho_tung_nguyet | Hồ Tùng Nguyệt | Kết Đan late | thuy 76, moc 62 | Huyền Thủy Địa Quyết (9) | Rising Tide (K); Dao in Dreams (cap); Timely Rain; Nourishing Rain | The sect's first elder and favourite teacher: gentle rain arts, deep linh lực, and dreams that cultivate on the road |
| dam_thanh_giang | Đàm Thanh Giang | Trúc Cơ late | moc 68, hoa 46, thuy 40 | Verdant Cycle Scripture (Thanh Hoàn Kinh) (5) | Forest Floor; Herb Seed; Spirit Grass; New Leaf | The head's humble disciple who would rather tend herbs and pills than fight; a healer's canon, a furnace gourd |

## Lạc Hà Tông

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| to_van_chieu | Tô Vãn Chiếu | Nguyên Anh early | tho 80, moc 60, kim 52 | Hậu Thổ Thiên Kinh (10) | Hundred Refinements (K); Gate of Faith; Spirit Coin; Buried Vault | Lạc Hà's merchant head: Earth for standing, a purse of coins and a rain of blades for business, the sword Tử Điện at her hip |
| tram_tich_duong | Trầm Tịch Dương | Nguyên Anh late | tho 86, moc 56 | Hậu Thổ Thiên Kinh (14) | Layered Earth (K); Immovable Mountain (K); Earthen Armour (K); Earthen Gate | The retired head in the second seat: a stubborn, greedy wall of Earth who never moves and keeps a ledger of every debt |
| to_mo_van | Tô Mộ Vân | Luyện Khí late | tho 78, moc 70, thuy 64 | Mountain Heart Canon (Sơn Tâm Kinh) (3) | Ink Trace; Ink Pool; Running Script | The world's brightest young talent: three good roots, a talisman hand that beat Nam Phố's scribes at fourteen |

## Thính Vũ Lâu

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| manh_da_vu | Mạnh Dạ Vũ | Nguyên Anh late | thuy 86, kim 66, phong 50 | Hollow Tide Scripture (Không Triều Kinh) (12) | Ebb Tide (K); Metal Begets Water (K); Moonlit Rain; Rain Curtain | The Night Rain head: a paranoid schemer who drains whoever comes close and is never quite where he was struck |
| quan_vu_thanh | Quan Vũ Thanh | Kết Đan late | thuy 72, kim 60 | Canh Kim Địa Quyết (8) | Rising Tide (K); Rainbow Bridge; Timely Rain; Dry in the Rain | The Tower's loyal envoy: a patient, gracious swordswoman of the rain who would rather talk peace than win |
| manh_luu_ly | Mạnh Lưu Ly | Kết Đan early | kim 72, hoa 48, thuy 55, loi 66 | Lôi Đế Chân Kinh (7) | Glass Meridians (K); Burning Life to Break Through (cap); Thunder Root; Thunder Step | The ambitious disciple who would be head: glass-meridian Thunder, all speed and no defence, burning years to break through |
| co_da_lan | Cố Dạ Lan | Nguyên Anh late | kim 92, huyet 55 | Canh Kim Địa Quyết (12) | Ten Thousand Swords Return (K); Keen Edge (K); Called Blow (K); Edge of Autumn | The war elder who has never lost a duel: a pure Metal root, swords only, every keystone spent on the edge |
| le_tieu_hon | Lệ Tiêu Hồn | Nguyên Anh middle | hoa 60, kim 68, loi 84 | Heavenly Tribulation Scripture (Thiên Kiếp Kinh) (12) | Storm Heart; Thunder Net; Thunder Thread; Cloudburst | Keeper of Kinh Lôi Mạch and the soul vaults: a cruel, patient Thunder caster who binds, seals and brands |

## Băng Tâm Các

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| so_ngoc_ho | Sở Ngọc Hồ | Nguyên Anh middle | thuy 86, bang 84 | Huyền Thủy Thiên Kinh (12) | Frost Seal (K); Returning Wave (K); Ice Root; Ice Lotus | The reclusive Ice head: a near-pure Water-Ice root that freezes the hour and seals every foe in frost |
| tiet_han_mai | Tiết Hàn Mai | Kết Đan late | thuy 72, tho 50, bang 54 | Winter Toll Canon (Đông Toán Kinh) (9) | Frost Seal (K); Still Ice; Frost Shield; Guardian Array | Băng Tâm's cautious formation elder: ice seals and frost shields inside a guardian array, honest and immovable |
| so_han_y | Sở Hàn Y | Trúc Cơ middle | thuy 70, bang 66 | Winter Toll Canon (Đông Toán Kinh) (5) | Frost Seal (K); Ice Root; Ice Lance | Her master's calm, stubborn disciple: an ice sword and the frost seal, nothing else yet |

## Thúy Vi Tông

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| ngu_lam_son | Ngu Lam Sơn | Nguyên Anh late | moc 82, tho 68 | Thanh Mộc Địa Quyết (12) | Hundred Herbs Kept Alive (cap); Spirit Garden (K); Embryonic Breath (cap); Growth Rings | A content, peaceable steward who never learned a killing art: fields, herbs and long closed-door years in the haze |
| quyen_thanh_lam | Quyền Thanh Lam | Kết Đan late | tho 70, moc 62 | Verdant Cycle Scripture (Thanh Hoàn Kinh) (8) | Portable Cave Abode (cap); Well-Field; Paddy Fields; Five Grains | Thúy Vi's diligent, loyal first elder: the sect's fields carried wherever he goes, a steady Earth body under him |

## Phượng Minh Cung

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| hoa_trieu_duong | Hoa Triêu Dương | Nguyên Anh early | hoa 88, moc 62 | Xích Diễm Thiên Kinh (10) | Nirvana (K); Phoenix Nest; Phoenix Down; Phoenix Cry | The brave, ambitious Phoenix head: a phoenix that burns and is reborn, the panpipes she must never play in full |
| vu_ngo_dong | Vu Ngô Đồng | Kết Đan late | hoa 74, moc 64 | Xích Diễm Thiên Kinh (7) | Ten Thousand Beasts, One Heart (cap); Beast Soul Union (cap); Beast Pen; Beast Claw | The wutong where the phoenixes roost: a generous, impatient beast tamer whose spirit birds fight for him |

## Thối Tinh Môn

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| cat_luu_quang | Cát Lưu Quang | Kết Đan early | kim 80, hoa 62 | Nine-Temper Scripture (Cửu Luyện Kinh) (6) | Hundred Refinements (K); Treasure Nurtured Within (cap); Bronze Spade; Ore Vein | The star-iron smith: a stubborn forger who fights with the blades he tempers and grows the one he keeps inside him |

## Phất Y Cốc

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| thang_vo_ta | Thang Vô Tạ | Kết Đan middle | kim 86, phong 56 | Canh Kim Địa Quyết (9) | Twin Arms in Harmony (cap); Ten Thousand Swords Return (K); Edge of Autumn; Sword Spine | The silent sword of Phất Y: a pure blade who held Tư Không Hạc Niên to a draw for three days with the same afterimage art |

## Củng Tinh Quán

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| tham_bac_than | Thẩm Bắc Thần | Nguyên Anh late | tho 82, kim 62, hoa 32, quang 44 | Hậu Thổ Địa Quyết (12) | Formation Within a Formation (cap); Earth Vein Tap (K); Reading Heaven's Secrets (cap); Array Foundation | The star-reader of Củng Tinh: the finest formation master alive, who reads heaven's secrets before every choice |

## Cửu Cao Phái

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| ung_hac_minh | Ung Hạc Minh | Kết Đan early | moc 60, phong 76 | Phong Hành Quyết (7) | Ten Thousand Beasts, One Heart (cap); Beast Soul Union (cap); Cloud Step; Beast Pen | The crane rider: fast on the wind, kind to every beast, and the one crane king that lets no one else ride it fights beside her |

## Hàm Nguyệt Trang

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| kieu_nguyet_chau | Kiều Nguyệt Châu | Kết Đan middle | thuy 78, bang 40 | Huyền Thủy Địa Quyết (8) | Deep Pearl; Hidden Pearl; Reflected Moon; Moon over the Tide | The pearl mistress of the moon lake: tide-and-moon Water arts and a nose for every pearl and fortune in the water |

## Vạn Hác Viện

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| ha_thinh_tung | Hà Thính Tùng | Kết Đan late | moc 74, phong 60 | Verdant Cycle Scripture (Thanh Hoàn Kinh) (9) | Zither Song; Zither String; Bamboo Flute; Pine Resin | The zither master of ten thousand valleys: songs that march and lull, pine and bamboo, the Tùng Phong Cầm in his hands |

## Thải Chi Cốc

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| nghiem_linh_chi | Nghiêm Linh Chi | Kết Đan middle | moc 80, thuy 58 | Verdant Cycle Scripture (Thanh Hoàn Kinh) (8) | Hundred Herbs Kept Alive (cap); Spirit Garden (K); Forest Floor; Herb Seed | The valley-mistress of the herb fields: a patient, compassionate grower and brewer who keeps her herbs alive in the bag |

## Lãng Đào Môn

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| giang_cuu_khuc | Giang Cửu Khúc | Kết Đan middle | thuy 76, moc 54 | Huyền Thủy Địa Quyết (8) | Grand Canal; Spirit Canal; River Spirit; River Lotus | The river-fleet master: canals, river spirits and an anchor, a brave and greedy toll-keeper whose ferries burned |

## Bình Thủy Môn

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| bui_phieu_binh | Bùi Phiêu Bình | Kết Đan late | thuy 74, phong 58 | Gale Courier Scripture (Phong Sứ Kinh) (9) | Blink Mark (cap); Boundless Sea (K); Misty Rain; Cardinal Points | The strait-crossing master: wind in the sails and the sea under him, fast, slippery and always somewhere else by morning |

## Mục Vân Trang

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| khau_muc_van | Khấu Mục Vân | Kết Đan middle | tho 70, moc 40, phong 64 | Mountain Heart Canon (Sơn Tâm Kinh) (8) | Ten Thousand Beasts, One Heart (cap); Beast Soul Union (cap); Solid Ground; Beast Pen | The horse lord of the plain: a sturdy Earth body and a herd that runs on the wind, his spirit foal first among them |

## Thiên Bảo Trai

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| phan_vat_hoa | Phan Vật Hoa | Nguyên Anh middle | kim 84, tho 66 | Hậu Thổ Thiên Kinh (11) | Hundred Refinements (K); Treasure Nurtured Within (cap); Spirit Coin; Bronze Spade | The treasure-market mistress: every point bought for refining and treasure, one nurtured artifact grown inside her for centuries |

## Nam Phố Đường

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| chau_phi_van | Châu Phi Vân | Kết Đan middle | thuy 76, moc 66 | Huyền Thủy Địa Quyết (8) | Endless Talismans (cap); Thousand Talismans (K); Ink Trace; Ink Pool | The hall-mistress of scribes: a devout talisman maker who fights with nothing but talismans, and rarely spends one |

## Xuyên Lâm Môn

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| uc_diep_thanh | Úc Diệp Thanh | Kết Đan early | moc 70, hoa 40, kim 38, loi 58 | Lôi Đế Chân Kinh (7) | Flash Step; Thunder Step; Lightning Dodge; Cloud Soaring | The rain-forest guide: a thunder staff and flash-step footwork, honest and stubborn, a step ahead of every strike |

## Hồng Đậu Trang

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| nghe_hong_dau | Nghê Hồng Đậu | Kết Đan late | moc 82, thuy 44 | Thanh Mộc Địa Quyết (9) | Strangling Vines (K); Ten Thousand Poisons (K); Venom Surge; Serpent Fang | The red-bean mistress: charming at the door and pure poison behind it, every stack of venom made to ripen and strangle |

## Lê Hoa Am

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| thai_le_tuyet | Thái Lê Tuyết | Kết Đan late | thuy 74, bang 76 | Winter Toll Canon (Đông Toán Kinh) (9) | Frost Seal (K); First Frost; Snow Lotus; Frost Bloom | The abbess of the pear-blossom hermitage: a compassionate teacher with a moonrime sword and snow-lotus ice |

## Trạc Anh Đài

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| doan_thanh_lang | Đoàn Thanh Lãng | Kết Đan early | thuy 72, kim 56, bang 42 | Hunter's Reach Canon (Liệp Trình Kinh) (6) | Ebb Tide (K); Whale Drinks; Fish Through the Net; Leaping Fish | The frost-coast sea hunter: a harpoon art that pins and drags, a humble, diligent body hardened by cold water |

## Dạ Quang Môn

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| hang_da_boi | Hạng Dạ Bôi | Kết Đan middle | kim 74, hoa 72, huyet 60 | Nine-Temper Scripture (Cửu Luyện Kinh) (6) | Blood Commands Spirit (cap); Ring Sabre; Sweeping Sabre; Horse-Cutting Sabre | The desert raider who knelt and did not forget: blood sabres that cut the horse first, wrathful offence paid in his own blood |

## Hồng Lô Cốc

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| dong_hong_lo | Đồng Hồng Lô | Kết Đan late | hoa 84, moc 58 | Red Sun Scripture (Xích Nhật Kinh) (9) | Divided Furnace Flame (cap); Alchemist's Heart (K); Furnace Heart; Pill Cauldron | The furnace that never cools: the continent's best alchemist, two recipes in one season over volcanic fire |

## Vân Khởi Quán

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| tong_toa_van | Tống Tọa Vân | Nguyên Anh late | tho 76, moc 72 | Thanh Mộc Địa Quyết (12) | Embryonic Breath (cap); Unwavering Faith; Gate of Faith; Unshaken Heart | The last student of the empty mountain: an unshakable Dao heart, cloud-watching faith and centuries of closed-door years |

## Trúc Thực Viên

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| ninh_truc_thuc | Ninh Trúc Thực | Kết Đan middle | moc 80, hoa 54 | Verdant Cycle Scripture (Thanh Hoàn Kinh) (8) | Spirit Garden (K); Hundred Herbs Kept Alive (cap); Bamboo Grove; Bamboo Joint | The bamboo breeder: the continent's best spirit farmer, his fields and his bamboo grove are the whole of his build |

## Lễ Tuyền Phái

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| mai_le_tuyen | Mai Lễ Tuyền | Kết Đan late | thuy 76, moc 62 | Still Moon Tide Scripture (Tĩnh Nguyệt Triều Kinh) (8) | Sun and Rain (K); Brimming Cup; Nourishing Rain; Water Wears Stone | The healer of the sweet springs: a brimming cup of spirit wine, gentle rain and endless regeneration |

## Phần Vũ Đường

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| hung_phan_vu | Hùng Phần Vũ | Kết Đan early | hoa 76, tho 70 | Mountain Heart Canon (Sơn Tâm Kinh) (7) | Nirvana (K); Fired Clay; Kiln Mouth; Kiln Hill | The vent-tempered body: a brave, impatient brawler who stands in the lava, burns, and gets back up |

## Thu Phần Các

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| ly_han_bich | Lý Hận Bích | Kết Đan late | thuy 60, tho 56, kim 48, am 72 | Canh Kim Địa Quyết (8) | Night Eye; Wandering Soul; Moth Wings; Dust of Wings | The grave-ward mistress: a vengeful soul caster of autumn Metal who wards the graves, tolls her bell and curses from the dark |

## No sect

| Key | Name | Realm | Root | Main (layer) | Đạo Đồ targets | Why it fits |
|---|---|---|---|---|---|---|
| mac_quy_khu | Mạc Quy Khư | Hóa Thần late | kim 62, moc 64, thuy 74, hoa 66, tho 60, hon_don 86, bang 50, quang 44 | Hundred Arts Sage Canon (Bách Pháp Hiền Kinh) (12) | Utmost Yang (K); Utmost Yin (K); Twin Technique Cultivation (cap); Mutation Awakening (cap) | The oldest man alive: a Primordial Chaos root from before the sects, fire and snow, Yin and Yang, time held still |
| tu_khong_hac_nien | Tư Không Hạc Niên | Nguyên Anh middle | kim 94 | Canh Kim Thiên Kinh (12) | Ten Thousand Swords Return (K); Keen Edge (K); Called Blow (K); Edge of Autumn | The lone crane: a pure Metal sword sage with nothing but the sword, every point spent on the edge, teaching no one |
| trieu_huyet_y | Triệu Huyết Y | Kết Đan middle | thuy 62, tho 46, kim 44, am 68, huyet 60 | Hollow Tide Scripture (Không Triều Kinh) (8) | Hidden Moon (K); Concealed Breath (cap); Great Essence-Draining Art (cap); Shadow Seed | The last disciple of Mặc Huyết Sinh: hidden, drained and draining, she grows by every cultivator she kills |
| lac_dan_thanh | Lạc Đan Thanh | Kết Đan late | hoa 80, moc 56 | Red Sun Scripture (Xích Nhật Kinh) (8) | Strange Pill Reborn (cap); Alchemist's Heart (K); Night Brew; Watching the Fire | The market alchemist who charges what he likes: pills no one else can make, and even his failures come out as pills |
| gia_hoi_xuan | Giả Hồi Xuân | Kết Đan middle | moc 78, thuy 60 | Verdant Cycle Scripture (Thanh Hoàn Kinh) (8) | Ageless Pine (K); Green Root; Weeping Willow; Spirit Berries | The apricot-blossom healer: a second spring for whoever others gave up on, needles, fruit and an ageless pine's regrowth |
| kim_van_ly | Kim Vạn Lý | Kết Đan late | kim 76, tho 60 | Hậu Thổ Địa Quyết (8) | Spirit Coin; Charm Coin; Horseshoe Gold; Hidden Cache | The richest merchant of the west: coins, caches and buried vaults, a gold root who buys his way and bets badly |
| doan_thuong_hai | Đoạn Thương Hải | Nguyên Anh middle | thuy 86, hoa 44, kim 48, loi 56 | Still Moon Tide Scripture (Tĩnh Nguyệt Triều Kinh) (12) | Rising Tide (K); Still Water (K); Dao in Dreams (cap); Sleeping Lotus | The blind survivor of a Hóa Thần tribulation: a still lake that hears every move and answers it, scarred against lightning |
| ve_van_co | Vệ Văn Cơ | Kết Đan early | tho 74, kim 60 | Hậu Thổ Địa Quyết (7) | Formation Within a Formation (cap); Portable Cave Abode (cap); Earth Vein Tap (K); Array Foundation | The formation master for hire: his arrays travel with him and stand wherever he is paid to stand them |
| lam_da_hac | Lâm Dã Hạc | Trúc Cơ middle | moc 66, kim 56 | Nine-Temper Scripture (Cửu Luyện Kinh) (4) | Wood Grain; Wood Root; Seedling; Bamboo Joint | The woodcutter's son with iron bones: an axe, a body that will not break, and no sect to teach him |

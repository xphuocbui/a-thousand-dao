# 2. New Techniques, Enablers and Effects

Everything the builds add that isn't a stacking modifier or an item: the enablers that make a build possible, công pháp, arts, Đạo, linh căn, tree clusters, wards and new rules. Proposals only.

## Words used below

- **Points (+12 points):** added to one of the five damage layers L1 to L5, which multiply together. L1 is ordinary increased damage; L2 to L5 are rarer and stronger.
- **c_art:** an art's damage multiplier. **cost:** its linh lực price, as a share of your maximum pool. **s:** its cooldown in seconds.
- **Pulse:** the once-a-second beat of a fight, when ticks and wards are paid.
- **Ward:** the linh lực shield. A **drain** ward pays per damage blocked, a **per-hit** ward a fixed fee per hit, a **per-pulse** ward a fixed fee per second.
- **Tick:** damage over time: burns, poisons, bleeds.
- **Art lint:** the rule that caps an art's damage for its cost and cooldown.
- **Foreseen fight:** one you prepare for, as opposed to a blind ambush.
- **Fit:** Fits today = works with the game as it is. Needs key = needs a new data field. Needs rule = needs a new combat or system rule.

## Enablers (26)

The one piece that makes a build possible. Most change a rule, and most close something off as their price.

| Name | What it does | Fit | Build |
|---|---|---|---|
| **Already Waited** (Dĩ Đãi) | At each pulse heart demon pays one art's timer, the next in slot order, at 1 per second left; it fires this instant at its normal linh lực cost. Closes your seasons: see The Owed Wait. | Needs rule | Already-Waited |
| **Bitter Tithe** (Khổ Thuế) | Poison-tag arts cost đan độc, not linh lực, and what is spent stays gone. Closes: cleansing pills no longer work on you. | Needs rule | Taster's Fever |
| **Borne Body** (Tá Thể) | The side's health, n_body and guard are the first puppet's in slot order, its blow is the companion channel, and when it falls the next walks on at full health, leaving statuses and curses behind. Closes the operator's own body and an art slot a puppet. | Needs rule | Puppeteer |
| **Both Sides** (Song Phương Thệ) | Arts may restore a share of maximum health. Closes: the same share goes to the other side, and a heal cannot be aimed. | Needs rule | House Call |
| **Census Seal** (Hộ Bạ Ấn) | Named an artifact from a mortal throne. Opens levy rows in Formulas K. Closes: no sect will hold you, and each 1,000 levy lost adds +1 heart demon, which the Nascent Soul gate reads. | Needs rule | Ant General |
| **Cut Fuse** (Tiệt Dẫn) | A pill rolled in wax acts in a window of the fight, with an onset and length in whole pulses, for +2 toxicity. Closes: doses cannot change, and a blind fight has none. | Needs rule | Pill Glutton |
| **Feeding-Back Ward** (Phản Bộ Hộ) | A per-hit ward that also returns blocked damage to the attacker's linh lực, 1.0 per point; past their maximum it becomes Surfeit. | Needs rule | Great Tonic |
| **Ground Law** (Địa Luật) | A laid formation carries one law moving listed Combat keys for one fight, for both sides. Closes: nothing in a blind fight, and the years reset if you leave. | Needs rule | Level Ground |
| **Incense Vow** (Hương Thệ) | A stalemate is a win when the other side opened the fight. Closes: your hits deal nothing, and you cannot start a fight. | Needs rule | Incense Vigil |
| **Lightning Rod** (Thu Lôi) | A Ground Law: on ground tagged tribulation, every art hit by the other side carries Thunder and no other element, counted as Fire for the cycle. Closes: nothing anywhere else. | Needs rule | Drink the Lightning |
| **Moved Sickness** (Di Bệnh) | Curses from your own life have no duration on you. An art with the cleanse tag sends them to the target; when one ends, is cleansed or is pushed out it comes home. You can never clear them yourself. | Needs rule | Stand-In |
| **Open-Door Furnace** (Khai Môn Lô) | New artifact base dan_lo, attack 46, defence 20, thần thức 30. Opens Five Courses. Closes: a loaded coating serves nothing else, blind nothing can be loaded, and the art ends with the meal. | Needs key | Wedding Furnace |
| **Paid in Advance** (Tiên Phó) | A talisman keeps its authored cost for the art lint and pays no linh lực when fired. Closes every art but talismans. | Needs rule | Spring Hand |
| **Promissory Paper** (Khế Trái Phù) | A talisman, stock used up: Slow Wound at share 1.0 for this fight, from the instant it fires. Closes: every fight costs a rare sheet, and with none left an old bill lands whole. | Needs rule | Best Plan |
| **Recall Banner** (Thu Binh Kỳ) | Named artifact, ky base. Lifts equip.max_slots; each piece flies on its own timer for no slot and no linh lực. Closes all artifact defence, removes thần thức in flight from soul defence, and a soul hit grounds everything for soul_lockout. | Needs rule | Remnant Host |
| **Seal of Full Payment** (Túc Phó Ấn) | Named artifact, an base. Arts and the ward may be paid in spirit stones; linh lực pays for nothing; carried stones show on your profile; a winner who takes you takes the seal. | Needs rule | Full Price |
| **Sown Field** (Hoạt Lũng) | At t = 0 each plot you sow is a permanent tick on the enemy, c_tick 0.04 x the herb's potency. Closes: your basic attack, 1 % of linh lực per plot for the fight, and the plot, whose herb dies. | Needs rule | Good Year |
| **Stele-Rubbing Scripture** (Thác Bi Kinh) | Secret art, Thiên giai, Water. Grants Rubbings, arts that take c_art, kind and tags from the enemy art fired that instant. Those slots hold nothing of your own. | Needs rule | Brush Fee |
| **The Copyist's Error** (Sao Ngộ) | While the Spent Kiln Sutra is main, every great breakthrough attempt fails with no roll, needs no pill and ignores bare_attempt_cap; each failure leaves a Gate Scar. | Needs rule | Turned-Away |
| **The Named Heir** (Lập Tự) | A rider on The Set Day: name a disciple, and at death continue as them in the same world, with the Book, the tally and one mask per dead head. Closes your tree, your realm and your player edge. | Needs rule | Heir |
| **The Received Years** (Thụ Niên) | The person named on a Set Day, while the giver lives: the years received become a wick that blows and terror burn, and an art's first firing at them turns. Closes any cultivation. | Needs rule | Mortal |
| **The Tasting Book** (Phẩm Thực Lục) | A soul-bound register. Opens Eaten Power and Clean Kill. Closes pills and seclusion for life, through Spoiled Palate. | Needs rule | Not-Yet-Full |
| **The Understudy** (Thế Thân) | Evade is never rolled. Each body or qi hit fills the Curtain by p_evade times min(1, your thần thức / theirs); at 1 or more it pays 1 and the hit lands on the double: nothing dealt, nothing drained, no on-hit trigger, their cost stays paid. Holds 2. Closes all but one light artifact and any ward gear. | Needs rule | Understudy |
| **Vow of the Open Hand** (Khai Thủ Thệ) | Catching Hand holds one catch per empty slot and Empty Hand counts every empty slot; any slot that holds an art after the Vow is stained for life and never counts as empty again. | Needs rule | Receiving Hand |
| **Wash the Dust** (Tẩy Trần) | A cleanse aimed at the target. Closes your own L2 to L5. | Needs rule | Welcome Bath |
| **Water Table** (Thủy Mạch) | Of the linh lực a target's ward pays for your hit, you gain 0.36, up to your maximum. Closes: your linh lực does not regenerate in a fight. | Needs rule | Deepest Well |

## Công pháp (techniques) (62)

Main and secret techniques. Their stat bonuses, the arts they teach and the clusters they unseal.

| Name | What it does | Fit | Build |
|---|---|---|---|
| **Ash Almanac** (Hôi Lịch) | Secret, tier 2, Fire, no bonuses. Holds Smoulder and Bed of Coals, with their Burning as a qi tick. | Needs key | Swidden Road |
| **Attendant's Manual** (Dục Sự Pháp) | Main, tier 1, names Water, no bonuses, gives three arts. | Needs key | Welcome Bath |
| **Baggage Sutra** (Hành Trang Kinh) | Main, Huyền giai, Earth and Metal, no bonuses, +40 L2 on Earth and Metal arts. Lists Plain Cut, Seam Thrust, Long Draw and Falling Lintel. | Needs key | Three Shirts |
| **Bath-Keeper's Note** (Dục Đường Ký) | Secret, tier 1, Fire and Earth, no bonuses, no arts. Carries one Ring Step: all of a Fire hit to Earth. | Needs key | Five Hot Stones |
| **Block-Stone Method** (Châm Thạch Công) | Body, Thiên giai. t_b 3 and Still Water. | Needs key | Fortieth Breath |
| **Bottomless Sutra** (Vô Để Kinh) | Main, Địa giai, Earth. Carries the five arts and First Taste, and seals High Table. | Needs key | Not-Yet-Full |
| **Clear Vat Canon** (Thanh Hang Kinh) | Main, names only Wood, no bonuses, seals The Clear Vat, gives Falling Drop. | Needs key | Indigo Drop |
| **Daily Lesson Canon** (Nhật Khóa Kiếm Điển) | Main, Huyền giai, Metal. tam_ma_resist_pct 10. Passive Full Title. Three Held-line arts. | Needs key | Daily Lesson |
| **Deep Bore Sutra** (Thâm Toản Kinh) | Main, Địa giai, Earth and Water. Carries Water Table, Scraping the Well, Head of Water, five arts, and seals Dry Courses. | Needs key | Deepest Well |
| **Eight-Legged Method** (Bát Cổ Công) | Main, Huyền giai, Metal. linh_luc_pct 12, tam_ma_resist_pct 10. Unlocks the two topic arts. | Needs key | Clever Harm |
| **Evergreen Canon** (Trường Thanh Kinh) | Main, Thiên giai, Wood. Passive: +20 points to Wood arts. Three arts, and Thorn on a second form of each for the Bramble. | Needs key | Evergreen Road |
| **Ferry-Rope Sutra** (Độ Lãm Kinh) | Main, Địa giai, Water. linh_luc_pct 20, khi_huyet_pct 15, attack_pct 15. Five arts, seals Cold Landing. | Needs key | Already-Waited |
| **First Load Method** (Sơ Đảm Công) | Body, Hoàng giai, 6 layers, no element. Volume I of the ladder: Even Step, Shifted Pole, Longer Breath, Sustained Note. | Needs key | Long Carry |
| **Five Dregs Sutra** (Ngũ Trọc Kinh) | Main, Thiên giai, names only the Dull Root, so it runs at the root's purity. | Needs key | Worst Root |
| **Forty-Breath Sentence** (Tứ Thập Tức Án Kinh) | Main, Thiên giai, Metal. Grants Last Word, Measured Stroke and Final Clause, and seals Standing Post. | Needs key | Fortieth Breath |
| **Furrow Scripture** (Lũng Điền Kinh) | Main, Thiên giai, Wood and Earth. herb_growth_pct 10, khi_huyet_pct 15, linh_luc_pct 20. Unlocks Sown Field and Scythe Day. | Needs key | Good Year |
| **Grindstone Primer** (Ma Thạch Thiên) | Main, Huyền giai, Metal. Passive: +20 points to Metal arts. Four arts. | Needs key | Grindstone Road |
| **Hundred Vessels Canon** (Bách Mạch Tư Dưỡng Kinh) | Main, Địa giai, Wood and Water. A dosing manual that treats only what travels the channels, so it has no answer to poison or the soul. | Needs key | Great Tonic |
| **Hundred-Mask Libretto** (Bách Diện Hí Bản) | Main, Địa giai, Water. linh_luc_pct 20, than_thuc_pct 15. Unlocks the five arts. | Needs key | Understudy |
| **Keeping-House Sutra** (Trì Gia Kinh) | Main, Địa giai, Fire and Earth. Four household arts, all paid in linh lực. | Needs key | Given Years |
| **Lamp-and-Thread Sutra** (Đăng Ti Kinh) | Main, Địa giai, Wood, linh_luc_pct 20, than_thuc_pct 15. Carries Borne Body. | Needs rule | Puppeteer |
| **Long Day Frame** (Trường Nhật Thể) | Body, Thiên giai. t_b 2 at full mastery, a first guess. | Needs key | Rice Pestle |
| **Long Firing Method** (Trường Thiêu Công) | Main, Huyền giai, Earth. tam_ma_resist_pct 15. Carries Falling Lintel, Settling Wall and +40 L2 on Earth arts. | Needs key | Long Firing |
| **Long Slope Scripture** (Trường Pha Kinh) | Body, Địa giai, 12 layers, no element. Volume III: Second Wind; handover at layer 10. Not run. | Needs key | Long Carry |
| **Low Flame Method** (Vi Hỏa Quyết) | Main, Thiên giai, Fire. tam_ma_resist_pct 15, lifespan_years 15. +40 L2 on Fire arts. Teaches the seven lamps. | Needs key | Seven Lamps |
| **Mirror Hall Sword Canon** (Kính Điện Kiếm Điển) | Main, Địa giai, Metal. attack_pct 15, khi_huyet_pct 15. Three arts, Full Title, The Answer, Losing Face, seals Gilt Line. | Needs key | Loud Sword |
| **Night-Sitter's Method** (Thủ Dạ Quyết) | Main, Hoàng giai, Wood, no bonuses. Carries the three sicknesses. | Needs key | Held Door |
| **One Ladle Rule** (Nhất Chước Quy) | Main, Thiên giai, Water. tam_ma_resist_pct 15, lifespan_years 15. Carries both ladle arts and +40 L2 on Water arts. | Needs key | One Ladle |
| **Packed Clay Method** (Hãng Thổ Công) | Body, Huyền giai, no element. t_b 2 at full mastery. | Needs key | Long Firing |
| **Paddy Keeper's Canon** (Thủ Điền Kinh) | Main, Thiên giai, Earth and Water. Ditch in four forms and Rising Water, all laid, seals Bund and Channel. | Needs key | Level Ground |
| **Paper Kite Manual** (Chỉ Diên Phổ) | Main, Địa giai, Metal. Carries Running Line and four soul arts, seals Paper Sky. | Needs key | Cut Line |
| **Plain Speech Method** (Trực Ngôn Công) | Main, Huyền giai. Linh lực +20, health +15, +10 L2 on the method's arts. Carries the seven arts. | Needs key | One Long Word |
| **Plough-Song Method** (Canh Ca Quyết) | Main, Hoàng giai, Earth. lifespan_years 15. A rhythm for walking behind an animal. Seals Old Yoke. | Needs key | Herd-Child |
| **Pounding Rule** (Đảo Quy) | Main, Thiên giai. Carries Pounding Stroke and Lifted Pestle, +40 L2 on body hits, the typical anchor. | Needs key | Rice Pestle |
| **Recruit's Drill Manual** (Tân Binh Điển) | Main, Huyền giai, Metal. linh_luc_pct 20, khi_huyet_pct 7. Carries Dull Fortune. No arts. | Needs key | Lucky Fool |
| **Refectory Rule** (Trai Đường Quy) | Main, Địa giai, Earth. linh_luc_pct 20, defense_pct 15, khi_huyet_pct 7. Four courses, Gorged and Still Water. Stops at Nascent Soul. | Needs key | Drink the Lightning |
| **Roll-Call Method** (Điểm Binh Quyết) | Main, Địa giai, Metal. No arts. Carries Drilled Ranks and seals Many Threads. | Needs key | Remnant Host |
| **Scale-Knife Method** (Quát Lân Đao Pháp) | Main, Huyền giai, Metal and Water. Scaling Stroke in three forms and Rub Salt, seals Open Seams, stops at Core Formation. | Needs key | Thousand Scales |
| **Scion Method** (Tiếp Mộc Quyết) | Main, Địa giai, names Wood. Holds the three arts. | Needs key | Transplant |
| **Scraped Register Sutra** (Tước Bạ Kinh) | Main, Địa giai, Water. Four arts, seals Struck Register. | Needs key | Struck Name |
| **Seam-Water Method** (Mạch Thủy Quyết) | Main, Huyền giai, Earth, linh_luc_pct 20. Seals Slow Wax. | Needs key | Pill Glutton |
| **Severed Wheat Sutra** (Đoạn Mạch Kinh) | Main, Địa giai, Earth and Metal. Carries the arts, re-lists Closed Gate, seals Hungry Courses. | Needs key | Corner |
| **Sickness-Moving Sutra** (Di Bệnh Kinh) | Main, Địa giai, Wood and Fire. Carries Moved Sickness, Purge, Bile, Phlegm, seals Hundred Ills. | Needs key | Stand-In |
| **Spent Kiln Sutra** (Phế Diêu Kinh) | Main, Địa giai, Fire and Earth. A firing manual with one reversed line, which is why nobody under it has ever passed a gate. Carries The Copyist's Error and Turned Away. | Needs rule | Turned-Away |
| **Spring Couplet Method** (Xuân Liên Quyết) | Main, Địa, Fire. Carries Paid in Advance, slots hold paper only, seals Red Paper Street. | Needs rule | Spring Hand |
| **Standard-Bearer's Method** (Chấp Kỳ Quyết) | Main, Địa giai, Earth. linh_luc_pct 12, khi_huyet_pct 8. Two arts, Spear Drill, seals Drum Line. | Needs key | Ant General |
| **Standing Stele Sutra** (Lập Bi Kinh) | Main, Địa giai, Earth and Wood. Carries Slow Wound, Years Owed and the three curses. | Needs key | Incense Vigil |
| **Taster's Canon** (Thí Độc Điển) | Main, Địa giai, Fire and Water. Carries Bitter Tithe and the three arts. | Needs key | Taster's Fever |
| **Ten Thousand Steps Scripture** (Vạn Bộ Kinh) | Body, Thiên giai, 15 layers, no element. Volume IV: Hill Road; handover at layer 13. Not run. | Needs key | Long Carry |
| **Thirty-Six Exits** (Tam Thập Lục Lộ Quyết) | Secret, Huyền giai, Water. Carries Cold Feet, Full Sleeve, Folded Corner, Skipped Bill, Dies Later and Goat in Passing, and seals Hidden Doors. | Needs key | Best Plan |
| **Two Baskets Method** (Song Lam Công) | Body, Huyền giai, 9 layers, no element. Volume II: Home Road, Thrift, Setting Down, Over the Ridge; re-lists Volume I's arts at layer 7. | Needs key | Long Carry |
| **Two Heats Manual** (Nhị Hỏa Thiên) | Main, Địa giai, Fire. Six plain arts and Bare Vessel, lesser grade. One technique serves both roads. | Needs key | Fierce Fire Road |
| **Two-Bowl Canon** (Song Bát Kinh) | Main, Thiên giai, all five elements, so every auxiliary art with an element runs at x0.60. Four ring arts, Banked Heat, Ring's Weakest and Still Water. | Needs key | Kept Hearth |
| **Two-Column Materia** (Lưỡng Lan Bản Thảo) | Ordinary tier 2 secret technique with no bonuses. Carries the three arts. | Needs key | Second Sickness |
| **Under the Roots Method** (Căn Hạ Quyết) | Main, Hoàng giai, names only the Cicada Root. Holds the three arts. | Needs key | Thirteenth Summer |
| **Waiting Hands Method** (Đãi Thủ Pháp) | Body technique, Thiên giai, with no arts in it by design; lists Callus Road. | Needs key | Receiving Hand |
| **Walking Stick Method** (Trượng Hành Quyết) | Main, Địa giai, Earth. tam_ma_resist_pct 15, lifespan_years 15. +40 L2 on hits with the beast form. Teaches no art. | Needs key | Guide Hound |
| **Warm Hands Method** (Ôn Thủ Pháp) | Main, Địa giai, Water. khi_huyet_pct 15, linh_luc_pct 20. Unlocks the three arts. | Needs key | House Call |
| **Watch Rule** (Vọng Quy) | Main, Địa giai. Carries The Look. On the Walk-Down Line also Stamping Foot and Beating Branch, and +40 L2 on hits. | Needs key | Third Look |
| **Wedding Hearth Sutra** (Hỉ Táo Kinh) | Main, Địa giai, Fire. Low Flame; three courses at layer 4, five at layer 7, Boiled Over at layer 9. Has no chapter on eating in a hurry. | Needs key | Wedding Furnace |
| **Weights and Measures Sutra** (Cân Lượng Kinh) | Main, Thiên giai, Metal. Abilities Earnest Money, Buyout, Ruinous Offer; lists Counting Beads. | Needs key | Full Price |
| **Whetstone Dew Page** (Lộ Ma Thiên) | Secret, tier 1, Metal and Water, no bonuses. Holds Plain Cut and Long Draw, and carries one Ring Step: all of a Metal hit to Water. | Needs key | Dew on the Blade |

## New rules and concepts (35)

Ideas the builds need that no system has yet.

| Name | What it does | Fit | Build |
|---|---|---|---|
| **A Ground Law may set an element** | A tag every art hit on the ground carries, replacing its own. Combat rules 6 and 12; Thien-kiep rule 5. Serves Kept Hearth at home and any element gate. | Needs rule | Drink the Lightning |
| **A roll that remembers** (Hạn) | A failed chance adds itself to a count that makes the next one certain. Combat rule 15, Formulas I. Serves any crit or status build that wants to be readable, and escape. | Needs rule | Lucky Fool |
| **A ward on the other person** (Cách Ly) | A ward may stand around the enemy, paid only by its holder. Rule 22. | Needs rule | Held Door |
| **Art costs in a life stat** | An art may name a cost_resource other than linh lực or health. Combat rules 13 and 14, Formulas E; Character Stats rule 7. | Needs rule | Taster's Fever |
| **Bare hit** (Vô Danh Kích) | A hit with no kind and no tags. Combat rule 4, Formulas C and D. | Needs rule | Struck Name |
| **Brood Year** (Thiền Niên) | One year in thirteen, world-wide, every holder wakes for four seasons. Sleeping through a waking keeps paying, up to 3 cycles. | Needs rule | Thirteenth Summer |
| **Chronic affliction** (Cố Tật) | A curse owned by a character, compiled from a real state, with no duration on its owner. Combat rule 8, Formulas F, Character Stats. | Needs rule | Stand-In |
| **Cornered Market** (Lũng Đoạn Thị) | A caller may lower a resident's starting linh lực share before a foreseen fight at a place you hold: 1 - n_plots / 16, never below 0.25. Combat rules 3 and 12, Event Engine. | Needs rule | Corner |
| **Debt** (Nợ) | Spirit stones may fall below 0 through On Credit, with interest, heart demon and a collector. Also serves a creditor build and a build borrowing from its future. | Needs rule | Full Price |
| **Deferred damage** | A ledger of hit damage paid at the pulse on its own cap. Combat rules 4, 14, Formulas C, F. | Needs rule | Incense Vigil |
| **First tribulation pool** (Kiếp Trì) | Seven boss sketches inside Formulas D: Iron Thunder, Thousand Needles, White Silence, Sour Cloud, Dry Wind, Held Breath, and Closed Mouth, the boss that tests this build. Typical 0.500, top-end 1.000 on the first six. | Needs key | Drink the Lightning |
| **Flight** (Ngự Bảo) | Damage from each equipped piece on its own timer, outside the art slots. Combat rules 3 and 13, Item Database rule 11. | Needs rule | Remnant Host |
| **Gate Scar** (Quan Ngân) | A saved count of failed great breakthroughs for every character, reset by a success. Does nothing without a piece that reads it. | Needs rule | Turned-Away |
| **Ground Law** (Địa Luật) | Combat rule 12 and a list of movable keys in Formations. Serves gate arrays, boss arenas, secret realms and tribulation preparation. | Needs rule | Level Ground |
| **Healing inside a fight** (Trận Trung Trị Liệu) | A heal effect on an art, with a first lint of heal_share at most 2 x cost_share, and one sentence in Thien-kiep rule 7: health restored inside a wave carries. | Needs rule | House Call |
| **Heart demon in a fight** (Tâm Ma Lâm Trận) | A fight can spend and raise heart demon, reported to Character Stats like vitality loss. Combat rules 2 and 14, Character Stats rule 8. | Needs rule | Already-Waited |
| **Kin tie** (Thân Duyên) | A named person bound by marriage, blood or adoption, beside Quests' master and disciple ties. | Needs rule | Given Years |
| **Kite Season** (Diên Tiết) | A season action: -2 heart demon, no cultivation. | Needs key | Cut Line |
| **Levy** (Hương Dũng) | A member row in Formulas K for mortals, who are not simulated. Combat rule 17, Formulas K. Also serves a sect arming its villages and a mortal rebellion as a world event. | Needs rule | Ant General |
| **Merged self-hit rule** (Phản Thủ Luật) | One rule replaces Slip of the Hand's and Turned Hand's copies: a turned art pays, and its hit resolves on its owner at the same size and M, through their own ward and guard, with no suppression, at most 25 % of their maximum health. Basic attacks, companions, ticks and arts with no hit never turn. Three doors decide when: the fortune roll, the curse, The Received Years. | Needs rule | Mortal |
| **Mimic art** (Mô Pháp) | An art record with no content that takes its coefficient, kind and tags from the enemy art fired that instant, plus a source tag, copied. Combat rules 6, 10, 13. | Needs rule | Brush Fee |
| **Mortal Body** (Phàm Thân) | A side the caller creates for one fight: no linh lực, no ward, no arts, a power term below Qi Refining (power 10 as a first guess). Carries Plain Blow. Combat rule 23, Realms. | Needs rule | Mortal |
| **Puppet** (Khôi Lỗi) | One record that is an artifact and a beast, so both tag families apply. Combat rule 19, Item Database rule 6. | Needs rule | Puppeteer |
| **Rejection** (Bài Dị) | Purity of a graft falls by 6 + donors fed each decade. Feeding a same-element donor gives +round(0.25 x donor purity). The need doubles about every 85 years. | Needs rule | Transplant |
| **Shared Years** (Cộng Thọ) | A beast has a lifespan by its realm, and its owner may give it years of their own. Each 1 % of health it loses in a fight costs it 1 year. | Needs rule | Herd-Child |
| **Size** (Tỉ Lệ) | A fight value on a side that scales its fight unit and both pools, bounded at 20 %. | Needs rule | Empty River |
| **Succession** (Kế Tự) | A mode of Codex & Karmic Carryover (#12): with a Named Heir alive at your death, the next life continues as them in this world. Passes Book, tally, half of Eaten Power, masks, stones and heirlooms. Heart demon, tree and the player's edge stay behind, and the heir crosses gates on their NPC edge score. | Needs rule | Heir |
| **Surfeit** (Ứ Khí) | Linh lực forced into a full pool, held as a share of qi_max up to 100 %. A forced gain is at most the pool the target holds, so the empty cannot take tonic. | Needs rule | Great Tonic |
| **The Creditors' Book** (Trái Chủ Bộ) | A per-life list of creditor and share. Against a creditor the share stands in the ledger at t = 0, and lands whole at the first pulse if no Slow Wound runs. An entry ends with the creditor's life. | Needs rule | Best Plan |
| **The Curtain** (Mạc) | A keystone may replace one chance roll with a counter that fills at the roll's chance, so a build can rest on it without breaking rule 15. | Needs rule | Understudy |
| **The Reckoning** (Thanh Toán) | Cultivators defeated is a public number. At each threshold NPC loadouts change, and at 1,000 the Event Engine sends hunters in a run with Tribulation's carry-over rules. | Needs rule | Not-Yet-Full |
| **Timed dose** (Định Tễ) | A pill with an onset and a length in whole pulses. Combat rule 12, Item Database Open Question 7. | Needs rule | Pill Glutton |
| **War Chest** (Quân Khố) | A stock of stones prepared for a clash. An Indemnity Ward on a levy costs 1 stone a soldier a second, and falls when it empties. | Needs key | Ant General |
| **Ward phase** (Hộ Hành) | A ward holds one element. A hit that generates it is Fed. Combat rule 22, Formulas D. Also serves any element ward and a healer who stands in a phase for an ally. | Needs rule | Kept Hearth |
| **Winning by standing** | A stalemate can be a win for the side that did not open the fight. Combat rule 14, Edge Cases, AC-CB-62. | Needs rule | Incense Vigil |

## Đạo (Ways) (11)

New Ways. Full trees are in `daos/`.

| Name | What it does | Fit | Build |
|---|---|---|---|
| **Illusion** (Huyễn Đạo) | Water at purity 30. theme_stats evade_pct, than_thuc_pct, linh_luc_regen_pct, mi_luc. Branches The Mask, The Script, The House. Keystone The Understudy. 20 nodes. A tree for the catalogue entry that has none. | Needs key | Understudy |
| **Poison** (Độc) | Requirement Fire and Water at purity 30, or Cinnabar. Branches The Tongue, The Fever, The Dregs. Keystone Fever. | Needs key | Taster's Fever |
| **Way of Chance** (Cơ Duyên Đạo) | Requires fortune 70 or a Void root at purity 30. theme_stats khi_van, evade_pct, status_resist_pct. Branches The Slip, The Pot, The Road Out. Keystone Slip of the Hand. 20 nodes. | Needs key | Lucky Fool |
| **Way of Generation and Overcoming** (Sinh Khắc Đạo) | Requires all five base elements at purity 10. theme_stats element_affinity_pct, conversion_share_pct, element_ward_pct. Branches The Feeding Ring, The Checking Ring, The Turned Ring. Keystone Turning Phase. 20 nodes, 258 W. | Needs key | Kept Hearth |
| **Way of Ink** (Mặc Đạo) | Requires a secret technique. theme_stats than_thuc_pct, ngo_tinh, tam_ma_resist_pct. Branches Rubbing, Ledger, Archive. Keystone Brush Fee. 20 nodes. | Needs key | Brush Fee |
| **Way of Keeping** (Thủ Đạo) | Requirement Earth at purity 40 and a body technique. Branches The Gate, The Held Breath, The Long Count. Keystone Incense Vow. | Needs key | Incense Vigil |
| **Way of Trade** (Thương Đạo) | Requires Metal at purity 40. Branches The Scale, The Road, The Ledger; keystone Priced Above the Sea. | Needs key | Full Price |
| **Way of the Bare Hand** (Xích Thủ Đạo) | Requires a body technique, no element. Branches Receiving, Striking, Waiting; keystone Vow of the Open Hand. Holds no art nodes. | Needs key | Receiving Hand |
| **Way of the Herd** (Mục Đạo) | Earth at purity 30. theme_stats khi_huyet_pct, linh_luc_regen_pct, art_speed_pct, body_guard_pct. Branches The Rope, The Song, The Field. Keystone Stands Over You. 20 nodes, no art nodes. | Needs key | Herd-Child |
| **Way of the Threshold** (Hạm Đạo) | Fire and Earth at purity 25. Branches Knock, Crack, Refusal. Keystone Cracked Perfection. | Needs key | Turned-Away |
| **Way of the Unnamed** (Vô Danh Đạo) | No requirement. theme_stats art_cost_pct, status_resist_pct, tam_ma_resist_pct, stealth. Branches Unsaid, Unseen, Unbound. 20 nodes. | Needs key | Struck Name |

## Đạo branches (5)

New branches added to existing or seed Ways.

| Name | What it does | Fit | Build |
|---|---|---|---|
| **Array, Field branch** (Trận Đạo, Điền Mạch) | Old Bund, Standing Water, Untended Field and Hoe Stroke, ending in Ground Law. | Needs key | Level Ground |
| **Array, Host branch** (Trận Đạo, Binh Mạch) | A branch of the Array Đạo holding Idle Hands and Overheat. | Needs key | Remnant Host |
| **Destruction, Wrath branch** (Hủy Diệt, Nộ Chi) | Thin Bleed (Sinew), Spillover, Unspent Rage, ending in Parting Cut. | Needs key | Thousand Scales |
| **Life, Tonic branch** (Bổ Chi) | Health and regeneration lines, Pill-Fed, keystone Deep Abscess, and an art node for Lancing. | Needs key | Great Tonic |
| **The Far Bank** (Viễn Ngạn) | Way of Space (Không Gian Đạo), a catalogue seed with no tree. Water at purity 40. Branches The Near Bank, The Middle Reach, The Far Bank. Keystone Far Distance. Only this branch's signature nodes are written. | Needs key | Empty River |

## Linh căn (spiritual roots) (6)

New roots.

| Name | What it does | Fit | Build |
|---|---|---|---|
| **Amber** (Hổ Phách) | Convergence of Wood and Earth. Per purity: +0.45 body_guard_pct, -0.10 cultivation_speed_pct. 11.5 W at purity 50, 23 W at 100. | Needs key | Incense Vigil |
| **Cicada Root** (Thiền Căn) | Innate, no parents, innate_chance 0.001. Per purity point: one buried season pays 0.2 s of one art's authored cooldown. Buried 12 years in 13, ageing at a quarter speed, a sleeping body with no arts or ward. Own sector as rule 12. Counts toward n_eff. Cost: nearly a whole life. | Needs rule | Thirteenth Summer |
| **Cinnabar** (Chu Sa) | Convergence of Fire and Water. Per purity: +0.60 pill_effect_pct, -0.20 dan_doc_resist_pct. 14 W at purity 50, 28 W at 100. | Needs key | Taster's Fever |
| **Dull Root** (Độn Căn) | Derived, reads its parents upside down. Needs n_base 3 or more, every element below 50; chance 1. Purity round(100 - 2 x mean purity), 1 to 80. Per element held: one part per hit. Per purity point: the line rises 0.05 % of the target's maximum health, attack_pct -0.5. Own sector as rule 12. Marrow-Cleansing Pills lower it. | Needs rule | Worst Root |
| **Grafted Root** (Di Thực Căn) | Grafted origin. A root cut from a donor of an element you lack, dead 3 days at most: purity round(0.9 x donor), operation chance 0.4 + donor / 200. Per purity point: pays 1 % of the cost of arts naming it, +0.5 L2 on them. Falls 6 + donors fed each decade; dies below 10; no sector of its own, reads the element's. Cost: rule 14 gone, +3 heart demon per donor. | Needs rule | Transplant |
| **Salt** (Diêm) | Transmutation of Earth. Per purity: +0.20 ward_draw_pct, +0.15 ward_efficiency_pct, -0.10 tam_ma_resist_pct. 15 W at purity 50, 30 W at 100. | Needs key | Deepest Well |

## Tree clusters (28)

Hidden and sealed clusters for the Meridian Map.

| Name | What it does | Fit | Build |
|---|---|---|---|
| **Bund and Channel** (Điền Thủy Mạch) | Theme formations and land, Earth, outer, sealed by a technique, size 10. Notables Known Ground and Deep Bund, capability Field Walls. | Needs key | Level Ground |
| **Callus Road** (Kiển Lộ) | Sealed, theme body cultivation, Earth, size 7: Basic attack damage, body guard, Ten Thousand Strikes. | Needs key | Receiving Hand |
| **Cold Landing** (Lãnh Độ) | Sealed, Heart State, Water, outer, size 10. Notables Every Blow, then Both Hands with Already Waited as its capability. | Needs key | Already-Waited |
| **Counting Beads** (Toán Châu) | Sealed, theme the Market economy, Metal, size 7: art cost, Metal damage, Full Sea. | Needs key | Full Price |
| **Drum Line** (Cổ Liệt Mạch) | Theme formations, Earth, outer, sealed by the Standard-Bearer's Method. Size 9. Notables Given to the Ranks, Rotating Ranks; capability Field Array. | Needs key | Ant General |
| **Dry Courses** (Can Mạch) | Linh lực and wards, Earth, outer, sealed by a technique, size 9. Notables Thrift, Rich Seam, Longer Breath. | Needs key | Deepest Well |
| **Evening Table** (Vãn Thực Mạch) | Longevity theme, Earth, outer, sealed by event: sit a last season with someone whose lifespan is ending. Size 8. Notables Short Wick and Nothing to Lose; keystone The Set Day as the capability. | Needs key | Given Years |
| **Examination Cells** (Hào Xá Mạch) | Theme comprehension and study, no element, inner, sealed by a technique, size 6. Notables Past Papers, Already Read. | Needs key | Clever Harm |
| **Furrow Line** (Lũng Mạch) | Theme spirit fields, Earth, outer, sealed by the Furrow Scripture, size 10. Notables Held Acres, Surplus, Rich Soil. Capability #14. | Needs key | Good Year |
| **Gilt Line** (Kim Tuyến Mạch) | Theme NPC Interaction and presence, Metal, outer, sealed by event: win twenty ticketed bouts. Size 10. Notables Shown Face, In Step, All Eyes; capability Called Blow. | Needs key | Loud Sword |
| **Green Room** (Hậu Đài) | Water, outer, sealed by a technique, size 10. Notables Returned Force and a second for Longer Breath's condition. Capability: a Cue guard on any art. | Needs key | Understudy |
| **Hidden Doors** (Ám Môn) | Sealed, Water, size 6, four Escape chance acupoints, notables Terror and Beneath Notice. Theme: escape. | Needs key | Best Plan |
| **High Table** (Thượng Tịch) | Sealed, Earth, size 8, Damage and Health acupoints, notables Varied Diet, Between Courses and Years at Table, capability #9 outermost. Theme: defeat. | Needs key | Not-Yet-Full |
| **Hundred Ills** (Bách Bệnh) | Curses and bad states, Wood, outer, sealed by a technique, size 9. Notable Virulence. | Needs key | Stand-In |
| **Hungry Courses** (Cơ Mạch) | Linh lực and starving it, Earth, outer, sealed by a technique, size 10. Notables Held Acres and Thrift, capability Requisition. | Needs key | Corner |
| **Long Table** (Trường Tịch Mạch) | Sealed by the Wedding Hearth Sutra, theme the Way of Alchemy, Fire, size 8. Notables Cook's Hand, then Fine Work. | Needs key | Wedding Furnace |
| **Many Threads** (Thiên Ti Mạch) | Divine Sense theme, Metal, outer, sealed by technique, size 10. Notables: Bare Vessel, then Spare Mind as its capability. | Needs key | Remnant Host |
| **Old Yoke** (Cổ Ách) | Sealed, Beast Taming, Earth, outer, size 10. Notables In Step, then Broad Back with Fights as Itself as its capability. | Needs key | Herd-Child |
| **Open Seams** (Khai Phùng Mạch) | Theme statuses, Water, outer, sealed by a technique, size 10. Notables Thin Bleed (Gall) and Kept Grudge, capability Widening Wound. | Needs key | Thousand Scales |
| **Paper Sky** (Chỉ Thiên Mạch) | Divine Sense theme, Metal, outer, sealed by technique, size 8. Notables Light Hand and Unseen Hand; keystone Along the Thread as the capability. | Needs key | Cut Line |
| **Red Paper Street** (Hồng Chỉ Phố) | Theme Way of Talismans, Fire, outer, sealed by a technique, size 9. Notables Signed Paper, Let It Ride, capability #13. | Needs key | Spring Hand |
| **Slow Wax** (Hoãn Lạp) | Sealed, Earth, size 8. Pills and what a body can hold. Notables Bright Blood, then Empty Stomach. | Needs key | Pill Glutton |
| **Standing Post** (Trạm Trang) | Theme body refinement, Metal, outer, sealed by a technique, size 10, notables Bare Rack and Withheld Hand as the capability. | Needs key | Fortieth Breath |
| **Struck Register** (Tước Bạ Mạch) | Heart State theme, Water, outer, sealed by technique, size 12. Notables: Borrowed Name with Bare Vessel's line, then Struck Name as the capability. | Needs key | Struck Name |
| **Swollen Channels** (Ứ Mạch) | Sealed, Water, size 8. Wards and how force moves through them. Notable: Strong Decoction. | Needs key | Great Tonic |
| **The Clear Vat** (Thanh Hang) | Wood sector, sealed by technique, eleven nodes: six Spread acupoints, Steeped, Clean Hands, Mordant, Bluer Than the Plant, One Drop at the far end. | Needs key | Indigo Drop |
| **Unmoved Body** (Bất Động Thân) | Body refinement, Earth, outer, sealed by a technique, size 10. Notables Still Sea and Iron Marrow. | Needs key | Incense Vigil |
| **Waster Heap** (Phế Đôi) | Sealed, Earth, size 8. Wounds and vitality. Sealed by a technique or three failed great breakthroughs. Notable: Reopened. | Needs key | Turned-Away |

## Wards (7)

New ward spells.

| Name | What it does | Fit | Build |
|---|---|---|---|
| **Indemnity Ward** (Bồi Thường Hộ) | A per-pulse ward whose premium is paid in stones, so linh lực is never touched. | Needs rule | Full Price |
| **Mother-and-Child Ward** (Mẫu Tử Hộ) | A common drain ward, pass 0.54 and 0.36, drain 1.0 and 1.5, that carries one element as a phase. | Needs rule | Kept Hearth |
| **Sealed Room** (Cách Ly Hộ) | Per-pulse ward, pass 0.55, upkeep_share 0.03, around the enemy. Hits leaving them and hits going in both meet it, and only its holder pays. Carries Nothing Leaves. | Needs rule | Held Door |
| **Soiled Gown** (Ô Y Hộ) | Drain ward, pass 0.55 body and 0.45 qi, drain 1.2 and 1.5, cheap and thin, made to go over another. | Needs key | Held Door |
| **Standing Verdict** (Án Định Hộ) | Per-hit ward, pass 0.30 body and 0.20 qi, hit_cost_share 0.05. | Needs key | Fortieth Breath |
| **Stone Ward** (Thạch Hộ) | A per-pulse ward (Combat rule 22): common pass, no drain, upkeep 10 % of maximum linh lực a pulse before ward efficiency. Costs the same whatever lands. | Needs key | Long Firing |
| **Vinegar Cloth** (Thố Cân Hộ) | Per-hit ward, pass 0.34 body and 0.24 qi, hit_cost_share 0.04. | Needs key | Held Door |

## Arts (169)

Every new art, sorted by build.

| Name | What it does | Fit | Build |
|---|---|---|---|
| **Lantern Left** (Lưu Đăng) | Body hit, c_art 4.4, cost 0.06, 12 s. | Needs key | Already-Waited |
| **Rope Burn** (Lãm Ngân) | Body hit, c_art 3.7, cost 0.04, 10 s. | Needs key | Already-Waited |
| **The Last Ferry** (Mạt Độ) | Body hit, c_art 6.3, cost 0.05, 20 s, guard enemy health below 40 %. | Needs key | Already-Waited |
| **Third Winter** (Đệ Tam Đông) | Qi hit, c_art 3.3, cost 0.05, 8 s. | Needs key | Already-Waited |
| **Wait Here** (Tại Thử Đãi) | Qi hit, c_art 2.7, cost 0.04, 6 s. The enemy's art nearest to firing is pushed back 3 s. | Needs rule | Already-Waited |
| **Officer's Cane** (Quân Trượng) | Body hit, c_art 1.48, cost 0.04, 1 s. | Needs key | Ant General |
| **Shouted Order** (Hô Lệnh) | Qi hit, c_art 2.2, cost 0.08, 2 s. | Needs key | Ant General |
| **Goat in Passing** (Thuận Thủ) | Cost 0.02, 0.5 s. Each firing lifts one carried thing, cheapest first, kept only on a Fled result. | Needs rule | Best Plan |
| **Bleeding Ink** (Thẩm Mặc) | Rubbing: half coefficient, fee ×2, carries Usurious Ink. | Needs rule | Brush Fee |
| **Fair Copy** (Thiện Bản) | Rubbing from a Way of Ink art node: also carries the original's status and curse. | Needs rule | Brush Fee |
| **First Impression** (Sơ Thác) | Rubbing: the hit alone, fee ×1. | Needs rule | Brush Fee |
| **Reversed Proof** (Phản Ấn) | Rubbing: kind swapped between body and qi, fee ×1. | Needs rule | Brush Fee |
| **Break the Topic** (Phá Đề) | Qi hit, c_art 1.45, cost 0.04, 1 s. | Needs key | Clever Harm |
| **Receive the Topic** (Thừa Đề) | Qi hit, c_art 1.95, cost 0.05, 2.5 s. | Needs key | Clever Harm |
| **Bad Year** (Hoang Niên) | Burn, cost 0.06 with Rush Order, 2 s: c_tick 0.4, 5 pulses. | Needs key | Corner |
| **Rent Day** (Thu Tô) | Qi hit, c_art 2.2, cost 0.08, 2 s, guard enemy linh lực at or below 20 %. | Needs key | Corner |
| **Short Measure** (Đoản Đấu) | Burn, cost 0.06 with Rush Order, 2 s: c_tick 0.4, 5 pulses. | Needs key | Corner |
| **Spoiled Stores** (Hủ Thương) | Body tick, cost 0.05, 2 s: c_tick 0.44, 5 pulses, there to clip and spill. | Needs key | Corner |
| **Thin Gruel** (Bạc Chúc) | Burn, cost 0.05, 2 s: c_tick 0.44, 5 pulses. | Needs key | Corner |
| **Glass Line** (Lưu Ly Tuyến) | Soul art, soul_pct 0.05, cost 0.09, cooldown 0.5 s. | Needs key | Cut Line |
| **Paper Cut** (Chỉ Thương) | Soul art, soul_pct 0.03, cost 0.05, cooldown 0.5 s. | Needs key | Cut Line |
| **Running Cut** (Tẩu Cát) | Soul art, soul_pct 0.05, cost 0.09, cooldown 0.5 s. | Needs key | Cut Line |
| **Test Tug** (Thí Tuyến) | Soul art, soul_pct 0.03, cost 0.05, cooldown 0.5 s. Applies Slackened Soul. | Needs key | Cut Line |
| **Falling Cut** (Hạ Phách) | Body hit, sword, c_art 1.72, cost 0.06, 1 s. Held line. | Needs key | Daily Lesson |
| **Let Fly** (Phóng Kiếm) | Active effect of a phi_kiem. Body hit, sword, artifact source, c_art 2.33, cost 0.09, 2 s, one art slot per sword. | Needs key | Daily Lesson |
| **Morning Thrust** (Thần Thích) | Body hit, sword, c_art 1.72, cost 0.06, 1 s. Held line. | Needs key | Daily Lesson |
| **Rising Cut** (Thượng Liêu) | Body hit, sword, c_art 1.72, cost 0.06, 1 s. Held line. | Needs key | Daily Lesson |
| **Cold Bucket** (Hàn Tuyền) | Body hit, c_art 1.6, cost 0.05, 1 s. | Needs key | Deepest Well |
| **Drawn Rope** (Khiên Sách) | Qi hit, c_art 2.46, cost 0.08, 3 s. | Needs key | Deepest Well |
| **Lowered Bucket** (Cấp Thủy) | Qi hit, c_art 1.6, cost 0.05, 1 s. | Needs key | Deepest Well |
| **Salted Well** (Diêm Tỉnh) | Curse, cost 0.09, 2 s, Rush Order: 3 pulses of drain raise +50 % and pass_raise -0.4. | Needs rule | Deepest Well |
| **The Whole Bucket** (Khuynh Tỉnh) | Qi hit, pays all above its keep line, 2 s, guarded on own linh lực above your line. c_art is the lint value of what it paid. | Needs rule | Deepest Well |
| **First Course** (Sơ Thiện) | Body hit, c_art 1.99, cost 0.02, 4 s. | Needs key | Drink the Lightning |
| **Last Course** (Mạt Thiện) | Qi hit, c_art 5.99, cost 0.02, 20 s. | Needs key | Drink the Lightning |
| **Rinse the Mouth** (Thấu Khẩu) | No hit, cost 0.02, 2 s: removes two statuses and every curse on you. | Needs key | Drink the Lightning |
| **Second Course** (Thứ Thiện) | Qi hit, c_art 2.99, cost 0.02, 8 s. | Needs key | Drink the Lightning |
| **Third Course** (Tam Thiện) | Body hit, c_art 3.99, cost 0.02, 12 s. | Needs key | Drink the Lightning |
| **Whole Seam** (Toàn Mạch) | Body hit, Earth, c_art 11.2, cost 0.85, 1 s, on the lint's line. Fires once in any fight, because it waits for the pool. | Needs key | Dug Stone |
| **Dry Brush** (Can Bút) | Body, ink, c_art 2.35, 5 Blank, 4 s. | Needs key | Empty River |
| **Signature** (Lạc Khoản) | Qi, c_art 2.1, cost 0.05, 3 s, guarded on 9 Blank or fewer. | Needs key | Empty River |
| **Splashed Ink** (Bát Mặc) | Qi, ink, c_art 4.0, 25 Blank, 1 s. | Needs key | Empty River |
| **Long Root** (Trường Căn) | Qi hit, Wood, c_art 2.2, cost 0.08, 3 s. The mixed enemy's strike. | Needs key | Evergreen Road |
| **New Shoot** (Tân Manh) | Body hit, Wood, c_art 1.4, cost 0.05, 1 s. The mixed enemy's jab. | Needs key | Evergreen Road |
| **Old Bough** (Lão Chi) | Body hit, Wood, c_art 3.6, cost 0.12, 6 s, while own linh lực is 30 % or above. The mixed enemy's heavy. | Needs key | Evergreen Road |
| **Bed of Coals** (Than Sàng) | As Smoulder, with its own Burning status. | Needs key | Fierce Fire Road |
| **Furnace Mouth** (Lô Khẩu) | Qi hit, c_art 3.18, cost 0.14, 3 s. | Needs key | Fierce Fire Road |
| **Last Cinder** (Dư Tẫn) | Hit, c_art 1.6, cost 0.05, 1 s. Qi on Fierce Fire, body on Slow Fire. | Needs key | Fierce Fire Road |
| **Red Bellows** (Xích Bễ) | Qi hit, c_art 3.18, cost 0.14, 3 s. | Needs key | Fierce Fire Road |
| **Smoulder** (Âm Nhiên) | Body hit, c_art 1.25, cost 0.05, 2 s, with Burning: c_tick 0.15, 3 pulses, chance 0.60. | Needs key | Fierce Fire Road |
| **White Coal** (Bạch Than) | Qi hit, c_art 3.18, cost 0.14, 3 s. | Needs key | Fierce Fire Road |
| **Last Word** (Mạt Tự) | One hit, c_art 13.75 plus withheld, cost 0.25, cooldown 40 s, firing at 40.000 at the time limit. | Needs rule | Fortieth Breath |
| **Buyout** (Mãi Đoạn) | Body hit, c_art 13, share 1, cooldown 1 s, guard own health below 75 %, so it fires in a follow-up instant. | Needs rule | Full Price |
| **Earnest Money** (Định Kim) | Qi hit, c_art 4.0, share 0.25, cooldown 1 s. | Needs key | Full Price |
| **Ruinous Offer** (Khuynh Gia Giá) | Body hit, c_art 25, share 2, rushed to t = 0.5. | Needs rule | Full Price |
| **Banked Coals** (Tàng Thán) | Qi hit, c_art 2.4, cost 0.08, 3 s. | Needs key | Given Years |
| **Last Harvest** (Mạt Thu) | Qi hit, c_art 4.2, cost 0.25, 2 s, guarded on own seasons 14 or fewer. | Needs key | Given Years |
| **Splitting Maul** (Phách Sài) | Body hit, c_art 2.4, cost 0.10, 2 s. | Needs key | Given Years |
| **Threshing Flail** (Đả Cốc) | Body hit, c_art 1.6, cost 0.05, 1 s. | Needs key | Given Years |
| **Scythe Day** (Khai Liêm) | Qi hit, Wood, c_art 2.9, cost 0.12, 3 s, guarded on enemy health below 50 %. | Needs key | Good Year |
| **Lancing** (Khai Ung) | With Surfeit above 60 %: target loses 25 % of maximum health per 100 % of Surfeit, past ward, guard and evade; its pool and Surfeit go to 0. | Needs rule | Great Tonic |
| **Long Needle** (Trường Châm) | Body hit, c_art 2.2, cost 0.08, 2 s. | Needs key | Great Tonic, House Call |
| **Tonic Needle** (Bổ Châm) | Qi hit, c_art 1.45, cost 0.04, 1 s. | Needs key | Great Tonic |
| **Full Cleave** (Toàn Phách) | Body hit, Metal, c_art 3.6, cost 0.12, 6 s, while own linh lực is 30 % or above. The mixed enemy's heavy. | Needs key | Grindstone Road |
| **Long Draw** (Trường Tha) | Qi hit, Metal, c_art 2.2, cost 0.08, 3 s. The mixed enemy's strike. | Needs key | Grindstone Road |
| **Plain Cut** (Bình Trảm) | Body hit, Metal, c_art 1.4, cost 0.05, 1 s. The mixed enemy's jab. | Needs key | Grindstone Road |
| **Seam Thrust** (Tầm Phùng Thích) | Point line only. Body hit, c_art 1.8, cost 0.06, 2 s, with a curse: pass_raise 0.40 for 2 pulses. | Needs key | Grindstone Road |
| **Low Howl** (Đê Hống) | A companion's fixed art: qi, beast, hit. | Needs key | Guide Hound |
| **Ague** (Ngược Chứng) | As Sweat. Qi tick. Foundation Establishment. | Needs key | Held Door |
| **Chill** (Hàn Chứng) | As Sweat. Qi tick. | Needs key | Held Door |
| **Flux** (Tả Chứng) | As Sweat. Body tick, no poison tag. | Needs key | Held Door |
| **Sweat** (Hãn Chứng) | Qi, c_art 0.6, cost 0.05, 1 s, own linh lực 60 % or above. Body tick, c_tick 0.5, 2 pulses, poison tag. | Needs key | Held Door |
| **Calling Note** (Hô Thanh) | Qi hit, c_art 1.2, cost 0.03, 1 s, song form. | Needs key | Herd-Child |
| **Furrow Song** (Lũng Ca) | Curse, ward pass x1.5 for 3 pulses, cost 0.05, 2 s. | Needs key | Herd-Child |
| **Home Call** (Hồi Thôn Khúc) | Escape, cost 0.10, 3 s, guard own health below 30 %. Unmodelled. | Needs key | Herd-Child |
| **Low Song** (Đê Ca) | Curse, -30 % body guard for 3 pulses, cost 0.05, 2 s. | Needs key | Herd-Child |
| **Rain Song** (Vũ Ca) | Curse, +50 % ward drain for 3 pulses, cost 0.05, 2 s. | Needs key | Herd-Child |
| **Mend** (Bổ Thủ) | No hit, cost 0.04, 2 s, heal_share 0.08, guarded on enemy health below 92 %. | Needs rule | House Call |
| **Silver Needle** (Ngân Châm) | Qi hit, Water, c_art 1.45, cost 0.04, 1 s. | Needs key | House Call |
| **Closed Gate** (Bế Môn) | Curse, cost 0.04, 3 s: blocks enemy regeneration for 5 pulses. | Needs key | Incense Vigil |
| **Stale Incense** (Trần Hương) | Curse, cost 0.04, 3 s: enemy art costs +50 % for 5 pulses. | Needs key | Incense Vigil |
| **Stilled Hand** (Định Thủ) | Curse, cost 0.04, 3 s: locks one enemy layer for 2 pulses. | Needs key | Incense Vigil |
| **Falling Drop** (Nhất Tích) | Qi, Wood, c_art 1.3, cost 0.04, 0.5 s, guarded on the target holding no colour. | Needs key | Indigo Drop |
| **Bank the Fire** (Phục Hỏa) | Body ring hit, c_art 2.45, cost 0.10, 2 s. | Needs key | Kept Hearth |
| **Cold Road** (Hàn Lộ) | Escape art, guarded on own health below 30 %. | Needs key | Kept Hearth |
| **Set a Place** (Thiết Vị) | Qi ring hit, c_art 2.2, cost 0.10, 1 s. | Needs key | Kept Hearth |
| **Turn Down the Lamp** (Hạ Đăng) | Qi ring hit, c_art 5.25, cost 0.25, 6 s. | Needs key | Kept Hearth |
| **Turn the Pillow** (Phiên Chẩm) | Qi ring hit, c_art 2.8, cost 0.11, 3 s. | Needs key | Kept Hearth |
| **Ditch** (Điền Câu) | One art in four forms, each slotted on its own: body or qi, water or earth. Formation source, c_art 1.75, cost 0.03, 3 s. Dead without the array. | Needs key | Level Ground |
| **Hoe Stroke** (Sừ Kích) | Body hit, c_art 2.45, cost 0.08, 3 s. The one art that works in a blind fight. | Needs key | Level Ground |
| **Rising Water** (Thăng Thủy) | Qi hit, formation source, c_art 2.45, cost 0.08, 3 s. Dead without the array. | Needs key | Level Ground |
| **Walk Home** (Quy Gia) | Escape art, cost 0.10, 5 s, guarded on own health below 30 %. | Needs key | Level Ground |
| **Even Step** (Bình Bộ) | Qi hit, c_art 1.48, cost 0.04, 1 s. | Needs key | Long Carry |
| **Home Road** (Quy Lộ) | The escape art, cost 0.06, 1 s, guarded on own health below 50 %. | Needs key | Long Carry |
| **Over the Ridge** (Việt Lĩnh) | Qi hit, c_art 3.4, cost 0.14, 4 s. | Needs key | Long Carry |
| **Setting Down** (Phóng Đảm) | Body hit, c_art 2.9, cost 0.12, 3 s. | Needs key | Long Carry |
| **Shifted Pole** (Hoán Kiên) | Qi hit, c_art 2.2, cost 0.08, 2 s. | Needs key | Long Carry |
| **Falling Lintel** (Lạc Mi) | Body hit, Earth tag, c_art 2.71, cost 0.08, 4 s. | Needs key | Long Firing |
| **Settling Wall** (Trầm Bích) | Body hit, Earth tag, c_art 2.96, cost 0.08, 5 s. | Needs key | Long Firing |
| **One Glance Topples the Realm** (Nhất Cố Khuynh Quốc) | Body hit, sword, c_art 2.94, cost 0.12, 3 s. It is a slightly larger thrust. | Needs key | Loud Sword |
| **Ten Thousand Geese Bow to the Peak** (Vạn Nhạn Triều Phong) | Qi hit, sword, c_art 1.48, cost 0.04, 1 s. It is a thrust. | Needs key | Loud Sword |
| **The Moon Envies My Left Sleeve** (Nguyệt Đố Tả Tụ) | Qi hit, sword, c_art 2.2, cost 0.08, 2 s. It is a slash. | Needs key | Loud Sword |
| **After You** (Nhượng Tiên) | No hit, no cost, 1 s. The slot Patronage runs from. | Needs key | Lucky Fool |
| **Ill Omen** (Hung Triệu) | Curse, cost 0.03, 2 s: the enemy's fortune -15 for 3 pulses, stacking to -45. | Needs key | Lucky Fool |
| **Wrong Turn** (Mê Lộ) | Escape art, e_art 0.55, cost 0.10, 3 s, guarded on own health below 30 %. | Needs key | Lucky Fool |
| **Carve** (Phiến Nhục) | Qi, c_art 2.2, cost 0.08, 2 s. | Needs key | Not-Yet-Full |
| **First Cut** (Sơ Đao) | Body, c_art 2.95, cost 0.15, 4 s, with Rush Order. | Needs key | Not-Yet-Full |
| **Honey Glaze** (Mật Trấp) | Qi, c_art 1.0, cost 0.05, 0.85 s. Curse for 3 pulses: Sweet Ward. | Needs rule | Not-Yet-Full |
| **Second Helping** (Thiêm Thiện) | Body, c_art 2.2, cost 0.08, 2 s, guarded on enemy health below 50 %. | Needs key | Not-Yet-Full |
| **Tucked Napkin** (Thiện Cân) | Body, lock tag, c_art 1.0, cost 0.03, 2 s. Curse for 3 pulses: cost_raise +50 %. | Needs key | Not-Yet-Full |
| **Cold Needle** (Hàn Châm) | Body hit, Water tag, c_art 1.84, cost 0.06, 1.5 s. Cold Line. Three such arts in that line. | Needs key | One Ladle |
| **First Ladle** (Sơ Chước) | Qi hit, Water tag, c_art 1.60, cost 0.04, 1.5 s. | Needs key | One Ladle |
| **Second Ladle** (Tái Chước) | Qi hit, Water tag, c_art 1.60, cost 0.04, 1.5 s. | Needs key | One Ladle |
| **Closing Sentence** (Kết Ngữ) | Qi hit, c_art 2.47, cost 0.06, 4 s. | Needs key | One Long Word |
| **Grudging Hand** (Lận Thủ) | Qi hit, c_art 1.4, cost 0.04, 2.5 s. Curse for 2 pulses: art cost +20 %. | Needs key | One Long Word |
| **Level Gaze** (Bình Thị) | Qi hit, c_art 1.9, cost 0.04, 3 s. | Needs key | One Long Word |
| **Plain Reproach** (Trực Trách) | Body hit, c_art 1.9, cost 0.04, 3 s. | Needs key | One Long Word |
| **Small Complaint** (Tiểu Oán) | Qi hit, c_art 1.4, cost 0.04, 2.5 s. Curse for 2 pulses: ward pass +24 %. | Needs key | One Long Word |
| **Standing Word** (Trụ Ngôn) | Qi hit, c_art 2.0, cost 0.08, 3.8 s. Curse for 3 pulses: art cost +34 %, ward drain +34 %, regeneration blocked. | Needs key | One Long Word |
| **Thin Skin** (Bạc Bì) | Body hit, c_art 1.4, cost 0.04, 2.5 s. Curse for 2 pulses: shred 0.24. | Needs key | One Long Word |
| **Backfill** (Hồi Điền) | Body, c_art 2.4, cost 0.08, 3 s, guarded on fight time. Core Formation. | Needs key | Pill Glutton |
| **Pick Stroke** (Hạo Kích) | Body, c_art 1.2, cost 0.04, 2 s. | Needs key | Pill Glutton |
| **Seam Charge** (Mạch Bạo) | Body, c_art 3.4, cost 0.12, 5 s. | Needs key | Pill Glutton |
| **Shot Hole** (Bạo Khổng) | Qi, c_art 1.9, cost 0.06, 2 s, guarded on fight time. | Needs key | Pill Glutton |
| **Wedge** (Tiết Thạch) | Qi, c_art 2.2, cost 0.08, 2 s, guarded on fight time. | Needs key | Pill Glutton |
| **Binding Sutra** (Phược Kinh) | Qi, c_art 1.0, cost 0.05, 2.5 s. Curse: shred 0.25 for 3 pulses. | Needs key | Puppeteer |
| **Evening Drum** (Mộ Cổ) | Body, c_art 2.6, cost 0.08, 3.75 s. | Needs key | Puppeteer |
| **Morning Bell** (Thần Chung) | Qi, c_art 1.0, cost 0.04, 1.25 s. | Needs key | Puppeteer |
| **Lifted Pestle** (Cử Xử) | Body, hit, c_art 2.46, body_cost_share 0.04, cooldown 3 s. | Needs key | Rice Pestle |
| **Pounding Stroke** (Đảo Kích) | Body, hit, c_art 1.60, body_cost_share 0.025, cooldown 1 s. | Needs key | Rice Pestle |
| **Bone Steam** (Cốt Chưng) | Qi hit, c_art 0.8, cost 0.04, 1.9 s. Applies a qi tick with no poison tag, c_tick 0.15, 4 pulses, 50 % a stack. | Needs key | Second Sickness |
| **Thin Dose** (Bạc Tễ) | Qi hit, c_art 0.8, cost 0.04, 1.9 s. Applies Poison: body tick, c_tick 0.15, 4 pulses, 50 % a stack. | Needs key | Second Sickness |
| **Wasting Thirst** (Tiêu Khát) | Qi hit, c_art 0.8, cost 0.04, 1.9 s. Applies a qi burn, c_tick 0.15, 4 pulses, 50 % a stack. | Needs key | Second Sickness |
| **First Lamp to Seventh Lamp** (Sơ Đăng to Thất Đăng) | Seven arts from Low Flame Method: qi, Fire, hit, c_art 2.23, cost 0.04, 4 s. | Needs key | Seven Lamps |
| **Quick Lamp** (Khoái Đăng) | Four arts on the Quick Breath line: qi, Fire, hit, c_art 1.605, cost 0.04, 1.5 s. | Needs key | Seven Lamps |
| **Bile** (Đảm Trấp) | Qi hit, c_art 2.2, cost 0.08, 3 s, guard no curse on you. | Needs key | Stand-In |
| **Phlegm** (Thổ Đàm) | Body hit, c_art 1.85, cost 0.05, 2 s, guard no curse on you. | Needs key | Stand-In |
| **Purge** (Thổ Uế) | Qi hit, c_art 2.2, cost 0.12 with Rush Order, 2 s, guard holding all your afflictions. Moves every curse and status on you, then hits. | Needs rule | Stand-In |
| **Empty Tablet** (Không Bài) | A bare hit, c_art 2.9, paid 0.06 of health, cooldown 3 s, guarded on enemy linh lực below 5 %. | Needs key | Struck Name |
| **Strike the Name** (Tước Danh Thức) | No hit. Applies Unnamed for 2 pulses. Cost 0.05, cooldown 1.3 s. | Needs rule | Struck Name |
| **Unwritten Line** (Vô Tự Hoạch) | A bare hit, c_art 2.2, cost 0.08, cooldown 2 s. | Needs key | Struck Name |
| **Worn Name** (Phi Danh) | A bare hit, c_art 2.9, cost 0.12, cooldown 3 s, guarded on the enemy having Unnamed. | Needs key | Struck Name |
| **First Taste** (Sơ Thí) | Qi hit, c_art 1.0, 1 s, 2 đan độc. Applies Bile, c_tick 0.3 for 4 pulses. | Needs key | Taster's Fever |
| **Second Cup** (Đệ Nhị Bôi) | Body hit, c_art 1.0, 1 s, 2 đan độc. | Needs key | Taster's Fever |
| **Spat Bile** (Thổ Đảm) | Body hit, c_art 1.0, 1 s, 2 đan độc. | Needs key | Taster's Fever |
| **Beating Branch** (Phác Chi) | Qi, hit, c_art 2.46, cost 0.08, cooldown 3 s. Walk-Down Line. | Needs key | Third Look |
| **Stamping Foot** (Đạp Hỏa) | Body, hit, c_art 1.60, cost 0.05, cooldown 1 s. Walk-Down Line. | Needs key | Third Look |
| **The Look** (Ngưng Thị) | Soul, soul_pct 0.07, cost 0.126, cooldown 1 s. | Needs key | Third Look |
| **Dry Click** (Khô Minh) | Qi. c_art 1.48, cost 0.04, 1 s. | Needs key | Thirteenth Summer |
| **Scrabble** (Bào Thổ) | Body. c_art 1.48, cost 0.04, 1 s. | Needs key | Thirteenth Summer |
| **The Long Note** (Trường Minh) | Qi, song. c_art 145.23, cost 0.04, authored cooldown 576 s at purity 60 and one waking. | Needs rule | Thirteenth Summer |
| **Rub Salt** (Sát Diêm) | Curse, cost 0.03, 3 s: shred 0.3 for 3 pulses. | Needs key | Thousand Scales |
| **Scaling Stroke** (Quát Lân Thức) | One art in three forms, each slotted on its own: body and metal, qi and metal, qi and water. c_art 0.5, cost 0.02, 1 s. Each form applies its own wound (Scale, Seam, Gill), c_tick 0.15, 4 pulses. | Needs key | Thousand Scales |
| **Grafted Branch** (Tiếp Chi) | Body, Wood. c_art 4.00, cost 0.25, 1 s. | Needs key | Transplant |
| **Stripped Bark** (Bác Bì) | Body, Wood. c_art 4.00, cost 0.25, 1 s. | Needs key | Transplant |
| **Through the Heartwood** (Xuyên Tâm) | Qi, Wood. c_art 4.00, cost 0.25, 1 s. | Needs key | Transplant |
| **Hairline** (Liệt Văn) | Qi hit, c_art 2.2, health 0.04, 2 s. | Needs key | Turned-Away |
| **Second Firing** (Tái Thiêu) | Body hit, c_art 2.9, health 0.06, 3 s. | Needs key | Turned-Away |
| **The Gate Opens Inward** (Môn Nội Khai) | Qi hit, c_art 4.1, health 0.08, 6 s. Timed to land in the last instant four scars buy. | Needs key | Turned-Away |
| **Aside** (Bàng Bạch) | Qi hit, c_art 2.4, cost 0.08, 3 s, guard Cue. | Needs rule | Understudy |
| **Costume Change** (Cải Trang) | No hit. Adds 1 to the Curtain, times the thần thức ratio. Cost 0.06, cooldown 1 s. | Needs rule | Understudy |
| **Curtain Call** (Tạ Mạc) | Qi hit, c_art 1.6, cost 0.05, 1 s, guard Cue. | Needs rule | Understudy |
| **Last Act** (Chung Mạc) | Qi hit, c_art 5.15, cost 0.12, 12 s. | Needs key | Understudy |
| **Painted Screen** (Họa Bình) | No hit. Adds 1 to the Curtain, times the thần thức ratio. Cost 0.08, cooldown 2 s. | Needs rule | Understudy |
| **Low Flame** (Văn Hỏa) | Qi hit, c_art 1.48, cost 0.04, 1 s. | Needs key | Wedding Furnace |
| **Open the Door** (Khai Lô) | Furnace active effect: c_art 2.2, cost 0.10, 1 s. Serves the next course; with none left it does not fire. | Needs key | Wedding Furnace |
| **Bathwater** (Dục Thủy) | Body, c_art 3.1, cost 0.12, 4 s. | Needs key | Welcome Bath |
| **Hot Towel** (Nhiệt Cân) | Qi, c_art 2.2, cost 0.08, 2 s. | Needs key | Welcome Bath |
| **Wash the Dust** (Tẩy Trần) | Body, cleanse, wash, c_art 1.3, cost 0.04, 0.5 s. | Needs rule | Welcome Bath |
| **The Seven Beads** (Thất Châu) | Seven arts: Mộc, Hỏa, Thổ, Kim, Thủy Châu, Niệm Châu, Hồi Hướng. c_art 1.48, cost 0.04, 1 s. | Needs key | Worst Root |

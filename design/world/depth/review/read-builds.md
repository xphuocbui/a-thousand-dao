# Reader: builds, items, sets and lineages (`read-builds`, 2026-11-25)

**Coverage.** I read 131 of the 159 living tier A builds in full: archetype, main and aux, gear, route, `targets_note`, `note`, wants and the opening of the backstory. The last 28 (Thúy Vi's tail, Trác Anh, Trấn Sa, Trúc Thục, Tuần Tùng, Tùng Đào, Vạn Hác, Vân Khởi, Vọng Triều, Vũ Ẩn, Vũ Linh, Xuyên Lâm and Yên Quang) I read by archetype and note only. I read all 45 sect lineages and the 5 group technique files, the full-set Effect and the story of every split set, and about 15 named items in full. Scripts did the rest: set completion, bases, caps, names and lore. I checked routes with `tools/design/world/depth_tree.py route` where I name them.

**Untested.** The lineage techniques are concepts, not records, so nothing here was fight-tested. Where I say a build or set would be fun, that is a reading, not a result.

## Verdict

The slice is close to the user's ask. Every tier A person has a personal set, and 144 of 159 wear all of it. Each sect has its own lineage, and most lineages grow from the sect's trade and land: assayers, reelers, bell-casters, ferrymen, pearl divers. Item lore is concrete and cites the chronicle. What fails is the wiring, not the invention:
- at least 40 pieces still carry the caps the user removed;
- the world has one named spirit beast for 18 tier A/B beast tamers;
- 48 tier A routes are leftovers from before the lineages, with a placeholder note;
- the "split regalia" story is cloned twelve times, so six great-sect heads fight without their own headline Effect.

## The weakest items, worst first

### 1. Caps survive in at least 40 pieces after the ruling removed them (must-fix)

**Where.** About 28 files. I hand-checked a pattern that counts only magnitude and stack caps, not rate limits. The worst cases:

| Piece | Cap | Note |
|---|---|---|
| `pm-ash-seat` | "up to 30 %" | The ruling's own example |
| `tx-breaker-harness` | "at most 5" | |
| `army-breaker-spear` | "Momentum, up to a cap" | The "10 momentum" example |
| `tx-archive-desk` | "at most three at once" | The "3 wards" example |
| `dq-night-raider` | "up to 40 %" | |
| `ht-lamp-ink-brush` | "at most 7" | |
| `lh-pear-blossom-vigil` | "up to 30 %" | |
| `bt-glacier-vigil` | "up to double" | |
| `vtd-breakwater` | "up to five" | |
| `mv-phu-dao-last` | "to 8" | |
| `ttv-rain-record` | "up to ten" | |
| `cl-locust-shade` | "up to 30 %" | |
| `mf-vermilion-azure` | "at most 10 %" | |
| `tht-fallen-star-forge` | "at most 5" | |

The source entries in `builds/authored/auth-eff-1.json`, `auth-eff-2.json` and `auth-tech.json` carry the same caps. These are not stale copies: the sweep was never run.

**Fix.** Keep rate limits such as "once a second" and "a pulse". Replace each magnitude or stack cap with a decay or a closing cost. Two examples:
- **`pm-ash-seat`**: "Each second a foe burns under your Fire, the censer banks 0.5 % of your health; the bank loses a twentieth of itself each second."
- **`dq-night-raider`**: "Your arts paid in health deal 1 % more damage for each 1 % of health you are missing, and each crit they land heals you for 4 % of your health. Healing from other sources is halved on you."

Run a sweep over `*.items.json`, `*.techniques.json` and `builds/authored/*.json`, and list every hit for the user.

### 2. One named spirit beast in the world (must-fix)

**Where.** `sects/cuu_cao.beasts.json` holds Thanh Điền and nothing else. I found no code that gives cast tamers a generated beast: `beast_keeper.gd` tames only beasts already beaten, and `world_builder.gd` skips beasts. The tamers whose companions do not exist:

| Person | Tier | Their beasts | Set that needs them |
|---|---|---|---|
| Tạ Thanh Loan | A | Three bonded birds | `bvc-bird-mother`: "when all three bonded birds strike" |
| Khấu Mục Vân | A | The spirit foal of A169 | `mv-horse-lord` |
| Vu Ngô Đồng | A | His writ birds | `pm-wutong-court` |
| Lâm Tuyết Điêu | B | A frost-wolf pack leader and an ice sable | |
| An Thú Sơn | B | A grey ridge hound | |
| Quan Tuyết Tùng | B | A lynx | |
| Lô Dã Hương | B | Her martens | |

Their Beast Pen, Ten Thousand Beasts One Heart and Ancestor Beast targets point at nothing. 11 of the 18 tamers are also filed as `linh_thuc_su`, which is Linh thực sư, the spirit farmer.

**Fix.** Author records in the `thanh_dien` form:
- `bach_vu.beasts.json`: three named birds, one a blue luan to match `bvc-blue-luan-whistle`;
- `muc_van.beasts.json`: Đạp Vân, the horse `mv-dap-van-bridle-ring` is already named for;
- `phuong_minh.beasts.json`: Vu Ngô Đồng's writ birds;
- one beast line each for the B tamers.

Then move the 11 tamers to `the_tu` or `phap_tu`, whichever their gear fits.

### 3. The pilot head, Sở Ngọc Hồ, is filed as a sword cultivator (must-fix)

**Where.** `bang_tam.cast.json`, `so_ngoc_ho.build`.

**What is wrong.** Her archetype is `kiem_tu`. Her gear is a gourd, a seal and a ring. Her canon "is a ward method", and her route is all Ice wards and the Frost Seal. She has no sword and takes no sword node. This is the record every writer was told to copy.

**Fix.** Set `archetype: "phap_tu"`.

### 4. Mạnh Dạ Vũ "cuts once" with no blade (must-fix)

**Where.** `thinh_vu.cast.json`, `manh_da_vu`.

**What is wrong.** His archetype is `kiem_tu`, and the first half of his canon says "the sword strikes once, late and hard". His gear is an umbrella (`thuan`), the Edict seal (`an`) and a catalogue Thunder drum: no sword.

**Fix.** Re-base `tvl-tuong-phi-tan` to `phi_kiem` as an umbrella with a blade in its shaft. Keep its Under the Umbrella Effect, and add the lore line "the ribs hide the blade his master never drew." He proclaimed the Edict under it, so the umbrella is where his one cut lives. The drum stays: his note relies on the regalia bolt standing in for his missing Thunder.

### 5. A place condition is still in a fight rule (must-fix)

**Where.** `thu_phan.items.json`, `tp-second-copy` (Cơ Ký Âm): "In fights on the thunder ridge, the repeat is at full power."

**What is wrong.** It breaks the environment ruling.

**Fix.** "Against a foe carrying one of your curses, the repeat is at full power." I did not use Resentment marks, because those come from the head's set and Cơ Ký Âm cannot lay them. I searched item and set Effects and technique concepts for ridge, ice, rain, dusk, dawn, night, snow, forest, moon and season wording. This was the only hit inside a fight rule. Time-of-day lines in cultivation methods are flavour, as the ruling allows.

### 6. 48 tier A routes are leftovers from before the lineages (should-fix)

**Where.** 48 of the 159 tier A builds have `targets_note: "restored from the 2026-11-20 authored build"`. 25 of them are sect or group heads.

**What is wrong.** These routes predate the sect routes, and the note says nothing about what the route builds. 20 tier A lineage runners take no node of their own sect route. Some are exempt by their route note: Thính Vũ sends its Water and Thunder starts their own way, and Thu Phần's Wood route does not fit a Darkness start. Several are not exempt:
- **Doãn Ngọc Hành.** The Thiên Xu note says Earth-start members "walk it from the Earth end", yet the head does not walk his own sect's road.
- **Đàm Tùng Lại.** The Tùng Đào note says "both halves of the palace take it", but the head does not.
- **Hùng Phần Vũ.** The founder of the vent-sitters starts on Earth (70) rather than Fire (76), so he skips "sitting in the vent", the sect's route.

**Fix.** Re-run the build-targets brief on these 48 only. Prepend the sect route where the start allows it, write a real one-line note, and check each route with `depth_tree.py`. For Hùng Phần Vũ, change `start` to `hoa` and set `targets: [2511, 2513, 2515, 2465, 1463, 3360, 3366, 9007]`. That route is proposed, not tested.

### 7. The three script flags, judged person by person (should-fix, plus a script fix)

**Sword cultivators with no sword: 12 of the 13 are real; one is a story choice.**
- **Wrong archetype, tier A:** `so_ngoc_ho` (item 3).
- **No blade where the canon needs one, tier A:** `manh_da_vu` (item 4).
- **Spear with no base, tier A:** `do_tinh_ha`. His `tx-pha-quan-spear` has `base: null`, and spears are split across bases:
  - `tx-marshal-spear` sits on `phi_kiem`;
  - `tv-dong-lam-spear` and `mv-cloud-herding-lance` sit on `mao` (anchor);
  - **fix:** add a **Thương** (spear) base to `design/items/bases.json` and move all four spears onto it.
- **Sword lineage, no blade (gear wrong, not archetype), tier B:**

| Person | Canon | Wears | Fix |
|---|---|---|---|
| `au_duong_kien` | Ten Paces Sword Canon | anchor and armour | swap the anchor for `phi_kiem` g2 |
| `boc_thu_chung` | Rain-Chain Sword | bell | swap the bell for a sword |
| `chau_tieu_dam` | Rain on Bronze | bell | swap the bell for a sword |
| `tuong_lau_thanh` | Thunder in the Rain | seal, armour and bell | swap the bell for a sword |
| `thach_lien_hoan` | Thunder in the Rain | hammer | add a sword in his ring slot |
| `bang_lanh_toi` | Star-Quench | tongs | add "the blades he tempers" |
| `hau_thiet_anh` | Star-Quench | anchor | add "the blades he tempers" |

- **Wrong archetype, tier B:** `su_pha_bang` (on the Lone Line canon) and `ho_tam_ky` (on the refining canon) should be `the_tu`.
- **Story choice, tier B:** `do_tieu_lien` is "untrained". Keep her as she is.

**Beast tamers with no beast whip: this is a script error.** `linh_thuc_su` is the spirit farmer. `depth_review.py` line 128 maps it to `tien_tieu`, which is the Coin base. In the game data (`world_generation.json`, `archetypes`) its bases are `phien` and `chuong`, and no whip base exists. The 33 people flagged are herbalists and stewards, and they fit. Make the script read the bases from `world_generation.json`; its `dan_su` and `tran_su` sets are also off. The real problem behind this flag is item 2.

**Array masters with no flag, seal or mirror: mostly false.**
- Bells (`chuong`) and lanterns (`dang`) are this world's array foci: Minh Loan's Hanging Bells, Vũ Linh's canopy bells, Sương Tùng's ward lanterns. They should count.
- **Real residue:**
  - `khang_thien_chuy`: `luyen_khi` 9, with a sword, an apron and a lid. Should be `kiem_tu`.
  - `tien_ngu_phan`: the auction steward, with a coin. Should be `phap_tu`.
  - `hau_bach_chu`: the shipwright, with a shield. Should be `the_tu`.
  - `ta_quy_yen`: `lh-scribes-reed-brush` has no base. Give it `cham`.
- **The cause underneath:** there is no refiner archetype. The 22 A/B Refiners are spread over six archetypes. Either add a refiner archetype (luyện khí sư), or rule that a refiner takes the archetype of what they fight with.

### 8. The split-regalia story is cloned 12 times (should-fix)

**Where.** `bt-regalia`, `tvl-night-rain-regalia`, `tx-pivot-regalia`, `tv-haze-regalia`, `pm-five-virtue`, `lh-sunset-regalia`, `hlo-ky-te`, `bt-plum-pair`, `tv-field-and-garden`, `td-cold-ford-charge`, `cl-set-old-hall` and `dm-set-blood-ink-study`.

**What is wrong.** All twelve splits are deliberate, and each set's `story` says so. The trouble is that the stories are one story: "the set is whole only in one pair of hands / only if X takes it back". The pilot's Ice Heart Regalia started it. The effect in play is that six great-sect heads fight their whole lives without their own headline Effect:
- Sở Ngọc Hồ (The Keeper's Stillness);
- Mạnh Dạ Vũ (The Rain Answers);
- Doãn Ngọc Hành (Seal and Weight in One Hand);
- Ngu Lâm Sơn (The Green Comes Back);
- Hoa Triêu Dương (The Phoenix Comes);
- Tô Vãn Chiếu (The Sky Goes One Colour).

Hồng Lô's Đồng Hồng Lô is a seventh, but Hồng Lô is a minor sect.

**Fix.** Keep the splits that are quests with a person on the other end: the pledged Lone Duck Ring, the red plum taken at Cô Thành, the Hắc Phong hooks, Triệu Huyết Y's stolen seal, and the Cold Ford lantern. Mark each set Effect as the growth goal. For the custom splits, move the full Effect to `pieces: 2` and give the elder's piece its own Effect:
- Thúy Vi: Cù Thúy Bách's gourd;
- Phượng Minh: the Wutong seal;
- Thiên Xu: the judge's Weight;
- Băng Tâm: Tiết Hàn Mai's mirror;
- Hồng Lô: the ember;
- the Tạ clan: the old-hall jade.

That gives the heads their idea and keeps the politics.

### 9. Seven sects run a shared catalogue method as their lineage main (should-fix)

**Where.**

| Shared method | Lineage main of |
|---|---|
| `verdant-cycle-scripture` | Hộ Lâm, Trúc Thục, Yên Quang (also a Cốc Vũ secret, and most loose Wood people) |
| `still-moon-tide-scripture` | Bình Thủy |
| `red-sun-scripture` | Hồng Lô |
| `gale-courier-scripture` | Cửu Cao |
| `winter-toll-canon` | Lê Hoa |

**What is wrong.** A shared main is the opposite of "deep and well defined". Several of these sects already have their own canon, sitting as a secret.

**Fix.**
- **Hồng Lô:** make `water-over-fire-canon` (Ký Tế) the main and `red-sun-scripture` the outer method.
- **Yên Quang:** make `gathered-haze-canon` the main.
- **Cửu Cao:** make `crane-bond-rite` the main.
- **Lê Hoa:** make `sealed-cold-sutra` the main.
- **Trúc Thục:** author a bamboo canon from `rain-on-bamboo-breath` and `sixty-year-flower`.
- **Bình Thủy:** grow the slack-water idea in `duckweed-drift-primer` into a Profound main.

### 10. Three sects learn their outer method by grinding ink (should-fix)

**Where.**
- `hoa_tinh`: Ink-Grinding Breath (Ma Mặc Tức);
- `nhan_van`: Ink-Grinding Primer (Ma Mặc Quyết);
- `nam_pho`: Mulberry Ink Primer ("The outer gate's method: grinding ink").

Almost every outer method also opens on one template: "The outer gate's method, learned at [the chore]".

**Fix.**
- **Nhàn Vân:** "Watching the Pool Primer (Quan Đàm Quyết)". The novice sits at the edge of the pool in Đàm Ảnh Thành and breathes only when its surface is flat.
- **Nam Phố:** "Bark-Beating Primer (Đả Chỉ Quyết)". Mulberry bark is beaten into pulp, one stroke to a breath.
- **The rest:** vary the first sentence.

### 11. "The longer you wait, the stronger" is the default fantasy (should-fix)

**Where.**
- About 13 of 45 lineage mains ramp with time or stillness: Lạc Hà, Nhạn Trận, Củng Tinh, Hàm Nguyệt, Cốc Vũ, Nhàn Vân, Tầm Kiếm, Vân Khởi, Xuyên Lâm, Thiên Xu, Băng Tâm, Lãnh Giang and Nam Phố.
- Of the set Effects, 16 are gated on Still or sitting, and 13 fire on "the first time you fall below X %".
- In tier A notes and intents, "outlast" appears 20 times, "slow" 15 and "wait" 10.

**What is wrong.** This fits the user's "sustain is king". But when a third of the world wins by standing still, the builds stop being distinct.

**Fix.** Give three of the Still lineages a tempo identity:
- **Tầm Kiếm:** marks spent within the first 5 s strike twice.
- **Xuyên Lâm:** the staff gains weight on changes of direction, not with time.
- **Hàm Nguyệt:** the Fist Pearl spends its Nacre on the opening exchange.

Then rewrite five of the "first time below X %" set Effects as on-hit or on-evade rules.

### 12. Native Vietnamese words in the Hán-Việt slot (should-fix)

**Where.** I ran a 12-word sample over item and set names, not a full sweep. Technique and art names were not searched. The hits:

| Where | Now | Fix |
|---|---|---|
| `mf-paid-shield` | Thuê Thủ Thuẫn | Dong Thủ Thuẫn (傭守盾) |
| `mf-losing-hand-ring` | Thua Thủ Hoàn | Bại Thủ Hoàn (敗手環) |
| `mf-losing-hand` | Dĩ Thua Vi Thắng | Dĩ Bại Vi Thắng (以敗為勝) |
| `tp-lined-winter-robe` | Lót Đông Bào | Hậu Đông Bào (厚冬袍) |
| `tv-salt-chest-lock` | Diêm Rương Tỏa | Diêm Tương Tỏa (鹽箱鎖) |
| `tv-salt-chest` | Rương Trung Vật | Tương Trung Vật (箱中物) |
| `tvl-gold-sand-pair` | Lôi Kích Lều | Lôi Kích Bằng (雷擊棚) |
| `mf-fair-weights` | Đòi Tiền Thối | Sách Hoàn (索還) |
| `tvl-dalan-suite` | Quy Vỏ | Quy Sao (歸鞘) |

The words to check are Hầm (`ltp-cellar-leather`, Hầm Tửu Giáp) and Ủ (the art Ủ Than). Items carry no `name_han`, so nothing can be checked against Hán characters. Add `name_han` to items, then run a full sweep.

### 13. Dev notes inside player-facing lore (should-fix)

**Where.** About 20 items:

| Item | Note in the lore |
|---|---|
| `lh-tu-dien` | "Legendary item tu_dien." |
| `hs-north-wind-breath` | "Legendary item soc_khi, slot A-1 (the legendary text says…)" |
| `hs-lone-crane` | "made_by null" |
| `tx-marshal-spear` | "No spear base exists, so it flies as a sword does." |
| `ls-white-wind-hook` | "The cross-sect pass gives it to Đồ Vô Cữu: it is in his gear." |

The same kind of note is in `bt-jade-vessel`, `tx-bac-than-an`, `tx-pha-quan-spear`, `tx-iron-horse-banner`, `tx-iron-horse-tally`, `tv-white-cloud-whisk`, `td-wandering-dragon-sash`, `hs-quy-khu-vase`, `mf-peach-spring-painting` and `mf-green-pearl`.

**Fix.** Move these to a `note` field. The `N-…` and `C…` event citations can stay, since the schema asks for them.

### 14. Two sets have no full-set Effect (should-fix)

**Where.**
- `ls-hac-phong-hooks`: Đồ Liệt Cơ's black hook and her brother Đồ Vô Cữu's white hook.
- `xl-calm-wind-and-waves`: the founder's staff, held by the head Úc Diệp Thanh, and the cape, held by the Road Mother Phi Thoa Y.

Both are 2-piece sets with modifiers only.

**Fix.**
- **Hắc Phong:** "Black and White Wind (Hắc Bạch Phong): when both hooks are worn in one fight, yours and an ally's, each hook strike lays one Heavy Breath, and the other hook's next strike on that foe is a sure crit." The siblings' reunion, which is in her `wants`, becomes a fight payoff.
- **Xuyên Lâm:** "Who Is Afraid (Thùy Phạ): while both are worn in one fight and you keep Moving without an escape art, every third staff strike lays one Heavy Breath; a foe with three cannot evade for 2 s."
- **Both sets need a rule that does not exist yet:** a set counted across allies. Add it to `builds/wishlist-sets-*.md`.

### 15. The sect route is forced on members who do not fight (nice-to-have)

**Where.**
- **Thiên Xu.** Its route `[723, 4141, 3461]` includes Serpent Spear, so four members who do not fight take a spear node:
  - the judge Phương Trực Ngôn;
  - the envoy Mâu Tri Viễn;
  - the archivist Sử Ngưng Mặc;
  - the copyist Thích Minh Thư, whose note says she "has never fought anyone".
- **Thính Vũ.** Its sword-crit route sends the spymaster Nhiếp Vô Thanh through Sword Rainbow and Sword Bow.

**Fix.**
- **Thiên Xu:** cut the route to `[723, 3461]`. Đỗ Tinh Hà and Ngũ Trấn Bắc keep 4141 in their own targets.
- **Nhiếp Vô Thanh:** replace 4270 and 4280 in her targets with 4219 Gong Stroke and 4216 Clear Gong.

### 16. A build note that contradicts the gear (nice-to-have)

**Where.** `tiet_han_mai.build.note` reads "frost-lotus seal, glacier bastion, and a mirror". The banner and the bastion belong to Cố Lăng Sương.

**Fix.** "The keeper of the lid: the hundred-and-eight-node seal, the locust-wood lid, and the Vessel's mirror for the soul arts." Then grep every note against the names of its gear.

## Patterns, with counts

- **Sets.**
  - 144 of 159 tier A wear a whole set.
  - 12 Kết Đan+ wear 2 of 3, all deliberate splits (item 8).
  - 3 Luyện Khí wear 1 of 2, which the ruling intends.
  - Of 166 sets, 99 are 3-piece and 67 are 2-piece; 2 have no full Effect.
- **Set Effect templates** (165 Effects). Most are specific to their holder, and few are generic. By template:

| Template | Count |
|---|---|
| Still or sitting-gated | 16 |
| First time below X % | 13 |
| Every Nth | 10 |
| % health each second | 8 |
| Sure crit | 7 |

- **Items.**
  - 490 items: 163 have an Effect and 327 have modifiers only. That fits Modifier vs Effect and is not a flaw.
  - 5 items have no base: `tx-pha-quan-spear`, `tx-iron-horse-tally`, `ttg-wolf-winter-bow`, `lh-scribes-reed-brush`, `mf-peach-spring-painting`. The bow needs a base or a ruling.
  - Lore leans on "since" (89 times), "has never" (31) and "still" (21). That is the brief's voice tic, but milder than in the backstories.
- **Caps.** At least 40 pieces in about 28 files, including the `builds/authored` sources (item 1).
- **Archetypes.**
  - There is no refiner archetype and no beast-tamer archetype. 22 Refiners are spread over 6 archetypes, and 11 tamers are filed as spirit farmers.
  - 7 of 45 sects use a shared catalogue main.
- **Shared aux methods.** The mains are distinct across lineages; the aux slot is where everyone looks alike:

| Aux method | Builds | Sects |
|---|---|---|
| `returning-wake-verse` | 22 | 8 |
| `hundred-echo-palm-scripture` | 17 | 5 |
| `mountain-bone-body-art` | 16 | 8 |
| `undertow-litany` | 13 | 6 |
| `thorn-and-ink-verses` | 11 | 6 |
| `iron-hide-manual` | 9 | 7 |

- **Routes.**
  - No two people in a sect share an identical route.
  - 48 tier A routes carry the placeholder note, 25 of them heads'.
  - 20 lineage runners take no node of their sect route. Some are exempt by their start (item 6).

## The best items: a short reading list

1. **Lạc Hà's twin swords and the pledged ring** (`lh-tu-dien`, `lh-armoury-twins`, `lh-lone-duck-ring`). A Thunder sword that no head in 840 years could wake, and a regalia ring sitting in a creditor's vault. This is the user's "roots against sect" complaint turned into a story and a growth goal.
2. **Thính Vũ's Canon of the Thunder Heard in the Rain, with the Tương Phi Tán.** The head's root opens only the Metal half of his own canon ("that is the head's limit, and he knows it"), and the umbrella turns aside the Thunder he cannot hold. The lineage, the root and the item make one idea.
3. **Hồng Đậu's Phi Hồng and The Second Cup** (`hd-phi-hong`, `hd-tea-at-the-manor`, `canon-of-longing`). Poisons that ripen rather than strike, a half-asleep sword waiting for its pair, and a Charm finisher: gracious and cruel at once.
4. **Kim Vạn Lý's Losing Hand** (`mf-losing-hand`, "Lose to Win"). A merchant who bets badly on purpose, and a set that banks the crits he takes for his coin art. It is funny, and the world needs more of that. Fix its Hán-Việt first (item 12).
5. **Nhạn Trận Môn's Wild Geese Formation Canon and Thối Tinh's Star-Quench.** One is "a method for a file, not for one person"; the other is a quench mark that makes a struck blade brittle. Both mechanics come straight from the sect's history and trade.

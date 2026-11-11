# The Dry Well (Khô Tỉnh)

Make the enemy pay for every point their ward stops, until the well runs dry before their first volley; then strike a cultivator with no ward at all.

## Why it works

Four rules of the fight make this build possible.

1. **A ward is a bucket in a well.** The usual ward (the Common Ward, Hộ Thể Chân Khí) is paid by *drain*: every point of
   damage it stops costs the defender linh lực. Big hits cost a lot. When the pool is empty, the drain ward, the per-hit
   ward and even the default ward are all down, and the defender cannot pay for arts (Combat rule 23). Only defence they
   built outside the pool (reserved wards, resistance from items, body shields) stays.
2. **Ice (Băng) attacks the pool.** Each Ice stack on an enemy makes their arts cost 3.9 % more, with no cap. Your Ice
   purity makes each stack stronger. An enemy under 30 Ice stacks pays about three times the normal price for every art.
3. **Absolute Zero (Hàn Thuế) puts the Ice into the bucket too.** Normally Ice never touches a ward's payment. This build's
   keystone changes that for you alone: your Ice stacks also raise what the enemy's drain ward bills against your hits.
   The more stacks, the dearer their defence. Every half second the needle adds stacks, and the next bill is bigger. In
   exchange, Ice's raise on their art costs is halved.
4. **An art can wait for the right moment.** Every art can carry a guard. Your "bucket" arts fire only while the enemy
   has linh lực (5 % or more). Your "blade" arts fire only when the enemy is dry (5 % or less). The blades wait ready,
   and fire in the same millisecond the enemy's pool reaches 0.

**The numbers.** All are first guesses, at Nguyên Anh (Nascent Soul) in a prepared fight, worked by hand on today's
rules. The project's fight calculator, `fight_calc.py`, still runs on the rules from before the #44 economy revision (31 of
its 60 constants are out of date) and cannot express Ice stacks, Absolute Zero or the new ward maths, so its results are
observations, not proof.

- Against a **top-end opponent** whose arts first fire at 2.0 s: your bills take its pool from 4,030 to 2,342 at 1.0 s and
  to 339 at 1.5 s. At 2.0 s its pulse and your Qi Disruption tick leave it at 0. Its six arts are ready and cost 478 each:
  **none fire.** Your Undertow (Ám Lưu) lands on 300 points of resistance instead of 1,500: 15,950 damage against 10,753
  health left. **You win at 2.0 s with 81 % health.**
- **The identity test:** the same fight **without Absolute Zero** is a **loss at 2.0 s**. The enemy still holds 2,067 linh lực,
  pays for two Ice-taxed arts, and two hits of 76,800 go through your ward.
- Against a heavily warded master (1,500 points of resistance, ordinary offence): **win at 2.0 s, no health lost**. Its
  arts never fire.
- Against a boss with four times the pools: **win at about 3.0 s.** It fires one volley at 2.0 s, which empties it.
- At **Trúc Cơ** (Foundation Establishment), before the keystone: against a strong warded foe the Ice alone makes it
  spend itself silent by about 5 s, and you win at about 11 s with 40 % health. Without the Ice, you lose.
- `fight_calc.py` (old rules): win at 1.000 s against the typical Nguyên Anh profile; loss at 1.000 s against its
  top-end profile, whose art fires every second (see "What beats it").

## What to look for

In the order you will meet them.

1. **Spiritual root (linh căn): Water (Thủy) with the Ice variant (Băng)**, Water purity 80 or more. Ice is a
   transmutation of Water: rare at birth (a few in a hundred Water roots), and its purity is 0.8 × your Water purity.
   Water and Ice share half their purity for stacks, so Water 90 gives Ice stacks ×1.23. *In the game.* A Water root
   without Ice can play the early half, but the technique below names Ice, so it cannot use it.
2. **Talents:** Comprehension (ngộ tính) for technique layers and Way glimpses; Root bone (căn cốt) second, because you
   take the opening on shields and health. *In the game.*
3. **Đạo:** **Vụ Đạo** · *Yên Vũ* (Misty Rain). *In the game's Way catalogue; its graph is not drawn yet.* Two facets:
   - **Chìm** (Drowning: linh lực burn): **Owed Water (Thủy Trái)**, *not in the game yet (staged: owed-water)*; **Bare Vessel (Lộ Đỉnh)**, *not in the game
     yet (an earlier build's piece, placed here by vu-chim-drowning)*; lines of Weighted Bucket and Force penetration
     on the way in, *not in the game yet (staged: vu-chim-drowning, weighted-bucket)*.
   - **Hàn Vụ** (Cold Mist: Ice debuff): Ice stack effect, Ice stack duration, art speed for Ice arts, three **Cold
     Depths (Hàn Uyên)** notables, and **Cracked Clay (Nẻ Đất)**. *Not in the game yet (staged: vu-han-vu-frost,
     cold-depths, cracked-clay).*
   - A glimpse of **Băng Đạo** (Sương Giá) for a fourth Cold Depths. *In the catalogue; graph not drawn.*
4. **Công pháp: Dry Well Scripture (Khô Tỉnh Quyết)**, main, names Water and Ice. Huyền giai (to Kết Đan), then the Địa
   giai copy **Khô Tỉnh Kinh** (to Nguyên Anh). *Not in the game yet (staged: dry-well-scripture).* Before you find it,
   the in-game Huyền Thủy Địa Quyết is a fine main technique for linh lực.
5. **Arts (from the scripture).** *Not in the game yet (staged: rime-needle, leaking-seal, drowning-palm, undertow,
   well-mouth-spring, dry-riverbed).*
   - **Rime Needle (Sương Châm)**: cheap, every second; 8 Ice stacks. A bucket.
   - **Leaking Seal (Lậu Ấn)**: puts the Leaking Ward curse on them (their drain wards bill +50 %). A bucket.
   - **Drowning Palm (Nịch Thủy Chưởng)**: a Force hit; Qi Disruption, which burns linh lực for three pulses. A bucket.
   - **Undertow (Ám Lưu)**: the first blade.
   - **Spring at the Well's Mouth (Tỉnh Khẩu Tuyền)**: a heal that refunds its cost when it heals.
   - **Dry Riverbed (Khô Hà)**: the second blade, part Physical, for Cold-warded foes.
6. **Items.**
   - A Cực phẩm needle (Châm) weapon and a robe (Giáp) for ward strength. *In the game.*
   - **Cold-Marrow Pill (Hàn Tủy Đan)**: taken before a foreseen fight, +70 "more" on Cold hits (L4). *Not in the game
     yet (staged: cold-marrow-pill).*
   - **Nine Rods Array (Cửu Can Trận)**: laid on the ground before a foreseen fight, +80 L4 on arts. *Not in the game yet
     (staged: nine-rods-array; first made for another build).*
   - The **Mountain Screen** and **Thousand-Layer Cloud** wards: reserved shields that start full. *In the game (designed
     in the defence GDD).*
7. **Enabler: the Well-Drawing Gourd (Cấp Tỉnh Hồ Lô)**, a named gourd that carries **Water Table (Thủy Mạch)**. *The
   Effect is in the game (designed in the Effects GDD); the gourd is not in the game yet (staged: well-drawing-gourd).*
   Look for it at Nguyên Anh, at the old dry well in the drought country or on a well-thief NPC.

## The enabling Effects

- **Water Table (Thủy Mạch)**: you gain 30 % of the linh lực the enemy's drain wards pay against your hits. **Closes:**
  your linh lực never regenerates in fights. In the opening the enemy is full and paying, so you drink 500–600 a
  second, more than your bucket arts cost. That is how the build survives the opening: their full well is your fuel.
  *In the game (designed; not built yet).*
- **Absolute Zero (Tuyệt Đối Linh Độ)**, Băng Đạo's capstone (the build's second Way): your Ice stacks also raise the
  drain bills their wards pay against your hits and ticks, by the same share they raise art costs. **Closes:** your
  Ice's raise on their art costs is halved. It is the build: it turns the slow Ice clock into a fast one. *Not in the
  game yet (Băng Đạo draft; the staged Absolute Zero was merged into it, user decision 2026-11-11).*
- **Owed Water (Thủy Trái)**: linh lực your burns and bills cannot take, because their pool is empty, becomes their
  debt (up to 40 % of their maximum). Their regeneration pays the debt before it refills them, and you get half of every
  repayment. It keeps a dry enemy dry and feeds you after Water Table goes quiet. In the short fights above it changes
  little; it is for long fights. *Not in the game yet (staged: owed-water).*
- **Bare Vessel (Lộ Đỉnh)**: +80 "more" (L5) on your hits while the enemy has under 5 % linh lực. *Not in the game yet
  (from an earlier build's content ledger; placed in Vụ Đạo here).*
- **Cracked Clay (Nẻ Đất)**: your Cold hits deal +4 more (L5) per 10 of your Ice stacks on the target, up to +20.
  Before the dry point it is your only L5; with Bare Vessel it fills L5's cap exactly. *Not in the game yet (staged:
  cracked-clay).*
- **Frost Tithe (Sương Thuế)**, an Ice keystone on the meridian map: you gain 9 % of the extra art cost your Ice makes
  them pay. *Not in the game yet (staged: frost-tithe).*
- **Still Water (Tĩnh Thủy)**: linh lực lost to a full pool heals you at half. When Water Table overfills you in the
  opening, the overflow becomes health. *In the game (designed; not built yet).*
- **Leaking Ward (Lậu Hộ)**, a curse from Leaking Seal: their drain wards bill 50 % more for 3 pulses. *In the game
  (designed; not built yet).*
- **Qi Disruption (Loạn Khí)**, a status from Drowning Palm: a Force tick on linh lực, 3 stacks, 3 pulses. *In the game
  (designed; not built yet).*

## Modifiers to stack

Most important first.

1. **Ice stack effect** (`stack_effect_pct` [bang, debuff]), the multiplier on every stack. Fills: the Ice debuff (and
   through Absolute Zero, the bill). Aim for +50 %. No cap; stop when Rime Needle's stacks already empty a top-end pool by
   your enemy's first cooldown (about +50 % at Nguyên Anh).
2. **Weighted Bucket** (`ward_bill_pct`), bills against your hits and ticks. Fills: the bill. Aim for +30 % (the gourd
   15, the Well-Rope cluster 15). Falling returns: a bill can never take more than the pool holds, so past the point
   where your 1.5 s instant already empties them, more does nothing.
3. **Art speed for Ice arts** (`art_speed_pct` [bang]). Fills: rate. Aim for +100 % (needle every 0.5 s). Stop there: a
   1 s needle hits the 0.5 s floor (`cooldown_min`) at +100 %.
4. **Cold Depths** (+40 "more" on Cold, L2). Fills L2. Aim for 4 of them, with the scripture's passive (+60 [bang]):
   220 points. L2 caps at 300; a fifth Cold L2 source would fill it (none is authored yet).
5. **Damage, then Cold damage** (`attack_pct`, `attack_pct` [cold]). Fills L1. Aim for about 300 points. Past 200 each
   point counts half; L1's cap is 400.
6. **Ice stack duration** (`stack_duration_pct` [bang, debuff]), +40 % (5 s → 7 s), and one rare **+1 Ice per grant**
   (`stack_grant`). Fills: stack count. Stop at +40 %: fights end long before the stacks fall off.
7. **Force penetration** (`resist_pen_pct` [force]), +300 points. Fills reach for Qi Disruption. No cap; it only matters
   for the palm.
8. **Ward strength and ward efficiency** (`defense_pct`, `ward_efficiency_pct`). Fills: survival in the opening (your
   drain ward and two shields). Aim for about +150 and +100. No ceiling; each point of resistance counts a little less.
9. **Maximum linh lực** (`linh_luc_pct`). Fills: your own well, since you do not regenerate. The scripture gives 20, the
   gourd 10.
10. **Preparation (L4)**: Cold-Marrow Pill +70 and Nine Rods Array +80 reach L4's cap of 150. Foreseen fights only.
11. **Crit: none.** The build trades it away: the blades fire into an empty ward, which is certainty enough.

## Upgrades to look for

Your shopping list, core first. A build that has the **core** rows works; the **strong** rows make it top-end; the **nice**
rows polish it or patch a weakness. "Staged" means the piece is written up in the run's staging catalogue but is not in
the game's data yet. Pieces marked "catalogue only" are in the tree modifier catalogue as designed ideas, not built.

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Absolute Zero (Tuyệt Đối Linh Độ) | Effect (enabler) | Your Ice stacks also raise the drain bills their ward pays. It is the build: without it the top-end foe is a loss at 2.0 s | Băng Đạo capstone (Absolute Zero merged into it, 2026-11-11) | not in the game yet (Băng Đạo draft) | core |
| Ice stack effect (`stack_effect_pct` [bang, debuff]) | Modifier | Makes every Ice stack hit harder, on art costs and, through Absolute Zero, on bills. Aim for +50 % | Vụ Đạo Hàn Vụ lines; Well-Rope cluster farthest notable (+24) | not in the game yet (staged: vu-han-vu-frost, well-rope-cluster) | core |
| Weighted Bucket (Trụy Dũng, `ward_bill_pct`) | Modifier | Their drain ward bills more for every point it stops. Aim for +30 | Well-Drawing Gourd affix (+15); Well-Rope notable (+15); Vụ Đạo Chìm lines | not in the game yet (staged: weighted-bucket) | core |
| Dry Well Scripture (Khô Tỉnh Quyết / Khô Tỉnh Kinh) | Modifier (+60 [bang] on L2) with the six arts | The main công pháp: the Ice and Cold L2 passive, Rime Needle, Leaking Seal, Drowning Palm, the two blades and the heal | Công pháp (Huyền giai to Kết Đan, Địa giai to Nguyên Anh) | not in the game yet (staged: dry-well-scripture) | core |
| Water Table (Thủy Mạch) on the Well-Drawing Gourd (Cấp Tỉnh Hồ Lô) | Effect (enabler) | Drinks 30 % of what their ward pays: 500–600 linh lực a second in the opening, which pays for your bucket arts. Closes your regeneration | Named item: the old dry well in the drought country, or a well-thief NPC at Nguyên Anh. Gourd also gives Weighted Bucket +15 and max linh lực +10 | Effect in the game (designed); gourd not in the game yet (staged: well-drawing-gourd) | core |
| Leaking Ward (Lậu Hộ) | Effect (curse) | Their drain wards bill +50 % for 3 pulses, laid by Leaking Seal | Leaking Seal (Dry Well Scripture, layer 3) | in the game (designed; not built yet); the art is not in the game yet (staged: leaking-seal) | core |
| Art speed for Ice arts (`art_speed_pct` [bang]) | Modifier | Needle every 0.5 s, so the stacks and bills come twice a second. Stop at +100 | Tree notables (+3 % each); Hàn Vụ lines; Well-Rope smalls | in the game, partly (tree notables designed); Vụ Đạo lines staged (staged: vu-han-vu-frost) | core |
| Cold Depths (Hàn Uyên) | Modifier (+40 "more" on Cold, L2) | The build's L2. Four of them with the scripture give 220 of 300 | Vụ Đạo Hàn Vụ ×3; Băng Đạo (Sương Giá) glimpse ×1 | not in the game yet (staged: cold-depths) | strong |
| Bare Vessel (Lộ Đỉnh) | Effect | +80 "more" (L5) on your hits once they are under 5 % linh lực: the payoff of the dry point | Vụ Đạo Chìm notable | not in the game yet (earlier build's piece, `design/builds/content-ledger.md`; placed in Vụ Đạo by vu-chim-drowning) | strong |
| Cracked Clay (Nẻ Đất) | Effect | +4 "more" (L5) per 10 Ice stacks, up to +20, so the hits before the dry point count too. With Bare Vessel it fills L5 exactly | Vụ Đạo Hàn Vụ minor; Băng Đạo Sương Giá minor | not in the game yet (staged: cracked-clay) | strong |
| Frost Tithe (Sương Thuế) | Effect (keystone) | You gain 9 % of the extra art cost your Ice makes them pay: more fuel in the opening | Meridian Map keystone, Water land's Ice reach | not in the game yet (staged: frost-tithe) | strong |
| Nine Rods Array (Cửu Can Trận) | Effect from a formation (Ringing Ground, +80 L4) | Half of L4's cap (150) in foreseen fights | Formation, laid before a foreseen fight | not in the game yet (staged: nine-rods-array) | strong |
| Cold-Marrow Pill (Hàn Tủy Đan) | Modifier (+70 "more" on Cold, L4) | The other half of L4: with the array it reaches the cap | Pill taken before a foreseen fight (an Ice root shrugs off its toxicity) | not in the game yet (staged: cold-marrow-pill) | strong |
| Owed Water (Thủy Trái) | Effect | Keeps a dry foe dry through its regeneration and pays you half of each repayment; your only income after the dry point | Vụ Đạo Chìm major | not in the game yet (staged: owed-water) | strong |
| Damage, then Cold damage (`attack_pct`, `attack_pct` [cold]) | Modifier | Fills L1. Aim for about 300 points; past 200 each point counts half | Tree notables (+8 % each, Cold +12 %); Way W; the technique; Cực phẩm needle (Châm) | in the game (the Cold-tagged notables are designed) | strong |
| Ward strength and ward efficiency (`defense_pct`, `ward_efficiency_pct`) | Modifier | Survives the opening: the drain ward and shields take the first volley. Aim for about +150 and +100 | Tree notables (+8 % each); the Giáp robe; the scripture (+15) | in the game | strong |
| Mountain Screen and Thousand-Layer Cloud | Effect (reserved shields, about 6,110 points) | Shields that start full, so the opening hits do not need linh lực | Ward slots, Kết Đan (second slot) and Nguyên Anh (third) | in the game (designed in the defence GDD) | strong |
| Sheathed Blade (Ẩn Phong) | Effect (keystone) | The blades wait ready for the dry point; this makes an art that waited hit harder per second waited | Meridian Map keystone idea | not in the game yet (catalogue only: tree modifier catalogue, Rule-benders) | nice |
| Damage to an enemy with no linh lực | Modifier | +15 % on a notable, a second payoff for the dry point | Tree notable | not in the game yet (catalogue only: tree modifier catalogue, Damage) | nice |
| Spirit Severing (Đoạn Linh) | Effect (keystone) | Your hits also burn their linh lực: a second clock beside the bills | Meridian Map keystone idea | not in the game yet (catalogue only: tree modifier catalogue, Rule-benders) | nice |
| Unyielding Breath (Bất Khuất) | Effect (keystone) | Once a fight, a killing blow leaves you at 1 health: lives through one volley from a foe faster than 1.5 s (the build's main weakness) | Existing keystone | catalogue only (a designed keystone in the tree modifier catalogue, Rule-benders; this guide calls it existing) | nice |
| Still Water (Tĩnh Thủy) | Effect | Overflow of linh lực in the opening heals you at half | Vụ Đạo or the tree | in the game (designed; not built yet) | nice |
| Maximum linh lực (`linh_luc_pct`) | Modifier | A bigger own well, since you do not regenerate. The scripture gives 20, the gourd 10 | Tree notables (+8 % each); scripture; gourd | in the game | nice |
| Ice stack duration (`stack_duration_pct` [bang, debuff]) and +1 Ice per grant (`stack_grant`) | Modifier | Stacks last 7 s instead of 5 s; one rare extra stack per hit. Stop at +40 % | Vụ Đạo Hàn Vụ lines; Well-Rope smalls | not in the game yet (staged: vu-han-vu-frost, well-rope-cluster) | nice |
| Force penetration (`resist_pen_pct` [force]) | Modifier | Qi Disruption lands more on a warded foe. Aim for +300 | Vụ Đạo Chìm lines | not in the game yet (staged: vu-chim-drowning) | nice |
| Driven Nail (Đóng Đinh) | Effect | Each curse you lay (Leaking Ward) shortens your slowest art's timer by 0.5 s, so Dry Riverbed comes sooner | Sinh Tử Đạo, Diệt facet major; a named item | not in the game yet (staged: driven-nail) | nice |
| Formation power and pill effect (`formation_power_pct`, `pill_effect_pct`) | Modifier | Make the array and the pill bigger inside L4's cap, so a weaker pill still reaches it | Tree notables (+8 % and +6 %) | in the game | nice |

**The jump from working to top-end:** Absolute Zero alone makes the build work. The strong rows decide how fast: Cold Depths
fill L2, Bare Vessel and Cracked Clay fill L5, the pill and the array fill L4, and Frost Tithe plus the gourd keep you
fuelled through the opening. A fifth Cold L2 source is still missing from the game (the sheet's planned 260 points).

## Realm by realm

- **Trúc Cơ (Foundation Establishment), 4 art slots, 1 ward slot.** Dry Well Scripture (Huyền giai): Rime Needle, Leaking
  Seal, Drowning Palm, Undertow. Common Ward. Your linh lực still regenerates. You are a patient needler: Ice makes a
  strong foe's arts so dear that it empties itself casting them, and by about 5 s it is silent. Then Undertow fires on an
  empty ward. Fights last 10–15 s against strong foes.
- **Kết Đan (Core Formation), 5 slots, 2 ward slots.** The Way of Mist (Vụ Đạo): Owed Water, Bare Vessel,
  Cracked Clay, Cold Depths; and the Way of Ice (Băng Đạo), glimpsed this realm, for its capstone Absolute Zero. Add Spring at the Well's Mouth and Mountain Screen. Now the Ice taxes their ward too, and
  the dry point comes twice as fast.
- **Nguyên Anh (Nascent Soul), 6 slots, 3 ward slots.** The Địa giai Khô Tỉnh Kinh and Dry Riverbed; Thousand-Layer
  Cloud; the **Well-Drawing Gourd**. You stop regenerating and start drinking from their ward. Strong foes are dry by
  2.0 s and dead in the same instant. The story beat: like the scripture's founder, you no longer refill on your own.

## How it plays

**Art order:** Rime Needle, Leaking Seal, Drowning Palm, Undertow, Dry Riverbed, Spring at the Well's Mouth. The needle
goes first so the Ice always goes out; the seal second, so the curse is on before the palm's bill; Undertow before Dry
Riverbed, so the cheaper blade pays first when both are ready.

**Guards:** buckets (needle, seal, palm) "enemy linh lực at or above 5 %"; blades (Undertow, Dry Riverbed) "enemy
linh lực at or below 5 %"; Spring "own health at or below 70 %".

**Wards:** Common Ward, Mountain Screen, Thousand-Layer Cloud. **Before a foreseen fight:** Cold-Marrow Pill, Nine Rods
Array.

**The fight:** half a second in, a rime needle finds them and their ward pays. A second in, the seal follows and their
ward pays more, because the frost is in their channels now. At 1.5 s the palm lands with Qi Disruption. At 2.0 s their
arts come off cooldown, and the pool that should have paid for them is gone.

**The signature moment:** the 2.000 s line of the Breakdown: "enemy linh lực 0 · 6 arts ready, unpaid · Undertow:
15,950 (no ward)".

## What beats it

- **Anyone faster than 1.5 s.** An alpha-strike build that fires at 0.5 s (another build of this run, the First Volley),
  or a top-end cultivator whose arts first fire at 1 s, hits you while their pool is still 90 % full. *Adapt:* stack
  ward strength and shields, or carry Unyielding Breath (an existing keystone: once a fight, a killing blow leaves you
  at 1) to live through one volley.
- **A drainer with a reserved ward** (Combat rule 18's linh lực drainer: Qi Disruption or soul arts, behind Still Lake
  Aura or Iron Shirt). Its defence is paid before the fight, so starving it changes nothing, and it drains you while
  Water Table has stopped your regeneration. *Adapt:* take the gourd off (your regeneration returns), slot Mountain
  Screen and a reserved resistance ward, and fight it as a plain Cold caster.
- **Reserved-ward and per-hit-ward casters.** Absolute Zero only taxes drain bills, and its close halves your Ice. You still
  win (about 3–4 s against a reserved healer), but the payoff after the dry point is a tenth of their damage, not a
  quarter. *Adapt:* lean on Dry Riverbed and Leaking Seal's raw damage.
- **A body cultivator (thể tu).** Its block, body shields and Physical resistance need no linh lực. An even fight on raw
  Cold damage. *Adapt:* Dry Riverbed's Physical part meets its Physical resistance, so slot Undertow first.
- **A cleanser with high status resistance** (Clear Heart Ward and status nodes): your Ice, Leaking Ward and Qi
  Disruption land less often and are cleansed each pulse. The dry point comes later. *Adapt:* more art speed on the
  needle, and Drowning Palm earlier in the slot order.

## Not in the game yet

Every staged piece this build needs (`design/builds/overnight-2026-11-10/staging-catalogue.md`):

- **Effects:** Absolute Zero (Băng Đạo; was staged cold-toll), owed-water (Owed Water), cracked-clay (Cracked Clay), frost-tithe (Frost Tithe).
- **Modifiers:** weighted-bucket (Weighted Bucket, new stat `ward_bill_pct`), cold-depths (Cold Depths).
- **Công pháp:** dry-well-scripture (Dry Well Scripture, Huyền and Địa giai).
- **Arts:** rime-needle, leaking-seal, drowning-palm, undertow, well-mouth-spring, dry-riverbed.
- **Items:** well-drawing-gourd (Well-Drawing Gourd), cold-marrow-pill (Cold-Marrow Pill), nine-rods-array (Nine Rods
  Array, reused from first-volley).
- **Đạo pieces:** vu-chim-drowning (Vụ Đạo Chìm), vu-han-vu-frost (Vụ Đạo Hàn Vụ).
- **Concepts and keys:** linh-luc-debt (owing linh lực), pool-shortfall (readable), ice-extra-cost (readable),
  well-rope-cluster (the Well-Rope sealed cluster).
- From earlier work, not in this run's staging: **Bare Vessel** (`design/builds/content-ledger.md`) and **Ringing
  Ground** (the tree modifier catalogue), both not in the game yet.

## Changes the game would need

1. **Let one keystone carry Ice onto drain bills** (Absolute Zero). Today Ice raises art costs and never a ward-slot payment
   (`design/gdd/combat-defence.md` Edge Cases, a user decision of 2026-11-10; `design/gdd/effects.md` rule 9a). The
   proposal keeps that rule for everyone and lets one named keystone override it for its owner, with the bill still
   bounded by the live pool (`combat-defence.md` Formulas C).
2. **A linh lực debt** (Owed Water). A new concept on the linh lực bar: a side may owe linh lực, up to a cap; while it
   owes, regeneration pays the debt first and it counts as having no linh lực. Touches `design/gdd/combat.md` rule 11
   and Formulas E, `combat-defence.md` rule 8, and `effects.md` rule 6 (a new action, "add debt").
3. **Two new readables** for Effects (`effects.md` rule 5): the linh lực a burn or bill could not take because the pool
   was short (for Owed Water), and the extra art cost your Ice stacks added (for Frost Tithe).
4. **A new stat, `ward_bill_pct`** (Weighted Bucket), in the Modifier System's Stat List (`design/gdd/modifiers.md`),
   applied in `combat-defence.md` Formulas C.
5. **A lint charge for curses** (`combat.md` Formulas C, `effects.md` Formulas D). The build does not need this; it
   exposes it. Leaking Seal applies a +50 % bill curse and keeps 96 % of a plain art's damage, because curses cost
   nothing in the art lint today.

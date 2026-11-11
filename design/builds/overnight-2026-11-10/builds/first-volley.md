# The Flash Before the Thunder (Tiên Điện Hậu Lôi)

Four Lightning arts leave your hands together half a second into the fight, and most opponents never get to act.

## Why it works

Three rules of the fight make this build possible.

1. **Nothing fires at the start, and nothing fires faster than half a second.** Every art waits one full cooldown before its first use, and no cooldown can drop below 0.5 s (`cooldown_min`). Art speed shortens cooldowns. This build adds a new stat, **opening haste (Tiên Phát)**, which shortens only each art's *first* wait. Together they put all four of your volley arts at exactly 0.500 s, before anyone's first basic attack (1.0 s) and before the first pulse.
2. **A ward pays for every point it stops.** The usual ward (the Common Ward) spends the defender's linh lực in proportion to the damage it prevents. One very large hit costs more linh lực than the defender has, so the ward runs dry *during* that hit, and every later hit in the same instant meets no drain ward at all. Your first slot is the **Breaker**, the Cloud-Splitting Bolt (Phá Vân Lôi). It exists to empty that pool, and the three cheap arts behind it land almost in full.
3. **Everything in one instant lands before anyone is judged.** If the enemy's opener also fires at 0.5 s, both of you take your hits. Then the "Down" step runs: a refusal (Unyielding Breath, Bất Khuất) keeps you at 1 health, the enemy stays Down, and you win. If the enemy refuses instead, your fifth art, Rolling Thunder (Hậu Lôi), waits for exactly that. Its guard is "enemy at half health or less", so it fires in the follow-up instant of the same millisecond.

**The numbers.** All are first guesses, at Nguyên Anh (Nascent Soul) in a prepared fight.

- Your damage multiplier for the first volley is **M 228** (every layer filled: L1 ×3.80, L2 ×4.0, L3 ×3.5, L4 ×2.5, L5 ×1.72), and crits are at both caps (50 % chance, ×3.0).
- `fight_calc.py`, given the volley at 0.500 s: **wins at 0.500 s** against the typical and the top-end profile at your realm and one or two realms up. The Breaker alone dealt 168,452 against the typical profile.
- The identity test: with the volley left at its normal 1.333 s, the same build **is knocked out at 1.000 s** by the top-end profile's first basic attack. Opening haste is the build.
- By hand, with the current ward rules: against a top-end cultivator, even a volley with no crits deals about 42,000 against 22,400 health. A floor tie against a top-end opener is won every time with Unyielding Breath, and about 4 times in 10 without it.
- Caveat: `fight_calc.py` still runs on rules from before the #44 economy revision (31 of its 60 constants are out of date), so these are observations, not a verdict. A current-rules script, `first-volley.volley.py`, sits next to this guide but has not been run yet.

## What to look for

In the order you will meet them.

1. **Spiritual root (linh căn): Thunder (Lôi)**, the convergence of Fire and Metal, purity 60 or more. It gives +0.30 % damage per purity point and every Lightning tag the build scales with. *In the game.*
2. **Talents:** Comprehension (ngộ tính), to reach layer 12 of your technique. Spend as little as you can on Root bone (căn cốt): this build does not buy health. *In the game.*
3. **Đạo:** **Lôi Đạo** · *Cửu Thiên Lôi* (Thunder of the Nine Heavens), facet **Thiểm Điện** (Lightning: crit, speed). *In the game's Way catalogue; its graph is not drawn yet.* Nodes to buy:
   - "Before the Sound" (two notables, opening haste +40 each). *Not in the game yet (staged: thiem-dien-before-the-sound).*
   - Art speed [Thunder], crit chance [Lightning], three L2 "more" notables. *Not in the game yet (staged: thiem-dien-before-the-sound).*
   - **Unanswered (Vô Ứng)**, the facet's big Effect. *Not in the game yet (staged: unanswered).*
   - Second Way: Ám Đạo (Thích Khách, first strike) or Thời Đạo (Tốc, art speed).
4. **Công pháp: Lôi Đế Chân Kinh** (Thunder Emperor True Canon), main, Địa giai, 12 layers. *In the game*, but its arts and passive are *not in the game yet (staged: loi-de-chan-kinh-abilities)*. Two auxiliary Lightning secret techniques add L2 "more" (none exist in the data yet; any will do).
5. **Arts (from the canon).** *Not in the game yet (staged: cloud-splitting-bolt, forked-light, thunder-needle, iron-spark, rolling-thunder, lightning-step).*
   - Cloud-Splitting Bolt (Phá Vân Lôi): the Breaker, big and costly.
   - Forked Light (Xoa Điện): a cheap follower.
   - Thunder Needle (Lôi Châm): cheap; leaves Leaking Ward on the target.
   - Iron Spark (Thiết Tinh): cheap; 60 % of it turns Physical.
   - Rolling Thunder (Hậu Lôi): the finisher.
   - Lightning Step (Lôi Độn): the escape.
6. **Items.**
   - Two Cực phẩm seals (Ấn) of the Nguyên Anh tier with the Liệt affix: they fill the gear layer by themselves. *In the game.*
   - **Herald's Banner (Tiên Thanh Kỳ)**: First Move and opening haste +40. *Not in the game yet (staged: herald-banner).*
   - **Thunder-Gall Pill (Lôi Đởm Đan)**: taken before a foreseen fight. *Not in the game yet (staged: thunder-gall-pill).*
   - **Nine Rods Array (Cửu Can Trận)**: laid on the ground before a foreseen fight. *Not in the game yet (staged: nine-rods-array).*
7. **Enabler:** none. The build is a stack, and its one new piece is the opening haste stat. *Not in the game yet (staged: opening-haste).*

## The enabling Effects

Each one, what it does, and why the build needs it.

- **First Move (Tiên Thủ)**: your first art of the fight costs no linh lực. It pays for the Breaker, so the whole first volley costs only 234 linh lực (6 % of your pool) and your own ward stays full in that instant. *In the game (designed in the Effects GDD; not built yet).* Carried by Herald's Banner.
- **Unyielding Breath (Bất Khuất)**: once a fight, a blow that would put you Down leaves you at 1 health. Costs 15 % maximum health. It wins every 0.5 s tie against a top-end opener. *In the game (designed; not built yet).*
- **Unanswered (Vô Ứng)**: while the enemy has fired no art this fight, your arts deal +40 more (layer L5). It stays true in a shared 0.5 s instant, because conditions are read at the instant's start. *Not in the game yet (staged: unanswered).*
- **Eruption (Phún Trào)**: your hits deal +5 more (L5) for each other art you fired in the same instant, up to +25. It pays you for firing together. *Not in the game yet (staged: eruption).*
- **Taut String (Huyền Căng)**: opening haste beyond what reaches the 0.5 s floor turns into extra damage on that first firing, +1 (L5) per 5 % clipped, up to +30. It is the reason to keep stacking opening haste past the floor. *Not in the game yet (staged: taut-string).*
- **Flowing Water (Lưu Thủy)**: each crit pulls your other arts' timers 0.5 s closer (3 a pulse). With two crits in the first volley, the second volley comes at 1.0 s instead of 1.833 s. *In the game (designed; not built yet).*
- **Final Clause (Mạt Khoản)**: as you go Down, your longest-cooldown art fires free. The Breaker goes first by slot order, so you can still swing a double knockout. *In the game (designed; not built yet).* Comes with the canon's layer 12.
- **Glass Meridians (Lưu Ly Kinh Mạch)**: +40 % art speed for −25 % health and half body shields. It is the glass in the glass cannon. *In the game (designed; not built yet).*
- **Cold Feet (Hàn Túc)**: your escape art's first firing comes at the floor. *In the game (designed; not built yet).*
- **Leaking Ward (Lậu Hộ)**, a curse from Thunder Needle: the target's drain wards bill 50 % more for 3 pulses, so a survivor's ward breaks faster on your second volley. *In the game (designed; not built yet).*

## Modifiers to stack

Most important first. The layer each fills is in brackets.

1. **Opening haste** (none: timing). Your volley needs `(1 + art speed) × (1 + opening haste) ≥ 8` for 4 s arts. Stop at about +170 % with art speed at +200 %; that reaches the floor. Past it, each extra 5 % becomes +1 L5 through Taut String. Stop for good when Taut String reaches +30, or your L5 reaches 100.
2. **Crit chance** (outside the layers). Stop at the 50 % cap. Crit damage: stop at the ×3.0 cap (+150 % over the base ×1.5).
3. **L2 "more" for Lightning** (L2, cap 300). From the technique, the arts, Lôi Đạo and two auxiliary techniques. Stop at 300.
4. **Gear attack** (L3, cap 250). Two Cực phẩm Nguyên Anh seals with Liệt reach it. Stop there and spend thần thức on the banner.
5. **Preparation** (L4, cap 150). The pill (+70) and the array (+80). Only in foreseen fights; in a blind fight this layer is empty and your multiplier drops from 228 to 91, which still kills an ordinary opponent.
6. **Art speed** (none). +200 % makes the reload cycle 1.333 s. Past that, your linh lực cannot pay for faster volleys, so stop.
7. **Damage increased, `attack_pct` and [lightning]** (L1). Worth full value to +200. Past that each point counts half (the soft cap), so stop near +200 to +300 and put points into crit or art speed instead.
8. **Linh lực on crit** (+1.26 % of maximum per crit) and **art cost −20 %** (none). Enough to pay for two or three reload volleys. More is wasted: if the second volley has not won, linh lực is not what you are short of.
9. **Accuracy** (none). +15 against evasive foes. Stop when the foe's evade minus your accuracy is near zero.

## Upgrades to look for

Your shopping list for improving this build, core first. "Core" pieces turn a plain Lightning caster into a volley build; "strong" pieces turn a working build into a top-end one; "nice" pieces smooth the edges. Pieces marked "in the game" are in the game's data or designed in its GDDs; pieces marked "catalogue" are listed in the tree modifier catalogue but not built.

| Piece | Modifier or Effect | What it adds to this build | Where it comes from | In the game or staged | Priority |
|---|---|---|---|---|---|
| Opening haste (Tiên Phát) | Modifier (timing stat) | Brings every art's first firing to the 0.5 s floor; without it the volley comes at 1.333 s and you lose to a top-end opener | Công pháp passive "Before the Sound" +80, Lôi Đạo Thiểm Điện notables +80, Herald's Banner +40, Thunder-Gall Pill +30, Drawn Bowstring +20 | Not in the game yet (staged: opening-haste) | Core |
| Art speed [Thunder] | Modifier | +200 % total sets the reload cycle at 1.333 s and, with opening haste, reaches the floor | Tree art speed notables (Thunder island), Lôi Đạo, Glass Meridians +40 | In the game (tree catalogue ◐) | Core |
| Crit chance and crit damage [Lightning] | Modifier | To the caps (50 %, ×3.0): doubles the expected volley and feeds Flowing Water | Tree notables, Lôi Đạo Thiểm Điện notable | In the game | Core |
| L2 "more" for Lightning | Modifier | Fills the 300 cap (×4.0): the largest single multiplier you control | Canon passive +50, the arts' own +40, Lôi Đạo three notables +40, two auxiliary Lightning secret techniques +45 | Canon and Way pieces not in the game yet (staged: loi-de-chan-kinh-abilities, thiem-dien-before-the-sound); auxiliary techniques: none in the data yet | Core |
| Two Cực phẩm Nguyên Anh seals (Ấn) with the Liệt affix | Modifier (gear attack, L3) | Fill the gear layer to its 250 cap by themselves (×3.5) | Item affix on weapon seals | In the game | Core |
| Lôi Đế Chân Kinh arts, slot order Breaker first | Effect (art kit) | Cloud-Splitting Bolt empties the ward pool; three cheap followers land through it | Công pháp Lôi Đế Chân Kinh, layers 1 to 11 | Not in the game yet (staged: cloud-splitting-bolt, forked-light, thunder-needle, iron-spark, rolling-thunder) | Core |
| Unyielding Breath (Bất Khuất) | Effect | Wins every 0.5 s floor tie against a top-end opener | Meridian Map keystone | In the game (designed; not built) | Core |
| First Move (Tiên Thủ) | Effect | Makes the Breaker free, so the first volley costs only 6 % of your linh lực and your ward stays full | Herald's Banner | In the game (designed); the banner is not in the game yet (staged: herald-banner) | Strong |
| Unanswered (Vô Ứng) | Effect | +40 L5 while the enemy has fired no art; decides floor ties and big pools | Lôi Đạo Thiểm Điện major | Not in the game yet (staged: unanswered) | Strong |
| Thunder-Gall Pill (Lôi Đởm Đan) and Nine Rods Array (Cửu Can Trận) | Modifier (preparation, L4) | +70 and +80: fills the 150 cap (×2.5) in foreseen fights; the largest jump from 91 to 228 | Pill (alchemy), formation (Ringing Ground) | Not in the game yet (staged: thunder-gall-pill, nine-rods-array) | Strong |
| Eruption (Phún Trào) | Effect | +5 L5 per other art fired in the instant: +15 for a four-art volley | Way notable or canon passive | Not in the game yet (staged: eruption, arts-fired-this-instant) | Strong |
| Taut String (Huyền Căng) | Effect | Turns opening haste past the floor into up to +30 L5 | Drawn Bowstring cluster, far notable | Not in the game yet (staged: taut-string, drawn-bowstring-cluster) | Strong |
| Flowing Water (Lưu Thủy) | Effect | Each crit pulls your other arts 0.5 s closer: second volley at 1.0 s instead of 1.833 s | Meridian Map keystone | In the game (designed; not built) | Strong |
| Final Clause (Mạt Khoản) | Effect | A last free Breaker as you go Down; can swing a double knockout | Canon layer 12 | Effect designed; canon ability not in the game yet (staged: loi-de-chan-kinh-abilities) | Strong |
| Glass Meridians (Lưu Ly Kinh Mạch) | Effect (trade) | +40 % art speed for −25 % health | Meridian Map keystone | In the game (designed; not built) | Strong |
| Thunder Needle's Leaking Ward (Lậu Hộ) | Effect (curse) | Survivor's drain ward bills 50 % more, so the second volley breaks it faster | Thunder Needle art | Not in the game yet (staged: thunder-needle) | Nice |
| Linh lực on crit and art cost −20 % | Modifier | Pay for two or three reload volleys | Tree notables | Art cost in the game; linh lực on crit: catalogue only (not built) | Nice |
| Accuracy | Modifier | +15 against evasive foes (40 % cap down to about 25 %) | Tree notables | In the game | Nice |
| Iron Spark's Physical conversion | Modifier (conversion) | 60 % turns Physical and goes around a Lightning-only resistance wall | Iron Spark art | Not in the game yet (staged: iron-spark) | Nice |
| Cold Feet (Hàn Túc) | Effect | Lightning Step's first firing at the floor: a ready exit after a refusal | Meridian Map | In the game (designed; not built) | Nice |
| Thunderclap | Effect (control art) | Delays every enemy art 1 s; the boss loadout in slot 6 | By-root missing pieces | Not in the game yet (see by-root missing pieces; no staged id in this build) | Nice |

## Realm by realm

- **Trúc Cơ (Foundation Establishment):** awaken the Thunder root and take the Lôi Đạo glimpse. You play a plain Lightning caster with a quick opener.
- **Kết Đan (Core Formation):** five slots. With the Breaker, Forked Light, Thunder Needle, Rolling Thunder and Lightning Step, art speed +150 % and opening haste +100 %, the volley comes at **0.8 s**, still before any basic attack. In `fight_calc` it beats every profile at 0.800 s except a top-end cultivator two realms up. Take Glass Meridians here.
- **Nguyên Anh (Nascent Soul):** six slots; Iron Spark joins. The banner, pill, array and Drawn Bowstring cluster bring the volley to the **0.5 s floor**. Unyielding Breath becomes essential: at this realm other top-end fighters can also open at 0.5 s.
- **Hóa Thần (Deity Transformation):** the Thunder canon stops here (Địa giai reaches Nguyên Anh). You need a Thiên giai Thunder canon, which does not exist yet.

## How it plays

**Art order (slot order matters):**

1. Cloud-Splitting Bolt (the Breaker: biggest hit first)
2. Forked Light
3. Thunder Needle
4. Iron Spark
5. Rolling Thunder (guard: enemy at or below 50 % health)
6. Lightning Step (escape; guard: own health at or below 30 %)

**Loadout:**

- Wards: a Common Ward in your free ward slots.
- Artifacts: two seals and Herald's Banner.
- Before a foreseen fight: take the Thunder-Gall Pill and lay the Nine Rods Array.
- Against a boss or a tribulation: put Thunderclap (a control art that delays every enemy art by 1 s) in slot 6, drop Glass Meridians and add health.

**The signature moment.** The fight log shows one line at **0.500 s**: four Lightning hits in a row. The enemy's ward bills its last linh lực on the first one, and the next three have no ward line at all. If the enemy opened at the same moment, their hit lands on you, you refuse at 1 health, and the result reads: knockout, fight time 0.500 s.

## What beats it

- **A boss with top-end damage and a large pool** (bosses are built to outlast a top-end build for 4 s or more). Your volley takes about 14 % of a ×10 pool, its opener takes your refusal and your linh lực at 1.0 s, and its basic attack ends you at 2.0 s. To adapt: slot Thunderclap, drop Glass Meridians, bring a reserved ward. Better still, do not take that fight. Bosses with ordinary damage are fine: their hits cannot break your ward, and your third volley breaks theirs at about 1.5 to 2 s.
- **Heavenly tribulation (Thiên Kiếp) waves.** Each wave starts with what the last one left you, so your volley wins wave one and the reloads run dry. Prepare with linh lực sustain, not more damage.
- **A wall of reserved ward**, 3,000 points or more paid before the fight. It does not spend linh lực, so the Breaker cannot empty it. To adapt: Iron Spark's Physical part dodges a Lightning-only wall, and resistance penetration helps a little. Against an all-resistance wall, walk away.
- **Another first-volley build (the mirror).** Both of you fire at 0.5 s, both refuse, both finishers fire, both last acts fire. The crits decide, about even.
- **One realm up.** About 3 in 4 at 0.5 s. When the volley rolls few crits, their opener takes your refusal and you have no linh lực left for a second volley. Lightning Step is your exit.
- **Evasive foes at the 40 % cap.** Accuracy brings them to 25 %, and the volley still lands about 95 % of the time.

## Not in the game yet

Every staged piece this build needs, by its ID in the staging catalogue:

- `opening-haste`: Opening Haste (Tiên Phát), the new stat; the identity piece.
- `unanswered`: Unanswered (Vô Ứng).
- `taut-string`: Taut String (Huyền Căng).
- `eruption`: Eruption (Phún Trào), first listed in the by-root missing pieces.
- `loi-de-chan-kinh-abilities`: the Thunder canon's arts and passive.
- `cloud-splitting-bolt`, `forked-light`, `thunder-needle`, `iron-spark`, `rolling-thunder`, `lightning-step`: the six arts.
- `herald-banner`: Herald's Banner (Tiên Thanh Kỳ).
- `thunder-gall-pill`: Thunder-Gall Pill (Lôi Đởm Đan).
- `nine-rods-array`: Nine Rods Array (Cửu Can Trận), carrying Ringing Ground (a tree-catalogue modifier, also not built).
- `thiem-dien-before-the-sound`: the Lôi Đạo Thiểm Điện nodes.
- `drawn-bowstring-cluster`: the Drawn Bowstring (Mãn Huyền) hidden cluster idea.
- `arts-fired-this-instant`: the readable Eruption needs.
- From elsewhere, also not built: Thunderclap (by-root missing pieces) for the boss loadout, and a Thiên giai Thunder canon for Hóa Thần.

## Changes the game would need

- **An opening timer stat** (`opening_haste_pct`). This changes Combat rule 13 and Formulas A2 (`design/gdd/combat.md`), which today say every art's first firing comes one full cooldown in. The proposal: an art's first timer is its cooldown divided by `(1 + opening haste)`, never below `cooldown_min`; later firings are unchanged. It also needs a row in the Modifier System's Stat List (`design/gdd/modifiers.md`), replacing its "Left out: first firing sooner" line. Price about half of art speed.
- **Two readables in the Effects System** (`design/gdd/effects.md` rule 5):
  - "arts you fired this instant", for Eruption;
  - confirmation that "firings this fight" includes the enemy's, for Unanswered.

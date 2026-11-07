# Decisions for Breakfast

> Overnight campaign, 2026-11-07. Nothing here has been changed in the game, and every recommendation is an agent's, not yours. 66 builds raised 179 questions, and of their rows 349 fit today, 874 need a new data key and 208 need a new rule. 25 builds ask for no new rule at all. All fight results are a paper model.
> **How to read the counts:** "stand on it" means a build's own pieces, fight file or ward need the ruling. "Ask" means it only raised the question. Counts come from `scratch/decisions/count.py`. Grouping the questions was done by hand, so they are a guide and not a census. **Order:** answer 1 and 2 first, because most of the rest leans on them. 11 and 12 belong together.

## 1. Top 12 decisions

### 1. Do you write the ward catalogue first, before touching the art price check?
- **Touches:** Combat Open Question 18, rule 22, Formulas C and K. **27 builds:** 19 stand on it (Banked Well, Dew on the Blade, Dug Stone, Fortieth Breath, Full Price, Good Year, Great Tonic, Held Door, Five Hot Stones, House Call, Long Answer, Long Firing, Seven Lamps, Spring Hand, Swidden Road, Proctor, Three Shirts, Under the Eaves, Wet Cloth). 8 ask (Daily Lesson, Deepest Well, Evergreen Road, Long Carry, Long Drought, One Ladle, Remnant Host, Worst Root).
- **Catalogue first:** filling every slot with the cheapest legal art (cost 0.04, 0.5 s) stops being the answer. With wards that charge per hit or per pulse, slower builds beat it at equal budget with no new rule, and results form a cycle with no single winner. **Common ward only:** no build at 1 s or slower was found to beat that cheap kit (0 wins in 8,000 random builds per realm), and you would need the curved price check, option A2 in `kit-options.md`.
- **Recommend:** catalogue first, leave the price check alone, and settle it before Formulas K is built. The three wards that beat the kit are overnight records, not game data, so that result is only true once they ship.

### 2. Should everything that has no hit get a price?
- **Touches:** Formulas C and F, rule 22, Open Question 18. **37 builds stand on it:** 20 carry an art with no hit and 19 run an unpriced ward, with 2 doing both (Already-Waited, Banked Well, Best Plan, Dew on the Blade, Brush Fee, Clever Harm, Cut Line, Deepest Well, Dug Stone, Fortieth Breath, Full Price, Given Years, Good Year, Great Tonic, Held Door, Herd-Child, Five Hot Stones, House Call, Incense Vigil, Kept Hearth, Level Ground, Long Answer, Long Firing, Lucky Fool, Seven Lamps, Spring Hand, Struck Name, Swidden Road, Corner, Heir, Proctor, Third Look, Thousand Scales, Three Shirts, Under the Eaves, Understudy, Wet Cloth).
- **Yes:** each family (wards, curses, masks, escape arts, talismans, statuses from triggers) gets its own check. **No:** a mask at cost 0.06 goes on stopping any blow of any size, and a per-pulse ward wins at upkeep 0.10 and loses at 0.20 with nothing to say why.
- **Recommend:** yes, one family at a time as each catalogue is written, wards first. The one check that exists only sees hits, and the ward is the largest unpriced number in the game.

### 3. Should the art price check read what actually runs, under one sentence: "a wait is paid, never deleted"?
- **Touches:** Combat rule 13, Formulas A2, C and F, plus a "seconds skipped" line in rule 14. **19 builds stand on it:** Already-Waited, Best Plan, Brush Fee, Daily Lesson, Deepest Well, Dug Stone, Fortieth Breath, Forum Build, Full Price, Held Door, Five Hot Stones, Level Ground, Not-Yet-Full, Seven Lamps, Spring Hand, Stand-In, Corner, Transplant, Thirteenth Summer.
- **Yes:** every skipped second comes from a named, limited pool and is reported. Forum Build loses its kill at t = 1, and its sheet says its three parent builds do not change. **No:** Forum Build stays legal, firing 43.1 against 11.9 sold. Rule out the obvious fix, counting flat bonuses: it kills Level Ground and Fortieth Breath, and Forum Build still beats a Deity (Hóa Thần).
- **Recommend:** yes. It is one sentence, and three separate builds broke the check the same way.

### 4. May a fight spend or raise what outlives it: heart demon (tâm ma), years, seasons, stones, toxicity, purity?
- **Touches:** Combat rules 2, 13 and 14, Formulas E, Character Stats rules 6, 7 and 8, Realms rule 14. **17 builds stand on it:** Already-Waited, Ant General, Best Plan, Cut Line, Fortieth Breath, Forum Build, Full Price, Given Years, Incense Vigil, Lucky Fool, Not-Yet-Full, Taster's Fever, Heir, Mortal, Transplant, Thirteenth Summer, Thousand Scales.
- **Yes:** the fight reports what was spent, as it already reports vitality, and the caller applies it. **No:** a fight stays sealed, and these 17 lose an enabler or a cost. Kills adding no heart demon stays as you ruled, with no exceptions.
- **Recommend:** yes, by report only, values read before the fight, and every second payer priced. Rule 14 already works this way, and a cost paid from a life is the most genre-true price the sheets found.

### 5. What happens after Down?
- **Touches:** Combat rules 10 and 14, Open Question 23, Heavenly Tribulation (Thiên Kiếp) rule 7. **12 builds:** 11 stand on it (Best Plan, Fortieth Breath, Given Years, Herd-Child, Incense Vigil, Lucky Fool, Heir, Mortal, Puppeteer, Thousand Scales, Turned-Away). 1 asks (Drink the Lightning).
- **One defined step:** the defeat check gains a fixed order for refusing Down, a last act, wounds and debts that run on, and a companion standing over you, plus a "won and died" result. **Down is final:** these effects go, or become lines in the result. Thousand Scales keeps wounds running after death, which is how a Foundation cultivator took a Deity to 9 %.
- **Recommend:** one step with a stated order, and wounds returned in the result so rule 14 still holds. One ruling serves all 12, and today stacking two of these has no defined outcome.

### 6. May a Way (Đạo) hold two keystones, of which a character owns one?
- **Touches:** `dao.md` rule 1. **All 7 new Ways ask, and they name 25 builds:** Already-Waited, Best Plan, Brush Fee, Clever Harm, Corner, Drink the Lightning, Given Years, Great Tonic, Herd-Child, Incense Vigil, Kept Hearth, Level Ground, Long Carry, Loud Sword, Lucky Fool, Not-Yet-Full, Proctor, Receiving Hand, Remnant Host, Stand-In, Taster's Fever, Thousand Scales, Turned-Away, Understudy, Wedding Furnace.
- **Yes:** the keystone becomes a life choice. Tested on 2 of 7: Poison is a real choice, Examination only half. **No:** each tree cuts one.
- **Recommend:** yes, after two fixes: "arts that apply a lodged tick deal no hit", and First on the List to ×1.5. Keep them exclusive, since Examination's two stack. Run the other 5 before calling it settled.

### 7. May anything restore health inside a fight?
- **Touches:** Combat rules 11 and 13, Thiên Kiếp rule 7, which forbids healing only between waves. **9 builds:** 7 stand on it (Drink the Lightning, Fortieth Breath, Forum Build, Great Tonic, House Call, Kept Hearth, Not-Yet-Full). 2 ask (Evergreen Road, Seven Lamps).
- **Yes:** healing needs a price, and House Call's oath that heals both sides is a first guess. **No:** say "health never rises in a fight", and these lose their piece.
- **Recommend:** yes in ordinary fights, no inside Tribulation waves for now. Still Water alone takes Tribulation survival from 0.117 to 1.000, and the boss pool is still waiting.

### 8. Do the reference builds get a soul defence now, rather than waiting on real techniques?
- **Touches:** Combat Open Question 16 (your 2026-11-06 decision to wait), Formulas C and E2, rule 24. **4 builds:** 3 stand on it (Cut Line, Third Look, Understudy). 1 asks (Third Tug).
- **Yes:** enemies gain soul sense (thần thức) and resistance by realm, and soul arts get a price. **No:** about 9 % of build budget stays the gap between dying without moving and killing at t = 1, and no soul result can be trusted.
- **Recommend:** yes. Few builds use it, but their results rest on a defence no reference enemy has. Third Look offers a free formula: talent 45 × (1 + road share).

### 9. May a build count chance instead of rolling it?
- **Touches:** Combat rule 15, Formulas I. **3 builds stand on it:** Loud Sword, Lucky Fool, Understudy. The Ways of Chance and Illusion also need it.
- **Yes:** a failed chance fills a visible count, and the full count lands. On the same stats, Loud Sword goes from a loss on 44 % to a win on 31 %, because a counted crit can be aimed. **No:** three authors' ideas go, each found alone.
- **Recommend:** yes, as one shared rule on a keystone, with a price. Rule 15 says the design aims at determinism anyway.

### 10. Should mass-battle reserves stop adding power at some point?
- **Touches:** Combat rule 17, Formulas K (`mass_reserve_weight`). **2 builds:** 1 stands on it (Ant General). 1 asks (Lucky Fool).
- **Yes:** the weight fades as numbers grow. **No:** 2,000 Qi Refining (Luyện Khí) under one mediocre leader beat a sect at R 5.44, and about all the world's Qi Refining reach R 18.58.
- **Recommend:** yes, before Formulas K is built, and keep mortals out of forces until then. Few builds care, but in a world of about 27 Nascent Souls (Nguyên Anh), realms must decide wars.

### 11. May a status run with no duration?
- **Touches:** Combat rule 7, Formulas F (duration 2 to 6, and a price that multiplies by duration). **3 builds stand on it:** Good Year, Held Door, Stand-In. The catalogue's Grave-Silk Shroud also wants it.
- **Yes:** a standing tick or curse, inside today's 5 % and 8 % caps. **No:** all three lose their enabler, and the Shroud needs a rewrite.
- **Recommend:** yes, only with a standing cost and only if a cleanse can clear it. Good Year's sheet says a cleanse decides the build, and that is the right counter.

### 12. May anything hold back part of the mana pool (linh lực)?
- **Touches:** Combat rule 11, which says "nothing reserves it". The calculator already has `reserve_share`. **2 builds stand on it:** Good Year, Heir. The Grave-Silk Shroud reserves 25 %, and Corner dropped an idea because reservation barely exists.
- **Yes:** reword rule 11, and reservation becomes the price of always-on effects. **No:** remove it from the calculator and re-cost those three.
- **Recommend:** yes, as a cost only and never a stat a player buys. It is the natural price for decision 11.

**Waiting behind these:** elements in a fight (8 builds), flight or a stalemate as success (8), how far curses reach (7), debt, family and a second path for stalled lives (5), Ground Law (4), targeting companions (3, reopens your Open Question 3).

## 2. Faults in existing GDDs (wrong today, whatever you decide above)

- `combat.md` AC-CB-49: T0 of 7.77 needs late damage of 22.8, but a basic attack gives 20.65, which makes T0 7.98. Rechecked by hand.
- `combat.md` AC-CB-50 and Formulas K's example: R 1.84 is just (19/14)², true only if health runs out before the ward. Ant General's reading gives 2.18.
- `combat.md` Formulas K: it never says how a force sums net spend or soul rate, and `t_w` has no term for per-hit or per-pulse wards.
- `combat.md` rule 10: nothing orders effects at the defeat check, and three test plug-ins overwrite each other there.
- `combat.md` rule 13 and Formulas F: a curse blocking the `hit` tag silences every hit art for 3 pulses, and the basic attack carries `hit` yet "always runs".
- `combat.md` rule 22 and Formulas D: it never says whose ward a ward is, or in what order two wards meet a hit (alive at 40 s became dead at 18 s), and the floor and curse cap read per ward.
- `combat.md` rule 22: a per-pulse ward with regeneration above upkeep can never fall, and only a regeneration-blocking curse ends it.
- `combat.md` rule 22: on a drain ward, more strength can lose a fight (Long Carry: a win became a loss with the enemy on 53 %). Three sheets found it alone.
- `combat.md` rule 7 and Formulas F: no rounding for a percentage on a whole-pulse duration, and no default for a curse recast (refresh or stack).
- `combat.md` Formulas F: is the 5 % qi burn cap per status or per pulse? AC-CB-38 reads either way. Statuses from triggers have no price check.
- `combat.md` Formulas E: cost is 0.04 to 0.25, but AC-CB-57 never tests it and Dug Stone read 0.85 as legal. Health-paid arts cannot take health below 1, so they are nearly free at low health.
- `thien-kiep.md` rule 7: silent on healing inside a wave, and on whether a deferred-damage ledger carries. Its edge cases say Combat has no revive, while the catalogue holds Unyielding Breath.
- `combat.md` rule 13: its art sources omit formations, no talisman firing cost is stated, and `crafting_talismans.json` spends talismans at the start of a fight, not as arts.
- `item-database.md` rule 11: a cultivator may wear three mail shirts, the whole edge of one build.
- `kinh-mach-do.md` rule 4: on a one-element root a gap cluster pays ×1.00 to one line and ×0.25 to its rival. Decide this at the tree rework.
- `tree-modifier-catalogue.md`: crit at catalogue size is a trap, paying only after about 16 nodes.
- Tools, not GDDs: `fight_calc.py` gives soul sense no realm scale, and both reference enemies spend themselves broke and carry no element.

## 3. Concepts worth keeping (ranked by builds using them)

1. **Healing inside a fight, 5:** see decision 7.
2. **Ledger of deferred damage, 4:** a blow is held and paid over time. Needs limits, as it is close to 20 s of invulnerability.
3. **Ground Law, 4:** a laid formation (trận pháp) moves listed rules for both sides. It gives every sect mountain a character for free.
4. **Counted chance, 3:** see decision 9.
5. **Heart demon that moves in a fight, 3:** see decision 4.
6. **Merged self-hit, 3:** one rule for arts turned back on their owner, clipped at 25 %.
7. **Kin tie, 3:** a named person bound to you. The smallest possible family system.
8. **Creditors' Book, 2:** enemies you fled from stay owed, for life.
9. **Art costs in a life stat, 2:** an art may name toxicity or purity as its cost.
10. **Mortal Body and Levy, 2:** mortals as a side the caller creates, not simulated.
11. **Ward phase, 2:** a ward holds an element, and hits that feed it pay it.
12. **The Reckoning, 2:** the world reads your kill tally and sends hunters.
13. **The Owed Wait, 2:** a forced stay of seasons in one place. Also serves oaths and sentences.
14. **One build each, in no order:** winning by standing, Succession, ward on the other person, Surfeit, Flight, timed dose, chronic affliction, bare hit, Gate Scar, mimic art, Debt, Puppet, Shared Years, Rejection, Brood Year, first Tribulation pool, Cornered Market.

## 4. Quick yeses

- **Rounding (3 builds ask):** a percentage on a whole-pulse duration rounds up, as the calculator does, so tonight's results stand.
- **Talismans (2 ask):** no linh lực when fired, with stock as the price. Best Plan dies otherwise. Fix the crafting file to match.
- **Basic attack (4 ask):** immune to tag blocks, and art modifiers do not reach it. This keeps "always runs" true.
- **Curse recast:** refresh, not stack. `curse_duration_max` already bounds it.
- **Self-hits (3 stand on it):** take the merged rule at 25 %. Unclipped, a Core Formation (Kết Đan) fool kills a Deity in 6 s.
- **Flight as success (8 builds in this family):** let a fight over something you already hold count flight as your success, by changing AC-CB-62's branch.
- **Elements (8 in this family):** every enemy profile carries a main element, so element builds can be assessed at all.
- **"No linh lực" (Fierce Fire, the tree proposal):** one threshold, Bare Vessel's 5 %.
- **First firing:** "comes sooner" stops at `cooldown_min`.
- **Body techniques:** Combat does not say, so rule that two add their `t_b`, inside today's 0 to 5 range.

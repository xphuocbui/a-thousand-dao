# Critic: Wave 2

Basis: all 10 wave 2 sheets read in full, including Herd-Child and Already-Waited, plus index, ledger, health, forge, combat model and 23 plug-ins. All five wave 1 orders were carried out, and the wave is better for it.
**Biggest finding:** every quoted number is true, but two headline readings are not: Cut Line's kill needs a soul-blind enemy, and Level Ground names only half its engine.

## 1. Verification results

- **30 quoted results re-run on 8 sheets, 0 mismatches:** Cut Line 8, Long Carry 6, Deepest Well 4, Given Years 4, Level Ground 3, Herd-Child 2, Thousand Scales 2, Already-Waited 1.
- **Plug-ins: no cheating.** I read the plug-ins of those sheets, plus Wedding Furnace's and most of Kept Hearth's. None acts for the enemy unless a spec asks, and none does more than its sheet says. `delay_enemy` and `realm_sense` touch the enemy exactly as stated.
- **Long Carry's 0 rule asks is true.** `breath_lead` is a condition on a modifier, `ward_thrift` is one compile-time line inside the 50 % limit, and `per_cap` only caps. Nothing moves a rule, by the skill's definition. One caveat: Combat has no vocabulary for modifier conditions, so Longer Breath needs a sentence there. The sheet's own `t_b` question is not load-bearing: at `t_b` 0.4 it still wins, on 9 %.
- **Cut Line's 0.813 s: real arithmetic, wrong headline.** E2 gives rho 6.8 to 9.1, and the hits land at 0.500, 0.613, 0.713, 0.813. The enemy's 85 is hard-coded and derived nowhere, but it is not sandbagged: it sits beside the build's own 60 × 1.45 = 87. The artifact is the anchor, whose top-end spends 90 % of W and none of it on soul.
- **Where it flips** (one-key edits to `sheets/cut-line.fight.json`, `--enemy top_end`, scratch only): enemy sense 128, which is +51 %, about 66 W or 9 % of W. Soul resistance 60. Art speed +41, not the sheet's +100, acting at 0.709 s, 4 ms before the third hit. No artifacts at all. Running Line's floor at 0.2, not its invented 0.1. Its own thần thức could fall to +160 and still kill. So say "kills a top-end who spent nothing on soul". Correct the pitch; do not shave the build.
- **Level Ground misreads itself.** It says the Bunds only show against a bigger pool. Each alone changes nothing because they are redundant. Remove both from `variants/level-ground-mixed.fight.json --enemy top_end` and the win at 4 s on 87 % becomes a loss at 20 s with the enemy on 51 %. Those arts run `c_art` 3.8 at cost 0.03, against a lint of 1.86. The law is half the engine, and +2.05 past the lint is the other half.
- **Plug-in hazard for stacked builds:** `lit_wick`, `stands_over` and `turned_away` each overwrite `Side.dry_at`, so loading two silently drops one.

## 2. Tired, do not repeat

**Fixed, thanks:** Bare Vessel, Full Sea, empty slots, standing still, rejecting the common ward. All 10 pay in linh lực, all 10 act early, 5 of 10 have no enabler, and no clerk appears. Those closures stay closed.

- **The legend is one story again, in a new costume.** A humble wet-country trade (kite, cook, gutter, bearer, well, paddy, herd, ferry) holds a physical fact that turns out to be how linh lực works, the sects sneer or hunt, and a quiet stinger closes it. "Those who walk" is in 5 sheets, "the happiest people" in 2, "the reed country" in 2, salt or brine in 3, a marriage or spouse in 4. No city, palace, mine, army or monastery exists yet.
- **Every sheet is an elegy.** A real cold choice is fine; ten tender ones are one mood. Nobody here is awful, vain or funny on purpose.
- **The surprise list is a ritual.** 8 of 10 run a numbered list, most opening with "the grand piece did nothing and the humble one did the work": the Great Sluice, the clock, the arts, the square, Last Ferry first. Each is true, the shape is formula, and two sheets now address the critic in it. From now on: one sentence, and only if the result changed the design.
- **Overflow is now compulsory.** 7 new in 10 builds: Running Line, Widening Wound, Deep Bund, Boiled Over, Broad Back, Scraping the Well, Unspent Rage. Closed for a wave unless it is the identity piece.
- **Two authors built the same modifier.** Thrift and One Rope are identical. Longer Breath and Dry Neighbour differ by a threshold (`breath_lead`, `pool_lead`). Given Years and Years Given are nearly one Per. In Step (+50, +40) and Cornered (+50, +60) carry two sizes, as Bare Vessel did. Reuse by name, at one size.
- **Renamed rows inflate the ledger:** Thin Bleed, Salted Edge, Burst Gall and Sinew Nick are one modifier. Scaling, Seam and Gill Stroke are one art. Headrace, Furrow, Ditch and Seep are one art.
- **Next crutches:** Hearth Ash is in 5 builds and changes nothing in Kept Hearth's or Already-Waited's mixed fight, so no sixth without a saved removal run. Heart demon is read by 3 of 10 and lifespan given away by 2, so the next Per reads something else.
- **Hán-Việt, the good:** Chỉ Diên Phổ, Hoán Kiên, Tử Đạo Mẫu Khí, Tương Vũ and the thâm and tham pun are very good. **Not varied:** all 10 titles are two words plus Đạo, so use Môn, Quyết, Lộ or no suffix. Trường and "Long" are on 8 names, so stop.
- **Hán-Việt, to fix:** Cựu Bờ, Thâm Bờ and Xát Diêm are hybrids; Tại Đây Chờ and Mỗi Đòn are wholly native. Thằng (rope) reads as "guy" in Trường Thằng and Độ Thằng Kinh, so use Sách or Lãm. Phục Hỏa names two arts. Tặng Thọ is both a Đạo and a modifier. Nhiên Đăng is a Buddha and a classic-novel figure, which the brief bans; try Tàn Đăng.

## 3. Missing

- **Channels and forms:** qi burn has never been the main channel, nor damage from being struck (seed 8), nor the riposte (seed 25). Wave 2 used Conversion, Timing and Borrow once each.
- **Systems:** crit, evade, escape, talismans and curses as engines, status detonation, contagion, fortune, purity, Đạo count, pills as timing, puppets, a past life, illusion, healing, comprehension, the mass-battle rating, quests, Heavenly Tribulation. Four sheets authored an escape art and none ran, so every "loss" there is an unexamined death.
- **Realms and power:** 4 Foundation, 5 Nascent Soul, 1 Deity. None at Qi Refining, none mortal, and Core has gone from all to none. One ordinary build in 20.
- **Moods:** pride, fear, mischief, ambition, curiosity, faith, shame, a villain enjoying themselves.
- **What a person would pick first, and cannot:** the loud sword saint, the devourer who grows with each kill (seed 16), the general, the lucky fool. Above all **the careful survivor**, who hoards, prepares, keeps an exit in every sleeve, runs from anything uncertain and comes back in fifty years. That is the heart of this genre and of the user's systemic taste, and in 20 builds no one runs away.

## 4. Best 3 of wave 2, and weakest 2

1. **Already-Waited.** Best idea of the night. The lint prices long cooldowns cheaply, so a pool that pays the wait and not the cost keeps the discount. Linh lực still pays, the ward stays up, it opens at t = 1, and the bill is 30 seasons at a ferry post. It reads a rule and finds a build in it, which is the brief exactly.
2. **Herd-Child.** The fantasy a player tells a friend: the owner goes down at 3 s and the buffalo wins at 4.8 s on 85 %. It weakens as the owner climbs, so the choice is your own Core against its strength. "A good support sings less" is real design from the numbers.
3. **Long Carry.** The only build of 20 that needs no rule change. Moving 48 points from ward strength to efficiency turns a win into a loss with the enemy on 53 %: a discovery a player can make alone. It loses one up honestly. Copy that.

Honourable mentions: Given Years, where 20 seasons walks home and 24 dies on the enemy's purse. Kept Hearth, for the ring's two steps matching the two conversions.

- **Weakest, Wedding Furnace.** The pitch says the order decides the fight. Its own table says Earth first wins all three winnable columns, because Whetstone Ash is the largest coating. That is "biggest first", not a menu. Courses must differ in kind, not size. Keep the joy.
- **Weakest, Thousand Scales.** The fury is decoration by its own numbers: heart demon 85 against 20 moves the kill one second, and a bare fist wins the same realm in 6 s. It is a competent poison stack, the safest sheet here. Widening Wound and Parting Cut are excellent; lift them out, because they want a stranger home.
- **Cut nothing.** Merge the renamed rows and the duplicates. Level Ground's law is a superb idea, but at 8 rule asks its sheet must first name its real engine.

## 5. Rule discoveries (for the user; none is a reason to shave a build)

1. **Soul defence is a cliff priced at almost nothing.** About 9 % of W separates "dead without moving" from "kills at t = 1", and the anchors spend 0 on it. Should reference enemies carry a soul profile? This is Open Question 16.
2. **`fight_calc.py` gives thần thức no realm scale.** Any soul result without `realm_sense` is off by the square of about 3 per realm.
3. **Ward strength can lose a fight.** Long Carry, Kept Hearth and Deepest Well each found it alone: blocking more pays more. Is that a lesson or a trap?
4. **Nothing defines what happens after Down.** Paid in Seasons, Parting Cut, Stands Over You, Turned Away and Final Clause all rewrite the defeat check, and rule 14 has no "won and died" or "mutual knockout". One ruling would serve five builds.
5. **Statuses from triggers have no lint.** `trig_cap` is the only limit, so a free fist keeps four wounds open.
6. **Reference enemies have no element,** so tag builds cannot be fully assessed (Kept Hearth's Validity). Should every profile carry one?
7. **Rule 12 turns off a standing formation in a blind fight, even at home,** and a beast can outrank its owner through the world tick alone. Are both intended?
8. **Wave 1 confirmed.** #3: the lint can be bought (Already-Waited), added after (Old Bund) or defined by what you paid (The Whole Bucket). #4: Cut Line lives or dies by 4 ms. #5: overkill is a routine ending in four sheets. #9: Long Carry, Wedding Furnace and Deepest Well all lose to the per-hit ward. #2: in Given Years a broke enemy decides who goes home.
9. **Wave 1 nuanced, none refuted.** #1: the mixed enemy is usually harder, but Deepest Well beats it one up and loses to the spender. Judge against both.

## 6. Orders for the next wave

1. **Drink the Lightning (seed 62; Kept Hearth crossed with Level Ground).** A build for Heavenly Tribulation only, since the user's boss fights are waiting on builds. Tribulation rule 5 shows the boss pool in advance and rule 7 carries health with no healing, so Mother-and-Child Ward, Child Steals the Mother and Still Water become a way to mend inside a wave. Chain three waves in `variants/`, and let it be nearly useless anywhere else.
2. **The Coward (seeds 60, 40), defined at Qi Refining.** Write `rules/escape.py` from Combat's escape keys first, because four sheets need it. Then a talisman sleeve, no kill condition, and a life that wins by leaving with the goods. Fear and pettiness as the mood, and it should be funny.
3. **Famine (seed 7; Thousand Scales, Deepest Well and Long Carry crossed).** Qi burn as the main channel at last. Spillover empties the pool, Scraping the Well turns every unpaid drain into health past guard, and Longer Breath lights up for free. None of those authors planned this. Set it in a city, with ambition or spite.
4. **The Forum Build (Already-Waited, Level Ground and Fortieth Breath crossed).** The exploit a player would post: Old Bund on a cheap long laid art, Withheld Hand growing it, heart demon paying the timer at the chosen pulse. At most one new piece. Break the lint on purpose and report what the game should do about it. No one sheet contains this, which is why nobody would think of it.
5. **The Loud Sword (Core Formation).** The fantasy everyone picks first: crit and evade as the engine, kept readable under rule 15, with presence above 45 as the stat, Forgotten Face turned inside out. Vanity as the mood, an arena or a palace as the home, and a protagonist who is awful and enjoying it. No enabler, at most 2 rule asks, no elegy.

**Standing rules from now on:** every build uses one modifier from another sheet in a way its author did not plan, proved with `--without`. Remove any two pieces that share a job together, not only singly. State where an enemy's `sense_base` or element comes from. Never load two of `lit_wick`, `stands_over`, `turned_away`. No river, rice, salt, spouse or "those who walk".

# System Suggestions — overnight 2026-11-10 builds

> Every new system or change to an existing rule that a build of this run needs. Appended by each build
> session; merged and ranked in `RUN-SUMMARY.md`. Nothing here is decided.

Format for each entry:

```
### <build slug>: <short title>
- **Kind:** new system | change to an existing rule | new key or readable
- **Touches:** <GDD path> rule <n> (or "new")
- **Proposal:** <what changes, in rule terms>
- **Why the build needs it:** <one or two lines>
- **Trade-off:** <what it costs the game, what it might break>
```

---

### two-clocks: Bound an art's stack grant at the charge cap
- **Kind:** change to an existing rule
- **Touches:** design/gdd/effects.md Formulas D (and AC-EF-69)
- **Proposal:** the charge stays `Σ w_kind · stacks · seconds` with `charge ≤ 0.6`, and the lint also fails any art whose uncapped charge is above 0.6. So one firing grants at most 40 debuff stack-seconds (0.6 / 0.015) or 60 buff stack-seconds (0.6 / 0.010). Today AC-EF-69 says an art "whose charge would exceed 0.6" simply pays 0.6, so a record granting 200 Burn stack-seconds lints at the same price as one granting 40.
- **Why the build needs it:** the min-max question was "what is the fastest legal kill clock". Read literally, today's text has no answer: the clock is unbounded. The build is designed at exactly 40 stack-seconds per firing, the bound this fix makes real.
- **Trade-off:** none for content authored inside the cap. It removes a loophole that a generated or LLM-authored art record could hit by accident.

### two-clocks: Price, or floor, front-loaded stack batches
- **Kind:** change to an existing rule
- **Touches:** design/gdd/effects.md rule 9a and Formulas D; design/gdd/combat-defence.md rule 6 (Cleanse payload)
- **Proposal:** pick one. (a) A minimum batch duration of 2 pulses for debuff stacks. (b) Weight short batches higher in the charge, e.g. `w_kind × (1 + 1/seconds)`. (c) Let a cleansing ward also act on batches the pulse they land. Today 40 Burn for 1 s and 4 Burn for 10 s cost the same charge. The 1 s batch delivers all 40 stack-pulses at the next pulse, skips the 10 s ramp, and ticks before a cleansing ward can thin it.
- **Why the build needs it:** the build's fast clock (Ember Rain: 20 Burn for 2 s) uses the shortest batch this proposal would keep. The paper model puts a pure 1 s-batch build's kill about 2 s earlier than the sheet's, and nearly immune to Clear Heart Ward.
- **Trade-off:** (a) is simplest and costs nothing authored so far. (b) keeps freedom but adds a term to the lint. (c) makes cleansing stronger against every stack build.

### two-clocks: Let an Effect extend L5 to over-time ticks
- **Kind:** change to an existing rule
- **Touches:** design/gdd/combat.md Formulas F (ticks use L1..L4); design/gdd/modifiers.md rule 6 (L5 as an Effect payload)
- **Proposal:** add one sentence to Formulas F: "an Effect may state that its owner's L5 payloads also apply to that owner's ticks; the L5 cap (100) is unchanged". The only host is an enabler with a real close (the Twin-Wick Incense Clock: your hits deal no damage).
- **Why the build needs it:** tick builds have no conditional layer, so every L5 Effect is dead for them. That includes the staged by-root piece Fuel for the Fire, whose L5 payload on Burn does nothing under today's Formulas F. The enabler turns Bare Vessel into the payoff of the first clock: when the enemy's linh lực reaches 0, both tick families get +80.
- **Trade-off:** it adds up to ×2 to the tick channel, bounded by the L5 cap. A build that takes it gives up every hit, so it has no fallback against high status resistance or a cleanser. The NPC generator must treat the enabler as an all-or-nothing choice.

### two-clocks: Two readables for overflow on ticks and cleanses
- **Kind:** new key or readable
- **Touches:** design/gdd/effects.md rule 5 (readables and events); design/gdd/combat.md rule 9 (trigger events)
- **Proposal:** (1) a tick's prevented points, the damage a tick lost to resistance after penetration, as part of the tick event (the by-root "Prevented damage" readable covers hits only); (2) an event "your debuff stacks were removed by a cleanse", with the count, on the applier's side.
- **Why the build needs it:** Ash Ledger (the identity piece) reads (1), and Cinder Debt reads (2). Both are Overflow Effects: what the enemy's defence clips becomes linh lực burn.
- **Trade-off:** two more lines in the Breakdown. Both values are already computed on the defence path, so the cost is exposure, not new maths.

### first-volley: An opening timer stat (opening haste)
- **Kind:** change to an existing rule
- **Touches:** design/gdd/combat.md rule 13 and Formulas A2; design/gdd/modifiers.md Stat List (Combat: offence) and its "Left out: First firing sooner" line
- **Proposal:** a new stat `opening_haste_pct` (op I, target art, scoped by art tags like art speed). Rule 13's start becomes: "every art's timer starts at `round_ms(max(cooldown_min, cd_eff / (1 + opening_haste_pct / 100)))`". Later firings use `cd_eff` as today. Price about 0.3 W per % (half of art speed, since it acts once a fight). The tree catalogue's "First firing comes sooner" row (○) becomes this key.
- **Why the build needs it:** it is the identity piece. A top-end hit kills in one instant, so the build must land before the enemy's first basic attack (1.0 s) and tie, not trail, a 0.5 s opener. Art speed alone would need about +700 % on 4 s arts, which also makes every later volley unpayable. In fight_calc, with the opening at the floor the build beats the top-end profile at 0.500 s; without it, it dies to that profile's first basic attack at 1.000 s.
- **Trade-off:** it makes "who fires first" a stat race at the top end. It is bounded by `cooldown_min`, which every build can reach, so the race ends in floor ties, settled by overkill share and refusals (Effects rule 11). The NPC generator must give top-end NPCs some of it, or the player's alpha strikes face no answer. Watch whether Unyielding Breath becomes mandatory at the top end (a macro check, not a fix).

### first-volley: Two in-fight readables for the first strike
- **Kind:** new key or readable
- **Touches:** design/gdd/effects.md rule 5 (readable quantities)
- **Proposal:** (1) "arts you fired this instant", a live count; a follow-up instant counts as its own instant. (2) Make explicit that "events this fight: firings" includes the **enemy's** firings, read at instant start.
- **Why the build needs it:** Eruption (by-root missing-pieces, staged) reads (1). Unanswered ("while the enemy has fired no art this fight") reads (2).
- **Trade-off:** none in maths. Both are counts the timeline already keeps. (1) gives synchronised kits a reason to exist. Bound it with a cap on the Effect, as Eruption's +25 does.

### dry-well: Let one keystone carry Ice's raise onto drain bills
- **Kind:** change to an existing rule
- **Touches:** design/gdd/combat-defence.md Edge Cases ("Ice … never a ward-slot payment", user decision 2026-11-10) and Formulas C (`bill_w`); design/gdd/effects.md rule 9a (Ice row)
- **Proposal:** keep the rule for everyone, and allow one named keystone Effect (Cold Toll) to override it for its owner: "your Ice stacks on a foe also raise the drain bills their wards pay against your hits and ticks, by the share they add to the foe's art costs; your Ice stacks' art-cost raise on that foe is halved". The raise multiplies `bill_w` after Leaking Ward; `pay_frac` and the live pool still bound the bill.
- **Why the build needs it:** it is the identity piece. At Nguyên Anh a top-end foe's first volley comes off cooldown at about 2 s; plain bills leave it about 1,900 linh lực, enough for two Ice-taxed arts that kill the build. With Cold Toll the same foe is dry at 2.0 s and fires nothing (paper model, `dry-well.sheet.md` § Fight Results).
- **Trade-off:** drain wards become fragile against one Ice build, which is the point. Reserved, per-hit and cast wards are untouched, so the counter is ward choice. The halved art-cost raise is a real loss against foes without drain wards. The NPC generator should give Ice NPCs this keystone rarely.

### dry-well: A linh lực debt (owing linh lực)
- **Kind:** new system
- **Touches:** design/gdd/combat.md rule 11 and Formulas E; design/gdd/combat-defence.md rule 8 ("Up while: linh lực is above 0"); design/gdd/effects.md rule 6 (a new action "add debt") and rule 5 (readable `pool-shortfall`)
- **Proposal:** a side may owe linh lực, up to a cap the creating Effect sets (Owed Water: 40 % of maximum). While it owes, regeneration and gains pay the debt before the pool, its pool stays at 0, and it counts as having no linh lực. Debt is filled only by Effects, from the shortfall of burns and bills that met an empty or short pool. One debt per side; the larger cap wins.
- **Why the build needs it:** today burn past an empty pool is lost and the next pulse's regeneration puts a drain ward back up for one hit. Owed Water spends that clipped burn (an Overflow) so a dry foe stays dry, and pays the build half of each repayment, which covers Water Table's close (no regeneration) in long fights.
- **Trade-off:** one more number on the linh lực bar and in the Breakdown. It makes "dry" sticky, so sustain builds that live on regeneration lose to a burn build more cleanly; the cap and the "Effects only" source keep it bounded. Fights here are short at top end, so its effect shows mainly in long fights (bosses, sustain mirrors, the Kết Đan arc).

### dry-well: Two readables for burn and Ice
- **Kind:** new key or readable
- **Touches:** design/gdd/effects.md rule 5 (readable quantities)
- **Proposal:** (1) `pool-shortfall`: the linh lực a burn, drain bill or per-hit fee could not take because the pool was short (the bill's `1 − pay_frac` share, a burn clipped at 0), as an event payload; (2) `ice-extra-cost`: when a foe pays an art cost your Ice stacks raised, the part your stacks added, as an event payload.
- **Why the build needs it:** Owed Water reads (1); Frost Tithe (by-root missing-pieces, Ice's linh lực keystone) reads (2).
- **Trade-off:** none in maths; both are computed on the cost and defence paths already. Two Breakdown lines.

### dry-well: A stat for the bill your hits raise (`ward_bill_pct`)
- **Kind:** new key or readable
- **Touches:** design/gdd/modifiers.md Stat List (Combat: offence, family resistance or a new "ward" offence family); design/gdd/combat-defence.md Formulas C
- **Proposal:** `ward_bill_pct`, op I, target own hit and own tick: the enemy's drain wards bill `× (1 + X/100)` for what they prevent against your hits and ticks. Small +2.5 %, notable +15 % (first guess 0.5 W per %). Not a curse, so `curse_drain_raise_max` does not clip it; the bill is still bounded by the live pool.
- **Why the build needs it:** a plain-number way to stack the starving game without a rule (Weighted Bucket). Water Table builds want it too: more paid is more drunk.
- **Trade-off:** it makes drain wards worse against anti-ward builds, which the ward price check does not see (it prices against the standard stream). Watch drain wards' share of NPC loadouts in the harness.

### dry-well: Charge curses and non-element statuses in the art lint
- **Kind:** change to an existing rule
- **Touches:** design/gdd/combat.md Formulas C (art lint); design/gdd/effects.md Formulas D (charge)
- **Proposal:** add a charge for a curse an art applies (for example 0.10 per pulse of duration for a rule-changing curse, 0.15 for Leaking Ward or Heavy Breath), and use the existing status lint for non-element ticks, so a curse-applying art loses some coefficient as a stack-applying art does.
- **Why the build needs it:** it does not need it; it exposes it. Leaking Seal (c 1.9 at a lint of 1.97) applies a +50 % drain bill curse for free, as first-volley's Thunder Needle does. A Leaking Ward on every hit is worth far more than 4 % of an art's damage.
- **Trade-off:** a new term in the lint and a re-check of every curse art authored. Cheap now, before content exists.

### soul-lance: A lint for soul arts
- **Kind:** change to an existing rule
- **Touches:** design/gdd/combat.md Formulas C (art lint) or Formulas E2 (`soul_pct`), rule 24
- **Proposal:** price `soul_pct` like `c_art`: `soul_pct ≤ soul_lint_k × (basic_coef · (1 + art_coef_per_cost · cost_share) + art_coef_per_cooldown · (cooldown − 1))`, with `soul_lint_k` 0.0125, clipped to E2's band 0.03–0.08. The slowest, costliest art (lint 6.75) reaches 0.084 and is clipped to 0.08; a 2 s art at cost 0.05 gets 0.031. If dry-well's curse charge is adopted, a soul art that applies a curse (Slackened Soul) pays it too.
- **Why the build needs it:** "the strongest legal soul sniper" has no answer today: `soul_pct` is a free number in its band, so a soul art at 0.08 can be authored at cost 0.02 and a 1 s cooldown. The lockout already caps the rate (one soul hit a second), so cost is the open hole. Soul Lance's arts are authored at this lint.
- **Trade-off:** a new data key and one lint line; nothing authored yet uses soul arts, so nothing breaks. It also gives art speed a real role for soul builds (a long authored cooldown buys a bigger share, art speed brings it back to the lockout), which is intended.

### soul-lance: Fill the reference soul table (Combat Defence & Healing Open Question 12)
- **Kind:** change to an existing rule
- **Touches:** design/gdd/combat-defence.md rule 14 and Open Question 12; design/gdd/combat.md rule 18
- **Proposal:** a table of reference thần thức (as talent-units × M_ts) and soul resistance by realm for the typical and top-end NPC, and for rule 18's soul-resistant enemy. Starting guesses from Soul Lance: typical 59.4 (talent 45, stage 1.2, +10 %), soul resistance 0; top-end 142 (talent 70, stage 1.45, +40 %), soul resistance 15; the soul-resistant enemy adds a Soul-Guarding Lamp (22.5 pp × (1 + ws/100), soul shield 0.50 on 0.10).
- **Why the build needs it:** every soul result depends on the foe's thần thức squared. With no reference table, a soul build's kill time against a "strong" foe can move from 4 s to 15 s on a guess.
- **Trade-off:** none for rules; it pins numbers that NPC Builds and the harness must then honour (AC-CD-51).

### soul-lance: The linh lực a soul hit takes, as a readable
- **Kind:** new key or readable
- **Touches:** design/gdd/effects.md rule 5 (readable list)
- **Proposal:** add "the linh lực your soul hit took (points, after soul shields)" as the payload of the hit event for soul hits, as "ward payments made against your hits" is for other hits.
- **Why the build needs it:** Lamp-Oil Siphon (restore 25 % of the points taken) is the build's fuel past Kết Đan; without the readable it cannot be written.
- **Trade-off:** one more event payload; it also serves Phệ Đạo's soul-drain facet (Hắc Khẩu).

### bare-fist: A basic attack speed stat (`basic_speed_pct`)
- **Kind:** change to an existing rule
- **Touches:** design/gdd/combat.md rule 13 ("art speed … applies to arts only"; "the basic attack is a free art on its own timer of `basic_cooldown`") and Formulas A2 (`basic_cooldown` fixed at 1 s); design/gdd/modifiers.md Stat List row "Basic attack speed" (Pending, 0.4 W)
- **Proposal:** give the Pending row the key `basic_speed_pct` and one line in Formulas A2: `basic_cd_eff = round_ms(max(cooldown_min, basic_cooldown / (1 + basic_speed_pct / 100)))`. Art speed still never touches it, and the companion keeps `basic_cooldown`. The basic attack's first strike moves with it (it first acts at `basic_cd_eff`).
- **Why the build needs it:** the seed asks to stack the basic attack's cooldown; today nothing can. Bare-fist runs +50 % at Nguyên Anh (0.667 s), which also makes it strike first against art builds whose first art lands at 1.25 s.
- **Trade-off:** a second speed stat to price (0.4 W per % is the Stat List's guess). Bounded by `cooldown_min` (+100 % is the most that counts). More basic hits meet flat block more often, so it trades against `basic_coef_add` by itself.

### bare-fist: A flat basic-coefficient stat (`basic_coef_add`)
- **Kind:** new key or readable
- **Touches:** design/gdd/modifiers.md Stat List (new row, op F, target basic attack); design/gdd/combat.md Formulas C (`c_art` for the basic attack reads `basic_coef` 1.0 from data)
- **Proposal:** `c_basic = basic_coef + Σ basic_coef_add`. The art lint still reads the data value `basic_coef` 1.0, so this stat never raises what an art may be authored at. First-guess price: +0.25 per 8 W notable.
- **Why the build needs it:** the basic attack's coefficient is the build's base rung and the payload of its identity Effect (Stored Breath). It is the skill's own "Flat base" example, with no key behind it.
- **Trade-off:** one key. Must stay out of the art lint, or every art gets stronger with it.

### bare-fist: Effects whose payload waits for the owner's next named event
- **Kind:** change to an existing rule
- **Touches:** design/gdd/effects.md rule 8 ("When an Effect applies") and rule 1's `limits` field
- **Proposal:** add a fifth timing: a **held** payload, banked when its trigger fires and spent by the owner's next event of a named kind (e.g. "your next basic attack that lands"), then cleared. The bank is capped by the Effect's record; a held payload never stacks past its cap and is lost when the fight ends. Breakdown line: "Stored Breath: +0.95 banked at 2.000 s, spent on the basic attack at 2.000 s".
- **Why the build needs it:** Stored Breath banks the overflow of each pulse into the next punch. Today an Effect can grant a modifier while a condition holds or on an event, but not "until your next X".
- **Trade-off:** one more state an Effect can hold, and one more Breakdown line. Many "your next art …" ideas from earlier runs need the same shape, so it is reused, not a one-off.

### bare-fist: Say which maximum a linh lực share reads when wards are reserved
- **Kind:** change to an existing rule (clarification)
- **Touches:** design/gdd/effects.md rule 5 ("own and enemy health and linh lực (as shares)") and the Starter Effects Steady Breath and Spent Breath; design/gdd/combat.md rule 13 guards ("own … linh lực below or above a share")
- **Proposal:** state that a linh lực share is read against the side's **usable maximum** (`qi_max · (1 − Σ reserved)`, combat-defence.md rule 10), as start shares already are (combat.md rule 3), not against the full `qi_max`.
- **Why the build needs it:** bare-fist reserves up to 0.29 of its pool for auras in art slots. Read against the full `qi_max`, Steady Breath (≥ 50 %) and Full Sea (≥ 80 %) could never both hold for a side with more than 20 % reserved, so reserved wards would quietly switch off every "full pool" Effect.
- **Trade-off:** none for unreserved sides. It makes heavy reservation slightly kinder to "full pool" Effects, which is the intent of reserving.

### curse-engine: An event for "your curse was cleansed from the target"
- **Kind:** new key or readable
- **Touches:** design/gdd/effects.md rule 5 (events); design/gdd/combat.md rule 9 (trigger events)
- **Proposal:** extend two-clocks' staged event "your debuff stacks were removed by a cleanse" to curses: it fires on the applier's side when a cleanse art, talisman or Effect removes a curse that side laid, carrying the curse, its stacks and the pulses it had left.
- **Why the build needs it:** the Petty-Man Effigy's close, Backlash ("a curse of yours cleansed from the target is placed on you with the time it had left"), reads it. Without the event the enabler has no price, and an enabler with no price is rejected (effects.md rule 14).
- **Trade-off:** none in maths: the cleanse already knows what it removed. One Breakdown line. It also lets Cinder Debt (two-clocks) cover curses later if wanted.

### curse-engine: Let one keystone raise curse slots for its owner's curses
- **Kind:** change to an existing rule
- **Touches:** design/gdd/combat.md Formulas F (`curse_slots` 3, "most curses on one target") and its curse-bounds table
- **Proposal:** add one line: "an Effect of tier `keystone` may let its owner's curses fill one more slot on a target than `curse_slots`; never more than one, whatever the sources". The fourth curse follows the same replace rule (least time left) when a fifth would be laid.
- **Why the build needs it:** the Fourth Nail (Nguyên Anh arc) puts Heavy Breath beside Sealed Meridian, Sundered and Exposed. In the paper model that fourth name is what makes a top-end foe unable to afford its 1.5 s opener.
- **Trade-off:** a cap shift, one of the strongest forms; bounded at +1 and paid by its close (curses on you last twice as long, which Backlash makes real). Curse defence (status resistance, cleanse) becomes a little more valuable for NPCs at Nguyên Anh and above; watch cleanse arts' share of NPC loadouts.

### curse-engine: A curse-effect stat (`curse_effect_pct`)
- **Kind:** new key or readable
- **Touches:** design/gdd/modifiers.md Stat List (Combat: offence, status family) and General Catalogue
- **Proposal:** `curse_effect_pct`, op I, target own curses: each curse's number × (1 + X/100); each curse's own maximum (`curse_cost_raise_max`, `curse_drain_raise_max`, `curse_heal_taken_max`) still clips. Small +4 %, notable +25 % (first guess, as `stack_effect_pct`). Locks and blocks (Sealed Meridian, Silence) have no number and gain nothing.
- **Why the build needs it:** it is the plain-number rung of a curse build (Deeper Nails), the curse twin of the element stacks' `stack_effect_pct`. Without it a curse build's only scaling is Effects.
- **Trade-off:** it grows the uncapped curses (Sundered, Exposed, Slackened Soul, Stagnation), all of which push resistance below 0 since 2026-11-10, where every point amplifies. Watch Sundered at +50 % (−225 a stack) in the harness; price it above `stack_effect_pct` if it outruns it.

### curse-engine: Say when a curse starts working
- **Kind:** change to an existing rule (clarification)
- **Touches:** design/gdd/combat.md rule 10 (Pulse: "A status or curse applied between pulses first counts at the next one") and rule 8
- **Proposal:** state that a curse's **rule** applies the moment it is placed (later hits in the same instant meet it), and only its **duration** first falls at the next pulse. Ticks keep "first ticks at the next pulse".
- **Why the build needs it:** the build is the requesting side in a 0.5 s instant: its Slipper Blow lands, the litany lays Sealed Meridian, and the enemy's opener in the same instant should meet the lock. If curses wait for the pulse, the lock misses the first opener and the build loses its top-end matchup (paper model: the first unprotected opener deals about 10,000 of 19,200 health).
- **Trade-off:** none for ticks. It makes slot order and the requesting side matter a little more for curse arts, which rule 10 already intends.

### beast-carry: A companion that can be hurt, healed and shielded (beast in the open)
- **Kind:** new system
- **Touches:** design/gdd/combat.md rule 19 and Formulas J; design/gdd/combat-defence.md rule 16 (heal and shield targets) and Formulas B; design/gdd/effects.md rule 5 (readables "companion health share", "companion Down")
- **Proposal:** an opt-in companion state, opened only by an Effect (the staged Shared-Heart Contract). The companion gets a health bar of `beast_health_share` 0.5 × its owner's maximum health (× `companion_health_pct`); `beast_share_taken` 0.30 of the damage that reaches the owner's health from hits (after the owner's whole defence path) lands on it instead; ticks, soul hits and fatigue are never shared. The owner's heals, health restores and shield casts may target it. At 0 it is Down (no strikes, no sharing) and rises after `beast_rise_s` 8 s at 25 %, or when an Effect stands it up. Every companion without the Effect keeps rule 19 exactly (untargetable, never removed).
- **Why the build needs it:** the seed's "heal or protect the beast" is empty while a companion cannot be hurt. This makes the keeper's arts matter and gives the minion build its real weakness: a Down beast means a side that deals nothing.
- **Trade-off:** a second health bar in the fight log and the Breakdown, and one more Down rule. It is a net defence gain for the keeper (a second bar takes 30 %), paid for by the Contract's close (no damaging arts). Fights with it may run longer; fatigue still ends them.

### beast-carry: Redirect the basic attack to the companion
- **Kind:** change to an existing rule (new Effect action)
- **Touches:** design/gdd/effects.md rule 6 (the closed action list); design/gdd/combat.md rule 13 and Formulas A2
- **Proposal:** add the action "your basic attack becomes a companion strike": on the basic attack's timer the owner's companion strikes instead, with its tags, `c_comp` and companion modifiers; the owner's own basic attack no longer exists for the fight. Only an enabler may carry it (it is a closing rule as well as a payload).
- **Why the build needs it:** it is Lent Hand, the half of the Shared-Heart Contract that makes the beast the whole damage (two timers instead of one beside the keeper's own fist).
- **Trade-off:** the swap is close to even (`c_comp` ≤ 1.0 = `basic_coef`), so the gain is only the companion's modifiers and timer rules; the owner loses crit on that timer. Bounded by `cooldown_min`.

### beast-carry: Let speed and timer actions reach the companion's timer
- **Kind:** change to an existing rule, plus a new key
- **Touches:** design/gdd/combat.md Formulas A2 (`basic_cooldown` is the companion's fixed timer; art speed applies to arts only); design/gdd/effects.md rule 6 ("move a timer"); design/gdd/modifiers.md Stat List
- **Proposal:** a key `companion_speed_pct` (the tree catalogue's "Companion attack speed" row): `comp_cd_eff = max(cooldown_min, basic_cooldown / (1 + (companion_speed_pct + bonded_art_speed) / 100))`, where `bonded_art_speed` is the owner's `art_speed_pct` only under the Bonded Spirit keystone. "Move a timer: shorten your own" may name the companion's timer, never sooner than `cooldown_min` after its last strike.
- **Why the build needs it:** rate is a companion build's only scaling past `c_comp_cap`, since it cannot crit. With two timers floored at 0.5 s the beast bites four times a second.
- **Trade-off:** companions gain a ×2 rate ceiling. It mirrors `basic_speed_pct` (bare-fist's suggestion), which leaves the companion alone, so the two rules can share one formula shape.

### beast-carry: Say where the Fire buff's "damage dealt" goes, and whether companion hits count
- **Kind:** change to an existing rule (clarification)
- **Touches:** design/gdd/effects.md rule 9a (Fire buff: "+1.2 % damage dealt") and Formulas D; design/gdd/combat.md Formulas B
- **Proposal:** state the layer (or a factor outside M) that Fire buff stacks fill, and that a companion's hits, being the side's direct damage (Formulas J), count. This build assumes a factor on all the side's direct damage, outside M.
- **Why the build needs it:** the keeper's buff arts pour Fire stacks into the side (every 1 % of maximum linh lực a second holds about 30 stacks). Outside M that is a ×2.4 to ×3.1 factor at 100–150 stacks; inside L1 it is about ×1.1 because L1 is already near its soft cap.
- **Trade-off:** a pure buffer with no hits of its own (any build whose damage is not its arts) can hold far more stacks than the equal-value fit assumed (1 stack for 10 s per firing). If that is too strong, the fix is a falling return on stack count, not a cap on companions.

### beast-carry: Element-tagged creature records
- **Kind:** new key or readable
- **Touches:** assets/data/creatures_linh_thu.json (no species list today); design/gdd/effects.md rule 9a; Spirit Beasts quick spec
- **Proposal:** the by-root missing piece "Element-tagged companions": a creature species record with an element tag, so its fixed art carries that element and grants its stacks; stack purity 0 unless the record sets one (Effects rule 9a already says so for beasts).
- **Why the build needs it:** the Moss-Striped Tiger's bite carries [moc] and lays Poison, which switches on Pack Hunt from the first bite and lets Wood conversion lines (Rot Seeps In) reach it.
- **Trade-off:** species records are new data for Spirit Beasts; nothing else changes.

### triple-convert: Write down that a part's earlier types are a scope and a readable
- **Kind:** change to an existing rule (a clarification)
- **Touches:** design/gdd/modifiers.md rule 8 (scope) and Formulas B (breadth); design/gdd/effects.md rule 5 (readables)
- **Proposal:** two sentences. Rule 8: "A scope may name two damage types, such as [fire, chaos]; it matches only a converted part whose type and history hold both, and its breadth is narrow (two family tags) or family ([physical] or [force] with another type)." Rule 5: add "a hit part's earlier types (its history, Combat Damage Types rule 6)" to the in-fight readables, so an Effect may count them.
- **Why the build needs it:** Combat Damage Types rule 6 already gives converted parts their history as offence tags, but the Modifier System's validation rule ("a scope the stat's target can never match fails validation") could reject a two-type scope, since a part has one type. The build's L2 cap and its identity Effect (Former Shapes: L5 +20 per earlier type) both rest on this reading.
- **Trade-off:** it creates a small family of rows only converters can use, priced at the narrow tier (×2.0 per W against universal). Stacked conversion into Chaos is already on the balance pass's watch list (effects.md, conversion note). Nothing else changes.

### triple-convert: Let one keystone allow a third conversion per hit
- **Kind:** change to an existing rule (optional)
- **Touches:** design/gdd/combat-damage-types.md rule 6 ("at most 2 conversions per hit") and Tuning Knobs ("conversions per hit", safe range 1–3)
- **Proposal:** the global knob stays 2. One keystone, The Fourth Smelting (Kim Đạo Lò Rèn, Deity Transformation), raises its holder's limit to 3, and closes one art slot. Parts per hit grow to at most 4 × the authored parts, as the knob's row already describes.
- **Why the build needs it:** it does not; the legal chain is complete at two. It is the legend step for a Wood–Fire–Metal root that converged Thunder: Physical → Fire → Lightning → Chaos, a fourth family of L2 and Thunder's crit stacks.
- **Trade-off:** a cap shift, among the strongest pieces in the game, so it stays single and costs a slot. The Breakdown line grows to four shapes ("Chaos ← Lightning ← Fire ← Physical"), the readability risk the Tuning Knobs row names. NPC Builds must treat it as a rare capstone.

### unkillable: Health overflow (overheal) as a readable
- **Kind:** new key or readable
- **Touches:** design/gdd/effects.md rule 5 (readable quantities); combat-defence.md rule 17 ("overheal is lost")
- **Proposal:** add "health overflow: the healing lost to a full health bar, from any source (regeneration, heal arts, leech, Effects), as an event per pulse window" to rule 5's list, beside the linh lực overflow event #44 added. A Down refusal is not healing and never counts (combat-defence.md rule 19). Breakdown line: "Overheal 4,210 (8.7 %)".
- **Why the build needs it:** its identity piece, Surplus Life, turns overheal into Poison on the enemy (1 stack for 10 s per 1 % of maximum health overhealed, at most 30 a pulse). Without the readable, healing past full is simply lost and the build can win only through fatigue.
- **Trade-off:** one new event, bounded by the side's own healing. It opens a family of "overheal becomes X" Effects (a shield, a ward refill, damage), each of which must name its own cap. It costs the engine one sum per side per pulse.

### unkillable: Say whether granted element stacks roll a status chance
- **Kind:** change to an existing rule (clarification)
- **Touches:** design/gdd/effects.md rule 6 (action "grant element stacks") and rule 9a; design/gdd/combat.md Formulas F (`p_status`: "status resistance counts against every status, guaranteed ones included")
- **Proposal:** state it in one line. Either (a) element stacks granted by an Effect or an art are placed without a roll (they are priced by the stack charge, Formulas D, not by chance), or (b) each debuff batch rolls `p_status` once against the target's status resistance, with the 5–95 % clamp. This build assumes (a).
- **Why the build needs it:** "damage low but certain" rests on it. Under (b) a high status resistance becomes a second counter to Surplus Life's Poison, beside cleansing. That is acceptable, but today the two rules can be read either way.
- **Trade-off:** (a) makes status resistance useless against Burn and Poison stacks, so cleansing wards are the only answer to a pile. (b) adds a draw per batch to every stack build and makes stacks chance-dependent, which rule 15 wants kept to flavour.

### home-fortress: An `own_abode` ground tag, and home-only formations read by Combat
- **Kind:** new key or readable, plus a change to an existing rule
- **Touches:** design/gdd/combat.md rule 12 (preparation by situation) and rule 1 (ground tags in the fight request); the Event Engine's fight request (#23, no GDD); `crafting_formations.json` field `applies` (`home` / `always`); design/gdd/travel-map.md rule 8 (the founder owns a cave abode)
- **Proposal:** when a fight happens at a cave abode, the Event Engine stamps the ground tag `own_abode` for the side that owns it. Combat then counts that side's formations whose `applies` is `home` (today only the sheet reads `applies`, for Hộ Sơn Trận's `defense_pct`). An Effect may also stamp `own_abode` for its owner on the fight's ground (the Threshold Flags, in a foreseen fight only). Breakdown: "Ground: own abode; Hộ Sơn Trận, Hot Spring Array, Nine Rods Array count".
- **Why the build needs it:** the whole build is "the fight comes to my ground". Without a tag, Host's Advantage has nothing to read and the flags have nothing to carry; without Combat reading `applies`, home formations stay life-only numbers.
- **Trade-off:** sect seats and NPC abodes get the same advantage, so a raid on an elder's mountain becomes a real siege (good for the world, harder for raiders). Needs a rule for two owners on one ground (a sect seat inside a sect): the owner of the fight's place wins.

### home-fortress: Let a source raise a fight's situation one step
- **Kind:** change to an existing rule
- **Touches:** design/gdd/combat.md rule 12 (the Event Engine names foreseen, ambush or blind); the Event Engine (#23, no GDD); `crafting_talismans.json` (`use` values)
- **Proposal:** a source may raise the situation for its owner's side only, by one step, at a named place: a home formation with `situation_step` (the Alarm Array: blind → ambush at your abode) or a life talisman (the Challenge Letter: the next fight with a named rival is foreseen, at your abode, within a season; a refusal is a World Database fact). Never two steps from one source, never a change to the other side's situation, and a tribulation is already foreseen.
- **Why the build needs it:** the seed asks what the player does to force fights onto their ground. These are the two levers: being found at home stops being a blind fight, and being hunted becomes an appointment.
- **Trade-off:** fewer blind fights at home weakens the ambush as a threat for anyone with an abode, so the Alarm Array has upkeep and caps at ambush (not foreseen). The letter adds an Event Engine branch (refuse, accept, ignore) and an NPC behaviour (elders send letters too).

### home-fortress: A layer's total before its cap, as a compile readable
- **Kind:** new key or readable
- **Touches:** design/gdd/effects.md rule 5 (readables); design/gdd/combat.md Formulas B
- **Proposal:** add "for a named art (by slot), the sum of its `x_i` from compile-time sources before the cap" to the compile readables. Today an Effect can read the per-hit event "a named cap's clipped amount", which suits per-hit payloads but not a stat fixed for the fight.
- **Why the build needs it:** Overbuilt Walls turns the L4 surplus into ward strength for the whole fight. A per-hit event would make ward strength change hit by hit and leave the opening (before slot 1 fires) unwalled.
- **Trade-off:** one sum per side at compile, cheap. Scoping by one art keeps it unambiguous when modifiers carry different tags.

### home-fortress: A fight payload for pills, coatings and talismans
- **Kind:** new key or readable
- **Touches:** design/gdd/combat.md rule 12 ("each prepared item adds modifiers to a layer"); design/gdd/item-database.md (pill and talisman records); the Alchemy and Talismans quick specs; design/gdd/character-stats.md Formulas D (`pill_potency`)
- **Proposal:** every pill, coating and combat talisman record gets a `fight_payload`: a list of modifiers (L4 `damage_more` with a scope, or a stat), the situations that allow it (foreseen; ambush if carried ready), and what scales it: `pill_potency` for pills (quality, `pill_effect_pct`, toxicity), talisman power for talismans, quality for coatings. Today combat talismans add `attack_pct` "for one fight" on the old sheet model and pills carry only life effects.
- **Why the build needs it:** four of its five kinds of preparation are items. Every staged pill and coating of this run names the same gap.
- **Trade-off:** pills become the main L4 source for most builds, so toxicity (which lowers potency) becomes a real limit on fighting often. That is the intended cost.

### home-fortress: Say how many formations count on one ground, and whose
- **Kind:** change to an existing rule (clarification)
- **Touches:** design/gdd/combat.md rule 12 ("a formation laid on the ground", singular) and Formulas B (L4)
- **Proposal:** state it: in a foreseen fight away from home a side lays one formation; at its own abode every standing home formation counts; when both sides lay one on the same ground, both count unless an Effect such as Taken Ground says otherwise.
- **Why the build needs it:** the build's home array is three or four formations (Hộ Sơn Trận, Hot Spring Array, Nine Rods Array, the Alarm Array); away it lays one. Today rule 12 can be read as one formation everywhere, which would make the home and the road the same.
- **Trade-off:** home stacking is strong, but it is paid in years of upkeep, materials and the formation skill cap (`max_level = min(max_level, skill + 1)`), and it counts only where the owner lives.

### armoury-mind: Let Effects read the pieces their owner controls
- **Kind:** new key or readable
- **Touches:** design/gdd/effects.md rule 5 (readable quantities); design/gdd/item-database.md rule 11 (what "controlled" means)
- **Proposal:** add to the compile reads: "the artifacts its owner controls (Item Database rule 11: equipped, within thần thức, counted in equip order), their count, and each piece's role tags and base". Pieces the thần thức cannot control are never counted. Breakdown: "Controlled pieces: 7 (weapon 4, ward_gear 2, body_gear 1)".
- **Why the build needs it:** its enabler (Garrison Mind: each weapon piece strikes each pulse) and two Effects (Full Rack: L5 per piece past the third; Humming Shields: linh lực per ward piece) all read the count and roles. Today rule 5 has free thần thức but not the pieces.
- **Trade-off:** small: the data is already in the compiled profile. It opens a family of gear-count Effects, so each needs a cap (Full Rack +50, Humming Shields 1.5 %) and `trig_cap` bounds strikes.

### armoury-mind: A close that thins soul defence (Thinned Mind)
- **Kind:** change to an existing rule
- **Touches:** design/gdd/combat.md rule 3 ("the thần thức that equipped artifacts occupy … does not lower the thần thức a side fights with") and Formulas E2 (`divine_sense_def`); design/gdd/effects.md rule 6 (closing-rule action)
- **Proposal:** let an enabler's or keystone's close set, for its holder only, `divine_sense_def = free + k × bound` in Formulas E2, with 0 ≤ k ≤ 1 stated on the record (Garrison Mind: k 0.5). Rule 3 stays true for everyone else.
- **Why the build needs it:** it is the enabler's price, and the lore's (the founder died to a soul needle). At 83 % of thần thức bound it leaves 0.58 defending: rho ×1.71 and a soul hit's share ×2.94 at `soul_beta` 2. It makes the soul dealer of Combat rule 18 the build's counter and gives soul resistance, soul wards and unbinding a piece before a fight a real price.
- **Trade-off:** it adds a branch to E2 and a second thần thức number to the profile. Soul numbers are still guesses (Combat Open Question 16), so k should be tuned with them; at k 0 it would be a death sentence against any soul art.

### armoury-mind: Check the top-end gear anchor against the slot limit and thần thức
- **Kind:** change to an existing rule (a note on the anchors)
- **Touches:** design/gdd/combat.md Formulas B (top-end L3 3.5) and design/gdd/combat-defence.md Formulas A0 (top-end artifact defence 5 × B_p)
- **Proposal:** state what gear the top-end profile implies and check it against `equip.max_slots` (6) and a top-end thần thức. With Item DB Formulas D, a Cực phẩm piece of the realm's tier gives L3 points 3 × base attack ÷ stage and a_w 3 × base defence ÷ 100 ÷ stage, so L3 at its cap needs two Seals with Liệt +30 and a_w 5 needs four Shields with Kiên +30: six pieces, every slot, about 120 units of base thần thức cost against a typical cultivator's 45 (thần hồn 45 at stage 1.0). At stage 1.45 it needs more than six.
- **Why the build needs it:** the armoury build reaches L3's cap easily but carries a_w 2.8, not 5, because it spends slots on strikers; the anchor it is measured against is otherwise reachable only by an all-gear build. The harness should know this when it fits the W shares.
- **Trade-off:** none to rules; it may lower the top-end artifact defence anchor or the W share given to ward strength.

### one-art: An art coefficient past the lint, from one enabler
- **Kind:** change to an existing rule, and a new key
- **Touches:** design/gdd/combat.md Formulas C (the art lint on `c_art`); design/gdd/modifiers.md Stat List (new key `art_coef_add`)
- **Proposal:** add to Formulas C: "after the lint, an art's coefficient adds `Σ art_coef_add` from Effect payloads". New key `art_coef_add` (F, flat, target art), rare: an Effect payload only, never a tree node, affix or technique line. Its one source is the Vow of the One Stroke (enabler): +0.4 per empty art slot, cap +2.8, closing every second art, talisman, escape art and art-slot ward.
- **Why the build needs it:** the seed asks what one art has to be when everything feeds it. The lint already makes it the largest legal art (6.75 at cost 0.125 and 12 s); the empty slots need a way to make it larger than any art a full loadout could carry, or leaving them empty is only a loss of options.
- **Trade-off:** the lint stops being the last word on an art's size, so the Breakdown must show the added part ("Room to Grow +2.8"). Bounded by the slot count, which is uncapped through `bonus_slots`; the cap +2.8 holds it. The NPC generator must treat the Vow as all-or-nothing.

### one-art: Measured Stroke's threshold is out of reach
- **Kind:** change to an existing rule
- **Touches:** design/gdd/effects.md Starter Effects, Rule change table (Measured Stroke); design/gdd/combat.md Formulas A2 (`cooldown` 0.5–12 s since #44)
- **Proposal:** Measured Stroke applies to arts with an authored cooldown of 20 s or more, but #44 cut the authored range to 0.5–12 s, so no art can ever meet it. Lower the threshold to 10 s (the top of the new range, as 20 s was near the top of the old 0.5–30 s).
- **Why the build needs it:** a one-art build loses a whole 2.5 s cycle to one evade; Measured Stroke (no evade, no crit) is its listed answer to evaders, and today it does nothing.
- **Trade-off:** none for content; only 10–12 s arts qualify, which the lint already pays for in cooldown. It also restores the Effect for slow formation arts and nukes it was written for.

### one-art: One meaning of "empty art slot"
- **Kind:** new key or readable (a clarification of an existing readable)
- **Touches:** design/gdd/effects.md rule 5 ("slots and loadout"); Starter Effects Bare Rack
- **Proposal:** state in rule 5 that an empty art slot is one holding no art, talisman, escape art or ward. Effects that want to count wards too (the staged Quiet Channels: "empty, or a ward") say so in their own rule.
- **Why the build needs it:** five pieces of this build count empty slots (Room to Grow, Clear Path, Undivided, Empty Hall, Quiet Channels), and Bare Rack already does; without one meaning, a ward placed in an art slot may count as empty for some and not others.
- **Trade-off:** none; it removes an ambiguity before data entry.

### cooldown-floor: Art cost accepts the dampened op
- **Kind:** change to an existing rule
- **Touches:** design/gdd/combat.md Formulas E (art cost); design/gdd/modifiers.md Stat List row "Art cost" (ops) and rule 6a
- **Proposal:** `art_cost_pct` gains op D. The cost becomes `cost_share · (1 − cost_red) · (1 + cost_raise) · qi_max ÷ (1 + D / 100)`. The increased reduction keeps its 0.5 cap; the dampened part never reaches 0, so it needs no cap of its own (rule 6a's stated strategy). Only Effect payloads grant D on art cost at first, each with its own cap (Slipstream: +200, so ÷ 3).
- **Why the build needs it:** its identity piece, Slipstream (Thuận Phong), turns art speed that `cooldown_min` clips into a lower cost. Read by the rules (no run): at Nguyên Anh, six cheap arts at the floor cost about 14.5 % of maximum linh lực a second against about 11.8 % income; with Slipstream about 6.6 %. Today cost reduction stops at the 0.5 cap, so no amount of surplus speed can pay the bill.
- **Trade-off:** a second shape on one stat (the Breakdown shows both). It makes floor builds sustainable, which is the point; Ice stacks and Heavy Breath still multiply the cost back up, so the cost-tax enemies remain the counter. Watch the macro: a solved bill at 13 hits a second is a high damage rate (the build is above the top-end anchors per second).

### cooldown-floor: Trigger limit +1 as a rare cap shift
- **Kind:** change to an existing rule
- **Touches:** design/gdd/combat.md Formulas G (`trig_cap` 6 per side); design/gdd/modifiers.md rare table (rule 13)
- **Proposal:** a rare stat `trig_cap_bonus` (F, +1 per source) adds to `trig_cap` for its owner, allowed only on keystones, named items, quest rewards and Way capstones, like `bonus_slots`. The tree catalogue already lists "Trigger limit (`trig_cap`) ○ +1 firing between pulses" as a rare one-off with no rule behind it.
- **Why the build needs it:** at 12 art firings a second it fills the 6 trigger firings a pulse with either Breath Between Blows (sustain) or Echo (extra hits), never both. One more firing lets it carry a little of each.
- **Trade-off:** `trig_cap` is what keeps trigger loops finite; +1 per rare source keeps it bounded by how many rare sources exist. Curse-engine, armoury-mind and one-art meet the cap too and would want it, so it should stay rare and single per source.

### cooldown-floor: What "a hit landed" means for on-hit sustain
- **Kind:** new key or readable (a clarification of an existing rule)
- **Touches:** design/gdd/modifiers.md rule 1 (the sustain exception) and AC-MD-33; design/gdd/combat-defence.md rule 1 (order: evade first)
- **Proposal:** state that `linh_luc_on_hit_pct`, `leech_linh_luc_pct` and `leech_health_pct` read every own hit that is not evaded: art hits, the basic attack, companion hits and trigger free hits. A hit that block takes to 0 still landed for `linh_luc_on_hit_pct` (leech, a share of damage dealt, gives 0 there by itself).
- **Why the build needs it:** half of its income is `linh_luc_on_hit_pct` paid 13 to 16 times a second; whether Echo's free hits and fully blocked hits count changes that income by up to a fifth.
- **Trade-off:** none for content; it fixes a reading before data entry. Counting trigger hits makes Echo-style Effects slightly better for sustain builds, still bounded by `trig_cap`.

### slow-thunder: Overflow is read whole by every Effect that reads it
- **Kind:** new key or readable (a clarification of an existing readable)
- **Touches:** design/gdd/effects.md rule 5 (the overflow event, #44)
- **Proposal:** state that every Effect reading the overflow event reads the whole amount lost to a full pool that pulse. Overflow is never split or used up between Effects, as a hit event is not used up by the Effects that read it. Breakdown: "Overflow 5.9 %: Still Water healed 412; Thunderhead 24.1 % gathered".
- **Why the build needs it:** its engine is the same unspent breath doing two jobs: Still Water heals for half of it and Thunderhead gathers it for the 12 s peal. If the first Effect in order took the overflow, one of the two would read 0. bare-fist's Stored Breath note already assumes the whole-read with Still Water.
- **Trade-off:** a build can stack several overflow readers on one pool, so overflow becomes worth more the more readers it has. Each reader is bounded by its own cap (Thunderhead +3.0) or by the pool's regeneration, which is on a log curve (combat.md Formulas E), so the total stays bounded.

### slow-thunder: A second, capped source of `art_coef_add`, held until the longest art lands
- **Kind:** change to an existing rule
- **Touches:** design/gdd/combat.md Formulas C (art lint); design/gdd/modifiers.md Stat List (`art_coef_add`, one-art's proposal); design/gdd/effects.md rule 8 (bare-fist's held payload)
- **Proposal:** allow `art_coef_add` from a second Effect, Thunderhead (tier `major`), as a held payload. It gathers overflow and is spent on the next landed hit of the art with the longest authored cooldown, at +0.1 coefficient per 1 % of maximum linh lực gathered, capped at +3.0 per landing and cleared when spent. The key stays an Effect payload only, never a node, affix or technique line. one-art's entry names the Vow of the One Stroke as its one source; this adds a second under the same rule.
- **Why the build needs it:** it is how "damage per linh lực" also counts the linh lực not spent. The lint buys 0.24 coefficient per 1 % of the pool spent; this pays 0.10 per 1 % kept, so keeping is worth less than spending but comes free with a full ward.
- **Trade-off:** a second way past the lint, so the Breakdown must show the added part. Bounded by the +3.0 cap, by regeneration's log curve and by pressure, since every drain bill the holder pays comes off the gathering. The NPC generator should give it only to kits whose longest art is slow and cheap, or it is wasted.

### giant-killer: Strike at a shifted fight unit (Half a Realm)
- **Kind:** change to an existing rule
- **Touches:** design/gdd/combat.md Formulas C (`base = U_att · stage_att · c_art`), F (`raw = U_src · …`), G (`free_hit = U · …`); design/gdd/effects.md rule 6 (closed action list)
- **Proposal:** add an Effects action "shift the fight unit a side's hits, ticks and trigger hits are struck at", read at compile, bounded to at most half a realm (× 2.512^±0.5 = ×1.585 or ÷1.585). Pools, fatigue and soul attacks do not move. Breakdown line: "Half a Realm: struck at ×1.585". The only user is the enabler Half a Realm (Bán Cảnh): against a foe 1–2 realms above, both sides strike half a realm closer; against equals and lower, its holder strikes a quarter realm down (÷1.26).
- **Why the build needs it:** the fight unit (×2.512 a realm on damage and on health, ×6.31 in fight power, Formulas A) is the largest part of the realm gap, and no existing action touches it. With the shift, one realm up costs ×2.51 instead of ×6.31.
- **Trade-off:** a new kind of power outside the layers M and their caps, like suppression and crit. Bounded by the half-realm limit and by the build's own close. It must stay off at gaps of three or more (see "Gap readers stop at two"). A rule NPCs use too: an NPC needle one realm below the player is a real threat.

### giant-killer: Readable "higher-realm knockouts this life"
- **Kind:** new key or readable
- **Touches:** design/gdd/effects.md rule 5 (sheet reads at compile)
- **Proposal:** a compile readable: the number of cultivators whose major realm was above yours at the time, whom you knocked out in this life. Realms already receives knockouts for capability #9 (combat.md Interactions), so only the realm comparison is new.
- **Why the build needs it:** Mountain Notches (+1 pierce and +3 Physical penetration per such knockout, up to +20 and +60) is the build's arc: the needle grows with the story.
- **Trade-off:** a life-history readable, bounded by its cap; NPC duellists read it the same way. Slight save-data cost (one counter).

### giant-killer: Readable "the target is a boss"
- **Kind:** new key or readable
- **Touches:** design/gdd/effects.md rule 5 (in a fight, compile)
- **Proposal:** true when the target's `boss_pool_mult` is above 1 (combat.md rule 18; tribulation bosses included). Gap-reading Effects may count such a target as one realm above.
- **Why the build needs it:** at Hóa Thần there is no realm above, so a giant-killer has no prey. With this readable it hunts bosses. Ordinary bosses already demand 4 s from a top-end build, so the 4-second rule bounds it.
- **Trade-off:** boss fights get a specialist answer. Tribulation bosses are already one realm up, so they are unaffected.

### giant-killer: Gap readers stop at two
- **Kind:** change to an existing rule
- **Touches:** design/gdd/effects.md rule 5 (the realm gap readable); protects design/gdd/combat.md Formulas H's target table
- **Proposal:** any Effect that reads the realm gap for power pays out at gaps 1 and 2 only, never at 3 or more. Escape Effects (Beneath Notice) are exempt.
- **Why the build needs it:** the build stacks four gap readers (Half a Realm, Against the Heavens, Stiff Neck, Through the Ceiling). By the clash model's fight-power ratio, letting them scale past two realms would lift a top-end build's three-up win chance from 0 % to roughly 7–26 %, against the user's target of ≤ 2 %. One shared convention keeps that target true for every future vượt cấp piece, not only this build's.
- **Trade-off:** none for content inside it. It makes "three realms up" a hard wall by rule, so the only answer there is escape, as the concept intends.

### starter-flame: Effects action "restore linh lực" on a tick event

- **Kind:** change to an existing rule
- **Touches:** `design/gdd/effects.md` rule 6 (action list) and the event list (tick dealt); Combat linh lực rules for the cap on refunds
- **Proposal:** allow an Effect on the "tick dealt" event with the action "restore linh lực" equal to a share of the tick's damage (Embers Feed the Hearth: 25 %), bounded by the pool maximum and reported in the Breakdown as "Embers: +n linh lực".
- **Why the build needs it:** the whole build's forgiveness comes from Burn ticks paying for the arts that apply them. Without it the build falls back to a regeneration stack.
- **Trade-off:** a Burn build gets near-free sustain, so Burn needs a counter that stays real: cleansing and Fire resistance already do that. It must not stack with other refund Effects without a per-pulse cap.

### starter-venom: Stack-count Per modifier on ticks
- **Kind:** Rule change
- **Touches:** `design/gdd/modifiers.md` (Per form, scope readables); `design/gdd/effects.md` rule 9a (element stack reads)
- **Proposal:** A modifier may read the number of the applier's element stacks on the target at each tick, as "X % more per N stacks, up to a cap", in layer L2 (not L5, which ticks never use).
- **Why the build needs it:** Patient Venom, the reward for a long poison fight, is a Per on stack count; without it the build's late-game scaling is a flat number.
- **Trade-off:** a tick now reads live state, so the Breakdown must show it. It is bounded by its cap and is NPC-safe.

### starter-venom: Cleanser telegraph in preparation
- **Kind:** Rule change
- **Touches:** `design/gdd/combat.md` rule 12 (preparation and what a foreseen fight reveals); the Guidance Layer
- **Proposal:** Before a foreseen fight, show whether the enemy carries a cleanse (a cleansing ward payload or a cleanse art), as one line on the enemy profile.
- **Why the build needs it:** The build loses 0 to 19 to a cleanser, and the lesson is meant to be learnt in preparation, not by dying. Without the line, a new player has no way to adapt (swap Rot Bloom for a hit art, take Seeds Left Behind).
- **Trade-off:** It gives away part of an enemy's profile, which Combat Open Question 4 treats as information worth paying for; keep it for foreseen fights only.

### starter-blade: Crit as an event and a self-stack source

- **Kind**: New rule.
- **Touches**: `design/gdd/effects.md` (status families and events), `design/gdd/combat.md` rule 8 (crit).
- **Proposal**: Make "you land a crit" a readable event for Effects. Allow a self-status family (Whet) that gains a stack on that event, with its own timer per stack, a stack cap of 8, and +2 pp crit chance per stack. Also let "you crit within the last N seconds" be a readable condition for an L5 bonus.
- **Why the build needs it**: Whetted Edge, Hot Edge and Flowing Water all hang off the crit event; without it crit is only a flat chance and the build has no loop.
- **Trade-off**: Crit feeding crit adds variance, and Combat rule 15 wants chance to stay a flavour. The stack cap (8 x 2 pp = 16 pp) and the existing `crit_chance_cap` 0.5 bound it, and the loop is deterministic given the seed.

### starter-blade: Overflow on the crit-chance cap

- **Kind**: Rule change (a cap overflow).
- **Touches**: `design/gdd/combat.md` rule 8 and Formulas C (`crit_chance_cap` 0.5, `crit_mult_cap` 3.0).
- **Proposal**: Crit chance above the cap converts to crit multiplier at 1 pp of multiplier per 2 pp over, still bounded by `crit_mult_cap`. Shown in the Breakdown as "crit chance over the cap".
- **Why the build needs it**: A crit build otherwise hits a wall at 0.5 and has nothing to stack; this is the top-end upgrade that turns a working crit build into a finished one.
- **Trade-off**: It gives crit builds a long tail of useful stacking; `crit_mult_cap` 3.0 still stops it, so top-end offence is not raised by more than the multiplier cap already allows.

### starter-tide: Ward efficiency may read the pool share

- **Kind:** Change to an existing rule
- **Touches:** combat-defence.md Formulas A (ward drain rate); the Effects System readable list
- **Proposal:** Allow a ward modifier to be conditional on the owner's current linh lực share, for example Still Water: +15 ward efficiency while the pool is at or above 80 %.
- **Why the build needs it:** Brimming Tide wants the ward and arts both to pay for a full pool. Without this, the ward ignores how full the pool is and half the economy is invisible.
- **Trade-off:** The ward's strength then varies during a fight, which makes a Breakdown line longer and a drain ward harder to read; bound it with a single threshold and one modifier per ward.

### starter-tide: Max linh lực counts toward ward strength (Borrow)

- **Kind:** New rule
- **Touches:** combat-defence.md A0 (ward layers W2 to W5)
- **Proposal:** Depth Is Shield: 1 point of ward strength per 5 % of maximum linh lực above the realm's typical pool, capped at +40.
- **Why the build needs it:** It is the top-end piece that makes a deep pool also the wall, which is the fantasy of the build at Kết Đan.
- **Trade-off:** It counts the pool twice, as casts and as ward; the cap and the fact that the ward still drains the same pool are the bound.

### sect-ladder: Sect curriculum record

- **Kind:** new system data and a change to an existing rule
- **Touches:** NPC Builds (#24, no GDD yet) and Sects & Missions (#26, no GDD yet); Combat rule 2 (every modifier applies to NPCs) and the combat GDD's NPC Builds dependency
- **Proposal:** a sect carries a curriculum record: per realm, one technique, the arts it teaches, an artifact base, a pill, an array and a few Đạo nodes, plus a talent grade (laggard, plain, gifted) that moves a disciple one rung up or down the ladder. The NPC generator builds each member of that sect from the record at their realm, so the world's 5,000 cultivators come from a few dozen records plus rogues.
- **Why the build needs it:** the build is the standard kit of an ordinary Fire sect; without a record to hold it, it is only one build and not the template of a sect.
- **Trade-off:** NPCs of one sect are alike, so players can predict them; talent grades and an occasional off-curriculum art or item are the way to break that, and the curriculum should not hold powers above the "ordinary" level.

### mirror-hide: Return channel

- **Kind:** new channel (rule)
- **Touches:** `design/gdd/combat.md` Formulas G (Triggers) and rule 9, with a new G2; `design/gdd/combat-defence.md` rule 1 (the defence path)
- **Proposal:** a free-hit channel "Return": for each incoming hit part that enters the defence path (ticks at weight 0.25), the owner returns `return_share × pre_defence_damage × L1..L4(return) × supp`, delivered as a free Physical hit that meets the target's defence path. Clipped at `ret_cap × U × stage` per hit (ret_cap 2.0). Not a trigger: it uses no `trig_budget` or `trigger_depth`, and a return never causes a return.
- **Why the build needs it:** triggers are capped at half of your own direct damage, so a thorns build cannot be built from triggers. Return scales with what the enemy throws, which is the seed.
- **Trade-off:** a new channel that is strongest against the highest-damage foe; the per-hit cap and depth 1 bound it. Two return builds mirroring each other only end by fatigue.

### mirror-hide: Bait curse changes the enemy's basic cooldown

- **Kind:** rule change
- **Touches:** `design/gdd/combat.md` rule 8 (curses change rules, never pools); `design/gdd/effects.md` Status Catalogue
- **Proposal:** one curse, Bait (Mồi Nhử), shortens the enemy's basic attack cooldown by 20 % for its duration.
- **Why the build needs it:** a return build earns by being hit; the curse is the lever against enemies that attack slowly.
- **Trade-off:** it helps the enemy as well as the cursing build against anything that does not return. Duration is short and it takes a curse slot.

### mirror-hide: Health paid counts as a hit taken

- **Kind:** rule change
- **Touches:** `design/gdd/combat-defence.md` rule 1; `design/gdd/effects.md` event vocabulary
- **Proposal:** when an art costs health, that health is read as one hit taken for the Return channel, at most once per cast.
- **Why the build needs it:** enemies that evade, wait or stall give a thorns build nothing to return; this makes the build its own supply of hits, paid for by health regeneration.
- **Trade-off:** it gives any health-pay build a free return source; limited by the health cost and the art's cooldown.

### evade-dancer: Hit-evaded event

- **Kind:** New concept (an event).
- **Touches:** combat.md Formulas I (evade roll and the line that an evaded hit fires no on-hit trigger); effects.md rule 9 (events an Effect can listen to) and rule 12 (counted chance).
- **Proposal:** an evaded hit fires one "hit evaded" event on the defender, readable by Effects. It stays bounded by `trig_budget` and `trigger_depth`, and the evaded hit still deals nothing, drains nothing and fires no on-hit trigger of the attacker. The Breakdown shows "evaded n of m hits".
- **Why the build needs it:** Evade Pays, Reply and Carried Off all listen to it. Without it, evade is only a defence stat.
- **Trade-off:** more event traffic per fight and a new bound to test; enemies with Effects on evade (NPCs) get the same power, so a high-evade NPC becomes harder to kill.

### evade-dancer: Evade points over the cap readable

- **Kind:** Rule addition.
- **Touches:** combat.md Formulas I (`p_evade = clamp(...)`, `evade_cap`).
- **Proposal:** report the points the clamp removed (evade − accuracy + realm step above `evade_cap`) as a readable value, for Overflow modifiers.
- **Why the build needs it:** Surplus Breeze turns clipped evade into art speed, the one reason to stack evade past the cap.
- **Trade-off:** evade over the cap is no longer wasted, which slightly raises the worth of evade stacking; the overflow is capped at +20 % art speed to bound it.

### status-collector: A second Effect may raise Marked Prey's cap

- **Kind**: change to an existing rule
- **Touches**: `design/gdd/effects.md`, Starter Effects, Marked Prey (Limits: Cap +16)
- **Proposal**: an Effect, such as Tally Ten, may raise another Effect's stated cap, to a bound the second Effect names (here +48, twelve kinds). The cap shift is read at compile and shown in the Breakdown beside the Effect it raises.
- **Why the build needs it**: Marked Prey stops paying at four kinds, so the eight others a breadth build collects are worth nothing in L5.
- **Trade-off**: a count-reader at twelve kinds fills L5 on its own; the L5 cap of 100 and the three-curse limit bound it.

### status-collector: A live-count Per modifier in L2

- **Kind**: new rule
- **Touches**: `design/gdd/combat.md` Formulas B (L2), `design/gdd/modifiers.md` (Per form)
- **Proposal**: a modifier may grant L2 "more" per distinct own status on the target, read live each hit, with a stated cap (Crowded Ledger: +3 per kind, cap +36). L5 stays Effects-only.
- **Why the build needs it**: the count has two readers, one in L5 (Marked Prey) and one in L2, so the build's payoff comes from two layers.
- **Trade-off**: L2 is compile-time today; a live L2 term makes a Breakdown change during the fight and gives builds a second way to read a state.

### deity-warden: Boss phase script

- **Kind:** new system
- **Touches:** `design/gdd/combat.md` rule 10 (time), `design/gdd/combat-defence.md` rule 1 (the one-ward rule)
- **Proposal:** an NPC or boss profile may carry a phase list of up to four entries, each with a duration of at least 8 s, a ward model (drain, per hit, reserved, soul or off) and optional stat swaps. The fight clock moves it from one phase to the next; the order is fixed and shown in the Breakdown ("Phase 2 of 4: Lustration").
- **Why the build needs it:** the Warden is four wards that each shut one channel; without a script it is one ward.
- **Trade-off:** the simulator needs a phase clock to prove any boss, and a boss with a fixed list can be memorised, which is the intent.

### deity-warden: Ward-swap gap

- **Kind:** rule change
- **Touches:** `design/gdd/combat-defence.md` rule 1
- **Proposal:** when a holder's ward model changes mid-fight the old ward's remaining capacity is discarded and the holder has no ward for a short window (2 s here), announced by a Toll.
- **Why the build needs it:** it gives the fight a readable opening and stops a player from stripping one ward and hitting the next.
- **Trade-off:** a ward swap becomes a strong action for any holder; players with the Turning Key also gain it, so the gap must stay at 2 s or longer.

### meta-hunter: A curse on how costs are paid

- **Kind:** New Effect (curse) and a readable.
- **Touches:** `design/gdd/effects.md` (curse table, rule 5 readables); `design/gdd/combat-defence.md` Formulas E (cost payment, `art_cost_health_pct`).
- **Proposal:** Dear Blood, a curse: the foe's health-paid art costs are 1.5×. A readable gives the health a side has paid on costs this fight and in the last pulse; Called Debt returns 15 % of the last pulse's amount as a tick. Both need a holder of the Ledger Seal.
- **Why the build needs it:** `notes.md` § 2 says health-paid costs have no counter, and Withering only hurts the builds that also heal. Without a rule on the payment itself, the Hunter would have a bigger number and no answer.
- **Trade-off:** It gives a counter to one pattern, so a health-payer must now weigh meeting a hunter. A foe with status resistance can ignore it. If the 1.5× is too hard it can fall to 1.25×.

### meta-hunter: Incoming status stack cap with overflow

- **Kind:** Rule extension.
- **Touches:** `design/gdd/effects.md` rule 9 (stacking); `design/quick-specs/tree-modifier-catalogue.md` (a keystone row).
- **Proposal:** A wearer's cap on stacks of one named status (here Stagnation, 20). A stack that would exceed it is not applied and adds a small bonus (+0.4 % more, L5, capped at +40 %).
- **Why the build needs it:** Stagnation on hit is the other pattern the sect hunts; at 1 % per stack a cap of 20 removes the curse as a threat, and the overflow makes the pattern feed the hunter.
- **Trade-off:** It makes one curse nearly harmless for holders of the keystone. Applies per status, one keystone, so it does not answer Silence or Sealed Meridian.

### meta-hunter: Quarry knowledge

- **Kind:** Rule change.
- **Touches:** `design/gdd/combat.md` rule 12 (blind fights); world and NPC generation (a sect's listed quarry).
- **Proposal:** A sect may list a pattern as its quarry (health-payers, Stagnation appliers). Against a foe of that pattern the fight is not blind for the hunter, so L4 preparation counts.
- **Why the build needs it:** The hunter's L4 (150 points, a ×2.5 factor in the simulator run) only exists if the fight is not blind, which makes the build the right answer to a known foe.
- **Trade-off:** It gives sect members a prepared layer in some fights, so the world must tag patterns. It does not apply to the player unless the player joins the sect.

### loaded-dice: Fortune may feed a counted chance (through a keystone)

- **Kind**: Change to an existing rule
- **Touches**: Effects System rule 12 and Formulas A ("Fortune does not shift counted chance"); Combat Formulas I (`khi_van_per_point`)
- **Proposal**: One named keystone, The Loaded Table, may add `0.002 × khí vận` (at most +0.15) to every counted chance its owner has, after the chance's own cap and inside the global caps. It also counts the owner's evade (one chance, as rule 12 allows). The meter still takes no seeded draw, so the fight stays deterministic.
- **Why the build needs it**: It is the whole fantasy. The player gets "luck as a stat" but the luck is prepared (items, formation, pill) and shows as a number on a meter, so nothing is rolled. Without it fortune does nothing for a counted build.
- **Trade-off**: One more path from a soft stat (khí vận) into combat power. It is bounded (+0.15, a named keystone, escape closed) but a gambler with very high fortune hits the bound early; an Ill Star curse (Mệnh Đạo) is its counter.

### loaded-dice: Counted payouts as a readable event

- **Kind**: New system (small)
- **Touches**: Effects System rule 12 and the event list; Combat rule 9 (triggers)
- **Proposal**: When a counted meter reaches 1 it emits a `counted_payout` event with the chance's name. Per modifiers and Effects may read it (Stacked Meter: payouts in the last 8 s; Jackpot: every third crit payout; Winnings: refund on a crit payout). An art guard may read and spend a meter (Cash Out).
- **Why the build needs it**: A counted build has predictable moments but today nothing can hang a reward on them. This lets the payout be the thing the build is built around.
- **Trade-off**: Counted payouts become a trigger source, so they count against `trig_budget` and `trigger_depth` when they fire free hits. The Per cap and Jackpot's crit multiplier cap bound the rest.

### art-thief: Loan slots, copying the foe's art

- **Kind:** New system
- **Touches:** `design/gdd/combat.md` rule 13 (arts, cooldown timers and slot order), rule 10 (instant order), rule 9 (the trigger budget, for Spent Hand)
- **Proposal:** An enabler may turn every empty art slot into a loan slot at the start of the fight. When the foe casts a body or qi art, the oldest empty loan slot records a copy: the foe's tags plus `stolen`, a fidelity share of its coefficient (70 % base), half its cost share, a first firing at half its cooldown. The copy is an ordinary art for the copier: its cooldown, linh lực and all five layers are the copier's. One copy per art id; a full hand loses the oldest copy; soul, ward and escape arts cannot be copied; copies end with the fight.
- **Why the build needs it:** it is the whole of The Hollow Thief; nothing today lets one side use the other side's art.
- **Trade-off:** it makes a fight depend on what the foe casts, so a simulator must model the foe's casts as events; a foe with no art gives nothing, which is the intended counter. It can feed back on itself (two thieves copying each other), so one copy per art id and the fidelity cap matter.

### art-thief: The foe's art list known before the fight

- **Kind:** Rule change
- **Touches:** `design/gdd/combat.md` Open Question 4 (what a character can read about the foe while preparing), rule 12 (blind fights)
- **Proposal:** Allow a preparation piece to read the foe's most costly known art. In a blind fight it reads nothing unless a formation says so (the Standing Array keystone).
- **Why the build needs it:** Pre-Read, the Nguyên Anh answer to the slow start.
- **Trade-off:** it adds information to preparation and gives scouts a reason to exist, and it could trivialise ambushes unless blind fights stay blind.

### pacifist: Opposed cost payment (Debt Seal, Interest)

- **Kind:** change to an existing rule
- **Touches:** `design/gdd/effects.md` (Blood Casting, rule 11 pay-in-health) and `design/gdd/combat.md` rule 11 (linh lực as one pool)
- **Proposal:** an Effect on one side can make the other side pay a share of each art's cost in health, per stack, capped at 10 stacks and 50 % of a cost; and a second Effect returns 20 % of the linh lực the other side spends, up to 2 % of maximum a pulse.
- **Why the build needs it:** it is the only thing in the build that wounds the foe, and it is the engine.
- **Trade-off:** it puts a health cost on NPC casters, so anti-caster builds are stronger against caster sects; the simulator needs a new foe-side field to test it.

### pacifist: Flight is a win

- **Kind:** change to an existing rule
- **Touches:** `design/gdd/combat.md` Escape (lines about "the fight ends in flight with no winner")
- **Proposal:** when the fleeing side's opponent holds Open Palm Vow, the fight ends as a win for the opponent. A forced escape (Dread of the Ledger) starts the foe's escape channel at 8 or more Seals and half health.
- **Why the build needs it:** "outlast them until they flee" is only a win if the rules call it one.
- **Trade-off:** flight with no winner exists so callers can treat it as a failure; the proposal narrows that for one enabler. Soul Pressure builds would want the same.

### pacifist: Borrow attack into ward strength

- **Kind:** new rule
- **Touches:** `design/gdd/combat-defence.md` Formulas A0 (ward and body layers)
- **Proposal:** Unspent Edge: the character's `attack_pct` counts 50 % as ward strength and body strength.
- **Why the build needs it:** its offence is zero by the Vow, so every attack bonus on gear would otherwise be wasted.
- **Trade-off:** it makes attack gear a defence source for any build that wears it, which can bring up defence above its offence twin, against Combat rule 18.

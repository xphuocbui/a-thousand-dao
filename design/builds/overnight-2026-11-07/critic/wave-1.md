# Critic: Wave 1

Basis: all 10 sheets read in full, plus index, ledger, health, forge and combat model. The calculator was not re-run: every figure is a sheet's own or read from a file.
**Biggest finding:** all 10 builds were tuned against one enemy shape. `typical` and `top_end` both carry a single art (`c_art` 2.0, cost 0.15, 1 s, no guard), so each spends 15 % of its pool a second and bankrupts itself.

## 1. Tired, do not repeat

- **Bare Vessel is a crutch.** The idea is sound; the use is not. Of the 8 builds, one needs it (Great Tonic, 4.6 s becomes 7.7 s), two gain a little (Taster's Fever, Remnant Host), one gains nothing at one realm up (Receiving Hand), and four report no removal run (Brush Fee, Fortieth Breath, Struck Name, Turned-Away). Full Price tested it and cut it.
- It is not even one piece: four sheets say +30 and four say +80, all calling it reused. The fixture runs dry, so its condition is close to always true, which the forge forbids.
- **The cause:** 59 new modifiers, zero new Conditionals. L5 has few ready sources, so agents grab one. Full Sea is the same crutch in 4 builds, and `health.txt` misses it because no `reused` list names it.
- **Rule from now on:** use Bare Vessel or Full Sea only if the build's own engine strips or holds the pool, and a saved `--without` run changes a result. Otherwise author a new L5 condition.
- **Per is fine; narrow Per is not.** 17 Per is what the forge wants, but 8 of them read three sources: Gate Scar, đan độc and empty slots. Next wave, Per must read a stat no build has used yet.
- **The converging shape is "escape the pool".** Only Struck Name and Great Tonic pay for their damage arts in linh lực in the normal way. The rest use stones, đan độc or health, bill the enemy, fly free, have no arts, or fire once at the end. Rule 11's mana-is-ward tension is the core of the fight, and 8 of 10 walked out of it. Resource swap is closed for a wave.
- **Rejecting the common ward is tired:** 2 switch it off, 2 use per-hit wards, 1 pays in stones. "The ward was the problem" is the surprise in 3 sheets. It stopped being a surprise.
- **"Stand still while the enemy ruins itself" is tired:** Receiving Hand, Fortieth Breath, Incense Vigil, Brush Fee, Great Tonic and Remnant Host all describe it. A build must now do something visible in the first 5 seconds.
- **Empty slots are closed:** Fortieth Breath, Receiving Hand and Remnant Host stack them, and Taster's Fever leaves two empty on purpose.
- **An enabler every time is wrong:** 10 of 10 have one, with 9 new concepts and 53 rule asks. The user said "sometimes".
- **The legend is one story:** an obsolete office or clerk finds a flaw, in 7 of 10 (copyists twice). No more clerks, ledgers, courts or registers.
- **Near copies the merge cannot catch, because it compares names:** Overheat and Whistling Flight are one modifier; Bare Rack and Idle Hands repeat the catalogue's Empty Hand; four L4 coatings differ only by tag (Whetstone Water, Whetstone Ash, Iron-Sand Hand Bath, Sized Paper). Reuse these; do not make a fifth.

## 2. Missing

- **Channels:** 6 of the model's 8 have never been a main damage source: companion, trigger, tick, qi burn, soul and ward drain. Flight is written as arts, so the set is art hits plus one fist. Taster's Fever dropped its tick.
- **Forms:** Conditional and Redirect are unused. Flat base, Conversion and Timing appear once each.
- **Layers:** L4 exists only as renamed coatings. Nothing lives on preparation.
- **Systems:** companions, offensive formations, talismans, heart demon as a main resource, fortune, lifespan as fuel, purity, Đạo count, the element cycle, statuses as an engine, Heavenly Tribulation, quests and the mass-battle rating. No build is built on crit, evade or escape.
- **Moods:** no fury, joy, love, greed or family. Nobody is bonded to anyone, so relatedness is empty. Every build is cold and ascetic.
- **Realms:** all 10 define themselves at Core Formation.
- **Plain builds: none.** 8 strong, 1 top-end, 1 legend. None has zero rule asks; the fewest is 3. Nine beat one realm up, which Combat keeps for top-end (a typical build wins 0 %). Nothing here is what an ordinary player finds and enjoys.
- **Generality is mixed.** "Reused by" is empty for all 59, as expected in a first wave, but many second homes are circular ("any Slow Wound user", "any Surfeit build"). Each build coined a noun, then modifiers reading only that noun. Portable and worth reusing: Bulk Order, Reopened, Rush Order, Final Clause, Still Water, Forgotten Face, Hollow Palm.

## 3. Best so far

1. **Receiving Hand:** one idea, in plain English. A caught art still costs the enemy, and the file models it exactly for the reference enemy. The sheet names what beats it (chaff arts, beasts, soul). Aim for this clarity. Its 5 catches are still sized to the fixture.
2. **Brush Fee:** best surprise. The fee kills its own engine, so the strongest move is paying your enemy (Patronage). Aim for a design the numbers turned around. The boss figures need saved files.
3. **Turned-Away:** the only build that makes a whole life a different game. It gives a stalled life a second path, which matters when the baseline is 3 in 10 per gate, and its price is 60 years. It marks its fight NOT ASSESSED, which is the honesty to copy.

Honourable mentions: Great Tonic, for killing its seed on the numbers and finding "the empty cannot take tonic". Full Price's "every multiplier is a discount" is first-rate, but see below.

## 4. Weakest

- **Incense Vigil.** The fight file deletes the enemy's arts and attacks and runs a fixed tick, so its "stands against everything" proves only a clock. Its key number is fitted: 5 % × (1 − 0.55) × 40 pulses leaves 10 % health. Every matchup, stance and year figure comes from a throwaway patch, which the brief bans from sheets. The player's only decision is one stance flag, Fair Measure appears in no quoted figure, and Combat lists stalling as degenerate. Keep it as an NPC gate guardian unless the user says otherwise.
- **Struck Name.** The enabler barely registers: against a plain ward, bare arts give the identical fight to qi arts. The identity piece is 30 points on what the sheet itself calls a knife edge. The pitch says "the bigger the specialist, the faster they die", yet any top-end kills it at 1 s because stolen L2 "never lands". Nine PASS on that record is too many.

**Sheets claiming more than they proved:**
- **Remnant Host:** 9 PASS with the channel and Spare Mind both stand-ins. It claims top-end power but loses to a same-realm top-end on overkill, and a blind fight leaves that enemy on 46 %. The fight check should be NOT ASSESSED.
- **Fortieth Breath:** fight PASS, but its win one realm up rests on `start_health` 1.55. With no Still Water it dies at 34 s, unless unsaved Final Clause runs apply.
- **Full Price:** fight PASS with the bill worked by hand. "Legend" assumes an 80,000-stone purse, 16 × `linh_thach_max` 5,000, which is the ceiling on a Core event reward. Nothing shows that purse can be reached.
- **All 10 sheets** quote scratch-only numbers. Repairs are under way.
- **The index's "changes the fight" 10 of 10 means little.** Only Fortieth Breath and Struck Name test their named piece. The other 8 pass another id, and any change in end state counts.

## 5. Rule discoveries (for the user; none is a reason to shave a build)

1. **The reference enemy cannot conserve.** Both fixtures dump 15 % a second, so surviving counts as offence, and one realm up looks easy. The sheets' M run far below top-end's 210, so suspect the fixture before the builds. Cheap arts already flip Brush Fee and Receiving Hand.
2. **A broke enemy keeps a ward.** A side that cannot afford its art holds its last pool as ward, so a weaker hit shortened one fight from 5 s to 4 s (Receiving Hand).
3. **The art lint has no ceiling.** Only pool size stops a coefficient: Full Price reaches `c_art` 25 against Formulas C's 1.2 to 12. Rubbings have no lint of their own, and Withheld Hand passes it by design.
4. **`cooldown_min` is a cliff.** Three builds act at t = 0.5, before anyone else. In Remnant Host, 0.007 s of timer moves a top-end from 62 % to 0 %.
5. **Overkill decides double knockouts,** so oversized hits are never wasted, and NPCs cannot choose to avoid the killing blow. Should a planned double knockout be legal?
6. **Top-end toughness is mostly one pool.** Billing it takes a top-end from 69 % to 0 (Brush Fee), and a floor ignores hit size (Turned-Away, rule model). Rules that ignore M beat M 210.
7. **Health-paid arts are nearly free at low health today,** since `body_cost_share` cannot take health below 1 (Turned-Away's reading of Formulas E). This needs no new rule.
8. **Rule 13 may tag the basic attack `art`,** with a timer of one pulse, so On the Beat would always be true for a fist (Receiving Hand's reading). It needs a ruling.
9. **The per-hit ward may beat the drain ward in any long fight.** On the same stats, the drain ward dies at 31 s to an equal enemy and the per-hit pool sits at 93 to 98 % (Fortieth Breath). Is that intended?

## 6. Orders for the next wave

1. **The beast is the fighter (seeds 2, 64):** companion channel, the cultivator as support, a bond with a real cost and warmth, no clerks.
2. **A doctrine for a thousand disciples (seed 61):** no enabler, zero rule asks, mid-power, defined at Foundation Establishment, loses one realm up, with one new Conditional and one Redirect.
3. **The pure soul assassin (seed 4):** soul channel, no layers, bends `soul_lockout`, defined at Nascent Soul or Deity Transformation.
4. **The creditor (seeds 5, 33):** common drain ward on, arts paid in linh lực, every choice about what the pool is for, and wins through ward drain.
5. **The rage of a thousand small cuts (seeds 6, 46):** trigger hits that exist to stack statuses, then a tick Overflow past `dot_pulse_cap`, fury as the mood.

**Standing rules for every build from now on:** implement a rule-bender as a `rules/` plug-in, not a stand-in. Save every quoted number in `variants/`. Set `identity_id` to the real piece or `null`. Judge the build against the mixed enemy (`_tools/mixed-enemy.json`), not only the fixtures, and vary the defining realm.

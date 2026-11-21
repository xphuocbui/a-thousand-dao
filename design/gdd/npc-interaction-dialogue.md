# NPC Interaction & Dialogue

> **Status**: In Design
> **Author**: user + Claude
> **Last Updated**: 2026-11-20 (NPC Relationships #46 designed: rule 11, loans, Dependencies, OQ 2 answered)
> **Last Verified**: 2026-11-15
> **Implements Pillar**: Pillar 5, A World That Remembers; Pillar 2, Every Number Is Bounded and Visible

## Summary

NPC Interaction & Dialogue is how the player deals with people: a Crusader Kings-style menu of verbs (greet, ask for
news, gift, ask for teaching or a loan, trade, spar, threaten, provoke, ask for work, and later the bond verbs). Each
verb shows whether the person will accept, and why, from a score of attitude, presence, realm gap, traits and
standing, with no dice. Replies come from an authored Vietnamese line library by tone and seniority, with the right
forms of address, and famous people have authored scenes. Attitude, flags and records remember what was done; lasting
bonds belong to NPC Relationships (#46).

> **Quick reference** — Layer: `Presentation` · Priority: `Vertical Slice` · Key deps: `World Database, NPC Traits, Character Stats, Event Engine, Time & Turn; soft: Quests, Sects & Missions, Market, Combat, Power Rankings, Travel & Map, NPC Relationships (#46, not designed)`

## Overview

NPC Interaction & Dialogue is how the player deals with a person face to face. It works like Crusader Kings' character
interactions: pick someone at your place and choose a verb: greet them, ask for news, ask about someone, give a gift,
ask for teaching or help, trade, spar, threaten, provoke, ask for work, and later the bond verbs (companion, disciple,
sworn sibling, Dao companion). Each verb shows before you choose whether the person **will accept**, with the score's
breakdown (attitude, presence (mị lực), realm gap, their traits, your sect standing), so a refusal is never a mystery
(Pillar 2). Talk itself takes no time; verbs that are real activity (being taught, a spar, a long favour) take part of
a season. Replies come from an authored Vietnamese **line library** keyed by the verb, the result, the person's
attitude, their tone (from their traits) and seniority, with the right forms of address (tiền bối, đạo hữu, sư huynh…);
famous fixed-cast people have their own lines and **authored scenes**, which are Event Engine events fired when you
greet them. What you do is remembered: attitude to the player, flags the Event Engine reads, and records in the World
Database (Pillar 5). This system owns the verbs and the voice; NPC Relationships (#46) will own lasting bonds between
people, and this system only asks for them. Without it the world's 5,000 people are names in a list; with it they are
people who know you.

## Detailed Design

### Core Rules

Direction decisions (user, 2026-11-15): a CK-style interaction menu plus authored scenes; this GDD owns verbs and
voice, #46 owns bonds; talk is free and deeds take time; a layered line library; acceptance is a score with no dice
(CK3); the first set holds the core social, favour, conflict and bond verbs.

**Who and when**

1. **Anyone present.** The player may interact with any living person (not a beast) at the same place. A beast only
   growls (as built).
2. **Meeting.** The first interaction with a person is a **meeting**: their attitude to the player is set to att0
   (NPC Traits F3), and the person becomes **known**. The known list feeds the Event Engine (its rule 19: known
   people live through NPC events, and their news reaches the player). A meeting is a greeting and costs nothing.
3. **Limits.** A person accepts at most `interactions_per_person_per_season` (2) interactions from the player in one
   season, and each verb has its own cooldown with that person (in the verb's record). An interaction that is refused
   still counts. The limit stops pestering, not exploring: there is no limit across people.
4. **Talk is free; deeds take time.** Verbs marked `time` take that share of a season (Time & Turn): teaching 0.25,
   a spar 0.1, a guide's help the travel it covers. Every other verb takes no time. A pending event blocks verbs that
   take time, as it blocks other time-consuming actions (Event Engine rule 9).

**The verb**

5. **A verb is a data record:** an id, a Vietnamese name, its group (social, favour, conflict, bond), **requirements**
   (Event Engine conditions: realm, sect, attitude band, flags, items held, the person's traits), what the player
   **offers** (spirit stones, an item, nothing), its **acceptance** parts (Formulas A), its **effects** on accept and on
   refusal (Event Engine effect vocabulary, through the Event Engine validator and budgets), its **choice tags** (NPC
   Traits rule 8), its cooldown and time, and its line keys (rule 16). A verb whose requirements fail is not shown,
   except bond verbs, which show their missing requirement greyed so the player learns the path.
6. **Acceptance is a score, not a roll.** Before choosing, each verb shows **will accept** or **won't accept** and the
   score's parts (Formulas A). The person accepts when the score is at least 0. The same state gives the same answer;
   the player changes the answer by changing the state (a gift, a better standing, a higher realm), never by asking
   again. Dice appear only where skill meets skill: a spar is a fight, and a threat is a power check (rule 10, Formulas E).
7. **Acting against your own traits.** A verb whose tags oppose one of the player's own traits costs what NPC Traits F7
   says (heart demon or standing); it is never hidden or greyed out (NPC Traits rule 9). A verb that fits a player
   trait may be added for that player (a Vengeful life gets "demand an apology" from someone holding a grudge flag).

**The first set of verbs**

8. **Social.**
   - **Greet (Hàn huyên).** Always accepted. A meeting the first time; afterwards a small attitude gain that shrinks with
     each greeting in the same year (Formulas B). It may fire the person's authored scene (rule 18).
   - **Ask for news (Hỏi tin).** Accepted by score. The person shares one thing they know that the player does not:
     a recent World Database event in their region or sect, a place they have been to (Travel & Map rule 14: it
     becomes heard of), or a **clue** they hold (Travel & Map rule 16; quality by their realm and calling, false
     clues possible). A person with nothing new says so, and the cooldown is not spent.
   - **Ask about someone (Hỏi về người).** Accepted by score. The person tells what they know of a third person: their
     realm, sect, last place, their personality traits (shown), and their own opinion of them (NPC Traits F3).
   - **Give a gift (Tặng lễ).** Always accepted unless their attitude is hostile. Spirit stones or an item; the attitude
     gain follows Formulas B (value against their realm's wealth, their greed, presence, and a yearly fall-off).
   - **Ask for work (Xin việc).** Hands to Quests: if the person has an offer, Quests' rules decide it (Quests rule 2,
     `offers_per_season`). Talking to a person who is the target of a `visit` stage completes it (Quests).
9. **Favours.**
   - **Ask for teaching (Thỉnh giáo).** Needs a teacher above the player's realm, or at the same realm with a technique
     the player lacks. Takes 0.25 of a season. On accept, the player chooses one lesson the teacher can give: a copy of
     a technique manual the teacher has mastered (only to the teacher's sect-mates if it is a sect technique; Công
     Pháp's own rules for fit), or insight: a cultivation speed bonus for the next season (Formulas C). One lesson per
     teacher per year.
   - **Ask for help (Nhờ giúp).** One of: a loan of spirit stones from their purse (Regional Economy & Trade Formula K;
     repaid within a term, rule 15), a guide (travel to a place they know at their knowledge, Travel & Map), or an
     introduction to their sect (a standing step toward joining, Sects & Missions owns the join).
   - **Trade (Giao dịch).** Barter with the person's own spare goods at Market prices with the presence factor (Character
     Stats H). Attitude changes **what** they show, never the price (Formulas D; user decision 2026-11-15: a price
     factor on top of presence would open a buy-sell loop). Equipped items are never on offer.
10. **Conflict.**
    - **Spar (Luận bàn).** A foreseen, non-lethal fight through Combat (Event Engine rule 17): it ends at the first
      knockout, no one dies, and the loser's vitality loss is `spar_loss_share` (0.5) of normal. Takes 0.1 season. The
      result counts as a rated fight (Power Rankings rule 12). Attitude after it follows the person's traits (a Brave or
      Martial person respects a hard fight either way; a Proud one resents a loss).
    - **Threaten (Uy hiếp).** A power check (Formulas E): on success the person yields what was demanded, up to the
      event budget and their purse (Formula K), their attitude falls hard and they gain a grudge flag; on failure they
      refuse, and by their traits may attack (an Event Engine fight event, ambush) or leave.
    - **Provoke (Khiêu khích).** Opens a real fight event now (Event Engine, foreseen), with death possible and the
      Event Engine's mercy choice after a win. Attitude falls. In a sect's grounds the sect may react (Sects).
11. **Bonds.** Recruit a companion, take a disciple, swear brotherhood (kết nghĩa), seek Dao
    companionship (đạo lữ). Each has its acceptance score and requirements here; on accept, NPC Relationships (#46)
    creates the bond and owns what it does (`npc-relationships.md`: companion, sư đồ, kết nghĩa and đạo lữ records,
    rule 6's notability gate for kết nghĩa and đạo lữ, and each kind's hook, rule 15a). The verb list gains **repay a debt**
    and **declare enmity** (#46 rule 8: +30 enmity both ways), and a fight event gains **call for help** to sworn siblings (#46 rule 15a,
    `p_help`; a sibling who joins is owed a favour, repaid by a call-in event or optionally at `favour_cost`). The repay
    verb lists each open obligation on a pair (debt, favour, loan) as its own entry; repaying a debt of gratitude asks
    the creditor for a deed with no reward (#46 rule 14). Meeting a person writes the player's met list (#46 rule 6),
    and a bond verb that would evict one of the player's ties names it first (#46 rule 15c). Scores and requirements stay here; #46 refuses a second living master or đạo lữ, which the
    verb shows greyed (rule 5).

**Attitude and memory**

12. **One stored number per person: attitude to the player** (−100 to 100, as built). It moves by verbs (Formulas B),
    quests (Quests Formulas E) and events (Event Engine). Positive changes from verbs scale with presence (Formulas B;
    this GDD owns Character Stats' "scale belongs to NPC Interaction"); losses do not. Each year it drifts one point
    toward the person's opinion of the player (NPC Traits F3), so neglected bonds cool and grudges soften slowly.
    Opinions between two NPCs are computed, never stored (NPC Traits rule 16).
13. **Bands.** Attitude bands name what a person will do and how they speak: hostile (≤ −30), cold (−29 to −10),
    neutral (−9 to 9), warm (10 to 29), friendly (30 to 59), close (60 and up). Hostile and friendly use the existing
    thresholds (`session_actions.json`); cold, warm and close are new.
14. **Deeds are remembered.** A notable interaction (a meeting with a fixed-cast person, a gift above
    `notable_gift_share` of their wealth, a lesson, a loan, a spar, a threat, a provocation, a bond) writes a World
    Database record and an Event Engine flag on the person (`gifted_by`, `taught`, `owes_loan`, `threatened_by`,
    `sparred`), so events, quests and #46 can read it.
15. **Loans fall due.** A loan has a term in seasons (`loan_term`); unpaid at the end, the lender's attitude falls and an
    Event Engine follow-up (the lender comes asking) is scheduled. Repaying early raises attitude a little.

**Voice**

16. **The line library.** Every reply is an authored Vietnamese line, chosen by keys: verb × result (accept, refuse,
    nothing new, first meeting) × attitude band × **tone** × **seniority**. A person's tone comes from their personality
    traits (each trait maps to one tone: courteous, blunt, haughty, gentle, sly, pious, wild, cold; the first held
    trait in catalogue order wins). Seniority is senior, peer or junior by realm gap and, within a sect, rank. Lookup
    falls back from the most specific key to the most general: person → (tone, band, seniority) → (tone, band) → (band)
    → the verb's generic line. A text may have several variants, drawn by a keyed draw so a reload shows the same line.
17. **Forms of address.** Lines use placeholders for how the speaker addresses the player and themselves, chosen by
    seniority, sect, attitude and kinship: tiền bối / vãn bối, đạo hữu / tại hạ, sư huynh / sư tỷ / sư đệ / sư muội in
    one sect, sư phụ / đồ nhi between master and disciple, the plain ngươi / ta for the hostile and the haughty. The
    table of forms is data.
18. **Authored scenes.** A person (any fixed-cast person, or anyone carrying a flag an event set) may have authored
    conversation scenes: Event Engine events listed under the `on_talk` hook, with their own conditions. When the player
    greets them and a scene's conditions hold, the scene fires instead of the library line. Scenes are how famous people
    tell their history, set up stories, and react to what the player did.
19. **Lines stand alone.** Lines need no LLM and carry placeholders for names, realm labels, places, sects, the person's
    latest history line and the shared rumour. The parked LLM could later voice the same reply inside the same result;
    it never changes the result.

**What NPCs do**

20. **NPCs do not use the menu.** Interactions between NPCs are not simulated verb by verb: their opinions are computed
    (NPC Traits), their acts come from NPC events (Event Engine rule 19), and their bonds from #46. An NPC may still
    start an interaction with the player through an event (a person seeks you out to repay a loan, to thank you, to
    challenge you).

### States and Transitions

**A person, seen from the player**

| State | Becomes | When |
|---|---|---|
| Unknown | Known | First interaction (a meeting, att0 set), or met inside an event |
| Known | Known | Attitude moves by band as verbs, quests and events change it |
| Known | Remembered dead | The person dies; the known list keeps them, greyed, with their record |

**A verb, for one person in one season**

| State | Becomes | When |
|---|---|---|
| Hidden | Shown | Requirements hold (bond verbs show greyed with the missing requirement) |
| Shown | Will accept / Won't accept | The score is computed (Formulas A); recomputed whenever the state changes |
| Will accept | Done | The player chooses it; effects apply; cooldown and the per-season count start |
| Won't accept | Refused | The player asks anyway; refusal effects apply (if any); the count is spent |
| Done / Refused | Shown | The cooldown ends and the per-season count has room |

**A loan:** taken → repaid (attitude up a little) or overdue (attitude down, follow-up scheduled) → repaid late or
written off (when the lender dies; loans do not pass to heirs, #46 rule 13).

### Interactions with Other Systems

| System | Direction | What flows | Owner of the interface |
|---|---|---|---|
| World Database (#3) | in / out | People, places, events for news; attitude, known list, cooldowns, loans, records | World DB (storage); this GDD (what is stored) |
| NPC Traits | in | att0 and opinion (F3), trait weights for tags, F7 costs, traits shown on asking about someone | NPC Traits |
| Character Stats (#7) | in | Presence (`eff(mi_luc) − 50`), whose attitude scale this GDD owns (Formulas A, B) | Character Stats (the stat); this GDD (the scale) |
| Event Engine (#23) | in / out | Conditions and effect vocabulary, validator and budgets, the `on_talk` hook, flags; fight events for threats and provocations | Event Engine |
| Time & Turn (#4) | out | Season shares for teaching, spars, guides | Time & Turn |
| Quests (#31) | in / out | Ask for work hands to an offer; a conversation completes a `visit` stage | Quests |
| Sects & Missions (#26) | in / out | Rank and standing in scores; introductions; reactions to a provocation in sect grounds | Sects |
| Market | in | Prices and the presence factor for trade | Market (no GDD) |
| Regional Economy & Trade | in | Formula K: loans and yields draw on the person's purse | Regional Economy & Trade |
| Combat (#21), Power Rankings | out / in | Spar as a non-lethal foreseen fight; threat odds from fight odds; spars rated | Combat; Power Rankings |
| Travel & Map (#25) | out | Places heard of, clues shared, guided travel | Travel & Map |
| Công Pháp (#9) | out | Technique manual copies by teaching, under its fit rules | Công Pháp |
| NPC Relationships (#46) | out / in | Out: bond verbs ask for bonds; flags and records feed lasting bonds. In: the player's ties for verbs, address and tone | #46 |
| LLM Game Master (#29), parked | in | Could voice a reply later inside the decided result | — |
| Game UI, Debug Terminal | out | The person card, verbs with accept and breakdown, replies, the known list | Game UI |

## Formulas

Every number marked *guess* waits for play. Presence enters as `pr = eff(mi_luc) − 50`, as Character Stats publishes
it (Formulas H); its scale here is this GDD's.

### A. Acceptance score (rule 6)

The acceptance_score formula is defined as:

`S = b_v + k_att · att + k_pr · pr + g_v · |Δr| + k_tr · log2(M) + k_st · standing + Σ flag_v` · accept when `S ≥ 0`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| b_v | int | news 0; ask about 0; trade +10; guide −5; spar −10; introduction −15; loan −20; teaching −25; companion −40; disciple −45; sworn sibling −50; Dao companion −70 | data file (verb record) *(guess)* | How much the verb asks of the person |
| att | int | −100 – 100 | World Database | Their attitude to the player |
| k_att | float | 1 | data file | Weight of attitude |
| pr | float | −49 and up (presence 1 → −49; 150 → 100) | Character Stats H | Presence above the norm |
| k_pr | float | 0.25 | data file *(guess)* | Presence weight: 70 gives +5, 150 gives +25 |
| Δr | int | −4 – 4 | calculated | Their realm index minus the player's |
| g_v | int | teaching −5; loan, guide, introduction −10; spar −15; bond verbs −10; news, ask about, trade 0 | data file (verb record) *(guess)* | Per realm of gap: seniors bother less with juniors, juniors fear seniors |
| M | float | 0.1 – 5 | NPC Traits F2 (the clamped product of their trait weights for the verb's tags) | How the verb suits their traits |
| k_tr | float | 10 | data file *(guess)* | Trait weight: a suited verb (M = 2) +10, an unsuited one (M = 0.5) −10; bounds −33 to +23 |
| standing | float | −100 – 100 | Sects F10 | The player's standing with their sect (0 for a loose cultivator) |
| k_st | float | 0.2 | data file *(guess)* | Standing weight (att0 already counted standing once at the meeting; this term follows it as it changes) |
| flag_v | int | e.g. `owes_loan` −30 on another loan; `taught` +10 on teaching; `spared_by` +20 on any ask | data file (verb record) | Remembered deeds |

**Output Range:** about −220 to 190; only the sign matters, and the card shows every term. A hostile person (−30 or
below) refuses everything but gifts and spars at best.
**Example:** asking a warm-to-friendly elder (attitude 30) one realm above for teaching, presence 50, neutral traits,
no sect: −25 + 30 + 0 − 5 + 0 + 0 = **0 → will accept**. At attitude 25 the score is −5: one gift (Formulas B) closes the
gap. A Greedy merchant (M = 2 on `greedy`) asked for trade at attitude −10: 10 − 10 + 10 = **10 → will accept**.

### B. Attitude change (rules 8, 12)

The attitude_change formula is defined as:

`Δatt = round_half_up(Δ_v · (1 + k_ch · pr))` for a gain; `Δatt = Δ_v` for a loss · applied as
`att' = clamp(att + Δatt, −100, 100)` (attitude is an integer) ·
greeting `Δ_v = greet_gain · 0.5^n_greet` · gift `Δ_v = gift_gain · (1 − e^(−V / W_r)) · M_greedy · 0.5^n_gift` ·
yearly drift `att' = att + sign(op − att) · min(1, |op − att|)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| Δ_v | float | per verb; at most `attitude_change_max` (10), gifts at most `gift_gain` | data file (verb record) | The verb's base change |
| k_ch | float | 0.01 | data file *(guess)* | Presence scale on gains: presence 1 gives ×0.51, 70 ×1.2, 150 ×2.0 |
| greet_gain | float | 2 | data file *(guess)* | Gain from greeting |
| n_greet, n_gift | int | 0 and up | calculated | Greetings or gifts to this person earlier in the same year |
| gift_gain | float | 15 | data file *(guess)* | Most a single gift can give before presence |
| V | int | ≥ 0 | Item Database base value, or the spirit stones | The gift's value |
| W_r | int | 80 / 600 / 5,000 / 40,000 / 300,000 | registry `event_budget_linh_thach_max` at **their** realm | What counts as a lot to them |
| M_greedy | float | 0.1 – 5 | NPC Traits F2 on tag `greedy` | A greedy person values gifts more |
| op | int | −100 – 100 | NPC Traits F3 | Their computed opinion of the player |

**Output Range:** a gain from 0 to `gift_gain · M · (1 + k_ch · pr)`; attitude always −100 to 100. Repeated gifts in a
year halve each time, so buying a friend takes years, not one purse.
**Example:** 300 spirit stones to a Foundation Establishment (Trúc Cơ) person (W = 600), not greedy, first gift this
year, presence 70: 15 · (1 − e^−0.5) = 5.9, × 1.2 = **+7**. A second, equal gift that year gives 3.54, so **+4**. The same 300
to a Golden Core (Kết Đan) person (W = 5,000) gives 15 · 0.058 · 1.2 = **+1**.

### C. Teaching insight (rule 9)

The teaching_insight formula is defined as:

`bonus = ins_base · (1 + max(0, Δr))` on cultivation speed for the next season

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| ins_base | float | 0.10 | data file *(guess)* | Speed bonus from a same-realm teacher |
| Δr | int | 0 – 4 | calculated | Teacher's realm above the player's |

**Output Range:** +10 % to +50 % for one season. One lesson per teacher per year (rule 9) bounds it.
**Example:** a Nascent Soul (Nguyên Anh) teacher for a Golden Core student: 0.10 · 2 = **+20 %** next season.

### D. Trade by attitude (rule 9)

The trade_offer formula is defined as:

`shown(item) = band(att) ≥ band_needed(item)` · prices are the Market's with the presence factor, unchanged

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| band(att) | enum | hostile … close | rule 13 | Their attitude band |
| band_needed | enum | common spare goods: neutral; their better goods (above the median rarity they hold): friendly; a treasure they keep: close | data file *(guess)* | What it takes to be shown an item |

**Output Range:** a hostile or cold person trades nothing; a close one shows everything not equipped. No price term, so
no buy-sell loop beyond Character Stats' (user decision 2026-11-15).
**Example:** a warm herbalist shows 5 common herbs; at friendly, also her 80-year Blood Ginseng.

### E. Threat check (rule 10)

The threat_check formula is defined as:

`p = clamp(q + k_th · log2(M_cautious), p_min, p_max)` · success on a roll below p (session stream)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| q | float | 0 – 1 | Event Engine rule 17 (fight odds, keyed samples) | The player's win share against them |
| M_cautious | float | 0.1 – 5 | NPC Traits F2 on tag `cautious` | A cautious person yields more easily, a brave one less |
| k_th | float | 0.1 | data file *(guess)* | Trait weight on the threat |
| p_min, p_max | float | 0.05, 0.95 | data file | No threat is ever certain |

**Output Range:** 0.05 – 0.95.
**Example:** win share 0.70 against a cautious person (M = 2): 0.70 + 0.1 = **80 %**. Against a Brave one (M = 0.5):
**60 %**.

### F. Loans (rule 15)

The loan formula is defined as:

`loan_max = min(loan_share · W_r, purse)` · repay `amount` within `loan_term` seasons · overdue `Δatt = −loan_overdue`
then a follow-up

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| loan_share | float | 0.5 | data file *(guess)* | Most a person lends, as a share of their realm's wealth measure |
| purse | int | ≥ 0 | Regional Economy & Trade (holder) | What they actually hold |
| loan_term | int | 8 seasons | data file *(guess)* | Time to repay |
| loan_overdue | int | 30 | data file *(guess)* | Attitude lost when it falls overdue |

**Output Range:** 0 to half their realm's measure; no interest (money is never created, Formula K).
**Example:** a Trúc Cơ lender with 1,000 in purse lends at most min(300, 1,000) = **300**.

## Edge Cases

- **If the person leaves the place, dies or is absent**: verbs are not shown; the known list keeps them.
- **If a person is met inside an event before any interaction**: they become known with att0 then (rule 2), and the
  next greeting is not a meeting.
- **If the score is exactly 0**: they accept (rule 6).
- **If the player asks a verb shown as "won't accept"**: allowed. It is refused, refusal effects apply (asking a
  hostile person for a loan costs attitude), and the per-season count is spent. Asking can never turn a refusal into
  an acceptance.
- **If a gift is worth 0** (a worthless item): Δatt = 0, and the line says the gift was not valued.
- **If the person has no purse for a loan** (balance 0): the loan verb shows "won't accept: nothing to lend" with the
  purse as the failing part.
- **If the lender dies with a loan open**: it is written off; heirs do not claim it, and a dead borrower's loan is cancelled (#46 rule 13).
- **If the player dies with a loan open**: nothing happens to the lender's purse; the record says the debt died with
  the borrower.
- **If ask-for-news has nothing new**: "nothing new" line; the cooldown and the per-season count are not spent.
- **If a clue shared is false** (Travel & Map rule 16): it is recorded as heard from this person; when the player
  learns it was false, the person's attitude does not change (they believed it), unless they knew (a Deceitful person
  may knowingly pass a false clue: an event flag records it).
- **If two scenes fit on greeting**: the Event Engine's pick rule chooses one by weight (Event Engine rule 7); the
  other waits for a later greeting.
- **If a scene fires on greeting**: the greeting's own attitude gain still applies, once.
- **If a spar's foe has a mortal wound at the end**: in a spar there is no mortal wound: the fight ends at the first
  knockout and both live (rule 10).
- **If a threat succeeds against a person stronger than the player** (q low, but the roll hits): they yield; the
  grudge flag lets their later NPC events strike back.
- **If presence is extreme** (1 or 150): the score term is −12 or +25 and the gain factor ×0.51 or ×2.0; both stay
  inside the bounds above.
- **If the player is in disguise or unknown to a sect** (stealth, false identity): out of scope; Open Questions.
- **Degenerate: gift-farming attitude.** Gifts halve each time within a year and scale with the person's realm wealth,
  so maxing a person takes years or a large share of a fortune; attitude also drifts back toward opinion yearly.
- **Degenerate: spar-farming a weak person for rating.** Spars are rated fights: beating a much weaker person moves
  the rating little (Power Rankings), and each spar costs 0.1 season and the person's cooldown.
- **Degenerate: borrow and never repay.** The lender's attitude falls by `loan_overdue`, the follow-up event comes
  asking, and `owes_loan` blocks further loans from anyone who knows the lender (a flag read by their verbs).

## Dependencies

**Upstream**

| System | Hard / Soft | Interface | Has GDD |
|---|---|---|---|
| World Database (#3) | Hard | People, events, places; stores attitude, known list, cooldowns, loans | No (built) |
| NPC Traits | Hard | att0 and opinion (F3), F2 weights for the score, F7 costs | Yes |
| Character Stats (#7) | Hard | Presence `eff(mi_luc) − 50` | Yes |
| Event Engine (#23) | Hard | Conditions, effects, validator, budgets, flags, the `on_talk` hook, fight events | Yes |
| Time & Turn (#4) | Hard | Season shares for time-taking verbs | No (built) |
| Sects & Missions (#26) | Soft | Rank, standing (F10), joining by introduction | Yes |
| Quests (#31) | Soft | Offers and `visit` stages | Yes |
| Market | Soft | Prices and the presence factor | No (built) |
| Regional Economy & Trade | Soft | Purses as holders (Formula K) for loans and yields | Yes |
| Combat (#21), Power Rankings | Soft | Spars, fight odds for threats | Yes |
| Travel & Map (#25) | Soft | Place knowledge, clues | Yes |
| Công Pháp (#9) | Soft | Manual copies and fit for teaching | Yes |

**Downstream**

| System | Hard / Soft | Interface |
|---|---|---|
| NPC Relationships (#46) | Hard (for bond verbs) | Bond requests, flags and records |
| Quests (#31) | Soft | Conversation completes `visit` |
| Event Engine (#23) | Soft | Known list (its rule 19), `on_talk` scenes, flags from deeds |
| Game UI | Hard | The person card and known list |

**Bidirectional check.** NPC Traits and Quests already list #30. **Event Engine** gets `on_talk` in its rule 6 hook list
(edited with this GDD). **Character Stats** names "NPC Interaction" as owner of the presence scale (row 363 and Formulas
H), which this GDD now fills. Sects, Regional Economy & Trade, Combat, Power Rankings, Travel & Map, Công Pháp and the
World Database do not name #30; their rows are small and listed in Open Questions rather than edited now.

## Visual/Audio Requirements

`art-director` not consulted (Lean mode; no art bible yet). Review before production.

- **The person card:** a portrait (fixed cast authored; others by archetype, realm and sect colours), name, realm,
  sect and rank, attitude band as a word and a colour, and the traits the player knows.
- **Tone is in the words, not effects:** no animation per line. An authored scene uses the Event Engine card.
- **Audio:** a soft cue on a meeting, a warm one on a gift accepted, a cold one on a refusal; a spar uses Combat's audio.

## Game Feel

- **No surprise refusals.** "Will accept / won't accept" is on every verb before choosing, with the reasons; the player
  works toward a yes.
- **People sound like themselves.** A haughty elder and a gentle herbalist answer the same question differently, and
  address the player by the right form (tiền bối, đạo hữu, sư muội).
- **Free to talk, costly to ask.** Greeting and news cost nothing, so exploring the cast is encouraged; teaching and
  loans spend time, favour and future goodwill.
- **Remembered.** A lender comes asking; a spared rival greets you differently; a famous person's scene changes after
  what you did.

## UI Requirements

- **The person card** (above), with the verb list grouped (social, favour, conflict, bond): each verb with will / won't
  accept, the score breakdown on hover or tap, costs and time, and bond verbs greyed with the missing requirement.
- **The reply** under the card: the line, then any effect lines (attitude change with its presence factor, items, the
  clue shared).
- **The known list:** everyone met, with attitude band, last place seen, open loans and flags the player knows of.
- **Trade view:** their goods by band (locked goods show the band needed).
- **Debug terminal:** the same as text, plus the line key chosen and its fallback level.

> **📌 UX Flag — NPC Interaction & Dialogue**: this system has UI requirements. In Pre-Production, run `/ux-design` for
> the person card, the known list and the trade view before writing epics.

## Cross-References

| This document references | Target GDD | Element | Nature |
|---|---|---|---|
| Rules 2, 12; Formulas A, B | npc-traits.md | F2, F3, F7, rules 8, 9, 16 | Formula dependency |
| Formulas A, B | character-stats.md | Formulas H (presence; scale owned here) | Ownership handoff |
| Rules 5, 18, 20 | event-engine.md | Rules 4, 6 (`on_talk`), 7, 13, 17, 19, 21 | Rule dependency |
| Formulas B, F | design/registry `event_budget_linh_thach_max` | W_r | Data dependency |
| Rule 8 | quests.md | Rule 2, `offers_per_season`, `visit` stage | Ownership handoff |
| Formulas A | sects.md | F10 standing; rank ladder rule 19 | Data dependency |
| Rule 9, Formulas F | regional-economy-trade.md | Formula K | Rule dependency |
| Rule 10, Formulas E | combat.md, power-rankings.md | Rules 12, 14; rule 12 | Rule dependency |
| Rule 8 | travel-map.md | Rules 14, 16 | Data dependency |
| Rule 9 | cong-phap.md | Manuals and fit | Rule dependency |

## Acceptance Criteria

Test types: [Logic] unit test; [Integration] cross-system test; [Config/Data] data-load check; [UI] retained
screenshot; [Playtest].

- **AC-NI-01** [Logic] Rules 1, 2. **GIVEN** an unknown person at the player's place, **WHEN** the player greets them,
  **THEN** their attitude equals att0 (NPC Traits F3) and they are on the known list; a beast refuses with the growl line.
- **AC-NI-02** [Logic] Rule 3. **GIVEN** 2 interactions with a person this season, **WHEN** a third is tried, **THEN** it
  is refused before the score, with the limit named; a different person accepts.
- **AC-NI-03** [Logic] Rule 4. **GIVEN** teaching accepted, **THEN** 0.25 season passes; a greeting passes none.
- **AC-NI-04** [Config/Data] Rule 5. **GIVEN** a verb record with an unknown condition or effect, **WHEN** data loads,
  **THEN** loading fails naming the verb (Event Engine rule 4).
- **AC-NI-05** [Logic] Rule 6, Formulas A. **GIVEN** teaching, attitude 30, presence 50, Δr 1, neutral traits, no sect,
  **THEN** S = 0 and the card shows "will accept"; at attitude 25, S = −5 and "won't accept". The same state asked twice
  gives the same answer.
- **AC-NI-06** [Logic] Formulas A bounds. **GIVEN** M = 0.1 and M = 5, **THEN** the trait term is −33 and +23.
- **AC-NI-07** [Logic] Rule 7. **GIVEN** a Merciful player choosing Threaten, **THEN** the F7 cost applies and the verb
  was shown, not greyed.
- **AC-NI-08** [Integration] Rule 8, Travel & Map. **GIVEN** a person who knows a place the player has not heard of,
  **WHEN** news is accepted, **THEN** the place becomes heard of for the player; asked again with nothing new, the
  "nothing new" line shows and no count is spent.
- **AC-NI-09** [Logic] Formulas B. **GIVEN** 300 stones to a Trúc Cơ person, presence 70, first gift this year, **THEN**
  +7; a second equal gift the same year gives +4 (3.54 rounded); the same 300 to a Kết Đan
  person gives +1.
- **AC-NI-10** [Logic] Formulas B. **GIVEN** a loss of 10 at presence 150, **THEN** attitude falls by exactly 10.
- **AC-NI-11** [Logic] Formulas B drift. **GIVEN** attitude 40 and opinion 10, **WHEN** a year passes, **THEN** attitude
  is 39.
- **AC-NI-12** [Integration] Rule 8, Quests. **GIVEN** a `visit` stage naming a person, **WHEN** the player greets them,
  **THEN** the stage completes.
- **AC-NI-13** [Logic] Rule 9, Formulas C. **GIVEN** a Nguyên Anh teacher and a Kết Đan student, **THEN** insight gives
  +20 % cultivation speed next season; a second lesson from the same teacher within the year is refused.
- **AC-NI-14** [Logic] Rule 9. **GIVEN** a teacher's sect technique and a student from another sect, **THEN** that manual
  is not offered as a lesson.
- **AC-NI-15** [Integration] Formulas F, Regional Economy. **GIVEN** a Trúc Cơ lender with 1,000, **THEN** the loan is at
  most 300, drawn from their purse (no money created); unpaid after 8 seasons, attitude falls 30 and a follow-up event
  is scheduled.
- **AC-NI-16** [Logic] Formulas D. **GIVEN** a warm person with common and better goods, **THEN** only common goods are
  shown; at friendly the better ones too; prices equal the Market's with presence.
- **AC-NI-17** [Integration] Rule 10, Combat. **GIVEN** an accepted spar, **THEN** the fight is foreseen, ends at the
  first knockout, no one dies, the loser's vitality loss is half the normal amount, 0.1 season passes and the result is
  rated.
- **AC-NI-18** [Logic] Formulas E. **GIVEN** win share 0.70 and M_cautious 2, **THEN** p = 0.80; with q = 1 and M = 5,
  **THEN** p = 0.95.
- **AC-NI-19** [Integration] Rule 10. **GIVEN** a provocation, **THEN** an Event Engine fight event opens at once with
  foreseen situation and the mercy choice after a win.
- **AC-NI-20** [Logic] Rule 11. **GIVEN** #46 not built, **THEN** bond verbs are absent from shipped data (provisional).
- **AC-NI-21** [Logic] Rule 13. **GIVEN** attitudes −30, −10, 0, 10, 30, 60, **THEN** the bands are hostile, cold,
  neutral, warm, friendly, close.
- **AC-NI-22** [Logic] Rule 14. **GIVEN** a lesson, **THEN** the person carries flag `taught` and a World Database record
  exists.
- **AC-NI-23** [Logic] Rule 16. **GIVEN** a person with no own line, a Haughty tone, band friendly, senior, **WHEN** the
  library has only (band) and generic lines for the verb, **THEN** the (band) line is used; a reload shows the same
  variant.
- **AC-NI-24** [Logic] Rule 17. **GIVEN** a sect-mate one rank above the player, **THEN** the line addresses the player
  as sư đệ or sư muội and the speaker as sư huynh or sư tỷ.
- **AC-NI-25** [Integration] Rule 18, Event Engine. **GIVEN** a fixed-cast person with an `on_talk` scene whose
  conditions hold, **WHEN** greeted, **THEN** the scene fires instead of the library line, and the greeting gain
  applies once.
- **AC-NI-26** [Config/Data] Rule 19. **GIVEN** the shipped line library, **THEN** every verb has a generic line for
  every result, and no reply needs an LLM.
- **AC-NI-27** [UI] UI Requirements. **GIVEN** a person card with every verb group, **THEN** a retained screenshot shows
  will / won't accept with breakdown, costs, time, and a greyed bond verb with its missing requirement.
- **AC-NI-28** [Playtest] Game Feel. Do players say people "sound different" and that refusals made sense? Is the
  gift fall-off felt as fair?

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Bond verbs (companion, disciple, sworn sibling, Dao companion): their effects and NPC-to-NPC bonds | NPC Relationships (#46) | #46 GDD |
| 2 | ~~Heirs and debts~~ **Answered 2026-11-20 by #46 rule 13:** loans are not ties; neither a dead lender's nor a dead borrower's loan passes to heirs. Debts of gratitude (ân tình) owed to the dead do pass to the heirs at half strength | #46 | — |
| 3 | Disguise and false identity (stealth): can the player hide who they are from a person or sect? | user | Later |
| 4 | Line library size: how many lines per verb, tones and bands before the first playable (the audit guessed 300–600)? | user + writer | Before content authoring |
| 5 | Small Dependencies rows naming #30 in Sects, Regional Economy & Trade, Combat, Power Rankings, Travel & Map, Công Pháp | — | Next consistency pass |
| 6 | All numbers marked *guess* (b_v, g_v, k_pr, k_tr, k_st, k_ch, gift_gain, greet_gain, ins_base, loan terms, k_th) | Balance Harness / playtest | First playable |
| 7 | Can NPCs ask the player things through the menu (a request card), or only through events (rule 20)? | user | Before content authoring |

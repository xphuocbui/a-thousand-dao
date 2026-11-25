# NPC Traits (Tính Cách)

> **Status**: In Design (started 2026-11-14 from the seed written for the Sects GDD)
> **Author**: user + Claude
> **Last Updated**: 2026-11-20 (rule 16 and F3 `tie` amended by NPC Relationships #46; Dependencies rows; OQ 8)
> **Last Verified**: 2026-11-14
> **Amended 2026-11-25** (user rulings, world-depth pass: `design/world/depth/DECISIONS-2026-11-25.md` groups 1, 5 and 11; proposal `design/world/depth/rules-proposals.md` R6, `traits-v2.md`, `traits-v2.json`): **traits v2, deeper and CK3-like.** Six new kinds (upbringing, talent tiers, path, lifestyle, health, coping; rule 2a), talent tiers replace the plain v1 fate gifts, personality rows doubled (F1), traits `open` hooks (rule 8a; dialogue verbs first) and carry likes and dislikes (rule 16a, F3), talent tiers inherit with drift (F5b), and no trait effect reads the environment (rule 7a). Group 11 accepted the seven open trait details (Open Questions 9, 10, 11, 13, 17, 19, 20). **Group 12** (2026-11-25): 15 behaviour-shaping v2 traits get choice-tag weights (rule 8), tier A's band widens to 6–12 with over-band people trimmed at export (rule 2a), Hunter and One-element devotee get scoped `attack_pct` rows (rule 7), and talent grades show the effective grade beside the base (F1b; Open Questions 12, 14, 16, 18, 22).
> **Implements Pillar**: A fixed world with a written history; Living world tick; Power is built, not given

## Summary

NPC Traits gives every person, NPCs and the player alike, a small set of traits in four kinds: 3 personality traits from
18 opposed sets, 1 calling, up to 2 fate-given (bẩm sinh) and up to 2 gained from events, which fade. Each trait trades a
small stat boon for a cost through the Modifier System, and carries pulls: weights on people's choices, on how they regard
each other (computed, never stored per pair), and on how a sect they lead behaves. It makes the world's 5,000 cultivators
act like people, and gives the player a character whose nature colours choices without ever blocking one.
**Amended 2026-11-25 (traits v2):** six more kinds join them (an upbringing, 0-2 graded talent tiers, 0-2 cultivation
paths, a lifestyle, a health trait and a coping trait), so a notable person carries 6-12 traits and an ordinary one
5-6; the new traits carry bigger rows, open event options, dialogue verbs, sect policy leans, duel stances and craft
edges, and like or dislike other traits.

> **Quick reference** — Layer: `Feature` · Priority: `Alpha (provisional)` · Key deps: `Modifier System, Character Stats, NPC Builds, World Database, Time & Turn; read by Sects, Living World Tick, Event Engine, NPC Interaction & Dialogue, LLM Game Master, Quests`

## Overview

Every person in the world, NPC or player, carries a small set of **traits** (tính cách) in four kinds: **personality**
(3, in opposed sets), a **calling** (1, the lifestyle), **fate-given** traits (0–2, born with) and **gained** traits (from
events, added and lost in play). A trait does two things and nothing more. It gives plain **stat modifiers** through the
Modifier System, and it gives **pulls**: weights on what a person chooses, how they regard others, and how a sect they lead
behaves (Sects F15). Traits are why two cultivators of the same realm and build act differently when a rival insults
them, a friend asks for help or a sect is at war, and they are how the world feels lived-in rather than rolled. For the
player they are a source of build identity and of choices that open or close (a Vengeful life reads a feud differently
from a Forgiving one), never a restriction on the player's own choices. The engine owns every trait record and number;
the LLM game master only reads traits to voice people. **Amended 2026-11-25:** six more kinds (upbringing, talent, path,
lifestyle, health, coping; rule 2a) make people read as more than "three adjectives and a job" (`traits-v2.md`), and a
third thing a trait may do is **open** a hook (rule 8a) that another system turns into an option, a verb or a lean.

## Detailed Design

### Core Rules

**What a trait is**

1. **A trait is catalogue data with three parts:** an id, a kind and (for personality) an opposed set; **stat rows**, which
   are plain modifiers on Modifier System stats; and **pulls**, which are weights read by other systems. It has a
   Hán-Việt name with an English gloss, a short description the LLM may read, and the conditions that grant or remove it.
   A trait has no rule of its own: anything that needs a rule is an Effect (Modifier vs Effect).
   **Amended 2026-11-25:** a v2 trait (rule 2a) has three more parts, all data: **opens** (hook ids, rule 8a), **likes**
   and **dislikes** (trait ids or v1 names, rule 16a). A talent trait also has **tiers** 1-3, each with its own rows
   (Formulas F1b). Neither part is a rule of its own: a hook is a key another system reads, and likes feed F3.
2. **Four kinds** (user decision 2026-11-14; **ten since 2026-11-25**, rule 2a):
   - **Personality** (tính tình): **3** per person, never both sides of an opposed set. Fixed for life, with one narrow
     exception (rule 15).
   - **Calling** (nghề nghiệp): **1** per person, the person's lifestyle (strategist, steward, alchemist, swordsman...). It
     follows the person's chosen path and may change when the path does (rule 14).
   - **Fate-given** (bẩm sinh; not *thiên định*, which is Character Stats' Fated birth mode): **0–2** per person, born with (heaven-favoured, ill-starred...). Rare, never lost. Fate-given traits come in opposed pairs too (Heaven-favoured / Ill-starred), and a person never holds both sides: the second draw (F4) removes the first trait and its opposite from the pool, as for personality.
     **Amended 2026-11-25** (user ruling, group 5: "talent tiers replace the plain gifts"): only the fates that are
     stories stay, **Spirit-eyed / Hollow-souled** and **Pure-hearted / Demon-seeded** (4 traits, 2 pairs). The six
     plain gifts and flaws are **retired** and map to talent tiers (rule 2a; table in Trait list): no roll draws them,
     and a save or authored record that holds one loads it as its talent tier.
   - **Gained** (hậu thiên): **0–2** per person, from events (scarred, embittered, humbled, renowned...). Added and lost in
     play (rules 11–13).
2a. **Six more kinds (new, 2026-11-25;** user ruling, group 1 R6: "all three parts: more kinds, bigger rows, opens +
    likes/dislikes"). The catalogue is `npc-traits-catalogue.md` § Traits v2 (80 traits). Per person:

    | Kind | Per person | Enters | Leaves |
    |---|---|---|---|
    | **Upbringing** (xuất thân) | **exactly 1** | At creation, from the birthplace and family (F4b); the player's from the origin, or picked in a Self-made birth | Never |
    | **Talent** (thiên phú bẩm sinh) | **0–2**; an authored tier-A person **1–3** (the cap of 3 is hard; the minimum of 1 is an authoring lint) | At birth: rolled (F4b) or inherited with drift (F5b); fixed lists for authored people; picked in a Self-made birth | Never. Events change the talent's base value (Character Stats rule 4), never the tier |
    | **Path** (tu hành) | **0–2** | An event outcome, a technique or a deed (a heart demon slain, a deviation survived, a tribulation crossed, years of pills); at creation by F4b | Only by a deed (a mending removes Cracked foundation), or replaced by its opposite (rule 13's grade test does not apply: paths have no grade) |
    | **Lifestyle** (thú vui; a pastime, not the calling, which is the person's work) | **0–1** | At creation by F4b, or an event offer | Replaced by a new offer (as a calling, rule 14) or removed by a deed |
    | **Health** (thương bệnh) | **0–1** at creation; an event may add a second (**at most 2**; `traits-v2.json`: "0-1 (rarely 2)") | An event outcome (a wound, a deviation, a poison); Waning years by age (Formulas F6b) | Only by a deed (a cure); Waning years when the lifespan is extended past its line |
    | **Coping** (ứng phó) | **0–1** | An event outcome under stress (grief, failure, heart demon), with a trigger id like a gained trait | Fades after `coping_fade_seasons` unless its trigger repeats; **hardens** (stops fading) after `coping_harden_refreshes` repeats (F6b); removed by a deed |

    - **Talent tiers.** A talent trait is a **family** (a gift or a flaw on one of the six talents) held at tier 1, 2
      or 3. A tier adds +6 / +12 / +20 (gift) or −6 / −12 / −20 (flaw) flat to the talent's effective value
      (Character Stats rule 5), and at tiers 2–3 most families add a stat row (F1b). Like CK3's congenital tiers, they
      are the hand a person is dealt, so they are sized against the talent roll (σ 16), not the W grades.
    - **Opposed v2 traits.** A talent gift and the flaw on the same talent (`quick_minded` / `slow_witted`, and so on)
      are opposed, and so are a talent family and the kept fate on the same talent in the other direction
      (`keen_soul` / Hollow-souled, `thin_soul` / Spirit-eyed, `steady_heart` / Demon-seeded, `restless_heart` /
      Pure-hearted). Three path pairs are opposed: `perfect_foundation` / `flawed_foundation`, `demonic_path` /
      `buddhist_path`, `frost_veined` / `fire_tempered`. A person never holds both sides; a grant of one side replaces
      the other. Same-direction stacking is allowed (Spirit-eyed with `keen_soul`: 8 authored people hold both).
    - **How many in all.** A notable person (authored tier A) carries **6–12 traits** (amended 2026-11-25, ruling
      group 12; was 6–10), a tier B person **5–8**, an ordinary one **4–6** (`traits-v2.md`). The fixed kinds
      (3 + 1 + 1) make 5 the floor, so an ordinary rolled person holds 5–6 at creation (F4b). These totals are **roll
      targets**; the per-kind caps above are hard. Gained traits come on top in play.
    - **Trimmed at export (new, 2026-11-25;** ruling group 12: "people above 12, and tier B/C over-band people, are
      trimmed at export (drop the weakest-fitting extras)"). The world export (World Generation's `export_world.py`)
      cuts an authored person above their band's top (tier A 12, B 8, C 6) down to it, one trait at a time. **Never
      dropped:** the 3 personality traits, the calling, the upbringing, and a tier A person's last talent. **Weakest
      fitting first** (this GDD's reading of the ruling, a guess; Open Question 23): (1) a trait the person's
      backstory does not name (by id, English or Vietnamese name) goes before one it names; (2) then by kind, in the
      order gained, coping, lifestyle, fate-given, path, talent (its lowest tier first), health, from the most passing
      to the most lasting; (3) then by id. Each drop is written to the export report (person, trait, reason). The depth
      pages keep what was authored; only the exported record is trimmed. A person under the band floor, or a tier A
      person with no talent, stays an authoring-lint line (advisory). Measured 2026-11-25 (`depth_check.py`
      observation line): 4 tier A (13 each), 20 tier B and 6 tier C people are over band, 36 traits to drop.
3. **A person's traits** are a short list of trait ids on the person record in the World Database, plus, for each gained
   trait, the season it expires and, for a **targeted** gained trait (Lovestruck, a grudge), one person id as its target
   (user decision 2026-11-14). The **player** record also holds one int, `heart_demon_used` (F7's season counter, reset
   each season, saved so a mid-season save keeps the cap). At most 8 ids per person (3 + 1 + 2 + 2). Everything else, the
   modifiers and the pulls, is derived from the catalogue when read.
   **Amended 2026-11-25:** with the v2 kinds (rule 2a) a person holds at most **18 ids**: 3 personality, 1 calling,
   1 upbringing, 3 talent (2 for anyone but an authored tier-A person), 2 path, 1 lifestyle, 2 health, 1 coping,
   2 fate-given and 2 gained. Stored per person beside the ids: **one tier int per talent trait**
   (≤ 3), the coping trait's expiry season and refresh count (≤ 1 each), and the gained traits' expiries and targets
   (≤ 2 each). Nothing else is stored: rows, opens and likes are derived from the catalogue when read.
4. **Both NPCs and the player have traits** (user decision 2026-11-14). The record and the rules are the same.

**What traits change: stats**

5. **Every trait carries stat rows** (user decision 2026-11-14: all kinds carry stats). Each row is a catalogue modifier
   (Modifier System rule 1) with the person's trait as its source, so it lasts exactly as long as the trait (Modifier
   rule 2). Traits use only the **flat** and **increased** operations, never `more` (L2/L4 is budgeted by other sources),
   and never a stat that the Modifier System marks rare or Pending.
6. **Every trait has a boon and a cost.** A personality or calling trait has one boon row and one cost row, each at the
   **small** grade (about 1.2 W), on stats that fit the trait (Brave: +maximum health `khi_huyet_pct`, −evade
   `evade_pct`). The opposed trait swaps the flavour and the trade, not the power, so no personality is
   simply better than its opposite. A fate-given or gained trait may be one-sided at the **notable** grade (about 8 W):
   heaven-favoured is a boon with a visible price elsewhere in play (rule 9). W grades are a sizing guide only: **no price
   check runs until the game is finished** (user decision, effects hand-designed and unpriced).
   **Amended 2026-11-25** (user ruling, group 5: "v1 personality rows: doubled"): a **personality** row is sized at
   twice the small grade (F1, `P_t` 2.0, about 2.4 W), so Brave is +4.0 % health / −1.6 pp evade. Callings, fate-given
   and gained traits keep their grades. **v2 traits** (rule 2a) are not bound by the boon-and-cost pattern: an
   upbringing, path, lifestyle or gift tier may be one-sided, and a health trait or flaw tier is a plain cost. Their
   rows are **hand-set** in the catalogue and sized by kind (Formulas F1b), not computed by F1.
7. **Stat rows target the stats the trait is about.** Talent rows (`ngo_tinh`, `khi_van`, `dao_tam`, `than_hon`,
   `can_cot`) appear only at the notable grade, on fate-given or gained traits; presence (`mi_luc`) may appear at small
   (user decision 2026-11-14: a small talent row would be invisible). Personality and calling rows use tâm ma and
   status resistance, cultivation speed, mission income, stealth, escape, evade, healing and healing taken, health,
   alchemy and refining success, travel speed, and (catalogue, user decision 2026-11-14) qi deviation chance, formation
   power, thần thức, companion health and herb growth. Not the damage layers: traits never touch `attack_pct`, crit or the combat
   offence rows, so personality cannot decide a fight on its own (builds are the game).
   **Amended 2026-11-25:** the paragraph above binds the **v1 kinds** (personality, calling, fate-given, gained). The
   **v2 kinds** may use any Live or Designed Stat List key, the talent keys and the combat rows included
   (`attack_pct` with or without a tag scope, `crit_chance_pct`, `art_speed_pct`, `accuracy_pct`, `defense_pct`,
   `leech_health_pct`, `soul_res_pct`, `linh_luc_pct` and the rest the catalogue lists), still only F and I, never
   `more`, never a Pending or rare key (rule 5). Why: R6 asks for "bigger effects", and a path trait "sized at about a
   third of a Profound technique's passive budget, enough that a Sword-heart is visible on the fight sheet"
   (`traits-v2.md`). A path is earned by cultivating, so it is part of the build, not a personality deciding a fight.
   **Two scoped rows (new, 2026-11-25;** ruling group 12, Open Questions 12 and 22):
   - **Hunter** is `attack_pct` +2 scoped to the **foe** tag `creature` (was the form tag `beast`). The foe tag is
     Pending in the Modifier System (Combat stamps foe tags on profiles only when content needs them), so this one
     row is an allowed exception to "never a Pending key": it loads, and it adds nothing until a foe carries
     `creature`, since a scope that matches nothing adds nothing.
   - **One-element devotee** is `attack_pct` +6 scoped to **`own_top_element`** (was `element_affinity_pct` +6, which
     targets artifacts). `own_top_element` is a placeholder scope **resolved at compile** to one base element tag:
     the holder's base element (Kim, Mộc, Thủy, Hỏa, Thổ) with the highest root purity, ties broken in that order. It
     is re-resolved whenever the row set is summed (at creation and on any root change), never per fight. A root with
     no base element (a pure Wind root) resolves to nothing, and the row adds nothing. The +6 is a guess, the size of
     Sword heart's scoped row. Rule 7a holds: the scope reads the holder's own root, not the environment.
7a. **No environment conditions (new, 2026-11-25;** user ruling, group 1: "this is stupid, remove conditions like
    this", and group 6 for time and season). No trait row, tier or `opens` hook depends on ground, terrain, biome,
    weather, place, time of day or season. (It binds a trait's **effects**; where a person is born may still lean
    which upbringing they roll, F4b's `m_birth`, as their root follows their land.) A row has exactly three fields, stat, value and an optional tag scope, and
    no scope names an environment. A trait's meaning may mention such things as flavour (Old wound "aches before
    rain", Lingering poison "flares in the cold months", Array-bound "strong inside it"): the rows are the same
    everywhere and always.

**What traits change: choices and regard (pulls)**

8. **Pulls come in three groups.**
   - **Sect pulls:** the 16 kinds of Sects F15 (dial deltas, war odds, weariness, pact line and so on). A sect reads the
     sum over its leader's traits.
   - **Choice weights:** every event choice carries **choice tags** (aggressive, merciful, greedy, deceitful, loyal,
     cautious, vengeful, devout, social...). A person's weight for a choice is the choice's base weight times the product of
     the trait weights for its tags. The Event Engine and the Living World Tick read this to pick an NPC's choice.
   - **Regard pulls:** how the trait colours the opinion others hold of this person and this person holds of others
     (rule 16).
   **Amended 2026-11-25:** ~~v2 traits carry **no choice-tag weights** (1.0 on every tag), so they never change F2 or
   count in F7;~~ **amended again 2026-11-25** (ruling group 12: "behaviour-shaping v2 traits get choice-tag weights
   (paths such as Demonic and Buddha's path, coping traits, Duel-seeker, Gambler...); talents and health stay
   stat-only"; Open Question 18): **15 v2 traits carry choice-tag weights**, in the interim vocabulary below and on the
   callings' scale (1.5 affinity, 0.67 aversion, at most three tags; 2.0 and 0.5 stay a personality trait's core):
   4 paths (Demonic path, Buddha's path, Sword heart, Dual cultivator), 3 lifestyles (Duel-seeker, Gambler, Drinker),
   6 coping traits (Vow of vengeance, Rage flares, Hides in seclusion, Cold detachment, Found faith, Hoarding) and
   2 upbringings (Street orphan, War orphan). The weights are in the catalogue's § Choice-tag weights of v2 traits
   and in `traits-v2.json` (`tags`), and are guesses. They count in F2 and F7 exactly as v1 weights do. Every other
   v2 trait, all talents and health traits included, stays 1.0 on every tag. A v2 trait's sect pulls are still only
   its `policy:` hooks (rule 8a), and its regard is its likes and dislikes (rule 16a).
8a. **Opens (new, 2026-11-25;** R6 part 3). A v2 trait's `opens` is a list of hook ids `kind:id`, five kinds:

    | Kind | What it opens | Consumer that turns it into play | Who must hold the trait |
    |---|---|---|---|
    | `event:` | an event option or an event kind (`event:insight_flash`) | Event Engine (#23): an option's show condition or an event's weight | the person the event is about |
    | `verb:` | a dialogue verb (`verb:share_tea`) | NPC Interaction & Dialogue (#30) | the player, the person the player faces, or either, by the verb's **side** (catalogue § Verb hooks) |
    | `policy:` | a sect policy lean (`policy:trade`) | Sects (#26) F15, as a sect pull | the sect's leader |
    | `stance:` | a duel stance (`stance:sword_intent`) | Combat duels (`design/world/depth/builds/duel-readings.md`) | the fighter |
    | `craft:` | a craft edge (`craft:alchemy`) | the craft's system (Alchemy, Formations, refining, Spirit Herbs, beasts, talismans) | the crafter |

    - A person's **opened set** is the union of the hooks of every trait they hold (computed when read, never stored).
    - A hook only **adds**: an option, a verb, a lean. It never removes, greys out or hides anything (rule 9).
    - A hook is a **key, not an Effect.** What a verb does, what an option costs, what a stance changes is the consumer's
      rule, written in the consumer's GDD. A hook whose consumer has no record for its id does nothing and is listed by
      the catalogue lint (an observation, not a failure), which is the honest limit of this pass: "the data makes
      people deeper, and the unbuilt chain and verb layers make the depth visible" (`traits-v2.md`).
    - **Dialogue verbs (#30) are the first consumer to build** (user ruling, group 5), because the player meets traits
      there first. The 19 verb hooks and their sides are in the catalogue.
9. **For the player, pulls never restrict choices.** Choice weights are shown as a hint and a cost modifier: a trait
   may add an extra option that fits it (a Vengeful life may take revenge in a feud scene), may make a fitting option
   cheaper, and may make an unfitting one cost heart-demon or standing (tâm ma, standing). It never greys an option out.
   A fate-given boon is paid for by the world: heaven-favoured raises the fortune rows and the chance of fortunate
   events, and its owner is more often the target of envy, in the Event Engine's weights.
   **Amended 2026-11-25:** the retired gifts' world prices move to tier 3 of the families that replace them: Fate-touched
   (`lucky` 3) envy ×1.5; Genius (`quick_minded` 3) envy ×1.5 and poached as a disciple ×2; Iron-framed (`sturdy_frame`
   3) duel challenges against them ×1.5. Tiers 1–2 carry no world price.

**Gaining and losing traits**

10. **Where traits come from at creation.** An ordinary NPC rolls personality and calling (rule 17) and fate-given traits
    rarely. An authored person has a fixed list. The player's personality comes from the chosen origin and its questions,
    the calling from the starting path, and fate-given traits from the same roll as other people.
    **Amended 2026-11-25:** the v2 kinds at creation follow rule 2a's table and F4b. The player's upbringing comes from
    the origin (Game UI and origins); in a Fated birth their talent tiers, lifestyle and the rest roll like anyone's
    (F4b); in a Self-made birth the player picks the upbringing, 0–2 talent families at any tier and a lifestyle, and
    starts with no path, health or coping trait.
11a. **Events grant v2 traits too (new, 2026-11-25).** An event outcome may grant a path, lifestyle, health or coping
    trait, or remove one by a deed, inside the event's budget, exactly as rule 11 does for gained traits. A grant to a
    full kind is refused and logged (rule 2a's caps), except an opposed trait, which replaces its opposite, a
    lifestyle, which replaces the held one, and a coping trait, which replaces a held coping trait that has not
    hardened (F6b). No event grants or removes an upbringing or a talent tier.
11. **Events add gained traits.** An event outcome may grant a gained trait from the catalogue, inside the event's
    budget (the engine validates it; the LLM may propose a trait id, never a number). A person holds at most 2 gained
    traits. When both slots are full, a new one replaces the oldest held gained trait whose grade is at most its own;
    if there is none, the grant is refused and logged (F6).
12. **Gained traits fade.** Each gained trait expires `fade_seasons` (a guess: 40) after it was gained. The expiry moves
    forward whenever the trait's trigger happens again; the trigger is a **trigger id** carried by the catalogue trait
    and raised by the Event Engine when an outcome matches it (a trait with no trigger id never refreshes). At its expiry the trait is removed (Formulas F6). People change
    slowly in both directions: a scarred warrior stops flinching after a long peace, and a renowned one is forgotten.
13. **Deeds remove traits.** An event outcome may remove a named gained trait (an atonement, a reconciliation, a rite).
    A gained trait that is opposed to a held **gained** trait replaces it outright when its grade is **equal or higher**
    (notable over small); a small trait opposed to a held notable one is refused and logged, like a full-slot grant
    (rule 11). One opposed to a personality trait is held beside it (Edge Cases). Every replacement rule in this
    document uses "grade at most its own" (rule 11); "stronger" in the States table means the same.
14. **A calling follows the path.** A person who changes their path (a sect rank into a different duty, a new craft
    mastery, a new technique focus) may be offered a new calling by the event engine; the new one replaces the old.
15. **One narrow change to personality.** A breakthrough that ends in a heart-demon crisis (Realms & Bottlenecks) may offer
    one personality swap to the opposed trait of a set, once per realm. It is a choice for the player, and a seeded roll
    for NPCs weighted by Dao heart.

**Regard**

16. **Opinion is computed, not stored.** A person's opinion of another person is derived on demand from the two trait
    sets: shared traits add, opposed traits subtract, the regard pulls adjust, plus any authored tie (master, disciples,
    sect head) and the person's own stored attitude to the player when the other is the player (Formulas). No opinion is
    stored for a pair of NPCs, so the save does not grow with the number of relationships.
    **Amended 2026-11-20 by NPC Relationships (#46):** named ties (kin, sư đồ, kết nghĩa, đạo lữ, friend, enmity…) are
    the one stored exception: a small capped set of records per person (`npc-relationships.md` rules 1–7, Formula E),
    which F3's `tie` term reads. Opinion itself is still never stored, and reading it never writes a tie (AC-NT-21
    holds).
    The stored **attitude to the player** stays as built (Quests, Formulas E), and traits set its starting value when the
    player first meets someone.
16a. **Likes and dislikes (new, 2026-11-25;** R6 part 3, CK3-style). A v2 trait lists the traits its holder **likes**
    (often the same trait: two Hermit-taught elders get on) and **dislikes** (a Street orphan resents a Clan heir).
    Entries are v2 ids or v1 names. Each like the other person holds adds to the holder's opinion of them, each
    dislike subtracts (F3's `lk` term). Regard is directed: Temple-raised dislikes Demonic path, and the demonic
    cultivator's own view is set by their own lists. Still computed, never stored (rule 16).

**Creation, inheritance and teaching**

17. **Rolling an ordinary NPC.** Personality is 3 draws without replacement from the catalogue by weight, rejecting any
    trait whose opposite is held; weights come from the person's archetype and, for a sect member, the sect (a martial sect
    leans Brave and Warlike). The calling is 1 draw by weight from the person's path. Fate-given traits are drawn rarely from
    a birth roll tied to the spiritual root (Formulas).
18. **Inheritance and teaching.** A person with known parents inherits each parent's personality trait with a chance, once,
    before the weighted roll fills the rest. A disciple's roll weights lean toward their master's traits. Neither
    overrides rule 3's opposed-set limit.
18a. **Talent tiers are inherited with drift (new, 2026-11-25).** A child of known parents may inherit each talent
    family a parent holds, at the parents' best tier shifted by a seeded drift that leans down (Formulas F5b), so
    gifted lines stay gifted for a generation or two and then regress, as CK3's congenital traits do. Inherited
    families fill the child's talent slots first; the creation roll (F4b) adds new ones only up to its own count.
    Upbringing is not inherited but read from the family (a cultivating clan's child is likely a Clan heir, F4b).

**Reading traits**

19. **Who reads them.** Sects (leaders' and elders' pulls), the Living World Tick and Event Engine (choice weights),
    NPC Interaction & Dialogue (opinion and tone), Quests (offers and refusals, through attitude), the LLM game master
    (names and descriptions for voicing), and Character Stats (the modifier rows, through the Modifier System).
    **Amended 2026-11-25:** the `opens` consumers (rule 8a) read the opened set: NPC Interaction & Dialogue (verbs,
    first), the Event Engine (event hooks), Sects (policy hooks), Combat duels (stances) and the craft systems (craft
    edges).
20. **The LLM game master reads, never writes.** It receives each person's trait names and one-line descriptions. It
    may propose a gained-trait id inside an event outcome; the engine validates it against the catalogue, the event budget
    and rule 11, or refuses it and logs the refusal. A proposal that carries a number, or names a personality, calling
    or fate-given trait, is refused. **Amended 2026-11-25:** it may also propose a path, lifestyle, health or coping id
    (rule 11a, same validation); a proposal naming an upbringing or a talent family or tier is refused.
21. **Cost.** Per season the engine touches only the gained traits that expire (a queue by expiry) and the people an
    event touched, so the
    season tick is proportional to events, not to the 5,000 cultivators. **Amended 2026-11-25:** the expiry queue also
    holds coping expiries (F6b); Waning years is checked only for the people whose lifespan or age line the Living
    World Tick already touches that season. Rows are still summed once at creation and on change, so the v2 kinds add
    no per-season cost.

**Interim choice-tag vocabulary (provisional, 2026-11-14 review).** Every event choice carries one or more of:
`aggressive`, `merciful`, `greedy`, `generous`, `deceitful`, `honest`, `loyal`, `disloyal`, `cautious`, `bold`, `vengeful`,
`forgiving`, `devout`, `pragmatic`, `social`, `solitary`, `ambitious`, `humble`, `diligent`, `indulgent`. This list is handed
to the Event Engine (#23), which owns the final vocabulary and may rename, add or remove tags; the trait-by-tag table in the
catalogue follows it. Until then the tested set is FX-CAT's tags.

### States and Transitions

Traits have no state machine of their own beyond the life of each trait on a person. Each kind follows one line:

| Kind | Enters | Can change | Leaves |
|---|---|---|---|
| Personality (3) | At creation (roll, inheritance, origin or authored) | Once per realm: a heart-demon crisis may swap one to its opposite (rule 15) | Never otherwise |
| Calling (1) | At creation, from the path | When the path changes, an event may offer a new calling (rule 14) | Replaced only |
| Fate-given (0–2) | At birth (rule 17) | Never | Never |
| Gained (0–2) | An event outcome (rule 11) | Its expiry moves forward when its trigger repeats (rule 12) | Expires, removed by a deed, or replaced by a trait of equal or higher grade, including an opposed one (rules 11–13) |
| Upbringing (1) *(new, 2026-11-25)* | At creation (F4b, origin, authored) | Never | Never |
| Talent (0–2; tier A 1–3) *(new)* | At birth (F4b, F5b, authored, Self-made pick) | Never (events move the base talent instead) | Never |
| Path (0–2) *(new)* | An event, technique or deed (rule 11a); F4b at creation | Never | A deed, or its opposite replaces it |
| Lifestyle (0–1) *(new)* | F4b or an event offer | A new offer replaces it | Replaced or removed by a deed |
| Health (0–2) *(new)* | An event outcome; Waning years by age (F6b) | Never | A deed (a cure); Waning years when the lifespan line moves past it |
| Coping (0–1) *(new)* | An event outcome under stress (rule 11a) | Expiry moves forward when its trigger repeats; **hardens** after `coping_harden_refreshes` repeats (F6b) | Expires (unless hardened), removed by a deed, or replaced by a new coping trait (unless hardened) |

**A gained trait's life**

```
        event grants (budget ok, slot free or weaker/oldest replaced)
 none ──────────────────────────────────────────────▶ held (expires = now + fade_seasons)
  ▲                                                     │  trigger repeats: expires = now + fade_seasons
  │                                                     │
  └──── expiry reached  /  a deed removes it  /  replaced by an equal-or-higher-grade or opposed trait
```

**Season tick order** (inside the Living World Tick, after events resolve):
1. Apply trait grants and removals that this season's events produced (rules 11, 13).
2. Remove the gained traits whose expiry is this season (a queue sorted by expiry, so only those are touched; rule 12).
3. Recompute the modifier rows of the people whose traits changed (Character Stats sheet sums).
Nothing else runs per season: opinion and choice weights are computed when read. **Amended 2026-11-25:** step 1 also
applies v2 grants and removals (rule 11a); step 2 also removes expired coping traits and grants or removes Waning years
(F6b); the opened set (rule 8a) and likes (rule 16a) are computed when read.

### Interactions with Other Systems

| System | Direction | What passes between them |
|---|---|---|
| **Modifier System** (#40) | out | Each trait's stat rows as catalogue modifiers, source `trait`; F and I only, never rare or Pending stats (rules 5–7) |
| **Character Stats** (#7) | out / in | Out: the modifier rows on the sheet; **talent tiers as flat modifiers on the talent keys** (F1b; 2026-11-25). In: talents (Dao heart for rule 15's swap; fortune and the root for the fate-given roll; each talent's base for the talent-family weights, F4b); lifespan left for Waning years (F6b) |
| **Sects & Missions** (#26) | out | The sect pulls of a leader's and elders' traits (`design/gdd/sects.md` F15); leaders hold 3 personality traits and 1 calling |
| **Event Engine** (#23) | in / out | Out: choice weights by tag, trait-gated extra options for the player, event-kind weights (envy, betrayal...). In: outcomes that grant or remove traits, inside budgets |
| **Living World Tick** (#28) | in / out | Calls the trait season steps; uses choice weights for NPC actions |
| **NPC Interaction & Dialogue** (#30) | out | Computed opinion between two people (with likes, F3 `lk`); the starting attitude to the player at first meeting; tone hints; **the opened `verb:` hooks and their sides (rule 8a; first consumer, 2026-11-25)** |
| **Quests** (#31) | out | Offers and refusals read attitude, which traits shape at first meeting; quest outcomes may grant gained traits |
| **LLM Game Master** (#29) | out / in | Out: trait names and one-line descriptions. In: proposed gained-trait ids, validated by the engine (rule 20) |
| **NPC Builds** (#24) | in / out | In: archetype and path for the roll weights. Out: the trait list replaces today's `traits_per_person` flavour roll |
| **World Generation & History** (#27) | in | Authored people's fixed traits; parents and masters for inheritance |
| **Realms & Bottlenecks** (#8) | in | The heart-demon crisis that offers rule 15's swap |
| **World Database** (#3) | in / out | Per person: ≤ 18 trait ids (≤ 8 before 2026-11-25), ≤ 3 talent tiers, ≤ 2 gained expiries and ≤ 1 coping expiry and refresh count, ≤ 2 target ids; the player also `heart_demon_used`. In: birthplace and parents for upbringing (F4b) |
| **Save/Load** (#5) | out | Per person: ≤ 18 trait ids, ≤ 3 talent tiers, ≤ 3 expiry seasons (2 gained, 1 coping), 1 coping refresh count, ≤ 2 target ids; the player also `heart_demon_used`. A retired fate id in an old save loads as its talent tier (Trait list) |
| **NPC Relationships** (#46) | in / out | In: the recorded tie value for F3 (its Formula A). Out: opinion, which weights help, revenge and the sworn-sibling help chance |
| **Sects & Missions** (#26), policy hooks *(new, 2026-11-25)* | out | A leader's `policy:` hooks as F15 sect pulls (catalogue § Policy hooks; mapping proposed, Sects owns it) |
| **Combat** duels *(new, 2026-11-25)* | out | A fighter's `stance:` hooks (4); v2 combat rows reach the fight sheet through the Modifier System |
| **Craft systems** (Alchemy, Formations, Item DB refining, Spirit Herbs, Talismans, beasts) *(new, 2026-11-25)* | out | A crafter's `craft:` hooks (8 crafts) |
| **Realms & Bottlenecks** (#8), **Thiên Kiếp**, Cultivation Techniques *(new, 2026-11-25)* | in | Outcomes that grant path traits (a heart demon slain, a deviation survived, a tribulation crossed, a forced breakthrough), through the Event Engine's grant (rule 11a) |
| **Living World Tick** (#28), births *(new, 2026-11-25)* | in | A birth's parents for talent inheritance (F5b) |

### Trait list

The full catalogue lives in `design/gdd/npc-traits-catalogue.md` (2026-11-14): 37 personality traits in 18 opposed sets,
14 callings, 10 fate-given traits in 5 pairs and 16 gained traits, each with its stat rows, choice-tag weights, regard
pulls, roll weight and sect pulls. It replaced the provisional list seeded from Sects. Sects (`design/gdd/sects.md`,
Formulas F15) reads only the pull kinds, so a trait's sect effect must be expressed in those kinds. Compassionate is
opposed to both Callous and Cruel; Callous and Cruel may be held together.

**Amended 2026-11-25:** the catalogue adds § Traits v2, **80 traits**: 12 upbringings, 12 talent families (tiers 1–3),
24 paths, 14 lifestyles, 10 health and 8 coping traits, each with id, name, Hán-Việt name, meaning, rows, opens, likes
and dislikes. Authored source: `design/world/depth/traits-v2.json` (the catalogue copies it; where the two differ the
catalogue's marked changes win). Fate-given now holds 4 kept traits; 6 are retired:

| Retired v1 fate (2026-11-25) | Loads as | Why this tier |
|---|---|---|
| Wise-born (tuệ căn) | `quick_minded` tier 3 (Genius) | The ruling's own example |
| Iron-boned (thiết cốt) | `sturdy_frame` tier 3 (Iron-framed) | Same Hán-Việt name and the same gift (group 5 ruling: talent tiers replace the plain gifts) |
| Heaven-favoured (thiên quyến) | `lucky` tier 3 (Fate-touched) | "tier 3 overlaps v1 Heaven-favoured and replaces it" (`traits-v2.json`) |
| Ill-starred (mệnh khắc) | `unlucky` tier 3 (Star-cursed) | "tier 3 overlaps v1 Ill-starred" |
| Dull-witted (độn căn) | `slow_witted` tier 3 (Dull-witted) | The v1 name is that family's tier-3 name (accepted 2026-11-25, ruling group 11; Open Question 9) |
| Frail (thể nhược) | `frail_frame` tier 1 (Frail) | The v1 name is that family's tier-1 name (accepted 2026-11-25, ruling group 11; Open Question 9) |

A v1 flaw's compensating boon (Ill-starred T +5.3 %, Dull-witted Dt +2.66, Frail Ng +1.60) is dropped with it: a flaw
tier is a plain cost. The authored cast's trait sets (`design/world/depth/people/*.cast.json` and
`sects/*.cast.json`: 1,889 people, 171 tier A, 369 tier B, 1,349 tier C) are World Generation's content and cite these
ids; `tools/design/world/depth_check.py` checks them against both catalogues. They hold 6 retired ids (Heaven-favoured
3, Iron-boned 2, Wise-born 1), which load by the table above.

**Migration of the 12 built flavour traits** (`world_names.json`): tham_lam → Greedy, hao_sang → Gregarious, an_dat →
Reclusive, da_nghi → Paranoid, chinh_truc → Honest, am_hiem → Deceitful, lanh_dam → Callous, cuong_ngao → Arrogant,
than_trong → Cautious, hieu_chien → Warlike, trung_thanh → Loyal, si_tinh → Lovestruck (gained, with no target: it is
dropped on load, since a target cannot be inferred). A person who held two opposed migrated traits keeps the first.

## Formulas

Proposed by `systems-designer` (2026-11-14), with the user's decisions on talents, names, gaps and targets. All values
are **guesses**. Random draws use ADR-0002 keyed streams; the key tuple is given. Values live in a new data file,
`assets/data/traits.json`, beside the trait catalogue.

### F1. Trait stat row size

The trait_row formula is defined as:

`value = d · floor(B · P_t / (price · u) + 1e-6) · u` (Modifier System Formulas C, unscoped, breadth 1.0)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| B | float | small 1.2; notable 8 | constant (Modifier System E) | Grade budget in W |
| P_t | float | 1.0; **personality 2.0** (amended 2026-11-25) | data file (`row_premium`, per kind) | Trait premium (a sizing guide; no price check until the game is finished). Personality rows doubled by the user's ruling (group 5); calling, fate-given and gained stay 1.0 |
| price | float | per stat | data file (`modifier_prices`) | W per unit of the stat |
| u | float | 0.01 / 0.1 / 1 | Character Stats I | The stat's grid |
| d | int | +1 boon; −1 cost | catalogue | Direction |

**Output Range:** a small row is worth about 1.2 W, a notable one about 8 W. A row that floors to 0 is not allowed at
that grade. Talent rows only at notable (rule 7): comprehension +1.6, presence +1.2 at small.
**Example:** Brave: +2.0 % `khi_huyet_pct` (1.2 / 0.6) and −0.8 pp `evade_pct`; Cautious mirrors it. Greedy: +1.7 %
`mission_income_pct` and −0.8 % `tam_ma_resist_pct`. Heaven-favoured (fate-given, notable): +26.6 % `co_duyen_pct`, paid
for through pulls (envy events ×1.5). Ill-starred: −26.6 % `co_duyen_pct` and +5.3 % `tam_ma_resist_pct`. Scarred (gained,
notable cost): −5.3 % `tam_ma_resist_pct`.
**Example (amended 2026-11-25, personality `P_t` 2.0):** Brave: `floor(1.2 · 2.0 / (0.6 · 0.1) + 1e-6) · 0.1` =
**+4.0 %** `khi_huyet_pct` and **−1.6 pp** `evade_pct`; Greedy **+3.4 %** `mission_income_pct` and **−1.6 %**
`tam_ma_resist_pct`; Content's cost **−1.0 %** `cultivation_speed_pct`. On every stat the catalogue's personality
rows use, the doubled row is exactly twice the v1 row (checked stat by stat in the catalogue), so no row changes its
rounding. Heaven-favoured and Ill-starred are retired (rule 2); their F1 values stay only as the v1 record.

### F1b. v2 rows and talent tiers (new, 2026-11-25)

v2 rows are **hand-set** in the catalogue (rule 6). F1b gives the effective talent, which is the only thing computed
here, and the sizing guide each kind was written to. The tier_talent and size_guide formulas are defined as:

`eff(t) = clamp(base(t) + Σ flat(t) + dir_f · tier_add[k_f], 1, 150)` for each talent family f on talent t held at tier k_f
`W_row = |value| · price(stat) · breadth(scope)` ; `W_trait = Σ W_row` (a guide only, never a check: rule 6)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| base(t) | int | 1–100 | Character Stats A | The talent's base value; its grade shows beside the effective value's grade when they differ (Character Stats rule 5, amended 2026-11-25) |
| Σ flat(t) | float | about −20 to +40 | stat sheet | Every other flat modifier on the talent key |
| tier_add | int[3] | **6 / 12 / 20** | data file (`talent_tier_add`) | Points per tier (user ruling, R6: "+6 / +12 / +20 to a talent") |
| dir_f | int | +1 gift; −1 flaw | catalogue | The family's direction |
| k_f | int | 1–3 | person record | The tier held |
| value, price, breadth | float | catalogue; Modifier System prices; 1.0 unscoped, 2/3 for a family tag scope | data files | One hand-set row and its price |

**Output Range:** a tier moves a talent by 6–20 points, 0.4–1.25 σ of the talent roll (σ 16), never past the 1–150
clamp. Tier rows (tiers 2–3) add 0–22 W. The other kinds, measured on the 80 catalogue entries at Modifier System
prices: upbringing 2.0–15.0 W of boon (Clan heir's fortune +3 at 5 W a point is the top); path 4.0–20.8 W of boon (a Profound technique's combat passive budget is 16 W, a
third is 5.3 W; the larger paths are mostly non-combat rows such as `tam_ma_resist_pct`, priced 1.5 a point); lifestyle
0.6–7.2 W; health 2.4–16.8 W of cost (Blind also +7.8 W of `than_thuc_pct`); coping 2.0–7.5 W, most with a cost.
**Example:** base comprehension 45 with `quick_minded` tier 3 reads **65** (45 + 20) and gains +6 %
`cultivation_speed_pct`; the sheet shows **"Upper (base Middle, Genius +20)"** (amended 2026-11-25, Open Question 16;
was Middle) with the +20 in its Breakdown. Base 10 with
`slow_witted` tier 3 reads **1** (10 − 20, clamped). Sword heart: `attack_pct` +6 [sword] (6 · 1.0 · 2/3 = 4.0 W) and
`crit_chance_pct` +3 (3.0 W): **7.0 W**, about 0.44 of a Profound passive budget.

### F2. An NPC's choice weight

The choice_weight formula is defined as:

`w(c) = base_c · clamp(Π_t Π_{g ∈ tags(c)} m(t, g), m_lo, m_hi)`, or 0 if any (t, g) is flagged `never`
Pick: `u = rand01(key: "choice", event_id, person_id, season)`; take the first choice whose running sum ≥ u · Σ w.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| base_c | float | > 0 | Event Engine data | The choice's base weight |
| m(t, g) | float | 2.0 core affinity; 1.5 affinity; 1.0; 0.67 aversion; 0.5 core aversion | data file (catalogue) | Trait-by-tag weight; "core" when the trait is named for the tag |
| never | bool | explicit flag only | catalogue | E.g. Honest on `deceitful` (matches Sects F15's pact keeping) |
| m_lo, m_hi | float | 0.1; 5.0 | data file | Clamp on the product |

**Output Range:** 0.1 · base to 5 · base, or 0 with `never`. If every choice is 0, base weights are used.
**Example:** "a rival insults you", a Wrathful, Vengeful NPC: retaliate (aggressive, vengeful) 1.5 · 2.0 = 3.0; endure
(cautious) 0.67; reconcile (merciful) 0.67 (Vengeful's aversion): odds **69 / 15 / 15 %**.

### F3. Opinion and the starting attitude to the player

The opinion formula is defined as:

`op(a → b) = clamp(s · n_sh − o · n_op + Σ_{t ∈ T_b} bias_all(t) + Σ_{t ∈ T_a} bias_dir(t, b) + tie(a, b) + sect(a, b) + target(a, b), −100, 100)`
`att0 = clamp(round(op(npc → player) + k_st · standing), hostile_threshold + 1, att0_max)` at the first meeting
**Amended 2026-11-25:** `op(a → b)` gains one more term inside the clamp, `+ lk(a, b)`, where
`lk(a, b) = Σ_{t ∈ V_a} ( l_v · |likes(t) ∩ T_b| − d_v · |dislikes(t) ∩ T_b| )`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| n_sh | int | 0–4 | calculated | Shared personality traits plus a shared calling |
| n_op | int | 0–5 | calculated | Opposed pairs between the two people's personality and gained traits (never within one person) |
| s, o | int | 10; 10 | data file | Equal, so the world's mean opinion stays near 0 |
| bias_all | int | Humble +5; Arrogant −5; Renowned +5 | catalogue (same numbers as Sects F15) | Held by b; everyone's view |
| bias_dir | int | Devout −10 to the opposite alignment; Cruel −10 to rivals: people whose sect is at feud or war with a's sect (Sects F7's lines; user decision 2026-11-21) | catalogue | Held by a, toward b |
| tie | int | master or disciple +30; kin +30; Dao companion +50; own sect head +15 | data file | Authored and recorded ties. Since 2026-11-20 the recorded part is NPC Relationships Formula A (`tie_value`, −70 to +105 before F3's clamp: these values plus kết nghĩa, companion, blood feud, soft ties and a debt of gratitude at their strength; a Grudge target and the tie's feud plus enmity form one term, the more negative, 2026-11-21); own sect head +15 stays here, computed from the sect |
| sect | int | same sect +10; else 0.2 · A_sect (−20 – 20) between NPCs; toward the player only +10 for the same sect, else 0 (standing already counts through k_st) | Sects F7 | Sect colouring |
| target | int | ±50 | catalogue | A targeted gained trait toward its target (Lovestruck +50, grudge −50) |
| standing | float | −100 – 100 | Sects F10 | The player's standing with the NPC's sect |
| k_st | float | 0.25 | data file | Weight of standing |
| hostile_threshold | int | −30 | Sects & Missions (`session_actions.json`, read only; Quests reads it too) | The floor is −29: traits alone never make a stranger hostile |
| att0_max | int | 30 | data file | Ceiling at a first meeting |
| V_a | set | 0–10 traits | calculated | a's **v2** traits (only v2 traits carry likes and dislikes; *new 2026-11-25*) |
| T_b | set | 5–18 ids | calculated | All of b's traits: v1 names and v2 ids; a talent family matches whatever its tier |
| l_v | int | **5** | data file (`opinion.like`) (accepted 2026-11-25, ruling group 11) | Per liked trait b holds |
| d_v | int | **10** | data file (`opinion.dislike`) (accepted 2026-11-25, ruling group 11) | Per disliked trait b holds. Twice l_v because the catalogue lists 77 likes and 39 dislikes, so 77 · 5 ≈ 39 · 10 and the world's mean opinion stays near 0, the reason s = o (values accepted 2026-11-25; Open Question 11) |
| lk | int | about −30 to +25 in practice | calculated | The likes term. v2 traits never enter n_sh or n_op, so a same-trait like (two Hermit-taught) is counted once, here |

**Output Range:** op −100 to 100; att0 −29 to 30. After the first meeting the stored attitude moves as Quests says.
**Example (likes, 2026-11-25):** two Reclusive, Hermit-taught elders: n_sh = 1 (Reclusive, +10); `hermit_taught` likes
Reclusive and `hermit_taught`, and the other holds both: lk = +10; op = **20** each way. A Street orphan and a Clan
heir: each lists the other's upbringing as a dislike, so lk = −10 each way. A Temple-raised elder meeting a demonic
cultivator: `temple_raised` dislikes `demonic_path`, lk −10; the demonic cultivator's `demonic_path` dislikes
`temple_raised`, −10 back.
**Example:** a Brave, Vengeful, Devout (chính) NPC meets a Brave, Forgiving, Humble, ma-aligned player with standing −20:
+10 − 10 + 5 − 10 − 5 = **att0 −10**. A Brave master and a Brave disciple in different sects: 10 + 30 = **40** (50 in the same sect).

### F4. Creation roll

The trait_roll formula is defined as:

Personality: `w_t = b_t · m_arch(t) · m_sect(t) · m_master(t)`; 3 draws, each removing t and opp(t) from the pool.
Calling: 1 draw from `w_c` over the callings the path allows. Fate-given: P(0 / 1 / 2) = 0.90 / 0.09 / 0.01 (**0.96 / 0.036 /
0.004 since 2026-11-25**, `p_any` 0.04), then
`w_f = b_f · g_f`; the second draw removes the first trait and its opposite from the pool (a person never holds
Heaven-favoured with Ill-starred). Key ("traits", person_id).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| b_t, b_f | float | b_f 1.0; b_t 0.5–1.0 (1.0 except Cruel 0.5, Arbitrary 0.7; catalogue) | data file | Base weights |
| m_arch, m_sect | float | 0.5 / 1 / 2 | data file | Leans (a martial sect ×2 on Brave and Warlike) |
| m_master | float | 3 on the master's traits | data file (F5) | Teaching |
| p_any, p_second | float | 0.10; 0.10 (**`p_any` 0.04 since 2026-11-25**) | data file | Fate-given count |
| g_f | float | 0.25–3 | calculated | Heaven-favoured clamp(eff(khi_van) / 45); Ill-starred clamp(45 / eff(khi_van)); root-bound traits 0 unless the root qualifies. **Since 2026-11-25** the pool is the 4 kept fates (a gift reads its talent / 45, a flaw 45 / its talent) |

**Output Range:** 3 distinct, non-opposed personality traits; 1 calling; 0–2 fate-given traits.
**Example:** fortune 72 gives Heaven-favoured g 1.6 and Ill-starred 0.63. In 5,000 cultivators, about 450 hold one
fate-given trait and 50 hold two; each personality trait is held by about 3/37 of people (about 400).
**Amended 2026-11-25:** the fate-given pool is the 4 kept fates (rule 2), and **`p_any` = 0.04** (was 0.10), so each
kept fate keeps its v1 world count (0.10 / 10 traits = 0.04 / 4 traits = 1 % of people per trait before `g_f`).
`p_second` stays 0.10. In 5,000 people about 180 hold one fate-given trait and 20 hold two. Example now: soul 72 gives
Spirit-eyed g 1.6 and Hollow-souled 0.625.

### F4b. Creation roll for the v2 kinds (new, 2026-11-25)

The trait_roll_v2 formula is defined as, after F4 and F5b, in this order (key ("traits_v2", person_id, kind)):

1. **Upbringing**, exactly 1: `w_u = b_u · m_birth(u) · m_family(u)`.
2. **Optional kinds**, in the order talent, path, health, lifestyle, coping, each with its count odds below; a draw that
   would take the person past `n_create_max` traits (counting the fixed five, fate-given and inherited talents) is
   skipped, and so is every later one. Fate-given traits (F4) and inherited talents (F5b) are **never** skipped by the
   cap. With `n_inh` inherited families and a talent count draw n, new families are drawn only while the person holds
   fewer than max(n, n_inh) talents (rule 18a).
   - Talent count P(0 / 1 / 2) = `p_talent`; each family by `w_f = clamp(base(t) / 45, 0.25, 3)` for a gift and
     `clamp(45 / base(t), 0.25, 3)` for a flaw (F4's `g_f` pattern on the family's talent, read before trait rows),
     removing the family, its opposite and any family opposed to a held fate (rule 2a); tier P(1 / 2 / 3) = `p_tier`.
   - Path P(1) = `p_path[realm]`, uniform over the paths whose root bond holds (`frost_veined` needs Water or Ice,
     `fire_tempered` Fire, `thunder_struck` Fire and Metal or Thunder, `pure_root_devotee` a single-element root).
   - Health P(1) = `p_health`, uniform over the health traits except Waning years (F6b grants that by age).
   - Lifestyle P(1) = `p_lifestyle`, uniform. Coping P(1) = `p_coping`, uniform.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| b_u | float | 1.0 | data file | Upbringing base weight |
| m_birth, m_family | float | 0–3 | data file (World Generation #27 owns the tables) | Leans by birthplace kind (city: Street orphan, Merchant's child, Mortal noble, Scholar's child; village: Village-born; wild: Wild-raised, Hermit-taught) and family (cultivating parents: Clan heir; sect servants: Servant-born; taken in as a child: Sect-raised); 1.0 until set |
| n_create_max | int | **6** | data file (from `traits-v2.md`'s ordinary band 4–6; accepted 2026-11-25, ruling group 11: an ordinary person holds ≤ 6 traits at creation) | Total traits an ordinary rolled person may reach at creation |
| p_talent | float[3] | **0.75 / 0.22 / 0.03** | data file *(guess)* | Talent count odds |
| p_tier | float[3] | **0.70 / 0.24 / 0.06** | data file *(guess; the authored cast, notables included, runs 53 / 36 / 11 %)* | Tier odds of a rolled family |
| p_path | float per realm | **Luyện Khí 0.05, Trúc Cơ 0.20, Kết Đan 0.40, Nguyên Anh and above 0.60** | data file *(guess)* | A path comes with cultivation |
| p_health | float | **0.08** | data file *(guess)* | |
| p_lifestyle | float | **0.35** | data file *(guess)* | |
| p_coping | float | **0.03** | data file *(guess)* | Stress already lived through |

**Output Range:** 1 upbringing; 0–2 talents (0–1 drawn new in practice: the cap of 6 leaves room for one optional
trait); 0–1 of each other kind. A person with no known parents holds 5–7 traits at creation; with inheritance up to 9
(two fates and two inherited families, very rare). Simulated over 200,000 rolls with a world realm mix of 70 / 22 / 6 / 2 %:
**5 traits 37 %, 6 traits 62 %, 7 traits 0.4 %** (two fates); holders of a talent 24 %, a lifestyle 20 %, a path 8 %,
a health trait 5 %, a coping trait 1 %; tiers 70 / 24 / 6 %; mean 5.6 traits. Authored people are not rolled.
**Example:** a Luyện Khí villager with base comprehension 70 draws a talent count of 1. The family draw weighs all 12
families by their own talents; comprehension's gift weighs 1.56 and its flaw 0.64 (at base 45 both would weigh 1).
The draw lands on `quick_minded` and the tier draw on 2: Brilliant (comprehension +12, cultivation speed +3 %). That is
the sixth trait, so the path, health, lifestyle and coping draws are skipped.

### F5. Inheritance and teaching

The inherit formula is defined as:

For each known parent, one roll with chance h (key ("inherit", child_id, parent_id)); on success, one of that parent's
personality traits not held and not opposed, chosen uniformly. F4 fills the rest, with `m_master` on the master's traits.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| h | float | 0.5 | data file | Chance per parent |
| m_master | float | 3 | data file | Lean toward a master known at creation |

**Output Range:** 0–2 inherited traits (about 1 with two known parents).
**Example:** a disciple shares 0.60 of the master's traits on average (an expected count out of 3, not a 60 % fraction), against 0.24 at random (3 · 3/37; checked by
`qa-lead` over 100,000 rolls). A master taken later passes on
only a calling (rule 14).

### F5b. Talent inheritance with drift (new, 2026-11-25)

The inherit_talent formula is defined as:

For each talent family f held by at least one known parent: `P_inh(f) = h_t1` if one parent holds f, `h_t2` if both;
key ("inherit_talent", child_id, f). On success: `k0 = max(parents' tiers of f)`, drift `δ ∈ {−1, 0, +1}` with odds
`p_drift`, key ("talent_drift", child_id, f); `k = min(3, k0 + δ)`; k = 0 means not inherited.
Then: a gift and the flaw on the same talent both inherited cancel (neither is held); more than 2 inherited families
keep the 2 highest tiers (ties by the family's catalogue order). Inherited families count toward F4b's cap.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| h_t1 | float | **0.35** | data file (`inherit.talent_one`) *(guess)* | Chance when one parent holds the family |
| h_t2 | float | **0.65** | data file (`inherit.talent_both`) *(guess)* | Chance when both parents hold it |
| p_drift | float[3] | **0.40 / 0.45 / 0.15** for −1 / 0 / +1 | data file (`inherit.talent_drift`) *(guess)* | Mean drift −0.25 a generation: gifted lines regress toward the mean instead of compounding into dynasties of geniuses |
| k0, k | int | 1–3; 0–3 | calculated | The parents' best tier and the child's |

**Output Range:** 0–2 inherited families. A tier-1 family is lost 40 % of the time it passes; a tier-3 family stays at 3
60 % of the time it passes.
**Example:** both parents hold `quick_minded` (tiers 3 and 2): P_inh 0.65, k0 3; tier 2 (δ −1) 0.65 × 0.40 = **0.26**,
tier 3 (δ 0 or +1, capped) 0.65 × 0.60 = **0.39**, none **0.35**. One parent with `sturdy_frame` 1: P_inh 0.35; lost
(δ −1) 0.14, tier 1 **0.1575**, tier 2 **0.0525**.

### F6. Gained traits: expiry, replacement and the world's stock

The fade formula is defined as:

`expires` is the stored field (rule 3): set to `now + F` on a grant and on a refresh; removed when `now ≥ expires`
Replacement: an opposed trait replaces outright; otherwise the new trait replaces the oldest held one whose grade is ≤ its
own; if none, the grant is refused and logged. Steady state: `N_gained ≈ λ · F`.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| F | int | 40 seasons | data file | `fade_seasons` |
| expires | int | season | World DB | Stored expiry season, reset to now + F by a grant or refresh |
| λ | float | about 25 grants a season (unknown) | Event Engine | World grant rate |

**Output Range:** about 1,000 gained traits held at once; 18 % of people hold one or more, 1.8 % hold two.
**Example:** Scarred gained in season 100 expires in season 140; a second battle in season 130 moves it to 170.

### F6b. Coping fade and hardening; Waning years (new, 2026-11-25)

The coping_fade and waning formulas are defined as:

Coping: on a grant, `expires = now + F_c`, `refreshes = 0`; when its trigger repeats, `expires = now + F_c` and
`refreshes += 1`; when `refreshes ≥ n_h` it **hardens**: `expires` is cleared and it never fades. Removed when
`now ≥ expires` (not hardened) or by a deed.
Waning years: held while `lifespan_left ≤ w_s · lifespan_total`; granted or removed at the season step that crosses
the line.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| F_c | int | **20 seasons** | data file (`coping_fade_seasons`) *(guess: half a gained trait's 40, since coping is a reaction, not a reputation)* | Coping fade |
| n_h | int | **3** | data file (`coping_harden_refreshes`) *(guess)* | Repeats before a habit becomes a trait for life ("fades or hardens", `traits-v2.json`) |
| refreshes | int | 0–n_h | World DB | Stored per coping trait |
| lifespan_left, lifespan_total | int | years | Character Stats (lifespan) | |
| w_s | float | **0.10** | data file (`waning_share`) *(guess)* | The share of a life left at which Waning years arrives |

**Output Range:** a coping trait lasts 20 seasons after its last trigger, or for life once hardened. Waning years is
held for the last 10 % of a lifespan and leaves when a pill or a breakthrough lifts the lifespan above the line.
**Example:** Drowns in wine granted in season 50 (expires 70); its trigger repeats in 60 (expires 80, refreshes 1);
nothing more, so it is removed at 80. Granted again in 90 with repeats in 100, 110 and 120: refreshes 3 at 120, it
hardens and never fades. A Kết Đan cultivator with a 500-year lifespan and 49 years left (9.8 %) holds Waning years; a
longevity pill adding 20 years (69 of 520, 13 %) removes it.

### F7. The player acting against or with a trait

The trait_conflict formula is defined as:

`Δtâm_ma = min(tm_a · n_against, tm_cap − heart_demon_used)` per choice, the cap counted across all of a season's
choices (`heart_demon_used`, the player record's saved counter, adds the pre-resistance gain and resets each season) and
applied before Character Stats' heart-demon resistance;
when the choice carries a **sect id** (a sect-affecting choice, set by the Event Engine), `Δstanding = −st_a` with that sect;
acting in character: `cost' = cost · (1 − r)^min(n_with, 2)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| tm_a | float | 2 | data file | Heart demon per conflicting trait (a failed breakthrough is 15) |
| tm_cap | float | 6 | data file | Cap a season, so heart demon cannot become a soft lock |
| st_a | int | 3 | data file | Standing cost |
| r | float | 0.10 | data file | Cost reduction in character |
| n_against, n_with | int | 0–13 (8 v1 traits and at most 5 weighted v2 traits: upbringing, 2 paths, lifestyle, coping; 2026-11-25) | calculated | Per held trait t, take its product `p_t = Π_{g ∈ tags(c)} m(t, g)` over the choice's tags: t counts **against** when `p_t < 1`, **with** when `p_t > 1`, and neither when `p_t = 1` (so a trait with an affinity and an aversion across one choice's tags nets out by product; `never` counts as against) |

**Output Range:** heart demon +0 to +6 a season; costs down by at most 19 %. Acting in character never heals heart demon.
**Example:** an Honest, Loyal player who breaks an oath gains 4 heart demon (3.8 with 5 % resistance). A Greedy player pays
90 instead of 100 for a bribe option.

### F8. A personality swap at a heart-demon crisis (NPC)

The swap formula is defined as:

`P_swap = max(0, p_s · (100 − eff(dao_tam)) / 55)` (the maximum is 0.545 at Dao heart 1, so no cap is needed); the trait is chosen uniformly among those that may swap,
key ("swap", person_id, realm)

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| p_s | float | 0.30 | data file | Chance at Dao heart 45 |
| eff(dao_tam) | float | 1–150 | Character Stats B | Effective Dao heart |

**Output Range:** 0 to 0.54 in practice (0 at Dao heart 100 or more).
**Example:** Dao heart 1 / 20 / 45 / 80 → 0.54 / 0.44 / 0.30 / 0.11. A Callous person cannot swap to Compassionate while
Cruel is held. Compassionate swaps to Callous or Cruel by a seeded pick (key ("swap_to", person_id, realm)).

**Riskiest values:** opinion's s against o (F3); λ, which depends on event volume (F6); tm_a and tm_cap (F7); keeping
`never` to explicit flags (F2). **Since 2026-11-25:** `tier_add` 20 at tier 3 (a talent row of +20 is far past any W
grade, so it is sized against the talent roll, F1b); l_v against d_v (F3); `n_create_max` 6, which leaves ordinary
people one optional trait (F4b); the v2 combat rows on path traits (F1b).

## Edge Cases

**Holding and replacing**

- **A roll would draw an opposed trait.** It cannot: each draw removes the trait and its opposite from the pool (F4).
  If the pool empties (possible only if a lean of 0 is allowed), the remaining draws are skipped and the person holds
  fewer than 3; this is logged, and no AC band allows it above 0.1 % of people.
- **Two parents give opposed traits.** The first inherited trait is kept; the second roll skips any trait opposed to it.
- **A gained trait arrives and both slots are full of stronger traits.** The grant is refused and logged (F6); the event's
  other outcomes still apply.
- **A gained trait is opposed to a personality trait** (Humbled on an Arrogant person). It is allowed: gained traits
  colour, they do not erase. Opinion counts the pair as opposed only between two people, never within one.
- **A targeted gained trait's target dies.** The target id is cleared from the save and the target term drops to 0. A
  Grudge stays until it expires, keeping its own tag weights (vengeful affinity 1.5 on choices tagged `vengeful`, as F2
  multiplies over a choice's own tags only), so it reads as a general bitterness. Lovestruck whose target dies is replaced by Grieving (a gained trait) at once.
- **The player is the target of an NPC's grudge.** The target term (−50) enters the NPC's opinion of the player; the stored
  attitude to the player is not changed by it, so Quests' attitude rules stay the only writer of that number.

**Stats and sizes**

- **A trait row would floor to 0 at its grade.** That stat is not allowed for the trait at that grade (F1); the catalogue
  lint rejects it.
- **A trait row names a Pending, rare or damage-layer stat.** Data validation rejects it (rules 5, 7).
- **A personality swap would break an opposed set** (Callous to Compassionate while holding Cruel). The swap picks another
  trait, or none if none may swap (F8).
- **The player refuses the rule-15 swap.** Nothing changes; the offer does not return for that realm.

**Choices and the player**

- **Every choice of an NPC's event has weight 0** (all `never`). Base weights are used (F2).
- **A player choice is against several traits.** Heart demon gain is capped at 6 a season (F7); the option is never
  greyed out (rule 9).
- **An LLM outcome proposes a trait id not in the catalogue, a personality or fate-given trait, or a trait over budget.**
  Refused and logged (rule 20); only gained traits may be granted by events.

**Migration and authored people**

- **An old save holds the 12 built flavour ids.** The migration also retires `traits_per_person`
  (`assets/data/world_generation.json`, read in `build_generator.gd`), which F4 replaces. They map as the migration table says; si_tinh is dropped (no target); a
  person with fewer than 3 personality traits after mapping is filled by F4 with its seeded key, and every migrated
  person rolls a calling and fate-given traits by F4 with the same key.
- **An authored person's fixed traits break a rule** (two opposed, four personality). The world data load fails and names
  the person and the rule.

**Sects**

- **A sect leader changes traits mid-season** (a gained trait, a swap). Sects reads the new pulls from the next tick, as
  with succession (Sects rule 15).
- **Gained and fate-given traits carry sect pulls.** Allowed; a sect sums over all its leader's traits (Sects F15). The
  sums stay within F15's stated output range, or the catalogue lint flags the trait.

**Traits v2 (new, 2026-11-25)**

- **A record holds a retired fate id** (Wise-born, Iron-boned, Heaven-favoured, Ill-starred, Dull-witted, Frail: an
  old save, or 6 authored cast records). It loads as its talent tier (Trait list). If the person already holds that
  family, the higher tier is kept; if they hold the opposite family, the converted one is kept and the other dropped;
  if the conversion would make a third talent on a rolled person, the lowest tier is dropped. Each case is logged.
- **A record has no upbringing** (an old save, or a person authored before 2026-11-25). On load the upbringing is
  filled by F4b step 1 with its seeded key; the optional kinds are **not** rolled for an existing person (they enter
  in play). Loading twice gives the same upbringing (AC-NT-28 as amended).
- **An authored person breaks a per-kind cap** (a third path, a second upbringing, no upbringing, a fourth talent, a
  gift with its own flaw). The world data load fails and names the person and the rule (as AC-NT-29). Today one
  authored person in `sects/bang_tam.cast.json` holds 3 paths; it must be re-authored before export.
- **An authored person is above the total band** (tier A 6–12, B 5–8, C 4–6; amended 2026-11-25). The export trims
  them to the band's top, weakest-fitting extras first (rule 2a); the load never sees an over-band person. Today
  4 tier A (13 each), 20 tier B and 6 tier C people, 36 traits.
- **An authored person is below the band floor, or is tier A with no talent.** Logged by the authoring lint, never a
  load failure and never filled in. Today 0 below and 2 tier A people with no talent.
- **The trim would have to drop a protected trait** (a person over band holding only personality, calling, upbringing
  and one talent). Impossible within the caps (those make 6 at most); if the data ever produced it, the export stops
  trimming at the protected set and logs the person.
- **Spirit-eyed with `keen_soul`** (both soul gifts). Allowed; both rows stack (8 authored people). Spirit-eyed with
  `thin_soul` is opposed and refused.
- **A talent tier would push the effective talent past 1–150.** The clamp holds (Character Stats rule 5); the
  Breakdown shows the clip. The grade shown is the effective value's, Heavenly above 100, with the base grade beside
  it (Character Stats rule 5, amended 2026-11-25; Open Question 16).
- **A path grant when both path slots are full.** Refused and logged, unless it is the opposite of a held path, which
  it replaces. A third health trait: refused and logged, except Waning years, which with both slots full replaces
  the older held health trait (age outranks an old wound; logged).
- **A coping trait arrives while a hardened one is held.** Refused and logged; a deed must remove the hardened one
  first. A new coping trait replaces an unhardened one; the same one refreshes it (F6b).
- **Waning years and a lifespan that rises and falls.** Granted and removed each time the line is crossed, at most
  once per season step.
- **A hook with no consumer record** (`verb:wager` before #30 has a wager verb). It does nothing; the lint lists it.
  The trait's rows and likes still apply.
- **The player holds a `verb:` hook whose side is "other"** (`verb:ask_history`, opened by Chronicler). The player
  sees the verb only with a person who holds a Chronicler trait; holding it themselves adds nothing (rule 8a).
- **A `policy:` hook on a person who leads no sect.** Ignored; it applies from the next tick after they take a seat,
  like any leader pull.
- **A likes list names a trait not in either catalogue.** The catalogue lint rejects it.
- **A meaning mentions a place, weather or season** (Old wound, Lingering poison, Array-bound). Flavour only (rule 7a).
  A row with a condition field is rejected by the lint.
- **Hunter's `attack_pct` [creature] row** (amended 2026-11-25). Until Combat stamps the foe tag `creature` on
  profiles, no foe matches and the row adds nothing; a beast-form art no longer gets it (rule 7).
- **One-element devotee with a tie or no base element** (amended 2026-11-25). `own_top_element` resolves to the
  first of Kim, Mộc, Thủy, Hỏa, Thổ among the tied top purities; a root with no base element gets nothing from the
  row. If a pill or event changes the root, the scope re-resolves when the rows are re-summed (rule 7).
- **Both parents give a gift and its flaw** (one Quick-minded, one Slow). Each rolls; if both pass they cancel
  (F5b), so the child holds neither from inheritance, and F4b may still roll a family for them.

## Dependencies

**Upstream (this system reads them)**

| System | Hard / soft | Interface | Lists NPC Traits back? |
|---|---|---|---|
| Modifier System (#40) | Hard | Stat List keys, F and I operations, grades (small 1.2, notable 8), rounding grid | Yes (modifiers.md, added 2026-11-14) |
| Character Stats (#7) | Hard | Talents (fortune for F4, Dao heart for F8, each base for F4b's family weights); the sheet that sums the rows and the talent-tier flats (F1b); heart-demon gain (F7); lifespan for Waning years (F6b, 2026-11-25) | Yes (character-stats.md, added 2026-11-14); the talent-tier source and lifespan read owed (2026-11-25) |
| World Database (#3) | Hard | Person records: trait ids, expiries, targets, parents, master | — (no GDD) |
| NPC Builds (#24) | Hard | Archetype and path for the roll leans; replaces `traits_per_person` | — (no GDD) |
| Time & Turn (#4) | Hard | The season clock for expiries | — (no GDD) |
| Event Engine (#23) | Hard | Choice tags on every choice; outcomes that grant or remove gained traits | — (no GDD) |
| World Generation & History (#27) | Soft | Authored people's traits, ties, parents and masters; **upbringing leans `m_birth`, `m_family` and the birthplace kind (F4b); the authored cast's v2 trait sets (`design/world/depth/`, 1,889 people; 2026-11-25)** | Owed (world-generation.md, 2026-11-25) |
| Realms & Bottlenecks (#8) | Soft | The heart-demon crisis that offers rule 15's swap | Yes (canh-gioi.md, added 2026-11-14) |
| Sects & Missions (#26) | Soft | Sect leans for the roll (F4); standing for att0 (F3); sect attitude (F3) | Yes (F15, rule 11) |
| NPC Relationships (#46) | Soft | The recorded part of F3's `tie` term (its Formula A); without it `tie` is 0 except the sect head | Yes (npc-relationships.md, 2026-11-20) |

**Downstream (they read this system)**

| System | Hard / soft | Interface | Lists NPC Traits back? |
|---|---|---|---|
| Sects & Missions (#26) | Hard | Sect pulls of leaders and elders (F15 contract); **4 `policy:` hooks as F15 pulls (catalogue § Policy hooks, 2026-11-25)** | Yes; the policy mapping and the trait-list counts in F15 owed (2026-11-25) |
| Living World Tick (#28) | Hard | Trait season steps; choice weights for NPC actions | — (no GDD) |
| Event Engine (#23) | Hard | Choice weights, trait-gated options, event-kind weights; **60 `event:` hooks (54 tags) as show conditions or event weights; v2 grants and removals (rule 11a) and coping trigger ids (2026-11-25)** | Yes (event-engine.md); the v2 hooks owed (2026-11-25) |
| NPC Interaction & Dialogue (#30) | Soft | Opinion (with likes), att0, tone hints; **19 `verb:` hooks with their sides, the first `opens` consumer (rule 8a, 2026-11-25)** | Yes (npc-interaction-dialogue.md); the verb records owed (2026-11-25) |
| Quests (#31) | Soft | att0 at first meeting; gained traits from outcomes | Yes (quests.md, added 2026-11-14) |
| LLM Game Master (#29) | Soft | Names and descriptions; proposals validated | — (no GDD) |
| Save/Load (#5) | Hard | ≤ 8 ids, ≤ 2 expiries and ≤ 2 targets per person; **since 2026-11-25 ≤ 18 ids, ≤ 3 talent tiers, ≤ 3 expiries, 1 coping refresh count (rule 3)** | — (no GDD) |
| NPC Relationships (#46) | Hard | F3 opinion for help and revenge weights and `p_help`; rule 16 (amended) | Yes |
| Codex & Karmic Carryover (#12) | Soft | An heir successor keeps their traits' stat rows, and trait-gated event options appear for the player; nothing is forced (`codex-karmic-carryover.md` Edge Cases) | Yes |
| Combat (#21), duels *(new, 2026-11-25)* | Soft | v2 combat rows (through the Modifier System); 4 `stance:` hooks (`duel-readings.md`) | Owed (combat.md) |
| Craft systems: Alchemy, Formations, Item DB (refining), Spirit Herbs, Talismans *(new, 2026-11-25)* | Soft | 8 `craft:` hooks; what an edge gives is each craft's rule | Owed |
| Realms & Bottlenecks (#8), Thiên Kiếp *(new, 2026-11-25)* | Soft | Grant path traits from their outcomes (Heart-demon victor, Deviation survivor, Tribulation survivor, Lightning-scarred, Cracked foundation) through rule 11a | Owed (canh-gioi.md, thien-kiep.md) |
| Living World Tick (#28), births *(new, 2026-11-25)* | Hard | Calls F5b and F4b for each birth; the season steps for coping and Waning years | — |

**Links:** Modifier System, Character Stats, Realms & Bottlenecks, Quests and Sects & Missions all list NPC Traits back.
Every other row marked "no GDD" is fixed when that system is designed. **2026-11-25:** the rows marked "owed" need a
line back from that GDD for the traits v2 amendment; another writer adds them. *(Written 2026-11-25 in Character
Stats, World Generation, Sects (F15), Event Engine, NPC Interaction & Dialogue, Combat, the Modifier System, Realms,
Thiên Kiếp, Living World Tick, Alchemy, Spirit Herbs and Item DB; Formations added 2026-11-25 (ruling group 12);
Talismans, Spirit Beasts, the body craft and `craft:poison` are still owed.)* **Group 12 (2026-11-25):** One-element
devotee's `own_top_element` scope reads the holder's root purities at compile (Spiritual Roots #6, read only); the
over-band trim (rule 2a) runs in World Generation's export (back-link owed in `world-generation.md`); Hunter's
`creature` scope and `own_top_element` need the Modifier System's scope list (Open Question 24, back-link owed).

## Tuning Knobs

*(New section, 2026-11-25. The v1 knobs are the Formulas defaults listed in FX-D; this table holds the knobs the traits
v2 amendment adds and the two v1 knobs it changes. All are guesses unless marked.)*

| Knob | Default | Safe range | What it moves |
|---|---|---|---|
| `row_premium.personality` | **2.0** (was 1.0; user ruling) | 1.0–2.5 | Personality row size (F1). Above 2.5 a three-trait stack on one stat passes a notable node (8 W) |
| `fate.p_any` | **0.04** (was 0.10) | 0.02–0.10 | People with a kept fate (F4); 0.04 keeps each kept fate at its v1 world count |
| `talent_tier_add` | **6 / 12 / 20** (user ruling) | tier 3 at 15–25 | How far a talent tier moves a talent (F1b); above 1.5 σ of the roll (24) one trait outweighs most of the birth roll |
| `opinion.like` / `opinion.dislike` | **5 / 10** | 3–10 / 5–15 | Regard from likes (F3 `lk`); keep like · 77 ≈ dislike · 39 or the world's mean opinion drifts |
| `inherit.talent_one` / `talent_both` | **0.35 / 0.65** | 0.2–0.5 / 0.5–0.8 | How often gifted lines pass on a family (F5b) |
| `inherit.talent_drift` | **0.40 / 0.45 / 0.15** | mean drift −0.4 to −0.1 | How fast gifted lines regress (F5b); a mean drift ≥ 0 lets clans compound into dynasties of geniuses |
| `roll.n_create_max` | **6** | 6–7 | Traits an ordinary person may reach at creation (F4b); 7 lets a second talent or a lifestyle beside a talent |
| `roll.p_talent` | **0.75 / 0.22 / 0.03** | P(≥ 1) 0.15–0.35 | How common a talented ordinary person is |
| `roll.p_tier` | **0.70 / 0.24 / 0.06** | tier 3 at 0.03–0.10 | How common Genius-level gifts and the worst flaws are |
| `roll.p_path` | **0.05 / 0.20 / 0.40 / 0.60** by realm | each 0–0.8 | How marked by their path cultivators are, by realm |
| `roll.p_health`, `p_lifestyle`, `p_coping` | **0.08, 0.35, 0.03** | 0–0.2, 0.1–0.6, 0–0.1 | How many people start wounded, with a pastime, or already coping |
| `coping_fade_seasons` | **20** | 8–40 | How long a coping trait lasts after its last trigger (F6b) |
| `coping_harden_refreshes` | **3** | 2–6 | How many repeats turn a coping habit into a trait for life (F6b) |
| `waning_share` | **0.10** | 0.05–0.2 | The share of a lifespan at which Waning years arrives (F6b) |
| `trait_bands` | A 6–12, B 5–8, C 4–6 (`traits-v2.md`; tier A amended 2026-11-25) | top 10–14 for A | The export trims to each band's top (rule 2a); the floors are the authoring lint (advisory). A lower top drops more authored traits |

## Acceptance Criteria

Drafted with `qa-lead` (2026-11-14); the F5 example was corrected from its check, and its gaps were settled in the
sections above. Nothing has run yet; every value is a guess until AC-NT-36 passes. Tests never call a live model. Every
draw uses an ADR-0002 keyed stream. Unit tests in `tests/unit/npc_traits/`, integration tests in
`tests/integration/npc_traits/`, timing and statistics in `production/qa/evidence/balance/`. Tolerance ±0.01 or one grid
step unless stated.

**Fixtures**
- **FX-D:** the Formulas defaults in `assets/data/traits.json` (s = o = 10, F 40, m_lo 0.1, m_hi 5, h 0.5, m_master 3,
  p_any = p_second 0.10, tm_a 2, tm_cap 6, st_a 3, r 0.10, p_s 0.30, k_st 0.25, att0_max 30), with the Modifier
  System prices `khi_huyet_pct` 0.6, `evade_pct` 1.5, `mission_income_pct` 0.7, `tam_ma_resist_pct` 1.5, `co_duyen_pct`
  0.3, `ngo_tinh` 5, `mi_luc` 1.0. **Amended 2026-11-25:** `row_premium.personality` 2.0, `p_any` 0.04, plus the
  Tuning Knobs defaults for the v2 knobs.
- **FX-V2 (new, 2026-11-25):** the catalogue's § Traits v2 (80 traits) and the 4 kept fates.
- **FX-CAT:** the catalogue's 37 personality traits in 18 sets and its 6 seed callings (`npc-traits-catalogue.md`) plus test gained traits Scarred (notable),
  Renowned (small, bias_all +5), Humbled (small), Grudge (targeted, −50), Lovestruck (targeted, +50), Grieving. Tag weights:
  Wrathful × aggressive 1.5, Vengeful × vengeful 2.0, Wrathful × cautious 0.67, Vengeful × merciful 0.67, Honest × deceitful
  `never`; all other pairs 1.0.
- **FX-W5K:** a generated world of 5,000 people from a fixed seed, default leans, no authored people.
- **FX-EV:** an Event Engine stub granting λ = 25 gained traits a season to keyed, uniformly drawn people, half small and
  half notable.
- **FX-LLM:** a mock returning scripted outcomes. **FX-OLD:** a save from the current build (`traits_per_person` 2 from the
  12 built ids).

**Record and kinds**

- **AC-NT-01** [Logic] Rules 2–3. **GIVEN** any person in FX-W5K, **THEN** they hold 3 personality traits with no opposed
  pair, 1 calling, 0–2 fate-given and 0–2 gained traits (≤ 8 ids); each gained trait has one expiry, and only targeted ones
  a target. **WHEN** an API call adds a 4th personality trait, a 2nd calling or a 3rd fate-given trait, **THEN** it is
  rejected.
  **Amended 2026-11-25:** the person also holds exactly 1 upbringing and the v2 kinds within rule 2a's caps (≤ 18 ids);
  AC-NT-40 tests the v2 caps.
- **AC-NT-02** [Logic] Rule 4. **GIVEN** the player and an NPC with identical trait ids, **THEN** their stat rows and F2
  tag multipliers are identical.

**Stat rows (F1, rules 5–7)**

- **AC-NT-03** [Logic] F1. **GIVEN** FX-D, **THEN** Brave gives +2.0 % `khi_huyet_pct` (not 1.9: the +1e-6 term is
  load-bearing) and −0.8 pp `evade_pct`; Greedy +1.7 % `mission_income_pct` and −0.8 % `tam_ma_resist_pct`;
  Heaven-favoured +26.6 % `co_duyen_pct`; Ill-starred −26.6 % `co_duyen_pct` and +5.3 % `tam_ma_resist_pct`; Scarred −5.3 %
  `tam_ma_resist_pct`; a notable `ngo_tinh` row +1.60; a small `mi_luc` row +1.20.
  **Amended 2026-11-25:** with FX-D as amended, Brave gives **+4.0 %** and **−1.6 pp**, Greedy **+3.4 %** and **−1.6 %**
  (AC-NT-37); the Heaven-favoured and Ill-starred values are tested only as the v1 record, since those traits are
  retired and load as talent tiers (AC-NT-49). Scarred, the notable `ngo_tinh` row and the small `mi_luc` row are
  unchanged.
- **AC-NT-04** [Config] Rules 5–7 lint. **GIVEN** catalogue entries each breaking one rule (a `more` row; `attack_pct`,
  crit or a combat offence row; a Pending or rare stat; a talent row at small; a personality or calling trait without
  exactly one boon and one cost row; a row that floors to 0), **THEN** the load rejects each and names the trait and rule.
  **Amended 2026-11-25:** these checks apply to the v1 kinds. A v2 entry is rejected only for a `more` row, a Pending
  or rare key, an unknown key or scope, or a condition field (AC-NT-38, AC-NT-48); a combat row or a one-sided row on a
  v2 entry loads.
- **AC-NT-05** [Integration] Rule 5. **GIVEN** Scarred gained in season 100 by a person at 0 % `tam_ma_resist_pct`,
  **THEN** the sheet reads −5.3 %; **WHEN** season 140 runs, **THEN** after tick step 3 it reads 0 % and no `trait`
  modifier for Scarred remains.

**Pulls and the player rule (F2, F7, rules 8–9)**

- **AC-NT-06** [Logic] F2. **GIVEN** a Wrathful, Vengeful NPC and choices retaliate (aggressive, vengeful), endure
  (cautious), reconcile (merciful), base 1 each, **THEN** weights are 3.0 / 0.67 / 0.67 (Σ 4.34), odds 69.1 / 15.4 / 15.4 %;
  u = 0.50 picks retaliate, 0.75 endure, 0.90 reconcile.
- **AC-NT-07** [Logic] F2 bounds. **GIVEN** a product of 2.0⁴, **THEN** the weight is 5.0 · base; 0.5⁴ gives 0.1 · base;
  Honest on a deceitful choice gives 0; every choice at 0 falls back to base weights.
- **AC-NT-08** [Integration] Rule 8, sect pulls. **GIVEN** a Greedy, Cruel, Cautious Strategist leader, **THEN** Sects
  receives Tax +1, loyalty −1, war odds 0.8 (lowest of 0.8 / 1.2 / 0.9) and first track Military; **GIVEN** the leader
  also holds a gained trait with a Tax pull, **THEN** it is summed too. Every catalogue pull is one of Sects F15's kinds, or
  the lint fails.
- **AC-NT-09** [Integration] Rule 9, never blocked. **GIVEN** every event template, each single trait in the loaded catalogue (FX-CAT: 37 personality, 6 callings and
  the 6 test gained traits) and 1,000 keyed random trait sets, **THEN** the player's selectable options with traits are a superset of those with no traits; no
  option is disabled or hidden.
- **AC-NT-10** [Logic] F7. **GIVEN** an Honest, Loyal player at 0 % resistance breaking an oath on a choice carrying a sect id, **THEN**
  heart demon +4 and standing −3 (3.8 at 5 % resistance); 3 traits against give +6 (5.7 at 5 %), 4 against +6; a second
  against-choice (2 traits) the same season after +4 adds only +2, and the cap resets next season. In-character costs: 100
  → 90 with 1 trait, 81 with 2, 81 with 3; in character never lowers heart demon. **GIVEN** a Wrathful person (aggressive
  1.5, cautious 0.67) and a choice tagged aggressive and cautious (product 1.005), **THEN** the trait counts as neither
  with nor against; a choice tagged only cautious counts it against.

**Gaining and losing (F6, rules 11–15)**

- **AC-NT-11** [Logic] F6 expiry. **GIVEN** Scarred gained in season 100, **THEN** it expires at 140; **WHEN** its trigger
  repeats in season 130, **THEN** it expires at 170 (held in 169, gone after 170's step 2). Granting a held trait refreshes
  it, never duplicates it.
- **AC-NT-12** [Logic] F6, full slots. **GIVEN** Scarred (notable, season 100) and Renowned (small, season 120) held,
  **WHEN** a small trait arrives in season 130, **THEN** it replaces Renowned; **WHEN** a notable one arrives instead, **THEN**
  it replaces Scarred; **GIVEN** two notable traits held, **WHEN** a small one arrives, **THEN** it is refused and logged and
  the event's other outcomes apply.
- **AC-NT-13** [Logic] Rule 13. **GIVEN** a gained trait opposed to a held gained trait of equal or lower grade, **THEN**
  it replaces it whatever its age; **GIVEN** a small trait opposed to a held notable one, **THEN** the grant is refused
  and logged; **GIVEN** Humbled on an Arrogant person, **THEN** both are held, and the pair never counts in n_op within one
  person.
- **AC-NT-14** [Logic] Rule 13, deeds. **WHEN** an outcome removes a held gained trait, **THEN** it is gone that season;
  removing one not held is a logged no-op; removing a personality or fate-given trait by event is refused.
- **AC-NT-15** [Logic] Rule 14. **WHEN** a path change's new calling is accepted, **THEN** exactly 1 calling is held, with
  the old rows gone and the new present.
- **AC-NT-16** [Logic] Target dies. **GIVEN** A holds Grudge → B, **THEN** op(A → B) includes −50; **WHEN** B dies in
  season s, **THEN** the target id is cleared, the Grudge keeps its expiry and its target term is 0; **GIVEN** Lovestruck →
  B instead, **THEN** in season s it becomes Grieving, expiring at s + 40.
- **AC-NT-17** [Integration] **GIVEN** an NPC with Grudge → player, **THEN** op(NPC → player) includes −50, and the stored
  attitude to the player is byte-identical before and after the grant.
- **AC-NT-18** [Logic] F8. **GIVEN** Dao heart 1 / 20 / 45 / 80 / 100 / 150, **THEN** P_swap is 0.54 / 0.436 / 0.30 /
  0.109 / 0 / 0; **GIVEN** a Callous, Cruel, Brave person, **THEN** only Brave → Cautious may swap; a Compassionate swap picks
  Callous or Cruel by its key; a second crisis in the same realm makes no roll; a player who refuses is not asked again that
  realm.

**Regard (F3, rule 16)**

- **AC-NT-19** [Logic] F3. **GIVEN** the Formulas example (no shared calling, sect term 0), **THEN** op = −5 and att0 =
  −10; **GIVEN** a Brave master and Brave disciple in different sects, **THEN** op = 40, and 50 in the same sect.
- **AC-NT-20** [Logic] F3 clamps. **GIVEN** a raw op of +150, **THEN** op = 100; op −100 with standing −100 gives att0 −29;
  op 100 gives att0 30; att0 is written only at the first meeting.
- **AC-NT-21** [Integration] Rule 16. **WHEN** 1,000,000 opinions are read in FX-W5K, **THEN** the save is byte-identical
  before and after and holds no pair records.

**Creation and inheritance (F4, F5, rules 10, 17–18)**

- **AC-NT-22** [Logic] F5. **GIVEN** two known parents, **THEN** over 100,000 keyed rolls 0 / 1 / 2 inherited traits occur
  25 / 50 / 25 % ± 1 pp; parents holding Brave and Cautious never give a child both; with uniform weights and m_master 3 a
  disciple shares 0.60 ± 0.02 of the master's 3 traits, against 0.24 ± 0.02 at random.
- **AC-NT-23** [Logic] F4. **GIVEN** fortune 72, **THEN** g is 1.6 (Heaven-favoured) and 0.625 (Ill-starred); fortune 5
  clamps them to 0.25 and 3; a root-bound trait has weight 0 when the root does not qualify.
  **Amended 2026-11-25:** the same values now come from the kept fates and talent families: soul 72 gives Spirit-eyed
  1.6 and Hollow-souled 0.625; fortune 72 gives the `lucky` family 1.6 and `unlucky` 0.625 (F4b); soul 5 clamps them
  to 0.25 and 3.
- **AC-NT-24** [Logic] F4 opposed sets. **WHEN** Compassionate is drawn, **THEN** Callous and Cruel leave the pool; **WHEN**
  Callous is drawn, **THEN** only Compassionate leaves. Over 100,000 rolls no opposed pair appears, and Callous with Cruel
  appears at least once.
- **AC-NT-25** [Logic] Rule 10. **GIVEN** a fixture origin and its answers, **THEN** the player's 3 personality traits are
  the origin table's, the calling follows the starting path, and fate-given traits use key ("traits", player_id).

**LLM and reading (rules 19–20)**

- **AC-NT-26** [Integration] Rule 20. **GIVEN** FX-LLM proposals of an unknown id, a personality id, a fate-given id, an
  over-budget gained id and a gained id with a number, **THEN** each is refused and logged with its reason and the other
  outcomes apply; a valid in-budget gained id is granted.
- **AC-NT-27** [Integration] Rule 20. **THEN** the LLM payload for a person holds trait names and one-line descriptions only.

**Migration and authored data**

- **AC-NT-28** [Integration] Migration. **GIVEN** FX-OLD, **THEN** all 12 ids map as the table says; [hao_sang, an_dat]
  becomes Gregarious plus 2 F4 fills (never Reclusive); [si_tinh, tham_lam] becomes Greedy plus 2 fills, no Lovestruck;
  [chinh_truc, am_hiem] keeps Honest; every person gets a calling and a fate-given roll, then passes AC-NT-01; loading twice
  gives identical traits. **Amended 2026-11-25:** every migrated person also gets an upbringing by F4b step 1 and no
  other v2 trait, then passes AC-NT-01 as amended.
- **AC-NT-29** [Config] **GIVEN** an authored person with Brave + Cautious, 4 personality traits, an unknown id, 2
  callings or 3 fate-given traits, **THEN** the world load fails and names the person and the rule.
  **Amended 2026-11-25:** also no upbringing or two, a third path, a fourth talent, a third talent on a tier B or C
  person, a gift with its own flaw, a talent family opposed to a held kept fate, or an unknown v2 id. A person outside
  the total band is not a failure (AC-NT-50).

**Timing, cost and determinism**

- **AC-NT-30** [Integration] Sect read timing. **GIVEN** a leader who gains Greedy in season s's events, **THEN** the
  sect's Tax uses the old pulls through season s and includes +1 from s + 1; a swap behaves the same.
- **AC-NT-31** [Logic] Determinism. **GIVEN** one seed twice, **THEN** every person's ids, expiries and targets hash
  equal; person 4,321 generated alone equals the same person in a full run; changing person 1 leaves person 2's roll
  unchanged; F2, F5 and F8 reproduce from their keys.
- **AC-NT-32** [Integration] Rule 21. **GIVEN** a season with 25 grants and 25 expiries, **THEN** at most 50 people are
  touched, at 5,000 and at 50,000 people.
- **AC-NT-33** [Integration] Performance (guess; no minimum-spec PC is set yet). **GIVEN** FX-W5K and FX-EV in a release
  export, **THEN** the three season steps take ≤ 2 ms median and ≤ 5 ms p99 over 200 seasons; 50,000 people take ≤ 1.25 ×
  the time of 5,000; creating 5,000 people ≤ 300 ms; 10,000 opinion reads ≤ 50 ms.
- **AC-NT-34** [Integration] Save size. **GIVEN** FX-W5K after 200 seasons of FX-EV, **THEN** every person has ≤ 8 ids,
  ≤ 2 expiries and ≤ 2 targets, and the world's trait data is ≤ 200 KB (a guess).
  **Amended 2026-11-25:** ≤ 18 ids, ≤ 3 talent tiers, ≤ 3 expiries, ≤ 1 coping refresh count and ≤ 2 targets per
  person; the world's trait data ≤ 400 KB (a guess: about twice the v1 ids at FX-W5K's mean of about 5.6 traits at
  creation, plus gained).

**World statistics** [Integration] (bands are guesses)

- **AC-NT-35** **GIVEN** FX-W5K, **THEN** people with ≥ 1 fate-given trait are 8.5–11.5 % and with 2 are 0.6–1.4 %; opposed
  personality pairs held together are exactly 0, and so are Heaven-favoured with Ill-starred; people with fewer than 3 personality traits ≤ 0.1 %; with uniform weights
  each personality trait is held by 7.0–9.3 %, and with default leans by 4–13 %; everyone holds exactly 1 calling.
  **Amended 2026-11-25:** with `p_any` 0.04, people with ≥ 1 fate-given trait are **3.0–5.0 %** and with 2 are
  **0.2–0.6 %**; no retired fate is ever drawn.
- **AC-NT-36** **GIVEN** FX-W5K after 200 seasons of FX-EV, **THEN** the gained-trait stock is 850–1,100 (λ · F = 1,000),
  people holding ≥ 1 are 15.5–20.5 %, and holding 2 are 1.0–2.8 %.

**Traits v2 (new, 2026-11-25)**

- **AC-NT-37** [Logic · BLOCKING] F1, doubled personality. **GIVEN** FX-D as amended, **THEN** Brave gives +4.0 %
  `khi_huyet_pct` and −1.6 pp `evade_pct`, Greedy +3.4 % and −1.6 %, Content −1.0 % `cultivation_speed_pct`; every one
  of the 74 personality rows equals exactly twice its v1 value; every calling row is unchanged (Strategist +1.2 pp
  `escape_pct`, −0.5 % `cultivation_speed_pct`).
- **AC-NT-38** [Config · BLOCKING] v2 catalogue load. **GIVEN** FX-V2, **THEN** it holds 80 traits (12 upbringing,
  12 talent families, 24 path, 14 lifestyle, 10 health, 8 coping); every row's key is a Live or Designed Stat List
  key or a talent key, F or I only; each talent family has exactly 3 tiers with talent adds ±6 / ±12 / ±20; every
  row equals the catalogue table's value; every likes and dislikes entry resolves to a v2 id or a v1 name; every
  hook is `event:`, `verb:`, `policy:`, `stance:` or `craft:`. **GIVEN** an entry with a `more` row, a Pending key or
  an unknown id in its likes, **THEN** the load rejects it and names the trait. *(2026-11-25:)* Hunter's `creature`
  scope is the one allowed Pending scope (rule 7).
- **AC-NT-39** [Logic · BLOCKING] F1b. **GIVEN** base comprehension 45 and `quick_minded` 3, **THEN** effective
  comprehension is 65, `cultivation_speed_pct` +6 %, and the grade shown is "Upper (base Middle, Genius +20)"
  (amended 2026-11-25; was Middle); **GIVEN** base 10 and
  `slow_witted` 3, **THEN** 1; **GIVEN** base 100, +40 of other flats and `quick_minded` 3, **THEN** 150 and the
  Breakdown shows the clip; **GIVEN** `comely` 2, **THEN** presence +12 and no other row.
- **AC-NT-40** [Logic · BLOCKING] Rule 2a caps. **WHEN** an API call gives a person a second upbringing, a third talent
  (a rolled or tier B/C person) or a fourth (anyone), a third path, a second lifestyle, a third health trait (Waning
  years excepted, below), or a second coping trait while a hardened one is held, **THEN** it is refused and logged.
  **GIVEN** `quick_minded`, **WHEN** `slow_witted` is added, **THEN** it is refused at creation and, by an event, never
  offered (talents are not event grants); **GIVEN** Spirit-eyed, **THEN** `keen_soul` is allowed and `thin_soul`
  refused; **GIVEN** `perfect_foundation`, **WHEN** an event grants `flawed_foundation`, **THEN** it replaces it.
- **AC-NT-41** [Logic · BLOCKING] F3 likes. **GIVEN** two Reclusive, Hermit-taught people with nothing else shared
  and no tie or sect term, **THEN** op = 20 each way; **GIVEN** a Street orphan and a Clan heir, **THEN** lk = −10 each
  way; **GIVEN** a Sect-raised person and a Loyal one, **THEN** lk(a → b) = +5 and lk(b → a) = 0 (directed);
  **GIVEN** two `quick_minded` holders at tiers 1 and 3, **THEN** lk = +5 each way (a family matches at any tier).
- **AC-NT-42** [Logic · BLOCKING] F4b. **GIVEN** an ordinary person with no fate and no inherited talent whose talent
  draw gives 1, **THEN** they hold exactly 6 traits and no path, health, lifestyle or coping draw is used; **GIVEN** a
  person with 1 fate-given trait, **THEN** no v2 optional draw lands; **GIVEN** a child with 1 fate-given trait and 2
  inherited families, **THEN** they hold all of them (8 traits) and no optional draw lands; every rolled person holds exactly 1 upbringing;
  the same seed gives the same traits, and person 4,321 rolled alone equals the same person in a full run.
- **AC-NT-43** [Integration · ADVISORY] F4b world statistics (bands are guesses around the 200,000-roll simulation).
  **GIVEN** FX-W5K, **THEN** (no known parents) people holding 5 traits at creation are 33–41 %, 6 are 58–66 %, 7 are ≤ 1 %; holders of a
  talent 21–27 %, a lifestyle 17–23 %, a path 6–11 %, a health trait 3.5–6.5 %, a coping trait 0.5–2 %; rolled tiers
  are 70 / 24 / 6 % ± 3 pp.
- **AC-NT-44** [Logic · BLOCKING] F5b. **GIVEN** both parents with `quick_minded` at tiers 3 and 2, **THEN** over
  100,000 keyed rolls the child holds tier 3 39 %, tier 2 26 %, none 35 % (± 1 pp); **GIVEN** one parent with
  `sturdy_frame` 1, **THEN** tier 1 15.75 %, tier 2 5.25 %, none 79 % (± 1 pp); **GIVEN** parents with `quick_minded`
  and `slow_witted` whose rolls both pass, **THEN** the child holds neither from inheritance; **GIVEN** three inherited
  families, **THEN** the two highest tiers are kept.
- **AC-NT-45** [Logic · BLOCKING] F6b, coping. **GIVEN** Drowns in wine granted in season 50 with one repeat in 60,
  **THEN** it is held in 79 and gone after 80's step 2; **GIVEN** repeats in 100, 110 and 120 after a grant in 90,
  **THEN** it is hardened at 120 and still held in season 1,000; a new coping trait is then refused and logged, and a
  deed removes the hardened one.
- **AC-NT-46** [Logic · BLOCKING] F6b, Waning years. **GIVEN** a 500-year lifespan, **WHEN** 50 years are left,
  **THEN** Waning years is granted at that season step, and with 2 health traits held it replaces the older one; **WHEN** a pill adds 20 years,
  **THEN** it is removed at the next step; a health trait never fades.
- **AC-NT-47** [Integration · BLOCKING] Rule 8a. **GIVEN** a #30 stub with records for `share_tea` (side either),
  `haggle` (self) and `ask_history` (other), **THEN** a Tea-master player sees share tea with anyone, a plain player
  sees it only with a Tea master; a Merchant's-child player sees haggle with anyone, a plain player never does; a
  Chronicler player sees ask about history only with another Chronicler. **GIVEN** every event template and 1,000
  keyed v2 trait sets, **THEN** the player's options are a superset of those with no v2 traits (AC-NT-09 extended).
  **GIVEN** a hook id with no consumer record, **THEN** nothing is added and the lint lists it.
- **AC-NT-48** [Config · BLOCKING] Rule 7a. **GIVEN** a catalogue row carrying any field besides stat, value and
  scope, or a scope naming a ground, terrain, biome, weather, place, time or season tag, **THEN** the load rejects it
  and names the trait; **GIVEN** FX-V2, **THEN** no row does.
- **AC-NT-49** [Integration · BLOCKING] Retired fates. **GIVEN** a save or authored record holding Wise-born,
  Iron-boned, Heaven-favoured, Ill-starred, Dull-witted or Frail, **THEN** it loads as `quick_minded` 3,
  `sturdy_frame` 3, `lucky` 3, `unlucky` 3, `slow_witted` 3 or `frail_frame` 1, with that family's tier rows and none
  of the v1 rows; a person already holding the family keeps the higher tier; over 100,000 F4 rolls no retired id is
  drawn.
- **AC-NT-50** [Config · ADVISORY] Authoring lint (amended 2026-11-25). **GIVEN** the authored cast, **THEN** every
  person below the band floor (tier A 6–12, B 5–8, C 4–6) and every tier A person with no talent is listed, and the
  world still loads; `depth_check.py` prints the over-band count as an observation, never a finding (today: 4 A,
  20 B, 6 C over band, 0 under; 2 tier A without a talent).
- **AC-NT-51** [Logic · BLOCKING] Rule 8 (amended 2026-11-25). **GIVEN** any v2 trait other than the 15 of rule 8
  (every talent and health trait included), **THEN** its F2 weight is 1.0 on every tag and it counts neither with nor
  against in F7; a person's F2 weights with and without those traits are identical. **GIVEN** Demonic path and a
  choice tagged only `aggressive`, **THEN** the trait multiplies its weight by 1.5 and counts **with** in F7; tagged
  only `merciful`, by 0.67 and **against**. **GIVEN** FX-V2, **THEN** exactly 15 v2 entries carry `tags`, each with
  1–3 tags from the vocabulary and values 1.5 or 0.67 only, matching the catalogue's § Choice-tag weights of v2 traits.
- **AC-NT-52** [Integration · ADVISORY] F3 drift. **GIVEN** 100,000 keyed pairs in FX-W5K, **THEN** the mean lk term is
  between −3 and +3 (a guess; it checks l_v against d_v).
- **AC-NT-53** [Config · BLOCKING] Rule 2a trim (new, 2026-11-25). **GIVEN** the authored cast, **WHEN** the export
  runs, **THEN** no exported person is above their band's top (tier A 12, B 8, C 6); every exported person keeps their
  3 personality traits, calling, upbringing and (tier A) at least one talent; each dropped trait is in the export
  report with its person; the depth pages are unchanged. **GIVEN** a tier B person with 10 traits whose backstory
  names their lifestyle but not their coping or gained trait, **THEN** the gained and the coping trait are dropped and
  the lifestyle kept. **GIVEN** the same cast exported twice, **THEN** the same traits are dropped.
- **AC-NT-54** [Logic · BLOCKING] Rule 7 scoped rows (new, 2026-11-25). **GIVEN** a Hunter fighting a foe with no foe
  tag, **THEN** Hunter adds 0 to `attack_pct`; **GIVEN** a foe tagged `creature`, **THEN** +2 %. **GIVEN** One-element
  devotee on a root Fire 70, Wood 20, **THEN** the compiled row is `attack_pct` +6 [hoa] and a Water art gets nothing
  from it; **GIVEN** a tie Fire 40, Metal 40, **THEN** [kim]; **GIVEN** a pure Wind root, **THEN** no row.

## Open Questions

User direction, 2026-11-10 and 2026-11-14: traits work like the character traits of grand-strategy games; they decide how
people act around events and lightly affect stats; leaders' personalities drive sect policy (Sects). Decided 2026-11-14:
NPCs and the player both have traits; four kinds; all kinds carry stats; gained traits fade; opinion is computed; weighted
roll with inheritance and teaching; 18 sets; fate-given named bẩm sinh; talents only at notable; one stored target per
gained trait. Decided 2026-11-25 (world-depth rulings, groups 1 and 5): ten kinds (rule 2a); talent tiers replace the
plain fate gifts; personality rows doubled; `opens`, with dialogue verbs first; likes and dislikes; no environment
conditions ("talents only at notable" now binds the v1 kinds only).

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | ~~The full catalogue~~ **Answered 2026-11-14:** `design/gdd/npc-traits-catalogue.md` (37 personality, 14 callings, 10 fate-given, 16 gained); its own open items cover leans, trigger ids and world-price events | user, game-designer | — |
| 2 | The final choice-tag vocabulary; an interim list stands in Core Rules, and the Event Engine (#23), which has no GDD, owns the final one | game-designer | F2 beyond FX-CAT, AC-NT-09 |
| 3 | The event budget's unit for granting a gained trait (Event Engine) | systems-designer | rule 11 |
| 4 | Origin questions that set the player's 3 personality traits (Game UI and origins) | user | AC-NT-25 |
| 5 | The world grant rate λ (about 25 a season) depends on event volume, unknown until the Event Engine is designed | systems-designer | AC-NT-36 |
| 6 | A minimum-spec PC and frame budget for AC-NT-33 (`project.yaml` has none) | technical-director | AC-NT-33 |
| 7 | Whether opinion s and o should differ (o > s makes the world quarrelsome) | user | F3 |
| 8 | Grudge (targeted gained trait, `target` −50) against an NPC Relationships enmity tie toward the same person: no-stack for now (F3 takes the more negative), or retire Grudge in favour of the tie (`npc-relationships.md` OQ 2) | user | F3 |
| 9 | **Answered 2026-11-25** (ruling group 11): Frail is `frail_frame` tier 1 and Dull-witted is `slow_witted` tier 3. **Still open:** the compensating-boon question below. ~~**(new, 2026-11-25)** Tiers for the two retired flaws the ruling left open: Dull-witted → `slow_witted` 3 and Frail → `frail_frame` 1 are chosen by name (guess).~~ And should a retired flaw keep its v1 compensating boon (Ill-starred T +5.3 %, Dull-witted Dt +2.66, Frail Ng +1.60)? Dropped for now | user | Trait list, AC-NT-49 |
| 10 | **Answered 2026-11-25** (ruling group 11): the tier is Empty-souled (hồn rỗng). ~~**(new, 2026-11-25)** `thin_soul` tier 3 was named "Hollow-souled", the same name as the kept v1 fate (hồn khuyết). The catalogue renames the tier "Empty-souled" (hồn rỗng, its own Hán-Việt name); confirm~~ | user | catalogue |
| 11 | **Answered 2026-11-25** (ruling group 11): like +5, dislike −10 (F3). **Still open:** whether v1 personality traits get likes lists too. ~~**(new, 2026-11-25)** Likes 5 and dislikes 10 (F3) balance the catalogue's 77 likes against 39 dislikes; a world where likes and dislikes weigh the same would drift friendly. Confirm the values~~, and whether v1 personality traits should get likes lists too | user, systems-designer | F3, AC-NT-52 |
| 12 | **Answered 2026-11-25** (ruling group 12): Hunter becomes `attack_pct` +2 scoped to the foe tag `creature`, inert until Combat stamps that tag (rule 7, AC-NT-54). ~~**(new, 2026-11-25)** Hunter's `attack_pct` [beast] uses the Designed form tag (beast-form arts); the meaning ("hunts spirit beasts") wants the Pending foe tag `creature`. Move it when the foe tag goes live, or change the row~~ | game-designer | — |
| 13 | **Answered 2026-11-25** (ruling group 11): callings stay not doubled. ~~**(new, 2026-11-25)** Callings were not doubled (the ruling named personality rows only), so a calling row is now half a personality row. Double them too?~~ | user | F1 |
| 14 | **Answered 2026-11-25** (ruling group 12) for the bands: tier A widens to 6–12, and people above 12 and over-band tier B and C people are trimmed at export, weakest-fitting extras first (rule 2a, AC-NT-53; today 4 A, 20 B, 6 C, 36 traits). The 3-path person is fixed (`depth_check.py` reports no path finding on 2026-11-25). **Still open:** 2 tier A people hold no talent (an authoring lint line); 6 retired fate ids map on load. ~~**(new, 2026-11-25)** The authored cast before export: one person in `sects/bang_tam.cast.json` holds 3 paths (a load failure); 18 tier A, 20 tier B and 6 tier C people exceed their bands (tier A up to 13); 2 tier A people hold no talent; 6 retired fate ids map on load~~ | World Generation writer | AC-NT-50 |
| 15 | **(new, 2026-11-25)** Each `opens` hook needs its consumer's record: 19 verbs (#30: requirements, score `b_v`, cooldown, line keys, and the side proposed in the catalogue), 54 event tags (#23 templates), 4 policy hooks (Sects F15, mapping proposed in the catalogue), 4 duel stances (Combat duels), 8 craft edges (what an edge gives, in each craft's GDD) | game-designer per consumer; #30 first | rule 8a, AC-NT-47 |
| 16 | **Answered 2026-11-25** (ruling group 12): the card shows the effective grade with the base beside it, "Upper (base Middle, Genius +20)" (Character Stats rule 5 as amended; the ruling's example said "Superior", which is this game's Upper, Thượng; above 100 reads Heavenly). ~~**(new, 2026-11-25)** A talent tier is a flat modifier, so the grade shown stays the base's (a Genius with base 45 shows Middle). Should the person card show the effective value's grade beside it?~~ | user, ux-designer | — |
| 17 | **Answered 2026-11-25** (ruling group 11): health 0–1 at creation, at most 2 (a second only by event; Waning years takes a slot). ~~**(new, 2026-11-25)** The task and `traits-v2.md` give health 0-1; `traits-v2.json` says "0-1 (rarely 2)". This amendment allows a second only by event, and Waning years takes a slot (replacing the older trait when both are full). Confirm~~ | user | rule 2a |
| 18 | **Answered 2026-11-25** (ruling group 12): 15 behaviour-shaping v2 traits (4 paths, 3 lifestyles, 6 coping, 2 upbringings) carry choice-tag weights at 1.5 / 0.67; talents and health stay stat-only (rule 8; catalogue § Choice-tag weights of v2 traits; AC-NT-51). The values are guesses. ~~**(new, 2026-11-25)** v2 traits carry no choice-tag weights, so they do not move NPC choices or F7. Should some (Demonic path, Buddha's path, Vow of vengeance, Rage flares) get tag weights?~~ | game-designer | — |
| 19 | **Answered 2026-11-25** (ruling group 11): the three opposed path pairs stand. ~~**(new, 2026-11-25)** The three opposed path pairs (foundation, demonic/Buddhist, frost/fire) are this amendment's own reading of the catalogue, not in the proposal. Confirm or extend~~ | user | rule 2a |
| 20 | **Answered 2026-11-25** (ruling group 11): `n_create_max` stays 6: an ordinary person holds ≤ 6 traits at creation. ~~**(new, 2026-11-25)** `n_create_max` 6 leaves an ordinary rolled person room for one optional trait, so a second talent or a lifestyle beside a talent occurs only in authored people. Raise to 7 (band 5–7)?~~ | user | F4b, AC-NT-43 |
| 21 | **(new, 2026-11-25)** All F4b, F5b and F6b odds are guesses; set the upbringing leans `m_birth`, `m_family` and any sect-lineage lean on paths (World Generation #27) before the first world census | systems-designer, World Generation | AC-NT-43 |
| 22 | **Answered 2026-11-25** (ruling group 12): One-element devotee becomes `attack_pct` +6 scoped to `own_top_element`, resolved at compile to the holder's highest-purity base element (ties Kim, Mộc, Thủy, Hỏa, Thổ; none for a root without a base element; rule 7, AC-NT-54). ~~**(new, 2026-11-25)** One-element devotee's `element_affinity_pct` row targets artifacts (Modifier System); the meaning reads as the person's own element. Keep it, or swap for an element-scoped `attack_pct`~~ | game-designer | — |
| 23 | **(new, 2026-11-25)** The ruling says "drop the weakest-fitting extras" without a measure. Rule 2a reads it as: not named in the backstory first, then by kind (gained, coping, lifestyle, fate-given, path, talent, health), then by id, never personality, calling, upbringing or a tier A person's last talent. Confirm the order, or have the export use another fit (the sect's leans, the person's ties). `export_world.py` must implement it | user; tools-programmer | AC-NT-53 |
| 24 | **(new, 2026-11-25)** Rule 7's two scoped rows need the Modifier System: the foe scope `creature` stays Pending until Combat stamps it (Hunter is inert until then), and `own_top_element` is a new placeholder scope resolved at compile, which `modifiers.md` does not list yet (back-link owed) | Modifier System, Combat | AC-NT-54 |

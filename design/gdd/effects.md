# Effects System (Hiệu Ứng)

> **Status**: Revised 2026-11-09 for the Combat economy revision (#44), part 3: element stacks (rule 9a, Formulas D), Burn and Poison become Fire's and Wood's debuffs, Frostbite and Shock retire, no tick or burn caps, overflow readable (decisions in `design/research/economy-revision-44-decisions.md`). Earlier: designed 2026-11-08; `/design-review` 2026-11-08 overnight (lean, passes 1–4): NEEDS REVISION; revised 2026-11-08 with the user's answers; daytime re-review 2026-11-08 (lean, three passes): NEEDS REVISION, see `reviews/effects-review-log.md`; revised the same day with the user's answers to all 24 items (more reads and actions; the qi-tick path; last acts resolve requesting side first and win only on overkill). Second re-review 2026-11-08b: NEEDS REVISION; its fixes and the user's answers applied the same day (`reviews/rereview-2026-11-08b/effects.md`)
> **Author**: user + agents
> **Last Updated**: 2026-11-10 (re-review fixes: tick-cap text, Shock AC, stack lint horizon and rounding, cleansing ward owner, Spiritual Roots dependency). Earlier: 2026-11-09 (#44 part 3). Earlier: 2026-11-08 (second re-review 2026-11-08b applied; see `reviews/rereview-2026-11-08b/effects.md`)
> **Last Verified**: 2026-11-08
> **Implements Pillar**: Your Dao, Your Name (1); Power Is Built, Not Given (3); Every Number Is Bounded and Visible (2)
> **Scope**: Every build piece with a rule in it: conditions, scaling, triggers, conditional conversion, overflow, rule changes, keystones and enablers. An Effect usually grants Modifier System modifiers (`design/gdd/modifiers.md`) as its payload (user decision 2026-11-07). Plain numbers on a stat are Modifiers, not Effects; so is a plain conversion share (`convert_pct`, user decision 2026-11-08).
> **Reference only**: Part 2 of `design/quick-specs/modifier-inventory.md` (361 effect candidates, mostly from the overnight run). This GDD is designed from scratch and adopts only what passes its rules.

## Summary

The Effects System holds every build piece with a rule in it: conditions, scaling, triggers, conversion, rule
changes, statuses, keystones and enablers. Each Effect is hand-designed as one plain sentence, usually granting
Modifier System modifiers as its payload, and works only through the engine's listed reads and actions under
Combat's limits. Effects give builds their identity and stay unpriced until the end-of-project balance pass.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Modifier System, Combat, Combat Defence & Healing, Combat Damage Types`

## Overview

An **Effect** is any build piece with a rule in it. "+12 % sword damage while your linh lực is above
half", "when you crit, your other arts' timers shorten by 0.5 s", "your basic attack carries your root's
element", "once a fight, a killing blow leaves you at 1 health": each is an Effect. Most Effects grant
plain modifiers from the Modifier System as their payload; some change a rule outright. Keystones (strong
rules that close something off) and enablers (the piece a build is built on) are Effects too, and so are
statuses, the burns, poisons and curses placed on a target.

Every Effect is hand-designed (user decision 2026-11-07): it has its own one-sentence rule, its own limits
and, for keystones and enablers, what it closes. There is no composing grammar and no price yet. Effects
are balanced once the game is finished. What this system fixes is the shape every Effect must take: the
record, what an Effect may read and do, the limits the engine enforces on all of them, and the rules for the
hard cases, such as costs that outlive the fight, what happens at Down, counted chance and statuses with
no end.

Effects are where builds get their identity (Pillar 1). Modifiers make a build bigger; Effects make it
different.

## Detailed Design

### Core Rules

> `game-designer` and `systems-designer` not consulted for this section — Lean mode. Review manually before production.

**What an Effect is**

1. **An Effect is a hand-designed rule piece** (user decision 2026-11-07). Each one is authored on its own, with
   no shared grammar. Every Effect record nonetheless states the same fields, so the engine, the Breakdown and
   NPC Builds can handle it:

   | Field | Meaning |
   |---|---|
   | `id`, name | English name with Hán-Việt, e.g. Flowing Water (Lưu Thủy) |
   | `kind` | One of the kinds in rule 2. Descriptive, for designers and filters |
   | `rule` | One plain sentence the player reads. It is the specification |
   | `reads` | What it looks at, from the readable list (rule 5), each with its read time: compile, instant start or live (events need none) |
   | `payload` | Catalogue modifiers (Modifier System) and/or actions (rule 6) |
   | `limits` | How often and how much: per pulse, per fight, cooldown, caps |
   | `closes` | Keystones and enablers only: what it forbids or costs |
   | `domain`, `tags` | Classification tags from the shared vocabulary (Modifier System rule 9), plus its kind |
   | `hosts` | Which sources may carry it (rule 13). `affix` (a rolled affix) is a host value; enablers may never list it |
   | `npc` | `true` if NPC Builds may use it (rule 15) |
   | `tier` | `minor`, `major`, `keystone` or `enabler` (rule 4): a rough size set by eye, so hosts can bound how much a build holds |
   | `price` | `unpriced` until the end-of-game balance pass (user decision 2026-11-07) |

2. **Kinds describe an Effect; they do not build it.**

   | Kind | It… | Example |
   |---|---|---|
   | Conditional | grants its payload while something holds | +12 % sword damage while linh lực is above 50 % |
   | Scaling | grows with a count, to a cap | +2 % damage per empty art slot, to +12 % |
   | Trigger | does something when an event happens | on a crit, your other arts' timers shorten by 0.5 s |
   | Conversion | changes a part's damage type or tags, or counts one quantity as another, with a condition or a rule; a plain share converted is the `convert_pct` modifier | while your formation is prepared, half your formation power counts as ward strength |
   | Overflow | uses what a cap clipped | tick damage the cap clips burns the target's linh lực |
   | Rule change | changes a rule outright | your basic attack carries your root's element |
   | Status | is placed on a target: a tick or a curse | Burn, Poison, Weaken (rule 9) |
   | Keystone | a strong rule paid for by what it closes | no ward ever; +large body shield |
   | Enabler | opens a channel, rule or resource and closes something | arts may be paid in spirit stones; linh lực pays for nothing |

3. **Modifier or Effect.** If a piece is a plain number on one stat, optionally narrowed by tags, it is a
   modifier (Modifier System), never an Effect. Anything with a condition, a count, an event or a rule is an
   Effect. An unconditional "+X" inside an Effect must use a stat from the Modifier System's Stat List, with an
   operation that stat allows. While Effects are unpriced (rule 4) its value is the designer's, not a
   catalogue grade; the balance pass prices it with the rest of the Effect.

4. **Effects are unpriced for now, but every Effect has a tier** (user decisions 2026-11-07 and 2026-11-08). An
   Effect carries `price: unpriced`: no W value, no price check, no budget. Its value depends too much on the
   build around it for one price to be right. Instead every Effect carries a **tier**, a rough size a designer
   sets by eye:

   | Tier | Meaning | Typical host slot |
   |---|---|---|
   | `minor` | A small edge that helps a build it fits | a Way node, a technique's lesser art, an item affix line on a named item |
   | `major` | Changes how a build plays or what it is good at | a Way branch node, a technique's main art, a named artifact |
   | `keystone` | A strong rule paid for by what it closes (rule 14) | a tree keystone, a Way capstone |
   | `enabler` | The piece a build is built on, opening and closing something (rule 14) | a named artifact, a technique, a Way capstone |

   Each host GDD says how many Effects of each tier its slots hold, so the total power a build carries stays
   bounded without valuing anything exactly. Engine limits (rule 7) still apply, because they keep fights finite
   and readable. The end-of-project balance pass measures Effects with the harness (Open Questions 1).

**What an Effect may read and do**

5. **Readable quantities.** An Effect may read only what the engine exposes. Today's list is drawn from the
   inventory's conditions:
   - **in a fight:** own and enemy health and linh lực (as shares); shields and their state; fight time;
     pulses; events this fight (hits, crits, evades, kills, firings, statuses applied); slots and loadout;
     the hit's damage type, element and tags; the realm gap; preparation and ground tags; foreseen or blind;
   - **from the sheet, read at compile:** owned stats; attributes (thiên phú); heart demon (tâm ma) and
     toxicity (đan độc); craft levels; root purity; lifespan and age; free thần thức (thần thức minus what
     artifacts bind); carried spirit stones; the strongest companion's power share;
   - **added with the starter catalogue** (user decision 2026-11-07): health restored to the side this fight; the
     number of distinct statuses of the side's own on the target; the event "a shield breaks";
   - **added with the review** (user decision 2026-11-08): **a named cap's clipped amount** (an event, one per
     named cap: `cooldown_min`, a layer cap and the others an Effect names; the regeneration and tick caps are gone
     with #44);
     **ward payments made against your hits** (an event: the linh lực the enemy's wards pay when your hit
     meets them); **a status's stack count on the target** (live);
   - **added with the Combat economy revision** (#44, 2026-11-09): **element stack counts** on either side, by
     element and by buff or debuff (live); **overflow**, the linh lực regeneration and gain lost to a full pool
     (an event each pulse it happens; it replaces "regeneration clip"); **the share of linh lực remaining** is
     already readable as own linh lực;
   - **added with the re-review** (user decision 2026-11-08, re-review EF 1): sheet reads at compile: **your main
     root's element**, **your formation's level**, **your cultivation base and stage**, **an art's authored
     record** (cooldown, cost, parts); events: **the Down step** (step 1 and step 2), **a failed brew**, **a death in
     an event**; and, live, **the chance about to be rolled** (read at each would-be roll, for counted chance);
   - **in life:** the season, the place, the sect, and the World DB facts the Event Engine exposes.

   An Effect that needs something not on the list asks for an engine addition first; the list is extended in
   this GDD. Each read says *when* it is read: at compile (fixed for the fight), at the start of each instant
   (Combat rule 10's guard time), or live. Events need no read time: they are read when they happen. Sheet
   reads are always compile, except the chance about to be rolled, and a conditional's condition is always instant
   start (rule 8).

6. **Actions.** Besides granting modifiers, an Effect may use only the engine's actions:

   | Action | Owner |
   |---|---|
   | Free hit | Combat Formulas G (`c_trig`, trigger budget) |
   | Apply or cleanse a status | this GDD (rule 9); Combat Formulas F |
   | Restore health, linh lực or a body shield | Combat Defence & Healing rules 16–19. Restores of health and body shields count as healing; a linh lực restore does not, and is clipped at the usable maximum (Combat Defence & Healing rule 10; re-review EF 20) |
   | Refund an art's cost, up to that cost | Combat rule 9 |
   | Waive an art's cost: the art fires without the cost in the pool, and nothing is paid (re-review EF 6) | Combat rule 9 |
   | Burn linh lực: take linh lực off the target, with no cap (`qi_burn_cap` removed, user decision 2026-11-09, #44) | this GDD; Combat Formulas F |
   | Grant element stacks: a number of buff stacks of an element to its owner, or debuff stacks to the target, for a duration or for the fight (rule 9a) | this GDD |
   | Cleanse element stacks: a number of debuff stacks, oldest first; a share of every debuff batch; or every debuff stack of one element (rule 9a) | this GDD |
   | Enforce a closing rule at compile: the `closes` of a keystone or enabler, applied for the whole fight (or, for a life Effect, while it holds). It may forbid (a ward, a slot kind, a companion, regeneration), set Combat Defence & Healing's `cannot_slot_wards` and `no_default_ward` flags, lower an owner's cap (Called Blow's crit cap), scale a named cost or pool (Formation Within a Formation's upkeep, Glass Meridians' body shields), or set a shared floor (Blood Casting with Withering) (re-review EF 2; 2026-11-08b EF-02) | the rule's owner |
   | Convert a share of a hit, under a condition (a plain share is `convert_pct`; none in the starter set yet) | Combat Damage Types rule 6 |
   | Reserve linh lực | Combat Defence & Healing rule 10 |
   | Raise or lower a ward, or change its payload while a condition holds | Combat Defence & Healing rules 5–9 |
   | Move a timer: shorten your own, or delay the enemy's | Combat rule 13. An art's next firing is never sooner than `cooldown_min` after its last |
   | Pay an art's cost in health (not damage, so nothing reduces it; it can put the side Down, and the Down step, refusals included, then runs as usual) | this GDD; it is neither damage nor healing |
   | Pay art and ward costs from carried spirit stones, reported after the fight | this GDD; rule 10 |
   | Report a life cost (rule 10) | this GDD; the caller applies it |
   | Add a tag to an art or its hits, for modifier scopes only (never defence) | Combat rule 6; Modifier System rule 8 |
   | Add a slot of a named kind (an art slot that takes only one kind of piece) | Combat Formulas A2 |
   | Skip a roll (evade, crit or a status chance): the roll is not drawn and its result is fixed | Combat rule 15; Combat Formulas C, I |
   | Multiply a sheet share by a fixed factor, read at compile and clipped by its owner's cap | the share's owner (e.g. Combat Formulas J `c_comp_cap`) |
   | Fire an art as a last act, at Down step 2 | rule 11; Combat rule 9 |
   | Raise a host's cap by a fixed amount (a formation's maximum level, a stack cap) | the cap's owner |
   | Change a life output (what a brew, a refinement or an event yields, including an event's outcome such as surviving a death) on the seeded life stream | the output's owner (Alchemy, Artifact Refining, Event Engine) |
   | Refuse Down, at Down step 1 | rule 11 |
   | Count a chance on a meter instead of rolling it (keystones only) | rule 12, Formulas A |

   The list is closed (user decision 2026-11-08). A new action is an engine addition, added here before any
   Effect uses it.

7. **Engine limits apply to every Effect.**
   - **Triggers:** Combat rule 9 and Formulas G: a fixed resolution order, chain depth 2, at most 6 firings per
     side between pulses, and trigger damage inside Formulas G's trigger budget (floor included; Combat owns
     the numbers). A trigger never fires itself twice in one chain.
   - **Caps** stay with their owners: layer caps, crit, evade and resistance caps, the
     reservation cap (the heal and tick caps were removed by #44). An Effect's modifiers are clipped like any others.
   - **Determinism:** every chance uses the fight's seeded stream (Combat rule 15). A chance of 0 or 1 draws
     nothing.
   - **Readability:** every Effect that applies, fires or is clipped writes a Breakdown line with its name and
     what it did (Combat rule 16).
   - **Ties go to slot order** (re-review EF 11): when an Effect picks "the longest cooldown", "the least time left"
     or "the next ready art" and two arts tie, the one in the earlier slot is picked.

8. **When an Effect applies.**
   - A **conditional** Effect's condition is read at the start of each instant, as Combat reads guards; its
     payload applies for that whole instant.
   - A **scaling** Effect's count is read when its `reads` says (compile, instant start or live), and its cap
     is part of its record.
   - A **trigger** resolves right after the event that set it off, in Combat rule 9's order.
   - **Life effects** (outside fights) resolve when the Event Engine or the season tick reaches them.

**Statuses**

9. **This system owns the status catalogue** (user decision 2026-11-07). A status is an Effect placed on a
   target by an art, a trigger, a talisman or the ground. Combat keeps the formulas and caps (Combat rules 7–8,
   Formulas F). Each status record states:
   - its **damage type** if it ticks (Combat Damage Types rule 1) or the rule it changes if it is a curse;
   - its **strength** (`c_tick` for a tick, or the curse's number), only where the status has a number: a lock or a
     block such as Sealed Meridian or Silence has none (re-review EF 4); its **duration** in pulses; and
     its **stacking**: refresh, stack to a cap, the stronger wins, or **none**, where a recast does nothing while it
     runs (re-review EF 12). A recast refreshes unless the record says otherwise;
   - its **cleanse tags**;
   - its **tags** (re-review EF 22, with Modifier System item 4): its status tag (`burn`, `qi_disruption` and the
     rest, the Modifier System's status family), its mode (`over_time` for a tick, `curse` for a curse), its damage
     type for a tick, and any effect tag (`poison`). Modifier scopes read these (Modifier System rule 8).

   **A status may have no duration** (user decision 2026-11-07; overnight decision 11) only if its caster pays a
   standing cost every pulse while it runs and a cleanse can clear it. It ends if the caster cannot pay.

9a. **Element stacks** (user decisions 2026-11-09, Combat economy revision #44). Each element has a **buff**, held
    by its owner, and a **debuff**, placed on a foe, counted in stacks:

    | Element | Buff, per stack | Debuff, per stack |
    |---|---|---|
    | Fire (Hỏa) | +1.2 % damage dealt | **Burn**: Fire damage each pulse, `c_tick` 0.019 per stack (Status Catalogue) |
    | Water (Thủy) | +0.5 % maximum linh lực, +0.025 pp linh lực regeneration | — (Ice carries the pair's debuff) |
    | Earth (Thổ) | Physical damage taken **1.1 % dampened** (Modifier System rule 6a; no cap) | −1.2 pp accuracy |
    | Metal (Kim) | +1.2 % Physical damage dealt | +1.8 % Physical damage taken |
    | Wood (Mộc) | +0.1 pp health regeneration | **Poison**: Chaos damage each pulse, `c_tick` 0.019 per stack (Status Catalogue) |
    | Ice (Băng) | — (Water carries the pair's buff) | +3.9 % art cost |
    | Thunder (Lôi) | +0.7 pp accuracy, +0.35 pp crit chance | +1.2 pp crit chance and +5 % crit damage taken |
    | Wind (Phong) | +7.5 % art speed (meets `cooldown_min` after a few stacks; to become dampen-shaped) | −1.2 pp evade |

    **Equal value** (user decision 2026-11-10): every element's buff is worth about the same, and every debuff about
    the same, against the typical foe; the numbers above were fitted to that (Formulas D). Matchups still differ on
    purpose: Earth resists Physical only, accuracy and evade stacks need a foe with evade, Ice hurts costly kits most.

    - **Two separate tracks.** A side may carry buff stacks, debuff stacks, both or neither. Chaos (Hỗn Độn), Light
      (Quang) and Darkness (Ám) have no stacks; Void and Blood are archived (Spiritual Roots).
    - **Batches.** Each grant is a batch with its own timer: the source (an art record, an Effect, an item) says how
      many stacks and for how long, or "for the fight". Batches never merge or refresh one another. A side's count
      for an element is the sum of its live batches.
    - **No cap** on stacks (user decision). Global caps still hold: crit chance, the resistance cap, the evade cap.
      Curse caps do not apply to stacks, so Ice stacks raise art cost past Heavy Breath's +50 %.
    - **Which element.** A stack belongs to its source's element tag (Kim, Mộc, Thủy, Hỏa, Thổ, Băng, Lôi, Phong),
      never to the damage type, so a converted hit builds the stacks of the art's element.
    - **Purity powers stacks:** every stack's effect is multiplied by `(1 + 0.002 × P)`, P the owner's purity in
      that element, uncapped, with Water and Ice sharing half (Spiritual Roots rule 8a, Formulas H).
    - **Debuff ticks are the applier's damage.** Burn and Poison use the applier's values from when each batch was
      applied (Combat Formulas F), so the applier's damage increases count.
    - **Cleansing is the answer to a pile** (user decision). A **cleansing ward** removes a share of every debuff
      batch on its side each pulse (`cleanse_share`, Formulas D). A cleanse art or Effect removes a number of debuff
      stacks, oldest first; rare ones remove every debuff stack of one element.
    - **Arts pay for the stacks they grant** in the art lint (Formulas D). Effects stay unpriced (rule 4).
    - **Enemies, beasts and tribulations** use the same rules; a tribulation may forbid cleansing in its own rules.
    - **Linh lực for every element** comes from keystones in each element's tree, not from stacks (user decision
      2026-11-09; Meridian Map content pass).

**The hard cases**

10. **Costs that outlive the fight are reported, never applied in the fight** (user decision 2026-11-07;
    overnight decision 4). An Effect may spend or raise heart demon, lifespan years, seasons, toxicity, spirit
    stones, root purity, cultivation base or stage (re-review EF 9). The values it reads are taken before the fight. The fight's result reports every
    such cost or gain, as it already reports vitality, and the caller applies it afterwards (Combat rule 14).
    Kills still add no heart demon unless an Effect says so.

11. **Down has one defined step** (user decision 2026-11-07; overnight decision 5). At the defeat check
    (Combat rule 10), after all of the instant's damage:
    1. **Refusals.** Each side's Effects that refuse Down (for example "once a fight, a killing blow leaves you
       at 1 health") are checked in that side's slot order, and the first unspent one saves it: health is set to
       1 and that Effect is Spent. Each refusal works once per fight, and at most one fires per Down, so a side
       holding two refusals can survive two separate Downs. A side saved by one is not Down. A refusal is not healing: it works under `no_heal`
       (Combat Defence & Healing rule 19).
    2. **Last acts.** For a side still Down, its Effects that act at Down (a final art, a parting curse) resolve
       once, then the side is Down. Their damage enters a follow-up check. The side making the last act cannot
       refuse a second time; a side the last act puts Down runs this step as usual, refusal included.
    3. **Wounds that run on** (a ledger of deferred damage, a curse that outlives its caster) are not resolved
       in the fight. They are reported in the result, and the caller applies them (rule 10).

    If both sides are saved, both are at 1 and the fight goes on. If both fall, Combat rule 10's overkill and
    draw rules decide as usual.

    **Order and overkill** (user decision 2026-11-08, re-review EF 7): when both sides reach this step in one
    instant, the requesting side (the side that opened the fight, Combat rule 10) resolves first, each side's
    Effects and draws in its slot order. A Down side keeps its overkill for the follow-up check, so a last act that
    downs the enemy wins the fight only if the enemy's overkill share is larger than its own. A last act's damage
    counts toward its target's overkill for the instant (Combat Formulas C), whether or not the target is already
    Down (user decision 2026-11-08b, EF-05), so a last act can swing a double knockout. Equal shares within
    `overkill_epsilon` are a draw.

12. **Counted chance is a keystone rule** (user decision 2026-11-07; overnight decision 9). A keystone may turn
    one of its owner's chances (crit, evade, a status chance) into a **count**:
    - each time the chance would be rolled, its probability is added to a visible meter instead;
    - when the meter reaches 1, the event happens and 1 is taken off.

    No seeded draw is used, so a counted build is deterministic. Fortune does not shift counted chance. Only a
    keystone may grant it, and only one chance per keystone.

**Keystones, enablers and hosts**

13. **Who may carry Effects.** Hosts are set per Effect, from:
    - the Meridian Map (keystones; its 25 live capabilities are re-expressed in this catalogue: those with a
      real closing cost as keystones, the rest as rule changes or another kind, user decision 2026-11-07;
      re-review EF 8);
    - the Way (Đạo): nodes, branches and capstones;
    - cultivation techniques and their arts;
    - items: named artifacts, treasures, talismans, pills;
    - formations and ground;
    - spirit beasts;
    - progression edges and spiritual roots;
    - statuses (on the target).

    A keystone is exclusive with any keystone its host marks as rival. An enabler is a named piece (an
    artifact, a technique, a keystone or a Way capstone), never a rolled affix.

14. **Keystones and enablers state what they close.** Their `closes` field is part of the rule and shows in the
    tooltip: "You can never use a ward" is read by the player before "+large body shield". A keystone or enabler
    without a real closing cost is rejected in review. A cost in `closes` that is a plain number on a Stat List stat is
    granted as a payload modifier at compile, using that stat's allowed operation: Unyielding Breath `khi_huyet_pct`
    −15, Glass Meridians `khi_huyet_pct` −25, Heart Demon's Blade `qi_deviation_pct` +100. A close that is a report
    uses rule 10, and every other close uses the closing-rule action.

15. **NPCs and the LLM Game Master.** NPC Builds may use any Effect whose record marks it `npc: true`, under the
    same rules. The LLM Game Master never creates an Effect and, while Effects are unpriced, never grants one;
    it may grant modifiers only (Modifier System rule 16).

### Status Catalogue

> Drafted by `game-designer` 2026-11-07; inserted as drafted (user decision). Bounds are Combat Formulas F:
> `c_tick` 0.15–0.5 per stack, duration 2–6 pulses, stack cap 5, the lint `c_tick · duration ≤ 1.2 · c_art`,
> at most 3 curses of at most 5 pulses. Since #44 (2026-11-09) ticks have no cap per tick or per pulse, and Burn and
> Poison are element debuffs, **exempt** from the `c_tick` range, the stack cap and the duration lint above (Formulas D's charge prices them instead; rule 9a): batches with no stack cap, `c_tick` 0.019 per stack, priced by Formulas D.

**Ticks**

| Status | Damage type | Strength | Duration | Stacking | Cleanse tags | Tags | Rule |
|---|---|---|---|---|---|---|---|
| Burn (Thiêu Đốt) — **Fire's debuff** | Fire | c_tick 0.019 per stack | per batch, set by its source | Element stack batches (rule 9a): no cap, no merging | fire, cleanse | burn, over_time, fire | Burns each pulse and wears down body shields (Fire does not pass them). Was a single status with c_tick 0.35 where the stronger Burn won (#44) |
| Poison (Trúng Độc) — **Wood's debuff** | Chaos | c_tick 0.019 per stack | per batch, set by its source | Element stack batches (rule 9a): no cap, no merging | poison, cleanse | poison, over_time, chaos | Passes every shield by default; only Chaos and all resistance cut it. Was 0.15 per stack to 5 (#44) |
| Bleed (Xuất Huyết) | Physical | 0.20 per stack | 4 | Stacks to 5; each stack keeps its own timer | bleed, cleanse | bleed, over_time, physical | Body shields soak it; block never does |
| ~~Frostbite (Đống Thương)~~ | Cold | — | — | — | — | — | **Retired (#44):** Ice's debuff is the art-cost rise (rule 9a); Rime Lock reads Ice stacks |
| ~~Shock (Lôi Chấn)~~ | Lightning | — | — | — | — | — | **Retired (#44):** Thunder's debuff is crit exposure (rule 9a) |
| Qi Disruption (Loạn Khí) | Force (qi burn) | 0.30 per stack | 3 | Stacks to 3 | force, cleanse | qi_disruption, over_time, force | Ticks linh lực, not health, at most 5 % of `qi_max` a pulse, shared with every other burn on the target (rule 6). Its path is all + Force resistance → linh lực, passing every shield (user decision 2026-11-08, re-review EF 3 with Combat Damage Types rule 4) |
| Corpse Rot (Thi Độc) — **standing** | Chaos | 0.15, one stack | none | None (a recast does nothing while it runs) | poison, cleanse | corpse_rot, over_time, chaos, poison | Never ends on its own. Its caster pays 2 % of their maximum linh lực every pulse (Formulas B); it ends the pulse that goes unpaid, or on a cleanse. Never merges with Poison |

Light has no tick (its status is Exposed) and Soul never ticks (Combat Damage Types rule 1).

**Standing statuses skip the duration lint** (user decision 2026-11-08), since `c_tick · duration` has no
duration to read. They are bound instead by their standing cost (Formulas B) and `c_tick ≤ 0.15`.

**Curses**

| Curse | Rule changed | Strength | Duration | Stacking | Cleanse tags | Tags | Rule |
|---|---|---|---|---|---|---|---|
| Sundered (Phá Giáp) | Resistance down, for the damage type of the applying hit's largest part after conversion (ties go to the first type in Combat Damage Types' order). When no hit applies it (a talisman, the ground, a trigger), the applying record names the type; an all-Soul hit cannot apply it (Slackened Soul is its Soul counterpart; re-review EF 5) | −150 points per stack (2026-11-10) | 4 | Stacks to 3 | curse, cleanse | sundered, curse | No shred cap or floor since 2026-11-10: below 0 points a part is amplified (Combat Defence & Healing rule 3) |
| Exposed (Hiển Hình) | All resistance down | −100 points (2026-11-10) | 3 | Refresh | curse, light, cleanse | exposed, curse, light | Light's status: the target is laid bare |
| Sealed Meridian (Phong Mạch) | Layer lock: one named layer, L2 to L5, counts as 1.0 | — | 2 | None | curse, seal, cleanse | sealed_meridian, curse | Cannot be reapplied to that target for 2 pulses after it ends |
| Silence (Cấm Ngôn) | Tag block: arts with the named tag cannot fire, and modifiers needing it do not apply | — | 3 | None | curse, seal, cleanse | silence, curse | May not name `ward`, `basic` or `escape`; the same 2-pulse reapply lockout |
| Stagnation (Trệ Khí) | Regeneration dampened: linh lực **and** health regeneration are divided by (1 + D / 100), D = 1 per stack (Modifier System rule 6a) | 1 % dampened per stack | 3 | Stacks with no cap; a new stack refreshes all | curse, cleanse | stagnation, curse | Pairs with drain and Force builds. 100 stacks halve regeneration, 200 leave a third; it never stops it (user decision 2026-11-10, replacing the full block that starved linh lực after #44) |
| Heavy Breath (Trọng Tức) | Art cost raise | +25 % per stack | 4 | Stacks to 2 (+50 %, `curse_cost_raise_max`) | curse, cleanse | heavy_breath, curse | — |
| Leaking Ward (Lậu Hộ) | Drain wards bill more | +50 % (`curse_drain_raise_max`) | 3 | Refresh | curse, ward, cleanse | leaking_ward, curse, ward | Drain wards only |
| Withering (Khô Héo) | Healing taken down | −50 % (`curse_heal_taken_max`, new) | 4 | Refresh | curse, cleanse | withering, curse | The healer's answer |
| Slackened Soul (Tùng Hồn) | Soul resistance down | −15 pp per stack (`curse_soul_shred_max` 30 pp; never below 0, Combat revision D12) | 2 | Stacks to 2 | curse, soul, cleanse | slackened_soul, curse, soul | — |

### Starter Effects

> Drafted by `game-designer` 2026-11-07, filtered from `modifier-inventory.md` Part 2 and new pieces; inserted
> as drafted (user decision). Every record is `price: unpriced`. **L5 +N** is N points in Combat's layer L5
> (cap 100), granted through `damage_more` on L5, which only Effects may grant (Modifier System rule 6).
> **Tiers** (rule 4): keystones and enablers carry their own tier. Of the rest, these are `major`: Flowing Water,
> Echo, Shattering Ward, Blood Drinker, Final Clause, Marked Prey, Gorged,
> Field Walls, Overheat, Elemental Fist, Measured Stroke, Talisman Sleeve and Great Essence-Draining Art. Every
> other starter Effect is `minor`. Statuses carry no tier; the art or Effect that applies them does.
> **Hosts:** MM Meridian Map, Way node or capstone, Tech technique or art, Item named item, Tal talisman, Form
> formation, Beast spirit beast, Root spiritual root. Every record is `npc: true` except Seal of Full Payment and the four life
> Effects, which NPC Builds summarises its own way.

**Conditional**

| Name | Rule | Reads | Payload / action | Limits | Closes | Hosts | Build families | From |
|---|---|---|---|---|---|---|---|---|
| Steady Breath (Bình Tức) | While your linh lực is at 50 % or above, arts in this piece's scope deal more. | Own linh lực, instant start | L5 +12, scope set by the host (e.g. sword) | — | — | Way, Tech, Item | Sword, ward caster, cheap arts | Steady Thread, Steady Breath |
| Spent Breath (Khí Tận) | While your linh lực is at 30 % or below, arts in this piece's scope deal more. | Own linh lực, instant start | L5 +12, scoped | — | — | Way, Tech, Item | Burnout, dark path, Force | Spent Breath, Running Low |
| Kindled Wound (Trì Nhiệt) | Your Fire parts deal more to a target bearing your Burn (your Fire debuff stacks). | Element stack counts on the target, instant start | L5 +15, scope [fire] | — | — | Way, Tech, Item | Fire arts, Fire-converted sword, status | Heat Held, Keeping Heat |
| Pack Hunt (Quần Liệp) | Your companion's hits deal more to a target bearing any of your statuses. | Statuses on the target, instant start | L5 +15, scope [companion] | — | — | Beast, Way, Item | Companion, poison, curse | new |
| Beneath Notice (Bất Túc Đạo) | Against an enemy of a higher realm, your escape is likelier. | Realm gap, instant start | `escape_pct` +15 (inside `escape_bonus` 0.3) | — | — | MM, Way, Item | Escape, low-realm survivor, fortune | Beneath Notice |

**Scaling**

| Name | Rule | Reads | Payload / action | Limits | Closes | Hosts | Build families | From |
|---|---|---|---|---|---|---|---|---|
| Marked Prey (Tiêu Ký) | Your hits deal more for each different status of yours on the target. | Distinct own statuses on the target, instant start | L5 +4 each | Cap +16 | — | Way, Tech, Item | Curse, poison, companion, Fire | Marked Target, Sick Body, Crowded Sky, Opened Guard |
| Bare Rack (Không Giá) | Your basic attack and companion hits deal more for each empty art slot. | Slots, compile | L5 +5 each, scope [basic] or [companion]. The [basic] half is Pending, adding nothing, until Combat adopts the `basic` tag in #43 (re-review EF 24) | Cap +20 | — | MM, Way | Martial basic attack, companion | Bare Rack, Still Hand, Idle Hands |
| Gorged (Bão Lôi) | Your hits deal more for every 1 % of maximum health restored to you this fight. | Health restored this fight, live | L5 +1 per 1 % | Cap +30 | — | Way, Tech | Healer-fighter, lifesteal body, sword | Gorged |
| Open Sky (Không Thiên) | Your wards are stronger for every 1 % of thần thức not bound to artifacts. | Free thần thức, compile | `defense_pct` +0.5 per 1 % | Cap +30 | — | MM, Way | Ward, soul, artifact-free | Open Sky |

**Trigger**

| Name | Rule | Reads | Payload / action | Limits | Closes | Hosts | Build families | From |
|---|---|---|---|---|---|---|---|---|
| Flowing Water (Lưu Thủy) | When you crit, your other arts' timers shorten by 0.5 s. | Crit event | Move timers | 3 firings per pulse; never below `cooldown_min` | — | MM, Way | Crit, sword, tempo | Flowing Water |
| Echo (Hồi Âm) | When one of your arts lands a hit, it has a 25 % chance to strike again for free. | Hit event | Free hit, c_trig 0.5, same tags (chance × c_trig 0.125) | Once per firing; trigger budget | — | Way, Tech, Item | Element arts, sword, talisman | Echo |
| Opening Cut (Khai Huyết) | When a Physical hit of yours crits, it applies one Bleed stack. | Crit event, the hit's type (event) | Apply Bleed | 1 per hit | — | Way, Tech, Item | Sword, crit, fist | Thin Bleed |
| Shattering Ward (Toái Hộ) | When one of your shields breaks, it bursts against the enemy. | Shield breaks (event) | Free Force hit, c_trig 0.6 | 1 per pulse, 3 per fight | — | Way, Tech, Item | Ward shield, body shield (thể tu) | Shattering Ward |
| Blood Drinker (Ẩm Huyết) | When your hit removes enemy health, you restore 6 % of what it dealt. | Hit event | Restore health (healing) | Direct hits only, never ticks or trigger hits; 0 under `no_heal` | — | Tech, Item, Way | Sword, body, dark path, beast | new |
| Iron Skin Renewed (Thiết Bì Phục) | When you fire an art with a Physical part, your body shield regains 2 % of maximum health. | Firing event | Restore body shield (healing) | 1 per pulse | — | Tech (luyện thể), Item | Thể tu, Physical sword | new |
| Soul Wound (Thương Hồn) | When your soul art lands, the enemy's next ready art is delayed by 0.5 s. | Soul hit event | Move the enemy's timer | Once per `soul_lockout` | — | Way, Tech | Soul, control, ward stall | Soul Wound |
| Rime Lock (Sương Tỏa) | When your Ice stacks on a target reach 10, that target's art with the least time left is delayed by 1 s. | Element stack counts on the target (live), a stack applied (event) | Move the enemy's timer | Once per 4 pulses per target | — | Way, Tech, Item | Cold, control, ticker | new (#44: was 3 Frostbite stacks) |
| Final Clause (Mạt Khoản) | Once a fight, as you go Down, your longest-cooldown art fires at no cost. | Down step 2 (event); an art's authored record (cooldown), compile | Fire the art with its cost waived (a last act); "longest" means the authored cooldown, and a tie goes to the earlier slot | Once per fight; its damage enters the follow-up check | — | Tech, Item | Dark path, burst Fire, sword | Final Clause |

**Conversion and overflow**

| Name | Kind | Rule | Reads | Payload / action | Limits | Hosts | Build families | From |
|---|---|---|---|---|---|---|---|---|
| Field Walls (Điền Thành) | Conversion | If your formation is prepared, half of your formation power also counts as ward strength. | Preparation, compile (fixed for the fight; re-review EF 23) | `defense_pct` = 0.5 × `formation_power_pct` | Nothing in blind fights | Form, Way | Formation, ward | Field Walls |
| Spillover (Dật Độc) | Overflow | Your ticks also burn the target's linh lực, 25 % of the damage each deals after resistance. | A tick dealt (event) | Burn linh lực, with no second resistance step (re-review EF 3) | None (no burn cap since #44) | Way, Tech, Item | Poison, status, anti-ward | Spillover (#44: was the tick cap's clipped amount) |
| Still Water (Tĩnh Thủy) | Overflow | Linh lực lost to a full pool restores health at half that amount. | Overflow (event) | Restore health (healing) | — (no heal cap or decay since #44) | MM, Way | Ward caster, healer, cheap arts | Still Water |
| Overheat (Quá Nhiệt) | Overflow | Art speed that `cooldown_min` clips on an art becomes extra damage for that art, point for point. | Art speed (compile), the art's cooldown | L5 on that art | Cap +30 | Way, MM | Tempo, quick arts, crit | Overheat |

Plain scoped conversions are `convert_pct` modifiers, not Effects (user decision 2026-11-08b, re-review EF-01,
DT-07, MD-09). Flame-Tempered Edge (40 % Physical → Fire, [sword]), Thunder Palm (50 % Force → Lightning, [palm])
and Rot Seeps In (25 % Physical → Chaos, [moc]) moved out of this list: their hosts grant scoped `convert_pct`
at catalogue grades (+15 pp on a notable), and a build reaches 40–50 % by stacking sources inside the 2 per hit.
Only conversions with a condition (Field Walls) stay Effects.
Stacked conversion into Chaos is watched in the balance pass; Chaos passes body shields (user decision 2026-11-08c, re-review EF-05, option A).

**Rule change**

| Name | Rule | Reads | Payload / action | Limits | Hosts | Build families | From |
|---|---|---|---|---|---|---|---|
| Elemental Fist (Ngũ Hành Quyền) | Your basic attack carries your main root's element tag. | Main root's element, compile | Adds a tag (modifier scopes only, never defence) | — | Way, Root, Tech | Element arts, martial basic attack, body | Elemental Fist |
| First Move (Tiên Thủ) | Your first art of the fight costs no linh lực. | Firings this fight, live | Waive the cost | Once per fight | Way, Item | Alpha-strike sword, Fire burst, soul opener | First Move |
| Measured Stroke (Định Trảm) | Your arts with an authored cooldown of 20 s or more cannot be evaded and cannot crit. | An art's authored record, compile | Skips the evade and crit rolls | — | Way, Tech | Slow nukes, formation arts, anti-evasion | Measured Stroke |
| Cold Feet (Hàn Túc) | Your escape art's first firing comes at `cooldown_min`. | — | Move a timer | First firing only | MM, Item, Tal | Escape, low-realm survivor, fortune | Cold Feet |
| Talisman Sleeve (Phù Tụ) | One talisman that carries a guard takes no art slot. | Loadout, compile | Adds a slot | 1 talisman | Item, Way | Talisman, escape, preparation | Talisman sleeve |

**Keystones**

| Name | Rule | Reads | Payload / action | Limits | Closes | Hosts | Build families | From |
|---|---|---|---|---|---|---|---|---|
| Called Blow (Báo Chiêu) | Your crit chance is counted on a visible meter, not rolled. | The chance about to be rolled, live (at each would-be roll) | Counted chance (rule 12); enforce a closing rule | One chance | Crit chance cap 0.50 → 0.35 | MM, Way capstone | Crit, sword, deterministic | Called Blow |
| Unyielding Breath (Bất Khuất) | Once a fight, a blow that would put you Down leaves you at 1 health. | Down step 1 (event) | Refusal | Once per fight | Maximum health −15 % (`khi_huyet_pct` −15) | MM | Body, escape window, dark path | Unyielding Breath |
| Burning Lifespan (Nhiên Thọ) | Once a fight, when your health first falls to 30 % or below, you burn years for 5 s of fury. | Own health, live | L5 +40 on all hits and `art_speed_pct` +30, for 5 s | Once per fight | When it fires, the result reports 2 % of your realm's base lifespan in years lost, win or lose (rule 10) | MM, Tech (ma đạo) | Dark path, sword, body comeback | Burning Lifespan |
| No Ward (Vô Hộ) | You can never use a ward, and your body hardens instead. | Hits reaching your health (events) | `body_shield_pct` +25; after each pulse in which no hit reached your health, the body shield regains 2 % of maximum health; enforces `cannot_slot_wards` and `no_default_ward` (Combat Defence & Healing rule 5) | — (shields are uncapped, Combat Defence & Healing rule 9) | No ward of any kind, including the default ward and soul wards | MM | Thể tu, Physical sword | No Ward |
| Glass Meridians (Lưu Ly Kinh Mạch) | Your arts run far faster, on a fragile body. | — | `art_speed_pct` +40; enforce a closing rule | `cooldown_min` | Maximum health −25 % (`khi_huyet_pct` −25); your body shields hold half | MM | Tempo, crit, element caster | Glass Meridians |
| Heart Demon's Blade (Tâm Ma Nhập Đao) | Your hits deal more for every point of heart demon above 30. | Heart demon, compile | L5 +1 per point | Cap +40 | Qi deviation chance × 2 (`qi_deviation_pct` +100); every fight you win reports +1 heart demon | MM | Dark path, sword, soul | Capability #25 |
| Beast Soul Union (Thú Hồn Hợp Thể) | Your strongest companion's power share counts double. | Strongest companion's share, compile | Companion share × 2; enforce a closing rule | `c_comp_cap` | −1 art slot; only one companion fights with you | MM, Beast | Companion, martial basic attack | Capability #17 |

**Enablers**

| Name | Rule | Reads | Payload / action | Limits | Closes | Hosts | Build families | From |
|---|---|---|---|---|---|---|---|---|
| Blood Casting (Huyết Tế) | When your linh lực cannot pay for an art, you pay the shortfall in health, 1 for 1. | Own linh lực, live (at firing) | Pay the cost in health: not damage; it can put you Down, and the Down step, refusals included, then runs as usual; enforce a closing rule | — | Healing taken −50 % for the fight (one floor with Withering: together they never go below −50 %) | Tech (ma đạo), named Item | Dark path, tempo, body | Blood Casting |
| Water Table (Thủy Mạch) | You gain 30 % of the linh lực the enemy's drain wards pay against your hits. | Ward payments against your hits (event) | Restore linh lực (not healing); enforce a closing rule | Up to your usable maximum (Combat Defence & Healing rule 10) | Your linh lực never regenerates in fights | Item, Way capstone | Force anti-ward, ward duelist, soul | Water Table |
| Paid in Advance (Tiên Phó) | Your talismans cost no linh lực when they fire. | — | Waive the cost; enforce a closing rule | Stock still runs out | You may slot only talismans, wards and the escape art | Named Item, Tech | Talisman, preparation, escape | Paid in Advance |
| Grave-Silk Shroud (Liệm Thi Y) | Corpse Rot is on the enemy from t = 0 without taking a slot. | — | Apply the standing status | Corpse Rot's standing cost applies | 15 % of maximum linh lực reserved for the fight | Named Item | Poison, dark path, ward caster | Grave-Silk Shroud |
| Seal of Full Payment (Túc Phó Ấn) (`npc: false`) | Your arts and wards are paid in carried spirit stones. | Carried stones, compile (before the fight) | Pay costs in stones; stones spent are reported | Stones carried. Stones never pay a standing status's upkeep: linh lực still pays it (re-review EF 18) | Linh lực pays for nothing except standing upkeep; a winner who knocks you out takes 10 % of your carried stones (reported) | Named Item | Wealth or Kỹ, ward, talisman | Seal of Full Payment |

**Life, cultivation and crafting** (live capabilities re-expressed)

| Name | Kind | Rule | Reads | Payload / action | Limits | Closes | Hosts | From |
|---|---|---|---|---|---|---|---|---|
| Soul Leaves the Body (Linh Hồn Xuất Khiếu) | Keystone | Once per realm, a death in an event leaves you alive at 5 % vitality. | A death in an event (event) | Change a life output (the event's outcome): survive at 5 % vitality | Once per realm | You lose one stage (reported; user decision 2026-11-08) | MM | Capability #5 |
| Great Essence-Draining Art (Hấp Tinh Đại Pháp) | Trigger | When you knock out a cultivator, you take cultivation base worth 5 % of your current stage, and your heart darkens. | A knockout (event); your stage, before the fight | Report base gained and +2 heart demon (re-review EF 8: a Trigger, so its cost is payload) | Cultivators only | — (a Trigger; nothing closed) | MM, Tech | Capability #9 |
| Strange Pill Reborn (Dị Đan Hóa Sinh) | Rule change | A failed brew has a 30 % chance to yield a random lesser pill instead of ash. | A failed brew (event) | Change a life output (seeded life stream) | Once per brew | — (reclassified as a rule change: it closes nothing) | MM | Capability #11 |
| Formation Within a Formation (Trận Trung Trận) | Keystone | Your formations may exceed their maximum by 2 levels. | Formation level, compile | Raise a host's cap; enforce a closing rule | +2 levels | Upkeep for those levels × 2 | MM | Capability #15 |

**Domain and tags** (re-review EF 14, before data entry). Every fight Effect above has domain `combat`; Soul Leaves the
Body and Great Essence-Draining Art have `cultivation`; Strange Pill Reborn and Formation Within a Formation have
`crafting`. Each record's tags are its kind (`conditional`, `scaling`, `trigger`, `conversion`, `overflow`,
`rule_change`, `status`, `keystone`, `enabler`), plus the stat-family and scope tags of its payload modifiers (Modifier System
rule 9), plus the status tags of any status it applies. Data entry writes them out; the smoke check's lint
(AC-EF-45) checks they match this rule.

**Capabilities without a closing cost** (user decision 2026-11-07): the live capabilities that close nothing
(about 12, such as #2, #3, #6, #8, #10, #12, #14, #16, #18, #20, #21, #24) are **rule-change Effects**, not
keystones; #9 and #11 above are re-expressed already. The ones with a real cost stay keystones. Their place in the tree is decided at the tree rework.

**Inventory filter, in short.** About 52 inventory rows were kept, most merged into the Effects above. The rest:
- about 28 are plain numbers (including the three scoped conversions; they belong in the Modifier System);
- about 30 are dead under the new damage and defence model (body guard, the qi kind, the element cycle, ward
  pass or phase, one ward at a time, Lava);
- about 130 need a subsystem invented for one overnight build;
- about 30 read something the engine does not expose;
- about 20 fail the one-sentence rule or break the game;
- about 40 are duplicate grades of kept entries;
- about 30 are deferred, not rejected, until the tree rework or a Combat key: Five Phases Cycle, Sheathed
  Blade, Against the Heavens, Home Ground, Standing Array, Seeing Eye, Soul Pressure, Mirror Ward, Spirit
  Severing, Focused Mind, Empty Hand, One Root, Heaven's Favour (a reroll needs a new action), and the
  remaining ~7 capabilities (25 live, less the 6 above and about 12 rule changes; settled with Open Question 4).

### States and Transitions

**An Effect in a fight**

| State | Meaning | Enters when | Leaves when |
|---|---|---|---|
| Idle | Its host is active, but it is not applying | Fight start, or its condition stops holding | Its condition holds, or its event happens |
| Active | Its payload applies (conditional, scaling, rule change) | Condition true at an instant's start | Condition false at a later instant's start |
| Fired | A trigger resolved this instant | Its event, within limits | The instant ends |
| On cooldown | A trigger waits out its own cooldown | It fired | Its cooldown ends (a scheduled wake-up, Combat rule 10) |
| Spent | A once-per-fight Effect has been used | It fired or refused Down | Never in this fight |

**A status on a target:** Applied → Ticking or Cursing (each pulse) → Expired (duration 0), Cleansed, or Ended
(a standing status whose caster could not pay). A recast refreshes unless the record says otherwise.

### Interactions with Other Systems

| System | Direction | Data | Interface owner |
|---|---|---|---|
| Modifier System (#40) | in | Catalogue modifiers used as payloads; tag vocabulary | Modifier System |
| Combat (#21) | in / out | Events, instants, guards, the trigger order and budget, the defeat check, results. Out: free hits, refunds, timer moves, Down refusals, Breakdown lines, reported life costs | Combat (timeline, limits); this GDD (the Effects) |
| Combat Defence & Healing (#21a) | out | Heals and restores, reservations, ward changes | Combat Defence & Healing (rules); this GDD (sources) |
| Combat Damage Types (#21b) | out | Conditional conversion Effect records (none yet); statuses' damage types | Combat Damage Types (the conversion rules and steps); this GDD (the records) |
| Character Stats (#7), Realms (#8) | in / out | Readable sheet values at compile. Out: reported heart demon, lifespan years, seasons, toxicity, spirit stones, root purity, cultivation base and stage (applied by the caller; rule 10) | Character Stats; Realms |
| Meridian Map (#10), The Way (#39), Cultivation Techniques (#9) | out | Keystones, Way nodes and capstones, technique and art Effects | each host |
| Item DB (#13), Talismans (#18), Formations (#17), Alchemy (#15), Spirit Beasts (#19) | out | Named items' Effects, talisman statuses, ground Effects, pill Effects, beast Effects | each host |
| Event Engine (#23), Time & Turn (#4) | in / out | Life Effects (season, place, events) | Event Engine |
| NPC Builds | out | Effects marked `npc: true` | NPC Builds |
| Debug Terminal, Game UI (#37) | out | Rule text, `closes`, Breakdown lines, counted-chance meters, status icons | Game UI |

## Formulas

> Effects are unpriced (rule 4), so this section holds only the mechanical rules that need numbers. Trigger
> damage, free hits and the trigger budget are Combat Formulas G; ticks and curse bounds are Combat Formulas F;
> heals and restores are Combat Defence & Healing Formulas E.

### A. Counted chance

The counted_chance formula is defined as:

`meter ← meter + p` at each point where the chance would be rolled ; if `meter ≥ 1`: the event happens and `meter ← meter − 1` ; `meter_0 = counted_start / 1000`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| p | float, held as per-mille int | 0–1 | the chance's own formula (Combat Formulas C, I; Formulas F), after its caps | The chance that would have been rolled, rounded to the nearest thousandth, half up (0.2875 → 288; re-review EF 10). Fortune does not shift it |
| meter | float, held as per-mille int | 0 to < 2 | calculated, per side, per counted chance | Visible in the Breakdown and the HUD |
| counted_start | int | 0–999 per mille | keystone record | Where the meter starts each fight (default 0) |

**Output Range:** over n opportunities, the event happens `floor(counted_start / 1000 + Σ p)` times: the long-run rate
equals the chance to within 0.0005 (the rounding of p), with no variance. No seeded draw is taken. The meter and p are held as whole thousandths
(per-mille integers), so sums are exact: 0.30 is 300, and the meter pays out at 1,000.

**Example:** crit chance 0.30, counted, starting at 0: hits 1–3 add 0.3 each (0.9); hit 4 reaches 1.2, so it crits
and the meter falls to 0.2; hit 7 reaches 1.1 and crits. Over 10 hits there are exactly **3** crits.

### B. Standing status

The standing_status formula is defined as:

`upkeep_n = standing_cost · qi_max_caster` paid by the caster at every pulse while the status runs, before the status ticks ; if the caster cannot pay, or is Down, the status ends at that pulse without ticking

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| standing_cost | float | 0.01–0.10 | status record | Share of the caster's maximum linh lực per pulse |
| qi_max_caster | float | > 0 | Combat Formulas A | The caster's maximum linh lực |

**Output Range:** the status lasts while the caster pays; a cleanse with a matching tag ends it at once.

**Example:** Corpse Rot (`standing_cost` 0.02) on a caster with 172.7 linh lực costs **3.45** per pulse, against the
6.05 per pulse a typical caster regenerates since #44, so regeneration pays it with 2.6 to spare.

### C. The Down step

The down_step order is defined as:

`sides in order, the requesting side first (Combat rule 10); for each side with health ≤ 0 after the instant: (1) refusals in slot order, first unspent one sets health ← 1 and is Spent ; (2) if still ≤ 0: last acts resolve once, in slot order ; (3) a follow-up defeat check judges (1)–(2)'s damage; the side that made the last act cannot refuse again, and a side newly put Down runs (1)–(2) ; (4) wounds that run on are written to the result`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| refusal | Effect | once per fight | Effect record | "Refuses Down"; health is set to exactly 1 |
| last act | Effect | once per fight | Effect record | Resolves at Down; its damage is ordinary damage |
| follow-up check | step | — | Combat rule 10 | Uses Combat's overkill and draw rules. A Down side keeps its overkill. A last act's damage is added to its target's `damage_in_instant` (Combat Formulas C) whether or not that target is already Down, so a last act wins only if the enemy's overkill share ends larger than its own, and shares within `overkill_epsilon` are a draw (user decisions 2026-11-08 and 2026-11-08b, EF-05) |

**Output Range:** at most one refusal per side per Down, each refusal Effect once per fight, and one round of
last acts per Down, so the step always ends.

**Example:** side A is at −12 after an instant. Its Unyielding Breath refuses Down, so A is at 1 and the keystone
is Spent. Next instant A falls to −3. No refusal is left, so A's Parting Curse (a last act) applies its curse to B,
and A is Down.

### D. Element stacks (#44)

The element stack formulas are defined as:

`count(side, element, kind) = Σ live batches` ; buff and debuff effects are `per_stack · count` (rule 9a's table) ; a cleansing ward removes `cleanse_share · stacks` from every debuff batch on its side each pulse ; an art that grants stacks lints at `c_art ≤ lint · (1 − charge)`, where `charge = Σ w_kind · stacks · seconds` per firing, buff and debuff charges simply add (the two-sided discount was removed 2026-11-10: re-measured at 1.00), with `charge ≤ 0.6`. A batch "for the fight" is charged as **60 s** (the fatigue start); the lint compares the capped coefficient **rounded down to 0.01**; a batch below **0.05** stacks is removed (user decisions 2026-11-10, re-review)

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| per_stack | float | rule 9a | data file (`element_stacks`) | One stack's effect |
| cleanse_share | float | 0.25 (0.25–0.5) | ward record | Share of each debuff batch a cleansing ward removes per pulse |
| w_kind | float | buff 0.010, debuff 0.015 per stack-second, the same for every element (user decision 2026-11-10: equal-value stacks) | data file | What one stack held for one second is worth, as a share of the art's damage. The per-stack numbers of rule 9a were fitted so every element meets these (`tools/design/combat_sim/equalfit.py`) |
| lint | float | Combat Formulas C | Combat | The art's damage limit before the charge |

**Output Range:** counts from 0 with no cap; a debuff batch under a cleansing ward falls by `cleanse_share` each
pulse; the charge runs from 0 to 0.6, so an art that grants stacks keeps at least 40 % of its damage.

**Why these weights.** Every element's per-stack numbers were fitted so that a typical kit granting 1 buff stack for
10 s per firing breaks even with the typical build when it pays a 0.010 charge per stack-second, and a kit granting 2
debuff stacks for 6 s per hit breaks even at 0.015 (the foe at 10 % evade, so accuracy and evade stacks act). Debuffs
are worth more per stack-second because they can be cleansed. A kit granting both sides is worth the sum of the two
(re-measured after equalising: factor 1.00 on average, `twosidefit.py`), so the charges add with no discount.

**Example:** a Fire art (cost 0.075, cooldown 4 s, lint 3.55) granting 1 buff stack for 10 s and 2 Burn stacks for
6 s per hit: charge = 0.010 × 10 + 0.015 × 12 = **0.28**, so c_art ≤ 3.55 × 0.72 = **2.55**. A cleansing ward
at 0.25 takes a batch of 8 Burn stacks to 6, then 4.5, then 3.4.

## Edge Cases

> `systems-designer` not consulted for this section — Lean mode. Review manually before production.

**Records**
- **If an Effect's record lacks a field rule 1 requires, or its `rule` is more than one sentence**: review rejects
  it.
- **If an Effect reads a quantity not on the readable list, or uses an action not on the action list**: it is
  rejected until the engine addition is made (rules 5–6).
- **If an Effect grants an unconditional plain number not in the modifier catalogue**: rejected (rule 3).
- **If an Effect's only payload is an unconditional, tag-scoped conversion share**: it is flagged as a `convert_pct`
  modifier, not an Effect (rule 3; AC-EF-58).
- **If a keystone or enabler has an empty or token `closes`**: rejected (rule 14).
- **If an Effect other than a status has no tier, or a keystone or enabler is tiered `minor` or `major`**: rejected (rule 4).
- **If a host slot receives an Effect of a tier the host does not allow there**: rejected; the host GDD's slot
  table decides.
- **If two keystones a host marks as rivals are both taken**: the second cannot be taken.

**In a fight**
- **If a conditional Effect's condition changes mid-instant**: it keeps the state it had at the instant's start
  (rule 8), as Combat's guards do.
- **If triggers would exceed 6 firings, chain depth 2, or the trigger damage budget**: the excess is clipped and
  logged "trigger budget", as Combat Formulas G says.
- **If a trigger sets itself off in its own chain**: it does not fire again in that chain.
- **If a timer move would take an art below `cooldown_min`**: it stops at `cooldown_min`.
- **If a refund would return more than the art cost**: it returns the cost.
- **If an Effect's modifiers pass a cap**: the cap's owner clips them; the Breakdown names the cap.
- **If a counted chance and a rolled chance apply to the same event**: the keystone's counted chance replaces the
  roll for that one chance only; other chances still roll.

**Statuses**
- **If a standing status's caster cannot pay its pulse cost, or is Down**: the status ends at that pulse.
- **If a status is cleansed by a matching tag**: it ends at once and its remaining ticks are lost.
- **If a recast meets a status of the same id**: it refreshes the duration, unless the record says it stacks, the
  stronger wins, or none (then nothing happens).
- **If a curse would pass its Combat bound** (`curse_shred_max`, `curse_cost_raise_max` and the rest): it is
  clipped to the bound.

**Life costs and Down**
- **If an Effect reports a life cost the character cannot pay** (more years than remain, more stones than held):
  the caller applies what it can and reports the shortfall; it never makes the fight's result untrue.
- **If two refusals are ready on one side**: only the first in slot order takes effect at that Down; the other
  stays unspent and may save the side at a later Down in the same fight (Formulas C).
- **If both sides refuse Down in the same instant**: both are at 1 health and the fight goes on.
- **If a last act's damage downs the other side**: the follow-up check uses Combat's overkill and draw rules, and
  each side keeps its overkill: the last act wins only if the enemy's overkill share is larger.
- **If a last act hits a side that is already Down**: its damage adds to that side's overkill for the instant, so it
  can swing a double knockout (rule 11). Equal shares within `overkill_epsilon` are a draw.
- **If Final Clause, Rime Lock or Soul Wound find two arts tied**: the earlier slot is picked (rule 7).
- **If a status with stacking "none" is recast while it runs**: nothing happens (rule 9).
- **If a status is applied with no hit** (a talisman, the ground, a trigger) and its rule reads "the applying hit":
  the applying record names the type; Sundered on an all-Soul hit is not applied.
- **If an Effect restores linh lực**: it is not healing, and it is clipped at the usable maximum (rule 6); what is
  lost to a full pool is overflow (rule 5).
- **If a side holds no element stacks and an Effect reads them**: the count is 0.
- **If a cleansing ward and new stacks land in one pulse**: stacks applied between pulses first count at the next
  pulse (Combat rule 10), so the ward removes its share from the batches present at the pulse, before new ones.
- **If Ice stacks would raise art cost past `curse_cost_raise_max`**: they do; that cap binds curses only (rule 9a).

**NPCs and the LLM Game Master**
- **If an NPC build picks an Effect without `npc: true`**: NPC Builds skips it.
- **If the LLM Game Master proposes an Effect**: the engine rejects it while Effects are unpriced (rule 15).

## Dependencies

| System | Kind | What this system needs | Status | Lists this system? |
|---|---|---|---|---|
| Modifier System (#40) | Hard | Catalogue modifiers as payloads; tags | Approved (2026-11-08b) | Yes |
| Combat (#21) | Hard | Instants, guards, trigger order and budget, curse bounds, tick formulas, the defeat check, results | Approved for rules | Partly: rule 9 defines triggers; the Combat revision (#43) cites this GDD for statuses and the Down step |
| Combat Defence & Healing (#21a) | Hard | Heal and restore rules, reservation, wards, the cleansing ward payload (`cleanse_share`) | Needs revision | Yes |
| Spiritual Roots (#6) | Hard | Purity's stack power (rule 8a, Formulas H) for rule 9a | In Review | Yes (rule 8a) |
| Heavenly Tribulation (#22) | Soft | Its waves run the Down step (refusals and last acts) like any fight | Approved for rules | Yes (Dependencies note, Combat revision #43) |
| Combat Damage Types (#21b) | Hard | Damage types of statuses; conversion | Needs revision | Yes |
| Character Stats (#7), Realms (#8) | Soft | Readable sheet values; applying reported life costs | In review | Not yet |
| Meridian Map (#10) | Soft (host) | Keystones; its 25 live capabilities move here as Effects | Redesign planned | Not yet |
| The Way (#39), Cultivation Techniques (#9) | Soft (hosts) | Nodes, capstones, technique and art Effects | Approved; in review | Not yet |
| Item DB (#13), Talismans (#18), Formations (#17), Alchemy (#15), Spirit Beasts (#19) | Soft (hosts) | Named-item, talisman, ground, pill and beast Effects | Approved; implemented | Not yet |
| Event Engine (#23) | Soft | Life Effects; World DB reads | Implemented | Not yet |
| NPC Builds | Soft | `npc: true` Effects | Implemented | Not yet |

## Visual/Audio Requirements

> `art-director` not consulted — Lean mode; the current client is the text Debug Terminal.

- Every Effect that fires or applies shows its name in the fight log, in its host's colour.
- Statuses show an icon in their damage type's colour (Combat Damage Types, Visual/Audio) with stacks and
  remaining pulses; curses show a broken-chain mark.
- A counted chance shows a meter that fills and flashes when it pays out.
- A refusal of Down has its own beat: a pause line in the log ("refuses to fall") and, later, a sound (Audio,
  #38).

## Game Feel

- **An Effect should read as a sentence and play as a promise.** When "on a crit, shorten your other timers"
  fires, the player should see the timers jump.
- **Keystones should feel like vows.** The tooltip leads with what is given up.
- **Counted chance should feel planned.** The meter makes the next crit something the player can see coming.
- **Refusing Down should be a moment,** used once, remembered.

## UI Requirements

- **Tooltip shape:** name; kind; for keystones and enablers, `closes`; then the one-sentence rule and limits.
- **Filters** by kind and by classification tag, as for modifiers.
- **Fight HUD:** status icons with stacks and pulses; counted-chance meters; Spent marks on once-per-fight
  Effects.
- **Breakdown:** one line per Effect that applied, fired or was clipped, with the reason.
- **Result screen:** reported life costs (rule 10) and wounds that run on (rule 11), each named by the Effect that
  caused it.

> **📌 UX Flag — Effects System**: This system has UI requirements. In Phase 4 (Pre-Production), run `/ux-design`
> for the Effect tooltip, the status HUD and the fight result screen **before** writing epics.

## Cross-References

| This document | References | Value or rule | Use |
|---|---|---|---|
| Rules 1, 3, 6, 15; Starter Effects | modifiers.md rules 1, 6, 8, 9, 16 | Modifier record, L5 only from Effects, scope tags, tag vocabulary, LLM limits | Read |
| Rules 5–8, 11; Formulas B | combat.md rules 6, 9, 10, 13, 15, 16; Formulas A, A2, C, G, I, J | Tags, triggers, instants, guards, the defeat check, timers, seeded draws, Breakdown, maximum linh lực, slots, rolls, trigger budget, companion share | Read |
| Rules 6, 11; Formulas | combat-defence.md rules 5–10, 16–19 (rule 19: a refusal is not healing); Formulas E | Wards, reservation, heals and restores | Read |
| Rules 6, 9; Status Catalogue | combat-damage-types.md rules 1, 4, 6, 7 | Damage types, how a tick meets the defence path, conversion, what passes a shield | Read |
| Rule 9 | combat.md rules 7–8, Formulas F | Statuses, curses, tick formula, curse bounds | Read; the status catalogue moves here |
| Rules 9–12 | overnight `decisions.md` decisions 4, 5, 9, 11 | Life costs, Down, counted chance, standing statuses | Adopted (user decisions 2026-11-07) |
| Rule 10 | combat.md rule 14 | A fight ends with a result, never a consequence | Read |
| Rule 13 | `meridian_capabilities.json` | The 25 live capabilities | Become keystones (those with a real closing cost) or rule-change Effects in this catalogue |

## Tuning Knobs

Added 2026-11-08; no value changed. Effects themselves are unpriced (rule 4), so these are the shared limits,
not prices. Safe ranges are design estimates.

| Knob | Default | Safe range | What it tunes | Source |
|---|---|---|---|---|
| `standing_cost` | per status, 0.01–0.10 (Corpse Rot 0.02) | 0.01–0.10 | What a standing status costs its caster each pulse | Formulas B |
| `counted_start` | 0 per mille | 0–999 | Where a counted chance's meter starts | Formulas A |
| Status strengths, durations, stack caps | Status Catalogue | Combat Formulas F's bounds | How hard ticks and curses hit | Status Catalogue |
| Curse bounds (`curse_shred_max`, `curse_cost_raise_max`, `curse_drain_raise_max`, `curse_heal_taken_max`, `curse_soul_shred_max`) | 0.5, +50 %, +50 %, −50 %, 30 pp | Combat Formulas F | The most a stack of curses can do | Status Catalogue |
| Reapply lockout (Sealed Meridian, Silence) | 2 pulses | 1–3 | How often a lock can be kept up | Status Catalogue |
| Starter limits (per pulse, per fight, cooldowns, caps) | each record | set by eye per Effect | Each Effect's size until the balance pass | Starter Effects |
| Tier allowances per host | each host GDD | each host GDD | How many Effects a build holds | Rule 4 |
| Element stack values | rule 9a's table | ±50 % each | How much a stack does | Rule 9a, Formulas D |
| `cleanse_share` | 0.25 per pulse | 0.25–0.5 | How fast a cleansing ward clears debuff piles | Formulas D |
| Stack weights `w_kind` | buff 0.010, debuff 0.015 per stack-second | 0.008–0.012; 0.012–0.018 | What arts pay for granting stacks; refit rule 9a's numbers (`equalfit.py`) when these change | Formulas D |
| Charge cap | 0.6 | 0.5–0.7 | The least damage an art that grants stacks keeps (the two-sided factor was removed 2026-11-10) | Formulas D |

## Acceptance Criteria

> Drafted by `qa-lead` 2026-11-08. Its gaps are fixed in rules 1, 3, 6 and 11, Formulas A–C, Edge Cases and the
> Burn row. Tests go in `tests/unit/effects/` [Logic] and `tests/integration/effects/` [Integration]; screenshots
> in `production/qa/evidence/` [UI]. Effects are unpriced (rule 4), so nothing here checks price or balance.
> Fixtures come from the Starter Effects and the Status Catalogue unless marked *test fixture*.

**Records and validation**

- **AC-EF-01** [Logic] Rule 1. **GIVEN** the Steady Breath record with each rule-1 field it must state removed in turn (including `tier`, `npc` and its read's read time; `closes` is for keystones and enablers only, and events need no read time), plus a copy whose `rule` is two sentences, **WHEN** validated, **THEN** each copy is rejected with an error naming the record and the field, and the intact record is accepted.
- **AC-EF-02** [Logic] Rule 2. **GIVEN** two copies of Steady Breath that differ only in `kind`, **WHEN** the same seeded fight runs with each, **THEN** the logs and results are identical.
- **AC-EF-03** [Logic] Rule 3. **GIVEN** an Effect whose unconditional payload names a stat not in the Modifier System's Stat List, or an operation that stat does not allow, **WHEN** validated, **THEN** it is rejected. **GIVEN** No Ward's +25 `body_shield_pct`, **THEN** it is accepted.
- **AC-EF-04** [Logic] Rule 4. **GIVEN** a record with `price` other than `unpriced`, or with a W, weight or budget field, **THEN** it is rejected. **AND** a search of Effect data and the Effects code finds no W value and no price-check call. **GIVEN** a keystone tiered `minor`, or a `major` Effect placed in a host slot that allows only `minor`, **THEN** it is rejected.
- **AC-EF-05** [Logic] Rule 5. **GIVEN** a read not on the readable list, or a read with no read time, **THEN** the record is rejected. **GIVEN** Gorged (live), **WHEN** 5 % of maximum health is restored partway through an instant, **THEN** the next hit in that instant gets L5 +5.
- **AC-EF-06** [Logic] Rule 6. **GIVEN** a record using an action not on the action list, **THEN** it is rejected until the action is added.
- **AC-EF-07** [Integration] Rule 6, paying in health. **GIVEN** Blood Casting, linh lực 10 and an art cost of 25, **WHEN** the art fires, **THEN** linh lực goes to 0 and health drops by exactly 15, with no resistance, ward or shield applied, and nothing counts it as damage or healing (Blood Drinker and Gorged are untouched). **WHEN** that takes health to 0 or below, **THEN** the Down step runs, and a ready refusal may save the side.
- **AC-EF-08** [Integration] Rule 6, delaying an enemy timer. **GIVEN** Soul Wound, **WHEN** a soul art lands, **THEN** the enemy's next ready art is delayed by 0.5 s; a second soul hit inside `soul_lockout` delays nothing.

**Engine limits (rule 7) and timing (rule 8)**

- **AC-EF-09** [Logic] **GIVEN** a chain event → trigger → trigger → trigger, **THEN** the third-level trigger does not fire and is logged. **GIVEN** 8 eligible firings for one side between two pulses, **THEN** 6 fire and 2 are dropped and logged "trigger cap" (`trig_cap`; "trigger budget" is the damage clip of AC-EF-10, Combat Formulas G).
- **AC-EF-10** [Logic] Combat Formulas G (restated by the Combat revision #43). **GIVEN** six free hits of 2.30 (13.81 in total) against FX-T with the Common Ward, and 13.34 direct damage since the last pulse, **THEN** 6.67 (0.5 × 13.34) is applied and "trigger budget" is logged.
- **AC-EF-11** [Logic] **GIVEN** Echo with its chance forced to 1 (*test fixture*), **WHEN** an art hits, **THEN** exactly one free hit follows, and it does not fire Echo again in that chain.
- **AC-EF-12** [Integration] **GIVEN** Effect modifiers raising the crit sum to 0.62, **THEN** Combat applies 0.50, and the Breakdown names the Effect and the crit cap.
- **AC-EF-13** [Logic] **GIVEN** a fixed seed, **WHEN** the same fight runs twice, **THEN** the logs are byte-identical. **GIVEN** a chance of exactly 0 or 1, **THEN** the seeded stream does not advance.
- **AC-EF-14** [Integration] **GIVEN** a fight where Effects apply, fire and are clipped, **THEN** each event writes one Breakdown line naming the Effect and what it did, and an Effect that does nothing writes none.
- **AC-EF-15** [Logic] Rule 8. **GIVEN** Steady Breath at 55 % linh lực when an instant starts, **WHEN** linh lực falls to 40 % during it, **THEN** every hit in that instant gets L5 +12, and none in the next instant does.

**Statuses (rule 9, Formulas B, catalogue)**

- **AC-EF-16** [Logic] Rule 9. **GIVEN** a status missing its damage type (tick) or rule (curse), or missing duration, stacking, cleanse tags or tags, or a status with a number but no strength, **THEN** it is rejected. **GIVEN** Sealed Meridian, Silence or Stagnation with no strength, **THEN** each is accepted. **GIVEN** Sealed Meridian recast while it runs, **THEN** nothing happens. **GIVEN** Exposed recast, **THEN** its duration refreshes and it does not stack.
- **AC-EF-17** [Logic] Rule 9. **GIVEN** a status with no duration that lacks a `standing_cost` or a cleanse tag, **THEN** it is rejected.
- **AC-EF-18** [Logic] Formulas B. **GIVEN** a standing status with `standing_cost` 0.03 (*test fixture*) on a caster with `qi_max` 172.7, **THEN** upkeep is 5.181 per pulse (shown 5.2), paid before it ticks. **WHEN** the caster cannot pay, or is Down, **THEN** it ends that pulse without ticking. **WHEN** a matching cleanse lands, **THEN** it ends at once and its remaining ticks are lost.
- **AC-EF-19** [Logic] Burn (Fire's debuff, #44). **GIVEN** a batch of 2 Burn stacks for 6 s and a second batch of 3 for 4 s on one target, **THEN** the count is 5, the first batch's timer is not refreshed, the count is 2 after 4 s and 0 after 6 s, and each tick uses its own batch's applier values.
- **AC-EF-20** [Logic] Poison (Wood's debuff, #44). **GIVEN** 40 Poison stacks in several batches, **THEN** all 40 count (no cap), each tick is Chaos, and it passes ward and body shields.
- **AC-EF-21** [Logic] Bleed. **GIVEN** stacks applied at pulse 0 and pulse 2, **THEN** the first expires after pulse 4 and the second ticks until pulse 6.
- **AC-EF-22** [Logic] Rime Lock (#44). **GIVEN** Rime Lock and a target with 9 of your Ice stacks, **WHEN** a 10th lands, **THEN** its art with the least time left is delayed by 1 s, at most once per 4 pulses per target. **GIVEN** a status record named Frostbite or Shock, **THEN** load rejects it as retired.
- **AC-EF-23** [Logic] Silence. **GIVEN** a Silence naming `ward`, `basic` or `escape`, **THEN** it is rejected. **WHEN** a Silence is reapplied within 2 pulses of ending, **THEN** it fails and is logged.
- **AC-EF-24** [Logic] Sundered and Exposed. **GIVEN** 3 Sundered stacks (−0.45) and Exposed (−0.10), **THEN** the shred is 0.50. **GIVEN** base resistance −0.20, **THEN** the result is −0.50 (`resist_floor`), never lower.
- **AC-EF-25** [Logic] Corpse Rot. **GIVEN** the loaded catalogue, **THEN** Corpse Rot is the only status with no duration. **GIVEN** Corpse Rot and Poison on one target, **THEN** they never merge, and neither is capped per tick or per pulse.
- **AC-EF-26** [Logic] Qi Disruption. **GIVEN** 3 stacks whose ticks would pass 5 % of the target's `qi_max`, **THEN** linh lực loses exactly 5 % of `qi_max` that pulse and health loses nothing. **GIVEN** Force resistance 0.20, `no_default_ward`, and full ward and body shields, **THEN** each tick is cut by 0.20 and both shields are unchanged.

**Life costs, Down and counted chance (rules 10–12, Formulas A and C)**

- **AC-EF-27** [Integration] Rule 10. **GIVEN** Heart Demon's Blade with heart demon 50 before the fight, **THEN** the payload is L5 +20. **WHEN** the side wins, **THEN** the result reports +1 heart demon while the sheet still reads 50, and it reads 51 only after the caller applies the result. **GIVEN** a kill with no Effect that adds heart demon, **THEN** none is reported.
- **AC-EF-28** [Logic] Formulas C. **GIVEN** side A at −12 after an instant, holding Unyielding Breath and Final Clause, **THEN** A is set to 1 and Unyielding Breath is Spent. **WHEN** A later falls to −3, **THEN** no refusal fires, Final Clause fires A's longest-cooldown art at no cost, its damage enters a follow-up check using Combat's overkill and draw rules, and A is Down without a second refusal. **GIVEN** A Down with overkill share 0.20 and B standing at 4 with `health_max` 100, **WHEN** A's last act deals 44, **THEN** B's share is 0.40 and A wins; **WHEN** it deals 14, B's share is 0.10 and B wins; **WHEN** the last act deals 24, B's share is 0.20, equal to A's within `overkill_epsilon`, so it is a draw. **GIVEN** both sides Down in one instant, `health_max` 100 on each, B the requesting side with no last act, A at overkill share 0.20 and B at −10 (share 0.10), **THEN** B's step resolves first, and A's last act of 20 adds to B's overkill: B's share is 0.30 against A's 0.20, so A wins.
- **AC-EF-29** [Logic] Rule 11. **GIVEN** two refusals ready on one side, **THEN** only the first in slot order fires at that Down, and the second saves the side at a later Down. **GIVEN** both sides going Down in one instant, each holding a refusal, **THEN** both are at 1 and the fight continues. **GIVEN** a last act that puts side B Down, **THEN** B may use its own unspent refusal.
- **AC-EF-30** [Logic] Formulas A. **GIVEN** Called Blow with crit chance 0.30 (300 per mille) and the meter at 0, **WHEN** 10 hits land, **THEN** hits 4, 7 and 10 crit (exactly 3), the meter reads 0 after hit 10, and no seeded draw is consumed.
- **AC-EF-31** [Logic] Rule 12. **GIVEN** counted chance on an Effect that is not a keystone, or one keystone counting two chances, **THEN** the record is rejected. **GIVEN** Called Blow and Echo together, **THEN** crits are counted and Echo still rolls.

**Hosts, closes and NPCs (rules 13–15)**

- **AC-EF-32** [Logic] Rule 13. **GIVEN** an Effect attached to a host type missing from its `hosts`, or an enabler listing `affix`, **THEN** it is rejected. **GIVEN** a keystone taken, **WHEN** its host's rival keystone is chosen, **THEN** the second cannot be taken.
- **AC-EF-33** [Logic] Rule 14. **GIVEN** a keystone or enabler whose `closes` is empty, "—" or "none", **THEN** it is rejected.
- **AC-EF-34** [Integration] Rule 15. **GIVEN** NPC Builds choosing from the catalogue, **THEN** it never picks an Effect with `npc: false`. **GIVEN** the LLM Game Master proposing an Effect, **THEN** the engine rejects it, while a modifier grant is accepted.

**Starter Effects as fixtures**

- **AC-EF-35** [Logic] Flowing Water. **GIVEN** 4 crits in one pulse, **THEN** timers move 3 times and the 4th is logged as clipped. **GIVEN** an art whose next firing would come sooner than `cooldown_min` after its last, **THEN** the move stops at `cooldown_min`.
- **AC-EF-36** [Logic] Echo. **WHEN** validated, **THEN** chance × `c_trig` = 0.125 and it is accepted; a *test fixture* with 0.8 × 0.8 = 0.64 is rejected.
- **AC-EF-37** [Logic] Blood Drinker. **GIVEN** a direct hit removing 200 health, **THEN** 12 is restored (no decay or cap since #44); ticks and trigger hits restore 0; every case restores 0 under `no_heal`.
- **AC-EF-38** [Logic] Iron Skin Renewed (#44). **GIVEN** `health_max` 1,000 with 30 already healed this pulse, **WHEN** it fires at t = 40, **THEN** the body shield regains its full 20 (no heal cap, no decay); under `no_heal` it regains 0.
- **AC-EF-39** [Integration] Burning Lifespan. **GIVEN** a realm base lifespan L (*test fixture*), **WHEN** it fires, **THEN** the result reports 0.02 · L years lost on a win and on a loss alike, and age does not change during the fight.
- **AC-EF-40** [Integration] No Ward. The two flags now exist (Combat Defence & Healing rule 5, re-review CD 11). **GIVEN** No Ward, **THEN** there is no default ward, ward and soul-ward arts cannot be slotted, and `body_shield_pct` is +25.
- **AC-EF-41** [Logic] Called Blow. **GIVEN** a crit sum of 0.50 and a fortune modifier, **THEN** the counted p is 0.35, and adding or removing fortune leaves it unchanged.
- **AC-EF-42** [Logic] Elemental Fist. **GIVEN** a Fire root, **THEN** the basic attack takes Fire-element-scoped damage modifiers, and its resistance is still Physical: a defender with Fire resistance 0.5 and Physical 0 takes unreduced damage.
- **AC-EF-43** [Integration] Seal of Full Payment. **GIVEN** 1,000 carried stones, **THEN** linh lực pays for nothing and stones spent are reported, not deducted mid-fight; a knockout reports a 100-stone loss to the winner; NPC Builds never picks it.
- **AC-EF-44** [Logic] L5 payloads. **GIVEN** a `damage_more` L5 modifier on a source that is not an Effect, **THEN** it is rejected (Modifier System rule 6); Kindled Wound's L5 +15 is accepted.
- **AC-EF-48** [Logic] Spillover (#44). **GIVEN** a tick of 12 after resistance, **THEN** the target also loses 3 linh lực, with no second resistance step and no burn cap. **GIVEN** a Qi Disruption tick of 7 and Spillover burns of 6 in one pulse, **THEN** 13 comes off and nothing is clipped.
- **AC-EF-49** [Logic] Water Table (ward payment event; restore linh lực). **GIVEN** the enemy's drain wards paying 20 against your hits and your pool 5 below your usable maximum, **THEN** you regain 5 (not 6), it is not healing, and your linh lực never regenerates.
- **AC-EF-50** [Logic] Beast Soul Union (multiply a share). **GIVEN** a strongest companion whose `share / (B_p · stage_mult)` is 0.40, **THEN** its `c_comp` is 0.80. **GIVEN** 0.60, **THEN** 1.20 is clipped to 1.0 (`c_comp_cap`, Combat Formulas J) and the Breakdown names the cap.
- **AC-EF-51** [Logic] Formation Within a Formation (raise a cap). **GIVEN** a formation maximum of level 5, **THEN** level 7 may be laid, and its upkeep for levels 6 and 7 is doubled.
- **AC-EF-52** [Logic] Strange Pill Reborn (change a life output). **GIVEN** a failed brew and a seeded life stream, **THEN** over seeds 1–10,000 the share that yields a lesser pill is between 0.28 and 0.32, the same seed always gives the same result, and a fight's stream is untouched.
- **AC-EF-53** [Logic] Talisman Sleeve (add a slot). **GIVEN** a talisman with a guard, **THEN** it takes no art slot; a second such talisman does.
- **AC-EF-54** [Logic] Measured Stroke (skip a roll; an art's authored record). **GIVEN** an art with an authored cooldown of 20 s, **THEN** no evade or crit roll is drawn and the seeded stream does not advance; at 19.9 s, both rolls happen.
- **AC-EF-55** [Logic] First Move (waive a cost). **GIVEN** a pool of 5 and a first art costing 25, **THEN** it fires, the pool stays 5, and drain wards see no dip.
- **AC-EF-56** [Integration] Soul Leaves the Body (death in an event; change a life output). **GIVEN** an event that would kill the character, **THEN** they survive at 5 % vitality, the result reports one stage lost, and a second death in the same realm kills.
- **AC-EF-57** [Integration] Great Essence-Draining Art (stage read before the fight; rule 10). **GIVEN** a stage whose span is S cultivation base (*test fixture*), **WHEN** the side knocks out a cultivator, **THEN** the result reports +0.05 · S base and +2 heart demon, the sheet is unchanged until the caller applies it, and a creature knockout reports nothing.
- **AC-EF-58** [Logic] Rule 3 (re-review EF-01). **GIVEN** an Effect record whose only payload is an unconditional, tag-scoped conversion share, **WHEN** the lint runs, **THEN** it is flagged as a `convert_pct` modifier, not an Effect.
- **AC-EF-59** [Logic] Paid in Advance (forbid a slot kind). **GIVEN** Paid in Advance and a loadout with a sword art in a slot, **WHEN** compiled, **THEN** it is rejected and names the art; a loadout of talismans, wards and the escape art compiles.
- **AC-EF-60** [Logic] Blood Casting with Withering (shared floor). **GIVEN** Blood Casting (−50 % healing taken) and Withering (−50 %) on one side and a heal of 100, **THEN** 50 is received, not 0 and not 25, and the Breakdown names the floor.
- **AC-EF-61** [Logic] Glass Meridians (scale a pool). **GIVEN** a body shield pool of 200 before the keystone, **THEN** it is 100 with it, and maximum health is 25 % lower.
- **AC-EF-62** [Logic] Beast Soul Union (forbid a companion). **GIVEN** two companions in the loadout, **WHEN** compiled, **THEN** it is rejected and names the second.
- **AC-EF-63** [Logic] Rule 9a, batches. **GIVEN** an art granting 1 Fire buff stack for 10 s fired at t 1, 3 and 5, **THEN** the count is 1, 2, 3 at t 5 and falls to 0 at t 15, and Fire damage dealt is +3.6 % at t 6.
- **AC-EF-64** [Logic] Rule 9a, no cap. **GIVEN** 250 Water buff stacks, **THEN** maximum linh lực is +125 % and the regeneration bonus +6.25 pp before Combat's diminishing returns; nothing is clipped. **GIVEN** 120 Thunder buff stacks on a side with crit chance 0.1, **THEN** crit chance stops at `crit_chance_cap`.
- **AC-EF-65** [Logic] Rule 9a, Ice past the curse cap. **GIVEN** Heavy Breath at +50 % and 30 Ice stacks on a side, **THEN** its art costs are ×1.5 × 2.17, and the log names both.
- **AC-EF-66** [Logic] Rule 9a, element tag. **GIVEN** a Metal-tagged art whose Physical is converted to Fire, granting stacks, **THEN** it grants Metal stacks, not Fire. **GIVEN** a record granting Chaos, Light or Darkness stacks, **THEN** load rejects it.
- **AC-EF-67** [Logic] Rule 9a, debuff ticks. **GIVEN** a Burn batch applied while the applier has +40 % Fire damage, **WHEN** the applier's bonus later drops, **THEN** that batch still ticks with +40 %; a later batch uses the new value.
- **AC-EF-68** [Logic] Formulas D, cleansing ward. **GIVEN** `cleanse_share` 0.25 and a Burn batch of 8, **THEN** it is 6, 4.5 and 3.375 after three pulses; a batch below 0.05 stacks is removed. **GIVEN** a cleanse art removing 5 stacks against batches of 3 (older) and 4, **THEN** the older is gone and the newer holds 2. **GIVEN** an element-wide cleanse, **THEN** every debuff batch of that element is removed and other elements stay.
- **AC-EF-69** [Config/Data] Formulas D, lint. **GIVEN** a Fire art with cost 0.075, cooldown 4 s, 1 buff stack for 10 s and 2 Burn stacks for 6 s per hit, **THEN** its charge is 0.28 and c_art 2.55 passes, 2.56 fails. **GIVEN** an art whose charge would exceed 0.6, **THEN** the charge is 0.6. **GIVEN** an art granting no stacks, **THEN** its charge is 0.
- **AC-EF-70** [Logic] Rule 5, overflow. **GIVEN** a full pool and regeneration of 6.05, **THEN** the overflow event carries 6.05 and Still Water restores 3.02 health with no cap. **GIVEN** a pool 2 short of full, **THEN** overflow is 4.05.

**Data and UI**

- **AC-EF-45** [Config/Data] **GIVEN** the shipped Effect and status data, **WHEN** the smoke check's lint runs, **THEN** every Effect other than a status has all rule-1 fields with `price: unpriced` and a valid `tier` (statuses carry none), every Effect's `domain` and `tags` match the Domain and tags rule and use only tags in the shared vocabulary (Modifier System rule 9), every keystone and enabler has a non-empty `closes`, every tick has a damage type and every curse a rule; it reports how many records it checked, and any failure names the record.
- **AC-EF-46** [UI] **GIVEN** the tooltips for No Ward and for Seal of Full Payment, **THEN** `closes` appears above the payload; one screenshot each is kept in `production/qa/evidence/`.
- **AC-EF-47** [UI] **GIVEN** a fight with Called Blow, **THEN** the HUD meter is visible, fills on each hit and flashes on payout; screenshots before and at a payout are kept in `production/qa/evidence/`.

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | **How Effects get priced** (plan agreed 2026-11-08). Not by formula: an Effect's value depends on the build. At the end of the project, once the fight engine and content exist: (a) run reference builds against reference enemies with and without each Effect in `tools/balance/` (autoplay bot, NPC cohort, the overnight fight calculator), deterministic and logged; (b) convert the change in time-to-kill and survival to W, using +1 % increased damage as the yardstick; (c) take the value to the builds that want the Effect, not an average across all builds; (d) fix only outliers that break the macro targets (player edge about 0.70; one realm up wins, two realms up about half the time, never three). Until then tiers bound builds, designers size by eye, and the LLM Game Master grants no Effect | user + systems-designer | Balance pass |
| 2 | ~~Combat Formulas F's curse bounds need restating for the new defence: add `curse_heal_taken_max` 0.5, `curse_soul_shred_max` 0.30 and a reapply lockout; restate `curse_shred_max` as resistance points across Sundered and Exposed; retire or remap `curse_pass_raise_max` (no ward pass any more)~~ **Done 2026-11-08:** restated in Combat Formulas F by the Combat revision (#43): `curse_heal_taken_max` 0.50, `curse_soul_shred_max` 30 pp, `curse_reapply_lockout` 2 pulses, `curse_shred_max` on resistance, `curse_pass_raise_max` retired | user + systems-designer | Combat revision (#43) |
| 3 | Closed 2026-11-08: Combat Defence & Healing rule 5 now defines `cannot_slot_wards` and `no_default_ward` (re-review EF 16, CD 11) | — | Closed |
| 4 | Which of the 25 live capabilities close nothing (about 12) and become rule changes, and where each sits in the redesigned tree | user | Meridian Map redesign |
| 5 | About 30 inventory Effects are deferred, not rejected (Five Phases Cycle, Sheathed Blade, Against the Heavens, Home Ground, Standing Array, Seeing Eye, Soul Pressure, Mirror Ward, Spirit Severing, Focused Mind, Empty Hand, One Root, Heaven's Favour and others). Revisit at the tree rework and as Combat keys arrive | game-designer | Meridian Map redesign |
| 6 | The Way, techniques and items will add most Effects. Each new one follows rule 1's record and rules 5–7's limits; the design-build skill should check this catalogue before inventing a piece | user | Way and technique design |
| 7 | Rerolling a chance (Heaven's Favour) needs a new action; decide whether rerolls exist at all next to counted chance | user | When a reroll piece is wanted |
| 8 | Register this GDD's entities: the status catalogue's new curse bounds, `counted_chance`, `standing_status` and the Down step. **Done:** all are in `design/registry/entities.yaml` (checked 2026-11-08); `counted_chance`'s output range is corrected to `floor(counted_start / 1000 + Σ p)` (re-review EF 17) | user | Done |
| 9 | Two ways to pay in health, kept on purpose (re-review EF 15): Blood Casting can put you Down, while Combat's `body_cost_share` never takes health below 1. Record the difference in the Combat revision (#43) | user + systems-designer | Combat revision (#43) |
| 10 | Talismans, Formations, Alchemy, Spirit Beasts, the Event Engine and NPC Builds have no GDD of their own; their back-references to this GDD are added in each host's sweep (re-review EF 19) | systems-designer | Host sweeps |
| 11 | **Balance-pass watch item (EF-05, accepted 2026-11-08c).** Stacked Physical → Chaos `convert_pct` has no cap below 100 %. About 7 notables at +15 pp turn all Physical into Chaos, which passes body shields. Accepted as a slightly OP build. Measure it in the Open Question 1 pass; fix only if it breaks the macro targets | user + systems-designer | Balance pass |

# Sects & Missions (Tông Môn & Nhiệm Vụ)

> **Status**: In Design (redesign of the thin built system, started 2026-11-14; **F3 revised 2026-11-14** for Regional Economy & Trade #43: income reads its Formula I, the market tax applies to cash turnover; consistency check 2026-11-14)
> **Author**: user + Claude
> **Last Updated**: 2026-11-14
> **Last Verified**: 2026-11-14
> **Implements Pillar**: A fixed world with a written history; Living world tick

## Summary

Sects are the only powers of the fixed continent: 7 great sects hold every region, and 15–25 minor sects hold sites
under them as vassals, paying tribute and sending levies. Each sect develops four tracks (Holdings, Institutions,
Military, Trade) and sets five policy dials from its needs and its leader's traits; those choices drive the region's
economy, its wars and its borders every season. For the player a sect is a power to reckon with, an institution to
join, rise in, lead, found or betray, and the source of missions, manuals and standing.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `World Generation & History, Travel & Map, Character Stats, Market; feeds Regional Economy & Trade, Quests, Cultivation Techniques`

## Overview

Sects are the only political and economic powers of the fixed continent (Travel & Map rule 24). Seven **great sects**
(đại tông môn) hold every region between them. Under each great sect sit **minor sects** (tiểu tông môn), which are its
**vassals**: they hold land inside its territory, pay it tribute and owe it service, and they can be drawn into its wars
or break from it. Each sect has a development level and leaders, and the two together decide what the sect does each
season: what it taxes, builds, trades, claims, or fights over. Those decisions are the main input to the economy of the
realm it holds (Regional Economy & Trade, #43, turns them into prices and stock). For the player, a sect is three things
at once: a **power** whose borders and wars shape where it is safe to go and what things cost, an **institution** to join,
rise in, serve and perhaps betray (ranks, duties, missions, loyalty), and a **market** of manuals, pills and teachers.
Without it the world would have a map but no politics, and the economy would have no one making decisions.

*Provisional:* the shape of vassalage, development, leadership and the season tick is designed in Detailed Design below;
nothing in this paragraph fixes a number.

## Detailed Design

### Core Rules

**What a sect is**

1. **Three kinds of holder.**
   - **Great sect** (đại tông môn): the 7 authored powers (4 tier-1, 3 tier-2; Thính Vũ Lâu promoted to tier 1, user decision 2026-11-15). Each holds regions. A great sect has no lord.
   - **Minor sect** (tiểu tông môn): 15–25 authored sects, each inside one great sect's territory and bound to it as a
     vassal. A minor sect holds sites (its seat, towns, mines, fields), never a whole region.
   - **Loose cultivator** (tán tu): belongs to no sect and owns only cave abodes (Travel & Map rule 24).
2. **A sect's record.** Every sect carries: tier and kind, lord (minor sects only), seat, held regions or sites,
   alignment (chính đạo, ma đạo or trung lập, kept from the built game), elemental leaning, leader, elders, members,
   treasury (linh thạch), four development levels (rule 8), five stance dials (rule 12), loyalty (minor sects only) and
   its attitude to every other sect (rule 16). The record lives in the World Database.
3. **Territory belongs to great sects.** A region belongs to one great sect for its whole life, and only a war or an
   event can change that (rules 17–18). Inside a region the great sect and its vassals hold the sites. A site has one
   holder. The map records every change (Travel & Map rule 26).

**Vassals**

4. **Tribute.** Each season a vassal pays its lord a share of its income (the **tribute rate**). The lord's stance sets
   the rate (rule 12), within a floor and a ceiling. Tribute is paid in linh thạch and, if the vassal prefers, in goods
   at the market value of the region.
5. **Levy.** When its lord is at war, a vassal sends a share of its fighting members (the **levy**) and may be called
   to defend. Sending fighters costs the vassal members and treasury, and a vassal that refuses loses loyalty.
6. **Loyalty** (0–100, vassals only) moves each season with: tribute against what the lord gives back (protection,
   share of trade, rank for its leader), the lord's strength against the vassal's neighbours, and the two leaders'
   traits. Below the **break line** a vassal may rebel (a war against its lord), or ask another great sect that borders
   it to take it as a vassal. A great sect never forces a vassal out except by war.
7. **Vassals of vassals do not exist.** There are two tiers of power, and no more. A minor sect's own branches are
   members' halls, not sects.

**Development**

8. **Four development tracks**, each a level that starts from the sect's authored history and has no maximum
   (scale without caps). A leader pays linh thạch and seasons to raise one level at a time, and a level costs
   more than the one before it. A track can also fall (unpaid upkeep, war, a lost site).
   - **Holdings** (cơ nghiệp): mines, herb fields, spirit veins, gathering arrays and other layer-2 works on the sect's
     land (Travel & Map rules 31–33). It sets how much of the territory's production the sect actually collects.
   - **Institutions** (đạo tràng): halls, libraries, schools and the sect's manual stock. It sets how many members the
     seat can house, what manuals and teachers it offers, and how many good disciples it recruits.
   - **Military** (võ bị): guards, wardens, war fleets and formations. It sets the sect's strength in wars, its power to
     keep roads safe, and how many raids on its land succeed.
   - **Trade** (thương lộ): roads, caravans, teleport arrays (truyền tống trận) and market charters. It sets how many
     markets the sect links, the fees on its arrays, and the share of trade it taxes.
9. **Development drives the economy.** The four levels feed the production contract (Travel & Map rule 25) and Regional
   Economy & Trade (#43): Holdings scales what a region produces for the sect, Trade scales what flows between markets,
   Institutions scales the stock of manuals, pills and teachers, and Military scales how safe the flow is. A great
   sect's effective level in a track counts its own investment plus half of its vassals' investment, converted back to
   a level (Formula F1; user decision 2026-11-14). Layer-2 works on sect land are gated by Holdings (Formula F2).
   *(Amended 2026-11-23, Provinces #48, user decision:)* layer-2 works are now **province buildings**, built and upkept as
   works are (their upkeep is F3's `works_due`). Each track level **caps** the level of its building kinds in the sect's
   provinces: Holdings caps production buildings (the F2 gate), Trade caps logistics buildings and market halls (which
   set a province's market access, Regional Economy & Trade Formula A), Military caps warding walls, Institutions caps
   gathering arrays and pavilions (Provinces rule 9). Tracks stay sect-wide levels.
10. **Treasury.** Income is the sect's share of production and trade after its vassals' tribute, plus tribute from
    vassals, plus a fee on the missions posted on its boards. Mission rewards are paid by the **client** (towns,
    merchants, villages, out of the production the sect does not collect); the sect keeps a fee (user decision 2026-11-14).
    A treasury above one year's reserve is invested, not hoarded (Formula F3). Costs are member stipends (kept: by realm), upkeep for developed works, investment
    in a track, and war. A sect that cannot pay stipends loses members and loyalty, and a vassal that cannot pay tribute
    loses standing with its lord.

**Leaders and policy**

11. **Leaders are people with traits.** A sect's head (tông chủ) is a named person in the World Database with
    **personality, lifestyle and congenital traits** (NPC Traits #42, in the spirit of the character traits of
    grand-strategy games). Elders (trưởng lão) have traits too. Sects read only a leader's **stance pulls**: a plain list
    of dial changes and event weights that each trait carries. Until #42 is designed, a short provisional trait list in data
    supplies these pulls (`design/gdd/npc-traits.md`, the #42 seed: 37 personality traits in 18 opposed sets and 6
    callings, user decision 2026-11-14, modelled on the trait structure of grand-strategy character games). A leader or elder has **3
    personality traits** (never both sides of a set) and **1 calling**. Replacing the table with #42 must not change
    this section; only the pull kinds of F15 are the contract.
12. **Five stance dials**, each a level the leader sets:
    - **Tax** (thuế): the tribute rate on vassals (F4) and the rate on towns and markets in the territory (`tf`, F3).
    - **Expansion** (khuếch trương): how readily the sect goes to war for sites, vassals and regions, and how big a goal it names (F18). A peaceful purchase or claim of sites is not designed here.
    - **Openness** (mở cửa): trade tariffs, array fees, and whether outsiders may buy manuals and enter the seat.
    - **War readiness** (chiến bị): the Military share of what the sect invests (F19), and how quickly the sect goes to war.
    - **Recruitment** (thu đồ): how wide the sect opens its gate, and how it ranks who enters.
13. **How a stance is set.** The sect starts each season with a stance that is the **sum of its needs** (an empty
    treasury raises Tax, a hostile neighbour raises War readiness, a failing track raises its investment) and
    its leader's **trait pulls**. The leader's choice moves the dials one step toward that target. A leader with
    strong traits (F15: Impatient or summed pulls of 3 or more) moves further and faster.
14. **Notable choices become events.** When a leader sets a dial across a threshold, picks a war, or breaks a pact,
    the event engine records it and the LLM game master may narrate it. The LLM never sets a stance, only the engine does
    (Bounded LLM game master).
15. **Succession.** When a leader dies or is deposed, the sect's successor takes over (same rank first, then the
    nearest rank above, then below; as built). The new leader's traits change the target stance, and the dials move toward
    it step by step, so the sect does not change character overnight.

**Politics**

16. **Four states between two sects:** peace, pact (an agreement to trade, to defend, or both), feud (open raids, no
    full war) and war. Attitude (−100 to 100) between two sects moves with borders, trade, alignment, leaders' traits and
    events. Only great sects fight great sects. A vassal only fights for its lord, or against the lord in a rebellion.
17. **War** is abstract and resolves once a season from the two sides' strength (Military, members' realms, levy and
    formations). A won war moves sites, and a decisive one moves a region. A great sect that loses all its regions
    falls, and its vassals pass to the winners. **The seat region is protected:** a war may take it only when the
    defender's strength is below half of its strength at the start of the game (S0, F9), so a fall comes after a long
    decline, not one bad war (user decision 2026-11-14).
18. **The map follows the politics.** Territory changes are written to the map when they happen. A change in holder
    changes tribute, taxes and who may use an array on that land from the next season.

**Members**

19. **Rank ladder** (kept from the built game): outer disciple (ngoại môn) → inner disciple (nội môn) → elder
    (trưởng lão) → sect head (tông chủ). A rank needs a realm gate and enough **contribution** (cống hiến). Contribution comes
    from missions, duties and gifts to the sect, and is spent on manuals, pills, promotion and **services** (rule 19a).
    Each rank has a stipend (by realm, as built), a duty (seasons of service a year) and a **residence grade** (Travel &
    Map rule 33).
19a. **Services and privileges** (user decision 2026-11-14). Contribution also buys what costs the sect little, so
    high-realm members always have a use for it. Each is priced by F14, and each owner system decides its own effect:
    - **Array and realm access:** use of the sect's teleport arrays without a fee, and a place in the sect's quota for a
      secret realm (bí cảnh) it controls when the realm opens (Travel & Map rule 26).
    - **An elder's guidance:** a season of an elder's help with cultivation or a breakthrough attempt (the bonus belongs to
      Realms & Bottlenecks; until Realms defines it, this service is not offered).
    - **Borrowing a treasure:** a sect treasure for some seasons, against a deposit in contribution that is returned when
      the treasure is. Losing it costs the deposit and standing.
    - **Protection and a levy call:** the sect warns off or hunts a named enemy of the player, or sends members to help in
      the player's own feud. Only at good standing; the sect refuses a call against an ally.
    - **A voice in the council** (elders only): a pull of +1 or −1 on one dial for 4 seasons, added to the leader's pulls
      (F6). It is how an elder prepares a bid for the head seat (rule 28).
    Top-grade stock (Nguyên Anh and Hóa Thần goods) stays rare, refills slowly with Institutions, and is gated by rank.
20. **Joining.** A loose cultivator who passes the sect's gate (spiritual root fit if the sect asks, a realm floor,
    **standing** at least the recruit line, and the sect's Recruitment dial) joins as an outer disciple. A minor sect's
    gate is easier, its teaching and manuals smaller, and its lord's reach can pull you into its levy.
20a. **Masters at joining** (user decision 2026-11-21). When a sect takes in an NPC (F17 intake or rule 20), with chance
    `master_share` (0.3, World Generation rule 8's share, so it holds after the first generation) it gives the newcomer
    a master: a living member of a higher realm with fewer than `disciples_max` (3) living disciples, weighted
    `w = 1 + rank index` (outer 1, inner 2, elder 3, head 4; rank follows realm, rule 19). The pair holds sư đồ (NPC
    Relationships rule 8, sect life), and the newcomer's traits roll with the master's lean (NPC Traits F5). No eligible
    member: no master. The player is never assigned one; they ask through the bond verb.
21. **Standing** (−100 to 100, per sect and per player) is what a sect thinks of the player. It sets offers, prices
    (a discount at good standing, a surcharge at poor), who recruits you, which manuals you may buy, and whether the
    sect hunts you. This answers Quests open question 10. Harming a sect's members, stealing, deserting or breaking a
    mission lowers it, and the sect's allies and vassals share part of the fall.
22. **Leaving.** A member may leave on good terms (pay what was borrowed, give up the residence), or desert. Deserting
    costs standing with the sect and its allies and marks the player as hostile at the threshold (Quests
    `hostile_threshold`); a great sect's reach is its whole territory.
23. **Betrayal and defection.** A member may sell a secret, take a manual, or lead an enemy in. The act is an event
    with a consequence in the sect's records, such as a lost manual, a lost site, or a fallen vassal.
23a. **Forbidden manuals** (chân truyền; user decision 2026-11-14). A sect's core manuals carry its **owner tag**. A member
    may receive one only at inner-disciple rank or above, for contribution. Markets in the owner's territory refuse to buy
    a tagged manual; elsewhere it sells at ×1.5 (a black market). After a sale or a gift, each season the owner may learn
    of it (F16). Discovery is a betrayal for the seller and a theft for the holder: standing −40 with each (F10), and the
    sect may post a hunt for them. Learning a tagged technique is not itself a crime; holding or passing on the manual is.

**Missions**

24. **Mission board.** Each sect seat and each large town in a sect's land has a **board** with several offers a season.
    The offers come from the sect's own state, not from a fixed list: a war posts raid and defence work, a shortage posts
    gathering and escort work, a feud posts hunts, a dispute with a vassal posts diplomacy. The sect's tracks, stance and
    needs set which kinds appear and how well they pay. **One board, two lists** (user decision 2026-11-14): the board the
    player reads at a sect hall or large town shows this list of missions and, beside it, the Quests standing board
    (Quests rule 2, `board_size`). Each list keeps its own rules, count and refresh; a quest's `mission` stage may point at
    a mission on the same board.
25. **A mission stays a one-season income action** (Quests: repeatable, stateless). Its reward is linh thạch scaled by the
    player's realm (kept: `sect_base_income`, `income_realm_scale`), contribution, and standing. Above Kết Đan the cash
    is capped by the board sect's income and the rest is paid as contribution (Formula F12; user decision 2026-11-14). A mission is also a
    valid Quests `mission` stage, with its income withheld.
26. **Missions are the member's link to politics.** A mission's result nudges the sect's own state: a won raid or a
    delivered cargo helps the sect, a failed one costs it.

**The player and the sect order**

27. **The player's four standings:** *loose* (no sect), *member* (outer disciple to elder), *leader* (sect head) and
    *founder* (a sect of the player's own). The player may change standing in play, subject to the rules below.
28. **Rising to leader.** An elder who has the realm, the contribution and enough standing may stand when the head
    seat is open (death, retreat or resignation), or may challenge the head by a trial the sect names. Becoming head makes
    the five dials and the investment of the track levels the player's choice each season, at the cost of seasons.
29. **Founding a sect.** A player of at least a stated realm, with a developed seat (a cave abode of at least a stated
    density), a stated sum, and enough disciples, may found a **minor sect** inside one great sect's territory. It
    starts as that great sect's vassal, and may break away later by war (rule 6). A founded sect has its own record, dials
    and development like any other minor sect. The seat's stacked density counts only **active** home works; a work held dormant for lack of slots counts for nothing (`design/gdd/cave-abode.md` rules 3, 9).
30. **NPCs found sects too.** Each season, in a great sect's territory that holds fewer minor sects than its authored
    count, one NPC who meets rule 29's terms may found a minor sect (chance 0.05 a season, a guess). This replaces fallen
    minor sects over time, so the world keeps 15–25 of them.

*All numbers named "stated" or marked as thresholds are guesses until Formulas and the balance pass.*

### States and Transitions

**The season tick.** Every sect, great and minor, runs these steps once at each season's end, in this order. Great sects
go first, then their vassals, so tribute and levy see the lord's new stance.

1. **Collect:** income from production, trade, tribute and missions (rule 10).
2. **Pay:** tribute to the lord (vassals), then stipends, then upkeep (F3's order). Tribute paid in season s counts in
   the lord's income in season s + 1, because the lord collects before its vassals pay.
3. **Set stance:** needs plus trait pulls give the target, and each dial moves one step toward it (rule 13).
4. **Invest:** the treasury share F3 allows (`inv_frac`, or the leader's invest share) goes into the track F19 picks, and War readiness sets the Military share of F19's mix (rule 8); the money accumulates there until it pays the next level's cost, then the level rises.
5. **Politics:** attitudes move, states change (below), wars resolve (rule 17).
6. **Loyalty:** vassals' loyalty moves, and a vassal under the break line decides whether to act (rule 6).
7. **Members:** intake (F17), rank by realm, stipend-shortfall desertions (F3), succession (rule 15). Deaths and breakthroughs come from the world tick and Realms; war losses from F9.
8. **Publish:** the sect's development levels and holdings go to the production contract and the map.

**A sect's own state**

| State | Enters when | Leaves when |
|---|---|---|
| **Thriving** | Treasury ≥ R (F3: one year of all costs), and no track has fallen in the last 4 seasons | Treasury drops below R, or a track falls |
| **Steady** | The default | Moves up or down on the tests either side |
| **Strained** | Treasury cannot cover the next season's stipends, or the sect lost a site this year | Two seasons paid in full |
| **Collapsing** | Strained for 4 seasons in a row (guess), or the seat is lost | It recovers to Strained, or falls |
| **Fallen** | A great sect has no region left, or a minor sect has no seat | Never: a fallen sect is history. Its members become loose cultivators or join the victor; its manuals and treasury go to the victor or are scattered as hidden places. |

Strained and Collapsing sects lose members each season and their stance swings toward Tax and against Openness. The
player sees these states in the sect's description and in rumours.

**A vassal's loyalty**

| State | Loyalty (guesses) | Behaviour |
|---|---|---|
| **Loyal** | 60 and above | Pays in full, sends the full levy |
| **Restless** | 30–59 | Pays, sends a reduced levy; the lord's stance may lower Tax to win it back |
| **Defiant** | below 30 (the break line) | Each season runs the ordered checks of F5b: seek a new lord, rebel, or pay late |
| **Rebelling** | It declared a war on its lord | Pays nothing; fights the lord in the war (rule 17) |

After a rebellion: if the lord wins, the vassal returns as Restless with its leader replaced or removed. If the rebel
wins, it chooses a bordering great sect as its new lord, or, if the war moved a whole region to it and its head is
Nguyên Anh or above, it becomes a **great sect** of tier 2 (rare; user decision 2026-11-14). Changing lords peacefully drops loyalty to 50 with the new lord.

**Relations between two sects**

```
            attitude ≥ pact line + both agree
   peace  ─────────────────────────────────▶  pact
     ▲  │ ◀────────────────────────────────    │
     │  │      broken by either / expires      │ broken (event, attitude collapses)
     │  ▼ attitude ≤ feud line                 ▼
   (truce)  feud ───────────────────────────▶ war
     ▲         leader chooses war (needs       │
     └──────── War readiness ≥ line)  ─────────┘ resolved: one side wins, or both accept a truce
```

- A **truce** lasts a set number of seasons (guess: 8). While it lasts, neither side may declare war, and attitude
  recovers toward 0.
- Only great sects may enter war with great sects. A vassal enters its lord's wars as levy, not as a party.
- Breaking a pact is a notable choice (rule 14). It costs attitude with every sect that holds a pact with the breaker.

**A war**

| Step | What happens |
|---|---|
| **Declared** | The aggressor names a goal: a site, a region, or a vassal. Its own vassals are called; their loyalty is tested. |
| **Fighting** | Each season the two sides' strength is compared and the result shifts a war score. Each side loses members, treasury and Military level. Raids hit the land's production in both territories. |
| **Resolved** | When the war score reaches the goal's threshold, the side ahead takes the goal. Otherwise, after the leaders' weariness passes their trait limit, both accept a truce. |

**The player's standing in a sect**

```
 loose ──join──▶ outer disciple ──▶ inner disciple ──▶ elder ──▶ sect head
   ▲                  │                  │              │          │
   └──── leave on good terms ◀───────────┴──────────────┴──────────┘
   ▲                  │
   └── desert ◀───────┘ (from any rank: standing falls, hostile at the threshold)

 loose (with realm, seat, sum, disciples) ──found──▶ founder of a minor sect (vassal) ──rebel and win──▶ free choice of lord
```

- Promotion needs the rank's realm gate and contribution (rule 19). Demotion follows failed duties or a punishment event.
- A member may hold one sect at a time. Founding a sect means leaving the old one first.
- A sect head who leaves the seat for a set number of seasons without naming a deputy loses it to succession.

### Interactions with Other Systems

| System | Direction | What passes between them |
|---|---|---|
| **Travel & Map** (#25) | in / out | In: regions, sites, seats, terrain, the layer-2 works on sect land, teleport arrays, residence grades. Out: who holds each region and site, territory changes, array fees and access, rent on sect grounds. |
| **Regional Economy & Trade** (#43) | out / in | Out: each sect's development levels, Tax and Openness dials, tariffs, which markets its Trade links. In: market prices and the region's production in value, which feed the sect's income. |
| **Market** (#20) | out | A sect's manual and pill stock, its prices by the player's standing, and whether it sells to outsiders (Openness). |
| **World Generation & History** (#27) | in | The authored sects: names, seats, starting regions and sites, vassals, starting development, alignment, leaders, and the history of past wars and fallen sects. |
| **World Database** (#3) | in / out | The sect records, members, leaders, attitudes, wars, and events. |
| **NPC Traits** (#42) | in | Each trait's stance pulls and event weights for leaders and elders (rule 11). Until #42 exists, a provisional trait table. |
| **Event Engine** (#23) and the **LLM game master** (#29) | out / in | Out: notable choices, wars, rebellions, successions, falls. In: event outcomes inside engine budgets that move attitude, loyalty or standing. The LLM never sets a dial. |
| **Living World Tick** (#28) | in | Calls the sect season tick for every sect each season. |
| **Quests** (#31) | out / in | Out: the mission action as a `mission` stage, the boards, base income, `hostile_threshold`, standing. In: quest outcomes that move standing. |
| **Cultivation Techniques** (#9) | out | Sect libraries hold techniques; a sect's Openness and the player's standing decide sales; sects may forbid the sale of their own manuals; the rule 18 duties (reserved copy, fallback stock). |
| **Character Stats** and **Realms** (#8) | in | The player's and members' realms for gates, stipends, mission pay and war strength. |
| **Combat** | in | Not used for war, which stays abstract. Duels, trials for the head seat and mission fights use the combat engine as built. |
| **Item Database** | out | Sect rewards (named templates, as Item Database line 240 waits on). |
| **Guidance Layer** (#35) | out | Sect states, offers and threats the advisor can surface. |
| **Time & Turn** (#4) | in | The season clock, and seasons spent on missions, duties and leader decisions. |

## Formulas

All values are **guesses** until the sect season tick runs in the Balance Simulation Harness (#33) for 400 seasons
(Acceptance Criteria). Specialists consulted: `systems-designer` (F1–F13), `economy-designer` (budgets, cost curve,
dampers). Realm-indexed lists run Luyện Khí / Trúc Cơ / Kết Đan / Nguyên Anh / Hóa Thần. All values live in a new data
file, `assets/data/sects.json`, unless marked as built.

**Anchors.** Stipends per season are the built yearly stipends ÷ 4: 3 / 20 / 50 / 325 / 2,500. Mission pay is
`sect_base_income` 10 × `income_realm_scale` 1 / 8 / 60 / 400 / 3,000 (built). The world census is 3,936 / 844 / 191 /
27 / 3 cultivators by realm (Realms, Formulas C2). The world's mines make about 124k linh thạch a season (Travel & Map,
Formula L). A sect gathering array costs 193,313 to reach level 5 (Travel & Map, Formula J).

**Season budgets these formulas aim at** (economy-designer; production outside mines is a guess until #43):

| Per season | Tier-1 great sect | Tier-2 great sect | Minor sect |
|---|---|---|---|
| Members (LK / TC / KĐ / NA / HT) | ~400 (300 / 75 / 20 / 4 / 1) | ~250 (181 / 55 / 12 / 2 / 0) | ~55 (43 / 10 / 2 / 0 / 0) |
| Income | 20,000–31,000 | 8,000–9,000 | ~1,800 |
| Stipends | ~7,200 | ~2,900 | ~430 |
| Left to invest | 10,000–22,000 (FX-T1: 20,090) | ~3,400 | ~650 |

*(2026-11-14: costs now count cash only (F3), so "left to invest" rises; the tier-1 range is re-derived from FX-T1, the tier-2 and minor figures are the earlier estimates until AC-SM-42 is re-run.)*

### F1. Track cost, upkeep and effective level

The track_cost formula is defined as:

`cost(T, L) = c0_T · g^(L−1)` · `C(T, L) = c0_T · (g^L − 1) / (g − 1)` · `upkeep(T) = u · C(T, L)` a season ·
`L_eff(T) = log_g(1 + (g − 1) · (C_own + w_v · Σ C_vassal) / c0_T)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| L | int | 0 – no maximum | World DB | The level of track T |
| c0_T | int | Holdings 2,000; Institutions 2,500; Military 2,000; Trade 1,500 | data file | Cost of level 1 |
| g | float | 1.4 | data file | Growth per level. Array growth (2.5) would act as a hidden cap near level 10 |
| C | float | 0 – ∞ | calculated | Total invested to reach L |
| u | float | 0.01 | data file | Upkeep, a share of the total invested. Built works run 0.3 %–4.8 % |
| w_v | float | 0.5 | data file | Weight of vassals' investment in the lord's level (user decision 2026-11-14) |
| L_eff | float | 0 – ∞ | calculated | The great sect's effective level (real, not rounded), used in F2 |

Two unpaid seasons in a row drop a track one level, as layer-2 works do (Travel & Map rule 31).

**Output Range:** no maximum level. Upkeep grows with C until it eats the surplus. A tier-1 sect settles near level
11–14 (11 at 20,000 income, about 13.5 at 31,000), a tier-2 near 9, a minor sect near 4–5. Authored starting levels must sit at or below these, or tracks decay from
the first season.
**Example:** Holdings 10 costs 2,000 · 1.4⁹ = 41,322 for the last level and C = 139,627 in total, upkeep 1,396 a
season. A lord at Holdings 10 with four vassals at Holdings 5 (C = 21,891 each) has
L_eff = log₁.₄(1 + 0.4 · (139,627 + 0.5 · 87,564) / 2,000) = log₁.₄(37.7) = **10.8**.

### F2. Track effects

The track_effect formula is defined as:

`collect = s_max · (H + 1) / (H + 1 + H_half)` · `work_max = ⌈H / 2⌉` · `trade_mult = 1 + t · T` ·
`capacity = cap_base · (1 + i · I)` · `mil_mult = 1 + m · M` · `road_danger = d^M`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| H, T, I, M | float | 0 – ∞ | F1 (L_eff for great sects) | Holdings, Trade, Institutions, Military |
| s_max | float | 0.6 | data file | The share of production a sect can approach and never reach (user decision 2026-11-14) |
| H_half | float | 6 | data file | Extra levels at which half of s_max is reached |
| work_max | int | 0 – ∞ | calculated | Highest layer-2 work level the sect may build on its land; the works keep Travel & Map's prices |
| t, i, m | float | 0.15; 0.25; 0.10 | data file | Gain per level |
| cap_base | int | great 160; minor 25 | data file | Members the seat houses at I = 0 (rounded down after the multiplier) |
| d | float | 0.92 | data file | Road-encounter multiplier per Military level (Travel & Map danger) |

**Output Range:** collect runs from 0.086 at H = 0 toward 0.6. The others have no maximum.
**Example:** a tier-1 sect at 6/6/6/6 collects 0.323, trade_mult 1.9, houses 400, mil_mult 1.6, road danger ×0.61.
Holdings 6 → 7 costs 15,059 and adds 989 a season on 50,000 of production, with 151 more upkeep: about 18 seasons to
repay. The level-5 sect array (193,313) needs Holdings 9 (a great sect's fractional L_eff needs more than 8).

### F3. Income, costs and the treasury

The treasury formula is defined as:

`Inc = Inc_mine + Inc_goods + Inc_tariff + tf · trade_mult · share_s · Turn_m + Σ trib_in + fee · Σ board_cash` · `tf = tf0 + tf_step · Tax` · `share_s = V_own[s] / Σ_{s' in m} V_own[s']`
`Cost = Σ_r n_r · stip_r − kind + (1 − goods_frac) · (Σ upkeep + works_due) + trib_out + war_cost + draw` · `draw = draw_mult · stip_head` *(cash only, user decision 2026-11-14: the in-kind share of stipends, upkeep and works is paid from collected goods and shows only as lower `Inc_goods`, so it is not also a cost)*
`R = 4 · Cost` · `invest = max(0, Tr + Inc − Cost − R) · inv_frac` · `Tr' = Tr + Inc − Cost − c_inv · invest` · `c_inv = inv_miss + (1 − inv_miss) · (1 − goods_frac)`
*(Regional Economy & Trade Formula H, design-review 7, user decision 2026-11-14: `invest` is the only spender of a treasury's surplus. `inv_miss` (0.5) of it is posted as missions from the treasury, with no mission fee on the sect's own board; the rest goes to the track F19 picks, where the `goods_frac` share is met in kind from collected goods, lowering `Inc_goods`, and only the cash half leaves the treasury. So `Tr'` subtracts the cash share `c_inv` (0.75), not all of `invest`. A player head cannot take missions from their own sect's treasury.)*

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| Inc_mine, Inc_goods, Inc_tariff | float | ≥ 0 | Regional Economy & Trade Formula I | Mine cash the sect collects, collected goods actually sold (after its own use and stipends in kind), and tariffs on imports. Goods are money only once sold |
| Turn_m | float | ≥ 0 | Regional Economy & Trade (Formulas C–E) | Money paid for goods in the sect's market this season (goods actually bought × P) |
| V_own, share_s | float | ≥ 0; 0–1 | Regional Economy & Trade Formula I | Production value of the sect's land, shown and used only as a weight: share_s is the sect's share of its market's V_own, so minor sects tax their part of the market |
| tf | float | 0.05 – 0.15 | calculated | Share of the land's trade the sect taxes: `tf0` 0.05 + `tf_step` 0.025 · Tax, so 0.05 / 0.10 / 0.15 at Tax 0 / 2 / 4 (user decision 2026-11-14). The same Tax dial sets the tribute rate (F4) |
| draw, draw_mult, stip_head | float | draw_mult Temperate 1 (default), Indulgent 4 | F15, data file | The head's draw from the treasury, on top of the head's stipend: `draw_mult` times the stipend of the head's realm, paid every season (user decision 2026-11-14). F13 sets the embezzlement ceiling |
| open[O] | float | 0.6 / 0.8 / 1.0 / 1.15 / 1.3 by Openness 0–4 | data file | Retired from the tax (2026-11-14): Openness now acts through links and tariffs (Regional Economy & Trade rules 12–14); kept for array fees and outsider access |
| trib_in, trib_out | float | ≥ 0 | F4 | Tribute received and paid |
| fee | float | 0.20 | data file | The sect's fee on missions posted on its boards, paid by the client on top of the reward |
| board_cash | float | ≥ 0 | F12 | Cash paid out on the sect's boards this season |
| n_r, stip_r | int | stip 3 / 20 / 50 / 325 / 2,500 | World DB; built (yearly ÷ 4) | Members and stipend by realm |
| works_due | float | ≥ 0 | Travel & Map Formula L (`works_upkeep_due_lt`) | Upkeep of layer-2 works |
| kind, goods_frac | float | ≥ 0; 0.5 | Regional Economy & Trade Formula I (`kind_stipend`), Formula C | Stipends paid in goods (pills and herbs), and the share of upkeep and works met in kind; neither is cash |
| war_cost | float | ≥ 0 | F9 | Cost of a war season |
| R | float | ≥ 0 | calculated | One year's reserve; the Thriving test |
| inv_frac | float | 0.5 | data file | Share of the treasury above the reserve that is invested (damper against hoarding) |

Order of cuts when money runs short: investment first, then the head's draw, then upkeep, then stipends. Tribute is paid before stipends, and the draw is paid last.

**Output Range:** see the season budgets above. A minor sect's margin is thin on purpose: minor sects fall and are
replaced; great sects rarely fall.
**Example (tier-1):** FX-T1 at levels 6/6/6/6, Openness 2, Tax 2 (tf 0.10): mine cash 7,938 + goods sold 5,834 + tariffs
1,800 (Regional Economy & Trade Formula I) + market tax 0.10 · 1.9 · 0.8 · 60,000 = 9,120 + tribute 976 (four vassals as in F4)
+ fees 4,000 = **29,668**. Cash costs: stipends 7,200 less 1,100 paid in kind (6,100) + half of track upkeep 1,306 and works 5,000 (3,153) + a Temperate Nguyên Anh head's draw 325 = **9,578**. Surplus 20,090 a season.
With a treasury of 60,000 and R = 38,312, it invests 0.5 · (60,000 + 20,090 − 38,312) = 20,889. Of that, 10,445 is reserved for missions (paid on completion, returned if untaken; Regional Economy & Trade Formula H) and 10,444 goes to a track, half in kind (5,222, taken from collected goods, so `Inc_goods` falls by that much) and half in cash and burned (5,222). The treasury commits 15,667 in cash (`c_inv` 0.75) and ends at 60,000 + 20,090 − 15,667 = 64,423, before the in-kind adjustment to `Inc_goods`. *(Re-derived 2026-11-14 for the cash-only Cost; was Cost 13,831, R 55,324, invest 10,257, Tr' 68,145.)*

### F4. Tribute

The tribute formula is defined as:

`rate = r_floor + (r_ceil − r_floor) · Tax / 4` · `tribute = rate · gross_v · pay[state]`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| Tax | int | 0–4 | lord's dial (F6) | The lord's Tax dial |
| r_floor, r_ceil | float | 0.05; 0.30 | data file | Lowest and highest rate |
| gross_v | float | ≥ 0 | F3 | The vassal's income before costs, without mission fees |
| pay[state] | float | Loyal 1; Restless 1; Defiant 0.5; Rebelling 0 | data file | Share actually paid by loyalty state |

**Output Range:** 0–30 % of the vassal's gross. Four vassals bring a tier-1 sect about 3 % of its income at Tax 2 and
about 5 % at the ceiling, so tribute is a political lever, not a lifeline.
**Example:** Tax 2 gives a rate of 0.175. A vassal grossing 1,394 pays 244.

### F5. Vassal loyalty

The loyalty formula is defined as:

`ΔLoy = k_tax · (2 − Tax) + k_prot · clamp(log₂(S_lord / S_threat), −1, 1) + Σ pull + k_rest · (60 − Loy) − k_refuse · refused + events`, Loy kept in 0–100

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| Loy | float | 0–100 | World DB | The vassal's loyalty |
| k_tax | float | 2 | data file | Pull of the Tax dial |
| k_prot | float | 2 | data file | Pull of the lord's strength against the threat |
| S_lord, S_threat | float | > 0 | F8 | The lord's strength; the strongest bordering great sect that is not the lord |
| pull | int | −3 – 3 | NPC Traits #42 | Both leaders' stance pulls on loyalty |
| k_rest | float | 0.05 | data file | Drift back toward 60 |
| k_refuse | int | 10 | data file | Loss for a refused levy |
| refused | int | 0 / 1 | calculated | Whether the vassal refused a levy this season |

**Output Range:** a steady pressure p settles at 60 + p / k_rest. Tax 4 under a strong lord settles at 20, below the
break line (30).
**Example:** Tax 3 (−2), a lord 1.34× the threat (+0.84), a greedy vassal head (−1), loyalty 55 (+0.25): **−1.91**.

### F5b. A Defiant vassal's choice

Each season a Defiant vassal runs these checks in order and takes the first that passes (user decision 2026-11-14).
An Ambitious leader runs check 2 before check 1.

1. **Seek a new lord** if a bordering great sect B (not its lord) has attitude to the vassal ≥ 20 and attitude to the
   lord ≤ 0. B accepts and the vassal changes lord peacefully (loyalty 50); the old lord's attitude to B falls by 20.
2. **Rebel** if `(S_v + S_backer) / S_spare ≥ rebel_odds`.
3. Otherwise **pay late**: half tribute (F4 `pay` 0.5).

The rebel test is defined as:

`rebel if (S_v + S_backer) / S_spare ≥ rebel_odds`, with `S_spare = S_lord / wars_lord`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| S_v | float | > 0 | F8 | The vassal's own strength |
| S_backer | float | ≥ 0 | F8 | Strength of a great sect with a defence pact with the vassal, or attitude ≥ 40 to it and ≤ −40 to the lord; else 0 |
| S_lord | float | > 0 | F8 | The lord's strength |
| wars_lord | int | ≥ 1 | World DB | Wars the lord is fighting, counting the rebellion (so at least 1) |
| rebel_odds | float | 1.0; Ambitious or Brave 0.8; Cautious or Content 1.3 (lowest applies) | data file, F15 | Ratio the vassal needs |

**Output Range:** a lone vassal almost never rebels against a lord at peace; it rebels when the lord is fighting
several wars or a rival great sect backs it.
**Example:** a vassal at 600 with a backer at 5,000, against a lord at 10,977 already in one war (S_spare =
10,977 / 2 = 5,489): 5,600 / 5,489 = 1.02 ≥ 1.0, so it rebels.

### F6. Stance target and step

The stance formula is defined as:

`target_d = clamp(2 + Σ need_d + Σ pull_d, 0, 4)` · `dial' = dial + sign(target_d − dial) · min(|target_d − dial|, 1 + bold)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| dial | int | 0–4 (2 neutral) | World DB | Each of the five dials |
| need_d | int | −2 – 2 | calculated | **Tax:** +1 if the treasury is under R, +2 if Strained, −1 if Thriving or a vassal is Restless or worse. **War readiness:** +1 per feud, +2 at war. **Recruitment:** +1 under 0.8 · capacity, −1 over capacity. **Openness:** −1 if Strained or at war. **Expansion:** +1 if Thriving and a neighbour is weaker than 1 / 1.5, −2 at war |
| pull_d | int | −3 – 3 | NPC Traits #42 (provisional table until then) | The leader's trait pulls on that dial |
| bold | int | 0 / 1 | calculated | 1 if the leader's absolute pulls, summed over all five dials, are 3 or more |

Needs on one dial add up (a feud and a war give War readiness +3), and their sum is clamped to −2 – 2 before pulls
are added.

**Output Range:** 0–4 for each dial. A dial moves 1 step a season (2 for a bold leader).
**Example:** a treasury under R (+1) and a greedy head (+1) give a Tax target of 4. The dial moves from 2 to 3.

### F7. Attitude between sects

The attitude formula is defined as:

`A_tgt = align[a, b] + b_k · borders + p_k · pact + Σ pull + g − bp − fr` · `ΔA = sign(A_tgt − A) · min(5, |A_tgt − A|, max(1, round(k_a · |A_tgt − A|))) + events` (round half away from zero;
attitude always reaches its target, with no dead band)

Lines: a **pact** forms when A ≥ 40 both ways. A **feud** starts when A ≤ −40 one way and ends when A ≥ −20. **War** is
declared from a feud when War readiness ≥ 3 and S_self / S_other ≥ war_odds' (F18: war_odds lowered by Expansion above 2), where S_other includes the target's
defence-pact partners. A **truce** lasts 8 seasons with A_tgt = 0.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| A | float | −100 – 100 | World DB | One sect's attitude to another |
| align | int | same alignment +20; chính vs ma −30; else 0 | data file | Alignment term |
| b_k | int | −5 | data file | Per shared border region |
| p_k | int | 15 | data file | For a standing pact |
| g | int | −30 – 0 | World Generation rule 7 | Authored grudge from the history (user decision 2026-11-15); fades toward 0 by `grudge_fade` (guess 1) a year; 0 for pairs with none |
| fr | int | 0 – fr_max | calculated | **Site friction** (user decision 2026-11-21): `round(fr_max · (1 − 2^(−V / V_half)))`, V the summed base value a season (base output × unit value, Travel & Map Formula H) of the border sites: resource sites (Travel & Map rules 19–20: mines, spirit veins, beast lairs, special sites) in a region either sect holds that borders a region the other holds. Same both ways; great sects only |
| fr_max | int | 30 | data file *(guess)* | The most a pair loses to friction |
| V_half | float | 45,000 | data file *(guess)* | Border-site value a season that gives half of fr_max; a large spirit vein makes 28,800, a large mine 15,000 (user decision 2026-11-21, after V was corrected from units to value) |
| bp | int | 0 – ∞ | calculated | Balance of power: toward the strongest sect only, 1 per 10 % its strength exceeds the runner-up's (damper against one sect snowballing) |
| k_a | float | 0.15 | data file | Speed toward the target |
| war_odds | float | 1.0; traits 0.8–1.2 (F15: Cruel 0.8, Cautious 1.2) | data file, traits | Strength ratio a leader needs to declare war |
| rivals | set | — | calculated | For a pull "to rivals" (F15, e.g. Cruel −10): the sects sharing at least one border region with a (user decision 2026-11-21) |

**Output Range:** −100 to 100.
**Example:** chính vs ma, 2 shared borders, a Cruel head (−10 to rivals): A_tgt = −50. From −20, attitude runs −25, −29, −32,
−35, −37, −39, −41: the feud starts in season 7. **Site friction:** Thiên Xu (trung) and Tùng Đào (chính), 4 shared
borders, 9 border sites worth 87,414 a season: fr = round(30 · (1 − 2^−1.94)) = 22, A_tgt = 0 − 20 − 22 = **−42**, a feud
with no trait; two chính sects with 1 border and 34,800: fr = 12, +20 − 5 − 12 = **+3**.

### F8. War strength

The war_strength formula is defined as:

`S = mil_mult · def · Σ_r n_r · p_r + Σ_v lv · loy_f · S_v`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| p_r | int | 1 / 8 / 60 / 400 / 3,000 | data file (starts equal to `income_realm_scale`) | Power of one member of each realm |
| mil_mult | float | ≥ 1 | F2 | Military |
| def | float | 1.2 in the defender's seat region, else 1 | data file | Formations bonus |
| lv | float | 0.25 | data file | Levy share of a vassal's strength |
| loy_f | float | Loyal 1; Restless 0.5; Defiant 0 | data file | How much of the levy comes |
| S_v | float | > 0 | F8 | Each vassal's own strength |

**Output Range:** 0 – ∞. One Hóa Thần is worth 3,000, as much as 375 Trúc Cơ.
**Example:** a tier-1 sect with 300 / 75 / 20 / 4 / 1 members is 6,700 × 1.6 = 10,720, plus 257 of levy: **10,977**.

### F9. War score, losses, weariness and spoils

The war_score formula is defined as:

`Δws = round(20 · (S_a · ε_a − S_d · ε_d) / (S_a · ε_a + S_d · ε_d))`, ε a seeded draw from U(0.85, 1.15)
`loss_share_a = 0.04 · S_d / (S_a + S_d)` (members lost, lowest realm first) · `war_cost = 0.5 · stipends` ·
`W' = W + 1 + 50 · loss_share + max(0, −Δws_self) / 2`

The goal falls to the attacker at ws ≥ 25 for a site, 40 for a vassal, 75 for a region. **If the defender leads to the same threshold (ws ≤ −threshold), the attack has failed** (user decision 2026-11-14): the goal stays with the defender, the war ends in an 8-season truce (F7), the attacker loses 1 Military level, and the defender's attitude to the attacker falls by 10. A defender wins nothing else. A great sect's **seat region** is a valid goal
only while its strength S < 0.5 · S0 (its strength at the start of the game, stored); otherwise a war may not name it,
and a war that named it ends in a truce when the defender recovers above that line. The side ahead accepts a truce when its W ≥
40 + trait pulls. The side that is **behind** (the lower ws for it), once past its own limit with |ws| ≥ goal / 2, concedes the goal to the side ahead. A side behind and past its limit with
|ws| < goal / 2 offers a truce; it is accepted only if the side ahead is past its own limit too, otherwise the war
goes on. Military drops 1 level every 4 war
seasons. **Spoils:** a captured site produces at ×0.5 for 8 seasons, and its works' upkeep passes to the winner. A fallen
sect's treasury: 50 % to the victor, the rest scattered as hidden caches (places for the player to find).

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| ws | int | −∞ – ∞ | World DB | War score, positive for the attacker |
| ε | float | 0.85–1.15 | seeded random | Fortune of the season |
| W | float | ≥ 0 | World DB | Each side's war weariness |
| goal thresholds | int | 25 / 40 / 75 | data file | Site / vassal / region |
| weariness limit | int | 40 + pulls | data file, traits | When a side accepts a truce |

**Output Range:** Δws is −20 to 20 a season. Target: a one-site war pays back in 20 seasons or more.
**Example:** 10,977 against 8,400 (7,000 × 1.2 at its seat) scores +3 a season at ε 1. The site falls on score in
season 9 (ws 27 ≥ 25), while the defender's weariness (+3.633 a season) is still 32.7. A region goal (75) is conceded
in season 13, when ws 39 ≥ 37.5 and the defender is past its limit.

### F10. Player standing

The standing formula is defined as:

`ΔSt = Σ e · (1 − St / 100)` for gains when St ≥ 0, and the full e otherwise. Allies and vassals of the sect take
0.5 of a fall (without desertion's −30 floor). St is stored as a float **per (sect, player)** in a World DB table that Sects owns (user decision 2026-11-14); Quests' `standing` effect writes into it, and displays round it.

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| St | float | −100 – 100 | World DB | The sect's standing with the player |
| e | int | mission +3 · km; failed mission −5; theft −20; killing a member −10 · (realm index + 1); desertion −40 and set to at most −30; leak discovered −40 with the seller and with the holder (rule 23a, F16); levy refused −10 with the player's own sect (Edge Cases) | data file | Events. Quests world effects stay within ±10 |

**Output Range:** ±100 approached smoothly. Quests `hostile_threshold` −30 marks the player hostile.
**Example:** at St 50 a mission gives +1.5.

### F11. Prices by standing and membership

The standing_price formula is defined as:

`price_mult = 1 − 0.002 · St` · `owner_mult = clamp(member ? rank_m : open_out[O] · price_mult, 0.5, 3)`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| rank_m | float | outer 0.8; inner 0.65; elder and head 0.5 | data file | Members' fee multiplier |
| open_out | float | 3.0 / 2.0 / 1.5 / 1.2 / 1.0 by Openness 0–4 | data file | Outsiders' fee multiplier |
| owner_mult | float | 0.5–3 | calculated | Travel & Map's owner fee multiplier, set by Sects (Travel & Map Formula K; clamped to its stated range) |

price_mult multiplies the sect's stock prices in linh thạch for everyone, members included; owner_mult multiplies its
fees (arrays, rent). At St ≤ −30 the sect will not sell to the player. The recruit line is `20 − 10 · Recruitment`.
**Output Range:** price_mult 0.8–1.2; owner_mult 0.5–3.
**Example:** an outsider at St −20 and Openness 1 pays ×2.0 · 1.04 = ×2.08.

### F12. Mission reward, contribution and the board

The mission formula is defined as:

`pay = round(base · scale[realm] · km[k] · (1 + 0.1 · need_k))`
`cash = pay` up to Kết Đan; above it, `cash = min(pay, max(floor_cash, round(cash_cap · Inc_board)))`, with
`floor_cash = round(base · scale[Kết Đan] · km[k] · (1 + 0.1 · need_k))`
`contribution = round(c_share · cash + (pay − cash))`
`w_k = w0_k · (1 + need_k)` · offers `n = min(kinds, 2 + ⌊I / 3⌋)` at a seat and `min(kinds, 2 + ⌊T / 4⌋)` in a town, drawn by weight without
replacement, seeded

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| base, scale | int | 10; 1 / 8 / 60 / 400 / 3,000 | built (`session_actions.json`) | Mission pay |
| km[k] | float | 0.8–1.3, weighted mean 1.0 | data file | Mission kind: gather, escort, hunt, raid, defence, diplomacy |
| need_k | int | 0–3 | sect state | War: raid and defence +3. Strained or shortage: gather and escort +2. Feud: hunt +2. A vassal Restless or worse: diplomacy +2 |
| cash_cap | float | 0.10 | data file | Above Kết Đan, cash is at most this share of the board sect's income (user decision 2026-11-14) |
| Inc_board | float | > 0 | F3 | The board sect's income last season |
| c_share | float | 0.25 | data file | Contribution earned per linh thạch of cash |
| w0_k | float | data | data file | Base weight of each kind |

**Contribution** is priced at about 1 per linh thạch of market value in the sect's stock (manuals, pills, treasures),
and it never converts back to linh thạch. A gift to the sect earns 0.5 contribution per linh thạch, with goods valued at
the sell ratio (0.6), so buying contribution is never cheaper than the market. The client pays `cash · (1 + fee)`
and the fee goes to the sect (F3).

**Output Range:** cash up to Kết Đan matches the built income. Above it, cash is at most 10 % of the board sect's
income, so high-realm players earn most of their pay as contribution and seek great sects' boards.
**Example:** a Kết Đan raid in wartime pays 10 · 60 · 1.2 · 1.3 = **936** cash and **234** contribution. A Hóa Thần
mission (km 1, need 0) at a tier-1 board with income 31,404 pays 3,140 cash and 785 + 26,860 = **27,645** contribution.

### F13. Promotion, founding and the head's draw

The promotion formula is defined as:

`promote if realm ≥ gate[rank] and contribution ≥ cp[rank] (spent) and St ≥ st[rank]`
`found if realm ≥ found_realm and seat_density ≥ 1.5 and linh thạch ≥ 6 · linh_thach_max[realm] and disciples ≥ 5 and St_host ≥ 20`
`head_draw ≤ 4 · own stipend` a season

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| gate, cp, st | per rank | great sect: inner Trúc Cơ / 400 / 0; elder Kết Đan / 3,000 / 40; head Nguyên Anh / 30,000 / 60 plus the trial | data file | About 20 missions at the rank's gate realm |
| minor-sect gates | per rank | each gate one realm lower, half the contribution | data file | Easier entry, smaller sect |
| found_realm | realm | Kết Đan | data file | Lowest realm to found a sect |
| seat_density | float | ≥ 1.5 | Travel & Map | Qi density of the seat abode |
| linh_thach_max | int | per realm | built (`events_budgets.json`) | The realm's event budget, used as a price scale |
| St_host | float | ≥ 20 | F10 | Standing with the great sect whose land it is |
| head_draw | float | ≤ 4 · stipend | data file | The F3 `draw` ceiling: a draw above it is embezzlement, an event with a standing and loyalty cost |

**Example:** founding at Kết Đan costs about 30,000 linh thạch. 20,000 buys Holdings 3 and Institutions 3 (19,620), and the
rest seeds the treasury. A Kết Đan elder reaches 3,000 contribution in about 13 wartime raids or 20
ordinary missions.

### F14. Service prices

The service_price formula is defined as:

`price = s_k · base · scale[realm]` (in contribution) · treasure deposit `= 2 · market value of the treasure`

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| s_k | float | arrays 2 a season; secret-realm place 20; elder guidance 15 a season; treasure loan 10 a season; protection 30; levy call 40; council pull 5 | data file | Price in missions' worth of pay at the buyer's realm |
| base, scale | int | 10; 1 / 8 / 60 / 400 / 3,000 | built (`session_actions.json`) | As F12 |
| realm | realm | — | Character Stats | The buyer's realm |

**Output Range:** from 20 contribution (a Luyện Khí using arrays for a season) to 1.2 million (a Hóa Thần levy call).
Prices scale with the buyer's realm, so a service is worth the same number of missions at every realm.
**Example:** a Hóa Thần earns about 27,600 contribution a mission at a tier-1 board (F12). A secret-realm place costs
20 · 30,000 = 600,000, about 22 missions; a council pull costs 150,000, about 5 missions.

### F15. Trait pulls: the contract with NPC Traits (#42)

Each trait carries **pulls** of these kinds, and each kind plugs into one formula. A leader's pulls are the sum over all
its traits (3 personality, the calling, and any fate-given or gained ones; npc-traits.md Edge Cases); an elder's
council pull (rule 19a) is separate.

| Pull kind | Read by | How it applies |
|---|---|---|
| dial delta | F6 | Added to `Σ pull_d` on that dial |
| bold / never bold | F6 | Impatient counts as bold; Stubborn is never bold and halves `Σ need_d` before the clamp |
| fickle | F6 | Each season the target moves by a seeded draw from {−1, 0, +1} on one seeded dial |
| invest share | F3 | Replaces `inv_frac` (Diligent 0.6, Lazy 0.35) |
| first track | F3 | The track that receives the season's investment when no need names one |
| treasury draw | F3, F13 | Replaces `draw_mult` (Temperate 1 × stipend; Indulgent 4 × stipend, paid every season, not embezzlement) |
| loyalty term | F5 | Added to `Σ pull` |
| attitude bias | F7 | Added to `A_tgt` (to all, to rivals, or to the opposite alignment, as stated) |
| attitude speed | F7 | Multiplies `k_a` (after hostile events, or toward friendly targets, as stated) |
| event fade | F7 | Event attitude losses fade by 10 % a season (Forgiving 20 %, Vengeful 0 % and ×1.5 on arrival) |
| alignment factor | F7 | Multiplies `align[a, b]` |
| pact line | F7 | Replaces the pact line 40 for this sect's pacts (the lower of the two sects' lines applies) |
| pact keeping | F7, rule 14 | Honest never breaks a pact; Deceitful and Schemer double the weight of breaking one |
| war odds | F7 | Replaces `war_odds`; with several, the lowest applies |
| weariness limit | F9 | Added to the limit 40; Compassionate accepts a truce 10 earlier; Callous adds half weariness from losses |
| conditional dial delta | F6 | A dial delta that applies only while a state holds (Steward: Tax −1 while Thriving) |
| dispute ruling | Edge Cases (vassal quarrels) | Loyalty change to each side. Default with no such trait: +2 to the side with the lower loyalty, 0 to the other. Just +2 to each; Arbitrary +5 to one side and −5 to the other (seeded) |
| raid loss multiplier | F9 | Multiplies the production lost on the target's land in a war season (Cruel ×1.5); the base loss is set with #43 |
| pact scope | F7 | A pact line that applies only to one kind of pact (Trusting: defence pacts) |
| event weights | Event Engine (#23) | Raise or lower the chance of named event kinds (betrayal, spying, head-seat challenge, harsh raids) |
| rebel odds | F8 | Replaces `rebel_odds` 1.0 for a vassal's head: Ambitious or Brave 0.8; Cautious or Content 1.3 (lowest applies, as for war odds) |

The trait list itself (37 personality traits in 18 opposed sets, 14 callings, 10 fate-given and 16 gained traits) lives in
`design/gdd/npc-traits-catalogue.md` (rules in `design/gdd/npc-traits.md`, NPC Traits #42). Sects owns only the pull kinds above.

**Output Range:** dial pulls from one leader can sum to −3 – +3 on a dial (F6 clamps the target to 0–4). War odds run 0.8
– 1.2, weariness limits 20 – 60, invest share 0.35 – 0.6.
**Example:** a Greedy, Ambitious, Paranoid Strategist: Tax +1, Expansion +1, War readiness +1, loyalty −2, war odds 0.9,
first track Military. Absolute pulls sum to 3, so the leader is bold (F6). With a hostile neighbour (War readiness need
+1), its War readiness target is 2 + 1 + 1 = 4, reached in one season.

### F16. Discovery of a leaked manual

The leak_discovery formula is defined as:

`p = p0 · (1 + 0.1 · M_owner) · max(0.1, 1 − dist / d_reach)` each season, for at most `trail` seasons after the sale

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| p0 | float | 0.15 | data file | Base chance a season |
| M_owner | float | 0 – ∞ | F2 | The owner sect's Military |
| dist | float | ≥ 0 | Travel & Map | Tiles from the sale's place to the owner's seat |
| d_reach | float | 200 tiles (about 5,000 km) | data file | Distance at which the sect's reach bottoms out |
| trail | int | 20 seasons | data file | After this, the trail goes cold and the leak is never found |

**Output Range:** from 0.015 to near 1 a season (clamped to 1).
**Example:** a sale 50 tiles from a tier-1 seat with Military 6: p = 0.15 · 1.6 · 0.75 = **0.18** a season, so about 98 %
found within 20 seasons. At 300 tiles: 0.15 · 1.6 · 0.1 = 0.024, about 38 % within 20 seasons.

### F17. Member intake

The intake formula is defined as:

`target = 0.9 · capacity` · `intake = round(rec_k[Recruitment] · (target − n))` Luyện Khí members a season, when `n < target` and the sect is not Strained or Collapsing

**Variables:**
| Variable | Type | Range | Source | Description |
|----------|------|-------|--------|-------------|
| capacity | int | 0 – ∞ | F2 | Members the seat houses |
| n | int | ≥ 0 | World DB | Current members, all realms |
| rec_k | float | 0.05 / 0.08 / 0.10 / 0.15 / 0.20 by Recruitment 0–4 | data file | Share of the gap filled each season |

Higher realms are never recruited in bulk: members reach them through Realms' breakthroughs, and the best outsiders join by rule 20.
Rank follows realm (rule 19). Deaths come from the world tick, losses from F9, desertion from F3's shortfall.

**Output Range:** 0 – 0.2 · target a season; 0 at or above target. **Example:** a minor sect at capacity 56 with 38 members and Recruitment 2: target 50, intake round(0.10 · 12) = **1**.

### F18. War target and goal

The war_goal rule is defined as:

Target = the sect this one is in a feud with that has the lowest S_other (F8) among those passing the F7 war-odds test, where `war_odds' = max(0.6, war_odds − 0.1 · max(0, Expansion − 2))`. Goal tier by Expansion:

| Expansion | Goal |
|---|---|
| 0–1 | A site: the target's highest `value_lt` site on a shared border |
| 2–3 | A vassal of the target, if it has one on a shared border; else a site |
| 4 | A region of the target on a shared border (its seat region only under F9's protection rule); else a vassal or site |

Thresholds are F9's 25 / 40 / 75. The goal is fixed at declaration. **Output Range:** one goal per war. **Example:** Expansion 4, a feud with a sect at 0.9 of its strength: war_odds' = max(0.6, 1.0 − 0.2) = 0.8, so it declares at an S ratio of 0.8 or more and names a border region.

### F19. Investment track

The invest_track rule is defined as:

1. A track that fell, or had unpaid upkeep, in the last 4 seasons.
2. Else the track with the largest `deficit_T = mix_T − C_T / ΣC`. **War readiness sets the Military share of the mix:** `mix_Military = clamp(0.30 + 0.10 · (War readiness − 2), 0.10, 0.50)` (0.10 / 0.20 / 0.30 / 0.40 / 0.50 at War readiness 0–4; user decision 2026-11-14). The other three tracks split the rest in the ratio Holdings 0.25 : Institutions 0.20 : Trade 0.25, so at War readiness 2 the mix is Holdings 0.25 · Institutions 0.20 · Military 0.30 · Trade 0.25.
3. Ties, and a sect with ΣC = 0, go to the leader's first track (F15), else the cheapest next level.

**Output Range:** exactly one track a season. **Example:** FX-T1 (6/6/6/6) at peace: C shares (Holdings / Institutions / Military / Trade) are 0.25 / 0.31 / 0.25 / 0.19, against the mix 0.25 / 0.20 / 0.30 / 0.25 the deficits are 0 / −0.11 / +0.05 / +0.06, so Trade is chosen.

**Highest risks** (from the specialists): the F3 money flow (mission fees and V_own depend on #43); F9 wars ending in
truce too often or chính–ma feuds never ending; minor-sect solvency; the contribution stock at the top realms (a Hóa Thần
earns contribution faster than a sect's stock refills). Each needs the 400-season simulation run.

## Edge Cases

**Leaders and succession**

- **The leader dies during a war.** Succession runs in step 7 (rule 15). The war goes on, and its weariness limit becomes
  the new leader's (F9). The new leader may accept a truce the old one refused.
- **No member is left to succeed.** A minor sect falls (Fallen). A great sect takes its highest-realm member of any rank;
  if it has no members at all, it falls, and its regions go to the bordering great sect with the highest attitude to it.
- **The player is head and is away.** A head who is away from the seat for 8 seasons (guess) without naming a deputy loses
  the seat to succession. With a deputy, the dials hold their values and the deputy's traits do not pull.
- **The player dies while head or founder.** The sect lives on under its successor as an ordinary NPC sect. Its history
  records the player as a past head.
- **An LLM event tries to set a dial, a level, or ownership.** The engine refuses and logs it. Events may move attitude,
  loyalty and standing only, within their budgets (rule 14).

**Vassals**

- **A vassal's lord falls.** The vassal passes to the great sect that took the region holding its seat, at loyalty 50.
  If no great sect took that region, it passes to the bordering great sect with the highest attitude to it.
- **A region changes hands and a vassal's seat is in it.** Unless the war's goal was that vassal, the new holder becomes
  its lord at loyalty 40 (Restless). Its other sites in other regions go with it.
- **Two vassals of one lord quarrel.** They may not fight (rule 16). Their quarrel becomes a diplomacy mission on the lord's
  boards and an event the lord's head decides. Each side's loyalty moves with the ruling (F15 dispute ruling; default +2 to the lower-loyalty side).
- **A vassal rebels while its lord is already at war.** A sect fighting several wars splits its strength S evenly between
  them, and pays war_cost and suffers losses in each.
- **A vassal cannot pay tribute.** It pays what it has; the shortfall costs 5 loyalty and counts as Defiant pay for the
  lord's Tax need. It never borrows.
- **A rebel wins a whole region.** If its head is Nguyên Anh or above, it becomes a great sect of tier 2 with that
  region (user decision 2026-11-14). Otherwise it keeps the region under a bordering great sect it chooses as lord, at
  loyalty 50. Either way, its old lord's attitude to it is set to −60.

**Money and development**

- **The treasury would go below 0.** It never does. Cuts follow F3's order: investment, then the head's draw, then upkeep (tracks lose levels
  after 2 unpaid seasons), then stipends (members leave, and loyalty falls for vassals).
- **A track falls below the level an existing work needs.** The work stays, but it cannot be raised, and it fades like an
  unpaid work if the sect stops paying its upkeep (Travel & Map rule 31).
- **The board sect's income is tiny** (a Strained minor sect) and the player is above Kết Đan. Cash is at least the Kết
  Đan pay for that mission (F12 floor_cash, 600 · km · (1 + 0.1 · need)); the rest is contribution.
- **The sect's stock is empty.** Contribution cannot be redeemed until the stock refills (Institutions sets the refill);
  contribution is kept. It never converts to linh thạch.
- **Dials at their ends.** A target beyond 0–4 is clamped. Loyalty, attitude and standing are clamped to their ranges.

**Politics and war**

- **A defence pact and a war.** When a sect with a defence pact is attacked, its partner joins as a party: the defenders'
  strengths add, and the partner pays its own war_cost. A trade pact does not draw a partner in.
- **Two great sects target the same site.** Wars resolve in the order they were declared; the second war's goal changes
  to whoever holds the site after the first.
- **Chính and ma in a pact.** Allowed if attitude reaches 40 both ways (traits can do it). Other chính sects' attitude
  to both falls by 10 (an event).
- **A sect loses its seat region but keeps others.** It is Collapsing. It moves its seat to its best remaining site
  after 4 seasons if it survives, losing one Institutions level.

**The player**

- **The player's sect goes to war with a sect where the player has high standing.** The player may refuse the levy duty:
  −10 standing with their own sect and the duty counts as failed. Fighting costs standing with the other sect as F10 says.
- **The player is a member of a rebelling vassal.** The lord treats the player as levy only if the player fights; standing
  with the lord is unchanged otherwise.
- **The player tries to found a sect where the host's standing is below 20,** or on land where they hold no abode.
  Refused, with the reason shown.
- **The player is above the realm gates of a minor sect** (a Hóa Thần joins a minor sect). Allowed. Promotion follows
  contribution and standing; the realm gates are already met. Mission cash is capped by that small sect's income (F12),
  so the player earns mostly contribution.
- **The player deserts while head.** Succession runs at once. Desertion's standing loss (F10) applies, and the sect's
  allies and vassals take half.

**Small-case defaults** (all guesses; listed in Open Questions for review)

- **A notable choice** (rule 14) is a dial reaching 0 or 4, a dial moving 2 steps in one season, a war declared, a pact
  formed or broken, a rebellion, a succession, or a fall.
- **A mission's nudge** (rule 26): a won raid or defence adds 1 to the sect's war score, a failed one subtracts 1; a
  successful diplomacy mission adds 3 loyalty to the vassal concerned. Gathering and escort missions move goods, not money.
- **Succession tiebreak** within one rank: highest realm, then most contribution, then the oldest.
- **After a failed rebellion** the vassal's loyalty is set to 40 (Restless).
- **Member losses** in war and on stipend shortfalls are rounded half up per realm, lowest realm first. On a stipend
  shortfall, the share of members who leave equals the unpaid share of stipends.
- **Event budgets:** an event moves attitude, loyalty or standing by at most 10.
- **Upkeep shortfall:** the track named by the leader's calling (F15) is paid last; the others go unpaid lowest
  level first (the cheapest loss). At war, Military is always paid last (user decision 2026-11-14).
- **Ties** on attitude (who takes a vassal whose lord fell) go to the stronger great sect (F8).

## Dependencies

> **Power Rankings (#44, 2026-11-14)** supplies ratings, power numbers and realm rankings that ranks, leaders and wars read; wars keep `rating_clash` with members ordered by power number (`design/gdd/power-rankings.md` rules 9, 10, 11).

**Upstream (this system reads them)**

| System | Hard / soft | Interface | Has a GDD? | Lists Sects back? |
|---|---|---|---|---|
| Travel & Map (#25) | Hard | Regions, sites, seats, layer-2 works and their prices, `value_lt`, `works_upkeep_due_lt`, teleport arrays, residence grades, `owner_mult` (Formula K) | Yes | Yes |
| World Generation & History (#27) | Hard | The authored sects, vassals, leaders, starting levels, dials, attitudes and history | No (rework pending) | Index lists it |
| World Database (#3) | Hard | Sect, person, site and war records | No | — |
| Time & Turn (#4) | Hard | The season tick and seasons spent | No | — |
| Character Stats and Realms (#8) | Hard | Members' and the player's realms for gates, stipends, pay and war strength | Yes | Yes (`canh-gioi.md` row 26) |
| Living World Tick (#28) | Hard | Calls the sect season tick | No | — |
| NPC Traits (#42) | Soft | Stance pulls, event weights and war odds per trait; a provisional table stands in until #42 exists | No | Index notes it |
| Regional Economy & Trade (#43) | Soft (Hard once built) | Production value and prices; until it exists, Travel & Map Formula L's `value_lt` is used | No | Index lists Sects |
| Trade Goods (#45) | Soft | Sect workshops' output is in kind and meets the sect's kind pills and Military use first; `kind_stipend` (15 %) is 0.10 in pills and 0.05 in herbs; Military's goods mix is ore 0.42, beast 0.28, artifact 0.2, talisman 0.1 (Trade Goods Formula H; #43 Formulas C, I; amended 2026-11-14) | Yes (designed 2026-11-14, pending review) | Trade Goods lists Sects |
| Event Engine (#23) and LLM Game Master (#29) | Soft | Event outcomes that move attitude, loyalty and standing, within budgets | No | — |
| Market (#20) | Soft | Item prices, `linh_thach_max` | No | — |
| Formations (#17) | Soft | Sect-owned arrays (teleport, protective, standing at the seat) use Formations' array record; sects teach combat diagrams. The seat's `def` 1.2 "Formations bonus" stays Sects' number until Formations Open Question 7 settles whether seat arrays feed it | Yes (`design/gdd/formations.md`, designed 2026-11-21) | Yes |
| Alchemy (#15) | Soft | Pills for the kind stipend come from workshops brewing Alchemy's recipes (Trade Goods' kind share) | Yes (`design/gdd/alchemy.md`, designed 2026-11-21) | Yes |
| Cave Abode & Home Works (#47) | Soft | The abode's active works and grade for the `seat_density` check (rule 29) | Yes (`design/gdd/cave-abode.md`, designed 2026-11-21) | Yes |

**Downstream (they read this system)**

| System | Hard / soft | Interface | Lists Sects back? |
|---|---|---|---|
| Travel & Map (#25) | Hard | Holder of each region and site, territory changes, array access, `owner_mult` | Yes |
| Regional Economy & Trade (#43) | Hard | Development levels, Tax and Openness, tariffs, linked markets, client-paid mission cash | Index: yes |
| Quests (#31) | Hard | Mission action, boards, base income, `hostile_threshold`, `sect_standing` and its readers (rule 21) | Yes: **Quests open question 10 is now answered by rule 21 and F10–F11** |
| Cultivation Techniques (#9) | Soft | Libraries, manual sales by Openness and standing, forbidden manuals, the rule 18 duties | Yes |
| Item Database | Soft | Sect rewards from named templates, through contribution | Yes |
| Market (#20) | Soft | Sect stock, prices by standing | No GDD |
| Guidance Layer (#35) | Soft | Sect states, offers and threats | No GDD |
| Combat | Soft | Trials and mission fights use the combat engine as built; wars do not | Yes (`combat.md` Dependencies) |
| NPC Relationships (#46) | Soft | Taking a disciple forms sư đồ; succession may prefer the head's disciples; ranks set notability, and a lost rank is reported to #46's S8b queue (rule 6); disciples' errands cost a season's stipend of the higher of the player's and the disciple's realm (`errand_cost`, read from the stipend anchors) | Yes (`npc-relationships.md`) |

**Back-links:** Realms (`canh-gioi.md`), Combat (`combat.md`), Quests, Cultivation Techniques and Item Database already list Sects. Character
Stats needs no change: Sects reads realm only.

## Acceptance Criteria

Drafted with `qa-lead` (2026-11-14), then corrected for the fixes it found in the worked examples. Nothing has run yet.
All numbers are guesses until AC-SM-42 passes. Tests never call a live model. Every random draw is seeded from (world
seed, season, record id). Evidence goes to `tests/unit/sects/`, `tests/integration/sects/` and
`production/qa/evidence/balance/`. Tolerance is ±1 linh thạch or ±0.01 for ratios, unless stated.

**Fixtures**
- **FX-D:** the Formulas defaults in `sects.json`, plus the built stipends, `session_actions.json` and `events_budgets.json`.
- **FX-T1:** a tier-1 great sect: members 300 / 75 / 20 / 4 / 1; own tracks 6/6/6/6 with no vassal investment; mines 12,000 and goods 38,000 (value_lt · acc;
  V_own 50,000), own use 5,000, stipends in kind 1,100, herb P 1.05, Inc_tariff 1,800, market turnover 60,000, share_s 0.8;
  Openness 2; Tax 2; works_due 5,000; board_cash 20,000; trib_in 976; treasury 60,000; a Temperate Nguyên Anh head; not at war.
- **FX-V:** a Loyal vassal grossing 1,394, mission fees excluded.
- **FX-TR:** the provisional trait list in `design/gdd/npc-traits.md`, in particular Greedy (Tax +1, loyalty −1), Cruel (attitude −10 to rivals,
  war odds 0.8) and Cautious (war odds 1.2).
- **FX-LLM:** a mock returning scripted event outcomes. **FX-S:** a stub holding strength S constant.

**Kinds, vassals and territory**

- **AC-SM-01** [Config] Rules 1–3, 7. **GIVEN** the authored world loaded, **THEN** there are 7 great sects (4 tier-1,
  3 tier-2) with no lord; 15–25 minor sects, each with exactly one lord that is a great sect whose territory holds its
  seat; every region has one great-sect holder and every site one holder; no lord is a minor sect.
- **AC-SM-02** [Logic] Rule 7. **GIVEN** a founding, or a winning rebel choosing a lord, **WHEN** lords are offered,
  **THEN** no minor sect is ever offered or accepted as a lord.
- **AC-SM-03** [Integration] Rule 18. **GIVEN** a site captured in season s's tick, **THEN** the map shows the new holder
  after step 8 of season s, and tribute, taxes and array access switch to the new holder from season s + 1.

**Development (F1, F2)** [Logic]

- **AC-SM-04** F1. **GIVEN** FX-D, **THEN** Holdings cost(10) = 41,322; C(10) = 139,627 and upkeep 1,396.3; C(5) =
  21,891; Institutions cost(1) = 2,500.
- **AC-SM-05** F1. **GIVEN** a lord at Holdings 10 and four vassals at Holdings 5, **THEN** L_eff = 10.79. **GIVEN** no
  vassals, **THEN** L_eff = L (±1e-6) for every L from 0 to 20.
- **AC-SM-06** F1. **GIVEN** a track at 7, **WHEN** two seasons in a row go unpaid, **THEN** it is 6 at the end of the
  second; **WHEN** one unpaid season is followed by a paid one, **THEN** it stays 7. A level-0 track never goes below 0.
- **AC-SM-07** F2. **THEN** H 0 gives collect 0.0857 and H 1,000 gives collect < 0.6; FX-T1 gives collect 0.3231,
  trade_mult 1.9, capacity 400, mil_mult 1.6 and road danger 0.6064; a minor sect at I 6 houses 62; work_max is 4 at
  H 8 and 5 at H 9; Holdings 6 → 7 on FX-T1 (mines 12,000, goods 38,000) costs 15,059, adds about 829 a season (mine cash
  119, goods sold 710) and 150.6 of upkeep.

**Treasury and states (F3)** [Logic]

- **AC-SM-08** F3. **GIVEN** FX-T1, **WHEN** the season runs, **THEN** Inc = 29,668, Cost = 9,578 (cash only: draw 325, kind stipends 1,100 and the in-kind half of upkeep and works excluded), R = 38,312,
  invest = 20,889 and Tr' = 64,423 (only the cash share `c_inv` 0.75 of invest, 15,667, leaves the treasury; Regional Economy & Trade Formula H). **GIVEN** a treasury of 15,000 instead, **THEN** invest = 0 and Tr' = 35,090. **GIVEN** Tax 0 / 4, **THEN** tf is 0.05 / 0.15 and the market tax is 4,560 / 13,680. A grep of the income code finds no read of `world_production_guess` and no `collect · V_own` term. **GIVEN** an Indulgent head, **THEN** the draw is 1,300 and is cut before upkeep when money runs short.
- **AC-SM-09** Edge (never below 0; cut order). **GIVEN** a minor sect with treasury 0, income 500, tribute due 100,
  stipends 430, upkeep 200 and no head's draw, **THEN** tribute 100 is paid, stipends get 400 of 430 (and 7 % of members leave), upkeep
  gets 0 and every track's unpaid count rises by 1, invest = 0 and Tr' = 0. Over 10,000 seeded random states, Tr' is
  never below 0.
- **AC-SM-10** States. **THEN** a treasury below next season's stipends gives Strained; two fully paid seasons after
  that give Steady; 4 Strained seasons in a row, or losing the seat, give Collapsing; a great sect with no region, or
  a minor sect with no seat, becomes Fallen and never leaves it; Thriving needs treasury ≥ R and no track fallen in the
  last 4 seasons.

**Tribute and loyalty (F4, F5)** [Logic]

- **AC-SM-11** F4. **THEN** Tax 0 / 2 / 4 give rates 0.05 / 0.175 / 0.30; FX-V at Tax 2 pays 244, 122 if Defiant and 0
  if Rebelling; adding 200 of mission fees to the vassal leaves its tribute at 244.
- **AC-SM-12** F5. **GIVEN** Tax 3, a lord/threat ratio of 1.34, a greedy vassal head and loyalty 55, **THEN** ΔLoy =
  −1.91 and loyalty becomes 53.09. A ratio of 8 gives a protection term of +2, not +6. Loyalty clamps to 0–100.
- **AC-SM-13** F5. **GIVEN** 400 seasons with no pulls or events, **THEN** Tax 4 with a ratio ≥ 2 settles at 20 ±0.5,
  and Tax 2 with a ratio of 1 settles at 60 ±0.5.
- **AC-SM-14** Loyalty states. **THEN** 60 is Loyal; 59 and 30 are Restless; 29.9 is Defiant. A refused levy costs 10,
  a tribute shortfall 5. A peaceful change of lord sets 50; a failed rebellion sets 40. Defiant pays at 0.5 with levy
  factor 0.
- **AC-SM-15** Edge (lord falls). **GIVEN** vassal V's lord falls, **THEN** V's lord becomes the great sect that took
  the region holding V's seat, at loyalty 50, or if none took it, the bordering great sect with the highest attitude to
  V (ties: the stronger). **GIVEN** the region holding a vassal's seat changes hands and the war's goal was not that
  vassal, **THEN** its lord becomes the region's holder at loyalty 40.
- **AC-SM-47** [Logic] Edge (rebel wins a region). **GIVEN** a rebel wins a war whose goal was a region, **WHEN** its head
  is Nguyên Anh, **THEN** it becomes a tier-2 great sect with no lord and its old lord's attitude to it is −60; **WHEN**
  its head is Kết Đan, **THEN** it holds the region under the bordering great sect it chooses, at loyalty 50.
- **AC-SM-48** [Logic] Rule 17, F9 (seat protection). **GIVEN** a great sect with S0 10,000, **WHEN** its S is 5,100,
  **THEN** no war may name its seat region as a goal; **WHEN** its S is 4,900, **THEN** one may; **GIVEN** such a war under
  way, **WHEN** the defender's S recovers to 5,000 or more, **THEN** the war ends in a truce.

**Leaders and stance (F6, rules 11–15)** [Logic]

- **AC-SM-16** F6. **GIVEN** a treasury under R and a greedy head, **THEN** the Tax target is 4 and the dial moves 2 → 3,
  then 3 → 4 the next season. A bold leader moves 2 → 4 in one season. Need +2 plus pull +2 gives a target of 4.
- **AC-SM-17** F6 needs. **THEN** 2 feuds give War readiness +2; a feud plus a war give +3, clamped to +2; Strained gives
  Openness −1, and so does war; 230 members against capacity 300 give Recruitment +1, and 301 give −1.
- **AC-SM-18** Rule 15. **GIVEN** a head dies with Tax at 4 and the successor's Tax target is 0 (not bold), **THEN**
  succession runs in step 7, Tax reads 4 until the next tick, then 3.
- **AC-SM-19** Edge, rule 14. **GIVEN** FX-LLM outcomes that set Tax, set Holdings, or move a site, **THEN** each is
  refused and logged, and the sect record is byte-identical. An outcome of attitude −8 is applied; one of −12 is refused.
- **AC-SM-20** Rule 14. **WHEN** a war is declared, a pact broken, or a dial reaches 0 or 4, **THEN** exactly one notable
  event is emitted for each.

**Politics and war (F7–F9)** [Logic]

- **AC-SM-21** F7. **GIVEN** chính vs ma, 2 shared borders and a Cruel head, **THEN** A_tgt = −50, and from −20
  attitude runs −25, −29, −32, −35, −37, −39, −41, with the feud starting in season 7. From −48, attitude reaches −50
  in two seasons (no dead band).
- **AC-SM-22** F7 lines. **THEN** a pact forms at 40 / 40 and not at 40 / 39; a feud starts at ≤ −40 one way and ends
  at ≥ −20 (−21 stays a feud); at a ratio of 0.85 a Cruel leader declares war and a neutral one does not; a Cautious
  leader does not declare at 1.15 and does at 1.20; War readiness 2 never declares. The target's defence-pact partners
  count in S_other.
- **AC-SM-23** Truce. **THEN** for 8 seasons no war is declared even when the conditions hold, and A_tgt is 0; in season
  9 a declaration is allowed.
- **AC-SM-24** F7 balance of power. **GIVEN** the strongest sect at 13,200 and the runner-up at 11,000, **THEN** every
  other sect's A_tgt toward the strongest includes bp 2, and toward the runner-up 0.
- **AC-SM-25** Rule 16. **THEN** two vassals of one lord never go to war, and their quarrel posts a diplomacy mission on
  the lord's boards; a minor sect is never a war party except as a rebel against its own lord.
- **AC-SM-26** F8. **THEN** FX-T1 members give 6,700 × 1.6 = 10,720; with four vassals at S_v 257, all Loyal give
  10,977, and two Loyal, one Restless and one Defiant give 10,880.6; a defender of 7,000 at its seat gives 8,400.
- **AC-SM-27** F9 score. **GIVEN** 10,977 against 8,400, **THEN** Δws is +3 at ε 1 / 1, +6 at ε 1.15 / 0.85 and 0 at
  ε 0.85 / 1.15. Every seeded ε lies in [0.85, 1.15].
- **AC-SM-28** F9 weariness and losses (FX-S, ε 1). **THEN** the defender's W rises 3.633 a season and the attacker's
  1.867; loss shares are 0.0173 (attacker) and 0.0227 (defender), lowest realm first; war_cost is 3,600 for FX-T1;
  Military drops 1 level at war seasons 4 and 8.
- **AC-SM-29** F9 resolution (FX-S, ε 1, +3 a season). **GIVEN** a site goal, **THEN** ws reaches 27 in season 9 and the
  site falls, with the defender's W at 32.7. **GIVEN** a region goal, **THEN** in season 12 (ws 36 < 37.5, defender W
  43.6) the defender's truce offer is refused because the attacker (W 22.4) is not past its limit, and in season 13
  (ws 39) the defender concedes the region.
- **AC-SM-30** Spoils. **THEN** a captured site produces ×0.5 for 8 seasons, then ×1; its works' upkeep moves to the
  winner; a fallen sect's treasury of 100,000 gives 50,000 to the victor and 50,000 to caches (total conserved).
- **AC-SM-31** Edge (several wars). **GIVEN** S 10,977 in 2 wars, **THEN** each war uses 5,488.5, war_cost is paid in
  each (7,200 in total), and losses are taken in each.
- **AC-SM-32** Edge (defence pact). **GIVEN** a defender of 8,400 with a defence-pact partner at 6,000 against 10,977,
  **THEN** Δws is −3 and the partner pays its own war_cost. A trade-pact partner does not join, and Δws stays +3.
- **AC-SM-33** Edge (succession in war; same target). **GIVEN** the side ahead at W 32 with limit 40, and its head dies
  in season 5 with a successor whose limit is 30, **THEN** season 5 still uses 40 and the side accepts a truce in season
  6. **GIVEN** two wars that target the same site, **THEN** they resolve in declaration order and the second's goal is set
  against the holder after the first.
- **AC-SM-58** [Logic] F9 (defender leads). **GIVEN** a site-goal war (FX-S, ε 1) with the defender leading, **WHEN** ws reaches −25, **THEN** the site stays with the defender, a truce of 8 seasons starts, the attacker loses 1 Military level and the defender's attitude to the attacker falls by 10; the same at −40 (vassal) and −75 (region). **GIVEN** ws −24, **THEN** the war goes on.

**Members and the player (F10, F11, F13)** [Logic]

- **AC-SM-34** F10. **THEN** a mission (km 1) moves St 50 → 51.5 and −10 → −7; theft moves 50 → 30; killing a Kết Đan
  member moves 0 → −30, and an ally of the sect at 20 drops to 5; desertion moves 50 → −30 and −50 → −90; at St ≤ −30
  the player is hostile.
- **AC-SM-35** F11. **THEN** an outsider at St −20 and Openness 1 pays ×2.08; St 100 and Openness 4 give ×0.8; St −29
  and Openness 0 give ×3.0 (clamped from 3.174); an outer disciple's fees are ×0.8 at any standing; at St −30 there is no
  sale; the recruit line at Recruitment 0 / 2 / 4 is 20 / 0 / −20.
- **AC-SM-36** F13 promotion. **GIVEN** a great-sect member at Kết Đan with 3,000 contribution and St 40, **THEN** they
  become elder and their contribution falls to 0; each of 2,999 contribution, St 39, or Trúc Cơ alone refuses. A
  minor-sect elder needs Trúc Cơ, 1,500 and St 40. A Hóa Thần may join a minor sect.
- **AC-SM-37** F13 founding and draw. **GIVEN** Kết Đan, seat density 1.5, 30,000 linh thạch, 5 disciples and St_host
  20, **THEN** a vassal of that host is founded; each of 29,999, density 1.49, 4 disciples, St_host 19.9, Trúc Cơ, or
  membership in another sect is refused with its reason shown. A Nguyên Anh head draws 1,300 freely; 1,301 raises an
  embezzlement event.
- **AC-SM-38** [Integration] Rules 20, 22, 27–28. **THEN** joining needs the gate; the player holds one sect at a time;
  leaving on good terms keeps St and desertion makes the player hostile; a Nguyên Anh elder with 30,000 and St 60 may
  stand for an open head seat; a head away 8 seasons with no deputy loses the seat, and with a deputy the dials freeze.

**Missions (F12, rules 24–26)** [Logic]

- **AC-SM-39** F12. **THEN** a Kết Đan wartime raid pays 936 cash and 234 contribution, the client pays 1,123.2 and the
  sect's fee is 187.2; a Hóa Thần mission (km 1, need 0) at a board with income 31,404 pays 3,140 cash and 27,645
  contribution; Luyện Khí to Kết Đan pay is never capped.
- **AC-SM-40** Edge (cash floor). **GIVEN** a Nguyên Anh raid (km 1.2, need 0) at a Strained minor sect with Inc_board
  500, **THEN** pay is 4,800, the cap is 50, the floor applies (cash 720) and contribution is 4,260.
- **AC-SM-41** Board. **THEN** a seat at I 6 offers 4 missions and a town at T 6 offers 3; at I 15 or more a seat offers
  6 (all kinds); at war raid and defence weights are ×4; no kind appears twice on a board; the same seed gives the same
  board; as a Quests `mission` stage, the mission pays no income. A won raid adds 1 to its sect's war score. **GIVEN** a sect hall
  board, **THEN** it lists the sect's missions and the Quests standing board's quests side by side, and refreshing one list
  leaves the other unchanged.

**Founding by NPCs, determinism, performance, data, balance**

- **AC-SM-46** [Logic] Rule 30. **GIVEN** a territory with one minor sect fewer than its authored count and an eligible
  NPC, **THEN** over 1,000 seeded seasons a sect is founded in 4–6 % of them (chance 0.05), and never when the count is
  full.
- **AC-SM-42** [Integration, Balance Harness #33] 400 seasons on 20 fixed seeds; bands are **guesses**:
  - great sects fallen: 0 in ≥ 18 seeds, never more than 1 in a seed;
  - minor sects: 2–8 fall per run, and 15–25 are alive at every season;
  - great-sect wars: 3–10 per run, ≤ 60 % ending in a truce without the goal; a one-site war repays in ≥ 20 seasons;
  - rebellions: 1–5 per run; no feud lasts more than 120 seasons without a war or a truce;
  - seasons 1–40: income and stipends per tier within ±25 % of the Formulas budget table;
  - season 400: median own track level 10–14 for tier 1, 8–10 for tier 2, 4–6 for minor sects;
  - no treasury stays above 3 · R for more than 8 seasons in a row;
  - minor sects Strained in ≤ 30 % of sect-seasons and Collapsing in ≤ 5 %;
  - the strongest S is ≤ 2.0 × the runner-up's at every season, and no sect holds more than 6 of the 20 regions;
  - median vassal loyalty 40–70, Defiant ≤ 20 % of vassal-seasons;
  - members by realm within ±20 % of the start.
- **AC-SM-43** [Integration] Determinism. **GIVEN** two 400-season runs on one seed, **THEN** sect records, war-score logs
  and boards are byte-identical; adding one board leaves every war's ε unchanged.
- **AC-SM-44** [Integration] Performance (**guess**). **GIVEN** 27 sects, 702 attitude pairs and about 3,300 members,
  **THEN** the sect tick takes ≤ 8 ms mean and ≤ 15 ms p99 over 400 seasons (about 10 % of the 60–90 ms world tick,
  Realms open question 21), and the attitude pass ≤ 1 ms.
- **AC-SM-45** [Config] **THEN** every Formulas value is read from `sects.json`; setting g to 1.5 makes Holdings cost(2)
  3,000 with no code change; a missing key fails the load and names the key.
- **AC-SM-49** [Logic] Rule 19a, F14. **GIVEN** a Hóa Thần member, **THEN** a secret-realm place costs 600,000
  contribution and a council pull 150,000; a Luyện Khí's season of arrays costs 20. **GIVEN** an inner disciple, **THEN** a
  council pull is refused (elders only). **GIVEN** a borrowed treasure worth 50,000, **THEN** the deposit is 100,000 and is
  returned in full when the treasure comes back on time. **GIVEN** a levy call against the sect's pact partner, **THEN** it
  is refused.
- **AC-SM-50** [Logic] F15. **GIVEN** a Greedy, Ambitious, Paranoid Strategist head and a hostile neighbour, **THEN** its
  pulls are Tax +1, Expansion +1, War readiness +1, loyalty −2, war odds 0.9, first track Military; it is bold, and War
  readiness moves 2 → 4 in one season. **GIVEN** a Stubborn head with needs +2 on Tax, **THEN** the target is 3 and the
  dial moves one step. **GIVEN** an Honest head, **THEN** it never breaks a pact. **GIVEN** a leader generated with
  traits, **THEN** it has exactly 3 personality traits, no two from one opposed set, and 1 calling. **GIVEN** a Fickle
  head and one seed, **THEN** the fickle draws repeat exactly.
- **AC-SM-51** [Logic] F5b. **GIVEN** a Defiant vassal at 600, a backer at 5,000 and a lord at 10,977 in one other war,
  **THEN** it rebels (1.02 ≥ 1.0); **GIVEN** the lord at peace (S_spare 10,977), **THEN** it pays half tribute instead.
  **GIVEN** a bordering great sect with attitude 25 to the vassal and −5 to the lord, **THEN** the vassal changes lord
  at loyalty 50 and the old lord's attitude to that sect falls by 20; **GIVEN** an Ambitious vassal head in that case with
  the rebel test passing, **THEN** it rebels instead.
- **AC-SM-52** [Logic] Rule 23a, F16. **GIVEN** a tagged manual, **THEN** markets in its owner's territory refuse it and a
  market elsewhere pays ×1.5; an outer disciple cannot receive it. **GIVEN** a sale 50 tiles from a seat with Military 6,
  **THEN** p = 0.18 a season, no check runs after 20 seasons, and on discovery the seller's and holder's standing each
  fall by 40. **GIVEN** a sale 300 tiles away, **THEN** p = 0.024.

- **AC-SM-53** [Logic] F17. **GIVEN** capacity 56, 38 members and Recruitment 2, **THEN** intake is 1 Luyện Khí; **GIVEN** 50 or more members, **THEN** intake is 0; **GIVEN** a Strained sect, **THEN** intake is 0.
- **AC-SM-54** [Logic] F18. **GIVEN** Expansion 4, war_odds 1.0 and a feuding target at S ratio 0.8, **THEN** it declares and names a border region; **GIVEN** Expansion 1, **THEN** the goal is a site; **GIVEN** Expansion 2 and a target with a bordering vassal, **THEN** the goal is that vassal. **GIVEN** a seat region above the protection line, **THEN** it is never named.
- **AC-SM-55** [Logic] F19. **GIVEN** FX-T1 at peace, **THEN** Trade is chosen; **GIVEN** a track that fell 2 seasons ago, **THEN** it is chosen first; **GIVEN** War readiness 0 / 2 / 3 / 4, **THEN** the Military mix is 0.10 / 0.30 / 0.40 / 0.50 and the other three split the rest 0.25 : 0.20 : 0.25 (at 4: Holdings 0.179, Institutions 0.143, Trade 0.179).
- **AC-SM-56** [Logic] F10, rule 23a. **GIVEN** a discovered leak, **THEN** the seller and the holder each lose 40 standing with the owner; **GIVEN** a refused levy, **THEN** −10 with the player's own sect. Standing is stored per (sect, player) as a float.
- **AC-SM-57** [Logic] F15 dispute ruling. **GIVEN** two vassals at loyalty 40 and 70 and a head with no ruling trait, **THEN** they become 42 and 70; **GIVEN** a Just head, **THEN** 42 and 72; **GIVEN** a Steward at Thriving, **THEN** its Tax pull is −1 and it is 0 otherwise.

## Open Questions

User direction, 2026-11-14 (built into this GDD): major sects are the powers; minor sects are their vassals; sects decide
each region's economy through their development and their leaders' decisions; leaders' traits work like the character
traits of grand-strategy games (NPC Traits #42).

| # | Question | Owner | Blocks |
|---|---|---|---|
| 1 | ~~May a winning rebel that takes a whole region become a great sect?~~ **Answered 2026-11-14:** yes, tier 2, if its head is Nguyên Anh or above; otherwise it picks a lord | user | — |
| 2 | ~~May a great sect fall in play?~~ **Answered 2026-11-14:** yes, but its seat region can be taken only while its strength is below half its starting strength (rule 17, F9) | user | — |
| 3 | ~~Contribution at the top may outrun a sect's stock.~~ **Answered 2026-11-14:** contribution also buys services and privileges (rule 19a, F14). Still open: the guidance bonus belongs to Realms & Bottlenecks | user, economy-designer | Realms |
| 4 | ~~One anchor key, `world_production_guess` (250,000 a season) in F3~~ **Closed 2026-11-14 by Regional Economy & Trade (#43):** F3 reads its Formula I; the anchor survives only as its check AC-RE-36. Re-derive the Formulas budget table and rerun AC-SM-42 with the harness | economy-designer | AC-SM-42 |
| 5 | ~~Same board as Quests?~~ **Answered 2026-11-14:** one board, two lists with separate rules (rule 24). Quests needs a back-reference line | user | Quests |
| 6 | **Decided 2026-11-14:** the provisional trait list is in `design/gdd/npc-traits.md` (37 personality traits in 18 sets, 6 callings; 3 + 1 per leader); Sects owns only the pull kinds (F15). Fate-given traits, stat effects and rolling are now designed in `design/gdd/npc-traits.md` (2026-11-14) | user | — |
| 7 | ~~A Defiant vassal's choice.~~ **Answered 2026-11-14:** ordered checks, F5b | user | — |
| 8 | ~~Review the small-case defaults.~~ **Answered 2026-11-14:** kept, with the upkeep order changed (calling's track last, lowest level first, Military last at war) | user | — |
| 9 | **Deferred 2026-11-14 to World Generation & History (#27):** authored starting levels, dials, attitudes, treasuries, alignments and leaders' traits for the great and minor sects, at or below F1's settle levels | user, world-builder | AC-SM-01 |
| 10 | ~~Sect-forbidden manuals.~~ **Answered 2026-11-14:** owner tag, black market ×1.5, discoverable leak (rule 23a, F16) | user | — |
| 11 | **Thiên Xu Tông as peacekeeper in play.** The history (World Generation rule 15, `design/world/territory_history_proposal.json`) makes Thiên Xu the neutral middle kingdom that enforces the North Star Compact of year 510: land changes hands only by a fall, a gift, an oath or a war licensed by its writ. Should play keep this, with a writ needed for a war of conquest and Thiên Xu stepping in against a sect that wars without one? Lore and starting strength only for now (user decision 2026-11-15) | user | — |

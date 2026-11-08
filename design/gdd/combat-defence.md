# Combat Defence & Healing (Phòng Ngự & Trị Thương)

> **Status**: Designed 2026-11-07 (revised the same day for Combat Damage Types, #21b: resistance per damage type, flat block, body shields; body guard retired). Design review 2026-11-08 (lean, overnight, four passes): Needs Revision; revised the same day with the user's answers (shields uncapped, drain billing completed). Re-review 2026-11-08 (lean, three passes): Needs Revision, see `reviews/combat-defence-review-log.md`; revised the same day with the user's answers to all 23 items (soul shield formula; ward-strength terms moved here; drain billing for shared block and a short pool; a Down refusal is not healing)
> **Author**: user + agents
> **Last Updated**: 2026-11-08 (re-review answers applied; see `reviews/rereview-2026-11-08-decisions.md`)
> **Last Verified**: 2026-11-08
> **Implements Pillar**: Power Is Built, Not Given (3); Every Number Is Bounded and Visible (2); Your Dao, Your Name (1)
> **Parent system**: Combat (#21, `design/gdd/combat.md`). This is sub-system #21a. It owns the whole defence path (evade, resistance, block, wards and body shields, health, soul and status defence) and healing in a fight. Combat keeps offence, the timeline, triggers and results, and is revised afterwards to point here (systems-index design order, user decision 2026-11-07).
> **Scope decisions (user, 2026-11-07)**: all of defence; healing allowed in ordinary fights, capped per pulse and decaying over the fight, none inside Heavenly Tribulation waves for now; the ward is redesigned (Combat Formulas D and rule 22 are replaced); ward models may reserve linh lực.

## Summary

Combat Defence & Healing, a sub-system of Combat, decides what a blow does after it is struck:
evade, then resistance by damage type, then a flat block, then shields from wards and the body, then
health. Wards are spells in free ward slots that grow with realm and thần thức. They layer, carry
resistance, block, shield, evade, status or soul payloads, and are paid by reservation, upkeep, per hit, drain or cast. Healing works in ordinary
fights, capped per pulse and fading over time, so builds are tested on more than damage.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Combat, Character Stats, Modifier System`

## Overview

Combat Defence & Healing decides what happens to a blow after it is struck. Every hit except a soul hit
follows one path:
1. it may be **evaded**;
2. **resistance** cuts a share of it by its damage type (Combat Damage Types, #21b);
3. **block** takes a flat amount off it;
4. **shields** soak what is left: ward shields first, then the body's own shields;
5. what remains reaches **health** (khí huyết).

Ticks meet resistance and the shields that do not let them pass. Soul hits meet only soul resistance and soul wards. Health may rise
again during a fight through regeneration, heal arts and Effects, but healing is capped every pulse and
fades as the fight goes on.

The centre of the system is the **ward** (hộ thể). A ward is a spell that sits in a slot. Every
cultivator gets free ward slots, which grow with realm and with thần thức, and every slotted ward is up at
once, so defences can be layered. A ward is what it carries (resistance, block, a shield, evade, status or
soul defence) and how it is paid:
- **reserved**, out of maximum linh lực;
- **upkeep**, which grows heavier the longer it is held;
- **per hit**;
- **drain**, a flat bill per point it prevents;
- **cast**, on a cooldown.

This makes the ward a build slot like any other: a sword cultivator under a Fire-resistance aura, a body
cultivator whose hardened skin is a shield and a block, or a formation master behind layered shields.

The player meets the system before the fight, choosing wards and sources of resistance, and reads it in
every hit's Breakdown and in the health, shield and linh lực bars. It replaces Combat's one-ward rule and
drain model (Combat rule 22, Formulas D), which three overnight builds showed could lose a fight by being
stronger or last forever on regeneration. It also gives healing builds the rule they were missing.

## Detailed Design

### Core Rules

> `game-designer` and `systems-designer` not consulted for this section — Lean mode. Review manually before production.

**The defence path**

1. **Every incoming threat follows one path.** Evade is rolled first. Offence is then resolved in Combat:
   conversion, layers, crit and suppression (Combat Formulas C and H). What arrives meets the rest of the
   defence path for its damage type (Combat Damage Types rule 4; user decisions 2026-11-07):

   | Threat | Path |
   |---|---|
   | Any hit except Soul, per part | evade → resistance → block → shields → health |
   | Over-time tick | resistance → the shields that do not let it pass → health. Ticks skip evade and block |
   | Soul hit | soul resistance and soul wards → its share of health and linh lực (Combat Formulas E2). Skips everything else |
   | Curse | status resistance (its chance) → applied or not. Curses never deal damage (Combat rule 8) |

   - Evade is one roll per hit, before anything else (Combat Formulas I, unchanged): an evaded hit deals
     nothing.
   - A hit part that reaches health deals at least 1, as today.
   - Each step and its numbers show in the hit's Breakdown (Combat rule 16).

   This replaces Combat rule 4's "meets the ward, then the body guard", Combat rule 22, rule 23's body
   guard and all of Combat Formulas D. Formulas D's ward strength, ward efficiency and artifact-defence terms
   (`ws`, `we`, `ward_floor`, `ward_cap`, `a_w`, `a_b`) now live in this GDD's Formulas A0; the Combat revision
   (systems-index #43) leaves a stub in Combat D that points here (re-review CD 2).

**Resistance**

2. **Resistance is a defence stat by damage type.** It cuts a share of damage. A side holds:
   - **all resistance**, which applies to every damage type except Soul;
   - **one resistance per damage type**: Physical, Force, Fire, Cold, Lightning, Light and Chaos (Combat
     Damage Types rule 5). Soul keeps soul resistance (rule 14).

   It comes from wards (rule 6), items, techniques, the Way, the tree and other sources. All of them
   are plain modifiers on the resistance stats (Modifier System), and they add.

3. **One resistance per part.** A hit part's resistance is all resistance plus the resistance of its
   **final damage type**, the type it carries after conversion (Combat Damage Types rule 6), then capped.
   A tick uses the same sum for its own type (a burn is Fire, a poison Chaos). Elements never enter
   resistance (Combat Damage Types rule 2).

   - **Cap:** 75 % by default (`resist_cap`). Rare modifiers raise it for one damage type or for all, up to a
     hard 90 % (`resist_cap_max`) (user decision 2026-11-07). No sum of resistances makes a damage type harmless.
   - **Floor:** curses and penalties can push resistance below 0, down to −50 % (`resist_floor`). A part
     then takes up to 1.5 times its damage.

4. **Resistance penetration is the offence answer.** The offence stat resistance penetration (scoped by
   damage type, or by any tag like a damage modifier) lowers the defender's resistance for that part before the cap is
   applied, down to the floor. Realm pierce stays a separate stat that acts on suppression (Combat
   Formulas H). Penetration is added to the Modifier System's Stat List.

**Wards are spells**

5. **A ward is a spell, and it uses a spell slot.** A ward record holds:
   - an id, tags (always `ward`, plus elements and forms as authored) and a realm;
   - one or more **payloads** (rule 6);
   - a **payment** (rule 8);
   - an **activation** (rule 7).

   A ward sits either in a **ward slot** or in an ordinary art slot. Every slotted ward is up at the same
   time, so a side can layer wards (user decision 2026-11-07). The one-ward-at-a-time rule of Combat
   rule 22 is gone.

   **Ward slots are free.** Every cultivator gets free ward slots, which only wards may use:
   - **By realm:** 1 at Qi Refining, 1 at Foundation Establishment, 2 at Core Formation, 2 at Nascent Soul
     and 3 at Deity Transformation (`ward_slots_by_realm`).
   - **By thần thức** (user decision 2026-11-07): +1 slot when the side's thần thức reaches
     `ward_slot_sense_step` times its realm's reference thần thức, and +1 more at twice that step, for at
     most +2.
   - **By modifiers:** a rare modifier, +1 ward slot (Modifier System rule 13).

   A ward in an ordinary art slot gives up that art. Creatures and NPCs follow the same rules.

   **No-ward flags** (re-review CD 11, for Effects such as No Ward): a side flagged `cannot_slot_wards`
   cannot slot any ward, in a ward slot or an art slot; compile rejects one and names it. A side flagged
   `no_default_ward` has no default ward (rule 11).

6. **A ward carries payloads, and payloads are what it does.** A ward may carry more than one.

   | Payload | While the ward is up |
   |---|---|
   | **Resistance** | Adds its resistance modifiers (all, or by damage type) to the side's sums (rule 2) |
   | **Block** | Adds a flat block to every hit (rule 12) |
   | **Status** | Adds status resistance, and may carry cleanse tags that a cleanse reads (Combat rule 8) |
   | **Soul** | Adds soul resistance, and may hold a soul shield that soaks a share of each soul hit's losses from its own bar (rule 14, Formulas B) |
   | **Shield** | A shield bar of its own size, which soaks damage after resistance and block (rule 9) |
   | **Evade** | Adds evade (rule 13) |

   - **Ward strength** scales the ward's own payload numbers: `× (1 + ws / 100)`, so it raises resistance,
     block, shield size, a soul shield's bar and evade granted. It never scales a soul shield's share, and it
     never raises the ward's cost (rule 8).
   - **Ward efficiency** lowers every payment and speeds shield recharge (Formulas).
   - Neither stat touches resistance that comes from items or other sources.
   - Both caps stay at 400 (`ward_cap`).

7. **Activation: standing or cast.**
   - A **standing** ward is up from t = 0 for as long as its payment holds.
   - A **cast** ward is slotted with a cooldown like an art (Combat rule 13). Each time it fires, it pays
     its cast cost and goes up for its authored duration. A shield is refilled when it fires. Before its
     first firing it is **Waiting**, and between firings it is **Expired** (States; re-review CD 22).
   - Before a fight the player may switch any standing ward off, to keep its linh lực for arts. Ward
     expiry keeps Combat rule 10's rule: a ward stays up through the whole millisecond it expires in.

8. **Payment: five models**, set on the ward record. Every model is reduced by ward efficiency.

   | Model | Pays | Up while | Character |
   |---|---|---|---|
   | **Reserved** | Holds a share of maximum linh lực for the whole fight (rule 10) | Always, once reserved | Steady and unbreakable by starvation, but less linh lực for arts |
   | **Upkeep** | A fee at t = 0 and at every pulse, **rising by `upkeep_growth` each pulse it has been held** | The fee can be paid | Strong early, tiring late. It can no longer last forever on regeneration (fixes the overnight finding) |
   | **Per hit** | A fixed fee for each hit or tick it meets | It can pay that hit's fee | Its payload applies only to hits it paid for. Beats big hits, strains under many small ones |
   | **Drain** | Linh lực per point of damage its payload prevents, at a rate that **falls with ward strength as fast as the payload rises**, so the bill stays flat while protection grows | Linh lực is above 0 | The classic warding spell. More strength never costs more, which fixes "strength can lose a fight" |
   | **Cast** | The cast ward's cost, paid when it fires (rule 7) | Its duration lasts. A broken shield ends only the shield, not the ward's other payloads (re-review CD 5) | Burst defence on a cooldown |

   - **Per hit** means one fee per hit, covering all of its parts, and one fee per tick.
   - **Several drain wards** bill in proportion to the damage each prevents. If the pool cannot cover the
     total, each pays the same share of what is there, and that unpaid share of the prevented damage
     leaks through (Formulas C).

   All payments come from the live linh lực pool that art costs use, except reserved, which comes off the
   top. A ward whose payment fails is **down** until it can pay again. Shields are not paid by drain:
   their bar is their budget. Drain also cannot pay evade, status or soul payloads, which have no clean
   "damage prevented" (user decision 2026-11-08). A drain-paid block payload is billed on its share of the
   block points the hit actually lost, split by each source's share of `B_hit` (Formulas C; re-review CD 3).

9. **Shields soak, in order.** A shield is a pool that soaks damage before health. Ward shields and the
   body's shields are one concept (user decision 2026-11-07: body armour is a shield too). Shields meet a
   hit part after resistance and block:
   - **Order:** ward shields first (ward slots, then art slots, each in slot order), then body shields
     (the body under the spell), in the order their sources list.
   - Each shield soaks as much of the part as it holds, and the rest moves to the next shield, then to
     health.
   - **What passes a shield is data on the shield** (Combat Damage Types rule 7). Ward shields are passed by
     Soul and by ticks by default; body shields by Soul and Chaos, so a burn wears a body shield down and a
     poison slips past it.
   - A shield at 0 is **broken**.
   - A **standing shield starts full** at t = 0. While its ward is Down (unpaid), the shield keeps its value,
     does not soak and does not recharge (re-review CD 6).
   - A **standing shield** recharges at its rate once `recharge_delay` seconds pass without it soaking
     anything. A broken one waits the same delay.
   - A **cast shield** refills only when its spell fires again.
   - A **body shield** never refills on its own. Only an Effect restores it, such as a hardening art or a
     pill (user decision 2026-11-07).
   - Soul hits meet only soul shields.
   - Shields have no total cap (user decision 2026-11-08: "let's make it uncapped"). Ward shields are
     bounded by their own sizes (σ ≤ 0.50 of `qi_max` each), the number of ward slots and their W price.
     The body shield is bounded by its W-priced sources, and it never refills on its own. `shield_total_cap`
     and `body_shield_cap` stay as data knobs, **off by default**, so the harness can restore a cap if
     shields stall fights (Formulas B, AC-CD-59).

**Reservation**

10. **Reserving linh lực.** A reserved ward holds `reserve_share · (1 − reservation efficiency / 100)` of
    maximum linh lực from t = 0 for the whole fight (overnight decision 12; reservation efficiency kept by
    user decision 2026-11-07).
    - The side's usable maximum is `qi_max · (1 − Σ reserved)`. Linh lực starts at that, and art costs,
      regeneration and payments work inside it. Art costs stay a share of the full `qi_max` (Combat
      Formulas E), so heavy reservation means fewer casts.
    - Total reservation is capped at `reserve_cap` (90 %), counted on the effective shares after
      efficiency. A ward that would pass it cannot be slotted.
    - Reservation efficiency counts at most 50 %, and ward efficiency counts at half weight on
      reservation (Formulas C), so the two cannot multiply a 90 % reservation down to almost nothing.
    - Reservation is not damage and cannot be drained. A soul hit's linh lực loss comes out of the usable
      pool only.
    - Other Effects may reserve linh lực under this same rule (Effects System, #41).

**The default ward**

11. **Everyone has a default ward, and it is the fallback.** It is decided per hit part: whenever no
    other ward of the side is Up for that part, the default ward is. A per-hit ward that could not pay for
    the hit counts as not Up for it, and a ward whose only payload is a broken shield counts as Up. A ward
    with no resistance, block or shield payload that applies to the part (a status-only or soul-only ward,
    such as Clear Heart Ward or Soul-Guarding Lamp) does not count as Up for it, so it never costs the side
    its default protection (re-review CD 8). A side flagged `no_default_ward` (rule 5) has none.
    The default ward is: an all resistance of 0.30 (`default_resist`) paid by drain at 2.0 (`default_drain`),
    exactly the old default ward's protection. Ward strength and efficiency do not apply to it: it is a
    floor, not a build piece. It needs no slot. A side with no linh lực has no default ward. Unless it built
    resistance from other sources, block, body shields or a reserved ward, every hit then lands nearly in
    full, which keeps Combat rule 23's "being a mortal".

**Body defence, block, evade, soul and status defence**

12. **Body defence replaces body guard** (user decision 2026-11-07). The body defends like a ward that
    needs no linh lực and no slot. Căn cốt, body techniques (luyện thể) and body gear grant any of:
    - **body shields** (rule 9), which never refill on their own;
    - **block**: a flat amount taken off every hit, once per hit, split across its parts by size, and
      never from ticks. Block answers many small hits, which proportional resistance cannot;
    - **resistance** (rule 2).

    Each piece's sizes are set when that piece is designed, inside its W price (Modifier System Formulas A–C; this GDD's Formulas H lists them),
    not the ward price check. Block from all
    sources adds. A part reduced to 0 by block deals nothing, but a part that gets past block and reaches
    health deals at least 1. Body guard (`body_guard_pct`, Combat rule 23 and Formulas D) is retired. A thể
    tu is now a build that stacked body shields, block and Physical resistance, and its weakness is Chaos,
    which passes body shields.

13. **Evade is unchanged** (Combat Formulas I): every hit except Soul, cap 0.40, set against accuracy.
    Evade payloads may add to it.

14. **Soul defence.** Soul resistance keeps its place in Combat Formulas E2 (it raises the defender's
    side of rho). Soul wards add soul resistance and soul shields. A **soul shield** has a share and a bar
    (user decision 2026-11-08, re-review CD 1): after E2's `pct` sets a soul hit's losses to health and
    linh lực, the shield takes its share of each loss off its own bar until the bar is empty. The share is
    capped below 1 (`soul_shield_share_max`), and ward strength scales the bar, never the share (Formulas B). **Every profile has a soul defence**:
    reference enemies and NPCs carry thần thức and soul resistance by realm, so soul results can be
    trusted (overnight decision 8).

15. **Status defence.** Status resistance keeps its role in Combat Formulas F, as the chance to avoid a
    status or curse. Status payloads add to it. The damage of a tick is cut by the resistance of its damage
    type (rule 3), not by status resistance.

**Healing**

16. **Health may rise inside an ordinary fight** (user decision 2026-11-07; overnight decision 7).
    Healing comes from:
    - **health regeneration**, a plain stat that restores a share of maximum health at each pulse;
    - **heal arts**, arts with a heal payload;
    - **Effects** such as lifesteal or a heal on a trigger (Effects System, #41).

    Every heal is multiplied by the healer's healing stat and by the receiver's healing taken (which a
    curse may lower), then by **healing decay** (rule 18), then clipped by the **heal cap** (rule 17).

17. **The heal cap.** All healing a side receives between two pulses is at most `heal_pulse_cap` of its
    maximum health. A heal at a pulse instant counts in the window that is ending, as Combat counts its
    per-pulse limits (Combat rule 10). This is a smaller share than ticks may deal (`dot_pulse_cap`, Combat Formulas F), so
    pressure from ticks can outpace healing. Heals apply in the order they occur; the excess is clipped and
    logged "heal cap". Health never rises above its maximum, and overheal is lost.

18. **Healing decays over the fight.** Healing is multiplied by a factor that falls with fight time, from
    full strength at t = 0 to a floor of `heal_decay_floor` by `heal_decay_end` seconds. A healer cannot
    stall a fight to the time limit. A long fight still favours the build that brought sustain, but it
    must win, not just outlast.

19. **Where healing never works.**
    - A side that is **Down** cannot be healed. The defeat check is final (Combat rule 10).
    - **A Down refusal is not healing** (user decision 2026-11-08, re-review CD 21). An Effect's refusal at the
      Down step (Effects rule 11), which sets health to 1 instead of letting the side fall, is not a heal: it
      works under `no_heal`, takes no healing decay and does not count toward `heal_pulse_cap`. A tribulation
      that should forbid such saves says so in its own rules.
    - A fight request may carry `no_heal`. **Heavenly Tribulation sets it on every wave** (user decision
      2026-11-07), so healing inside waves is 0 for now. Thiên Kiếp rule 7 already forbids healing between
      waves.
    - **Healing never raises vitality.** After the fight, `v_after = min(v, health_end / health_max)`
      still holds (Combat Formulas A). Healing only keeps a side standing during the fight; its injuries
      are the caller's (Combat rule 14).

**Pricing and readability**

20. **Every ward has a price check.** It is the counterpart of the art lint (Combat Formulas C). A ward's
    payloads, payment and activation must fit a budget for its realm and slot, so no ward is cheap and
    universal (overnight decisions 1 and 2). The check lives in Formulas, together with the **ward
    catalogue**: a first set of records for each payload and payment, so builds have real wards to choose
    from.

21. **NPCs and creatures defend the same way.** Profiles compile resistances, wards, shields, block and
    healing through the same rules (Combat rule 18), and the Breakdown names each one.

### States and Transitions

**A ward in a fight**

| State | Meaning | Enters when | Leaves when |
|---|---|---|---|
| Off | Switched off before the fight | The player chose it | Never in this fight |
| Waiting | A cast ward before its first firing; payloads do not apply | t = 0 | Its spell fires |
| Up | Its payloads apply | Standing: t = 0 with payment met. Cast: its spell fires | Payment fails or duration ends (a broken shield ends only the shield) |
| Down (unpaid) | Payloads do not apply | Upkeep, per-hit or drain payment cannot be met | The next payment it can meet |
| Broken | A shield ward at 0 shield; its non-shield payloads stay up if paid, and it counts as Up for the default-ward fallback (rule 11) | Its shield reaches 0 | Recharge begins after `recharge_delay` (standing) or its spell fires (cast) |
| Expired | A cast ward whose duration ended | Duration ends (it stays up through that millisecond) | Its spell fires again |

The default ward is Up for a hit part whenever no other ward of the side is Up for that part and linh lực
is above 0 (rule 11).

**A side's health:** Standing → Down at the defeat check (Combat rule 10). Healing applies only while
Standing, and never to a Down side.

### Interactions with Other Systems

| System | Direction | Data | Interface owner |
|---|---|---|---|
| Combat (#21) | in / out | In: each hit part after offence (final damage type, elements, tags, damage), ticks, soul hits, fight time, pulses, the `no_heal` flag. Out: what reached health and linh lực, ward and shield states, heals, Breakdown lines | Combat (timeline, offence, results); this GDD (the defence path, wards, healing) |
| Character Stats (#7) | in | Maximum health and linh lực, thần thức and its realm reference, căn cốt, the defence stat sums | Character Stats |
| Modifier System (#40) | in | Resistance (all and per damage type), resistance cap, penetration, block rating, body shield, ward strength and efficiency, reservation efficiency, ward slots, healing, healing taken, health regeneration, evade, soul and status resistance | Modifier System (stats and prices); this GDD (what they do) |
| Effects System (#41) | in | Lifesteal and triggered heals, other reservations, curses that lower healing taken or resistance | Effects System |
| Cultivation Techniques (#9), The Way (#39) | in | Ward spells and heal arts as technique and Way content; resistance and block modifiers | each system |
| Item DB (#13), Artifact Refining (#16) | in | Ward-role artifacts, resistance affixes, body gear | Item DB |
| Talismans (#18), Formations (#17), Alchemy (#15) | in | Cast wards from talismans, formation wards and ground resistance, healing pills (provisional) | each system |
| Heavenly Tribulation (#22) | in | `no_heal` on every wave; resistance as its defence against tribulation lightning | Heavenly Tribulation |
| NPC Builds | in | The same profile rules (rule 21) | NPC Builds |
| Debug Terminal, Game UI (#37) | out | Health, shield and linh lực bars, reserved share, ward states, heal and cap lines | Game UI |

## Formulas

> `systems-designer` consulted 2026-11-07. User choices the same day:
> - drain billing covers only what is prevented;
> - stronger auras (`reserve_weight` 1.5);
> - `recharge_delay` 2 s;
> - guard payloads stay flat guard and evade (since revised: body guard is retired, so ward payloads grant block and evade instead).
>
> Adopted as recommended, not objected to: the default ward 0.30 / 2.0 is not scaled by ward strength or
> efficiency; `shield_total_cap` (since removed: shields are uncapped, user decision 2026-11-08); half-weight efficiency on reservation; reservation efficiency capped at
> 50. Every number is a guess or a derivation from Combat's Qi Refining typical anchor (health 109.9, linh
> lực 172.7, incoming 36.5 per second, D 41.3, ws = we = 30.8) until the balance harness confirms it.

**Revision 2026-11-07 (Combat Damage Types, #21b):** resistance is all + the part's final damage type; flat
block replaces body guard; body shields join ward shields. `systems-designer` re-derived A, A2, B, G, H and I.
User choices: base block from flesh + armour with ward gear capped; split block by size after resistance;
separate shield caps (since removed: shields uncapped 2026-11-08); Iron Shirt stacking accepted; body gear gives mainly shield (0.60 per a_b, top-end
1.0 × B_p); restoring a body shield counts as healing; Force resistance is broad; type-scoped penetration
matches the final type.

**Calibration.** The typical defender is tuned to match Combat's old typical ward exactly. Old pass
0.344 at drain 0.956 becomes resistance 0.654 at 0.959 linh lực per point prevented. So the typical
effective health (now 297.8 with block, was 298), the typical mirror (about 7.7 s), the suppression table and
the unbuilt mirror (about 24 s) all carry over at Qi Refining. The thể tu keeps its toughness against
Physical (570 against 575), stays weaker against Force (368.5) and is weakest against Chaos (221.3) (Formulas G).

### A0. Ward strength, ward efficiency and artifact defence

Moved here from Combat Formulas D (re-review CD 2; the Combat revision #43 leaves a stub there). The values
are unchanged.

`ws = clamp(defense_pct + Σ ward_strength + 100 · ward_gear_scale · min(a_w, 1), ward_floor, ward_cap)` ; `we = clamp(ward_efficiency_pct + 100 · ward_gear_scale · min(a_w, 1), 0, ward_cap)` ; `a_w = Σ (defence of artifacts without the body tag) / (B_p · stage_mult)` ; `a_b = Σ (defence of body-tagged artifacts) / (B_p · stage_mult)`

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| defense_pct | float | ≥ −100 | Modifier System (`defense_pct`, ward strength) | Tree nodes keep their W price |
| ward_strength | float | any | modifiers and Effects naming ward strength | Added flat |
| ward_efficiency_pct | float | ≥ 0 | Modifier System | Lowers payments, speeds recharge |
| ward_gear_scale | float | 0.30 | data file | Artifact defence 0.85 × B_p gives +25.5 to both ws and we |
| a_w | float | ≥ 0 | Item DB | **All non-body artifact defence** (re-review CD 10; the role-tag rename is draft D2). Counts up to 1 for ws, we and gear block |
| a_b | float | 0–1.0 per piece at top end | Item DB | Body-tagged artifact defence. One top-end body piece gives 1.0; a_b sums every body-tagged piece, so 2.0 means two top-end pieces (re-review CD 9) |
| ward_floor, ward_cap | float | −90, 400 | data file | ws stays above −90 so `1 + ws/100` stays positive; both stats cap at 400 |

**Anchor:** Combat's typical fixture FX-T sets ws = we = 30.8. With a_w 0.85 the gear term gives 25.5 of that,
so the remaining 5.3 comes from modifiers (derived, not a separate fixture value).

### A. Resistance

The resistance formula is defined as:

`r_j = clamp(R_all + R_type(j) − pen_j, resist_floor, cap_j)` ; `cap_j = min(resist_cap_max, resist_cap + Σ cap_raise scoped all or to type(j))` ; `R_x = R_x,other + Σ_w r_w,x · (1 + ws/100)` ; `a_j = D_j · (1 − r_j)`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| D_j | float | ≥ 0 | Combat Formulas C | The part after layers, crit and suppression |
| R_all | float | any; only the final r is floored | Modifier System (`resist_pct`, no scope) | All resistance: every type except Soul |
| R_type(j) | float | any; only the final r is floored | Modifier System (`resist_pct` scoped to a damage type) | Resistance of the part's **final** damage type only (Combat Damage Types rule 6) |
| R_x,other | float | any; only the final r is floored | items, the tree, the Way, techniques, body pieces | Not scaled by ws |
| r_w,x | float | 0–0.60 per ward (`ward_resist_max`) | ward record | One ward's resistance payload on x (all or a type) |
| ws | float | −90 to 400 | Formulas A0 | Ward strength, capped by `ward_cap` 400 |
| pen_j | float | ≥ 0 | Modifier System (`resist_pen_pct`, scoped by type or tag) | Taken before the cap. A type scope matches the final type only |
| resist_cap, resist_cap_max, resist_floor | float | 0.75, 0.90, −0.50 | data file | Rule 3 |
| cap_raise | float | 0–0.15 per source | rare modifier (`resist_cap_pct`) | Counts only if scoped to all or to the part's type |

**Output Range:** r from −0.50 to 0.90, so a_j runs from 0.10 · D to 1.5 · D.

**Example:** a Fire part, D 41.3:
- R_all 0.654 (the Common Ward's 0.50 × 1.308) plus R_Fire 0.503 (items 0.15 + the Flame-Quelling Aura's
  0.353) = 1.157, capped at 0.75, so a = **10.3**. With penetration 20, it is still 10.3.
- The Common Ward alone with penetration 10 gives r 0.554 and a = **18.4**.
- FX-T's block of 0.95 then leaves **9.4** and **17.5**.
- A Metal-tagged Physical part ignores R_Fire, so a = 14.3.

**Anchors:** unchanged, because the Common Ward's "general 0.50" is now "all 0.50".

| Realm | Typical ws | Typical r (Common Ward) | Top-end r |
|---|---|---|---|
| Qi Refining | 30.8 | 0.654 | 0.75 |
| Foundation Establishment | 37.9 | 0.690 | 0.75 |
| Core Formation | 47.9 | 0.740 | 0.80 (cap raise) |
| Nascent Soul | 62.5 | 0.75 (cap) | 0.85 |
| Deity Transformation | 84.1 | 0.75 (cap) | 0.90 |

**Default ward:** all 0.30 at drain 2.0, which is exactly the old default ward. Ward strength and efficiency do
not apply to it.

### A2. Block

The block formula is defined as:

`B_hit = block_unit[r] · stage · (b_flesh + b_gear + Σ b_src + Σ_w b_w · (1 + ws/100))` ; `b_flesh = flesh_block · n_body` ; `b_gear = gear_block · (min(a_w, 1) + a_b)` ; `k_j = a_j · min(1, B_hit / Σ_i a_i)` ; `c_j = a_j − k_j` ; after shields soak `h_j` ; `dealt_j = 0 if h_j ≤ 0, else max(1, h_j)`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| block_unit[r] | float | 0.0631 / 0.2031 / 0.6672 / 2.254 / 6.883 | data file, derived: `U_r · M_typ[r] / (100 · M_typ[QR])` | Points per block rating, so block keeps its share of a typical hit at every realm |
| stage | float | per stage | Combat Formulas A | The defender's stage multiplier |
| flesh_block | float | 4.4 | data file | Flesh's rating per n_body, calibrated to the unbuilt mirror |
| n_body | float | 0.25–8 | Combat Formulas A | Căn cốt and health % raise it |
| gear_block | float | 12 per unit of a | data file | Ward gear counts up to a = 1; body gear counts in full (Formulas B) |
| a_w, a_b | float | ≥ 0 | Formulas A0 | All non-body artifact defence; body-tagged artifact defence |
| b_src | float | ≥ 0 | body techniques; `block_rating` modifiers | Block rating from other sources |
| b_w | float | 0–100 (`ward_block_max`) | ward record | A ward's block payload, scaled by ws |
| a_j | float | ≥ 0 | A | Each part after resistance |
| k_j | float | 0–a_j | calculated | The part's share of block, split by its size after resistance |

**Output Range:** one hit loses exactly `min(B_hit, Σ a_j)`, however it is split. Block never touches ticks or
Soul. A part reduced to 0 deals nothing; a part that gets past block and shields deals at least 1.

**Why split after resistance:** splitting by D would waste block on parts that resistance has mostly zeroed.
With parts of D 30 Physical (r 0) and D 30 Fire (r 0.90) against B 8, splitting by D deals 26.0, and splitting
after resistance deals **25.0**.

**Typical block** is flesh 4.4 × n_body (4.8) plus armour 12 × a (10.2, from the typical artifact defence 0.85),
so 15.0 rating (user decision 2026-11-07). An unbuilt side (no gear, n_body 1.0) keeps 4.4, so the unbuilt
mirror stays at 24.3 s.

| Realm | Typical (rating / points) | Top-end, ward gear | Thể tu | Thể tu + Iron Shirt |
|---|---|---|---|---|
| Qi Refining | 15.0 / 0.95 | ≈ 17 / 1.1 | 88 / 5.6 | 148 / 9.3 |
| Foundation Establishment | 15.7 / 3.2 | ≈ 18 / 3.7 | 95 / 19.3 | 155 / 31.5 |
| Core Formation | 16.4 / 10.9 | ≈ 19 / 12.7 | 100 / 66.7 | 160 / 107 |
| Nascent Soul | 17.7 / 40 | ≈ 21 / 47 | 105 / 237 | 165 / 372 |
| Deity Transformation | 19.2 / 132 | ≈ 23 / 158 | 110 / 757 | 170 / 1,170 |

Typical block takes 7.5 / 8.8 / 10.9 / 12.2 / 13.3 % of the standard hit after resistance, close to the
retired body guard's 6.8–12 %. The Foundation Establishment to Deity Transformation n_body values are
estimates until the harness measures them.

**Block against the cheap 0.5 s kit.** The fast art is c 1.2, cost 0.04, D 24.75 (13.8 linh lực per second);
the slow art is c 3.3, 3 s, cost 0.15, D 68.1.

| Defender | Fast hit dealt | Slow hit dealt | Damage per linh lực, fast / slow |
|---|---|---|---|
| Typical (r 0.654, B 0.95) | 7.62 (−11 %) | 22.62 (−4 %) | 1.10 / 0.87 |
| Thể tu (r 0.60 on Physical, B 5.57) | 4.33 (−56 %) | 21.67 (−20 %) | 0.63 / 0.84 |
| Typical + Iron Shirt (B 5.9) | 2.67 (−69 %) | 17.7 | 0.39 / 0.68 |

The fast kit edges a typical defender (×1.26) and loses to block builds (×0.57 to ×0.75). Block makes it a
counter-build matchup rather than a universal answer, which closes the gap the first draft left open (Open
Question 3).

**Example:** a typical Common Ward hit: 41.3 × 0.346 = 14.29 after resistance, minus block 0.946 = **13.3**
dealt.

### B. Shields

The shield formula is defined as:

ward shield `S_w = σ · qi_max · (1 + ws/100)`, recharging at `shield_recharge · S_w · (1 + we/100)` per second once `recharge_delay` passes with no soak ; body shield `S_body = health_max · Σ σ_b`, never recharging on its own ; `σ_b,gear = body_gear_shield · a_b` ; order: ward shields (ward slots, then art slots), then the body shield ; optional caps, off by default: `Σ S_w ≤ shield_total_cap · health_max` and `S_body ≤ body_shield_cap · health_max`, clipping maximum sizes at compile, later slots first ; for a cast shield, `σ ≤ shield_per_cost · β · κ`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| σ | float | 0–0.50 | ward record | Ward shield size as a share of the full `qi_max` |
| σ_b | float | ≥ 0 | body techniques, body gear, `body_shield_pct` | Body shield as a share of `health_max`. Not scaled by ws |
| body_gear_shield | float | 0.60 per unit of a_b | data file | Body gear's shield (user decision 2026-11-07: body gear gives mainly shield, worth the same W per defence point as ward gear, 0.648) |
| a_b | float | 0–1.0 per piece at top end | Formulas A0 | Body-tagged artifact defence / (B_p · stage_mult). Top-end body gear is 1.0 × B_p, against 5 × B_p for ward gear; 2.0 is two top-end pieces |
| κ | float | 0.04–0.25 | ward record | Cast cost share |
| β | float | 1.0–2.5 | Modifier System Formulas B | The ward's breadth multiplier |
| shield_per_cost | float | 0.76 | price check (1.25 · ε_0) | Cast shields are sized against their cost |
| shield_recharge, recharge_delay | float | 0.25 per second, 2.0 s | data file | Ward shields only (user decision 2026-11-07: 2 s) |
| shield_total_cap | float or none | none (off); 1.0 if restored | data file | Optional cap on ward shields together, as a share of `health_max` (user decision 2026-11-08: uncapped) |
| body_shield_cap | float or none | none (off); 1.0 if restored | data file | Optional cap on the body shield, as a share of `health_max` |

**Output Range:** no total cap. Each ward shield is at most 0.50 · qi_max · (1 + ws/100), one per ward or art
slot holding a shield ward. The body shield is health_max · Σ σ_b: 0.90 × for the thể tu at Qi Refining, 1.5 ×
at a_b 2.0 with Iron Body tier 3.

- **One body-shield bar.** All body sources share the default pass list (Soul and Chaos pass), so they form one
  bar. A source that authors a different pass list gets a bar of its own.
- **Body shields grow with health.** They are a share of `health_max`, so căn cốt and health % raise them.
- **Restoring a body shield is healing** (user decision 2026-11-07). An Effect that restores it counts toward
  `heal_pulse_cap`, takes healing decay, and is 0 under `no_heal`.
- **No body-shield cap** (user decision 2026-11-08). Past σ_b 1.0 (a_b ≥ 1.17 with Iron Body tier 3, or a_b ≥
  0.84 with tier 5), body gear keeps adding shield as well as block. The harness checks that no shield build
  stalls a fight to `time_limit` (AC-CD-59); if one does, the first fix is to restore a cap knob.

**Soul shield** (rule 14; user decision 2026-11-08, re-review CD 1):

`S_soul = σ_soul · qi_max · (1 + ws/100)` ; for each soul hit, after Combat Formulas E2's `pct` gives losses `L_h` (health) and `L_q` (linh lực): `soak_x = min(S_soul,left, s_soul · L_x)` for x = h then q ; `L_x ← L_x − soak_x` ; `s_soul ≤ soul_shield_share_max`

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| σ_soul | float | 0–0.50 | ward record | The soul shield's bar as a share of `qi_max`, scaled by ws |
| s_soul | float | 0–0.75 | ward record | Share of each soul-hit loss the shield takes. Never scaled by ws |
| soul_shield_share_max | float | 0.75 | data file | Keeps every soul hit landing in part |

A soul shield is a ward shield passed by everything except Soul hits; it recharges like any standing ward
shield. Soul-Guarding Lamp's shield is s_soul 0.50 with a bar of σ_soul 0.10 (G: a guess until the price check
covers soul payloads, Open Question 8).

**Example:** Mountain Screen gives **61.0**. The thể tu's body shield is 0.90 × 121.15 = **109.0**.

### C. Payments

The ward_payment formulas are defined as:

`pay_mult = 1 / (1 + we/100)` ;
reserved `= ρ · (1 − min(res_eff, res_eff_cap)/100) / (1 + we/200)` of qi_max ;
upkeep at pulse n `= u · qi_max · pay_mult · (1 + upkeep_growth)^n` (n = 0 at t = 0, counted from the ward's first Up, never reset) ;
per-hit fee `= φ · qi_max · pay_mult` per hit or tick met ;
drain: `rate_w = drain_base / ((1 + ws/100)(1 + we/100))` ; resistance payload `prevented_w = D · max(0, r_eff) · r_w / R_pos`, and 0 when R_pos = 0 ; block payload `prevented_w = blk_w = min(B_hit, Σ a_j) · B_w / B_hit`, its share of the block points the hit lost ; `bill = min(pool, rate_w · prevented_w)` ; a short pool's unpaid share of a resistance payload's prevented damage is added back to `a_j` before block, and a drain-paid block's unpaid share is simply not taken ; drain is invalid for evade, status and soul payloads (the price check rejects them) ;
cast `= κ · qi_max · pay_mult` at each firing

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| we | float | 0–400 | Modifier System (`ward_efficiency_pct`) | Ward efficiency. Counts half on reservation |
| ρ | float | 0.05–0.90 | ward record | Reserved share; all reservations together are capped by `reserve_cap` 0.9 |
| res_eff, res_eff_cap | float | 0–50; 50 | Modifier System (`reserve_eff_pct`); data file | Reservation efficiency, capped so the reservation stack stays bounded |
| u, upkeep_growth | float | 0.01–0.10; 0.15 | ward record; data file | Upkeep share and its geometric growth per pulse |
| φ | float | 0.02–0.20 | ward record | Per-hit fee share |
| drain_base | float | ≥ 1 / (ε_0 · β) | ward record | Price-checked drain rate |
| r_eff | float | −0.5–0.9 | calculated (A) | The part's final resistance |
| r_w | float | ≥ 0 | calculated (A) | This ward's scaled payload on the part (all, or the part's final damage type) |
| blk_w | float | ≥ 0 | calculated (A2) | This ward's share of the block points the hit actually lost: `min(B_hit, Σ a_j)` split by each source's share of `B_hit` (flesh, gear, other sources and each ward's `B_w`). Block a hit did not need is not billed (user decision 2026-11-08; re-review CD 3) |
| B_w | float | ≥ 0 | A2 | This ward's scaled block points inside `B_hit` |
| R_pos | float | ≥ 0 | calculated | Sum of the part's positive resistance terms before penetration. Billing is split by share and does not depend on ward order (user decision 2026-11-07: bill only what is prevented) |
| κ | float | 0.04–0.25 | ward record | Cast cost share |

**Output Range:** every payment is ≥ 0 (a floored or negative r_eff bills 0, and so does a part with no
positive resistance), reserved is at most 0.9 · qi_max, and a drain bill never exceeds the live pool. The
shortfall leaks through: the unpaid share of a resistance payload's prevented damage rejoins the part before
block, so it meets block and shields like any damage; a drain-paid block that cannot be paid in full takes
only its paid share (re-review CD 3).

**Why the bill stays flat.** Below the cap and with no penetration, r_eff = R_pos, so
prevented_w = D · r_w0 · (1 + ws/100). The bill is then D · r_w0 · drain_base / (1 + we/100), with no
ws term. Over the cap or with penetration, prevented_w ≤ D · r_w, so the bill only falls. No other model
has a ws term. **Total payment never rises with ward strength**, which fixes "strength can lose a fight".

**Other overnight faults:**
- **Regeneration outlasting upkeep:** even at the smallest upkeep (u 0.01) and the regeneration cap, with
  no arts, a full pool empties and the ward falls by about 25–27 s at we 0 and about 36 s at the maximum we
  400, both inside the 40 s time limit; at u 0.03 and we 0, by about 18 s. The we 400 case is tight, so the
  harness confirms it (Open Questions).
- **Two wards' order:** resistance adds and drain is split by share, so order does not matter. Only
  shields have an order (rule 9). The floor and the cap belong to the side, not to each ward.
- **The cheap 0.5 s art kit** is now a counter-build matchup: flat block punishes many small hits (Formulas
  A2), so the fast kit edges typical defenders and loses to block builds.

**Example** (typical, D 41.3): 41.3 × 0.346 = 14.3 gets through, and the bill is 27.0 × 0.959 = **25.9**
linh lực (the old mean was 26.4). Block 0.946 leaves **13.3** dealt. An upkeep ward at u 0.045 and
we 0 costs 7.8 at t = 0 and 18.0 at 6 s (5.9 and 13.7 at the typical we 30.8).

### D. Ward slots

The ward_slots formula is defined as:

`ward_slots = ward_slots_by_realm[r] + min(2, floor(divine_sense / (ward_slot_sense_step · ds_ref[r]))) + Σ bonus_ward_slots`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| ward_slots_by_realm | int | 1 / 1 / 2 / 2 / 3 | data file | User decision 2026-11-07 |
| divine_sense | float | ≥ 0 | Character Stats Formulas C | The side's thần thức |
| ds_ref[r] | float | 45 / 135 / 450 / 1,350 / 4,500 | Character Stats Formulas C (talent 45, stage 1.00) | Reference thần thức, the same convention as Combat's ref_k |
| ward_slot_sense_step | float | 1.75 (1.5–2.0) | data file | +1 slot at 1.75 × the reference, +2 at 3.5 × |
| bonus_ward_slots | int | ≥ 0 | rare modifier (Modifier System rule 13) | +1 each |

**Output Range:** from 1 at Qi Refining up to 5 plus bonuses at Deity Transformation.

**Example:** talent 45 at peak stage (×1.45) with +25 % thần thức has 81.6 thần thức against a step of 78.75,
so **2 slots** at Qi Refining. +2 needs a soul build, such as talent 60, peak stage and +82 % thần thức. A
step of 1.5 would be too low, because peak stage alone would nearly reach it.

### E. Healing

The healing formulas are defined as:

`heal = base · (1 + healing_pct/100) · (1 + taken_pct/100) · d(t)` ; `d(t) = max(heal_decay_floor, 1 − (1 − heal_decay_floor) · t / heal_decay_end)` ; heal art `base = U · stage · c_heal` ; regeneration `base = health_max · min(hregen_base + hregen_bonus, hregen_cap)` per pulse ; `Σ heals between two pulses ≤ heal_pulse_cap · health_max` ; heal lint `c_heal ≤ heal_lint_ratio · (basic_coef · (1 + art_coef_per_cost · cost_share) + art_coef_per_cooldown · (cooldown − 1))`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| U, stage | float | per realm | Combat Formulas A | The healer's fight unit and stage multiplier |
| c_heal | float | ≥ 0 | art record | Heal coefficient, bounded by the heal lint |
| healing_pct | float | 0–200 | Modifier System (`healing_pct`) | The healer's healing |
| taken_pct | float | −100 to +100 | Modifier System (`healing_taken_pct`); curses | The receiver's healing taken |
| heal_decay_end, heal_decay_floor | float | 15 s, 0.10 | data file | Linear decay to a floor (rule 18) |
| hregen_base, hregen_bonus, hregen_cap | float | 0; 0–0.02; 0.02 | data file; Modifier System (`health_regen_pct`); data file | No innate health regeneration, so the anchors are unchanged |
| heal_pulse_cap | float | 0.04 | data file | Below `dot_pool_cap` 0.05 and `dot_pulse_cap` 0.08 (rule 17) |
| heal_lint_ratio | float | 0.3 | data file | A heal art heals at most 0.3 of the damage coefficient the art lint allows |
| basic_coef, art_coef_per_cost, art_coef_per_cooldown | float | 1.0, 12, 0.25 | Combat Formulas C | The art lint's terms |

**Output Range:** 0 to 0.04 · health_max per pulse window, and never above health_max. Body-shield restores
share this cap and the decay, and are 0 under `no_heal` (Formulas B).

**Why 0.3.** At typical, one point healed is worth 1 / λ = 3.12 incoming points (Formulas G), and one point
of damage coefficient is worth M · crit EV = 3.61. Parity would be about 1.16 × the art lint, but high
resistance multiplies what a heal is worth, so the ratio is set at 0.3. That makes a typical heal art
about one pulse cap.

**Stall check.** A pure healer at the cap, facing an unbuilt attacker (3.8 % of health per second), dies at
**37.6 s**, inside 40 s. With a floor of 0.25 it would last about 43.8 s (continuous model; the harness
confirms both figures with discrete pulses, AC-CD-45), which is a stall.

**Example:** a heal art at cost 0.15 and cooldown 3 s:
- The lint gives 3.3, so c_heal ≤ 0.99, which heals 6.25 (5.7 % of health).
- At t = 0 the cap clips it to **4.4**.
- At t = 10 s, d = 0.40, so it heals **2.5**.

### F. Ward price check

The ward_price formula is defined as:

`V_w ≤ ε_0 · β_w · α_m · C_w`, evaluated at ws = we = 0 for a bare defender, over the **standard stream** (one hit of size I per second) for `T_ref` = 8 s

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| V_w | float | ≥ 0 | calculated | Health points prevented by the payloads. **Resistance:** r · I · T, assuming every part matches its scope. **Shield:** σQ once if standing, min(σQ, I · duration) per firing if cast. **Block:** min(B_w, I) · T. **Evade:** e · I · T. **T** is `T_ref` for a standing ward and the ward's up time inside `T_ref` for a cast ward, floor(T_ref / cooldown) × duration (re-review CD 19; Black Tortoise Shell: 0.33 × 36.5 × 2 s = 24.1, ratio 0.930). A block payload paid per hit balances itself, since both are sensitive to hit count in opposite directions. **Status and soul:** 0.008 · I · T per W of their stat price |
| C_w | float | > 0 | calculated | Linh lực paid. **Reserved:** ρQ · `reserve_weight`. **Upkeep:** 16.79 · uQ. **Per hit:** 8 · φQ. **Drain:** drain_base · V. **Cast:** κQ · floor(T / cooldown) |
| reserve_weight | float | 1.5 | data file | User decision 2026-11-07: stronger auras. Each reserved point counts 1.5 paid points, since it is held all fight |
| ε_0 | float | 0.61 | data file, anchored to the Common Ward (1 / 1.64) | Prevented points per linh lực point |
| β_w | float | 1.0 / 1.25 / 1.5 / 2.0 / 2.5 | Modifier System Formulas B | Narrower scopes buy more |
| α_m | float | drain 1.0, reserved 1.0, per hit 1.0, upkeep 1.15, cast 1.25 | data file | Upkeep can fail and grows; cast is down until its first firing and between firings |
| I, T_ref | float | Qi Refining 36.5 per second; 8 s | Combat Formulas K typical offence; the typical mirror | Per realm from the anchors |
| ward_resist_max, σ max | float | 0.60, 0.50 | data file | No single ward reaches the cap at ws 0 |

**Output Range:** a pass or fail lint; the margin is V / (ε_0 · β · α · C).

**How the payments trade off.** All payments are equal against the standard stream. Away from it, each
wins somewhere different:
- **Per hit** is 3 × better against one 3I hit every 3 s, and 4 × worse against three small hits plus a
  tick per second.
- **Drain** is best in short fights.
- **Reserved** is best in long fights and against strong attackers, because its cost does not grow with
  incoming damage, but it takes the casting budget.
- **Upkeep** is front-loaded.

No ward can be cheap and universal, because universal means β = 1.

**Example:** Golden Bell (per hit 0.14, r 0.40): V = 116.8, C = 193.5, ratio 0.604 ≤ 0.61, so it **passes**.

### G. Effective health

The ehp formula is defined as:

`x = Q_use / b`, and the wards never fall when b = 0 (only reserved wards and other sources), so then `ehp = P / λ_all` (re-review CD 7) ; `λ_s = max(λ_min, 1 − r_s − B_s / D_ref)` for s ∈ {all, fix} ; `P = H + S_std + S_body`, leaving out any shield the damage type passes ; `ehp = P / λ_all` if `x · λ_all ≥ P`, else `x + (P − x · λ_all) / λ_fix`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| H | float | ≥ 1 | Combat Formulas A | Health at the start |
| Q_use | float | ≥ 0 | qi_max · (1 − Σ reserved) | Usable linh lực |
| b | float | ≥ 0 | C: Σ drain rate_w · r_w + per-hit φQ / D_ref + total upkeep / (I · T_ref), plus `rate_w · B_w / D_ref` for drain-paid block payloads | Linh lực paid per incoming point |
| r_all, r_fix | float | −0.5–0.9 | A | Resistance with every ward up; with only reserved wards and other sources |
| B_all, B_fix | float | ≥ 0 | A2 | All block; body block plus reserved-ward block |
| D_ref | float | I · 1 s | the standard stream | In Combat Formulas K, use the attacker's mean hit size D̄ |
| λ_min | float | 0.02 | data file | Keeps ehp finite when block exceeds the hit |
| S_std, S_body | float | ≥ 0 | B | Standing ward shields (one fill) and the body shield |

**Output Range:** ehp runs from P / 1.5 (resistance at the floor, no block) up to 50 × P.

**Example (typical):** x = 275.55; λ_all = 0.346 − 0.946 / 36.5 = 0.32006; health lost while the ward holds is
88.19; then 21.68 / 0.97406 = 22.26, so ehp = **297.8** (it was 298.1 with body guard, a drift of −0.1 %). For
the healing ratio, one point healed is now worth 1 / λ = 3.12 incoming points (was 3.10).

**The thể tu at Qi Refining:** block 88.3 rating (flesh 5.3 + gear 12 + Iron Body tier 3 30 + 41 from W), so
B 5.57; body shield 109.0 (σ_b 0.90 = technique 0.30 + gear 0.60); Physical resistance 0.30 (Iron Body tier 3
0.20 + Black Iron Armour's Physical affix 0.10); health 121.15,
linh lực 164.1, the default ward only.

| ehp against | Old (body guard m 0.754) | Now |
|---|---|---|
| Physical | 574.7 | **570.4** |
| Force | 360.8 | **368.5** |
| Chaos (passes the body shield) | — | **221.3** |
| Physical, top-end-sized hits | 575 | **446** (block is small against big hits) |

**For Combat Formulas K** (Combat revision, systems-index #43):
- `t_w = Q_use / (D · b_drain + n_hits · fee + upkeep_avg(T0) + net_spend)`. This fixes the overnight fault that
  `t_w` has no term for per-hit or upkeep wards.
- `t_h = (S / λ_all + (H + heal(T0)) / λ_all) / D`, using D̄, with one fixed-point pass for the decaying heal.
- Combat Formulas C's `dealt_j`, Formulas F's tick factor and Formulas K's f are replaced by this GDD's path.
- Healing stays out of `display_power`'s ehp.

### H. Starter ward catalogue and body pieces

**Wards.** Values are at Qi Refining with ws = we = 0. **Check** is the price-check ratio against its limit.

| Ward | Payload | Payment, activation | Check | Wanted by |
|---|---|---|---|---|
| Common Ward (Hộ Thể Chân Khí) | all r 0.50 | drain 1.64, standing | 0.610 / 0.610 | Everyone; the typical anchor |
| Fire-Shunning Veil (Tị Hỏa Sa) | Fire r 0.60 | drain 1.10, standing | 0.909 / 0.915 | Anyone facing Fire foes or a Fire sect |
| Qi-Scattering Robe (Tán Khí Bào) | Force r 0.55 | drain 1.32, standing | 0.758 / 0.763 | Thể tu covering their Force weakness with idle linh lực |
| Flame-Quelling Aura (Trấn Hỏa Quang) | Fire r 0.27 | reserved 0.35 | 0.869 / 0.915 | The sword cultivator under a Fire aura |
| Still Lake Aura (Tĩnh Hồ Quang) | all r 0.27 | reserved 0.50 | 0.609 / 0.610 | Long fights, tribulation, art-light builds |
| Golden Bell (Kim Chung Tráo) | all r 0.40 | per hit 0.14, standing | 0.604 / 0.610 | Boss fighters, anyone facing slow heavy hits |
| Surging Tide (Triều Thủy Tráo) | all r 0.30 | upkeep 0.045, standing | 0.671 / 0.702 | Burst builds that end fights by 6 s |
| Mountain Screen (Sơn Hà Bình Chướng) | shield σ 0.27 | reserved 0.30, standing | 0.600 / 0.610 | Formation masters; fights against slow hitters |
| Thousand-Layer Cloud (Thiên Tầng Vân) | shield σ 0.20 | upkeep 0.018, standing | 0.662 / 0.702 | Layered-shield builds |
| Golden Light Shield (Kim Quang Thuẫn) | shield σ 0.09 | cast 0.12, cooldown 4 s, up 3 s | 0.750 / 0.763 | Art-speed builds, talisman users |
| Black Tortoise Shell (Huyền Quy Giáp) | Physical r 0.33 | cast 0.15, cooldown 5 s, up 2 s | 0.930 / 0.953 | Builds facing sword and fist cultivators |
| Clear Heart Ward (Thanh Tâm Chú) | status +37.5 pp, cleanse [poison] | reserved 0.23 | † | Anti-curse, anti-poison |
| Soul-Guarding Lamp (Hộ Hồn Đăng) | soul res +22.5 pp; optional soul shield, s_soul 0.50 on a bar of σ_soul 0.10 (G) | reserved 0.20 | † | Anyone facing soul builds |
| Iron Shirt (Thiết Bố Sam) | block 60 (3.79 at QR), evade +12 pp | reserved 0.42 | 0.600 / 0.610 | Thể tu and light-body hybrids; block adds linearly, so a thể tu gains about +60 % block (user decision 2026-11-07: accepted) |

† scaled ×1.5 by hand for `reserve_weight` 1.5; rerun the price check when the lint tool exists.

**Body pieces.** These are priced in W through the Modifier System, not by the ward price check.

| Piece | Grants | Value |
|---|---|---|
| Iron Body Art (Thiết Thân Công), tier t of 1–5 | per tier: block +10, σ_b +0.10, Physical resistance +6.7 pp. Tier 3: 30 / 0.30 / 0.20 | about 20.7 W per tier |
| Black Iron Armour (Ô Thiết Giáp), body-tagged artifact | at a_b 1.0 (top end): block 12, σ_b 0.60; may carry a Physical-resistance affix | about 65 W, the same as ward gear at a 1.0 |
| Căn cốt, per talent point | +2.22 % health, and so +2.22 % on the body shield; +0.1 block rating; no shield of its own | about 4.6 W to a thể tu, against its 3.0 price |

### I. W prices for the new defence stats

These belong in the Modifier System's Stat List and price table, which was rebuilt for this GDD on 2026-11-07; Open Question 1 checks them against it. **D**
marks a derived price, **G** a guess.

| Stat | Key | W per unit | | Basis |
|---|---|---|---|---|
| All resistance | `resist_pct`, no scope (universal ×1.0) | 1.25 / pp | D | +1 pp ≈ +1.0 % ehp at r 0.654, and 1 % ehp ≈ 1.26 W |
| Physical, Force resistance | `resist_pct` scoped (broad ×1.25) | 1.0 / pp effective | D | The old body and qi kinds, carried over by migration |
| Fire, Cold, Lightning, Light, Chaos resistance | `resist_pct` scoped (family ×1.5) | 0.83 / pp effective | D | Chaos stays family, but only rare sources may carry it (content rule) |
| Resistance cap raise | `resist_cap_pct` | 5 / pp, rare | D | At the cap, +1 pp cuts the leak by 4 %, about +4.2 % ehp |
| Resistance penetration | `resist_pen_pct`, scoped by type or tag | 3.0 / pp | D | 3.6 against a typical warded defender, 1.4 against the default ward |
| Block | `block_rating` | 0.4 / rating point | D | 0.41 to a thể tu, 0.22 to a typical side. Universal; grid 1 |
| Body shield | `body_shield_pct` (pp of health_max) | 1.0 / pp | D/G | Pegged to health's 1.2 × 0.85 (Chaos passes it and it never refills) |
| Health regeneration | `health_regen_pct` | 3.0 / pp per pulse | D/G | +1 pp over 8 s at mean decay 0.76 ≈ +6 % health ≈ 2.4 % ehp |
| Healing | `healing_pct` | 0.5 / % | G | No heal-build anchor exists yet |
| Healing taken | `healing_taken_pct` | 0.5 / % | G | Also counters curses |
| Ward slots | `bonus_ward_slots` | 30 / slot, rare | D/G | A first ward is about +77 % ehp over the default; a second about +25–35 % |
| Reservation efficiency | `reserve_eff_pct` | 0.8 / % (cap 50) | D | At a 50 % total reservation; 3.4 at 80 % |
| Body guard | `body_guard_pct` | **retired** (was 0.8) | — | Replaced by block and the body shield |
| Artifact defence | Item DB | about 0.648 per defence point on ward and body gear alike | D | Body gear's mapping was raised to match (user decision 2026-11-07) |

## Edge Cases

> `systems-designer` not consulted for this section — Lean mode. Review manually before production.

**Resistance**
- **If a part's resistance sum is above its cap**: it is capped. Penetration is subtracted first, so over-cap
  resistance absorbs penetration before the cap binds (Formulas A).
- **If resistance falls below −50 %** (curses, penalties, penetration): it is held at the floor, and the part
  takes at most 1.5 × its damage.
- **If cap raises would pass 90 %**: the cap is 90 %, and the excess raise does nothing.
- **If a part was converted**: only its final damage type counts for resistance, block and penetration;
  earlier types count for offence modifiers only (Combat Damage Types rule 6). Elements never enter
  resistance.
- **If the damage is tribulation lightning**: it is Lightning, so all resistance and Lightning resistance apply
  (Heavenly Tribulation).

**Wards and payment**
- **If linh lực reaches 0**: drain, per-hit and upkeep wards are down and so is the default ward. Reserved
  wards stay up, since they are already paid. A cast ward stays up until its duration ends; a broken shield
  ends only the shield.
- **If a per-hit ward cannot pay a hit's fee**: its payload does not apply to that hit. The next hit pays if it
  can. An evaded hit charges no fee, because evade comes first.
- **If an upkeep ward misses a payment**: it is down. Its growth counter keeps advancing, so a ward that fell
  late rarely comes back.
- **If a drain bill is larger than the live pool**: the pool pays what it can, and the unpaid share of the
  prevented damage leaks through.
- **If a cast ward fires while it is already up**: its duration restarts and its shield refills to its
  maximum. Firings never stack two copies.
- **If the same ward id is slotted twice**: rejected at compile. A ward is slotted at most once per side.
- **If a ward sits in an ordinary art slot**: it counts toward `slot_count` (Combat Formulas A2) and gives up
  that art.
- **If a side has more ward slots than wards**: the empty slots do nothing, and the default ward is up only
  for a part that no other ward is Up for (rule 11).
- **If the reservations together would pass 90 %**: the ward that would pass it cannot be slotted. Compile
  names it.
- **If reservation leaves less usable linh lực than an art's cost**: that art can never fire in this fight,
  and compile warns the player before the fight.

**Shields**
- **If a hit part is larger than all shields together**: shields soak in order (rule 9), ward shields then
  the body shield, and the rest goes to health.
- **If block is larger than a hit**: the hit deals 0 and is logged "blocked". Block is never carried over to
  the next hit.
- **If a body shield is damaged**: it stays damaged unless an Effect restores it. A restore is healing: it
  shares `heal_pulse_cap` and decay, and is 0 under `no_heal`.
- **If the body shield sources pass 1.0 × health_max**: nothing is clipped, because shields are uncapped
  (user decision 2026-11-08). If the `body_shield_cap` knob is set, the bar is clipped to it at compile.
- **If a shield soaks part of a hit**: its `recharge_delay` restarts from that millisecond, whether the shield
  is broken or not.
- **If the `shield_total_cap` knob is set and ward shields would pass it**: the maximum sizes are clipped at
  compile, later slots first, so a refiring cast shield never exceeds its clipped maximum. Off by default.
- **If a tick arrives**: by default it passes ward shields and meets the body shield (rule 9), unless its type passes that too
  (a poison is Chaos). Ticks never meet block. **If a soul hit arrives**: only soul shields meet it.
- **If the side is a boss**: `qi_max` and `health_max` already include `boss_pool_mult`, so shield sizes (and
  any cap knob that is set) scale with it.

**Healing**
- **If a heal lands on a side at full health**: nothing is restored, and only health actually restored counts
  toward `heal_pulse_cap`.
- **If heals in one pulse window pass the cap**: they apply in the order they occur, and the excess is
  clipped and logged "heal cap".
- **If a heal and lethal damage land in the same instant**: all of the instant's events resolve, heals
  included, before the defeat check (Combat rule 10). A heal can keep a side standing only if it lands
  inside that instant.
- **If a side is Down**: it cannot be healed. The defeat check is final.
- **If an Effect refuses the Down step** (Effects rule 11): health is set to 1, which is not a heal. It
  works under `no_heal` and takes nothing from `heal_pulse_cap` (re-review CD 21).
- **If a soul hit meets a soul shield**: the shield takes `s_soul` of each loss from its bar, health first;
  once the bar is empty, the rest lands in full (Formulas B).
- **If the fight request carries `no_heal`** (every Heavenly Tribulation wave): all heals are 0, and the log
  says "no healing here".
- **If healing taken reaches −100 %**: the side cannot be healed.
- **If healing would raise health above the start of the fight**: allowed inside the fight, but
  `v_after = min(v, health_end / health_max)` means vitality never rises (Combat Formulas A).

**Compile**
- **If thần thức or realm changes**: never mid-fight. Ward slots and every base defence sum are compiled
  once at the start (Combat rule 2). **Curses and Effects apply live on top** (re-review CD 20): a curse that
  lowers resistance, or an Effect that raises a ward while a condition holds, changes the sum at the read times
  the Effects System sets (Effects rule 5), without recompiling slots or base sums.

## Dependencies

| System | Kind | What this system needs | Status | Lists this system? |
|---|---|---|---|---|
| Combat (#21) | Hard, parent | Timeline, pulses, instants, offence (layers, crit, suppression), tags and conversion, the defeat check, results, the art lint, the evade formula | GDD approved for rules | Not yet: the Combat revision (#43) replaces rule 4's path, rule 22, rule 23's body guard and all of Formulas D, removes `ward_art_duration` from A2, and updates Formulas A's ehp and Formulas K |
| Character Stats (#7) | Hard | Maximum health and linh lực, thần thức and `ds_ref`, căn cốt, the stat sheet sums | In review | Not yet: add the new defence keys to Parameter keys |
| Modifier System (#40) | Hard | The defence and healing stats, their W prices, breadth, scope matching | Designed 2026-11-07; Needs Revision (design review 2026-11-08) | Yes: its Stat List carries the defence stats, its rule 7 leaves the caps here, and its Cross-References cite rules 2–4, 6, 7, 9–12 and Formulas A–E, I |
| Combat Damage Types (#21b) | Hard | The damage types that resistance is keyed on, conversion, and what passes each shield | Designed 2026-11-07; Needs Revision (design review 2026-11-08) | Yes: rules 4, 5 and 7 and its Cross-References |
| Effects System (#41) | Soft | Lifesteal, triggered heals, other reservations, curses on resistance and healing taken | Designed 2026-11-08; Needs Revision (design review 2026-11-08) | Yes: rule 6 (restores and reservation) and its Cross-References |
| Heavenly Tribulation (#22) | Soft | Sets `no_heal` on every wave; tribulation lightning is Lightning | Approved for rules | Not yet: its rule 7 should cite `no_heal` |
| Cultivation Techniques (#9), The Way (#39) | Soft | Ward spells and heal arts as content | In review; approved | Not yet |
| Item DB (#13), Artifact Refining (#16) | Soft | Ward-role artifacts, resistance affixes, body gear | Approved; built | Not yet |
| Talismans (#18), Formations (#17), Alchemy (#15) | Soft | Cast wards from talismans, formation wards, healing pills | Implemented, quick specs | Not yet |
| NPC Builds | Soft | The same profile rules, including a soul defence by realm (rule 14) | Implemented | Not yet |
| Game UI (#37), Debug Terminal | Soft | Bars, ward states, Breakdown lines | Not started; built | Not yet |

## Visual/Audio Requirements

> `art-director` not consulted — Lean mode, and the current client is the text Debug Terminal. Review
> before Game UI (#37) is designed.

The defence path must be legible at a glance, because the player reads it to understand why a build lived
or died (Pillar 2). Every defence event has a distinct cue.

| Event | Visual | Audio (Audio, #38, Full Vision) |
|---|---|---|
| Resistance cuts a hit | The hit number shows the cut share in its final damage type's colour (Combat Damage Types) | Soft dampened impact |
| A shield soaks | The shield bar drops; a ripple on the side's portrait | Glassy chime |
| A shield breaks | The bar flashes and empties; "shield broken" | Sharp crack |
| A shield starts recharging | The bar pulses once | Rising tone |
| A ward goes down (unpaid) | Its icon greys out | Low thud |
| A cast ward fires | Its icon lights, with a duration ring | Short cast sound |
| Heal | A green number; "heal cap" shown when clipped | Gentle bloom, softer as decay grows |
| Default ward takes over | The ward row shows "default" | None |

## Game Feel

- **The ward should feel like a choice.** Before a fight, picking three wards for three slots should
  read like slotting arts: which threats will I meet, and what can I afford? The pre-fight preview
  shows the expected cut per damage type.
- **Breaking a shield is a moment.** A shield that breaks is a beat in the fight log. A build that times its
  burst past a shield should feel it land.
- **Healing should feel urgent, not endless.** Early heals are strong. Late heals visibly fade, so a healer
  feels pressure to finish the fight rather than outlast it.
- **Reservation should feel like a trade.** The linh lực bar shows the reserved share as a locked segment,
  so the player sees what an aura costs in casts.
- **Response target:** every defence step appears in the hit's Breakdown in the same log line as the hit. No
  defence result is hidden or delayed.

## UI Requirements

- **Bars per side:** health; the body shield as its own bar over health; one bar per ward shield, stacked in
  slot order, or one segmented bar; linh lực with the reserved share drawn as a locked segment.
- **Ward row:** one icon per slotted ward, showing state (up, down, broken, expired, off), a duration ring for
  cast wards and a recharge indicator for standing shields. The default ward shows when it is the one up.
- **Resistance panel** (sheet and pre-fight preview): all resistance and each damage type's resistance with their
  caps, block rating and points,
  the share from wards against other sources, and over-cap amounts.
- **Breakdown line per hit:** evade → resistance (all + type, and the cap) → block → each ward shield → the
  body shield → health,
  plus the drain, fee or upkeep paid.
- **Heal lines:** amount, decay factor, healing and healing taken, and "heal cap" when clipped.
- **Compile warnings:** reservation over the cap; an art that cannot be afforded after reservation; a
  duplicate ward.
- **Debug Terminal first.** All of the above as text in the current terminal, before Game UI exists.

> **📌 UX Flag — Combat Defence & Healing**: This system has UI requirements. In Phase 4 (Pre-Production),
> run `/ux-design` to create a UX spec for the fight HUD and the ward loadout screen **before** writing
> epics. Stories that reference UI should cite `design/ux/[screen].md`, not the GDD directly.

## Cross-References

| This document | References | Value or rule | Use |
|---|---|---|---|
| Rule 1 | combat.md rules 4, 7, 8, 24; Formulas C, H, I | The order of offence, ticks, curses and soul hits | Replaced in part (the path); read |
| Rules 5–11 | combat.md rule 22, Formulas D | The old ward | Replaced |
| Rule 7 | combat.md rule 10 | A ward stays up through the millisecond it expires in | Read |
| Rule 10 | combat.md rule 11, Formulas E | "Nothing reserves it"; art cost as a share of `qi_max` | Replaced (reservation); read |
| Rule 10 | overnight `decisions.md` decision 12 | Reservation as the price of always-on effects | Adopted; reservation efficiency kept by user decision 2026-11-07 |
| Rule 12 | combat.md rule 23, Formulas D (body guard) | Body guard formula | Replaced by block and body shields |
| Rules 1–4, Formulas A2 | combat-damage-types.md rules 1, 2, 4–7 | The eight damage types; which pass which shields | Read |
| Rule 14 | combat.md Formulas E2; overnight decision 8 | Soul attack, `soul_res_pct`; a soul defence for every profile | Read; adopted |
| Rules 16–19 | combat.md Formulas A; overnight decision 7; thien-kiep.md rule 7 | `v_after`; healing allowed outside Tribulation waves | Read; adopted |
| Rule 17 | combat.md Formulas F | `dot_pool_cap` 0.05, `dot_pulse_cap` 0.08 | Read: `heal_pulse_cap` sits below them |
| Formulas A–C | combat.md Formulas A–D anchors | Health 109.9, linh lực 172.7, D 41.3, ws = we = 30.8, pass 0.344, drain 0.956 | Calibration source |
| Formulas D | character-stats.md Formulas C | Reference thần thức by realm | Read |
| Formulas E | combat.md Formulas C | The art lint's terms | Read |
| Formulas F, I | modifiers.md Formulas A–C | W, breadth multipliers, the value formula | Read |
| Formulas G | combat.md Formulas A, K | ehp, `t_w`, `t_h` | Replaced (ehp); proposed for K |
| Formulas B, I | item-database.md (artifact defence a_w, a_b) | Body gear mapping 0.60 σ_b and 12 block per a_b; top-end body gear 1.0 × B_p | Proposed change to Item DB |
| Formulas A0 | combat.md Formulas D | `ws`, `we`, `ward_floor`, `ward_cap`, `a_w`, `a_b`, `ward_gear_scale` | Moved here; Combat keeps a stub after #43 |
| Rules 5, 6, 10, 11, 19, Edge Cases | effects.md rules 5, 6, 11; No Ward | Reservation by Effects; restores; live changes; the Down step; `cannot_slot_wards`, `no_default_ward` | Read |
| Rules 5, 10, 16 | modifiers.md rule 13 | Rare modifiers (ward slots, cap raise) | Read |

## Tuning Knobs

All live in the data file. Added 2026-11-08 from the formula tables; no value changed. The safe ranges are
design estimates until the balance harness confirms them.

| Knob | Default | Safe range | What it tunes | Source |
|---|---|---|---|---|
| `resist_cap`, `resist_cap_max` | 0.75, 0.90 | 0.70–0.80; 0.85–0.90 | How much of a hit resistance can stop; the cap raise's ceiling | A, rule 3 |
| `resist_floor` | −0.50 | −0.75 to −0.25 | The most a hit can be amplified (1.5 × at default) | A |
| `default_resist`, `default_drain` | 0.30, 2.0 | 0.25–0.35; 1.8–2.2 | The free default ward; matches the old one | A, rule 11 |
| `block_unit[r]` | 0.0631 / 0.2031 / 0.6672 / 2.254 / 6.883 | derived; rederive if Combat's U or M changes | Block's share of a typical hit at every realm | A2 |
| `flesh_block`, `gear_block` | 4.4; 12 per a | 3.5–5.5; 10–14 | Unbuilt block; gear block | A2 |
| `body_gear_shield` | 0.60 per a_b | 0.50–0.70 | Body gear's shield (price parity with ward gear) | B |
| `shield_recharge`, `recharge_delay` | 0.25 / s, 2.0 s | 0.15–0.35; 1.5–3.0 | How fast standing ward shields come back | B |
| `shield_total_cap`, `body_shield_cap` | none (off) | none, or 1.0–2.0 | Optional shield caps, the fix if AC-CD-59 finds a stall | B |
| `upkeep_growth` | 0.15 | 0.10–0.20 | How fast upkeep wards tire (AC-CD-43) | C |
| `reserve_cap`, `res_eff_cap` | 0.9; 50 | 0.8–0.9; 40–60 | Most linh lực reservable; reservation efficiency's ceiling | C, rule 10 |
| `reserve_weight` | 1.5 | 1.25–1.75 | Aura strength per reserved point (price check) | F |
| `ε_0`, `shield_per_cost` | 0.61, 0.76 | anchored; move only with the Common Ward | Ward price check's yardstick | F |
| `ward_slots_by_realm`, `ward_slot_sense_step` | 1/1/2/2/3; 1.75 | as set; 1.5–2.0 | Free ward slots, and the thần thức bonus | D |
| `heal_pulse_cap` | 0.04 | 0.03–0.045 (below `dot_pool_cap` 0.05) | Most healing per pulse window | E |
| `heal_decay_end`, `heal_decay_floor` | 15 s, 0.10 | 12–20 s; 0.05–0.15 (0.25 stalls, AC-CD-45) | How fast healing fades in a fight | E |
| `heal_lint_ratio` | 0.3 | 0.25–0.40 | Heal art strength against the damage lint | E |
| `λ_min` | 0.02 | 0.01–0.05 | Keeps ehp finite | G |
| `ward_resist_max`, σ max | 0.60; 0.50 | 0.50–0.65; 0.40–0.60 | Largest resistance or shield one ward may carry | F |
| `ward_block_max` | 100 | 80–120 | Largest block payload on one ward | A2, F |
| `ward_cap`, `ward_floor` | 400; −90 | 300–500; fixed | Ceiling on ward strength and efficiency; floor on ward strength | A0 |
| `ward_gear_scale` | 0.30 | 0.25–0.35 | Ward strength and efficiency from artifact defence | A0 |
| `hregen_cap` | 0.02 | 0.015–0.03 | Most health regeneration per pulse | E |
| α_m | drain 1.0, reserved 1.0, per hit 1.0, upkeep 1.15, cast 1.25 | ±0.10 each | How the price check rates each payment model | F |
| `T_ref` | 8 s | 6–10 s | Length of the price check's standard stream | F |
| `soul_shield_share_max` | 0.75 | 0.50–0.90 | Most of a soul hit's loss a soul shield can take | B, rule 14 |

## Acceptance Criteria

> Drafted by `qa-lead` 2026-11-07. Every fixture value was recomputed from the formulas, and the two
> inconsistent worked examples it found are fixed in Formulas A and C.

**Fixtures and conventions**
- **FX-T** is Combat's typical fixture: health 109.87, linh lực 172.74, ws = we = 30.8, block rating 15.0
  (0.946 points), no body shield, U 6.31, stage 1.00.
- **FX-U** is Combat's unbuilt fixture, with block rating 4.4 (0.278 points).
- **Thể tu fixture:** Formulas G's Qi Refining thể tu: block 88.3 (5.57 points), body shield 109.0, R_all 0.30
  (default ward) and R_Physical 0.30 (so Physical 0.60, Fire and Chaos 0.30), health 121.15, linh lực 164.1.
- **Common Ward:** all r 0.50, drain 1.64.
- **FX-H:** FX-U carrying one heal art at the heal lint's maximum and no damage arts.
- **Tolerance:** ±0.1 unless a criterion says otherwise.
- **Test locations:** [Logic] tests go in `tests/unit/combat_defence/`, [Integration] tests in
  `tests/integration/combat_defence/`. **[Harness]** means the check runs in `tools/balance/autoplay.gd`, not
  in a unit test.

**Defence path (Rules 1, 12, 13, 15)**

- **AC-CD-01** [Logic] Rule 1. **GIVEN** a Physical hit part on FX-T with a ward shield, a body shield and the Common Ward, **WHEN** it resolves, **THEN** its Breakdown lists evade → resistance → block → ward shields → body shield → health in that order, and nothing reaches health while a shield it meets still holds.
- **AC-CD-02** [Logic] Rule 1. **GIVEN** an over-time tick on a side with a full ward shield and a full body shield, **WHEN** it resolves, **THEN** no evade roll and no block are logged and the ward shield is unchanged. **GIVEN** a Fire tick, **THEN** the body shield soaks it. **GIVEN** a poison (Chaos) tick, **THEN** it passes the body shield.
- **AC-CD-03** [Logic] Rules 1, 14. **GIVEN** a soul hit on a side with all resistance 0.75, a full ward shield, block 5.6 and a full body shield of 109.0, **WHEN** it resolves, **THEN** only soul resistance and soul wards change the result, and the ward shield, block and body shield are untouched.
- **AC-CD-04** [Logic] Rules 1, 15. **GIVEN** a curse with chance 1.0 against status resistance 0.375, **WHEN** it resolves, **THEN** its apply chance is 0.625 and health is unchanged either way. **GIVEN** a tick of 10 with status resistance 0.9, resistance 0 and no shields, **THEN** 10 reaches health.
- **AC-CD-05** [Logic] Rule 1. **GIVEN** an evaded hit, **THEN** no resistance, block, shield, per-hit fee, drain bill or health loss is logged. **GIVEN** a part of D 1.2 at r 0.90 and block 0, **THEN** 1 reaches health. **GIVEN** the same part on FX-T, **THEN** block takes it to 0 and it deals 0, logged "blocked".
- **AC-CD-06** [Logic] Rule 12. **GIVEN** FX-T at linh lực 0 with no ward up, **WHEN** a Physical hit of D 41.3 lands, **THEN** block still applies and 40.35 is dealt. **GIVEN** a body shield of σ_b 0.30 (33.0), **THEN** 7.39 is dealt.
- **AC-CD-07** [Logic] Rule 13. **GIVEN** evade 0.30 plus an evade payload of +9 pp and a +30 fortune lead, **WHEN** the roll is inspected, **THEN** it is clamped at 0.40, and ticks and soul hits never roll evade.

**Resistance (Rules 2–4, Formulas A)**

- **AC-CD-08** [Logic] Formulas A. **GIVEN** a Fire part of D 41.3 with R_all 0.654 (the Common Ward), item Fire +0.15 and the Flame-Quelling Aura's Fire 0.353, **THEN** r is 0.75 (capped from 1.157) and 10.3 gets through resistance. **WHEN** the attacker has penetration 0.20, **THEN** still 10.3. **GIVEN** the Common Ward alone and penetration 0.10, **THEN** r is 0.554 and 18.4 gets through. **WHEN** FX-T's block applies, **THEN** 9.4 and 17.5 are dealt.
- **AC-CD-09** [Logic] Rule 3. **GIVEN** an all-resistance sum of −0.80, **WHEN** a part of D 41.3 resolves, **THEN** r is −0.50 and after resistance it is 61.95.
- **AC-CD-10** [Logic] Rule 3. **GIVEN** two Fire-scoped cap raises of +0.10 and one Cold-scoped raise of +0.15, **THEN** a Fire part's cap is 0.90 (not 0.95), and a Cold part's cap is 0.90.
- **AC-CD-11** [Logic] Rule 3. **GIVEN** a Physical → Fire part, **THEN** it uses R_all + R_Fire only. **GIVEN** a Physical part from a Fire-element art, **THEN** it uses R_all + R_Physical, and the Breakdown shows type Physical and element Fire.
- **AC-CD-12** [Logic] Rule 2. **GIVEN** `resist_pct` +15 scoped Fire from an item, the tree and the Way, **THEN** R_Fire rises by 0.45. **WHEN** ws is 100, **THEN** those terms are unscaled and only ward payloads double.
- **AC-CD-13** [Logic] Rule 4. **GIVEN** `resist_pen_pct` 30 scoped Fire, **THEN** a Fire part's r falls by 0.30 before the cap, a Cold part's r is unchanged, and suppression is unchanged. **GIVEN** Physical-scoped penetration on a Physical → Fire part, **THEN** nothing changes; Fire-scoped penetration lowers its Fire resistance.

**Wards, slots and activation (Rules 5–7, Formulas D)**

- **AC-CD-14** [Logic] Formulas D. **GIVEN** Qi Refining with thần thức 81.6 (step 78.75), **THEN** there are 2 ward slots. **GIVEN** 78.74, **THEN** 1. **GIVEN** 157.5, **THEN** 3. **GIVEN** 400, **THEN** still 3. **GIVEN** Deity Transformation at 3.5 × ds_ref plus one `bonus_ward_slots`, **THEN** 6.
- **AC-CD-15** [Logic] Rule 5. **GIVEN** three wards in two ward slots and one art slot, **THEN** all three payloads apply at once, the art slot holds no art, and `slot_count` counts the ward.
- **AC-CD-16** [Logic] Rule 6. **GIVEN** a ward with r_w 0.40, shield σ 0.20 and block 60 at ws 50, **THEN** it gives 0.60 resistance, a shield of 0.30 × qi_max and 90 block rating, and its non-drain payment equals its payment at ws 0. **GIVEN** ws 500, **THEN** ws is treated as 400.
- **AC-CD-17** [Logic] Rule 7. **GIVEN** a cast ward with cooldown 4 s and duration 3 s, **THEN** it is Waiting until its first firing, Up from each firing through the whole millisecond at firing + 3 s, and Expired until the next firing. **GIVEN** its shield breaks while Up, **THEN** its other payloads stay up until the duration ends. **GIVEN** a refire while it is Up, **THEN** its duration restarts, its shield refills to its maximum, and only one copy exists.
- **AC-CD-18** [Logic] Rule 7. **GIVEN** a standing ward switched Off before the fight, **THEN** it is never Up and takes no payment, and the default ward covers each part for which no other ward is Up.

**Payments and reservation (Rules 8, 10, Formulas C)**

- **AC-CD-19** [Logic] Reserved. **GIVEN** Still Lake ρ 0.50 on FX-T, **THEN** the reserved share is 0.4333 and usable linh lực is 97.9. **GIVEN** res_eff 80 and we 400, **THEN** the share is 0.0833.
- **AC-CD-20** [Logic] Upkeep. **GIVEN** Surging Tide u 0.045 at we 0 on qi_max 172.74, **THEN** it costs 7.77 at t 0 and 17.98 at 6 s. **GIVEN** a missed fee at pulse 8, **THEN** the pulse 9 fee uses n = 9.
- **AC-CD-21** [Logic] Per hit. **GIVEN** Golden Bell φ 0.14 on FX-T, **THEN** it costs 18.49 per hit, one fee covering all of the hit's parts. **GIVEN** a pool of 10, **THEN** that hit gets no Golden Bell resistance, and the next hit it can afford does.
- **AC-CD-22** [Logic] Drain. **GIVEN** FX-T with the Common Ward and D 41.3, **THEN** 14.3 gets through resistance, the bill is 25.9, and 13.3 is dealt after block (14.29 − 0.946). **GIVEN** a pool of 10, **THEN** 10 is billed and the unpaid share of the prevented damage leaks. **GIVEN** two drain wards with a pool short of their total bill, **THEN** each pays the same share of the pool, and the same share of the total prevented damage leaks.
- **AC-CD-23** [Logic] Cast. **GIVEN** Golden Light Shield κ 0.12 at we 0, **THEN** each firing costs 20.73, and its shield fills to 15.55 at ws 0.
- **AC-CD-24** [Logic] Regression: strength can lose a fight. **GIVEN** the Common Ward at we 30.8 and D 41.3, **FOR** ws in {−90, −50, 0, 30.8, 50, 100, 200, 400}, **THEN** the drain bill is 25.9 for every ws up to the cap and strictly falls once the cap binds. **FOR** each of the five models, **THEN** total payment at a higher ws is never greater than at a lower one.
- **AC-CD-25** [Logic] Rule 10. **GIVEN** two reserved wards of 0.50 each at we 0 and res_eff 0, **WHEN** compiled, **THEN** the second is rejected with its id named. **GIVEN** 0.50 + 0.35 and an art of cost_share 0.20, **THEN** compile warns that the art is unaffordable (34.5 > 25.9).
- **AC-CD-26** [Logic] Rule 10. **GIVEN** a reserved share of 0.4333, **THEN** an art of cost_share 0.15 still costs 25.9, and a soul hit's linh lực loss lowers only the usable pool.
- **AC-CD-27** [Logic] Edge Cases. **GIVEN** the same ward id slotted twice, **WHEN** compiled, **THEN** it is rejected with the id named.

**Shields (Rule 9, Formulas B)**

- **AC-CD-28** [Logic] Formulas B. **GIVEN** Mountain Screen σ 0.27 on FX-T, **THEN** shield_max is 61.0. **WHEN** 2.0 s pass with no soak, **THEN** it recharges at 19.9 per second. **AT** 1.999 s, **THEN** it has not started. **GIVEN** a partial soak at 1.5 s, **THEN** the delay restarts.
- **AC-CD-29** [Logic] Rule 9. **GIVEN** FX-T with a ward-slot shield of 20 and an art-slot shield of 30, **WHEN** a part of 45 after resistance lands, **THEN** block takes 0.946, the ward-slot shield is Broken, the art-slot shield holds 5.95, and 0 reaches the body shield or health.
- **AC-CD-30** [Logic] Formulas B. **GIVEN** Mountain Screen at ws 400 on FX-T (raw 233.2), **THEN** the ward shield is 233.2 (shields are uncapped). **GIVEN** σ_b 1.3, **THEN** the body shield is 1.3 × health_max. **GIVEN** body gear a_b 1.0, **THEN** it gives σ_b 0.60 and block 12; a_b 2.0 plus Iron Body tier 3 gives σ_b 1.5, not clipped. **GIVEN** the `shield_total_cap` knob set to 1.0, **THEN** the same ward shields are capped at 109.87 at compile, later slots clipped first, and a refiring cast shield never exceeds its clipped maximum.
- **AC-CD-31** [Logic] Rule 9. **GIVEN** a Broken cast shield, **THEN** it never recharges by time, only by firing again.

**Default ward (Rule 11)**

- **AC-CD-32** [Logic] Rule 11. **GIVEN** FX-U with no wards and D 41.3, **THEN** r is 0.30, 28.91 gets through resistance, 28.6 is dealt after block, and the bill is 24.8, unchanged at ws 400 and we 400. **GIVEN** linh lực 0, **THEN** r is 0 and 41.0 is dealt. **GIVEN** a per-hit ward that cannot pay for a hit, **THEN** the default ward applies to that hit.

**Healing (Rules 16–19, Formulas E)**

- **AC-CD-33** [Logic] Formulas E. **GIVEN** d(t), **THEN** d(0) = 1.00, d(7.5) = 0.55, d(15) = 0.10 and d(30) = 0.10.
- **AC-CD-34** [Logic] Formulas E. **GIVEN** FX-T and a heal art of cost 0.15, cooldown 3 s and c_heal 0.99, **THEN** its raw heal is 6.25. **AT** t 0, **THEN** it applies 4.4 and logs "heal cap". **AT** t 10, **THEN** it applies 2.5. **GIVEN** a body-shield restore of 6.25 at t 10, **THEN** it applies 2.5.
- **AC-CD-35** [Logic] Heal lint. **GIVEN** cost 0.15 and cooldown 3 s, **THEN** c_heal 0.99 passes and 1.00 fails.
- **AC-CD-36** [Logic] Rule 17. **GIVEN** two heals of 3.0 in one pulse window on FX-T, **THEN** 3.0 and then 1.39 apply (cap 4.39). **GIVEN** a heal of 3.0 then a body-shield restore of 3.0 in one window, **THEN** 3.0 and 1.39 apply. **GIVEN** a heal at full health, **THEN** 0 counts toward the cap. **GIVEN** `hregen_bonus` 0.03, **THEN** regeneration uses 0.02. **GIVEN** a heal at a pulse instant, **THEN** it counts in the window that is ending.
- **AC-CD-37** [Logic] Rule 16. **GIVEN** healing_pct 100 and taken_pct −50, **THEN** the heal equals base × d(t). **GIVEN** taken_pct −100, **THEN** the heal is 0.
- **AC-CD-38** [Logic] Rule 19. **GIVEN** a lethal hit and a 4.0 heal in the same instant, leaving 2.0 health, **THEN** the side is Standing. **GIVEN** a Down side, **THEN** no heal applies.
- **AC-CD-39** [Logic] Rule 19. **GIVEN** `no_heal`, **THEN** every heal and every body-shield restore is 0, and the log says "no healing here". **GIVEN** v 0.7 and an end health of 90 %, **THEN** `v_after` is 0.7. **AT** an end health of 50 %, **THEN** it is 0.5.

**Price check, catalogue and ehp (Rule 20, Formulas F–H)**

- **AC-CD-40** [Logic] Formulas F. **GIVEN** Golden Bell, **THEN** V is 116.8, C is 193.5, the ratio is 0.604 and it passes. **GIVEN** φ 0.13, **THEN** the ratio is 0.650 and it fails.
- **AC-CD-41** [Config/Data] Formulas H. **GIVEN** the ward catalogue file, **THEN** every ward without † passes at its listed ratio (±0.005), including Iron Shirt at 0.600; every † ward is flagged "recheck"; and no ward exceeds `ward_resist_max` 0.60, σ 0.50 or `ward_block_max` 100.
- **AC-CD-42** [Logic] Formulas G. **GIVEN** typical FX-T, **THEN** x is 275.6 and ehp is 297.8 (±0.2). **GIVEN** the thể tu fixture, **THEN** ehp is 570.4 against Physical, 368.5 against Force and 221.3 against Chaos (±1.0). **GIVEN** block above the hit, **THEN** λ stays at least 0.02 and ehp is finite.

**Regressions from the overnight faults**

- **AC-CD-43** [Logic] Upkeep cannot last forever. **GIVEN** an upkeep ward with u 0.01, regeneration at `regen_cap` 0.08 and no arts, **THEN** the ward is Down before 40 s, at about 25–27 s at we 0 and at about 36 s at we 400.
- **AC-CD-44** [Logic] Ward order. **GIVEN** the Common Ward and the Fire-Shunning Veil in either slot order and no shields, **THEN** damage dealt, each ward's bill and the total bill are identical across 50 seeds.
- **AC-CD-45** [Harness] No stall. **GIVEN** FX-H at the heal cap against FX-U, **THEN** it is Down at 37.6 s (±1.0), before `time_limit`.
- **AC-CD-46** [Harness] Calibration. **GIVEN** the FX-T mirror at Qi Refining, **THEN** it lasts 7.7 s (±10 %). **GIVEN** the FX-U mirror, **THEN** 24.3 s (±10 %). **GIVEN** the other realms' typical mirrors, **THEN** each is within 10 % of 7.2 / 7.4 / 7.0 / 7.0 s (block is estimated to lengthen them by 1–2 %).

**Determinism and Breakdown**

- **AC-CD-47** [Logic] Determinism. **GIVEN** two sides with layered wards, shields, heals and one seed, **WHEN** the fight runs twice, **THEN** the logs are byte-identical.
- **AC-CD-48** [Logic] Rule 1. **GIVEN** any hit part except Soul, **THEN** its Breakdown lists evade; R_all, R_type (final type), penetration, cap and r; block (the hit's total and this part's share); each ward-shield soak; the body-shield soak; health dealt; each ward's payment; and the default ward when it applies.
- **AC-CD-49** [Logic] Edge Cases. **GIVEN** thần thức changed mid-fight by a fixture hook, **THEN** ward slots and the defence sums are unchanged.

**Cross-system**

- **AC-CD-50** [Integration] Rule 19. **GIVEN** a Heavenly Tribulation run, **THEN** every wave request carries `no_heal` = true, and lightning parts are Lightning, cut by R_all + R_Lightning.
- **AC-CD-51** [Integration] Rules 14, 21. **GIVEN** every reference NPC and creature profile at each realm, **THEN** each has thần thức > 0 and a soul resistance value. **GIVEN** a two-ward NPC, **THEN** it compiles by the same rules and its Breakdown names its wards.
- **AC-CD-52** [Integration] Modifier System. **GIVEN** `resist_pct` (all and type-scoped), `resist_pen_pct`, `block_rating`, `body_shield_pct`, ward strength, ward efficiency and `healing_pct` modifiers in a build, **THEN** the compiled profile's sums match the Modifier System's totals.

**Block and body shields (added with the revision)**

- **AC-CD-53** [Logic] Formulas A2. **GIVEN** parts of D 30 Physical (r 0) and D 30 Fire (r 0.90) against block 8 points, **THEN** block takes 7.27 and 0.73 and 25.0 is dealt. **FOR** any split of a hit, **THEN** the hit loses exactly min(B_hit, Σ a_j).
- **AC-CD-54** [Logic] Formulas A2. **GIVEN** the block_unit table, **THEN** one rating point is 0.0631 / 0.2031 / 0.6672 / 2.254 / 6.883 points by realm, times stage. **GIVEN** FX-T, **THEN** its rating is 15.0 (flesh 4.8 + armour 10.2) and its block 0.946. **GIVEN** FX-U, **THEN** 4.4 and 0.278.
- **AC-CD-55** [Logic] Rule 9. **GIVEN** a body shield damaged to half, **WHEN** 30 s pass with no Effect, **THEN** it is still at half. **GIVEN** a standing ward shield damaged the same way, **THEN** it recharges after 2 s.
- **AC-CD-56** [Logic] Rule 9. **GIVEN** a Chaos hit on the thể tu fixture, **THEN** its after-block amount passes the body shield and reaches health. **GIVEN** a body shield authored as not passed by Chaos, **THEN** it soaks the Chaos hit.
- **AC-CD-57** [Config/Data] Formulas B, I. **GIVEN** ward gear and body gear at a ≤ 1, **THEN** each prices at 0.648 W per defence point (±0.01).
- **AC-CD-58** [Harness] Formulas A2. **GIVEN** the fast 0.5 s kit and the slow 3 s kit at equal budget, **THEN** the fast kit's damage per linh lực is within 10 % of 1.26 × the slow kit's against a typical defender, and below the slow kit's against the thể tu and against typical + Iron Shirt.

- **AC-CD-59** [Harness] No shield stall (shields uncapped, user decision 2026-11-08; attackers per re-review CD 4). **GIVEN** the largest legal shield kit at each realm (Mountain Screen and Thousand-Layer Cloud at ws 400 and we 400, plus body gear at a_b 2.0 and Iron Body tier 5) **AGAINST** the realm's typical attacker (FX-T offence) **AND** a slow-hitter variant whose hits come more than 2 s apart, **THEN** it is Down before `time_limit` against both. If it is not, the first fix is a cap knob (`shield_total_cap` or `body_shield_cap`); raising `recharge_delay` or lowering `shield_recharge` is also allowed. Record the value chosen.
- **AC-CD-60** [Logic] Formulas C, drain. **GIVEN** a drain-paid resistance ward on a part with r_eff −0.2, **THEN** its bill is 0. **GIVEN** a part with no positive resistance (R_pos 0), **THEN** the bill is 0 and nothing divides by 0. **GIVEN** a drain-paid block payload of 8 points on a hit whose parts total 5, **THEN** it bills `rate_w` × 5. **GIVEN** a drain-paid evade, status or soul ward, **THEN** compile rejects it.
- **AC-CD-61** [Logic] Formulas C, shared block (re-review CD 3). **GIVEN** a hit whose `B_hit` of 10 points is 4 from flesh and gear and 6 from a drain-paid ward's block, against parts totalling 5, **THEN** the hit loses 5 points of block, the ward's share is 3.0, and it bills `rate_w` × 3.0. **GIVEN** a pool short by half for a drain-paid resistance ward, **THEN** half its prevented damage rejoins the part before block, and block and shields then meet it.
- **AC-CD-62** [Logic] Rule 14, Formulas B (re-review CD 1). **GIVEN** a soul hit that E2 turns into losses of 10 health and 6 linh lực, against a soul shield of s_soul 0.50 and a bar of 6, **THEN** the shield takes 5 from health and 1 from linh lực, the bar is empty, and 5 health and 5 linh lực are lost. **GIVEN** ws 100, **THEN** the bar doubles and s_soul stays 0.50. **GIVEN** a record with s_soul 0.90, **THEN** compile clamps it to 0.75 and warns.
- **AC-CD-63** [Logic] Rule 11 (re-review CD 8, CD 11). **GIVEN** a side whose only ward is Clear Heart Ward (status payload only), **THEN** the default ward still covers every hit part. **GIVEN** a side flagged `no_default_ward`, **THEN** it has no default ward. **GIVEN** a side flagged `cannot_slot_wards` with a ward in its loadout, **THEN** compile rejects the ward and names it.
- **AC-CD-64** [Logic] Rule 19 (re-review CD 21). **GIVEN** `no_heal` and an Effect that refuses the Down step, **THEN** the side stands at 1 health, and nothing counts toward `heal_pulse_cap`.
- **AC-CD-65** [Logic] Formulas G (re-review CD 7). **GIVEN** a side whose only wards are reserved (b = 0), **THEN** ehp is P / λ_all and nothing divides by 0.

**Remaining gaps** (from `qa-lead`, not yet resolved; see Open Questions):
- AC-CD-51 checks presence only. Exact soul defence values by realm need a table (Open Question 12).
- AC-CD-43's figure at we 400 is a model estimate and needs the harness to confirm it (Open Question 11).

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Closed 2026-11-08 (re-review MD 12): modifiers.md's defence rows and prices match Formulas I. Left: the artifact-defence basis note (row 16) | — | Closed |
| 2 | The Combat revision (#43) must replace Combat rule 4's path, rule 22 and all of Formulas D (leaving a stub that cites this GDD's Formulas A0), `ward_art_duration` (A2), Formulas A's ehp and Formulas K's `t_w` and `t_h`, rewrite the ward ACs, and add the back-references the Dependencies table lists (re-review CD 16) | user + systems-designer | Combat revision |
| 3 | The cheap 0.5 s art kit: flat block now makes it a counter-build matchup (Formulas A2). Confirm with the harness (AC-CD-58) before deciding whether the art lint still needs the curved check (overnight decision 3) | systems-designer | Balance harness |
| 4 | The reserved wards in the catalogue (†) were scaled ×1.5 by hand for `reserve_weight` 1.5. Rerun the price check on them once the lint tool exists | systems-designer | Before ward content ships |
| 5 | Healing inside Heavenly Tribulation waves is 0 for now. Revisit once the boss pool and tribulation healing are designed (overnight decision 7) | user | Heavenly Tribulation revision |
| 6 | Settled by Combat Damage Types (#21b): resistance is by damage type, and no element cycle applies in fights | — | Closed 2026-11-07 |
| 7 | Healing and healing taken W prices (0.5) are guesses with no heal-build anchor | systems-designer | First healer reference build |
| 8 | The price check values status and soul payloads coarsely (0.008 · I · T per W). Refine once soul and status reference builds exist | systems-designer | Balance harness |
| 9 | Shields rarely recharge in a duel at a 2 s delay. Confirm with the harness that shield builds still get picked | systems-designer | Balance harness |
| 10 | Closed 2026-11-08: the registry holds these entities. What remains (retire `ward_block`) moved to row 14 | — | Closed |
| 11 | Harness checks: layered shields behind capped resistance (flag ehp above 3 × top-end); stacked reservation; capped resistance plus healing against the realm's typical attacker; a thể tu healer; per-hit wards against tick builds; over-cap from two drain wards against penetration builds; ward strength's value per extra ward; whether reserved wards are still picked; an upkeep ward at we 400 falls before 40 s (AC-CD-43); no shield build stalling a fight now that shields are uncapped (AC-CD-59); block against top-end-sized hits (the thể tu falls to 446 there); the FE–DT n_body and block anchors; ticks now skipping block (about +7 % against typical) | systems-designer | Balance harness |
| 12 | Rule 14 gives every profile a soul defence, but no table of thần thức and soul resistance by realm exists for reference enemies and NPCs. Add one, so AC-CD-51 can check exact values | systems-designer | Before NPC Builds use it |
| 13 | Item DB must adopt the body-gear mapping (0.60 σ_b and 12 block per a_b, top-end body gear 1.0 × B_p) and the block from ward gear capped at a = 1 | user | Item DB revision |
| 14 | Closed 2026-11-08 except one step: retire the registry's `ward_block` and `body_guard_pct` once Combat #43 lands | user | Combat revision (#43) |
| 15 | The Modifier System's Pending rows that cite this GDD (typed block after the shared pool, foe-scoped resistance, a body-shield increased op, recharge delay, cast ward duration, the `[body_shield]` scope) are defined here when they leave Pending; decide then whether a cast ward's duration must stay below its cooldown (re-review CD 12) | systems-designer | When each row leaves Pending |
| 16 | Re-check modifiers.md's "about 0.35 on body gear" artifact-defence note against Formulas B and I's raised body-gear mapping (re-review CD 18) | systems-designer | Modifier System re-review |
| 17 | Reword Formulas E's "continuous model" stall note (37.6 s recomputes to 37.4 s continuous) once the harness has run AC-CD-45 (re-review CD 17) | systems-designer | Balance harness |

# Combat Defence & Healing (Phòng Ngự & Trị Thương)

> **Status**: **Approved 2026-11-10** (combat review, `reviews/combat-review-2026-11-10/`, five headless rounds; round 4 and 5 approved). Revised the same day: resistance in points with no cap or floor, no per-ward resistance maximum, no ward strength or efficiency ceiling, shield wards and Clear Heart Ward re-priced, art costs read the start maximum, Ice on art-slot wards only, Water's gain usable, full heal refund (user decisions). Before that: the Combat economy revision #44 (2026-11-09, `design/research/economy-revision-44-decisions.md`), designed 2026-11-07, reviews 2026-11-08 to 08c; the full history is in `reviews/combat-defence-review-log.md` and the review folders
> **Author**: user + agents
> **Last Updated**: 2026-11-10 (third review round and its decisions: shield and Clear Heart re-price, no ward strength ceiling, start-maximum art costs)
> **Last Verified**: 2026-11-10 (fifth confirming review: **approved**, `reviews/combat-review-2026-11-10/round5/`; its notes applied)
> **Implements Pillar**: Power Is Built, Not Given (3); Every Number Is Bounded and Visible (2); Your Dao, Your Name (1)
> **Parent system**: Combat (#21, `design/gdd/combat.md`). This is sub-system #21a. It owns the whole defence path (evade, resistance, block, wards and body shields, health, soul and status defence) and healing in a fight. Combat keeps offence, the timeline, triggers and results, and is revised afterwards to point here (systems-index design order, user decision 2026-11-07).
> **Scope decisions (user, 2026-11-07)**: all of defence; healing allowed in ordinary fights (since #44 with no cap per pulse and no decay; fatigue ends stalls), none inside Heavenly Tribulation waves for now; the ward is redesigned (Combat Formulas D and rule 22 are replaced); ward models may reserve linh lực.

## Summary

Combat Defence & Healing, a sub-system of Combat, decides what a blow does after it is struck:
evade, then resistance by damage type, then a flat block, then shields from wards and the body, then
health. Wards are spells in free ward slots that grow with realm and thần thức. They layer, carry
resistance, block, shield, evade, status or soul payloads, and are paid by reservation, per hit, drain or cast. Healing works in ordinary
fights at full strength; Combat's fatigue ends fights no side can win, so builds are tested on more than damage.

> **Quick reference** — Layer: `Feature` · Priority: `MVP` · Key deps: `Combat, Character Stats, Modifier System`

## Overview

Combat Defence & Healing decides what happens to a blow after it is struck. Every hit except a soul hit
follows one path:
1. it may be **evaded**;
2. **resistance** cuts a share of it by its damage type (Combat Damage Types, #21b);
3. **block** takes a flat amount off it;
4. **shields** soak what is left: ward shields first, then the body's own shields;
5. what remains reaches **health** (khí huyết).

Ticks meet resistance and the shields that do not let them pass. Soul hits meet only soul resistance and soul wards.
A tick's resistance is that of its damage type, less the source's penetration; both are read when the status is
applied, so a later change does not rewrite it. What reaches health from a tick is dealt exactly, with no floor of 1 (user decision 2026-11-10; a hit part keeps its
floor of 1). Health may rise
again during a fight through regeneration, heal arts and Effects, with no cap per pulse and no fade (user
decision 2026-11-09, #44 items C1, C3); Combat's fatigue ends a fight neither side can win.

The centre of the system is the **ward** (hộ thể). A ward is a spell that sits in a slot. Every
cultivator gets free ward slots, which grow with realm and with thần thức, and every slotted ward is up at
once, so defences can be layered. A ward is what it carries (resistance, block, a shield, evade, status or
soul defence) and how it is paid:
- **reserved**, out of maximum linh lực;
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
   | Tick on linh lực (Qi Disruption) | resistance (all + Force, rule 3) → linh lực, passing every shield. Never evade, never block (Combat Damage Types rule 4) |
   | Soul hit | soul resistance and soul wards → its share of health and linh lực (Combat Formulas E2). Skips everything else |
   | Curse | status resistance (its chance) → applied or not. Curses never deal damage (Combat rule 8) |
   | Fatigue (Combat rule 10) | straight to health: no evade, resistance, block or shield, no Effect changes it; the Down step applies |

   Element stacks that change damage taken (Earth's dampened Physical damage, Metal's Physical damage taken) act on the
   part **before resistance**, like the attacker's layers (user decision 2026-11-10, re-review Q2). They are a separate
   multiplier on the part, `(1 + increased / 100) / (1 + dampened / 100)` (Modifier System rule 6a), and never add to or
   take from R. Thunder's crit damage taken joins the crit layer (Combat Formulas C).

   - Evade is one roll per hit, before anything else (Combat Formulas I, unchanged): an evaded hit deals
     nothing.
   - A hit part that reaches health deals at least 1, as today.
   - Each step and its numbers show in the hit's Breakdown (Combat rule 16).

   This replaces Combat rule 4's "meets the ward, then the body guard", Combat rule 22, rule 23's body
   guard and all of Combat Formulas D. Formulas D's ward strength, ward efficiency and artifact-defence terms
   (`ws`, `we`, `ward_floor`, `a_w`, `a_b`; `ward_cap` retired 2026-11-10) now live in this GDD's Formulas A0; the Combat revision
   (systems-index #43) leaves a stub in Combat D that points here (re-review CD 2).

**Resistance**

2. **Resistance is a defence stat by damage type.** It cuts a share of damage. A side holds:
   - **all resistance**, which applies to every damage type except Soul;
   - **one resistance per damage type**: Physical, Force, Fire, Cold, Lightning, Light and Chaos (Combat
     Damage Types rule 5). Soul keeps soul resistance (rule 14).

   It comes from wards (rule 6), items, techniques, the Way, the tree and other sources. All of them
   are plain modifiers on the resistance stats (Modifier System), and they add.

3. **One resistance per part.** A hit part's resistance is all resistance plus the resistance of its
   **final damage type**, the type it carries after conversion (Combat Damage Types rule 6).
   A tick uses the same sum for its own type (a burn is Fire, a poison Chaos). Elements never enter
   resistance (Combat Damage Types rule 2).

   - **Points, no cap** (user decision 2026-11-10, replacing the 90 % cap and the −50 % floor): resistance is counted
     in **points**, and a part is divided by `(1 + R / 100)`. 100 points stop half, 448 stop 81.75 % (the typical ward
     at Qi Refining), 900 stop 90 %, and no amount stops everything. Each point counts for a little less than the one
     before, so stacking wards always helps but never makes a type harmless.
   - **Negative resistance amplifies:** below 0, a part is multiplied by `(1 + |R| / 100)`, with no limit.

4. **Resistance penetration is the offence answer.** The offence stat resistance penetration (scoped by
   damage type, or by any tag like a damage modifier) lowers the defender's resistance points for that part (there is no cap or floor since 2026-11-10), and
   below 0 it amplifies (rule 3). Realm pierce stays a separate stat that acts on suppression (Combat
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
   - **By realm:** 1 at Qi Refining, 1 at Foundation Establishment, 2 at Core Formation, 3 at Nascent Soul
     and 4 at Deity Transformation (`ward_slots_by_realm`; raised 2026-11-10 so higher realms can stack wards now that
     resistance has no cap).
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
   | **Cleanse** | Each pulse removes `cleanse_share` (0.25 by default, 0.25–0.5) of every debuff batch on its side, oldest batches first when rounding (Effects System rule 9a, Formulas D; owned here, re-review Q5) |
   | **Soul** | Adds soul resistance, and may hold a soul shield that soaks a share of each soul hit's losses from its own bar (rule 14, Formulas B) |
   | **Shield** | A shield bar of its own size, which soaks damage after resistance and block (rule 9) |
   | **Evade** | Adds evade (rule 13) |

   - **Ward strength** scales the ward's own payload numbers: `× (1 + ws / 100)`, so it raises resistance,
     block, shield size, a soul shield's bar and evade granted. It never scales a soul shield's share, and it
     never raises the ward's cost (rule 8).
   - **Ward efficiency** lowers every payment and speeds shield recharge (Formulas).
   - Neither stat touches resistance that comes from items or other sources.
   - Neither has a ceiling (`ward_cap` retired, user decision 2026-11-10): resistance points already count for less
     as they grow, while shields grow in step with ws and drain bills fall toward 0, which the harness watches
     (AC-CD-59). Ward strength keeps its floor of −90 so `1 + ws/100` stays positive.

7. **Activation: standing or cast.**
   - A **standing** ward is up from t = 0 for as long as its payment holds.
   - A **cast** ward is slotted with a cooldown like an art (Combat rule 13). Each time it fires, it pays
     its cast cost and goes up for its authored duration. A shield is refilled when it fires. Before its
     first firing it is **Waiting**, and between firings it is **Expired** (States; re-review CD 22).
   - Before a fight the player may switch any standing ward off, to keep its linh lực for arts. Ward
     expiry keeps Combat rule 10's rule: a ward stays up through the whole millisecond it expires in.

8. **Payment: four models**, set on the ward record (upkeep was removed, user decision 2026-11-09, #44 item C2). Every model is reduced by ward efficiency.

   | Model | Pays | Up while | Character |
   |---|---|---|---|
   | **Reserved** | Holds a share of maximum linh lực for the whole fight (rule 10) | Always, once reserved | Steady and unbreakable by starvation, but less linh lực for arts |
   | **Per hit** | A fixed fee for each hit or tick it meets | It can pay that hit's fee | Its payload applies only to hits it paid for. Beats big hits, strains under many small ones |
   | **Drain** | Linh lực per point of damage its payload prevents, at a rate that **falls with ward strength as fast as the payload rises**, so the bill stays flat while protection grows | Linh lực is above 0 | The classic warding spell. More strength never costs more, which fixes "strength can lose a fight" |
   | **Cast** | The cast ward's cost, paid when it fires (rule 7) | Its duration lasts. A broken shield ends only the shield, not the ward's other payloads (re-review CD 5) | Burst defence on a cooldown |

   - **Per hit** means one fee per hit, covering all of its parts, and one fee per tick.
   - **Drain bills in two steps per hit part.** First, every drain-paid resistance payload (the default ward
     included) is billed together, in proportion to the damage each prevents. If the pool cannot cover the
     total, each pays the same fraction of its own bill (`pay_frac`, Formulas C), and the unpaid share of their prevented damage rejoins
     the part before block. Then block is taken, and every drain-paid block payload is billed together from
     what is left, by the same rule (Formulas C).

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
     poison slips past it. A tick on linh lực passes every shield, whatever its list (Combat Damage Types rule 4). Soul shields are the reverse: passed by everything except Soul (Formulas B).
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
    - The side's usable maximum is `qi_max · (1 − Σ reserved)` at the start. The reserved amount is then fixed in
      points for the fight, so if `qi_max` changes live (Water stacks) usable is the live maximum less those points
      (user decision 2026-11-10). Linh lực starts at that, and art costs,
      regeneration and payments work inside it. Art costs stay a share of the full `qi_max` at the fight's start (Combat
      Formulas E; user decision 2026-11-10: a live rise from Water does not make arts dearer, and a fall does not
      make them cheaper), so heavy reservation means fewer casts.
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
    with no payload that applies to the part (resistance on all or on the part's final type; block, for hits
    only; or a shield the part does not pass, full or broken), such as a status-only or soul-only ward
    (Clear Heart Ward or Soul-Guarding Lamp), does not count as Up for it, so it never costs the side
    its default protection (re-review CD 8). A side flagged `no_default_ward` (rule 5) has none.
    The default ward is: an all resistance of 60 points (`default_resist`, stopping 37.5 %) paid by drain at 0.40 (`default_drain`),
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
    curse may lower). Nothing else limits it: there is no cap per pulse and no decay over the fight (user
    decision 2026-11-09, #44 items C1, C3). A heal art's size scales with `health_units`, and it **refunds the
    linh lực actually paid for it, only when it restores health** (#44 part 2; refined 2026-11-10, re-review Q4: no
    refund at full health or under `no_heal`; user decision 2026-11-10: any health restored refunds all that was paid,
    when the heal lands, after any cast time), because with wards paid in linh lực a heal that drains the pool would
    only hasten the fall (Formulas E). **Leech** (`leech_health_pct`, a plain modifier) is healing too: it takes
    `healing_pct` and healing taken, and is 0 under `no_heal`.

17. **Retired (#44): the heal cap.** Healing has no cap per pulse (user decision 2026-11-09, item C3). Health
    never rises above its maximum, and overheal is lost.

18. **Retired (#44): healing decay.** Healing keeps full strength all fight (user decision 2026-11-09, item C1).
    Combat's fatigue (Combat rule 10) is what ends a fight a healer could otherwise stall.

19. **Where healing never works.**
    - A side that is **Down** cannot be healed. The defeat check is final (Combat rule 10).
    - **A Down refusal is not healing** (user decision 2026-11-08, re-review CD 21). An Effect's refusal at the
      Down step (Effects rule 11), which sets health to 1 instead of letting the side fall, is not a heal: it
      works under `no_heal` and is not counted as healing. A tribulation
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
| Down (unpaid) | Payloads do not apply | A per-hit or drain payment cannot be met | The next payment it can meet |
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
| Modifier System (#40) | in | Resistance (all and per damage type, in points), penetration, block rating, body shield, ward strength and efficiency, reservation efficiency, ward slots, healing, healing taken, health regeneration, evade, soul and status resistance | Modifier System (stats and prices); this GDD (what they do) |
| Effects System (#41) | in | Lifesteal and triggered heals, other reservations, curses that lower healing taken or resistance | Effects System |
| Cultivation Techniques (#9), The Way (#39) | in | Ward spells and heal arts as technique and Way content; resistance and block modifiers | each system |
| Item DB (#13), Artifact Refining (#16) | in | Ward_gear-role artifacts, resistance affixes, body gear | Item DB |
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

**Calibration (pre-#44, kept for history; the #44 note below supersedes its numbers).** The typical defender was tuned to match Combat's old typical ward exactly. Old pass
0.344 at drain 0.956 becomes resistance 0.654 at 0.959 linh lực per point prevented. So the typical
effective health (now 297.8 with block, was 298), the typical mirror (about 7.7 s), the suppression table and
the unbuilt mirror (about 24 s) all carry over at Qi Refining. The thể tu keeps its toughness against
Physical (570 against 575), stays weaker against Force (368.5) and is weakest against Chaos (221.3) (Formulas G).
**#44 note (2026-11-09):** the Combat economy revision moved this calibration on purpose: health ×4, ward
resistance ×1.25 (typical r 0.8175), drain ×0.2. Typical ehp is now 1,376.2 and the typical mirror 30–60 s
(Formulas G; Combat Formulas A2).

### A0. Ward strength, ward efficiency and artifact defence

Moved here from Combat Formulas D (re-review CD 2; the Combat revision #43 leaves a stub there). The values
are unchanged.

`ws = max(ward_floor, defense_pct + Σ ward_strength + 100 · ward_gear_scale · a_w)` ; `we = max(0, ward_efficiency_pct + 100 · ward_gear_scale · a_w)` (no ceiling since 2026-11-10) ; `a_w = Σ (defence of artifacts without the body_gear tag) / (B_p · stage_mult)` ; `a_b = Σ (defence of body_gear-tagged artifacts) / (B_p · stage_mult)`

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| defense_pct | float | ≥ −100 | Modifier System (`defense_pct`, ward strength) | Tree nodes keep their W price |
| ward_strength | float | any | modifiers and Effects naming ward strength | Added flat |
| ward_efficiency_pct | float | ≥ 0 | Modifier System | Lowers payments, speeds recharge |
| ward_gear_scale | float | 0.30 | data file | Artifact defence 0.85 × B_p gives +25.5 to both ws and we |
| a_w | float | ≥ 0 | Item DB | **All non-body artifact defence** (re-review CD 10; the role-tag rename of `ward`/`body` to `ward_gear`/`body_gear` is done, D2, 2026-11-08). Counts in full for ws and we; counts up to 1 for gear block only (Formulas A2, Open Question 13; re-review 2026-11-08b CD-01) |
| a_b | float | 0–1.0 per piece at top end | Item DB | body_gear-tagged artifact defence. One top-end body piece gives 1.0; a_b sums every body_gear-tagged piece, so 2.0 means two top-end pieces (re-review CD 9) |
| ward_floor | float | −90 | data file | ws stays above −90 so `1 + ws/100` stays positive. `ward_cap` (400) is retired: neither stat has a ceiling (user decision 2026-11-10) |

**Anchor:** Combat's typical fixture FX-T sets ws = we = 30.8. With a_w 0.85 the gear term gives 25.5 of that,
so the remaining 5.3 comes from modifiers (derived, not a separate fixture value).

### A. Resistance

The resistance formula is defined as:

`R_j = R_all + R_type(j) − pen_j` (points, no cap) ; `a_j = D_j · 100 / (100 + R_j)` when R_j ≥ 0, and `a_j = D_j · (1 − R_j / 100)` when R_j < 0 ; `R_x = R_x,other + Σ_w R_w,x · (1 + ws/100)` ; the share stopped is `r_j = R_j / (100 + R_j)` when R_j ≥ 0 and `r_j = R_j / 100` (negative) when R_j < 0, so `a_j = D_j · (1 − r_j)` either way

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| D_j | float | ≥ 0 | Combat Formulas C | The part after layers, crit and suppression |
| R_all | float | points, any | Modifier System (`resist_pct`, no scope) | All resistance: every type except Soul |
| R_type(j) | float | points, any | Modifier System (`resist_pct` scoped to a damage type) | Resistance of the part's **final** damage type only (Combat Damage Types rule 6) |
| R_x,other | float | points, any | items, the tree, the Way, techniques, body pieces | Not scaled by ws |
| R_w,x | float | ≥ 0 points (no per-ward maximum since 2026-11-10; the price check bounds it) | ward record | One ward's resistance payload on x (all or a type) |
| ws | float | −90 and up | Formulas A0 | Ward strength, no ceiling |
| pen_j | float | points, ≥ 0 | Modifier System (`resist_pen_pct`, scoped by type or tag) | Subtracted from R; a type scope matches the final type only |
| ~~resist_cap, resist_cap_max, resist_floor~~ | — | retired 2026-11-10 | — | Points have no cap and no floor |
| ~~cap_raise~~ | — | retired 2026-11-10 | — | `resist_cap_pct` is retired with the cap |

**Output Range:** a_j is above 0 for any R (0.1825 · D at the typical 448) and grows without limit as R falls below 0.

**Example:** a Fire part, D 41.3:
- R_all 448 (the Common Ward's 342.5 × 1.308) plus R_Fire 84.2 (items 17.6 + the Flame-Quelling Aura's 66.6) = 532.2,
  stopping 84.2 %, so a = 41.3 × 100 / 632.2 = **6.53**. With penetration 20 points, 6.75.
- The Common Ward alone with penetration 10 points gives R 438 and a = **7.68**.
- FX-T's block of 0.95 then leaves **5.59** and **6.73**.
- A Metal-tagged Physical part ignores R_Fire, so a = 7.54.

**Anchors** (resistance in points, user decision 2026-11-10; the Common Ward is 342.5 points so a typical ward still stops
81.75 % at Qi Refining; every other ward keeps its old stop share at ws 0, R = 100 · r / (1 − r)):

| Realm | Typical ws | Typical R (Common Ward) | Share stopped | Top-end |
|---|---|---|---|---|
| Qi Refining | 30.8 | 448 | 81.75 % | a second ward and modifiers, about 900 (90 %) |
| Foundation Establishment | 37.9 | 472 | 82.5 % | about 1,000 |
| Core Formation | 47.9 | 507 | 83.5 % | about 1,200 |
| Nascent Soul | 62.5 | 557 | 84.8 % | about 1,500 |
| Deity Transformation | 84.1 | 631 | 86.3 % | about 1,900 (95 %) |

Higher realms stop a little less than under the old 90 % cap (accepted by the user); more free ward slots (Formulas D)
let them stack a second or third ward.

**Default ward:** all 60 points (stops 37.5 %) at drain 0.40 (2026-11-10: points; #44: drain ×0.2). Ward strength and efficiency do
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
| a_w, a_b | float | ≥ 0 | Formulas A0 | All non-body_gear artifact defence; body_gear-tagged artifact defence |
| b_src | float | ≥ 0 | body techniques; `block_rating` modifiers | Block rating from other sources |
| b_w | float | 0–100 (`ward_block_max`) | ward record | A ward's block payload, scaled by ws |
| a_j | float | ≥ 0 | A | Each part after resistance |
| k_j | float | 0–a_j | calculated | The part's share of block, split by its size after resistance |

**Output Range:** one hit loses exactly `min(B_hit, Σ a_j)`, however it is split. Block never touches ticks or
Soul. A part reduced to 0 deals nothing; a part that gets past block and shields deals at least 1.

**Why split after resistance:** splitting by D would waste block on parts that resistance has mostly zeroed.
With parts of D 30 Physical (R 0) and D 30 Fire (R 900 points, stopping 90 %) against B 8, splitting by D deals 26.0, and splitting
after resistance deals **25.0**.

**Typical block** is flesh 4.4 × n_body (4.8) plus armour 12 × a (10.2, from the typical artifact defence 0.85),
so 15.0 rating (user decision 2026-11-07). An unbuilt side (no gear, n_body 1.0) keeps 4.4 (the unbuilt mirror's
24.3 s is a pre-#44 figure; Combat Formulas K holds the current one).

| Realm | Typical (rating / points) | Top-end, ward gear | Thể tu | Thể tu + Iron Shirt |
|---|---|---|---|---|
| Qi Refining | 15.0 / 0.95 | ≈ 17 / 1.1 | 88 / 5.6 | 148 / 9.3 |
| Foundation Establishment | 15.7 / 3.2 | ≈ 18 / 3.7 | 95 / 19.3 | 155 / 31.5 |
| Core Formation | 16.4 / 10.9 | ≈ 19 / 12.7 | 100 / 66.7 | 160 / 107 |
| Nascent Soul | 17.7 / 40 | ≈ 21 / 47 | 105 / 237 | 165 / 372 |
| Deity Transformation | 19.2 / 132 | ≈ 23 / 158 | 110 / 757 | 170 / 1,170 |

Typical block took 7.5 / 8.8 / 10.9 / 12.2 / 13.3 % of the standard hit after resistance before #44 (at Qi Refining it is
now about 12.5 %: 0.946 of 7.54; the other realms are re-derived in the harness), close to the
retired body guard's 6.8–12 %. The Foundation Establishment to Deity Transformation n_body values are
estimates until the harness measures them.

**Block against the cheap 0.5 s kit.** The fast art is c 1.2, cost 0.04, D 24.75 (13.8 linh lực per second);
the slow art is c 3.3, 3 s, cost 0.15, D 68.1.

Pre-#44 numbers (r 0.654, full art costs); the harness re-derives them under #44, where the typical r is 0.8175 and art costs are halved.

| Defender | Fast hit dealt | Slow hit dealt | Damage per linh lực, fast / slow |
|---|---|---|---|
| Typical (r 0.654, B 0.95) | 7.62 (−11 %) | 22.62 (−4 %) | 1.10 / 0.87 |
| Thể tu (r 0.60 on Physical, B 5.57) | 4.33 (−56 %) | 21.67 (−20 %) | 0.63 / 0.84 |
| Typical + Iron Shirt (B 5.9) | 2.67 (−69 %) | 17.7 | 0.39 / 0.68 |

The fast kit edges a typical defender (×1.26) and loses to block builds (×0.57 to ×0.75). Block makes it a
counter-build matchup rather than a universal answer, which closes the gap the first draft left open (Open
Question 3).

**Example:** a typical Common Ward hit (#44): 41.3 × 0.1825 = 7.54 after resistance, minus block 0.946 = **6.59**
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
| a_b | float | 0–1.0 per piece at top end | Formulas A0 | body_gear-tagged artifact defence / (B_p · stage_mult). Top-end body gear is 1.0 × B_p, against 5 × B_p for ward gear; 2.0 is two top-end pieces |
| κ | float | 0.04–0.25 | ward record | Cast cost share |
| β | float | 1.0–2.5 | Modifier System Formulas B | The ward's breadth multiplier |
| shield_per_cost | float | 3.81 | price check (1.25 · ε_0 3.05) | Cast shields are sized against their cost: σ ≤ `shield_per_cost` · κ (Golden Light Shield 0.09 ≤ 3.81 × 0.024). Raised from 0.76 with the shield re-price (2026-11-10) |
| shield_recharge, recharge_delay | float | 0.25 per second, 2.0 s | data file | Ward shields only (user decision 2026-11-07: 2 s) |
| shield_total_cap | float or none | none (off); 1.0 if restored | data file | Optional cap on ward shields together, as a share of `health_max` (user decision 2026-11-08: uncapped) |
| body_shield_cap | float or none | none (off); 1.0 if restored | data file | Optional cap on the body shield, as a share of `health_max` |

**Output Range:** no total cap. Each ward shield is at most 0.50 · qi_max · (1 + ws/100), one per ward or art
slot holding a shield ward. The body shield is health_max · Σ σ_b: 0.90 × for the thể tu at Qi Refining, 1.5 ×
at a_b 2.0 with Iron Body tier 3.

- **One body-shield bar.** All body sources share the default pass list (Soul and Chaos pass), so they form one
  bar. A source that authors a different pass list gets a bar of its own.
- **Body shields grow with health.** They are a share of `health_max`, so căn cốt and health % raise them.
- **Restoring a body shield is healing** (user decision 2026-11-07). An Effect that restores it is 0 under
  `no_heal`; like all healing it has no cap and no decay (#44).
- **No body-shield cap** (user decision 2026-11-08). Past σ_b 1.0 (a_b ≥ 1.17 with Iron Body tier 3, or a_b ≥
  0.84 with tier 5), body gear keeps adding shield as well as block. The harness checks that no shield build
  stalls a fight past 60 s against the typical attacker (AC-CD-59); if one does, the first fix is to restore a cap knob.

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

**Example:** Mountain Screen gives **61.0**. The thể tu's body shield is 0.90 × 484.6 = **436.1**.

### C. Payments

The ward_payment formulas are defined as:

`pay_mult = 1 / (1 + we/100)` ;
reserved `= ρ · (1 − min(res_eff, res_eff_cap)/100) / (1 + we/200)` of qi_max ;
per-hit fee `= φ · qi_max · pay_mult` per hit or tick met ;
drain: `rate_w = drain_base / ((1 + ws/100)(1 + we/100))` ; resistance payload `prevented_w = D · max(0, r_eff) · r_w / R_pos`, and 0 when R_pos = 0 ; block payload `prevented_w = blk_w = min(B_hit, Σ a_j) · B_w / B_hit`, its share of the block points the hit lost ; `pay_frac = min(1, pool / Σ_w rate_w · prevented_w)` over the wards billed together in that step (`pay_frac` = 1 when that sum is 0, so nothing divides by 0), and `bill_w = pay_frac · rate_w · prevented_w` ; a short pool's unpaid fraction `(1 − pay_frac)` of a resistance payload's prevented damage is added back to `a_j` before block, and a drain-paid block's unpaid share is simply not taken ; resistance bills are settled before block, block bills after ; drain is invalid for evade, status and soul payloads (the price check rejects them) ; a tick on linh lực bills drain like any part, so a drain ward can make it cost more than no ward when its `drain_base` is above 1 (known weakness, user decision 2026-11-08b CD-04; since #44 the default ward turns a 10-point tick into 6.25 lost plus a 1.5 bill = 7.75, so at default numbers it no longer costs more; the bill is taken first, then the tick lands on what is left) ;
cast `= κ · qi_max · pay_mult` at each firing

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| we | float | ≥ 0 (no ceiling since 2026-11-10) | Formulas A0 (`ward_efficiency_pct` plus the gear term) | Ward efficiency. Counts half on reservation |
| ρ | float | 0.05–0.90 | ward record | Reserved share; all reservations together are capped by `reserve_cap` 0.9 |
| res_eff, res_eff_cap | float | 0–50; 50 | Modifier System (`reserve_eff_pct`); data file | Reservation efficiency, capped so the reservation stack stays bounded |
| φ | float | 0.02–0.20 | ward record | Per-hit fee share |
| drain_base | float | ≥ 1 / (ε_0 · β) | ward record | Price-checked drain rate; ×0.2 with #44 (the Common Ward 1.64 → 0.328) |
| r_eff | float | below 0 up to (never) 1 | calculated (A) | The share the part's final R stops, `r_j` of Formulas A (after penetration); a negative share bills 0 |
| r_w | float | ≥ 0 points | calculated (A) | This ward's scaled payload on the part in points (all, or the part's final damage type) |
| blk_w | float | ≥ 0 | calculated (A2) | This ward's share of the block points the hit actually lost: `min(B_hit, Σ a_j)` split by each source's share of `B_hit` (flesh, gear, other sources and each ward's `B_w`). Block a hit did not need is not billed (user decision 2026-11-08; re-review CD 3) |
| B_w | float | ≥ 0 | A2 | This ward's scaled block points inside `B_hit` |
| R_pos | float | ≥ 0 | calculated | Sum of the part's positive resistance terms before penetration. Billing is split by share and does not depend on ward order (user decision 2026-11-07: bill only what is prevented) |
| κ | float | 0.04–0.25 | ward record | Cast cost share |

**Output Range:** every payment is ≥ 0 (a negative r_eff bills 0, and so does a part with no
positive resistance), reserved is at most 0.9 · qi_max, and a drain bill never exceeds the live pool. The
shortfall leaks through: the unpaid share of a resistance payload's prevented damage rejoins the part before
block, so it meets block and shields like any damage; a drain-paid block that cannot be paid in full takes
only its paid share (re-review CD 3). The other sources keep their own shares; they do not cover the unpaid
part, which moves on to shields.

**Why the bill falls with strength** (points, 2026-11-10). With one drain ward and no penetration, the bill is
D · r_w0 · drain_base / ((1 + we/100) · (100 + R)), so it falls as ws raises R: each point stops less than the one
before while the drain rate falls as 1 / (1 + ws/100). The Common Ward at we 30.8 bills 8.02 at ws 0, 6.47 at
30.8, 4.52 at 100 and 1.96 at 400 (AC-CD-24). Penetration only lowers prevented damage, so it only lowers the bill.
No other model has a ws term. **Total payment never rises with ward strength**, which fixes "strength can lose a
fight", and stronger drain wards are now also cheaper to run.

**Other overnight faults:**
- **Two wards' order:** resistance adds and drain is split by share, so order does not matter. Only
  shields have an order (rule 9). Resistance is summed for the side, not per ward.
- **The cheap 0.5 s art kit** is now a counter-build matchup: flat block punishes many small hits (Formulas
  A2), so the fast kit edges typical defenders and loses to block builds.

**Example** (typical, D 41.3): 41.3 × 0.1825 = 7.54 gets through, and the bill is 33.76 × 0.1917 = **6.47**
linh lực (pre-#44: 25.9). Block 0.946 leaves **6.59** dealt.

### D. Ward slots

The ward_slots formula is defined as:

`ward_slots = ward_slots_by_realm[r] + min(2, floor(divine_sense / (ward_slot_sense_step · ds_ref[r]))) + Σ bonus_ward_slots`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| ward_slots_by_realm | int | 1 / 1 / 2 / 3 / 4 | data file | Raised 2026-11-10 from 1 / 1 / 2 / 2 / 3 (user: more free ward slots at higher realms) |
| divine_sense | float | ≥ 0 | Character Stats Formulas C | The side's thần thức |
| ds_ref[r] | float | 45 / 135 / 450 / 1,350 / 4,500 | Character Stats Formulas C (talent 45, stage 1.00) | Reference thần thức, the same convention as Combat's ref_k |
| ward_slot_sense_step | float | 1.75 (1.5–2.0) | data file | +1 slot at 1.75 × the reference, +2 at 3.5 × |
| bonus_ward_slots | int | ≥ 0 | rare modifier (Modifier System rule 13) | +1 each |

**Output Range:** from 1 at Qi Refining up to 6 plus bonuses at Deity Transformation (4 by realm + 2 from thần thức).

**Example:** talent 45 at peak stage (×1.45) with +25 % thần thức has 81.6 thần thức against a step of 78.75,
so **2 slots** at Qi Refining. +2 needs a soul build, such as talent 60, peak stage and +82 % thần thức. A
step of 1.5 would be too low, because peak stage alone would nearly reach it.

### E. Healing

The healing formulas are defined as:

`heal = base · (1 + healing_pct/100) · (1 + taken_pct/100)` ; heal art `base = U · stage · c_heal · (health_units / 16)`, and the heal art **refunds the linh lực actually paid for it** when it lands and restores any health (rule 16) ; regeneration `base = health_max · (hregen_base + hregen_bonus) · (1 + health_regen_inc_pct/100) / (1 + D_stag/100)` per pulse, with `D_stag` Stagnation's dampened sum (Combat Formulas E, which also owns linh lực regeneration's log curve and `regen_k`) ; heal lint `c_heal ≤ heal_lint_ratio · (basic_coef · (1 + art_coef_per_cost · cost_share) + art_coef_per_cooldown · (cooldown − 1))`

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| U, stage | float | per realm | Combat Formulas A | The healer's fight unit and stage multiplier |
| c_heal | float | ≥ 0 | art record | Heal coefficient, bounded by the heal lint |
| health_units / 16 | float | 4 at the default | Combat Formulas A | Heals grow with health: ×4 health would otherwise make every heal four times weaker (#44) |
| healing_pct | float | 0–200 | Modifier System (`healing_pct`) | The healer's healing |
| taken_pct | float | −100 to +100 | Modifier System (`healing_taken_pct`); curses | The receiver's healing taken |
| hregen_base, hregen_bonus | float | 0; ≥ 0 | data file; Modifier System (`health_regen_pct`), Wood stacks | No innate health regeneration; no cap (`hregen_cap` removed, #44 item C3) |
| heal_lint_ratio | float | 1.4 (was 0.3) | data file | A heal art heals at most 1.4 × the damage coefficient the art lint allows |
| basic_coef, art_coef_per_cost, art_coef_per_cooldown | float | 1.0, 24, 0.25 | Combat Formulas C | The art lint's terms |

**Output Range:** 0 up to the health missing; health never rises above health_max. No cap per pulse and no decay
(#44 items C1, C3). Body-shield restores are 0 under `no_heal` (Formulas B).

**Why 1.4 and the refund.** With wards paid in linh lực, running dry decides a fight: at r 0.8175 a side with no
pool takes about 5.5 times the damage. A heal that costs linh lực makes a healer run dry sooner, so in the #44
simulator (`tools/design/combat_sim/sim.py`) a healer lost every fight to a typical build at any heal size. With
heal arts refunding their cost and heals scaled to health, a ratio of 1.4 gives a healer with the same budget
about 40 % against a typical build (8 of 20 in the simulator, 2026-11-10; it trades damage for healing), and a
healer mirror ends by fatigue at about 66 s (65.8 s).

**Stall check.** Combat's fatigue (Combat rule 10, Formulas A2) ends every fight; a healer mirror falls by about
66 s (65.8 s in the simulator; flat n² fatigue since 2026-11-10; AC-CD-45).

**Example:** a heal art at cost 0.075 and cooldown 3 s:
- The lint gives 3.3, so c_heal ≤ 4.62, which heals 6.31 × 4.62 × 4 = **116.6** (26.5 % of FX-T's health), at
  any time in the fight.
- It refunds the **12.96** linh lực paid, when it restores health.

### F. Ward price check

The ward_price formula is defined as:

`V_w ≤ ε_0 · β_w · α_m · C_w`, evaluated at ws = we = 0 for a bare defender, over the **standard stream** (one hit of size I per second) for `T_ref` = 45 s (#44 item A5; was 8 s)

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| V_w | float | ≥ 0 | calculated | Health points prevented by the payloads. **Resistance:** s · I · T, with s = R / (100 + R) the ward's stop share at ws 0, assuming every part matches its scope. **Shield:** σQ once if standing, min(σQ, I · duration) per firing if cast. **Block:** min(B_w, I) · T. **Evade:** e · I · T. **T** is `T_ref` for a standing ward. For a cast ward, resistance, block and evade use its up time inside `T_ref` instead: `T_up = floor(T_ref / cooldown) × duration`, so r · I · T_up, min(B_w, I) · T_up and e · I · T_up (re-review CD 19, 2026-11-08b CD-02; Black Tortoise Shell: 0.4125 × 36.5 × 18 s = 271.0, ratio 4.711 at its 2026-11-10 cast cost 0.037). A cast ward's first firing is at t = cooldown (combat.md line 126), so firings in `T_ref` number `floor(T_ref / cooldown)`. A cast shield's V is that count times its per-firing value. A firing exactly at `T_ref` counts in both V and C. A block payload paid per hit balances itself, since both are sensitive to hit count in opposite directions. **Status and soul:** 0.008 · I · T per W of their stat price |
| C_w | float | > 0 | calculated | Linh lực paid. **Reserved:** ρQ · `reserve_weight`. **Per hit:** `T_ref` · φQ (one hit a second). **Drain:** drain_base · V. **Cast:** κQ · floor(T_ref / cooldown) |
| reserve_weight | float | 1.5 | data file | User decision 2026-11-07: stronger auras. Each reserved point counts 1.5 paid points, since it is held all fight |
| ε_0 | float | 3.05 (was 0.61) | data file, anchored to the Common Ward (1 / 0.328) | Prevented points per linh lực point; ×5 with the drain cut (#44) |
| β_w | float | 1.0 / 1.25 / 1.5 / 2.0 / 2.5 | Modifier System Formulas B | Narrower scopes buy more |
| α_m | float | drain 1.0, reserved 1.0, per hit 1.0, cast 1.25 | data file | A cast ward is Waiting until its first firing and Expired between firings |
| I, T_ref | float | Qi Refining 36.5 per second; 45 s | Combat Formulas K typical offence; the typical mirror (#44: 30–60 s) | Per realm from the anchors |
| σ max | float | 0.50 | data file | Largest shield one ward may carry. `ward_resist_max` is retired (user decision 2026-11-10): a ward's resistance is bounded only by this price check |

**Output Range:** a pass or fail lint; the margin is V / (ε_0 · β · α · C).

**How the payments trade off.** All payments are equal against the standard stream. Away from it, each
wins somewhere different:
- **Per hit** is 3 × better against one 3I hit every 3 s, and 4 × worse against three small hits plus a
  tick per second.
- **Drain** is best in short fights.
- **Reserved** is best in long fights and against strong attackers, because its cost does not grow with
  incoming damage, but it takes the casting budget.

No ward can be cheap and universal, because universal means β = 1.

**Shields after #44** (re-priced 2026-11-10, user decision). A shield's value does not grow with `T_ref`, while ε_0
rose ×5, so the old payments left every shield ward far under the bar (Mountain Screen 0.600 against 3.05). Their
payments are cut to pass at the bar (Mountain Screen reserved 0.30 → 0.060, Thousand-Layer Cloud 0.20 → 0.044, Golden
Light Shield cast 0.12 → 0.024, Black Tortoise Shell cast 0.15 → 0.037), and `shield_per_cost` rises ×5 by its
formula to 3.81. The check counts a standing shield once, with no recharge, so it errs toward generous; the harness
confirms (AC-CD-59).

**Stacking** (user decision 2026-11-10). The check values each ward alone. A side's first ward replaces the default
ward, so the lone price is exact for it; every later ward adds points on top, and points count for less as they grow
(rule 3), so a second ward is worth less than its price. That is intended: it is the cost of having no resistance
cap. The flat per-point prices in Formulas I (`resist_pct` 0.04 W, penetration 0.1 W) are set at the typical 448
points and carry the same bias, also intended.

**Example:** Golden Bell (per hit 0.035, r 0.50): V = 0.50 × 36.5 × 45 = 821.2, C = 45 × 0.035 × 172.74 = 272.1, ratio
3.019 ≤ 3.05, so it **passes**.

### G. Effective health

The ehp formula is defined as:

`x = Q_use / b`, and the wards never fall when b = 0 (only reserved wards and other sources), so then `ehp = P / λ_all` (re-review CD 7) ; `λ_s = max(λ_min, 1 − r_s − B_s / D_ref)` for s ∈ {all, fix} ; `P = H + S_std + S_body`, leaving out any shield the damage type passes ; `ehp = P / λ_all` if `x · λ_all ≥ P`, else `x + (P − x · λ_all) / λ_fix`

**Variables:**

| Variable | Type | Range | Source | Description |
|---|---|---|---|---|
| H | float | ≥ 1 | Combat Formulas A | Health at the start |
| Q_use | float | ≥ 0 | qi_max · (1 − Σ reserved) at the start; then live qi_max less the reserved points (rule 10) | Usable linh lực |
| b | float | ≥ 0 | C: Σ drain rate_w · r_w + per-hit φQ / D_ref, plus `rate_w · B_w / D_ref` for drain-paid block payloads | Linh lực paid per incoming point |
| r_all, r_fix | float | share stopped, `r_j` of Formulas A: R / (100 + R) up to (never) 1, or R / 100 below 0 | A | Resistance with every ward up; with only reserved wards and other sources |
| B_all, B_fix | float | ≥ 0 | A2 | All block; body block plus reserved-ward block |
| D_ref | float | I · 1 s | the standard stream | In Combat Formulas K, use the attacker's mean hit size D̄ |
| λ_min | float | 0.02 | data file | Keeps ehp finite when block exceeds the hit |
| S_std, S_body | float | ≥ 0 | B | Standing ward shields (one fill) and the body shield |

**Output Range:** ehp has no lower bound above 0: negative resistance has no floor, so ehp falls toward 0 as R falls (P / 2 at R −100, no block); the top is 50 × P.

**Example (typical, #44):** b = 0.1917 × 0.8175 = 0.1567, so x = 172.74 / 0.1567 = 1,102.2; λ_all = 0.1825 −
0.946 / 36.5 = 0.1566; health lost while the ward holds is 172.6; then (439.48 − 172.6) / 0.9741 = 273.9, so
ehp = **1,376.2** (pre-#44 297.8). One point healed is worth 1 / λ = 6.39 incoming points while the ward holds.

**The thể tu at Qi Refining:** block 88.3 rating (flesh 5.3 + gear 12 + Iron Body tier 3 30 + 41 from W), so
B 5.57; body shield 436.1 (σ_b 0.90 = technique 0.30 + gear 0.60); Physical resistance 36.1 points (Iron Body tier 3
25 points + Black Iron Armour's Physical affix 11.1 points); health 484.6 (#44: ×4),
linh lực 164.1, the default ward only (all 60 points, drain 0.40). (**Reachability, 2026-11-10:** Iron Body tier 3 needs a Profound body technique at great completion, Core Formation at the earliest (Cultivation Techniques rule 2, `iron_tier`); at Qi Refining a body technique reaches tier 1. This fixture stays as a formula test, not a reachable build; the worked example moves to Core Formation with the harness re-fit of the thể tu's W shares, user decision 2026-11-10, techniques re-review D-3.)

| ehp against | Pre-#44 | Now (#44) |
|---|---|---|
| Physical | 570.4 | **2,098.8** (points, 2026-11-10) |
| Force | 368.5 | **1,570.7** |
| Chaos (passes the body shield) | 221.3 | **1,025.8** |
| Physical, top-end-sized hits | 446 | re-derive with the harness (block is small against big hits) |

**For Combat Formulas K** (Combat revision, systems-index #43):
- `t_w = Q_use / (D · b_drain + n_hits · fee + net_spend)`. This fixes the overnight fault that `t_w` had no term
  for per-hit wards (upkeep wards were removed with #44).
- `t_h = (S / λ_all + (H + heal(T0)) / λ_all) / D`, using D̄; healing no longer decays, and fatigue caps T0
  (Combat Formulas K).
- Combat Formulas C's `dealt_j`, Formulas F's tick factor and Formulas K's f are replaced by this GDD's path.
- Healing stays out of `display_power`'s ehp.

### H. Starter ward catalogue and body pieces

**Wards.** Values are at Qi Refining with ws = we = 0. **Check** is the price-check ratio against its limit, at `T_ref`
45 s and ε_0 3.05 (#44: resistance payloads ×1.25, drain ×0.2; reserved, per-hit and cast resistance wards re-priced
to keep their pre-#44 margins; shield wards and Clear Heart Ward re-priced 2026-11-10, Formulas F).

| Ward | Payload | Payment, activation | Check | Wanted by |
|---|---|---|---|---|
| Common Ward (Hộ Thể Chân Khí) | all 342.5 points | drain 0.328, standing | 3.049 / 3.050 | Everyone; the typical anchor |
| Fire-Shunning Veil (Tị Hỏa Sa) | Fire 300 points | drain 0.22, standing | 4.545 / 4.575 | Anyone facing Fire foes or a Fire sect |
| Qi-Scattering Robe (Tán Khí Bào) | Force 220 points | drain 0.264, standing | 3.788 / 3.813 | Thể tu covering their Force weakness with idle linh lực |
| Flame-Quelling Aura (Trấn Hỏa Quang) | Fire 50.9 points | reserved 0.49 | 4.366 / 4.575 | The sword cultivator under a Fire aura |
| Still Lake Aura (Tĩnh Hồ Quang) | all 50.9 points | reserved 0.71 | 3.013 / 3.050 | Long fights, tribulation, art-light builds |
| Golden Bell (Kim Chung Tráo) | all 100 points | per hit 0.035, standing | 3.019 / 3.050 | Boss fighters, anyone facing slow heavy hits |
| Surging Tide (Triều Thủy Tráo) | all 60 points | per hit 0.027, standing (was upkeep) | 2.935 / 3.050 | A lighter bell for builds that take few, heavy hits |
| Mountain Screen (Sơn Hà Bình Chướng) | shield σ 0.27 | reserved 0.060, standing (was 0.30) | 3.000 / 3.050 | Formation masters; fights against slow hitters |
| Thousand-Layer Cloud (Thiên Tầng Vân) | shield σ 0.20 | reserved 0.044, standing (was 0.20) | 3.031 / 3.050 | Layered-shield builds |
| Golden Light Shield (Kim Quang Thuẫn) | shield σ 0.09 | cast 0.024, cooldown 4 s, up 3 s (was 0.12) | 3.750 / 3.813 | Art-speed builds, talisman users |
| Black Tortoise Shell (Huyền Quy Giáp) | Physical 70.2 points | cast 0.037, cooldown 5 s, up 2 s (was 0.15) | 4.711 / 4.766 | Builds facing sword and fist cultivators |
| Clear Heart Ward (Thanh Tâm Chú) | status +37.5 pp, cleanse 0.25 of every debuff batch per pulse | reserved 0.25 (was 0.23) | 3.043 / 3.050 (status payload; the cleanse rides free) | Anti-curse, anti-poison |
| Soul-Guarding Lamp (Hộ Hồn Đăng) | soul res +22.5 pp; optional soul shield, s_soul 0.50 on a bar of σ_soul 0.10 (G) | reserved 0.20 | † | Anyone facing soul builds |
| Iron Shirt (Thiết Bố Sam) | block 60 (3.79 at QR), evade +12 pp | reserved 0.47 | 3.019 / 3.050 | Thể tu and light-body hybrids; block adds linearly, so a thể tu gains about +60 % block (user decision 2026-11-07: accepted) |

† scaled ×1.5 by hand for `reserve_weight` 1.5; rerun the price check when the lint tool exists.

**Body pieces.** These are priced in W through the Modifier System, not by the ward price check.

| Piece | Grants | Value |
|---|---|---|
| Iron Body Art (Thiết Thân Công), tier t of 1–5 | per tier: block +10, σ_b +0.10, Physical resistance +8.3 points. Tier 3: 30 / 0.30 / 25 points | about 9.4 W per tier (2026-11-10: health and body shield re-priced, resistance in points) |
| Black Iron Armour (Ô Thiết Giáp), body_gear-tagged artifact | at a_b 1.0 (top end): block 12, σ_b 0.60; may carry a Physical-resistance affix | about 35 W (2026-11-10; parity with ward gear dropped, re-review Q8) |
| Căn cốt, per talent point | +2.22 % health, and so +2.22 % on the body shield; +0.1 block rating; no shield of its own | about 2.4 W to a thể tu, against its 3.0 price |

### I. W prices for the new defence stats

These belong in the Modifier System's Stat List and price table, which was rebuilt for this GDD on 2026-11-07; Open Question 1 checks them against it. **D**
marks a derived price, **G** a guess.

| Stat | Key | W per unit | | Basis |
|---|---|---|---|---|
| All resistance | `resist_pct`, no scope (universal ×1.0) | 0.04 / point | D | 2026-11-10, points: +1 point at the typical 448 cuts damage taken by about 0.18 %; about 30 points match the old +1 pp |
| Physical, Force resistance | `resist_pct` scoped (broad ×1.25) | 0.032 / point effective | D | The old body and qi kinds, carried over by migration |
| Fire, Cold, Lightning, Light, Chaos resistance | `resist_pct` scoped (family ×1.5) | 0.027 / point effective | D | Chaos stays family, but only rare sources may carry it (content rule) |
| ~~Resistance cap raise~~ | `resist_cap_pct` | retired 2026-11-10 | — | No cap to raise |
| Resistance penetration | `resist_pen_pct`, scoped by type or tag | 0.1 / point | D | 3.6 against a typical warded defender, 1.4 against the default ward |
| Block | `block_rating` | 0.4 / rating point | D | 0.41 to a thể tu, 0.22 to a typical side. Universal; grid 1 |
| Body shield | `body_shield_pct` (pp of health_max) | 0.51 / pp | D/G | Pegged to health's 0.6 × 0.85 (was 1.2 × 0.85 = 1.0; health re-priced 2026-11-10). Chaos passes it and it never refills |
| Health regeneration | `health_regen_pct` | 9.9 / pp per pulse | D | #44 simulator, 45 s fights, no decay (Modifier System) |
| Healing | `healing_pct` | 0.5 / % | G | No heal-build anchor exists yet |
| Healing taken | `healing_taken_pct` | 0.5 / % | G | Also counters curses |
| Ward slots | `bonus_ward_slots` | 30 / slot, rare | D/G | A first ward is about +77 % ehp over the default; a second about +25–35 % |
| Reservation efficiency | `reserve_eff_pct` | 0.8 / % (cap 50) | D | At a 50 % total reservation; 3.4 at 80 % |
| Body guard | `body_guard_pct` | **retired** (was 0.8) | — | Replaced by block and the body shield |
| Artifact defence | Item DB | about 0.648 per defence point on ward and body gear alike | D | Body gear's mapping was raised to match (user decision 2026-11-07) |

## Edge Cases

> `systems-designer` not consulted for this section — Lean mode. Review manually before production.

**Resistance**
- **If penetration is larger than resistance**: R goes below 0 and the part is amplified (Formulas A); there is no cap
  for penetration to work against.
- **If resistance is very high**: there is no cap; 900 points stop 90 %, 1,900 stop 95 %, and each point adds less.
- **If resistance falls below 0**: the part is amplified by `(1 + |R| / 100)`, with no limit (Sundered and Exposed can do this).
- **If soul resistance falls below 0** (Slackened Soul): it has no floor, and below 0 it amplifies the soul hit
  through `rho` (Combat Formulas E2; user decision 2026-11-10). Soul resistance is counted in pp and read like
  points: ÷ (1 + x/100) above 0, × (1 + |x|/100) below.
- **If a part was converted**: only its final damage type counts for resistance, block and penetration;
  earlier types count for offence modifiers only (Combat Damage Types rule 6). Elements never enter
  resistance.
- **If the damage is tribulation lightning**: it is Lightning, so all resistance and Lightning resistance apply
  (Heavenly Tribulation).

**Wards and payment**
- **If linh lực reaches 0**: drain and per-hit wards are down and so is the default ward. Reserved
  wards stay up, since they are already paid. A cast ward stays up until its duration ends; a broken shield
  ends only the shield.
- **If a per-hit ward cannot pay a hit's fee**: its payload does not apply to that hit. The next hit pays if it
  can. An evaded hit charges no fee, because evade comes first.
- **If a drain bill is larger than the live pool**: the pool pays what it can, and the unpaid share of the
  prevented damage leaks through.
- **If a cast ward fires while it is already up**: its duration restarts and its shield refills to its
  maximum. Firings never stack two copies.
- **If the same ward id is slotted twice**: rejected at compile. A ward is slotted at most once per side.
- **If a ward sits in an ordinary art slot**: it counts toward `slot_count` (Combat Formulas A2) and gives up
  that art. It is an art for cost changes: Ice stacks and other art-cost raises reach its cast cost; a ward in a
  ward slot keeps its own payment (user decision 2026-11-10). Only a cast is an art's cost, so a reserved, per-hit
  or drain payment is unchanged by Ice wherever the ward sits.
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
  is 0 under `no_heal`.
- **If the body shield sources pass 1.0 × health_max**: nothing is clipped, because shields are uncapped
  (user decision 2026-11-08). If the `body_shield_cap` knob is set, the bar is clipped to it at compile.
- **If a shield soaks part of a hit**: its `recharge_delay` restarts from that millisecond, whether the shield
  is broken or not.
- **If the `shield_total_cap` knob is set and ward shields would pass it**: the maximum sizes are clipped at
  compile, later slots first, so a refiring cast shield never exceeds its clipped maximum. Off by default.
- **If a tick arrives**: by default it passes ward shields and meets the body shield (rule 9), unless its type passes that too
  (a poison is Chaos). Ticks never meet block. A tick on linh lực passes every shield and comes off linh lực after
  resistance. A drain-paid ward bills it like any part (Formulas C, known weakness). **If a soul hit arrives**: only soul shields meet it.
- **If the side is a boss**: `qi_max` and `health_max` already include `boss_pool_mult`, so shield sizes (and
  any cap knob that is set) scale with it.

**Healing**
- **If a heal lands on a side at full health**: nothing is restored, and a heal art refunds nothing.
- **If Water stacks change maximum linh lực mid-fight** (re-review Q3): the pool's maximum, and so its regeneration and
  cap, change live; reservations and ward shield sizes stay as compiled at the start; a pool above a falling maximum
  is clipped to it. Reservations are fixed amounts in points, so usable linh lực is the live maximum less the reserved
  points, and every point Water adds is usable (user decision 2026-11-10). If the live maximum falls below the
  reserved points, usable linh lực is 0 (never negative). Art costs keep reading the start maximum (rule 10).
- **If heals in one pulse window are large**: they all apply in the order they occur; there is no cap (#44).
- **If a heal and lethal damage land in the same instant**: all of the instant's events resolve, heals
  included, before the defeat check (Combat rule 10). A heal can keep a side standing only if it lands
  inside that instant.
- **If a side is Down**: it cannot be healed. The defeat check is final.
- **If an Effect refuses the Down step** (Effects rule 11): health is set to 1, which is not a heal. It
  works under `no_heal` and is not counted as healing (re-review CD 21).
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
| Combat (#21) | Hard, parent | Timeline, pulses, instants, offence (layers, crit, suppression), tags and conversion, the defeat check, results, the art lint, the evade formula | GDD approved for rules | Yes (since the Combat revision #43). History: the revision replaced rule 4's path, rule 22, rule 23's body guard and all of Formulas D (leaving a stub that cites Formulas A0), updates rule 24 and E2 for soul wards, removes `ward_art_duration` from A2, and updates Formulas A's ehp and Formulas K |
| Character Stats (#7) | Hard | Maximum health and linh lực, thần thức and `ds_ref`, căn cốt, the stat sheet sums | In review | Not yet: add the new defence keys to Parameter keys |
| Modifier System (#40) | Hard | The defence and healing stats, their W prices, breadth, scope matching | Approved 2026-11-08b; revised for #44 2026-11-09/10 | Yes: its Stat List carries the defence stats, its rule 7 leaves the bounds here, and its Cross-References cite rules 2–4, 6, 7, 9–12 and Formulas A–E, I |
| Combat Damage Types (#21b) | Hard | The damage types that resistance is keyed on, conversion, and what passes each shield | Approved 2026-11-08c; revised 2026-11-10 (points) | Yes: rules 4, 5 and 7 and its Cross-References |
| Effects System (#41) | Soft | Lifesteal, triggered heals, other reservations, curses on resistance and healing taken | Approved 2026-11-08c; revised for #44 2026-11-09/10 | Yes: rule 6 (restores and reservation) and its Cross-References |
| Heavenly Tribulation (#22) | Soft | Sets `no_heal` on every wave; tribulation lightning is Lightning | Approved for rules | Yes (Dependencies note, Combat revision #43; its rule 7 should still cite `no_heal`) |
| Realms (#8) | Soft | The realm, for free ward slots by realm (Formulas D) | In review | Yes (Dependencies note, Combat revision #43) |
| Quests (#31) | Soft | Reads effective health (Formulas G) through Combat's fight power F | In review | Yes (Dependencies note, Combat revision #43) |
| Cultivation Techniques (#9), The Way (#39) | Soft | Ward spells and heal arts as content | In review; approved | Not yet |
| Item DB (#13), Artifact Refining (#16) | Soft | Ward_gear-role artifacts, resistance affixes, body gear | Approved; built | Not yet |
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
| Heal | A green number | Gentle bloom |
| Default ward takes over | The ward row shows "default" | None |

## Game Feel

- **The ward should feel like a choice.** Before a fight, picking three wards for three slots should
  read like slotting arts: which threats will I meet, and what can I afford? The pre-fight preview
  shows the expected cut per damage type.
- **Breaking a shield is a moment.** A shield that breaks is a beat in the fight log. A build that times its
  burst past a shield should feel it land.
- **Healing should feel urgent, not endless.** Early heals are strong. Heals keep full strength; fatigue from 60 s is what presses a healer, so a healer
  feels pressure to finish the fight rather than outlast it.
- **Reservation should feel like a trade.** The linh lực bar shows the reserved share as a locked segment,
  so the player sees what an aura costs in casts.
- **Response target:** every defence step appears in the hit's Breakdown in the same log line as the hit. No
  defence result is hidden or delayed.

## UI Requirements

- **Bars per side:** health; the body shield as its own bar over health; one bar per ward shield, stacked in
  slot order, or one segmented bar; linh lực with the reserved share drawn as a locked segment.
- **Ward row:** one icon per slotted ward, showing state (waiting, up, down, broken, expired, off), a duration ring for
  cast wards and a recharge indicator for standing shields. The default ward shows when it is the one up.
- **Resistance panel** (sheet and pre-fight preview): all resistance and each damage type's resistance in points with the
  share each stops, block rating and points,
  and the share from wards against other sources.
- **Breakdown line per hit:** evade → resistance (all + type, in points) → block → each ward shield → the
  body shield → health,
  plus the drain or fee paid.
- **Heal lines:** amount, healing and healing taken, and the linh lực a heal art refunds.
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
| Rule 17 | combat.md Formulas F | `dot_pool_cap`, `dot_pulse_cap` | Retired with `heal_pulse_cap` (#44 item C3) |
| Formulas A–C | combat.md Formulas A–D anchors | Health 439.5 (#44; was 109.9), linh lực 172.7, D 41.3, ws = we = 30.8 | Calibration source |
| Formulas D | character-stats.md Formulas C | Reference thần thức by realm | Read |
| Formulas E | combat.md Formulas C | The art lint's terms | Read |
| Formulas F, I | modifiers.md Formulas A–C | W, breadth multipliers, the value formula | Read |
| Formulas G | combat.md Formulas A, K | ehp, `t_w`, `t_h` | Replaced (ehp); proposed for K |
| Formulas B, I | item-database.md (artifact defence a_w, a_b) | Body gear mapping 0.60 σ_b and 12 block per a_b; top-end body gear 1.0 × B_p | Proposed change to Item DB |
| Formulas A0 | combat.md Formulas D | `ws`, `we`, `ward_floor`, `a_w`, `a_b`, `ward_gear_scale` (`ward_cap` retired 2026-11-10) | Moved here; Combat keeps a stub after #43 |
| Rules 5, 6, 10, 11, 19, Edge Cases | effects.md rules 5, 6, 11; No Ward | Reservation by Effects; restores; live changes; the Down step; `cannot_slot_wards`, `no_default_ward` | Read |
| Rules 5, 10, 16 | modifiers.md rule 13 | Rare modifiers (ward slots) | Read |

## Tuning Knobs

All live in the data file. Added 2026-11-08 from the formula tables; no value changed. The safe ranges are
design estimates until the balance harness confirms them.

| Knob | Default | Safe range | What it tunes | Source |
|---|---|---|---|---|
| ~~`resist_cap`, `resist_cap_max`, `resist_floor`~~ | retired 2026-11-10 | — | Resistance is counted in points with no cap or floor | A, rule 3 |
| `default_resist`, `default_drain` | 60 points, 0.40 | 40–90 points; 0.30–0.50 | The free default ward (stops 37.5 % at 60 points) | A, rule 11 |
| `block_unit[r]` | 0.0631 / 0.2031 / 0.6672 / 2.254 / 6.883 | derived; rederive if Combat's U or M changes | Block's share of a typical hit at every realm | A2 |
| `flesh_block`, `gear_block` | 4.4; 12 per a | 3.5–5.5; 10–14 | Unbuilt block; gear block | A2 |
| `body_gear_shield` | 0.60 per a_b | 0.50–0.70 | Body gear's shield (price parity with ward gear) | B |
| `shield_recharge`, `recharge_delay` | 0.25 / s, 2.0 s | 0.15–0.35; 1.5–3.0 | How fast standing ward shields come back | B |
| `shield_total_cap`, `body_shield_cap` | none (off) | none, or 1.0–2.0 | Optional shield caps, the fix if AC-CD-59 finds a stall | B |
| `reserve_cap`, `res_eff_cap` | 0.9; 50 | 0.8–0.9; 40–60 | Most linh lực reservable; reservation efficiency's ceiling | C, rule 10 |
| `reserve_weight` | 1.5 | 1.25–1.75 | Aura strength per reserved point (price check) | F |
| `ε_0`, `shield_per_cost` | 3.05, 3.81 | anchored; move only with the Common Ward (`shield_per_cost` = 1.25 · ε_0) | Ward price check's yardstick | F |
| `ward_slots_by_realm`, `ward_slot_sense_step` | 1/1/2/3/4; 1.75 | as set; 1.5–2.0 | Free ward slots, and the thần thức bonus | D |
| `heal_lint_ratio` | 1.4 | 1.2–1.6 | Heal art strength against the damage lint (#44 simulator) | E |
| `λ_min` | 0.02 | 0.01–0.05 | Keeps ehp finite | G |
| ~~`ward_resist_max`~~; σ max | retired 2026-11-10; 0.50 | —; 0.40–0.60 | No per-ward resistance maximum (the price check bounds it); largest shield one ward may carry | F |
| `cleanse_share` | 0.25 | 0.25–0.5 | Share of every debuff batch a cleansing ward removes each pulse | Rule 6 |
| `ward_block_max` | 100 | 80–120 | Largest block payload on one ward | A2, F |
| ~~`ward_cap`~~, `ward_floor` | retired 2026-11-10; −90 | —; fixed | No ceiling on ward strength or efficiency; floor on ward strength | A0 |
| `ward_gear_scale` | 0.30 | 0.25–0.35 | Ward strength and efficiency from artifact defence | A0 |
| α_m | drain 1.0, reserved 1.0, per hit 1.0, cast 1.25 | ±0.10 each | How the price check rates each payment model | F |
| `T_ref` | 45 s | 30–60 s | Length of the price check's standard stream (#44) | F |
| `soul_shield_share_max` | 0.75 | 0.50–0.90 | Most of a soul hit's loss a soul shield can take | B, rule 14 |

## Acceptance Criteria

> Drafted by `qa-lead` 2026-11-07. Every fixture value was recomputed from the formulas, and the two
> inconsistent worked examples it found are fixed in Formulas A and C.

**Fixtures and conventions**
- **FX-T** is Combat's typical fixture: health 439.48, linh lực 172.74, ws = we = 30.8, block rating 15.0
  (0.946 points), no body shield, U 6.31, stage 1.00.
- **FX-U** is Combat's unbuilt fixture, with block rating 4.4 (0.278 points).
- **Thể tu fixture:** Formulas G's Qi Refining thể tu: block 88.3 (5.57 points), body shield 436.1, R_all 60 points
  (default ward, stopping 37.5 %) and R_Physical 36.1 points (so Physical 96.1 points, stopping 49 %; Fire and Chaos 60, stopping
  37.5 %), health 484.6, linh lực 164.1. A formula fixture: tier 3 is not reachable at Qi Refining (Formulas G note).
- **Common Ward:** all 342.5 points, drain 0.328.
- **FX-H:** FX-U carrying one heal art at the heal lint's maximum and no damage arts.
- **Tolerance:** ±0.1 unless a criterion says otherwise.
- **Test locations:** [Logic] tests go in `tests/unit/combat_defence/`, [Integration] tests in
  `tests/integration/combat_defence/`. **[Harness]** means the check runs in `tools/balance/autoplay.gd`, not
  in a unit test.

**Defence path (Rules 1, 12, 13, 15)**

- **AC-CD-01** [Logic] Rule 1. **GIVEN** a Physical hit part on FX-T with a ward shield, a body shield and the Common Ward, **WHEN** it resolves, **THEN** its Breakdown lists evade → resistance → block → ward shields → body shield → health in that order, and nothing reaches health while a shield it meets still holds.
- **AC-CD-02** [Logic] Rule 1. **GIVEN** an over-time tick on a side with a full ward shield and a full body shield, **WHEN** it resolves, **THEN** no evade roll and no block are logged and the ward shield is unchanged. **GIVEN** a Fire tick, **THEN** the body shield soaks it. **GIVEN** a poison (Chaos) tick, **THEN** it passes the body shield.
- **AC-CD-03** [Logic] Rules 1, 14. **GIVEN** a soul hit on a side with all resistance 300 points, a full ward shield, block 5.6 and a full body shield of 436.1, **WHEN** it resolves, **THEN** only soul resistance and soul wards change the result, and the ward shield, block and body shield are untouched.
- **AC-CD-04** [Logic] Rules 1, 15. **GIVEN** a curse with chance 1.0 against status resistance 0.375 (status resistance stays a share of the chance, not points, and counts against guaranteed statuses too, user decision 2026-11-10), **WHEN** it resolves, **THEN** its apply chance is 0.625 and health is unchanged either way. **GIVEN** a tick of 10 with status resistance 0.9, resistance 0 (the side is flagged `no_default_ward`, since the default ward would add 60 points) and no shields, **THEN** 10 reaches health.
- **AC-CD-05** [Logic] Rule 1. **GIVEN** an evaded hit, **THEN** no resistance, block, shield, per-hit fee, drain bill or health loss is logged. **GIVEN** a part of D 1.2 at R 900 points (stops 90 %) and block 0, **THEN** 1 reaches health (the hit floor; 0.12 before it). **GIVEN** the same part on FX-T, **THEN** block takes it to 0 and it deals 0, logged "blocked".
- **AC-CD-06** [Logic] Rule 12. **GIVEN** FX-T at linh lực 0 with no ward up, **WHEN** a Physical hit of D 41.3 lands, **THEN** block still applies and 40.35 is dealt. **GIVEN** a body shield of σ_b 0.30 (131.8), **THEN** the shield takes the 40.35 and 0 is dealt, leaving 91.5.
- **AC-CD-07** [Logic] Rule 13. **GIVEN** evade 0.30 plus an evade payload of +9 pp and a +30 fortune lead, **WHEN** the roll is inspected, **THEN** it is clamped at 0.40, and ticks and soul hits never roll evade.

**Resistance (Rules 2–4, Formulas A)**

- **AC-CD-08** [Logic] Formulas A. **GIVEN** a Fire part of D 41.3 with R_all 448 (the Common Ward), item Fire 17.6 points and the Flame-Quelling Aura's 66.6, **THEN** R is 532.2 and 6.53 gets through. **WHEN** the attacker has penetration 20 points, **THEN** 6.75. **GIVEN** the Common Ward alone and penetration 10, **THEN** R is 438 and 7.68 gets through. **WHEN** FX-T's block applies, **THEN** 5.59 and 6.73 are dealt. **GIVEN** R −50, **THEN** the part takes ×1.5.
- **AC-CD-09** [Logic] Rule 3. **GIVEN** an all-resistance sum of −80 points, **WHEN** a part of D 41.3 resolves, **THEN** it is multiplied by 1.8 and after resistance it is 74.34 (no floor). **GIVEN** −300 points, **THEN** it is multiplied by 4.
- **AC-CD-10** [Logic] Rule 3. Retired 2026-11-10 with the cap: a record carrying `resist_cap_pct` is rejected at load. **GIVEN** R 100, 448 and 900, **THEN** the share stopped is 50 %, 81.75 % and 90 %.
- **AC-CD-11** [Logic] Rule 3. **GIVEN** a Physical → Fire part, **THEN** it uses R_all + R_Fire only. **GIVEN** a Physical part from a Fire-element art, **THEN** it uses R_all + R_Physical, and the Breakdown shows type Physical and element Fire.
- **AC-CD-12** [Logic] Rule 2. **GIVEN** `resist_pct` +15 points scoped Fire from an item, the tree and the Way, **THEN** R_Fire rises by 45 points. **WHEN** ws is 100, **THEN** those terms are unscaled and only ward payloads double.
- **AC-CD-13** [Logic] Rule 4. **GIVEN** `resist_pen_pct` 30 scoped Fire, **THEN** a Fire part's R falls by 30 points (from 448 to 418, so 19.3 % gets through instead of 18.25 %), a Cold part's r is unchanged, and suppression is unchanged. **GIVEN** Physical-scoped penetration on a Physical → Fire part, **THEN** nothing changes; Fire-scoped penetration lowers its Fire resistance.

**Wards, slots and activation (Rules 5–7, Formulas D)**

- **AC-CD-14** [Logic] Formulas D. **GIVEN** Qi Refining with thần thức 81.6 (step 78.75), **THEN** there are 2 ward slots. **GIVEN** 78.74, **THEN** 1. **GIVEN** 157.5, **THEN** 3. **GIVEN** 400, **THEN** still 3. **GIVEN** Deity Transformation at 3.5 × ds_ref plus one `bonus_ward_slots`, **THEN** 7 (4 + 2 + 1).
- **AC-CD-15** [Logic] Rule 5. **GIVEN** three wards in two ward slots and one art slot, **THEN** all three payloads apply at once, the art slot holds no art, and `slot_count` counts the ward.
- **AC-CD-16** [Logic] Rule 6. **GIVEN** a ward with resistance 40 points, shield σ 0.20 and block 60 at ws 50, **THEN** it gives 60 points of resistance, a shield of 0.30 × qi_max and 90 block rating, and its non-drain payment equals its payment at ws 0. **GIVEN** ws 500, **THEN** it applies in full (× 6; no ceiling since 2026-11-10), and a record carrying `ward_cap` is rejected at load. **GIVEN** `defense_pct` −500, **THEN** ws is −90 (`ward_floor`) and `1 + ws/100` is 0.10 (Formulas A0; moved from Combat AC-CB-13).
- **AC-CD-17** [Logic] Rule 7. **GIVEN** a cast ward with cooldown 4 s and duration 3 s, **THEN** it is Waiting until its first firing, Up from each firing through the whole millisecond at firing + 3 s, and Expired until the next firing. **GIVEN** its shield breaks while Up, **THEN** its other payloads stay up until the duration ends. **GIVEN** a refire while it is Up, **THEN** its duration restarts, its shield refills to its maximum, and only one copy exists.
- **AC-CD-18** [Logic] Rule 7. **GIVEN** a standing ward switched Off before the fight, **THEN** it is never Up and takes no payment, and the default ward covers each part for which no other ward is Up.

**Payments and reservation (Rules 8, 10, Formulas C)**

- **AC-CD-19** [Logic] Reserved. **GIVEN** Still Lake ρ 0.71 on FX-T, **THEN** the reserved share is 0.6153 and usable linh lực is 66.4. **GIVEN** res_eff 80 and we 400, **THEN** the share is 0.1183.
- **AC-CD-20** Retired (#44 item C2): upkeep wards were removed; Surging Tide is now per hit (Formulas H).
- **AC-CD-21** [Logic] Per hit. **GIVEN** Golden Bell φ 0.035 on FX-T, **THEN** it costs 4.62 per hit, one fee covering all of the hit's parts. **GIVEN** a pool of 4, **THEN** that hit gets no Golden Bell resistance, and the next hit it can afford does.
- **AC-CD-22** [Logic] Drain. **GIVEN** FX-T with the Common Ward and D 41.3, **THEN** 7.54 gets through resistance, the bill is 6.47, and 6.59 is dealt after block (7.54 − 0.946). **GIVEN** a pool of 5, **THEN** 5 is billed and the unpaid share of the prevented damage leaks. **GIVEN** two drain wards with a pool short of their total bill, **THEN** each pays the same fraction of its bill (pool 15, bills 20 and 10: 10 and 5), and the same share of the total prevented damage leaks.
- **AC-CD-23** [Logic] Cast. **GIVEN** Golden Light Shield κ 0.024 at we 0, **THEN** each firing costs 4.15, and its shield fills to 15.55 at ws 0.
- **AC-CD-24** [Logic] Regression: strength can lose a fight. **GIVEN** the Common Ward at we 30.8 and D 41.3, **FOR** ws in {−90, −50, 0, 30.8, 50, 100, 200, 400}, **THEN** the drain bill strictly falls: 26.42, 13.08, 8.02, 6.47, 5.78, 4.52, 3.15 and 1.96 (±0.01). **FOR** each of the four models, **THEN** total payment at a higher ws is never greater than at a lower one.
- **AC-CD-25** [Logic] Rule 10. **GIVEN** two reserved wards of 0.71 each at we 0 and res_eff 0, **WHEN** compiled, **THEN** the second is rejected with its id named. **GIVEN** 0.71 + 0.19 and an art of cost_share 0.125, **THEN** compile warns that the art is unaffordable (21.6 > 17.3).
- **AC-CD-26** [Logic] Rule 10. **GIVEN** a reserved share of 0.4333, **THEN** an art of cost_share 0.15 still costs 25.9, and a soul hit's linh lực loss lowers only the usable pool.
- **AC-CD-27** [Logic] Edge Cases. **GIVEN** the same ward id slotted twice, **WHEN** compiled, **THEN** it is rejected with the id named.

**Shields (Rule 9, Formulas B)**

- **AC-CD-28** [Logic] Formulas B. **GIVEN** Mountain Screen σ 0.27 on FX-T, **THEN** shield_max is 61.0. **WHEN** 2.0 s pass with no soak, **THEN** it recharges at 19.9 per second. **AT** 1.999 s, **THEN** it has not started. **GIVEN** a partial soak at 1.5 s, **THEN** the delay restarts.
- **AC-CD-29** [Logic] Rule 9. **GIVEN** FX-T with a ward-slot shield of 20 and an art-slot shield of 30, **WHEN** a part of 45 after resistance lands, **THEN** block takes 0.946, the ward-slot shield is Broken, the art-slot shield holds 5.95, and 0 reaches the body shield or health.
- **AC-CD-30** [Logic] Formulas B. **GIVEN** Mountain Screen at ws 400 on FX-T (raw 233.2), **THEN** the ward shield is 233.2 (shields are uncapped). **GIVEN** σ_b 1.3, **THEN** the body shield is 1.3 × health_max. **GIVEN** body gear a_b 1.0, **THEN** it gives σ_b 0.60 and block 12; a_b 2.0 plus Iron Body tier 3 gives σ_b 1.5, not clipped. **GIVEN** the `shield_total_cap` knob set to 0.5, **THEN** the same ward shields are capped at 219.74 at compile, later slots clipped first, and a refiring cast shield never exceeds its clipped maximum.
- **AC-CD-31** [Logic] Rule 9. **GIVEN** a Broken cast shield, **THEN** it never recharges by time, only by firing again.

**Default ward (Rule 11)**

- **AC-CD-32** [Logic] Rule 11. **GIVEN** FX-U with no wards and D 41.3, **THEN** R is 60 points, 25.81 gets through resistance, 25.53 is dealt after block, and the bill is 6.19, unchanged at ws 400 and we 400. **GIVEN** linh lực 0, **THEN** r is 0 and 41.0 is dealt. **GIVEN** a per-hit ward that cannot pay for a hit, **THEN** the default ward applies to that hit.

**Healing (Rules 16–19, Formulas E)**

- **AC-CD-33** Retired (#44 item C1): healing has no decay. A record or key carrying `heal_decay_end` or `heal_decay_floor` is rejected at load.
- **AC-CD-34** [Logic] Formulas E. **GIVEN** FX-T at 200 health and a heal art of cost 0.075, cooldown 3 s and c_heal 4.62, **THEN** it heals 116.6 and refunds 12.96 linh lực, the same at t 0, t 10 and t 50 (no decay). c_heal 4.63 fails the lint. **GIVEN** a body-shield restore of 50 at t 10, **THEN** it applies 50 and refunds nothing.
- **AC-CD-35** [Logic] Heal lint. **GIVEN** cost 0.15 and cooldown 3 s, **THEN** the art lint is 1.0 × (1 + 24 × 0.15) + 0.25 × 2 = 5.1, so c_heal 7.14 (1.4 × 5.1) passes and 7.15 fails.
- **AC-CD-36** [Logic] Rules 17, 18 retired (#44). **GIVEN** FX-T at 100 health and two heals of 150 in one pulse window, **THEN** 150 and then 150 apply (health 400), and nothing is logged "heal cap". **GIVEN** a third heal of 150, **THEN** health stops at 439.48 and the overheal is lost. **GIVEN** `hregen_bonus` 0.03, **THEN** regeneration restores 3 % of health_max a pulse, at any fight time.
- **AC-CD-37** [Logic] Rule 16. **GIVEN** healing_pct 100 and taken_pct −50, **THEN** the heal equals its base (×2 × 0.5, no decay). **GIVEN** taken_pct −100, **THEN** the heal is 0. **GIVEN** `leech_health_pct` 10 under `no_heal`, **THEN** leech restores 0.
- **AC-CD-38** [Logic] Rule 19. **GIVEN** a lethal hit and a 4.0 heal in the same instant, leaving 2.0 health, **THEN** the side is Standing. **GIVEN** a Down side, **THEN** no heal applies.
- **AC-CD-39** [Logic] Rule 19. **GIVEN** `no_heal`, **THEN** every heal and every body-shield restore is 0, and the log says "no healing here". **GIVEN** v 0.7 and an end health of 90 %, **THEN** `v_after` is 0.7. **AT** an end health of 50 %, **THEN** it is 0.5.

**Price check, catalogue and ehp (Rule 20, Formulas F–H)**

- **AC-CD-40** [Logic] Formulas F. **GIVEN** Golden Bell, **THEN** V is 821.2, C is 272.1, the ratio is 3.019 and it passes. **GIVEN** φ 0.034, **THEN** the ratio is 3.107 and it fails.
- **AC-CD-41** [Config/Data] Formulas H. **GIVEN** the ward catalogue file, **THEN** every ward without † passes at its listed ratio (±0.005), including Iron Shirt at 3.019; every † ward is flagged "recheck"; no ward's payment is upkeep; and no ward exceeds σ 0.50 or `ward_block_max` 100. A record carrying `ward_resist_max` is rejected at load (retired 2026-11-10).
- **AC-CD-42** [Logic] Formulas G. **GIVEN** typical FX-T, **THEN** x is 1,102.2 and ehp is 1,376.2 (±0.5). **GIVEN** the thể tu fixture, **THEN** ehp is 2,098.8 against Physical, 1,570.7 against Force and 1,025.8 against Chaos (±1.0). **GIVEN** block above the hit, **THEN** λ stays at least 0.02 and ehp is finite.

**Regressions from the overnight faults**

- **AC-CD-43** Retired (#44 item C2): upkeep wards were removed. A ward record with payment `upkeep` is rejected at load (AC-CD-70).
- **AC-CD-44** [Logic] Ward order. **GIVEN** the Common Ward and the Fire-Shunning Veil in either slot order and no shields, **THEN** damage dealt, each ward's bill and the total bill are identical across 50 seeds.
- **AC-CD-45** [Harness] No stall (#44). **GIVEN** a healer mirror (heal arts at `heal_lint_ratio` 1.4, refunding their cost), **THEN** the fight ends by fatigue by about 66 s (65.8 s in the simulator; flat n² fatigue, Combat Formulas A2) and always before 80 s. **GIVEN** a healer against a typical build with the same budget, **THEN** the healer wins 25–50 % of seeds (simulator 2026-11-10, healer at the heal lint with the refund: 8 of 20, 40 %). **GIVEN** the largest legal heal stack against flat n² fatigue, **THEN** it still falls by 80 s.
- **AC-CD-46** [Harness] Calibration. **GIVEN** the typical rotation at Qi Refining (Combat Formulas K), **THEN** its T0 is 55.8 s (±1). The FX-T fixture mirror ends at exactly 34.000 s with linh lực dry at 10 s, and the FX-U mirror at 64.000 s by flat n² fatigue, both draws (Combat AC-CB-30, worked by hand). **GIVEN** the other realms' typical mirrors, **THEN** each lasts 30–60 s (#44 item A1).

**Determinism and Breakdown**

- **AC-CD-47** [Logic] Determinism. **GIVEN** two sides with layered wards, shields, heals and one seed, **WHEN** the fight runs twice, **THEN** the logs are byte-identical.
- **AC-CD-48** [Logic] Rule 1. **GIVEN** any hit part except Soul, **THEN** its Breakdown lists evade; R_all, R_type (final type), penetration, R and the share stopped; block (the hit's total and this part's share); each ward-shield soak; the body-shield soak; health dealt; each ward's payment; and the default ward when it applies.
- **AC-CD-49** [Logic] Edge Cases. **GIVEN** thần thức changed mid-fight by a fixture hook, **THEN** ward slots and the base defence sums are unchanged.

**Cross-system**

- **AC-CD-50** [Integration] Rule 19. **GIVEN** a Heavenly Tribulation run, **THEN** every wave request carries `no_heal` = true, and lightning parts are Lightning, cut by R_all + R_Lightning.
- **AC-CD-51** [Integration] Rules 14, 21. **GIVEN** every reference NPC and creature profile at each realm, **THEN** each has thần thức > 0 and a soul resistance value. **GIVEN** a two-ward NPC, **THEN** it compiles by the same rules and its Breakdown names its wards.
- **AC-CD-52** [Integration] Modifier System. **GIVEN** `resist_pct` (all and type-scoped), `resist_pen_pct`, `block_rating`, `body_shield_pct`, ward strength, ward efficiency and `healing_pct` modifiers in a build, **THEN** the compiled profile's sums match the Modifier System's totals.

**Block and body shields (added with the revision)**

- **AC-CD-53** [Logic] Formulas A2. **GIVEN** parts of D 30 Physical (R 0) and D 30 Fire (R 900 points) against block 8 points, **THEN** block takes 7.27 and 0.73 and 25.0 is dealt. **FOR** any split of a hit, **THEN** the hit loses exactly min(B_hit, Σ a_j).
- **AC-CD-54** [Logic] Formulas A2. **GIVEN** the block_unit table, **THEN** one rating point is 0.0631 / 0.2031 / 0.6672 / 2.254 / 6.883 points by realm, times stage. **GIVEN** FX-T, **THEN** its rating is 15.0 (flesh 4.8 + armour 10.2) and its block 0.946. **GIVEN** FX-U, **THEN** 4.4 and 0.278.
- **AC-CD-55** [Logic] Rule 9. **GIVEN** a body shield damaged to half, **WHEN** 30 s pass with no Effect, **THEN** it is still at half. **GIVEN** a standing ward shield damaged the same way, **THEN** it recharges after 2 s.
- **AC-CD-56** [Logic] Rule 9. **GIVEN** a Chaos hit on the thể tu fixture, **THEN** its after-block amount passes the body shield and reaches health. **GIVEN** a body shield authored as not passed by Chaos, **THEN** it soaks the Chaos hit.
- **AC-CD-57** [Config/Data] Formulas B, I (2026-11-10). **GIVEN** body gear at a_b 1.0, **THEN** it prices at about 35 W (block 4.8 + shield 30.6); parity with ward gear is no longer required (re-review Q8).
- **AC-CD-58** [Harness] Formulas A2. **GIVEN** the fast 0.5 s kit and the slow 3 s kit at equal budget, **THEN** the fast kit's damage per linh lực is within 10 % of 1.26 × the slow kit's against a typical defender, and below the slow kit's against the thể tu and against typical + Iron Shirt.

- **AC-CD-59** [Harness] No shield stall (shields uncapped, user decision 2026-11-08; attackers per re-review CD 4). **GIVEN** a top-end shield kit at each realm (Mountain Screen and Thousand-Layer Cloud at ws 400 and we 400, and again at ws 800 since ws has no ceiling, plus body gear at a_b 2.0 and Iron Body tier 5) **AGAINST** the realm's typical attacker (FX-T offence) **AND** a slow-hitter variant: FX-T with only Formulas A2's slow art (c 3.3, 3 s cooldown, D 68.1 at Qi Refining, scaled per realm) and no basic attack, **THEN** it is Down by 90 s against both (fatigue passes shields and grows without bound, so this holds by rule), and its end time against the typical attacker is recorded; past 60 s, the first fix is a cap knob (`shield_total_cap` or `body_shield_cap`); raising `recharge_delay` or lowering `shield_recharge` is also allowed. Record the value chosen.
- **AC-CD-60** [Logic] Formulas C, drain. **GIVEN** a drain-paid resistance ward on a part whose R after penetration is −20 points, **THEN** its bill is 0. **GIVEN** a part with no positive resistance (R_pos 0), **THEN** the bill is 0 and nothing divides by 0. **GIVEN** a drain-paid block payload of 8 points on FX-U (flesh 0.278, so `B_hit` 8.278) and a hit whose parts total 5, **THEN** it bills `rate_w` × 4.83. **GIVEN** a drain-paid evade, status or soul ward, **THEN** compile rejects it.
- **AC-CD-61** [Logic] Formulas C, shared block (re-review CD 3). **GIVEN** a hit whose `B_hit` of 10 points is 4 from flesh and gear and 6 from a drain-paid ward's block, against parts totalling 5, **THEN** the hit loses 5 points of block, the ward's share is 3.0, and it bills `rate_w` × 3.0. **GIVEN** a pool short by half for a drain-paid resistance ward, **THEN** half its prevented damage rejoins the part before block, and block and shields then meet it. **GIVEN** the first hit and a pool that pays only half of the ward's 3.0 bill, **THEN** the ward takes 1.5, flesh and gear take 2.0, the hit loses 3.5 points of block, and 1.5 more moves on to shields.
- **AC-CD-62** [Logic] Rule 14, Formulas B (re-review CD 1). **GIVEN** a soul hit that E2 turns into losses of 10 health and 6 linh lực, against a soul shield of s_soul 0.50 and a bar of 6, **THEN** the shield takes 5 from health and 1 from linh lực, the bar is empty, and 5 health and 5 linh lực are lost. **GIVEN** ws 100, **THEN** the bar doubles and s_soul stays 0.50. **GIVEN** a record with s_soul 0.90, **THEN** compile clamps it to 0.75 and warns.
- **AC-CD-63** [Logic] Rule 11 (re-review CD 8, CD 11). **GIVEN** a side whose only ward is Clear Heart Ward (status payload only), **THEN** the default ward still covers every hit part. **GIVEN** a side flagged `no_default_ward`, **THEN** it has no default ward. **GIVEN** a side flagged `cannot_slot_wards` with a ward in its loadout, **THEN** compile rejects the ward and names it.
- **AC-CD-64** [Logic] Rule 19 (re-review CD 21). **GIVEN** `no_heal` and an Effect that refuses the Down step, **THEN** the side stands at 1 health, and it is not counted as healing.
- **AC-CD-65** [Logic] Formulas G (re-review CD 7). **GIVEN** a side whose only ward is Still Lake Aura (reserved, all resistance, so the default ward is never Up and b = 0), **THEN** ehp is P / λ_all and nothing divides by 0.
- **AC-CD-66** [Logic] Edge Cases, Compile (re-review CD 20). **GIVEN** FX-T with the Common Ward and Exposed (all resistance −100 points), applied at 3 s, **THEN** a part resolved before 3 s uses R 448 (stops 81.75 %), a part resolved in a later instant uses R 348 (stops 77.68 %), and ward slots are unchanged.
- **AC-CD-67** [Logic] Rule 9 (re-review CD 6). **GIVEN** Thousand-Layer Cloud on FX-T, **THEN** its shield is 45.2 at t 0. **GIVEN** a per-hit-paid shield ward whose fee fails while its shield holds 20, **THEN** while it is Down the shield soaks nothing and is still 20 five seconds later.
- **AC-CD-68** [Logic] Formulas C, drain on a linh lực tick (user decision 2026-11-08b CD-04: kept as a known weakness). **GIVEN** FX-T at full linh lực and a Qi Disruption tick of 10 against the default ward only (all 60 points, stopping 37.5 %, drain 0.40; no burn cap since #44), **THEN** 6.25 comes off linh lực, the default ward bills 1.5, and linh lực falls by 7.75 in total.
- **AC-CD-69** [Logic] Formulas F, cast wards (re-review 2026-11-08b CD-02). **GIVEN** Black Tortoise Shell and Golden Light Shield at Qi Refining typical, **THEN** their cast costs count firings inside `T_ref` 45 s (9 firings, 57.52; 11 firings, 45.60), and their ratios are 4.711 and 3.750, under limits 4.766 and 3.813.
- **AC-CD-70** [Logic] Rule 8 (moved from Combat AC-CB-72). **GIVEN** a ward record whose payment is not one of the four models (reserved, per hit, drain, cast; `upkeep` included, removed with #44), **WHEN** data loads, **THEN** it is rejected and the error names the record and the field.
- **AC-CD-71** [Logic] Rule 1, ticks (Combat revision D11). **GIVEN** a Burn applied by a source with Fire penetration 20 points to a target with Fire resistance 50 points, **WHEN** the source's penetration later rises to 40 points, **THEN** every tick of that Burn still uses R 30 points. **GIVEN** a tick whose share after resistance and shields is 0.4, **THEN** health loses 0.4 (ticks have no floor, Combat Formulas F); **GIVEN** a tick fully soaked by a shield, **THEN** health loses 0.
- **AC-CD-72** [Logic] Rule 6, cleanse. **GIVEN** a side with Clear Heart Ward (`cleanse_share` 0.25) carrying a Poison batch of 8 stacks, **WHEN** a pulse passes, **THEN** 6 stacks remain; **GIVEN** a batch thinned below 0.05 stacks, **THEN** it is removed (Effects Formulas D).
- **AC-CD-73** [Logic] Rule 16, Formulas E, heal refund (user decision 2026-11-10). **GIVEN** FX-T 1 health below maximum and a heal art that paid 12.96 linh lực, **WHEN** it lands, **THEN** 1 health is restored and 12.96 is refunded; **GIVEN** a heal art with a cast time, **THEN** the refund lands with the heal; **GIVEN** a short pool that paid 0, **THEN** 0 is refunded.
- **AC-CD-74** [Logic] Edge Cases, wards and stacks (user decisions 2026-11-10). **GIVEN** 5 Ice stacks (+19.5 % art cost) on a side with Black Tortoise Shell in an art slot and the same ward in a ward slot, **THEN** only the art-slot copy's cast cost rises by 19.5 %. **GIVEN** FX-T with Still Lake reserved at the start and Water stacks raising maximum linh lực by 20, **THEN** usable linh lực rises by 20.

**Remaining gaps** (from `qa-lead`, not yet resolved; see Open Questions):
- AC-CD-51 checks presence only. Exact soul defence values by realm need a table (Open Question 12).

## Open Questions

| # | Question | Owner | Resolve by |
|---|---|---|---|
| 1 | Closed 2026-11-08 (re-review MD 12): modifiers.md's defence rows and prices match Formulas I. Left: the artifact-defence basis note (row 16) | — | Closed |
| 2 | The Combat revision (#43) must replace Combat rule 4's path, rule 22 and all of Formulas D (leaving a stub that cites this GDD's Formulas A0), `ward_art_duration` (A2), Formulas A's ehp and Formulas K's `t_w` and `t_h`, rule 24's and Formulas E2's "ignores wards" (soul wards and soul shields now apply, this GDD's rule 14), rewrite the ward ACs, and add the back-references the Dependencies table lists (re-review CD 16) | user + systems-designer | Combat revision |
| 3 | The cheap 0.5 s art kit: flat block now makes it a counter-build matchup (Formulas A2). Confirm with the harness (AC-CD-58) before deciding whether the art lint still needs the curved check (overnight decision 3) | systems-designer | Balance harness |
| 4 | The reserved wards in the catalogue (†) were scaled ×1.5 by hand for `reserve_weight` 1.5. Rerun the price check on them once the lint tool exists | systems-designer | Before ward content ships |
| 5 | Healing inside Heavenly Tribulation waves is 0 for now. Revisit once the boss pool and tribulation healing are designed (overnight decision 7) | user | Heavenly Tribulation revision |
| 6 | Settled by Combat Damage Types (#21b): resistance is by damage type, and no element cycle applies in fights | — | Closed 2026-11-07 |
| 7 | Healing and healing taken W prices (0.5) are guesses with no heal-build anchor | systems-designer | First healer reference build |
| 8 | The price check values status and soul payloads coarsely (0.008 · I · T per W). Refine once soul and status reference builds exist | systems-designer | Balance harness |
| 9 | Shields rarely recharge in a duel at a 2 s delay. Confirm with the harness that shield builds still get picked | systems-designer | Balance harness |
| 10 | Closed 2026-11-08: the registry holds these entities. Its last step, retiring `ward_block`, is done (row 14) | — | Closed |
| 11 | Harness checks: layered shields behind high resistance (flag ehp above 3 × top-end); stacked reservation; high resistance plus healing against the realm's typical attacker; the largest legal heal stack against flat n² fatigue (it must still fall by 80 s, AC-CD-45); a thể tu healer; per-hit wards against tick builds; two drain wards against penetration builds; ward strength's value per extra ward, now with no ceiling; whether reserved wards are still picked; no shield build stalling a fight now that shields are uncapped (AC-CD-59); block against top-end-sized hits (the thể tu falls to 446 there); the FE–DT n_body and block anchors; ticks now skipping block (about +7 % against typical) | systems-designer | Balance harness |
| 12 | Rule 14 gives every profile a soul defence, but no table of thần thức and soul resistance by realm exists for reference enemies and NPCs. Add one, so AC-CD-51 can check exact values | systems-designer | Before NPC Builds use it |
| 13 | Item DB must adopt the body-gear mapping (0.60 σ_b and 12 block per a_b, top-end body gear 1.0 × B_p) and the block from ward gear capped at a = 1 | user | Item DB revision |
| 14 | ~~Retire the registry's `ward_block` and `body_guard_pct` once Combat #43 lands~~ **Closed 2026-11-10:** `ward_block` and the `body_guard` formula (which held `body_guard_pct`) are `deprecated` in the registry | — | — |
| 15 | The Modifier System's Pending rows that cite this GDD (typed block after the shared pool, foe-scoped resistance, a body-shield increased op, recharge delay, cast ward duration, the `[body_shield]` scope) are defined here when they leave Pending; decide then whether a cast ward's duration must stay below its cooldown (re-review CD 12) | systems-designer | When each row leaves Pending |
| 16 | Re-check modifiers.md's "about 0.35 on body gear" artifact-defence note against Formulas B and I's raised body-gear mapping (re-review CD 18) | systems-designer | Modifier System re-review |
| 17 | ~~Reword Formulas E's "continuous model" stall note~~ **Closed 2026-11-09:** the stall check is now fatigue (#44) | — | — |
| 18 | ~~Shield prices after #44~~ **Closed 2026-11-10:** payments cut to pass at the bar and `shield_per_cost` 3.81 (Formulas F, H); the harness confirms with AC-CD-59 | — | — |
| 19 | **Reserved resistance got dearer.** At `T_ref` 45 s, Still Lake Aura needs 0.71 of the pool (was 0.50) and the Flame-Quelling Aura 0.49 (was 0.35). Confirm with the harness that auras still get picked in 30–60 s fights | systems-designer | Balance harness |
| 20 | ~~The price check values each ward alone~~ **Closed 2026-11-10:** documented as intended (Formulas F, Stacking): the lone price is exact for a side's first ward, later wards are worth less by design | — | — |
| 21 | ~~Clear Heart Ward's cleanse payload has no price~~ **Closed 2026-11-10:** the ward is priced on its status payload (reserved 0.25, 3.043 / 3.050) and the cleanse rides free; the simulator shows a free 0.25 cleanse moves Fire stacks only from 19 to 16 wins in 20 | — | — |

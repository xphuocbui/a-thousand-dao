# Sustain audit: resource stats in the Modifier System (2026-11-08)

Input for the planned Combat economy revision (systems-index #44, combat.md Open Question 26). The user's
direction (2026-11-08): resource sustain is a core build axis and sustain is king. All-in burst builds (spend
the whole pool at once; win, or be spent) stay possible but rare. The economy must support mana-based công pháp,
such as damage that scales on remaining linh lực, or overflow linh lực turned into a shield or damage. Sources:
`design/gdd/modifiers.md` (Stat List, General Catalogue, Formulas A), `design/gdd/combat.md` Formulas E, and
`design/gdd/combat-defence.md` Formulas C and E.

## What exists today

**Linh lực (mana)**

| Stat | Key | Operation | Price | Catalogue rows | Status |
|---|---|---|---|---|---|
| Maximum linh lực | `linh_luc_pct` | % increased | 1.0 W per % | 1, universal only (+1.2 % small, +8 % notable) | **Live** |
| Linh lực regeneration | `linh_luc_regen_pct` | flat pp of maximum per pulse (1 s) | **8 W per pp** | 1, universal only (+0.15 pp/s small, +1.00 pp/s notable) | Designed |
| Art cost reduction | `art_cost_pct` | % reduced, capped at −50 % (`cost_red`) | 1.2 W per % | 7: universal, by type, element, form, curse, slow/costly, poison | Designed |
| Reservation efficiency | `reserve_eff_pct` | % increased, counts to 50 | 0.8 W | 1 | Designed |
| Ward efficiency | `ward_efficiency_pct` | lowers every ward payment | 1.0 W | yes | Designed |

**Health**

| Stat | Key | Operation | Price | Catalogue rows |
|---|---|---|---|---|
| Health regeneration | `health_regen_pct` | pp of maximum per pulse, capped at 2 | 3.0 W per pp | 1, universal only |
| Healing, healing taken | `healing_pct`, `healing_taken_pct` | % increased | 0.5 W each | for heal arts and heals |

**Outside the Modifier System:** an art may cost health instead (`body_cost_share`, an art-record field). Effects:
- refund triggers;
- Blood Casting (pay the shortfall in health; an enabler);
- Water Table (gain from the enemy's ward payments);
- Still Water (regeneration clipped by a full pool restores health);
- Blood Drinker (restore a share of damage dealt).

## Problems for a sustain-first design

1. **Regeneration is priced against 8-second fights.** The price basis reads "+1 pp/s over a typical 8 s fight is
   about +8 % of the pool". In a 45 s fight the same notable is worth about +45 % of the pool. The price, the cap or
   both must change with the fight length.
2. **Regeneration is tightly capped.** Base regeneration is 2 % of the pool per pulse and `regen_cap` is 8 %, so all
   bonuses together add at most +6 pp, about six notables' worth. "Sustain is king" probably needs a higher cap or a
   different shape, such as diminishing returns instead of a hard stop.
3. **Thin variety.** Maximum linh lực, linh lực regeneration and health regeneration each have one universal row
   only, with no scoped or conditional versions. Art cost reduction is the only sustain stat with variety (7 rows).
4. **Missing entirely:**
   - **Linh lực gain from play:** on hit, on crit, on kill, on a status applied. Today it exists only as Effects.
   - **Increased regeneration rate:** a % increase of regeneration, beside the flat pp.
   - **Paying with health as a stat:** for example "X % of art costs paid with health instead". Today it is only an
     art-record field and the Blood Casting enabler.
   - **Leech:** a share of damage dealt returned as linh lực or health. Blood Drinker is an Effect; there is no
     plain stat.
5. **A rule question.** In PoE, "mana gained on hit" and leech are plain modifiers. Under this project's rule, an
   event such as "on hit" is a rule, so it is an Effect. To make gain-on-hit cheap, common modifier content would
   need a narrow exception to the Modifier vs Effect rule, like the conversion exception allowed on 2026-11-08.
6. **Character Stats does not know the new keys yet** (consistency C14). Only `linh_luc_pct` is live there.
   Regeneration, cost reduction and health regeneration are not.

## Related levers outside the Modifier System (for #44)

- Combat Formulas E: `regen_base` 0.02, `regen_cap` 0.08, art `cost_share` 0.04–0.25 of `qi_max`.
- Combat Defence & Healing:
  - the drain rate per prevented point;
  - upkeep growth (+15 % per pulse);
  - the heal cap (`heal_pulse_cap` 0.04) and heal decay;
  - the ward price check's 8 s reference fight (`T_ref`).
- These set how fast linh lực runs dry today (3–6 s in a typical mirror).

## Element stacks (user decisions 2026-11-09, part of #44)

The stack-buff system set aside on 2026-11-08 comes back as **element stacks**, drafted inside revision #44. Each
element has a **buff** (on yourself) and a **debuff** (on a foe), counted in stacks. The two tracks are separate: a
character can carry buff stacks, debuff stacks, both or neither. Chaos (Hỗn Độn), Light (Quang) and Darkness (Ám)
have no stacks.

| Element | Buff, per stack | Debuff, per stack |
|---|---|---|
| Fire (Hỏa) | +1 % damage dealt | Burn: Fire damage per second. The source is whoever applied it, so their damage increases apply |
| Water (Thủy) | +maximum linh lực and +linh lực regeneration | — (Ice carries it) |
| Earth (Thổ) | +Physical resistance | −accuracy |
| Metal (Kim) | +Physical damage dealt | +Physical damage taken |
| Wood (Mộc) | +health regeneration | Poison: damage per second |
| Ice (Băng) | — (Water carries it) | +1 % art cost |
| Thunder (Lôi) | +accuracy and +critical chance | +critical chance and +critical damage taken |
| Wind (Phong) | +art speed | −evade (user picked this over −art speed) |

Numbers other than the 1 % rows are still to set.

**Rules decided:**
1. **Gain and loss come from the source.** The art, Effect or item that grants stacks says how many and for how long;
   there is no default stack timer.
2. **No cap on stacks.** The answer to a big stack is cleansing: debuff-cleansing wards and Effects.
3. **Water and Ice share one pair:** Water holds the buff, Ice the debuff.
4. **Void (Hư Không) and Blood (Huyết)** have no stacks. They are still variant roots in Spiritual Roots
   (`linh-can.md`); whether they are being removed is open.

**To settle while drafting #44:**
- **Existing statuses.** Burn (Fire), Poison (Chaos) and Frostbite and Shock (Effects System Status Catalogue)
  overlap the debuffs. Proposal: Burn becomes Fire's debuff, Poison becomes Wood's (keeping the Chaos damage type, so
  it still passes shields), and Frostbite and Shock retire.
- **Caps that still bound uncapped stacks.** The tick caps (one pulse's ticks ≤ 8 % of maximum health), `regen_cap`
  (8 % of the pool per pulse, which limits the Water and Wood buffs), `cost_red` (−50 %), the Heavy Breath curse's
  `curse_cost_raise_max` (+50 %, which Ice's uncapped +1 % per stack overlaps), and crit chance stopping at 100 %.
  Each needs a ruling: keep, raise, or exempt element stacks.
- **Cleansing.** Cleanse tags exist on every status; cleansing wards and Effects that remove element debuff stacks
  (all, some, or one element) need authoring.
- **Pricing.** "Per stack" is a rule, so stack-granting pieces are Effects, while "+X % buff strength per stack" or
  "+stacks gained" could be plain modifiers.

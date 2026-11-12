# The Hundred-Ailment Ledger (Bách Bệnh Lục), geared: many different curses on one foe, paid by the count, with Ruin Ledger items

Realm: Hóa Thần (Spirit Transformation). Fight file: `builds/status-collector.fight.json`. Old build: `design/builds/engine-v2/status-collector.md`.

## Loadout

Limit for the extra slots: 45 × divine_sense 1.0 × (1 + 14 / 100) = **51.3** (the build's total thần thức bonus is 14 %: Hollow Robe 6, Branding Iron 4, Deep Freeze Ring 4).

| Slot | Item | Grade | Why it is here |
|---|---|---|---|
| Weapon | Balance-Sheet Seal (Kết Toán Ấn) `force-chaos-ledger-seal` | 3 | Its art Settle the Account counts as a Ruin Ledger Scripture art, lays Stagnation, and cashes Fray at 4.5 times |
| Armour | Hollow Robe (Không Y) `force-chaos-hollow-robe` | 2 | Chaos resistance and a Force ward; the build's own ward is stronger, so the robe is kept for its resistance and thần thức |
| Ring 1 | Deep Freeze Ring (Thâm Đống Giới) `ice-deep-freeze-ring` | 4 unique | Ice stacks last longer and art speed rises; Deep Freeze delays the foe's art at every 10 Ice stacks |
| Ring 2 | Hollow Ring (Không Giới) `force-chaos-hollow-ring` | 1 | Stronger debuff stacks and Chaos attack |
| Necklace | Ledger-Murmur Pendant (Phế Thanh Bội) `force-chaos-ledger-murmur-pendant` | 2 | Stronger debuff stacks; reserve art lengthens every status |
| Extra 1 (TT 15) | Ledger Branding Iron (Phế Trướng Lạc Thiết) `force-chaos-ledger-branding-iron` | 2 | Marked Prey: hits grow with each different status on the foe |
| Extra 2 (TT 18) | Black Ledger Mirror (Huyền Trướng Kính) `ice-black-ledger-mirror` | 3 | Longer and stronger Ice stacks, Cold art speed; Toll Taker refills linh lực |
| Extra 3–6 | empty | | 33 of 51.3 thần thức used |

Art swap: `blight-canker` out, `force-chaos-settle-the-account` in (seven slots, as before). Settle lays Stagnation itself, but the build loses Poison as a status kind.

## Before and after

| Matchup | Mean s, old | Mean s, geared | W-L-other, old | W-L-other, geared |
|---|---|---|---|---|
| Hóa Thần vs typical | 2.9 | 2.9 | 20-0-0 | 20-0-0 |
| Hóa Thần vs top_end | 6.5 | 5.4 | 20-0-0 | 20-0-0 |

(The old file was re-run on the current engine; the figures in the v2 guide, 1.6 s and 4.0 s, were from an earlier engine.)

`--without` tests (geared file, `--matrix`):

| Removed | Typical | Top_end |
|---|---|---|
| `item:force-chaos-ledger-seal` | 2.9 to 2.9 s, NO_CHANGE | 5.4 to 5.4 s, NO_CHANGE |
| `item:force-chaos-ledger-branding-iron` | 2.9 to 2.9 s, NO_CHANGE | 5.4 to 5.4 s, NO_CHANGE |
| `eff:Marked Prey` | 2.9 to 2.9 s, NO_CHANGE | 5.4 to 5.9 s, 20-0 both |

All runs 20-0-0.

## Upgrades to look for

| Piece | Modifier or Effect | What it adds | Where it comes from | In the catalogue or missing | Priority |
|---|---|---|---|---|---|
| Weapon | Settle the Account (art) | A fourth suite art that cashes Fray | Ruin Ledger clerks, craft | In the catalogue | High |
| Extra | Marked Prey (Effect) | Up to +16 L5 from different statuses | Branding Iron, craft or npc | In the catalogue | High |
| Ring | Deep Freeze (Effect) | Delays the foe's art every 10 Ice stacks | Northern Nascent Soul Ice cultivator | In the catalogue (not modelled) | Medium |
| Necklace | `stack_effect_pct` and `status_duration_pct` | Stronger and longer statuses, the passives this engine cannot run | Pendant and seal | In the catalogue (not modelled) | Medium |
| Armour | A ward that beats the build's own | Survival | Any ward robe | Hollow Veil (264) is below the build's 342.5 | Low |
| Extra | Poison or Stagnation source on an item | Replaces Poison lost with Blight Canker | None | Missing | Medium |

## Missing pieces

- A Wood-family item that lays Poison and Stagnation (so Blight Canker need not give up a slot): Wood.
- A Metal or Earth-family item that lays Sundered or Exposed, the status kinds the old build had: Metal.
- An item that raises a count's cap (Marked Prey stops at +16): Force-chaos.

## UNMODELLED

- Toll Taker (Black Ledger Mirror): the engine has no readable for the extra art cost the foe pays for your Ice stacks.
- Deep Freeze (Deep Freeze Ring): the engine has no event for a stack count crossing a multiple of 10. Its 10 % art-cost penalty is not applied either.
- Ledger-Murmur Pendant reserve art: reserved linh lực is not deducted and its grants are not run.
- Hollow Veil ward: not used, the build's own drain ward is stronger.
- Item passives with no engine stat: `stack_effect_pct`, `stack_duration_pct`, `status_duration_pct`, `stack_grant`, `khi_huyet_pct`, `defense_pct`, `status_resist_pct`, `than_thuc_pct`; `art_speed_pct` scoped `curse` or `cold` is applied to every art.

## Observations

Gear barely mattered. Against a typical foe the fight stayed at 2.9 s, and on top_end it fell from 6.5 to 5.4 s, both still far under the 30-60 s band. Nothing went degenerate, but L1 clipping rose (4.0 on typical, 19.1 on top_end) because the added attack percentages push past the soft knee. The only item piece with a measurable effect is the Marked Prey Effect: removing it moves top_end from 5.4 to 5.9 s and changes nothing on typical. Removing the Balance-Sheet Seal or the Branding Iron alone changes nothing, since the seal's art never fires against a typical foe (it fires 1.1 times on top_end) and the iron's own modifiers are mostly unrun passives. NEVER_FIRED on typical: Rime Lock Seal, Black Ice Glaze, Shatter Palm, Gathered Ruin Verdict and Settle the Account; on top_end every art fires. The items' strongest passives (stack effect and duration, Deep Freeze, Toll Taker) cannot run, so the geared build is under-measured. Observations only, no tuning was done.

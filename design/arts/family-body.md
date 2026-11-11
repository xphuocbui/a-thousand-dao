# Family: element-less body forms (fist, palm, thể tu)

8 signature arts in `family-body.json` (5 engine, 3 standalone), linted: 0 findings. Numbers are first guesses; none tested in
a fight. Engine payoffs (lint report): full steps at x4.1-5.3 of the lint; first steps x1.4-3.0.

| Art | Power | Mechanic shape | Hooks | Engine (how to feed it) | One-line rule |
|---|---|---|---|---|---|
| Marrow Tithe Strike (Tủy Cống Quyền) | engine | Paying with health | health cost, Debt, low health, cost reduction, linh lực restore | Debt (its own firings, hits taken, Last Breath / Bulwark siblings) OR own health ≤ 50 % for the x4 step; the x11 step needs 6 Debt AND (health ≤ 30 % OR three canon arts in 2 s) | Pay 8 % health for a small strike and linh lực; writes Debt; steps call it in as a x4 then x11 burst that refills linh lực |
| Last Breath Fist (Tàn Tức Quyền) | engine | Conditional payoff (low health) | low health, Debt, dmg more, Exposed | step 1: health ≤ 50 % OR 3 Debt; step 2: 5 Debt AND (health ≤ 25 % OR three canon arts in 2 s) | More damage per 10 % health missing; steps x3 then x6 and Exposes |
| Bulwark Knuckle (Thuẫn Quyền) | engine | Shield as a weapon | body shield, shield size, Ram, Force, stance | body shield ≥ 20 % / 30 % AND (Mountain Root stance OR 5 Ram from hits behind the shield and broken shields OR three canon arts) | Raise a shield, hit harder per shield held, burst on break; steps x3.5 then x10 Force |
| Answering Palm (Ứng Hưởng Chưởng) | engine | Echo / repeat | echo, palm count, art speed, crit, heavy last art | step 1: 2 echoes, OR three scripture arts in 2 s, OR a Slowed foe; step 2: two scripture arts in 2 s AND (four arts in a pulse, OR Barrage just fired, OR Slowed 3 deep) | Every 3rd palm art refires your last art at 60 %; steps x2.8 then x5 plus a whole-strength repeat |
| Rolling Barrage Fist (Cổn Liên Quyền) | engine | Charges and bursts (+ split rain) | charges, crit, per-hit, cooldown cut, art speed, Tempo | Tempo from any fist art (and Twin Shadow's double): step 1 at 4 Tempo OR three fist arts in 3 s; step 2 needs 6 Tempo AND (three scripture arts in 2 s, three fist arts in 3 s, OR foe Slowed 3 deep) | 4 charges of quick hits; Tempo opens a x3 Cascade then four x3 Rain hits |
| Twin Shadow Fist (Song Ảnh Quyền) | standalone | Summon | companion speed, crit, summon, Tempo | feeds the Barrage Fist's Tempo with each double hit | Calls a 12 s double that strikes every 2.5 s; crits quicken it |
| Mountain Root Stance (Sơn Căn Thế) | standalone | Stance / form | damage taken, block, body shield, thorns | feeds Bulwark Knuckle's Collapse (the form is one of its routes) | Toggle: 14 % less damage, strike back (1.0x) on every hit, 8 % slower, Barrage Fist suppressed |
| Bone-Turning Palm (Chuyển Cốt Chưởng) | standalone | Conversion | conversion, Force, Physical, Qi Disruption, palm count | counts as a palm art for any echo | Half the heavy blow lands as Force; leaves Qi Disruption |

## Suite 1: Unbroken Flesh Canon (`unbroken-flesh-canon`, Bất Hoại Nhục Kinh)
Marrow Tithe Strike, Last Breath Fist, Bulwark Knuckle (Mountain Root Stance is the optional fourth, read by Bulwark).
Health is the resource. Marrow Tithe pays health and writes **Debt**; Last Breath Fist and Marrow's own steps spend Debt; Bulwark Knuckle spends
**Ram** (hits taken behind a shield) and rewards shields, which Marrow's tithe also hardens a little. Cross-feed: any three canon
arts fired within 2 s open the last step of all three, so a rotation of all three is the full engine. Hooks: health regeneration,
shield size, low health, cost reduction, damage taken.

## Suite 2: Hundred Echo Palm Scripture (`hundred-echo-palm-scripture`, Bách Hưởng Chưởng Kinh)
Answering Palm, Rolling Barrage Fist, Twin Shadow Fist. Tempo (written by any fist art and by the shadow double) opens the Barrage's steps;
the Barrage just fired opens the palm's Thousand Echo; any three scripture arts within 2 s open both top steps. Slowed Time is a
shared outside key. Hooks: art speed, crit, arts per pulse, companion speed.

## Replaces
No library art. The common Iron Fist, Qi-Shaking Palm and Shockwave stay; Shattering Fist (strip) is a control art and stays. The first draft's
Marrow Tithe, Last Breath Fist, Answering Palm and the rest were kept and upgraded into the engine form (Marrow Tithe gained a strike).

## What the engine could not express
- **Refused fall**: the draft's Last Breath "refuse a fall once" is dropped; `refuse_down` only works with a build `refusals` count, an art cannot grant one.
  Missing piece: an art-granted refusal.
- **Counter pay by route**: a step `pay` runs whichever route unlocked it (low health still pays 4 Debt, floored at 0). Missing piece: per-route pay.
- **`own.charges` readable**: Rolling Barrage Fist cannot pay off on its last or empty charge.
- **Held 'next art' payload by art tag**, and an echo's own `art_fired` (`fire_art` fires no art event, so echoes do not count toward Tempo or the palm echo; arguably good).
- **Negative shield pay**: Bulwark cannot spend shield as a cost (no safe `shield` subtraction), so shield is a gate, not a payment.
- **Conversion** is a share meeting the other defence; it does not retag the hit for Force-scaled modifiers.

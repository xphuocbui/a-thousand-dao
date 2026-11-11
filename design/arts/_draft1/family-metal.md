# Metal (Kim) signature arts

8 authored arts in `family-metal.json`, linted: 0 findings. Numbers are first guesses inside the art lint.
Commons (Quick Draw Cut, Notch the Foe, Closing Palm, Peg-Line Cut) are untouched and not repeated.

| Art | Mechanic shape | Hooks | One-line rule |
|---|---|---|---|
| Whetstone Pass (Mài Phong Chưởng) | Counter ramp (timed counter) | art speed, crit, temper count, quick arts | Each Metal art fired adds a 10 s Temper; each Temper gives Metal arts +1 crit chance, no cap. |
| Shatter-Edge Cleave (Toái Nhận Trảm) | Build-up then cash-in (consume) | metal debuff stacks, trigger damage, stack duration | Heavy hit that breaks all foe Metal debuff stacks; every 2 broken strike again for 0.7 c. |
| Iron Hide Stance (Thiết Bì Thế) | Stance / form | resistance, block, hits taken, buff stacks | Toggle: +60 resist, +20 block, -20 % art speed, Cleave suppressed; hits taken give Metal buff stacks. |
| Blood-Quench Blade (Huyết Thối Nhận) | Paying with health, repaid by crits | crit, healing, health-cost reduction | Pays 6 % health, gives 5 Metal buff stacks; each crit of the art heals 2 %. |
| Needle Rain (Châm Vũ) | Split hits | crit, on-hit effects, bleed, split count | 6 needles roll their own crits and lay Bleed; crit needles lay Metal debuff stacks. |
| Sundering Wedge (Liệt Thạch Tiết) | Curse pattern (stack to threshold, then escalate) | curse duration, status application, foe resistance | Lays Sundered; into a foe at 3 Sundered it adds Exposed (once per 6 s). |
| Flying Blade Retinue (Phi Nhận Trận) | Summons | companion speed, summon count, duration | Each firing adds a flying sword (0.45 c every 2 s for 12 s) whose hits lay Metal debuff stacks. |
| Sheathed Edge (Nhập Sao Nhận) | Held payload ("your next art") | crit, trigger damage, banked cap | Crits bank up to 4 strikes; your next art fired releases them as free hits. |

## Replaces
- Thorn Chorus (`thorn-chorus`) -> Iron Hide Stance (hits taken now feed stacks inside a form, not a counter).
- Writ of Reckoning (`writ-of-reckoning`) -> Sundering Wedge (curse pattern on Sundered; the Withering anti-healer
  job is dropped here and should live in a Wood or soul curse art).
- Left as they are: Through the Mountain, Last Stitch, Ledger Reckoning (conditional payoffs), Quench, Lustral Bell.
- Shapes not used here (echo, conversion, delay/Slowed Time, shields as weapon) are left to other families.

## Engine gaps
- **Held payloads ignore `filter`.** `fire_event` banks a `held` Effect on every matching event without
  checking `filter`, so Sheathed Edge banks on any crit, not only Metal crits, and the spend cannot be limited
  to a tag. Missing piece: filter check in `bank` / `spend_banked`.
- **Art Effects are build-wide, not art-scoped.** An Effect on an art is live whenever the art is equipped, not
  only while it fires; Whetstone and Sheathed Edge work as passives of the art slot. Scoped only through `filter` tags.
- **Stances cannot suppress by tag**, only by art id (Iron Hide suppresses one named art).
- **Negative `art_speed` in a state** is assumed to be accepted as a plain mod; the lint only checks key names.
- **`needle` per-sub-hit crit and status** (Needle Rain) assumes `split` rolls crit and statuses per sub-hit;
  the lint does not prove it, a run on the engine should.
- **Consume amount is not capped per firing**, so Shatter-Edge Cleave scales without limit on stacks; its
  free hits are only bounded by the trigger budget and cap.

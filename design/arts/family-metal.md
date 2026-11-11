# Metal (Kim) signature arts

8 authored arts in `family-metal.json` (5 engine, 3 standalone), linted: 0 findings. Engine payoffs gated at 3.3-5.9x the
lint. Numbers are first guesses. Commons (Quick Draw Cut, Notch the Foe, Closing Palm, Peg-Line Cut) are untouched.

| Art | Power | Mechanic shape | Hooks | One-line rule | Engine (how to feed it) |
|---|---|---|---|---|---|
| Whetstone Pass (Mài Phong Chưởng) | engine | Timed counter ramp | art speed, crit, temper, quick arts | Each Metal art fired adds a 10 s Temper (+1 Metal crit each, no cap). | Honed Pass (x2.5, +4 buff stacks, spends 3 Temper) at 6 Temper AND (4 foe Metal stacks OR 2 scripture arts in one pulse) |
| Shatter-Edge Cleave (Toái Nhận Trảm) | engine | Build-up then cash-in | foe/own Metal stacks, temper, trigger damage | Heavy cleave; fed, it becomes a x6 Shattering Blow. | x4 blow: break up to 12 foe Metal stacks at 6+ (each 2 = a 0.7 free hit, so more stacks = bigger), OR 5 Temper AND 3 buff stacks, OR 8 buff stacks AND 2 Temper |
| Sheathed Edge (Nhập Sao Nhận) | engine | Held payload ("your next art") | crit, trigger damage, banked cap, low health | Crits bank up to 4 strikes; the next art releases them. | Step 2 (x2): 4 Temper OR 2 Sundered; step 3 (x3.5): 3 Temper AND (3 scripture arts in a pulse OR you at 40 % health) |
| Blood-Quench Blade (Huyết Thối Nhận) | standalone | Paying with health | crit, healing, health-cost reduction, low health | Pays 6 % health, gives 5 buff stacks; crits heal 2 % and add Temper. | Feeds the scripture: buff stacks (Cleave route), Temper, and the low health that opens Sheathed Edge step 3 |
| Needle Rain (Châm Vũ) | standalone | Split hits | crit, on-hit, bleed, split count | 6 needles roll their own crit and Bleed; crit needles lay Metal debuff stacks. | Feeds the canon: its foe stacks open Retinue and Wedge |
| Flying Blade Retinue (Phi Nhận Trận) | engine | Summons | companion speed, summon count, foe stacks | Each firing adds a flying sword that lays Metal debuff stacks. | x3: break up to 12 foe stacks at 4+ (every 3 launches a blade), OR 2 Sundered AND (a canon art within 4 s OR 8 own buff stacks) |
| Sundering Wedge (Liệt Thạch Tiết) | engine | Curse pattern (escalating steps) | curse duration, status application, foe resistance | Lays 2 Sundered; escalates to Exposed, then a x6 break. | Step 2 (x2.5): 2 Sundered OR a canon art within 4 s (Temper route dropped, canon never builds it); step 3 (x4, breaks up to 12 stacks, each 3 a 0.6 hit): 2 Sundered AND (6 foe stacks OR a canon art that pulse) |
| Iron Hide Stance (Thiết Bì Thế) | standalone | Stance / form | resistance, block, hits taken, buff stacks | Toggle: +120 resist, +35 block, no art-speed penalty, Cleave suppressed; hits taken give buff stacks. | Standalone; its buff stacks also pay Cleave and Retinue if built beside them |

## Suite 1: Nine-Temper Scripture (`nine-temper-scripture`)
Whetstone Pass, Shatter-Edge Cleave, Sheathed Edge, Blood-Quench Blade. Temper is the shared counter: Whetstone and
Blood-Quench build it, Cleave and Sheathed Edge spend it, and Whetstone's Honed Pass also rewards firing two scripture
arts together. Blood-Quench's health cost is the low-health route for Sheathed Edge step 3. A crit build turns Temper
into banked strikes; a stack build pays Cleave with foe stacks instead.

## Suite 2: Hundred-Blades Canon (`hundred-blades-canon`)
Needle Rain, Flying Blade Retinue, Sundering Wedge. Needle crits and blade hits lay foe Metal stacks; Wedge makes the foe
Sundered; Retinue and Wedge's last step cash the stacks in (Retinue turns them into more blades). Any two canon arts in
one pulse also open both engines, so a fast-art build needs no stacks at all.

## Replaces
- Thorn Chorus (`thorn-chorus`) -> Iron Hide Stance.
- Writ of Reckoning (`writ-of-reckoning`) -> Sundering Wedge (the Withering anti-healer job is dropped; it belongs in a
  Wood or soul curse art).
- Left as they are: Through the Mountain, Last Stitch, Ledger Reckoning, Quench, Lustral Bell.
- Not used here (echo, conversion, delay/Slowed Time, shields as weapon): left to other families.

## Engine gaps and caveats
- **Held payloads ignore `filter`** (Sheathed Edge banks on any crit, not only Metal). Missing piece: filter check in
  bank / spend.
- **Art Effects are build-wide**, live whenever the art is equipped, not only when it fires.
- **Stances suppress by art id only**, not by tag (Iron Hide names Cleave).
- **Shared counter `temper`** is declared in each art that touches it (identical `{id, each_for: 10}`); a build merging
  them must dedupe. Not tested that a negative `counter.add` floors at 0 (used as the Temper spend).
- **`consume` as a pay** is assumed to take as many stacks as exist up to `n`, doing nothing when there are none;
  routes that don't need the foe's stacks still go through it in Retinue and Wedge step 3.
- **`fired_within.1.group.<g> >= N`** assumes the count includes the art being fired.
- **Per-needle crit and status** in Needle Rain assumes `split` rolls them per sub-hit (as in the first draft).
- Per-firing consume has no cap beyond `n`; free hits are bounded only by the trigger budget.

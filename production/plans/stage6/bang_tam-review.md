# Băng Tâm Các: Stage 6 review (round 1, 2026-11-26)

This round covers what is built (techniques, 6 arts, 5 Effects, items, sets, stand-ins) and what I propose to build
next (four engine words with their GDD text), plus the rulings that block them. Nothing is exported to the game yet.

**How to answer:** for each numbered ruling, pick the option or write your own. For the records, list only what you
want changed; silence means approved. Every record cites its file, and the depth text is the original proposal in
`design/world/depth/sects/bang_tam.*.json`.

## A. Rulings needed (each has my recommendation first)

**ANSWERED 2026-11-26: the user took every recommendation** (recorded in `design/world/depth/DECISIONS-2026-11-26.md`,
"Stage 6, Băng Tâm Các review round 1"). Still open: the GDD text for W1-W4 and the rule 20f amendment, each shown to
the user before it is written. The record list (§C-§G) had no change requests at the time of the rulings.

1. **R1, a formation inside a fight.** Walk the Nodes says "inside your own formation… regains 4 % of its
   strength… cannot be broken"; The Peak Does Not Move says "while your diagram is laid". Neither fight engine has a
   formation's strength. The GDScript fight applies a Set combat diagram (node mods and feeds), but `fight.py` and
   `engine.py` know no diagram at all.
   - **(a), recommended:** read both as your Field stance (`field_up`, for example Lotus Seal Ground). The
     formation's strength becomes your growing ward (W1). This costs nothing new.
   - (b) "Diagram laid" means fighting with a Set diagram, a new readable `own.diagram`. It needs diagrams in the
     Python engine first, a larger piece of work.
2. **R2, Hidden Half** ("your curses on it count as Ice debuffs for your stack effect"). No word exists.
   - **(a), recommended:** while the foe carries one of your curses, your Ice stacks on it count 20 % more (the live
     `stack_more` mod, debuff side).
   - (b) Build a new "curses count as stacks" word, the reverse of `counted_curse_per`.
3. **R3, Ice in the Vessel's out-of-fight half** ("heart-demon odds at a breakthrough fall by a third").
   - **(a), recommended:** a `tam_ma_resist_pct` line on the Vessel, sized so the odds fall by a third.
     `character_rules.gd` already reads it at a breakthrough.
   - (b) A breakthrough Effect of its own.
4. **R4, "freezes for a breath"** (Rime Lotus, Plum Falls on Snow).
   - **Recommended and already used:** stop the foe's clock for 1 s (`stop_clock`, Effects rule 6). There is no new
     Freeze status. Say if you want a real Freeze status instead.
5. **R5, Heart in the Jade Vessel's "while the ward is above half its peak".**
   - **(a), recommended:** W1 includes a peak readable, so the text runs as written.
   - (b) Use half of the 25 % release size instead.
6. **R6, the signature items' own arts.** Item Database rule 20a gives a named item "the arts its role gives (rule 21),
   authored instead of common". The depth items name none: 9 weapons, 4 robes or armours and 1 shield here, about 300
   across the world.
   - **(a), recommended:** they use their base's common art or ward, marked with a rule 21 `exception`. Authored arts
     come only where a story names one. This is how they are promoted now.
   - (b) Author an attack art or ward per piece.
7. **W2 design call: does a reflected soul art still hurt you?** (Clear-Heart Mirror, Clear-Heart Reflection: "reflects
   … back on its caster as Cold damage equal to its own").
   - **(a), recommended:** no. You take nothing, and the caster takes Cold damage equal to what the soul art would have
     done (as `reflect_first` does for a hit).
   - (b) You take it as well.
8. **W3 design call: does the afterimage (Hidden Fragrance) spend the avoid budget** (Combat R6, `avoid_budget` 2 a
   fight, which decoys use)?
   - **(a), recommended:** yes, it is a decoy like the others, and it lays 2 Ice stacks on the striker.
   - (b) No, it is its own avoid.
9. **Promoting another sect's method early: confirm.** Your "yes" covered the whole stand-in table, but
   hang_minh_sa's row was an either/or. I promoted Dạ Quang's `red-sand-sabre-primer` (and its art `cut-the-horse`)
   into `catalogue-sect-da_quang.json` so Băng Tâm's gap can reach zero. The plan now says the headless jobs do the
   same.
   - **(a), recommended:** keep it, but a job may only *add* to another sect's file, and the two parallel jobs never
     run sects that reference each other.
   - (b) Keep a marked stand-in (`wants`) until that sect's own pass.
10. **Red Plum and the other grade 2-3 pieces.** A grade 4 piece is unique (rarity 5); a grade 2-3 one is repeatable
    (rule 20c). With `sources: ["npc"]`, could the world hand a second White Plum to someone else? This needs checking
    in Stage 7.
    - **Recommended:** mark every signature item unique, whatever its grade (a rule 20f amendment).
    - Alternative: leave them repeatable.

## B. Engine words to build next (both engines, parity), with their GDD text

The text goes into the Effects GDD rule 6 (actions and readables) after your approval, section by section as usual.
- **W1, a growing ward.**
  - The action `ward_grow {share, of: "hp" | "base", cap?}` raises your stance ward shield, in shares of your maximum
    health.
  - It has two readables, `own.ward_share` (now) and `own.ward_peak` (the highest this stance).
  - The action `release_ward {dtype, more_per_stack, consume: el}` ends the ward and deals what is left as damage,
    more for each stack it consumes.
  - It fires the existing `ward_absorbed` and `shield_broken` events.
  - It serves Heart in the Jade Vessel, Glacier Bastion, Ice in the Vessel, The Peak Does Not Move, Master's Road and
    Walk the Nodes.
- **W2, a soul reflect.**
  - The mod `soul_reflect` (a count of soul arts to reflect) and the event `soul_taken` (on the defender).
  - It serves Clear-Heart Mirror and Clear-Heart Reflection.
- **W3, an afterimage.** The action `decoy {n}` grants decoys (R6 budget), and the event `decoy_struck` fires on the
  owner. It serves Hidden Fragrance.
- **W4, a live stack duration.** The mod `stack_dur` (percent, element and buff or debuff scope), read when a batch is
  laid. It serves Master's Road ("Ice stacks last twice as long while your ward holds").

## C. Techniques (`design/techniques/catalogue-sect-bang_tam.json`, `catalogue-sect-da_quang.json`)

The depth records name no bonuses or passives. **All bonuses and passives below are mine**, sized against the
catalogue's same-tier techniques and unpriced.

| Technique | Tier, kind | Bonuses | Passives | Arts (unlock layer) |
|---|---|---|---|---|
| clear-frost-breath | Yellow main, Water | none | attack 4 % [cold], art speed 4 % [cold], linh lực regen +6 % | frost-breath-palm (1) |
| jade-vessel-ice-heart-canon | Earth main, Ice + Water | tâm ma resist 12, linh lực 12 % | ward efficiency 10, Ice stack effect 10 %, Ice stack duration 12 %, attack 6 % [cold], status resist 8 | heart-in-the-jade-vessel (1), rime-lotus (2), clear-heart-mirror (4) |
| snow-plum-sword | Profound secret, Ice | attack 8 % | crit 5 [sword], art speed 8 % [sword], Ice stack effect 8 % | five-petals-of-cold (1), hidden-fragrance (2), plum-falls-on-snow (4) |
| frost-lotus-array-canon | Earth secret, Ice + Earth | thần thức 10 %, defence 10 % | Ice stack duration 14 %, ward efficiency 10, curse duration 10 %, formation art cost −8 % | lotus-seal-ground (1), glacier-bastion (2) |
| **warm-hearth-breath (new)** | Yellow main, Earth + Wood + Fire | none | health regen +10 %, khí huyết 4 %, linh lực regen +4 % | warm-hands (1) |
| red-sand-sabre-primer (Dạ Quang) | Yellow main, Fire | none | attack 5 % [fire], art speed 6 % [fire], art cost **+6 %** [fire] ("wasteful of qi") | cut-the-horse (1) |

The new method is the servants' method. Âu Dương Tuyết set it down from what the servants' families did, after the
Primer never took for the washer and her son. It opens no gate.

## D. Arts (`design/arts/part-sect-bang_tam.json`, `part-sect-da_quang.json`)

Built and run in `fight.py` (Kết Đan, typical foe: 20-0 in about 43 s, every art fired, no engine errors).

| Art | Depth text | Engine form | Deviation |
|---|---|---|---|
| frost-breath-palm | light Cold hit that slows the target's next art | Water art, c 1.5, cost 0.03, cd 3; delays the foe's next ready art 0.5 s | none |
| rime-lotus | each petal an Ice stack, the fifth freezes for a breath | 5 sub-hits, each 1 Ice stack (8 s); the fifth petal to land stops the foe's clock 1 s | **the fifth petal is counted across firings** (a missed petal carries over) |
| five-petals-of-cold | five cuts, each 1 Ice stack; the fifth deals Cold scaled by stacks | 5 sub-hits, each 1 stack; the fifth to land adds a Cold hit of 0.05 per Ice stack on the foe | none |
| plum-falls-on-snow | freezes a foe with 5+ Ice stacks for a breath and consumes them | c 2.0; at 5+ stacks: eats all, c 3.5, foe clock stops 1 s | none |
| lotus-seal-ground | a Field; the foe takes Ice stacks each second and its art speed falls | a Field stance that **stays up for the fight**: you cast 10 % slower; each second 1 Ice stack (6 s) and 1 Slowed Time (2 s) on the foe | **no end and no upkeep** (the 10 % slower casting is its cost) |
| warm-hands (new) | n/a | a small heal, c_heal 0.5, cd 5 | new art |
| cut-the-horse (Dạ Quang) | Fire draw-cut, heavy slow, doubled against a foe who is moving | Fire c 1.8, 2 Slowed Time (2 s); ×2 against a **Pressing** foe | **"moving" read as Pressing** (no spatial fight) |

Waiting for W1-W3: heart-in-the-jade-vessel (d18 authored record), clear-heart-mirror, hidden-fragrance,
glacier-bastion.

## E. Effects (`design/world/depth/effects/bang_tam.effects.json`, merged into `assets/data/combat_effects.json`)

Each one was run with and without it in `fight.py`, and each changed the fight.

| Effect (set) | Engine form | Deviation |
|---|---|---|
| The Keeper's Stillness (Regalia) | on `wounded` (first fall to 25 %): foe clock stops 1.5 s, 3 Ice stacks | none |
| Twin Plums (Plums) | a Snow Plum crit lays 1 more Ice stack; every 5th Snow Plum hit that lands strikes again | **"every fifth petal" counts every Snow Plum hit**, and the repeat is a fixed Cold 0.36 (one petal's share) |
| Second Wind on the Ice (Fisher's Three) | first fall to half: 5 % health and 6.25 % linh lực a second for 4 s; the next 5 Snow Plum arts lay 1 more Ice stack | **"cuts" are Snow Plum arts** (firings), not single hits |
| Every Fifth a Star (Clear Glaze) | when the foe reaches 5 of your Ice stacks: your next sword hit is a sure crit with bypass 0.5 | **"ignores the ward" is bypass 0.5**, the engine's cap (marked `approx`) |
| Sitting on the Ice (Fisher's Heirs) | after 2 s Composed: 1.5 % health and linh lực a second; the next sword art lays 2 Ice stacks | none |

Waiting for W1, W2, W4 or rulings: Ice in the Vessel (W1, R3), Clear-Heart Reflection (W2), The Peak Does Not Move
(W1, R1), Walk the Nodes (W1, R1), Master's Road (W1, W4), Hidden Half (R2).

## F. Items and sets (`design/items/catalogue-sect-bang_tam.json`, `sets-bang_tam.json`)

- **23 items, 9 sets**, with modifiers exactly as the depth file has them. Every piece has `sources: ["npc"]`.
  Weapons and armour carry the R6 exception mark.
- In `fight.py` all 9 sets load: five full-set Effects run, and four wait for the words above.

## G. Stand-ins (applied in the cast files)

| Person | Was | Now |
|---|---|---|
| trac_on_tuyen | hoang_thuy | clear-frost-breath, layer 1 |
| giai_tieu_hoa | hoang_hoa | red-sun-scripture, layer 2 |
| dao_han_mac, ma_thao_nhi, quy_to_nga | hoang_tho / hoang_moc | warm-hearth-breath, layers 2 / 1 / 1 |
| hang_minh_sa | huyen_hoa, layer 9 | red-sand-sabre-primer, layer 6 (its top) |

lam_tuyet_dieu now lists her beasts ngoc_dieu and han_tich.

## H. What happens after your answers

Build W1-W4 with the GDD text, write the 4 arts and 6 Effects, and run the gap report (target: only events, beasts
and ties open, which Stage 7's export closes). Then a short round 2 on those records alone, and then Stage 7.

## Round 2 (2026-11-26): the last 4 arts and 6 Effects, decisions auto-accepted (user rule)

The user's rule since 2026-11-26: take the recommended option after thinking it through against the design
philosophy, and log it here. Each one below is logged. Say if any should change.

**Built:**
- W1-W4 in both engines, with parity fixture `t25_stance_ward_exact` exact.
- GDD texts: W1 (c14985d9), W2 (a108d9f3), W3 and rule 20f (bceada72).
- Gap report: **all 11 Effects run**, and all 10 arts and 5 techniques are in the catalogue. What is still open
  (beasts, events, the tie cap, the exports) closes at Stage 7.

| Record | Engine form | Deviation, and why (auto-accepted) |
|---|---|---|
| heart-in-the-jade-vessel (art, d18) | A Composed stance. The ward grows 3 % of health a second; each absorbed hit lays 1 Ice (10 s), 2 while the ward is above half its peak; release at 25 % of health or 10 Ice, all Ice consumed, +4 % per stack | **"Holds your damaging arts" is a fixed list** (the lineage's damaging Ice arts: rime-lotus, five-petals, plum-falls, frost-breath-palm, shatter-palm, rime-lock-seal, black-ice-glaze). The engine's `suppress` takes art ids, and no word holds every damaging art. **The new readable `own.ward_of_peak`** expresses "half its peak" (GDD line extended) |
| clear-heart-mirror (art) | one soul-reflect charge for 6 s | none |
| hidden-fragrance (art) | a small Cold cut (c 0.8, tag `movement`, so it reads as Pressing) and 1 decoy; a struck decoy lays 2 Ice | none |
| glacier-bastion (art) | the ward grows 6 % of health; +1 % a second while your Field is up | "stands inside the seal" is your Field (R1) |
| Ice in the Vessel | while Composed, the ward refills 2 % of its peak a second; the Vessel gains `tam_ma_resist_pct 33` | R3: "a third" is 33 (the resist scales heart-demon gain by 1 − pct/100) |
| Clear-Heart Reflection | one soul-reflect charge for the fight | none |
| The Peak Does Not Move | Field up and Composed: the ward grows 3 % of its peak a second past the peak; after 10 s Composed, 1 % of linh lực a second; when the ward breaks, 4 Ice and Off Guard 1 s on the foe | R1 (the Field). The upkeep is a negative linh lực gain, and it stops below 1 % |
| Walk the Nodes | Field up: every 6 s a 4 % peak refill and 1 Earth buff (20 s); once a fight at 10 Earth buffs, the ward is held 3 s | R1. "Earth guard stack" is an Earth buff |
| Master's Road | while the ward holds, Ice lasts twice as long (`stack_dur` 100) | none |
| Hidden Half | at the foe's 4th Ice stack from you: Heavy Breath 3 s. While the foe is cursed, each Ice grant gives 1 more stack | **R2 refined.** "Count 20 % more" would need `stack_more` on debuffs, which would also change four existing Water and Wood Effects (scoped by element only), or a new key needing live debuff sums in GDScript. `stack_grant` already exists and keeps the intent: curses feed the Ice, with no cap. **The curse is Heavy Breath** (it raises art costs, the Ice debuff's own stat) |

**Fight checks:** `$CLAUDE_JOB_DIR/tmp/run_bt.py`, with the sets loaded from `sets-bang_tam.json`.
- Against a typical foe of their own realm:
  - Sở Ngọc Hồ's kit (Nguyên Anh): 20-0, 24 s, 75 % health left;
  - Cố Lăng Sương's Glacier Vigil and Keeper of the Lid kit (Nguyên Anh): 20-0, 27 s, 100 % left;
  - Phó Ám Hương's Plums with a robe and needle (Kết Đan): 20-0, 15 s.
- Against a typical foe one realm up, all three lose (Vigil after 41 s, out of linh lực).

  Strong, but not unbeatable. That fits "slightly overpowered builds are fine".

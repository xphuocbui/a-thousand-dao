# Đạo Ways: shared rule proposals

> Overnight 2026-11-11. Proposals only, for the user to decide. The 93 Way drafts ask for 87 rule changes and 91
> new keys (`_new-pieces.md`). Most of them are the same few asks repeated from different Ways. This file groups
> them into **15 shared proposals**. Deciding one of them settles every Way that asks for it, and the Ways can then
> be revised to use one rule instead of each having its own.
> Order: most Ways first. "Ways" lists the files that ask.

## R1. Effects that act on the foe's timers

**Asked by:** Thổ (Earthquake), Băng (Frozen Clock, The World Stops), Thời (Time Stands Still, Delay), Chưởng (One
Palm Fells a Mountain), Hồn (Mind Crack), Bỉ Ngạn (Lost Thread), Hóa (Stomp), Mị (Enthral), Tình (Afraid), Nho
(Command), Lôi/Sát (first-art waits), Vực (Heavy Air). **12 Ways.**

**Proposal.** Two Effect actions, owned by the Effects System:
- `delay_timer(target art, seconds)`: pushes one foe art timer back;
- the curse **Slowed Time** (Thời Đạo's): the foe's timers run X % slower per stack (cap 5 stacks).

**Bound.** Delays on one target within 3 s count at half each time (a falling return), so a stack of delay sources
cannot lock a foe. A new defence key `timer_resist_pct`, with counters already drafted (Thổ's Stand Fast, Động Tĩnh's
Heavy Seat, Thể's Hard Frame).

**Trade-off.** Control builds become real. The falling return keeps "the enemy never acts" out of reach. The fight
log has to show the delays.

## R2. A share of a hit that skips ward shields

**Asked by:** Thương (Through the Ward), Chưởng (Internal Injury), Nhân Quả (Karma payout), Hỗn Độn (Before the
Forms), Diệt (Silent Extinction), Vô Cực (Before Taiji), Quang (Radiance), Đao (Sweep, the reverse: damage to
every shield). **8 Ways.**

**Proposal.** A part property `bypass_share`: that share of the part skips ward shields only. It still meets
resistance, block and the body shield. Sources add up, capped at 50 % per hit.

**Trade-off.** It answers ward-stacking tanks, which today are beaten only by Chaos, drain and ticks. It weakens
Combat rule 11's "linh lực is defence" a little, so the cap matters.

## R3. What each shield stops, and shields in pieces

**Asked by:** Ngọc (Unflawed Shell: Chaos), Quang (Halo: Chaos and Soul), Cốt (Skull Ward: Soul; Plates), Thiền
(Diamond Body: Burn and Chaos), Long (Scales by element group), Băng (Eternal Glacier), Thể (Bronze Body: block
twice), Thổ (block on ticks), Phong (evade on ticks). **9 Ways.**

**Proposal.** Give every shield record a `stops` list (types, ticks yes or no) at a share, and let Effects add to
that list. Add an optional `pieces` field: a shield made of N pieces, where one hit breaks at most one piece and each
piece regrows.

**Trade-off.** Chaos (passes body shields) and Soul (passes everything) remain the counters, but they can be
answered at a share. Each such answer should cost something real: the drafts close max health, art speed or ward
strength.

## R4. Arts outside the one slot pool

**Asked by:** Kim (artifact actives), Kỹ (Talisman Sleeve), Vụ and Bỉ Ngạn (escape), Đan (Pill Belt), Hư Thực
(feints), Chưởng (slots for one form), Phân Thân (Many Hands), Trận (formation in the body). **9 Ways.**

**Proposal.** A key `free_slots[kind]`, where kind is one of talisman, artifact_active, escape, pill or feint. Its
total over all sources is capped at +3 per character. The catalogue already lists "Talisman sleeve" and "Art slot,
keep rare".

**Trade-off.** It keeps Combat rule 13's pool as the rule while letting a few Ways bend it, with a hard ceiling.

## R5. Down-step refusals: one budget per fight

**Asked by:** Hỏa (Rise from the Ashes), Sinh Tử (Walk the Threshold), Luân Hồi (Rebirth), Liên (Seed of Rebirth),
Ngọc (Better Broken Jade), Bỉ Ngạn (Red Petals, last act), Hoàng Tuyền (Dying Wish), Sinh Tử (Last Act). **7 Ways.**

**Proposal.** A character can make **one** Down refusal per fight from all sources combined. A capstone that says
"twice" raises it to 2, and nothing goes higher. Last acts are not refusals and are not limited.

**Trade-off.** Without it, a four-Dao life could refuse the Down four times. With it, refusal builds stay distinct
without stacking.

## R6. Avoiding a hit before the defence path

**Asked by:** Ám (Step into Shadow), Sinh Tử (untouchable for 1 s), Huyễn (Decoys), Phân Thân (Images), Thú and
Cốt (the companion takes a share). **5 Ways.**

**Proposal.** An **avoid** step at the head of the defence path, before evade. A decoy or image absorbs a hit, an
untargetable window drops hits, and a companion sink moves a share of the hit. Ticks are never avoided.

**Trade-off.** It is the counter to first-volley builds. It also makes fights harder to read, so the log names
every avoid.

## R7. Self-counters (Fury, Spin, Hunger and the rest)

**Asked by:** Đao (Fury), Vũ (Spin), Phệ (Hunger), Si (Obsession), Cầm (Resonance), Thương (Dragon stacks), Kiếp
(Calamity), Vô Vi (Stillness), Vô Cực (Boundless), Bỉ Ngạn (Petals), Âm Dương (Yin, Yang), Ấn (Seal Marks, on the
foe), Lưu Tinh (Stars), Nhẫn (the store), Điếu (Line Weight). **15 Ways.**

**Proposal.** One generic record, the **self-counter**: id, the event that adds to it, cap, decay rule and what reads
it. Every such counter carries the tag `growing`, so counters to it (Liên's Calming Scent, Cầm's Flute, Thần's
Terrible Face) can read the tag.

**Trade-off.** No rule change, one key family. It turns 15 bespoke counters into data.

## R8. Pre-fight choices

**Asked by:** Thiền (Vows), Kiếp (Trials), Thiên (Rules), Hoàng (Decrees), Hoàng Tuyền (Depth), Ma (Sacrifice),
Thần (Incense), Hồng Trần (Coin), Nho (Inscription), Họa (Scroll), Liên/Ngọc/others (start-of-fight stacks).
**10 Ways.**

**Proposal.** A **preparation choice** record: id, its effects, and the fight situations it is allowed in
(foreseen, ambush, blind). Combat rule 12's situation table already gates preparation, and this extends it to
choices that are not items.

**Trade-off.** UI weight before every fight, which the Advisor can preset. It is a strong place for min-maxing and
costs no in-fight complexity.

## R9. Ground you carry

**Asked by:** Tinh (Array in the Sky), Trận (a formation in the body), Vực (the Domain), Mộng (Dreamscape), Họa
(Landscape), Kỹ (Folding Array), Hoàng and Thủ (fortress places). **8 Ways.**

**Proposal.** **Carried ground**: a ground object brought into fights, whose power is set by the situation
(foreseen 100 %, ambush 70 %, blind 50 %). The Domain is the one carried ground that unfolds mid-fight.

**Trade-off.** It answers "L4 is gone in a blind fight". Keep the multipliers below 1 outside foreseen fights, or
preparation stops mattering.

## R10. Conversion to the least-resisted type

**Asked by:** Thủy (Like Water), Bỉ Ngạn (Flower without Leaves). **2 Ways.**

**Proposal.** Allow `convert_to: least_resisted` as a conversion target, decided when the hit lands. It still uses
one of the 2 conversions.

**Trade-off.** It ruins the resistance matchup on purpose. Keep it to capstones and majors.

## R11. An added Soul part on a non-soul art

**Asked by:** Cầm (Song of Heaven's Pipes), Mị (Fox Fire). **2 Ways.**

**Proposal.** A non-soul art may carry an **added** Soul part, at most 30 % of its damage. That part meets only soul
defence and shares the soul lockout. Converting to Soul stays forbidden.

## R12. Healing and pools as weapons

**Asked by:** Sinh Tử (healing turned to damage while Withered), Âm Dương (pool swap), Thủy (overdraw), Ma (heart
demon as a pool), Xạ (thần thức as a pool), Phệ (thần thức theft). **6 Ways.**

**Proposal.** Treat these one by one. They are each a strong identity. **Recommended:** accept Crossing the Line
(the sustain meta needs a hard counter), heart demon as a pool, and thần thức as a pool. Defer overdraw and the pool
swap.

## R13. Readables and keys the world must supply

World time and season (Tứ Thời, Thái Âm, Quỷ, Tinh). Kill count and win streak (Sát). World Database grudges, oaths,
kindness and debts (Hận, Thệ, Hiếu). Merit, incense and renown in fights (Bồ Đề, Thần, Hiệp). Heart demon and pill
toxicity in fights (Ma, Si, Phệ, Hỏa). Foe tags `demonic`, `ghost`, `undead` (Lôi, Quang, Bồ Đề, Luân Hồi, Trừ
Ma). Character resources: Blood Purity, Dao Heart, Calamity Marks, Soul charges, Tipsiness.

**Proposal.** One Character Stats pass that adds a "life readables" section, and one combat pass that exposes them to
Effects (Combat rule 2 already reads the whole sheet).

## R14. Cap shifts, all flagged

Crit multiplier past its cap (Ám), pierce past its cap (Nghịch, Vượt Cấp), one hit past the L5 cap (Điếu),
`ward_cap` (Thủ), `cooldown_min` (Phong, Thời), `evade_cap` (Phong, Vũ, Huyễn, Tửu, Hóa, Hư Thực), resistance cap
(Kim), `soul_lockout` per art (Hồn, Phân Thân), `crit_chance_cap` (Lôi), `regen_cap` (Thể), `c_comp_cap` (Thú, Độc,
Quỷ).

**Rule from the combat model:** a cap shift is among the strongest things in the game, so make it small, single
and costly. **Recommended:** at most one cap-shift capstone per Way, each with a closing cost that a build feels,
and let the balance harness price them.

## R15. Big design questions (not rules, decisions)

- **Meta progression across lives:** Luân Hồi (Memory of Lives) and Sư (Pass the Lamp). Does a new character
  inherit anything?
- **A fifth Dao:** Phân Thân (The Avatar Walks) against dao.md rule 9.
- **Cull:** Sát (kill below 8 %). A clean finisher, and a hard counter to low-health play.
- **Layer clipping and raising:** Thiên (Heaven Is Impartial), Vô Cực (Return to One). Effects that read and write
  layer totals.
- **The Dream window and the swap:** Mộng. A snapshot of the fight state.

## How to use this

Say yes, no or later to each R. A "yes" becomes a rule in the owning GDD (Combat, Combat Defence, Effects,
Character Stats), and each Way that asked is revised to point at it. A "no" means each Way's piece is cut or
redesigned around the existing rules.

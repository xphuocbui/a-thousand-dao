# NPC Traits — Catalogue

> **Status**: Approved (design-review re-review lean 2026-11-14: 0 blocking, 7 recommended; see `design/gdd/reviews/npc-traits-catalogue-review-log.md`). Earlier: Needs Revision (first review 2026-11-14, both blockers resolved); In Design (started 2026-11-14; NPC Traits Open Question 1)
> **Author**: user + Claude
> **Last Updated**: 2026-11-14
> **Amended 2026-11-25** (user rulings, world-depth pass: `design/world/depth/DECISIONS-2026-11-25.md` groups 1, 5 and 11; proposal `design/world/depth/rules-proposals.md` R6, `traits-v2.md`, `traits-v2.json`): personality rows doubled; 6 of the 10 fate-given traits replaced by talent tiers; **§ Traits v2** adds 80 traits in six new kinds (upbringing, talent, path, lifestyle, health, coping), each with rows, opens, likes and dislikes. Rules: `npc-traits.md` rules 2a, 7a, 8a, 16a and F1b, F3, F4b, F5b, F6b. **Group 12** (2026-11-25): 15 v2 traits gain choice-tag weights (§ Choice-tag weights of v2 traits), and Hunter and One-element devotee get scoped `attack_pct` rows (npc-traits rules 7, 8).
> **Rules**: `design/gdd/npc-traits.md` (approved 2026-11-14). This file is content only: it adds no rule, and where it
> needs one changed it says so under Rule changes this catalogue asks for.

## Summary

Every trait in the game: 37 personality traits in 18 opposed sets, 14 callings, 10 fate-given traits in 5 pairs and
16 gained traits. Each entry gives its stat rows (F1), its choice-tag weights (F2), its regard pulls (F3), its roll
weight (F4) and, where it has them, its sect pulls (Sects F15: personality, callings and six gained traits). `assets/data/traits.json` is built from this
file when the system is implemented. All numbers are **guesses** and are not price-checked until the game is finished.
**Amended 2026-11-25:** personality rows are doubled; 4 fate-given traits stay and 6 are replaced by talent tiers;
§ Traits v2 adds **80 traits**: 12 upbringings, 12 talent families (tiers 1–3), 24 paths, 14 lifestyles, 10 health
and 8 coping traits, each with id, name, Hán-Việt name, meaning, rows, opens, likes and dislikes.

## Conventions

**Stat rows (F1, rules 5–7).** Sizes come from F1 with `P_t = 1.0`. The table holds every stat this catalogue uses, at
both grades:

| Code | Stat | Key | Price (W) | Small (1.2 W) | Notable (8 W) |
|---|---|---|---|---|---|
| H | Maximum health | `khi_huyet_pct` | 0.6 | 2.0 % | 13.3 % |
| E | Evade | `evade_pct` | 1.5 | 0.8 pp | 5.3 pp |
| T | Heart demon resistance | `tam_ma_resist_pct` | 1.5 | 0.8 % | 5.3 % |
| S | Status resistance | `status_resist_pct` | 0.4 | 3.0 pp | 20.0 pp |
| C | Cultivation speed | `cultivation_speed_pct` | 2.2 | 0.5 % | 3.6 % |
| M | Mission income | `mission_income_pct` | 0.7 | 1.7 % | 11.4 % |
| St | Stealth | `stealth` | 1.5 | 0.8 | 5.3 |
| Es | Escape chance | `escape_pct` | 1.0 | 1.2 pp | 8.0 pp |
| Hl | Healing | `healing_pct` | 0.5 | 2.4 % | 16.0 % |
| Ht | Healing taken | `healing_taken_pct` | 0.5 | 2.4 % | 16.0 % |
| Tr | Travel speed | `travel_speed_pct` | 0.3 | 4.0 % | 26.6 % |
| P | Presence | `mi_luc` | 1.0 | 1.20 | 8.00 |
| Q | Qi deviation chance (lower is better) | `qi_deviation_pct` | 1.0 | 1.2 % | 8.0 % |

"−" on a row means the cost direction: a lower value, or for Q a higher chance. Callings, fate-given and gained traits add
their own stats in their sections.

**Personality grade (amended 2026-11-25).** Personality rows use `P_t` 2.0 (npc-traits F1; user ruling, group 5:
"v1 personality rows: doubled"), about 2.4 W a row. On every stat above the doubled row is exactly twice the small
column (H 4.0 %, E 1.6 pp, T 1.6 %, S 6.0 pp, C 1.0 %, M 3.4 %, St 1.6, Es 2.4 pp, Hl 4.8 %, Ht 4.8 %, Tr 8.0 %,
P 2.40, Q 2.4 %), so no row changes its rounding. Callings, fate-given and gained traits keep the small and notable
columns.

**Choice tags (F2).** The interim vocabulary in NPC Traits Core Rules has 20 tags in 10 opposed pairs:

| Tag | Opposite |
|---|---|
| aggressive | merciful |
| greedy | generous |
| deceitful | honest |
| loyal | disloyal |
| cautious | bold |
| vengeful | forgiving |
| devout | pragmatic |
| social | solitary |
| ambitious | humble |
| diligent | indulgent |

Weights use F2's four steps: **2.0** core affinity, **1.5** affinity, **0.67** aversion, **0.5** core aversion ("core"
when the trait is named for, or against, the tag). Each tag is the core affinity of exactly one personality trait, and
the trait opposed to it holds that tag at 0.5. A trait carries at most three weights, at most one of them 2.0. Only
Honest × `deceitful` is `never`, in place of the 0.5 (it matches Sects F15's "Honest never breaks a pact"). Unlisted
pairs are 1.0.

**Regard (F3).** `bias_all` is added to every other person's opinion of the holder; `bias_dir` is added to the holder's
opinion of a named group. Only the traits listed carry one.

**Roll weight (F4).** `b_t` is 1.0 unless the table says otherwise. Archetype and sect leans (`m_arch`, `m_sect`) belong
to NPC Builds (#24) and World Generation (#27); this file does not set them.

## Personality (tính tình): 37 traits in 18 sets

Boon and cost are one row each at the small grade (rule 6), **doubled since 2026-11-25** (the personality grade,
Conventions). Sect pulls are the seed's, unchanged (Sects F15 reads them).

| # | Trait | Boon | Cost | Choice tags | Regard | b_t | Sect pulls (F15) |
|---|---|---|---|---|---|---|---|
| 1 | Brave (dũng mãnh) | H +4.0 % | E −1.6 pp | bold 2.0 · aggressive 1.5 · cautious 0.5 | | | war odds 0.9; weariness +5; rebel odds 0.8 |
| | Cautious (thận trọng) | E +1.6 pp | H −4.0 % | cautious 2.0 · bold 0.5 · aggressive 0.67 | | | war odds 1.2; weariness −10; rebel odds 1.3 |
| 2 | Calm (trầm tĩnh) | Q −2.4 % | S −6.0 pp | aggressive 0.67 · vengeful 0.67 | | | attitude speed ×0.7 after hostile events |
| | Wrathful (nóng nảy) | S +6.0 pp | Q +2.4 % | aggressive 1.5 · cautious 0.67 | | | attitude speed ×1.5 after hostile events; War readiness +1 |
| 3 | Content (an phận) | T +1.6 % | C −1.0 % | humble 1.5 · ambitious 0.5 | | | Expansion −1; rebel odds 1.3 |
| | Ambitious (dã tâm) | C +1.0 % | T −1.6 % | ambitious 2.0 · bold 1.5 · humble 0.67 | | | Expansion +1; head-seat challenge ×3 as an elder; rebel odds 0.8 |
| 4 | Diligent (cần mẫn) | M +3.4 % | Ht −4.8 % | diligent 2.0 · indulgent 0.5 | | | invest share 0.6 |
| | Lazy (biếng nhác) | Ht +4.8 % | M −3.4 % | indulgent 1.5 · diligent 0.5 | | | invest share 0.35 |
| 5 | Forgiving (khoan dung) | Ht +4.8 % | S −6.0 pp | forgiving 2.0 · merciful 1.5 · vengeful 0.5 | | | event fade 20 % |
| | Vengeful (thù dai) | Es +2.4 pp | T −1.6 % | vengeful 2.0 · merciful 0.67 · forgiving 0.5 | | | event fade 0 %, losses ×1.5 |
| 6 | Generous (khoan hậu) | P +2.40 | M −3.4 % | generous 2.0 · greedy 0.5 | | | Tax −1; loyalty +1 |
| | Greedy (tham lam) | M +3.4 % | T −1.6 % | greedy 2.0 · generous 0.5 | | | Tax +1; loyalty −1 |
| 7 | Gregarious (hào sảng) | Tr +8.0 % | St −1.6 | social 2.0 · solitary 0.5 | | | Openness +1; pact line 35 |
| | Reclusive (ẩn dật) | St +1.6 | Tr −8.0 % | solitary 2.0 · social 0.5 | | | Openness −1; Recruitment −1 |
| 8 | Honest (chân thật) | T +1.6 % | St −1.6 | honest 2.0 · deceitful **never** | | | pact keeping: never breaks |
| | Deceitful (gian trá) | St +1.6 | T −1.6 % | deceitful 2.0 · disloyal 1.5 · honest 0.5 | | | pact keeping ×2 to break; betrayal ×2 |
| 9 | Humble (khiêm tốn) | T +1.6 % | P −2.40 | humble 2.0 · ambitious 0.67 | bias_all +5 | | attitude bias +5 from all others |
| | Arrogant (kiêu ngạo) | P +2.40 | T −1.6 % | aggressive 1.5 · ambitious 1.5 · humble 0.5 | bias_all −5 | | attitude bias −5 from all others; war odds 0.9 |
| 10 | Just (công chính) | T +1.6 % | St −1.6 | honest 1.5 · greedy 0.67 · deceitful 0.67 | | | vassal disputes: +2 loyalty to each side |
| | Arbitrary (độc đoán) | St +1.6 | T −1.6 % | pragmatic 1.5 · honest 0.67 | | 0.7 | vassal disputes: +5 to one side, −5 to the other (seeded) |
| 11 | Patient (nhẫn nại) | C +1.0 % | Tr −8.0 % | cautious 1.5 · diligent 1.5 · bold 0.67 | | | weariness +10 |
| | Impatient (nóng vội) | Tr +8.0 % | C −1.0 % | bold 1.5 · cautious 0.67 | | | weariness −10; bold |
| 12 | Temperate (điều độ) | H +4.0 % | P −2.40 | indulgent 0.5 · greedy 0.67 | | | treasury draw 1 × stipend |
| | Indulgent (hưởng lạc) | P +2.40 | H −4.0 % | indulgent 2.0 · diligent 0.67 | | | treasury draw 4 × stipend |
| 13 | Trusting (cả tin) | P +2.40 | Es −2.4 pp | loyal 1.5 · cautious 0.67 | | | pact line 35 for defence pacts |
| | Paranoid (đa nghi) | Es +2.4 pp | P −2.40 | cautious 1.5 · social 0.67 · loyal 0.67 | | | War readiness +1; loyalty −1 |
| 14 | Devout (mộ đạo) | C +1.0 % | M −3.4 % | devout 2.0 · pragmatic 0.5 | bias_dir −10 to the opposite alignment | | alignment factor ×2 |
| | Pragmatic (thực dụng) | M +3.4 % | C −1.0 % | pragmatic 2.0 · devout 0.5 | | | alignment factor ×0 |
| 15 | Stubborn (cố chấp) | S +6.0 pp | Es −2.4 pp | loyal 1.5 · disloyal 0.67 | | | never bold; needs halved |
| | Fickle (thất thường) | Es +2.4 pp | S −6.0 pp | disloyal 1.5 · loyal 0.67 | | | fickle |
| 16 | Compassionate (từ bi) | Hl +4.8 % | M −3.4 % | merciful 2.0 · generous 1.5 · aggressive 0.5 | | | weariness −10 for truce; Recruitment +1 |
| | Callous (lạnh lùng) | T +1.6 % | Hl −4.8 % | pragmatic 1.5 · merciful 0.5 | | | half weariness from losses |
| | Cruel (tàn nhẫn) | S +6.0 pp | P −2.40 | aggressive 2.0 · vengeful 1.5 · merciful 0.5 | bias_dir −10 to rivals | 0.5 | war odds 0.8; raids cost the target ×1.5 production |
| 17 | Warlike (hiếu chiến) | S +6.0 pp | C −1.0 % | bold 1.5 · aggressive 1.5 · merciful 0.67 | | | War readiness +1; duel challenges ×2 |
| | Peaceable (ôn hòa) | C +1.0 % | S −6.0 pp | merciful 1.5 · aggressive 0.5 | | | War readiness −1; duel challenges ×0.5 |
| 18 | Loyal (trung thành) | M +3.4 % | Es −2.4 pp | loyal 2.0 · disloyal 0.5 | | | betraying own sect ×0.25; head-seat challenge ×0.5 |
| | Faithless (bạc nghĩa) | Es +2.4 pp | M −3.4 % | disloyal 2.0 · loyal 0.5 | | | betraying own sect ×2; head-seat challenge ×1.5 |

**Checks on the table**
- Every one of the 20 tags is the core (2.0) of exactly one trait: aggressive Cruel, merciful Compassionate, greedy Greedy,
  generous Generous, deceitful Deceitful, honest Honest, loyal Loyal, disloyal Faithless, cautious Cautious, bold Brave,
  vengeful Vengeful, forgiving Forgiving, devout Devout, pragmatic Pragmatic, social Gregarious, solitary Reclusive,
  ambitious Ambitious, humble Humble, diligent Diligent, indulgent Indulgent.
- The extremes: the strongest stack is three 2.0s on one choice (8.0 before F2's clamp at 5.0); the weakest is three
  0.5s (0.125, clamped to 0.1).
- Boon counts by stat, out of 37: T 5, S 4, C 4, M 4, Es 4, P 4, St 3, H 2, Ht 2, Tr 2, E 1, Hl 1, Q 1 (Calm's lower
  qi deviation). Costs: T 6, M 5, S 4, C 4, P 4, St 3, Es 3, H 2, Tr 2, E 1, Q 1, Ht 1, Hl 1. No stat holds more than a
  seventh of the boons, so no single personality line is the obvious pick.
- The worst stacking case, three traits boosting one stat (say Content, Honest and Humble: T +2.4 %), is three small
  rows, about 3.6 W: below one notable node. **Amended 2026-11-25:** doubled, T +4.8 %, about 7.2 W: still just below
  one notable node (8 W).
- Only Cruel (0.5) and Arbitrary (0.7) are rarer than 1.0, so a world is not full of tyrants. Compassionate's set has
  three members, so without that lean the dark side would come up twice as often as the light one.

## Callings (nghề nghiệp): 14

A calling is the person's lifestyle (rule 2). It has one boon and one cost at the small grade (**not doubled**, 2026-11-25;
npc-traits Open Question 13, answered 2026-11-25: they stay not doubled), like a personality trait,
but its tag weights are only 1.5 or 0.67: the core tags belong to personality. The six seed callings keep their sect
pulls; the eight new ones use only existing pull kinds. New stats used here (rule 7 change below):

| Code | Stat | Key | Price (W) | Small (1.2 W) |
|---|---|---|---|---|
| A | Alchemy success | `alchemy_success` | 2.7 | 0.4 |
| R | Refining success | `refining_success` | 2.0 | 0.6 pp |
| F | Formation power | `formation_power_pct` | 1.0 | 1.2 % |
| Tt | Thần thức | `than_thuc_pct` | 1.3 | 0.9 % |
| Cp | Companion health | `companion_health_pct` | 0.4 | 3.0 % |
| Hg | Herb growth | `herb_growth_pct` | 0.9 | 1.3 % |

| # | Calling | Boon | Cost | Choice tags | Sect pulls (F15) |
|---|---|---|---|---|---|
| 1 | Strategist (binh gia) | Es +1.2 pp | C −0.5 % | ambitious 1.5 · cautious 1.5 | first track Military; war odds 0.9 |
| 2 | Steward (chưởng quỹ) | M +1.7 % | Tr −4.0 % | diligent 1.5 · indulgent 0.67 | first track Holdings; Tax −1 while Thriving |
| 3 | Diplomat (thuyết khách) | P +1.20 | H −2.0 % | social 1.5 · aggressive 0.67 | attitude speed ×1.3 toward friendly targets; pact line 35 |
| 4 | Merchant (thương gia) | Tr +4.0 % | T −0.8 % | greedy 1.5 · pragmatic 1.5 | first track Trade; Openness +1 |
| 5 | Teacher (truyền đạo) | Hl +2.4 % | C −0.5 % | generous 1.5 · solitary 0.67 | first track Institutions; Recruitment +1 |
| 6 | Schemer (mưu sĩ) | St +0.8 | P −1.20 | deceitful 1.5 · honest 0.67 | pact keeping ×2 to break; spying and betrayal against rivals ×2 |
| 7 | Alchemist (đan sư) | A +0.4 | H −2.0 % | cautious 1.5 · diligent 1.5 | first track Institutions |
| 8 | Refiner (luyện khí sư) | R +0.6 pp | C −0.5 % | diligent 1.5 · indulgent 0.67 | first track Military |
| 9 | Formation master (trận sư) | F +1.2 % | Es −1.2 pp | cautious 1.5 · bold 0.67 | first track Military; War readiness +1 |
| 10 | Talisman maker (phù sư) | Tt +0.9 % | E −0.8 pp | devout 1.5 · diligent 1.5 | first track Institutions |
| 11 | Beast tamer (ngự thú sư) | Cp +3.0 % | P −1.20 | merciful 1.5 · social 0.67 | first track Holdings |
| 12 | Herbalist (linh thực sư) | Hg +1.3 % | Tr −4.0 % | diligent 1.5 · aggressive 0.67 | first track Holdings; Expansion −1 |
| 13 | Duelist (đấu sĩ) | E +0.8 pp | T −0.8 % | bold 1.5 · aggressive 1.5 | War readiness +1; duel challenges ×1.5 |
| 14 | Wanderer (du hiệp) | Tr +4.0 % | M −1.7 % | solitary 1.5 · loyal 0.67 | Openness +1; Recruitment −1 |

The Talisman maker's thần thức row stands in until a talisman key goes live (talisman drawing success and talisman power
are Pending in the Stat List); it then moves to that key at the same grade.

**Which callings a path allows (F4 `w_c`).** The roll reads the person's archetype (`world_generation.json`
`archetypes`; NPC Builds owns the final list of paths):

| Archetype | Callings and weights |
|---|---|
| Kiếm tu (sword) | Duelist 6 · Wanderer 3 · Refiner 1 |
| Thể tu (body) | Duelist 6 · Beast tamer 2 · Wanderer 2 |
| Pháp tu (spell) | Duelist 4 · Talisman maker 4 · Teacher 2 |
| Đan sư (alchemy) | Alchemist 6 · Herbalist 3 · Merchant 1 |
| Trận sư (formation) | Formation master 6 · Refiner 3 · Talisman maker 1 |
| Linh thực sư (spirit planter) | Herbalist 6 · Beast tamer 3 · Alchemist 1 |
| Tán tu (loose cultivator) | Wanderer 6 · Merchant 2 · Beast tamer 1 · Schemer 1 |
| Any sect member, in addition | Strategist, Steward, Diplomat, Merchant, Teacher, Schemer: 0.5 each |

So about one sect member in four (3 of 13) holds a leader calling, which gives the sect enough candidates for its elders.
An authored sect head has a fixed calling (World Generation). A sect office does not change a calling by itself; rule 14's
offer does, when an event moves the person into the duty.

## Fate-given (bẩm sinh): 10 traits in 5 pairs (4 kept since 2026-11-25)

**Amended 2026-11-25** (user ruling, group 5: "talent tiers replace the plain gifts; v1 fates that are stories
stay"). The soul pair (Spirit-eyed / Hollow-souled) and the Dao heart pair (Pure-hearted / Demon-seeded) stay as they
are. The fortune, comprehension and root-bone pairs are **retired**: no roll draws them, and a record that holds one
loads as the talent tier named in the table (npc-traits Trait list). Their world prices move to tier 3 of the
replacing family (npc-traits rule 9). The table keeps their v1 rows as the record.

One pair per talent: fortune, comprehension, root bone, soul and Dao heart. All rows are at the **notable** grade (rule 6),
and talent rows are allowed there (rule 7). Each pair follows one pattern:
- The **gift** is one-sided: a notable boon, paid for by the world through event weights (rule 9).
- The **flaw** is a notable cost with a notable boon on another stat, so it nets about zero W. It reads as a life with
  a different shape, not a punishment.

`g_f` follows F4's fortune pattern for every pair: the gift reads `clamp(eff(talent) / 45, 0.25, 3)` and the flaw
`clamp(45 / eff(talent), 0.25, 3)` on its own talent, so a gifted root makes the gift likelier. Extra talents used here:

| Code | Stat | Key | Price (W) | Notable (8 W) |
|---|---|---|---|---|
| Fo | Fortuitous encounter rate | `co_duyen_pct` | 0.3 | 26.6 % |
| Ng | Comprehension | `ngo_tinh` | 5 | 1.60 |
| Cc | Root bone | `can_cot` | 3.0 | 2.66 |
| Th | Soul | `than_hon` | 3.0 | 2.66 |
| Dt | Dao heart | `dao_tam` | 3.0 | 2.66 |

| Pair | Trait | Rows (notable) | World price (event weights) | Choice tags | Regard | g_f reads |
|---|---|---|---|---|---|---|
| Fortune | ~~Heaven-favoured (thiên quyến)~~ **retired → `lucky` 3** | Fo +26.6 % | envy ×1.5 | bold 1.5 | | khi_van |
| | ~~Ill-starred (mệnh khắc)~~ **retired → `unlucky` 3** | Fo −26.6 % · T +5.3 % | | cautious 1.5 | | khi_van (inverse) |
| Comprehension | ~~Wise-born (tuệ căn)~~ **retired → `quick_minded` 3** | Ng +1.60 | envy ×1.5; rival sects poach them as a disciple ×2 | | | ngo_tinh |
| | ~~Dull-witted (độn căn)~~ **retired → `slow_witted` 3** | Ng −1.60 · Dt +2.66 | | humble 1.5 | | ngo_tinh (inverse) |
| Root bone | ~~Iron-boned (thiết cốt)~~ **retired → `sturdy_frame` 3** | Cc +2.66 | duel challenges against them ×1.5 | bold 1.5 | | can_cot |
| | ~~Frail (thể nhược)~~ **retired → `frail_frame` 1** | Cc −2.66 · Ng +1.60 | | cautious 1.5 | | can_cot (inverse) |
| Soul | Spirit-eyed (linh nhãn) | Th +2.66 | soul-devouring hunts against them ×1.5 | | | than_hon |
| | Hollow-souled (hồn khuyết) | Th −2.66 · H +13.3 % | | | | than_hon (inverse) |
| Dao heart | Pure-hearted (xích tử tâm) | Dt +2.66 | deceptions against them ×1.5 | honest 1.5 · deceitful 0.67 | | dao_tam |
| | Demon-seeded (ma chủng) | C +3.6 % · T −5.3 % | | aggressive 1.5 · merciful 0.67 | bias_dir −10 from righteous-aligned people | dao_tam (inverse) |

None of the ten is root-bound, so F4's root-bound clause is unused here. `g_f` reads each talent's value **before** trait rows, so Wise-born does not raise its own odds and Dull-witted does not lower them.

Heaven-favoured and Ill-starred are the values AC-NT-03 already tests (as the v1 record since 2026-11-25). **Kept fates and talent families (2026-11-25):** each kept fate is opposed to the talent family on its talent in the other direction (Spirit-eyed / `thin_soul`, Hollow-souled / `keen_soul`, Pure-hearted / `restless_heart`, Demon-seeded / `steady_heart`) and stacks with the one in the same direction. Demon-seeded is the one flaw whose pair is
cultivation speed against heart demon: it is the "fast but dangerous" birth, and righteous people sense it. Fate-given
traits carry no sect pulls; a leader's sect is shaped by its personality and calling.

## Gained (hậu thiên): 16

Events grant these (rule 11), they fade 40 seasons after the grant or the last trigger (rule 12), and deeds remove them
(rule 13). A **small** gained trait has a boon and a cost, like personality; a **notable** one may be one-sided (rule
6). The trigger id is the event outcome that grants and refreshes it (rule 12); the Event Engine (#23) owns the final ids.
**Targeted** traits store one person id (rule 3).

| # | Trait | Grade | Rows | Choice tags | Regard / target | Opposed | Trigger id | Sect pulls |
|---|---|---|---|---|---|---|---|---|
| 1 | Scarred (chiến thương) | notable | T −5.3 % | cautious 1.5 | | | `near_death` | |
| 2 | Battle-hardened (bách chiến) | small | S +3.0 pp · Ht −2.4 % | bold 1.5 | | Shaken | `war_victory` | War readiness +1 |
| 3 | Shaken (kinh hồn) | small | Es +1.2 pp · S −3.0 pp | cautious 1.5 · bold 0.67 | | Battle-hardened | `rout` | war odds 1.2 |
| 4 | Renowned (thành danh) | small | P +1.20 · St −0.8 | ambitious 1.5 | bias_all +5 | Disgraced | `public_feat` | Recruitment +1 |
| 5 | Disgraced (ô danh) | small | St +0.8 · P −1.20 | humble 1.5 | bias_all −5 | Renowned | `public_shame` | Recruitment −1 |
| 6 | Humbled (khuất phục) | small | T +0.8 % · M −1.7 % | humble 1.5 · ambitious 0.67 | | | `defeated_by_lesser` | |
| 7 | Embittered (oán hận) | small | S +3.0 pp · T −0.8 % | vengeful 1.5 · forgiving 0.67 | | | `betrayed` | event fade 0 % |
| 8 | Grudge (thù hận) | small | E +0.8 pp · T −0.8 % | vengeful 1.5 | target −50 | | `wronged_by_target` | |
| 9 | Lovestruck (si tình) | small | P +1.20 · T −0.8 % | merciful 1.5 | target +50 | | `courtship` | |
| 10 | Grieving (tang thương) | notable | C −3.6 % | solitary 1.5 · aggressive 0.67 | | | `bereaved` | |
| 11 | Sworn sibling (kết nghĩa) | small | Hl +2.4 % · M −1.7 % | loyal 1.5 | target +30 | | `sworn_oath` | |
| 12 | Life-debt (ân cứu mạng) | small | T +0.8 % · Es −1.2 pp | loyal 1.5 · generous 1.5 | target +30 | | `saved_by_target` | |
| 13 | Hunted (bị truy sát) | small | St +0.8 · M −1.7 % | cautious 1.5 · social 0.67 | | | `bounty_posted` | |
| 14 | Enlightened (đốn ngộ) | notable | C +3.6 % | devout 1.5 | | | `epiphany` | |
| 15 | Oath-bound (lập thệ) | small | T +0.8 % · Es −1.2 pp | honest 1.5 · loyal 1.5 · deceitful 0.67 | | | `heart_oath` | pact keeping: never breaks |
| 16 | Demon-tainted (nhiễm ma) | notable | Q +8.0 % | aggressive 1.5 | bias_dir −10 from righteous-aligned people | | `demonic_exposure` | |

Notes:
- **Grudge, Lovestruck, Sworn sibling and Life-debt** are targeted. Rule 3 allows two target ids, so a person can hold, say, a
  grudge and a sworn sibling at once. When Lovestruck's target dies it becomes Grieving (Edge Cases); when another
  targeted trait's target dies, the target term drops to 0 and the trait runs out its expiry (AC-NT-16).
- **Hunted** also raises the Event Engine's ambush weight against the holder ×2 (an event weight, rule 9's world price).
- **Oath-bound** is the heart-demon oath (tâm ma thệ). Breaking it is a deed that removes the trait and grants Disgraced in
  the same outcome.
- **Opposed gained pairs** are Battle-hardened / Shaken and Renowned / Disgraced. A new one replaces its opposite when its
  grade is equal or higher (rule 13); all four are small, so it always does.
- **One-sided notable traits** are Scarred, Grieving and Demon-tainted, which are pure costs, and Enlightened, a pure
  boon whose price is that it fades. They are the only gained traits that can tip a fight-relevant stat by a notable
  amount, and none of them touches a combat row.

## Traits v2 (new, 2026-11-25): 80 traits in six kinds

User ruling (`design/world/depth/DECISIONS-2026-11-25.md` group 1, R6): "approved, all three parts (more kinds, bigger
rows, opens + likes/dislikes)". The entries below are `design/world/depth/traits-v2.json` copied in full; the only
change is one display name (`thin_soul` tier 3, marked). The choice-tag weights added 2026-11-25 are in the JSON's
`tags` field and in their own table below. Rules: `npc-traits.md` rules 2a (kinds and caps), 7 and 7a
(stats allowed, no environment conditions), 8a (opens), 16a (likes and dislikes), Formulas F1b (rows and tiers), F3
(`lk`), F4b (creation roll), F5b (inheritance), F6b (coping, Waning years). All values are **guesses**, unpriced.

**Conventions for v2 entries**
- **Rows** are hand-set plain Modifier System numbers (F or I, never `more`), written with the codes below; a tag scope
  is in brackets (`Ak +6 % [sword]`). They are not computed by F1 and are not bound to one boon and one cost.
- **Talent families** list their talent add and rows per tier; the talent codes add flat to the effective talent
  (Ng comprehension, Cc root bone, Th soul, Kv fortune, Dt Dao heart, P presence).
- **Opens** are hook ids (rule 8a): `event:`, `verb:`, `policy:`, `stance:`, `craft:`. Inert until their consumer has a
  record for the id.
- **Likes / dislikes** name v2 ids (in code font) or v1 names (plain). F3 adds 5 per liked trait the other person
  holds and subtracts 10 per disliked one.
- ~~**No choice-tag weights**~~ **Choice-tag weights on 15 behaviour-shaping traits only** (amended 2026-11-25,
  ruling group 12; § Choice-tag weights of v2 traits); talents, health and the rest carry none. **No sect pulls**
  other than `policy:` hooks, **no roll weights** other than F4b's.
- **No environment conditions** (rule 7a). Where a meaning mentions weather, season or place (Old wound "aches before
  rain", Lingering poison "flares in the cold months", Array-bound "strong inside it, weak far from it"), it is flavour:
  the rows are the same everywhere and always.

**Stats the v2 rows add** (the codes in Conventions and in the Callings and Fate-given tables are reused; status from
`modifiers.md`, all Live or Designed, none rare or Pending, except Hunter's foe scope `creature` (below)):

| Code | Stat | Key | Price (W) | Status |
|---|---|---|---|---|
| Ak | Damage, increased | `attack_pct` (unscoped, or a type, form, foe or own-element scope) | 1.0 (family scope 0.67) | Live (unscoped); Designed (scoped); the foe scope `creature` is Pending (Hunter only) |
| Cr | Crit chance | `crit_chance_pct` | 1.0 | Designed |
| As | Art speed | `art_speed_pct` | 0.6 | Designed |
| Ac | Accuracy | `accuracy_pct` | 0.5 | Designed |
| Df | Ward strength | `defense_pct` | 1.0 | Live |
| Lh | Health leech | `leech_health_pct` | 0.21 | Designed |
| Sr | Soul resistance | `soul_res_pct` | 0.6 | Designed |
| L | Maximum linh lực | `linh_luc_pct` | 1.0 | Live |
| Lr | Linh lực regeneration, increased | `linh_luc_regen_inc_pct` | 0.8 | Designed |
| Bt | Breakthrough chance | `breakthrough_chance` | 5 | Live |
| Dd | Pill toxicity resistance | `dan_doc_resist_pct` | 1.6 | Live |
| Kv | Fortune (talent) | `khi_van` | 5 | Live |

**Two scoped rows (amended 2026-11-25,** ruling group 12; npc-traits rule 7, Open Questions 12 and 22). Hunter's row
is `Ak +2 % [creature]`, the **foe** tag (was the form tag `beast`): `creature` is Pending, so the row is inert until
Combat stamps it on profiles; it is the one Pending scope the catalogue allows. One-element devotee's row is
`Ak +6 % [own_top_element]` (was `Ea +6 %`, which targeted the holder's artifacts): the scope is resolved at compile to
the holder's highest-purity base element (ties in the order Kim, Mộc, Thủy, Hỏa, Thổ; none for a root without a base
element). +6 is a guess, the size of Sword heart's scoped row: 6 · 1.0 · 2/3 = 4.0 W, below the old 7.8 W.

**Opposed v2 traits** (rule 2a): each talent gift and the flaw on the same talent (`quick_minded` / `slow_witted`,
`sturdy_frame` / `frail_frame`, `keen_soul` / `thin_soul`, `comely` / `homely`, `lucky` / `unlucky`, `steady_heart` /
`restless_heart`); each talent family and the kept fate on its talent in the other direction (Fate-given section);
and three path pairs, `perfect_foundation` / `flawed_foundation`, `demonic_path` / `buddhist_path`, `frost_veined` /
`fire_tempered`.

**Root bonds for the path roll** (F4b): `frost_veined` needs Water or Ice, `fire_tempered` Fire, `thunder_struck`
Fire and Metal or Thunder, `pure_root_devotee` a single-element root. Authored people are not bound by them.

**World prices** (rule 9): `lucky` 3 envy ×1.5; `quick_minded` 3 envy ×1.5 and poached as a disciple ×2;
`sturdy_frame` 3 duel challenges against them ×1.5 (moved from the retired gifts).

### Upbringing (xuất thân): 12 (new, 2026-11-25)

**Exactly 1** per person, set at creation and fixed for life (rule 2a).

| # | id | Trait | Meaning | Rows | Opens | Likes | Dislikes |
|---|---|---|---|---|---|---|---|
| 1 | `sect_raised` | Sect-raised (tông môn dưỡng) | Taken in as a child; the sect is the only home they know. | C +3 % | `event:sect_loyalty_test`, `policy:tradition` | `sect_raised`, Loyal | Faithless, `street_orphan` |
| 2 | `clan_heir` | Clan heir (thế gia tử) | Born into a cultivating clan; resources early, duties always. | Kv +3 | `event:clan_summons`, `verb:invoke_clan` | `clan_heir` | `street_orphan` |
| 3 | `mortal_noble` | Mortal noble (quý tộc phàm trần) | A lord's or official's child; knows courts, rents and servants. | M +6 % · P +3 | `event:mortal_court`, `verb:command_mortals` | `mortal_noble`, `scholar_family` |  |
| 4 | `scholar_family` | Scholar's child (thư hương môn đệ) | Grew up among books and examinations; reads old script. | Tt +4 % | `event:ancient_text`, `craft:formations` | `scholar_family`, `calligrapher`, `poet` | Arbitrary |
| 5 | `street_orphan` | Street orphan (cô nhi đầu đường) | Survived alone in a city's gutters; trusts no one, misses nothing. | Es +4 pp · St +3 | `event:underworld_contact`, `stance:dirty_fighting` | `street_orphan` | `clan_heir`, `mortal_noble` |
| 6 | `village_born` | Village-born (thôn dã) | Farm or fishing folk; plain, hardy, close to the land. | Hg +5 % · H +2 % | `event:village_plea` | `village_born`, Humble | Arrogant |
| 7 | `merchant_child` | Merchant's child (thương gia tử) | Raised behind a counter; counts in their sleep. | M +8 % | `verb:haggle`, `policy:trade` | `merchant_child`, Merchant |  |
| 8 | `temple_raised` | Temple-raised (tự viện dưỡng) | Grew up in a monastery or shrine; rites and fasting are second nature. | T +6 % | `event:rite`, `verb:counsel` | `temple_raised`, Devout, Temperate | Indulgent, `demonic_path` |
| 9 | `wild_raised` | Wild-raised (sơn dã) | Raised by hunters or beasts in the wilds; reads tracks before letters. | Cp +6 % · Tr +4 % | `event:beast_sign`, `craft:beasts` | `wild_raised`, `hunter` |  |
| 10 | `war_orphan` | War orphan (chiến loạn cô nhi) | Lost their family to a sect war; remembers whose banner it was. | Ak +2 % | `event:old_war_grudge` | `war_orphan` | Warlike, Cruel |
| 11 | `servant_born` | Servant-born (nô bộc xuất thân) | Born to the sect's servants; rose from sweeping halls. | C +2 % · Es +2 pp | `event:servants_whisper` | `servant_born`, Humble | Arrogant, `clan_heir` |
| 12 | `hermit_taught` | Hermit-taught (ẩn sĩ truyền) | Taught alone by a recluse in the mountains; odd habits, deep roots. | T +4 % · Tt +3 % | `event:hermit_returns` | Reclusive, `hermit_taught` | Gregarious |

### Talent (thiên phú bẩm sinh): 12 families, tiers 1-3 (new, 2026-11-25)

**0-2** per person (an authored tier-A person 1-3; rule 2a). Each family is a gift or a flaw on one talent. A tier
adds **±6 / ±12 / ±20** flat to that talent's effective value (Formulas F1b) and, where listed, a stat row. The family
is named by its tier names, tier 1 / 2 / 3. Gift and flaw of the same talent are opposed (never held together).

| # | id | Family (tier 1 / 2 / 3) | Meaning | Tier 1 | Tier 2 | Tier 3 | Opens | Likes | Dislikes | Replaces (v1, rule 2) |
|---|---|---|---|---|---|---|---|---|---|---|
| 1 | `quick_minded` | Quick-minded / Brilliant / Genius (thông tuệ / tuệ căn / thiên tài) | Comprehension (ngộ tính) gift. | Ng +6 | Ng +12 · C +3 % | Ng +20 · C +6 % | `event:insight_flash` | `quick_minded` | `slow_witted` | Wise-born → tier 3 |
| 2 | `slow_witted` | Slow / Dim / Dull-witted (trì độn / ngu muội / đần độn) | Comprehension flaw. | Ng −6 | Ng −12 | Ng −20 · C −4 % |  |  |  | Dull-witted → tier 3 |
| 3 | `sturdy_frame` | Sturdy / Robust / Iron-framed (tráng kiện / cường tráng / thiết cốt) | Bone and body (căn cốt) gift. | Cc +6 | Cc +12 · H +4 % | Cc +20 · H +8 % | `craft:body` |  |  | Iron-boned → tier 3 |
| 4 | `frail_frame` | Frail / Sickly / Broken-framed (yếu ớt / bệnh nhược / phế cốt) | Bone and body flaw. | Cc −6 | Cc −12 · H −4 % | Cc −20 · H −8 % |  |  |  | Frail → tier 1 |
| 5 | `keen_soul` | Keen / Deep / Vast-souled (linh mẫn / thâm hồn / hải hồn) | Soul (thần hồn) gift: senses far, resists the soul arts. | Th +6 | Th +12 · Sr +6 pp | Th +20 · Sr +12 pp · Tt +6 % | `event:sense_hidden` |  |  |  |
| 6 | `thin_soul` | Thin / Clouded / Empty-souled (hồn bạc / hồn mê / hồn rỗng) (tier-3 name changed from "Hollow-souled", which is the kept v1 fate) | Soul flaw. | Th −6 | Th −12 | Th −20 · Sr −10 pp |  |  |  |  |
| 7 | `comely` | Comely / Beautiful / Peerless (thanh tú / mỹ mạo / khuynh thành) | Charm (mị lực) gift. | P +6 | P +12 | P +20 | `verb:charm`, `event:suitors` |  |  |  |
| 8 | `homely` | Plain / Homely / Scarred-faced (tầm thường / xấu xí / mặt sẹo) | Charm flaw. | P −6 | P −12 | P −20 |  |  |  |  |
| 9 | `lucky` | Lucky / Blessed / Fate-touched (hữu phúc / phúc hậu / mệnh quý) | Fortune (khí vận) gift; tier 3 overlaps v1 Heaven-favoured and replaces it for new records. | Kv +6 | Kv +12 · Fo +6 % | Kv +20 · Fo +14 % | `event:chance_meeting` |  |  | Heaven-favoured → tier 3 |
| 10 | `unlucky` | Unlucky / Ill-fated / Star-cursed (bạc phúc / mệnh khổ / tinh sát) | Fortune flaw; tier 3 overlaps v1 Ill-starred. | Kv −6 | Kv −12 | Kv −20 · Fo −12 % | `event:misfortune` |  |  | Ill-starred → tier 3 |
| 11 | `steady_heart` | Steady / Unshaken / Dao-hearted (tâm định / tâm kiên / đạo tâm) | Dao heart (đạo tâm) gift: resists heart demons, holds through bottlenecks. | Dt +6 | Dt +12 · T +6 % | Dt +20 · T +12 % | `event:heart_demon_resist` | `steady_heart` |  |  |
| 12 | `restless_heart` | Restless / Wavering / Heart-cracked (tâm loạn / tâm dao / tâm liệt) | Dao heart flaw. | Dt −6 | Dt −12 · T −6 % | Dt −20 · T −12 % · Q +4 % |  |  |  |  |

### Path (tu hành): 24 (new, 2026-11-25)

**0-2** per person: what cultivation has made them. Granted by an event outcome, a technique or a deed (rule 2a);
permanent until a deed removes it. Rows are sized at about a third of a Profound technique's 16 W combat passive
budget (Cultivation Techniques), so a path shows on the fight sheet.

| # | id | Trait | Meaning | Rows | Opens | Likes | Dislikes |
|---|---|---|---|---|---|---|---|
| 1 | `sword_heart` | Sword heart (kiếm tâm) | Has become one with the sword; thinks in cuts. | Ak +6 % [sword] · Cr +3 pp | `stance:sword_intent`, `event:sword_challenge` | `sword_heart` |  |
| 2 | `pill_fed` | Pill-fed (đan dược đôi) | Rose on pills more than on work; fast, but the foundation is loose. | C +5 % · Q +3 % | `event:pill_debt` |  | `perfect_foundation` |
| 3 | `perfect_foundation` | Flawless foundation (hoàn mỹ đạo cơ) | Built every stage without a crack; slow and sure. | Bt +3 pp · L +4 % | `event:envied_foundation` | `perfect_foundation`, Patient | `pill_fed` |
| 4 | `flawed_foundation` | Cracked foundation (đạo cơ hữu tì) | A rushed or damaged stage left a crack that every breakthrough tests. | Bt −3 pp | `event:seek_mending` |  |  |
| 5 | `body_tempered` | Body-tempered (luyện thể) | Has tempered flesh and bone as hard as the art; takes blows others die of. | H +6 % · Df +4 % | `stance:take_the_blow` | `body_tempered` |  |
| 6 | `formation_mind` | Array mind (trận tâm) | Sees the world as lines and nodes; lays arrays without thinking. | F +8 % | `craft:formations`, `event:array_puzzle` | `formation_mind`, Formation master |  |
| 7 | `beast_bonded` | Beast-bonded (thú khế) | Shares a life-bond with a spirit beast; feels its hurt. | Cp +12 % | `craft:beasts`, `event:beast_bond` | Beast tamer, `wild_raised` |  |
| 8 | `frost_veined` | Frost-veined (băng mạch) | Ice has entered the meridians; cold to the touch, slow to bleed, slow to warm to anyone. | Ak +5 % [cold] · Dd +6 % · P −3 | `event:cold_presence` | `frost_veined` | `fire_tempered` |
| 9 | `fire_tempered` | Fire-tempered (hỏa luyện) | Fire runs hot in them: quick temper, quick pulse, quick hand. | Ak +5 % [fire] · As +3 % | `event:temper_flare` | `fire_tempered` | `frost_veined` |
| 10 | `thunder_struck` | Lightning-scarred (lôi kích) | Survived a lightning strike or a failed tribulation wave; it still hums in them. | Ak +5 % [lightning] · S +4 pp | `event:tribulation_echo` | `tribulation_survivor` |  |
| 11 | `poison_proof` | Poison-proofed (bách độc bất xâm) | Ate poisons for years to build a tolerance; poison is their tool too. | Dd +12 % · S +4 pp | `craft:poison`, `event:poisoned_cup` |  | `temple_raised` |
| 12 | `deviation_survivor` | Deviation survivor (tẩu hỏa dư sinh) | Went through a qi deviation and lived; knows the edge from inside. | Q −4 % · T +3 % | `verb:counsel_deviation` |  |  |
| 13 | `heart_demon_victor` | Heart-demon victor (trảm tâm ma) | Slew their own heart demon at a breakthrough; calm where others break. | T +10 % | `event:heart_demon_resist` | `steady_heart` |  |
| 14 | `long_seclusion` | Long-secluded (bế quan lâu năm) | Spent decades in closed-door cultivation; deep, out of date, awkward. | C +4 % · P −4 | `event:emerges_from_seclusion` | Reclusive | Gregarious |
| 15 | `dual_cultivator` | Dual cultivator (song tu) | Cultivates with a Dao partner; each one's progress feeds the other. | C +4 % | `verb:propose_dual_cultivation`, `event:partner_in_danger` | `dual_cultivator` | Temperate |
| 16 | `demonic_path` | Demonic path (ma đạo) | Cultivates by blood, souls or stolen qi; strong fast, hunted always. | Ak +6 % · Lh +3 % · T −6 % | `event:righteous_hunt`, `verb:tempt` | `demonic_path` | `temple_raised`, Just, Devout |
| 17 | `buddhist_path` | Buddha's path (phật tu) | Cultivates by vows, abstinence and merit; slow to anger, terrible when roused. | T +8 % · Hl +4 % | `verb:exhort`, `event:vow_tested` | `temple_raised`, Compassionate | `demonic_path`, Cruel |
| 18 | `tribulation_survivor` | Tribulation survivor (độ kiếp dư sinh) | Faced heaven's lightning and lived (crossing a great gate or surviving a failed wave). | H +4 % · S +4 pp | `event:tribulation_echo` | `thunder_struck` |  |
| 19 | `bloodline_awakened` | Awakened bloodline (huyết mạch thức tỉnh) | An ancestor's beast or immortal blood has woken in them. | H +5 % · Ak +3 % | `event:bloodline_call` | `clan_heir` |  |
| 20 | `reborn_soul` | Reborn soul (chuyển thế) | Carries memories of a past life (the world's rebirths); sometimes a stranger looks out of their eyes. | Tt +6 % · C +3 % | `event:past_life_memory` |  |  |
| 21 | `pure_root_devotee` | One-element devotee (đơn hệ chuyên tu) | Has cultivated a single element to the exclusion of all else. | Ak +6 % [own_top_element] | `event:element_shrine` | `pure_root_devotee` |  |
| 22 | `array_bound` | Array-bound (trận khế) | Bound to a sect's great array as its keeper; strong inside it, weak far from it. | F +10 % · Tr −6 % | `event:array_breach` | `formation_mind` |  |
| 23 | `pill_master_tongue` | Pill-taster (thường đan thiệt) | Tastes a pill's flaws on the tongue; has eaten thousands. | A +4 · Dd +6 % | `craft:alchemy` | Alchemist |  |
| 24 | `forge_scarred` | Forge-scarred (lò luyện thương) | Hands burned by a thousand smeltings; feels a blade's grain. | R +4 pp | `craft:refining` | Refiner |  |

### Lifestyle (thú vui): 14 (new, 2026-11-25)

**0-1** per person: what they do with their time, a pastime. Not the calling, which is their work (rule 2 calls the
calling "the lifestyle" in that older sense). Drawn at creation or offered by an event; a new one replaces the old
(rule 2a).

| # | id | Trait | Meaning | Rows | Opens | Likes | Dislikes |
|---|---|---|---|---|---|---|---|
| 1 | `tea_master` | Tea master (trà nhân) | Keeps a tea ritual; spirit teas calm the mind. | T +3 % | `verb:share_tea` | `tea_master`, Calm | `drinker` |
| 2 | `poet` | Poet (thi nhân) | Writes verse; their poems travel further than they do. | P +4 | `verb:exchange_poems`, `event:poem_spreads` | `poet`, `scholar_family` |  |
| 3 | `calligrapher` | Calligrapher (thư gia) | Writes a hand that holds intent; talismans come easy. | Tt +3 % | `craft:talismans` | `calligrapher`, Talisman maker |  |
| 4 | `qin_player` | Qin player (cầm sư) | Plays the guqin; their music steadies or unsettles qi. | T +2 % · P +2 | `verb:play_for`, `stance:song` | `qin_player`, `poet` |  |
| 5 | `go_player` | Go player (kỳ thủ) | Plays weiqi; sees ten moves ahead in politics too. | F +3 % | `verb:play_go`, `policy:caution` | `go_player`, Strategist | Impatient |
| 6 | `collector` | Collector (tàng gia) | Hoards rare treasures, manuals or curios; will trade a favour for one. | Fo +3 % | `verb:trade_curio`, `event:rare_find` | `collector` | Generous |
| 7 | `gambler` | Gambler (đổ đồ) | Bets on stones, duels and fates. | Fo +2 % · M −4 % | `verb:wager`, `event:gambling_debt` | `gambler` | Temperate |
| 8 | `hunter` | Hunter (liệp nhân) | Hunts spirit beasts for sport and parts. | Ak +2 % [creature] · Tr +2 % | `event:great_hunt` | `hunter`, `wild_raised` | Compassionate |
| 9 | `gardener` | Gardener (viên đinh) | Tends spirit herbs with love; talks to them. | Hg +8 % | `craft:herbs` | `gardener`, Herbalist |  |
| 10 | `drinker` | Drinker (tửu đồ) | Loves spirit wine more than is wise. | P +2 · C −2 % | `verb:drink_with`, `event:drunken_word` | `drinker`, Gregarious | `tea_master`, Temperate |
| 11 | `chronicler` | Chronicler (sử gia) | Keeps records of the world's affairs; knows every lineage. | Tt +2 % | `verb:ask_history`, `event:old_record` | `scholar_family`, `chronicler` | Deceitful |
| 12 | `duel_seeker` | Duel-seeker (khiêu chiến cuồng) | Travels to fight the strong; collects defeats as gladly as wins. | Ak +2 % | `verb:challenge`, `event:challenger_arrives` | `duel_seeker`, Duelist, Brave | Peaceable |
| 13 | `teacher_at_heart` | Born teacher (hảo vi sư) | Cannot see talent without wanting to shape it. | C +1 % | `verb:take_disciple`, `policy:openness` | Teacher, Diligent | Lazy |
| 14 | `pilgrim` | Pilgrim (hành giả) | Walks to sacred summits and old ruins; never stays long. | Tr +5 % | `event:pilgrim_road` | Wanderer, `pilgrim` |  |

### Health (thương bệnh): 10 (new, 2026-11-25)

**0-1** at creation; an event may add a second (at most 2; `waning_years` takes a slot and, with both full,
replaces the older; rule 2a). Health traits are costs;
they never fade and are removed by a deed (a cure, a mending, a regrown limb).

| # | id | Trait | Meaning | Rows | Opens | Likes | Dislikes |
|---|---|---|---|---|---|---|---|
| 1 | `old_wound` | Old wound (cựu thương) | A wound that never closed properly; aches before rain. | H −4 % | `event:seek_healing` |  |  |
| 2 | `cracked_dantian` | Cracked dantian (đan điền liệt) | The dantian is damaged; linh lực leaks. | L −8 % · C −4 % | `event:seek_mending` |  |  |
| 3 | `meridian_scar` | Scarred meridians (kinh mạch tổn) | Meridians scarred by a deviation or a hostile art; arts come slow. | As −4 % | `event:seek_mending` |  |  |
| 4 | `lingering_poison` | Lingering poison (dư độc) | A poison no one has cured; it flares in the cold months. | H −3 % · S −4 pp | `event:poison_flare`, `event:seek_antidote` |  |  |
| 5 | `cold_toxin` | Cold toxin (hàn độc) | Ice-cold qi lodged in the body (often from a failed Ice art). | Lr −6 % | `event:seek_fire_cure` |  |  |
| 6 | `fire_poison` | Fire poison (hỏa độc) | Pill fire or forge fire turned inward; feverish, irritable. | T −4 % | `event:seek_cold_cure` |  |  |
| 7 | `soul_wound` | Soul wound (thần hồn tổn) | The soul itself is torn; forgets, sees things. | Sr −10 pp · Tt −6 % | `event:soul_mending` |  |  |
| 8 | `maimed` | Maimed (tàn tật) | Lost an arm, a leg or an eye; fights differently now. | E −4 pp | `event:regrow_limb` |  |  |
| 9 | `blind` | Blind (mù lòa) | Sightless; divine sense sees for them. | Ac −4 pp · Tt +6 % |  |  |  |
| 10 | `waning_years` | Waning years (thọ nguyên tương tận) | Near the end of their lifespan; desperate for a breakthrough or a legacy. | H −6 % | `event:last_gamble`, `event:choose_heir` |  |  |

### Coping (ứng phó): 8 (new, 2026-11-25)

**0-1** per person: gained under stress (grief, failure, heart demons). Fades unless its trigger repeats; hardens
after repeats (rule 2a, Formulas F6b).

| # | id | Trait | Meaning | Rows | Opens | Likes | Dislikes |
|---|---|---|---|---|---|---|---|
| 1 | `drowns_in_wine` | Drowns in wine (mượn rượu) | Copes with grief or failure by drinking. | C −3 % | `event:drunken_word` |  |  |
| 2 | `buried_in_seclusion` | Hides in seclusion (trốn bế quan) | Copes by closing the door and refusing the world. | C +2 % · P −4 |  |  |  |
| 3 | `rage_flares` | Rage flares (nộ hỏa công tâm) | Copes by lashing out; a slight becomes a duel. | Ak +2 % · T −4 % | `event:rage_incident` |  |  |
| 4 | `obsessive_training` | Obsessive training (khổ tu cuồng) | Copes by training until they bleed. | C +3 % · Q +3 % |  | Diligent |  |
| 5 | `cold_detachment` | Cold detachment (tâm như chỉ thủy) | Copes by feeling nothing at all; people notice. | T +4 % · P −5 |  |  | Gregarious |
| 6 | `vengeance_vow` | Vow of vengeance (thề báo thù) | Copes by living for one revenge. | Ak +3 % | `event:vengeance_lead` |  |  |
| 7 | `faith_found` | Found faith (quy y) | Copes by turning to a temple's vows. | T +5 % | `event:vow_tested` | `temple_raised` |  |
| 8 | `hoarding` | Hoarding (tích trữ cuồng) | Copes by gathering stones and pills against a disaster that may come. | M +3 % |  |  | Generous |

### Choice-tag weights of v2 traits (new, 2026-11-25)

User ruling (`DECISIONS-2026-11-25.md` group 12): "behaviour-shaping v2 traits get choice-tag weights (paths such as
Demonic and Buddha's path, coping traits, Duel-seeker, Gambler...); talents and health stay stat-only". Rule:
`npc-traits.md` rule 8 and F2, F7. Tags are the interim vocabulary (npc-traits § Interim choice-tag vocabulary). The
scale is the callings' (1.5 affinity, 0.67 aversion, at most three tags): 2.0 and 0.5 stay each personality trait's
core (AC-NTC-02). Values are **guesses**. The same weights are the `tags` field of each entry in `traits-v2.json`.
Every v2 trait not listed carries none (1.0 on every tag).

| Kind | id | Trait | Weights |
|---|---|---|---|
| Path | `demonic_path` | Demonic path (ma đạo) | aggressive 1.5 · ambitious 1.5 · merciful 0.67 |
| Path | `buddhist_path` | Buddha's path (phật tu) | merciful 1.5 · devout 1.5 · aggressive 0.67 |
| Path | `sword_heart` | Sword heart (kiếm tâm) | bold 1.5 · honest 1.5 · deceitful 0.67 |
| Path | `dual_cultivator` | Dual cultivator (song tu) | loyal 1.5 · social 1.5 · solitary 0.67 |
| Lifestyle | `duel_seeker` | Duel-seeker (khiêu chiến cuồng) | bold 1.5 · aggressive 1.5 · cautious 0.67 |
| Lifestyle | `gambler` | Gambler (đổ đồ) | bold 1.5 · greedy 1.5 · cautious 0.67 |
| Lifestyle | `drinker` | Drinker (tửu đồ) | indulgent 1.5 · social 1.5 · diligent 0.67 |
| Coping | `vengeance_vow` | Vow of vengeance (thề báo thù) | vengeful 1.5 · forgiving 0.67 · merciful 0.67 |
| Coping | `rage_flares` | Rage flares (nộ hỏa công tâm) | aggressive 1.5 · cautious 0.67 · forgiving 0.67 |
| Coping | `buried_in_seclusion` | Hides in seclusion (trốn bế quan) | solitary 1.5 · social 0.67 · bold 0.67 |
| Coping | `cold_detachment` | Cold detachment (tâm như chỉ thủy) | pragmatic 1.5 · merciful 0.67 · social 0.67 |
| Coping | `faith_found` | Found faith (quy y) | devout 1.5 · humble 1.5 · indulgent 0.67 |
| Coping | `hoarding` | Hoarding (tích trữ cuồng) | greedy 1.5 · cautious 1.5 · generous 0.67 |
| Upbringing | `street_orphan` | Street orphan (cô nhi đầu đường) | cautious 1.5 · pragmatic 1.5 · loyal 0.67 |
| Upbringing | `war_orphan` | War orphan (chiến loạn cô nhi) | vengeful 1.5 · forgiving 0.67 |

**Example (F2):** "a rival insults you", a Wrathful NPC with Rage flares: retaliate (aggressive, vengeful) 1.5 (Wrathful)
· 1.5 (Rage flares, aggressive) = 2.25; endure (cautious) 0.67 · 0.67 = 0.45; reconcile (merciful) 1.0. Rage flares
counts **with** retaliate in F7 and **against** endure.

### Hooks by consumer (new, 2026-11-25)

The 97 hooks the 80 traits open, grouped by the system that turns them into play (rule 8a). Each needs that system's
record before it shows (npc-traits Open Question 15).

**Verb hooks (19): NPC Interaction & Dialogue (#30), the first consumer to build** (user ruling, group 5). The
**side** says whose trait shows the verb in the player's menu (#30 rule 20: only the player uses the menu): **self**,
the player holds the trait and may use the verb with anyone; **other**, the person the player faces holds it and the
player may ask it of them; **either**, both. Sides are this catalogue's proposal; #30 owns each verb's record
(requirements, score `b_v`, cooldown, time, line keys).

| Verb | Opened by | Side | Reads as |
|---|---|---|---|
| `invoke_clan` | `clan_heir` | self | call on one's clan's name or help |
| `command_mortals` | `mortal_noble` | self | give orders to mortal officials and servants |
| `haggle` | `merchant_child` | self | bargain a better price |
| `charm` | `comely` | self | win someone over by looks and manner |
| `tempt` | `demonic_path` | self | offer a forbidden shortcut |
| `exhort` | `buddhist_path` | self | urge someone to turn from a wrong |
| `propose_dual_cultivation` | `dual_cultivator` | self | propose cultivating together |
| `challenge` | `duel_seeker` | self | challenge someone to a duel |
| `take_disciple` | `teacher_at_heart` | self | offer to take someone as a disciple |
| `counsel` | `temple_raised` | other | ask for counsel |
| `counsel_deviation` | `deviation_survivor` | other | ask how to come back from the edge of a deviation |
| `ask_history` | `chronicler` | other | ask about a lineage or an old affair |
| `share_tea` | `tea_master` | either | share a tea ritual |
| `exchange_poems` | `poet` | either | trade verses |
| `play_for` | `qin_player` | either | play the qin, or ask to be played for |
| `play_go` | `go_player` | either | play a game of weiqi |
| `trade_curio` | `collector` | either | trade a curio for a favour |
| `wager` | `gambler` | either | bet on something |
| `drink_with` | `drinker` | either | drink spirit wine together |

**Policy hooks (4): Sects (#26) F15**, read when the holder leads a sect. Proposed mapping onto existing F15 pull
kinds (a guess; Sects owns it):

| Hook | Opened by | Proposed F15 pull |
|---|---|---|
| `policy:tradition` | `sect_raised` | Openness −1 |
| `policy:trade` | `merchant_child` | first track Trade |
| `policy:caution` | `go_player` | war odds 1.2 |
| `policy:openness` | `teacher_at_heart` | Openness +1 |

**Stance hooks (4): Combat duels** (`design/world/depth/builds/duel-readings.md`): `stance:dirty_fighting`
(`street_orphan`), `stance:sword_intent` (`sword_heart`), `stance:take_the_blow` (`body_tempered`), `stance:song`
(`qin_player`).

**Craft hooks (8 crafts, 10 hooks): the craft systems**: `craft:formations` (`scholar_family`, `formation_mind`),
`craft:beasts` (`wild_raised`, `beast_bonded`), `craft:body` (`sturdy_frame`), `craft:poison` (`poison_proof`),
`craft:alchemy` (`pill_master_tongue`), `craft:refining` (`forge_scarred`), `craft:talismans` (`calligrapher`),
`craft:herbs` (`gardener`).

**Event hooks (54 tags, 60 hooks): the Event Engine (#23)**, as an option's show condition or an event's weight on
the holder. Shared tags: `heart_demon_resist` (`steady_heart`, `heart_demon_victor`), `seek_mending`
(`flawed_foundation`, `cracked_dantian`, `meridian_scar`), `tribulation_echo` (`thunder_struck`,
`tribulation_survivor`), `vow_tested` (`buddhist_path`, `faith_found`), `drunken_word` (`drinker`, `drowns_in_wine`).
Every other tag is opened by the one trait that lists it in the tables above.

### Authored trait sets

The authored cast's trait sets are World Generation's content, not this catalogue's:
`design/world/depth/people/*.cast.json` and `design/world/depth/sects/*.cast.json`, **1,889 people** (171 tier A, mean
9.4 traits; 369 tier B, mean 6.9; 1,349 tier C, mean 5.1), in the citation format of `traits-v2.md` § How content
cites traits, checked by `tools/design/world/depth_check.py`. Their talent tiers run 213 / 144 / 43 (tier 1 / 2 / 3).
Known breaks: npc-traits Edge Cases and Open Question 14.

## Rule changes this catalogue asks for

- **Rule 7 stat list** (user-approved and applied to npc-traits.md 2026-11-14). Added to the stats personality and
  calling rows may use (evade and healing taken, already used by the seed, were listed at the same time):
  - qi deviation chance (`qi_deviation_pct`): Calm and Wrathful;
  - formation power (`formation_power_pct`), a preparation stat, not a combat offence row: Formation master;
  - thần thức (`than_thuc_pct`): Talisman maker, until a talisman key goes live;
  - companion health (`companion_health_pct`): Beast tamer;
  - herb growth (`herb_growth_pct`): Herbalist.

  Rule 7's ban on `attack_pct`, crit and the combat offence rows is unchanged.

- **The provisional list in npc-traits.md.** Done 2026-11-14: the GDD's section is now "Trait list", a pointer to this
  file plus the migration table, so the trait list lives in one place.

- **Roll weights below 1.0** (Cruel 0.5, Arbitrary 0.7). Done 2026-11-14: F4's `b_t` range now reads 0.5–1.0.
- **Rebel odds** (Brave, Ambitious ×0.8; Cautious, Content ×1.3), read by Sects `rebel_odds` (sects.md F8). Done
  2026-11-14: F15 now lists rebel odds as a pull kind and points its trait list at this file.
- **Traits v2 (2026-11-25)**, applied to npc-traits.md the same day under the user's rulings: rule 2 (six fate-given
  traits retired), rule 2a (the six new kinds and their caps), rule 6 (personality `P_t` 2.0; v2 rows
  hand-set), rule 7 (the v2 kinds may use the combat rows and talent keys; the ban stays for the v1 kinds), rule 7a (no
  environment conditions), rule 8a (opens), rule 16a and F3 (likes and dislikes), F1b, F4b, F5b, F6b.
- **Asked of other GDDs (2026-11-25):** the verb records for the 19 verb hooks (NPC Interaction & Dialogue), the 4
  policy mappings and the trait-list counts (Sects F15), the 54 event tags (Event Engine), the 4 stances (Combat
  duels), the 8 craft edges (each craft's GDD).

## Dependencies

- `design/gdd/npc-traits.md`: the rules, F1–F4, rules 5–7 and the tag vocabulary.
- `design/gdd/sects.md` F15: the pull kinds the sect-pull column must stay inside (rebel odds included).
- `design/gdd/modifiers.md`: stat keys and prices. `companion_health_pct` is Designed, not Live.
- Open owners with no GDD yet: Event Engine #23 (trigger ids, tags, world-price events), NPC Builds #24 (`m_arch`), World Generation #27 (`m_sect`), Talismans (Talisman maker's stat).
- **Since 2026-11-25:** `design/world/depth/traits-v2.json` (the authored source of § Traits v2) and `traits-v2.md`;
  `design/gdd/npc-interaction-dialogue.md` (verb hooks, the first consumer); `design/gdd/event-engine.md` (event
  hooks); `design/gdd/sects.md` F15 (policy hooks); `design/world/depth/builds/duel-readings.md` (stances); the craft
  GDDs (craft hooks); `design/gdd/character-stats.md` rule 5 (talent tiers add flat to the effective talent).

## Validation (acceptance criteria for `traits.json`)

Each is a Logic check run against the built `assets/data/traits.json`.

- **AC-NTC-01** Every stat row equals `d · floor(B · 1.0 / (price · u) + 1e-6) · u` for its grade (1.2 or 8) and no row floors to 0.
- **AC-NTC-02** Each of the 20 tags is the 2.0 of exactly one personality trait; no trait has more than three weights or more than one 2.0; the opposite of a tag's core trait holds it at 0.5 (Honest × `deceitful` is `never`).
- **AC-NTC-03** Callings carry only 1.5 or 0.67 weights; each archetype's calling weights sum to 10; all 14 callings are reachable.
- **AC-NTC-04** Every personality and calling trait has exactly one boon and one cost row at the small grade; no row uses `attack_pct`, crit or a combat offence key.
- **AC-NTC-05** Every gained trait has a trigger id; every targeted trait is exactly Grudge, Lovestruck, Sworn sibling or Life-debt; each of the four opposed gained traits names its pair.
- **AC-NTC-06** Every fate-given flaw nets about zero W (its notable cost equals its notable boon within one grid step); talent rows appear only on fate-given or gained traits at the notable grade. *(Amended 2026-11-25: both clauses bind the v1 kinds only; v2 talent tiers and v2 talent-key rows, such as Clan heir's Kv +3, are allowed by npc-traits rule 7.)*
- **AC-NTC-07** Counts: 37 personality in 18 sets, 14 callings, 10 fate-given in 5 pairs, 16 gained.
- **AC-NTC-08** Brave, Ambitious carry rebel odds 0.8 and Cautious, Content 1.3, matching sects.md F8.

**Amended 2026-11-25:** AC-NTC-01 uses `P_t` 2.0 for personality rows (each is exactly twice its v1 value) and 1.0 for
callings, fate-given and gained traits, and binds the v1 kinds only. AC-NTC-04's small grade reads the doubled
personality grade for personality and the small grade for callings. AC-NTC-06 binds only the 4 kept fates (the soul
and Dao heart pairs). AC-NTC-07's counts become 37 personality in 18 sets, 14 callings, **4 kept fate-given in 2 pairs
(6 retired, never drawn)**, 16 gained.

- **AC-NTC-09** *(new, 2026-11-25)* v2 counts: 12 upbringing, 12 talent families with exactly 3 tiers each, 24 path,
  14 lifestyle, 10 health, 8 coping; 80 distinct ids, none equal to a v1 name.
- **AC-NTC-10** *(new)* Every v2 row equals this file's table (parsed back against `traits-v2.json`, 80 of 80 matched
  2026-11-25); every key is Live or Designed in `modifiers.md`, F or I, never `more`; no row has a field besides stat,
  value and scope, and no scope is an environment tag (npc-traits rule 7a). *(2026-11-25:)* the one Pending scope is
  Hunter's foe tag `creature`, and `own_top_element` is a compile-time scope (npc-traits rule 7).
- **AC-NTC-11** *(new)* Talent tiers add exactly ±6 / ±12 / ±20 to one talent key, gifts positive and flaws negative;
  each gift's flaw is named in § Opposed v2 traits; the retired fates map exactly as the Fate-given table says.
- **AC-NTC-12** *(new)* Every likes and dislikes entry resolves to a v2 id or a v1 name (77 likes, 39 dislikes); every
  hook is one of the five kinds; every verb hook has a side in § Hooks by consumer; every policy hook has a proposed
  F15 pull of an existing kind.
- **AC-NTC-13** *(new)* No v2 display name (tier names included) equals a kept v1 name; the only v1 names a v2 tier
  reuses are the retired Dull-witted and Frail, which load as exactly that tier (the `thin_soul` tier-3 rename holds;
  checked 2026-11-25 against `assets/data/traits.json`).
- **AC-NTC-14** *(new, 2026-11-25)* Choice-tag weights: exactly the 15 entries of § Choice-tag weights of v2 traits
  carry `tags` in `traits-v2.json`, each equal to that table; every tag is in the npc-traits vocabulary; every value is
  1.5 or 0.67; no entry has more than three tags; no talent or health entry has any.

## Open items

| # | Item | Owner | Blocks |
|---|---|---|---|
| 1 | Archetype and sect leans (`m_arch`, `m_sect`): which traits each archetype and each sect leans toward | NPC Builds (#24), World Generation (#27) | F4 beyond uniform weights |
| 2 | The trigger ids for gained traits are proposals; the Event Engine (#23) owns the final ids and may merge them | Event Engine | rule 12 refresh |
| 3 | The tag vocabulary is the interim one; if the Event Engine renames tags, every table here follows | Event Engine | F2 |
| 4 | The Talisman maker's thần thức row moves to a talisman key when one goes live | Talismans | — |
| 5 | FX-CAT stays a test catalogue: it differs from this file on purpose (Vengeful × merciful is 0.5 in FX-CAT, 0.67 here), so AC-NT-06 keeps its numbers | qa-lead | — |
| 6 | The world-price event kinds (envy, sought as a disciple, duel challenges, soul hunts, deceptions, ambush) need event templates | Event Engine | rule 9 for fate-given gifts |
| 7 | **Answered 2026-11-25** (ruling group 11): Empty-souled (hồn rỗng) is accepted. ~~**(new, 2026-11-25)** `thin_soul` tier 3 renamed Empty-souled (hồn rỗng) from "Hollow-souled", which the kept v1 fate holds; confirm (npc-traits OQ 10)~~ | user | AC-NTC-13 |
| 8 | **(new, 2026-11-25)** Each consumer's records for the 97 hooks; the verb sides and the policy mappings are proposals here (npc-traits OQ 15) | #30, Sects, Event Engine, Combat, craft GDDs | rule 8a |
| 9 | **Answered 2026-11-25** (ruling group 12): Hunter is `Ak +2 % [creature]` now (inert until the foe tag is live), and One-element devotee `Ak +6 % [own_top_element]` (npc-traits OQ 12, 22). ~~**(new, 2026-11-25)** Hunter's [beast] scope: the form tag now, the foe tag `creature` when it goes live (npc-traits OQ 12)~~ | game-designer | — |
| 10 | ~~**(new, 2026-11-25)** The v2 entries carry no choice-tag weights~~ **Half answered 2026-11-25** (ruling group 12, npc-traits OQ 18): 15 behaviour-shaping v2 entries carry weights (§ Choice-tag weights of v2 traits, AC-NTC-14). **Still open:** v1 traits carry no likes lists (npc-traits OQ 11) | game-designer | F3 |

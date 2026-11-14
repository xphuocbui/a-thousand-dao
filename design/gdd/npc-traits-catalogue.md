# NPC Traits — Catalogue

> **Status**: In Design (started 2026-11-14; NPC Traits Open Question 1)
> **Author**: user + Claude
> **Last Updated**: 2026-11-14
> **Rules**: `design/gdd/npc-traits.md` (approved 2026-11-14). This file is content only: it adds no rule, and where it
> needs one changed it says so under Rule changes this catalogue asks for.

## Summary

Every trait in the game: 37 personality traits in 18 opposed sets, 14 callings, 10 fate-given traits in 5 pairs and
16 gained traits. Each entry gives its stat rows (F1), its choice-tag weights (F2), its regard pulls (F3), its roll
weight (F4) and, for personality and callings, its sect pulls (Sects F15). `assets/data/traits.json` is built from this
file when the system is implemented. All numbers are **guesses** and are not price-checked until the game is finished.

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

Boon and cost are one row each at the small grade (rule 6). Sect pulls are the seed's, unchanged (Sects F15 reads them).

| # | Trait | Boon | Cost | Choice tags | Regard | b_t | Sect pulls (F15) |
|---|---|---|---|---|---|---|---|
| 1 | Brave (dũng mãnh) | H +2.0 % | E −0.8 pp | bold 2.0 · aggressive 1.5 · cautious 0.5 | | | war odds 0.9; weariness +5 |
| | Cautious (thận trọng) | E +0.8 pp | H −2.0 % | cautious 2.0 · bold 0.5 · aggressive 0.67 | | | war odds 1.2; weariness −10 |
| 2 | Calm (trầm tĩnh) | Q −1.2 % | S −3.0 pp | aggressive 0.67 · vengeful 0.67 | | | attitude speed ×0.7 after hostile events |
| | Wrathful (nóng nảy) | S +3.0 pp | Q +1.2 % | aggressive 1.5 · cautious 0.67 | | | attitude speed ×1.5 after hostile events; War readiness +1 |
| 3 | Content (an phận) | T +0.8 % | C −0.5 % | humble 1.5 · ambitious 0.5 | | | Expansion −1 |
| | Ambitious (dã tâm) | C +0.5 % | T −0.8 % | ambitious 2.0 · bold 1.5 · humble 0.67 | | | Expansion +1; head-seat challenge ×3 as an elder |
| 4 | Diligent (cần mẫn) | M +1.7 % | Ht −2.4 % | diligent 2.0 · indulgent 0.5 | | | invest share 0.6 |
| | Lazy (biếng nhác) | Ht +2.4 % | M −1.7 % | indulgent 1.5 · diligent 0.5 | | | invest share 0.35 |
| 5 | Forgiving (khoan dung) | Ht +2.4 % | S −3.0 pp | forgiving 2.0 · merciful 1.5 · vengeful 0.5 | | | event fade 20 % |
| | Vengeful (thù dai) | Es +1.2 pp | T −0.8 % | vengeful 2.0 · merciful 0.67 · forgiving 0.5 | | | event fade 0 %, losses ×1.5 |
| 6 | Generous (khoan hậu) | P +1.20 | M −1.7 % | generous 2.0 · greedy 0.5 | | | Tax −1; loyalty +1 |
| | Greedy (tham lam) | M +1.7 % | T −0.8 % | greedy 2.0 · generous 0.5 | | | Tax +1; loyalty −1 |
| 7 | Gregarious (hào sảng) | Tr +4.0 % | St −0.8 | social 2.0 · solitary 0.5 | | | Openness +1; pact line 35 |
| | Reclusive (ẩn dật) | St +0.8 | Tr −4.0 % | solitary 2.0 · social 0.5 | | | Openness −1; Recruitment −1 |
| 8 | Honest (chân thật) | T +0.8 % | St −0.8 | honest 2.0 · deceitful **never** | | | pact keeping: never breaks |
| | Deceitful (gian trá) | St +0.8 | T −0.8 % | deceitful 2.0 · disloyal 1.5 · honest 0.5 | | | pact keeping ×2 to break; betrayal ×2 |
| 9 | Humble (khiêm tốn) | T +0.8 % | P −1.20 | humble 2.0 · ambitious 0.67 | bias_all +5 | | attitude bias +5 from all others |
| | Arrogant (kiêu ngạo) | P +1.20 | T −0.8 % | aggressive 1.5 · ambitious 1.5 · humble 0.5 | bias_all −5 | | attitude bias −5 from all others; war odds 0.9 |
| 10 | Just (công chính) | T +0.8 % | St −0.8 | honest 1.5 · greedy 0.67 · deceitful 0.67 | | | vassal disputes: +2 loyalty to each side |
| | Arbitrary (độc đoán) | St +0.8 | T −0.8 % | pragmatic 1.5 · honest 0.67 | | 0.7 | vassal disputes: +5 to one side, −5 to the other (seeded) |
| 11 | Patient (nhẫn nại) | C +0.5 % | Tr −4.0 % | cautious 1.5 · diligent 1.5 · bold 0.67 | | | weariness +10 |
| | Impatient (nóng vội) | Tr +4.0 % | C −0.5 % | bold 1.5 · cautious 0.67 | | | weariness −10; bold |
| 12 | Temperate (điều độ) | H +2.0 % | P −1.20 | indulgent 0.5 · greedy 0.67 | | | treasury draw 1 × stipend |
| | Indulgent (hưởng lạc) | P +1.20 | H −2.0 % | indulgent 2.0 · diligent 0.67 | | | treasury draw 4 × stipend |
| 13 | Trusting (cả tin) | P +1.20 | Es −1.2 pp | loyal 1.5 · cautious 0.67 | | | pact line 35 for defence pacts |
| | Paranoid (đa nghi) | Es +1.2 pp | P −1.20 | cautious 1.5 · social 0.67 · loyal 0.67 | | | War readiness +1; loyalty −1 |
| 14 | Devout (mộ đạo) | C +0.5 % | M −1.7 % | devout 2.0 · pragmatic 0.5 | bias_dir −10 to the opposite alignment | | alignment factor ×2 |
| | Pragmatic (thực dụng) | M +1.7 % | C −0.5 % | pragmatic 2.0 · devout 0.5 | | | alignment factor ×0 |
| 15 | Stubborn (cố chấp) | S +3.0 pp | Es −1.2 pp | loyal 1.5 · disloyal 0.67 | | | never bold; needs halved |
| | Fickle (thất thường) | Es +1.2 pp | S −3.0 pp | disloyal 1.5 · loyal 0.67 | | | fickle |
| 16 | Compassionate (từ bi) | Hl +2.4 % | M −1.7 % | merciful 2.0 · generous 1.5 · aggressive 0.5 | | | weariness −10 for truce; Recruitment +1 |
| | Callous (lạnh lùng) | T +0.8 % | Hl −2.4 % | pragmatic 1.5 · merciful 0.5 | | | half weariness from losses |
| | Cruel (tàn nhẫn) | S +3.0 pp | P −1.20 | aggressive 2.0 · vengeful 1.5 · merciful 0.5 | bias_dir −10 to rivals | 0.5 | war odds 0.8; raids cost the target ×1.5 production |
| 17 | Warlike (hiếu chiến) | S +3.0 pp | C −0.5 % | bold 1.5 · aggressive 1.5 · merciful 0.67 | | | War readiness +1; duel challenges ×2 |
| | Peaceable (ôn hòa) | C +0.5 % | S −3.0 pp | merciful 1.5 · aggressive 0.5 | | | War readiness −1; duel challenges ×0.5 |
| 18 | Loyal (trung thành) | M +1.7 % | Es −1.2 pp | loyal 2.0 · disloyal 0.5 | | | betraying own sect ×0.25; head-seat challenge ×0.5 |
| | Faithless (bạc nghĩa) | Es +1.2 pp | M −1.7 % | disloyal 2.0 · loyal 0.5 | | | betraying own sect ×2; head-seat challenge ×1.5 |

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
  rows, about 3.6 W: below one notable node.
- Only Cruel (0.5) and Arbitrary (0.7) are rarer than 1.0, so a world is not full of tyrants. Compassionate's set has
  three members, so without that lean the dark side would come up twice as often as the light one.

## Callings (nghề nghiệp): 14

A calling is the person's lifestyle (rule 2). It has one boon and one cost at the small grade, like a personality trait,
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

## Fate-given (bẩm sinh): 10 traits in 5 pairs

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
| Fortune | Heaven-favoured (thiên quyến) | Fo +26.6 % | envy ×1.5 | bold 1.5 | | khi_van |
| | Ill-starred (mệnh khắc) | Fo −26.6 % · T +5.3 % | | cautious 1.5 | | khi_van (inverse) |
| Comprehension | Wise-born (tuệ căn) | Ng +1.60 | envy ×1.5; sought as a disciple ×2 | | | ngo_tinh |
| | Dull-witted (độn căn) | Ng −1.60 · Dt +2.66 | | humble 1.5 | | ngo_tinh (inverse) |
| Root bone | Iron-boned (thiết cốt) | Cc +2.66 | duel challenges against them ×1.5 | bold 1.5 | | can_cot |
| | Frail (thể nhược) | Cc −2.66 · Ng +1.60 | | cautious 1.5 | | can_cot (inverse) |
| Soul | Spirit-eyed (linh nhãn) | Th +2.66 | soul-devouring hunts against them ×1.5 | | | than_hon |
| | Hollow-souled (hồn khuyết) | Th −2.66 · H +13.3 % | | | | than_hon (inverse) |
| Dao heart | Pure-hearted (xích tử tâm) | Dt +2.66 | deceptions against them ×1.5 | honest 1.5 · deceitful 0.67 | | dao_tam |
| | Demon-seeded (ma chủng) | C +3.6 % · T −5.3 % | | aggressive 1.5 · merciful 0.67 | bias_dir −10 from righteous-aligned people | dao_tam (inverse) |

Heaven-favoured and Ill-starred are the values AC-NT-03 already tests. Demon-seeded is the one flaw whose pair is
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

## Open items

| # | Item | Owner | Blocks |
|---|---|---|---|
| 1 | Archetype and sect leans (`m_arch`, `m_sect`): which traits each archetype and each sect leans toward | NPC Builds (#24), World Generation (#27) | F4 beyond uniform weights |
| 2 | The trigger ids for gained traits are proposals; the Event Engine (#23) owns the final ids and may merge them | Event Engine | rule 12 refresh |
| 3 | The tag vocabulary is the interim one; if the Event Engine renames tags, every table here follows | Event Engine | F2 |
| 4 | The Talisman maker's thần thức row moves to a talisman key when one goes live | Talismans | — |
| 5 | FX-CAT stays a test catalogue: it differs from this file on purpose (Vengeful × merciful is 0.5 in FX-CAT, 0.67 here), so AC-NT-06 keeps its numbers | qa-lead | — |
| 6 | The world-price event kinds (envy, sought as a disciple, duel challenges, soul hunts, deceptions, ambush) need event templates | Event Engine | rule 9 for fate-given gifts |

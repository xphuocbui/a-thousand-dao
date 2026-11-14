# NPC Traits (Tính Cách) — seed

> **Status**: Seed, not designed. Written 2026-11-14 from the Sects GDD (`design/gdd/sects.md` rule 11, Formulas F15),
> at the user's request, so the trait list lives with the system that owns it. NPC Traits (#42) will be authored
> section by section later (`/design-system npc-traits`); this file is its starting point, not its design.
> **Last Updated**: 2026-11-14

## What this seed fixes

- Traits work like the character traits of grand-strategy games (user direction 2026-11-10 and 2026-11-14): personality,
  lifestyle, and fate-given (congenital) traits that decide how NPCs act and lightly affect their stats.
- **Sect leaders and elders** have **3 personality traits** (never both sides of an opposed set) and **1 calling**.
- Sects reads only each trait's **pulls**, of the kinds listed in `design/gdd/sects.md` Formulas F15. Those pull kinds
  are the contract: #42 may rename, add or remove traits, but a trait's sect effect must be expressed in them.

## Not yet decided (for #42)

- Fate-given traits (heaven-favoured, ill-starred...), traits gained from events (scarred, vengeful...), and whether the
  player has traits.
- Stat effects through the Modifier System, as plain modifiers.
- How traits are rolled for ordinary NPCs, inherited or taught, and how NPCs regard shared or opposed traits.
- Event-choice weights beyond the sect pulls, and what the LLM game master reads.
- Cost: traits for about 5,000 cultivators in the season tick and the save.

## Provisional trait list (sect pulls only)

**Personality (3 per leader; never both sides of a set)**

| Trait | Pulls | Opposite | Pulls |
|---|---|---|---|
| Brave (dũng mãnh) | war odds 0.9; weariness +5 | Craven (nhút nhát) | war odds 1.2; weariness −10 |
| Calm (trầm tĩnh) | attitude speed ×0.7 after hostile events | Wrathful (nóng nảy) | attitude speed ×1.5 after hostile events; War readiness +1 |
| Content (an phận) | Expansion −1 | Ambitious (dã tâm) | Expansion +1; event weight: head-seat challenge ×3 as an elder |
| Diligent (cần mẫn) | invest share 0.6 | Lazy (biếng nhác) | invest share 0.35 |
| Forgiving (khoan dung) | event fade 20 % | Vengeful (thù dai) | event fade 0 %, losses ×1.5 |
| Generous (khoan hậu) | Tax −1; loyalty +1 | Greedy (tham lam) | Tax +1; loyalty −1 |
| Gregarious (hào sảng) | Openness +1; pact line 35 | Reclusive (ẩn dật) | Openness −1; Recruitment −1 |
| Honest (chân thật) | pact keeping: never breaks | Deceitful (gian trá) | pact keeping ×2 to break; event weight: betrayal ×2 |
| Humble (khiêm tốn) | attitude bias +5 from all others | Arrogant (kiêu ngạo) | attitude bias −5 from all others; war odds 0.9 |
| Just (công chính) | vassal disputes: +2 loyalty to each side | Arbitrary (độc đoán) | vassal disputes: +5 to one side, −5 to the other (seeded) |
| Patient (nhẫn nại) | weariness +10 | Impatient (nóng vội) | weariness −10; bold |
| Temperate (điều độ) | treasury draw 1 × stipend | Indulgent (hưởng lạc) | treasury draw 4 × stipend |
| Trusting (cả tin) | pact line 35 for defence pacts | Paranoid (đa nghi) | War readiness +1; loyalty −1 |
| Devout (mộ đạo) | alignment factor ×2; attitude bias −10 to the opposite alignment | Pragmatic (thực dụng) | alignment factor ×0 |
| Stubborn (cố chấp) | never bold; needs halved | Fickle (thất thường) | fickle |
| Compassionate (từ bi) | weariness −10 for truce; Recruitment +1 | Callous (lạnh lùng) · Cruel (tàn nhẫn) | Callous: half weariness from losses. Cruel: attitude bias −10 to rivals; war odds 0.8; raids cost the target ×1.5 production |

Compassionate is opposed to both Callous and Cruel; Callous and Cruel may be held together.

**Calling (1 per leader)**

| Calling | Pulls |
|---|---|
| Strategist (binh gia) | first track Military; war odds 0.9 |
| Steward (chưởng quỹ) | first track Holdings; Tax −1 while Thriving |
| Diplomat (thuyết khách) | attitude speed ×1.3 toward friendly targets; pact line 35 |
| Merchant (thương gia) | first track Trade; Openness +1 |
| Teacher (truyền đạo) | first track Institutions; Recruitment +1 |
| Schemer (mưu sĩ) | pact keeping ×2 to break; event weights: spying and betrayal against rivals ×2 |

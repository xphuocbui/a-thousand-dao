# Đạo Ways: combos and risks (a min-maxer's read)

> Overnight 2026-11-11. Observations, not verdicts: nothing here was simulated. A life holds up to **four Daos** (one
> glimpse a realm), so a min-maxer reads the catalogue for pieces that multiply across Ways. This file lists the combos
> that look strongest, the caps that stop them, and the places where nothing stops them yet. The balance harness
> (dao.md Open Question 4) should run the **red** ones first.

## Red: nothing in the rules stops these yet

### 1. Permanent growth from playing the life
Several Ways add **permanent** power earned by play, outside the skill-point economy:

| Way | Piece | Ceiling as drafted |
|---|---|---|
| Kiếp | Calamity Marks (+0.5 % damage and health each, with the capstone) | 60 Marks → +30 % |
| Thệ | Life oaths (+8 % damage each, with the capstone) | 5 oaths → +40 % |
| Sát | Battle Streak (+1 % each) | 50 with the capstone → +50 % |
| Si | Peerless Art Mastery (+1 % damage per Mastery) | 100 with the capstone → +100 % on one art |
| Phệ | Digest (+0.1 % per kill, cap +10 % per realm) | +50 % over five realms |
| Hiệp | Hero's Quests | +15 % |
| Hiếu | Repay Kindness | +20 % with the capstone |
| Tứ Thời, Hồng Trần | seasons lived, decades among mortals | +8 % each (no cap with Wheel of the Year) |

A four-Dao life (for example Kiếp + Thệ + Sát + Si) could carry +100 % or more from these alone, against macro
targets tuned to the point economy (memory: difficulty targets). **Recommendation:** one shared ceiling on
"life-earned permanent bonuses" across all sources (+25 % suggested), or price each one in the harness before
promoting it. Pillar 3 ("Power Is Built, Not Given") holds either way, because all of it is earned. The risk is size,
not kind.

### 2. Resistance shred stacking
Quang's Exposed (−100 to all), Hỗn Độn's Erosion (−60, no cap with Primal Haze), Diệt's stacking Sundered (×3 per
type), Vực's Domain Pressure (−60 to −100), and Thiên Đạo's clipping. Together they can take a 150-point
high-resistance enemy (Combat rule 18) well below 0. **Question for the user:** is there a floor on non-soul
resistance? Soul has "no floor" by design (Combat rule 8). If the other types do not have a floor either, shred
becomes multiplicative damage, and the anti-resistance Ways become the strongest Ways in the game.

### 3. The cost lock
Băng's Ice stacks raise the foe's art cost with no cap (Effects rule 9a). Other Ways and one build add sources:
Vụ's Mist in the Lungs (1 stack every pulse), Âm Dương's Union, Thái Âm's Moonlight, Băng's Absolute Zero (ward
payments too), and the build *dry-well*'s staged **Cold Toll** (the same idea as Absolute Zero, drafted
separately). Against art-heavy enemies, which is most NPCs, the foe stops casting and its wards starve. The counter
exists (cleansing wards; bare-fist builds), but it is narrow. **Recommendation:** keep it, since it is the purest
"build within the rules" engine, but merge Absolute Zero and Cold Toll into one piece and have the harness check how
far Ice-on-ward-payments moves the macro targets.

## Amber: a cap stops it, if the cap holds

### 4. L5 from low health
Nghịch (Against the Current), Hoàng Tuyền (Descend), Diệt (Annihilate), Kiếp (Calamity Qi), Sát (Mutual Ruin),
Bỉ Ngạn (Petals) and Huyết all pay L5 for missing health. **L5's cap of 100** stops the multiplication, so these
compete with each other instead of stacking. That is fine as long as no capstone breaks the cap. Điếu's reel-in does
(+50 over the cap, on one hit), and that one is flagged.

### 5. Companion caps raised by several Ways
Thú (+50 % of `c_comp_cap`), Độc (Gu King, +50 %), Quỷ (counts at 50 %), Phân Thân (two clones as one), Linh Khế
(+20 %). If these multiply, a companion can carry 2–3× its cap. **Recommendation:** a `c_comp_cap` raise does not
stack with another raise; the largest applies.

### 6. Triggers outside `trig_budget`
Tinh's meteor, Bỉ Ngạn's petals, Hoa's capstone, Ti's webs, Họa's finishing stroke, Nhẫn's Last Stand and Thủ's
Shield and Spear all fire outside the trigger budget. The combat model says triggers can never be the main damage.
Hoa's capstone (Beautiful Because It Falls) makes petals the main damage on purpose, at a −40 % cost to the art's own
hits. **Recommendation:** "outside `trig_budget`" is allowed only on once-per-fight or every-N-hits bursts, and on
one capstone that declares a new channel (Hoa's). That capstone is a `Needs rule` for a "petal channel".

### 7. Down refusals
See shared rule R5: one refusal per fight from all sources, or a four-Dao life refuses four times.

### 8. Counted chance
Mệnh's The Heavens Bend counts every chance; Kiếm's Called Blow counts sword crits; Mệnh's Counted Fate counts all
crits. These are the same rule (Effects rule 12) and must not stack into "more than counted". Counted is counted.

## Green: strong, intended, with real counters

- **Stack thieves** (Thâu: steal 5 a hit; Thái Âm: Borrowed Light; Quang: Dispel) crush stack builds (Fire, Wind and
  Earth buffs). That is counterplay (Pillar 3); stack builds answer with Hỏa's Furnace Never Cools or Mộc's Forest
  Outlives Everything.
- **Anti-sustain** (Sinh Tử: Crossing the Line; Sát: Cull; Diệt: Withering riders) is the hard counter the
  sustain-is-king economy needs. Recommended to keep.
- **Feints** (Hư Thực) drain per-hit wards and bait counters, and are useless against a drain ward. A clean matchup
  piece.
- **Decoys and images** (Huyễn, Phân Thân) beat first-volley builds and lose to ticks.

## Which Ways a min-maxer picks first (a guess, to test)

| Pick | Why |
|---|---|
| Băng | The cost lock (item 3) |
| Quang | Exposed uptime makes every other damage piece better |
| Hỗn Độn | Bypass plus erosion (needs the rare root, which limits it) |
| Kiếp | Permanent Calamity Marks (item 1) |
| Thời | `cooldown_min` lower (cap shift) and Rewind |
| Hồn | Per-art soul lockouts (The Body Is a Vessel) turn the soul sniper into a soul machine gun: flag |
| Mệnh | Deterministic crits and evades: reliable, so the min-maxer's favourite |
| Sinh Tử | The anti-sustain answer |

**Ways a min-maxer may never pick:** Hiếu, Sư, Hoàng, Thần, Hồng Trần and Tiêu Dao. They are life-around Ways with
little fight power, which dao.md rule 12 allows ("theme comes before combat value"). The cost is that a glimpse
offering three of them feels like a wasted realm. **Recommendation:** each life-Way keeps at least one capstone
that matters in fights (most drafts have one: Hiệp's Peerless Duelist, Hoàng's All under Heaven, Thần's
Worshipped, Therefore Mighty), and the glimpse offer (Formulas D2) weights fight Ways for characters who fight often.

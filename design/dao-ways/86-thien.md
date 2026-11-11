# 86 · Thiên Đạo · *Thiên Đạo Vô Thân* (Heaven Has No Favourites)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `status_resist_pct`, `defense_pct`, `attack_pct` (lightning, light), `soul_res_pct`,
> `status_duration_pct` (curse), `resist_pct` (all).
> **Road:** `status_resist_pct` +1.

## Build directions

1. **The Equaliser.** Caps on both sides: the foe's biggest numbers are clipped to yours (Công Bằng). The anti-
   outlier build: it does nothing against an ordinary foe and everything against a broken one.
2. **The Lawgiver.** Heaven's Rules: at fight start you set one rule on the foe (no healing, no stacks above 30, no
   arts below 2 s cooldown), and suffer a matching cost yourself. A build that writes the fight's rules.
3. **Heaven's Punishment.** Damage against rule-breakers: demons, forbidden-art users, foes who cheat death
   (refuse a Down), foes with big stacks (Thiên Phạt).
4. **Acting for Heaven.** World-level authority: renown and judgement, punishing NPCs with bad karma.

## Facets

### 1. Thiên Quy (Heaven's Rules)
- **Small:** `status_duration_pct` curse +2 · `defense_pct` +0.6
- **Stat notables:** Edict (Thiên Lệnh): curse duration ×2 · Order (Trật Tự): defense ×2 · Rule of Law (Pháp Trị):
  curse duration +1, status resist +1 · Measured (Chừng Mực): resist all +1
- **Effects:**
  - **Major: Heaven's Rule (Thiên Quy).** Before a fight, choose one Rule from a list; it binds the foe all fight:
    *No Mending* (the foe carries Withering, healing −50 %, reapplied whenever it lapses; fight-long debuff as a
    named curse, R17, duration clamped 1–5 pulses, R22), *Measured Stacks* (the foe's debuff batches expire 1 pulse
    sooner), *Measured Haste* (each foe art that fires has its repeat delayed 0.5 s: `delay_timer`, Effects rule 6,
    R1, falls off within 3 s), *No Refusal* (the foe's one Down refusal is removed, R5). You are bound by the same
    Rule. Pre-fight rule choice (Effects rule 8 / Combat rule 12, R8).
  - Minor: Witnessed (Thiên Chứng). Your Rule's curse lasts 1 pulse longer (clamped 1–5, R22). *(starter)*
  - Minor: Spirit of the Law (Tinh Thần Luật). While the foe carries a curse of yours, your hits deal more (L5 +10).

### 2. Công Bằng (Impartial)
- **Small:** `resist_pct` +1 · `status_resist_pct` +1
- **Stat notables:** Even Scales (Cân Bằng): resist all ×2 · Blind Justice (Công Lý Mù): status resist ×2 · Level Field
  (Sân Phẳng): resist +1, defense +1 · No Favour (Vô Tư): soul resist +2
- **Effects:**
  - **Major: Heaven Is Impartial (Thiên Đạo Vô Thân).** Reads both sides' layer totals (L1 to L5, free to read,
    R15d). For each layer where the foe exceeds yours by more than 30 %, your hits gain L5 +5 (cap +20). The clipping
    itself is the capstone's.
  - Minor: Equal Footing (Ngang Hàng). The foe's crit chance cannot exceed yours by more than 10 pp. *(starter)*
  - Minor: Shared Burden (Cùng Gánh). The foe's buff stacks cannot exceed your own buff stacks by more than 50.

### 3. Thiên Phạt (Heaven's Punishment)
- **Small:** `attack_pct` lightning +1 · `attack_pct` light +1
- **Stat notables:** Smite (Trừng Phạt): lightning ×2 · Judgement Light (Ánh Phán): light ×2 · Heaven's Wrath (Thiên
  Nộ): lightning +1, light +1 · Punisher (Kẻ Trừng): crit damage +2
- **Effects:**
  - **Major: Heaven's Punishment (Thiên Phạt).** Your hits deal more to a foe that breaks heaven's order: per thing it
    does (refuses a Down, pays arts in health, holds 50+ stacks of one kind, uses a forbidden art, carries Corpse Rot),
    L5 +12, cap +48. `Needs key` (forbidden tag).
  - Minor: Lightning for the Wicked (Lôi Cho Kẻ Ác). Your hits apply 2 Thunder debuff stacks for 4 pulses to a foe with a demonic
    tag (foe tags, Character Stats rule 9a, R13). *(starter)*
  - Minor: No Second Chance (Không Cơ Hội Hai). A foe that refused the Down step against you takes 20 % more for the
    rest of the fight.

### 4. Pháp Tắc (Laws)
- **Small:** `defense_pct` +1.2 · `attack_pct` +1
- **Stat notables:** Law of Heaven (Luật Trời): defense ×2 · Law of Earth (Luật Đất): attack ×2 · Codex (Pháp Điển):
  defense +1, attack +1 · Precedent (Tiền Lệ): status resist +2
- **Effects:**
  - **Major: Black-Letter Law (Luật Chữ Đen).** Curses you place on the foe cannot be cleansed during their first 2
    pulses, and they ignore 25 pp of the foe's status resist. `Needs rule` (a cleanse lock; `cleanse_share` is the
    nearest existing constant).
  - Minor: Lawful (Tuân Luật). Curses that name a tag do not apply to you for the first 10 s of a fight. *(starter)*
  - Minor: By the Book (Đúng Luật). +5 % to all stat lines from this Dao while the foe has not yet used its Down refusal.

### 5. Thay Trời (Acting for Heaven)
- **Small:** renown +1 · `attack_pct` +1
- **Stat notables:** Mandate (Thiên Mệnh): renown ×2 · Executioner of Heaven (Đao Phủ Trời): attack ×2 · Upright (Chính
  Trực): status resist +1, attack +1 · Feared Name (Tên Đáng Sợ): renown +1, defense +1
- **Effects:**
  - **Major: Act for Heaven (Thế Thiên Hành Đạo).** Defeating an NPC with a "wicked" trait gives renown, merit and a
    one-season fortune bonus. `Needs key` (NPC traits, index #42).
  - Minor: Heaven's Envoy (Sứ Giả Trời). Sects of righteous alignment give you better prices. *(starter)* `Needs key`.
  - Minor: Judgement Seat (Tòa Phán). In fights you started as a punishment (event flag), your hits deal +10 %.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **You Are the Law in This Fight (Ngã Tức Thiên Pháp)** | keystone | Choose two Rules; the second binds only the foe | Your hits deal 20 % less (L2 −20) | Thiên Quy |
| **Rewrite a Law (Cải Pháp)** | keystone | Before the fight choose one constant (`cooldown_min`, `soul_lockout`, `trigger_depth`, `cleanse_share` or a `stack` cap): it is shifted 10 % in your favour, for you only. This is the Way's one cap shift (Dao rule 4, R14) | Heaven writes one law, and you pay for it: your hits deal 15 % less (L2 −15) | Pháp Tắc |
| **Heaven Has No Favourites (Thiên Địa Bất Nhân)** | keystone | Heaven Is Impartial also clips: each foe layer above your value × 1.1 is clipped (layer write, capstone only, logged; R15d) | Your own layers above the foe's are clipped the same way | Công Bằng |
| **Thunder of Judgement (Phán Lôi)** | keystone | Heaven's Punishment's cap rises to +60 (L5 headroom; L5 total stays capped at 100) | Against a foe that breaks no order, your hits deal 25 % less | Thiên Phạt |

## New pieces

- Pre-fight Rule choice: Effects rule 8 / Combat rule 12 (R8). Clipping the foe's layers: layer write at capstone tier
  (R15d, Thiên named). Rewrite a Law is now Thiên's one cap-shift capstone (R14); the layer write (Heaven Has No Favourites, R15d) is not a cap shift. Black-Letter Law (the freed major) needs a cleanse-lock rule.
- A forbidden-art tag; NPC wicked trait: `Needs key` (NPC Traits #42).

## Kept apart from

Vực Đạo (a domain that rewrites rules inside it, mid-fight; Thiên Đạo binds the whole fight from the start), Trấn
Đạo (silence and prison), Quang's Phán Xét (judgement for curses placed on you). Thiên Đạo is **rules on both
sides, clipping outliers, and punishing the rule-breaker**.

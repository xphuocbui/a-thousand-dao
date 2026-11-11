# 76 · Phân Thân Đạo · *Nhất Khí Hóa Tam* (One Breath, Three Bodies)

> Overnight draft 2026-11-11. Proposal. **Needs:** none.
> **Theme stats:** `than_thuc_pct`, companion damage (clone), `evade_pct`, `attack_pct`, `art_speed_pct`, `linh_luc_pct`.
> **Road:** `than_thuc_pct` +0.9.

## Build directions

1. **The Clone.** A clone of yourself fights as your companion: it fires a copy of one of your arts on its own timer
   (Phân Thân). The "two of me" companion build, with power drawn from thần thức.
2. **Mirror Images.** Evasion from images (Kính Ảnh), kept apart from Huyễn's decoys: images here make the foe's
   hits **split** between you and them.
3. **The Avatar.** A second body that cultivates while you travel (Hóa Thân): life-around cultivation speed.
4. **Shared Mind.** Clone and you share thần thức: soul builds with a clone that fires soul arts in its own lockout
   (Đồng Tâm).
5. **Many Hands.** A rare extra art slot (Thiên Thủ Phân Thân), kept rare.

## Facets

### 1. Phân Thân (Split Self)
- **Small:** companion damage +2 · `than_thuc_pct` +0.5
- **Stat notables:** Second Self (Bản Thể Thứ Hai): companion ×2 · Split Breath (Chia Hơi): thần thức ×2 · Mirror Body
  (Thân Gương): companion +1, thần thức +1 · Same Blood (Cùng Huyết): max health +2
- **Effects:**
  - **Major: Split Self (Phân Thân Thuật).** Your companion may be a Clone: it fires a copy of your first damaging art on that
    art's cooldown × 1.5 (companion hits otherwise follow Combat rule 19), at your stats × its power share (thần thức ratio × 25 %, cap `c_comp_cap`), with no cost.
    `Needs key` (clone companion).
  - Minor: Quick Split (Phân Nhanh). Your Clone's first firing comes at half the cooldown. *(starter)*
  - Minor: Clone Swap (Hoán Thân). Once per fight, swap places with the Clone: the next hit on you is moved to it at the avoid step (it
    drops its share by 10 %; counts in the per-pulse avoid budget; Effects rule 6 avoid, R6).

### 2. Kính Ảnh (Mirror Images)
- **Small:** `evade_pct` +0.4 · `than_thuc_pct` +0.5
- **Stat notables:** Many Mirrors (Nhiều Gương): evade ×2 · Image Mind (Tâm Ảnh): thần thức ×2 · Doubled Shape (Hình Đôi):
  evade +1, thần thức +1 · Glass Body (Thân Kính): soul resist +2
- **Effects:**
  - **Major: Split the Blow (Phân Kích).** Each hit on you is split: 25 % goes to an Image (lost harmlessly) while you
    hold Images (start with 3, one lost per 4 hits, regrow every 6 s). The split is an avoid-step move (Effects rule 6 avoid, R6): it
    counts in the per-pulse avoid budget of 2 and never splits ticks.
  - Minor: Image Start (Ảnh Đầu). You start with 1 extra Image. *(starter)*
  - Minor: Shattered Image (Ảnh Vỡ). When an Image is lost, +5 pp evade for 1 pulse.

### 3. Hóa Thân (an Avatar Body)
- **Small:** `cultivation_speed_pct` +0.4 · `linh_luc_pct` +1.2
- **Stat notables:** Second Seat (Ghế Thứ Hai): cultivation speed +1 · Deep Pool (Hồ Sâu): max linh lực ×2 · Body at
  Home (Thân Ở Nhà): cultivation +0.5, max linh lực +1 · Two Paths (Hai Đường): comprehension +2
- **Effects:**
  - **Major: Avatar (Hóa Thân).** An Avatar sits in seclusion at home while you travel: it gives you 30 % of seclusion's
    cultivation progress during travel seasons (counts within the per-Dao rate cap). `Needs key`.
  - Minor: Avatar Watch (Thân Canh). Your cave dwelling is guarded by your Avatar (events). *(starter)*
  - Minor: Swap Home (Đổi Về). Once a year, swap places with your Avatar (travel home instantly).

### 4. Đồng Tâm (Shared Mind)
- **Small:** `than_thuc_pct` +0.9 · `attack_pct` soul +1
- **Stat notables:** One Mind (Một Tâm): thần thức ×2 · Twin Thought (Ý Đôi): soul ×2 · Linked Sense (Thức Liên): thần
  thức +1, soul +1 · Echo Mind (Tâm Vọng): soul resist +2
- **Effects:**
  - **Major: Shared Mind (Đồng Tâm).** If your first damaging art is a soul art, your Clone's copy runs on its own soul lockout,
    separate from yours. `Needs rule` (Combat rule 24; not covered by R11, which only adds a Soul part).
  - Minor: Shared Sight (Cùng Nhìn). Your Clone's hits make the foe Slackened Soul every 4th hit. *(starter)*
  - Minor: Mind Link (Liên Tâm). Your Clone's power share +3 %.

### 5. Thiên Thủ Phân Thân (Many Hands, rare)
- **Small:** `art_speed_pct` +0.5 · `attack_pct` +1
- **Stat notables:** Extra Arm (Tay Thêm): art speed ×2 · Hundred Hands (Bách Thủ): attack ×2 · Busy Hands (Tay Bận):
  art speed +1, attack +1 · Juggler (Kẻ Tung Hứng): art cost −2
- **Effects:**
  - **Major: Many Hands (Thiên Thủ).** +1 art slot (`bonus_slots`). Rare one-off (catalogue: "keep these rare"); this is
    the Way's only such node.
  - Minor: Handy (Khéo Tay). Your slot-4+ arts cost 10 % less. *(starter)*
  - Minor: All Hands (Mọi Tay). When all your slots are filled, +5 % art speed.

## Capstones

| Capstone | Kind | Rule | Closes | Near |
|---|---|---|---|---|
| **There Are Three of You (Nhất Khí Hóa Tam Thanh)** | keystone | You may have 2 Clones (they copy your first and second damaging arts), each counting against `c_comp_cap` (the cap is shared between them) | You cannot attach any other companion, and your max health is 20 % lower | Phân Thân |
| **Hall of Mirrors (Kính Điện)** | keystone | Split the Blow sends 40 % and Images regrow every 4 s | Your hits deal 20 % less (L2 −20) | Kính Ảnh |
| **The Avatar Walks (Hóa Thân Hành Thế)** | keystone | Your Avatar can hold a Dao glimpse of its own (a fifth Dao: the one allowed exception to dao.md rule 9, R15b; no other source) | Your Avatar's Dao counts at 50 % for stat lines | Hóa Thân |

## New pieces

- Clone companions; Images; the Avatar: `Needs key` / `Needs rule`. The fifth Dao (capstone) is decided: Dao rule 9
  exception, Phân Thân only (R15b).

## Kept apart from

Huyễn (decoys absorb whole big hits; Phân Thân's images split every hit), Hồn's puppets, Thú (beasts). Phân Thân is
**a clone that copies your art, images that split blows, and an avatar at home**.

# Build wishlist: sets-tx (personal sets for Thiên Xu, its vassals and four outside groups)

What the batch's personal sets (2026-11-25, `_brief-cast-sets.md`) wanted and the game does not have. Each set uses
the closest existing lines for now. Pieces already filed in `wishlist-targets-tx.md` are cited by key, not re-filed:
**W1-earth-weight** (the Pivot, abbey and Quản sets lean on Earth debuff stacks), **W2-metal-marks** (Hoa Cái's Mercury
sets), **W3-assay-strip** (Tried and Stamped, `ck-assayer-tools`), **W4-seal-scope** (`attack_pct [seal]` on the
archive, copyist and digger pieces), **W6-rainfast-marks** (Seven Stars in One Stroke, Sentence Stands, Paid Back: marks
that cannot be cleansed), **W9-stone-wardens** (The Weakest File), **W10-health-leech** (Never Had a Healer). Proposals
for the user's review; nothing here is added to the tree, `effects.md` or the item catalogue.

## S1. Spear, hook, brush and fist bases (Thương, Câu, Bút, Quyền Sáo)

- **Kind:** Item (four new bases in `design/items/bases.json`).
- **Rule or line:** a spear base (long reach, pierce), a hook base (pulls, crit on a pulled foe), a brush base for
  talisman painters (talisman speed), and a fist-wrap base for body cultivators' fist arts.
- **Where it would live:** item bases.
- **Fun:** the Pivot's spearmen read as spearmen; a talisman mistress fights with her brush in hand.
- **Who needs it:** do_tinh_ha, ngu_tran_bac (thien_xu: Army-Breaker Spear has base null, Spear of the Seventh File sits
  on phi_kiem); do_liet_co (loose-south: the Hắc Phong hooks are on phi_kiem); ky_ngan_chuc (hoa_tinh); du_chuc_nhi
  (loose-north: hot fists).
- **Why:** the 22 bases have no spear, hook, brush or fist piece; flying sword and censer stand in.

## S2. Heat the Edge: a Fire-into-Metal engine (Tôi Phong)

- **Kind:** Other (engine: an own-weapon counter fed by one element and spent by another).
- **Rule or line:** each Fire art heats your sword one step (at most 5, each +4 % pierce to Metal sword arts); at 5 the
  next sword art quenches it as a certain crit that counts as a Thunder strike on the blade (waking Sky Iron Sings).
- **Where it would live:** set bonus (`tht-fallen-star-forge`, written), and ideally a Star-Quench Canon art that feeds
  the counter directly.
- **Fun:** the smith fans his own blade red, then quenches it in a foe: a visible build-up and one ringing blow.
- **Who needs it:** cat_luu_quang (thoi_tinh).
- **Why:** arts have counters (`temper`, `afterimage`) but nothing lets one element's arts charge a weapon that another
  element spends; the Rite's Fire and the star sword's Metal otherwise run side by side without meeting.

## S3. A formation that walks (Trận Tùy Thân)

- **Kind:** Effect (new rule kind: a moving formation).
- **Rule or line:** your standing formation follows you at walking pace instead of staying where it was laid.
- **Where it would live:** set bonus (`mf-carried-array`, written); a formation-diagram modifier in Formations #17
  would be the natural home.
- **Fun:** a hired array master who walks into a fight already inside his own walls.
- **Who needs it:** ve_van_co (market-folk).
- **Why:** formations are placed and fixed; the Loom of Letters Seal can move one once a fight, which is a teleport,
  not a walking wall.

## S4. Array within an array (Hoàn Trung Hoàn)

- **Kind:** Effect.
- **Rule or line:** an array laid on a foe already inside your array becomes a second ring: foes in both cannot leave
  either and take each ring's damage every second.
- **Where it would live:** set bonus (`ct-armillary-rings`, written), or the Formation Within a Formation node made to
  do this.
- **Who needs it:** to_tinh_nghi (cung_tinh).
- **Why:** her route takes Formation Within a Formation for damage; nothing nests one array's hold inside another's.

## S5. Time stopped for everyone but you (Tiền Thế)

- **Kind:** Effect (new rule kind).
- **Rule or line:** for 2 s every foe's clock stops (no arts, no movement, no stack decay) while yours runs.
- **Where it would live:** set bonus (`hs-what-the-old-man-kept`, written), and the Stilled Hour Sutra's top art.
- **Fun:** the oldest man alive answers a killing blow by stepping out of time and laying every element at once.
- **Who needs it:** mac_quy_khu (hermits-sages).
- **Why:** the Regalia of Băng Tâm stills time "for you alone" (you are protected); no rule freezes the foes instead.

## S6. The crane king as a companion (Thanh Điền)

- **Kind:** Other (spirit beast: a named companion with its own strikes and stats).
- **Rule or line:** the crane king fights beside its rider as a companion that strikes with Wind, takes
  `attack_pct [companion]`, and answers each attack the rider evades.
- **Where it would live:** the Crane Bond Rite (cuu_cao lineage) and the spirit-beast system.
- **Fun:** a rider who never touches the foe: she dodges, the king strikes.
- **Who needs it:** ung_hac_minh (cuu_cao); the riders of Cửu Cao in general.
- **Why:** the Green Field Bell calls the king once a fight; the set (`cc-green-field-riders`) assumes it stays.

## S7. Protect a hirer (Bảo Tiêu)

- **Kind:** Other (fight state: an ally you are guarding).
- **Rule or line:** a fight may mark one ally as your charge; effects can read "while you protect your charge" and
  "if your charge leaves alive".
- **Where it would live:** combat state, read by items and the valley's arts.
- **Fun:** a hired sword who fights differently when the client is in the room.
- **Who needs it:** lam_khe_ngon, the swords of Phất Y Cốc (phat_y); yen_hoi_do (loose-south: carrying an ally).
- **Why:** the Contract Seal and Paid in Full both name a hirer, and the fight has no such role.

## S8. A Luyện Khí set worn whole (Song Hỏa)

- **Kind:** Other (rule question for the item pass).
- **Rule or line:** Luyện Khí wear one piece (`1 + realm index`), so a two-piece set for a Luyện Khí tier A cannot be
  whole. Either let a set's second piece count when carried in the pack at Luyện Khí, or give Luyện Khí tier A single
  items only.
- **Who needs it:** du_chuc_nhi (loose-north): she wears the Thawing Brazier; the Ember Pendant waits in her pack.
- **Why:** the brief asks for a 2-piece set at Luyện Khí, and the gear rule allows one piece.

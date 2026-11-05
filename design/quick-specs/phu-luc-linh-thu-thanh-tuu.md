# Quick spec: Talismans (Phù lục), Spirit beasts (Linh thú), Achievements (Thành tựu) (and changing spiritual roots [linh căn])

*Status: implemented in the debug terminal build, 2026-11-03, pending design review.
Source: game-concept.md § Core Mechanics 3 (talismans, spirit beasts), § Changing spiritual roots (linh căn),
§ Character Stats (Fated birth [Thiên Định]: achievements on). Built at the user's request; the
concept's MVP list defers all of these.*

## Talismans (Phù lục)

**Rules.** `talisman <id>` spends one season, spirit stone (linh thạch) ink and cheap materials to draw a
batch. Talismans sit in the bag and are used automatically on the one check they help:
Hỏa Cầu Phù (+attack) and Kim Cương Phù (+defense) at the start of a fight, Thần Hành Phù
(+stealth) on a fleeing or hiding check. One of each kind is used per check. The odds on
an event card already include talismans in the bag ("+ Hỏa Cầu Phù") and showing the
card uses nothing.

**Formula** (crafting_talismans.json):

    draw success % = clamp(100 − difficulty + level × success_per_level
                           + (soul strength − than_hon_neutral) × than_hon_per_point, min, max)

Example: level 0, soul strength (thần hồn) 60, Hỏa Cầu Phù: 100 − 45 + 0 + 10 × 0.2 = 57%.

**Edge cases.** Not enough ink or materials → refused, nothing spent. Thần Hành Phù needs
talisman skill level 1. No talisman of a kind → that bonus is simply absent.

## Spirit beasts (Linh thú)

**Rules.** Winning a fight against a beast in an event rolls a tame chance. A tamed beast
is a people record with `owner_id`; the owner lists it. Owned beasts cultivate in the
world tick (wild ones do not), follow the owner when travelling, and add `power_share`
of their combat power (chiến lực) to the owner's offense (shown in `explain power`). Every year each
beast eats `feed_lt_by_realm[realm]` spirit stones (linh thạch): fed, loyalty rises; unfed, it falls by
`unfed_loss`, and at 0 the beast leaves. Soul strength (thần hồn) sets how many beasts can be kept.

**Formulas** (creatures_linh_thu.json):

    tame chance = clamp(base + (soul strength − 50) × 0.004 + Beast Taming level × 0.05, min, max)
    capacity    = max_beasts_base + floor(soul strength / than_hon_per_extra_beast)
    owner bonus = Σ beast combat power × power_share

Example: soul strength 70, Beast Taming (Ngự thú) 2: 0.15 + 0.08 + 0.10 = 33%; capacity 1 + 1 = 2.

## Changing spiritual roots (linh căn)

- **Tẩy Tủy Đan** (recipe, Way of Alchemy [Đan Đạo] 5, two 40-year herbs): raises the weakest owned
  element by max(1, round(6 × pill potency)), max 3 per life. It never rolls for variant roots
  (biến dị linh căn); it only recomputes the purity of derived variants built on that element. The rules are
  owned by `design/gdd/linh-can.md` (rule 13), which wins on any difference.
- **Linh Căn Quả** (items_treasures.json): adds a missing element at purity 20–35, then rolls once for
  each derived variant that becomes eligible (or +8 to the weakest element when all five are owned: no roll,
  derived variants' purity recomputed). Rare by design. Events only, and only from
  Foundation Establishment (Trúc Cơ) up: `events_budgets.json` per_realm `treasures` lists what an event may grant; the
  validator drops anything else (LLM included). Template: "Linh Căn Quả chín" (beast
  guardian, realm ≥ Foundation Establishment, weight 2).

## Achievements (Thành tựu)

**Rules.** Conditions in meta_achievements.json (realm reached, with max age / origin /
element count; skill levels; formation level; beasts kept; variant root (biến dị linh căn) owned; age; a logged
event). Checked after every command. Earned only in Fated-birth (Thiên Định) lives; any `debug` or
`buildgen` command marks the life (`cheated`, saved) and it earns none. Kept across lives
in `user://achievements.json`; scripted runs (`--commands`) keep them in memory so tests
never write the player's record (`--achievements-file` overrides).

## Tuning knobs

| Knob | File | Safe range | Effect |
|---|---|---|---|
| value per talisman | crafting_talismans.json | 20–80 | strength of one use |
| ink_lt, yield | crafting_talismans.json | 5–100, 1–4 | talisman economy |
| tame.base, per_skill_level | creatures_linh_thu.json | 0.05–0.3, 0.02–0.1 | how often beasts join |
| power_share | creatures_linh_thu.json | 0.2–1.0 | beast weight in combat |
| feed_lt_by_realm | creatures_linh_thu.json | per realm | the beast sink |
| purity, raise (Linh Căn Quả) | items_treasures.json | 20–35, 8 | size of a root change |
| treasures per realm | events_budgets.json | lists | where root changes can happen |

## Acceptance criteria

1. Drawing spends the stated ink and materials and one season; success adds `yield` talismans.
2. A fight uses one attack and one defense talisman; an evade check uses one Thần Hành Phù;
   other checks use none; the card's odds include them without consuming them.
3. Higher soul strength (thần hồn) gives a higher tame chance; a tamed beast raises the owner's combat power (chiến lực)
   and moves with the owner.
4. Unfed beasts lose loyalty and leave at 0.
5. Owned beasts advance stages over time; wild beasts do not.
6. Linh Căn Quả adds a missing element; with all five it raises one instead.
7. An event cannot grant Linh Căn Quả in Qi Refining (Luyện Khí); it can from Foundation Establishment (Trúc Cơ).
8. Achievements are earned once, never in Self-made-birth (Tự Định) lives or after debug commands, and
   survive across lives.

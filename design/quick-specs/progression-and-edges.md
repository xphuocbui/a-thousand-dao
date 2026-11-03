# Quick spec: Progression targets and edges (thiên mệnh, cơ duyên, NPC edges)

*Status: in progress, 2026-11-03. Decisions by the user (this session): the game is tuned so
anyone without an edge makes about 3 in 10 realm breakthroughs; the main character's edge
lifts that to about 7 in 10 with competent play; NPCs can have edges too, up to the
player's level; five-element roots follow the same baseline (slow early, strong late).*

## Targets

| Who | Per breakthrough (LK→TC, TC→KĐ, …) | Reach Kết Đan from birth |
|---|---|---|
| Anyone without an edge, competent play | ~30% | ~9% |
| Main character with the edge, competent play | ~70% | ~49% |
| NPC with edges | 30% → up to 70% as edges stack | — |

Measured with `tools/balance/autoplay.gd` (`--edge off` = baseline, `--edge on` = player).

## The player's edge (three parts, all in character_edges.json)

1. **Thiên mệnh (birth perk).** Thiên Định: three perks are rolled, the player picks one.
   Tự Định: any one. Perks are ordinary stat modifiers on the sheet (source "Thiên mệnh: …",
   shown by `explain`), plus a few flags and one-time birth effects:

   | Perk | Effect |
   |---|---|
   | Đạo Cốt Thiên Sinh | +breakthrough chance |
   | Bất Diệt Đạo Tâm | failed breakthroughs lose no tu vi and half the tâm ma; +Đạo tâm |
   | Tổ Truyền Linh Điền | +1 linh điền plot, herbs grow faster |
   | Cổ Ngọc Tàn Hồn | +Ngộ tính, +breakthrough chance |
   | Thiên Đố Kỳ Duyên | +Khí vận, cơ duyên come twice as often |
   | Đan Tâm Thông Linh | +luyện đan success, stronger pills |
   | Thọ Nguyên Dư Dả | +thọ nguyên % |
   | Linh Căn Thuần Tịnh | +purity on every owned root at birth, +tu luyện speed |

2. **Starting items.** One Phá Cảnh Phù: a talisman used automatically on the next
   breakthrough attempt (+breakthrough chance). It can also be drawn later with phù lục.
3. **Cơ duyên.** At a bình cảnh the player's chance of an event rises, and protagonist-only
   templates become eligible: an old master's guidance (Phá Cảnh Phù), the missing herb of
   the next breakthrough pill found at the age it needs, or a forgotten breakthrough pill.
   At most `co_duyen_per_realm` such gifts per realm; the validator enforces it for LLM
   events too.

A life created with `edge: false` (balance baseline) gets none of the three.

## NPC edges

Each NPC gets an edge score e in [0, 1] from sources in character_edges.json → `npc`:

    e = strong root (purity and biến dị) + sect value (rank) + rich family + blessing (a perk)
    p_step = base_step + min(e, 1) × (max_step − base_step)          (0.30 → 0.70)

The world tick rolls each NPC's fate once per realm when it reaches the bình cảnh: with
probability p_step it is fated to break through (then does so within a few years); otherwise
it stays until death. `db show <id>` explains the NPC's chance and its sources. World
generation's realm mix is set to match these rates.

## Tuning knobs

| Knob | File | Effect |
|---|---|---|
| entry_requirement.pill_chance / base_chance | cultivation_realms.json | baseline per-attempt odds |
| breakthrough.ngo_tinh_bonus_per_point, dao_tam_bonus_per_point | cultivation_realms.json | how much thiên phú helps |
| perk effects | character_edges.json | size of the player's edge |
| Phá Cảnh Phù value | crafting_talismans.json | starting-item strength |
| co_duyen_bottleneck_event_bonus, co_duyen_per_realm | character_edges.json | cơ duyên frequency |
| npc.base_step, npc.max_step, source weights | character_edges.json | NPC progression |

## Acceptance criteria

1. Baseline bot (no edge): LK→TC and TC→KĐ each ≈ 30% (±10 points over ≥ 24 lives).
2. Player bot (edge): each ≈ 70% (±10 points).
3. NPC cohort with no edges: ≈ 30% per realm; an NPC with e = 1 ≈ 70%.
4. A perk's effect shows in `explain` with its name as the source.
5. A Phá Cảnh Phù is used by the next breakthrough and its bonus shows in the odds first.
6. Cơ duyên templates appear only for a life with the edge, only at a bình cảnh, at most
   `co_duyen_per_realm` times per realm.

## Calibration log

| Round (2026-11-03) | Baseline LK→TC | Baseline TC→KĐ | Edge LK→TC | Edge TC→KĐ |
|---|---|---|---|---|
| 1 (old odds; bot declined event gifts) | 24/30 = 80% | 8/24 = 33% | 24/24 = 100% | 10/24 = 42% |
| 2 (TC pill 0.06, KĐ pill 0.30; bot values outcomes) | 18/36 = 50% | 8/18 = 44% | 17/24 = 71% | 12/17 = 71% |
| 3 (TC pill 0.06 / bare 0.005, KĐ pill 0.20 / bare 0.01, Ngộ 0.0005, Đạo tâm 0.00025, quality 0.015; Phá Cảnh Phù +25, 2 at start, 2 cơ duyên per realm) | 22/48 = 46% | 6/22 = 27% | 19/24 = 79% | 14/19 = 74% |

NPC cohorts (tools/balance/npc_cohort.gd, 200 each): no edge 29% / 28% / 25%; all edges
68% / 71% / 64%. On target.

Still open after round 3: the baseline's first step is too easy (46% vs 30%). Next
adjustment: Trúc Cơ Đan pill_chance ≈ 0.04, with Phá Cảnh Phù raised so the edge stays
near 70%. A round where the pill and bare odds were equal (0.02 / 0.02) was stopped:
the unit test caught that the pill must always matter.
| 4 (TC pill 0.03, failed breakthrough loses 50% tu vi) | 21/48 = 44% | 6/21 = 29% | 15/24 = 63% | 9/15 = 60% |

Round 4 was reverted: the baseline barely moved while the edge fell below target, so
round 3's values stand. The baseline's first step needs a lever that does not also hit
the edge (e.g. herb age or Đan Đạo level for the Trúc Cơ Đan, or making the edge's
Phá Cảnh Phù / cơ duyên stronger while the pill chance drops).
| 5 (TC pill 0.04, Hoàng Tinh Sâm 40y, Phá Cảnh Phù +35) | 20/48 = 42% | 7/20 = 35% | 17/24 = 71% | 9/17 = 53% |

Round 5 was reverted too: the baseline's first step moved only 46% → 42% while the edge's
second step fell 74% → 53%. Rounds 3–5 show the bot's results are noisy (±10 points at
this sample size) and that the single levers tried (pill chance, herb age, talisman
strength) move baseline and edge together. Round 3's values stand. A real fix needs a
lever that applies only to lives without the edge (e.g. a baseline-only breakthrough
penalty) or a larger sample (96+ lives per arm); both are design decisions for the
Cảnh Giới & Bình Cảnh GDD, not more blind tuning.

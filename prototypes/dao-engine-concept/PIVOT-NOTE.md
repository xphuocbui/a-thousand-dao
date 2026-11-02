<!-- PROTOTYPE - NOT FOR PRODUCTION -->
<!-- Question: carry-forward note for the next concept prototype -->
<!-- Date: 2026-11-02 -->

# Pivot Note: Dao Engine → Cultivation System

## Original hypothesis
If the player drafts fragments and fuses them into a chain engine with a live preview, they
deliberately rework their build to push the result higher. **Refuted:** the fragments were stat
blocks in a damage race; "it doesn't even have a decent system."

## What to keep
- One cultivator's life per run; thọ nguyên as the clock.
- The bounded LLM: the engine owns every number (budgets, clamping, recorded values), the LLM
  narrates and invents within them, templated narration as the fallback, and a check that the
  narration invents no numbers.
- Inspectable numbers: every mechanical value is visible and explainable.
- The Godot + OpenAI-compatible HTTP plumbing (proven against a mock; real model still untested).

## What to change (the single most important thing)
The game needs **a system the player builds inside**: primitives with properties and interaction
rules, with power emerging from what the player constructs. Model it on the cultivation systems of
*Phàm Nhân Tu Tiên* (凡人修仙传, Vong Ngữ) — **systems and genre conventions only**; world, names,
sects, characters and signature items are original. Use Hán-Việt terms throughout.

### Direction agreed with the developer
- **Cảnh giới ladder with power levels:** Luyện Khí (tầng 1–13) → Trúc Cơ → Kết Đan → Nguyên Anh →
  Hóa Thần (ceiling of Nhân giới); Luyện Hư → Hợp Thể → Đại Thừa → Độ Kiếp in Linh giới (later
  scope). Sub-stages sơ / trung / hậu kỳ / đại viên mãn. Roughly 10x power per major realm, so
  vượt cấp is normally impossible — and achieving it through what you built is the min-max fantasy.
- **Bình cảnh:** each major breakthrough needs specific resources; this drives the economy.
- **Building system:** linh thảo that ages over seasons → luyện đan → đan dược (cultivate, trade for
  linh thạch, break bình cảnh); luyện chế pháp bảo (refined and nourished over years); linh thú /
  linh trùng bred in numbers; phù lục; trận pháp.
- **The Dao folds in as công pháp:** methods found and combined, compatible with your linh căn, which
  set cultivation speed and the thần thông you gain.
- **Linh căn redesigned — more elements is better** (a deliberate break from genre convention):
  each element owned unlocks its công pháp and crafts, adjacent tương sinh elements give bonuses, a
  full five-element cycle is the peak, and more elements open more biến dị. A linh căn is a set of
  elements, each with a purity (độ tinh khiết), plus any biến dị. **Many biến dị linh căn**, formed
  systematically from element combinations (and from combining biến dị), so they can be reasoned
  about and discovered. **Linh căn can change during a life, but rarely:** rare treasures or bí thuật
  can add an element, raise purity or trigger a biến dị, so the root is also a long-term build goal.
- **Trade-off agreed: better late, slower early, with fast crossovers.** Relative cultivation speed
  vs. Đơn linh căn (draft values, tune in the GDD):

  | | LK 1–4 | LK 5–9 | LK 10–13 | TC sơ | TC trung | TC hậu | TC đvm | KĐ sơ | KĐ trung | KĐ hậu | NA sơ |
  |---|---|---|---|---|---|---|---|---|---|---|---|
  | Song (2) | 0.6 | 0.7 | 0.8 | 0.9 | **1.0** | 1.3 | 1.6 | 2.0 | 2.4 | 2.8 | 3.5 |
  | Tam (3) | 0.5 | 0.6 | 0.75 | 0.9 | **1.0** | 1.4 | 1.8 | 2.3 | 2.8 | 3.4 | 4.5 |
  | Tứ (4) | 0.4 | 0.5 | 0.6 | 0.75 | 0.9 | **1.0** | 1.5 | 2.1 | 2.8 | 3.6 | 5 |
  | Ngũ (5+) | 0.3 | 0.4 | 0.5 | 0.6 | 0.75 | 0.85 | 0.95 | **1.0** | 1.8 | 2.8 | 6+ |

  Parity: 2–3 elements at Trúc Cơ trung kỳ, 4 at Trúc Cơ hậu kỳ, 5+ at Kết Đan sơ kỳ; each further
  element pushes parity about one sub-stage later, and growth after parity is steep. Assumption to
  confirm: biến dị count as extra elements (e.g. Ngũ Hành + Lôi = 6).
- **Biến dị draft (developer accepted as the starting point; names/pairings may change).**
  First order — tương sinh pairs give stable mutations: Mộc+Hỏa → Quang, Hỏa+Thổ → Dung Nham,
  Thổ+Kim → Trọng, Kim+Thủy → Băng, Thủy+Mộc → Sinh Mệnh; tương khắc pairs give volatile ones:
  Kim+Mộc → Phong, Mộc+Thổ → Độc, Thổ+Thủy → Ám, Thủy+Hỏa → Vụ, Hỏa+Kim → Lôi.
  Higher order — combat: Phong+Kim → Kiếm, Lôi+Quang → Thiên Lôi, Dung Nham+Lôi → Hủy Diệt,
  Sinh Mệnh+Độc → Huyết, Ám+Độc → Tử; crafting: Hỏa+Sinh Mệnh → Đan Hỏa (luyện đan),
  Thổ+Sinh Mệnh → Linh Thực (linh thảo), Kim+Dung Nham → Tinh Kim (pháp bảo), Trọng+Thổ → Trận
  (trận pháp); esoteric: Ám+Sinh Mệnh → Hồn, Vụ+Ám → Huyễn, Quang+Ám → Tinh Thần,
  Trọng+Phong → Không Gian, Băng+Ám → Âm, Quang+Dung Nham → Dương, Sinh Mệnh+Tử → Luân Hồi;
  apex: Âm+Dương → Thái Cực, Không Gian+Luân Hồi → Thời Gian, all five base → Hỗn Độn.
- **World-building in the same structure:** Nhân giới under Linh giới; sect states, a lawless sea of
  islands, great cultivation empires, ruins and bí cảnh — with original geography and history.

## Revised hypothesis for the next prototype
If the player plans an engine shaped by their linh căn (linh thảo → đan dược → breakthrough, plus
pháp bảo) under thọ nguyên pressure, they will feel the compounding of their own plan — evidenced
by deliberate long-term investments the player can explain ("I planted this now because in 30
years I need it for Kết Đan"), and by different linh căn leading to visibly different engines.

**Suggested path:** Paper / spreadsheet sim first (the question is whether the rules are legible
and exploitable, not feel), then Engine.

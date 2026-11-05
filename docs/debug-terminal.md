# Debug terminal and game core

*Built 2026-11-02 (overnight session). Design source: `design/gdd/game-concept.md`.*

The debug terminal is a text frontend for the real game core. It is **not a
prototype**: every rule lives in `src/gameplay/` behind the `GameSession` API, and
the terminal only parses commands and prints what the session returns. A future
Godot UI calls the same API.

## Run it

```
tools\debug-terminal.bat                  (Windows cmd / double-click; sets UTF-8)
tools/debug-terminal.sh                   (Git Bash)
```

Both run the Godot **console** build headless:

```
C:/Godot/Godot_v4.7.1-stable_win64_console.exe --headless --path . -s res://src/debug_terminal/terminal_main.gd -- [options]
```

| Option | Effect |
|---|---|
| `--seed N` | world seed for the next `new` |
| `--color` | ANSI colours (elements, headings) |
| `--commands file.txt` | run commands from a file first (echoed) |
| `--exit-after-commands` | quit when the file ends (scripts, CI) |
| `--no-llm` | templates only, this run |
| `--llm-url URL` / `--llm-model M` | point at another OpenAI-compatible endpoint, this run only |

Set `GODOT_CONSOLE` if Godot is not at `C:\Godot\`.

## Connect DeepSeek

Either of these works; the key never goes into the repository.

- Environment variable: `set DEEPSEEK_API_KEY=sk-...` (cmd) or `export DEEPSEEK_API_KEY=sk-...` (bash), then start the terminal.
- Inside the terminal: `llm key sk-...` stores it in `user://llm_config.json`
  (Windows: `%APPDATA%\Godot\app_userdata\Ten Thousand Daos\llm_config.json`).

Then `llm test` does one round trip, and `llm` shows status, call count and average latency.
Defaults (`assets/data/services_llm.json`): `https://api.deepseek.com` + `/chat/completions`,
model `deepseek-chat`, JSON mode for events and talk, story language Vietnamese (`llm lang en` switches for the run).
A local model works the same way: `llm url http://localhost:11434/v1 qwen2.5` (Ollama) needs no key.

Without a key, or when a call fails, every feature falls back to templates and the
terminal says so: the game is fully playable offline.

## Playing without memorising commands

After every action that changes something, the terminal prints three things:

- **Δ change line**: what the action changed ("1 year passed · Tu vi 0 → 14 (+14) ·
  Linh thạch 44 → 39 (−5) · + Hỏa Linh Chi"), coloured by gain or loss.
- **HUD**: realm with a tu vi bar and the time to the next tầng (or BÌNH CẢNH), age
  against thọ nguyên, khí huyết, linh thạch, chiến lực, unspent Kinh Mạch points, and
  the two most pressing goals from the Advisor (‼ urgent, ! warning, ➤ goal).
- **Numbered menu**: the Advisor's goals as concrete actions ("Plant Hoàng Tinh Sâm
  (15 LT) — for Trúc Cơ Đan", "Break through to Trúc Cơ (52%)") followed by what can be
  done here. Type the number. Enter shows the HUD and menu again; `menu off` hides the
  menu after each turn, `goals` lists every goal.

Events show as a card with each choice's odds (bar and percentage, the stat or chiến
lực compared), its cost, and why a choice is unavailable; type the choice number.
Commands that need an id (`go`, `use`, `equip`, `unequip`, `learn`, `craft`, `plant`,
`talk`, `buy`, `sell`, `tree alloc`) show a numbered list when the id is left out.
The sheet draws linh căn purity and thiên phú as bars coloured by grade (Hạ red → Thiên
magenta), with each element's crafting role. Colour is on by default in a console window
and off when output is piped; `--no-color` / `--color` override. Screenshots:
`production/qa/evidence/debug-terminal/03-*.png` and `04-*.png`.

The goals come from `src/gameplay/session/advisor.gd` and the change line from
`state_snapshot.gd`: both are read-only gameplay-layer APIs, so a Godot UI can show the
same guidance. Advisor thresholds are in `assets/data/session_advisor.json`; readable
stat names for modifiers in `assets/data/character_stat_labels.json`.

## A first session (typed commands)

```
new                      character creation: name, gender, origin, seed, Thiên Định (roll, reroll) or Tự Định (choose)
sheet                    the character sheet (every number has a breakdown: explain rate / power / life / ngo_tinh ...)
look / map               where you are, who is here, roads
field / recipes          linh điền and đan phương (what is ripe, what you can make, odds)
plant hoang_tinh_sam     a seed for the Trúc Cơ Đan, which needs 30 years of age
cul 4                    cultivate a year (events may interrupt)
event / choose 2         read and answer an event
tree / tree targets      Kinh Mạch Đồ: openable huyệt, notables and keystones by cost
tree go <id>             open the whole path to a node
talk <person id> hello   conversation (LLM or template)
db people <filter>       the world database; db show <id> for anyone's record and history
bequan 5                 five years of seclusion; the world moves on ('news')
breakthrough             at a bình cảnh; consumes the best Trúc Cơ Đan you have
save / load              user://saves
help                     every command
```

The full command list is `help` (grouped: General, New life, Character, Actions,
World, Kinh Mạch Đồ, LLM, Debug). Debug commands (`debug event <template>`,
`debug tuvi`, `debug lt`, `debug herb`, `debug tp`, `debug heal`, `debug item`,
`buildgen <archetype> <realm>`) exist for testing and balancing.

## What is in the game core

| Request | Where | Notes |
|---|---|---|
| Character creation | `character/character_factory.gd`, terminal `new` | Thiên Định (rolled, rerollable, achievements flag) / Tự Định (chosen, casual) |
| Character stats | `character/stat_sheet.gd`, `character_rules.gd` | design/gdd/character-stats.md: quantized modifiers, character-wide ceilings with penalties after the cap, stage-scaled derived values, the capability set |
| The ladder | `cultivation/ladder.gd`, `cultivation/cultivation_rules.gd` | design/gdd/canh-gioi.md: levels 1-110, stages, level costs, bottleneck bar, a separate condition per gate, pill and bare attempts, failure insight, the q-extras ceiling, lifespan ceiling |
| Techniques | `cultivation/cong_phap.gd`, terminal `tech`, `slot` | design/gdd/cong-phap.md: main and auxiliary slots, layers and mastery, speed and power, harmony, reserved par-tier manuals |
| Spiritual roots | `character/linh_can.gd` | design/gdd/linh-can.md: five elements, eight variant roots of three origins, `n_base` for tier and pairs, `n_eff` for the curve, a fixed birth draw order, Mutation Awakening |
| World generation + history | `world/world_generator.gd` | regions, places, roads, sects with ranked members, townsfolk, loose cultivators, legendary and lost treasures, ~300 years of legends consistent with the present |
| Living world | `world/world_ticker.gd` | each season NPCs age, cultivate, break through, die, duel |
| Story | `narrative/narrator.gd`, `events/*` | LLM or template events, LLM narration with a number check, NPC talk, an epitaph; `chronicle` |
| Item generation | `items/item_factory.gd` | linh thảo (age → potency), đan dược (quality), pháp bảo (grade, tier, element, affixes), công pháp (tier, elements, bonuses), materials |
| Build generation | `build/build_generator.gd` | every NPC gets linh căn, thiên phú, công pháp, artifacts limited by thần thức, Kinh Mạch points spent toward its archetype, đạo nghệ — same rules as the player |
| Passive tree (PoE-like) | `meridian/meridian_tree.gd`, `meridian_generator.gd` | design/gdd/kinh-mach-do.md: 802 visible acupoints, 75 hidden clusters, 25 capabilities, 8 locked variant sectors; terminal `tree`, `tree clusters`, `tree mode` |
| LLM events | `narrative/llm_service.gd`, `events/event_validator.gd` | DeepSeek/OpenAI-compatible; the engine clamps every number to `events_budgets.json`, registers new people before they appear, drops unknown effects, and shows each adjustment |
| Databases | `world/world_db.gd` | people, sects, places, regions, items, events — one JSON-serializable store, event index per entity; terminal `db` |
| Crafting / economy | `crafting/herb_field.gd`, `alchemy.gd`, `items/pill_effects.gd`, `economy/market.gd` | herbs age by Mộc, alchemy by Hỏa/Đan Đạo, đan độc brake, markets by realm budget |
| Luyện khí | `crafting/refinery.gd`, terminal `refine` | pháp bảo from a design + materials + linh thạch fuel; Kim purity and the Tinh Kim biến dị raise success |
| Trận pháp | `crafting/formations.gd`, terminal `formation` | Tụ Linh / Thanh Mộc / Hộ Sơn at the động phủ, levels, yearly upkeep (Thổ cuts it, Trận biến dị strengthens them) |
| Phù lục | `crafting/talismans.gd`, terminal `talisman` | talismans drawn from materials + ink, used automatically on the fight or escape they help |
| Linh thú | `character/beast_keeper.gd`, terminal `beasts` | tame beasts you beat; they grow each season, add to chiến lực, follow you, need feeding |
| Changing linh căn | `items/treasure_effects.gd`, `items/pill_effects.gd` | Tẩy Tủy Đan (weakest root +purity, 3 a life), Linh Căn Quả (new root; events from Trúc Cơ only) |
| Thành tựu | `meta/achievements.gd`, terminal `achievements` | 14 achievements, Thiên Định lives only, debug commands disqualify a life, kept across lives |
| Progression and edges | `cultivation/progression_edges.gd`, `world/world_ticker.gd` | baseline ~3 in 10 per breakthrough for everyone; the main character's edge (thiên mệnh perk chosen at birth, a starting Phá Cảnh Phù, cơ duyên events at a bình cảnh) aims at ~7 in 10; NPC edges (strong root, sect rank, rich family, blessing) range 30–70%, fate rolled once per realm (`db show` explains it); `tools/balance/npc_cohort.gd` measures NPCs |
| Guidance | `session/advisor.gd`, `session/state_snapshot.gd` | goals, menu actions, event odds, the change line; read-only, reusable by a Godot UI |
| Combat | `combat/combat_power.gd` | chiến lực computed from what you built (and your linh thú); duel curve; vượt cấp only through items/tree |
| Session / saves | `session/game_session.gd`, `core/save/save_store.gd` | one turn = one season; saves include the RNG state |

### Layers

```
src/core/            engine-level, no gameplay knowledge
  data/              DataRegistry (JSON files)
  random/            RngUtils (all randomness through an injected RNG)
  math/              Breakdown (explainable numbers)
  save/              SaveStore
  llm/               LlmClient (synchronous HTTPClient, OpenAI-compatible)
src/gameplay/        rules; depend on core, never on the terminal
  game_data.gd       typed access to assets/data
  character/ cultivation/ meridian/ items/ crafting/ economy/ combat/
  build/ world/ events/ narrative/ session/ meta/
src/debug_terminal/  frontend: terminal_main (entry), terminal_io, terminal_views, terminal_app
assets/data/         every gameplay number (schemas: docs/data-schemas.md)
```

**The LLM is bounded by construction.** Event JSON goes through `EventValidator`
(budget clamps, allowed stats and effects, people registered first). Outcomes are
rolled by `EventResolver` with engine rules only. Narration is rejected and replaced
by the template if it contains a number that is not in the facts. Talk replies may
only hint at entities that exist; attitude changes are clamped.

## Tests

```
tools/run-tests.sh                        everything (about a minute)
tools/run-tests.sh res://tests/unit/meta  one folder or file of unit suites
```

1. **Unit suites** (88 tests, `tests/unit/**`) run on **gdUnit4 v6.2.2**
   (`addons/gdUnit4`, the release line that supports Godot 4.7). Suites extend
   `DaoTestSuite` (`tests/framework/dao_test_suite.gd`), which adds the message-first
   helpers `assert_eq / assert_near / assert_true / assert_false` on top of gdUnit4's
   asserts. HTML and JUnit reports land in `reports/` (gitignored). `project.yaml`'s
   `commands.test` runs the same suites; its `--remote-debug tcp://127.0.0.1:0` makes
   Godot 4.7 print two harmless "remote port" errors.
2. **Scripted session**: `tests/integration/debug_terminal/smoke_commands.txt` played
   through the real terminal; fails on a non-zero exit or any `SCRIPT ERROR`.
3. **Typed line by line** (`tests/integration/debug_terminal/pipe_interactive.js`, needs
   node): types commands one at a time over a pipe and waits for each answer, the way a
   person or an agent drives the terminal.

Every stage has a timeout, so a script error that leaves Godot idle fails the gate
instead of hanging it. Scripted runs keep achievements in memory, so tests never write
the player's records.

Each regression test was run against the unfixed code and seen to fail first: legend
ordering; `harvest all` taking young herbs; artifact thần thức cost at high realms;
late-game pills in starting markets; an all-cost event softlocking a broke player;
change-line rounding ("9 → 9 (−1)"); typed input never running (Godot strips the
newline, TerminalIO now restores it); a queued Enter blocking on a second read; the
Advisor sending the player to search for a herb already in the bag; formations losing
two levels a year; stealth having no effect.

`tools/llm-mock/mock_server.js` is an OpenAI-compatible mock that behaves like a
careless model (over-budget numbers, unknown effects, invented ids, fenced JSON) for
testing the LLM path offline: `node tools/llm-mock/mock_server.js` then
`--llm-url http://localhost:18080`.

## Known limitations and open questions

- **Balance (tools/balance/autoplay.gd, tools/balance/npc_cohort.gd).** Targets (user, 2026-11-03):
  without an edge about 3 in 10 make each realm breakthrough; the main character's edge lifts
  that to about 7 in 10; NPC edges range between. The bot plays whole lives through the session
  API with the plant plan; `--edge off` measures the baseline and `--perk dao_cot` the edge the
  calibration assumes. Latest run on the GDD rules (2026-11-05; 300 baseline, 120 edge lives; a
  gate's rate is crossed / arrived at a full bar): baseline 27.7 % / 25.0 % / 66.7 % / 83.3 %,
  edge 55.8 % / 62.3 % / 81.6 % / 74.2 %. The two late baseline figures rest on 18 and 12 lives.
  Raw results: `production/qa/evidence/balance/2026-11-05-gdd-bot-run.txt`.
  NPC cohorts: no edge 35 / 35 / 23 %, all edges 71 / 67 / 65 %.
  `godot --headless --path . -s res://tools/balance/autoplay.gd -- --edge off --seeds 1,2,3`
- **Balance is first-pass.** Values come from the concept's draft tables; nothing
  has been playtested. In particular: event difficulty against low thiên phú, early
  linh thạch income, and how long a Luyện Khí life takes all need a human session.
  `buildgen` and `debug` commands exist to tune with.
- **Narration number check catches digits only.** A model that writes a number in
  words ("ba nghìn năm") passes the check.
- **The world never ends**: realms past Kết Đan exist in data (up to Hóa Thần) but
  there is no "win"; a life ends at death.
- **Built 2026-11-03, first pass**: luyện khí, trận pháp, phù lục, linh thú, changing
  linh căn, thành tựu (specs in `design/quick-specs/`). **Not yet built**: linh trùng
  swarms, a Codex of discovered recipes and variants, karmic carryover.
- **Built 2026-11-05 from the GDDs, with placeholders**: sealed cluster content and the
  variant sector names are theme-pool filler; a technique-sealed cluster opens for a main
  method naming its element; open cluster fills use the template pool, never the LLM;
  the Heavenly Tribulation is absent, so the Deity Transformation roll stands alone; divine
  abilities exist on techniques but Combat reads none; #20's "seen two stages lower" is not
  shown; the Advisor shows brews possible and `Advisor.next_plant` holds the plant plan, but the
  terminal has no one-click command for it yet. The viewer is built by `tools/meridian-map/`.
- **Open design questions carried from the concept**: turn granularity (season vs year)
  and exact combat resolution (currently a power-ratio duel).
- Unit tests read the real data files (they are project fixtures, read-only); a
  test-only data set would make them independent of tuning changes.

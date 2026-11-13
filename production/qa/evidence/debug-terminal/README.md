<!-- Evidence for the debug-terminal build (2026-11-02, updated 2026-11-03). The UI is a terminal: screenshots of a real Windows Terminal window plus text transcripts. -->
# Debug terminal evidence

| File | What it shows |
|---|---|
| `01-smoke-session-transcript.txt` | 2026-11-02 build: the scripted session (`tests/integration/debug_terminal/smoke_commands.txt`, ~70 commands, templates only): every command group, events with odds, Kinh Mạch map, crafting, market, NPC builds, save/load. Exit 0, no SCRIPT ERROR. |
| `02-character-creation-transcript.txt` | Interactive `new` wizard through piped input: Thiên Định roll + reroll, Tự Định custom stats and purities, sheet and tree map of a Tam linh căn character. |
| `03-hud-change-line-menu.png` | Windows Terminal (the window a double-click opens): after `cul 4`, the Δ change line, the HUD with bars and goals, the numbered menu. Colours on by default. |
| `04-character-sheet.png` | The sheet: linh căn purity bars in element colours with each element's role, biến dị with readable effects, thiên phú bars coloured by grade. |
| `06-smoke-session-with-new-systems.txt` | 2026-11-03 scripted session: HUD, change lines, event cards with odds bars, menu numbers answering events, pickers (go, talk, equip, tree alloc, plant, craft), luyện khí and trận pháp, talismans, linh thú view, achievements view (debug use disqualifies the life). Exit 0, no SCRIPT ERROR. |
| `10-equip-slots-session.txt` | 2026-11-13 overnight (Item Database rule 11): commands in `10-equip-slots-commands.txt`. Rerun 2026-11-13 after the rule change (no piece costs thần thức; thần thức adds extra slots). At Qi Refining a weapon, armour, two rings and a necklace go into base slots; a bell and a third ring take the two extra slots; a flag is refused ("No free slot fits"); a named necklace asked into the weapon slot is refused; after unequipping a ring it takes the freed extra slot; `explain power` shows "Extra slots 2 / 2, the next at thần thức 79". Stamp: `10-equip-slots-stamp.txt`. |

(There is no 05: the event-card screenshot showed only half the card and was dropped; 06
shows full cards as text.)

Verified elsewhere: typed input line by line (`tests/integration/debug_terminal/pipe_interactive.js`,
part of `tools/run-tests.sh`); the LLM path against `tools/llm-mock/mock_server.js`. Not yet
verified: a real DeepSeek run (needs the key) and typing Vietnamese diacritics in a console
window (piped Vietnamese input works).

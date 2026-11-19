# Sun, Moon, Thunder and Chaos designed by OpenAI (2026-11-19, candidate)

The user asked: "please ask openai to design sun, moon, thunder island and chaos land please". Model: `gpt-6.2-sol`
(newest on the account), Responses API, reasoning effort high. One request per region, each with the same rules brief
(`common.md`), a region brief with the user's art direction (`regions.json`), the region's geometry (`pack.json`, from
`pack.py`: road nodes, fixed start nodes, road links, nearby v2 land/border pieces) and renders of the empty region
(`img-*.png`). No personal details or paths were sent. My own `islands.py` / `chaos.py` were not sent.

- Round 1 (`prompt-*.md` -> `r1-*`): all four passed every check first time.
- Round 2 (`prompt2-*.md` -> `r2-*`): each model saw its own render and improved what it judged weakest (Thunder got
  the note "sparse, nothing reads as lightning yet"). Files: `oai2_sun.py`, `oai2_moon.py`, `oai2_thunder.py`,
  `oai2_chaos.py` (current); `oai_*.py` = round 1.
- No hand edits by Claude: the files are the model's code as returned (`extract.py` pulls the block and scans imports).
- Checks of round 2 inside the v2 tree (`check.sh`, `oai_check.py`): 0 crossings, only the base map's 4 spacing
  warnings, all 795 pieces pass R0-R4, two-entry R3 and arc centres clean for the new pieces.
  Sun 80 nodes / 17 pieces, Thunder 65 / 12, Moon 75 / 11, Chaos 120 / 25. Merged map `oai-r2-map.json`,
  render `oai-r2-whole.png`; shown in the viewer as "OpenAI islands + hub".
- Spend: 8 calls (plus a probe), about 95k input and 66k output tokens.
- Rebuild: `sh design/dao-do/cells/openai/check.sh <tag> design/dao-do/cells/openai/oai2_{sun,moon,thunder,chaos}.py`
  from the repo root. Not promoted; v2's `islands.py` / `chaos.py` are untouched.

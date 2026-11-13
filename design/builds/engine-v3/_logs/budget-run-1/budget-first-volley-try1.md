# Job transcript: budget-first-volley (try 1)

"first-volley" is now within budget: it claims 21% of the layer gap, against the 23% budget at Nguyên Anh (nguyen_anh), and `fight.py` prints `layer_budget`. It was 46% and flagged `OVER_BUDGET` before.

I changed `layers` from `[360, 0, 250, 0, 0]` to `[270, 0, 130, 0, 0]`. I cut L3 hardest and L1 least, because the build's concept is the opening burst. A value of 150 for L3 rounded to 23% and still tripped the flag, so I settled on 130. I changed no techniques, items or arts and removed none.

Fights, 20 each, run with `--matrix` (mean time, wins–losses):

| Matchup | Before | After |
|---|---|---|
| typical, same realm | 1.0 s, 20–0 | 1.5 s, 20–0 |
| typical, +1 realm (hoa_than) | 2.5 s, 20–0 | 3.7 s, 20–0 |
| top-end, same realm | 33.1 s, 19–1 | 48.2 s, 15–5 |
| top-end, +1 realm | 4.0 s, 0–20 | 4.0 s, 0–20 |

The build still beats a typical same-realm foe in 1.5 s, not the 10–20 s a build at its budget should take. The speed comes from the crit and art-speed fields and the item modifiers, which `layers` doesn't hold, so cutting `layers` alone doesn't slow it further. Bringing it into the 10–20 s range would mean changing those, and your instructions ruled that out.

The guide's old numbers were from an earlier run. I replaced them with the re-run figures and added the "Budget revision (2026-11-13)" section.

The report lists what the build would want from the catalogue:
- A Thunder `more` multiplier (L2) that library arts can carry.
- A Thunder ring of grade 2–3.
- A Thunder sword of grade 3–4 whose art joins the suite.
- A Thunder armour with a drain ward.
- An L4 preparation source.
- An escape or step item for Lightning Step.

Files are in `design/builds/engine-v3/`:
- `builds/first-volley.fight.json`
- `first-volley.md`
- `_logs/budget/first-volley.md`

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/_logs/budget/first-volley.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/_logs/budget/first-volley.md) instead (Edit rules cover all file-editing tools).
```

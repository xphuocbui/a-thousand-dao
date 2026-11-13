# Job transcript: budget-art-thief (try 1)

The `art-thief` build now prints `layer_budget`. Its claimed share fell from 84 % to 22 %, against the 23 % Nguyên Anh (nguyên anh) budget.

`layers` went from `[400, 200, 240, 150, 0]` to `[370, 40, 40, 20, 0]`. L2–L4 now sit at the typical enemy's values, so they claim nothing. L1 was trimmed from 400 to 370, because L1 carries the echo-palm concept. Cutting L2–L4 alone left the claim at 26 %, still over budget. No technique, item or art was changed.

The "before" column is today's run of the over-budget file. The "after" figures come from today's `--matrix` run of the budgeted file, 20 fights per row.

| Matchup | Before (mean, wins–losses) | After (mean, wins–losses) |
|---|---|---|
| typical, Nguyên Anh +0 | 1.9 s, 20–0 | 6.0 s, 20–0 |
| typical, Hóa Thần +1 | 3.6 s, 20–0 | 20.2 s, 20–0 |
| top-end, Nguyên Anh +0 | 5.2 s, 20–0 | 37.9 s, 9–10 (1 draw) |
| top-end, Hóa Thần +1 | 8.7 s, 3–17 | 5.9 s, 0–20 |

The typical same-realm fight now takes 6.0 s, under the 10–20 s target for a build at budget. I left that alone, since tuning the ward and Effects is outside this task. I also reran `--without eff:Echo` and `--without item:force-chaos-shock-zither`: removing Echo shifts times by 0.2–3.5 s, and removing the zither's modifiers changes nothing.

The guide `art-thief.md` has its tables and Observations updated and a new "## Budget revision (2026-11-13)" section. The report is at `design/builds/engine-v3/_logs/budget/art-thief.md`. It lists the pieces the build now lacks:
- a foe-art-copying piece (the theft identity is unmodelled);
- an Echo that stacks;
- a force-scoped `attack_pct` item;
- a palm-scoped Drink item;
- armour with a stronger ward.

I changed no other files.

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/_logs/budget/art-thief.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/_logs/budget/art-thief.md) instead (Edit rules cover all file-editing tools).
```

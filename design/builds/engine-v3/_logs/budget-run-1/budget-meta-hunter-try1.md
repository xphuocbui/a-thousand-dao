# Job transcript: budget-meta-hunter (try 1)

I couldn't bring "meta-hunter" within its layer budget. The sandbox refuses every `python` call to `fight.py` and says it needs approval, which I can't give in an unattended run, and I can't ask. Without a run I have no real fight numbers and can't see the printed `layer_budget` flag or the claimed share. I changed no files and did not create `_logs/budget/meta-hunter.md`.

A report or a "Budget revision" section built on guessed numbers would put false results into the catalogue. A trial-and-error loop on `layers` needs actual runs.

**To finish this**, allow `python -I tools/design/combat_sim/fight.py …` for this session (or run it yourself). Then I will:
1. Read the Layer budget rules (FIGHT-INPUT.md lines 165–169) and compute the budget. At nguyên_anh it is 23% of the typical-to-top-end gap, summed over L1–L5.
2. Lower `layers` (now `[200, 280, 250, 150, 80]`, 80% claimed) until the run prints `layer_budget` instead of `OVER_BUDGET`. I'd cut the layers the concept needs least first.
3. Run `--matrix`, update the guide, and write the report.

**What I read, so the next attempt starts faster:**
- The build's own pieces already run as Effects: the two techniques' passives, the eight items' modifiers, Edge Returns the Breath and Marked Prey. `layers` should keep only Meridian Map and other named sources, so most of the current values probably double-count.
- Marked Prey adds L5 +4 per distinct foe status (cap +16) on top of `layers[4]`.
- The guide's current fights are 2.3 s and 4.5 s at nguyên_anh (typical and top-end), all 20-0. After the cut I expect them to lengthen toward the 10–20 s target, but I haven't run anything to confirm it.

## stderr

```text
Permission allow rule (--allowed-tools): Write(design/builds/engine-v3/_logs/budget/meta-hunter.md) is not matched by file permission checks — only Edit(path) rules are. Use Edit(design/builds/engine-v3/_logs/budget/meta-hunter.md) instead (Edit rules cover all file-editing tools).
```

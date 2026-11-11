# Session transcript: beast-carry-try1

> Final message of one headless `claude -p` session.

I finished the build design for **Raising the Tiger (Dưỡng Hổ)**. As you decided, no fight simulation was run, so "The fight" and the identity test are NOT ASSESSED.

**What the build does.** The beast deals all the damage. The keeper's arts only buff, heal, shield or revive it.
- **Enabler: the Shared-Heart Contract (Đồng Tâm Khế).**
  - Your basic attack becomes a second strike by the beast.
  - The beast gets its own health bar, half of yours, and takes 30 % of the damage that reaches you. Your heals and shields can reach it.
  - The price: you can slot no art that hits, ticks or curses the enemy. While the beast is Down, your side deals no damage.
- **Rate.** The beast cannot crit, so its scaling past the 1.0 cap on its hit size (`c_comp_cap`) is rate. Bonded Spirit (from the tree catalogue) lets your art speed shorten both beast timers. At +100 % art speed they reach the 0.5 s floor, so the beast bites four times a second for no linh lực.
- **Fuel.** Spare linh lực becomes damage. Feed the Fire grants Fire buff stacks: every 1 % of your maximum linh lực per second spent on it holds about 30 stacks, which is +36 % damage dealt.
- **Identity piece: Straining Leash (Căng Xích).** The beast's power past the 1.0 cap becomes +5 extra damage per 0.1 over, up to +50. That is why a keeper hunts a beast stronger than itself.
- **Root:** Wood and Fire. Fire purity powers the buff stacks.
- **Key numbers (Nascent Soul, top-end, prepared fight):** the beast's damage multiplier is about 203, against the top-end reference of 256. One bite is about 20,300 before Fire stacks and about 48,700 with 100 stacks. In a fight with no preparation the multiplier drops to about 136.
- **What beats it:** a Physical-resistant enemy that heals, and a slow heavy hitter that knocks the beast Down twice within Rouse's 6 s cooldown.

**One assumption that matters.** The Effects GDD lists Fire's buff as "+1.2 % damage dealt" without saying which layer it fills or whether companion hits count. The build assumes it multiplies all the side's damage, including the beast's. If it is ruled into the "increased" layer instead, the Fire stacks add only about ×1.1 and the build relies on its layers and rate alone. I filed this as a suggestion.

**Checks:** 7 PASS, 0 FAIL, 2 NOT ASSESSED (the fight and the identity test). Budgets passes, but its thần thức part could not be checked because there is no reference thần thức table per realm. Read by hand, removing Straining Leash cuts every bite by about 26 %.

**Shared-file changes:**
- **Staging catalogue:** 29 new rows. 24 are new pieces. 5 copy pieces from other sources by name: Bonded Spirit and Companion attack speed (tree catalogue), Rain on Both and Element-tagged companions (by-root missing pieces), and Full Trough (the 2026-11-07 ledger). Counting Companion damage from the tree catalogue, which needed no row, 6 pieces were reused. I added this slug to no existing row's "Used by".
- **Suggestions:** 5 entries:
  - a companion that can be hurt, healed and shielded;
  - a new action that turns the basic attack into a companion strike;
  - speed and timer actions reaching the companion's timer;
  - where Fire's "damage dealt" goes;
  - creature records with an element tag.
- **Ledger:** one build row plus rows under Modifiers, Enablers, Other pieces and New concepts.

Files are in `design/builds/overnight-2026-11-10/`:
- `builds/beast-carry.md` (player guide)
- `builds/beast-carry.sheet.md` (design sheet)

BUILD-RESULT: slug=beast-carry status=DONE staged_new=24 staged_reused=6 suggestions=5 checks_fail=0 checks_na=2

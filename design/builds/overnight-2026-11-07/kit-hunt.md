# Kit Hunt: Is the Cheap Art Dominant?
> Overnight analysis, 2026-11-07. Paper model. Each number is a saved run: `variants/[hunter]-[name].fight.json` through `_tools/fight_x.py`. "Search" means `scratch/kit-hunter/`: the best line is saved, but a search is not a proof. Nothing was changed.

**Verdict: dominant only in some cases.** The cheap kit is not dominant once a per-hit or per-pulse ward exists: slower kits beat all three lines at equal W and realm, with 0 new pieces and 0 rule asks. It is dominant over slow kits on the common drain ward, and all three wards that beat it are overnight records, not game data.

| Hunter (ward, cooldown) | Thin Shavings, Qi Refining, 81.6 W | Short Reply, Foundation, 247.8 W | Pine Rain, Deity, 361.2 W | Panel |
|---|---|---|---|---|
| Wet Cloth (Vinegar Cloth, 1 s) | **W 3 s on 27 %** | W 3 s on 67 % | W 2 s on 76 % | 4 of 5 |
| Long Answer (Stone Ward, 3 to 4 s) | L 2 s, kit on 89 % | **W 8 s on 30 %** | W 6 s on 71 % | 4 of 5 |
| Under the Eaves (Standing Verdict, 4 s) | L 4 s on overkill, both at 0 % | W 4 s on 45 % | **W 4 s on 71 %** | 5 of 5 |

Bold is the sheet. The rest keep ward and cadence, re-cut by search to that line's realm, W and node counts (`-vs-[line]`). Panel: `-mixed`, `-pulse`, `-wall`, `-evader`, `-fast`. Each kit line wins 5 of 5, and the Wall beats two hunters.

**The kit answers back.** A fair test lets it change too.

| Kit's reply to the sheet | Wet Cloth | Long Answer | Under the Eaves |
|---|---|---|---|
| Line, rows kept, on Cloth (`-line-on-cloth`) | **L 3 s, kit on 3 %** | W 8 s on 28 % | W 4 s on 71 % |
| Line on Verdict (`-line-on-verdict`) | W 3 s, both at 0 % | W 8 s on 28 % | W 4 s on 71 % |
| Line on Stone (`-line-on-stone`) | W 3 s, both at 0 % | W 8 s on 36 % | W 17 s on 59 % |
| Cheap art on the hunter's rows and ward (`-kit-on-my-rows`) | W 6 s on 6 % | W 9 s on 73 % | W 12 s on 64 % |
| Best kit by search, W re-spent, any ward (`-kit-answer`) | **L 3.5 s, kit on 42 %** | **L 3 s, kit on 68 %** | Stalemate 40 s, both on 8 % |
| 1 s art on the ward search chose, against that kit (`-second-answer`) | W 4 s on 5 % | W 4 s on 37 % | not needed |

So it is a cycle, not a ladder: kit line, hunter, re-spent kit, 1 s art. No kit found beats everything, and no hunter does either.
## What beats it
1. **Not paying by the size of the hit.** On the common ward the hunters' pools are dry at 1 s, 1 s and 0.5 s (`-common`, all lost). On their own wards they are never dry, dry at 8 s and dry at 4 s. The ward is the identity: `--without ward` loses all three, at 1 to 1.5 s.
2. **Outlasting its pool.** The kit is dry at 2 s, 3.8 s and 2.5 s (`-swap`). More slots spend it faster: seven arts take half of Pine Rain's pool a second.
3. **Moving W from damage to defence.** Long Answer's L1 is 6. Its first-line arts lost four of five on the panel, and they win here.
4. **A bigger art at the same 0.5 s, on the common ward, no ward swap:** W 0.5 s on 71 % (`wet-cloth-burst`), W 1 s on 62 % (`long-answer-burst`), W 0.5 s on 40 % (`under-the-eaves-burst`). So cheapness is not what wins. The 0.5 s floor is.

**What did not work,** each one change from `long-answer-common`, Foundation only: evade 12.8 %, body guard +95.4, all qi hits, a curse at 2 s (`-p-evade`, `-p-guard`, `-p-all-qi`, `-p-early-word`). All lose at 2 s with the kit on 95 %, because the pool is dry at 1 s. On the Stone Ward the same curse helps: 6 s on 47 %, not 8 s on 30 % (`long-answer-early-word`). The damage floor of 1 never binds: the kit's hits land for about 8 even at Qi Refining (`wet-cloth-swap`).
## Where it cannot be beaten
- **Common drain ward, every cooldown 1 s or more.** Search: 0 wins in 8,000 random lines at each realm, and the best lines end in a 1 s photo finish, both at 0 %, kit ahead on overkill (`-common-best`). If the per-hit and per-pulse records do not ship, only a bigger 0.5 s art beats it.
- **Qi Refining with cooldowns of 3 s or more.** Both re-cuts lose. It is the kit's best realm: L3 114 against small pools, and Wet Cloth's margins there are thin.
- **Ordinary opponents.** The hunters win by spending W on the foreseen fight. A fighter who cannot prepare meets the kit as the panel does, and loses. It stays the best blind choice.

**Limits:** a paper model with evade as an expected value. Hunters know the enemy. Searches are short. The burst lines were not put through rematches.

# UI Patterns from Crusader Kings III, Victoria 3, Europa Universalis V and Path of Exile

> **Date**: 2026-11-22 · **Requested by**: the user ("learn from paradox games like vic3 ck3 eu5 and poe … compose the
> best of best") · **Researched by**: a research agent (web search and fetch); summarised here as the source of
> `design/ux/interaction-patterns.md` v2.
> **Source tags**: **[F]** page fetched and read · **[S]** search snippet only, URL cited · **[GK]** general knowledge,
> unverified. Several official sources (Paradox forum, wikis, PoE wikis) refused automated fetches, so EU5's official
> dev-diary UI content, CK3's acceptance internals and PoE's comparison and crafting-bench behaviour rest on snippets or
> general knowledge: check them in the games before a spec relies on them.

## Per-game notes

**Crusader Kings III**
- Nested tooltips: highlighted terms open their own tooltip; three lock modes: Timer Lock (default, locks after a second
  or two), Action Lock (middle mouse), Mouse Tendency (stays open while the cursor moves toward it); delay sliders
  [F] https://www.gamewatcher.com/crusader-kings-3-tutorials-highlighted-text-encyclopedia
- The encyclopedia uses the same highlighted words; new concepts hook into both automatically [F]/[S]
  https://www.gamingonlinux.com/articles/16333/
- Top: alert icons and a numbered opportunities icon; resources with hover breakdowns; right: the outliner (armies,
  holdings, pinned characters) above department buttons; the decision window shows requirements, consequences and costs
  before committing; the character window opens on the left from the portrait, with traits, attributes, dynasty,
  titles and tabs [F] https://www.gamepressure.com/crusader-kings-3/interface-description/z2f0f6
- Interactions: an acceptance widget (base plus modifiers), hidden modifiers shown as "positive / negative effect", a
  decline-consequence line, hooks that add or force acceptance [S]; a known bug where the menu's red X disagreed with
  the tooltip's "will accept", two sources of truth [S]; out-of-character choices stay available at a stress cost [S].

**Victoria 3**
- Dev Diary #29 (User Experience): "the right information at the right time", "clear feedback about cause and effect";
  nested tooltips for Game Concepts (an integrated dictionary) and number breakdowns; lock options; tooltips predict
  outcomes; graphs over time; state names highlight on the map; lenses = a map mode plus actions [S]
  https://forum.paradoxplaza.com/forum/developer-diary/victoria-3-dev-diary-29-user-experience.1506484/
- Dev Diary #74 (UX Improvements): per-type message settings (how it shows, whether it pauses); notifications cut by
  about half, minor types off by default, some only when they concern you; rebindable shortcuts; nested tooltips laid
  out so moving into one does not open another; lists sortable with group-by and filters; jumps between related panels;
  the AI acceptance display shows which offer would flip the answer; blocked diplomatic plays listed with what blocks
  them; map modes fade; counters hidden until relevant; battle breakdown tooltips [F]
  https://www.paradoxinteractive.com/games/victoria-3/news/dev-diary-74-ux-improvements
- Dev Diary #104: outliner tabs (Pinned, Economy, Politics, Diplomacy, Military, All, custom); keeping scroll position
  was the most wanted fix [S]. Dev Diary #117: structured "cooltips" instead of long text strings [S]. Dev Diary #51:
  an encyclopedia entry can walk the player to the related UI [S]. Criticism: each task led to "multiple tooltips,
  panels, tabs and icons" [S] https://exputer.com/reviews/victoria-3/

**Europa Universalis V**
- Update 1.1: top alerts can be muted permanently, with a list of hidden alerts to restore; collapsible unit panels;
  more map modes [F] https://www.gamewatcher.com/news/europa-universalis-5-rossbach-update-1-1-hidden-alerts-army-navy-templates-quality-of-life-changes
- Automation toggles per area (trade, building, estate taxes), partial delegation [F]
  https://acoup.blog/2025/10/31/miscellania-europa-universalis-v-confirmed-first-impressions/
- Criticised: sub-screens with sub-sub-screens; icon-heavy economy tooltips; a critical shortage warning easy to miss;
  tiny vital buttons that blend into information icons; praised: map modes [F]
  https://scanlines.substack.com/p/my-first-125-hours-of-europa-universalis

**Path of Exile (1 and 2)**
- Item tooltips: header coloured by rarity; sections divided by separators (enchant, implicit, explicit); local
  modifiers tint the base line; Alt shows the advanced view (prefix or suffix, tier, roll range); Ctrl+C copies the
  item as text [S] https://poewiki.net/wiki/FAQ ; comparison with the equipped item [GK].
- PoE 2 keyword tooltips chain with Alt; complaints: never taught, the second window's terms unreachable, depth
  silently capped at two [F] https://www.pathofexile.com/forum/view-thread/3595606
- Passive tree: search makes matches pulse even zoomed out [S]; Enter pans to matches (PoE 2) [S]; highlight similar
  and shortest-path toggles on the web tree [F] https://www.pathofexile.com/passive-skill-tree ; node scope by colour
  and depth-priced refunds (PoE 2 weapon sets) [F] https://maxroll.gg/poe2/resources/poe-2-passive-tree-and-dual-specialization
- Stash search: matches outlined, the rest dimmed; regex accepted but length-capped [S]. PoE 2 gems: hovering a support
  shows which skills can take it; an incompatible pairing explains why [S].

## Best-of-best synthesis (adopted in `design/ux/interaction-patterns.md` v2)

| Category | Best source | Adopt | Avoid |
|---|---|---|---|
| Tooltips and concepts | CK3 / Vic3 | Underlined terms; timer lock with a visible lock bar; middle-click lock; a forgiving hover corridor; a breadcrumb past level 2; concepts auto-registered in the wiki | PoE 2: untaught chaining, unreachable second-window terms, silent depth changes |
| Number breakdowns | Vic3 | Total first, base, contributions sorted by size with signs, each a concept link; a prediction line before acting; sparklines for seasonal values | Icon-only rows; fold tiny rows into "Other (n)" |
| Panels | Vic3 + CK3 | The selected entity on the left, the outliner on the right; links with history; remember scroll and tab | Sub-sub-screens (EU5); information icons that look like buttons |
| Interactions | CK3 + Vic3 | Grouped verbs, each with cost and verdict; breakdown and decline consequence on hover; the levers that would flip a refusal; blocked rows with the reason | CK3's red X versus tooltip mismatch: compute once |
| Notifications | Vic3 #74 + EU5 1.1 | Toasts, an alert row, a season report; per-type "blocks End turn / report only / silent"; permanent but reversible mute; minor types off by default | Alert floods; dismissals that return; critical warnings that look routine |
| Outliner | Vic3 | Tabs, a pin on everything, one live number per row, sortable, collapsible | Truncated numbers; lost scroll |
| Map modes | EU5 / Vic3 | A grouped mode bar, a legend, hover values, fades, lenses (mode + actions) | Actions only inside modes |
| Lists | Vic3 + PoE stash | Ctrl+F search, sortable columns, group-by, persistent filter chips, highlight in place | Regex as the only power tool |
| Item tooltips | PoE | Rarity header, separated sections, Alt for detail, comparison deltas first, Ctrl+C copy | Text walls |
| Tree and graph views | PoE + Path of Building | Zoom, pan, pulsing search, path preview with cost and net change, pending Apply / Reset, distinct node classes, visible refund price | Undifferentiated node visuals; commit on click |
| Combat log | (none of the four) | Header bars, playback, filter by actor and type, folded repeats, per-hit breakdown, result and top reasons first | Making the player read a raw log for the result |
| Top bar | CK3 / Vic3 | Few resources, each with a season delta and breakdown; hidden until relevant | Rarely used stats on the bar |
| Costly actions | CK3 decisions | A decision window with requirements, costs and consequences for big choices; nothing for cheap reversible ones | Dialog fatigue |
| Shortcuts | Vic3 / PoE | All rebindable; shown in every tooltip; conflicts checked | Modifier clashes |
| Automation | EU5 | Per-area toggles, partial delegation, reported in the season report, always inspectable | Automation that hides systems |

## Not to copy
1. Unlimited or unpredictable tooltip depth. 2. Icon-only rows. 3. Information icons that look like buttons, tiny vital
buttons. 4. Sub-sub-screens. 5. Alert floods and dismissals that return. 6. Two calculations for one verdict.
7. Undiscoverable power features. 8. Text-wall tooltips. 9. "Ship now, fix the UI later". 10. Real-time pause rules
(translate them into turn rules). 11. Any game's art, icons or frames: genre conventions only.

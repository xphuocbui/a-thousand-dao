# HUD Design

> **Status**: **Approved 2026-11-22** (lean `/design-review` round 6, after full rounds 1–4 and lean round 5; history in `design/gdd/reviews/hud-review-log.md`) **Changed after approval, 2026-11-22 (user request):** map bubbles, elements 30–32 (Map bubbles); lean round 7 NEEDS REVISION (16 fixes applied), lean round 8 NEEDS REVISION (2 fixes applied), **lean round 9 APPROVED**, all the same day. **Changed after approval, 2026-11-22 (person window, `design/ux/person.md`):** current places for people bubbles and pins, the share of the season left in the Focus preview, numbers follow the language, gamepad X on a person; lean round 10 NEEDS REVISION (fixes applied), **lean round 11 APPROVED**. **Changed after approval, 2026-11-23 (user request):** grand-strategy resource boxes in the top bar (linh thạch, lifespan, cultivation, rating, renown, sect contribution; elements 2, 8, 10, 33–35); realm, cultivation and lifespan move up from Z3, which keeps the portrait; a Borders toggle on the map (element 13; provinces as a drawing layer only); lean round 12 NEEDS REVISION (3 blocking, 7 recommended, all applied); lean round 13 NEEDS REVISION (1 blocking: the alert row's width; 6 recommended; all applied); **lean round 14 APPROVED** (0 blocking; 5 recommended, applied).
> **Author**: user + ux-designer
> **Last Updated**: 2026-11-23
> **Platform Targets**: PC (Steam / Epic); keyboard and mouse; gamepad partial (from `.claude/docs/technical-preferences.md`; `project.yaml` has no `platform` block)
> **Template**: HUD Design
> **Reviews**: `/ux-review` 2026-11-22 (headless Sonnet): NOT ASSESSED (no accessibility tier), 0 blocking, 6 advisory; all 6 fixed the same day (edge margin, Must Show vs MUST KEEP, area budget, M / Tab / F6 keys, performance criterion, split criteria). Round 2 2026-11-22 (headless Sonnet, after the tier was committed): **APPROVED**, 0 blocking, 5 advisory; 1–4 fixed the same day (committed tier cited, rebindable keys, colourblind mode and brightness in settings, End turn hold-or-confirm); 5 (Z2 budget at 1280×720) is checked on the first build screenshot
> **Scope**: the main map screen (the game board) and its chrome, plus the window, tooltip and turn rules every other screen follows
> **Reference**: Crusader Kings III's map, window and nested-tooltip model (user, 2026-11-21); Civilization's end-turn flow for the season turn

---

## HUD Philosophy

**The map is the game board; everything else is a window on it.** The game is a world sim played on the continent map,
like CK2 and CK3. The map stays on screen almost all the time. The player reaches everything else through buttons and
through the people, places and things on the map. The HUD is **information-dense on demand**: a few readouts are always
visible, and everything else is one hover or one click away. Nothing is hidden: every number can explain itself
(Pillar 2, *Every Number Is Bounded and Visible*).

**Rules every later screen follows**

1. **Seasons are turns, as in Civilization.** In each season the player:
   - picks one season focus: cultivate, brew, explore, a mission, travel, and so on;
   - does any number of free actions around it: trade, talk, plant and harvest, equip, spend Đạo Đồ points, manage the
     abode;
   - then presses **End turn**, which resolves the focus and the world tick.

   There is no pause-and-play and no speed control. Commands that span several seasons (closed-door cultivation, long
   journeys) confirm first, then run their End turns in one go. *(User decision 2026-11-21, option A. Today's code passes
   the season inside each timed action, `src/gameplay/session/game_session.gd` `_pass_season`; the UI build splits
   choosing the focus from ending the turn. Time & Turn #4 keeps its per-season rates.)*
2. **End turn can be blocked.** An event or decision that needs an answer blocks End turn until the player answers it.
   The button names what's waiting. *(Matches today's code, which refuses timed actions while an event is pending.)*
   **While a blocking event waits, the player can look but not change** (user decision 2026-11-22), so nobody changes
   their build to dodge an event they have already seen. *Allowed:* opening any window, the map, the wiki and
   tooltips; pinning; choosing next season's focus; saving. *Locked until the event is answered* (and still locked
   while its card is minimised): equipping and unequipping, using pills and other consumables, spending Đạo Đồ points,
   changing technique slots, the formation editor, trading, gifts and other verbs that change a person, planting and
   harvesting, free brews (Capability #10's extra brew) and abode changes. A locked control shows a lock mark and its
   tooltip says why; on a full screen it is shown the same way. *(Today's code allows
   these free actions with an event pending, `_guard(false)`: a dependency on the session code.)*
3. **Windows, not menus.**
   - **Panels over the map:** the character sheet, a person card with traits, a place, a sect, inventory,
     relationships, journal, rankings, news.
   - **Their own full screens:** the cave abode, fight (`design/ux/fight-screen.md`), Đạo Đồ, brewing, the formation
     editor, tribulation, succession.
   - Windows link to each other: a name in one window opens that person's window. Back and forward history connects
     them.
4. **Hover anything for information.** Words, people, items, places and numbers all have a tooltip. Tooltips nest: a
   highlighted concept word inside a tooltip opens its own tooltip. A tooltip locks in place after a short delay or on a
   middle click, so the player can move onto it. Every number's tooltip is its Breakdown (its sources and any cap that
   applies). The key fact, such as a cost, a penalty or a risk, always sits in the first tooltip, never a level down.
5. **An in-game wiki** holds the reference material: the traits catalogue, Effects, modifiers, herbs, rules and the
   Codex. Highlighted concept words link to their wiki page.
6. **Right-click a person for their actions.** On the map or in any window, right-clicking a person opens their
   interaction verbs (NPC Interaction & Dialogue).

---

## Information Architecture

### Full Information Inventory

Gathered 2026-11-21 from the UI Requirements sections of 28 of the 31 system GDDs in `design/gdd/` (game-concept,
systems-index and gdd-cross-review are not systems). `sects.md`, `npc-traits.md` and `npc-traits-catalogue.md` have no
such section; the user confirmed sects and NPC traits need screens and the traits catalogue goes to the in-game wiki.
Items are what the **map screen** must carry or lead to; the detail inside each window belongs to that window's own UX
spec.

### Categorization

Approved by the user 2026-11-21, group by group. **Must Show** = always on screen; **Contextual** = appears when
relevant; **On Demand** = the player opens it; **Hidden** = never shown as text.

**Group 1: the character's readouts**

(Since 2026-11-23 realm, stage and level, the cultivation bar and lifespan show as top-bar resource boxes, elements 8 and 10, not in Z3.)

| Item | Category | Source |
|---|---|---|
| Realm, stage, level (the layer, tầng, in Luyện Khí) | Must Show | canh-gioi.md |
| Cultivation bar: progress; rate per season and seasons to the next level and the bottleneck on hover | Must Show | canh-gioi.md, cong-phap.md |
| Lifespan: age / lifespan (thọ nguyên) | Must Show | canh-gioi.md, living-world-tick.md |
| Health, linh lực | Contextual: a small bar shows when below full | combat-defence.md, character-stats.md |
| Heart demon, toxicity, vitality bands | Contextual: an icon on the portrait once past a band | character-stats.md |
| Power number (rating) | Must Show: a top-bar box (since 2026-11-23); the realm rank ("12th of 835 Trúc Cơ") on hover | power-rankings.md |
| Renown (danh vọng) | Must Show: a top-bar box (user, 2026-11-23) | character-stats.md (merit, incense, renown) |

**Group 2: resources and the turn**

Since 2026-11-23 (user) the character's readouts and resources show as **resource boxes** on the top bar, grand-strategy style (element 2's form): linh thạch, lifespan, cultivation (realm, level, progress and the rate here), rating, renown, and sect contribution while in a sect.

| Item | Category | Source |
|---|---|---|
| Linh thạch | Must Show | regional-economy-trade.md, item-database.md |
| Sect contribution (cống hiến) | Contextual: a top-bar box while the player is in a sect | sects.md |
| Season and year | Must Show | Time & Turn #4 |
| Season focus chosen, and the End turn button (blocked state names what's waiting) | Must Show | HUD Philosophy rules 1–2 |
| Unspent Đạo Đồ points | Contextual: a badge on the Đạo Đồ button when above 0 | dao-do.md |
| Multi-season command progress (closed door: years left) | Contextual | living-world-tick.md rule 17 |

**Group 3: the map**

| Item | Category | Source |
|---|---|---|
| The player's bubble (element 30) and the current place's name | Must Show | travel-map.md |
| The abode bubble (element 31) | Contextual: when the player has a home | cave-abode.md |
| Area bubbles: what can be done at nearby known places (element 32) | Contextual: region zoom only | travel-map.md, regional-economy-trade.md, sects.md, quests.md, npc-relationships.md, spirit-herbs.md |
| Places, sect seats, cities and region borders at region and continent zoom, with a legend | Must Show (the map is the board); region borders behind the Borders toggle (element 13), on by default | travel-map.md |
| Route preview when hovering or choosing a destination: seasons, danger, encounter chance, teleport fee | Contextual | travel-map.md (`route`) |
| Map modes: terrain, sect territory, qi density by element, prices last seen, specialties, danger, known people | On Demand (buttons) | travel-map.md, regional-economy-trade.md, trade-goods.md, npc-relationships.md |
| Place stat block (qi layers, the character's match and density) | On Demand (place tooltip and place panel) | travel-map.md (`place`) |
| The active clue's search area | Contextual | travel-map.md (`search`) |

**Group 4: alerts** — a CK3-style row of icons on the top bar: hover for detail, click to open the window it concerns,
right-click to snooze until next season.

| Item | Category | Source |
|---|---|---|
| Breakthrough ready, or the bottleneck panel at great perfection | Contextual alert | canh-gioi.md |
| Herbs matured or Frozen; abode upkeep short or works fading; rent due | Contextual alert | spirit-herbs.md, cave-abode.md, travel-map.md |
| Quest deadline at risk; favours owed or presented; loans due | Contextual alert | quests.md, npc-relationships.md, npc-interaction-dialogue.md |
| Advisor warnings: toxic pill, heart demon before Nascent Soul, unused glimpse, a herb that can't grow at home | Contextual alert, snoozable | character-stats.md, dao.md, spirit-herbs.md |

**Group 5: what each season brings**

| Item | Category | Source |
|---|---|---|
| Season summary after End turn: the focus's result, up to 3 news lines, herbs matured, upkeep paid | Contextual: a window that opens after End turn | living-world-tick.md, spirit-herbs.md, cave-abode.md |
| Seclusion digest after a multi-season command (totals, at most 12 lines grouped by person) | Contextual (replaces the summary) | living-world-tick.md rule 17 |
| Event card: a centre window; options with costs, checks and odds | Contextual; blocks End turn | event-engine.md |
| Quest offer: as an event or from a place's board | Contextual | quests.md |
| News log; stories panel | On Demand | living-world-tick.md, event-engine.md |

**Group 6: windows behind buttons** (all On Demand)

| Window | Opens as | Source |
|---|---|---|
| Character sheet: talents, root, techniques, stats with Breakdowns, craft masteries, resistances, power | Panel over the map | character-stats.md, linh-can.md, cong-phap.md, combat.md, modifiers.md |
| Inventory and equipment | Panel | item-database.md |
| Relationships and the known list | Panel | npc-relationships.md, npc-interaction-dialogue.md |
| NPC screen with traits (from a person card) | Panel | npc-interaction-dialogue.md, npc-traits.md |
| Sect screen | Panel | sects.md |
| Rankings | Panel | power-rankings.md |
| Journal and quests | Panel | quests.md |
| Places (every known place as a list; the keyboard and screen-reader path to the map) | Panel | travel-map.md |
| Market and trade (at a market only) | Panel | regional-economy-trade.md, trade-goods.md |
| Wiki and Codex (traits catalogue, Effects, modifiers, herbs, rules, Lives) | Panel | codex-karmic-carryover.md, npc-traits-catalogue.md, effects.md, modifiers.md |
| Đạo Đồ; the Dao list and graphs | Full screen | dao-do.md, dao.md |
| Cave abode (fields, arrays, works) | Full screen | cave-abode.md, spirit-herbs.md, formations.md |
| Brewing | Full screen | alchemy.md |
| Formation diagram editor | Full screen | formations.md |
| Fight | Full screen | combat.md, `design/ux/fight-screen.md` |
| Tribulation | Full screen | thien-kiep.md |
| Succession (on death) | Full screen | codex-karmic-carryover.md |

**Group 7: hidden**

| Item | Why | Source |
|---|---|---|
| The world tick itself (no control; the player sees its news) | The world runs on its own | living-world-tick.md |
| The world seed's ledger; hidden tiles | Secrets stay secret | world-generation.md, travel-map.md |
| Debug-only views: the true map, the money ledger, event validator warnings | Testing tools, debug terminal only | travel-map.md, regional-economy-trade.md, event-engine.md |

**Philosophy check** (recounted 2026-11-23): 9 Must Show *information* items (the cultivation box: realm, stage, level, progress and the rate here; lifespan; linh thạch; rating; renown; season and year; focus and End turn; marker and place (two elements, 17 and 30); the map). HUD Element Specifications adds 3 *controls* that are also always on screen (wiki and menu, window buttons, portrait), so with the marker-and-place item counting as two, **13 elements are Must Show** (elements 2, 3, 4, 5, 7, 8, 10, 14, 15, 17, 30, 33, 34). This fits "information-dense
on demand".

**Terms:** *Must Show* means on screen at the base layout. *MUST KEEP* (Information Hierarchy) means it never drops,
even in the compact layout. A Must Show control can be SHOULD KEEP: it stays on screen but may shrink (window buttons
lose their labels) when space runs short.

---

## Layout Zones

Arrangement A, "CK3 classic" (user choice 2026-11-21, over a Civ-style and a portrait-corner arrangement). Base layout
1920×1080 (16:9). The map fills the screen behind every zone. **Safe zone:** PC has no TV safe area; every zone keeps a
16 px margin from each screen edge (`edge_margin`).

```
+--------------------------------------------------------------+
| Z1 [!][!] [宗85▲10][◆1,240▲30][⧖136y][☯TrucCo3 ▓▓░62%▲4][⚔1,512▲8][★340▲5] Xuan Y3|W|≡|
+--------------------------------------------------------------+
| Z6 panel (opens over |                                 | Z2   |
|    the map, left)    |                                 | [Ch] |
|  < >  Character      |          Z7 event card /        | [In] |
|  ...                 |          season summary         | [Re] |
|                      |          (centre)               | [Se] |
|                      |                                 | [Qu] |
|                      |             M A P               | [Rk] |
|                      |                                 | [Nw] |
|                      |                                 | [Pl] |
|                      |                                 | [ĐĐ] |
|                      |                                 | [Ab] |
|                      |                                 |------|
|                      |                                 |outli-|
|                      |                                 | ner  |
| Z3 +--------+            Z4 [terrain][sect][qi][price][bdr] +----+
|    |portrait| (health, linh lực bars) | Z5 focus: [Cultivate▾]|
|    +--------+ (band icons)            |    [   END TURN    ]  |
+--------------------------------------------------------------+
```
(Numbers in the wireframe use the English format; the Vietnamese UI shows 1.240, Localisation. Z1's boxes, left to right: sect contribution (in a sect), linh thạch, lifespan left, cultivation, rating, renown; the glyphs stand for the painted icons.)

| Zone | Where | Holds |
|---|---|---|
| **Z1 Top bar** | Full width, top | Left: the alert row. Right: the resource boxes as one **right-anchored** group (elements 35, 2, 10, 8, 33, 34, left to right; the contextual sect contribution box is leftmost, so its appearing or leaving never moves the others, and the alert row's length never moves any box), season and year, then the wiki (W) and the game menu (≡) (CK3 keeps these bottom-right; here Z5 is reserved for the turn) |
| **Z2 Right column** | Right edge | Window buttons: character, inventory, relationships, sect, quests and journal, rankings, news, places, Đạo Đồ, abode. Below them, the **outliner**: pinned people, places and quests, collapsible |
| **Z3 Portrait cluster** | Bottom left | The player's portrait (click: character sheet). Contextual: health and linh lực bars, band icons. (Realm, cultivation and lifespan moved to Z1's boxes, 2026-11-23) |
| **Z4 Map controls** | Bottom centre | Map mode buttons; the region and continent zoom toggle; the Borders toggle (it stays its own button when the compact layout folds the map modes into a dropdown) |
| **Z5 Turn block** | Bottom right | The season focus selector, the End turn button (a blocked state names what's waiting), progress of a multi-season command |
| **Z6 Panel area** | Left, about ⅓ of the width, over the map; from the bottom of Z1 to the top of Z3, so it never covers the portrait cluster | One panel at a time: character, person, place, sect and so on. Back and forward arrows step through the window history (the last `history_max`, 20, windows, like a browser: opening a new window after going back drops the forward entries); opening a name inside a panel replaces the panel |
| **Z7 Centre windows** | Centre of the map area; with a panel open, centred in the space right of Z6, so the two never overlap. A temporary overlay: its width is capped by `centre_width_max` and its height by the viewport minus Z1, minus the tallest bottom zone (Z3, Z4 or Z5) it overlaps horizontally, minus 2 × `edge_margin`, scrolling inside when the content is taller (option buttons stay pinned below the scroll); one Z7 window shows at a time, the rest wait in order (a comparison opened while a blocking event card is up replaces it for the moment: the card is minimised); it does not count toward `panel_share_max` | Event cards, the season summary, quest offers, the multi-season confirm dialog. An event card can be minimised to its alert to look at the map first, but it still blocks End turn |
| **Tooltip layer** | Above everything | Nested, lockable tooltips (HUD Philosophy rule 4) |

**Full screens** (Đạo Đồ, abode, brewing, formation editor, fight, tribulation, succession) replace the map and all
zones except Z1: the top bar stays visible. Each has a back button to the map; its focus order is Z1, the back button,
then the content. A full screen with uncommitted edits (a planned Đạo Đồ path, an unsaved formation layout) asks
before leaving: keep, discard, or cancel. An event that fires on a full screen opens as a modal overlay on it, with the
Z7 rules. **Exception:** the fight and tribulation screens hide the top bar too, and succession has no back button
(there is no map until the next life begins); they are context-only screens with no exit mid-fight, and the fight spec's
own header replaces it (user decision 2026-11-21). The fight screen keeps its own spec (`design/ux/fight-screen.md`);
its play/pause and 1×/2×/4× controls set **replay speed** and are not game time, so they do not conflict with HUD
Philosophy rule 1.

---

## HUD Element Specifications

What sits on the map screen. The contents of each window belong to that window's own UX spec. Approved by the user
2026-11-21; elements 23–28 added 2026-11-22 (full design review item 6), 29 after the re-review, 30–32 after approval at the user's request; elements 6 and 32 and the Focus preview changed
after approval for the person window (2026-11-22, lean rounds 10–11).

| # | Element (zone) | Category | Shows | Form | Updates | Animation |
|---|---|---|---|---|---|---|
| 1 | Alert row (Z1) | Contextual | One icon per open alert (Information Architecture, Group 4); hover: detail, click: opens the window concerned, right-click or Delete on a focused alert (gamepad X): snooze until next season; the row holds at most `alerts_shown_max` icons (`alerts_shown_max_compact` in the compact layout) and never more than fit in the space left of the resource boxes; blocking alerts come first and are never hidden: those that do not fit fold into their own "+N !" icon, drawn with the blocking frame and always shown, whose tooltip lists them; the non-blocking rest fold into "+N" | Icon row, newest left | When a season resolves, or when an action changes a condition | A new icon slides in once; no pulsing |
| 2 | Linh thạch box (Z1) | Must Show | Amount held; change: what the last resolution did (▲ / ▼ with sign); hover: the season's income and costs; click: inventory | Resource box | Event-driven | The number ticks to its new value; a brief flash on a loss |
| 3 | Season and year (Z1) | Must Show | "Xuân, year 3"; hover: the date and seasons per year | Text | On End turn | Changes in step with End turn |
| 4 | Wiki and menu (Z1) | Must Show | The wiki opens the wiki panel; ≡ opens save, settings and quit | Two icon buttons | Static | None |
| 5 | Window buttons (Z2) | Must Show | Character, inventory, relationships, sect, quests, rankings, news, places, Đạo Đồ, abode; badges such as unspent Đạo Đồ points or unread news | Icon buttons with number badges | Event-driven | A badge pops once when it appears |
| 6 | Outliner (Z2) | On Demand (collapsible) | Pinned people (where they are now; changed 2026-11-22, `design/ux/person.md`), places, quests (seasons left) | List; a click centres the map or opens the window | On End turn | None |
| 7 | Portrait (Z3) | Must Show | The player; hover: name, root line; click: character sheet | Portrait frame | On a realm change | None |
| 8 | Cultivation box (Z1) | Must Show | "Trúc Cơ 3" ("tầng 7" in Luyện Khí) and the % to the next level, with a thin progress strip along the box's bottom edge; change: ▲ the progress per season if the player cultivates **at the current place** (density and match here); hover: the rate-per-season Breakdown, seasons to the next level and to the bottleneck, and how this place compares with the abode; click: character sheet | Resource box, double width | On End turn; on a move (the rate) | Short glow on a breakthrough; the bar fills over `motion_slow` after End turn |
| 9 | (Merged into element 8, 2026-11-23) | — | The cultivation bar is the bar inside the cultivation box | — | — | — |
| 10 | Lifespan box (Z1) | Must Show | Years left ("136 y"); change: shown only when lifespan was gained or lost by something other than time (▲ 50 y after a breakthrough), never the season's own passing; hover: age / lifespan and the lifespan Breakdown; click: character sheet | Resource box | On End turn | Turns amber with an hourglass mark when `lifespan_warn_share` (10 %) or less of the lifespan is left |
| 11 | Health and linh lực (Z3) | Contextual | Only when below full | Thin bars under the portrait | Event-driven | Fade in and out |
| 12 | Band icons (Z3) | Contextual | Heart demon, toxicity or vitality once past a band; hover: the band and its effect | Small icons on the portrait | On End turn | Fade in |
| 13 | Map modes and zoom (Z4) | On Demand | Terrain, sect territory, qi by element, prices last seen, specialties, danger, known people; region or continent zoom (+ and −, the wheel); a **Borders** toggle: **region borders**, a thin plain ink line along the 20 regions over the painted map, in every mode, on by default, a player setting (one for all saves) (the user's "provinces" are this drawing layer only; tiles stay the rule unit, user 2026-11-23). In sect territory mode the sect's own control border (patterned, with the sect's name) is drawn above it, so the two never read alike | Toggle buttons; the active one lit | Player-chosen | The map cross-fades between modes |
| 14 | Season focus selector (Z5) | Must Show | The chosen focus; a click opens the focus comparison (element 29) | Button | Player-chosen | None |
| 15 | End turn (Z5) | Must Show | "End turn: <focus>"; armed: "Confirm end turn"; blocked, in this order of precedence: "Event waiting: <title>", "Check focus: <reason>", "Checking focus…"; a click (or Enter) on a blocked button opens the blocker; label changes are announced; a non-blocking reminder pip when Đạo Đồ points are unspent or a matured herb waits, with the details in its tooltip | Large button | Event-driven | A gentle glow when ready; none when blocked |
| 16 | Multi-season progress (Z5) | Contextual | "Closed door: year 2 of 5", and Stop (takes effect at the next season boundary) | Bar + text | Each simulated season | Steady fill |
| 17 | Current place name (map) | Must Show | The name of the place the player is at, beside their bubble (element 30); hover: the place tooltip | Map label | On a move | Moves with element 30 |
| 18 | Route preview (map) | Contextual | Hovering a place draws the route: seasons, danger, encounter chance, teleport fee | Line on the map + tooltip | On hover | Draws from the marker outwards |
| 19 | Clue search area (map) | Contextual | The active clue's area; seasons spent | Shaded area | On End turn | None |
| 20 | Panel frame (Z6) | On Demand | Title, back and forward arrows, close | Frame | — | Slides in from the left over about 0.15 s |
| 21 | Centre window frame (Z7) | Contextual | Event card, season summary, quest offer; minimise to an alert | Frame | — | Fades in |
| 22 | Tooltip | — | Content; highlighted concept words; a lock indicator | Floating box | On hover, or Q on the focused element | Appears after `tooltip_delay` (0.3 s); locks after `tooltip_lock_delay` (about 1 s), on a middle click or on a click (Tooltips) |
| 23 | Toast stack (above Z4) | Contextual | The result of a free action; at most 3, newest on top | Small text boxes | Event-driven | Fade in and out |
| 24 | Refusal note (beside the control) | Contextual | Why an action can't be done; reappears on hovering the control again | Small text box | On a refused click | None |
| 25 | Breakthrough banner (centre) | Contextual | The stage or realm reached | Banner | On a breakthrough | Fades in and out over `banner_seconds` |
| 26 | Back to map (full screens) | Contextual | Returns to the map screen | Button, top left under Z1 | Static | None |
| 27 | Multi-season confirm dialog (Z7) | Contextual | Seasons, lifespan spent and age at the end, expected gain, what stops it (The turn) | Centre window | On choosing a multi-season command | Fades in |
| 28 | Map legend (map, top left below Z1; right of Z6 when a panel is open) | Contextual | The active map mode's key: hues, patterns and icons, plus the bubble kind icons in every mode; announced on a mode change | Small box | On a map mode change | None |
| 29 | Focus comparison (Z7) | Contextual | Every focus the player can take, side by side, with its preview fields (The turn: Focus preview); unavailable focuses greyed with their reason; "Check focus" highlights the reason | Centre window; a table for screen readers; a list on gamepad | When opened, and at each season start | Fades in |
| 30 | Your bubble (map) | Must Show | A round portrait badge at the player's location, replacing a plain marker; a status mark while travelling (an arrow) or in closed-door cultivation; hover: name, realm, place; click: the character sheet | Map badge | On a move | Slides along the route (as element 17's marker did) |
| 31 | Abode bubble (map) | Contextual: when the player has a home, at every zoom | A house badge at the home's place; click: the cave abode full screen (changes that need the player present say so, and are locked while away) | Map badge | On a home change | None |
| 32 | Area bubbles (map) | Contextual: region zoom only | What can be done at the current place and at known places within `bubble_trip_seasons`: market, sect and quests, people the player knows who are there, explore and search; each an icon and a count (Map bubbles); hover: the place's name and what is there, and for another place the route's seasons, danger and fee (drawing the route preview, element 18); a merged bubble lists its parts; Q or F2 opens the tooltip from the keyboard | Map badges | At each season start and on a move | Fade in |
| 33 | Rating box (Z1) | Must Show | The power number (power-rankings.md); change: since last season (▲ / ▼ with sign); hover: the realm rank ("12th of 835 Trúc Cơ") and what moved it; click: rankings | Resource box | On End turn; after a rating fight | The number ticks to its new value |
| 34 | Renown box (Z1) | Must Show | Renown (danh vọng); change: last season's (▲ / ▼ with sign); hover: where it came from this season; click: character sheet | Resource box | On End turn; on an event | The number ticks |
| 35 | Sect contribution box (Z1) | Contextual: while in a sect | Contribution (cống hiến) held; change: last season's net; hover: earned and spent, and the next rank's need; click: sect window | Resource box | On End turn; on a sect action | Fades in on joining, out on leaving |

**Resource box** (elements 2, 8, 10, 33–35; art bible 7.13): a small wood plaque with the resource's painted icon, its tabular number and the season's change as ▲ or ▼ with a sign (never colour alone). Each box has a fixed width (`resource_box_width`, 144 layout px; the cultivation box `cultivation_box_factor`, 2.25, times that; `resource_box_width_compact`, 112, in the compact layout), so a changing number never moves the bar. A number above 99,999 is shortened, always rounded down: thousands up to 999,999 ("123k", "999k"), then millions with one decimal ("1.2M" for 1,250,000; in Vietnamese "1,2M", numbers following the language), the full number in its tooltip and accessible name. Z1 is one row, `top_bar_height` (48 layout px, the 36 px boxes inside the bar's frame) high; the cultivation box's progress bar is a thin strip along its bottom edge, so the realm name keeps the row. A box is one focusable control: Q (or hover) opens its tooltip, Enter (or a click) opens its window, and its accessible name reads the resource, the number and the change ("Linh thạch 1,240, up 30 this season"). In the compact layout the change shows as the ▲ / ▼ mark only, the number moving into the tooltip (Visual Budget).

- **The change** is what the last season resolution did: the value right after it minus the value right before End turn. It is **frozen until the next End turn**: buying or earning during the season moves the number, not the change. The lifespan box compares the lifespan itself, not the years left, so time passing never shows as a change (a five-season closed door does not read ▼ 1¼ y). A multi-season command is one End turn, so its change is the whole command's. On a new game, after loading a save and after succession there is no baseline: no change shows until the next End turn.
- **Renown** shows "—" until the game tracks it: `character-stats.md` has the stat (≥ 0) but no sources or season change yet (Open Questions). Its accessible name then reads "Renown: not tracked yet"; it stays on screen (Must Show) so the bar's layout does not change when it starts.
- **The cultivation rate here** is the rate-per-season Breakdown the old cultivation bar already showed on hover (element 9, approved 2026-11-21: `canh-gioi.md`'s rate per season at the current place's density and qi, `CultivationRules.rate_per_season`), as a share of the level's requirement. No new rule: only a read added to the GameQuery contract (ADR-0006), `GameQuery.resources`. At the bottleneck or a realm cap (`GameQuery.resources` `held`, from `CultivationRules.at_bottleneck` and `is_capped`) the box shows no change and its tooltip says why; while travelling it is the rate at the place the player is in now.
- **Several boxes open the character sheet** (cultivation, lifespan, renown): intended, each on its own section.
- **On full screens** (Z1 stays) the boxes are tooltip-only: Enter or a click does nothing there, since Z6 is hidden.
- **A provisional rating** (from world generation, `power-rankings.md`) shows with a "~" before the number, in the box and its tooltip, and its accessible name reads "Rating about 1,512, provisional".

### Tooltips

Added 2026-11-22 after the full design review (blocker 4); revised after re-reviews 2 and 3. Godot's built-in tooltip
cannot lock, nest or be hovered into, so the game needs its own tooltip layer (a dependency; likely an ADR). Esc on a
tooltip follows the Esc rules in Platform Adaptation.

- **One chain.** Tooltips form one chain at a time: a root and its children. Hovering a new source while an unlocked
  chain is open replaces it; while a locked chain is open, hovering elsewhere opens nothing until the chain closes.
- **Opening.** Hovering opens a tooltip after `tooltip_delay`; hovering a highlighted word inside a tooltip opens the
  next level after the same delay. Moving the pointer into an open tooltip keeps it open.
- **Locking.** A tooltip locks once the pointer has rested in it for `tooltip_lock_delay`, on a middle click, or on a
  click inside it. **Click-to-lock on the source** works only for things that have no click action of their own
  (text, numbers, icons); a button or an alert keeps its click.
- **Depth.** At most `tooltip_depth_max` (5) levels. At the last level, highlighted words read "opens in the wiki":
  hovering them does nothing, and a click or Enter opens the wiki page.
- **Closing.**
  - **An unlocked tooltip** closes once the pointer has been off it, its source and its children for
    `tooltip_close_grace` (0.3 s by default, a player setting from 0.3 to 2 s), so the pointer can cross from a source
    into its tooltip.
  - **A locked tooltip never closes on a timer.** It closes on Esc, on a click outside the chain, when its source
    disappears, when the season changes, or when a window opens over it. The click outside is consumed: it does not
    also activate what is under it.
  - Leaving a child tooltip returns to its parent.
  - **Esc closes only the top tooltip**; pressing it again closes the next.
- **Placement.** Beside the thing described, flipping to stay inside `edge_margin`, never covering what it describes.
  Each child opens beside its parent, on alternating sides. When there is no room (a high UI scale), older levels
  shrink to a title strip at the text floor size; clicking or focusing a strip brings that level back.
- **Content.** The first tooltip always holds the name, the key fact (cost, penalty or risk) and a one-line summary,
  with the Breakdown below. A control that has a tooltip says so to screen readers ("has details: Q").
- **Link styles** (user decision 2026-11-22). Every piece of **text or number that has a tooltip is underlined**, in
  readouts, tooltips, panels and windows, then styled by what it is: terms and concepts in the term colour; numbers
  with a Breakdown bold; people bold, in their relation colour (friend, neutral, hostile); places italic; items in
  their rarity colour; sects bold italic, in the sect's colour. Buttons, map bubbles and icons keep their own look.
  The underline is the constant cue, so a style never relies on colour alone; the colours are data (`link_styles`,
  rarity colours to come from the art bible). In a readout only the part with the tooltip is styled ("Linh thạch
  **30**"); a resource box is one control, so its number is styled as a number.
- **Keyboard.** **Q** (or **F2**) opens the focused element's tooltip, already locked, **and moves focus into it**.
  Inside a tooltip, Tab and Shift+Tab move between its highlighted words and wrap around (zone Tab is suspended while a
  tooltip has focus; Shift+Tab from the first word reaches any title strips); Enter or Q on a word opens its tooltip;
  Esc closes the top one and returns focus to where it came from (the parent, or the source; End turn if the source is
  gone). A keyboard-opened tooltip does not close on pointer rules.
- **Gamepad.** Y opens the focused element's tooltip, locked, and moves focus into it; the d-pad moves between
  highlighted words; A opens one; B closes the top one.
- **Screen reader.** Each highlighted word is a real focusable control (a flat underlined link button in a flowing row
  of labels, not a rich-text link), and each tooltip has an "Open in wiki" button, so the content is reachable even if
  AccessKit cannot read rich-text links (Open Questions). The tooltip root has an accessible name and description, and
  an opened tooltip's text is announced.

### Places panel

Added 2026-11-22 after the full design review (blocker 5): the keyboard and screen-reader path to the map, which is
custom-drawn and exposes nothing to a screen reader.

- A **Places** window: key **P**, and a button in Z2.
- **Top row:** "You are here: <place>".
- **Below it:** every place the player knows, grouped by region and searchable. Each row shows its kind, the travel
  time in seasons, danger, the player's qi match there, the holder of its territory, how many known people are there,
  market and sect marks, the age of the last price seen ("prices seen 3 seasons ago"), an "in the clue's search area"
  flag, and **the actions available there, as in the Map bubbles table**; the current place's row offers its free
  actions as buttons, under the same locks and through the same focus comparison as the bubbles. Hidden places never appear: it reads the same map knowledge as the debug terminal's `map` view
  (`MapKnowledge.knows_place`).
- **Selecting a row** centres the map on the place and shows its route as text: seasons, danger, encounter chance,
  fee, and the travel modes available. **Enter** opens the place panel with its full details.
- **"Travel here"** opens the focus comparison with Travel to that destination preselected; the focus is set when the
  player confirms there.
- The active clue's search area is listed in text at the top of the panel while a clue is active.
- **The map in the focus order.** The map is a focus stop after Z4. With the map focused (or nothing focused), the
  arrow keys pan it and the focused place or bubble stays in view, clear of Z1–Z5 and an open panel. Tab visits the
  visible known places nearest first, and at each place that place's bubbles (the abode bubble and your bubble are
  visited at their place); Shift+Tab goes back. On a focused place, Enter opens its panel; on a focused bubble, Enter
  acts like a click; Enter ends the turn only when no place or bubble is focused (The turn: End turn input). Map modes (M) and zoom (+ and −) also have keys, so the map itself is usable without a mouse. With the
  mouse, dragging with the left or middle button pans.

### Map bubbles

Added 2026-11-22 at the user's request, after CK3's map bubbles (user decisions the same day). The map is where the
player acts from: bubbles show where they are, where their home is, and what can be done nearby.

- **Your bubble** (element 30) sits at the player's location at every zoom. **The abode bubble** (element 31) sits at
  the home's place at every zoom, when the player has a home.
- **Area bubbles** (element 32) show **only at region zoom**, at the current place and at known places within
  `bubble_trip_seasons` (1 season) of travel, measured from a full season (a season shortened by timed free actions
  does not shrink the reach; the focus comparison shows the real time). At continent zoom only elements 30 and 31 show.
- **Kinds**, each an icon and a count ("2 quests"): **market** (trade); **sect** (visit the sect); **quests** (open
  quests on the board); **people you know**: who is there now, at the current place and elsewhere (changed after
  approval, 2026-11-22, user decision in `design/ux/person.md`: the player always sees everything about everyone, so
  bubbles show where people are now, not where they were last seen); **explore and search**
  (discovered herb grounds and secret domains, and the active clue's search area, anchored on the nearest known place
  inside the area, or on the area's centre at region zoom). Quests at another place are those open on its board as last
  seen, with the same age.
- **What a click does:**

  | Bubble | At the current place | At another place |
  |---|---|---|
  | Market | The trade window (a free action) | The focus comparison with Travel to the place preselected |
  | Sect | The sect panel (free) | As above |
  | Quests | The quest board in the journal (free); a mission or quest stage opens the focus comparison with it preselected (a season action) | As above |
  | People you know | One person: their person card; several: the relationships list filtered to that place (free) | As above |
  | Explore and search | The focus comparison with Explore (or Search) preselected (a season action) | As above |

  The focus is set only when the player confirms in the comparison (The turn); no click ends a turn. The comparison's
  Travel label names what is at the destination ("market, 2 quests").
- **Clutter.** At most `bubbles_max` (12) area bubbles show, counted after merging. "Nearest" means route seasons from
  the player's place, ties broken by place id; the current place's bubbles are never dropped; places beyond the cap stay
  reachable through the Places panel. Bubbles merge only within one place's cluster; hovering a merged bubble lists its
  parts and clicking it opens that place's panel. A bubble under Z1–Z5 or an open Z6 panel is not drawn and not
  clickable. Every bubble is a click target of at least 24×24 screen pixels at the 75 % UI scale. When a bubble sits on
  a route line or a place marker, the bubble's tooltip wins.
- **Only what the player knows.** Only known places (`MapKnowledge.knows_place`) and people the player knows get
  bubbles; a hidden place, secret or person never does. A remote bubble's count of quests reads the player's
  last-seen data; its count of people is the true current count (2026-11-22, see People you know above). A person
  travelling between places counts at the place they left, and the tooltip names them "travelling to <place>"; a
  pinned person who dies stays in the outliner as "died" until the player unpins them.
- **While a blocking event waits**, bubbles whose window changes something (trade, gifts and verbs, abode changes) show
  the lock mark and still open their window for looking, with its changing controls locked (HUD Philosophy rule 2).
  Season-action and Travel bubbles stay active, since choosing next season's focus is allowed; the click minimises the
  blocking event card (it stays an alert and still blocks End turn) and opens the comparison, and closing the comparison
  restores the card. A locked bubble's tooltip
  and accessible name give the reason.
- **During a multi-season command**, area bubbles and the abode bubble are inert: hovering works, clicks open nothing,
  and Stop stays in Z5. Mid-journey, area bubbles are measured from the next place on the route.
- **Keyboard, gamepad and screen reader.** Tab and Enter on the map follow the map focus rules (Places panel: The map in
  the focus order). On the gamepad, the map cursor snaps to bubbles as well as places, and A acts like a click. Each
  bubble has an accessible name ("Market at Lạc Hà Thành, 1 season away"), including the lock reason when locked. The
  Places panel lists the same actions in each row, as the text equivalent.
- **Colour is never the only cue:** each kind has its own icon shape, and the count is a number.
- **Dependency:** the game code must say what can be done at a place (market, sect, open quests, known people present,
  explore sites), from what the player knows.

### The turn

Added 2026-11-22 after the full design review (blockers 1 and 3); revised after re-reviews 2 and 3 (user decisions
Q2–Q4).

**End turn input**
- **One End turn gate.** The End turn button's press and the `end_turn` action both go through one gate that owns the
  input mode, the cooldown and every inhibitor below, so a click, Enter and the action always behave the same.
- **Enter ends the turn when focus is on End turn, on nothing (a read-only label counts as nothing), or on the map
  with no place or bubble focused.** On a focused place, Enter opens that place's panel; on a focused bubble, Enter acts
  like a click. On any other focused control (a row, a
  list, a slider, a dropdown, a button, a text field), that control uses Enter. Key repeat is ignored: one press ends
  at most one turn. Enter (or a click) on a blocked End turn opens the blocker.
- **The gate refuses End turn** while any of these holds: a full screen is open; a fight or tribulation runs; the game
  menu is open; a Z7 window is open (the season summary included: user decision 2026-11-22, so Enter closes the
  summary and Enter again ends the turn); a season is resolving; the post-turn sequence (the banner, the summary and
  any queued Z7 windows) has not finished; `end_turn_cooldown` (0.5 s) has not passed since the last inhibitor
  cleared; a multi-season command runs; a blocking event waits; "Check focus" is pending; the preview is still
  computing (user decision 2026-11-22: the press is refused with "Checking focus…", never queued).
- The **End turn input** setting (Tuning Knobs):
  - *single press* (keyboard and mouse default);
  - *press, then confirm* (user decision 2026-11-22; the gamepad default): the first press turns the button into
    **"Confirm end turn"**; a second press ends the turn. It is cancelled by Esc, by a click on any other control, by
    any window key, or by focus leaving End turn. No timeout, so it is not a timed input;
  - *hold* (gamepad only, optional): hold Start for `end_turn_hold` (0.6 s by default, a player setting from 0.3 to
    1.5 s) while a ring fills (a static fill with reduced motion on); releasing early, losing focus or a card opening
    cancels it.
- **While a season resolves**, focus stays where it was and controls stay focusable but do nothing; input that arrives
  meanwhile is discarded when the season returns, **except Stop, which is latched** (see Multi-season commands). When
  the season summary opens it takes focus. After it closes, focus goes to the next queued Z7 window; the control that
  had focus before End turn gets it back only when the queue is empty.
- **While a blocking event waits**, free actions that change the character are locked (HUD Philosophy rule 2).
- The season's random stream is part of the save, so reloading and making the same choices gives the same season
  (a dependency on the session code).

**Default focus** (user decisions 2026-11-21 and 2026-11-22: carry over, break on a risk change)
- Each new season starts on last season's focus, and on Cultivate in the first season and after a multi-season
  command, so a routine season is two key presses: Enter closes the summary, Enter again ends the turn (three with "press,
  then confirm").
- If last season's focus can't be done again (the journey ended, no recipe can be brewed, the mission is over), the
  focus falls back to Cultivate and the selector names the old focus and the reason; Cultivate's baseline is set as
  below.
- **Risk band.** The game code gives each focus a risk band: *none*, *low*, *medium*, *high* or *can kill*, from its
  danger, encounter chance and fight odds (the worst of the three decides), with the thresholds in data. "Can kill"
  means a possible outcome of the focus is death with at least a data-set minimum chance.
- **Baseline.** Each (focus, params) pair has a baseline, saved with the game. It is set only by a player act:
  choosing the focus, confirming it in the comparison, or **ending a season on it, which sets it to that season's band**
  (user decision 2026-11-22, so a band that falls and rises again asks again). There are two stated exceptions: the
  fallback to Cultivate sets Cultivate's baseline to its current band, and a pair with no baseline takes its band when
  it is first set. Succession clears every baseline and the once-per-bottleneck and lifespan flags. A confirm accepts
  risk only up to the band confirmed. **The risk band and every stop read only what the player knows**, as the preview
  does.
- The selector **stops and asks** when:
  - at a season's start, or when End turn is pressed (free actions may have changed the fight odds, or a timed free
    action shortened the season), the focus's band is higher than its baseline;
  - the player has just reached the bottleneck (asked once per bottleneck);
  - the lifespan warning has just started (asked once).
  The once-per-bottleneck and lifespan flags are saved with the game.
- While stopped, End turn reads **"Check focus: <reason>"**. A click opens the focus comparison with the reason
  highlighted; confirming there sets the new baseline and does not end the turn (End turn is pressed as usual). Picking
  a focus from the gamepad radial or any list opens the same comparison; nothing sets a focus around it.
- **Reminders.** End turn's pip shows idle reminders (unspent Đạo Đồ points, a matured herb). A reminder whose cost
  grows when ignored (a quest deadline at risk, a matured herb still unharvested) becomes a "Check focus" stop after
  `reminder_escalate_seasons` (2) seasons ignored, so a one-key routine cannot run past it.

**Focus preview** (element 29): every focus the player can take, side by side, each with:
- expected gain as a range; for Explore, Travel and Mission, the **possible outcomes** instead;
- seasons it takes;
- lifespan used, in years;
- **the share of the season left** when free actions took time this season (a lesson 0.25, a spar 0.1): the expected
  gain and distance are scaled by it (changed 2026-11-22, `design/ux/person.md` and the dialogue GDD rule 4). A Travel
  focus covers that share of a season's distance and is never refused for it: a 1-season trip with 75 % left arrives a
  season later, and "seasons it takes" and "lifespan used" count the extra season;
- the risk band, with its danger, encounter chance and fight odds; "can kill" when it can;
- the bottleneck state after it;
- cost in linh thạch and fuel.

**What the UI needs from the game code** (a dependency on the session code, not designed here): `chosen_focus`,
`can_do(focus, params)` (ok, or the reason), `preview(focus, params)`, `end_turn()`, `blocker()` (none, event,
check focus, or pending while the preview computes), and a stop reason (blocking event, fight, breakthrough,
bottleneck, lifespan warning, death, health below half, player stop, done). `params` names the destination (Travel),
the recipe (Brew) or the mission.
- **Deterministic.** `preview` never draws from the game's random streams. Its trial fights use their own generator
  seeded from the game seed, the season, the focus, its params and a hash of the known inputs the preview reads (the
  player's sheet, the route, the opponent values the player knows, and the share of the season left after timed free
  actions), so the same known state always gives the same
  preview, and equipping then unequipping an item gives the preview back unchanged. Its seeds never collide with the
  rating fights' seeds (`power-rankings.md` rule 13). The state revision number is only the cache key.
- **Only what the player knows.** The preview reads only what the player knows: an opponent's strength as the player
  sees it (the shown power number or an estimate), places through map knowledge (`MapKnowledge.knows_place`), and no
  hidden tile or secret. It must be identical with and without a hidden secret on the route.
- **Cost.** It may cost a trial fight or two (about 13 ms each), so it is computed at the season's start and when the
  comparison opens, cached until the state revision changes, and shows "…" while it computes; End turn is refused, not
  queued, and reads "Checking focus…" until it is ready (The turn: the gate).

**Death in the turn flow**
- A death during a season: the season summary shows it, then the succession full screen opens
  (codex-karmic-carryover.md).
- A death in a fight or from an event card: that result screen shows it, then succession.
- A multi-season command stops on death.

**Multi-season commands** (closed-door cultivation, long journeys)
- **The confirm dialog shows** the seasons, the lifespan spent and the age at the end (or "your lifespan ends in year
  N" when it would run out), the expected gain, the worst risk band along the way (for a journey, the worst band on
  any leg of the route), and what stops it.
- **It stops only for what needs an answer** (user decision 2026-11-22), checked at each season boundary: a blocking
  event, a fight, a breakthrough, reaching the bottleneck, the lifespan warning, death, or health below half (strictly
  below 50 %). Events that need no answer go into the seclusion digest. After a stop, "Continue" resumes the run. After a
  stop for health below half, that stop does not fire again until health is back at 50 % or more. Every other stop (a
  blocking event, a fight, a breakthrough, reaching the bottleneck, the lifespan warning, death) always stops the
  run.
- **Stop** (the button, Esc, or B on the gamepad) is **latched**: it is never discarded, not even while a season
  resolves or during the cooldown, and it takes effect at the next season boundary; seasons can't be split. Stop is
  the focused control in Z5 while a run is active.
- **Progress shows season by season**, and the map updates each season. This needs the session to step one season at
  a time (today `closed_door` loops inside itself): a dependency on the session code.

---

## HUD States by Gameplay Context

Approved by the user 2026-11-21. The four review contexts map to this game as: exploring = the map, dialogue = talking
to someone, cutscene = an event card, paused = the game menu (the game is turn-based, so nothing runs in any state
until End turn).

| State | Trigger | What changes |
|---|---|---|
| **Map (default, "exploring")** | Normal play | Every Must Show element; contextual ones as their conditions hold |
| **Panel open** | A window button, a portrait, a name or a place | Z6 slides in over the left third. The map stays live: hover and right-click still work, and End turn still works |
| **Talking to someone ("dialogue")** | Open a person card, or right-click → a verb | It's a panel, so the Panel open rules apply; the reply appears in the card |
| **Event card ("cutscene")** | An event fires at End turn or on an action | Z7 card in the centre; the map behind it dims by about 30 %; End turn is blocked and names the event; the card can be minimised to its alert |
| **Season resolving** | End turn pressed | Focus stays; controls stay focusable but do nothing for the moment it takes (input arriving meanwhile is discarded, except a latched Stop); the season and year readout changes, bars fill, and the season summary opens in Z7. If resolving takes longer than `resolve_notice_delay` (0.3 s), "The world turns…" shows in Z5 |
| **Multi-season command** | Closed door, or a long journey | Z5 shows the progress and Stop; the map updates each season; it stops by itself on the stops listed in The turn, and opens the seclusion digest at the end (or succession, on death) |
| **Full screen** | Đạo Đồ, abode, brewing, formation editor, succession | The map and Z2–Z7 are hidden; Z1 stays, plus a back button (none on succession); End turn is unavailable until the player returns to the map; an event opens as an overlay on the full screen |
| **Tooltip locked** | A lock (timer, middle click, click, or Q) | The chain stays open until Esc, a click outside, its source disappearing, a season change or a window opening over it; a lock mark shows |
| **Check focus** | The focus's band rose, the bottleneck was reached, the lifespan warning started, or a reminder escalated | End turn reads "Check focus: <reason>" and opens the focus comparison |
| **Confirm armed** | First press with "press, then confirm" | End turn reads "Confirm end turn" until a second press or a cancel |
| **Hold in progress** | Start held with "hold" | A ring fills on End turn over `end_turn_hold`; release, focus loss or a card cancels it |
| **Blocking event waits** | An event needing an answer | End turn names it; character-changing free actions show a lock mark (HUD Philosophy rule 2) |
| **Combat** | A fight or tribulation | Everything is hidden, the top bar too (Layout Zones exception); the fight spec's header and controls take over |
| **Game menu ("paused")** | ≡ or Esc | A modal menu over a dimmed screen: save, load, settings, wiki, quit; it shows the world seed so it can be shared (world-generation.md) |
| **Low lifespan** | `lifespan_warn_share` (10 %) or less left | The lifespan box turns amber with an hourglass mark, and an alert appears once |
| **Nothing to show** | No alerts, no pins | The alert row is empty with no placeholder; the outliner shows "Pin people, places or quests here" |
| **No data on the map** | A map mode or route with nothing known | Prices mode: markets never visited are hatched "not seen"; route preview to an unreachable place: "No route" and the reason (for example, needs flight); known-people mode with no one known here: "You know no one here yet." |

---

## Information Hierarchy

Approved by the user 2026-11-21. The order in which elements drop when space runs short (Visual Budget).

| Tier | Elements | What carries it when hidden |
|---|---|---|
| **MUST KEEP** | End turn and focus; the cultivation box (realm, stage, level, progress); the lifespan box; season and year; the linh thạch box; the player's bubble and place name (elements 30 and 17); blocking alerts | — (never hidden on the map) |
| **SHOULD KEEP** | Window buttons; portrait; wiki and menu; map mode buttons; non-blocking alerts; the rating, renown and sect contribution boxes (their change shrinks to a mark in the compact layout) | Keyboard shortcuts open every window; map modes fold into one dropdown |
| **CAN HIDE** | Outliner (collapses); health and linh lực bars; band icons; route preview; clue area | The window buttons and the boxes' tooltips; band states also raise an alert |
| **ALWAYS HIDE** | Information Architecture, Group 7 | Nothing (debug only) |

---

## Visual Budget

Approved by the user 2026-11-21; every number is a tuning knob. **Screen share is the budget.** The 34 live elements in HUD
Element Specifications (35 numbers; element 9 is merged into 8), with their sub-indicators (the autosave indicator, "The world turns…", lock marks, the hold
ring, tooltip title strips), are the complete list for the map screen; adding one is a change to this spec, not a
build decision.

- **The bare map** (no panel open): the HUD chrome (Z1–Z5) covers at most `chrome_share_max` **15 %** of the screen,
  measured as the union of the zone rectangles; in the compact layout the target is `chrome_share_max_compact`
  **20 %**.
- **A panel open**: at most `panel_share_max` **45 %** (`panel_share_max_compact` **50 %** in the compact layout),
  measured as the combined area the HUD covers (overlaps counted once, not a sum of zone sizes). Z7 is not counted:
  it is a temporary overlay, at most `centre_width_max` **40 %** of the screen width, its height capped as in Layout
  Zones.
- **Alerts**: at most `alerts_shown_max` **8** icons at once, and never more than fit in the alert row's space (Z1:
  the row ends where the right-anchored resource boxes begin, so it never overlaps them); blocking alerts come first and are never hidden: those that do not fit fold into their own "+N !" icon, drawn with the blocking frame and always shown, whose tooltip lists them; the non-blocking rest fold into "+N".
- **Drop order** when the layout area (in layout pixels, Platform Adaptation: Scaling rule) is smaller than
  `compact_below` (1600×900):
  1. Collapse the outliner.
  2. Fold the map modes into one dropdown.
  3. Show window buttons as icons only, without labels.
  4. Resource boxes narrow to `resource_box_width_compact` and show their change as the ▲ / ▼ mark only (the number moves into the tooltip), and the alert row shows at most `alerts_shown_max_compact` (4) alert icons (the fold icons do not count toward either cap), folding as in Alerts above ("+N !" for blocking overflow, "+N" for the rest).
  5. Below `boxes_icon_below` (1,360 layout px wide) the rating and renown boxes show their icon and change mark only, the
     number in the tooltip and the accessible name (they are SHOULD KEEP; the MUST KEEP boxes never shrink further).

  Fit at 1280×720 (layout px), with step 5: boxes 3 × 112 + 252 + 2 × 48 = 684, gaps 6 × 8 = 48, season about 130 (the Vietnamese "Xuân, năm 3"), wiki and menu 72, four alerts and both fold icons ("+N !", "+N") about 212, separators 48: about 1,194 of the 1,248 (the first build at 1280×720 fits, 2026-11-23) between the margins (about 120 px spare for longer strings). An AC measures it in both languages.

  MUST KEEP elements never drop. At 1280×720 the 10 window buttons fit in Z2 once the outliner collapses; the first
  build screenshot confirms it.

---

## Feedback & Notification Systems

Approved by the user 2026-11-21.

| Type | Trigger | Where | Lasts | Max at once | Queue behaviour |
|---|---|---|---|---|---|
| **Alert icon** | A standing condition (Information Architecture, Group 4) | Z1 alert row | Until resolved, or snoozed until next season | `alerts_shown_max` (8; 4 compact) and what fits, then "+N !" for blocking overflow and "+N" for the rest | Blocking alerts first, then newest |
| **Toast** | The result of a free action ("Bought 3 herbs", "Planted Huyết Linh Thảo") | Bottom centre, above Z4 | `toast_seconds` (3 s) | 3 stacked, newest on top | A 4th pushes out the oldest |
| **Refusal** | A click that can't be done ("Not enough linh thạch (need 120)") | Next to the control clicked | `refusal_seconds` (2 s), or until the mouse leaves; reappears on hovering or focusing the control again, and on Q; it is also the control's accessible description | 1 | Never queued; replaces the last |
| **Season summary** | End turn | Z7 centre | Until closed | 1 | Opens **first**; the season's events follow it. It also lists the season's toasts under "This season" |
| **Seclusion digest** | A multi-season command ends | Z7 | Until closed | 1 | Replaces that run's summaries |
| **Event card** | An event fires | Z7 | Until answered (can be minimised) | 1 shown | FIFO, shown "1 of N"; each blocks End turn |
| **Breakthrough banner** | A stage or realm breakthrough | Centre, over the map | `banner_seconds` (2.5 s), or until a click or Esc skips it | 1 | Shown before the summary, and listed in it; the summary waits for it |
| **Unread news badge** | News lines from a season | The news button (Z2) | Until the news log is opened | — | Counts up |
| **Save failed** | A save that could not be written | Z7 | Until closed | 1 | Never auto-dismissed; an autosave indicator shows in Z1 while saving |

**Order after End turn:** breakthrough banner, then the season summary, then event cards one by one, so the player
sees what happened before being asked to choose. **The summary opens in the frame after the banner ends**, or in the
frame after the season finishes resolving when there is no banner. One Z7 window shows at a time; the rest wait in
this order. If the player died, succession follows the summary (The turn). **Alert order** is written here once:
blocking alerts first, then the newest. Blocking alerts cannot be snoozed.

**During other states:**
- In a fight or tribulation, everything waits and shows afterwards in the order above. Refusals are the exception, as
  they belong to the fight screen.
- On a full screen (abode, brewing), toasts and refusals still show; an event triggered there opens as a modal overlay
  on the full screen, with the Z7 rules.
- The game menu holds everything until it closes.

---

## Platform Adaptation

Approved by the user 2026-11-21. PC (Steam / Epic); keyboard and mouse first; gamepad partial.

- **Screen sizes:** 1920×1080 is the base. 16:10 and 21:9 widen the map, and the zones stay anchored to their edges.
  The minimum is 1280×720, which uses the compact drop order (Visual Budget).
- **Scaling rule** (added 2026-11-22, full design review blocker 2): **a smaller window gives less room, never smaller
  text.**
  - UI size = the UI scale setting × an automatic factor. **The automatic factor is max(1, min(window width ÷ 1920,
    window height ÷ 1080))**, so it never shrinks the UI and a tall or narrow window does not inflate it: at 1280×720
    text stays at its floor and the compact layout takes over; at 2560×1440 everything is 1.33× larger; at
    3840×2160, 2×.
  - **The layout area never drops below 1280×720.** The layout area is the window size ÷ (UI scale × automatic
    factor), so the UI scale's maximum is **floor(100 × min(window width ÷ 1280, window height ÷ 720) ÷ automatic
    factor) %**, never below the 75 % minimum: 150 % at 1920×1080, 2560×1440, 3840×2160, 1920×1200 and 2560×1080;
    100 % at 1280×720 and at 1280×1600; 106 % at 1366×768. **The setting's range is 75–150 %** (user decision
    2026-11-22), default 100 %; the slider shows the cap for the window ("max 106 % at this window size"). The
    effective scale is recomputed on every resize as min(the saved setting, the cap); the saved setting is kept. The 150 % ceiling is a Known Intentional Limitation in
    `design/accessibility-requirements.md`.
  - **The window cannot be made smaller than 1280×720.**
  - **The text floors** (16 px; 14 px for tooltip detail; `design/accessibility-requirements.md`) hold at UI scale
    100 % and above. Below 100 %, the player has chosen smaller text.
  - `compact_below` is measured in layout pixels, not screen pixels, so a high UI scale on a large monitor also gets
    the compact layout. The compact layout applies when the layout area is narrower **or** shorter than it.
  - `edge_margin` is in layout pixels.
  - Which Godot window-scaling setting gives this behaviour is NOT SOURCEABLE from `docs/engine-reference/godot/`; the
    greybox build verifies it on screen.
- **Every binding below is a default and can be rebound** (keys, mouse buttons and gamepad buttons; `design/accessibility-requirements.md` Motor Accessibility). A rebind that clashes with another shows a warning.
- **Keyboard:**
  - Every window has a key: C character, I inventory, R relationships, S sect, J journal, K rankings, N news,
    P places, D Đạo Đồ, A abode, F1 wiki; Q opens the focused element's tooltip (Tooltips); + and − zoom the map.
  - Enter ends the turn from End turn, from nothing, or from the map with no place focused (The turn: End turn
    input).
  - **Esc first acts on the window that holds focus** (user decision 2026-11-22): a modal (rebind capture, the keep /
    discard / cancel prompt, settings, the game menu) cancels or closes; a tooltip opened with Q closes; a focused
    panel closes; a focused Z7 window does its step below (5 or 6). Only when focus is on the map, on Z1–Z5 or on
    nothing does Esc follow the ranked list. Closing a panel therefore never minimises a card or stops a run. Gamepad B
    follows the same rules.
  - **The ranked list: Esc does exactly one thing per press, the first that applies, and the press is consumed:**
    1. skip the breakthrough banner;
    2. cancel an armed "Confirm end turn";
    3. close the top tooltip;
    4. Stop, while a multi-season command runs;
    5. close a non-blocking Z7 window (the summary; a quest offer closes as "not now" and stays on the board);
    6. minimise a blocking event card (it is never dismissed; minimised, it is an alert and Esc leaves it alone);
    7. close the panel, or leave the full screen for the map (succession has no map, so this step is skipped there);
    8. open the game menu (Esc again closes it).

    In a fight or tribulation, Esc opens settings only (the fight spec allows no exit mid-fight).
  - V (or Shift+F10) on a focused person opens their verbs; the person card also has a Verbs button.
  - Delete on a focused alert snoozes it until next season.
  - **Single-letter hotkeys are off whenever a text control is the focus owner** (Godot cannot detect an IME
    composing, so the rule keys on the focused control): every letter types, Q and V included (they are letters in
    Vietnamese, as in "quên" and "về"), and + and − type too, so typing in the Places search opens no window. F2 and
    Shift+F10 still work there.
    A setting turns single-letter window hotkeys off entirely; **Q and V stay on** (they act only on the focused
    element) and have non-letter keys too (F2 for a tooltip, Shift+F10 for verbs), so the setting never removes a
    function.
  - Keys are bound by physical position, so AZERTY and Dvorak keyboards get the same layout.
  - With a blocking event card open, window keys still open their panels (look, don't change); focus moves into the
    panel and returns to the card when the panel closes.
  - Alt+←/→ and mouse buttons 4/5 step back and forward through the window history.
  - M cycles the map modes (Shift+M backwards).
  - Tab and Shift+Tab move keyboard focus within a zone; F6 and Shift+F6 jump between zones in the focus order
    (Accessibility).
- **Mouse:** hover for tooltips; middle-click (or a click) locks a tooltip; right-click a person for verbs or an alert
  to snooze it; the wheel zooms.
- **Gamepad (partial):** follows CK3's console approach, without a virtual mouse.
  - Shoulder buttons cycle the window buttons.
  - A radial menu holds the map modes, the season focus list and the window buttons; it toggles on a press (not a
    hold) and has a plain list form.
  - One button switches focus between the map and the open panel.
  - The map cursor snaps to places and to map bubbles; A on a bubble acts like a click.
  - Y opens the focused thing's tooltip, locked, with focus in it; A on a highlighted word opens its nested tooltip
    (Tooltips).
  - End turn on Start defaults to "press, then confirm"; "hold" is an optional setting (The turn). B means Stop while
    a multi-season command runs.
  - **The game menu is on Select/View**, because Start is held for End turn. X on a focused alert snoozes it.
  - **X on a focused person opens their verbs** (their window scrolled to the verb list; the twin of V and
    right-click; added 2026-11-22, `design/ux/person.md`). On a dead person, who has no verbs, it opens their window
    at the death banner; on a person's name inside a tooltip it opens their verbs too (A there still opens the nested
    tooltip).
  - "Partial" means every map-screen action is reachable. Dense full screens such as Đạo Đồ may stay mouse-first **on
    the gamepad only**: the keyboard reaches everything everywhere (`design/accessibility-requirements.md`).

---

## Accessibility

Approved by the user 2026-11-21. **Tier: Standard**, plus reduced motion and menu and panel screen-reader support, committed 2026-11-22 in `design/accessibility-requirements.md`; that document wins where the two differ.

- **Focus order:** Z5 (End turn) → Z3 → Z1 alerts → Z1 resource boxes → Z2 buttons → Z4 → the map → the open panel → a non-blocking Z7
  window. F6 jumps between these zones;
  Tab moves within one. Every interactive element can be reached with the keyboard, including tooltips (Q) and the
  map (the Places panel). **Opening a panel moves focus to its first control**; Back and Forward keep focus in the
  panel; closing it returns focus to the control that opened it. **When a Z7 window opens, focus moves into it**; a
  blocking event card keeps focus (and F6) inside it until it is answered or minimised, while F6 leaves a non-blocking
  window. Closing a Z7 window returns focus to the control that had it before (End turn, if that control is gone).
- **Non-text contrast:** icons, bars, and the focus ring at least 3:1 against what is behind them. The focus ring
  shows after keyboard or gamepad focus, including after a mouse click moved focus.
- **Hit targets:** every click target is at least 24×24 screen pixels at the 75 % minimum UI scale (32 layout pixels).
- **Text:** a contrast ratio of at least 4.5:1. The smallest text is 16 px at 1080p and 100 % scale, and 14 px for
  secondary lines inside tooltips and Breakdowns (`design/accessibility-requirements.md`, 2026-11-22); both grow with UI
  scale. Vietnamese diacritics must be legible at the smallest size.
- **Never colour alone:** each alert has its own glyph shape, and blocking alerts also have a distinct frame and sort
  first; the amber lifespan box also shows an hourglass mark and its accessible name adds "little lifespan left" (announced once when it starts); each box's change is a ▲ / ▼ mark with a sign; the cultivation box reads "Cultivation: Trúc Cơ 3, 62 percent, up 4 percent a season here"; band icons carry their band number; health and linh lực bars
  carry their own icons; sect territory has a border pattern and the sect's name; price changes show arrows and
  numbers; map modes have a legend with patterns, not only hues. With reduced motion on, the linh thạch loss flash is
  replaced by a "−12" change shown beside the number, and the boxes' number ticks, the cultivation fill and the sect
  box's fade happen at once.
- **Compact labels:** when the compact layout drops the window buttons' labels, each label stays in the button's
  tooltip and accessible name.
- **Reduced motion:** a setting turns off slides, glows, cross-fades, the filling bars (cultivation and multi-season
  progress and the End turn hold ring), the bubble slide and the area bubbles' fade-in, the toast fade, the tooltip appearance fade and the breakthrough banner's fade (the banner still shows
  for `banner_seconds`); the End turn glow becomes a static highlight; changes become instant. One central motion helper owns every UI animation, so the setting reaches them all.
  Flashes and glows are limited to one per element per second.
- **Tooltips:** settings for the hover delay (0–2 s), the lock mode (any of timer, middle-click and click) and the
  close grace (0.3–2 s). "Click to lock" helps players who can't hold the mouse still, and a locked tooltip never
  closes on a timer.
- **Localisation:** every player-facing string goes through translation keys (Vietnamese and English); layouts leave
  room for text 30 % longer than the English. **Numbers follow the language** (user decision 2026-11-22,
  `design/ux/person.md`): one locale-aware formatter everywhere, so the Vietnamese UI shows 1.240 and 1,5 and the
  English UI 1,240 and 1.5.
- **Screen readers:** Godot 4.5+ Control nodes work with AccessKit (`docs/engine-reference/godot/modules/ui.md`). Every
  icon button gets an accessible name, and alerts and toasts are announced.

---

## Tuning Knobs

Approved by the user 2026-11-21.

**Player settings**

| Setting | Range | Default |
|---|---|---|
| UI scale | 75–150 %, capped per window (Scaling rule) | 100 % |
| Tooltip delay (`tooltip_delay`) | 0–2 s | 0.3 s |
| Tooltip lock | any of: timer, middle-click, click | all three |
| Tooltip lock delay (`tooltip_lock_delay`) | 0.5–3 s | 1 s |
| Tooltip close grace (`tooltip_close_grace`) | 0.3–2 s | 0.3 s |
| Reduced motion | on / off | off |
| Toast duration (`toast_seconds`) | 2–6 s | 3 s |
| Outliner | shown / collapsed | shown |
| Borders (element 13) | on / off, one setting for all saves | on |
| Alerts by kind | on / off per kind (blocking alerts can't be turned off) | all on |
| Colourblind mode | off / red-green | off |
| Brightness (map and art) | slider | default |
| End turn input | single press / press, then confirm (any input); hold (gamepad only) | single press (keyboard and mouse); press, then confirm (gamepad) |
| End turn hold (`end_turn_hold`) | 0.3–1.5 s | 0.6 s |
| Single-letter window hotkeys | on / off (Q and V always stay on) | on |
| Key bindings | every default binding rebindable | as in Platform Adaptation |

**Designer knobs** (a data file such as `assets/data/ui_hud.json`; not yet created)

| Knob | Default | Used in |
|---|---|---|
| `lifespan_warn_share` | 0.10 | Element 10; Low lifespan state |
| `resource_box_width` | 144 px (the cultivation box × `cultivation_box_factor`, 2.25) | Resource box (elements 2, 8, 10, 33–35) |
| `resource_box_width_compact` | 112 px (the cultivation box × 2.25) | Resource box, compact layout |
| `top_bar_height` | 48 px | Z1 (one row; measured on the first build, 2026-11-23) |
| `boxes_icon_below` | 1360 px (layout width) | Visual Budget drop order step 5 |
| `resource_box_icon_width` | 48 px | Visual Budget drop order step 5 (icon-only boxes) |
| `alerts_shown_max_compact` | 4 | Visual Budget drop order (compact layout) |
| `chrome_share_max` | 0.15 | Visual Budget |
| `chrome_share_max_compact` | 0.20 | Visual Budget (compact layout) |
| `panel_share_max` | 0.45 | Visual Budget |
| `panel_share_max_compact` | 0.50 | Visual Budget (compact layout) |
| `centre_width_max` | 0.40 | Visual Budget |
| `alerts_shown_max` | 8 | Visual Budget; Feedback |
| `compact_below` | 1600×900 | Visual Budget drop order |
| `resolve_notice_delay` | 0.3 s | Season resolving state |
| `banner_seconds` | 2.5 s | Feedback (breakthrough banner) |
| `edge_margin` | 16 px | Layout Zones (safe zone) |
| `end_turn_cooldown` | 0.5 s | The turn (End turn input) |
| `tooltip_depth_max` | 5 | Tooltips |
| `history_max` | 20 | Layout Zones (Z6 window history) |
| `bubble_trip_seasons` | 1 | Map bubbles (how far area bubbles reach) |
| `bubbles_max` | 12 | Map bubbles (area bubbles on screen at once) |
| `motion_fast` | 0.15 s | Panel slide, fades |
| `motion_slow` | 0.5 s | Cultivation box progress fill |
| `refusal_seconds` | 2 s | Feedback (refusal) |
| `reminder_escalate_seasons` | 2 | The turn (reminders) |

---

## Acceptance Criteria

Rewritten 2026-11-22 after the full design review (items 7 and 8). Each criterion carries its evidence: `[GdUnit]` an
automated test, `[Screenshot]` a retained screenshot in `production/qa/evidence/`, `[Manual]` a played check written
up beside the screenshots. Timings are counted in simulated frames at a fixed 1/60 s step (9 frames = 0.15 s, 18 =
0.3 s, 30 = 0.5 s, 36 = 0.6 s, 120 = 2 s, 150 = 2.5 s, 180 = 3 s), with ±1 frame except where a criterion names an
exact boundary; "appears" means `visible` becomes true. Rows marked `[GdUnit]` drive input through simulated events and an injected clock.

**Layout and scaling**
- [ ] `[Screenshot]` At 1920×1080 on the bare map, all 13 Must Show elements are visible (elements 2, 3, 4, 5, 7, 8,
      10, 14, 15, 17, 30, 33, 34).
- [ ] `[GdUnit]` Each resource box keeps its rectangle when its number changes from 1 to 1,000,000 (the neighbours do
      not move, and 1,000,000 shows as "1.0M" inside the box with the full number in its tooltip); the sect
      contribution box appears on joining a sect and disappears on leaving, and no other box moves either time; adding
      or removing alerts moves no box.
- [ ] `[GdUnit]` After End turn each box's change equals the value right after the resolution minus the value right
      before End turn, and a purchase during the season changes the number but not the change; a five-season
      closed door shows the whole command's change; after loading a save or a succession no change shows until the next
      End turn.
- [ ] `[GdUnit]` The Borders toggle is on in a new game, draws region borders in every map mode, is saved as a
      setting, is reachable with Tab in Z4 and stays a button when the map modes fold into a dropdown.
- [ ] `[GdUnit]` On a full screen, Enter or a click on a box opens no window; Q opens its tooltip.
- [ ] `[GdUnit]` At 1280×720, in English and in Vietnamese, the measured widths of the Z1 children (alerts with 4 icons
      and "+N", the boxes, season, wiki and menu, gaps) sum to at most the bar's width; below `boxes_icon_below` the
      rating and renown boxes show icon and mark only.
- [ ] `[GdUnit]` The lifespan box turns amber with an hourglass mark at `lifespan_warn_share` and its accessible name adds
      "little lifespan left", announced once; a provisional rating shows "~1,512" and reads "Rating about 1,512,
      provisional"; renown shows "—" and reads "Renown: not tracked yet"; below `boxes_icon_below` the rating and
      renown boxes hide their number and keep it in the accessible name; the "+N !" and "+N" icons are reached with Tab
      in Z1 and Q opens their list.
- [ ] `[GdUnit]` A box shows 99,999 as "99,999", 100,000 as "100k", 999,999 as "999k" and 1,000,000 as "1.0M"; in Vietnamese 1,250,000 shows as "1,2M" and
      1,240 as "1.240" (numbers follow the language).
- [ ] `[GdUnit]` A box's change shows ▲ with a + sign for a gain, ▼ with a − sign for a loss and no mark for no change;
      the lifespan box shows no change mark for a season that only passed, and ▲ for a breakthrough's gain.
- [ ] `[GdUnit]` The cultivation box's rate equals the rate-per-season Breakdown's total at the current place, and it
      changes after a move to a place of different density or match.
- [ ] `[GdUnit]` Enter (or a click) on each box opens its window (inventory, character sheet, rankings, sect), and Q
      opens its tooltip; its accessible name reads resource, number and change.
- [ ] `[Screenshot]` At 1280×720 (compact) and 1920×1080, Z1 holds the alerts, all six boxes, season, wiki and menu
      with no overlap or clipping, the compact boxes showing the change mark only.
- [ ] `[GdUnit]` At 1920×1080 on the bare map, the union of the Z1–Z5 rectangles covers at most `chrome_share_max`
      (15 %) of the viewport.
- [ ] `[GdUnit]` At 1280×720 and at 2560×1080 (21:9), every HUD control's rectangle lies inside the layout area
      inset by `edge_margin` (16 layout pixels), and the compact drop order applies at 1280×720.
- [ ] `[GdUnit]` The compact layout applies at a layout area of 1599×900 and 1600×899, and not at 1600×900.
- [ ] `[GdUnit]` In a 1280×720 window at 100 % UI scale, the effective font size of HUD and panel text is at least
      16 screen pixels (tooltip detail 14).
- [ ] `[GdUnit]` The UI scale cap (rounded down) is 150 % at 1920×1080, 2560×1440, 3840×2160, 1920×1200 and
      2560×1080; 100 % at 1280×720 and 1280×1600; 106 % at 1366×768; at each cap the layout area is at least
      1280×720.
- [ ] `[GdUnit]` Resizing from 2560×1440 at a 150 % setting to 1366×768 gives an effective 106 % and keeps the saved
      150 %.
- [ ] `[Screenshot]` At 2560×1440 and 100 % UI scale, every element is 1.33× (±0.01) its 1080p size and the layout is
      intact.
- [ ] `[GdUnit]` The slider cannot go past the window's cap and shows the cap with its reason.
- [ ] `[GdUnit]` The window's minimum size is 1280×720.
- [ ] `[GdUnit]` In the compact layout at 1280×720, the union of the Z1–Z5 rectangles covers at most
      `chrome_share_max_compact` (20 %).
- [ ] `[GdUnit]` With a panel open, the union of the HUD rectangles covers at most `panel_share_max` (45 %); Z6 does
      not intersect Z3; Z7 does not intersect Z1, Z2, Z3, Z4, Z5 or Z6. At 1280×720 the compact budget
      `panel_share_max_compact` (50 %) holds.
- [ ] `[GdUnit]` Z7 is never wider than `centre_width_max` (40 %) of the viewport.
- [ ] `[GdUnit]` The `tallest_event_card` fixture (the longest Vietnamese event text with 4 options) scrolls inside the
      Z7 height cap, with its options pinned, at 1280×720, 1920×1080 and 2560×1080.
- [ ] `[GdUnit]` With the `tallest_event_card` fixture open, Z7 does not intersect Z3, Z4 or Z5 at those sizes.

**The turn**
- [ ] `[GdUnit]` With an event pending, End turn reads "Event waiting: <title>", a click opens the card, and Enter
      does not end the turn.
- [ ] `[GdUnit]` With another button, a Places row, a list, a slider or a text field focused, Enter is used there and
      does not end the turn. With a place focused on the map, Enter opens its panel; with a bubble focused, Enter acts
      like a click on it. With nothing, a read-only label, the map with no place or bubble focused, or End turn focused,
      a held Enter ends exactly one turn.
- [ ] `[GdUnit]` A click on End turn, Enter and the `end_turn` action give the same result in every input mode, and
      each is refused while any gate inhibitor holds (full screen, fight, game menu, Z7 window including the summary,
      resolving, post-turn sequence, cooldown, multi-season command, blocking event, Check focus, preview computing).
- [ ] `[GdUnit]` An End turn within `end_turn_cooldown` (30 frames) after the last inhibitor cleared is refused; one
      at 30 frames is accepted.
- [ ] `[GdUnit]` While the banner of the previous turn shows, End turn is refused.
- [ ] `[GdUnit]` With the summary open, Enter closes it and does not end the turn; a second Enter ends the turn.
- [ ] `[GdUnit]` "Press, then confirm": the first press shows "Confirm end turn"; a second press ends the turn; Esc, a
      click on another control, a window key or focus leaving End turn cancels it; after 10 minutes of simulated time
      it is still armed.
- [ ] `[GdUnit]` Gamepad hold: holding Start for `end_turn_hold` (36 frames) ends the turn and fills the ring;
      releasing at 35 frames ends no turn; a card opening mid-hold cancels it.
- [ ] `[GdUnit]` Input that arrives while a season resolves is discarded, except Stop. When the summary opens it has
      focus; with two queued events, closing the summary moves focus to "1 of 2", and only after the last queued
      window closes does focus return to the control focused before End turn.
- [ ] `[GdUnit]` While a blocking event waits (and while its card is minimised), equipping, using a pill, spending Đạo
      Đồ points, changing technique slots, the formation editor, trading, verbs that change a person, planting,
      harvesting, a free brew and abode changes are refused with a reason and a lock mark; opening windows, the wiki
      and the focus selector still works; once the event is answered, all of them work again.
- [ ] `[GdUnit]` After a brewing season, the next season starts on Brew; if no recipe can be brewed, it starts on
      Cultivate and the selector says so.
- [ ] `[GdUnit]` When the carried-over focus's risk band rises above its baseline, End turn reads "Check focus:
      <reason>"; confirming in the comparison sets the new baseline, does not end the turn, and the next season does not
      ask again unless the band rises further. The baseline survives a save and reload.
- [ ] `[GdUnit]` Ending a season on a focus sets its baseline to that season's band: a band that falls from high to low
      and rises to medium asks again.
- [ ] `[GdUnit]` After the fallback to Cultivate, Cultivate's baseline is its current band; succession clears every
      baseline and the bottleneck and lifespan flags.
- [ ] `[GdUnit]` A free action that raises the focus's fight odds into a higher band makes End turn read "Check
      focus" when pressed.
- [ ] `[GdUnit]` Reaching the bottleneck asks once; the following seasons at the same bottleneck do not ask, also
      after a save and reload.
- [ ] `[GdUnit]` A reminder ignored for `reminder_escalate_seasons` (2) seasons becomes a "Check focus" stop.
- [ ] `[GdUnit]` `preview(focus, params)` returns the same values when called twice on the same state, and the
      session's random streams are unchanged after it.
- [ ] `[GdUnit]` Equipping and then unequipping an item gives the same preview as before.
- [ ] `[GdUnit]` The preview is identical with and without a hidden secret on the route, and never names a place
      the player does not know.
- [ ] `[GdUnit]` While the preview computes, End turn reads "Checking focus…" and is refused; when the preview is
      ready, no turn has ended.
- [ ] `[GdUnit]` An End turn with a breakthrough and 2 events shows the banner, then the season summary, then
      "1 of 2", then "2 of 2".
- [ ] `[GdUnit]` A death during a season shows the summary, then opens succession.
- [ ] `[GdUnit]` Stop (the button, Esc or B) during a multi-season command, pressed even while a season resolves,
      takes effect at the next season boundary, and the digest opens.
- [ ] `[GdUnit]` A multi-season command stops on each of: a blocking event, a fight, a breakthrough, reaching the
      bottleneck, the lifespan warning, death, health below 50 % (and not at exactly 50 %); an event that needs no
      answer goes into the digest and does not stop it. After "Continue" from a health stop, health below half does
      not stop it again until health has been back at 50 % or more; a later blocking event still stops it.
- [ ] `[GdUnit]` With a breakthrough, the summary opens in the frame after the banner ends (150 frames, or at once if
      the banner is skipped); without one, in the frame after the season finishes resolving (the tick's and the
      rating fights' own time belong to `living-world-tick.md` and `power-rankings.md`).
- [ ] `[GdUnit]` Rebinding End turn to a key already used by another action shows a conflict warning, and the new
      binding is loaded after a restart.
- [ ] `[Manual]` With the gamepad, End turn on Start needs a press then a confirm by default; with "hold" set, a held
      Start; the game menu opens on Select/View.
- [ ] `[GdUnit]` Reloading a save and making the same choices gives the same season.

**Windows, Esc and focus**
- [ ] `[GdUnit]` Esc acts on the focused window first, then the ranked list (Platform Adaptation), one step per press,
      each press consumed. Reachable cases:
      - a pointer-locked tooltip over an open summary (focus in the summary): the first Esc closes the summary, and the
        tooltip closes with it, because its chain closes when its source disappears or a window opens over it;
      - a tooltip opened with Q from a panel control: Esc closes the tooltip and focus returns to the control; Esc
        again closes the panel;
      - an armed "Confirm end turn" with a pointer-locked tooltip open: the first Esc cancels the confirm, the second
        closes the tooltip;
      - a banner with a tooltip open: the first Esc skips the banner;
      - a blocking card with a panel opened over it (focus in the panel): Esc closes the panel and focus returns to the
        card; Esc again minimises the card and the event stays pending;
      - the game menu over a panel: Esc closes the menu;
      - a closed-door run with a panel focused: Esc closes the panel and the run goes on; Esc again stops it;
      - on succession: Esc opens the game menu.
- [ ] `[GdUnit]` Opening a panel with its key moves focus to the panel's first control; closing it returns focus to
      the opener.
- [ ] `[GdUnit]` With a blocking event card open, F6 keeps focus inside the card.
- [ ] `[GdUnit]` Back and forward step through the window history; opening a new window after going back drops the
      forward entries; the history keeps the last `history_max` (20) windows.
- [ ] `[GdUnit]` Opening a Z7 window moves focus into it; closing the last queued Z7 window returns focus to the
      control that had it.
- [ ] `[GdUnit]` A panel starts opening in the frame after its click and finishes in `motion_fast` (0.15 s, 9
      frames); with reduced motion on, it is fully open in the frame after the click.
- [ ] `[GdUnit]` On a full screen (Đạo Đồ, abode, brewing, formation editor, succession) End turn is refused.
- [ ] `[Screenshot]` On a full screen the top bar shows; in a fight or tribulation it is hidden; succession has no back
      button.
- [ ] `[GdUnit]` An event that fires on a full screen opens as an overlay on it, and the full screen keeps its state.
- [ ] `[GdUnit]` Leaving a full screen with uncommitted edits asks keep, discard or cancel.
- [ ] `[Screenshot]` The game menu shows the world seed.

**Notifications**
- [ ] `[GdUnit]` With 10 non-blocking alerts, 8 show plus "+2"; in the compact layout 4 show plus "+6"; with 6 blocking
      and 4 other alerts at 1280×720, the row shows the blocking alerts that fit, a "+N !" icon for the rest of them and
      a "+N" for the others, and its rectangle never intersects the resource boxes.
- [ ] `[GdUnit]` A snoozed alert whose condition still holds comes back at the next season.
- [ ] `[GdUnit]` A 4th toast pushes out the oldest; at most 3 show.
- [ ] `[GdUnit]` A refused click shows the refusal beside the control; hovering or focusing the control again, or Q,
      shows it again; it is the control's accessible description.
- [ ] `[GdUnit]` A blocking alert cannot be snoozed.

**Changes after approval, 2026-11-22 (person window)**
- [ ] `[GdUnit]` The focus comparison shows the share-of-season-left line only after a timed free action this season,
      and the expected gain and distance scale by it; a 1-season Travel with 75 % left is not refused, previews arriving
      a season later, and its lifespan used counts the extra season.
- [ ] `[GdUnit]` The same known state gives the same preview seed; the same state with a different share of the season
      left gives a different seed. A timed free action that pushes a focus's band above its baseline makes the selector
      stop and ask.
- [ ] `[GdUnit]` One number formatter: the Vietnamese UI shows 1.240 and 1,5, the English UI 1,240 and 1.5, checked on
      the Places panel, a HUD readout and a tooltip Breakdown.
- [ ] `[GdUnit]` On a gamepad, X on a focused person opens their window scrolled to the verbs; on a dead person it
      opens at the banner; on a person's name inside a tooltip it opens their verbs while A opens the nested tooltip; X on
      a focused alert still snoozes it.

**Tooltips**
- [ ] `[GdUnit]` A tooltip never appears before `tooltip_delay` (18 frames), and appears within 2 frames after it.
- [ ] `[GdUnit]` Moving the pointer from a source into its unlocked tooltip within `tooltip_close_grace` keeps it
      open; staying off it longer closes it; hovering a highlighted word there opens a second tooltip; a middle click
      locks it.
- [ ] `[GdUnit]` A locked tooltip stays open with the pointer away for 10 minutes of simulated time; it closes on
      Esc, a click outside (which does not reach the control underneath), its source being freed, a season change or
      a window opening over it.
- [ ] `[GdUnit]` Clicking a window button with a tooltip open activates the button and does not lock the tooltip.
- [ ] `[GdUnit]` A 6th level of nesting opens the wiki page instead (`tooltip_depth_max` 5).
- [ ] `[GdUnit]` With the keyboard only: Q (or F2) opens the focused element's tooltip, locked, with focus in it; Tab
      selects a highlighted word and wraps; Enter opens its tooltip; Esc closes the levels one at a time from the top
      and returns focus to the source.
- [ ] `[GdUnit]` With single-letter window hotkeys off, Q and V still work, and F2 and Shift+F10 do the same.
- [ ] `[GdUnit]` Changing the tooltip delay, lock mode and close grace in settings changes the behaviour at once.

**Keyboard, screen reader and accessibility**
- [ ] `[Manual]` With the keyboard only, the player travels to a known place through the Places panel (P, select a
      row, Travel here, confirm in the focus comparison, End turn).
- [ ] `[GdUnit]` A place the player does not know (`knows_place` false) never appears in the Places panel.
- [ ] `[GdUnit]` Each Places row shows kind, seasons, danger, qi match, holder, known people, market and sect marks,
      price age, the clue flag and its bubble actions; the current place's row offers its free actions as buttons.
- [ ] `[GdUnit]` With a text control as the focus owner, every letter key, Q, V, + and − included, types and opens
      no window; F2 and Shift+F10 still work.
- [ ] `[Manual]` Typing Vietnamese with real Telex (Windows keyboard), Unikey and EVKey into the Places search opens
      no window.
- [ ] `[GdUnit]` With the map focused, the arrow keys pan it and keep the focused place in view.
- [ ] `[GdUnit]` F6 visits Z5, Z3, Z1 (alerts, then the resource boxes), Z2, Z4, the map, the open panel and a non-blocking Z7 window in that order, and
      Tab reaches every control inside each.
- [ ] `[Manual]` With NVDA running, every map-screen button is announced with its name and role, and an opened
      tooltip's text, a selected Places row, a new alert and a toast are announced.
- [ ] `[GdUnit]` Text in Z1–Z7 has an effective font size of at least 16 screen pixels (tooltip detail lines 14) at
      1920×1080 and 100 % UI scale.
- [ ] `[Screenshot]` A contrast checker on the screenshot gives at least 4.5:1 for text on its plate and 3:1 for icons,
      bars and the focus ring, in Z1–Z7.
- [ ] `[GdUnit]` With reduced motion on, no UI tween is running after any state change, and each element shows its
      final value in the same frame (the alert slide-in, the linh thạch tick and flash, the badge pop, the
      breakthrough glow and banner fade, the cultivation box fill, the multi-season progress fill, the hold ring, the
      health and linh lực fades, the band icon fade, the toast fade, the tooltip fade, the map mode cross-fade, the End
      turn glow, the bubble slide and the area bubbles' fade-in, the route draw, the panel slide, the centre window fade).
- [ ] `[Screenshot]` With the red-green colourblind mode on, a Coblis simulation of the map modes and the alert row
      still shows every backup listed in the accessibility doc's colour audit.

**Map bubbles**
- [ ] `[GdUnit]` At continent zoom only the player's bubble and the abode bubble show; at region zoom area bubbles show
      at the current place and at known places within `bubble_trip_seasons` (1 season), and at no place farther.
- [ ] `[GdUnit]` With the `crowded_region` fixture (20 qualifying bubbles at region zoom, 1280×720), at most
      `bubbles_max` (12) show after merging, nearest by route seasons with ties by place id; the current place's
      bubbles are always among them; two at one place that would overlap merge into one with a count.
- [ ] `[GdUnit]` At the current place, clicking a market bubble opens the trade window; clicking an explore bubble opens
      the focus comparison with Explore preselected; the focus is set only on confirm, and no turn ends.
- [ ] `[GdUnit]` Clicking a bubble at another place opens the focus comparison with Travel to <place> preselected, its
      label naming what is there; the focus is set only on confirm, and no turn ends.
- [ ] `[GdUnit]` A people bubble with one person opens their person card; with several, the relationships list
      filtered to that place.
- [ ] `[GdUnit]` A place the player does not know, and a person they do not know, never gets a bubble.
- [ ] `[GdUnit]` A remote **quest** bubble's count reads the player's last-seen data and shows its age; changing the
      world's true state at that place without the player seeing it does not change the bubble. A **people** bubble's
      count equals the number of known living people actually at that place now, and shows no age (2026-11-22).
- [ ] `[GdUnit]` A known person travelling between places counts at the place they left, and their bubble's tooltip
      names them "travelling to <place>"; a pinned person who dies stays in the outliner as "died" until unpinned.
- [ ] `[GdUnit]` An outliner pin shows the person's current place; it changes when they move, with no visit by the
      player.
- [ ] `[GdUnit]` While a blocking event waits, a market bubble shows the lock mark and opens the trade window with its
      buy and sell controls locked; an explore bubble minimises the event card and opens the comparison, and closing the
      comparison restores the card; the locked bubble's accessible name
      gives the reason.
- [ ] `[GdUnit]` With the map focused, Tab visits places nearest first and each place's bubbles after it; Enter on a
      focused bubble acts like a click and does not end the turn.
- [ ] `[GdUnit]` Without a home, there is no abode bubble; with one, it shows at continent and region zoom.
- [ ] `[GdUnit]` During a multi-season command, clicking an area bubble or the abode bubble opens nothing.
- [ ] `[GdUnit]` A bubble under Z1–Z5 or the open Z6 panel is not drawn and does not take a click; every bubble's click
      target is at least 24×24 screen pixels at 75 % UI scale.
- [ ] `[GdUnit]` With reduced motion on, the bubble slide and the area bubbles' fade-in do not animate.
- [ ] `[Manual]` On the gamepad, the map cursor snaps to bubbles and A acts like a click.
- [ ] `[GdUnit]` Clicking the player's bubble opens the character sheet; clicking the abode bubble opens the abode screen.
- [ ] `[Screenshot]` Region zoom with area bubbles, at 1280×720 and 1920×1080.

**HUD states**
- [ ] `[Screenshot]` One windowed screenshot per row of HUD States by Gameplay Context (17 rows), named
      `production/qa/evidence/hud/<state>-<width>x<height>.png`, each showing what its row says.

---

## Open Questions

- **Resource box data (2026-11-23):** `GameQuery.resources` gives the rate here, the power number and contribution (ADR-0006); the season changes come from the HUD's End-turn baseline (Resource box). **Renown** has no sources or season rule in `character-stats.md` yet (the GDD session's), so its box shows "—" until it does. The icons for the six boxes are new art (art bible 7.13).

- Player journey map not yet created. Author it from the template at `.claude/docs/templates/player-journey.md` to
  establish player context for this screen.
- Art bible §1–4 (identity, mood, shape, colour) are empty; this spec defines zones and behaviour, not the look.
- `sects.md` and `npc-traits.md` have no UI Requirements section; the user confirmed both need screens (a sect screen;
  an NPC screen showing traits). `npc-traits-catalogue.md` content goes to the in-game wiki.
- **There is no Time & Turn GDD** (systems index #4 is Implemented with no document). The turn split belongs to the
  session code and `living-world-tick.md`. **The session code** must split choosing the focus from ending the turn (today each timed action
  passes the season itself, `game_session.gd` `_pass_season`). The free-or-focus list in HUD Philosophy rule 1 is
  provisional and needs an exact list in Time & Turn (for example: is a short hop to a neighbouring place free?).
  Capability #10's second brew becomes a free extra brew.
- **Dismissing an alert:** resolved 2026-11-22: dismissing snoozes an alert until next season while its condition
  still holds.
- **Map modes and the outliner:** the final list of map modes; whether the outliner has a pin limit.
- **Gamepad per full screen:** how much gamepad support each full screen gets is decided in that screen's spec.
- **The look** (palette, frames, fonts) waits on the mood board and the art bible.
- **AccessKit and rich text:** can AccessKit read nested tooltips built from `RichTextLabel` meta links? NOT
  SOURCEABLE from `docs/engine-reference/godot/`; the focusable word buttons and "Open in wiki" (Tooltips) are the
  fallback. Check in the greybox.
- **Carried into the build stories** (user decision 2026-11-22: settled while building, not by more spec rounds; from
  the full re-review):
  - acceptance criteria for the remaining untested rules (tooltip placement and strips at 150 %, hold and cooldown
    feedback, every default-focus trigger, the preview fields, the multi-season dialog contents);
  - screen-reader live-region tiers (assertive for refusals, blocking alerts, "Check focus" and death; polite for
    toasts; none for value ticks), coalescing after End turn, and a status-readout hotkey;
  - the full screenshot list per screen touched (Places panel, event card, summary, confirm dialog, save failed, alert
    row with "+N", toasts and refusals, a 3-level tooltip, the compact layout), taken windowed per
    `.claude/docs/run-and-observe.md`;
  - reminders against autopilot play (urgent versus idle reminders on the End turn pip);
  - an interim table of free versus focus actions, with the rule that free actions never advance the clock or use
    lifespan;
  - history entries store a window kind and subject id (a dead or forgotten subject shows a note instead); outliner
    pins at succession and for dead or finished subjects;
  - the `_pass_season` news overwrite (`out.news` is replaced after the abode and works lines are added), a code bug
    for `production/todo.md`;
  - from re-review 4 (deferred by the reviewer): the "can kill" measure (per season or per run); a clearing rule for
    reminder stops and their counter during multi-season commands; re-checking the band each season of a run; the
    lock list as an allow-list (dropping, selling, learning manuals, quests, costed verbs); saving during a blocking
    event; "Travel here" opening the comparison; element 29's form at 40 % width (scrolling, pinned header, screen
    reader and gamepad forms); tooltip lock details (chain granularity, a click on a locked chain's source, middle
    click versus middle-drag pan, a first click swallowed by a locked tooltip); the preview compute model (snapshot,
    worker or sliced; cancelling a stale run); panel-opener focus after mouse opens (restore focus only after a
    keyboard or gamepad open); announcements for discarded input, the latched Stop, the cooldown refusal, "…" and the
    armed state; lock marks for screen readers; camera pan and zoom under reduced motion; Z7 scroll keys; hit-target
    checks for inline link buttons; more colour-only cues (the lit mode button, greyed foci, the clue area, the End turn
    glow); rebind capture rules; toast and banner timing against WCAG 2.2.1; the F6 ring on full screens; screen-reader
    criteria for the event card, summary, confirm dialog and comparison; one injected clock for timed criteria;
    integer or epsilon scale maths tested as a pure function (with an off-grid case such as 2000×1125); restating the
    focus ring after a mouse click as a goal to verify (4.6 dual focus); `is_echo()` for key repeat; a 1366×768 laptop
    and the 1280×720 window; splitting bundled criteria; criteria for `refusal_seconds`, `toast_seconds`,
    `resolve_notice_delay`, `lifespan_warn_share`, death in a fight or event, blocked-label precedence and preview
    cache invalidation; risk-band thresholds in the knobs table; the preview using actual stats versus the
    one-season-late power number.
- **Build notes from the engine review** (godot-specialist, re-review 3; NOT SOURCEABLE from
  `docs/engine-reference/godot/`, so each is checked in the greybox, not decided here):
  - scaling: drive the root window's content scale factor from code on each resize, with the `canvas_items` stretch
    mode, fractional scaling and a 1280×720 minimum size. Corrected 2026-11-22 after the greybox measurement (user
    approved): the content scale size is set to the window's own size on each resize, not left unset, because unset
    makes Godot stretch from the project's default 1152×648 (`production/qa/evidence/hud-greybox/README.md`);
  - tooltip bodies as a flowing container of labels and flat underlined link buttons (a `RichTextLabel` cannot hold
    focusable controls); sources leave Godot's own `tooltip_text` empty; the pointer grace uses rectangle tests;
  - one Esc router node that marks the input handled; `focus_next` / `focus_previous` on zone-edge controls for F6;
  - re-check Enter and focus after clicks given the 4.6+ dual-focus changes, and the focus-ring theme;
  - time the gamepad hold with `Time.get_ticks_msec()`; key repeat is handled by the gate's cooldown and busy flag;
  - if the season resolves on the main thread, show "The world turns…" first and wait two frames before resolving;
  - the gamepad menu on `JOY_BUTTON_BACK`; check Steam Input's remaps and 4.7's mouse and keyboard device IDs.
- **Fonts:** a font that covers Vietnamese diacritics at 14–16 px is still to choose (art bible typography); Godot 4.7
  changed the dynamic-font hinting default, so small-text sharpness must be re-checked on the first build
  (godot-specialist).
- **Dependencies on other work** (named here, owned elsewhere; full design review item 14):
  - what can be done at a place, from what the player knows (Map bubbles);
  - a shared Breakdown format that every tooltip and panel reads;
  - an alerts model: who raises and clears each alert, and the snooze state saved with the game;
  - outliner pins saved with the game; an NPC whose current place is not in the data shows "unknown";
  - the season running off the main thread or one step at a time, so "The world turns…" and multi-season progress
    can draw (today the tick is synchronous); the one-season-late rating rule (`power-rankings.md` rule 13,
    2026-11-22) removes the largest wait;
  - the custom tooltip layer, the scaling approach and the motion helper (each likely an ADR).
- **Pattern library gap:** this spec invents 7 interaction patterns: the nested lockable tooltip, the alert row, the
  panel with back and forward history, the toast, the refusal note, the End turn blocker and the season focus selector.
  There is no `design/ux/interaction-patterns.md` yet; add them with `/ux-design patterns` once a few more screens
  exist.
- **Screens outside the HUD:** the new-game, origin list, build progress and save list screens (world-generation.md,
  codex-karmic-carryover.md) need their own specs.

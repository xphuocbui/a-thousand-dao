# UX Spec: Person Window

> **Status**: In Review (all sections written 2026-11-22; run `/ux-review person`)
> **Author**: user + ux-designer
> **Last Updated**: 2026-11-22
> **Journey Phase(s)**: Unknown (no `design/player-journey.md`)
> **Platform Target**: PC (Windows); keyboard and mouse primary, gamepad Partial (`.claude/docs/technical-preferences.md`; `design/ux/hud.md` Platform Adaptation)
> **Template**: UX Spec
> **Scope** (user, 2026-11-22): the one-person window only. The known list, the trade view and the relationships page
> (`design/ux/relationships-page.md`) get their own specs and are only linked from here.

---

## Purpose & Player Need

**The player arrives at this window wanting to** know who this person is, what they think of the player, and what the
player can do with them, and then to act without being surprised by the answer.

It serves four needs:

1. **Recognition.** Who is this: name, realm, sect and rank, and their attitude to the player as a word and a colour
   (`design/gdd/npc-interaction-dialogue.md`, Visual/Audio: the person card).
2. **Understanding.** Who they are as a cultivator, which is the window's most important information (user,
   2026-11-22): **realm and stage, power rating, linh căn (elements and purities), stats, công pháp (main method and
   arts), sect and rank**; then their character: **traits** and the ties that matter (master, đạo lữ, blood feud).
   **The player always sees all of it** (user decision 2026-11-22): nothing is hidden, nothing is unlocked and nothing
   has to be learned before it shows. People read as individuals whose traits drive what they do, not as stat blocks.
3. **Action with no surprise refusals.** Every verb shows "will accept" or "won't accept" before it is chosen, with the
   reasons, so the player works toward a yes (dialogue GDD, Game Feel: no surprise refusals; talk is free, deeds cost
   time).
4. **Memory.** What has passed between them: favours owed, loans, inherited feuds, so a lender who comes asking or a
   spared rival who greets the player differently is explained by something on screen.

**Without it:** the world is a list of names, refusals feel arbitrary, and the traits catalogue (37 personality traits,
14 callings, 10 fate traits, 16 gained traits) has no face to show it. This is the screen where the cast becomes
people, and the only place the social, favour, conflict and bond verbs are used.

---

## Player Context on Arrival

**When the player first meets this window:** a few seasons into a life, when they first stand at a place with someone
they haven't spoken to (the people bubble, or a name in a news line or window). It is then one of the most-visited
windows in the game, the one players return to whenever a name matters.

**What they were just doing:** one of four things, each carrying a different question:
- on the map at a place with a people bubble (*who is here?*);
- reading a name in a summary, news line or tooltip (*who is that?*);
- in another window such as a sect roster, a quest giver or a market seller (*tell me more about this one*);
- coming from the outliner, where they pinned the person (*where are they now and what do they want?*).

**What they arrive with:** the full sheet from the first glance, whoever the person is. The question is "how do I
compare with this person, and what will they accept?"

**Emotional state to assume:** curious and unhurried. The game is turn-based, talk is free and nothing runs while the
window is open. But it must also serve a wary player about to ask a costly favour of a rival or answer a lender, so it
shows risk (won't accept, debts, feuds) as clearly as warmth.

**Voluntary or sent:** always voluntary; nothing opens this window by itself. During a blocking event it opens
**look-only** (the HUD's look-don't-change rule, `design/ux/hud.md`): everything readable, verbs that change anything
locked with the reason shown.

**Journey phase:** unknown (no `design/player-journey.md`); noted in Open Questions.

---

## Navigation Position

This window lives at: **Map screen → Z6 panel area → Person window.** It is a *panel*, not a full screen: it slides
over the left third of the map, the map stays live (hover and right-click work, End turn still works), and only one
panel is open at a time (`design/ux/hud.md`, Layout Zones: Z6; HUD States: Panel open).

It is **context-dependent, not top-level**: there is no window button or key for "the person window", because it always
belongs to one chosen person. The player reaches it from many places (Entry & Exit Points) and it joins the **window
history** (the last `history_max` = 20 windows, with back and forward arrows, like a browser). Opening a name inside it
replaces it, so following a chain of people (master → rival → sect elder) is a trail the player can walk back along.

**A person who is gone:** a dead person shows a banner ("died in 1198, Winter") and the sheet as at death; only
someone with no record at all shows a one-line note. Either way the history entry stays valid (hud.md, Layout Zones:
window history; States & Variants below).

---

## Entry & Exit Points

| Entry source | Trigger | Player carries this context |
|---|---|---|
| People bubble with one person | Click, or Enter on the focused bubble | Which person; the place they're at |
| People bubble with several | Opens the relationships list filtered to that place (hud.md, Map bubbles); picking a row opens this window | The place filter; the person picked |
| A highlighted name anywhere (summary, news line, tooltip, another window, a sect roster, a quest giver) | Click, or Enter or Q on the focused word | The person's id; the window they came from (for the history and focus return) |
| Outliner pin | Click, or Enter | The pinned person; where they are now |
| Right-click a person (map or any window) | Right-click, V or Shift+F10 on a focused person, or X on a gamepad (user decision 2026-11-22) | The person, and a request to show their verbs (see Open Questions: verbs on the card or in a menu) |
| History | Alt+←/→, mouse buttons 4/5, the panel's arrows | Returns to the person as it was, refreshed to the current state |
| Returning from a fight or an event | Closing the fight screen or the summary | The person; the result as a reply line |

| Exit destination | Trigger | Notes |
|---|---|---|
| Map (panel closes) | Esc, the close button, or the same window button again | Esc follows the HUD's focused-window-first rule; focus returns to the opener |
| Another person's window | A name inside this window | Replaces the panel; this person stays in the history |
| Another panel (character, place, sect …) | Its window button, key or a link | Replaces the panel; history entry kept |
| Back / forward | The arrows, Alt+←/→, mouse 4/5 | Steps through the history |
| The fight screen | Spar or Provoke | One-way until the fight ends, then back here with the result |
| Across End turn | End turn | The window stays open; the season summary opens in the centre and the panel refreshes when it closes |

**No irreversible exits:** leaving never loses anything. Gifts, loans and other costly verbs are irreversible, so they
confirm *before* they run, not on exit.

---

## Layout Specification

### ASCII Wireframe

The panel at 1280 × 720, two views of the same window. Names and numbers are sample values; the build uses Vietnamese
diacritics and the HUD's link styles (underlined names, bold numbers).

**View 1: scrolled to the top**

```
+----------------------------------------------------+
| Person                              [<]  [>]  [x]  |  P1 frame
+----------------------------------------------------+
| +--------+  Lam Thanh  F                          |
| |        |  Truc Co so ky - Thanh Van Tong, noi mon|  P2 header
| |  64x64 |  Power 4,210?  Attitude: friendly +34^ |  (sticky)
| +--------+                                         |
+----------------------------------------------------+
| MADE OF                                            |
|  Linh can    Moc 72 [#####-]   Thuy 40 [##----]    |
|  Cultivation Lv 6 [####--] 62%     age 47 / 220    |
|  Health 1,840   Linh luc 2,310   Than thuc 410     |
|  Vitality 1.2   Can cot 58                         |
|  Cong phap   Main:  Xuan Quy Quyet (L3, Moc)       |
|              Arts:  Thanh Dang Thuat - Hoi Xuan    |
|              Second: none                          |  P3 body
| CHARACTER AND TIES                                 |  (scrolls)
|  Traits   Patient    calm under pressure   (vs Rash)|
|           Herbalist  better brews                  |
|  Ties     master: Du Lao  - bond                   |
|           feud: Hac Sa (blood) - toward them       |
|  Favours  none owed                                |
+----------------------------------------------------+
| Reply: "She thanks you quietly."   Attitude +3     |  P4 reply strip
+----------------------------------------------------+
| [Verbs]      [Pin]      [Relations]                |  P5 action bar
+----------------------------------------------------+
```

**View 2: scrolled to the verbs** (an event is waiting, so the verbs are look-only)

```
| VERBS                  look-only: an event waits    |
|  Social                                             |
|   Greet                 v will accept      free     |
|   Ask for news          v will accept      free     |
|   Give a gift           v will accept      costs stones |
|  Favours                                            |
|   Ask for teaching      v will accept      0.25 season |
|   Ask for help          x won't accept     score -12: |
|                         attitude -8, realm gap -4   |
|   Trade                 opens the trade view        |
|  Conflict                                           |
|   Spar                  v will accept      0.1 season  |
|   Provoke               a real fight, death possible |
|  Bonds                                              |
|   Swear brotherhood     greyed: needs a close bond  |
|                                                     |
+----------------------------------------------------+
| [Verbs]      [Pin]      [Relations]                 |
```

Notes: will / won't is a **word plus a mark (v / x), never colour alone**, with the reason on the same row (no surprise
refusals); **look-only** locks every verb while an event waits, with the reason in the section heading; the reply strip
appears only after a verb and stays pinned wherever the body is scrolled.

### Layout Zones

One scrolling column (arrangement A, chosen by the user 2026-11-22) in the HUD's Z6 panel. The sizes assume the
minimum layout area, 1280 × 720, where the panel is about 420 × 540 px; the HUD's UI-scale cap keeps that true at
any UI scale (`design/ux/hud.md`, Platform Adaptation: Scaling rule).

| Zone | Where | Size at minimum | Holds |
|---|---|---|---|
| **P1 Frame** | Top of the panel (HUD element 20) | 32 px | "Person", back and forward arrows, close |
| **P2 Header** (sticky) | Under the frame; never scrolls | about 112 px | Identity: who and how strong (hierarchy item 1) |
| **P3 Body** (scrolls) | Middle | about 350 px (about 280 with a reply showing) | The sections in hierarchy order: Made of, Character and ties, Verbs, More |
| **P4 Reply strip** | Pinned just above the action bar; appears only after a verb | up to 72 px | The reply to the last verb, with its effect lines; dismissible |
| **P5 Action bar** (pinned) | Bottom of the panel | 44 px | Verbs (jump), Pin, Relations |

The body is short at the minimum size: a screenful is about 12 lines and the whole sheet about 4 screens. So section
headings are **jump targets** (Tab on a heading, the triggers LT / RT on a gamepad), the Verbs button jumps straight to the verb
list, and the header and action bar never scroll away.

**Verbs live on the card:** the verb list is a body section; the pinned Verbs button, right-click on a person, and V or
Shift+F10 open the window scrolled to it. (This settles the HUD spec's "right-click opens verbs *and* the card has a
Verbs button".)

### Component Inventory

| Zone | Component | Type | Shows | Interactive |
|---|---|---|---|---|
| P1 | Back / forward / close | Buttons (HUD element 20) | Window history | Yes |
| P2 | Portrait | Image 64×64 | Authored for the fixed cast; others composed from archetype, realm and sect colours | No |
| P2 | Name line | Text | Vietnamese name, English where useful, gender mark | Link style: person (bold, relation colour) |
| P2 | Standing line | Text | Realm and stage, then sect and rank | Realm and sect are links to their entries |
| P2 | Power rating | Number + tooltip | The power number, `?` while provisional | Tooltip with the Breakdown |
| P2 | Attitude | Word + colour + number + icon | "friendly +34" (bands: hostile, cold, neutral, warm, friendly, close) | Tooltip with the reasons |
| P3 Made of | Linh căn | Chips with purity | Each owned element and its purity, variant tags | Tooltip per element |
| P3 Made of | Cultivation | Progress bar + text | Level, progress to the next, age / lifespan | Tooltip |
| P3 Made of | Stats | Label / number rows | Health, linh lực, thần thức, vitality, căn cốt | Each has a Breakdown tooltip |
| P3 Made of | Công pháp | Rows | Main method, auxiliary arts, second technique, with layers and element tags | Each opens its entry |
| P3 Character | Traits | Grouped rows | Personality, calling, fate, gained; each with a one-line effect and the opposed trait | Each opens the catalogue entry |
| P3 Character | Ties | Rows with glyphs | The player's ties to them first, then up to 3 other notable ties, each with its glyph, the **kind named in Vietnamese and English**, and its band | The partner's name opens their window |
| P3 Character | Favours and feuds | Block | Owed favours with state, loans, inherited feuds with cause | Tooltips |
| P3 Verbs | Verb groups | Four lists | Social, favour, conflict, bond; each verb with will / won't accept, cost and time, and the missing requirement when greyed | Yes: select to use; Q for the score breakdown |
| P3 More | Where, family, talents, gear, origin, history | Rows | Location now and last seen, home, master and parent, thiên phú, equipped gear and wards, background, their last few events | Names and places are links |
| P4 | Reply strip | Text | The line, then effect lines | Dismiss |
| P5 | Verbs / Pin / Relations | Buttons | Jump to verbs; pin to the outliner; the relationships page filtered to this person | Yes |

**Patterns:** there is no pattern library yet (`design/ux/interaction-patterns.md`), so these are new and flagged for
it: the sticky header with pinned action bar and section jumps, the will / won't badge (a word plus an icon, never
colour alone), the reply strip, and the link styles from the HUD spec (Tooltips: Link styles).

### Information Hierarchy

Everything is shown (user decision 2026-11-22); the ranking only sets what the eye meets first and what sits lower.

1. **Who they are and how strong** (first glance, sticky header): name, realm and stage, power rating, sect and rank,
   attitude (word and colour).
2. **What they are made of:** linh căn, stats, công pháp: the information the user named most important.
3. **What they are like and what binds us:** traits, ties, favours and debts.
4. **What I can do:** the verbs, always one step away (the pinned Verbs button), each with its will / won't accept
   answer and why.
5. **Everything else, lower down:** where they are, home, age, thiên phú, equipped gear, background, recent history.

---

## States & Variants

| State / Variant | Trigger | What changes |
|---|---|---|
| **Default** | A living person the player has met, at the player's place | Full sheet; every verb live with will / won't accept and the reason |
| **Not met** | A person the player has never spoken to (a name in a news line) | Full sheet. Attitude reads "not met"; verbs are greyed with "you haven't met: greet them first", and Greet is the only live verb if they are here (it is the meeting, dialogue GDD rule 2) |
| **Elsewhere** | The person is not at the player's place (dialogue GDD rule 1) | Full sheet. Every verb greyed with "not here: *place*, 1.4 seasons away"; the action bar gains **Travel there**, which opens the focus comparison with Travel preselected, like a bubble |
| **Verb requirement fails** | A verb's requirements (realm, sect, attitude band, flags, items, the person's traits) are not met | The verb is **not shown** (dialogue GDD rule 5), except **bond** verbs, which show greyed with the missing requirement so the player learns the path. A verb opposing the player's own traits is never hidden or greyed: its cost is shown (rule 7) |
| **Won't accept** | The acceptance score is below 0 | The verb stays, marked "x won't accept" with the score's parts in words (dialogue GDD rule 6); the player changes the answer by changing the state, never by asking again |
| **Verb on cooldown** | The verb's own cooldown, or the person's interaction limit reached (`interactions_per_person_per_season`, 2) | That verb alone is greyed with its reason in words; the others are unaffected |
| **Look-only** | A blocking event is waiting | Everything readable; every verb that changes something shows a lock mark and "locked while an event waits (look only)" (hud.md: look-don't-change) |
| **Season resolving** | A session job is running | The panel is inert and dimmed, nothing is re-read, and it shows the last data; it refreshes when the summary closes (ADR-0006: nothing is read while a job runs) |
| **Provisional rating** | The power number is still an estimate | Power shows `?`; the tooltip says it is an estimate and a better number comes with their next rating |
| **Dead person** | The person has died | A banner line leads the body ("died in 1198, Winter: *cause*"); the sheet stays readable **as at death**, from a snapshot frozen when they died (gear, stats, công pháp, ties), so it is unchanged after their items pass on; verbs and Pin are absent; the history entry stays valid |
| **Beast** | A name that belongs to a creature | The sheet without Sect, Ties and Verbs (a beast only growls) |
| **The player's own name** | Any link to the player | Redirects to the character sheet (C): no verbs on yourself |
| **Empty sub-sections** | No ties, no favours, no công pháp slot filled | The row stays with "none" ("none owed", "no ties"); sections never disappear silently, so the layout is the same for everyone |
| **Missing record** | A history entry or an old save points at a person who no longer exists | A one-line note "no record of this person" with the back arrow working; never an error |
| **Loading** | None | Data is local and read in one frame, so there is no loading state |
| **Compact layout** | The window is below the HUD's compact size (1600 × 900) | Same panel and content; the portrait shrinks to 48 px and spacing tightens |
| **Gamepad** | Controller input | A focus ring through the rows (the D-pad moves it, and the body scrolls to follow); the triggers LT / RT jump between section headings; A uses a verb; Y opens the focused row's tooltip; B closes (B means Stop while a multi-season command runs, per the HUD) |
| **Reduced motion** | The setting is on | The panel appears without sliding and jumps without animated scrolling |

---

## Interaction Map

Mapping interactions for **keyboard and mouse (primary) and gamepad (Partial: every map-screen action is
reachable)** (`design/ux/hud.md`, Platform Adaptation). The shoulder buttons belong to the HUD (they cycle the window
buttons), so this window uses the triggers LT / RT for section jumps and the frame's arrows for history.
**Opening the panel moves focus to its first control**, as the HUD says (Accessibility); closing it returns focus to
the control that opened it. Window keys follow the HUD: **V** or Shift+F10 opens a person's verbs, Q or F2 a tooltip, Esc follows the
HUD's focused-window-first rule.

**Panel controls and information**

| Component | Mouse | Keyboard | Gamepad | Feedback | Outcome |
|---|---|---|---|---|---|
| Back / forward | Click the arrows, or mouse buttons 4 / 5 | Alt+← / Alt+→ | D-pad to the frame's arrows, then A | Pressed state | Steps through the window history; the person is refreshed to the current state |
| Close | Click ×, or the window's own button again | Esc | B | The panel slides out (none under reduced motion) | Closes; focus returns to the opener |
| Name, realm, sect, power, attitude, linh căn, stats, công pháp, traits, ties (anything with a tooltip) | Hover for the tooltip; middle-click or click to lock | Q or F2 on the focused row | Y | Underlined text; the tooltip layer (ADR-0005) | Tooltip with the Breakdown and nested words |
| Realm, sect, trait, công pháp name (a link) | Click | Enter | A | Pressed state | Opens its entry: the sect's window, or the wiki page. *Dependency: sect window and wiki specs* |
| A partner's name in Ties | Click | Enter | A | Pressed state | Opens that person's window (replaces this one; this stays in history). Right-click opens theirs scrolled to the verbs |
| Section headings | Click | Tab to a heading; Home / End for first and last | LT / RT between headings (when the panel has focus) | Focus ring on the heading | The body scrolls to it. Nothing collapses: everything stays visible |
| Body | Wheel, drag the scrollbar | Arrow keys, PgUp, PgDn | Right stick | Smooth scroll (instant under reduced motion) | Scrolls |
| Reply strip | Click × | Enter on its dismiss button | A | The strip slides away | Dismisses; it also clears when the next verb runs or the window closes |

**The pinned action bar**

| Component | Mouse | Keyboard | Gamepad | Outcome |
|---|---|---|---|---|
| **Verbs** | Click | **V** or Shift+F10 | A on the button, X on a focused person, or the D-pad down to the verb list | Scrolls to the verb list and focuses the first verb |
| **Pin / Unpin** | Click | Enter on the button | A | Adds or removes the person in the outliner (Z2); the label flips |
| **Relations** | Click | Enter | A | Opens the relationships page filtered to this person. *Dependency: `relationships-page.md`* |
| **Travel there** (only when the person is elsewhere) | Click | Enter | A | Opens the focus comparison with Travel to their place preselected |

**Verbs** (every row is focusable, including greyed ones, so keyboard and screen-reader users can read why)

| Action | Mouse | Keyboard | Gamepad | Feedback | Outcome |
|---|---|---|---|---|---|
| Use a free, safe verb (Greet, Ask for news, Ask about someone) | Click | Enter | A | Row presses; a soft audio cue | Runs now; the reply appears in the reply strip with its effect lines (attitude change and why) |
| Use a costed or irreversible verb (Give a gift, Ask for help, Threaten, Provoke, bond verbs, Declare enmity, Repay) | Click | Enter | A | The row turns into "Confirm: *cost*? [Confirm] [Cancel]" | A second press confirms, Esc or Cancel backs out; then as above. A verb with a parameter expands **inline** first (user decision 2026-11-22): a short list (the items to give, the lessons on offer) or a stepper (the loan size), then Confirm |
| Use a verb that takes time (Ask for teaching 0.25, Spar 0.1) | Click | Enter | A | The row states its time ("0.25 season: this season's focus gives 75 %") | Runs now as a free action; its time is taken from this season's focus, which then yields (1 − time used) of its result, shown in the focus comparison (dialogue GDD rule 4, user decision 2026-11-22). A spar opens the fight screen now. Refused, with the reason, when less of the season is left than it takes. A Travel focus is never refused for it: it covers the share left (hud.md, Focus preview) |
| Trade | Click | Enter | A | Opens the trade view | *Dependency: trade window spec* |
| Verb tooltip (score breakdown) | Hover | Q or F2 | Y | Tooltip layer | The acceptance score's parts, in words |
| Greyed or locked verb | Hover or focus | Q | Y | Reason shown in the row and the tooltip | Nothing runs |

**Assumptions (user approved 2026-11-22):** the verbs that spend resources, create a debt or can't be undone ask for a
second press, and the free social verbs run at once; the reply strip has its own dismiss and does not take Esc, which
closes the whole panel as the HUD says.

**Right-click** on anything in the window that is not a person's name is a **no-op** (never a context menu); on a
person's name it opens their window scrolled to the verbs.

---

## Data Requirements

The window reads through `GameQuery` and writes only through `GameSession` actions (ADR-0006); it owns no game state.
Status is as of 2026-11-22.

| Data | Source system | Read / Write | Status | Notes |
|---|---|---|---|---|
| Identity (name, gender, age, archetype / calling, portrait key) | World DB people records | Read | Built | Through `GameQuery.person(s, id)`, a deep copy. The portrait key picks an authored image or composes one |
| Realm, stage, level, progress, lifespan | Realms, Cultivation | Read | Built | Lifespan uses the person's own sheet |
| **Stats** (health, linh lực, thần thức, vitality, căn cốt) | Character Stats via the person's fight sheet (`BuildGenerator.sheet_of`) | Read | Built | Computed on demand and cached per season by `GameQuery`; every number carries its Breakdown |
| **Power rating** | Power Rankings, `RatingService.peek_person` | Read | Built | A peek: the stored rating, `?` while provisional or stale; opening the window never runs a panel (ADR-0006 decision 1) |
| **Linh căn** (elements, purities, variants) | Character (`linh_can`) | Read | Built | |
| **Công pháp** (main, auxiliary arts, second technique, layers) | Công Pháp, the person's record | Read | Built | Each name links to its entry |
| Equipped gear and wards | Item Database (`items_of`, `equipped`) | Read | Built | |
| Traits (personality, calling, fate, gained) and their effects | NPC Traits (`npc_traits`) | Read | **Partly**: the field exists; the catalogue content is designed (37 + 14 + 10 + 16 traits) | **Overrides the dialogue GDD's "the traits the player knows": all are shown** |
| Ties (to the player first, then up to 3 notable ones), favours, feuds | NPC Relationships (`Ties`) | Read | Built | Glyph, band, direction for enmity |
| Loans | NPC Interaction & Dialogue rule 15 | Read | Designed, not built | |
| Attitude, its band and the reasons | Person record `attitude`; bands (hostile, cold, neutral, warm, friendly, close) | Read | Number built; bands and reasons designed | The reasons come from the score's parts |
| **Verb list**: which verbs are shown, will / won't accept, score parts, cost, time, requirement text | NPC Interaction & Dialogue (rules 5 to 11, Formulas A) | Read | **Designed, not built** | New `GameQuery.person_verbs(s, id)` returning copies. Needs the verb records as data and the acceptance score implemented |
| Where they are, home, master, parent, route in seasons | World DB; `GameQuery.route_seasons` | Read | Built | Everything is shown, including a person's current place |
| Met or not | `met_list` / `met_player` | Read | Built | Drives the "not met" state |
| Recent history (last events) | World DB `events_of` | Read | Built | |
| Pinned | Outliner pins | Read / **Write** | Designed (HUD), not built | Saved with the game (HUD open dependency) |
| **Use a verb** | New action `GameSession.interact(npc_id, verb_id, params)` | **Write** | Does not exist | Through `GameSession.run`, one job at a time; returns `{ok, lines, events}` for the reply strip. Only the free-form `talk` exists today |

**Real-time data:** none. Nothing changes while the window is open except through the player's own actions; it
refreshes when a season's summary closes.

**Architectural concerns (flagged, not decided here)**
1. **The verb system is the big missing piece.** The window can be built without it (placeholder verbs) but cannot be
   finished until the verb records, the acceptance score and `interact` exist: it needs its own epic.
2. **Per-person stat sheets on demand** cost something; `GameQuery` should cache them per season.
3. **Dead people "as at death"** (decided 2026-11-22: a snapshot at death): the death writes a frozen copy of what the
   sheet shows (gear, stats, công pháp, ties) on the record, a little extra save data per dead notable.
4. **Pins must be saved** (already one of the HUD's open dependencies).
5. **The dialogue GDD says the card shows "the traits the player knows"**; this spec overrides it, so that line needs
   updating.

---

## Events Fired

The project has no analytics or telemetry system, so "events" are (1) what an action returns in `result.events` for the
UI to react to (ADR-0006 decision 7) and (2) the persistent state it changes, following the dialogue GDD's rule 14
(deeds are remembered) and rule 11 (bonds).

| Player action | Event returned (in `result.events`) | Payload | Persistent state change |
|---|---|---|---|
| Open, close, back, forward, scroll, tooltips, jump to a section | **none** (deliberate: pure UI) | — | None. Window history is UI state and isn't saved. Opening the window never "meets" an unmet person |
| Pin / Unpin | `pin_changed` | person id, pinned | Writes the outliner pins (**saved with the game**) |
| Greet | `person_met` the first time, else `attitude_changed` | person id, attitude before and after, band | Met list and starting attitude (NPC Relationships rule 6); a deed record for fixed-cast meetings; may fire their authored scene, which returns `scene_started` (an event card opens) |
| Ask for news | `news_received` | what was learned: an event, a place heard of, or a clue | A place becomes heard of, or a clue is added; the cooldown is spent only if something new was said |
| Ask about someone | `person_described` | the third person's id | Cooldown and attitude only; their opinion of that person is computed, never stored |
| Give a gift | `gift_given`, `attitude_changed` | item or stones, attitude gain | Removes the item or stones; flag `gifted_by` when above the notable share (rule 14) |
| Ask for work | `quest_offered` | quest id | Hands to Quests |
| Ask for teaching | `lesson_taken`, `season_time_used` | lesson: a manual or an insight bonus; time used (0.25) | A manual copy or a speed bonus; flag `taught`; this season's focus yields 75 % |
| Ask for help | `loan_taken`, `guide_given` or `introduction_made` | terms, place, sect | Loan: stones plus a debt record, flag `owes_loan`, due in `loan_term` seasons |
| Trade | its own events (trade window spec) | — | — |
| Spar | `fight_started`, then the fight's result | opponent | Counts as a rated fight (Power Rankings rule 12); flag `sparred` |
| Threaten | `threat_resolved` | success or failure | Attitude falls hard, a grudge flag; on failure they may attack (ambush fight event) |
| Provoke | `fight_started` | opponent | Attitude falls; death possible; mercy choice after a win |
| Bond verbs (companion, disciple, brotherhood, đạo lữ) | `bond_formed` | kind, person | NPC Relationships creates the record; a tie that would be evicted is named before confirming |
| Declare enmity | `enmity_declared` | person | +30 enmity both ways (NPC Relationships rule 8) |
| Repay a debt | `debt_repaid` | which obligation | Closes the obligation; attitude rises a little |
| Travel there | none from here | — | The focus comparison fires its own |

**Flagged for the architecture team**
- **Every verb changes persistent state** (attitude, flags, items, ties, quests, loans). They all go through the one
  new action `GameSession.interact(npc_id, verb_id, params)` under ADR-0006: one job at a time, events in the result,
  deterministic on the session stream.
- **No analytics events are defined:** the game has no telemetry system and this spec adds none. If one is added
  later, the returned events are the natural hook.
- **The pin write** needs a save-format decision (already among the HUD spec's dependencies).

---

## Transitions & Animations

Timings are the HUD spec's knobs (`design/ux/hud.md`, Tuning Knobs: `motion_fast` 0.15 s, `motion_slow` 0.5 s); the
reduced-motion setting turns every animation instant through the HUD's one central motion helper.

| Moment | Animation | Timing | Under reduced motion |
|---|---|---|---|
| **Open** (no panel was open) | The panel slides in from the left over the map | `motion_fast` | Appears at once |
| **Replace** (another panel, or another person, was open) | The content cross-fades; the frame stays put | `motion_fast` | Swaps at once |
| **Close** | The panel slides out to the left | `motion_fast` | Disappears at once |
| **Back / forward** | The same cross-fade as a replace | `motion_fast` | Swaps at once |
| **Jump to a section** (Verbs button, V, heading) | A short smooth scroll | `motion_fast` | Jumps at once |
| **A verb runs** | The reply strip slides up from the action bar; the body shrinks to make room | `motion_fast` | Appears at once |
| **Attitude changes** | The attitude word and colour cross-fade, and a "+3" chip beside the number fades out | `motion_slow` | The word and number change at once and the chip is not shown; the reply strip's text still states the change, so nothing depends on the chip |
| **Verb asks for confirmation** | The row changes in place to "Confirm: *cost*?" with no movement | None | Same |
| **A season resolves** | The panel dims | `motion_fast` | Dims at once |

**Deliberately not animated:** bars (cultivation, linh căn purity) do not fill on open: the window is dense and the
numbers matter more than the flourish. Nothing flashes, pulses or moves on its own, and there is no parallax or
scroll-jacking.

**Skippable:** any key or click during a slide completes it (`.claude/rules/ui-code.md`).

---

## Input Method Completeness Checklist

An item is ticked only where the Interaction Map above specifies it; each unticked item is an open implementation
question and is listed under Open Questions. Touch is not a supported input method for this project, so its block is
dropped.

**Keyboard**
- [x] All interactive elements are reachable with Tab and arrow keys alone (Tab within the panel; F6 leaves it, as the HUD says)
- [x] Tab order follows visual reading order: the header, the sections top to bottom, the reply strip, the action bar (user decision 2026-11-22)
- [x] Every action achievable by mouse is also achievable by keyboard (Enter on links, V for verbs, Q for tooltips, Alt+← / → for history)
- [x] Focus is visible at all times: every focusable row, greyed verb rows and tooltip words included, shows the focus ring
- [x] Focus trap: not applicable, this is a non-modal panel and focus may leave to the map (HUD zone rings)
- [x] Esc closes or cancels (the panel, a verb confirmation) and never quits the game from a screen

**Gamepad**
- [x] All interactive elements are reachable with D-pad and left stick (a focus ring through the rows, States & Variants)
- [x] Face-button mapping documented and consistent with the HUD: A uses, B closes (Stop during a multi-season command), Y opens a tooltip, X on a focused person opens their verbs
- [x] No action needs analog precision (the right stick scrolls; moving the focus ring scrolls too)
- [x] Trigger shortcuts documented: LT / RT jump section headings; the shoulder buttons stay with the HUD (they cycle the window buttons); history is the frame's arrows
- [x] Controller disconnection changes nothing (the game is turn-based); a toast says keyboard and mouse still work, and focus stays where it was

**Mouse**
- [x] Hover states are defined for all interactive elements: every interactive row and button has a hover highlight
- [x] Clickable hit targets are at least 32 × 32 px: rows are padded to 32 px (text rows at 16 px are about 26 px tall unpadded)
- [x] Right-click is defined everywhere: a person's name opens their verbs, anything else is a no-op
- [x] Scroll wheel is defined in every scrollable zone (the body)

---

## Accessibility

Tier: **Standard**, plus reduced motion, screen-reader support for panels and the tooltip timing settings
(`design/accessibility-requirements.md`, This Project's Commitment).

| Requirement | How this window meets it |
|---|---|
| **Keyboard-only path** | Every action works from the keyboard (Interaction Map): Tab, arrows and Home / End move through the window, Enter uses a link or verb, V opens the verbs, Q opens a tooltip, Alt+← / → steps history, Esc closes. Tab order follows the visual reading order: header, sections, reply strip, action bar |
| **Gamepad** (Partial) | D-pad moves a focus ring through the rows; A uses, B closes, Y opens a tooltip, LT / RT jump sections; history through the frame's arrows |
| **Text size** | Names, numbers and verb names at the **16 px** floor; secondary lines (Breakdown lines, effect text, tooltip detail) at **14 px**. It scales with the UI scale (75–150 %, capped so the layout stays at least 1280 × 720) |
| **Colour never the only cue** | Attitude is a word, a number and an icon, not just a hue. Will / won't accept is a word plus a mark (v / x) with the reason in words. Linh căn chips carry the element's name and its own icon shape. Bands on ties are word plus glyph. A person's name is underlined and bold as well as relation-coloured. The red-green colourblind mode recolours the attitude and relation hues |
| **Screen reader** (panels are in scope) | Reading order: the header (name, realm, sect, power, attitude), then the sections as headings (Made of, Character and ties, Verbs, More), then the action bar. Rows read as "Health, 1,840, has details" and verbs as "Greet, will accept, free" or "Ask for help, won't accept, score −12: attitude −8, realm gap −4". Bars give their value as text, not just a fill. The portrait is decorative (the name already carries it). The reply strip is announced politely when it appears and states the attitude change; look-only locks, a dead person's banner and the "not met" and "elsewhere" reasons are read as text. Whether AccessKit announces tooltips is already an open question in the HUD spec |
| **Reduced motion** | Every animation becomes instant (Transitions & Animations); nothing depends on the "+3" chip |
| **No timed input** | None: the game is turn-based and nothing runs while the window is open |
| **Cognitive load** | The window is dense, so it keeps a **stable layout** (empty sections say "none", they never vanish), jump headings, plain-word reasons instead of codes, no surprise refusals, and a confirmation before anything costly. Everything is shown, so load is reduced by order, not by hiding |
| **Tooltip timing settings** | Inherited from the HUD (delay, lock mode, close grace); nothing window-specific |
| **Hit targets** | Rows are padded to at least 32 px (Input Method Completeness Checklist) |

**Known limitation:** the portrait has no description beyond the person's name, so a screen-reader user does not get an
appearance. This is acceptable at Standard; it should be recorded under Known Intentional Limitations in
`design/accessibility-requirements.md`.

---

## Localization Considerations

Baseline (`design/ux/hud.md`, Accessibility): every player-facing string goes through translation keys (Vietnamese and
English), and layouts leave room for text 30 % longer than the English. Elements where that bites:

| Element | Issue | Priority |
|---|---|---|
| **Header standing line** (realm + stage, sect, rank) | Vietnamese realm, sect and rank names together run long ("Kim Đan hậu kỳ · Thiên Kiếm Tông, trưởng lão chấp sự"). The line must **wrap to two lines**; the header's 112 px height has to allow it | **HIGH** |
| **Verb rows**: the will / won't accept word and the reason | The accept word sits in a fixed short column, and the reason ("score −12: attitude −8, realm gap −4") wraps under the verb name. Neither may truncate: a cut-off reason defeats "no surprise refusals" | **HIGH** |
| **Reply strip** | The reply is an authored Vietnamese line (dialogue GDD rule 16) plus effect lines. English comes from the same line library: every line key carries Vietnamese and English text through the translation keys, with forms of address (tiền bối, đạo hữu) kept in Vietnamese inside the English line (user decision 2026-11-22). The strip is the longest text in the window and needs room for 3 wrapped lines at 72 px | **HIGH** |
| **Action bar** (Verbs, Pin, Relations, and Travel there when elsewhere) | Four buttons in about 420 px; each 30 % longer may not fit. The bar must allow wrapping or shrinking to icon + short label | **HIGH** |
| **Trait effect lines** | One-line effects from the catalogue are authored text; they **wrap and never truncate**, because a truncated effect loses information | Medium |
| **Section headings** | All-caps with stacked Vietnamese diacritics needs generous line height (about 1.4 ×); test the tallest | Medium |
| **Numbers** | Follow the language (user decision 2026-11-22, also in the HUD spec): one locale-aware formatter, so the Vietnamese UI shows 1.840 and 1,2 and the English UI 1,840 and 1.2 | Medium |
| **Dates and time** | Use the game's calendar ("1198, Winter"); "1.4 seasons away" needs plural handling per language | Low |
| **Names** | Proper nouns, never translated; they must render with full diacritics at 16 px (the font is still to be chosen, HUD Open Questions) | Medium |
| **Attitude band words** | Six short words (hostile, cold, neutral, warm, friendly, close); each needs a Vietnamese and English term in the glossary | Low |

The sample names in the wireframe are placeholders only: names are not translated and the glossary puts Hán-Việt first.

---

## Acceptance Criteria

Tags follow the HUD spec: `[GdUnit]` automated, `[Screenshot]` retained evidence in `production/qa/evidence/`,
`[Manual]` by a tester.

**Core purpose and "everything shown"**
- [ ] `[GdUnit]` For a living person, `GameQuery.person` returns every field the window shows: name, realm and stage, sect and rank, power, attitude, linh căn, cultivation, all five stats, main method, auxiliary arts and second technique, **all** traits, ties, favours, verbs, place, home, gear, background and history. None is withheld.
- [ ] `[GdUnit]` That same data comes back for a person the player has **not met** and for one **elsewhere**: nothing is hidden by distance or acquaintance.
- [ ] `[GdUnit]` Opening the window leaves `to_dict()` and the session RNG state unchanged (ADR-0006), runs no rating panel, and does **not** add an unmet person to the met list.
- [ ] `[Screenshot]` At 1280 × 720 a retained screenshot shows each of the two views in the wireframe (top of the sheet; the verbs), with the sticky header and the pinned action bar visible in both.
- [ ] `[GdUnit]` The power number shows `?` while the rating is provisional or stale, and its tooltip says it is an estimate. Every stat and the power number open a tooltip with a Breakdown.

**Performance**
- [ ] `[GdUnit]` The window opens and is fully populated within 6 frames (0.1 s at 60 fps) of the trigger for the `person_heaviest` fixture (12 traits, 3 ties to the player plus 3 notable ties, 4 favours or loans, all 21 verbs shown, 12 history lines), and starts no background job.
- [ ] `[GdUnit]` Opening the same person twice in one season builds their stat sheet once (it is cached).

**Verbs** (these and the Events criteria can be QA'd only once the verb system exists, Open Question 5; until then
the window is built and checked against placeholder verbs for layout, states and input only)
- [ ] `[GdUnit]` A verb whose requirements fail is not shown, except bond verbs, which show greyed with their missing requirement. A verb that opposes the player's own trait is shown with its cost, never hidden or greyed.
- [ ] `[GdUnit]` Every shown verb displays will or won't accept **before** it is chosen; a "won't accept" shows the score's parts in words; the same state gives the same answer.
- [ ] `[GdUnit]` A free social verb runs on the first press. A costed or irreversible verb needs a second press; Esc or Cancel runs nothing and changes nothing.
- [ ] `[GdUnit]` A verb that takes time runs at once and lowers this season's focus yield by its share (teaching 0.25 → the focus comparison shows 75 %); with less of the season left than it takes, it is refused with the reason.
- [ ] `[GdUnit]` With a person elsewhere, every verb is greyed with the place and seasons away, and **Travel there** opens the focus comparison with Travel preselected. With an unmet person here, only Greet is live.
- [ ] `[GdUnit]` While a blocking event waits, the window is readable and every verb that changes something is locked with the reason shown.

**Navigation**
- [ ] `[GdUnit]` Clicking a name in another window opens this window; back returns to the previous window and the person is refreshed to the current state.
- [ ] `[GdUnit]` Right-click on a person's name opens their window scrolled to the verbs; right-click on anything else in the window does nothing. The player's own name opens the character sheet instead.
- [ ] `[GdUnit]` The Verbs button and V scroll to the verb list and focus its first row; Esc closes the panel and returns focus to the opener.

**Error and empty states**
- [ ] `[GdUnit]` A dead person shows the banner and the sheet as at death, with no verbs and no Pin; a person with no record shows "no record of this person" and the back arrow still works; neither raises an error.
- [ ] `[GdUnit]` A person with no ties, favours or filled công pháp slots shows "none" rows; no section disappears.
- [ ] `[GdUnit]` While a season resolves the window is inert and dimmed and reads nothing from the session.

**Accessibility, motion and localization**
- [ ] `[Screenshot]` In greyscale, attitude, will / won't accept and element chips are still distinguishable (word, mark or shape, never colour alone).
- [ ] `[Screenshot]` At the 150 % UI scale cap and at 1280 × 720, text keeps its 16 px / 14 px floors and nothing is clipped.
- [ ] `[Screenshot]` In the compact layout (below 1600 × 900: a 48 px portrait) and at 2560 × 1440, the window shows the same sections with nothing clipped.
- [ ] `[Manual]` With a screen reader, the reading order is the header, then the four sections, then the action bar; verb rows read their accept answer and reason; the reply strip is announced when it appears. (Gated on the HUD spec's open AccessKit question.)
- [ ] `[GdUnit]` With reduced motion on, every transition in the table is instant and the "+3" chip is not shown.
- [ ] `[GdUnit]` With strings 30 % longer than English, the header standing line wraps to two lines and no verb reason, trait effect or reply line truncates.

---

## Open Questions

**Conflicts with other documents**
1. ~~**Timed verbs and the one-season focus.**~~ **Decided 2026-11-22:** time taxes the focus. A timed verb is a free
   action done at once, and its time is taken from the season's focus, which yields (1 − time used); the focus
   comparison shows it. Applied to the dialogue GDD rule 4 and the HUD's Focus preview. Build note: the session's
   `_pass_season` scales the focus by the share of the season left.
2. ~~**"The traits the player knows."**~~ **Done 2026-11-22:** the dialogue GDD's person card now shows all traits;
   `npc-traits.md` has no hidden-trait rule to change.
3. ~~**"See everything" versus last-seen data.**~~ **Decided 2026-11-22:** everywhere. People bubbles and outliner
   pins show where people are now; the HUD spec is amended.
4. ~~**Dead-person data.**~~ **Decided 2026-11-22:** a snapshot at death (Data Requirements, concern 3). Build: the
   death writes the frozen copy; the save format (Required ADR #1) carries it.

**Not yet decided or built**
5. **The verb system** (verb records, the acceptance score, `GameQuery.person_verbs`, `GameSession.interact`) is
   designed (`npc-interaction-dialogue.md`) but not built: only the free-form `talk` exists. It needs its own epic.
6. ~~**Verb choosers.**~~ **Decided 2026-11-22:** inline in the panel (Interaction Map).
7. ~~**English for the reply strip.**~~ **Decided 2026-11-22:** the line library carries Vietnamese and English per key
   (Localization). The dialogue GDD's rule 16 should say so when it is next revised.
8. ~~**Number format.**~~ **Decided 2026-11-22:** follow the language; the HUD spec is amended.
9. **Pins** need a save-format decision (also a HUD dependency).

**Input and layout gaps from the checklist**
10. ~~The input gaps~~ **decided 2026-11-22** (defaults accepted; Input Method Completeness Checklist), and **X on a focused person** opens their verbs (decided 2026-11-22, added to the HUD's gamepad rules).
11. Header and action-bar sizes under 30 % longer text (Localization, HIGH items).

**Dependencies on specs that do not exist yet**
12. The sect window, the relationships page (`design/ux/relationships-page.md`), the trade window, the known list,
    and wiki entries for traits and công pháp.

**Smaller items**
13. **Pattern library gap** (user: flag and continue, 2026-11-22): there is no `design/ux/interaction-patterns.md`.
    This spec invents four patterns for it: the sticky header with pinned action bar and section jumps, the
    will / won't badge (a word plus a mark), the reply strip, and the confirm-in-place verb row. The HUD spec flags the
    same gap for its own; run `/ux-design patterns` when the library is started.
14. No `design/player-journey.md` exists: author it from `.claude/docs/templates/player-journey.md` to establish
    player context for this screen. The portrait limitation should be added to Known Intentional Limitations in
    `design/accessibility-requirements.md` (done 2026-11-22). AccessKit tooltip support is already open in the HUD spec. The ASCII
    wireframe has no diacritics, so a mock with the real font is needed once the font is chosen.

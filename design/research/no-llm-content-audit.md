# No-LLM Content Audit (2026-11-15)

**Decision (user, 2026-11-15):** the LLM features are parked. The game must be playable with no LLM, from authored
data: events, characters, history, flavour. Player-facing text stays **Vietnamese**, as the current templates are.
Using an LLM at *authoring* time to draft data that is then reviewed is not ruled out.

## What players get today with the LLM off

| Text | Offline fallback today | State |
|---|---|---|
| Events | 19 templates, `assets/data/events_templates.json` (`EventTemplateSource`) | Thin, and stale: the templates key to the old generator's place types (`thanh`, `tran`, `phuong_thi`, `son`, `coc`, `ho`, `bi_canh`, `dao`), not the fixed world's 13 kinds (great_seat, minor_seat, city, market, town, village, mine, peak, volcano, lake, island, forest, gorge). `dao_an_co_vat` uses Đạo Ấn, which Item DB retired |
| Narration of a choice | The template's outcome line (`Narrator.narrate`) | Works; one line per outcome |
| NPC talk | 3 greetings by attitude band plus one random line from the person's history (`Narrator._talk_template`) | Very thin: no traits, calling, realm or sect in the voice |
| Epitaph / life chronicle | The raw fact list (`Narrator.epitaph`) | Not prose |
| Quests | Errands only, `quest_templates.json` | Biggest gap: Quests rule 3 (approved; user decision 2026-11-06) has the LLM design every person and sect quest |

## What the GDDs assume

- **Hard dependencies:** Quests (33 mentions; the LLM designs quests), the game concept's pitch (the LLM tells the
  life, voices people, generates events), NPC Traits (traits read by the LLM to voice people).
- **Narration only** (needs sentence templates, not redesign): Sects (notable choices), Regional Economy & Trade (price
  shocks), Thiên Kiếp (boss summaries, epitaph), World Generation & History (chronicle lines are "canon the LLM narrates
  around"; with the LLM parked the line itself is the player-facing text).
- **Guard rails that simply go unused:** Modifiers rule 16, Effects rule 15, Item Database rule 16, Công Pháp's
  LLM-invented events, Character Stats' fortune reward ceiling. Template events use the same budgets.

## Rough content to author (guesses, sized against the full game)

| Surface | Rough amount |
|---|---|
| Event templates (place kind × realm band × trigger), each 2–3 choices with outcome texts | 150–250 |
| Dialogue lines (attitude band × trait × calling × realm) | 300–600 |
| Rumour and clue sentences (clue kind × quality, Travel & Map rules 16–17) | 30–60 |
| Event-log and history sentences (about 30 event kinds × 2–3 variants); the 42 chronicle lines exist | 60–90 |
| Epitaph composer phrases | 40–80 |
| Quest templates with stage graphs, replacing LLM-designed quests | 40–80 |
| Flavour descriptions: 204 places, 29 sects, techniques, items, the Ways | several hundred short texts |

## Open

- Quests rule 3 needs a redesign before Quests can run without an LLM.
- The game concept, NPC Traits and World Generation & History need wording passes that make authored text primary.
- Nothing above is scheduled yet (user: record only, 2026-11-15).

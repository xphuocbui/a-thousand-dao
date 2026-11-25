# Brief: authoring the wishlist (world-depth pass, phase A)

User, 2026-11-25: author the wishlist as proposals now, wired onto the items, sets and techniques that need them,
unpriced; the user reviews once later. Rulings that bind you are in `design/world/depth/DECISIONS-2026-11-25.md`
(read it):
- nothing new goes on the Đạo Đồ;
- no terrain, weather, place, time-of-day or season conditions in fight rules;
- Modifier = a plain number on a stat (+X, or X % increased/more, optionally tag-scoped, conversion allowed);
- Effect = anything with a rule, hand-designed and unpriced.

## Read

- `design/world/depth/builds/wishlist.md`: your section (named in your prompt), each entry's requesters and homes.
- `design/gdd/modifiers.md` and `design/gdd/effects.md` by section (Grep `^#` for headings): stat list, scopes, the
  Effect record format, and the starter Effects as examples.
- `design/items/catalogue-*.json` for modifier keys and sizes; `design/techniques/catalogue-*.json` and
  `design/arts/family-*.json` for technique and art records.
- The requesters' records (`design/world/depth/**/*.cast.json`), their lineage (`sects/<key>.techniques.json`), their
  items (`*.items.json`) and `tree.targets_note`, so what you author fits their build.

## Write (phase A: new files only; a later wiring pass applies them)

`design/world/depth/builds/authored/<your-name>.json`:

```json
{"by": "<your-name>", "entries": [
  {"wish": "<wishlist key(s)>", "kind": "modifier|effect|technique|art",
   "record": { ...the authored thing in its catalogue's format: a modifier line {key, value, scope}, an Effect
     {id, name "English (Hán-Việt)", group, rule, reads, payload, closes, hosts}, a technique or art record... },
   "wire": [ {"file": "design/world/depth/sects/<key>.items.json", "id": "<item or technique id>",
              "field": "modifiers|effects|arts|passives|lineage.secret|...", "action": "add|replace", "note": "why"} ],
   "fun": "the moment it creates", "status": "proposal"}
]}
```

Plus a short `builds/authored/<your-name>.md`: one line per entry (name, what it does, who carries it).

Rules:
- Every wish in your section gets an entry, or a one-line reason it can't be authored (say which ruling or rule it
  breaks).
- **Wiring targets must be existing items or techniques of the requesters.** Prefer the piece that already carries the
  build: their set's full-set Effect, their lineage's main or secret method. Where no fitting piece exists, propose a
  new item or technique record inside the entry, with `"action": "new"`.
- **Modifier values** follow the catalogue's sizes for the host's grade or tier. Effects stay short, readable and
  deterministic.
- Do not edit any existing file. Do not commit. Do not run Godot. Prefix scratchpad files with your name.
- Report briefly (under 150 words): entries authored, entries refused and why.

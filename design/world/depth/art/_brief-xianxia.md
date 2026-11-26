# Brief: the xianxia rewrite of the portrait prompts (2026-11-26)

The user found the current portraits read as **wuxia** (grounded, practical clothes, naturalistic light) when the game
is **xianxia**. They chose a new style after a demo ("v1 is better"), and you rewrite prompts into it.

## Read first
- `design/world/depth/art/portraits/demo-xianxia.json`: the 20 demo prompts the user approved. Use them for the level
  and kind of change only. Do not copy their phrasing.
- `XIANXIA_STYLE` in `tools/asset-pipeline/portraits/paint_authored.py`: the style block sent before every prompt.
- `design/world/depth/art/portraits/xianxia-dress.json`: the xianxia dress sheet for every sect (keys `x:<sect>`).
- For each person: their current prompt (in `design/world/depth/art/portraits/<batch>/<group>.json`) and their cast
  record (by key under `design/world/depth/**/*.cast.json`).

## The rules, all in one list
1. **Rewrite, never patch or append.** Keep the person, the moment (`imagined`), the face, the signature objects and
   the expression. Re-imagine **Clothing**, **Light** and, where needed, **Background** and **Hair ornaments** in
   the xianxia style. Write the whole `subject` fresh, as one coherent picture of 200-300 words.
2. **Xianxia dress.** Cultivators dress as immortals:
   - flowing layered silk and gauze, two or three crossed collars, wide sleeves;
   - embroidered borders in the sect's motifs;
   - jade or silver ornaments.

   Follow the sect's `x:` sheet: every member wears the sect's colours and marks, so a sect reads as one house.
3. **Rank and realm show in the dress.**
   - Outer disciples and low realms (Luyện Khí) wear the simplest graceful silk.
   - Elders, heads and high realms (Kết Đan and up) wear the sheet's richest version: brocade, crowns, glowing
     treasures, a visible aura.
   - Write this into the Clothing and Power parts yourself. No separate rank or realm line is added for you.
4. **Power may be drawn, but not always.** Where it suits the person and the moment, add a short **Power:** part: a
   soft aura, wisps of qi or floating motes in the colour of the person's strongest element (from the record's
   root), stronger for the stronger. Many low-realm people show none.
5. **Light is ethereal:** moonlight, spirit-light, mist, glow and soft rim light, not flat daylight realism.
6. **Not wuxia.**
   - No rough leather, aprons, work wool or felt, and no gritty realism, unless the person's story asks for it.
   - A servant, a mortal or a poor storyteller may be plainer; say so, and keep it clean.
   - Rags only where the story calls for it.
7. **Keep what must stay:** every visible mark or flaw, named gear (the sword, the beast, the item), age, and the
   memorial treatment for the dead.
8. No writing in the picture. No names or images from existing novels, dramas or games.

## Write
- One output file per writer: `design/world/depth/art/portraits/x-<sect>/<your id>.json`, shaped like `pilot.json`
  (`{"people": [...]}`).
- Each entry keeps `key`, `sex`, `age`, `memorial` and `imagined`, and sets `"dress": "x:<sect>"` (or null for people
  without a sect) and `"style": "xianxia"`.
- After your **first 5 entries**, stop and run `python -I tools/design/world/art_prompt_check.py`. Fix anything it
  flags in your file, then continue.
- Finish with the checker clean for your entries. Validate that the JSON parses.
- Do not commit. Report in under 80 words.

## The full pass (after the user approved Băng Tâm, 2026-11-26)
Your writer id names one or more chunks in `design/world/depth/art/_xianxia-writers.json`. Each chunk is listed in
`design/world/depth/art/_xianxia-chunks.json`, with its `keys`, its `source` (the current prompts) and its `out`
file. Write one output file per chunk, at the chunk's `out` path, holding exactly that chunk's people.
- Use the person's own sect for `dress` (`x:<their sect>`, from the cast record).
- For people outside any sect (clans, market-folk, hermits, loose, demonic), `dress` is null and the Clothing part
  carries the xianxia dress itself.
- After each chunk file, append `<writer> <chunk> done <count>` to `design/world/depth/art/_progress.md`.

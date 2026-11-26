# Brief: author portrait prompts (world-depth art, 2026-11-25)

You write one portrait prompt for every person in your batch, for a Godot cultivation (tu tiên) grand-strategy game.
The user has approved the method after a pilot. Your prompts are painted later, at low quality, by an image model.

## Read first
- `design/world/depth/art/README.md` in full. These sections hold the rules: "Rules for the subject paragraph",
  "The method as of v4", the clothing rule, and "Lessons from the pilot paint".
- `design/world/depth/art/portraits/pilot.json`, for the **format only**. Do not copy its phrasing or its order of
  parts; every person needs a fresh picture.
- `design/world/depth/art/dress.json`: the dress sheets that already exist.

## For each person, read their whole record
- the cast record: role, sect, rank, birth year, realm, root, talents, traits, appearance, backstory, wants, secret,
  ties and build;
- their named gear in the `*.items.json` files (use the description);
- their main technique's concept in `*.techniques.json` (for a hint of the qi's colour and kind);
- their beasts in `*.beasts.json`;
- the sect page's dress line (§4) and §9, for context.

The year is 1200. Apparent age follows the README's convention, and the record's `appearance` wins. Paint the dead as
memorial portraits at the age of their defining deed.

## Write
1. **Dress sheets first.** Write one sheet for each sect or group in your batch that has none in `dress.json`, into
   `design/world/depth/art/portraits/<batch>-dress.json` as `{"<sect key>": "<sheet>"}`. Use `dress.json` as the model.
   - Base it on the sect page's dress line: cloth, colours, the marks of each rank, tools.
   - Cultivators dress well, so a frugal sect is plain, never ragged.
   - For a group with no shared dress (clans, market-folk, hermits, loose, demonic), write no sheet. Put the dress in
     each person's subject.
2. **Prompts.** One file per sect or group: `design/world/depth/art/portraits/<batch>/<group>.json`, shaped like
   `pilot.json` (`{"people": [...]}`). Each entry has these fields:
   - `key`;
   - `sex` (m or f);
   - `age` (apparent);
   - `dress` (a sheet key, or null);
   - `memorial` (true for the dead);
   - `imagined`: the moment you picture, in a few sentences;
   - `subject`: labelled parts (The moment, Face, Hair, Body, Clothing, Hands and objects, Background, Light,
     Expression), about 200-300 words, every detail specific.

   Tier C people get the same care, built from what their record gives.
3. **Skip** the ten people already in `pilot.json` (so_ngoc_ho, thang_vo_ta, hach_anh_ha, ham_tan_chung,
   ta_thanh_loan, ha_tinh_can, nhan_du_ti, mac_thang_kieu, cu_tieu_lang, cao_sa_lang).

## Rules that bite
- **Specific, never generic.** Use exact garments, colours, materials, counts and positions. The thing that makes this
  person recognisable comes first, and it must be big enough to read in a 36 px round crop.
- **Vary the lead and the shape across people.** No two people in a sect share a moment or a lead.
- **Describe the look, never the deed.** Cruelty shows in a face, not in blood. Marks and flaws must be plainly
  visible: lead with them.
- **No writing in the picture:** no seals, ledgers or banners with text.
- **Power may be drawn, but not always** (user, 2026-11-25): a qi glow, an aura or an ethereal presence where it
  suits the person and the moment.
- No names, characters or images from existing novels, dramas or games.

## Finish
Validate that each JSON file parses. After each group file, append one line to `design/world/depth/art/_progress.md`:
`<batch> <group> done <count>`. If you are cut off, the next writer resumes from there. Touch only your batch's
files and the progress file. Do not commit. Report in under 100 words.

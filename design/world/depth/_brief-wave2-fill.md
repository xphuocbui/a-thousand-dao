# Brief: wave 2, tier C fill of a great sect's gates (world-depth pass)

Same rules and style as `_brief-sect-writer.md` (read its "Names and style" and "Check" sections, and `schema.md`).
You add **tier C people** to great sects that are already written, so the sect's gates feel full: outer disciples
(ngoại môn), inner disciples (nội môn), stewards (chấp sự), servants (tạp dịch), the gate's families.

For each sect in your prompt:
1. Read its page `design/world/depth/sects/<key>.md` (sections 2, 4, 5, 6, 7, 9, 12) and its cast files
   `<key>.cast.json`, `<key>.2.cast.json`, `<key>.3.cast.json`. Know its halls, its factions, its lineage methods by
   rank, its admission rule, its land and birthplaces.
2. Write **`design/world/depth/sects/<key>.4.cast.json`** only, with about **15 Trúc Cơ and 30 Luyện Khí** new living
   people, all tier C (`quotas.json` now allows 45 Trúc Cơ and 55 Luyện Khí per great sect, existing included; check
   the current counts first and stay within).
3. Each person: the tier C fields of `schema.md` (key, name_hv, name_han, gloss optional, sex, born, alive, realm,
   stage, sect, rank, home, birthplace, role, tier "C", root, traits with personality 3 + calling + upbringing,
   backstory 1-2 sentences, at least one tie, master if any, build with lineage method by rank and 1 gear piece).
4. Make them **belong**: each has a master or a friend or a family member already in the sect (key), a hall, a
   faction or a quarrel from the page's section 9, a birthplace on the sect's ground (R1) whose land fits their root.
   Siblings and cousins in the same gate are good. Outer disciples hold the lineage's base element at ≥ 30; inner
   ranks the main element (R2); exceptions only with a reason.
5. Masters must be older and of a higher realm (a Trúc Cơ can teach Luyện Khí).

Do not edit any other file (not the existing cast files, not the page). Do not commit or run Godot. Use unique
scratchpad file names (prefix with your sect keys). Run `python -I tools/design/world/depth_check.py` and fix every
finding in your files. Report briefly (under 150 words): counts per sect and the checker's final lines.

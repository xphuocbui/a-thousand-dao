# Brief: writer for people outside sects (world-depth pass)

Same pass, same rules and quality bar as `_brief-sect-writer.md`. **Read that brief first** and follow everything
in it (read list, style, names, checks), except where this file differs.

## What differs

- You write a **group** of people who belong to no sect, in `design/world/depth/people/<group>.md` (the group's
  shared story: who they are, where they live, how they live, what binds them, their hooks) and
  `design/world/depth/people/<group>.cast.json` (and `<group>.2.cast.json`... in batches), plus optionally
  `people/<group>.items.json` for their signature items (id prefix: the group's initials and a hyphen).
- `sect` is `""` for everyone. Ranks are `""`. There is no lineage and no admission rule (R2 does not apply).
  Roots follow birthplaces (R1) and nothing else. That is why loose cultivators include the odd roots no sect would take.
- Main techniques: a catalogue technique the person could plausibly have found or bought, a fallen sect's method
  (say which), a generated stand-in `<hoang|huyen|dia|thien>_<element>`, or a technique you propose in
  `people/<group>.techniques.json` (same schema as a sect's, without `lineage`).
- Ties may go to people in the sect files that **already exist** in `design/world/depth/sects/*.cast.json` and
  `assets/data/world_history.json`, and should: a loose cultivator was expelled from a sect, a clan marries its
  daughters into a great sect, a merchant owes a sect elder. Read the sect pages in `design/world/depth/sects/*.md`
  that your group touches.
- Places: use place ids from `_inputs/world.json` and the sect slices `_inputs/<sect>.json` (the `ground` lists).

## Groups and quotas

Your prompt names your group, its members already in the world (keep their keys and facts), and your quota by realm.
Living outside-sect people across all groups must stay within `quotas.json` for `""` (Hóa Thần 1, Nguyên Anh 3, Kết
Đan 25, Trúc Cơ 60, Luyện Khí 100, existing people included), so keep to your group's share.

# Brief: wave 3, tier C fill of minor sects (world-depth pass)

Same as `_brief-wave2-fill.md` (read it, and the "Names and style" and "Check" sections of `_brief-sect-writer.md`),
except:

- You fill **minor sects**. For each sect in your prompt, read its page `design/world/depth/sects/<key>.md` (sections 2,
  4, 5, 6, 7, 9) and its cast files, then write **`design/world/depth/sects/<key>.5.cast.json`** only, with about
  **2 Trúc Cơ and 5 Luyện Khí** new living tier C people (`quotas.json` now allows 6 Trúc Cơ and 10 Luyện Khí per minor
  sect, existing included; count first, and stay within).
- A no-lean sect (its page says so) admits any root: roots follow birthplace only.
- Masters must be older and of a higher realm: a Trúc Cơ can teach Luyện Khí; a Luyện Khí cannot be a master.
- Each new person is tied to someone in the sect (master, kin, friend, rival) and to its halls or quarrels.
- Do not edit any existing file: another writer (the cross-sect pass) is editing the other cast files right now.
- Keys and names must be unique in the whole world: grep `design/world/depth/**/*.cast.json` for a key before using it.

Run `python -I tools/design/world/depth_check.py` and fix every finding in your files. Report briefly (under 150
words): counts per sect and the checker's final lines.

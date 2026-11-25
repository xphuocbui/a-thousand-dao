# Brief: fix pass B, story shapes (world-depth review fixes)

The content review found that about six plot shapes repeat across the 50 sects (`review/RANKED.md` group B). A planner
wrote one block per sect saying what changes: `review/SHAPES-PLAN.md`. You apply it to **your batch's sects only**.

## Read, in this order
1. `SHAPES-PLAN.md`: the top section ("Rules for every rewrite"), then **only your sects' blocks** in §4.2 or §4.3, and
   the §4.4 rows that name your sects. Also read §5, §6 or §7 if your batch is named for them.
2. **The current files**, not the plan's quotes. The plan was written while a mechanical sweep was still editing, so a
   quote or a date in it may be stale: trust the file.
3. The `read-*.md` findings that name your sects, and `review/_bc-notes.md` lines for your batch.

Do not read other sects' blocks or pages to match their style. Each sect is its own story; there is no model to copy.

## Do
- Rewrite §9 (Inside the sect) and §12 (Story hooks) of each page, and §1 or §3 where the block names them, to the
  block's arc. Then edit the named people's records (`backstory`, `wants`, `secret`, `ties`, `traits`) to carry it.
- **A secret is an act in progress:** someone is doing something now that will be found out or finished.
- **At least one person per changed sect is cruel, callous, greedy or petty in what they do**, and the traits match the
  deeds (a trait without a deed is not the fix).
- Keep cited facts: chronicle ids (C, A, V) are game data and keep their years and text. `cross-sect.md` threads keep
  who did what and when; only the arc around them changes.
- **New people** (only where the block asks): full records per `schema.md`, a root that passes the sect's R2 gate, an
  age that fits the realm and the events, Hán-Việt names with matching Hán characters, ties written on both sides.
- Edits needed **outside your files** (another sect's page or cast, `cross-sect.md`, a group file): do not make them.
  Append each to `review/_b-requests.md` as one line: target file, key or section, the change, and why.
- After each sect, append one line to `review/_b-progress.md`: `<batch> <sect> done` plus a one-sentence note on what
  changed. If you are cut off, the next writer resumes from there.

## Do not
- **Touch what works.** Leave these exactly as they are: the kept sects' arcs (SHAPES-PLAN §2), and every item in the
  "best items" sections of the `read-*.md` files (for example Lạc Hà's twin swords and the pledged ring, the rear guard
  of Đan Sơn Mạch, Hoa Triêu Dương's Shao, Vi Thanh Âm's written canon, Mục Vân Trang's three stones, Kim Vạn Lý's
  Losing Hand, Hám Tàn Chung and Tòng Bích Linh).
- **Write to the counters.** Do not swap words to lower a script count ("heir", "has never", "succession"). Write the
  new story; the readers judge it, not the script.
- Land on the other flagged shapes the plan lists (the exposing ledger, the lost top layer, two houses that disagree, the
  junior who "has begun to" notice, the Kết Đan who refuses the headship, the dying witness, sailing past the charts).

## Rulings in force
No caps inside pieces (use a closing cost or a decay). No terrain, weather, place, time-of-day or season conditions in
fight rules (Combat rule 26). R2 admission for anyone you add or move. No names, characters or plots from existing
novels, dramas or games. A tile is 25 km and roads run about 15 km a day.

## Finish
Validate that every JSON file you touched parses, and run `python -I tools/design/world/depth_check.py` until it shows no
findings in your files. Touch only your batch's files plus the two shared append files. Do not commit. Prefix scratchpad
files with your batch name. Report in under 150 words: sects done, new people added, requests filed, anything left.

## Added after the pilot (fresh read, `review/read-pilot-B.md`)
1. **Check your plan block before you write.** The pilot's two shape slips came from the block, not the writer. If your
   block itself has someone who "has found" or "noticed" something, or a breach "against the custom", rework that part
   into an act with a cost, and say so in your progress line.
2. **The echo test covers mechanics and names, not only words.** Read every gloss (the dead founder's included) and
   every number in a rule you inherit against the source being removed. A count, a name's meaning or a paraphrased line
   is an echo.
3. **Do not add a custom so that someone can break it in secret.** If a breach is the act, someone sees it and it costs
   something now. At most one witness per arc; everyone else in it profits, pays or does something. Do not reuse an
   act another sect already uses (copying a paper to sell, a skim).
4. **Every person who knows a secret has a stated way of knowing:** a book they keep, a road they rode. When you cut a
   line, check whether it was someone's source.
5. **Travel check.** For every act that moves people, papers or goods, work out road days. Deadlines and "a week" must
   fit, and two people who trade weekly live in one place.
6. **Size and cadence.** One §9 bullet is 120 words or fewer, with five named people or fewer; wrap lines at 120
   characters. Do not repeat a rhythm ("X a night", "by the Y") more than once per sect.
7. **Close your own seams.** Before you finish:
   - apply every open row in `review/_b-requests.md` that targets your files, and log each as `APPLIED <row>` in
     `_b-progress.md`;
   - re-grep your sects' dated moves and renames across `design/world/depth/`;
   - list any request you filed that is still open in your report. Do not call a batch clean while a row is open.

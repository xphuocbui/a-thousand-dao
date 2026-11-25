# Fresh read: fix pass B pilot (Phất Y, Lạc Hà, Thiên Bảo; the 1150 pile and repeated people)

Read on 2026-11-25 against `git diff -- design/world/depth/` (HEAD is the before state). I read §9 and §12 of the three
pages in full, and the changed records in `phat_y*.json`, `lac_ha*.cast.json`, `thien_bao.cast.json`, `loose-*`,
`demonic`, `tam_kiem`, `market-folk`, `clans.2` and `hermits-sages*`. I also checked the moved 1150 rows on every page
that holds one, `_b-requests.md` and `_b-progress.md`, and road distances from `assets/data/world_continent.json`
(25 km a tile, 15 km a day). `depth_check.py` reports no findings.

Each finding is tagged **[writer]** or **[plan]**. A [plan] finding needs a change to SHAPES-PLAN or to how its blocks
are written, not only to the brief.

## Verdict: go with changes

The process works. In all three pilot sects the secrets are now acts under way: Thôi skims the sleeve price, Hách
draws the list, Tô Bình Chu buys a substitute child, Phan writes a trap clause, Tiền sells a planted figure. Each sect
has someone harsh in deed, and their traits match: Thôi is Greedy and Callous, Hách Callous, Phan Greedy, Lam
Deceitful. Lạc Hà and Thiên Bảo share one arc, written from both sides, that is a new shape (M22, the debt paid in
people). It is the best thing in the pass. The 1150 work is careful: all 11 moves are made, and the durations are
recounted ("sixty-eight years", 317, thirteen, eighteen, eighty).

Fix four things before the next 35 sects:
1. **The echo test is about names only.** The poem still drives a mechanic and a founder's name, both from the plan.
2. **The plan seeds old shapes.** Phất Y's head breaks a custom in secret (shape 13), and two juniors notice.
3. **About 20 outside edits sit unapplied** in `_b-requests.md`, and the checker cannot see them.
4. **Bullets have grown dense and travel has gone unchecked.**

All four can be fixed with the brief changes below plus a plan scan before writers start.

## Findings by criterion

### 1. Originality (Phất Y)
**What went:** the verse in rock, reading the unreadable art (it now opens to a Wind root), the "ten paces" names, the
surname Thạch and 藏名. None of these is left in `sects/` or `people/` outside the pending requests.

**What is left:**
- **[plan] The mechanic is still 十步殺一人.** `contract-sword-canon` reads: "each second you are Moving and strike
  nothing stores a Step; at ten the next strike is a killing cut that spends them all, and the holder steps back out
  of reach." That is ten steps, one kill, and gone. SHAPES-PLAN §6 said "rule text unchanged", so the writer kept it.
  - **Fix:** take the count off ten and rename the unit to fit a contract. For example, store a **Term (Khoản 款)**
    and spend at five, or set the count by the hire. The wiring then follows in `auth-eff-2`, `WIRED.md` and
    `duel-readings.md`.
- **[plan] The founder is Quách Vô Tích 郭無跡, glossed "Leaves no trace".** This is the old verse's second clause (千里不留行,
  "a thousand li, no trace") moved into a name.
  - **Fix:** change `name_hv`, `name_han` and the gloss. Keep the key as a legacy id. One example is Quách Thủ Ước
    郭守約, "keeps the bond", which goes with the contract law.
- **[writer] The Brushed Sleeve Step paraphrases 事了拂衣去.** Its concept says "when the hire is done, brush your
  sleeve and go before anyone can thank you". The sect name 拂衣 stays by ruling, but the gloss should not restate
  the line.
  - **Fix:** "a sleeve brushed across the hilt ends the hire".
- **[writer, minor] "dried mutton carried for a thousand li"** (§4) echoes the same verse. Drop "a thousand li".
- **For the user, not the writers:** in A232, disciples climb a peak to read sword marks. This is chronicle data. It is
  a broad wuxia beat (learning from carvings), and it sits close to the Hiệp Khách Đảo murals.
- **Other works:** I found no echo. The hidden contract with no clause and the hall of the dead's sleeves read as the
  world's own.

### 2. A different story
- **Lạc Hà and Thiên Bảo:** a new shape. The succession bullets are gone, and the arc turns on the sect's own law
  (oaths are contracts, and Placement Day already sells tenths).
- **Phất Y:** the dilemma is new: two laws that collide if the writ passes. Its spine is still the old secret, though:
  Lam hides the southern contract, and now its missing line too. Most people in the arc either hide it or are finding
  it out. **[plan]** That is §6's design, and the writer followed it.

### 3. Acts in progress
- **Mostly yes.** The weak spots are the noticers, each with an act stapled on:
  - **[plan]** Yên smells the rain and asks the drivers.
  - **[plan]** Giang found the train and is copying the contract to sell.
  - **[writer]** Nhạc Trường Tín "knows which names were on the first draft".
- **Fix:** keep Yên. She pays, because it is her brother. Make Giang part of the lie, not the one who finds it. For
  example, Lam has her write the camel-train names into the road book, and Giang raises her own copying fee each
  season. This also removes a clone: **[writer]** Giang copying a document to sell repeats Giản Vạn Lộ's new act (he
  copied the order book and sold it). The same pass made the same move twice.

### 4. Harshness
- **Good:** Thôi skims the dead's families and charges by the sleeve. Phan prices children by root, "as lots". Hách
  fills the gaps with children who have never sat the dusk test. Giả Chỉ Lộ leaves his clients at the last turn.
- **[writer] Tô Bình Chu's deed is cruel, but his traits are not.** He offers a poor family his stipend if their child
  goes in his son's place, and his traits stay Humble, Patient, Content.
  - **Fix:** change Content to Deceitful. Say in the text that the Hà Khúc child would be enrolled only to be sold.

### 5. Sense
- **[writer] Lam's seal year is still 1150** in three places: phat_y §3, `lam_khe_ngon` and `py-contract-seal`. Plan §7
  says 1147. fixB-x filed the request, and the pilot owned the file, so neither writer applied it. Meanwhile fixB-x's
  progress line says "1150 now holds only the five stays".
  - **Fix:** apply the three lines.
- **[writer] Thôi's source of knowledge was cut.** Her old backstory said she paid the southern company's wages. Now
  she "knows the nine never rode a camel road" with no way of knowing.
  - **Fix:** restore it. She pays both the wages and the sleeve prices, so she sees both books.
- **[writer] Phất Y §1 says the head "leaves the valley only for a Wind child, and the last time was 1195".** The 1130
  duel was on Cùng Mục Phong, about 600 km (40 road days) away.
  - **Fix:** "has left it once since 1130, for a Wind child in 1195".
- **[writer] Yên asks the Đà Đội drivers "one by one".** Đà Đội is 577 km (38 days) from the hall she sweeps.
  - **Fix:** she asks them "as their trains come to the valley mouth for guards".
- **[writer] Hách Thần Hà "will never be placed"**, yet Hách keeps her off the list to place her herself.
  - **Fix:** "she will not be sold to the studio, because her great-aunt draws the list".
- **[writer] One Lạc Hà §9 clause reads backwards.** "so that no one can call the lot selling children" covers the
  untested children too, and putting them on the list is selling children.
  - **Fix:** split the sentence. The untested children fill the count. The head's own blood is on the list so that no
  one can say only the poor are sold.
- **[writer] The places do not fit the timing.**
  - Hách buys "a figure a week" from Tiền at Vật Hoa Thị while she draws the list at Cựu Hà Viện, 767 km (51 days)
    away.
  - Nhạc carried a draft over that road and knows two drafts.
  - Phan's "by this year's autumn auction" needs Tiền's pricing ride (about 100 days there and back) plus thirty
    children walking 51 days. The sim's cross-region travel is 3 seasons.
  - **Fix:** put Hách at Vật Hoa Thị for the spring auction. Have Nhạc carry the one list. Say outright that Phan chose
    a date Lạc Hà can barely meet, since that is the trap.
- **[writer] Thiên Bảo hook 9 lists Quan Tẩy Ngọc and place 132** (Khê Thanh, about 1,400 km off), but its text names
  neither. Write her in or drop her.
- **The 1150 pile (fixB-x): sound.**
  - Every moved id has its §3 row, cast lines and recounted ages: Kỷ Thu Tịch at 317, Kê Thính Đào at thirteen, Quản
    Phục Thu at eighteen, Chung Tàn Hưởng's 68 years, Quản Tề Phong 1142.
  - The repeated people are separated, and both sides of their ties are written.
  - The refused "Nhan Cô Vụ at 410" is correct: it breaks C169 and the 1,000-year cap. That is a plan error caught.
- **Ties:** both sides are written for the new arc ties: Hách and Tô Bình Chu; Thôi and Lam; Thôi and Yên. Thôi
  "creditor" and Lam "debt" are consistent with each other. Đái Hổ Thần is still one-way (in requests).

### 6. Craft
- **[writer] Lạc Hà's "Thirty contracts for the ring" is one bullet of about 280 words with nine bold or named people.**
  - **Fix:** split it into three bullets: the lot, the list, and the signer and the clerk.
- **[writer] Some lines run past 120 characters unwrapped:** phat_y §9 (the Khúc sentence), thien_bao "Thirty hands"
  and hook 9, and lac_ha hook 13.
- **[writer] Khúc Liệt Dương's sentence is stranded inside "The fold at a time".** Tiết Hoành Sa is re-aimed by
  swapping a clause ("says it loudest when Lam is in the room"). He is still a succession rival with no succession.
  - **Fix:** give Khúc her own act (she rides south this spring to see the contract kept), or cut the sentence.
- **[writer] The voice is plainer and more concrete:** "a stone in ten", "blood at the nose", "priced at a third".
  Two problems remain:
  - **A new tic:** "a clause a night", "one fold a night", "a figure a week", and "by the sleeve" five times.
  - **"never" grew in phat_y.md from 4 to 7** ("they have never met", "a Metal house that will never teach them").
- **[writer] Hán:**
  - The lintel saying "thù tức thị tạ" has no Hán (酬即是謝).
  - **Quy Vỏ** uses native *vỏ*, the same fault as the fixed "Thuê". Hán-Việt would be Quy Sao 歸鞘.
  - Thang Vô Tạ 湯無謝 and the other new names are fine.

### 7. Lost value
- **Intact:** Lạc Hà's twin swords and the pledged ring. `lac_ha.items.json` is not in the diff, and the ring bullet
  is unchanged. Thiên Bảo's slag and second key are unchanged. Ring secrecy holds: the lot is sold "against the loan",
  which is public (N-lac_ha-03), not against the ring.
- **[writer] "The seam" is flattened.** It has no act left, and it repeats the second half of Thang's secret. Merge it
  into hook 7, or give it an act. For example, Thang has started climbing to the sword marks at night.
- **Small losses:**
  - Hách's private ledger of savings "against the day she needs a favour" is gone.
  - Tông Thủ Tín's "lies awake over the day he will be asked to [write a false figure]" is gone, and the lot was that
    day. A stronger act: the head asks him to book the lot at the new rate, and he sends the families the old one.

## Process risk: outside edits
`_b-requests.md` holds about 20 unapplied rows:
- the `py-ten-paces` id and names, still live in `builds/authored/` and `duel-readings.md`;
- "ten paces" twice in loose-south;
- "Thạch wears the sleeve" in hermits-sages;
- cross-sect §1.3, which still states Lạc Hà's heir quarrel;
- the Đái Hổ Thần tie, which is one-way;
- Lam's 1147.

The brief says "do not edit outside your files", while plan §4.4 says the other side is written "in the same pass".
Across 35 sects this pile grows faster than anyone reads it, and `depth_check` passes over it.

## Instructions to add to `_brief-fix-B.md`
1. **Echo test covers mechanics and names, not only words.** Before you finish, read every gloss (including the dead
   founder's) and every number in a rule you inherit against the source you are removing. A count, a name meaning or a
   paraphrased line counts as an echo. If the plan says "rule text unchanged" and the rule is the echo, change the
   number and file the wiring request.
2. **Do not add a custom so that someone can break it in secret.** If a breach is the act, let someone see it and make
   it cost something now. Use at most one witness per arc. Everyone else in it profits, pays or does something, and
   an act already used by another batch (for example, copying a paper to sell) does not count.
3. **Every person who knows a secret needs a stated way of knowing**: a book they keep, a road they rode. When you cut
   a line, check whether it was the source.
4. **Travel check.** For every act that moves people, papers or goods, work out road days (a tile is 25 km; a road
   runs 15 km a day), and make deadlines and "a week" fit. Two people trading weekly must be in one place.
5. **Size and cadence.** Keep one §9 bullet to 120 words or fewer, with five named people or fewer, and wrap lines at
   120 characters. Do not repeat a rhythm ("X a night", "by the Y") more than once per sect.
6. **Close your own seams.** At the end of a batch, re-grep the plan's dated moves and renames for your sects across
   the whole repo. List any unapplied `_b-requests.md` rows in your progress line. Do not write "clean" while a row is
   open.

**Process changes (for the planner, not the brief):**
- Run an applier over `_b-requests.md` after every 3-5 sects.
- Scan the remaining SHAPES-PLAN blocks before writers start for "has found", "noticed" and "against the custom". The
  pilot's two shape slips came from the block, not the writer.

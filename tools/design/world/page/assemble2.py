import json
import os
import re
import sys

src, here = sys.argv[1], os.path.dirname(os.path.abspath(__file__))
H = open(src, encoding="utf-8").read()
assert H.startswith("<!doctype html>")
H = H[H.index("<body>\n") + len("<body>\n"):]
assert H.rstrip().endswith("</body></html>")
H = H.rstrip()[:-len("</body></html>")] + "</body></html>"
rd = lambda f: open(os.path.join(here, f), encoding="utf-8").read()
data = json.load(open(os.path.join(here, "build", "out2", "data2.json"), encoding="utf-8"))


def rep(old, new, count=1):
    global H
    n = H.count(old)
    assert n == count, (n, old[:80])
    H = H.replace(old, new)


# fonts, css
rep("family=IBM+Plex+Sans+Condensed:wght@500;600&", "family=IBM+Plex+Sans+Condensed:wght@500;600&family=Noto+Serif:wght@400;600&")
rep("a:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px; }\n</style>",
    "a:focus-visible { outline: 2px solid var(--accent); outline-offset: 2px; }\n" + rd("frag_css.css") + rd("frag_css2.css") + "</style>")

# header
rep("<h1>Continent 11: sects, places, sacred ground and history sites</h1>",
    "<h1>Continent 11: the land and its 1,200 years</h1>")
rep("Each territory is then split into its own regions. Every region belongs to a sect.</p>",
    "Each territory is then split into its own regions. Every region belongs to a sect. The written history now sits on the same map: the chronicle tells how each sect, ruin and hidden place came to be, and the page ends where every game begins.</p>\n"
    '    <a class="lead-card" href="#chronicle"><b>0 → 1,200</b><span>Read the chronicle on the map: 200 landmark events in six eras, 16 wars, 18 sects that rose and fell, 30 cities and 17 ruins, 34 legendary items, and 316 annals of the twenty regions.</span></a>')
rep('<span class="pill">Mine names, origins: approved</span></div>',
    '<span class="pill">Mine names, origins: approved</span><span class="pill">Chronicle, cast, traits, sect start: approved 2026-11-15</span><span class="pill">Wider history: 200 landmarks, 316 annals, items, cities, ruins; Thính Vũ Lâu tier 1: approved 2026-11-15</span></div>')
rep("  </header>\n",
    "  </header>\n\n"
    '  <nav class="toc" aria-label="Sections">'
    '<a href="#sects">Great sects</a><a href="#regions">Regions</a><a href="#minor">Minor sects</a><a href="#places">Places</a>'
    '<a href="#sacred">Sacred</a><a class="star" href="#chronicle">Chronicle</a><a href="#annals">Annals</a><a href="#items">Items</a><a href="#sites">History sites</a>'
    '<a href="#people">People</a><a href="#start">Year 1,200</a><a href="#mines">Mines, origins</a><a href="#next">Next</a></nav>\n')

# section ids
for h2, sid in [("The seven great sects", "sects"), ("The 20 regions", "regions"), ("The 22 minor sects", "minor"),
                ("Places, roads and arrays", "places"), ("Sacred features", "sacred"), ("History sites", "sites"),
                ("Mine names and origins", "mines"), ("Next", "next")]:
    rep("  <section>\n    <h2>%s</h2>" % h2, '  <section id="%s">\n    <h2>%s</h2>' % (sid, h2))

# great sect table: founded column
rep("<th>Regions</th><th>Land</th><th>What it holds</th>", "<th>Regions</th><th>Land</th><th>Founded</th><th>What it holds</th>")
ev = data["events"]
for k, s in data["sects"].items():
    if s.get("tier") is None or s.get("minor") or s.get("vanished"):
        continue
    e = next(x for x in ev if x["kind"] == "sect_founded" and k in x["sects"])
    who = data["people"][e["people"][0]]["name"]
    pat = re.compile(r'(<tr><td class="name"><span class="sw" style="background:rgb\([^)]*\)"></span>' + re.escape(s["name"]) + r'<br>.*?%</td>)')
    m = pat.findall(H)
    assert len(m) == 1, s["name"]
    H = H.replace(m[0], m[0] + '<td class="num"><button type="button" class="gotobtn" data-goto="%s">year %d</button><span class="sub">by %s</span></td>' % (e["id"], s["founded"], who))

# minor sect table: founded column
rep("<th>Alignment</th><th>Leans</th>", "<th>Alignment</th><th>Founded</th><th>Leans</th>")
for k, s in data["sects"].items():
    if not s.get("minor") or k == "thu_phan":  # Thu Phần Các's row is added below, Founded included
        continue
    pat = re.compile(r'(<tr><td class="num">\d+</td><td class="name"><span class="sw dia"[^>]*></span>' + re.escape(s["name"]) +
                     r'<br>.*?<td(?: class="ma")?>(?:chính đạo|trung lập|ma đạo)</td>)')
    m = pat.findall(H)
    assert len(m) == 1, s["name"]
    H = H.replace(m[0], m[0] + '<td class="num">%d</td>' % s["founded"])
rep("chính đạo · trung lập · ma đạo. A first guess; alignment belongs to World Generation &amp; History (#27)",
    "chính đạo · trung lập · ma đạo, as the sect start of 2026-11-15 sets them: Củng Tinh Quán and Thối Tinh Môn follow their neutral lord. Founding years run from 150 (Củng Tinh Quán) to 1,020 (Phần Vũ Đường)")


rep("<b>15 · 5 · 2</b>", "<b>13 · 7 · 3</b>")
rep("<b>50 %</b><span>of the land held by the three tier-1 sects, one for each of the ~3 Hóa Thần</span>", "<b>62 %</b><span>of the land held by the four tier-1 sects: Thính Vũ Lâu, the only ma đạo great sect, was promoted on 2026-11-15</span>")
i = H.index("Thính Vũ Lâu<br><span class=\"han\">聽雨樓</span>")
j = H.index("<td class=\"num\">2</td>", i)
assert j - i < 400
H = H[:j] + "<td class=\"num\">1</td>" + H[j + len("<td class=\"num\">2</td>"):]
rep("<h2>The 22 minor sects</h2>", "<h2>The 23 minor sects</h2>")
i = H.index("<h2>The 23 minor sects</h2>")
j = H.index("</p>", i)
H = H[:j] + " Since 2026-11-15 there are 23: Thu Phần Các, Thính Vũ Lâu's third vassal and its second ma đạo one, was founded in 960 among the graves of Lôi Trạch Thành." + H[j:]
i = H.index("</tbody>", H.index("<h2>The 23 minor sects</h2>"))
H = H[:i] + '<tr><td class="num">23</td><td class="name"><span class="sw dia" style="background:rgb(92,96,206)"></span>Thu Phần Các<br><span class="han">秋墳閣</span></td><td>Pavilion of the Autumn Graves</td><td>Thính Vũ Lâu</td><td>19 Kinh Trập Sơn</td><td class="ma">ma đạo</td><td class="num">960</td><td>Darkness, Metal</td><td>soul arts and grave wards</td><td>Lý Hạ: thu phần quỷ xướng Bão gia thi (in the autumn graves ghosts sing old poems); its seat looks over the ruins of Lôi Trạch Thành</td></tr>' + H[i:]
for nm in ("Thối Tinh Môn", "Củng Tinh Quán"):
    pat = re.compile(r'(<td class="name"><span class="sw dia"[^>]*></span>' + re.escape(nm) + r'<br>.*?)<td>chính đạo</td>')
    m = pat.search(H)
    assert m, nm
    H = H[:m.start()] + m.group(1) + "<td>trung lập</td>" + H[m.end():]
# places: stale note
rep("<p class=\"lede\">Not yet: names for the 16 mines; the secret realms, ruins and famous blessed lands, which come with the written history (#27).</p>",
    "<p class=\"lede\">The history added to these: 15 towns grew into cities, for 30 in all, and 17 ruins of fallen sects and cities lie in the wild. <a href=\"#chronicle\">The chronicle map</a> shows each one in its years, and the secret realms, ruins and blessed lands are under <a href=\"#sites\">History sites</a>.</p>")

# sacred: wasteland now explained
rep("Who fought here is for the history (#27).</td>",
    "Here Thiên Xu Tông fought Lạc Hà Tông and Thính Vũ Lâu from 790; the war ended in one day in 803. <button type=\"button\" class=\"gotobtn\" data-goto=\"C017\">See the battle</button></td>")
rep("One miasma wasteland, Chiết Kích Nguyên, is an old battlefield, set by hand in the scorched badlands where three sects meet.",
    "One miasma wasteland, Chiết Kích Nguyên, is an old battlefield, set by hand in the scorched badlands where three sects meet; <a href=\"#chronicle\">the chronicle</a> says whose.")

# history sites
rep("<b>Hidden slots</b> are ground for the written history (#27). Each has 2–3 candidate spots in the wild, and each game's seed picks one, so the same story lies somewhere different and a guide can't give it away. The history names each slot and ties it to a dead cultivator, a vanished sect or a lost blessed land.</p>",
    "<b>Hidden slots</b> each have 2–3 candidate spots in the wild, and each game's seed picks one, so the same story lies somewhere different and a guide can't give it away. The chronicle now gives every one of the 28 slots its origin: a dead cultivator, a vanished sect, a fallen star or a hermit who stayed too long. The table below lists them all; <i>See it</i> shows the spots on the chronicle map.</p>")
rep("Its gate opens inside Chiết Kích Nguyên, near the barrow; whose war it holds is for the history (#27).</td>",
    "Its gate opened inside Chiết Kích Nguyên, by the barrow, seven years after the battle (year 810). Those who go in say Quý Trường Kích's army still waits there. <button type=\"button\" class=\"gotobtn\" data-goto=\"C019\">See it</button></td>")
rep("Fallen walls on the edge of Chiết Kích Nguyên; whose they were is for the history (#27).</td>",
    "Fallen walls on the edge of Chiết Kích Nguyên: the ramparts Thiên Xu Tông's war marshal Quý Trường Kích held until he fell in 803. <button type=\"button\" class=\"gotobtn\" data-goto=\"C017\">See the battle</button></td>")
rep("Its gate is on the island Dục Nhật Đảo, where the sun bathes.</td>",
    "Its gate is on the island Dục Nhật Đảo, where the sun bathes. Its first recorded opening is year 0 of the calendar. <button type=\"button\" class=\"gotobtn\" data-goto=\"C001\">See it</button></td>")
rep("Its gate is a cave by a forest stream.</td>",
    "Its gate is a cave by a forest stream. Found by a mortal fisherman in year 560. <button type=\"button\" class=\"gotobtn\" data-goto=\"C011\">See it</button></td>")
i0 = H.index("    <h3>Hidden slots</h3>")
i1 = H.index("    <p class=\"lede\">Rough spots. A secret realm's gate tile")
H = H[:i0] + ("    <h3>The 28 hidden slots and how each came to be</h3>\n"
              "    <p class=\"lede\">3 secret realms, 4 ruins of vanished sects, 6 dead cultivators' cave abodes, 2 large and 13 small blessed lands. The 80 tile secrets (springs, pocket veins, herb patches, caches) have no history of their own.</p>\n"
              "    <div class=\"scroll\"><table id=\"slots\"></table></div>\n") + H[i1:]

# insert the new sections
rep('  <section id="sites">', rd("frag_chron2.html") + "\n" + rd("frag_annals.html") + "\n" + '  <section id="sites">')
rep('  <section id="mines">', rd("frag_people2.html") + "\n" + '  <section id="mines">')

# next
i0 = H.index('  <section id="next">')
i1 = H.index("</section>", i0) + len("</section>")
H = H[:i0] + ('  <section id="next">\n    <h2>Next</h2>\n    <ol>\n'
              "      <li>Fully authored builds for the 51 living people (World Generation &amp; History Core Rule 6). Their traits are done.</li>\n"
              "      <li>Effects for the 34 legendary items, hand-designed, so Item Database rule 20d can place them.</li>\n"
              "      <li>Whether the Pivot keeps the peace in play: writs and stepping in (Sects &amp; Missions open question 11).</li>\n"
              "      <li>Run the map exporter so the game data gets the 30 cities and the 17 ruins.</li>\n"
              "      <li>Any time: the map's art style, and the two rough borders.</li>\n"
              "    </ol>\n  </section>") + H[i1:]

# data + script before </body>
blob = json.dumps(data, ensure_ascii=False, separators=(",", ":")).replace("</", "<\\/")
rep("</body></html>", '<script type="application/json" id="c11data">' + blob + "</script>\n<script>\n" + rd("frag_js2.js") + "</script>\n")

out = os.path.join(here, "build", "continent11.html")
open(out, "w", encoding="utf-8", newline="\n").write(H)
print("written", len(H.encode("utf-8")))

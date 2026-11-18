import sys
tp, od, outp = sys.argv[1:4]
t = open(tp, encoding="utf-8").read()
R = [
    ("and they form long travel roads between crossroads of 5 to 9 roads (starts, jewel sockets, wheel centres).",
     "and they form long travel roads. Where roads meet, the crossroad (5 to 9 links) is almost always an attribute travel node itself: 102 of 116 crossroads in PoE 1, 179 of 213 in PoE 2."),
    ("the inner 40 % of the radius holds about a tenth of the nodes,", "the inner 40 % of the radius holds about a tenth of PoE 1's nodes (a sixth of PoE 2's),"),
    ("and 34–61 notables sit within 10 points.", "and 34–61 notables sit within 10 points (PoE 2: 20–28)."),
    ("Twelve classes share six starts, set much closer to the centre,", "Each of the six starts is shared by two classes (the data names pairs such as Witch/Sorceress), set much closer to the centre,"),
    ('Only about <span class="num">2 %</span> of our nodes sit between half and 85 % of the radius,', 'Only about <span class="num">2 %</span> of our nodes sit between half and nine-tenths of the radius,'),
    ("ctx.lineWidth=Math.max(1*unit,Math.min(30,unit*1.3));", "ctx.lineWidth=unit*1.2;"),
]
for a, b in R:
    if a in t:
        t = t.replace(a, b)


def blob(f):
    return open(od + "/" + f, encoding="utf-8").read().replace("</", "<\\u002f")


for k, f in (("__TREES__", "trees.json"), ("__METRICS__", "metrics.json"), ("__THEMES__", "themes.json"), ("__TMETRICS__", "theme-metrics.json")):
    assert t.count(k) == 1, k
    t = t.replace(k, blob(f))
open(outp, "w", encoding="utf-8").write(t)
print(len(t.encode()))

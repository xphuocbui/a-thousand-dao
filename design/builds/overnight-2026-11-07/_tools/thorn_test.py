"""Does the cheap 0.5 s kit survive an enemy that punishes many small hits?
Runs the first and second lines, and two exotic builds, against the Mixed arts with thorns."""
import json
import os
import subprocess
import sys

R = r"C:\Users\xphuo\IdeaProjects\my-game"
D = os.path.join(R, "design", "builds", "overnight-2026-11-07")
os.chdir(R)
panel = json.load(open(os.path.join(D, "_tools", "panel-enemies.json"), encoding="utf-8"))
tmp = os.path.join(D, "scratch", "_panel", "thorn.json")


def run(path, thorns):
    b = json.load(open(path, encoding="utf-8"))
    b["enemy_overrides"] = dict(panel["Mixed"], thorns_c=thorns)
    b["rules"] = list(b.get("rules", [])) + ["thorn_skin"]
    b.pop("enemy", None)
    json.dump(b, open(tmp, "w", encoding="utf-8"))
    out = subprocess.run([sys.executable, os.path.join(D, "_tools", "fight_x.py"), tmp],
                         capture_output=True, text=True, encoding="utf-8").stdout
    res = [l.split("\t") for l in out.splitlines() if l.startswith("result\t")]
    end = [l for l in out.splitlines() if l.startswith("end_state\t")]
    name = b.get("name", "")
    if not res:
        return "?"
    r = res[0]
    won = r[3] == "winner=" + str(name)
    e = end[0].split("\t") if end else ["", "", ""]
    return "%s %s | %s | %s" % ("W" if won else r[1][:1].upper() if r[1] != "knockout" else "L",
                                r[2].replace("t=", ""), e[1], e[2])


cases = [("Fierce Fire first", "sheets/fierce-fire.fight.json"),
         ("Scattered Sparks (kit)", "variants/fierce-fire-second-way.fight.json"),
         ("Evergreen first", "sheets/evergreen.fight.json"),
         ("Pine Rain (kit)", "variants/evergreen-second-way.fight.json"),
         ("Grindstone first", "sheets/grindstone.fight.json"),
         ("Thin Shavings (kit)", "variants/grindstone-second-way.fight.json"),
         ("One Long Word first", "sheets/one-long-word.fight.json"),
         ("Short Reply (kit)", "variants/one-long-word-second-way.fight.json"),
         ("Banked Well", "sheets/banked-well.fight.json"),
         ("Already-Waited", "sheets/already-waited.fight.json")]
for thorns in (0.25, 0.5, 1.0):
    print("== thorns_c", thorns)
    for label, rel in cases:
        print("%-24s %s" % (label, run(os.path.join(D, rel), thorns)))

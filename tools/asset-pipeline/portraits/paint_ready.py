"""Paint every xianxia group whose rewrite is complete (all its chunk files exist), skipping what is painted.
Groups come from design/world/depth/art/_xianxia-chunks.json; Băng Tâm (x-bang_tam) is included. Safe to run again:
paint_authored.py skips images that already exist.
Run (repo root): python -I tools/asset-pipeline/portraits/paint_ready.py [--jobs 4]
"""
import json
import os
import subprocess
import sys

ROOT = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", "..", ".."))
jobs = sys.argv[sys.argv.index("--jobs") + 1] if "--jobs" in sys.argv else "4"
chunks = json.load(open(os.path.join(ROOT, "design/world/depth/art/_xianxia-chunks.json"), encoding="utf-8"))
groups = {}
for c in chunks:
    groups.setdefault(c["group"], []).append(c["out"])
ready = [g for g, outs in groups.items() if all(os.path.exists(os.path.join(ROOT, o)) for o in outs)]
for g in sorted(ready):
    folder = os.path.join(ROOT, "design/world/depth/art/portraits", "x-" + g)
    want = sum(len(json.load(open(os.path.join(folder, f), encoding="utf-8"))["people"])
               for f in os.listdir(folder) if f.endswith(".json"))
    out = os.path.join(ROOT, "tools/asset-pipeline/portraits/out/authored", "x-" + g)
    have = len([f for f in os.listdir(out) if f.endswith(".png")]) if os.path.isdir(out) else 0
    if have >= want:
        continue
    r = subprocess.run([sys.executable, "-I", os.path.join(ROOT, "tools/asset-pipeline/portraits/paint_authored.py"),
                        "paint", "x-" + g, "--jobs", jobs], capture_output=True, text=True)
    ok = r.stdout.count(" ok")
    bad = [l for l in r.stdout.splitlines() if l.startswith("portrait") and not l.endswith(" ok")]
    print("x-%s: %d painted now, %d already, %d failed %s" % (g, ok, have, len(bad), bad[:3]), flush=True)
print("ready groups %d of %d" % (len(ready), len(groups)))

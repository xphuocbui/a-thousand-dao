"""The job list of the parallel world-depth Stage 6 run (production/plans/stage6/_run.md), for tools/headless/run_jobs.py.

    python -I tools/headless/stage6_jobs.py [--waves A-B] [--out production/plans/stage6/_jobs.json] [--only k1,k2,...]
                                           [--tag wNN] [--part record|serial|both]

Owners still open (depth_gap.py) are dealt into waves of three: the sects first, the outside groups last, each wave
one large owner with two small ones so the lanes end together. After each wave comes its serial job (a barrier):
the engine words, then the gate stage6_gate.py serial (merge, exports, checks, commit). Every record job's gate is
stage6_gate.py record <owner>. --waves picks a range (1-based, inclusive) for a pilot.
"""
import json
import os
import subprocess
import sys

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
OUTSIDE = ["clans", "market-folk", "demonic", "hermits-sages", "loose-south", "loose-north"]
SKIP = {"bang_tam", "authored"}   # Băng Tâm is done; the authored wishes' Effects ride with their owners' records
RECORD_TOOLS = "Read,Glob,Grep,Write,Edit,Bash(python -I:*),Bash(python:*)"
SERIAL_TOOLS = RECORD_TOOLS + ",Bash(C:/Godot/Godot_v4.7.1-stable_win64_console.exe:*)"
SYSTEM = ("You are a headless world-depth Stage 6 job; nobody is watching and nobody answers questions. The user waived, "
          "for these jobs (2026-11-26), CLAUDE.md's ask-first protocol ('May I write...', show drafts, wait for approval): "
          "write the files the brief names without asking. Decisions are auto-accepted: take your recommended option, think "
          "it through against the design rules in the brief, and log it with its reason. Finish every step of the brief; if "
          "something blocks a step, log it as an open item in your review file and carry on, never stop early or hand back. "
          "The owner's depth text (design/world/depth/) and the user's rulings are the source of truth; the brief's examples "
          "(Băng Tâm) show the form, not the content. Never run git.")


def sizes():
    out = os.path.join(ROOT, "production", "session-logs", "stage6-gap.json")
    os.makedirs(os.path.dirname(out), exist_ok=True)
    subprocess.run([sys.executable, "-I", "tools/design/world/depth_gap.py", "--json", out], cwd=ROOT,
                   capture_output=True)
    g = json.load(open(out, encoding="utf-8"))["sections"]
    n = {}
    for sec in ("techniques", "arts_new", "items", "sets", "effects", "beasts", "stand_ins"):
        for e in g.get(sec, []):
            if e["state"] not in ("runs", "game"):
                n[e["owner"]] = n.get(e["owner"], 0) + 1
    return n


def waves(n):
    sects = sorted((o for o in n if o not in OUTSIDE and o not in SKIP), key=lambda o: -n[o])
    out = []
    while sects:
        w = [sects.pop(0)]
        w += [sects.pop() for _ in range(2) if sects]
        out.append(w)
    rest = [o for o in OUTSIDE if o in n]
    for i in range(0, len(rest), 3):
        out.append(rest[i:i + 3])
    return out


TAG = None   # --tag: the serial step's tag (one owner run alone: its own tag, e.g. "thien_xu")


def jobs_for(ws, first, part="both"):
    out = []
    for i, w in enumerate(ws, start=first):
        tag = TAG or "w%02d" % i
        for o in (w if part in ("both", "record") else []):
            out.append({
                "id": "s6-%s" % o, "model": "opus", "timeout_min": 240, "allowed": RECORD_TOOLS, "system": SYSTEM,
                "env": {"DEPTH_STAGE": os.path.join(ROOT, "design", "stage6-staging", o)},
                "expect": "production/plans/stage6/%s.done" % o,
                "prompt": ("Run world-depth Stage 6's record pass for owner %s. Follow "
                           "production/plans/stage6/_brief-record.md exactly (OWNER = %s). DEPTH_STAGE is already set "
                           "for you. Finish by writing production/plans/stage6/%s.done." % (o, o, o)),
                "after": [sys.executable, "-I", "tools/headless/stage6_gate.py", "record", o]})
        if part == "record":
            continue
        out.append({
            "id": "s6-serial-%s" % tag, "model": "opus", "timeout_min": 240, "allowed": SERIAL_TOOLS, "system": SYSTEM,
            "barrier": True, "expect": "production/plans/stage6/_serial-%s.done" % tag,
            "before": [sys.executable, "-I", "tools/headless/stage6_gate.py", "snapshot", tag],
            "prompt": ("Run world-depth Stage 6's serial step for wave %s, owners %s. Follow "
                       "production/plans/stage6/_brief-serial.md exactly (TAG = %s). Finish by writing "
                       "production/plans/stage6/_serial-%s.done." % (tag, ", ".join(w), tag, tag)),
            "after": [sys.executable, "-I", "tools/headless/stage6_gate.py", "serial", tag] + w})
    return out


def main():
    arg = lambda k, d=None: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    global TAG
    TAG = arg("--tag")
    n = sizes()
    ws = waves(n)
    if arg("--only"):
        ws = [[o.strip() for o in arg("--only").split(",")]]
    lo, hi = 1, len(ws)
    if arg("--waves"):
        a, _, b = arg("--waves").partition("-")
        lo, hi = int(a), int(b or a)
    out = arg("--out", os.path.join(ROOT, "production", "plans", "stage6", "_jobs.json"))
    jobs = jobs_for(ws[lo - 1:hi], lo, arg("--part", "both"))
    with open(out, "w", encoding="utf-8", newline="\n") as fh:
        json.dump(jobs, fh, ensure_ascii=False, indent=1)
    for i, w in enumerate(ws, start=1):
        mark = "*" if lo <= i <= hi else " "
        print("%s w%02d  %s" % (mark, i, "  ".join("%s(%d)" % (o, n.get(o, 0)) for o in w)))
    print("wrote %s: %d jobs" % (os.path.relpath(out, ROOT), len(jobs)))
    return 0


if __name__ == "__main__":
    sys.exit(main())

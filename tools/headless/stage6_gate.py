"""The gates of the parallel world-depth Stage 6 run (production/plans/stage6/_run.md), run by tools/headless/run_jobs.py
as each job's `after` command (a non-zero exit halts the run).

    python -I tools/headless/stage6_gate.py snapshot <tag>          hashes of every dirty path, before a serial job
    python -I tools/headless/stage6_gate.py record <owner>          after an owner's record job
    python -I tools/headless/stage6_gate.py serial <tag> <owner>... after a wave's serial (engine) job

record <owner>:
- every dirty path must be one a record job may write (any owner's staging, depth people files, progress files);
  anything else halts the run;
- the owner's progress file production/plans/stage6/<owner>.md must say "RECORD PASS DONE";
- the staged files lint clean (lint_techniques, lint_arts, lint_items with DEPTH_STAGE set to the owner's staging);
- sect_fight.py <owner> runs (DEPTH_STAGE set) with no REFUSED holder;
- then it commits the owner's own paths (git commit -- <paths>).
serial <tag> <owner>...:
- tools/design/world/stage6_merge.py for the owners (its gates), export_combat_library.py, compile_parity_export.py,
  parity_export.py --quick, test_engine.py, and the combat and parity GdUnit groups;
- then it commits every path whose content changed since `snapshot <tag>` (so another session's uncommitted hunks,
  in a GDD file say, are never swept in unless the serial job touched that file too: then it halts instead).
"""
import glob
import hashlib
import json
import os
import re
import subprocess
import sys

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", ".."))
PY = [sys.executable, "-I"]
GODOT = os.environ.get("GODOT_CONSOLE", r"C:/Godot/Godot_v4.7.1-stable_win64_console.exe")
SNAP = os.path.join(ROOT, "production", "session-logs", "stage6-snapshots")   # gitignored
TRAILER = "Co-Authored-By: Claude Opus 5.5 <noreply@anthropic.com>"
RECORD_OK = [r"^design/stage6-staging/", r"^design/world/depth/(sects|people)/[^/]+\.(cast|techniques|items|beasts)\.json$",
             r"^production/plans/stage6/[^/]+\.(md|done|reviewed)$"]


def sh(args, env=None, timeout=3600):
    r = subprocess.run(args, cwd=ROOT, capture_output=True, text=True, encoding="utf-8", errors="replace", env=env,
                       timeout=timeout)
    return r.returncode, (r.stdout or "") + (r.stderr or "")


def dirty():
    """Every changed or untracked path (expanded to files)."""
    code, out = sh(["git", "status", "--porcelain", "-uall"])
    paths = []
    for ln in out.splitlines():
        if len(ln) > 3:
            p = ln[3:].strip().strip('"')
            if " -> " in p:
                p = p.split(" -> ")[1]
            paths.append(p.replace("\\", "/"))
    return paths


def digest(p):
    f = os.path.join(ROOT, p)
    if not os.path.exists(f):
        return "gone"
    with open(f, "rb") as fh:
        return hashlib.sha256(fh.read()).hexdigest()


def commit(paths, msg):
    if not paths:
        print("nothing to commit")
        return 0
    sh(["git", "add", "--"] + paths)
    code, out = sh(["git", "commit", "-q", "-m", msg + "\n\n" + TRAILER, "--"] + paths)
    print(out.strip())
    return code


def lint(label, cmd, env, ok):
    code, out = sh(PY + cmd, env=env)
    tail = out.strip().splitlines()[-1] if out.strip() else ""
    print("%s\t%s" % (label, tail))
    if ok not in tail:
        print(out[-3000:])
        return False
    return True


def record(owner):
    bad = [p for p in dirty() if not any(re.search(rx, p) for rx in RECORD_OK)]
    if bad:
        print("FAILED\tpaths a record job may not write:\n  " + "\n  ".join(bad))
        return 1
    prog = os.path.join(ROOT, "production", "plans", "stage6", owner + ".md")
    if not os.path.exists(prog) or "RECORD PASS DONE" not in open(prog, encoding="utf-8").read():
        print("FAILED\t%s has no RECORD PASS DONE" % os.path.relpath(prog, ROOT))
        return 1
    stage = "design/stage6-staging/" + owner   # forward slashes: compared with git status paths
    env = dict(os.environ, DEPTH_STAGE=os.path.join(ROOT, stage))
    good = True
    for sub, pat, cmd, okw in (("techniques", "catalogue-sect-*.json", "tools/design/arts/lint_techniques.py", " 0 findings"),
                               ("arts", "part-sect-*.json", "tools/design/arts/lint_arts.py", " 0 findings"),
                               ("items", "catalogue-sect-*.json", "tools/design/items/lint_items.py", " 0 findings")):
        files = sorted(glob.glob(os.path.join(ROOT, stage, sub, pat)))
        if files:
            good &= lint(sub, [cmd] + files, env, okw)
    code, out = sh(PY + ["tools/design/combat_sim/sect_fight.py", owner, "--seeds", "5"], env=env, timeout=5400)
    print(out[-4000:])
    if code or "REFUSED" in out:
        print("FAILED\tsect_fight %s: a holder's build was refused" % owner)
        good = False
    if not good:
        return 1
    mine = [p for p in dirty() if p.startswith(stage + "/") or re.search(r"^design/world/depth/(sects|people)/%s\." % re.escape(owner), p)
            or re.search(r"^production/plans/stage6/%s(-review\.md|-checkpoint\.md|\.md|\.done|\.reviewed)$" % re.escape(owner), p)]
    reviewed = os.path.exists(os.path.join(ROOT, "production", "plans", "stage6", owner + ".reviewed"))
    what = "the checkpoint review and its fixes" if reviewed else "the record pass"
    return commit(mine, "feat: world-depth Stage 6 %s: %s (staged)\n\nPlan: production/plans/stage6/%s.md" % (owner, what, owner))


def snapshot(tag):
    os.makedirs(SNAP, exist_ok=True)
    snap = {p: digest(p) for p in dirty()}
    with open(os.path.join(SNAP, tag + ".json"), "w", encoding="utf-8") as fh:
        json.dump(snap, fh)
    print("snapshot %s: %d dirty paths" % (tag, len(snap)))
    return 0


def godot(target):
    code, out = sh([GODOT, "--headless", "--path", ".", "-s", "-d", "--remote-debug", "tcp://127.0.0.1:0",
                    "res://addons/gdUnit4/bin/GdUnitCmdTool.gd", "-a", target, "--ignoreHeadlessMode"], timeout=3600)
    clean = re.sub(r"\x1b\[[0-9;]*m", "", out)
    summary = [ln for ln in clean.splitlines() if "Overall Summary" in ln]
    print("%s\t%s" % (target, summary[-1] if summary else "NO SUMMARY"))
    return bool(summary) and " 0 failures" in summary[-1] and " 0 errors" in summary[-1]


def serial(tag, owners):
    snap_p = os.path.join(SNAP, tag + ".json")
    if not os.path.exists(snap_p):
        print("FAILED\tno snapshot %s" % tag)
        return 1
    snap = json.load(open(snap_p, encoding="utf-8"))
    code, out = sh(PY + ["tools/design/world/stage6_merge.py"] + owners, timeout=3600)
    print(out[-6000:])
    if code:
        print("FAILED\tstage6_merge")
        return 1
    for cmd in (["tools/design/combat_sim/export_combat_library.py"], ["tools/design/combat_sim/compile_parity_export.py"],
                ["tools/design/combat_sim/parity_export.py", "--quick"]):
        code, out = sh(PY + cmd, timeout=3600)
        print("%s\texit %d" % (cmd[0], code))
        if code:
            print(out[-3000:])
            return 1
    code, out = sh(PY + ["tools/design/combat_sim/test_engine.py"], timeout=3600)
    print("test_engine\t%s" % (out.strip().splitlines()[-1] if out.strip() else ""))
    if not out.strip().endswith("0 failed"):
        print(out[-3000:])
        return 1
    sh([GODOT, "--headless", "--path", ".", "--import"], timeout=1800)
    if not (godot("res://tests/unit/combat") and godot("res://tests/parity")):
        return 1
    changed = [p for p in dirty() if snap.get(p) != digest(p)]
    foreign = [p for p in changed if p in snap and p.startswith("design/gdd/")]
    if foreign:
        print("FAILED\tthe serial job edited GDD files that already had uncommitted changes (another session's?): %s"
              % ", ".join(foreign))
        return 1
    return commit(changed, "feat: world-depth Stage 6 serial step for %s: engine words, records merged, checks green\n\n"
                           "Plan: production/plans/stage6/_run.md" % ", ".join(owners))


def main():
    if len(sys.argv) < 3:
        print(__doc__)
        return 2
    mode = sys.argv[1]
    if mode == "snapshot":
        return snapshot(sys.argv[2])
    if mode == "record":
        return record(sys.argv[2])
    if mode == "serial":
        return serial(sys.argv[2], sys.argv[3:])
    print(__doc__)
    return 2


if __name__ == "__main__":
    sys.exit(main())

"""World-depth Stage 6, the serial step: move an owner's staged records into design/ and check them (plan Stage 6,
"After Băng Tâm Các"; staging: design/stage6-staging/<owner>/ mirroring design/, read by DEPTH_STAGE).

    python -I tools/design/world/stage6_merge.py <owner> [<owner> ...] [--check]

For each owner, the staged files move into place:
- techniques/catalogue-sect-*.json, arts/part-sect-*.json, items/catalogue-sect-*.json and items/sets-*.json go to
  design/<same path>. A file that already exists is merged by record id: the staged record replaces one of the same id,
  others are kept. That is how a job adds to another owner's file (an early promotion);
- effects/<owner>.effects.json goes to design/world/depth/effects/, merged by Effect name, then put_effects.py merges it
  into assets/data/combat_effects.json.

Then the gates (any failure exits 1 and names it):
- one id per technique, per art and per item across design/, and one owner per Effect name in the library;
- lint_techniques, lint_arts and lint_items (each must report 0 findings), and depth_check.py;
- depth_gap.py --sect <owner> (printed).

With --check nothing moves: it reports what would move and what clashes. Emits observations; the exit code is the gate.
"""
import glob
import json
import os
import shutil
import subprocess
import sys

ROOT = os.path.normpath(os.path.join(os.path.dirname(os.path.abspath(__file__)), "..", "..", ".."))
STAGE = os.path.join(ROOT, "design", "stage6-staging")
PY = [sys.executable, "-I"]


def load(p):
    with open(p, encoding="utf-8") as fh:
        return json.load(fh)


def write_list(p, recs):
    with open(p, "w", encoding="utf-8", newline="\n") as fh:
        fh.write("[\n" + ",\n".join(" " + json.dumps(r, ensure_ascii=False) for r in recs) + "\n]\n")


def merge_list(dst, src):
    """Merge a staged list file into dst by id: staged records replace same-id ones, the rest keep their order."""
    new = load(src)
    if not os.path.exists(dst):
        return new
    old = load(dst)
    by = {r["id"]: r for r in new}
    out = [by.pop(r["id"], r) for r in old]
    return out + [r for r in new if r["id"] in by]


def moves(owner):
    base = os.path.join(STAGE, owner)
    out = []
    for sub, pat in (("techniques", "catalogue-sect-*.json"), ("arts", "part-sect-*.json"),
                     ("items", "catalogue-sect-*.json"), ("items", "sets-*.json")):
        for f in sorted(glob.glob(os.path.join(base, sub, pat))):
            out.append((f, os.path.join(ROOT, "design", sub, os.path.basename(f))))
    eff = os.path.join(base, "effects", "%s.effects.json" % owner)
    if os.path.exists(eff):
        out.append((eff, os.path.join(ROOT, "design", "world", "depth", "effects", "%s.effects.json" % owner)))
    return out


def uniqueness():
    """Ids that appear in more than one record across design/ (techniques, arts, items), and Effect names."""
    bad = []
    for sub, pats in (("techniques", ["catalogue-*.json"]), ("arts", ["family-*.json", "part-*.json"]),
                      ("items", ["catalogue-*.json"])):
        seen = {}
        for pat in pats:
            for f in sorted(glob.glob(os.path.join(ROOT, "design", sub, pat))):
                for r in load(f):
                    if r["id"] in seen and seen[r["id"]] != f:
                        bad.append("%s id %s in %s and %s" % (sub, r["id"], os.path.basename(seen[r["id"]]), os.path.basename(f)))
                    seen.setdefault(r["id"], f)
    names = {}
    for f in sorted(glob.glob(os.path.join(ROOT, "design", "world", "depth", "effects", "*.effects.json"))):
        for n in load(f)["effects"]:
            if n in names:
                bad.append("Effect %s in %s and %s" % (n, os.path.basename(names[n]), os.path.basename(f)))
            names.setdefault(n, f)
    lib = load(os.path.join(ROOT, "assets", "data", "combat_effects.json"))["effects"]
    for n, f in names.items():
        src = lib.get(n, {}).get("source")
        own = "world-depth:%s" % os.path.basename(f).split(".")[0]
        if n in lib and src != own:
            bad.append("Effect %s is already in the library from %r" % (n, src))
    return bad


def run(args, label):
    r = subprocess.run(PY + args, cwd=ROOT, capture_output=True, text=True, encoding="utf-8", errors="replace")
    tail = (r.stdout or "").strip().splitlines()[-1:] if r.stdout else []
    return r.returncode, (tail[0] if tail else (r.stderr or "").strip()[-200:]), r.stdout


def main():
    args = [a for a in sys.argv[1:] if not a.startswith("--")]
    check = "--check" in sys.argv
    if not args:
        print(__doc__)
        return 2
    fails = []
    for owner in args:
        mv = moves(owner)
        if not mv:
            print("observation\t%s\tnothing staged in %s" % (owner, os.path.join(STAGE, owner)))
        for src, dst in mv:
            print("%s\t%s -> %s" % ("would move" if check else "move", os.path.relpath(src, ROOT), os.path.relpath(dst, ROOT)))
            if check:
                continue
            os.makedirs(os.path.dirname(dst), exist_ok=True)
            if dst.endswith(".effects.json"):
                d = load(src)
                if os.path.exists(dst):
                    old = load(dst)
                    old["effects"].update(d["effects"])
                    d = old
                with open(dst, "w", encoding="utf-8", newline="\n") as fh:
                    fh.write(json.dumps(d, ensure_ascii=False, indent=1) + "\n")
            else:
                write_list(dst, merge_list(dst, src))
            os.remove(src)
        if not check:
            eff = os.path.join(ROOT, "design", "world", "depth", "effects", "%s.effects.json" % owner)
            if os.path.exists(eff):
                code, tail, _ = run([os.path.join("tools", "design", "combat_sim", "put_effects.py"), eff], "put_effects")
                print("put_effects\t%s\t%s" % (owner, tail))
                if code:
                    fails.append("put_effects %s: %s" % (owner, tail))
            shutil.rmtree(os.path.join(STAGE, owner), ignore_errors=True)
    for b in uniqueness():
        fails.append("unique: " + b)
    if not check:
        for label, cmd, ok in (
                ("lint_techniques", ["tools/design/arts/lint_techniques.py"], " 0 findings"),
                ("lint_arts", ["tools/design/arts/lint_arts.py"], " 0 findings"),
                ("lint_items", ["tools/design/items/lint_items.py"], " 0 findings"),
                ("depth_check", ["tools/design/world/depth_check.py"], "findings: none")):
            code, tail, _ = run(cmd, label)
            print("%s\t%s" % (label, tail))
            if ok not in tail:
                fails.append("%s: %s" % (label, tail))
        for owner in args:
            code, _, out = run(["tools/design/world/depth_gap.py", "--sect", owner], "gap")
            print("gap %s\n%s" % (owner, "\n".join(out.strip().splitlines()[1:])))
    for f in fails:
        print("FAILED\t" + f)
    print("%d failure(s)" % len(fails))
    return 1 if fails else 0


if __name__ == "__main__":
    sys.exit(main())

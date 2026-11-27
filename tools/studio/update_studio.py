#!/usr/bin/env python3
"""Update helper for the two studio layers in this repo (used by /update-studio).

`.claude/` + `CLAUDE.md` come from Claude Code Game Studios (remote `template`).
`.agents/` + `AGENTS.md` come from Antigravity Game Studios (remote `ag-studio`),
a port of the same releases. `.agents/studio-upstream.json` records which
Antigravity commit the layer matches; the Claude side is found by merge-base.

Subcommands
  status                  fetch both remotes; report versions, new commits, what would change
  merge-ccgs --to REF     git merge --no-ff --no-commit REF (Claude side); reports conflicts
  apply-ag [--to REF]     3-way apply the upstream diff of the Antigravity layer only
  record-ag --commit REF  record REF as the Antigravity commit the layer now matches
  check                   verify both layers: PASS / FAIL / NOT ASSESSED per item

It reports observations; the skill and the user decide what to apply. It never
stashes, resets, cleans, pushes or commits.

    python -I tools/studio/update_studio.py <subcommand>
"""
from __future__ import annotations

import argparse
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.normpath(os.path.join(HERE, "..", ".."))
STATE_PATH = os.path.join(ROOT, ".agents", "studio-upstream.json")
GUARD = os.path.join(ROOT, ".agents", "hooks", "guard_shell.py")
AG_PATHSPEC = [".agents", ":(glob)**/AGENTS.md", "GEMINI.md"]
CLAUDE_PATHSPEC = [".claude", ":(glob)**/CLAUDE.md", "project.yaml"]
VALID_TRIGGERS = {"always_on", "model_decision", "glob", "manual"}


# --- git plumbing -------------------------------------------------------------

def git_raw(*args, input_text=None):
    p = subprocess.run(["git", "-C", ROOT, *args], input=input_text, capture_output=True,
                       text=True, encoding="utf-8", errors="replace")
    return p.returncode, p.stdout, p.stderr


def git_bytes(*args, input_bytes=None):
    """Patches must travel as bytes: text-mode pipes rewrite CRLF on Windows and corrupt them."""
    p = subprocess.run(["git", "-C", ROOT, *args], input=input_bytes, capture_output=True)
    return p.returncode, p.stdout, p.stderr.decode("utf-8", "replace")


def git(*args, input_text=None):
    code, so, se = git_raw(*args, input_text=input_text)
    return code, so.strip(), se.strip()


def out(*args):
    code, so, se = git(*args)
    if code:
        raise RuntimeError(f"git {' '.join(args)} failed: {se or so}")
    return so


def lines(text):
    return [l for l in text.splitlines() if l.strip()]


def commit_exists(ref):
    return git("cat-file", "-e", f"{ref}^{{commit}}")[0] == 0


def describe(ref):
    code, so, _ = git("describe", "--tags", "--abbrev=0", ref)
    return so if code == 0 else None


# --- state and versions -------------------------------------------------------

def load_state():
    with open(STATE_PATH, encoding="utf-8") as f:
        return json.load(f)


def save_state(state):
    with open(STATE_PATH, "w", encoding="utf-8", newline="\n") as f:
        json.dump(state, f, indent=2)
        f.write("\n")


def read_project_yaml(ref=None):
    if ref is None:
        try:
            with open(os.path.join(ROOT, "project.yaml"), encoding="utf-8") as f:
                return f.read()
        except OSError:
            return ""
    code, so, _ = git_raw("show", f"{ref}:project.yaml")
    return so if code == 0 else ""


def yaml_block_key(text, block, key):
    m = re.search(rf"^{block}:[ \t]*\r?\n((?:[ \t]+.*\r?\n?|[ \t]*\r?\n)*)", text, re.M)
    if not m:
        return None
    v = re.search(rf"^[ \t]+{key}:[ \t]*['\"]?([^'\"\r\n#]+?)['\"]?[ \t]*(?:#.*)?$", m.group(1), re.M)
    return v.group(1).strip() if v else None


def framework_version(ref=None):
    return yaml_block_key(read_project_yaml(ref), "framework", "version")


def vtuple(v):
    nums = re.findall(r"\d+", v or "")
    return tuple(int(n) for n in nums[:3]) if nums else None


def release_label(ref):
    subject = out("log", "-1", "--format=%s", ref)
    m = re.search(r"Release\s+(\S+)", subject)
    return m.group(1) if m else out("rev-parse", "--short", ref)


def is_ag_layer(path):
    return path.startswith(".agents/") or path.rsplit("/", 1)[-1] == "AGENTS.md"


# --- shared steps -------------------------------------------------------------

def ensure_remote(name, url):
    if git("remote", "get-url", name)[0] == 0:
        return None
    out("remote", "add", name, url)
    return f"added remote `{name}` -> {url}"


def fetch(name, tags):
    code, so, se = git("fetch", name, "main", "--tags" if tags else "--no-tags")
    tail = (se or so).splitlines()[-1:] or [""]
    return code == 0, tail[0]


def preflight(pathspec):
    problems = []
    if git("rev-parse", "-q", "--verify", "MERGE_HEAD")[0] == 0:
        problems.append("a merge is in progress: finish it (commit) or abort it (`git merge --abort`) first")
    staged = lines(out("diff", "--cached", "--name-only"))
    if staged:
        problems.append(f"{len(staged)} file(s) already staged ({', '.join(staged[:5])}"
                        f"{' ...' if len(staged) > 5 else ''}): commit or unstage them first")
    dirty = lines(out("status", "--porcelain", "--", *pathspec))
    if dirty:
        problems.append("uncommitted changes in the layer: " + "; ".join(d.strip() for d in dirty[:8])
                        + (" ..." if len(dirty) > 8 else ""))
    return problems


def refuse(problems):
    print("REFUSED - nothing was changed:")
    for p in problems:
        print(f"- {p}")
    print("Never stash, reset or clean to make room; ask the user.")
    return 2


def record(sha):
    state = load_state()
    state["ag_studio"]["commit"] = out("rev-parse", f"{sha}^{{commit}}")
    state["ag_studio"]["version"] = release_label(sha)
    save_state(state)
    return state["ag_studio"]


# --- subcommands --------------------------------------------------------------

def cmd_status(_args):
    state = load_state()
    new_counts = 0
    print("# Studio update status\n")
    for side in ("ccgs", "ag_studio"):
        note = ensure_remote(state[side]["remote"], state[side]["url"])
        if note:
            print(f"- {note}")

    print("## Working tree")
    merging = git("rev-parse", "-q", "--verify", "MERGE_HEAD")[0] == 0
    staged = lines(out("diff", "--cached", "--name-only"))
    dirty_c = lines(out("status", "--porcelain", "--", *CLAUDE_PATHSPEC))
    dirty_a = lines(out("status", "--porcelain", "--", *AG_PATHSPEC))
    print(f"- merge in progress: {'YES' if merging else 'no'}")
    print(f"- staged files: {len(staged)}")
    print(f"- uncommitted Claude-layer files: {len(dirty_c)}" + (f" ({'; '.join(d.strip() for d in dirty_c[:5])})" if dirty_c else ""))
    print(f"- uncommitted Antigravity-layer files: {len(dirty_a)}" + (f" ({'; '.join(d.strip() for d in dirty_a[:5])})" if dirty_a else ""))

    r = state["ccgs"]["remote"]
    print(f"\n## Claude side (.claude/, CLAUDE.md) - remote `{r}`")
    ok, msg = fetch(r, tags=True)
    claude_latest = None
    if not ok:
        print(f"- NOT ASSESSED: fetch failed: {msg}")
    else:
        base = out("merge-base", "HEAD", f"{r}/main")
        claude_latest = describe(f"{r}/main")
        new = lines(out("log", "--oneline", f"{base}..{r}/main"))
        changed = lines(out("diff", "--name-only", base, f"{r}/main"))
        new_counts += len(new)
        print(f"- current: {describe(base) or 'untagged'} (merge-base {base[:8]}); project.yaml framework.version: {framework_version() or 'MISSING'}")
        print(f"- latest upstream: {claude_latest or 'untagged'} at {r}/main ({out('rev-parse', '--short', f'{r}/main')})")
        print(f"- new upstream commits: {len(new)}; files they change: {len(changed)}")
        for c in new[:15]:
            print(f"  - {c}")
        if len(new) > 15:
            print(f"  - ... {len(new) - 15} more")
        tags = lines(out("tag", "--merged", f"{r}/main", "--no-merged", "HEAD", "--sort=v:refname"))
        if tags:
            print(f"- release tags not yet merged: {', '.join(tags)}")

    a = state["ag_studio"]
    print(f"\n## Antigravity side (.agents/, AGENTS.md) - remote `{a['remote']}`")
    ok, msg = fetch(a["remote"], tags=False)
    port_covers = None
    if not ok:
        print(f"- NOT ASSESSED: fetch failed: {msg}")
    elif not commit_exists(a["commit"]):
        print(f"- NOT ASSESSED: recorded commit {a['commit'][:8]} is not in the repo (upstream rewritten?)")
    else:
        head = f"{a['remote']}/main"
        port_covers = framework_version(head)
        print(f"- current: {a['version']} ({a['commit'][:8]})")
        print(f"- latest upstream: {release_label(head)} ({out('rev-parse', '--short', head)}), ports framework {port_covers or 'UNKNOWN'}")
        if git("merge-base", "--is-ancestor", a["commit"], head)[0] != 0:
            print("- WARNING: recorded commit is not an ancestor of upstream main (history rewritten); the diff still applies by content")
        new = lines(out("log", "--oneline", f"{a['commit']}..{head}"))
        new_counts += len(new)
        files = lines(out("diff", "--name-only", a["commit"], head))
        layer = [f for f in files if is_ag_layer(f)]
        outside = [f for f in files if not is_ag_layer(f)]
        print(f"- new upstream commits: {len(new)}; Antigravity-layer files changed: {len(layer)}; other files changed: {len(outside)}")
        for c in new[:15]:
            print(f"  - {c}")
        if outside:
            print(f"- not applied by apply-ag (shared files come from the Claude side): {', '.join(outside[:10])}{' ...' if len(outside) > 10 else ''}")
        if layer:
            _, patch, _ = git_bytes("diff", "--binary", a["commit"], head, "--", *layer)
            clean = git_bytes("apply", "--check", "-", input_bytes=patch)[0] == 0
            print(f"- patch onto local files: {'applies cleanly' if clean else 'needs a 3-way merge (local edits overlap; conflicts possible)'}")

    print("\n## Release pairing")
    claude_now = framework_version()
    print(f"- Claude side now: {claude_now or 'UNKNOWN'}; Claude latest: {claude_latest or 'NOT ASSESSED'}")
    print(f"- Antigravity port covers: {port_covers or 'NOT ASSESSED'}")
    if claude_latest and port_covers:
        if vtuple(claude_latest) > vtuple(port_covers):
            print(f"- LAG: Claude Code Game Studios {claude_latest} is not ported yet (port covers {port_covers}).")
        elif claude_now and vtuple(claude_now) >= vtuple(port_covers) and not new_counts:
            print("- UP TO DATE: both sides are on the latest paired release.")
        else:
            print(f"- paired target: Claude side v{port_covers} with Antigravity {a['remote']}/main")
    return 0


def cmd_merge_ccgs(args):
    problems = preflight(CLAUDE_PATHSPEC)
    if problems:
        return refuse(problems)
    target = args.to
    if not commit_exists(target):
        print(f"REFUSED: `{target}` is not a commit here (run status first to fetch).")
        return 2
    code, so, se = git("merge", "--no-ff", "--no-commit", target)
    msg = (so + "\n" + se).strip()
    if "unrelated histories" in msg:
        print("REFUSED by git: unrelated histories. Never use --allow-unrelated-histories; see UPGRADING.md Strategy A2.")
        return 2
    unmerged = lines(out("diff", "--name-only", "--diff-filter=U"))
    staged = lines(out("diff", "--cached", "--name-only"))
    print(f"# merge-ccgs {target}\n")
    print("\n".join(msg.splitlines()[-6:]))
    print(f"\n- files changed by the merge: {len(staged)}")
    print(f"- conflicts: {len(unmerged)}")
    for f in unmerged:
        print(f"  - {f}")
    ag = [f for f in staged if is_ag_layer(f) or f == "GEMINI.md"]
    if ag:
        print(f"- WARNING: the merge touches Antigravity files ({', '.join(ag[:8])}): upstream ships its own; ask the user before going on")
    print("\nNothing is committed. Resolve conflicts, apply the UPGRADING.md steps, then commit the merge.")
    return 1 if unmerged else 0


def cmd_apply_ag(args):
    state = load_state()
    a = state["ag_studio"]
    target = args.to or f"{a['remote']}/main"
    if not commit_exists(target):
        print(f"REFUSED: `{target}` is not a commit here (run status first to fetch).")
        return 2
    if not commit_exists(a["commit"]):
        print(f"REFUSED: recorded commit {a['commit'][:8]} is missing; fetch `{a['remote']}` first.")
        return 2
    problems = preflight(AG_PATHSPEC)
    if problems:
        return refuse(problems)
    files = lines(out("diff", "--name-only", a["commit"], target))
    layer = [f for f in files if is_ag_layer(f)]
    outside = [f for f in files if not is_ag_layer(f)]
    print(f"# apply-ag {a['version']} -> {release_label(target)}\n")
    if outside:
        print(f"- not applied (outside the Antigravity layer): {', '.join(outside[:10])}{' ...' if len(outside) > 10 else ''}")
    if not layer:
        rec = record(target)
        print(f"- no Antigravity-layer changes; recorded {rec['version']} ({rec['commit'][:8]})")
        print("- paths to commit: .agents/studio-upstream.json")
        return 0
    _, patch, _ = git_bytes("diff", "--binary", a["commit"], target, "--", *layer)
    code, so, se = git_bytes("apply", "--3way", "--whitespace=nowarn", "-", input_bytes=patch)
    so = so.decode("utf-8", "replace")
    unmerged = lines(out("diff", "--name-only", "--diff-filter=U"))
    print(f"- upstream files applied: {len(layer)}")
    for l in (se or so).splitlines()[-8:]:
        print(f"  {l}")
    print(f"- conflicts: {len(unmerged)}")
    for f in unmerged:
        print(f"  - {f}")
    print("- paths to commit: " + " ".join(sorted(set(layer))) + " .agents/studio-upstream.json")
    if code == 0 and not unmerged:
        rec = record(target)
        print(f"- recorded {rec['version']} ({rec['commit'][:8]}) in .agents/studio-upstream.json")
        return 0
    print(f"- NOT recorded: resolve the conflicts, then run `record-ag --commit {out('rev-parse', target)}`")
    return 1


def cmd_record_ag(args):
    if not commit_exists(args.commit):
        print(f"REFUSED: `{args.commit}` is not a commit here.")
        return 2
    rec = record(args.commit)
    print(f"recorded {rec['version']} ({rec['commit'][:8]}) in .agents/studio-upstream.json")
    return 0


def strip_frontmatter(text):
    text = text.replace("\r\n", "\n")
    m = re.match(r"---\n.*?\n---\n", text, re.S)
    return text[m.end():] if m else text


def cmd_check(_args):
    results = []

    def add(item, verdict, detail=""):
        results.append((item, verdict, detail))

    # 1-2: the safety hook
    hooks_path = os.path.join(ROOT, ".agents", "hooks.json")
    try:
        with open(hooks_path, encoding="utf-8") as f:
            hooks = json.load(f)
        wired = any(
            g.get("matcher") == "run_command"
            and any("guard_shell.py" in (h.get("command") or "") for h in g.get("hooks", []))
            for spec in hooks.values() if isinstance(spec, dict)
            for g in spec.get("PreToolUse", [])
        )
        add("hooks.json wires guard_shell.py to run_command", "PASS" if wired else "FAIL",
            "" if wired else "no PreToolUse run_command handler calls guard_shell.py")
    except FileNotFoundError:
        add("hooks.json wires guard_shell.py to run_command", "FAIL", ".agents/hooks.json is missing")
    except ValueError as e:
        add("hooks.json wires guard_shell.py to run_command", "FAIL", f"invalid JSON: {e}")
    if not os.path.exists(GUARD):
        add("guard blocks `git stash`, allows `git status`", "FAIL", ".agents/hooks/guard_shell.py is missing")
    else:
        try:
            def decide(cmd):
                payload = json.dumps({"toolCall": {"name": "run_command", "args": {"CommandLine": cmd}}})
                p = subprocess.run([sys.executable, "-I", GUARD], input=payload, capture_output=True,
                                   text=True, timeout=20)
                return json.loads(p.stdout)["decision"]
            got = (decide("git stash list"), decide("git status"))
            add("guard blocks `git stash`, allows `git status`", "PASS" if got == ("deny", "allow") else "FAIL",
                "" if got == ("deny", "allow") else f"got {got}")
        except Exception as e:  # noqa: BLE001 - report, do not guess
            add("guard blocks `git stash`, allows `git status`", "NOT ASSESSED", f"could not run the guard: {e}")

    # 3: rule frontmatter (Antigravity drops rules without a valid trigger)
    rules_dir = os.path.join(ROOT, ".agents", "rules")
    bad = []
    names = sorted(f for f in os.listdir(rules_dir) if f.endswith(".md")) if os.path.isdir(rules_dir) else []
    for name in names:
        with open(os.path.join(rules_dir, name), encoding="utf-8") as f:
            text = f.read().replace("\r\n", "\n")
        m = re.match(r"---\n(.*?)\n---", text, re.S)
        trig = re.search(r"^trigger:\s*(\S+)", m.group(1), re.M) if m else None
        if not trig or trig.group(1) not in VALID_TRIGGERS:
            bad.append(f"{name} (no valid trigger)")
        elif trig.group(1) == "glob" and not re.search(r"^globs?:", m.group(1), re.M):
            bad.append(f"{name} (glob without globs)")
    if not names:
        add(".agents/rules have valid frontmatter", "FAIL", ".agents/rules/ has no rules")
    else:
        add(".agents/rules have valid frontmatter", "FAIL" if bad else "PASS", "; ".join(bad))

    # 4-5: the two layers carry the same skills and agents
    def skill_names(base):
        d = os.path.join(ROOT, base, "skills")
        return {n for n in os.listdir(d) if os.path.isfile(os.path.join(d, n, "SKILL.md"))} if os.path.isdir(d) else set()

    def agent_names(base):
        d = os.path.join(ROOT, base, "agents")
        return {n[:-3] for n in os.listdir(d) if n.endswith(".md")} if os.path.isdir(d) else set()

    for kind, fn in (("skills", skill_names), ("agents", agent_names)):
        c, g = fn(".claude"), fn(".agents")
        if not c or not g:
            add(f"same {kind} in .claude/ and .agents/", "FAIL", f".claude: {len(c)}, .agents: {len(g)}")
            continue
        diff = []
        if c - g:
            diff.append("only in .claude: " + ", ".join(sorted(c - g)))
        if g - c:
            diff.append("only in .agents: " + ", ".join(sorted(g - c)))
        add(f"same {kind} in .claude/ and .agents/ ({len(c)}/{len(g)})", "FAIL" if diff else "PASS", "; ".join(diff))

    # 6: local edits to AGENTS.md survived
    engine = yaml_block_key(read_project_yaml(), "engine", "name")
    try:
        with open(os.path.join(ROOT, "AGENTS.md"), encoding="utf-8") as f:
            agents_md = f.read()
    except OSError:
        agents_md = None
    if agents_md is None:
        add("AGENTS.md names the engine and its reference", "FAIL", "AGENTS.md is missing")
    elif not engine:
        add("AGENTS.md names the engine and its reference", "NOT ASSESSED", "project.yaml has no engine.name")
    else:
        pointer = f"docs/engine-reference/{engine.lower()}/VERSION.md"
        tail = agents_md.split("ENGINE-REFERENCE-IMPORT", 1)[-1]
        missing = [s for s, ok in ((f"**Engine**: {engine}", f"**Engine**: {engine}" in agents_md),
                                   (pointer, pointer in tail)) if not ok]
        add("AGENTS.md names the engine and its reference", "FAIL" if missing else "PASS",
            ("missing: " + ", ".join(missing)) if missing else "")

    # 7: project rules added to .claude/rules are mirrored in .agents/rules
    state = load_state()
    r = state["ccgs"]["remote"]
    code, base, _ = git("merge-base", "HEAD", f"{r}/main")
    if code:
        add("project rules in .claude/rules mirrored in .agents/rules", "NOT ASSESSED",
            f"no merge-base with {r}/main (run status to fetch)")
    else:
        missing = []
        cdir = os.path.join(ROOT, ".claude", "rules")
        for name in sorted(os.listdir(cdir)) if os.path.isdir(cdir) else []:
            if not name.endswith(".md"):
                continue
            with open(os.path.join(cdir, name), encoding="utf-8") as f:
                now = strip_frontmatter(f.read())
            bcode, btext, _ = git_raw("show", f"{base}:.claude/rules/{name}")
            base_lines = {l.strip() for l in strip_frontmatter(btext).splitlines()} if bcode == 0 else set()
            added = [l.strip() for l in now.splitlines() if l.strip() and l.strip() not in base_lines]
            if not added:
                continue
            agp = os.path.join(rules_dir, name)
            if not os.path.exists(agp):
                missing.append(f"{name}: no .agents/rules/{name}")
                continue
            with open(agp, encoding="utf-8") as f:
                ag_lines = {l.strip() for l in strip_frontmatter(f.read()).splitlines()}
            lost = [l for l in added if l.replace(".claude/", ".agents/") not in ag_lines and l not in ag_lines]
            if lost:
                missing.append(f"{name}: {len(lost)} line(s), first: {lost[0][:70]}")
        add("project rules in .claude/rules mirrored in .agents/rules", "FAIL" if missing else "PASS", "; ".join(missing))

    # 8: no conflict markers left in either layer
    code, so, se = git("grep", "-n", "-I", "-E", "^(<<<<<<<|>>>>>>>) ", "--", *AG_PATHSPEC, *CLAUDE_PATHSPEC)
    if code == 1:
        add("no conflict markers in the studio layers", "PASS")
    elif code == 0:
        hits = lines(so)
        add("no conflict markers in the studio layers", "FAIL", f"{len(hits)} marker(s), first: {hits[0][:90]}")
    else:
        add("no conflict markers in the studio layers", "NOT ASSESSED", f"git grep failed: {se}")

    # 9-10: recorded Antigravity commit, and both layers on one release
    a = state["ag_studio"]
    if not commit_exists(a["commit"]):
        add("recorded Antigravity commit is present", "FAIL", f"{a['commit'][:8]} missing (fetch `{a['remote']}`)")
        add("both layers on the same release", "NOT ASSESSED", "recorded Antigravity commit is missing")
    else:
        add("recorded Antigravity commit is present", "PASS", f"{a['version']} ({a['commit'][:8]})")
        claude_v, port_v = framework_version(), framework_version(a["commit"])
        if not claude_v or not port_v:
            add("both layers on the same release", "NOT ASSESSED",
                f"framework.version unreadable (Claude: {claude_v}, Antigravity: {port_v})")
        else:
            add("both layers on the same release", "PASS" if claude_v == port_v else "FAIL",
                f"Claude side {claude_v}, Antigravity layer ports {port_v}")

    width = max(len(i) for i, _, _ in results)
    print("# Studio check\n")
    for item, verdict, detail in results:
        print(f"{verdict:<13} {item:<{width}}" + (f"  - {detail}" if detail else ""))
    verdicts = {v for _, v, _ in results}
    overall = "FAIL" if "FAIL" in verdicts else "NOT ASSESSED" if "NOT ASSESSED" in verdicts else "PASS"
    print(f"\nOverall: {overall}")
    return {"PASS": 0, "FAIL": 1, "NOT ASSESSED": 3}[overall]


def main():
    ap = argparse.ArgumentParser(description=__doc__.splitlines()[0])
    sub = ap.add_subparsers(dest="cmd", required=True)
    sub.add_parser("status")
    m = sub.add_parser("merge-ccgs")
    m.add_argument("--to", required=True, help="tag or commit, e.g. v1.4.0")
    a = sub.add_parser("apply-ag")
    a.add_argument("--to", help="commit or ref (default: <ag remote>/main)")
    r = sub.add_parser("record-ag")
    r.add_argument("--commit", required=True)
    sub.add_parser("check")
    args = ap.parse_args()
    try:
        return {"status": cmd_status, "merge-ccgs": cmd_merge_ccgs, "apply-ag": cmd_apply_ag,
                "record-ag": cmd_record_ag, "check": cmd_check}[args.cmd](args)
    except RuntimeError as e:
        print(f"ERROR: {e}")
        return 2


if __name__ == "__main__":
    sys.stdout.reconfigure(encoding="utf-8")
    sys.exit(main())

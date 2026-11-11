"""Headless /design-build driver: runs a queue of build seeds as fresh `claude -p` sessions, unattended.

Why headless and not subagents: a skill's `model:` pin only applies when the slash command is typed, and a
fresh session keeps the parent's long context out of every build (see the memory note on headless sessions).

Usage (from the repo root):
    python -I tools/headless/run_builds.py --run design/builds/overnight-2026-11-10 \
        [--queue <run>/queue.json] [--until 2026-11-11T09:00] [--parallel 2] [--model sonnet] [--dry-run]
        [--no-simulator]
    python -I tools/headless/run_builds.py --run <run dir> --summary-only

The queue is a JSON list of seeds, re-read before every launch, so seeds can be appended while it runs:
    {"slug": "two-clocks", "kind": "min-max", "seed": "...", "realm": "...", "power": "...",
     "root": "...", "use": "player"}

Per build the session writes, inside <run>/builds/:
    <slug>.md          a player guide (why it works, what to look for, what to stack, what is missing)
    <slug>.sheet.md    the design-build sheet (skill template)
    <slug>.fight.json  the fight input for fight.py (not with --no-simulator)
    <slug>.staging.md, <slug>.ledger.md, <slug>.suggestions.md   its own rows for the run's shared files
It never reads or writes the shared files (staging-catalogue.md, ledger.md, suggestions.md): after each build the
driver merges its own files into them with tools/headless/merge_build_files.py and rewrites staging-index.md, the
short index sessions grep for reuse (2026-11-11: re-reading the 170k-character shared catalogue before every edit
was the largest avoidable cost of the 2026-11-10 run). It never touches GDDs, the real modifier catalogue, the
real content ledger, data or code.

State lives in <run>/_driver/ (state.json, driver.md, one transcript per session as <slug>-try<n>.md). A build that fails is
retried once. A usage-limit message pauses the driver (15 min steps) until --until, then it stops.
When the queue is empty or the deadline passes, a final session writes <run>/RUN-SUMMARY.md.
A temporary project.local.yaml (automation: autonomous) is created if none exists and removed at the end.
"""
import argparse
import concurrent.futures
import datetime
import json
import os
import re
import subprocess
import sys
import threading
import time

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
CLAUDE = os.path.expanduser("~/.local/bin/claude.exe" if os.name == "nt" else "~/.local/bin/claude")
LOCAL = os.path.join(REPO, "project.local.yaml")
SESSION_TIMEOUT = 75 * 60
LIMIT_WAIT = 15 * 60

ALLOWED_BASE = [
    "Read", "Glob", "Grep", "Edit", "Write", "Skill", "TodoWrite",
    "Bash(bash */.claude/skills/design-build/../../hooks/yaml-helper.sh *)",
    "Bash(bash .claude/hooks/yaml-helper.sh *)",
    "Bash(ls *)", "Bash(wc *)", "Bash(grep *)", "Bash(head *)",
]
# The simulator (default): sessions may run fight.py and nothing else in Python. A deny rule would beat this
# allow rule, so Python is not denied by pattern; a headless session cannot prompt, so any Python command not
# on the allow list is refused anyway. --no-simulator denies all Python, as in the 2026-11-10 run.
FIGHT_TOOL = "Bash(python .claude/skills/design-build/scripts/fight.py *)"
DISALLOWED_BASE = ["AskUserQuestion", "Agent", "Bash(git *)", "WebSearch", "WebFetch"]
ALLOWED = ",".join(ALLOWED_BASE + [FIGHT_TOOL])
DISALLOWED = ",".join(DISALLOWED_BASE)

FIGHT_SIM = """   - `{builds}/{slug}.fight.json`: the fight input (references/content-formats.md, Fight input). In Phase 2
     run `python .claude/skills/design-build/scripts/fight.py --selftest`; in Phase 7 run `python
     .claude/skills/design-build/scripts/fight.py {builds}/{slug}.fight.json --matrix` and the `--without` run on
     the identity piece, at the defining realm and one other. That script is the only Python you may run; do not
     write or run any other script, and do not hand-simulate the fight. Report the fight checks from its output,
     and list everything it could not model (its `model_note` and `UNMODELLED` lines) in the sheet."""
FIGHT_NONE = """   - NO combat simulator in this run (driver --no-simulator). Do not write a fight input, do not run or
     write any simulation script, and do not hand-simulate the fight second by second. In Phase 7 run every
     check you can by reading the rules; mark "The fight" and the identity test NOT ASSESSED with the reason
     "no simulator this run". Explain the engine in words and a few key numbers taken straight from the GDD
     formulas. `fight.py --numbers` cannot run either: Grep the GDDs for the numbers you need (about 40 lines
     around each hit), never whole sections."""

SYSTEM = """You are running UNATTENDED; the user cannot answer. AskUserQuestion is
unavailable. The project is in autonomous automation mode for this run (project.local.yaml).

You are running the design-build skill for ONE build: slug `{slug}`. Goal: a build that makes the game
good, a build a real player would chase. It is NOT a test of any Đạo. Kind: {kind}.
Shaping (use these where Phase 3 would ask): realm span: {realm}; power level: {power}; spiritual root:
{root}; use: {use}.

Overrides to the skill, in force for this session:
1. Phase 3 direction: think through the directions as the skill says, then CHOOSE the strongest for this
   kind of build yourself. Record the chosen direction and, in two lines each, the ones you did not pick, in
   the sheet under "Directions considered". Phases 4, 5 and 8 prompts: proceed as if the user chose [A].
2. Outputs go to `{builds}/`, not design/builds/:
   - `{builds}/{slug}.sheet.md`: the skill's design sheet (assets/build-sheet-template.md).
{fight}
   - `{builds}/{slug}.md`: a PLAYER GUIDE, written for a new player, plain language. Sections, in order:
     "# <Build name> (<Hán-Việt>)" then a one-line pitch; "## Why it works" (the engine in plain words, with
     the few key numbers from the formulas); "## What to look for" (in the order a player finds them:
     spiritual root, talents, Đạo and nodes, công pháp, arts, items, enabler; mark each piece "in the game"
     or "not in the game yet (staged: <name>)"); "## The enabling Effects" (each Effect, what it does, why
     the build needs it); "## Modifiers to stack" (a priority list, most important first, with the layer
     each fills and when to stop: caps, falling returns); "## Upgrades to look for" (the player's shopping
     list for improving the build: a table | Piece | Modifier or Effect | What it adds to this build | Where it
     comes from (tree node or cluster, Đạo node, công pháp, item affix, named item, pill, formation) | In the
     game or staged | Priority (core / strong / nice) |, at least 12 rows, both modifiers and Effects, core
     first, including the pieces that turn a working build into a top-end one); "## Realm by realm" (what changes as it climbs);
     "## How it plays" (art order, loadout, the signature moment); "## What beats it" (real enemy types and
     how to adapt); "## Not in the game yet" (every staged piece this build needs); "## Changes the game
     would need" (new systems or changes to existing rules, each naming the GDD and rule; write "None" if
     none). Use English with Hán-Việt for names, e.g. "sect (tông môn)".
3. Do NOT edit design/quick-specs/tree-modifier-catalogue.md, design/builds/content-ledger.md, any file in
   design/gdd/, design/registry/, assets/, src/, project.yaml, or files under design/dao-ways/ (a separate
   task; do not read it either). Do not run git.
4. Missing pieces go to YOUR OWN staging file `{builds}/{slug}.staging.md`: every new modifier, Effect,
   enabler, artifact, talisman, pill, formation, công pháp, art, Đạo facet or notable, or concept this build
   needs that the game does not have. Do NOT read or edit the run's shared files (staging-catalogue.md,
   ledger.md, suggestions.md); the driver merges your files into them after you finish. Before staging a piece,
   look for a fit and reuse it by name: Grep `{index}` (every piece earlier builds staged, one short row each,
   with each section's column headers at the top), then design/quick-specs/tree-modifier-catalogue.md and
   design/builds/content-ledger.md (read in Phase 2), then Grep design/builds/by-root/missing-pieces.md. In
   your staging file, use `## <section>` headings with the section names and columns listed at the top of the
   index; the ID is a short kebab-case name; "Used by" is `{slug}`. List each staged piece you reuse in a
   `## Reused` table: `| ID | Found in |` (Found in: staging, tree catalogue, content ledger or missing
   pieces).
5. System suggestions: if the build needs a new system or a change to an existing rule, write it in the
   guide's last section AND in `{builds}/{slug}.suggestions.md`, one entry each, headed
   `### {slug}: <short title>`, with the bullets Kind, Touches, Proposal, Why the build needs it, Trade-off.
6. Your ledger rows go in `{builds}/{slug}.ledger.md`, with `## Builds`, `## Modifiers`, `## Enablers`,
   `## Other pieces` and `## New concepts` tables in the real content ledger's columns
   (design/builds/content-ledger.md). If your own files exist from an interrupted earlier try, update them.
7. Take every number from `fight.py --numbers` and the data files on this run. Numbers on new pieces are first guesses.
8. Respect the project memory: Modifier = a plain number on a stat (conversions allowed); Effect = anything
   with a rule; Effects are hand-designed and unpriced; sustain is king and fights run 30-60 s; slightly
   overpowered is fine, only macro targets matter. Originality: no names lifted from novels or games.
9. Reading and writing (2026-11-11, cost): follow the skill's Phase 2 "Read each file once" and "What not to
   read" exactly. Never read another build's files or an earlier run. Write each output file whole with one
   Write when its content is ready, then fix it with a few Edits; do not build files line by line.
10. Finish with exactly one line as the last line of your final message:
   BUILD-RESULT: slug={slug} status=<DONE|PARTIAL|FAILED> staged_new=<n> staged_reused=<n> suggestions=<n> checks_fail=<n> checks_na=<n>
"""

SUMMARY = """You are running UNATTENDED; the user is asleep. Write the end-of-run report to `{run}/RUN-SUMMARY.md`.
Read every guide and sheet in `{run}/builds/`, `{run}/staging-catalogue.md`, `{run}/suggestions.md`,
`{run}/ledger.md` and the driver table below. Do not edit anything else, and do not run git.

Contents, plain and short:
1. Synopsis of the run: builds made, by kind, with one line each (name, the engine, power, the build's
   strongest upgrade). {fight_note} Name builds that failed or did not run, with why.
2. All system suggestions, merged where builds asked for the same thing, each with: the GDD and rule it
   touches, the proposal, the builds that need it, the trade-off, and your recommendation. Most important
   (most builds, biggest effect on the game) first.
3. The staging catalogue in brief: counts by type, the pieces most reused, pieces only one build uses.
4. Balance flags: builds far above or below the anchors, cap hits, checks that FAILED or were NOT ASSESSED.
5. Decisions for the user, each with a recommended answer.

Driver table:
{table}
"""

_lock = threading.Lock()


def log(run, msg):
    line = f"[{datetime.datetime.now():%Y-%m-%d %H:%M:%S}] {msg}"
    with _lock:
        print(line, flush=True)
        p = os.path.join(run, "_driver", "driver.md")
        new = not os.path.exists(p)
        with open(p, "a", encoding="utf-8") as f:
            if new:
                f.write("# Build driver log\n\n> One line per event, written by tools/headless/run_builds.py.\n\n")
            f.write("- " + line + "\n")


def load_state(run):
    p = os.path.join(run, "_driver", "state.json")
    if os.path.exists(p):
        with open(p, encoding="utf-8") as f:
            return json.load(f)
    return {"builds": {}}


def save_state(run, state):
    with _lock:
        p = os.path.join(run, "_driver", "state.json")
        with open(p + ".tmp", "w", encoding="utf-8") as f:
            json.dump(state, f, indent=1, ensure_ascii=False)
        os.replace(p + ".tmp", p)


def load_queue(path):
    with open(path, encoding="utf-8") as f:
        return json.load(f)


def run_session(run, prompt, system, tag, model):
    out_path = os.path.join(run, "_driver", f"{tag}.md")
    cmd = [CLAUDE, "-p", prompt, "--model", model, "--permission-mode", "acceptEdits",
           "--allowedTools", ALLOWED, "--disallowedTools", DISALLOWED,
           "--append-system-prompt", system, "--output-format", "text"]
    try:
        r = subprocess.run(cmd, cwd=REPO, capture_output=True, text=True, encoding="utf-8",
                           errors="replace", timeout=SESSION_TIMEOUT)
        text = (r.stdout or "") + ("\n[stderr]\n" + r.stderr if r.stderr else "")
        code = r.returncode
    except subprocess.TimeoutExpired as e:
        text = (e.stdout if isinstance(e.stdout, str) else "") + "\n[driver] TIMEOUT"
        code = -1
    body, _, err = text.partition("\n[stderr]\n")
    md = f"# Session transcript: {tag}\n\n> Final message of one headless `claude -p` session.\n\n{body.strip()}\n"
    if err.strip():
        md += f"\n## stderr\n\n```text\n{err.strip()}\n```\n"
    with open(out_path, "w", encoding="utf-8") as f:
        f.write(md)
    return code, text


RESULT = re.compile(r"BUILD-RESULT:\s*slug=(\S+)\s+status=(\w+)\s+staged_new=(\d+)\s+staged_reused=(\d+)\s+"
                    r"suggestions=(\d+)\s+checks_fail=(\d+)\s+checks_na=(\d+)")


def is_limit(text):
    t = text.lower()
    # "You've hit your 5-hour limit · resets 4:50am" is the subscription message; it was missed on 2026-11-11.
    return any(k in t for k in ("usage limit", "rate limit", "limit reached", "resets at", "overloaded")) or (
        "hit your" in t and "limit" in t)


def merge_files(run, slug):
    """Merges one build's own files (or all, slug None) into the shared files and rewrites staging-index.md."""
    cmd = [sys.executable, "-I", os.path.join(REPO, "tools", "headless", "merge_build_files.py"), "--run", run]
    cmd += ["--slug", slug] if slug else ["--all"]
    r = subprocess.run(cmd, cwd=REPO, capture_output=True, text=True, encoding="utf-8", errors="replace")
    out = (r.stdout + r.stderr).strip()
    unplaced = [l for l in out.splitlines() if l.startswith("UNPLACED")]
    log(run, "merge %s: exit %d, %d lines%s" % (slug or "all", r.returncode, len(out.splitlines()),
                                                ("; " + "; ".join(unplaced)) if unplaced else ""))


def fight_block(args, builds, slug):
    return (FIGHT_NONE if args.no_simulator else FIGHT_SIM).format(builds=builds, slug=slug)


def build_one(args, seed, attempt):
    run = args.run
    slug = seed["slug"]
    builds = f"{run}/builds"
    system = SYSTEM.format(slug=slug, kind=seed.get("kind", "player build"), realm=seed.get("realm", "your choice"),
                           power=seed.get("power", "your choice"), root=seed.get("root", "your choice"),
                           use=seed.get("use", "player"), builds=builds, staging=f"{run}/staging-catalogue.md",
                           suggestions=f"{run}/suggestions.md", ledger=f"{run}/ledger.md",
                           index=f"{run}/staging-index.md", fight=fight_block(args, builds, slug))
    prompt = f"/design-build {seed['seed']}"
    tag = f"{slug}-try{attempt}"
    log(run, f"start {tag}")
    t0 = time.time()
    code, text = run_session(run, prompt, system, tag, args.model)
    mins = (time.time() - t0) / 60
    m = RESULT.findall(text)
    guide = os.path.exists(os.path.join(REPO, builds, f"{slug}.md"))
    if m:
        _, status, sn, sr, sg, cf, cn = m[-1]
        res = {"status": status, "staged_new": int(sn), "staged_reused": int(sr), "suggestions": int(sg),
               "checks_fail": int(cf), "checks_na": int(cn)}
    else:
        res = {"status": "LIMIT" if is_limit(text) else "NO-RESULT"}
    res.update({"exit": code, "minutes": round(mins, 1), "guide": guide, "attempt": attempt})
    log(run, f"end {tag}: {res}")
    return slug, res


def deadline_passed(args):
    return args.until is not None and datetime.datetime.now() >= args.until


def table(state):
    rows = ["| Build | Status | Guide | New staged | Reused | Suggestions | Checks FAIL | NOT ASSESSED | Min | Tries |",
            "|---|---|---|---|---|---|---|---|---|---|"]
    for slug, r in state["builds"].items():
        rows.append(f"| {slug} | {r.get('status')} | {'yes' if r.get('guide') else 'no'} | {r.get('staged_new', '-')} | "
                    f"{r.get('staged_reused', '-')} | {r.get('suggestions', '-')} | {r.get('checks_fail', '-')} | "
                    f"{r.get('checks_na', '-')} | {r.get('minutes', '-')} | {r.get('attempt', '-')} |")
    return "\n".join(rows)


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--run", required=True, help="run folder, relative to the repo root")
    ap.add_argument("--queue", help="queue JSON (default <run>/queue.json)")
    ap.add_argument("--until", help="stop launching after this local time, ISO format")
    ap.add_argument("--parallel", type=int, default=1)
    ap.add_argument("--model", default="sonnet",
                    help="sonnet by default (2026-11-11, cost); the skill's own model pin does not apply here")
    ap.add_argument("--dry-run", action="store_true")
    ap.add_argument("--summary-only", action="store_true")
    ap.add_argument("--no-summary", action="store_true")
    ap.add_argument("--no-simulator", action="store_true",
                    help="no fight.py: sessions mark the fight checks NOT ASSESSED (the 2026-11-10 run's setting)")
    args = ap.parse_args()
    global ALLOWED, DISALLOWED
    if args.no_simulator:
        ALLOWED = ",".join(ALLOWED_BASE)
        DISALLOWED = ",".join(DISALLOWED_BASE + ["Bash(python *)"])
    args.run = args.run.replace("\\", "/").rstrip("/")
    args.until = datetime.datetime.fromisoformat(args.until) if args.until else None
    queue_path = args.queue or os.path.join(REPO, args.run, "queue.json")
    os.makedirs(os.path.join(REPO, args.run, "_driver"), exist_ok=True)
    os.makedirs(os.path.join(REPO, args.run, "builds"), exist_ok=True)
    os.chdir(REPO)
    state = load_state(args.run)
    if not args.dry_run:
        merge_files(args.run, None)  # fold in anything an earlier interrupted run left, and write the index

    if args.dry_run:
        seeds = load_queue(queue_path)
        todo = [s["slug"] for s in seeds if state["builds"].get(s["slug"], {}).get("status") not in ("DONE", "PARTIAL")]
        print(f"claude: {CLAUDE} exists={os.path.exists(CLAUDE)}\nqueue: {len(seeds)} seeds, {len(todo)} to run: {todo}")
        s = seeds[0]
        print(SYSTEM.format(slug=s["slug"], kind=s.get("kind"), realm=s.get("realm"), power=s.get("power"),
                            root=s.get("root"), use=s.get("use"), builds=f"{args.run}/builds",
                            staging=f"{args.run}/staging-catalogue.md", suggestions=f"{args.run}/suggestions.md",
                            ledger=f"{args.run}/ledger.md", index=f"{args.run}/staging-index.md",
                            fight=fight_block(args, f"{args.run}/builds", s["slug"]))[:6000])
        print(f"\nallowedTools: {ALLOWED}\ndisallowedTools: {DISALLOWED}")
        return

    created_local = False
    if not os.path.exists(LOCAL):
        with open(LOCAL, "w", encoding="utf-8") as f:
            f.write("# TEMPORARY override for an unattended headless run; removed by tools/headless/run_builds.py.\n"
                    "modes:\n  automation: autonomous\n")
        created_local = True
        log(args.run, "created project.local.yaml (automation: autonomous)")
    try:
        if not args.summary_only:
            running = {}
            paused_until = 0.0
            with concurrent.futures.ThreadPoolExecutor(max_workers=args.parallel) as pool:
                while True:
                    for fut in [f for f in running if f.done()]:
                        slug, res = fut.result()
                        del running[fut]
                        state["builds"][slug] = res
                        save_state(args.run, state)
                        merge_files(args.run, slug)
                        if res["status"] == "LIMIT":
                            paused_until = time.time() + LIMIT_WAIT
                            log(args.run, f"usage limit; pausing launches for {LIMIT_WAIT // 60} min")
                    if deadline_passed(args):
                        if not running:
                            log(args.run, "deadline passed; stopping")
                            break
                        time.sleep(20)
                        continue
                    seeds = load_queue(queue_path)
                    busy = set(running.values())

                    def pending(s):
                        r = state["builds"].get(s["slug"])
                        if s["slug"] in busy:
                            return False
                        if r is None:
                            return True
                        if r["status"] == "LIMIT":
                            return True
                        return r["status"] not in ("DONE", "PARTIAL") and r.get("attempt", 1) < 2

                    todo = [s for s in seeds if pending(s)]
                    if not todo and not running:
                        log(args.run, "queue empty")
                        break
                    if todo and len(running) < args.parallel and time.time() >= paused_until:
                        s = todo[0]
                        prev = state["builds"].get(s["slug"])
                        attempt = 1 if prev is None else (prev.get("attempt", 1) if prev["status"] == "LIMIT" else prev.get("attempt", 1) + 1)
                        fut = pool.submit(build_one, args, s, attempt)
                        running[fut] = s["slug"]
                        time.sleep(30)  # stagger launches so sessions do not open shared files at once
                        continue
                    time.sleep(20)
        if not args.no_summary:
            log(args.run, "writing RUN-SUMMARY.md")
            code, _ = run_session(args.run, "Write the end-of-run report as instructed.",
                                  SUMMARY.format(run=args.run, table=table(state), fight_note=(
                                      "Note that the fight checks were not assessed (driver --no-simulator)."
                                      if args.no_simulator else "Give each build's fight results from its sheet "
                                      "(fight.py), and what the simulator could not model.")),
                                  "summary", args.model)
            log(args.run, f"summary session exit {code}")
    finally:
        with open(os.path.join(args.run, "_driver", "table.md"), "w", encoding="utf-8") as f:
            f.write(table(state) + "\n")
        if created_local and os.path.exists(LOCAL):
            os.remove(LOCAL)
            log(args.run, "removed project.local.yaml")
        log(args.run, "driver done")


if __name__ == "__main__":
    sys.exit(main())

"""Generic headless job runner: runs a JSON list of prompts as fresh `claude -p` sessions, one after another.

Usage (from the repo root):
    python -I tools/headless/run_jobs.py <jobs.json> <log_dir> [--model sonnet] [--until 2026-11-11T09:00]

jobs.json: [{"id": "dao-review-01", "prompt": "...", "system": "...", "allowed": "Read,Glob,Grep,Write(...)",
             "expect": "path/that/must/exist/after"}]
Each job's transcript goes to <log_dir>/<id>-try<n>.md and a line to <log_dir>/jobs.md. A job whose `expect` file is
missing after it ends is logged as NO-OUTPUT and retried once. Usage-limit messages pause 15 minutes and retry.
For /design-build runs use run_builds.py, which knows the build outputs.
"""
import datetime
import json
import os
import subprocess
import sys
import time

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
CLAUDE = os.path.expanduser("~/.local/bin/claude.exe" if os.name == "nt" else "~/.local/bin/claude")


def log(d, msg):
    line = f"[{datetime.datetime.now():%Y-%m-%d %H:%M:%S}] {msg}"
    print(line, flush=True)
    p = os.path.join(d, "jobs.md")
    new = not os.path.exists(p)
    with open(p, "a", encoding="utf-8") as f:
        if new:
            f.write("# Job runner log\n\n> One line per event, written by tools/headless/run_jobs.py.\n\n")
        f.write("- " + line + "\n")


def main():
    jobs_path, log_dir = sys.argv[1], sys.argv[2]
    model = sys.argv[sys.argv.index("--model") + 1] if "--model" in sys.argv else "sonnet"
    until = datetime.datetime.fromisoformat(sys.argv[sys.argv.index("--until") + 1]) if "--until" in sys.argv else None
    os.makedirs(log_dir, exist_ok=True)
    jobs = json.load(open(jobs_path, encoding="utf-8"))
    for job in jobs:
        for attempt in (1, 2, 3):
            if until and datetime.datetime.now() >= until:
                log(log_dir, "deadline passed; stopping")
                return
            exp = job.get("expect")
            if exp and os.path.exists(os.path.join(REPO, exp)):
                log(log_dir, f"{job['id']}: output exists, skipping")
                break
            cmd = [CLAUDE, "-p", job["prompt"], "--model", job.get("model", model), "--permission-mode", "acceptEdits",
                   "--allowedTools", job.get("allowed", "Read,Glob,Grep"),
                   "--disallowedTools", "AskUserQuestion,Agent,Bash(git *)",
                   "--append-system-prompt", job.get("system", ""), "--output-format", "text"]
            log(log_dir, f"start {job['id']} try {attempt}")
            try:
                r = subprocess.run(cmd, cwd=REPO, capture_output=True, text=True, encoding="utf-8", errors="replace",
                                   timeout=60 * 60)
                text, code = (r.stdout or "") + ("\n[stderr]\n" + r.stderr if r.stderr else ""), r.returncode
            except subprocess.TimeoutExpired as e:
                text, code = (e.stdout if isinstance(e.stdout, str) else "") + "\n[runner] TIMEOUT", -1
            body, _, err = text.partition("\n[stderr]\n")
            md = f"# Job transcript: {job['id']} (try {attempt})\n\n{body.strip()}\n"
            if err.strip():
                md += f"\n## stderr\n\n```text\n{err.strip()}\n```\n"
            with open(os.path.join(log_dir, f"{job['id']}-try{attempt}.md"), "w", encoding="utf-8") as f:
                f.write(md)
            ok = (not exp) or os.path.exists(os.path.join(REPO, exp))
            log(log_dir, f"end {job['id']} try {attempt}: exit {code}, output {'yes' if ok else 'NO-OUTPUT'}")
            if ok:
                break
            t = text.lower()
            if any(k in t for k in ("usage limit", "rate limit", "limit reached", "resets at")) or ("hit your" in t and "limit" in t):
                log(log_dir, "usage limit; waiting 15 min")
                time.sleep(15 * 60)


if __name__ == "__main__":
    sys.exit(main())

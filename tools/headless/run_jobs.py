"""Generic headless job runner: runs a JSON list of prompts as fresh `claude -p` sessions.

Usage (from the repo root):
    python -I tools/headless/run_jobs.py <jobs.json> <log_dir> [--model sonnet] [--until 2026-11-11T09:00]
                                         [--lanes N] [--limit-waits K]

jobs.json: [{"id": "dao-review-01", "prompt": "...", "system": "...", "allowed": "Read,Glob,Grep,Write(...)",
             "expect": "path/that/must/exist/after"}]
Optional job fields (2026-11-26, world-depth Stage 6's parallel run):
- "model": the job's model (else --model);
- "timeout_min": the job's time limit (default 60);
- "env": extra environment variables for the session (e.g. {"DEPTH_STAGE": "design/stage6-staging/<owner>"});
- "barrier": true waits for every running job, then runs this one alone (a serial step between parallel waves);
- "before": a command (argv list) run once before the job's first try (a snapshot); a non-zero exit HALTS the run;
- "after": a command (argv list) the runner runs from the repo root once the job has its output. A non-zero exit
  HALTS the run: no new job starts, running ones finish, and <log_dir>/HALT names the reason.

Each job's transcript goes to <log_dir>/<id>-try<n>.md and a line to <log_dir>/jobs.md. A job whose `expect` file
exists is skipped (a rerun resumes). One whose `expect` is missing after it ends is retried, up to 3 tries. With
--lanes N (default 1), up to N non-barrier jobs run at once. A usage-limit message waits 30 minutes and retries the job
(at most --limit-waits times, default 10, then the run HALTS); --until stops starting jobs after that time.
"""
import concurrent.futures
import datetime
import json
import os
import subprocess
import sys
import threading
import time

REPO = os.path.abspath(os.path.join(os.path.dirname(__file__), "..", ".."))
CLAUDE = os.path.expanduser("~/.local/bin/claude.exe" if os.name == "nt" else "~/.local/bin/claude")
LIMIT_WORDS = ("usage limit", "rate limit", "limit reached", "resets at")
_lock = threading.Lock()


def log(d, msg):
    line = f"[{datetime.datetime.now():%Y-%m-%d %H:%M:%S}] {msg}"
    with _lock:
        print(line, flush=True)
        p = os.path.join(d, "jobs.md")
        new = not os.path.exists(p)
        with open(p, "a", encoding="utf-8") as f:
            if new:
                f.write("# Job runner log\n\n> One line per event, written by tools/headless/run_jobs.py.\n\n")
            f.write("- " + line + "\n")


def halt(log_dir, why):
    with _lock:
        with open(os.path.join(log_dir, "HALT"), "a", encoding="utf-8") as f:
            f.write(f"{datetime.datetime.now():%Y-%m-%d %H:%M:%S} {why}\n")
    log(log_dir, "HALT: " + why)


def halted(log_dir):
    return os.path.exists(os.path.join(log_dir, "HALT"))


def run_job(job, log_dir, model, until, limit_waits):
    """One job, with retries; returns True when it ended with its output (and its after-command passed)."""
    waits = 0
    attempt = 0
    exp0 = job.get("expect")
    if job.get("before") and not (exp0 and os.path.exists(os.path.join(REPO, exp0))):
        b = subprocess.run(job["before"], cwd=REPO, capture_output=True, text=True, encoding="utf-8", errors="replace")
        log(log_dir, f"before {job['id']}: exit {b.returncode} {b.stdout.strip()[-120:]}")
        if b.returncode != 0:
            halt(log_dir, f"{job['id']}: before-command failed: {b.stdout.strip()[-200:]} {b.stderr.strip()[-200:]}")
            return False
    while attempt < 3:
        attempt += 1
        if halted(log_dir):
            return False
        if until and datetime.datetime.now() >= until:
            log(log_dir, f"{job['id']}: deadline passed; not started")
            return False
        exp = job.get("expect")
        if exp and os.path.exists(os.path.join(REPO, exp)):
            log(log_dir, f"{job['id']}: output exists, skipping")
            return True
        cmd = [CLAUDE, "-p", job["prompt"], "--model", job.get("model", model), "--permission-mode", "acceptEdits",
               "--allowedTools", job.get("allowed", "Read,Glob,Grep"),
               "--disallowedTools", "AskUserQuestion,Agent,Bash(git *)",
               "--append-system-prompt", job.get("system", ""), "--output-format", "text"]
        env = dict(os.environ)
        env.update({k: str(v) for k, v in job.get("env", {}).items()})
        log(log_dir, f"start {job['id']} try {attempt}")
        try:
            r = subprocess.run(cmd, cwd=REPO, capture_output=True, text=True, encoding="utf-8", errors="replace",
                               timeout=60 * int(job.get("timeout_min", 60)), env=env)
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
            after = job.get("after")
            if after:
                a = subprocess.run(after, cwd=REPO, capture_output=True, text=True, encoding="utf-8", errors="replace")
                with open(os.path.join(log_dir, f"{job['id']}-after.md"), "w", encoding="utf-8") as f:
                    f.write(f"# After: {job['id']}\n\n`{' '.join(after)}` exit {a.returncode}\n\n```text\n{a.stdout}\n{a.stderr}\n```\n")
                log(log_dir, f"after {job['id']}: exit {a.returncode}")
                if a.returncode != 0:
                    halt(log_dir, f"{job['id']}: after-command failed (see {job['id']}-after.md)")
                    return False
            return True
        t = text.lower()
        if any(k in t for k in LIMIT_WORDS) or ("hit your" in t and "limit" in t):
            waits += 1
            if waits > limit_waits:
                halt(log_dir, f"{job['id']}: usage limit persists after {limit_waits} waits")
                return False
            log(log_dir, f"{job['id']}: usage limit; waiting 30 min ({waits}/{limit_waits})")
            time.sleep(30 * 60)
            attempt -= 1   # a limit is not a failed try
    return False


def main():
    jobs_path, log_dir = sys.argv[1], sys.argv[2]
    arg = lambda k, d=None: sys.argv[sys.argv.index(k) + 1] if k in sys.argv else d
    model = arg("--model", "sonnet")
    until = datetime.datetime.fromisoformat(arg("--until")) if arg("--until") else None
    lanes = int(arg("--lanes", "1"))
    limit_waits = int(arg("--limit-waits", "10"))
    os.makedirs(log_dir, exist_ok=True)
    jobs = json.load(open(jobs_path, encoding="utf-8"))
    pool = concurrent.futures.ThreadPoolExecutor(max_workers=max(1, lanes))
    running = []
    for job in jobs:
        if halted(log_dir):
            break
        if job.get("barrier"):
            concurrent.futures.wait(running)
            running = []
            if halted(log_dir):
                break
            run_job(job, log_dir, model, until, limit_waits)
            continue
        while len([f for f in running if not f.done()]) >= max(1, lanes):
            time.sleep(5)
        running = [f for f in running if not f.done()]
        running.append(pool.submit(run_job, job, log_dir, model, until, limit_waits))
    concurrent.futures.wait(running)
    pool.shutdown()
    log(log_dir, "run ended" + (" (HALTED)" if halted(log_dir) else ""))
    return 1 if halted(log_dir) else 0


if __name__ == "__main__":
    sys.exit(main())

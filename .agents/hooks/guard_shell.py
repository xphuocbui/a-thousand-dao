"""Antigravity PreToolUse hook: hard-block destructive shell commands.

Mirrors the deny list in .claude/settings.json for Antigravity sessions:
git stash, git reset --hard, git clean -f, git push --force / -f / +refspec,
rm -rf, Remove-Item -Recurse, rmdir /s.

Reads the hook payload (JSON) on stdin, writes {"decision": ...} on stdout.
"allow" hands the call on to the normal permission policy (it does not
auto-approve). Quoted text is blanked first, so a commit message that
mentions "git stash" is not blocked. A guard against accidents, not against
a determined caller: a command hidden inside `bash -c "..."` is not seen.
Fails open (allow) if the payload cannot be read.
"""
import json
import re
import sys

QUOTED = re.compile(r"@'.*?'@|@\".*?\"@|'[^']*'|\"[^\"]*\"", re.S)
SPLIT = re.compile(r"&&|\|\||[;&|\n]")
GIT_OPTS_WITH_VALUE = {"-C", "-c", "--git-dir", "--work-tree", "--namespace"}
PS_REMOVE = {"remove-item", "ri", "rm", "rmdir", "rd", "del", "erase"}


def _git_reason(args):
    i = 0
    while i < len(args) and args[i].startswith("-"):
        i += 2 if args[i] in GIT_OPTS_WITH_VALUE else 1
    if i >= len(args):
        return None
    sub, rest = args[i].lower(), args[i + 1:]
    if sub == "stash":
        return "git stash"
    if sub == "reset" and "--hard" in rest:
        return "git reset --hard"
    if sub == "clean" and any(
        a == "--force" or (re.fullmatch(r"-[a-zA-Z]+", a) and "f" in a) for a in rest
    ):
        return "git clean -f"
    if sub == "push" and any(
        a.startswith("--force") or a.startswith("+")
        or (re.fullmatch(r"-[a-zA-Z]+", a) and "f" in a)
        for a in rest
    ):
        return "git push --force"
    return None


def _segment_reason(tokens):
    while tokens and tokens[0] in ("&", "sudo", "command", "exec"):
        tokens = tokens[1:]
    if not tokens:
        return None
    head = tokens[0].lower().rsplit("/", 1)[-1].rsplit("\\", 1)[-1]
    if head in ("git", "git.exe"):
        return _git_reason(tokens[1:])
    args = tokens[1:]
    low = [a.lower() for a in args]
    if head == "rm":
        short = "".join(a[1:] for a in args if re.fullmatch(r"-[a-zA-Z]+", a))
        if (("r" in short.lower()) and "f" in short) or (
            "--recursive" in low and "--force" in low
        ) or ("--recursive" in low and "f" in short) or ("--force" in low and "r" in short.lower()):
            return "rm -rf"
    if head in PS_REMOVE:
        if any(re.fullmatch(r"-r(e(c(u(r(s(e)?)?)?)?)?)?", a) for a in low):
            return "Remove-Item -Recurse"
        if head in ("rmdir", "rd", "del", "erase") and "/s" in low:
            return head + " /s"
    return None


def check(command):
    blanked = QUOTED.sub(" Q ", command)
    for segment in SPLIT.split(blanked):
        reason = _segment_reason(segment.split())
        if reason:
            return reason
    return None


def main():
    try:
        payload = json.load(sys.stdin)
        call = payload.get("toolCall") or {}
        command = (call.get("args") or {}).get("CommandLine") or ""
        reason = check(command) if call.get("name") == "run_command" else None
    except Exception:  # unreadable payload: do not break every command
        reason = None
    if reason:
        out = {
            "decision": "deny",
            "reason": f"Blocked by .agents/hooks.json: `{reason}` is never allowed in this "
            "repo (shared checkout; see GEMINI.md). Find a non-destructive way or ask the user.",
        }
    else:
        out = {"decision": "allow"}
    sys.stdout.write(json.dumps(out))


if __name__ == "__main__":
    main()

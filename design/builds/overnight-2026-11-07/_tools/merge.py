#!/usr/bin/env python3
"""Rebuilds the campaign's shared files from the per-build summaries.

Observations only: it merges, runs the calculator, and lists what looks wrong.
It writes content-ledger.md, index.md and _tools/health.txt in the campaign
folder. Run from the repo root: python design/builds/overnight-2026-11-07/_tools/merge.py
"""
import collections
import difflib
import glob
import json
import os
import re
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.dirname(HERE)
CALC = os.path.join(HERE, "fight_x.py")


def run(args):
    r = subprocess.run([sys.executable, CALC] + args, capture_output=True, text=True, encoding="utf-8")
    return r.stdout


def result_lines(text):
    return [l.split("\t") for l in text.splitlines() if l.startswith("result\t")]


def summary_of(slug, piece):
    path = os.path.join(ROOT, "sheets", slug + ".fight.json")
    if not os.path.exists(path):
        return {"problem": "no fight file"}
    out = run([path, "--matrix"])
    res = result_lines(out)
    if len(res) != 6:
        return {"problem": "calculator gave %d results: %s" % (len(res), out[-160:].replace("\n", " "))}
    info = {"typical": [], "over_lint": out.count("\tOVER"),
            "unmodelled": out.count("UNMODELLED\t"), "drift": out.count("CONSTANT_DRIFT")}
    name = piece.get("slug")
    build_name = json.load(open(path, encoding="utf-8")).get("name", name)
    for row in res[:3]:
        if row[1] == "stalemate":
            info["typical"].append("S")
        elif row[1] == "draw":
            info["typical"].append("D")
        elif "flight" in row[1] or "fled" in row[1]:
            info["typical"].append("F")
        else:
            info["typical"].append("W" if row[3] == "winner=" + str(build_name) else "L")
    info["mixed"] = []
    os.makedirs(os.path.join(ROOT, "scratch", "_merge"), exist_ok=True)
    build = json.load(open(path, encoding="utf-8"))
    mixed = json.load(open(os.path.join(HERE, "mixed-enemy.json"), encoding="utf-8"))
    mixed.pop("_doc", None)
    build["enemy_overrides"] = mixed
    build.pop("enemy", None)
    tmp = os.path.join(ROOT, "scratch", "_merge", slug + ".json")
    json.dump(build, open(tmp, "w", encoding="utf-8"))
    for gap in ("0", "1"):
        rows = result_lines(run([tmp, "--gap", gap]))
        if not rows:
            info["mixed"].append("?")
        elif rows[0][1] == "stalemate":
            info["mixed"].append("S")
        elif rows[0][1] == "draw":
            info["mixed"].append("D")
        elif "flight" in rows[0][1] or "fled" in rows[0][1]:
            info["mixed"].append("F")
        else:
            info["mixed"].append("W" if rows[0][3] == "winner=" + str(build_name) else "L")
    ident = piece.get("identity_id")
    if ident:
        base = run([path, "--gap", "0"])
        alt = run([path, "--gap", "0", "--without", ident])
        base1 = run([path, "--gap", "1"])
        alt1 = run([path, "--gap", "1", "--without", ident])
        if "WITHOUT_NOT_FOUND" in alt:
            info["identity"] = "id not found"
        else:
            def key(t):
                return [l for l in t.splitlines() if l.startswith(("result\t", "end_state\t"))]
            same = key(base) == key(alt) and key(base1) == key(alt1)
            info["identity"] = "NO EFFECT" if same else "changes the fight"
    else:
        info["identity"] = "unmodelled"
    return info


def main():
    if len(sys.argv) > 1:
        print("merge.py takes no arguments. Only the orchestrator runs it, between waves.")
        return
    sheets = sorted(os.path.basename(p)[:-3] for p in glob.glob(os.path.join(ROOT, "sheets", "*.md")))
    pieces = {}
    health = []
    for p in sorted(glob.glob(os.path.join(ROOT, "pieces", "*.json"))):
        slug = os.path.basename(p)[:-5]
        try:
            pieces[slug] = json.load(open(p, encoding="utf-8"))
        except ValueError as e:
            health.append("BAD_JSON\t%s\t%s" % (slug, e))
    for s in sheets:
        if s not in pieces:
            health.append("NO_PIECES\t%s" % s)
    for s in pieces:
        if s not in sheets:
            health.append("NO_SHEET\t%s" % s)

    selftest = run(["--selftest"]).strip().splitlines()[-1:]
    health.append("calculator\t%s" % (selftest[0] if selftest else "did not run"))

    rows, kinds, forms, channels, enablers = [], collections.Counter(), collections.Counter(), collections.Counter(), collections.Counter()
    all_new = []
    used = collections.Counter()
    for slug, d in sorted(pieces.items()):
        info = summary_of(slug, d)
        if "problem" in info:
            health.append("CALC\t%s\t%s" % (slug, info["problem"]))
        else:
            if info["over_lint"]:
                health.append("ART_OVER_LINT\t%s\t%d" % (slug, info["over_lint"]))
            if info["identity"] in ("NO EFFECT", "id not found"):
                health.append("IDENTITY\t%s\t%s" % (slug, info["identity"]))
            if info["drift"]:
                health.append("DRIFT\t%s" % slug)
        channels[d.get("channel", "?")] += 1
        enablers[d.get("enabler_kind") or "none"] += 1
        for r in d.get("reused", []):
            used[r] += 1
        for n in d.get("new", []):
            kinds[n.get("type", "?")] += 1
            if n.get("type") == "modifier":
                forms[n.get("form", "?")] += 1
            all_new.append((n.get("name", "?"), n, slug))
        rows.append((slug, d, info))

    # near duplicates among new pieces of the same type
    by_type = collections.defaultdict(list)
    for name, n, slug in all_new:
        by_type[n.get("type")].append((name, slug))
    for t, items in by_type.items():
        for i, (a, sa) in enumerate(items):
            for b, sb in items[i + 1:]:
                if sa != sb and difflib.SequenceMatcher(None, a.lower(), b.lower()).ratio() > 0.86:
                    health.append("NEAR_DUPLICATE\t%s\t%s (%s) / %s (%s)" % (t, a, sa, b, sb))

    with open(os.path.join(ROOT, "index.md"), "w", encoding="utf-8", newline="\n") as f:
        f.write("# Build Index\n\nGenerated by `_tools/merge.py`. W, L, S, D and F (win, loss, stalemate, draw, fled). `vs typical` is the fixture enemy at the same realm, one up and two up. `vs mixed` is the conserving enemy (`_tools/mixed-enemy.json`) at the same realm and one up, which is the harder and fairer test.\n\n")
        f.write("| Build | Pitch | Channel | Enabler | Identity | Power | vs typical | vs mixed | Identity test | Rule asks |\n|---|---|---|---|---|---|---|---|---|---|\n")
        for slug, d, info in rows:
            typ = "".join(info.get("typical", [])) or "?"
            fit = d.get("fit", {})
            f.write("| [%s (%s)](sheets/%s.md) | %s | %s | %s | %s | %s | %s | %s | %s | %s |\n" % (
                d.get("name", slug), d.get("han_viet", ""), slug, str(d.get("pitch", "")).replace("|", "/"),
                d.get("channel", ""), d.get("enabler") or "none", d.get("identity_piece", ""),
                d.get("power", ""), typ, "".join(info.get("mixed", [])) or "?",
                info.get("identity", info.get("problem", "?")), fit.get("needs_rule", "?")))

    with open(os.path.join(ROOT, "content-ledger.md"), "w", encoding="utf-8", newline="\n") as f:
        f.write("# Overnight Content Ledger\n\nGenerated by `_tools/merge.py` from `pieces/`. Proposals only. Separate from the main ledger on purpose.\n\n")
        order = ["enabler", "modifier", "keystone", "notable", "acupoint", "cluster", "dao", "dao_branch", "root",
                 "technique", "art", "ward", "artifact", "talisman", "pill", "formation", "beast", "concept"]
        seen = set(order)
        for t in order + sorted(k for k in by_type if k not in seen):
            items = [(n, s) for name, n, s in all_new if n.get("type") == t]
            if not items:
                continue
            f.write("## %s (%d)\n\n| Name | Effect | Form | Channel | Layer | Fit | From | Second home | Reused by |\n|---|---|---|---|---|---|---|---|---|\n" % (t, len(items)))
            for n, s in sorted(items, key=lambda v: v[0].get("name", "")):
                nm = n.get("name", "?")
                by = [k for k, d in pieces.items() if nm in d.get("reused", [])]
                f.write("| %s (%s) | %s | %s | %s | %s | %s | %s | %s | %s |\n" % (
                    nm, n.get("han_viet", ""), str(n.get("effect", "")).replace("|", "/").replace("\n", " "),
                    n.get("form", ""), n.get("channel", ""), n.get("layer", ""), n.get("fit", ""), s,
                    n.get("second_home", ""), ", ".join(by)))
            f.write("\n")

    known = {n for n, _, _ in all_new}
    for r in used:
        if r not in known and r not in ("Bare Vessel", "Spillover", "On the Beat", "Sustained Note", "Rot Deepens",
                                        "Corpse-Wax Coating", "Tolled Seal", "Ringing Ground"):
            health.append("REUSE_OF_UNKNOWN\t%s" % r)
    health.append("dao_trees\t%d" % len(glob.glob(os.path.join(ROOT, "daos", "*.md"))))
    with open(os.path.join(HERE, "health.txt"), "w", encoding="utf-8", newline="\n") as f:
        f.write("builds\t%d\nchannels\t%s\nenabler_kinds\t%s\nnew_pieces\t%s\nmodifier_forms\t%s\nmost_reused\t%s\n" % (
            len(pieces), dict(channels), dict(enablers), dict(kinds), dict(forms), used.most_common(12)))
        f.write("\n".join(health) + "\n")
    print(open(os.path.join(HERE, "health.txt"), encoding="utf-8").read())


if __name__ == "__main__":
    main()

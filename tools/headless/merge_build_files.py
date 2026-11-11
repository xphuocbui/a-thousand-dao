"""merge_build_files.py: folds one build session's own files into a run's shared files, and writes the index.

Each headless /design-build session writes only its own files (cheap: it never reads the large shared ones):
    <run>/builds/<slug>.staging.md      new pieces, in the staging catalogue's sections and columns, plus a
                                        "## Reused" table (| ID | Found in |) of staged pieces it reuses
    <run>/builds/<slug>.ledger.md       its ledger rows, in the run ledger's sections and columns
    <run>/builds/<slug>.suggestions.md  its system suggestions, one "### <slug>: <title>" entry each
This script, run by tools/headless/run_builds.py after each build (or by hand), merges them:
    - a staging or ledger row whose ID is new is appended to its section; a row whose ID already exists only
      adds the slug to that row's "Used by" (rows are never rewritten)
    - a "Reused" ID adds the slug to that staged row's "Used by"
    - a suggestion whose heading is not in suggestions.md yet is appended
and then rewrites <run>/staging-index.md: every staged piece as one short row (ID, name, fit, used by), with
each section's column headers, which is what sessions grep for reuse.

It is idempotent: merging the same build twice changes nothing. It prints what it did and every row it could
not place (an unknown section, a row with no ID), so nothing is dropped silently.

Usage:
    python -I tools/headless/merge_build_files.py --run <run dir> --slug <slug>
    python -I tools/headless/merge_build_files.py --run <run dir> --all
    python -I tools/headless/merge_build_files.py --run <run dir> --index-only
"""
import argparse
import glob
import os
import re

STAGING_SECTIONS = {
    "Modifiers": "| ID | Name (Hán-Việt) | Stat and size | Form | Channel | Layer | Fit | Suggested home | Used by | Notes |",
    "Effects": "| ID | Name (Hán-Việt) | Rule | Fit | Suggested home | Used by | Notes |",
    "Enablers": "| ID | Name (Hán-Việt) | Kind | Lives on | Opens | Closes | Fit | Used by |",
    "Artifacts, talismans, pills, formations": "| ID | Name (Hán-Việt) | Type | What it does | Fit | Used by | Notes |",
    "Công pháp": "| ID | Name (Hán-Việt) | Kind and tier | What it gives | Fit | Used by | Notes |",
    "Arts": "| ID | Name (Hán-Việt) | Source | Kind, tags | c_art / cost / cooldown | Rule | Fit | Used by |",
    "Đạo pieces": "| ID | Name (Hán-Việt) | Way and facet | Kind | What it does | Fit | Used by |",
    "Concepts and keys": "| ID | Name | Kind | What it is | Fit | Used by |",
}
LEDGER_SECTIONS = {
    "Builds": "| Build | Channel | Enabler | Identity piece | Sheet |",
    "Modifiers": "| Modifier | Form | Channel | Layer | Fit | Used by | Second home | State |",
    "Enablers": "| Enabler | Kind | Lives on | Opens | Closes | Used by | State |",
    "Other pieces": "| Piece | Type | Fit | Used by | State |",
    "New concepts": "| Concept | Rule needed | Serves | State |",
}
SPLIT = re.compile(r"(?<!\\)\|")


def cells(row):
    parts = SPLIT.split(row.strip())
    return [c.strip() for c in parts[1:-1]] if len(parts) >= 3 else []


def key(cell):
    return re.sub(r"[`*\s]", "", cell).lower()


def is_sep(row):
    return bool(re.match(r"^\|[\s:|-]+\|\s*$", row))


class Doc:
    """A markdown file as lines, with its ## sections and the table rows in each."""

    def __init__(self, path, title, sections):
        self.path = path
        if os.path.exists(path):
            with open(path, encoding="utf-8") as f:
                self.lines = f.read().splitlines()
        else:
            self.lines = ["# " + title, ""]
            for name, header in sections.items():
                self.lines += ["## " + name, "", header, "|" + "---|" * len(cells(header)), ""]
        self.changed = False

    def sections(self):
        out = {}
        cur = None
        for i, l in enumerate(self.lines):
            if l.startswith("## "):
                cur = l[3:].strip()
                out[cur] = {"start": i, "header": None, "rows": []}
            elif cur and l.startswith("|"):
                s = out[cur]
                if s["header"] is None:
                    s["header"] = i
                elif not is_sep(l):
                    s["rows"].append(i)
        return out

    def find(self, rid):
        for name, s in self.sections().items():
            for i in s["rows"]:
                c = cells(self.lines[i])
                if c and key(c[0]) == rid:
                    return name, i
        return None, None

    def add_used_by(self, i, header_line, slug):
        hdr = [h.lower() for h in cells(header_line)]
        if "used by" not in hdr:
            return False
        col = hdr.index("used by")
        c = cells(self.lines[i])
        if col >= len(c):
            return False
        used = c[col]
        if re.search(r"(^|[\s,`])" + re.escape(slug) + r"($|[\s,`])", used):
            return False
        c[col] = (used + ", " + slug) if used and used not in ("—", "-") else slug
        self.lines[i] = "| " + " | ".join(c) + " |"
        self.changed = True
        return True

    def append_row(self, section, row):
        s = self.sections().get(section)
        if s is None or s["header"] is None:
            return False
        last = s["rows"][-1] if s["rows"] else s["header"] + 1
        self.lines.insert(last + 1, row.strip())
        self.changed = True
        return True

    def save(self):
        if self.changed:
            with open(self.path, "w", encoding="utf-8") as f:
                f.write("\n".join(self.lines) + "\n")


def own_rows(path):
    """Rows of a per-build file, by section: {section: [row text]}."""
    out = {}
    if not os.path.exists(path):
        return out
    cur = None
    seen_header = False
    with open(path, encoding="utf-8") as f:
        for l in f.read().splitlines():
            if l.startswith("## "):
                cur, seen_header = l[3:].strip(), False
                out.setdefault(cur, [])
            elif cur and l.startswith("|"):
                if not seen_header:
                    seen_header = True
                elif not is_sep(l):
                    out[cur].append(l)
    return out


def merge_table_file(shared, own_path, sections, slug, label, report):
    for section, rows in own_rows(own_path).items():
        if section == "Reused":
            continue
        if section not in sections:
            for r in rows:
                report.append("UNPLACED\t%s\tunknown section '%s': %s" % (label, section, r[:100]))
            continue
        for r in rows:
            c = cells(r)
            if not c or not key(c[0]):
                report.append("UNPLACED\t%s\trow with no ID in '%s': %s" % (label, section, r[:100]))
                continue
            sec, i = shared.find(key(c[0]))
            if i is not None:
                hdr = shared.lines[shared.sections()[sec]["header"]]
                if shared.add_used_by(i, hdr, slug):
                    report.append("used_by\t%s\t%s += %s" % (label, c[0], slug))
            elif shared.append_row(section, r):
                report.append("added\t%s\t%s / %s" % (label, section, c[0]))
            else:
                report.append("UNPLACED\t%s\tsection '%s' has no table in the shared file: %s" % (label, section, c[0]))


def merge(run, slug, report):
    b = os.path.join(run, "builds")
    st = Doc(os.path.join(run, "staging-catalogue.md"), "Staging Catalogue", STAGING_SECTIONS)
    merge_table_file(st, os.path.join(b, slug + ".staging.md"), STAGING_SECTIONS, slug, "staging", report)
    for r in own_rows(os.path.join(b, slug + ".staging.md")).get("Reused", []):
        c = cells(r)
        if not c:
            continue
        sec, i = st.find(key(c[0]))
        if i is not None:
            if st.add_used_by(i, st.lines[st.sections()[sec]["header"]], slug):
                report.append("used_by\tstaging\t%s += %s (reused)" % (c[0], slug))
        elif len(c) > 1 and "staging" in c[1].lower():
            report.append("UNPLACED\tstaging\treused ID not found in the staging catalogue: %s" % c[0])
    st.save()
    led = Doc(os.path.join(run, "ledger.md"), "Build Content Ledger", LEDGER_SECTIONS)
    merge_table_file(led, os.path.join(b, slug + ".ledger.md"), LEDGER_SECTIONS, slug, "ledger", report)
    led.save()
    sp = os.path.join(b, slug + ".suggestions.md")
    if os.path.exists(sp):
        shared = os.path.join(run, "suggestions.md")
        text = open(shared, encoding="utf-8").read() if os.path.exists(shared) else "# System Suggestions\n"
        with open(sp, encoding="utf-8") as f:
            own = f.read()
        entries = re.split(r"(?m)^(?=### )", own)
        added = []
        for e in entries:
            if not e.startswith("### "):
                continue
            head = e.splitlines()[0].strip()
            if head not in text:
                text = text.rstrip("\n") + "\n\n" + e.strip() + "\n"
                added.append(head)
        if added:
            with open(shared, "w", encoding="utf-8") as f:
                f.write(text)
        for h in added:
            report.append("added\tsuggestions\t%s" % h[4:])


def write_index(run):
    st = Doc(os.path.join(run, "staging-catalogue.md"), "Staging Catalogue", STAGING_SECTIONS)
    out = ["# Staging index (generated; do not edit)", "",
           "> One short row per staged piece in `staging-catalogue.md`, for reuse by grep. Generated by",
           "> `tools/headless/merge_build_files.py` after each build. To stage a new piece, write it in your own",
           "> `<slug>.staging.md` under the matching section, with that section's columns:", ""]
    for name, header in STAGING_SECTIONS.items():
        out.append("- **%s:** `%s`" % (name, header))
    out += ["", "To reuse a staged piece, list its ID in your file's `## Reused` table: `| ID | Found in |`.", ""]
    n = 0
    for name, s in st.sections().items():
        if s["header"] is None:
            continue
        hdr = [h.lower() for h in cells(st.lines[s["header"]])]
        fit = next((i for i, h in enumerate(hdr) if h == "fit"), None)
        used = next((i for i, h in enumerate(hdr) if h == "used by"), None)
        out += ["## " + name, "", "| ID | Name | Fit | Used by |", "|---|---|---|---|"]
        for i in s["rows"]:
            c = cells(st.lines[i])
            if not c:
                continue

            def cut(j, w):
                if j is None or j >= len(c):
                    return ""
                v = c[j]
                return v if len(v) <= w else v[:w - 1] + "…"
            out.append("| %s | %s | %s | %s |" % (cut(0, 40), cut(1, 50), cut(fit, 28), cut(used, 60)))
            n += 1
        out.append("")
    with open(os.path.join(run, "staging-index.md"), "w", encoding="utf-8") as f:
        f.write("\n".join(out) + "\n")
    return n


def main():
    ap = argparse.ArgumentParser()
    ap.add_argument("--run", required=True)
    g = ap.add_mutually_exclusive_group(required=True)
    g.add_argument("--slug")
    g.add_argument("--all", action="store_true")
    g.add_argument("--index-only", action="store_true")
    a = ap.parse_args()
    report = []
    if a.slug or a.all:
        slugs = [a.slug] if a.slug else sorted({os.path.basename(p).split(".")[0] for p in
                                                 glob.glob(os.path.join(a.run, "builds", "*.staging.md"))
                                                 + glob.glob(os.path.join(a.run, "builds", "*.ledger.md"))
                                                 + glob.glob(os.path.join(a.run, "builds", "*.suggestions.md"))})
        for s in slugs:
            merge(a.run, s, report)
    n = write_index(a.run)
    for r in report:
        print(r)
    print("index\t%d staged pieces\t%s" % (n, os.path.join(a.run, "staging-index.md")))
    return 1 if any(r.startswith("UNPLACED") for r in report) else 0


if __name__ == "__main__":
    raise SystemExit(main())

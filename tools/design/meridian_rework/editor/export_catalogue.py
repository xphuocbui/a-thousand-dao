"""Read the modifier and effect catalogues out of the GDDs for the Meridian Map editor's pickers.

Usage (from the repo root):
  python -I tools/design/meridian_rework/editor/export_catalogue.py [<out.json>]

serve.py calls build() on every request, so the editor always shows the GDDs as they are now; the file output is
for publish_view.py and for a look at what the parser found. Sources (design/gdd/):
- modifiers.md  #### General Catalogue  -> "modifier" entries: one per scope tag, with the Small and Notable values
- modifiers.md  #### Stat List          -> "stat" entries: a stat and its key, for a modifier with a value you type
- effects.md    ### Status Catalogue, ### Starter Effects -> "effect" entries: name, rule, payload, hosts
The GDDs are the source of truth; this only reads them. Rows struck through (~~) are skipped.
"""
import json
import os
import re
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
GDD = os.path.join(ROOT, "design", "gdd")


def _lines(fn):
    with open(os.path.join(GDD, fn), encoding="utf-8") as f:
        return f.read().splitlines()


def _section(lines, heading):
    """Lines under `heading` up to the next heading of the same or a higher level."""
    level = len(heading) - len(heading.lstrip("#"))
    out, on = [], False
    for ln in lines:
        if ln.strip() == heading:
            on = True
            continue
        if on and ln.startswith("#"):
            lv = len(ln) - len(ln.lstrip("#"))
            if lv <= level:
                break
        if on:
            out.append(ln)
    return out


def _cells(row):
    row = row.strip()
    if row.startswith("|"):
        row = row[1:]
    if row.endswith("|"):
        row = row[:-1]
    return [c.strip() for c in re.split(r"(?<!\\)\|", row)]


def _tables(lines):
    """Yield (group, header, rows) for every Markdown table; group is the last bold-line label above it."""
    group, header, rows = "", None, []
    for ln in lines + [""]:
        s = ln.strip()
        if s.startswith("|"):
            cells = _cells(s)
            if header is None:
                header = cells
            elif all(re.fullmatch(r":?-{2,}:?", c) for c in cells if c):
                continue
            else:
                rows.append(cells)
            continue
        if header is not None:
            yield group, header, rows
            header, rows = None, []
        m = re.match(r"^\*\*(.+?)\*\*", s)
        if m:
            group = m.group(1).strip().rstrip(":.").strip()


def plain(md):
    """Markdown cell text as plain text: no backticks, bold or links."""
    md = re.sub(r"\[([^\]]+)\]\([^)]*\)", r"\1", md)
    return re.sub(r"[`*]", "", md).replace("<br>", " ").strip()


def _key_of(label):
    m = re.search(r"`([a-z0-9_]+)`", label)
    return m.group(1) if m else None


def modifiers(lines):
    out = []
    for group, head, rows in _tables(_section(lines, "#### General Catalogue")):
        if not head or head[0] != "Modifier":
            continue
        col = {h: i for i, h in enumerate(head)}
        for r in rows:
            if len(r) < len(head) or r[0].startswith("~~"):
                continue
            g = lambda h: plain(r[col[h]]) if h in col else ""
            label, scope = r[col["Modifier"]], (r[col["Scope"]] if "Scope" in col else "—")
            # the two odd tables: "Damage, more" (Sources, Typical points) and "Rare" (Unit, W, Allowed sources)
            note = "; ".join(x for x in (g("Typical points"), g("Unit") and f"{g('Unit')}, W {g('W')}",
                                         g("Sources") and "sources: " + g("Sources"),
                                         g("Allowed sources") and "sources: " + g("Allowed sources")) if x)
            name = plain(re.sub(r"\s*\(`[^`]*`\)", "", label))
            key = _key_of(label)
            count = r[col["Count"]] if "Count" in col else ""
            # one entry per tag when the scope lists exactly Count tags ("type: fire, cold, lightning, light, chaos")
            tags = [scope]
            m = re.match(r"^([a-z][a-z ()]*?):\s*(.+)$", plain(scope))
            if m and count.isdigit() and int(count) > 1:
                items = [re.sub(r"\s*\(.*?\)$", "", t.strip()) for t in m.group(2).split(",")]
                if len(items) == int(count):
                    tags = [f"{m.group(1)}: {t}" for t in items]
            for sc in tags:
                sc = plain(sc)
                out.append({
                    "type": "modifier", "id": f"mod:{key}|{sc}", "group": group, "name": name, "key": key,
                    "scope": "" if sc in ("—", "-") else sc, "tier": g("Tier"),
                    "small": g("Small (1.2 W)"), "notable": g("Notable (8 W)"), "status": g("Status"), "note": note,
                })
    return out


def stats(lines):
    out = []
    for group, head, rows in _tables(_section(lines, "#### Stat List")):
        if not head or head[0] != "Stat":
            continue
        col = {h: i for i, h in enumerate(head)}
        for r in rows:
            if len(r) < len(head) or r[0].startswith("~~"):
                continue
            key = _key_of(r[col["Key"]])
            if not key:
                continue
            out.append({"type": "stat", "id": f"stat:{key}", "group": group.split(":")[0] + (":" + group.split(":")[1] if ":" in group else ""),
                        "name": plain(r[0]), "key": key, "ops": plain(r[col.get("Ops", 2)]),
                        "better": plain(r[col["Better"]]) if "Better" in col else "",
                        "status": plain(r[col["Status"]]) if "Status" in col else ""})
    return out


def effects(lines):
    out = []
    for sec in ("### Status Catalogue", "### Starter Effects"):
        for group, head, rows in _tables(_section(lines, sec)):
            if not head or head[0] not in ("Name", "Status", "Curse"):
                continue
            col = {h: i for i, h in enumerate(head)}
            for r in rows:
                if len(r) < len(head) or r[0].startswith("~~"):
                    continue
                name = plain(r[0])
                rule = plain(r[col["Rule"]]) if "Rule" in col else ""
                payload = plain(r[col["Payload / action"]]) if "Payload / action" in col else ""
                if sec == "### Status Catalogue":
                    bits = [f"{h}: {plain(r[i])}" for h, i in col.items() if i and h != "Rule" and plain(r[i]) not in ("", "—")]
                    payload = "; ".join(bits)
                out.append({"type": "effect", "id": f"eff:{re.sub(r' [(].*', '', name)}",
                            "group": ("Status: " if sec == "### Status Catalogue" else "") + group, "name": name,
                            "rule": rule, "payload": payload,
                            "closes": plain(r[col["Closes"]]) if "Closes" in col and plain(r[col["Closes"]]) not in ("", "—") else "",
                            "hosts": plain(r[col["Hosts"]]) if "Hosts" in col else ""})
    return out


def build():
    m, e = _lines("modifiers.md"), _lines("effects.md")
    return {"modifiers": modifiers(m), "stats": stats(m), "effects": effects(e),
            "sources": ["design/gdd/modifiers.md", "design/gdd/effects.md"]}


if __name__ == "__main__":
    data = build()
    print(f"{len(data['modifiers'])} modifiers, {len(data['stats'])} stats, {len(data['effects'])} effects", file=sys.stderr)
    if len(sys.argv) > 1:
        with open(sys.argv[1], "w", encoding="utf-8") as f:
            json.dump(data, f, ensure_ascii=False, indent=1)
    else:
        json.dump(data, sys.stdout, ensure_ascii=False, indent=1)

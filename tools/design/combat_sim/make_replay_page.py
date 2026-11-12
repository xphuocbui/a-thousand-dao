"""Inline a replays JSON (export_replay.py) into the fight-screen viewer (replay_viewer.html) as one page.

Run: python -I tools/design/combat_sim/make_replay_page.py REPLAYS.json OUT.html
"""
import os
import sys

HERE = os.path.dirname(os.path.abspath(__file__))


def main():
    if len(sys.argv) != 3:
        print(__doc__)
        return 2
    page = open(os.path.join(HERE, "replay_viewer.html"), encoding="utf-8").read()
    data = open(sys.argv[1], encoding="utf-8").read().replace("</", "<\\/")
    if "/*__DATA__*/" not in page:
        print("NO_SLOT\treplay_viewer.html has no /*__DATA__*/ slot")
        return 2
    with open(sys.argv[2], "w", encoding="utf-8", newline="\n") as f:
        f.write(page.replace("/*__DATA__*/", data))
    print("wrote %s (%d KB)" % (sys.argv[2], os.path.getsize(sys.argv[2]) // 1024))
    return 0


if __name__ == "__main__":
    sys.exit(main())

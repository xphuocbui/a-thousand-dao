"""Rebuild the Continent 11 atlas page (the claude.ai artifact) from the approved design data.

The page is base_page.html (the atlas as approved before the history) with the history sections added: the
chronicle map that follows the eras, the annals by region, the legendary items, the people and the sect start.
Steps: build_assets.py (base map, miasma, first data blob), build_assets2.py (one mask per land unit, page data),
assemble2.py (joins base_page.html, the frag_* files and the data). Everything lands in build/ (git-ignored):
build/continent11.html and the images it loads (chron-base.jpg, chron-miasma.png, u-*.png). Publish build/ as the
artifact. Takes a few minutes.

Run:  python -I tools/design/world/page/build_page.py
"""

import glob
import os
import shutil
import subprocess
import sys

HERE = os.path.dirname(os.path.abspath(__file__))
ROOT = os.path.abspath(os.path.join(HERE, "..", "..", "..", ".."))
BUILD = os.path.join(HERE, "build")


def run(*args):
    subprocess.run([sys.executable, *args], check=True, cwd=ROOT, env=dict(os.environ, PYTHONIOENCODING="utf-8"))


def main():
    os.makedirs(BUILD, exist_ok=True)
    run(os.path.join(HERE, "build_assets.py"), ROOT, os.path.join(BUILD, "out"))
    run(os.path.join(HERE, "build_assets2.py"), ROOT, os.path.join(BUILD, "out2"))
    run(os.path.join(HERE, "assemble2.py"), os.path.join(HERE, "base_page.html"))
    for f in ["chron-base.jpg", "chron-miasma.png"]:
        shutil.copy(os.path.join(BUILD, "out", f), BUILD)
    for f in glob.glob(os.path.join(BUILD, "out2", "u-*.png")):
        shutil.copy(f, BUILD)
    print("built", os.path.join(BUILD, "continent11.html"))


if __name__ == "__main__":
    main()

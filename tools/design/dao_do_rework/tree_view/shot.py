"""Screenshots of the tree page at fixed views, by headless Chrome (or Edge).

usage: python -I shot.py [--clean] <page.html> <out_dir> <W>x<H> name:tree:cx,cy:width [name:tree:cx,cy:width ...]
  --clean leaves out the caption (for reference images given to an image model); --grid=N draws a u/v grid every N units.
  tree = poe2 | ours | ours1 ...; cx, cy, width in map units as drawn (screen y grows downward, so our v is -y).
Writes <out_dir>/<name>.png at W x H pixels, one device pixel per CSS pixel.
"""
import os
import pathlib
import subprocess
import sys
import tempfile

CANDIDATES = [r'C:\Program Files\Google\Chrome\Application\chrome.exe',
              r'C:\Program Files (x86)\Microsoft\Edge\Application\msedge.exe']
browser = next(p for p in CANDIDATES if os.path.exists(p))
CLEAN = '--clean' in sys.argv
GRID = next((a.split('=')[1] for a in sys.argv if a.startswith('--grid=')), None)
sys.argv = [a for a in sys.argv if a != '--clean' and not a.startswith('--grid=')]
page, out_dir, size = sys.argv[1], sys.argv[2], sys.argv[3]
w, h = size.split('x')
os.makedirs(out_dir, exist_ok=True)
url = pathlib.Path(page).resolve().as_uri()
prof = tempfile.mkdtemp(prefix='treeshot-')
for spec in sys.argv[4:]:
    name, tree, c, width = spec.split(':')
    out = os.path.abspath(os.path.join(out_dir, name + '.png'))
    cmd = [browser, '--headless=new', '--disable-gpu', '--hide-scrollbars', '--force-device-scale-factor=1',
           '--user-data-dir=' + prof, '--window-size=%s,%s' % (w, h), '--virtual-time-budget=4000',
           '--screenshot=' + out, '%s#t=%s&c=%s&w=%s&shot%s' % (url, tree, c, width, ('&clean' if CLEAN else '') + ('&grid=' + GRID if GRID else ''))]
    subprocess.run(cmd, check=True, stdout=subprocess.DEVNULL, stderr=subprocess.DEVNULL, timeout=120)
    print(out)

"""Pulls the python block out of a response text into a module file. usage: python -I extract.py <text.md> <out.py>"""
import re, sys
t = open(sys.argv[1], encoding='utf-8').read()
blocks = re.findall(r"```python\n(.*?)```", t, re.S)
assert blocks, 'no python block'
code = max(blocks, key=len)
open(sys.argv[2], 'w', encoding='utf-8').write(code)
bad = [w for w in ('open(', 'exec(', 'eval(', '__import__', 'subprocess', 'os.', 'sys.', 'socket', 'urllib', 'print(') if w in code]
imps = sorted(set(l.strip() for l in code.splitlines() if l.strip().startswith(('import ', 'from '))))
print(sys.argv[2], len(code.splitlines()), 'lines; imports', imps, '; flagged', bad)

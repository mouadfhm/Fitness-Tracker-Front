# Temporary: lists methods in the release bundle that call BitmapFactory.decode*
# without an Options argument, with their original names from mapping.txt.
import re, sys
dump, mapping = sys.argv[1], sys.argv[2]
sites = set()
cls = meth = None
for line in open(dump, errors="replace"):
    m = re.search(r"Class descriptor\s*:\s*'L(.+);'", line)
    if m: cls = m.group(1).replace("/", "."); continue
    m = re.match(r"\s+name\s*:\s*'(.+)'", line)
    if m: meth = m.group(1); continue
    if "Landroid/graphics/BitmapFactory;.decode" in line and "BitmapFactory$Options" not in line:
        sites.add((cls, meth, line.split("BitmapFactory;.")[1].strip()))
orig = {}
methods = {}
cur = None
for line in open(mapping, errors="replace"):
    if line.startswith("#"): continue
    if not line.startswith(" "):
        m = re.match(r"(\S+) -> (\S+):", line)
        if m: cur = m.group(2); orig[cur] = m.group(1)
    else:
        m = re.search(r"(\S+)\(.*\)(?::\d+(?::\d+)?)? -> (\S+)$", line.strip())
        if m and cur: methods.setdefault((cur, m.group(2)), set()).add(m.group(1))
for c, mt, call in sorted(sites):
    print(f"{c}.{mt}  =>  {orig.get(c, c)}.{'/'.join(sorted(methods.get((c, mt), {mt})))}  calls {call}")

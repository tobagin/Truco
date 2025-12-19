import os
import glob

# Check dimensions from existing file or assume generic
# I will use 223.2 x 312 based on common playing card svg libraries, but I'll check the output of head command first if I can.
# Actually I am running this script in a separate step, so I can't see the output of adjacent tool call.
# I will assume standard size or read it from the file in python.

def get_svg_dims(path):
    with open(path, 'r') as f:
        content = f.read()
        # simplified parsing
        if 'width="' in content and 'height="' in content:
            try:
                w = content.split('width="')[1].split('"')[0]
                h = content.split('height="')[1].split('"')[0]
                return w, h
            except:
                pass
    return "223.2", "312"

w, h = get_svg_dims('data/cards/modern/ace_of_diamonds.svg')

# 1. Wrap PNG
with open('/tmp/b64.txt', 'r') as f:
    b64 = f.read().strip()

svg_content = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg width="{{w}}" height="{{h}}" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
 <image x="0" y="0" width="{{w}}" height="{{h}}" xlink:href="data:image/png;base64,{{b64}}"/>
</svg>'''

with open('data/cards/spanish/ace_of_diamonds.svg', 'w') as f:
    f.write(svg_content)

# 2. Update gresource
lines = []
with open('data/io.github.tobagin.Truco.gresource.xml.in', 'r') as f:
    for line in f:
        # Keep everything except old cards
        # Old cards were <file>cards/xxx.svg</file>
        # New ones will be <file>cards/modern/xxx.svg</file>
        # make sure we don't delete backs/
        if '<file>cards/' in line and '.svg</file>' in line and 'backs/' not in line and 'modern/' not in line and 'spanish/' not in line:
            continue
        lines.append(line)

# Insert new files
insert_idx = -1
for i, line in enumerate(lines):
    if '</gresource>' in line:
        insert_idx = i
        break

new_lines = []
for folder in ['modern', 'spanish']:
    files = sorted(glob.glob(f'data/cards/{{folder}}/*.svg'))
    for path in files:
        rel_path = path.replace('data/', '') # remove data/ prefix
        new_lines.append(f'    <file>{rel_path}</file>\n')

lines[insert_idx:insert_idx] = new_lines

with open('data/io.github.tobagin.Truco.gresource.xml.in', 'w') as f:
    f.writelines(lines)

print(f"Updated gresource. Created Spanish Ace with dims {{w}}x{{h}}")

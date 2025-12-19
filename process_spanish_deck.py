
import os
import io
import base64
from PIL import Image

# Configuration based on grid detection
# Found 12 cols, 5 rows.
# Card: 206x317
# Gap: 2px
# Start: 1,1
INPUT_FILE = 'data/Baraja_española_completa.png'
OUTPUT_DIR = 'data/cards/spanish'

CARD_W = 206
CARD_H = 317
GAP_X = 2
GAP_Y = 2
OFFSET_X = 1
OFFSET_Y = 1

ROW_COUNT = 4 # Process first 4 rows as suits
COL_COUNT = 12 # Process 12 cards per suit

SUITS = ['diamonds', 'hearts', 'spades', 'clubs'] # Oros, Copas, Espadas, Bastos

# Ensure output directory exists
os.makedirs(OUTPUT_DIR, exist_ok=True)

img = Image.open(INPUT_FILE)
width, height = img.size

print(f"Processing 12x4 grid from {width}x{height} image")

def save_card(cropped_img, filename):
    # Convert to base64
    buf = io.BytesIO()
    cropped_img.save(buf, format='PNG')
    b64 = base64.b64encode(buf.getvalue()).decode('utf-8')
    
    # SVG Template - wrap the exact pixel size
    svg = f'''<?xml version="1.0" encoding="UTF-8"?>
<svg width="{CARD_W}" height="{CARD_H}" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
 <image x="0" y="0" width="{CARD_W}" height="{CARD_H}" xlink:href="data:image/png;base64,{b64}"/>
</svg>'''
    
    with open(os.path.join(OUTPUT_DIR, filename), 'w') as f:
        f.write(svg)
    print(f"Saved {filename}")

for r in range(ROW_COUNT):
    suit_name = SUITS[r]
    for c in range(COL_COUNT):
        # Calculate coords
        x = OFFSET_X + c * (CARD_W + GAP_X)
        y = OFFSET_Y + r * (CARD_H + GAP_Y)
        
        # Determine value (1-12)
        val = c + 1
        
        # Truco filename mapping
        # 1-7: number or ace
        # 8,9: number
        # 10: Sota -> "queen" (in Truco logic usually 8=Queen, 9=Jack? No. Truco uses 10,11,12)
        # Wait, Truco: 1, 2, 3, 4, 5, 6, 7, 10, 11, 12.
        # But my codebase expects: "queen" for 10 (Sota), "jack" for 11 (Caballo), "king" for 12 (Rey).
        # And standard numbers for 1-9.
        # "ace" for 1.
        
        prefix = str(val)
        if val == 1: prefix = "ace"
        elif val == 10: prefix = "queen"
        elif val == 11: prefix = "jack"
        elif val == 12: prefix = "king"
        
        # Note: My detected grid has 12 cols.
        # Col 0 -> 1 -> Ace
        # ...
        # Col 9 -> 10 -> Queen (Sota)
        # Col 10 -> 11 -> Jack (Caballo)
        # Col 11 -> 12 -> King (Rey)
        
        filename = f"{prefix}_of_{suit_name}.svg"
        
        crop = img.crop((x, y, x + CARD_W, y + CARD_H))
        save_card(crop, filename)

# Process Row 5 (Jokers?)
# Usually row 4 (0-indexed) has jokers.
# Assuming 2 jokers at card 1 and 2 of row 4? Or end?
# I saw 12 cols in row detection for row 5 as well?
# Let's just grab the first 2 cards of row 4 as jokers just in case.
joker_row = 4
# Red Joker
x = OFFSET_X + 0 * (CARD_W + GAP_X)
y = OFFSET_Y + joker_row * (CARD_H + GAP_Y)
crop = img.crop((x, y, x + CARD_W, y + CARD_H))
save_card(crop, "red_joker.svg")

# Black Joker
x = OFFSET_X + 1 * (CARD_W + GAP_X)
y = OFFSET_Y + joker_row * (CARD_H + GAP_Y)
crop = img.crop((x, y, x + CARD_W, y + CARD_H))
save_card(crop, "black_joker.svg")

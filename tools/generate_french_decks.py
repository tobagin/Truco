#!/usr/bin/env python3
"""
Hand-crafted French-suited decks (spades/hearts/diamonds/clubs) as true vector
SVG, in three coherent styles that match the Spanish deck's quality bar:

    french         ivory heritage stock, gilt frame, woodcut court figures on a throne
    modern-faces   clean white stock, the same woodcut court figures, flat
    modern-simple  minimalist white stock, typographic court (rank letter + watermark)

Filenames: ace,2..10,jack,queen,king x spades/hearts/diamonds/clubs (52 cards).
Truco uses A,2-7 + jack/queen/king; full decks are emitted for completeness.
"""
import os

CARD_W, CARD_H = 250, 350

SUITS = ["spades", "hearts", "diamonds", "clubs"]
RED = "#c4302b"
BLACK = "#23272e"
SUIT_COLOR = {"spades": BLACK, "clubs": BLACK, "hearts": RED, "diamonds": RED}
# robe colour per suit for the court figures (red suits red, black suits royal blue)
ROBE_COLOR = {"hearts": "#b0271c", "diamonds": "#b0271c", "spades": "#2f5b9c", "clubs": "#2f5b9c"}

RANKS = ["ace", "2", "3", "4", "5", "6", "7", "8", "9", "10", "jack", "queen", "king"]
RANK_LABEL = {"ace": "A", "jack": "J", "queen": "Q", "king": "K"}
COURTS = {"jack", "queen", "king"}

INK = "#2b2117"
SKIN = "#e8b88a"; SKIN_SH = "#c99064"
GOLD = "#e3b53a"; GOLD_D = "#a87f1e"
ERMINE = "#f4efe2"


def _sh(hexc, f):
    h = hexc.lstrip('#'); r, g, b = (int(h[i:i + 2], 16) for i in (0, 2, 4))
    if f < 0:
        f = 1 + f; return '#%02x%02x%02x' % (int(r * f), int(g * f), int(b * f))
    return '#%02x%02x%02x' % (int(r + (255 - r) * f), int(g + (255 - g) * f), int(b + (255 - b) * f))

def dk(c, f=0.7): return _sh(c, -(1 - f))
def lt(c, f=0.4): return _sh(c, f)


# --------------------------------------------------------------------------
# Suit glyphs — centred on (0,0), ~36 units tall.
# --------------------------------------------------------------------------

def spade(fill):
    return (f'<g fill="{fill}"><path d="M0,-18 C7,-7 20,-2 20,9 C20,17 13,21 7,19 '
            f'C4,18 2,16 1,14 C2,20 4,24 8,27 L-8,27 C-4,24 -2,20 -1,14 '
            f'C-2,16 -4,18 -7,19 C-13,21 -20,17 -20,9 C-20,-2 -7,-7 0,-18 Z"/></g>')

def heart(fill):
    return (f'<g fill="{fill}"><path d="M0,26 C-3,20 -19,9 -19,-6 C-19,-15 -12,-19 -6,-19 '
            f'C-2,-19 0,-16 0,-13 C0,-16 2,-19 6,-19 C12,-19 19,-15 19,-6 '
            f'C19,9 3,20 0,26 Z"/></g>')

def diamond(fill):
    return f'<g fill="{fill}"><path d="M0,-25 C7,-12 13,-6 19,0 C13,6 7,12 0,25 C-7,12 -13,6 -19,0 C-13,-6 -7,-12 0,-25 Z"/></g>'

def club(fill):
    return (f'<g fill="{fill}"><circle cx="0" cy="-9" r="9"/><circle cx="-10" cy="6" r="9"/>'
            f'<circle cx="10" cy="6" r="9"/><path d="M-3,4 C-3,14 -6,22 -9,27 L9,27 '
            f'C6,22 3,14 3,4 Z"/></g>')

GLYPH = {"spades": spade, "hearts": heart, "diamonds": diamond, "clubs": club}
GLYPH_CY = {"spades": 4.5, "hearts": 3.5, "diamonds": 0.0, "clubs": 4.5}


# --------------------------------------------------------------------------
# Pip layouts (standard; lower half rotated 180).
# --------------------------------------------------------------------------
PIPS = {
    1:  [(0, 0)],
    2:  [(0, -1), (0, 1)],
    3:  [(0, -1), (0, 0), (0, 1)],
    4:  [(-1, -1), (1, -1), (-1, 1), (1, 1)],
    5:  [(-1, -1), (1, -1), (0, 0), (-1, 1), (1, 1)],
    6:  [(-1, -1), (1, -1), (-1, 0), (1, 0), (-1, 1), (1, 1)],
    7:  [(-1, -1), (1, -1), (0, -0.5), (-1, 0), (1, 0), (-1, 1), (1, 1)],
    8:  [(-1, -1), (1, -1), (0, -0.5), (-1, 0), (1, 0), (0, 0.5), (-1, 1), (1, 1)],
    9:  [(-1, -1), (1, -1), (-1, -0.34), (1, -0.34), (0, 0), (-1, 0.34), (1, 0.34), (-1, 1), (1, 1)],
    10: [(-1, -1), (1, -1), (0, -0.66), (-1, -0.34), (1, -0.34), (-1, 0.34), (1, 0.34), (0, 0.66), (-1, 1), (1, 1)],
}
CX, CY, HX, HY = 125, 178, 52, 116
PIP_SCALE = 1.18
ACE_SCALE = 2.3


def pip_field(suit, n):
    fill = SUIT_COLOR[suit]
    sc = ACE_SCALE if n == 1 else PIP_SCALE
    out = []
    for (nx, ny) in PIPS[n]:
        x = CX + nx * HX; y = CY + ny * HY
        rot = ' rotate(180)' if ny > 0.001 else ''
        out.append(f'<g transform="translate({x:.1f} {y:.1f}) scale({sc:.3f}){rot}">{GLYPH[suit](fill)}</g>')
    return "".join(out)


def suit_watermark(suit, scale=5.2, cy=178, opacity=0.9, tint=0.80):
    c = SUIT_COLOR[suit]
    wy = cy - GLYPH_CY[suit] * scale
    return f'<g transform="translate(125 {wy:.1f}) scale({scale})" opacity="{opacity}">{GLYPH[suit](lt(c, tint))}</g>'


def indices(suit, label, font, weight="bold", size=30, gap=20, mini=0.42):
    c = SUIT_COLOR[suit]
    g = (f'<text x="0" y="0" font-family="{font}" font-weight="{weight}" font-size="{size}" '
         f'fill="{c}" text-anchor="middle">{label}</text>'
         f'<g transform="translate(0 {gap}) scale({mini})">{GLYPH[suit](c)}</g>')
    return (f'<g transform="translate(27 38)">{g}</g>'
            f'<g transform="translate({CARD_W - 27} {CARD_H - 38}) rotate(180)">{g}</g>')


# --------------------------------------------------------------------------
# Frames
# --------------------------------------------------------------------------
IVORY_DEFS = '''
    <linearGradient id="ivory" x1="0" y1="0" x2="0.3" y2="1"><stop offset="0%" stop-color="#fdf8ec"/><stop offset="100%" stop-color="#f0e8d2"/></linearGradient>
    <radialGradient id="ivoryGlow" cx="50%" cy="40%" r="70%"><stop offset="0%" stop-color="#fffefa" stop-opacity="0.7"/><stop offset="100%" stop-color="#fffefa" stop-opacity="0"/></radialGradient>'''


def frame_modern():
    return (f'<rect x="3" y="3" width="{CARD_W - 6}" height="{CARD_H - 6}" rx="16" '
            f'fill="#ffffff" stroke="#d9dde3" stroke-width="2"/>')


def frame_french(suit):
    c = SUIT_COLOR[suit]; acc = "#b08a2e"
    return f'''
    <rect x="2.5" y="2.5" width="{CARD_W - 5}" height="{CARD_H - 5}" rx="17" fill="url(#ivory)" stroke="#d8cba2" stroke-width="2"/>
    <rect x="2.5" y="2.5" width="{CARD_W - 5}" height="{CARD_H - 5}" rx="17" fill="url(#ivoryGlow)"/>
    <rect x="11" y="11" width="{CARD_W - 22}" height="{CARD_H - 22}" rx="12" fill="none" stroke="{acc}" stroke-width="2.4"/>
    <rect x="15.5" y="15.5" width="{CARD_W - 31}" height="{CARD_H - 31}" rx="9" fill="none" stroke="{c}" stroke-width="1" opacity="0.55"/>'''


# --------------------------------------------------------------------------
# Woodcut court figures (King / Queen / Jack)
# --------------------------------------------------------------------------

def _face(cx, cy, beard=False, queen=False):
    locks = (f'<path d="M{cx-26},{cy-4} Q{cx-30},{cy+22} {cx-15},{cy+34} Q{cx-22},{cy+16} {cx-21},{cy-4} Z" fill="{INK}"/>'
             f'<path d="M{cx+26},{cy-4} Q{cx+30},{cy+22} {cx+15},{cy+34} Q{cx+22},{cy+16} {cx+21},{cy-4} Z" fill="{INK}"/>')
    if queen:
        locks += f'<path d="M{cx-22},{cy-8} Q{cx},{cy-22} {cx+22},{cy-8} Q{cx},{cy-16} {cx-22},{cy-8} Z" fill="{INK}"/>'
    head = (f'<ellipse cx="{cx}" cy="{cy}" rx="22" ry="25" fill="{SKIN}" stroke="{INK}" stroke-width="1.7"/>'
            f'<ellipse cx="{cx-21}" cy="{cy+2}" rx="3.4" ry="5" fill="{SKIN}" stroke="{INK}" stroke-width="1.1"/>'
            f'<ellipse cx="{cx+21}" cy="{cy+2}" rx="3.4" ry="5" fill="{SKIN}" stroke="{INK}" stroke-width="1.1"/>')
    brows = (f'<path d="M{cx-16},{cy-8} Q{cx-9},{cy-12} {cx-3},{cy-8}" fill="none" stroke="{INK}" stroke-width="1.6"/>'
             f'<path d="M{cx+3},{cy-8} Q{cx+9},{cy-12} {cx+16},{cy-8}" fill="none" stroke="{INK}" stroke-width="1.6"/>')
    eyes = (f'<path d="M{cx-16},{cy-2} Q{cx-10},{cy-6} {cx-4},{cy-2} Q{cx-10},{cy+2} {cx-16},{cy-2} Z" fill="#fff" stroke="{INK}" stroke-width="1.1"/>'
            f'<circle cx="{cx-10}" cy="{cy-2}" r="2.1" fill="{INK}"/>'
            f'<path d="M{cx+4},{cy-2} Q{cx+10},{cy-6} {cx+16},{cy-2} Q{cx+10},{cy+2} {cx+4},{cy-2} Z" fill="#fff" stroke="{INK}" stroke-width="1.1"/>'
            f'<circle cx="{cx+10}" cy="{cy-2}" r="2.1" fill="{INK}"/>')
    nose = f'<path d="M{cx},{cy-2} L{cx-3},{cy+10} Q{cx},{cy+13} {cx+3},{cy+10}" fill="none" stroke="{INK}" stroke-width="1.4"/>'
    if beard:
        mouth = (f'<path d="M{cx-13},{cy+14} Q{cx},{cy+19} {cx+13},{cy+14} Q{cx+11},{cy+17} {cx},{cy+18} Q{cx-11},{cy+17} {cx-13},{cy+14} Z" fill="{INK}"/>'
                 f'<path d="M{cx-15},{cy+17} Q{cx-11},{cy+46} {cx},{cy+53} Q{cx+11},{cy+46} {cx+15},{cy+17} '
                 f'Q{cx+11},{cy+30} {cx},{cy+32} Q{cx-11},{cy+30} {cx-15},{cy+17} Z" fill="{INK}"/>')
    else:
        mouth = f'<path d="M{cx-7},{cy+15} Q{cx},{cy+18} {cx+7},{cy+15}" fill="none" stroke="#9a3b2a" stroke-width="1.6"/>'
    blush = (f'<ellipse cx="{cx-14}" cy="{cy+8}" rx="3.6" ry="2.4" fill="#b0271c" opacity="0.22"/>'
             f'<ellipse cx="{cx+14}" cy="{cy+8}" rx="3.6" ry="2.4" fill="#b0271c" opacity="0.22"/>')
    return locks + head + brows + eyes + nose + blush + mouth


def _crown(cx, top, cross=True):
    spire = (f'<rect x="{cx-4}" y="{top-16}" width="8" height="12" fill="{GOLD}" stroke="{INK}" stroke-width="1.2"/>'
             f'<rect x="{cx-9}" y="{top-12}" width="18" height="6" fill="{GOLD}" stroke="{INK}" stroke-width="1.2"/>') if cross else \
            f'<circle cx="{cx}" cy="{top-6}" r="4" fill="{GOLD}" stroke="{INK}" stroke-width="1.2"/>'
    return (f'<path d="M{cx-28},{top+32} L{cx-23},{top} L{cx-9},{top+24} L{cx},{top-6} '
            f'L{cx+9},{top+24} L{cx+23},{top} L{cx+28},{top+32} Z" fill="{GOLD}" stroke="{INK}" stroke-width="1.8"/>'
            f'<rect x="{cx-30}" y="{top+28}" width="60" height="13" rx="3" fill="{GOLD}" stroke="{INK}" stroke-width="1.6"/>'
            f'{spire}'
            f'<g stroke="{INK}" stroke-width="1">'
            f'<circle cx="{cx-23}" cy="{top}" r="3" fill="#b0271c"/><circle cx="{cx}" cy="{top-6 if not cross else top-2}" r="3.2" fill="#2f5b9c"/><circle cx="{cx+23}" cy="{top}" r="3" fill="#b0271c"/>'
            f'<circle cx="{cx-14}" cy="{top+34}" r="2.4" fill="#b0271c"/><circle cx="{cx}" cy="{top+34}" r="2.6" fill="#2e7d4f"/><circle cx="{cx+14}" cy="{top+34}" r="2.4" fill="#2f5b9c"/></g>')


def _cap(cx, top, acc):
    return (f'<path d="M{cx-26},{top+30} Q{cx-28},{top} {cx},{top-2} Q{cx+28},{top} {cx+26},{top+30} '
            f'Q{cx},{top+18} {cx-26},{top+30} Z" fill="{acc}" stroke="{INK}" stroke-width="1.7"/>'
            f'<rect x="{cx-27}" y="{top+26}" width="54" height="9" rx="3" fill="{lt(acc,0.25)}" stroke="{INK}" stroke-width="1.3"/>'
            f'<path d="M{cx+22},{top+18} Q{cx+48},{top+2} {cx+54},{top-22} Q{cx+40},{top+8} {cx+24},{top+12} Z" fill="{GOLD}" stroke="{INK}" stroke-width="1.2"/>')


def _robe(acc, x0=70, x1=180):
    return f'''
    <path d="M{x0},300 L{x0+4},210 Q{x0+10},176 {x0+34},166 L{x1-34},166 Q{x1-10},176 {x1-4},210 L{x1},300 Z"
          fill="{acc}" stroke="{INK}" stroke-width="2"/>
    <g stroke="{INK}" stroke-width="1" opacity="0.4" fill="none">
      <path d="M104,182 Q100,242 96,298"/><path d="M125,178 L125,298"/><path d="M146,182 Q150,242 154,298"/>
      <path d="M86,212 Q84,256 82,298"/><path d="M164,212 Q166,256 168,298"/>
    </g>'''


def _placket():
    spots = "".join(
        f'<g transform="translate(122 {y})"><path d="M0,0 l3,0 -1.5,4 z" fill="{INK}"/>'
        f'<circle cx="-2" cy="-1" r="0.8" fill="{INK}"/><circle cx="5" cy="-1" r="0.8" fill="{INK}"/></g>'
        for y in (196, 222, 248, 274))
    return f'<path d="M116,168 L134,168 L138,300 L112,300 Z" fill="{ERMINE}" stroke="{INK}" stroke-width="1.4"/>{spots}'


def _collar():
    return f'<path d="M92,176 Q125,158 158,176 Q150,192 125,186 Q100,192 92,176 Z" fill="{ERMINE}" stroke="{INK}" stroke-width="1.6"/>'


def _throne():
    return (f'<path d="M62,150 Q62,96 125,92 Q188,96 188,150 L188,300 L62,300 Z" fill="#f3ead2" stroke="{GOLD_D}" stroke-width="2"/>'
            f'<path d="M70,150 Q70,104 125,100 Q180,104 180,150" fill="none" stroke="{GOLD}" stroke-width="2.5"/>')


def _held(suit, x, y, scale, rot=0):
    r = f' rotate({rot})' if rot else ''
    return f'<g transform="translate({x} {y}) scale({scale}){r}">{GLYPH[suit](SUIT_COLOR[suit])}</g>'


def court_king(suit, throne):
    acc = ROBE_COLOR[suit]
    base = _throne() if throne else ''
    return f'''{base}
    {_robe(acc)}{_placket()}{_collar()}
    <path d="M74,200 Q60,212 64,250 Q72,246 80,232 Q78,214 90,200 Z" fill="{acc}" stroke="{INK}" stroke-width="1.6"/>
    <ellipse cx="68" cy="250" rx="9" ry="10" fill="{SKIN}" stroke="{INK}" stroke-width="1.4"/>
    {_held(suit, 64, 226, 1.4, -10)}
    <path d="M176,200 Q190,212 186,250 Q178,246 170,232 Q172,214 160,200 Z" fill="{acc}" stroke="{INK}" stroke-width="1.6"/>
    <ellipse cx="182" cy="250" rx="9" ry="10" fill="{SKIN}" stroke="{INK}" stroke-width="1.4"/>
    <circle cx="186" cy="238" r="9" fill="{GOLD}" stroke="{INK}" stroke-width="1.4"/>
    <path d="M186,229 L186,247 M177,238 L195,238" stroke="{GOLD_D}" stroke-width="1.4"/>
    <rect x="116" y="146" width="18" height="22" rx="3" fill="{SKIN}" stroke="{INK}" stroke-width="1.4"/>
    {_face(125, 120, beard=True)}{_crown(125, 72, cross=True)}'''


def court_queen(suit, throne):
    acc = ROBE_COLOR[suit]
    base = _throne() if throne else ''
    return f'''{base}
    {_robe(acc)}{_placket()}{_collar()}
    <path d="M74,200 Q60,212 64,250 Q72,246 80,232 Q78,214 90,200 Z" fill="{acc}" stroke="{INK}" stroke-width="1.6"/>
    <ellipse cx="68" cy="250" rx="9" ry="10" fill="{SKIN}" stroke="{INK}" stroke-width="1.4"/>
    <line x1="64" y1="250" x2="64" y2="206" stroke="#3f8a4f" stroke-width="3"/>
    <path d="M64,206 Q54,212 58,222 Q64,214 64,224 Q64,214 70,222 Q74,212 64,206 Z" fill="{GOLD}" stroke="{INK}" stroke-width="1.2"/>
    <path d="M176,200 Q190,212 186,250 Q178,246 170,232 Q172,214 160,200 Z" fill="{acc}" stroke="{INK}" stroke-width="1.6"/>
    <ellipse cx="182" cy="250" rx="9" ry="10" fill="{SKIN}" stroke="{INK}" stroke-width="1.4"/>
    {_held(suit, 186, 232, 1.25, 8)}
    <rect x="116" y="148" width="18" height="20" rx="3" fill="{SKIN}" stroke="{INK}" stroke-width="1.4"/>
    {_face(125, 122, beard=False, queen=True)}{_crown(125, 82, cross=False)}'''


def court_jack(suit, throne):
    acc = ROBE_COLOR[suit]
    base = _throne() if throne else ''
    return f'''{base}
    <path d="M86,300 L92,210 Q98,178 120,170 L130,170 Q152,178 158,210 L164,300 Z" fill="{acc}" stroke="{INK}" stroke-width="2"/>
    <g stroke="{INK}" stroke-width="1" opacity="0.4" fill="none"><path d="M112,184 Q108,242 104,298"/><path d="M138,184 Q142,242 146,298"/><path d="M125,180 L125,298"/></g>
    <rect x="92" y="226" width="66" height="10" rx="3" fill="{GOLD}" stroke="{INK}" stroke-width="1.3"/>
    <path d="M120,170 Q108,210 96,236 L108,242 Q118,212 130,184 Z" fill="{acc}" stroke="{INK}" stroke-width="1.6"/>
    <ellipse cx="100" cy="240" rx="8.5" ry="9.5" fill="{SKIN}" stroke="{INK}" stroke-width="1.4"/>
    {_held(suit, 98, 208, 1.3, 8)}
    <path d="M150,176 Q166,188 168,232 Q160,228 150,216 Q150,196 138,184 Z" fill="{acc}" stroke="{INK}" stroke-width="1.6"/>
    <ellipse cx="160" cy="230" rx="8" ry="9" fill="{SKIN}" stroke="{INK}" stroke-width="1.4"/>
    <path d="M104,176 Q125,166 146,176 Q125,184 104,176 Z" fill="{ERMINE}" stroke="{INK}" stroke-width="1.4"/>
    <rect x="117" y="150" width="16" height="20" rx="3" fill="{SKIN}" stroke="{INK}" stroke-width="1.4"/>
    {_face(125, 126, beard=False)}{_cap(125, 100, acc)}'''


COURT_FN = {"king": court_king, "queen": court_queen, "jack": court_jack}


def court_simple(suit, court):
    c = SUIT_COLOR[suit]; label = RANK_LABEL[court]; rule = lt(c, 0.55)
    return f'''
    {suit_watermark(suit)}
    <line x1="74" y1="96" x2="176" y2="96" stroke="{rule}" stroke-width="2"/>
    <line x1="74" y1="260" x2="176" y2="260" stroke="{rule}" stroke-width="2"/>
    <text x="125" y="178" font-family="'DejaVu Sans','Helvetica',sans-serif" font-weight="bold" font-size="132"
          fill="{c}" text-anchor="middle" dominant-baseline="central">{label}</text>'''


# --------------------------------------------------------------------------
# Assembly
# --------------------------------------------------------------------------

def _svg(defs, body):
    d = f'<defs>{defs}</defs>' if defs else ''
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{CARD_W}" height="{CARD_H}" '
            f'viewBox="0 0 {CARD_W} {CARD_H}">{d}{body}</svg>')


def card_french(suit, rank):
    if rank in COURTS:
        body = frame_french(suit) + COURT_FN[rank](suit, throne=True)
    else:
        n = 1 if rank == "ace" else int(rank)
        body = frame_french(suit) + pip_field(suit, n)
    idx = indices(suit, RANK_LABEL.get(rank, rank), "Georgia,'Times New Roman',serif", size=30, gap=20, mini=0.42)
    return _svg(IVORY_DEFS, body + idx)


def card_modern_faces(suit, rank):
    if rank in COURTS:
        body = frame_modern() + COURT_FN[rank](suit, throne=False)
    else:
        n = 1 if rank == "ace" else int(rank)
        body = frame_modern() + pip_field(suit, n)
    idx = indices(suit, RANK_LABEL.get(rank, rank), "'DejaVu Sans','Helvetica',sans-serif", size=29, gap=19, mini=0.40)
    return _svg('', body + idx)


def card_modern_simple(suit, rank):
    if rank in COURTS:
        body = frame_modern() + court_simple(suit, rank)
    else:
        n = 1 if rank == "ace" else int(rank)
        body = frame_modern() + pip_field(suit, n)
    idx = indices(suit, RANK_LABEL.get(rank, rank), "'DejaVu Sans','Helvetica',sans-serif", size=29, gap=19, mini=0.40)
    return _svg('', body + idx)


STYLES = {"french": card_french, "modern-faces": card_modern_faces, "modern-simple": card_modern_simple}


def write_style(style, outdir):
    os.makedirs(outdir, exist_ok=True)
    count = 0
    for suit in SUITS:
        for rank in RANKS:
            with open(os.path.join(outdir, f"{rank}_of_{suit}.svg"), "w") as fh:
                fh.write(STYLES[style](suit, rank))
            count += 1
    return count


if __name__ == "__main__":
    import sys
    base = sys.argv[1] if len(sys.argv) > 1 else "data/cards"
    for style in STYLES:
        n = write_style(style, os.path.join(base, style))
        print(f"wrote {n} cards to {os.path.join(base, style)}")

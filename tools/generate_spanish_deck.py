#!/usr/bin/env python3
"""
Hand-crafted Spanish deck (baraja española) as true vector SVG, drawn in a
traditional woodcut / engraving style: warm parchment stock, suit-coloured
frame with "pintas", layered metallic suit emblems on the pip cards, and
ink-outlined court figures (Sota, Caballo, Rey) with ornate costume detail.

Suits (palos): oros, copas, espadas, bastos.
Ranks: 1 (As) .. 9, plus Sota (10), Caballo (11), Rey (12).

Filenames map to the app (see Game.get_svg_name):
    clubs -> bastos   diamonds -> oros   hearts -> copas   spades -> espadas
    ace=1  queen=Sota(10)  jack=Caballo(11)  king=Rey(12)
"""
import math, os

CARD_W, CARD_H = 250, 350

SUIT_FILE = {"diamonds": "oros", "hearts": "copas", "spades": "espadas", "clubs": "bastos"}
ACCENT = {"oros": "#b07d12", "copas": "#b0271c", "espadas": "#2f5b9c", "bastos": "#2f7d4f"}
PINTAS = {"oros": 0, "copas": 1, "espadas": 2, "bastos": 3}

NUMBER_FILES = ["ace", "2", "3", "4", "5", "6", "7", "8", "9"]
COURT = {"queen": ("Sota", 10), "jack": ("Caballo", 11), "king": ("Rey", 12)}

INK = "#2b2117"
SKIN = "#e8b88a"; SKIN_SH = "#c99064"
GOLD = "#e3b53a"; GOLD_D = "#a87f1e"
ERMINE = "#f4efe2"
HORSE = "#efe7d4"; HORSE_SH = "#cdc2a6"


def _shade(hexc, f):
    h = hexc.lstrip('#'); r, g, b = (int(h[i:i + 2], 16) for i in (0, 2, 4))
    if f < 0:
        f = 1 + f; return '#%02x%02x%02x' % (int(r * f), int(g * f), int(b * f))
    return '#%02x%02x%02x' % (int(r + (255 - r) * f), int(g + (255 - g) * f), int(b + (255 - b) * f))

def darken(hexc, f=0.7):  return _shade(hexc, -(1 - f))
def lighten(hexc, f=0.4): return _shade(hexc, f)


# --------------------------------------------------------------------------
# Suit glyphs — centred at (0,0); callers scale/translate.
# --------------------------------------------------------------------------

def g_oros(p):
    dots = "".join(
        f'<circle cx="{42 * math.cos(a * math.pi / 6):.2f}" cy="{42 * math.sin(a * math.pi / 6):.2f}" r="1.7"/>'
        for a in range(12))
    rays = "".join(
        f'<line x1="{11 * math.cos(a * math.pi / 4):.2f}" y1="{11 * math.sin(a * math.pi / 4):.2f}" '
        f'x2="{18 * math.cos(a * math.pi / 4):.2f}" y2="{18 * math.sin(a * math.pi / 4):.2f}"/>'
        for a in range(8))
    return f'''<g>
      <circle r="47" fill="url(#oroGrad{p})" stroke="#8a6414" stroke-width="2.5"/>
      <circle r="47" fill="none" stroke="#fff3c4" stroke-width="1.4" opacity="0.6"/>
      <circle r="36" fill="none" stroke="#a9781a" stroke-width="2"/>
      <g fill="#9c6f17">{dots}</g>
      <circle r="21" fill="url(#oroCore{p})" stroke="#a9781a" stroke-width="1.5"/>
      <g stroke="#b9831a" stroke-width="2" stroke-linecap="round">{rays}</g>
    </g>'''

def g_copas(p):
    return f'''<g>
      <ellipse cx="0" cy="50" rx="24" ry="6" fill="#7a4a12" opacity="0.30"/>
      <path d="M-30,-34 Q-30,8 0,16 Q30,8 30,-34 Z" fill="url(#copaBowl{p})" stroke="#8a3b22" stroke-width="2"/>
      <path d="M-30,-34 Q0,-22 30,-34 L30,-25 Q0,-13 -30,-25 Z" fill="#b0271c" stroke="#8a3b22" stroke-width="1.4"/>
      <ellipse cx="0" cy="-34" rx="30" ry="8" fill="#ecc25a" stroke="#8a6414" stroke-width="1.5"/>
      <circle cx="0" cy="-44" r="5" fill="#ecc25a" stroke="#8a6414" stroke-width="1.2"/>
      <rect x="-4.5" y="16" width="9" height="20" fill="url(#copaStem{p})" stroke="#8a6414" stroke-width="1"/>
      <ellipse cx="0" cy="22" rx="9" ry="4.5" fill="#ecc25a" stroke="#8a6414" stroke-width="1.1"/>
      <path d="M-24,46 Q0,34 24,46 Q0,40 -24,46 Z M-24,46 Q0,52 24,46" fill="url(#copaFoot{p})" stroke="#8a6414" stroke-width="1.5"/>
    </g>'''

def g_espadas(p):
    return f'''<g>
      <path d="M0,-54 L7,-30 L6,34 L0,40 L-6,34 L-7,-30 Z" fill="url(#blade{p})" stroke="#5b6b7a" stroke-width="1.4"/>
      <line x1="0" y1="-46" x2="0" y2="32" stroke="#ffffff" stroke-width="1.2" opacity="0.5"/>
      <rect x="-22" y="34" width="44" height="8" rx="3" fill="url(#guard{p})" stroke="#7a5a10" stroke-width="1.2"/>
      <circle cx="-22" cy="38" r="5" fill="#eac84e" stroke="#7a5a10" stroke-width="1"/>
      <circle cx="22" cy="38" r="5" fill="#eac84e" stroke="#7a5a10" stroke-width="1"/>
      <rect x="-5" y="42" width="10" height="22" rx="3" fill="url(#grip{p})" stroke="#3a2a14" stroke-width="1.2"/>
      <g stroke="#2a1d0e" stroke-width="1.1"><line x1="-5" y1="48" x2="5" y2="46"/><line x1="-5" y1="54" x2="5" y2="52"/><line x1="-5" y1="60" x2="5" y2="58"/></g>
      <circle cx="0" cy="68" r="6.5" fill="url(#pommel{p})" stroke="#7a5a10" stroke-width="1.2"/>
    </g>'''

def g_bastos(p):
    return f'''<g>
      <path d="M-9,-50 Q-15,-46 -13,-30 L-7,38 Q-9,52 0,54 Q9,52 7,38 L13,-30 Q15,-46 9,-50 Q0,-56 -9,-50 Z"
            fill="url(#wood{p})" stroke="#5a3a18" stroke-width="2"/>
      <path d="M11,-22 Q25,-30 30,-18 Q21,-19 13,-9 Z" fill="url(#wood{p})" stroke="#5a3a18" stroke-width="1.6"/>
      <ellipse cx="28" cy="-20" rx="3.4" ry="2.6" fill="#caa066"/>
      <path d="M-12,0 Q-27,-3 -32,10 Q-22,7 -11,13 Z" fill="url(#wood{p})" stroke="#5a3a18" stroke-width="1.6"/>
      <ellipse cx="-30" cy="9" rx="3.4" ry="2.6" fill="#caa066"/>
      <g fill="#6a4420"><ellipse cx="-1" cy="-34" rx="3.6" ry="4.6"/><ellipse cx="4" cy="-6" rx="3.6" ry="4.6"/><ellipse cx="-4" cy="22" rx="3.6" ry="4.6"/></g>
      <path d="M-4,-48 Q-6,-20 -2,40" fill="none" stroke="#caa066" stroke-width="1.6" opacity="0.55"/>
    </g>'''

GLYPH = {"oros": g_oros, "copas": g_copas, "espadas": g_espadas, "bastos": g_bastos}


def gradients(p):
    return f'''
    <radialGradient id="oroGrad{p}" cx="40%" cy="35%" r="75%"><stop offset="0%" stop-color="#fdeaa0"/><stop offset="55%" stop-color="#e9c34e"/><stop offset="100%" stop-color="#c2941f"/></radialGradient>
    <radialGradient id="oroCore{p}" cx="40%" cy="35%" r="80%"><stop offset="0%" stop-color="#fdeaa0"/><stop offset="100%" stop-color="#d9ad33"/></radialGradient>
    <linearGradient id="copaBowl{p}" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#f0c45e"/><stop offset="100%" stop-color="#c2901f"/></linearGradient>
    <linearGradient id="copaStem{p}" x1="0" y1="0" x2="1" y2="0"><stop offset="0%" stop-color="#ecc25a"/><stop offset="100%" stop-color="#b8881c"/></linearGradient>
    <linearGradient id="copaFoot{p}" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#f0c45e"/><stop offset="100%" stop-color="#b8881c"/></linearGradient>
    <linearGradient id="blade{p}" x1="0" y1="0" x2="1" y2="0"><stop offset="0%" stop-color="#9fb2c4"/><stop offset="50%" stop-color="#e8eef4"/><stop offset="100%" stop-color="#7f93a6"/></linearGradient>
    <linearGradient id="guard{p}" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#f0d36a"/><stop offset="100%" stop-color="#b8881c"/></linearGradient>
    <linearGradient id="grip{p}" x1="0" y1="0" x2="1" y2="0"><stop offset="0%" stop-color="#6a4a24"/><stop offset="100%" stop-color="#3a260f"/></linearGradient>
    <radialGradient id="pommel{p}" cx="40%" cy="35%" r="75%"><stop offset="0%" stop-color="#f0d36a"/><stop offset="100%" stop-color="#b8881c"/></radialGradient>
    <linearGradient id="wood{p}" x1="0" y1="0" x2="1" y2="0"><stop offset="0%" stop-color="#b98a4e"/><stop offset="45%" stop-color="#9c6b2f"/><stop offset="100%" stop-color="#6e4720"/></linearGradient>'''


PARCH = '''
    <linearGradient id="parch" x1="0" y1="0" x2="0.3" y2="1"><stop offset="0%" stop-color="#fbf5e3"/><stop offset="100%" stop-color="#efe2c4"/></linearGradient>
    <radialGradient id="parchGlow" cx="50%" cy="42%" r="70%"><stop offset="0%" stop-color="#fffdf3" stop-opacity="0.6"/><stop offset="100%" stop-color="#fffdf3" stop-opacity="0"/></radialGradient>'''


# --------------------------------------------------------------------------
# Frame + indices + pintas
# --------------------------------------------------------------------------
CX, CY, HX, HY = 125, 178, 72, 118

def layout(n):
    L, R = -0.62, 0.62
    return {
        1: [(0, 0)],
        2: [(0, -0.66), (0, 0.66)],
        3: [(0, -0.82), (0, 0), (0, 0.82)],
        4: [(L, -0.7), (R, -0.7), (L, 0.7), (R, 0.7)],
        5: [(L, -0.78), (R, -0.78), (0, 0), (L, 0.78), (R, 0.78)],
        6: [(L, -0.82), (R, -0.82), (L, 0), (R, 0), (L, 0.82), (R, 0.82)],
        7: [(L, -0.85), (R, -0.85), (0, -0.42), (L, 0.05), (R, 0.05), (L, 0.85), (R, 0.85)],
        8: [(L, -0.85), (R, -0.85), (L, -0.28), (R, -0.28), (L, 0.28), (R, 0.28), (L, 0.85), (R, 0.85)],
        9: [(L, -0.85), (R, -0.85), (L, -0.28), (R, -0.28), (0, 0), (L, 0.85), (R, 0.85), (L, 0.28), (R, 0.28)],
    }.get(n, [(0, 0)])

PIP_SCALE = {1: 1.30, 2: 0.86, 3: 0.82, 4: 0.70, 5: 0.64, 6: 0.60, 7: 0.56, 8: 0.50, 9: 0.48}
ACE_BOOST = {"espadas": 1.18, "bastos": 1.12, "oros": 1.0, "copas": 1.0}


def pinta_marks(palo):
    n = PINTAS[palo]
    if n == 0:
        return ''
    acc = ACCENT[palo]
    span = 13 * (n - 1)
    out = []
    for i in range(n):
        dx = -span / 2 + i * 13
        for cy in (19, CARD_H - 19):
            out.append(f'<path transform="translate({CX + dx} {cy}) rotate(45)" d="M-2.6,-2.6 h5.2 v5.2 h-5.2 Z" fill="{acc}"/>')
    return "".join(out)


def frame(palo):
    acc = ACCENT[palo]
    return f'''
    <rect x="2.5" y="2.5" width="{CARD_W - 5}" height="{CARD_H - 5}" rx="17" fill="url(#parch)" stroke="#cbb98a" stroke-width="2"/>
    <rect x="2.5" y="2.5" width="{CARD_W - 5}" height="{CARD_H - 5}" rx="17" fill="url(#parchGlow)"/>
    <rect x="11" y="11" width="{CARD_W - 22}" height="{CARD_H - 22}" rx="12" fill="none" stroke="{acc}" stroke-width="2.6"/>
    <rect x="16" y="16" width="{CARD_W - 32}" height="{CARD_H - 32}" rx="8.5" fill="none" stroke="{acc}" stroke-width="1" opacity="0.5"/>
    {pinta_marks(palo)}'''


def index(palo, label):
    acc = ACCENT[palo]
    mini = f'<g transform="scale(0.21)">{GLYPH[palo](str(palo[0]) + "i")}</g>'
    one = (f'<g transform="translate(31 41)">'
           f'<text x="0" y="0" font-family="Georgia,serif" font-weight="bold" font-size="31" '
           f'fill="{acc}" text-anchor="middle">{label}</text>'
           f'<g transform="translate(0 23)">{mini}</g></g>')
    other = (f'<g transform="translate({CARD_W - 31} {CARD_H - 41}) rotate(180)">'
             f'<text x="0" y="0" font-family="Georgia,serif" font-weight="bold" font-size="31" '
             f'fill="{acc}" text-anchor="middle">{label}</text>'
             f'<g transform="translate(0 23)">{mini}</g></g>')
    return one + other


def held(palo, p, x, y, scale, rot=0):
    r = f' rotate({rot})' if rot else ''
    return f'<g transform="translate({x} {y}) scale({scale}){r}">{GLYPH[palo](str(p) + "h")}</g>'


def number_card(palo, rank_label, n):
    p = palo[0]
    woven = palo in ("espadas", "bastos")
    pts = layout(n)
    scale = PIP_SCALE[n] * (ACE_BOOST[palo] if n == 1 else 1.0)
    body = []
    for i, (nx, ny) in enumerate(pts):
        tilt = 0
        if woven and n > 1:
            tilt = 16 if (nx < 0 or (nx == 0 and i % 2 == 0)) else -16
        x = CX + nx * HX; y = CY + ny * HY
        rot = f' rotate({tilt})' if tilt else ''
        body.append(f'<g transform="translate({x:.1f} {y:.1f}) scale({scale:.3f}){rot}">{GLYPH[palo](p)}</g>')
    inner = "\n".join(body)
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{CARD_W}" height="{CARD_H}" viewBox="0 0 {CARD_W} {CARD_H}">'
            f'<defs>{PARCH}{gradients(p)}{gradients(str(p) + "i")}</defs>'
            f'{frame(palo)}{inner}{index(palo, rank_label)}</svg>')


# --------------------------------------------------------------------------
# Court figures (woodcut style)
# --------------------------------------------------------------------------

def _face(cx, cy, beard=False, queen=False):
    hair = INK
    locks = (f'<path d="M{cx-26},{cy-4} Q{cx-30},{cy+22} {cx-15},{cy+34} Q{cx-22},{cy+16} {cx-21},{cy-4} Z" fill="{hair}"/>'
             f'<path d="M{cx+26},{cy-4} Q{cx+30},{cy+22} {cx+15},{cy+34} Q{cx+22},{cy+16} {cx+21},{cy-4} Z" fill="{hair}"/>')
    if queen:
        locks += f'<path d="M{cx-22},{cy-8} Q{cx},{cy-22} {cx+22},{cy-8} Q{cx},{cy-16} {cx-22},{cy-8} Z" fill="{hair}"/>'
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
        mouth = f'<path d="M{cx-13},{cy+14} Q{cx},{cy+19} {cx+13},{cy+14} Q{cx+11},{cy+17} {cx},{cy+18} Q{cx-11},{cy+17} {cx-13},{cy+14} Z" fill="{INK}"/>'
        beardp = (f'<path d="M{cx-15},{cy+17} Q{cx-11},{cy+46} {cx},{cy+53} Q{cx+11},{cy+46} {cx+15},{cy+17} '
                  f'Q{cx+11},{cy+30} {cx},{cy+32} Q{cx-11},{cy+30} {cx-15},{cy+17} Z" fill="{INK}"/>')
        mouth += beardp
    else:
        mouth = f'<path d="M{cx-7},{cy+15} Q{cx},{cy+18} {cx+7},{cy+15}" fill="none" stroke="#9a3b2a" stroke-width="1.6"/>'
    blush = (f'<ellipse cx="{cx-14}" cy="{cy+8}" rx="3.6" ry="2.4" fill="#b0271c" opacity="0.22"/>'
             f'<ellipse cx="{cx+14}" cy="{cy+8}" rx="3.6" ry="2.4" fill="#b0271c" opacity="0.22"/>')
    return locks + head + brows + eyes + nose + blush + mouth


def _crown(cx, top):
    return (f'<path d="M{cx-28},{top+32} L{cx-23},{top} L{cx-9},{top+24} L{cx},{top-6} '
            f'L{cx+9},{top+24} L{cx+23},{top} L{cx+28},{top+32} Z" fill="{GOLD}" stroke="{INK}" stroke-width="1.8"/>'
            f'<rect x="{cx-30}" y="{top+28}" width="60" height="13" rx="3" fill="{GOLD}" stroke="{INK}" stroke-width="1.6"/>'
            f'<rect x="{cx-4}" y="{top-16}" width="8" height="12" fill="{GOLD}" stroke="{INK}" stroke-width="1.2"/>'
            f'<rect x="{cx-9}" y="{top-12}" width="18" height="6" fill="{GOLD}" stroke="{INK}" stroke-width="1.2"/>'
            f'<g stroke="{INK}" stroke-width="1">'
            f'<circle cx="{cx-23}" cy="{top}" r="3" fill="#b0271c"/><circle cx="{cx}" cy="{top-6}" r="3.4" fill="#2f5b9c"/><circle cx="{cx+23}" cy="{top}" r="3" fill="#b0271c"/>'
            f'<circle cx="{cx-14}" cy="{top+34}" r="2.4" fill="#b0271c"/><circle cx="{cx}" cy="{top+34}" r="2.6" fill="#2e7d4f"/><circle cx="{cx+14}" cy="{top+34}" r="2.4" fill="#2f5b9c"/></g>')


def _hat(cx, top, acc):
    return (f'<path d="M{cx-26},{top+30} Q{cx-28},{top} {cx},{top-2} Q{cx+28},{top} {cx+26},{top+30} '
            f'Q{cx},{top+18} {cx-26},{top+30} Z" fill="{acc}" stroke="{INK}" stroke-width="1.7"/>'
            f'<rect x="{cx-27}" y="{top+26}" width="54" height="9" rx="3" fill="{lighten(acc,0.25)}" stroke="{INK}" stroke-width="1.3"/>'
            f'<path d="M{cx+22},{top+18} Q{cx+48},{top+2} {cx+54},{top-22} Q{cx+40},{top+8} {cx+24},{top+12} Z" fill="{GOLD}" stroke="{INK}" stroke-width="1.2"/>')


def _robe(acc, x0=70, x1=180, top=166, foldcol=None):
    fold = foldcol or darken(acc, 0.7)
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
    return (f'<path d="M116,168 L134,168 L138,300 L112,300 Z" fill="{ERMINE}" stroke="{INK}" stroke-width="1.4"/>{spots}')


def _collar():
    return f'<path d="M92,176 Q125,158 158,176 Q150,192 125,186 Q100,192 92,176 Z" fill="{ERMINE}" stroke="{INK}" stroke-width="1.6"/>'


def _throne(acc):
    return (f'<path d="M62,150 Q62,96 125,92 Q188,96 188,150 L188,300 L62,300 Z" fill="#f3ead2" stroke="{GOLD_D}" stroke-width="2"/>'
            f'<path d="M70,150 Q70,104 125,100 Q180,104 180,150" fill="none" stroke="{GOLD}" stroke-width="2.5"/>')


def rey(palo, p):
    acc = ACCENT[palo]
    return f'''
    {_throne(acc)}
    {_robe(acc)}
    {_placket()}
    {_collar()}
    <path d="M74,200 Q60,212 64,250 Q72,246 80,232 Q78,214 90,200 Z" fill="{acc}" stroke="{INK}" stroke-width="1.6"/>
    <ellipse cx="68" cy="250" rx="9" ry="10" fill="{SKIN}" stroke="{INK}" stroke-width="1.4"/>
    {held(palo, p, 58, 214, 0.62, -12)}
    <path d="M176,200 Q190,212 186,250 Q178,246 170,232 Q172,214 160,200 Z" fill="{acc}" stroke="{INK}" stroke-width="1.6"/>
    <ellipse cx="182" cy="250" rx="9" ry="10" fill="{SKIN}" stroke="{INK}" stroke-width="1.4"/>
    <circle cx="186" cy="238" r="9" fill="{GOLD}" stroke="{INK}" stroke-width="1.4"/>
    <path d="M186,229 L186,247 M177,238 L195,238" stroke="{GOLD_D}" stroke-width="1.4"/>
    <rect x="116" y="146" width="18" height="22" rx="3" fill="{SKIN}" stroke="{INK}" stroke-width="1.4"/>
    {_face(125, 120, beard=True)}
    {_crown(125, 72)}'''


def sota(palo, p):
    acc = ACCENT[palo]
    return f'''
    {_throne(acc)}
    <path d="M86,300 L92,210 Q98,178 120,170 L130,170 Q152,178 158,210 L164,300 Z" fill="{acc}" stroke="{INK}" stroke-width="2"/>
    <g stroke="{INK}" stroke-width="1" opacity="0.4" fill="none"><path d="M112,184 Q108,242 104,298"/><path d="M138,184 Q142,242 146,298"/><path d="M125,180 L125,298"/></g>
    <rect x="92" y="226" width="66" height="10" rx="3" fill="{GOLD}" stroke="{INK}" stroke-width="1.3"/>
    <circle cx="125" cy="231" r="4" fill="{lighten(acc,0.2)}" stroke="{INK}" stroke-width="1"/>
    <path d="M120,170 Q108,210 96,236 L108,242 Q118,212 130,184 Z" fill="{acc}" stroke="{INK}" stroke-width="1.6"/>
    <ellipse cx="100" cy="240" rx="8.5" ry="9.5" fill="{SKIN}" stroke="{INK}" stroke-width="1.4"/>
    {held(palo, p, 96, 196, 0.6, 8)}
    <path d="M150,176 Q166,188 168,232 Q160,228 150,216 Q150,196 138,184 Z" fill="{acc}" stroke="{INK}" stroke-width="1.6"/>
    <ellipse cx="160" cy="230" rx="8" ry="9" fill="{SKIN}" stroke="{INK}" stroke-width="1.4"/>
    <path d="M104,176 Q125,166 146,176 Q125,184 104,176 Z" fill="{ERMINE}" stroke="{INK}" stroke-width="1.4"/>
    <rect x="117" y="150" width="16" height="20" rx="3" fill="{SKIN}" stroke="{INK}" stroke-width="1.4"/>
    {_face(125, 126, beard=False)}
    {_hat(125, 100, acc)}'''


def caballo(palo, p):
    acc = ACCENT[palo]
    return f'''
    <ellipse cx="124" cy="298" rx="84" ry="7" fill="#000" opacity="0.10"/>
    <!-- horse body -->
    <path d="M58,236 Q56,196 96,186 Q150,178 176,196 Q196,210 192,250 L178,250 Q180,220 168,212
             Q120,198 92,210 Q74,220 74,248 Z" fill="{HORSE}" stroke="{INK}" stroke-width="1.8"/>
    <!-- legs -->
    <g fill="{HORSE}" stroke="{INK}" stroke-width="1.5">
      <path d="M80,244 L76,292 L86,292 L90,246 Z"/><path d="M104,248 L100,292 L110,292 L114,250 Z"/>
      <path d="M156,248 L160,292 L170,292 L164,250 Z"/><path d="M176,244 L184,290 L194,290 L186,246 Z"/>
    </g>
    <g fill="{INK}"><rect x="74" y="289" width="14" height="5" rx="1.5"/><rect x="99" y="289" width="14" height="5" rx="1.5"/>
       <rect x="158" y="289" width="14" height="5" rx="1.5"/><rect x="183" y="289" width="14" height="5" rx="1.5"/></g>
    <!-- neck + head -->
    <path d="M58,236 Q40,214 36,188 Q34,174 44,172 Q54,190 76,206 Q84,214 80,232 Z" fill="{HORSE}" stroke="{INK}" stroke-width="1.8"/>
    <path d="M44,174 Q30,170 24,182 Q20,192 28,196 Q38,198 46,190 Q52,182 52,174 Z" fill="{HORSE}" stroke="{INK}" stroke-width="1.6"/>
    <path d="M24,182 Q17,187 19,194 L28,193 Q27,186 32,183 Z" fill="{HORSE_SH}" stroke="{INK}" stroke-width="1.1"/>
    <path d="M46,166 L42,154 L54,164 Z" fill="{HORSE}" stroke="{INK}" stroke-width="1.2"/>
    <path d="M55,166 L53,153 L65,166 Z" fill="{HORSE}" stroke="{INK}" stroke-width="1.2"/>
    <circle cx="40" cy="184" r="2.2" fill="{INK}"/>
    <!-- mane + tail -->
    <path d="M52,166 Q66,176 74,202 Q66,196 58,202 Q56,182 46,170 Z" fill="{INK}" opacity="0.85"/>
    <path d="M190,206 Q210,214 208,256 Q200,236 192,240 Q196,222 184,212 Z" fill="{INK}" opacity="0.85"/>
    <!-- saddle blanket -->
    <path d="M88,206 Q124,220 162,206 L168,224 Q124,238 84,224 Z" fill="{acc}" stroke="{INK}" stroke-width="1.5"/>
    <path d="M86,214 L166,214" stroke="{GOLD}" stroke-width="2"/>
    <!-- reins -->
    <path d="M46,178 Q90,156 116,176" fill="none" stroke="{INK}" stroke-width="1.8"/>
    <!-- rider held emblem -->
    {held(palo, p, 178, 120, 0.5, 6)}
    <!-- rider torso -->
    <path d="M104,200 Q98,172 110,158 L132,158 Q146,172 140,202 Q122,212 104,200 Z" fill="{acc}" stroke="{INK}" stroke-width="1.8"/>
    <g stroke="{INK}" stroke-width="0.9" opacity="0.4" fill="none"><path d="M122,162 L120,200"/></g>
    <rect x="103" y="194" width="38" height="8" rx="2" fill="{GOLD}" stroke="{INK}" stroke-width="1.2"/>
    <!-- raised arm to emblem -->
    <path d="M134,176 Q156,150 172,132 L164,124 Q146,142 122,168 Z" fill="{acc}" stroke="{INK}" stroke-width="1.6"/>
    <ellipse cx="170" cy="130" rx="7.5" ry="8.5" fill="{SKIN}" stroke="{INK}" stroke-width="1.3"/>
    <!-- leg over horse -->
    <path d="M106,196 Q96,214 96,236 L108,236 Q108,214 118,202 Z" fill="{acc}" stroke="{INK}" stroke-width="1.6"/>
    <path d="M104,232 L98,246 L112,246 L114,234 Z" fill="#6a4a24" stroke="{INK}" stroke-width="1.3"/>
    <rect x="116" y="146" width="16" height="16" rx="3" fill="{SKIN}" stroke="{INK}" stroke-width="1.3"/>
    {_face(124, 124, beard=False)}
    {_hat(124, 100, acc)}'''


FIGURE = {"queen": sota, "jack": caballo, "king": rey}


def court_card(palo, court_file, label):
    p = palo[0]
    fig = FIGURE[court_file](palo, p)
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{CARD_W}" height="{CARD_H}" viewBox="0 0 {CARD_W} {CARD_H}">'
            f'<defs>{PARCH}{gradients(p)}{gradients(str(p) + "i")}{gradients(str(p) + "h")}</defs>'
            f'{frame(palo)}{fig}{index(palo, label)}</svg>')


# --------------------------------------------------------------------------
def build_card(fsuit, vfile):
    palo = SUIT_FILE[fsuit]
    if vfile in COURT:
        _, num = COURT[vfile]
        return court_card(palo, vfile, str(num))
    label = "1" if vfile == "ace" else vfile
    n = 1 if vfile == "ace" else int(vfile)
    return number_card(palo, label, n)


ALL_VALUES = NUMBER_FILES + list(COURT.keys())


def write_deck(outdir):
    os.makedirs(outdir, exist_ok=True)
    count = 0
    for fsuit in SUIT_FILE:
        for vfile in ALL_VALUES:
            with open(os.path.join(outdir, f"{vfile}_of_{fsuit}.svg"), "w") as fh:
                fh.write(build_card(fsuit, vfile))
            count += 1
    return count


if __name__ == "__main__":
    import sys
    outdir = sys.argv[1] if len(sys.argv) > 1 else "data/cards/spanish"
    print(f"wrote {write_deck(outdir)} cards to {outdir}")

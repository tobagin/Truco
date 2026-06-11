#!/usr/bin/env python3
"""
Generate a hand-crafted Spanish deck (baraja española) as true vector SVG.

Suits (palos): oros, copas, espadas, bastos.
Ranks: 1 (As) .. 9, plus Sota (10), Caballo (11), Rey (12).

Output filenames map to the app's expectations (see Game.get_svg_name):
    clubs   -> bastos       diamonds -> oros
    hearts  -> copas        spades   -> espadas
    ace=1   queen=Sota(10)  jack=Caballo(11)  king=Rey(12)

Cards use a viewBox so they scale crisply at any resolution.
"""
import math, os

CARD_W, CARD_H = 250, 350

# filename suit -> spanish palo
SUIT_FILE = {"diamonds": "oros", "hearts": "copas", "spades": "espadas", "clubs": "bastos"}
# spanish palo -> accent colour (frame, indices)
ACCENT = {"oros": "#b07d12", "copas": "#b0271c", "espadas": "#2f5b9c", "bastos": "#2f7d4f"}

NUMBER_FILES = ["ace", "2", "3", "4", "5", "6", "7", "8", "9"]
COURT = {"queen": ("Sota", 10), "jack": ("Caballo", 11), "king": ("Rey", 12)}

# Figure palette
SKIN = "#f0c9a0"; SKIN_SH = "#d9a878"; HAIR = "#6e4a26"; BEARD = "#7a5630"

def _shade(hexc, f):
    h = hexc.lstrip('#'); r, g, b = (int(h[i:i+2], 16) for i in (0, 2, 4))
    if f < 0:  # darken
        f = 1 + f; return '#%02x%02x%02x' % (int(r*f), int(g*f), int(b*f))
    return '#%02x%02x%02x' % (int(r+(255-r)*f), int(g+(255-g)*f), int(b+(255-b)*f))

def darken(hexc, f=0.7):  return _shade(hexc, -(1-f))
def lighten(hexc, f=0.4): return _shade(hexc, f)


# --------------------------------------------------------------------------
# Suit glyphs — centred at (0,0), ~94 units wide; callers scale/translate.
# --------------------------------------------------------------------------

def g_oros(p):
    dots = "".join(
        f'<circle cx="{42*math.cos(a*math.pi/6):.2f}" cy="{42*math.sin(a*math.pi/6):.2f}" r="1.7"/>'
        for a in range(12))
    rays = "".join(
        f'<line x1="{11*math.cos(a*math.pi/4):.2f}" y1="{11*math.sin(a*math.pi/4):.2f}" '
        f'x2="{18*math.cos(a*math.pi/4):.2f}" y2="{18*math.sin(a*math.pi/4):.2f}"/>'
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
    <linearGradient id="wood{p}" x1="0" y1="0" x2="1" y2="0"><stop offset="0%" stop-color="#b98a4e"/><stop offset="45%" stop-color="#9c6b2f"/><stop offset="100%" stop-color="#6e4720"/></linearGradient>
    <linearGradient id="parch{p}" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#fbf5e3"/><stop offset="100%" stop-color="#efe2c4"/></linearGradient>'''


# --------------------------------------------------------------------------
# Pip layouts (normalised coords in [-1,1]); centre region maps them.
# --------------------------------------------------------------------------
CX, CY, HX, HY = 125, 178, 72, 118

def layout(n):
    L = -0.62; R = 0.62
    if n == 1: return [(0, 0)]
    if n == 2: return [(0, -0.66), (0, 0.66)]
    if n == 3: return [(0, -0.82), (0, 0), (0, 0.82)]
    if n == 4: return [(L, -0.7), (R, -0.7), (L, 0.7), (R, 0.7)]
    if n == 5: return [(L, -0.78), (R, -0.78), (0, 0), (L, 0.78), (R, 0.78)]
    if n == 6: return [(L, -0.82), (R, -0.82), (L, 0), (R, 0), (L, 0.82), (R, 0.82)]
    if n == 7: return [(L, -0.85), (R, -0.85), (0, -0.42), (L, 0.05), (R, 0.05), (L, 0.85), (R, 0.85)]
    if n == 8: return [(L, -0.85), (R, -0.85), (L, -0.28), (R, -0.28), (L, 0.28), (R, 0.28), (L, 0.85), (R, 0.85)]
    if n == 9: return [(L, -0.85), (R, -0.85), (L, -0.28), (R, -0.28), (0, 0), (L, 0.85), (R, 0.85), (L, 0.28), (R, 0.28)]
    return [(0, 0)]

PIP_SCALE = {1: 1.25, 2: 0.82, 3: 0.80, 4: 0.66, 5: 0.62, 6: 0.58, 7: 0.55, 8: 0.50, 9: 0.48}


def pip(palo, p, nx, ny, scale, tilt=0):
    x = CX + nx * HX; y = CY + ny * HY
    rot = f' rotate({tilt})' if tilt else ''
    return f'<g transform="translate({x:.1f} {y:.1f}) scale({scale:.3f}){rot}">{GLYPH[palo](p)}</g>'


# --------------------------------------------------------------------------
# Card frame + corner indices
# --------------------------------------------------------------------------

def frame(palo, p):
    acc = ACCENT[palo]
    return f'''
    <rect x="3" y="3" width="{CARD_W-6}" height="{CARD_H-6}" rx="16" fill="url(#parch{p})" stroke="#cdbb8e" stroke-width="2"/>
    <rect x="12" y="12" width="{CARD_W-24}" height="{CARD_H-24}" rx="11" fill="none" stroke="{acc}" stroke-width="2.4" opacity="0.9"/>
    <rect x="17" y="17" width="{CARD_W-34}" height="{CARD_H-34}" rx="8" fill="none" stroke="{acc}" stroke-width="1" opacity="0.5"/>
    <g fill="{acc}">
      <circle cx="12" cy="12" r="3.2"/><circle cx="{CARD_W-12}" cy="12" r="3.2"/>
      <circle cx="12" cy="{CARD_H-12}" r="3.2"/><circle cx="{CARD_W-12}" cy="{CARD_H-12}" r="3.2"/>
    </g>'''

def index(palo, p, label):
    acc = ACCENT[palo]
    mini = f'<g transform="scale(0.22)">{GLYPH[palo](str(p)+"i")}</g>'
    one = (f'<g transform="translate(30 40)">'
           f'<text x="0" y="0" font-family="Georgia,serif" font-weight="bold" font-size="30" '
           f'fill="{acc}" text-anchor="middle">{label}</text>'
           f'<g transform="translate(0 22)">{mini}</g></g>')
    other = (f'<g transform="translate({CARD_W-30} {CARD_H-40}) rotate(180)">'
             f'<text x="0" y="0" font-family="Georgia,serif" font-weight="bold" font-size="30" '
             f'fill="{acc}" text-anchor="middle">{label}</text>'
             f'<g transform="translate(0 22)">{mini}</g></g>')
    return one + other


def number_card(palo, rank_label, n):
    p = palo[0]
    tiltable = palo in ("espadas", "bastos")
    body = []
    pts = layout(n)
    for i, (nx, ny) in enumerate(pts):
        tilt = (12 if i % 2 == 0 else -12) if (tiltable and n > 1) else 0
        body.append(pip(palo, p, nx, ny, PIP_SCALE[n], tilt))
    inner = "\n".join(body)
    # need mini-glyph gradients too (suffix 'i')
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{CARD_W}" height="{CARD_H}" '
            f'viewBox="0 0 {CARD_W} {CARD_H}">'
            f'<defs>{gradients(p)}{gradients(str(p)+"i")}</defs>'
            f'{frame(palo, p)}{inner}{index(palo, p, rank_label)}</svg>')



# --------------------------------------------------------------------------
# Court figures (Sota = 10, Caballo = 11, Rey = 12)
# --------------------------------------------------------------------------

def figdefs(palo, p):
    acc = ACCENT[palo]
    return f'''
    <linearGradient id="robe{p}" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="{acc}"/><stop offset="100%" stop-color="{darken(acc)}"/></linearGradient>
    <linearGradient id="crown{p}" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#f4dd77"/><stop offset="100%" stop-color="#c79a2e"/></linearGradient>
    <linearGradient id="cap{p}" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="{lighten(acc)}"/><stop offset="100%" stop-color="{acc}"/></linearGradient>
    <linearGradient id="horse{p}" x1="0" y1="0" x2="0" y2="1"><stop offset="0%" stop-color="#efe9dc"/><stop offset="100%" stop-color="#c9c1b0"/></linearGradient>'''

def held_glyph(palo, p, x, y, scale):
    return f'<g transform="translate({x} {y}) scale({scale})">{GLYPH[palo](str(p)+"h")}</g>'

def rey(palo, p):
    acc = ACCENT[palo]
    return f'''
    {held_glyph(palo, p, 182, 150, 0.5)}
    <path d="M84,290 C78,232 92,182 100,168 L150,168 C158,182 172,232 166,290 Z" fill="url(#robe{p})" stroke="#00000033" stroke-width="1.5"/>
    <path d="M118,170 L132,170 L136,290 L114,290 Z" fill="#ffffff" opacity="0.18"/>
    <path d="M125,176 L125,286" stroke="{acc}" stroke-width="2" opacity="0.5"/>
    <g fill="#e9c34e"><circle cx="125" cy="200" r="3"/><circle cx="125" cy="224" r="3"/><circle cx="125" cy="248" r="3"/></g>
    <path d="M100,172 C84,186 80,214 86,240 L100,236 C96,212 100,190 112,180 Z" fill="url(#robe{p})" stroke="#00000022" stroke-width="1"/>
    <path d="M150,172 C168,184 176,206 174,150 L160,150 C160,180 150,184 138,180 Z" fill="url(#robe{p})" stroke="#00000022" stroke-width="1"/>
    <ellipse cx="90" cy="240" rx="8" ry="9" fill="{SKIN}" stroke="{SKIN_SH}" stroke-width="1"/>
    <ellipse cx="172" cy="150" rx="8" ry="9" fill="{SKIN}" stroke="{SKIN_SH}" stroke-width="1"/>
    <path d="M96,168 Q125,150 154,168 Q125,182 96,168 Z" fill="#fbf7ee" stroke="#cbb78a" stroke-width="1.2"/>
    <g fill="#3a3026"><circle cx="110" cy="167" r="1.5"/><circle cx="125" cy="171" r="1.5"/><circle cx="140" cy="167" r="1.5"/></g>
    <rect x="118" y="150" width="14" height="14" fill="{SKIN}"/>
    <ellipse cx="125" cy="128" rx="19" ry="22" fill="{SKIN}" stroke="{SKIN_SH}" stroke-width="1"/>
    <path d="M106,124 Q104,150 116,158 Q110,140 110,126 Z" fill="{HAIR}"/>
    <path d="M144,124 Q146,150 134,158 Q140,140 140,126 Z" fill="{HAIR}"/>
    <path d="M111,138 Q125,176 139,138 Q138,152 125,158 Q112,152 111,138 Z" fill="{BEARD}"/>
    <g fill="#5a4631"><ellipse cx="118" cy="126" rx="2" ry="2.4"/><ellipse cx="132" cy="126" rx="2" ry="2.4"/></g>
    <path d="M125,130 L125,138" stroke="{SKIN_SH}" stroke-width="1.5"/>
    <path d="M119,144 Q125,148 131,144" fill="none" stroke="#a8694a" stroke-width="1.6"/>
    <path d="M112,118 Q118,114 124,118 M126,118 Q132,114 138,118" fill="none" stroke="{HAIR}" stroke-width="1.6"/>
    <path d="M104,108 L108,90 L116,104 L125,86 L134,104 L142,90 L146,108 Z" fill="url(#crown{p})" stroke="#9a7415" stroke-width="1.4"/>
    <rect x="103" y="106" width="44" height="8" rx="3" fill="url(#crown{p})" stroke="#9a7415" stroke-width="1.2"/>
    <g><circle cx="108" cy="90" r="3" fill="#c0392b"/><circle cx="125" cy="86" r="3.4" fill="#2e7d32"/><circle cx="142" cy="90" r="3" fill="#2f5b9c"/>
       <circle cx="116" cy="110" r="2.2" fill="#c0392b"/><circle cx="134" cy="110" r="2.2" fill="#2f5b9c"/></g>'''

def sota(palo, p):
    acc = ACCENT[palo]
    return f'''
    {held_glyph(palo, p, 184, 150, 0.5)}
    <path d="M108,232 L104,288 L120,288 L122,238 Z" fill="#caa46a" stroke="#00000022" stroke-width="1"/>
    <path d="M128,238 L130,288 L146,288 L142,232 Z" fill="#b9925a" stroke="#00000022" stroke-width="1"/>
    <path d="M100,286 L124,286 L124,294 L96,294 Z" fill="#4a3526"/>
    <path d="M126,286 L148,286 L150,294 L124,294 Z" fill="#3e2c1f"/>
    <path d="M92,238 C88,210 92,182 100,170 L150,170 C158,182 162,210 158,238 Q125,250 92,238 Z" fill="url(#robe{p})" stroke="#00000033" stroke-width="1.4"/>
    <rect x="92" y="228" width="66" height="9" rx="3" fill="#7a5a2a"/>
    <rect x="120" y="228" width="10" height="9" rx="2" fill="#e9c34e"/>
    <path d="M125,176 L125,228" stroke="{acc}" stroke-width="1.6" opacity="0.45"/>
    <path d="M98,174 C84,188 82,210 90,232 L102,228 C96,208 100,188 110,180 Z" fill="url(#robe{p})" stroke="#00000022" stroke-width="1"/>
    <path d="M152,174 C168,184 176,204 174,150 L160,150 C160,178 150,184 140,180 Z" fill="url(#robe{p})" stroke="#00000022" stroke-width="1"/>
    <ellipse cx="94" cy="232" rx="7.5" ry="8.5" fill="{SKIN}" stroke="{SKIN_SH}" stroke-width="1"/>
    <ellipse cx="172" cy="150" rx="8" ry="9" fill="{SKIN}" stroke="{SKIN_SH}" stroke-width="1"/>
    <path d="M100,170 Q125,158 150,170 Q125,180 100,170 Z" fill="#fbf7ee" stroke="#cbb78a" stroke-width="1.1"/>
    <rect x="118" y="152" width="14" height="13" fill="{SKIN}"/>
    <ellipse cx="125" cy="132" rx="18" ry="21" fill="{SKIN}" stroke="{SKIN_SH}" stroke-width="1"/>
    <path d="M107,128 Q106,150 117,156 Q112,142 112,130 Z" fill="{HAIR}"/>
    <path d="M143,128 Q144,150 133,156 Q138,142 138,130 Z" fill="{HAIR}"/>
    <g fill="#5a4631"><ellipse cx="119" cy="130" rx="2" ry="2.4"/><ellipse cx="131" cy="130" rx="2" ry="2.4"/></g>
    <path d="M125,134 L125,141" stroke="{SKIN_SH}" stroke-width="1.4"/>
    <path d="M120,147 Q125,150 130,147" fill="none" stroke="#a8694a" stroke-width="1.5"/>
    <ellipse cx="113" cy="140" rx="3" ry="2" fill="#e7a07e" opacity="0.5"/>
    <ellipse cx="137" cy="140" rx="3" ry="2" fill="#e7a07e" opacity="0.5"/>
    <path d="M104,118 Q108,98 125,98 Q146,98 148,116 Q150,122 142,120 Q125,112 110,120 Q103,123 104,118 Z" fill="url(#cap{p})" stroke="#00000033" stroke-width="1.2"/>
    <path d="M146,112 Q166,104 170,86 Q158,96 148,104 Z" fill="#e9c34e" stroke="#9a7415" stroke-width="1"/>
    <rect x="106" y="114" width="40" height="6" rx="3" fill="#7a5a2a"/>'''

def caballo(palo, p):
    return f'''
    <ellipse cx="120" cy="290" rx="78" ry="8" fill="#000000" opacity="0.12"/>
    <path d="M176,196 Q200,210 196,250 Q188,232 182,236 Q188,256 178,268 Q176,236 168,214 Z" fill="#5a4631"/>
    <path d="M150,236 L156,286 L148,286 L144,238 Z" fill="#b8b0a0" stroke="#00000022" stroke-width="1"/>
    <path d="M92,238 L88,286 L96,286 L100,238 Z" fill="#b8b0a0" stroke="#00000022" stroke-width="1"/>
    <ellipse cx="118" cy="216" rx="60" ry="27" fill="url(#horse{p})" stroke="#9a9486" stroke-width="1.4"/>
    <path d="M70,210 Q52,196 46,176 Q44,166 52,164 Q60,178 78,192 Q86,200 84,214 Z" fill="url(#horse{p})" stroke="#9a9486" stroke-width="1.4"/>
    <path d="M52,168 Q40,166 34,176 Q30,184 36,188 Q44,190 50,184 Q56,178 56,170 Z" fill="url(#horse{p})" stroke="#9a9486" stroke-width="1.4"/>
    <path d="M34,176 Q28,180 30,186 L37,186 Q36,180 40,178 Z" fill="#b8b0a0"/>
    <path d="M54,160 L50,150 L60,158 Z" fill="url(#horse{p})" stroke="#9a9486" stroke-width="1"/>
    <path d="M62,160 L60,149 L70,160 Z" fill="url(#horse{p})" stroke="#9a9486" stroke-width="1"/>
    <circle cx="48" cy="174" r="2.2" fill="#2a221a"/>
    <path d="M58,158 Q70,166 76,188 Q70,184 64,190 Q60,176 52,166 Z" fill="#5a4631"/>
    <path d="M104,238 L100,287 L110,287 L112,240 Z" fill="url(#horse{p})" stroke="#9a9486" stroke-width="1.2"/>
    <path d="M158,236 L164,287 L174,287 L168,238 Z" fill="url(#horse{p})" stroke="#9a9486" stroke-width="1.2"/>
    <g fill="#2f2417"><rect x="99" y="284" width="13" height="6" rx="2"/><rect x="162" y="284" width="14" height="6" rx="2"/>
       <rect x="86" y="283" width="12" height="6" rx="2"/><rect x="145" y="283" width="12" height="6" rx="2"/></g>
    <path d="M92,198 Q120,210 150,198 L154,214 Q120,226 88,214 Z" fill="url(#robe{p})" stroke="#00000033" stroke-width="1"/>
    <rect x="86" y="206" width="70" height="5" fill="#e9c34e" opacity="0.8"/>
    <path d="M52,176 Q90,150 112,168" fill="none" stroke="#3a2a18" stroke-width="2"/>
    {held_glyph(palo, p, 178, 132, 0.46)}
    <path d="M122,176 Q150,150 168,134 L160,126 Q142,142 116,166 Z" fill="url(#robe{p})" stroke="#00000022" stroke-width="1"/>
    <ellipse cx="166" cy="132" rx="7" ry="8" fill="{SKIN}" stroke="{SKIN_SH}" stroke-width="1"/>
    <path d="M104,196 Q100,172 110,160 L130,160 Q140,172 136,196 Q120,204 104,196 Z" fill="url(#robe{p})" stroke="#00000033" stroke-width="1.3"/>
    <rect x="104" y="190" width="34" height="7" rx="2" fill="#7a5a2a"/>
    <path d="M108,168 Q96,176 100,190 L110,186 Q108,176 116,170 Z" fill="url(#robe{p})" stroke="#00000022" stroke-width="1"/>
    <ellipse cx="103" cy="188" rx="6" ry="7" fill="{SKIN}" stroke="{SKIN_SH}" stroke-width="1"/>
    <path d="M108,160 Q120,152 132,160 Q120,168 108,160 Z" fill="#fbf7ee" stroke="#cbb78a" stroke-width="1"/>
    <rect x="114" y="145" width="12" height="12" fill="{SKIN}"/>
    <ellipse cx="120" cy="130" rx="15" ry="17" fill="{SKIN}" stroke="{SKIN_SH}" stroke-width="1"/>
    <path d="M106,128 Q105,144 114,150 Q110,138 110,128 Z" fill="{HAIR}"/>
    <g fill="#5a4631"><ellipse cx="115" cy="129" rx="1.7" ry="2.1"/><ellipse cx="126" cy="129" rx="1.7" ry="2.1"/></g>
    <path d="M116,146 Q120,148 124,146" fill="none" stroke="#a8694a" stroke-width="1.3"/>
    <ellipse cx="110" cy="138" rx="2.6" ry="1.8" fill="#e7a07e" opacity="0.5"/>
    <path d="M104,120 Q106,104 120,104 Q135,104 137,118 Q120,112 104,120 Z" fill="url(#cap{p})" stroke="#00000033" stroke-width="1.1"/>
    <rect x="105" y="116" width="32" height="5" rx="2" fill="#7a5a2a"/>
    <path d="M134,112 Q152,104 156,88 Q146,98 136,106 Z" fill="#e9c34e" stroke="#9a7415" stroke-width="1"/>'''

FIGURE = {"queen": sota, "jack": caballo, "king": rey}

def court_card(palo, court_file, label):
    p = palo[0]
    fig = FIGURE[court_file](palo, p)
    return (f'<svg xmlns="http://www.w3.org/2000/svg" width="{CARD_W}" height="{CARD_H}" '
            f'viewBox="0 0 {CARD_W} {CARD_H}">'
            f'<defs>{gradients(p)}{gradients(str(p)+"i")}{gradients(str(p)+"h")}{figdefs(palo, p)}</defs>'
            f'{frame(palo, p)}{fig}{index(palo, p, label)}</svg>')


# --------------------------------------------------------------------------
# Full deck generation
# --------------------------------------------------------------------------

def build_card(fsuit, vfile):
    palo = SUIT_FILE[fsuit]
    if vfile in COURT:
        _, num = COURT[vfile]
        return court_card(palo, vfile, str(num))
    label = "1" if vfile == "ace" else vfile
    n = 1 if vfile == "ace" else int(vfile)
    return number_card(palo, label, n)

ALL_VALUES = NUMBER_FILES + list(COURT.keys())  # ace..9, queen, jack, king

def write_deck(outdir):
    os.makedirs(outdir, exist_ok=True)
    count = 0
    for fsuit in SUIT_FILE:
        for vfile in ALL_VALUES:
            svg = build_card(fsuit, vfile)
            with open(os.path.join(outdir, f"{vfile}_of_{fsuit}.svg"), "w") as fh:
                fh.write(svg)
            count += 1
    return count


if __name__ == "__main__":
    import sys
    outdir = sys.argv[1] if len(sys.argv) > 1 else "data/cards/spanish"
    n = write_deck(outdir)
    print(f"wrote {n} cards to {outdir}")

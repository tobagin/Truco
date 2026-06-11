# Truco

A native GNOME card game for playing **Truco**, the popular South American
trick-taking card game played with a Spanish deck. Built with **Vala** and
**GTK4 / Libadwaita**, distributed as a **Flatpak**.

![Application ID](https://img.shields.io/badge/app--id-io.github.tobagin.Truco-blue)
![License](https://img.shields.io/badge/license-GPL--3.0--or--later-green)

## Features

- **Multiple regional variants**, each with authentic card-power rules:
  - **Paulista** (Brazil) — dynamic manilhas based on the *vira* card
  - **Mineiro** (Brazil) — fixed manilhas (Zap 4♣, 7♥, A♠, 7♦)
  - **Argentino / Uruguayo / Venezolano** — international rules with Envido and Flor
  - **Truco de Reis** — fixed-manilha mode where Kings are manilhas
- **Smart CPU opponents** with distinct personalities and an MCTS-based decision engine
- Variant-specific mechanics: **Mão de 11 / Mão de Ferro**, truco escalation
  (3 → 6 → 9 → 12), Envido/Flor betting, and card signaling
- **Customizable presentation** — multiple card decks (Spanish, French, modern),
  table felts, and 18+ player avatars
- Match statistics and game-history tracking
- Built-in tutorial and interactive help
- Fully translated: Spanish and Portuguese (pt, pt_BR, pt_PT)

## Building

The supported build path is Flatpak via the helper script:

```bash
./scripts/build.sh --dev   # development build (io.github.tobagin.Truco.Devel)
./scripts/build.sh         # production build (io.github.tobagin.Truco)
```

Run after building:

```bash
flatpak run io.github.tobagin.Truco.Devel   # development
flatpak run io.github.tobagin.Truco         # production
```

### Build dependencies

- `meson` (>= 0.59) and `ninja`
- `vala`
- `blueprint-compiler`
- GTK4 and Libadwaita development libraries
- `libgee` (Gee collections)

A direct (non-Flatpak) build:

```bash
meson setup build
meson compile -C build
./build/src/truco
```

## Project layout

| Path | Purpose |
|------|---------|
| `src/` | Vala source — game engine, UI, rules, managers, dialogs |
| `src/Game.vala` | Core engine: cards, players, game state, AI opponent |
| `src/RulesEngine.vala` | Per-variant card-power calculation |
| `src/Window.vala` | Main game window and UI |
| `src/dialogs/` | New Game, Preferences, Match End, Avatar Selector, About |
| `data/` | Card art, avatars, icons, sounds, CSS, GSettings schema, Blueprint UI |
| `po/` | gettext translations |
| `help/` | Mallard user help (yelp) |
| `packaging/` | Flatpak manifests (dev + prod) |

## Translating

Translations live in `po/`. To add a language, append its code to `po/LINGUAS`
and provide a `.po` file generated from `po/io.github.tobagin.Truco.pot`.

## License

Truco is released under the **GPL-3.0-or-later** license.

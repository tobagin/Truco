# Contributing to Truco

Thank you for your interest in contributing to Truco! This document provides guidelines and instructions for contributing to the project.

## Table of Contents

- [Code of Conduct](#code-of-conduct)
- [Getting Started](#getting-started)
- [Development Setup](#development-setup)
- [Project Structure](#project-structure)
- [Coding Standards](#coding-standards)
- [Submitting Changes](#submitting-changes)
- [Reporting Bugs](#reporting-bugs)
- [Feature Requests](#feature-requests)
- [Translations](#translations)

## Code of Conduct

This project adheres to professional and respectful collaboration standards. Please:

- Be respectful and constructive in discussions
- Focus on the technical merits of contributions
- Help maintain a welcoming environment for all contributors

## Getting Started

1. **Fork the repository** on GitHub
2. **Clone your fork** locally:
   ```bash
   git clone https://github.com/YOUR_USERNAME/Truco.git
   cd Truco
   ```
3. **Create a feature branch**:
   ```bash
   git checkout -b feature/your-feature-name
   ```

## Development Setup

### Prerequisites

- **Vala Compiler**
- **Meson** (>= 0.59) and **Ninja**
- **GTK4** and **LibAdwaita** development libraries
- **libgee**, **GStreamer** 1.0, **libsoup** 3, **json-glib**
- **Blueprint Compiler** (for UI files)
- **Flatpak** (for packaging)

### Building the Application

The supported path is Flatpak via the helper script:

```bash
./scripts/build.sh --dev   # development build (io.github.tobagin.Truco.Devel)
./scripts/build.sh         # production build (io.github.tobagin.Truco)
```

Run after building:

```bash
flatpak run io.github.tobagin.Truco.Devel
```

A direct (non-Flatpak) build is also possible:

```bash
meson setup build
meson compile -C build
```

## Project Structure

| Path | Purpose |
|------|---------|
| `src/` | Vala source — game engine, UI, rules, managers, dialogs |
| `src/Game.vala` | Core engine: cards, players, game state, AI opponent |
| `src/RulesEngine.vala` | Per-variant card-power calculation |
| `src/Window.vala` | Main game window and UI |
| `src/dialogs/` | New Game, Preferences, Online, Onboarding, Match End, Avatar, About |
| `src/services/network/` | WebSocket session, relay protocol, multiplayer controller |
| `data/ui/` | **Blueprint** (`.blp`) UI definitions |
| `data/` | Card art, avatars, icons, sounds, CSS, GSettings schema |
| `po/` | gettext translations |
| `help/` | Mallard user help (yelp) |
| `packaging/` | Flatpak manifests (dev + prod) |
| `server/` | Node.js multiplayer relay |

## Coding Standards

- **UI is built in Blueprint, never in code.** Add a `.blp` file under `data/ui/`, register it in `meson.build` and the GResource XML, and bind widgets with `[GtkTemplate]` / `[GtkChild]` in the Vala class.
- Follow the conventions of the surrounding Vala code (4-space indentation, existing naming).
- Keep user-facing strings wrapped in `_()` for translation.
- Prefer GSettings for persisted preferences.

## Submitting Changes

1. Make your changes on a feature branch.
2. Build and verify with `./scripts/build.sh --dev`.
3. Use clear, [Conventional Commit](https://www.conventionalcommits.org/) messages.
4. Open a pull request describing what changed and why.

## Reporting Bugs

Open a [GitHub Issue](https://github.com/tobagin/Truco/issues) with:

- A clear description of the problem
- Steps to reproduce
- Expected vs. actual behaviour
- Your version and platform

## Feature Requests

Feature requests are welcome via [GitHub Issues](https://github.com/tobagin/Truco/issues). Describe the use case and how it fits the game.

## Translations

Translations live in `po/`. To add a language:

1. Add its code to `po/LINGUAS`.
2. Create a `.po` file from `po/io.github.tobagin.Truco.pot` (e.g. `msginit -l <code> -i po/io.github.tobagin.Truco.pot -o po/<code>.po`).
3. Translate the strings and verify with `msgfmt --check po/<code>.po`.

Current languages: Catalan, Spanish, French, Italian, Brazilian Portuguese, European Portuguese.

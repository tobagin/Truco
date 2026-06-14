# Changelog

All notable changes to Truco will be documented in this file.

The format is based on [Keep a Changelog](https://keepachangelog.com/en/1.0.0/),
and this project adheres to [Semantic Versioning](https://semver.org/spec/v2.0.0.html).

## [1.0.0] - 2026-06-14

First public release.

### 🚀 Added
- **Five Regional Variants**: Paulista, Mineiro, Argentino, Uruguayo, and Venezolano, each with authentic per-variant card-power rules, plus a fixed-manilha *Truco de Reis* mode.
- **Online Multiplayer**: Quick matchmaking, private rooms with shareable codes, and join-by-code, over a deterministic lockstep relay.
- **Smart CPU Opponents**: Distinct personalities driven by an MCTS-based decision engine.
- **Game Mechanics**: Truco escalation (3 → 6 → 9 → 12), Envido/Real/Falta and Flor betting, Mão de 11 and Mão de Ferro special hands, and partner signalling.
- **Player Profile**: First-run onboarding to choose a username (pre-filled from the system account) and an avatar, used as the online and leaderboard handle.
- **Customization**: Multiple card decks (Spanish, French, modern), table felts, and 18+ avatars.
- **Help & Tutorial**: Interactive tutorial and Mallard user help.
- **Localization**: Catalan, Spanish, French, Italian, Brazilian Portuguese, and European Portuguese translations.

### 📦 Packaging
- Flatpak manifests for development and production, targeting the GNOME 49 runtime.
- AppStream metainfo, desktop entry, and GSettings schema.

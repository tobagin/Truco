# Fix Application Launch and Basic UI

## Status
**Proposed** | 2025-10-11

## Problem
The application currently crashes on launch due to:
1. Missing quotes in generated Config.vala causing Vala syntax errors
2. No icon resources configured for development (.Devel) builds
3. Basic window needs proper UI structure with main menu and title widget

## Solution
Implement a complete fix that:
1. Corrects Config.vala generation using `set_quoted()` for proper string literals
2. Creates placeholder icon resources for both release and development builds
3. Builds a proper main window with:
   - Adw.WindowTitle as title widget
   - Main menu using Gtk.MenuButton
   - Blueprint (.blp) file for declarative UI definition
4. Ensures all resource files are properly renamed with .Devel suffix for development builds

## Scope
**In Scope:**
- Fix build system configuration (meson.build) to properly quote Config.vala values
- Create icon placeholder (SVG) for io.github.tobagin.Truco and .Devel variant
- Implement main window UI using Blueprint
- Add GResource compilation for UI and icon files
- Ensure development build uses correct .Devel app ID throughout

**Out of Scope:**
- Game logic implementation
- Final icon design
- Multiple window support
- Advanced menu items beyond basic structure

## Impact
**Users:** Application will launch successfully with basic UI
**Developers:** Clear pattern for UI development using Blueprint
**Build:** Proper handling of development vs release builds

## Dependencies
- Existing buildtype-based app ID configuration
- GTK4 and LibAdwaita dependencies already declared
- Blueprint compiler (blueprint-compiler) available in GNOME SDK

## Risks
- Blueprint compiler availability in flatpak runtime
- Icon resource naming conventions must match app ID

## Alternatives Considered
1. **Hardcode UI in Vala:** Rejected - Blueprint provides better maintainability
2. **Skip icon for now:** Rejected - App won't show in launcher without icon
3. **Single icon for both builds:** Rejected - Need visual distinction for dev builds

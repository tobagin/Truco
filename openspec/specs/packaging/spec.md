# packaging Specification

## Purpose
TBD - created by archiving change initial-vala-gtk-setup. Update Purpose after archive.
## Requirements
### Requirement: Flatpak Manifest
The project SHALL have a Flatpak manifest for packaging as io.github.tobagin.Truco.

#### Scenario: Manifest file present
- **WHEN** checking root directory
- **THEN** io.github.tobagin.Truco.json is present

### Requirement: Runtime Dependencies
The Flatpak manifest SHALL specify necessary runtime dependencies for GNOME platform.

#### Scenario: Runtime specified
- **WHEN** checking manifest
- **THEN** runtime is org.gnome.Platform

### Requirement: Build Dependencies
The Flatpak manifest SHALL include build dependencies for Vala, Meson, and GTK.

#### Scenario: Build tools included
- **WHEN** checking manifest
- **THEN** build system includes vala, meson, and gtk4


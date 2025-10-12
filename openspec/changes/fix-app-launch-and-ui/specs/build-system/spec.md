# build-system Spec Delta

## ADDED Requirements

### Requirement: Configuration Data Quoting
The build system SHALL properly quote string values in configuration data to generate valid Vala code.

#### Scenario: Config.vala generation with quoted strings
- **GIVEN** buildtype determines application_id
- **WHEN** meson generates Config.vala from Config.vala.in
- **THEN** string constants are properly quoted (e.g., `"io.github.tobagin.Truco.Devel"`)
- **AND** generated Config.vala compiles without syntax errors

### Requirement: Blueprint Compiler Integration
The build system SHALL compile Blueprint (.blp) files to GTK UI (.ui) files.

#### Scenario: Blueprint compilation
- **GIVEN** Blueprint files exist in data/ui/
- **WHEN** running meson compile
- **THEN** .blp files are compiled to .ui files
- **AND** UI files are included in GResource bundle

### Requirement: GResource Bundle Generation
The build system SHALL generate a GResource bundle containing UI files and icons with correct namespacing.

#### Scenario: Resource bundle created
- **GIVEN** UI files and icons are present
- **WHEN** building the application
- **THEN** GResource bundle is created with path /io/github/tobagin/Truco/
- **AND** bundle is compiled into the executable

### Requirement: Icon Installation
The build system SHALL install icon files with names matching the application ID for each buildtype.

#### Scenario: Development build icons
- **GIVEN** buildtype is debug or debugoptimized
- **WHEN** installing application
- **THEN** icon is installed as io.github.tobagin.Truco.Devel.svg
- **AND** icon is placed in hicolor/scalable/apps/

#### Scenario: Release build icons
- **GIVEN** buildtype is release
- **WHEN** installing application
- **THEN** icon is installed as io.github.tobagin.Truco.svg
- **AND** icon is placed in hicolor/scalable/apps/

## MODIFIED Requirements

### Requirement: Build Dependencies
The project SHALL declare dependencies for GTK4, LibAdwaita, Vala, and blueprint-compiler in meson.build.

#### Scenario: Dependencies listed
- **WHEN** checking meson.build
- **THEN** dependencies include gtk4, libadwaita, vala, and blueprint-compiler

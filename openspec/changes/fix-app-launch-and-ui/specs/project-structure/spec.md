# project-structure Spec Delta

## ADDED Requirements

### Requirement: Icon Resources Directory
The project SHALL organize icon files in hicolor-compliant directory structure.

#### Scenario: Icon directory structure
- **GIVEN** data/icons/ directory exists
- **WHEN** inspecting structure
- **THEN** icons are in data/icons/hicolor/scalable/apps/
- **AND** both base and .Devel icon variants exist

### Requirement: Blueprint UI Files Organization
Blueprint source files SHALL be stored in data/ui/ directory.

#### Scenario: UI files location
- **GIVEN** project uses Blueprint
- **WHEN** checking data/ui/
- **THEN** window.blp is present
- **AND** compiled .ui files are generated in build directory

### Requirement: GResource Definition
The project SHALL define GResource XML for bundling UI and icon resources.

#### Scenario: GResource XML exists
- **GIVEN** data directory
- **WHEN** checking for resource files
- **THEN** io.github.tobagin.Truco.gresource.xml exists
- **AND** it references ui/ and icons/ paths

## MODIFIED Requirements

### Requirement: UI Definition Files
The project SHALL maintain UI definition files in data/ui/ including Blueprint source and compiled UI files.

#### Scenario: UI files exist
- **WHEN** checking data/ui/
- **THEN** window.blp source file is present
- **AND** GResource compilation is configured in data/meson.build

# ui-framework Spec Delta

## ADDED Requirements

### Requirement: Main Window Structure
The application SHALL provide a main window with header bar, title widget, and content area defined in Blueprint.

#### Scenario: Window with header bar
- **GIVEN** application is launched
- **WHEN** main window is displayed
- **THEN** window has an Adw.HeaderBar at the top
- **AND** header bar contains an Adw.WindowTitle

### Requirement: Window Title Widget
The main window SHALL display the application name "Truco" in the window title using Adw.WindowTitle.

#### Scenario: Title displayed
- **GIVEN** main window is shown
- **WHEN** viewing the header bar
- **THEN** Adw.WindowTitle displays "Truco"

### Requirement: Main Menu
The application SHALL provide a main menu accessible via Gtk.MenuButton in the header bar.

#### Scenario: Menu button present
- **GIVEN** main window is displayed
- **WHEN** viewing header bar end section
- **THEN** Gtk.MenuButton with "open-menu-symbolic" icon is present

#### Scenario: Menu contains basic items
- **GIVEN** menu button is clicked
- **WHEN** menu opens
- **THEN** menu contains "About" and "Preferences" items

### Requirement: Blueprint UI Definition
UI layouts SHALL be defined in Blueprint (.blp) files for maintainability and clarity.

#### Scenario: Window defined in Blueprint
- **GIVEN** window.blp exists in data/ui/
- **WHEN** application builds
- **THEN** window.blp compiles to window.ui
- **AND** Application.vala loads UI from resource path

### Requirement: Resource Loading
The application SHALL load UI definitions from compiled GResource bundle.

#### Scenario: UI loaded from resources
- **GIVEN** GResource bundle is compiled
- **WHEN** Application activates
- **THEN** window UI is loaded via Gtk.Builder.from_resource()
- **AND** resource path is /io/github/tobagin/Truco/ui/window.ui

## MODIFIED Requirements

### Requirement: Blueprint UI Files
The application SHALL define UI layouts using Blueprint (.blp) files compiled into GResource bundles.

#### Scenario: Blueprint files compiled
- **WHEN** building the application
- **THEN** Blueprint files are compiled into UI resources
- **AND** UI resources are bundled in GResource file

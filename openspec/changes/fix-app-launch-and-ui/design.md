# Design: Fix Application Launch and Basic UI

## Architecture Overview

### Component Structure
```
Application (Vala)
├── Config (generated from Config.vala.in)
│   └── APP_ID, VERSION, PROFILE (quoted strings)
├── Main Window (Blueprint → GResource)
│   ├── Adw.ApplicationWindow
│   ├── Adw.HeaderBar
│   │   ├── Adw.WindowTitle (title-widget)
│   │   └── Gtk.MenuButton (main menu)
│   └── Content Area
└── Resources (GResource bundle)
    ├── UI files (*.ui from *.blp)
    └── Icons (*.svg → scalable/apps/)
```

### Build-Time Configuration Flow

1. **meson.build (root)**
   - Determines `application_id` from buildtype
   - Creates `conf_data` with `set_quoted()` for string values
   - Passes to subdirectories

2. **data/meson.build**
   - Compiles Blueprint → UI files
   - Processes icons with correct naming
   - Creates GResource bundle with `application_id` namespace
   - Generates desktop/metainfo with substituted `@APP_ID@`

3. **src/meson.build**
   - Generates Config.vala from Config.vala.in
   - Compiles Vala sources including generated Config

### Icon Resource Strategy

**Directory Structure:**
```
data/icons/
├── hicolor/
│   └── scalable/
│       └── apps/
│           ├── io.github.tobagin.Truco.svg (base icon)
│           └── io.github.tobagin.Truco.Devel.svg (dev icon, symlink or variant)
```

**Build Logic:**
- Use `install_data()` with `rename` parameter based on `application_id`
- Or install with dynamic filenames directly

### Blueprint UI Pattern

**File:** `data/ui/window.blp`
```
using Gtk 4.0;
using Adw 1;

Adw.ApplicationWindow window {
  default-width: 800;
  default-height: 600;

  Adw.ToolbarView {
    [top]
    Adw.HeaderBar header_bar {
      [title]
      Adw.WindowTitle title {
        title: "Truco";
      }

      [end]
      Gtk.MenuButton menu_button {
        icon-name: "open-menu-symbolic";
        menu-model: primary_menu;
      }
    }

    content: Gtk.Box {
      orientation: vertical;
      spacing: 12;
      margin-top: 12;
      margin-bottom: 12;
      margin-start: 12;
      margin-end: 12;

      Gtk.Label {
        label: "Welcome to Truco!";
        styles ["title-1"]
      }
    };
  }
}

menu primary_menu {
  section {
    item {
      label: _("_Preferences");
      action: "app.preferences";
    }
    item {
      label: _("_About Truco");
      action: "app.about";
    }
  }
}
```

### Config.vala Generation Fix

**Issue:** Meson's `conf_data.set()` doesn't automatically quote strings
**Solution:** Use `conf_data.set_quoted()` instead

**Before:**
```meson
conf_data.set('APP_ID', '"' + application_id + '"')  # Manual quoting fails
```

**After:**
```meson
conf_data.set_quoted('APP_ID', application_id)  # Automatic proper quoting
```

**Generated Output:**
```vala
public const string APP_ID = "io.github.tobagin.Truco.Devel";
```

### Resource Loading Pattern

**In Application.vala:**
```vala
public class Truco.Application : Adw.Application {
    construct {
        resource_base_path = "/io/github/tobagin/Truco";
    }

    protected override void activate () {
        var builder = new Gtk.Builder.from_resource (
            @"$resource_base_path/ui/window.ui"
        );
        var window = builder.get_object ("window") as Adw.ApplicationWindow;
        window.application = this;
        window.present ();
    }
}
```

## Trade-offs

### Blueprint vs Vala UI
**Chosen:** Blueprint
- **Pro:** Declarative, easier to maintain, better separation
- **Pro:** GNOME ecosystem standard
- **Con:** Requires blueprint-compiler dependency
- **Con:** Another build step

### Icon Approach
**Chosen:** Separate icon files per build type
- **Pro:** Clear visual distinction in launcher
- **Pro:** Follows flatpak conventions
- **Con:** Need to maintain two icons (can symlink for placeholder)

### GResource Namespace
**Chosen:** Use base app ID for resource path
- **Pro:** Single resource path in code
- **Con:** Must handle in application construct
- **Alternative:** Dynamic paths - rejected for complexity

## Implementation Phases

### Phase 1: Fix Config.vala (Critical)
- Update meson.build to use `set_quoted()`
- Verify generated Config.vala syntax
- Test application startup

### Phase 2: Add Icons
- Create placeholder SVG
- Configure icon installation
- Symlink/copy for .Devel variant

### Phase 3: Implement Blueprint UI
- Create window.blp
- Add blueprint-compiler dependency
- Configure GResource compilation
- Update Application.vala to load from resource

### Phase 4: Integration
- Verify both dev and release builds
- Test icon display
- Validate menu functionality

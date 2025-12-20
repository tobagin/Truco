# Tech Stack: Truco

## Core Language & Frameworks
- **Language:** [Vala](https://vala.projects.gnome.org/) - A high-level language with C-like performance and native GObject support.
- **UI Toolkit:** [GTK4](https://www.gtk.org/) - The latest version of the GIMP Toolkit for modern UI development.
- **Platform Library:** [Libadwaita](https://gnome.pages.gitlab.gnome.org/libadwaita/) - Providing the GNOME "building blocks" and HIG compliance.

## Libraries & Tools
- **Collections:** [libgee-0.8](https://wiki.gnome.org/Projects/Libgee) - GObject-based collection library for Vala.
- **Multimedia:** [GStreamer 1.0](https://gstreamer.freedesktop.org/) - For handling game sound effects and potentially future audio/video.
- **Build System:** [Meson](https://mesonbuild.com/) with [Ninja](https://ninja-build.org/).
- **UI Definition:** [Blueprint](https://jwestman.pages.gitlab.gnome.org/blueprint-compiler/) - A concise markup language for GTK4 UIs.
- **Localization:** [gettext](https://www.gnu.org/software/gettext/) via GNOME's i18n module.

## Architecture
- **Pattern:** Model-View-Controller (MVC).
- **Resource Management:** GResource for bundling assets (SVG cards, sounds, UI files).
- **Asynchrony:** GLib signals and async/await for non-blocking UI and AI processing.

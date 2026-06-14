# Screenshots

The metainfo (`data/io.github.tobagin.Truco.metainfo.xml.in`) references
`gameplay.png` in this directory, served from:

    https://raw.githubusercontent.com/tobagin/Truco/master/data/screenshots/gameplay.png

Flathub requires at least one reachable screenshot. Before tagging the
release, capture a gameplay shot and commit it here as `gameplay.png`:

    flatpak run io.github.tobagin.Truco.Devel    # start a match, then
    gnome-screenshot -w -f data/screenshots/gameplay.png

(Use the interactive screenshot UI — Print Screen — if the CLI is blocked by
the compositor.) Recommended size: 16:10-ish, ≥ 1280px wide, PNG.

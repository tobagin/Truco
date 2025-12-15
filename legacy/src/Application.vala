public class Truco.Application : Adw.Application {
    public Application () {
        Object (
            application_id: Config.APP_ID,
            flags: ApplicationFlags.DEFAULT_FLAGS,
            resource_base_path: "/io/github/tobagin/Truco"
        );
    }

    public override void startup () {
        base.startup ();

        // Set up actions
        var about_action = new SimpleAction ("about", null);
        about_action.activate.connect (show_about);
        add_action (about_action);

        var preferences_action = new SimpleAction ("preferences", null);
        preferences_action.activate.connect (show_preferences);
        add_action (preferences_action);

        var quit_action = new SimpleAction ("quit", null);
        quit_action.activate.connect (() => {
            quit ();
        });
        add_action (quit_action);

        // Set up keyboard accelerators
        set_accels_for_action ("app.about", {"<Control>question"});
        set_accels_for_action ("app.preferences", {"<Control>comma"});
        set_accels_for_action ("app.quit", {"<Control>q"});
        set_accels_for_action ("win.show-help-overlay", {"<Control>question"});
    }

    protected override void activate () {
        Truco.Window? window = active_window as Truco.Window;
        if (window == null) {
            window = new Truco.Window (this);

            // Set up keyboard shortcuts window
            var builder = new Gtk.Builder.from_resource (Config.RESOURCE_PATH + "/shortcuts.ui");
            var shortcuts_window = builder.get_object ("shortcuts_window") as Gtk.ShortcutsWindow;
            window.set_help_overlay (shortcuts_window);
        }

        window.present ();
    }

    private void show_about () {
        Truco.AboutDialog.show (active_window);
    }

    private void show_preferences () {
        // TODO: Implement preferences dialog
        warning ("Preferences not yet implemented");
    }
}

#if DEVELOPMENT
[GtkTemplate (ui = "/io/github/tobagin/Truco/Devel/window.ui")]
#else
[GtkTemplate (ui = "/io/github/tobagin/Truco/window.ui")]
#endif
public class Truco.Window : Adw.ApplicationWindow {
    public Window (Gtk.Application app) {
        Object (application: app);
    }
}
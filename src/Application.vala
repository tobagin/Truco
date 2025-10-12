public class Truco.Application : Adw.Application {
    public Application () {
        Object (
            application_id: Config.APP_ID,
            flags: ApplicationFlags.FLAGS_NONE,
            resource_base_path: "/io/github/tobagin/Truco"
        );
    }

    protected override void activate () {
        var window = new Truco.Window (this);
        window.present ();
    }
}

[GtkTemplate (ui = "/io/github/tobagin/Truco/ui/window.ui")]
public class Truco.Window : Adw.ApplicationWindow {
    public Window (Gtk.Application app) {
        Object (application: app);
    }
}
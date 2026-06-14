using Gtk;
using Adw;

// Workaround for GtkUriLauncher not working with help:// URIs in Flatpak
namespace Workaround {
    [CCode (cheader_filename = "gtk/gtk.h", cname = "gtk_show_uri")]
    extern static void gtk_show_uri (Gtk.Window? parent, string uri, uint32 timestamp);
}

namespace Truco {

    public class Application : Adw.Application {
        public Application () {
            Object (
                application_id: Config.APP_ID,
                flags: ApplicationFlags.DEFAULT_FLAGS,
                resource_base_path: "/io/github/tobagin/Truco"
            );
        }

        protected override void startup () {
            base.startup ();
            
            // CSS
            var css_provider = new Gtk.CssProvider();
            css_provider.load_from_resource(Config.RESOURCE_PATH + "/style.css");
            Gtk.StyleContext.add_provider_for_display(Gdk.Display.get_default(), css_provider, Gtk.STYLE_PROVIDER_PRIORITY_APPLICATION);

            var about_action = new SimpleAction ("about", null);
            about_action.activate.connect (show_about);
            add_action (about_action);

            var quit_action = new SimpleAction ("quit", null);
            quit_action.activate.connect (quit);
            add_action (quit_action);
            
            var preferences_action = new SimpleAction ("preferences", null);
            preferences_action.activate.connect (show_preferences);
            add_action (preferences_action);

            var shortcuts_action = new SimpleAction ("shortcuts", null);
            shortcuts_action.activate.connect (show_shortcuts);
            add_action (shortcuts_action);

            var online_action = new SimpleAction ("play-online", null);
            online_action.activate.connect (show_play_online);
            add_action (online_action);

            var help_action = new SimpleAction ("help", null);
            help_action.activate.connect (show_help);
            add_action (help_action);
            
            set_accels_for_action ("app.preferences", {"<Control>comma"});
            set_accels_for_action ("app.quit", {"<Control>q"});
            set_accels_for_action ("app.shortcuts", {"<Control>question"});
            set_accels_for_action ("app.help", {"F1"});
            set_accels_for_action ("app.about", {"<Control>F1"});
            set_accels_for_action ("win.new-game", {"<Control>n"});
            set_accels_for_action ("win.new-game-quick", {"F5"});
        }

        protected override void activate () {
            Truco.Window? window = active_window as Truco.Window;
            if (window == null) {
                window = new Truco.Window (this);
            }

            window.present ();
        }
        
        private void show_help () {
            var win = active_window as Truco.Window;
            // Use workaround for help: URI
            Workaround.gtk_show_uri(win, "help:" + Config.APP_ID, Gdk.CURRENT_TIME);
        }
        
        private void show_shortcuts () {
            // Load and show dialog
            var builder = new Gtk.Builder.from_resource (Config.RESOURCE_PATH + "/shortcuts.ui");
            var dialog = builder.get_object ("shortcuts_window") as Adw.ShortcutsDialog;
            if (dialog != null) {
                dialog.present (active_window);
            }
        }
        
        private void show_about () {
            Truco.AboutDialog.show (active_window);
        }
        
        private void show_preferences () {
            if (active_window is Truco.Window) {
                var prefs = new PreferencesDialog (active_window as Truco.Window);
                prefs.present (active_window);
            }
        }
        
        private void show_play_online () {
            var win = active_window as Truco.Window;
            if (win == null) {
                return;
            }
            var dialog = new OnlineDialog (win.get_local_player_name ());
            dialog.game_ready.connect ((controller, variant, seat, first_dealer, seed) => {
                win.start_multiplayer_game (controller, variant, seat, first_dealer, seed);
            });
            dialog.present (win);
        }
    }
}
using Gtk;
using Adw;

namespace Truco {

    [GtkTemplate (ui = "/io/github/tobagin/Truco/preferences_dialog.ui")]
    public class PreferencesDialog : Adw.PreferencesDialog {
        
        [GtkChild]
        private unowned Adw.ComboRow default_variant_row;
        [GtkChild]
        private unowned Adw.ComboRow felt_color_row;
        [GtkChild]
        private unowned Adw.ComboRow deck_style_row;
        [GtkChild]
        private unowned Adw.ComboRow card_design_row;
        [GtkChild]
        private unowned Adw.ComboRow card_color_row;
        [GtkChild]
        private unowned Adw.EntryRow username_row;
        [GtkChild]
        private unowned Adw.ActionRow avatar_row;
        [GtkChild]
        private unowned Adw.Avatar avatar_image;
        [GtkChild]
        private unowned Adw.SwitchRow sound_row;

        private weak Truco.Window main_window;

        public PreferencesDialog(Truco.Window parent) {
            this.main_window = parent;
            
            // Avatar Selector Handler
            avatar_row.activated.connect(() => {
                var selector = new AvatarSelector(main_window);
                selector.avatar_selected.connect((idx) => {
                     // Update settings
                     var settings_tmp = new GLib.Settings (Config.SCHEMA_ID);
                     settings_tmp.set_int("avatar-index", idx);
                     // The change listener below will handle visual update
                });
                selector.present();
            });

            // GSettings Binding
            var settings = new GLib.Settings (Config.SCHEMA_ID);
            
            settings.bind ("username", username_row, "text", SettingsBindFlags.DEFAULT);
            settings.bind ("default-game-variant", default_variant_row, "selected", SettingsBindFlags.DEFAULT);
            settings.bind ("felt-color-index", felt_color_row, "selected", SettingsBindFlags.DEFAULT);
            settings.bind ("deck-style", deck_style_row, "selected", SettingsBindFlags.DEFAULT);
            settings.bind ("card-back-design", card_design_row, "selected", SettingsBindFlags.DEFAULT);
            settings.bind ("card-back-color", card_color_row, "selected", SettingsBindFlags.DEFAULT);
            settings.bind ("sound-enabled", sound_row, "active", SettingsBindFlags.DEFAULT);
            // Removed bind for avatar-index to combo row, handled manually via click
            
            // Sync Indices to String Keys
            settings.changed["felt-color-index"].connect (() => {
                string color = "felt-green";
                int idx = settings.get_int("felt-color-index");
                switch (idx) {
                    case 0: color = "felt-green"; break;
                    case 1: color = "felt-red"; break;
                    case 2: color = "felt-blue"; break;
                }
                settings.set_string("felt-color", color);
            });
            
            settings.changed["card-back-design"].connect(() => update_card_settings(settings));
            settings.changed["card-back-color"].connect(() => update_card_settings(settings));
            
            settings.changed["avatar-index"].connect(() => {
                update_avatar_display(settings);
            });
            
            // Initial Display
            update_avatar_display(settings);
        }
        

        private void update_avatar_display(GLib.Settings settings) {
            int idx = settings.get_int("avatar-index");
            string icon = "avatars/avatar%d.svg".printf(idx + 1);
            settings.set_string("avatar", icon);
            
            // Update UI image
            var paintable = Gdk.Texture.from_resource(Config.RESOURCE_PATH + "/" + icon);
            avatar_image.set_custom_image(paintable);
        }
        
        private void update_card_settings(GLib.Settings settings) {
            int design = settings.get_int("card-back-design") + 1;
            int color_idx = settings.get_int("card-back-color");
            string color = "black";
             switch (color_idx) {
                case 0: color = "black"; break;
                case 1: color = "blue"; break;
                case 2: color = "green"; break;
                case 3: color = "lightblue"; break;
                case 4: color = "red"; break;
            }
            string path = "cards/backs/player_card_back_design_%d_%s.svg".printf(design, color);
            settings.set_string("card-back", path);
        }
        
    }
}

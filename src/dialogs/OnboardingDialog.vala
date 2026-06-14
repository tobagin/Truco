using Gtk;
using Adw;

namespace Truco {

    [GtkTemplate (ui = "/io/github/tobagin/Truco/onboarding_dialog.ui")]
    public class OnboardingDialog : Adw.Dialog {

        [GtkChild] private unowned Gtk.Button avatar_button;
        [GtkChild] private unowned Adw.Avatar avatar_image;
        [GtkChild] private unowned Adw.EntryRow username_row;
        [GtkChild] private unowned Gtk.Button continue_button;

        private GLib.Settings settings;
        private int avatar_index;

        public signal void completed ();

        public OnboardingDialog (string suggested_name) {
            Object ();

            settings = new GLib.Settings (Config.SCHEMA_ID);
            avatar_index = settings.get_int ("avatar-index");
            update_avatar_preview ();

            username_row.text = suggested_name;
            update_continue_sensitive ();

            username_row.changed.connect (update_continue_sensitive);

            avatar_button.clicked.connect (() => {
                var selector = new AvatarSelector (this.get_root () as Gtk.Window);
                selector.avatar_selected.connect ((idx) => {
                    avatar_index = idx;
                    settings.set_int ("avatar-index", idx);
                    settings.set_string ("avatar", "avatars/avatar%d.svg".printf (idx + 1));
                    update_avatar_preview ();
                });
                selector.present ();
            });

            continue_button.clicked.connect (() => {
                settings.set_string ("username", username_row.text.strip ());
                completed ();
                this.close ();
            });
        }

        private void update_continue_sensitive () {
            continue_button.sensitive = username_row.text.strip () != "";
        }

        private void update_avatar_preview () {
            var paintable = Gdk.Texture.from_resource (
                Config.RESOURCE_PATH + "/avatars/avatar%d.svg".printf (avatar_index + 1));
            avatar_image.set_custom_image (paintable);
        }
    }
}

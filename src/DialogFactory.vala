using Gtk;
using Adw;

namespace Truco {
    public class DialogFactory : Object {
        public static Adw.AlertDialog create_game_dialog(string title, string body, string accept_label, string refuse_label) {
            var dialog = new Adw.AlertDialog(title, body);

            dialog.add_response("refuse", refuse_label);
            dialog.set_response_appearance("refuse", Adw.ResponseAppearance.DESTRUCTIVE);

            dialog.add_response("accept", accept_label);
            dialog.set_response_appearance("accept", Adw.ResponseAppearance.SUGGESTED);

            dialog.set_default_response("accept");

            dialog.close_response = "refuse";

            return dialog;
        }
    }
}

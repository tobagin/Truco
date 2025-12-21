using Gtk;
using Adw;

namespace Truco {
    public class DialogFactory : Object {
        public static Adw.AlertDialog create_game_dialog(string title, string body, string accept_label, string refuse_label) {
            var dialog = new Adw.AlertDialog(title, body);
            
            // Standard "Run/Refuse" action
            dialog.add_response("refuse", refuse_label);
            dialog.set_response_appearance("refuse", Adw.ResponseAppearance.DESTRUCTIVE);
            
            // Standard "Accept" action
            dialog.add_response("accept", accept_label);
            dialog.set_response_appearance("accept", Adw.ResponseAppearance.SUGGESTED);
            
            // Default to accept? Usually default is the safe action, or the one that moves forward.
            // For games, "Accept" is usually the primary.
            dialog.set_default_response("accept");
            
            // Close response? Adw.AlertDialog handles escape/close automatically if we don't set close_response.
            // But we want to ensure a choice is made. 
            // We can map close to refuse for safety.
            dialog.close_response = "refuse";

            return dialog;
        }
    }
}

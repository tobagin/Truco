using Gtk;
using Adw;

namespace Truco {

    [GtkTemplate (ui = "/io/github/tobagin/Truco/new_game_dialog.ui")]
    public class NewGameDialog : Adw.AlertDialog {
        
        [GtkChild]
        private unowned Adw.ComboRow variant_row;
        
        public string? selected_variant { get; private set; }
        
        public NewGameDialog() {
            Object();
            
            this.add_response("cancel", _("Cancel"));
            this.add_response("start", _("Start Game"));
            
            this.set_response_appearance("start", Adw.ResponseAppearance.SUGGESTED);
            
            this.response.connect((response_id) => {
                if (response_id == "start") {
                    switch (variant_row.selected) {
                        case 0: selected_variant = "mineiro"; break;
                        case 1: selected_variant = "paulista"; break;
                        case 2: selected_variant = "uruguayo"; break;
                        case 3: selected_variant = "venezolano"; break;
                        case 4: selected_variant = "argentino"; break;
                        default: selected_variant = "mineiro"; break;
                    }
                } else {
                    selected_variant = null;
                }
                this.close();
            });
        }
    }
}

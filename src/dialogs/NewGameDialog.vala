using Gtk;
using Adw;

namespace Truco {

    [GtkTemplate (ui = "/io/github/tobagin/Truco/new_game_dialog.ui")]
    public class NewGameDialog : Adw.AlertDialog {

        [GtkChild]
        private unowned Adw.ComboRow variant_row;
        [GtkChild]
        private unowned Adw.ComboRow team_size_row;
        [GtkChild]
        private unowned Adw.SwitchRow hidden_vira_row;

        public string? selected_variant { get; private set; }
        public int selected_team_size { get; private set; }
        public bool selected_hidden_vira { get; private set; }
        public bool selected_fixed_manilha { get; private set; }

        public NewGameDialog() {
            Object();

            this.add_response("cancel", _("Cancel"));
            this.add_response("start", _("Start Game"));

            this.set_response_appearance("start", Adw.ResponseAppearance.SUGGESTED);

            this.response.connect((response_id) => {
                if (response_id == "start") {
                    selected_team_size = (int)team_size_row.selected + 1;
                    selected_hidden_vira = hidden_vira_row.active;
                    selected_fixed_manilha = false;

                    switch (variant_row.selected) {
                        case 0: selected_variant = "mineiro"; break;
                        case 1: selected_variant = "paulista"; break;
                        case 2: selected_variant = "uruguayo"; break;
                        case 3: selected_variant = "venezolano"; break;
                        case 4: selected_variant = "argentino"; break;
                        case 5:
                            selected_variant = "paulista";
                            selected_fixed_manilha = true;
                            break;
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

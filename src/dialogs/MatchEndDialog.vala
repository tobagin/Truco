using Gtk;
using Adw;

namespace Truco {
    public class MatchEndDialog : Adw.AlertDialog {
        
        public signal void match_response(string response_id);

        public MatchEndDialog(int winning_team, int us_score, int them_score, int us_wins, int them_wins, int rounds_us, int total_rounds) {
            Object(
                heading: _("Match Over"),
                body: (winning_team == 0) ? _("You Won!") : _("You Lost!")
            );
            
            // Actions
            add_response("new", _("Play Again"));
            set_response_appearance("new", Adw.ResponseAppearance.SUGGESTED);
            
            add_response("ok", _("OK"));
            
            add_response("quit", _("Quit Game"));
            set_response_appearance("quit", Adw.ResponseAppearance.DESTRUCTIVE);
            
            set_default_response("new");
            close_response = "ok";
            
            // Stats Content
            var box = new Box(Orientation.VERTICAL, 12);
            box.halign = Align.CENTER;
            
            int games_played = us_wins + them_wins;
            double games_pct = (games_played > 0) ? ((double)us_wins / games_played) * 100.0 : 0.0;
            double rounds_pct = (total_rounds > 0) ? ((double)rounds_us / total_rounds) * 100.0 : 0.0;

            string stats_text = _("Games Won: %d/%d (%.0f%%)\nRounds Won: %d/%d (%.0f%%)").printf(
                us_wins, games_played, games_pct,
                rounds_us, total_rounds, rounds_pct
            );
            
            var label = new Label(stats_text);
            label.justify = Justification.CENTER;
            label.add_css_class("body");
            box.append(label);
            
            set_extra_child(box);
            
            // Map responses to signal
            this.response.connect((id) => {
                match_response(id);
            });
        }
    }
}

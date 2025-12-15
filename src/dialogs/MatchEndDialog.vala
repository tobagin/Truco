using Gtk;

[GtkTemplate (ui = "/io/github/tobagin/Truco/match_end_dialog.ui")]
public class Truco.MatchEndDialog : Adw.Window {
    
    [GtkChild]
    private unowned Adw.StatusPage status_page;
    
    [GtkChild]
    private unowned Label result_label;
    
    [GtkChild]
    private unowned Label stats_label;
    
    public signal void response(string response_id);

    public MatchEndDialog(int winning_team, int us_score, int them_score, int us_wins, int them_wins, int rounds_us, int total_rounds) {
        
        // Actions
        var action_group = new SimpleActionGroup();
        
        var act_play = new SimpleAction("play-again", null);
        act_play.activate.connect(() => { response("new"); close(); });
        action_group.add_action(act_play);
        
        var act_ok = new SimpleAction("ok", null);
        act_ok.activate.connect(() => { response("ok"); close(); });
        action_group.add_action(act_ok);
        
        var act_quit = new SimpleAction("quit", null);
        act_quit.activate.connect(() => { response("quit"); close(); });
        action_group.add_action(act_quit);
        
        insert_action_group("dialog", action_group);
        
        // Populate Data
        if (winning_team == 0) {
            status_page.title = _("Match Over");
            result_label.label = _("You Won!");
            status_page.icon_name = "emoji-events-symbolic"; // Trophy
        } else {
            status_page.title = _("Match Over");
            result_label.label = _("You Lost!");
            status_page.icon_name = "emblem-unreadable-symbolic"; // Sad face or similar
        }
        
        int games_played = us_wins + them_wins;
        double games_pct = (games_played > 0) ? ((double)us_wins / games_played) * 100.0 : 0.0;
        double rounds_pct = (total_rounds > 0) ? ((double)rounds_us / total_rounds) * 100.0 : 0.0;

        string stats = _("Games Won: %d/%d (%.0f%%)\nRounds Won: %d/%d (%.0f%%)").printf(
            us_wins, games_played, games_pct,
            rounds_us, total_rounds, rounds_pct
        );
        
        stats_label.label = stats;
    }
}

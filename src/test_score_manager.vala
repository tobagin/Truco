using GLib;
using Truco;

void main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/ScoreManager/Argentino/Progression", () => {
        var sm = new ScoreManager (30);
        
        sm.add_points (0, 10);
        assert (sm.score_team_0 == 10);
        assert (!sm.is_buenas (sm.score_team_0));
        assert (sm.get_relative_score (sm.score_team_0) == 10);
        
        sm.add_points (0, 10); // Now 20
        assert (sm.score_team_0 == 20);
        assert (sm.is_buenas (sm.score_team_0));
        assert (sm.get_relative_score (sm.score_team_0) == 5);
        
        sm.add_points (0, 15); // Now 30 (capped)
        assert (sm.score_team_0 == 30);
        assert (sm.is_game_over ());
        assert (sm.get_winner () == 0);
    });

    Test.run ();
}

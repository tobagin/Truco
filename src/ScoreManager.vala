using Gee;

namespace Truco {
    public class ScoreManager : Object {
        public int score_team_0 { get; set; default = 0; }
        public int score_team_1 { get; set; default = 0; }
        public int limit { get; set; default = 30; }

        public ScoreManager(int limit = 30) {
            this.limit = limit;
        }

        public bool is_buenas(int score) {
            if (limit == 30) return score > 15;
            return false; // For 12 points, there's no usually Buenas/Malas distinction in same way
        }

        public int get_relative_score(int score) {
            if (limit == 30 && score > 15) return score - 15;
            return score;
        }

        public string get_score_label(int score) {
            if (limit != 30) return score.to_string();
            if (score <= 15) return _("%d Malas").printf(score);
            return _("%d Buenas").printf(score - 15);
        }

        public void add_points(int team, int points) {
            if (team == 0) {
                score_team_0 += points;
                if (score_team_0 > limit) score_team_0 = limit;
            } else {
                score_team_1 += points;
                if (score_team_1 > limit) score_team_1 = limit;
            }
        }

        public bool is_game_over() {
            return score_team_0 >= limit || score_team_1 >= limit;
        }

        public int get_winner() {
            if (score_team_0 >= limit) return 0;
            if (score_team_1 >= limit) return 1;
            return -1;
        }

        public void reset() {
            score_team_0 = 0;
            score_team_1 = 0;
        }
    }
}

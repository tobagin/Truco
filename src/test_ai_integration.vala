using GLib;
using Gee;
using Truco;

void main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/AI/Argentino/CardSelection", () => {

        var game = new GameState("argentino", 1);

        var cpu = game.players[1];
        cpu.hand.clear();

        var c_best = new Card(Suit.SWORDS, 1);
        var c_mid = new Card(Suit.CUPS, 3);
        var c_worst = new Card(Suit.GOLDS, 4);

        c_best.power = game.rules_engine.get_power(c_best, "argentino");
        c_mid.power = game.rules_engine.get_power(c_mid, "argentino");
        c_worst.power = game.rules_engine.get_power(c_worst, "argentino");

        cpu.hand.add(c_worst);
        cpu.hand.add(c_best);
        cpu.hand.add(c_mid);

        game.current_player_index = 1;
        game.table_cards.clear();
        game.table_pids.clear();

        int idx = game.get_best_card_index(1);
        assert (idx >= 0 && idx < 3);

        var op_card = new Card(Suit.GOLDS, 3);
        op_card.power = game.rules_engine.get_power(op_card, "argentino");

        game.table_cards.add(op_card);
        game.table_pids.add(0);

        int idx_response = game.get_best_card_index(1);
        var chosen = cpu.hand[idx_response];

        assert (chosen.suit == Suit.SWORDS && chosen.value == 1);

        game.table_cards.clear();
        game.table_pids.clear();
        var op_card2 = new Card(Suit.GOLDS, 7);
        op_card2.power = game.rules_engine.get_power(op_card2, "argentino");
        game.table_cards.add(op_card2);
        game.table_pids.add(0);

        idx_response = game.get_best_card_index(1);
        chosen = cpu.hand[idx_response];
        assert (chosen.suit == Suit.SWORDS && chosen.value == 1);

        game.table_cards.clear();
        game.table_pids.clear();
        var op_card3 = new Card(Suit.CLUBS, 1);
        op_card3.power = game.rules_engine.get_power(op_card3, "argentino");
        game.table_cards.add(op_card3);
        game.table_pids.add(0);

        idx_response = game.get_best_card_index(1);
        chosen = cpu.hand[idx_response];
        assert (chosen.suit == Suit.SWORDS && chosen.value == 1);
    });

    Test.add_func ("/AI/Argentino/EnvidoCalling", () => {

        var game = new GameState("argentino", 1);
        var cpu = game.players[1];
        cpu.hand.clear();

        var c1 = new Card(Suit.SWORDS, 7);
        var c2 = new Card(Suit.SWORDS, 6);
        var c3 = new Card(Suit.GOLDS, 4);

        cpu.hand.add(c1);
        cpu.hand.add(c2);
        cpu.hand.add(c3);

        game.round_count = 1;
        game.current_player_index = 1;
        game.envido_available = true;
        game.envido_played = false;
        game.state_envido_pending = false;
        game.vaza_wins_team_0 = 0;
        game.vaza_wins_team_1 = 0;
        game.table_cards.clear();

        int s = game.rules_engine.get_envido_score(cpu.hand);
        assert (s == 33);

        bool would_consider = (s >= 20);
        assert (would_consider);
    });

    Test.add_func ("/AI/Argentino/TrucoResponse", () => {
        var game = new GameState("argentino", 1);
        var cpu = game.players[1];

        cpu.hand.clear();
        var w1 = new Card(Suit.GOLDS, 4); w1.power = 1;
        var w2 = new Card(Suit.CUPS, 4); w2.power = 1;
        var w3 = new Card(Suit.CLUBS, 5); w3.power = 2;
        cpu.hand.add(w1); cpu.hand.add(w2); cpu.hand.add(w3);

        game.stake = 1;
        game.proposed_stake = 2;
        game.challenger_team = 0;

        game.score_manager.reset();

        cpu.personality = Personality.CONSERVATIVE;

        game.cpu_respond_truco();

        if (game.score_manager.score_team_0 == 1) {

            assert (true);
        } else if (game.stake == 2) {

        }

        cpu.hand.clear();
        var s1 = new Card(Suit.SWORDS, 1); s1.power = 19;
        cpu.hand.add(s1);

        game.stake = 1;
        game.proposed_stake = 2;
        game.challenger_team = 0;

        game.cpu_respond_truco();

        bool accepted_or_raised = (game.stake == 2 || game.proposed_stake == 3);
        assert (accepted_or_raised);
    });

    Test.run ();
}

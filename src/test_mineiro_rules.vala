using Truco;

public void main(string[] args) {
    Test.init(ref args);
    
    Test.add_func("/game/mineiro/no_flor", () => {
        // Setup Mineiro Game
        var game = new GameState("mineiro");
        var p = game.players[0];
        
        // Force a Flor hand
        p.hand.clear();
        p.hand.add(new Card(Suit.SWORDS, 1));
        p.hand.add(new Card(Suit.SWORDS, 2));
        p.hand.add(new Card(Suit.SWORDS, 3));
        
        // Ensure it is first trick
        game.vaza_wins_team_0 = 0;
        game.vaza_wins_team_1 = 0;
        game.envido_available = true;
        game.state_envido_pending = false;
        game.envido_played = false;
        
        // Attempt to call Flor
        bool success = game.call_flor(0);
        
        assert(success == false);
    });

    Test.add_func("/game/paulista/no_flor", () => {
        var game = new GameState("paulista");
        var p = game.players[0];
        
        p.hand.clear();
        p.hand.add(new Card(Suit.SWORDS, 1));
        p.hand.add(new Card(Suit.SWORDS, 2));
        p.hand.add(new Card(Suit.SWORDS, 3));
        
        game.vaza_wins_team_0 = 0;
        game.vaza_wins_team_1 = 0;
        game.envido_available = true;
        game.state_envido_pending = false;
        game.envido_played = false;
        
        bool success = game.call_flor(0);
        assert(success == false);
    });

    Test.add_func("/game/argentino/flor_allowed", () => {
        var game = new GameState("argentino");
        var p = game.players[0];
        
        p.hand.clear();
        p.hand.add(new Card(Suit.SWORDS, 1));
        p.hand.add(new Card(Suit.SWORDS, 2));
        p.hand.add(new Card(Suit.SWORDS, 3));
        
        game.vaza_wins_team_0 = 0;
        game.vaza_wins_team_1 = 0;
        game.envido_available = true;
        game.state_envido_pending = false;
        game.envido_played = false;
        
        bool success = game.call_flor(0);
        assert(success == true);
    });

    Test.run();
}

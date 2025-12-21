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

    Test.add_func("/rules/mineiro/fixed_manilhas", () => {
        var engine = new RulesEngine();
        
        // 4 of Clubs (Zap) - Should be strongest
        var zap = new Card(Suit.CLUBS, 4);
        int p_zap = engine.get_power(zap, "mineiro");
        assert(p_zap == 14); 
        
        // 7 of Hearts (Copas)
        var copas = new Card(Suit.CUPS, 7);
        int p_copas = engine.get_power(copas, "mineiro");
        assert(p_copas == 13);
        
        // Ace of Spades (Espadilha)
        var espadilha = new Card(Suit.SWORDS, 1);
        int p_espadilha = engine.get_power(espadilha, "mineiro");
        assert(p_espadilha == 12);
        
        // 7 of Diamonds (Ouros)
        var ouros = new Card(Suit.GOLDS, 7);
        int p_ouros = engine.get_power(ouros, "mineiro");
        assert(p_ouros == 11);
        
        // Verify Vira doesn't change it
        var vira_dummy = new Card(Suit.GOLDS, 1); // If paulista, Manilha would be 2.
        int p_zap_with_vira = engine.get_power(zap, "mineiro", vira_dummy);
        assert(p_zap_with_vira == 14);
    });

    Test.run();
}

using GLib;
using Gee;
using Truco;

void main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/AI/Argentino/CardSelection", () => {
        // Setup minimal game state
        var game = new GameState("argentino", 1); // 1v1 vs CPU
        
        // Manually set CPU hand (Player 1)
        var cpu = game.players[1];
        cpu.hand.clear();
        
        // Give CPU: 1 of Swords (19), 3 of Cups (10), 4 of Coins (1)
        var c_best = new Card(Suit.SWORDS, 1); // Power 19
        var c_mid = new Card(Suit.CUPS, 3);    // Power 10
        var c_worst = new Card(Suit.GOLDS, 4); // Power 1
        
        // We need to ensure powers are calculated.
        // We can manually call rules_engine or rely on deal logic?
        // Game.calculate_powers is private.
        // So we set them manually using the public engine instance.
        c_best.power = game.rules_engine.get_power(c_best, "argentino");
        c_mid.power = game.rules_engine.get_power(c_mid, "argentino");
        c_worst.power = game.rules_engine.get_power(c_worst, "argentino");
        
        cpu.hand.add(c_worst);
        cpu.hand.add(c_best);
        cpu.hand.add(c_mid);
        
        // Scenario 1: CPU is first to play (Round start)
        game.current_player_index = 1;
        game.table_cards.clear();
        game.table_pids.clear();
        
        // AI Logic:
        // get_best_card_index(pid)
        // If first to play, usually plays low (conservative/balanced) or high (aggressive)?
        // Default behavior: "mostly play low".
        // Let's check get_best_card_index logic in Game.vala:
        // "Strategy: Play lowest unless partner has nothing... Normal logic: mostly play low, occasionally high."
        
        // We just want to ensure it RUNS and returns a valid index.
        int idx = game.get_best_card_index(1);
        assert (idx >= 0 && idx < 3);
        
        // Scenario 2: Opponent played a 3 (Power 10). CPU must beat it.
        // Opponent (Player 0) plays 3 of Golds
        var op_card = new Card(Suit.GOLDS, 3);
        op_card.power = game.rules_engine.get_power(op_card, "argentino"); // 10
        
        game.table_cards.add(op_card);
        game.table_pids.add(0);
        
        // CPU has: 1S (19), 3C (10), 4G (1).
        // 4G (1) loses.
        // 3C (10) ties (if 3C vs 3G? RulesEngine says 3 is 10. Tie.)
        // 1S (19) wins.
        
        // AI Logic for "Opponent winning":
        // "Find lowest card that BEATS target".
        // 1S (19) beats 10.
        // 3C (10) does NOT beat 10 (it equals). Logic: hand[i].power > target_power.
        // So 3C is not a candidate.
        // 4G (1) is not a candidate.
        // Only 1S is candidate.
        // So it should pick 1S (index 1).
        
        int idx_response = game.get_best_card_index(1);
        var chosen = cpu.hand[idx_response];
        
        // Assert CPU chose the 1 of Swords to win
        assert (chosen.suit == Suit.SWORDS && chosen.value == 1);
        
        // Scenario 3: Opponent played 7 of Golds (16).
        // CPU has 1S (19).
        // It should still pick 1S.
        game.table_cards.clear();
        game.table_pids.clear();
        var op_card2 = new Card(Suit.GOLDS, 7);
        op_card2.power = game.rules_engine.get_power(op_card2, "argentino");
        game.table_cards.add(op_card2);
        game.table_pids.add(0);
        
        idx_response = game.get_best_card_index(1);
        chosen = cpu.hand[idx_response];
        assert (chosen.suit == Suit.SWORDS && chosen.value == 1);
        
        // Scenario 4: Opponent played 1 of Clubs (18).
        // CPU has 1S (19).
        // Should pick 1S.
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

    Test.run ();
}

using GLib;
using Gee;
using Truco;

void main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/RulesEngine/Argentino/Hierarchy", () => {
        var engine = new RulesEngine ();
        
        // Espada 1 (Ace of Spades) > Basto 1 (Ace of Clubs)
        var e1 = new Card (Suit.SWORDS, 1);
        var b1 = new Card (Suit.CLUBS, 1);
        
        // Assert return values
        // Note: Currently RulesEngine.get_power returns 0 for everything, so these will fail (0 > 0 is false)
        assert (engine.get_power (e1, "argentino") > engine.get_power (b1, "argentino"));
        
        // Basto 1 > Espada 7
        var e7 = new Card (Suit.SWORDS, 7);
        assert (engine.get_power (b1, "argentino") > engine.get_power (e7, "argentino"));
        
        // Espada 7 > Oro 7
        var o7 = new Card (Suit.GOLDS, 7);
        assert (engine.get_power (e7, "argentino") > engine.get_power (o7, "argentino"));

        // 3s > 2s > 1s (cup/gold)
        var c3 = new Card (Suit.CUPS, 3);
        var c2 = new Card (Suit.CUPS, 2);
        var c1 = new Card (Suit.CUPS, 1); // Ancho falso
        
        assert (engine.get_power (c3, "argentino") > engine.get_power (c2, "argentino"));
        assert (engine.get_power (c2, "argentino") > engine.get_power (c1, "argentino"));
    });

    Test.add_func ("/RulesEngine/Argentino/Envido", () => {
        var engine = new RulesEngine ();
        
        // Two of same suit: 7 of Swords and 1 of Swords
        var hand1 = new ArrayList<Card> ();
        hand1.add (new Card (Suit.SWORDS, 7));
        hand1.add (new Card (Suit.SWORDS, 1));
        hand1.add (new Card (Suit.CLUBS, 3));
        
        // Score: 20 + 7 + 1 = 28
        assert (engine.get_envido_score (hand1) == 28);
        
        // Two figures of same suit: 10 and 11
        var hand2 = new ArrayList<Card> ();
        hand2.add (new Card (Suit.CUPS, 10));
        hand2.add (new Card (Suit.CUPS, 11));
        hand2.add (new Card (Suit.GOLDS, 7));
        
        // Score: 20 + 0 + 0 = 20
        assert (engine.get_envido_score (hand2) == 20);
        
        // All different suits: 1, 2, 3
        var hand3 = new ArrayList<Card> ();
        hand3.add (new Card (Suit.SWORDS, 1));
        hand3.add (new Card (Suit.CLUBS, 2));
        hand3.add (new Card (Suit.CUPS, 3));
        
        // Score: max(1, 2, 3) = 3 (since figures are 0 and numeric are themselves)
        // Wait, numeric 1, 2, 3 are numeric. 
        // Figures are 10, 11, 12.
        assert (engine.get_envido_score (hand3) == 3);

        // One figure, others diff
        var hand4 = new ArrayList<Card> ();
        hand4.add (new Card (Suit.SWORDS, 12));
        hand4.add (new Card (Suit.CLUBS, 2));
        hand4.add (new Card (Suit.CUPS, 3));
        assert (engine.get_envido_score (hand4) == 3);
    });

    Test.add_func ("/RulesEngine/Argentino/Flor", () => {
        var engine = new RulesEngine ();
        
        // 3 of same suit
        var hand1 = new ArrayList<Card> ();
        hand1.add (new Card (Suit.SWORDS, 7));
        hand1.add (new Card (Suit.SWORDS, 1));
        hand1.add (new Card (Suit.SWORDS, 2));
        
        assert (engine.has_flor (hand1));
        // Score: 20 + 7 + 1 + 2 = 30
        assert (engine.get_flor_score (hand1) == 30);
        
        // 3 figures of same suit
        var hand2 = new ArrayList<Card> ();
        hand2.add (new Card (Suit.CUPS, 10));
        hand2.add (new Card (Suit.CUPS, 11));
        hand2.add (new Card (Suit.CUPS, 12));
        
        assert (engine.has_flor (hand2));
        // Score: 20 + 0 + 0 + 0 = 20
        assert (engine.get_flor_score (hand2) == 20);
        
        // Not a flor
        var hand3 = new ArrayList<Card> ();
        hand3.add (new Card (Suit.SWORDS, 1));
        hand3.add (new Card (Suit.SWORDS, 2));
        hand3.add (new Card (Suit.CLUBS, 3));
        
        assert (!engine.has_flor (hand3));
        assert (engine.get_flor_score (hand3) == 0);
    });

    Test.add_func ("/RulesEngine/Argentino/FullHierarchy", () => {
        var engine = new RulesEngine ();
        
        Suit s = Suit.SWORDS;
        
        // 1S (19) > 1C (18) > 7S (17) > 7G (16)
        assert (engine.get_power (new Card(Suit.SWORDS, 1), "argentino") == 19);
        assert (engine.get_power (new Card(Suit.CLUBS, 1), "argentino") == 18);
        assert (engine.get_power (new Card(Suit.SWORDS, 7), "argentino") == 17);
        assert (engine.get_power (new Card(Suit.GOLDS, 7), "argentino") == 16);
        
        // > 3 (10) > 2 (9) > 1FG (8) > 12 (7) > 11 (6) > 10 (5) > 7CC (4) > 6 (3) > 5 (2) > 4 (1)
        assert (engine.get_power (new Card(s, 3), "argentino") == 10);
        assert (engine.get_power (new Card(s, 2), "argentino") == 9);
        assert (engine.get_power (new Card(Suit.CUPS, 1), "argentino") == 8);
        assert (engine.get_power (new Card(s, 12), "argentino") == 7);
        assert (engine.get_power (new Card(s, 11), "argentino") == 6);
        assert (engine.get_power (new Card(s, 10), "argentino") == 5);
        assert (engine.get_power (new Card(Suit.CUPS, 7), "argentino") == 4);
        assert (engine.get_power (new Card(s, 6), "argentino") == 3);
        assert (engine.get_power (new Card(s, 5), "argentino") == 2);
        assert (engine.get_power (new Card(s, 4), "argentino") == 1);
    });

    Test.run ();
}

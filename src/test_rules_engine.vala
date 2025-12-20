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

    Test.run ();
}

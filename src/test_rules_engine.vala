using GLib;
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

    Test.run ();
}

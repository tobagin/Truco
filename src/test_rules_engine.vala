using GLib;
using Gee;
using Truco;

void main (string[] args) {
    Test.init (ref args);

    Test.add_func ("/RulesEngine/Argentino/Hierarchy", () => {
        var engine = new RulesEngine ();

        var e1 = new Card (Suit.SWORDS, 1);
        var b1 = new Card (Suit.CLUBS, 1);

        assert (engine.get_power (e1, "argentino") > engine.get_power (b1, "argentino"));

        var e7 = new Card (Suit.SWORDS, 7);
        assert (engine.get_power (b1, "argentino") > engine.get_power (e7, "argentino"));

        var o7 = new Card (Suit.GOLDS, 7);
        assert (engine.get_power (e7, "argentino") > engine.get_power (o7, "argentino"));

        var c3 = new Card (Suit.CUPS, 3);
        var c2 = new Card (Suit.CUPS, 2);
        var c1 = new Card (Suit.CUPS, 1);

        assert (engine.get_power (c3, "argentino") > engine.get_power (c2, "argentino"));
        assert (engine.get_power (c2, "argentino") > engine.get_power (c1, "argentino"));
    });

    Test.add_func ("/RulesEngine/Argentino/Envido", () => {
        var engine = new RulesEngine ();

        var hand1 = new ArrayList<Card> ();
        hand1.add (new Card (Suit.SWORDS, 7));
        hand1.add (new Card (Suit.SWORDS, 1));
        hand1.add (new Card (Suit.CLUBS, 3));

        assert (engine.get_envido_score (hand1) == 28);

        var hand2 = new ArrayList<Card> ();
        hand2.add (new Card (Suit.CUPS, 10));
        hand2.add (new Card (Suit.CUPS, 11));
        hand2.add (new Card (Suit.GOLDS, 7));

        assert (engine.get_envido_score (hand2) == 20);

        var hand3 = new ArrayList<Card> ();
        hand3.add (new Card (Suit.SWORDS, 1));
        hand3.add (new Card (Suit.CLUBS, 2));
        hand3.add (new Card (Suit.CUPS, 3));

        assert (engine.get_envido_score (hand3) == 3);

        var hand4 = new ArrayList<Card> ();
        hand4.add (new Card (Suit.SWORDS, 12));
        hand4.add (new Card (Suit.CLUBS, 2));
        hand4.add (new Card (Suit.CUPS, 3));
        assert (engine.get_envido_score (hand4) == 3);
    });

    Test.add_func ("/RulesEngine/Argentino/Flor", () => {
        var engine = new RulesEngine ();

        var hand1 = new ArrayList<Card> ();
        hand1.add (new Card (Suit.SWORDS, 7));
        hand1.add (new Card (Suit.SWORDS, 1));
        hand1.add (new Card (Suit.SWORDS, 2));

        assert (engine.has_flor (hand1));

        assert (engine.get_flor_score (hand1) == 30);

        var hand2 = new ArrayList<Card> ();
        hand2.add (new Card (Suit.CUPS, 10));
        hand2.add (new Card (Suit.CUPS, 11));
        hand2.add (new Card (Suit.CUPS, 12));

        assert (engine.has_flor (hand2));

        assert (engine.get_flor_score (hand2) == 20);

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

        assert (engine.get_power (new Card(Suit.SWORDS, 1), "argentino") == 19);
        assert (engine.get_power (new Card(Suit.CLUBS, 1), "argentino") == 18);
        assert (engine.get_power (new Card(Suit.SWORDS, 7), "argentino") == 17);
        assert (engine.get_power (new Card(Suit.GOLDS, 7), "argentino") == 16);

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

using Gee;

namespace Truco {
    public class RulesEngine : Object {
        public RulesEngine() {
        }

        public int get_power(Card c, string mode, Card? vira = null, bool manilha_fixed = false) {
            if (manilha_fixed) return get_fixed_power(c);
            
            switch (mode) {
                case "paulista":
                    int manilha_val = 0;
                    if (vira != null) {
                        manilha_val = vira.value + 1;
                        if (manilha_val > 12) manilha_val = 1; 
                        if (manilha_val == 8) manilha_val = 10;
                    }
                    return get_paulista_power(c, manilha_val);
                case "mineiro":
                    return get_mineiro_power(c);
                case "argentino":
                case "uruguayo":
                case "venezolano":
                    return get_international_power(c, mode, vira);
                default:
                    return get_base_power(c);
            }
        }

        private int get_fixed_power(Card c) {
            // Truco de Reis: Kings are manilhas
            if (c.value == 12) {
                 switch (c.suit) {
                     case Suit.CLUBS: return 34;
                     case Suit.CUPS: return 33;
                     case Suit.SWORDS: return 32;
                     case Suit.GOLDS: return 31;
                 }
            }
            return get_base_power(c);
        }

        private int get_paulista_power(Card c, int manilha_val) {
            if (c.value == manilha_val) {
                 switch (c.suit) {
                     case Suit.CLUBS: return 14;
                     case Suit.CUPS: return 13;
                     case Suit.SWORDS: return 12;
                     case Suit.GOLDS: return 11;
                 }
            }
            return get_base_power(c);
        }

        private int get_mineiro_power(Card c) {
             if (c.suit == Suit.CLUBS && c.value == 4) return 14;
             if (c.suit == Suit.CUPS && c.value == 7) return 13;
             if (c.suit == Suit.SWORDS && c.value == 1) return 12;
             if (c.suit == Suit.GOLDS && c.value == 7) return 11;
             return get_base_power(c);
        }

        private int get_international_power(Card c, string mode, Card? vira) {
            // Check Special Cards first
            if (mode == "uruguayo" && vira != null) {
                if (c.suit == vira.suit) {
                    if (c.value == 2) return 24;
                    if (c.value == 4) return 23;
                    if (c.value == 5) return 22;
                    if (c.value == 11) return 21;
                    if (c.value == 10) return 20;
                }
            } else if (mode == "venezolano" && vira != null) {
                if (c.suit == vira.suit) {
                    if (c.value == 11) return 21; // Perico
                    if (c.value == 10) return 20; // Perica
                }
            }

            // Standard / Argentine Hierarchy (Cartas Bravas)
            // 1S > 1C > 7S > 7D
            if (c.suit == Suit.SWORDS && c.value == 1) return 19;
            if (c.suit == Suit.CLUBS && c.value == 1) return 18;
            if (c.suit == Suit.SWORDS && c.value == 7) return 17;
            if (c.suit == Suit.GOLDS && c.value == 7) return 16;
            
            return get_base_power(c);
        }

        private int get_base_power(Card c) {
            switch (c.value) {
                case 3: return 10;
                case 2: return 9;
                case 1: return 8;
                case 12: return 7;
                case 11: return 6;
                case 10: return 5;
                case 7: return 4;
                case 6: return 3;
                case 5: return 2;
                case 4: return 1;
                default: return 0;
            }
        }

        public int get_envido_score(ArrayList<Card> hand) {
            int max_score = 0;
            
            // Check all pairs for 20 + sum
            for (int i = 0; i < hand.size; i++) {
                for (int j = i + 1; j < hand.size; j++) {
                    if (hand[i].suit == hand[j].suit) {
                        int val1 = (hand[i].value >= 10) ? 0 : hand[i].value;
                        int val2 = (hand[j].value >= 10) ? 0 : hand[j].value;
                        int score = 20 + val1 + val2;
                        if (score > max_score) max_score = score;
                    }
                }
            }
            
            // If < 20, it means no pair was found
            if (max_score < 20) {
                 for (int i = 0; i < hand.size; i++) {
                      int val = (hand[i].value >= 10) ? 0 : hand[i].value;
                      if (val > max_score) max_score = val;
                 }
            }
            
            return max_score;
        }

        public bool has_flor(ArrayList<Card> hand) {
            if (hand.size != 3) return false;
            return (hand[0].suit == hand[1].suit && hand[1].suit == hand[2].suit);
        }

        public int get_flor_score(ArrayList<Card> hand) {
            if (!has_flor(hand)) return 0;
            int sum = 0;
            foreach (var c in hand) {
                int val = (c.value >= 10) ? 0 : c.value;
                sum += val;
            }
            return 20 + sum;
        }
    }
}

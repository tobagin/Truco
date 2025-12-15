using Gee;

namespace Truco {

    public enum Suit {
        SWORDS,
        CLUBS,
        GOLDS,
        CUPS;

        public string to_localized_string() {
            switch (this) {
                case SWORDS: return _("Swords");
                case CLUBS: return _("Clubs");
                case GOLDS: return _("Golds");
                case CUPS: return _("Cups");
                default: return "";
            }
        }
    }

    public class Card : Object {
        public Suit suit { get; set; }
        public int value { get; set; }
        public int power { get; set; }

        public Card(Suit suit, int value, int power = 0) {
            this.suit = suit;
            this.value = value;
            this.power = power;
        }

        public string to_string() {
            // Translate values?
            string v_str = value.to_string();
            if (value == 1) v_str = _("Ace");
            else if (value == 11) v_str = _("Jack");
            else if (value == 12) v_str = _("King");
            else if (value == 10) v_str = _("Queen");
            
            return _("%s of %s").printf(v_str, suit.to_localized_string());
        }

        public string get_svg_name() {
             string s = "";
             switch (suit) {
                 case Suit.CLUBS: s = "clubs"; break;
                 case Suit.GOLDS: s = "diamonds"; break;
                 case Suit.CUPS: s = "hearts"; break;
                 case Suit.SWORDS: s = "spades"; break;
             }
             

             string v = "";
             switch (value) {
                 case 1: v = "ace"; break;
                 case 11: v = "jack"; break;
                 case 12: v = "king"; break;
                 case 10: v = "queen"; break; // Truco 8,9,10 are missing usually or 10 is Q?
                 // Truco deck: A, 2, 3, 4, 5, 6, 7, Q(10), J(11), K(12)
                 // SVG files: 10_of_..., jack(11), queen(12), king(13)?
                 // Let's check SVG listing again.
                 // 10_, jack_, queen_, king_.
                 // Truco Value 10 is usually Queen (Dama). Value 11 is Jack (Valete). Value 12 is King (Rei).
                 // Wait, standard Truco:
                 // 8, 9, 10 are removed.
                 // Faces are Q, J, K.
                 // In my Game.vala: values are 1..7, 10, 11, 12.
                 // Value 10 -> is it 10 or Queen?
                 // Truco Mineiro/Paulista: 4,5,6,7,Q,J,K,A,2,3.
                 // So 8,9,10 numeric are out.
                 // Q=8? No.
                 // Let's assume my logic uses 10 for Q, 11 for J, 12 for K?
                 // Or 10 is 10?
                 // Let's look at Game logic powers.
                 // Case 10: power=5. Case 11: power=6. Case 12: power=7.
                 // Power 5,6,7. 
                 // 4=1, 5=2, 6=3, 7=4.
                 // So 10 is the lowest face.
                 // Q, J, K order?
                 // Usually Q < J < K.
                 // So 10 is Q.
                 // 11 is J.
                 // 12 is K.
                 default: v = value.to_string(); break;
             }
             
             if (value == 10) v = "queen";
             if (value == 11) v = "jack"; 
             if (value == 12) v = "king";

             return "cards/%s_of_%s.svg".printf(v, s);
        }
    }

    public class Player : Object {
        public int id { get; set; }
        public string name { get; set; }
        public ArrayList<Card> hand { get; set; }
        public bool is_cpu { get; set; }
        public int team { get; set; }
        public string avatar_icon { get; set; default = "avatars/avatar1.svg"; } // Default

        public Player(int id, string name, bool is_cpu, int team) {
            this.id = id;
            this.name = name;
            this.is_cpu = is_cpu;
            this.team = team;
            this.hand = new ArrayList<Card>();
            
            if (is_cpu) {
                // Randomize avatar 1-58
                int num = Random.int_range(1, 59);
                this.avatar_icon = "avatars/avatar%d.svg".printf(num);
            } else {
                // Default for human
                this.avatar_icon = "avatars/avatar1.svg"; 
            }
        }
    }

    public struct HistoryItem {
        public int player_id; // -1 for system
        public string message;
        
        public HistoryItem(int pid, string msg) {
            this.player_id = pid;
            this.message = msg;
        }
    }

    public class GameState : Object {
        public ArrayList<Player> players;
        public int current_player_index;
        public int score_team_0;
        public int score_team_1;
        public int matches_won_team_0;
        public int matches_won_team_1;
        public bool match_over = false;
        public bool game_over = false;

        public const int MAX_POINTS = 12;
        public const int GAMES_TO_WIN_MATCH = 2; // Best of 3
        
        // Statistics
        public int total_rounds_played = 0;
        public int rounds_won_team_0 = 0;
        public int rounds_won_team_1 = 0;

        public signal void match_ended(int winning_team);
        public signal void game_ended(int winning_team);

        public ArrayList<Card?> table_cards;
        public ArrayList<int> table_pids; // Player IDs corresponding to table cards
        public int vaza_wins_team_0;
        public int vaza_wins_team_1;
        public int stake = 1;
        
        public int round_count = 1;
        public int? proposed_stake = null;
        public int? challenger_team = null;
        
        public string game_mode;
        public Card? vira;
        public ArrayList<HistoryItem?> history;

        public GameState(string mode) {
            this.game_mode = mode;
            this.players = new ArrayList<Player>();
            this.history = new ArrayList<HistoryItem?>();
            this.table_cards = new ArrayList<Card?>();
            this.table_pids = new ArrayList<int>();
            
            // Teams: 0 (You + Partner), 1 (Opponents)
            players.add(new Player(0, _("You"), false, 0));
            players.add(new Player(1, _("CPU 1"), true, 1));
            players.add(new Player(2, _("Partner"), true, 0));
            players.add(new Player(3, _("CPU 3"), true, 1));

            reset_match();
        }
        
        public void reset_match() {
            matches_won_team_0 = 0;
            matches_won_team_1 = 0;
            total_rounds_played = 0;
            rounds_won_team_0 = 0;
            rounds_won_team_1 = 0;
            match_over = false;
            history.clear();
            history.add(HistoryItem(-1, _("Match Started!")));
            reset_game_score();
        }

        public void reset_game_score() {
            score_team_0 = 0;
            score_team_1 = 0;
            history.add(HistoryItem(-1, _("New Game Started. Score 0-0.")));
            game_over = false;
            round_count = 0; // Reset round count for a new game
            start_round();
        }

        private void start_round() {
            vaza_wins_team_0 = 0;
            vaza_wins_team_1 = 0;
            stake = 1;
            proposed_stake = null;
            challenger_team = null;
            
            table_cards.clear();
            table_pids.clear();
            
            // Increment round count here? Or was it doubled?
            // reset_game calls start_round.
            // collect_trick calls start_round.
            // So round_count++ should be here.
            round_count++; 
            
            // history.add("Round %d started.".printf(round_count)); // Logged in deal_cards? No, do it here.
            history.add(HistoryItem(-1, _("Round %d started.").printf(round_count)));

            deal_cards();
            
            // Ensure turn starts with correct player?
            // Usually winner of last round starts.
            // For now, keep rotation or simplified logic.
            current_player_index = 0; // Rotate dealer in real game, simple for now
        }

        private void deal_cards() {
            var deck = create_deck();
            // Simple shuffle (fisher-yates)
            for (int i = deck.size - 1; i > 0; i--) {
                int j = Random.int_range(0, i + 1);
                var temp = deck[i];
                deck[i] = deck[j];
                deck[j] = temp;
            }

            foreach (var p in players) {
                p.hand.clear();
                for (int i = 0; i < 3; i++) {
                    if (deck.size > 0) p.hand.add(deck.remove_at(0));
                }
            }

            if (deck.size > 0 && (game_mode == "paulista" || game_mode == "uruguayo" || game_mode == "venezolano")) {
                vira = deck.remove_at(0);
            } else {
                vira = null;
            }
            
            calculate_powers();
        }

        private ArrayList<Card> create_deck() {
            var deck = new ArrayList<Card>();
            Suit[] suits = { Suit.SWORDS, Suit.CLUBS, Suit.GOLDS, Suit.CUPS };
            int[] values = { 1, 2, 3, 4, 5, 6, 7, 10, 11, 12 };

            foreach (var s in suits) {
                foreach (var v in values) {
                    deck.add(new Card(s, v));
                }
            }
            return deck;
        }

        private void calculate_powers() {
            int manilha_val = 0;
            if (game_mode == "paulista" && vira != null) {
                manilha_val = vira.value + 1;
                if (manilha_val > 12) manilha_val = 1; 
                if (manilha_val == 8) manilha_val = 10;
            }

            foreach (var p in players) {
                foreach (var c in p.hand) {
                    if (game_mode == "paulista") c.power = get_paulista_power(c, manilha_val);
                    else if (game_mode == "mineiro") c.power = get_mineiro_power(c);
                    else c.power = get_international_power(c); // Uruguayo, Venezolano, Argentino
                }
            }
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

        private int get_international_power(Card c) {
            // Check Special Cards first
            if (game_mode == "uruguayo" && vira != null) {
                if (c.suit == vira.suit) {
                    if (c.value == 2) return 24;
                    if (c.value == 4) return 23;
                    if (c.value == 5) return 22;
                    if (c.value == 11) return 21;
                    if (c.value == 10) return 20;
                }
            } else if (game_mode == "venezolano" && vira != null) {
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

        public bool play_card(int player_id, int card_index) {
            if (proposed_stake != null) return false;
            if (current_player_index != player_id) return false;
            
            var p = players[player_id];
            if (card_index >= p.hand.size) return false;

            var card = p.hand.remove_at(card_index);
            table_cards.add(card);
            table_pids.add(player_id);

            // History: Just the card name, Avatar provides context
            history.add(HistoryItem(player_id, card.to_string()));

            advance_turn();
            return true;
        }
        
        public bool raise_stake(int player_id) {
            // Allow counter-raising! 
            // Only forbid if we are the ones who proposed it (cannot raise own proposal immediately)
            if (proposed_stake != null && players[player_id].team == challenger_team) return false;
            
            if (stake >= 12 && proposed_stake == null) return false; // Max reached
            if (proposed_stake != null && proposed_stake >= 12) return false; // Cannot raise beyond 12

            if (score_team_0 == 11 || score_team_1 == 11) return false; // Mão de 11/Ferro forbidden
            
            int current_val = (proposed_stake != null) ? proposed_stake : stake;
            int next = 0;
            
            if (current_val == 1) next = 3;
            else if (current_val == 3) next = 6;
            else if (current_val == 6) next = 9;
            else next = 12;
            
            if (next <= current_val) return false; // Safety check

            proposed_stake = next;
            challenger_team = players[player_id].team;
            
            string msg = _("Called Truco!");
            if (next == 6) msg = _("Called Six!");
            else if (next == 9) msg = _("Called Nine!");
            else if (next == 12) msg = _("Called Twelve!");
            
            history.add(HistoryItem(player_id, msg));
            return true;
        }

        public void respond_challenge(int player_id, bool accept) {
            if (proposed_stake == null) return;
            
            if (accept) {
                stake = proposed_stake;
                proposed_stake = null;
                challenger_team = null;
                history.add(HistoryItem(player_id, _("Accepted! Stake is now %d").printf(stake)));
            } else {
                // Fold
                int winner = (challenger_team == 0) ? 0 : 1;
                history.add(HistoryItem(player_id, _("Refused!")));
                
                string win_msg = (winner == 0) ? _("Your team won the round!") : _("Opponent team won the round!");
                history.add(HistoryItem(-1, win_msg));
                 // Points awarded is PREVIOUS stake
                if (winner == 0) score_team_0 += stake;
                else score_team_1 += stake;
                
                start_round(); // New round
            }
        }
        
        public void cpu_respond_truco() {
            // Find a CPU player from the challenging team? No, from the responding team.
            if (challenger_team == null) return;
            int responding_team = (challenger_team == 0) ? 1 : 0;
            
            // Find a CPU player in responding team
            int cpu_pid = -1;
            foreach (var p in players) {
                if (p.team == responding_team && p.is_cpu) {
                    cpu_pid = p.id;
                    break;
                }
            }
            
            if (cpu_pid != -1) {
                // Reuse logic from cpu_turn for decision
                  int strength = 0;
                  foreach (var c in players[cpu_pid].hand) {
                      strength += c.power;
                  }
                  
                  bool accept = false;
                  // More aggressive if already invested?
                  if (strength > 15) accept = true; 
                  else if (strength > 10 && Random.double_range(0.0, 1.0) > 0.3) accept = true; 
                  else if (Random.double_range(0.0, 1.0) > 0.7) accept = true; 
                  
                  respond_challenge(cpu_pid, accept);
            }
        }

        public void cpu_turn() {
            int pid = current_player_index;
            if (!players[pid].is_cpu) return;

            // Simple Logic
            // If challenged, evaluate hand strength
             if (proposed_stake != null) {
                 if (challenger_team != players[pid].team) {
                      cpu_respond_truco(); // Delegate
                 }
                 return;
             }

            // Truco Calling Logic
             // Do not call Truco if anyone has 11 points (Mão de 11 usually forbids it)
             bool can_call_truco = (score_team_0 != 11 && score_team_1 != 11 && stake < 12 && proposed_stake == null);
             
             if (can_call_truco) {
                  int hand_strength = 0;
                  foreach (var c in players[pid].hand) {
                      hand_strength += c.power;
                  }
                  
                  // Simple heuristic for calling Truco
                  // If hand strength is high, maybe call Truco?
                  // Max power for 3 cards is around ~40 (e.g. 14+13+12 in Manilhas) or similar.
                  // Let's say if strength > 20, we have a good hand.
                  if (hand_strength > 22 && Random.double_range(0.0, 1.0) > 0.6) {
                      raise_stake(pid);
                      return; // Wait for response
                  }
                  // Bluff
                  if (hand_strength < 10 && Random.double_range(0.0, 1.0) > 0.95) {
                       raise_stake(pid);
                       return;
                  }
             }

            // Play card
            if (players[pid].hand.size > 0) {
                 // Simple: Play highest card if we can win, or lowest if we can't?
                 // Current: Random (index 0)
                 
                 // Let's just play random for now, logic task was about raising stakes response
                 int idx = Random.int_range(0, players[pid].hand.size);
                 play_card(pid, idx);
            } else {
                 // Should not happen, stuck?
                 advance_turn();
            }
        }

        private void advance_turn() {
            current_player_index = (current_player_index + 1) % 4;
            
            // Check trick end
            if (table_cards.size == 4) {
                collect_trick();
            }
        }

        private void collect_trick() {
            // Determine winner
            int best_pow = -1;
            int best_pid = -1;
            
            for (int i = 0; i < 4; i++) {
                var c = table_cards[i];
                if (c.power > best_pow) {
                    best_pow = c.power;
                    best_pid = table_pids[i];
                }
            }

            int winner_team = players[best_pid].team;
            if (winner_team == 0) vaza_wins_team_0++;
            else vaza_wins_team_1++;

            table_cards.clear();
            table_pids.clear();
            current_player_index = best_pid; // Winner starts

            // Check Round End
            if (vaza_wins_team_0 >= 2 || vaza_wins_team_1 >= 2) {
                total_rounds_played++;
                if (vaza_wins_team_0 >= 2) {
                    score_team_0 += stake;
                    rounds_won_team_0++;
                } else {
                    score_team_1 += stake;
                    rounds_won_team_1++;
                }
                
                check_game_end_conditions();
            }
        }
        
        private void check_game_end_conditions() {
             if (score_team_0 >= MAX_POINTS || score_team_1 >= MAX_POINTS) {
                 // Cap score for display beauty
                 if (score_team_0 > MAX_POINTS) score_team_0 = MAX_POINTS;
                 if (score_team_1 > MAX_POINTS) score_team_1 = MAX_POINTS;
                 
                 int winner_team = (score_team_0 >= MAX_POINTS) ? 0 : 1;
                 
                 if (winner_team == 0) matches_won_team_0++;
                 else matches_won_team_1++;
                 
                 history.add(HistoryItem(-1, (winner_team == 0) ? _("Team US wins the Game!") : _("Team THEM wins the Game!")));
                 game_over = true;
                 game_ended(winner_team); // Signal
                 
                 // Check Match Win
                 // For now, let's treat 1 game as match for simplicity or keep logic
                 // If GAMES_TO_WIN_MATCH is used, we check that.
                 // Assuming user wants simple "Match Over" when someone reaches 12 for this session
                 
                 // If we strictly follow "Points do Jogo" as match score:
                 if (matches_won_team_0 >= GAMES_TO_WIN_MATCH || matches_won_team_1 >= GAMES_TO_WIN_MATCH) {
                     history.add(HistoryItem(-1, (winner_team == 0) ? _("Team US wins the Match!") : _("Team THEM wins the Match!")));
                     match_over = true;
                     match_ended(winner_team);
                     return; 
                 } else {
                     // Start new game automatically?
                     // reset_game_score(); // this starts new round immediately
                     // Ideally we verify if we want auto-restart or wait for user.
                     // UI handles game_ended signal, maybe shows "Game Won! Next Game?".
                     // For now, let's auto-reset game score to continue match.
                     reset_game_score();
                 }
             } else {
                 start_round();
             }
        }
    }
}

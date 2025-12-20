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

        public string get_svg_name(int style = 0) {
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

             string style_dir = "modern-simple";
             if (style == 1) style_dir = "modern-faces";
             if (style == 2) style_dir = "spanish";
             if (style == 3) style_dir = "french";

             return "cards/%s/%s_of_%s.svg".printf(style_dir, v, s);
        }
    }

    public enum Personality {
        BALANCED,
        AGGRESSIVE,
        CONSERVATIVE,
        GAMBLER
    }

    private class MCTSNode {
        public int card_index;
        public int wins;
        public int visits;

        public MCTSNode(int idx) {
            this.card_index = idx;
            this.wins = 0;
            this.visits = 0;
        }
    }

    public class Player : Object {

        public int id { get; set; }
        public string name { get; set; }
        public ArrayList<Card> hand { get; set; }
        public bool is_cpu { get; set; }
        public int team { get; set; }
        public Personality personality { get; set; }
        public string? last_signal { get; set; }
        public string avatar_icon { get; set; default = "avatars/avatar1.svg"; } // Default

        public Player(int id, string name, bool is_cpu, int team) {
            this.id = id;
            this.name = name;
            this.is_cpu = is_cpu;
            this.team = team;
            this.hand = new ArrayList<Card>();
            
            if (is_cpu) {
                // Randomize personality for CPUs
                int p_num = Random.int_range(0, 4);
                this.personality = (Personality)p_num;

                // Randomize avatar 1-58
                int num = Random.int_range(1, 59);
                this.avatar_icon = "avatars/avatar%d.svg".printf(num);
            } else {
                // Default for human
                this.avatar_icon = "avatars/avatar1.svg"; 
            }
        }

        public int get_winner_team(ArrayList<Card> cards) {
             // To be implemented or handled in resolve
             return -1;
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
        public ScoreManager score_manager;
        public int matches_won_team_0;
        public int matches_won_team_1;
        public bool match_over = false;
        public bool game_over = false;

        public const int GAMES_TO_WIN_MATCH = 2; // Best of 3
        
        public int get_max_points() {
            if (game_mode == "argentino") return 30;
            if (game_mode == "uruguayo") return 40;
            if (game_mode == "venezolano") return 24;
             // Paulista / Mineiro
            return 12;
        }

        // Statistics
        public int total_rounds_played = 0;
        public int rounds_won_team_0 = 0;
        public int rounds_won_team_1 = 0;

        public signal void match_ended(int winning_team);
        public signal void game_ended(int winning_team);
        public signal void turn_advanced();
        public signal void show_partner_cards();

        public ArrayList<Card?> table_cards;
        public ArrayList<int> table_pids; // Player IDs corresponding to table cards
        public int vaza_wins_team_0;
        public int vaza_wins_team_1;
        public int stake = 1;
        
        public int round_count = 1;
        public int? proposed_stake = null;
        public int? challenger_team = null;
        public bool state_mao_11_pending = false;

        // Envido State
        public bool envido_available = true;
        public int envido_stake = 0;
        public int? envido_challenger_team = null;
        public bool state_envido_pending = false;
        public bool envido_played = false; // Only one envido per round
        
        public string game_mode;
        public Card? vira;
        public ArrayList<HistoryItem?> history;

        // Custom House Rules
        public bool manilha_fixed = false; // Truco de Reis
        public bool hidden_vira = false;
        private RulesEngine rules_engine;

        public GameState(string mode, int team_size = 2, bool fixed_manilha = false, bool hide_vira = false) {
            this.game_mode = mode;
            this.manilha_fixed = fixed_manilha;
            this.hidden_vira = hide_vira;
            this.rules_engine = new RulesEngine();
            this.score_manager = new ScoreManager(get_max_points());
            this.players = new ArrayList<Player>();
            this.history = new ArrayList<HistoryItem?>();
            this.table_cards = new ArrayList<Card?>();
            this.table_pids = new ArrayList<int>();
            
            // Teams: 0 (You + Partners), 1 (Opponents)
            players.add(new Player(0, _("You"), false, 0)); // User
            
            if (team_size == 1) {
                players.add(new Player(1, _("CPU 1"), true, 1)); // Opponent
            } else if (team_size == 2) {
                players.add(new Player(1, _("CPU 1"), true, 1)); // Opponent 1
                players.add(new Player(2, _("Partner"), true, 0)); // Partner
                players.add(new Player(3, _("CPU 3"), true, 1)); // Opponent 2
            } else if (team_size == 3) {
                players.add(new Player(1, _("CPU 1"), true, 1)); // Opponent 1
                players.add(new Player(2, _("Partner 1"), true, 0)); // Partner 1
                players.add(new Player(3, _("CPU 2"), true, 1)); // Opponent 2
                players.add(new Player(4, _("Partner 2"), true, 0)); // Partner 2
                players.add(new Player(5, _("CPU 3"), true, 1)); // Opponent 3
            }

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
            dealer_index = players.size - 2; // Set so next increment makes it size-1, and (size-1+1)%size = 0 (Player starts)
            reset_game_score();
        }

        public void reset_game_score() {
            score_manager.reset();
            history.add(HistoryItem(-1, _("New Game Started. Score 0-0.")));
            game_over = false;
            round_count = 0; // Reset round count for a new game
            start_round();
        }

        public int dealer_index = 3; // Default

        private void start_round() {
            vaza_wins_team_0 = 0;
            vaza_wins_team_1 = 0;
            stake = 1;
            proposed_stake = null;
            challenger_team = null;
            
            table_cards.clear();
            table_pids.clear();
            
            // Round rules:
            // 1st round of hand: Envido available
            // 2nd, 3rd: Not available
            // Start of a new hand: Envido is always available initially
            envido_available = true;
            envido_played = false;
            
            // Increment round count here? Or was it doubled?
            // reset_game calls start_round.
            // collect_trick calls start_round.
            // So round_count++ should be here.
            round_count++; 
            
            // history.add("Round %d started.".printf(round_count)); // Logged in deal_cards? No, do it here.
            history.add(HistoryItem(-1, _("Round %d started.").printf(round_count)));

            deal_cards();
            
            // Rotate dealer
            dealer_index = (dealer_index + 1) % players.size;
            current_player_index = (dealer_index + 1) % players.size; 
            
            history.add(HistoryItem(-1, _("%s starts the round.").printf(players[current_player_index].name)));
            
            // Check Mão de 11
            state_mao_11_pending = false;
            
            // Mão de Ferro: Both 11. Usually played "in the dark" (blind).
            int limit = get_max_points();
            if (score_manager.score_team_0 == limit - 1 && score_manager.score_team_1 == limit - 1) {
                 history.add(HistoryItem(-1, _("Mão de Ferro! Players plays blind!")));
                 // Logic to hide cards? For now just allow play, but no Truco.
                 // We don't need pending state for Ferro, just Truco disabled (handled in raise_stake)
            } 
            else if (score_manager.score_team_0 == limit - 1 || score_manager.score_team_1 == limit - 1) {
                // One team is at limit - 1.
                // Only standard Mão de 11 for Brazilian variants
                if (game_mode == "paulista" || game_mode == "mineiro") {
                    state_mao_11_pending = true;
                    
                    int team_critical = (score_manager.score_team_0 == limit - 1) ? 0 : 1;
                    string t_name = (team_critical == 0) ? _("YOUR TEAM") : _("OPPONENT TEAM");
                    history.add(HistoryItem(-1, _("Mão de 11 for %s! Deciding...").printf(t_name)));
                    
                    if (team_critical == 0) {
                        show_partner_cards(); // Signal UI
                    }
                }
            }
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
                p.last_signal = null;
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
            foreach (var p in players) {
                foreach (var c in p.hand) {
                    c.power = rules_engine.get_power(c, game_mode, vira, manilha_fixed);
                }
            }
        }

        public bool play_card(int player_id, int card_index) {

            if (proposed_stake != null) return false;
            // If in Mão de 11 pending state, only allow explicit acceptance/run interactions or specific flow?
            // Actually, playing a card *is* how you start if you are dealer/first player? 
            // No, Mão de 11 requires a dialog decision FIRST.
            if (state_mao_11_pending || state_envido_pending) return false;

            if (current_player_index != player_id) return false;
            
            var p = players[player_id];
            if (card_index >= p.hand.size) return false;

            var card = p.hand.remove_at(card_index);
            table_cards.add(card);
            table_pids.add(player_id);

            // History: Just the card name, Avatar provides context
            history.add(HistoryItem(player_id, card.to_string()));
            
            SoundManager.get_default().play("card_snap");

            advance_turn();
            return true;
        }
        
        public bool raise_stake(int player_id) {
            // Allow counter-raising! 
            // Only forbid if we are the ones who proposed it (cannot raise own proposal immediately)
            if (proposed_stake != null && players[player_id].team == challenger_team) return false;
            
            int limit = 12; // Default limit for betting values
            if (game_mode == "venezolano") limit = 5; // To check progression
            
            // If already at max betting value standard for the variant
            // Brazil: 12. Int'l: 4. Ven: ?
            
            // Simplified check: if current stake is "Vale Game" equivalent, return false.
            if (game_mode == "paulista" || game_mode == "mineiro") {
                if (stake >= 12 && proposed_stake == null) return false;
                if (proposed_stake != null && proposed_stake >= 12) return false;
            } else if (game_mode == "argentino" || game_mode == "uruguayo") {
                if (stake >= 4 && proposed_stake == null) return false; 
                if (proposed_stake != null && proposed_stake >= 4) return false;
            } else if (game_mode == "venezolano") {
                // If Truco (3) is max direct bet usually? 
                // Let's assume typical 1 -> 3 -> 4 -> 5 progression found in some sources or similar
                if (stake >= 5 && proposed_stake == null) return false;
            }

            if (score_manager.score_team_0 == get_max_points() - 1 || score_manager.score_team_1 == get_max_points() - 1) return false; // Mão de 11/Ferro forbidden (generic -1)
            
            // Calculate next stake
            int next = 0;
            int current_val = (proposed_stake != null) ? proposed_stake : stake;
            
            if (game_mode == "paulista" || game_mode == "mineiro") {
                // 1 -> 3 -> 6 -> 9 -> 12
                if (current_val == 1) next = 3;
                else if (current_val == 3) next = 6;
                else if (current_val == 6) next = 9;
                else if (current_val == 9) next = 12;
                else next = 12;
            } else if (game_mode == "venezolano") {
                // 1 -> 3 -> 4 -> 5 (Assuming this variation for distinctiveness)
                if (current_val == 1) next = 3;
                else if (current_val == 3) next = 4;
                else if (current_val == 4) next = 5;
                else next = 5;
            } else {
                // International (Arg/Uru): 1 -> 2 -> 3 -> 4
                if (current_val == 1) next = 2; // Truco
                else if (current_val == 2) next = 3; // Retruco
                else if (current_val == 3) next = 4; // Vale Cuatro
                else next = 4;
            }
            
            if (next <= current_val) return false; // Safety check

            proposed_stake = next;
            challenger_team = players[player_id].team;
            
            string msg = _("Called Truco!");
            
            if (game_mode == "paulista" || game_mode == "mineiro") {
                if (next == 6) msg = _("Called Six!");
                else if (next == 9) msg = _("Called Nine!");
                else if (next == 12) msg = _("Called Twelve!");
            } else if (game_mode == "venezolano") {
                 if (next == 3) msg = _("Called Truco!");
                 else if (next == 4) msg = _("Retruco!");
                 else if (next == 5) msg = _("Vale Juego!"); 
            } else {
                // Arg/Uru
                if (next == 2) msg = _("Truco!");
                else if (next == 3) msg = _("Retruco!");
                else if (next == 4) msg = _("Vale Cuatro!");
            }
            
            history.add(HistoryItem(player_id, msg));
            SoundManager.get_default().play("truco");
            return true;
        }

        public void respond_challenge(int player_id, bool accept) {
            if (proposed_stake == null && !state_mao_11_pending) return;
            
            // Special Mão de 11 handling
            if (state_mao_11_pending) {
                state_mao_11_pending = false;
                if (accept) {
                    stake = 3; // Mão de 11 starts worth 3 (Standard Brazil) - TODO Adjust for variants?
                    // Usually if you play Mão de 11 you risk losing 3 (or whatever Truco value is).
                    // In Arg/Uru/Ven, rejecting 'Mão' usually costs 1, playing risks a basic Truco amount? 
                    // Let's keep 3 for Brazil, and maybe check game_mode for others.
                    if (game_mode == "argentino" || game_mode == "uruguayo") stake = 2; // Truco value
                    else if (game_mode == "venezolano") stake = 3;
                    
                    history.add(HistoryItem(player_id, _("Accepted Hand! Round worth %d points.").printf(stake)));
                    // Game continues normally
                } else {
                    history.add(HistoryItem(player_id, _("Refused Mão de 11!")));
                    // Opponent gets 1 point
                    if (players[player_id].team == 0) score_manager.add_points(1, 1);
                    else score_manager.add_points(0, 1);
                    
                    check_game_end_conditions();
                    if (!game_over && !match_over) start_round();
                }
                return;
            }

            if (proposed_stake == null) return;

            if (accept) {
                stake = proposed_stake;
                proposed_stake = null;
                challenger_team = null;
                history.add(HistoryItem(player_id, _("Accepted! Stake is now %d").printf(stake)));
                SoundManager.get_default().play("quiero");
            } else {
                // Fold
                int winner = (challenger_team == 0) ? 0 : 1;
                history.add(HistoryItem(player_id, _("Refused!")));
                SoundManager.get_default().play("run");
                
                string win_msg = (winner == 0) ? _("Your team won the round!") : _("Opponent team won the round!");
                history.add(HistoryItem(-1, win_msg));
                 // Points awarded is PREVIOUS stake
                if (winner == 0) score_manager.add_points(0, stake);
                else score_manager.add_points(1, stake);
                
                check_game_end_conditions(); // Check if this wins the game
                if (!game_over && !match_over) start_round(); // New round
            }
        }
        
        public bool call_envido(int player_id, int type) {
            // types: 0=Envido (2), 1=Real Envido (3), 2=Falta Envido
            // Check if blocked
            if (!envido_available) return false;
            // if (envido_played) return false; // Allow raising? Complex. For now block if already played.
            if (envido_played && !state_envido_pending) return false; 
            
            // Allow raise logic later. For now, basic state set.
            state_envido_pending = true;
            envido_challenger_team = players[player_id].team;
            
            string msg = "";
            int points = 0;
            if (type == 0) { msg = _("Envido!"); points = 2; }
            if (type == 1) { msg = _("Real Envido!"); points = 3; }
            if (type == 2) { msg = _("Falta Envido!"); points = 30; } 
            
            envido_stake = points;
            history.add(HistoryItem(player_id, msg));
            // Placeholder: Use truco sound for Envido call
            SoundManager.get_default().play("truco");
            
            // Trigger AI response if needed
            int responding_team = (envido_challenger_team == 0) ? 1 : 0;
            // Check if responding team has CPU
            bool ai_embarks = false;
            foreach (var p in players) {
                 if (p.team == responding_team && p.is_cpu) {
                     ai_embarks = true;
                     break;
                 }
            }
            
            if (ai_embarks) {
                 Timeout.add(1500, () => {
                     cpu_respond_envido();
                     return false;
                 });
            }
            
            return true;
        }

        public void respond_envido(int player_id, bool accept) {
             if (!state_envido_pending) return;
             
             state_envido_pending = false;
             envido_played = true; 
             envido_available = false; // Ends envido phase for this round
             
             if (accept) {
                 history.add(HistoryItem(player_id, _("Quiero! (Accepted Envido)")));
                 SoundManager.get_default().play("quiero");
                 resolve_envido();
             } else {
                 history.add(HistoryItem(player_id, _("No Quiero! (Refused Envido)")));
                 SoundManager.get_default().play("run");
                 int winner_team = (envido_challenger_team == 0) ? 0 : 1; // Original caller's team
                 // Opponent refused, so challenger wins 1 point (or more if raised, but keeping simple)
                 if (winner_team == 0) score_manager.add_points(0, 1);
                 else score_manager.add_points(1, 1);
                 
                 check_game_end_conditions();
             }
        }
        
        private void resolve_envido() {
             int start_idx = (dealer_index + 1) % players.size;
             int best_p0 = -1;
             int best_p1 = -1;
             string summary = "";
             
             for (int i = 0; i < players.size; i++) {
                 int pid = (start_idx + i) % players.size;
                 int s = rules_engine.get_envido_score(players[pid].hand);
                 summary += "%s: %d  ".printf(players[pid].name, s);
                 
                 if (players[pid].team == 0) {
                     if (s > best_p0) best_p0 = s;
                 } else {
                     if (s > best_p1) best_p1 = s;
                 }
             }
             
             history.add(HistoryItem(-1, _("Envido Scores: ") + summary));
             
             // Tie breaker: Hand (Mão) wins. Mão is dealer+1.
             // We need to know who is "hand".
             // If p0 (team 0) and p1 (team 1) tie, the one earlier in turn order wins.
             // Since we iterated in turn order, the FIRST one to set the max score holds it?
             // No, standard rule: "Mão" wins tie.
             
             // Simplest: Check if Mão's team is equal to best score of other team?
             
             int winner_team = 0;
             if (best_p0 > best_p1) winner_team = 0;
             else if (best_p1 > best_p0) winner_team = 1;
             else {
                 // Tie.
                 int hand_pid = (dealer_index + 1) % players.size;
                 winner_team = players[hand_pid].team;
             }
             
             history.add(HistoryItem(-1, (winner_team == 0) ? _("Your team wins Envido!") : _("Opponent team wins Envido!")));
             
             if (winner_team == 0) score_manager.add_points(0, envido_stake);
             else score_manager.add_points(1, envido_stake);
             
             check_game_end_conditions();
        }

        public bool call_flor(int player_id) {
            // Check eligibility
            // Must be first trick (vaza) not first round (hand)
            if (vaza_wins_team_0 > 0 || vaza_wins_team_1 > 0) return false;
            
            // Check if player actually has Flor
            if (!rules_engine.has_flor(players[player_id].hand)) return false;
            
            // Disable Envido/Truco pending?
             state_envido_pending = false;
             envido_available = false; 
             
             history.add(HistoryItem(player_id, _("Flor!")));
             SoundManager.get_default().play("truco"); // Use Truco sound for now or specific
             
             // Immediate Resolution (Simplified)
             // Check Opposing Team for Flor
             int opponent_team = (players[player_id].team == 0) ? 1 : 0;
             int best_opp_flor = -1;
             int s_opp_best = -1;
             
             foreach(var p in players) {
                 if (p.team == opponent_team) {
                     if (rules_engine.has_flor(p.hand)) {
                         int s = rules_engine.get_flor_score(p.hand);
                         if (s > s_opp_best) {
                             s_opp_best = s;
                             best_opp_flor = p.id;
                         }
                     }
                 }
             }
             
             if (best_opp_flor != -1) {
                 // Contra Flor!
                 history.add(HistoryItem(best_opp_flor, _("Contra Flor!")));
                 
                 // Showdown
                 // Find best Flor in caller's team
                 int best_my_flor = -1;
                 int s_my_best = -1;
                 foreach(var p in players) {
                     if (p.team == players[player_id].team) {
                         if (rules_engine.has_flor(p.hand)) {
                             int s = rules_engine.get_flor_score(p.hand);
                             if (s > s_my_best) {
                                 s_my_best = s;
                                 best_my_flor = p.id;
                             }
                         }
                     }
                 }
                 
                 // Winner
                 int winner_team = -1;
                 if (s_my_best > s_opp_best) winner_team = players[player_id].team;
                 else if (s_opp_best > s_my_best) winner_team = opponent_team;
                 else {
                     // Tie: Hand wins
                     int hand_pid = (dealer_index + 1) % players.size;
                     winner_team = players[hand_pid].team;
                 }
                 
                 history.add(HistoryItem(-1, _("Flor Showdown: Us %d vs Them %d").printf(s_my_best, s_opp_best)));
                 history.add(HistoryItem(-1, (winner_team == 0) ? _("Your team wins Flor!") : _("Opponent team wins Flor!")));
                 
                 if (winner_team == 0) score_manager.add_points(0, 6);
                 else score_manager.add_points(1, 6);
                 
             } else {
                 // No Flor for opponents
                 history.add(HistoryItem(-1, _("Opponents have no Flor. 3 points awarded.")));
                 if (players[player_id].team == 0) score_manager.add_points(0, 3);
                 else score_manager.add_points(1, 3);
             }
             
             check_game_end_conditions();
             return true;
        }

        public void cpu_respond_envido() {
            if (!state_envido_pending) return;
            if (envido_challenger_team == null) return;
            
            int responding_team = (envido_challenger_team == 0) ? 1 : 0;
            
            // Find a CPU player in responding team
            int cpu_pid = -1;
            foreach (var p in players) {
                if (p.team == responding_team && p.is_cpu) {
                    cpu_pid = p.id;
                    break;
                }
            }
            
            if (cpu_pid != -1) {
                  var cpu = players[cpu_pid];
                  int s = rules_engine.get_envido_score(cpu.hand);
                  
                  bool accept = false;
                  int threshold = 27;
                  double bluff_catch = 0.1;

                  switch (cpu.personality) {
                      case Personality.AGGRESSIVE:
                          threshold = 25;
                          bluff_catch = 0.2;
                          break;
                      case Personality.CONSERVATIVE:
                          threshold = 30;
                          bluff_catch = 0.05;
                          break;
                      case Personality.GAMBLER:
                          threshold = 20;
                          bluff_catch = 0.3;
                          break;
                      case Personality.BALANCED:
                      default:
                          threshold = 27;
                          bluff_catch = 0.1;
                          break;
                  }

                  if (envido_stake > 5) threshold += 3; // Increase threshold for Real/Falta

                  if (s >= threshold) accept = true;
                  else if (Random.double_range(0.0, 1.0) < bluff_catch) accept = true; 
                  
                  respond_envido(cpu_pid, accept);
            }
        }

        public void cpu_respond_truco() {
            int limit = get_max_points();
            // Check Mão de 11 first
            if (state_mao_11_pending) {
                 // Should only be called if it's CPU's team that is at limit-1
                 int team_at_limit = (score_manager.score_team_1 == limit - 1) ? 1 : 0;
                 if (team_at_limit == 1) { // It is CPU team
                      // Decide to play or run
                      int combined_strength = 0;
                      // Peek both CPU/Partner hands
                      foreach(var p in players) {
                          if (p.team == 1) {
                              foreach(var c in p.hand) combined_strength += c.power;
                          }
                      }
                      
                      // Max possible for team is roughly 80? (40+40)
                      // Threshold for 11: Need very good cards to risk 3 points? 
                      // actually 1 point to run vs 3 to play.
                      
                      // Personality factor
                      int threshold = 35;
                      var cpu = players[1]; // CPU 1
                      switch (cpu.personality) {
                          case Personality.AGGRESSIVE: threshold = 30; break;
                          case Personality.CONSERVATIVE: threshold = 40; break;
                          case Personality.GAMBLER: threshold = 25; break;
                      }

                      bool play = (combined_strength >= threshold);
                      // Add some randomness
                      if (Random.double_range(0.0, 1.0) < 0.1) play = !play;

                      respond_challenge(1, play); // ID 1 (CPU 1) responds
                 }
                 return;
            }

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
                  var cpu = players[cpu_pid];
                  int strength = 0;
                  foreach (var c in cpu.hand) {
                      strength += c.power;
                  }
                  
                  bool accept = false;
                  int high_threshold = 25;
                  int med_threshold = 15;
                  double bluff_accept = 0.15;

                  switch (cpu.personality) {
                      case Personality.AGGRESSIVE:
                          high_threshold = 20;
                          med_threshold = 10;
                          bluff_accept = 0.25;
                          break;
                      case Personality.CONSERVATIVE:
                          high_threshold = 30;
                          med_threshold = 20;
                          bluff_accept = 0.05;
                          break;
                      case Personality.GAMBLER:
                          high_threshold = 15;
                          med_threshold = 5;
                          bluff_accept = 0.4;
                          break;
                  }
                  
                  if (strength >= high_threshold) {
                      // Chance to re-raise instead of just accepting
                      double p_raise = 0.3;
                      if (cpu.personality == Personality.AGGRESSIVE) p_raise = 0.5;
                      if (cpu.personality == Personality.GAMBLER) p_raise = 0.6;
                      
                      if (Random.double_range(0.0, 1.0) < p_raise) {
                          if (raise_stake(cpu_pid)) return; // Re-raised successfully
                      }
                      accept = true;
                  } 
                  else if (strength >= med_threshold && stake < 6) accept = true;
                  else if (strength >= 5 && stake == 1) accept = true;
                  else if (Random.double_range(0.0, 1.0) < bluff_accept) accept = true;
                  
                  respond_challenge(cpu_pid, accept);
            }
        }

        public async void cpu_turn_async() {
            int pid = current_player_index;
            var cpu = players[pid];
            if (!cpu.is_cpu) return;

             // Send signals if first trick and haven't signaled yet
             if (vaza_wins_team_0 == 0 && vaza_wins_team_1 == 0 && cpu.last_signal == null) {
                 cpu_send_signals(pid);
             }

             // Flor Check
             if ((vaza_wins_team_0 == 0 && vaza_wins_team_1 == 0) && envido_available && !state_envido_pending && !envido_played) {
                 if (rules_engine.has_flor(cpu.hand)) {
                      call_flor(pid);
                      if (game_over || match_over) return;
                 }
             }

             if (proposed_stake != null) {
                 if (challenger_team != cpu.team) {
                      cpu_respond_truco(); 
                 }
                 return;
             }
             
             if (state_mao_11_pending) {
                 cpu_respond_truco();
                 return;
             }

            // Truco Calling Logic
             int limit = get_max_points();
             bool can_call_truco = (score_manager.score_team_0 != limit - 1 && score_manager.score_team_1 != limit - 1 && proposed_stake == null);
             
             // Check max stake based on variant to ensure we don't try to call past max
             if (game_mode == "paulista" || game_mode == "mineiro") { if (stake >= 12) can_call_truco = false; }
             else if (game_mode == "argentino" || game_mode == "uruguayo") { if (stake >= 4) can_call_truco = false; }
             else if (game_mode == "venezolano") { if (stake >= 5) can_call_truco = false; }
             
             if (can_call_truco) {
                  int hand_strength = 0;
                  foreach (var c in cpu.hand) {
                      hand_strength += c.power;
                  }
                  
                  // Personality probabilities
                  double p_strong = 0.6;
                  double p_med = 0.4;
                  double p_bluff = 0.08;

                  switch (cpu.personality) {
                      case Personality.AGGRESSIVE:
                          p_strong = 0.8;
                          p_med = 0.6;
                          p_bluff = 0.15;
                          break;
                      case Personality.CONSERVATIVE:
                          p_strong = 0.4;
                          p_med = 0.2;
                          p_bluff = 0.02;
                          break;
                      case Personality.GAMBLER:
                          p_strong = 0.9;
                          p_med = 0.7;
                          p_bluff = 0.3;
                          break;
                  }

                  bool call = false;
                  if (hand_strength > 28 && Random.double_range(0.0, 1.0) < p_strong) call = true; // Very Strong
                  else if (hand_strength > 20 && stake < 3 && Random.double_range(0.0, 1.0) < p_med) call = true; // Strong
                  else if (hand_strength < 10 && Random.double_range(0.0, 1.0) < p_bluff) call = true; // Bluff
                  
                  if (call) {
                      raise_stake(pid);
                      return; 
                  }
             }

            // Envido Calling Logic (only if first trick)
            if (envido_available && !envido_played && !state_envido_pending && vaza_wins_team_0 == 0 && vaza_wins_team_1 == 0) {
                 int s = rules_engine.get_envido_score(cpu.hand);
                 double p_envido = 0.0;
                 if (s >= 30) p_envido = 0.8;
                 else if (s >= 27) p_envido = 0.5;
                 else if (s < 20) p_envido = 0.05; // Rare bluff

                 // Personality multiplier
                 switch (cpu.personality) {
                     case Personality.AGGRESSIVE: p_envido *= 1.2; break;
                     case Personality.CONSERVATIVE: p_envido *= 0.7; break;
                     case Personality.GAMBLER: p_envido += 0.1; break;
                 }

                 if (Random.double_range(0.0, 1.0) < p_envido) {
                     call_envido(pid, 0); // Call basic Envido
                     return;
                 }
            }

            // Play card
            if (cpu.hand.size > 0) {
                 int idx = yield get_best_card_index_async(pid);
                 play_card(pid, idx);
            } else {
                 advance_turn();
            }

            turn_advanced(); // Notify UI that AI finished its actions
        }

        public void cpu_turn() {
            cpu_turn_async.begin();
        }

        private async int get_best_card_index_async(int pid) {
            var cpu = players[pid];
            
            // Use MCTS for strategic personalities if hand size > 1
            if (cpu.hand.size > 1 && (cpu.personality == Personality.BALANCED || cpu.personality == Personality.CONSERVATIVE)) {
                return get_mcts_best_move(pid);
            }

            return get_best_card_index(pid);
        }

        /**
         * Returns a localized hint for the player.
         */
        public string? get_hint(int pid) {
            if (game_over || match_over) return null;
            if (current_player_index != pid) return _("Wait for your turn.");

            var p = players[pid];
            if (p.hand.size == 0) return null;

            // Check for Flor (if applicable)
            if ((vaza_wins_team_0 == 0 && vaza_wins_team_1 == 0) && envido_available && !state_envido_pending && !envido_played) {
                if (rules_engine.has_flor(p.hand)) return _("Hint: You have a Flor! You should call it.");
            }

            // Check for Envido
            if (envido_available && !envido_played && !state_envido_pending && vaza_wins_team_0 == 0 && vaza_wins_team_1 == 0) {
                 int s = rules_engine.get_envido_score(p.hand);
                 if (s >= 27) return _("Hint: You have a good Envido score (%d). Consider calling it.").printf(s);
            }

            // Check for Truco (simplified)
            int hand_strength = 0;
            foreach (var c in p.hand) hand_strength += c.power;
            if (hand_strength > 24 && proposed_stake == null) {
                return _("Hint: You have strong cards. Consider calling Truco!");
            }

            // Suggest best card
            int best_idx = get_best_card_index(pid);
            var best_card = p.hand[best_idx];
            return _("Hint: I suggest playing the %s.").printf(best_card.to_string());
        }

        public int get_best_card_index(int pid) {
            var hand = players[pid].hand;
            var cpu = players[pid];
            
            int best_idx = 0;
            
            // Partner awareness
            bool partner_has_strong = false;
            foreach (var p in players) {
                if (p.team == cpu.team && p.id != pid) {
                    if (p.last_signal != null && (p.last_signal.contains(_("Zap")) || p.last_signal.contains(_("Strong")))) {
                        partner_has_strong = true;
                    }
                }
            }
            
            Card? winning_card = null;
            int winning_pid = -1;
            
            if (table_cards.size > 0) {
                 int current_best_power = -1;
                 for(int i=0; i<table_cards.size; i++) {
                     if (table_cards[i].power > current_best_power) {
                         current_best_power = table_cards[i].power;
                         winning_pid = table_pids[i];
                         winning_card = table_cards[i];
                     }
                 }
            }
            
            // Are we winning? (Any team mate is current winner)
            if (winning_pid != -1 && players[winning_pid].team == cpu.team) {
                // Partner winning. Play lowest card (esconder carta).
                int lowest_power = 999;
                for (int i=0; i < hand.size; i++) {
                    if (hand[i].power < lowest_power) {
                        lowest_power = hand[i].power;
                        best_idx = i;
                    }
                }
                return best_idx;
            }
            
            // We are likely losing or first to play.
            if (table_cards.size == 0) {
                // Strategy: Play lowest unless partner has nothing and we want to win first trick.
                if (partner_has_strong) {
                    int lowest_power = 999;
                    for (int i=0; i < hand.size; i++) {
                        if (hand[i].power < lowest_power) {
                            lowest_power = hand[i].power;
                            best_idx = i;
                        }
                    }
                    return best_idx;
                }

                // Normal logic: mostly play low, occasionally high.
                int best_p = 999;
                for (int i=0; i < hand.size; i++) {
                    if (hand[i].power < best_p) {
                        best_p = hand[i].power;
                        best_idx = i;
                    }
                }
                if (Random.double_range(0, 1) > 0.8) {
                     int highest = -1;
                     for (int i=0; i < hand.size; i++) {
                        if (hand[i].power > highest) {
                            highest = hand[i].power;
                            best_idx = i;
                        }
                    }
                }
                return best_idx;
            }
            
            // Opponent winning. Try to beat.
            if (winning_card != null && players[winning_pid].team != cpu.team) {
                 int target_power = winning_card.power;
                 
                 // If a partner still has to play and they have strong signal,
                 // we might skip beating if our card is too precious.
                 bool partner_will_play = false;
                 for (int i = table_cards.size + 1; i < players.size; i++) {
                     int future_pid = (current_player_index + (i - table_cards.size)) % players.size;
                     if (players[future_pid].team == cpu.team) {
                         partner_will_play = true;
                         break;
                     }
                 }

                 if (partner_will_play && partner_has_strong && target_power < 15) {
                     // Let partner handle it. Throw low.
                    int lp = 999;
                    for (int i=0; i < hand.size; i++) {
                        if (hand[i].power < lp) {
                            lp = hand[i].power;
                            best_idx = i;
                        }
                    }
                    return best_idx;
                 }

                 // Find lowest card that BEATS target
                 int best_candidate_power = 999;
                 int best_candidate_idx = -1;
                 
                 for (int i=0; i < hand.size; i++) {
                     if (hand[i].power > target_power && hand[i].power < best_candidate_power) {
                         best_candidate_power = hand[i].power;
                         best_candidate_idx = i;
                     }
                 }
                 
                 if (best_candidate_idx != -1) {
                     return best_candidate_idx; 
                 } else {
                     // Cannot win. Throw lowest.
                    int lp = 999;
                    for (int i=0; i < hand.size; i++) {
                        if (hand[i].power < lp) {
                            lp = hand[i].power;
                            best_idx = i;
                        }
                    }
                    return best_idx;
                 }
            }
            
            return best_idx;
        }

        private void advance_turn() {
            current_player_index = (current_player_index + 1) % players.size;
            
            // Check trick end
            if (table_cards.size == players.size) {
                collect_trick();
            }
            turn_advanced();
        }

        private void collect_trick() {
            // Determine winner
            int best_pow = -1;
            int best_pid = -1;
            
            for (int i = 0; i < players.size; i++) {
                var c = table_cards[i];
                if (c.power > best_pow) {
                    best_pow = c.power;
                    best_pid = table_pids[i];
                } else if (c.power == best_pow) {
                    // Canga (Tie)
                    best_pid = -1;
                }
            }

            int winner_team = (best_pid == -1) ? -1 : players[best_pid].team;
            
            if (winner_team == 0) vaza_wins_team_0++;
            else if (winner_team == 1) vaza_wins_team_1++;
            else {
                // Tie (Canga)
                // Both get a vaza or special rule: 1st trick winner wins tie
                // simplified: both get it, but usually it just counts as a draw
                // In many truco variants: "Amarrado" (tied)
                // If 1st is tied, winner of 2nd wins hand.
                // If 2nd is tied, winner of 1st wins hand.
                // If 1st and 2nd tied, winner of 3rd wins.
                // For now keep it simple: don't increment vaza_wins, wait for next.
                // But current_player_index must be someone. 
                // Usually "Mão" starts if tied.
                current_player_index = (dealer_index + 1) % players.size;
            }

            if (winner_team != -1) {
                current_player_index = best_pid; // Winner starts
            }

            table_cards.clear();
            table_pids.clear();

            // Envido is only available in the first trick.
            // Once a trick is collected, it's definitely late.
            envido_available = false;

            // Check Round End
            if (vaza_wins_team_0 >= 2 || vaza_wins_team_1 >= 2) {
                total_rounds_played++;
                if (vaza_wins_team_0 >= 2) {
                    score_manager.add_points(0, stake);
                    rounds_won_team_0++;
                } else {
                    score_manager.add_points(1, stake);
                    rounds_won_team_1++;
                }
                
                check_game_end_conditions();
            }
        }
        
        private void check_game_end_conditions() {
             if (score_manager.is_game_over()) {
                 int winner_team = score_manager.get_winner();
                 
                 if (winner_team == 0) matches_won_team_0++;
                 else matches_won_team_1++;
                 
                 history.add(HistoryItem(-1, (winner_team == 0) ? _("Team US wins the Game!") : _("Team THEM wins the Game!")));
                 game_over = true;
                 game_ended(winner_team); // Signal
                 
                 // Check Match Win
                  if (matches_won_team_0 >= GAMES_TO_WIN_MATCH || matches_won_team_1 >= GAMES_TO_WIN_MATCH) {
                      history.add(HistoryItem(-1, (winner_team == 0) ? _("Team US wins the Match!") : _("Team THEM wins the Match!")));
                      match_over = true;
                      match_ended(winner_team);
                      return; 
                  } else {
                      // Prepare for next game in match
                      // User Request: Winner starts the new game.
                      if (winner_team == 0) dealer_index = players.size - 2;
                      else dealer_index = players.size - 1;
                      
                      reset_game_score();
                  }
             } else {
                 start_round();
             }
        }
        private void cpu_send_signals(int pid) {
            var cpu = players[pid];
            int max_power = -1;
            int total_power = 0;
            foreach (var c in cpu.hand) {
                if (c.power > max_power) max_power = c.power;
                total_power += c.power;
            }

            string signal = "";
            if (max_power >= 14) signal = _("Zap! (Best Card)");
            else if (max_power >= 12) signal = _("Strong Card");
            else if (total_power >= 30) signal = _("Good Hand");
            else if (total_power <= 10) signal = _("Weak Hand");
            else signal = _("Average Hand");

            // Probability of signaling depends on personality
            double p_signal = 0.7;
            switch (cpu.personality) {
                case Personality.BALANCED: p_signal = 0.7; break;
                case Personality.AGGRESSIVE: p_signal = 0.9; break;
                case Personality.CONSERVATIVE: p_signal = 0.5; break;
                case Personality.GAMBLER: p_signal = 0.8; break;
            }

            if (Random.double_range(0, 1) < p_signal) {
                send_signal(pid, signal);
            }
        }

        public void send_signal(int player_id, string signal) {
            var p = players[player_id];
            p.last_signal = signal;
            history.add(HistoryItem(player_id, _("Signal: %s").printf(signal)));
            
            // In a real UI, this would show an emote or animation.
            // For now, we use the history log.
        }

        private int get_mcts_best_move(int pid) {
            var cpu = players[pid];
            if (cpu.hand.size <= 1) return 0;

            var nodes = new ArrayList<MCTSNode>();
            for (int i = 0; i < cpu.hand.size; i++) {
                nodes.add(new MCTSNode(i));
            }

            int num_sims = 100; // Fairly low for performance
            
            // Simplified Determinization:
            // For each card, we simulate random games.
            foreach (var node in nodes) {
                for (int s = 0; s < num_sims; s++) {
                    if (simulate_game(pid, node.card_index)) {
                        node.wins++;
                    }
                    node.visits++;
                }
            }

            int best_idx = 0;
            double best_score = -1.0;
            foreach (var node in nodes) {
                double score = (double)node.wins / node.visits;
                if (score > best_score) {
                    best_score = score;
                    best_idx = node.card_index;
                }
            }

            return best_idx;
        }

        private bool simulate_game(int pid, int start_card_idx) {
            // Very simplified rollout:
            // 1. Estimate our power vs expected opponent power
            // 2. Consider table state
            // 3. Return true if we think we win the round
            
            var cpu = players[pid];
            var card = cpu.hand[start_card_idx];
            int team = cpu.team;

            // Simplified: If we play this card, how strong is it compared to likely remaining cards?
            // In a full MCTS we'd actually play out the turns.
            // Let's do a slightly better one:
            
            int total_power_remaining = 0;
            int cards_out = 0;
            // Realistically we should track known cards, but let's keep it simple.
            
            // Heuristic rollout:
            int my_power = card.power;
            
            // If table has cards, check if we beat them
            if (table_cards.size > 0) {
                int best_on_table = -1;
                foreach (var tc in table_cards) {
                    if (tc != null && tc.power > best_on_table) best_on_table = tc.power;
                }
                if (my_power < best_on_table) {
                    // We lose this trick unless partner wins it later (not modeled here)
                    return false; 
                }
            }

            // Estimate win chance based on power and remaining cards in hand
            int hand_power = 0;
            foreach (var c in cpu.hand) hand_power += c.power;
            hand_power -= my_power; // Power left for other tricks

            // Win if my_power is high or hand_power is high
            double win_prob = (my_power / 25.0) + (hand_power / 50.0);
            return (Random.double_range(0, 1) < win_prob);
        }
    }
}

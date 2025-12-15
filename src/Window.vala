using Gtk;
using Adw;
using Gee;

namespace Truco {

    [GtkTemplate (ui = "/io/github/tobagin/Truco/window.ui")]
    public class Window : Adw.ApplicationWindow {

        [GtkChild]
        private unowned Adw.WindowTitle window_title;
        [GtkChild]
        private unowned Grid game_grid;
        
        [GtkChild]
        private unowned Label status_label;

        [GtkChild]
        private unowned Box score_box; // Bind the box to control/ensure visibility
        [GtkChild]
        private unowned Label match_score_us_label;
        [GtkChild]
        private unowned Label match_score_them_label;
        [GtkChild]
        private unowned Label game_score_us_label;
        [GtkChild]
        private unowned Label game_score_them_label;

        [GtkChild]
        private unowned Label turn_indicator_label;

        [GtkChild]
        private unowned Label round_label;

        [GtkChild]
        private unowned Box top_cards;
        [GtkChild]
        private unowned Box left_cards;
        [GtkChild]
        private unowned Box right_cards;
        
        [GtkChild]
        private unowned Adw.Avatar avatar_top;
        [GtkChild]
        private unowned Adw.Avatar avatar_left;
        [GtkChild]
        private unowned Adw.Avatar avatar_right;
        [GtkChild]
        private unowned Adw.Avatar avatar_user;

        [GtkChild]
        private unowned Box table_cards_box;
        // ... (existing fields)

        // ...


        private void update_avatars() {
             load_avatar(avatar_user, game.players[0].avatar_icon);
             load_avatar(avatar_right, game.players[1].avatar_icon);
             load_avatar(avatar_top, game.players[2].avatar_icon);
             load_avatar(avatar_left, game.players[3].avatar_icon);
        }
        
        private void load_avatar(Adw.Avatar avatar, string resource_path) {
            var paintable = Gdk.Texture.from_resource(Config.RESOURCE_PATH + "/" + resource_path);
            avatar.set_custom_image(paintable);
        }
        
        private void update_opp_box(Box b, int count, string rotation_class) {
             clean_box(b);
             for (int i=0; i<count; i++) {
                 var img = new Image.from_resource(Config.RESOURCE_PATH + "/" + current_card_back);
                 img.pixel_size = 120;
                 img.add_css_class("opponent-card");
                 img.add_css_class(rotation_class);
                 img.halign = Align.CENTER;
                 img.valign = Align.CENTER;
                 img.hexpand = false;
                 img.vexpand = false;
                 b.append(img);
             }
        }
        [GtkChild]
        private unowned Image vira_image;
        [GtkChild]
        private unowned Box vira_box;
        
        [GtkChild]
        private unowned Box player_hand_box;
        
        [GtkChild]
        private unowned ListBox history_box;
        
        [GtkChild]
        private unowned Adw.OverlaySplitView split_view;

        [GtkChild]
        private unowned Button btn_truco;
        [GtkChild]
        private unowned Button btn_accept;
        [GtkChild]
        private unowned Button btn_refuse;

        private GameState game;
        
        private string current_felt_class = "felt-green";
        private string current_card_back = "cards/backs/player_card_back_design_1_blue.svg";
        private bool raise_dialog_shown = false; // State to track dialog visibility

        public Window (Gtk.Application app) {
            Object (application: app);
            
            // Settings
            var settings = new GLib.Settings (Config.SCHEMA_ID);
            
            int default_variant_idx = settings.get_int("default-game-variant");
            string default_variant = "mineiro";
            switch (default_variant_idx) {
                case 0: default_variant = "mineiro"; break;
                case 1: default_variant = "paulista"; break;
                case 2: default_variant = "uruguayo"; break;
                case 3: default_variant = "venezolano"; break;
                case 4: default_variant = "argentino"; break;
            }
            game = new GameState(default_variant);
            setup_game_signals();
            
            // Initial Load
            load_settings(settings);
            
            // Listen for changes
            settings.changed["felt-color"].connect (() => {
                set_felt_color(settings.get_string("felt-color"));
            });
            settings.changed["card-back"].connect (() => {
                set_card_back(settings.get_string("card-back"));
            });
            settings.changed["avatar"].connect (() => {
                set_user_avatar(settings.get_string("avatar"));
            });
            
            update_ui();

            var new_game_action = new SimpleAction ("new-game", null);
            new_game_action.activate.connect (on_new_game);
            add_action (new_game_action);

            btn_truco.clicked.connect (() => {
                if (game.raise_stake(0)) {
                    update_ui();
                    // AI Response Delay
                    GLib.Timeout.add(1000, () => {
                        game.cpu_respond_truco();
                        update_ui();
                        check_cpu_turn();
                        return false;
                    });
                }
            });
            
            btn_accept.clicked.connect(() => {
                game.respond_challenge(0, true);
                update_ui();
                check_cpu_turn();
            });
            
            btn_refuse.clicked.connect(() => {
                game.respond_challenge(0, false);
                update_ui();
            });
        }
        
        private void load_settings(GLib.Settings settings) {
            set_felt_color(settings.get_string("felt-color"));
            set_card_back(settings.get_string("card-back"));
            set_user_avatar(settings.get_string("avatar"));
        }
        
        public void set_felt_color(string color_class) {
            game_grid.remove_css_class(current_felt_class);
            current_felt_class = color_class;
            game_grid.add_css_class(current_felt_class);
        }
        
        public void set_card_back(string path) {
            current_card_back = path;
            update_ui();
        }

        public void set_user_avatar(string path) {
            game.players[0].avatar_icon = path;
            // Also save to settings if using GSettings later
            update_ui();
        }
        
        private void on_new_game(SimpleAction action, Variant? parameter) {
             on_new_game_void();
        }

        private void on_new_game_void() {
            var dialog = new NewGameDialog();
            dialog.response.connect((response) => {
                if (dialog.selected_variant != null) {
                    game = new GameState(dialog.selected_variant);
                    setup_game_signals();
                    update_ui();
                }
            });
            dialog.present(this);
        }
        
        private void setup_game_signals() {
            game.match_ended.connect((winning_team) => {
                show_match_end_dialog(winning_team);
            });
            
            // Maybe connect game_ended too if we want a dialog for each sub-game?
            // For now, only match end is critical.
        }

        private void check_cpu_turn() {
            if (game.game_over || game.match_over) return;
            
            int pid = game.current_player_index;
            if (game.players[pid].is_cpu) {
                 GLib.Timeout.add(1000, () => {
                     if (game.game_over || game.match_over) return false;
                     
                     // If there is a pending challenge from a CPU (e.g. Partner raised), we need response
                     if (game.proposed_stake != null && game.challenger_team != null) {
                        // If challenger is Team 0 (Partner/User) and responding team is 1 (Cpu 1/3)
                        if (game.challenger_team == 0) {
                            game.cpu_respond_truco();
                            update_ui();
                            // Logic continues to Next Turn? cpu_respond_truco acts instantly.
                            // If they accept, the game state changes (stake updated).
                            // If they refuse, round ends.
                            // We should re-check turn or return?
                            // cpu_respond_truco calls start_round if Fold.
                            
                            // If accepted, the turn remains with the same player usually?
                            // Or does the turn pass?
                            // Standard Truco: Raise interrupts. If accepted, game continues with current player.
                            if (game.proposed_stake == null && !game.game_over) {
                                // Accepted or Refused (but refused starts new round).
                                // If accepted, we continue the logic for CURRENT CPU to play a card?
                                // Yes, if Partner raised, they still need to play their card.
                                // BUT: cpu_turn includes logic "If challenged...".
                                // We need to be careful not to infinite loop.
                                check_cpu_turn(); 
                            }
                            return false; 
                        }
                     }

                     game.cpu_turn();
                     
                     // If CPU raised (Partner), we need to trigger response logic for Opponents NEXT.
                     // cpu_turn() returns after raising.
                     if (game.proposed_stake != null && game.challenger_team == 0) {
                         // Partner raised! Schedule response validation next loop
                         update_ui();
                         
                         // Re-trigger check to hit the block above?
                         check_cpu_turn();
                         return false;
                     }

                     update_ui();
                     
                     // Recursively check next if it's still CPU turn (e.g. turn advanced)
                     int next_pid = game.current_player_index;
                     if (game.players[next_pid].is_cpu && !game.game_over) {
                         check_cpu_turn();
                     }
                     return false;
                 });
            } else {
                // If it's User Turn, but there is a challenge from CPU:
                if (game.proposed_stake != null && game.players[pid].team != game.challenger_team) {
                    string challenger_name = (game.challenger_team == 1) ? _("Opponent") : _("Partner"); 
                    show_raise_dialog(challenger_name, game.proposed_stake);
                }
            }
        }
        
        private void update_ui() {
            if (game.match_over) {
                 window_title.subtitle = "MATCH OVER! %s Wins!".printf(game.matches_won_team_0 > game.matches_won_team_1 ? "YOU" : "CPU");
            } else {
                 string variant_str = game.game_mode.substring(0,1).up() + game.game_mode.substring(1); 
                 window_title.subtitle = _("%s Variant").printf(variant_str);
            }

            score_box.visible = true; // Ensure it's visible
            match_score_us_label.label = game.matches_won_team_0.to_string();
            match_score_them_label.label = game.matches_won_team_1.to_string();
            game_score_us_label.label = game.score_team_0.to_string();
            game_score_us_label.label = game.score_team_0.to_string();
            game_score_them_label.label = game.score_team_1.to_string();
            
            // turn_indicator_label update moved to status logic block below

            update_avatars();

            // Status & Buttons
            string stake_text = _("Stake: %d").printf(game.stake);
            
            if (game.proposed_stake != null) {
                int challenger = game.challenger_team;
                status_label.label = _("Truco! %d proposed by Team %d.").printf(game.proposed_stake, challenger);
                
                if (challenger != 0) {
                    // Hide in-window buttons as we use the Dialog
                    btn_accept.visible = false;
                    btn_refuse.visible = false;
                    
                    if (!raise_dialog_shown) {
                         show_raise_dialog(game.players[game.current_player_index].name, game.proposed_stake);
                         raise_dialog_shown = true;
                    }
                    
                    // Also hide 'raise' button from bottom bar since dialog offers it
                    btn_truco.visible = false;

                } else {
                    status_label.label = _("Waiting for response...");
                    btn_accept.visible = false;
                    btn_refuse.visible = false;
                    btn_truco.visible = false;
                }
            } else {
                raise_dialog_shown = false; // Reset state
                
                // Scoreboard shows Status (Turn | Stake)
                turn_indicator_label.label = _("Turn: %s | %s").printf(game.players[game.current_player_index].name, stake_text);
                
                // Status label under avatar just shows name (like CPU labels)
                status_label.label = game.players[0].name;
                
                btn_accept.visible = false;
                btn_refuse.visible = false;
                
                btn_truco.visible = true;
                btn_truco.sensitive = (game.current_player_index == 0);
                
                string lbl = _("TRUCO!");
                if (game.stake == 3) lbl = _("SEIS!");
                else if (game.stake == 6) lbl = _("NOVE!");
                else if (game.stake == 9) lbl = _("DOZE!");
                
                if (game.score_team_0 == 11 || game.score_team_1 == 11) {
                    btn_truco.sensitive = false;
                    turn_indicator_label.label = _("Turn: %s | MÃO DE 11").printf(game.players[game.current_player_index].name);
                 } else if (game.stake >= 12) {
                    btn_truco.sensitive = false;
                } else {
                    btn_truco.label = lbl;
                }
            }

            // Status status_label updated above in logic blocks
            
            // Round Label
            round_label.label = _("Round: %d").printf(game.round_count);
            
            // Hand
            clean_box(player_hand_box);
            for (int i = 0; i < game.players[0].hand.size; i++) {
                var c = game.players[0].hand[i];
                var btn = new Button();
                btn.add_css_class("player-card");
                var img = new Image.from_resource(Config.RESOURCE_PATH + "/" + c.get_svg_name());
                img.pixel_size = 120; // Larger for player
                btn.set_child(img);
                
                if (game.current_player_index != 0 || game.proposed_stake != null) {
                    btn.sensitive = false;
                }
                
                // Capture index
                int idx = i;
                btn.clicked.connect(() => {
                    if (game.play_card(0, idx)) {
                        update_ui();
                        check_cpu_turn(); 
                    }
                });
                player_hand_box.append(btn);
            }

            // Opponents logic
            update_opp_box(top_cards, game.players[2].hand.size, "rotate-180");
            update_opp_box(left_cards, game.players[3].hand.size, "rotate-270");
            update_opp_box(right_cards, game.players[1].hand.size, "rotate-90");
            
            // Table
            clean_box(table_cards_box);
            for (int i = 0; i < game.table_cards.size; i++) {
               var c = game.table_cards[i];
               var img = new Image.from_resource(Config.RESOURCE_PATH + "/" + c.get_svg_name());
               img.pixel_size = 120; // Increased from 80
               img.add_css_class("card-on-table");
               table_cards_box.append(img);
            }
            
            if (game.vira != null) {
                vira_box.visible = true;
                vira_image.set_from_resource(Config.RESOURCE_PATH + "/" + game.vira.get_svg_name());
            } else {
                vira_box.visible = false;
            }
            
            // Sidebar History
            // Sidebar History
            update_history_ui();
        }

        private void update_history_ui() {
            clean_listbox(history_box);
            
            // We can use Adw.PreferencesGroup for visual grouping or just clean rows
            // User requested Adw.HeaderBar removal, maybe they want a clean list.
            // Let's just add ActionRows directly to the ListBox.
            
            foreach (var item in game.history) {
                var h = item.message;
                var pid = item.player_id;
                
                // Filter out unwanted system messages
                if (h.contains("Match Started") || h.contains("New Game") || h.contains("Cards dealt")) continue;
                if (h.contains("Score 0-0")) continue;

                if (h.contains("started")) { // "Round X started"
                    var row = new Adw.ActionRow();
                    row.title = h;
                    row.add_css_class("dim-label"); 
                    history_box.append(row);
                } else {
                     var row = new Adw.ActionRow();
                     row.title = h;
                     
                     if (pid != -1) {
                         var da_player = game.players[pid];
                         var avatar = new Image.from_resource(Config.RESOURCE_PATH + "/" + da_player.avatar_icon);
                         avatar.pixel_size = 24;
                         row.add_prefix(avatar);
                         
                         if (pid == 0) {
                             row.add_css_class("history-user");
                         } else if (pid == 2) {
                             row.add_css_class("history-partner");
                         }
                     }
                     history_box.append(row);
                }
            }
            
            // Scroll to bottom (simple hack: set vadjustment to upper? Or assume ScrolledWindow handles it?)
            // We'll leave scrolling behavior as is for now.
        }
        
        
        private void clean_listbox(ListBox b) {
            var child = b.get_first_child();
            while (child != null) {
                b.remove(child);
                child = b.get_first_child();
            }
        }
        
        private void clean_box(Box b) {
            var child = b.get_first_child();
            while (child != null) {
                b.remove(child);
                child = b.get_first_child();
            }
        }
        
        private void show_raise_dialog(string challenger_name, int new_stake) {
            split_view.show_sidebar = false; // Ensure dialog is seen

            string call_name = _("Truco!");
            if (new_stake == 6) call_name = _("SEIS!");
            else if (new_stake == 9) call_name = _("NOVE!");
            else if (new_stake == 12) call_name = _("DOZE!");
            
            var dialog = new Adw.AlertDialog (
                call_name,
                _("%s proposed %s (Stake: %d)").printf(challenger_name, call_name, new_stake)
            );

            dialog.add_response ("refuse", _("Run"));

            dialog.add_response ("accept", _("Accept"));
            
            // Calc explicit raise possibilities based on game logic used in update_ui
            int current_prop = game.proposed_stake;
            int next_val = 0;
            string raise_lbl = "";
            
            if (current_prop == 3) { next_val = 6; raise_lbl = _("Raise to 6"); }
            else if (current_prop == 6) { next_val = 9; raise_lbl = _("Raise to 9"); }
            else if (current_prop == 9) { next_val = 12; raise_lbl = _("Raise to 12"); }
            
            if (next_val > 0 && game.score_team_0 < 11 && game.score_team_1 < 11) {
                dialog.add_response ("raise", raise_lbl);
                dialog.set_default_response ("raise");
            } else {
                dialog.set_default_response ("accept"); // Default if can't raise
            }
            
            dialog.set_response_appearance ("refuse", Adw.ResponseAppearance.DESTRUCTIVE);
            dialog.set_response_appearance ("accept", Adw.ResponseAppearance.SUGGESTED);
            
            dialog.response.connect ((response) => {
                 if (response == "accept") {
                     game.respond_challenge(0, true);
                     update_ui();
                     check_cpu_turn();
                 } else if (response == "refuse") {
                     game.respond_challenge(0, false);
                     update_ui();
                 } else if (response == "raise") {
                     // Check if btn_truco logic is reusable or just call raise logic
                     bool success = game.raise_stake(0);
                     if (success) {
                        update_ui();
                        // AI Response Delay
                        GLib.Timeout.add(1000, () => {
                            game.cpu_respond_truco();
                            update_ui();
                            check_cpu_turn();
                            return false;
                        });
                     } else {
                        print("DEBUG: raise_stake(0) failed!\n");
                     }
                 }
            });
            
            dialog.present (this);
            dialog.present (this);
        }

        private void show_match_end_dialog(int winning_team) {
            split_view.show_sidebar = false;

            var dialog = new MatchEndDialog(
                winning_team,
                game.score_team_0, game.score_team_1,
                game.matches_won_team_0, game.matches_won_team_1,
                game.rounds_won_team_0, game.total_rounds_played
            );
            
            dialog.response.connect((response) => {
                if (response == "new") {
                   game.reset_match();
                   update_ui();
                } else if (response == "quit") {
                   close();
                }
            });
            
            dialog.transient_for = this;
            dialog.present();
        }
    }
}

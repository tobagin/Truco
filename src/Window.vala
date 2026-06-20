using Gtk;
using Adw;

namespace Truco {

    [GtkTemplate (ui = "/io/github/tobagin/Truco/window.ui")]
    public class Window : Adw.ApplicationWindow {

        [GtkChild]
        private unowned Adw.WindowTitle window_title;
        [GtkChild]
        private unowned Grid game_grid;
        [GtkChild]
        private unowned Box player_top_box;
        [GtkChild]
        private unowned Box user_container;
        [GtkChild]
        private unowned Box player_left_box;
        [GtkChild]
        private unowned Box player_right_box;
        [GtkChild]
        private unowned Label status_label;

        [GtkChild]
        private unowned Box score_box;
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
        private unowned Box top2_cards;
        [GtkChild]
        private unowned Box left_cards;
        [GtkChild]
        private unowned Box right_cards;
        [GtkChild]
        private unowned Box right2_cards;
        [GtkChild]
        private unowned Box bottom2_cards;

        [GtkChild]
        private unowned Adw.Avatar avatar_top;
        [GtkChild]
        private unowned Adw.Avatar avatar_top2;
        [GtkChild]
        private unowned Adw.Avatar avatar_left;
        [GtkChild]
        private unowned Adw.Avatar avatar_right;
        [GtkChild]
        private unowned Adw.Avatar avatar_right2;
        [GtkChild]
        private unowned Adw.Avatar avatar_bottom2;
        [GtkChild]
        private unowned Adw.Avatar avatar_user;

        [GtkChild]
        private unowned Label label_top;
        [GtkChild]
        private unowned Label label_top2;
        [GtkChild]
        private unowned Label label_left;
        [GtkChild]
        private unowned Label label_right;
        [GtkChild]
        private unowned Label label_right2;
        [GtkChild]
        private unowned Label label_bottom2;

        [GtkChild]
        private unowned Box part1_container;
        [GtkChild]
        private unowned Box part2_container;
        [GtkChild]
        private unowned Box part3_container;
        [GtkChild]
        private unowned Box opp1_container;
        [GtkChild]
        private unowned Box opp3_container;

        [GtkChild]
        private unowned Box table_cards_box;

        private void update_avatars() {
             load_avatar(avatar_user, game.players[0].avatar_icon);

             int size = game.players.size;
             if (size == 2) {

                 load_avatar(avatar_top, game.players[1].avatar_icon);
                 label_top.label = game.players[1].name;
             } else if (size == 4) {

                 load_avatar(avatar_right, game.players[1].avatar_icon);
                 label_right.label = game.players[1].name;
                 load_avatar(avatar_top, game.players[2].avatar_icon);
                 label_top.label = game.players[2].name;
                 load_avatar(avatar_left, game.players[3].avatar_icon);
                 label_left.label = game.players[3].name;
             } else if (size == 6) {

                 load_avatar(avatar_bottom2, game.players[1].avatar_icon);
                 label_bottom2.label = game.players[1].name;

                 load_avatar(avatar_right, game.players[2].avatar_icon);
                 label_right.label = game.players[2].name;

                 load_avatar(avatar_top2, game.players[3].avatar_icon);
                 label_top2.label = game.players[3].name;

                 load_avatar(avatar_top, game.players[4].avatar_icon);
                 label_top.label = game.players[4].name;

                 load_avatar(avatar_left, game.players[5].avatar_icon);
                 label_left.label = game.players[5].name;
             }
        }

        private void load_avatar(Adw.Avatar avatar, string resource_path) {
            var paintable = Gdk.Texture.from_resource(Config.RESOURCE_PATH + "/" + resource_path);
            avatar.set_custom_image(paintable);
        }

        private void update_layout_visibility() {
            int size = game.players.size;

            part2_container.visible = false;
            part3_container.visible = false;
            opp3_container.visible = false;

            player_top_box.homogeneous = false;
            user_container.homogeneous = false;

            if (size == 2) {

                player_left_box.visible = false;
                player_right_box.visible = false;
                avatar_top.parent.visible = true;

                player_top_box.margin_start = 0;
                player_top_box.margin_end = 0;
                player_top_box.halign = Align.CENTER;
                player_top_box.hexpand = false;
                player_top_box.homogeneous = false;

                user_container.margin_start = 0;
                user_container.margin_end = 0;
                user_container.halign = Align.CENTER;
                user_container.hexpand = false;
                user_container.homogeneous = false;
            } else if (size == 4) {

                player_left_box.visible = true;
                player_right_box.visible = true;
                avatar_top.parent.visible = true;

                player_top_box.margin_start = 0;
                player_top_box.margin_end = 0;
                player_top_box.halign = Align.CENTER;
                player_top_box.hexpand = false;
                player_top_box.homogeneous = false;

                user_container.margin_start = 0;
                user_container.margin_end = 0;
                user_container.halign = Align.CENTER;
                user_container.hexpand = false;
                user_container.homogeneous = false;
            } else if (size == 6) {

                player_left_box.visible = true;
                player_right_box.visible = true;
                avatar_top.parent.visible = true;

                part2_container.visible = true;
                part3_container.visible = true;

                player_top_box.margin_start = 150;
                player_top_box.margin_end = 150;
                player_top_box.halign = Align.FILL;
                player_top_box.hexpand = true;
                player_top_box.homogeneous = true;

                user_container.margin_start = 150;
                user_container.margin_end = 150;
                user_container.halign = Align.FILL;
                user_container.hexpand = true;
                user_container.homogeneous = true;
            }
        }

        private void update_opp_box(Box b, int count, string rotation_class) {
             clean_box(b);
             for (int i=0; i<count; i++) {
                 var img = new Image.from_resource(Config.RESOURCE_PATH + "/" + current_card_back);
                 img.pixel_size = 115;
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

        [GtkChild]
        private unowned MenuButton btn_envido;
        [GtkChild]
        private unowned Button btn_call_envido;
        [GtkChild]
        private unowned Button btn_call_real_envido;
        [GtkChild]
        private unowned Button btn_call_falta_envido;

        [GtkChild]
        private unowned Button btn_call_flor;

        [GtkChild]
        private unowned Button btn_hint;

        [GtkChild]
        private unowned Box tutorial_dimmer;
        [GtkChild]
        private unowned Box tutorial_overlay;
        [GtkChild]
        private unowned Label tutorial_title;
        [GtkChild]
        private unowned Label tutorial_text;
        [GtkChild]
        private unowned Button btn_tutorial_next;
        [GtkChild]
        private unowned Button btn_tutorial_close;

        private GameState game;
        private TutorialManager tutorial_manager;

        private Truco.Network.MultiplayerGameController? mp_controller = null;
        public bool online_mode { get { return mp_controller != null; } }

        private string current_felt_class = "felt-green";
        private string current_card_back = "cards/backs/player_card_back_design_1_blue.svg";
        private int current_deck_style = 0;
        private bool raise_dialog_shown = false;

        public Window (Gtk.Application app) {
            Object (application: app);

            if (Config.PROFILE == "Devel") {
                add_css_class ("devel");
                window_title.title = Config.NAME;
            }

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

            update_layout_visibility();

            load_settings(settings);

            settings.changed["felt-color"].connect (() => {
                set_felt_color(settings.get_string("felt-color"));
            });
            settings.changed["card-back"].connect (() => {
                set_card_back(settings.get_string("card-back"));
            });
            settings.changed["avatar"].connect (() => {
                set_user_avatar(settings.get_string("avatar"));
            });
            settings.changed["deck-style"].connect (() => {
                set_deck_style(settings.get_int("deck-style"));
            });

            update_ui();

            var new_game_action = new SimpleAction ("new-game", null);
            new_game_action.activate.connect (on_new_game);
            add_action (new_game_action);

            var new_game_quick_action = new SimpleAction ("new-game-quick", null);
            new_game_quick_action.activate.connect (on_new_game_quick);
            add_action (new_game_quick_action);

            btn_truco.clicked.connect (() => {
                if (game.raise_stake(0)) {
                    update_ui();
                    if (mp_controller != null) {

                        mp_controller.local_call_truco(game.proposed_stake ?? 3);
                    } else {

                        GLib.Timeout.add(1000, () => {
                            game.cpu_respond_truco();
                            update_ui();
                            check_cpu_turn();
                            return false;
                        });
                    }
                }
            });

            btn_accept.clicked.connect(() => {
                game.respond_challenge(0, true);
                if (mp_controller != null) {
                    mp_controller.local_respond_truco("accept");
                }
                update_ui();
                check_cpu_turn();
            });

            btn_refuse.clicked.connect(() => {
                game.respond_challenge(0, false);
                if (mp_controller != null) {
                    mp_controller.local_respond_truco("run");
                }
                update_ui();
            });

            btn_call_envido.clicked.connect(() => {
                if (game.call_envido(0, 0)) {
                    update_ui();
                    if (mp_controller != null) mp_controller.local_call_bet("envido");
                    else check_cpu_turn();
                }
            });

            btn_call_real_envido.clicked.connect(() => {
                if (game.call_envido(0, 1)) {
                    update_ui();
                    if (mp_controller != null) mp_controller.local_call_bet("real_envido");
                    else check_cpu_turn();
                }
            });

            btn_call_falta_envido.clicked.connect(() => {
                if (game.call_envido(0, 2)) {
                    update_ui();
                    if (mp_controller != null) mp_controller.local_call_bet("falta_envido");
                    else check_cpu_turn();
                }
            });

            btn_call_flor.clicked.connect(() => {
                if (game.call_flor(0)) {
                    update_ui();
                    if (mp_controller != null) mp_controller.local_call_bet("flor");
                    else check_cpu_turn();
                }
            });

            btn_hint.clicked.connect(() => {
                on_hint_clicked();
            });

            var tutorial_action = new SimpleAction ("tutorial", null);
            tutorial_action.activate.connect (on_tutorial_activated);
            add_action (tutorial_action);

            tutorial_manager = new TutorialManager(this);

            btn_tutorial_next.clicked.connect(() => {
                tutorial_manager.next();
            });

            btn_tutorial_close.clicked.connect(() => {
                tutorial_manager.finish();
            });
        }

        private void load_settings(GLib.Settings settings) {
            set_felt_color(settings.get_string("felt-color"));
            set_card_back(settings.get_string("card-back"));
            set_user_avatar(settings.get_string("avatar"));
            set_deck_style(settings.get_int("deck-style"));
        }

        public void set_deck_style(int style) {
            current_deck_style = style;
            update_ui();
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

            update_ui();
        }

        private void on_new_game(SimpleAction action, Variant? parameter) {
             on_new_game_void();
        }

        private void on_new_game_void() {
            var dialog = new NewGameDialog();
            dialog.response.connect((response) => {
                if (dialog.selected_variant != null) {
                    game = new GameState(
                        dialog.selected_variant,
                        dialog.selected_team_size,
                        dialog.selected_fixed_manilha,
                        dialog.selected_hidden_vira
                    );
                    setup_game_signals();
                    update_layout_visibility();
                    update_ui();
                    check_cpu_turn();
                }
            });
            dialog.present(this);
        }

        public string get_local_player_name () {
            var settings = new GLib.Settings (Config.SCHEMA_ID);
            var u = settings.get_string ("username").strip ();
            if (u != "") {
                return u;
            }
            var n = GLib.Environment.get_real_name ();
            return (n == null || n == "Unknown" || n.strip () == "") ? _("Player") : n;
        }

        public void start_multiplayer_game (Truco.Network.MultiplayerGameController controller,
                                            string variant, int seat, int first_dealer, uint32 seed) {
            mp_controller = controller;
            game = new GameState.online (variant, seat, seed, first_dealer);

            if (game.players.size > 1) {
                game.players.get (1).name = controller.session.opponent_name;
            }
            setup_game_signals ();
            connect_multiplayer_signals (controller);
            update_layout_visibility ();
            update_ui ();
        }

        private void connect_multiplayer_signals (Truco.Network.MultiplayerGameController c) {
            c.opponent_played_card.connect ((suit, value) => {
                apply_remote_card (suit, value);
            });
            c.opponent_called_truco.connect ((level) => {
                apply_remote_truco (level);
            });
            c.opponent_responded_truco.connect ((response) => {
                apply_remote_truco_response (response);
            });
            c.opponent_called_bet.connect ((bet) => {
                apply_remote_bet (bet);
            });
            c.opponent_responded_bet.connect ((response) => {
                apply_remote_bet_response (response);
            });
            c.opponent_mao_de_11_decision.connect ((accepted) => {
                apply_remote_mao_de_11 (accepted);
            });
            c.opponent_signalled.connect ((text) => {
                apply_remote_signal (text);
            });
            c.opponent_chat.connect ((text) => {
                show_remote_chat (text);
            });
            c.session.opponent_left.connect ((reason) => {
                show_opponent_left (reason);
            });
        }

        private void apply_remote_card (Truco.Suit suit, int value) {
            if (mp_controller == null) return;
            int opp_index = mp_controller.local_seat == 0 ? 1 : 0;
            game.play_card_for_player (opp_index, suit, value);
            update_ui ();
            check_cpu_turn ();
        }

        private void apply_remote_truco (int level) {
            if (mp_controller == null) return;
            int opp_index = mp_controller.local_seat == 0 ? 1 : 0;
            game.remote_raise_stake (opp_index);
            update_ui ();
        }

        private void apply_remote_truco_response (string response) {
            if (mp_controller == null) return;
            int opp_index = mp_controller.local_seat == 0 ? 1 : 0;
            switch (response) {
                case "raise":
                    game.remote_raise_stake (opp_index);
                    break;
                case "run":
                    game.remote_respond_challenge (opp_index, false);
                    break;
                default:
                    game.remote_respond_challenge (opp_index, true);
                    break;
            }
            update_ui ();
        }

        private void apply_remote_bet (string bet) {
            if (mp_controller == null) return;
            int opp_index = mp_controller.local_seat == 0 ? 1 : 0;
            if (bet == "flor") {
                game.remote_call_flor (opp_index);
            } else {
                int type = 0;
                if (bet == "real_envido") type = 1;
                else if (bet == "falta_envido") type = 2;
                game.remote_call_envido (opp_index, type);
            }
            update_ui ();
        }

        private void apply_remote_bet_response (string response) {
            if (mp_controller == null) return;
            int opp_index = mp_controller.local_seat == 0 ? 1 : 0;
            game.remote_respond_bet (opp_index, response == "accept");
            update_ui ();
        }

        private void apply_remote_mao_de_11 (bool accepted) {
            if (mp_controller == null) return;
            int opp_index = mp_controller.local_seat == 0 ? 1 : 0;
            game.remote_mao_de_11_decision (opp_index, accepted);
            update_ui ();
        }

        private void apply_remote_signal (string text) {
            if (mp_controller == null) return;
            int opp_index = mp_controller.local_seat == 0 ? 1 : 0;
            if (opp_index < game.players.size) {
                game.players[opp_index].last_signal = text;
            }
            update_ui ();
        }

        private void show_remote_chat (string text) {
            status_label.label = _("Opponent: %s").printf (text);
        }

        private void show_opponent_left (string reason) {
            string msg = (reason == "resign")
                ? _("Your opponent resigned. You win!")
                : _("Your opponent left the game.");
            var dialog = new Adw.AlertDialog (_("Game Over"), msg);
            dialog.add_response ("ok", _("OK"));
            dialog.present (this);
            mp_controller = null;
        }

        private void on_new_game_quick(SimpleAction action, Variant? parameter) {
             game = new GameState(game.game_mode);
             setup_game_signals();
             update_ui();
             check_cpu_turn();
        }

        private void setup_game_signals() {
            game.match_ended.connect((winning_team) => {
                show_match_end_dialog(winning_team);
            });

            game.show_partner_cards.connect(() => {
                show_mao_11_dialog();
            });

            game.turn_advanced.connect(update_ui);
        }

        private void check_cpu_turn() {
            if (game.game_over || game.match_over) return;

            if (mp_controller != null) return;

            if (game.proposed_stake != null) {
                int responding_team = (game.challenger_team == 0) ? 1 : 0;

                if (responding_team == 0) {

                    return;
                } else {

                    GLib.Timeout.add(1000, () => {
                        if (game.proposed_stake != null && (game.challenger_team == 0)) {
                            game.cpu_respond_truco();
                            update_ui();
                            check_cpu_turn();
                        }
                        return false;
                    });
                    return;
                }
            }

            if (game.state_envido_pending) {
                int responding_team = (game.envido_challenger_team == 0) ? 1 : 0;
                if (responding_team == 0) {

                    if (!raise_dialog_shown) {
                        string challenger_name = (game.envido_challenger_team == 1) ? _("Opponent") : _("Partner");
                        show_envido_dialog(challenger_name, game.envido_stake);
                        raise_dialog_shown = true;
                    }
                    return;
                } else {

                    GLib.Timeout.add(1000, () => {
                        if (game.state_envido_pending && game.envido_challenger_team != null && game.envido_challenger_team == 0) {
                            game.cpu_respond_envido();
                            update_ui();
                            check_cpu_turn();
                        }
                        return false;
                    });
                    return;
                }
            }

            if (game.state_mao_11_pending) {
                int limit = game.get_max_points();
                int team11_cpu = -1;
                if (game.score_manager.score_team_1 == limit - 1) team11_cpu = 1;
                else if (game.score_manager.score_team_0 == limit - 1 && game.players[2].is_cpu && game.players[0].is_cpu) {
                    team11_cpu = 0;
                }

                if (team11_cpu != -1) {
                    GLib.Timeout.add(1000, () => {
                         if (!game.state_mao_11_pending) return false;
                         game.cpu_respond_truco();
                         update_ui();
                         check_cpu_turn();
                         return false;
                    });
                    return;
                }

                return;
            }

            int pid = game.current_player_index;
            if (game.players[pid].is_cpu) {
                 GLib.Timeout.add(1000, () => {
                     if (game.game_over || game.match_over || game.proposed_stake != null || game.state_mao_11_pending || game.state_envido_pending) return false;

                     game.cpu_turn();
                     update_ui();

                     if (game.proposed_stake == null && !game.state_envido_pending && !game.game_over) {
                         int next_pid = game.current_player_index;
                         if (game.players[next_pid].is_cpu) {
                             check_cpu_turn();
                         }
                     } else {

                         check_cpu_turn();
                     }
                     return false;
                 });
            }
        }

        private void update_ui() {
            if (game.match_over) {
                 window_title.subtitle = "MATCH OVER! %s Wins!".printf(game.matches_won_team_0 > game.matches_won_team_1 ? "YOU" : "CPU");
            } else {
                 string variant_str = game.game_mode.substring(0,1).up() + game.game_mode.substring(1);
                 window_title.subtitle = _("%s Variant").printf(variant_str);
            }

            score_box.visible = true;
            match_score_us_label.label = game.matches_won_team_0.to_string();
            match_score_them_label.label = game.matches_won_team_1.to_string();
            game_score_us_label.label = game.score_manager.get_score_label(game.score_manager.score_team_0);
            game_score_them_label.label = game.score_manager.get_score_label(game.score_manager.score_team_1);

            update_avatars();

            string stake_text = _("Stake: %d").printf(game.stake);

            if (game.proposed_stake != null) {
                int challenger = game.challenger_team;
                status_label.label = _("Truco! %d proposed by Team %d.").printf(game.proposed_stake, challenger);

                if (challenger != 0) {

                    btn_accept.visible = false;
                    btn_refuse.visible = false;

                    if (!raise_dialog_shown) {
                         show_raise_dialog(game.players[game.current_player_index].name, game.proposed_stake);
                         raise_dialog_shown = true;
                    }

                    btn_truco.visible = false;

                } else {
                    status_label.label = _("Waiting for response...");
                    btn_accept.visible = false;
                    btn_refuse.visible = false;
                    btn_truco.visible = false;
                    raise_dialog_shown = false;
                }
            } else if (game.state_envido_pending) {
                int challenger = game.envido_challenger_team;
                status_label.label = _("Envido! Points proposed by Team %d.").printf(challenger);

                if (challenger != 0) {
                    btn_accept.visible = false;
                    btn_refuse.visible = false;

                    if (!raise_dialog_shown) {
                         show_envido_dialog(game.players[game.current_player_index].name, game.envido_stake);
                         raise_dialog_shown = true;
                    }
                    btn_truco.visible = false;
                } else {
                    status_label.label = _("Waiting for Envido response...");
                    btn_accept.visible = false;
                    btn_refuse.visible = false;
                    btn_truco.visible = false;
                    raise_dialog_shown = false;
                }
            } else {
                raise_dialog_shown = false;

                turn_indicator_label.label = _("Turn: %s | %s").printf(game.players[game.current_player_index].name, stake_text);

                status_label.label = game.players[0].name;

                btn_accept.visible = false;
                btn_refuse.visible = false;

                bool is_international = (game.game_mode == "uruguayo" || game.game_mode == "venezolano" || game.game_mode == "argentino");
                if (is_international && game.envido_available && !game.envido_played && !game.state_envido_pending && game.current_player_index == 0) {
                     btn_envido.visible = true;
                } else {
                     btn_envido.visible = false;
                }

                btn_truco.visible = true;
                btn_truco.sensitive = (game.current_player_index == 0);

                string lbl = _("TRUCO!");
                bool is_brazil = (game.game_mode == "paulista" || game.game_mode == "mineiro");
                bool is_venezuela = (game.game_mode == "venezolano");

                if (is_brazil) {
                    if (game.stake == 3) lbl = _("SIX!");
                    else if (game.stake == 6) lbl = _("NINE!");
                    else if (game.stake == 9) lbl = _("TWELVE!");
                } else if (is_venezuela) {
                     if (game.stake == 3) lbl = _("RETRUCO!");
                     else if (game.stake == 4) lbl = _("VALE JUEGO!");
                } else {

                    if (game.stake == 2) lbl = _("RETRUCO!");
                    else if (game.stake == 3) lbl = _("VALE CUATRO!");
                }

                if (game.envido_available && game.rules_engine.has_flor(game.players[0].hand) &&
                    ((!game.envido_played && !game.state_envido_pending) || game.state_envido_pending)) {

                     btn_call_flor.visible = true;
                } else {
                     btn_call_flor.visible = false;
                }

                int limit = game.get_max_points();

                if (is_brazil &&
                    (game.score_manager.score_team_0 == limit - 1 || game.score_manager.score_team_1 == limit - 1)) {
                    btn_truco.sensitive = false;
                    string hand_type = (game.score_manager.score_team_0 == limit - 1 && game.score_manager.score_team_1 == limit - 1) ? _("MÃO DE FERRO") : _("MÃO DE 11");
                    turn_indicator_label.label = _("Turn: %s | %s").printf(game.players[game.current_player_index].name, hand_type);
                 } else {

                     if (is_brazil && game.stake >= 12) btn_truco.sensitive = false;
                     else if (is_venezuela && game.stake >= 5) btn_truco.sensitive = false;
                     else if (!is_brazil && !is_venezuela && game.stake >= 4) btn_truco.sensitive = false;
                     else btn_truco.label = lbl;
                 }
            }

            round_label.label = _("Round: %d").printf(game.round_count);

            clean_box(player_hand_box);
            for (int i = 0; i < game.players[0].hand.size; i++) {
                var c = game.players[0].hand[i];
                var btn = new Button();
                btn.add_css_class("player-card");

                string card_img_path = c.get_svg_name(current_deck_style);
                if (game.state_mao_de_ferro) {
                    card_img_path = current_card_back;
                }

                var img = new Image.from_resource(Config.RESOURCE_PATH + "/" + card_img_path);
                img.pixel_size = 115;
                btn.set_child(img);

                if (game.current_player_index != 0 || game.proposed_stake != null || game.state_mao_11_pending) {
                    btn.sensitive = false;
                }

                int idx = i;
                var played = c;
                btn.clicked.connect(() => {
                    if (game.play_card(0, idx)) {
                        if (mp_controller != null) {
                            mp_controller.local_play_card(played);
                        }
                        update_ui();
                        check_cpu_turn();
                    }
                });
                player_hand_box.append(btn);
            }

            clean_box(top_cards);
            clean_box(top2_cards);
            clean_box(left_cards);
            clean_box(right_cards);
            clean_box(right2_cards);
            clean_box(bottom2_cards);

            int size = game.players.size;
            if (size == 2) {
                update_opp_box(top_cards, game.players[1].hand.size, "rotate-180");
            } else if (size == 4) {
                update_opp_box(right_cards, game.players[1].hand.size, "rotate-90");
                update_opp_box(top_cards, game.players[2].hand.size, "rotate-180");
                update_opp_box(left_cards, game.players[3].hand.size, "rotate-270");
            } else if (size == 6) {

                update_opp_box(bottom2_cards, game.players[1].hand.size, "");
                update_opp_box(right_cards, game.players[2].hand.size, "rotate-90");
                update_opp_box(top2_cards, game.players[3].hand.size, "rotate-180");
                update_opp_box(top_cards, game.players[4].hand.size, "rotate-180");
                update_opp_box(left_cards, game.players[5].hand.size, "rotate-270");
            }

            clean_box(table_cards_box);
            if (size == 6) {
                var row1 = new Box(Orientation.HORIZONTAL, 5);
                row1.halign = Align.CENTER;
                var row2 = new Box(Orientation.HORIZONTAL, 5);
                row2.halign = Align.CENTER;
                table_cards_box.append(row1);
                table_cards_box.append(row2);

                for (int i = 0; i < game.table_cards.size; i++) {
                    var c = game.table_cards[i];
                    var img = new Image.from_resource(Config.RESOURCE_PATH + "/" + c.get_svg_name(current_deck_style));
                    img.pixel_size = 115;
                    img.add_css_class("card-on-table");
                    if (i < 3) row1.append(img);
                    else row2.append(img);
                }
            } else {
                var row = new Box(Orientation.HORIZONTAL, 5);
                row.halign = Align.CENTER;
                table_cards_box.append(row);
                for (int i = 0; i < game.table_cards.size; i++) {
                    var c = game.table_cards[i];
                    var img = new Image.from_resource(Config.RESOURCE_PATH + "/" + c.get_svg_name(current_deck_style));
                    img.pixel_size = 115;
                    img.add_css_class("card-on-table");
                    row.append(img);
                }
            }

            if (game.vira != null) {
                vira_box.visible = !game.hidden_vira;
                vira_image.set_from_resource(Config.RESOURCE_PATH + "/" + game.vira.get_svg_name(current_deck_style));
            } else {
                vira_box.visible = false;
            }

            update_history_ui();
        }

        private void update_history_ui() {
            clean_listbox(history_box);

            foreach (var item in game.history) {
                var h = item.message;
                var pid = item.player_id;

                if (h.contains("Match Started") || h.contains("New Game") || h.contains("Cards dealt")) continue;
                if (h.contains("Score 0-0")) continue;

                if (h.contains("started")) {
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
            split_view.show_sidebar = false;

            string call_name = _("Truco!");
            if (new_stake == 6) call_name = _("SIX!");
            else if (new_stake == 9) call_name = _("NINE!");
            else if (new_stake == 12) call_name = _("TWELVE!");

            var dialog = DialogFactory.create_game_dialog(
                call_name,
                _("%s proposed %s (Stake: %d)").printf(challenger_name, call_name, new_stake),
                _("Accept"),
                _("Run")
            );

            int current_prop = game.proposed_stake;
            int next_val = 0;
            string raise_lbl = "";

            if (game.game_mode == "paulista" || game.game_mode == "mineiro") {
                if (current_prop == 3) { next_val = 6; raise_lbl = _("Six!"); }
                else if (current_prop == 6) { next_val = 9; raise_lbl = _("Nine!"); }
                else if (current_prop == 9) { next_val = 12; raise_lbl = _("Twelve!"); }
            } else if (game.game_mode == "argentino" || game.game_mode == "uruguayo") {
                if (current_prop == 2) { next_val = 3; raise_lbl = _("Retruco!"); }
                else if (current_prop == 3) { next_val = 4; raise_lbl = _("Vale Cuatro!"); }
            } else if (game.game_mode == "venezolano") {
                if (current_prop == 3) { next_val = 4; raise_lbl = _("Retruco!"); }
                else if (current_prop == 4) { next_val = 5; raise_lbl = _("Vale Juego!"); }
            }

            int limit = game.get_max_points();

            bool mao_de_11 = (game.score_manager.score_team_0 >= limit - 1 || game.score_manager.score_team_1 >= limit - 1);
            if (game.game_mode != "paulista" && game.game_mode != "mineiro") mao_de_11 = false;

            if (next_val > 0 && !mao_de_11) {
                dialog.add_response ("raise", raise_lbl);
                dialog.set_default_response ("raise");
            } else {
                dialog.set_default_response ("accept");
            }

            dialog.response.connect ((response) => {
                 if (response == "accept") {
                     game.respond_challenge(0, true);
                     update_ui();
                     check_cpu_turn();
                 } else if (response == "refuse") {
                     game.respond_challenge(0, false);
                     update_ui();
                 } else if (response == "raise") {
                     bool success = game.raise_stake(0);
                     if (success) {
                        update_ui();
                        if (mp_controller != null) {
                            mp_controller.local_call_truco(game.proposed_stake ?? 3);
                        } else {

                            GLib.Timeout.add(1000, () => {
                                game.cpu_respond_truco();
                                update_ui();
                                check_cpu_turn();
                                return false;
                            });
                        }
                     }
                 }
            });

            dialog.present (this);
        }

        private void show_envido_dialog(string challenger_name, int points) {
            split_view.show_sidebar = false;

            string call_name = _("Envido!");
            if (points == 3) call_name = _("Real Envido!");
            else if (points > 3) call_name = _("Falta Envido!");

            var dialog = DialogFactory.create_game_dialog(
                call_name,
                _("%s proposed %s").printf(challenger_name, call_name),
                _("Quiero (Accept)"),
                _("No Quiero (Run)")
            );

            dialog.response.connect ((response) => {
                 if (response == "accept") {
                     game.respond_envido(0, true);
                     if (mp_controller != null) mp_controller.local_respond_bet("accept");
                     update_ui();
                     check_cpu_turn();
                 } else if (response == "refuse") {
                     game.respond_envido(0, false);
                     if (mp_controller != null) mp_controller.local_respond_bet("refuse");
                     update_ui();
                     check_cpu_turn();
                 }
            });

            dialog.present (this);
        }

        private void show_match_end_dialog(int winning_team) {
            split_view.show_sidebar = false;

            var dialog = new MatchEndDialog(
                winning_team,
                game.score_manager.score_team_0, game.score_manager.score_team_1,
                game.matches_won_team_0, game.matches_won_team_1,
                game.rounds_won_team_0, game.total_rounds_played
            );

            dialog.match_response.connect((response) => {
                if (response == "new") {
                   game.reset_match();
                   update_ui();
                   check_cpu_turn();
                } else if (response == "quit") {
                   close();
                }
            });

            dialog.present(this);
        }

        private void show_mao_11_dialog() {
            split_view.show_sidebar = false;

            bool has_partner = game.players.size > 2;

            string body = has_partner
                ? _("Your team has 11 points. You can see your partner's cards. Do you want to play this round (Worth 3 points)?")
                : _("Your team has 11 points. Do you want to play this round (Worth 3 points)?");

            var dialog = DialogFactory.create_game_dialog(
                _("Mão de 11!"),
                body,
                _("Play (Worth 3)"),
                _("Run (Give 1 point)")
            );

            if (has_partner) {

                var box = new Box(Orientation.VERTICAL, 12);
                box.halign = Align.CENTER;

                var cards_box = new Box(Orientation.HORIZONTAL, 6);
                cards_box.halign = Align.CENTER;

                foreach (var c in game.players[2].hand) {
                    var img = new Image.from_resource(Config.RESOURCE_PATH + "/" + c.get_svg_name(current_deck_style));
                    img.pixel_size = 80;
                    cards_box.append(img);
                }

                box.append(new Label(_("Your Partner's Hand:")));
                box.append(cards_box);
                dialog.set_extra_child(box);
            }

            dialog.response.connect((response) => {
                bool accepted = (response == "accept");
                game.respond_challenge(0, accepted);
                if (mp_controller != null) {
                    mp_controller.local_mao_de_11_decision(accepted);
                }
                update_ui();
            });

            dialog.present(this);
        }

        private void on_hint_clicked() {
            string? hint = game.get_hint(0);
            if (hint != null) {
                status_label.label = hint;
            }
        }

        private void on_tutorial_activated(SimpleAction action, Variant? parameter) {
            tutorial_manager.start();
        }

        public void show_tutorial_step(string title, string instruction, string? highlight_id) {
            tutorial_title.label = title;
            tutorial_text.label = instruction;

            tutorial_dimmer.visible = true;
            tutorial_overlay.visible = true;

            clear_tutorial_highlights();

            if (highlight_id != null) {
                var widget = get_widget_by_id(highlight_id);
                if (widget != null) {
                    widget.add_css_class("tutorial-highlight");
                }
            }
        }

        private Gtk.Widget? get_widget_by_id(string id) {
            switch (id) {
                case "avatar_user": return avatar_user;
                case "vira_box": return vira_box;
                case "score_box": return score_box;
                case "btn_truco": return btn_truco;
                case "btn_hint": return btn_hint;
                default: return null;
            }
        }

        private void clear_tutorial_highlights() {
            avatar_user.remove_css_class("tutorial-highlight");
            vira_box.remove_css_class("tutorial-highlight");
            score_box.remove_css_class("tutorial-highlight");
            btn_truco.remove_css_class("tutorial-highlight");
            btn_hint.remove_css_class("tutorial-highlight");
        }

        public void hide_tutorial() {
            tutorial_dimmer.visible = false;
            tutorial_overlay.visible = false;
            clear_tutorial_highlights();
        }
    }
}

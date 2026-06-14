using Gtk;
using Adw;
using Truco.Network;

namespace Truco {

    [GtkTemplate (ui = "/io/github/tobagin/Truco/online_dialog.ui")]
    public class OnlineDialog : Adw.Dialog {

        public const string DEFAULT_SERVER = "wss://truco.tobagin.eu";

        [GtkChild] private unowned Adw.ToastOverlay toasts;
        [GtkChild] private unowned Adw.NavigationView nav;
        [GtkChild] private unowned Adw.ComboRow variant_row;
        [GtkChild] private unowned Gtk.Button quick_button;
        [GtkChild] private unowned Gtk.Button create_button;
        [GtkChild] private unowned Gtk.Button join_button;

        [GtkChild] private unowned Gtk.Spinner search_spinner;
        [GtkChild] private unowned Gtk.Label search_variant_label;
        [GtkChild] private unowned Gtk.Button search_cancel_button;

        [GtkChild] private unowned Gtk.Label room_creating_label;
        [GtkChild] private unowned Gtk.Box room_code_box;
        [GtkChild] private unowned Gtk.Label room_code_label;
        [GtkChild] private unowned Gtk.Label room_wait_label;
        [GtkChild] private unowned Gtk.Spinner room_spinner;
        [GtkChild] private unowned Gtk.Button room_copy_button;
        [GtkChild] private unowned Gtk.Button room_cancel_button;

        [GtkChild] private unowned Adw.EntryRow join_code_row;
        [GtkChild] private unowned Gtk.Button join_confirm_button;
        [GtkChild] private unowned Gtk.Spinner join_spinner;

        private NetworkSession session;
        private MultiplayerGameController controller;

        private enum Mode { NONE, SEARCHING, ROOM, JOIN }
        private Mode mode = Mode.NONE;

        public signal void game_ready (MultiplayerGameController controller,
                                       string variant, int seat, int first_dealer, uint32 seed);

        public OnlineDialog (string player_name) {
            Object ();

            session = new NetworkSession (player_name);
            controller = new MultiplayerGameController (session);
            wire_session ();

            quick_button.clicked.connect (on_quick_match);
            create_button.clicked.connect (on_create_room);
            join_button.clicked.connect (on_open_join);
            search_cancel_button.clicked.connect (() => nav.pop ());
            room_cancel_button.clicked.connect (() => nav.pop ());
            room_copy_button.clicked.connect (on_copy_code);
            join_confirm_button.clicked.connect (on_join_confirm);
            join_code_row.changed.connect (() => {
                join_confirm_button.sensitive = join_code_row.text.strip () != "";
            });

            nav.popped.connect ((page) => leave_current_mode ());
        }

        private string selected_variant () {
            switch (variant_row.selected) {
                case 0: return "mineiro";
                case 1: return "paulista";
                case 2: return "uruguayo";
                case 3: return "venezolano";
                case 4: return "argentino";
                default: return "paulista";
            }
        }

        private string variant_display () {
            return ((Gtk.StringList) variant_row.model).get_string (variant_row.selected);
        }

        private void toast (string text) {
            toasts.add_toast (new Adw.Toast (text));
        }

        private async void ensure_connected () {
            if (session.state == SessionState.DISCONNECTED) {
                yield session.connect_to_server (DEFAULT_SERVER);
            }
        }

        private void leave_current_mode () {
            switch (mode) {
                case Mode.SEARCHING:
                    if (session.state == SessionState.WAITING) {
                        session.cancel_quick_match ();
                    }
                    search_spinner.stop ();
                    break;
                case Mode.ROOM:

                    if (session.state != SessionState.IN_GAME) {
                        session.disconnect ();
                    }
                    room_spinner.stop ();
                    break;
                case Mode.JOIN:
                    join_spinner.visible = false;
                    join_spinner.stop ();
                    break;
                default:
                    break;
            }
            mode = Mode.NONE;
        }

        private void on_quick_match () {
            mode = Mode.SEARCHING;
            search_variant_label.label = variant_display ();
            search_spinner.start ();
            nav.push_by_tag ("searching");

            ensure_connected.begin ((o, r) => {
                ensure_connected.end (r);
                session.quick_match (selected_variant ());
            });
        }

        private void on_create_room () {
            mode = Mode.ROOM;
            room_creating_label.visible = true;
            room_creating_label.label = _("Creating room…");
            room_code_box.visible = false;
            room_spinner.start ();
            nav.push_by_tag ("room");

            ensure_connected.begin ((o, r) => {
                ensure_connected.end (r);
                session.create_room (selected_variant ());
            });
        }

        private void on_open_join () {
            mode = Mode.JOIN;
            join_code_row.text = "";
            join_confirm_button.sensitive = false;
            join_spinner.visible = false;
            nav.push_by_tag ("join");
            join_code_row.grab_focus ();
        }

        private void on_join_confirm () {
            string code = join_code_row.text.strip ().up ();
            if (code == "") {
                return;
            }
            join_confirm_button.sensitive = false;
            join_spinner.visible = true;
            join_spinner.start ();

            ensure_connected.begin ((o, r) => {
                ensure_connected.end (r);
                session.join_room (code);
            });
        }

        private void on_copy_code () {
            var clipboard = Gdk.Display.get_default ().get_clipboard ();
            clipboard.set_text (room_code_label.label);
            toast (_("Code copied"));
        }

        private void wire_session () {
            session.room_created.connect ((code) => {
                room_creating_label.visible = false;
                room_code_label.label = code;
                room_code_box.visible = true;
                room_wait_label.label = _("Waiting for opponent…");
            });
            session.opponent_joined.connect ((name) => {
                room_wait_label.label = _("%s joined. Starting…").printf (name);
            });
            session.game_started.connect (() => {
                mode = Mode.NONE;
                game_ready (controller, session.variant, session.seat,
                            session.first_dealer, session.deal_seed);
                this.close ();
            });
            session.quick_match_cancelled.connect (() => {
                search_spinner.stop ();
            });
            session.session_error.connect ((code, message) => {
                if (nav.visible_page != null && nav.visible_page.tag != "main") {
                    mode = Mode.NONE;
                    nav.pop_to_tag ("main");
                }
                join_spinner.visible = false;
                toast (_("Error: %s").printf (message));
            });
        }
    }
}

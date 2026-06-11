using Gtk;
using Adw;
using Truco.Network;

namespace Truco {

    /**
     * Connect-to-multiplayer dialog: pick a server, then create a private
     * room, join one by code, or enter quick matchmaking. Built in code
     * (no Blueprint template) so it has no compiled UI dependency.
     *
     * When both players are present the dialog emits `game_ready`, handing the
     * window a ready MultiplayerGameController plus the negotiated variant and
     * seat so it can start the board in multiplayer mode.
     */
    public class OnlineDialog : Adw.Dialog {
        // Default relay; override in the entry to point at a deployed server.
        public const string DEFAULT_SERVER = "ws://localhost:8443";

        private NetworkSession session;
        private MultiplayerGameController controller;

        private Adw.EntryRow server_row;
        private Adw.EntryRow name_row;
        private Adw.EntryRow code_row;
        private Adw.ComboRow variant_row;
        private Gtk.Label status_label;
        private Gtk.Button create_btn;
        private Gtk.Button join_btn;
        private Gtk.Button quick_btn;

        /** Emitted once an opponent is matched and the game can begin. */
        public signal void game_ready (MultiplayerGameController controller,
                                       string variant, int seat, int first_dealer, uint32 seed);

        public OnlineDialog (string player_name) {
            Object ();
            this.title = _("Play Online");
            this.content_width = 420;

            session = new NetworkSession (player_name);
            controller = new MultiplayerGameController (session);
            wire_session ();

            build_ui (player_name);
        }

        private void build_ui (string player_name) {
            var toolbar = new Adw.ToolbarView ();
            toolbar.add_top_bar (new Adw.HeaderBar ());

            var page = new Adw.PreferencesPage ();

            var conn_group = new Adw.PreferencesGroup ();
            conn_group.title = _("Connection");

            server_row = new Adw.EntryRow ();
            server_row.title = _("Server");
            server_row.text = DEFAULT_SERVER;
            conn_group.add (server_row);

            name_row = new Adw.EntryRow ();
            name_row.title = _("Your Name");
            name_row.text = player_name;
            conn_group.add (name_row);

            variant_row = new Adw.ComboRow ();
            variant_row.title = _("Variant");
            variant_row.model = new Gtk.StringList ({
                "Mineiro", "Paulista", "Uruguayo", "Venezolano", "Argentino"
            });
            conn_group.add (variant_row);
            page.add (conn_group);

            var play_group = new Adw.PreferencesGroup ();
            play_group.title = _("Match");

            quick_btn = new Gtk.Button.with_label (_("Quick Match"));
            quick_btn.add_css_class ("suggested-action");
            quick_btn.add_css_class ("pill");
            quick_btn.margin_top = 6;
            quick_btn.clicked.connect (on_quick_match);
            play_group.add (quick_btn);

            create_btn = new Gtk.Button.with_label (_("Create Private Room"));
            create_btn.add_css_class ("pill");
            create_btn.margin_top = 6;
            create_btn.clicked.connect (on_create_room);
            play_group.add (create_btn);

            code_row = new Adw.EntryRow ();
            code_row.title = _("Room Code");
            play_group.add (code_row);

            join_btn = new Gtk.Button.with_label (_("Join Room"));
            join_btn.add_css_class ("pill");
            join_btn.margin_top = 6;
            join_btn.clicked.connect (on_join_room);
            play_group.add (join_btn);

            page.add (play_group);

            var status_group = new Adw.PreferencesGroup ();
            status_label = new Gtk.Label (_("Not connected."));
            status_label.wrap = true;
            status_label.add_css_class ("dim-label");
            status_group.add (status_label);
            page.add (status_group);

            toolbar.content = page;
            this.child = toolbar;
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

        private void set_status (string text) {
            status_label.label = text;
        }

        private void set_busy (bool busy) {
            create_btn.sensitive = !busy;
            join_btn.sensitive = !busy;
            quick_btn.sensitive = !busy;
        }

        // --- Actions ------------------------------------------------------

        private async void ensure_connected () {
            if (session.state == SessionState.DISCONNECTED) {
                set_status (_("Connecting to %s…").printf (server_row.text));
                yield session.connect_to_server (server_row.text);
            }
        }

        private void on_quick_match () {
            set_busy (true);
            ensure_connected.begin (() => {
                session.quick_match (selected_variant ());
                set_status (_("Looking for an opponent…"));
            });
        }

        private void on_create_room () {
            set_busy (true);
            ensure_connected.begin (() => {
                session.create_room (selected_variant ());
            });
        }

        private void on_join_room () {
            if (code_row.text.strip () == "") {
                set_status (_("Enter a room code to join."));
                return;
            }
            set_busy (true);
            ensure_connected.begin (() => {
                session.join_room (code_row.text.strip ());
                set_status (_("Joining room %s…").printf (code_row.text.up ()));
            });
        }

        // --- Session signals ---------------------------------------------

        private void wire_session () {
            session.room_created.connect ((code) => {
                set_status (_("Room created. Share this code with a friend:\n%s").printf (code));
            });
            session.opponent_joined.connect ((name) => {
                set_status (_("%s joined. Starting…").printf (name));
            });
            session.game_started.connect (() => {
                set_status (_("Opponent found! Starting game…"));
                game_ready (controller, session.variant, session.seat,
                            session.first_dealer, session.deal_seed);
                this.close ();
            });
            session.session_error.connect ((code, message) => {
                set_busy (false);
                set_status (_("Error: %s").printf (message));
            });
            session.state_changed.connect ((state) => {
                if (state == SessionState.DISCONNECTED) {
                    set_busy (false);
                }
            });
        }
    }
}

namespace Truco.Network {

    public enum SessionState {
        DISCONNECTED,
        CONNECTING,
        HANDSHAKING,
        IDLE,           // connected, not in a room
        WAITING,        // created a room / queued, awaiting opponent
        IN_GAME
    }

    /**
     * High-level multiplayer session: owns a NetworkClient, performs the
     * handshake, drives room creation / joining / matchmaking, and tracks
     * which seat we hold. Game actions are sent and received here and handed
     * up to MultiplayerGameController via signals.
     */
    public class NetworkSession : Object {
        private NetworkClient client;
        private string player_name;

        public SessionState state { get; private set; default = SessionState.DISCONNECTED; }
        public string room_code { get; private set; default = ""; }
        public string variant { get; private set; default = "paulista"; }
        public int seat { get; private set; default = -1; }
        public int first_dealer { get; private set; default = 0; }
        public string opponent_name { get; private set; default = ""; }

        // Lifecycle signals consumed by the UI / controller.
        public signal void state_changed (SessionState state);
        public signal void room_created (string code);
        public signal void opponent_joined (string name);
        public signal void game_started ();
        public signal void opponent_disconnected (int grace_ms);
        public signal void opponent_reconnected ();
        public signal void opponent_left (string reason); // resign/forfeit/ended
        public signal void session_error (string code, string message);

        /** An in-game action arrived from the opponent (play_card, call_truco, ...). */
        public signal void action_received (NetworkMessage message);

        public NetworkSession (string player_name) {
            this.player_name = player_name;
            this.client = new NetworkClient ();
            client.opened.connect (on_opened);
            client.closed.connect (on_closed);
            client.transport_error.connect ((m) => session_error ("transport", m));
            client.message_received.connect (on_message);
        }

        private void set_state (SessionState s) {
            if (state == s) {
                return;
            }
            state = s;
            state_changed (s);
        }

        public async void connect_to_server (string url) {
            set_state (SessionState.CONNECTING);
            yield client.connect_to (url);
        }

        public void disconnect () {
            client.disconnect_from_server ();
            set_state (SessionState.DISCONNECTED);
        }

        private void on_opened () {
            set_state (SessionState.HANDSHAKING);
            var hello = new NetworkMessage ("hello");
            hello.set_string ("version", PROTOCOL_VERSION);
            hello.set_string ("name", player_name);
            client.send (hello);
        }

        private void on_closed (string reason) {
            set_state (SessionState.DISCONNECTED);
        }

        // --- Intent API (called by UI) ----------------------------------

        public void create_room (string variant) {
            this.variant = variant;
            var m = new NetworkMessage ("create_room");
            m.set_string ("variant", variant);
            client.send (m);
        }

        public void join_room (string code) {
            var m = new NetworkMessage ("join_room");
            m.set_string ("roomCode", code.up ());
            client.send (m);
        }

        public void quick_match (string variant) {
            this.variant = variant;
            var m = new NetworkMessage ("quick_match");
            m.set_string ("variant", variant);
            client.send (m);
            set_state (SessionState.WAITING);
        }

        public void cancel_quick_match () {
            client.send (new NetworkMessage ("cancel_quick_match"));
            set_state (SessionState.IDLE);
        }

        public void resign () {
            client.send (new NetworkMessage ("resign"));
        }

        public void report_game_ended (string result) {
            var m = new NetworkMessage ("game_ended");
            m.set_string ("result", result);
            client.send (m);
        }

        /** Send an in-game action to the opponent (the server relays it). */
        public void send_action (NetworkMessage action) {
            client.send (action);
        }

        // --- Server message routing --------------------------------------

        private void on_message (NetworkMessage m) {
            switch (m.message_type) {
                case "connected":
                    // handshake is sent on_opened; nothing to do here
                    break;
                case "hello_ok":
                    set_state (SessionState.IDLE);
                    break;
                case "room_created":
                    room_code = m.get_string ("roomCode");
                    set_state (SessionState.WAITING);
                    room_created (room_code);
                    break;
                case "opponent_joined":
                    opponent_name = m.get_string ("opponentName", "Opponent");
                    opponent_joined (opponent_name);
                    break;
                case "queued":
                    set_state (SessionState.WAITING);
                    break;
                case "game_started":
                    room_code = m.get_string ("roomCode", room_code);
                    variant = m.get_string ("variant", variant);
                    seat = m.get_int ("seat", seat);
                    first_dealer = m.get_int ("firstDealer", 0);
                    opponent_name = m.get_string ("opponentName", opponent_name);
                    set_state (SessionState.IN_GAME);
                    game_started ();
                    break;
                case "opponent_disconnected":
                    opponent_disconnected (m.get_int ("graceMs", 60000));
                    break;
                case "opponent_reconnected":
                    opponent_reconnected ();
                    break;
                case "opponent_resigned":
                    opponent_left ("resign");
                    break;
                case "opponent_forfeited":
                    opponent_left ("forfeit");
                    break;
                case "game_ended":
                    opponent_left ("ended");
                    break;
                case "room_expired":
                    session_error ("room_expired", _("The room expired due to inactivity."));
                    set_state (SessionState.IDLE);
                    break;
                case "pong":
                    break;
                case "error":
                    session_error (m.get_string ("code", "error"), m.get_string ("message"));
                    break;
                default:
                    // Everything else is an in-game action relayed from the opponent.
                    action_received (m);
                    break;
            }
        }
    }
}

namespace Truco.Network {

    public enum SessionState {
        DISCONNECTED,
        CONNECTING,
        HANDSHAKING,
        IDLE,
        WAITING,
        IN_GAME
    }

    public class NetworkSession : Object {
        private NetworkClient client;
        private string player_name;

        public SessionState state { get; private set; default = SessionState.DISCONNECTED; }
        public string room_code { get; private set; default = ""; }
        public string variant { get; private set; default = "paulista"; }
        public int seat { get; private set; default = -1; }
        public int first_dealer { get; private set; default = 0; }
        public uint32 deal_seed { get; private set; default = 0; }
        public string opponent_name { get; private set; default = ""; }

        public signal void state_changed (SessionState state);
        public signal void room_created (string code);
        public signal void opponent_joined (string name);
        public signal void searching ();
        public signal void match_found ();
        public signal void quick_match_cancelled ();
        public signal void game_started ();
        public signal void opponent_disconnected (int grace_ms);
        public signal void opponent_reconnected ();
        public signal void opponent_left (string reason);
        public signal void session_error (string code, string message);

        public signal void action_received (NetworkMessage message);

        public NetworkSession (string player_name) {
            this.player_name = player_name;
            this.client = new NetworkClient ();
            client.opened.connect (on_opened);
            client.closed.connect (on_closed);
            client.transport_error.connect ((m) => session_error ("transport", m));
            client.message_received.connect (on_message);
        }

        private void transition_to (SessionState s) {
            if (state == s) {
                return;
            }
            state = s;
            state_changed (s);
        }

        public async void connect_to_server (string url) {
            transition_to (SessionState.CONNECTING);
            yield client.connect_to (url);
        }

        public void disconnect () {
            client.disconnect_from_server ();
            transition_to (SessionState.DISCONNECTED);
        }

        private void on_opened () {
            transition_to (SessionState.HANDSHAKING);
            var hello = new NetworkMessage ("hello");
            hello.set_string ("version", PROTOCOL_VERSION);
            hello.set_string ("name", player_name);
            client.send (hello);
        }

        private void on_closed (string reason) {
            transition_to (SessionState.DISCONNECTED);
        }

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
            transition_to (SessionState.WAITING);
        }

        public void cancel_quick_match () {
            client.send (new NetworkMessage ("cancel_quick_match"));
            transition_to (SessionState.IDLE);
        }

        public void resign () {
            client.send (new NetworkMessage ("resign"));
        }

        public void report_game_ended (string result) {
            var m = new NetworkMessage ("game_ended");
            m.set_string ("result", result);
            client.send (m);
        }

        public void send_action (NetworkMessage action) {
            client.send (action);
        }

        private void on_message (NetworkMessage m) {
            switch (m.message_type) {
                case "connected":

                    break;
                case "hello_ok":
                    transition_to (SessionState.IDLE);
                    break;
                case "room_created":
                    room_code = m.get_string ("roomCode");
                    transition_to (SessionState.WAITING);
                    room_created (room_code);
                    break;
                case "opponent_joined":
                    opponent_name = m.get_string ("opponentName", "Opponent");
                    opponent_joined (opponent_name);
                    break;
                case "queued":
                    transition_to (SessionState.WAITING);
                    searching ();
                    break;
                case "quick_match_found":
                    match_found ();
                    break;
                case "quick_match_cancelled":
                    transition_to (SessionState.IDLE);
                    quick_match_cancelled ();
                    break;
                case "game_started":
                    room_code = m.get_string ("roomCode", room_code);
                    variant = m.get_string ("variant", variant);
                    seat = m.get_int ("seat", seat);
                    first_dealer = m.get_int ("firstDealer", 0);
                    deal_seed = (uint32) m.get_int ("seed", 0);
                    opponent_name = m.get_string ("opponentName", opponent_name);
                    transition_to (SessionState.IN_GAME);
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
                    transition_to (SessionState.IDLE);
                    break;
                case "pong":
                    break;
                case "error":
                    session_error (m.get_string ("code", "error"), m.get_string ("message"));
                    break;
                default:

                    action_received (m);
                    break;
            }
        }
    }
}

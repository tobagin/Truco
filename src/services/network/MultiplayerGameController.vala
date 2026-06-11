namespace Truco.Network {

    /**
     * Bridges a NetworkSession to the local game UI.
     *
     * Outbound: the UI calls the local_* methods when the human acts; the
     * controller serializes the action and sends it through the session.
     *
     * Inbound: opponent actions arrive on the session's `action_received`
     * signal; the controller decodes them and emits high-level signals that
     * Window connects to the local GameState (applying the move as if a
     * remote player had taken their turn).
     *
     * The Truco rules engine remains authoritative on each client; this layer
     * only carries intent between the two peers, matching the relay model of
     * the server.
     */
    public class MultiplayerGameController : Object {
        public NetworkSession session { get; private set; }

        /** Our seat (0 or 1); the opponent holds the other. */
        public int local_seat { get { return session.seat; } }

        // High-level inbound signals (opponent's actions).
        public signal void opponent_played_card (Suit suit, int value);
        public signal void opponent_called_truco (int level);     // 3/6/9/12
        public signal void opponent_responded_truco (string response); // accept/raise/run
        public signal void opponent_called_bet (string bet);      // envido/flor/...
        public signal void opponent_responded_bet (string response);
        public signal void opponent_mao_de_11_decision (bool accepted);
        public signal void opponent_signalled (string signal_text);
        public signal void opponent_chat (string text);

        public MultiplayerGameController (NetworkSession session) {
            this.session = session;
            session.action_received.connect (on_action);
        }

        // --- Outbound (local player acted) -------------------------------

        public void local_play_card (Card card) {
            var m = new NetworkMessage ("play_card");
            m.set_int ("suit", (int) card.suit);
            m.set_int ("value", card.value);
            session.send_action (m);
        }

        public void local_call_truco (int level) {
            var m = new NetworkMessage ("call_truco");
            m.set_int ("level", level);
            session.send_action (m);
        }

        public void local_respond_truco (string response) {
            var m = new NetworkMessage ("respond_truco");
            m.set_string ("response", response);
            session.send_action (m);
        }

        public void local_run () {
            session.send_action (new NetworkMessage ("run"));
        }

        public void local_call_bet (string bet) {
            var m = new NetworkMessage ("call_envido");
            m.set_string ("bet", bet);
            session.send_action (m);
        }

        public void local_respond_bet (string response) {
            var m = new NetworkMessage ("respond_bet");
            m.set_string ("response", response);
            session.send_action (m);
        }

        public void local_mao_de_11_decision (bool accepted) {
            var m = new NetworkMessage ("mao_de_11_decision");
            m.set_bool ("accepted", accepted);
            session.send_action (m);
        }

        public void local_signal (string signal_text) {
            var m = new NetworkMessage ("signal");
            m.set_string ("text", signal_text);
            session.send_action (m);
        }

        public void local_chat (string text) {
            var m = new NetworkMessage ("chat");
            m.set_string ("text", text);
            session.send_action (m);
        }

        // --- Inbound (decode opponent action) ----------------------------

        private void on_action (NetworkMessage m) {
            switch (m.message_type) {
                case "play_card":
                    opponent_played_card ((Suit) m.get_int ("suit"), m.get_int ("value"));
                    break;
                case "call_truco":
                    opponent_called_truco (m.get_int ("level", 3));
                    break;
                case "respond_truco":
                    opponent_responded_truco (m.get_string ("response"));
                    break;
                case "run":
                    opponent_responded_truco ("run");
                    break;
                case "call_envido":
                case "call_flor":
                    opponent_called_bet (m.get_string ("bet", m.message_type));
                    break;
                case "respond_bet":
                    opponent_responded_bet (m.get_string ("response"));
                    break;
                case "mao_de_11_decision":
                    opponent_mao_de_11_decision (m.get_bool ("accepted"));
                    break;
                case "signal":
                    opponent_signalled (m.get_string ("text"));
                    break;
                case "chat":
                    opponent_chat (m.get_string ("text"));
                    break;
                default:
                    warning ("Unhandled multiplayer action: %s", m.message_type);
                    break;
            }
        }
    }
}

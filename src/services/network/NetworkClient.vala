namespace Truco.Network {

    /**
     * Low-level WebSocket transport to the Truco relay server.
     *
     * Responsibilities: open/close the connection, send/receive raw
     * NetworkMessages, and emit lifecycle signals. It knows nothing about
     * rooms or game rules — that lives in NetworkSession.
     *
     * Uses libsoup-3.0's WebSocket support.
     */
    public class NetworkClient : Object {
        private Soup.Session session;
        private Soup.WebsocketConnection? connection = null;

        public bool connected { get; private set; default = false; }

        /** A decoded message arrived from the server. */
        public signal void message_received (NetworkMessage message);
        /** The transport opened successfully. */
        public signal void opened ();
        /** The transport closed (cleanly or otherwise). */
        public signal void closed (string reason);
        /** A transport-level error occurred. */
        public signal void transport_error (string message);

        public NetworkClient () {
            session = new Soup.Session ();
        }

        /**
         * Connect to a relay. Accepts ws:// or wss:// URLs.
         */
        public async void connect_to (string url) {
            if (connected) {
                return;
            }
            var message = new Soup.Message ("GET", url);
            if (message == null) {
                transport_error ("Invalid server URL: %s".printf (url));
                return;
            }
            try {
                connection = yield session.websocket_connect_async (
                    message, null, null, GLib.Priority.DEFAULT, null);
                connection.max_incoming_payload_size = 1 << 20; // 1 MiB
                connection.message.connect (on_message);
                connection.closed.connect (() => {
                    connected = false;
                    closed ("connection closed");
                });
                connection.error.connect ((err) => {
                    transport_error (err.message);
                });
                connected = true;
                opened ();
            } catch (Error e) {
                transport_error (e.message);
            }
        }

        private void on_message (int type, Bytes bytes) {
            if (type != Soup.WebsocketDataType.TEXT) {
                return;
            }
            var raw = (string) bytes.get_data ();
            var msg = NetworkMessage.parse (raw);
            if (msg != null) {
                message_received (msg);
            } else {
                warning ("Discarded malformed server message");
            }
        }

        public void send (NetworkMessage message) {
            if (connection == null || !connected) {
                warning ("Tried to send while disconnected: %s", message.message_type);
                return;
            }
            connection.send_text (message.to_wire ());
        }

        public void disconnect_from_server () {
            if (connection != null && connected) {
                connection.close (Soup.WebsocketCloseCode.NORMAL, null);
            }
            connected = false;
        }
    }
}

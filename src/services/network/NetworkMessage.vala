using Gee;

namespace Truco.Network {

    /**
     * Protocol version negotiated with the relay server. Must match the
     * server's REQUIRED_VERSION (see server/README.md).
     */
    public const string PROTOCOL_VERSION = "1.0.0";

    /**
     * A single JSON message exchanged with the relay server. Every message has
     * a string "type" and a "timestamp"; everything else is type-specific and
     * accessed through the typed getters below.
     *
     * This wraps Json-GLib so the rest of the client never touches raw JSON.
     */
    public class NetworkMessage : Object {
        public string message_type { get; private set; }
        private Json.Object root;

        public NetworkMessage (string type) {
            this.message_type = type;
            this.root = new Json.Object ();
            this.root.set_string_member ("type", type);
            this.root.set_int_member ("timestamp", GLib.get_real_time () / 1000);
        }

        private NetworkMessage.from_object (Json.Object obj) {
            this.root = obj;
            this.message_type = obj.has_member ("type")
                ? obj.get_string_member ("type") : "";
        }

        /** Parse an incoming wire string. Returns null on malformed input. */
        public static NetworkMessage? parse (string raw) {
            try {
                var parser = new Json.Parser ();
                parser.load_from_data (raw, -1);
                var node = parser.get_root ();
                if (node == null || node.get_node_type () != Json.NodeType.OBJECT) {
                    return null;
                }
                var obj = node.get_object ();
                if (!obj.has_member ("type")) {
                    return null;
                }
                return new NetworkMessage.from_object (obj);
            } catch (Error e) {
                warning ("Failed to parse network message: %s", e.message);
                return null;
            }
        }

        // --- Builders (fluent) -------------------------------------------

        public NetworkMessage set_string (string key, string value) {
            root.set_string_member (key, value);
            return this;
        }

        public NetworkMessage set_int (string key, int64 value) {
            root.set_int_member (key, value);
            return this;
        }

        public NetworkMessage set_bool (string key, bool value) {
            root.set_boolean_member (key, value);
            return this;
        }

        public NetworkMessage set_object (string key, Json.Object obj) {
            root.set_object_member (key, obj);
            return this;
        }

        // --- Accessors ----------------------------------------------------

        public bool has (string key) {
            return root.has_member (key);
        }

        public string get_string (string key, string fallback = "") {
            return root.has_member (key) && root.get_member (key).get_node_type () == Json.NodeType.VALUE
                ? root.get_string_member (key) : fallback;
        }

        public int get_int (string key, int fallback = 0) {
            return root.has_member (key) && root.get_member (key).get_node_type () == Json.NodeType.VALUE
                ? (int) root.get_int_member (key) : fallback;
        }

        public bool get_bool (string key, bool fallback = false) {
            return root.has_member (key) && root.get_member (key).get_node_type () == Json.NodeType.VALUE
                ? root.get_boolean_member (key) : fallback;
        }

        public Json.Object? get_object (string key) {
            return root.has_member (key) && root.get_member (key).get_node_type () == Json.NodeType.OBJECT
                ? root.get_object_member (key) : null;
        }

        // --- Serialization ------------------------------------------------

        public string to_wire () {
            var gen = new Json.Generator ();
            var node = new Json.Node (Json.NodeType.OBJECT);
            node.set_object (root);
            gen.set_root (node);
            return gen.to_data (null);
        }
    }
}

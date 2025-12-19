using Gst;
using Gee;

namespace Truco {
    public class SoundManager : GLib.Object {
        private static SoundManager? instance = null;
        private Gee.LinkedList<Gst.Element> active_players;
        private bool initialized = false;

        public static SoundManager get_default() {
            if (instance == null) {
                instance = new SoundManager();
            }
            return instance;
        }

        private SoundManager() {
            active_players = new Gee.LinkedList<Gst.Element>();
            try {
                // Initialize GStreamer
                string[] args = null;
                unowned string[] tmp_args = args;
                Gst.init(ref tmp_args);
                initialized = true;
            } catch (Error e) {
                warning("Failed to init GStreamer: %s", e.message);
            }
        }

        public void play(string sound_name) {
            if (!initialized) {
                warning("SoundManager not initialized, skipping sound: %s", sound_name);
                return;
            }
            
            var settings = new GLib.Settings(Config.SCHEMA_ID);
            if (!settings.get_boolean("sound-enabled")) return;

            string uri = "resource:///io/github/tobagin/Truco/sounds/" + sound_name + ".ogg";
            // debug("Playing sound: %s", uri);
            
            var player = Gst.ElementFactory.make("playbin", null);
            if (player == null) {
                warning("Failed to create playbin element. Install gstreamer-plugins-base.");
                return;
            }
            
            player.set("uri", uri);
            
            // Keep reference to prevent premature destruction
            active_players.add(player);
            
            var bus = player.get_bus();
            bus.add_watch(GLib.Priority.DEFAULT, (bus, msg) => {
                switch (msg.type) {
                    case Gst.MessageType.EOS:
                        // Cleanup
                        player.set_state(Gst.State.NULL);
                        active_players.remove(player);
                        return false; 
                    case Gst.MessageType.ERROR:
                        GLib.Error err;
                        string debug_info;
                        msg.parse_error(out err, out debug_info);
                        warning("Error playing sound '%s': %s", sound_name, err.message);
                        player.set_state(Gst.State.NULL);
                        active_players.remove(player);
                        return false; 
                    default:
                        return true;
                }
            });

            player.set_state(Gst.State.PLAYING);
        }
    }
}

using Gst;

namespace Truco {
    public class SoundManager : GLib.Object {
        private static SoundManager? instance = null;
        private bool initialized = false;

        public static SoundManager get_default() {
            if (instance == null) {
                instance = new SoundManager();
            }
            return instance;
        }

        private SoundManager() {
            try {

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

            var player = Gst.ElementFactory.make("playbin", null);
            if (player == null) {
                warning("Failed to create playbin element. Install gstreamer-plugins-base.");
                return;
            }

            player.set("uri", uri);

            // The watch closure below holds the only reference that keeps `player`
            // alive during playback; it drops when we return false at EOS/ERROR.
            var bus = player.get_bus();
            bus.add_watch(GLib.Priority.DEFAULT, (bus, msg) => {
                switch (msg.type) {
                    case Gst.MessageType.EOS:

                        player.set_state(Gst.State.NULL);
                        return false;
                    case Gst.MessageType.ERROR:
                        GLib.Error err;
                        string debug_info;
                        msg.parse_error(out err, out debug_info);
                        warning("Error playing sound '%s': %s", sound_name, err.message);
                        player.set_state(Gst.State.NULL);
                        return false;
                    default:
                        return true;
                }
            });

            player.set_state(Gst.State.PLAYING);
        }
    }
}

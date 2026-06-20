public class Truco.AboutDialog : GLib.Object {

    public static void show(Gtk.Window? parent) {
        var developers = new string[] { "Thiago Fernandes", null };
        var designers = new string[] { "Thiago Fernandes", null };
        var artists = new string[] { "Thiago Fernandes", null };

        string comments = "A traditional card game from Brazil";
        if (Config.APP_ID.contains("Devel")) {
            comments += " (Dev Version)";
        }

        var about = new Adw.AboutDialog() {
            application_name = Config.NAME,
            application_icon = Config.APP_ID,
            developer_name = "Thiago Fernandes",
            version = Config.VERSION,
            developers = developers,
            designers = designers,
            artists = artists,
            license_type = Gtk.License.GPL_3_0,
            website = "https://github.com/tobagin/Truco",
            issue_url = "https://github.com/tobagin/Truco/issues",
            support_url = "https://github.com/tobagin/Truco/discussions",
            comments = comments
        };

        load_release_notes(about);

        about.set_copyright("© 2025 Thiago Fernandes");

        var acknowledgements = new string[] {
            "The GNOME Project",
            "LibAdwaita Contributors",
            "Vala Programming Language Team",
            null
        };
        about.add_acknowledgement_section("Special Thanks", acknowledgements);

        var card_art = new string[] {
            "Spanish deck by Basquetteur (Wikimedia Commons) — CC BY-SA 3.0",
            "French deck — English pattern (Wikimedia Commons) — CC0 / Public Domain",
            "Avatars by Iryna Korshak",
            null
        };
        about.add_acknowledgement_section("Artwork", card_art);

        about.set_translator_credits("Thiago Fernandes");

        about.add_link("Source", "https://github.com/tobagin/Truco");
        about.add_link("Spanish Cards (CC BY-SA 3.0)", "https://commons.wikimedia.org/wiki/File:Baraja_espa%C3%B1ola_completa.png");
        about.add_link("Avatars by Iryna Korshak", "https://dribbble.com/irynakorshak");

        if (parent != null && !parent.in_destruction()) {
            about.present(parent);
        }
    }

    private static void load_release_notes(Adw.AboutDialog about) {
        try {
            string[] possible_paths = {
                Path.build_filename("/app/share/metainfo", @"$(Config.APP_ID).metainfo.xml"),
                Path.build_filename("/usr/share/metainfo", @"$(Config.APP_ID).metainfo.xml"),
                Path.build_filename(Environment.get_user_data_dir(), "metainfo", @"$(Config.APP_ID).metainfo.xml")
            };

            foreach (string metainfo_path in possible_paths) {
                var file = File.new_for_path(metainfo_path);

                if (file.query_exists()) {
                    uint8[] contents;
                    string etag_out;
                    file.load_contents(null, out contents, out etag_out);
                    string xml_content = (string) contents;

                    var parser = new Regex("<release version=\"%s\"[^>]*>(.*?)</release>".printf(Regex.escape_string(Config.VERSION)),
                                           RegexCompileFlags.DOTALL | RegexCompileFlags.MULTILINE);
                    MatchInfo match_info;

                    if (parser.match(xml_content, 0, out match_info)) {
                        string release_section = match_info.fetch(1);

                        var desc_parser = new Regex("<description>(.*?)</description>",
                                                    RegexCompileFlags.DOTALL | RegexCompileFlags.MULTILINE);
                        MatchInfo desc_match;

                        if (desc_parser.match(release_section, 0, out desc_match)) {
                            string release_notes = desc_match.fetch(1).strip();
                            about.set_release_notes(release_notes);
                            about.set_release_notes_version(Config.VERSION);
                        }
                    }
                    break;
                }
            }
        } catch (Error e) {

            warning("Could not load release notes from metainfo: %s", e.message);
        }
    }

}

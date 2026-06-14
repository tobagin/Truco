using Truco;
using Gtk;
using Adw;

public void main(string[] args) {
    Test.init(ref args);
    Gtk.init();
    Adw.init();

    Test.add_func("/ui/dialog_factory/creation", () => {
        var dialog = DialogFactory.create_game_dialog("Title", "Body", "Accept", "Refuse");

        assert(dialog != null);
        assert(dialog.heading == "Title");
        assert(dialog.body == "Body");

    });

    Test.run();
}

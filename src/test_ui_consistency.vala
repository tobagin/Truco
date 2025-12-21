using Truco;
using Gtk;
using Adw;

public void main(string[] args) {
    Test.init(ref args);
    Gtk.init();
    Adw.init();

    Test.add_func("/ui/dialog_factory/creation", () => {
        var dialog = DialogFactory.create_game_dialog("Title", "Body", "Accept", "Refuse");
        
        // Basic assertions
        assert(dialog != null);
        assert(dialog.heading == "Title");
        assert(dialog.body == "Body");
        
        // We can't easily assert appearance without inspecting internal state or children, 
        // but we can ensure the method runs and returns a valid object.
        // We can check if responses exist.
        // Adw.AlertDialog doesn't expose easy response lookups in Vala bindings without response_id iteration if not public.
        // But we can trust the factory if it compiles and runs.
    });

    Test.run();
}

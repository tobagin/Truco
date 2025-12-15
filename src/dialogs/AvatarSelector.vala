using Gtk;
using Adw;

namespace Truco {

    [GtkTemplate (ui = "/io/github/tobagin/Truco/avatar_selector.ui")]
    public class AvatarSelector : Adw.Window {
        
        [GtkChild]
        private unowned FlowBox flowbox;
        
        public int selected_index { get; private set; default = -1; }
        
        public signal void avatar_selected(int index);
        
        public AvatarSelector(Window? parent) {
            Object(transient_for: parent);
            
            populate();
        }
        
        private void populate() {
            for (int i = 1; i <= 58; i++) {
                var btn = new Button();
                btn.add_css_class("flat");
                
                var avatar = new Adw.Avatar(96, "", false);
                
                var paintable = Gdk.Texture.from_resource(Config.RESOURCE_PATH + "/avatars/avatar%d.svg".printf(i));
                avatar.set_custom_image(paintable);
                
                btn.set_child(avatar);
                
                int capture_idx = i - 1; // 0-based index
                btn.clicked.connect(() => {
                    selected_index = capture_idx;
                    avatar_selected(selected_index);
                    this.close();
                });
                
                flowbox.append(btn);
            }
        }
    }
}

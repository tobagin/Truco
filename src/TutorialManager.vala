using Gtk;
using Adw;
using Gee;

namespace Truco {

    public class TutorialStep : Object {
        public string title { get; set; }
        public string instruction { get; set; }
        public string? highlight_widget_id { get; set; }

        public TutorialStep(string title, string instruction, string? widget_id = null) {
            this.title = title;
            this.instruction = instruction;
            this.highlight_widget_id = widget_id;
        }
    }

    public class TutorialManager : Object {
        private ArrayList<TutorialStep> steps;
        private int current_step_index = -1;
        private Window window;

        public TutorialManager(Window window) {
            this.window = window;
            this.steps = new ArrayList<TutorialStep>();
            setup_steps();
        }

        private void setup_steps() {
            steps.add(new TutorialStep(_("Welcome to Truco!"), _("Truco is a popular South American card game. Let's learn the basics.")));
            steps.add(new TutorialStep(_("You are here"), _("This is your avatar. Your cards will appear below it."), "avatar_user"));
            steps.add(new TutorialStep(_("The Deck"), _("Truco uses a 40-card Spanish deck (or similar). No 8s, 9s, or jokers.")));
            steps.add(new TutorialStep(_("Hierarchy"), _("Cards have a special hierarchy. 1 of swords is the strongest card (usually).")));
            steps.add(new TutorialStep(_("The Vira (Turn Card)"), _("This is the Vira. It can determine which cards are special 'Manilhas' for this round."), "vira_box"));
            steps.add(new TutorialStep(_("Scoring"), _("Check the score board to track matches and games. First to 12 points wins!"), "score_box"));
            steps.add(new TutorialStep(_("Betting"), _("Use this button to call 'Truco' and raise the stakes of the round."), "btn_truco"));
            steps.add(new TutorialStep(_("Hints"), _("If you are unsure, click the 'Hint' button for advice."), "btn_hint"));
            steps.add(new TutorialStep(_("Have fun!"), _("You are ready to play. Good luck!")));
        }

        public void start() {
            current_step_index = 0;
            show_current_step();
        }

        public void next() {
            if (current_step_index < steps.size - 1) {
                current_step_index++;
                show_current_step();
            } else {
                finish();
            }
        }

        public bool is_active() {
            return current_step_index >= 0;
        }

        private void show_current_step() {
            var step = steps[current_step_index];
            window.show_tutorial_step(step.title, step.instruction, step.highlight_widget_id);
        }

        public void finish() {
            current_step_index = -1;
            window.hide_tutorial();
        }
    }
}

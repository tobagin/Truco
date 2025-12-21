# Track Plan: UI Consistency for Game Dialogs

## Phase 1: Foundation & Base Dialog Refactoring
- [x] Task: Create a base utility or extension method for `Adw.AlertDialog` to enforce uniform styling (Suggested for Accept, Destructive for Refuse). (8af4922)
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Foundation & Base Dialog Refactoring' (Protocol in workflow.md)

## Phase 2: Dialog Implementation & Standardization
- [ ] Task: Refactor `show_raise_dialog` in `Window.vala` to strictly use the new base styling and ensure responsive button layout.
- [ ] Task: Refactor `show_envido_dialog` in `Window.vala` to use the same `Adw.AlertDialog` implementation.
- [ ] Task: Refactor `show_mao_11_dialog` in `Window.vala` to align with the new standard.
- [ ] Task: Update `MatchEndDialog.vala` (or its invocation) to ensure visual consistency with gameplay dialogs.
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Dialog Implementation & Standardization' (Protocol in workflow.md)

## Phase 3: Validation & Mobile Testing
- [ ] Task: Verify dialog responsiveness by testing with narrow window widths (stacked buttons).
- [ ] Task: Verify dialog styling across all game modes (Argentino, Paulista, etc.) to ensure variant-specific labels are correct.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Validation & Mobile Testing' (Protocol in workflow.md)

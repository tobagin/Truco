# Track Plan: UI Consistency for Game Dialogs

## Phase 1: Foundation & Base Dialog Refactoring [checkpoint: 77c3c95]
- [x] Task: Create a base utility or extension method for `Adw.AlertDialog` to enforce uniform styling (Suggested for Accept, Destructive for Refuse). (8af4922)
- [x] Task: Conductor - User Manual Verification 'Phase 1: Foundation & Base Dialog Refactoring' (Protocol in workflow.md) (77c3c95)

## Phase 2: Dialog Implementation & Standardization [checkpoint: 4ebc7fe]
- [x] Task: Refactor `show_raise_dialog` in `Window.vala` to strictly use the new base styling and ensure responsive button layout. (7bcd078)
- [x] Task: Refactor `show_envido_dialog` in `Window.vala` to use the same `Adw.AlertDialog` implementation. (45436fc)
- [x] Task: Refactor `show_mao_11_dialog` in `Window.vala` to align with the new standard. (af4d21c)
- [x] Task: Update `MatchEndDialog.vala` (or its invocation) to ensure visual consistency with gameplay dialogs. (3d38de6)
- [x] Task: Conductor - User Manual Verification 'Phase 2: Dialog Implementation & Standardization' (Protocol in workflow.md) (4ebc7fe)

## Phase 3: Validation & Mobile Testing
- [ ] Task: Verify dialog responsiveness by testing with narrow window widths (stacked buttons).
- [ ] Task: Verify dialog styling across all game modes (Argentino, Paulista, etc.) to ensure variant-specific labels are correct.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: Validation & Mobile Testing' (Protocol in workflow.md)

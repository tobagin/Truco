# Track Plan: Truco Paulista Completion

## Phase 1: Core Rules Polish
- [ ] Task: Update `Game.vala` and `RulesEngine.vala` to explicitly prevent Flor calls in Paulista mode.
- [ ] Task: Update AI turn logic in `Game.vala` to ignore Flor for Paulista.
- [ ] Task: Create `test_paulista_rules.vala` to verify variable Manilha rotation and Flor exclusion.
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Core Rules Polish' (Protocol in workflow.md)

## Phase 2: Mão de Ferro (Blind Play)
- [ ] Task: Implement `is_blind_round` flag in `GameState` for 11x11 state.
- [ ] Task: Update `Window.vala` card rendering to show card backs if `is_blind_round` is true for the human player.
- [ ] Task: Ensure Truco is disabled during Mão de Ferro in `raise_stake`.
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Mão de Ferro (Blind Play)' (Protocol in workflow.md)

## Phase 3: UI Feedback & Testing
- [ ] Task: Add "Mão de Ferro - Playing Blind" status indicator in the UI.
- [ ] Task: Verify betting progression labels (3, 6, 9, 12) specifically for Paulista in the `btn_truco` logic.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: UI Feedback & Testing' (Protocol in workflow.md)

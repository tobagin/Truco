# Track Plan: Truco Mineiro Completion

## Phase 1: Core Rules & Logic
- [x] Task: Disable "Flor" mechanism in `RulesEngine` and `Game.vala` when playing `mineiro` or `paulista` variants. (61d6df8)
- [ ] Task: Create `test_mineiro_rules.vala` to verify Flor is disabled and fixed Manilhas (Zap) are correctly identified.
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Core Rules & Logic' (Protocol in workflow.md)

## Phase 2: Mão de Ferro (Iron Hand)
- [ ] Task: Implement "Blind Play" state in `GameState` when score is 11-11 (Mão de Ferro).
- [ ] Task: Update `Window.vala` to render player cards face-down during Mão de Ferro.
- [ ] Task: Modify `Game.vala` to automate the turn progression (no Truco calls allowed) during Mão de Ferro.
- [ ] Task: Conductor - User Manual Verification 'Phase 2: Mão de Ferro (Iron Hand)' (Protocol in workflow.md)

## Phase 3: UI Polish & AI
- [ ] Task: Update `Game.vala` signal logic to use "Zap" and other Mineiro-specific terms in history/logs.
- [ ] Task: Refine AI in `Game.vala` to play aggressively when holding the Zap (4 of Clubs) in Mineiro mode.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: UI Polish & AI' (Protocol in workflow.md)

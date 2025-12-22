# Track Plan: Truco Mineiro Completion

## Phase 1: Core Rules & Logic [checkpoint: 2ccb7c0]
- [x] Task: Disable "Flor" mechanism in `RulesEngine` and `Game.vala` when playing `mineiro` or `paulista` variants. (61d6df8)
- [x] Task: Create `test_mineiro_rules.vala` to verify Flor is disabled and fixed Manilhas (Zap) are correctly identified. (b368dfe)
- [x] Task: Conductor - User Manual Verification 'Phase 1: Core Rules & Logic' (Protocol in workflow.md) (2ccb7c0)

## Phase 2: Mão de Ferro (Iron Hand) [checkpoint: d449cc4]
- [x] Task: Implement "Blind Play" state in `GameState` when score is 11-11 (Mão de Ferro). (2ccb7c0)
- [x] Task: Update `Window.vala` to render player cards face-down during Mão de Ferro. (d2c4816)
- [x] Task: Modify `Game.vala` to automate the turn progression (no Truco calls allowed) during Mão de Ferro. (d2c4816)
- [x] Task: Conductor - User Manual Verification 'Phase 2: Mão de Ferro (Iron Hand)' (Protocol in workflow.md) (d449cc4)

## Phase 3: UI Polish & AI [checkpoint: 115f4de]
- [x] Task: Update `Game.vala` signal logic to use "Zap" and other Mineiro-specific terms in history/logs. (61d6df8)
- [x] Task: Refine AI in `Game.vala` to play aggressively when holding the Zap (4 of Clubs) in Mineiro mode. (c04780a)
- [x] Task: Conductor - User Manual Verification 'Phase 3: UI Polish & AI' (Protocol in workflow.md) (115f4de)

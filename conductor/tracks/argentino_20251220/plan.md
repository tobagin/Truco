# Track Plan: Truco Argentino Logic & Scoring

## Phase 1: Core Logic Implementation
- [ ] Task: Create or Refine `RulesEngine` class to encapsulate Truco Argentino card hierarchy and point values.
- [ ] Task: Implement `ScoreManager` logic for 30-point game structure (15 Malas / 15 Buenas).
- [ ] Task: Implement `Envido` calculation logic (20 + sum of same-suit cards).
- [ ] Task: Implement basic `Flor` detection logic (3 cards of same suit).
- [ ] Task: Conductor - User Manual Verification 'Phase 1: Core Logic Implementation' (Protocol in workflow.md)

## Phase 2: AI & Gameplay Integration
- [ ] Task: Update AI decision making to use the new `RulesEngine` for card throwing value.
- [ ] Task: Integrate `Envido` calling logic into the AI's turn evaluation.
- [ ] Task: Integrate `Truco/Retruco` response logic into the AI.
- [ ] Task: Conductor - User Manual Verification 'Phase 2: AI & Gameplay Integration' (Protocol in workflow.md)

## Phase 3: UI & Validation
- [ ] Task: Update the Scoreboard UI to display "Malas" and "Buenas" indicators.
- [ ] Task: Create a comprehensive test suite (unit tests) for the `RulesEngine` to verify hierarchy and point calculations.
- [ ] Task: Playtest a full game loop to 30 points to verify state transitions.
- [ ] Task: Conductor - User Manual Verification 'Phase 3: UI & Validation' (Protocol in workflow.md)

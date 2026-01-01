# Track Specification: Truco Paulista Completion

## Overview
Polish and finalize the "Truco Paulista" game variant to ensure it strictly follows standard rules and offers a complete experience. This involves mirroring the refinements planned for "Truco Mineiro" (disabling Flor, implementing Blind Play for Mão de Ferro) while maintaining the unique "Variable Manilha" rule that defines Paulista.

## Functional Requirements
1.  **Rule Enforcement:**
    *   **Disable Flor:** Explicitly disable "Flor" calls for the `paulista` game mode in both the UI (button visibility) and AI logic.
    *   **Variable Manilhas:** Verify and preserve the logic where Manilhas are determined by the "Vira" card (Card value + 1, looping 12->1, 7->10).
2.  **Mão de Ferro (Iron Hand):**
    *   **Trigger:** Detect when the score is 11-11.
    *   **Blind Play:** In this state, the player's cards must be dealt face-down (hidden) in the UI.
    *   **No Truco:** Disable the ability to raise stakes (call Truco) during Mão de Ferro.
    *   **Automatic Play:** The round proceeds without the initial "Accept/Run" dialog typical of Mão de 11.
3.  **UI & Terminology:**
    *   **Betting Progression:** Ensure the button labels and logic follow the 1 -> Truco (3) -> Seis (6) -> Nove (9) -> Doze (12) progression.
    *   **Manilha Highlighting:** (Optional but good) Ensure the UI clearly indicates which card is the current Manilha based on the Vira.

## Non-Functional Requirements
1.  **Consistency:** The "Blind Play" implementation should be shared with the "Truco Mineiro" track to avoid code duplication.
2.  **Clarity:** The "Mão de Ferro" state must be clearly communicated to the user.

## Acceptance Criteria
1.  Start a Paulista game; verify "Flor" button is never visible or active.
2.  Verify that Manilhas change correctly based on the Vira (e.g., if Vira is 3, Manilha is 4).
3.  Simulate a game to 11-11; verify that cards are dealt face down (or obscured) and the player cannot see their values until played.
4.  Verify that betting correctly jumps from 3 to 6, 6 to 9, and 9 to 12.

## Out of Scope
1.  Changes to Argentine/Uruguayan/Venezuelan logic.

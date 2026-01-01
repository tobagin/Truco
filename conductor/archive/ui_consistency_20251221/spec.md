# Track Specification: UI Consistency for Game Dialogs

## Overview
Standardize all in-game decision dialogs (Truco, Envido, Flor, Mão de 11, Match End) to use a consistent `Adw.AlertDialog` implementation. This ensures a unified look and feel and leverages Libadwaita's responsive layout (inline vs stacked buttons) to support both desktop and mobile/narrow screen sizes.

## Functional Requirements
1.  **Uniform Implementation:** Use `Adw.AlertDialog` for all gameplay proposals (Truco levels, Envido types, Flor) and game state decisions (Mão de 11).
2.  **Standardized Styling:**
    *   **Accept/Quiero:** Use `Adw.ResponseAppearance.SUGGESTED`.
    *   **Refuse/No Quiero/Run:** Use `Adw.ResponseAppearance.DESTRUCTIVE`.
    *   **Raise/Counter-proposals:** Standardize button placement and styling.
3.  **Adaptive Layout:** Ensure the dialogs take advantage of Libadwaita's automatic button stacking/inline logic based on available width.
4.  **Information Hierarchy:** Consistent formatting for titles (e.g., the name of the call) and body text (who called it and what the current stake is).
5.  **Match End Dialog:** Refactor or wrap the `MatchEndDialog` to ensure it shares the same visual language as the gameplay decision dialogs.

## Non-Functional Requirements
1.  **Responsiveness:** Dialog buttons must transition between inline and stacked based on window width.
2.  **Consistency:** Eliminating the current discrepancy where some dialogs are stacked and others are inline by default.

## Acceptance Criteria
1.  Truco, Envido, Flor, and Mão de 11 dialogs all use `Adw.AlertDialog`.
2.  Buttons follow the standard color scheme (Blue/Suggested for Accept, Red/Destructive for Refuse).
3.  The layout is verified to be responsive (inline on wide, stacked on narrow).
4.  No gameplay decisions are using custom-styled buttons that deviate from the standard.

## Out of Scope
1.  Modifying game logic or state machine transitions.
2.  Adding new sound effects or animations.

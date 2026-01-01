# Track Specification: Truco Mineiro Completion

## Overview
Polish and finalize the "Truco Mineiro" game variant to ensure it strictly follows standard rules and offers a complete experience. This includes disabling non-standard rules (Flor), implementing the critical "Mão de Ferro" (Iron Hand) blind play mechanic, and adding variant-specific terminology and AI behaviors.

## Functional Requirements
1.  **Rule Enforcement:**
    *   **Disable Flor:** Explicitly disable "Flor" calls for `mineiro` and `paulista` game modes.
    *   **Fixed Manilhas:** Verify and reinforce that `mineiro` uses fixed manilhas (4♣, 7♥, A♠, 7♦) regardless of the Vira.
2.  **Mão de Ferro (Iron Hand):**
    *   **Trigger:** Detect when the score is 11-11.
    *   **Blind Play:** In this state, the player's cards must be dealt face-down (hidden) in the UI.
    *   **No Truco:** Disable the ability to raise stakes (call Truco) during Mão de Ferro.
    *   **Automatic Play:** The round proceeds without the initial "Accept/Run" dialog typical of Mão de 11.
3.  **UI & Terminology:**
    *   **Card Labels:** When a player holds a fixed manilha (e.g., 4 of Clubs), the UI/History should refer to it by its specific name (e.g., "Zap") instead of just "4 of Clubs".
4.  **AI Adjustments:**
    *   **Aggression:** Adjust the AI personality for `mineiro` to value fixed manilhas more highly, knowing they are the absolute strongest cards.

## Non-Functional Requirements
1.  **Consistency:** Changes should not regress other variants (Argentino, Uruguayo).
2.  **Clarity:** The "Blind Play" state must be clearly communicated to the user via a status message or visual cue (e.g., "Mão de Ferro - Playing in the Dark").

## Acceptance Criteria
1.  Start a Mineiro game; verify "Flor" button is never visible or active.
2.  Verify that 4♣ is always the highest card (Zap) and beats 7♥.
3.  Simulate a game to 11-11; verify that cards are dealt face down (or obscured) and the player cannot see their values until played (or just strictly hidden representations).
4.  Verify that the AI plays aggressively when holding the Zap.

## Out of Scope
1.  Visual redesign of the card faces (just card backs/hiding logic).
2.  Online multiplayer synchronization.

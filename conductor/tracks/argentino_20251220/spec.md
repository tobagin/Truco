# Track Specification: Truco Argentino Logic & Scoring

## Goal
Implement the core logic and scoring rules for "Truco Argentino" to serve as a robust baseline for the game's regional variations. This track focuses on the standard "blind" Truco (without "Muestra" card) played to 30 points.

## Scope
1.  **Game Rules:**
    -   **Points:** Game played to 30 points (two halves of 15, "Malas" and "Buenas").
    -   **Card Values:** Standard Truco hierarchy (Espada 1 > Basto 1 > Espada 7 > ...).
    -   **Envido:** Logic for calculating Envido points (20 + card values for same suit).
    -   **Flor:** Basic detection of "Flor" (3 cards of same suit). *Note: Configurable to be disabled.*
    -   **Truco Chain:** Logic for Truco -> Retruco -> Vale Cuatro.

2.  **Scoring System:**
    -   Implement a `ScoreManager` or extend existing logic to handle the 15/30 point progression.
    -   UI updates to reflect "Malas" (1-15) and "Buenas" (16-30).

3.  **AI Adjustments:**
    -   Update AI evaluation to respect the Truco Argentino hierarchy and Envido probabilities.

## Out of Scope
-   complex "Muestra" variations (reserved for Uruguayan/Venezuelan tracks).
-   Online multiplayer synchronization (future track).

## User Stories
-   As a player, I want to play a game that follows standard Argentine rules so I can practice for real matches.
-   As a player, I want to see my score clearly indicated as "Malas" or "Buenas".
-   As a player, I want the AI to properly calculate and call "Envido" based on the cards it holds.

# Product Guidelines: Truco

## Tone and Voice
- **Primary Tone:** Playful & Enthusiastic. The default experience should capture the spirited, passionate atmosphere of a real Truco table, using regional slang and lively language.
- **Tone Flexibility:** The application MUST support multiple linguistic "modes" (Playful, Professional, Traditional) selectable in user preferences to ensure comfort for all player types.
- **Clarity:** Regardless of tone, essential instructions and error messages must be unambiguous.

## Visual Identity & UX
- **App Shell:** Clean, modern, and native. Adheres strictly to the GNOME desktop's look and feel using Libadwaita.
- **Game Board:** Textural and organic. Simulates a physical environment with wood grain, green/blue felt textures, and realistic card representations.
- **Action Communication:** Uses text labels by default, with an option in preferences to enable symbolic iconography (e.g., hand gestures for calls).
- **Animation:** Smooth, purposeful animations for card dealing, playing, and score updates to provide a tactile feel.

## Technical Standards
- **Robustness:** Maximize use of Vala's type system to ensure compile-time safety.
- **Architecture:** Maintain a clear separation of concerns (Model-View-Controller pattern) to handle the complex logic of various regional rule sets.
- **Performance:** Maintain 60fps animations and low memory footprint. Logic processing (AI) should not block the UI thread.

## Accessibility & Inclusivity
- **Universal Access:** Full support for keyboard navigation and GNOME accessibility tools (Orca).
- **Adaptability:** High-contrast theme support and seamless scaling with system font sizes.
- **Localization (i18n):** Deep internationalization support for all UI text, rule descriptions, and regional terminology.

## Education & Onboarding
- **Interactive First-Run:** A guided tutorial is the primary method for teaching new players. It should walk them through a sample hand, explaining regional calls and point values.
- **Help Documentation:** A comprehensive, searchable manual for deep reference on specific regional variations.

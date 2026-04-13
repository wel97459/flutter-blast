# Product Guidelines: Blockblast Clone

## User Experience (UX) Principles

*   **Clarity:** The game interface should be clear, intuitive, and easy to understand. Visual feedback for actions (e.g., placing a block, clearing a line) should be immediate and unambiguous.
*   **Responsiveness:** The application must be highly responsive to user input, especially during drag-and-drop operations. Animations should be fluid and contribute to a sense of responsiveness.
*   **Consistency:** UI elements, interactions, and visual styles should be consistent throughout the application to reduce cognitive load and enhance usability.
*   **Feedback:** Provide clear and timely feedback for all user actions and system states (e.g., successful placement, invalid moves, game over, score updates).
*   **Forgiveness:** Allow players to easily understand and recover from mistakes, although the core mechanic of irreversible block placement remains. The focus is on clear communication of rules.

## Visual Design & Branding

*   **Aesthetic:** Clean, modern, and vibrant. Use a color palette that is appealing and offers good contrast for readability and visual differentiation of blocks.
*   **Iconography:** Use simple, recognizable icons where necessary.
*   **Typography:** Choose a clear, legible font that works well across different screen sizes.
*   **Branding Elements:** The game's logo and overall visual identity should be consistent with the fun, challenging, and modern tone.

## Content & Language

*   **Conciseness:** All in-game text (instructions, scores, messages) should be concise, clear, and easy to understand.
*   **Tone:** Friendly, encouraging, and clear. Avoid jargon.

## Accessibility

*   **Color Contrast:** Ensure sufficient color contrast for all UI elements to support players with visual impairments.
*   **Touch Target Size:** Provide adequately sized touch targets for interactive elements to improve usability on mobile devices.
*   **Feedback Mechanisms:** Utilize visual feedback primarily, but consider subtle haptic feedback for key interactions if feasible in Flutter.

## Performance

*   **Smooth Animations:** All animations and transitions should run smoothly at 60fps where possible.
*   **Fast Load Times:** The game should load quickly, and level transitions (e.g., starting a new game) should be instantaneous.
*   **Resource Efficiency:** Optimize for low battery consumption and efficient use of device resources.
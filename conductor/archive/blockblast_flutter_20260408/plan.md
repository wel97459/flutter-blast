# Implementation Plan: Implement Blockblast game in Flutter

This plan outlines the steps to re-implement the Blockblast game in Flutter, based on the provided specification and adhering to the project's workflow principles.

## Phase 1: Setup & Core Game Loop (Flutter) [checkpoint: d4ce853]

- [x] **Task: Flutter Project Setup** d599384
    - [ ] Write Tests: Verify Flutter environment and basic app structure.
    - [ ] Implement to Pass Tests: Create a new Flutter project and configure basic dependencies.
    - [ ] Refactor: Organize initial project structure (e.g., lib/screens, lib/widgets).
- [x] **Task: Game Board Grid Display** be9aa8a
    - [ ] Write Tests: Test rendering of an 8x8 grid on the screen.
    - [ ] Implement to Pass Tests: Create a Flutter widget to draw the 8x8 game board grid.
    - [ ] Refactor: Ensure grid drawing is efficient and configurable.
- [x] **Task: Basic Block Representation** ac35d52
    - [ ] Write Tests: Test block data structure and rendering of individual blocks.
    - [ ] Implement to Pass Tests: Define a `Block` data model and a simple widget to render a single block within the grid.
    - [ ] Refactor: Optimize block rendering and state management.
- [x] **Task: Conductor - User Manual Verification 'Setup & Core Game Loop (Flutter)' (Protocol in workflow.md)**

## Phase 2: UI/UX Implementation (Flutter) [checkpoint: 2f4ae66]

- [x] **Task: Piece Data Model & Generation** efef346
    - [ ] Write Tests: Test random piece generation logic and piece shape definitions.
    - [ ] Implement to Pass Tests: Implement the `Piece` data model with various shapes and a function to generate random pieces.
    - [ ] Refactor: Ensure piece generation is robust and extensible.
- [x] **Task: Shelf UI** 8b1ae77
    - [ ] Write Tests: Test rendering of the shelf area and placing pieces on it.
    - [ ] Implement to Pass Tests: Create a Flutter widget to display the three generated pieces on a shelf area.
    - [ ] Refactor: Optimize shelf rendering and layout.
- [x] **Task: Drag-and-Drop Interaction** 1b201f5
    - [x] Write Tests: Test drag detection, movement, and drop functionality for pieces.
    - [x] Implement to Pass Tests: Implement drag-and-drop gestures for pieces from the shelf to the grid.
    - [x] Refactor: Improve drag-and-drop feel and responsiveness.
- [x] **Task: Conductor - User Manual Verification 'UI/UX Implementation (Flutter)' (Protocol in workflow.md)** 2f4ae66

## Phase 3: Game Logic Integration & Refinement (Flutter) [checkpoint: d763885]

- [x] **Task: Valid Placement Logic** 4e1bb77
    - [x] Write Tests: Test `is_valid_placement` function for various piece shapes and grid states.
    - [x] Implement to Pass Tests: Develop the logic to check if a piece can be validly placed at a given grid position.
    - [x] Refactor: Optimize placement validation for performance.
- [x] **Task: Piece Placement on Grid** 918092f
    - [x] Write Tests: Test `place_piece` function and its effect on the grid state.
    - [x] Implement to Pass Tests: Integrate the placement logic, updating the grid state when a piece is dropped validly.
    - [x] Refactor: Ensure efficient grid state updates.
- [x] **Task: Line Clearing Mechanics** 598f811
    - [x] Write Tests: Test row and column clearing logic with various filled line scenarios.
    - [x] Implement to Pass Tests: Implement the logic to detect and clear full rows/columns and update the score.
    - [x] Refactor: Optimize line clearing algorithm.
- [x] **Task: Score Tracking and Display** a4b34cd
    - [x] Write Tests: Test score updates based on piece placement and line clears.
    - [x] Implement to Pass Tests: Implement score calculation and display it prominently in the UI.
    - [x] Refactor: Improve score display and formatting.
- [x] **Task: Game Over Condition** 45e2b17
    - [x] Write Tests: Test `check_game_over` logic for various unplaceable piece scenarios.
    - [x] Implement to Pass Tests: Develop the logic to detect the game over condition.
    - [x] Refactor: Ensure game over detection is accurate and performant.
- [x] **Task: New Round Initialization** 9cbf5b8
    - [x] Write Tests: Test the logic for generating new pieces for the shelf after a round.
    - [x] Implement to Pass Tests: Implement the mechanism to refill the shelf with new pieces once all current pieces are placed.
    - [x] Refactor: Streamline new round initiation.
- [x] **Task: Conductor - User Manual Verification 'Game Logic Integration & Refinement (Flutter)' (Protocol in workflow.md)** 1a617cc
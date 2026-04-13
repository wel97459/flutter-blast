# Implementation Plan: Move Ghost/Piece Above Finger & Fixed Shelf Height

This plan outlines the steps to enhance the drag-and-drop experience by offsetting the dragged piece and ghost preview above the user's finger, and fixing the piece shelf height to 100px.

## Phase 1: UI Layout Adjustments [checkpoint: 70a3b2c]

- [x] **Task: Fixed Shelf Height** 50c036f
    - [x] Write Tests: Verify `PieceShelf` has a height of 100px.
    - [x] Implement to Pass Tests: Update `PieceShelf` widget to have a fixed height of 100px.
    - [x] Refactor: Ensure the layout remains responsive and aesthetically pleasing with the fixed shelf height.
- [x] **Task: Drag Placeholder** 88821a1
    - [x] Write Tests: Verify that a piece on the shelf becomes invisible when it is being dragged.
    - [x] Implement to Pass Tests: Update `PieceShelf` to show an empty placeholder when a piece is dragged.
    - [x] Refactor: Optimize placeholder rendering logic.
- [x] **Task: Conductor - User Manual Verification 'UI Layout Adjustments' (Protocol in workflow.md)** 70a3b2c

## Phase 2: Drag-and-Drop Interaction Enhancements

- [x] **Task: Draggable Feedback Offset** a0cf714
    - [x] Write Tests: Verify the feedback widget is offset vertically by the piece height.
    - [x] Implement to Pass Tests: Update `Draggable` in `PieceShelf` to use an offset for the feedback widget.
    - [x] Refactor: Ensure the offset calculation is robust for different piece sizes.
- [x] **Task: Ghost Preview Offset** c77549e
    - [x] Write Tests: Verify the ghost preview on the grid is offset vertically to match the dragged piece.
    - [x] Implement to Pass Tests: Update `GameBoardGrid`'s `onMove` logic to apply the vertical offset to the hover position.
    - [x] Refactor: Consolidate offset calculation logic.
- [~] **Task: Precise Drop Logic**
    - [ ] Write Tests: Verify the piece is dropped exactly at the ghost preview's location.
    - [ ] Implement to Pass Tests: Update `DragTarget`'s `onAcceptWithDetails` in `GameBoardGrid` to use the same offset for determining the final drop coordinates.
    - [ ] Refactor: Ensure consistency between `onMove` and `onAccept` logic.
- [ ] **Task: Conductor - User Manual Verification 'Drag-and-Drop Interaction Enhancements' (Protocol in workflow.md)**

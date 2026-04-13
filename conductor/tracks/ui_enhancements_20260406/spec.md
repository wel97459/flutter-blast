# Specification: Move Ghost/Piece Above Finger & Fixed Shelf Height

## Overview
This track involves UI enhancements to improve the drag-and-drop experience in the Blockblast Clone. The goal is to move the dragged piece and its ghost preview above the user's finger during a drag operation, providing better visibility of the placement on the grid. Additionally, the piece shelf will have a fixed height of 100px.

## Functional Requirements
*   **FR1: Draggable Feedback Offset:** When a piece is dragged from the shelf, the feedback widget (the piece being dragged) must be positioned above the user's finger. The vertical offset should be equal to the height of the piece itself.
*   **FR2: Ghost Preview Offset:** The ghost preview on the game board grid must also be offset vertically to match the dragged piece's position, ensuring it remains accurately aligned with where the piece will be dropped.
*   **FR3: Fixed Shelf Height:** The piece shelf area at the bottom of the screen must have a fixed height of 100px.
*   **FR4: Drag Placeholder:** While a piece is being dragged, it must disappear from its original position on the shelf, leaving an empty space (placeholder) within the 100px shelf.
*   **FR5: Precise Drop Logic:** The logic for determining the drop location on the grid must be updated to account for the new vertical offset, ensuring the piece is placed exactly where the ghost preview was shown.

## Non-Functional Requirements
*   **Smoothness:** The drag feedback and ghost preview updates must remain smooth and responsive (target 60fps).
*   **Visual Consistency:** The UI should maintain its clean and intuitive aesthetic throughout the interaction.

## Acceptance Criteria
*   Dragging a piece shows the piece above the user's finger/pointer.
*   The vertical offset of the dragged piece is approximately the piece's height.
*   The ghost preview correctly snaps to the grid but remains offset above the finger.
*   Dropping the piece places it on the grid at the location indicated by the ghost preview.
*   The piece shelf height is exactly 100px.
*   The original piece on the shelf is invisible while being dragged.

## Out of Scope
*   Any changes to the scoring or line clearing logic.
*   Animations for piece movement or snapping.

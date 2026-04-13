# Tech Stack: Blockblast Clone

## Overview
This project involves transitioning an existing Python/Pygame prototype of the Blockblast game into a new mobile application built with Flutter/Dart. The tech stack therefore includes both the original and target technologies.

## Core Technologies

### Current (Prototype)
*   **Language:** Python
*   **Framework:** Pygame (for game loop, graphics, and input handling)

### Target (Mobile Application)
*   **Language:** Dart
    *   **Reasoning:** Dart is the language used by Flutter, optimized for UI development, and provides excellent performance on various platforms.
*   **Framework:** Flutter
    *   **Reasoning:** Flutter is Google's UI toolkit for building natively compiled applications for mobile, web, and desktop from a single codebase. It offers fast development, expressive UIs, and native performance, which is ideal for a mobile game.
*   **Development Environment:**
    -   **IDE:** VS Code or Android Studio with Flutter and Dart plugins.
    -   **Version Control:** Git with auditable task summaries via git notes.

    ## Libraries & Tools (Target - Flutter)

    ### UI/Game Engine
    *   **Vanilla Flutter Widgets:** The game is implemented using standard Flutter widgets (CustomPainter, Draggable, DragTarget) without external game engines.
    *   **StatefulWidgets:** Core game state management is handled using Flutter's native state management.

    ### Build & Deployment
*   **Flutter SDK:** Essential for building and running Flutter applications.
*   **Android SDK/Xcode:** For building and deploying to respective mobile platforms.

## Architectural Considerations

*   **Client-side heavy:** The game logic will primarily reside on the client-side within the Flutter application.
*   **No Backend (initially):** For the initial scope, no backend services are anticipated. All game state and logic will be handled locally on the device.
*   **Modular Design:** Emphasis on creating reusable Flutter widgets and modular game components to ensure maintainability and scalability.

## Data Storage (Future Consideration)
*   **Hive/Sqflite:** For local persistence of high scores or game settings if required in future iterations. (Not in initial scope).
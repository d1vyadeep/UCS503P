# Week 3: Adaptive Reader and Accessibility Controls

## Objective
Build the main reading interface and let users customize how text is displayed.

## Contributions
- Developed or refined the reading text area and controls for choosing a simplification level: Basic, Easier, and Very Simple.
- Added reading preferences for font, text size, letter spacing, page tint, line spacing, and focus mode.
- Used React state to apply preference changes to the reading area immediately.
- Added read-aloud controls using the browser's Web Speech API, including pause, resume, and stop behavior where supported.
- Added clear labels and status messages so users can understand what each control does.

## Technologies Used
- React: reader components and state management.
- CSS: typography, page tint, spacing, and focus-mode presentation.
- Web Speech API: browser-based text-to-speech.
- JavaScript: event handling and preference updates.

## Challenges and Learning
Reading preferences should be adjustable without disrupting the user's place in the text. Browser speech support can vary, so the interface needs a helpful message when read-aloud is unavailable.

## Next Steps
Connect the simplify action to the backend API and improve loading and error states.


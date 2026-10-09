# Week 3: Text Simplification Endpoint

## Objective
Create the backend endpoint that returns a simplified version of user-provided text.

## Contributions
- Implemented or refined the POST endpoint at `/api/reader/simplify/`.
- Parsed JSON input and validated that text is present and within the configured character limit.
- Added validation for the supported levels: Basic, Easier, and Very Simple.
- Created level-specific instructions for the AI model to control how much the text is simplified.
- Integrated the Gemini API from the backend and returned the simplified text and selected level as JSON.
- Added server-side logging for provider failures while returning a safe error message to the client.

## Technologies Used
- Django: endpoint and HTTP response handling.
- Python `json`: request-body parsing.
- Google GenAI SDK: call to the language model.
- Environment configuration: server-side API key and model selection.

## Challenges and Learning
AI output can be empty or the provider can fail. The endpoint needs validation and predictable error responses so the frontend can handle failures gracefully.

## Next Steps
Test invalid inputs and connect the endpoint with the frontend request helper.


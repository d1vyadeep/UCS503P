# Week 1: Backend Setup and API Planning

## Objective
Set up the Python backend service and define how the frontend will request reading assistance.

## Contributions
- Reviewed the project requirements and defined the backend responsibilities: receive reading text, validate requests, call the AI provider, and return a predictable response.
- Reviewed the Django project structure, including configuration, URL routing, and the reader application.
- Planned a health-check route and a dedicated endpoint for text simplification.
- Identified configuration values that should be stored in environment variables rather than source code.
- Coordinated the API contract with the frontend teammate, including text input, simplification level, and response fields.

## Technologies Used
- Python: backend language.
- Django: web framework and request handling.
- JSON: API request and response format.
- Environment variables / python-dotenv: configuration management.

## Challenges and Learning
A clear API contract prevents mismatches between frontend and backend. Secrets such as API keys must remain on the server and should not be exposed to browser code or committed to version control.

## Next Steps
Implement token verification and the initial endpoint structure.


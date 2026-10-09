# Week 4: AI API Integration and User Feedback

## Objective
Connect the reader interface to the text-simplification API and handle its response reliably.

## Contributions
- Connected the frontend simplify action to the Django endpoint through a dedicated API helper.
- Sent the text and selected simplification level in a JSON request.
- Included the current Supabase access token in the authorization header when available.
- Added a loading state to prevent repeated simplify requests while a request is running.
- Displayed success and error messages based on the API response.
- Reviewed the save-article interaction and its feedback to make the outcome clear to the user.

## Technologies Used
- React and JavaScript: request handling and UI states.
- Fetch API: HTTP communication with the backend.
- Supabase Auth: access-token retrieval.
- Django REST-style endpoint: text simplification service.




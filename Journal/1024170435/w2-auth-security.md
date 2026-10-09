# Week 2: Authentication Verification and API Security

## Objective
Protect the reading API so requests require a valid authenticated user session.

## Contributions
- Implemented or reviewed a backend authentication decorator for requests carrying a Bearer token.
- Configured verification of Supabase-issued JWTs using the Supabase JWKS endpoint.
- Added responses for missing, invalid, or expired tokens.
- Checked that AI provider credentials and Django secrets are read from environment variables.
- Reviewed the allowed-origin configuration for frontend-to-backend requests.

## Technologies Used
- Django: request and response handling.
- PyJWT: token decoding and validation.
- PyJWKClient / Supabase JWKS: public-key retrieval for JWT verification.
- python-dotenv: loading local environment configuration.

## Challenges and Learning
Authentication must be checked on the server; hiding a frontend control is not sufficient protection. Error responses should not expose secret values or internal diagnostics.

## Next Steps
Implement the text-simplification endpoint with input validation.


# LEXIA — first MVP slice

The original visual reference is preserved at `lexia-frontend.html`. The React implementation in `frontend/` carries forward its visual tokens, layout, typography, card treatment, sidebar, and calm reading-space design; this first slice intentionally implements only authentication and the adaptive reader.

## Run locally

1. Install Node.js **with npm** (the current machine has Node but no npm available).
2. In `frontend/`, copy `.env.example` to `.env`. Add only the Supabase URL, publishable key, and Django service URL.
3. Run `npm install` and `npm run dev` in `frontend/`.
4. Install Python 3.11+ and create a virtual environment in `ai-service/`.
5. Install `requirements.txt`, copy `.env.example` to `.env`, and supply the Gemini key, Supabase JWKS URL, and Django secret there. Load these environment values before running Django.
6. Apply `supabase/migrations/20260917_lexia_foundation.sql` through the Supabase CLI or SQL Editor before creating test users.

## Security boundary

`VITE_SUPABASE_PUBLISHABLE_KEY` is the only Supabase credential allowed in the browser. The Gemini key and any Supabase secret/service-role key must never be put in `frontend/`, committed to git, or returned by Django. The browser sends the user access token to Django; Django verifies it against Supabase JWKS before calling Gemini.

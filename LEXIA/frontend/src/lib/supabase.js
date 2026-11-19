import { createClient } from '@supabase/supabase-js'

const url = import.meta.env.VITE_SUPABASE_URL
const publishableKey = import.meta.env.VITE_SUPABASE_PUBLISHABLE_KEY

if (!url || !publishableKey) {
  console.warn('Supabase is not configured. Copy .env.example to .env and supply only browser-safe values.')
}

export const supabase = createClient(url ?? 'https://example.invalid', publishableKey ?? 'placeholder')

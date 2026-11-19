import { supabase } from './supabase'

const endpoint = import.meta.env.VITE_AI_SERVICE_URL

export async function simplifyText({ text, level }) {
  const { data: { session } } = await supabase.auth.getSession()
  const response = await fetch(`${endpoint}/api/reader/simplify/`, {
    method: 'POST',
    headers: {
      'Content-Type': 'application/json',
      ...(session?.access_token ? { Authorization: `Bearer ${session.access_token}` } : {}),
    },
    body: JSON.stringify({ text, level }),
  })
  if (!response.ok) throw new Error((await response.json().catch(() => null))?.detail ?? 'Unable to simplify text.')
  return response.json()
}

export async function summarizeText({ text }) {
  const { data: { session } } = await supabase.auth.getSession()
  const response = await fetch(`${endpoint}/api/reader/summarize/`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json', ...(session?.access_token ? { Authorization: `Bearer ${session.access_token}` } : {}) },
    body: JSON.stringify({ text }),
  })
  if (!response.ok) throw new Error((await response.json().catch(() => null))?.detail ?? 'Unable to summarize text.')
  return response.json()
}

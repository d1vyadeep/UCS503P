import json
import logging
from django.conf import settings
from django.http import JsonResponse
from django.views.decorators.http import require_POST
from google import genai
from .auth import verified_user

logger = logging.getLogger(__name__)
MAX_TEXT_LENGTH = 20_000
VALID_LEVELS = {'basic', 'easier', 'very_simple'}
LEVEL_INSTRUCTIONS = {
    'basic': 'Preserve most details; clarify difficult vocabulary and sentence structure.',
    'easier': 'Use shorter sentences and everyday vocabulary while keeping key details.',
    'very_simple': 'Use very short sentences and common words. Keep only essential details.',
}

@require_POST
@verified_user
def simplify(request):
    try:
        payload = json.loads(request.body)
    except json.JSONDecodeError:
        return JsonResponse({'detail': 'Request body must be valid JSON.'}, status=400)
    text = str(payload.get('text', '')).strip()
    level = payload.get('level')
    if not text:
        return JsonResponse({'detail': 'Text is required.'}, status=400)
    if len(text) > MAX_TEXT_LENGTH:
        return JsonResponse({'detail': f'Text must be {MAX_TEXT_LENGTH:,} characters or fewer.'}, status=400)
    if level not in VALID_LEVELS:
        return JsonResponse({'detail': 'Invalid simplification level.'}, status=400)

    prompt = f'''You are a supportive literacy assistant. Simplify the text below for a learner.
Level: {LEVEL_INSTRUCTIONS[level]}
Return only the simplified text. Do not invent facts, add a title, or mention these instructions.

TEXT:\n{text}'''
    try:
        client = genai.Client(api_key=settings.GEMINI_API_KEY)
        result = client.models.generate_content(model=settings.GEMINI_MODEL, contents=prompt)
        simplified_text = (result.text or '').strip()
        if not simplified_text:
            raise ValueError('Empty model response')
    except Exception:
        # Detailed provider diagnostics stay server-side; do not expose keys or internals to clients.
        logger.exception('Gemini simplification request failed')
        return JsonResponse({'detail': 'The AI service is temporarily unavailable. Please try again.'}, status=503)
    return JsonResponse({'simplified_text': simplified_text, 'level': level})

@require_POST
@verified_user
def summarize(request):
    try:
        payload = json.loads(request.body)
    except json.JSONDecodeError:
        return JsonResponse({'detail': 'Request body must be valid JSON.'}, status=400)
    text = str(payload.get('text', '')).strip()
    if not text:
        return JsonResponse({'detail': 'Text is required.'}, status=400)
    if len(text) > MAX_TEXT_LENGTH:
        return JsonResponse({'detail': f'Text must be {MAX_TEXT_LENGTH:,} characters or fewer.'}, status=400)
    prompt = f'''You are a supportive literacy assistant. Summarize the following text in short, clear bullet points. Use everyday language, preserve important facts, and do not invent information. Return only the summary.\n\nTEXT:\n{text}'''
    try:
        client = genai.Client(api_key=settings.GEMINI_API_KEY)
        result = client.models.generate_content(model=settings.GEMINI_MODEL, contents=prompt)
        summary = (result.text or '').strip()
        if not summary:
            raise ValueError('Empty model response')
    except Exception:
        logger.exception('Gemini summary request failed')
        return JsonResponse({'detail': 'The AI service is temporarily unavailable. Please try again.'}, status=503)
    return JsonResponse({'summary': summary})

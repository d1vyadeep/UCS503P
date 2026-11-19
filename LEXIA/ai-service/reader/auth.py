from functools import lru_cache
from django.conf import settings
from django.http import JsonResponse
import jwt
from jwt import PyJWKClient

@lru_cache
def jwks_client():
    return PyJWKClient(settings.SUPABASE_JWKS_URL, cache_keys=True)

def verified_user(view):
    def wrapped(request, *args, **kwargs):
        token = request.headers.get('Authorization', '').removeprefix('Bearer ').strip()
        if not token:
            return JsonResponse({'detail': 'Authentication is required.'}, status=401)
        try:
            key = jwks_client().get_signing_key_from_jwt(token).key
            request.user_claims = jwt.decode(token, key, algorithms=['ES256'], audience='authenticated')
        except jwt.PyJWTError:
            return JsonResponse({'detail': 'Invalid or expired session.'}, status=401)
        return view(request, *args, **kwargs)
    return wrapped

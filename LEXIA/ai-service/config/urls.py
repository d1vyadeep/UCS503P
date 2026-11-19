from django.http import JsonResponse
from django.urls import path
from reader.views import simplify, summarize

def health(_request):
    return JsonResponse({
        'service': 'LEXIA AI service',
        'status': 'running',
        'reader_simplification_endpoint': '/api/reader/simplify/',
    })

urlpatterns = [
    path('', health, name='health'),
    path('api/reader/simplify/', simplify, name='simplify'),
    path('api/reader/summarize/', summarize, name='summarize'),
]

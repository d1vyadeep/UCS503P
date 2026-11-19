import os
from pathlib import Path
from dotenv import load_dotenv

BASE_DIR = Path(__file__).resolve().parent.parent
load_dotenv(BASE_DIR / '.env')
SECRET_KEY = os.environ['DJANGO_SECRET_KEY']
DEBUG = os.getenv('DJANGO_DEBUG', '').lower() == 'true'
ALLOWED_HOSTS = os.getenv('ALLOWED_HOSTS', 'localhost,127.0.0.1').split(',')
INSTALLED_APPS = ['corsheaders', 'django.contrib.contenttypes', 'django.contrib.auth', 'reader']
MIDDLEWARE = ['corsheaders.middleware.CorsMiddleware', 'django.middleware.common.CommonMiddleware']
ROOT_URLCONF = 'config.urls'
DEFAULT_AUTO_FIELD = 'django.db.models.BigAutoField'
CORS_ALLOWED_ORIGINS = [value for value in os.getenv('ALLOWED_ORIGINS', '').split(',') if value]
GEMINI_API_KEY = os.environ['GEMINI_API_KEY']
GEMINI_MODEL = os.getenv('GEMINI_MODEL', 'gemini-3.6-flash')
SUPABASE_JWKS_URL = os.environ['SUPABASE_JWKS_URL']

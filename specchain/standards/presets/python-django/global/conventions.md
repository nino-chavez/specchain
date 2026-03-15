# Project Conventions (Python/Django)

## File Organization
- Apps grouped by domain (e.g., `users/`, `products/`, `orders/`)
- Each app: `models.py`, `views.py`, `serializers.py`, `urls.py`, `tests/`
- Co-locate tests: `app/tests/test_models.py`, `app/tests/test_views.py`

## Imports
- Group: stdlib, third-party, Django, local apps
- Use absolute imports for cross-app references
- Use relative imports within the same app

## Configuration
- Use django-environ for environment variables
- Never hardcode secrets — use .env files
- Separate settings: base.py, development.py, production.py

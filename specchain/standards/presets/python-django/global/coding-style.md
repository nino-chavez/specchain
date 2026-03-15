# Coding Style Standards (Python/Django)

## Formatting
- Follow PEP 8 strictly
- Use Black for formatting (line length 88)
- Use isort for import ordering
- Use type hints on all function signatures

## Naming
- snake_case for functions, variables, modules
- PascalCase for classes
- UPPER_SNAKE_CASE for constants
- Prefix private methods with underscore

## Structure
- Keep functions under 20 lines
- One class per file for models and serializers
- Use dataclasses or Pydantic for data transfer objects
- Prefer composition over inheritance

## Django-Specific
- Fat models, thin views — business logic in models or services, not views
- Use Django's built-in validators
- Never use `objects.raw()` for queries — use the ORM
- Use `select_related` and `prefetch_related` to avoid N+1

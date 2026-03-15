# API Standards (Django REST Framework)

## URL Conventions
- Use plural nouns: `/api/v1/users/`, `/api/v1/products/`
- Nested resources for relationships: `/api/v1/users/{id}/orders/`
- Use query params for filtering: `?status=active&page=2`

## Serializers
- Separate read and write serializers when needed
- Use `SerializerMethodField` sparingly — prefer annotations
- Always specify `fields` explicitly (never use `__all__`)

## ViewSets
- Use ModelViewSet for standard CRUD
- Override `get_queryset()` for filtered access
- Use `@action` decorator for custom endpoints
- Apply permission classes at the view level

## Pagination
- Default page size: 25
- Use cursor pagination for large datasets
- Always return total count in list responses

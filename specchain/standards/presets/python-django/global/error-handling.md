# Error Handling Standards (Python/Django)

## API Errors
- Return consistent JSON error responses: `{"error": "message", "code": "ERROR_CODE"}`
- Use appropriate HTTP status codes (400, 401, 403, 404, 422, 500)
- Use DRF's exception handler for consistent formatting

## Exceptions
- Create custom exception classes per domain
- Catch specific exceptions, never bare `except:`
- Use `raise ... from err` to preserve exception chains
- Log exceptions with full context before re-raising

## Validation
- Validate at serializer level (DRF serializers)
- Use Django model validators for database-level constraints
- Return all validation errors at once (not one at a time)

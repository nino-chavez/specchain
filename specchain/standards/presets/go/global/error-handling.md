# Error Handling Standards (Go)

## Patterns
- Return `error` as the last return value
- Check errors immediately after the call
- Wrap with context at each level: `fmt.Errorf("creating order: %w", err)`
- Use `errors.Is()` and `errors.As()` for error inspection

## Custom Errors
- Define domain error types: `type NotFoundError struct { Resource string; ID string }`
- Implement `Error() string` on custom types
- Use sentinel errors for well-known conditions: `var ErrNotFound = errors.New("not found")`

## HTTP Errors
- Map domain errors to HTTP status codes in the handler layer only
- Return JSON: `{"error": "message", "code": "NOT_FOUND"}`
- Log internal errors, return sanitized messages to clients
- Use middleware for panic recovery

# API Standards (Go)

## Router
- Use chi or gorilla/mux for routing
- Group routes by resource: `r.Route("/api/v1/users", userRoutes)`
- Use middleware for auth, logging, CORS, rate limiting

## Handlers
- Accept `http.ResponseWriter` and `*http.Request`
- Parse input early, validate, then call service layer
- Never put business logic in handlers
- Use `context.Context` for cancellation and request-scoped values

## Response Format
- Consistent JSON envelope: `{"data": ..., "meta": {"total": N}}`
- Use `encoding/json` with struct tags
- Set `Content-Type: application/json` on all responses
- Return appropriate status codes (200, 201, 204, 400, 404, 500)

# Coding Style Standards (Go)

## Formatting
- `gofmt` / `goimports` — non-negotiable, run on save
- Follow Effective Go and Go Code Review Comments
- Use `golangci-lint` with project `.golangci.yml`

## Naming
- Short, descriptive names: `srv` not `server`, `ctx` not `context`
- Exported names are PascalCase, unexported are camelCase
- Interfaces named by method: `Reader`, `Stringer`, `Handler`
- Avoid stuttering: `user.User` not `user.UserStruct`

## Structure
- Accept interfaces, return structs
- Keep packages small and focused
- One file per major type or concern
- `internal/` for packages not meant for external import

## Error Handling
- Always handle errors — never `_ = err`
- Wrap errors with context: `fmt.Errorf("fetching user %d: %w", id, err)`
- Use sentinel errors or custom error types for expected failures
- Errors are values — use them in control flow, don't panic

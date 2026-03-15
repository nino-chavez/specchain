# Project Conventions (Go)

## Layout
Follow standard Go project layout:
- `cmd/` — Entry points (main packages)
- `internal/` — Private application code
- `pkg/` — Public library code (if applicable)
- `api/` — OpenAPI specs, protobuf definitions
- `migrations/` — Database migrations

## Dependencies
- Use Go modules (`go.mod`)
- Minimize external dependencies — stdlib is powerful
- Vendor if deploying to restricted environments
- Pin major versions in `go.mod`

## Configuration
- Use environment variables (12-factor)
- Parse config at startup, pass as structs (no global state)
- Use `envconfig` or `viper` for structured config loading

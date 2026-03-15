# Test Writing Standards (Go)

## Framework
- Use stdlib `testing` package as foundation
- Use `testify/assert` for readable assertions
- Use `testify/suite` for setup/teardown when needed

## Patterns
- Table-driven tests for multiple input/output cases
- Name test cases descriptively in the table
- Use `t.Run()` for sub-tests
- Use `t.Helper()` in test utility functions

## Practices
- Test packages from the outside: `package foo_test`
- Use `testdata/` directory for test fixtures
- Mock interfaces with hand-written mocks or `gomock`
- Use `httptest.NewServer()` for HTTP handler tests
- Run tests with `-race` flag in CI

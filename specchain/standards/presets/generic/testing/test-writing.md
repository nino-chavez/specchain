# Test Writing Standards (Generic)

## Structure
- Follow Arrange-Act-Assert (AAA) pattern
- One logical assertion per test
- Descriptive test names that explain the expected behavior
- Group related tests together

## Focus
- Test behavior, not implementation details
- Prioritize critical paths and edge cases
- Test at the right level: unit for logic, integration for boundaries, e2e for workflows
- Don't test framework code — test your code

## Practices
- Tests should be independent and run in any order
- Use factories or fixtures for test data — avoid hard-coded values
- Mock external dependencies, not internal code
- Keep tests fast — slow tests don't get run

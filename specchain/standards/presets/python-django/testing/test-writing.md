# Test Writing Standards (Python/Django)

## Framework
- Use pytest with pytest-django
- Use factory_boy for test data (never fixtures.json)
- Use `@pytest.mark.django_db` for database tests

## Structure
- Arrange-Act-Assert pattern
- One assertion per test (prefer)
- Name tests: `test_<what>_<condition>_<expected>`
- Group in classes by feature: `class TestUserRegistration:`

## Practices
- Use `APIClient` for API tests
- Mock external services with `responses` or `unittest.mock`
- Test permissions separately from business logic
- Use `freezegun` for time-dependent tests

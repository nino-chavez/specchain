# Project Conventions (Generic)

## File Organization
- Group by feature, not by type (co-locate related files)
- Co-locate tests with the code they test
- Keep file names descriptive and consistent with their exports

## Imports
- Group imports: external libraries first, then internal modules, then relative imports
- Sort alphabetically within groups
- Avoid circular dependencies

## Documentation
- Document "why" not "what" — code should be self-documenting for the "what"
- Use doc comments for public APIs and exported functions
- Keep README files up to date with setup and development instructions
- Include TODOs with context: `TODO(reason): description`

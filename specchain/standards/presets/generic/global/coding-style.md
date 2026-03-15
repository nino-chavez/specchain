# Coding Style Standards (Generic)

## Naming Conventions
- Use descriptive, meaningful names for variables, functions, and classes
- Boolean variables should read as questions: `isActive`, `hasPermission`, `canEdit`
- Functions should be verbs: `getUser`, `createProfile`, `validateInput`

## Formatting
- Consistent indentation throughout the project
- Keep lines under 120 characters
- One blank line between logical sections
- No trailing whitespace

## Structure
- Keep functions small and focused (single responsibility)
- Prefer pure functions where possible
- Limit function parameters (max 3-4, use objects for more)
- Early returns to reduce nesting

## General Principles
- Don't repeat yourself (DRY) — but don't abstract prematurely
- Prefer explicit over implicit
- Write code for readability first, optimize second
- Delete dead code rather than commenting it out

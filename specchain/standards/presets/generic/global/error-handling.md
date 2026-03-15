# Error Handling Standards (Generic)

## Principles
- Fail fast in development, gracefully in production
- Never swallow errors silently
- Validate at system boundaries (user input, external APIs)
- Trust internal code — don't over-validate between internal modules

## User-Facing Errors
- Show friendly, actionable messages to users
- Never expose stack traces or internal details
- Include guidance on what the user can do to resolve the issue

## Logging
- Log errors with sufficient context to reproduce
- Include operation name, input identifiers, and error details
- Use structured logging where available
- Log at appropriate severity levels (error, warn, info, debug)

## Recovery
- Provide fallback behavior for non-critical failures
- Use retry with backoff for transient failures (network, database)
- Set sensible timeouts on all external calls

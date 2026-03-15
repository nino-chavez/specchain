# Example: User Profile Feature

This is a complete worked example showing every artifact specchain produces through its spec-driven development workflow.

## How this was created

1. `/new-spec Add a user profile page with avatar upload and bio editing`
2. Answered researcher's clarifying questions (see planning/requirements.md)
3. `/create-spec` — generated spec.md and tasks.md
4. `/implement-spec` — implemented with squad + standard profile

## Artifact walkthrough

| File | Purpose |
|------|---------|
| `planning/initialization.md` | Raw user idea, preserved unchanged |
| `planning/requirements.md` | Researcher Q&A output with gathered requirements |
| `planning/execution-profile.yml` | Persisted execution profile (squad + standard) |
| `spec.md` | Generated specification document |
| `tasks.md` | Task breakdown with domain-layer grouping |
| `planning/progress.yml` | Implementation progress tracking (completed) |
| `implementation/` | Per-group implementation reports |
| `verification/` | Verifier reports and final verification |

## Execution profile used

- **Strategy:** squad (multi-agent delegation)
- **Depth:** standard (full pipeline with domain verifiers)

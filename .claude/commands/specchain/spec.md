# Unified Spec Process

This command chains the full spec lifecycle with confirmation gates between each phase. Individual commands (`/new-spec`, `/create-spec`, `/implement-spec`) remain available for granular control.

## Preconditions

Before starting, verify:
1. `specchain/config.yml` exists — if not, display: "Specchain not installed in this project. Run `./setup.sh /path/to/project` first." and STOP.

## Command Flags

Inherits all flags from individual commands:

**Execution profile overrides:**
- `--solo` | `--squad` — Strategy override
- `--lean` | `--standard` | `--thorough` — Depth override

**Flow control:**
- `--skip-to create` — Skip initialization, jump to spec creation (requires existing spec with requirements)
- `--skip-to implement` — Skip to implementation (requires existing spec with spec.md and tasks.md)

**Context management:**
- `--fresh-agent` — Force fresh agents during implementation
- `--no-context-split` — Disable mandatory context splitting
- `--resume-from <N>` — Resume implementation from task group N

## Process

### Gate 0: Determine entry point

- If `--skip-to create` is provided: Verify a spec folder exists with `planning/requirements.md`, then jump to Phase 2.
- If `--skip-to implement` is provided: Verify a spec folder exists with `spec.md` and `tasks.md`, then jump to Phase 3.
- Otherwise: Start at Phase 1.

---

### Phase 1: Initialize & Research

Execute the `/new-spec` workflow (Phase 1-3 from new-spec.md):
1. Initialize spec folder via spec-initializer
2. Research requirements via spec-researcher (depth-aware questions)
3. Display results

Pass any execution profile flags (`--solo`, `--squad`, `--lean`, `--standard`, `--thorough`) through to the spec-initializer.

After completion, present gate:
```
Phase 1 complete: Spec initialized, requirements gathered.
- Spec folder: [path]
- Execution profile: [strategy] + [depth]

Proceed to spec creation? (y/stop)
```

If user says "stop": Exit with message "Run `/spec --skip-to create` to continue."

---

### Phase 2: Create Spec & Tasks

Execute the `/create-spec` workflow (Phase 0-4 from create-spec.md):
1. Load execution profile
2. Generate spec.md via spec-writer
3. Generate tasks.md via tasks-list-creator
4. Verify (conditional on depth)
5. Display results

After completion, present gate:
```
Phase 2 complete: spec.md and tasks.md created.
[If verification ran: Verification: [status]]

Proceed to implementation? (y/stop)
```

If user says "stop": Exit with message "Run `/spec --skip-to implement` to continue."

---

### Phase 3: Implement

Execute the `/implement-spec` workflow (Phase 0-5 from implement-spec.md):
1. Load state and check for progress
2. Resolve execution profile (with auto-suggest)
3. Plan assignments (squad) or process directly (solo)
4. Delegate task group implementations
5. Run verifiers (squad + standard/thorough)
6. Remediation loop (if issues found)
7. Final verification report
8. Update state

Pass through all relevant flags (`--fresh-agent`, `--no-context-split`, `--resume-from`).

---

### Completion

After all phases complete, display:
```
Spec lifecycle complete!
- Spec: [spec-name]
- Profile: [strategy] + [depth]
- Tasks: [N] groups completed
- Verification: [status]
- State: Updated

All artifacts in: specchain/specs/[spec-folder]/
```

# Specchain

A spec-driven development workflow for AI-assisted coding. Define features as specifications, then let structured agents implement and verify them — with crash recovery, remediation loops, and full traceability.

## Features

- **Unified `/spec` command** — chains initialization, spec creation, and implementation with confirmation gates
- **Execution profiles** — solo/squad strategy x lean/standard/thorough depth (6 combos)
- **Structured state directory** — 6 YAML files replace monolithic STATE.md
- **Crash recovery** — `progress.yml` tracks per-group completion; resume with `--resume-from`
- **Remediation loop** — verifier issues route back to implementers (Phase 3.5, capped at 1 cycle)
- **Mandatory context splitting** — solo strategy auto-splits at threshold, not just advisory
- **Conflict detection** — warns when concurrent specs touch the same domain
- **Weighted auto-suggest** — complexity scoring: subtasks x1 + domains x3 + cross-cutting x5
- **Bidirectional traceability** — structured YAML frontmatter in all reports; implementers add spec/task comments in code
- **Multi-editor support** — CLAUDE.md, .cursorrules, and .windsurfrules templates
- **Tech stack presets** — generic, typescript-nextjs, python-django, go
- **Self-tests** — validate agents, templates, and project structure

## Quick Setup

```bash
# Option 1: npx (recommended)
npx create-specchain /path/to/your/project

# Option 2: git clone
git clone https://github.com/nino-chavez/specchain.git
cd specchain
./setup.sh /path/to/your/project
```

## Quick Example

See [examples/user-profile/](examples/user-profile/) for a complete worked example — from raw idea through implementation and verification, including `progress.yml` and structured implementation reports.

## 5-Minute Walkthrough

Run the unified `/spec` command and walk through each gate:

```
> /spec Add user profile page with avatar upload

Phase 1 complete: Spec initialized, requirements gathered.
- Spec folder: specchain/specs/2026-03-15-user-profile/
- Execution profile: squad + standard

Proceed to spec creation? (y/stop)
> y

Phase 2 complete: spec.md and tasks.md created.
Verification: passed (3 consistency checks)

Proceed to implementation? (y/stop)
> y

Spec Analysis:
- Tasks: 4 groups, 12 sub-tasks
- Domains: database, api, frontend (complexity: +9)
- Cross-cutting: yes (+5)
- Complexity score: 26

Recommended: squad + standard
Accept? Or override with flags (e.g., --squad --thorough)
> y

Task Group 1: Data Models — delegated to database-engineer ... Complete
Task Group 2: API Endpoints — delegated to api-engineer ... Complete
Task Group 3: UI Components — delegated to ui-designer ... Complete
Task Group 4: Test Review — delegated to testing-engineer ... Complete

Verification: backend-verifier passed, frontend-verifier passed
Final verification: passed

Spec lifecycle complete!
- Spec: 2026-03-15-user-profile
- Profile: squad + standard
- Tasks: 4 groups completed
- State: Updated
```

## Structure

```
your-project/
├── specchain/
│   ├── config.yml                 # Execution config (includes specchain_version)
│   ├── state/                     # Session state (replaces STATE.md)
│   │   ├── context.yml            # Where you left off, active spec
│   │   ├── decisions.yml          # Key decisions and rationale
│   │   ├── blockers.yml           # Active and resolved blockers
│   │   ├── sessions.yml           # Session history log
│   │   ├── patterns.yml           # Reusable patterns discovered
│   │   └── profiles.yml           # Execution profile history
│   ├── docs/
│   │   └── execution-profiles.md
│   ├── governance/
│   │   ├── principles.md          # Core governance principles
│   │   ├── claude-md.tmpl         # CLAUDE.md template (envsubst)
│   │   ├── cursorrules.tmpl       # .cursorrules template (envsubst)
│   │   └── windsurfrules.tmpl     # .windsurfrules template (envsubst)
│   ├── product/
│   │   └── roadmap.md
│   ├── roles/
│   │   ├── implementers.yml
│   │   └── verifiers.yml
│   ├── specs/
│   │   └── [feature-name]/
│   │       ├── spec.md
│   │       ├── tasks.md
│   │       ├── planning/
│   │       │   ├── initialization.md
│   │       │   ├── requirements.md
│   │       │   ├── execution-profile.yml
│   │       │   └── progress.yml       # Crash recovery tracker
│   │       ├── implementation/        # Reports with YAML frontmatter
│   │       └── verification/
│   └── standards/
│       ├── presets/                    # Tech stack presets
│       │   ├── generic/
│       │   ├── python-django/
│       │   └── go/
│       ├── backend/
│       ├── frontend/
│       ├── global/
│       └── testing/
│
├── .claude/
│   ├── commands/specchain/
│   │   ├── spec.md                    # Unified lifecycle command
│   │   ├── new-spec.md
│   │   ├── create-spec.md
│   │   ├── implement-spec.md
│   │   └── plan-product.md
│   └── agents/specchain/
│       ├── spec-initializer.md
│       ├── spec-researcher.md
│       ├── spec-writer.md
│       ├── tasks-list-creator.md
│       ├── spec-verifier.md
│       ├── implementation-verifier.md
│       ├── database-engineer.md
│       ├── api-engineer.md
│       ├── ui-designer.md
│       ├── testing-engineer.md
│       ├── backend-verifier.md
│       ├── frontend-verifier.md
│       └── product-planner.md
│
├── examples/
│   └── user-profile/                  # Quickstart worked example
│
└── test/
    ├── validate_agents.sh
    ├── validate_templates.sh
    └── validate_structure.sh
```

## Commands

| Command | Description |
|---------|-------------|
| `/spec` | **Unified lifecycle** — chains init, create, and implement with gates between each phase |
| `/new-spec` | Initialize a new spec with requirements gathering |
| `/create-spec` | Generate spec.md and tasks.md from requirements |
| `/implement-spec` | Implement a specification with progress tracking |
| `/plan-product` | Product planning and roadmap |

All commands validate preconditions before running (e.g., config exists, spec folder present, roles defined).

## Execution Profiles

Two orthogonal axes control execution behavior:

### Strategy: `solo` | `squad`

| Strategy | Description | Agent Model |
|----------|-------------|-------------|
| **solo** | Single agent handles ALL implementation | No agent assignment, no domain verifiers. Mandatory context splitting at threshold. |
| **squad** | Multi-agent delegation to specialists | database-engineer, api-engineer, ui-designer, testing-engineer + domain verifiers. |

### Depth: `lean` | `standard` | `thorough`

| Depth | Spec Creation | Implementation | Verification |
|-------|--------------|----------------|--------------|
| **lean** | 3-5 Q&A questions, skip visual analysis | Skip testing-engineer group | Skip domain verifiers, minimal final verification |
| **standard** | 6-9 questions, full pipeline | Full delegation | Domain verifiers + full final verification |
| **thorough** | 6-9 questions + architecture/testing | TDD Red-Green-Refactor, phase checkpoints | All verifiers + coverage + manual confirmation |

### Composition Matrix

| | lean | standard | thorough |
|---|---|---|---|
| **solo** | Fastest path. One agent, minimal checks. | Conductor-like. One agent, full spec pipeline. | Max single-agent rigor: TDD, checkpoints at phase boundaries. |
| **squad** | Fast specialists. Parallel delegation, skip verifiers. | **Default.** Balanced rigor with specialists. | Full rigor: TDD per agent, phase checkpoints, fresh agents, all verification layers. |

### Common Combos

| Use Case | Flags | Why |
|----------|-------|-----|
| Hotfix / small bug | `--solo --lean` | Fastest path, one agent, minimal ceremony |
| Config change | `--solo --lean` | Infrastructure-only, no UI verification needed |
| Standard feature | *(default)* | Squad + standard is the balanced default |
| Solo developer flow | `--solo --standard` | Full pipeline, single-agent Conductor-like workflow |
| Major feature | `--squad --thorough` | Full rigor with specialists, TDD, phase checkpoints |
| Critical release | `--squad --thorough` | Maximum verification including manual confirmation gates |

### Auto-Suggest

When `auto_suggest: true` and no explicit flags are provided, the system computes a weighted complexity score:

```
Complexity = (subtask_count x 1) + (domain_count x 3) + (cross_cutting ? 5 : 0)
```

| Score | Recommendation |
|-------|---------------|
| <= 10, new code < 30% | `solo` + `lean` |
| <= 15, single domain | `solo` |
| 16 - 40 | `squad` + `standard` |
| > 40 | `squad` + `thorough` |

The system always prompts with a scoring breakdown — it never silently decides.

## Crash Recovery & Resumption

Each spec tracks per-group completion in `planning/progress.yml`:

```yaml
task_groups:
  - group: "Task Group 1: Data Models"
    status: complete
    agent: database-engineer
    completed_at: "2026-03-15T10:45:00Z"
  - group: "Task Group 2: API Endpoints"
    status: failed
    failure_reason: "agent_crash"
```

If a session ends unexpectedly, specchain detects existing progress on next run:

```
Found previous progress for this spec:
- Task Group 1: Data Models — Complete
- Task Group 2: API Endpoints — Failed

Resume from Task Group 2? (y/restart/skip-to-N)
```

You can also resume explicitly: `/implement-spec --resume-from 2`

**Fresh agent failure handling:** If a spawned agent times out (60s), crashes, or returns malformed output, specchain records the failure and offers three options: retry, continue in current context, or stop and resume later.

## Verification & Remediation

Phase 3 runs domain verifiers (squad + standard/thorough). If verifiers report issues, Phase 3.5 kicks in:

1. Issues are grouped by responsible implementer
2. User approves remediation (or skips/handles manually)
3. Each issue set is routed back to its implementer with instructions to fix only the listed issues
4. Failed verification steps are re-run (not full re-verification)
5. **Capped at 1 remediation cycle** — remaining issues are flagged in the final report

## Session State

Session state lives in `specchain/state/` as structured YAML files:

| File | Contents |
|------|----------|
| `context.yml` | Active spec, last completed group, session summary, next steps |
| `decisions.yml` | Key decisions with date, rationale, and spec reference |
| `blockers.yml` | Active and resolved blockers with severity |
| `sessions.yml` | Session history log (pruned to `max_session_logs`) |
| `patterns.yml` | Reusable patterns discovered during implementation |
| `profiles.yml` | Execution profile used for each spec |

All state files are auto-updated at the end of each implementation session.

## Configuration

### `specchain/config.yml`

```yaml
specchain_version: "1.1.0"

project:
  name: "Your Project"
  description: "Project description"

execution:
  strategy: squad          # solo | squad
  depth: standard          # lean | standard | thorough
  auto_suggest: true       # Analyze complexity and recommend profile

state_tracking:
  enabled: true
  auto_update: true
  state_dir: state         # Directory for state files (relative to specchain/)
  max_decisions: 20
  max_resolved_blockers: 10
  max_session_logs: 10

context_management:
  enabled: true
  advisory_mode: true
  warn_after_task_groups: 3
  fresh_agent_for_depths:
    - thorough
```

## Command Flags

| Flag | Description |
|------|-------------|
| `--solo` | Single agent handles all implementation |
| `--squad` | Multi-agent delegation to specialists |
| `--lean` | Minimal depth: fewer questions, skip verifiers |
| `--standard` | Full pipeline (default) |
| `--thorough` | Maximum rigor: TDD, checkpoints, coverage |
| `--fresh-agent` | Force fresh agent for next task group |
| `--context-report` | Display context summary before implementation |
| `--resume-from <N>` | Resume implementation from task group N |
| `--no-context-split` | Disable mandatory context splitting (solo) |
| `--skip-to <phase>` | Skip to `create` or `implement` phase (`/spec` only) |

### Flag Propagation

Flags are resolved in priority order:

1. **Command flags** (highest) — `/spec --solo --lean`
2. **Per-spec profile** — `planning/execution-profile.yml`
3. **Project config** (lowest) — `specchain/config.yml`

## Editor Support

| Editor | File | Source Template |
|--------|------|----------------|
| Claude Code | `CLAUDE.md` | `governance/claude-md.tmpl` |
| Cursor | `.cursorrules` | `governance/cursorrules.tmpl` |
| Windsurf | `.windsurfrules` | `governance/windsurfrules.tmpl` |

All templates use `${GOV_VAR}` placeholder syntax and are generated during `./setup.sh`. To regenerate manually:

```bash
export GOV_PROJECT_NAME="My Project"
export GOV_PROJECT_DESCRIPTION="What it does"
export GOV_LANGUAGE="TypeScript"
export GOV_FRAMEWORK="Next.js"
export GOV_CMD_INSTALL="npm install"
export GOV_CMD_DEV="npm run dev"
export GOV_CMD_BUILD="npm run build"
export GOV_CMD_TEST="npm test"
export GOV_CMD_TYPECHECK="npx tsc --noEmit"
export GOV_DATE=$(date +%Y-%m-%d)

envsubst < specchain/governance/claude-md.tmpl > CLAUDE.md
envsubst < specchain/governance/cursorrules.tmpl > .cursorrules
envsubst < specchain/governance/windsurfrules.tmpl > .windsurfrules
```

## Tech Stack Presets

Presets provide opinionated coding standards for common stacks. Selected during setup.

| Preset | Includes |
|--------|----------|
| `generic` | Language-agnostic coding style, conventions, error handling, testing |
| `typescript-nextjs` | Default standards in `standards/` (backend, frontend, global, testing) |
| `python-django` | Django models, DRF API conventions, pytest patterns |
| `go` | Go idioms, stdlib-first API patterns, table-driven tests |

Presets live in `specchain/standards/presets/` and are copied into the active `standards/` directory during setup.

## Customization

### Add Custom Standards

Edit files in `specchain/standards/`:
- `global/tech-stack.md` — Your tech stack
- `global/coding-style.md` — Coding conventions
- `frontend/*.md` — Frontend standards
- `backend/*.md` — Backend standards

### Add Custom Agents

Create agent files in `.claude/agents/specchain/` and register them in `specchain/roles/implementers.yml`.

## Governance Templates

Distilled from the Aegis Constitutional AI Governance Framework.

| File | Purpose |
|------|---------|
| `governance/principles.md` | Core principles: scope minimization, behavioral contracts, traceability, boundary validation, graceful degradation, observability |
| `governance/claude-md.tmpl` | CLAUDE.md template with `${GOV_VAR}` placeholders |
| `governance/cursorrules.tmpl` | .cursorrules template with `${GOV_VAR}` placeholders |
| `governance/windsurfrules.tmpl` | .windsurfrules template with `${GOV_VAR}` placeholders |

## Upgrading

To upgrade an existing specchain installation:

```bash
./setup.sh --upgrade /path/to/your/project
```

The `--upgrade` flag:
- Reads `specchain_version` from the existing `config.yml`
- Compares against the new version
- Migrates configuration (e.g., STATE.md to `state/` directory)
- Preserves your custom standards, roles, and governance edits
- Updates `.specchain-manifest` with the installed version and file checksums

## Self-Tests

Validate your specchain installation:

```bash
# Verify all agent files are well-formed
bash test/validate_agents.sh

# Verify governance templates have valid placeholders
bash test/validate_templates.sh

# Verify project structure matches expected layout
bash test/validate_structure.sh
```

## License

MIT

# Specchain

A spec-driven development workflow system for AI-assisted coding. Specchain provides structured specifications, task management, and verification workflows for Claude Code projects.

## Features

- **Spec-driven development** - Define features as specifications before implementation
- **Configurable execution profiles** - Choose who does the work (solo/squad) and how deep (lean/standard/thorough)
- **Task breakdown** - Automatic task grouping with specialist agent assignments (squad) or feature-slice grouping (solo)
- **Verification steps** - Concrete verification criteria for each task group, scaled by depth
- **Session memory** - STATE.md maintains context between sessions
- **Context advisory** - Warns when context accumulates, suggests fresh agents
- **Auto-suggest** - Analyzes spec complexity and recommends an execution profile

## Quick Setup

```bash
# Clone or download specchain
git clone https://github.com/yourusername/specchain.git

# Run setup script
cd specchain
./setup.sh /path/to/your/project
```

Or manually:
```bash
cp -r specchain/ /path/to/your/project/
cp -r .claude/ /path/to/your/project/
```

## Structure

```
your-project/
├── specchain/
│   ├── config.yml              # Execution & workflow configuration
│   ├── STATE.md                # Session memory (auto-updated)
│   ├── product/
│   │   └── roadmap.md          # Product roadmap
│   ├── roles/
│   │   ├── implementers.yml    # Implementer agent definitions
│   │   └── verifiers.yml       # Verifier agent definitions
│   ├── specs/                  # Feature specs go here
│   │   └── [feature-name]/
│   │       ├── spec.md
│   │       ├── tasks.md
│   │       ├── planning/
│   │       │   ├── initialization.md
│   │       │   ├── requirements.md
│   │       │   ├── execution-profile.yml
│   │       │   └── visuals/
│   │       ├── implementation/
│   │       └── verification/
│   └── standards/              # Your coding standards
│       ├── backend/
│       ├── frontend/
│       ├── global/
│       └── testing/
│
└── .claude/
    ├── commands/specchain/     # Slash commands
    │   ├── new-spec.md
    │   ├── create-spec.md
    │   └── implement-spec.md
    └── agents/specchain/       # Agent definitions
        ├── spec-initializer.md
        ├── spec-researcher.md
        ├── tasks-list-creator.md
        ├── spec-verifier.md
        ├── implementation-verifier.md
        └── ...
```

## Usage

### 1. Create a New Spec

```
/new-spec [description]
/new-spec --solo --lean [description]
/new-spec --squad --thorough [description]
```

Initializes a spec folder, gathers requirements through Q&A, and persists the execution profile.

### 2. Generate Spec & Tasks

```
/create-spec
/create-spec --thorough
```

Creates `spec.md` and `tasks.md` from gathered requirements. Runs verification (unless `--lean`).

### 3. Implement a Spec

```
/implement-spec [spec-folder-name]
/implement-spec --solo --lean
/implement-spec --squad --thorough
```

Workflow:
1. Loads session state from STATE.md
2. Resolves execution profile (auto-suggests if enabled)
3. Plans task assignments (squad) or processes directly (solo)
4. Delegates implementation
5. Runs verifications (depth-dependent)
6. Updates STATE.md with session log and execution profile entry

## Execution Profiles

Specchain uses two orthogonal axes to control execution behavior:

### Axis 1 — Strategy: `solo` | `squad`

| Strategy | Description | Agent Model |
|----------|-------------|-------------|
| **solo** | Single agent handles ALL implementation | No agent assignment, no domain verifiers. One agent works through task groups sequentially. |
| **squad** | Multi-agent delegation to specialists | Current behavior — database-engineer, api-engineer, ui-designer, testing-engineer + domain verifiers. |

### Axis 2 — Depth: `lean` | `standard` | `thorough`

| Depth | Spec Creation | Implementation | Verification |
|-------|--------------|----------------|--------------|
| **lean** | 3-5 Q&A questions, skip visual analysis | Skip testing-engineer group | Skip domain verifiers, minimal final verification (tests pass + tasks checked) |
| **standard** | 6-9 questions, full pipeline | Current behavior | Domain verifiers + full final verification |
| **thorough** | 6-9 questions + architecture/testing questions | TDD Red-Green-Refactor per task, phase checkpoints with user confirmation | Domain verifiers + full suite + coverage + manual verification prompts |

### Composition Matrix

| | lean | standard | thorough |
|---|---|---|---|
| **solo** | Fastest path. One agent, minimal checks. | Conductor-like. One agent, full spec pipeline. | Max single-agent rigor: TDD, checkpoints at phase boundaries. |
| **squad** | Fast specialists. Parallel delegation, skip verifiers. | **Current specchain default.** | Full rigor: TDD per agent, phase checkpoints, fresh agents, all verification layers. |

### Common Combos

| Use Case | Flags | Why |
|----------|-------|-----|
| Hotfix / small bug | `--solo --lean` | Fastest path, one agent, minimal ceremony |
| Config change | `--solo --lean` | Infrastructure-only, no UI verification needed |
| Standard feature | *(default)* | Squad + standard is the balanced default |
| Solo developer flow | `--solo --standard` | Full pipeline, single-agent Conductor-like workflow |
| Major feature | `--squad --thorough` | Full rigor with specialists, TDD, phase checkpoints |
| Critical release | `--squad --thorough` | Maximum verification including manual confirmation gates |

## Command Flags

All specchain commands support execution profile flags:

| Flag | Description |
|------|-------------|
| `--solo` | Single agent handles all implementation |
| `--squad` | Multi-agent delegation to specialists |
| `--lean` | Minimal depth: fewer questions, skip verifiers |
| `--standard` | Full pipeline (default) |
| `--thorough` | Maximum rigor: TDD, checkpoints, coverage |
| `--fresh-agent` | Force fresh agent for next task group |
| `--context-report` | Display context summary before implementation |

### Flag Propagation

Flags are resolved in priority order:

1. **Command flags** (highest) — `/implement-spec --solo --lean`
2. **Per-spec profile** — `planning/execution-profile.yml` (persisted when `/new-spec` runs)
3. **Project config** (lowest) — `specchain/config.yml` `execution` section

This means you can set project defaults, override per-spec during `/new-spec`, and override per-invocation with flags.

## Configuration

### `specchain/config.yml`

```yaml
project:
  name: "Your Project"
  description: "Project description"

execution:
  strategy: squad          # solo | squad
  depth: standard          # lean | standard | thorough
  auto_suggest: true       # Suggest profile before /implement-spec

state_tracking:
  enabled: true
  max_decisions: 20
  max_session_logs: 10

context_management:
  enabled: true
  warn_after_task_groups: 3
  fresh_agent_for_depths:
    - thorough
```

### Auto-Suggest

When `auto_suggest: true` and no explicit flags are provided, `/implement-spec` analyzes the spec and recommends a profile:

```
Spec Analysis: 6 tasks, single domain (API), no frontend components.
Recommended: solo + lean
Reason: Small scope, single domain, no UI verification needed.

Accept? Or override with flags (e.g., --squad --standard)
```

Rules:
- Tasks <= 8, single domain -> suggest `solo`
- Tasks > 20 -> suggest `thorough`
- Spec touches >= 2 domains -> suggest `squad`
- Infrastructure/config only -> suggest `solo` + `lean`

The system always prompts — it never silently decides.

### `specchain/roles/implementers.yml`

Define specialist agents for your project:

```yaml
implementers:
  - id: database-engineer
    areas_of_responsibility:
      - Database migrations
      - Database models
    verified_by: backend-verifier

  - id: ui-designer
    areas_of_responsibility:
      - UI components
      - Styling
    verified_by: frontend-verifier
```

## Key Concepts

### STATE.md - Session Memory

Maintains context between sessions:
- **Session Context** - Where you left off
- **Key Decisions** - Important decisions and rationale
- **Active Blockers** - Current blockers
- **Resolved Blockers** - How past blockers were resolved
- **Execution Profiles** - Strategy/depth used for each spec
- **Patterns Established** - Reusable patterns discovered
- **Session Log** - History of work sessions

### Execution Profile File

Each spec has a `planning/execution-profile.yml`:

```yaml
strategy: squad      # solo | squad
depth: standard      # lean | standard | thorough
set_by: new-spec     # which command last set this
```

### Verification Steps

Each task group includes executable verification:

```markdown
**Verification Steps:**
1. Run migration: `npx prisma migrate deploy` - expect success
2. Run tests: `npm test -- --grep "Model"` - expect 0 failures

**Verification Commands:**
```bash
npx prisma migrate deploy
npm test -- --grep "Model"
```
```

### Context Advisory

After completing 3+ task groups, displays:
```
Context Advisory: 3 task groups completed in this session.
Consider using fresh agents for remaining tasks.
```

## Commands Reference

| Command | Description |
|---------|-------------|
| `/new-spec` | Initialize a new spec with requirements gathering |
| `/create-spec` | Generate spec.md and tasks.md from requirements |
| `/implement-spec` | Implement a specification |
| `/plan-product` | Product planning |

## Customization

### Add Custom Standards

Edit files in `specchain/standards/`:
- `global/tech-stack.md` - Your tech stack
- `global/coding-style.md` - Coding conventions
- `frontend/*.md` - Frontend standards
- `backend/*.md` - Backend standards

### Add Custom Agents

Create agent files in `.claude/agents/specchain/`:

```markdown
---
name: my-custom-agent
description: Does custom things
tools: Write, Read, Bash
---

You are a custom agent...
```

Register in `specchain/roles/implementers.yml`.

## License

MIT

# Specchain

A spec-driven development workflow system for AI-assisted coding. Specchain provides structured specifications, task management, and verification workflows for Claude Code projects.

## Features

- **Spec-driven development** - Define features as specifications before implementation
- **Task breakdown** - Automatic task grouping with specialist agent assignments
- **Verification steps** - Concrete verification criteria for each task group
- **Session memory** - STATE.md maintains context between sessions
- **Context advisory** - Warns when context accumulates, suggests fresh agents

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
│   ├── config.yml              # Workflow configuration
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
    │   ├── create-spec.md
    │   └── implement-spec.md
    └── agents/specchain/       # Agent definitions
        ├── tasks-list-creator.md
        ├── implementation-verifier.md
        └── ...
```

## Usage

### Create a New Spec

```
/create-spec
```

Creates a new feature specification with:
- `spec.md` - Feature requirements and design
- `tasks.md` - Task breakdown with verification steps

### Implement a Spec

```
/implement-spec [spec-folder-name]
```

Workflow:
1. Loads session state from STATE.md
2. Plans task assignments to specialist agents
3. Delegates implementation to agents
4. Runs verifications
5. Updates STATE.md with session log

### Flags

| Flag | Description |
|------|-------------|
| `--fresh-agent` | Force fresh agent for next task group |
| `--context-report` | Display context summary before implementation |

## Configuration

### `specchain/config.yml`

```yaml
project:
  name: "Your Project"
  description: "Project description"

workflow:
  default_mode: direct      # direct, selective, thorough
  project_profile: medium   # small, medium, large

state_tracking:
  enabled: true
  max_decisions: 20
  max_session_logs: 10

context_management:
  enabled: true
  warn_after_task_groups: 3
```

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
- **Patterns Established** - Reusable patterns discovered
- **Session Log** - History of work sessions

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

## Commands Reference

| Command | Description |
|---------|-------------|
| `/create-spec` | Create a new feature specification |
| `/new-spec` | Alternative spec creation |
| `/implement-spec` | Implement a specification |
| `/plan-product` | Product planning |

## License

MIT

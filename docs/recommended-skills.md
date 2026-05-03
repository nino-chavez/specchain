# Recommended Claude Code Skills

specchain ships its own slash commands and subagents (see [`.claude/commands/`](../.claude/commands/) and [`.claude/agents/`](../.claude/agents/)). These are project-specific to the spec-driven workflow.

For best results, install these general-purpose skills at the workspace level. specchain references them but does not bundle them.

## Project-bundled (already here)

Located in `.claude/`:

| Command | Purpose |
|---|---|
| `/new-spec` | Initialize a spec folder, run requirements Q&A |
| `/create-spec` | Generate `spec.md` + `tasks.md` from requirements |
| `/implement-spec` | Execute task groups via solo or squad strategy |
| `/spec-diagnose` | Diagnose loop for failing task groups during `/implement-spec`. Wraps the general `diagnose` pattern with specchain context (STATE.md blockers, implementation reports, verifier output) |
| `/plan-product` | Product roadmap planning |

| Subagent | Role |
|---|---|
| `spec-initializer` | Creates dated spec folder, persists execution profile |
| `spec-researcher` | Gathers requirements via depth-aware Q&A; uses codebase-first rule (don't ask if the answer is in code) |
| `spec-writer` | Authors `spec.md` from requirements |
| `tasks-list-creator` | Authors `tasks.md` with HITL/AFK classification per task group |
| `spec-verifier` | Cross-checks spec against requirements; deep reusability audit on `--thorough` |

## Recommended workspace skills (install separately)

### From [matt-pocock/skills](https://github.com/mattpocock/skills) (MIT)

| Skill | Why specchain benefits |
|---|---|
| `tdd` | The `--thorough` depth already enforces TDD inside specchain. Outside specchain (e.g., tweaking the specchain tooling itself), `/tdd` is the right escape hatch. |
| `diagnose` | When `/implement-spec` blocks on a failing task group, run `/diagnose` against the failure rather than retrying. The 6-phase loop (feedback loop → reproduce → hypothesise → instrument → fix → cleanup) finds root causes specchain's verifier can't. |
| `grill-with-docs` | Use *before* `/new-spec` if you're not yet sure what you want — stress-test the idea against any existing CONTEXT.md / ADRs before initializing the spec folder. |
| `triage` | If you've published your project on GitHub Issues, `/triage` complements specchain — incoming issues become input for `/new-spec`. |
| `to-prd` | When a conversation has already happened (no time for `/new-spec`), `/to-prd` captures it as a PRD. Treat as a less-rigorous fallback. |

### Custom workspace skills (Nino's setup)

| Skill | Why |
|---|---|
| `deepen` | Architectural review of specchain's own code (the implementer subagents, the orchestrator commands). Use the deletion test to catch shallow modules. |
| `simplify` | Code review on diffs (built into Claude Code). |
| `zoom-out` | Quick orientation when dropping into an unfamiliar specchain area. |

## Installation

```bash
mkdir -p ~/.claude/skills
git clone https://github.com/mattpocock/skills /tmp/pocock-skills
for skill in tdd diagnose grill-with-docs triage to-prd; do
  cp -r /tmp/pocock-skills/skills/*/$skill ~/.claude/skills/$skill 2>/dev/null
done
```

## Convention: don't bundle general skills

specchain deliberately doesn't redistribute upstream skills. The point of specchain is the *spec-driven workflow* — the commands and subagents above. Bundling general skills bloats the install and creates drift from upstream.

## Lineage

specchain's `--thorough` TDD template, the codebase-first rule in spec-researcher, and the HITL/AFK classification in tasks-list-creator are all **adapted from** patterns in matt-pocock/skills (MIT). The implementations are specchain-native; the techniques are credited to upstream.

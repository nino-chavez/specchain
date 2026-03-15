# Spec Implementation Process

Now that we have a spec and tasks list ready for implementation, we will proceed with implementation of this spec by following this multi-phase process:

PHASE 0: Load session state and context
PHASE 0.5: Resolve execution profile (with conflict detection and auto-suggest)
PHASE 1: Plan the subagent assignments for each task group (squad only)
PHASE 2: Delegate implementation of each task group (with incremental progress tracking)
PHASE 3: Delegate verifications to verifier subagents (squad + standard/thorough only)
PHASE 3.5: Remediation loop — route verifier issues back to implementers (squad + standard/thorough only)
PHASE 4: Produce the final verification report
PHASE 5: Update session state

Follow each of these phases and their individual workflows IN SEQUENCE:

## Preconditions

Before starting, verify these prerequisites exist:
1. At least one spec folder in `specchain/specs/` contains both `spec.md` and `tasks.md` — if not, display: "No spec ready for implementation. Run `/new-spec` then `/create-spec` first." and STOP.
2. `specchain/roles/implementers.yml` exists — if not, display: "Implementer roles not configured. Edit `specchain/roles/implementers.yml`." and STOP.
3. `specchain/state/context.yml` exists — if not, display: "State directory not initialized. Run `./setup.sh` to reinstall." and STOP.

If any precondition fails, do not proceed with any phase.

## Command Flags

This command supports the following optional flags:

**Execution profile overrides:**
- `--solo` | `--squad` — Strategy override
- `--lean` | `--standard` | `--thorough` — Depth override

**Context management:**
- `--fresh-agent` — Force spawning a fresh agent for the next task group
- `--no-context-split` — Disable mandatory context splitting (advanced users only)
- `--context-report` — Display context summary before proceeding with implementation

**Recovery:**
- `--resume-from <N>` — Resume implementation from task group N (skip completed groups)

## Multi-Phase Process

### PHASE 0: Load session state and context

Read the structured state files to understand the current project state:

1. **Read `specchain/state/context.yml`** (always): Understand where work left off, active spec, last completed group
2. **Read `specchain/state/blockers.yml`**: Check active blockers that may affect the current spec
3. **Read `specchain/state/decisions.yml`**: Note any relevant decisions that apply to this implementation
4. **Read `specchain/state/patterns.yml`**: Use established patterns to maintain consistency

If the `--context-report` flag is provided, display a summary of:
- Current session context (from context.yml)
- Active blockers relevant to this spec (from blockers.yml)
- Recent key decisions (from decisions.yml)
- Established patterns that apply (from patterns.yml)

Store the current spec folder path for later state updates.

#### Check for existing progress

Read `specchain/specs/[this-spec]/planning/progress.yml` if it exists.

If progress.yml shows previously completed task groups:
1. Display resume prompt:
   ```
   Found previous progress for this spec:
   - Task Group 1: [Title] — Complete
   - Task Group 2: [Title] — Failed
   - Task Group 3: [Title] — Pending

   Resume from Task Group 2? (y/restart/skip-to-N)
   ```
2. Wait for user confirmation.
3. If resuming, skip completed groups in Phase 2.

If `--resume-from <N>` flag is provided, skip to task group N without prompting.

---

### PHASE 0.5: Resolve Execution Profile

#### Conflict Detection

Before resolving the profile, scan `specchain/specs/*/planning/progress.yml` for any spec (other than this one) with task groups that have `status: in_progress`.

If found, read that spec's `tasks.md` and compare domain overlap with the current spec:
- If both specs touch the same domain (e.g., both have database tasks or both modify the same models/routes), warn:
  ```
  Warning: Spec [other-spec] has in-progress [domain] tasks.
  Concurrent modifications to the same domain may cause conflicts.
  Proceed anyway? (y/n)
  ```
- If no domain overlap, proceed silently.

#### Profile Resolution

1. **Read persisted profile**: Load `specchain/specs/[this-spec]/planning/execution-profile.yml`
2. **Apply command flag overrides**: If `--solo`, `--squad`, `--lean`, `--standard`, or `--thorough` flags were provided, they override the persisted values.
3. **If no profile exists and no flags**: Read defaults from `specchain/config.yml` under the `execution` section.

#### Auto-Suggest (when `auto_suggest: true` AND no explicit strategy/depth flags provided)

If `specchain/config.yml` has `execution.auto_suggest: true` and no explicit flags were passed:

1. **Analyze the spec**: Read `specchain/specs/[this-spec]/tasks.md` and evaluate:
   - `task_count`: Number of top-level task groups
   - `subtask_count`: Total number of sub-tasks across all groups
   - `domain_count`: Number of distinct domains touched (database, API, frontend, testing)
   - `cross_cutting`: Whether tasks reference shared models/services across groups
   - `new_code_ratio`: Ratio of "Create new" vs "Extend existing" language in tasks

2. **Apply weighted suggestion rules**:

   Compute complexity score:
   - **Complexity score** = (`subtask_count` x 1) + (`domain_count` x 3) + (`cross_cutting` ? 5 : 0)

   Apply scoring thresholds:
   - Score <= 15 AND single domain → suggest `solo`
   - Score 16-40 → suggest `squad` + `standard`
   - Score > 40 → suggest `squad` + `thorough`
   - Score <= 10 AND `new_code_ratio` < 0.3 → suggest `solo` + `lean`

   Additional notes:
   - If suggesting `solo` but `task_count` > 5, note: "Automatic context splits will occur after [threshold] groups."

3. **Present recommendation with scoring breakdown to user**:
   ```
   Spec Analysis:
   - Tasks: [N] groups, [M] sub-tasks
   - Domains: [list] (complexity: +[domain_count x 3])
   - Cross-cutting: [yes/no] (+[5 or 0])
   - New code ratio: [X%]
   - Complexity score: [total]

   Recommended: [strategy] + [depth]
   Reason: [rationale based on scoring]

   Accept? Or override with flags (e.g., --squad --standard)
   ```

4. **Wait for user confirmation or override.** Never silently decide.

5. **Store resolved strategy + depth** for all subsequent phases.

If a flag override changed the profile, update `planning/execution-profile.yml` with the new values and set `set_by: implement-spec`.

---

### PHASE 1: Plan subagent assignments

**This phase is conditional on strategy:**

#### If strategy is `solo`: **SKIP Phase 1 entirely.** No agent assignment needed — the orchestrator handles all task groups directly.

#### If strategy is `squad`: Current behavior.

Read the following files:
- `specchain/specs/[this-spec]/tasks.md`
- `specchain/roles/implementers.yml`

Create `specchain/specs/[this-spec]/planning/task-assignments.yml` with this structure:

```yaml
task_assignments:
  - task_group: "Task Group 1: [Title from tasks.md]"
    assigned_subagent: "[implementer-id-from-implementers.yml]"

  - task_group: "Task Group 2: [Title from tasks.md]"
    assigned_subagent: "[implementer-id-from-implementers.yml]"

  # Continue for all task groups found in tasks.md
```

Ensure each assigned subagent exists in both of these locations:
- In implementers.yml there must be an implementer with this role ID.
- In `.claude/agents/specchain` there must be a file named by this implementer ID.

---

### PHASE 2: Delegate task group implementations

Loop through each task group in `specchain/specs/[this-spec]/tasks.md` and delegate its implementation.

#### Strategy: `solo`

Delegate ALL task groups to the orchestrator (self). Process task groups **sequentially**. For each task group, include:
- The full spec file: `specchain/specs/[this-spec]/spec.md`
- STATE.md context (blockers, decisions, patterns)
- The task group with all its sub-tasks

#### Strategy: `squad`

Current behavior — delegate each task group to its assigned specialist subagent from `task-assignments.yml`.

For each delegation, provide the subagent with:
- The task group (including the parent task and all sub-tasks)
- The spec file: `specchain/specs/[this-spec]/spec.md`
- **Relevant state context:**
  - Any active blockers related to this task group (from `specchain/state/blockers.yml`)
  - Key decisions that may affect implementation (from `specchain/state/decisions.yml`)
  - Established patterns to follow (from `specchain/state/patterns.yml`)
- Instruct subagent to:
  1. Perform their implementation
  2. Check off the task and sub-task(s) in `specchain/specs/[this-spec]/tasks.md`
  3. Document their work in an implementation report named and numbered by this task name and placed in `specchain/specs/[this-spec]/implementation/`. The report MUST begin with a structured YAML frontmatter block (see Structured Output Contract below).
  4. Report any new blockers discovered during implementation
  5. Report any new patterns established during implementation

#### Incremental Progress Tracking

After each task group completes (or fails), immediately:
1. Update `specchain/specs/[this-spec]/planning/progress.yml` with status, timestamp, blockers, and patterns for that group.
2. Update `specchain/state/context.yml` with `last_completed_group` number.

This ensures crash recovery is possible — if the session ends unexpectedly, progress.yml records exactly which groups completed.

#### Structured Output Contract

All implementation reports MUST begin with this YAML frontmatter block that the orchestrator parses:

```yaml
---
agent: [agent-id]
task_group: [N]
task_title: "[Task Group Title]"
status: complete          # complete | partial | blocked
completed_subtasks:
  - "[N.1] [subtask description]"
incomplete_subtasks: []   # List any sub-tasks not completed
blockers_discovered:      # Empty list if none
  - title: "[Blocker title]"
    severity: critical    # critical | warning
    affects: "Task [N.N]"
    description: "[What is blocking]"
patterns_established: []  # Empty list if none
files_created: []
files_modified: []
tests_passed: 0
tests_failed: 0
---
```

After parsing the frontmatter:
- If `status` is `blocked`: Add blockers to `state/blockers.yml`, display to user, ask how to proceed.
- If `status` is `partial`: Record incomplete subtasks in progress.yml, warn user before proceeding.
- If `status` is `complete`: Update progress.yml, add patterns to `state/patterns.yml`.

#### Depth modifier: `thorough` (applies to both strategies)

Prepend the following **TDD instruction block** to each task group delegation:

> "For each sub-task in this task group, follow the TDD Red-Green-Refactor cycle:
> 1. **RED** — Write a failing test that defines the expected behavior
> 2. **GREEN** — Write the minimum code necessary to make the test pass
> 3. **REFACTOR** — Clean up the code while keeping all tests green
>
> After completing each sub-task, verify tests pass before proceeding to the next."

**Phase checkpoints (thorough only):** After completing each task group, pause and present a verification prompt to the user:
```
Task Group [N]: [Title] — Complete.
[Brief summary of what was implemented]

Verify and confirm before proceeding to Task Group [N+1]? (y/continue/override)
```
Wait for user confirmation before proceeding to the next task group.

#### Context Management

After completing each task group, track the count of completed task groups in this session.

**`squad` (any depth):**
- `lean` and `standard`: Advisory mode — after `warn_after_task_groups` threshold (default: 3), display context advisory suggesting fresh agents.
- `thorough`: Force a **fresh agent for every task group** (not just after threshold).

**`solo` (any depth):**
- **Mandatory split** (unless `--no-context-split` flag is set): When `task_count` exceeds `warn_after_task_groups` threshold, automatically spawn a fresh agent for remaining groups:
  ```
  Context split: Completed [N] task groups. Spawning fresh agent for remaining
  [M] groups to maintain implementation quality.
  ```
- `thorough` + `solo`: Force a fresh agent at **phase boundaries** (e.g., after data model tasks, before API tasks) AND at the threshold, whichever comes first.
- If `--no-context-split` is used, display warning: "Context splitting disabled. Implementation quality may degrade for later task groups."

**Fresh agent provisioning:** When spawning a fresh agent (by any trigger), provide:
- `specchain/state/context.yml` content (compact session state)
- `specchain/specs/[this-spec]/planning/progress.yml` (completed group tracking)
- Current task group from tasks.md
- Path to spec.md for reference
- List of completed task group names (not full implementation details)

#### Fresh Agent Failure Handling

When spawning a fresh agent for a task group:

1. **Timeout**: If the fresh agent does not begin producing output within 60 seconds, consider the spawn failed.

2. **On spawn failure or agent crash mid-task**:
   - Write to `planning/progress.yml`: `status: failed`, `failure_reason: "agent_spawn_timeout"` (or `"agent_crash"`)
   - Display prompt to user:
     ```
     Fresh agent spawn failed for Task Group [N].
     Options:
     1. Retry fresh agent spawn
     2. Continue in current context (may have degraded quality)
     3. Stop and resume later (/implement-spec --resume-from N)
     ```
   - Wait for user choice.
   - If retrying, provide the fresh agent with any partially completed sub-tasks from progress.yml and instruct it to continue from where the previous agent left off.

3. **Missing or malformed structured output**: If an agent returns a report without valid YAML frontmatter, treat as `status: failed` with `failure_reason: "no_structured_output"` and display the 3-option prompt.

---

### PHASE 3: Delegate verifications to verifier subagents

**This phase is conditional on strategy and depth:**

#### If strategy is `solo` (any depth): **SKIP Phase 3 entirely.** No domain verifiers for single-agent work.

#### If strategy is `squad` + depth is `lean`: **SKIP Phase 3 entirely.**

#### If strategy is `squad` + depth is `standard` or `thorough`: Run verifiers (current behavior).

1. Collect the list of subagent IDs that were delegated to in Phase 2.

2. Read `implementers.yml` and find those subagent IDs. Collect the verifier role IDs specified in their `verified_by` field.

3. If there are verifier roles, ensure those verifiers are defined in `specchain/roles/verifiers.yml`.

4. If there are verifier roles, delegate to each verifier subagent:
   - Collect all task groups that fall under the purview of this verifier (i.e. these tasks' implementers' verified_by specifies this verifier).
   - Provide to the verifier:
     1. Details of those task groups (parent task and sub-tasks) to the verifier for verification.
     2. The spec file: `specchain/specs/[this-spec]/spec.md` for context.
   - Instruct the verifier:
     1. Read and analyze these tasks and where they fit in the context of this spec.
     2. Run tests to verify implementation of these tasks.
     3. Verify whether `specchain/specs/[this-spec]/tasks.md` has been updated to reflect these tasks' completeness.
     4. Document your verification report and place this document in: `specchain/specs/[this-spec]/verification/`

---

### PHASE 3.5: Remediation Loop (squad + standard/thorough only)

**This phase is conditional:** Only runs if Phase 3 verifiers reported issues. Skip entirely if Phase 3 was skipped.

1. **Parse verifier reports**: Read each verification report in `specchain/specs/[this-spec]/verification/`. Check the structured output header for `status: pass_with_issues` or `status: fail`.

2. **If all verifiers report `status: pass`**: Skip to Phase 4.

3. **If issues found**:
   a. Group issues by `responsible_implementer` from the verifier's structured output.

   b. Display remediation summary to user:
      ```
      Verification found [N] issues:
      - backend-verifier: [X] issues (assigned to: [implementer-ids])
      - frontend-verifier: [Y] issues (assigned to: [implementer-ids])

      Run remediation pass? (y/skip/manual)
      ```

   c. If user approves (`y`):
      - Delegate each issue set to the responsible implementer agent
      - Include: the verifier's report, the specific failed items, and instruction: "Fix ONLY the issues listed. Do not refactor or add features."
      - Implementer updates their report frontmatter and appends a "Remediation" section to their implementation report

   d. After remediation: Re-run ONLY the failed verification steps (not full re-verification)

   e. **Cap at 1 remediation cycle.** If issues persist after remediation:
      - Note remaining issues in `planning/progress.yml` under a `remediation` key
      - Proceed to Phase 4 with issues flagged in the final report
      - Do NOT loop indefinitely

4. **Update progress.yml** with remediation results.

---

### PHASE 4: Produce the final verification report

**The scope of verification depends on depth:**

Use the **implementation-verifier** subagent to do its implementation verification and produce its final verification report.

Provide to the subagent the following:
- The path to this spec: `specchain/specs/[this-spec]`
- **The resolved depth** (lean, standard, or thorough)

Instruct the subagent to do the following:
  1. Run all of its final verifications according to its built-in workflow (depth-aware)
  2. Produce the final verification report in `specchain/specs/[this-spec]/verification/final-verification.md`.

---

### PHASE 5: Update session state

Update the structured state files in `specchain/state/` to reflect the completed implementation session:

1. **Update `specchain/state/context.yml`**:
   - Set `last_updated` to current date/time
   - Set `active_spec` to the spec folder that was just implemented
   - Set `last_completed_group` to the last task group number completed
   - Write 2-3 sentence `session_summary` covering: what spec was implemented, overall outcome (success/partial/issues)
   - Set `next_steps` to what should be done next

2. **Update `specchain/state/decisions.yml`**: If any significant decisions were made during implementation, append entries with date, decision, rationale, and spec reference. Prune to `max_decisions` from config.yml.

3. **Update `specchain/state/blockers.yml`**:
   - Move any resolved blockers from `active` to `resolved` list with resolution date and description
   - Add any new blockers discovered during implementation to `active` list
   - Prune `resolved` to `max_resolved_blockers` from config.yml

4. **Update `specchain/state/profiles.yml`**: Append an entry:
   ```yaml
   - spec: "[spec-name]"
     strategy: [strategy]
     depth: [depth]
     date: "[today's date]"
   ```

5. **Update `specchain/state/patterns.yml`**: If any new patterns were discovered or established during implementation, append them to the patterns list.

6. **Update `specchain/state/sessions.yml`**: Append a new session entry with date, session number, summary of work done, execution profile used, and next steps. Prune to `max_session_logs` from config.yml.

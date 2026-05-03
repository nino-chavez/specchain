# Spec Diagnose

Disciplined diagnosis loop for failing task groups during `/implement-spec`. Wraps the general `diagnose` skill (matt-pocock/skills, MIT) with specchain context: STATE.md blockers, implementation reports, verifier output, spec folder structure.

Use when `/implement-spec` flagged a blocker and STATE.md has an active entry that needs root-cause investigation rather than retry.

## When to use

- A task group failed and the implementer wrote a blocker to STATE.md
- A verifier reported a failure that points back to a specific task group
- You're tempted to re-run `/implement-spec` on the same task group hoping it works this time — that's the wrong move; diagnose first.

## Command flags

- `--spec <spec-name>` — spec folder to diagnose (default: most recent in `specchain/specs/*/`)
- `--task <task-id>` — specific task group ID (e.g., `1.3`); defaults to first active blocker in STATE.md
- `--lean` — skip Phase 3 (hypothesise) ranking, jump to single-hypothesis fix; only use when failure mode is unambiguous
- `--no-state-update` — diagnose-only mode; don't write back to STATE.md (useful for dry runs)

## Process

### PHASE 0: Load context

1. Resolve spec folder. If `--spec` not provided, find most recent dated folder in `specchain/specs/`.
2. Read `specchain/STATE.md` — find the most recent active blocker matching this spec (or the one identified by `--task`).
3. Read the failing task group from `specchain/specs/[spec]/tasks.md` — the parent task and all sub-tasks.
4. Read the implementation report at `specchain/specs/[spec]/implementation/[task-name].md` if it exists — capture what the implementer reported.
5. Read any verification report at `specchain/specs/[spec]/verification/` that touches this task group.
6. Read `CONTEXT.md` (project glossary) and any `docs/adr/` files relevant to this area — diagnose grounds in domain language.

If no blocker is found in STATE.md and no `--task` was specified, report that there's nothing to diagnose and stop. Do not invent a failure.

---

### PHASE 1: Build a feedback loop

**This is the skill.** Diagnose does not proceed without a fast, deterministic, agent-runnable pass/fail signal.

For specchain task groups, the loop options in priority order:

1. **The verification commands from `tasks.md`** — every task group has `Verification Commands` defined by the tasks-list-creator. Run them.
2. **The implementation report's "tests run" block** — extract the exact test command, re-run it.
3. **A targeted test at the seam** — write one new test that exercises the failure shape from the user-reported symptom.
4. **Curl/HTTP probe** — for API task failures, hit the endpoint with the failing payload directly.
5. **Headless browser** — for UI task failures, drive the affected component with Playwright; assert on the specific failure (visible bug, not "didn't crash").
6. **Differential** — if the failure appeared after a recent task group, run the same probe at the prior task group's commit SHA; diff outputs.

**A 30-second flaky loop is barely better than none. A 2-second deterministic loop is the goal.** Iterate on the loop itself before proceeding.

If you cannot construct a loop, stop and say so. List what you tried. Ask the user for environment access, captured artifacts, or permission to add temporary instrumentation. Do not move to hypothesise without a loop.

---

### PHASE 2: Reproduce

Run the loop. Watch the failure appear. Confirm:

- [ ] The loop produces the failure mode the **blocker description** captured — not a different failure that happens to be nearby
- [ ] The failure is reproducible across multiple runs (or, for non-deterministic bugs, at high enough rate to debug against)
- [ ] You captured the exact symptom (error message, wrong output, timeout) for Phase 5 verification

Do not proceed until you reproduce.

---

### PHASE 3: Hypothesise

Generate **3–5 ranked, falsifiable hypotheses** before testing any. Each must state its prediction:

> "If <X> is the cause, then <changing Y> will make the bug disappear / <changing Z> will make it worse."

For specchain task failures, the most common hypothesis families are:

| Family | Example |
|---|---|
| **Schema drift** | "Migration didn't run; types are stale" → if true, regenerating types makes it pass |
| **Missing dependency** | "Task Group N depended on Task Group M which wasn't completed" → if true, completing M unblocks N |
| **Verifier mismatch** | "Verification command in tasks.md doesn't match what the implementer actually built" → if true, updating the verification command passes |
| **Spec ambiguity** | "Two interpretations of the requirement; implementer picked one, verifier expects the other" → if true, sharpening the spec resolves the conflict |
| **Environmental** | "Works locally, fails in CI / clean checkout" → if true, isolating env vars/state reveals the missing piece |

If `--lean` is set: skip ranking, jump to the most likely single hypothesis.

**Show the ranked list to the user before testing.** They have domain context that re-ranks instantly. Don't block on the response if they're AFK; proceed with your top rank.

---

### PHASE 4: Instrument

One probe per top hypothesis. Change one variable at a time.

Specchain-specific probe priority:
1. **`STATE.md` Patterns Established section** — does any documented pattern already address this failure mode? If yes, the implementer didn't follow the pattern; that's the fix.
2. **Spec verification report** — did spec-verifier flag any gaps in this area during `/create-spec`? Re-read those flags now.
3. **Reusability research from spec-researcher** — did the spec say "reuse existing module X"? Verify the implementer actually reused it.
4. **Tagged debug logs** with prefix `[SPEC-DIAG-<short-hash>]` if logging is needed. Cleanup is one grep at end.

---

### PHASE 5: Fix + regression

Write the regression test before the fix — but only if there's a correct seam. Specchain seams are usually the verification commands in `tasks.md` (these become the regression test) OR new tests in the project's test suite.

If no correct seam exists: that itself is the finding. The architecture is preventing the bug from being locked down. Note it for Phase 6 — this is when the `deepen` skill becomes the right next move.

If a correct seam exists:
1. Turn the minimised repro into a failing test
2. Watch it fail
3. Apply the fix
4. Watch it pass
5. Re-run the full Phase 1 loop against the original (unminimised) failure scenario

---

### PHASE 6: Cleanup + STATE.md update

Required before declaring done:

- [ ] Original repro no longer fails (re-run the Phase 1 loop)
- [ ] Regression test passes (or absence of seam is documented as a finding)
- [ ] All `[SPEC-DIAG-...]` instrumentation removed (`grep` the prefix)
- [ ] Throwaway harnesses deleted

**STATE.md update** (skipped if `--no-state-update`):

1. Move the diagnosed blocker from **Active Blockers** → **Resolved Blockers** with:
   - Resolution date
   - Root cause (the hypothesis that turned out correct)
   - Fix summary (one sentence)
2. Add to **Key Decisions** if the fix involved a non-obvious choice:
   - Date | Decision | Rationale | Spec/Context reference
3. Add to **Patterns Established** if the diagnosis revealed a pattern that future implementers should follow:
   - Pattern | When to apply | Example link

**Then ask: what would have prevented this bug?**
- If the answer involves architectural change (no good test seam, tangled callers, hidden coupling): hand off to the `deepen` skill with the specifics.
- If the answer involves spec ambiguity: surface as a finding for the next `/create-spec` cycle.
- If the answer involves verification gap: update the tasks-list-creator template to add a verification step that would have caught it.

Make the recommendation **after** the fix is in. Hindsight is sharper than foresight.

---

## Output

A diagnose report at `specchain/specs/[spec]/verification/diagnose-[task-id]-[date].md` containing:

- Blocker description (from STATE.md)
- Phase 1 feedback loop (how it was constructed, command to re-run)
- Phase 2 repro confirmation
- Phase 3 ranked hypotheses (with predictions)
- Phase 4 probe results (which hypothesis was correct)
- Phase 5 fix + regression test reference
- Phase 6 cleanup verification + STATE.md updates applied
- "What would have prevented this" recommendation

## Lineage

The 6-phase loop is adapted from [matt-pocock/skills `diagnose`](https://github.com/mattpocock/skills) (MIT). The specchain-specific scope (STATE.md context, verification command priority, regression test seams in `tasks.md`) is native.

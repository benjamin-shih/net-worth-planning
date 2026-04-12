## Task Weight

Before loading skills or contracts, classify the task:

- **Trivial** (single-file, quick question): Work directly. Skip full graph traversal and handoff. Still load skills implied by file type or project context (e.g., LaTeX skills for .tex files).
- **Standard** (multi-file, single domain): Load contract + relevant skills only.
- **Complex** (multi-domain, multi-session): Full traversal, plan-first, handoff package.

## Automatic Session Binding

- Sessions launched through the shared harness may already have `AGENTS_RUNTIME`, `AGENTS_SESSION_ID`, `AGENTS_PROJECT_ROOT`, `AGENTS_ACTIVE_TASK`, `AGENTS_TASK_BOUND`, and `AGENTS_SHARED_ROOT` set before work begins.
- Codex sessions may auto-discover an active task and hydrate the session with task context. Claude sessions may auto-bind tasks at session start or on prompt submission.
- If `AGENTS_ACTIVE_TASK` is set or startup context identifies a task, read that task's `status.json`, `route.json`, `lease.json`, `events.jsonl`, `plan.md`, and `assumptions.md` before creating parallel notes or plans.
- Respect live leases and explicit handoffs. Do not silently take over a task already claimed by another session.
- Standard or Complex work should use the shared task package; Trivial work should usually stay outside it unless continuity or review is needed.
- Task packages under `/Users/benjaminshih/.agents/tasks/` are operational artifacts, not project deliverables.

## Core Operating Rules
Before doing any work (Standard or Complex tasks):
1. Read `/Users/benjaminshih/.agents/shared/AGENT_OPERATING_CONTRACT.md`.
2. Read `/Users/benjaminshih/.agents/shared/SKILL_SELECTION_POLICY.md`.
3. Read `/Users/benjaminshih/.agents/shared/HANDOFF_PROTOCOL.md`.
4. Read `/Users/benjaminshih/.agents/shared/DOMAIN_QUALITY_GATES.md`.
5. Read `/Users/benjaminshih/.agents/skills/SKILLS.md`, then immediately read `/Users/benjaminshih/.agents/skills/karpathy-guidelines/SKILL.md` and treat it as the default coding/project guidance overlay.
6. If `AGENTS_ACTIVE_TASK` is set or startup context identifies a task, read the bound task package before selecting new work.
7. If the task is project/course-specific, read the corresponding local skills index (for example `<project>/.agents/skills/SKILLS.md`).
8. Traverse the skill graph by links:
   - Load `Depends on` before `Related`.
   - Load foundational skills first, then global machine skills, then project/course-specific skills.
9. List the exact skills selected and why.
10. For complex tasks, provide a plan before execution.
11. Follow all `ALWAYS`/`NEVER` rules in loaded skills.
12. If assumptions are needed, state them explicitly; if uncertain, mark uncertainty and propose safe alternatives.
13. During long tasks, summarize state every 2-3 major steps.

## Cross-Runtime Note
- If the same project also has a `CLAUDE.md`, keep it aligned with the same shared `.agents/shared/` contract instead of maintaining a separate operating philosophy.
- Use `/Users/benjaminshih/.agents/tasks/<task-id>/` for cross-runtime handoff when work moves between Codex and Claude.

## QMD Retrieval Policy
- Prefer `qmd` for skill/lesson/task markdown discovery.
- If qmd query/database fails in sandbox (`SQLITE_CANTOPEN`, `SQLITE_BUSY`, or permission failures):
  1. Retry with writable cache root (example: `XDG_CACHE_HOME=<writable_path> qmd ...`).
  2. If still failing, escalate qmd commands outside sandbox.
- If qmd remains unavailable, fallback to `rg`.

## Global Workflow Orchestration (Dispatch)
If user asks to run a workflow in natural language (for example: "start debugging workflow", "run debugging triad", or "start <workflow> workflow for this codebase"), automatically invoke dispatch workflow orchestration. Do not ask the user to run commands.

### Mandatory discovery
Before concluding no workflow exists, scan:
- `/Users/benjaminshih/.agents/dispatch/workflows/`
- `/Users/benjaminshih/.agents/roles/`

### Mandatory execution behavior
1. Resolve the best-matching workflow.
2. Infer target project root from context; if ambiguous, ask one concise clarification question.
3. Launch dispatch runner directly.
4. Stream concise progress updates.
5. Return merged final results when the workflow completes.

### Runner path and defaults
- Runner: `/Users/benjaminshih/.agents/dispatch/scripts/run_workflow.py`
- Default worker mode: full permissions (`codex -a never exec -s danger-full-access ...`).
- Runtime: tmux-backed worker windows.
- Canonical run artifacts: `~/.agents/dispatch/runs/<run_id>/`
- Project pointer bootstrap: `<project>/.agents/runs/<run_id>` symlink (or JSON pointer fallback).

### Example auto-invocation command (agent runs this, not user)
```bash
python3 /Users/benjaminshih/.agents/dispatch/scripts/run_workflow.py \
  --workflow debugging_triad \
  --project-root <absolute-project-root>
```

## Net Worth Workbook

Primary workbook:
- `/Users/benjaminshih/Desktop/Net-Worth-Planning/Net Worth.xlsx`

Before answering questions about the workbook or editing it, read these continuity files:
1. `/Users/benjaminshih/Desktop/Net-Worth-Planning/net-worth-workbook-handoff.md`
2. `/Users/benjaminshih/Desktop/Net-Worth-Planning/todo.md`
3. `/Users/benjaminshih/Desktop/Net-Worth-Planning/progress-log.md`
4. `/Users/benjaminshih/Desktop/Net-Worth-Planning/tasks/lessons.md`
5. `/Users/benjaminshih/Desktop/Net-Worth-Planning/career-financial-planning-memo.md`

There is also a compact Codex memory at:
- `/Users/benjaminshih/.codex/memories/personal-net-worth-career-plan.md`

## Operating Notes

- Keep all workbook sheets visible. Hidden-sheet shortcuts were explicitly rejected.
- On `Savings Projection`, column `B` is `Gross Comp (output)` and column `BC` is `Gross Comp Input`. Do not turn `B` into a manual input path; that previously caused circular references and stale propagation.
- Older handoff notes mention a test override at `Savings Projection!BC29 = 5000000`, but live inspection on 2026-04-11 showed `BC29` empty and `B29` blank/no formula. Verify the live workbook before relying on either state.
- If editing the workbook on disk with `openpyxl`, close the workbook in Excel first, patch the file, then reopen and save through Excel to refresh cached values. Saving an already-open stale workbook over on-disk edits caused mismatches during debugging.
- Prefer JXA (`osascript -l JavaScript`) over ad hoc AppleScript for Excel open / close / save operations on this machine.
- Do not create backup workbook copies unless the user explicitly asks for them.

## Career / Financial Planning Context

The user wants this folder and workbook to serve as a long-running planning system over future years. The core goal is to track whether their quant-finance career path can support early financial independence, a Bay Area return, and a high-end home purchase.

Use `/Users/benjaminshih/Desktop/Net-Worth-Planning/career-financial-planning-memo.md` for the detailed assumptions and rough conclusions from the 2026-04-11 discussion, including:
- `$7M` vs `$5M` Bay Area home cases.
- Immediate retirement vs buying while continuing to work.
- Noncompete pay modeled as temporary base-salary income when working outside finance, not as spendable deferred bonus and not as a blocker to a non-finance Bay Area job.
- The difference between baseline quant IC, 3-5 YOE switching / guarantee, PM / pod economics, and startup / seed-round paths.
- The need to keep PM-path assumptions tied to actual attributable PnL, capacity, risk discipline, and portability as the user's career develops.

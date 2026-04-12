# CLAUDE.md

Local supplement for `/Users/benjaminshih/Desktop/Net-Worth-Planning`.

Read `/Users/benjaminshih/.claude/CLAUDE.md` first, then use this file for workbook-specific continuity.
Default coding/project guidance skill: `/Users/benjaminshih/.agents/skills/karpathy-guidelines/SKILL.md` (loaded by the shared bootstrap).

## Net Worth Workbook

Primary file:
- `/Users/benjaminshih/Desktop/Net-Worth-Planning/Net Worth.xlsx`

Before touching the workbook, read these files in order:
1. `/Users/benjaminshih/Desktop/Net-Worth-Planning/net-worth-workbook-handoff.md`
2. `/Users/benjaminshih/Desktop/Net-Worth-Planning/todo.md`
3. `/Users/benjaminshih/Desktop/Net-Worth-Planning/progress-log.md`
4. `/Users/benjaminshih/Desktop/Net-Worth-Planning/tasks/lessons.md`
5. `/Users/benjaminshih/Desktop/Net-Worth-Planning/career-financial-planning-memo.md`

## Operating Notes

- Keep all workbook sheets visible. Hidden-sheet shortcuts were explicitly rejected.
- On `Savings Projection`, column `B` is `Gross Comp (output)` and column `BC` is `Gross Comp Input`. Do not try to turn `B` back into a manual input path; that caused circular references and stale propagation.
- Older handoff notes mention a test override at `Savings Projection!BC29 = 5000000`, but live inspection on 2026-04-11 showed `BC29` empty and `B29` blank/no formula. Verify the workbook before relying on either state.
- If editing the workbook on disk with `openpyxl`, close the workbook in Excel first, patch the file, then reopen and save through Excel to refresh cached values. Saving an already-open stale workbook over on-disk edits caused mismatches during debugging.
- Prefer JXA (`osascript -l JavaScript`) over ad hoc AppleScript for Excel open / close / save operations on this machine.
- Do not create backup workbook copies unless the user explicitly asks for them.

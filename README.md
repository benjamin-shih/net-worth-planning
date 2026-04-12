# Net Worth Planning

Personal financial planning workbook and continuity notes for long-running net worth, compensation, Bay Area home purchase, and early-retirement modeling.

## Primary Workbook

- `Net Worth.xlsx`

## Supporting Notes

- `net-worth-workbook-handoff.md`
- `career-financial-planning-memo.md`
- `progress-log.md`
- `todo.md`
- `tasks/lessons.md`
- `AGENTS.md`
- `CLAUDE.md`

## Workflow

Before editing the workbook, read `AGENTS.md` and the continuity files listed there.

Run a lightweight repository check with:

```bash
uv sync
make validate
```

The validation checks that the workbook is present and structurally readable as an `.xlsx` zip package, and that the core continuity files are present. It does not recalculate Excel formulas; use Excel/JXA for workbook recalc when formulas change.

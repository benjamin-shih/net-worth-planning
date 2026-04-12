# Lessons

## 2026-04-09

### Failure
Trying to let the visible gross-comp output column also behave like a manual input path created circular references and stale propagation.

### Root Cause
`Savings Projection!B:B` already depends on modeled comp formulas. Making upstream formulas inspect `B` to detect manual inputs created a self-referential path.

### Prevention Rule
Do not make the same workbook column both the displayed output and the canonical manual input. Use a dedicated visible input column instead.

---

### Failure
Derived working years previously stopped at the first blank / `Retired` row, so later filled years could disappear from scenarios.

### Root Cause
The workbook used first-gap logic (`MATCH("Retired", ...)`) instead of last-working-year logic.

### Prevention Rule
When users may extend a model non-contiguously, derive horizon state from the last active row, not the first inactive row.

---

### Failure
Late-year activated rows could silently zero out rent and living costs.

### Root Cause
Rows beyond the originally populated horizon had blank cost inputs but were allowed to become `Working`.

### Prevention Rule
If later rows can be activated dynamically, carry forward the latest nonblank recurring-cost assumptions or give them explicit defaults.

---

### Failure
Affordability summaries understated the benefit of working additional years after a house purchase.

### Root Cause
Some scenario summary cells were indexed to purchase year when they should have been indexed to retirement year for sustainability metrics.

### Prevention Rule
Keep purchase-close constraints and retirement-sustainability constraints separate, and index each to the correct lifecycle year.

---

### Failure
On-disk workbook edits could appear to revert or partially disappear after reopening Excel.

### Root Cause
Excel sometimes kept an older in-memory workbook open and could save that stale state back over the patched file.

### Prevention Rule
Before writing workbook structure with `openpyxl`, close the Excel workbook first. After editing, reopen from disk and save through Excel to refresh cached values.

---

### Failure
AppleScript interactions with Excel were inconsistent during reopen / save workflows.

### Root Cause
The machine handled some Excel actions more reliably through JXA than through ad hoc AppleScript snippets.

### Prevention Rule
Prefer `osascript -l JavaScript` for Excel open / close / save automation on this machine when deterministic workbook lifecycle control matters.

---

### Failure
A scenario-sheet control cell overlapped an existing threshold table row, causing the intended default IC bump control to be overwritten by the `$5M` home-price input.

### Root Cause
The new PM sheet reused the threshold table's row range for both controls and threshold outputs instead of reserving a separate control block.

### Prevention Rule
When adding new scenario-sheet controls, reserve a non-overlapping visible control block first, then wire summary/helper formulas to that block and spot-check the control cell cached values before recalc.

---

### Failure
A scenario helper table used the same row for helper headers and first data row, so the first helper data row overwrote the visible header.

### Root Cause
The helper-row start variable was set to the header row instead of the first data row below the header.

### Prevention Rule
When building scenario helper tables, reserve distinct constants for `header_row` and `data_start_row`, then inspect both the header row and the first data row before recalculation.

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

---

### Failure
A single stray literal in a scenario helper row caused cached `#VALUE!` errors to spill into a PM summary row after Excel recalculation.

### Root Cause
`PM After Switch!H227` contained the text `e` where adjacent helper rows used a formula reference to the summary input cell.

### Prevention Rule
After Excel recalculation, scan cached workbook values for formula-error literals across all sheets, not just the sheet being edited. If errors appear in a helper block, compare the same column in adjacent rows before assuming the summary formula is the source.

---

### Failure
Adding a Y15 summary block replaced the existing Y10 scenario readouts instead of preserving them.

### Root Cause
The summary-table rewrite treated Y15 as a replacement horizon rather than an additive comparison horizon, even though the user still wanted the Y10 decision snapshot.

### Prevention Rule
When adding a new planning horizon to a scenario sheet, preserve existing horizon readouts unless the user explicitly asks to remove them. Add the new horizon as a separate labeled block and keep helper-range caps independent from summary-display choices.
---

### Failure
Switch scenario formulas applied the pay bump immediately after the switch year and multiplied later baseline cash comp, so pre-switch projection years and post-switch compensation timing looked economically inconsistent once the two-year noncompete was considered.

### Root Cause
The scenario helper treated `Switch After YOE` as a simple formula breakpoint rather than a lifecycle phase with Jump years, base-only noncompete years, and a separate new-firm start. It also used cash-gross timing as the bump anchor instead of the switch-year package.

### Prevention Rule
For career-transition scenario sheets, model phase gates explicitly: baseline through the completed switch YOE, base-only noncompete for the specified duration, then apply the new-firm package anchored to the switch-year base plus accrued bonus. Keep helper notes clear when projection rows begin before the actual transition.

---

### Failure
Scenario summary formulas calculated correctly but some newly added dollar columns kept `General` formatting, while some year/YOE fields inherited compact dollar formatting from neighboring financial columns.

### Root Cause
The workbook validation focused on formulas, cached values, and sheet visibility, but did not include a number-format audit after adding and rewiring summary/helper blocks.

### Prevention Rule
After spreadsheet formula or structural edits, audit number formats on all affected sheets before delivery. For financial models, explicitly verify currency-intent columns use dollar formats and year/YOE/counter columns use integer/text formats; cached formula correctness alone is not enough.

---

### Failure
A workbook patch script failed before saving because it attempted to assign cell values while iterating over merged-cell placeholders.

### Root Cause
`openpyxl` exposes non-anchor merged cells as read-only `MergedCell` objects, but the formula rewrite loop treated every cell object as writable.

### Prevention Rule
When bulk-editing workbooks with merged titles or section headers, skip `MergedCell` objects and write only to normal cell anchors.

---

### Failure
A workbook patch script failed before saving when adding data validation over a space-separated multi-range string.

### Root Cause
`openpyxl`'s `DataValidation.add()` expects a single coordinate/range per call, even though Excel validation references can represent multiple ranges.

### Prevention Rule
When applying one data validation rule to multiple disjoint ranges, split the range string and add each range to the validation object separately.

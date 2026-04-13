# Progress Log

## 2026-04-12 (session 17) - jump baseline comparison and scenario-surface cleanup

Context:
- User wanted a fixed `Stay at Jump` baseline added to the scenario comparison flow.
- User also wanted the house-target wording clarified, and felt that `Scenario Analysis` and `Scenario Pivot Lab` still looked rough relative to the rest of the workbook.

Implementation:
- Extended `Scenario Results` so `tblScenarioResults` now includes two additional normalized rows:
  - `Stay at Jump | Base | Y10`
  - `Stay at Jump | Base | Y15`
- Sourced those baseline rows directly from `Savings Projection`, including liquid net worth, taxable liquid, retirement balance, target-gap formulas, and first-crossing formulas through Y15.
- Renamed the normalized target-gap headers away from ambiguous `vs ...` wording to:
  - `Surplus / Shortfall to $5M All-Cash Target`
  - `Surplus / Shortfall to $5M 50% Down Target`
  - `Surplus / Shortfall to $7M All-Cash Target`
  - `Surplus / Shortfall to $7M 50% Down Target`
  - `Target Status`
- Reworked `Scenario Analysis` into a three-way compare surface:
  - `Primary`
  - `Comparison`
  - `Stay at Jump (Base)`
  - plus explicit delta columns for `Primary - Comparison`, `Primary - Jump Base`, and `Comparison - Jump Base`
- Extended the analysis chart-data block so both charts now include the fixed Jump baseline series.
- Simplified `Scenario Pivot Lab` into a cleaner utility sheet with a tighter visible surface for Y10 / Y15 liquid-net-worth cuts.
- Preserved native sparkline XML during the final aesthetics save by passing a preserved pre-edit workbook as the source of unsupported sheet extensions instead of restoring from the already-edited file.

Verification:
- `uv sync` completed successfully.
- `uv run python -m py_compile scripts/enhance_workbook_low_risk.py scripts/enhance_workbook_advanced.py scripts/enhance_workbook_aesthetics.py` passed.
- Ran the workbook rebuild pipeline:
  - `uv run python scripts/enhance_workbook_low_risk.py`
  - `uv run python scripts/enhance_workbook_advanced.py --phase 3`
  - `NET_WORTH_NATIVE_FEATURE_SOURCE=... uv run python scripts/enhance_workbook_aesthetics.py`
  - `./scripts/validate.sh`
- Verified structurally with `openpyxl` and zip inspection:
  - workbook sheet order is now `Financial Dashboard`, `Scenario Analysis`, `Scenario Pivot Lab`, `Model Inputs`, `Savings Projection`, `Scenario Lab`, `IC Switch Scenarios`, `PM After Switch`, `Scenario Results`, `Tax Assumptions`
  - `tblScenarioResults` now spans `A4:U64`
  - `Scenario Results` keeps the sparkline `extLst` block after the rebuild
  - pivot cache / pivot table package parts remain present
  - baseline rows are present at rows 63 and 64 with formulas linked to `Savings Projection`
  - dashboard labels now use the clearer house-target wording and `Target Status`
- Native Excel open/save recalc was not completed in this session because both AppleScript and JXA calls against the live Excel process hung. The workbook is still flagged for full recalculation on open/save.

## 2026-04-12 (session 14) - workbook cleanup and UX pass

Context:
- User asked to fix all findings from the workbook review and run an aesthetics / UX pass, using subagents to refine ideas.

Implementation:
- Replaced hardcoded switch-scenario calendar-year formulas with `Model Inputs!B22`-linked formulas.
- Fixed `Tax Assumptions!A1`.
- Pruned duplicate `5Y -> PM Y7` rows/helper blocks from `PM After Switch` because the two-year noncompete makes them identical to effective `5Y -> PM Y8`.
- Added validation/dropdown guardrails on key editable model controls and scenario inputs.
- Added summary auto filters, tab colors, gridline-off polish, outline grouping for helper blocks, and notes clarifying that the lower `Scenario Lab` frontier engine is live dashboard support.

Verification:
- Recalculated and saved through Excel, then closed Excel.
- `make validate` passed.
- Verified all sheets visible, no lock file, no cached formula errors, no unsupported formula tokens, no remaining hardcoded `2025+` formulas, no formulas referencing the removed PM helper tail, and targeted scenario sheets have zero numeric `General` formatting drift.

## 2026-04-12 (session 13) - scenario sheet number-format cleanup

Context:
- User flagged that the new scenario sheets had formatting drift: some dollar outputs were still `General`, and some YOE/year fields had inherited currency-style formats.

Implementation:
- Audited number formats across all workbook sheets.
- Corrected `IC Switch Scenarios` Y15 summary dollar columns and helper YOE/year columns.
- Corrected `PM After Switch` Y15 summary dollar columns, summary YOE columns, and helper projection/calendar-year columns.
- Updated the global `spreadsheet` skill to require an all-sheet number-format audit after formula or structural workbook edits.

Verification:
- Recalculated and saved through Excel via JXA, then closed Excel.
- Verified no cached formula errors, all sheets visible, no Excel lock file, and `make validate` passes.
- Verified the targeted scenario summary/helper ranges have zero format errors; `IC Switch Scenarios` and `PM After Switch` now have zero numeric cells left with `General` format.

## 2026-04-12 (session 12) - switch/noncompete timing correction

Context:
- User clarified that a switch after 3/4/5 YOE means the selected Jump years complete first, then two years of noncompete pay only, and only then the new firm package starts.
- Noncompete pay should be base salary only. The pay bump should be applied to the switch-year package (base + FY bonus accrued), not to each later baseline cash-comp year.

Implementation:
- Added visible noncompete-year controls to `IC Switch Scenarios` and `PM After Switch` at `J18 = 2`.
- Rewired `IC Switch Scenarios` helper formulas: baseline through switch year, base-only during noncompete, switch-year package x bump after noncompete through Y8, then post-Y8 plateau.
- Rewired `PM After Switch` helper formulas: baseline through first switch year, base-only during noncompete, IC switch package x bump before PM, and PM comp only at or after `MAX(requested PM start, first switch YOE + noncompete years + 1)`.
- Updated helper-block notes to explain why projection rows begin at Y1/CY2026 even though the switch starts later.

Verification:
- Recalculated and saved through Excel via JXA, then closed Excel.
- Verified no cached formula errors, all sheets visible, no Excel lock file, and `make validate` passes.
- Spot-checked phase behavior: 3Y IC cases now have Y4-Y5 base-only and Y6 first boosted year; 5Y IC cases now have Y6-Y7 base-only and Y8 first boosted year; 5Y PM requested Y7 is delayed to Y8 and matches requested Y8.

## 2026-04-11 (session 7) — IC switch scenario sheet

Context:
- User wanted to revisit 3-5 YOE Jump job-switch scenarios in the workbook, with 2x-4x IC quant compensation bumps, while keeping the response and scenario work separate from the core model.

Design:
- Added a new visible sheet: `IC Switch Scenarios`.
- The sheet has:
  - assumptions section,
  - `$5M` / `$7M` all-cash and 50%-down house + immediate-retirement thresholds,
  - 9-row scenario summary for switch after 3/4/5 YOE and 2x/3x/4x bump,
  - visible Y1-Y30 helper model for auditability.
- The helper rebuilds the baseline IC cash-comp path from `Model Inputs`, applies the selected bump after the switch year, and then uses the existing tax tables, rent/living assumptions, retirement contributions, and base return.
- Gross walk-away `BK` is shown separately and not deducted, because exact buyout / deferred comp forfeiture / noncompete tax timing is not modeled in this sheet.

Implementation:
- Added `IC Switch Scenarios` between `Scenario Lab` and `Tax Assumptions`.
- Did not modify the core sheets' formulas.
- Initial first-crossing formulas used `MINIFS`, but Excel cached those as `#NAME?` in this workbook context.
- Replaced first-crossing logic with visible helper columns `Y:AB` that flag the first crossing year, then summary columns use `SUMIFS`, which verified cleanly.

Verification:
- Recalculated and saved through Excel via JXA, then closed Excel.
- Verified with `openpyxl`:
  - sheet is visible and all sheets remain visible,
  - `IC Switch Scenarios` summary rows cache correctly,
  - no `#NAME?` in first-crossing columns after the helper-column fix,
  - no `~$Net Worth.xlsx` lock file remains.
- Current base-home threshold values from the sheet:
  - `$5M` all-cash: about `$14.0M`;
  - `$5M` 50% down: about `$16.9M`;
  - `$7M` all-cash: about `$17.3M`;
  - `$7M` 50% down: about `$21.4M`.


## 2026-04-11 (session 6) — IC quant median compensation calibration

Context:
- User reported updated IC quant path assumptions from conversations: median case is roughly $1.0M-$1.5M by Y5 and $1.5M-$3.0M by Y8, with much larger Y8 upside tails possible.
- Existing workbook was a tranche-aware cash model. Compensation market quotes are better interpreted as annual total comp earned/accrued, not the delayed cash received after 50/25/25 deferral.

Design:
- Calibrated the pre-swing `AU` Trend Bonus path to the midpoint of those ranges: about $1.25M total trend comp in projection year 5 and about $2.25M total trend comp in projection year 8.
- Preserved existing model semantics:
  - `B` / `BB` remain cash gross comp outputs.
  - `AY` remains FY bonus accrued.
  - `BJ` remains bonus cash received.
  - `BK` remains unvested deferred comp / walk-away cost.
  - `BC` remains the manual gross-comp input path.
- Left the existing 12% swing layer in place, so actual accrued totals in Y5/Y8 are below the midpoint trend targets because both rows land on negative swing points.

Implementation:
- Set `Model Inputs!B28` early bonus growth from 35.0% to 45.3%.
- Set `Model Inputs!B29` later bonus growth from 22.0% to 27.1%.
- Added comments on `Model Inputs!B28:B29` and updated `Model Inputs!J24` to document the IC median calibration and the distinction between accrued trend comp and cash received.
- Restored the missing `Savings Projection!B29` output formula to `=IF(BB29="","",BB29)`. This does not change current outputs because `BC29` and `BB29` are blank, but it keeps future year-11 inputs propagating.

Verification:
- Recalculated and saved through Excel via JXA, then closed the workbook.
- Verified refreshed cached values with `openpyxl`:
  - `Model Inputs!B28 = 45.3%`; `B29 = 27.1%`.
  - Y5 / CY2030: trend total comp $1.25M; accrued total comp $1.15M after negative swing; cash gross comp $954K.
  - Y8 / CY2033: trend total comp $2.25M; accrued total comp $2.05M after negative swing; cash gross comp $1.87M.
  - Y10 / CY2035: cash gross comp $2.60M; base total wealth $6.43M.
  - `Savings Projection!B29` has the normal output formula; `BC29` remains empty.


## 2026-04-10 (session 5) — Rent + living-cost inflation drivers

Context:
- User asked whether the current spend level (~$118–130K/yr) is reasonable given the earnings path. Spend itself is conservative (33–45% save rate), but the model held rent and living costs flat in nominal terms, which understated late-year spend. User picked option (a): add inflation drivers.

Design:
- Separate "real $" inputs from "nominal display" columns so user can edit in today's dollars and let the model compound.
- New Model Inputs at `B35` (rent inflation, 3%) and `B36` (living-cost inflation, 3%), blue inputs with % format.
- New Savings Projection columns `BL` (Rent real $) and `BM` (Living real $) holding the prior literals for rows 19–28 and the same `LOOKUP` carry-forward pattern for rows 29–58.
- Rewrote `S` and `T` as pure display formulas: `=IF(C_r="Working", IF(BL_r="","", BL_r * (1+'Model Inputs'!$B$35)^(AN_r-1)), "")` and the parallel for `T`/`BM`/`B$36`.
- Renamed `S18` → "Rent (nominal)", `T18` → "Other Living Costs (nominal)" to make the semantics explicit.

Cross-sheet audit:
- Grepped every sheet for `Savings Projection!S` / `!T` references. Only `Scenario Lab` reads them (J32:K58 for nominal rent/living × scenario multiplier). Leaving S/T as the inflated nominal columns means Scenario Lab automatically picks up inflated values — exactly what we want.

Implementation:
- Quit Excel via JXA, cleared any lock.
- Cloned label/input styles from the existing comp rows.
- Added inflation inputs + BL/BM columns + S/T rewrites via openpyxl in one pass.
- Added cell comments on `B35`, `B36`, `BL18`, `BM18` explaining the real-vs-nominal convention.
- Reopened in Excel, forced recalc, saved, closed.

Verification (cached):
| yr | BL real | BM real | S nom | T nom | Post-tax | Cash After | Save rate |
|---|---|---|---|---|---|---|---|
| 1 | $78K | $40K | $78.0K | $40.0K | $302.7K | $184.7K | 38.0% |
| 5 | $78K | $50K | $87.8K | $56.3K | $487.7K | $343.7K | 40.2% |
| 10 | $80K | $50K | $104.4K | $65.2K | $1,002.5K | $832.9K | 42.9% |

Save rate in year 10 dropped from 44.9% → 42.9% (~2 pts), consistent with the expected drag from compounding rent/living at 3% over 10 years. Scenario Lab and Dashboard read downstream from S/T so they automatically benefit.



## 2026-04-10 (session 4) — Tranche-aware 50/25/25 bonus model + walk-away readout

Context:
- User pointed out that the session-2 / session-3 "lump the entire FY bonus into the next calendar year" simplification did not actually reflect the 50/25/25 deferred schedule in the offer letter, and asked whether the "golden handcuffs" stacking effect was already visible. It wasn't.
- User confirmed the FY2026 guarantee is pro-rated by 4/12 (not full $450K).
- User asked for both: (a) a tranche-aware cash model that splits each FY bonus 75/25 across two calendar years, and (b) a year-end walk-away readout showing unvested deferred comp.

Cycle 1: cross-sheet reference audit
- Searched every sheet for formulas referencing `Savings Projection!AY/BB/B/AX/AU/AV/AW`.
- Only `Savings Projection!B` is referenced externally (Financial Dashboard, Model Inputs, Scenario Lab — 370+ cells). Nothing reads AY / BB / AX directly off-sheet.
- Conclusion: flipping AY from cash-basis to accrual-basis is safe as long as the B column continues to reflect cash gross comp via BB.

Cycle 2: design
- Accrual layer: repurpose AU / AV / AY to represent FY accrued bonus (what was earned in that FY).
- Cash layer: new column BJ = 0.75 × AY(r-1) + 0.25 × AY(r-2), the 75/25 tranche sum.
- Walk-away readout: new column BK = AY(r) + 0.25 × AY(r-1) — full just-finished FY accrual (nothing paid yet as of Dec 31) + 25% tail from prior FY (the 12-month Mar 15 tranche still ahead).
- Rewire BB to use BJ instead of AY for the bonus component. Rewire BD (session-3 actuals) with the same 75/25 structure using BE overrides where present and AY fallback otherwise. Drop the session-3 `BE × stub_factor` multiplier since accruals in BE are now entered post-proration.

Cycle 3: implementation
- Quit Excel via JXA and cleared the `~$Net Worth.xlsx` lock.
- Patched with openpyxl:
  - Updated AU formula to produce AN=1 → stub × B$27, AN=2 → B$27, AN≥3 → early/late ramp.
  - Updated AV swing suppression from AN≤3 to AN≤2.
  - Simplified AY formula to pure accrual (dropped the BC-derived back-solve path).
  - Repinned AX19 = 150000, AX20 = 450000, cleared AX21.
  - Added BJ column with 75/25 tranche formula (row 19 = 0, row 20 = one-sided).
  - Added BK column with year-end walk-away formula.
  - Rewrote BB to gate on BJ (not AY) in the "any signal" check and to use BJ in the cash sum.
  - Rewrote BD to use 75/25 tranche math, preserving the actuals override precedence.
  - Renamed headers: AX18 = "FY Bonus Accrual Override", AY18 = "FY Bonus Accrued".
  - Rewrote the AN5 help note to document the new model.
  - Added cell comments on AY18 / BJ18 / BK18 explaining semantics.

Cycle 4: verification
- Reopened in Excel, forced recalc, saved.
- Cached values matched expectations exactly:
  - Row 19 (CY2026): B=550K, AY=150K, BJ=0, BK=150K
  - Row 20 (CY2027): B=412.5K, AY=450K, BJ=112.5K, BK=487.5K
  - Row 21 (CY2028): B=675K, AY=450K, BJ=375K, BK=562.5K
  - Row 22 (CY2029): B=750K, AY=670,633 (AV swing fires), BJ=450K, BK=783K
- Discovered pre-existing bug: B29 and B30 had no formula at all (likely leftover from session 1's literal `B29 = 5000000` stress-test that was never restored). Every other row in B19:B58 had `=IF(BBxx="","",BBxx)`. This meant BC29's $5M override was not propagating through the B column to the scenario lab / dashboard, even though BB29 held the right value.
- Fixed by restoring B29 and B30 formulas with matching cell styles cloned from B28.
- Re-verified: B29 = BB29 = 5,000,000; B30 = blank (no inputs).

Cycle 5: docs
- Updated `net-worth-workbook-handoff.md` with the session-4 tranche model, new verified cached values, and the B29/B30 gap fix.
- Appended this entry to the progress log.
- Updated todo.md to close the "FY2026 proration confirmation" question and the session-4 items.



## 2026-04-09 (session 3) — Realized Comp (Actuals) input block

Context:
- User wants to pin realized compensation as fiscal years close (e.g. actual FY2027 bonus once known, then FY2028, etc.) while keeping the planning model running for future years.
- Realized comp must follow the same deferred structure: an FY bonus earned in year N pays in calendar year N+1, with FY2026 pro-rated by (13 − start_month)/12 to match the existing stub logic.

Cycle 1: design
- Reviewed existing `Savings Projection` compensation schedule (AN:BC).
- Chose to add a new actuals block at `BD:BI` without touching the existing AR/AX/BA pins or the BC stress-test override, so planning and actuals remain cleanly separated.
- Precedence in the rewritten `BB` formula: BD (actuals) > BC (stress-test) > modeled (AT + AY + AZ + BA).
- Component-level fallback inside BD: each of base, bonus, and other falls back to its modeled value when the corresponding actual is blank.

Cycle 2: implementation
- Quit Excel via JXA and removed the stale `~$Net Worth.xlsx` lock.
- Patched with openpyxl:
  - Added headers at BD18:BI18 matching the existing dark-navy banker style.
  - Added blue input cells at BE:BI rows 19–30 with currency / general formats.
  - Added computed BD formula per row, special-casing row 19 (AN=1, no prior FY bonus) to avoid dereferencing the header row.
  - Rewrote BB19:BB30 to prefer BD when non-blank, else BC, else the original modeled sum.
  - Added cell comments on BD18 / BE18 explaining the timing and precedence.
  - Extended `AN5` help note to document the new block.
  - Widened BD:BI columns for legibility.
- Reopened in Excel, forced recalc, and saved to refresh cached values.

Cycle 3: verification
- Pre-state values match the session-2 handoff: BB19=550K, BB20=450K, BB21=750K, BB22=970,633, BC29=5M still intact.
- Smoke test with BE19=600K and BF19=95K:
  - BD19=BB19=545K (95K actual base + 450K default sign-on + 0 bonus in year 1)
  - BD20=BB20=500K (300K modeled base + 600K × 4/12 stub-prorated FY2026 actual)
  - BD21="" so BB21 fell through to the modeled pin of 750K
- Cleared the test inputs and saved clean. BE19/BF19/BD19 all None in the final cached workbook.



## 2026-04-09 (session 2) — Cash-basis bonus model

Context:
- User provided Jump Trading offer letter PDF at `~/Desktop/Offer-Letters/Addendum`
- Previous model used accrual basis: FY bonus booked in the year earned
- Offer letter specifies deferred payment: 50% by March 15, 25% at 6 months, 25% at 12 months after FY end
  → entire FY bonus arrives in the *following* calendar year (cash basis)

Cycle 1: offer letter extraction
- Opened PDF via Preview with computer-use
- Confirmed key numbers: $300K base, $450K guaranteed annual bonus (FY2026–27), $450K sign-on (2026 only)
- Confirmed deferred payment schedule requiring cash-basis model

Cycle 2: bonus override pins for years 1–3
- Set `AX19 = 0` (2026 stub: no bonus received that calendar year)
- Set `AX20 = 150000` (2027: receives FY2026 pro-rated bonus; $450K × 4/12 ≈ $150K)
- Set `AX21 = 450000` (2028: receives FY2027 full guaranteed bonus $450K)

Cycle 3: AU Trend Bonus formula correction
- Original formula used `(AN-2)` exponent, ramping from Year 2
- Corrected to `(AN-3)` so discretionary ramp starts from Year 4 (2029), consistent with years 1–3 being pinned
- Applied to rows 19–30

Cycle 4: AV Swing suppression
- Updated swing formula to return 0 when `AN <= 3`
- Prevents fluctuation overlay on guaranteed/override years

Cycle 5: label and note updates
- `Model Inputs!A27`: updated label to reflect deferred-payment guarantee scope
- `Model Inputs!J24`: updated comp description note to explain cash-basis model
- `Savings Projection!AN5`: updated note to reference Jump Trading offer terms

Cycle 6: save and verification
- Saved through Excel (AutoSave active, Cmd+S sent while Excel was frontmost)
- Verified visually: BB19=$550K, BB20=$450K, BB21=$750K, BB22=$970,633 ✓
- Updated handoff docs



## 2026-04-09 15:37:37 PDT

Context:
- workbook under active iteration at `/Users/benjaminshih/Desktop/Net-Worth-Planning/Net Worth.xlsx`
- user reported that some cells still did not populate correctly when manually adding more years

Cycle 1: propagation audit
- inspected `Savings Projection`, `Model Inputs`, `Scenario Lab`, and dashboard references
- found that later years propagated only through the dedicated override path, not through the visible gross-comp column
- found that derived working years truncated on the first blank / `Retired` row
- found that scenario affordability outputs mixed purchase-year and retirement-year indexing

Cycle 2: compensation-path hardening
- kept `Savings Projection!B:B` as output-only
- standardized manual late-year gross input to `Savings Projection!BC:BC`
- updated formula comments / labels so the intended edit surface is visible

Cycle 3: working-year and late-row fixes
- changed `Savings Projection!B12` to last-working-year logic
- kept `Model Inputs!B19` and scenario YOE caps linked to that repaired count
- made late working years carry forward nonblank rent and living-cost values

Cycle 4: circular-reference correction
- discovered that trying to infer direct manual edits from the visible gross-comp output column created circular references
- removed that self-referential logic entirely
- retained only the explicit manual-input path through `BC`

Cycle 5: scenario affordability correction
- changed retirement sustainability outputs to use retirement-year carry / draw metrics
- kept purchase-close metrics indexed to purchase year
- updated dashboard labels to reflect the distinction

Cycle 6: independent cross-checks
- ran two independent subagent audits
- both confirmed the core issues:
  - first-gap truncation
  - unsafe direct-edit path in the visible output column
  - purchase-year indexing leaking into retirement sustainability metrics

Cycle 7: explicit gap test
- created a temp workbook copy
- kept year 12 blank
- entered a year 13 gross-comp input
- verified that:
  - derived working years moved to 13
  - scenario caps updated
  - scenario year 13 remained `Working`

Cycle 8: continuity package
- created local handoff files in `Desktop/Net-Worth-Planning`
- documented workbook state, lessons, and next steps for Claude or Codex continuation

## 2026-04-12 01:11:59 UTC - directory rename maintenance

Context:
- User wanted the non-net-worth personal files folder renamed to a regular personal-files location and asked whether quoted directory names in ls could be removed.

Cycle 1: rename and path-reference cleanup
- Renamed Desktop folders to avoid spaces in shell display: net worth repo -> Net-Worth-Planning, non-net-worth personal files -> Personal, offer-letter files -> Offer-Letters.
- Updated repo continuity docs and local settings path references to the new hyphenated paths.
- Verified old path strings no longer appear in the repo docs or compact Codex memory.


## 2026-04-12 (session 8) - PM after first-switch scenario sheet

Context:
- User wanted to model switching to PM after making a first job switch, likely around projection year 7 or 8.

Design:
- Added a separate visible `PM After Switch` sheet and left the core projection sheets unchanged.
- Modeled first switch after 3/4/5 YOE with a visible default 3x IC bump until PM start.
- Modeled PM start in Y7/Y8 with four visible PM economics cases: Starter, Base, Upside, and Tail.
- PM gross comp = PM base salary + payout share x net PnL, treated as same-year gross cash. PM-specific deferral, platform pass-through costs, drawdown, clawback, and seat-loss risk are intentionally not modeled yet.

Implementation:
- Built a 24-scenario summary and visible Y1-Y30 helper model.
- Reused the existing tax tables, rent/living inflation, retirement contribution logic, base investment return, and `$5M` / `$7M` house + immediate-retirement thresholds.
- First pass overlapped the default IC bump control with the threshold table; rebuilt the sheet with controls in `J15:J17` and PM cases in `L15:O18`.

Verification:
- Recalculated and saved through Excel via JXA, then closed the workbook.
- Verified with `openpyxl` that all sheets are visible, the Excel lock file is gone, no cached formula errors are present, and the new sheet caches summary values.
- Current examples: 3Y -> PM Y7 Starter caches about `$9.67M` Y10 wealth; 3Y -> PM Y7 Base caches about `$14.31M`; 3Y -> PM Y7 Upside caches about `$27.04M`.


## 2026-04-12 (session 9) - Y15 liquid net worth scenario cap

Context:
- User wanted both the IC switch and PM-after-switch sheets mapped through continued work in the switched role until Y15, with no projections beyond Y15 and a clear liquid net worth readout.

Design:
- Treated liquid net worth as taxable balance + retirement balance, excluding home equity and unvested deferred comp.
- Kept the taxable and retirement components visible separately in the summary tables.
- Limited first-crossing formulas to Y15 and changed non-crossing labels to `Not by Y15`.

Implementation:
- Rebuilt `IC Switch Scenarios` helper rows as Y1-Y15 only, ending at row 170.
- Rebuilt `PM After Switch` helper rows as Y1-Y15 only, with row 50 as the actual helper header and data rows 51-410.
- Replaced Y10 summary columns with Y15 gross comp, Y15 taxable liquid, Y15 retirement, and Y15 liquid net worth.

Verification:
- Recalculated and saved through Excel via JXA, then closed the workbook.
- Verified with `openpyxl` that Excel has no workbook lock, both scenario sheets stop at Y15, all sheets remain visible, and no cached formula errors are present.
- Current cached examples: IC 3Y 2x Y15 liquid net worth about `$43.55M`; IC 3Y 3x about `$65.04M`; PM 3Y -> PM Y7 Starter about `$17.17M`; PM 3Y -> PM Y7 Base about `$29.35M`.


## 2026-04-12 (session 10) - post-Y8 IC plateau

Context:
- User clarified that staying on the IC path should not keep compounding past Y8; it is hard to get past roughly `$3M-$4M` per year as an IC, so post-Y8 IC switch cases should stagnate with some variability.

Implementation:
- Updated `IC Switch Scenarios` so helper cash-comp formulas use baseline comp before switch, 2x/3x/4x bumped comp through Y8, and a bounded post-Y8 plateau afterward.
- Added visible controls at `IC Switch Scenarios!J15:J17`: plateau starts after Y8, steady-state midpoint `$3.5M`, and variability band `$0.5M`.
- Updated IC sheet assumptions/comments to make the plateau visible in the workbook.
- During cached-value validation, found a stray literal `e` in `PM After Switch!H227`; corrected it to `=$H$33`, matching adjacent helper rows, which removed cached `#VALUE!` values in that PM tail scenario.

Verification:
- Recalculated and saved through Excel via JXA, then closed the workbook.
- Verified all sheets remain visible, Excel has no workbook open, no temp lock file is present, and `make validate` passes.
- Verified no cached formula-error literals remain in the workbook.
- Current IC switch cached Y15 cash comp is about `$3.93M` across cases. Current cached Y15 liquid net worth examples: 3Y 2x about `$23.92M`; 3Y 3x about `$28.67M`; 3Y 4x about `$33.40M`; 5Y 2x about `$22.41M`; 5Y 4x about `$28.95M`.


## 2026-04-12 (session 11) - restore Y10 summary alongside Y15

Context:
- User clarified that adding Y15 should not replace the original Y10 net-worth/statistics readouts.

Implementation:
- Updated `IC Switch Scenarios` summary rows to include Y10 cash comp, taxable liquid, retirement, liquid net worth, threshold deltas, and Y10 read text, followed by the Y15 version of those same readouts.
- Updated `PM After Switch` summary rows with the same Y10 and Y15 structure.
- Kept helper rows capped at Y15 and kept first-crossing columns capped at Y15.
- Updated sheet notes so future edits understand the summaries are intentionally dual-horizon.

Verification:
- Recalculated and saved through Excel via JXA, then closed the workbook.
- Verified all sheets remain visible, Excel has no open workbook, no temp lock file is present, and `make validate` passes.
- Verified no cached formula-error literals remain in the workbook.
- Current examples: IC 3Y 2x Y10 liquid NW about `$11.18M` and Y15 about `$23.92M`; IC 3Y 4x Y10 about `$18.27M` and Y15 about `$33.40M`; PM 3Y -> PM Y7 Starter Y10 about `$9.67M` and Y15 about `$17.17M`; PM 3Y -> PM Y7 Base Y10 about `$14.31M` and Y15 about `$29.35M`.

## 2026-04-12 16:14:15 PDT - low-risk Excel presentation simplification

Context:
- User asked to implement the low-risk advanced Excel features first and note the higher-risk features for a later pass.

Design:
- Kept all sheets visible and left core scenario/helper formulas intact.
- Treated true Excel Tables, a normalized scenario-results sheet, dashboard dropdown selector, conditional formatting, and navigation links as low-risk.
- Deferred PivotTables/slicers, sparklines, Power Query, and formula abstraction work to a later pass because those are more dependent on native Excel automation or a deeper formula audit.

Implementation:
- Added project-local UV tooling (`pyproject.toml` / `uv.lock`) with `openpyxl` and updated `scripts/validate.sh` so validation uses `uv run python` instead of plain `python3`.
- Added `tblICSwitchSummary` on `IC Switch Scenarios!A21:Z30`.
- Added `tblPMAfterSwitchSummary` on `PM After Switch!A21:AF41`.
- Added visible `Scenario Results` sheet with normalized `tblScenarioResults` at `A4:U62`, one row per scenario / horizon combination.
- Added `ScenarioResultKeys` named range and a Financial Dashboard dropdown selector at `B103`.
- Added conditional formatting for positive/negative threshold deltas, shortfall/read text, and first-crossing failures.
- Added dashboard navigation links and sheet backlinks where a blank `A3` anchor was available.

Corrections during implementation:
- Fixed formula reference generation for multi-letter columns such as `AA` / `AC`.
- Made the workbook patch script idempotent for the dashboard section by unmerging prior selector-section ranges before rewriting them.

Verification:
- Ran `uv sync`.
- Ran `uv run python scripts/enhance_workbook_low_risk.py`.
- Recalculated and saved through Microsoft Excel via JXA, then closed the workbook.
- Ran `make validate`; validation passed.
- Verified no hidden sheets, no cached formula errors, table parts present for the three new Excel Tables, `ScenarioResultKeys` present, dashboard selector resolving to the first normalized scenario result, and zero targeted `General` number-format issues in the new/changed presentation ranges.

## 2026-04-12 16:54:06 PDT - advanced analysis pass

Context:
- User wanted the advanced next pass implemented one item at a time with subagent critique first, then correctness/functionality verification after each item.

Design:
- Kept native PivotTables/slicers and Power Query out of scope for this pass because the local Excel automation surface could not safely author them from scratch.
- Added a dedicated `Scenario Analysis` sheet as the advanced presentation surface rather than crowding the dashboard or reusing helper-engine sheets.
- Used `tblScenarioResults` for selector-driven summaries and matrices, and used a local Y1-Y15 chart-data block for charts so the chart series do not depend directly on the helper ranges.
- Kept named cleanup conservative: range-style names only for selector/result pointers, with dashboard lookup repetition reduced through a helper pointer cell.

Implementation:
- Added `scripts/enhance_workbook_advanced.py` with phased execution:
  - phase 1 builds `Scenario Analysis`, support lists, selectors, comparison table, matrices, and chart data block
  - phase 2 adds two compact line charts
  - phase 3 adds presentation-layer defined names and rewires dashboard selector formulas
- Added `Scenario Analysis` with:
  - primary/comparison scenario dropdowns
  - horizon and chart-metric dropdowns
  - selected-horizon comparison block
  - IC and PM liquid-net-worth matrices
  - local chart data at `X41:AC56`
  - two line charts anchored at `A41` and `I41`
- Rewired the dashboard selector region to use `DashboardScenarioResultRow` backed by `Financial Dashboard!P104`, and kept `DashboardSelectedProjectionRow` as a name pointing at `Financial Dashboard!J65`.

Corrections during implementation:
- First named-formula attempt serialized formula-based defined names with a leading `=`, which triggered Excel content-recovery prompts on open.
- Replaced those with range-backed names plus helper worksheet formulas instead.
- First dashboard cleanup attempt created a direct circular reference by naming `J65` and then setting `J65 = DashboardSelectedProjectionRow`; restored `J65` to the plain projection-row formula and kept the name pointing to the cell.

Verification:
- Ran `uv run python -m py_compile scripts/enhance_workbook_advanced.py`.
- Ran phased workbook writes through `uv run python scripts/enhance_workbook_advanced.py --phase 1/2/3`.
- After each phase, reopened and saved through Excel via JXA and checked structural/package state.
- Final audit confirmed:
  - no lock file
  - all sheets visible
  - zero cached formula-error cells
  - `Scenario Analysis` contains exactly two charts
  - both charts point only to `Scenario Analysis!Y42:AC56`
  - defined names are all plain range names
  - targeted new/rewired cells use intended integer or currency formats
  - `make validate` passes

# Net Worth Workbook Handoff

Updated: 2026-04-12 (session 8)

Workbook:
- `/Users/benjaminshih/Desktop/Net-Worth-Planning/Net Worth.xlsx`

## Goal

This workbook is meant to let the user stress-test a quant-research compensation path, see savings and net-worth growth over time, model retirement after different YOE counts, and understand what house purchase is reasonable given both purchase liquidity and post-retirement burn.

## Current Workbook Structure

Visible sheets:
- `Financial Dashboard`
- `Model Inputs`
- `Savings Projection`
- `Scenario Lab`
- `IC Switch Scenarios`
- `PM After Switch`
- `Tax Assumptions`

Key sheet roles:
- `Model Inputs`: single control surface for global return, spending, house, mortgage, and scenario parameters.
- `Savings Projection`: canonical year-by-year base projection and compensation schedule.
- `Scenario Lab`: downside / base / upside scenario mechanics, retirement / house affordability outputs, and sensitivity logic.
- `IC Switch Scenarios`: formula-driven side sheet for switching after 3/4/5 YOE at Jump and applying 2x/3x/4x IC quant cash-comp bumps, with `$5M` / `$7M` house + immediate-retirement threshold checks.
- `PM After Switch`: formula-driven side sheet for switching to PM in Y7/Y8 after a first IC job switch, with visible PM net-PnL / payout-share cases and the same `$5M` / `$7M` house + immediate-retirement threshold checks.
- `Financial Dashboard`: presentation layer reading from the projection and scenario sheets.
- `Tax Assumptions`: visible tax tables and payroll assumptions.

## Important Current Modeling Rules

### Compensation

- `Savings Projection!B:B` is now output-only.
- `Savings Projection!BC:BC` is the manual late-year gross-comp input column (stress-test / scenario override).
- `Savings Projection!AR:AR`, `AX:AX`, and `BA:BA` remain finer-grained override columns.
- `Savings Projection!BD:BI` is the **Realized Comp (Actuals)** input block. See dedicated section below.
- The comp model is **tranche-aware cash basis** (session 4): an **accrual layer** records what was earned in each fiscal year, and a **cash layer** splits each FY bonus across two calendar years on the 50/25/25 deferral schedule. This is stricter than the session-2 lump-sum cash simplification.
- Accrual layer (per row, matches the FY earned in that projection year):
  - `AU` Trend Bonus now computes accrued FY bonus: `AN=1` → stub-prorated guarantee (`B$27 × (13-B$23)/12`); `AN=2` → full guarantee `B$27`; `AN≥3` → discretionary ramp using existing early/late growth rates.
  - `AV` swing suppressed for `AN ≤ 2` (years 1–2 are guaranteed; FY2028 is first discretionary year).
  - `AY` (renamed **FY Bonus Accrued**): pure accrual — `AX override → AU × (1+swing)`. The old BC-derived back-solve path is removed.
  - `AX` pins (session 4): `AX19 = 150000` (FY2026 accrued prorated), `AX20 = 450000` (FY2027 full guarantee). `AX21` cleared; trend formula drives FY2028+.
  - IC quant median calibration (session 6): `Model Inputs!B28 = 45.3%` early bonus growth and `Model Inputs!B29 = 27.1%` later bonus growth. These target pre-swing trend total comp of about `$1.25M` in projection year 5 and `$2.25M` in projection year 8, based on the user's updated IC median ranges (`$1.0M-$1.5M` by Y5 and `$1.5M-$3.0M` by Y8). Column `B` is still cash received, so it lags these accrued/trend targets under the 50/25/25 deferral schedule.
- Cash layer (new column `BJ`, fed into `BB`):
  - `BJ` **Bonus Cash Received** = `0.75 × AY_{r-1} + 0.25 × AY_{r-2}`, with zero terms for rows before 19.
  - `BJ19 = 0` (no FY has ended before CY2026). `BJ20 = 0.75 × AY19`.
  - `BB` (Modeled Gross Comp) uses `BJ` instead of `AY` for the bonus component: `AT + BJ + AZ + BA`.
- Walk-away readout (new column `BK`):
  - `BK` **Unvested Deferred Comp (YE)** = `AY_r + 0.25 × AY_{r-1}` on active rows.
  - Represents the "golden handcuffs" overhang — dollars you would forfeit at Dec 31 of that year if you voluntarily quit.
- Verified tranche-model cached values after the session-6 IC calibration (no actuals entered, default pins):

  | Row | CY | Trend total comp | Accrued total comp | Cash gross comp (B/BB) | Unvested YE (BK) |
  |---|---|---|---|---|---|
  | 19 | 2026 | $250K + sign-on | $250K + sign-on | **$550K** | $150K |
  | 20 | 2027 | $750K | $750K | **$412.5K** | $487.5K |
  | 21 | 2028 | $750K | $750K | **$675K** | $562.5K |
  | 22 | 2029 | $954K | $1.022M | **$750K** | $834K |
  | 23 | 2030 | $1.250M | $1.151M | **$954K** | $1.032M |
  | 24 | 2031 | $1.507M | $1.507M | **$1.119M** | $1.420M |
  | 25 | 2032 | $1.834M | $1.994M | **$1.418M** | $1.996M |
  | 26 | 2033 | $2.250M | $2.047M | **$1.872M** | $2.171M |
  | 28 | 2035 | $3.450M | $3.777M | **$2.595M** | $4.096M |

### Realized Comp (Actuals) Block — `Savings Projection!BD:BI`

Added session 3 so the user can pin down realized compensation as fiscal years close, while keeping the planning model intact for future years.

Column layout (row 18 headers, data rows 19–30 matching the calendar-year grid):
- `BD` **Actual CY Gross Comp** — computed readout (black font). Sums realized components for the calendar year, routes FY bonuses into the correct next CY with stub logic, and returns `""` if nothing actual is filled for that row.
- `BE` **FY Bonus Earned (paid next CY)** — blue input. Enter the actual FY bonus in the row for the fiscal year it was *earned*; the workbook pays it in the next calendar year row. FY2026 is pro-rated by `(13 − 'Model Inputs'!$B$23)/12 = 4/12` to match the existing stub-year start.
- `BF` **CY Base Actual** — blue input. Realized base salary for that calendar year.
- `BG` **CY Other / Sign-On Actual** — blue input. Replaces the default `AZ + BA` (sign-on + other cash) for that row when filled.
- `BH` **Confirmed?** — blue input (free-form date or marker).
- `BI` **Notes** — blue input.

Precedence in the `BB` (Modeled Gross Comp) formula, highest → lowest:
1. `BD` (actuals) — used whenever it is non-blank.
2. `BC` (existing stress-test / manual override).
3. Modeled path: `AT + BJ + AZ + BA` (session 4: `BJ` cash-received replaces the old direct `AY` reference).

`BD` now uses the same 75/25 tranche math as `BJ`:
- `BD_r` bonus component = `0.75 × IF(BE_{r-1}<>"", BE_{r-1}, AY_{r-1}) + 0.25 × IF(BE_{r-2}<>"", BE_{r-2}, AY_{r-2})`.
- Rows 19 and 20 special-case the missing prior rows.
- **Semantic change:** `BE` now represents the **accrued** FY bonus (post-proration). Enter the dollar number from the bonus letter as-is — do **not** annualize and do **not** pre-apply the 4/12 stub, because FY2026's proration is already baked into what you receive. The session-3 `BE × stub_factor` multiplier has been removed.

Smoke test stays valid: entering `BE19 = 150000` + no other actuals should leave `BD20 = BB20 = $412.5K` (the same as the modeled default). Entering `BE19 = 200000` should push `BD20 = $300K + 0.75×$200K = $450K` and `BD21 = $300K + 0.75×AY20 + 0.25×$200K = $300K + $337.5K + $50K = $687.5K` (both CY2027 and CY2028 move, because the FY2026 bonus spills into both years under tranche logic).

Editing constraints:
- Do **not** turn `AX` / `AR` / `BA` into formulas driven from this block. They remain hard pins for the planning path. The actuals layer sits above them in `BB`, not inside them.
- The FY/CY row offset matters. `BE19` is FY2026 (earned in row 19, paid 75% in row 20 and 25% in row 21). Do not shift or off-by-one this mapping.
- `BD` must stay a formula. The first-row formula special-cases `AN=1`; the second-row formula special-cases one prior row.

### Rent & Living-Cost Inflation (session 5)

- `Model Inputs!B35` **Rent inflation (annual)** = 3% (blue input, % format).
- `Model Inputs!B36` **Living cost inflation (annual)** = 3% (blue input, % format).
- `Savings Projection!BL` **Rent (real $)** holds the user's rent plan in today's dollars. Blue input for rows 19–28, `LOOKUP` carry-forward for rows 29–58.
- `Savings Projection!BM` **Living (real $)** is the same pattern for other living costs.
- `Savings Projection!S` (renamed **Rent (nominal)**) and `T` (renamed **Other Living Costs (nominal)**) are now pure display formulas: `=IF(C_r="Working", IF(BL_r="","", BL_r * (1+'Model Inputs'!$B$35)^(AN_r-1)), "")` and the parallel for `T`/`BM`/`$B$36`.
- Semantics: projection year 1 is the base year, so real = nominal in row 19. Real dollars compound forward from there.
- Scenario Lab `J32:K58` still reads `S`/`T` as the nominal multiplier base, so scenario downsides/upsides now automatically ride on the inflated nominal path — no additional edit needed downstream.
- Do **not** put literal values back into `S` / `T`. Edit real-dollar assumptions in `BL` / `BM` and the inflation rates in Model Inputs.
- Verified cached: year 10 rent nominal = $104.4K (up from flat $80K), living = $65.2K (up from flat $50K); total save rate trims from 44.9% → 42.9%.

### Working-Year Detection

- `Savings Projection!B12` now uses the last working year rather than the first blank gap.
- This means a later filled year can still propagate even if there is a blank retired year above it.
- `Model Inputs!B19` is linked to `Savings Projection!B12`.
- Scenario retire-YOE caps at `Model Inputs!F11:H11` derive from `B19`.

### House / Retirement Affordability

- Purchase-close liquidity logic still uses the purchase year.
- Retirement sustainability logic now uses the retirement year, not the purchase year.
- This split matters if the user buys a house and then keeps working for additional years.

### Late-Year Cost Carry-Forward

- When a later year becomes `Working`, rent and living-cost rows now carry forward the latest nonblank values instead of dropping to blank / zero.

## Major Progress Completed

1. Reworked the workbook away from a net-worth tracker into a financial planning workbook with visible assumptions and no hidden sheets.
2. Built a banker-style dashboard with scenario blocks, charts, retirement metrics, and wealth-bucket summaries.
3. Added NYC-focused tax modeling with visible tax assumptions and explicit components.
4. Added recurring retirement contributions (`401(k)` and Roth / backdoor Roth assumptions).
5. Added retirement drawdown modeling, house-purchase modeling, and scenario comparison.
6. Added `Model Inputs` as a centralized parameter sheet.
7. Added compensation structure for the user’s quant-research trajectory:
   - stub year in 2026
   - guaranteed bonus starting in calendar year 2027
   - faster early ramp
   - slower later ramp
   - deterministic fluctuation layer
8. Fixed multiple propagation bugs caused by manually extending the working horizon.
9. Removed circular-reference behavior introduced by trying to make the visible gross-comp output column act like an input.
10. **Switched bonus model from accrual-basis to cash-basis** per the Jump Trading offer letter deferred payment schedule (session 2):
    - Read the offer letter (`~/Desktop/Offer-Letters/Addendum` PDF).
    - First pass used a lump simplification: the entire fiscal year's bonus was assumed to arrive in the *following* calendar year.
    - Pinned years 1–3 with Bonus Override (`AX19=0`, `AX20=150000`, `AX21=450000`).
    - Updated AU Trend Bonus formula to shift growth exponent from `(AN-2)` to `(AN-3)`.
    - Updated AV Swing formula to suppress fluctuation for years ≤ 3.
    - Updated `Model Inputs!A27` label and `Model Inputs!J24` note to document cash-basis approach.
    - Updated `Savings Projection!AN5` note to reference Jump Trading offer terms.
11. **Added Realized Comp (Actuals) input block** at `Savings Projection!BD:BI` (session 3) so realized FY bonuses / CY base / CY other could be pinned as fiscal years close, with a computed `BD` readout overriding `BB`.
12. **Replaced the lump cash-basis simplification with a proper tranche-aware 50/25/25 model** (session 4):
    - Flipped `AU` / `AV` / `AY` to represent **accrual** (what was earned in a given FY), not cash.
    - Added `BJ` Bonus Cash Received as the 75/25 tranche sum of prior-row accruals.
    - Added `BK` Unvested Deferred Comp (YE) as the "golden handcuffs" walk-away readout.
    - Rewired `BB` to use `BJ` instead of `AY`. Rewired `BD` actuals with the same tranche structure and dropped the session-3 `BE × stub_factor` multiplier (accruals in `BE` are entered post-proration).
    - Repinned `AX19 = 150000`, `AX20 = 450000`; cleared `AX21` to let the trend formula drive FY2028+.
    - Restored missing `B29` and `B30` formulas (pre-existing gap from session 1's literal-value stress test). Without this fix, `Savings Projection!B` silently fed `None` to the scenario lab and dashboard for row 29 even though `BB29` held the `$5M` stress override.
    - Session-4 historical verification: `BB19=$550K`, `BB20=$412.5K`, `BB21=$675K`, `BB22=$750K`; `BK19=$150K`, `BK20=$487.5K`, `BK21=$562.5K`; `BB29=$5M`; `B29=$5M`. Later live inspection showed the old `$5M` stress input was gone, and session 6 restored only the missing `B29` formula.
13. **Added rent + living-cost inflation drivers** (session 5): moved editable real-dollar rent/living assumptions to `BL:BM`, made `S:T` nominal formula outputs, and added `Model Inputs!B35:B36` inflation controls.
14. **Recalibrated the IC quant base compensation path** (session 6): set `Model Inputs!B28 = 45.3%` and `B29 = 27.1%` so the pre-swing trend total comp targets roughly `$1.25M` by Y5 and `$2.25M` by Y8. Restored `Savings Projection!B29` as a formula while leaving `BC29` empty.
15. **Added `IC Switch Scenarios` sheet** (session 7):
    - Separate visible sheet; no changes to the core projection mechanics.
    - Models switch after 3/4/5 YOE at Jump with 2x/3x/4x IC quant cash-comp bump from the following projection year.
    - Shows gross walk-away `BK` as a separate readout, not deducted from net worth. Exact buyout / forfeiture / noncompete tax timing is not modeled.
    - Rebuilds the baseline IC cash-comp path from `Model Inputs`, applies the scenario bump, then uses the existing tax tables, rent/living assumptions, retirement contributions, and base return to project through Y30.
    - Computes `$5M` / `$7M` all-cash and 50%-down house + immediate-retirement thresholds from base home assumptions in `Model Inputs`.
    - Verified after Excel recalc: all first-crossing formulas calculate without `#NAME?`; sheet is visible; Excel lock file absent.

16. **Added `PM After Switch` sheet** (session 8):
    - Separate visible sheet; no changes to the core projection mechanics.
    - Models a first IC job switch after 3/4/5 YOE with a visible default 3x pre-PM IC bump, then PM start in projection year 7 or 8.
    - PM economics are visible cases: Starter (`$10M` net PnL × 15% payout + `$300K` base = `$1.8M` gross), Base (`$25M` × 15% + `$300K` = `$4.05M`), Upside (`$50M` × 20% + `$300K` = `$10.3M`), and Tail (`$100M` × 15% + `$300K` = `$15.3M`).
    - PM payout is modeled as same-year gross cash for scenario analysis; PM-specific deferral, clawback, platform cost allocation, drawdown, and seat-loss probability are not modeled.
    - Reuses the workbook tax tables, rent/living inflation, retirement contributions, base return, and `$5M` / `$7M` home + retirement thresholds.
    - First implementation overlapped a new control cell with the threshold table; fixed by moving controls to `J15:J17` and PM cases to `L15:O18` before recalculation.
    - Verified after Excel recalc: sheet is visible, all sheets remain visible, controls cache correctly, and no cached formula errors appear on the new sheet.

## Latest Debugging Pass

The latest pass fixed the issues the user flagged about manual extension and stale scenario behavior.

Fixed:
- `Savings Projection!B12` previously truncated on the first `Retired` row.
- Late-year manual edits were only safe through a hidden-ish override path and could partially fail if the user typed where the sheet visually suggested.
- Newly activated working rows could lose rent / living costs.
- Scenario affordability summaries were partly keyed off purchase year when they should have been retirement-year metrics.
- Temporary attempts to infer manual edits directly from `Savings Projection!B:B` caused circular references.

Current resolution:
- `B` is explicitly an output column.
- `BC` is explicitly the manual gross-comp input column.
- Last-working-year logic is gap-safe.
- Late-year living costs carry forward.
- Retirement sustainability metrics use retirement-year indexes.

## Current Verified State

Verified after the session-6 IC quant calibration and save-through-Excel:
- `Model Inputs!B28 = 45.3%`; `Model Inputs!B29 = 27.1%`.
- `Savings Projection!B12 = 10`; `Model Inputs!B19 = 10`; `Model Inputs!F11:H11 = 12 / 10 / 9`.
- `Savings Projection!BC29` is empty. `Savings Projection!B29` now has the normal output formula `=IF(BB29="","",BB29)` and currently evaluates blank because year 11 is retired.
- Projection year 5 / CY2030: trend total comp about `$1.25M`, accrued total comp about `$1.15M` after the negative swing, and cash gross comp about `$954K`.
- Projection year 8 / CY2033: trend total comp about `$2.25M`, accrued total comp about `$2.05M` after the negative swing, and cash gross comp about `$1.87M`.
- Projection year 10 / CY2035: cash gross comp about `$2.60M`; total wealth at base return about `$6.43M`.

- `PM After Switch` has 24 scenarios: first switch after 3/4/5 YOE, default 3x pre-PM IC bump, PM start in Y7/Y8, and Starter/Base/Upside/Tail PM economics. Current cached examples: 3Y -> PM Y7 Starter reaches about `$9.67M` Y10 wealth and first clears the `$5M` all-cash threshold in Y14 / 2039; 3Y -> PM Y7 Base reaches about `$14.31M` Y10 wealth; 3Y -> PM Y7 Upside reaches about `$27.04M` Y10 wealth and clears `$7M` 50% down by Y10.

Verified in Excel after cash-basis lump model (session 2, now superseded):
- `BB19 = $550,000`, `BB20 = $450,000`, `BB21 = $750,000`, `BB22 = $970,633`.

Verified in Excel after tranche-aware model (session 4, now superseded by the session-6 growth-rate calibration):
- `BB19 = $550,000` (unchanged — no bonus paid in CY2026 regardless).
- `BB20 = $412,500` (base $300K + 75% × $150K FY2026 accrual = $112.5K).
- `BB21 = $675,000` (base $300K + 75% × $450K FY2027 + 25% × $150K FY2026 = $375K).
- `BB22 = $750,000` (base $300K + 75% × $450K + 25% × $450K = $450K; AV swing for AN=4 ≈ 10% ramps AY22 but BJ22 still = $450K because it averages prior two accruals).
- `BK19 = $150,000`, `BK20 = $487,500`, `BK21 = $562,500` (walk-away).
- Historical note: old handoff text said `B29 = BB29 = $5,000,000`, but live inspection before session 6 showed `BC29` empty and `B29` missing its formula. Session 6 restored the `B29` formula without reintroducing the old `$5M` stress input.

Separate gap test on a temp copy also passed:
- left year 12 blank
- set year 13 gross-comp input
- derived working years advanced to 13
- scenario year 13 stayed `Working`

## Known Constraints / Caveats

- The modeled projection horizon is still fixed to the existing table length on `Savings Projection` and scenario blocks. If the user wants many more years beyond the current grid, the sheet structure will need an intentional expansion.
- Excel cache coherence matters. If the workbook is open in Excel while `openpyxl` edits are written to disk, Excel can later save its stale in-memory state back over those edits.
- Some chart / layout work is subjective and should be validated visually in Excel, not just from formulas.

## Recommended Next Steps For The Next Agent

1. If continuing workbook development, start by reading the four local handoff files referenced in `CLAUDE.md`.
2. Do not assume the old year-11 `$5M` test still exists. Live workbook state after session 6 has `BC29` empty and `B29` formula-driven blank.
3. If making structural workbook edits:
   - close the workbook in Excel first
   - edit on disk
   - reopen and save through Excel
   - then verify cached values with `openpyxl` in `data_only=True`
4. If the user wants a more flexible manual-input UX, redesign the sheet around explicit input columns rather than reusing output cells.

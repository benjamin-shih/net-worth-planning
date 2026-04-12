# Career And Financial Planning Memo

Recorded: 2026-04-11

Purpose: keep a running plain-English record of the planning logic behind `Net Worth.xlsx`, so future agents can compare the user's realized path against the goals and update the workbook without replaying the full discussion.

## User Goal

The user wants to use the net-worth workbook over multiple years to track whether their quant-finance career path is on pace for early financial independence, eventual Bay Area return, and a high-end home purchase.

Core target cases discussed:
- Bay Area home price cases: `$7M` and `$5M`.
- Desired outcome: ability to buy the home and, ideally, retire early or at least keep working with the purchase comfortably supported.
- Non-housing retirement spend assumption used in rough analysis: `$200K/year`.
- Comfort test used in discussion: liquid assets after home purchase should support total retirement need at roughly a `3.5%` draw rate.
- Mortgage assumptions used in rough analysis: `6.5%` 30-year fixed, `2.5%` closing costs, approximate home carrying cost stack of `1.1%` property tax, `0.2%` insurance, and `1.0%` maintenance.

## Live Workbook State Observed

The workbook path is:
- `/Users/benjaminshih/Desktop/Net-Worth-Planning/Net Worth.xlsx`

Observed during this session:
- After the 2026-04-11 IC quant compensation recalibration, the live workbook's base case has about `$6.43M` total wealth at projection year 10 / calendar 2035.
- The year-10 gross comp output is about `$2.60M` cash received. This is lower than the year-10 accrued/trend total comp because the workbook intentionally models deferred bonus cash timing.
- The workbook models tranche-aware bonus cash timing using `AY` for FY bonus accrued, `BJ` for bonus cash received, and `BK` for unvested deferred comp at year-end.
- `BK` is a walk-away / forfeiture readout, not spendable cash.
- The prior local handoff said `Savings Projection!BC29 = 5000000` and `B29 = 5000000` were preserved, but live inspection showed `BC29` empty and `B29` blank/no formula. The 2026-04-11 calibration pass restored `B29`'s formula while leaving `BC29` empty.

## IC Quant Base-Path Calibration

The user updated the core IC quant path assumptions after discussions with others:
- Median-ish Y5 annual total comp expectation: about `$1.0M-$1.5M`.
- Median-ish Y8 annual total comp expectation: about `$1.5M-$3.0M`, with much larger upside tails possible.

Workbook interpretation:
- Treat these as earned/accrued annual total comp targets, not cash received, because actual savings cash follows the Jump-style 50/25/25 bonus deferral timing.
- `Model Inputs!B28` early bonus growth is now about `45.3%`.
- `Model Inputs!B29` later bonus growth is now about `27.1%`.
- These values make the pre-swing trend total comp about `$1.25M` in projection year 5 and `$2.25M` in projection year 8.
- With the existing 12% deterministic swing layer, the refreshed cached workbook shows accrued total comp about `$1.15M` in Y5 and `$2.05M` in Y8; cash gross comp is about `$954K` in Y5 and `$1.87M` in Y8 because of deferral lag.

## IC Switch Scenario Sheet

The workbook now includes a visible `IC Switch Scenarios` sheet for revisiting whether the user should consider switching jobs after `3-5` YOE at Jump for a `2x-4x` IC quant pay bump.

Sheet interpretation:
- The bump applies to the ongoing baseline cash gross-comp path from the year after the switch and continues through Y15.
- PM carry / pod economics are intentionally excluded.
- Gross walk-away `BK` is shown separately and not deducted, because exact buyout / deferred-comp forfeiture / noncompete tax timing is not modeled.
- The sheet uses current workbook tax tables, rent/living assumptions, retirement contributions, and base return.
- The sheet stops at Y15 and shows taxable balance, retirement balance, and liquid net worth for each scenario.
- House + immediate-retirement thresholds are computed from base home assumptions in `Model Inputs`; current values are about `$14.0M` for a `$5M` all-cash house, `$16.9M` for `$5M` with 50% down, `$17.3M` for `$7M` all-cash, and `$21.4M` for `$7M` with 50% down.


## PM After Switch Scenario Sheet

The workbook now includes a visible `PM After Switch` sheet for PM conversion after a first IC job switch.

Sheet interpretation:
- First switch is after `3-5` YOE at Jump, with a visible default `3x` pre-PM IC comp bump until PM start.
- PM starts in projection year `7` or `8`.
- PM gross comp is modeled as PM base salary plus payout share times net PnL, paid as same-year gross cash for this scenario sheet.
- PM case table: Starter = `$10M` net PnL at `15%` payout plus `$300K` base (`$1.8M` gross), Base = `$25M` at `15%` plus base (`$4.05M`), Upside = `$50M` at `20%` plus base (`$10.3M`), Tail = `$100M` at `15%` plus base (`$15.3M`).
- PM-specific deferral, platform pass-through costs, drawdown, clawback, and seat-loss probability are not modeled yet. Those should be revised once the user has actual PM terms or attributable PnL.

Current cached examples after Excel recalculation, capped at Y15:

```text
Scenario              Y15 liquid NW   First $5M cash     Read
------------------    -------------   ---------------    --------------------------
3Y -> PM Y7 Starter   ~$17.17M        Y14 / 2039         clears $5M 50% down by Y15
3Y -> PM Y7 Base      ~$29.35M        Y10 / 2035         clears $7M 50% down by Y15
3Y -> PM Y7 Upside    ~$62.80M        Y8 / 2033          clears $7M 50% down by Y15
3Y -> PM Y7 Tail      ~$89.51M        Y8 / 2033          clears $7M 50% down by Y15
```

Interpretation:
- PM is not automatically better than a strong IC switch. The Starter PM case can lag the 3x IC-switch path in some years because `$1.8M` PM gross comp is below some bumped IC cash-comp years.
- The PM path becomes decisive when attributable net PnL is closer to the Base/Upside cases.
- Liquid net worth on these scenario sheets is taxable balance + retirement balance; home equity and unvested deferred comp are excluded, and taxable/retirement components are shown separately.

## Noncompete / Deferred Comp Treatment

The workbook discussion distinguished:
- Deferred bonus / unvested comp: visible through `BK`; this is not counted as spendable cash when leaving unless it actually vests and pays.
- Noncompete period compensation: from the offer language, this appears to be current base salary during an elected noncompete period, not bonus-level compensation.
- User clarified that a noncompete would not block starting a Bay Area job if that job is outside finance. Therefore model noncompete pay as temporary extra income on top of an outside-finance Bay Area job, not as a period with no work.

Rough noncompete bridge assumption used:
- `$300K/year` gross base salary for 12-24 months.
- Directional after-tax value: about `$170K-$180K` for 12 months, `$250K-$270K` for 18 months, `$340K-$360K` for 24 months.
- It is useful bridge cash but not enough to meaningfully change the long-run home/retirement threshold by itself.

## $7M Home Rough Conclusions

Immediate retirement after year 10 with a `$7M` Bay Area home is not supported by the current workbook path.

Approximate liquid wealth needed before close, using the assumptions above:

```text
Down pay    Approx liquid wealth needed before close
--------    -----------------------------------------
30%         ~$23.2M
40%         ~$22.4M
50%         ~$21.6M
60%         ~$20.8M
70%         ~$19.9M
100%        ~$17.5M
```

Current path year-10 liquid/wealth of about `$6.43M` after the IC quant compensation recalibration is still far below these retirement targets. It may close on a home with lower down payment, but the draw rate would be too high for early retirement.

If the user moves back and keeps working outside finance:
- `$500K/year` Bay Area job: too tight for a `$7M` home.
- `$750K/year`: borderline / portfolio-subsidized.
- `$1M/year`: plausible if liquidity is preserved, especially with noncompete bridge income, but still not an immediate-retirement setup.

## $5M Home Rough Conclusions

A `$5M` home is much more realistic.

Approximate liquid wealth needed before close for home purchase plus immediate retirement:

```text
Down pay    Approx liquid wealth needed before close
--------    -----------------------------------------
20%         ~$18.8M
30%         ~$18.2M
40%         ~$17.6M
50%         ~$17.0M
60%         ~$16.5M
70%         ~$15.9M
100%        ~$14.1M
```

The current year-10 path can plausibly buy a `$5M` house, but not retire immediately. Continuing to work in the Bay changes the picture:

```text
Bay job comp    Rough read for $5M house
------------    ------------------------------------------
$500K           Still tight; relies on portfolio subsidy.
$750K           Workable around 50%-70% down, not lavish.
$1M             Reasonable around 40%-60% down.
```

Approximate annual break-even Bay Area salary for a `$5M` home:

```text
Down pay    Break-even salary
--------    -----------------
30%         ~$1.13M
40%         ~$1.05M
50%         ~$0.97M
60%         ~$0.89M
70%         ~$0.81M
100%        ~$0.58M
```

## Career Path Scenarios Discussed

The user asked about switching firms, PM roles, and possibly returning to the Bay to raise a seed round after building top-quant credibility.

Working priors:
- Do not model firm-switching as "switch every N years."
- Model one serious market check around `3-5 YOE`, when external firms may pay for credible experience and when unvested deferred comp may not yet be too large.
- A switch is likely +EV only if it changes the payout surface: larger guarantee, better platform/data, clearer risk/PnL ownership, or PM-track capital.
- Repeated lateral switching for small bumps is likely negative because it resets trust, complicates noncompetes, and can weaken the signal of stability.

Career path ranking for early-retirement target:

```text
Path                         Wealth mechanism                  Rough read
-------------------------    -------------------------------   ------------------------------
Elite quant IC / researcher   Salary + discretionary bonus      Good, lower variance, capped.
Major 3-5 YOE switch          Buyout + guarantee + better seat  Good if it is a step-change.
Platform PM / pod PM          Percent of net PnL                Best-aligned upside, high risk.
Startup after 8-10 YOE        Equity ownership                  Good option, weak cash-flow plan.
```

## $4M Guarantee Scenario

Rough scenario: after 3-5 YOE, noncompete bridge, then a `$4M` guaranteed package that grows around `10%/year`.

Estimated timing for `$7M` home plus retirement:

```text
Switch timing    Approx result
-------------    ------------------------------------------------
After 3 YOE      ~$14.9M by year 10; retire target around 2037-38.
After 4 YOE      ~$12.0M by year 10; retire target around 2038.
After 5 YOE      ~$9.6M by year 10; retire target around 2038-39.
```

This is the type of path that can plausibly make the `$7M` home plus early-retirement goal work.

## $2M Guarantee Scenario

Rough scenario: after 3-5 YOE, noncompete bridge, then a `$2M` guaranteed package that grows around `10%/year`.

For a `$7M` home:

```text
Switch timing    Approx result
-------------    ------------------------------------------------
After 3 YOE      ~$7.8M by year 10; retire target around 2040-41.
After 4 YOE      ~$6.6M by year 10; retire target around 2040-42.
After 5 YOE      ~$5.7M by year 10; retire target around 2041-43.
```

For a `$5M` home:

```text
Switch timing    Approx result
-------------    ------------------------------------------------
After 3 YOE      ~$7.8M by year 10; retire target around 2038-40.
After 4 YOE      ~$6.6M by year 10; retire target around 2039-41.
After 5 YOE      ~$5.7M by year 10; retire target around 2040-42.
```

Interpretation:
- `$2M` guarantee is strong but probably not a "retire after 10 years with a `$7M` home" path.
- It becomes much more reasonable if the home target is `$5M`, or if the `$2M` grows quickly into `$4M+`.

## PM / Carry Path

The PM path is most directly relevant to the early-retirement target because it creates power-law upside.

Working assumptions:
- PM candidacy usually depends on attributable PnL, capacity, risk control, and portability of strategy, not just being a strong quant.
- A realistic PM discussion can happen after `5-8 YOE` if the person has live, attributable, portable results; earlier may happen for exceptional cases or sub-PM / risk-owner seats.
- Pod/platform PM payouts are often discussed as a share of net PnL, roughly `10%-20%` in broad-market lore, but details vary heavily by platform, strategy, drawdown terms, and cost allocation.

Illustrative pod PM economics:

```text
Net PnL    15% payout    20% payout
-------    ----------    ----------
$5M        $0.75M        $1.00M
$10M       $1.50M        $2.00M
$25M       $3.75M        $5.00M
$50M       $7.50M        $10.00M
$100M      $15.00M       $20.00M
```

Lifestyle / risk notes:
- PM is high-autonomy but high-pressure.
- It is a small-business role under daily PnL and risk scrutiny.
- Job security can be low if drawdowns or Sharpe disappoint.
- Upside is excellent if the edge is real and scalable.
- Downside includes being cut, losing platform support, and having noncompete / portability issues.

## Startup / Seed Round Path

The user also asked about working as a top quant for ~10 years, returning to the Bay Area, raising a seed round, and using that to fund lifestyle.

Working read:
- Top-quant credibility can help with a technical founder story, especially in AI/infra/trading/financial tooling.
- But venture-backed founder salary is not a good substitute for finance compensation.
- A seed-funded startup is best modeled as equity option value, not as a cash-flow bridge for a `$5M-$7M` home.
- Public founder salary data tends to put seed-stage founder salaries far below quant finance comp, often around low-to-mid six figures rather than `$500K+`.

Startup path vs PM path:

```text
Dimension       PM path                         Startup path
----------      -----------------------------   ------------------------------
Cash comp       Immediate if PnL is good         Low/moderate founder salary
Upside timing   Annual bonus / payout            Exit or secondary years later
Risk            Drawdown / getting cut           Zero outcome / dilution
House support   Strong if PM works               Weak unless already wealthy
Fit             Best for direct wealth target    Best if company-building goal dominates
```

## Future Update Instructions

When revisiting this memo:
- Update the live workbook values first: actual comp, deferred comp, noncompete terms, tax location, Bay Area spend, and current house-price target.
- Keep the distinction clear between "can buy while working" and "can buy and retire immediately."
- Track realized compensation against three lanes:
  1. Baseline elite IC path.
  2. Switch / guarantee path.
  3. PM / risk-owner path.
- If the user has actual PnL attribution, update the PM probability and payout assumptions. This is likely the most important variable.
- If the user has a credible startup idea or fundraising signal, model it separately as equity-option value, not as salary replacement.

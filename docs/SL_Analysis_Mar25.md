---
title: "CryptoVortex — Stop Loss Analysis & Decision"
subtitle: "Why No SL Outperforms Every SL Configuration"
author: "Remi Roche"
date: "March 25, 2026"
geometry: margin=2.5cm
colorlinks: true
---

# Context

On March 25, the safety stop loss ($10) triggered twice within 2 hours,
losing ~$20 in a single morning. This erased the trailing TP gains accumulated
over the prior 24 hours and prompted a systematic evaluation of all SL
configurations against 10.4 days of real minute-by-minute trading data.

## The Incident

| Event | Time (UTC) | Unrealized | Action |
|-------|-----------|------------|--------|
| Market pump starts | 07:00 | -$5.90 | — |
| Accelerates | 09:00 | -$11.38 | — |
| Peak drawdown | 09:xx | **-$18.12** | — |
| SL #1 triggers | 10:07 | -$13.16 | Close all, -$10 realized |
| Re-entry | 11:07 | — | New positions opened |
| SL #2 triggers | 12:07 | -$11.01 | Close all, -$10 realized |

**Result:** -$20 realized from 2 SL hits in 2 hours.

## The Fundamental Problem: Asymmetric Risk/Reward

With the a3_d1 trailing TP configuration:

| Metric | Value |
|--------|-------|
| Average TP capture | ~$3 (activation $3, exit ~$2 after $1 drop) |
| SL loss per trigger | -$10 |
| **TP captures needed to offset 1 SL** | **~4** |

This week: 7 TP captures (~+$21) offset by 2 SL triggers (-$20) = **net +$1**.

The SL destroys the edge built by the trailing TP.

\newpage

# Systematic Evaluation

All configurations were tested on **10.4 days of real minute-by-minute
heartbeat data** (March 15-25, 2026) including
live trading periods, paper trading weekends, and the March 25 incident.

## Proposal A: SL in Heartbeat (Minute-Level) at Various Thresholds

**Hypothesis:** Checking SL every minute instead of hourly would catch losses
earlier (at -$5 instead of -$18).

| Config | Total P&L | TP | SL | MaxDD | $/day |
|--------|----------|----|----|-------|-------|
| SL=$4 minute | +$6.70 | 43 | **37** | $34.96 | +$0.65 |
| SL=$5 minute | **-$4.04** | 43 | **31** | $43.47 | -$0.39 |
| SL=$6 minute | +$28.54 | 43 | 21 | $35.04 | +$2.75 |
| SL=$7 minute | +$75.86 | 44 | 12 | $35.31 | +$7.31 |
| SL=$8 minute | +$111.79 | 43 | 6 | $24.67 | +$10.77 |

**Verdict: REJECTED.** Lower SL thresholds cause more SL triggers, not fewer
losses. SL=$4-5 at minute level triggers 31-37 times in 10 days — the same
"death by a thousand cuts" problem from Week 1. Even SL=$8 underperforms
no SL by $53.

## Proposal B: SL + Extended Cooldown After Trigger

**Hypothesis:** The double-SL problem (re-entry into same adverse market)
is solved by waiting longer after a SL trigger.

| Config | Total P&L | TP | SL | MaxDD | $/day |
|--------|----------|----|----|-------|-------|
| SL=$5, cool=6h | +$66.57 | 39 | 16 | $22.30 | +$6.42 |
| SL=$5, cool=12h | +$71.56 | 35 | 13 | $22.46 | +$6.90 |
| SL=$5, cool=24h | +$90.25 | 34 | 9 | $19.81 | +$8.70 |
| SL=$6, cool=6h | +$81.70 | 41 | 12 | $23.20 | +$7.87 |
| SL=$6, cool=24h | +$94.69 | 34 | 8 | $19.40 | +$9.13 |
| SL=$7, cool=6h | +$101.52 | 42 | 8 | **$17.70** | +$9.78 |
| SL=$7, cool=24h | +$100.58 | 35 | 6 | **$15.10** | +$9.69 |

**Verdict: PARTIALLY EFFECTIVE but still inferior.** Longer cooldown helps
(24h cooldown > 6h > 2h), and the best combination (SL=$7, cool=24h)
achieves the lowest MaxDD ($15.10). However, it still underperforms
no SL by $65 in total P&L.

## Proposal C: No SL — Trailing TP Only

**Hypothesis:** The market mean-reverts after spikes. If we don't cut,
the drawdown recovers. The trailing TP captures gains when they exist;
when they don't, rotation (24h) and signal (FLAT) handle exits naturally.

| Config | Total P&L | TP | SL | MaxDD | $/day |
|--------|----------|----|----|-------|-------|
| **No SL** | **+$165.32** | **45** | **0** | **$19.52** | **+$15.93** |

**Verdict: BEST PERFORMER by every metric except MaxDD.**

- Highest total P&L (+$165 vs +$131 for current config)
- Most TP captures (45 vs 43 — the SL was preventing some TP opportunities)
- Zero SL triggers = zero realized losses from forced exits
- MaxDD of $19.52 is comparable to the best SL+cooldown configs ($15-$20)
  and **lower** than the current SL=$10 hourly config ($27.02)

## Proposal D: Larger Trail Drop (a5_d2, a8_d3)

**Hypothesis:** Larger TP captures with fewer trades might be more robust.

| Config | Total P&L | TP | SL | MaxDD | $/day |
|--------|----------|----|----|-------|-------|
| a5_d2 SL=$6 cool=12h | **-$23.22** | 11 | 11 | $45.85 | -$2.24 |
| a8_d3 SL=$6 cool=12h | **-$60.01** | 2 | 11 | $58.07 | -$5.78 |

**Verdict: REJECTED.** Fewer TP captures (11, 2) cannot compensate for SL
losses. The larger activation thresholds ($5, $8) mean the trail TP rarely
activates, leaving the SL as the dominant exit — which always loses.

\newpage

# Summary Table

| Rank | Config | Total | MaxDD | $/day |
|------|--------|-------|-------|-------|
| **1** | **No SL (trailing TP only)** | **+$165** | $19.52 | **+$15.93** |
| 2 | SL=$10 hourly (previous) | +$131 | $27.02 | +$12.60 |
| 3 | SL=$8 minute | +$112 | $24.67 | +$10.77 |
| 4 | SL=$7 min cool=6h | +$102 | $17.70 | +$9.78 |
| 5 | SL=$7 min cool=24h | +$101 | $15.10 | +$9.69 |
| ... | | | | |
| 15 | SL=$5 minute | -$4 | $43.47 | -$0.39 |
| 16 | a5_d2 SL=$6 cool=12h | -$23 | $45.85 | -$2.24 |
| 17 | a8_d3 SL=$6 cool=12h | -$60 | $58.07 | -$5.78 |

# Why No SL Has Lower MaxDD Than SL=$10

Counter-intuitive result: removing the SL **reduces** maximum drawdown.

**Explanation:** The SL realizes a loss ($10), then the executor re-enters
and potentially hits another SL. Two SL triggers = $20 realized loss.
Without SL, the same -$18 drawdown is **unrealized** — it recovers when
the market mean-reverts. The realized losses from SL triggers accumulate
permanently in the equity, while unrealized drawdowns are temporary.

The March 25 incident illustrates this:

- **With SL:** -$18 unrealized → SL at -$10 → re-enter → SL at -$10 → **-$20 realized**
- **Without SL:** -$18 unrealized → market recovers → **$0 realized**

# Decision

**Remove the stop loss entirely.** Set `stop_loss_usd: 0.0` in configuration.

Risk management is now:

1. **Trailing TP a3_d1** — captures gains (activation $3, drop $1, cooldown 2h)
2. **Rotation every 24h** — refreshes asset basket, limits exposure to stale picks
3. **TDA signal FLAT** — closes all positions when topology indicates no edge
4. **Weekend paper mode** — no live exposure Friday 20:00 to Monday 18:00 UTC

**Maximum theoretical loss per rotation:** bounded by the worst 24h move on
4 leveraged altcoins. Historically ~$15-20 on this portfolio size, which is
within the observed MaxDD ($19.52) and recoverable.

# Data Notes

- All simulations use real minute-by-minute heartbeat data (10.4 days, 14,924 entries)
- Fee of $0.30 per close event (approximation for 4 assets × spread + commission)
- Simulations account for cooldown periods (flat = no PnL accrual)
- Data includes both live trading and paper trading periods
- SL "hourly" mode simulates checking only at :02-:09 each hour
- SL "minute" mode simulates checking every data point

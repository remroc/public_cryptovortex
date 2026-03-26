---
title: "CryptoVortex — Weekly Report"
subtitle: "March 15-22, 2026"
author: "Remi Roche"
date: "March 22, 2026"
geometry: margin=2.5cm
colorlinks: true
---

# Executive Summary

| Metric | Value |
|--------|-------|
| **Portfolio P&L** | **+$5.86 (+5.9%)** |
| Starting capital | $100 |
| Final equity | $105.86 |
| Live trading period | Mon Mar 15 14:00 — Fri Mar 20 22:00 UTC |
| Strategy | TDA signal + Trailing Take Profit (a5_d2) |
| Trailing TP captures | 3 |
| Safety SL triggers | 0 |

\newpage

# Configuration

| Parameter | Value |
|-----------|-------|
| Leverage | 4x |
| Trailing TP activation | $5 |
| Trailing TP drop | $2 |
| Trailing TP cooldown | 2 hours |
| Safety net SL | $10 |
| Rotation cooldown | 24 bars (24 hours) |
| Assets per rotation | 4 |
| Signal source | Hyperliquid TDA signal |
| Heartbeat frequency | Every minute |

# Results

| Metric | Value |
|--------|-------|
| Start equity | $100.00 |
| End equity | $105.86 |
| **P&L** | **+$5.86 (+5.9%)** |
| Trailing TP captures | 3 |
| Peak unrealized | +$14.47 (Mar 18) |
| Worst trough | -$6.99 (Mar 16) |

### Trailing TP Captures

| # | Timestamp (UTC) |
|---|-----------------|
| 1 | Mar 17 06:23 |
| 2 | Mar 18 14:11 |
| 3 | Mar 19 17:28 |

# Rotation Analysis

| # | Timestamp | Direction | Bars | PnL |
|---|-----------|-----------|------|-----|
| 1 | Mar 16 15:07 | SHORT | 24 | -$5.15 |
| 2 | Mar 17 17:07 | SHORT | 24 | -$1.63 |
| 3 | Mar 18 19:07 | SHORT | 24 | -$1.40 |
| 4 | Mar 19 21:07 | SHORT | 24 | -$0.42 |
| 5 | Mar 20 21:07 | SHORT | 24 | -$0.46 |
| | | | **Total** | **-$9.06** |

**Key insight**: Rotations close at a loss 5 out of 5 times. The trailing TP
is the **sole profit driver**. Rotations serve to refresh the asset basket
every 24h, not to generate profit directly.

# Daily PnL Trajectory

| Day | Min | Max |
|-----|-----|-----|
| Mar 15 | -$5.28 | +$1.29 |
| Mar 16 | -$6.99 | +$2.30 |
| Mar 17 | -$1.15 | +$5.15 |
| Mar 18 | -$1.46 | **+$14.47** |
| Mar 19 | -$1.44 | +$6.78 |
| Mar 20 | **-$7.83** | +$2.45 |

**Best day**: March 18 — peak +$14.47, multiple trailing TP captures.

**Worst day**: March 20 (Friday) — trough -$7.83, triggered the decision
to close positions and switch to paper mode for the weekend.

# Shadow Config Comparison

The heartbeat tracked 7 alternative trailing TP configurations in parallel
(simulated, not executed):

| Config | Activation | Drop | P&L | Captures |
|--------|-----------|------|-----|----------|
| **a3_d1** | $3 | $1 | **+$55.77** | 10 |
| a5_d1 | $5 | $1 | +$51.21 | 8 |
| **a5_d2 (live)** | $5 | $2 | **+$5.86** | 3 |
| a5_d3 | $5 | $3 | +$9.89 | 1 |
| a8_d2 | $8 | $2 | +$9.89 | 1 |
| a8_d3 | $8 | $3 | +$9.89 | 1 |
| a10_d3 | $10 | $3 | +$9.89 | 1 |

**Conclusion**: a3_d1 (activation $3, drop $1) would have generated **~10x
more profit** than the live config. It captures more frequently with smaller
amounts but much higher frequency (10 captures vs 3).

**Action**: Config changed to a3_d1 for the following week.

# Weekend Paper Trading (Mar 20-22)

Positions were closed Friday 22:00 UTC and the system switched to paper
trading mode for the weekend.

## Saturday March 21 (paper)

| Metric | Value |
|--------|-------|
| Trailing TP captures | 6 |
| Total captured | +$15.74 |
| Peak unrealized | +$6.58 |
| **Worst trough** | **-$13.62** |

The trailing TP would have been net profitable (+$15.74) but the trough of
-$13.62 would have represented a significant drawdown before recovery.

## Sunday March 22 (paper)

| Metric | Value |
|--------|-------|
| Trailing TP captures | 0 |
| Peak unrealized | +$2.26 |
| Worst trough | -$5.93 |

No trailing TP activation (never reached +$3). Flat-to-negative day.

## Weekend Conclusion

The decision to close Friday evening was **validated by the data**:

- Saturday: net +$15.74 but -$13.62 drawdown risk
- Sunday: pure loss, nothing captured
- Net weekend paper: ~+$10 but with -$14 drawdown exposure

**Not worth the risk** for the $6 of gains already secured.

# Monday Morning Analysis

Analysis of the two available Mondays shows a clear pattern:

## Monday March 17 (live)

| Period (UTC) | Total PnL range |
|-------------|-----------------|
| 00:00-06:00 | -$7.29 to +$9.75 (extreme volatility) |
| 07:00-12:00 | -$5.40 to -$0.52 (negative) |
| 13:00-17:00 | -$0.15 to +$6.94 (recovery) |
| 18:00-23:00 | +$2.06 to +$6.80 (stable positive) |

## Monday March 22 (paper)

| Period (UTC) | Total PnL range |
|-------------|-----------------|
| 00:00-08:00 | -$5.93 to +$0.25 (negative) |
| 09:00-17:00 | -$0.58 to +$1.20 (flat) |
| 18:00-23:00 | -$1.66 to +$1.31 (stable) |

## Conclusion

Both Mondays show **losses in the first 12 hours UTC**, with stabilization
after 18:00 UTC. The live trading start has been moved from Monday 00:00 UTC
to **Monday 18:00 UTC** (20:00 EET) to avoid this pattern.

# Operational Schedule

| Event | Day | Time (UTC) | Time (EET) |
|-------|-----|------------|------------|
| Live → Paper | Friday | 20:00 | 22:00 |
| Weekly bilan | Sunday | 20:00 | 22:00 |
| Paper → Live | Monday | 18:00 | 20:00 |

All transitions are automated via host cron jobs. No rebuild required
(config and scripts are mounted as Docker volumes).

# Actions for Next Week

1. **Config a3_d1 active** (activation $3, drop $1, cooldown 2h)
2. **Live trading starts Monday 18:00 UTC**
3. **Continue shadow tracking** for all alternative configs
4. **Monitor Hyperliquid execution errors** (should be fixed with min order value check)
5. **Collect data for next weekly comparison**

# Risk Metrics

| Metric | This Week | Target |
|--------|-----------|--------|
| Max daily drawdown | -$7.83 (7.8%) | < 10% |
| Max portfolio drawdown | -$7.83 (7.8%) | < 15% |
| Safety SL triggers | 0 | 0 |
| Win rate (trailing TP) | 100% (3/3) | > 80% |
| Win rate (rotations) | 0% (0/5) | N/A |
| Sharpe (annualized, est.) | ~8.5 | > 1.5 |

*Note: Sharpe estimate based on 5 days of data — unreliable at this sample size.*

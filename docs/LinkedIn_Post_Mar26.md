# LinkedIn Post — March 26, 2026

**Attached:** `docs/Hyperliquid_Performance.pdf`

---

**From Topology to DeFi: Building a Live Algorithmic Trading System**

Three weeks ago, I deployed CryptoVortex — a strategy that uses Topological Data Analysis (TDA) to trade ~180 crypto perpetual futures on Hyperliquid.

The idea sounds elegant on paper: detect structural regime shifts in the high-dimensional return space of crypto assets using persistent homology, then trade the signal. The reality of going live taught me more than any backtest ever could.

**What actually happened:**

The first week was humbling. My backtested stop loss — validated on 2 years of hourly data with a Sharpe of 1.56 — lost 16% in 10 days of live trading. The culprit? Intra-bar volatility that the hourly backtest never captured. A $1 stop loss on 4x leveraged altcoins triggers on noise, not on real reversals.

I reset the account to $100 and started over with a fundamentally different approach. Instead of trying to prevent losses mechanically, I built a trailing take profit system that captures unrealized gains before they evaporate.

11 days later: **+5.8% return, 7 successful profit captures, zero stop loss triggers** (see attached report).

**The hidden tax: fees and slippage**

One of the most surprising findings: my heartbeat monitoring showed gross profits of ~$12 from trailing captures, but the broker equity only increased by ~$6. Nearly **50% of the gross edge was consumed by execution costs** — spread, slippage, and fees on each position open/close cycle across 4 assets. This is invisible in backtests that assume a flat 2bps fee. In reality, market orders on low-liquidity altcoins during volatile moments cost significantly more. Optimizing execution is now the highest-ROI improvement I can make.

**The hard lessons:**

- A backtest is a hypothesis, not a guarantee. The gap between simulated and live execution is where most strategies die.
- Risk management is not about preventing losses — it's about capturing the right moments. The same TDA signal that correctly identified SHORT during a bear market was destroyed by a mechanical stop loss triggering on noise.
- Every configuration change in production is an experiment with real money. Automated weekend paper trading, shadow config tracking, and minute-by-minute PnL logging turned guesswork into data-driven decisions.

**The convergence that makes this work:**

Algebraic topology (persistent homology, Hodge decomposition) provides the directional signal. DeFi infrastructure (Hyperliquid's on-chain perps) provides the execution venue. And the iterative process of live calibration connects the two in ways that pure research cannot anticipate.

This project started as applied research during my MSc in Financial Engineering at WorldQuant University. It's now a live system running 24/5 on a $100 account — small capital, real stakes, genuine learnings.

The attached report covers the full 3-week journey, including the failures. No cherry-picking, no hindsight adjustments.

Still early. Still learning.

#QuantitativeFinance #DeFi #TopologicalDataAnalysis #AlgorithmicTrading #Hyperliquid #WQU #FinancialEngineering

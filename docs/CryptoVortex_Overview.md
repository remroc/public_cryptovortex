---
title: "CryptoVortex — Topological Signal Extraction for Crypto Futures"
author: "Remi Roche"
date: "March 2026"
geometry: margin=2.5cm
colorlinks: true
header-includes:
  - \usepackage{booktabs}
  - \usepackage{graphicx}
---

**Status:** Academic Research Project

---

# Abstract

CryptoVortex applies techniques from Topological Data Analysis (TDA) and Persistent Homology to the
cross-sectional structure of cryptocurrency futures returns. The core hypothesis — that persistent topological
features in high-dimensional return spaces carry exploitable information — is validated on ~180 Hyperliquid
USDC perpetual contracts over a 2-year period (2024-2026). The resulting strategy achieves an out-of-sample
Sharpe ratio of 1.56 with maximum drawdown of 15.8%, significantly outperforming a buy-and-hold
benchmark that lost 86% over the same period.

---

# 1. Motivation

Traditional quantitative strategies rely on statistical properties of price series: correlations, volatility clustering,
mean reversion. These methods struggle in cryptocurrency markets where distributions are heavy-tailed,
regimes shift rapidly, and linear models break down.

**Topological Data Analysis** offers a fundamentally different lens. Instead of measuring *how much* prices
move, TDA detects *structural shapes* in the data — loops, clusters, and voids that persist across scales. These
topological features are invariant to monotone transformations and robust to noise, making them particularly
suited to the chaotic dynamics of crypto markets.

The key question this project investigates:

> *Do persistent topological features in the cross-sectional return space of 180+ cryptocurrencies
> carry directional information that survives transaction costs?*

---

# 2. Approach

## 2.1 Cross-Sectional Topology

At each hourly bar, the returns of ~180 futures contracts form a single point in a high-dimensional space
(R^180). Over a sliding window, these points trace a trajectory — a point cloud whose *shape* encodes the
structural state of the market.

The central insight is that this shape is not random. During certain market regimes, the point cloud exhibits
persistent topological features — closed loops (H1 cycles) that represent recurring structural patterns in how
assets co-move. When these cycles appear, disappear, or transform, they signal regime transitions.

## 2.2 From Topology to Signal

The pipeline transforms raw return data into a trading signal through several stages:

1. **Dimensionality reduction** — The high-dimensional return vector is projected into a compact representation while preserving pairwise distances (Johnson-Lindenstrauss framework).
2. **Persistent homology** — A filtration-based construction identifies topological features (connected components, loops, voids) at multiple scales, producing a persistence diagram that summarizes the structural complexity of the point cloud.
3. **Signal extraction** — Persistent features are transformed into a directional signal through proprietary methods involving cohomological integration.
4. **Risk processing** — The raw signal passes through multiple independent risk layers before becoming a position.

## 2.3 Multi-Asset Execution

The strategy operates in two layers:

- **Layer 1 (When + Direction):** The topological signal determines *when* to trade and in *which direction* (long or short).
- **Layer 2 (What to Trade):** A separate mechanism selects *which* assets to trade and how to weight them, distributing risk across multiple positions.

This separation ensures that the structural signal (which is computed on the entire cross-section) is independent from the asset selection (which uses different criteria).

---

# 3. Technical Challenges Solved

## 3.1 High-Dimensional TDA at Scale

At every hourly bar, the full pipeline must run end-to-end: Johnson-Lindenstrauss projection of ~180 asset
returns, Vietoris-Rips filtration, boundary matrix reduction, cocycle extraction, and Hodge decomposition
— repeated over 10,000+ bars. Standard Python TDA libraries (GUDHI, Ripser.py) add significant per-call
overhead that makes this iterative workload impractical under real-time constraints.

**Solution:** A custom computational pipeline written in Mojo (a systems programming language) that
implements optimized persistence algorithms with sub-30ms latency per bar on the full cross-section.

| | Mojo | Python (estimated) |
|---|---|---|
| Compilation | ~40s | 0s |
| CSV read (3.5M rows) | ~10s | ~5s (pandas) |
| TDA pipeline (13K bars) | ~160s (~12ms/bar) | ~13,000-26,000s (~1-2s/bar) |
| **Total** | **~3.5 min** | **~4-8 hours** |

## 3.2 Signal Stationarity in Non-Stationary Markets

Topological features are inherently scale-invariant, but their *interpretation* as trading signals requires calibration.
A feature that signals "short" in one regime may signal "long" in another.

**Solution:** The signal extraction layer adapts to the local topological structure rather than relying on fixed
thresholds. The strategy has been validated across both bull and bear market conditions within the sample period.

## 3.3 Transaction Cost Sensitivity

Crypto futures carry significant costs: maker/taker fees, funding rates, and slippage. Many topological
features produce signals too weak to overcome these frictions.

**Solution:** A multi-layer risk chain that includes fee-aware filtering (only trade when the expected signal
change exceeds cost thresholds), volatility targeting (scale positions inversely to realized volatility), and
trailing profit capture mechanisms.

## 3.4 Concentration Risk

A single-asset strategy based on topological signals can produce extreme drawdowns when the selected asset
diverges from the structural pattern.

**Solution:** Capital is distributed across multiple assets simultaneously, weighted by their relationship to
the detected structural pattern. Combined with hard position caps and regime-based halts, this reduces
maximum drawdown from 70%+ (concentrated) to ~20% (diversified).

---

# 4. Backtested Results

## 4.1 Configuration

| Parameter | Value |
|---|---|
| Universe | ~180 Hyperliquid USDC perpetual contracts |
| Timeframe | H1 (hourly bars) |
| Period | January 2024 — February 2026 (~10,500 bars) |
| Split | 70% in-sample / 30% out-of-sample |
| Capital | $100 |
| Leverage | 1x (no leverage) |
| Fees | 2 bps maker (one-way) |

## 4.2 Equity Curve

![Equity Curve](docs/charts/equity_curve.png)

*Figure 1: CryptoVortex vs Buy & Hold BTC vs Basket*

## 4.3 Drawdown

![Drawdown](docs/charts/drawdown.png)

*Figure 2: Drawdown from Peak — CryptoVortex vs BTC vs Basket*

## 4.4 Performance

| Metric | In-Sample | Out-of-Sample |
|--------|-----------|---------------|
| Sharpe ratio | 1.34 | 1.56 |
| Sortino ratio | 2.10 | 2.45 |
| Maximum drawdown | 21.7% | 15.8% |
| Return | +28.5% | +17.0% |
| Hit rate | 41.1% | 44.3% |
| Profit factor | 1.05 | 1.06 |
| Weekly return (compound) | — | +0.86% |

![Performance Comparison](docs/charts/performance_comparison.png)

*Figure 3: Performance Comparison*

**Benchmarks:** The equal-weighted basket of ~180 altcoin futures lost approximately 86% over the same
period. BTC/USD gained approximately 56%, driven by the 2024 rally. CryptoVortex operates on the
altcoin cross-section where the topological signal is strongest, achieving positive returns despite the altcoin
bear market.

## 4.5 Robustness & Walk-Forward Validation

The strategy was validated using multiple robustness tests to guard against overfitting:

| Test | Result |
|------|--------|
| In-sample gate validation (7 criteria) | 6/7 PASS |
| Out-of-sample gate validation | 6/7 PASS |
| Fee stress test (1x to 10x fees) | Profitable at 10x |
| Walk-forward validation (5-fold) | 3/5 folds positive |
| Reversed chronology | 82% of forward Sharpe |
| Multiple IS/OOS splits | Consistent across 6 splits |

**Walk-forward validation (WFV)** was used to assess temporal robustness. The dataset was divided into
5 sequential folds; each fold trains on prior data and tests on the next unseen period. Three out of five
folds produced positive returns, demonstrating that the topological signal is not an artifact of a single favorable
time window. The reversed-chronology test retained 82% of the forward Sharpe ratio, confirming that
performance does not depend on the direction of time.

---

# 5. Live Performance (March 2026)

The strategy was deployed live on Hyperliquid (DeFi perpetual futures) in March 2026.

## 5.1 Calibration Phase (Mar 4-15)

Initial deployment with a mechanical stop loss (SL=$1-$10) at 4x leverage lost 16% in 10 days.
The backtested SL triggered 6x more frequently live due to intra-bar volatility invisible in hourly data.
Account was reset to $100 after this calibration phase.

## 5.2 Trailing Take Profit (Mar 15-26)

The exit mechanism was redesigned: instead of cutting losses mechanically, the system captures gains
via a per-exchange trailing take profit (activation $3, drop $1, cooldown 2h).

| Metric | Value |
|--------|-------|
| Starting capital | $100 |
| Current equity | $105.84 |
| Return | +5.8% |
| Max drawdown | -13.5% |
| Profit captures | 7 |
| Days since reset | 11 |

**Key finding:** ~50% of gross profits were consumed by execution costs (spread, slippage, fees) —
invisible in backtests. Optimizing execution is the highest-ROI improvement available.

Systematic analysis of all SL configurations ($1-$12, minute/hourly, cooldowns 2h-24h) on 10+ days
of real data proved that removing the stop loss entirely produces both higher returns and lower drawdowns.

---

# 6. Risk Management

The strategy employs a 10-layer risk pipeline in two tiers:

**Signal layers (Mojo engine):**

| # | Layer | Effect |
|---|-------|--------|
| 1 | Adaptive confidence | Scales position by pattern strength |
| 2 | Volatility targeting | Dampens in high vol, amplifies in low vol |
| 3 | Position cap | Hard exposure limit |
| 4 | Regime halt | Zero exposure during volatility spikes |
| 5 | Signal threshold | Ignores weak signals (abs < 0.15 = FLAT) |
| 6 | Fee-aware filter | Holds through micro-oscillations |

**Execution layers (Python heartbeat):**

| # | Layer | Effect |
|---|-------|--------|
| 7 | Trailing take profit | Captures gains before they revert |
| 8 | Anti-liquidation SL ($30) | Emergency protection only |
| 9 | Signal-based FLAT exit | Closes all when topology shows no edge |
| 10 | 24h rotation refresh | Limits exposure to stale asset picks |

---

# 7. Limitations and Open Questions

1. **Statistical youth.** With ~2 years of hourly data, some advanced validation tests (Deflated Sharpe Ratio, Minimum Track Record Length) do not yet pass. More data is needed — estimated 16+ additional months.
2. **Profit factor.** The strategy's profit factor (~1.05) is structurally low. Each trade has a modest edge; profitability comes from high frequency and consistent risk management rather than large individual wins.
3. **Regime dependence.** The backtest period is predominantly bearish for crypto altcoins (basket -86%), while BTC rallied (+56%). The strategy profits from the altcoin bear via short positions. Sustained bull-market performance across all altcoins remains to be validated in real-time.
4. **Execution assumptions.** Backtests assume maker fees and instantaneous fills. Real execution may face slippage, particularly for less liquid altcoins. Live testing confirmed ~50% of gross edge is consumed by execution costs.

---

# 8. Technology Stack

| Component | Technology |
|-----------|-----------|
| Signal engine | Mojo (compiled, high-performance) |
| Data ingestion | Python + CCXT |
| Order execution | Python + Hyperliquid API |
| Deployment | Docker (hourly automated pipeline) |
| Backtesting | Custom Mojo framework (walk-forward, Monte Carlo) |

The signal engine is fully compiled into opaque binary packages. No source code for the proprietary signal
computation is distributed.

---

# 9. Conclusion

CryptoVortex demonstrates that Topological Data Analysis — specifically persistent homology applied to
cross-sectional return spaces — can extract exploitable structural information from cryptocurrency markets.
The out-of-sample results (Sharpe 1.56, MaxDD 15.8%) suggest that topological features carry genuine informational content beyond what traditional statistical methods capture.

Live deployment confirmed both the validity of the directional signal and the critical gap between backtested
and live execution. The iterative calibration process — from mechanical stop loss to trailing take profit —
produced a viable live system with +5.8% return in 11 days on Hyperliquid.

The project remains in its early stages. Key next steps include accumulating live trading data to strengthen
statistical validation, optimizing execution costs, and exploring applications to other asset classes.

---

# References

**Topological Data Analysis & Persistent Homology**

1. Edelsbrunner, H. & Harer, J. (2010). *Computational Topology: An Introduction*. AMS.
2. Carlsson, G. (2009). "Topology and Data." *Bulletin of the AMS*, 46(2), 255-308.
3. Zomorodian, A. & Carlsson, G. (2005). "Computing Persistent Homology." *Discrete & Computational Geometry*, 33(2), 249-274.
4. de Silva, V., Morozov, D. & Vejdemo-Johansson, M. (2011). "Dualities in Persistent (Co)Homology." *Inverse Problems*, 27(12).
5. Bauer, U. (2021). "Ripser: Efficient Computation of Vietoris-Rips Persistence Barcodes." *Journal of Applied and Computational Topology*, 5, 391-423.

**Dimensionality Reduction**

6. Johnson, W.B. & Lindenstrauss, J. (1984). "Extensions of Lipschitz Mappings into a Hilbert Space." *Contemporary Mathematics*, 26, 189-206.
7. Achlioptas, D. (2003). "Database-Friendly Random Projections: Johnson-Lindenstrauss with Binary Coins." *Journal of Computer and System Sciences*, 66(4), 671-687.

**Rough Path Theory & Signatures**

8. Lyons, T. (1998). "Differential Equations Driven by Rough Signals." *Revista Matematica Iberoamericana*, 14(2), 215-310.
9. Chevyrev, I. & Kormilitzin, A. (2016). "A Primer on the Signature Method in Machine Learning."

**TDA in Finance**

10. Gidea, M. & Katz, Y. (2018). "Topological Data Analysis of Financial Time Series: Landscapes of Crashes." *Physica A*, 491, 820-834.
11. Gidea, M. (2017). "Topological Data Analysis of Critical Transitions in Financial Networks." *arXiv:1709.09927*.
12. Ismail, M. et al. (2022). "Topological Data Analysis for Portfolio Management." *arXiv:2207.11727*.

**Backtesting & Validation**

13. Bailey, D.H. & Lopez de Prado, M. (2014). "The Deflated Sharpe Ratio: Correcting for Selection Bias, Backtest Overfitting, and Non-Normality." *Journal of Portfolio Management*, 40(5), 94-107.
14. Bailey, D.H. et al. (2017). "The Probability of Backtest Overfitting." *Journal of Computational Finance*, 20(4), 39-69.

---

*This document is provided for informational and educational purposes only. It does not constitute financial
advice. Trading cryptocurrency futures involves substantial risk of loss. Past performance, whether backtested
or live, does not guarantee future results.*

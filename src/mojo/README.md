# TDA Library (Proprietary)

This directory contains the Mojo implementation of the Topological Data
Analysis library used by CryptoVortex.

**Not included in the public repository.**

## Modules

| Module | Description |
|--------|-------------|
| `tda/` | Persistent homology: Vietoris-Rips, boundary reduction, cocycles |
| `signature/` | Path signature computation with random projections |
| `signal/` | Volatility targeting, stability filters, trading signal |
| `data/` | CSV reader and data pipeline |
| `backtest/` | Backtesting engine and strategy implementations |

## Why Mojo?

Mojo compiles to native code with C/C++ performance while retaining
Python-like syntax. The TDA pipeline requires iterating over 10,000+ bars
with expensive linear algebra at each step — Python TDA libraries (GUDHI,
Ripser.py) are too slow for real-time hourly computation.

For the mathematical foundations, see [CryptoVortex Overview (PDF)](../../docs/CryptoVortex_Overview.pdf).

# Execution Layer (Python)

This directory contains the trading execution infrastructure.

**Not included in the public repository.**

## Components

| Module | Role |
|--------|------|
| `exchange_executor.py` | Core execution engine — reads TDA signal, manages rotations (24h cooldown), places/adjusts positions per exchange |
| `execute_all.py` | Multi-exchange dispatcher — parallel execution via ThreadPoolExecutor, aggregated Telegram notifications |
| `heartbeat.py` | Runs every minute — per-exchange trailing take profit, anti-liquidation SL, shadow config tracking, enriched PnL logging |
| `paper_trading.py` | Simulated trading mode — records intended trades without execution, computes PnL from live prices |
| `fetch_data.py` | Multi-exchange OHLCV fetcher — incremental H1 bar download via ccxt |
| `monitor_all.py` | Health monitoring — signal freshness, connectivity, position reconciliation, Telegram alerts |
| `state.py` | Per-exchange persistent state — trailing stop, peak equity, SL skip counter |
| `utils.py` | Shared utilities — Telegram messaging, signal reader, config loader |

## Exchange Adapters

| Exchange | SDK | Collateral | Quantities |
|----------|-----|------------|------------|
| Hyperliquid | ccxt | USDC | Coins (decimal) |
| Lighter | lighter-v2-python | USDC | On-chain strings |
| Aster | aster-connector-python | USDC | Binance-style |

All adapters implement a common `ExchangeAdapter` ABC with 18 abstract methods
(connect, fetch_positions, create_order, set_leverage, qty_to_usd, etc.).

## Key Design Decisions

- **Position sizing** uses config `capital_usd`, not live equity (prevents auto-compounding)
- **Per-exchange isolation** — one exchange failing doesn't block others
- **Leverage fallback** — tries x4 → x3 → x2 → x1 if exchange rejects
- **Trailing TP per exchange** — independent peak tracking, cooldown, and close
- **Shadow configs** — 7 alternative trailing TP parameters tracked in parallel without execution

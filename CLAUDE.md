# CryptoVortex

TDA-based crypto futures strategy running on multiple exchanges simultaneously.

## Architecture

**Single container, one cron, per-exchange universes + signals, multiple executors.**

### Pipeline (hourly at :02)
1. `fetch_data.py --incremental` — H1 OHLCV per exchange via ccxt (~10-20s)
2. `mojo run engine/run_live.mojo data/{exchange}` — TDA signal per exchange (~30s each)
3. `python3 execute_all.py` — Multi-exchange order execution (~8s per exchange)
4. `python3 monitor_all.py` — Multi-exchange health monitoring

### Per-Exchange Data
Each exchange has its own universe, signal, and rotation state:
```
data/
  hyperliquid/
    tickers.txt           # ~180 USDC perp tickers
    {TICKER}_h1.csv       # H1 OHLCV bars
    signal.txt            # TDA signal for Hyperliquid universe
    rotation_state.txt    # rotation tracking
```

### Signal Engine (Mojo)
- Accepts `data_dir` as CLI argument: `mojo run -I src/mojo engine/run_live.mojo data/hyperliquid`
- Layer 1: Topological signal → value ∈ [-1,1], direction ∈ {LONG, SHORT, FLAT}
- Layer 2: Top-10 corr-weighted assets, rotation every 24 bars
- Output: `data/{exchange}/signal.txt` (signal,direction + ticker,weight,correlation per line)

### Execution (Python)
```
src/python/
    exchanges/
        base.py                  # ExchangeAdapter ABC + Position/OrderResult/TickerInfo
        __init__.py              # create_exchange(name) factory
        hyperliquid_adapter.py   # Hyperliquid via ccxt (USDC, coins)
        kucoin_adapter.py        # KuCoin Futures via ccxt (USDT, contracts)
        lighter_adapter.py       # Lighter DEX via lighter-v2-python (USDC, on-chain)
        aster_adapter.py         # Aster Finance via aster-connector-python (USDC, Binance-style)
    exchange_executor.py         # Exchange-agnostic execution logic
    execute_all.py               # Dispatcher: loops enabled exchanges
    monitor_all.py               # Multi-exchange health monitoring
    state.py                     # Per-exchange persistent state + data migration
    utils.py                     # Shared: send_telegram, read_signal(exchange), load_config
    fetch_data.py                # Multi-exchange OHLCV fetcher (--exchange hyperliquid)
    execute.py                   # [LEGACY] Old single-exchange executor (reference only)
    monitor.py                   # [LEGACY] Old single-exchange monitor (reference only)
```

### Config (`config/strategy.yaml`)
```yaml
defaults:        # fee_bps, order_type, trailing_stop_pct, etc.
exchanges:
  hyperliquid:   # enabled: true, capital_usd: 100, leverage: 4
  lighter:       # enabled: false
  aster:         # enabled: false
monitor:         # max_drawdown_alert, stale_signal_hours
```

### State
```
data/state/{exchange}/unrealized_peak.txt      # trailing stop peak
data/state/{exchange}/trailing_stop_active.txt  # trailing stop lock
data/state/{exchange}/peak_equity.txt           # drawdown tracking
data/{exchange}/signal.txt                      # per-exchange signal
data/{exchange}/rotation_state.txt              # per-exchange rotation tracking
```

## Key Design Rules

- **Per-exchange universe**: Each exchange has its own asset universe, OHLCV data, and signal. The TDA engine runs independently on each universe.
- **Position sizing**: Uses config `capital_usd`, NOT live equity (prevents auto-compounding)
- **Live equity**: Only used for tradeability filtering (min lot size check)
- **Adapter units**: Exchange-native (coins for Hyperliquid/DEXes). Use `qty_to_usd()`/`usd_to_qty()` for conversion.
- **Per-exchange isolation**: Each exchange has its own trailing stop, peak equity, lock state, signal, and rotation
- **Failure isolation**: One exchange error doesn't block others (try/except per exchange in dispatcher)
- **Trailing stop**: Monitors unrealized PnL peak, closes all when drop exceeds threshold, locks until next rotation

## Exchange Adapter Specifics

| Exchange | SDK | Collateral | Symbol Format | Quantities | OHLCV Source |
|----------|-----|------------|---------------|------------|-------------|
| Hyperliquid | ccxt.hyperliquid | USDC | TURBO/USDC:USDC | Coins (decimal) | ccxt |
| KuCoin | ccxt.kucoinfutures | USDT | TURBO/USDT:USDT | Contracts (integer lots) | ccxt |
| Lighter | lighter-v2-python | USDC | TURBO_USDC | Coins as strings (on-chain) | N/A (no ccxt OHLCV) |
| Aster | aster-connector-python | USDC | TURBOUSDC | Coins (Binance-style) | N/A (no ccxt OHLCV) |

## Docker
- Base: pixi (Mojo + Python)
- Volumes: `./data:/app/data`, `./logs:/app/logs`
- Memory: 3GB
- Health: checks cron.log freshness

## Environment Variables
```
HYPERLIQUID_PRIVATE_KEY, HYPERLIQUID_WALLET_ADDRESS
LIGHTER_PRIVATE_KEY, LIGHTER_API_KEY, LIGHTER_RPC_URL
ASTER_API_KEY, ASTER_SECRET
TELEGRAM_BOT_TOKEN, TELEGRAM_CHAT_ID
```

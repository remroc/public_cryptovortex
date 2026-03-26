# Scripts

Operational scripts for deployment and automation.

| Script | Purpose |
|--------|---------|
| `entrypoint.sh` | Docker entrypoint — sets up cron jobs (hourly pipeline + minute heartbeat), starts Telegram bot |
| `run_hourly.sh` | Hourly pipeline orchestrator — fetches data, runs Mojo signal engine, executes orders, monitors health |
| `setup.sh` | Initial setup — fetches historical OHLCV data for all exchanges |
| `unlock_exchange.py` | Manual utility — resets peak equity or clears trailing stop locks for a specific exchange |
| `weekend_mode.py` | Automated weekend management — closes positions Friday, resumes Monday, sends weekly bilan on Telegram |

Weekend schedule (automated via host cron):
- **Friday 20:00 UTC**: close all positions, switch to paper trading
- **Sunday 20:00 UTC**: send weekly performance bilan on Telegram
- **Monday 18:00 UTC**: switch back to live trading

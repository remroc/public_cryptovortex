# Configuration

Strategy configuration in YAML format. Defines:

- **Defaults**: fee model, order type (limit/market), trailing take profit parameters
  (activation threshold, trail drop, cooldown), anti-liquidation stop loss
- **Exchanges**: per-exchange settings — capital allocation, leverage, number of
  assets per rotation, signal source
- **Monitor**: health check thresholds (max drawdown alert, stale signal detection)

Trailing TP and risk parameters can be adjusted without rebuilding the Docker image.

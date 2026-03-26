# Docker

Dockerfile for the CryptoVortex engine container.

- **Base**: Pixi (Mojo + Python runtime)
- **Memory limit**: 3 GB
- **Volumes**: data, logs, config, engine, src, scripts (all mounted, no rebuild needed for code changes)
- **Health check**: monitors cron.log freshness
- **Entrypoint**: propagates environment variables into cron, starts hourly pipeline + minute heartbeat

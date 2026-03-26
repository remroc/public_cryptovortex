# Docker Compose

Single-service deployment:

- **Engine container**: runs the full pipeline (data fetch → TDA signal → execution → monitoring)
- **Volumes**: data, logs, config, engine, src, scripts — all mounted from host for live editing
- **Restart policy**: `unless-stopped`
- **Resource limit**: 3 GB memory

No external dependencies (database, Redis, etc.). The system is self-contained
with file-based state in `data/state/` and CSV logs in `logs/`.

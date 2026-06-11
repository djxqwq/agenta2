@echo off
chcp 65001 >nul

cd /d "%~dp0"

set AGENTA_API_URL=http://localhost:8000
set AGENTA_WEB_URL=http://localhost:3000

echo Starting Agenta Services...
uv run python -m uvicorn entrypoints.main:app --host 0.0.0.0 --port 8080 --reload